function submitFunc(scheduler, job, props, varargin)
% Assign the relevant values to environment variables, starting
% with identifying the decode function to be run by the worker:

decodeFcn = 'workerDecodeFunc';	
% if you change the name of the worker function, then change this too	

setenv('MDCE_DECODE_FUNCTION', decodeFcn);
setenv('MDCE_STORAGE_LOCATION', props.StorageLocation);
setenv('MDCE_STORAGE_CONSTRUCTOR',props.StorageConstructor);
setenv('MDCE_JOB_LOCATION', props.JobLocation);

%Get the current directory
currdir=pwd;

% Set the task-related variable:
prevDir = cd(fileparts(which(decodeFcn)));
for i = 1:props.NumberOfTasks
setenv('MDCE_TASK_LOCATION', props.TaskLocations{i});

% Run a MATLAB worker for each task in the job:
logLocation = [scheduler.DataLocation filesep ...
props.TaskLocations{i} '.log'];
%Build a script file for qsub for this task 
%Modify this to give control over qsub parameters - walltime ?
fid=fopen([currdir,'/ml_qsub_',num2str(i),'.sh'],'w');
fprintf(fid,'#!/bin/sh\n');
fprintf(fid,'#PBS -l walltime=300:00:00\n');
fprintf(fid,'#PBS -j oe\n');
fprintf(fid,['export MDCE_DECODE_FUNCTION=' decodeFcn '\n']);
fprintf(fid,['export MDCE_STORAGE_LOCATION=' props.StorageLocation '\n']);
fprintf(fid,['export MDCE_STORAGE_CONSTRUCTOR=' props.StorageConstructor '\n']);
fprintf(fid,['export MDCE_JOB_LOCATION=' props.JobLocation '\n']);
fprintf(fid,['export MDCE_TASK_LOCATION=' props.TaskLocations{i} '\n']);
fprintf(fid,['cd ',currdir,'\n']);
fprintf(fid,'matlab -dmlworker -nodisplay -r distcomp_evaluate_filetask\n');
fclose(fid)

%Submit job
system(['qsub -d ',currdir,' -e ',currdir,' -o ',currdir,' ',currdir,'/ml_qsub_',num2str(i),'.sh']);
end
cd(prevDir);

