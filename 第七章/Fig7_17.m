%%%% 例7.7 Eq.(7.45)
clear all; clc
close all

M = 12;                   % 阵元数
f0 = 2000; c = 1500;
fL = f0/2; fU = f0;              % 期望频率
fM = (fL + fU)/2;                % 参考频率
fs = 3.125*f0; Ts = 1/fs;
lambda = c/f0;
d = lambda/2;
d_lambda = 1/2;
angle_radian = 1/180*pi;            % 角度转换为弧度
theta_s = 10*angle_radian;
delta0 = 2*angle_radian;

%---- 拟合波束 对应于频率 f0/2~f0 -------%
theta_wl = -pi/2:delta0:pi/2;
theta_ml = [(-8*angle_radian) : delta0 : (28*angle_radian)];
theta_sl = [-pi/2:delta0:(-12*angle_radian), (32*angle_radian):delta0:pi/2];

L = 15;               % 滤波器长度
tau_s  = (0:M-1)'*d*sin(theta_s)/c;
tau_ml = (0:M-1)'*d*sin(theta_ml)/c;
tau_sl = (0:M-1)'*d*sin(theta_sl)/c;
tau_wl = (0:M-1)'*d*sin(theta_wl)/c;
T = -round(tau_s/Ts + (L-1)/2) * Ts;

%----- 式(7.10) -----%
deltaf = 0.005;                     % 离散化频率间隔
PB = 0.16 : deltaf : 0.32;      % 通带带宽 其中 0.16 = fL/fs；0.32 = fU/fs；
WB =  0 : deltaf : 0.5;                            % 全部带宽
e_PB = exp(-1i*2*pi*(0:L-1)'*PB);  
e_WB = exp(-1i*2*pi*(0:L-1)'*WB);

K_PB = exp(-1i*2*pi*T*PB*fs);
K_WB = exp(-1i*2*pi*T*WB*fs);

%----- 利用yalmip求解 L2范数 -----%
y = sdpvar(1);
h = sdpvar(M*L,1,'full','real');

%----- 无失真约束 -------  %
U_S = zeros(M,L);
for m = 1 : M
    for LL = 1 : L
        U_S(m,LL)    = exp(-1i*2*pi*fM*(T(m,1)+tau_s(m,1)+(LL-1)*Ts));
    end
end
u_S = reshape(U_S,numel(U_S),1);
constraint_S = set(  u_S.'*h == 1 );

%----- PB + ML -------  %
for pb = 1 : length(PB)
    for ml = 1: length(theta_ml)
        U_PBML = zeros(M,L);
        U_D    = zeros(M,L);
        for m = 1 : M
            for LL = 1 : L
                U_PBML(m,LL) = exp(-1i*2*pi*PB(1,pb)*fs*(T(m,1)+tau_ml(m,ml)+(LL-1)*Ts));
                U_D(m,LL)    = exp(-1i*2*pi*fM*(T(m,1)+tau_ml(m,ml)+(LL-1)*Ts));
            end
        end
        u_PBML = reshape(U_PBML,numel(U_PBML),1);
        u_D    = reshape(U_D,numel(U_D),1);
        if pb ==1 && ml ==1
            constraint_PBML = set( cone( (u_PBML - u_D).'*h,y ) );
        else
            constraint_PBML = constraint_PBML + set( cone( (u_PBML - u_D).'*h,y ) );
        end
    end
end

%----- PB + SL -------  %  
delta_PBSL = 10^(-30/20);
for pb = 1 : length(PB)
    for sl = 1: length(theta_sl)
        U_PBSL = zeros(M,L);
        for m = 1 : M
            for LL = 1 : L
                U_PBSL(m,LL) = exp(-1i*2*pi*PB(1,pb)*fs*(T(m,1)+tau_sl(m,sl)+(LL-1)*Ts));
            end
        end
        u_PBSL = reshape(U_PBSL,numel(U_PBSL),1);
        if pb ==1 && sl ==1
            constraint_PBSL = set( cone( u_PBSL.'*h, delta_PBSL ) );
        else
            constraint_PBSL = constraint_PBSL + set( cone( u_PBSL.'*h, delta_PBSL ) );
        end
    end
end

constraint_h = set(cone(h,0.5));

constraints = constraint_S + constraint_PBML + constraint_PBSL;% + constraint_h + constraint_TBSL + constraint_SBWL
obj = y; 
solvesdp(constraints,obj);
h_opt = double(h);
y_opt = 20*log10(double(y));
%----- 利用yalmip求解 -----%

%----- 式(7.10) -----%
p_PB = zeros(length(PB),length(theta_wl));
pdB_PB = zeros(length(PB),length(theta_wl));
figure; hold on
for pb = 1 : length(PB)
    for wl = 1: length(theta_wl)
        U = zeros(M,L);
        for m = 1 : M
            for LL = 1 : L
                U(m,LL) = exp(-1i*2*pi*PB(1,pb)*fs*(T(m,1)+tau_wl(m,wl)+(LL-1)*Ts));
            end
        end
        u = reshape(U,numel(U),1);  
        p_PB(pb,wl) = u.' * h_opt;
        pdB_PB(pb,wl) = 20*log10(abs(p_PB(pb,wl)));
    end
    plot(theta_wl/angle_radian,pdB_PB(pb,:),'b','linewidth',1.0)
    axis([-90 90 -60 0])
    grid on        
end
figure; 
mesh(theta_wl/angle_radian,PB,pdB_PB)
zlim([-60 0])           
  
