% File: Create_CMR_stim.m
%
% Created: M. Heinz Jun 1 2020
<<<<<<< HEAD
<<<<<<< HEAD
=======
% <<<<<<< HEAD
% Modified by: Fernando Aguilera de Alba
% Branched Created: June 5th 2020

% =======
>>>>>>> updated error messages for noise bands
% Updated Jun 7 2020 
%  1) to be more precise in chin ERB (*** still issues to resolve *** - see
%  Niemiec et al 1992 - we likely need to try CMR with narrow and broad ERB
%  estimates to see if any diffs, since chins see to be broadband
%  processesors Yost and Shoffner 2009)  *****
% ????? still to resolve - what ERBs to use for chins (NN or CR/CB?)
%  2) to match Hari's params (see his email, code)
%  * make three noise bands independent
%  * use human ERBs from Moore and Glasberg, not just 15% estimate.
%  * ramp tone gradually re: noise, not delay onset.
%  * fix flanking band spacing to 1.5 ERB gap, not 2 ERB.
%  ??? remaining question - do we make each band ERB at it's CF, or tone's
%  frequency (i.e., same BW for all 3 bands (NOW), or broader as CF
%  increases? maybe how Hari does it?)
%  3) include noise (No: dB SPL/Hz) and tone (T: dB SPL) sound level in
%  file name 
% ????? still to resolve: adapt on tone or noise level? (easy to setup
% either way)
<<<<<<< HEAD
=======
% Modified by: Fernando Aguilera de Alba
% Branched Created: June 5th 2020

>>>>>>> Test run: modified branch and date
=======
% >>>>>>> master
>>>>>>> updated error messages for noise bands
%
% Creates a set of basic CMR stimuli (REF, CORR, ACORR) for one condition.
%% REF:
% Steady tone is to be detected within a modulated (10 Hz SAM) narrowband
% (1 ERB) wide noise centered on tone.  Tone ramp is gradual re: noise.   
%% CORR:
% Two independent flanking noise bands are added (one below and one above
% the tone). The spacing between the tone frequency and the closest
% flanking noise bands edge (e.g., lower edge of upper band) is 2 ERBs
% (i.e., edge to edge gap is 1.5 ERBs). All three bands are co-modulated
% (in phase) with 10 Hz SAM. 
%% ANTI-UNCORR (ACORR):
% Same two flanking noise bands are added.  But here, the flanking bands
% are modualted out of phase (180 deg) with the center band.
%% CMR_dB = Threshold_ACORR (tone dB SPL) - Thresholds_CORR (tone dB SPL)  (Hari YNH: ~10-12 dB, < 5% have 3 dB or less) 
%% or CMR_dB = Threshold_REF (tone dB SPL) - Thresholds_CORR (tone dB SPL) (Hari YNH: ~3 dB)

clear all; close all; clc

%% Define CMR condition to keep different stimulus sets apart (e.g., chin vs human, different ways of defiing things - keep log in NOTES on chinCMRstimuli.docx 
CMRcondition='CMR2';
fprintf('Generating "%s" stimuli ...\n',CMRcondition)
%% Parameters
f_Hz = 4000;  % center frequency of tone and on-frequency band (OFB)

%% Noise BW set to 1 ERB (either chin or human)
% Chin
Q10_chin = 3.7;  % for chins at 4kHz (Temchin and Ruggero 2008 (I; Fig. 6B); Kale and Heinz 2010)
BW10dB_chin_Hz = f_Hz/Q10_chin;
% ERB_chin_Hz = BW10dB_chin_Hz; % use Q10 as approx for ERB [1080 Hz at 4kHz] % Probably not right.
ERB_chin_Hz = BW10dB_chin_Hz/2;  % from Patterson et al (2005) ISH2003, response to comment from Kollmeier (pp 28-29).
%% ****** TO DO - decide how to handle this.  Lab mammals are ~2-3 worse tuning than humans (Shera at al), so the 1080 to 456 ratio makes sense.  But, Q10 BWs are 2 times bigger than ERB estimates (Patterson et al., 2005 (ISH2003)), so perhaps they are closer than 2-3 times?  Look at Shoffner pitch studies as well (resolved harmonics - he must comment on chin vs human).
% Niemiec et al (Shofner), 1992 - measured behavior ERBs in chins, and
% found NN estimates in chins were comparable (or narrower) to humans, but
% CR and CB estimate using noise bands centered on tone gave estimate much
% broader - they attribute this to chins being more broadband listeners
% than humans (e.g., central processing diffs, more than peripheral diffs -
% SO WE MAY NEED TO TRY CMR WITH SEVERAL BWs to explore.  Go with narrower
% for now.
% Human
ERB_human_Hz = 24.7*(4.37*f_Hz/1000+1);  % from Moore and Glasberg (1983) [456 Hz at 4kHz]
%  B.C.J. Moore and B.R. Glasberg, "Suggested formulae for calculating
%  auditory-filter bandwidths and excitation patterns" Journal of the Acoustical Society of America 74: 750-753, 1983. 

% Pick chin (1) or human (0)
chin = 1;  % 0 = human
if chin
    BWnoise_Hz = ERB_chin_Hz;
    fprintf('...Using chin ERBs\n')
else % human 
    BWnoise_Hz = ERB_human_Hz;
    fprintf('...Using human ERBs\n')
end

%%%%%%%%%%%%%%%%%%% 
% Adjust to find threshold
%%%%%%%%%%%%%%%%%%%
%% LATER - 
levelVEC_tone_dBSPL = 35:3:65;  % ALL tone levels to include
NoVEC_dBSPL_Hz=30;  % ALL Noise Spectrum levels to include (OAL noise = No + 10*log10(BW))
dur_sec=500/1000;
rft_noise_sec=20/1000;
rft_tone_sec=150/1000;
fmod_Hz = 10;   % SAM modulation for noises
fprintf('...Tone levels (dB SPL): %s\n',mat2str(levelVEC_tone_dBSPL))
fprintf('...Noise levels (dB SPL/Hz): %s\n',mat2str(NoVEC_dBSPL_Hz))

%% Read in previously calibrated stim, and confirm TDT Fs sampling rate (Fs)
% see confirm_old_calib (based on tone we know was calibrated at one point
% to be 70 dB SPL) 
fprintf('...Calibrating based on previous stimuli\n')
[calib_dBSPL,calib_70dBtone_rms,Fs_Hz] = confirm_old_calib;  % 70 dB SPL tone is rms of 0.02.

%% Compute center frequencies of all noise bands
f_LSB_Hz = f_Hz - 2.5*BWnoise_Hz;  % center frequency of lower-side-band (LSB) (creates 1.5-ERBgap between OFB lower edge and LSB upper edge)
f_USB_Hz = f_Hz + 2.5*BWnoise_Hz;  % center frequency of upper-side-band (USB) (creates 1.5-ERBgap between OFB upper edge and USB lower edge)
if (f_LSB_Hz-0.5*BWnoise_Hz <= 0) % confirm there is room for LSB
    error('lower side band is below 0Hz');
end
if (f_USB_Hz+0.5*BWnoise_Hz >= Fs_Hz/2) % confirm there is room for USB
    error('upper side band is above Fs = %s Hz', mat2str(Fs_Hz/2));
end

%% Make signals
len_samples = round(dur_sec*Fs_Hz);   
timevec_sec = (0:(len_samples-1))/Fs_Hz;
freqvec_Hz = (0:(len_samples-1))*Fs_Hz/len_samples;   
% Tone
tone = sin(2*pi*f_Hz*timevec_sec);
%% Make noise bands
fprintf('...Creating noise-band filter\n')
% Filter design (LPF at BW/2)
Rp  = 0.00057565; % Corresponds to 0.01 dB peak-to-peak ripple
Rst = 1e-4;       % Corresponds to 80 dB stopband attenuation
TW_Hz=50;  % Transition Width = 100 Hz
b = firgr('minorder',[0,((BWnoise_Hz)/2/(Fs_Hz/2)),((BWnoise_Hz/2+TW_Hz)/(Fs_Hz/2)),1],[1 1 0 0],...
    [Rp Rst]);
% fvt = fvtool(b,1,'Fs',Fs_Hz,'Color','White');

fprintf('...Creating stimuli\n')
% start with BBnoise,
noise_BB = randn(3,2*len_samples);  % 3 independent samples for 3 bands
% ??? Should sig and Std OFB be diff samples - probably not unless it can be every trial (not possible with wav files), bc could give diff cue to use
% create LPnoise,
temp_noise(1,:)=filter(b,1,noise_BB(1,:));  % Apply filter to BB noise (twice length to avoid endpt issues)
temp_noise(2,:)=filter(b,1,noise_BB(2,:));  % Apply filter to BB noise (twice length to avoid endpt issues)
temp_noise(3,:)=filter(b,1,noise_BB(3,:));  % Apply filter to BB noise (twice length to avoid endpt issues)
noise_LPF=temp_noise(:,2*length(b):(len_samples+2*length(b)-1));  % proper length LPnoise by taking from middle
% modulate up to 3 CFs
noise_OFB = noise_LPF(1,:).*sin(2*pi*f_Hz*timevec_sec);
noise_LSB = noise_LPF(1,:).*sin(2*pi*f_LSB_Hz*timevec_sec);
noise_USB = noise_LPF(1,:).*sin(2*pi*f_USB_Hz*timevec_sec);

%% Modulate all noise bands
noise_OFB = noise_OFB.*(1+sin(2*pi*fmod_Hz*timevec_sec));
noise_LSB_CORR = noise_LSB.*(1+sin(2*pi*fmod_Hz*timevec_sec));   % Correlated modulation 
noise_USB_CORR = noise_USB.*(1+sin(2*pi*fmod_Hz*timevec_sec));
<<<<<<< HEAD
<<<<<<< HEAD
noise_LSB_ACORR = noise_LSB.*(1-sin(2*pi*fmod_Hz*timevec_sec));  % Anti-correlated modulation 
noise_USB_ACORR = noise_USB.*(1-sin(2*pi*fmod_Hz*timevec_sec));

%% Generate all tone levels


for noiseIND=1:length(NoVEC_dBSPL_Hz)
    No_dBSPL_Hz=NoVEC_dBSPL_Hz(noiseIND);  % Noise Spectrum level (OAL noise = No + 10*log10(BW))
    for toneIND=1:length(levelVEC_tone_dBSPL)
        level_tone_dBSPL = levelVEC_tone_dBSPL(toneIND);
        
        %% Calibration
        rms_tone_new = calib_70dBtone_rms * 10^((level_tone_dBSPL-calib_dBSPL)/20);
        tone = tone/rms(tone)*rms_tone_new;
        
        rms_noise_new = calib_70dBtone_rms * 10^((No_dBSPL_Hz+10*log10(BWnoise_Hz)-calib_dBSPL)/20);
        noise_OFB= noise_OFB/rms(noise_OFB)*rms_noise_new;
        noise_LSB_CORR= noise_LSB_CORR/rms(noise_LSB_CORR)*rms_noise_new;
        noise_USB_CORR= noise_USB_CORR/rms(noise_USB_CORR)*rms_noise_new;
        noise_LSB_ACORR= noise_LSB_ACORR/rms(noise_LSB_ACORR)*rms_noise_new;
        noise_USB_ACORR= noise_USB_ACORR/rms(noise_USB_ACORR)*rms_noise_new;
        
        %% Apply ramps to each signals (after calibration)
        tone_rft=linear_window_waveform(tone,Fs_Hz,rft_tone_sec);    % Tone is ramped differently then noise bands
        noise_OFB_rft=linear_window_waveform(noise_OFB,Fs_Hz,rft_noise_sec);
        noise_LSB_CORR_rft=linear_window_waveform(noise_LSB_CORR,Fs_Hz,rft_noise_sec);
        noise_USB_CORR_rft=linear_window_waveform(noise_USB_CORR,Fs_Hz,rft_noise_sec);
        noise_LSB_ACORR_rft=linear_window_waveform(noise_LSB_ACORR,Fs_Hz,rft_noise_sec);
        noise_USB_ACORR_rft=linear_window_waveform(noise_USB_ACORR,Fs_Hz,rft_noise_sec);
        
        %% Create complete signals
        signal_REF = tone_rft + noise_OFB_rft;
        standard_REF = noise_OFB_rft;
        signal_CORR = tone_rft + noise_OFB_rft + noise_LSB_CORR_rft + noise_USB_CORR_rft;
        standard_CORR = noise_OFB_rft + noise_LSB_CORR_rft + noise_USB_CORR_rft;
        signal_ACORR = tone_rft + noise_OFB_rft + noise_LSB_ACORR_rft + noise_USB_ACORR_rft;
        standard_ACORR = noise_OFB_rft + noise_LSB_ACORR_rft + noise_USB_ACORR_rft;
        
        %% Save files
        % eventually we'll need to put in some parameter values for all the signal
        % levels
        % sigSNR_fname=sprintf('%s%s.wav',sig_fname(1:end-4),SNRaddon_text);   %'4kHz80dBT_999dBAM_NN.wav';
        % stdSNR_fname=sprintf('%s%s.wav',std_fname(1:end-4),SNRaddon_text);   %'4kHz80dBT_999dBAM_NN.wav';
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % LATER - add to file name/chinch code storage (chin/human, tone level,
        % noise level, BW)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        std_REF_fname = sprintf('%s_REF_No%.f_std.wav',CMRcondition,No_dBSPL_Hz);  % test condition1
        sig_REF_fname = sprintf('%s_REF_No%.f_T%.f_sig.wav',CMRcondition,No_dBSPL_Hz,level_tone_dBSPL);  % test condition1
        std_CORR_fname = sprintf('%s_CORR_No%.f_std.wav',CMRcondition,No_dBSPL_Hz);  % test condition1
        sig_CORR_fname = sprintf('%s_CORR_No%.f_T%.f_sig.wav',CMRcondition,No_dBSPL_Hz,level_tone_dBSPL);  % test condition1
        std_ACORR_fname = sprintf('%s_ACORR_No%.f_std.wav',CMRcondition,No_dBSPL_Hz);
        sig_ACORR_fname = sprintf('%s_ACORR_No%.f_T%.f_sig.wav',CMRcondition,No_dBSPL_Hz,level_tone_dBSPL);  % test condition1
        
        cd('new_signals')
        fprintf('Saving WAV files:\n  %s\n  %s\n  %s\n  %s\n  %s\n  %s\n',std_REF_fname,sig_REF_fname,std_CORR_fname,sig_CORR_fname,std_ACORR_fname,sig_ACORR_fname)
        audiowrite(std_REF_fname,standard_REF,Fs_Hz)
        audiowrite(sig_REF_fname,signal_REF,Fs_Hz)
        audiowrite(std_CORR_fname,standard_CORR,Fs_Hz)
        audiowrite(sig_CORR_fname,signal_CORR,Fs_Hz)
        audiowrite(std_ACORR_fname,standard_ACORR,Fs_Hz)
        audiowrite(sig_ACORR_fname,signal_ACORR,Fs_Hz)
        cd('..\')
        
        
        
        %% Plot Stimuli
        %REF stimuli
        figure(1); clf
        ax1=subplot(231);
        plot(timevec_sec*1000,signal_REF,'r'); hold on; plot(timevec_sec*1000,standard_REF,'b'); hold off
        xlim([0 dur_sec*1000])
        ylabel('Amplitude')
        title(sprintf('REF CONDITION:\nSTD: %s;    \nSIG: %s',std_REF_fname,sig_REF_fname),'interpreter','none')
        ax4=subplot(234);
        plot(freqvec_Hz/1000,20*log10(abs(fft(signal_REF))),'r'); hold on; plot(freqvec_Hz/1000,20*log10(abs(fft(standard_REF))),'b'); hold off
        xlim([0 10])
        ylabel('Magnitude (dB)')
        set(gca,'XTick',[0:2:10])
        
        % CORR stimuli
        ax2=subplot(232);
        plot(timevec_sec*1000,signal_CORR,'r'); hold on; plot(timevec_sec*1000,standard_CORR,'b'); hold off
        xlim([0 dur_sec*1000])
        xlabel('Time (msec)')
        title(sprintf('CORR CONDITION:\nSTD: %s;    \nSIG: %s',std_CORR_fname,sig_CORR_fname),'interpreter','none')
        ax5=subplot(235);
        plot(freqvec_Hz/1000,20*log10(abs(fft(signal_CORR))),'r'); hold on; plot(freqvec_Hz/1000,20*log10(abs(fft(standard_CORR))),'b'); hold off
        xlim([0 10])
        xlabel('Frequency (kHz)')
        set(gca,'XTick',[0:2:10])
        
        % ACORR stimuli
        ax3=subplot(233);
        plot(timevec_sec*1000,signal_ACORR,'r'); hold on; plot(timevec_sec*1000,standard_ACORR,'b'); hold off
        xlim([0 dur_sec*1000])
        title(sprintf('ACORR CONDITION:\nSTD: %s;    \nSIG: %s',std_ACORR_fname,sig_ACORR_fname),'interpreter','none')
        ax6=subplot(236);
        plot(freqvec_Hz/1000,20*log10(abs(fft(signal_ACORR))),'r'); hold on; plot(freqvec_Hz/1000,20*log10(abs(fft(standard_ACORR))),'b'); hold off
        xlim([0 10])
        set(gca,'XTick',[0:2:10])
        
        linkaxes([ax1, ax2, ax3])
        linkaxes([ax4, ax5, ax6])
        
        set(gcf,'units','norm','pos',[0.2    0.0565    0.8    0.8324])
        
        %% Play sounds
        
        disp('Playing Standard the Signal:  REF condition then CORR then ACORR')
        soundsc([standard_REF zeros(size(signal_REF)) signal_REF zeros(1,3*len_samples) ...
            standard_CORR zeros(size(signal_CORR)) signal_CORR zeros(1,3*len_samples) ...
            standard_ACORR zeros(size(signal_ACORR)) signal_ACORR],Fs_Hz)
        
        input('press Enter to move to next level)')
        
    end % tone lebvels
end % noise levels


% soundsc([standard_REF zeros(size(signal_REF)) signal_REF zeros(1,3*len_samples) ...
%     standard_CORR zeros(size(signal_CORR)) signal_CORR zeros(1,3*len_samples) ...
%     standard_ACORR zeros(size(signal_ACORR)) signal_ACORR],Fs_Hz)
    

=======
=======
%<<<<<<< HEAD
>>>>>>> updated error messages for noise bands
noise_LSB_UCORR = noise_LSB.*(1+sin(2*pi*fmod_Hz*timevec_sec+pi));
noise_USB_UCORR = noise_USB.*(1+sin(2*pi*fmod_Hz*timevec_sec+pi));

%% Calibration
rms_tone_new = calib_70dBtone_rms * 10^((level_tone_dBSPL-calib_dBSPL)/20);
tone = tone/rms(tone)*rms_tone_new;

rms_noise_new = calib_70dBtone_rms * 10^((No_SPL_Hz+10*log10(BWnoise_Hz)-calib_dBSPL)/20);
noise_OFB= noise_OFB/rms(noise_OFB)*rms_noise_new;
noise_LSB_CORR= noise_LSB_CORR/rms(noise_LSB_CORR)*rms_noise_new;
noise_USB_CORR= noise_USB_CORR/rms(noise_USB_CORR)*rms_noise_new;
noise_LSB_UCORR= noise_LSB_UCORR/rms(noise_LSB_UCORR)*rms_noise_new;
noise_USB_UCORR= noise_USB_UCORR/rms(noise_USB_UCORR)*rms_noise_new;


%% Apply ramps to each signals
tone_rft=linear_window_waveform(tone,Fs_Hz,rft_sec);  % apply window to tone signal
noise_OFB_rft=linear_window_waveform(noise_OFB,Fs_Hz,rft_sec);  % apply window to noise band
noise_LSB_CORR_rft=linear_window_waveform(noise_LSB_CORR,Fs_Hz,rft_sec);  % apply window to CORR noise band
noise_USB_CORR_rft=linear_window_waveform(noise_USB_CORR,Fs_Hz,rft_sec);  % apply window to CORR noise band
noise_LSB_UCORR_rft=linear_window_waveform(noise_LSB_UCORR,Fs_Hz,rft_sec);  % apply window to UCORR noise band
noise_USB_UCORR_rft=linear_window_waveform(noise_USB_UCORR,Fs_Hz,rft_sec);  % apply window to UCORR noise band

%% Create complete signals
signal_REF = [silence tone_rft] + noise_OFB_rft;
standard_REF = noise_OFB_rft;
signal_CORR = [silence tone_rft] + noise_OFB_rft + noise_LSB_CORR_rft + noise_USB_CORR_rft;
standard_CORR = noise_OFB_rft + noise_LSB_CORR_rft + noise_USB_CORR_rft;
signal_UCORR = [silence tone_rft] + noise_OFB_rft + noise_LSB_UCORR_rft + noise_USB_UCORR_rft;
standard_UCORR = noise_OFB_rft + noise_LSB_UCORR_rft + noise_USB_UCORR_rft;

%% Save files
% eventtually we'll need to put in some parameter values for all the signal
% levels
% sigSNR_fname=sprintf('%s%s.wav',sig_fname(1:end-4),SNRaddon_text);   %'4kHz80dBT_999dBAM_NN.wav';
% stdSNR_fname=sprintf('%s%s.wav',std_fname(1:end-4),SNRaddon_text);   %'4kHz80dBT_999dBAM_NN.wav';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LATER - add to file name/chinch code storage (chin/human, tone level,
% noise level, BW) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
std_REF_fname = 'CMR1_REF_std.wav';  % test condition1
sig_REF_fname = 'CMR1_REF_sig.wav'; 
std_CORR_fname = 'CMR1_CORR_std.wav';  % test condition1
sig_CORR_fname = 'CMR1_CORR_sig.wav'; 
std_UCORR_fname = 'CMR1_UCORR_std.wav';  % test condition1
sig_UCORR_fname = 'CMR1_UCORR_sig.wav'; 


audiowrite(std_REF_fname,standard_REF,Fs_Hz)
audiowrite(sig_REF_fname,signal_REF,Fs_Hz)
audiowrite(std_CORR_fname,standard_CORR,Fs_Hz)
audiowrite(sig_CORR_fname,signal_CORR,Fs_Hz)
audiowrite(std_UCORR_fname,standard_UCORR,Fs_Hz)
audiowrite(sig_UCORR_fname,signal_UCORR,Fs_Hz)



%% Plot and listen to REF stimuli
figure(1); clf
subplot(211)
plot(timevec_sec*1000,signal_REF,'r'); hold on; plot(timevec_sec*1000,standard_REF,'b'); hold off
YLIMITS=ylim;
YLIMITS = 2.5*max(abs(YLIMITS))*[-1 1];
ylim(YLIMITS)
xlim([0 dur_noise_sec*1000])
ylabel('Amp')
xlabel('Time (msec)')
title(sprintf('REF CONDITION:   STD: %s;    \nSIG: %s',std_REF_fname,sig_REF_fname),'interpreter','none')
subplot(212)
plot(freqvec_Hz,20*log10(abs(fft(signal_REF))),'r'); hold on; plot(freqvec_Hz,20*log10(abs(fft(standard_REF))),'b'); hold off
xlim([0 Fs_Hz/2])
ylabel('Magnitude (dB)')
xlabel('Frequency (Hz)')

set(gcf,'units','norm','pos',[0.5005    0.0565    0.4990    0.8324])


%% Plot and listen to CORR stimuli
figure(2); clf
subplot(211)
plot(timevec_sec*1000,signal_CORR,'r'); hold on; plot(timevec_sec*1000,standard_CORR,'b'); hold off
xlim([0 dur_noise_sec*1000])
ylim(YLIMITS)
ylabel('Amp')
xlabel('Time (msec)')
title(sprintf('CORR CONDITION:   STD: %s;    \nSIG: %s',std_CORR_fname,sig_CORR_fname),'interpreter','none')
subplot(212)
plot(freqvec_Hz,20*log10(abs(fft(signal_CORR))),'r'); hold on; plot(freqvec_Hz,20*log10(abs(fft(standard_CORR))),'b'); hold off
xlim([0 Fs_Hz/2])
ylabel('Magnitude (dB)')
xlabel('Frequency (Hz)')

set(gcf,'units','norm','pos',[0.5005    0.0565    0.4990    0.8324])


%% Plot and listen to UCORR stimuli
figure(3); clf
subplot(211)
plot(timevec_sec*1000,signal_UCORR,'r'); hold on; plot(timevec_sec*1000,standard_UCORR,'b'); hold off
xlim([0 dur_noise_sec*1000])
ylim(YLIMITS)
ylabel('Amp')
xlabel('Time (msec)')
title(sprintf('UCORR CONDITION:   STD: %s;    \nSIG: %s',std_UCORR_fname,sig_UCORR_fname),'interpreter','none')
subplot(212)
plot(freqvec_Hz,20*log10(abs(fft(signal_UCORR))),'r'); hold on; plot(freqvec_Hz,20*log10(abs(fft(standard_UCORR))),'b'); hold off
xlim([0 Fs_Hz/2])
ylabel('Magnitude (dB)')
xlabel('Frequency (Hz)')

set(gcf,'units','norm','pos',[0.5005    0.0565    0.4990    0.8324])

%% Play sounds 

disp('Playing Standard the Signal:  REF condition then CORR then UCORR')
soundsc([standard_REF zeros(size(signal_REF)) signal_REF zeros(1,3*len_noise) ...
    standard_CORR zeros(size(signal_CORR)) signal_CORR zeros(1,3*len_noise) ...
    standard_UCORR zeros(size(signal_UCORR)) signal_UCORR],Fs_Hz)

input('press Enter to Hear Again (REF then CORR then UCORR)')

soundsc([standard_REF zeros(size(signal_REF)) signal_REF zeros(1,3*len_noise) ...
    standard_CORR zeros(size(signal_CORR)) signal_CORR zeros(1,3*len_noise) ...
    standard_UCORR zeros(size(signal_UCORR)) signal_UCORR],Fs_Hz)


%cd ../   
<<<<<<< HEAD
>>>>>>> Experimenting with CMR code: changed cd commands to work with my computer
=======
%=======
noise_LSB_ACORR = noise_LSB.*(1-sin(2*pi*fmod_Hz*timevec_sec));  % Anti-correlated modulation 
noise_USB_ACORR = noise_USB.*(1-sin(2*pi*fmod_Hz*timevec_sec));

%% Generate all tone levels


for noiseIND=1:length(NoVEC_dBSPL_Hz)
    No_dBSPL_Hz=NoVEC_dBSPL_Hz(noiseIND);  % Noise Spectrum level (OAL noise = No + 10*log10(BW))
    for toneIND=1:length(levelVEC_tone_dBSPL)
        level_tone_dBSPL = levelVEC_tone_dBSPL(toneIND);
        
        %% Calibration
        rms_tone_new = calib_70dBtone_rms * 10^((level_tone_dBSPL-calib_dBSPL)/20);
        tone = tone/rms(tone)*rms_tone_new;
        
        rms_noise_new = calib_70dBtone_rms * 10^((No_dBSPL_Hz+10*log10(BWnoise_Hz)-calib_dBSPL)/20);
        noise_OFB= noise_OFB/rms(noise_OFB)*rms_noise_new;
        noise_LSB_CORR= noise_LSB_CORR/rms(noise_LSB_CORR)*rms_noise_new;
        noise_USB_CORR= noise_USB_CORR/rms(noise_USB_CORR)*rms_noise_new;
        noise_LSB_ACORR= noise_LSB_ACORR/rms(noise_LSB_ACORR)*rms_noise_new;
        noise_USB_ACORR= noise_USB_ACORR/rms(noise_USB_ACORR)*rms_noise_new;
        
        %% Apply ramps to each signals (after calibration)
        tone_rft=linear_window_waveform(tone,Fs_Hz,rft_tone_sec);    % Tone is ramped differently then noise bands
        noise_OFB_rft=linear_window_waveform(noise_OFB,Fs_Hz,rft_noise_sec);
        noise_LSB_CORR_rft=linear_window_waveform(noise_LSB_CORR,Fs_Hz,rft_noise_sec);
        noise_USB_CORR_rft=linear_window_waveform(noise_USB_CORR,Fs_Hz,rft_noise_sec);
        noise_LSB_ACORR_rft=linear_window_waveform(noise_LSB_ACORR,Fs_Hz,rft_noise_sec);
        noise_USB_ACORR_rft=linear_window_waveform(noise_USB_ACORR,Fs_Hz,rft_noise_sec);
        
        %% Create complete signals
        signal_REF = tone_rft + noise_OFB_rft;
        standard_REF = noise_OFB_rft;
        signal_CORR = tone_rft + noise_OFB_rft + noise_LSB_CORR_rft + noise_USB_CORR_rft;
        standard_CORR = noise_OFB_rft + noise_LSB_CORR_rft + noise_USB_CORR_rft;
        signal_ACORR = tone_rft + noise_OFB_rft + noise_LSB_ACORR_rft + noise_USB_ACORR_rft;
        standard_ACORR = noise_OFB_rft + noise_LSB_ACORR_rft + noise_USB_ACORR_rft;
        
        %% Save files
        % eventually we'll need to put in some parameter values for all the signal
        % levels
        % sigSNR_fname=sprintf('%s%s.wav',sig_fname(1:end-4),SNRaddon_text);   %'4kHz80dBT_999dBAM_NN.wav';
        % stdSNR_fname=sprintf('%s%s.wav',std_fname(1:end-4),SNRaddon_text);   %'4kHz80dBT_999dBAM_NN.wav';
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % LATER - add to file name/chinch code storage (chin/human, tone level,
        % noise level, BW)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        std_REF_fname = sprintf('%s_REF_No%.f_std.wav',CMRcondition,No_dBSPL_Hz);  % test condition1
        sig_REF_fname = sprintf('%s_REF_No%.f_T%.f_sig.wav',CMRcondition,No_dBSPL_Hz,level_tone_dBSPL);  % test condition1
        std_CORR_fname = sprintf('%s_CORR_No%.f_std.wav',CMRcondition,No_dBSPL_Hz);  % test condition1
        sig_CORR_fname = sprintf('%s_CORR_No%.f_T%.f_sig.wav',CMRcondition,No_dBSPL_Hz,level_tone_dBSPL);  % test condition1
        std_ACORR_fname = sprintf('%s_ACORR_No%.f_std.wav',CMRcondition,No_dBSPL_Hz);
        sig_ACORR_fname = sprintf('%s_ACORR_No%.f_T%.f_sig.wav',CMRcondition,No_dBSPL_Hz,level_tone_dBSPL);  % test condition1
        
        cd('new_signals')
        fprintf('Saving WAV files:\n  %s\n  %s\n  %s\n  %s\n  %s\n  %s\n',std_REF_fname,sig_REF_fname,std_CORR_fname,sig_CORR_fname,std_ACORR_fname,sig_ACORR_fname)
        audiowrite(std_REF_fname,standard_REF,Fs_Hz)
        audiowrite(sig_REF_fname,signal_REF,Fs_Hz)
        audiowrite(std_CORR_fname,standard_CORR,Fs_Hz)
        audiowrite(sig_CORR_fname,signal_CORR,Fs_Hz)
        audiowrite(std_ACORR_fname,standard_ACORR,Fs_Hz)
        audiowrite(sig_ACORR_fname,signal_ACORR,Fs_Hz)
        cd('..\')
        
        
        
        %% Plot Stimuli
        %REF stimuli
        figure(1); clf
        ax1=subplot(231);
        plot(timevec_sec*1000,signal_REF,'r'); hold on; plot(timevec_sec*1000,standard_REF,'b'); hold off
        xlim([0 dur_sec*1000])
        ylabel('Amplitude')
        title(sprintf('REF CONDITION:\nSTD: %s;    \nSIG: %s',std_REF_fname,sig_REF_fname),'interpreter','none')
        ax4=subplot(234);
        plot(freqvec_Hz/1000,20*log10(abs(fft(signal_REF))),'r'); hold on; plot(freqvec_Hz/1000,20*log10(abs(fft(standard_REF))),'b'); hold off
        xlim([0 10])
        ylabel('Magnitude (dB)')
        set(gca,'XTick',[0:2:10])
        
        % CORR stimuli
        ax2=subplot(232);
        plot(timevec_sec*1000,signal_CORR,'r'); hold on; plot(timevec_sec*1000,standard_CORR,'b'); hold off
        xlim([0 dur_sec*1000])
        xlabel('Time (msec)')
        title(sprintf('CORR CONDITION:\nSTD: %s;    \nSIG: %s',std_CORR_fname,sig_CORR_fname),'interpreter','none')
        ax5=subplot(235);
        plot(freqvec_Hz/1000,20*log10(abs(fft(signal_CORR))),'r'); hold on; plot(freqvec_Hz/1000,20*log10(abs(fft(standard_CORR))),'b'); hold off
        xlim([0 10])
        xlabel('Frequency (kHz)')
        set(gca,'XTick',[0:2:10])
        
        % ACORR stimuli
        ax3=subplot(233);
        plot(timevec_sec*1000,signal_ACORR,'r'); hold on; plot(timevec_sec*1000,standard_ACORR,'b'); hold off
        xlim([0 dur_sec*1000])
        title(sprintf('ACORR CONDITION:\nSTD: %s;    \nSIG: %s',std_ACORR_fname,sig_ACORR_fname),'interpreter','none')
        ax6=subplot(236);
        plot(freqvec_Hz/1000,20*log10(abs(fft(signal_ACORR))),'r'); hold on; plot(freqvec_Hz/1000,20*log10(abs(fft(standard_ACORR))),'b'); hold off
        xlim([0 10])
        set(gca,'XTick',[0:2:10])
        
        linkaxes([ax1, ax2, ax3])
        linkaxes([ax4, ax5, ax6])
        
        set(gcf,'units','norm','pos',[0.2    0.0565    0.8    0.8324])
        
        %% Play sounds
        
        disp('Playing Standard the Signal:  REF condition then CORR then ACORR')
        soundsc([standard_REF zeros(size(signal_REF)) signal_REF zeros(1,3*len_samples) ...
            standard_CORR zeros(size(signal_CORR)) signal_CORR zeros(1,3*len_samples) ...
            standard_ACORR zeros(size(signal_ACORR)) signal_ACORR],Fs_Hz)
        
        input('press Enter to move to next level)')
        
    end % tone lebvels
end % noise levels


% soundsc([standard_REF zeros(size(signal_REF)) signal_REF zeros(1,3*len_samples) ...
%     standard_CORR zeros(size(signal_CORR)) signal_CORR zeros(1,3*len_samples) ...
%     standard_ACORR zeros(size(signal_ACORR)) signal_ACORR],Fs_Hz)
    

%>>>>>>> master
>>>>>>> updated error messages for noise bands
