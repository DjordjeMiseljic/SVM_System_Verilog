struct.mode='fixed';
truct.mode='fixed';
struct.roundmode='round';
struct.overflowmode='saturate';
struct.format=[16 14];
q=quantizer(struct);


%%%Python file being read, numbers transformed into hex, and wrote back
%%%into y_hex.txt
fid = fopen('../ML_number_recognition_SVM/y.txt','r');
j = 1;
while ~feof(fid) 
    xdata(j,:) = str2num(fgetl(fid));
    x_fixed(j,:) = quantize(q,xdata(j,:));
    j = j + 1;
end
fclose all;

file_input=fopen('../ML_number_recognition_SVM/y_hex.txt','w');
j = 1;
k = 1;
img_num = size(xdata, 1);
pixels = size(xdata, 2);
for j = 1 : img_num
    
    for k = 1 : pixels
        if(mod(k - 1, 16) == 0)
            fprintf(file_input,'\n');
        end
        if(mod(k - 1,2) == 0)
            fprintf(file_input,'0x');
            fprintf(file_input,num2hex(q,x_fixed(j ,k)));
        else
            fprintf(file_input,num2hex(q,x_fixed(j ,k)));
            fprintf(file_input,',');
        end
        
    end
    
end
fclose(file_input);




