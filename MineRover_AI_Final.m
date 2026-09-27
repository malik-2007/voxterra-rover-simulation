%================================================================
%        VOXTERRA - AI POWERED MINE RESCUE ROVER
%        Complete MATLAB Prototype
%
%        flowchart:
%        Mine Data
%             ↓
%        Gas Mapping
%             ↓
%        Local Rover Analysis
%             ↓
%        Gas Gradient
%             ↓
%        Gas Source Estimation
%             ↓
%        Temporal Gas Analysis
%             ↓
%        Gas Spread Rate
%             ↓
%        AI Gas Behavior Classification
%             ↓
%        Source Tracking
%             ↓
%        Rescue Dashboard
 %
% ==================================================================

clear;
clc;
close all;

fprintf('\n');
fprintf('============================================================\n');
fprintf('        VOXTERRA AI MINE RESCUE ROVER\n');
fprintf('============================================================\n');


%% ================================================================
% STEP 1 - CREATE SIMULATED MINE SENSOR DATA
% ================================================================

fprintf('\n===== STEP 1 - MINE SENSOR DATA GENERATION =====\n');

rng(10);

% Mine dimensions
mineSizeX = 20;
mineSizeY = 20;

mineX = 1:mineSizeX;
mineY = 1:mineSizeY;

% Create complete mine grid
[Xgrid, Ygrid] = meshgrid(mineX, mineY);

X = Xgrid(:);
Y = Ygrid(:);

pointsPerVisit = numel(X);

% ------------------------------------------------
% Gas source location
% ------------------------------------------------

sourceX = 14;
sourceY = 14;

% ------------------------------------------------
% Distance from gas source
% ------------------------------------------------

distanceFromSource = sqrt( ...
    (X-sourceX).^2 + ...
    (Y-sourceY).^2);

% ------------------------------------------------
% VISIT 1
% ------------------------------------------------

% CH4 concentration [20+
CH4_visit1 = ...
    20 + ...
    480 .* exp(-0.25 .* distanceFromSource);

% Add small sensor noise
CH4_visit1 = CH4_visit1 + 5 .* randn(pointsPerVisit,1);

CH4_visit1 = max(CH4_visit1,5);

% CO2
CO2_visit1 = ...
    600 + ...
    250 .* exp(-0.15 .* distanceFromSource);

% CO
CO_visit1 = ...
    5 + ...
    40 .* exp(-0.20 .* distanceFromSource);

% Oxygen reduction 
O2_visit1 = ...
    20.9 ...
    - 0.004 .* CH4_visit1 ...
    - 0.001 .* CO2_visit1 ...
    - 0.01 .* CO_visit1;

% Temperature
Temperature_visit1 = ...
    25 + 0.01 .* CH4_visit1;

% ------------------------------------------------
% VISIT 2
% Gas becomes slightly more concentrated
% ------------------------------------------------

CH4_visit2 = ...
    20 + ...
    540 .* exp(-0.23 .* distanceFromSource);

CH4_visit2 = CH4_visit2 + 5 .* randn(pointsPerVisit,1);

CH4_visit2 = max(CH4_visit2,5);

CO2_visit2 = ...
    600 + ...
    270 .* exp(-0.15 .* distanceFromSource);

CO_visit2 = ...
    5 + ...
    45 .* exp(-0.20 .* distanceFromSource);

O2_visit2 = ...
    20.9 ...
    - 0.004 .* CH4_visit2 ...
    - 0.001 .* CO2_visit2 ...
    - 0.01 .* CO_visit2;

Temperature_visit2 = ...
    25 + 0.01 .* CH4_visit2;

% ------------------------------------------------
% IMPORTANT:
% CREATE THE VISIT VARIABLE HERE
% ------------------------------------------------

Visit = [
    ones(pointsPerVisit,1);
    2*ones(pointsPerVisit,1)
];

% ------------------------------------------------
% Combine both visits
% ------------------------------------------------

RoverData = table( ...
    [X; X], ...
    [Y; Y], ...
    Visit, ...
    [CH4_visit1; CH4_visit2], ...
    [CO2_visit1; CO2_visit2], ...
    [CO_visit1; CO_visit2], ...
    [O2_visit1; O2_visit2], ...
    [Temperature_visit1; Temperature_visit2], ...
    'VariableNames', { ...
    'X', ...
    'Y', ...
    'Visit', ...
    'CH4', ...
    'CO2', ...
    'CO', ...
    'O2', ...
    'Temperature'});

fprintf('Mine grid          : %d x %d\n', ...
    mineSizeX, mineSizeY);

fprintf('Points per visit   : %d\n', ...
    pointsPerVisit);

fprintf('Total sensor rows  : %d\n', ...
    height(RoverData));

fprintf('Visit 1 rows       : %d\n', ...
    sum(RoverData.Visit == 1));

fprintf('Visit 2 rows       : %d\n', ...
    sum(RoverData.Visit == 2));

fprintf('Gas source          : (%.1f, %.1f)\n', ...
    sourceX, sourceY);


%% ================================================================
% STEP 2 - FIRST VISIT SPATIAL GAS ANALYSIS
% ================================================================

fprintf('\n===== STEP 2 - FIRST VISIT SPATIAL GAS ANALYSIS =====\n');

% Select first rover visit
Visit1 = RoverData(RoverData.Visit == 1, :);

% Create CH4 concentration map
CH4_Map = reshape( ...
    Visit1.CH4, ...
    length(mineX), ...
    length(mineY));

% Display gas concentration
figure('Name','First Visit CH4 Map');

imagesc(mineX, mineY, CH4_Map');

set(gca,'YDir','normal');

xlabel('Mine X Position');
ylabel('Mine Y Position');

title('First Rover Visit - CH_4 Concentration Map');

colorbar;

fprintf('First visit gas map generated.\n');


%% ================================================================
% STEP 3 - ROVER LOCAL GAS ANALYSIS
% ================================================================

fprintf('\n===== STEP 3 - ROVER LOCAL GAS ANALYSIS =====\n');

% Rover starting position
roverX = 8;
roverY = 8;

% Sensor search radius
radius = 3;

% Distance from rover to every sensor
distanceFromRover = sqrt( ...
    (Visit1.X - roverX).^2 + ...
    (Visit1.Y - roverY).^2);

% Nearby measurements
Nearby = Visit1(distanceFromRover <= radius, :);

% Find closest sensor measurement
[~, roverIndex] = min(distanceFromRover);

% Current rover readings
currentCH4 = Visit1.CH4(roverIndex);

currentO2 = ...
    Visit1.O2(roverIndex);

currentTemp = ...
    Visit1.Temperature(roverIndex);

% Average surrounding CH4
surroundingCH4 = mean(Nearby.CH4);

fprintf('Rover position       : (%.1f, %.1f)\n', ...
    roverX, roverY);

fprintf('Current CH4          : %.2f ppm\n', ...
    currentCH4);

fprintf('Surrounding CH4      : %.2f ppm\n', ...
    surroundingCH4);

fprintf('Current O2           : %.2f %%\n', ...
    currentO2);

fprintf('Temperature          : %.2f C\n', ...
    currentTemp);

fprintf('Nearby measurements  : %d\n', ...
    height(Nearby));


%% ================================================================
% STEP 4 - GAS CONCENTRATION GRADIENT
% ================================================================

fprintf('\n===== STEP 4 - GAS GRADIENT ANALYSIS =====\n');

% Find points in four directions

north = Visit1( ...
    Visit1.X == roverX & ...
    Visit1.Y > roverY & ...
    Visit1.Y <= roverY + radius, :);

south = Visit1( ...
    Visit1.X == roverX & ...
    Visit1.Y < roverY & ...
    Visit1.Y >= roverY - radius, :);

east = Visit1( ...
    Visit1.Y == roverY & ...
    Visit1.X > roverX & ...
    Visit1.X <= roverX + radius, :);

west = Visit1( ...
    Visit1.Y == roverY & ...
    Visit1.X < roverX & ...
    Visit1.X >= roverX - radius, :);

% ------------------------------------------------
% Safe mean function
% ------------------------------------------------

if isempty(north)
    northCH4 = currentCH4;
else
    northCH4 = mean(north.CH4);
end

if isempty(south)
    southCH4 = currentCH4;
else
    southCH4 = mean(south.CH4);
end

if isempty(east)
    eastCH4 = currentCH4;
else
    eastCH4 = mean(east.CH4);
end

if isempty(west)
    westCH4 = currentCH4;
else
    westCH4 = mean(west.CH4);
end

% Calculate gradient
gradientX = ...
    (eastCH4 - westCH4) / (2*radius);

gradientY = ...
    (northCH4 - southCH4) / (2*radius);

% Direction of increasing gas
angle = atan2d(gradientY,gradientX);

% Gradient magnitude
gradientMagnitude = sqrt( ...
    gradientX^2 + ...
    gradientY^2);

fprintf('North CH4 : %.2f ppm\n',northCH4);
fprintf('South CH4 : %.2f ppm\n',southCH4);
fprintf('East CH4  : %.2f ppm\n',eastCH4);
fprintf('West CH4  : %.2f ppm\n',westCH4);

fprintf('\nGradient X : %.3f ppm/grid\n', ...
    gradientX);

fprintf('Gradient Y : %.3f ppm/grid\n', ...
    gradientY);

fprintf('Gas direction : %.1f degrees\n', ...
    angle);

fprintf('Gradient magnitude : %.3f\n', ...
    gradientMagnitude);


%% ================================================================
% STEP 5 - ESTIMATE GAS SOURCE
% ================================================================

fprintf('\n===== STEP 5 - GAS SOURCE ESTIMATION =====\n');

% Find highest CH4 measurement
[maxCH4,maxIndex] = max(Visit1.CH4);

% Estimated source position
sourceEstimateX = ...
    Visit1.X(maxIndex);

sourceEstimateY = ...
    Visit1.Y(maxIndex);

% Distance from rover
sourceDistance = sqrt( ...
    (sourceEstimateX-roverX)^2 + ...
    (sourceEstimateY-roverY)^2);

fprintf('Rover position   : (%.1f, %.1f)\n', ...
    roverX,roverY);

fprintf('Estimated source : (%.1f, %.1f)\n', ...
    sourceEstimateX,sourceEstimateY);

fprintf('Peak CH4         : %.2f ppm\n', ...
    maxCH4);

fprintf('Source distance  : %.2f grid units\n', ...
    sourceDistance);


%% ================================================================
% STEP 6 - GAS SOURCE VISUALIZATION
% ================================================================

fprintf('\n===== STEP 6 - GAS SOURCE VISUALIZATION =====\n');

figure('Name','Gas Gradient and Source');

imagesc(mineX,mineY,CH4_Map');

set(gca,'YDir','normal');

hold on;

% Rover
plot(roverX,roverY, ...
    'ko', ...
    'MarkerSize',10, ...
    'LineWidth',2);

% Estimated source
plot(sourceEstimateX,sourceEstimateY, ...
    'kx', ...
    'MarkerSize',14, ...
    'LineWidth',3);

% Gradient arrow
arrowLength = 4;

quiver( ...
    roverX, ...
    roverY, ...
    cosd(angle)*arrowLength, ...
    sind(angle)*arrowLength, ...
    0, ...
    'k', ...
    'LineWidth',2, ...
    'MaxHeadSize',0.8);

text( ...
    roverX+0.5, ...
    roverY, ...
    'ROVER', ...
    'FontSize',11, ...
    'FontWeight','bold');

text( ...
    sourceEstimateX+0.5, ...
    sourceEstimateY, ...
    'ESTIMATED GAS SOURCE', ...
    'FontSize',11, ...
    'FontWeight','bold');

xlabel('Mine X Position');
ylabel('Mine Y Position');

title('AI Mine Rescue Rover - Gas Source Estimation');

colorbar;

hold off;


%% ================================================================
% STEP 7 - MULTI-GAS SENSOR MODEL
% ================================================================

fprintf('\n===== STEP 7 - MULTI-GAS SENSOR MODEL =====\n');

% Select first visit
Visit1 = RoverData(RoverData.Visit == 1,:);

% Recalculate distance
distance = sqrt( ...
    (Visit1.X-sourceX).^2 + ...
    (Visit1.Y-sourceY).^2);

% Multi-gas values
Visit1.CH4 = ...
    500 .* exp(-0.25.*distance);

Visit1.CO2 = ...
    600 + 250.*exp(-0.15.*distance);

Visit1.CO = ...
    5 + 40.*exp(-0.20.*distance);

Visit1.O2 = ...
    20.9 ...
    - 0.004.*Visit1.CH4 ...
    - 0.001.*Visit1.CO2 ...
    - 0.01.*Visit1.CO;

Visit1.Temperature = ...
    25 + 0.01.*Visit1.CH4;

% Rover location
roverX = 8;
roverY = 8;

% Closest measurement
distanceFromRover = sqrt( ...
    (Visit1.X-roverX).^2 + ...
    (Visit1.Y-roverY).^2);

[~,roverIndex] = min(distanceFromRover);

% Current values
currentCH4 = Visit1.CH4(roverIndex);
currentCO2 = Visit1.CO2(roverIndex);
currentCO = Visit1.CO(roverIndex);
currentO2 = Visit1.O2(roverIndex);
currentTemp = Visit1.Temperature(roverIndex);

fprintf('Rover position : (%d,%d)\n', ...
    roverX,roverY);

fprintf('CH4            : %.2f ppm\n', ...
    currentCH4);

fprintf('CO2            : %.2f ppm\n', ...
    currentCO2);

fprintf('CO             : %.2f ppm\n', ...
    currentCO);

fprintf('O2             : %.2f %%\n', ...
    currentO2);

fprintf('Temperature    : %.2f C\n', ...
    currentTemp);


%% ================================================================
% STEP 8 - GAS CHANGE BETWEEN VISITS
% ================================================================

fprintf('\n===== STEP 8 - TEMPORAL GAS ANALYSIS =====\n');

Visit1 = RoverData(RoverData.Visit == 1,:);
Visit2 = RoverData(RoverData.Visit == 2,:);

% Use same gas model for both visits
distance1 = sqrt( ...
    (Visit1.X-sourceX).^2 + ...
    (Visit1.Y-sourceY).^2);

distance2 = sqrt( ...
    (Visit2.X-sourceX).^2 + ...
    (Visit2.Y-sourceY).^2);

% Visit 1
Visit1.CH4 = ...
    500.*exp(-0.25.*distance1);

Visit1.CO2 = ...
    600 + 250.*exp(-0.15.*distance1);

Visit1.CO = ...
    5 + 40.*exp(-0.20.*distance1);

Visit1.O2 = ...
    20.9 ...
    - 0.004.*Visit1.CH4 ...
    - 0.001.*Visit1.CO2 ...
    - 0.01.*Visit1.CO;

Visit1.Temperature = ...
    25 + 0.01.*Visit1.CH4;

% Visit 2 - increasing concentration
Visit2.CH4 = ...
    540.*exp(-0.23.*distance2);

Visit2.CO2 = ...
    600 + 270.*exp(-0.15.*distance2);

Visit2.CO = ...
    5 + 45.*exp(-0.20.*distance2);

Visit2.O2 = ...
    20.9 ...
    - 0.004.*Visit2.CH4 ...
    - 0.001.*Visit2.CO2 ...
    - 0.01.*Visit2.CO;

Visit2.Temperature = ...
    25 + 0.01.*Visit2.CH4;

% Changes
CH4_change = ...
    Visit2.CH4 - Visit1.CH4;

O2_change = ...
    Visit2.O2 - Visit1.O2;

Temp_change = ...
    Visit2.Temperature - Visit1.Temperature;

% Average changes
avgCH4Change = mean(CH4_change);

avgO2Change = mean(O2_change);

avgTempChange = mean(Temp_change);

fprintf('Average CH4 change : %.3f ppm/visit\n', ...
    avgCH4Change);

fprintf('Average O2 change  : %.3f %%/visit\n', ...
    avgO2Change);

fprintf('Average temperature change : %.3f C\n', ...
    avgTempChange);


%% ================================================================
% STEP 9 - GAS SPREAD RATE
% ================================================================

fprintf('\n===== STEP 9 - GAS SPREAD RATE =====\n');

timeBetweenVisits = 60;

CH4_threshold = 100;

% Affected areas
affected1 = ...
    Visit1.CH4 >= CH4_threshold;

affected2 = ...
    Visit2.CH4 >= CH4_threshold;

% Distance from estimated source
dist1 = sqrt( ...
    (Visit1.X(affected1)-sourceEstimateX).^2 + ...
    (Visit1.Y(affected1)-sourceEstimateY).^2);

dist2 = sqrt( ...
    (Visit2.X(affected2)-sourceEstimateX).^2 + ...
    (Visit2.Y(affected2)-sourceEstimateY).^2);

% Avoid empty region
if isempty(dist1)
    radius1 = 0;
else
    radius1 = max(dist1);
end

if isempty(dist2)
    radius2 = 0;
else
    radius2 = max(dist2);
end

radiusChange = ...
    radius2-radius1;

spreadRate = ...
    radiusChange/timeBetweenVisits;

fprintf('Visit 1 affected radius : %.2f grid units\n', ...
    radius1);

fprintf('Visit 2 affected radius : %.2f grid units\n', ...
    radius2);

fprintf('Radius change           : %.2f grid units\n', ...
    radiusChange);

fprintf('Time interval           : %d seconds\n', ...
    timeBetweenVisits);

fprintf('Estimated spread rate   : %.4f grid/s\n', ...
    spreadRate);


%% ================================================================
% STEP 10 - AI GAS BEHAVIOR INPUT
% ================================================================

fprintf('\n===== STEP 10 - AI GAS BEHAVIOR INPUT =====\n');

CH4_current = mean(Visit2.CH4);

CH4_previous = mean(Visit1.CH4);

CH4_change = ...
    CH4_current-CH4_previous;

O2_current = mean(Visit2.O2);

O2_previous = mean(Visit1.O2);

O2_change = ...
    O2_current-O2_previous;

Temp_current = ...
    mean(Visit2.Temperature);

Temp_previous = ...
    mean(Visit1.Temperature);

Temp_change = ...
    Temp_current-Temp_previous;

gradientMagnitude = sqrt( ...
    gradientX^2 + gradientY^2);

CurrentFeatures = [ ...
    CH4_current, ...
    CH4_change, ...
    spreadRate, ...
    O2_change, ...
    Temp_change, ...
    mean(Visit2.CO2), ...
    mean(Visit2.CO), ...
    gradientMagnitude];

fprintf('CH4 concentration : %.2f ppm\n', ...
    CH4_current);

fprintf('CH4 change        : %.2f ppm\n', ...
    CH4_change);

fprintf('Spread rate       : %.4f grid/s\n', ...
    spreadRate);

fprintf('O2 change         : %.4f %%\n', ...
    O2_change);

fprintf('Temperature change: %.4f C\n', ...
    Temp_change);

fprintf('CO2 concentration : %.2f ppm\n', ...
    mean(Visit2.CO2));

fprintf('CO concentration  : %.2f ppm\n', ...
    mean(Visit2.CO));

fprintf('Gradient magnitude: %.3f\n', ...
    gradientMagnitude);

fprintf('\nAI feature vector created successfully.\n');


%% ================================================================
% STEP 11 - TRAIN AI GAS BEHAVIOR MODEL
% ================================================================

fprintf('\n===== STEP 11 - TRAINING AI MODEL =====\n');

rng(10);

N = 3000;

% Synthetic training features
CH4_train = ...
    20 + 480.*rand(N,1);

CH4_change_train = ...
    -30 + 60.*rand(N,1);

spreadRate_train = ...
    0.001 + 0.01.*rand(N,1);

O2_change_train = ...
    -0.15 + 0.30.*rand(N,1);

Temp_change_train = ...
    -0.2 + 0.4.*rand(N,1);

CO2_train = ...
    500 + 400.*rand(N,1);

CO_train = ...
    2 + 50.*rand(N,1);

gradient_train = ...
    0.5 + 10.*rand(N,1);


%% ================================================================
% CREATE BEHAVIOR LABELS
% ================================================================

Behavior = strings(N,1);

for i = 1:N

    if spreadRate_train(i) > 0.006 && ...
       CH4_change_train(i) > 5

        Behavior(i) = "SPREADING";

    elseif CH4_change_train(i) > 5 && ...
           O2_change_train(i) < -0.03

        Behavior(i) = "ACCUMULATING";

    elseif CH4_change_train(i) < -5 && ...
           spreadRate_train(i) < 0.004

        Behavior(i) = "DISSIPATING";

    else

        Behavior(i) = "STABLE";

    end

end


%% ================================================================
% CREATE TRAINING TABLE
% ================================================================

TrainingData = table( ...
    CH4_train, ...
    CH4_change_train, ...
    spreadRate_train, ...
    O2_change_train, ...
    Temp_change_train, ...
    CO2_train, ...
    CO_train, ...
    gradient_train, ...
    categorical(Behavior), ...
    'VariableNames', { ...
    'CH4', ...
    'CH4_Change', ...
    'SpreadRate', ...
    'O2_Change', ...
    'Temperature_Change', ...
    'CO2', ...
    'CO', ...
    'Gradient', ...
    'Behavior'});


%% ================================================================
% TRAIN DECISION TREE
% ================================================================

AI_Model = fitctree( ...
    TrainingData(:,1:8), ...
    TrainingData.Behavior);

fprintf('\n===== AI MODEL TRAINED =====\n');

fprintf('Training samples : %d\n',N);

fprintf('Features         : %d\n',8);

fprintf(['Classes          : SPREADING / ' ...
         'ACCUMULATING / DISSIPATING / STABLE\n']);


%% ================================================================
% STEP 12 - AI MODEL VALIDATION
% ================================================================

fprintf('\n===== STEP 12 - AI MODEL VALIDATION =====\n');

% 70/30 train-test split
cv = cvpartition( ...
    height(TrainingData), ...
    'HoldOut',0.30);

TrainSet = ...
    TrainingData(training(cv),:);

TestSet = ...
    TrainingData(test(cv),:);

% Train only on training set
AI_Model_Validated = fitctree( ...
    TrainSet(:,1:8), ...
    TrainSet.Behavior);

% Predict unseen test data
PredictedTest = predict( ...
    AI_Model_Validated, ...
    TestSet(:,1:8));

% Accuracy
testAccuracy = ...
    mean(PredictedTest == TestSet.Behavior)*100;

fprintf('Training samples : %d\n', ...
    height(TrainSet));

fprintf('Test samples     : %d\n', ...
    height(TestSet));

fprintf('Test accuracy    : %.2f %%\n', ...
    testAccuracy);


%% ================================================================
% CONFUSION MATRIX
% ================================================================

figure('Name','AI Model Confusion Matrix');

confusionchart( ...
    TestSet.Behavior, ...
    PredictedTest);

title('Gas Behavior AI - Unseen Test Data');


%% ================================================================
% PREDICT CURRENT ROVER BEHAVIOR
% ================================================================

CurrentFeatureTable = array2table( ...
    CurrentFeatures, ...
    'VariableNames', { ...
    'CH4', ...
    'CH4_Change', ...
    'SpreadRate', ...
    'O2_Change', ...
    'Temperature_Change', ...
    'CO2', ...
    'CO', ...
    'Gradient'});

PredictedBehavior = predict( ...
    AI_Model_Validated, ...
    CurrentFeatureTable);

fprintf('\n===== AI GAS BEHAVIOR PREDICTION =====\n');

fprintf('Predicted gas behavior: %s\n', ...
    string(PredictedBehavior));


%% ================================================================
% STEP 13 - AI GAS BEHAVIOR MAP
% ================================================================

fprintf('\n===== STEP 13 - AI GAS BEHAVIOR MAP =====\n');

% Recreate visits
Visit1 = RoverData(RoverData.Visit == 1,:);

Visit2 = RoverData(RoverData.Visit == 2,:);

% Recalculate gas values
distance1 = sqrt( ...
    (Visit1.X-sourceX).^2 + ...
    (Visit1.Y-sourceY).^2);

distance2 = sqrt( ...
    (Visit2.X-sourceX).^2 + ...
    (Visit2.Y-sourceY).^2);

Visit1.CH4 = ...
    500.*exp(-0.25.*distance1);

Visit2.CH4 = ...
    540.*exp(-0.23.*distance2);

Visit1.CO2 = ...
    600 + 250.*exp(-0.15.*distance1);

Visit2.CO2 = ...
    600 + 270.*exp(-0.15.*distance2);

Visit1.CO = ...
    5 + 40.*exp(-0.20.*distance1);

Visit2.CO = ...
    5 + 45.*exp(-0.20.*distance2);

Visit1.O2 = ...
    20.9 ...
    - 0.004.*Visit1.CH4 ...
    - 0.001.*Visit1.CO2 ...
    - 0.01.*Visit1.CO;

Visit2.O2 = ...
    20.9 ...
    - 0.004.*Visit2.CH4 ...
    - 0.001.*Visit2.CO2 ...
    - 0.01.*Visit2.CO;

Visit1.Temperature = ...
    25 + 0.01.*Visit1.CH4;

Visit2.Temperature = ...
    25 + 0.01.*Visit2.CH4;


%% ================================================================
% CREATE FEATURES FOR EVERY MINE LOCATION
% ================================================================

MapFeatures = zeros(height(Visit2),8);

for i = 1:height(Visit2)

    % Current CH4
    ch4_current = ...
        Visit2.CH4(i);

    % Previous CH4
    ch4_previous = ...
        Visit1.CH4(i);

    % Change
    ch4_change = ...
        ch4_current-ch4_previous;

    % Oxygen change
    o2_change = ...
        Visit2.O2(i)-Visit1.O2(i);

    % Temperature change
    temp_change = ...
        Visit2.Temperature(i) ...
        - Visit1.Temperature(i);

    % Current location
    x = Visit2.X(i);
    y = Visit2.Y(i);

    % ------------------------------------------------
    % Find neighboring points
    % ------------------------------------------------

    east = Visit2( ...
        Visit2.Y == y & ...
        Visit2.X == x+1,:);

    west = Visit2( ...
        Visit2.Y == y & ...
        Visit2.X == x-1,:);

    north = Visit2( ...
        Visit2.X == x & ...
        Visit2.Y == y+1,:);

    south = Visit2( ...
        Visit2.X == x & ...
        Visit2.Y == y-1,:);

    % ------------------------------------------------
    % Gradient
    % ------------------------------------------------

    localGradientX = 0;

    localGradientY = 0;

    if ~isempty(east) && ~isempty(west)

        localGradientX = ...
            (east.CH4(1)-west.CH4(1))/2;

    end

    if ~isempty(north) && ~isempty(south)

        localGradientY = ...
            (north.CH4(1)-south.CH4(1))/2;

    end

    localGradientMagnitude = sqrt( ...
        localGradientX^2 + ...
        localGradientY^2);

    % ------------------------------------------------
    % Store feature vector
    % ------------------------------------------------

    MapFeatures(i,:) = [ ...
        ch4_current, ...
        ch4_change, ...
        spreadRate, ...
        o2_change, ...
        temp_change, ...
        Visit2.CO2(i), ...
        Visit2.CO(i), ...
        localGradientMagnitude];

end


%% ================================================================
% CONVERT TO TABLE
% ================================================================

MapFeatureTable = array2table( ...
    MapFeatures, ...
    'VariableNames', { ...
    'CH4', ...
    'CH4_Change', ...
    'SpreadRate', ...
    'O2_Change', ...
    'Temperature_Change', ...
    'CO2', ...
    'CO', ...
    'Gradient'});


%% ================================================================
% PREDICT BEHAVIOR AT EVERY LOCATION
% ================================================================

MapPrediction = predict( ...
    AI_Model_Validated, ...
    MapFeatureTable);

Visit2.Behavior = MapPrediction;


%% ================================================================
% CREATE BEHAVIOR MAP
% ================================================================

behaviorMap = zeros( ...
    length(mineX), ...
    length(mineY));

for i = 1:height(Visit2)

    xIndex = Visit2.X(i);

    yIndex = Visit2.Y(i);

    switch string(Visit2.Behavior(i))

        case "STABLE"

            behaviorMap(xIndex,yIndex) = 1;

        case "DISSIPATING"

            behaviorMap(xIndex,yIndex) = 2;

        case "ACCUMULATING"

            behaviorMap(xIndex,yIndex) = 3;

        case "SPREADING"

            behaviorMap(xIndex,yIndex) = 4;

    end

end


%% ================================================================
% DISPLAY AI BEHAVIOR MAP
% ================================================================

figure('Name','AI Gas Behavior Map');

imagesc(mineX,mineY,behaviorMap');

set(gca,'YDir','normal');

xlabel('Mine X Position');
ylabel('Mine Y Position');

title('AI Gas Behavior Prediction Map');

cb = colorbar;

cb.Ticks = 1:4;

cb.TickLabels = { ...
    'STABLE', ...
    'DISSIPATING', ...
    'ACCUMULATING', ...
    'SPREADING'};

clim([1 4]);


%% ================================================================
% STEP 14 - AUTONOMOUS ROVER MOVEMENT
% ================================================================

fprintf('\n===== STEP 14 - AUTONOMOUS GAS SOURCE TRACKING =====\n');

figure('Name','Autonomous Rover Gas Tracking');

imagesc(mineX,mineY,CH4_Map');

set(gca,'YDir','normal');

hold on;

xlabel('Mine X Position');
ylabel('Mine Y Position');

title('Autonomous Rover - Gas Source Tracking');

colorbar;


% Starting position
currentX = 8;
currentY = 8;

% Target
targetX = sourceEstimateX;
targetY = sourceEstimateY;


% Plot estimated source
plot( ...
    targetX, ...
    targetY, ...
    'kx', ...
    'MarkerSize',14, ...
    'LineWidth',3);


% Rover path
pathX = currentX;
pathY = currentY;


% Rover
roverPlot = plot( ...
    currentX, ...
    currentY, ...
    'ko', ...
    'MarkerSize',10, ...
    'LineWidth',2);


% Path
pathPlot = plot( ...
    pathX, ...
    pathY, ...
    'k-', ...
    'LineWidth',2);


%% ================================================================
% MOVE ROVER
% ================================================================

for step = 1:30

    dx = targetX-currentX;

    dy = targetY-currentY;

    distanceToSource = ...
        sqrt(dx^2+dy^2);

    % Stop when source reached
    if distanceToSource < 1

        fprintf('\n*** SOURCE REGION REACHED ***\n');

        break;

    end

    % Normalize direction
    dx = dx/distanceToSource;

    dy = dy/distanceToSource;

    % Move rover
    currentX = currentX+dx;

    currentY = currentY+dy;

    % Store path
    pathX(end+1) = currentX;

    pathY(end+1) = currentY;

    % Update rover
    set( ...
        roverPlot, ...
        'XData',currentX, ...
        'YData',currentY);

    % Update path
    set( ...
        pathPlot, ...
        'XData',pathX, ...
        'YData',pathY);

    drawnow;

    pause(0.15);

end


fprintf('Starting position : (8, 8)\n');

fprintf('Final position    : (%.2f, %.2f)\n', ...
    currentX,currentY);

fprintf('Estimated source  : (%.2f, %.2f)\n', ...
    targetX,targetY);

fprintf('Navigation completed.\n');

hold off;


%% ================================================================
% STEP 15 - FINAL AI MINE RESCUE DASHBOARD
% ================================================================

fprintf('\n===== STEP 15 - FINAL AI MINE RESCUE DASHBOARD =====\n');

figure( ...
    'Name','VOXTERRA AI Mine Rescue Dashboard', ...
    'NumberTitle','off');


tiledlayout(2,2, ...
    'TileSpacing','compact', ...
    'Padding','compact');


%% ================================================================
% PANEL 1 - CH4 CONCENTRATION
% ================================================================

nexttile;

imagesc( ...
    mineX, ...
    mineY, ...
    CH4_Map');

set(gca,'YDir','normal');

hold on;

plot( ...
    currentX, ...
    currentY, ...
    'ko', ...
    'MarkerSize',10, ...
    'LineWidth',2);

plot( ...
    sourceEstimateX, ...
    sourceEstimateY, ...
    'kx', ...
    'MarkerSize',14, ...
    'LineWidth',3);

xlabel('Mine X');
ylabel('Mine Y');

title('CH_4 Concentration Map');

colorbar;

hold off;


%% ================================================================
% PANEL 2 - AI GAS BEHAVIOR
% ================================================================

nexttile;

imagesc( ...
    mineX, ...
    mineY, ...
    behaviorMap');

set(gca,'YDir','normal');

xlabel('Mine X');
ylabel('Mine Y');

title('AI Gas Behavior Prediction');

cb = colorbar;

cb.Ticks = 1:4;

cb.TickLabels = { ...
    'STABLE', ...
    'DISSIPATING', ...
    'ACCUMULATING', ...
    'SPREADING'};

clim([1 4]);


%% ================================================================
% PANEL 3 - ROVER PATH
% ================================================================

nexttile;

imagesc( ...
    mineX, ...
    mineY, ...
    CH4_Map');

set(gca,'YDir','normal');

hold on;

plot( ...
    pathX, ...
    pathY, ...
    'k-', ...
    'LineWidth',2);

plot( ...
    pathX(1), ...
    pathY(1), ...
    'ko', ...
    'MarkerSize',9, ...
    'LineWidth',2);

plot( ...
    currentX, ...
    currentY, ...
    'ks', ...
    'MarkerSize',10, ...
    'LineWidth',2);

plot( ...
    sourceEstimateX, ...
    sourceEstimateY, ...
    'kx', ...
    'MarkerSize',14, ...
    'LineWidth',3);

xlabel('Mine X');
ylabel('Mine Y');

title('Autonomous Rover Path');

colorbar;

legend( ...
    'Rover Path', ...
    'Start', ...
    'Current Rover', ...
    'Estimated Source', ...
    'Location','best');

hold off;


%% ================================================================
% PANEL 4 - AI STATUS
% ================================================================

nexttile;

axis off;

% Find nearest Visit 2 sensor to final rover position
distanceFinal = sqrt( ...
    (Visit2.X-currentX).^2 + ...
    (Visit2.Y-currentY).^2);

[~,finalIndex] = ...
    min(distanceFinal);

finalCH4 = ...
    Visit2.CH4(finalIndex);

finalO2 = ...
    Visit2.O2(finalIndex);

finalTemp = ...
    Visit2.Temperature(finalIndex);

finalBehavior = string( ...
    Visit2.Behavior(finalIndex));


%% ================================================================
% DASHBOARD TEXT
% ================================================================

text( ...
    0.05,0.90, ...
    'AI MINE RESCUE STATUS', ...
    'FontSize',16, ...
    'FontWeight','bold');

text( ...
    0.05,0.76, ...
    sprintf( ...
    'Rover Position : (%.1f, %.1f)', ...
    currentX,currentY), ...
    'FontSize',12);

text( ...
    0.05,0.66, ...
    sprintf( ...
    'CH4 : %.2f ppm', ...
    finalCH4), ...
    'FontSize',12);

text( ...
    0.05,0.56, ...
    sprintf( ...
    'O2 : %.2f %%', ...
    finalO2), ...
    'FontSize',12);

text( ...
    0.05,0.46, ...
    sprintf( ...
    'Temperature : %.2f C', ...
    finalTemp), ...
    'FontSize',12);

text( ...
    0.05,0.36, ...
    sprintf( ...
    'Spread Rate : %.4f grid/s', ...
    spreadRate), ...
    'FontSize',12);

text( ...
    0.05,0.24, ...
    sprintf( ...
    'AI Behavior : %s', ...
    finalBehavior), ...
    'FontSize',14, ...
    'FontWeight','bold');

text( ...
    0.05,0.12, ...
    sprintf( ...
    'AI Test Accuracy : %.2f %%', ...
    testAccuracy), ...
    'FontSize',12);


%% ================================================================
% FINAL OUTPUT
% ================================================================

fprintf('\n');
fprintf('============================================================\n');
fprintf('              VOXTERRA PROTOTYPE COMPLETE\n');
fprintf('============================================================\n');

fprintf('Estimated gas source : (%.2f, %.2f)\n', ...
    sourceEstimateX,sourceEstimateY);

fprintf('Final rover position : (%.2f, %.2f)\n', ...
    currentX,currentY);

fprintf('AI behavior           : %s\n', ...
    finalBehavior);

fprintf('AI test accuracy      : %.2f %%\n', ...
    testAccuracy);

fprintf('Gas spread rate       : %.4f grid/s\n', ...
    spreadRate);

fprintf('============================================================\n');
fprintf('Navigation completed.\n');
fprintf('============================================================\n');