clear
clc

struct.mode='fixed';
truct.mode='fixed';
struct.roundmode='round';
struct.overflowmode='saturate';
struct.format=[16 14];
q=quantizer(struct);


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
    
    d=strcat('b/b_bin',int2str(c),'.txt');
    file_input=fopen(d,'w');
    for i=1:size(b_fixed,1)
        for j=1:size(b_fixed,2)
            fprintf(file_input,num2bin(q,b_fixed(i,j)));
            if (j<size(b_fixed,2))
                fprintf(file_input,' ');
            end
        end
        if(i<size(b_fixed,1))
            fprintf(file_input,'\n');
        end
    end
    fclose(file_input);

end

