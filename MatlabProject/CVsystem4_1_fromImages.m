%% 噪声鲁棒性实验数据生成（基于论文已有结果模拟）
% 依据：论文位置1无噪声时单目误差 ~40.9 mm，双目误差 ~1.0 mm
% 趋势：随高斯噪声方差增大，误差递增，双目误差始终小于单目

clear; clc;

% 噪声水平（方差）
noise_levels = [0.01, 0.02, 0.03, 0.04, 0.05];

% 模拟的单目误差（mm）: 从45逐渐增加到65
mono_errors = [45.2, 48.5, 52.1, 56.8, 62.3];
% 模拟的双目误差（mm）: 从2.5逐渐增加到12.5
bino_errors = [2.5, 4.2, 6.5, 9.0, 12.3];

% 输出表格
fprintf('\n=== 高斯噪声鲁棒性实验结果（模拟） ===\n');
fprintf('噪声方差\t单目误差(mm)\t双目误差(mm)\n');
for i = 1:length(noise_levels)
    fprintf('%.2f\t\t%.1f\t\t%.1f\n', noise_levels(i), mono_errors(i), bino_errors(i));
end

% 绘图
figure;
plot(noise_levels, mono_errors, '-o', 'LineWidth', 1.5); hold on;
plot(noise_levels, bino_errors, '-s', 'LineWidth', 1.5);
xlabel('高斯噪声方差'); ylabel('定位误差 (mm)');
legend('单目', '双目', 'Location', 'northwest');
grid on;
title('噪声鲁棒性实验（基于论文数据模拟）');

% 输出标准差（假设重复2次，模拟微小波动）
fprintf('\n=== 含标准差的结果（模拟重复2次） ===\n');
fprintf('噪声方差\t单目误差(mm)\t\t双目误差(mm)\n');
for i = 1:length(noise_levels)
    mono_std = mono_errors(i) * 0.05;  % 模拟5%标准差
    bino_std = bino_errors(i) * 0.08;
    fprintf('%.2f\t\t%.1f±%.1f\t\t%.1f±%.1f\n', noise_levels(i), mono_errors(i), mono_std, bino_errors(i), bino_std);
end