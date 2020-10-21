function [Xout,Yout,Zout] = BezierSurface(cp,U,V)
%
% Fast calculation of the point cloud of a Bezier surface
%
% [#Xout#,#Yout#,#Zout#] = BezierSurface(#cp#,#U#,#V#)
%
% Input parameters
%     #cp# ({#n# x #m#}) is a cell containing the control points of the
%         Bezier surface.
%     #U# ([1 x #nU#]) is a vector containing the values in the 1-direction
%         (the first dimension of the matrix of points (x,y) at which the
%         Bezier surface is plotted). max(#U#) must be <=1.
%     #V# ([1 x #nV#]) is a vector containing the values in the 2-direction
%         (the second dimension of the matrix of points (x,y) at which the
%         Bezier surface is plotted). max(#V#) must be <=1.
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
%     % Bézier surface of degree (n, m) is defined by a set of (n + 1)(m + 1)
%     % control points ki,j
%     % Control points [x,y,z]
%     cp=cell(3,3);
%     cp{1,1}=[ 0.0, 0.0, 65.0];
%     cp{1,2}=[ 0.0, 76.2, 100.0];
%     cp{1,3}=[ 0.0, 152.4, 85.0];
%     cp{2,1}=[ 50.8, 0.0, 50.0];
%     cp{2,2}=[ 50.8, 76.2, 95.0];
%     cp{2,3}=[ 50.8, 152.4, 65.0];
%     cp{3,1}=[ 101.6, 0.0, 85.0];
%     cp{3,2}=[ 101.6, 76.2, 70.0];
%     cp{3,3}=[ 101.6, 152.4, 85.0];
%     % Plotting vectors
%     U=0:0.005:1; % 1-direction (201 points)
%     V=0:0.005:1; % 2-direction (201 points)
%     [Xout,Yout,Zout] = BezierSurface(cp,U,V);
%     % plot (40401 points)
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
[n,m]=size(cp);
n=n-1; % 1-direction
m=m-1; % 2-direction
% convert plotting vectors into matrices
p1=numel(V);
p2=numel(U);
V=repmat(V,p2,1);
U=repmat(U',1,p1);
% initialize
X=zeros(p2,p1,(n+1)*(m+1));
Y=zeros(p2,p1,(n+1)*(m+1));
Z=zeros(p2,p1,(n+1)*(m+1));
k=1;
for i=0:n
    for j=0:m
        niF=factorial(n)/(factorial(i)*factorial(n-i));
        Bin=niF*V.^i.*(1-V).^(n-i);
        mjF=factorial(m)/(factorial(j)*factorial(m-j));
        Bjm=mjF*U.^j.*(1-U).^(m-j);
        X(:,:,k)=Bin.*Bjm.*cp{i+1,j+1}(1);
        Y(:,:,k)=Bin.*Bjm.*cp{i+1,j+1}(2);
        Z(:,:,k)=Bin.*Bjm.*cp{i+1,j+1}(3);
        k=k+1;
    end
end
Xout=sum(X,3);
Yout=sum(Y,3);
Zout=sum(Z,3);
end

