function [totalArea,areas, centroid] = surfarea(varargin)
% SURFAREA  Estimate surface area of a surface or mesh.
% 
%   [totalArea, areas, centroid] = surfarea(x,y,z)
%   [totalArea, areas, centroid] = surfarea(h)
% 
%     totalArea - Estimate of total area of the surface.
%     areas     - Estimate of area of each cell.
%     centroid  - Estimate of area centroid of the surface.
% 
%     x,y,z     - Surface coordinates.
%     h         - Handle to a Surface object (XData, YData, and ZData properties
%                 are used for x, y, and z).
% 
%   If a handle is provided, totalArea and areas are set as fields of
%   h.UserData.
% 
%   Example 2: Plot peaks, coloring each cell with its own area.
%     [x,y,z] = peaks;
%     [area,cellAreas] = surfarea(x,y,z);
% 
%     h = surf(x,y,z,cellAreas); axis image
%     title(sprintf('Total surface area: %.2f', surfarea(h)));
%     
%   See also surf, surface, mesh.

%   Copyright 2017 Sky Sartorius
%   Contact: www.mathworks.com/matlabcentral/fileexchange/authors/101715

%   Method from www.mathworks.com/matlabcentral/answers/93117.

%% Parse inputs.
narginchk(1,3);
if nargin == 3 
    % [x,y,z] = disperse(varargin);
    x = varargin{1};
    y = varargin{2};
    z = varargin{3};
elseif nargin == 1
    % Asssume matlab.graphics.primitive.Surface
    h = varargin{1};
    x = h.XData;
    y = h.YData;
    z = h.ZData;
else
    error('surfarea accepts exactly one or three inputs.')
end

if isvector(x) && isvector(y)
    [x,y] = meshgrid(x,y);
end

if ~isequal(size(x),size(y),size(z))
    error('x, y, and z must all be the same size.')
end

%% Calculate area.
v0 = cat(3, x(1:end-1,1:end-1), y(1:end-1,1:end-1), z(1:end-1,1:end-1));
v1 = cat(3, x(1:end-1,2:end  ), y(1:end-1,2:end  ), z(1:end-1,2:end  ));
v2 = cat(3, x(2:end  ,1:end-1), y(2:end  ,1:end-1), z(2:end  ,1:end-1));
v3 = cat(3, x(2:end  ,2:end  ), y(2:end  ,2:end  ), z(2:end  ,2:end  ));

a = v1 - v0;
b = v2 - v0;
c = v3 - v0;

A1 = cross(a,c,3);
A2 = cross(b,c,3);

A1 = sqrt(sum(A1.^2,3))/2;
A2 = sqrt(sum(A2.^2,3))/2;

areas = A1 + A2;
totalArea = sum(areas(:));

%% Centroid.
% Mean position of each triangle, weighted by area.
PW = ((v0 + v1 + v3)/3.*A1 + (v0 + v2 + v3)/3.*A2 )/totalArea;

centroid = sum(reshape(PW,numel(areas),3));

%% 
if exist('h','var')
    h.UserData.totalArea = totalArea;
    h.UserData.areas = areas;
    h.UserData.centroid = centroid;
end