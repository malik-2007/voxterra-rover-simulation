%% MINE RESCUE ROVER - EMERGENCY SCENARIO V2

clear;
clc;
close all;

fprintf('\n========================================\n');
fprintf('   AI MINE RESCUE ROVER - EMERGENCY\n');
fprintf('========================================\n\n');

%% STEP 2 - Mine and Emergency Setup

% Mine dimensions
mineX = 1:20;
mineY = 1:20;

% Number of rover visits
numVisits = 5;

% Hidden gas leak location
sourceX = 15;
sourceY = 15;

% Time between rover visits
timeBetweenVisits = 60;   % seconds

fprintf('Mine size        : 20 x 20 grid\n');
fprintf('Rover visits     : %d\n', numVisits);
fprintf('Hidden leak zone : (%d, %d)\n', sourceX, sourceY);
fprintf('Visit interval   : %d seconds\n', timeBetweenVisits);
fprintf('\nEmergency simulation initialized.\n');

%% STEP 3 - Emergency Gas Evolution

Data = [];

for visit = 1:numVisits

    % Gas leak becomes stronger with every visit
    emergencyFactor = 1 + 0.30*(visit-1);

    for x = mineX
        for y = mineY

            % Distance from hidden leak
            distance = sqrt( ...
                (x-sourceX)^2 + ...
                (y-sourceY)^2);

            % CH4 concentration
            CH4 = 10 + ...
                emergencyFactor * ...
                500 * exp(-0.25*distance);

            % CO2 concentration
            CO2 = 500 + ...
                emergencyFactor * ...
                250 * exp(-0.15*distance);

            % CO concentration
            CO = 3 + ...
                emergencyFactor * ...
                40 * exp(-0.20*distance);

            % Oxygen decreases as gases increase
            O2 = 20.9 ...
                - 0.004*CH4 ...
                - 0.001*CO2 ...
                - 0.01*CO;

            % Temperature increases near the leak
            Temperature = 25 + 0.01*CH4;

            Data = [Data;
                visit, x, y, ...
                CH4, CO2, CO, O2, Temperature];

        end
    end
end

% Convert to table
EmergencyData = array2table(Data, ...
    'VariableNames', { ...
    'Visit', ...
    'X', ...
    'Y', ...
    'CH4', ...
    'CO2', ...
    'CO', ...
    'O2', ...
    'Temperature'});

fprintf('\n===== EMERGENCY GAS SIMULATION =====\n');

for visit = 1:numVisits

    V = EmergencyData( ...
        EmergencyData.Visit == visit, :);

    fprintf('Visit %d | Max CH4: %.2f ppm | Min O2: %.2f %%\n', ...
        visit, max(V.CH4), min(V.O2));

end
%% STEP 4 - Emergency Evolution Map

figure('Name','Gas Emergency Evolution', ...
    'NumberTitle','off');

for visit = 1:numVisits

    % Get current visit
    V = EmergencyData( ...
        EmergencyData.Visit == visit, :);

    % Create CH4 map
    CH4_Map = reshape( ...
        V.CH4, ...
        length(mineX), ...
        length(mineY));

    imagesc(mineX, mineY, CH4_Map');
    set(gca,'YDir','normal');

    xlabel('Mine X Position');
    ylabel('Mine Y Position');

    title(sprintf( ...
        'Mine Gas Emergency - Visit %d',visit));

    colorbar;

    clim([0 1200]);

    hold on;

    % Mark hidden source
    plot(sourceX,sourceY,'kx', ...
        'MarkerSize',14, ...
        'LineWidth',3);

    text(sourceX+0.5,sourceY, ...
        'GAS LEAK', ...
        'FontSize',11, ...
        'FontWeight','bold');

    hold off;

    drawnow;

    pause(1);

end
%% STEP 5 - Rover Emergency Detection

% Rover starting position
roverX = 8;
roverY = 8;

% Use the first emergency visit
Visit1 = EmergencyData( ...
    EmergencyData.Visit == 1, :);

% Find nearest measurement to rover
distanceFromRover = sqrt( ...
    (Visit1.X-roverX).^2 + ...
    (Visit1.Y-roverY).^2);

[~, roverIndex] = min(distanceFromRover);

% Rover sensor readings
roverCH4 = Visit1.CH4(roverIndex);
roverO2 = Visit1.O2(roverIndex);
roverCO2 = Visit1.CO2(roverIndex);
roverCO = Visit1.CO(roverIndex);
roverTemp = Visit1.Temperature(roverIndex);

% Surrounding measurements
radius = 3;

nearbyDistance = sqrt( ...
    (Visit1.X-roverX).^2 + ...
    (Visit1.Y-roverY).^2);

Nearby = Visit1( ...
    nearbyDistance <= radius, :);

surroundingCH4 = mean(Nearby.CH4);

% Local gradient
east = Visit1.CH4( ...
    Visit1.Y == roverY & ...
    Visit1.X > roverX & ...
    Visit1.X <= roverX+radius);

west = Visit1.CH4( ...
    Visit1.Y == roverY & ...
    Visit1.X < roverX & ...
    Visit1.X >= roverX-radius);

north = Visit1.CH4( ...
    Visit1.X == roverX & ...
    Visit1.Y > roverY & ...
    Visit1.Y <= roverY+radius);

south = Visit1.CH4( ...
    Visit1.X == roverX & ...
    Visit1.Y < roverY & ...
    Visit1.Y >= roverY-radius);

gradientX = (mean(east)-mean(west))/(2*radius);
gradientY = (mean(north)-mean(south))/(2*radius);

gradientMagnitude = sqrt( ...
    gradientX^2 + gradientY^2);

gradientAngle = atan2d( ...
    gradientY,gradientX);

%% Display rover analysis

fprintf('\n========================================\n');
fprintf('       ROVER EMERGENCY DETECTION\n');
fprintf('========================================\n');

fprintf('Rover position       : (%d, %d)\n', ...
    roverX,roverY);

fprintf('CH4                  : %.2f ppm\n', ...
    roverCH4);

fprintf('Surrounding CH4      : %.2f ppm\n', ...
    surroundingCH4);

fprintf('CO2                  : %.2f ppm\n', ...
    roverCO2);

fprintf('CO                   : %.2f ppm\n', ...
    roverCO);

fprintf('O2                   : %.2f %%\n', ...
    roverO2);

fprintf('Temperature          : %.2f C\n', ...
    roverTemp);

fprintf('CH4 gradient         : %.3f\n', ...
    gradientMagnitude);

fprintf('Gas increasing angle : %.1f degrees\n', ...
    gradientAngle);
%% STEP 6 - Detect Emergency Progression

% Get Visit 1 and Visit 2
V1 = EmergencyData(EmergencyData.Visit == 1, :);
V2 = EmergencyData(EmergencyData.Visit == 2, :);

% Find rover location in both visits
d1 = sqrt((V1.X-roverX).^2 + (V1.Y-roverY).^2);
d2 = sqrt((V2.X-roverX).^2 + (V2.Y-roverY).^2);

[~,idx1] = min(d1);
[~,idx2] = min(d2);

% Sensor changes
CH4_change = V2.CH4(idx2) - V1.CH4(idx1);
O2_change = V2.O2(idx2) - V1.O2(idx1);
Temp_change = V2.Temperature(idx2) - V1.Temperature(idx1);

fprintf('\n========================================\n');
fprintf('       EMERGENCY PROGRESSION\n');
fprintf('========================================\n');

fprintf('Visit 1 CH4       : %.2f ppm\n',V1.CH4(idx1));
fprintf('Visit 2 CH4       : %.2f ppm\n',V2.CH4(idx2));

fprintf('CH4 change        : +%.2f ppm\n',CH4_change);

fprintf('\nVisit 1 O2        : %.2f %%\n',V1.O2(idx1));
fprintf('Visit 2 O2        : %.2f %%\n',V2.O2(idx2));

fprintf('O2 change         : %.2f %%\n',O2_change);

fprintf('\nTemperature change: +%.2f C\n',Temp_change);

%% Emergency decision

if CH4_change > 0 && O2_change < 0

    fprintf('\n*** EMERGENCY TREND DETECTED ***\n');
    fprintf('CH4 is increasing.\n');
    fprintf('O2 is decreasing.\n');
    fprintf('Gas condition is worsening.\n');

else

    fprintf('\nNo significant emergency progression detected.\n');

end

%% STEP 7 - Gas Spread and Affected Area

CH4_threshold = 100;   % ppm - level used to visualize affected region

fprintf('\n========================================\n');
fprintf('       GAS SPREAD ANALYSIS\n');
fprintf('========================================\n');

for visit = 1:numVisits

    V = EmergencyData(EmergencyData.Visit == visit, :);

    affected = V.CH4 >= CH4_threshold;

    affectedArea = sum(affected);

    distances = sqrt((V.X(sourceX == V.X & V.Y == V.Y) - sourceX).^2 + ...
        (V.Y(sourceY == V.Y & V.X == V.X) - sourceY).^2);

    % Distance of farthest affected point from source
    affectedX = V.X(affected);
    affectedY = V.Y(affected);

    if ~isempty(affectedX)
        affectedRadius = max(sqrt( ...
            (affectedX-sourceX).^2 + ...
            (affectedY-sourceY).^2));
    else
        affectedRadius = 0;
    end

    fprintf('Visit %d | Affected cells: %d | Affected radius: %.2f\n', ...
        visit, affectedArea, affectedRadius);

end
%% STEP 8 - Gas Spread Rate

CH4_threshold = 100;

affectedRadius = zeros(numVisits,1);
affectedArea = zeros(numVisits,1);

for visit = 1:numVisits

    V = EmergencyData(EmergencyData.Visit == visit, :);

    affected = V.CH4 >= CH4_threshold;

    affectedArea(visit) = sum(affected);

    affectedX = V.X(affected);
    affectedY = V.Y(affected);

    affectedRadius(visit) = max(sqrt( ...
        (affectedX-sourceX).^2 + ...
        (affectedY-sourceY).^2));

end

spreadRate = zeros(numVisits-1,1);

for visit = 2:numVisits
    spreadRate(visit-1) = ...
        (affectedRadius(visit) - affectedRadius(visit-1)) ...
        / timeBetweenVisits;
end

fprintf('\n========================================\n');
fprintf('          GAS SPREAD RATE\n');
fprintf('========================================\n');

for visit = 2:numVisits
    fprintf(['Visit %d -> %d | Radius change: %.2f | ' ...
        'Spread rate: %.4f grid units/sec\n'], ...
        visit-1, visit, ...
        affectedRadius(visit)-affectedRadius(visit-1), ...
        spreadRate(visit-1));
end

fprintf('\nFinal affected radius : %.2f grid units\n', ...
    affectedRadius(end));

fprintf('Total affected cells  : %d\n', ...
    affectedArea(end));
%% STEP 10 - Refined Gas Source Estimation

V = EmergencyData(EmergencyData.Visit == 1, :);

% Only consider gas concentrations above the affected-zone threshold
affected = V.CH4 >= CH4_threshold;

SourceCandidates = V(affected, :);

% Weighted centroid:
% Higher CH4 concentration gets more influence
weights = SourceCandidates.CH4;

estimatedSourceX = sum(SourceCandidates.X .* weights) / sum(weights);
estimatedSourceY = sum(SourceCandidates.Y .* weights) / sum(weights);

sourceError = sqrt( ...
    (estimatedSourceX-sourceX)^2 + ...
    (estimatedSourceY-sourceY)^2);

fprintf('\n========================================\n');
fprintf('     REFINED GAS SOURCE ESTIMATION\n');
fprintf('========================================\n');

fprintf('Rover position       : (%.1f, %.1f)\n', ...
    roverX, roverY);

fprintf('Gas gradient angle   : %.1f degrees\n', ...
    gradientAngle);

fprintf('Estimated source     : (%.2f, %.2f)\n', ...
    estimatedSourceX, estimatedSourceY);

fprintf('Ground truth         : (%d, %d)\n', ...
    sourceX, sourceY);

fprintf('Estimation error     : %.2f grid units\n', ...
    sourceError);
%% STEP 11 - AI Gas Behaviour Prediction

% Visit 1 and Visit 2 at rover position

V1 = EmergencyData(EmergencyData.Visit == 1, :);
V2 = EmergencyData(EmergencyData.Visit == 2, :);

d1 = sqrt((V1.X-roverX).^2 + (V1.Y-roverY).^2);
d2 = sqrt((V2.X-roverX).^2 + (V2.Y-roverY).^2);

[~,idx1] = min(d1);
[~,idx2] = min(d2);

% Current sensor values
CH4_current = V2.CH4(idx2);
CO2_current = V2.CO2(idx2);
CO_current = V2.CO(idx2);

% Temporal changes
CH4_change = V2.CH4(idx2) - V1.CH4(idx1);
O2_change = V2.O2(idx2) - V1.O2(idx1);
Temp_change = V2.Temperature(idx2) - V1.Temperature(idx1);

% AI feature vector
AI_Features = [ ...
    CH4_current, ...
    CH4_change, ...
    spreadRate(1), ...
    O2_change, ...
    Temp_change, ...
    CO2_current, ...
    CO_current, ...
    gradientMagnitude];

fprintf('\n========================================\n');
fprintf('        AI GAS BEHAVIOUR INPUTS\n');
fprintf('========================================\n');

fprintf('Current CH4       : %.2f ppm\n',CH4_current);
fprintf('CH4 change        : %.2f ppm\n',CH4_change);
fprintf('Spread rate       : %.4f grid units/sec\n',spreadRate(1));
fprintf('O2 change         : %.4f %%\n',O2_change);
fprintf('Temperature change: %.4f C\n',Temp_change);
fprintf('CO2               : %.2f ppm\n',CO2_current);
fprintf('CO                : %.2f ppm\n',CO_current);
fprintf('Gas gradient      : %.3f\n',gradientMagnitude);

fprintf('\nAI feature vector created successfully.\n');

%% STEP 12 - AI Gas Behaviour Model

rng(10);

N = 3000;

% Synthetic training features
CH4_train = 20 + 500*rand(N,1);
CH4_change_train = -30 + 60*rand(N,1);
spread_train = 0.001 + 0.025*rand(N,1);
O2_change_train = -0.15 + 0.30*rand(N,1);
Temp_change_train = -0.2 + 0.4*rand(N,1);
CO2_train = 500 + 400*rand(N,1);
CO_train = 2 + 50*rand(N,1);
gradient_train = 0.5 + 10*rand(N,1);

Behavior = strings(N,1);

for i = 1:N

    if spread_train(i) > 0.012 && CH4_change_train(i) > 5
        Behavior(i) = "SPREADING";

    elseif CH4_change_train(i) > 5 && ...
            O2_change_train(i) < -0.03
        Behavior(i) = "ACCUMULATING";

    elseif CH4_change_train(i) < -5 && ...
            spread_train(i) < 0.006
        Behavior(i) = "DISSIPATING";

    else
        Behavior(i) = "STABLE";
    end

end

TrainingData = table( ...
    CH4_train, ...
    CH4_change_train, ...
    spread_train, ...
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
    'Temp_Change', ...
    'CO2', ...
    'CO', ...
    'Gradient', ...
    'Behavior'});

% Train decision tree
AI_Model = fitctree( ...
    TrainingData(:,1:8), ...
    TrainingData.Behavior);

% Predict current emergency condition
CurrentInput = array2table(AI_Features, ...
    'VariableNames', TrainingData.Properties.VariableNames(1:8));

PredictedBehavior = predict(AI_Model, CurrentInput);

fprintf('\n========================================\n');
fprintf('        AI GAS BEHAVIOUR PREDICTION\n');
fprintf('========================================\n');

fprintf('Predicted behaviour : %s\n', ...
    string(PredictedBehavior));

fprintf('\nAI interpretation:\n');

switch string(PredictedBehavior)

    case "SPREADING"
        fprintf('Gas concentration is increasing and the affected region is expanding.\n');

    case "ACCUMULATING"
        fprintf('Gas concentration is increasing while oxygen is decreasing.\n');

    case "DISSIPATING"
        fprintf('Gas concentration is decreasing and the affected region is contracting.\n');

    case "STABLE"
        fprintf('Gas conditions show no strong spatial or temporal change.\n');

end
%% STEP 13 - AI Model Validation

% 70% training / 30% testing
cv = cvpartition(height(TrainingData), 'HoldOut', 0.30);

TrainSet = TrainingData(training(cv), :);
TestSet  = TrainingData(test(cv), :);

% Train using only training data
ValidatedModel = fitctree( ...
    TrainSet(:,1:8), ...
    TrainSet.Behavior);

% Predict unseen test data
PredictedTest = predict( ...
    ValidatedModel, ...
    TestSet(:,1:8));

% Calculate accuracy
testAccuracy = mean( ...
    PredictedTest == TestSet.Behavior) * 100;

fprintf('\n========================================\n');
fprintf('          AI MODEL VALIDATION\n');
fprintf('========================================\n');

fprintf('Training samples : %d\n', height(TrainSet));
fprintf('Test samples     : %d\n', height(TestSet));

fprintf('Test accuracy    : %.2f %%\n', testAccuracy);

% Confusion matrix
figure('Name','AI Behaviour Confusion Matrix', ...
    'NumberTitle','off');

confusionchart( ...
    TestSet.Behavior, ...
    PredictedTest);

title('AI Gas Behaviour Classification');
%% STEP 14B - Improved Spatial AI Behaviour Map

V1 = EmergencyData(EmergencyData.Visit == 1, :);
V2 = EmergencyData(EmergencyData.Visit == 2, :);

AI_Map = strings(length(mineY), length(mineX));

for i = 1:height(V2)

    x = V2.X(i);
    y = V2.Y(i);

    % Find same location during previous visit
    previous = V1(V1.X == x & V1.Y == y, :);

    CH4_change_local = V2.CH4(i) - previous.CH4;
    O2_change_local = V2.O2(i) - previous.O2;

    currentCH4 = V2.CH4(i);

    % Local behaviour classification
    if currentCH4 < CH4_threshold

        behavior = "STABLE";

    elseif CH4_change_local > 8 && ...
            O2_change_local < -0.05 && ...
            currentCH4 >= CH4_threshold

        behavior = "SPREADING";

    elseif CH4_change_local > 3 && ...
            O2_change_local < -0.02

        behavior = "ACCUMULATING";

    else

        behavior = "STABLE";

    end

    AI_Map(y,x) = behavior;

end

% Convert behaviour into numbers
BehaviorNumeric = zeros(size(AI_Map));

BehaviorNumeric(AI_Map == "STABLE") = 1;
BehaviorNumeric(AI_Map == "ACCUMULATING") = 2;
BehaviorNumeric(AI_Map == "SPREADING") = 3;

figure('Name','Improved AI Gas Behaviour Map', ...
    'NumberTitle','off');

imagesc(mineX,mineY,BehaviorNumeric);

set(gca,'YDir','normal');

xlabel('Mine X Position');
ylabel('Mine Y Position');

title('AI Gas Behaviour Map - Visit 2');

colorbar;

hold on;

plot(roverX,roverY,'ko', ...
    'MarkerSize',10, ...
    'LineWidth',2);

plot(estimatedSourceX,estimatedSourceY,'kx', ...
    'MarkerSize',14, ...
    'LineWidth',3);

text(roverX+0.5,roverY,'ROVER', ...
    'FontWeight','bold');

text(estimatedSourceX+0.5,estimatedSourceY, ...
    'ESTIMATED SOURCE', ...
    'FontWeight','bold');

hold off;
%% STEP 15 - Rover Navigation Toward Estimated Source

currentX = roverX;
currentY = roverY;

pathX = currentX;
pathY = currentY;

maxSteps = 20;
stepSize = 0.6;

fprintf('\n========================================\n');
fprintf('        ROVER NAVIGATION\n');
fprintf('========================================\n');

fprintf('Starting position : (%.1f, %.1f)\n', ...
    currentX, currentY);

fprintf('Target source     : (%.2f, %.2f)\n', ...
    estimatedSourceX, estimatedSourceY);

fprintf('Navigation angle  : %.1f degrees\n', ...
    gradientAngle);

for step = 1:maxSteps

    % Direction toward increasing gas concentration
    dx = cosd(gradientAngle);
    dy = sind(gradientAngle);

    % Move rover
    currentX = currentX + stepSize * dx;
    currentY = currentY + stepSize * dy;

    % Keep rover inside mine
    currentX = max(min(currentX,max(mineX)),min(mineX));
    currentY = max(min(currentY,max(mineY)),min(mineY));

    pathX(end+1) = currentX;
    pathY(end+1) = currentY;

    % Distance from estimated source
    distanceToSource = sqrt( ...
        (currentX-estimatedSourceX)^2 + ...
        (currentY-estimatedSourceY)^2);

    fprintf('Step %2d | Rover: (%.2f, %.2f) | Distance to source: %.2f\n', ...
        step,currentX,currentY,distanceToSource);

    if distanceToSource < 1.0
        fprintf('\n*** SOURCE REGION REACHED ***\n');
        break;
    end

end

fprintf('\nFinal rover position : (%.2f, %.2f)\n', ...
    currentX,currentY);

fprintf('Navigation completed.\n');


%% Navigation Visualization

figure('Name','AI Rover Navigation','NumberTitle','off');

imagesc(mineX,mineY,BehaviorNumeric);

set(gca,'YDir','normal');

xlabel('Mine X Position');
ylabel('Mine Y Position');

title('AI-Guided Rover Navigation');

colorbar;

hold on;

plot(pathX,pathY,'k-o', ...
    'LineWidth',2, ...
    'MarkerSize',4);

plot(roverX,roverY,'ko', ...
    'MarkerSize',10, ...
    'LineWidth',2);

plot(estimatedSourceX,estimatedSourceY,'kx', ...
    'MarkerSize',14, ...
    'LineWidth',3);

text(roverX+0.5,roverY,'START', ...
    'FontWeight','bold');

text(estimatedSourceX+0.5,estimatedSourceY, ...
    'ESTIMATED SOURCE', ...
    'FontWeight','bold');

hold off;
%% STEP 16 - FINAL AI MINE RESCUE DASHBOARD

figure('Name','AI Mine Rescue Rover - Emergency Dashboard', ...
       'NumberTitle','off', ...
       'Position',[100 100 1200 700]);

tiledlayout(2,2,'TileSpacing','compact','Padding','compact');


%% PANEL 1 - Current Gas Map

nexttile;

V = EmergencyData(EmergencyData.Visit == 2,:);

CH4_Map = reshape(V.CH4, ...
    length(mineX),length(mineY));

imagesc(mineX,mineY,CH4_Map');

set(gca,'YDir','normal');

xlabel('Mine X');
ylabel('Mine Y');

title('CH_4 Concentration - Visit 2');

colorbar;

hold on;

plot(roverX,roverY,'ko', ...
    'MarkerSize',10, ...
    'LineWidth',2);

plot(estimatedSourceX,estimatedSourceY,'kx', ...
    'MarkerSize',14, ...
    'LineWidth',3);

hold off;


%% PANEL 2 - Gas Behaviour

nexttile;

imagesc(mineX,mineY,BehaviorNumeric);

set(gca,'YDir','normal');

xlabel('Mine X');
ylabel('Mine Y');

title('AI Gas Behaviour');

colorbar;

hold on;

plot(roverX,roverY,'ko', ...
    'MarkerSize',10, ...
    'LineWidth',2);

plot(estimatedSourceX,estimatedSourceY,'kx', ...
    'MarkerSize',14, ...
    'LineWidth',3);

hold off;


%% PANEL 3 - Rover Navigation

nexttile;

imagesc(mineX,mineY,CH4_Map');

set(gca,'YDir','normal');

xlabel('Mine X');
ylabel('Mine Y');

title('AI-Guided Rover Navigation');

colorbar;

hold on;

plot(pathX,pathY,'k-o', ...
    'LineWidth',2, ...
    'MarkerSize',4);

plot(roverX,roverY,'ko', ...
    'MarkerSize',10, ...
    'LineWidth',2);

plot(estimatedSourceX,estimatedSourceY,'kx', ...
    'MarkerSize',14, ...
    'LineWidth',3);

hold off;


%% PANEL 4 - AI Emergency Status

nexttile;

axis off;

text(0.05,0.90,'AI MINE RESCUE STATUS', ...
    'FontSize',16, ...
    'FontWeight','bold');

text(0.05,0.78, ...
    sprintf('AI Behaviour: %s',string(PredictedBehavior)), ...
    'FontSize',14, ...
    'FontWeight','bold');

text(0.05,0.66, ...
    sprintf('CH4: %.2f ppm',CH4_current), ...
    'FontSize',12);

text(0.05,0.57, ...
    sprintf('O2 Change: %.3f %%',O2_change), ...
    'FontSize',12);

text(0.05,0.48, ...
    sprintf('Spread Rate: %.4f grid/s',spreadRate(1)), ...
    'FontSize',12);

text(0.05,0.39, ...
    sprintf('Source Estimate: (%.2f, %.2f)', ...
    estimatedSourceX,estimatedSourceY), ...
    'FontSize',12);

text(0.05,0.30, ...
    sprintf('Source Error: %.2f grid units',sourceError), ...
    'FontSize',12);

text(0.05,0.21, ...
    sprintf('AI Test Accuracy: %.2f %%',testAccuracy), ...
    'FontSize',12);

text(0.05,0.12, ...
    'STATUS: EMERGENCY / SOURCE LOCATED', ...
    'FontSize',13, ...
    'FontWeight','bold');