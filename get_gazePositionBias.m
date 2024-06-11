%% Step2--Gaze position calculation

%% start clean
clear; clc; close all;

%% parameters
for pp = [1:25, 27];

    baselineCorrect = 1; 
    removeTrials    = 0; % remove trials where gaze deviation larger than value specified below. Only sensible after baseline correction!
    max_x_pos       = 50; % remove trials with x_position bigger than 50 pixels (~1degree)???
    plotResults     = 0;
    
    %% load epoched data of this participant data
    param = getSubjParam(pp);
    load([param.path, '\epoched_data\eyedata_vidi4','_'  param.subjName], 'eyedata');
    
    %% optional: add relevant behavioural file data 
    
    %% only keep channels of interest
    cfg = [];
    cfg.channel = {'eyeX','eyeY'}; % only keep x & y axis
    eyedata = ft_selectdata(cfg, eyedata); % select x & y channels
    
    %% reformat such that all data in single matrix of trial x channel x time
    cfg = [];
    cfg.keeptrials = 'yes';
    tl = ft_timelockanalysis(cfg, eyedata); % realign the data: from trial*time cells into trial*channel*time?
    
    % dirty hack to get proxy for blink rate
    tl.blink = squeeze(isnan(tl.trial(:,1,:))*100); % 0 where not nan, 1 where nan (putative blink, or eye close etc.)... *100 to get to percentage of trials where blink at that time
    
    %% baseline correct?
    if baselineCorrect
        tsel = tl.time >= -.25 & tl.time <= 0; 
        bl = squeeze(mean(tl.trial(:,:,tsel),3));
        for t = 1:length(tl.time)
            tl.trial(:,:,t) = ((tl.trial(:,:,t) - bl));
        end
    end
    
    %% remove trials with gaze deviation >= 50 pixels
    chX = ismember(tl.label, 'eyeX');
    chY = ismember(tl.label, 'eyeY');
    
    if plotResults
        figure;
        plot(tl.time, squeeze(tl.trial(:,chX,:)));
        title('all trials - full time range');
    end
    
    if removeTrials
        tsel = tl.time>= 0 & tl.time <=1.5; % only check within this time range of interest
        figure; subplot(1,2,1); plot(tl.time(tsel), squeeze(tl.trial(:,chX,tsel))); title('before');
        for trl = 1:size(tl.trial,1)
            oktrial(trl) = sum(abs(tl.trial(trl,chX,tsel)) > max_x_pos)==0; % after baselining, no more deviation than XXX pixels... which is about 1 degree
        end
        tl.trial = tl.trial(oktrial,:,:);
        tl.trialinfo = tl.trialinfo(oktrial,:);
        subplot(1,2,2); plot(tl.time(tsel), squeeze(tl.trial(:,chX,tsel))); title('after');
        proportionOK(pp) = mean(oktrial)*100;
    end
    
    %% selection vectors for conditions -- this is where it starts to become interesting!
    % probed item location
    targL = ismember(tl.trialinfo(:,1), [21,23,25,27,29,211:2:271]);
    targR = ismember(tl.trialinfo(:,1), [22,24,26,28,210:2:272]);
    
    % congruency
    congruent =     ismember(tl.trialinfo(:,1), [21:26, 213:218, 225:230, 237:242, 249:254, 261:266]);
    incongruent  =  ismember(tl.trialinfo(:,1), [27:29, 210:212, 219:224, 231:236, 243:248, 255:260, 267:272]);
    
    % cued item location
    captureL = (targL&congruent)+(targR&incongruent);
    captureR = (targR&congruent)+(targL&incongruent);
   
    % predictability
    predictable = ismember(tl.trialinfo(:,1), [21:29, 210:236]);
    unpredictable = ismember(tl.trialinfo(:,1), [237:272]);

    % timing
    early = ismember(tl.trialinfo(:,1), [21:29, 210:212, 237:248]);
    middle = ismember(tl.trialinfo(:,1), [213:224, 249:260]);
    late = ismember(tl.trialinfo(:,1), [225:236, 261:272]);
    
    stable_trigs = [];
    low_freq_trigs = [];
    high_freq_trigs = [];

    all_triggers = [21:29, 210:272];
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
    
    %% get relevant contrasts out
    gaze = [];
    gaze.time = tl.time * 1000;
    gaze.label = {'all', ...
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

    for selection = [1:size(gaze.label, 2)] % conditions.
        if  selection == 1  sel = ones(size(congruent));
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


        gaze.dataL(selection,:) = squeeze(nanmean(tl.trial(sel&captureL, chX,:)));
        gaze.dataR(selection,:) = squeeze(nanmean(tl.trial(sel&captureR, chX,:)));
        gaze.blinkrate(selection,:) = squeeze(nanmean(tl.blink(sel, :)));
    end
    
    % add towardness field
    gaze.towardness = (gaze.dataR - gaze.dataL) ./ 2;
    
    %% plot
    if plotResults
        figure;
        for sp = 1:size(gaze.label, 2)
            subplot(3,4,sp);
            hold on;
            plot(gaze.time, gaze.dataR(sp,:), 'r');
            plot(gaze.time, gaze.dataL(sp,:), 'b');
            title(gaze.label(sp)); legend({'R','L'},'autoupdate', 'off');
            plot([0,0], ylim, '--k');
            plot([1500,1500], ylim, '--k');
        end

        figure;
        for sp = 1:size(gaze.label, 2)
            subplot(3,4,sp);
            hold on;
            plot(gaze.time, gaze.towardness(sp,:), 'k');
            plot(xlim, [0,0], '--k');
            title(gaze.label(sp)); legend({'T'},'autoupdate', 'off');
            plot([0,0], ylim, '--k');
            plot([1500,1500], ylim, '--k');
        end

        figure;
        hold on;
        plot(gaze.time, gaze.towardness([1:7],:));
        plot(xlim, [0,0], '--k');
        legend(gaze.label([1:7]),'autoupdate', 'off');
        plot([0,0], ylim, '--k');
        plot([1500,1500], ylim, '--k'); 

        figure;
        hold on;
        plot(gaze.time, gaze.blinkrate([1:7],:));
        plot(xlim, [0,0], '--k');
        legend(gaze.label([1:7]),'autoupdate', 'off');
        plot([0,0], ylim, '--k');
        plot([1500,1500], ylim, '--k');
        title('blinkrate');
    end
    
    %% save
    if baselineCorrect == 1 toadd1 = '_baselineCorrect'; else toadd1 = ''; end; % depending on this option, append to name of saved file.    
    if removeTrials == 1    toadd2 = '_removeTrials';    else toadd2 = ''; end; % depending on this option, append to name of saved file.    
    
    save([param.path, '\saved_data\gazePositionEffects', toadd1, toadd2, '__', param.subjName], 'gaze');
    
    drawnow; 
    
    %% close loops
end % end pp loop


