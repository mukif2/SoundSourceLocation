function [label,arrayCentroid,arrayOrientation] = load_arrayPos(corpusPath,h,r,geoId)
% load_arrayPos
% This function loads array position and orientation
%
% [label,arrayCentroid,arrayOrientation] = load_arrayPos(corpusPath,h,r,geoId)
%
% INPUTS :
% corpusPath : path to the corpus
% h : home index
% r : room index
% geoId : geometry index (must be 1)
%
% OUTPUT :
% label : text label
% arrayCentroid : 1x3 vector : array centroid position
% arrayOrientation : 1x2 vector : array orientation 
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
arrayCentroid = [];
arrayOrientation = [];
    
fname = [corpusPath 'annotations/rooms/home' num2str(h) '_room' num2str(r) '_arrayPos' num2str(geoId) '.txt'];
fid = fopen(fname,'r');
if(fid == -1)

    error(['[load_arrayPos] : Unable to open ' fname]);
else
    while feof(fid) == 0
        line = fgetl(fid);
        k = strfind(line,sprintf('\t'));
        label = [label;{line(1:(k(1)-1))}];
        arrayCentroid =[arrayCentroid;str2num(line(k(1)+1:(k(2)-1))) str2num(line(k(2)+1:(k(3)-1))) str2num(line(k(3)+1:(k(4)-1)))];
        arrayOrientation = [arrayOrientation; str2num(line(k(4)+1:(k(5)-1))) str2num(line(k(5)+1:end))];
    end
    fclose(fid);
end
end