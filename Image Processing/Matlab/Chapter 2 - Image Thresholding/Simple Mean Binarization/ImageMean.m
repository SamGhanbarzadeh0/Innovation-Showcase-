function Mu = ImageMean(I, Nr, Nc, Dir)
%IMAGEMEAN Local arithmetic mean using a summed-area table.
%   Input I is already padded according to Dir (Pre, Post, Both).
%   The returned mean map has the unpadded image dimensions.
validateattributes(I, {'numeric','logical'}, {'2d','nonempty','real'}, mfilename, 'I');
validateattributes(Nr, {'numeric'}, {'scalar','integer','nonnegative','finite'}, mfilename, 'Nr');
validateattributes(Nc, {'numeric'}, {'scalar','integer','nonnegative','finite'}, mfilename, 'Nc');
Dir = validatestring(Dir,{'Pre','Post','Both'},mfilename,'Dir');
Nr = double(Nr); Nc = double(Nc);
if strcmp(Dir,'Both')
    winRows = 2*Nr+1; winCols = 2*Nc+1;
else
    winRows = Nr+1; winCols = Nc+1;
end
[r,c] = size(I);
if r < winRows || c < winCols
    error('ImageMean:Dimensions','Padded input is smaller than the requested window.');
end
J = zeros(r+1,c+1);
J(2:end,2:end) = cumsum(cumsum(double(I),1),2);
localSums = J(winRows+1:end,winCols+1:end) - J(1:end-winRows,winCols+1:end) ...
    - J(winRows+1:end,1:end-winCols) + J(1:end-winRows,1:end-winCols);
Mu = localSums / (winRows*winCols);
end
