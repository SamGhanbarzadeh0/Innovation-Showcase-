function J = IntegralImage(I)
%INTEGRALIMAGE Summed-area table of a 2-D image (without zero border).
validateattributes(I,{'numeric','logical'},{'2d','nonempty','real'},mfilename,'I');
J=cumsum(cumsum(double(I),1),2);
end
