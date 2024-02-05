

% Replace 'your_source_folder' with the path to your source folder
source_folder = '/Volumes/T7_Shield/1002_New_Reduced/10_SOURCE_CORRECT_UHD_selection/12.1_TRANSFORMED_HLG_FR_UHD';

% Replace 'your_target_folder' with the path to your target folder
target_folder = '/Volumes/T7_Shield/1010_HLG_vs_Org';

% Replace 'your_search_folder' with the path to the folder for searching
search_folder = '/Volumes/T7_Shield/XX_WATCHFOLDER_10_BIT_REDUCTION/10_SOURCE_CORRECT_UHD_selection/12.1_TRANSFORMED_HLG_FR_UHD';

% Get a list of all files in the source folder and its subfolders
file_list = dir(fullfile(source_folder, '**', '10bit*.*'));

ppd = hdrvdp_pix_per_deg( 55, [3840 2160], 1.096 );
% ppd = hdrvdp_pix_per_deg( 55, [1920 1080], 2.192 );


% Iterate through each file
for i = 1:length(file_list)
    % Get the current file name
    current_file = file_list(i).name;

    % Skip '.' and '..' entries and folders
    if strcmp(current_file, '.') || strcmp(current_file, '..') || file_list(i).isdir
        continue;
    end

    current_file_path1 = fullfile(file_list(i).folder);

    relative_path1 = strrep(current_file_path1, source_folder, '');

    target_subfolder1 = fullfile(target_folder, relative_path1);

    if exist(target_subfolder1, 'dir') ~= 7
        mkdir(target_subfolder1);
        disp('Subdirectory created.');
    else
        disp('Subdirectory already exists.');
    end

    % Specify the target file path
    target_file_path = target_subfolder1;

    % Extract the pattern "V1-" followed by four digits from the current file name
    match = regexp(current_file, '^(.*?)\.', 'tokens', 'once');
    pattern = '10bit_Narrow_Range_...............'; % 10 dots represent any character

    % Use regexprep to replace the matched pattern with an empty string
    match = regexprep(match, pattern, '');
    disp(match)

    if ~isempty(match)
        % Extract the four digits
        current_numbers = match{1};
        disp(current_numbers)

        % Search for a file with the same four digits in the search folder
        search_pattern = fullfile(search_folder, '**', ['*' current_numbers '*.tif']);
        disp(search_pattern)
        matching_files = dir(search_pattern);


        if ~isempty(matching_files)
            % Filter out files starting with "./"
            matching_files = matching_files(~startsWith({matching_files.name}, '._'));
            matching_files = matching_files(~contains({matching_files.name}, 'P3Lim'));


            % Check if there are still matching files
            if ~isempty(matching_files)
                % Use the first matching file found in your specific command
                matching_file_path = fullfile(matching_files(1).folder, matching_files(1).name);

                folder = matching_files(1).folder;
                ref_file = matching_files(1).name;
                seperator = "/";
                resulting_ref = strcat(folder,seperator,ref_file);
    
                filePathString1 = string(fullfile(source_folder,fullfile(relative_path1,current_file)));
                filePathString2 = string(resulting_ref);

                %filePathString1 = "D:\41_TIFF_EXTRACTION_NEW\01.1_ARRI_Encounters_PQ_UHD_FR\09_H265_Main422_10\Compound Clip 3_V1-0003.000200.tif"
                %filePathString2 = "D:\01_TIFF_ORIGINALS\01.1_ARRI_Encounters_PQ_UHD_FR\V1-0003_Compound Clip 3.000000.tif"
                
                disp(['Reference: ', filePathString2]);
                disp(['Image: ', filePathString1]);
                    
                image1 = double(imread(filePathString1));
                image2 = double(imread(filePathString2));

                %image1_1 = narrow2full(image1);
                %image2_1 = narrow2full(image2);

                %image1_linear = pq2lin(image1);
                %image2_linear = pq2lin(image2);

                image1_linear = hlg2lin(image1,0,1000);

                %image1_linear(1000<image1_linear) = 1000;
                image2_linear = hlg2lin(image2,0,1000);

                test1 = image1_linear(:,:,1);
                test2 = image2_linear(:,:,1);

                image1_xyz = bt2020_to_xyz(image1_linear);
                image2_xyz = bt2020_to_xyz(image2_linear);

                %image1_linear = pq2lin(image1);
                %image2_linear = pq2lin(image2);
    
                %image1_linear = hlg2lin(image1_1,0,1000);
                %image2_linear = hlg2lin(image2_1,0,1000);
    
                res = hdrvdp3( 'flicker',image2_xyz,image1_xyz, 'XYZ', ppd, { 'surround', 5, 'rgb_display', 'oled'} );
                %res = hdrvdp3( 'side-by-side', image2_linear, image1_linear, 'rgb-native', ppd, { 'surround', 5 } );
                resulting_image = hdrvdp_visualize( 'pmap', res.P_map, { 'context_image', image2 });
                
                % Add two lines of text with variables
                text5 = sprintf('P_det: %s', res.P_det);
                text4 = sprintf('Q: %s', res.Q);
                text3 = sprintf('Q_JOD: %s', res.Q_JOD);
                text2 = sprintf('Reference: %s', filePathString2);
                text1 = sprintf('Image: %s', filePathString1);
                
                % Insert text below the image
                image_with_text = insertText(resulting_image, [0  size(image1,1)-40; 0 size(image1,1)-85; 0 size(image1,1)-130; 0 size(image1,1)-175; 0 size(image1,1)-220], {text1, text2, text3, text4, text5}, 'FontSize', 12, 'BoxColor', 'white', 'BoxOpacity', 0.5, 'TextColor', 'black');
                
                add_matrix = strcat(current_file,"_HDR_VDP_3_0_MATLAB.tif");
                storage_path = fullfile(target_file_path,add_matrix);

                imshow(image_with_text)
    
                % Save the image with added text
                imwrite(image_with_text, storage_path);

                % Create the file name with the same name for the variable and array
                csvname1 = strcat(storage_path, "_Q_Q_JOD.csv");
                csvname2 = strcat(storage_path, "_P_map.csv");
                
                % Write the single variable and 2D array to the CSV file
                % Open the file for writing
                fileID1 = fopen(csvname1, 'w');
                fileID2 = fopen(csvname2, 'w');
                
                % Write variables and array to the CSV file in one line
                fprintf(fileID1, '%d,%d,%d\n', res.P_det,res.Q, res.Q_JOD');
                fprintf(fileID2, '%f,%f,%f,%f,%f,%f,%f,%f,%f,%f\n', res.P_map');
                
                % Close the file
                fclose(fileID1);
                fclose(fileID2);
                                        
            else
                disp(['No matching file found for: ', current_file]);
            end
        else
            disp(['Current file does not match pattern: ', current_file]);
        end

    else
        disp(['Current file does not match pattern: ', current_file]);
    end
end




% Replace 'your_source_folder' with the path to your source folder
source_folder = '/Volumes/T7_Shield/1002_New_Reduced/10_SOURCE_CORRECT_UHD_selection/12.1_TRANSFORMED_HLG_FR_UHD';

% Replace 'your_target_folder' with the path to your target folder
target_folder = '/Volumes/T7_Shield/1010_HLG_vs_Org';

% Replace 'your_search_folder' with the path to the folder for searching
search_folder = '/Volumes/T7_Shield/XX_WATCHFOLDER_10_BIT_REDUCTION/10_SOURCE_CORRECT_UHD_selection/12.1_TRANSFORMED_HLG_FR_UHD';

% Get a list of all files in the source folder and its subfolders
file_list = dir(fullfile(source_folder, '**', '10bit*.*'));

ppd = hdrvdp_pix_per_deg( 55, [3840 2160], 1.096 );
% ppd = hdrvdp_pix_per_deg( 55, [1920 1080], 2.192 );


% Iterate through each file
for i = 1:length(file_list)
    % Get the current file name
    current_file = file_list(i).name;

    % Skip '.' and '..' entries and folders
    if strcmp(current_file, '.') || strcmp(current_file, '..') || file_list(i).isdir
        continue;
    end

    current_file_path1 = fullfile(file_list(i).folder);

    relative_path1 = strrep(current_file_path1, source_folder, '');

    target_subfolder1 = fullfile(target_folder, relative_path1);

    if exist(target_subfolder1, 'dir') ~= 7
        mkdir(target_subfolder1);
        disp('Subdirectory created.');
    else
        disp('Subdirectory already exists.');
    end

    % Specify the target file path
    target_file_path = target_subfolder1;

    % Extract the pattern "V1-" followed by four digits from the current file name
    match = regexp(current_file, '^(.*?)\.', 'tokens', 'once');
    pattern = '10bit_Narrow_Range_...............'; % 10 dots represent any character

    % Use regexprep to replace the matched pattern with an empty string
    match = regexprep(match, pattern, '');
    disp(match)

    if ~isempty(match)
        % Extract the four digits
        current_numbers = match{1};
        disp(current_numbers)

        % Search for a file with the same four digits in the search folder
        search_pattern = fullfile(search_folder, '**', ['*' current_numbers '*.tif']);
        disp(search_pattern)
        matching_files = dir(search_pattern);


        if ~isempty(matching_files)
            % Filter out files starting with "./"
            matching_files = matching_files(~startsWith({matching_files.name}, '._'));
            matching_files = matching_files(~contains({matching_files.name}, 'P3Lim'));


            % Check if there are still matching files
            if ~isempty(matching_files)
                % Use the first matching file found in your specific command
                matching_file_path = fullfile(matching_files(1).folder, matching_files(1).name);

                folder = matching_files(1).folder;
                ref_file = matching_files(1).name;
                seperator = "/";
                resulting_ref = strcat(folder,seperator,ref_file);
    
                filePathString1 = string(fullfile(source_folder,fullfile(relative_path1,current_file)));
                filePathString2 = string(resulting_ref);

                %filePathString1 = "D:\41_TIFF_EXTRACTION_NEW\01.1_ARRI_Encounters_PQ_UHD_FR\09_H265_Main422_10\Compound Clip 3_V1-0003.000200.tif"
                %filePathString2 = "D:\01_TIFF_ORIGINALS\01.1_ARRI_Encounters_PQ_UHD_FR\V1-0003_Compound Clip 3.000000.tif"
                
                disp(['Reference: ', filePathString2]);
                disp(['Image: ', filePathString1]);
                    
                image1 = double(imread(filePathString1));
                image2 = double(imread(filePathString2));

                image1_1 = narrow2full(image1);
                %image2_1 = narrow2full(image2);

                %image1_linear = pq2lin(image1);
                %image2_linear = pq2lin(image2);

                image1_linear = hlg2lin(image1,0,1000);

                %image1_linear(1000<image1_linear) = 1000;
                image2_linear = hlg2lin(image2,0,1000);

                test1 = image1_linear(:,:,1);
                test2 = image2_linear(:,:,1);

                image1_xyz = bt2020_to_xyz(image1_linear);
                image2_xyz = bt2020_to_xyz(image2_linear);

                %image1_linear = pq2lin(image1);
                %image2_linear = pq2lin(image2);
    
                %image1_linear = hlg2lin(image1_1,0,1000);
                %image2_linear = hlg2lin(image2_1,0,1000);
    
                res = hdrvdp3( 'flicker',image2_xyz,image1_xyz, 'XYZ', ppd, { 'surround', 5, 'rgb_display', 'oled'} );
                %res = hdrvdp3( 'side-by-side', image2_linear, image1_linear, 'rgb-native', ppd, { 'surround', 5 } );
                resulting_image = hdrvdp_visualize( 'pmap', res.P_map, { 'context_image', image2 });
                
                % Add two lines of text with variables
                text5 = sprintf('P_det: %s', res.P_det);
                text4 = sprintf('Q: %s', res.Q);
                text3 = sprintf('Q_JOD: %s', res.Q_JOD);
                text2 = sprintf('Reference: %s', filePathString2);
                text1 = sprintf('Image: %s', filePathString1);
                
                % Insert text below the image
                image_with_text = insertText(resulting_image, [0  size(image1,1)-40; 0 size(image1,1)-85; 0 size(image1,1)-130; 0 size(image1,1)-175; 0 size(image1,1)-220], {text1, text2, text3, text4, text5}, 'FontSize', 12, 'BoxColor', 'white', 'BoxOpacity', 0.5, 'TextColor', 'black');
                
                add_matrix = strcat(current_file,"_HDR_VDP_3_0_MATLAB.tif");
                storage_path = fullfile(target_file_path,add_matrix);

                imshow(image_with_text)
    
                % Save the image with added text
                imwrite(image_with_text, storage_path);

                % Create the file name with the same name for the variable and array
                csvname1 = strcat(storage_path, "_Q_Q_JOD.csv");
                csvname2 = strcat(storage_path, "_P_map.csv");
                
                % Write the single variable and 2D array to the CSV file
                % Open the file for writing
                fileID1 = fopen(csvname1, 'w');
                fileID2 = fopen(csvname2, 'w');
                
                % Write variables and array to the CSV file in one line
                fprintf(fileID1, '%d,%d,%d\n', res.P_det,res.Q, res.Q_JOD');
                fprintf(fileID2, '%f,%f,%f,%f,%f,%f,%f,%f,%f,%f\n', res.P_map');
                
                % Close the file
                fclose(fileID1);
                fclose(fileID2);
                                        
            else
                disp(['No matching file found for: ', current_file]);
            end
        else
            disp(['Current file does not match pattern: ', current_file]);
        end

    else
        disp(['Current file does not match pattern: ', current_file]);
    end
end


