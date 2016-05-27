%%%%% MODEL TESTING CONTAINER SCRIPT


count = 0;
pars = {};
for dist = [3 5.0 7.5 10 15 20 25 30 40]
    for delay = 0
        for luminance = 0.5:0.1:0.9
        count = count + 1;
        pars{count}.delay = luminance;
        pars{count}.dist = dist;
        pars{count}.cmf_type = 0;
        end
    end
end

for i = 1: count
    out = BATCH_CMF(pars{i});
end

BATCH_ANALYSE_CMF_LUM