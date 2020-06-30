clear
close all
clc
warning('off');
method = str2func('gccphat_wiener');
source = 'chirps';

noisetype = {'free-flight', 'hovering', 'rectangle', 'spinning', 'updown'};
azimuth = [45, 60, 75, 90];
elevation = [0, -15, -30];
distance = [1.2, 2.4];
% set repeat = 1 for fast testing
repeat = 1;
tolerance = (2*sind(10/2))^2;

for SNR = 40:-20:-20
error_sq = [];

for n = noisetype
    filename = ['DREGON-noise-only_recordings/DREGON_', n{1},...
        '_nosource_room2.wav'];
    noise = audioread(filename);
for a = azimuth
for e = elevation
for d = distance
    if strcmp(source, 'speech') == 0
        filename = ['DREGON_clean_recordings_' source, '/', num2str(a),...
            '_', num2str(e), '_', num2str(d), '.wav'];
        [audio, fs] = audioread(filename);
    end
for r = 1:repeat
    if strcmp(source, 'speech') == 1
        filename = ['DREGON_clean_recordings_speech/', num2str(a),...
            '_', num2str(e), '_', num2str(d), '__', num2str(r), '.wav'];
        [audio, fs] = audioread(filename);
    end
    
    % sample clips of 0.2s
    len = floor(fs*0.2);
    audio_clip = select_clip(audio, len);
    noise_clip = select_clip(noise, len);
%     m = max(max(audio_clip));
%     audio_clip = audio_clip / m;
%     noise_clip = noise_clip / m;
    audio_noisy = add_noise(audio_clip, noise_clip, SNR);
    
    % estimate azimuth and elevation, calculate RSE
%     noise_c = noise_clip;
    [a_est, e_est] = method(audio_noisy,noise_clip);
    error_sq(end+1) = square_error(a, a_est, e, e_est);
    
    % comment the following line for compact output
    fprintf('(%.0f,%.0f) estimated as (%.0f,%.0f), e^2=%f\n',...
        a, e, a_est, e_est, error_sq(end));
end
end
end
end
    fprintf('SNR=%f,noise=%s\n', SNR, n{1})
    fprintf('RMSE=%f\n', sqrt(mean(error_sq)));
    fprintf('accept rate=%f%%\n\n', 100*mean(error_sq<tolerance));
end

end