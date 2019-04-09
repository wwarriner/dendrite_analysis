function midvals( input_dir )
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
	filenames = dir(strcat(input_dir,FS,AST,DOT,CSV));
catch err
	error(err.identifier,BADDIRMSG,input_dir,err.message);
end

if ~exist(input_dir,'dir')
    error('Could not locate %s.', input_dir);
end

result_dir = [ input_dir, FS, OUT_DIR ];
mkdir( result_dir );
result_csv = fopen( [ result_dir, FS, OUT_DIR, DOT, CSV ], 'w' );
fprintf( result_csv, '%s,%s,%s,%s,%s,%s\n', 'Name', 'Radius (um)', 'Min Val', 'Max Val', 'Mid Val', 'Hill Radius (um)' );

for i = 1:length(filenames(:))

    csv1 = fopen(strcat(input_dir,FS,filenames(i).name),MAIN_RESULTS_PERMISSIONS);

    temp = next_line_to_array(csv1,',');
    temp = next_line_to_array(csv1,',');
    temp = next_line_to_array(csv1,',');
    temp = next_line_to_array(csv1,',');
    temp = next_line_to_array(csv1,',');
    temp = next_line_to_array(csv1,',');

    line1x = next_line_to_array(csv1,',');        
    line1y = next_line_to_array(csv1,',');   

    half_index = floor( 0.5 * length( line1y ) );
    [minval,minindex] = min( line1y( 1:half_index ) );
    [maxval,maxindex] = max( line1y( half_index:end ) );
    maxindex = maxindex + half_index - 1;
    
    midval = mean( [ minval, maxval ] );
    
    crossover_scale = ...
        nonmono_interp1( ...
            line1y( minindex:maxindex ), ...
            line1x( minindex:maxindex ), ...
            midval ...
            );
    
    fprintf( result_csv, '%s,%s,%s,%s,%s,%s\n', filenames(i).name, num2str( crossover_scale, 15 ), num2str( minval, 15 ), num2str( maxval, 15 ), num2str( midval, 15 ), num2str( line1x(maxindex), 15 ) );
    
end

fclose(result_csv);

end



function mat = next_line_to_array( fid, delim )

    mat = fgets(fid);
    mat = strsplit(mat,delim);
    mat = cellfun(@(x) str2num(x), mat(2:end), 'UniformOutput', false);
    mat = cell2mat(mat);    
    
end



function vq = nonmono_interp1( x, v, xq )

    vq = [];

    for i = 1:length(x) - 1
        
        if x( i ) == x ( i + 1 )
            x ( i ) = x ( i ) - 1e-9;
            x ( i + 1 ) = x ( i + 1 ) + 1e-9;
        end
       
        if v( i ) == v ( i + 1 )
            v ( i ) = v ( i ) - 1e-9;
            v ( i + 1 ) = v ( i + 1 ) + 1e-9;
        end
        
        out = interp1( ...
            [ x( i ), x( i + 1 ) ], ...
            [ v( i ), v( i + 1 ) ], ...
            xq ...
            );
        
        if ~isnan( out )
           
            vq = [ vq, out ];
            
        end
        
    end

end

