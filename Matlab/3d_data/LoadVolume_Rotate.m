close all

patientNo = 18
visualDebug = true;

switch patientNo
    %BATCH3
    case 101
        %patient 1
        inputName1 = 'c:\NewData_NLM\DataStOlavs1-8\Converted\gr4_STolav1to4/p3122153/J1ECAT8E_NLMF.h5';
        inputName2 = 'c:\NewData_NLM\DataStOlavs1-8\Converted\gr4_STolav1to4/p3122153/J1ECAT8G_NLMF.h5';
        thetaDegree = -135;
    case 102
        %patient 1
        inputName1 = 'c:\NewData_NLM\DataStOlavs1-8\Converted\gr4_STolav1to4/p3122153/J1ECAT8I_NLMF.h5';
        inputName2 = 'c:\NewData_NLM\DataStOlavs1-8\Converted\gr4_STolav1to4/p3122153/J1ECAT8I_NLMF.h5';
        thetaDegree = -135;

    case 201
        %patient 1
        inputName1 = 'c:\NewData_NLM\DataStOlavs1-8\Converted\gr4_STolav1to4/p3122154/J1ECATI6_NLMF.h5';
        inputName2 = 'c:\NewData_NLM\DataStOlavs1-8\Converted\gr4_STolav1to4/p3122154/J1ECATI8_NLMF.h5';
        thetaDegree = 135;
        
    case 202
        %patient 1
        inputName1 = 'c:\NewData_NLM\DataStOlavs1-8\Converted\gr4_STolav1to4/p3122154/J1ECATIA_NLMF.h5';
        inputName2 = 'c:\NewData_NLM\DataStOlavs1-8\Converted\gr4_STolav1to4/p3122154/J1ECATIC_NLMF.h5';
        thetaDegree = 135;
    
    case 203
        %patient 1
        inputName1 = 'c:\NewData_NLM\DataStOlavs1-8\Converted\gr4_STolav1to4/p3122154/J1ECATIE_NLMF.h5';
        inputName2 = 'c:\NewData_NLM\DataStOlavs1-8\Converted\gr4_STolav1to4/p3122154/J1ECATIG_NLMF.h5';
        thetaDegree = 135;

    case 301
        %patient 1
        inputName1 = 'c:\NewData_NLM\DataStOlavs1-8\Converted\gr4_STolav1to4/p3122155/J1ECATQ2_NLMF.h5';
        inputName2 = 'c:\NewData_NLM\DataStOlavs1-8\Converted\gr4_STolav1to4/p3122155/J1ECATQ6_NLMF.h5';
        thetaDegree = 45;
        
    case 302
        %patient 1
        inputName1 = 'c:\NewData_NLM\DataStOlavs1-8\Converted\gr4_STolav1to4/p3122155/J1ECATQ8_NLMF.h5';
        inputName2 = 'c:\NewData_NLM\DataStOlavs1-8\Converted\gr4_STolav1to4/p3122155/J1ECATQA_NLMF.h5';
        thetaDegree = 45;
    
    case 401
        %patient 1
        inputName1 = 'c:\NewData_NLM\DataStOlavs1-8\Converted\gr4_STolav1to4/p3122156/J1ECAU12_NLMF.h5';
        inputName2 = 'c:\NewData_NLM\DataStOlavs1-8\Converted\gr4_STolav1to4/p3122156/J1ECAU2M_NLMF.h5';
        thetaDegree = 20;
        
    case 402
        %patient 1
        inputName1 = 'c:\NewData_NLM\DataStOlavs1-8\Converted\gr4_STolav1to4/p3122156/J1ECAU2O_NLMF.h5';
        inputName2 = 'c:\NewData_NLM\DataStOlavs1-8\Converted\gr4_STolav1to4/p3122156/J1ECAU2Q_NLMF.h5';
        thetaDegree = 20;
    
    case 403
        %patient 1
        inputName1 = 'c:\NewData_NLM\DataStOlavs1-8\Converted\gr4_STolav1to4/p3122156/J1ECAU2S_NLMF.h5';
        inputName2 = 'c:\NewData_NLM\DataStOlavs1-8\Converted\gr4_STolav1to4/p3122156/J1ECAU2S_NLMF.h5';
        thetaDegree = 20;


    case 501
        %patient 1
        inputName1 = 'c:\NewData_NLM\DataStOlavs1-8\Converted\gr5_STolav5to8/p5_3d/J249J6IU_NLMF.h5';
        inputName2 = 'c:\NewData_NLM\DataStOlavs1-8\Converted\gr5_STolav5to8/p5_3d/J249J6J0_NLMF.h5';
        thetaDegree = -40;
        
    case 502
        %patient 1
        inputName1 = 'c:\NewData_NLM\DataStOlavs1-8\Converted\gr5_STolav5to8/p5_3d/J249J6J2_NLMF.h5';
        inputName2 = 'c:\NewData_NLM\DataStOlavs1-8\Converted\gr5_STolav5to8/p5_3d/J249J6J4_NLMF.h5';
        thetaDegree = -40;

    case 601
        %patient 1
        inputName1 = 'c:\NewData_NLM\DataStOlavs1-8\Converted\gr5_STolav5to8/p6_3d/J249J6QO_NLMF.h5';
        inputName2 = 'c:\NewData_NLM\DataStOlavs1-8\Converted\gr5_STolav5to8/p6_3d/J249J6QQ_NLMF.h5';
        thetaDegree = -40;
        
    case 602
        %patient 1
        inputName1 = 'c:\NewData_NLM\DataStOlavs1-8\Converted\gr5_STolav5to8/p6_3d/J249J6R0_NLMF.h5';
        inputName2 = 'c:\NewData_NLM\DataStOlavs1-8\Converted\gr5_STolav5to8/p6_3d/J249J6R0_NLMF.h5';
        thetaDegree = -40;
        
    case 701
        %patient 1
        inputName1 = 'c:\NewData_NLM\DataStOlavs1-8\Converted\gr5_STolav5to8/p7_3d/J249J70E_NLMF.h5';
        inputName2 = 'c:\NewData_NLM\DataStOlavs1-8\Converted\gr5_STolav5to8/p7_3d/J249J70G_NLMF.h5';
        thetaDegree = 45;
        
    case 702
        %patient 1
        inputName1 = 'c:\NewData_NLM\DataStOlavs1-8\Converted\gr5_STolav5to8/p7_3d/J249J70I_NLMF.h5';
        inputName2 = 'c:\NewData_NLM\DataStOlavs1-8\Converted\gr5_STolav5to8/p7_3d/J249J70K_NLMF.h5';
        thetaDegree = 45;

    case 703
        %patient 1
        inputName1 = 'c:\NewData_NLM\DataStOlavs1-8\Converted\gr5_STolav5to8/p7_3d/J249J70M_NLMF.h5';
        inputName2 = 'c:\NewData_NLM\DataStOlavs1-8\Converted\gr5_STolav5to8/p7_3d/J249J70M_NLMF.h5';
        thetaDegree = 45;

    case 801
        %patient 1
        inputName1 = 'c:\NewData_NLM\DataStOlavs1-8\Converted\gr5_STolav5to8/p8_3d/J249J79K_NLMF.h5';
        inputName2 = 'c:\NewData_NLM\DataStOlavs1-8\Converted\gr5_STolav5to8/p8_3d/J249J79M_NLMF.h5';
        thetaDegree = -90;
        
    case 802
        %patient 1
        inputName1 = 'c:\NewData_NLM\DataStOlavs1-8\Converted\gr5_STolav5to8/p8_3d/J249J79O_NLMF.h5';
        inputName2 = 'c:\NewData_NLM\DataStOlavs1-8\Converted\gr5_STolav5to8/p8_3d/J249J79Q_NLMF.h5';
        thetaDegree = -90;

    case 803
        %patient 1
        inputName1 = 'c:\NewData_NLM\DataStOlavs1-8\Converted\gr5_STolav5to8/p8_3d/J249J79S_NLMF.h5';
        inputName2 = 'c:\NewData_NLM\DataStOlavs1-8\Converted\gr5_STolav5to8/p8_3d/J249J79S_NLMF.h5';
        thetaDegree = -90;
        
    %BATCH 1    
    case 9
        %patient 9
        inputName1 = 'c:\NewData_NLM\DataStOlavs9-18\Converted\p09_3191404\J44J7124_ecg_NLMF.h5';
        inputName2 = 'c:\NewData_NLM\DataStOlavs9-18\Converted\p09_3191404\J44J712A_ecg_NLMF.h5';
        thetaDegree = -91;
        
    case 10
        %patient 10
        inputName1 = 'c:\NewData_NLM\DataStOlavs9-18\Converted\p10_3191405\J44J71A4_ecg_NLMF.h5';
        inputName2 = 'c:\NewData_NLM\DataStOlavs9-18\Converted\p10_3191405\J44J71AG_ecg_NLMF.h5';
        thetaDegree = -110;
        
    case 11
        %patient 11
        inputName1 = 'c:\NewData_NLM\DataStOlavs9-18\Converted\p11_3191406/J44J71GE_ecg_NLMF.h5';
        inputName2 = 'c:\NewData_NLM\DataStOlavs9-18\Converted\p11_3191406/J44J71GK_ecg_NLMF.h5';
        thetaDegree = -130;

    case 12
        %patient 12
        inputName1 = 'c:\NewData_NLM\DataStOlavs9-18\Converted\p12_3191407/J44J71Q0_ecg_NLMF.h5';
        inputName2 = 'c:\NewData_NLM\DataStOlavs9-18\Converted\p12_3191407/J44J71Q2_ecg_NLMF.h5';
        thetaDegree = -90;

    case 13
        %patient 13
        inputName1 = 'c:\NewData_NLM\DataStOlavs9-18\Converted\p13_3191408/J44J721U_ecg_NLMF.h5';
        inputName2 = 'c:\NewData_NLM\DataStOlavs9-18\Converted\p13_3191408/J44J7220_ecg_NLMF.h5';
        thetaDegree = 15;

    case 14
        %patient 14
        inputName1 = 'c:\NewData_NLM\DataStOlavs9-18\Converted\p14_3191409\J44J729S_ecg_NLMF.h5';
        inputName2 = 'c:\NewData_NLM\DataStOlavs9-18\Converted\p14_3191409\J44J72A0_ecg_NLMF.h5';
        thetaDegree = 0;
        
    case 15
        %patient 15
        inputName1 = 'c:\NewData_NLM\DataStOlavs9-18\Converted\p15_3191410/J44J72HU_ecg_NLMF.h5';
        inputName2 = 'c:\NewData_NLM\DataStOlavs9-18\Converted\p15_3191410/J44J72I4_ecg_NLMF.h5';
        thetaDegree = 15;
        
    case 16
        %patient 16
        inputName1 = 'c:\NewData_NLM\DataStOlavs9-18\Converted\p16_3191411/J44J72Q6_ecg_NLMF.h5';
        inputName2 = 'c:\NewData_NLM\DataStOlavs9-18\Converted\p16_3191411/J44J72Q8_ecg_NLMF.h5';
        thetaDegree = 15;
    
    case 17
        %patient 17
        inputName1 = 'c:\NewData_NLM\DataStOlavs9-18\Converted\p17_3191412/J44J730I_ecg_NLMF.h5';
        inputName2 = 'c:\NewData_NLM\DataStOlavs9-18\Converted\p17_3191412/J44J730K_ecg_NLMF.h5';
        thetaDegree = 20;

    case 18
        %patient 18
        inputName1 = 'c:\NewData_NLM\DataStOlavs9-18\Converted\p18_3191413/J44J73AG_ecg_NLMF.h5';
        inputName2 = 'c:\NewData_NLM\DataStOlavs9-18\Converted\p18_3191413/J44J73AI_ecg_NLMF.h5';
        thetaDegree = -115;
    %BATCH 2    
    case 19
        %patient 19
        inputName1 = 'c:\NewData_NLM\DataStOlavs19-28\Converted\p19_3115004/J65BP12E_ecg_NLMF.h5';
        inputName2 = 'c:\NewData_NLM\DataStOlavs19-28\Converted\p19_3115004/J65BP12G_ecg_NLMF.h5';
        thetaDegree = -10;
    case 20
        %patient 20
        inputName1 = 'c:\NewData_NLM\DataStOlavs19-28\Converted\p20_3115005/J65BP1A0_ecg_NLMF.h5';
        inputName2 = 'c:\NewData_NLM\DataStOlavs19-28\Converted\p20_3115005/J65BP1A4_ecg_NLMF.h5';
        thetaDegree = 5;
    case 21
        %patient 21
        inputName1 = 'c:\NewData_NLM\DataStOlavs19-28\Converted\p21_3115006/J65BP1I4_ecg_NLMF.h5';
        inputName2 = 'c:\NewData_NLM\DataStOlavs19-28\Converted\p21_3115006/J65BP1I6_ecg_NLMF.h5';
        thetaDegree = 5;
    case 22
        %patient 22
        inputName1 = 'c:\NewData_NLM\DataStOlavs19-28\Converted\p22_3115007/J65BP1R0_ecg_NLMF.h5';
        inputName2 = 'c:\NewData_NLM\DataStOlavs19-28\Converted\p22_3115007/J65BP1R2_ecg_NLMF.h5';
        thetaDegree = 20;
    case 23
        %patient 23
        inputName1 = 'c:\NewData_NLM\DataStOlavs19-28\Converted\p23_3115008/J65BP22K_ecg_NLMF.h5';
        inputName2 = 'c:\NewData_NLM\DataStOlavs19-28\Converted\p23_3115008/J65BP22M_ecg_NLMF.h5';
        thetaDegree = -45;
    case 24
        %patient 24
        inputName1 = 'c:\NewData_NLM\DataStOlavs19-28\Converted\p24_3115009/J65BP2AQ_ecg_NLMF.h5';
        inputName2 = 'c:\NewData_NLM\DataStOlavs19-28\Converted\p24_3115009/J65BP2B0_ecg_NLMF.h5';
        thetaDegree = 40;
    case 25
        %patient 25
        inputName1 = 'c:\NewData_NLM\DataStOlavs19-28\Converted\p25_3115010/J65BP2IQ_ecg_NLMF.h5';
        inputName2 = 'c:\NewData_NLM\DataStOlavs19-28\Converted\p25_3115010/J65BP2IU_ecg_NLMF.h5';
        thetaDegree = 35;
    case 26
        %patient 26
        inputName1 = 'c:\NewData_NLM\DataStOlavs19-28\Converted\p26_3115011/J65BP2QK_ecg_NLMF.h5';
        inputName2 = 'c:\NewData_NLM\DataStOlavs19-28\Converted\p26_3115011/J65BP2QM_ecg_NLMF.h5';
        thetaDegree = -115;
    case 27
        %patient 27
        inputName1 = 'c:\NewData_NLM\DataStOlavs19-28\Converted\p27_3115012/J65BP338_ecg_NLMF.h5';
        inputName2 = 'c:\NewData_NLM\DataStOlavs19-28\Converted\p27_3115012/J65BP33A_ecg_NLMF.h5';
        thetaDegree = 20;
    case 28
        %patient 28
        inputName1 = 'c:\NewData_NLM\DataStOlavs19-28\Converted\p28_3115013/J65BP3A4_ecg_NLMF.h5';
        inputName2 = 'c:\NewData_NLM\DataStOlavs19-28\Converted\p28_3115013/J65BP3A8_ecg_NLMF.h5';
        thetaDegree = -125;
        

end


%generate output name
outputName1 = replace(inputName1, "Converted", "Rotated");
outputName2 = replace(inputName2, "Converted", "Rotated");

%create output dir
[pathstr, name, ext] = fileparts(outputName1);
mkdir(pathstr)

%rotate and save file
RotateYFile3D(inputName1, outputName1, thetaDegree, visualDebug)
RotateYFile3D(inputName2, outputName2, thetaDegree, visualDebug)
