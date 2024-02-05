%ppd = hdrvdp_pix_per_deg( 55, [1920 1080], 2.192 );
ppd = hdrvdp_pix_per_deg( 55, [3840 2160], 2.192/2 );

filePathString1 = "/Users/justus/Desktop/TEST_IMAGE_HLG_GRAY_SCALE_IN_HLG.tiff";
filePathString2 = "/Users/justus/Desktop/TEST_IMAGE_HLG_GRAY_SCALE_IN_PQ.tiff";

%filePathString1 = "D:\41_TIFF_EXTRACTION_NEW\01.1_ARRI_Encounters_PQ_UHD_FR\09_H265_Main422_10\Compound Clip 3_V1-0003.000200.tif"
%filePathString2 = "D:\01_TIFF_ORIGINALS\01.1_ARRI_Encounters_PQ_UHD_FR\V1-0003_Compound Clip 3.000000.tif"

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
%image2_linear(image2_linear>1000) = 1000;

image1_linear = hlg2lin(image1,0.005,1000);
%image2_linear = hlg2lin(image2,0.000,1000);

image1_xyz = bt2020_to_xyz(image1_linear);
image2_xyz = bt2020_to_xyz(image2_linear);

%image1_linear = pq2lin(image1);
%image2_linear = pq2lin(image2);

%image1_linear = hlg2lin(image1_1,0,1000);
%image2_linear = hlg2lin(image2_1,0,1000);

test1 = image1_linear(:,:,1);
test2 = image2_linear(:,:,1);


% Find the maximum value and its indices
[maxValue, linearIndex] = max(image1_linear(:));

% Convert linear index to subscripts
[idx1, idx2, idx3] = ind2sub(size(image1_linear), linearIndex);

% Display the results
fprintf('Maximum value: %f\n', maxValue);
fprintf('Indices of the maximum value: (%d, %d, %d)\n', idx1, idx2, idx3);

% Find the maximum value and its indices
[maxValue, linearIndex] = max(image2_linear(:));

% Convert linear index to subscripts
[idx1, idx2, idx3] = ind2sub(size(image2_linear), linearIndex);

% Display the results
fprintf('Maximum value: %f\n', maxValue);
fprintf('Indices of the maximum value: (%d, %d, %d)\n', idx1, idx2, idx3);


res = hdrvdp3( 'flicker',image2_xyz,image1_xyz, 'XYZ', ppd, { 'surround', 5, 'rgb_display', 'oled'} );
%res = hdrvdp3( 'side-by-side', image2_linear, image1_linear, 'rgb-native', ppd, { 'surround', 5 } );
resulting_image = hdrvdp_visualize( 'pmap', res.P_map, { 'context_image', image2 });
imshow(resulting_image)

% Create the file name with the same name for the variable and array
%csvname1 = strcat("/Users/justus/Desktop/Test_2", "_Q_Q_JOD.csv");
csvname2 = strcat("/Users/justus/Desktop/TEST_IMAGE_HLG_GRAY_SCALE_IN_HLG_neu.tiff", "_P_map.csv");

% Write the single variable and 2D array to the CSV file
% Open the file for writing
%fileID1 = fopen(csvname1, 'w');
fileID2 = fopen(csvname2, 'w');

% Write variables and array to the CSV file in one line
%fprintf(fileID1, '%d,%d,%d\n', res.P_det,res.Q, res.Q_JOD');
fprintf(fileID2, '%f,%f,%f,%f,%f,%f,%f,%f,%f,%f\n', res.P_map');

% Close the file
%fclose(fileID1);
fclose(fileID2);