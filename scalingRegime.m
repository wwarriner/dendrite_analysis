function xpos = scalingRegime(x1,y1)

% Show trial plot.
fig1 = figure;
trial = axes;
axes(trial);
hold on;
plot(x1,y1,'r');
plot(x1,y1,'or');
plot(x1,y1,'+r');
set(gca,'xscale','log');
xmin = 1;
xmax = 10e4;
ymin = 1;
ymax = 2;
xlim([xmin xmax]);
ylim([ymin ymax]);
aspect = (log(xmax) - log(xmin)) / (ymax - ymin);

xpos = zeros(1,2);
ypos = zeros(1,2);
for i = 1:2
    % Get scaling regime range point.
    [xpos(i),ypos(i)] = ginput(1);

    % Find y distance from pointer to nearest point.
    ydist = abs(ypos(i)-y1);
    
    % Find x distance from pointer to nearest point.
    lnx1 = log(x1);
    lnxp = log(xpos(i));
    xdist = abs(lnx1 - lnxp);
    
    % Find nearest point on curve.
    [~,nearestidx] = min(xdist.^2 + (ydist * aspect).^2);
    
    % Store xpos of nearest point.
    xpos(i) = x1(nearestidx);
    ypos(i) = y1(nearestidx);
    
    % Provide feedback.
    plot(xpos(i),ypos(i),'ok');
end

% Pause.
fprintf(1,'Click on image to continue.\n');
ginput(1);

% Sort xpos.
xpos = sort(xpos(:));


end