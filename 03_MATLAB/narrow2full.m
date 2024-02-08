function im_full = narrow2full(im_narrow)
% Narrow Range to Full Range Conversion for 10-bit signals

im_full = (((im_narrow*1023)/2^(10-8)-16))/219;

end