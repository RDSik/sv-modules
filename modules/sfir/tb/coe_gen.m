clc
clear
close

COE_WIDTH = 16;
COE_NAME  = 'fir.coe';

Fs          = 250e6;
Fpass       = 55e6;
Fstop       = 62.5e6;
Astop       = 50;
PASS_RIPPLE = 0.5;
DESIGN      = 'equiripple';

SIN_LUT_NAME = 'sin_lut.mem';
PHASE_WIDTH  = 8;
SAMPLE_NUM   = 2^PHASE_WIDTH;
SAMPLE_WIDTH = 16;

%% Filter coefficients generation
lpFilt = designfilt('lowpassfir', 'PassbandFrequency', Fpass, 'StopbandFrequency', Fstop, ... 
         'PassbandRipple', PASS_RIPPLE, 'StopbandAttenuation', Astop, 'SampleRate', Fs, 'DesignMethod', DESIGN);
filter_coe = round(lpFilt.Coefficients*(2^(COE_WIDTH-1)-1));
fvtool(filter_coe, 'Fs', Fs);

hq = dfilt.dffir(filter_coe); 
set(hq,'arithmetic','fixed');
set(hq, 'coeffwordlength', COE_WIDTH); 
coewrite(hq, 16, COE_NAME);

%% Sin lut generation
sin_fid = fopen(SIN_LUT_NAME, 'w');
if sin_fid == -1
    error('File %s is not opened', SIN_LUT_NAME);
end

A = 2^(SAMPLE_WIDTH-1)-1;
sin_lut = zeros(SAMPLE_NUM, 1);

for i = 1:SAMPLE_NUM
    sin_lut(i) = round(A*sin(2*pi*i/SAMPLE_NUM));
    fprintf(sin_fid, '%04X\n', mod(sine_lut(i), 2^SAMPLE_WIDTH));
end

fclose(sin_fid);
