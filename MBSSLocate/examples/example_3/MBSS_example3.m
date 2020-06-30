% File MBSS_example3.m
%
% Script example to  :
%    - Compute a simulated mixture of two static sources recorded by a
%    microphone array of 8 microphones with the help of Roomsimove toolbox ;
%    - Apply multi-channel BSS Locate algorithm on the mixture to estimate 
%    source directions;
%    - Evaluate localization results between estimated angle and ground
%    truth (Recall, Precision, F-measure, Accuracy).
%
% Version : v2.0
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2018 Ewen Camberlein and Romain Lebarbenchon
% This software is distributed under the terms of the GNU Public License
% version 3 (http://www.gnu.org/licenses/gpl.txt)
% If you find it useful, please cite the following reference:
% http://bass-db.gforge.inria.fr/bss_locate/
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
close all;

%% Add tools to path
addpath(genpath('./../../localization_tools/'));
addpath('./../../evaluation_tools/');
addpath('./../../roomsimove_tools/');
addpath('./wav files/');

%% Audio Scene parameters
[roomStruct,sensorsStruct,sourcesStruct,sceneTimeStamps] = MBSS_audioScene_parameters(); % audio scene definition
nsrcMixture = length(sourcesStruct); % Number of Sources

%% Microphone parameters
micPos          = sensorsStruct.sensor_xyz.';
isArrayMoving   = false; % The microphone array is static
subArray        = [];    % []: all microphones are used

%% MBSS Locate core Parameters
angularSpectrumMeth        = 'GCC-PHAT';  % Local Angular spectrum method {'GCC-PHAT' 'GCC-NONLIN' 'MVDR' 'MVDRW' 'DS' 'DSW' 'DNM' 'MUSIC'}
pooling                    = 'max';       % Pooling method {'max' 'sum'}
applySpecInstNormalization = 0;           % 1: Normalize instantaneous local angular spectra - 0: No normalization
% Search space
azBound                    = [-179 180];  % Azimuth search boundaries (°)
elBound                    = [-90 90];    % Elevation search boundaries (°)
gridRes                    = 1;           % Resolution (°) of the global 3D reference system {theta (azimuth),phi (elevation)}
alphaRes                   = 5;           % Resolution (°) of the 2D reference system defined for each microphone pair
% Multiple sources parameters
nsrce                      = nsrcMixture; % Number of sources to be detected
minAngle                   = 10;          % Minimum angle between peaks
% Moving sources parameters
blockDuration_sec          = 0.512;       % Block duration in seconds (default []: one block for the whole signal)
blockOverlap_percent       = 0;           % Requested block overlap in percent (default []: No overlap) - is internally rounded to suited values
% Wiener filtering
enableWienerFiltering       = 0;          % 1: Process a Wiener filtering step in order to attenuate / emphasize the provided excerpt signal into the mixture signal. 0: Disable Wiener filtering
wienerMode                  = [];         % Wiener filtering mode {'[]' 'Attenuation' 'Emphasis'}
wienerRefSignal             = [];         % Excerpt of the source(s) to be emphasized or attenuated
% Display results
specDisplay                = 1;           % 1: Display angular spectrum found and sources directions found - 0: No display
% Other parameters
speedOfSound               = 343;         % Speed of sound (m.s-1) - typical value: 343 m.s-1 (assuming 20°C in the air at sea level)
fftSize_sec                = [];          % FFT size in seconds (default []: 0.064 sec)
freqRange                  = [];          % Frequency range to aggregate the angular spectrum : [] means no specified range
% Debug
angularSpectrumDebug       = 0;          % Flag to enable additional plots to debug the angular spectrum aggregation

%% Evaluation Parameters
evalMode       = 'cartesian'; % Evaluation mode: 'cartesian', 'az_only', 'el_only' or 'curvilinear'
angleThreshold = 10;          % Maximum error between estimated and reference angle for results evaluation (Recall, Precision, F-measure)

%% Generate a 16 kHz simulated mixture with roomsimove
% Sampling frequency of generated mixture file
fs = 16000;

% Call roomsimove toolbox
simg = [];    % Sources images
fprintf('Mixture generation (%d sources)\n',nsrcMixture);

for i = 1:nsrcMixture
    fprintf(' - Generation of source %d / %d image\n',i,nsrcMixture);
    
    [s,fsFile] = audioread(sourcesStruct(i).filename);
    % Downsampling signal to 16kHz if necessary
    if (fsFile > fs)
        [q,p] = rat(fs/fsFile);
        s = resample(s,q,p);
    elseif (fsFile < fs)
        error('[MBSS_example2.m error] wav file sampling frequency is below 16kHz : Upsampling the signal is not allowed');
    end
    % Truncate audio signal if needed (the shortest file duration is used as audioscene mixture duration)
    s=s(1:sourcesStruct(i).ptime(end)*fs,:);
    % Generate room filter
    [time,HH] = MBSS_roomsimove(fs,roomStruct.room_size,roomStruct.F_abs',roomStruct.A',sensorsStruct.sensor_xyz',sensorsStruct.sensor_off',sensorsStruct.sensor_type,sourcesStruct(i).ptime,sourcesStruct(i).source_xyz);
    % Compute source image
    simg = cat(3,simg,MBSS_roomsimove_apply(time,HH,s',fs));
end

% Generate mixture : mean of source images
x = squeeze(mean(simg,3)).';

%% Convert algorithm parameters to MBSS structures
sMBSSParam = MBSS_InputParam2Struct(angularSpectrumMeth,speedOfSound,fftSize_sec,blockDuration_sec,blockOverlap_percent,pooling,azBound,elBound,gridRes,alphaRes,minAngle,nsrce,fs,applySpecInstNormalization,specDisplay,enableWienerFiltering,wienerMode,freqRange,micPos,isArrayMoving,subArray,sceneTimeStamps,angularSpectrumDebug);

%% Run the localization
fprintf('\nLocalization processing\n');
[azEst, elEst, block_timestamps,elaps_time,~] = MBSS_locate_spec(x,wienerRefSignal,sMBSSParam);

%% Results evaluation
% Define the reference srcPos matrix
srcPos = zeros(3,nsrcMixture);
for i = 1:nsrcMixture
    srcPos(:,i) = sourcesStruct(i).source_xyz(:,1);
end

fprintf('\nResults evaluation\n');
MBSS_eval(evalMode,angleThreshold,sMBSSParam.arrayCentroid,srcPos,azEst,elEst,block_timestamps);
