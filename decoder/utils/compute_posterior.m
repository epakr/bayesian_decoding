function [p_xn] = compute_posterior(p_x, frms, spikes, win_size_sec, t)
% Compute posterior distribution over position bins at time t
%
% Args:
%     p_x (NxN array): Prior distribution over position bins 
%
% Returns:
%    p_xn (NxN array): Posterior distribution over position bins given data

% Accumulator variables for evaluating posterior
a = ones(size(p_x));
b = zeros(size(p_x));

for k = 1:length(spikes)

    % Number of spikes for cell k at time t
    n_kt = spikes{k}(t);

    % Tuning function (Hz) scaled by window size (sec)
    frm = frms{k} * win_size_sec;

    % Update accumulator variables
    a = a .* (frm .^ n_kt);
    b = b + frm;
end

% Non-normalized probabilities
p_xn_nn = p_x .* a .* exp(-b);

% Posterior probabilities for time t
p_xn = p_xn_nn / nansum(p_xn_nn(:));

end
