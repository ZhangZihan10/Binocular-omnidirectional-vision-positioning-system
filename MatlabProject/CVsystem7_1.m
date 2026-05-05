function output = CVsystem4(a)
% 激光点云去噪 + 计算平均值
% 输入: a - TCP客户端句柄
% 输出: output - [x_mean_cm, y_mean_cm] 平均值，单位 cm
% 绘图时坐标除以10，但标签显示为 mm

Client = a;
image = ImageReadTCP_One(Client, 'Center');
img = las_segm(image);

% 加载标定参数
load('Omni_Calib_Results_Unity.mat');
ocam_model = calib_data.ocam_model;

% 系统参数（原始单位 mm）
camX = 0; camY = 0; camZ = 0;
lasX = 0; lasY = 0; las_dist = 1950;
CVsyst_x = -1700; CVsyst_y = -800; CVsyst_rot = 0;
CVsyst_x1 = 2500; CVsyst_y1 = 4500; CVsyst_rot1 = 0;

% 坐标映射（原始单位 mm）
[x, y] = mapping(img, CVsyst_rot, CVsyst_x, CVsyst_y, camX, camY, camZ, ...
                 lasX, lasY, las_dist, ocam_model);

% 去除零值以及两个CV系统原点
combinedVector1 = nonzeros(x);
combinedVector2 = nonzeros(y);
combinedVector1(combinedVector1 == CVsyst_x) = [];
combinedVector2(combinedVector2 == CVsyst_y) = [];
combinedVector1(combinedVector1 == CVsyst_x1) = [];
combinedVector2(combinedVector2 == CVsyst_y1) = [];

% 去噪：保留最大连通簇
points = [combinedVector1, combinedVector2];
if size(points, 1) > 0
    distThreshold = 10;  % 距离阈值 (mm)
    % 使用 dbscan（若没有工具箱，请使用附录中的自定义代码）
    labels = dbscan(points, distThreshold, 1);
    unique_labels = unique(labels);
    if unique_labels(1) == -1
        unique_labels = unique_labels(2:end);
    end
    counts = arrayfun(@(lab) sum(labels == lab), unique_labels);
    [~, maxIdx] = max(counts);
    mainLabel = unique_labels(maxIdx);
    keepIdx = (labels == mainLabel);
    x_filtered = points(keepIdx, 1);
    y_filtered = points(keepIdx, 2);
else
    x_filtered = []; y_filtered = [];
end

% 计算平均值（原始 mm）
if ~isempty(x_filtered)
    x_mean_mm = mean(x_filtered);
    y_mean_mm = mean(y_filtered);
    fprintf('原始平均值（mm）： x = %.2f, y = %.2f\n', x_mean_mm, y_mean_mm);
else
    warning('无有效激光点！');
    x_mean_mm = NaN; y_mean_mm = NaN;
end

% 转换为 cm（除以10）
x_mean_cm = x_mean_mm / 10;
y_mean_cm = y_mean_mm / 10;
fprintf('输出平均值（cm）： x = %.2f, y = %.2f\n', x_mean_cm, y_mean_cm);

% ========== 绘图：所有坐标除以10，但标签显示为 mm ==========
x_plot = x_filtered / 10;
y_plot = y_filtered / 10;
CVsyst_x_plot  = CVsyst_x  / 10;
CVsyst_y_plot  = CVsyst_y  / 10;
CVsyst_x1_plot = CVsyst_x1 / 10;
CVsyst_y1_plot = CVsyst_y1 / 10;

figure;
scatter(x_plot, y_plot, 5, 'filled');
hold on;
plot(CVsyst_x_plot, CVsyst_y_plot, 'r*', 'MarkerSize', 10);
plot(CVsyst_x1_plot, CVsyst_y1_plot, 'r*', 'MarkerSize', 10);
grid on;
xlabel('X (mm)'); ylabel('Y (mm)');   % 标签写 mm，但数值实际是 cm
title('Filtered Laser Points (Main Component Kept, Units: mm)');
legend('相机成像点云', 'CV系统原点', 'Location', 'best');
axis equal;
hold off;

% 输出平均值（单位 cm）
output = [x_mean_cm, y_mean_cm];

end

% ========== 附录：若无 dbscan 函数，请使用以下自定义连通分量代码替换上面的聚类部分 ==========
% （将上面的 dbscan 部分整段替换为下面的代码）

%{
    % 自定义连通分量提取（不依赖任何工具箱）
    distThreshold = 10;
    nPoints = size(points, 1);
    visited = false(nPoints, 1);
    clusters = {};
    for i = 1:nPoints
        if ~visited(i)
            queue = i;
            visited(i) = true;
            cluster = [];
            while ~isempty(queue)
                idx = queue(1);
                queue(1) = [];
                cluster = [cluster; idx];
                for j = 1:nPoints
                    if ~visited(j)
                        dist = sqrt((points(idx,1)-points(j,1))^2 + (points(idx,2)-points(j,2))^2);
                        if dist <= distThreshold
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
    [~, maxIdx] = max(sizes);
    mainCluster = clusters{maxIdx};
    x_filtered = points(mainCluster, 1);
    y_filtered = points(mainCluster, 2);
%}