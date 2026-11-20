% COLLECT_VALIDATION  Run the complete tests and export MATLAB result files.
% From the extracted repository's root folder, execute:
%   run('tests/collect_validation.m')
testFolder = fileparts(mfilename('fullpath'));
addpath(testFolder);
collect_validation_bundle();
