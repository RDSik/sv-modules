clc
clear

DATA_WIDTH = 16;
PHASE_WIDTH = 14;
SIN_NUM = 2^PHASE_WIDTH;
AMPL = 2^(DATA_WIDTH-1)-1;
FS = 100e6;
FREQ = 20e6;
FREQ_norm = FREQ / (FS/2);

sin_lut = round(AMPL * (1+sin(2*pi*(0:SIN_NUM-1)/SIN_NUM)));

dds_i = zeros(SIN_NUM/2, 1);
dds_q = zeros(SIN_NUM/2, 1);

phase_acc = 0;
phase_inc = round((FREQ * 2^PHASE_WIDTH)/FS);

for i = 1:SIN_NUM/2
    dds_i(i) = sin_lut(mod(phase_acc, SIN_NUM)+1);
    dds_q(i) = sin_lut(mod(phase_acc+SIN_NUM/4, SIN_NUM)+1);
    phase_acc = phase_acc+phase_inc;
end

file_name = 'dds_out.bin';
fid = fopen(file_name, 'rb');
dds_rtl = fread(fid, 'uint32');

dds_matlab = reshape([dds_i dds_q].', [], 1);

signalAnalyzer(dds_matlab, sin_lut);