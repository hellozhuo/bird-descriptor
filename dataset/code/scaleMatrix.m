% Return a scale Matrix 
function transform = scaleMatrix( s)
transform = eye(3);
transform(1,1) = s;
transform(2,2) = s;

end