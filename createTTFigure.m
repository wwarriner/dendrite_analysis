function figim = createTTFigure(name,lnr,tt,gtt,fdi)
% Plotting ---------------------------------------------------------------------
% Clear all figures.
close all;

% Set up figure, and axes handle.
figure('name',name);
ah = axes;

% Set up x-axis.
lox = floor(lnr(1)*2)/2;
hix = ceil(lnr(end)*2)/2;
xlabel('ln(r)');
set(gca,'XLimMode',     'manual');
set(gca,'XLim',         [lox hix]);
set(gca,'XTick',        lox:0.5:hix);
set(gca,'XTickLabel',	sprintf('%2.1f|',lox:0.5:hix));

% Set up y-axis.
loy = 1.2;
hiy = 1.9;
ylabel('Takens-Theiler Estimator of Correlation Dimension');
set(gca,'YLimMode',     'manual');
set(gca,'YLim',         [loy hiy]);
set(gca,'YTick',        loy:0.1:hiy);
set(gca,'YTickLabel',	sprintf('%3.2f|',loy:0.1:hiy));

% Hold the plot so we can draw multiple things on it.
hold(ah);

% Plot tt points.
plot(lnr,                       tt,                 'k.',	...
	'LineStyle',                'none',                     ...
	'MarkerSize',               5,                          ...
	'MarkerFaceColor',          'none'                      );

% Plot gtt curve on top of tt for visibility.
plot(lnr(6:end-5),				gtt(6:end-5),       'k'     );

% Plot fractal dimension point on top of others.
plot(lnr(fdi),                  gtt(fdi),           'ko',   ...
    'LineStyle',                'none',                     ...
    'MarkerSize',               9,                          ...
    'MarkerFaceColor',          'none'                      );
plot(lnr(fdi),                  gtt(fdi),           'k+',   ...
    'LineStyle',                'none',                     ...
    'MarkerSize',               9,                          ...
    'MarkerFaceColor',          'none'                      );
plot([lnr(fdi) lnr(fdi)],        [0 gtt(fdi)],       'k:'   );
plot([0 lnr(fdi)],               [gtt(fdi) gtt(fdi)],'k:'   );

% Export plot to an image using external code.
figim = export_fig('-png','-m2',gca);

% Close figure.
close all;

end

