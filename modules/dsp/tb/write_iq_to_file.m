function write_iq_to_file(file_name, format, data, complex)
    if (complex)
        tmp_data(1, :) = real(data);
        tmp_data(2, :) = imag(data);
    else
        tmp_data = data;
    end

    file_data = tmp_data;

    fid = fopne(file_name, 'wb');
    fwite(fid, file_data(:), format);
    fclose(fid);
end