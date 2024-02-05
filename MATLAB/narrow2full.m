function im_full = narrow2full(im_narrow)

im_full = (((im_narrow*1023)/2^(10-8)-16))/219;

end