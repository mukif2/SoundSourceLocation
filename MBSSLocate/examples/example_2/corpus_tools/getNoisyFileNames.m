function [wavFname,promptFname] = getNoisyFileNames(h,r,spk,pos,noise,utt,nHome,nRoom,nSpk,nPos,nNoise,nUtt)
% getNoisyFileNames
% This function computes noisy wav/transcription file name + prompt file
% name.
%
% [wavFname,promptFname] = getNoisyFileNames(h,r,spk,pos,noise,utt,nHome,nRoom,nSpk,nPos,nNoise,nUtt)
% 
% INPUTS :
% h : home index
% r : room index
% spk : speaker index in home h and room r (between [1,3])
% pos : speaker position index
% noise : noise index in home h and room r (between [1,4])
% utt : utterence index for {h,r,spk,pos,noise} (between [1,2])
% nHome : total number of homes (must be 4)
% nRoom : total number of rooms per home (must be 3)
% nSpk : total number of speaker per home (must be 3)
% nPos : total number of position per room (must be 5)
% nNoise : total number of noise condition per room (must be 4)
% nUtt : total number of sentences uttered for each {h,r,spk,pos,noise} 
% (must be 2)
%
% OUTPUTS :
% wavFname : noisy wav/transcription file name (without extension)
% promptFname : prompt file name (without extension)
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
arrayGeo = 1;
arrayPos = 1;

[genre,spkId] = getSpkId(h,spk);
uttId = getUttId(h,r,spk,pos,noise,utt,nHome,nRoom,nSpk,nPos,nNoise,nUtt);
noise_new  = getNoiseId(h,r,noise,nRoom,nNoise);

wavFname = ['home' num2str(h) '_room' num2str(r) '_arrayGeo' num2str(arrayGeo) '_arrayPos' num2str(arrayPos) '_speaker' genre num2str(spkId) '_speakerPos' num2str(pos) '_noiseCond' num2str(noise_new) '_uttNum' num2str(uttId) ];
promptFname = ['uttNum' num2str(uttId)];
end

function uttId = getUttId(h,r,spk,pos,noise,utt,nHome,nRoom,nSpk,nPos,nNoise,nUtt)
uttId = utt + (noise-1)*nUtt + (pos-1)*nUtt*nNoise + (spk-1)*nUtt*nNoise*nPos + (r-1)*nUtt*nNoise*nPos*nSpk + (h-1)*nUtt*nNoise*nPos*nSpk*nRoom;
end