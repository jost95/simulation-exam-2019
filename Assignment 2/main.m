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

%% Problem AA (init above first)
ub = [1 1000]; % no upper bound on x2
[x, fval, ~, ~] = linprog(f, A, b, Aeq, Beq, lb, ub)

%% Problem AB (init above first)
lb = [2 0];
[x, fval, ~, ~] = linprog(f, A, b, Aeq, Beq, lb, ub)

%% Problem ABA
lb = [2 0];
ub = [1000 2]; % no upper bound on x1
[x, fval, ~, ~] = linprog(f, A, b, Aeq, Beq, lb, ub)

%% Problem ABB
lb = [2 3];
[x, fval, ~, ~] = linprog(f, A, b, Aeq, Beq, lb, ub)