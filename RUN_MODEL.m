%*************************************************************************%
%                                                                         % 
%                             FULL MODEL                                  %
%                                                                         %
%*************************************************************************%

%   Full oculomotor and visual system model
%   Alex Cope 2009


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PARAM INI %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Namespace paths:
p2a = 'dev/abrg/2009/modlin/activation/';
p2o = 'dev/abrg/2009/modlin/output/';
p2p = 'dev/abrg/2009/modlin/projection/';


% prepare command object
exe = brahms_execution();
if (~exist('overrideName', 'var')) 
    exe.name = 'manc_test';
else
    exe.name = overrideName;
end
exe.stop = executionStop;
exe.encapsulated = false;
if concerto
    exe.execPars.MaxThreadCount = 'x3';
else
    exe.execPars.MaxThreadCount = 'x8';
end
exe.execPars.IntervoiceCompression = 0;
if concerto == true
    exe.execPars.ShowGUI = false;
end
exe.execPars.ShowGUI = false;
exe.all = false;

% scope interval
inter = 20;

% Hacked factor to calibrate motors to pixels
pantilt_scale = 1;

% set up standard LIN node parameters (see "help sub_nw_node_lin")
defParsAct = [];
defParsAct.tau_membrane = 0.01;
defParsAct.p = 1;
defParsAct.sigma_membrane = MEMB_NOISE;

defParsOut = [];
defParsOut.limits = [0 1];
defParsOut.m = 1;
defParsOut.c = 0;

sys = sml_system();

%%%%%%%%%%%%%%%%%%%%%%%% SET UP FOR SPECIFIC TASK %%%%%%%%%%%%%%%%%%%%%%%%%


fovea_damping_offset = 1;

switch taskType
    
    case 'TEST'
        layerDims = [50 50];
        layerLocs = [50 50];
        In_dims = [150 150];
        In_locs = {[150 150]};
        ret_dims = [150 150];
        ret_locs = {[150 150]};
        EXTERN_VIRTUAL
        ORIENT  
        cd CONNECT
        CONNECT_NO_VIS_LP
        cd ..
        
    case 'FLAG'
        layerDims = [32 32];
        layerLocs = [32 32];
        In_dims = [80 80];
        In_locs = {[80 80]};
        ret_dims = [80 80];
        ret_locs = {[80 80]};
        EXTERN_VIRTUAL
        ORIENT
        switch visSys
            case 'gate'
                cd VIS
                vis_gate_1_2_OC
                %vis_VIRTUAL
                cd ..
            case 'add'
                cd VIS
                vis_add_1_2_OC
                cd ..
            case 'shunt'
                cd VIS
                vis_shunt_1_2_OC
                cd ..
        end
        cd CONNECT
        CONNECT_FLAG
        cd ..
        
    case 'TEST_ROBOT'
%         layerDims = [32 32];
%         layerLocs = [32 32];
        layerDims = [128 128];
        layerLocs = [128 128];

        vs = 64;
        In_dims = [vs vs];
        In_locs = {[vs vs]};
        ret_dims = [vs vs];
        ret_locs = {[vs vs]};
        EXTERN
        if concerto == false
            ORIENTB
        else
            ORIENTCUDA
        end

        cd VIS
        vis_Robot_CartMAX2
        cd ..

        LEARN_ROBOT
        
        cd CONNECT
        if concerto == false
            CONNECT_LP_ROBOT
        else
            CONNECT_LP_CUDA
        end
        cd ..
%         SCAMP
        
   case 'TEST_APRON'
        layerDims = [32 32];
        layerLocs = [32 32];
        vs = 64;
        In_dims = [vs vs];
        In_locs = {[vs vs]};
        ret_dims = [vs vs];
        ret_locs = {[vs vs]};
        EXTERN
        ORIENTAPRON

        cd VIS
        vis_Robot_Cart_APRON
        cd ..

        LEARN_ROBOT_APRON
        
        cd CONNECT
        CONNECT_LP_APRON
        cd ..
        
    case 'TEST_OCM'
        layerDims = [32 32];
        layerLocs = [32 32];
        In_dims = [150 150];
        In_locs = {[150 150]};
        ret_dims = [150 150];
        ret_locs = {[150 150]};
        EXTERN_VIRTUAL
        ORIENT
        cd CONNECT
        CONNECT_NO_VIS_LP
        cd ..
        
   case 'NO_GO'
        layerDims = [32 32];
        layerLocs = [32 32];
        In_dims = [150 150];
        In_locs = {[150 150]};
        ret_dims = [150 150];
        ret_locs = {[150 150]};
        EXTERN_VIRTUAL
        ORIENT
        cd CONNECT
        CONNECT_NO_VIS_LP
        cd ..
        
     case 'CHAR'
        layerDims = [32 32];
        layerLocs = [32 32];
        In_dims = [150 150];
        In_locs = {[150 150]};
        ret_dims = [150 150];
        ret_locs = {[150 150]};
        EXTERN_VIRTUAL
        ORIENT
        cd CONNECT
        CONNECT_NO_VIS_LP
        cd ..
        
    case 'CMF'
        fovea_damping_offset = 5;
        layerDims = [50 50];
        layerLocs = [50 50];
        In_dims = [150 150];
        In_locs = {[150 150]};
        ret_dims = [150 150];
        ret_locs = {[150 150]};
        EXTERN_VIRTUAL
        ORIENT  
        cd CONNECT
        CONNECT_NO_VIS_LP
        cd ..
        
     case 'DUAL'
        fovea_damping_offset = 5;
        layerDims = [50 50];
        layerLocs = [50 50];
        In_dims = [150 150];
        In_locs = {[150 150]};
        ret_dims = [150 150];
        ret_locs = {[150 150]};
        EXTERN_VIRTUAL
        ORIENT  
        cd CONNECT
        CONNECT_NO_VIS_LP
        cd ..
        
    case 'JON'
        fovea_damping_offset = 5;
        layerDims = [50 50];
        layerLocs = [50 50];
        In_dims = [150 150];
        In_locs = {[150 150]};
        ret_dims = [150 150];
        ret_locs = {[150 150]};
        EXTERN_VIRTUAL
        ORIENT  
        cd CONNECT
        CONNECT_NO_VIS_LP
        cd ..
        
    case 'CMF_VIS'
        layerDims = [50 50];
        layerLocs = [50 50];
        In_dims = [150 150];
        In_locs = {[150 150]};
        ret_dims = [150 150];
        ret_locs = {[150 150]};
        EXTERN_VIRTUAL
        ORIENT  
        cd CONNECT
        CONNECT_NO_VIS_GBR_LP
        cd ..
        
    case'VS'
        if field_vs == true
        fovea_damping_offset = 4;            
        end
        layerDims = [32 32];
        layerLocs = [32 32];
        In_dims = [150 150];
        In_locs = {[150 150]};
        ret_dims = [150 150];
        ret_locs = {[150 150]};
        EXTERN_VIRTUAL
        ORIENT
        switch visSys
            case 'gate3'
                cd VIS
                vis_3_2_LP_OC_MAX
                %vis_VIRTUAL
                cd ..
            case 'gate3feat'
                cd VIS
                vis_3_2_LP_OC_FEATURE
                %vis_VIRTUAL
                cd ..
            case 'add3'
                cd VIS
                vis_3add_OC
                cd ..
            case 'shunt3'
                cd VIS
                vis_3shunt_OC
                cd ..
            case 'test_input'
                cd VIS
                TEST_INPUT
                cd ..
        end
        cd CONNECT
        CONNECT_LP
        cd ..
        
    case'ONSET'
        layerDims = [32 32];
        layerLocs = [32 32];
        In_dims = [150 150];
        In_locs = {[150 150]};
        ret_dims = [150 150];
        ret_locs = {[150 150]};
        EXTERN_VIRTUAL
        fovea_damping_offset = 4;
        ORIENT
        switch visSys
            case 'gate3'
                cd VIS
                vis_3_2_LP_OC_MAX
                cd ..
            case 'add3'
                cd VIS
                vis_3add_OC
                cd ..
            case 'shunt3'
                cd VIS
                vis_3shunt_OC
                cd ..
        end
        cd CONNECT
        CONNECT_LP
        cd ..
        
    case'SACLEN'
        layerDims = [32 32];
        layerLocs = [32 32];
        In_dims = [150 150];
        In_locs = {[150 150]};
        ret_dims = [150 150];
        ret_locs = {[150 150]};
        EXTERN_VIRTUAL
        fovea_damping_offset = 4;
        ORIENT
        switch visSys
            case 'gate3'
                cd VIS
                vis_3_2_LP_OC_MAX
                cd ..
        end
        cd CONNECT
        CONNECT_LP
        cd ..
        
end



%*************************************************************************%
%                            RUN BRAHMS                                   %
%*************************************************************************%


if concerto == true 
    exe.addresses = {'192.168.101.201' '192.168.101.42' '192.168.101.46'};
    exe.affinity = {{1,'scampCam' 'vis' 'extern' 'learn' 'inhib' 'ones' 'orient' 'zeros' 'input_proj1' 'visResampIn' 'd2_bias'},{2, 'scamp'},{3, 'APRON'}};
    exe.launch = 'each concerto_launch2 ((ADDR)) ((EXECFILE)) ((VOICE)) ((ARGS)) --logfile-((LOGFILE))';
%     exe.addresses = {'192.168.101.46' '192.168.101.201' };
%     exe.affinity = {{1, 'APRON' 'learn'},{2,'scampCam' 'vis' 'extern' 'ones' 'inhib' 'zeros' 'input_proj1' 'visResampIn' 'orient' 'd2_bias'}};
%     exe.launch = 'each concerto_launch2 ((ADDR)) ((EXECFILE)) ((VOICE)) ((ARGS)) --logfile-((LOGFILE))';
end
%     exe.addresses = {'192.168.101.201' '192.168.101.46'};
%      exe.affinity = {{2, 'orient'},{1, 'learn' 'scampCam' 'vis' 'extern' 'ones' 'inhib' 'zeros' 'input_proj1' 'visResampIn' 'd2_bias'}};
%      exe.launch = 'each concerto_launch ((ADDR)) ((EXECFILE)) ((VOICE)) ((ARGS)) --logfile-((LOGFILE))';


% call BRAHMS
%t1 = etime(clock, t0);
[out, rep] = brahms(sys, exe);% ,'--debug-5');
%t2 = etime(clock, t0);

