clc
clear
close

COE_WIDTH     = 18;
COE_FILE_NAME = 'fir.coe';
COE_MEM_NAME  = 'fir.mem';

FILE_FORMAT = 'mem';

Fs          = 100e6;
Fpass       = 20e6;
Fstop       = 30e6;
Astop       = 60;
PASS_RIPPLE = 0.5;
DESIGN      = 'equiripple';

%% Filter coefficients generation
lpFilt = designfilt('lowpassfir', 'PassbandFrequency', Fpass, 'StopbandFrequency', Fstop, ... 
         'PassbandRipple', PASS_RIPPLE, 'StopbandAttenuation', Astop, 'SampleRate', Fs, 'DesignMethod', DESIGN);
filter_coe = round(lpFilt.Coefficients*(2^(COE_WIDTH-1)-1));
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
