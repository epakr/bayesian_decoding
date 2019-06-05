function [x_pred, dbg] = decoder_predict(params, spikes, opt)
% Return predictions of decoder given time series of spikes.
%
% Args:
%     params (struct): Trained decoder parameters. Contains fields:
%         p_x (NxN array): Prior distribution over positions
%         frms (cell array of NxN arrays): Firing rate maps for each cell
%     spikes (cell array of Nx1 arrays): Spike counts for each cell
%     opt (struct): Options for decoder. Must contain the following fields:
%         n_bins_dim (int): Number of position bins for both dimensions
%         ts_size (float): Duration of time step
%         win_size (int): Number of bins in sliding window used for prediction 
%         ignore_null_vecs (boolean): Set this flag for the decoder to predict
%             a NaN for every time step where there are zero spikes in the
%             sliding window
%
% Returns:
%     x_pred (Nx2 array): Predicted position values 
%     dbg (struct): Debug info

% Validate option values
assert(mod(opt.win_size, 2) == 1, 'window size must be odd length');

% Number of time steps in spike series
n_ts = size(spikes{1}, 1);
for k = 1:numel(spikes);
    assert(size(spikes{k}, 1) == n_ts, 'spike series must have same length');
end

% Number of cells in ensemble
n_cells = numel(spikes);

% Apply sliding window to spike counts
spikes_win = get_spikes_win(spikes, opt.win_size);
dbg.spikes_win = spikes_win;

% Window size in seconds
win_size_sec = opt.win_size * opt.ts_size;
dbg.win_size_sec = win_size_sec;

% Choose random time steps to save posteriors for
n_ts_save = 10;
ts_save = randperm(n_ts, n_ts_save);
dbg.ts_save = ts_save;

% Allocate arrays for storing predictions and sum of posteriors
x1_pred = zeros(n_ts, 1);
x2_pred = zeros(n_ts, 1);
sum_p_xn = zeros(opt.n_bins_dim);
dbg.p_xns = cell(1, n_ts_save);

% Compute prediction for each time step
for t = 1:n_ts

    % Determine if spike counts are zero for all cells
    is_null_vec = true;
    for k = 1:length(spikes_win)
        if spikes_win{k}(t) ~= 0
            is_null_vec = false;
        end
    end

    % If condition met, don't predict for this time step
    if opt.ignore_null_vecs & is_null_vec
        x1_pred(t) = NaN;
        x2_pred(t) = NaN;
        continue;
    end

    % Compute posterior for time step
    p_xn = compute_posterior( ...
        params.p_x, params.frms, spikes_win, win_size_sec, t);

    % Save posterior depending on time step
    ts_idx = find(ts_save == t);
    if ~isempty(ts_idx)
        dbg.p_xns{ts_idx} = p_xn;
    end

    % Add posterior to accumulator
    sum_p_xn = sum_p_xn + p_xn;

    % Predict position value for time step
    [x1_p, x2_p] = predict_position(p_xn);
    x1_pred(t) = x1_p;
    x2_pred(t) = x2_p;
end

x_pred = [x1_pred, x2_pred];

dbg.avg_p_xn = sum_p_xn ./ n_ts;

end
