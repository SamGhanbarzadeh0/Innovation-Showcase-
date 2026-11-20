%% Reproducible MATLAB regression checks for the Stage 03 fixes
% Run from any working directory:
%   run('tests/run_regression.m')
% Tested assumptions are explicit; this file does not require project images.
clear; clc;
root=fileparts(fileparts(mfilename('fullpath')));
base=fullfile(root,'Image Processing','Matlab','Chapter 2 - Image Thresholding');
addpath(fullfile(base,'OTSU Binarization'));
addpath(fullfile(base,'Simple Mean Binarization'));
addpath(fullfile(base,'Wellner Thresholding'));
addpath(fullfile(base,'Bradley Thresholding'));
testCount=0;

%% Histogram: integer extremes, normalized floating values, RGB
H=ComputeHistogram(uint8([0 255; 255 0]));
assert(numel(H)==256 && H(1)==2 && H(256)==2);
testCount=testCount+1;
H=ComputeHistogram(uint16([0 65535]));
assert(numel(H)==65536 && H(1)==1 && H(end)==1);
testCount=testCount+1;
H=ComputeHistogram([0 .5 1]);
assert(numel(H)==256 && H(1)==1 && H(129)==1 && H(end)==1);
testCount=testCount+1;
rgb=zeros(2,2,3,'uint8'); rgb(:,:,2)=255;
H=ComputeHistogram(rgb);
assert(iscell(H) && numel(H)==3 && H{2}(256)==4 && H{1}(1)==4);
testCount=testCount+1;

%% Otsu: known bimodal populations and degenerate images
[BW,threshold,detail]=OtsuThreshold(uint8([0 0 255 255]));
assert(isequal(BW,logical([0 0 1 1])) && threshold>=0 && threshold<255);
assert(all(isfinite(detail.betweenClassVariance)));
testCount=testCount+1;
[BW,~,detail]=OtsuThreshold(zeros(4,4,'uint8'));
assert(~any(BW(:)) && all(isfinite(detail.betweenClassVariance)));
testCount=testCount+1;
[BW,~,detail]=OtsuThreshold(ones(4,4,'uint8')*255);
assert(all(BW(:)) && all(isfinite(detail.betweenClassVariance)));
testCount=testCount+1;
[BW,~,~]=OtsuThreshold([0 0 1 1]);
assert(isequal(BW,logical([0 0 1 1])));
testCount=testCount+1;

%% PadArray: exact known pixels and extreme pad lengths
I=[1 2;3 4];
P=PadArray(I,[1 1],'Both','Replicate');
assert(isequal(P,[1 1 2 2;1 1 2 2;3 3 4 4;3 3 4 4]));
testCount=testCount+1;
P=PadArray(I,[1 1],'Both','Circular');
assert(isequal(P,[4 3 4 3;2 1 2 1;4 3 4 3;2 1 2 1]));
testCount=testCount+1;
P=PadArray(I,[1 1],'Both','Symmetric');
assert(isequal(P,[1 1 2 2;1 1 2 2;3 3 4 4;3 3 4 4]));
testCount=testCount+1;
P=PadArray(uint8(I),[3 4],'Both','Circular');
assert(isequal(size(P),[8 10]) && isa(P,'uint8'));
testCount=testCount+1;
P=PadArray(I,[2 3],'Both','ones');
assert(all(all(P(1:2,:)==1)) && isequal(P(3:4,4:5),I));
testCount=testCount+1;

%% Mean maps: compare summed-area implementation to direct enumeration
directions={'Pre','Post','Both'};
padding={'Replicate','Circular','Symmetric'};
I=[0 2 4;1 3 5;2 4 6];
for d=1:numel(directions)
    for t=1:numel(padding)
        dir=directions{d};
        J=PadArray(I,[1 1],dir,padding{t});
        M=ImageMean(J,1,1,dir);
        if strcmp(dir,'Both'), win=3; else, win=2; end
        ref=zeros(size(I));
        for i=1:size(I,1)
            for j=1:size(I,2)
                patch=J(i:i+win-1,j:j+win-1);
                ref(i,j)=mean(patch(:));
            end
        end
        assert(isequal(size(M),size(I)) && max(abs(M(:)-ref(:)))<1e-11);
        testCount=testCount+1;
    end
end

%% Integral image identities
I=[3 1 4 1;5 9 2 6;5 3 5 8];
expected=cumsum(cumsum(double(I),1),2);
assert(isequal(IntegralImage(I),expected));
testCount=testCount+1;
assert(isequal(IntegralImagePlus(I),expected));
testCount=testCount+1;

%% Bradley: constant images and direct neighborhood comparison
I=reshape(mod(0:63,13),8,8)/12;
dirs={'Pr','Po','Bo'}; types={'Rp','Sm','Cr'};
styles={'Replicate','Symmetric','Circular'};
for d=1:3
    for t=1:3
        opts=struct('Direction',dirs{d},'PadValue',types{t});
        BW=BradleyImage(I,opts);
        assert(isequal(size(BW),size(I)));
        dir=directions{d}; style=styles{t};
        % For an 8x8 input, neighborhood radius is exactly one pixel.
        J=PadArray(I,[1 1],dir,style);
        if d==3, win=3; else, win=2; end
        ref=false(8,8);
        for i=1:8
            for j=1:8
                block=J(i:i+win-1,j:j+win-1);
                ref(i,j)=I(i,j)>0.8*mean(block(:));
            end
        end
        assert(isequal(BW,ref));
        testCount=testCount+1;
        onesBW=BradleyImage(ones(8),opts);
        assert(all(onesBW(:)));
        testCount=testCount+1;
    end
end

%% Wellner: all four scan directions, three border modes
methods={'LR','RL','UD','DU'};
for m=1:4
    for t=1:3
        opts=struct('Method',methods{m},'PadValue',types{t});
        assert(all(WellnerImage(ones(8),opts),'all'));
        assert(~any(WellnerImage(zeros(8),opts),'all'));
        testCount=testCount+1;
    end
end
% Explicit RL count counterexample: old implementation turns ones black.
assert(all(WellnerImage(ones(8),struct('Method','RL','PadValue','Rp')),'all'));
testCount=testCount+1;
% Very small images must not cause division by zero.
assert(isequal(size(WellnerImage(ones(2,1),...
    struct('Method','DU','PadValue','Cr'))),[2 1]));
testCount=testCount+1;

%% Directional Wellner: numerical comparison to explicit sample loops
grad=reshape(mod(0:71,19),8,9)/18;
for m=1:4
    for t=1:3
        method=methods{m};
        style=styles{t};
        opts=struct('Method',method,'PadValue',types{t});
        got=WellnerImage(grad,opts);
        if any(strcmp(method,{'LR','RL'}))
            S=max(1,round(size(grad,2)/8)); pad=[0 S];
        else
            S=max(1,round(size(grad,1)/8)); pad=[S 0];
        end
        if any(strcmp(method,{'LR','UD'}))
            padded=PadArray(grad,pad,'Pre',style);
        else
            padded=PadArray(grad,pad,'Post',style);
        end
        expected=false(size(grad));
        for i=1:size(grad,1)
            for j=1:size(grad,2)
                neighborSum=0;
                for k=1:S
                    switch method
                        case 'LR', neighborSum=neighborSum+padded(i,S+j-k);
                        case 'RL', neighborSum=neighborSum+padded(i,j+k);
                        case 'UD', neighborSum=neighborSum+padded(S+i-k,j);
                        case 'DU', neighborSum=neighborSum+padded(i+k,j);
                    end
                end
                expected(i,j)=grad(i,j)>0.85*neighborSum/S;
            end
        end
        assert(isequal(got,expected));
        testCount=testCount+1;
    end
end

%% Floating Otsu mask must use the quantized histogram levels
floatImage=[0 0.499 0.502 1];
[mask,~,info]=OtsuThreshold(floatImage);
quantized=floor(floatImage*255+0.5);
assert(isequal(mask,quantized>info.thresholdLevel));
testCount=testCount+1;

%% Local mean: explicitly tested margin for near-equality stability
I=0.8*ones(16);
[BW,M]=LocalMeanThreshold(I,[3 3],'Both','Replicate',0.12);
assert(all(BW(:)) && max(abs(M(:)-0.8))<1e-10);
testCount=testCount+1;
[X,Y]=meshgrid(1:16,1:16);
I=0.60+0.001*X+0.001*Y;
BW=LocalMeanThreshold(I,[3 3],'Both','Replicate',0.12);
assert(all(BW(:))); % A smooth background should remain all background.
testCount=testCount+1;
I=0.8*ones(16);
I(:,6:7)=0.4;
BW=LocalMeanThreshold(I,[3 3],'Both','Replicate',0.12);
assert(~any(BW(:,6:7),'all') && all(BW(:,1:2),'all'));
testCount=testCount+1;

fprintf('PASS: %d MATLAB assertions/groups (all tests reached).\n',testCount);
