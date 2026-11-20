function J = IntegralImagePlus(I)
%INTEGRALIMAGEPLUS Equivalent row-first summed-area table.
validateattributes(I,{'numeric','logical'},{'2d','nonempty','real'},mfilename,'I');
J=cumsum(cumsum(double(I),2),1);
end
