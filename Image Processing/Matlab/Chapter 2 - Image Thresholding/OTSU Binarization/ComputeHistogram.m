function HIST = ComputeHistogram(I)
%COMPUTEHISTOGRAM Exact grayscale counts for uint8/uint16, or 256
%   quantization levels for normalized floating-point images.
%   RGB input returns a cell array with one histogram per channel.
validateattributes(I,{'numeric','logical'},{'nonempty','real','nonsparse'},mfilename,'I');
if ndims(I) > 3 || (ndims(I)==3 && size(I,3)~=3)
    error('ComputeHistogram:Dimensions','Expected grayscale or three-channel RGB image.');
end
if ndims(I) == 2
    HIST = oneHistogram(I);
else
    HIST = cell(1,3);
    for ch=1:3
        HIST{ch}=oneHistogram(I(:,:,ch));
    end
end
end

function H = oneHistogram(A)
if islogical(A)
    levels = 2;
    idx = double(A(:))+1;
elseif isa(A,'uint8')
    levels = 256;
    idx = double(A(:))+1;
elseif isa(A,'uint16')
    levels = 65536;
    idx = double(A(:))+1;
elseif isa(A,'double') || isa(A,'single')
    if any(~isfinite(A(:))) || any(A(:)<0) || any(A(:)>1)
        error('ComputeHistogram:Range','Floating-point images must be finite and in [0,1].');
    end
    levels = 256;
    idx = floor(double(A(:))*255+0.5)+1;
else
    error('ComputeHistogram:Class','Use logical, uint8, uint16, single or double images.');
end
H = accumarray(idx,1,[levels,1])';
end
