function image = pfmread(filename)
    id = fopen(filename);
    head = fgetl(id);
    if head ~= 'Pf'
       error('Not a valid pfm file.');
       return
    end
    dim = sscanf(fgetl(id), '%d %d');
    endian = sscanf(fgetl(id),'%f');
    if endian ~= -1.0
        error('The endian of the pfm file is undefined');
        return
    end
    image = transpose(fread(id,[dim(1) dim(2)],'float32'));
    fclose(id);
end 