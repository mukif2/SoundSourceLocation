function [roomStruct,sensorsStruct,sourcesStruct,sceneTimeStamps] = MBSS_audioScene_parameters()

% Function MBSS_audioScene_parameters
%
% This function store and display audio scene parameters in dedicated 
% structures for mixture generation
%
% OUTPUT:
% roomStruct : struct, room parameters used in the roomsimove toolbox
% sensorsStruct : struct, sensors parameters used in the roomsimove toolbox
% sourcesStruct : struct, sources parameters used in the roomsimove toolbox
% sceneTimeStamps : audio scene time stamps

% Version : v2.0
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2018 Ewen Camberlein and Romain Lebarbenchon
% This software is distributed under the terms of the GNU Public License
% version 3 (http://www.gnu.org/licenses/gpl.txt)
% If you find it useful, please cite the following reference:
% http://bass-db.gforge.inria.fr/bss_locate/
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% display configuration
bDisplayConfiguration = 1;

%% Room configuration
% Structure fields declaration
roomStruct = struct(...
    'room_size',   NaN,...
    'F_abs',       NaN, ...
    'A',           NaN ...
    );

% Room size (in meters)
roomStruct.room_size = [6.046	4.562	2.535];

% Frequencies to define absorption coefficients
roomStruct.F_abs = [125	250	500	1000 2000 4000 8000];

% Absorption coefficients for surfaces x=0, x=Lx, y=0, y=Ly, z=0, z=Lz
roomStruct.A = ...
   [0.9 0.9	0.9	0.9	0.9	0.9	0.9;  %Ax1
	0.9	0.9	0.9	0.9	0.9	0.9	0.9;  %Ax2
	0.9	0.9	0.9	0.9	0.9	0.9	0.9;  %Ay1
	0.9	0.9	0.9	0.9	0.9	0.9	0.9;  %Ay2
	0.9	0.9	0.9	0.9	0.9	0.9	0.9;  %Az1
	0.9	0.9	0.9	0.9	0.9	0.9	0.9]; %Az2

%% Time stamps for motion of source and sensors
% Define time stamps based on source 1 original file duration for motion 
% of sources and sensors 
% Warnings : 
%   - timeStampsRes must be <= block_duration to avoid error on the last block(s)
%   - If both source and array are moving, you must use the same timestamps
%     for both due to roomsimove behaviour 
timeStampsRes   = 0.5; % Time stamps resolution (sec)
sourceFileName  = 'male_s1.wav';
infoAudioFile  = audioinfo(sourceFileName);
sceneTimeStamps = 0:timeStampsRes:infoAudioFile.Duration; % time stamps

%% Sensors Configuration
% Structure fields declaration
sensorsStruct = struct(...
    'sensor_nb',    NaN, ...
    'sensor_xyz',   NaN, ...
    'sensor_off',   NaN, ...
    'sensor_type',  NaN ...
    );

% Number of sensors
sensorsStruct.sensor_nb = 8;

% Sensor reference positions (in meters)
  sensor_xyz_ref = ...
 ...% mic1	mic2  mic3  mic4  mic5  mic6  mic7  mic8
    [2.742	2.671 2.649	2.649 2.668 2.739 2.761 2.761;  % x
     2.582	2.582 2.563 2.492 2.470 2.470 2.489 2.560;  % y
     1.155	1.231 1.155 1.231 1.155 1.231 1.155 1.231]; % z
     
 % Define a vertical motion of the microphone array
 sensorsStruct.sensor_xyz = repmat(sensor_xyz_ref, 1 ,1 , length(sceneTimeStamps));
 for i=1:length(sceneTimeStamps)
    vertical_offset = -1 + 2 /(length(sceneTimeStamps)-1) * (i-1);
    sensorsStruct.sensor_xyz(3,:,i)= sensorsStruct.sensor_xyz(3,:,i)+ vertical_offset;
 end
 
% Sensor directions (azimuth, elevation and roll offset in degrees, positive for slew left, nose up or right wing down)
sensorsStruct.sensor_off = zeros(sensorsStruct.sensor_nb,3); % no direction as all microphone as omnidirectionnal.

% Sensor direction-dependent impulse responses (e.g. gains or HRTFs)
sensorsStruct.sensor_type = [1 1 1 1 1 1 1 1]; % 1 = omnidirectional / 2 = cardioid

%% Source 1 configuration : moving source with an uniform circular motion
%Define motion parameters
theta0   = 0;     % initial azimuth (in rad)
omega    = pi/(length(sceneTimeStamps)/2); % angular speed (rad/sec)
arrayPosRef = mean(sensor_xyz_ref,2); 
R        = 1;     % radius
% Define an uniform circular motion for source 1
srcPos = bsxfun(@plus,[R.*cos(omega.*sceneTimeStamps + theta0);R.*sin(omega.*sceneTimeStamps + theta0);zeros(1,length(sceneTimeStamps))],arrayPosRef); 

sourcesStruct(1) = struct(...
    ...
    'filename',        sourceFileName,...  % audio file name : close field recording
    ...
    'sceneTimeStamps', sceneTimeStamps,... % Time stamps
    ...
    'source_xyz',      srcPos...           % Corresponding source positions (in meters) for each time stamps
    );

if(bDisplayConfiguration)
    display_configuration(roomStruct,sensorsStruct,sourcesStruct)
end

end

function display_configuration(roomStruct,sensorsStruct,sourcesStruct)

figure;

% display room
A = [0 0 0];
B = [roomStruct.room_size(1) 0 0];
C = [0 roomStruct.room_size(2) 0];
D = [0 0 roomStruct.room_size(3)];
E = [0 roomStruct.room_size(2) roomStruct.room_size(3)];
F = [roomStruct.room_size(1) 0 roomStruct.room_size(3)];
G = [roomStruct.room_size(1) roomStruct.room_size(2) 0];
H = [roomStruct.room_size(1) roomStruct.room_size(2) roomStruct.room_size(3)];
P = [A;B;F;H;G;C;A;D;E;H;F;D;E;C;G;B];
plot3(P(:,1),P(:,2),P(:,3),'k')

hold on;

% display sources (red)
for i=1:length(sourcesStruct)
    for t = 1:size(sourcesStruct(i).source_xyz,2)
        plot3(sourcesStruct(i).source_xyz(1,t),sourcesStruct(i).source_xyz(2,t),sourcesStruct(i).source_xyz(3,t),'*r');
        if(t == 1 || t == size(sourcesStruct(i).source_xyz,2))
            text(sourcesStruct(i).source_xyz(1,t),sourcesStruct(i).source_xyz(2,t),sourcesStruct(i).source_xyz(3,t),['S_' num2str(i) '(' num2str(t) ')']);
        else
            % no text
        end
    end
end

% display sensors (blue)
for t=1:size(sensorsStruct.sensor_xyz,3)
    for sensorId = 1:size(sensorsStruct.sensor_xyz,2)
        plot3(sensorsStruct.sensor_xyz(1,sensorId,t),sensorsStruct.sensor_xyz(2,sensorId,t),sensorsStruct.sensor_xyz(3,sensorId,t),'*b');
        if((t == 1 || t == size(sensorsStruct.sensor_xyz,3)) && sensorId ==1)
            text(sensorsStruct.sensor_xyz(1,sensorId,t),sensorsStruct.sensor_xyz(2,sensorId,t),sensorsStruct.sensor_xyz(3,sensorId,t),['A' '(' num2str(t) ')']);
        else
            % no text
        end
    end
end

axis equal
xlabel('X');
ylabel('Y');
zlabel('Z');
title('Experiment : room + sources positions (red) + sensors positions (blue)');
clear A B C D E F G H P;
drawnow;
end