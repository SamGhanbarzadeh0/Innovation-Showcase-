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
H=ComputeHistogram(I);
p=double(H)/sum(H);
L=numel(H);
levels=(0:L-1)';
omega=cumsum(p(:));
mu=cumsum(levels.*p(:));
totalMean=mu(end);
between=zeros(L,1);
valid=(omega>0 & omega<1);
between(valid)=(totalMean*omega(valid)-mu(valid)).^2 ./ ...
    (omega(valid).*(1-omega(valid)));
[peak,index]=max(between);
thresholdIndex=index-1; % Class 0 includes level <= thresholdIndex.
if isa(I,'single') || isa(I,'double')
    threshold=thresholdIndex/255;
else
    threshold=thresholdIndex;
end
BW=double(I)>threshold; % Class 1 is strictly above the threshold.

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
