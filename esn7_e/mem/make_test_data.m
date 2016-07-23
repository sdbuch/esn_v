writedatfiles = true;
writemiffiles = false;

%% Get some weights in (-1, 1)
w_struct.N = 7;
pr_struct.p = 1;
[W,~,W_in,~] = ESN_init(0.7,w_struct,pr_struct,0,0,0,0);
Wq = round(W*2^15);
W_inq = round(W_in*2^15);

%% Get a sinusoidal input
T = 1e-3;
ppp = 64;       % points per period
Nper = 1;      % num periods
Nt = ppp*Nper;
dt = T*Nper/Nt;
% af = exp(round(log(dt)));
% dt = dt + af;
t = 0:dt:T*Nper-dt;

u = (sin(2*pi/T*t)*2.5);
y = (u.^3);

wordlen = 16;
signed = 1;
intlen = 3;
fraclen = wordlen-signed-intlen;
u_q = round(u*2^fraclen);
y2 = (u_q.^3);

%% Write data files
% These are readmemb format
if writedatfiles
  data = u_q(:);
  data(data<0) = 2^wordlen + data(data<0);
  fmtstr = sprintf('%%0%dX', wordlen/4);
  data_out = num2str(data, fmtstr);
  dlmwrite('input_data.dat', data_out, '');
  
  data = Wq';
  data = data(:);
  data(data<0) = 2^wordlen + data(data<0);
  fmtstr = sprintf('%%0%dX', wordlen/4);
  data_out = num2str(data, fmtstr);
  dlmwrite('weight_data.dat', data_out, '');
  
  data = W_inq(:);
  data(data<0) = 2^wordlen + data(data<0);
  fmtstr = sprintf('%%0%dX', wordlen/4);
  data_out = num2str(data, fmtstr);
  dlmwrite('in_weight_data.dat', data_out, '');
end

% These are .mif format
if writemiffiles
  data = u_q(:);
  data(data<0) = 2^wordlen + data(data<0);
  fmtstr = sprintf('%%%dd\t:\t%%0%dX;', ceil(log10(length(data))), 4);
  data_out = num2str([(0:(length(data)-1)).' data], fmtstr);
  f = fopen('input_data.mif','w+');
  if f~=-1
    fseek(f,0,-1);
    fprintf(f,'WIDTH=%d;\n', 16);
    fprintf(f,'DEPTH=%d;\n', length(data));
    fprintf(f,'ADDRESS_RADIX=UNS;\n');
    fprintf(f,'DATA_RADIX=HEX;\n');
    fprintf(f,'CONTENT BEGIN \n');
    dlmwrite('input_data.mif', data_out, '-append', 'delimiter', '');
    fseek(f,0,1);
    fprintf(f,'END;');
    fclose(f);
  end
  
  for i = 1:size(W,1)
    data = Wq(i,:)';
    data(data<0) = 2^wordlen + data(data<0);
    fmtstr = sprintf('%%%dd\t:\t%%0%dX;', ceil(log10(length(data))), 4);
    data_out = num2str([(0:(length(data)-1)).' data], fmtstr);
    fn = strcat('weight_data', num2str(i), '.mif');
    f = fopen(fn,'w+');
    if f~=-1
      fseek(f,0,-1);
      fprintf(f,'WIDTH=%d;\n', 16);
      fprintf(f,'DEPTH=%d;\n', length(data));
      fprintf(f,'ADDRESS_RADIX=UNS;\n');
      fprintf(f,'DATA_RADIX=HEX;\n');
      fprintf(f,'CONTENT BEGIN \n');
      dlmwrite(fn, data_out, '-append', 'delimiter', '');
      fseek(f,0,1);
      fprintf(f,'END;');
      fclose(f);
    end
    
    
  end
  
  data = W_inq(:);
  data(data<0) = 2^wordlen + data(data<0);
  fmtstr = sprintf('%%%dd\t:\t%%0%dX;', ceil(log10(length(data))), 4);
  data_out = num2str([(0:(length(data)-1)).' data], fmtstr);
  fn = strcat('in_weight_data.mif');
  f = fopen(fn,'w+');
  if f~=-1
    fseek(f,0,-1);
    fprintf(f,'WIDTH=%d;\n', 16);
    fprintf(f,'DEPTH=%d;\n', length(data));
    fprintf(f,'ADDRESS_RADIX=UNS;\n');
    fprintf(f,'DATA_RADIX=HEX;\n');
    fprintf(f,'CONTENT BEGIN \n');
    dlmwrite(fn, data_out, '-append', 'delimiter', '');
    fseek(f,0,1);
    fprintf(f,'END;');
    fclose(f);
  end
end