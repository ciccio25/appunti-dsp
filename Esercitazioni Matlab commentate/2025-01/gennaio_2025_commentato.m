%% Gennaio 2025 - Possibile risoluzione del compito della prova pratica di Digital Signal Processing 

%% Procedure iniziali 
clc; 
clear all; 
close all; 

%% Importare il file "AudioSample.wav" su Matlab
[campioni_audio_file, Fs] = audioread("AudioSample.wav"); 

%% Per localizzare, nello spettro dove si trova il disturbo, nella realtà dovremmo utilizzare uno spettogramma, 
% su Matlab si utilizza il comando spectogram 

% Dalla teoria, sappiamo che, per utilizzare lo spettogramma, è necessario
% sapere il periodo di stazionarietà del segnale non stazionario
% (perchè la voce vocale è un segnale non stazionario). 

% Considerando un intervallo di stazionarietà della voce vocale dai 20 ai
% 50 ms, per adesso consideriamo un intervallo di stazionarietà di 50 ms 

intervallo_di_stazionarieta = 50 * 10^(-3); % 50 ms 

% Allora, per trovare quanti intervalli del vettore servono per la finestra
% dello spettogramma è necessario risolvere la seguente proporzione: 

% intervallo_di_stazionarieta : 1 s = lunghezza_finestra_spettogramma_ideale : Fs 

% dove: 
% - 1 s sta per un secondo 
% - Fs è la frequenza di campionamento in cui si svolge l'intervallo 
%  (si mette Fs perchè indica quanti campioni del segnale ci sono in un secondo) 

% Allora facendo i conti, la lunghezza_finestra_spettogramma_ideale vale: 

lunghezza_finestra_spettogramma_ideale = intervallo_di_stazionarieta*Fs; % 800 campioni 

% Dalla teoria, però, sappiamo che è meglio scegliere dei valori alle
% potenze di 2, quindi il valore per difetto più vicino alla
% lunghezza_finestra_spettogramma_ideale, cioè 800, è 2^9 = 512 campioni 

% Sempre dalla teoria, nello spettogramma, generalmente si sceglie un
% overlap tra i campioni della finestra del 50%, quindi l'overlap varrà:
% 512/2 = 256 campioni 

% Ora, sapendo tutti questi valori, possiamo inserirli nel comando
% spectogram 

figure(1); 
spectrogram(campioni_audio_file, 512, 256, 512, Fs); 

% Dallo spettogramma, notiamo che il disturbo è a banda stretta, 
% centrato a 1 KHz 

%% Quindi, progettiamo un filtro elimina-banda per abbassarlo, in base alle specifiche date 

% Apriamo il package filterDesigner e progettiamo il filtro 

% La regola generale per la progettazione dei filtri è che se non viene
% richiesta quella determinata specifica, abbiamo libertà progettuale 
% (detta in soldoni, possiamo fare come ci pare) 

% I valori che ho inserito su filterDesigner per progettare il filtro sono
% i seguenti: 

% - Response Type: 
%   - Bandstop 

% - Design Method: 
%   - IIR 
%     ( perchè viene richiesto, dalle specifiche "un filtro IIR")  
%    - Butterworth  

% - Filter Order: 
%  - Minimum order 

% - Options: 
%  - Density Factor = 20 

% - Frequency Specifications: 
%  - Units: 
%   - Hz 
%  - Fs = 16000 
%  - Fpass1 = 800 
%  - Fstop1 = 900 
%  - Fstop2 = 1100 
%  - Fpass2 = 1200  

% - Magnitude Specifications: 
%  - Units: 
%   - dB  
%  - Apass1 = 1 
%    (perchè si richiede, dalle specifiche "ripple in banda passante non superiori a 1 dB) 
%  - Astop = 3  
%    (perchè si richiede, dalle specifiche "attenuazione in banda oscura non inferiore a 70 dB") 
%  - Apass2 = 1 
%    ( Apass1 = Apass2 in modo che il filtro sia simmetrico) 

% Una volta inseriti tutti questi valori, 
% cliccare il pulsante in basso "Design Filter" 

% Cliccando sul pulsante in alto "Group Delay Response", 
% notiamo che il filtro appena progettato ha un ritardo di gruppo massimo
% di 40.24199 campioni alla frequenza 0.8916016  

% Ora che abbiamo progettato il filtro, possiamo salvare la sessione di
% filterDesigner 

% Ritardo di gruppo massimo e costante di 220 campioni con il filtro
% progettato andando in alto a sinistra, cliccare su "File" e poi "Save Session As..." 
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

% E poi cliccare in basso a sinistra sul bottone "Export" 

% Dai un nome al file .mat (io l'ho chiamato filtro_progettato_file.mat) 

% Ricordati di salvare il file .mat nella stessa cartella dello script 

% Adesso che abbiamo realizzato il filtro, possiamo importarlo con il
% comando load 

load filtro_progettato_file.mat; 

%% Ora che il filtro progettato è importato sul Workspace, 
% possiamo filtrare il segnale iniziale campioni_audio_file con il filtro
% filtro_progettao usando il comando filter 

audio_filtrato = filter(filtro_progettato, campioni_audio_file); 

%% Per visualizzare che il disturbo a banda stretta è stato fortemente abbattuto, 
% possiamo utilizzare, di nuovo, lo spettogramma 

% Siccome l'audio originale è stato semplicemente filtrato, possiamo
% utilizzare gli stessi valori precedenti, soltanto che, al posto di
% utilizzare il vettore campioni_audio_file, useremo il vettore
% audio_filtrato 

figure(2); 
spectrogram(audio_filtrato, 512, 256, 512, Fs); 

% Da questo spettogramma, notiamo che, grazie al filtro appena progettato, 
% il disturbo a banda stretta appena progettato è stato fortemente abbattuto, 
% disturbo che si trovava nell'intorno di 1 KHz 

%% Bonus track: 
% Si può ascolatare anche l'audio finale filtrato con le cuffie con il comando sound 

sound(audio_filtrato, Fs); 

% oppure salvato nel file "FilteredAudio.wav"

audiowrite("FilteredAudio.wav", audio_filtrato/max(abs(audio_filtrato)), Fs); 

% Nei parametri di audiowrite ho inserito il vettore
% audio_filtrato/max(abs(audio_filtrato)) 
% perchè i file audio .wav possono contenere valori compresi
% nell'intervallo [-1, +1] 

% FINE 

