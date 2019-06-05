function [x1_p, x2_p] = predict_position(Pxn)
%prob-weighted average (less noisy than maxima)
%only for top 10% of pixels

% Copied from earlier part of script
NedgesXY = size(Pxn, 1);
IND = 1:NedgesXY*NedgesXY; %pixel indexes
[iX, iY] = ind2sub([NedgesXY,NedgesXY],IND);

Pxn = Pxn(:)'; %linearize

[PxnSort,ksort] = sort(Pxn,'descend');
iXsort = iX(ksort);
iYsort = iY(ksort);

knan = ~isnan(PxnSort); %sorted values start with nan!
iXsort = iXsort(knan);
iYsort = iYsort(knan);
PxnSort = PxnSort(knan);

N = ceil(length(PxnSort)/10); %10%

iXsort = iXsort(1:N); %select 10%
iYsort = iYsort(1:N);
PxnSort = PxnSort(1:N);

s = nansum(PxnSort); %sum of probs

x1_p = nansum(iXsort.*PxnSort)/s; %probability weighted average of location
x2_p = nansum(iYsort.*PxnSort)/s;

end
