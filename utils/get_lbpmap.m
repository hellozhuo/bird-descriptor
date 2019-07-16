
function dictionary = get_lbpmap(bits, method)

maps = cell(1, length(bits));
his_dim = 0;
for i = 1: length(bits)
    bit = bits(i);
    if bit <= 16
        if strcmp(method, 'lbp_u2')
            maps{i} = getmapping(bit, 'u2');
        elseif strcmp(method, 'lbp_riu2')
            maps{i} = getmapping(bit, 'riu2');
        end
        his_dim = his_dim + maps{i}.num;
    else
        bitmap = [0, 2^(bit + 1) - 1];
        for j = 1: bit - 1
            if strcmp(method, 'lbp_u2')
                for k = 1: bit
                    primitive = zeros(1, bit);
                    extra = j - (bit - k + 1);
                    if extra > 0
                        primitive(k:end) = 1;
                        primitive(1: extra) = 1;
                    else
                        primitive(k: k + j -1) = 1;
                    end
                    number = bi2de(primitive);
                    bitmap = [bitmap, number];
                end
            elseif strcmp(method, 'lbp_riu2')
                primitive = zeros(1, bit);
                primitive(1: j) = 1;
                number = bi2de(primitive);
                bitmap = [bitmap, number];
            end
        end
        maps{i} = bitmap;
        his_dim = his_dim + length(bitmap) + 1;
    end
end

dictionary.maps = maps;
dictionary.his_dim = his_dim;

        