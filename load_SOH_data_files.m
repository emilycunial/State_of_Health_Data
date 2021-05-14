function [SOH] = load_SOH_data_files(SOH,topdir)
% [SOH] = load_SOH_data_files(SOH,topdir)
% 
% Function to load csv data files and parse them into the SOH structure

%% SOH field and csv column headings
% lhs is the field name to go into SOH, right is the csv column header

% "instrument"
inst_dat = {'Supply_Voltage', 'Supply_Voltage'
            'Current',        'Current'
            'Temp',           'Temp'};
        
time_dat = {'timeUTC',        'UTC' %UTC from time data
            'Lat',            'Lat' %latitudes
            'Lon',            'Lon' %Longitudes
            'Elev',           'Elev' %Elevation
            'GNSS',           'GNSS' %GNSS
            'Sats',           'Satellites' %Number satellites
            'Lock',           'Phase_Lock' %Phase Locking
            'Time_Status',    'Timing_Status' %Timing Status
            'Time_Uncert',    'Time_uncertainty' %Uncertainty in Time
            'Time_Quality',   'Timing_Quality' %Time Quality
            'Time_Error',     'Timing_Error'}; %Error in timing

env_dat =  {'mass1',          'Vol_A1' %mass 1
            'mass2',          'Vol_A2' %mass 2
            'mass3',          'Vol_A3' %mass 3
            'Ext1',           'Ext_SOH1' %external voltage 1
            'Ext2',           'Ext_SOH2' %external voltage 2
            'Ext3',           'Ext_SOH3'}; %external voltage 3
         
fprintf('  Loading SOH data from files... '); tic

% directory delimiters for mac or pc
if ismac
    ddlm ='/'; 
elseif ispc
    ddlm = '\';
end

%% Loop over all files (years, months, days)
Ny = length(SOH.yrs); % N years of data
for iy = 1:Ny
    
    ystr = num2str(SOH.yrs(iy),'%04.f');
    Nm = SOH.(['yyyy',ystr]).Nm; % N months of data this year
    
    for im = 1:Nm
        
        mstr = num2str(SOH.(['yyyy',ystr]).mos(im),'%02.f');
        ymdir = [topdir,ddlm,ystr,ddlm,mstr,ddlm,'soh']; % directory for year and mo
        Nd = length(SOH.(['yyyy',ystr]).(['mm',mstr]).days);
        
        for id = 1:Nd
            dstr = sprintf('%02.0f',id);

            %% Set up file names
            temp_csv = dir([ymdir,ddlm,SOH.sta,'*',ystr,mstr,dstr,'*','0.csv']);
                kill = [];for jj = 1:length(temp_csv), if strcmp(temp_csv(jj).name(1),'.'), kill(jj) = 1; else kill(jj) = 0; end; end
                temp_csv = temp_csv(~kill);
                csv = [temp_csv.folder,ddlm,temp_csv.name];

            temp_csv1 = dir([ymdir,ddlm,SOH.sta,'*',ystr,mstr,dstr,'*','0.csv_1']);
                kill1 = [];for jj = 1:length(temp_csv1), if strcmp(temp_csv1(jj).name(1),'.'), kill1(jj) = 1; else kill1(jj) = 0; end; end
                temp_csv1 = temp_csv1(~kill1);
                csv1 = [temp_csv1.folder,ddlm,temp_csv1.name];


            temp_csv2 = dir([ymdir,ddlm,SOH.sta,'*',ystr,mstr,dstr,'*','0.csv_2']);
                kill2 = [];for jj = 1:length(temp_csv2), if strcmp(temp_csv2(jj).name(1),'.'), kill2(jj) = 1; else kill2(jj) = 0; end; end
                temp_csv2 = temp_csv2(~kill2);
                csv2 = [temp_csv2.folder,ddlm,temp_csv2.name];

            %% import data in each file
            % attempt to load soh csv file #0
            if ~isempty(csv) && ~isempty(temp_csv)
                try 
                    csv_rawdat = importdata(csv);%gets data from csv
                    n1 = size(csv_rawdat.textdata,2);%size cell 
                    if n1 >= 9
                        time_dat_raw = csv_rawdat;
                    elseif  n1 == 5
                        inst_dat_raw = csv_rawdat;
                    elseif  n1 == 8
                        env_dat_raw = csv_rawdat;
                    else 
                        error('wrong file type?')
                    end
                catch
                    fprintf('Error - no file %s \n',csv)
                end
            end

            % attempt to load soh csv file #1
            if ~isempty(csv1) && ~isempty(temp_csv1)
                try 
                    csv_rawdat1 = importdata(csv1);%gets data from csv
                    n2 = size(csv_rawdat1.textdata,2);%size cell 
                    if n2 >= 9
                        time_dat_raw = csv_rawdat1;
                    elseif  n2 == 5	
                        inst_dat_raw = csv_rawdat1;
                    elseif  n2 == 8
                        env_dat_raw = csv_rawdat1;
                    else 
                        error('wrong file type?')
                    end
                catch
                    fprintf('Error - no file %s \n',csv1)
                end
            end

            % attempt to load soh csv file #2
            if ~isempty(csv2) && ~isempty(temp_csv2)
                try
                    csv_rawdat2 = importdata(csv2);%gets data from csv
                    n3 = size(csv_rawdat2.textdata,2);%size cell 
                    if n3 >= 9
                        time_dat_raw = csv_rawdat2;
                    elseif  n3 == 5
                        inst_dat_raw = csv_rawdat2;
                    elseif  n3 == 8
                        env_dat_raw = csv_rawdat2;
                    else 
                        error('wrong file type?')
                    end
                catch
                        fprintf('Error - no file %s \n',csv2)
                end
            end

            %% Parse data into SOH structure
            % parse time data
            if exist('time_dat_raw','var') 
                timedata = SOH_time_parse(time_dat_raw);
                for iff = 1:size(time_dat,1)
                    SOH.(['yyyy',ystr]).(['mm',mstr]).(['dd',dstr]).(time_dat{iff,1}) = timedata.(time_dat{iff,2});
                end
            else
                for iff = 1:size(time_dat,1)
                    SOH.(['yyyy',ystr]).(['mm',mstr]).(['dd',dstr]).(time_dat{iff,1}) = nan;
                end
            end
            
            % parse instrument data
            if exist('inst_dat_raw','var')
                instdata = SOH_inst_parse(inst_dat_raw);
                for iff = 1:size(inst_dat,1)
                    SOH.(['yyyy',ystr]).(['mm',mstr]).(['dd',dstr]).(inst_dat{iff,1}) = instdata.(inst_dat{iff,2});
                end
            else
                for iff = 1:size(inst_dat,1)
                    SOH.(['yyyy',ystr]).(['mm',mstr]).(['dd',dstr]).(inst_dat{iff,1}) = nan;
                end
            end

            %env
            if exist('env_dat_raw','var')
                envdata = SOH_env_parse(env_dat_raw);
                for iff = 1:size(env_dat,1)
                    SOH.(['yyyy',ystr]).(['mm',mstr]).(['dd',dstr]).(env_dat{iff,1}) = envdata.(env_dat{iff,2});
                end
            else
                for iff = 1:size(env_dat,1)
                    SOH.(['yyyy',ystr]).(['mm',mstr]).(['dd',dstr]).(env_dat{iff,1}) = nan;
                end
            end

             %% Clean up
            % Clear all to ensure no double counting
            clear env
            clear inst
            clear times
            clear envlist
            clear timelist
            clear instlist
                

        end % loop on days        
    end % loop on months
end % loop on years

fprintf(' done (%.1fs)\n',toc)


end % function

