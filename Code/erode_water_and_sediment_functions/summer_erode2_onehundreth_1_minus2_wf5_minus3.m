function [H, h, index, target] = summer_erode2_onehundreth_1_minus2_wf5_minus3(H, h, toPrint, index, target, original)
% This function will continue the erosion process and print set number of
% graphs:
%   H is the height of the water surface
%   h is the water height
%   toPrint is the number of graphs to print this run
%   index is the number used in labeling data when saving 
%   target is the next percent eroded value to specifically save data for 
%   original is the volume of sediment in the original hillside, before any
%       erosion

[a,b]=size(H);

% Discritize the X and Y domains
xMin = 0; 
xMax = a-1;
dx = 1;
X = xMin:dx:xMax;
Nx = length(X);

yMin = 0;
yMax = b-1;
dy = 1;
Y = yMin:dy:yMax;
Ny = length(Y);

% For the movie making

% zbottom=-15;
% ztop=15;
% 
% xlowest1=1;
% xhighest1=1;
% ylowest1=1;
% yhighest1=1;
% 
% xlowest1=1;
% xhighest1=1;
% ylowest1=1;
% yhighest1=1;
% 
% xlowest2=1;
% xhighest2=1;
% ylowest2=1;
% yhighest2=1;
% 
% xlowest2=1;
% xhighest2=1;
% ylowest2=1;
% yhighest2=1;

% WaterHvideo=VideoWriter('Mudflow_Mountain2_Millionpixels.avi');
% Waterhvideo=VideoWriter('debrisflow_rain_Millionpixels.avi');
% 
% open(WaterHvideo);
% open(Waterhvideo);

% Loop until the desired number of graphs have been printed
for f = 1:1:toPrint
    
    % Do 1000 iterations of water flow/erosion between printing a frame
    for t = 1:1:1000
        % The parameters input into the water_flow function are as follows:
        %  time step, X-spacing, Y-spacing, # points in X direction, 
        %   # points in Y direction, water height, water depth,
        %   Rainfall rate, eta (scaling parameter), How to handle the
        %    bottom boundary (1 => transport, 0 => fixed), tolerance    
        [h, T] = water_flow5(.1, dx, dy, Nx, Ny, h, H, .5,15,1,10^(-3) );
        % The parameters input into the sediment_flow function are:
        %  time it took for the water height to converge, X-spacing, Y-spacing,
        %   # points in X, # points in Y, fixed water height at the bottom,
        %   water height, water surface height, gamma, sigma
        H = sediment_flow2(T, dx, dy, Nx, Ny, 1, h, H, 2, 2);
        
        
%         Now we will make the movie

        % first the H movie
        
%         s=surf(H);
%         s.LineStyle = ':';
%         ax=gca;
%         xbottom1=ax.XLim(1);
%         ybottom1=ax.YLim(1);
%         xtop1=ax.XLim(2);
%         ytop1=ax.YLim(2);
%         if xlowest1>xbottom1
%             xlowest1=xbottom1;
%         end
%         if ylowest1>ybottom1
%             ylowest1=ybottom1;
%         end
%         if xhighest1<xtop1
%             xhighest1=xtop1;
%         end
%         if yhighest1<ytop1
%             yhighest1=ytop1;
%         end
%         xlim([xlowest1,xhighest1]);
%         ylim([ylowest1,yhighest1]);
%         frame=getframe(gcf);
%         writeVideo(WaterHvideo,frame);
%         
%         % now the h movie
%         
%         s=surf(h);
%         s.LineStyle = ':';
%         ax=gca;
%         xbottom2=ax.XLim(1);
%         ybottom2=ax.YLim(1);
%         xtop2=ax.XLim(2);
%         ytop2=ax.YLim(2);
%         if xlowest2>xbottom2
%             xlowest2=xbottom2;
%         end
%         if ylowest2>ybottom2
%             ylowest2=ybottom2;
%         end
%         if xhighest2<xtop2
%             xhighest2=xtop2;
%         end
%         if yhighest2<ytop2
%             yhighest2=ytop2;
%         end
%         xlim([xlowest2,xhighest2]);
%         ylim([ylowest2,yhighest2]);
%         frame=getframe(gcf);
%         writeVideo(Waterhvideo,frame);

        % end of movie making
        
%         if mod(t,10)==0
%             save(sprintf('Smooth11KWaterFrames/frame_%d_%d', index, t), 'H', 'h', 't')
%         end  
    end

    % Save the data need to plot the graph 
    save(sprintf('/home/astawsky/FoldersForKnot/Smooth11KMudFrames/frame_%d', index), 'H', 'h', 'index')
    
    % Increment the index counter for the next graph
    index = index + 1;
    % Save the data need to continue the erosion process from this point.
    save('Data', 'H', 'h', 'index', 'original', 'target');
    
    % Calculate the current volume of sediment
    % Note: this formula only works because dx = dy = 1
    current = sum(sum(H));
    % Calculate the percentage of sediment that has been eroded
    percent = ((original - current)/original) * 100;
    if ( percent >= target )
        % If the percent eroded is greater than the target, save this data
        % in a separate location so it can be examined later if desired.
        save(sprintf('data/Percent%d', target), 'H', 'h', 'index', 'percent');
        % Increase the target percentage eroded
        target = target + 5;
    end
    
end % End the toPrint for loop

% close(WaterHvideo);
% close(Waterhvideo);



