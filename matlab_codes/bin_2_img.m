%%%%Deskewd image from hdl code from binary representation transformed to
%%%%float represenation for python
struct.mode='fixed';
truct.mode='fixed';
struct.roundmode='round';
struct.overflowmode='saturate';
struct.format=[16 14];
q=quantizer(struct);
num2bin(q,0.9)
fid = fopen('../ML_number_recognition_SVM/number_dskw.txt','r');
 
i=1;
tline = fgetl(fid);

while ischar(tline)

r(i,:)=tline;
tline = fgetl(fid);

i=i+1;  
end


for k=1:i-1
B(k,:)=bin2num(q,r(k,:));
end;

file_input=fopen('../ML_number_recognition_SVM/number.txt','w');
for i=1:784
    fprintf(file_input,'%2.14f',B(i));
    fprintf(file_input,'\n');
end
fclose(file_input);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%