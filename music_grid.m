function [azimuth, elevation] = music_grid(xCorr, aRange, eRange)
    % the search space
    aNum = length(aRange);
    eNum = length(eRange);
    windowLen = size(xCorr, 3);
    powerSpace = zeros(aNum, eNum);
    
    % known parameters
    micPos = [...
        0.0420      0.0615      -0.0410;
        -0.0420     0.0615      0.0410;
        -0.0615     0.0420      -0.0410;
        -0.0615     -0.0420     0.0410;
        -0.0420     -0.0615     -0.0410;
        0.0420      -0.0615     0.0410;
        0.0615      -0.0420     -0.0410;
        0.0615      0.0420      0.0410];
    soundSpeed = 343;
    
    % calculate the spacial power spacturm
    for ai = 1:aNum
        a = aRange(ai);
        for ei = 1:eNum
            e = eRange(ei);
            direction = [cosd(e)*cosd(a); cosd(e)*sind(a); sind(e)];
            micDelay = - micPos * direction;
            power = 0;
            for i = 1:windowLen
                aDirection = exp(-1j*2*pi*(i-1)/windowLen*44100/soundSpeed*micDelay');
                Rxx = xCorr(:, :, i);
                [vector, value] = eig(Rxx);
                [~, index] = sort(diag(value), 'descend');
                En = vector(:, index(2:end));
                powerInv = aDirection*(En*En')*aDirection';
                power = power + 1/abs(powerInv);
            end
            powerSpace(ai, ei) = power;
        end
    end
    
    % choose the direction with biggest power
    [~, index] = max(powerSpace(:));
    eIndex = ceil(index/aNum);
    aIndex = index - (eIndex-1)*aNum;
    azimuth = aRange(aIndex);
    elevation = eRange(eIndex);
end