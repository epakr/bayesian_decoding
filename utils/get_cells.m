function [cells] = get_cells(data_root, trial, session)
% Get IDs of all cells from the given trial and session

if strcmp(session, 'SA1')
    cells = get_sa1_cells(data_root, trial);

elseif strcmp(session, 'SA2')
    cells = get_sa2_cells(data_root, trial);

elseif strcmp(session, 'RA')
    cells = get_ra_cells(data_root, trial);

else
    error('session must be either SA1, SA2, or RA');

end

% Cells we decided to ignore
ignore(1).a_id = '0000'; ignore(1).r_id = '00'; ignore(1).c_id = 'P0C0';

% Remove cells to ignore from list
ignore_idx = zeros(1, length(cells));
for k = 1:length(cells)
    
    c = cells(k);  
    a_cmp = strcmp(c.a_id, {ignore.a_id});
    r_cmp = strcmp(c.r_id, {ignore.r_id});
    c_cmp = strcmp(c.c_id, {ignore.c_id});
    if any(a_cmp & r_cmp & c_cmp)
        ignore_idx(k) = 1;
    end
end
cells = cells(~ignore_idx);

end


function [cells] = get_sa1_cells(data_root, trial)
% Get all cells in trial with SA1 data

cells = [];

dir_ls = dir(sprintf('%s/%s/*SA1R*-cl.P*Rm.txt', data_root, trial.subdir));
for k = 1:length(dir_ls)

    fname = dir_ls(k).name;

    cells(k).a_id = trial.a_id;
    cells(k).r_id = trial.r_id;
    cells(k).c_id = parse_cell_id(fname);
    cells(k).subdir = trial.subdir;
    cells(k).sa1_fname = fname;
    cells(k).sa2_fname = '';
    cells(k).ra_rm_fname = '';
    cells(k).ra_ar_fname = '';

end

end


function [cells] = get_sa2_cells(data_root, trial)
% Get all cells in trial with SA2 data

cells = [];

dir_ls = dir(sprintf('%s/%s/*SA2R*-cl.P*Rm.txt', data_root, trial.subdir));
for k = 1:length(dir_ls)

    fname = dir_ls(k).name;

    cells(k).a_id = trial.a_id;
    cells(k).r_id = trial.r_id;
    cells(k).c_id = parse_cell_id(fname);
    cells(k).subdir = trial.subdir;
    cells(k).sa1_fname = '';
    cells(k).sa2_fname = fname;
    cells(k).ra_rm_fname = '';
    cells(k).ra_ar_fname = '';

end

end


function [cells] = get_ra_cells(data_root, trial)
% Get all cells in trial with RA data

cells = [];

% Determine if directory uses 'RA' or 'TF' for session ID
contains_ra = length(dir(sprintf('%s/%s/*RA*', data_root, trial.subdir))) > 0;
contains_tf = length(dir(sprintf('%s/%s/*TF*', data_root, trial.subdir))) > 0;
if contains_ra & ~contains_tf
    s_id = 'RA';
elseif ~contains_ra & contains_tf
    s_id = 'TF';
else
    error('subdirectory contains inconsistent data');
end

% Iterate through all room data filenames
dir_ls = dir(sprintf('%s/%s/*%sR*-cl.P*Rm.txt', data_root, trial.subdir, s_id));
for k = 1:length(dir_ls)

    % Room data filename
    rm_fname = dir_ls(k).name;

    % Arena data filename and path (if file exists)
    ar_fname = replace(rm_fname, 'Rm', 'Ar');
    ar_fpath = sprintf('%s/%s/%s', data_root, trial.subdir, ar_fname);

    % If arena data exists, add cell to array
    if isfile(ar_fpath)

        c.a_id = trial.a_id;
        c.r_id = trial.r_id;
        c.c_id = parse_cell_id(rm_fname);
        c.subdir = trial.subdir;
        c.sa1_fname = '';
        c.sa2_fname = '';
        c.ra_rm_fname = rm_fname;
        c.ra_ar_fname = ar_fname;

        cells = [cells, c];

    end

end

end


function [cell_id] = parse_cell_id(fname)
% Parse cell ID from filename

matches = regexp(fname, '-cl.[PC0-9]+', 'match');
cell_id = matches{1}(5:end);

end
