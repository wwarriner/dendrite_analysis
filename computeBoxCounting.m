function nhat = computeBoxCounting(im,prange)

% Define count function.
countfunc = @(x) any(x.data(:));

% Define block processing function.
blockfunc = @(x,im) blockproc(im,[x x],countfunc);

% Define fractal function.
fracfunc = @(x,im) sum(reshape(blockfunc(x,im),[],1));

% Apply box-counting method to the image.
nhat = arrayfun(@(x) fracfunc(x,im), prange);
nhat = 1./nhat;

end