 %%���������в����Ż������Ӧ��
 %%20171103
 %%myuzhao@163.com
 %%Բ����L2��L1׼���Ż��������������
clc;
clear ;
close all;

%ɨ����㷶Χ
freq =1000;  %�ź�Ƶ��
c0 = 344;
lamd=c0/freq;

% %��Ԫλ��
element_num=24;
theta_xy=linspace(-180,165,element_num).';
r=0.96*lamd;%�뾶

%%ɨ���������
theta0=0*pi/180;
theta1=linspace(-180,180,361);
theta=theta1*pi/180;

M=element_num;


index_temp_r=find(theta1<25);
index_temp_l=find(theta1>-25);
% 
theta2=[theta1(1:index_temp_l(1)) theta1(index_temp_r(end):end)];
theta3=theta1(index_temp_l(1):index_temp_r(end));
%����
ap0=exp(1i*2*pi*freq*r/c0*cosd(theta_xy-theta0));
% ap0_error=ap0+abs(ap0).*rand(size(ap0))*0.05;
%%ɨ��
for ii=1:length(theta1)
    %ap1=exp(1i*2*pi*freq*r/c0*cosd(repmat(theta_xy,1,180)-repmat(theta1,24,1)));
    ap(:,ii)=exp(1i*2*pi*freq*r/c0*cosd(theta_xy-theta1(ii)));
end
 ap_error=ap+abs(ap).*rand(size(ap))*0.1;

for ii=1:length(theta2)
    aps(:,ii)=exp(1i*2*pi*freq*r/c0*cosd(theta_xy-theta2(ii)));
end
aps_error=aps+abs(aps).*rand(size(aps))*0.05;  %%�԰�

% for ii=1:length(theta3)
%     apm(:,ii)=exp(1i*2*pi*freq*r*cosd(theta_xy-theta3(ii)));
% end
% apm_error=apm+abs(apm).*rand(size(apm))*0.05;  %%����

figure
plot(theta1,20*log10(abs(ap0'/M*ap)),'k-.')
ylim([-60 10])
hold on


% b=[-1 0 zeros(1,2*M)].';
% aa=[real(aps).' imag(aps).'];
% aa1=[real(ap0).' imag(ap0).'];
% temp_A1=[];
% temp_A2=[];
% SS=0.05;
% for i=1:size(aa,1)
%     temp_A1=[temp_A1;0 -1 zeros(1,2*M);0 0 -aa(i,:)];
% end
% for i=1:size(aa1,1)
%     temp_A2=[temp_A2;0 0 -aa1(i,:);zeros(2*M,1) zeros(2*M,1) -SS*diag(ones(1,2*M))];
% end

% % A=[temp_A1;-1 1 zeros(1,2*M);zeros(2*M,1) zeros(2*M,1) -SS*diag(ones(1,2*M));temp_A2].';
% c=[zeros(size(aa,1)*2,1);0;zeros(2*M,1);repmat([-1 zeros(1,2*M)].',size(aa1,1),1)];
% K.q=[2*ones(1,size(aa,1)) 2*M+1 (2*M+1)*ones(1,size(aa1,1))];
% [x,y]=sedumi(A,b,c,K);
% ww=y(3:12)+1i*y(13:22);

%%��С���԰�
cvx_begin quiet%%
        variable w_msl(M) complex
        variable s_msl(1)
    minimize(s_msl)
    subject to
          for i=1:size(aps,2)
            abs(aps(:,i)'*w_msl)<=s_msl;
          end
          ap0'*w_msl==1;
%           s<=-20;
cvx_end

hold on
energy_cbf_P_msl=20*log10(abs(w_msl'*ap));
plot(theta1,energy_cbf_P_msl,'b')


%%l2׼���Ƚ�
ss=0.05*(M^0.5);
cvx_begin quiet %%
        variable w_l2(M) complex
        variable s_l2(1)
    minimize(s_l2)
    subject to
          for i=1:size(aps,2)
            abs(aps(:,i)'*w_l2)+ss*norm(w_l2,2)<=s_l2;
          end
          for i=1:size(ap0,2)
          {ss*w_l2,ap0(:,i)'*w_l2-1} <In> complex_lorentz(M);      
          end
%           s<=-20;
cvx_end

%%l1׼���Ƚ�
ss=0.05;
sum_w_l1=0;
cvx_begin quiet%%
        variable w_l1(M) complex
        variable s_l1(1)
    minimize(s_l1)
    subject to
%           for ii=1:M
%                sum_w_l1=abs(w_l1(ii))+sum_w_l1;
%           end
          sum_w_l1=sum(abs(w_l1));
          for i=1:size(aps,2)
              abs(aps(:,i)'*w_l1)+ss*sum_w_l1<=s_l1;
          end
          for i=1:size(ap0,2)
          {ss*w_l1,ap0(:,i)'*w_l1-1} <In> complex_lorentz(M);      
          end
%           s<=-20;
cvx_end


energy_cbf_P_l2=20*log10(abs(w_l2'*ap));
hold on
plot(theta1,energy_cbf_P_l2,'g')

energy_cbf_P_l1=20*log10(abs(w_l1'*ap));
plot(theta1,energy_cbf_P_l1,'r--')


figure%% error
plot(theta1,20*log10(abs(w_l2'*ap_error)),'g-')
hold on
plot(theta1,20*log10(abs(w_msl'*ap_error)),'b-.')
plot(theta1,20*log10(abs(ap0'/M*ap_error)),'k-.')
plot(theta1,20*log10(abs(w_l1'*ap_error)),'r--')
