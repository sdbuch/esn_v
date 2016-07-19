T = 1e-3;
ppp = 64;       % points per period
Nper = 5;      % num periods
Nt = ppp*Nper;
dt = T*Nper/Nt;
% af = exp(round(log(dt)));
% dt = dt + af;
t = 0:dt:T*Nper-dt;


u = (sin(2*pi/T*t)*0.5);
y = (u.^3);

figure(1);
plot(t, u/max(u)*max(y));
hold on;
plot(t, y, '--r');
hold off;

w = 16;
s = 1;
nf = 0;
f = w-s-nf;
u_q = round(u*2^f)./2^f;
y2 = (u_q.^3);

figure(2);
plot(t,u_q/max(u_q)*max(y2));
hold on;
plot(t,y2,'--r');
hold off;

u_out = u_q*2^f;
u_sub = u_out(1:ppp);
if ~isequal(u_out,repmat(u_sub,1,Nper))
  keyboard
end

% pack hex string representations of data
data = zeros(length(u_sub),1);
for i=1:length(u_sub)
  if u_sub(i) >= 0
    data(i) = u_sub(i);
  else
    
    tmp = dec2bin(-u_sub(i),w) == '1';
    fmts_inv = '';
    for j = 1:w
      fmts_inv = strcat(fmts_inv, '%d');
    end
    ones_c = num2str(~tmp,fmts_inv);
    ones_c_num = bin2dec(ones_c);
    twos_c_num = ones_c_num+1;
%     twos_c = dec2bin(twos_c_num,w)=='1';
    data(i) = twos_c_num;
    
  end
end

% format and write data to a file
fmtstr = sprintf('%%%dd\t:\t%%0%dX;', ceil(log10(length(data))), w/4);
data_out = num2str([(0:(length(u_sub)-1)).' data], fmtstr);
keyboard
dlmwrite('sin_data.txt', data_out, '');

