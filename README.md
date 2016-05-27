# OCM_model

## Installation

*Platform:* This model requires 64bit Linux to run.

*Matlab:* Matlab is required for this model, and due to changes in the Matlab toolboxes, Matlab 2012b or earlier is required. Additionally the Image Processing Toolbox is required.

*BRAHMS:* This model runs using the Matlab BRAHMS bindings. Instructions for installing and configuring BRAHMS for use with Matlab, and information on what BRAHMS does, can be found here: 
http://brahms.sourceforge.net/home/

Once BRAHMS and Matlab are installed and configured there are a few aditional steps.

*NodeWeaver:* a set of Matlab functions called 'NodeWeaver' is included in the repository. These must be added to the Matlab path using the 'addpath' function.

*BRAHMS Namespace processes / MODLIN:* A set of BRAHMS processes are required for the model. Mostly these are the MODLIN processes, available as source code here:
http://modlin.sourceforge.net/
There are also additional processes. For convinience these are provided as compiled 64bit Linux libraries in the Git repository (Namespace.tar.gz). This tarball should be untar'd and the path should be added to BRAHMS (using brahms_manager from within Matlab).

After these steps the model is ready to run.

## Running

The model results comprise a set of batch jobs - for convinience we have distributed them as sequential jobs rather than tied to a cluster submission system. The following Matlab scripts lanch these jobs:

```
SINGLE_RUN_CMF_LUMINANCE.m
SINGLE_RUN_DELAY.m
SINGLE_RUN_MULTI.m
STEP_COMPARISON_GRAPHS.m
DISTANCE_GRAPH.m
```

These are best run from the command line using the following syntax:

```matlab -nodisplay -nodesktop -r "SINGLE_RUN_MULTI"```

for example.

