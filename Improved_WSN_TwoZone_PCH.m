%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                      %
%          IMPROVED: Two-Zone PCH Protocol                            %
%          Zone 1 (y < 50) has PCH1, Zone 2 (y >= 50) has PCH2       %
%          a=5 et m = 0.1, Two energy levels                         %
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

%*** NEW: Zone boundary ***
zone_boundary = 50;  % y-coordinate dividing zones

%%%%%%%%%%%%%%%%%%%%%%%%% END OF PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%
%Computation of do
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

    %*** NEW: Assign zone based on y-coordinate ***
    if S(i).yd < zone_boundary
        S(i).zone = 1;  % Lower zone
    else
        S(i).zone = 2;  % Upper zone
    end

   temp_rnd0=i;
    if (temp_rnd0 >= 0 && temp_rnd0 < 50 )
        t=1;
        S(i).a= t ;
        S(i).E=t*Eo;
        if S(i).zone == 1
            plot(S(i).xd,S(i).yd,'bo');  % Blue circle for zone 1
        else
            plot(S(i).xd,S(i).yd,'co');  % Cyan circle for zone 2
        end
        hold on;
    end
    if (temp_rnd0 >= 50 && temp_rnd0 < 100 )
        t=4;
        S(i).a= t ;
        S(i).E=t*Eo;
        if S(i).zone == 1
            plot(S(i).xd,S(i).yd,'b+');  % Blue + for zone 1
        else
            plot(S(i).xd,S(i).yd,'c+');  % Cyan + for zone 2
        end
        hold on;
    end

end

% Draw zone boundary
plot([0 xm], [zone_boundary zone_boundary], 'k--', 'LineWidth', 2);
plot(S(n+1).xd,S(n+1).yd,'rx', 'MarkerSize', 15, 'LineWidth', 3);
text(5, zone_boundary-5, 'Zone 1 (y < 50)', 'FontSize', 10, 'FontWeight', 'bold', 'Color', 'blue');
text(5, zone_boundary+5, 'Zone 2 (y >= 50)', 'FontSize', 10, 'FontWeight', 'bold', 'Color', 'cyan');

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
dtoPCH=xm/2;
% k is the number of clusters
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
dead_z1=0;  % Dead in zone 1
dead_z2=0;  % Dead in zone 2
%counter for bit transmitted to Bases Station and to Cluster Heads
packets_TO_BS=0;
packets_TO_CH=0;
%counter for bit transmitted to Bases Station and to Cluster Heads
%per round
PACKETS_TO_CH(r+1)=0;
PACKETS_TO_BS(r+1)=0;

% Energy tracking per zone
zone1_energy = 0;
zone2_energy = 0;

figure(1);
for i=1:1:n
    %checking if there is a dead node
    if (S(i).E<=0)
        plot(S(i).xd,S(i).yd,'red .');
        dead=dead+1;
        if S(i).zone == 1
            dead_z1 = dead_z1 + 1;
        else
            dead_z2 = dead_z2 + 1;
        end
        hold on;
    end

    if S(i).E>0
        S(i).type='N';
        if S(i).zone == 1
            plot(S(i).xd,S(i).yd,'bo', 'MarkerSize', 4);
            zone1_energy = zone1_energy + S(i).E;
        else
            plot(S(i).xd,S(i).yd,'co', 'MarkerSize', 4);
            zone2_energy = zone2_energy + S(i).E;
        end
        hold on;
    end
end

% Draw zone boundary
plot([0 xm], [zone_boundary zone_boundary], 'k--', 'LineWidth', 2);
plot(S(n+1).xd,S(n+1).yd,'rx', 'MarkerSize', 15, 'LineWidth', 3);

STATISTICS(r+1).DEAD=dead;
STATISTICS(r+1).DEAD_Z1=dead_z1;
STATISTICS(r+1).DEAD_Z2=dead_z2;
STATISTICS(r+1).ZONE1_ENERGY=zone1_energy;
STATISTICS(r+1).ZONE2_ENERGY=zone2_energy;
DEAD(r+1)=dead;
CC(r+1,:)=n-(STATISTICS(r+1).DEAD);

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
            C(cluster).zone=S(i).zone;  % Store zone info

            if S(i).zone == 1
                plot(S(i).xd,S(i).yd,'b*', 'MarkerSize', 8);  % Blue star for Zone 1 CH
            else
                plot(S(i).xd,S(i).yd,'c*', 'MarkerSize', 8);  % Cyan star for Zone 2 CH
            end

            C(cluster).id=i;
            X(cluster)=S(i).xd;
            Y(cluster)=S(i).yd;
            cluster=cluster+1;
 end
    end
  end
end

%%%*** NEW: Election of TWO Primary Cluster Heads (PCH1 and PCH2) ***%%%

    % PCH1 for Zone 1 (y < 50)
    trouve_z1=true;
    pch1=0;
    for i=1:1:n
        if(S(i).type=='C' && S(i).zone==1)
            if (trouve_z1==true)
                maxE_z1=S(i).E ;
                pch1=i;
                trouve_z1 = false;
            else
                if(S(i).E>maxE_z1 )
                    maxE_z1=S(i).E;
                    pch1=i;
                end
            end
        end
    end

    % PCH2 for Zone 2 (y >= 50)
    trouve_z2=true;
    pch2=0;
    for i=1:1:n
        if(S(i).type=='C' && S(i).zone==2)
            if (trouve_z2==true)
                maxE_z2=S(i).E ;
                pch2=i;
                trouve_z2 = false;
            else
                if(S(i).E>maxE_z2 )
                    maxE_z2=S(i).E;
                    pch2=i;
                end
            end
        end
    end

    % Mark PCH1
    if pch1 ~= 0
        S(pch1).type='P';
        P1.xd=S(pch1).xd;
        P1.yd=S(pch1).yd;
        P1.id=pch1;
        plot(S(pch1).xd,S(pch1).yd,'g^','Markersize',15,'Linewidth',3);  % Green triangle for PCH1
    end

    % Mark PCH2
    if pch2 ~= 0
        S(pch2).type='P';
        P2.xd=S(pch2).xd;
        P2.yd=S(pch2).yd;
        P2.id=pch2;
        plot(S(pch2).xd,S(pch2).yd,'m^','Markersize',15,'Linewidth',3);  % Magenta triangle for PCH2
    end

    %%%%%%%%%%%%%%%%%%%%%%%
    % CH to PCH/BS routing
    %%%%%%%%%%%%%%%%%%%%%%%
    compte1=0;  % Number of CHs sending to PCH1
    compte2=0;  % Number of CHs sending to PCH2

    for i=1:1:n
        %Energy dissipated for CHs
        if(S(i).type=='C' && S(i).E>0)
            distanceBS=sqrt( (S(i).xd-(S(n+1).xd) )^2 + (S(i).yd-(S(n+1).yd) )^2 );

            % Zone 1 CHs route to PCH1 or BS
            if S(i).zone == 1 && pch1 ~= 0
                distancePCH1=sqrt( (S(i).xd-(S(pch1).xd) )^2 + (S(i).yd-(S(pch1).yd) )^2 );

                if(distanceBS <= distancePCH1)
                    % Send to BS
                    if (distanceBS>do)
                        S(i).E=S(i).E- ( (ETX+EDA)*(4000) + Emp*4000*( distanceBS^4 ));
                        EG=EG+( (ETX+EDA)*(4000) + Emp*4000*( distanceBS^4 ));
                    else
                        S(i).E=S(i).E- ( (ETX+EDA)*(4000)  + Efs*4000*( distanceBS^2 ));
                        EG=EG+  ( (ETX+EDA)*(4000)  + Efs*4000*( distanceBS^2 ));
                    end
                else
                    % Send to PCH1
                    compte1=compte1+1;
                    if (distancePCH1>do)
                        S(i).E=S(i).E- ( (ETX+EDA)*(4000) + Emp*4000*( distancePCH1^4 ));
                        EG=EG+ ( (ETX+EDA)*(4000) + Emp*4000*( distancePCH1^4 ));
                    else
                        S(i).E=S(i).E- ( (ETX+EDA)*(4000)  + Efs*4000*( distancePCH1^2 ));
                        EG=EG+ ( (ETX+EDA)*(4000)  + Efs*4000*( distancePCH1^2 ));
                    end
                end
            end

            % Zone 2 CHs route to PCH2 or BS
            if S(i).zone == 2 && pch2 ~= 0
                distancePCH2=sqrt( (S(i).xd-(S(pch2).xd) )^2 + (S(i).yd-(S(pch2).yd) )^2 );

                if(distanceBS <= distancePCH2)
                    % Send to BS
                    if (distanceBS>do)
                        S(i).E=S(i).E- ( (ETX+EDA)*(4000) + Emp*4000*( distanceBS^4 ));
                        EG=EG+( (ETX+EDA)*(4000) + Emp*4000*( distanceBS^4 ));
                    else
                        S(i).E=S(i).E- ( (ETX+EDA)*(4000)  + Efs*4000*( distanceBS^2 ));
                        EG=EG+  ( (ETX+EDA)*(4000)  + Efs*4000*( distanceBS^2 ));
                    end
                else
                    % Send to PCH2
                    compte2=compte2+1;
                    if (distancePCH2>do)
                        S(i).E=S(i).E- ( (ETX+EDA)*(4000) + Emp*4000*( distancePCH2^4 ));
                        EG=EG+ ( (ETX+EDA)*(4000) + Emp*4000*( distancePCH2^4 ));
                    else
                        S(i).E=S(i).E- ( (ETX+EDA)*(4000)  + Efs*4000*( distancePCH2^2 ));
                        EG=EG+ ( (ETX+EDA)*(4000)  + Efs*4000*( distancePCH2^2 ));
                    end
                end
            end
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%
    % PCH1 energy consumption (reception + transmission to BS)
    %%%%%%%%%%%%%%%%%%%%%%%
    if pch1 ~= 0 && S(pch1).E > 0
        distanceP1BS=sqrt( (S(pch1).xd-(S(n+1).xd) )^2 + (S(pch1).yd-(S(n+1).yd) )^2 );

        % Reception from CHs
        for j=1:1:compte1
            S(pch1).E = S(pch1).E- ( (ERX+EDA)*4000 );
            EG=EG + ( (ERX+EDA)*4000 );
        end

        % Transmission to BS
        if (distanceP1BS>do)
            S(pch1).E=S(pch1).E- ( (ETX+EDA)*(4000) + Emp*4000*( distanceP1BS^4 ));
            EG=EG+( (ETX+EDA)*(4000) + Emp*4000*( distanceP1BS^4 ));
        else
            S(pch1).E=S(pch1).E- ( (ETX+EDA)*(4000)  + Efs*4000*( distanceP1BS^2 ));
            EG=EG+( (ETX+EDA)*(4000)  + Efs*4000*( distanceP1BS^2 ));
        end

        plot([S(pch1).xd S(n+1).xd],[S(pch1).yd S(n+1).yd],'g-.', 'LineWidth', 2);
    end

    %%%%%%%%%%%%%%%%%%%%%%%
    % PCH2 energy consumption (reception + transmission to BS)
    %%%%%%%%%%%%%%%%%%%%%%%
    if pch2 ~= 0 && S(pch2).E > 0
        distanceP2BS=sqrt( (S(pch2).xd-(S(n+1).xd) )^2 + (S(pch2).yd-(S(n+1).yd) )^2 );

        % Reception from CHs
        for j=1:1:compte2
            S(pch2).E = S(pch2).E- ( (ERX+EDA)*4000 );
            EG=EG + ( (ERX+EDA)*4000 );
        end

        % Transmission to BS
        if (distanceP2BS>do)
            S(pch2).E=S(pch2).E- ( (ETX+EDA)*(4000) + Emp*4000*( distanceP2BS^4 ));
            EG=EG+( (ETX+EDA)*(4000) + Emp*4000*( distanceP2BS^4 ));
        else
            S(pch2).E=S(pch2).E- ( (ETX+EDA)*(4000)  + Efs*4000*( distanceP2BS^2 ));
            EG=EG+( (ETX+EDA)*(4000)  + Efs*4000*( distanceP2BS^2 ));
        end

        plot([S(pch2).xd S(n+1).xd],[S(pch2).yd S(n+1).yd],'m-.', 'LineWidth', 2);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
STATISTICS(r+1).CLUSTERHEADS=cluster-1;
CLUSTERHS(r+1)=cluster-1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Nombre de paquets envoyées vers la BS
     PB = PB + PACKETS_TO_BS(r+1);
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

            if (min_dis>do)
                S(i).E=S(i).E- ( ETX*(4000) + Emp*4000*( min_dis^4));
                EG=EG+( ETX*(4000) + Emp*4000*( min_dis^4));
            else
                S(i).E=S(i).E- ( ETX*(4000) + Efs*4000*( min_dis^2));
                EG=EG+( ETX*(4000) + Efs*4000*( min_dis^2));
            end

        if(min_dis>0)
            S(C(min_dis_cluster).id).E = S(C(min_dis_cluster).id).E- ( (ERX + EDA)*4000 );
            EG = EG +   ( (ERX + EDA)*4000 );
            PACKETS_TO_CH(r+1)=n-dead-cluster+1;

            if S(i).zone == 1
                plot([S(i).xd S(C(min_dis_cluster).id).xd],[S(i).yd S(C(min_dis_cluster).id).yd],'b-', 'LineWidth', 0.5);
            else
                plot([S(i).xd S(C(min_dis_cluster).id).xd],[S(i).yd S(C(min_dis_cluster).id).yd],'c-', 'LineWidth', 0.5);
            end
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

%%%%%%%%%% VISUALIZATION %%%%%%%%%%
%first node Dies
figure(2);
plot(CC,'r-','LineWidth',2);
hold on;
grid on;
axis([0 r 0 n]);
xlabel('Time(Round)');
ylabel('Number of nodes alive');
title('IMPROVED: Two-Zone PCH (a=5 and m=0.1)');

 %les paquets recus par BS
figure(3);
plot(PBS,'r-','LineWidth',2);
hold on;
grid on;
axis([0 r 0 35000]);
xlabel('Time(Round)');
ylabel('Number of messages received at the BS');
title('IMPROVED: Two-Zone PCH (a=5 and m=0.1)');

EE = 0;
for j=1:1: g-1
    EE = EE + EGG(j);
    MKK(j)=EE;
end

 %figure quatre energy residuelle dans le reseaux par round
  figure(4);
plot(RR,MKK,'r-','LineWidth',2);
hold on;
grid on;
xlabel('Time(Round)');
ylabel('Energy dissipation');
title('IMPROVED: Two-Zone PCH (a=5 and m=0.1)');

% l'energie gaspiller par rapport au round
figure(5);
plot(RR, Etot - MKK,'r-','LineWidth',2);
hold on;
grid on;
xlabel('Time(Round)');
ylabel('Residual energy');
title('IMPROVED: Two-Zone PCH (a=5 and m=0.1)');

%paquets recu par rapport au noud vivantes
figure(6);
plot(PBS, FDD,'r-','LineWidth',2);
hold on;
grid on
xlabel('Number of messages received at the BS');
ylabel('Number of nodes alive');
title('IMPROVED: Two-Zone PCH (a=5 and m=0.1)');

 % les paquets par rapports à l'energie gaspiller
figure(7);
plot(MKK, PRBS,'r-','LineWidth',2);
hold on;
grid on
ylabel('Number of messages received at the BS');
xlabel('Energy dissipation');
title('IMPROVED: Two-Zone PCH (a=5 and m=0.1)');

% NEW: Zone energy distribution over time
figure(8);
rounds_vec = 1:length([STATISTICS.ZONE1_ENERGY]);
zone1_energy_vec = [STATISTICS.ZONE1_ENERGY];
zone2_energy_vec = [STATISTICS.ZONE2_ENERGY];

plot(rounds_vec, zone1_energy_vec, 'b-', 'LineWidth', 2);
hold on;
plot(rounds_vec, zone2_energy_vec, 'c-', 'LineWidth', 2);
plot(rounds_vec, zone1_energy_vec + zone2_energy_vec, 'k--', 'LineWidth', 1.5);
xlabel('Rounds');
ylabel('Energy (J)');
title('Energy Distribution Across Zones');
legend('Zone 1 (y < 50)', 'Zone 2 (y >= 50)', 'Total', 'Location', 'best');
grid on;

% Save results
save('improved_twozone_pch_results.mat', 'STATISTICS', 'CC', 'PBS', 'MKK', 'RR', 'PRBS', 'FDD', 'first_dead', 'Etot');

fprintf('\n=== IMPROVED Two-Zone PCH Protocol Results ===\n');
fprintf('First node death: Round %d\n', first_dead);
fprintf('Network lifetime: %d rounds\n', r);
fprintf('Total packets to BS: %d\n', PB);
fprintf('Total energy dissipated: %.4f J\n', MKK(end));
fprintf('============================================\n\n');
