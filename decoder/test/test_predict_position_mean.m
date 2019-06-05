function tests = test_predict_position_mean

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

[x1_p, x2_p] = predict_position_mean(p_xn);
verifyEqual(testCase, x1_p, x1);
verifyEqual(testCase, x2_p, x2);

end


function test_2(testCase)
% Basic test

p_xn = [ ...
    [0.25, 0.25, 0]; ...
    [0.25, 0.25, 0]; ...
    [0, 0, 0];...
];

x1 = 1.5;
x2 = 1.5;

[x1_p, x2_p] = predict_position_mean(p_xn);
verifyEqual(testCase, x1_p, x1);
verifyEqual(testCase, x2_p, x2);

end
