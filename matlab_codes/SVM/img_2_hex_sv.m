clear
clc

struct.mode='fixed';
truct.mode='fixed';
struct.roundmode='round';
struct.overflowmode='saturate';
struct.format=[16 14];
q=quantizer(struct);
total=751*784;

d=strcat('z_hex_sv/sv_array.txt');
file_input=fopen(d,'w');
name_init=strcat('u32 sv_array[10][',int2str(total),']={');
fprintf(file_input,name_init);
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
    
    
    fprintf(file_input,'\n');
    fprintf(file_input,'{');

    for i=1:size(sv_fixed,1)
        for j=1:size(sv_fixed,2)
            fprintf(file_input,'0x');
            fprintf(file_input,num2hex(q,sv_fixed(i,j)));
            
            if (j<size(sv_fixed,2) || i<size(sv_fixed,1))
                fprintf(file_input,', ');
            end
            
            if(mod(j,10)==0)
                fprintf(file_input,'\n');
            end
            
        end  
    end
    
    fprintf(file_input,'}');
    if(c<9)
        fprintf(file_input,',');
    end

end
fprintf(file_input,'};');
fclose(file_input);
