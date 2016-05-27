function F = myFun2(x)
    load data.mat
       
    
    F = gampdf(((0.05:0.005:0.6)+x(2)).*x(1),x(3),x(4)).*x(5) + gampdf(((0.05:0.005:0.6)+x(7)).*x(6),x(8),x(9)).*x(10) - the_data;
end