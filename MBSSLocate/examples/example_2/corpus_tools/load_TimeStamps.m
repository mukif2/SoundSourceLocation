function [labels,timeStamps] = load_TimeStamps(corpusPath,fname)
% load_TimeStamps
% This function loads timestamps and labels
%
% [labels,timeStamps] = load_TimeStamps(corpusPath,fname)
%
% INPUTS :
% corpusPath : path to the corpus
% fname : file to open
%
% OUTPUT :
% labels : 1xN cell vector : labels (one label per timestamp)
% spkPos : Nx2 vector : Start and end timestamps 
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
timeStamps = [];

fid = fopen([corpusPath fname],'r','n','UTF-8');
if(fid ==-1)
    error(['[load_timeStamps] : Unable to open ' [corpusPath fname]]);
end

while feof(fid) == 0
    line = fgetl(fid);
    k = strfind(line,sprintf('\t'));
    timeStamps = [timeStamps;str2num(line(1:(k(1)-1)))  str2num(line(k(1)+1:(k(2)-1)))];
    labels  =   [labels;{sprintf(line(k(2)+1:end))}];
end

fclose(fid);
end
