%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fits HGFs for each subject/block and simulates traces
% 
% Lukas Vogelsang, May 2018
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function hgfparams = single_subject_HGF_analysis(fol_name, name,default_config)
% Load data
load(strcat(fol_name,'/',name));
load('metadata.mat');

% Set config file for perceptual model
if default_config == 1 
    config_prc = 'tapas_hgf_binary_config'; % --> default
    config_resp = 'tapas_unitsq_sgm_config';
elseif default_config == 0
    config_prc = 'tapas_hgf_binary_LJM_config';
    config_resp = 'tapas_unitsq_sgm_config_LJM';
elseif default_config == 2
    config_prc = 'tapas_hgf_binary_2level_config';
    config_resp = 'tapas_unitsq_sgm_config_LJM';
end

% Generate cue-stimulus contingency corrected input/output sequences
HGF_input_seq = subject.behav.css.input;
HGF_output_seq_neutral = subject.behav.css.response_neutral;
HGF_output_seq_aversive = subject.behav.css.response_aversive;


% BAYES-OPTIMAL
% Find Bayes optimal perceptual parameter values for dataset under binary HGF model
params_bo = tapas_fitModel([],... % observations; here: empty.
                         HGF_input_seq,... % input
                         config_prc,... % perceptual model
                         'tapas_bayes_optimal_binary_config',... % pseudo-response model
                         'tapas_quasinewton_optim_config'); % opt. algo 
fprintf('\n 1. bo is done')
                     
% Simulate responses
% sim_bo = tapas_simModel(HGF_input_seq,... % data
%                      'tapas_hgf_binary',... % perceptual model
%                      [NaN 0 1 NaN 1 1 NaN 0 0 1 1 NaN params_bo.p_prc.om(2) params_bo.p_prc.om(3)],... % NaN, -2.5, -6 = omegas
%                      'tapas_unitsq_sgm',... % response model: unit square sigmoid
%                      5); % zeta parameter         

                 %fprintf('\n 2. sim_bo is done')                     
% NEUTRAL STIMULI                     
% Fit HGF based on participant data 
params_neutral = tapas_fitModel(HGF_output_seq_neutral,... % observations; here: empty.
                         HGF_input_seq,... % input
                         config_prc,... % perceptual model
                         config_resp,... % response model
                         'tapas_quasinewton_optim_config'); % opt. algo 
fprintf('\n 3. neut_fit is done')
% Simulate responses
% sim_neutral = tapas_simModel(HGF_input_seq,... % data
%                      'tapas_hgf_binary',... % perceptual model
%                      [NaN 0 1 NaN 1 1 NaN 0 0 1 1 NaN params_neutral.p_prc.om(2) params_neutral.p_prc.om(3)],... % NaN, -2.5, -6 = omegas
%                      'tapas_unitsq_sgm',... % response model: unit square sigmoid
%                      params_neutral.p_obs.ze); % zeta parameter                       
%fprintf('\n 4. neut_sim is done')                 
% AVERSIVE STIMULI       
% Fit HGF based on participant data 
params_aversive = tapas_fitModel(HGF_output_seq_aversive,... % observations; here: empty.
                         HGF_input_seq,... % input
                         config_prc,... % perceptual model
                         config_resp,... % response model
                         'tapas_quasinewton_optim_config'); % opt. algo    
fprintf('\n 5. av_fit is done')
% Simulate responses
% sim_aversive = tapas_simModel(HGF_input_seq,... % data
%                      'tapas_hgf_binary',... % perceptual model
%                      [NaN 0 1 NaN 1 1 NaN 0 0 1 1 NaN params_aversive.p_prc.om(2) params_aversive.p_prc.om(3)],... % NaN, -2.5, -6 = omegas
%                      'tapas_unitsq_sgm',... % response model: unit square sigmoid
%                      params_aversive.p_obs.ze); % zeta parameter                                           
%fprintf('\n 5. av_sim is done')
subject.hgf.params_neutral = params_neutral;
subject.hgf.params_aversive = params_aversive; 
%subject.hgf.sim_neutral = sim_neutral; 
%subject.hgf.sim_aversive = sim_aversive; 
subject.hgf.params_bo = params_bo;
%subject.hgf.sim_bo = sim_bo;
subject.hgf.configfile_prc = config_prc;
subject.hgf.configfile_resp = config_resp;

if default_config == 1
    save(strcat('data/behav_analyzed_hgf_default/',name), 'subject');
elseif default_config == 0
    save(strcat('data/behav_analyzed_hgf_newpriors/',name), 'subject');
elseif default_config == 2
    save(strcat('data/behav_analyzed_hgf_2layer/',name), 'subject');
end



%{                 
% die halt alle plotten sp�ter

% 

% check Manual.pdf and _tapas_simModel.m, _tapas_hgf_binary_config.m_ 
% and of the response model: _tapas_unitsq_sgm_config.m_.
% Plot simulated responses $y$ using the plotting function for _hgf_binary_ models

%{  Recover parameter values from simulated responses
% We can now try to recover the parameters we put into the simulation ($\omega_2=-2.5$ 
% and $\omega_3=-6$) using fitModel.
est = tapas_fitModel(sim.y,...
                     sim.u,...
                     'tapas_hgf_binary_config',...
                     'tapas_unitsq_sgm_config',...
                     'tapas_quasinewton_optim_config');
% How good recovery? Do it several times, look at distribution. Typically good 

% Check parameter identifiability
% To check how well the parameters could be identified, we can take a look at 
% their posterior correlation. This gives us an idea to what degree changing one 
% parameter value can be compensated by changing another.
tapas_fit_plotCorr(est)
% here good; not close to +1 or -1. 
% posterior correlation matrix stored in:
disp(est.optim.Corr)
%% while the posterior parameter covariance matrix is stored in est.optim.Sigma
disp(est.optim.Sigma)
%% Posterior means
% Posterior means of  estimated as well as  fixed parameters can be found in 
% est.p_prc for the perceptual model and in est.p_obs for the observation model:
disp(est.p_prc)
disp(est.p_obs)
% The posterior means are contained in these structures separately by name 
% (e.g., om for $\omega$) as well as jointly as a vector $p$ in their native space 
% and as a vector $p_{\mathrm{trans}}$ in their transformed space (ie, the space 
% they are estimated in). For details, see the manual.
%% Inferred belief trajectories
% As with the simulated trajectories, we can plot the inferred belief trajectories 
% implied by the estimated parameters.
tapas_hgf_binary_plotTraj(est)
% These trajectories can be found in est.traj:
disp(est.traj)
%% Changing the perceptual model: now try Rescorla-Wagner model
est1a = tapas_fitModel(sim.y,...
                       sim.u,...
                       'tapas_rw_binary_config',...
                       'tapas_unitsq_sgm_config',...
                       'tapas_quasinewton_optim_config');
%% 
% The single estimated perceptual parameter is the constant learning rate 
% $\alpha$.
% 
% Just as for _hgf_binary_, we can plot posterior correlations and inferred 
% trajectories for _rw_binary_.
%%
tapas_fit_plotCorr(est1a)
tapas_rw_binary_plotTraj(est1a)
%% Input on a continuous scale
% Up to now, we've only used binary input - 0 or 1. However, many of the most 
% interesting time series are on a continuous scale. As an example, we'll use 
% the exchange rate of the US Dollar to the Swiss Franc during much of 2010 and 
% 2011.
%%
usdchf = load('example_usdchf.txt');
%% 
% As before, we'll first estimate the Bayes optimal parameter values. This 
% time, we'll take a 2-level HGF for continuous-scaled inputs.
%%
bopars2 = tapas_fitModel([],...
                         usdchf,...
                         'tapas_hgf_config',...
                         'tapas_bayes_optimal_config',...
                         'tapas_quasinewton_optim_config');
%% 
% And again, let's check the posterior correlation and the trajectories:
%%
tapas_fit_plotCorr(bopars2)
tapas_hgf_plotTraj(bopars2)
%% 
% Now, let's simulate an agent and plot the resulting trajectories:
%%
sim2 = tapas_simModel(usdchf,...
                      'tapas_hgf',...
                      [1.04 1 0.0001 0.1 0 0 1 -13  -2 1e4],...
                      'tapas_gaussian_obs',...
                      0.00002);
tapas_hgf_plotTraj(sim2)
%% 
% Looking at the volatility (ie, the second) level, we see that there are 
% two salient events in our time series where volatility shoots up. The first 
% is in April 2010 when the currency markets react to the news that Greece is 
% effectively broke. This leads to a flight into the US dollar (green dots rising 
% very quickly), sending the volatility higher. The second is an accelarating 
% increase in the value of the Swiss Franc in Augutst and September 2011, as the 
% Euro crisis drags on. The point where the Swiss central bank intervened and 
% put a floor under how far the Euro could fall with respect to the Franc is clearly 
% visible in the Franc's valuation against the dollar. This surprising intervention 
% shows up as another spike in volatitlity.
%% Adding levels
% Let's see what happens if we add another level:
%%
sim2a = tapas_simModel(usdchf,...
                       'tapas_hgf',...
                       [1.04 1 1 0.0001 0.1 0.1 0 0 0 1 1 -13  -2 -2 1e4],...
                       'tapas_gaussian_obs',...
                       0.00005);
tapas_hgf_plotTraj(sim2a)
%% 
% Owing to the presence of the third level, the second level is a lot smoother 
% now. At the third level, nothing much happens. This is an indication that adding 
% further levels doesn't make sense. Formally, you can always check whether adding 
% levels is warrented by using the log-model evidence to compare models with different 
% numbers of levels.
%% Salient events reflected in precision weights
% While the third level is very smooth overall, the two salient events discussed 
% above are still visible. Let's see how these events are reflected in the precision 
% weighting of the updates at each level:
%%
figure
plot(sim2a.traj.wt)
xlim([1, length(sim2a.traj.wt)])
legend('1st level', '2nd level', '3rd level')
xlabel('Trading days from 1 Jan 2010')
ylabel('Weights')
title('Precision weights')
%% 
% Most prominently at the second level, there is a very clear peak in the 
% precision weights at the moments where the HGF picks up that the environment 
% has changed. This spike in the precision weights leads to an increase in the 
% lerning rate at the corresponding levels, and once the filter has taken the 
% lessons from the new situation on board, the precision weights and with them 
% the learning rates go down again quickly.
%% Parameter recovery
% Now, let's try to recover the parameters we put into the simulation by fitting 
% the HGF to our simulated responses:
%%
est2 = tapas_fitModel(sim2.y,...
                      usdchf,...
                      'tapas_hgf_config',...
                      'tapas_gaussian_obs_config',...
                      'tapas_quasinewton_optim_config');
%% 
% Again, we fit the posterior correlation and the estimated trajectories:
%%
tapas_fit_plotCorr(est2)
tapas_hgf_plotTraj(est2)
%% Plotting residual diagnostics
% It's often helpful to look at the residuals (ie, the differences between predicted 
% and actual responses) of a model. If the residual show any obvious patterns, 
% that's an indication that your model fails to capture aspects of the data that 
% should in princple be predictable.
%%
tapas_fit_plotResidualDiagnostics(est2)
%% 
% Everything looks fine here - no obvious patterns to be seen.
% 
% An important point to note is that these are the residuals of the *response 
% model*, not the perceptual model. Ultimately, we want to be able to predict 
% responses, not just filter inputs, and the residuals of the response model capture 
% the performance of the combination of perceptual and response models.
% 
% Looking at the same diagnostics for binary responses is less straightforward. 
% The HGF Toolbox uses *Pearson residuals* in this case, defined as
% 
% $$r^{(k)} =\frac{y^{(k)} - \hat{\mu}_1^{(k)}}{\sqrt{\hat{\mu}_1^{(k)} \left(1-\hat{\mu}_1^{(k)}\right) 
% }}$$
%%
tapas_fit_plotResidualDiagnostics(est)
%% 
% In the case of our binary response example, we see some patterns in the 
% residuals, notably in their autocorrelation. This is due to the fact that there 
% are fairly regular reversals in the input probabilities. This means that if 
% there are suddenly many large prediction errors following each other, they tend 
% to be in the same direction. At longer lags, we see patterns caused by the regularity 
% of the reversals taking place always after about 45 inputs. Therefore, prediction 
% errors tend to go in the same direction around every 90 inputs.
%% Bayesian parameter averaging
% It is often useful to average parameters from several estimations, for instance 
% to compare groups of subjects. This can be achieved by using the function _tapas_bayesian_parameter_average()_ 
% which takes into account the covariance structure between the parameters and 
% weights individual estimates according to their precision.
% 
% We begin by simulating responses from another fictive agent and estimating 
% the parameters behind the simulated responses:
%%
sim2b = tapas_simModel(usdchf,...
                       'tapas_hgf',...
                       [1.04 1 0.0001 0.1 0 0 1 -14.5 -2.5 1e4],...
                       'tapas_gaussian_obs',...
                       0.00002);
tapas_hgf_plotTraj(sim2b)
est2b = tapas_fitModel(sim2b.y,...
                       usdchf,...
                       'tapas_hgf_config',...
                       'tapas_gaussian_obs_config',...
                       'tapas_quasinewton_optim_config');
tapas_fit_plotCorr(est2b)
tapas_hgf_plotTraj(est2b)
%% 
% Now we can take the Bayesian parameter average of our two:
%%
bpa = tapas_bayesian_parameter_average(est2, est2b);
tapas_fit_plotCorr(bpa)
tapas_hgf_plotTraj(bpa)
%}