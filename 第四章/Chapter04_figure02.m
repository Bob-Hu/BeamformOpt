%%���������в����Ż������Ӧ��
 %%20170818
 %%myuzhao@163.com
 %%DC��Ȩ�ڱ�׼�������е�Ӧ��
 %%ָ��������
clc;
clear ;
close all;
% %��Ԫλ��
M = 10;
d_lamda = 1/2;%��Ԫ���d�벨��lamda�Ĺ�ϵ
%%��������
angle0 = 0;
angle = linspace(-90,90,10000);
%%DC
sll=[];
type=1;
  as = exp(-1i*pi*[0:M-1]'*sind(angle0));
for angle11 = [asin(2/M) asin(3/M) asin(4/M)]
    w_dc = DC_win(angle11,sll,d_lamda,M,type);
    w_dc = w_dc/sum(w_dc);
    w = w_dc.*exp(-1i*pi*[0:M-1]'*sind(angle));   
    p = w'*as;
    enegry_cbf = 20*log10(abs(p));
    figure(1)
    hold on
    plot(angle,enegry_cbf,'.')
end
legend('sin=2/M','sin=3/M','sin=4/M')
ylabel('DC��Ȩ����/dB')
xlabel('��λ/(^o)')
set(gca,'fontsize',16)
ylim([-80 3])
grid on
