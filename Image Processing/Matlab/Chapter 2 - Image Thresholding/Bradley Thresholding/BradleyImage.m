function BW = BradleyImage(I, opts)
%BRADLEYIMAGE Adaptive thresholding against a padded local mean.
%   Pre uses preceding rows/columns, Post following rows/columns,
%   Both a centered window. Each output pixel is assigned.
%   The padded *image* (not its integral image) is summed locally.
validateattributes(I,{'numeric','logical'},{'2d','nonempty','real'},mfilename,'I');
if nargin<2 || ~isstruct(opts) || ~isfield(opts,'Direction') || ~isfield(opts,'PadValue')
    error('BradleyImage:Options','opts.Direction and opts.PadValue are required.');
end
direction=validatestring(opts.Direction,{'Bo','Pr','Po','Both','Pre','Post'});
type=validatestring(opts.PadValue,{'Rp','Sm','Cr','Replicate','Symmetric','Circular'});
switch direction
    case 'Bo', direction='Both';
    case 'Pr', direction='Pre';
    case 'Po', direction='Post';
end
switch type
    case 'Rp', type='Replicate';
    case 'Sm', type='Symmetric';
    case 'Cr', type='Circular';
end
[r,c]=size(I);
S=max([1 1],round([r c]/8));
radius=max([1 1],round(S/2));
T=0.20;
if isfield(opts,'Sensitivity')
    validateattributes(opts.Sensitivity,{'numeric'},{'scalar','finite','>=',0,'<',1});
    T=double(opts.Sensitivity);
end
if strcmp(direction,'Both')
    before=radius; after=radius;
elseif strcmp(direction,'Pre')
    before=radius; after=[0 0];
else
    before=[0 0]; after=radius;
end
J=double(PadArray(I,radius,direction,type));
rows=before(1)+after(1)+1;
cols=before(2)+after(2)+1;
C=zeros(size(J,1)+1,size(J,2)+1);
C(2:end,2:end)=cumsum(cumsum(J,1),2);
% A single vectorized rectangle-sum identity for all pixels.
A=C(rows+1:rows+r,cols+1:cols+c);
B=C(1:r,cols+1:cols+c);
D=C(rows+1:rows+r,1:c);
E=C(1:r,1:c);
localMean=(A-B-D+E)/(rows*cols);
BW=double(I)>(1-T)*localMean;
end
