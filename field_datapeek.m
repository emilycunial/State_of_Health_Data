clear all
close all

%% Give top level directory for data card
% This will probably be just /Volumes/Untitled
topdir = '/Volumes/Emily_Data/SR.G1C3'; % no need for final slash
addpath '/Volumes/Emily_Data/SOH_Centaur_Eval/mattaup'
addpath '/Volumes/Emily_Data/SOH_Centaur_Eval/matguts'
addpath '/Volumes/Emily_Data/SOH_Centaur_Eval/IRIS'

delsac = false; % option to delete SAC files that are made in this dir


%% give station coordinates
slat = 34.69795;
slon = -120.04044;

%% Loop through quakes

load('/Volumes/Emily_Data/SOH_Centaur_Eval/IRIS/events.mat')

%events_info = (['SR.G4H1.centaur-3_4311_20200720_000000.miniseed', events_info])
    
%for orid = 1:length(events_info)
for orid = 1
    clear eqar;
    elat = events_info(orid).PreferredLatitude;
    elon = events_info(orid).PreferredLongitude;
    edep = events_info(orid).PreferredDepth;
    evtimestr = events_info(orid).PreferredTime;
    eqmag  = events_info(orid).PreferredMagnitudeValue;

    eqar.elat = elat;
    eqar.elon = elon;
    eqar.edep = edep;
    eqar.evtimestr = evtimestr;
    eqar.eqmag = eqmag;
     

    % no need to change these here
    filtfs = [0.01 0.5];
    viewwind = [-100 2000];% default window to view in seconds from event time
    bigwind = [-500 3500]; % window to subset in seconds from event time

    %% preamble
    addpath('matguts');
    spd = 24*3600;

    [data] = make_data_date_struct(topdir);

    %% parse into allfiles
    Ndf = 0; % number of data files
    dfs = {}; % names of data files
    dps = {}; % paths to data files
    serialstarts = []; % serial start times for each file
    for iy = 1:length(data.yrs)
        ystr = num2str(data.yrs(iy),'%04.f');

        for im = 1:data.(['yyyy',ystr])(1).Nm
            mstr = num2str(data.(['yyyy',ystr]).mos(im),'%02.f');
            modat = data.(['yyyy',ystr])(1).(['mm',mstr]);
            Ndf = Ndf + length(modat.datfiles);
            dfs = cat(1,dfs,modat.datfiles);
            dps = cat(1,dps,modat.fpath);
            serialstarts = cat(1,serialstarts,modat.serialstart);
        end; clear im
    end; clear iy

    %% Predict EQ times
    [gcarc,seaz] = distance(slat,slon,elat,elon);
    tpt = tauptime('deg',gcarc,'dep',edep);
    evtime = datenum(evtimestr);
    arrtime = tpt(1).time/spd + evtime;
    t0 = arrtime + bigwind(1)/spd; % start of window to request 
    t1 = arrtime + bigwind(2)/spd; % end of window to request (surface waves gone at least 180deg)
    
    sks_id = strcmp('SKS',[{tpt.phase}]);
    skstime = tpt(sks_id).time;
    sks0 = skstime - 30/spd;
    sks1 = skstime + 30/spd;

    % find data file(s)
    fid0 = find(serialstarts<t0,1,'last');
    fid1 = find(serialstarts<t1,1,'last');
    fid2read = fid0:fid1;
    for idf = 1:length(fid2read)
        dfile = [dps{fid2read(idf)},'/',dfs{fid2read(idf)}];
        % Use mseed2sac to make a sac file in the current directory
        system(sprintf('/Volumes/Emily_Data/mseed2sac-master/mseed2sac -O %s',dfile));
        sacfiles = dir([data.nwk,'.',data.sta,'*.SAC']);
        sfileinfo = parse_sac_filename({sacfiles.name}');
    
        for icsf = 1:length(sfileinfo)
            % Uses sacpc2mat to extract data + metadata from SAC file
            [SACdata(icsf),seisdat{icsf},~]=sacpc2mat(sacfiles(icsf).name);
            if delsac
                fprintf('Deleting SAC file %s\n',sacfiles(icsf).name);
                delete(sacfiles(icsf).name);
            end
            [ST(icsf),fstarttime(icsf)] = parse_timing(SACdata(icsf).event);
            dt = round(SACdata(icsf).times.delta,4);
            t0i = round(SACdata(icsf).times.b,2);
            t1i = round(SACdata(icsf).times.e,2);
            tti{icsf} = [t0i:dt:t1i]';
            if length(tti{icsf})~=SACdata(icsf).trcLen, error('mismatch of times and samples'); end
        end
        % find which chan is which (search second char in chan name + chstr)
        icn = find(contains({sfileinfo.chan},[sfileinfo(1).chan(2),'N'])); 
        ice = find(contains({sfileinfo.chan},[sfileinfo(1).chan(2),'E']));
        icz = find(contains({sfileinfo.chan},[sfileinfo(1).chan(2),'Z']));
        % insert data as ENZ
        tt = [0:dt:spd-dt]';
        dat = nan(length(tt),3);
        chord = [ice,icn,icz];
        for ic = 1:3
            ttins = tt>=tti{ic}(1) & round(tt-tti{ic}(end),3)<=0;
            dat(ttins,ic) = seisdat{chord(ic)};
        end
        tt = tt/spd + fstarttime(icsf);
        % dat = [seisdat{ice},seisdat{icn},seisdat{icz}];
        % tt(:,icsf) = fstarttime(icsf) + [0:(SACdata(icsf).trcLen-1)]'*dt./spd;
    end


    eqar.dat = dat(:,:);
    eqar.tt = tt;
    eqar.dt = dt;
    eqar.slat = slat;
    sqar.slon = slon;
    
    save(['/Volumes/Emily_Data/evdata/', events_info(orid).PreferredTime([1:10]),'_',...
        events_info(orid).PreferredTime([12:13]),'_',events_info(orid).PreferredTime([15:16]),...
        '_',events_info(orid).PreferredTime([18:19])], 'eqar');
    
end


%% isolate data around event
inwin = ((tt-evtime)*spd >= bigwind(1)) & ((tt-evtime)*spd < bigwind(2));
ttw = tt(inwin,:);
datw = dat(inwin,:);

inwin_sks = ((tt-evtime)*spd >= sks0) & ((tt-evtime)*spd < sks1);
ttw_sks = tt(inwin_sks,:);
datw_sks = dat(inwin_sks,:);
%% Get radial and transverse chans
datZRT = zne2zrt( datw(:,[3,2,1]), seaz );
datZNERTw = [datw,datZRT(:,2:3)];

% %% spectrogram
% figure(86);
% spectrogram(datZNERTw(:,3),'yaxis')

%% dynamic waveform plot
plot_data_dynamic(datZNERTw,dt,evtimestr,gcarc,seaz,edep)


