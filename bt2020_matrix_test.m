% Define the size of the 3D array
sizeX = 20;
sizeY = 20;
sizeZ = 3;

% Create a 3D array with all ones
imageData = ones(sizeX, sizeY, sizeZ) * 10000;

% Display the 3D array
disp('3D Array with Ones:');
disp(imageData);

xyz_array = imageData;
xyz_array(:,:,1) = 0.636958 * imageData(:,:,1) + 0.144617 * imageData(:,:,2) + 0.168881 * imageData(:,:,3);
xyz_array(:,:,2) = 0.262700 * imageData(:,:,1) + 0.677998 * imageData(:,:,2) + 0.059302 * imageData(:,:,3);
xyz_array(:,:,3) = 0.0 * imageData(:,:,1) + 0.028073 * imageData(:,:,2) + 0.060985 * imageData(:,:,3);