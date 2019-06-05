%%% Run Bayesian decoder on synthetic data

clear all, close all, clc


%% Parameters

rng(1979);

% Input and output paths
config = get_config();
in_fname = sprintf('%s/syn_data/syn_data.mat', config.results_root);
out_fname = sprintf('%s/syn_results/syn_results.mat', config.results_root);

% Preprocessing parameters
n_bins_dim = 32;

% Decoder parameters
decode_opt.n_bins_dim = n_bins_dim;
decode_opt.ts_size = 0.033;
decode_opt.px_filter = [];
decode_opt.fr_filter.size = [3, 3];
decode_opt.fr_filter.std = 1.0;
decode_opt.win_size = 15;
decode_opt.ignore_null_vecs = false;


%% Load and preprocess data

% Load synthetic data
load(in_fname, 'x', 'spikes', 'fr_true');


%% Run decoder

% Train decoder on position and spike data
[dec_params, dbg_train] = decoder_train(x, spikes, decode_opt);

% Predict position for same spike data that we trained on
[x_pred, dbg_pred] = decoder_predict(dec_params, spikes, decode_opt);

% For control, predict using only prior positional information
[x_pred_ctr, dbg_pred_ctr] = prior_predict(dec_params, spikes, decode_opt);

% Compute error for both decoder and control
err = sqrt(sum((x_pred - x) .^ 2, 2));
err_ctr = sqrt(sum((x_pred_ctr - x) .^ 2, 2));

% Print results
fprintf('Decoder results (synthetic data):\n');
fprintf('\tmean error (decoder): %.2f\n', mean(err, 'omitnan'));
fprintf('\tmean error (control): %.2f\n', mean(err_ctr, 'omitnan'));


%% Save results

save(out_fname);
