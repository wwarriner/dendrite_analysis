function [fitresult, gof] = sigmoidFit(logScale, TT)
% a	1.15E-07
% b	2.39E-07
% c	8.705818649
% d	1.35046432


%CREATEFIT(LOGSCALE,TT)
%  Create a fit.
%
%  Data for 'Sigmoid Fit' fit:
%      X Input : logScale
%      Y Output: TT
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  See also FIT, CFIT, SFIT.

%  Auto-generated by MATLAB on 29-Mar-2015 14:40:06


%% Fit: 'Sigmoid Fit'.
[xData, yData] = prepareCurveData( logScale, TT );

% Set up fittype and options.
ft = fittype( 'a/(b+exp(-c*x)) + d', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = [0.0975404049994095 0.278498218867048 0.546881519204984 0.957506835434298];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

% Create a figure for the plots.
figure( 'Name', 'Sigmoid Fit' );

% Plot fit with data.
subplot( 2, 1, 1 );
h = plot( fitresult, xData, yData, 'predobs', 0.99 );
legend( h, 'TT vs. logScale', 'Sigmoid Fit', 'Lower bounds (Sigmoid Fit)', 'Upper bounds (Sigmoid Fit)', 'Location', 'NorthEast' );
% Label axes
xlabel logScale
ylabel TT
grid on

% Plot residuals.
subplot( 2, 1, 2 );
h = plot( fitresult, xData, yData, 'residuals' );
legend( h, 'Sigmoid Fit - residuals', 'Zero Line', 'Location', 'NorthEast' );
% Label axes
xlabel logScale
ylabel TT
grid on

