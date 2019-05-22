%% Initialize problem

f = [1 5];
A = [2 -1;
     -1 1;
     1 4];
b = [4; 1; 12];
intcon = [1 2];
Aeq = [];
Beq = [];
lb = zeros(1,2);
ub = [];

% Change to max problem
f = -f;

%% With integer condition (init above first)
[x, fval, ~, ~] = intlinprog(f, intcon, A, b, Aeq, Beq, lb, ub);

% Print result
x;
-fval;

%% Without integer condition (init above first)
[x, fval, ~, ~] = intlinprog(f, [], A, b, Aeq, Beq, lb, ub);

% Print the results
x;
-fval;