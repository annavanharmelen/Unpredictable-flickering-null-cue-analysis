clear all
close all
clc

%% set parameters and loops
see_performance = 0;
display_percentageok = 1;
plot_individuals = 0;
plot_averages = 0;

pp2do = [1:9]; 
p = 0;

[bar_size, colours,  dark_colours, labels, subplot_size, percentageok] = setBehaviourParam(pp2do);

for pp = pp2do
    p = p+1;
    ppnum(p) = pp;
    figure_nr = 1;

    param = getSubjParam(pp);
    disp(['getting data from ', param.subjName]);
    
    %% load actual behavioural data
    behdata = readtable(param.log);
    
    %% update signed error to stay within -90/+90
    behdata.signed_difference(behdata.signed_difference>90) = behdata.signed_difference(behdata.signed_difference>90)-180;
    behdata.signed_difference(behdata.signed_difference<-90) = behdata.signed_difference(behdata.signed_difference<-90)+180;
    
    %% check ok trials, just based on decision time, because this one is unlimited.
    oktrials = abs(zscore(behdata.idle_reaction_time_in_ms))<=3; 
    percentageok(p) = mean(oktrials)*100;

    %% display percentage OK
    if display_percentageok
        fprintf('%s has %.2f%% OK trials ', param.subjName, percentageok(p))
        fprintf('and an average score of %.2f \n\n', mean(behdata.performance))
    end

    %% basic data checks, each pp in own subplot
    if plot_individuals
        figure(figure_nr);
        figure_nr = figure_nr+1;
        subplot(subplot_size,subplot_size,p);
        histogram(behdata.response_time_in_ms(oktrials),50);
        title(['response time - pp ', num2str(pp2do(p))]);
        xlim([0 1500]);

        figure(figure_nr);
        figure_nr = figure_nr+1;
        subplot(subplot_size,subplot_size,p);
        histogram(behdata.idle_reaction_time_in_ms(oktrials),50);
        title(['decision time - pp ', num2str(pp2do(p))]);  

        figure(figure_nr);
        figure_nr = figure_nr+1;
        subplot(subplot_size,subplot_size,p);
        histogram(behdata.signed_difference(oktrials),50);
        title(['signed error - pp ', num2str(pp2do(p))]);
        xlim([-100 100]);

        figure(figure_nr);
        figure_nr = figure_nr+1;
        subplot(subplot_size,subplot_size,p);
        histogram(behdata.absolute_difference(oktrials),50);
        title(['error - pp ', num2str(pp2do(p))]);
        xlim([0 100]);
        
    end
    
    %% trial selections
    predictable_trials = ismember(behdata.predictability, {'predictable'});
    unpredictable_trials = ismember(behdata.predictability, {'unpredictable'});

    early_cue_trials = ismember(behdata.cue_timing, {'early'});
    middle_cue_trials = ismember(behdata.cue_timing, {'middle'});
    late_cue_trials = ismember(behdata.cue_timing, {'late'});

    congruent_trials = ismember(behdata.trial_condition, {'congruent'});
    incongruent_trials = ismember(behdata.trial_condition, {'incongruent'});

    stable_cue_trials = ismember(behdata.flicker_type, {'stable'});
    high_freq_cue_trials = ismember(behdata.flicker_type, {'high_freq'});
    low_freq_cue_trials = ismember(behdata.flicker_type, {'low_freq'});
    
    left_target_trials = ismember(behdata.target_bar, {'left'});
    right_target_trials = ismember(behdata.target_bar, {'right'});

    
    %% extract data of interest
    overall_dt(p,1) = mean(behdata.idle_reaction_time_in_ms(oktrials));
    overall_error(p,1) = mean(behdata.absolute_difference(oktrials));

    congruency_decisiontime(p,1) = mean(behdata.idle_reaction_time_in_ms(congruent_trials&oktrials));
    congruency_decisiontime(p,2) = mean(behdata.idle_reaction_time_in_ms(incongruent_trials&oktrials));

    congruency_error(p,1) = mean(behdata.absolute_difference(congruent_trials&oktrials));
    congruency_error(p,2) = mean(behdata.absolute_difference(incongruent_trials&oktrials));

    predictability_decisiontime(p,1) = mean(behdata.idle_reaction_time_in_ms(congruent_trials&predictable_trials&oktrials));
    predictability_decisiontime(p,2) = mean(behdata.idle_reaction_time_in_ms(incongruent_trials&predictable_trials&oktrials));
    predictability_decisiontime(p,3) = mean(behdata.idle_reaction_time_in_ms(congruent_trials&unpredictable_trials&oktrials));
    predictability_decisiontime(p,4) = mean(behdata.idle_reaction_time_in_ms(incongruent_trials&unpredictable_trials&oktrials));

    predictability_error(p,1) = mean(behdata.absolute_difference(congruent_trials&predictable_trials&oktrials));
    predictability_error(p,2) = mean(behdata.absolute_difference(incongruent_trials&predictable_trials&oktrials));
    predictability_error(p,3) = mean(behdata.absolute_difference(congruent_trials&unpredictable_trials&oktrials));
    predictability_error(p,4) = mean(behdata.absolute_difference(incongruent_trials&unpredictable_trials&oktrials));

    timing_decisiontime(p,1) = mean(behdata.idle_reaction_time_in_ms(congruent_trials&early_cue_trials&oktrials));
    timing_decisiontime(p,2) = mean(behdata.idle_reaction_time_in_ms(incongruent_trials&early_cue_trials&oktrials));
    timing_decisiontime(p,3) = mean(behdata.idle_reaction_time_in_ms(congruent_trials&middle_cue_trials&oktrials));
    timing_decisiontime(p,4) = mean(behdata.idle_reaction_time_in_ms(incongruent_trials&middle_cue_trials&oktrials));
    timing_decisiontime(p,5) = mean(behdata.idle_reaction_time_in_ms(congruent_trials&late_cue_trials&oktrials));
    timing_decisiontime(p,6) = mean(behdata.idle_reaction_time_in_ms(incongruent_trials&late_cue_trials&oktrials));

    timing_error(p,1) = mean(behdata.absolute_difference(congruent_trials&early_cue_trials&oktrials));
    timing_error(p,2) = mean(behdata.absolute_difference(incongruent_trials&early_cue_trials&oktrials));
    timing_error(p,3) = mean(behdata.absolute_difference(congruent_trials&middle_cue_trials&oktrials));
    timing_error(p,4) = mean(behdata.absolute_difference(incongruent_trials&middle_cue_trials&oktrials));
    timing_error(p,5) = mean(behdata.absolute_difference(congruent_trials&late_cue_trials&oktrials));
    timing_error(p,6) = mean(behdata.absolute_difference(incongruent_trials&late_cue_trials&oktrials));

    cue_flicker_decisiontime(p,1) = mean(behdata.idle_reaction_time_in_ms(congruent_trials&stable_cue_trials&oktrials));
    cue_flicker_decisiontime(p,2) = mean(behdata.idle_reaction_time_in_ms(incongruent_trials&stable_cue_trials&oktrials));
    cue_flicker_decisiontime(p,3) = mean(behdata.idle_reaction_time_in_ms(congruent_trials&high_freq_cue_trials&oktrials));
    cue_flicker_decisiontime(p,4) = mean(behdata.idle_reaction_time_in_ms(incongruent_trials&high_freq_cue_trials&oktrials));
    cue_flicker_decisiontime(p,5) = mean(behdata.idle_reaction_time_in_ms(congruent_trials&low_freq_cue_trials&oktrials));
    cue_flicker_decisiontime(p,6) = mean(behdata.idle_reaction_time_in_ms(incongruent_trials&low_freq_cue_trials&oktrials));

    cue_flicker_error(p,1) = mean(behdata.absolute_difference(congruent_trials&stable_cue_trials&oktrials));
    cue_flicker_error(p,2) = mean(behdata.absolute_difference(incongruent_trials&stable_cue_trials&oktrials));
    cue_flicker_error(p,3) = mean(behdata.absolute_difference(congruent_trials&low_freq_cue_trials&oktrials));
    cue_flicker_error(p,4) = mean(behdata.absolute_difference(incongruent_trials&low_freq_cue_trials&oktrials));
    cue_flicker_error(p,5) = mean(behdata.absolute_difference(congruent_trials&high_freq_cue_trials&oktrials));
    cue_flicker_error(p,6) = mean(behdata.absolute_difference(incongruent_trials&high_freq_cue_trials&oktrials));
    

    %% calculate aggregates of interest
    % always incongruent - congruent
    congruency_dt_effect(p,1) = congruency_decisiontime(p,2) - congruency_decisiontime(p,1);
    congruency_er_effect(p,1) = congruency_error(p,2) - congruency_error(p,1);

    predictability_labels = {"predictable", "unpredictable"};
    predictability_dt_effect(p,1) = predictability_decisiontime(p,2) - predictability_decisiontime(p,1);
    predictability_dt_effect(p,2) = predictability_decisiontime(p,4) - predictability_decisiontime(p,3);
    
    predictability_er_effect(p,1) = predictability_error(p,2) - predictability_error(p,1);
    predictability_er_effect(p,2) = predictability_error(p,4) - predictability_error(p,3);

    timing_labels = {"early", "middle", "late"};
    timing_dt_effect(p,1) = timing_decisiontime(p,2) - timing_decisiontime(p,1);
    timing_dt_effect(p,2) = timing_decisiontime(p,4) - timing_decisiontime(p,3);
    timing_dt_effect(p,3) = timing_decisiontime(p,6) - timing_decisiontime(p,5);

    timing_er_effect(p,1) = timing_error(p,2) - timing_error(p,1);
    timing_er_effect(p,2) = timing_error(p,4) - timing_error(p,3);
    timing_er_effect(p,3) = timing_error(p,6) - timing_error(p,5);

    cue_flicker_labels = {"stable", "low frequency", "high frequency"};
    cue_flicker_dt_effect(p,1) = cue_flicker_decisiontime(p,2) - cue_flicker_decisiontime(p,1);
    cue_flicker_dt_effect(p,2) = cue_flicker_decisiontime(p,4) - cue_flicker_decisiontime(p,3);
    cue_flicker_dt_effect(p,3) = cue_flicker_decisiontime(p,6) - cue_flicker_decisiontime(p,5);

    cue_flicker_er_effect(p,1) = cue_flicker_error(p,2) - cue_flicker_error(p,1);
    cue_flicker_er_effect(p,2) = cue_flicker_error(p,4) - cue_flicker_error(p,3);
    cue_flicker_er_effect(p,3) = cue_flicker_error(p,6) - cue_flicker_error(p,5);

    %% plot individuals
    dt_lim = 1200;
    er_lim = 30;

    if plot_individuals
        figure(figure_nr);
        figure_nr = figure_nr+1;
        subplot(subplot_size,subplot_size,p);
        bar([1:2], congruency_decisiontime(p,1:2)); 
        xticks([1,2]);
        xticklabels(labels);
        ylim([0 dt_lim]);
        title(['decision time, all trials - pp ', num2str(pp)]);

        figure(figure_nr);
        figure_nr = figure_nr+1;
        subplot(subplot_size,subplot_size,p);
        bar([1:2], congruency_error(p,1:2)); 
        xticks([1,2]);
        xticklabels(labels);
        ylim([0 er_lim]);
        title(['error, all trials - pp ', num2str(pp)]);
    end
end


%% all pp plot
if plot_averages

    figure; 
    subplot(3,1,1);
    bar(ppnum, overall_dt(:,1));
    title('overall decision time');
    ylim([0 dt_lim]);

    subplot(3,1,2);
    bar(ppnum, overall_error(:,1));
    title('overall error');
    ylim([0 50]);

    subplot(3,1,3);
    bar(ppnum, percentageok);
    title('percentage ok trials');
    ylim([90 100]);
    xlabel('pp #');

    %% does it work at all?
    figure;
    subplot(1,2,1);
    bar([1:2], mean(congruency_decisiontime)); 
    xticks([1,2]);
    xticklabels(labels);
    ylim([0 dt_lim]);
    xlim([0.3 2.7]);
    title('decision time, all trials');

    subplot(1,2,2);
    bar([1:2], mean(congruency_error)); 
    xticks([1,2]);
    xticklabels(labels);
    ylim([0 er_lim]);
    xlim([0.3 2.7]);
    title('error, all trials');

    %% grand average bar graphs of data as function of condition
    % predictability of cue
    figure; 
    subplot(1,2,1)
    hold on
    bar([1:2], mean(predictability_dt_effect)); 
    plot([1:2], predictability_dt_effect', 'Color', [0, 0, 0, 0.25]);
    xticks([1,2]);
    xticklabels(predictability_labels);
    ylim([-30 150]);
    xlim([0.3 2.7]);
    title('dt effect of predictability');

    subplot(1,2,2)
    hold on
    bar([1:2], mean(predictability_er_effect)); 
    plot([1:2], predictability_er_effect', 'Color', [0, 0, 0, 0.25]);
    xticks([1,2]);
    xticklabels(predictability_labels);
    ylim([-1 7]);
    xlim([0.3 2.7]);
    title('er effect of predictability');
    
    % timing of cue
    figure; 
    subplot(1,2,1)
    hold on
    bar([1:3], mean(timing_dt_effect)); 
    plot([1:3], timing_dt_effect', 'Color', [0, 0, 0, 0.25]);
    xticks([1,2,3]);
    xticklabels(timing_labels);
    xlim([0.3 3.7]);
    title('dt effect of timing');

    subplot(1,2,2)
    hold on
    bar([1:3], mean(timing_er_effect)); 
    plot([1:3], timing_er_effect', 'Color', [0, 0, 0, 0.25]);
    xticks([1,2,3]);
    xticklabels(timing_labels);
    xlim([0.3 3.7]);
    title('er effect of timing');

    % stability of cue - raw data
    % figure;
    % subplot(1,3,1)
    % bar([1:2], mean(cue_flicker_decisiontime(:,1:2)));
    % xticks([1,2]);
    % xticklabels(labels);
    % ylim([0 dt_lim]);
    % xlim([0.3 2.7]);
    % title('stable')
    % 
    % subplot(1,3,2)
    % bar([1:2], mean(cue_flicker_decisiontime(:,3:4)));
    % xticks([1,2]);
    % xticklabels(labels);
    % ylim([0 dt_lim]);
    % xlim([0.3 2.7]);
    % title('low frequency')
    % 
    % subplot(1,3,3)
    % bar([1:2], mean(cue_flicker_decisiontime(:,5:6)));
    % xticks([1,2]);
    % xticklabels(labels);
    % ylim([0 dt_lim]);
    % xlim([0.3 2.7]);
    % title('high frequency')
    % 
    % figure;
    % subplot(1,3,1)
    % bar([1:2], mean(cue_flicker_error(:,1:2)));
    % xticks([1,2]);
    % xticklabels(labels);
    % ylim([0 er_lim]);
    % xlim([0.3 2.7]);
    % title('stable')
    % 
    % subplot(1,3,2)
    % bar([1:2], mean(cue_flicker_error(:,3:4)));
    % xticks([1,2]);
    % xticklabels(labels);
    % ylim([0 er_lim]);
    % xlim([0.3 2.7]);
    % title('low frequency')
    % 
    % subplot(1,3,3)
    % bar([1:2], mean(cue_flicker_error(:,5:6)));
    % xticks([1,2]);
    % xticklabels(labels);
    % ylim([0 er_lim]);
    % xlim([0.3 2.7]);
    % title('high frequency')
    
    % stability of cue 
    figure; 
    subplot(1,2,1)
    hold on
    bar([1:3], mean(cue_flicker_dt_effect)); 
    plot([1:3], cue_flicker_dt_effect', 'Color', [0, 0, 0, 0.25]);
    xticks([1,2,3]);
    xticklabels(cue_flicker_labels);
    xlim([0.3 3.7]);
    title('dt effect of stability');

    subplot(1,2,2)
    hold on
    bar([1:3], mean(cue_flicker_er_effect)); 
    plot([1:3], cue_flicker_er_effect', 'Color', [0, 0, 0, 0.25]);
    xticks([1,2,3]);
    xticklabels(cue_flicker_labels);
    xlim([0.3 3.7]);
    title('er effect of stability');
     
end

%% see performance per block (for fun for participants)
if see_performance
    n_blocks = 24;
    x = (1:n_blocks);
    block_performance = zeros(1, length(x));
    block_performance_std = zeros(1, length(x));
    block_speed = zeros(1, length(x));
    block_speed_std = zeros(1, length(x));
    
    for i = x
        block_performance(i) = mean(behdata.performance(behdata.block == i));
        block_performance_std(i) = std(behdata.performance(behdata.block == i));
        block_speed(i) = mean(behdata.idle_reaction_time_in_ms(behdata.block == i));
        block_speed_std(i) = std(behdata.idle_reaction_time_in_ms(behdata.block == i));
    end
    
    figure;
    hold on
    plot(block_performance)
    %errorbar(block_performance, block_performance_std)
    ylim([50 100])
    xlim([1 n_blocks])
    ylabel('Performance score')
    yyaxis right
    plot(block_speed)
    %errorbar(block_speed, block_speed_std)
    ylim([100 2000])
    ylabel('Reaction time (ms)')
    xlabel('Block number')
    xticks(x)
end
