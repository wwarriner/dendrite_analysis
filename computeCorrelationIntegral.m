function C = computeCorrelationIntegral(im, prange)
% Variables
%{
%}

% Description
%{
%}

% Loop over the ranges to get correlation integral numerators.
cr = zeros(length(prange),1);
im = double(im);
for i = 1:length(prange(:))
    
	fprintf(1,'.');
    if mod(i,10)==0
        fprintf(1,'\n');
    end
    
    % Create a ball of given radius with empty center.
	se = strel('ball',round(prange(i)),1,0);
	nh = se.getnhood;
	nh(prange(i)+1,prange(i)+1) = 0;
	nh = double(nh);
    
    % Convolve to get the local ball-sum.
	cv = conv2(im, nh, 'same');
    cv = cv(im>0);
    
    % Get the total.
	cr(i) = sum(cv(:));
end

% We've double counted pairs.
cr = cr./2;

% Compute the correlation integral denominator.
d = sum(im(:));
d = d*(d-1)/2;

% Final calculation of correlation integrals.
C = cr./d;

% Cleanup.
fprintf(1,'\n');