function xyz_array = bt2020_to_xyz(image)
% Matrix Conversion for Linear Luminance in BT.2020 domain into XYZ domain

xyz_array = image;
xyz_array(:,:,1) = 0.636958 * image(:,:,1) + 0.144617 * image(:,:,2) + 0.168881 * image(:,:,3);
xyz_array(:,:,2) = 0.262700 * image(:,:,1) + 0.677998 * image(:,:,2) + 0.059302 * image(:,:,3);
xyz_array(:,:,3) = 0.0 * image(:,:,1) + 0.028073 * image(:,:,2) + 0.060985 * image(:,:,3);

end