function [x_rb] = rebin_pos_decoder(x, n_bins_dim)
% Rebin position data for decoder

X = x(:, 1);
Y = x(:, 2);

%% Copied from Dino's code

% Remove (0, 0) values
k = (X == 0 & Y == 0);
X(k) = NaN;
Y(k) = NaN;

% Minmax values of XY
minX = min(X);
maxX = max(X);
minY = min(Y);
maxY = max(Y);

% Partition the space
edgesX = linspace(minX - 0.1, maxX + 0.1, n_bins_dim + 1);
edgesY = linspace(minY - 0.1, maxY + 0.1, n_bins_dim + 1);

% Bin position
kGoodSpot = ~isnan(X) & ~isnan(Y);
XYS = nan(length(X), 2);
[~, indX] = histc(X, edgesX);
[~, indY] = histc(Y, edgesY);
XYS(:,1) = indX;
XYS(:,2) = indY;
XYS(~kGoodSpot,:) = NaN;

%%

x_rb = XYS;

end
