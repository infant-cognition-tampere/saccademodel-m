function [ rt, dur, mu_src, mu_tgt ] = saccadeEM( gazepoints, mu_source, mu_target )
    % Estimates the reaction time and duration of the saccade by
    % fitting a saccade model to the data.
    % 
    % The model consists of three phases:
    %   1) source phase, gaze is fixated onto a point
    %   2) saccade phase, gaze moves steadily from the source point
    %      onto the target point
    %   3) target phase, gaze becomes fixated onto a point.
    %
    % The estimation is done in Expectation-Maximation manner:
    %   1) Initial locations are given for the source and target points.
    %   2) Expectation: given the source and target points, saccade start
    %      and end times are calculated and the gazepoints are divided
    %      into three classes: source, saccade, and target gazepoints.
    %      In EM terminology, the classes are the latent variables.
    %   3) Maximization: the means of the new source and target gazepoints
    %      become the new values of the source and target points.
    %   4) Repeat steps 2) and 3) until the source and target points stay
    %      the same.
    % 
    % Input arguments
    %   gazepoints, row vector of 2d column vectors
    %   mu_source
    %   mu_target
    %
    % Output arguments
    %   rt, saccadic reaction time.
    %     The number of frames in the source class.
    %   dur, saccade duration
    %     The number of frames in the saccade class.
    %   mu_src
    %     Predicted mean of the source
    %   mu_tgt
    %     Predicted mean of the target

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
    
    % Tools to select columns by time.
    util = utils;
    
    % Initialize
    Mu_s = mu_source;
    Mu_t = mu_target;
    t_start = min([n 60]); % Average SRT is about 200 ms 
    t_end = min([n 70]); % Average duration is about 30 ms

    real_iters = 0
    for i = 1:10
        [t_start_hat,t_end_hat] = saccadeMLE(g, Mu_s,Mu_t, t_start,t_end);
        % Limit times so that there is at least one gazepoint.
        % This prevents next centroids to become NaN.
        t_start_hat = max([t_start_hat, 1]);
        t_end_hat = min([t_end_hat, n - 1]);
        g_source = util.colsTimeToTime(g, 0, t_start_hat);
        g_target = util.colsTimeToTime(g, t_end_hat, size(g,2));
        % Compute means based on windows of 100 ms before and after saccade.
        g_source30 = util.lastCols(g_source, 30);
        g_target30 = util.firstCols(g_target, 30);
        Mu_s_hat = mean(g_source30, 2);
        Mu_t_hat = mean(g_target30, 2);
        % Compute until values to estimate have converged.
        if isequal(Mu_s_hat, Mu_s) && ...
           isequal(Mu_t_hat, Mu_t) && ...
           (t_start_hat == t_start) && ...
           (t_end_hat == t_end)
            real_iters = i
            break;
        else
            Mu_s = Mu_s_hat;
            Mu_t = Mu_t_hat;
            t_start = t_start_hat;
            t_end = t_end_hat;
            disp(['Mu_s', 'Mu_t']);
            disp([Mu_s, Mu_t]);
            disp(['t_start: ', num2str(t_start)]);
            disp(['t_end: ', num2str(t_end)]);
        end
    end
    
    disp(['em iterations: ', real_iters]);
    
    % Results
    rt = t_start;
    dur = t_end - t_start;
    mu_src = Mu_s;
    mu_tgt = Mu_t;
end

