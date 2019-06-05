%%% Script for plotting decoder error on RA data

clear all; close all; clc;

config = get_config();
in_dir = sprintf('%s/decode_err_ra', config.results_root);

ts_sec = 0.033;

dir_ls = dir(sprintf('%s/*.mat', in_dir));
fnames = {dir_ls.name};

fnames = fnames(1:1);

for k = 1:numel(fnames)

    fname = fnames{k};
    load(sprintf('%s/%s', in_dir, fname));

    ts = 1000:18000;

    figure();

    subplot(411);
    hold on;
    plot(ts * ts_sec, err_rm(ts));
    plot(ts * ts_sec, err_ar(ts));
    xlabel('time (sec)');
    ylabel('error (pixels)');
    legend({'room', 'arena'});
    title(fname(1:(end-4)), 'interpreter', 'none');

    subplot(412);
    histogram(err_rm, 100);
    title('room error distribution');

    subplot(413);
    histogram(err_ar, 100);
    title('arena error distribution');

    subplot(414);
    histogram(err_rm - err_ar, 100);
    title('(room - arena) error distribution');

end
