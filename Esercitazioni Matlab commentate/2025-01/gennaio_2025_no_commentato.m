clc; 
clear all; 
close all; 

[campioni_audio_file, Fs] = audioread("AudioSample.wav"); 

intervallo_di_stazionarieta = 50 * 10^(-3); % 50 ms 

lunghezza_finestra_spettogramma_ideale = intervallo_di_stazionarieta*Fs; % 800 campioni 

figure(1); 
spectrogram(campioni_audio_file, 512, 256, 512, Fs); 

load filtro_progettato_file.mat; 

audio_filtrato = filter(filtro_progettato, campioni_audio_file); 

figure(2); 
spectrogram(audio_filtrato, 512, 256, 512, Fs); 

%% Bonus track: 
sound(audio_filtrato, Fs); 

audiowrite("FilteredAudio.wav", audio_filtrato/max(abs(audio_filtrato)), Fs); 

