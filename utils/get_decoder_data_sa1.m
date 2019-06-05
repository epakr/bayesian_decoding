function [x, y] = get_decoder_data_sa1(cell, data_root, n_bins_dim)
% Load cell data from files and re-bin by timestep factor

fpath = sprintf('%s/%s/%s', data_root, cell.subdir, cell.sa1_fname);
check_exists(fpath);

% Load data 
[y, x] = get_raw_data(fpath, true, 300, 256);

% Rebin by position
[x] = rebin_pos_decoder(x, n_bins_dim);

% Filter out zero and NaN values
valid_idx = ~any(isnan(x), 2);
x = x(valid_idx, :);
y = y(valid_idx);

% Quick fix for (0, x) bug -- need to ask Eun Hye why these points exist
x(x == 0) = 1;

end
