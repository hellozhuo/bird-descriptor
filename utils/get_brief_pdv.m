%% produce pixel difference vector for traditional lbp (BRIEF binary pattern)
% author: zhuo.su@oulu.fi
% date: 13.04.2018
%
% [IN]
% image: a gray scale image
%
% pairs: size of [num_pairs, 4], each row represents a pair of (row, col)
% location with [row1, col1, row2, col2], the row and col are both real number.
%
% [OUT]
% pdv: obtained pdvs, size of [num_pdvs, dim]

function pdv = get_brief_pdv(image, pairs)

