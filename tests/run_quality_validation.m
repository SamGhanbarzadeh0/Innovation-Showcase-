% Run from the extracted repository root:
%   run('tests/run_quality_validation.m')
% The benchmark is separate from the previous Stage 03 collector.
root=fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(root,'tests'));
collect_quality_validation_bundle();
