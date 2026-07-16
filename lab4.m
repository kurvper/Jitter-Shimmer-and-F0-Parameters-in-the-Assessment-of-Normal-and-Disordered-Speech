
clear; clc;

%% =========================
% SZUKANIE PLIKÓW REKURENCYJNIE
%% =========================

pathHealthy = 'prawidłowa';
pathPath = 'patologiczna';

filesH = dir(fullfile(pathHealthy, '**', '*.wav'));
filesP = dir(fullfile(pathPath, '**', '*.wav'));

allFiles = [filesH; filesP];

%% =========================
% WYNIKI
%% =========================

Group = [];
FileID = {};
Jitt = [];
Shimm = [];
F0val = [];

%% =========================
% ANALIZA WSZYSTKICH PLIKÓW
%% =========================

for i = 1:length(allFiles)

    file = fullfile(allFiles(i).folder, allFiles(i).name);

    % określenie grupy na podstawie ścieżki
    if contains(file, pathHealthy)
        g = 1;
    elseif contains(file, pathPath)
        g = 2;
    else
        continue;
    end

    [x,fs] = audioread(file);

    [J,S,F0] = analiza_parametrow(x,fs);

    if ~isnan(J) && ~isnan(S) && ~isnan(F0)

        Group(end+1) = g;
        FileID{end+1} = file;
        Jitt(end+1) = J;
        Shimm(end+1) = S;
        F0val(end+1) = F0;

    end
end

%% =========================
% TABELA
%% =========================

T = table(Group',FileID',Jitt',Shimm',F0val');
T.Properties.VariableNames = ...
    {'Group','File','Jitt','Shimm','F0'};

disp(T(1:min(10,height(T)),:));

fprintf('Wczytano %d plików\n', height(T));

%% =========================
% WYKRES 2D
%% =========================

figure; hold on;

idxH = T.Group == 1;
idxP = T.Group == 2;

scatter(T.Jitt(idxH), T.Shimm(idxH), 'g','filled');
scatter(T.Jitt(idxP), T.Shimm(idxP), 'r','filled');

xlabel('Jitter [%]');
ylabel('Shimmer [%]');
title('Jitter vs Shimmer');
legend('Prawidłowa','Patologiczna');
grid on;

%% =========================
% WYKRES 3D
%% =========================

figure; hold on; grid on;

scatter3(T.Jitt(idxH), T.Shimm(idxH), T.F0(idxH), 'g','filled');
scatter3(T.Jitt(idxP), T.Shimm(idxP), T.F0(idxP), 'r','filled');

xlabel('Jitter [%]');
ylabel('Shimmer [%]');
zlabel('F0 [Hz]');
title('Jitter - Shimmer - F0');
legend('Prawidłowa','Patologiczna');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FUNKCJA ANALIZY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Jitt, Shimm, F0] = analiza_parametrow(x, fs)

x = x - mean(x);
x = x / max(abs(x));

d = designfilt('bandpassiir','FilterOrder',4, ...
    'HalfPowerFrequency1',70,'HalfPowerFrequency2',400, ...
    'SampleRate',fs);

x = filtfilt(d,x);

%% F0
minF0 = 70; maxF0 = 400;
minLag = round(fs/maxF0);
maxLag = round(fs/minF0);

[r,lags] = xcorr(x,'coeff');
r = r(lags >= 0);

searchRange = r(minLag:maxLag);
[~, idx] = max(searchRange);
lag = idx + minLag - 1;

if lag <= 0
    Jitt = NaN; Shimm = NaN; F0 = NaN;
    return;
end

F0 = fs / lag;

%% PEAKS
env = abs(hilbert(x));

[~, locs] = findpeaks(env,'MinPeakDistance',round(0.8*lag));

if length(locs) < 6
    Jitt = NaN; Shimm = NaN;
    return;
end

%% PERIODY
periods = diff(locs);
Fi = fs ./ periods;

Fi = Fi(abs(Fi - mean(Fi)) < 2*std(Fi));

if length(Fi) < 6
    Jitt = NaN; Shimm = NaN;
    return;
end

%% JITTER
Jitt = mean(abs(diff(Fi))) / mean(Fi) * 100;

%% SHIMMER
A = [];

for i = 1:length(locs)-1
    seg = x(locs(i):locs(i+1));
    if length(seg) > 5
        A(end+1) = rms(seg);
    end
end

if length(A) < 6
    Shimm = NaN;
    return;
end

Shimm = mean(abs(diff(A))) / mean(A) * 100;

end