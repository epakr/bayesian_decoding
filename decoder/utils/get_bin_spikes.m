function [n_spks_bin] = get_bin_spikes(x1, x2, y, n_bins_dim)
% Compute the total number of spikes for each position bin.
%
% Args:
%     x1 (Nx2 array): Position bin indices for first dimension
%     x2 (Nx2 array): Position bin indices for second dimension
%     y (Nx2 array): Spike counts
%     n_bins_dim (int): Number of position bins per dimension
%
% Returns:
%     n_spks_bin (KxK array): Spike counts for each bin

n_spks_bin = full(sparse(x1, x2, y, n_bins_dim, n_bins_dim));

end 
