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
        % Centered dark-document preset was calibrated on illustrative
        % synthetic fixtures. The underlying function default remains 0.20.
        if strcmp(directions{d},'Bo')
            opts.Sensitivity=0.08;
        end
        BW=BradleyImage(I,opts);
        subplot(3,3,(d-1)*3+t);
        imshowpair(I,BW,'montage');
        title(sprintf('%s / %s (T=%.2f)',directionNames{d}, ...
            padNames{t},sensitivityLabel(opts)));
    end
end
sgtitle('Bradley local-mean thresholding: centered document preset T=0.08');

function t=sensitivityLabel(opts)
if isfield(opts,'Sensitivity'),t=opts.Sensitivity;
else,t=0.20;end
end
