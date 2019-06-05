function [fr, pos, hdr] = load_file(fpath, mecf)
% Load data from file using textscan

fid = fopen(fpath);    
txt_out = textscan(fid, '%d%d%d%d%*[^\n]', 'HeaderLines', 13);

if mecf
    pos = double([txt_out{1}, txt_out{2}]);
    hdr = double(txt_out{3});
    fr = double(txt_out{4});
else
    hdr = [];
    pos = double([txt_out{1}, txt_out{2}]);
    fr = double(txt_out{3});
end

end
