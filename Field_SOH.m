clear all
close all

%% Give top level directory for data card
% Set the desired file path, end with /station name (ex. /SR.G1C3)
topdir = '/Volumes/Emily_Data/SR.G1C3'; % no need for final slash after station name

delsac = false; % option to delete SAC files that are made in this dir
profile on
addpath = 'functions';

% station name

%% make data structure
SOH = make_SOH_date_struct(topdir);

%% load in the soh data
SOH = load_SOH_data_files(SOH,topdir);

%% Concatenate all data into column vectors
ALL_SOH = Concat_SOH(SOH);

%% Plot 
figure1 = Plot_ALL_Day(ALL_SOH);

profile viewer

%% plot one by one
% Plot_allcoord(ALL_SOH);
% Plot_allinst(ALL_SOH);
% Plot_alltime(ALL_SOH);
% Plot_allGPS(ALL_SOH);
