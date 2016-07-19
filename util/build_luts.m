% tanh LUT
o_wordlen = 16;
o_fraclen = 15;
i_fraclen = 11;
i_intlen = 2;

f = @(x) tanh(x);
df = @(x) 1-tanh(x).^2;

inputs = uint16(0:(2^(i_fraclen+i_intlen)-1));

outputs = uint16(zeros(length(inputs),1));
d_outputs = uint16(zeros(length(inputs),1));

for i = 1:length(inputs)
  outputs(i) = uint16(round(f(double(inputs(i))/2^i_fraclen)*(2^o_fraclen-1)));
  d_outputs(i) = uint16(round(df(double(inputs(i))/2^i_fraclen)*(2^o_fraclen-1)));
end

tanh_approx = double(d_outputs(:)).*double(inputs(:)) + double(outputs(:));