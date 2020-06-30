function [label,noisePos] = load_noisePos(corpusPath,h,r,noise,nRoom,nNoise)
% load_noisePos
% This function loads noise position
%
% [label,noisePos] = load_noisePos(corpusPath,h,r,noise,nRoom,nNoise)
%
% INPUTS :
% corpusPath : path to the corpus
% h : home index
% r : room index
% noise : noise index in home h and room r (between [1,4])
% nRoom : total number of rooms per home (must be 3)
% nNoise : total number of noise condition per room (must be 4)
%
% OUTPUT :
% label : text label
% noisePos : 1x3 vector : noise position
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2017 Ewen Camberlein and Romain Lebarbenchon
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
noise_new = getNoiseId(h,r,noise,nRoom,nNoise);
fname = [corpusPath 'annotations/rooms/' 'home' num2str(h) '_room' num2str(r) '_noiseCond' num2str(noise_new) '.txt'];
fid = fopen(fname,'rt');
label = [];
noisePos = [];

if(fid == -1)
    label = [];
    noisePos = [];
    error(['[load_noisePos] : Unable to open ' fname]);
else
    if(noise == 1)
        
        while feof(fid) == 0
            line = fgetl(fid);
            label = [label;{line(1:end)}];
        end
        fclose(fid);
        noisePos = nan.*ones(1,3);
    else
        while feof(fid) == 0
            line = fgetl(fid);
            k = strfind(line,sprintf('\t'));
            label = [label;{line(1:(k(1)-1))}];
            noisePos =[noisePos;str2num(line(k(1)+1:(k(2)-1))) str2num(line(k(2)+1:(k(3)-1))) str2num(line(k(3)+1:end))];
        end
        fclose(fid);
    end
end

end