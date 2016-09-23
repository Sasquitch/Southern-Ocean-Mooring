filename = 'ItalyNetcdf.txt';
writefileID = fopen(filename, 'w');
%mkdir ('ItalyNetcdf');
raw_data = importdata('Italydata.mat');

dataStruct = raw_data.dat; %Navigate Structs, need to check var names from other data.

%write data logic
fprintf(writefileID, 'data:\n\n');
fields = fieldnames(dataStruct); %code retrieved from http://stackoverflow.com/questions/2803962/iterating-through-struct-fieldnames-in-matlab
for i = 1:numel(fields); 

fprintf(writefileID, '%s', [fields{i} ' = ']); %var = 'data'
Structdata = dataStruct.(fields{i});
len = length(Structdata);

for j=1:len
    data = Structdata(j,1);

        fprintf(writefileID, '%f', data);
        fprintf(writefileID, ', ');
    
    %Easier to read in writefile
    if mod(j,5) == 0;
        fprintf(writefileID, '\n');
    end
end
fprintf(writefileID, ';');
fprintf(writefileID, '\n\n');
end

fprintf(writefileID, '}');
fclose(writefileID);