close all; figure

blueColor = [0, 0.4470, 0.7410];
orangeColor = [0.8500, 0.3250, 0.0980];
yellowColor = [0.9290, 0.6940, 0.1250];
greenColor = [0.4660, 0.6740, 0.1880];
grayColor = [17,17,17]/255;

[x,y,z] = cylinder(0:5);

%surf(x,y,-z, 'FaceAlpha',0, 'EdgeAlpha',1.0, 'LineWidth', 2.0);

hold on

plot3(2,3,-0.5, 'ro','MarkerSize',15,'MarkerFaceColor','r');
plot3(-2,3,-0.5, 'ro','MarkerSize',15,'MarkerFaceColor','r');

% patch([0,0,0,0],[-5,-5,5,5],[-1,0,0, -1],'w','FaceColor',orangeColor,'FaceAlpha',0.3);
%patch([-3,-3,3,3],[-5,-5,5,5],[-1,0,0, -1],'w','FaceColor',orangeColor,'FaceAlpha',0.3);
% patch([-1,-1,1,1],[-5,-5,5,5],[-1,0,0, -1],'w','FaceColor',grayColor,'FaceAlpha',0.3);
% patch([1,1,-1,-1],[-5,-5,5,5],[-1,0,0, -1],'w','FaceColor',grayColor,'FaceAlpha',0.3);
% patch([3,3,-3,-3],[-5,-5,5,5],[-1,0,0, -1],'w','FaceColor',orangeColor,'FaceAlpha',0.3);

% patch([1,0,0,1],[5,5,-5,-5],[-1,0,0, -1],'w','FaceColor',grayColor,'FaceAlpha',0.3);
% patch([3,0,0,3],[-5,-5,5,5],[-1,0,0, -1],'w','FaceColor',grayColor,'FaceAlpha',0.3);
% patch([5,0,0,5],[-5,-5,5,5],[-1,0,0, -1],'w','FaceColor',orangeColor,'FaceAlpha',0.3);
% 
% patch([-1,0,0,-1],[5,5,-5,-5],[-1,0,0, -1],'w','FaceColor',orangeColor,'FaceAlpha',0.3);
% patch([-3,0,0,-3],[-5,-5,5,5],[-1,0,0, -1],'w','FaceColor',orangeColor,'FaceAlpha',0.3);
%patch([-5,0,0,-5],[-5,-5,5,5],[-1,0,0, -1],'w','FaceColor',grayColor,'FaceAlpha',0.3);

%patch([4,0,0,4],[5,5,-5,-5],[-1,0,0, -1],'w','FaceColor',orangeColor,'FaceAlpha',0.5);

xAxis = [[0,-5,0]; [0,5,0]];
yAxis = [[-5,0,0]; [5,0,0]];
zAxis = [[0,0,0]; [0,0,-1]];

plot3(xAxis(:,1), xAxis(:,2), xAxis(:,3), 'Color', 'k', 'LineWidth', 4)
plot3(yAxis(:,1), yAxis(:,2), yAxis(:,3), 'Color', 'k', 'LineWidth', 4)
plot3(zAxis(:,1), zAxis(:,2), zAxis(:,3), 'Color', 'k', 'LineWidth', 4)

axis off
grid on
view([130,40])
xlabel('x-axis')
ylabel('y-axis')
zlabel('z-axis')