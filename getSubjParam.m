function param = getSubjParam(pp)

%% participant-specific notes

%% set path and pp-specific file locations
unique_numbers = [64, 97, 50, 32, 77, 31, 34, 92, 89]; %needs to be in the right order

param.path = 'C:\Users\annav\Documents\Jottacloud\Neuroscience PhD\Experiments\Vidi experiments\Data\Vidi4 - Unpredictable flickering\';

if pp < 10
    param.subjName = sprintf('pp0%d', pp);
else
    param.subjName = sprintf('pp%d', pp);
end

log_string = sprintf('data_session_%d.csv', pp);
param.log = [param.path, log_string];

eds_string = sprintf('%d_%d.asc', pp, unique_numbers(pp));
param.eds = [param.path, eds_string];