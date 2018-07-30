clear
clc

struct.mode='fixed';
truct.mode='fixed';
struct.roundmode='round';
struct.overflowmode='saturate';
struct.format=[16 14];
q=quantizer(struct);



    clear y_data
    clear y_fixed
    %%%Python file being read, numbers transformed into binary, and wrote back
    %%%into y_bin.txt
    y=('../saved_data/test_images/yy.txt');
    
    fidy = fopen(y,'r');
    j = 1;
    while ~feof(fidy) 
        y_data(j,:) = str2num(fgetl(fidy));
        y_fixed(j,:) = quantize(q,y_data(j,:));
        j = j + 1;
    end

    fclose(fidy);
    
    d=strcat('y/y_bin.txt');
    file_input=fopen(d,'w');
    for i=1:size(y_fixed,1)
        for j=1:size(y_fixed,2)
            fprintf(file_input,num2bin(q,y_fixed(i,j)));
            if (i<size(y_fixed,1) || j<size(y_fixed,2))
                fprintf(file_input,' ');
            end
        end
        if(i<size(y_fixed,1))
            fprintf(file_input,'\n');
        end
    
    

    end
fclose(file_input);

