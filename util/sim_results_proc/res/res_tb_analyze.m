% simulation data
clear all;
DIN0 = csvread('_res_tb.DUT.PE0-DATA127:0.csv');
%DIN1 = csvread('_res_tb.DUT.PE1-DATA127:0.csv');
WIN0 = csvread('_res_tb.DUT.PE0-WEIGHT511:0.csv');
WIN1 = csvread('_res_tb.DUT.PE1-WEIGHT511:0.csv');
% XSTATE = csvread('_res_tb-xstate127:0.csv');
XSTATE1 = csvread('xstate_256depthTanhLUT.csv');
XSTATE2 = csvread('xstate_2inputshifts.csv');

% saved data, sr is 0.7
f = fopen('~/projects/verilog/esn_v/esn7_e/mem/weight_data.dat', 'r+');
weights = textscan(f,'%s');
fclose(f);
weights = hex2dec(cell2mat(weights{1}));
weights(weights>=2^15) = -(2^16-weights(weights>=2^15));
f = fopen('~/projects/verilog/esn_v/esn7_e/mem/in_weight_data.dat', 'r+');
in_weights = textscan(f,'%s');
fclose(f);
in_weights = hex2dec(cell2mat(in_weights{1}));
in_weights(in_weights>=2^15) = -(2^16-in_weights(in_weights>=2^15));

% w1_reshape = reshape(WIN1(2:end),8,4);
% w0_reshape = reshape(WIN0(2:end),8,4);
% fW_in = [w1_reshape(1,:), w0_reshape(1,:)];
% fW = [w1_reshape(2:end,:), w0_reshape(2:end,:)];


% latency compensation
% statedata = XSTATE(:,2:end)*2^-15;
statedata1 = XSTATE1(:,2:end)*2^-15;
statedata2 = XSTATE2(:,2:end)*2^-15;

X = zeros(7,size(statedata1,1));
W = reshape(weights*2^-15,7,7)';
W_in = in_weights*2^-15;
T = 1e-3;
ppp = 64;       % points per period
Nper = 1;      % num periods
Nt = ppp*Nper;
dt = T*Nper/Nt;
% af = exp(round(log(dt)));
% dt = dt + af;
t = 0:dt:T*Nper-dt;
u = (sin(2*pi/T*t)*2.5);
u_q = round(u*2^12);
w_struct.N = 7;
w_struct.M = 1;
w_struct.L = 1;
w_struct.ff = false;
w_struct.fb = false;
repu = repmat(u_q*2^-12,1,ceil(250/64));
X(:,1) = u_q(1)*W_in;
for i = 2:size(X,2)
  X(:,i) = round(tanh( W*X(:,i-1) + W_in*repu(i) )*2^15)/2^15;
end

keyboard

% Test by training
y_q = u_q.^3;
y_q = y_q*2^-36;
% Xq = statedata(:,2:end)';
Xq = X;
y_q = repmat(y_q,1,2^nextpow2(size(Xq,2))/length(y_q));
Xq_train = Xq(:,10:150);
yq_train = y_q(:,10:150);
Xq_test = Xq(:,151:end);
yq_test = y_q(:,151:size(Xq,2));
Wout = yq_train*Xq_train'*((Xq_train*Xq_train')^(-1));

% try a gradient descent approach
Nepoch = 1e4;
Wout_gd = (2*rand(size(Wout))-1);
for i=1:Nepoch
  for j = 1:size(Xq_train,2)
    y_est = Wout_gd*Xq_train(:,j);
    grad = 2*(y_est-yq_train(j))*Xq_train(:,j)';
    step = 1/2*norm(Xq_train(:,j),2).^-2;
    Wout_gd = Wout_gd - step*grad;
  end
end


