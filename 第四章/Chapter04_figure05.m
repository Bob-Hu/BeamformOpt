%%���������в����Ż������Ӧ��
 %%20170818
 %%myuzhao@163.com
 %%���ڵ�����ʱ��MVDR����ͼ �����������Ļ���
clc;
clear;
close all;

%ɨ����㷶Χ
snaps = 5000;

% %��Ԫλ��
M = 10;
%%ɨ���������
angle0 = 0;%���᷽��
angle1 = -30;%���ŷ���
angle = linspace(-90,90,18000);
format = ['k.';'r-';'b-'];
inr = [-10 0 10]; 
noise = 1/sqrt(2)*(randn(M,snaps)+1i*randn(M,snaps));
fs = 10000;
f = 1000;
for i=1:3
    inr1 = inr(i);%�����
    s1 = 10^(inr1/20)*randn(1,snaps);
    ap = exp(-1i*pi*(0:1:M-1)'*sind(angle1)); 
    apis = ap*s1;  %%%���н��ո����ź�

    apisn = apis + noise;
    Rin = apisn*apisn'/snaps;
    iRin = inv(Rin);
    
    as0 = exp(-1i*pi*(0:1:M-1)'*sind(angle0))
    w0 = iRin*as0/(as0'*iRin*as0);  
    as = exp(-1i*pi*(0:1:M-1)'*sind(angle));
    p = as'*w0;
    enegry_mvdr = 20*log10(abs(p));
    figure(1)
    hold on
    plot(angle,enegry_mvdr,format(i))
end
figure(1)
xlabel('��λ/(^o)')
ylabel('����/dB')
ylim([-60 3])
grid on
title('���ڵ�����ʱ��MVDR����ͼ')
legend('INR=-10dB','INR=0dB','INR=10dB')
% Create arrow
annotation('arrow',[0.401785714285714 0.401785714285714],...
    [0.854761904761905 0.65]);
