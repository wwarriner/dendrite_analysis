function dataComparison( dir1, dir2 )


% Static variable declarations.
%--------------------------------------------------------------------------
% File management variables.
FS                  = filesep;
CSV                 = 'csv';
DOT                 = '.';
AST                 = '*';
OUT_DIR             = 'results';

% Main results CSV variables.
MAIN_RESULTS_PERMISSIONS = 'r';

% Error handling variables.
BADDIRMSG   = 'Cannot use input directory\n%s\nReason:\n%s\nExiting...';
%--------------------------------------------------------------------------




try
	filenames1 = dir(strcat(dir1,FS,AST,DOT,CSV));
catch err
	error(err.identifier,BADDIRMSG,dir1,err.message);
end

try
	filenames2 = dir(strcat(dir2,FS,AST,DOT,CSV));
catch err
	error(err.identifier,BADDIRMSG,dir2,err.message);
end

for i = 1:length(filenames1(:))
    for j = 1:length(filenames2(:))
        
        csv1 = fopen(strcat(dir1,FS,filenames1(i).name),MAIN_RESULTS_PERMISSIONS);
        csv2 = fopen(strcat(dir2,FS,filenames2(j).name),MAIN_RESULTS_PERMISSIONS);
        
        % 0 : box count
        % 1 : box count local slop moving average
        % 2 : correlation sum
        % 3 : takens-theiler estimator
        entry_val = 3;
        for k=0:entry_val-1
            get_csv_line_as_array(csv1,',');
            get_csv_line_as_array(csv1,',');
            get_csv_line_as_array(csv2,',');
            get_csv_line_as_array(csv2,',');
        end
        
        % primary data
        line1x = get_csv_line_as_array(csv1,',');        
        line1y = get_csv_line_as_array(csv1,',');        
        
        line2x = get_csv_line_as_array(csv2,',');
        line2y = get_csv_line_as_array(csv2,',');
        
        fclose(csv1);
        fclose(csv2);
        
        % primary scatter plot
        cmp = colormap(parula(255));
        
        ax = axes;
        hold(ax,'on');
        plot(ax,line1x,line1y,'.','color',cmp(20,:));
        plot(ax,line2x,line2y,'.','color',cmp(200,:));
        
        % mid radii
        [mid1,min1,max1] = mid_rise_index( line1y );        
        mid_radius_1 = line1x( mid1 );
        
        [mid2,min2,max2] = mid_rise_index( line2y );
        mid_radius_2 = line2x( mid2 );
        
        % secondary upper/lower bounds
        plot(ax,[1,10000],[line1y(min1),line1y(min1)],':','linewidth',0.25,'color',cmp(20,:));
        plot(ax,[1,10000],[line1y(max1),line1y(max1)],':','linewidth',0.25,'color',cmp(20,:));
        frac_extent = floor( 0.1 * length( line1x(:) ) );
        plot(ax,[line1x(mid1-frac_extent),line1x(mid1+frac_extent)],[line1y(mid1),line1y(mid1)],'-','linewidth',0.25,'color',cmp(20,:));
        plot(ax,[line1x(mid1),line1x(mid1)],[1,line1y(mid1)],'-','linewidth',2,'color',cmp(20,:));
        
        plot(ax,[1,10000],[line2y(min2),line2y(min2)],':','linewidth',0.25,'color',cmp(200,:));
        plot(ax,[1,10000],[line2y(max2),line2y(max2)],':','linewidth',0.25,'color',cmp(200,:));
        frac_extent = floor( 0.1 * length( line2x(:) ) );
        plot(ax,[line2x(mid2-frac_extent),line2x(mid2+frac_extent)],[line2y(mid2),line2y(mid2)],'-','linewidth',0.25,'color',cmp(200,:));
        plot(ax,[line2x(mid2),line2x(mid2)],[1,line2y(mid2)],'-','linewidth',2,'color',cmp(200,:));
        
        % plot settings
        ax.XScale = 'log';
        ax.YLim = [1,2];
        ax.XLabel.String = 'Log Radius (log um)';
        ax.YLabel.String = 'Takens-Theiler Correlation Dimension Estimator';
        
        pause();
        
    end
end

end



function [index,minindex,maxindex] = mid_rise_index( linear_array )

[minval,minindex] = min_of_first_half( linear_array );
[maxval,maxindex] = max_of_last_half( linear_array );

midval = mean( [ minval, maxval ] );

first_quarter = ceil( 1/4 * length( linear_array ) );
third_quarter = floor( 3/4 * length( linear_array ) );
index = find( linear_array( minindex:maxindex ) > midval, 1 ) + minindex - 1;

end



function [minval,index] = min_of_first_half( linear_array )

mid_point = linear_array_mid_point( linear_array );
[minval,index] = min( linear_array( 1:mid_point ) );

end



function [maxval,index] = max_of_last_half( linear_array )

mid_point = linear_array_mid_point( linear_array );
[maxval,index] = max( linear_array( mid_point:end ) );
index = index + mid_point - 1;

end



function index = linear_array_mid_point( linear_array )

array_length = length( linear_array(:) );
index = floor( array_length / 2 );

end



function mat = get_csv_line_as_array( fid, delim )

    mat = fgets(fid);
    mat = strsplit(mat,delim);
    mat = cellfun(@(x) str2num(x), mat(2:end), 'UniformOutput', false);
    mat = cell2mat(mat);    
    
end