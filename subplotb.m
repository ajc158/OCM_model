function h = subplotb(row,col,index)

frame = 0.1;
padding = 0.1;

index = index - 1;

indexRow = floor(index/col);
indexCol = index - (indexRow)*col;

indexRow = row - (floor(index/col)+1);


h = axes('position', [(1-2*frame)/col*indexCol+padding*(1-2*frame)/col+frame, ...
                    (1-2*frame)/row*indexRow+padding*(1-2*frame)/row+frame, ...
                    (1-2*frame)/col-padding*(1-2*frame)/col, ...
                    (1-2*frame)/row-padding*(1-2*frame)/row]);

end