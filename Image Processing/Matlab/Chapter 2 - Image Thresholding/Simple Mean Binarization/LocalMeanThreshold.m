function [BW, localMean] = LocalMeanThreshold(I, radius, direction, paddingType, sensitivity)
%LOCALMEANTHRESHOLD Adaptive local-mean binarization.
%   BW = I >= (1-sensitivity)*localMean, where true denotes bright
%   background and false denotes dark foreground. Use ~BW to obtain
%   a mask of dark objects. Defaults: sensitivity = 0.12.
%
%   The margin avoids near-equality noise when a smooth image has
%   intensities nearly identical to its local average.
validateattributes(I,{'numeric','logical'}, ...
    {'2d','nonempty','real','finite'},mfilename,'I');
validateattributes(radius,{'numeric'}, ...
    {'vector','numel',2,'nonnegative','integer','finite'},mfilename,'radius');
if nargin<5 || isempty(sensitivity), sensitivity=0.12; end
validateattributes(sensitivity,{'numeric'}, ...
    {'scalar','>=',0,'<',1,'finite'},mfilename,'sensitivity');
direction=validatestring(direction,{'Pre','Post','Both'},mfilename,'direction');
paddingType=validatestring(paddingType, ...
    {'zeros','ones','Replicate','Circular','Symmetric'},mfilename,'paddingType');
radius=double(radius(:)');
J=PadArray(I,radius,direction,paddingType);
localMean=ImageMean(J,radius(1),radius(2),direction);
assert(isequal(size(localMean),size(I)), ...
    'LocalMeanThreshold:IncorrectShape','The returned mean map must match the input.');
BW=double(I)>=(1-double(sensitivity))*localMean;
end
