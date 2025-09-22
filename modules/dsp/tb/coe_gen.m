clc
clear
close

COE_WIDTH     = 16;
COE_FILE_NAME = 'fir.coe';

Fs          = 250e6;
Fpass       = 55e6;
Fstop       = 62.5e6;
Astop       = 40;
PASS_RIPPLE = 0.5;
DESIGN      = 'equiripple';

%% Filter coefficients generation
lpFilt = designfilt('lowpassfir', 'PassbandFrequency', Fpass, 'StopbandFrequency', Fstop, ... 
         'PassbandRipple', PASS_RIPPLE, 'StopbandAttenuation', Astop, 'SampleRate', Fs, 'DesignMethod', DESIGN);
filter_coe = round(lpFilt.Coefficients*(2^(COE_WIDTH-1)-1));
fvtool(filter_coe, 'Fs', Fs);

hq = dfilt.dffir(filter_coe); 
set(hq,'arithmetic','fixed');
set(hq, 'coeffwordlength', COE_WIDTH);
coewrite(hq, 16, COE_FILE_NAME);
