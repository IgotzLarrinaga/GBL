function Graficar()
foldername = uigetdir;

if isequal(foldername, 0)
   disp('Kantzela ein dau')
   return;
end

fig = figure;

nextBtn = uicontrol('Style', 'pushbutton', 'String', 'Next',...
        'Position', [80 20 50 20]);
backBtn = uicontrol('Style', 'pushbutton', 'String', 'Back',...
        'Position', [20 20 50 20]);
allBtn = uicontrol('Style', 'pushbutton', 'String', 'All',...
        'Position', [140 20 50 20]);
refreshBtn = uicontrol('Style', 'pushbutton', 'String', 'Refresh',...
        'Position', [340 20 60 20]);
avgBtn = uicontrol('Style', 'pushbutton', 'String', 'Average',...
        'Position', [200 20 60 20]);
openBtn = uicontrol('Style', 'pushbutton', 'String', 'Open',...
        'Position', [400 20 60 20]);

filterBox = uicontrol('Style', 'edit', 'String', '',...
        'Position', [280 20 50 20]);

dataIndex = 1;
files = {};
allData = {};
dataAvg = {};

nextBtn.Callback = @(src,event) plotData(src, event, 1);
backBtn.Callback = @(src,event) plotData(src, event, -1);
allBtn.Callback = @(src,event) plotAllData(src, event);
avgBtn.Callback = @(src,event) average(src, event);
refreshBtn.Callback = @(src,event) refreshData(src, event);
openBtn.Callback = @(src,event) openDirectory(src, event);

    function openDirectory(src, event)
        foldername = uigetdir;
        if isequal(foldername, 0)
           disp('Kantzela ein dau')
           return;
        end
        refreshData(src, event);
    end

    function refreshData(src, event)
    files = dir(fullfile(foldername, ['*', filterBox.String, '*.log']));
    allData = {};
    
    h = waitbar(0, 'Processing files...');
    
        for fileIndex = 1:length(files)
        data = preprocessFile(files(fileIndex));
            if ~isempty(data.position)
            allData{end+1} = data;
            end
        
            waitbar(fileIndex / length(files), h, sprintf('Processing file %d of %d...', fileIndex, length(files)));
        end
    
        close(h);
    
        dataIndex = 1;
        if ~isempty(allData)
            plotFile(allData{dataIndex});
        end
    end

    function plotData(src, event, direction)
        dataIndex = dataIndex + direction;
        if dataIndex > 0 && dataIndex <= length(allData)
            plotFile(allData{dataIndex});
        else
            disp('No more files to display');
        end
    end

    function plotAllData(src, event)
        hold on;
        legendInfo = cell(length(allData), 1); 
        for dataIndex = 1:length(allData)
            plotFile(allData{dataIndex});
            legendInfo{dataIndex} = allData{dataIndex}.name;
        end
        legend(legendInfo);
        hold off;
    end

    function average(src, event)
    disp('Average function called');

    minLen = min(cellfun(@(x) length(x.position), allData));
    disp(['minLen: ', num2str(minLen)]);

    positionAvg = zeros(minLen, 1);
    forceAvg = zeros(minLen, 1);

    for dataIndex = 1:length(allData)
        positionAvg = positionAvg + allData{dataIndex}.position(1:minLen);
        forceAvg = forceAvg + allData{dataIndex}.force(1:minLen);
    end

    positionAvg = positionAvg / length(allData);
    forceAvg = forceAvg / length(allData);
    dataAvg = struct('name', 'Average', 'position', positionAvg, 'force', forceAvg);
    plotFile(dataAvg);
end

    function data = preprocessFile(file)
    fullpath = fullfile(file.folder, file.name);
    data = readtable(fullpath,'FileType','text');
    dataCell = table2cell(data);
    record1_line = find(contains(dataCell, '[Record 1]'));
    record2_line = find(contains(dataCell, '[Record 2]'));
    lines_between = dataCell(record1_line+3:record2_line-1, :);
    lines_after = dataCell(record2_line+3:end, :); 
    separated_data = cell(size(lines_between, 1) + size(lines_after, 1), 1);

    for i = 1:size(lines_between, 1)
        line_data = strsplit(lines_between{i, :}, ';');
        separated_data{i, :} = line_data(1:3);
    end

    for i = 1:size(lines_after, 1)
        line_data = strsplit(lines_after{i, :}, ';');
        separated_data{i + size(lines_between, 1), :} = {num2str(i + size(lines_between, 1)), line_data{2}, line_data{3}};
    end

    position = zeros(size(separated_data, 1), 1);
    force = zeros(size(separated_data, 1), 1);

    for i = 1:size(separated_data, 1)
        position(i) = str2double(separated_data{i}{2});
        force(i) = str2double(separated_data{i}{3});
    end

    data = struct('name', file.name, 'position', position, 'force', force);
end

    function plotFile(data)
        plot(data.position, data.force);
        rectangle('position',[240.5 11.0 4.0 20.0])
        rectangle('position',[244 90.0 3.0 20.0])
        grid on
        xlim([240 253])
        ylim([-20 300])
        xlabel('Position (mm)');
        ylabel('Force (N)');
        title(['File: ', data.name]);
    end
end
