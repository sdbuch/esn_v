% simulation data
clear all;
WOUT = csvread('_esn_top_tb-W_out255:0.csv');
YHAT = csvread('_esn_top_tb-est31:0.csv');

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

W_out = WOUT(end,2:end);
y_hat = YHAT(:,2:end);
keyboard


X = zeros(8,500);
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
w_struct.ff = true;
w_struct.fb = false;
repu = repmat(u_q*2^-12,1,ceil(500/64));
X(:,1) = [u_q(1)*W_in; u_q(1)];
for i = 2:size(X,2)
  X(:,i) = [[round(tanh( W*X(1:end-1,i-1) + W_in*repu(i) )*2^15)/2^15]; repu(i)];
end


% 
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
keyboard

Wout = yq_train*Xq_train'*((Xq_train*Xq_train')^(-1));

% try a gradient descent approach
Nepoch = 1e3;
Wout_gd = zeros(Nepoch+1,size(Wout,2));
Wout_gd(1,:) = (2*rand(size(Wout))-1);

% stochastic
for i=1:Nepoch
  for j = 1:size(Xq_train,2)
    
    y_est((i-1)*size(Xq_train,2)+j) = Wout_gd((i-1)*size(Xq_train,2)+j,:)*Xq_train(:,j);
    err((i-1)*size(Xq_train,2)+j) = y_est((i-1)*size(Xq_train,2)+j)-yq_train(j);
    grad = 2*(err((i-1)*size(Xq_train,2)+j))*Xq_train(:,j)';
    step = 0.5 * 1/2*norm(Xq_train(:,j),2).^-2;
    Wout_gd((i-1)*size(Xq_train,2)+j+1,:) = Wout_gd((i-1)*size(Xq_train,2)+j,:) - step*grad;
    grad_last = grad;
  end
end

% batch
% for i=1:Nepoch
%   y_est((i-1)*size(Xq_train,2)+j) = Wout_gd((i-1)*size(Xq_train,2)+j,:)*Xq_train(:,j);
%   for j = 1:size(Xq_train,2)
%     
%     grad = 2*(y_est((i-1)*size(Xq_train,2)+j)-yq_train(j))*Xq_train(:,j)';
%     step = 1/2*norm(Xq_train(:,j),2).^-2;
%     Wout_gd((i-1)*size(Xq_train,2)+j+1,:) = Wout_gd((i-1)*size(Xq_train,2)+j,:) - step*grad;
%     grad_last = grad;
%   end
% end
