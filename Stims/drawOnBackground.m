function newImg = drawOnBackground(img, backimg, x, y)

%This takes a (color) image matrix, and draws it on another, but skips replace
%if the img is near [0 255 0] at that pixel.
%x, y gives the top x and y of where you'll draw the img
%tolerance lets us deal with fuzzy image boundaries!

tolerance = 140;

%How big is the img? (and how many layers?)
[q r s] = size(img);

newImg = backimg;


for i=1:q
    for j=1:r
        pix = impixel(img, j, i); %Get that pixel in the img
        %check if it's the  GREEN (we'll allow for variance!)
        pix
        if pdist([pix; 0 255 0], 'Euclidean') < 50
            newImg(x+i-1, y+j-1,:) = pix; %bump the index so the first pixel is still at correct loc in the larger pic!
            
        end
    end
end


end