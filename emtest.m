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
% S = csvread('04.csv', 1)';
% Mu_ag = [0.5 0.5]'; % Mean of the attention grabber
% Mu_tg = [0.15 0.75]'; % Mean of the target

% Reliability 0.076
% This gives an example where SRT and SD are believable even
% though the data is clearly insufficient. Although,
% MSE shows a large error.
% S = csvread('05.csv', 1)';
% Mu_ag = [0.5 0.5]'; % Mean of the attention grabber
% Mu_tg = [0.85 0.75]'; % Mean of the target

% Reliability 0.435
S = csvread('06.csv', 1)';
Mu_ag = [0.5 0.5]'; % Mean of the attention grabber
Mu_tg = [0.15 0.25]'; % Mean of the target



[rt, dur, Mu_ag, Mu_tg] = saccadeEM(S, Mu_ag, Mu_tg);

% Uncomment to directly display known saccade points:
%rt = 76; dur = 107 - rt;

sourcePoints = util.colsBeforeTime(S, rt);
saccadePoints = util.colsTimeToTime(S, rt, rt + dur);
targetPoints = util.colsAfterTime(S, rt + dur);
centroids = [Mu_ag Mu_tg];

srt = rt * 1000 / 300;
sd = dur * 1000 / 300;
disp(['Saccadic Reaction Time: ', num2str(srt), ' ms']);
disp(['Saccade Duration: ', num2str(sd), ' ms']);

figure(1);
plot(sourcePoints(1,:), sourcePoints(2,:), 'rx',...
     saccadePoints(1,:), saccadePoints(2,:), 'gx', ...
     targetPoints(1,:), targetPoints(2,:), 'bx', ...
     centroids(1,:), centroids(2,:), 'ko');
axis([0 1 0 1]);
