function archiveFile = collect_validation_bundle()
%COLLECT_VALIDATION_BUNDLE Execute MATLAB tests and collect reproducible outputs.
%   Start with: run('tests/collect_validation.m')
%   The function creates validation_results/validation_YYYYMMDD_HHMMSS/
%   and a ZIP with console logs, figures, CSV statistics, and MAT arrays.
%
%   No original source files or publication PDFs are modified.
root = fileparts(fileparts(mfilename('fullpath')));
stamp = datestr(now, 'yyyymmdd_HHMMSS');
resultsRoot = fullfile(root, 'validation_results');
out = fullfile(resultsRoot, ['validation_' stamp]);
if ~exist(out,'dir'), mkdir(out); end

info = fopen(fullfile(out,'environment.txt'),'w');
if info < 0, error('Cannot open environment output file.'); end
fprintf(info,'Repository: hesamghd/Innovation-Showcase-\n');
fprintf(info,'Source branch: fix/stage-03-matlab-2026-11-20\n');
fprintf(info,'Source PR: https://github.com/hesamghd/Innovation-Showcase-/pull/3\n');
fprintf(info,'Captured at: %s\n',datestr(now,31));
fprintf(info,'MATLAB: %s\n',version);
fprintf(info,'Platform: %s\n',computer);
installed = ver;
for k = 1:numel(installed)
    fprintf(info,'%s | %s\n',installed(k).Name,installed(k).Version);
end
fclose(info);

testOK = false; testLog = '';
testError = '';
tic;
try
    testLog = evalc('runRegressionIsolated();');
    testOK = contains(testLog,'PASS:');
catch ME
    testError = getReport(ME,'extended','hyperlinks','off');
end
elapsed = toc;
fid = fopen(fullfile(out,'regression_console.txt'),'w');
fprintf(fid,'MATLAB TEST STATUS: %s\n',passFail(testOK));
fprintf(fid,'Time seconds: %.6f\n\n%s\n',elapsed,testLog);
if ~isempty(testError), fprintf(fid,'ERROR REPORT:\n%s\n',testError); end
fclose(fid);

figOK = false;
figError = '';
try
    imgRoot = fullfile(root,'Image Processing','Matlab', ...
        'Chapter 2 - Image Thresholding');
    addpath(fullfile(imgRoot,'OTSU Binarization'));
    addpath(fullfile(imgRoot,'Simple Mean Binarization'));
    addpath(fullfile(imgRoot,'Wellner Thresholding'));
    addpath(fullfile(imgRoot,'Bradley Thresholding'));

    [x,y] = meshgrid(linspace(0,1,128));
    I = 0.15 + 0.50*x + 0.20*y;
    I(28:96,32:75) = max(0,I(28:96,32:75)-0.30);
    I(45:85,78:110) = min(1,I(45:85,78:110)+0.30);
    I = max(0,min(1,I));

    [otsuBW,threshold,details] = OtsuThreshold(I);
    pad = PadArray(I,[8 8],'Both','Replicate');
    avg = ImageMean(pad,8,8,'Both');
    meanBW = I>=avg;
    wellner = cell(4,1);
    directions = {'LR','RL','UD','DU'};
    for k=1:4
        wellner{k} = WellnerImage(I, ...
            struct('Method',directions{k},'PadValue','Rp'));
    end
    bradley = cell(3,1);
    bdirs = {'Pr','Po','Bo'};
    for k=1:3
        bradley{k} = BradleyImage(I, ...
            struct('Direction',bdirs{k},'PadValue','Rp'));
    end
    assert(all(isfinite(I(:))) && all(isfinite(avg(:))));
    assert(isequal(size(otsuBW),size(I),size(meanBW)));
    for k=1:4, assert(isequal(size(wellner{k}),size(I))); end
    for k=1:3, assert(isequal(size(bradley{k}),size(I))); end

    fig=figure('Visible','off','Position',[100 100 1300 780]);
    subplot(2,3,1); imshow(I); title('Synthetic input');
    subplot(2,3,2); imshow(otsuBW); title('Otsu threshold');
    subplot(2,3,3); imshow(meanBW); title('Local mean');
    subplot(2,3,4); imshow(wellner{1}); title('Wellner LR');
    subplot(2,3,5); imshow(wellner{2}); title('Wellner RL');
    subplot(2,3,6); imshow(bradley{3}); title('Bradley Both');
    saveas(fig,fullfile(out,'threshold_comparison.png')); close(fig);

    fig=figure('Visible','off','Position',[100 100 1250 900]);
    for k=1:4
        subplot(2,4,k); imshow(wellner{k});
        title(['Wellner ' directions{k}]);
    end
    for k=1:3
        subplot(2,4,k+4); imshow(bradley{k});
        title(['Bradley ' bdirs{k}]);
    end
    saveas(fig,fullfile(out,'direction_comparison.png')); close(fig);

    save(fullfile(out,'synthetic_outputs.mat'),'I','otsuBW','threshold', ...
        'details','meanBW','avg','wellner','bradley','directions','bdirs');

    fid = fopen(fullfile(out,'summary_metrics.csv'),'w');
    fprintf(fid,'algorithm,fraction_foreground\n');
    fprintf(fid,'Otsu,%.10f\n',mean(otsuBW(:)));
    fprintf(fid,'LocalMean,%.10f\n',mean(meanBW(:)));
    for k=1:4, fprintf(fid,'Wellner_%s,%.10f\n', ...
            directions{k},mean(wellner{k}(:))); end
    for k=1:3, fprintf(fid,'Bradley_%s,%.10f\n', ...
            bdirs{k},mean(bradley{k}(:))); end
    fclose(fid);
    figOK=true;
catch ME
    figError=getReport(ME,'extended','hyperlinks','off');
end

fid=fopen(fullfile(out,'status.txt'),'w');
fprintf(fid,'MATLAB regression tests: %s\n',passFail(testOK));
fprintf(fid,'Synthetic output + figures: %s\n',passFail(figOK));
fprintf(fid,'Do not interpret these synthetic results as medical data validation.\n');
if ~isempty(testError), fprintf(fid,'\nREGRESSION ERROR:\n%s\n',testError); end
if ~isempty(figError), fprintf(fid,'\nFIGURE ERROR:\n%s\n',figError); end
fclose(fid);

archiveFile = fullfile(resultsRoot,['MATLAB_Validation_Results_' stamp '.zip']);
zip(archiveFile,{['validation_' stamp]},resultsRoot);
fprintf('\n============================================\n');
fprintf('Regression tests: %s\n',passFail(testOK));
fprintf('Synthetic figures: %s\n',passFail(figOK));
fprintf('Result ZIP: %s\n',archiveFile);
fprintf('Upload this ZIP in your ChatGPT conversation.\n');
fprintf('============================================\n');
end

function runRegressionIsolated()
% The historical test script starts with CLEAR. Isolating its workspace
% protects the collector's variables even if a regression fails.
root=fileparts(fileparts(mfilename('fullpath')));
run(fullfile(root,'tests','run_regression.m'));
end

function label=passFail(ok)
if ok, label='PASS'; else, label='FAIL / NOT COMPLETED'; end
end
