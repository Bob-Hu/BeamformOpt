%%���������в����Ż������Ӧ��
 %%20170815
 %%myuzhao
 %%������
clc;
clear;
close all;

%ɨ����㷶Χ
freq = 1000;  %�ź�0Ƶ��
fs = 10000; % ����Ƶ��
c0 = 344;
snaps = 500;

% %��Ԫλ��
M = 10;
d_lamda = 1/2;%��Ԫ���d�벨��lamda�Ĺ�ϵ
d = d_lamda * c0/freq * [0:1:M-1];
%%ɨ���������
angle0 = 10;
snr = 30;
angle = linspace(-90,90,10000);
 
noise = 1/sqrt(2)*(randn(M,snaps)+1i*randn(M,snaps));
s1 = 10^(snr/20)*exp(1i*2*pi*freq*[1/fs:1/fs:snaps/fs]);
as = exp(1i*2*pi*freq*d'*sind(angle0)/c0)*s1; 

as = as+noise;
R = as*as'/snaps;


%%%%%%%%%%%%%%%%%%%%%%%%%��������-10��%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
angle1 = -10;
as1 = exp(1i*2*pi*freq*d'*sind(angle1)/c0);%��������
iR = inv(R);
w = iR*as1/(as1'*iR*as1);
as = exp(1i*2*pi*freq*d'*sind(angle)/c0);   
p = as'*w;
energy_mvdr_P1 = 20*log10(abs(p));

as = exp(1i*2*pi*freq*d'*sind(angle)/c0); 
as1 = exp(1i*2*pi*freq*d'*sind(angle1)/c0);%��������
error = sqrt(2)*(sqrt(0.1)*rand(M,1) + 1i*sqrt(0.1)*rand(M,1));
as1 = as1 + error;
w = iR*as1/(as1'*iR*as1);
p = as'*w;
energy_mvdr_P2 = 20*log10(abs(p));


figure
plot(angle,energy_mvdr_P1,'b--',angle,energy_mvdr_P2,'k-')
xlabel('��λ/(^o)')
ylabel('����/dB')
ylim([-100 30])
grid on
% legend()

%%%%%%%%%%%%%%%%%%%%%%%%%��������10��%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
angle1 = 10;
as1 = exp(1i*2*pi*freq*d'*sind(angle1)/c0);%��������
iR = inv(R);
w = iR*as1/(as1'*iR*as1);
as = exp(1i*2*pi*freq*d'*sind(angle)/c0);   
p = as'*w;
energy_mvdr_P1 = 20*log10(abs(p));

as = exp(1i*2*pi*freq*d'*sind(angle)/c0); 
as1 = exp(1i*2*pi*freq*d'*sind(angle1)/c0);%��������
error = sqrt(2)*(sqrt(0.1)*rand(M,1) + 1i*sqrt(0.1)*rand(M,1));
as1 = as1 + error;
w = iR*as1/(as1'*iR*as1);
p = as'*w;
energy_mvdr_P2 = 20*log10(abs(p));


figure
plot(angle,energy_mvdr_P1,'b--',angle,energy_mvdr_P2,'k-')
xlabel('��λ/(^o)')
ylabel('����/dB')
ylim([-100 30])
grid on

% % % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%��λ��%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % %%MVDR
% % % iR=inv(R);
% % % as = exp(1i*2*pi*freq*d'*sind(angle)/c0);   
% % % p_mvdr = diag(1./abs(as'*iR*as));
% % % energy_mvdr_P1 = 10*log10(abs(p_mvdr));
% % % 
% % % iR=inv(R);
% % % as = exp(1i*2*pi*freq*d'*sind(angle)/c0) + error;   
% % % p_mvdr = diag(1./abs(as'*iR*as));
% % % energy_mvdr_P2 = 10*log10(abs(p_mvdr));
% % % 
% % % figure
% % % plot(10,30,'bo')
% % % hold on
% % % plot(angle,energy_mvdr_P1,'b--',angle,energy_mvdr_P2,'k-')
% % % xlabel('��λ/(^o)')
% % % ylabel('����/dB')
% % % ylim([-20 40])
% % % grid on
% % % legend('��ʵ�ź�','��λ��')
