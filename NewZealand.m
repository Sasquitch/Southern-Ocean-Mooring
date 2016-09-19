fileID = fopen('Sample.DAT3');
C = textscan(fileID, '%s %s %s %s %s %s %s');
fclose(fileID);




comma = ', ';
writefileID = fopen('writeto.abc', 'w');
lineNum = length(C{1});
len = length(C);

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
    fprintf(writefileID, '\n\n');
end

fclose(writefileID);