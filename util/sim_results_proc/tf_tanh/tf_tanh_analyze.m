clear all;
DIN = csvread('_tf_tanh_tb-D151:0.csv');
DOUT = csvread('_tf_tanh_tb-Q63:0.csv');

% basic tests
fprintf('All DOUT columns equal: %d\n', isequal(DOUT(:,2), DOUT(:,3), DOUT(:,4), DOUT(:,5)));

t = union(DIN(:,1), DOUT(:,1));
% latency compensation
inputs = DIN(:,2:end);
outputs = DOUT(:,2:end);
inputs = [zeros(1,size(inputs,2)); inputs];