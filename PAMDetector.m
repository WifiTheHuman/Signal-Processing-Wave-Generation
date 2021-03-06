clear;clf;
fsamp = 8;%sample at 50 times data rate

%Generate raised cosine pulse with alpha = 1
delay_rc = 3;
delayrc = 2 * delay_rc * fsamp;

prcos = rcosdesign(1, delay_rc*2, fsamp);
matchedFilter = prcos(end:-1:1);

% Generating random signal data, 5000 symbols long, each symbol is 2 bits
dataSize = 10000;
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

msgLen=length(message); 
noiseq=randn(msgLen,1) ;

SNRMAX = 10;
SNRDB = zeros(SNRMAX, 1);
BERSimulated = zeros(SNRMAX, 1);
BERTheoretical = zeros(SNRMAX, 1);

for i = 0 : 1 : SNRMAX
    %add noise over channel
    
    SNRDB(i+1) = i;                       % 10dB SNR
    SNR=10^(SNRDB(i+1)/10);           % SNR in linear scale
    
    %%%%%%%%%%%%%%%%%%%%%
    %this part not needed for simulated error rate
    Var_n=1/(2*SNR);               % 1/SNR is the noise variance
    signoise=sqrt(Var_n);                % standard deviation
    awgnoise=signoise*noiseq;             % AWGN
    % Add noise to signals at the channel output
    noisymessage=message + awgnoise;
    
    %apply matched filter
    rxmessage = conv(noisymessage,matchedFilter);
    
    sampMsg = rxmessage(delayrc + 1:fsamp:end);
    
    decodedMsg = zeros(dataSize, 1);
    for ii= 1 : 1 : dataSize
        if sampMsg(ii) < 0
            if sampMsg(ii) < -2
                decodedMsg(ii) = -3;
            else
                decodedMsg(ii) = -1;
            end
        else
            if sampMsg(ii) > 2
                decodedMsg(ii) = 3;
            else
                decodedMsg(ii) = 1;
            end
        end
    end
    
    BERSimulated(i+1) = 0.5*erfc(sqrt(SNR));
    BERTheoretical(i+1) = sum((abs(dataArray-decodedMsg) > 0))/(2 * dataSize)
end

figure(1)
semilogy(SNRDB,BERSimulated, SNRDB,BERTheoretical);
xlabel('SNR(dB)')
ylabel('Bit Error Rate')
title('Bit Error Rate vs SNR for 10000 Bits')
legend('Analytical', 'Raised Cosine BER')