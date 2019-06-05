%%% Compute error of SA1-trained Bayesian decoder on RA data

clear all, close all, clc

rng(1979);


%% Global parameters

% Config file specifies directories for input data and results
config = get_config();
out_dir = sprintf('%s/decode_err_ra', config.results_root);

% Number of position bins per dimension (space is n_bins_dim x n_bins_dim grid)
n_bins_dim = 32;

% Minimum number of total spikes required for cell to be considered
min_spikes = 100;

% Minimum number of cells required for session to be considered for analysis
min_cells = 5;

% Anatomical region data is from
region = 'MEC'; % also could be 'CA1' or 'SUB'


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

    % Load cell filenames for SA1 and RA cells
    cells_sa1 = get_cells(data_root, trial, 'SA1');
    cells_ra = get_cells(data_root, trial, 'RA');
    if isempty(cells_sa1) || isempty(cells_ra)
        continue;
    end
    cells = [];
    for k = 1:length(cells_sa1)
        a_eq = strcmp(cells_sa1(k).a_id, cells_ra(k).a_id);
        r_eq = strcmp(cells_sa1(k).r_id, cells_ra(k).r_id);
        c_eq = strcmp(cells_sa1(k).c_id, cells_ra(k).c_id);
        if a_eq & r_eq & c_eq
            c = cells_sa1(k);
            c.ra_rm_fname = cells_ra(k).ra_rm_fname;
            c.ra_ar_fname = cells_ra(k).ra_ar_fname;
            cells = [cells, c];
        else
            error('SA1 and RA sessions do not have same cells');
        end
    end
    
    % Load SA1 position data (this should be the same for all cells)
    [x_sa1, ~] = get_decoder_data_sa1(cells(1), data_root, n_bins_dim);
    
    % Load spike data for trial, and decide whether to keep trial
    spikes_sa1 = {};
    spikes_ra = {};
    n_valid_cells = 0;
    for c = cells
        [~, y_sa1] = get_decoder_data_sa1(c, data_root, n_bins_dim);
        if (size(y_sa1, 1) ~= size(x_sa1, 1))
            error('x and y not same length!');
        end        
        [~, ~, y_ra] = get_decoder_data_ra(c, data_root, n_bins_dim);
        if (sum(y_sa1) >= min_spikes) & (sum(y_ra) >= min_spikes)
            spikes_sa1{end + 1} = y_sa1;
            spikes_ra{end + 1} = y_ra;
            n_valid_cells = n_valid_cells + 1;
        end
    end
    if n_valid_cells < min_cells
        continue;
    end
    
    
    %% Compute firing rate maps using SA1 data

    % Train decoder on SA1 data
    [sa1_params, dbg_train] = decoder_train(x_sa1, spikes_sa1, decode_opt);


    %% Predict RA position using RA spikes
    
    % Set decoder parameters (firing rates from SA1 with flat prior)
    p_x_flat_nn = ones(decode_opt.n_bins_dim);
    p_x_flat = p_x_flat_nn / sum(p_x_flat_nn);
    dec_params.p_x = p_x_flat;
    dec_params.frms = sa1_params.frms;

    % Predict position for RA data
    [x_pred, dbg_pred] = decoder_predict(dec_params, spikes_ra, decode_opt);


    %% Compute error in both coordinate frames

    % Get position data (this should be the same for all cells)
    [x_ra_rm, x_ra_ar, ~] = get_decoder_data_ra(cells(1), data_root, n_bins_dim);

    % Compute 'room' and 'arena' error signals
    err_rm = sqrt(sum((x_pred - x_ra_rm) .^ 2, 2));
    err_ar = sqrt(sum((x_pred - x_ra_ar) .^ 2, 2));

    % Print results
    fprintf('trial: A%s-R%s\n', trial.a_id, trial.r_id);
    fprintf('num cells: %d\n', length(cells));
    fprintf('\tmean error (rm): %.4f\n', mean(err_rm, 'omitnan'));
    fprintf('\tmean error (ar): %.4f\n', mean(err_ar, 'omitnan'));

    % Save results
    results_fpath = sprintf('%s/A%s_R%s.mat', out_dir, trial.a_id, trial.r_id);
    save(results_fpath);

end
