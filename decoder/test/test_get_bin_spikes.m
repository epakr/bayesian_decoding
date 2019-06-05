function tests = test_get_bin_spikes

tests = functiontests(localfunctions);

end


function test_1(testCase)
% Basic test

n_bins_dim = 3;
x1 = [1, 2, 3];
x2 = [2, 3, 1];
y = [1, 2, 0];

target = [ ...
    [0, 1, 0]; ...
    [0, 0, 2]; ...
    [0, 0, 0];...
];

output = get_bin_spikes(x1, x2, y, n_bins_dim);
verifyEqual(testCase, output, target);

end


function test_2(testCase)
% Make sure things still work when bin is repeatedly visited

n_bins_dim = 3;
x1 = [1, 2, 3, 2];
x2 = [2, 3, 1, 3];
y = [1, 2, 0, 1];

target = [ ...
    [0, 1, 0]; ...
    [0, 0, 3]; ...
    [0, 0, 0];...
];

output = get_bin_spikes(x1, x2, y, n_bins_dim);
verifyEqual(testCase, output, target);

end
