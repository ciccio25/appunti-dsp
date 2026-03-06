%% Aprile 2025 - Possibile risoluzione del compito della prova pratica di Digital Signal Processing 

% Versione di Matlab utilizzata: R2023a 
% Sistema operativo utilizzato: Windows 11  

%% Procedure iniziali 
clc; 
clear all; 
close all; 

%% Importare il file "AudioSample.wav" su Matlab
[campioni_audio_file, Fs] = audioread("AudioSample.wav"); 

% Dalle specifiche viene richiesto: 
% "Caricare sul Workspace Matlab il file “AudioSample.wav”, 
% contenente un segnale audio alla frequenza di campionamento pari a 32kHz. 
% Ricampionare il segnale in modo da portarlo alla nuova frequenza di
% campionamento di 10kHz" 

% Quindi, dobbiamo portare il vettore campioni_audio_file 
% da Fs = 32000 a Fs_audio = 10000 

% Dalla teoria sappiamo che, non possiamo fare un sotto-campionamento per
% un coefficiente non intero, cioè non possiamo scrivere: 
% Fs_audio = Fs*(16/5) = 10000 
% perchè il fattore 16/5 è un numero non intero 
% (alchè 16/5 = 3.2) 

% Ma, sempre dalla teoria, per non perdere contenuto informativo, 
% si DEVE prima sopra-campionare per un coefficiente L intero 
% e poi sotto-campionare per un coefficiente M intero. 

% In inglese sovra-campionamento prende il nome di up-sampling,  
% invece il sotto-campionamento prende il nome di down-sampling 

% Quindi poniamo assegnamo i coefficienti di up-sampling e down-sampling
% opportuni 
L = 5; 
M = 16; 

% In modo tale che, partendo da Fs = 10 KHz: 
Fs_filtro = Fs*L; % 160 KHz 
Fs_audio = Fs_filtro/M; % 10 KHz

% Per non avere aliasing nel segnale finale con la nuova frequenza di
% campionamento, bisogna ricordarsi di progettare un filtro anti-aliasing o
% un filtro anti-imaging opportuno. 

% Dalla teoria, se in una architettura abbiamo sia un up-sampler e poi un down-sampler, 
% per non avere distorsione, dobbiamo mettere un filtro anti-imaging dopo
% il sovra-campionatore e poi un filtro anti-aliasing dopo il filtro
% anti-imaging e prima del sotto-campionatore. 

% Considerando i filtri anti-imaging e anti-aliasing dei filtri passa-basso perchè partiamo da un segnale, 
% come quello vocale, che è di tipo passa-basso, possiamo inserire
% nell'architettura uno tra i due filtri che ha una frequenza di taglio
% inferiore 

% Dando, per adesso, le specifiche nel dominio discreto, abbiamo che 
% la pulsazione di taglio del filtro anti-imaging da inserire dopo il
% sovra-campionatore è uguale a: 

omega_taglio_anti_imaging = pi/L; % 0.6283 

% invece la pulsazione di taglio del filtro anti-aliasing da inserire prima
% del sotto-campionatore e dopo il filtro anti-imaging è uguale a: 

omega_taglio_anti_aliasing = pi/M; % 0.1963 

% Ora scegliamo a quale pulsazione dovr' tagliare il filtro 
if(omega_taglio_anti_aliasing < omega_taglio_anti_imaging)
    pulsazione_taglio_filtro = omega_taglio_anti_aliasing;
else 
    pulsazione_taglio_filtro = omega_taglio_anti_imaging; 
end

% In questo caso omega_taglio_anti_aliasing è uguale è quella più bassa, 
% quindi dobbiamo progettare un filtro passa-baso che tagli a quella
% pulsazione 

% Siccome su filterDesigner possiamo inserire dei valori in analogico, 
% dobbiamo riportare la pulsazione dal dominio discreto al dominio
% analogico con la seguente formula: 

frequenza_taglio_filtro = (pulsazione_taglio_filtro/(2*pi) ) * Fs_filtro; 

%% Dalle specifiche ci viene detto che il filtro da progettare deve essere:  
% - un filtro FIR 
% - progettato con tecnica "equiripple" 
% - banda di transizione di larghezza inferiore a 150Hz 
% - ripple in banda passante non superiore a 1dB 
% - ritardo di gruppo massimo inferiore a 300 campioni

% Il ritardo di gruppo massimo richiesto è un ritardo di gruppo del filtro
% se operasse alla frequenza di campionamento dopo il down-sampler, cioè
% uguale a: 

max_ritoardo_gruppo_filtro_Fs_audio = 300; % campioni 

% quindi su filterDesigner dobbiamo progettare un filtro con un ritardo di
% gruppo uguale a: 

max_ritardo_gruppo_filtro = max_ritoardo_gruppo_filtro_Fs_audio*M; % 4800 campioni 

% Ora che abbiamo capito le specifiche, 
% sapriamo il package filterDesigner dalla Command Window e progettiamo il filtro richiesto 

% I valori che ho inserito su filterDesigner per progettare il filtro sono i seguenti: 

% - Response Type: 
%   - Lowpass   
%     (perchè il segnale vocale è un segnale di tipo passa-basso )

% - Design Method: 
%   - FIR
%     (FIR perchè ci viene detto da specifiche)
%    - Equiripple 
%     (FIR perchè ci viene detto da specifiche)

% - Filter Order: 
%   - Minimum order 

% - Options: 
%   - Density factor = 20 

% - Frequency Specifications: 
%   - Units: 
%    - Hz 
%   - Fs = 160000
%     (perchè ci troviamo a Fs_filtro)     
%   - Fpass = 5000
%     (che è priprio frequenza_taglio_filtro calcolata precedentemente) 
%   - Fstop = 5150
%     (dalle specifiche viene richiesta una banda di transizione di 150 Hz
%     che è proprio uguale a Fstop - Fpass = 150) 

% - Magnitude Specifications: 
%   - Units: 
%     - dB 
%   - Apass = 1 
%     (perchè si richiede, dalle specifiche "ripple in banda passante non superiore a 1dB")     
%   - Astop = 80 
%     (trovato per tentativi, in modo che il filtro progettato abbiamo un ritardo di gruppo finale minore di 300 campioni)     

% Astop è proprio l'attenuazione in banda oscura richiesta dall'esericizio,
% che, in base al filtro progettato, può valere 80 dB 

% Una volta inseriti tutti questi valori, 
% cliccare il pulsante in basso "Design Filter" 

% Cliccando sul pulsante in alto "Group Delay Response", 
% notiamo che il filtro appena progettato ha un ritardo di gruppo costante 
% di 1349.5 campioni, e che quindi rispecchia la specifica di 
% "ritardo di gruppo massimo inferiore a 300 campioni." perchè,  
% 1349.5 / M =  1394.5 / 16 = 84.39 

% Dalle specifiche, si sotto-intende, implicitamente, 
% "un ritardo di gruppo massimo inferiore a 300 campioni" alla frequenza finale dell'audio finale, 
% cioè dopo il down-sampling M. 

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

%% Prima di utilizzare il filtro appena progettato, facciamo l'up-sampling del segnale inziale 
audio_sovra_campionato = upsample(campioni_audio_file, L); 

%% Adesso che abbiamo realizzato il filtro, possiamo importarlo con il
% comando load 
load filtro_progettato_file.mat; 

% Ora filtriamo l'audio sovra-campionato 
audio_filtrato = filter(filtro_progettato, audio_sovra_campionato); 

%% Ora facciamo il down-sampling 

audio_sotto_campionato = downsample(audio_filtrato, M); 

% Come richiesto dall'esercizio, facciamo lo spettogramma
% dell'audio-sottocampionato 

% Sapendo che la voce ha un intervallo di stazionarietà tra i 20 ms ed i 50
% ms, la finestra deve essere lunga almeno: 
% tempo_stazionarietà : 1 s = lunghezza_finestra : Fs_audio 

% Risolvendo questa equazione con i seguenti dati: 

tempo_stazionarieta = 50*10^(-3); % 50 ms 

% avremo che la lunghezza della finestra per lo spettogramma sarà uguale a:

lunghezza_finestra = Fs_audio * tempo_stazionarieta; % 500 campioni

% Considerando però una potenza di 2, il valore più vicino per difetto alla
% lunghezza della finestra è 2^(8) = 256 

% Considerando anche un overlap tra le finestre del 50%, avremo che sarà
% uguale a 256/2 = 128 

figure(1); 
spectrogram(audio_sotto_campionato, 256, 128, 256, Fs_audio);

% Dallo spettogramma finale si nota che il contenuto informativo iniziale
% non è stato modificato e non c'è aliasing quando si è sotto-campionato 

%% Bonus track: 

% Confronto con lo spettogramma dell'audio iniziale da "AudioSample.wav" 
figure(2); 
spectrogram(campioni_audio_file, 1024, 512, 1024, Fs);

% Gli spettogrammi dall'audio iniziale e dell'audio sotto-campionato, 
% sono pressochè uguali 

% Si può ascoltare l'audio finale filtrato sotto-campionato opportunamente 
sound(audio_sotto_campionato, Fs_audio); 

% Ascoltandolo, si nota che è "quasi" uguale all'audio iniziale "AudioSample.wav" 

% Oppure, possiamo salvare l'audio sotto-campionato nel file "DownSampledAudio.wav"

audiowrite("DownSampledAudio.wav", audio_sotto_campionato/max(abs(audio_sotto_campionato)), Fs_audio); 

% Nei parametri di audiowrite ho inserito il vettore
% audio_sotto_campionato/max(abs(audio_sotto_campionato))
% perchè i file audio .wav possono contenere valori compresi
% nell'intervallo [-1, +1] 

% FINE 





