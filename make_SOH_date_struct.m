function [SOH] = make_SOH_date_struct(topdir)
% [SOH] = make_SOH_date_struct(topdir)
%
% Function to establish directory structure and file locations for SOH
% information in monthly directories

fprintf('  Making SOH data structure... '); tic

% directory delimiters for mac or pc
if ismac
    ddlm ='/'; 
elseif ispc
    ddlm = '\';
end


SOH(1).sta = fliplr(strtok(fliplr(topdir),ddlm));


%%% years

temp = dir(topdir);
if isempty(temp)
    error('no data in topdir')
end

%
isyr = false(length(temp),1); %Creates a logical structure for years.
for ii = 1:length(temp) %Runs through names from top directory
        if strcmp(temp(ii).name(1),'.'), continue; end %skips name with'.'
        if length(temp(ii).name)~=4, continue; end %skips names not length 4
        isyr(ii) = true; % if both ifs satisfied than entry is 1.
        %indicates that the entry ii corresponds to a year
end

tempy = {temp(isyr).name}; % creates a cell for unique yrs from logical isyr
Ny = length(tempy); % number of years
for iy = 1:Ny %initiates creating a data structure (empty) for each year
    SOH(1).yrs(iy,1) = str2num(tempy{iy});
    SOH(1).(['yyyy',tempy{iy}]) = struct();
end

%%% months
for iy = 1:Ny
    ystr = num2str(SOH.yrs(iy));
    
    temp = dir([topdir,ddlm,ystr]); %files within the year folder for year iy
    
    ismo = false(length(temp),1); % Creates a logical structure for months
    for ii = 1:length(temp) % loops over number of files in year iy
            if strcmp(temp(ii).name(1),'.'), continue; end %skips name with'.'
            if length(temp(ii).name)>2, continue; end % skips name longer than 2
            ismo(ii) = true; % Both ifs satisfied than ii ismo = 1
    end
    tempm = {temp(ismo).name}; %cell of unique months for year iy
    Nm = length(tempm);
    SOH.(['yyyy',ystr])(1).Nm = Nm;
    for im = 1:Nm
        SOH.(['yyyy',ystr]).mos(im,1) = str2num(tempm{im});
        SOH.(['yyyy',ystr]).(['mm',tempm{im}]) = struct();
    end

end

%%% Days
for iy=1:Ny
    ystr = num2str(SOH.yrs(iy),'%04.f');
    Nm = SOH.(['yyyy',ystr]).Nm;

    for im = 1:Nm
        mstr = num2str(SOH.(['yyyy',ystr]).mos(im),'%02.f');
        temp = dir([topdir,ddlm,ystr,ddlm,mstr,ddlm,'soh']);
        isCSV = false(length(temp),1);
        
        for ii = 1:length(temp) % loops over number of files in year iy
            if strcmp(temp(ii).name(1),'.'), continue; end % skips name with'.'
            isCSV(ii) = true; 
        end

        for ii = 1:length(temp) % loops over number of files in year iy
            if strcmp(temp(ii).name(1),'.'), continue; end %s kips name with'.'

            tempn = {temp(isCSV).name};
            tempf = {temp(isCSV).folder};
            Nf = length(tempn);
            SOH.(['yyyy',ystr]).(['mm',mstr])(1).Nf = Nf;
            SOH.(['yyyy',ystr]).(['mm',mstr])(1).csvfiles = {tempn{:}}';
            SOH.(['yyyy',ystr]).(['mm',mstr])(1).fpath = {tempf{:}}';
        end

        % Days?
        temp = dir([topdir,ddlm,ystr,ddlm,mstr,ddlm,'soh']);
        isdy = false(length(temp),1);

        for ii = 1:length(temp) % loops over number of files in year iy
            if strcmp(temp(ii).name(1),'.'), continue; end %skips name with'.'
            if temp(ii).date(1:2) == temp(ii-1).date(1:2), continue;end
            isdy(ii) = true;
        end
        
%         tempd = temp(isdy);
        days30 = [4 6 9 11];
        days31 = [1 3 5 7 8 10 12];
        if ismember((SOH.(['yyyy',ystr]).mos(im)),days30) == 1
            numdays = 30;
        elseif ismember((SOH.(['yyyy',ystr]).mos(im)),days31) == 1
            numdays = 31;
        elseif SOH.(['yyyy',ystr]).mos(im) == 2
            if isleap(SOH.yrs(iy))==1
                numdays = 29;
            else
                numdays = 28;
            end
        end
        for id = 1:numdays
            dstr = sprintf('%02.0f',id);
            SOH.(['yyyy',ystr]).(['mm',mstr])(1).days(id,1) = id;
            SOH.(['yyyy',ystr]).(['mm',mstr]).(['dd',dstr]) = struct();
        end % day loop
        clear numdays id 
    end % month loop
    clear mstr temp
end % year loop

fprintf(' done (%.1fs)\n',toc)

end % on function

