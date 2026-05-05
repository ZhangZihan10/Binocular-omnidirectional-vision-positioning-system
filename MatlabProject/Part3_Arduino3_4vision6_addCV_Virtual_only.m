%clear
%clc;

%close all;
name = "Matlab";
Client = TCPInit('127.0.0.1',55019,name);
%arduino=serialport("COM9",1000000);%只需要运�?1次，连接端口
%arduino1=serialport("COM12",115200);%只需要运�?1次，连接端口color1 = readline(arduino1);

%传输图像unity
%fig= capture_fig(Client);

%grabSend(arduino,"a");%手臂到达初始位置
%pause(3);



%通过鱼眼摄像头计算方块的位置
Loc=CVsystem4(Client);%CVsystem平均值算法，CVsystem2取最小�?�算�?,CVsystem3平均值算法加姿�?�调整，CVsystem4寻找中心点算法加姿�?�调�?
pot=PositionTran(Loc(1),Loc(2));
t = 0:0.1:6;
X1 = pot(1,1)/100;  % Z
Y1 = pot(2,1)/100; % -X
Z1 = -0.01;  % Y - GREEN

T = transl(X1, Y1, Z1)* trotz(180);%根据给定终点，得到终点位�?
qi1 = robot.ikine(T,'mask',[1 1 1 1 0 0]);%根据终点点位姿，得到终点关节�?
qf1 = [0.12 0 0 0 0 0];%机器人初始位�?

qi1(1,4)=qi1(1,2)+qi1(1,3)+Loc(3)*pi/180;%添加抓取点末端位姿，加入了姿态调�?

q = jtraj(qf1,qi1,t);%五次多项式轨迹，得到关节角度，角速度，角加�?�度�?50为采样点个数

%qq=q(61,3)-q(1,3);%�?要旋转的角度
%robot.plot(q);

%numberTran(arduino,q(61,1),q(61,2),q(61,3));%将计算结果转换为电机参数,并传入arduino

%robot.plot(q);传输到unity
b = 1;
for a = 1 : length(q)
    func_data(Client, q, b);
    b=b+1;     
end

pause(4);


% take object
%grabSend(arduino,"c");

% take object
Grab = 1;
func_grab(Client, Grab);
func_data(Client,q,b-1);
pause(2);


%将方块移动到摄像头上
%X3 = 0.03;  % Z
%Y3 = -0.095; % -X
%Z3 = 0.015;  % Y 
%T3 = transl(X3, Y3, Z3)* trotz(180);%根据给定终点，得到终点位�?
%qf3 = robot.ikine(T3,'mask',[1 1 1 1 0 0]);
%将方块移动到自己上方
X3 = X1;%0.04;  % Z
Y3 =Y1;% 0.135; % -X
Z3 = 0.03;  % Y - GREEN
T3 = transl(X3, Y3, Z3)* trotz(180);%根据给定终点，得到终点位�?
qf3 = robot.ikine(T3,'mask',[1 1 1 1 0 0]);

qf3(1,4)=qf3(1,2)+qf3(1,3);%末端姿�??
q = jtraj(qi1,qf3,t);


%robot.plot(q);

%numberTran(arduino,q(61,1),q(61,2),q(61,3));%将计算结果转换为电机参数,并传入arduino

%robot.plot(q);%传输到unity�?
b = 1;
for a = 1 : length(q)
    func_data(Client, q, b); 
    b=b+1;
end
pause(4);



 color1=4;   
    if color1 == 3 % Red sorting
        X2 = 0.21;  % Z
        Y2 = -0.08; % -X
        Z2 = -0.001;  % Y
    elseif color1 == 4 % Green sorting
        X2 = 0.21;  % Z
        Y2 = 0.08; % -X
        Z2 = -0.001;  % Y
    elseif color1 == 5 % Blue sorting
        X2 = 0.21; % Z
        Y2 = 0.001; % -X
        Z2 =-0.001; % Y 
    elseif color1 == 6 % yellow sorting
        X2 = 0.15; % Z
        Y2 = 0.07; % -X
        Z2 =-0.001; % Y

    elseif color1 == 1 % black sorting
        X2 = 0.15; % Z
        Y2 = -0.08; % -X
        Z2 =-0.001; % Y
    else % white sorting
        X2 = 0.15; % Z
        Y2 = 0.001; % -X
        Z2 =-0.001; % Y
    end
    
    pause(1);

%机械手臂将蓝色方块放到指定位�?
%起点不变�?
%X2 = 8.26/100;  % Z
%Y2 = 0.85/100; % -X
%Z2 = 1.51/100;  % Y - GREEN
T2 = transl(X2, Y2, Z2)* trotz(180);%根据给定终点，得到终点位�?
qi2 = robot.ikine(T2,'mask',[1 1 1 1 0 0]);%根据终点点位姿，
qi2(1,4)=qi2(1,2)+qi2(1,3);%末端姿�??
% 得到终点关节�?.'mask' 参数是一个掩码向量，用于指定执行逆解运动学时要�?�虑的自由度�?
% 在这里，[1 1 1 1 0 0] 表示机器人的前四个自由度（平移方向）是可用的，后两个自由度（旋转方向）是被限制的�?
%qf1 = [0.12 0 0 0 0 0];%机器人初始位�?
%q = jtraj(qf1,qi2,t);
q = jtraj(qf3,qi2,t);

%qq=q(61,3)-q(1,3);%�?要旋转的角度

%numberTran(arduino,q(61,1),q(61,2),q(61,3));%将计算结果转换为电机参数,并传入arduino

%robot.plot(q);传输到unity�?
b = 1;
for a = 1 : length(q)
    func_data(Client, q, b); 
    b=b+1;
end

pause(4);



% release object

%grabSend(arduino,"f");
% release object
grab = 0;
func_grab(Client, grab);
func_data(Client,q,b-1);

pause(1);

%back to initial pos
%grab = 2;

q = jtraj(qi2,qf1,t);
 %robot.plot(q);
%func_grab(Client, Grab);

%qq=q(61,3)-q(1,3);%�?要旋转的角度

%numberTran(arduino,q(61,1),q(61,2),q(61,3));%将计算结果转换为电机参数,并传入arduino
b = 1;
for a = 1 : length(q)
    func_data(Client, q, b); 
    b=b+1;
end

pause(4);


fprintf(1,"Disconnected from server\n");

%end

%end
