%%%%% MODEL TESTING CONTAINER SCRIPT


count = 0;
pars = {};
% distance of targets from fixation
dist = 25;
% angle separating targets
for ang = [0]
    for stim_strength = 0.3 %0.2:0.025:0.6
        count = count + 1;
        pars{count}.delay = stim_strength;
        pars{count}.dist = round(cos(ang/2*pi/180)*dist);
        pars{count}.y_val = round(sin(ang/2*pi/180)*dist);
        pars{count}.angle = ang;
    end
end

for i = 1: count
    out = BATCH_MULTISING(pars{i});
end

BATCH_ANALYSE_DUAL_RTvsAver
