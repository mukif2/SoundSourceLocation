function [R, P, F, Acc] = MBSS_eval(evalMode,angleThreshold,arrayCentroid,srcPos,azEst,elEst,blockTimeStamps,sceneTimeStamps)
% Function MBSS_eval
% Evaluation of Angle estimation in terms of recall, precision, F-measure
% and accuracy
%
% Inputs:
% evalMode: Evaluation mode. Could take one of these values :
%    'az_only': Accuracy is computed by only using the estimated azimut
%    'el_only': Accuracy is computed by only using the estimated elevation
%    'cartesian': Accuracy is computed by using the estimated azimut and
%    elevation. Both must respect the correctness threshold
%    'curvilinear': Accuracy is computed as a curvilinear distance on a
%    1-meter sphere
% angleThreshold: correctness threshold in degrees under the far-field assumption
% arrayCentroid: 3 x T, cartesian microphone array centroid
% position for each source time stamps. If the time dimension equals 1, we
% consider a static microphone array.
% srcPos: 3 x nsrc x T, Cartesian source positions at defined time stamps.
% If (T == 1), sources are considered static, otherwise moving
% azEst: nBlocks x nsrce, Estimated azimuths
% elEst: nBlocks x nsrce, Estimated elevations
% sceneTimeStamps: 1 x T, Mandatory if T > 1 (in srcPos). Defined source
% time stamps.
% blockTimeStamps: 1 x nBlocks Madatory if T > 1 (in srcPos). Estimation time
% stamps.
%
% Outputs:
%   R: 1 x nBlocks Recall at each estimation time stamp
%   P:  1 x nBlocks Precision at each estimation time stamp
%   F:  1 x nBlocks F-measure at each estimation time stamp
% Acc: (nBlocks x nsrce x 1)* or (nBlocks x nsrce x 2)** vector of
%      estimated source accuracie in degrees  (+inf if above the threshold)
%      for each estimation time stamp.
%  (*): For 'az_only', 'el_only' and 'curvilinear' mode => only one value
% (**): For 'cartesian' mode
%       =>  First value: azimut accuracy / Second value: elevation accuracy
%
% Version: v2.0
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyrigth 2018 Ewen Camberlein and Romain Lebarbenchon
% Copyright 2010-2011 Charles Blandin and Emmanuel Vincent
% This software is distributed under the terms of the GNU Public License
% version 3 (http://www.gnu.org/licenses/gpl.txt)
% If you find it useful, please cite the following reference:
% - Charles Blandin, Emmanuel Vincent and Alexey Ozerov, "Multi-source TDOA
%   estimation in reverberant audio using angular spectra and clustering",
%   Signal Processing, to appear.
% - http://bass-db.gforge.inria.fr/bss_locate/
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get info from dimensions
[nBlocks,nsrce] = size(azEst);
if(nBlocks > 1)
   blockApproach = 1; 
else
    blockApproach = 0;
end
if(sum(size(azEst) - size(elEst)) ~= 0)
    error('azEst and elEst must have the same size');
end

[dim1,nsrc,nTrueTimeStamps] = size(srcPos);
if(dim1 ~=3)
    error('srcPos : size of first dimension must be 3');
end
if(nTrueTimeStamps == 1)
    % The sources are statics
    movingSrc = 0;
else
    movingSrc = 1;
    if(~exist('sceneTimeStamps','var') || ~exist('blockTimeStamps','var') || isempty(sceneTimeStamps) || isempty(blockTimeStamps)  || length(sceneTimeStamps) ~= nTrueTimeStamps || length(blockTimeStamps) ~= nBlocks)
        error('You must provide sceneTimeStamps / blockTimeStamps if the source is moving and the dimension must be correct');
    end
end

% Compute azimuth and elevation for reference sources (ground thruth)
[azRef,elRef] = MBSS_true_aoa(arrayCentroid,srcPos);

% display azRef elRef azEst and elEst for each source if block approach is used
if(blockApproach)
    figure;
    % generate the legend labels
    legendLabels = cell(1,nsrc + 1);
    legendLabels{1} = 'estimated';
    for trueSrcId = 1:nsrc
        legendLabels{trueSrcId + 1} = ['ground truth #' num2str(trueSrcId)];
    end
    % For each estimated source
    
    for srcId=1:nsrce
        % azimuth
        subplot(2,nsrce,(srcId-1) * nsrce + 1);
        
        plot(blockTimeStamps,azEst(:,srcId),'*');
        hold on
        for trueSrcId=1:nsrc
            if(movingSrc)
                plot(sceneTimeStamps,azRef(trueSrcId,:),'o--');
            else
                plot(blockTimeStamps,repmat(azRef(trueSrcId,:),1,nBlocks),'o--');
            end
        end
        title(['Estimated Source #' num2str(srcId) '- Azimuth']);
        legend(legendLabels);
        xlabel('Time (sec)');
        ylabel('azimuth (°)');
        
        % elevation
        subplot(2,nsrce,(srcId-1) * nsrce + 2);
        plot(blockTimeStamps,elEst(:,srcId),'*');
        hold on
        for trueSrcId=1:nsrc
            if(movingSrc)
                plot(sceneTimeStamps,elRef(trueSrcId,:),'o--');
            else
                plot(blockTimeStamps,repmat(elRef(trueSrcId,:),1,nBlocks),'o--');
            end
        end
        title(['Estimated Source #' num2str(srcId) '- Elevation']);
        legend(legendLabels);
        xlabel('Time (sec)');
        ylabel('elevation (°)');
    end
end

% Compute and display metrics between ground thruth and estimated angles (Recall, Precision, F-measure, Accuracy)
R = zeros(1,nBlocks);
P = zeros(1,nBlocks);
F = zeros(1,nBlocks);
switch evalMode
    case 'cartesian'
        Acc = inf(nBlocks,nsrce,2);
    case {'az_only','el_only','curvilinear'}
        Acc = inf(nBlocks,nsrce,1);
end

for k = 1:nBlocks % number of blocks
    % Find the closest timestamp
    if(movingSrc)
        [~,id] = min(abs(sceneTimeStamps - blockTimeStamps(k)));
    else
        id =1;
    end
    [R(k), P(k), F(k), Acc(k,:,:)] = MBSS_eval_angle([azEst(k,:);elEst(k,:)], [azRef(:,id)';elRef(:,id)'],angleThreshold,evalMode);
end

% Display results : Recall / Accuracy and F-measure
if(nBlocks == 1)
    fprintf('Recall: %f \t Precision: %f \t F-Measure: %f \n',R,P,F);
else
    figure;
    hist([R; P; F]',0:0.1:1);
    legend('Recall','Precision','F-measure');
    title('Recall / Precision / F-measure histograms');
    ylabel('Hist. count');
end

% Display results : Accuracy
figure;
for srcId = 1:nsrce
    subplot(nsrce,1,srcId);
    hist(Acc(:,srcId,:),0:angleThreshold);
    title(['Error histogram (in degrees) - Estimated source #' num2str(srcId)]);
    switch (evalMode)
        case 'cartesian'
            legend('Azimuth','Elevation');
        case 'az_only'
            legend('Azimuth');
        case 'el_only'
            legend('Elevation');
        case 'curvilinear'
            legend('Curvilinear');
    end
    xlabel('Error (°)');
    ylabel('Hist. count');
end
end

function [R, P, F, Acc_out] = MBSS_eval_angle(loc_e, loc_true,thres,mode)

% Function MBSS_eval_angle
% Evaluation of Angle estimation in terms of recall,
% precision, F-measure and accuracy
%
% Inputs:
% loc_e: 2 x nsrce vector of estimated angles (azimuth and elevation)
% loc_true: 2 x nsrc vector of true angles (azimuth and elevation)
% thresh: correctness threshold in degrees under the far-field assumption
% mode : Evaluation mode. Could take one of these values :
%    'az_only' : Accuracy is computed by only using the estimated azimut
%    'el_only' : Accuracy is computed by only using the estimated elevation
%    'cartesian' : Accuracy is computed by using the estimated azimut and
%    elevation. Both must respect the correctness threshold
%    'curvilinear' : Accuracy is computed as a curvilinear distance on a
%    1-meter sphere
% Outputs:
% R: recall
% P: precision
% F: F-measure
% Acc: (nsrce x 1)* or (nsrce x 2)** vector of estimated source accuracie in degrees  (+inf
% if above the threshold).
% (*) : For 'az_only', 'el_only' and 'curvilinear' mode.
% (**): For 'cartesian' mode.
% First value: azimut accuracy / Second value: elevation accuracy
%
% Version: v2.0
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2010-2011 Charles Blandin and Emmanuel Vincent
% Copyrigth 2018 Ewen Camberlein and Romain Lebarbenchon
% This software is distributed under the terms of the GNU Public License
% version 3 (http://www.gnu.org/licenses/gpl.txt)
% If you find it useful, please cite the following reference:
% - Charles Blandin, Emmanuel Vincent and Alexey Ozerov, "Multi-source TDOA
%   estimation in reverberant audio using angular spectra and clustering",
%   Signal Processing, to appear.
% - http://bass-db.gforge.inria.fr/bss_locate/
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Default mode
if nargin <= 3
    mode = 'curvilinear';
end

if(size(loc_e,1) ~= 2 || size(loc_true,1) ~=2)
    error('Each localization must have two components (theta and phi)');
end

nsrce = size(loc_e,2);
nsrc = size(loc_true,2);

% Init
correctness = inf(nsrce,nsrc);
switch mode
    case 'cartesian'
        Acc = inf(nsrce,nsrc,2);
        Acc_out = zeros(nsrce,2);
    case {'az_only','el_only','curvilinear'}
        Acc = inf(nsrce,nsrc,1);
        Acc_out = zeros(nsrce,1);
    otherwise
        error('Evaluation method unknown');
        
end

% Correctness of each {estimated,true} value resp. the threshold and the
% mode
for e = 1:nsrce
    for t = 1:nsrc
        [correctness(e,t),Acc(e,t,:)] = isCorrect(loc_e(:,e),loc_true(:,t),thres,mode);
    end
end

% An estimate is correct if it matches one true localization
correct = sum(correctness,2) ~=0;

% Compute the evaluation metrics
% Accuracy
for e = 1:nsrce
    if(correct(e))
        tmp = shiftdim(Acc(e,:,:),1);
        [~,id]= min(mean(tmp,2));
        Acc_out(e,:) = tmp(id,:);
    else
        Acc_out(e,:) = inf;
    end
end


%Recall
R = sum(correct)/nsrc;
%Precision
P = sum(correct)/nsrce;
% F-measure
F = 2*(P.*R)./(P + R + realmin);

end

function [val,Acc] = isCorrect(loc_e,loc_true,thres,mode)
% loc_e : 2x1 estimate
% loc_true : 2x1 true
% mode

% Return 1 if loc_e and loc_true are correct according to the threshold and
% the evaluation method


switch mode
    case {'cartesian','az_only','el_only'}
        % Angle error both in azimuth and elevation
        angleErr = abs(loc_e-loc_true);
        angleErr = min(angleErr,360-angleErr);
        val = angleErr <= thres;
        switch mode
            case 'cartesian'
                % Correct if both the azimut and elevation are corrects
                val = sum(val) == 2;
                if(val==1)
                    Acc = angleErr;
                else
                    Acc = inf(1,2);
                end
            case 'az_only'
                val = val(1) == 1;
                if(val == 1)
                    Acc = angleErr(1);
                else
                    Acc = inf(1);
                end
            case 'el_only'
                val = val(2) == 1;
                if(val == 1)
                    Acc = angleErr(2);
                else
                    Acc = inf(1);
                end
        end
    case 'curvilinear'
        % Curvilear angle error on a 1 meter sphere
        angleErr = acosd(sind(loc_e(2)).*sind(loc_true(2))+cosd(loc_e(2)).*cosd(loc_true(2)).*cosd(loc_true(1)-loc_e(1)));
        val = angleErr<=thres;
        if(val == 1)
            Acc = angleErr;
        else
            Acc = inf;
        end
    otherwise
        error('Evaluation method unknown');
end

end