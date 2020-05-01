file_path = fullfile( pwd, 'example', 'Al9wt.Si 3kmm 0.03mms 0mT_No2  1 mod_OUT.csv' );
file_data = importdata( file_path );
scale = file_data.data( 7, : );
takens_theiler = file_data.data( 8, : );
mid_index = round( length( takens_theiler( : ) ) / 2 );
[ min_value, min_index ] = min( takens_theiler( 1 : mid_index ) );
[ max_value, max_index ] = max( takens_theiler( mid_index : end ) );
max_index = max_index + mid_index - 1;
fit_log_scale = log10( scale( min_index : max_index ) );
fit_tt = takens_theiler( min_index : max_index );

a = 1.15 .* 10 .^ ( -7 );
b = 2.39 .* 10 .^ ( -7 );
c = 8.71;
d = 1.35;
sigmoid_fit = ( a ./ ( b + exp( -c .* log10( scale ) ) ) ) + d;
max_sig_fit = max( sigmoid_fit( : ) );
min_sig_fit = min( sigmoid_fit( : ) );
mean_sig_fit = ( max_sig_fit + min_sig_fit ) / 2;
mean_sig_fit_radius = 10 .^ ( log( ( a ./ ( mean_sig_fit - d ) ) - b ) ./ -c );

figh = figure;
figh.Color = 'white';
figh.Position = [ 100 100 500 450 ];

axh = axes( figh );
axh.TickLabelInterpreter = 'latex';
axh.XScale = 'log';
min_x = 1;
max_x = 10000;
axh.XLim = [ min_x max_x ];
axh.XLabel.Interpreter = 'latex';
axh.XLabel.String = 'Log Correlation Radius \(r\;\left(\log{\mathrm{\mu}\rm{m}}\right)\)';
min_y = 1.3;
max_y = 1.9;
axh.YLim = [ min_y max_y ];
axh.YTickLabel = min_y : 0.1 : max_y;
axh.YLabel.Interpreter = 'latex';
axh.YLabel.String = 'Takens-Theiler Estimator of $\nu$';
hold( axh, 'on' );

ph1 = plot( axh, scale, takens_theiler );
ph1.Color = [0.7 0.7 0.7];
ph1.LineStyle = 'none';
ph1.Marker = '.';
ph1.MarkerSize = 10;

ph2 = plot( axh, scale, sigmoid_fit );
ph2.Color = 'k';
ph2.LineStyle = '-';
ph2.Marker = 'none';

ph3 = plot( axh, [ mean_sig_fit_radius mean_sig_fit_radius ], [ min_y mean_sig_fit ] );
ph3.Color = 'k';
ph3.LineStyle = ':';
ph3.Marker = 'none';

xstop = mean_sig_fit_radius;
ph4 = plot( axh, [ axh.XLim(1) xstop ], [ mean_sig_fit mean_sig_fit ] );
ph4.Color = 'k';
ph4.LineStyle = ':';
ph4.Marker = 'none';

xstop = scale( end - 1 );
ph4 = plot( axh, [ axh.XLim(1) xstop ], [ max_sig_fit max_sig_fit ] );
ph4.Color = 'k';
ph4.LineStyle = ':';
ph4.Marker = 'none';

xstop = scale( 1 );
ph4 = plot( axh, [ axh.XLim(1) xstop ], [ min_sig_fit min_sig_fit ] );
ph4.Color = 'k';
ph4.LineStyle = ':';
ph4.Marker = 'none';

text_h = annotation( 'textbox' );
text_h.Position = [ 0.6 0.3 0.1 0.1 ];
text_h.LineStyle = 'none';
text_h.Interpreter = 'latex';
text_h.String = { ...
    '\( \nu = \frac{a}{b+e^{-c\;\log_{10}{r}}}+d \)', ...
    '\( a = 1.15\times 10^{-7} \)', ...
    '\( b = 2.39\times 10^{-7} \)', ...
    '\( c = 8.71 \)', ...
    '\( d = 1.35 \)' ...
    };

out_folder = fullfile( pwd, 'fit_plot' );
export_fig( fullfile( out_folder, 'fit_plot.png' ), '-png', figh );
export_fig( fullfile( out_folder, 'fit_plot.eps' ), '-eps', figh );
matlab2tikz( fullfile( out_folder, 'fit_plot.tex' ), 'figurehandle', figh );