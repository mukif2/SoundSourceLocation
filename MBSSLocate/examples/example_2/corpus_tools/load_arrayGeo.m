function [labels,micPos] = load_arrayGeo(corpusPath,geoId)
% load_arrayGeo
% This function loads microphone positions
%
% [labels,micPos] = load_arrayGeo(corpusPath,geoId)
%
% INPUTS :
% corpusPath : path to the corpus
% geoId : geometry index (must be 1)
%
% OUTPUTS :
% label : text label
% micPos : microphone's positions
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

labels = [];
micPos = [];

fname = [corpusPath 'annotations/arrays/arrayGeo' num2str(geoId) '.txt'];
fid = fopen(fname,'r');
if(fid == -1)
    error(['[load_arrayGeo] : Unable to open ' fname]);
else
    while feof(fid) == 0
        line = fgetl(fid);
        k = strfind(line,sprintf('\t'));
        labels = [labels;{line(1:(k(1)-1))}];
        micPos =[micPos;str2num(line(k(1)+1:(k(2)-1))) str2num(line(k(2)+1:(k(3)-1))) str2num(line(k(3)+1:end))];
    end
    fclose(fid);
end

end