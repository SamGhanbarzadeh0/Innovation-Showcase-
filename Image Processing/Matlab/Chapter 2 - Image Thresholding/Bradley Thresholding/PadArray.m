function PadIm = PadArray(I, Size, Dir, Type)
%PADARRAY Pad a 2-D image (or RGB image), preserving its numeric class.
%   Size = [numberOfRows numberOfColumns]. Dir: Pre, Post, Both.
%   Type: zeros, ones, Replicate, Circular, Symmetric.
%   Symmetric repeats boundary samples (MATLAB padarray convention).
validateattributes(I, {'numeric','logical'}, {'nonempty','nonsparse'}, mfilename, 'I');
if ndims(I) > 3 || (ndims(I) == 3 && size(I,3) ~= 3)
    error('PadArray:Dimension', 'Input must be a 2-D image or 3-channel RGB image.');
end
validateattributes(Size, {'numeric'}, {'vector','numel',2,'integer','nonnegative','finite'}, mfilename, 'Size');
Size = double(Size(:)');
Dir = validatestring(Dir, {'Pre','Post','Both'}, mfilename, 'Dir');
Type = validatestring(Type, {'zeros','ones','Replicate','Circular','Symmetric'}, mfilename, 'Type');

switch Dir
    case 'Pre'
        before = Size; after = [0 0];
    case 'Post'
        before = [0 0]; after = Size;
    case 'Both'
        before = Size; after = Size;
end
[nr,nc,channels] = size(I);
outRows = nr + before(1) + after(1);
outCols = nc + before(2) + after(2);
if strcmp(Type,'zeros') || strcmp(Type,'ones')
    PadIm = zeros(outRows,outCols,channels,'like',I);
    if strcmp(Type,'ones')
        PadIm(:) = 1;
    end
    PadIm(before(1)+(1:nr),before(2)+(1:nc),:) = I;
    return
end
rowPositions = (1-before(1)):(nr+after(1));
colPositions = (1-before(2)):(nc+after(2));
switch Type
    case 'Replicate'
        rowIdx = min(max(rowPositions,1),nr);
        colIdx = min(max(colPositions,1),nc);
    case 'Circular'
        rowIdx = mod(rowPositions-1,nr)+1;
        colIdx = mod(colPositions-1,nc)+1;
    case 'Symmetric'
        rowIdx = symmetricIndex(rowPositions,nr);
        colIdx = symmetricIndex(colPositions,nc);
end
PadIm = I(rowIdx,colIdx,:);
end

function idx = symmetricIndex(positions,n)
% Reflect indices including the edge pixels: 1,1,2,...,n,n,n-1,...
r = mod(positions-1,2*n);
idx = min(r+1,2*n-r);
end
