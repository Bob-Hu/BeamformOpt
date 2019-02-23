clear
clc
close all

format = ['r-.';'b-+';' k.'];
%%%%%%%%%%%%%%%%%%%%%%�źŲ���%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
C0 = 340;
Snapshots = 15;
Fs = 10000;
Angle = [0  90;    %%%ˮƽ��  ������
%          -5 90
         ];
SNR =   [0];
Freq = [1000;
         ];
Freqs_ref = 1000;
rand_state = 1;
rng('default');
rng(rand_state);
%%%%%%%%%%%%%%%%%%%%%%���в���%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Sensor = 2; %%Sound_Pressur%%Acoustic_Vector_Sensor
if Sensor == 2
    Sensor_Channel_Num = 4;
else
    Sensor_Channel_Num = 1;
end

M = 10;
Pos_array = zeros(M,3);
Pos_array(:,1) = (0:1:M-1) * (C0/Freqs_ref/2);
Array_Loc = Pos_array;

Angle0 = Angle;
uu =[sind(Angle0(2)) * sind(Angle0(1));
     sind(Angle0(2)) * cosd(Angle0(1));
     cosd(Angle0(2))];
     as = exp(-1i * 2 * pi * Freq /C0 * (Array_Loc * uu) );
     if( Sensor == 2)
         avxs= as * uu(1);
         avys= as * uu(2);
         avzs= as * uu(3);
         steer_vector =[as; avxs; avys; avzs];%
     else
         steer_vector = as;
     end
a0 = steer_vector;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
            avzs= as * uu(3);
            steer_vector =[as; avxs; avys; avzs];% 
        else
            steer_vector = as;
        end
        a_all= [a_all steer_vector];
end
p = 20*log10(abs(a_all'*a0)/max(abs(a_all'*a0)));

angle_ml = -12:1:12;
angle_sl1 = [-90:1:-12];
angle_sl2 = [12:1:90];
angle_sl =[angle_sl1 angle_sl2];

% a_head = zeros(size(a_all));
index_ml = find(scan_angle1>=angle_ml(1) & scan_angle1<=angle_ml(end))
       
a_ml = a_all(:,index_ml);%%%���굼������
p_ml = p(index_ml);


index_s1 = find(scan_angle1>=angle_sl1(1) & scan_angle1<=angle_sl1(end));     
a_sl1  = a_all(:,index_s1);

index_s2 = find(scan_angle1>=angle_sl2(1) & scan_angle1<=angle_sl2(end));    
a_sl2  = a_all(:,index_s2);

index_sl = [index_s1 index_s2];
a_sl = [a_sl1 a_sl2];%%%�԰굼������
p_sl = p(index_sl);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure
plot(scan_angle1 , p,format(1,:))
hold on
plot(angle_ml , p_ml,format(2,:))
plot(angle_sl , p_sl,format(3,:))
ylim([-90 0])
xlabel('�Ƕ�/^o','fontsize',14)
ylabel('������Ӧ/dB','fontsize',14)
legend({'������Ӧ','��������','�԰�����'},'fontsize',14,'Location','best')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%������Լ������С�԰겨����Ӧ%%%%%%%
cvx_begin quiet%
   variable w_msl(M*4) complex
   variable s_msl(1)
   minimize(s_msl)
   subject to
        abs(w_msl'*a_sl)<=s_msl;
        w_msl'* a0 == 1;
cvx_end 

figure
plot(scan_angle1 , p,format(1,:))
p_msl =20*log10(abs(w_msl' * a_all)/max(abs(w_msl' * a_all)));
hold on
plot(scan_angle1,p_msl ,format(2,:))
ylim([-90 0])
xlabel('�Ƕ�/^o','fontsize',14)
ylabel('������Ӧ/dB','fontsize',14)
legend({'DAS������Ӧ','����԰겨����Ӧ'},'fontsize',14,'Location','best')
norm(w_msl)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%������Լ�����Ƚ���С�԰겨����Ӧ%%%%%%%
cvx_begin quiet%
   variable w_msl(M*4) complex
   variable s_msl(1)
   minimize(s_msl)
   subject to
        abs(w_msl'*a_sl)<=s_msl;
        w_msl'* a0 == 1;
        norm(w_msl) <= 1/(M*4)*10;
cvx_end 

figure
plot(scan_angle1 , p,format(1,:))
p_msl =20*log10(abs(w_msl' * a_all)/max(abs(w_msl' * a_all)));
hold on
plot(scan_angle1,p_msl ,format(2,:))
ylim([-90 0])
xlabel('�Ƕ�/^o','fontsize',14)
ylabel('������Ӧ/dB','fontsize',14)
legend({'DAS������Ӧ','�Ƚ�����԰겨����Ӧ'},'fontsize',14,'Location','best')
norm(w_msl)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%�԰����������С���%%%%%%%
max_sl = -20; %%%
max_sl=10.^(max_sl/20);
p_ml = 10.^(p_ml/20); %%%����������Ӧ
cvx_begin quiet%
    variable w_msl(M*4) complex
    p_temp=(w_msl' * a_all);
    p_temp_ml=p_temp(index_ml);
    p_temp_ml=p_temp_ml(:); %%%�Ż�������Ӧ
    p_ml=p_ml(:);%%%����������Ӧ
    p_temp_sl=p_temp(index_sl);%%%�Ż��԰���Ӧ
    
    minimize(norm(p_temp_ml-p_ml,2))  %ML 2����
subject to
    abs(p_temp_sl) <= max_sl;%%sl L_inf
    w_msl'*a0 == 1;
%     norm(w_msl,2) <=55;% 2.5;%$1/(M*4)*12500;
cvx_end

figure
plot(scan_angle1 , p,format(1,:))
p_msl =20*log10(abs(w_msl' * a_all)/max(abs(w_msl' * a_all)));
hold on
plot(scan_angle1,p_msl ,format(2,:))
ylim([-90 0])
xlabel('�Ƕ�/^o','fontsize',14)
ylabel('������Ӧ/dB','fontsize',14)
legend({'DAS������Ӧ','�԰����������С���'},'fontsize',14,'Location','best')
norm(w_msl,2)