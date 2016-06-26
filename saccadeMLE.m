function [ rt1, rt2 ] = saccadeMLE( gazepoints, mu_source, mu_target, t1_0, t2_0)
    %SACCADEMLE
    % Input arguments
    %   gazepoints, row vector of 2d column vectors
    %   mu_source, 2d column vector
    %   mu_target, 2d column vector
    %   t1_0, initial guess for saccade start time
    %   t2_0, initial guess for saccade end time


    % Two different concepts, times and indices:
    % Time t  0 1 2 3 4 5
    %         | | | | | |
    % Vector [ 2 3 1 2 1 ]
    %          | | | | |
    % Index i  1 2 3 4 5

    % Aliases
    g = gazepoints;
    
    % Max t, max index
    n = size(gazepoints, 2);
    
    % Dynamic programming memories:    
    % 1) Cumulative sum from t=0 to t=n
    %    so that source_mem(1) gives cum. sum from t=0 to t=1
    source_mem  = -ones(n, 1);
    % 2) Non-cumulative sums from t1 to t2 for each t1 and t2,
    %    so that saccade_mem(1,1) gives square error from t1=0 to t2=1
    %    and that saccade_mem(n,n) gives square error from t1=n-1 to t2=n.
    %    Because t1 < t2 then saccade_mem is an upper triangular matrix
    %    for -1.
    saccade_mem = -ones(n, n); 
    % 3) Cumulative sum from t=n to t=0
    %    so that target_mem(1) gives cum. sum from t=n to t=n-1
    %    and that target_mem(n) gives cum. sum from t=n to t=0.
    target_mem  = -ones(n, 1); 
    
    function SSE = sourceObjective( t1 )
        % Output arguments
        %   SSE, sum of square errors from t=0 to t=t1. I.e. i in [1,t1]
        if t1 == 0
            SSE = 0;
        elseif source_mem(t1) ~= -1
            SSE = source_mem(t1);
        else
            for t = 1:t1
                if source_mem(t) ~= -1
                    continue;
                else
                    delta = g(:,t) - mu_source;
                    d2 = delta'*delta;
                    if t == 1
                        source_mem(t) = d2;
                    else
                        source_mem(t) = d2 + source_mem(t - 1);
                    end
                end
            end
            SSE = source_mem(t1);
        end
    end

    function sse = saccadeObjective( t1, t2 )
        % Output arguments
        %   SSE, sum of square errors from t=t1 to t=t2
        %        i.e. on gazepoints [t1+1, t2]
        if t1 >= t2
            % Includes case that t2 == 0
            sse = 0;
        elseif saccade_mem(t1 + 1, t2) ~= -1
            sse = saccade_mem(t1 + 1, t2);
        else
            sse = 0; % Initial state; sum to this
            for t = (t1 + 1):t2
                % Alpha in [0, 1] and gives the progression of
                % the saccade. Alpha always > 0.
                alpha = (t - t1) / (t2 - t1);
                % Take weighted mean of the source and target points.
                mu = mu_source * (1 - alpha) + mu_target * alpha;
                % Difference vector
                delta = g(:,t) - mu;
                % Distance^2
                d2 = delta'*delta;
                sse = sse + d2;
            end
            saccade_mem(t1 + 1, t2) = sse;
        end
    end

    function SSE = targetObjective( t2 )
        % Output arguments
        %   SSE, sum of square errors from t=n to t=t2
        %        i.e. on gazepoints [t2+1, n]
        if t2 >= n
            SSE = 0;
        elseif target_mem(t2 + 1) ~= -1
            SSE = target_mem(t2 + 1);
        else
            for t = n:-1:(t2 + 1)
                if target_mem(t) ~= -1
                    continue;
                else
                    % Difference vector
                    delta = g(:,t) - mu_target;
                    % Distance^2
                    d2 = delta'*delta;
                    if t == n
                        % No previous sum
                        target_mem(t) = d2;
                    else
                        prev = target_mem(t + 1);
                        target_mem(t) = d2 + prev;
                    end
                end
            end
            SSE = target_mem(t2 + 1);
        end
    end

    function [ t1, t2, source_err, saccade_err, target_err, opt_err ] = find_optimal()
        min_err = Inf;
        min_source_err = Inf;
        min_saccade_err = Inf;
        min_target_err = Inf;
        t1_min_err = 0;
        t2_min_err = n;
        for t1 = 0:n
            for t2 = t1:n
                so_err = sourceObjective(t1);
                sa_err = saccadeObjective(t1, t2);
                ta_err = targetObjective(t2);
                sum_err = so_err + sa_err + ta_err;
                if min_err > sum_err
                    min_err = sum_err;
                    min_source_err = so_err;
                    min_saccade_err = sa_err;
                    min_target_err = ta_err;
                    t1_min_err = t1;
                    t2_min_err = t2;
                end
            end
        end
        t1 = t1_min_err;
        t2 = t2_min_err;
        source_err = min_source_err;
        saccade_err = min_saccade_err;
        target_err = min_target_err;
        opt_err = min_err;
    end

    function [ t1, source_sse, saccade_sse ] = find_t1( t2 )
        % Given t2, find t1=t such that the sum of
        % sourceObjective and saccadeObjective
        % are minimized.
        minSSE = Inf;
        min_sourceSSE = Inf;
        min_saccadeSSE = Inf;
        t_minSSE = 0;
        for t = 0:t2
            sourceSSE = sourceObjective(t);
            saccadeSSE = saccadeObjective(t, t2);
            if minSSE > sourceSSE + saccadeSSE
                minSSE = sourceSSE + saccadeSSE;
                min_sourceSSE = sourceSSE;
                min_saccadeSSE = saccadeSSE;
                t_minSSE = t;
            end
        end
        t1 = t_minSSE;
        source_sse = min_sourceSSE;
        saccade_sse = min_saccadeSSE;
    end

    function [ t2, saccade_sse, target_sse ] = find_t2( t1 )
        % Given t1, find t2=t such that
        % saccadeObjective and targetObjective
        % are minimized.
        minSSE = Inf;
        min_saccadeSSE = Inf;
        min_targetSSE = Inf;
        t_minSSE = 0;
        for t = t1:n
            saccadeSSE = saccadeObjective(t1, t);
            targetSSE = targetObjective(t);
            if minSSE > saccadeSSE + targetSSE
                minSSE = saccadeSSE + targetSSE;
                min_saccadeSSE = saccadeSSE;
                min_targetSSE = targetSSE;
                t_minSSE = t;
            end
        end
        t2 = t_minSSE;
        saccade_sse = min_saccadeSSE;
        target_sse = min_targetSSE;
    end
    
    % Initial quess
    t1 = min([t1_0, n]);
    t2 = min([t2_0, n]);
    sum_sse = Inf;
    % Iterate until no change
    for i = 1:13
        [new_t1, source_sse] = find_t1(t2);
        [new_t2, saccade_sse, target_sse] = find_t2(new_t1);
        sum_sse = source_sse + saccade_sse + target_sse;
        disp([new_t1, new_t2, source_sse, saccade_sse, target_sse, sum_sse]);
        if (new_t1 == t1) && (new_t2 == t2)
            break
        else
            t1 = new_t1;
            t2 = new_t2;
        end
    end
    
    disp(['Mean Squared Error (MSE): ', num2str(sum_sse/n)]);
    
%     disp('Computed optimal:');
%     [t1, t2, o1, o2, o3, osum] = find_optimal();
%     disp([t1, t2, o1, o2, o3, osum]);
    
    rt1 = t1;
    rt2 = t2;
end

