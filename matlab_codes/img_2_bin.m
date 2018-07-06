struct.mode='fixed';
truct.mode='fixed';
struct.roundmode='round';
struct.overflowmode='saturate';
struct.format=[16 14];
q=quantizer(struct);


%%%Python file being read, numbers transformed into binary, and wrote back
%%%into y_bin.txt
fid = fopen('../ML_number_recognition_SVM/y.txt','r');
j = 1;
while ~feof(fid) 
    xdata(j,:) = str2num(fgetl(fid));
    x_fixed(j,:) = quantize(q,xdata(j,:));
    j = j + 1;
end
fclose all;

file_input=fopen('../ML_number_recognition_SVM/y_bin.txt','w');
j = 1;
k = 1;
pixels = (size(xdata,1) * size(xdata,2));
for i = 1:pixels
    fprintf(file_input,num2bin(q,x_fixed(j,k)));
    if(i == j*784)
        fprintf(file_input,'\n');
        j = j + 1;
        k = 0;
    else
       fprintf(file_input,' ');    
    end
    k = k + 1;
    
end
fclose(file_input);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%images deskewed in python transformed to binary and writen into file.
%this is used for comparison in HDL
fid = fopen('../ML_number_recognition_SVM/python_deskewed.txt','r');
j = 1;
while ~feof(fid) 
    xdata_py(j,:) = str2num(fgetl(fid));
    x_fixed(j,:) = quantize(q,xdata_py(j,:));
    j = j + 1;
end
fclose all;

file_input=fopen('../ML_number_recognition_SVM/python_deskewed_bin.txt','w');
j = 1;
k = 1;
pixels = (size(xdata,1) * size(xdata,2));
for i = 1:pixels
    fprintf(file_input,num2bin(q,x_fixed(j,k)));
    if(i == j*784)
        fprintf(file_input,'\n');
        j = j + 1;
        k = 0;
    else
       fprintf(file_input,' ');    
    end
    k = k + 1;
    
end
fclose(file_input);



