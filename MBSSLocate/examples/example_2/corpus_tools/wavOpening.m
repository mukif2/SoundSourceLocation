function y = wavOpening(corpusPath,fname,fileType,mode,offset,nSec,targetFs)
% wavOpening
% This function opens corpus wav files (clean or noisy only).
%
% y = wavOpening(corpusPath,fname,fileType,mode,offset,nSec,targetFs)
%
% INPUTS :
% corpusPath : path to the corpus
% fname : wav file name
% fileType :  'clean' or 'noisy'
% mode : One of the following parameter
% - 'wuw_cmd' : wake-up word + command interval
% - 'cmd' : command interval
% - 'wuw' : wake-up word interval
% - 'noise_before' : noise before the "wuw + command"
% offset : 
% - In 'noise_before' mode : 1x1 scalar
% Indicates the noise interval to leave between the end of the noise segment
% and the start of the wake-up word
% - Otherwise : 1x2 vector
% Indicates the duration (in sec) of signal added before (offset(1)) and after
% (offset(2)) the interval considered .
% nSec : 1x1 scalar, only in 'noise_before' mode
% Indicates the duraration (in sec) of the noise interval considered.
% targetFs : 1x1 scalar, target sampling frequency (in Hz) for downsampling
% purpose
%
% OUTPUT :
% y : nsampl x nchan matrix : sampled data
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

switch(fileType)
    case 'clean'
        wavPath = 'audio/clean/';
        transcriptPath = 'transcriptions/clean/';
        
    case 'noisy'
        wavPath = 'audio/noisy/';
        transcriptPath = 'transcriptions/noisy/';
        
    otherwise
        error('File type does not exist'); 
end

wavFile = [corpusPath wavPath fname '.wav'];
wuwLabel = 'OK VESTA';

%% Open the audio file (.wav)
try
    [y,fileFs] = audioread(wavFile);
    if (fileFs > targetFs)
        [q,p] = rat(targetFs/fileFs);
        y = resample(y,q,p);
        fileFs = targetFs;
    end
catch
    error(['Can not open the wav : ' wavFile]);
end

%% Open the time stamp file (.txt)
[labels,timeStamps] = load_TimeStamps(corpusPath,[transcriptPath fname '.txt']);

%% Parsing the time stamp file

% Find the Wake Up Word label
idWuw = [];
for i = 1:length(labels)
    if(strcmp(labels{i},wuwLabel) == 1)
        idWuw = i;
        break;
    end
end

if(isempty(idWuw))
    error('No WUW label found !');
end

timeStamp_wuw_cmd = zeros(2,2); % First line = 'OK VESTA' start and stop // Second line = command start and stop (in sec)
for i =1:2
    timeStamp_wuw_cmd(i,1) = timeStamps(idWuw + i - 1,1);
    timeStamp_wuw_cmd(i,2) = timeStamps(idWuw + i - 1,2);
end

timeStamp_wuw_cmd = round(timeStamp_wuw_cmd.*targetFs); % convert to samples

%% Extract the good part of the signal
switch(mode)
    case 'wuw_cmd'
        sample_start = max(1,timeStamp_wuw_cmd(1,1)-round(offset(1).*targetFs));
        sample_end = min(size(y,1),timeStamp_wuw_cmd(2,2)+round(offset(2).*targetFs));
        y = y(sample_start:sample_end,:);
        
    case 'wuw'
         sample_start = max(1,timeStamp_wuw_cmd(1,1)-round(offset(1).*targetFs));
         sample_end = min(size(y,1),timeStamp_wuw_cmd(1,2)+round(offset(2).*targetFs));
         y = y(sample_start:sample_end,:);
         
    case 'cmd'
        sample_start = max(1,timeStamp_wuw_cmd(2,1)-round(offset(1).*targetFs));
        sample_end = min(size(y,1),timeStamp_wuw_cmd(2,2)+round(offset(2).*targetFs));
        y = y(sample_start:sample_end,:);
         
    case 'noise_before'
        if(isnan(nSec) || isinf(nSec) || nSec <=0)
            y = [];
            error('Number of noise seconds must be specified');
        else
            if(length(offset) ~= 1 || (sum(offset<0)~=0))
                y = [];
                error('Length of offset variable must be 1 and positive in noise_before mode');
            else
                sample_start = max(1,timeStamp_wuw_cmd(1,1) - round((nSec + offset).*targetFs));
                sample_end = timeStamp_wuw_cmd(1,1) -  round(offset.*targetFs);
                y = y(sample_start:sample_end,:);
            end
        end
    otherwise
        y = [];
        error('The opening mode does not exist');
        
end

end
