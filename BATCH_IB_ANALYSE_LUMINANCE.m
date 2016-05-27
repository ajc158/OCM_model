

allData = {};
fits1 = {};
fits2 = {};
fits3 = {};
fits1gof = {};
fits2gof = {};
fits3gof = {};
hists = {};

gauss_r2_1 = [];
gauss_r2_2 = [];
gauss_r2_3 = [];

residuals1 = [];
residuals2 = [];
residuals3 = [];

adjr2_1 = [];
adjr2_2 = [];
adjr2_3 = [];

chisquared1 = [];
chisquared2 = [];
chisquared3= [];

fileStr ='';

count = 0;
d = 0;
w = 0;
pars = {};
for dist = 25
    for luminance = [0.6]%:0.1:1.0%0.25
        count = 0;

            for noise = [5]
                for weight = [1 1.5 2 2.5 3]
                    w = w + 1;
                    if w == 6
                        w = 1;
                    end
                   for delay = [-0.1 0.0 0.1]
                    d = d + 1;
                    if d == 4
                        d = 1;
                    end
                    
                    count = count + 1;
                    allData{d,w} = [];
                    smoothed_data = zeros(size(0.05:0.005:0.6));
                    % create the job
                    for part = 1:40
                        if delay < 0
                            minus = 'm';
                        else
                            minus = '';
                        end
                        runString = ['moo_' minus num2str(abs(luminance*10)) '_' num2str(abs(delay*10)) '_' num2str(weight*10)  '_' num2str(part)];
                        eval(['fileStr = ''data' runString ''';']);
                        
                         if (exist(['./dataTemp/big_high_noise/' fileStr '.mat']) == 0)
                            continue; 
                         end
                         
                        % load file
                        eval(['load ./dataTemp/big_high_noise/' fileStr ';']);
                        eval(['goodOrNot = size(' fileStr ',1);']);
                        if goodOrNot > 0
                            eval(['allData{d,w} = [allData{d,w}; ' fileStr '];']);
                        end
                    end
                    
                    figure(luminance*10)
                    subplot(5,3,count);
                    
                    % smooth some shit
                    for i = 1:size(allData{d,w},1)
                        smoothed_data = smoothed_data + normpdf(0.05:0.005:0.6, allData{d,w}(i), 0.005)./(sum(normpdf(0.05:0.005:0.6, allData{d,w}(i), 0.005)));
                    end
                    
                    the_data = smoothed_data;
                    save data.mat the_data;
                    
                    x0 = [60, -0.1, 9, 0.5, 150]  ;                      % Starting guess
                    opts = optimoptions(@lsqnonlin,'Algorithm','levenberg-marquardt','MaxFunEvals',5000, 'MaxIter', 2000);
                     [x,residuals1(d,w)] = lsqnonlin(@myFun,x0,[],[], opts);   % Invoke optimizer

                    fits1{d,w} = x;
                                       
                    
                    %for i = 1:24
                      %  [x,resnorm] = lsqnonlin(@myFun,x);
%                     end 
                    t=gampdf(((0.05:0.005:0.6)+x(2)).*x(1),x(3),x(4)).*x(5);
                    
                    one_minus_r2 = (sum((smoothed_data-t).^2))./(sum((smoothed_data - mean(smoothed_data)).^2));
                    num_bins = size(smoothed_data(smoothed_data>0),2);
                    num_free_pars = 5;
                    
                    adjr2_1(d,w) = 1-one_minus_r2*(num_bins-1)/(num_bins-num_free_pars-1);
                    
                    % chi squared test
                    chisquared1(d,w) = chi2pdf(sum(((the_data(t>5)-t(t>5)).^2)./t(t>5)),size(t(t>5),2)-5);
                                        
                    
                    if w == 1 && d == 2
                        x0 = [60, -0.12, 9, 0.5, 150, 65, -0.15, 8.5, 0.45,150];                        % Starting guess
                    else
                        x0 = [60, -0.05, 9, 0.5, 170, 65, -0.15, 8.5, 0.45,150];                        % Starting guess
                    end
                    opts = optimoptions(@lsqnonlin,'Algorithm','levenberg-marquardt','MaxFunEvals',10000, 'MaxIter', 2000);
                     [x,residuals2(d,w)] = lsqnonlin(@myFun2,x0,[],[], opts);   % Invoke optimizer
 
                    
                     [f, fit1gof{d,w}] = fit((0.05:0.005:0.6)', smoothed_data', 'gauss1');

                    gauss_r2_1(d,w) = fit1gof{d,w}.adjrsquare
                    
                     fits2{d,w} = x;
                     
                    
%                     hist(allData{d,w},0.05:0.005:0.6);
                    plot(0.05:0.005:0.6, smoothed_data); hold on;
                    plot(0.05:0.005:0.6, t,'r'); 
                    
                    t = gampdf(((0.05:0.005:0.6)+x(2)).*x(1),x(3),x(4)).*x(5) + gampdf(((0.05:0.005:0.6)+x(7)).*x(6),x(8),x(9)).*x(10);
                    
                    % chi squared test
                    chisquared2(d,w) = chi2pdf(sum(((the_data(t>5)-t(t>5)).^2)./t(t>5)),size(t(t>5),2)-10);
                    
                    one_minus_r2 = (sum((smoothed_data-t).^2))./(sum((smoothed_data - mean(smoothed_data)).^2));
                    num_bins = size(smoothed_data(smoothed_data>0),2);
                    num_free_pars = 10;
                    
                    adjr2_2(d,w) = 1-one_minus_r2*(num_bins-1)/(num_bins-num_free_pars-1);
                    
                    plot(0.05:0.005:0.6, t,'g'); 
                    
                    
                    x0 = [60, -0.1, 9, 0.5, 170, 65, -0.15, 8.5, 0.45,150, 70, -0.2, 8.8, 0.55,130];                        % Starting guess
                    opts = optimoptions(@lsqnonlin,'Algorithm','levenberg-marquardt','MaxFunEvals',15000, 'MaxIter', 2000);
                     [x,residuals3(d,w)] = lsqnonlin(@myFun3,x0,[],[], opts);   % Invoke optimizer
 
                    fits3{d,w} = x;
                    
                    t = gampdf(((0.05:0.005:0.6)+x(2)).*x(1),x(3),x(4)).*x(5) + gampdf(((0.05:0.005:0.6)+x(7)).*x(6),x(8),x(9)).*x(10) + gampdf(((0.05:0.005:0.6)+x(12)).*x(11),x(13),x(14)).*x(15);
                    
                    % chi squared test
                    chisquared3(d,w) = chi2pdf(sum(((the_data(t>5)-t(t>5)).^2)./t(t>5)),size(t(t>5),2)-15);
                    
                    one_minus_r2 = (sum((smoothed_data-t).^2))./(sum((smoothed_data - mean(smoothed_data)).^2));
                    num_bins = size(smoothed_data(smoothed_data>0),2);
                    num_free_pars = 15;
                    
                    adjr2_3(d,w) = 1-one_minus_r2*(num_bins-1)/(num_bins-num_free_pars-1);
                    
                    plot(0.05:0.005:0.6, t,'c'); hold off;
                    
%                     figure(luminance*10+1)
%                     subplot(5,3,count);
                    
                     [f, fit2gof{d,w}] = fit((0.05:0.005:0.6)', smoothed_data', 'gauss2');
gauss_r2_2(d,w) = fit1gof{d,w}.adjrsquare;
%                     fits2{d,w} = f;
%                     %plot(f,0.05:0.005:0.6, smoothed_data); %hold on;
%                     
%                     
                     [f, fit3gof{d,w}] = fit((0.05:0.005:0.6)', smoothed_data', 'gauss3');
gauss_r2_3(d,w) = fit1gof{d,w}.adjrsquare;
%                     fits3{d,w} = f;
                    
%                     plot(0.05:0.005:0.6, f); hold off;
                    axis([0.05 0.5 0 100]);
                    hists{d,w} = [(0.1:0.005:0.3)', histc(allData{d,w},0.1:0.005:0.3)];
                    
                    % write to file:
%                     csvwrite(['~/Dropbox/OCM_data/rt_dist_no_SC_input_d' num2str(delay*10) '_w' num2str(weight*10) '.csv'], hists{d,w});
                end
            end
        end
    end
end

if 1==0
    
    % put all the gof in a blob
    gofgauss1 = [];
    for i=1:5
        for j=1:3
       
            array(i,j) = (fits1{j,i}(3)*fits1{j,i}(4))/fits1{j,i}(1)-fits1{j,i}(2);
            
        end
    end
   
    % put the means into a blob
    
    array = [];
    
    for i=1:5
        for j=1:3
       
            array(i,j) = (fits1{j,i}(3)*fits1{j,i}(4))/fits1{j,i}(1)-fits1{j,i}(2);
            
        end
    end
    array
    
    array2a = [];
    
    for i=1:5
        for j=1:3
       
            array2a(i,j) = (fits2{j,i}(3)*fits2{j,i}(4))/fits2{j,i}(1)-fits2{j,i}(2);
            
        end
    end
    array2a
    array2b = [];
    
    for i=1:5
        for j=1:3
       
            array2b(i,j) = (fits2{j,i}(8)*fits2{j,i}(9))/fits2{j,i}(6)-fits2{j,i}(7);
            
        end
    end
    array2b
    
        array3a = [];
    
    for i=1:5
        for j=1:3
       
            array3a(i,j) = (fits3{j,i}(3)*fits3{j,i}(4))/fits3{j,i}(1)-fits3{j,i}(2);
            
        end
    end
    array3a
    array3b = [];
    
    for i=1:5
        for j=1:3
       
            array3b(i,j) = (fits3{j,i}(8)*fits3{j,i}(9))/fits3{j,i}(6)-fits3{j,i}(7);
            
        end
    end
    array3b
        array3c = [];
    
    for i=1:5
        for j=1:3
       
            array3c(i,j) = (fits3{j,i}(13)*fits3{j,i}(14))/fits3{j,i}(11)-fits3{j,i}(12);
            
        end
    end
    array3c
    
end
