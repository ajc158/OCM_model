%%%%% MODEL TESTING CONTAINER SCRIPT


count = 0;
pars = {};
for dist = 25:25
    for delay = 0.2
        for type = 1:2
            count = count + 1;
            pars{count}.delay = delay;
            pars{count}.dist = dist;
            pars{count}.type = type;
        end
    end
end

for i = 1: count
    out = BATCH_DELAY(pars{i}, i);
end

BATCH_ANALYSE_CUMULATIVE_DELAY