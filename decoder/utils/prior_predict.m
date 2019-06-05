function [x_pred, dbg] = prior_predict(params, spikes, opt)
% Predict position as maximum of prior distribution, constant across time
%
% Args:
%     params (struct): Trained decoder parameters. Contains fields:
%         p_x (NxN array): Prior distribution over positions
%     spikes (cell array of Nx1 arrays): Spike counts for each cell
%     opt (struct): Options for decoder. Must contain the following fields:
%         n_bins_dim (int): Number of position bins for both dimensions
%         win_size (int): Number of bins in sliding window used for prediction 
%         ignore_null_vecs (boolean): Set this flag for the decoder to predict
%             a NaN for every time step where there are zero spikes in the
%             sliding window
%
% Returns:
%     x_pred (Nx2 array): Predicted position values 
%     dbg (struct): Debug info

% Find maximum of prior
[~, lin_idx] = max(params.p_x(:));
[x1, x2] = ind2sub([opt.n_bins_dim, opt.n_bins_dim], lin_idx);
dbg.x_max = [x1, x2];

% Predict this value at every time step
n_pts = size(spikes{1}, 1);
x_pred = repmat([x1, x2], [n_pts, 1]);

% Don't predict for null vectors, if option is set to true
if opt.ignore_null_vecs

    % Apply sliding window to spike counts
    spikes_win = get_spikes_win(spikes, opt.win_size);
    dbg.spikes_win = spikes_win;

    % Find time indices of all windows with zero spikes
    spikes_win_arr = [spikes_win{:}];
    zero_vec_idx = (sum(spikes_win_arr, 2) == 0);
    dbg.zero_vec_idx = zero_vec_idx;

    % Set prediction to NaN if time step has no spikes
    x_pred(zero_vec_idx, 1) = NaN;
    x_pred(zero_vec_idx, 2) = NaN;

end

end
