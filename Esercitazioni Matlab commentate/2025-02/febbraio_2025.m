%% Febbraio 2025 - Possibile risoluzione del compito della prova pratica di Digital Signal Processing 

% Versione di Matlab utilizzata: R2023a 
% Sistema operativo utilizzato: Windows 11  

%% Procedure iniziali 
clear all; 
clc; 
close all; 

%% Importare il file "AudioSample.wav" su Matlab
[campioni_audio_file, Fs_originale] = audioread("AudioSample.wav"); 

%% Sovracampionare di L = 3, in modo che il segnale da 16 KHz diventa a 48 KHz 
L = 3; 

audio_sovra_campionato = upsample(campioni_audio_file, L); 

%% Ora che si è sovra-campionato per L, 
% la nuova frequenza di campionamento reale non sarà più Fs_originale, bensì Fs_L, che è uguale a: 
Fs_L = Fs_originale * L; 

%% Dalle specifiche ci viene detto che dobbiamo: 
% - selezionare la banda da 8 KHz a 16 KHz 
% - filtro FIR 
% - bande di transizione di larghezza inferiore a 200 Hz, ciascuna 
% - ripple in banda passante non superiore a 1 dB 
% - ritardo di gruppo massimo inferiore a 250 campioni 

% Quindi, apriamo il package filterDesigner dalla Command Window e progettiamo il filtro richiesto 

% I valori che ho inserito su filterDesigner per progettare il filtro sono i seguenti: 

% - Response Type: 
%   - Bandpass  
%     (perchè il segnale che ci viene detto di prendere è compreso nella banda da 8 KHz a 16 KHz)

% - Design Method: 
%   - FIR
%     (FIR perchè ci viene detto da specifiche)
%    - Equiripple 
      
% - Filter Order: 
%   - Minimum order 

% - Options: 
%   - Density factor = 20 

% - Frequency Specifications: 
%   - Units: 
%    - Hz 
%   - Fs = 48000
%     (perchè ci troviamo a Fs_L)     
%   - Fstop1 = 7800
%     (dalle specifiche viene richiesta una banda di transizione di 200 Hz
%     che è proprio uguale a Fpass1 - Fstop1 = 200) 
%   - Fpass1 = 8000
%     (dalle specifiche, viene richiesta di prendere la porzione da 8 KHz a 16 KHz) 
%   - Fpass2 = 16000 
%     (dalle specifiche, viene richiesta di prendere la porzione da 8 KHz a 16 KHz)
%   - Fstop2 = 16200
%     (dalle specifiche viene richiesta una banda di transizione di 200 Hz
%     che è proprio uguale a Fpass2 - Fstop2 = 200) 

% - Magnitude Specifications: 
%   - Units: 
%     - dB 
%   - Astop1 = 63 
%     (trovato per tentativi, in modo che il filtro progettato abbiamo un ritardo di gruppo minore di 250 campioni)     
%   - Apass = 1 
%     (perchè si richiede, dalle specifiche "ripple in banda passante non superiore a 1dB")     
%   - Astop2 = 63 
%     ( Apass1 = Apass2 in modo che il filtro sia simmetrico)  

% Una volta inseriti tutti questi valori, 
% cliccare il pulsante in basso "Design Filter" 

% Cliccando sul pulsante in alto "Group Delay Response", 
% notiamo che il filtro appena progettato ha un ritardo di gruppo costante 
% di 247 campioni, e che quindi rispecchia la specifica di 
% "ritardo di gruppo massimo inferiore a 250 campioni." 

% Ora che abbiamo progettato il filtro, 
% possiamo salvare la sessione di filterDesigner 

% Cliccare su "File" e poi "Save Session As..." 
% e poi dare un nome al file .fda (io l'ho chiamato filtro_progettato.fda) 

% Ricordati di salvare il file .fda nella stessa cartella dello script 

% Poi, cliccando sempre su "File", questa volta clicchiamo su "Export..." per esportare il filtro progettato 
% come oggetto da usare successivamente su Matlab 

% I valori da inserire nel menu a tendina sono i seguenti: 

% - Export To: 
%  - MAT-File 

% - Export As: 
%  - Objects 

% - Variable Names: 
%  - Discrete Filter = filtro_progettato 
%    (che è lo stesso nome del filtro che troveremo sul Workspace successivamente) 

% E poi cliccare in basso a sinistra sul bottone "Export" 

% Dai un nome al file .mat (io l'ho chiamato filtro_progettato_file.mat) 

% Ricordati di salvare il file .mat nella stessa cartella dello script 

% Adesso che abbiamo realizzato il filtro, possiamo importarlo con il
% comando load 

load filtro_progettato_file.mat;

%% Ora che il filtro progettato è importato sul Workspace, 
% possiamo filtrare il segnale audio_sovra_campionato con il filtro
% filtro_progettato usando il comando filter 

audio_filtrato = filter(filtro_progettato, audio_sovra_campionato);


%% Dalle specifiche "Analizzare il segnale risultante tramite uno spettrogramma opportunamente parametrizzato"
% su Matlab si utilizza il comando spectogram per svolgere uno spettogramma su un segnale  

% Dalla teoria, sappiamo che, per utilizzare lo spettogramma, è necessario
% sapere il periodo di stazionarietà del segnale non stazionario
% (perchè la voce vocale è un segnale non stazionario). 

% Considerando un intervallo di stazionarietà della voce vocale dai 20 ai
% 50 ms, per adesso consideriamo un intervallo di stazionarietà di 50 ms 

intervallo_di_stazionarieta = 50 * 10^(-3); % 50 ms 

% Allora, per trovare quanti intervalli del vettore servono per la finestra
% dello spettogramma è necessario risolvere la seguente proporzione: 

% intervallo_di_stazionarieta : 1 s = lunghezza_finestra_spettogramma_ideale : Fs_L 

% dove: 
% - 1 s sta per un secondo 
% - Fs_L è la frequenza di campionamento in cui si svolge l'intervallo 
%  (si mette Fs_L perchè indica quanti campioni del segnale ci sono in un secondo) 

% Allora facendo i conti, la lunghezza_finestra_spettogramma_ideale vale: 

lunghezza_finestra_spettogramma_ideale = intervallo_di_stazionarieta*Fs_L; % 2400 campioni 

% Dalla teoria, però, sappiamo che è meglio scegliere dei valori alle
% potenze di 2, quindi il valore per difetto più vicino alla
% lunghezza_finestra_spettogramma_ideale, cioè 2400, è 2^11 = 2048 campioni 

% Sempre dalla teoria, nello spettogramma, generalmente si sceglie un
% overlap tra i campioni della finestra del 50%, quindi l'overlap varrà:
% 2048/2 = 1024 campioni 

% Ora, sapendo tutti questi valori, possiamo inserirli nel comando
% spectogram 

figure(1); 
spectrogram(audio_filtrato, 2048, 1024, 2048, Fs_L); 

% Sapendo che i colori che si avvicinano al blu intendono meno potenza del
% segnale a quella frequenza, invece i colori che si avvicinano al giallo
% intendono più potenza del segnale a quella frequenza, dallo spettogramma
% si nota che il filtro passa-banda ha abbattuto di tanto tutte le
% componenti inferiori di 8 KHz e maggiori di 16 KHz 
% e che il parlato originale è stato preservato perchè il sovra-campionamento replica la banda del segnale iniziale sulle altre bande 

%% Bonus track: 
% Confronto degli spettri tra quello del segnale sovra-campionato e quello iniziale  

figure(2); 
spectrogram(audio_sovra_campionato, 2048, 1024, 2048, Fs_L); % spettro del segnale sovra-campionato 

lunghezza_finestra_spettogramma_ideale_originale = intervallo_di_stazionarieta*Fs_originale; % 800 campioni 

figure(3); 
spectrogram(campioni_audio_file, 512, 256, 512, Fs_originale); % spettro del segnale iniziale

% Confrontando i due spettri, si nota che il sovra-campionamento è stato
% svolto con aliasing perchè il segnale iniziale occupa tutta la banda di 8
% KHz, ma, dopo i 4 KHz, la componente informativa del segnale vocale è
% minore, quindi non si hanno grossi problemi

% FINE 

