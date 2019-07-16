function transform = reflectMatrix(bool_x, bool_y)
transform = eye(3);

if (bool_x)
    transform(1,1) = -1;
end
if (bool_y)
    transform(2,2) = -1;
end
