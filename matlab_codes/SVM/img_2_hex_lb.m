clear
clc

struct.mode='fixed';
truct.mode='fixed';
struct.roundmode='round';
struct.overflowmode='saturate';
struct.format=[16 0];
q=quantizer(struct);



    clear y_data
    clear y_fixed
    %%%Python file being read, numbers transformed into binary, and wrote back
    %%%into y_bin.txt
    y=('../saved_data/labels/labels100.txt');
    
    fidy = fopen(y,'r');
    j = 1;
    while ~feof(fidy) 
        y_data(j,:) = str2num(fgetl(fidy));
        y_fixed(j,:) = quantize(q,y_data(j,:));
        j = j + 1;
    end

    fclose(fidy);
    
    d=strcat('z_hex_lb/lb_hex.txt');
    file_input=fopen(d,'w');
    fprintf(file_input,'u32 labels[100]={\n');

    for i=1:size(y_fixed,1)
        for j=1:size(y_fixed,2)
            fprintf(file_input,'0x');
            fprintf(file_input,num2hex(q,y_fixed(i,j)));
            
            if (i<size(y_fixed,1) || j<size(y_fixed,2))
                fprintf(file_input,', ');
            end
            if (mod(j,10)==0)
                fprintf(file_input,'\n');
            end
        end
    end
        
        
        
    fprintf(file_input,'};');
    fclose(file_input);



