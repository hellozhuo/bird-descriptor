%% crop out a tight face image from the original image
% author: zhuo.su@oulu.fi
% date: 27.10.2018
%
% [IN]
% image: a gray scale image
%
% eyes_position: =[xl, yl; xr, yr] left_eye_x, left_eye_y; right_eye_x,
% right_eye_y
%
% out_size: =[height, width], height and width of the cropped iamge
%
% [OUT]
% the cropped face iamge
%%

function face = get_face_region_0(image, eyes_position, out_size)

[h_image, w_image, channel] = size(image);
if(channel == 3)
    image = rgb2gray(image);
end
xl = double(eyes_position(1, 1)); yl = double(eyes_position(1, 2));
xr = double(eyes_position(2, 1)); yr = double(eyes_position(2, 2));
h_out = out_size(1); w_out = out_size(2);

eyes_distance = sqrt((xl - xr)^2 + (yl - yr)^2);

if(abs(yr - yl) > 0)
    sin_theta = (yr - yl) / eyes_distance;
    theta = asind(sin_theta);
    image = imrotate(image, theta, 'bilinear');
    
    dis_c_r = sqrt((xr - w_image / 2)^2 + (yr - h_image / 2)^2);
    theta_c_r = asind((yr - h_image / 2) / dis_c_r);
    xr = w_image / 2 + dis_c_r * cosd(-theta_c_r + theta);
    yr = h_image / 2 - dis_c_r * sind(-theta_c_r + theta);
    
    dis_c_l = sqrt((xl - w_image / 2)^2 + (yl - h_image / 2)^2);
    theta_c_l = asind((yl - h_image / 2) / dis_c_l) + 180;
    xl = w_image / 2 + dis_c_l * cosd(theta_c_l + theta);
    yl = h_image / 2 - dis_c_l * sind(theta_c_l + theta);
%     fprintf("the diff between yl and yr is %d\n", yl - yr);  
    eyes_distance = sqrt((xl - xr)^2 + (yl - yr)^2);
end

w_face = round(2.4 * eyes_distance);
h_face = round(w_face * double(h_out) / w_out);
% h_face = (2.4 * eyes_distance);
dis_eye_top = 0.55 * eyes_distance;
dis_eye_left = 0.7 * eyes_distance;

top = round(yl - dis_eye_top); top = max(1, top);
buttom = round(yl - dis_eye_top + h_face); buttom = min(h_image, buttom);
left = round(xl - dis_eye_left); left = max(1, left);
right = round(xl - dis_eye_left + w_face); right = min(w_image, right);

face = image(top: buttom, left: right);
face = imresize(face, [h_out, w_out], 'bilinear');
% imshow(face);






