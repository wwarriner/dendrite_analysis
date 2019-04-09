function automaticImagePrepping(imagedir, imtype)
% Description
%{
---------------------------------------------------------------------------
The purpose of this function is to automatically load, segment and run
prepareImage on each image in a folder full of images. After each image is
processed, a copy is stored in a results folder with name dirName plus the
current date and time.

This function is not capable of automatically distinguishing between light
and dark field. The user should separate the images into folders containing
either one or the other. They should not be mixed when this function is
run, or unexpected results will occur.
---------------------------------------------------------------------------
%}

% Variables
%{
---------------------------------------------------------------------------
This function takes in 2 variables:
    imageDir    - Image directory as a properly formatted file path string.
    imtype      - Integer valued from {1, 2}
                    1 - Image is darkfield.
                    2 - Image is lightfield.
---------------------------------------------------------------------------
The function returns 0 variables. Instead it modifies and saves copies of
loaded images after turning them into single-pixel-boundary logical images.
---------------------------------------------------------------------------
This function will only work with jpg, tif, bmp, and png files.
---------------------------------------------------------------------------
%}

% CONVERT TO LOGICAL?!

% Input Validation.
%--------------------------------------------------------------------------
% Make sure there are exactly 2 input arguments. If not then throw an error
% and stop.
if ~nargin==2
    error(strcat(                                                       ...
        'Must be exactly 2 input arguments.'                            ...
        ));
end

% Make sure the image directory is a character string. If not then throw an
% error and stop.
if ~isa(imagedir,'char')
    error(strcat(                                                       ...
        'First Argument \"imagedir\" must be a string.'                 ...
        ));
end

% Make sure the image type is either an integer 1 or 2. No other inputs
% allowed, otherwise throw an error and stop.
if ~(imtype == 1 || imtype == 2)
    error(strcat(                                                       ...
        'Second Argument \"imtype\" must be either 1 or 2',              ...
        '\n  1 - Dark Field Image',                                     ...
        '\n  2 - Light Field Image'                                     ...
        ));
end
%--------------------------------------------------------------------------

% Static Variables.
%--------------------------------------------------------------------------
% Define a color for comparison overlay.
% First vector is [R,G,B], from 0 to 255.
OUTLINE_COLOR = reshape(uint8([0,255,0]),[1 1 3]);

% File management variables.
FS					= filesep;
DATE_FORMAT			= 'yyyy.mm.dd.HH.MM.SS';
IMAGE_FILE_TYPES	= {'jpg';'jpeg';'tif';'tiff';'bmp';'png'};
OUT_EXT				= 'bmp'; % don't change this!
DOT					= '.';
AST					= '*';
OUT_DIR				= 'out';
OUT					= '_OUT';
COM					= '_COMPARE';
RESULTS             = 'results';

% Main results CSV variables.
MAIN_RESULTS_PERMISSIONS = 'w';
MAIN_RESULTS_FORMAT_STRING_HEADERS = '%s,%s,%s\n';
MAIN_RESULTS_FORMAT_STRING = '%s,%s,%s\n';
CSV_MR_1 = 'Image Name';
CSV_MR_2 = 'Volume/Volume';
CSV_MR_3 = 'Surface Area/Volume';

% Error handling variables.
BADDIRMSG   = 'Cannot use input directory\n%s\nReason:\n%s\nExiting...';
NOIMAGESMSG = 'No images found in input directory\n%s\nExiting...';
NOMKDIRMSG	= 'Cannot create output directory:\n%s\nExiting...';
SKIPMSG		= 'Skipping image %i (%s):\n%s';
EMPTYMSG	= 'Prepared image empty!';
SMALLMSG	= 'Image must be a least 3 pixels in each dimension!';
%--------------------------------------------------------------------------
% Get the names and other superfluous metadata for each of the image files
% contained within the user input directory. Catch any bad directory errors,
% quit if can't use directory.
try
	imageFileNames = cellfun(@(x) dir(x),                                    ...
							 strcat(imagedir,FS,AST,DOT,IMAGE_FILE_TYPES),	 ...
							 'UniformOutput',0);
catch err
	error(err.identifier,BADDIRMSG,imagedir,err.message);
end
imageFileNames = vertcat(imageFileNames{:});
numImages = size(imageFileNames,1);
% If no images, inform user, quit.
if numImages<1; fprintf(1,NOIMAGESMSG,imagedir); return; end;

% Get the current date and time, and put it into a useful string format to
% make a unique output directory.
datetime = datestr(now,DATE_FORMAT);
OUT_DIR = strcat(imagedir,FS,OUT_DIR,datetime);
[status,msg,msgid] = mkdir(OUT_DIR);
% Can't make directory error handling.
if ~status; error(msgid,NOMKDIRMSG,msg); end

% The first file is called 'dirName.txt' and is the main results file.
% Contains fractal dim, best fit line info, etc.
fMainResults = fopen(strcat(OUT_DIR,FS,RESULTS,DOT,'txt'),MAIN_RESULTS_PERMISSIONS);

% Write a header line to the main results file.
fprintf(fMainResults,MAIN_RESULTS_FORMAT_STRING_HEADERS,...
	CSV_MR_1,CSV_MR_2,CSV_MR_3);

% Loop over all images, creating the resulting images and putting them in
% the results directory.
for i = 1:numImages
    
    % Segment the image path, name and extension. Throw out the path since
    % it is not needed: we already have it.
    [~,imname,imext] = fileparts(imageFileNames(i).name);
    
    % Load the current image. First put together the image's location as a
    % file string. Then read in the image. Finally format it as a uint8
    % array.
    try % loading the image
        im = uint8(imread(strcat(imagedir,FS,imname,imext)));
    catch err
        warning(err.identifier,SKIPMSG,i,strcat(imname,imext),err.message);
        continue;
    end
    if size(im,1)<3||size(im,2)<3 % Size checking
        warning(SKIPMSG,i,strcat(imname,imext),SMALLMSG);
    end
    %imwrite(im(601:(601+259),301:(301+346)),'G:\paper images\test image\0 orig.png');
    % Make a copy of the image for creating the overlay.
    if size(im,3)==1                                % grayscale
        imcompare = repmat(im,[1 1 3]);
	else											% color
        imcompare = im;
    end
    imcompare = imcompare(2:end-1,2:end-1,:);
    
    % Run code depending on whether the user input images are dark field
    % or light field.
    [im, imfilled] = prepareImage(im,imtype);
    if isempty(im); % This should not happen, but just in case.
        warning(SKIPMSG,i,strcat(imname,imext),EMPTYMSG);
        continue;
    end
    
    % Replicate the color vector to the full prepared image size. 
    colormat = repmat(OUTLINE_COLOR,size(im));
    % Also make a check matrix the same size as the trimmed image using the
    % outline binary image.
    checkmat = repmat(im,[1 1 3]);
    % Finally, for any pixel in the trimmed original image where the
    % outline exists in the corresponding check image, replace that pixel
    % with a colored pixel.
    imcompare(checkmat==1) = colormat(checkmat==1);
    
    % Write the images to files.
    try
        imwrite(im,strcat(OUT_DIR,FS,imname,OUT,DOT,OUT_EXT));
        imwrite(imcompare,strcat(OUT_DIR,FS,imname,COM,DOT,OUT_EXT));
    catch err
        warning(err.identifier,SKIPMSG,i,strcat(imname,imext),err.message);
        continue;
    end
    %imwrite(imcompare(601:(601+259),301:(301+346)),'G:\paper images\test image\last compare.png');
    
    % Store some stereology-related results.
    p = prod(size(im));
    aratio = sum(imfilled(:))/p;
    bratio = 2*sum(im(:))/p;
    
    % Write the main results for the current image.
    fprintf(fMainResults,MAIN_RESULTS_FORMAT_STRING,                        ...
        imname,                                                             ...
        aratio,                                                              ...
        bratio                                                              ...
    );
    
    
end

fclose(fMainResults);

end

