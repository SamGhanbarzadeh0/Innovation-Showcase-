function summary = validate_builtin_images(methodHandle, root, source, out)
%VALIDATE_BUILTIN_IMAGES Matched comparisons on MATLAB example images.
% Uses images shipped with MATLAB/toolboxes, not synthetic inputs.
% Unlabeled samples do NOT provide accuracy, sensitivity, Dice, or IoU.
% Original and corrected outputs are measured on the IDENTICAL pixels.
% Images are evaluated at a reproducible maximum dimension of 256.
%
% The source image paths stay in the owner's temporary artifact only;
% the original example image binaries are not committed to the repository.

candidates={'cameraman.tif','coins.png','rice.png','peppers.png', ...
    'saturn.png','printedtext.png','pout.tif','liftingbody.png'};
names={'Original_Otsu','Corrected_Otsu','Toolbox_Otsu', ...
    'Original_LocalMean_Zero','Corrected_LocalMean_Zero', ...
    'Corrected_LocalMean_T012','Toolbox_Adaptive', ...
    'Original_Wellner_LR','Corrected_Wellner_LR', ...
    'Original_Wellner_UD','Corrected_Wellner_UD', ...
    'Original_Bradley_Both','Corrected_Bradley_Both'};
pairIdx=[1 2;4 5;4 6;8 9;10 11;12 13];
nCandidates=numel(candidates);nMethods=numel(names);
inputData=cell(nCandidates,1);
resultMasks=cell(nCandidates,nMethods);
manifest=cell(nCandidates,6);
records=cell(0,9);
pairs=cell(0,8);
figureCount=0;found=0;missing=0;correctedErrors=0;legacyErrors=0;
notes={};
for i=1:nCandidates
    name=candidates{i};
    filepath=which(name);
    if isempty(filepath) || ~exist(filepath,'file')
        missing=missing+1;
        manifest(i,:)={name,'NOT_FOUND','','',NaN,NaN};
        continue
    end
    try
        [raw,map]=imread(filepath);
        if ~isempty(map)
            I=rgb2gray(ind2rgb(raw,map));
        elseif ndims(raw)==3
            I=rgb2gray(raw);
        else
            I=raw;
        end
        I=im2double(I);
        if ndims(I)~=2 || isempty(I) || any(~isfinite(I(:)))
            error('BuiltIn:Input','Image is non-finite, empty or not 2-D.');
        end
        originalSize=size(I);
        if max(originalSize)>256
            I=imresize(I,256/max(originalSize),'bilinear');
        end
        inputData{i}=I;
        found=found+1;
        manifest(i,:)={name,'LOADED',filepath, ...
            sprintf('%dx%d',originalSize(1),originalSize(2)), ...
            size(I,1),size(I,2)};
    catch ME
        notes{end+1}=sprintf('LOAD %s: %s',name,ME.message); %#ok<AGROW>
        missing=missing+1;
        manifest(i,:)={name,'LOAD_ERROR',filepath,'',NaN,NaN};
        continue
    end
    for m=1:nMethods
        status='PASS';msg='';mask=[];fraction=NaN;
        components=NaN;t0=tic;
        try
            mask=logical(methodHandle(names{m},I,root,source));
            if ~isequal(size(mask),size(I))
                error('BuiltIn:Shape','Output dimensions differ from the input.');
            end
            fraction=nnz(mask)/numel(mask);
            components=bwconncomp(mask,8).NumObjects;
            resultMasks{i,m}=mask;
        catch ME
            status='ERROR';msg=ME.identifier;
            if isempty(msg),msg=ME.message;end
            if startsWith(names{m},'Original_')
                legacyErrors=legacyErrors+1;
            else
                correctedErrors=correctedErrors+1;
            end
            notes{end+1}=sprintf('METHOD %s on %s: %s', ...
                names{m},name,ME.message); %#ok<AGROW>
        end
        elapsed=toc(t0);
        records(end+1,:)={name,names{m},status,msg, ...
            size(I,1),size(I,2),fraction,components,elapsed}; %#ok<AGROW>
    end
    for k=1:size(pairIdx,1)
        a=pairIdx(k,1);b=pairIdx(k,2);
        A=resultMasks{i,a};B=resultMasks{i,b};
        if isempty(A)||isempty(B)
            status='UNMATCHED';agreement=NaN;changed=NaN;
        else
            status='COMPARED';
            changed=nnz(xor(A,B))/numel(A);
            agreement=1-changed;
        end
        pairs(end+1,:)={name,names{a},names{b},status, ...
            agreement,changed,nnz(A),nnz(B)}; %#ok<AGROW>
    end
    try
        renderNative(I,resultMasks(i,:),names,name, ...
            fullfile(out,sprintf('native_%s.png',erase(name,{'.png','.tif'}))));
        figureCount=figureCount+1;
    catch ME
        notes{end+1}=sprintf('FIGURE %s: %s',name,ME.message); %#ok<AGROW>
    end
end
M=cell2table(manifest,'VariableNames', ...
    {'Filename','Status','InstalledPath','OriginalDimensions','Height','Width'});
writetable(M,fullfile(out,'native_image_manifest.csv'));
R=cell2table(records,'VariableNames', ...
    {'Image','Method','Status','ErrorID','Height','Width', ...
    'ForegroundFraction','Components8','Seconds'});
writetable(R,fullfile(out,'native_method_results.csv'));
P=cell2table(pairs,'VariableNames', ...
    {'Image','OriginalMethod','RevisedMethod','Status', ...
    'PixelAgreement','ChangedPixelFraction', ...
    'OriginalDarkPixelCount','RevisedDarkPixelCount'});
writetable(P,fullfile(out,'native_paired_disagreement.csv'));
save(fullfile(out,'native_image_arrays.mat'), ...
    'inputData','resultMasks','candidates','names','-v7');
fid=fopen(fullfile(out,'native_image_notes.txt'),'w');
fprintf(fid,'MATLAB original sample images are UNLABELED for this analysis.\n');
fprintf(fid,['Pixel agreement is not segmentation accuracy; component counts ' ...
    'measure fragmentation, not correctness.\n']);
for k=1:numel(notes),fprintf(fid,'%s\n',notes{k});end
fclose(fid);
summary=struct('requested',nCandidates,'found',found,'missing',missing, ...
    'correctedErrors',correctedErrors,'legacyErrors',legacyErrors, ...
    'figures',figureCount,'minRequired',4);
summary.passed=found>=summary.minRequired && ...
    correctedErrors==0 && figureCount==found;
end

function renderNative(I,masks,names,imageName,target)
selected=[1 2 3 4 5 6 7 8 9 12 13];
f=figure('Visible','off','Color','white','Position',[80 80 1500 1080]);
subplot(3,4,1);imshow(I);title(['Original: ' imageName],'Interpreter','none');
for k=1:numel(selected)
    id=selected(k);
    subplot(3,4,k+1);
    mask=masks{id};
    if isempty(mask)
        imshow(ones(size(I)));title([names{id} ' | ERROR'], ...
            'Interpreter','none','FontSize',9);
    else
        imshow(~mask);title(names{id}, ...
            'Interpreter','none','FontSize',9);
    end
end
sgtitle('MATLAB built-in example — dark object masks (NO GROUND TRUTH)');
exportgraphics(f,target,'Resolution',140);
close(f);
end
