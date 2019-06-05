function check_exists(varargin)
% Throw an error if args are not all valid file paths

for i = 1:nargin
    fpath = varargin{i};
    if ~exist(fpath, 'file')
        error(sprintf('File does not exist: %s', fpath));
    end
end
end
