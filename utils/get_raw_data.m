function [fr, pos] = get_raw_data(fpath, mecf, max_spike, max_pos)
% Get data from file and check integrity

if nargin < 3
    max_spike = 30;
end
if nargin < 4
    max_pos = 255;
end

[fr, pos, hdr] = load_file(fpath, mecf);

if max(fr) > max_spike
    error(sprintf('file %s misread: spike count exceeds max. (%d)', fpath, max(fr)));
end
if max(pos) > max_pos
    error(sprintf('file %s misread: position value exceeds max.', fpath));
end

end
