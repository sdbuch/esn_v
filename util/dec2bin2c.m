function [bstr] = dec2bin2c(in, N)

if nargin==1
  N = nextpow2(abs(in))+1;
end

if in >= 0
  out = in;
else
  tmp = dec2bin(-in,N) == '1';
  fmts_inv = '';
  for j = 1:N
    fmts_inv = strcat(fmts_inv, '%d');
  end
  ones_c = num2str(~tmp,fmts_inv);
  ones_c_num = bin2dec(ones_c);
  twos_c_num = ones_c_num+1;
  out = twos_c_num;
  
end

bstr = dec2bin(out,N);

end