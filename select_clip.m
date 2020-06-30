function clip = select_clip(audio, len)
    % calculate average energy
    average_energy = mean(sum(audio.^2, 2));

    % randomly select a clip
    audio_length = length(audio);
    clip_energy = 0;
    while clip_energy < 0.1*average_energy
        start = randi(audio_length-len+1);
        clip = audio(start:start+len-1, :);
        clip_energy = mean(sum(clip.^2, 2));
    end
end