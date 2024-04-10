%% Script for creating (half-)violing plots.
% So run the scripts that make your data first.
% by Anna, 04-07-2023

dataset(1:41, 1) = capture_cue_effect(:,3);
dataset(1:16, 2) = 1;
dataset(17:41, 2) = 2;
long_format = 1;

ft_size = 26;

%% Convert to long-format if necessary
if not(long_format)
    dataset_original = dataset;
    [len, wid]  = size(dataset_original);
    dataset = zeros(len*wid, 2);
    for i = 1:wid
        dataset(i*len-len+1:len*i, 1) = dataset_original(:, i); %dit werkt
        dataset(i*len-len+1:len*i, 2) = repelem(i, len)';
    end
    disp('dataset succesfully converted')
end

%% Necessary stuff
x_scatter_overlap = max(dataset(:,1)) / 35; % make smaller for more rows 
y_scatter_overlap = max(dataset(:,1)) / 0.06; % make smaller for less spacec
kernel_plot_size = max(dataset(:,1)) * 0.3;

% x_scatter_overlap = max(dataset(:,1)) / 14.5; % make smaller for more rows 
% y_scatter_overlap = max(dataset(:,1)) / 0.5; % make smaller for less space
% kernel_plot_size = max(dataset(:,1)) / 1.5;

d = 0.2; % set distance between elements of one group
ld = 1.5; % set distance between groups
w = 0.1; % set half of total width of boxplot

n_groups = max(unique(dataset(:,2)));
f = zeros(length(n_groups), 100);
xi = zeros(length(n_groups), 100);
stats = zeros(length(n_groups), 5);

total_len = length(dataset(:,1));
group_len = total_len/n_groups;

colours = [233, 194, 117;...
           191, 149, 192];...

colours = colours/255;

% colours = [1 0 0;
%            1 0 1;
%            0 0 1];

%% Create kernel density's for data
for i = 1:n_groups
    disp(['Calculating kernel density and stats for group ', num2str(i)]);
    [f(i,:), xi(i,:)] = ksdensity(dataset(dataset(:,2) == i, 1));
    stats(i,:) = [prctile(dataset(dataset(:,2) == i, 1), 5),...
        prctile(dataset(dataset(:,2) == i, 1), 25), ...
        mean(dataset(dataset(:,2) == i)), ...
        prctile(dataset(dataset(:,2) == i, 1), 75), ...
        prctile(dataset(dataset(:,2) == i, 1), 95)];
end

%% Plot that thang

% position = [1:n_groups]+[0, ld*1, ld*2];
position = [1:n_groups]+[0, ld*1];
lengths = [16; 25];
figure;
hold on 

for i = 1:n_groups

    % Scatter dot density
    to_scatter = zeros(lengths(i), 2);
    changed = true;
    changed_dim = true;
    to_scatter(:,1) = dataset(dataset(:,2) == i, 1);
    to_scatter(:,1) = sort(to_scatter(:,1));
    to_scatter(:,2) = 1;
    dim  = 0;

    while changed_dim
        dim = dim + 1;
        changed_dim = false;
        changed = true;
        while changed && length(find(to_scatter(:,2) == dim)) > 1
            changed = false;
            current_dim = find(to_scatter(:,2) == dim);
            for j = current_dim(2:end)'
                current_dim = find(to_scatter(:,2) == dim);
                idx_comp = max(current_dim(current_dim < j));
                if abs(diff([to_scatter(j, 1), to_scatter(idx_comp, 1)])) < x_scatter_overlap && to_scatter(j,2) == to_scatter(idx_comp,2)
                    to_scatter(j, 2) = to_scatter(j, 2) + 1;
                    changed = true;
                    changed_dim = true;
                end
            end
        end
    end
  
    scatter(position(i)-d-to_scatter(:,2)/y_scatter_overlap, ...
        to_scatter(:,1), 45, ...
        colours(i,:), 'filled', '', ...
        'MarkerEdgeColor', 'white',...
        'LineWidth', 0.5, 'MarkerFaceAlpha', 0.8)
    
    % Plot kdensity distribution
    patch('XData', position(i)+d+[f(i,:),zeros(1,numel(xi(i,:)),1),0]*kernel_plot_size,...
        'yData', [xi(i,:),xi(i,:),xi(i,1)],'FaceColor', colours(i,:),...
        'EdgeColor', colours(i,:));
    % change i+d+ at start of previous line to i-d- if you want to left-right flip the patch.
    
    % Plot boxplot (middle line is mean)
    line([position(i), position(i)], [stats(i,1), stats(i,5)], 'Color', 'black', 'LineWidth', 1);
    patch([position(i)-w, position(i)-w, position(i)+w, position(i)+w], ...
        [stats(i,2), stats(i, 4), stats(i, 4), stats(i, 2)], colours(i,:), 'LineWidth', 1);
    line([position(i)-w, position(i)+w], [stats(i,3), stats(i,3)], 'Color', 'black', 'LineWidth', 2);
end

%ylim([0, max(dataset(:,1))+500]);
%xlim([0, max(position)+2]);
ylabel('Saccade rate effect (Hz)');
xticks(position);
xticklabels({'Experiment 1', 'Experiment 2'});
xlim([0, 5]);
hold off
set(gcf,'position',[0,0, 1080, 1600])
fontsize(ft_size,"points");