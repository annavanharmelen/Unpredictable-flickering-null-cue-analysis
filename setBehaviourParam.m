function [bar_size, colours, dark_colours, labels, subplot_size, percentageok, all_conditions_dt, all_conditions_er] = setBehaviourParam(pp2do)
%SETBEHAVIOURPARAM sets the parameters for analysing the behavioural data.
bar_size = 0.8;

colours = [114, 182, 161;...
           149, 163, 192;...
           233, 150, 117;...
           194, 102, 162];
colours = colours/255;

dark_colours = [50, 79, 70;
                58, 67, 88;
                105, 67, 52;
                92, 49, 77];
dark_colours = dark_colours/255;

labels = {'congruent', 'incongruent'};

subplot_size = ceil(sqrt(size(pp2do, 2)));

percentageok = zeros(size(pp2do));

all_conditions_dt = [];
all_conditions_er = [];

end

