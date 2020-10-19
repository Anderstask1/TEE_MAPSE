function [com_left_corr, com_right_corr] = RotationCorrection3D(mapseLeft3DMatrix, mapseRight3DMatrix, es_frame, ed_frame, frameNo, pixelCorr)
    
    %% -------------------- LEFT --------------------
    %% Find CoM in ES and ED 
    
    %CoM computation
    com_es_left = [nanmean(mapseLeft3DMatrix(1,:,es_frame));
                   nanmean(mapseLeft3DMatrix(2,:,es_frame));
                   nanmean(mapseLeft3DMatrix(3,:,es_frame));
                   1];
    
    com_ed_left = [nanmean(mapseLeft3DMatrix(1,:,ed_frame));
                   nanmean(mapseLeft3DMatrix(2,:,ed_frame));
                   nanmean(mapseLeft3DMatrix(3,:,ed_frame));
                   1];
    
    %% Translation and rotation
    %translation to CoM in ES (set as origin)
    translate_com_es_left = [
              1 0 0 com_es_left(1)
              0 1 0 com_es_left(2)
              0 0 1 com_es_left(3)
              0 0 0 1
            ];
    
    %CoM coordinates after translation
    com_ed_left_trans = translate_com_es_left\com_ed_left;%inv(translate_com_es_left) * com_ed_left
        
    %rotation around x-axis to lie ED CoM on xz-plane
    theta = atan(com_ed_left_trans(2)/com_ed_left_trans(3));
    
    rotate_com_x = [
                 1  0            0           0
                 0  cos(theta)   -sin(theta) 0
                 0  sin(theta)   cos(theta)  0  
                 0  0            0           1
                 ];
    
    %CoM coordinates after translation and rotation about x-axis
    com_ed_left_trans_rot = rotate_com_x * com_ed_left_trans;
             
    %rotate around y-axis to lie ED CoM on z-axis
    alpha = - atan(com_ed_left_trans_rot(1)/com_ed_left_trans_rot(3));
    
    rotate_com_y = [
             cos(alpha)  0  sin(alpha)  0
             0           1  0           0
             -sin(alpha) 0  cos(alpha)  0  
             0           0  0           1
             ];         
    
    %transformation matrix
    mv_trf = rotate_com_y * rotate_com_x / translate_com_es_left;
    
    %corrected coordinates for CoM of mapse landmarks 
    com_left_corr = zeros(3, frameNo);
    
    %rotation correction on all mapse landmarks
    for j = 1 : frameNo
        %CoM for left mapse landmark - frame j
        com_left = [nanmean(mapseLeft3DMatrix(1,:,j));
                   nanmean(mapseLeft3DMatrix(2,:,j));
                   nanmean(mapseLeft3DMatrix(3,:,j));
                   1];
        
        %transform according to rotation correction - heart expansion along z-axis
        com_left_trf = mv_trf * com_left;
        
        %cartesian coordinates
        com_left_trf(end) = [];
        
        com_left_corr(:, j) = pixelCorr .* com_left_trf;       
         
    end
    
    %% -------------------- RIGHT --------------------    
    %% Find CoM in ES and ED 
    
    %CoM computation
    com_es_right = [nanmean(mapseRight3DMatrix(1,:,es_frame));
                   nanmean(mapseRight3DMatrix(2,:,es_frame));
                   nanmean(mapseRight3DMatrix(3,:,es_frame));
                   1];
               
    com_ed_right = [nanmean(mapseRight3DMatrix(1,:,ed_frame));
                   nanmean(mapseRight3DMatrix(2,:,ed_frame));
                   nanmean(mapseRight3DMatrix(3,:,ed_frame));
                   1];
    
    %% Translation and rotation
    %translation to CoM in ES (set as origin)
    translate_com_es_right = [
              1 0 0 com_es_right(1)
              0 1 0 com_es_right(2)
              0 0 1 com_es_right(3)
              0 0 0 1
            ];
    
    %CoM coordinates after translation
    com_ed_right_trans = translate_com_es_right \ com_ed_right;
        
    %rotation around x-axis to lie ED CoM on xz-plane
    theta = atan(com_ed_right_trans(2)/com_ed_right_trans(3));
    
    rotate_com_x = [
                 1  0            0           0
                 0  cos(theta)   -sin(theta) 0
                 0  sin(theta)   cos(theta)  0  
                 0  0            0           1
                 ];
    
    %CoM coordinates after translation and rotation about x-axis
    com_ed_right_trans_rot = rotate_com_x * com_ed_right_trans;
             
    %rotate around y-axis to lie ED CoM on z-axis
    alpha = - atan(com_ed_right_trans_rot(1)/com_ed_right_trans_rot(3));
    
    rotate_com_y = [
             cos(alpha)  0  sin(alpha)  0
             0           1  0           0
             -sin(alpha) 0  cos(alpha)  0  
             0           0  0           1
             ];         
    
    %transformation matrix
    mv_trf = rotate_com_y * rotate_com_x / translate_com_es_right;
    
    %corrected coordinates for CoM of mapse landmarks 
    com_right_corr = zeros(3, frameNo);
    
    %rotation correction on all mapse landmarks
    for j = 1 : frameNo
        %CoM for right mapse landmark - frame j
        com_right = [nanmean(mapseRight3DMatrix(1,:,j));
                   nanmean(mapseRight3DMatrix(2,:,j));
                   nanmean(mapseRight3DMatrix(3,:,j));
                   1];
               
        %transform according to rotation correction - heart expansion along z-axis
        com_right_trf = mv_trf * com_right;
        
        %cartesian coordinates
        com_right_trf(end) = [];
        
        com_right_corr(:, j) = pixelCorr .* com_right_trf;
         
    end
end