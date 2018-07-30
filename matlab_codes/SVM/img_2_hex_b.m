clear
clc

struct.mode='fixed';
truct.mode='fixed';
struct.roundmode='round';
struct.overflowmode='saturate';
struct.format=[16 14];
q=quantizer(struct);

d=strcat('z_hex_b/b_array.txt');
file_input=fopen(d,'w');
fprintf(file_input,'u32 b_array[10] = {');

for c=0:9
    clear b_data
    clear b_fixed
    %%%Python file being read, numbers transformed into binary, and wrote back
    %%%into y_bin.txt
    b=strcat('../saved_data/bias/bias',int2str(c),'.txt');
    
    fidb = fopen(b,'r');
    j = 1;
    while ~feof(fidb) 
        b_data(j,:) = str2num(fgetl(fidb));
        b_fixed(j,:) = quantize(q,b_data(j,:));
        j = j + 1;
    end

    fclose(fidb);
    

    
    fprintf(file_input,'0x');
    fprintf(file_input,num2hex(q,b_fixed(1,1)));
    if(c<9)
        fprintf(file_input,', ');        
    end

end
fprintf(file_input,'};');
fclose(file_input);

