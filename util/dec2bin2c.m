function [bstr] = dec2bin2c(in, N)

%% Better to just use 2^N - <my_Decimal_val>

in = in(:);
if nargin==1
  N = nextpow2(max(abs(double(in))))+1;
end

if any(strcmp(class(in), {'int8', 'int16', 'int32', 'int64'}))
  intype = ['u' class(in)];
else
  intype = class(in);
end

out = zeros(size(in),intype);
for i = 1:length(in)
  
  if in(i) >= 0
    out(i) = in(i);
  else
    tmp = dec2bin(-double(in(i)),N) == '1';
    fmts_inv = '';
    for j = 1:N
      fmts_inv = strcat(fmts_inv, '%d');
    end
    ones_c = num2str(~tmp,fmts_inv);
    ones_c_num = bin2dec(ones_c);
    twos_c_num = ones_c_num+1;
    out(i) = twos_c_num;
  end
  
  %bstr(i,:) = dec2bin(out,N);
end

bstr = dec2bin(out,N);


end