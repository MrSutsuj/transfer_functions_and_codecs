function im_lin = hlg2lin(im_hlg,Lb,Lw)
% HLG Inverse OETF + OOTF resulting in HLG EOTF with parameters Lb for minimum display luminance and Lb for maximum display luminance
% Use with RGB images only, since the OOTF uses weighted RGB channels

a = 0.17883277;
b = 1 - 4 * a;
c = 0.5 - a * log(4*a);

gamma = 1.2 + 0.42 * log10(Lw/1000);

beta = sqrt(3*(Lb/Lw)^(1/gamma));

value = max(0,(1-beta)*im_hlg+beta);

x = value;

value_lin = (x <= 0.5) .* (((x.^(2))./3)) + (0.5 < x) .* ((exp((x-c)./a)+b)./12);

% Multiply each channel by its respective weight
weighted_image = 0.2627 .* value_lin(:,:,1) + 0.6780 .* value_lin(:,:,2) + 0.0593 .* value_lin(:,:,3);

% Sum the weighted values across the third dimension (RGB)
weighted_sum_array = value_lin;

weighted_image_gamma = (weighted_image .^(gamma-1));

weighted_sum_array(:,:,1) = weighted_sum_array(:,:,1) .* weighted_image_gamma;
weighted_sum_array(:,:,2) = weighted_sum_array(:,:,2) .* weighted_image_gamma;
weighted_sum_array(:,:,3) = weighted_sum_array(:,:,3) .* weighted_image_gamma;

im_lin = weighted_sum_array .* Lw;

end