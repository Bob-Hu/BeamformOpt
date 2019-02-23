clc;
clear;
close all;
M = 10;
snaps_all = 10:5:60;
LNR = 10;
temp1 = zeros(length(snaps_all),1);
temp2 = zeros(length(snaps_all),1);
rand_state = 1;
rng('default');
rng(rand_state);
for i_snaps = 1:length(snaps_all)
    snaps = snaps_all(i_snaps);
    noise = 1/sqrt(2)*(randn(M,snaps)+1i*randn(M,snaps));%��˹������
    snr0 = 0;
    angle0 = 0;
    s0 = randn(1, snaps) ;%;exp(1i*2*pi*f*(1/fs:1/fs:snaps/fs));%
    as0 = 10^(snr0/20)*exp(-1i*pi*(0:1:M-1)'*sind(angle0)) * s0;

    inr1 = 30;
    angle1 = 20;
    s1 = randn(1, snaps) ;%;exp(1i*2*pi*(f+100)*(1/fs:1/fs:snaps/fs)+1i*2*pi*rand(1));%randn(1, snaps);
    an1 = 10^(inr1/20)*exp(-1i*pi*(0:1:M-1)'*sind(angle1)) * s1;

    inr2 = 35;
    angle2 = 35;
    s2 = randn(1, snaps) ;%;exp(1i*2*pi*(f+200)*(1/fs:1/fs:snaps/fs)+1i*2*pi*rand(1));%randn(1, snaps);
    an2 = 10^(inr2/20)*exp(-1i*pi*(0:1:M-1)'*sind(angle2)) * s2;

    as_all = as0 + an1 + an2 + noise; %%���յ�����
    R = (as_all*as_all')/(snaps);     %%����Э�������

    %Rin = ((an1+an2+noise)*(an1+an2+noise)')/snaps;%%���ź�����Э�������
    Rin = (an1*an1' + an2*an2'+ noise*noise')/snaps;%%���ź�����Э�������
    
    Rn = (noise*noise')/snaps;
    [vector, lamda] = eig(Rn);
    lamda = diag(lamda);
    temp1(i_snaps) = 20*log10((max(lamda)/min(lamda)));
    
    Rn = Rn + 10^(LNR/10) * eye(M);
    [vector, lamda] = eig(Rn);
    lamda = diag(lamda);
    temp2(i_snaps) = 20*log10((max(lamda)/min(lamda)));
end
figure
plot(snaps_all ,temp1 ,'k--*',snaps_all ,temp2 ,'b--o')
xlabel('snaps');ylabel('����ֵ��ɢ/dB');
legend({'SMI','LSMI'})
set(gca,'fontsize',16)