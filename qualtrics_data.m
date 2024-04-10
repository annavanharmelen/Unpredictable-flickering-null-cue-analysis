%clear all
%close all
%clc

%% load data
data_path = "C:\Users\annav\Documents\Jottacloud\Neuroscience\Year 2\Thesis\Data\Vidi1 - null-cue gaze-bias\qualtrics_data\Vidi 1. null-cue_June 19, 2023_08.42.csv";
data = readtable(data_path);

%% show participant distributions
% figure;
% hist(data.Age);

%age
mean(data.Age(1:16))
std(data.Age(1:16))
max(data.Age(1:16))
min(data.Age(1:16))
mean(data.Age(17:41))
std(data.Age(17:41))
max(data.Age(17:41))
min(data.Age(17:41))

%gender
%female = 1, non-binary = 2, male = 3, other/prefer not to say = 4
sum(data.GenderIdentity(1:16) == 1)
sum(data.GenderIdentity(1:16) == 2)
sum(data.GenderIdentity(1:16) == 3)
sum(data.GenderIdentity(17:41) == 1)
sum(data.GenderIdentity(17:41) == 2)
sum(data.GenderIdentity(17:41) == 3)

%handedness
% right = 1, left = 2, ambi = 3
sum(data.Handedness(1:16) == 1)
sum(data.Handedness(1:16) == 2)
sum(data.Handedness(1:16) == 3)
sum(data.Handedness(17:41) == 1)
sum(data.Handedness(17:41) == 2)
sum(data.Handedness(17:41) == 3)

%vision
% 1 = normal, 2 = c-t-n glasses, 3 = c-t-n lenses, 4 = not normal
sum(data.Vision(1:16) == 1)
sum(data.Vision(1:16) == 2)
sum(data.Vision(1:16) == 3)
sum(data.Vision(1:16) == 4)
sum(data.Vision(17:41) == 1)
sum(data.Vision(17:41) == 2)
sum(data.Vision(17:41) == 3)
sum(data.Vision(1:16) == 4)

%% calculate impulsivity scores per participant
impulsivity_scores = data.Impulsivity_1_2 + data.Impulsivity_1_5...
    + data.Impulsivity_1_6 + data.Impulsivity_1_7...
    + (5-data.Impulsivity_1_1) + (5-data.Impulsivity_1_3)...
    + (5-data.Impulsivity_1_4) + (5-data.Impulsivity_1_8);

%% calculate hallucination scores per participant
hallucination_scores = data.Hallucination_1_1 + data.Hallucination_1_2...
    + data.Hallucination_1_3 + data.Hallucination_1_4 + data.Hallucination_1_5...
    + data.Hallucination_1_6 + data.Hallucination_1_7 + data.Hallucination_1_8...
    + data.Hallucination_1_9 + data.Hallucination_1_10 + data.Hallucination_1_11...
    + data.Hallucination_1_12 + data.Hallucination_1_13;

%% show scatterplot between capture effect size and impulsivity and calculate correlation
figure;
scatter(abs(capture_effectsize(:,3)), impulsivity_scores(17:38));
ylabel("Impulsivity scores");
xlabel("Capture-effect size (absolute)");
ylim([8 24])
figure;
scatter(capture_effectsize(:,3), impulsivity_scores(17:38));
ylabel("Impulsivity scores");
xlabel("Capture-effect size");
ylim([8 24])

[rho, pval] = corr(capture_effectsize(:,3), impulsivity_scores(17:38))
[rho, pval] = corr(abs(capture_effectsize(:,3)), impulsivity_scores(17:38))
%% show scatterplot between capture effect size and hallucination and calculate correlation
figure;
scatter(abs(capture_effectsize(:,3)), hallucination_scores(17:38));
ylabel("Hallucination scores");
xlabel("Capture-effect size (absolute)");
ylim([13 52])
figure;
scatter(capture_effectsize(:,3), hallucination_scores(17:38));
ylabel("Hallucination scores");
xlabel("Capture-effect size");
ylim([13 52])

[rho, pval] = corr(capture_effectsize(:,3), hallucination_scores(17:38))
[rho, pval] = corr(abs(capture_effectsize(:,3)), hallucination_scores(17:38))

