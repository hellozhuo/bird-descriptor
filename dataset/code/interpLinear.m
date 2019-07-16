% interpolate a pixel value at a point
% PIX_TYPE interpLinear(Image img, PIX_TYPE x, PIX_TYPE y, int c)
function outPut = interpLinear(img, x, y, c)
xfrac = (x - floor(x));
yfrac = (y - floor(y));
xLower = floor(x);
xUpper = ceil(x);
yLower = floor(y);
yUpper = ceil(y);

xLower = max(1, xLower);
xLower = min(size(img, 2), xLower);
yLower = max(1, yLower);
yLower = min(size(img, 1), yLower);
xUpper = max(1, xUpper);
xUpper = min(size(img, 2), xUpper);
yUpper = max(1, yUpper);
yUpper = min(size(img, 1), yUpper);


% ==============================
% ������Щ����������ڴ���������ͼ����Ϊ�һ�û��������������
% if yUpper > 384
%     yUpper = 384;
% end
% if yLower > 384
%     yLower = 384;
% end
% if xLower < 1
%     xLower = 1;
% end
% if xUpper < 1
%     xUpper = 1;
% end
% 
% if xLower > 256
%     xLower = 256;
% end
% if xUpper > 256
%     xUpper = 256;
% end
% ==============================

valUpper = img(yUpper,xLower,c)*(1.0-xfrac) + img(yUpper,xUpper,c)*(xfrac);
valLower = img(yLower,xLower,c)*(1.0-xfrac) + img(yLower,xUpper,c)*(xfrac);
% valUpper = img(xLower,yUpper,c)*(1.0-xfrac) + img(xUpper,yUpper,c)*(xfrac);
% valLower = img(xLower,yLower,c)*(1.0-xfrac) + img(xUpper,yLower,c)*(xfrac);

outPut =  valLower*(1.0-yfrac) + valUpper*(yfrac);
end % the end of the function