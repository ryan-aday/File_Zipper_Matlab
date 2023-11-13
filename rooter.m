%% File Rooter
function rooter()
    clear; clc;
    warning('off', 'all');
    fprintf(2, '---SECRET NO/FORN ---\n\n')
    fprintf('File Rooter\n');
    fprintf('Written by Ryan Aday\n');
    fprintf('Version 1: 2023-10-18\n');
    fprintf('Contact: Ryan.Aday@rtx.com\n\n');
    
    makeZIP = input('Type y or n to generate .zip file: ', 's');
    
    root = pwd;
    filelist = [];
    
    filelist = recursiveSearch(root, filelist);
    fprintf('All rooting done.\n');
    exportTable = createCSV(filelist);
    if strcmp(lower(makeZIP), 'y') 
        fprintf('You chose to create a .zip folder.\n');
        exportZIP(exportTable, root);
    else
        fprintf('You did not choose to create a .zip folder.\n');
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Subfunctions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function output = recursiveSearch(dirname, filelist)
    parent = string(struct2cell(dir(dirname)));
    filelist = [filelist parent];
    for i = 1:width(parent)
        if parent{5, i} == "true"
            if ~strcmp(parent{1, i}, ".") && ~strcmp(parent{1, i}, "..")
                dirname_temp = parent{2, i} + "\" + parent{1, i};
                filelist = recursiveSearch(dirname_temp, filelist);
            end
        end
    end
    
    output = filelist;
end

function exportTable = createCSV(filelist)
    filelist_no_dir = filelist(:, contains(filelist(5, :), "false"));
    filelist_no_zip = filelist_no_dir(:, ~contains(filelist_no_dir(1, :), "zip", ...
        'IgnoreCase', true));
    filelist_no_tilde = filelist_no_zip(:, ~contains(filelist_no_zip(1, :), "~"));

    Extension = lower(extractAfter(filelist_no_tilde(1, :), "."));
    while any(contains(Extension, "."))
        Extension = [extractAfter(Extension(contains(Extension, ".")), ".") ...
            Extension(~contains(Extension, "."))];
    end
    Name =  filelist_no_tilde(1, :);
    Directory =  filelist_no_tilde(2, :);
    varnames = {'Name', 'Directory', 'Extension'};

    exportTable = table(Name', Directory', Extension', 'VariableNames', varnames);
    writetable(exportTable, 'filelist.csv')
    fprintf('filelist.csv built.\n')
end

function exportZIP(exportTable, root)
    subfolder_dir = erase(exportTable.Directory, root);
    
    fprintf('New folder created.\n');
    fprintf('Moving files to New folder...\n');
    for i = 1 : length(subfolder_dir)
        mkdir(string(pwd) + "\New" + subfolder_dir(i));
        src_loc = exportTable.Directory(i) + "\" + exportTable.Name(i);
        dest_loc = string(pwd) + "\New\" +  subfolder_dir(i) + ...
            "\" + exportTable.Name(i);
        copyfile(src_loc, dest_loc);
    end
    fprintf('Migration to New folder done.\n');
    
    folder_dir = split(cd, '\');
    root_folder = folder_dir{end};
    fprintf('Creating .zip file...\n')
    zip([char(string(root_folder)) '.zip'], 'New')
    fprintf('.zip file finished.\n')
    fprintf('Removing New folder...\n')
    rmdir("New\", 's')
    fprintf('New removed.\n')
    fprintf('Process complete.\n')
end