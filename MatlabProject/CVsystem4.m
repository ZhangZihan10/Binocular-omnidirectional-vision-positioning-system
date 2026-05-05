%平均值算�?
function output=CVsystem4(a)
% Laser Segmentation
%name = "Matlab";
%Client = TCPInit('127.0.0.1',55012,name);
Client=a;
image =ImageReadTCP_One(Client,'Center'); %image=imread('image.png');
image1 = ImageReadTCP_One1(Client,'Center');%image1=imread('image1.png');
%img = las_segm(image);
%img1 = las_segm(image1);
%image = imread('image1.jpg');
%image1 = imread('image2.jpg');
%img = LaserFind(image);
%img1 = LaserFind(image1);
img = las_segm(image);
img1 = las_segm(image1);
% Configuration
load('Omni_Calib_Results_Unity.mat'); % Calib parameters
ocam_model = calib_data.ocam_model; % Calib parameters
camX =0;%-2.5; % Camera parameters
camY =0;%6; % Camera parameters
camZ =0;% 3; % Camera parameters
lasX = 0;%1.5; % Laser Plane parameters
lasY = 0;%-2.5; % Laser Plane parameters
las_dist = 1950; % Laser Plane parameters
CVsyst_x = -1700; % CV System initial position 在unity中为CVSystemOrigin的位置参数z*1000
CVsyst_y =-800; % CV System initial position 在unity中为CVSystemOrigin的位置参数x*-1000
CVsyst_rot = 0; % CV System initial rotation
CVsyst_x1 = 2500; % CV System second position 在unity中为CVSystemOrigin2的位置参数z*1000
CVsyst_y1 = 4500; % CV System second position 在unity中为CVSystemOrigin2的位置参数x*-1000
CVsyst_rot1 = 0;%20; % CV System second rotation 在unity中为CVSystemOrigin2的位置参数Rotation Y
% Mapping
[x,y] = mapping(img,CVsyst_rot,CVsyst_x,CVsyst_y,camX,camY,camZ,lasX,lasY,...
    las_dist,ocam_model); % mapping function
[x1,y1] = mapping(img1,CVsyst_rot1,CVsyst_x1,CVsyst_y1,camX,camY,camZ,lasX,...
    lasY,las_dist,ocam_model); % mapping function
% Finally figure:
figure;
scatter(x,y,5,'filled'); % Laser intersections, first image
hold on;
plot(CVsyst_x,CVsyst_y,'r*'); % CV System location, first image
scatter(x1,y1,5,'filled'); % Laser intersections, second image
plot(CVsyst_x1,CVsyst_y1,'r*'); % CV System location, second image
grid on;
combinedVector1 = [x, x1];
combinedVector2 = [y, y1];
combinedVector1 = nonzeros(combinedVector1);
combinedVector2 = nonzeros(combinedVector2);

combinedVector1(combinedVector1==CVsyst_x1)=[];
combinedVector2(combinedVector2==CVsyst_y1)=[];%去除向量内的原点坐标，减少干�?
combinedVector1(combinedVector1==CVsyst_x)=[];
combinedVector2(combinedVector2==CVsyst_y)=[];%去除向量内的原点坐标，减少干�?

%将激光矫正数据还原成图片
Toimage1(combinedVector1,combinedVector2);

%x2=mean(combinedVector1);
%y2=mean(combinedVector2);

%x2=(max(combinedVector1)+min(combinedVector1))/2;
%y2=(max(combinedVector2)+min(combinedVector2))/2;

%寻找偏移角度
[Y1max,Y1maxRow]=max(combinedVector2);%寻找y�?大�??
X1value = combinedVector1(Y1maxRow);
[X3max,X3Row]=max(combinedVector1);%寻找x�?大�??
Y3value = combinedVector2(X3Row);
[X2min,X2Row]=min(combinedVector1);%寻找x�?小�??
Y2value = combinedVector2(X2Row);
[Y4min,Y4minRow]=min(combinedVector2);%寻找y�?小�??
X4value = combinedVector1(Y4minRow);
%寻找立方体中心点
L1=sqrt((X1value-X4value)^2+(Y1max-Y4min)^2);
L2=sqrt((X1value-X3max)^2+(Y1max-Y3value)^2);
L3=sqrt((X3max-X4value)^2+(Y3value-Y4min)^2);
thetha1=acosd((L1^2+L2^2-L3^2)/(2*L1*L2));
thetha2=thetha1-atan2d(X3max-X1value,Y1max-Y3value);%立方体中心点与y1点的偏角


output=[x;y];
end