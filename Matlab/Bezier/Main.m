% Plot a Bezier curve and a Bezier surface on a 3D graph with given control
% points

% Bézier curve of degree n is defined by a set of (n + 1) control
% points ki (n=2)
% Control points [x,y,z]
cp=cell(3,1);
cp{1,1}=[ 0.0, 0.0, 65.0];
cp{2,1}=[ 50.8, 0.0, 50.0];
cp{3,1}=[ 101.6, 0.0, 85.0];
% Plotting vector (2001 points)
U=0:0.0005:1;
[Xout,Yout,Zout] = BezierCurve(cp,U);
% plot (2001 points)
figure()
scatter3(Xout(:),Yout(:),Zout(:))


% Bézier surface of degree (n, m) is defined by a set of (n + 1)(m + 1)
% control points ki,j
% Control points [x,y,z]
cp=cell(3,3);
cp{1,1}=[ 0.0, 0.0, 65.0];
cp{1,2}=[ 0.0, 76.2, 100.0];
cp{1,3}=[ 0.0, 152.4, 85.0];
cp{2,1}=[ 50.8, 0.0, 50.0];
cp{2,2}=[ 50.8, 76.2, 95.0];
cp{2,3}=[ 50.8, 152.4, 65.0];
cp{3,1}=[ 101.6, 0.0, 85.0];
cp{3,2}=[ 101.6, 76.2, 70.0];
cp{3,3}=[ 101.6, 152.4, 85.0];
% Plotting vectors
U=0:0.005:1; % 1-direction (201 points)
V=0:0.005:1; % 2-direction (201 points)
[Xout,Yout,Zout] = BezierSurface(cp,U,V);
% plot (40401 points)
figure()
scatter3(Xout(:),Yout(:),Zout(:))


%
%__________________________________________________________________________
% Copyright (c) 2018
%     George Papazafeiropoulos
%     Captain, Infrastructure Engineer, Hellenic Air Force
%     Civil Engineer, M.Sc., Ph.D. candidate, NTUA
%     Email: gpapazafeiropoulos@yahoo.gr
% _________________________________________________________________________
