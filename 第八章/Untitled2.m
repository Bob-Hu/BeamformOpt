 %%paper���������Ԥ�˲�Ŀ�귽λ����
 %%%%%%%��ͬ׼����Ƶ��˲����Ա�
clear
clc
% close all


format = ['r-.';'b-+';'k--'];
%%%%%%%%%%%%%%%%%%%%%%�źŲ���%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
C0 = 340;
Snapshots = 15;
Fs = 10000;
Angle = [0 90;    %%%ˮƽ��  ������
%          -5 90
         ];
SNR =   [0];
Freqs = [1000;
         ];
Freqs_ref = 1000;
rand_state = 1;
rng('default');
rng(rand_state);
%%%%%%%%%%%%%%%%%%%%%%���в���%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Sensor = 1; %%Sound_Pressur%%Acoustic_Vector_Sensor
if Sensor == 2
    Sensor_Channel_Num = 4;
else
    Sensor_Channel_Num = 1;
end

M = 20;
Pos_array = zeros(M,3);
Pos_array(:,1) = (0:1:M-1) * (C0/Freqs_ref/2);
Array_Loc = Pos_array;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%���������ź�%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MM = Sensor_Channel_Num * M;
aps_all = zeros(MM, Snapshots);
noise = 1/sqrt(2) * (randn(MM, Snapshots)+1i * randn(MM, Snapshots));
snr = SNR(1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%����ɨ��%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Freq = Freqs;
resolution = 1;
scan_angle1 = [-90:resolution:90]; %%%����ʱ�������������
scan_angle2 = Angle(1,2);          %%%�̶�������
a_all =[]; 
for i_1 = 1:length(scan_angle1) %%%ˮƽ��
        Angle0 = [scan_angle1(i_1), scan_angle2];
        uu =[sind(Angle0(2)) * sind(Angle0(1));
             sind(Angle0(2)) * cosd(Angle0(1));
             cosd(Angle0(2))];
        as = exp(-1i * 2 * pi * Freq /C0 * (Array_Loc * uu) );
        if( Sensor == 2)
            avxs= as * uu(1);
            avys= as * uu(2);
%             avzs= as * uu(3);
            steer_vector =[ as; avxs; avys;];% avzs
        else
            steer_vector = as;
        end
        a_all= [a_all steer_vector];
end

angle_p = -15:1:15;
angle_s1 = [-90:1:-18];
angle_s2 = [18:1:90];
angle_s =[angle_s1 angle_s2];

a_head = zeros(size(a_all));
index_p = find(scan_angle1>=angle_p(1) & scan_angle1<=angle_p(end))
       
a_head(:,index_p) = a_all(:,index_p);
a_p = a_all(:,index_p);

index_s1 = find(scan_angle1>=angle_s1(1) & scan_angle1<=angle_s1(end));     
a_s1(:,index_s1) = a_all(:,index_s1);

index_s2 = find(scan_angle1>=angle_s2(1) & scan_angle1<=angle_s2(end));    
a_s2(:,index_s2) = a_all(:,index_s2);

a_s = [a_s1 a_s2];

%%%%��С����׼��
G1 = inv(a_all*a_all')*a_all*a_head';
temp = G1' * a_all;
enegry = zeros(size(temp,2),1);
for i =1 : size(temp,2)
     enegry(i)= norm(temp(:,i),2);
end
figure
plot(scan_angle1,20*log10(enegry/max(enegry)),format(1,:))

%%%%���Լ��ͨ��Minimax׼�� 
sl=0.5;
cvx_begin
     variable G2(MM,MM) complex
     variable sss(1)
     minimize(sss)
     subject to
     for iii=1:size(a_p,2)
         norm(G2'*a_p(:,iii) - a_p(:,iii))<= sss;
     end
     norm(G2'*a_s,'fro') <= sl;
cvx_end
 
temp = G2' * a_all;
enegry = zeros(size(temp,2),1);
for i =1 : size(temp,2)
    enegry(i)= norm(temp(:,i),2);
end
hold on
plot(scan_angle1,20*log10(enegry/max(enegry)),format(2,:))
 
%%%%���Լ��ͨ����С����׼��
sum_p=0;
sl=0.5;
cvx_begin
     variable G3(MM,MM) complex
     variable sss(1)
     minimize(sss)
     subject to
     for iii=1:size(a_p,2)
         sum_p= sum_p + norm(G3'*a_p(:,iii) - a_p(:,iii));
     end
     sum_p <= sss;
     norm(G3'*a_s,'fro')<= sl;
 cvx_end
 
temp =G3' * a_all;
enegry = zeros(size(temp,2),1);
for i =1 : size(temp,2)
     enegry(i)= norm(temp(:,i),2);
end
hold on
plot(scan_angle1,20*log10(enegry/max(enegry)),format(3,:))

legend({'��С����׼��','ͨ��Minimax׼��','ͨ����С����׼��'},'fontsize',14,'Location','best')
xlabel('�Ƕ�/^o','fontsize',14)
ylabel('������Ӧ/dB','fontsize',14)
set(gca,'fontsize',14)  
save('G','G1','G2','G3')