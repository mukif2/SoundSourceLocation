function [label,spkPos,spkMouthOrientation] = load_spkPos(corpusPath,h,r,spk,pos)
% load_spkPos
% This function loads speaker label, position and mouth orientation.
%
% [label,spkPos,spkMouthOrientation] = load_spkPos(corpusPath,h,r,spk,pos)
%
% INPUTS :
% corpusPath : path to the corpus
% h : home index
% r : room index
% spk : speaker index in home h and room r
% pos : speaker position index
%
% OUTPUT :
% label : text label
% spkPos : 1x3 vector : speaker position
% spkMouthOrientation : 1 x2 vector : speaker's mouth orientation
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
label = [];
spkPos = [];
spkMouthOrientation = [];

[genre,spkId] = getSpkId(h,spk);
fname = [corpusPath 'annotations/rooms/' 'home' num2str(h) '_room' num2str(r) '_speaker' genre num2str(spkId) '_speakerPos' num2str(pos) '.txt'];

fid = fopen(fname,'r');
if(fid == -1)
    
    error(['[load_spkPos] : Unable to open ' fname]);
else
    while feof(fid) == 0
        line = fgetl(fid);
        k = strfind(line,sprintf('\t'));
        label = [label;{line(1:(k(1)-1))}];
        spkPos =[spkPos;str2num(line(k(1)+1:(k(2)-1))) str2num(line(k(2)+1:(k(3)-1))) str2num(line(k(3)+1:(k(4)-1)))];
        spkMouthOrientation = [spkMouthOrientation; str2num(line(k(4)+1:(k(5)-1))) str2num(line(k(5)+1:end))];
    end
    fclose(fid);
end

end