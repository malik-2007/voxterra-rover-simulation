%% MINE ROVER - HUMAN DETECTION

clear;
clc;
close all;

fprintf('\n========================================\n');
fprintf('       MINE ROVER HUMAN DETECTION\n');
fprintf('========================================\n\n');

%% Load YOLOv4

detector = yolov4ObjectDetector('csp-darknet53-coco');

fprintf('YOLOv4 detector loaded successfully.\n');

%% Select an image

[file, path] = uigetfile( ...
    {'*.jpg;*.jpeg;*.png;*.bmp', 'Image Files'}, ...
    'Select a Mine/Rover Camera Image');

if isequal(file,0)
    fprintf('No image selected.\n');
    return;
end

img = imread(fullfile(path,file));

%% Detect objects

[bboxes, scores, labels] = detect(detector, img);

%% Find PERSON detections

personIndex = labels == "person";

personBoxes = bboxes(personIndex,:);
personScores = scores(personIndex);

%% Display result

figure('Name','Mine Rover Human Detection');

if isempty(personBoxes)

    imshow(img);
    title('NO PERSON DETECTED');

    fprintf('\nNO PERSON DETECTED\n');

else

    detectedImage = insertObjectAnnotation( ...
        img, ...
        'rectangle', ...
        personBoxes, ...
        "WORKER " + string(round(personScores*100)) + "%");

    imshow(detectedImage);

    title(sprintf('%d WORKER(S) DETECTED', ...
        size(personBoxes,1)));

    fprintf('\n========================================\n');
    fprintf('        HUMAN DETECTION RESULT\n');
    fprintf('========================================\n');

    fprintf('Workers detected : %d\n',size(personBoxes,1));

    for i = 1:length(personScores)

        fprintf('Worker %d confidence : %.2f %%\n', ...
            i, personScores(i)*100);

    end

end