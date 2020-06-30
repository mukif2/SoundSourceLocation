function [azimuth, elevation] = mvdr(audio)
    % sliding windows
    [sampleNum, micNum] = size(audio);
    windowLen = 1024;
    windowHop = 512;
    windowNum = floor((sampleNum - windowLen)/windowHop) + 1;
    
    % calculate the frequency domain correlation
    xCorr = zeros(micNum, micNum, windowLen);
    for w = 1:windowNum
        xFreq = fft(audio((w-1)*windowHop+1:(w-1)*windowHop+windowLen, :), [], 1);
        for f = 1:windowLen
            xCorr(:, :, f) = xCorr(:, :, f) + xFreq(f, :)'*xFreq(f, :);
        end
    end
    
    % coarse-search
    aRange = -150:60:150;
    eRange = -75:30:75;
    [azimuth, elevation] = mvdr_grid(xCorr, aRange, eRange);
    
    % fine-search
    aRange = azimuth-25:10:azimuth+25;
    eRange = elevation-12.5:5:elevation+12.5;
    [azimuth, elevation] = mvdr_grid(xCorr, aRange, eRange);
    
    % extra-fine search
    aRange = azimuth-5:1:azimuth+5;
    eRange = elevation-2.5:1:elevation+2.5;
    [azimuth, elevation] = mvdr_grid(xCorr, aRange, eRange);
end