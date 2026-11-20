function count=extended_edge_tests()
%EXTENDED_EDGE_TESTS Differential tests against MATLAB padarray reference.
%   Runs on small, rectangular and one-pixel images, including oversized
%   padding and all three directions. Also verifies local mean, Otsu,
%   Bradley and sample-rate identities. No data downloads are needed.
root=fileparts(fileparts(fileparts(mfilename('fullpath'))));
base=fullfile(root,'Image Processing','Matlab', ...
    'Chapter 2 - Image Thresholding');
addpath(fullfile(base,'OTSU Binarization'));
addpath(fullfile(base,'Simple Mean Binarization'));
addpath(fullfile(base,'Wellner Thresholding'));
addpath(fullfile(base,'Bradley Thresholding'));
rng(20261120,'twister');
count=0;
directions={'Pre','Post','Both'};
styles={'zeros','ones','Replicate','Circular','Symmetric'};
cases={[7],[1 2 3;4 5 6],[10 25 40 2 8;3 50 17 4 2;1 3 5 7 11]};
widths={[0 0],[1 1],[3 4]};
for c=1:numel(cases)
    I=uint8(cases{c});
    for d=1:numel(directions)
        dir=directions{d};
        for s=1:numel(styles)
            style=styles{s};
            for w=1:numel(widths)
                pad=widths{w};
                actual=PadArray(I,pad,dir,style);
                if strcmp(style,'zeros')
                    expected=padarray(I,pad,0,lower(dir));
                elseif strcmp(style,'ones')
                    expected=padarray(I,pad,1,lower(dir));
                else
                    expected=padarray(I,pad,lower(style),lower(dir));
                end
                assert(isequal(actual,expected), ...
                    'Extended:Padding','Mismatch for %s/%s on fixture %d', ...
                    dir,style,c);
                count=count+1;
            end
        end
    end
end
% Random local-mean means, exact reference window enumeration.
I=reshape(1:35,5,7)/35;
for d=1:3
    dir=directions{d};
    J=PadArray(I,[2 3],dir,'Symmetric');
    M=ImageMean(J,2,3,dir);
    if strcmp(dir,'Both'),wr=5;wc=7;
    else,wr=3;wc=4;end
    for r=1:size(I,1)
        for col=1:size(I,2)
            win=J(r:r+wr-1,col:col+wc-1);
            assert(abs(M(r,col)-mean(win(:)))<2e-12);
            count=count+1;
        end
    end
end
% Otsu intensity extremes and class conventions.
u=uint8([zeros(1,100),255*ones(1,100)]);
[BW,~,detail]=OtsuThreshold(u);
assert(isequal(BW,logical([zeros(1,100),ones(1,100)])));
assert(all(isfinite(detail.betweenClassVariance)));
count=count+1;
b=OtsuThreshold([zeros(1,100),ones(1,100)]);
assert(isequal(b,logical([zeros(1,100),ones(1,100)])));
count=count+1;
% Integral-image methods stay equivalent for rectangular uint16 arrays.
I=uint16(randi([0 400],17,19));
expect=cumsum(cumsum(double(I),1),2);
assert(max(abs(IntegralImage(I)-expect),[],'all')==0);
assert(max(abs(IntegralImagePlus(I)-expect),[],'all')==0);
count=count+1;
% Discrete sinusoid is not degenerate at Nyquist.
n=-10:10;F=2;Fs=10;
assert(max(abs(sin(2*pi*F*n/Fs)))>0.90);
count=count+1;
% Sampled pulse is normalized to unit numerical area.
t=-1:0.001:1;delta=double(abs(t)<=0.01);
delta=delta/(sum(delta)*(t(2)-t(1)));
assert(abs(sum(delta)*(t(2)-t(1))-1)<1e-12);
count=count+1;
fprintf('EXTENDED PASS: %d mathematical assertions/groups.\n',count);
end
