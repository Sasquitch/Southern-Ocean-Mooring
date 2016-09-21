mkdir('netcdf');
s = dir('*.DAT3'); %Retrieves all .DAT3 files from current directory
file_list = {s.name}'; %inserts into list to loop over.

path = file_list{1}; %Hardcoded, TODO fix to variable that loops over entire directory.

fileID = fopen(path);
C = textscan(fileID, '%s %s %s %s %s %s %s');
fclose(fileID);

file_name = [path(1:end-5) '.txt']; %Removes .DAT3 adds .txt
comma = ', ';
writefileID = fopen(file_name, 'w');

lineNum = length(C{1}); %Define dimensions of table
len = length(C);

%define variables
raw_file_name = path(1:end-5);

%writes to file
fprintf(writefileID, ['netcdf ' raw_file_name ' {\n']);
fprintf(writefileID, 'dimensions:\n');

fprintf(writefileID, 'variables:\n');

fprintf(writefileID, '// global attributes:\n');
fprintf(writefileID, '        :ncei_template_version = "NCEI_NetCDF_TimeSeriesProfile_Orthogonal_Template_v2.0" ;\n');

fprintf(writefileID, 'data:\n\n' ); 

%data output logic
for i=1:len
    if i == 1
        for j=1:lineNum
            if j==1
                data = C{i}{j};
                concat = [data ' = '];
                fprintf(writefileID, concat);
            end
            if j ~=1 && j ~= 2 && j ~= lineNum-1
                data = C{i}{j};
                concat = [data comma];
                fprintf(writefileID, concat);
            end
            if j==lineNum
                data = C{i}{j};
                concat = [data ' ;'];
                fprintf(writefileID, concat);
            end
            
            %Easier to read in writefile
            if mod(j,5) == 0;
                fprintf(writefileID, '\n');
            end
        end
        fprintf(writefileID, '\n\n');
    end
    
    if i ~= 7
        
        for j=1:lineNum
            if j==1
                data = C{i}{j};
                concat = [data ' = '];
                fprintf(writefileID, concat);
            end
            if j ~=1 && j ~= 2 && j ~= lineNum-1
                data = C{i+1}{j};
                concat = [data comma];
                fprintf(writefileID, concat);
            end
            if j==lineNum
                data = C{i+1}{j};
                concat = [data ' ;'];
                fprintf(writefileID, concat);
            end
            
            
            if mod(j,5) == 0;
                fprintf(writefileID, '\n');
            end
        end
    end
end
fprintf(writefileID, '}');
fclose(writefileID);

movefile(file_name,'netcdf/')