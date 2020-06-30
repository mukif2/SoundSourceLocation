function [gender,spkId] = getSpkId(h,spk)
% getSpkId
% This function associates speaker index in a specific home to a global 
% index with one letter (gender) and one digit (index)
%
% [gender,spkId] = getSpkId(h,spk)
%
% INPUTS :
% h : home index
% spk : speaker index in home h
%
% OUTPUT :
% gender : 'F' or 'M'
% spkId : 1x1 scalar : new speaker index
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
switch(h)
    case 1
        switch(spk)
            case 1
                gender = 'F';
                spkId = 1;
            case 2
                gender = 'M';
                spkId = 1;
            case 3
                gender = 'M';
                spkId = 2;
        end
    case 2
        switch(spk)
            case 1
                gender = 'M';
                spkId = 3;
            case 2
                gender = 'M';
                spkId = 4;
            case 3
                gender = 'F';
                spkId = 2;
        end
    case 3
        switch(spk)
            case 1
                gender = 'M';
                spkId = 5;
            case 2
                gender = 'M';
                spkId = 6;
            case 3
                gender = 'F';
                spkId = 3;
        end
    case 4
        switch(spk)
            case 1
                gender = 'M';
                spkId = 7;
            case 2
                gender = 'F';
                spkId = 4;
            case 3
                gender = 'M';
                spkId = 8;
        end
end

end