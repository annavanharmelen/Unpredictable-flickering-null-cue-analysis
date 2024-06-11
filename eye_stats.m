%% Script for doing stats on saccade and gaze bias data.
% So run those scripts first.
% by Anna, 11-06-2024

%% Saccade bias data - stats
statcfg.xax = saccade.time;
statcfg.npermutations = 1000;
statcfg.clusterStatEvalaluationAlpha = 0.05;
statcfg.nsub = s;
statcfg.statMethod = 'montecarlo';
%statcfg.statMethod = 'analytic';

ft_size = 26;

data_cond1 = d3(:,2,951:1951);
data_cond2 = zeros(size(data_cond1));

stat = frevede_ftclusterstat1D(statcfg, data_cond1, data_cond2)

%% Saccade bias data - plot only effect
mask_xxx = double(stat.mask);
mask_xxx(mask_xxx==0) = nan; % nan data that is not part of mark

figure; hold on;
ylimit = [-0.3, 0.3];
% p1 = frevede_errorbarplot(saccade.time, squeeze(d3(:,2,:)), [1,0,0], 'se');
% p2 = frevede_errorbarplot(saccade.time, squeeze(d3(:,3,:)), [1,0,1], 'se');
% p3 = frevede_errorbarplot(saccade.time, squeeze(d3(:,4,:)), [0,0,1], 'se');

p4 = frevede_errorbarplot(saccade.time, squeeze(d3(:,2,:)), colours(4,:), 'se');
p4.LineWidth = 2.5;
plot(xlim, [0,0], '--', 'LineWidth',2, 'Color', [0.6, 0.6, 0.6]);
plot([0,0], ylimit, '--', 'LineWidth',2, 'Color', [0.6, 0.6, 0.6]);

xlim(xlimtoplot);
sig = plot(saccade.time(951:1951), mask_xxx*-0.18, 'Color', 'k', 'LineWidth', 4); % verticaloffset for positioning of the "significance line"
% ylim(ylimit+[0 0.0001]);
ylabel('Rate (Hz)');
xlabel('Time (ms)');
% set(gcf,'position',[0,0, 1800,900])
% fontsize(ft_size*1.5,"points")
% legend([p1,p2,p3], saccade.label(2:4));

%% Saccade bias data - plot all 3
mask1_xxx = double(stat.mask);
mask1_xxx(mask1_xxx==0) = nan; % nan data that is not part of mark

figure; hold on;

p1 = frevede_errorbarplot(saccade.time, squeeze(d3(:,4,:)), colours(1,:), 'se');
p2 = frevede_errorbarplot(saccade.time, squeeze(d3(:,6,:)), colours(2,:), 'se');
p1.LineWidth = 2.5;
p2.LineWidth = 2.5;
plot(xlim, [0,0], '--','LineWidth',2, 'Color', [0.6, 0.6, 0.6]);
plot([0,0], [-0.5, 1], '--','LineWidth',2, 'Color', [0.6, 0.6, 0.6]);
plot([1500, 1500], [-0.5, 1], '--','LineWidth',2, 'Color', [0.6, 0.6, 0.6]);
xlim(xlimtoplot);
sig1 = plot(saccade.time(951:1951), mask1_xxx*-0.3, 'Color', colours(1,:), 'LineWidth', 5); % verticaloffset for positioning of the "significance line"
ylim([-0.5 0.5])
yticks(linspace(-0.5, 1, 7));
ylabel('Rate (Hz)');
xlabel('Time (ms)');
set(gcf,'position',[0,0, 1800,900])
fontsize(ft_size*1.5,"points")
% legend([p1,p2,p3], saccade.label(2:4), 'EdgeColor', 'w', 'Position', [0.25 0.81 0 0]);

%% Gaze bias data - stats
statcfg.xax = gaze.time;
statcfg.npermutations = 1000;
statcfg.clusterStatEvalaluationAlpha = 0.05;
statcfg.nsub = s;
statcfg.statMethod = 'montecarlo';
%statcfg.statMethod = 'analytic';
% 
% data_cond1 = d3(:,5,501:2001);
% data_cond2 = zeros(size(data_cond1));

ft_size = 26;

data_cond1 = d3(:,2,2001:end);
data_cond2 = d3(:,3,2001:end);
data_cond3 = d3(:,4,2001:end);
data_cond4 = zeros(size(data_cond1));

% stat = frevede_ftclusterstat1D(statcfg, data_cond1, data_cond2)

stat1 = frevede_ftclusterstat1D(statcfg, data_cond1, data_cond4)
stat2 = frevede_ftclusterstat1D(statcfg, data_cond2, data_cond4)
stat3 = frevede_ftclusterstat1D(statcfg, data_cond3, data_cond4)


%% Gaze bias data - plot effect
mask_xxx = double(stat.mask);
mask_xxx(mask_xxx==0) = nan; % nan data that is not part of mark

figure; hold on;

ylimit = [-2.5, 1.5];
p4 = frevede_errorbarplot(gaze.time, squeeze(d3(:,5,:)), colours(4,:), 'se');
p4.LineWidth = 2.5;
plot(xlim, [0,0], '--', 'LineWidth',2, 'Color', [0.6, 0.6, 0.6]);
plot([0,0], [ylimit], '--', 'LineWidth',2, 'Color', [0.6, 0.6, 0.6]);
xlim(xlimtoplot);
sig = plot(gaze.time(501:2001), mask_xxx*-0.25, 'Color', [0 0 0], 'LineWidth', 4); % verticaloffset for positioning of the "significance line"
% plot([find(mask_xxx == 1, 1, 'first'), find(mask_xxx == 1, 1, 'first')],...
    % [0, mean(d3(:,5,771))], '--', 'LineWidth',2, 'Color', 'black');
ylim(ylimit)
ylabel('Gaze towardness (px)');
xlabel('Time (ms)');
set(gcf,'position',[0,0, 1800,900])
fontsize(ft_size,"points")

% legend([p1,p2,p3], saccade.label(2:4));


%% Gaze bias - plot all three separately (for probe effect)
% mask1_xxx = double(stat1.mask);
% mask1_xxx(mask1_xxx==0) = nan; % nan data that is not part of mark
% 
% mask2_xxx = double(stat2.mask);
% mask2_xxx(mask2_xxx==0) = nan; % nan data that is not part of mark
% 
% mask3_xxx = double(stat3.mask);
% mask3_xxx(mask3_xxx==0) = nan; % nan data that is not part of mark
% 

figure; hold on;

p1 = frevede_errorbarplot(gaze.time, squeeze(d3(:,2,:)), colours(1,:), 'se');
p2 = frevede_errorbarplot(gaze.time, squeeze(d3(:,3,:)), colours(2,:), 'se');
p3 = frevede_errorbarplot(gaze.time, squeeze(d3(:,4,:)), colours(3,:), 'se');
p1.LineWidth = 2.5;
p2.LineWidth = 2.5;
p3.LineWidth = 2.5;

plot(xlim, [0,0], '--','LineWidth',2, 'Color', [0.6, 0.6, 0.6]);
plot([0,0], [-4, 5], '--','LineWidth',2, 'Color', [0.6, 0.6, 0.6]);
plot([1500, 1500], [-4, 10], '--','LineWidth',2, 'Color', [0.6, 0.6, 0.6]);
xlim(xlimtoplot);

% sig1 = plot(gaze.time(2001:end), mask1_xxx*-1.6, 'Color', colours(1,:), 'LineWidth', 5); % verticaloffset for positioning of the "significance line"
% sig2 = plot(gaze.time(2001:end), mask2_xxx*-1.82, 'Color', colours(2,:), 'LineWidth', 5);
% sig3 = plot(gaze.time(2001:end), mask3_xxx*-2.04, 'Color', colours(3,:), 'LineWidth', 5);
ylim([-4 10])
ylabel('Gaze towardness (px)');
xlabel('Time (ms)');
set(gcf,'position',[0,0, 1800,900])
fontsize(ft_size*1.5,"points")

legend([p1,p2,p3], gaze.label(2:4), 'EdgeColor', 'w', 'Position', [0.25 0.81 0 0]);
