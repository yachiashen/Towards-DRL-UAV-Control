clc; clear; close all;

obsInfo = rlNumericSpec([16 1]);
obsInfo.Name = 'observations';
obsInfo.Description = 'UAV states';

actInfo = rlNumericSpec([4 1], 'LowerLimit', 0, 'UpperLimit', 100);
actInfo.Name = 'motor_speeds';


% 載入訓練好的 Agent
load('202506101112.mat','agent');

% load('savedAgents/Agent988.mat', 'saved_agent');  % Max: 988 
% agent = saved_agent;

% load('savedAgents/Agent500.mat','saved_agent');
% agent = saved_agent;

load('QuadModel_X.mat');
load('IC_customHover.mat');
% load('IC_hoverat10ft.mat');

model = 'Quadcopter';
% rlBlock = [model '/RL Agent'];
% env = rlSimulinkEnv(model, rlBlock, obsInfo, actInfo);

Tf = 120;
Ts = 0.005;
set_param(model, 'StopTime', num2str(Tf));

simOut = sim(model, 'ReturnWorkspaceOutputs', 'on');


tout = simOut.simOut.time;
yout = simOut.simOut.signals.values;


addpath(genpath('Graphical User Interfaces'));
QuadAnim4