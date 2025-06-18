IC = struct;

IC.X = 0;
IC.Y = 0;
IC.Z = 3.048;        % 初始高度

IC.P = 0;
IC.Q = 0;
IC.R = 0;

IC.Phi = 0;
IC.The = 0;
IC.Psi = 0;

IC.U = 0;
IC.V = 0;
IC.W = 0;

IC.w1 = 4108;
IC.w2 = 4108;
IC.w3 = 4108;
IC.w4 = 4108;

save('IC_customHover.mat', 'IC');   % 儲存成檔案