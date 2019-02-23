%%���������в����Ż������Ӧ��
%%20181226
%%myuzhao@163.com
%%SOCP-MSL ���� Dolph-Chebychev ������ͼ�Ա�
%%(a) ���������԰꼶�Ĺ�ϵ, (b) ��Ȩ���������Ƚ�
clc;
clear ;
close all;
% %��Ԫλ��
M = 10;
d_lamda=1/2;%��Ԫ���d�벨��lamda�Ĺ�ϵ

%ɨ���������
angle0 = 0;
angle = linspace(-90,90,10000);

%DC
angle11=asin(2/M);
i=0;
SLL = -10:-5:-45;
for d_lamda = [1/2 1/4]
    w_dc1_2 = zeros(size(SLL));
    w_cvx1_2 = w_dc1_2;
    max_sll1 = zeros(size(SLL));
    max_sll1_cvx1 = max_sll1;
    l_angle = zeros(size(SLL));
    r_angle = zeros(size(SLL));
    for i_sll = 1:length(SLL)
        sll = SLL(i_sll);
        type=2;
        w_dc = DC_win(angle11,sll,d_lamda,M,type);
        w_dc = w_dc/sum(w_dc);
        w = w_dc.*exp(-1i*2*pi*d_lamda*(0:M-1)'*sind(angle0));
        w_dc1_2(i_sll) = 10*log10(norm(w)^2);
        as = exp(-1i*2*pi*d_lamda*(0:M-1)'*sind(angle));
        p = w'*as;
        energy_cbf_P=20*log10(abs(p));
        % �ҵ�������
%         figure(1)
%         plot(angle,energy_cbf_P)
        [peak1,index1]=findpeaks(energy_cbf_P);
        [peak2,index2]=findpeaks(-energy_cbf_P);
        [peak3,index3]=max(peak1);
        inner_index = index1(index3);
        temp1 = find(index2>inner_index);
        temp2 = find(index2<inner_index);
        l_angle(i_sll) = index2(temp2(end));%�ҵ������ٽ��
        r_angle(i_sll) = index2(temp1(1));
        %�ҵ�����԰꼶
        max_sll1(i_sll)=max([energy_cbf_P(1:l_angle(i_sll)+50) energy_cbf_P(r_angle(i_sll)-50:end)]);

        angle2 = [angle(1:l_angle(i_sll)+50) angle(r_angle(i_sll)-50:end)];%%%%�԰�����
        ap = exp(-1i*2*pi*d_lamda*(0:M-1)'*sind(angle0));
        apsll = exp(-1i*2*pi*d_lamda*(0:M-1)'*sind(angle2)); 
        cvx_begin quiet%%���꣨��DC��Ȩ�õ����̶���С���԰�
            variable ww(M) complex
            variable s(1)
            minimize(s)
            subject to
                ww'*ap==1;
                abs(ww'*apsll)<=s;
        cvx_end
        
        as = exp(-1i*2*pi*d_lamda*(0:M-1)'*sind(angle));
        energy_cbf_P_cvx = 20*log10(abs(ww'*as));
        w_cvx1_2(i_sll) = 10*log10(norm(ww)^2);
        max_sll1_cvx1(i_sll)=max([energy_cbf_P_cvx(1:l_angle(i_sll)+50) energy_cbf_P_cvx(r_angle(i_sll)-50:end)]);
    end
    if d_lamda ==1/2
        figure(1)
        plot(SLL,abs(max_sll1),'k.-',SLL,abs(max_sll1_cvx1),'b-')
        hold on
        set(gca,'XDir','reverse')
        figure(2)
        hold on
        plot(SLL,w_dc1_2,'k.-',SLL,w_cvx1_2,'b-')
        set(gca,'XDir','reverse')
    else
        figure(1)
        plot(SLL,abs(max_sll1),'r.-',SLL,abs(max_sll1_cvx1),'go-')
        hold on
        set(gca,'XDir','reverse')
        figure(2)
        hold on
        plot(SLL,w_dc1_2,'r.-',SLL,w_cvx1_2,'go-')
        set(gca,'XDir','reverse')
    end
end