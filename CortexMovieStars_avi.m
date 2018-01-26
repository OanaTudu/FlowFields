function [mov] = CortexMovieStarsFwd(varargin)

%%STARFIELD3D(varargin) 
%%This function creates a starfield simulation; the size 
%%of the matrix (MATRIX_SIZE, integer) can be given in the command line,
%%optionally it can be set below.
%%See list of PARAMETERS below for further settings.
%%O.T. Jan. 2005


if nargin>=1
    matrix_size = varargin{1};
else
    matrix_size = 200;            %size of the image (matrix to work with) Please put an EVEN number
end
if nargin>=2
    dir = varargin{2};
else
    dir = 2;            %size of the image (matrix to work with) Please put an EVEN number
end

colordef none;  %set the color defaults to their MATLAB values
colormap(hot);
%%%%%%%%%%%%%%%%%%%%%       PARAMETERS      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%dir = 1;                %%for "departing" dots set on 2, for "approaching" stars set on 1
frames = 20;           %%number of frames in the movie
dotsize = 4;            %%define dot size (x by x pixels)
ratio = 1.0;            %%a ratio of the full matrix to be covered with dots 
speed = 1;              %%define the speed of travel through the stars

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Section I: General Constants 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

msperframe = 1000/frames;%getGlobalParams('framedur');	      % milliseconds per frame
pixperdegree = 41;%getGlobalParams('pixelsperdegree');    % Number of pixels per degree


space_depth_param = 70;

d = 512;
z = d-speed-space_depth_param; 
msize = floor(matrix_size/2);
numberdots = msize*msize*ratio/(dotsize*dotsize*100);
a = 1;
k = 1; % index for the movie frames

initial = zeros(msize, msize);
smalldot = ones(dotsize);     
   
%create the stream of frames


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Section II: Moving Stars
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

WRITEFILES = 1;

% Stimulus parameters
TF = 1    % 0.5 Hz temporal frequency


msperperiod = 1/TF*1000;
framesperperiod = round(msperperiod/msperframe);

Xpix = msize*2;
Ypix = msize*2;

Stimulus = 128*ones(Xpix,Ypix,framesperperiod);

cd c:\Oana;

%figure;
colormap(jet(256));   
for frame = 1:framesperperiod
          if(frame == 1)
            %initial positions of the dots on the screen (x,y,z)
            x_small = floor(rand(4,numberdots)*(msize-2)+1);
            y_small = floor(rand(4,numberdots)*(msize-2)+1);
            z_small = z*ones(4,numberdots);
          else
            %compute new positions of dots on the screen (x,y,z)
            x_small = floor(x_small);
            y_small = floor(y_small);
            z_small = (z_small-.00001);
          end;
    for quadrant = 1:4
         ini1 = initial; 
    
        %make the matrix for the image (draw the dots in their positions)
        for h=1:numberdots
             %make new dots appear for each dot that gets out of the image
            if(x_small(quadrant,h) >= msize | x_small(quadrant,h) <= 1 | y_small(quadrant,h) >= msize | y_small(quadrant,h) <= 1 )
                 tempx = floor(randn*msize);
                 tempy = floor(randn*msize);
                 x_small(quadrant,h) = mod(tempx*tempx, msize-2)+1;
                 y_small(quadrant,h) = mod(tempy*tempy, msize-2)+1;
                 z_small(quadrant,h) = z-1;
            end;
        
            ini1(x_small(quadrant,h):x_small(quadrant,h)+dotsize-1, y_small(quadrant,h):y_small(quadrant,h)+dotsize-1) = smalldot;     
            x_small(quadrant, h) = floor(x_small(quadrant, h)*d/z_small(quadrant,h));
            y_small(quadrant, h) = floor(y_small(quadrant, h)*d/z_small(quadrant,h));
              
        end %for numberdots
    
            ini1 = ini1(1:msize, 1:msize);
            size(ini1);
            if(quadrant == 1) q1 = imrotate(ini1,-90,'bilinear','crop');
            elseif(quadrant == 2) q2 = imrotate(ini1,90,'bilinear','crop');
            elseif(quadrant == 3) q3 = imrotate(ini1,180,'bilinear','crop');
            else q4 = ini1;
            end;
    end; %for quadrants
    
    im = [q3 q2; q1 q4] ;
    Stimulus(:,:,frame) = cut(im);                %see function cut below
    Stimulus(:,:,frame) = (Stimulus(:,:,frame)+1)/.5;
    Stimulus(:,:,frame) = round(Stimulus(:,:,frame)*127+128);
    prl=max(round(Stimulus(:,:,frame)));
    %imshow(Stimulus(:,:,frame)/512);
    %drawnow;
    %mov(frame) = getframe;
    %pause
 end % for frames 
 
    %in case you want to have the field departing!!! use the 2 lines below.
    if(dir == 2)
        Stimulus = invertMovie(Stimulus);
    end;
    for frame = 1:framesperperiod
        imshow(Stimulus(:,:,frame)/512);
        drawnow;
        mov(frame) = getframe;
    end
    mov = mov(4:end);
    map = colormap;
    cd c:\Oana\work;
    %movie(mov);      %play the matlab movie.
    %mpgwrite(mov, map, outfile,[1, 0, 1, 1, 10, 6, 6, 6]); %create mpeg file from movie.
    movie2avi(mov,'recede4','FPS',10, 'compression','Cinepak', 'quality', 75);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                          FUNCTIONS USED IN THE PROGRAM                 %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [stars] = cut(mat)

%  For making stimuli.  Takes an image and cuts the center (for the fixation spot)
%  and makes the stimulus circular.
%
%  The way this program works, the images are ready to go;
%  
%  Oana. Jan. 2005

colormap(hot);


fix = 50;               %%set a fraction of the size of the matrix as diameter for the black central spot.
fixspot = 6;           %%set the size in pixels of the fixation spot


r = length(mat);
im = ones(r,r);
    for xi = 1:r
       for yi = 1:r
           if ((sqrt((r/2-xi)^2+(r/2-yi)^2) > r/2 -5 | sqrt((r/2-xi)^2+(r/2-yi)^2) < r/fix) )
                     im(xi,yi) = 0;         
           end;
       end;
    end;
stars = mat .* im-1.5;

imagesc(stars);
%nargout
axis('square');
colormap(hot);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [invStim] = invertMovie(stim)
%
%   Inverts the order of the frames in the movie
%   Use it if you want the stars in the starfiels 
%   simulator to depart instead of to approach
%
%  Oana Jan. 2005

n = size(stim,3)
m = floor(n/2)

for i = 1:m
        temp = stim(:,:,i);
        stim(:,:,i) = stim(:,:,n-i+1);
        stim(:,:,n-i+1) = temp;
end;

invStim = stim;