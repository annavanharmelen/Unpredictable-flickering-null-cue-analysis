
%% Step3b--grand average plots of gaze-shift (saccade) results

%% start clean
clear; clc; close all;
    
%% parameters
pp2do           = [1:2];
oneOrTwoD       = 1;        oneOrTwoD_options = {'_1D','_2D'};
nsmooth         = 200;
plotSinglePps   = 1;
plotGAs         = 1;
xlimtoplot      = [-100 1500];

%% set visual parameters
[bar_size, colours, dark_colours, labels, subplot_size, percentageok] = setBehaviourParam(pp2do);

%% load and aggregate the data from all pp
s = 0;
for pp = pp2do
    s = s+1;

    % get participant data
    param = getSubjParam(pp);

    % load
    disp(['getting data from participant ', param.subjName]);
    load([param.path, '\saved_data\saccadeEffects', oneOrTwoD_options{oneOrTwoD} '__', param.subjName], 'saccade','saccadesize');
       
    % smooth?
    if nsmooth > 0
        for x1 = 1:size(saccade.toward,1)
            saccade.toward(x1,:)  = smoothdata(squeeze(saccade.toward(x1,:)), 'gaussian', nsmooth);
            saccade.away(x1,:)    = smoothdata(squeeze(saccade.away(x1,:)), 'gaussian', nsmooth);
            saccade.effect(x1,:)  = smoothdata(squeeze(saccade.effect(x1,:)), 'gaussian', nsmooth);
        end
        % also smooth saccadesize data over time.
        for x1 = 1:size(saccadesize.toward,1)
            for x2 = 1:size(saccadesize.toward,2)
                saccadesize.toward(x1,x2,:) = smoothdata(squeeze(saccadesize.toward(x1,x2,:)), 'gaussian', nsmooth);
                saccadesize.away(x1,x2,:)   = smoothdata(squeeze(saccadesize.away(x1,x2,:)), 'gaussian', nsmooth);
                saccadesize.effect(x1,x2,:) = smoothdata(squeeze(saccadesize.effect(x1,x2,:)), 'gaussian', nsmooth);
            end
        end
    end

    % put into matrix, with pp as first dimension
    d1(s,:,:) = saccade.toward;
    d2(s,:,:) = saccade.away;
    d3(s,:,:) = saccade.effect;

    d4(s,:,:,:) = saccadesize.toward;
    d5(s,:,:,:) = saccadesize.away;
    d6(s,:,:,:) = saccadesize.effect;
end

%% make GA for the saccadesize fieldtrip structure data, to later plot as "time-frequency map" with fieldtrip. For timecourse data, we directly plot from d structures above. 
saccadesize.toward = squeeze(mean(d4));
saccadesize.away   = squeeze(mean(d5));
saccadesize.effect = squeeze(mean(d6));

%% all subs
if plotSinglePps
    % toward vs away
    figure;
    for sp = 1:s
        subplot(subplot_size,subplot_size,sp); hold on;
        plot(saccade.time, squeeze(d3(sp,:,:)));
        plot(xlim, [0,0], '--k');
        xlim(xlimtoplot); ylim([-1.5 1.5]);
        title(pp2do(sp));
    end
    legend(saccade.label);

    % towardness for all conditions condition - gaze shift effect X saccade size
    figure;
    for sp = 1:s
        subplot(subplot_size,subplot_size,sp);
        cfg = [];
        cfg.parameter = 'effect_individual';
        cfg.figure = 'gcf';
        cfg.zlim = [-.1 .1];
        cfg.xlim = xlimtoplot;
        for sp = 1:s
            subplot(subplot_size,subplot_size,sp); hold on;
            saccadesize.effect_individual = squeeze(d6(sp,:,:,:)); % put in data from this pp
            cfg.channel = 4; % colour cue colour block
            ft_singleplotTFR(cfg, saccadesize);
            title(pp2do(sp));
        end
        colormap('jet');
    end

    figure;
    for sp = 1:s
        subplot(subplot_size,subplot_size,sp);
        cfg = [];
        cfg.parameter = 'effect_individual';
        cfg.figure = 'gcf';
        cfg.zlim = [-.1 .1];
        cfg.xlim = xlimtoplot;
        for sp = 1:s
            subplot(subplot_size,subplot_size,sp); hold on;
            saccadesize.effect_individual = squeeze(d6(sp,:,:,:)); % put in data from this pp
            cfg.channel = 5; % location cue location block
            ft_singleplotTFR(cfg, saccadesize);
            title(pp2do(sp));
        end
        colormap('jet');
    end
end

%% plot grand average data patterns of interest, with error bars
if plotGAs
    % right and left cues, per condition
    figure;
    for sp = 1:size(saccade.label,2)
        subplot(3,4,sp); hold on; title(saccade.label(sp));
        p1 = frevede_errorbarplot(saccade.time, squeeze(d1(:,sp,:)), [1,0,0], 'se');
        p2 = frevede_errorbarplot(saccade.time, squeeze(d2(:,sp,:)), [0,0,1], 'se');
        plot(xlim, [0,0], '--k');
        xlim(xlimtoplot); ylim([0 1]);
    end
    legend([p1, p2], {'toward','away'});
    
    % towardness per condition - gaze shift effect X saccade size
    figure;
    for sp = 1:size(saccade.label,2)
        subplot(3,4,sp); hold on; title(saccade.label(sp));
        frevede_errorbarplot(saccade.time, squeeze(d3(:,sp,:)), [0,0,0], 'both');
        plot(xlim, [0,0], '--k');
        xlim(xlimtoplot); ylim([-0.3 0.3]);
    end
    legend({'effect'});
    
    %% towardness overlay of all conditions
    ylimit = [-0.3, 0.3];
    figure;
    hold on;
    p1 = frevede_errorbarplot(saccade.time, squeeze(d3(:,1,:)), 'k', 'both');
    plot(xlim, [0,0], '--k');
    plot([0,0], ylimit, '--k');
    legend([p1], saccade.label(1));
    xlim(xlimtoplot);
    ylabel('Rate (Hz)');
    xlabel('Time (ms)');

    %% as function of saccade size
    cfg = [];
    cfg.parameter = 'effect';
    cfg.figure = 'gcf';
    cfg.zlim = [-0.1, 0.1];
    cfg.xlim = xlimtoplot;
    cfg.colormap = 'jet';
    % per condition
    figure;
    for chan = 1:size(saccadesize.label,2)
        cfg.channel = chan;
        subplot(3,4,chan); ft_singleplotTFR(cfg, saccadesize);
    end
    % cfg.channel = 4;
    % ft_singleplotTFR(cfg, saccadesize);
    ylabel('Saccade size (dva)')
    xlabel('Time (ms)')
    hold on
    plot([0,0], [0, 7], '--k');
    % plot([1500,1500], [0, 7], '--', 'LineWidth',3, 'Color', [0.6, 0.6, 0.6]);
    ylim([0.2 6.8]);

end
