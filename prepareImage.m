function varargout = prepareImage(im,imtype)
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
---------------------------------------------------------------------------
The function returns 1 variable:
    im          - The segmented image.
---------------------------------------------------------------------------
%}

% Static Variables.
%--------------------------------------------------------------------------
if imtype==1
	BW_AREA_REM = 5;
	BW_AREA_REM_DELTA = 25;
	CL_STREL_RAD = 2;
	CL_STREL_RAD_DELTA = 1;
elseif imtype==2
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
im = medfilt2(im,[5 5]);
%imwrite(im(601:(601+259),301:(301+346)),'G:\paper images\test image\1 medfilt.png');

% Send top and bottom range pixels to intermediate values.
% High values destructive for both LF and DF.
% Low values only destructive for LF.
if imtype==2
	im(im<(256*0.5))=0.3*uint8(mean(im(:)));%0.3
	im(im>(256*0.8))=0.3*uint8(mean(im(:)));
else
	im(im>(256*0.8))=uint8(128);
end
%imwrite(im(601:(601+259),301:(301+346)),'G:\paper images\test image\2 clip.png');

% Threshold the image using Otsu by windows.
im = thresholdLocally(im, round(size(im)./10));

% If the image is light-field, flip all bits.
if imtype==2; im=~im; end
%imwrite(im(601:(601+259),301:(301+346)),'G:\paper images\test image\3 thresh.png');
k=4;
for i=1:3
    rad = CL_STREL_RAD + ( (i-1) * CL_STREL_RAD_DELTA );
    se = strel('disk',rad,0);
    im = imclose(im,se);
    %imwrite(im(601:(601+259),301:(301+346)),strcat('G:\paper images\test image\',num2str(k),' close',num2str(i),'.png'));
    k=k+1;
    im = ~im;
    rem = BW_AREA_REM + ( (i-1)^2 * BW_AREA_REM_DELTA );
    im = bwareaopen(im,rem);
	im = ~im;
    %imwrite(im(601:(601+259),301:(301+346)),strcat('G:\paper images\test image\',num2str(k),' open',num2str(i),'.png'));
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
    %imwrite(im(601:(601+259),301:(301+346)),strcat('G:\paper images\test image\',num2str(k),' circles',num2str(i),'.png'));
    k=k+1;
    fprintf(1,'.');
end
fprintf(1,'\n');
varargout{2} = logical(im);

% Remove all but boundary pixels.
im = bwmorph(im,'remove');
%imwrite(im(601:(601+259),301:(301+346)),strcat('G:\paper images\test image\',num2str(k),' remove.png'));
k=k+1;
% Remove the outer edge of pixels.
if size(im)>2
    im=im(2:end-1,2:end-1);
    varargout{2} = varargout{2}(2:end-1,2:end-1);
else im = [];
end

varargout{1} = im;
end