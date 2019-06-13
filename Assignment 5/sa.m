function [X,Y,Z,cost,iter] = sa(Cp, Cf, Cs, D, G)    
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
    
    % Initial dummy solution
    X = ones(L,1)*round(G/2);
    Y = ones(L,1);
    Z = zeros(L,1);
    
    % Initial search range, a bit outside the feasible boundries
    xRange = G/2;
    
    % Initial feasible solution
    [X,Y,Z] = newSolution(X,Y,Z,xRange,D,G);
    cost = Cp*X + Cf*Y + Cs*Z;
    
    % SA parameters
    iter = 1;
    completeTempIter = 0;
    sameCostThresh = 50;
    sameCostIter = 0;
    temp = 500;
    coolingRate = 0.98;
    iterPerTemp = 20;
    
    while sameCostIter < sameCostThresh    
        [newX,newY,newZ] = newSolution(X,Y,Z,xRange,D,G);
        
        newCost = Cp*newX + Cf*newY + Cs*newZ;
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
            
            % Reduce search space
            xRange = xRange * exp(-diff/(iter*temp));
            completeTempIter = completeTempIter + 1;
        elseif rand < exp(-diff/(temp))
            cost = newCost;
            X = newX;
            Y = newY;
            Z = newZ;
        end
        
        % Check if optimal solution has changed
        if newCost == cost
            sameCostIter = 0;
        else
            sameCostIter = sameCostIter + 1;
        end
        
        iter = iter + 1;
    end
end

function [X,Y,Z] = newSolution(X, Y, Z, xRange, D, G)
    L = length(X);
    feasible = false;
    
    while ~feasible
        feasible = true;
        Y = ones(L,1);

        % Generate new number of goods to produce
        for i = 1:L
            % Check how much we NEED to produce
            storageSurplus = -D(i);
            
            % Try to empty storage
            if i > 1
                storageSurplus = storageSurplus + Z(i-1);
            end

            % If we have a surplus, we have a possibility to not produce
            if storageSurplus >= 0
                maxProd = G;
                X(i) = randX(X(i), xRange, 0, maxProd);
                
                if X(i) == 0
                    Y(i) = 0;
                end
            else
                % No surplus, try to fullfill demand constraint
                maxProd = G;
                minProd = -storageSurplus;
                
                % Check max production constraint
                if maxProd < minProd
                    feasible = false;
                    break
                end

                X(i) = randX(X(i), xRange, minProd, maxProd);
            end
            
            % Add any surplus to storage
            Z(i) = storageSurplus + X(i);
        end
    end
end

function X = randX(X, range, min, max)
    sign = 1;
    
    if rand < 0.5
        sign = -1;
    end

    tryX = X + sign*rand*range;
    
    if tryX > max
        tryX = max;
    end
        
    if tryX < min
        tryX = min;
    end
    
    X = round(tryX);
end