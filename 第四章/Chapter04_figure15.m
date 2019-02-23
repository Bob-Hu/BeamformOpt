%%���������в����Ż������Ӧ��
 %%20170829
 %%myuzhao
 %%SOCP-MSL ���� Dolph-Chebychev ������ͼ�Ա�
clc;
clear ;
close all;

% %��Ԫλ��
M = 10;
d_lamda=1/2;%��Ԫ���d�벨��lamda�Ĺ�ϵ

%%��������
angle0=0;
angle = linspace(-90,90,10000);
p=zeros(length(angle),1);
%%DC
angle11 = asin(2/M);
sll = -30;
d_lamda = 1/2;
type=2;
w_dc = DC_win(angle11,sll,d_lamda,M,type);
w_dc = w_dc/sum(w_dc);
w = w_dc.*exp(-1i*pi*(0:M-1)'*sind(angle));
as0 = exp(-1i*pi*(0:M-1)'*sind(angle0));   
p = w'*as0;
enegry_cbf = 20*log10(abs(p));
figure(1)
hold on
plot(angle,enegry_cbf,'r.')
xlabel('��λ/(^o)')
ylabel('����/dB')
ylim([-60 3])
grid on
% 
index_temp_r=find(angle<16.46);
index_temp_l=find(angle>-16.46);

angle2=[angle(1:index_temp_l(1)-20) angle(index_temp_r(end)+20:end)];
as0 = exp(-1i*pi*[0:M-1]'*sind(angle0));
as = exp(-1i*pi*[0:M-1]'*sind(angle2));
cvx_begin quiet%%����̶�����DC��Ȩ�õ�����С���԰�
    variable ww(M) complex
    variable s(1)
    minimize(s)
    subject to
         ww'*as0==1;
         abs(ww'*as)<=s;
cvx_end

as = exp(-1i*pi*(0:M-1)'*sind(angle));
energy_cvx = 20*log10(abs(ww'*as));
figure(1)
hold on
plot(angle,energy_cvx,'b-')
xlabel('��λ/(^o)')
ylabel('����/dB')
ylim([-60 3])
legend('Chebychev','SOCP-MSL')


%%d=1/4��
angle11 = asin(2/M);
sll=-30;
d_lamda=1/4;%��Ԫ���d�벨��lamda�Ĺ�ϵ
type=2;
w_dc = DC_win(angle11,sll,d_lamda,M,type);
w_dc = w_dc/sum(w_dc);
w = w_dc.*exp(1i*2*pi*d_lamda*(0:M-1)'*sind(angle0));
as = exp(-1i*2*pi*d_lamda*(0:M-1)'*sind(angle));   
p = w'*as;
enegry_cbf = 20*log10(abs(p));
figure(2)
hold on
plot(angle,enegry_cbf,'r.')
xlabel('��λ/(^o)')
ylabel('����/dB')
ylim([-60 3])
grid on
% 
index_temp_r=find(angle<35.54);
index_temp_l=find(angle>-35.54);

angle2=[angle(1:index_temp_l(1)-20) angle(index_temp_r(end)+20:end)];
as0 = exp(-1i*2*pi*d_lamda*(0:M-1)'*sind(angle0));
as = exp(-1i*2*pi*d_lamda*(0:M-1)'*sind(angle2));
cvx_begin quiet%%����̶�����DC��Ȩ�õ�����С���԰�
    variable ww(M) complex
    variable s(1)  
    minimize(s)
    subject to
         ww'*as0==1;
         abs(ww'*as)<=s;
cvx_end

as = exp(-1i*2*pi*d_lamda*(0:M-1)'*sind(angle));
energy_cvx = 20*log10(abs(ww'*as));
figure(2)
hold on
plot(angle,energy_cvx,'b-')
xlabel('��λ/(^o)')
ylabel('����/dB')
ylim([-60 3])
legend('Chebychev','SOCP-MSL')
