function [intval] = bin2c2dec(bstr)

if bstr(1) == '1'
  ones_c = bstr(2:end);
  for i = 1:length(ones_c)
    if ones_c(i) == '1'
      ones_c(i) = '0';
    else
      ones_c(i) = '1';
    end
    intval = -(bin2dec(ones_c)+1);
  end
  
else
  intval = bin2dec(bstr);
end

end