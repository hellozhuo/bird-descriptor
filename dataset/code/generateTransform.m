function transformGenerated = generateTransform(source,dest,reflect)
sourceMidX = (source.x1 + source.x2) * 0.5;
sourceMidY = (source.y1 + source.y2) * 0.5;
destMidX = (dest.x1 + dest.x2) * 0.5;
destMidY = (dest.y1 + dest.y2) * 0.5;

% translate the left point to the origin
translate1 = translateMatrix(-sourceMidX, -sourceMidY);

% translate the origin to the left destination
translate2 = translateMatrix(destMidX, destMidY);


% compute the scale that needs to be applyed to the image
sdist = sqrt((source.x1 - source.x2)^2 + (source.y1 - source.y2)^2);
ddist = sqrt((dest.x1 - dest.x2)^2 + (dest.y1 - dest.y2)^2);
s = ddist/sdist;
scale = scaleMatrix(s);

% compute the rotation that needs to be applyed to the image
stheta = atan((source.y2 -source.y1)/(source.x2 - source.x1));
dtheta = atan((dest.y2 -dest.y1)/(dest.x2 - dest.x1));
theta  = dtheta - stheta;
rotate = rotateMatrix(theta);

% compute the reflection if nessicary
reflection = reflectMatrix(reflect,0);

% build the final transformation
tmp1 = scale * translate1;
tmp2 = rotate * tmp1;
tmp3 = reflection * tmp2;
transformGenerated = translate2 * tmp3;

% free temporary matricies
clear translate1;
clear translate2;
clear scale;
clear rotate;
clear reflection;
clear tmp1;
clear tmp2;
clear tmp3;


end % the end of the function









