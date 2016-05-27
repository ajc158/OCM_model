function [W,srci,dsti] = netdist(src,dst,args)

srci = repmat((1:src.count)',1,dst.count);
dsti = repmat((1:dst.count),src.count,1);
W = args.weights;

