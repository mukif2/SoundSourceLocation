% File MBSS_example2.m
%
% Script example to:
%  - Apply multi-channel BSS Locate algorithm on a real speaking mixture
%  corrupted by noise in order to estimate speaking source direction.
%  - Illustrate the effect of Wiener filtering for source localization in 
%  noisy environment with a known noise. To see this effect on the provided
%  example, apply or not Wiener filtering with the "applyWienerFiltering" 
%  variable.
% 
% Prerequisite :
%  - This example is based on data published in the voiceHome-2 corpus. In
%  order to use this example, you have to download the corpus first at
%  this location :
%  https://zenodo.org/record/1252143
%  Then, extract the corpus in provided "corpus" folder in the directory
%  where this script is located. If you want to extract the corpus in a
%  different location, just update the "corpusPath" variable.
%
% Version : v2.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2018 Ewen Camberlein and Romain Lebarbenchon
% This software is distributed under the terms of the GNU Public License
% version 3 (http://www.gnu.org/licenses/gpl.txt)
% If you find it useful, please cite the following reference:
% - Nancy Bertin, Ewen Camberlein, Romain Lebarbenchon, Emmanuel Vincent,
%   Sunit Sivasankaran, Irina Illina, Frédéric Bimbot
%   "VoiceHome-2, an extended corpus for multichannelspeech processing in
%    real homes", submitted to Speech Communication, Elsevier, 2017
%
% Contact : nancy.bertin[at]irisa.fr
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
close all;

%% Define voiceHome-2 corpus path
corpusPath = './corpus/voiceHome-2_corpus_1.0/'; % Path to voiceHome-2 corpus

%% ADD paths
addpath(genpath('./corpus_tools/')); % Corpus tools functions
addpath(genpath('./../../localization_tools/'));
addpath('./../../evaluation_tools/');

%% voiceHome-2 file settings
% Scenario choice
h           = 4;     % Home index
r           = 2;     % Room index
spk         = 2;     % Speaker index
pos         = 5;     % Speaker position index
noise       = 2;     % Noise index (for a given {h,r})
utt         = 2;     % Utterence index
% Fixed params (don't change these params)
nHouse      = 4;     % number of houses in the corpus (fixed)
nRoom       = 3;     % number of rooms per house (fixed)
nSpk        = 3;     % number of speakers per house (fixed)
nPos        = 5;     % number of speakers positions (fixed)
nNoise      = 4;     % number of noise conditions per room (fixed)
nUtt        = 2;     % number of utterances per {spk,pos,room,house,noise} (fixed)
geoId       = 1;     % probe geometry (fixed)
% Signal duration settings
nSecSpk     = NaN;   % Duration of the "Wake Up Word + Command" part => the true duration
offsetSpk   = [0 0]; % No offset
nSecNoise   = 4;     % Duration of the "noise only" part => 4 seconds
offsetNoise = 1;     % Let 1sec between the end of the "noise only" part and the "WUW + Command" part
% Other params
fs          = 16000; % Sampling frequency

%% Microphone position structure
[~,micPos]      = load_arrayGeo(corpusPath,geoId);
isArrayMoving   = false; % The microphone array is static
subArray        = [];    % []: all microphones are used
sceneTimeStamps = [];    % Both array and sources are statics => no time stamps

%% MBSS Locate core Parameters
% localization method
angularSpectrumMeth        = 'GCC-PHAT'; % Local Angular spectrum method {'GCC-PHAT' 'GCC-NONLIN' 'MVDR' 'MVDRW' 'DS' 'DSW' 'DNM' 'MUSIC'}
pooling                    = 'sum';      % Pooling method {'max' 'sum'}
applySpecInstNormalization = 0;          % 1: Normalize instantaneous local angular spectra - 0: No normalization
% Search space
azBound                    = [-179 180]; % Azimuth search boundaries (°)
elBound                    = [-90 90];   % Elevation search boundaries (°)
gridRes                    = 1;          % Resolution (°) of the global 3D reference system {theta (azimuth),phi (elevation)}
alphaRes                   = 5;          % Resolution (°) of the 2D reference system defined for each microphone pair
% Multiple sources parameters
nsrce                      = 2;          % Number of sources to be detected
minAngle                   = 15;         % Minimum angle between peaks
% Moving sources parameters
blockDuration_sec          = [];         % Block duration in seconds (default []: one block for the whole signal)
blockOverlap_percent       = 0;          % Requested block overlap in percent (default []: No overlap) - is internally rounded to suited values
% Wiener filtering
enableWienerFiltering      = 1;             % 1: Process a Wiener filtering step in order to attenuate / emphasize the provided excerpt signal into the mixture signal. 0: Disable Wiener filtering
wienerMode                 = 'Attenuation'; % Wiener filtering mode {'[]' 'Attenuation' 'Emphasis'} - In this example considered signal (noise) is attenuated in the mixture
wienerRefSignal            = [];            % Excerpt of the source(s) to be emphasized or attenuated - This variable is filled hereafter
% Display results
specDisplay                = 1;          % 1: Display angular spectrum found and sources directions found - 0: No display
% Other parameters
speedOfSound               = 343;        % Speed of sound (m.s-1) - typical value: 343 m.s-1 (assuming 20°C in the air at sea level)
fftSize_sec                = [];         % FFT size in seconds (default []: 0.064 sec)
freqRange                  = [];         % Frequency range to aggregate the angular spectrum : [] means no specified range
% Debug
angularSpectrumDebug       = 0;          % Flag to enable additional plots to debug the angular spectrum aggregation

%% Evaluation Parameters
evalMode       = 'cartesian'; % Evaluation mode: 'cartesian', 'az_only', 'el_only' or 'curvilinear'
angleThreshold = 10;          % Maximum error between estimated and reference angle for results evaluation (Recall, Precision, F-measure)

%% Convert algorithm parameters to MBSS structures
sMBSSParam = MBSS_InputParam2Struct(angularSpectrumMeth,speedOfSound,fftSize_sec,blockDuration_sec,blockOverlap_percent,pooling,azBound,elBound,gridRes,alphaRes,minAngle,nsrce,fs,applySpecInstNormalization,specDisplay,enableWienerFiltering,wienerMode,freqRange,micPos',isArrayMoving,subArray,sceneTimeStamps,angularSpectrumDebug);

%% Ground thruth processing
% Load array centroid position
[~,arrayCentroid,~] = load_arrayPos(corpusPath,h,r,geoId);
% Load speaker true position
[~,spkTruePos,~] = load_spkPos(corpusPath,h,r,spk,pos);
% Load noise true position
[~,noiseTruePos] = load_noisePos(corpusPath,h,r,noise,nRoom,nNoise);

% Define the srcPos matrix : the first source is the speaker position,
% the second is the noise position.
% srcPos is expressed into the room referential
srcPos = [spkTruePos',noiseTruePos'];

% sMicPosParam.arrayCentroid gives the microphone centroid position into the
% microphone array referential (i.e [0 0 0] if the eight microphones are 
% used, other value if a subarray is used).
% arrayCentroid from load_arrayPos() gives the position of the microphone
% array centroid (centroid of the 8 microphones) into the room referential.
% In order to use the same referential between srcPos and arrayCentroid, we
% have to express arrayCentroid into the room referential, that is done by
% summing the next two vectors.
arrayCentroid = arrayCentroid' + sMBSSParam.arrayCentroid;

% Compute azimuth and evelevation for reference sources (ground thruth)
% First az/el : spk
% Second az/el : noise
[azRef,elRef] = MBSS_true_aoa(arrayCentroid,srcPos);

%% Load wav files and run the localization
% Get file name
[fname,~] = getNoisyFileNames(h,r,spk,pos,noise,utt,nHouse,nRoom,nSpk,nPos,nNoise,nUtt);
% Load noisy speech part
y_noisy = wavOpening(corpusPath,fname,'noisy','wuw_cmd',offsetSpk,nSecSpk,fs);
% Load noise-only part
wienerRefSignal = wavOpening(corpusPath,fname,'noisy','noise_before',offsetNoise,nSecNoise,fs);

%% Run the localization
[azEst,elEst,block_timestamps,~,figHandle] = MBSS_locate_spec(y_noisy,wienerRefSignal,sMBSSParam);

% Update the output figures by plotting:
% - the noise true localization in yellow
% - the speaker true localization in green
if(figHandle ~= -1)
    for i=1:length(figHandle)
        figure(figHandle(i));
        hold on;
        plot(azRef(2),elRef(2),'*y','MarkerSize',20,'linewidth',1.5);
        plot(azRef(1),elRef(1),'*g','MarkerSize',20,'linewidth',1.5);
    end
end

%% Results evaluation
fprintf('\nResults evaluation\n');
MBSS_eval(evalMode,angleThreshold,arrayCentroid,srcPos,azEst,elEst,[],[]);