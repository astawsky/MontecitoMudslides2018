function [A b] = setCroutMatrices(H, h, h0, B, C, E, dx, dt)
% This function will take single row vectors and create the necessary
% vectors used by the tri-Crout algorithm.

% Define vectors that will make solving for A and b cleaner and easier
V = zeros(10, 1);
Z = zeros(3, 1);

% Get the length of the final arrays
N = length(H) - 1;

% Define the dimensions of A and b
A = zeros(N, 3);
b = zeros(N, 1);

% By the boundary conditions,
b(1) = h0;
A(1, 2) = 1;

% Now define the rest of the A and b matrices using the given values
for i = 2:N
    % The following calculations come from linearizing the sediment flow
    % equation in a single dimension
    V(1) = ( H(i+1) - H(i) )/dx;
    V(2) = ( H(i) - H(i-1) )/dx;
    V(3) = abs( V(1) )^C;
    V(4) = abs( V(2) )^C;
    V(5) = abs( V(1) )^(C+1);
    V(6) = abs( V(2) )^(C+1);
    V(7) = sign( V(1) );
    V(8) = sign( V(2) );
    V(9) = ( (h(i+1) + h(i))/2 )^B;
    V(10) = ( (h(i) + h(i-1))/2 )^B;
    
    Z(1) = E*( (C+1)*V(3)*V(9) )/( 2*dx );
    Z(2) = E*( (C+1)*V(4)*V(10) )/( 2*dx );
    Z(3) = E*( V(5)*V(7)*V(9) - V(6)*V(8)*V(10) )/dx;

    % Calculate the coefficients
    A(i,1) = - Z(2)/dx;
    A(i,2) = 1/dt + ( Z(1) + Z(2) )/dx;
    A(i,3) = - Z(1)/dx;
    
    % Calculate the solution vector
    b(i) = Z(3) - V(1)*Z(1) + V(2)*Z(2) + H(i)/dt;
end % end i for
