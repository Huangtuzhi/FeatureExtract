% Features: 12MFCC + 1 En + 1 ZCR +1 En*ZCR
function ccc = FeatureExtract(x)  
xx=double(x);
xx=filter([1 -0.9375],1,xx);
xx=enframe(xx,256,128);

%ZCR
zcr = zeros(size(xx,1),1);
delta= 0.02;
for i=1:size(xx,1)
      x=xx(i,:);
      for j=1:length(x)-1
           if ( x(j)*x(j+1)<0 && abs(x(j)-x(j+1))>delta )
              zcr(i,:)=zcr(i,:)+1;
          end
      end
end

% Mel Coffs 
fh=20000;
melf=2595*log(1+fh/700);
M=24;
i=0:25;
f=700*(exp(melf/2595*i/(M+1))-1);
N=256;
for m=1:24
    for k=1:256
        x=fh*k/N;
        if (f(m)<=x)&&(x<=f(m+1))
            F(m,k)=(x-f(m))/(f(m+1)-f(m));
        else if (f(m+1)<=x)&&(x<=f(m+2))
                F(m,k)=(f(m+2)-x)/(f(m+2)-f(m+1));
            else
                F(m,k)=0;
            end
        end
    end
end


% DCT
for k=1:12
  n=0:23;
  dctcoef(k,:)=cos((2*n+1)*k*pi/(2*24));
end
w = 1 + 6 * sin(pi * [1:12] ./ 12);
w = w/max(w);

% MFCC
for i=1:size(xx,1)               
  y = xx(i,:);
  s = y'.* hamming(256);         
  sf=fft(s);
  t = abs(sf);              
  t = t.^2; 
  En(i,:)=sum(t);       
  c1=dctcoef * log(F * t);  % dctcoefΪDCTϵ�� bank��һ��mel�˲�����ϵ��
  c2 = c1.*w';                    % wΪ��һ�����������
  mc(i,:)=c2';
end

% the output
ccc=[mc,En,zcr,(En.*zcr)];
