%% Step3-- gaze-shift calculation

%% start clean
clear; clc; close all;

%% parameters
for pp = [2];

    oneOrTwoD       = 1; oneOrTwoD_options = {'_1D','_2D'};
    plotResults     = 1;

    %% load epoched data of this participant data
    param = getSubjParam(pp);
    load([param.path, '\epoched_data\eyedata_vidi4_probe','_'  param.subjName], 'eyedata');

    %% add relevant behavioural file data

    %% only keep channels of interest
    cfg = [];
    cfg.channel = {'eyeX','eyeY'}; % only keep x & y axis
    eyedata = ft_selectdata(cfg, eyedata); % select x & y channels

    %% reformat such that all data in single matrix of trial x channel x time
    cfg = [];
    cfg.keeptrials = 'yes';
    tl = ft_timelockanalysis(cfg, eyedata); % realign the data: from trial*time cells into trial*channel*time?

    %% pixel to degree
    [dva_x, dva_y] = frevede_pixel2dva(squeeze(tl.trial(:,1,:)), squeeze(tl.trial(:,2,:)));
    tl.trial(:,1,:) = dva_x;
    tl.trial(:,2,:) = dva_y;

    %% selection vectors for conditions -- this is where it starts to become interesting!
    % probed item location
    targL = ismember(tl.trialinfo(:,1), [31,33,35,37,39,311:2:371]);
    targR = ismember(tl.trialinfo(:,1), [32,34,36,38,310:2:372]);
    
    % congruency
    congruent =     ismember(tl.trialinfo(:,1), [31:36, 313:318, 325:330, 337:342, 349:354, 361:366]);
    incongruent  =  ismember(tl.trialinfo(:,1), [37:39, 310:312, 319:324, 331:336, 343:348, 355:360, 367:372]);
    
    % cued item location
    captureL = (targL&congruent)+(targR&incongruent);
    captureR = (targR&congruent)+(targL&incongruent);
   
    % predictability
    predictable = ismember(tl.trialinfo(:,1), [31:39, 310:336]);
    unpredictable = ismember(tl.trialinfo(:,1), [337:372]);

    % timing
    early = ismember(tl.trialinfo(:,1), [31:39, 310:312, 337:348]);
    middle = ismember(tl.trialinfo(:,1), [313:324, 349:360]);
    late = ismember(tl.trialinfo(:,1), [325:336, 361:372]);
    
    stable_trigs = [];
    low_freq_trigs = [];
    high_freq_trigs = [];

    all_triggers = [31:39, 310:372];
    for trigger = all_triggers
        i = find(all_triggers==trigger);
        if mod(i, 6) == 5 || mod(i, 6) == 0
            low_freq_trigs(end+1) =  trigger;
        elseif mod(i, 6) == 3 || mod(i, 6) == 4
            high_freq_trigs(end+1) = trigger;
        elseif mod(i, 6) == 1 || mod(i, 6) == 2
            stable_trigs(end+1) = trigger;
        end
    end

    % flickering
    stable = ismember(tl.trialinfo(:,1), stable_trigs);
    low_freq = ismember(tl.trialinfo(:,1), low_freq_trigs);
    high_freq = ismember(tl.trialinfo(:,1), high_freq_trigs);

    % channels
    chX = ismember(tl.label, 'eyeX');
    chY = ismember(tl.label, 'eyeY');

    %% get gaze shifts using our custom function
    cfg = [];
    data_input = squeeze(tl.trial);
    time_input = tl.time*1000;

    if oneOrTwoD == 1         [shiftsX, velocity, times]             = PBlab_gazepos2shift_1D(cfg, data_input(:,chX,:), time_input);
    elseif oneOrTwoD == 2     [shiftsX,shiftsY, peakvelocity, times] = PBlab_gazepos2shift_2D(cfg, data_input(:,chX,:), data_input(:,chY,:), time_input);
    end

    %% select usable gaze shifts
    minDisplacement = 0;
    maxDisplacement = 1000;

    if oneOrTwoD == 1     saccadesize = abs(shiftsX);
    elseif oneOrTwoD == 2 saccadesize = abs(shiftsX+shiftsY*1i);
    end
    shiftsL = shiftsX<0 & (saccadesize>minDisplacement & saccadesize<maxDisplacement);
    shiftsR = shiftsX>0 & (saccadesize>minDisplacement & saccadesize<maxDisplacement);

    %% get relevant contrasts out
    saccade = [];
    saccade.time = times;
    saccade.label = {'all', ...
        'congruent', ...
        'incongruent', ...
        'predictable', ...
        'unpredictable', ...
        'early', ...
        'middle', ...
        'late', ...
        'stable', ...
        'low_freq', ...
        'high_freq', ...
        'congruent early', ...
        'incongruent early', ...
        'congruent late', ...
        'incongruent late'};

    for selection = [1:size(saccade.label, 2)] % conditions.
        if     selection == 1  sel = ones(size(congruent));
            elseif selection == 2  sel = congruent;
            elseif selection == 3  sel = incongruent;
            elseif selection == 4  sel = predictable;
            elseif selection == 5  sel = unpredictable;
            elseif selection == 6  sel = early;
            elseif selection == 7  sel = middle;
            elseif selection == 8  sel = late;
            elseif selection == 9  sel = stable;
            elseif selection == 10 sel = low_freq;
            elseif selection == 11 sel = high_freq;
            elseif selection == 12 sel = congruent&early;
            elseif selection == 13 sel = incongruent&early;
            elseif selection == 14 sel = congruent&late;
            elseif selection == 15 sel = incongruent&late;
        end

        saccade.toward(selection,:) =  (mean(shiftsL(targL&sel,:)) + mean(shiftsR(targR&sel,:))) ./ 2;
        saccade.away(selection,:)  =   (mean(shiftsL(targR&sel,:)) + mean(shiftsR(targL&sel,:))) ./ 2;
    end

    % add towardness field
    saccade.effect = (saccade.toward - saccade.away);

    
    %% smooth and turn to Hz
    integrationwindow = 100; % window over which to integrate saccade counts
    saccade.toward = smoothdata(saccade.toward,2,'movmean',integrationwindow)*1000; % *1000 to get to Hz, given 1000 samples per second.
    saccade.away   = smoothdata(saccade.away,2,  'movmean',integrationwindow)*1000;
    saccade.effect = smoothdata(saccade.effect,2,'movmean',integrationwindow)*1000;

    %% plot
    if plotResults
        figure;
        for sp = 1:size(saccade.label, 2)
            subplot(3,4,sp);
            hold on;
            plot(saccade.time, saccade.toward(sp,:), 'r');
            plot(saccade.time, saccade.away(sp,:), 'b');
            title(saccade.label(sp));
            legend({'toward','away'},'autoupdate', 'off');
            plot([0,0], ylim, '--k');
            plot([1500,1500], ylim, '--k');
        end

        figure;
        for sp = 1:size(saccade.label, 2)
            subplot(3,4,sp); hold on;
            plot(saccade.time, saccade.effect(sp,:), 'k');
            plot(xlim, [0,0], '--k');
            title(saccade.label(sp));
            legend({'effect'},'autoupdate', 'off');
            plot([0,0], ylim, '--k');
            plot([1500,1500], ylim, '--k');
        end

        figure;
        hold on;
        plot(saccade.time, saccade.effect([1:7],:));
        plot(xlim, [0,0], '--k');
        legend(saccade.label([1:7]),'autoupdate', 'off');
        plot([0,0], ylim, '--k');
        plot([1500,1500], ylim, '--k');
        drawnow;
    end

    %% also get as function of saccade size - identical as above, except with extra loop over saccade size.
    binsize = 0.5;
    halfbin = binsize/2;

    saccadesize = [];
    saccadesize.dimord = 'chan_freq_time';
    saccadesize.freq = halfbin:0.1:7-halfbin; % shift sizes, as if "frequency axis" for time-frequency plot
    saccadesize.time = times;
    saccadesize.label = {'all', ...
        'congruent', ...
        'incongruent', ...
        'predictable', ...
        'unpredictable', ...
        'early', ...
        'middle', ...
        'late', ...
        'stable', ...
        'low_freq', ...
        'high_freq'};

    cnt = 0;
    for sz = saccadesize.freq;
        cnt = cnt+1;
        shiftsL = [];
        shiftsR = [];
        shiftsL = shiftsX<-sz+halfbin & shiftsX > -sz-halfbin; % left shifts within this range
        shiftsR = shiftsX>sz-halfbin  & shiftsX < sz+halfbin; % right shifts within this range

    % add towardness field
    saccade.effect = (saccade.toward - saccade.away);

        for selection = [1:size(saccadesize.label,2)] % conditions.
            if     selection == 1  sel = ones(size(congruent));
            elseif selection == 2  sel = congruent;
            elseif selection == 3  sel = incongruent;
            elseif selection == 4  sel = predictable;
            elseif selection == 5  sel = unpredictable;
            elseif selection == 6  sel = early;
            elseif selection == 7  sel = middle;
            elseif selection == 8  sel = late;
            elseif selection == 9  sel = stable;
            elseif selection == 10 sel = low_freq;
            elseif selection == 11 sel = high_freq;
            end

            saccadesize.toward(selection,cnt,:) = (mean(shiftsL(captureL&sel,:)) + mean(shiftsR(captureR&sel,:))) ./ 2;
            saccadesize.away(selection,cnt,:) =   (mean(shiftsL(captureR&sel,:)) + mean(shiftsR(captureL&sel,:))) ./ 2;
        end

    end
    % add towardness field
    saccadesize.effect = (saccadesize.toward - saccadesize.away);

    %% smooth and turn to Hz
    integrationwindow = 100; % window over which to integrate saccade counts
    saccadesize.toward = smoothdata(saccadesize.toward,3,'movmean',integrationwindow)*1000; % *1000 to get to Hz, given 1000 samples per second.
    saccadesize.away   = smoothdata(saccadesize.away,3,  'movmean',integrationwindow)*1000;
    saccadesize.effect = smoothdata(saccadesize.effect,3,'movmean',integrationwindow)*1000;

    if plotResults
        cfg = [];
        cfg.parameter = 'effect';
        cfg.figure = 'gcf';
        %cfg.zlim = [-0.01, 0.01];
        figure;
        for chan = 1:size(saccadesize.label,2)
            cfg.channel = chan;
            subplot(3,4,chan); ft_singleplotTFR(cfg, saccadesize);
        end
        colormap('jet');
        drawnow;
    end

    %% save
    save([param.path, '\saved_data\saccadeEffects_probe', oneOrTwoD_options{oneOrTwoD} '__', param.subjName], 'saccade','saccadesize');

    %% close loops
end % end pp loop


