%% Extract_gt3x
% Extract the information from the .gt3x files. and saves the numpy arrays
% to file in the subject folder.

% functions needed:
% 1. gt3x2df.py this extract the raw acceleration data from the nativ
% actigraph files
% 2. gt3x_functions.py this extracts the meta information from the sensors
% to determine the accelerometer site.

clear; clc; close all;

cd('C:\Users\u0117545\Documents\GitHub\EduCan\')
path.root 		= 'C:\Users\u0117545\Documents\GitHub\EduCan\';
path.data       = 'C:\Users\u0117545\KU Leuven\An De Groef - ActiLife EduCan Trial\Data';
timepoint       = 'A12';

%% set python environment
pe = pyenv("Version", "C:\GBW_MyPrograms\Anaconda3\python.exe");

pathToFunc = fileparts(which('gt3x2df.py'));
if count(py.sys.path,pathToFunc) == 0
    insert(py.sys.path,int64(0),pathToFunc);
end

%%
for subj = 161:190

    lower = 1:10:181;
    upper = 10:10:190;

    for num = 1:length(lower)
        if subj >= lower(num) && subj <= upper(num)
            range = [lower(num), upper(num)];
        end
    end

    if subj < 10
        subj_name = ['E00', num2str(subj)];
        subj_range = ['E00' num2str(range(1)), '-E0' num2str(range(2))];
    elseif subj == 10
        subj_name = ['E0', num2str(subj)];
        subj_range = ['E00' num2str(range(1)), '-E0' num2str(range(2))];
    elseif subj <= 90
        subj_name = ['E0', num2str(subj)];
        subj_range = ['E0', num2str(range(1)), '-E0', num2str(range(2))];
    elseif subj > 90 && subj < 100
        subj_name = ['E0', num2str(subj)];
        subj_range = ['E0', num2str(range(1)), '-E', num2str(range(2))];
    elseif subj == 100
        subj_name = ['E', num2str(subj)];
        subj_range = ['E0', num2str(range(1)), '-E', num2str(range(2))];
    else
        subj_name = ['E', num2str(subj)];
        subj_range = ['E', num2str(range(1)), '-E', num2str(range(2))];
    end
    
   

    disp(' ')
    disp(['Processing: ' subj_name])
    disp(['     at timepoint: ', timepoint])

    path.subj   = fullfile(path.data, subj_range, subj_name, timepoint);
    check_subj  = exist(path.subj, "dir");
    content_check = dir(path.subj);

    if check_subj == 7 && size(content_check,1) > 3
        clearvars -except path timepoint pe pathToFunc subj_name subj content nfiles file_counter file_name
        try
            content = dir(path.subj);
            nfiles = size(content,1);
            file_counter = 0;
            for file = 1:nfiles
                if contains(content(file).name, '.gt3x')
                    file_counter = file_counter + 1;
                    file_name{file_counter} = content(file).name;
                end
            end


            %% obtain raw acceleration data non-wear-periods from the hip sensor
            %try
            disp('     Extracting meta data .gt3x files......')
            for f = 1:size(file_name,2)
                temp = py.gt3x_functions.unzip_gt3x_file(fullfile(path.subj,file_name{f}));
                info = py.gt3x_functions.extract_info(temp{2});
                acceleration_scale = py.float(info{'Acceleration_Scale'});
                sample_rate = py.int(info{'Sample_Rate'});

                metadata.acceleration_scale = double(acceleration_scale);
                metadata.sample_rate = double(sample_rate);

                if info{'Limb'} == 'Wrist'
                    if info{'Side'} == 'Left'
                        left_data = file_name{f};
                        disp(['         ', file_name{f}, newline, '         Side: Left Wrist'])
                        log.left = py.gt3x_functions.extract_log(temp{1}, acceleration_scale, sample_rate);
                    elseif info{'Side'} == 'Right'
                        right_data = file_name{f};
                        disp(['         ', file_name{f}, newline, '         Side: Right Wrist'])
                        log.right = py.gt3x_functions.extract_log(temp{1}, acceleration_scale, sample_rate);
                    end
                elseif info{'Limb'} == 'Waist' || info{'Limb'} == 'Thigh'
                    hip_data = file_name{f};
                    disp(['         ', file_name{f}, newline, '         Side: Hip'])
                    log.hip = py.gt3x_functions.extract_log(temp{1}, acceleration_scale, sample_rate);
                end
                clear temp info
            end

            disp('     Done')
            disp('     __________________________')
            %% obtain raw acceleration data 
            disp('     Reading in the hip data:......')
            path.subj = [path.subj, '\\'];
            pyOut.hip = py.gt3x2df.gt3x2df(path.subj, hip_data);
            rawdata.hip = double(pyOut.hip{1});
            T_hip = table(rawdata.hip(:,1), rawdata.hip(:,2), rawdata.hip(:,3));
            T_hip.Properties.VariableNames = {'X', 'Y', 'Z'};


            disp('     Reading in the left data:......')
            pyOut.left = py.gt3x2df.gt3x2df(path.subj, left_data);
            rawdata.left = double(pyOut.left{1});
            T_left = table(rawdata.left(:,1), rawdata.left(:,2), rawdata.left(:,3));
            T_left.Properties.VariableNames = {'X', 'Y', 'Z'};


            disp('     Reading in the right data:......')
            pyOut.right = py.gt3x2df.gt3x2df(path.subj, right_data);
            rawdata.right = double(pyOut.right{1});
            T_right = table(rawdata.right(:,1), rawdata.right(:,2), rawdata.right(:,3));
            T_right.Properties.VariableNames = {'X', 'Y', 'Z'};

            md = table(metadata.acceleration_scale, metadata.sample_rate);
            md.Properties.VariableNames = {'Acceleration_Scale', 'Sample_Rate'};

            disp('     Write data to file:......')
            parquetwrite([path.subj, 'rawdata_hip.parq'],T_hip)
            parquetwrite([path.subj, 'rawdata_left.parq'], T_left)
            parquetwrite([path.subj, 'rawdata_right.parq'],T_right)
            parquetwrite([path.subj, 'metadata.parq'], md)


            disp('     Done')

        catch ME
        end

    end % subject path exists and folder is not empty
end% loop through subjects