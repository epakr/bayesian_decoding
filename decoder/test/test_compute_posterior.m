function tests = test_compute_posterior

tests = functiontests(localfunctions);

end


function test_1(testCase)
% Basic test

p_x = [0.1, 0.1; 0.4, 0.4];
frms{1} = [1, 2; 1, 2];
frms{2} = [3, 4; 3, 4];
spikes{1} = [1];
spikes{2} = [2];
t = 1;
win_size_sec = 1;

target_nn = [0.9, 3.2; 3.6, 12.8] .* exp(-[4, 6; 4, 6]);
target = target_nn ./ sum(target_nn(:));

output = compute_posterior(p_x, frms, spikes, win_size_sec, t);
verifyEqual(testCase, output, target, 'AbsTol', 1e-9);

end


function test_2(testCase)
% Test with nontrivial window size

p_x = [0.1, 0.1; 0.4, 0.4];
frms{1} = [1, 2; 1, 2];
frms{2} = [3, 4; 3, 4];
spikes{1} = [1];
spikes{2} = [2];
t = 1;
win_size_sec = 5;

target_nn = [0.9, 3.2; 3.6, 12.8] .* exp(-[20, 30; 20, 30]);
target = target_nn ./ sum(target_nn(:));

output = compute_posterior(p_x, frms, spikes, win_size_sec, t);
verifyEqual(testCase, output, target, 'AbsTol', 1e-9);

end
