function [BW, threshold, details] = OtsuThreshold(I)
%OTSUTHRESHOLD Two-class threshold maximizing between-class variance.
%   BW identifies intensities strictly above the selected threshold.
%   For floating-point images, inputs must lie in [0,1].
validateattributes(I,{'numeric','logical'},{'2d','nonempty','real'},mfilename,'I');
H=ComputeHistogram(I);
prob=double(H(:))/sum(H);
L=numel(prob);
levels=(0:L-1)';
omega=cumsum(prob);
mu=cumsum(levels.*prob);
muTotal=mu(end);
variance=zeros(L,1);
valid=omega>0 & omega<1;
variance(valid)=(muTotal*omega(valid)-mu(valid)).^2 ./ ...
    (omega(valid).*(1-omega(valid)));
[peak,idx]=max(variance);
thresholdLevel=idx-1; % Lowest-index tie rule
if isa(I,'single') || isa(I,'double')
    % The histogram uses nearest-level quantization; classify using
    % precisely the same bins to avoid boundary inconsistencies.
    threshold=(thresholdLevel+0.5)/255;
    BW=floor(double(I)*255+0.5)>thresholdLevel;
else
    threshold=thresholdLevel;
    BW=double(I)>thresholdLevel;
end
details=struct('histogram',H,'probability',prob, ...
    'levels',levels,'cumulativeProbability',omega, ...
    'betweenClassVariance',variance,'peakVariance',peak, ...
    'thresholdLevel',thresholdLevel);
end
