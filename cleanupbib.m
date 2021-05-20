%% CLEANUPBIB cleanup unused references in .bib files
% [newBib,bibKeys]=CLEANUPBIB(fileName,bibName,newFile)
% Create a new .bib file with only the bib keys from a specific .tex file. 
% 
% Example:  
%   createbibtex('manuscript.tex','references.bib','newrefs.bib');
%       "newrefs.bib" will contain only references with keys that are
%       mentioned in "manuscript.tex" (within \cite{}).
% 
% Author: Riccardo Iacobucci
% iacobucci (dot) riccardo (at) gmail (dot) com

function [newBib,bibKeys]=cleanupbib(fileName,bibName,newFile)

bibKeys=extractbibkeys(fileName);

newBib=selectbibitems(bibName,bibKeys);

if nargin==3
    savetexttofile(newBib,newFile);
end

end


function newBib=selectbibitems(fileName,bibKeys)

formatSpec = '%s';
fileID = fopen(fileName,'r');
newBib={};
startRec=false;
tline = fgetl(fileID);
while ischar(tline)
    
    if startsWith(tline,'@')
        k1 = strfind(tline,'{');
        k2 = strfind(tline,',');
        thisKey=lower(tline(k1(1)+1:k2(1)-1));
        if ismember(thisKey,bibKeys)
            startRec=true;
            newBib=[newBib , tline];
        else 
            startRec=false;
        end
    else
        if startRec
            newBib=[newBib , tline];
            k1 = count(tline,'{');
            k2 = count(tline,'}');
            if k2>k1
                startRec=false;
            end
        end
    end
    tline = fgetl(fileID);
end

fclose(fileID);


newBib=newBib';

end


function bibKeys=extractbibkeys(fileName)

formatSpec = '%s';
fileID = fopen(fileName,'r');

refNames={};
tline = fgetl(fileID);
while ischar(tline)
    k = strfind(tline,'\cite{');
    if ~isempty(k)
        for j=1:length(k)
            kend = strfind(tline(k(j):end),'}');
            refNames=[refNames , strsplit(lower(tline(k(j)+6:k(j)+kend(1)-2)),',')];
        end
    end
    tline = fgetl(fileID);
end


fclose(fileID);

bibKeys=unique(refNames)';

end


function savetexttofile(textToWrite,fileName)

filePh = fopen(fileName,'w');
fprintf(filePh,'%s\n',textToWrite{:});
fclose(filePh);

end


