close all;clear all;
%��Ŀ����6.1 P169
%      12Ԫ������������Ԫ���f0��Ӧ�İ벨����-30�㷽��LFM�źţ�fl=0.5*f0;fu=f0;fs=5*f0;��������γɣ���Ȩϵ�����ó��沨���γ�
%����ʲôû����1����֤�ֶβ��ظ�ʱ��Ч����2�������׹�һ��
%ע1��Figure2��������ϸ΢��𣨺��ߵڶ�������������ԣ���ԭ����12����Ԫ���յ����źŹ��첻ͬ�����д���һ��������Ԫ0��12���ź�������ʱ�������潫��Ԫ1���ɲο���
%1���ֶ���ʲôҪ��2����Щ������Ч�ģ���ôƴ��һ��3���ֶβ��ֳ���ĸĽ�4�������ٵ��dft
%% ��������
f0=50;fl=0.5*f0;fu=f0;fs=5*f0;
N=512;%LFM�ź�һ�����ڵĳ���
N1=256;%���泤��
T=1/fs*(N-1);
t0=0:1/fs:T;%����LFMһ�����ڵ���������
M=12;%��Ԫ��
theta=-30*pi/180;%�źŷ���
%% ���·LFM�ź�
m=0:M-1;%��ע1
tau=-sin(theta)/2/fu*m;   %dӦ��ȡ���Ƶ�ʵİ벨���������Ԫ��಻���£�����ʲô�����                       
c=1500;%����
d=c/2/fu;%��Ԫ���Ϊ�벨�� %c=1500;%����
                          %d=c/2/fu;%��Ԫ���Ϊ�벨��
                          %theta=10*pi/180;%�źŷ���
                          %tau=-d*sin(theta)/c*0:M-1;                       
[T0 Tau0]=meshgrid(t0,tau);
tt=T0-Tau0;
t1=tt;               %��·��ʱ����
t1(tt>T)=0;t1(tt<0)=0;%���ӳ�ǰ����ಿ������

figure(1);%����Ԫ���յĲ���
st_all=sin(2*pi*(fl+(fu-fl)/(2*T)*t1).*t1);%ÿһ����������ʾÿһ����Ԫ�����Ľ��
for i=1:12
    plot(1:512,st_all(i,1:512)/2+i)
    hold on
end
xlabel('i');ylabel('��Ԫ��m');title('����Ԫ���յĲ���');
axis([0 512 0 13]);

t(1:M,1:N1,1)=t1(1:M,1:N1);t(1:M,1:N1,2)=t1(1:M,0.5*N1+1:1.5*N1);t(1:M,1:N1,3)=t1(1:M,N1+1:N);%�źŵ��ص���Ϊ0.5
st=sin(2*pi*(fl+(fu-fl)/(2*T)*t).*t);%ÿһ����������ʾÿһ����Ԫ�����Ľ��
%% ����dft��ʽ����Ҷ�任����ÿ��Ƶ�ʽ��в����γɣ�IDFT�����ƴ��
L=256;%DFT����
l=0:L-1;%l=0:size(t,2)-1;
%k1=floor(L*fl/fs);k2=ceil(L*fu/fs);%k1С��fl�����Ƶ�ʶ�Ӧ��������k2����fu����СƵ�ʶ�Ӧ������
k1=21;k2=56;
k=k1:k2;%��ͬ��k��Ӧ��ͬ��Ƶ��
xk=zeros(M,size(k,2),3);
for i=1:3
xk(1:M,1:size(k,2),i)=st(1:M,1:size(l,2),i)*exp(-2i*pi*l.'*k/L);%��ʽ6.5��ÿ����������ʾƵ��ϵ��
end
%��ÿһ�н��в����γ�
jiao0=-30;%�����źŷ���
theta0=pi/2-jiao0*pi/180;%ת���Ƕȣ����û��ȱ�ʾ
v0=-[cos(theta0);sin(theta0)];
p0=[0:M-1;zeros(1,M)]';
fk=fs*k/L;
wc=1/M*exp(1i*2*pi/c*d*p0*v0*fk);%��������ʽ��2.69������ʽ��2.11����ʵ�ʼ�Ȩֵȡ����
                                 %ÿһ����������ʾ��ͬƵ�ʣ���fk��Ӧ���ļ�Ȩ����
                                 
k3=0:L-1;
yk1=zeros(1,size(k,2),3);yk2=zeros(1,L/2,3);yk=zeros(1,L,3);yt=zeros(1,N1,3);%����������С
for i=1:3
yk1(1,1:size(k,2),i)=sum(xk(1:M,1:size(k,2),i).*wc);%��ÿһ��Ƶ�ʽ��в����γ�
yk2(1,1:L/2,i)=[zeros(1,k1),yk1(1,1:size(k,2),i),zeros(1,L/2-1-k2)];%��û�м����Ƶ�ʽ��в���
yk(1,1:L,i)=[yk2(1,1:L/2,i),0,conj(fliplr(yk2(1,2:L/2,i)))];%Ϊ��ʹ���Ϊʵ������Ƶ�ʴ�ȡ��Ƶ�ʵĹ���
%���Խ������任��ע�ӵ�������                %  yk(1,(k1+1):(k2+1),i)=yk1(1,1:size(k,2),i);
                                           %  yk(1,(L-k2+1):(L-k1+1),i)=conj(fliplr(yk1(1,1:size(k,2),i)));
yt(1,1:N1,i)=yk(1,1:L,i)*exp(2i*pi*k3.'*l/L)/L;%IDFT
end

figure(2);%�ص���0.5ʱ��Ƶ������
plot(k1:k2,20*log10(abs(yk1(1,1:size(k,2),1))),':dk',...
                                    'LineWidth',2,...
                                 	'MarkerEdgeColor','k',...
                                    'MarkerFaceColor','k',...
                                    'MarkerSize',5);
hold on;
plot(k1:k2,20*log10(abs(yk1(1,1:size(k,2),2))),'--ob',...
                                 	'LineWidth',2,...
                                   	'MarkerEdgeColor','b',...
                                   	'MarkerFaceColor','b',...
                                 	'MarkerSize',5);
plot(k1:k2,20*log10(abs(yk1(1,1:size(k,2),3))),'-dr',...
                                  	'LineWidth',2,...
                                   	'MarkerEdgeColor','r',...
                                   	'MarkerFaceColor','r',...
                                  	'MarkerSize',5);
legend('{\itn}=1','{\itn}=2','{\itn}=3','Location','South');
xlabel('\itk');
ylabel('|{{\itY}^{({\itn})}}({\itk})|/dB');
axis([k1 k2 -40 40]);
yout=[yt(1,1:192,1),yt(1,65:192,2),yt(1,65:256,3)];

figure(3);%����LFM������
st0=sin(2*pi*(fl+(fu-fl)/(2*T)*t0).*t0);%��һ����Ԫ���յ���LFM��һ������T�ڵ��źţ�st_all(1,:)
xk_st0=fft(st0(1,:));
P_st0=xk_st0(1:N/2).*conj(xk_st0(1:N/2))/(N/2);
plot((0:N/2-1).*fs/N/f0,10*log10(P_st0),'LineWidth',2);
xlabel('Ƶ��({\itf}_0)');
ylabel('������/(dB/Hz)')
grid on;

figure(4);plot(t0,real(yout)-st0);axis([0 2 -1.5 1.5 ]);
xlabel('\iti');
ylabel('{\ity}({\iti})-{\its}({\iti})');
title('��������������ź�Դ����ʧ���С');
%% ��֤
ykk=fft(yout,5000);
f = fftshift(ykk);
w = linspace(-fs/2,fs/2,5000);%Ƶ�����꣬��λHz 
figure(5),plot(w,abs(f)); title('��������γ�����źŵ�Ƶ��'); xlabel('Ƶ��(Hz)');