%% 1-way RM anova on behavioural data
% X must be n-by-3; dependent variable=column 1, independent variable=column 2; subject=column 3). 

% reaction time
reaction_time_anova = cat(2, ...
    cat(1, decisiontime(:,1), decisiontime(:,2), decisiontime(:,3)), ...
    cat(1, ones(size(decisiontime, 1), 1), ones(size(decisiontime, 1), 1)*2, ones(size(decisiontime, 1), 1)*3), ...
    cat(1, [1: size(decisiontime, 1)]', [1: size(decisiontime, 1)]', [1: size(decisiontime, 1)]'));
[p_subj, p_iv, eta2, part_eta2] = RMAOV1(reaction_time_anova);

% error
error_anova = cat(2, ...
    cat(1, error(:,1), error(:,2), error(:,3)), ...
    cat(1, ones(size(error, 1), 1), ones(size(error, 1), 1)*2, ones(size(error, 1), 1)*3), ...
    cat(1, [1: size(error, 1)]', [1: size(error, 1)]', [1: size(error, 1)]'));
[p_subj, p_iv, eta2, part_eta2] = RMAOV1(error_anova);

% proportion wrong-key use (in trials where the keys are different)
wrong_key_anova = cat(2, ...
    cat(1, proportion_wrong(:,1), proportion_wrong(:,2), proportion_wrong(:,3)), ...
    cat(1, ones(size(proportion_wrong, 1), 1), ones(size(proportion_wrong, 1), 1)*2, ones(size(proportion_wrong, 1), 1)*3), ...
    cat(1, [1: size(proportion_wrong, 1)]', [1: size(proportion_wrong, 1)]', [1: size(proportion_wrong, 1)]'));
[p_subj, p_iv, eta2, part_eta2] = RMAOV1(wrong_key_anova);

%% 1-way RM anova on mixture model parameters 
% precision
precision_anova = cat(2, ...
    cat(1, precision(:,1), precision(:,2), precision(:,3)), ...
    cat(1, ones(size(precision, 1), 1), ones(size(precision, 1), 1)*2, ones(size(precision, 1), 1)*3), ...
    cat(1, [1: size(precision, 1)]', [1: size(precision, 1)]', [1: size(precision, 1)]'));
[p_subj, p_iv, eta2, part_eta2] = RMAOV1(precision_anova );

% pT
pT_anova = cat(2, ...
    cat(1, pT(:,1), pT(:,2), pT(:,3)), ...
    cat(1, ones(size(pT, 1), 1), ones(size(pT, 1), 1)*2, ones(size(pT, 1), 1)*3), ...
    cat(1, [1: size(pT, 1)]', [1: size(pT, 1)]', [1: size(pT, 1)]'));
[p_subj, p_iv, eta2, part_eta2] = RMAOV1(pT_anova);

% pNT
pNT_anova = cat(2, ...
    cat(1, pNT(:,1), pNT(:,2), pNT(:,3)), ...
    cat(1, ones(size(pNT, 1), 1), ones(size(pNT, 1), 1)*2, ones(size(pNT, 1), 1)*3), ...
    cat(1, [1: size(pNT, 1)]', [1: size(pNT, 1)]', [1: size(pNT, 1)]'));
[p_subj, p_iv, eta2, part_eta2] = RMAOV1(pNT_anova );

% pU
pU_anova = cat(2, ...
    cat(1, pU(:,1), pU(:,2), pU(:,3)), ...
    cat(1, ones(size(pU, 1), 1), ones(size(pU, 1), 1)*2, ones(size(pU, 1), 1)*3), ...
    cat(1, [1: size(pU, 1)]', [1: size(pU, 1)]', [1: size(pU, 1)]'));
[p_subj, p_iv, eta2, part_eta2] = RMAOV1(pU_anova );

%% All-to-all correlation
correlation_data_v1 = zeros(16, 15);
correlation_data_v1(:,1) = 1:16;
correlation_data_v1(:,2) = 1:16;
correlation_data_v1(:,3) = decisiontime(:,3) -  decisiontime(:,1);
correlation_data_v1(:,4) = error(:,3) -  error(:,1);
correlation_data_v1(:,5) = overall_dt;
correlation_data_v1(:,6) = overall_error;
correlation_data_v1(:,7) = proportion_wrong(:,3);
correlation_data_v1(:,8) = mean(decisiontime_std(:,1:3),2);
correlation_data_v1(:,9) = taskconfusion_scores(1:16, 2);
correlation_data_v1(:,10) = impulsivity_scores(1:16);
correlation_data_v1(:,11) = hallucination_scores(1:16);
% correlation_data_v1(:,12) = capture_cue_effect(:,2);
% correlation_data_v1(:,13) = capture_cue_effect(:,3);
% correlation_data_v1(:,14) = capture_cue_effect(:,2);
% correlation_data_v1(:,15) = capture_cue_effect(:,3);

correlation_variables = {'session','ppn', 'rt_effect','er_effect', ...
    'rt_overall', 'er_overall', 'wrong_key', 'rt_var', 'task_confusion', ...
    'impulsivity', 'hallucination', 'sacc_capture', 'sacc_probe', ...
    'gaze_capture', 'gaze_probe'};


frevede_allbyall_correlations(master(:,[3:4,8,10:12,14]), correlation_variables(:,[3:4,8,10:12,14]), 1)

%% Explore probe correlations further
% impulsivity vs. saccade probe response
figure;

subplot(2,2,1)
scatter(correlation_data_v1(:,10), correlation_data_v1(:,13))
lsline;
xlabel('Impulsivity')
ylabel('Saccade bias after probe')

% impulsivity vs gaze probe response
subplot(2,2,2)
scatter(correlation_data_v1(:,10), correlation_data_v1(:,15))
lsline;
xlabel('Impulsivity')
ylabel('Gaze bias after probe')

% hallucination vs saccade probe response
subplot(2,2,3)
scatter(correlation_data_v1(:,11), correlation_data_v1(:,13))
lsline;
xlabel('Hallucination')
ylabel('Saccade bias after probe')

% hallucination vs gaze probe response
subplot(2,2,4)
scatter(correlation_data_v1(:,11), correlation_data_v1(:,15))
lsline;
xlabel('Hallucination')
ylabel('Gaze bias after probe')

%% Explore interesting&significant correlations further
figure;

%pairs_to_plot = [4 3; 4 11; 6 11; 10 11; 12 3; 12 5; 12 7; 12 13; 14 4; 14 12; 15 7; 15 12; 8 11; 8 10];
pairs_to_plot = [3 12];
names_to_plot = {'Session','Participant number', 'Decision time effect','Error effect', ...
    'Decision time overall', 'Error overall', 'Wrong key usage', 'Decision time SD', 'Task confusion', ...
    'Impulsivity', 'Hallucination', 'Saccade - capture', 'Saccade - probe', ...
    'Gaze - capture', 'Gaze - probe'};

subplot_size = round(sqrt(size((pairs_to_plot),1)),0);

sc = zeros(length(master),3);
sc(1:16,1) = 1;
sc(17:41,3) = 1;

sz = 150;

for i = 1:size((pairs_to_plot),1)
    
    subplot(subplot_size,subplot_size,i)
    [rho, pval] = corr(master(1:16,pairs_to_plot(i,1)), master(1:16,pairs_to_plot(i,2)));
    hold on
    % plot([19.4014 19.4014], [-0.2 0.4], '--', 'LineWidth', 3, 'Color', [0.6, 0.6, 0.6]);
    scatter(master(:,pairs_to_plot(i,1)), master(:,pairs_to_plot(i,2)), sz, 'w', 'filled')
    h = lsline;
    h.LineWidth = 3.5;
    h.Color = [0.6, 0.6, 0.6];
    % scatter(master(1:16,pairs_to_plot(i,1)), master(1:16,pairs_to_plot(i,2)), sz, 'k', 'filled')
    scatter(master(1:16,pairs_to_plot(i,1)), master(1:16,pairs_to_plot(i,2)), sz, [240, 172, 36]/255, 'filled')
    scatter(master(17:41,pairs_to_plot(i,1)), master(17:41,pairs_to_plot(i,2)), sz, [191, 86, 228]/255, 'filled')
    % scatter(master(17:41,pairs_to_plot(i,1)), master(17:41,pairs_to_plot(i,2)), sz, [0.6 0.6 0.6], 'filled')
    % scatter(master([11,13],pairs_to_plot(i,1)), master([11,13],pairs_to_plot(i,2)), sz, 'mx')
    % scatter(master(master((master(17:41,3)>19.5),2)+16,pairs_to_plot(i,1)), master(master((master(17:41,3)>19.5),2)+16,pairs_to_plot(i,2)), sz,[223,52,163]/255, 'filled');
    t = title(sprintf('r = %.3f, p = %.3f', rho, pval));
    ylim([-0.2 0.4]);
    xlim([-100 150]);
    hold off
    if pval < 0.05
        t.Color = 'blue';
    end
    xlabel("Decision time effect (ms)")
    ylabel("Rate effect (Hz)")
    set(gcf,'position',[0,0, 1000,1000])
    fontsize(35,"points");

end

%% Compare behavioural effects of both versions
rt_effect_1 = decisiontime(1:16,3) - decisiontime(1:16,1);
rt_effect_2 = decisiontime(17:41,3) - decisiontime(17:41,1);
er_effect_1 = error(1:16,3) - error(1:16,1);
er_effect_2 = error(17:41,3) - error(17:41,1);

to_plot_dt = zeros(size(rt_effect_2, 1),2);
to_plot_dt(1:length(rt_effect_1), 1) = rt_effect_1;
to_plot_dt(length(rt_effect_1)+1:end, 1) = NaN;
to_plot_dt(1:length(rt_effect_2), 2) = rt_effect_2;

figure;
boxplot(to_plot_dt)

to_plot_er = zeros(size(er_effect_2, 1),2);
to_plot_er(1:length(er_effect_1), 1) = er_effect_1;
to_plot_er(length(er_effect_1)+1:end, 1) = NaN;
to_plot_er(1:length(er_effect_2), 2) = er_effect_2;

figure;
boxplot(to_plot_er)

[h, p, ci, stats] = ttest2(rt_effect_1, rt_effect_2) %p=0.1488
[h, p, ci, stats] = ttest2(er_effect_1, er_effect_2) %p=0.7896
