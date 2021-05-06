% So what I want to do is first is get a smoothing 11Kx11K frame, then
% mix it to H, then run the erode code with waterflow 3 and 5 with
% different 10^-2 and -1 laplace coefficients

% Add folders to path
addpath(genpath('/Users/alestawsky/Desktop/Code/'));

% smooth the FullResFrame
load('/Users/alestawsky/Desktop/Code/Smoothing_REAL_DEAMS.mat')
summer_erode2_onehundreth_1_minus2_wf5_minus3(NewSmoothingH, h, 5, index, target, original);

% Mix it with the original
load('/Users/alestawsky/Desktop/Smooth11KMudFrames/frame_4.mat');
HH=H;
load('/Users/alestawsky/Desktop/Smoothing_REAL_DEAMS.mat');
SmoothedH=H+.1*HH;

% Run the different versions of erode
summer_erode2_0005_pointthree_minus3_wf5_minus3(SmoothedH, h, toPrint, index, target, original);
summer_erode2_0005_pointthree_minus3_wf5_minus2(SmoothedH, h, toPrint, index, target, original);
summer_erode2_0005_pointthree_minus3_wf5_minus1(SmoothedH, h, toPrint, index, target, original);

% This should be good for now...


