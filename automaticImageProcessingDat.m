function automaticImageProcessingDat(imagedir)

% Description
%{
%}

% Variables
%{
%}

% Cleanup
close all;
clc;

% Get the name of the current method.
[~,myname,~] = fileparts(mfilename);

% Input Validation.
%--------------------------------------------------------------------------
% Make sure there are exactly 2 input arguments. If not then throw an error
% and stop.
if ~nargin==2
    error(strcat(myname,':Argument'), strcat(                               ...
        'Must be exactly 2 input arguments.'                                ...
        ));
end

% Make sure the image directory is a character string. If not then throw an
% error and stop.
if ~isa(imagedir,'char');
    error(strcat(myname,':Argument'), strcat(                               ...
        'First Argument \"imagedir\" must be a string.'                     ...
        ));
end
%--------------------------------------------------------------------------

% Static variable declarations.
%--------------------------------------------------------------------------
% File management variables.
FS                  = filesep;
DATE_FORMAT         = 'yyyy.mm.dd.HH.MM.SS';
IMAGE_FILE_TYPES	= {'jpg';'jpeg';'tif';'tiff';'bmp';'png'};
OUT_EXT	            = 'csv';
DOT                 = '.';
AST                 = '*';
OUT_DIR             = 'results';

% Main results CSV variables.
MAIN_RESULTS_PERMISSIONS = 'w';

% Status update variables.
STARTMSG = 'Starting Image %i of %i...\n';

% Error handling variables.
BADDIRMSG   = 'Cannot use input directory\n%s\nReason:\n%s\nExiting...';
NOIMAGESMSG = 'No images found in input directory\n%s\nExiting...';
NOMKDIRMSG	= 'Cannot create output directory:\n%s\nExiting...';
SKIPMSG		= 'Skipping image %i (%s):\n%s';
LOGICALMSG	= 'Image must be monochrome bitmap, and should be a dendrite outline!';

% Parameters
NUMSTEPS = 100;
SCALEFACTOR = 2.062;
%--------------------------------------------------------------------------
% Get the names and other superfluous metadata for each of the image files
% contained within the user input directory. Catch any bad directory errors,
% quit if can't use directory.
try
	imageFileNames = cellfun(@(x) dir(x),                                   ...
        strcat(imagedir,FS,AST,DOT,IMAGE_FILE_TYPES),                       ...
        'UniformOutput',0);
catch err
	error(err.identifier,BADDIRMSG,imagedir,err.message);
end
imageFileNames = vertcat(imageFileNames{:});
numImages = size(imageFileNames,1);

% If no images, inform user, quit.
if numImages<1; fprintf(1,NOIMAGESMSG,imagedir); return; end;

% Get the number of images.
numImages = size(imageFileNames,1);
 
% Get the current date and time, and put it into a useful string format to
% make a unique output directory.
datetime = datestr(now,DATE_FORMAT);
OUT_DIR = strcat(imagedir,FS,OUT_DIR,datetime);
[status,msg,msgid] = mkdir(OUT_DIR);

% Can't make directory error handling.
if ~status; error(msgid,NOMKDIRMSG,msg); end

% Loop over all images, getting the results and putting them in the right
% places. We are looping because loading an arbitrary number of images is a
% good way to run out of memory.
for i = 1:numImages
    close all;
    % Segment the image path, name and extension. Throw out the path since
    % it is not needed: we already have it.
    [~,imname,imext] = fileparts(imageFileNames(i).name);
	
    % Load the current image. First put together the image's location as a
    % file string. Then read in the image. Finally format it as a uint8
    % array.
    try % loading the image
        im = imread(strcat(imagedir,FS,imname,imext));
    catch err
        warning(err.identifier,SKIPMSG,i,strcat(imname,imext),err.message);
        continue;
    end
	
	% If the image isn't logical, convert.
    if ~islogical(im)
        warning(SKIPMSG,i,strcat(imname,imext),LOGICALMSG);
        im = logical(im);
    end
    
    % Tell the user what image we're working on.
    fprintf(1,STARTMSG,i,numImages);
    
    % Get the range of values to compute.
    imdiagonal = log(sqrt(sum(size(im).^2)));
    step = imdiagonal/NUMSTEPS;
    lnprange = 0:step:imdiagonal;
    prange = unique(round(exp(lnprange)));
    
    % Box counting.
    % Compute the box count.
    dd = computeBoxCounting(im,prange);

    % Compute the unique dimension values so we have a monotonic function with
    % no artifacts.
    udd = unique(dd);
    [~,loc] = ismember(udd,dd);
    dd = udd;
    prange = prange(loc);
    
    % Get accessory values.
    lnr = log(prange(:));
    lndd = log(dd(:));
    midlnr = ( 1 / 2 ) * ( lnr(2:end) + lnr(1:end-1) );
    dlnr = diff(lnr);
    dlncr = diff(lndd);

    % Compute local slope and moving average.
    x1 = exp(midlnr);
    y1 = dlncr./dlnr;
    y1 = smooth(x1,y1,19);
    
    % Scale appropriately.
    sprange = SCALEFACTOR*prange;
    sx1 = SCALEFACTOR*x1;
    
    % Output to a file.
    fSpecResults = fopen(strcat(OUT_DIR,FS,imname,DOT,OUT_EXT),MAIN_RESULTS_PERMISSIONS);
    fprintf(fSpecResults,'Scale,'); fprintf(fSpecResults,'%f,',sprange); fprintf(fSpecResults,'\n');
    fprintf(fSpecResults,'Box Counting,'); fprintf(fSpecResults,'%f,',dd); fprintf(fSpecResults,'\n');
    fprintf(fSpecResults,'Scale,'); fprintf(fSpecResults,'%f,',sx1); fprintf(fSpecResults,'\n');
    fprintf(fSpecResults,'Local Slope,'); fprintf(fSpecResults,'%f,',y1); fprintf(fSpecResults,'\n');
    
    % Correlation
    % Compute correlation sum.
    dd = computeCorrelationIntegral(im,prange);    
    % Get accessory values.
    lnr = log(prange(:));
    lndd = log(dd(:));
    midlnr = ( 1 / 2 ) * ( lnr(2:end) + lnr(1:end-1) );
    % Compute takens theiler.
    x1 = exp(midlnr);
    m = diff(lndd)./diff(lnr);
    b = lndd(1:end-1)-m.*lnr(1:end-1);
    y1 = dd(2:end)./cumsum(((double(prange(2:end).').^m)-(double(prange(1:end-1).').^m)).*(1./m).*exp(b));
    
    % Scale appropriately.
    sprange = SCALEFACTOR*prange;
    sx1 = SCALEFACTOR*x1;
    
    % Output to a file.
    fprintf(fSpecResults,'Scale,'); fprintf(fSpecResults,'%f,',sprange); fprintf(fSpecResults,'\n');
    fprintf(fSpecResults,'Correlation,'); fprintf(fSpecResults,'%f,',dd); fprintf(fSpecResults,'\n');
    fprintf(fSpecResults,'Scale,'); fprintf(fSpecResults,'%f,',sx1); fprintf(fSpecResults,'\n');
    fprintf(fSpecResults,'TT Dimension,'); fprintf(fSpecResults,'%f,',y1); fprintf(fSpecResults,'\n');
    fclose(fSpecResults);
    
end

end