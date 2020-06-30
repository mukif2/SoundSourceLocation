function [azRef,elRef] = MBSS_true_aoa(arrayCentroid,srcPos)

% Function MBSS_true_aoa
% Retrieve the true Angle Of Arrival corresponding to a given set 
% of source positions expressed into the microphone array referential. Be
% careful, both arrayCentroid position and srcPos must be expressed into 
% the same referential.
%
% Inputs:
% arrayCentroid: 3 x 1 or 3 x T, cartesian microphone array centroid
% position for each source time stamps. If the time dimension equals 1, we
% consider a static microphone array
% srcPos: 3 x nsrc x T, cartesian source positions for each time
% stamps
%
% Outputs:
% azRef: nsrc x T vector of true source's azimuth (in degrees) for each
% time stamps
% elRef:  nsrc x T vector of the true source's elevation (in degrees) for
% each time stamps
%
% Version: v2.0
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2018 Ewen Camberlein and Romain Lebarbenchon
% This software is distributed under the terms of the GNU Public License
% version 3 (http://www.gnu.org/licenses/gpl.txt)
% If you find it useful, please cite the following reference:
% http://bass-db.gforge.inria.fr/bss_locate/
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[dim,nsrc,Tsrc] = size(srcPos);
if(dim ~= 3)
    error('Bad dimensions');
end
[dim,Tarray] = size(arrayCentroid);
if(dim ~= 3)
    error('Bad dimensions');
end

if(Tarray ~= 1 && Tarray ~= Tsrc)
   error('Time dimension between array position and source position must be the same'); 
end

% Source position into the microphone array referential
if(Tarray == 1)
    for i = 1:nsrc
        srcPos(:,i,:) = bsxfun(@minus,srcPos(:,i,:),arrayCentroid);
    end
else
    for i = 1:nsrc
        srcPos(:,i,:) = squeeze(srcPos(:,i,:)) - arrayCentroid;
    end
end
    

[azRef,elRef,~] = cart2sph(srcPos(1,:,:),srcPos(2,:,:),srcPos(3,:,:));

% Back to deg
azRef = shiftdim(rad2deg(azRef),1); 
elRef = shiftdim(rad2deg(elRef),1);

end