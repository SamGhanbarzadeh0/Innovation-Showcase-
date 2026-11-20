function outputZip = collect_final_validation()
%COLLECT_FINAL_VALIDATION Compare original and corrected MATLAB implementations.
%   One-command, reproducible Stage 03 release gate for MATLAB R2024a.
%   The exact original MATLAB blobs live under tests/legacy_snapshot.
%
%   A completed ZIP is NOT evidence of success: inspect status.txt and
%   all per-case methods/statuses in matched_metrics.csv.
%   All masks use TRUE = dark foreground. No images are read from patients.
root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
source = fullfile(root,'Image Processing','Matlab','Chapter 2 - Image Thresholding');
addpath(fullfile(source,'OTSU Binarization'),'-end');
addpath(fullfile(source,'Simple Mean Binarization'),'-end');
addpath(fullfile(source,'Wellner Thresholding'),'-end');
addpath(fullfile(source,'Bradley Thresholding'),'-end');
stamp = datestr(now,'yyyymmdd_HHMMSS');
parent = fullfile(root,'validation_results');
out = fullfile(parent,['final_' stamp]);
if ~exist(out,'dir'), mkdir(out); end
fid = fopen(fullfile(out,'environment.txt'),'w');
fprintf(fid,'MATLAB: %s\nOS: %s\nStarted: %s\n', ...
    version,computer,datestr(now,31));
fprintf(fid,'Original base commit: 40240cd9d6aed4b6613697b535f84ad6fda80c29\n');
fprintf(fid,'Proposed final branch: fix/stage-03-final-evaluation-2026-11-20\n');
fprintf(fid,'Synthetic fixtures: 3 geometries x 3 illuminations x 2 contrasts x 2 seeds = 36\n');
fprintf(fid,'Image size: 128x128; dark is foreground; no per-image tuning.\n');
fclose(fid);
methodNames = {'Original_Otsu','Corrected_Otsu','Toolbox_Otsu', ...
    'Original_LocalMean_Zero','Corrected_LocalMean_Zero', ...
    'Corrected_LocalMean_T012','Toolbox_Adaptive', ...
    'Original_Wellner_LR','Corrected_Wellner_LR', ...
    'Original_Wellner_RL','Corrected_Wellner_RL', ...
    'Original_Wellner_UD','Corrected_Wellner_UD', ...
    'Original_Wellner_DU','Corrected_Wellner_DU', ...
    'Original_Bradley_Pre','Corrected_Bradley_Pre', ...
    'Original_Bradley_Post','Corrected_Bradley_Post', ...
    'Original_Bradley_Both','Corrected_Bradley_Both'};
nMethods = numel(methodNames);
nCases=36;
caseI=cell(nCases,1); caseGT=cell(nCases,1);
allMasks=cell(nCases,nMethods);
results=cell(nCases*nMethods,18);
failures={};
testPassed=false;
try
    log = evalc('runRegression(root);');
    testPassed=contains(log,'PASS:');
    writeText(fullfile(out,'regression_console.txt'),log);
catch ME
    writeText(fullfile(out,'regression_console.txt'), ...
        getReport(ME,'extended','hyperlinks','off'));
    failures{end+1}=['REGRESSION: ' ME.message]; %#ok<AGROW>
end
extendedPassed=false;
try
    edgeLog=evalc('extended_edge_tests();');
    extendedPassed=contains(edgeLog,'EXTENDED PASS:');
    writeText(fullfile(out,'extended_edge_console.txt'),edgeLog);
catch ME
    writeText(fullfile(out,'extended_edge_console.txt'), ...
        getReport(ME,'extended','hyperlinks','off'));
    failures{end+1}=['EXTENDED EDGE CHECK: ' ME.message]; %#ok<AGROW>
end
counter=0;
for geometry=1:3
    for illumination=1:3
        for contrast=1:2
            for replicate=1:2
                caseNum=caseNumFromParams(geometry,illumination,contrast,replicate);
                [I,GT]=makeFixture(geometry,illumination,contrast,replicate);
                caseI{caseNum}=I; caseGT{caseNum}=GT;
                for m=1:nMethods
                    counter=counter+1;
                    t0=tic; status='PASS'; errorID='';
                    try
                        P=oneMethod(methodNames{m},I,root,source);
                        if ~islogical(P), P=logical(P); end
                        if ~isequal(size(P),size(GT))
                            error('Final:Shape','Output shape disagrees with ground truth.');
                        end
                        if isempty(P) || any(~isfinite(double(P(:))))
                            error('Final:Nonfinite','Output is empty or invalid.');
                        end
                    catch ME
                        status='ERROR';errorID=ME.identifier;
                        if isempty(errorID),errorID=ME.message;end
                        P=[];
                        failures{end+1}=sprintf( ...
                            'case=%d method=%s error=%s : %s', ...
                            caseNum,methodNames{m},errorID,ME.message); %#ok<AGROW>
                    end
                    sec=toc(t0);
                    allMasks{caseNum,m}=P;
                    [tp,fp,tn,fn,dice,iou,sensitivity,specificity,balanced] = ...
                        evaluateMask(P,GT);
                    results(counter,:)={caseNum,geometry,illumination, ...
                        contrast,replicate,methodNames{m},status,errorID, ...
                        tp,fp,tn,fn,dice,iou,sensitivity,specificity,balanced,sec};
                end
            end
        end
    end
end
T=cell2table(results,'VariableNames', ...
    {'CaseID','Geometry','Illumination','Contrast','Replicate', ...
    'Method','Status','ErrorID','TP','FP','TN','FN', ...
    'Dice','IoU','Sensitivity','Specificity','BalancedAccuracy','Seconds'});
writetable(T,fullfile(out,'matched_metrics.csv'));

% Aggregate ONLY successful cases; report count so errors cannot be hidden.
fid=fopen(fullfile(out,'method_summary.csv'),'w');
fprintf(fid,'Method,SuccessCount,ErrorCount,MeanDice,MedianDice,MinDice,MeanIoU,MedianSeconds\n');
for m=1:nMethods
    rows=strcmp(T.Method,methodNames{m});
    ok=rows & strcmp(T.Status,'PASS');
    vals=T.Dice(ok);
    if isempty(vals), vals=NaN; end
    secs=T.Seconds(ok);
    if isempty(secs),secs=NaN;end
    fprintf(fid,'%s,%d,%d,%.8f,%.8f,%.8f,%.8f,%.6f\n', ...
        methodNames{m},sum(ok),sum(rows)-sum(ok), ...
        mean(vals),median(vals),min(vals),mean(T.IoU(ok)),median(secs));
end
fclose(fid);

% Paired comparisons are computed on the same cases, never on independent
% averages or only on a hand-picked image.
pairs={'Original_LocalMean_Zero','Corrected_LocalMean_Zero'; ...
    'Original_LocalMean_Zero','Corrected_LocalMean_T012'; ...
    'Original_Otsu','Corrected_Otsu'; ...
    'Original_Wellner_LR','Corrected_Wellner_LR'; ...
    'Original_Wellner_RL','Corrected_Wellner_RL'; ...
    'Original_Wellner_UD','Corrected_Wellner_UD'; ...
    'Original_Wellner_DU','Corrected_Wellner_DU'; ...
    'Original_Bradley_Pre','Corrected_Bradley_Pre'; ...
    'Original_Bradley_Post','Corrected_Bradley_Post'; ...
    'Original_Bradley_Both','Corrected_Bradley_Both'};
fid=fopen(fullfile(out,'paired_comparison.csv'),'w');
fprintf(fid,'Original,Corrected,MatchedN,UnmatchedN,MeanDiceDifference,MedianDiceDifference,WorseCases,BetterCases,TiedCases\n');
for p=1:size(pairs,1)
    a=strcmp(T.Method,pairs{p,1});
    b=strcmp(T.Method,pairs{p,2});
    va=T.Dice(a); vb=T.Dice(b);
    matched=isfinite(va) & isfinite(vb);
    delta=vb(matched)-va(matched);
    if isempty(delta), delta=NaN; end
    fprintf(fid,'%s,%s,%d,%d,%.8f,%.8f,%d,%d,%d\n', ...
        pairs{p,1},pairs{p,2},sum(matched),nCases-sum(matched), ...
        mean(delta),median(delta),sum(delta < -1e-9), ...
        sum(delta > 1e-9),sum(abs(delta)<=1e-9));
end
fclose(fid);

% Save every fixture and mask: future reviewers can independently
% recompute each reported TP/FP/TN/FN value and every quality metric.
save(fullfile(out,'matched_arrays.mat'), ...
    'caseI','caseGT','allMasks','methodNames','-v7');
figuresOK=false;figureError='';
try
    for light=1:3
        % Fixed, pre-declared case (first geometry, high contrast, seed 1).
        id=caseNumFromParams(1,light,1,1);
        renderCase(caseI{id},caseGT{id},allMasks(id,:), ...
            methodNames,fullfile(out,sprintf('case_light_%d.png',light)),id);
    end
    figuresOK=true;
catch ME
    figureError=getReport(ME,'extended','hyperlinks','off');
    failures{end+1}=['FIGURE: ' ME.message]; %#ok<AGROW>
end

% An unlabeled real-image visual audit has NO Dice/IoU.
realFigureOK=false;
sample=which('printedtext.png');
if ~isempty(sample)
    try
        I=im2double(imread(sample));
        if ndims(I)==3,I=rgb2gray(I);end
        pred={};labels={};
        selected={'Corrected_Otsu','Corrected_LocalMean_T012', ...
            'Corrected_Bradley_Both','Toolbox_Adaptive'};
        for j=1:numel(selected)
            labels{end+1}=selected{j}; %#ok<AGROW>
            pred{end+1}=oneMethod(selected{j},I,root,source); %#ok<AGROW>
        end
        fig=figure('Visible','off','Color','white','Position',[60 60 1250 800]);
        subplot(2,3,1);imshow(I);title('Unlabeled input');
        for j=1:numel(pred)
            subplot(2,3,j+1);imshow(~pred{j});
            title(labels{j},'Interpreter','none');
        end
        sgtitle('Qualitative ONLY: no reference mask and no accuracy metric');
        exportgraphics(fig,fullfile(out,'printedtext_comparison.png'),'Resolution',160);
        close(fig);
        realFigureOK=true;
    catch ME
        failures{end+1}=['UNLABELED SAMPLE: ' ME.message]; %#ok<AGROW>
    end
end
fid=fopen(fullfile(out,'failures.txt'),'w');
for j=1:numel(failures),fprintf(fid,'%s\n',failures{j});end
fclose(fid);
nErr=sum(strcmp(T.Status,'ERROR'));
correctedRows=startsWith(T.Method,'Corrected_') | startsWith(T.Method,'Toolbox_');
nCorrectedErr=sum(correctedRows & strcmp(T.Status,'ERROR'));
nOriginalErr=nErr-nCorrectedErr;
status=sprintf(['Regression assertions: %s\n' ...
    'Evaluated synthetic cases: %d\n' ...
    'Method attempts: %d\n' ...
    'Extended differential assertions: %s\n' ...
    'Total method errors: %d\n' ...
    'Original method errors: %d\n' ...
    'Corrected/toolbox method errors: %d\n' ...
    'Representative figures: %s\n' ...
    'Optional unlabeled printed-text figure: %s\n' ...
    'Matched legacy-vs-corrected comparisons: %d\n' ...
    'Release-gate decision: %s\n'], ...
    yesno(testPassed),nCases,height(T),yesno(extendedPassed), ...
    nErr,nOriginalErr,nCorrectedErr, ...
    yesno(figuresOK),yesno(realFigureOK),size(pairs,1), ...
    releaseGate(testPassed && extendedPassed,nCorrectedErr,figuresOK));
status=[status sprintf(['Method ranking is descriptive for these synthetic fixtures.\n' ...
    'Do not claim publication-grade superiority or clinical validation.\n' ...
    'Failures in ORIGINAL functions are retained as evidence, not suppressed.\n' ...
    'Results on unlabeled imagery have no ground-truth accuracy metrics.\n'])];
if ~isempty(figureError),status=[status figureError];end
writeText(fullfile(out,'status.txt'),status);
outputZip=fullfile(parent,['MATLAB_Final_Validation_' stamp '.zip']);
zip(outputZip,{['final_' stamp]},parent);
fprintf('\n%s\nZIP: %s\n',status,outputZip);
end

function number=caseNumFromParams(geometry,illum,contrast,replicate)
number=(((geometry-1)*3+(illum-1))*2+(contrast-1))*2+replicate;
end

function [I,GT]=makeFixture(geometry,illum,contrast,replicate)
% Distinct structures, two noise realizations and three lighting models.
N=128;[X,Y]=meshgrid(1:N,1:N);
shift=replicate*3+geometry;
switch geometry
    case 1 % line-and-ring geometry
        GT=(abs(X-(20+shift))<=3 & Y>=18 & Y<=112) | ...
            (abs(Y-(18+shift))<=3 & X>=20 & X<=102) | ...
            (abs(Y-(91-shift))<=3 & X>=47 & X<=111) | ...
            ((abs((X-(72+shift)).^2+(Y-65).^2-19^2))<=70);
    case 2 % two elliptical outlines and a slanted stroke
        r1=((X-(38+shift))/19).^2+((Y-43)/13).^2;
        r2=((X-88)/15).^2+((Y-(90-shift))/23).^2;
        GT=(abs(r1-1)<=0.23) | (abs(r2-1)<=0.25) | ...
            (abs(Y-(0.6*X+28+shift))<=2 & X>36 & X<106);
    case 3 % multi-scale block glyphs (thin + thick strokes)
        GT=(X>=19 & X<=24 & Y>=18 & Y<=113) | ...
            (Y>=22 & Y<=27 & X>=19 & X<=103) | ...
            (X>=52 & X<=57 & Y>=47 & Y<=104) | ...
            (Y>=70 & Y<=75 & X>=52 & X<=103) | ...
            (X>=87 & X<=95 & Y>=70 & Y<=109) | ...
            (abs(Y-(0.25*(X-25)+82))<=2 & X>=25 & X<=79);
end
GT=logical(GT);
x=(X-1)/(N-1);y=(Y-1)/(N-1);
switch illum
    case 1, background=0.79+zeros(N,N);
    case 2, background=0.53+0.38*x+0.045*y;
    case 3, background=0.55+0.21*((x-0.4).^2+(y-0.6).^2) ...
            +0.18*exp(-((x-0.5)/0.22).^2);
end
if contrast==1,delta=0.36; sigma=0.013;
else,delta=0.16;sigma=0.027;end
rng(20261120+geometry*1000+illum*100+contrast*10+replicate,'twister');
I=background-delta*double(GT)+sigma*randn(N,N);
I=max(0,min(1,I)); % precise fixture definition
end

function P=oneMethod(name,I,root,source)
% Input is normalized double; output TRUE means DARK foreground.
n=size(I);
radius=max([1 1],round(n/16));
switch name
    case 'Original_Otsu'
        U=im2uint8(I);
        H=invokeOriginal('Otsu','ComputeHistogram',U,[],root);
        % Faithful numerical transcription of the original interactive
        % Project1_OtsuBinarization.m, steps 5-9. No error repairs.
        prob=H/sum(H);cumul=cumsum(prob);
        L=max(U(:))+1;
        levels=double(0:L-1);
        muTotal=sum(levels.*prob);
        v=zeros(1,L);
        for q=1:L
            w0=cumul(q);w1=1-w0;
            m0=sum(levels(1:q).*prob(1:q))/(w0+eps);
            m1=sum(levels(q+1:end).*prob(q+1:end))/(w1+eps);
            v(q)=w0*(m0-muTotal)^2+w1*(m1-muTotal)^2;
        end
        [~,idx]=max(v);
        P=~(U>=levels(idx));
    case 'Corrected_Otsu'
        P=~OtsuThreshold(I);
    case 'Toolbox_Otsu'
        P=~imbinarize(I,graythresh(I));
    case 'Original_LocalMean_Zero'
        J=invokeOriginal('Mean','PadArray',I,{radius,'Both','Replicate'},root);
        M=invokeOriginal('Mean','ImageMean',J, ...
            {radius(1),radius(2),'Both'},root);
        P=~(I>=M);
    case 'Corrected_LocalMean_Zero'
        P=~LocalMeanThreshold(I,radius,'Both','Replicate',0);
    case 'Corrected_LocalMean_T012'
        P=~LocalMeanThreshold(I,radius,'Both','Replicate',0.12);
    case 'Toolbox_Adaptive'
        T=adaptthresh(I,0.5,'Statistic','mean', ...
            'NeighborhoodSize',[17 17],'ForegroundPolarity','dark');
        P=~imbinarize(I,T);
    otherwise
        if contains(name,'Wellner')
            j=extractAfter(name,'Wellner_');
            opts=struct('Method',char(j),'PadValue','Rp');
            if startsWith(name,'Original_')
                P=~invokeOriginal('Wellner','WellnerImage',I,{opts},root);
            else
                P=~WellnerImage(I,opts);
            end
        elseif contains(name,'Bradley')
            j=char(extractAfter(name,'Bradley_'));
            switch j
                case 'Pre',dir='Pr';
                case 'Post',dir='Po';
                case 'Both',dir='Bo';
                otherwise,error('Final:Method','Unsupported Bradley direction');
            end
            opts=struct('Direction',dir,'PadValue','Rp');
            if startsWith(name,'Original_')
                P=~invokeOriginal('Bradley','BradleyImage',I,{opts},root);
            else
                P=~BradleyImage(I,opts);
            end
        else
            error('Final:Method','Unrecognized method: %s',name);
        end
end
P=logical(P);
end

function output=invokeOriginal(family,functionName,I,extras,root)
% Original source bytes were copied by Git object SHA, not rewritten.
base=fullfile(root,'tests','legacy_snapshot','Image Processing', ...
    'Matlab','Chapter 2 - Image Thresholding');
switch family
    case 'Otsu', folder=fullfile(base,'OTSU Binarization');
    case 'Mean', folder=fullfile(base,'Simple Mean Binarization');
    case 'Wellner', folder=fullfile(base,'Wellner Thresholding');
    case 'Bradley', folder=fullfile(base,'Bradley Thresholding');
    otherwise,error('Final:LegacyPath','Unknown source family');
end
addpath(folder,'-begin');
clean=onCleanup(@()legacyCleanup(folder)); %#ok<NASGU>
clear PadArray ImageMean ComputeHistogram WellnerImage BradleyImage IntegralImage IntegralImagePlus
resolved=which(functionName);
assert(startsWith(resolved,folder), ...
    'Final:LegacyResolution','Failed to resolve the original source %s',functionName);
if isempty(extras)
    output=feval(functionName,I);
else
    output=feval(functionName,I,extras{:});
end
end

function legacyCleanup(folder)
if contains(path,[folder pathsep]) || strcmp(path,folder) ...
        || endsWith(path,[pathsep folder])
    rmpath(folder);
end
clear PadArray ImageMean ComputeHistogram WellnerImage BradleyImage IntegralImage IntegralImagePlus
end

function [tp,fp,tn,fn,dice,iou,sens,spec,bal]=evaluateMask(P,GT)
if isempty(P)
    tp=NaN;fp=NaN;tn=NaN;fn=NaN;
    dice=NaN;iou=NaN;sens=NaN;spec=NaN;bal=NaN;
    return
end
P=logical(P);GT=logical(GT);
tp=sum(P(:)&GT(:));fp=sum(P(:)&~GT(:));
tn=sum(~P(:)&~GT(:));fn=sum(~P(:)&GT(:));
dice=2*tp/max(1,2*tp+fp+fn);
iou=tp/max(1,tp+fp+fn);
sens=tp/max(1,tp+fn);spec=tn/max(1,tn+fp);
bal=(sens+spec)/2;
end

function runRegression(root)
run(fullfile(root,'tests','run_regression.m'));
end

function renderCase(I,GT,masks,names,target,id)
selected={'Original_LocalMean_Zero','Corrected_LocalMean_Zero', ...
    'Corrected_LocalMean_T012','Toolbox_Adaptive', ...
    'Original_Bradley_Both','Corrected_Bradley_Both', ...
    'Corrected_Otsu','Toolbox_Otsu'};
fig=figure('Visible','off','Color','white','Position',[50 50 1400 950]);
subplot(3,4,1);imshow(I);title(sprintf('Input case %d',id));
subplot(3,4,2);imshow(~GT);title('Reference dark objects');
for k=1:numel(selected)
    idx=find(strcmp(names,selected{k}),1);
    subplot(3,4,k+2);
    P=masks{idx};
    if isempty(P)
        imshow(ones(size(I)));
        title([selected{k} ' | ERROR'],'Interpreter','none');
    else
        imshow(~P);
        [~,~,~,~,d]=evaluateMask(P,GT);
        title(sprintf('%s | Dice %.3f',selected{k},d), ...
            'Interpreter','none','FontSize',9);
    end
end
sgtitle('Matched legacy / revised / MATLAB toolbox; same test input');
exportgraphics(fig,target,'Resolution',150);
close(fig);
end

function writeText(target,message)
fid=fopen(target,'w');
if fid<0,error('Final:Write','Unable to create output %s',target);end
fprintf(fid,'%s',message);fclose(fid);
end

function status=yesno(pass)
if pass,status='PASS';else,status='FAIL / NOT COMPLETED';end
end

function gate=releaseGate(regressionOK,nCorrectedErrors,figuresOK)
if regressionOK && nCorrectedErrors==0 && figuresOK
    gate='FUNCTIONAL PASS (quality claims remain limited)';
else
    gate='REVIEW REQUIRED (inspect corrected method errors, figures and regression log)';
end
end
