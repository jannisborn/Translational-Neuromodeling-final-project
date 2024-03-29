%% Compare LMEs of 2- and both 3layer HGFs

LMEs = nan(2,3,12); % block, model (3def,3new,2), subject

paths = {'data/behav_analyzed_hgf_2layer/','data/behav_analyzed_hgf_default/',...
            'data/behav_analyzed_hgf_newpriors/'};

for p = 1:length(paths)
for i = 1:18
    try
        load([paths{p},'subject_',num2str(i),'.mat'])
        LMEs(1,p,i) = subject.hgf.params_neutral.optim.LME;
        LMEs(2,p,i) = subject.hgf.params_aversive.optim.LME;
    catch 
        fprintf('\nSubject %d not found',i)
    end
    
end
end

out = [17,15,10,5,4,2,1]
for i = 1:length(out)
LMEs(:,:,out(i))=[]
end

%% Look at differences between models

% Default vs. newpriors
% -------------------------------------------------------------------------

def_vs_np = LMEs(:,1,:)-LMEs(:,2,:);

% Default vs. 2layer
% -------------------------------------------------------------------------

def_vs_2l = LMEs(:,1,:)-LMEs(:,3,:);

% Newpriors vs 2layer 
% -------------------------------------------------------------------------

np_vs_2l = LMEs(:,2,:)-LMEs(:,3,:);

% Get averages
% -------------------------------------------------------------------------
avg_def_vs_np = mean(def_vs_np,3);
std_def_vs_np = mean(std(reshape(def_vs_np,[2 11])'))
avg_def_vs_2l = mean(def_vs_2l,3);
std_def_vs_2l = mean(std(reshape(def_vs_2l,[2 11])'))
avg_np_vs_2l = mean(np_vs_2l,3);
std_np_vs_2l = mean(std(reshape(np_vs_2l,[2 11])'))


all_m = [avg_def_vs_np,-avg_np_vs_2l,avg_def_vs_2l];
all_s = [std_def_vs_np, std_np_vs_2l,std_def_vs_2l];

%% Plot
% -------------------------------------------------------------------------
figure
bar(all_m)
errorbar(all_m(1,:),ones(1,3),ones(1,3))

ylabel('\DeltaLME \approx log Bayes factor','fontsize',15,'interpreter','tex')
%xlabel('Block: 1: Neutral, 2: Aversive','interpreter','tex','fontsize',15)
%xticks('','')
xticklabels({'Neutral','Aversive'})
%xtickformat('fontsize',13)
set(gca,'fontsize', 15,'fontname','CMU Sans Serif');
legend('Default 3L - New 3L','2L - New 3L','Default 3L - 2L')

%% Mean of both blocks (because blocks are quasi-identical)
close all
figure
mn = mean(all_m,1)
b = bar(mn);
b.FaceColor = 'flat';
b.CData(1,:) = [0 103 181]/255;
b.CData(2,:) = [212 73 24]/255;
b.CData(3,:) = [234 167 30]/255;
xlim([0.2 3.8])
b.BarWidth=0.8
%legend('Default 3L - New 3L','2L - New 3L','Default 3L - 2L')
hold on
errorbar(1:3,mn,all_s/sqrt(22),'linestyle','none','linewidth',2.5,'color','black')
y = ylabel('\DeltaLME \approx log Bayes factor','fontsize',15,'interpreter','tex')
set(y, 'Units', 'Normalized', 'Position', [-0.08, 0.5, 0]);
xticklabels({'Default 3L - New 3L','2L - New 3L','Default 3L - 2L'})
xt = get(gca, 'XTick');
set(gca, 'FontSize', 14,'interpreter','tex')


