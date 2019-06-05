function [trials] = get_all_trials(data_root)
% Return struct array of all trials stored in data root directory
%
% A 'trial' here is a set of simulateous recordings, specified by an animal
% ID string and a room ID string. 
%
% Args:
%     data_root (string): Absolute path to directory containing experiment data
%
% Returns:
%     trials (struct array): Each struct contains the following fields:
%         a_id (string): Animal ID
%         r_id (string): Room ID
%         subdir (string): Relative path from data root to directory containing
%             trial data.

trials = [];

animal_ls = dir(sprintf('%s/S*', data_root));
if isempty(animal_ls)
    error(sprintf('Data root directory has no data: %s', data_root));
end

for animal_idx = 1:length(animal_ls)

    % Get animal ID
    animal_dir = animal_ls(animal_idx).name;
    animal_id = animal_dir(2:end);

    % Get list of room directories (if there are any)
    room_ls = dir(sprintf('%s/%s/R*', data_root, animal_dir));
    room_ls = room_ls(cell2mat({room_ls.isdir}));

    % Only one room for animal
    if isempty(room_ls)
        
        % Figure out room ID from cell in directory
        cell_ls = dir(sprintf('%s/%s/*.txt', data_root, animal_dir));
        if isempty(cell_ls)
            error(sprintf('Subdirectory has no data: %s/%s', data_root));
        end
        matches = regexp(cell_ls(1).name, 'R[0-9][0-9]', 'match');
        room_id = matches{1}(2:end);

        % Add trial to list (trial subdir is animal directory)
        t.a_id = animal_id;
        t.r_id = room_id;
        t.subdir = animal_dir;
        trials = [trials, t];

    % Multiple rooms for animal
    else

        for room_idx = 1:length(room_ls)

            room_dir = room_ls(room_idx).name;

            % Add trial to list (trial subdir is subdir of animal directory)
            t.a_id = animal_id;
            t.r_id = room_dir(2:end);
            t.subdir = sprintf('%s/%s', animal_dir, room_dir);
            trials = [trials, t];

        end

    end 
    
% Trials we decided to ignore
ignore(1).a_id = '1027'; ignore(1).r_id = '54';

% Remove trials to ignore from list
ignore_idx = zeros(1, length(trials));
for k = 1:length(trials)
  
    t = trials(k);
    a_cmp = strcmp(t.a_id, {ignore.a_id});
    r_cmp = strcmp(t.r_id, {ignore.r_id});

    if any(a_cmp & r_cmp)
        ignore_idx(k) = 1;
    end
end
trials = trials(~ignore_idx);

end
