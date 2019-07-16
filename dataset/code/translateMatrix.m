% Return a translation matrix
function transform = translateMatrix(dx, dy)
transform = eye(3);

transform(1,3) = dx;
transform(2,3) = dy;

end