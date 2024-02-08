function im_lin = pq2lin(im_pq)
% Function based on given HDR-VDP-3 pq2lin function and validated using ITU-R BT.2100 
% Old commentary: Transforms a PQ-encoded image into an image with absolute linear colour values (accrding to Rec. 2100).

Lmax = 10000;

n    = 0.15930175781250000;
m    = 78.843750000000000;	
c1   = 0.83593750000000000;	
c2   = 18.851562500000000;	
c3   = 18.687500000000000;	


im_t = max(im_pq,0).^(1/m);

im_lin = Lmax * (max( im_t-c1, 0 )./(c2-c3*im_t)).^(1/n);


end
