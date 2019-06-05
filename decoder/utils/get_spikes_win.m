function [spikes_win] = get_spikes_win(spikes, win_size)
% Apply sliding window to spike counts
%
% Args:
%     spikes (cell array of Nx1 arrays): Spike counts for each cell at all
%         time bins.
%     win_size (int): Number of time bins to use for sliding window
%
% Returns:
%     spikes_win (cell array of Nx1 arrays): Sliding window spike counts for
%         each cell at all time bins

spikes_win = {};
for k = 1:length(spikes)
    spikes_win{k} = conv(spikes{k}, ones(win_size, 1), 'same');
end

end
