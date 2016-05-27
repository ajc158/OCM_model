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
    for delay = [-0.1 0 0.1]
        for luminance = [0.6]%:0.1:1.0%0.25
            for noise = [5]
                for weight = [1.25 1.75 2.25]
                    count = count + 1;
                    % create the job
                    for part = 1:40
                        job = 'qsub ';
                        if count == 1 && part == 1
                            job = [job '-m bea -M a.cope@shef.ac.uk '];
                        end
                        job = [job '-l h_rt=20:00:00 -l mem=8G -j y /home/ac1ajcx/FULL_JON_OCM_PAPER/matlabjob ''-r "BATCH_IB_LUMINANCE(' num2str(delay) ',' num2str(luminance) ',' num2str(weight) ',' num2str(part) ')"'''];
                        job
                         [status,cmdout] = system(job);
                         cmdout
                    end
                        
%                     pars{count}.delay = delay;
%                     pars{count}.luminance = luminance;
%                     pars{count}.dist = dist;
%                     pars{count}.noise = noise;
%                     pars{count}.weight = weight;
                end
            end
        end
    end
end

% outs = {};



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

