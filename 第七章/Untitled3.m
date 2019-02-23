clc;
clear all;
close all;
%%
array_num=12;%%��������Ŀ
f0=1000;
f1=f0/2;%%��Сf
fu=f0;%%���f
f_jg=0.01;%��һ�����
fs=3.125*f0;%����f
c=1500;%����
d=c/f0/2*[0:array_num-1];%%�벨������
Fpb=(0.16:0.01:0.32);%%ͨ��Ƶ��
Fsb=[(0:0.01:0.13) (0.35:0.01:0.5)];%%���Ƶ��
Ftb=[(0.14:0.01:0.15) (0.33:0.01:0.34)];%%���ɴ�Ƶ��
fpb=Fpb*fs;%%ͨ��Ƶ��
fsb=Fsb*fs;%���Ƶ��
ftb=Ftb*fs;%%���ɴ�Ƶ��
theta=(-90:2:90);%%�Ƕ�
thetaML=(-8:2:28);%%����Ƕ�
thetaSL=[(-90:2:-12) (32:2:90)];%%�԰�Ƕ�
theta0=10;%%����Ƕ�
%%%����������%%%
SL=-25;
wd=exp(1i*2*pi*(f0/2)*d'*sind(theta0)/c)/array_num;
a=exp(1i*2*pi*(f0/2)*d'*sind(theta)/c);
cbf_p=wd'*a;
energy_cbf_P=20*log10(abs(cbf_p));
energy_cbf_PML=energy_cbf_P(:,42:60);
energy_cbf_PSL=[energy_cbf_P(:,1:40) energy_cbf_P(:,62:end)];
energy_cbf_PSL(:,1:end)=SL;
figure(1)
hold on
plot(theta,energy_cbf_P,'k-');
hold on
scatter(thetaML,energy_cbf_PML,'*');
plot(thetaSL,energy_cbf_PSL,'r');
legend('���沨��','��������','�����԰�')
title('��������')
xlabel('��λ/(^o)')
ylabel('����/dB')
ylim([-60 3])
grid on
%%
f=(0:0.01:0.5)*fs;%%%����Ƶ��
p_d_ML=cbf_p(:,42:60);%%%����
L=25;%%�˲�������
Ts=1/fs;%%�������
taus=-d'*sind(theta0)/c;
Tm=-(taus/Ts+(L-1)/2)*(Ts);


sum=0;
cvx_begin quiet
    variable hh(N*L) 
    variable s_s(1)
    minimize(s_s)
    subject to
        for k=1:length(Fpb)     
            fk=Fpb(k)*fs;
            ak_ML=exp(1i*2*pi*fk*d'*sind(thetaML)/c); %N*Nml
            ak_SL=exp(1i*2*pi*fk*d'*sind(thetaSL)/c); 
            ek=exp(-1i*(0:L-1)'*2*pi*(fk/fs));     %L*1
            ka=exp(-1i*2*pi*fk*Tm);                %N*1
            temp_ML=cheng(ak_ML,ka);                     %N*Nml
            u_ML=kron(ek,temp_ML);                       %(L*N)*(Nml) 
            pk_ML(k,:)=hh'*u_ML;                              %1*Nml
            temp2(k,:)=pk_ML(k,:)-p_d_ML  ;                    %1*Nml
            temp_SL=cheng(ak_SL,ka);  
            u_SL=kron(ek,temp_SL);
            pk_SL(k,:)=hh'*u_SL;
        end
        max(abs(temp2))<=s_s;
        abs(pk_SL)<=10^(SL/20);
%         norm(hh,2)<=0.25;
cvx_end

for k=1:length(fpb)
    fk=fpb(k);
    ak=exp(1i*2*pi*fk*d'*sind(theta)/c);
    ek=exp(-1i*(0:L-1)'*2*pi*(fk/fs));
    ka=exp(-1i*2*pi*fk*Tm);
    temp=cheng(ak,ka);
    u=kron(ek,temp);
    pk=hh'*u;
    energy_p(k,:)=20*log10(abs(pk));
    figure(5)
    plot(theta,20*log10(abs(pk)));
    hold on
  end

 figure(7)
 [ff,tt]=meshgrid(theta,fpb/fs);
 surf(ff,tt,energy_p);
 zlim([-80 0])
 xlabel('��λ/(^o)')
 ylabel('f/fs')
 zlabel('����/dB')
 title('�������ͼ');










 
 
 
 
   
   
   
   
   
   
   
   
   
   