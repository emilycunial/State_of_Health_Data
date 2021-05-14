function hfig = Plot_ALL_Day(ALL_SOH)
%% Takes in the SOH data and plots all the data from the entire deployment in hourly increments

close all;
%% Sets Critical/Warning Values

crit_temp       = 60;
warn_temp       = 45;
crit_sat        = 4;
warn_sat        = 6;
crit_volt       = 9;
warn_volt       = 11;
crit_mass       = 2500000;
crit_current    = 2.5;
crit_timeun     = 100000;
crit_timestatus = .8;
crit_timeq      = 80;
crit_timeerr    = 200;
crit_lock       = 15;

%% Plots the long and lat at hourly intervals (Fig. 1)
figure(1);
clf;

x = ALL_SOH.Lon(:,1);
y = ALL_SOH.Lat(:,1);
z = ALL_SOH.Elev(:,1);
plot3 (x ,y,z,'ro');
    titlename = ['Position for',' ', ALL_SOH.sta,' '];
    htit      = suptitle(titlename);
    set(htit,'fontweight','bold','fontsize',18);
    xlabel ('Longitude',         'FontSize',14);
    ylabel ('Latitude',          'FontSize',14);
    zlabel ('Elevation',         'FontSize',14);
    set(gca,'Xminortick','on','Yminortick','on','Zminortick','on');
    set(gca,'FontName','Lucida Bright');
    set(gca,'Box','on');
    grid on;
    

%% Calculate mean daily values for every day for the SOH fields
% left column is field in daily average struct, right is field in ALL_SOH
% daily_soh_fields = {'time_serial',


% get midnight times of all days in the dataset
DayStarts = unique(floor(ALL_SOH.Time));

% loop through days, calc means
for id = 1:length(DayStarts)
    % find all entries for this day (times > midnight but < next day)
    inday = find(ALL_SOH.Time >= DayStarts(id) & ALL_SOH.Time < DayStarts(id)+1);
    
    % use nanmean to avoid gaps
    sertime(id)        = nanmean(ALL_SOH.Time(inday)); %nanmean  time (serial time)
    hmsat(id)          = nanmean(ALL_SOH.Sat(inday)); %nanmean hourly sat
    hmSupply_Volt(id)  = nanmean(ALL_SOH.Supply_Voltage(inday)); %nanmean  Supply Voltage
    hmCurrent(id)      = nanmean(ALL_SOH.Current(inday)); %nanmean  Current
    hmTemp(id)         = nanmean(ALL_SOH.Temp(inday)); %nanmean Temp
    hmTime_Status(id)  = nanmean(ALL_SOH.Time_Status(inday)); %nanmean  Time status
    hmLock(id)         = nanmean(ALL_SOH.Lock(inday)); %nanmean  Lock
    hmTime_Un(id)      = nanmean(ALL_SOH.Time_Uncertainty(inday)); %nanmean  Time Uncertainty
    hmTime_Error(id)   = nanmean(ALL_SOH.Time_Error(inday)); %nanmean  Time Error
    hmTime_Quality(id) = nanmean(ALL_SOH.Time_Quality(inday)); %nanmean  time quality
    hmMass1(id)        = nanmean(ALL_SOH.mass1(inday)); %nanmean  Voltage 
    hmMass2(id)        = nanmean(ALL_SOH.mass2(inday)); %nanmean  Voltage 
    hmMass3(id)        = nanmean(ALL_SOH.mass3(inday)); %nanmean  Voltage 
end

xtickval = [min(sertime):14:max(sertime)]; % define intervals for x values on plots



%% Sets up axes (Fig. 2)
figure(2);
clf;

xstep = .41;
ystep = .38;
xpos  = [0.05 0.55];
ypos  = [0.07 .57];
ax    = zeros(length(xpos),length(ypos));
for ix = 1:length(xpos)
    for iy = 1:length(ypos)
       ax(ix,iy) = axes('Position',[xpos(ix) ypos(iy) xstep ystep]);
       hold on;
    end
end
set(gcf, 'Position', get(0,'ScreenSize'));

    
%% Timing Plots

    plot(ax(1,1),sertime(hmTime_Error <= crit_timeerr),hmTime_Error(hmTime_Error <= crit_timeerr),'bo');
    hold on;
    plot(ax(1,1),sertime(hmTime_Error < -crit_timeerr),hmTime_Error(hmTime_Error < -crit_timeerr),'ro');
    hold on;
    plot(ax(1,1),sertime(hmTime_Error > crit_timeerr), hmTime_Error(hmTime_Error > crit_timeerr), 'ro');
    hold on;
        title(ax(1,1),'Timing Error',      'FontSize',14)
        xlabel(ax(1,1),'Date',             'FontSize',12)
        ylabel(ax(1,1),'Timimg Error (ns)','FontSize',12)
        xticks(ax(1,1),xtickval)
        datetick(ax(1,1),'x', ' mm/yy', 'keepticks')
        xlim(ax(1,1),[min(sertime) max(sertime)])
        set(ax(1,1),'Xminortick','on','Yminortick','on')
        set(ax(1,1),'FontName','Lucida Bright')
        
%% Timing Uncertainity and Time Quality -- Together

    [axyy, H_TUn, H_TQu] = plotyy(ax(1,2),...
                    sertime(hmTime_Un      <= crit_timeun),hmTime_Un(hmTime_Un          <= crit_timeun),...
                    sertime(hmTime_Quality >= crit_timeq),hmTime_Quality(hmTime_Quality >= crit_timeq));
    axes(axyy(1))
    hold on;
    
    axes(axyy(2))
    hold on;
    
    
    if any(hmTime_Un      > crit_timeun)
        plot(axyy(1),sertime(hmTime_Un      > crit_timeun),hmTime_Un(hmTime_Un          > crit_timeun), 'ro');
    end

    if any(hmTime_Quality >= crit_timeq)
        plot(axyy(2),sertime(hmTime_Quality < crit_timeq),hmTime_Quality(hmTime_Quality < crit_timeq), 'ro');
    end
    
        title(axyy(1),'Timing Uncertainity + Time Quality','FontSize',14)
        xlabel(axyy(1),'Date',                    'FontSize',12)
        ylabel(axyy(1),'Timing Uncertainity',           'FontSize',12)
        ylabel(axyy(2),'Time Quality',               'FontSize',12)
        xticks(axyy(1),xtickval)
        datetick(axyy(1),'x', 'mm/YY', 'keepticks')
        xlim(axyy([1,2]),[min(sertime) max(sertime)])
        set(axyy([1,2]),'Xminortick','on','Yminortick','on')
        set(axyy([1,2]),'FontName','Lucida Bright')
        set(axyy(2),'YColor','k')
        set(H_TUn, 'LineStyle','none','Marker','o','MarkerEdgeColor','b')
        set(H_TQu, 'LineStyle','none','Marker','o','MarkerEdgeColor','k')
    
%% Timing Status and Satalites -- Together

    [axyy, H_TS, H_Sat] = plotyy(ax(2,2),...
                    sertime(hmTime_Status >= crit_timestatus),hmTime_Status(hmTime_Status >= crit_timestatus),...
                    sertime(hmsat         >= crit_sat)       ,hmsat(hmsat                 >= crit_sat)       );
    axes(axyy(1))
    hold on;
    
    axes(axyy(2))
    hold on;
    
    
    if any(hmTime_Status < crit_timestatus)
        plot(axyy(1),sertime(hmTime_Status < crit_timestatus),hmTime_Status(hmTime_Status < crit_timestatus), 'ro');
    end

    if any(hmsat < crit_sat)
        plot(axyy(2),sertime(hm_sat < crit_sat),              hmsat(hmsat < crit_sat),                        'ro');
    end
    
        title(axyy(1),'Timing Status + Satalites','FontSize',14)
        xlabel(axyy(1),'Date',                    'FontSize',12)
        ylabel(axyy(1),'Timing Status',           'FontSize',12)
        ylabel(axyy(2),'Satalites',               'FontSize',12)
        xticks(axyy([1,2]),xtickval)
        datetick(axyy(1),'x', 'mm/YY', 'keepticks')
        xlim(axyy([1,2]),[min(sertime) max(sertime)])
        set(axyy([1,2]),'Xminortick','on','Yminortick','on')
        set(axyy([1,2]),'FontName','Lucida Bright')
        set(axyy(2),'YColor','k')
        set(H_TS, 'LineStyle','none','Marker','o','MarkerEdgeColor','b')
        set(H_Sat, 'LineStyle','none','Marker','o','MarkerEdgeColor','k')
        
%% Plot GPS Stuff -- Locking Status

    len = length(ALL_SOH.Lock);
    lock_status = ALL_SOH.Lock(1:len);

    [lock1,lock2,lock1_max,lock2_max] = lockstat(lock_status,len);
    
    time_lap = (ALL_SOH.Time(78123) - ALL_SOH.Time(1))/len; %seconds in between each measurement
    scaled_lock1_max = (lock1_max/time_lap)/3600; %hours since last locked
    
    plot(ax(2,1),ALL_SOH.Time(scaled_lock1_max <= crit_lock),scaled_lock1_max(scaled_lock1_max <= crit_lock),'bo');
    hold on;
    plot(ax(2,1),ALL_SOH.Time(scaled_lock1_max > crit_lock),scaled_lock1_max(scaled_lock1_max > crit_lock),'ro');
    hold on;
   
    title(ax(2,1),'Locking Status',      'FontSize',14)
    xlabel(ax(2,1),'Date',               'FontSize',12)
    ylabel(ax(2,1),'Time Since Locked (hours)','FontSize',12)
    xticks(ax(2,1),xtickval)
    datetick(ax(2,1),'x', ' mm/yy', 'keepticks')
    xlim(ax(2,1),[min(sertime) max(sertime)])
    set(ax(2,1),'Xminortick','on','Yminortick','on')
    set(ax(2,1),'FontName','Lucida Bright')
    
%% Link axes (Fig. 2)    
linkaxes(ax,'x')

%% overall title - station name etc. (Fig. 2)
titlename = ['Timing Plots for',' ', ALL_SOH.sta,' '];
htit = suptitle(titlename);
set(htit,'fontweight','bold','fontsize',20,'fontname','Lucida Bright')
hfig = gcf;


%% Sets up axes (Fig. 3)
figure(3);
clf;

xstep = .90;
ystep = .15;
xpos  = [0.05];
ypos  = [0.07 .31 .55 .79];
ax    = zeros(length(xpos),length(ypos));
for ix = 1:length(xpos)
    for iy = 1:length(ypos)
       ax(ix,iy) = axes('Position',[xpos(ix) ypos(iy) xstep ystep]);
       hold on;
    end
end
set(gcf, 'Position', get(0,'ScreenSize'));

%% Plot for Mass Positions
    plot(ax(1,1),sertime(hmMass1 <= crit_mass),hmMass1(hmMass1 <= crit_mass),'bo');
    hold on;
    plot(ax(1,1),sertime(hmMass1 < -crit_mass),hmMass1(hmMass1 < -crit_mass),'ro');
    hold on;
    plot(ax(1,1),sertime(hmMass1 > crit_mass) ,hmMass1(hmMass1 > crit_mass) ,'ro');
    hold on;
    
    G = gradient(hmMass1);
    hmMass1(isnan(hmMass1)) = nanmean(hmMass1);
    G(isnan(G))             = nanmean(G);
    
    plot(ax(1,1),sertime(G >= 100000) ,hmMass1(G >= 100000) ,'rs','MarkerSize',30);
    plot(ax(1,1),sertime(G <= -100000),hmMass1(G <= -100000),'rs','MarkerSize',30);

        title(ax(1,1),'Mass Positions','FontSize',14)
        xlabel(ax(1,1),'Date',          'FontSize',12)
        ylabel(ax(1,1),'Voltage (\muV)','FontSize',12)
        xticks(ax(1,1),xtickval)
        datetick(ax(1,1),'x', 'mm/yy', 'keepticks')
        xlim(ax(1,1),[min(sertime) max(sertime)])
        plot(ax(1,1),sertime,hmMass2,'g*')
        plot(ax(1,1),sertime,hmMass3,'k*')
        %legend(ax(1,1),{'Mass1','Mass2','Mass3'}) % uncomment if mult mass
        set(ax(1,1),'Xminortick','on','Yminortick','on')
        set(ax(1,1),'FontName','Lucida Bright')
    
%% Plot for Voltage
    plot(ax(1,2),sertime(hmSupply_Volt >= crit_volt),hmSupply_Volt(hmSupply_Volt >= crit_volt),'bo');
    hold on;
    plot(ax(1,2),sertime(hmSupply_Volt < crit_volt), hmSupply_Volt(hmSupply_Volt < crit_volt), 'ro');
    hold on;

        title(ax(1,2),'Supply Voltage',     'FontSize',14)
        xlabel(ax(1,2),'Date',              'FontSize',12)
        ylabel(ax(1,2),'Supply Voltage (V)','FontSize',12)
        xticks(ax(1,2),xtickval)
        datetick(ax(1,2),'x', 'mm/yy', 'keepticks')
        xlim(ax(1,2),[min(sertime) max(sertime)])
        set(ax(1,2),'Xminortick','on','Yminortick','on')
        set(ax(1,2),'FontName','Lucida Bright')
    
%% Plot for Current
    plot(ax(1,3),sertime(hmCurrent <= crit_current),hmCurrent(hmCurrent <= crit_current),'bo');
    hold on;
    plot(ax(1,3),sertime(hmCurrent > crit_current), hmCurrent(hmCurrent > crit_current), 'ro');
    hold on;
        title(ax(1,3),'Current',      'FontSize',14)
        xlabel(ax(1,3),'Date',        'FontSize',12)
        ylabel(ax(1,3),'Current (mA)','FontSize',12)
        xticks(ax(1,3),xtickval)
        datetick(ax(1,3),'x', 'mm/yy', 'keepticks')
        xlim(ax(1,3),[min(sertime) max(sertime)])
        set(ax(1,3),'Xminortick','on','Yminortick','on')
        set(ax(1,3),'FontName','Lucida Bright')
         
%% Plots for Temperature
    plot(ax(1,4),sertime(hmTemp <= warn_temp),hmTemp(hmTemp <= warn_temp),'bo');
    hold on;
    plot(ax(1,4),sertime(hmTemp > warn_temp), hmTemp(hmTemp > warn_temp), 'oo');
    hold on;
    plot(ax(1,4),sertime(hmTemp > crit_temp), hmTemp(hmTemp > crit_temp), 'ro');
    hold on;
        title(ax(1,4),'Temperature',           'FontSize',14)
        xlabel(ax(1,4),'Date',                 'FontSize',12)
        ylabel(ax(1,4),'Temperature (Celsius)','FontSize',12)
        xticks(ax(1,4),xtickval)
        datetick(ax(1,4),'x', 'mm/yy', 'keepticks')
        xlim(ax(1,4),[min(sertime) max(sertime)])
        set(ax(1,4),'Xminortick','on','Yminortick','on')
        set(ax(1,4),'FontName','Lucida Bright')
    
%% Link axes (Fig. 3)     
linkaxes(ax,'x')

%% overall title - station name etc. (Fig. 3)
titlename = ['Environment Plots for',' ', ALL_SOH.sta,' '];
htit = suptitle(titlename);
set(htit,'fontweight','bold','fontsize',20,'fontname','Lucida Bright')
hfig = gcf;


    
    
    
    
    