%% Bradley-style adaptive thresholding
% Compare local-mean thresholds across padding directions and types.
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
directions={'Pr','Po','Bo'};
directionNames={'Pre','Post','Both'};
padTypes={'Rp','Sm','Cr'};
padNames={'Replicate','Symmetric','Circular'};
figure('Name','Bradley adaptive thresholding');
for d=1:numel(directions)
    for t=1:numel(padTypes)
        opts=struct('Direction',directions{d},'PadValue',padTypes{t});
        BW=BradleyImage(I,opts);
        subplot(3,3,(d-1)*3+t);
        imshowpair(I,BW,'montage');
        title(sprintf('%s / %s',directionNames{d},padNames{t}));
    end
end
sgtitle('Bradley local-mean thresholding');
