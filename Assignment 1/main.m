%% LP solver

% Initialize problem
f = 10000*[4 3 2 2 1];
A = [2 0 0 0 0;
     0 2 2 2 1;
     0.2 1 0 0.5 0;
     1 1 1 0 0;
     0 0 0 1 1];
b = 1000*[36; 216; 18; 34; 28];
lb = [0 0 0 0 0];

noUb = 1000; % very large upper limit
ub = 1000*[16 noUb 2 noUb noUb];
Aeq = [];
beq = [];

% Change to max problem
f = -f;

% Solve
[x,fval,~,~,lambda] = linprog(f,A,b,Aeq,beq,lb,ub);

% Print results
x/10^3;
-fval/10^6;

% Shadow prices
lambda.ineqlin/10^3;
lambda.upper;

%% Change PIII demand iteratively (run init first)
stepSize = 600;
ubBase = ub(3);

changeInDemand = [];
totalProfit = [];
shadowPrices = [];
lastProfit = -1;
currentProfit = 0;

i = 0;
while lastProfit ~= currentProfit
    lastProfit = currentProfit;
    ub(3) = ubBase + 600*i;
    ub(3)
    [~,fval,~,~,lambda] = linprog(f,A,b,Aeq,beq,lb,ub);
    shadowPrices(i+1) = lambda.upper(3);
    currentProfit = -fval;
    changeInDemand(i+1) = 600*i;
    totalProfit(i+1) = currentProfit;
    i = i + 1;
end

plot(changeInDemand, totalProfit)
xlabel('Change in max PIII demand')
ylabel('Total profit')

%% Variating in price for P1 (run init first)
%basePrice = f(1);
basePrice = -6100;
oldPrice = f(1);
baseX = x;
newX = x;

i = 0;
while isequal(baseX,newX)
    oldPrice = f(1);
    f(1) = basePrice + i;
    newX = linprog(f,A,b,Aeq,beq,lb,ub);
    i = i + 1;
end

% Print price
f(1)