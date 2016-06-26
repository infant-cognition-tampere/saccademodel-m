% Import tools
util = utils;

% S = csvread('01.csv', 1)';
% Mu_ag = [0.5 0.5]'; % Mean of the attention grabber
% Mu_tg = [0.15 0.25]'; % Mean of the target

% Reliability 1.0
% S = csvread('02.csv', 1)';
% Mu_ag = [0.5 0.5]'; % Mean of the attention grabber
% Mu_tg = [0.15 0.75]'; % Mean of the target

% Reliability 1.0; t1: 117, t2: 129, centroids: [0.53 0.53]' [0.87 0.29]'
% S = csvread('03.csv', 1)';
% Mu_ag = [0.5 0.5]'; % Mean of the attention grabber
% Mu_tg = [0.85 0.25]'; % Mean of the target

% Reliability 0.8
S = csvread('04.csv', 1)';
Mu_ag = [0.5 0.5]'; % Mean of the attention grabber
Mu_tg = [0.15 0.75]'; % Mean of the target

% Reliability 0.076
% S = csvread('05.csv', 1)';
% Mu_ag = [0.5 0.5]'; % Mean of the attention grabber
% Mu_tg = [0.85 0.75]'; % Mean of the target

% Reliability 0.435
% S = csvread('06.csv', 1)';
% Mu_ag = [0.5 0.5]'; % Mean of the attention grabber
% Mu_tg = [0.15 0.25]'; % Mean of the target

% Initial values
t1_0 = 60;
t2_0 = 70;

disp('First estimation');
[t1, t2] = saccadeMLE(S, Mu_ag, Mu_tg, t1_0, t2_0);
t1 = max([t1, 1]); % Ensure that not zero because hat centroids.
sourcePoints = S(:,1:t1);
saccadePoints = S(:,(t1 + 1):t2);
targetPoints = S(:,(t2+1):end);
centroids = [Mu_ag Mu_tg];

figure(1);
plot(sourcePoints(1,:), sourcePoints(2,:), 'rx',...
     saccadePoints(1,:), saccadePoints(2,:), 'gx', ...
     targetPoints(1,:), targetPoints(2,:), 'bx', ...
     centroids(1,:), centroids(2,:), 'ko');
axis([0 1 0 1]);

disp('Second estimation');
% Truncate source and target.
w = size(saccadePoints, 2);
sourcePoints_hat = util.lastCols(sourcePoints, w);
targetPoints_hat = util.firstCols(targetPoints, w);
% Recompute source and target means.
Mu_ag_hat = mean(sourcePoints_hat, 2);
Mu_tg_hat = mean(targetPoints_hat, 2);
centr_hat = [Mu_ag_hat Mu_tg_hat];
% Refit the model
S_hat = [sourcePoints_hat saccadePoints targetPoints_hat];
[t1, t2] = saccadeMLE(S_hat, Mu_ag_hat, Mu_tg_hat, t1, t2);
sourcePoints_hat = S_hat(:,1:t1);
saccadePoints_hat = S_hat(:,(t1 + 1):t2);
targetPoints_hat = S_hat(:,(t2+1):end);

figure(2);
plot(sourcePoints_hat(1,:), sourcePoints_hat(2,:), 'rx',...
     saccadePoints_hat(1,:), saccadePoints_hat(2,:), 'gx', ...
     targetPoints_hat(1,:), targetPoints_hat(2,:), 'bx', ...
     centr_hat(1,:), centr_hat(2,:), 'ko');
axis([0 1 0 1]);
