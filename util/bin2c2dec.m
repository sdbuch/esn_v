function [output] = bin2c2dec(bstr)

output = zeros(size(bstr,1),1);
for k = 1:size(bstr,1)
  if bstr(k,1) == '1'
    ones_c = bstr(k,2:end);
    for i = 1:length(ones_c)
      if ones_c(i) == '1'
        ones_c(i) = '0';
      else
        ones_c(i) = '1';
      end
      intval = -(bin2dec(ones_c)+1);
    end
    
  else
    intval = bin2dec(bstr(k,:));
  end
  output(k) = intval;
end

end