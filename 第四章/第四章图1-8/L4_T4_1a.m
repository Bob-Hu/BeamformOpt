 %%���������в����Ż������Ӧ��
 %%20170818
 %%myuzhao@163.com
 %%���ִ��������ȼ�Ȩ�Ա�
 %%���ȼ�Ȩ ���Ҽ�Ȩ hanning hamming 
 
clc;
clear ;
close all;

%ɨ����㷶Χ
freq =1000;  %�ź�Ƶ��
f=freq;
c0 = 344;
lamd=c0/freq;


% %��Ԫλ��
element_num=10;
d_lamda=1/2;%��Ԫ���d�벨��lamda�Ĺ�ϵ
d=d_lamda*c0/f*[0:1:element_num-1];
%%ɨ���������
theta0=0*pi/180;
theta1=linspace(-90,90,180);
theta=theta1*pi/180;
 
p=zeros(length(theta),1);
%%
wp=exp(1i*2*pi*f*d'*sin(theta0)/c0)/element_num;
ap=exp(1i*2*pi*f*d'*sin(theta)/c0);   
p=wp'*ap;
energy_cbf_P=20*log10(abs(p));
figure(1)
hold on
plot(theta1,energy_cbf_P,'k-.')
xlabel('��λ/(^o)')
ylabel('���ȼ�Ȩ����/dB')
ylim([-60 3])
grid on
%%cossin��Ȩ
m=1:1:element_num;
w_cos=cos(pi*(m-(element_num+1)/2)/element_num);
w_cos=w_cos.'/sum(w_cos);
wp=w_cos.*exp(1i*2*pi*d_lamda*[0:element_num-1]'*sin(theta0));
ap=exp(1i*2*pi*d_lamda*[0:element_num-1]'*sin(theta));   
p=wp'*ap;
energy_cbf_cos_P=20*log10(abs(p));
figure(1)
plot(theta1,energy_cbf_cos_P,'b.')
xlabel('��λ/(^o)')
ylabel('cos��Ȩ����/dB')
ylim([-60 3])
grid on
%%hanning��Ȩ
w_hanning=hanning(element_num)
w_hanning=w_hanning/sum(w_hanning);
wp=w_hanning.*exp(1i*2*pi*d_lamda*[0:element_num-1]'*sin(theta0));
wp=w_cos.*exp(1i*2*pi*d_lamda*[0:element_num-1]'*sin(theta0));
ap=exp(1i*2*pi*d_lamda*[0:element_num-1]'*sin(theta));   
p=wp'*ap;
energy_cbf_hanning_P=20*log10(abs(p));
figure(1)
plot(theta1,energy_cbf_hanning_P,'r--')
xlabel('��λ/(^o)')
ylabel('hanning��Ȩ����/dB')
ylim([-60 3])
grid on
%%hamming��Ȩ
w_hamming=hamming(element_num)
w_hamming=w_hamming/sum(w_hamming);
wp=w_hamming.*exp(1i*2*pi*d_lamda*[0:element_num-1]'*sin(theta0));
ap=exp(1i*2*pi*d_lamda*[0:element_num-1]'*sin(theta));   
p=wp'*ap;
energy_cbf_hamming_P=20*log10(abs(p));
figure(1)
plot(theta1,energy_cbf_hamming_P,'g-')
xlabel('��λ/(^o)')
ylabel('hamming��Ȩ����/dB')
ylim([-60 3])
grid on

legend('uniform','cossin','hanning','hamming')