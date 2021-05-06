% Below is the code for creating the movies for h,H,h(i)-h(1), and
% H(i)-H(1).

% Modifications will be needed to change between h and H but they are minor
% and are explained below.


% X will contain strings of the names of the
% waterframes, h, in the correct order
Xframes4Info=dir('OraWaterFrames'); % put in the name of the folder we get the frames from
X={};
[n,~]=size(Xframes4Info);
for j=1:n
    X{j}=Xframes4Info(j).name;
end
X=natsortfiles(X);

% trivial initializations of the axes since they change
% depending on the frame
xlowest=1;
xhighest=1;
ylowest=1;
yhighest=1;
posi=[267    63   980   642];

% Same procedure for h instead of H.
% Make sure to include the initial ordering of the
% frame names in X if only interested in h.
Waterhvideo=VideoWriter('OraWaterFrames_top'); % Name of the movie

set(Waterhvideo,'FrameRate',10); % optional framerate change
open(Waterhvideo);

for j=4:n
    Prevh=load(X{4});
    if j~=n
        Nexth=load(X{j+1});
        Diff=Nexth.h-Prevh.h; % Change to Nexth.H-Prevh.H if we want to see difference in H
        s=surf(Diff);
        colormap pink
        shading interp
        view(-90,90);
        ax=gca;
        zbottom=-.05;
        ztop=.5;
        xbottom=ax.XLim(1);
        ybottom=ax.YLim(1);
        xtop=ax.XLim(2);
        ytop=ax.YLim(2);
        if xlowest>xbottom
            xlowest=xbottom;
        end
        if ylowest>ybottom
            ylowest=ybottom;
        end
        if xhighest<xtop
            xhighest=xtop;
        end
        if yhighest<ytop
            yhighest=ytop;
        end
        xlim([xlowest,xhighest]);
        ylim([ylowest,yhighest]);
        zlim([zbottom,ztop]);
        set(gcf, 'Position', posi);
        frame=getframe(gcf);
        writeVideo(Waterhvideo,frame);
    end
end

close(Waterhvideo);

