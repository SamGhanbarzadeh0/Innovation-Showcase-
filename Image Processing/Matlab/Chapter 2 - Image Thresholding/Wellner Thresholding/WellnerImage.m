function BW = WellnerImage(I, opts)
%WELLNERIMAGE Directional adaptive threshold using S neighboring samples.
%   LR: compare with S pixels to the left; RL: S to the right.
%   UD: S pixels above; DU: S below. The current pixel is excluded
%   from the local reference. Boundary extension uses PadArray.
validateattributes(I,{'numeric','logical'},{'2d','nonempty','real'},mfilename,'I');
if nargin < 2 || ~isstruct(opts) || ~isfield(opts,'Method') || ~isfield(opts,'PadValue')
    error('WellnerImage:Options','opts.Method and opts.PadValue are required.');
end
direction = validatestring(opts.Method,{'LR','RL','UD','DU'});
type = validatestring(opts.PadValue,{'Rp','Sm','Cr','Replicate','Symmetric','Circular'});
switch type
    case 'Rp', type='Replicate';
    case 'Sm', type='Symmetric';
    case 'Cr', type='Circular';
end
[r,c] = size(I);
T = 0.15;
if isfield(opts,'Sensitivity')
    validateattributes(opts.Sensitivity,{'numeric'},{'scalar','finite','>=',0,'<',1});
    T = double(opts.Sensitivity);
end
if any(strcmp(direction,{'LR','RL'}))
    S = max(1,round(c/8)); pad = [0 S];
else
    S = max(1,round(r/8)); pad = [S 0];
end
if any(strcmp(direction,{'LR','UD'})), side='Pre'; else, side='Post'; end
J = double(PadArray(I,pad,side,type));
ref = zeros(r,c);
switch direction
    case 'LR'
        for k=1:S
            ref=ref+J(:,S+1-k:S+c-k);
        end
    case 'RL'
        for k=1:S
            ref=ref+J(:,1+k:c+k);
        end
    case 'UD'
        for k=1:S
            ref=ref+J(S+1-k:S+r-k,:);
        end
    case 'DU'
        for k=1:S
            ref=ref+J(1+k:r+k,:);
        end
end
BW = double(I) > (1-T)*(ref/S);
end
