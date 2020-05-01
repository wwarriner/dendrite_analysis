function plot_velocity_fit()

data = readtable( 'data.csv' );

value_v = data{:, 'velocity'};
value_c = data{:, 'concentration'};
t_logscale = data{:, 'logscale'};

lo_lo = value_c == 0 & value_v == 0;
lo_hi = value_c == 0 & value_v == 1;
hi_lo = value_c == 1 & value_v == 0;
hi_hi = value_c == 1 & value_v == 1;

actual_v = log10([ 0.03; 0.12 ]);
actual_v = actual_v( value_v + 1 );

out_folder = fullfile( pwd, 'fit_sdas' );

X = actual_v(value_c == 0);
y = t_logscale(value_c == 0);
mdl = fitlm(X, y);
gen_plot(fullfile(out_folder, "low_c"), mdl);
lo = t_logscale(lo_lo);
hi = t_logscale(lo_hi);
gen_mean_plot(fullfile(out_folder, "low_c_means"), 10.^lo, 10.^hi);

X = actual_v(value_c == 1);
y = t_logscale(value_c == 1);
mdl = fitlm(X, y);
gen_plot(fullfile(out_folder, "high_c"), mdl);
lo = t_logscale(hi_lo);
hi = t_logscale(hi_hi);
gen_mean_plot(fullfile(out_folder, "high_c_means"), 10.^lo, 10.^hi);

X = actual_v;
y = t_logscale;
mdl = fitlm(X, y);
gen_plot(fullfile(out_folder, "all_c"), mdl);
lo = t_logscale(value_v == 0);
hi = t_logscale(value_v == 1);
gen_mean_plot(fullfile(out_folder, "all_c_means"), 10.^lo, 10.^hi);

end


function gen_plot(out_file, mdl)

FONT_SIZE = 16;
LINE_WIDTH_BASE = 2;
MARKER_SIZE = LINE_WIDTH_BASE * 6;

fh = figure('color', 'white');
axh = axes(fh);
hold(axh, 'on');
ph = plot(mdl);
ph(1).MarkerEdgeColor = [0.7 0.7 0.7];
ph(1).Marker = '.';
ph(1).MarkerSize = MARKER_SIZE;
ph(2).Color = [0.0 0.0 0.0];
ph(2).LineWidth = LINE_WIDTH_BASE * 1.25;
ph(3).Color = [0.1 0.1 0.1];
ph(3).LineWidth = LINE_WIDTH_BASE * 0.5;
ph(3).LineStyle = ":";
ph(4).Color = [0.1 0.1 0.1];
ph(4).LineWidth = LINE_WIDTH_BASE * 0.5;
ph(4).LineStyle = ":";
lh = legend(axh);
lh.Visible = "off";
axh.FontSize = FONT_SIZE;
axis(axh, 'square');
axh.Title.Visible = "off";
axh.XLabel.String = "Solidification Velocity (mm/ms)";
axh.XTick = log10([0.03, 0.12]);
axh.XTickLabel = [30 120];
axh.XLim = axh.XTick + [-0.1 0.1];
axh.YLabel.String = "log10 Scaling Transition (um)";
axh.YTick = 1.5 : 0.1 : 2.2;
ytickformat(axh, "%1.1f");
axh.YLim = [1.5, 2.2];

export_fig( out_file + ".png", '-png', fh );
export_fig( out_file + ".eps", '-eps', fh );
matlab2tikz( char(out_file + ".tex"), 'figurehandle', fh );

end


function gen_mean_plot(out_file, lo, hi)

FONT_SIZE = 16;
LINE_WIDTH_BASE = 2;
MARKER_SIZE = LINE_WIDTH_BASE * 6;

m_lo = mean(lo);
s_lo = std(lo);
m_hi = mean(hi);
s_hi = std(hi);

X = log10([0.03 0.12]);
y = [m_lo m_hi];
Y = log10(y);
err = [s_lo s_hi];
lo_err = log10(y - err) - Y;
hi_err = log10(y + err) - Y;

fh = figure('color', 'white');
axh = axes(fh);
hold(axh, 'on');
ph = errorbar(X, Y, lo_err, hi_err);
ph.Color = [0 0 0];
ph.LineWidth = LINE_WIDTH_BASE * 0.75;
lh = legend(axh);
lh.Visible = "off";
axh.FontSize = FONT_SIZE;
axis(axh, 'square');
axh.Title.Visible = "off";
axh.XLabel.String = "Solidification Velocity (mm/ms)";
axh.XTick = log10([0.03, 0.12]);
axh.XTickLabel = [30 120];
axh.XLim = axh.XTick + [-0.1 0.1];
axh.YLabel.String = "log10 Scaling Transition (um)";
axh.YTick = 1.5 : 0.1 : 2.2;
ytickformat(axh, "%1.1f");
axh.YLim = [1.5, 2.2];

export_fig( out_file + ".png", '-png', fh );
export_fig( out_file + ".eps", '-eps', fh );
matlab2tikz( char(out_file + ".tex"), 'figurehandle', fh );

end
