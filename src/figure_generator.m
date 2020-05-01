function [ box_count_figh, correlation_figh ] = ...
    automaticImageProcessing(imagedir)

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
if ~isa(imagedir,'char')
    error(strcat(myname,':Argument'), strcat(                               ...
        'First Argument \"imagedir\" must be a string.'                     ...
        ));
end
%--------------------------------------------------------------------------

% Static variable declarations.
%--------------------------------------------------------------------------
% File management variables.
FS                  = filesep;
%DATE_FORMAT         = 'yyyy.mm.dd.HH.MM.SS';
IMAGE_FILE_TYPES	= {'jpg';'jpeg';'tif';'tiff';'bmp';'png'};
OUT_EXT	            = 'csv';
OUT_EXT_IMG         = 'png';
DOT                 = '.';
AST                 = '*';
OUT_DIR             = 'results';
RESULTS             = 'results';

% Main results CSV variables.
MAIN_RESULTS_PERMISSIONS = 'w';
MAIN_RESULTS_FORMAT_STRING_HEADERS = '%s,%s,%s,%s,%s,%s,%s,%s,%s\n';
MAIN_RESULTS_FORMAT_STRING = '%s,%s,%s,%s,%s,%s,%s,%s,%s\n';
CSV_MR_1 = 'Image Name';
CSV_MR_2 = 'Box-Counting Dimension Estimator';
CSV_MR_3 = 'Box-Counting Dimension Estimator Radius Low';
CSV_MR_4 = 'Box-Counting Dimension Estimator Radius High';
CSV_MR_5 = 'Correlation Dimension Estimator';
CSV_MR_6 = 'Correlation Dimension Estimator Radius Low';
CSV_MR_7 = 'Correlation Dimension Estimator Radius High';
CSV_MR_8 = 'Correlation Dimension Hill Estimator';
CSV_MR_9 = 'Correlation Dimension Hill Radius';

% Status update variables.
STARTMSG = 'Starting Image %i of %i...\n';

% Error handling variables.
BADDIRMSG   = 'Cannot use input directory\n%s\nReason:\n%s\nExiting...';
NOIMAGESMSG = 'No images found in input directory\n%s\nExiting...';
NOMKDIRMSG	= 'Cannot create output directory:\n%s\nExiting...';
SKIPMSG		= 'Skipping image %i (%s):\n%s';
BADFIGMSG   = 'Bad figure for image %i:\n%s';
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
%datetime = datestr(now,DATE_FORMAT);
OUT_DIR = strcat(imagedir,FS,OUT_DIR);
[status,msg,msgid] = mkdir(OUT_DIR);

% Can't make directory error handling.
if ~status; error(msgid,NOMKDIRMSG,msg); end

% The first file is called 'dirName.txt' and is the main results file.
% Contains fractal dim, best fit line info, etc.
fMainResults = fopen(strcat(OUT_DIR,FS,RESULTS,DOT,OUT_EXT),MAIN_RESULTS_PERMISSIONS);

% Write a header line to the main results file.
fprintf(fMainResults,MAIN_RESULTS_FORMAT_STRING_HEADERS,...
	CSV_MR_1,CSV_MR_2,CSV_MR_3,...
    CSV_MR_4,CSV_MR_5,CSV_MR_6,...
    CSV_MR_7,CSV_MR_8,CSV_MR_9);

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

    close all;
    % Get the scaling regime image.
    xpos = scalingRegime(x1,y1);
    loreg = xpos(1);
    hireg = xpos(2);

    % Scale range values.
    sprange = SCALEFACTOR*prange;
    sx1 = SCALEFACTOR*x1;
    sloreg = SCALEFACTOR*loreg;
    shireg = SCALEFACTOR*hireg;

    % Get indices of input bounds.
    [~,loi] = find(sprange < sloreg,1,'last');
    [~,hii] = find(sprange > shireg,1);
    sloreg = sprange(loi);
    shireg = sprange(hii);

    % Compute dimension estimate.
    beta1 = mean(y1((sprange)>sloreg & (sprange)<shireg));

    % Final plot.
    xlabel = 'Box Side Length $r \left(\mu m\right)$';
    y1label = 'Box-count Ratio';
    y2label = 'Estimate of $\beta$';
    box_count_figh = dualplot(sprange(1:end-1),dd(1:end-1),sx1(1:end-1),y1(1:end-1),loi,hii,beta1,xlabel,y1label,y2label);

    lobeta = sloreg;
    hibeta = shireg;

    % Write the figures.
    % Save final plot name.
    figname = strcat(OUT_DIR,FS,imname,'_box_dual');
    try
        export_fig(figname,'-png',box_count_figh);
        export_fig(figname,'-eps',box_count_figh);
        matlab2tikz(figname,'figurehandle',box_count_figh);
    catch err
        warning(err.identifier,BADFIGMSG,i,strcat(fileNames(i).name,OUT_EXT_IMG),err.message);
    end

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

    close all;
    % Get the scaling regime image.
    xpos = scalingRegime(x1,y1);
    loreg = xpos(1);
    hireg = xpos(2);

    % Scale range values.
    sprange = SCALEFACTOR*prange;
    sx1 = SCALEFACTOR*x1;
    sloreg = SCALEFACTOR*loreg;
    shireg = SCALEFACTOR*hireg;

    % Get indices of input bounds.
    [~,loi] = find(sprange < sloreg,1,'last');
    [~,hii] = find(sprange > shireg,1);
    sloreg = sprange(loi);
    shireg = sprange(hii);

    % Compute dimension estimate.
    nu1 = mean(y1((sprange)>sloreg & (sprange)<shireg));

    % Get hill value.
    [nu2,hillnu] = max(y1(hireg:end));
    hillnu = sprange(hillnu);

    % Final plot.
    xlabel = 'Correlation Radius $r \left(\mu m\right)$';
    y1label = 'Correlation Ratio';
    y2label = 'Estimate of $\nu$';
    correlation_figh = dualplot(sprange(1:end-2),dd(1:end-2),sx1(1:end-2),y1(1:end-2),loi,hii,nu1,xlabel,y1label,y2label);

    lonu = sloreg;
    hinu = shireg;

    % Save final plot name.
    figname = strcat(OUT_DIR,FS,imname,'_corr_dual');

    % Write the figures.
    try
        export_fig(figname,'-png',correlation_figh);
        export_fig(figname,'-eps',correlation_figh);
        matlab2tikz(figname,'figurehandle',correlation_figh);
    catch err
        warning(err.identifier,BADFIGMSG,i,strcat(fileNames(i).name,OUT_EXT_IMG),err.message);
    end

    % Write the main results for the current image.
    fprintf(fMainResults,MAIN_RESULTS_FORMAT_STRING,                        ...
        imname,                                                             ...
        beta1,                                                              ...
        lobeta,                                                             ...
        hibeta,                                                             ...
        nu1,                                                                ...
        lonu,                                                               ...
        hinu,                                                               ...
        nu2,                                                                ...
        hillnu ...
    );
end

% Close the main results file.
fclose(fMainResults);
fprintf(1,'Complete!\n');

end