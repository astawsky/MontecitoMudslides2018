function x = triCrout(A, b)
% This function will solve a tridiagonal system of (linear) equations using
% the Crout reduction algorithm. The system to solve specifically is 
%                           Ax = b
% where A is the given input, but consists of only the three non zero
% diagonals ( in column form ) and be is the result. 

% Get the length of the vector, i.e. the dimensions of the matricies
N = length(b);

% First we create variables to hold the triangular matricies L and U. Since
% the original matrix A is tridiagonal, it follows that L is going to have
% 2 nonzero diagonals and U will only have one.
L = zeros(N, 2);
U = zeros(N, 1);

% Now calculate the entries for L and U
L(1, 2) = A(1, 2);
U(1) = A(1, 3)/L(1, 2);

for i = 2:N-1
    % Calculate the ith row of L
    L(i, 1) = A(i, 1);
    L(i, 2) = A(i, 2) - L(i, 1)*U(i-1);
    % Calculate the (i + 1) column of U
    U(i) = A(i, 3)/L(i, 2);
end

% Calculate the last few values
L(N, 1) = A(N, 1);
L(N, 2) = A(N, 2) - L(N, 1)*U(N-1);

% Now that we have the matrices L and U, we solve the linear system.
% First we solve the system Lz = b
% Create a variable for z
z = zeros(N, 1);
% Now Solve:
z(1) = b(1)/L(1, 2);
for i = 2:N
    z(i) = ( b(i) - L(i, 1)*z(i-1) )/( L(i, 2) );
end

% Now we solve for Ux = z
% Create a variable for x
x = zeros(N, 1);
% Now Solve:
x(N) = z(N);
for i = (N-1):-1:1
    x(i) = z(i) - U(i)*x(i+1);
end