%%% Compute error of SA1-trained Bayesian decoder on SA1 data

clear all, close all, clc

rng(1979);


%% Global parameters

% Change this to subdirectory we want to write out to!
out_subdir = 'decode_err_sa1';

% Config file specifies directories for input data and results
config = get_config();
out_dir = sprintf('%s/%s', config.results_root, out_subdir);

% Number of position bins per dimension (space is n_bins_dim x n_bins_dim grid)
n_bins_dim = 32;

% Minimum number of total spikes required for cell to be considered
min_spikes = 100;

% Minimum number of cells required for session to be considered for analysis
min_cells = 5;

% Anatomical region data is from
region = 'CA1'; % could be 'MEC' or 'CA1' or 'SUB'


%% Decoder parameters

% Number of bins per dimension
decode_opt.n_bins_dim = n_bins_dim;

% Size of time step (seconds)
decode_opt.ts_size = 0.033;

% Don't use Gaussian smoothing for occupancy distribution 
decode_opt.px_filter = [];

% Use Gaussian smoothing for estimating cell firing rate maps
decode_opt.fr_filter.size = [3, 3];
decode_opt.fr_filter.std = 1.0;

% Size of sliding window in time bins (15 * 33 = 495 ms sliding window) 
decode_opt.win_size = 15;

% Set flag to not predict at time points where no cells in ensemble have
% spikes (these are called 'null vectors')
decode_opt.ignore_null_vecs = true;


%% Compute decoder error for all trials

% Data root
if strcmp(region, 'SUB')
    data_root = config.data_root_sub;
elseif strcmp(region, 'CA1')
    data_root = config.data_root_ca1;
elseif strcmp(region, 'MEC')
    data_root = config.data_root_mec;
else
    error('region not supported');
end

trials = get_all_trials(data_root, region);

for t = 1:length(trials)

    trial = trials(t);

    %% Load SA1 and RA data

    % Load cell filenames for cells
    cells_sa1 = get_cells(data_root, trial, 'SA1');
    if isempty(cells_sa1)
        continue;
    end
    
    % Load SA1 position data (this should be the same for all cells)
    [x, ~] = get_decoder_data_sa1(cells_sa1(1), data_root, n_bins_dim);
    
    % Load spike data for trial, and decide whether to keep trial
    spikes_sa1 = {};
    spikes_ra = {};
    n_valid_cells = 0;
    for c = cells_sa1
        [~, y_sa1] = get_decoder_data_sa1(c, data_root, n_bins_dim);
        if (size(y_sa1, 1) ~= size(x, 1))
            error('x and y not same length!');
        end
        if sum(y_sa1) >= min_spikes
            spikes_sa1{end + 1} = y_sa1;
            n_valid_cells = n_valid_cells + 1;
        end
    end
    if n_valid_cells < min_cells
        continue;
    end
    
    
    %% Compute firing rate maps using SA1 data

    % Train decoder on SA1 data
    [sa1_params, dbg_train] = decoder_train(x, spikes_sa1, decode_opt);


    %% Predict SA1 position using SA1 spikes

    % Predict position for SA1 data
    [x_pred, dbg_pred] = decoder_predict(sa1_params, spikes_sa1, decode_opt);
    
    % For control, predict using only prior positional information
    [x_pred_ctr, dbg_pred_ctr] = prior_predict(sa1_params, spikes_sa1, decode_opt);


    %% Compute error

    % Compute error signal
    err = sqrt(sum((x_pred - x) .^ 2, 2));
    err_ctr = sqrt(sum((x_pred_ctr - x) .^ 2, 2));

    % Print results
    fprintf('trial: A%s-R%s\n', trial.a_id, trial.r_id);
    fprintf('num cells: %d\n', length(cells_sa1));
    fprintf('\tmean error: %.2f\n', mean(err, 'omitnan'));
    fprintf('\tmean error (control): %.2f\n', mean(err_ctr, 'omitnan'));

    % Save results
    results_fpath = sprintf('%s/A%s_R%s.mat', out_dir, trial.a_id, trial.r_id);
    save(results_fpath);

end