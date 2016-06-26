function x = utils
    % Google: matlab call local functions using function handles
    x.colsBeforeTime = @selectColsBeforeTime;
    x.colsAfterTime = @selectColsAfterTime;
    x.firstCols = @selectFirstCols;
    x.lastCols = @selectLastCols;
    x.colsTimeToTime = @selectColsTimeToTime;
end

function Y = selectColsBeforeTime(X, t)
    % Return columns before given time index.
    Y = selectFirstCols(X, t);
end

function Y = selectColsAfterTime(X, t)
    % Return columns after given time index.
    if t + 1 < size(X, 2)
        Y = X(:,(t + 1):end);
    else
        Y = X;
    end
end

function Y = selectFirstCols(X, n)
    % Return first max n columns of X.
    if n > size(X, 2)
        Y = X;
    else
        Y = X(:,1:n);
    end
end

function Y = selectLastCols(X, n)
    % Return last max n columns of X.
    s = size(X, 2);
    if n > s
        Y = X;
    else
        Y = X(:, (s-n-1):end);
    end
end

function Y = selectColsTimeToTime(X, t1, t2)
    % Return columns according to the time interpretation of indices.
    % Precondition: t1 <= t2 and t1,t2 >= 0.
    % Time t  0 1 2 3 4 5
    %         | | | | | |
    % Vector [ 2 3 1 2 1 ]
    %          | | | | |
    % Index i  1 2 3 4 5
    s = size(X, 2);
    if t1 == t2
        Y = zeros(size(X, 1), 0);
    elseif t2 <= s
        Y = X(:,(t1 + 1):t2);
    elseif t1 < s
        Y = X(:,(t1 + 1):end);
    else
        Y = zeros(size(X, 1), 0);
    end
end
