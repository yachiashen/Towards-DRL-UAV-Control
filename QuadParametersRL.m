% Walking Robot Parameters -- Reinforcement Learning
% Copyright 2020 The MathWorks, Inc.

% Mass parameters
mass = 29.55 / 1000; % Total mass [kg]

% Inertia parameters (these values should be calculated based on your quadcopter's design)
I_xx = 2.3951e-05; % Moment of inertia around x-axis [kg*m^2]
I_yy = 2.3951e-05; % Moment of inertia around y-axis [kg*m^2]
I_zz = 3.2347e-05; % Moment of inertia around z-axis [kg*m^2]

% Frame dimensions
x_motor = 0.325; % Arm length in x-direction [m]
y_motor = 0.325; % Arm length in y-direction [m]

%% Reinforcement Learning (RL) parameters
Ts = 0.005; % Agent sample time
Tf = 10;    % Simulation end time
        
% Scaling factor for RL action [-1 1]
max_speed = 20000 ; % maximum speed 20000rpm

% Initial conditions
phi_0   = 0 ; % initial roll angle [rad]
theta_0 = 0 ; % initial pitch angle [rad]
psi_0   = 0 ; % initial yaw angle [rad]
p_0     = 0 ; % initial roll rate [rad/s]
q_0     = 0 ; % initial pitch rate [rad/s]
r_0     = 0 ; % initial yaw rate [rad/s]
x_0     = 0 ; % initial x-position [m]
y_0     = 0 ; % initial y-position [m]
z_0     = 3.048 ; % initial z-position [m]
u_0     = 0 ; % initial x-velocity [m/s]
v_0     = 0 ; % initial y-velocity [m/s]
w_0     = 0 ; % initial z-velocity [m/s]

% % Calculate initial joint angles
% init_angs_L = zeros(1,2);
% theta = legInvKin(upper_leg_length/100,lower_leg_length/100,-leftinit(1),leftinit(3));
% % Address multiple outputs
% if size(theta,1) == 2
%    if theta(1,2) < 0
%       init_angs_L(1) = theta(2,1);
%       init_angs_L(2) = theta(2,2);
%    else
%       init_angs_L(1) = theta(1,1);
%       init_angs_L(2) = theta(1,2);
%    end
% end
% init_angs_R = zeros(1,2);
% theta = legInvKin(upper_leg_length/100,lower_leg_length/100,-rightinit(1),rightinit(3));
% % Address multiple outputs
% if size(theta,1) == 2
%    if theta(1,2) < 0
%       init_angs_R(1) = theta(2,1);
%       init_angs_R(2) = theta(2,2);
%    else
%       init_angs_R(1) = theta(1,1);
%       init_angs_R(2) = theta(1,2);
%    end
% end