function [Xout,Yout,Zout] = BezierCurve(cp,U)
%
% Fast calculation of the point cloud of a Bezier curve
%
% [#Xout#,#Yout#,#Zout#] = BezierCurve(#cp#,#U#)
%
% Input parameters
%     #cp# ({#n# x #m#}) is a cell containing the control points of the
%         Bezier surface.
%     #U# ([#nU# x 1]) is a vector containing the points (x,y,z) at which
%         the Bezier curve is plotted). max(#U#) must be <=1.
%
% Output parameters
%     #Xout# ([#nU# x #nV#]) is the X-coordinates of the points of teh
%         Bezier surface.
%     #Yout# ([#nU# x #nV#]) is the Y-coordinates of the points of teh
%         Bezier surface.
%     #Zout# ([#nU# x #nV#]) is the Z-coordinates of the points of teh
%         Bezier surface.
%
% Example
%     % Bézier curve of degree n is defined by a set of (n + 1) control
%     % points ki (n=2)
%     % Control points [x,y,z]
%     cp=cell(3,1);
%     cp{1,1}=[ 0.0, 0.0, 65.0];
%     cp{2,1}=[ 50.8, 0.0, 50.0];
%     cp{3,1}=[ 101.6, 0.0, 85.0];
%     % Plotting vector (2001 points)
%     U=0:0.0005:1;
%     [Xout,Yout,Zout] = BezierCurve(cp,U);
%     % plot
%     scatter3(Xout(:),Yout(:),Zout(:))
%
%__________________________________________________________________________
% Copyright (c) 2018
%     George Papazafeiropoulos
%     Captain, Infrastructure Engineer, Hellenic Air Force
%     Civil Engineer, M.Sc., Ph.D. candidate, NTUA
%     Email: gpapazafeiropoulos@yahoo.gr
% _________________________________________________________________________


%% Initial checks
m=size(cp,1);
m=m-1;
p=numel(U);
% initialize
X=zeros(p,m+1);
Y=zeros(p,m+1);
Z=zeros(p,m+1);
k=1;
for j=0:m
    mjF=factorial(m)/(factorial(j)*factorial(m-j));
    Bjm=mjF*U.^j.*(1-U).^(m-j);
    X(:,k)=Bjm.*cp{j+1,1}(1);
    Y(:,k)=Bjm.*cp{j+1,1}(2);
    Z(:,k)=Bjm.*cp{j+1,1}(3);
    k=k+1;
end
Xout=sum(X,2);
Yout=sum(Y,2);
Zout=sum(Z,2);
end

