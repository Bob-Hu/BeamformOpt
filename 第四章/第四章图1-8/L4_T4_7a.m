%%���������в����Ż������Ӧ��
 %%20170819
 %%myuzhao@163.com
 %%olen���԰���Ʋ���ͼ
 %%����kk(��Ƕȼ���й�ϵ) ���Բ������԰�Ч�� 
clc;
clear;
close all;

%ɨ����㷶Χ
freq1 =1000;  %�ź�Ƶ��
freq0 =1000;  %�ź�Ƶ��
f=freq1;
fs = 10000; % ����Ƶ��
c0 = 344;
snapshots_N=11;

% %��Ԫλ��
element_num=10;
d_lamda=1/2;%��Ԫ���d�벨��lamda�Ĺ�ϵ
d=d_lamda*c0/f*[0:1:element_num-1];
%%ɨ���������
theta0=0*pi/180;%���᷽��
theta_gr=[];%���ŷ���

theta=linspace(-90,90,180);
theta=theta*pi/180;
sll=-30; 
qw_db=10^(sll/20);
sigma_1=zeros(length(theta),1);
sigma_2=sigma_1.^2;
kk=1;

noise=1/sqrt(2)*(randn(element_num,snapshots_N)+1i*randn(element_num,snapshots_N));

aps=noise;
% R=aps*aps'/snapshots_N;
R=eye(element_num,element_num);
% R=(ap0*ap0'+ap1*ap1'+noise*noise')/snapshots_N;

as=exp(1i*2*pi*f*d'*sin(theta0)/c0);%��������
iR=inv(R);
w=iR*as/(as'*iR*as);
ap=exp(1i*2*pi*f*d'*sin(theta)/c0);   
p=ap'*w;
energy_mvdr_P1=20*log10(abs(p));
[peak1,index1]=findpeaks(energy_mvdr_P1);
[peak2,index2]=findpeaks(-energy_mvdr_P1);
[peak3,index3]=max(peak1);
inner_index=index1(index3);
temp1=find(index2>inner_index);
temp2=find(index2<inner_index);
l_theta=index2(temp2(length(temp2)));%�ҵ������ٽ��
r_theta=index2(temp1(1));
% 
energy_mvdr_temp=energy_mvdr_P1(l_theta:1:r_theta);
energy_mvdr_P1(l_theta:1:r_theta)=ones(r_theta-l_theta+1,1)*(sll-10);
index_gr=find(energy_mvdr_P1>sll);
% theta_gr=theta(theta_gr);
sigma_2(1:1:length(theta))=sigma_2(1:1:length(theta))+kk*(abs(10.^(energy_mvdr_P1(1:1:length(theta))./20))-qw_db);
% sigma_2(theta_gr)=sigma_2(theta_gr)+2*(abs(10.^(energy_mvdr_P1(theta_gr)./20))-qw_db);
sigma_2(l_theta:1:r_theta)=zeros(r_theta-l_theta+1,1);
sigma_2(sigma_2<0)=0;
% energy_mvdr_P1(l_theta:1:r_theta)=energy_mvdr_temp;
figure(1)
hold on
plot(theta*180/pi,energy_mvdr_P1)

figure(3)
hold on
plot(index_gr,'.')


k=0;
s1=exp(1i*2*pi*f*randn(1,snapshots_N));
while(length(index_gr)>0)
   k=k+1
   sigma_1=abs(sigma_2.^(1/2));
   figure(2)
   hold on
   plot(theta*180/pi,sigma_1,'.')
   
   figure(3)
   hold on
   plot(theta_gr,'.')
   R=zeros(element_num,element_num);
for ii=1:length(theta)%%��������źŲ����
    ap=exp(1i*2*pi*f*d'*sin(theta(ii))/c0);
    s2=sigma_1(ii).*s1;
    aps=ap*s2;
    R=R+aps*aps'/snapshots_N;
end
R=R+eye(element_num,element_num);
% R=R/max(max(R));
as=exp(1i*2*pi*f*d'*sin(theta0)/c0);%��������
iR=inv(R);
w=iR*as/(as'*iR*as);
ap=exp(1i*2*pi*f*d'*sin(theta)/c0);   
p=ap'*w;
energy_mvdr_P1=20*log10(abs(p));
[peak1,index1]=findpeaks(energy_mvdr_P1);
[peak2,index2]=findpeaks(-energy_mvdr_P1);
[peak3,index3]=max(peak1);
inner_index=index1(index3);
temp1=find(index2>inner_index);
temp2=find(index2<inner_index);
l_theta=index2(temp2(length(temp2)));
r_theta=index2(temp1(1));
energy_mvdr_temp=energy_mvdr_P1(l_theta:1:r_theta);
energy_mvdr_P1(l_theta:1:r_theta)=ones(r_theta-l_theta+1,1)*(sll-10);
index_gr=find(energy_mvdr_P1>sll);
sigma_2(1:1:length(theta))=sigma_2(1:1:length(theta))+kk*(abs(10.^(energy_mvdr_P1(1:1:length(theta))./20))-qw_db);%���¸���Դ�����
% sigma_2(theta_gr)=sigma_2(theta_gr)+120*(abs(10.^(energy_mvdr_P1(theta_gr)./20))-qw_db);
sigma_2(l_theta:1:r_theta)=zeros(r_theta-l_theta+1,1);
sigma_2(sigma_2<0)=0;

energy_mvdr_P1(l_theta:1:r_theta)=energy_mvdr_temp;
figure(1)
hold on
plot(theta*180/pi,energy_mvdr_P1)
if(k>30)
    break;
end
end


figure
hold on
plot(theta*180/pi,energy_mvdr_P1)
xlabel('��λ/(^o)')
ylabel('����/dB')
ylim([-100 30])
grid on


