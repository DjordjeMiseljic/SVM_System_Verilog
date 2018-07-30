clear
clc

struct.mode='fixed';
truct.mode='fixed';
struct.roundmode='round';
struct.overflowmode='saturate';
struct.format=[16 14];
q=quantizer(struct);

d=strcat('z_hex_lt/lt_array.txt');
file_input=fopen(d,'w');
fprintf(file_input,'u32 lt_array[10][751]={');

for c=0:9
    clear l_data
    clear t_data
    clear lt_data
    clear lt_fixed
    %%%Python file being read, numbers transformed into binary, and wrote back
    %%%into y_bin.txt
    l=strcat('../saved_data/lambdas/lambdas',int2str(c),'.txt');
    t=strcat('../saved_data/targets/targets',int2str(c),'.txt');
    fidl = fopen(l,'r');
    fidt = fopen(t,'r');
    j = 1;
    while ~feof(fidl) 
        l_data(j,:) = str2num(fgetl(fidl));
        t_data(j,:) = str2num(fgetl(fidt));
        j = j + 1;
    end
    l_data=1000*l_data;
    lt_data=l_data.*t_data;
    j = 1;
    for k=1:size(lt_data,1) 
        lt_fixed(j,:) = quantize(q,lt_data(j,:));
        j = j + 1;
    end
 
    fclose(fidl);
    fclose(fidt);
 
    
    fprintf(file_input,'\n');
    fprintf(file_input,'{');
    for i=1:size(lt_fixed,1)  
            fprintf(file_input,'0x');
            fprintf(file_input,num2hex(q,lt_fixed(i,1)));
        if(i<size(lt_fixed,1))
            fprintf(file_input,', ');
        end
        if(mod(i,10)==0)
            fprintf(file_input,'\n');
        end
    end
    
    fprintf(file_input,'}');
    if(c<9)
        fprintf(file_input,',');
    end
    
end
fprintf(file_input,'};');
fclose(file_input);

