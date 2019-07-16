% author: zhuo.su@oulu.fi
% date: 10.11.2018

function pdv = LBP_M(image, pa, image_lm)

% using interpolation 

max_radius = pa.max_r;

d_image = double(image);
[ysize, xsize] = size(image);

% yNum_region = min(16,floor((ysize-max_radius*2)/rows_split));
% xNum_region = min(16,floor((xsize-max_radius*2)/cols_split));
% 
% yPerm_region = randperm(floor((ysize-max_radius*2)/rows_split));
% xPerm_region = randperm(floor((xsize-max_radius*2)/cols_split));

% Block size, each LBP code is computed within a block of size bsizey*bsizex
bsizey= 2 * max_radius +1;
bsizex= 2 * max_radius +1;

% Coordinates of origin (0,0) in the block
origy = 1 + max_radius;
origx = 1 + max_radius;

% Minimum allowed size for the input image depends
% on the radius of the used LBP operator.
if(xsize < bsizex || ysize < bsizey)
  error('Too small input image. Should be at least (2*radius+1) x (2*radius+1)');
end

% Calculate dx and dy;
dx = xsize - bsizex;
dy = ysize - bsizey;

% Fill the center pixel matrix C.
C = image(origy:origy+dy,origx:origx+dx);
d_C = double(C);

neighbors = pa.q * pa.bit;
pdv_whole = zeros(size(C, 1), size(C, 2), neighbors);
radius = pa.r;    

spoints=zeros(neighbors,2);

% Angle step.
a = 2*pi/neighbors;

for i = 1:neighbors
    spoints(i,1) = -radius*sin((i-1)*a);
    spoints(i,2) = radius*cos((i-1)*a);
end

% compute pixel difference vector
for i = 1:neighbors
    y = spoints(i,1)+origy;
    x = spoints(i,2)+origx;
    % Calculate floors, ceils and rounds for the x and y.
    fy = floor(y); cy = ceil(y); ry = round(y);
    fx = floor(x); cx = ceil(x); rx = round(x);
    % Check if interpolation is needed.
    if (abs(x - rx) < 1e-6) && (abs(y - ry) < 1e-6)
        % Interpolation is not needed, use original datatypes
        N = d_image(ry:ry+dy,rx:rx+dx);
    else
        % Interpolation needed, use double type images 
        ty = y - fy;
        tx = x - fx;

        % Calculate the interpolation weights.
        w1 = roundn((1 - tx) * (1 - ty),-6);
        w2 = roundn(tx * (1 - ty),-6);
        w3 = roundn((1 - tx) * ty,-6) ;
        % w4 = roundn(tx * ty,-6) ;
        w4 = roundn(1 - w1 - w2 - w3, -6);

        % Compute interpolated pixel values
        N = w1*d_image(fy:fy+dy,fx:fx+dx) + w2*d_image(fy:fy+dy,cx:cx+dx) + ...
        w3*d_image(cy:cy+dy,fx:fx+dx) + w4*d_image(cy:cy+dy,cx:cx+dx);
        N = roundn(N,-4);
    end 
    pdv_whole(:, :, i) = abs(N - d_C);
end

if pa.q > 1
    [dim1, dim2, ~] = size(pdv_whole);
    pdv_whole = reshape(pdv_whole, dim1, dim2, [], pa.bit);
    pdv_whole = mean(pdv_whole, 3);
    pdv_whole = reshape(pdv_whole, dim1, dim2, []);
    neighbors = pa.bit;
end

pdv_whole = pdv_whole - mean(pdv_whole, 3);

if(pa.sort)
    pdv_whole = sort(pdv_whole, 3);
end

if(pa.binary)
    pdv_whole = pdv_whole > 0;
end

if(nargin > 2)
    [h, w, ~] = size(pdv_whole);
    pdv = cell(pa.div(1), pa.div(2));
    for i = 1: pa.div(1)
        center_x = image_lm(i, 1) + 1 - max_radius;
        center_y = image_lm(i, 2) + 1 - max_radius;
        if center_y - 19 < 1
            row_range = 1: 40;
        elseif center_y + 20 > h
            row_range = (h - 39): h;
        else
            row_range = (center_y - 19): (center_y + 20);
        end
        if center_x - 19 < 1
            col_range = 1: 40;
        elseif center_x + 20 > w
            col_range = (w - 39): w;
        else
            col_range = (center_x - 19): (center_x + 20);
        end
        patch = pdv_whole(row_range, col_range, :);
        num_inter = uint32(sqrt(pa.div(2)));
        axis_x = uint32(linspace(1, 41, num_inter + 1));
        axis_y = uint32(linspace(1, 41, num_inter + 1));
        for j = 1: pa.div(2)
            index_col = mod(j - 1, num_inter) + 1;
            index_row = floor((j - 1) / double(num_inter)) + 1;
            Tmp = patch(axis_y(index_row): axis_y(index_row + 1) - 1, ...
                axis_x(index_col): axis_x(index_col + 1) - 1, :);
            pdv{i, j} = reshape(Tmp, size(Tmp, 1) * size(Tmp, 2), neighbors);
        end
    end       
else
    rows_split = pa.div(1);
    cols_split = pa.div(2);
    h_region = floor((ysize-max_radius*2)/rows_split);
    w_region = floor((xsize-max_radius*2)/cols_split);
    pdv = cell(rows_split, cols_split);
    for i = 1:rows_split
        s_h = h_region * (i-1) + 1;
        e_h = s_h + h_region - 1;
        for j = 1:cols_split
            pdv{i, j} = zeros(h_region * w_region, neighbors);
            s_w = w_region * (j-1) + 1;
            e_w = s_w + w_region - 1;
            Tmp = pdv_whole(s_h:pa.step:e_h, s_w:pa.step:e_w, :);   
            pdv{i,j} = reshape(Tmp, [], neighbors);
    %         pdv{i,j} = reshape(Tmp(yPerm_region(1:yNum_region),...
    %             xPerm_region(1:xNum_region),:),xNum_region*yNum_region,dim_whole);
        end
    end
end
end

function x = roundn(x, n)

narginchk(2, 2)
validateattributes(x, {'single', 'double'}, {}, 'ROUNDN', 'X')
validateattributes(n, ...
    {'numeric'}, {'scalar', 'real', 'integer'}, 'ROUNDN', 'N')

if n < 0
    p = 10 ^ -n;
    x = round(p * x) / p;
elseif n > 0
    p = 10 ^ n;
    x = p * round(x / p);
else
    x = round(x);
end

end