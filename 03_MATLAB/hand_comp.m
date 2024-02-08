%ppd = hdrvdp_pix_per_deg( 55, [1920 1080], 2.192 );
ppd = hdrvdp_pix_per_deg( 55, [3840 2160], 2.192/2 );

filePathString1 = "/Users/justus/Desktop/TEST_IMAGE_HLG_GRAY_SCALE_IN_HLG.tiff";
filePathString2 = "/Users/justus/Desktop/TEST_IMAGE_HLG_GRAY_SCALE_IN_PQ.tiff";

disp(['Reference: ', filePathString2]);
disp(['Image: ', filePathString1]);
    
image1 = double(imread(filePathString1)) / 65535;
image2 = double(imread(filePathString2)) / 65535;

test01 = image1(:,:,1);
test02 = image2(:,:,1);

%image1_1 = narrow2full(image1);
%image2_1 = narrow2full(image2);

%image1_linear = pq2lin(image1);
image2_linear = pq2lin(image2);

image1_linear = hlg2lin(image1,0.005,1000);
%image2_linear = hlg2lin(image2,0.005,1000);

image1_xyz = bt2020_to_xyz(image1_linear);
image2_xyz = bt2020_to_xyz(image2_linear);


[maxValue1, linearIndex1] = max(image1_linear(:));
[maxValue2, linearIndex2] = max(image2_linear(:));

[idx1_1, idx2_1, idx3_1] = ind2sub(size(image1_linear), linearIndex1);
[idx1_2, idx2_2, idx3_2] = ind2sub(size(image2_linear), linearIndex2);


fprintf('Maximum value: %f\n', maxValue1);
fprintf('Maximum value: %f\n', maxValue2);
fprintf('Indices of the maximum value: (%d, %d, %d)\n', idx1_1, idx2_1, idx3_1);
fprintf('Indices of the maximum value: (%d, %d, %d)\n', idx1_2, idx2_2, idx3_2);


res = hdrvdp3( 'flicker',image2_xyz,image1_xyz, 'XYZ', ppd, { 'surround', 5} );
resulting_image = hdrvdp_visualize( 'pmap', res.P_map, { 'context_image', image2 });
imshow(resulting_image)

%csvname1 = strcat("/Users/justus/Desktop/Test_2", "_Q_Q_JOD.csv");
csvname2 = strcat("/Users/justus/Desktop/TEST_IMAGE_HLG_GRAY_SCALE_IN_HLG_neu.tiff", "_P_map.csv");

%fileID1 = fopen(csvname1, 'w');
fileID2 = fopen(csvname2, 'w');

% Write variables and array to the CSV file in one line
%fprintf(fileID1, '%d,%d,%d\n', res.P_det,res.Q, res.Q_JOD');
fprintf(fileID2, '%f,%f,%f,%f,%f,%f,%f,%f,%f,%f\n', res.P_map');

% Close the file
%fclose(fileID1);
fclose(fileID2);