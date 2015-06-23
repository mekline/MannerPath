function makeKenBurnsStims(manners, paths, mode, watchit)
%Just like makeMPStims, but the whole movie also moves on a white
%background.  Also adds and option to have multiple agents!
%
%The new watchit option lets you decide to watch the movie as it compiles,
%which is SUPER SLOW
%
%Full set of paths & manners:
%{'vibrate','rotate','halfrotate','rock','sine','bounce','loop','stopstart','squarewave','backforth','zip','wheelie'}
%{'past','above','under','to','behind','tofar','along','underup','over','circle','onto','underfar'}
%
%modes: 'pilot' just shows traces quickly, 'movie' exports videos to
%movies folder

if nargin < 4
    watchit = 0;
end


currentFolder = pwd;

for a=1:length(manners)
    for b=1:length(paths)
        
        %Calculate the x,y vectors of the manner+path composition!
        mymanner = manners{a};
        mypath = paths{b};
        [x, y, lens, bridgeFront] = getPath(mypath); %x and y are the top lh corner of the object
        %lens is number of (motion) frames, 30 = 1 sec
        %bridge front tells whether to draw the bridge in front of the
        %triangle at this timpoint.
        
        [x, y] = smoothPath(x,y); %Ensures that points are equidistant along that piecewise path...
        [x, y, rotations] = applyManner(mymanner, x, y);

        %special case! lens may have gotten longer, watch out:
        if (lens < length(x))
            bridgeFront = [bridgeFront; repmat(bridgeFront(end),length(x)-lens, 1)]; 
            lens = length(x);
        elseif (lens > length(x))
            lens=length(x);
        end
        
        %Get the imgs and make a movie!    
        for obj = 1:1
            
            tic; %how long does this take?
            
            img = imread([currentFolder '/img/' num2str(obj) 'eye.jpg'],'JPEG'); %read in object
            [m n p] = size(img); %how big is it? (h, w, layers)

            backimg = imread([currentFolder '/img/bg.jpg'],'JPEG'); %read in bg
            [q r s] = size(backimg);

            bridgeimg = imread([currentFolder '/img/bridge.jpg'],'JPEG'); %read in bg

            %Now use the above calculated path to draw them to obj m_images
            clear m_images;
            
            %How big is my array going to be?  Preallocate it!
            %m_images = ones(600, 800, 3, 180); %height, width, colors, length-in-frames

            if strcmp(mode,'movie')

                %Because of how imrotate works, the size of img (the agent) is not guaranteed!  
                %(it adds buffer cells if needed to fit the whole img). But
                %the midpoint is guaranteed to stay the midpoint!  So let's plot that
                %instead.
                
                x = x+50;
                y = y+50;

                %Draw one boring second of the triangle sitting in initial position!
                withbridge = drawOnBackground(bridgeimg, backimg, 195, 295);
                newimg = moveImg(img, withbridge, x(1)-50, y(1)-50); 
                
                prefix = floor((180-lens)/3); %Standardized so that total movie comes out to 180frames
                postfix = floor(2*(180-lens)/3);
                
                for j=1:prefix
                    %NEW FOR KB - Plot newimg onto the bigger background,
                    %in the right spot.
                    if watchit
                        image(newimg);
                    end
                    m_images(:,:,:,j) = newimg;
                end
                

                %Draw the animation
                for i = 1:lens
                    %rotate the triangle
                    img_rot = imrotate(img, rotations(i)); 
                    %how big is the img right now? Find this out so we can set the lh
                    %corner correctly!
                    [t u v] = size(img_rot);
                    %draw triangle & bridge on background, in the correct order!
                    if bridgeFront(i)
                        nobridge = moveImg(img_rot, backimg, x(i) - round(t/2),y(i)-round(u/2));
                        newimg = drawOnBackground(bridgeimg, nobridge, 195, 295);
                    else
                        withbridge = drawOnBackground(bridgeimg, backimg, 195, 295);
                        newimg = moveImg(img_rot, withbridge, x(i) - round(t/2),y(i)-round(u/2));
                        end
                    
                    %NEW FOR KB - Plot newimg onto the bigger background,
                    %in the right spot.    
                    if watchit
                        image(newimg);
                    end
                    m_images(:,:,:,prefix+i) = newimg;
                end

                %Draw boring final position
                for k = 1:postfix
                    %NEW FOR KB - Plot newimg onto the bigger background,
                    %in the right spot.
                    if watchit
                        image(newimg);
                    end
                    m_images(:,:,:,prefix+lens+k) = newimg;
                end
                
                %Report what movie that was
                
                deets = [manners{a},' ',paths{b},' ', num2str(obj)];
                disp(deets)
   

                %Convert m_images to a movie!           
                w = VideoWriter(['movies/' num2str(obj) '_' mymanner '_' mypath],'MPEG-4');
                w.FrameRate = 30;
                open(w);
                writeVideo(w,m_images);
                close(w);
               

            elseif strcmp(mode,'pilot')

                %And here's something else for debugging - instead of redrawing the
                %triangle, trace its path 
                newimg = drawOnBackground(bridgeimg,backimg,195, 275);
                for i = 1:lens
                    newimg = traceImg(img, newimg, x(i),y(i));
                end
                image(newimg);
                axis off;
                drawnow;
            end
            
            toc %how long did this movie take?
        end %End THIS MOVIE
    end
end
