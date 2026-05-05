%% gen_gauss_mono_show.m
% 生成并显示单目高斯噪声图像（σ² = 0.01:0.01:0.05）
clear; close all;

if ~exist('pos1_orig_left.png','file')
    error('未找到 pos1_orig_left.png，请先保存原始左相机图像。');
end

I = imread('pos1_orig_left.png');
gauss_var = 0.01:0.01:0.05;

for idx = 1:length(gauss_var)
    s2 = gauss_var(idx);
    noisy = imnoise(I, 'gaussian', 0, s2);
    
    % 保存文件
    filename = sprintf('pos1_gauss_%.2f_left.png', s2);
    imwrite(noisy, filename);
    
    % 显示噪声图像
    figure;
    imshow(noisy);
    title(sprintf('高斯噪声方差 σ² = %.2f', s2));
end

fprintf('已生成并显示 %d 张单目高斯噪声图像。\n', length(gauss_var));