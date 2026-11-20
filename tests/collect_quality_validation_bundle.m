function archivePath = collect_quality_validation_bundle()
%COLLECT_QUALITY_VALIDATION_BUNDLE  Stage 03B benchmark with known masks.
%   Dark objects are FOREGROUND (true in the ground-truth mask).
%   Otsu, Wellner, Bradley and local-mean return bright-background masks;
%   for evaluation, predictions are consistently inverted.
%
%   Three fixed synthetic conditions, no tuning on their outcomes:
%     uniform illumination, spatially varying illumination, lower contrast.
%   Every condition uses an independently reproducible Gaussian noise seed.
%   Figures display dark objects on white backgrounds, consistent with
%   document-binarization convention.
%
%   This benchmark is a controlled functional evaluation, NOT evidence of
%   clinical performance or generalization to arbitrary photographs.
root=fileparts(fileparts(mfilename('fullpath')));
base=fullfile(root,'Image Processing','Matlab','Chapter 2 - Image Thresholding');
addpath(fullfile(base,'OTSU Binarization'));
addpath(fullfile(base,'Simple Mean Binarization'));
addpath(fullfile(base,'Wellner Thresholding'));
addpath(fullfile(base,'Bradley Thresholding'));

stamp=datestr(now,'yyyymmdd_HHMMSS');
resultsRoot=fullfile(root,'validation_results');
out=fullfile(resultsRoot,['quality_' stamp]);
if ~exist(out,'dir'),mkdir(out);end

writeText(fullfile(out,'environment.txt'),sprintf( ...
    'MATLAB: %s\nPlatform: %s\nSource: fix/stage-03b-quantitative-qc-2026-11-20\nSeed base: 20261120\n', ...
    version,computer));
algNames={'Otsu','LocalMean_Both_T012','Wellner_LR','Wellner_RL', ...
    'Wellner_UD','Wellner_DU','Bradley_Pre','Bradley_Post','Bradley_Both'};
cases={'uniform','uneven','low_contrast'};
rows={};
inputs=cell(numel(cases),1);
truth=cell(numel(cases),1);
outputs=cell(numel(cases),1);
messages={};
regressionOK=false;
try
    console=evalc('runPreviousRegression(root);');
    regressionOK=contains(console,'PASS:');
    writeText(fullfile(out,'regression_console.txt'),console);
catch ME
    writeText(fullfile(out,'regression_console.txt'), ...
        getReport(ME,'extended','hyperlinks','off'));
    messages{end+1}=['Regression check failed: ' ME.message]; %#ok<AGROW>
end

for caseIndex=1:numel(cases)
    try
        [I,GT]=syntheticDocument(caseIndex);
        predicted=runMethods(I);
        assert(numel(predicted)==numel(algNames));
        inputs{caseIndex}=I;
        truth{caseIndex}=GT;
        outputs{caseIndex}=predicted;
        for methodIndex=1:numel(algNames)
            P=logical(predicted{methodIndex});
            assert(isequal(size(P),size(GT)));
            tp=sum(P(:)&GT(:));
            fp=sum(P(:)&~GT(:));
            tn=sum(~P(:)&~GT(:));
            fn=sum(~P(:)&GT(:));
            dice=2*tp/max(1,2*tp+fp+fn);
            iou=tp/max(1,tp+fp+fn);
            sens=tp/max(1,tp+fn);
            spec=tn/max(1,tn+fp);
            balanced=(sens+spec)/2;
            rows(end+1,:)={cases{caseIndex},algNames{methodIndex}, ... %#ok<AGROW>
                tp,fp,tn,fn,dice,iou,sens,spec,balanced,mean(P(:))};
        end
        imwrite(I,fullfile(out,['input_' cases{caseIndex} '.png']));
        imwrite(~GT,fullfile(out,['truth_' cases{caseIndex} '.png']));
        renderComparison(I,GT,predicted,algNames, ...
            fullfile(out,['comparison_' cases{caseIndex} '.png']), ...
            cases{caseIndex});
    catch ME
        messages{end+1}=sprintf('Case %s failed: %s', ... %#ok<AGROW>
            cases{caseIndex},getReport(ME,'basic','hyperlinks','off'));
    end
end

csvPath=fullfile(out,'quality_metrics.csv');
fid=fopen(csvPath,'w');
if fid<0,error('Unable to create quality_metrics.csv');end
fprintf(fid,'case,method,TP,FP,TN,FN,Dice,IoU,Sensitivity,Specificity,BalancedAccuracy,PredictedForegroundFraction\n');
for k=1:size(rows,1)
    v=rows(k,:);
    fprintf(fid,'%s,%s,%d,%d,%d,%d,%.9f,%.9f,%.9f,%.9f,%.9f,%.9f\n', ...
        v{1},v{2},v{3},v{4},v{5},v{6},v{7},v{8}, ...
        v{9},v{10},v{11},v{12});
end
fclose(fid);
save(fullfile(out,'quality_benchmark_arrays.mat'), ...
    'inputs','truth','outputs','cases','algNames','rows');

%% Optional qualitative sample: no ground truth, hence NO accuracy metrics.
samplePath=which('printedtext.png');
if ~isempty(samplePath)
    try
        sample=imread(samplePath);
        if size(sample,3)==3,sample=rgb2gray(sample);end
        sample=im2double(sample);
        sampleResults=runMethods(sample);
        renderUnlabeled(sample,sampleResults,algNames, ...
            fullfile(out,'printedtext_qualitative.png'));
    catch ME
        messages{end+1}=['Printed text preview failed: ' ME.message]; %#ok<AGROW>
    end
else
    messages{end+1}='printedtext.png not installed; optional preview skipped';
end

allCasesHaveResults=(size(rows,1)==numel(cases)*numel(algNames));
report=sprintf('Previous MATLAB regression suite: %s\n', ...
    statusWord(regressionOK));
report=[report sprintf('Quality cases evaluated: %d of %d\n', ...
    size(rows,1)/numel(algNames),numel(cases))];
report=[report sprintf('Reference masks present: %s\n', ...
    statusWord(allCasesHaveResults))];
report=[report sprintf('Methods per condition: %d\n',numel(algNames))];
report=[report sprintf('Output CSV: quality_metrics.csv\n')];
report=[report sprintf(['Dice/IoU are valid only for these fixed synthetic fixtures; ' ...
    'do not infer real-image or medical accuracy.\n'])];
for k=1:numel(messages)
    report=[report sprintf('NOTE: %s\n',messages{k})]; %#ok<AGROW>
end
writeText(fullfile(out,'status.txt'),report);
archivePath=fullfile(resultsRoot,['MATLAB_Quality_Validation_' stamp '.zip']);
zip(archivePath,{['quality_' stamp]},resultsRoot);
fprintf('\n==============================================\n%s',report);
fprintf('Result ZIP: %s\n',archivePath);
fprintf('==============================================\n');
end

function runPreviousRegression(root)
run(fullfile(root,'tests','run_regression.m'));
end

function [I,GT]=syntheticDocument(caseIndex)
% Geometric strokes and a ring with known object membership.
n=256;
[X,Y]=meshgrid(0:n-1,0:n-1);
x=X/(n-1); y=Y/(n-1);
GT=false(n,n);
GT(41:205,46:53)=true;
GT(41:48,46:190)=true;
GT(81:205,116:123)=true;
GT(196:203,116:215)=true;
GT(88:95,116:182)=true;
GT(126:133,166:223)=true;
GT(126:193,216:223)=true;
GT(178:185,167:223)=true;
r=(X-80).^2+(Y-145).^2;
GT=GT|((r<27^2)&(r>20^2));
switch caseIndex
    case 1
        background=0.80+zeros(n,n);
        darkOffset=0.30; noiseSD=0.008;
    case 2
        background=0.64+0.27*x+0.05*y+0.026*sin(2*pi*y);
        darkOffset=0.30; noiseSD=0.014;
    case 3
        background=0.64+0.25*x+0.05*y+0.025*sin(2*pi*y);
        darkOffset=0.22; noiseSD=0.020;
    otherwise
        error('Unknown synthetic fixture.');
end
rng(20261120+caseIndex,'twister');
I=max(0,min(1,background-darkOffset*double(GT)+noiseSD*randn(n)));
end

function masks=runMethods(I)
% Every returned mask uses TRUE=dark foreground.
masks=cell(1,9);
masks{1}=~logical(OtsuThreshold(I));
radius=max([1 1],round(size(I)/16));
masks{2}=~logical(LocalMeanThreshold(I,radius,'Both','Replicate',0.12));
dirs={'LR','RL','UD','DU'};
for k=1:4
    mask=WellnerImage(I,struct('Method',dirs{k},'PadValue','Rp'));
    masks{2+k}=~logical(mask);
end
dirs={'Pr','Po','Bo'};
for k=1:3
    mask=BradleyImage(I,struct('Direction',dirs{k},'PadValue','Rp'));
    masks{6+k}=~logical(mask);
end
end

function renderComparison(I,GT,masks,names,file,caseName)
fig=figure('Visible','off','Color','white','Position',[100 100 1600 1050]);
subplot(3,4,1); imshow(I); title(['Input: ' caseName],'Interpreter','none');
subplot(3,4,2); imshow(~GT); title('Ground truth: dark objects');
for k=1:numel(masks)
    mask=masks{k};
    TP=sum(mask(:)&GT(:));
    FP=sum(mask(:)&~GT(:));
    FN=sum(~mask(:)&GT(:));
    dice=2*TP/max(1,2*TP+FP+FN);
    subplot(3,4,k+2); imshow(~mask);
    title(sprintf('%s | Dice %.3f',names{k},dice), ...
        'Interpreter','none','FontSize',10);
end
subplot(3,4,12);
imshow(xor(GT,masks{end}));
title('Bradley Both: disagreement');
exportgraphics(fig,file,'Resolution',180);
close(fig);
end

function renderUnlabeled(I,masks,names,file)
fig=figure('Visible','off','Color','white','Position',[100 100 1600 1050]);
subplot(3,4,1); imshow(I); title('Sample input');
for k=1:numel(masks)
    subplot(3,4,k+1); imshow(~masks{k});
    title(names{k},'Interpreter','none','FontSize',10);
end
sgtitle('Unlabeled sample — no ground-truth metrics');
exportgraphics(fig,file,'Resolution',180);
close(fig);
end

function writeText(path,contents)
fid=fopen(path,'w');
if fid<0,error('Cannot write %s',path);end
fprintf(fid,'%s',contents);
fclose(fid);
end

function label=statusWord(ok)
if ok,label='PASS';else,label='FAIL / INCOMPLETE';end
end
