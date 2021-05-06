function H = sediment_flow2(dt, dx, dy, Nx, Ny, h0, h, H, gamma, sigma)
% This function will use the Crank Nicolson scheme and a triCrout
% algorithm to calculate the change in water height (or the movement of
% sediment in the land surface) over a period of time dt using the
% equation:
%   \frac{\partial H}{\partial t} - \eta\frac{\partial h}{\partial t} =
%       \nabla\cdot\left[\frac{\nabla H}{|\nabla H|} h^{\frac{5}{3}\gamma}*
%                           |\nabla H|^{\frac{\gamma}{2} + \delta}\right]
% where: 
%   dt is the time step
%   dx and dy are the discritization sizes in x and y respectively
%   Nx and Ny are the number of points in the discritizations of x and y
%   h0 is the minimum height for the water surface
%   h is the (average) water depth over the time frame
%   H is the water hieght
%   gamma and sigma are constants in the equation
% The output of this function will be the water height after the system has
% been eroded. 

% The functions below will be used to avoid long, complicated, nested
% if/else statements in the code, since we are using periodic boundary
% conditions.
left = @(x) mod(x - 2, Nx) + 1;
right = @(x) mod(x, Nx) +  1;

% The bottom boundary is an absorbing boundary condition and H(x, 1) is
% constant for all x. Thus, this program should never try to access data at
% H(x, 0). However, the top boundary has a zero flux boundary condition,
% and we implement this by a reflexive boundary condition, 
%   i.e. H(x, Ny+1) = H(x, Ny)
up = @(x) min(x+1, Ny);

% Set up some constants that appear in the discritization of the equation
B = (5/3)*gamma;
C = sigma + (gamma/2) - 1;

% The constant for erosion k, is set in such a way that no more than a
% millimeter of sediment is eroded from any one gridpoint. To find this
% value of k, we must do some calculations

% Set defualt values and useful arrays
m = 0.01;
XY = zeros(16, 2);

% At every point on the grid (except where y = 0) we need to do some
% calculations to determine the 'max' value used in the computing of
% the erosion constant
for j = 2:Ny
    for i = 1:Nx
        for q = 1:2
            % The first six values are dependent on whether we are
            % solving for X or Y (determined by q = 1 or 2)
            if ( q == 1 )
                XY(1, 1) = ( H(right(i), up(j)) + H(i, up(j)) - H(i, j-1) - H(right(i), j-1) )/(4*dx);
                XY(2, 1) = ( H(left(i), up(j)) + H(i, up(j)) - H(i, j-1) - H(left(i), j-1) )/(4*dx);
                XY(3, 1) = ( ( h(right(i), j) + h(i, j) )/2 )^B;
                XY(4, 1) = ( ( h(left(i), j) + h(i, j) )/2 )^B;
                XY(5, 1) = ( H(right(i), j) - H(i, j) )/dx;
                XY(6, 1) = ( H(i, j) - H(left(i), j) )/dx;
            else
                XY(1, 2) = ( H(right(i), up(j)) + H(right(i), j) - H(left(i), j) - H(left(i), up(j)) )/(4*dy);
                XY(2, 2) = ( H(right(i), j-1) + H(right(i), j) - H(left(i), j) - H(left(i), j-1) )/(4*dy);
                XY(3, 2) = ( ( h(i, up(j)) + h(i, j) )/2 )^B;
                XY(4, 2) = ( ( h(i, j-1) + h(i, j) )/2 )^B;
                XY(5, 2) = ( H(i, up(j)) - H(i, j) )/dy;
                XY(6, 2) = ( H(i, j) - H(i, j-1) )/dy;
            end
            % The rest of the values are solved in such a way where
            % they are independent of X and Y
            XY(7, q) = XY(5, q)^2 + XY(1, q)^2;
            XY(8, q) = XY(7, q)^(C/2 - 1);
            XY(9, q) = XY(8, q)*XY(7, q);
            XY(10, q) = XY(6, q)^2 + XY(2, q)^2;
            XY(11, q) = XY(10, q)^(C/2 - 1);
            XY(12, q) = XY(11, q)*XY(10, q);
            XY(13, q) = XY(3, q)*XY(9, q);
            XY(14, q) = XY(4, q)*XY(12, q);
            XY(15, q) = XY(13, q)*XY(5, q);
            XY(16, q) = XY(14, q)*XY(6, q);
        end % end q for loop

        % Now that we computed the neccessary values for this grid
        % point, see if it is the max value
        m = max(m, XY(15, 1) - XY(16, 1) + XY(15, 2) - XY(16, 2) );
        % Repeat
    end % end i for loop
end % end j for loop

% Erosion constant 
E = (0.001*dx)/(m*dt); 

% Create a vector that will be used to store a single dimension on the
% H and h matrices to pass to the Matrix generating function
Hrow = zeros(Nx+1, 1);
hrow = zeros(Nx+1, 1);

% To solve for the new water level height, we will solve in the y = x,
% then y = -x, then y then finally the periodic x direction

% The y = x direction ====================================================
% First we create a variable to store the x location with respect to
% the y variable. In other words, this array will store the grid
% locations on this dimension in the form (I(j), j);

I = zeros(Ny, 1);

% Since we are doing diagonally, the we need a new distance
dd = sqrt(dx*dx + dy*dy);

% Now plug in values to the I, Hrow, and hrow vectors
for i = 1:(Nx)

    I(1) = i;
    Hrow(1) = h0;
    hrow(1) = h0;

    for j = 1:Ny-1
        I(j + 1) = right( I(j) );
        Hrow(j + 1) = H( I(j + 1), j + 1 );
        hrow(j + 1) = h( I(j + 1), j + 1 );
    end
    Hrow(Ny+1) = H( right( I(Ny) ), Ny );
    hrow(Ny+1) = h( right( I(Ny) ), Ny );

    % Now get the arrays from the function
    [A, b] = setCroutMatrices(Hrow, hrow, h0, B, C, E, dd, dt);

    % Solve this linear system
    U = triCrout(A, b);

    % Put the results of the linear system in the appropriate place in
    % the array
    for j = 1:Ny
      %  if ((U(j)-h(I(j),j)) > 0)
      %  H( I(j), j ) = U(j);
      %  else
      %  H( I(j),j)=H( I(j),j);  
        H( I(j), j ) = U(j);
    end
end % end i for loop

% The y = -x direction ===================================================
% Use the I vector and dd value defined above since we are again
% solving across the diagonal

% Now plug in values to the I, Hrow, and hrow vectors
for i = 1:(Nx)

    I(1) = i;
    Hrow(1) = h0;
    hrow(1) = h0;

    for j = 1:Ny-1
        I(j + 1) = left( I(j) );
        Hrow(j + 1) = H( I(j + 1), j + 1 );
        hrow(j + 1) = h( I(j + 1), j + 1 );
    end
    Hrow(Ny+1) = H( left( I(Ny) ), Ny );
    hrow(Ny+1) = h( left( I(Ny) ), Ny );

    % Now get the arrays from the function
    [A, b] = setCroutMatrices(Hrow, hrow, h0, B, C, E, dd, dt);

    % Solve this linear system
    U = triCrout(A, b);

    % Put the results of the linear system in the appropriate place in
    % the array
    for j = 1:Ny
      %  if ((U(j)-h(I(j),j)) > 0)
        H( I(j), j ) = U(j);
      %  else
      %  H( I(j),j)=H( I(j),j);    
    end
end % end i for loop         

% The y direction ========================================================
% This direction is simplier since we don't need any special values or
% matrices to store data

for i = 1:(Nx)
    Hrow = [H(i, :), H(i, Ny)];
    hrow = [h(i, :), h(i, Ny)];

    % Solve for the arrays
    [A, b] = setCroutMatrices(Hrow, hrow, h0, B, C, E, dy, dt);

    % Solve the system and put the solution exactly where it belongs
    H(i, :) = triCrout(A, b);
   % if ( (U(i,:)-h(i,:)) > 0 )
     %   H(i,:) = U(i,:);
    %    else
    %    H(i,:)=H(i,:);  
end % end i for loop

% The x direction ========================================================
% This direction is the trickiest due to the periodic boundary
% conditions in this direction. We can still use the set matrices
% function to do majority of the work for us

for j = 2:Ny
    Hrow = [H(:,j); H(1, j); H(2, j)];
    hrow = [h(:,j); h(1,j); h(2,j)];

    % Get the base matricies for the tri Crout method
    [A, b] = setCroutMatrices(Hrow, hrow, 0, B, C, E, dx, dt);

    % Modify these matricies slightly because this is a periodic system
    Ap = [A; 0, 1, 0];
    bp = [b; 0];

    % Solve for three systems
    x = triCrout(Ap, bp);
    y = triCrout(Ap, [1; zeros(Nx+1, 1)]);
    z = triCrout(Ap, [zeros(Nx+1, 1); 1]);

    % Calculate the final solution
    D = (1 - y(Nx+1))*(1 - z(2)) - y(2)*z(Nx+1);
    r = ( x(Nx+1)*(1 - z(2)) + x(2)*z(Nx+1) )/D;
    s = ( x(Nx+1)*y(2) + x(2)*(1 - y(Nx+1)) )/D;

    % Put the solution together
    U = x + r*y + s*z;

    % This solution has two extra rows due to the periodicity
    U(Nx+1) = [];
    U(Nx+1) = [];

    % Plug in the final solution 
    if (H(:,j)-h(:,j) > 0)
    H(:, j) = U;
    else
    H(:,j) = H(:,j);

end % end j for
    
% FINISHED. The surface has been eroded 
end % sediment flow function