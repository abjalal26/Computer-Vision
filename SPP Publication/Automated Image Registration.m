%% read image folder

imageDirectory = "C:\Users\Abdel Jalal\Desktop\cagayancillo airport\cropped";
imageFile = dir(fullfile(imageDirectory, '*.jpg')); %images in imageFile.name
currentFileName = fullfile(imageDirectory, imageFile(1).name);

%% initialization

I = imread(currentFileName);
grayImage = rgb2gray(I);
points = detectSURFFeatures(grayImage); % detect corners
[features, points] = extractFeatures(grayImage,points); % extract features
numImages = numel(imageFile);
tforms(numImages) = projective2d(eye(3));
imageSize = zeros(numImages,2);

%% image loop

for n = 2:numImages
    pointsPrevious = points;
    featuresPrevious = features;
    I = imread(fullfile(imageDirectory, imageFile(n).name));
    grayImage = rgb2gray(I);
    imageSize(n,:) = size(grayImage);
    points = detectSURFFeatures(grayImage);
    [features, points] = extractFeatures(grayImage, points);
    indexPairs = matchFeatures(features, featuresPrevious, 'Unique', true);
    matchedPoints = points(indexPairs(:,1), :);
    matchedPointsPrev = pointsPrevious(indexPairs(:,2), :);
    tforms(n) = estimateGeometricTransform(matchedPoints, matchedPointsPrev, ...
        'projective', 'Confidence', 99.9, 'MaxNumTrials', 2000);
    tforms(n).T = tforms(n).T * tforms(n-1).T;
end

%% panorama setup

for i = 1:numel(tforms)
    [xlim(i,:), ylim(i,:)] = outputLimits(tforms(i), ...
        [1 imageSize(i,2)], [1 imageSize(i,1)]);
end

avgXLim = mean(xlim, 2);
[~, idx] = sort(avgXLim);
centerIdx = floor((numel(tforms)+1)/2);
centerImageIdx = idx(centerIdx);
Tinv = invert(tforms(centerImageIdx));

for i = 1:numel(tforms)
    tforms(i).T = tforms(i).T * Tinv.T
end

for i = numel(tforms)
    [xlim(i,:), ylim(i,:)] = outputLimits(tforms(i), ...
        [1 imageSize(i,2)], [1 imageSize(i,1)]);
end

maxImageSize = max(imageSize);

xMin = min([1; xlim(:)]);
xMax = max([maxImageSize(2); xlim(:)]);

yMin = min([1; ylim(:)]);
yMax = max([maxImageSize(1); ylim(:)]);

width = round(xMax - xMin);
height = round(yMax - yMin);

%% final panorama

panorama = zeros([height width 3], 'like', I);
blender = vision.AlphaBlender('Operation', 'Binary mask', ...
    'MaskSource', 'Input port');

xLimits = [xMin xMax];
yLimits = [yMin yMax];
panoramaView = imref2d([height width], xLimits, yLimits);

for i = 1:numImages
    I = imread(fullfile(imageDirectory, imageFile(i).name));
    warpedImage = imwarp(I, tforms(i), 'OutputView', panoramaView);
    mask = imwarp(true(size(I,1), size(I,2)),...
    tforms(i), 'OutputView', panoramaView);
    panorama = step(blender, panorama, warpedImage, mask);
end

figure
imshow(panorama)

%% area computation

g = panorama(:,:,2);
x = [0:255];
[counts, center] = hist(g(:),x);
figure;
plot(center, counts);
counts(1);
size(g);
A = size(g,1)*size(g,2);
area = A - counts(1)