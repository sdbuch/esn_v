do_matlab_sim = 0;

% simulation data
clear all;
dvalid = csvread('_esn7e_st_src_tb-data_valid.csv');
dout = csvread('_esn7e_st_src_tb-data_out31:0.csv');
WOUT = csvread('_esn7e_st_src_tb.U0.ESN0-W_out255:0.csv');
XSTATE = csvread('_esn7e_st_src_tb.U0.ESN0-XSTATE127:0.csv');

t_dvalid = dvalid(:,1);
tvalid = t_dvalid(~~dvalid(:,2));
t_dout = dout(:,1);
for i = 1:length(tvalid)
  
  idx = find(t_dout==tvalid(i),1,'first');
  if ~isempty(idx)
    dout_valid(i,:) = dout(idx,2:end);
  end
end
% repeat for output weights
t_wout = WOUT(:,1);
for i = 1:length(tvalid)
  
  idx = find(t_wout==tvalid(i),1,'first');
  if ~isempty(idx)
    wout_valid(i,:) = WOUT(idx,2:end);
  end
end
% process XSTATE by scaling msb column
xstate_valid = XSTATE(:,2:end);
xstate_valid(:,1) = 8*xstate_valid(:,1);

u_raw_valid = dout_valid(:,1);
yhat_raw_valid = dout_valid(:,2);

u_valid = zeros(size(u_raw_valid));
yhat_valid = zeros(size(yhat_raw_valid));
for i = 1:length(u_raw_valid)
  tmp = dec2bin(u_raw_valid(i),16);
  tmp_trunc = strcat(tmp(2:8), tmp(10:end));
  tmp_dec = bin2dec(tmp_trunc);
  if tmp_dec >= 2^13
    tmp_dec = -(2^14-tmp_dec);
  end
  u_valid(i) = tmp_dec;
  
  
  tmp = dec2bin(yhat_raw_valid(i),16);
  tmp_trunc = strcat(tmp(2:8), tmp(10:end));
  tmp_dec = bin2dec(tmp_trunc);
  if tmp_dec >= 2^13
    tmp_dec = -(2^14-tmp_dec);
  end
  yhat_valid(i) = tmp_dec;
  
end

figure(1);
plot(yhat_valid*2^-9)
hold on; plot((u_valid*2^-10).^3,'--r'); hold off;
title('predicted output and true output comparison');

figure(2);
err_norm2 = (yhat_valid*2^-9 - (u_valid*2^-10).^3).^2;
plot(err_norm2);
title('instantaneous squared error over training cycles');

figure(3);
plot(xstate_valid);
title('reservoir states during simulation period');

figure(4);
test_weights = wout_valid(end-500,:);
plot(test_weights*xstate_valid(end-499:end,:)');
title('predicted output, taking weights at 500 cycles before end of simulation period');



% more stuff
if do_matlab_sim
  
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
end