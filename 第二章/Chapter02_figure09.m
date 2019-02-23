 %%���������в����Ż������Ӧ��
 %%20170815
 %%myuzhao
 %%
clc;
clear ;
close all;

%ɨ����㷶Χ
freq = 1000;  %�ź�Ƶ��
fs = 10000; % ����Ƶ��
c0 = 344;
snaps = 500;

% %��Ԫλ��
M = 10;
d_lamda = 1/2;%��Ԫ���d�벨��lamda�Ĺ�ϵ
d = d_lamda*c0/freq*[0:1:M-1];
%%ɨ���������
angle0 = 10;
angle = linspace(-90,90,10000);

a0 = exp(-1i*2*pi*freq*d'*sind(angle0)/c0)/M;
w = exp(-1i*2*pi*freq*d'*sind(angle)/c0);   
p = w'*a0;

energy_cbf_P=20*log10(abs(p));
figure
plot(angle,energy_cbf_P)
xlabel('��λ/(^o)')
ylabel('����/dB')
ylim([-70 3])
grid on
title('����ͼ')

%%���ź�ʱ����ɨ�跽λ��
snr = 0;
s = 10^(snr/20)*exp(-1i*2*pi*freq*[1/fs:1/fs:snaps/fs]);
as = exp(-1i*2*pi*freq*d'*sind(angle0)/c0)*s;
R = as*as'/snaps;
w = exp(1i*2*pi*freq*d'*sind(angle)/c0)/M;   
p = diag(w'*R*w);
energy_cbf_P = 10*log10(abs(p));
figure
plot(angle,energy_cbf_P)
xlabel('��λ/(^o)')
ylabel('����/dB')
ylim([-70 3])
grid on
title('���ź�ʱ����ɨ�跽λ��')

%%SNR=30dB�����ʱ����ɨ�跽λ��
snr = 30;
s = 10^(snr/20)*exp(-1i*2*pi*freq*[1/fs:1/fs:snaps/fs]);
as = exp(-1i*2*pi*freq*d'*sind(angle0)/c0)*s;
noise = 1/sqrt(2)*(randn(M,snaps)+1i*randn(M,snaps));

as = as + noise;
R = as*as'/snaps;
w = exp(1i*2*pi*freq*d'*sind(angle)/c0)/M;  
p= diag(w'*R*w);
energy_cbf_P=10*log10(abs(p));
figure
plot(angle,energy_cbf_P)
xlabel('��λ/(^o)')
ylabel('����/dB')
ylim([-10 33])
grid on
title('SNR=30dBʱ����ɨ�跽λ��')


%%��ͬ��λʱ���������� 10*logM
a0 = exp(1i*2*pi*freq*d'*sind(angle0)/c0);
pn = eye(10,10);
w = exp(1i*2*pi*freq*d'*sind(angle)/c0);
pn = diag(w'*pn*w);
ps = diag((w'*a0)*(w'*a0)');
G = abs(ps./pn);
G_dB = 10*log10(G);
figure
plot(angle,G_dB)
xlabel('��λ/(^o)')
ylabel('������/dB')
title('��ͬ��λʱ����������')
ylim([-50 13])
grid on