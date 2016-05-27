%*************************************************************************%
%                                                                         %
%                                EXTERN                                   %
%                                                                         %
%*************************************************************************%

%contains:
% world - simulated visual environment

extern = sml_system();

retinaSize = [1032 778];
state = [];
state.camPort = 0;
state.camResolution = [1023 778];
state.retinaSize    = retinaSize;
state.retinaPosition = [0 0]; %[452 325];
state.color = 1;
state.viewUpdate = 1;
%extern = extern.addprocess('cam0', 'dev/aber/format7Cam', 25, state);
		state = [];
        state.ratio = round(fS/25);
		extern = extern.addprocess('cam0', 'dev/abrg/2009/camera', fS, state);

state = [];
state.retinaSize = [In_dims(1) In_dims(2)];
state.scale = floor(388/In_dims(1));
state.scale = 6;
state.camdims = [516 388];
extern = extern.addprocess('world', 'dev/abrg/2009/emPanTilt2', fS, state);

% pan-tilt system, delivering current 
% pan-tilt absolute positions
state = [];
state.panScale = 1;
state.tiltScale = 1;
state.velocity = 570;
state.acceleration = 5000;
extern = extern.addprocess('absPos', 'dev/abrg/2009/panTilt', fS, state);

extern = extern.link('cam0>timing', 'world<<cam<timing');

% 
extern = extern.link('cam0>R', 'world<<cam<r');
extern = extern.link('cam0>G', 'world<<cam<g');
extern = extern.link('cam0>B', 'world<<cam<b');


%*************************************************************************%
%                              END EXTERN                                 %
%*************************************************************************%

sys = sys.addsubsystem('extern', extern);