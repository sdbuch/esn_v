function [bstr_out] = bin2hex(bstr)

if mod(length(bstr),4) ~= 0
  error('Pass in a binary string with length divisible by 4');
end

bstr_reshape = reshape(bstr,[],4);
bstr_out = zeros(size(bstr_reshape,1),1);
for i=1:size(bstr_reshape,1)
  switch bstr_reshape(i,1:end)
    case '0000'
      bstr_out(i) = '0';
    case '0001'
      bstr_out(i) = '1';
    case '0010'
      bstr_out(i) = '2';
    case '0011'
      bstr_out(i) = '3';
    case '0100'
      bstr_out(i) = '4';
    case '0101'
      bstr_out(i) = '5';
    case '0110'
      bstr_out(i) = '6';
    case '0111'
      bstr_out(i) = '7';
    case '1000'
      bstr_out(i) = '8';
    case '1001'
      bstr_out(i) = '9';
    case '1010'
      bstr_out(i) = 'A';
    case '1011'
      bstr_out(i) = 'B';
    case '1100'
      bstr_out(i) = 'C';
    case '1101'
      bstr_out(i) = 'D';
    case '1110'
      bstr_out(i) = 'E';
    case '1111'
      bstr_out(i) = 'F';
      
  end
end

bstr_out = char(bstr_out)';

end