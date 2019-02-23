clear all;
clc;
close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  ������ʼ�� %%%%%%%%%%%%%%%%%%%%%%%%%%
M = 12;       	% 12Ԫ����������

% ���Ե�Ƶ�ź�LPM����
f0 = 1000;    	% f0
f1 = 0.5*f0;    
fu = f0;       	% f1��fuΪ��Ƶ�ź�Դ�����±߽�Ƶ�� 
fs = 5*f0;     	% ����Ƶ��fs
T = 512/fs;    	% �źų���ʱ�䣬����T*fs = 512��������
N = ceil(T*fs);	% �ܵĲ�������512���˴�����趨N=T*fs���������������Ĳ���Ƶ�ʣ����׳���

% ��0=c/f0
c = 3*10^8;
lambda0 = c/f0;

% ȡ��Ƶ��������k = 21,...56���Ӵ����ݣ���ӦƵ�ʷ�ΧΪ[0.4102f0,1.0938f0]
% fk = fs*k/L      , k = 1,...,L/2-1
%    = fs*(k-L)/L  , k = L/2,...L-1
L = N/2; % �������ݿ鳤��256��
k = 21:1:56;
fk = zeros(1,length(k));
for i=1:length(k)
    if k(i)< L/2
        fk(i) = fs*k(i)/L;   
    else
        fk(i) = fs*(k(i)-L)/L;
    end
end

% �ź����䷽��Ϊ��0
phi = 90*pi/180; % xOyƽ�棬phi = 90��
theta0 = -30*pi/180; % ��0 = -30��

% ��Ԫ��������p_m
p_element_coordinate = ones(2,1,M);
p_element_coordinate(1,1,:) = 0; % x = 0
p_element_coordinate(2,1,:) = (0:M-1).*lambda0/2; % y_m = (m-1)/2*��

% �źŴ�������ĵ�λ����v(��0)
v_theta0 = -[sin(phi)*cos(theta0),sin(phi)*sin(theta0)].'; % ��.'���ǹ���ת�ã���'������ת��

%%%%%%%%%%%%%%%%%%%% part2: ���沨���γ�����Ȩ����w_c(fk) %%%%%%%%%%%%%%%%%%
% ��������Ϊ��0ʱ��������������a(��0)
omega = 2*pi*fk; % w = 2��fk
a_theta0 = zeros(M,length(k));
k_theta0 = zeros(2,length(k));
for i=1:length(k)
	k_theta0(:,i) = omega(i)/c*v_theta0; 
    for m=1:M
        a_theta0(m,i) = exp(-1i*k_theta0(:,i).'*p_element_coordinate(:,:,m));
    end
end

% խ�����沨���γ����ļ�Ȩ����w_c(fk)
w_c = a_theta0/M;

%%%%%%%%%%%%%%%%%%% part3: ��Ԫ���յ���Ч�ź�s_receive_LFM %%%%%%%%%%%%%%%%%
% ��Ԫ����ʱ����Ԫ1���յ�����ʱ��ԪM��δ���յ����ݣ���m = v(��0).'*pm/c
tau = zeros(1,M);
for m=1:M
    tau(m) = v_theta0.'*p_element_coordinate(:,:,m)/c;
end
delay = floor(tau*fs);  % ��ʱ�������ȡ��������m/Ts = ��m*fs

% ��������������Ե�Ƶ�ź�s_LFM(i) = sin(2*pi*(f1+(fu-f1)/(2*T)*t(i))*t(i));
te = (0:1:N-1);
t = (0:1:N+delay(M)-1)./fs;
s_receive_LFM = zeros(M,N); %��Ч�źų�������512��
s_receive_LFM_tmp = zeros(M,length(t));  % ��Ԫ��������
for m=1:M	
	for i=1:length(t)
        s_receive_LFM_tmp(m,i) = sin(2*pi*(f1+(fu-f1)/(2*T)*(t(i)-tau(m)))*(t(i)-tau(m)));  % ��Ԫm���յ����ź�sm(t)=s(t-��m)
        
        % ����ʱ�� 0<=t<T
        if t(i)-tau(m)<0
            s_receive_LFM_tmp(m,i) = 0;
        elseif t(i)-tau(m)>=T
            s_receive_LFM_tmp(m,i) = 0;
        end
        
        % ȡǰ512������Ϊ��������
        if i<=N
            s_receive_LFM(m,i)= s_receive_LFM_tmp(m,i);
        end
    end
end

%%%%%%%%%%%%%%%%% part4: ��Ԫ��Ч���ݷֶν���DFT�����ص���Ϊ2��%%%%%%%%%%%%%%
%      |     ,     , ... ,    |          |     ,     , ... ,     | �� k0
%      |     ,     , ... ,    |          |     ,     , ... ,     | �� k1
% x(n)=|     ,     , ... ,    |   X(k) = |     ,     , ... ,     | �� k2
%      |     ,     , ... ,    |          |     ,     , ... ,     | ...
%      |     ,     , ... ,    |          |     ,     , ... ,     | �� kL-1
%        ��    ��          ��               ��    ��          ��
%       x1(n) x2(n)   ... xM(n)           X1(k) X2(k)  ...  XM(k)

xn_2_seg = zeros(L,M,2);
Xk_2_seg = zeros(L,M,2);
for m=1:M
    for i=1:L
        xn_2_seg(i,m,1) = s_receive_LFM(m,i);
        xn_2_seg(i,m,2) = s_receive_LFM(m,i+L);
    end
%     Xk_2_seg(:,m,1) = dft(xn_2_seg(:,m,1),L);
%     Xk_2_seg(:,m,2) = dft(xn_2_seg(:,m,2),L);
      Xk_2_seg(:,m,1) = fft(xn_2_seg(:,m,1));
      Xk_2_seg(:,m,2) = fft(xn_2_seg(:,m,2));
end

Yk_2_seg = zeros(2,length(k));
for i=1:length(k)
    Yk_2_seg(1,i) = w_c(:,i)'*Xk_2_seg(k(i)+1,:,1).';   % k(i)+1 �Ŷ�ӦX(21)��X(56)
    Yk_2_seg(2,i) = w_c(:,i)'*Xk_2_seg(k(i)+1,:,2).';
end

%%%%%%%%%%%%%%%%% part5: 2�β������Ƶ�����ݽ���IDFT���õ�ʱ����� %%%%%%%%%
Yk_2_seg_full = zeros(L,2);
for i=1:length(k)
    Yk_2_seg_full(k(i)+1,1) = Yk_2_seg(1,i);            % k(i)+1 �Ŷ�ӦY(21)��Y(56)
    Yk_2_seg_full(L-k(i)+1,1) = conj(Yk_2_seg(1,i));
    
    Yk_2_seg_full(k(i)+1,2) = Yk_2_seg(2,i);            
    Yk_2_seg_full(L-k(i)+1,2) = conj(Yk_2_seg(2,i));    % L-k(i)+1��Ӧ�ĸ�Ƶ��
end

yn_2_seg_full = zeros(L,2);
% yn_2_seg_full(:,1) = idft(Yk_2_seg_full(:,1),L);
% yn_2_seg_full(:,2) = idft(Yk_2_seg_full(:,2),L);
yn_2_seg_full(:,1) = ifft(Yk_2_seg_full(:,1));
yn_2_seg_full(:,2) = ifft(Yk_2_seg_full(:,2));

% �������ص�����ƴ��
yn_2_seg = zeros(1,N);
for i=1:L
    yn_2_seg(i) = yn_2_seg_full(i,1);
    yn_2_seg(i+L) = yn_2_seg_full(i,2);
end

%%%%%%%%%%%%%%%%% part6: ��Ԫ��Ч���ݷֶν���DFT��50%�ص���Ϊ3��%%%%%%%%%%%%%%
xn_3_seg = zeros(L,M,3);
Xk_3_seg = zeros(L,M,3);
for m=1:M
    for i=1:L
        xn_3_seg(i,m,1) = s_receive_LFM(m,i);
        xn_3_seg(i,m,2) = s_receive_LFM(m,i+L/2);
        xn_3_seg(i,m,3) = s_receive_LFM(m,i+L);
    end
%     Xk_3_seg(:,m,1) = dft(xn_3_seg(:,m,1),L);
%     Xk_3_seg(:,m,2) = dft(xn_3_seg(:,m,2),L);
%     Xk_3_seg(:,m,3) = dft(xn_3_seg(:,m,3),L);
    Xk_3_seg(:,m,1) = fft(xn_3_seg(:,m,1));
    Xk_3_seg(:,m,2) = fft(xn_3_seg(:,m,2));
    Xk_3_seg(:,m,3) = fft(xn_3_seg(:,m,3));
end

Yk_3_seg = zeros(3,length(k));
for i=1:length(k)
    Yk_3_seg(1,i) = w_c(:,i)'*Xk_3_seg(k(i)+1,:,1).';
    Yk_3_seg(2,i) = w_c(:,i)'*Xk_3_seg(k(i)+1,:,2).';
    Yk_3_seg(3,i) = w_c(:,i)'*Xk_3_seg(k(i)+1,:,3).';
end

%%%%%%%%%%%%%%%%% part7: 3�β������Ƶ�����ݽ���IDFT���õ�ʱ����� %%%%%%%%%
Yk_3_seg_full = zeros(L,3);
for i=1:length(k)
    Yk_3_seg_full(k(i)+1,1) = Yk_3_seg(1,i);
    Yk_3_seg_full(L-k(i)+1,1) = conj(Yk_3_seg(1,i));
    
    Yk_3_seg_full(k(i)+1,2) = Yk_3_seg(2,i);
    Yk_3_seg_full(L-k(i)+1,2) = conj(Yk_3_seg(2,i));
    
    Yk_3_seg_full(k(i)+1,3) = Yk_3_seg(3,i);
    Yk_3_seg_full(L-k(i)+1,3) = conj(Yk_3_seg(3,i));
end

yn_3_seg_full = zeros(L,3);
% yn_3_seg_full(:,1) = idft(Yk_3_seg_full(:,1),L);
% yn_3_seg_full(:,2) = idft(Yk_3_seg_full(:,2),L);
% yn_3_seg_full(:,3) = idft(Yk_3_seg_full(:,3),L);
yn_3_seg_full(:,1) = ifft(Yk_3_seg_full(:,1));
yn_3_seg_full(:,2) = ifft(Yk_3_seg_full(:,2));
yn_3_seg_full(:,3) = ifft(Yk_3_seg_full(:,3));

% ���ݰ���50%�ص�����ƴ�ӣ�˳���ܱ䶯�����Ҳ�����һ��ѭ�������
yn_3_seg = zeros(1,N);
for i=1:L
    yn_3_seg(i) = yn_3_seg_full(i,1);  	   
end

for i=1:L
    yn_3_seg(i+L/2) = yn_3_seg_full(i,2);
end

for i=1:L
	yn_3_seg(i+L) = yn_3_seg_full(i,3);  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%% part8: plot all figures %%%%%%%%%%%%%%%%%%%%%%%
% Figure1: �������źŲ���
plot(te,s_receive_LFM(1,:))
xlabel('\iti');
ylabel('{\its}({\iti})');
axis([0 N-1 -1.25 1.25]);

% Figure2/3: �źŵĹ������ܶ�
% algorithm 1:ֱ�ӷ������ף�|Xk|^2/N���ƹ�����,matlab����������
figure;
Xk = fft(s_receive_LFM(1,:));
Px = abs(Xk).^2/N/(fs/f0)*2;        % ע��:*2 �ǹؼ�����Ϊ�˴���ȡ[0,fs/2)Ƶ�������ҹ�һ��
Hpsd = dspdata.psd(Px(1:length(Px)/2),'Fs',fs/f0); 
F_1 = Hpsd.Frequencies;
PSD_1 = Hpsd.Data;
plot(F_1,10*log10(PSD_1),'LineWidth',2);
xlabel('Ƶ��({\itf}_0)');
ylabel('������/(dB/Hz)')
title('|{\itX}({\itk})|^2���ƹ������ܶ�');
axis([0 fs/f0/2 -50 10]);
grid on;

% algorithm 2: ����periodogram����ͼ����,��ʵ��algorithm 1�ޱ�������
figure;
Hs = spectrum.periodogram;
Hpsd = psd(Hs,s_receive_LFM(1,:),'Fs',fs/f0);   % fs/f0��һ������
F_2 = Hpsd.Frequencies;
PSD_2 = Hpsd.Data;
plot(F_2,10*log10(PSD_2),'LineWidth',2);
xlabel('Ƶ��({\itf}_0)');
ylabel('������/(dB/Hz)')
title('Periodogram����ͼ�����ƹ������ܶ�');
axis([0 fs/f0/2 -50 10]);
grid on;

% Figure4: ������Ԫ���յ����źŲ���
figure;
for m=1:M
    t = 1:1:(N+delay(M));
	plot(t,s_receive_LFM_tmp(m,:)/2+m); 
    hold all;
end
xlabel('\iti');
ylabel('��Ԫ��\itm');
axis([0 N+delay(M)-1 0 13]);

% Figure5: ��Ԫ�������ص���Ϊ2�Σ��������Ƶ�����ݷ���|Y(k)|/dB
figure;
plot(k,20*log10(abs(Yk_2_seg(1,:))),':dk',...
                                  	'LineWidth',2,...
                                   	'MarkerEdgeColor','k',...
                                   	'MarkerFaceColor','k',...
                                   	'MarkerSize',5);
hold on;
plot(k,20*log10(abs(Yk_2_seg(2,:))),'-ob',...
                                  	'LineWidth',2,...
                                	'MarkerEdgeColor','b',...
                                  	'MarkerFaceColor','b',...
                                  	'MarkerSize',5);
legend('{\itn}=1','{\itn}=2','Location','South');
xlabel('\itk');
ylabel('|{{\itY}^{({\itn})}}({\itk})|/dB');
axis([k(1)-3 k(length(k))+3 -40 40]);

% Figure6: 2��IDFTʱ���������ƴ��
figure;
plot(te,real(yn_2_seg));
xlabel('\iti');
ylabel('{\ity}({\iti})');
axis([0 N-1 -1.5 1.5]);

% Figure7: ��Ԫ�������ص���Ϊ3�Σ��������Ƶ�����ݷ���|Y(k)|/dB
figure;
plot(k,20*log10(abs(Yk_3_seg(1,:))),':dk',...
                                    'LineWidth',2,...
                                 	'MarkerEdgeColor','k',...
                                    'MarkerFaceColor','k',...
                                    'MarkerSize',5);
hold on;
plot(k,20*log10(abs(Yk_3_seg(2,:))),'--ob',...
                                 	'LineWidth',2,...
                                   	'MarkerEdgeColor','b',...
                                   	'MarkerFaceColor','b',...
                                 	'MarkerSize',5);
hold on;
plot(k,20*log10(abs(Yk_3_seg(3,:))),'-dr',...
                                  	'LineWidth',2,...
                                   	'MarkerEdgeColor','r',...
                                   	'MarkerFaceColor','r',...
                                  	'MarkerSize',5);
legend('{\itn}=1','{\itn}=2','{\itn}=3','Location','South');
xlabel('\itk');
ylabel('|{{\itY}^{({\itn})}}({\itk})|/dB');
axis([k(1)-3 k(length(k))+3 -40 40]);

% Figure8: 3��IDFTʱ���������ƴ��
figure;
plot(te,real(yn_3_seg));
xlabel('\iti');
ylabel('{\ity}({\iti})');
axis([0 N-1 -1.5 1.5]);

% Figure9: DFT��������������ź�Դ����ʧ���С
figure;
plot(te,real(yn_2_seg)-s_receive_LFM(1,:),'--k','LineWidth',2);
hold on;
plot(te,real(yn_3_seg)-s_receive_LFM(1,:),'-b','LineWidth',2);
xlabel('\iti');
ylabel('{\ity}({\iti})-{\its}({\iti})');
legend('���ص�','�ص�50%','Location','SouthWest');
axis([0 N-1 -1.5 1.5]);
