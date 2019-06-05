function tests = test_predict_position_map

tests = functiontests(localfunctions);

end


function test_1(testCase)
% Basic test

p_xn = [ ...
    [0, 1, 0]; ...
    [0, 0, 0]; ...
    [0, 0, 0];...
];

x1 = 1;
x2 = 2;

[x1_p, x2_p] = predict_position_map(p_xn);
verifyEqual(testCase, x1_p, x1);
verifyEqual(testCase, x2_p, x2);

end


function test_2(testCase)
% Basic test

p_xn = [ ...
    [0.1, 0.4, 0]; ...
    [0.3, 0.2, 0]; ...
    [0, 0, 0];...
];

x1 = 1;
x2 = 2;

[x1_p, x2_p] = predict_position_map(p_xn);
verifyEqual(testCase, x1_p, x1);
verifyEqual(testCase, x2_p, x2);

end
