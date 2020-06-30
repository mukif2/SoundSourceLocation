function audio_noisy = add_noise(audio, noise, SNR)
    audio_energy = sum(sum(audio.^2));
    noise_energy = sum(sum(noise.^2));
    
    coefficient = audio_energy/noise_energy*10^(-SNR/10);
    audio_noisy = audio + sqrt(coefficient)*noise;
end