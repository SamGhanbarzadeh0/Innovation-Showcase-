% Stage 03 final: run complete original-versus-corrected comparison.
% Set MATLAB Current Folder to the extracted repository root, then run:
%   run('tests/final/run_final.m')
baseDir = fileparts(mfilename('fullpath'));
addpath(baseDir);
collect_final_validation();
