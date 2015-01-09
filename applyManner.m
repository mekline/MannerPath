function [xman, yman, rotations] = applyManner(mannername, x,y)

lens = length(x);

switch mannername
    case 'none'
        rotations = zeros(lens, 1); %no changes!
        xman = x;
        yman = y;
    case 'sillySine'
        rotations = zeros(lens, 1);
        xman = x + sin(x/5)*12;
        yman = y;
    case 'sillyBounce'
        rotations = zeros(lens, 1);
        x = x + abs(sin(x/5))*12;
        yman = y;
        
    %OK, here's the real ones
    case 'vibrate' %just a very fast and small-amplitude sine...no need to adjust for path length
        rotations = zeros(lens,1);
        xman = x + sin(40*2*pi*(y-250)/(450))*4;
        yman = y;
    case 'rotate'
        %rotations? ~ 1 per second, rounded down
        rots = floor(lens/30);
        rotations = 0:(-360*rots/(lens-1)):(-360*rots); %Four complete rotations
        xman = x;
        yman = y;
   case 'halfrotate' %rotate ~180 deg, start & end up vertical
        t = 1:lens;
        %~ 1 bops per second
        mult = floor(lens/30);
        rotations = 100*sawtooth((mult)*pi*(t-t(1))/(t(end)-t(1))+pi/2, 0.5);
        xman = x;
        yman = y;
    case 'rock' %rotate over the 90 deg. around upright, start & end up vertical
        t = 1:lens;
        %~ 6 bops per second
        mult = floor(lens/30)*6;
        rotations = 30*sawtooth((mult)*pi*(t-t(1))/(t(end)-t(1))+pi/2, 0.5);
        xman = x;
        yman = y;

        
    case 'sineWave' % 5 complete sines over the path (looks bad on length changes!)
        rotations = zeros(lens,1);
        xman = x + sin(5*2*pi*(y-y(1))/(y(end)-y(1)))*20;
        yman = y;
    case 'bounce' %Abs the above
        rotations = zeros(lens,1);
        xman = x - abs(sin(5*2*pi*(y-y(1))/(y(end)-y(1)))*20);
        yman = y;


    
    case 'backandforth'
        rotations = zeros(lens,1);
        xman = x + sin(5*2*pi*(y-y(1))/(y(end)-y(1)));
        yman = y + (sin(5*2*pi*(y-y(1))/(y(end)-y(1)))*50);
end



