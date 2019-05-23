% Original input

Cp = [3 4 3 4 4 5];
Cf = [12 15 30 23 19 45];
Cs = [1 1 1 1 1 1];
D = [6 7 4 6 3 8];
G = 10;

[X,Y,Z,cost,iter] = sa(Cp,Cf,Cs,D,G);

% Print results
X
cost
iter

%% Input with twelve periods
Cp = [3 4 3 4 4 5 3 6 2 5 4 3];
Cf = [12 15 30 23 19 45 11 16 23 28 18 13];
Cs = [1 1 1 1 1 1 1 1 1 1 1 1];
D = [6 7 4 6 3 8 6 7 4 6 3 8];
G = 10;

[X,Y,Z,cost,iter] = sa(Cp,Cf,Cs,D,G);

% Print results
X
cost
iter


