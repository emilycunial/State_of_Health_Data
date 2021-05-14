function All_DeploySOH = Concat_SOH(SOH)

%% initialise all-time vectors of soh fields
utc=[];
supvolt =[];
cur = [];
temp =[];
lat =[];
lon =[];
elev =[];
gnss =[];
sats =[];
timestat =[];
lock =[];
timeun =[];
timeerr =[];
timequal =[];
v1 =[];
v2 =[];
v3 =[];
ext1 =[];
ext2 =[];
ext3 =[];

badval = NaN;

fprintf('  Concatenating daily SOH data... '); tic

Ny = length(SOH.yrs);
for iy=1:Ny
    ystr = num2str(SOH.yrs(iy),'%04.f');
    Nm = SOH.(['yyyy',ystr])(1).Nm;
    for im=1:Nm
        mstr = num2str(SOH.(['yyyy',ystr])(1).mos(im),'%02.f');
        intStr = SOH.(['yyyy',ystr])(1).(['mm',mstr]);        
        for id = 1:length(SOH.(['yyyy',ystr]).(['mm',mstr]).days)
            dstr = num2str(intStr.days(id),'%02.f');
            daydat = SOH.(['yyyy',ystr])(1).(['mm',mstr]).(['dd',dstr]);
            
            % calculate day start time in serial time format
            serial_t0_day = datenum([ystr mstr dstr '00' '00' '00'],'yyyymmddHHMMSS');
            % insert this if no time data
            if ~iscell(daydat.timeUTC(:)) && isnan(daydat.timeUTC(:))
                daydat.timeUTC(:) = serial_t0_day;
            end
%             if isempty(fieldnames(daydat)) % daydat is empty, so no info for that day...
%             end
            
            
            try % if there is data for this day, concatenate into soh fields
                utc =    [utc       ; datenum(daydat.timeUTC(:))];
                sats =    [sats       ; daydat.Sats(:)];
                supvolt =[supvolt   ; daydat.Supply_Voltage(:)];
                cur =    [cur       ; daydat.Current(:)];
                temp =   [temp      ; daydat.Temp(:)];
                lat =    [lat       ; daydat.Lat(:)];
                lon =    [lon       ; daydat.Lon(:)];
                elev =   [elev      ; daydat.Elev(:)];
                gnss =   [gnss      ; daydat.GNSS(:)];
                timestat=[timestat  ; daydat.Time_Status(:)];
                lock =   [lock      ; daydat.Lock(:)];
                timeun = [timeun    ; daydat.Time_Uncert(:)];
                timeerr =[timeerr   ; daydat.Time_Error(:)];
                timequal=[timequal  ; daydat.Time_Quality(:)];
                v1 =     [v1        ; daydat.mass1(:)];
                % check if Compact (only 1 mass reported)
                if ~isempty(daydat.mass2(:))                    
                    v2 =     [v2        ; daydat.mass2(:)];
                    v3 =     [v3        ; daydat.mass3(:)];
                else % stick in nans if so
                     v2 =     [v2        ; nan(length(daydat.mass1(:)),1)];
                     v3 =     [v3        ; nan(length(daydat.mass1(:)),1)];
                end
                
                ext1 =   [ext1      ; daydat.Ext1(:)];
                ext2 =   [ext2      ; daydat.Ext2(:)];
                ext3 =   [ext3      ; daydat.Ext3(:)];
            catch % put in correct time but junk in the soh values
                utc =    [utc       ; serial_t0_day];
                sats =    [sats       ; badval];
                supvolt =[supvolt   ; badval];
                cur =    [cur       ; badval];
                temp =   [temp      ; badval];
                lat =    [lat       ; badval];
                lon =    [lon       ; badval];
                elev =   [elev      ; badval];
                gnss =   [gnss      ; badval];
                timestat=[timestat  ; badval];
                lock =   [lock      ; badval];
                timeun = [timeun    ; badval];
                timeerr =[timeerr   ; badval];
                timequal=[timequal  ; badval];
                v1 =     [v1        ; badval];
                v2 =     [v2        ; badval];
                v3 =     [v3        ; badval];
                ext1 =   [ext1      ; badval];
                ext2 =   [ext2      ; badval];
                ext3 =   [ext3      ; badval];
            end
        end % loop on days
    end % loop on mos
end % loop on years

%% Insert into new structure
All_DeploySOH.Time = utc;
All_DeploySOH.Sat = sats;
All_DeploySOH.Supply_Voltage = supvolt;
All_DeploySOH.Current = cur;
All_DeploySOH.Temp = temp;
All_DeploySOH.Lat = lat;
All_DeploySOH.Lon = lon;
All_DeploySOH.Elev = elev;
All_DeploySOH.GNSS = gnss;
All_DeploySOH.Time_Status = timestat;
All_DeploySOH.Lock = lock;
All_DeploySOH.Time_Uncertainty = timeun;
All_DeploySOH.Time_Error = timeerr;
All_DeploySOH.Time_Quality = timequal;
All_DeploySOH.mass1 = v1;
All_DeploySOH.mass2 = v2;
All_DeploySOH.mass3 = v3;
All_DeploySOH.Ext1 = ext1;
All_DeploySOH.Ext2 = ext2;
All_DeploySOH.Ext3 = ext3;

All_DeploySOH.sta = SOH.sta;

fprintf(' done (%.1fs)\n',toc)


end
