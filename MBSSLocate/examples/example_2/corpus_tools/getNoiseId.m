function noiseId  = getNoiseId(h,r,noise,nRoom,nNoise)
% getNoiseId
% This function associates noise condition index for each {home,room} to a
% global index.
% NOTE : Index "1" always refers the quiet condition
%
% noiseId  = getNoiseId(h,r,noise,nRoom,nNoise)
% 
% INPUTS :
% h : home index
% r : room index
% noise : noise index in home h and room r (between [1,4])
% nRoom : total number of rooms per home (must be 3)
% nNoise : total number of noise condition per room (must be 4)
% nUtt : total number of sentences uttered for each {h,r,spk,pos,noise} 
% (must be 2)
%
% OUTPUT :
% noiseId : Global noise index ("1" for the quiet condition)
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
if(noise == 1)
    noiseId = 1;
else
    noiseId = (h-1)*nRoom*(nNoise-1) + (r-1)*(nNoise-1) + (noise);
end
end