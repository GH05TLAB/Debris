function [ d ] = euclidianDistance( x1, x2, y1, y2 )

diff1 = (x1-x2)^2;
diff2 = (y1-y2)^2;

d = sqrt(diff1+diff2);

end

