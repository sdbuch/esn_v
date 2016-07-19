%% tanh LUTs
o_wordlen = 16;
o_fraclen = 15;
i_wordlen = [4]; % Controls LUT depth = 2^i_wordlen. 1x M9k storing 32 bit words can hold up to 256 words (2^8)
i_intlen = 2;

f = @(x) tanh(x);
df = @(x) 1-tanh(x).^2;

for k = 1:length(i_wordlen)
  i_fraclen = i_wordlen(k)-i_intlen;
  inputs = uint16(0:(2^(i_fraclen+i_intlen)-1));
  
  outputs = uint16(zeros(length(inputs),1));
  d_outputs = uint16(zeros(length(inputs),1));
  
  for i = 1:length(inputs)
    outputs(i) = uint16(round(f(double(inputs(i))/2^i_fraclen)*(2^o_fraclen-1)));
    d_outputs(i) = uint16(round(df(double(inputs(i))/2^i_fraclen)*(2^o_fraclen-1)));
  end
  
  
  if 1
    real_outputs = double(outputs)/2^o_fraclen;
    real_inputs = double(inputs)/2^i_fraclen;
    mse(k) = norm(real_outputs(:)-f(real_inputs(:)))/length(real_inputs);
%     plot(real_inputs, real_outputs);
%     hold on; plot(0:0.01:max(real_inputs),tanh(0:0.01:max(real_inputs)),'--r'); hold off;
%     legend({'interpolated', 'actual'});
%     keyboard
  end
  
end

%% 1/x LUTs (for the NORM LOOKUP---OPTIMIZED FOR SIN^3(X) TASK)
o_wordlen = 16;
o_fraclen = 10; % Q5.10 signed
i_wordlen = 16;
i_fraclen = 4;  % Q11.4 signed

f = @(x) 1./x;
df = @(x) 1./(x).^2;  % this is actually negative, so configure the interp adder to be a subtractor

% SPLIT: ONE M9K for upper 9 bits, ONE for bottom 6 bits
% LUT1
inputs = 2^(2)*(1:(2^9-1));
LUT1  = uint16(round(f(inputs)*(2^o_fraclen)));
LUT1 = [0, LUT1]; % a lookup of 9'b0 gives output 0

% LUT2
inputs = 2^-i_fraclen*(1:2^6-1);
LUT2  = uint16(round(f(inputs)*(2^o_fraclen)));
LUT2 = [0, LUT2]; % a lookup of 6'b0 gives output 0


%% WRITE MIF FILES
%% FIRST FILE: upper 9 1/x lut
data = LUT1(:);

% format and write data to a file
fmtstr = sprintf('%%%dd\t:\t%%0%dX;', ceil(log10(length(data))), 4);
data_out = num2str([(0:(length(data)-1)).' data], fmtstr);
dlmwrite('inv_lookup_Q11-4sgn_to_Q5-10sgn_upper9.txt', data_out, '');

%% SECOND FILE: tanh f, tanh fprime, lower 6 1/x lut
data = [outputs(:); d_outputs(:); LUT2(:)];

% format and write data to a file
fmtstr = sprintf('%%%dd\t:\t%%0%dX;', ceil(log10(length(data))), 4);
data_out = num2str([(0:(length(data)-1)).' data], fmtstr);
dlmwrite('Q2-13_Q0-15tanh__Q11-4_Q5-10_inv_lower6.txt', data_out, '');





