clc
clear
close all
dbstop if error

for prob=1:28
    if prob<=10
        Data_Path{prob,1} = fullfile(sprintf('Mk%02d.mat', prob));
    else
        Data_Path{prob,1} = fullfile(sprintf('%02da.mat', prob-10));
    end
end
outDir = 'txt_cases';
if ~exist(outDir,'dir')
    mkdir(outDir);
end
for prob=1:28
    clearvars -except Data_Path prob outDir
    load(Data_Path{prob,1});
    W=M+2;
    aw=ceil(W/2);

    for job=1:N
        for oper=1:H(job)
            if rand<0.15
                I(job,oper)=1;
            else
                I(job,oper)=0;
            end
            Mac_Set=find(Time{job}(oper,:)~=0);
            W_Set=randperm(W,aw);

            for mac=Mac_Set
                for work=W_Set
                    Time1{job,oper}(mac,work)=Time{job}(oper,mac);
                    Time2{job,oper}(work)=Time{job}(oper,mac);
                end
            end

        end
    end



    Job=N;

    for job = 1:Job
        for oper = 1:H(job)
            if I(job,oper) == 0
                Time2{job,oper}(:) = 0;
            else
                Time1{job,oper}(:) = 0;
            end
        end
    end


    fileName = sprintf('Problem_%02d.txt', prob);
    filePath = fullfile(outDir, fileName);

    fid = fopen(filePath, 'w');
    if fid == -1
        error('无法创建文件：%s', filePath);
    end
    Mac=M;
    Work=W;
    fprintf(fid, '%d %d %d\n', Job, Mac, Work);

    for job = 1:Job

        fprintf(fid, '%d ', H(job));

        for oper = 1:H(job)

            if I(job,oper) == 0
                [mac_idx, work_idx, val] = find(Time1{job,oper});
                combo_num = numel(val);

                fprintf(fid, '%d %d ', 0, combo_num);

                for s = 1:combo_num
                    fprintf(fid, '%d %d %d ', mac_idx(s), work_idx(s), val(s));
                end

            else
                work_idx = find(Time2{job,oper} > 0);
                val = Time2{job,oper}(work_idx);
                combo_num = numel(val);

                fprintf(fid, '%d %d ', 1, combo_num);

                for s = 1:combo_num
                    fprintf(fid, '%d %d ', work_idx(s), val(s));
                end
            end

        end

        fprintf(fid, '\n');
    end

    fclose(fid);
    fprintf('已写入: %s\n', filePath);


end