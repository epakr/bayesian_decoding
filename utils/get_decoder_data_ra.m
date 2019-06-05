function [x_rm, x_ar, y] = get_decoder_data_ra(cell, data_root, n_bins_dim)
% Load cell data from files and re-bin by timestep factor

fpath_rm = sprintf('%s/%s/%s', data_root, cell.subdir, cell.ra_rm_fname);
fpath_ar = sprintf('%s/%s/%s', data_root, cell.subdir, cell.ra_ar_fname);
check_exists(fpath_rm, fpath_ar);

% Load data 
[y_rm, x_rm] = get_raw_data(fpath_rm, true, 300, 256);
[y_ar, x_ar] = get_raw_data(fpath_ar, true, 300, 256);

% Check that spike counts from room and arena data match
assert(all(y_rm == y_ar), 'Spike counts dont match');
y = y_rm;

% Rebin by position
[x_rm] = rebin_pos_decoder(x_rm, n_bins_dim);
[x_ar] = rebin_pos_decoder(x_ar, n_bins_dim);

% Filter out zero and NaN values
valid_idx = ~any(isnan(x_rm), 2) & ~any(isnan(x_ar), 2);
x_rm = x_rm(valid_idx, :);
x_ar = x_ar(valid_idx, :);
y = y(valid_idx);

% Quick fix for (0, x) bug -- need to ask Eun Hye why these points exist
x_rm(x_rm == 0) = 1;
x_ar(x_ar == 0) = 1;

end
