%% Mean-based adaptive thresholding with three padding directions
% Compare padding rules using one consistent neighborhood radius.
clear; close all; clc;
images={'coins.png','cameraman.tif','rice.png','saturn.png', ...
    'peppers.png','printedtext.png'};
for k=1:numel(images), fprintf('%d) %s\n',k,images{k}); end
choice=input('Image number: ');
if ~isnumeric(choice) || ~isscalar(choice) || ~isfinite(choice) || ...
        choice~=fix(choice) || choice<1 || choice>numel(images)
    error('Select a valid image number.');
end
I=imread(images{choice});
if size(I,3)==3, I=rgb2gray(I); end
I=im2double(I);
radius=max([1 1],round(size(I)/16));
directions={'Pre','Post','Both'};
padding={'Replicate','Symmetric','Circular'};
figure('Name','Local mean thresholding');
for d=1:numel(directions)
    for t=1:numel(padding)
        % Fixed, documented contrast margin prevents equality speckle.
        [binary,localMean]=LocalMeanThreshold(I,radius, ...
            directions{d},padding{t},0.12);
        assert(isequal(size(localMean),size(I)),'Incorrect local mean dimensions.');
        subplot(3,3,(d-1)*3+t);
        imshow(binary);
        title(sprintf('%s / %s',directions{d},padding{t}));
    end
end
sgtitle('Local mean binarization (12% contrast margin)');
