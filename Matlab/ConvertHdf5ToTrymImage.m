
fileOslo = 'D:\dl\MAPSE\Data\test\KWA03_70.h5'

fileTrym = 'd:\dl\MAPSE\Data\test_trym\p123_4c.h5'

%load dataset
hdfdataOslo = HdfImport(fileOslo);
hdfdataTrym = HdfImport(fileTrym);


szOslo = size(hdfdataOslo.tissue.data)
szTrym = size(hdfdataTrym.images)


%used to generate some fake references
r = hdfdataTrym.reference(:,1);
fakeRef = repmat(r,1, szOslo(1));

%rearrange data
d = permute(hdfdataOslo.tissue.data,[3 2 1]);
hdfdataOslo.images = d(:,:,20:40);
hdfdataOslo.reference = fakeRef(:,20:40);

%visual debug
fr = 1;

figure(22), clf
imshow(squeeze(hdfdataOslo.images(:,:,fr)), [0 255])

figure(23), clf
imshow(squeeze(hdfdataTrym.images(:,:,fr)), [0 255])

%save back to HDF
HdfExport(fileOslo, hdfdataOslo)