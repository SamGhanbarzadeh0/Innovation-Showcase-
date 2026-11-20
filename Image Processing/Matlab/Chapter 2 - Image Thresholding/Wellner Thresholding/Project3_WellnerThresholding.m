%% Wellner directional thresholding
% Each direction compares the current pixel with preceding or following
% samples, using the selected boundary rule.
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
methods={'LR','RL','UD','DU'};
padTypes={'Rp','Sm','Cr'};
figure('Name','Wellner adaptive thresholding');
for m=1:numel(methods)
    for t=1:numel(padTypes)
        opts=struct('Method',methods{m},'PadValue',padTypes{t});
        BW=WellnerImage(I,opts);
        subplot(4,3,(m-1)*3+t);
        imshowpair(I,BW,'montage');
        title(sprintf('%s / %s',methods{m},padTypes{t}));
    end
end
sgtitle('Directional adaptive thresholding (Wellner)');
