function F = myFun(x)
    load data.mat
       
    
    F = gampdf(((0.05:0.005:0.6)+x(2)).*x(1),x(3),x(4)).*x(5) - the_data;
end