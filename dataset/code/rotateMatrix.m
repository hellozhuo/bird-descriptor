%  Return a rotation matrix
function transform = rotateMatrix(theta)
transform = eye(3);

transform(1,1) = cos(theta);
transform(2,2) = cos(theta);
transform(1,2) = -sin(theta);
transform(2,1) = sin(theta);
end