clear
clc

struct.mode='fixed';
truct.mode='fixed';
struct.roundmode='round';
struct.overflowmode='saturate';
struct.format=[16 14];
q=quantizer(struct);


for c=0:9
    clear sv_data
    clear sv_fixed
    %%%Python file being read, numbers transformed into binary, and wrote back
    %%%into y_bin.txt
    sv=strcat('../saved_data/support_vectors/sv',int2str(c),'.txt');
    
    fidsv = fopen(sv,'r');
    j = 1;
    while ~feof(fidsv) 
        sv_data(j,:) = str2num(fgetl(fidsv));
        sv_fixed(j,:) = quantize(q,sv_data(j,:));
        j = j + 1;
    end

    fclose(fidsv);
    
    d=strcat('sv/sv_bin',int2str(c),'.txt');
    file_input=fopen(d,'w');
    for i=1:size(sv_fixed,1)
        for j=1:size(sv_fixed,2)
            fprintf(file_input,num2bin(q,sv_fixed(i,j)));
            if (j<size(sv_fixed,2))
                fprintf(file_input,' ');
            end
        end
        if(i<size(sv_fixed,1))
            fprintf(file_input,'\n');
        end
    end
    fclose(file_input);

end

