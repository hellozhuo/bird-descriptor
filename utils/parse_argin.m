%% parse the inputting parameters into name-value pairs
% author: zhuo.su@oulu.fi
% date: 27.10.2018
%
% [IN]
% varargin: the pair (name, value), which can be the following 
%
% name      value
%
% 'lbp'     [r, p]
% 
% 'rd'      [r1, r2, p]
%
% 'ad'      [r, p]
%
% 'concat'  'pdv-level': concatenate single pdvs into a whole pdv, 
%           'his-level': concatenate the histograms derived from single pdvs into a whole histogram,
%            default: 'pdv-level'
%
% 'coding'  'u2', 
%           'riu2', 
%           'k-means': neither 'u2' nor 'riu2', maintain their dimensions and cluster them using k-means, 
%           'cbfd'
%
% 'binary'  'yes': extract binary pdv, 
%           'no', 
%            default: 'yes'
%
% 'sort'    'yes': extract sorted pdv, 
%           'no', 
%            default: 'no'
% 
% 'split'   [M, N]: split the image into M * N regions
%
% 'kmeans'  function: k-means function, including cluster number, distance metric
%
% [OUT]
% a struct, of which name is field and value is value
%%

function pair = parse_argin(varargin)

number_pair = floor(nargin / 2);
if(nargin / 2.0 > number_pair) 
    error('number of parameters should be times of 2')
end

name_dic = {'lbp', 'rd', 'ad', 'concat', 'conding', 'binary', 'sort',...
    'split', 'kmeans'};

for i = 1: number_pair
    name = varargin{2 * (i - 1) + 1};
    if(~ismember(name, name_dic))
        error('come across a unknown name field ''%s\''\n', name);
    end
    pair.(varargin{2 * i - 1}) = varargin{2 * i};
end
    



