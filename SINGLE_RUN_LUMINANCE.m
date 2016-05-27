%%%%% MODEL TESTING CONTAINER SCRIPT

% luminance = [];


% for i = 1:800
%     luminance = [luminance 0.5];
% end

% hist(luminance, 10)

% figure(3);
% clf;

tic
count = 0;
pars = {};
for dist = 25
    for delay = [0 0.1]
        for luminance = 0.6%:0.1:1.0%0.25
            for noise = [5]
                for weight = [1 2 3]
                    count = count + 1;
                    pars{count}.delay = delay;
                    pars{count}.luminance = luminance;
                    pars{count}.dist = dist;
                    pars{count}.noise = noise;
                    pars{count}.weight = weight;
                end
            end
        end
    end
end

% outs = {};

for i = 2: count
    out = BATCH_LUMINANCE(pars{i})
    outs{i} = out;
    figure(1);
    subplot(1,7,i);
    hist(outs{i},0:0.001:1);
    axis([0.1 0.4 0 80]);
end
toc

count = 1;
for delay = [1 2]
    for noise = [1]
        for weight = [1 2 3]
            count = count + 1;
            figure(delay);
            subplot(7,1,weight);
            hist(outs{count},0:0.005:1);
            axis([0.1 0.3 0 60]);
        end
    end
end

% creates /home/alex/lum_step_gap_0p1_noise_5_phasic_1_2_3.mat
% tic
% count = 0;
% pars = {};
% for dist = 25
%     for delay = [0 0.1]
%         for luminance = 0.6%:0.1:1.0%0.25
%             for noise = [5]
%                 for weight = [1 2 3]
%                     count = count + 1;
%                     pars{count}.delay = delay;
%                     pars{count}.luminance = luminance;
%                     pars{count}.dist = dist;
%                     pars{count}.noise = noise;
%                     pars{count}.weight = weight;
%                 end
%             end
%         end
%     end
% end
% 
% outs = {};
% 
% for i = 1: count
%     out = BATCH_LUMINANCE(pars{i})
%     outs{i} = out;
% end
% toc
% 
% count = 0;
% for delay = [1 2]
%     for noise = [1]
%         for weight = [1 2 3]
%             count = count + 1;
%             figure(delay);
%             subplot(1,3,weight);
%             hist(outs{count},0:0.001:1);
%             axis([0.1 0.4 0 80]);
%         end
%     end
% end

%%% creates /home/alex/lum_overlap_step_gap_0p1_noise_5_10_phasic_1_2_3.mat  
% tic
% count = 0;
% pars = {};
% for dist = 25
%     for delay = [-0.1 0 0.1]
%         for luminance = 0.25%:0.1:1.0%0.25
%             for noise = [5 10]
%                 for weight = [1 2 3]
%                     count = count + 1;
%                     pars{count}.delay = delay;
%                     pars{count}.luminance = luminance;
%                     pars{count}.dist = dist;
%                     pars{count}.noise = noise;
%                     pars{count}.weight = weight;
%                 end
%             end
%         end
%     end
% end
% 
% outs = {};
% 
% for i = 1: count
%     out = BATCH_LUMINANCE(pars{i})
%     outs{i} = out;
% end
% toc
% 
% count = 0;
% for delay = [1 2 3]
%     for noise = [1 2]
%         for weight = [1 2 3]
%             count = count + 1;
%             figure(delay);
%             subplot(2,3,(weight-1)*2+noise);
%             hist(outs{count},0:0.01:1);
%             axis([0.2 0.7 0 80]);
%         end
%     end
% end

