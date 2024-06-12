
%% Step2b--grand average plots of gaze-position results

%% start clean
clear; clc; close all;

%% parameters
pp2do = [1, 3:25, 27];

nsmooth         = 200;
baselineCorrect = 1;
removeTrials    = 0; % remove trials with more than XX pixel deviation from baseline
plotSinglePps   = 0;
plotGAs         = 0;
xlimtoplot      = [-100 1500];

%% set visual parameters
[bar_size, colours, dark_colours, labels, subplot_size, percentageok] = setBehaviourParam(pp2do);

%% load and aggregate the data from all pp
s = 0;
for pp = pp2do;
    s = s+1;

    % get participant data
    param = getSubjParam(pp);

    % load
    disp(['getting data from participant ', param.subjName]);

    if baselineCorrect == 1 toadd1 = '_baselineCorrect'; else toadd1 = ''; end % depending on this option, append to name of saved file.
    if removeTrials == 1    toadd2 = '_removeTrials';    else toadd2 = ''; end % depending on this option, append to name of saved file.

    load([param.path, '\saved_data\gazePositionEffects', toadd1, toadd2, '__', param.subjName], 'gaze');
      

    % smooth?
    if nsmooth > 0
        for x1 = 1:size(gaze.dataL,1);
            gaze.dataL(x1,:)      = smoothdata(squeeze(gaze.dataL(x1,:)), 'gaussian', nsmooth);
            gaze.dataR(x1,:)      = smoothdata(squeeze(gaze.dataR(x1,:)), 'gaussian', nsmooth);
            gaze.towardness(x1,:) = smoothdata(squeeze(gaze.towardness(x1,:)), 'gaussian', nsmooth);
            gaze.blinkrate(x1,:)  = smoothdata(squeeze(gaze.blinkrate(x1,:)), 'gaussian', nsmooth);
        end
    end

    % put into matrix, with pp as first dimension
    d1(s,:,:) = gaze.dataR;
    d2(s,:,:) = gaze.dataL;
    d3(s,:,:) = gaze.towardness;
    d4(s,:,:) = gaze.blinkrate;
end

%% make GA

%% all subs
if plotSinglePps
    % towardness
    figure;
    for sp = 1:s
        subplot(subplot_size, subplot_size, sp); hold on;
        plot(gaze.time, squeeze(d3(sp,:,:)));
        plot(xlim, [0,0], '--k');
        xlim(xlimtoplot); ylim([-5 5]);
        title(pp2do(sp));
    end

    % blink rate
    figure;
    for sp = 1:s
        subplot(subplot_size, subplot_size, sp); hold on;
        plot(gaze.time, squeeze(d4(sp,:,:)));
        plot(xlim, [0,0], '--k');
        xlim(xlimtoplot); ylim([-20 100]);
        title(pp2do(sp));
    end
    legend(gaze.label);
end

%% plot grand average data patterns of interest, with error bars
if plotGAs
    % right and left cues, per condition
    figure;
    for sp = 1:11
        subplot(3,4,sp); hold on; title(gaze.label(sp));
        p1 = frevede_errorbarplot(gaze.time, squeeze(d1(:,sp,:)), [1,0,0], 'se');
        p2 = frevede_errorbarplot(gaze.time, squeeze(d2(:,sp,:)), [0,0,1], 'se');
        xlim(xlimtoplot);
    end
    legend([p1, p2], {'R','L'});
    
    % towardness per condition
    figure;
    for sp = 1:11
        subplot(3,4,sp); hold on; title(gaze.label(sp));
        frevede_errorbarplot(gaze.time, squeeze(d3(:,sp,:)), [0,0,0], 'both');
        plot(xlim, [0,0], '--k');
        xlim(xlimtoplot); ylim([-5 5]);
    end
    legend({'toward'});
    
%% towardness overlay of all conditions
    figure; hold on;
    ylimit = [-4, 4];
    plot([0,0], [ylimit], '--', 'LineWidth',2, 'Color', [0.6, 0.6, 0.6]);
    frevede_errorbarplot(gaze.time, squeeze(d3(:,2,:)), [1,0,0], 'se');
    frevede_errorbarplot(gaze.time, squeeze(d3(:,4,:)), [0,0,1], 'se');

    ylim(ylimit);
    plot(xlim, [0,0], '--', 'LineWidth',2, 'Color', [0.6, 0.6, 0.6]);
    legend(gaze.label(2:4));
    xlim(xlimtoplot);
    ylabel('Gaze towardness (px)');
    xlabel('Time (ms)');

    ylimit2 = [-4, 3];
    figure;
    % subplot(1,2,1);
    hold on;
    p1 = frevede_errorbarplot(gaze.time, squeeze(d3(:,5,:)), 'k', 'both');
    plot(xlim, [0,0], '--', 'LineWidth',2, 'Color', [0.6, 0.6, 0.6]);
    plot([0,0], ylimit2, '--', 'LineWidth',2, 'Color', [0.6, 0.6, 0.6]);
    xlim(xlimtoplot);
    ylabel('Gaze towardness (px)');
    xlabel('Time (ms)');
    ylim(ylimit2);
    
    % subplot(1,2,2); hold on;
    % p1 = plot(gaze.time, squeeze(d3(:,5,:)));
    % plot(xlim, [0,0], '--k');
    % legend([p1], gaze.label(5));
    % xlim(xlimtoplot);
    % 
    %% blink rate
    figure; 
    hold on;
    frevede_errorbarplot(gaze.time, squeeze(d4(:,2,:)), [1,0,0], 'se');
    frevede_errorbarplot(gaze.time, squeeze(d4(:,4,:)), [0,0,1], 'se');
    plot(xlim, [0,0], '--k');
    plot([0,0], [-5, 30], '--k')
    xlim(xlimtoplot);

end