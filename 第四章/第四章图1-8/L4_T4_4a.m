%%���������в����Ż������Ӧ��
 %%20170818
 %%myuzhao@163.com
 %%DC��Ȩ�ڱ�׼�������е�Ӧ��
 %%ָ���԰꼶,��0����
clc;
clear ;
close all;

%ɨ����㷶Χ
freq =1000;  %�ź�Ƶ��
c0 = 344;
lamd=c0/freq;

% %��Ԫλ��
element_num=10;
d_lamda=1/2;%��Ԫ���d�벨��lamda�Ĺ�ϵ

%%ɨ���������
theta0=-10*pi/180;
theta1=linspace(-90,90,10000);
theta=theta1*pi/180;
 
p=zeros(length(theta),1);
%%DC
M=element_num;
theta11=asin(2/M);
sll=-20;
lamd=c0/freq;
M=10;
d=1/2*lamd;
type=2;
w_dc=DC_win(theta11,sll,d,M,lamd,type)
w_dc=w_dc/sum(w_dc);
wp=w_dc.*exp(1i*2*pi*d_lamda*[0:element_num-1]'*sin(theta0))
ap=exp(1i*2*pi*d_lamda*[0:element_num-1]'*sin(theta));   
p=wp'*ap;
energy_cbf_P=20*log10(abs(p));
figure(1)
hold on
plot(theta1,energy_cbf_P,'.')
xlabel('��λ/(^o)')
ylabel('DC��Ȩ����/dB')
ylim([-60 3])
grid on

sll=-30;
w_dc=DC_win(theta11,sll,d,M,lamd,type)
w_dc=w_dc/sum(w_dc);
wp=w_dc.*exp(1i*2*pi*d_lamda*[0:element_num-1]'*sin(theta0))
ap=exp(1i*2*pi*d_lamda*[0:element_num-1]'*sin(theta));   
p=wp'*ap;
energy_cbf_P=20*log10(abs(p));
figure(1)
hold on
plot(theta1,energy_cbf_P,'--')
xlabel('��λ/(^o)')
ylabel('DC��Ȩ����/dB')
ylim([-60 3])
grid on


sll=-40;
w_dc=DC_win(theta11,sll,d,M,lamd,type)
w_dc=w_dc/sum(w_dc);
wp=w_dc.*exp(1i*2*pi*d_lamda*[0:element_num-1]'*sin(theta0))
ap=exp(1i*2*pi*d_lamda*[0:element_num-1]'*sin(theta));   
p=wp'*ap;
energy_cbf_P=20*log10(abs(p));
figure(1)
hold on
plot(theta1,energy_cbf_P,'-')
xlabel('��λ/(^o)')
ylabel('DC��Ȩ����/dB')
ylim([-60 3])
grid on

legend('sll=-20dB','sll=-30dB','sll=-40dB')
title('���㷽��ͬ�԰�DC��Ȩ�Ա�')