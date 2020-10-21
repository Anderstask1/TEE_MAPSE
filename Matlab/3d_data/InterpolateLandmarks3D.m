function [landmarkSplineCurve, landmarkBezierCurve] = InterpolateLandmarks3D(landmark3DMatrix, frameNo)

    %% Init
    landmarkSplineCurve = cscvn(0);
    
    % Bezier: number of points - resolution
    U=0:0.0005:1;
    landmarkBezierCurve = zeros(size(U, 2), 3, frameNo);

    %% Iterate over all frames
    for f = 1 : frameNo
        %get x, y, z values of all landmarks
        xyz = landmark3DMatrix(:,:,f);
        
        %remove all nan values
        xyz(:,isnan(xyz(1,:))) = [];
        xyz(:,isnan(xyz(2,:))) = [];
        xyz(:,isnan(xyz(3,:))) = [];
        
        %% interpolating cubic spline curve
        landmarkSplineCurve(f) = cscvn(xyz(:,[1:end 1]));
      
        %% Interpolating Bezier
        
        %control points
        cp = cell(3,1);
        for i = 1 : size(xyz,2)
           cp{i} = xyz(:,i); 
        end
        
        %add start points on end of control points array to make it
        %circular
%         for i = 1 : 5
%             cp{size(xyz,2) + i} = xyz(:,i);
%         end
        cp{size(xyz,2) + 1} = xyz(:,1);
        
        %bezier curve points
        [Xout,Yout,Zout] = BezierCurve(cp,U);
        landmarkBezierCurve(:,:,f) = [Xout,Yout,Zout];
        
    end
end