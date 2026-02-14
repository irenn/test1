%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                      %
%               Original Protocol - Single PCH (y > 50)               %
%                         a=5  et m = 0.1                             %
%           Primary CH in y> 50 with two energy levels                %
%                                                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Field Dimensions - x and y maximum (in meters)
xm=100;
ym=100;
%x and y Coordinates of the Sink
sink.x=0.5*xm;
sink.y=1.75*ym;
%Number of Nodes in the field
n=100;
%Optimal Election Probability of a node
%to become cluster head
%p=0.1;
%Energy Model (all values in Joules)
%Initial Energy
Eo=0.5;
%Eelec=Etx=Erx
Eelec=50*0.000000001;
ETX  =50*0.000000001;
ERX  =50*0.000000001;
%Transmit Amplifier types
Efs    =10*0.000000000001;
Emp=0.0013*0.000000000001;
%Data Aggregation Energy
EDA=5*0.000000001;
%Values for Hetereogeneity
%Percentage of nodes than are advanced
m=0.1;
%\alpha
a=5;
%maximum number of rounds
rmax=2000;
%variable accumulateur
g=1;
% Paquet to BS
PB=0;
%%%%%%%%%%%%%%%%%%%%%%%%% END OF PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%
%Computation of do
%do=sqrt(Efs/Emp);
do=87.7;
%Creation of the random Sensor Network
figure(1);
S(n+1).xd=sink.x;
S(n+1).yd=sink.y;

for i=1:1:n
    S(i).xd=rand(1,1)*xm;
    XR(i)=S(i).xd;
    S(i).yd=rand(1,1)*ym;
    YR(i)=S(i).yd;
    S(i).G=0;
    %initially there are no cluster heads only nodes
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
%counter for CHs
countCHs=0;
%counter for CHs per round
rcountCHs=0;
cluster=1;
countCHs;
rcountCHs=rcountCHs+countCHs;
flag_first_dead=0;

%Etot : the total initial energy of the two level heterogeneous networks
Etot=n*Eo*(1+(a*m));
%%%%%%%%%%%%****************
%dtoBS: is the avarage distance between the cluster head and BS
%dtoBS = 0.765*(xm/2);
dtoPCH=xm/2;
% k is the number of clusters
%k=   (sqrt(n)/sqrt(2*pi))  *   (sqrt(Efs/Emp))   *     (xm/(dtoBS^2));
k=   (sqrt(n)/sqrt(2*pi))  *   (sqrt(Efs/Emp))   *     (xm/(dtoPCH^2));
%%%%%%%%%%%%****************
for r=0:1:rmax
    r

    %l'energie gaspiller
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

           %Operation for epoch
           if(mod(r, round(1/ S(i).p) )==0)

                   S(i).G=0;
                   S(i).cl=0;

           end
        end
    end
hold off;
%Number of dead nodes
dead=0;
%Number of dead Advanced Nodes
dead_a=0;
%Number of dead Normal Nodes
dead_n=0;
%counter for bit transmitted to Bases Station and to Cluster Heads
packets_TO_BS=0;
packets_TO_CH=0;
%counter for bit transmitted to Bases Station and to Cluster Heads
%per round
PACKETS_TO_CH(r+1)=0;
PACKETS_TO_BS(r+1)=0;
figure(1);
for i=1:1:n
    %checking if there is a dead node
    if (S(i).E<=0)
        plot(S(i).xd,S(i).yd,'red .');
        dead=dead+1;
        hold on;
    end

    if S(i).E>0
        S(i).type='N';
        plot(S(i).xd,S(i).yd,'o');
        hold on;
    end
end

plot(S(n+1).xd,S(n+1).yd,'x');
STATISTICS(r+1).DEAD=dead;
DEAD(r+1)=dead;
DEAD_N(r+1)=dead_n;
DEAD_A(r+1)=dead_a;
 %%%%%%%%
    CC(r+1,:)=n-(STATISTICS(r+1).DEAD);
    %%%%%%%%%
%When the first node dies
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
 %Election of Cluster Heads
 if(temp_rand<= (S(i).p/(1-S(i).p*mod(r,round(1/S(i).p)))))
            countCHs=countCHs+1;
            packets_TO_BS=packets_TO_BS+1;
            PACKETS_TO_BS(r+1)=packets_TO_BS;

            S(i).type='C';
            S(i).G=round(1/S(i).p)-1;
            C(cluster).xd=S(i).xd;
            C(cluster).yd=S(i).yd;
            plot(S(i).xd,S(i).yd,'k*');

            C(cluster).id=i;
            X(cluster)=S(i).xd;
            Y(cluster)=S(i).yd;
            cluster=cluster+1;


 end


    end
  end
end
%%%Election du Primary Cluster Head : PCH
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
        plot(S(pch).xd,S(pch).yd,'g*','Markersize',10,'Linewidth',20);
        P(pch).id=pch;
        X(pch)=S(pch).xd;
        Y(pch)=S(pch).yd;
    end
    %fin d'election PCH
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%
    compte=0;
    for i=1:1:n
        %Energy dissipated pour les CH
        if(S(i).type=='C'&& S(i).E>0)
            % la distance vers la SB
            distanceBS=sqrt( (S(i).xd-(S(n+1).xd) )^2 + (S(i).yd-(S(n+1).yd) )^2 );
            % la distance vers le PCH
            distancePCH=sqrt( (S(i).xd-(S(pch).xd) )^2 + (S(i).yd-(S(pch).yd) )^2 );

            if(distanceBS <= distancePCH)
                %envoi vers BS

                distanceBS;
                if (distanceBS>do)
                    S(i).E=S(i).E- ( (ETX+EDA)*(4000) + Emp*4000*( distanceBS*distanceBS*distanceBS*distanceBS ));
                    EG=EG+( (ETX+EDA)*(4000) + Emp*4000*( distanceBS*distanceBS*distanceBS*distanceBS ));
                end

                if (distanceBS<=do)
                    S(i).E=S(i).E- ( (ETX+EDA)*(4000)  + Efs*4000*( distanceBS * distanceBS ));
                    EG=EG+  ( (ETX+EDA)*(4000)  + Efs*4000*( distanceBS * distanceBS ));
                end
            end
            if(distanceBS > distancePCH)
                %envoi vers PCH
                compte=compte+1;

                distancePCH;
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
    %%%%%%%%%%%%%%%%%%%%%%%
    %l'energie perdu au niveau du PCH
    pch
    if pch ~= 0
            distancePSB=sqrt( (S(pch).xd-(S(n+1).xd) )^2 + (S(pch).yd-(S(n+1).yd) )^2 );
            %energie d'envoi vers BS

            for j=1:1:compte
                %energie de reception des infos des CH
                %PCH considere les CH comme des noeus donc EDA
                S(pch).E = S(pch).E- ( (ERX+EDA)*4000 );
                EG=EG + ( (ERX+EDA)*4000 );
            end

            %envoi des données du PCH  vers BS
            if (distancePSB>do)
                S(pch).E=S(pch).E- ( (ETX+EDA)*(4000) + Emp*4000*( distancePSB*distancePSB*distancePSB*distancePSB ));
                EG=EG+( (ETX+EDA)*(4000) + Emp*4000*( distancePSB*distancePSB*distancePSB*distancePSB ));
            end

            if (distancePSB<=do)
                S(pch).E=S(pch).E- ( (ETX+EDA)*(4000)  + Efs*4000*( distancePSB * distancePSB ));
                EG=EG+( (ETX+EDA)*(4000)  + Efs*4000*( distancePSB * distancePSB ));
            end


    plot([S(pch).xd S(n+1).xd],[S(pch).yd S(n+1).yd],'g-.');
    end
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%
STATISTICS(r+1).CLUSTERHEADS=cluster-1;
CLUSTERHS(r+1)=cluster-1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Nombre de paquets envoyées vers la BS
     PB = PB + PACKETS_TO_BS(r+1)
     PBS(r+1,:)=PB;
    %%%%%%%%%%%%%%%%%%%%%%%
%Election of Associated Cluster Head for Normal Nodes

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
       %Energy dissipated by associated Cluster Head
       %
            min_dis;
            if (min_dis>do)
                S(i).E=S(i).E- ( ETX*(4000) + Emp*4000*( min_dis * min_dis * min_dis * min_dis));
                EG=EG+( ETX*(4000) + Emp*4000*( min_dis * min_dis * min_dis * min_dis));
            end

            if (min_dis<=do)
                S(i).E=S(i).E- ( ETX*(4000) + Efs*4000*( min_dis * min_dis));
                EG=EG+( ETX*(4000) + Efs*4000*( min_dis * min_dis));

            end
        %Energy dissipated
        if(min_dis>0)
            S(C(min_dis_cluster).id).E = S(C(min_dis_cluster).id).E- ( (ERX + EDA)*4000 );
            EG = EG +   ( (ERX + EDA)*4000 );
            PACKETS_TO_CH(r+1)=n-dead-cluster+1;

            plot([S(i).xd S(C(min_dis_cluster).id).xd],[S(i).yd S(C(min_dis_cluster).id).yd],'b-');
        end
       S(i).min_dis=min_dis;
       S(i).min_dis_cluster=min_dis_cluster;

   end
 end
end
hold on;
countCHs;
rcountCHs=rcountCHs+countCHs;
EnergieGaspiller(r+1) = EG;




EGG(g)= EG;
RR(g) = r;
PRBS(g)= PB;
FDD(g)=n-(STATISTICS(r+1).DEAD);
g=g+1;

end
%first node Dies
figure(2);
plot(CC,'b-','LineWidth',2);
hold on;
grid on;
axis([0 r 0 n]);
xlabel('Time(Round)');
ylabel('Number of nodes alive');
title('Original: Single PCH (a=5 and m=0.1)');

 %les paquets recus par BS
figure(3);
plot(PBS,'b-','LineWidth',2);
hold on;
grid on;
axis([0 r 0 35000]);
xlabel('Time(Round)');
ylabel('Number of messages received at the BS');
title('Original: Single PCH (a=5 and m=0.1)');

EE = 0;
for j=1:1: g-1
    EE = EE + EGG(j);
    MKK(j)=EE;
end


 %figure quatre energy residuelle dans le reseaux par round
  figure(4);
plot(RR,MKK,'b-','LineWidth',2);
hold on;
grid on;
xlabel('Time(Round)');
ylabel('Energy dissipation');
title('Original: Single PCH (a=5 and m=0.1)');
% l'energie gaspiller par rapport au round
figure(5);
plot(RR, Etot - MKK,'b-','LineWidth',2);
hold on;
grid on;
xlabel('Time(Round)');
ylabel('Residual energy');
title('Original: Single PCH (a=5 and m=0.1)');

%paquets recu par rapport au noud vivantes
figure(6);
plot(PBS, FDD,'b-','LineWidth',2);
hold on;
grid on
xlabel('Number of messages received at the BS');
ylabel('Number of nodes alive');
title('Original: Single PCH (a=5 and m=0.1)');

 % les paquets par rapports à l'energie gaspiller
figure(7);
plot(MKK, PRBS,'b-','LineWidth',2);
hold on;
grid on
ylabel('Number of messages received at the BS');
xlabel('Energy dissipation');
title('Original: Single PCH (a=5 and m=0.1)');

% Save results
save('original_single_pch_results.mat', 'STATISTICS', 'CC', 'PBS', 'MKK', 'RR', 'PRBS', 'FDD', 'first_dead', 'Etot');

fprintf('\n=== Original Single PCH Protocol Results ===\n');
fprintf('First node death: Round %d\n', first_dead);
fprintf('Network lifetime: %d rounds\n', r);
fprintf('Total packets to BS: %d\n', PB);
fprintf('Total energy dissipated: %.4f J\n', MKK(end));
fprintf('==========================================\n\n');
