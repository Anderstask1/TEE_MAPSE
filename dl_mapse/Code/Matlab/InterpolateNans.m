
function interpVals = InterpolateNans(vals)

X = ~isnan(vals);
Y = cumsum(X-diff([1,X])/2);
interpVals = interp1(1:nnz(X),vals(X),Y);

%replace 
 ~isnan(vals)