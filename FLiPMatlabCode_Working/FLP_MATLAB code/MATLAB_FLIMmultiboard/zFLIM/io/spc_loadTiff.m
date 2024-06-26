function spc_loadTiff (fname, page);
global spc;

if nargin < 2
    page = 1;
end


finfo = imfinfo (fname);
header = finfo(1).ImageDescription;

if length(finfo) < page
    page = length(finfo);
end
if findstr(header, 'spc')
    evalc(header);
    image1 = double(imread(fname, page));
else
    disp('This is not a spc file !!');
end

spc.filename = fname;
spc.page = page;

% frames = length(imfinfo(fname));
% for i = 1:frames
%     image (i, :, :) = double(imread(fname, i));
% end

 spc.size = [spc.size(1), spc.SPCdata.scan_size_y, spc.SPCdata.scan_size_x];
 siz = spc.size;
 spc.imageMod = reshape(image1, siz);
 spc.project = reshape(sum(image1, 1), spc.size(2), spc.size(3));
 %spc.image = sparse(reshape(image, spc.size(1), spc.size(2)*spc.size(3)));
 %spc.imageMod = spc.image;
% 
% 
% spc.size = size(spc.image);
% 
% spc.switches.imagemode = 1;
% spc.switches.lutlim = [50, 300];
% spc.switches.logscale = 1;
% spc.switches.peak = [-1, 4];
% spc.switches.lifetime_limit = [0.5, 5];
% 
% spc.fit.range = [1, spc.size(2)];
