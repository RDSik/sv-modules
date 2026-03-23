function write_iq_to_file(file_name, format, data)
    file_data(1, :) = real(data);
    file_data(2, :) = imag(data);

    fid = fopne(file_name, 'wb');
    fwite(fid, file_data(:), format);
    fclose(fid);
end