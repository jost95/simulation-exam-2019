function [X,iter] = sa(Cp, Cf, Cs, D, G)
    L = length(Cp);
   
    if L > 12
        throw(MException('Number of periods exceeds limit of 12'))
    end
   
    if L ~= length(Cf) || L ~= length(Cs) || L ~= length(D)
        throw(MException('Length of input vectors does not match'))
    end
    
    if floor(G) ~= G
        throw(MException('G is not integer'))
    end
    
    for i = 1:L
        if floor(D(i)) ~= D(i)
            throw(MException('D is not an array of integers'))
        end
    end

    % Convert to row matrices
    if ~isrow(Cp)
        Cp = Cp';
    end
    
    if ~isrow(Cf)
        Cf = Cf';
    end
    
    if ~isrow(Cs)
        Cs = Cs';
    end
    
    if ~isrow(D)
        D = D';
    end
    
    % Initial (potentially infeasible solution)
    X = ones(L,1)*round(G/2);
    Y = ones(L,1)*0.5;
    Z = ones(L,1)*round(G/2);
    Z(1) = 0; % Cannot store anything first period
    
    % Initial search ranges
    xRange = G;
    yRange = 1;
    
    % Initial feasible solution
    [X,Y,Z] = newSolution(X,Y,Z,xRange,yRange,D,G);
    cost = Cp*X + Cf*toBinary(Y) + Cs*Z;
    
    % SA parameters
    iter = 1;
    completeTempIter = 0;
    iterThresh = 1000;
    temp = 200;
    coolingRate = 0.9;
    iterPerTemp = 10;
    
    while iter < iterThresh
        [newX,newY,newZ] = newSolution(X,Y,Z,xRange,yRange,D,G)
        newCost = Cp*newX + Cf*toBinary(newY) + Cs*newZ;
        diff = abs(cost-newCost);
        
        if newCost < cost
            cost = newCost;
            X = newX;
            Y = newY;
            Z = newZ;
            
            if completeTempIter >= iterPerTemp
                completeTempIter = 0;
                temp = coolingRate*temp;
            end
            
            [xRange, yRange] = reduceSearchSpace(xRange, yRange, iter, temp, diff);
            completeTempIter = completeTempIter + 1;
        elseif rand < exp(-diff/(temp))
            cost = newCost;
            X = newX;
            Y = newY;
            Z = newZ;
        end
        
        iter = iter + 1;
    end
end

function [X,Y,Z] = newSolution(X, Y, Z, xRange, yRange, D, G)
    L = length(X);
    
    % Generate new production decisions
    for i = 1:L
        Y(i) = randStep(Y(i), yRange, 1);
    end
    
    % Generate new number of goods to produce
    for i = 1:L
        % Fullfill demand constraint
        maxProd = G;
        
        if i > 1
            maxProd = min(maxProd,D(i)-Z(i));
        end
        
        X(i) = round(randStep(X(i), xRange, maxProd));
    end
    
    % Fullfill produce constraint
    X = toBinary(Y).*X;
    
    for i = 2:L
        Z(i) = X(i) + Z(i-1) - D(i);
    end
end

function binY = toBinary(Y)
    L = length(Y);
    binY = ones(L,1);
    
    for i = 1:L
        if Y(i) < 0.5
            binY(i) = 0;
        end
    end
end

function step = randStep(val, range, max)
    tryStep = val + randSign()*randi(round(range));
    
    if tryStep > max
        tryStep = max;
    end
        
    if tryStep < 0
        tryStep = 0;
    end
    
    step = tryStep;
end

function sign = randSign()
    if rand < 0.5
        sign = -1;
    else
        sign = 1;
    end
end

function [xRange, yRange] = reduceSearchSpace(oldXRange, oldYRange, iter, temp, diff)
    xRange = oldXRange * exp(-diff/(iter*temp));
    yRange = oldYRange * exp(-diff/(iter*temp));
end