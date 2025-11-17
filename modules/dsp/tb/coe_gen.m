clc
clear
close

COE_WIDTH     = 18;
COE_FILE_NAME = 'fir.coe';
COE_MEM_NAME  = 'fir.mem';

FILE_FORMAT = 'mem';

PASS_RIPPLE = 0.001;       % Passband ripple in dB 
STOP_RIPPLE = 0.1;         % Stopband ripple in dB
Fs          = 100e6;       % Sample rate
F           = [20e6 30e6]; % Cutoff frequencies
A           = [1 0];       % Desired amplitudes

Fs_norm = F / (Fs/2);

%% Filter coefficients generation
dev = [(10^(PASS_RIPPLE/20)-1)/(10^(PASS_RIPPLE/20)+1) 10^(-STOP_RIPPLE/20)]; 
[n,fo,ao,w] = firpmord(F,A,dev,Fs);
b = firpm(n,fo,ao,w);
filter_coe = round(b*(2^(COE_WIDTH-1)-1));
fvtool(filter_coe, 'Fs', Fs);

if (strcmp(FILE_FORMAT, 'coe'))
    hq = dfilt.dffir(filter_coe); 
    set(hq,'arithmetic','fixed');
    set(hq, 'coeffwordlength', COE_WIDTH);
    coewrite(hq, 10, COE_FILE_NAME);
elseif (strcmp(FILE_FORMAT, 'mem'))
    fid = fopen(COE_MEM_NAME, 'wb');

    if fid == -1
        error('File is not opened');
    end

    neg_pos = filter_coe < 0;
    dop_code = filter_coe;
    dop_code(neg_pos) = dop_code(neg_pos) + 2^COE_WIDTH;
    
    for i = 1:length(filter_coe)
        fprintf(fid, '%s\n', dec2hex(dop_code(i), ceil((COE_WIDTH/4))));
    end
else
    error('Not valid file fomat!');
end
