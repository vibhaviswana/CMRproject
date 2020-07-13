% File: PsychometricCurve_CMR.m
% Created: Fernando Aguilera - Jun 28 2020

% Last Modified by: Fernando Aguilera de Alba - July 11 2020
%% Goal
% Generate psychometric curves for REF, CORR, and ACORR conditions from user data for CMR pilot testing.
clear all; close all; clc;
%% Requirement
CMRstimuli = input('\nType of CMR stimuli: ','s');
%% Load subject's matlab data file
% Load all blocks from user files from CMRpilot_results folder
fprintf('\nAnalyze individual subject data -- 1'); 
fprintf('\nAnalyze all subjects data -- 2');
menuresponse = input('\n\nMenu option: ');
while isempty(menuresponse)
    fprintf('\n\nERROR: Invalid menu option');
    menuresponse = input('\n\nMenu option: ');
end
%% Individual data: plot all blocks and average
if menuresponse == 1
    userid = input('\nUser ID: ','s');
    blocks = input('Number of blocks: ');
    cd CMRpilot_results % open pilot data folder
    cd CMR2C % CHANGE FOLDER TO TYPE OF STIMULI
% load block files for subject based on userid    
    for i = 1:blocks   
        filename = [userid '_Block' num2str(i) '_' CMRstimuli '_Pilot_Results.mat'];
        load(filename);
        REFresults_avg(:,i+1) = (REFtonescore(:,2)/2)*100;
        CORRresults_avg(:,i+1) = (CORRtonescore(:,2)/2)*100;
        ACORRresults_avg(:,i+1) = (ACORRtonescore(:,2)/2)*100;
        fprintf('\nFile loaded:%s ',filename);
    end
    cd ../
    cd ../
% Average results
REF = 0; CORR = 0; ACORR = 0;
for j = 1:length(levelVEC_tone_dBSPL)
    for i = 1:blocks
        REF = REF + REFresults_avg(j,i+1);
        CORR = CORR + CORRresults_avg(j,i+1);
        ACORR = ACORR + ACORRresults_avg(j,i+1);
    end
    REFresults_avg(j,(blocks+2)) = (REF/blocks);
    CORRresults_avg(j,(blocks+2)) = (CORR/blocks);
    ACORRresults_avg(j,(blocks+2)) = (ACORR/blocks);
    REF = 0; CORR = 0; ACORR = 0;
end
REFresults_avg(:,1) = levelVEC_tone_dBSPL'; CORRresults_avg(:,1) = levelVEC_tone_dBSPL'; ACORRresults_avg(:,1) = levelVEC_tone_dBSPL';
%% Psychometric curve generation for each block
plotlegend = string(zeros(blocks,1));
for i = 1:blocks
plotlegend(i,1) = ['Block ' num2str(i)];
end
Markers = {'+','o','*','x','v','d','^','s','>','<'};
counter = 1;
for i = 2:(blocks+1)
% REF
figure(1);
hold on;
plot(REFresults_avg(:,1),REFresults_avg(:,i),strcat(Markers{counter})); % scatter plot of block REF
hold off;
% CORR
figure(2);
hold on;
scatter(CORRresults_avg(:,1),CORRresults_avg(:,i),strcat(Markers{counter})); % scatter plot of block CORR
hold off;
% ACORR
figure(3);
hold on;
scatter(ACORRresults_avg(:,1),ACORRresults_avg(:,i),strcat(Markers{counter})); % scatter plot of block ACORR
hold off;
counter = counter + 1; 
end
%% Psychometric curve generation average
criteria = 75; % 
REFplot = sprintf('Psychometric Curve (Condition: REF | User ID: %s)', userid);
CORRplot = sprintf('Psychometric Curve (Condition: CORR | User ID: %s)', userid);
ACORRplot = sprintf('Psychometric Curve (Condition: ACORR | User ID: %s)', userid);

figure(1); % REF 
hold on;
title(REFplot); xlabel('Tone Level (dB)'); ylabel('Correctness (%)'); xlim([levelVEC_tone_dBSPL(1) levelVEC_tone_dBSPL(end)]); ylim([0,110]);
REF_TH = fitPsychometricFunctionCMR(REFresults_avg(:,1), REFresults_avg(:,(blocks+2)), 1, criteria);
legend(plotlegend(1:blocks,:),'Location','SouthEast');
hold off;

figure(2); % CORR
hold on;
title(CORRplot); xlabel('Tone Level (dB)'); ylabel('Correctness (%)'); xlim([levelVEC_tone_dBSPL(1) levelVEC_tone_dBSPL(end)]); ylim([0,110]);
CORR_TH = fitPsychometricFunctionCMR(CORRresults_avg(:,1), CORRresults_avg(:,(blocks+2)), 1, criteria);
%plot(CORRresults_avg(:,1), CORRresults_avg(:,(blocks+2)), 'r', 'linewidth',1.5); CORR_TH = NaN;
legend(plotlegend(1:blocks,:),'Location','SouthEast');
hold off;

figure(3); % ACORR

hold on;
title(ACORRplot); xlabel('Tone Level (dB)'); ylabel('Correctness (%)'); xlim([levelVEC_tone_dBSPL(1) levelVEC_tone_dBSPL(end)]); ylim([0,110]);
ACORR_TH = fitPsychometricFunctionCMR(ACORRresults_avg(:,1), ACORRresults_avg(:,(blocks+2)), 1, criteria);
legend(plotlegend(1:blocks,:),'Location','SouthEast');
hold off;

cd CMRpilot_results
cd CMR2C % CHANGE FOLDER TO TYPE OF STIMULI
cd Psychometric_Curves_CMR2C % CHANGE FOLDER TO TYPE OF STIMULI
cd Subject_Average_CMR2C % CHANGE FOLDER TO TYPE OF STIMULI
plotnameREF = sprintf('%s_Block_Averages_REF_%s_Pilot_Results.jpg',userid, CMRstimuli);
plotnameCORR = sprintf('%s_Block_Averages_CORR_%s_Pilot_Results.jpg',userid, CMRstimuli);
plotnameACORR = sprintf('%s_Block_Averages_ACORR_%s_Pilot_Results.jpg',userid, CMRstimuli);
saveas(figure(1), plotnameREF); saveas(figure(2), plotnameCORR); saveas(figure(3), plotnameACORR);
cd ../
cd ../
cd ../
%% CMR effect
clc;
thresholds = string(zeros(1,4)); % col1 = userid | col2 = REF | col3 = CORR | col4 = ACORR
thresholds(1,1) = userid; thresholds(1,2) = REF_TH; thresholds(1,3) = CORR_TH; thresholds(1,4) = ACORR_TH;
CMR_AC = ACORR_TH - CORR_TH;
CMR_RC = REF_TH - CORR_TH;
fprintf('\nThresholds (USER ID: %s)',userid);
fprintf('\nREF:%6.1f dB',REF_TH); fprintf('\nCORR:%6.1f dB',CORR_TH); fprintf('\nACORR:%6.1f dB',ACORR_TH);
fprintf('\n\nCMR Score (ACORR - CORR):%6.1f dB', CMR_AC); fprintf('\nCMR Score (REF - CORR):%6.1f dB', CMR_RC);
end

%% All subjects: plot subject average and population average (no individual blocks)
REFtotalavg = []; CORRtotalavg = []; ACORRtotalavg = [];
if menuresponse == 2
    numsubjects = input('\nNumber of Subjects: ');
    cd CMRpilot_results % open pilot data folder   
    cd CMR2C % CHANGE FOLDER TO TYPE OF STIMULI
% load files for each subject based on userid  
plotlegend = string(zeros(numsubjects,1));
for i = 1:numsubjects
        fprintf('\n\nUser ID #%d: ', i); userid = input('','s');
        blocks = input('Number of blocks: ');
        plotlegend(i,:) = ['Subject: ' userid ', Blocks: ' mat2str(blocks)];
        for j = 1:blocks
            filename = [userid '_Block' num2str(j) '_' CMRstimuli '_Pilot_Results.mat'];
            load(filename);
            REFresults_avg(:,j+1) = (REFtonescore(:,2)/2)*100;
            CORRresults_avg(:,j+1) = (CORRtonescore(:,2)/2)*100;
            ACORRresults_avg(:,j+1) = (ACORRtonescore(:,2)/2)*100;
            fprintf('\nFile loaded:%s ',filename);
        end
% Average results for each subject's block
    REF = 0; CORR = 0; ACORR = 0;
    for j = 1:length(levelVEC_tone_dBSPL)
        for k = 1:blocks
            REF = REF + REFresults_avg(j,k+1);
            CORR = CORR + CORRresults_avg(j,k+1);
            ACORR = ACORR + ACORRresults_avg(j,k+1);
        end
    REFresults_avg(j,(blocks+2)) = (REF/blocks);
    CORRresults_avg(j,(blocks+2)) = (CORR/blocks);
    ACORRresults_avg(j,(blocks+2)) = (ACORR/blocks);
    REF = 0; CORR = 0; ACORR = 0;
    end
    REFtotalavg(:,i+1) = REFresults_avg(:,blocks+2); 
    CORRtotalavg(:,i+1) = CORRresults_avg(:,blocks+2); 
    ACORRtotalavg(:,i+1) = ACORRresults_avg(:,blocks+2); 
end
% Average results for all subjects
  REFall = 0; CORRall = 0; ACORRall = 0;
    for j = 1:length(levelVEC_tone_dBSPL)
        for k = 1:numsubjects
            REFall = REFall + REFtotalavg(j,k+1);
            CORRall = CORRall + CORRtotalavg(j,k+1);
            ACORRall = ACORRall + ACORRtotalavg(j,k+1);
        end
    REFtotalavg(j,(numsubjects+1)) = (REFall/numsubjects);
    CORRtotalavg(j,(numsubjects+1)) = (CORRall/numsubjects);
    ACORRtotalavg(j,(numsubjects+1)) = (ACORRall/numsubjects);
    REFall = 0; CORRall = 0; ACORRall = 0;
    end
cd ../
cd ../
REFtotalavg(:,1) = levelVEC_tone_dBSPL'; CORRtotalavg(:,1) = levelVEC_tone_dBSPL'; ACORRtotalavg(:,1) = levelVEC_tone_dBSPL'; 
%% Psychometric curve generation for each subject's average
Markers = {'+','o','*','x','v','d','^','s','>','<'};
counter = 1;
for i = 2:(numsubjects+1)
% REF
figure(1);
hold on;
plot(REFtotalavg(:,1),REFtotalavg(:,i),strcat(Markers{counter})); % scatter plot of block REF
hold off;
% CORR
figure(2);
hold on;
scatter(CORRtotalavg(:,1),CORRtotalavg(:,i),strcat(Markers{counter})); % scatter plot of block CORR
hold off;
% ACORR
figure(3);
hold on;
scatter(ACORRtotalavg(:,1),ACORRtotalavg(:,i),strcat(Markers{counter})); % scatter plot of block ACORR
hold off;
counter = counter + 1; 
end
%% Psychometric curve generation average
criteria = 75; % 
REFplot = sprintf('Population Averages Psychometric Curve (Condition: REF | Subjects: %d)',numsubjects);
CORRplot = sprintf('Population Averages Psychometric Curve (Condition: CORR | Subjects: %d)',numsubjects');
ACORRplot = sprintf('Population Averages Psychometric Curve (Condition: ACORR | Subjects: %d)',numsubjects');

figure(1); % REF 
hold on;
REF_TH = fitPsychometricFunctionCMR(REFtotalavg(:,1), REFtotalavg(:,(numsubjects+1)), 1, criteria);
title(REFplot); xlabel('Tone Level (dB SPL)'); ylabel('Correctness (%)'); xlim([levelVEC_tone_dBSPL(1) levelVEC_tone_dBSPL(end)]);ylim([45,110]);
legend(plotlegend(1:numsubjects,:),'Location','southeast');
hold off;

figure(2); % CORR
hold on;
CORR_TH = fitPsychometricFunctionCMR(CORRtotalavg(:,1), CORRtotalavg(:,(numsubjects+1)), 1, criteria);
title(CORRplot); xlabel('Tone Level (dB SPL)'); ylabel('Correctness (%)'); ylim([45,110]);
legend(plotlegend(1:numsubjects,:),'Location','southeast');
hold off;

figure(3); % ACORR
hold on;
ACORR_TH = fitPsychometricFunctionCMR(ACORRtotalavg(:,1), ACORRtotalavg(:,(numsubjects+1)), 1, criteria);
title(ACORRplot); xlabel('Tone Level (dB SPL)'); ylabel('Correctness (%)'); xlim([levelVEC_tone_dBSPL(1) levelVEC_tone_dBSPL(end)]); ylim([45,110]);
legend(plotlegend(1:numsubjects,:),'Location','southeast');
hold off;

figure(4); % ALL conditions
hold on;
fitPsychometricFunctionCMR(REFtotalavg(:,1), REFtotalavg(:,(numsubjects+1)), 1, criteria);
fitPsychometricFunctionCMR(CORRtotalavg(:,1), CORRtotalavg(:,(numsubjects+1)), 1, criteria);
fitPsychometricFunctionCMR(ACORRtotalavg(:,1), ACORRtotalavg(:,(numsubjects+1)), 1, criteria);
title('Population Average (All Conditions)'); 
xlabel('Tone Level (dB SPL)'); ylabel('Correctness (%)'); xlim([levelVEC_tone_dBSPL(1) levelVEC_tone_dBSPL(end)]); ylim([45,110]);

cd CMRpilot_results % open pilot data folder  
cd CMR2C % CHANGE FOLDER TO TYPE OF STIMULI
cd Psychometric_Curves_CMR2C % CHANGE FOLDER TO TYPE OF STIMULI
cd All_Subjects_CMR2C % CHANGE FOLDER TO TYPE OF STIMULI
plotnameREF = sprintf('Subject_Averages_REF_%s_Pilot_Results.jpg', CMRstimuli);
plotnameCORR = sprintf('Subject_Averages_CORR_%s_Pilot_Results.jpg', CMRstimuli);
plotnameACORR = sprintf('Subject_Averages_ACORR_%s_Pilot_Results.jpg', CMRstimuli);
plotnameALL = sprintf('Subject_Averages_ALL_%s_Pilot_Results.jpg', CMRstimuli);
saveas(figure(1), plotnameREF); saveas(figure(2), plotnameCORR); saveas(figure(3), plotnameACORR); saveas(figure(4), plotnameALL);
cd ../
cd ../
%% Average thresholds results (all subjects)
clc;
thresholds = string(zeros(1,4)); % col1 = userid | col2 = REF | col3 = CORR | col4 = ACORR
thresholds(1,1) = 'Average'; thresholds(1,2) = REF_TH; thresholds(1,3) = CORR_TH; thresholds(1,4) = ACORR_TH; 
CMR_AC = ACORR_TH - CORR_TH;
CMR_RC = REF_TH - CORR_TH;
fprintf('\nThresholds (Population Average)');
fprintf('\nREF:%6.1f dB',REF_TH); fprintf('\nCORR:%6.1f dB',CORR_TH); fprintf('\nACORR:%6.1f dB',ACORR_TH);
fprintf('\n\nCMR Score (ACORR - CORR):%6.1f dB', CMR_AC); fprintf('\nCMR Score (REF - CORR):%6.1f dB', CMR_RC);
end
%% Notes:
% 2. mu = average of CMR scores (ACORR - CORR) ~12 dB   (CORR - REF) ~3 dB
% 3. calculate variability between subject CMR scores

% Code to choose curve fitting for CORR when threshold is not available 
% (% correctness > 75% for all tone levels)


