%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                      %
%               Original Protocol  (a=5, m=0.1)                       %
%  Primal CH in y > 50, two energy levels                             %
%                                                                      %
%  === MODIFIED ===                                                    %
%  Added:  save('original_results.mat', ...) after simulation ends    %
%          for use with compare_protocols.m                            %
%                                                                      %
%  NOTE: figure(1) inside the main loop updates every round which is  %
%        slow for 2000 rounds. Comment out figure(1)/plot/hold lines  %
%        inside the loop if you only need saved data for comparison.  %
%                                                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;

% Set ANIMATE = true to watch the per-round node map (very slow for 2000 rounds).
% Keep false (default) for fast execution and saved results only.
ANIMATE = false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%
xm=100;
ym=100;
sink.x=0.5*xm;
sink.y=1.75*ym;
n=100;
Eo=0.5;
Eelec=50*0.000000001;
ETX  =50*0.000000001;
ERX  =50*0.000000001;
Efs    =10*0.000000000001;
Emp=0.0013*0.000000000001;
EDA=5*0.000000001;
m=0.1;
a=5;
rmax=2000;
g=1;
PB=0;
%%%%%%%%%%%%%%%%%%%%%%%%% END OF PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%

do=87.7;

figure(1);
S(n+1).xd=sink.x;
S(n+1).yd=sink.y;

for i=1:1:n
    S(i).xd=rand(1,1)*xm;
    XR(i)=S(i).xd;
    S(i).yd=rand(1,1)*ym;
    YR(i)=S(i).yd;
    S(i).G=0;
    S(i).type='N';

    temp_rnd0=i;

    if (temp_rnd0 >= 0 && temp_rnd0 < 50 )
        t=1;
        S(i).a= t ;
        S(i).E=t*Eo;
        plot(S(i).xd,S(i).yd,'o');
        hold on;
    end

    if (temp_rnd0 >= 50 && temp_rnd0 < 100 )
        t=4;
        S(i).a= t ;
        S(i).E=t*Eo;
        plot(S(i).xd,S(i).yd,'+');
        hold on;
    end
end

plot(S(n+1).xd,S(n+1).yd,'x');

%First Iteration
figure(1);
countCHs=0;
rcountCHs=0;
cluster=1;
countCHs;
rcountCHs=rcountCHs+countCHs;
flag_first_dead=0;

Etot=n*Eo*(1+(a*m));

dtoPCH=xm/2;
k=   (sqrt(n)/sqrt(2*pi))  *   (sqrt(Efs/Emp))   *     (xm/(dtoPCH^2));

for r=0:1:rmax
    r

    EG=0;
    Etotal=0;
    Et(r+1)=0;

    for i=1:1:n
        if (S(i).E>0)
            Etotal=Etotal+S(i).E;
        end
    end

    Et(r+1)=Etotal;

    for i=1:1:n
        if (S(i).E>0)
            S(i).dt = S(i).E/Et(r+1);
            S(i).p=min(S(i).dt*k,1);
            if(mod(r, round(1/ S(i).p) )==0)
                S(i).G=0;
                S(i).cl=0;
            end
        end
    end

    if ANIMATE; hold off; end
    dead=0;
    dead_a=0;
    dead_n=0;
    packets_TO_BS=0;
    packets_TO_CH=0;
    PACKETS_TO_CH(r+1)=0;
    PACKETS_TO_BS(r+1)=0;

    if ANIMATE; figure(1); end
    for i=1:1:n
        if (S(i).E<=0)
            if ANIMATE; plot(S(i).xd,S(i).yd,'red .'); hold on; end
            dead=dead+1;
        end
        if S(i).E>0
            S(i).type='N';
            if ANIMATE; plot(S(i).xd,S(i).yd,'o'); hold on; end
        end
    end

    if ANIMATE; plot(S(n+1).xd,S(n+1).yd,'x'); end
    STATISTICS(r+1).DEAD=dead;
    DEAD(r+1)=dead;
    DEAD_N(r+1)=dead_n;
    DEAD_A(r+1)=dead_a;

    CC(r+1,:)=n-(STATISTICS(r+1).DEAD);

    if (dead==1)
        if(flag_first_dead==0)
            first_dead=r
            flag_first_dead=1;
        end
    end

    countCHs=0;
    cluster=1;
    for i=1:1:n
        if(S(i).E>0)
            temp_rand=rand;
            if ( (S(i).G)<=0)
                if(temp_rand<= (S(i).p/(1-S(i).p*mod(r,round(1/S(i).p)))))
                    countCHs=countCHs+1;
                    packets_TO_BS=packets_TO_BS+1;
                    PACKETS_TO_BS(r+1)=packets_TO_BS;
                    S(i).type='C';
                    S(i).G=round(1/S(i).p)-1;
                    C(cluster).xd=S(i).xd;
                    C(cluster).yd=S(i).yd;
                    if ANIMATE; plot(S(i).xd,S(i).yd,'k*'); end
                    C(cluster).id=i;
                    X(cluster)=S(i).xd;
                    Y(cluster)=S(i).yd;
                    cluster=cluster+1;
                end
            end
        end
    end

    %%%Election du Primar Cluster Head : PCH
    trouve=true;
    pch=1;
    for i=1:1:n
        if(S(i).type=='C' && S(i).yd>50)
            if (trouve==true)
                maxE=S(i).E ;
                pch=i;
                trouve = false;
            else
                if(S(i).E>maxE )
                    maxE=S(i).E;
                    pch=i;
                end
            end
        end
    end

    pch
    if pch ~= 0
        S(pch).type='P';
        P(pch).xd=S(pch).xd;
        P(pch).yd=S(pch).yd;
        if ANIMATE; plot(S(pch).xd,S(pch).yd,'g*','Markersize',10,'Linewidth',20); end
        P(pch).id=pch;
        X(pch)=S(pch).xd;
        Y(pch)=S(pch).yd;
    end

    compte=0;
    for i=1:1:n
        if(S(i).type=='C'&& S(i).E>0)
            distanceBS=sqrt( (S(i).xd-(S(n+1).xd) )^2 + (S(i).yd-(S(n+1).yd) )^2 );
            distancePCH=sqrt( (S(i).xd-(S(pch).xd) )^2 + (S(i).yd-(S(pch).yd) )^2 );

            if(distanceBS <= distancePCH)
                if (distanceBS>do)
                    S(i).E=S(i).E- ( (ETX+EDA)*(4000) + Emp*4000*( distanceBS*distanceBS*distanceBS*distanceBS ));
                    EG=EG+( (ETX+EDA)*(4000) + Emp*4000*( distanceBS*distanceBS*distanceBS*distanceBS ));
                end
                if (distanceBS<=do)
                    S(i).E=S(i).E- ( (ETX+EDA)*(4000)  + Efs*4000*( distanceBS * distanceBS ));
                    EG=EG+ ( (ETX+EDA)*(4000)  + Efs*4000*( distanceBS * distanceBS ));
                end
            end

            if(distanceBS > distancePCH)
                compte=compte+1;
                if (distancePCH>do)
                    S(i).E=S(i).E- ( (ETX+EDA)*(4000) + Emp*4000*( distancePCH*distancePCH*distancePCH*distancePCH ));
                    EG=EG+ ( (ETX+EDA)*(4000) + Emp*4000*( distancePCH*distancePCH*distancePCH*distancePCH ));
                end
                if (distancePCH<=do)
                    S(i).E=S(i).E- ( (ETX+EDA)*(4000)  + Efs*4000*( distancePCH * distancePCH ));
                    EG=EG+ ( (ETX+EDA)*(4000)  + Efs*4000*( distancePCH * distancePCH ));
                end
            end
        end
    end

    pch
    if pch ~= 0
        distancePSB=sqrt( (S(pch).xd-(S(n+1).xd) )^2 + (S(pch).yd-(S(n+1).yd) )^2 );
        for j=1:1:compte
            S(pch).E = S(pch).E- ( (ERX+EDA)*4000 );
            EG=EG + ( (ERX+EDA)*4000 );
        end
        if (distancePSB>do)
            S(pch).E=S(pch).E- ( (ETX+EDA)*(4000) + Emp*4000*( distancePSB*distancePSB*distancePSB*distancePSB ));
            EG=EG+( (ETX+EDA)*(4000) + Emp*4000*( distancePSB*distancePSB*distancePSB*distancePSB ));
        end
        if (distancePSB<=do)
            S(pch).E=S(pch).E- ( (ETX+EDA)*(4000)  + Efs*4000*( distancePSB * distancePSB ));
            EG=EG+( (ETX+EDA)*(4000)  + Efs*4000*( distancePSB * distancePSB ));
        end
        if ANIMATE; plot([S(pch).xd S(n+1).xd],[S(pch).yd S(n+1).yd],'g-.'); end
    end

    STATISTICS(r+1).CLUSTERHEADS=cluster-1;
    CLUSTERHS(r+1)=cluster-1;

    PB = PB + PACKETS_TO_BS(r+1);
    PBS(r+1,:)=PB;

    for i=1:1:n
        if ( S(i).type=='N' )
            if(cluster-1>=1)
                min_dis=sqrt( (S(i).xd-S(n+1).xd)^2 + (S(i).yd-S(n+1).yd)^2 );
                min_dis_cluster=1;
                for c=1:1:cluster-1
                    temp=min(min_dis,sqrt( (S(i).xd-C(c).xd)^2 + (S(i).yd-C(c).yd)^2 ) );
                    if ( temp<min_dis )
                        min_dis=temp;
                        min_dis_cluster=c;
                    end
                end
                if (min_dis>do)
                    S(i).E=S(i).E- ( ETX*(4000) + Emp*4000*( min_dis * min_dis * min_dis * min_dis));
                    EG=EG+( ETX*(4000) + Emp*4000*( min_dis * min_dis * min_dis * min_dis));
                end
                if (min_dis<=do)
                    S(i).E=S(i).E- ( ETX*(4000) + Efs*4000*( min_dis * min_dis));
                    EG=EG+( ETX*(4000) + Efs*4000*( min_dis * min_dis));
                end
                if(min_dis>0)
                    S(C(min_dis_cluster).id).E = S(C(min_dis_cluster).id).E- ( (ERX + EDA)*4000 );
                    EG = EG + ( (ERX + EDA)*4000 );
                    PACKETS_TO_CH(r+1)=n-dead-cluster+1;
                    if ANIMATE; plot([S(i).xd S(C(min_dis_cluster).id).xd],[S(i).yd S(C(min_dis_cluster).id).yd],'b-'); end
                end
                S(i).min_dis=min_dis;
                S(i).min_dis_cluster=min_dis_cluster;
            end
        end
    end

    if ANIMATE; hold on; end
    countCHs;
    rcountCHs=rcountCHs+countCHs;
    EnergieGaspiller(r+1) = EG;

    EGG(g)= EG;
    RR(g) = r;
    PRBS(g)= PB;
    FDD(g)=n-(STATISTICS(r+1).DEAD);
    g=g+1;
end

%% ── Cumulative energy dissipation ────────────────────────────────────────
EE = 0;
for j=1:1: g-1
    EE = EE + EGG(j);
    MKK(j)=EE;
end

%% ── Save for compare_protocols.m ────────────────────────────────────────
if ~exist('first_dead', 'var')
    first_dead = rmax + 1;  % no node died within rmax rounds
end
final_round_orig = r;   % last round executed (== rmax, no break in original)

save('original_results.mat', ...
    'CC', 'Et', 'DEAD', 'DEAD_N', 'DEAD_A', ...
    'PBS', 'PACKETS_TO_BS', 'PACKETS_TO_CH', ...
    'first_dead', 'final_round_orig', 'n', 'rmax', ...
    'EGG', 'RR', 'MKK', 'PRBS', 'FDD', 'Etot');

fprintf('\nOriginal protocol results saved → original_results.mat\n');
fprintf('Run compare_protocols.m to compare with Two-Zone X PCH.\n');

%% ── Original figures (unchanged) ────────────────────────────────────────
figure(2);
plot(CC,'b-','LineWidth',2);
hold on;
grid on;
axis([0 r 0 n]);
xlabel('Time(Round)');
ylabel('Number of nodes alive');
title('a=5 and m=0.1');

figure(3);
plot(PBS,'b-','LineWidth',2);
hold on;
grid on;
axis([0 r 0 35000]);
xlabel('Time(Round)');
ylabel('Number of messages received at the BS');
title('a=5 and m=0.1');

figure(4);
plot(RR,MKK,'b-','LineWidth',2);
hold on;
grid on;
xlabel('Time(Round)');
ylabel('Energy dissipation');
title('a=5 and m=0.1');

figure(5);
plot(RR, Etot - MKK,'b-','LineWidth',2);
hold on;
grid on;
xlabel('Time(Round)');
ylabel('Residual energy');
title('a=5 and m=0.1');

figure(6);
plot(PBS, FDD,'b-','LineWidth',2);
hold on;
grid on
xlabel('Number of messages received at the BS');
ylabel('Number of nodes alive');
title('a=5 and m=0.1');

figure(7);
plot(MKK, PRBS,'b-','LineWidth',2);
hold on;
grid on
ylabel('Number of messages received at the BS');
xlabel('Energy dissipation');
title('a=5 and m=0.1');

%%%%%%%%%%%%%%%%%%%%%%%%%%%   STATISTICS   %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  DEAD        : dead nodes / round
%  DEAD_A      : dead Advanced nodes / round
%  DEAD_N      : dead Normal nodes / round
%  CLUSTERHS   : Cluster Heads / round
%  PACKETS_TO_BS : packets → Base Station / round
%  PACKETS_TO_CH : packets → Cluster Heads / round
%  first_dead  : round of first node death
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
