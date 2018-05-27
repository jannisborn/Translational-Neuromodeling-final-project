%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Runs analysis. All subroutines are called from here.
%
% Lukas Vogelsang, May 2018
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% (A) DATA ORGANIZATION
%% Make directories
current = pwd;
if ~strcmp(current(end-11:end),'/TNM_project')
    disp('Wrong directory!')
else
    folders = {'behav_w_css','behav_analyzed_perf','behav_analyzed_hgf',...
               'behav_analyzed_hgf_newpriors'};
    for i=1:4
        if ~isfolder(strcat('data/',folders{i}))
            mkdir(strcat('data/',folders{i}));
        end
    end
    disp('Directories are ready!')
end

%% Reorganize data structures
reorganize();

%% Encode cue-stimulus-contingencies
css_encoding();

%% Reject subjects with too many invalid trials
count_irrs()
%% (B) PERFORMANCE ANALYSIS
%% Perform block performance analysis
get_block_performance();

%% Plot block performance
plot_blockperformance();

%% Calculate and plot average block responses
avg_block_performance();
% make merged histograms

%% (C) MODEL-BASED ANALYSIS: HGF
%% Fit HGFs and simulate HGF traces; store all data for later analysis
default_config = 0; % only fix omega3 (var = 0)
hgf_all(default_config);
%hgf_all(0);


%% Analysis and plot of parameter fit
parameter_plot(default_config);

%% Analysis of parameter correlation

%% Analysis of parameter estimation reliability

%% Analysis of traces
fol_name = 'data/behav_analyzed_hgf';
all = dir(strcat(fol_name,'/*.mat'));
k = 3

load(strcat(fol_name,'/',all(k).name));
tapas_hgf_binary_plotTraj(subject.hgf.sim_neutral);
tapas_hgf_binary_plotTraj(subject.hgf.sim_aversive);
%%
fol_name = 'data/behav_raw';
all = dir(strcat(fol_name,'/*.mat'));
k = 4
    load(strcat(fol_name,'/',all(k).name));
    subject = compute_score(subject);
    disp(subject.scores)


%% Manual trace calculation ... pretty
if default_config
    fol_name = 'data/behav_analyzed_hgf';
else
    fol_name = 'data/behav_analyzed_hgf_newpriors';
end

all = dir(strcat(fol_name,'/*.mat'));
figure;
subplot(2,2,3);
for k = 1:length(all)
    load(strcat(fol_name,'/',all(k).name));
    plot(subject.hgf.sim_neutral.traj.mu(:,2));
    hold on;
end
title('\mu_2')
subplot(2,2,1);
for k = 1:length(all)
    load(strcat(fol_name,'/',all(k).name));
    plot(subject.hgf.sim_neutral.traj.mu(:,3));
    hold on;
end
title('\mu_3')

subplot(2,2,4);
for k = 1:length(all)
    load(strcat(fol_name,'/',all(k).name));
    plot(subject.hgf.sim_aversive.traj.mu(:,2));
    hold on;
end
title('\mu_2')

subplot(2,2,2);
for k = 1:length(all)
    load(strcat(fol_name,'/',all(k).name));
    plot(subject.hgf.sim_aversive.traj.mu(:,3));
    hold on;
end
title('\mu_3')

%% Both plots
fol_name = 'data/behav_analyzed_hgf';
all = dir(strcat(fol_name,'/*.mat'));
k = 3    
load(strcat(fol_name,'/',all(k).name));
plot(subject.hgf.sim_bo.traj.mu(:,2));


%%
fol_name = 'data/behav_analyzed_hgf';
all = dir(strcat(fol_name,'/*.mat'));
for k = 1:length(all)
    load(strcat(fol_name,'/',all(k).name));
    plot(subject.hgf.sim_neutral.traj.mu(:,2));
    hold on;
    plot(subject.hgf.sim_aversive.traj.mu(:,2));
    hold on;
    plot(subject.hgf.sim_bo.traj.mu(:,2));
    hold off;
    legend('Neutral','Aversive','Bayes-optimal')
    title(strcat('Subject ID',num2str(subject.ID)))
    pause(3);
end

%% Difference plots
fol_name = 'data/behav_analyzed_hgf';
all = dir(strcat(fol_name,'/*.mat'));
for k = 1:length(all)
    load(strcat(fol_name,'/',all(k).name));
    plot(subject.hgf.sim_aversive.traj.mu(:,2)-subject.hgf.sim_neutral.traj.mu(:,2));
    hold on;
end
title('Aversive vs. Neutral');

%% (D) GSR ANALYSIS




