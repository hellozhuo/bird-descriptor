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

function face = get_face_region_with_transform(image, transform, out_size)

image = double(image);
width = out_size(1);
height = out_size(2);
face = transformImage(image,width,height,transform);

% imshow(face);






