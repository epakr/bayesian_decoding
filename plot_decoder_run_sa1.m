%%% Plot results from single decoder run on SA1 data

clear all, close all, clc

%% Load data

config = get_config();

% Set this to results you want to plot
results_path = sprintf('%s/decode_err_sa1/A0405_R22.mat', config.results_root);

results = load(results_path);


%% Plot posteriors

figure();
for k = 1:length(results.dbg_pred.p_xns)

    subplot(5, 2, k);
    img_plot(results.dbg_pred.p_xns{k});
    axis off;
    colorbar;

    ts = results.dbg_pred.ts_save(k);
    hold on;
    plot(results.x_pred(ts, 1), results.x_pred(ts, 2), 'r*', 'MarkerSize', 10);

    title(sprintf('t=%d', ts));
end

suptitle('posteriors and estimated position values (*)');


%% Plot trajectory

ts_start = 3000;
ts_end = 3200;

figure();

plot_trajectory(results.x, results.x_pred, ts_start, ts_end);
title(sprintf('x vs x_{pred}(room) (t:%d-%d)', ts_start, ts_end));

%% Helper functions

function img_plot(x)

xt = x';

alpha_data = ones(size(xt));
alpha_data(isnan(xt)) = 0;
imagesc(xt, 'AlphaData', alpha_data);
axis square;

end


function plot_trajectory(x, x_pred, ts_start, ts_end)

ts_start = 3000;
ts_end = 3200;
ts = ts_start:ts_end;

hold on;

% Plot arena boundary
tc = linspace(0, 2*pi, 1000);
c = [16.5, 16.5];
r = 16.0;
xs = r * cos(tc) + c(1);
ys = r * sin(tc) + c(1);
plot(xs, ys, 'k');

% Plot true trajectory of animal
p1 = traj_plot(x(ts, 1)', x(ts, 2)');

% Plot decoded trajectory of animal
p2 = plot(x_pred(ts, 1)', x_pred(ts, 2)', 'r');

xlim([0, 33]);
ylim([0, 33]);
axis square;
axis ij;
axis off;
legend([p1, p2], {'true pos.', 'decoded pos.'});

end


function [p] = traj_plot(x, y)

z = zeros(size(x));
col = 1:length(x);
p = surface( ...
    [x;x], [y;y], [z;z], [col;col], ...
    'facecol', 'no', ...
    'edgecol', 'interp', ...
    'linew', 2 ...
);

end
