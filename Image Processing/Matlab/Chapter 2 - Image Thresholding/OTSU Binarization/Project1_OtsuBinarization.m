%% Otsu thresholding: probability distribution and between-class variance
% Run this script from its folder. A valid image can be selected below.
clear; close all; clc;

images = {'coins.png','cameraman.tif','rice.png','saturn.png', ...
    'peppers.png','printedtext.png'};
fprintf('Select an image:\n');
for k=1:numel(images)
    fprintf('%d) %s\n',k,images{k});
end
choice = input('Image number: ');
if ~isnumeric(choice) || ~isscalar(choice) || ~isfinite(choice) || ...
        choice ~= fix(choice) || choice < 1 || choice > numel(images)
    error('Select a whole number between 1 and %d.',numel(images));
end
I=imread(images{choice});
if size(I,3)==3
    I=rgb2gray(I);
end
[BW,threshold,result]=OtsuThreshold(I);
H=result.histogram;
p=result.probability;
levels=result.levels;
omega=result.cumulativeProbability;
between=result.betweenClassVariance;
peak=result.peakVariance;
thresholdIndex=result.thresholdLevel;
L=numel(levels);

figure('Name','Otsu thresholding');
subplot(2,3,1); imshow(I); title('Grayscale image');
subplot(2,3,2); plot(levels,H); title('Histogram');
xlabel('Intensity level'); ylabel('Count');
subplot(2,3,3); plot(levels,p); title('Probability mass');
xlabel('Intensity level');
subplot(2,3,4); plot(levels,omega); title('Cumulative probability');
xlabel('Intensity level');
subplot(2,3,5); plot(levels,between); hold on;
plot(thresholdIndex,peak,'ro'); title('Between-class variance');
xlabel('Intensity level'); ylabel('Variance');
subplot(2,3,6); imshow(BW); title('Binary image');
fprintf('Otsu level: %d / %d, threshold: %.8g, max variance: %.8g\n', ...
    thresholdIndex,L-1,threshold,peak);
