function [x1_p, x2_p] = predict_position_map(p_xn)
% Compute maximum a posteriori (MAP) estimate of position using posterior

[~, max_idx] = max(p_xn(:));
[x1_p, x2_p] = ind2sub(size(p_xn), max_idx);

end
