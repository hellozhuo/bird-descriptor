%********* Geometric Transformation Code **********%
% typedef struct{
%     int width;
%     int height;
%     int channels;
%     PIX_TYPE*** data;
% } image;
% This function performs a 3X3 two dimentional perspective transform to an image
% This is used to perform geomentric normalization
function dest = transformImage(source, newWidth, newHeight, m)
% Image source
% const Matrix m
% Image dest = makeImage(newWidth, newHeight, source.channels);

dest = zeros(newHeight, newWidth, size(source,3));
point = zeros(3,1);
if size(m,1) ~= 3 || size(m,2) ~=3
    error('Error!');
end
point(3,1) = 1;

% find the inverse transformation to convert from dest to source
mINV = inv(m);

for x = 0 : size(dest,2)-1
    for y = 0 : size(dest,1)-1
        % calculate source point
        point(1,1) = x;
        point(2,1) = y;
        point(3,1) = 1.0;
        pt = mINV * point;
        pt(1,1) = pt(1,1) / pt(3,1);
        pt(2,1) = pt(2,1) / pt(3,1);
        
        for c = 1 : size(dest,3)
            % interpolate value
            dest(y+1,x+1,c) = interpLinear(source, pt(1,1),pt(2,1),c);
        end
    end
end

end % the end of the function
