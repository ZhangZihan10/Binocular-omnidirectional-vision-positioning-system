function Loc = CVsystem4_1(Client)
% 两个相机成像都要有，彻底去噪：只保留最大的两个连通分量
% 输出 Loc = [x_mean/10, y_mean/10] 单位：cm
% 绘图时坐标除以10，但标签显示为 mm（数值不变，仅改单位文字）

% 读取两个图像
image  = ImageReadTCP_One(Client, 'Center');
image1 = ImageReadTCP_One1(Client, 'Center');

img  = las_segm(image);
img1 = las_segm(image1);

% 加载标定参数
load('Omni_Calib_Results_Unity.mat');
ocam_model = calib_data.ocam_model;

% 系统参数（原始单位 mm）
camX = 0; camY = 0; camZ = 0;
lasX = 0; lasY = 0; las_dist = 1950;
CVsyst_x  = -1700; CVsyst_y  = -800;  CVsyst_rot  = 0;
CVsyst_x1 =  2500; CVsyst_y1 = 4500;  CVsyst_rot1 = 0;

% 坐标映射（原始单位 mm）
[x, y]   = mapping(img,  CVsyst_rot,  CVsyst_x,  CVsyst_y, ...
                   camX, camY, camZ, lasX, lasY, las_dist, ocam_model);
[x1, y1] = mapping(img1, CVsyst_rot1, CVsyst_x1, CVsyst_y1, ...
                   camX, camY, camZ, lasX, lasY, las_dist, ocam_model);

% 强制转换为列向量
x = x(:); y = y(:);
x1 = x1(:); y1 = y1(:);

% 合并点云
combinedX = [x; x1];
combinedY = [y; y1];

% 删除零值
combinedX = nonzeros(combinedX);
combinedY = nonzeros(combinedY);

% 删除两个CV系统原点（容差）
tol = 1e-6;
idx_origin1 = (abs(combinedX - CVsyst_x) < tol) & (abs(combinedY - CVsyst_y) < tol);
idx_origin2 = (abs(combinedX - CVsyst_x1) < tol) & (abs(combinedY - CVsyst_y1) < tol);
keepIdx = ~(idx_origin1 | idx_origin2);
combinedX = combinedX(keepIdx);
combinedY = combinedY(keepIdx);

% ========== 去噪：只保留点数最多的两个簇 ==========
points = [combinedX, combinedY];
nPts = size(points, 1);
x_clean = []; y_clean = [];

if nPts >= 2
    distTh = 10;   % 距离阈值 (mm)
    visited = false(nPts, 1);
    clusters = {};
    
    for i = 1:nPts
        if ~visited(i)
            queue = i;
            visited(i) = true;
            cluster = [];
            while ~isempty(queue)
                idx = queue(1);
                queue(1) = [];
                cluster = [cluster; idx];
                for j = 1:nPts
                    if ~visited(j)
                        dist = sqrt((points(idx,1)-points(j,1))^2 + (points(idx,2)-points(j,2))^2);
                        if dist <= distTh
                            visited(j) = true;
                            queue = [queue; j];
                        end
                    end
                end
            end
            clusters{end+1} = cluster;
        end
    end
    
    sizes = cellfun(@length, clusters);
    [sortedSizes, sortIdx] = sort(sizes, 'descend');
    numKeep = min(2, length(clusters));
    minPoints = 30;
    validClusters = sizes(sortIdx(1:numKeep)) >= minPoints;
    if any(validClusters)
        keepIdx_all = [];
        for k = 1:numKeep
            if sizes(sortIdx(k)) >= minPoints
                keepIdx_all = [keepIdx_all; clusters{sortIdx(k)}];
            end
        end
        x_clean = points(keepIdx_all, 1);
        y_clean = points(keepIdx_all, 2);
    else
        [~, maxIdx] = max(sizes);
        x_clean = points(clusters{maxIdx}, 1);
        y_clean = points(clusters{maxIdx}, 2);
        warning('未找到足够大的簇，仅保留最大簇（点数：%d）', max(sizes));
    end
else
    x_clean = combinedX;
    y_clean = combinedY;
end

% 计算平均值（原始 mm）
if isempty(x_clean)
    warning('去噪后无有效激光点！');
    x_mean_mm = NaN; y_mean_mm = NaN;
else
    x_mean_mm = mean(x_clean);
    y_mean_mm = mean(y_clean);
    fprintf('去噪后保留的总点数：%d\n', length(x_clean));
    fprintf('原始平均值（mm）： x = %.2f, y = %.2f\n', x_mean_mm, y_mean_mm);
end

% 转换为 cm（除以10）
x_mean_cm = x_mean_mm / 10;
y_mean_cm = y_mean_mm / 10;
fprintf('输出平均值（cm）： x = %.2f, y = %.2f\n', x_mean_cm, y_mean_cm);

% ========== 绘图：数据仍为除以10后的值（cm），但标签显示为 mm ==========
x_clean_cm = x_clean / 10;
y_clean_cm = y_clean / 10;
CVsyst_x_cm  = CVsyst_x  / 10;
CVsyst_y_cm  = CVsyst_y  / 10;
CVsyst_x1_cm = CVsyst_x1 / 10;
CVsyst_y1_cm = CVsyst_y1 / 10;

figure('Name', 'Both Cameras - Clean Laser', 'NumberTitle', 'off');
scatter(x_clean_cm, y_clean_cm, 5, 'filled');
hold on;
plot(CVsyst_x_cm, CVsyst_y_cm, 'r*', 'MarkerSize', 10);
plot(CVsyst_x1_cm, CVsyst_y1_cm, 'r*', 'MarkerSize', 10);
grid on;
xlabel('X (mm)'); ylabel('Y (mm)');   % 标签改为 mm，但数值实际是 cm
title('Both Cameras - Clean Laser Points (Largest 2 Clusters, Units: mm)');
legend('相机成像点云', 'CV原点1', 'CV原点2', 'Location', 'best');
axis equal;
hold off;

% 输出平均值（单位 cm，如需改为 mm 请告知）
Loc = [x_mean_cm, y_mean_cm];
end