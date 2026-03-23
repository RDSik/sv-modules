function data = read_iq_from_file(file_name, format)
    fid = fopen(file_name, 'rb');
    
    if fid == -1
        error('File %s is not opened', file_name);
    end

    file_data = fread(fid, format);
    data = file_data(1:2:end) + 1i*file_data(2:2:end);
end