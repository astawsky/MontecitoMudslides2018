function convertDataToGraphs(dataDir, graphDir)
% This function will take all the *.mat files from the dataDir, can use
% that data to create a graph ans store it in the graphDir

% Add a color for the land surface
land = [0.5 0.25 0];
h0 = 5;

% First, collect all the *.mat files
dataFile = dir(fullfile(dataDir, '*.mat'));

% Now, for each data file, collect the data and generate the graph
for i = 1:length(dataFile)
    % Load the data
    data = strcat(dataDir, '/', dataFile(i).name);
    load(data);
    
    % Create the figure and set its properties
    fig = figure('visible', 'off');
    axes1 = axes('Parent', fig);
    zlim([5, 15]);
    set(axes1, 'ZTick', [5 10 15]);
    set(axes1, 'YTick',[0 50 100]);
    set(axes1, 'XTick',[0 50 100]);
    view(axes1,[-50.5 20]);
    grid(axes1,'on');
    hold(axes1,'all');
    
    % Plot the surface
    surf(0:1:100, 0:1:100, H, 'FaceColor', land, 'EdgeColor', 'none');
    hold on;
    fill3([0:1:100, 100], zeros(1, 102), [H(1, :), h0], [0.5 0.25 0] );
    camlight left; lighting gouraud;
    hold off;

    % Save and close the figure
    name = sprintf('/frame%d', index);
    print(fig, '-djpeg', strcat(graphDir, name));
    close(fig);
    
    % Now clear the data so the next figure can be plotted
    clear H index
    
    % Delete the original file
    delete(data);
end