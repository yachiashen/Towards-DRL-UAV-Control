clc; clear; close all;

rng(0,"twister")

% 載入模型與初始條件
load('QuadModel_X.mat');
load('IC_customHover.mat');
% load('IC_hoverat10ft.mat');
% load('IC_onground_w4000.mat');


mdl = "Quadcopter";
open_system(mdl)

% 定義 Observation 與 Action
obsInfo = rlNumericSpec([16 1]);
obsInfo.Name = 'observations';
obsInfo.Description = 'UAV states';

actInfo = rlNumericSpec([4 1], 'LowerLimit', 0, 'UpperLimit', 100);
actInfo.Name = 'motor_speeds';

% 環境定義
blk = mdl + "/RL Agent";
env = rlSimulinkEnv(mdl, blk, obsInfo, actInfo);

% 時間設定
Ts = 0.005;
Tf = 15;

% Agent Options 設定
agentOptions = rlDDPGAgentOptions();
agentOptions.SampleTime = Ts;
agentOptions.MiniBatchSize = 256;
agentOptions.ExperienceBufferLength = 3e5;
agentOptions.MaxMiniBatchPerEpoch = 50;
agentOptions.ActorOptimizerOptions.LearnRate = 1e-4;
agentOptions.ActorOptimizerOptions.GradientThreshold = 1;
agentOptions.CriticOptimizerOptions.LearnRate = 1e-3;
agentOptions.CriticOptimizerOptions.GradientThreshold = 1;

agentOptions.NoiseOptions.StandardDeviation = 0.2;
agentOptions.NoiseOptions.StandardDeviationDecayRate = 1e-5;
agentOptions.NoiseOptions.MeanAttractionConstant = 0.2; 
agentOptions.NoiseOptions.Variance = 0.04; % = σ^2，標準差的平方（可寫明）
agentOptions.NoiseOptions.MeanAttractionConstant = 0.15; % 決定 OU 過程回到均值速度（控制探索與穩定性平衡）


agentOptions.NumStepsToLookAhead = 1;  % default
agentOptions.DiscountFactor = 0.99;    % 建議寫明

% Exploration Warm-up：先收集 N 步不學習資料
agentOptions.NumWarmStartSteps = 5e3;  % 預設為0，可設 5000 ~ 10000

% 建立 Actor 與 Critic Network
[criticNetwork1, actorNetwork] = createNetworks(16, 4);

actor = rlContinuousDeterministicActor(actorNetwork, obsInfo, actInfo);
critic = rlQValueFunction(criticNetwork1, obsInfo, actInfo);

% load("202506100326.mat", "agent");
agent = rlDDPGAgent(actor, critic, agentOptions);

% 訓練選項
% trainOpts = rlTrainingOptions(...
%     MaxEpisodes=4000,...
%     MaxStepsPerEpisode=floor(Tf/Ts),...
%     ScoreAveragingWindowLength=250,...
%     Plots="training-progress",...
%     StopTrainingCriteria="EvaluationStatistic",...
%     StopTrainingValue=1000,...
%     SaveAgentCriteria="EpisodeReward",...
%     SaveAgentValue=500, ...
%     SaveAgentDirectory="savedAgents");

trainOpts = rlTrainingOptions(...
    MaxEpisodes=10000,...
    MaxStepsPerEpisode=floor(Tf/Ts),...
    ScoreAveragingWindowLength=250,...
    StopTrainingCriteria="None",...
    Plots="training-progress");

trainOpts.UseParallel = false;
trainOpts.ParallelizationOptions.Mode = "async";

doTraining = true;

if doTraining
    evaluator = rlEvaluator(NumEpisodes=10, EvaluationFrequency=100);
    result = train(agent, env, trainOpts, Evaluator=evaluator);
    save("202506111214.mat", "agent");
else
    load("trainedUAVAgent.mat", "agent");
end


% createNetworks.m function (請另存成檔案或放在底部)
function [criticNetwork1, actorNetwork] = createNetworks(obsDim, actDim)

% === Actor Network ===
fc3 = fullyConnectedLayer(actDim, ...
    'Name','fc3', ...
    'BiasInitializer','narrow-normal');

actorNetwork = [
    imageInputLayer([obsDim 1 1],'Normalization','none','Name','state')
    fullyConnectedLayer(400,'Name','fc1')
    reluLayer('Name','relu1')
    fullyConnectedLayer(300,'Name','fc2')
    reluLayer('Name','relu2')
    fc3
    tanhLayer('Name','tanh')
    % scalingLayer('Name','rescale','Scale',50,'Bias',50)  % [-1,1] → [0,100]
    scalingLayer('Name','rescale','Scale',0.5,'Bias',38.86725)  % [-1,1] → [37,47]
];

% === Critic Network 1 ===
statePath = [
    imageInputLayer([obsDim 1 1],'Normalization','none','Name','state')
    fullyConnectedLayer(400,'Name','fc1')
    reluLayer('Name','relu1')
    fullyConnectedLayer(300,'Name','fc2')];

actionPath = [
    imageInputLayer([actDim 1 1],'Normalization','none','Name','action')
    fullyConnectedLayer(300,'Name','fc_act')];

commonPath = [
    additionLayer(2,'Name','add')
    reluLayer('Name','relu2')
    fullyConnectedLayer(1,'Name','out')];

criticNetwork1 = layerGraph(statePath);
criticNetwork1 = addLayers(criticNetwork1, actionPath);
criticNetwork1 = addLayers(criticNetwork1, commonPath);
criticNetwork1 = connectLayers(criticNetwork1,'fc2','add/in1');
criticNetwork1 = connectLayers(criticNetwork1,'fc_act','add/in2');

end
