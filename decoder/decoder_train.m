function [params, dbg] = decoder_train(x, spikes, opt)
% Train a Bayesian decoder and return its parameters
%
% Args:
%     x (Nx2 array): Position values
%     spikes (cell array of Nx1 arrays): Spike counts for each cell
%     opt (struct): Options for decoder. Must contain the following fields:
%         n_bins_dim (int): Number of position bins for both dimensions
%         ts_size (float): Duration of time step
%         fr_filter (struct): Options for Gaussian filter applied to firing
%             rate maps. Contains the following fields:
%                 size (array or scalar): Size of filter
%                 std (float): Standard deviation of filter
%         px_filter (struct): Options for Gaussian filter applied to occupancy
%             distribution. Setting this to empty Contains the following fields:
%                 size (array or scalar): Size of filter
%                 std (float): Standard deviation of filter
%
% Returns:
%     params (struct): Decoder parameters. Contains the following fields:
%         p_x (NxN array): Prior distribution over position
%         frms (cell array of NxN arrays): Firing rate map for each cell
%     dbg (struct): Debug info

n_ts = size(x, 1);
n_cells = size(spikes, 2);


%% Compute prior over position

% Get number of timestamps for each position bin
x_counts = hist3(x, {1:opt.n_bins_dim, 1:opt.n_bins_dim});

% Smooth with Gaussian kernel
if ~isempty(opt.px_filter)
    h = fspecial('gaussian', opt.px_filter.size, opt.px_filter.std);
    x_counts = filter2(h, x_counts);
end

params.p_x = x_counts / sum(x_counts(:));


%% Compute firing rate map for each cell

% Amount of time spent in each bin
dwell_time = x_counts * opt.ts_size;
dbg.dwell_time = dwell_time;

params.frms = {};
for k = 1:n_cells

    % Total number of spikes in each bin
    n_spks_bin = get_bin_spikes(x(:, 1), x(:, 2), spikes{k}, opt.n_bins_dim);
    dbg.n_spks_bin{k} = n_spks_bin;

    % Empirical firing rate = (num. spikes) / (bin dwell time)
    frm = n_spks_bin ./ dwell_time;
    frm(dwell_time == 0) = NaN;

    % Smooth with Gaussian kernel 
    if ~isempty(opt.fr_filter)
        h = fspecial('gaussian', opt.fr_filter.size, opt.fr_filter.std);
        frm = filter2(h, frm);
    end

    params.frms{k} = frm;

end

end
