% Versione di Matlab utilizzata: R2023a 
% Sistema operativo utilizzato: Windows 11  

clear all; 
clc; 
close all; 

[campioni_audio_file, Fs_originale] = audioread("AudioSample.wav"); 

L = 3; 

audio_sovra_campionato = upsample(campioni_audio_file, L); 

Fs_L = Fs_originale * L; 

load filtro_progettato_file.mat;

audio_filtrato = filter(filtro_progettato, audio_sovra_campionato);

intervallo_di_stazionarieta = 50 * 10^(-3); % 50 ms 

lunghezza_finestra_spettogramma_ideale = intervallo_di_stazionarieta*Fs_L; % 2400 campioni 


figure(1); 
spectrogram(audio_filtrato, 2048, 1024, 2048, Fs_L); 

%% Bonus track: 

figure(2); 
spectrogram(audio_sovra_campionato, 2048, 1024, 2048, Fs_L); % spettro del segnale sovra-campionato 

lunghezza_finestra_spettogramma_ideale_originale = intervallo_di_stazionarieta*Fs_originale; % 800 campioni 

figure(3); 
spectrogram(campioni_audio_file, 512, 256, 512, Fs_originale); % spettro del segnale iniziale

