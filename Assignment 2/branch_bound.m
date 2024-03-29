%% Below algorithm solves a maximization problem

f = -[1 5];
A = [2 -1;
     -1 1;
     1 4];
b = [4; 1; 12];
Aeq = [];
Beq = [];
lb = zeros(1,2);
ub = ones(1,2)*Inf;

B = -Inf;
xOpt = zeros(1,2);

upperBounds = {ub};
lowerBounds = {lb};

while ~isempty(upperBounds)
    % Extract next problem
    ub = cell2mat(upperBounds(1));
    upperBounds = upperBounds(2:end);
    lb = cell2mat(lowerBounds(1));
    lowerBounds = lowerBounds(2:end);
    
    % Solve the relaxed problem
    [x, fval, exitflag] = linprog(f, A, b, Aeq, Beq, lb, ub);
    fval = -fval;
    
    % Only consider feasible solutions to the LP problem
    if exitflag == 1
        if fval > B
            % Check integer conditions
            if floor(x) == x
                B = fval;
                xOpt = x;
            else
                % Find x to branch on
                i = 1;
                while floor(x(i)) == x(i)
                    i = i + 1;
                end
                
                % Copy the current bounds
                newLb = lb;
                newUb = ub;
                
                % Calculate new bounds
                newLb(i) = ceil(x(i));
                newUb(i) = floor(x(i));
                
                % Add the problems to the list
                lowerBounds(end+1:end+2) = {newLb, lb};
                upperBounds(end+1:end+2) = {ub, newUb};
            end
        end
    end
end

% Print solution
xOpt
B




