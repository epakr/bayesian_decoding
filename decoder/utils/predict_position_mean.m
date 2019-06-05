function [x1_p, x2_p] = predict_position_mean(p_xn)
% Compute maximum a posteriori (MAP) estimate of position using posterior

x1_vals = 1:size(p_xn, 1);
x2_vals = 1:size(p_xn, 2);
[X2, X1] = meshgrid(x2_vals, x1_vals);

X1_weighted = X1 .* p_xn;
x1_p = nansum(X1_weighted(:));

X2_weighted = X2 .* p_xn;
x2_p = nansum(X2_weighted(:));

end
