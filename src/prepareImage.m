function varargout = prepareImage(im, imtype, out_folder, out_window)
% Description
%{
---------------------------------------------------------------------------
The purpose of this function is to turn an image of an Al-Si system alloy's
dendrites into the boundary of those dendrites as a single-pixel-wide curve
in a logical image. The fractal dimension of this boundary can then be
computed.
---------------------------------------------------------------------------
%}

% Variables
%{
---------------------------------------------------------------------------
This function takes in 1 variable:
    im          - The image we wish to segment.
	imtype      - The type of image, 1 for DF, 2 for LF.
    out_folder  - Output folder for intermediate images to be written (opt).
    out_window  - [x, y, w, h] of image to write (opt).
---------------------------------------------------------------------------
The function returns 1 variable:
    im          - The segmented image.
---------------------------------------------------------------------------
%}

do_write = true;
if nargin < 3
    do_write = false;
    out_folder = [];
end
if nargin < 4
    out_window = [1 1 size(im, 1:2)];
end

assert(isfolder(out_folder));

% Static Variables.
%--------------------------------------------------------------------------
DARK_FIELD = 1;
BRIGHT_FIELD = 2;
if imtype==DARK_FIELD
	BW_AREA_REM = 5;
	BW_AREA_REM_DELTA = 25;
	CL_STREL_RAD = 2;
	CL_STREL_RAD_DELTA = 1;
elseif imtype==BRIGHT_FIELD
	BW_AREA_REM = 50;
	BW_AREA_REM_DELTA = 25;
	CL_STREL_RAD = 1;
	CL_STREL_RAD_DELTA = 1;
end
%--------------------------------------------------------------------------
% Convert the image from RGB to grayscale by retaining only HSL lightness.
if size(im,3)==3
    im = rgb2gray(im);
end

% Apply a median noise filter;
im_orig = im;
if do_write
    write(im_orig, out_folder, "0_orig", out_window);
end
im = medfilt2(im,[5 5]);
if do_write
    write(im, out_folder, "1_medfilt", out_window);
end


% Send top and bottom range pixels to intermediate values.
% High values destructive for both LF and DF.
% Low values only destructive for LF.
if imtype==BRIGHT_FIELD
    MID_VAL = uint8(0.3 * mean(im(:)));
	im(im<(256*0.5))=MID_VAL;
	im(im>(256*0.8))=MID_VAL;
else
    MID_VAL = uint8(128);
	im(im>(256*0.8))=MID_VAL;
end
if do_write
    write(im, out_folder, "2_clipping", out_window);
end

% Threshold the image using Otsu by windows.
im = thresholdLocally(im, round(size(im)./10));


% If the image is light-field, flip all bits.
if imtype==BRIGHT_FIELD
    im=~im;
end
if do_write
    write(im, out_folder, "3_adaptive_thresholding", out_window);
end
k=4;
for i=1:3
    rad = CL_STREL_RAD + ( (i-1) * CL_STREL_RAD_DELTA );
    se = strel('disk',rad,0);
    im = imclose(im,se);
    if do_write
        name = sprintf("%d_morph_close", k);
        write(im, out_folder, name, out_window);
    end
    k=k+1;
    im = ~im;
    rem = BW_AREA_REM + ( (i-1)^2 * BW_AREA_REM_DELTA );
    im = bwareaopen(im,rem);
	im = ~im;
    if do_write
        name = sprintf("%d_area_open_1", k);
        write(im, out_folder, name, out_window);
    end
    k=k+1;
	if i==1
		rem = BW_AREA_REM + ( (i-1)^2 * BW_AREA_REM_DELTA );
		im = bwareaopen(im,rem);
	else
		cc = bwconncomp(im,8);
		pp = regionprops(cc,'Perimeter');
		aa = regionprops(cc,'Area');
		im = zeros(size(im));
		for j=1:cc.NumObjects
			eqvrad = (pp(j).Perimeter)/(2*pi);
			if eqvrad>5
				im(cc.PixelIdxList{j}) = 1;
			end
			eqvarea = pi*(eqvrad)^2;
			if eqvarea>(1.25*aa(j).Area)
				im(cc.PixelIdxList{j}) = 1;
			end
		end
    end
    if do_write
        name = sprintf("%d_area_open_2", k);
        write(im, out_folder, name, out_window);
    end
    k=k+1;
    fprintf(1,'.');
end
fprintf(1,'\n');
varargout{2} = logical(im);

% Remove all but boundary pixels.
im = bwmorph(im,'remove');
if do_write
    name = sprintf("%d_remove", k);
    write(im, out_folder, name, out_window);
end
k=k+1;
if do_write
    name = sprintf("%d_overlay", k);
    im_out = imoverlay(im_orig, im, [1.0 1.0 1.0]);
    write(im_out, out_folder, name, out_window);
end
% Remove the outer edge of pixels.
if all(size(im) > 2)
    im=im(2:end-1,2:end-1);
    varargout{2} = varargout{2}(2:end-1,2:end-1);
else
    im = [];
end

varargout{1} = im;
end


function write(im, out_folder, name, window)

out_name = fullfile(out_folder, name + ".png");
y = window(1) : window(1) + window(3) - 1;
x = window(2) : window(2) + window(4) - 1;
out_im = im(x, y);
imwrite(out_im, out_name);

end