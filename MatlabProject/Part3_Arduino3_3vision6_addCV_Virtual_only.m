%clear
%clc;

%close all;
name = "Matlab";
% ��ȷ���﷨
name = 'Client1';  % ������������name����
Client = tcpclient('127.0.0.1', 55019);
%arduino=serialport("COM9",1000000);%只需要运�?1次，连接端口
%arduino1=serialport("COM12",115200);%只需要运�?1次，连接端口color1 = readline(arduino1);

%传输图像unity
%fig= capture_fig(Client);

%grabSend(arduino,"a");%手臂到达初始位置
%pause(3);

gripping_point = 0.056;

%gripping_point = 0.1978;






joints = [0.12 0 0 0 0 0];            %指定的关节角


%while(1)%�?始循�?

%识别颜色
%grabSend(arduino,"g");
%pause(3);%并在arduino中添加一个对应函数，让g命令颜色传感器工�?
%color1 = readline(arduino);%读取传输到的色彩信息，真实颜�?
%color1 = str2double(color1);%1黑色�?2白色�?3红色�?4绿色�?5蓝色�?6黄色
%disp(color1);


%if(color1~=2)%&&color1~=empty)

 %color = color_check(Client); % function for detecting colors


%robot.plot(joints);
%方块位置
%Grab = 2; % activate EE (0 - release the object, 1 - grab, 2 - do nothing)
%t = 0:0.1:6;
%X1 = 0.04;  % Z
%Y1 = 0.135; % -X
%Z1 = -0.005;  % Y - GREEN
% Z1 = 3.5/100; % - RED
% Z1 = 5.5/100; % - BLUE

%通过鱼眼摄像头计算方块的位置
Loc=CVsystem7_1(Client);%CVsystem平均值算法，CVsystem2取最小�?�算�?,CVsystem3平均值算法加姿�?�调整，CVsystem4寻找中心点算法加姿�?�调�?
pot=PositionTran(Loc(1),Loc(2));
t = 0:0.1:6;
X1 = pot(1,1)/100;  % Z
Y1 = pot(2,1)/100; % -X
Z1 = -0.01;  % Y - GREEN

