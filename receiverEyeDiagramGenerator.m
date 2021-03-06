clear;clf;close all;
fsamp = 8;%sample at 8 times data rate

%Generate raised cosine pulse with alpha = 1
delay_rc = 3;
prcos = rcosdesign( 1, delay_rc*2, fsamp);
matchedFilter = prcos(end:-1:1);

% Generating random signal data for polar signaling
dataSize = 1000;
dataArray = zeros(dataSize, 1);
for i=1:dataSize
   rounded = round(3*rand(1));
   switch (rounded) 
       case 0
           dataArray(i) = -3;
       case 1
           dataArray(i) = -1;
       case 2
           dataArray(i) = 1;
       case 3
           dataArray(i) = 3;
   end 
end
transpose(dataArray);
upData = upsample(dataArray,fsamp);

message=conv(upData,prcos);

rxmessage = conv(message,matchedFilter);

Tau=8;
eye1=eyediagram(rxmessage,2*Tau,Tau,Tau/2);title('Filtered Signal Eye Diagram');