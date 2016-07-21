%% tanh LUTs
o_wordlen = 16;
o_fraclen = 15;
i_wordlen = [4]; % Controls LUT depth = 2^i_wordlen. 1x M9k storing 32 bit words can hold up to 256 words (2^8)
i_intlen = 2;

f = @(x) tanh(x);
df = @(x) 1-tanh(x).^2;

for k = 1:length(i_wordlen)
  i_fraclen = i_wordlen(k)-i_intlen;
  inputs = -2^(i_fraclen+i_intlen):(2^(i_fraclen+i_intlen)-1);
  
  outputs = zeros(length(inputs),1);
  d_outputs = zeros(length(inputs),1);
  
  for i = 1:length(inputs)
    outputs(i) = round(f(inputs(i)/2^i_fraclen)*(2^o_fraclen));
%     d_outputs(i) = round(df(double(inputs(i))/2^i_fraclen)*(2^o_fraclen));
  end
  d_outputs = [diff(outputs); 0]./mean(diff(inputs/2^i_fraclen));
  d_outputs(d_outputs >= 2^(o_fraclen)-1) = 2^(o_fraclen)-1;
  intercepts = zeros(length(inputs)-1,1);
  for i = 1:length(intercepts)
    intercepts(i) = (outputs(i)/2^15.*inputs(i+1)/2^2 - outputs(i+1)/2^15*inputs(i)/2^2) / (inputs(i+1)/2^2-inputs(i)/2^2);
  end
  intercepts = [intercepts; outputs(end)/2^15];
  intercepts = round(intercepts*2^o_fraclen);
  
  % looks like the intercepts can be encoded as Q0.15 signed
  
  
  % convert to 2's complement
  intercepts(intercepts<0) = 2^o_wordlen+intercepts(intercepts<0);
  d_outputs(d_outputs<0) = 2^o_wordlen+d_outputs(d_outputs<0);
  % reshape for address lookups
  twosC_input = inputs;
  twosC_input(twosC_input<0) = 2^o_wordlen+twosC_input(twosC_input<0);
  [~, idxmap] = sort(twosC_input);
  for i = setdiff(1:length(idxmap),1:length(intercepts))
    delete_idxs = find(idxmap==i);
    idxmap(delete_idxs) = [];
  end
  intercepts = intercepts(idxmap);
  d_outputs = d_outputs(idxmap);
  
end

LUT0 = intercepts;
dLUT0 = d_outputs;

% Test the LUT's performance/error
input_neg = 2^15:-1:1;
input_neg = 2^16-input_neg;
input = [input_neg, 0:2^15-1];
tmp = dec2bin(input,16);
addr = tmp(:,1:5);
indices = bin2dec(addr)+1;
f_lookups = intercepts(indices);
df_lookups = d_outputs(indices);
% Convert to double for arithmetic
fvals = f_lookups;
fvals(fvals>=2^15) = -(2^16 - fvals(fvals>=2^15));
dfvals = df_lookups;
dfvals(dfvals>=2^15) = -(2^16 - fvals(fvals>=2^15));
fvals = double(fvals);
dfvals = double(dfvals);
test_in = input;
test_in(test_in>=2^15) = -(2^16-test_in(test_in>=2^15));
interp = (2^-13*test_in(:)).*(dfvals*2^-15) + (fvals*2^-15);
% fvals = double(f_lookups)/;
% dfvals = double(df_lookups);



%% 1/x LUTs (for the NORM LOOKUP---OPTIMIZED FOR SIN^3(X) TASK)
o_wordlen = 32;
o_fraclen = 23; % Q8.23 signed
i_wordlen = 16;
i_fraclen = 7;  % Q8.7 signed

f = @(x) 1./x;
df = @(x) 1./(x).^2;  % this is actually negative, so configure the interp adder to be a subtractor

% SPLIT: TWO M9K for upper 8 bits, ONE for bottom 7 bits of input
% LUT1
inputs = 1:2^8-1; % pre-compute point shift
outputs= round(f(inputs)*(2^o_fraclen));
d_outputs = diff(outputs);

intercepts = zeros(length(inputs)-1,1);
for i = 1:length(intercepts)
  intercepts(i) = (outputs(i)/2^o_fraclen.*inputs(i+1)/2^i_fraclen...
    - outputs(i+1)/2^o_fraclen*inputs(i)/2^i_fraclen)...
    / (inputs(i+1)/2^i_fraclen-inputs(i)/2^i_fraclen);
end

intercepts = [intercepts; outputs(end)/2^o_fraclen];
intercepts = round(intercepts*2^o_fraclen);
outputs = [0, outputs];
d_outputs = [0, d_outputs, 0];
intercepts = [0; intercepts];
LUT1 = intercepts;
dLUT1 = d_outputs;
dLUT1(dLUT1 < 0) =  2^o_wordlen - abs(dLUT1(dLUT1<0));



% LUT2
inputs = 2^-i_fraclen*(1:2^i_fraclen-1);
outputs= round(f(inputs)*(2^o_fraclen));
d_outputs = diff(outputs);

intercepts = zeros(length(inputs)-1,1);
for i = 1:length(intercepts)
  intercepts(i) = (outputs(i)/2^o_fraclen.*inputs(i+1)/2^i_fraclen...
    - outputs(i+1)/2^o_fraclen*inputs(i)/2^i_fraclen)...
    / (inputs(i+1)/2^i_fraclen-inputs(i)/2^i_fraclen);
end

intercepts = [intercepts; outputs(end)/2^o_fraclen];
intercepts = round(intercepts*2^o_fraclen);
outputs = [0, outputs];
d_outputs = [0, d_outputs, 0];
intercepts = [0; intercepts];
LUT2  = intercepts;
dLUT2 = d_outputs;
dLUT2(dLUT2 < 0) = 2^o_wordlen - abs(dLUT2(dLUT2<0));


%% WRITE MIF FILES
%% FIRST FILE: tanh LUT, all interp data
data = [LUT0(:); dLUT0(:)];

% format and write data to a file
fmtstr = sprintf('%%%dd\t:\t%%0%dX;', ceil(log10(length(data))), 4);
data_out = num2str([(0:(length(data)-1)).' data], fmtstr);
dlmwrite('tanh_interp_LUT.txt', data_out, '');

%% SECOND FILE: 1/x (Q8.7 signed in) upper 8 LUT, interp points
data = [LUT1(:)];

% format and write data to a file
fmtstr = sprintf('%%%dd\t:\t%%0%dX;', ceil(log10(length(data))), 8);
data_out = num2str([(0:(length(data)-1)).' data], fmtstr);
dlmwrite('inv_integerbits_interp_funcpoints_LUT.txt', data_out, '');

%% THIRD FILE: 1/x (Q8.7 signed in) upper 8 LUT, slope points
data = [dLUT1(:)];

% format and write data to a file
fmtstr = sprintf('%%%dd\t:\t%%0%dX;', ceil(log10(length(data))), 8);
data_out = num2str([(0:(length(data)-1)).' data], fmtstr);
dlmwrite('inv_integerbits_interp_slopepoints_LUT.txt', data_out, '');

%% FOURTH FILE: 1/x (Q8.7 signed in) lower 7 LUT, all interp data
data = [LUT2(:); dLUT2(:)];

% format and write data to a file
fmtstr = sprintf('%%%dd\t:\t%%0%dX;', ceil(log10(length(data))), 8);
data_out = num2str([(0:(length(data)-1)).' data], fmtstr);
dlmwrite('inv_decimalbits_interp_LUT.txt', data_out, '');

