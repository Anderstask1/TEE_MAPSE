function rejectedLandmark3DMatrix = LandmarkOutlierRejection3D(landmark3DMatrix, landmarkBezierCurve, frameNo, pixelCorr)
     %init rejected landmark matrix
     rejectedLandmark3DMatrix = nan(size(landmark3DMatrix));
     
     % Iterate over all frames
    for f = 1 : frameNo
        
        % Compute distance between landmark and Bezier
        for i = 1 : size(landmark3DMatrix, 2)

            %skip if landmark is nan
            if ~isnan(landmark3DMatrix(:,i,f))
            
                %init dist bigger than possible dists
                shortDist = 100000;

                for j = 1 : size(landmarkBezierCurve, 1)
                    dist = pixelCorr * norm(landmark3DMatrix(:,i,f) - landmarkBezierCurve(j,:,f)');%dist in mm
                    if dist < shortDist
                        shortDist = dist;
                    end
                end
                
                %add point if dist less than * mm
                if shortDist < 0.01
                    rejectedLandmark3DMatrix(:,i,f) = landmark3DMatrix(:,i,f);
                end
            end
        end
    end
end