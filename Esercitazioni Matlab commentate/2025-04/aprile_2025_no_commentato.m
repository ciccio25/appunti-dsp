% Versione di Matlab utilizzata: R2023a 
% Sistema operativo utilizzato: Windows 11  

clc; 
clear all; 
close all; 

[campioni_audio_file, Fs] = audioread("AudioSample.wav"); 

L = 5; 
M = 16; 

Fs_filtro = Fs*L; % 160 KHz 
Fs_audio = Fs_filtro/M; % 10 KHz

omega_taglio_anti_imaging = pi/L; % 0.6283 

omega_taglio_anti_aliasing = pi/M; % 0.1963 

if(omega_taglio_anti_aliasing < omega_taglio_anti_imaging)
    pulsazione_taglio_filtro = omega_taglio_anti_aliasing;
else 
    pulsazione_taglio_filtro = omega_taglio_anti_imaging; 
end

frequenza_taglio_filtro = (pulsazione_taglio_filtro/(2*pi) ) * Fs_filtro; 


max_ritoardo_gruppo_filtro_Fs_audio = 300; % campioni 

max_ritardo_gruppo_filtro = max_ritoardo_gruppo_filtro_Fs_audio*M; % 4800 campioni 

audio_sovra_campionato = upsample(campioni_audio_file, L); 

load filtro_progettato_file.mat; 

audio_filtrato = filter(filtro_progettato, audio_sovra_campionato); 

audio_sotto_campionato = downsample(audio_filtrato, M); 

tempo_stazionarieta = 50*10^(-3); % 50 ms 

lunghezza_finestra = Fs_audio * tempo_stazionarieta; % 500 campioni

figure(1); 
spectrogram(audio_sotto_campionato, 256, 128, 256, Fs_audio);

%% Bonus track: 

figure(2); 
spectrogram(campioni_audio_file, 1024, 512, 1024, Fs);

sound(audio_sotto_campionato, Fs_audio); 

audiowrite("DownSampledAudio.wav", audio_sotto_campionato/max(abs(audio_sotto_campionato)), Fs_audio); 





