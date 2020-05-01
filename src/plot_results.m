data = readtable('results.csv');
out_folder = fullfile( pwd, 'plot_results' );
CONCENTRATION = 1;
VELOCITY = 3;
BOX = 3;
COR = 5;
SCALE = 7;
% for i = [CONCENTRATION VELOCITY]
%     lo = i;
%     hi = i + 1;
%     name = data{lo, 'parameter'}{1};
%     for j = [BOX COR SCALE]
%         fh = figure('color', 'white');
%         axh = axes(fh);
%         axh.XLim = [-0.2 1.2];
%         axh.YLim = [1.3 2.1];
%         axh.XTick = [0 1];
%         axis(axh, 'square');
%         hold(axh, 'on');
%         val = j;
%         err = j + 1;
%         measure = data.Properties.VariableNames{j};
%         x = [data{lo, 'value'} data{hi, 'value'}];
%         y = [data{lo, val} data{hi, val}];
%         e = [data{lo, err} data{hi, err}];
%         eh = errorbar(axh, x, y, e);
%         eh.Color = 'k';
%         filename = sprintf( '%s_%s', name, measure );
%         export_fig( fullfile( out_folder, [filename, '.png'] ), '-png', fh );
%         export_fig( fullfile( out_folder, [filename, '.eps'] ), '-eps', fh );
%         matlab2tikz( fullfile( out_folder, [filename, '.tex'] ), 'figurehandle', fh );
%         close(fh);
%     end
% end

fh = figure('color', 'white');
axh = axes(fh);
VELS = VELOCITY + [0 1];
scale = data{VELS, SCALE};
err = data{VELS, SCALE + 1};
v = data{VELS, 'v'};
logv = log10(v);
errorbar(axh, logv, scale, err);
