function [h, T] = water_flow5_power2(dt, dx, dy, Nx, Ny, h, H, R, eta, transport, tol)
% This function will use an upwind scheme to calculate the change in the water
% depth over a period of time using the equation:
%    \eta^2\frac{\partial h}{\partial t}
%         = \nabla\cdot[\frac{\nabla H}{|\nabla H|}h^(5/3)|\nabla H|^(1/2)]
% where:
% 	dt is the time step
%	dx and dy are the lengths of the discritizations in x and y
%	Nx and Ny are the number of points in the discritizations of x and y
%	h is the water current water depth that needs to be equilibrated
%	H is the (average) water height over the surface
%	R is the rate of rainfall
%   eta is a  scaling parameter
%	tol is the tolerance we want to achieve
% The output of this function will be the water depth over the surface H after
% the water has come to an equilibrium. This program will also output the total 
% time that has elapsed waiting for the system to reach equilibrium.

% The functions below will be used to avoid long, complicated, nested if/else
% statements in the code. Since we are using periodic boundary conditions. 
left = @(x) mod(x - 2, Nx) + 1;
right = @(x) mod(x, Nx) +  1;

% At the top boundary, we have a no flux boundary condition. This boundary
% condition is usually simulated with a reflective boundary condition.
up = @(x) min(x+1, Ny);

% Since H remains constant during the equilibrating of the water depth, the
% main component of the velocities at the half grid points also remain
% constant. To save time during the iterations, we compute all the
% deriviatives a the half grid points and store the main component of the
% velocity vector

% Initialize the arrays:
U = zeros(Nx, Ny-1);           % U(i, j) = u(i + 1/2, j+1)
V = zeros(Nx, Ny-1);           % V(i, j) = v(i, j + 1/2)

% Now enter the data into the arrays. The values of (i, j) correspond to the 
% grid points that will need a half value associated with it. 
% Define some variables that will be used
Hx = 0;
Hy = 0;
denom = 1;

for j = 1:Ny-1
    for i = 1:Nx
        % Calculate the main component of the velocity at (i, j+0.5)
        % First calculate the partial derivatives of H in x and y
        Hx = (H(right(i), j) + H(right(i), up(j)) - H(left(i), j) - H(left(i), up(j)))/(4*dx);
        Hy = (H(i, up(j)) - H(i, j))/dy;
        
        % Use the derivatives to calculate the desired result
        denom = (Hx^2 + Hy^2)^(1/4);
        V(i, j) = -Hy/denom;

        % Calculate the main component of the velocity at (i+0.5, j)
        % First calculate the partial derivatives of H in x and y
        Hx = (H(right(i), up(j)) - H(i, up(j)))/dx;
        Hy = (H(i, up(j+1)) + H(right(i), up(j+1)) - H(i, j) - H(right(i), j))/(4*dy);

        % Now that we have the derivitives, calculate the main part of the
        % velocity term
        denom = (Hx^2 + Hy^2)^(1/4);
        U(i, j) = -Hx/denom;
    end % i for loop
end % j for loop

% Now create a dummy variable to use during the iterations
hn = h;             	% Store values of h at the beginning of a timestep

% Create a variable that will help determine whether or not the system is at 
% an equilibrium state or not
equilibrium = 0;

% Create a variable to store the time that has passed
T = 0;

% The Manning number
m = 33.3;

% Now run the scheme until an equilibrium is achieved.
while (~equilibrium )
    % Assume that the system will reach an equilibrium during this iteration
	equilibrium = 1;
    
    % Now loop through (almost) every point in the grid and update the
    % water depth at each point
    for j = 2:(Ny-1)
        for i = 1:(Nx) 
            % At this point (i, j) get the velocity of (i+0.5, j), 
            % (i-0.5, j), (i, j+0.5), and (i, j-0.5) to calculate the flux
            % of water going into/out of this spot
            
            % Get the velocity at the point (i+0.5, j). To save memory,
            % store it in the flux variable that will be used later
            fluxPlusX = m*U(i, j-1)*( ((hn(right(i), j) + hn(i, j))/2)^(2/3) );
            
            % Determine which way the water is moving and get the total
            % flux accordingly
            if ( fluxPlusX > 0 )
                fluxPlusX = fluxPlusX*hn(i,j);
            else
                fluxPlusX = fluxPlusX*hn(right(i), j);
            end
            
            % Get the velocity at the point (i-0.5, j). To save memory,
            % store it in the flux variable that will be used later
            fluxMinusX = m*U(left(i), j-1)*( ((hn(left(i), j) + hn(i, j))/2)^(2/3) );
            
            % Determine which way the water is moving and get the total
            % flux accordingly
            if ( fluxMinusX > 0 )
                fluxMinusX = fluxMinusX*hn(left(i),j);
            else
                fluxMinusX = fluxMinusX*hn(i, j);
            end
            
            % Get the velocity at the point (i, j+0.5). To save memory,
            % store it in the flux variable that will be used later
            fluxPlusY = m*V(i, j)*( ((hn(i, j+1) + hn(i, j))/2)^(2/3) );

            % Determine which way the water is moving and get the total
            % flux accordingly
            if ( fluxPlusY > 0 )
                fluxPlusY = fluxPlusY*hn(i,j);
            else
                fluxPlusY = fluxPlusY*hn(i, j+1);
            end

            
            % Get the velocity at the point (i, j-0.5). To save memory,
            % store it in the flux variable that will be used later
            fluxMinusY = m*V(i, j-1)*( ((hn(i, j) + hn(i, j-1))/2)^(2/3) );
            
            % Determine which way the water is moving and get the total
            % flux accordingly
            if ( fluxMinusY > 0 )
                fluxMinusY = fluxMinusY*hn(i,j-1);
            else
                fluxMinusY = fluxMinusY*hn(i, j);
            end
            
            % Now that the flux in all four directions has been found,
            % update the water depth
            if i>1 
                if i<Nx
                    if j>1
            h(i, j) = hn(i, j) + (dt/(eta^2))*(R - (fluxPlusX - fluxMinusX)/dx - (fluxPlusY - fluxMinusY)/dy)+(10^2)*(dt/(eta^2))*(h(i+1,j)+h(i-1,j)-2*h(i,j)+h(i,j+1)+h(i,j-1)-2*h(i,j));
            else
            h(i, j) = hn(i, j) + (dt/(eta^2))*(R - (fluxPlusX - fluxMinusX)/dx - (fluxPlusY - fluxMinusY)/dy); 
                    end
                 end
            end
            if isnan(h(i, j))
                error('Getting NaNs');
            end
            
            % Check the difference between the two values of h to see if we
            % have converged or not
            if ( abs( h(i, j) - hn(i, j) ) > tol )
                % The system has not yet come to an equilibrium
                equilibrium = 0;
            end
        end % end i for loop
    end % end j for loop
    
    % Update the time that has elasped
    T = T + dt;
    
    % Have an if statement to control how the bottom boundary is handled
    if ( transport )
        % Solve for the bottom boundary using a transport equation u_t+vu_x=0
        % Let the value alpha be v*dt/dx;
        alpha = 0.75;
        h(:,1) = (dt/(eta^2))*R + (1 - alpha)*hn(:,1) + alpha*hn(:, 2);
    end
    % An else statement is not needed, because if the bottom boundary is
    % held constant, that was acheived before the while loop when hn = h
       
    % Prepare for the next iteration
    hn = h;
end % end while loop