
% Load images.
imgs = fullfile('imagens_praca3poderes');
imgSet = imageSet(imgs);

% Display images to be stitched
montage(imgSet.ImageLocation)

% Read the first image from the image set.
img = read(imgSet, 1);

% Initialize features for I(1)
grayImg = rgb2gray(img);
pts = detectSURFFeatures(grayImg);
[fts, pts] = extractFeatures(grayImg, pts);

% Initialize all the transforms to the identity matrix. Note that the
% projective transform is used here because the building images are fairly
% close to the camera. Had the scene been captured from a further distance,
% an affine transform would suffice.
tforms(imgSet.Count) = projective2d(eye(3));

% Iterate over remaining image pairs
for n = 2:imgSet.Count

    % Store points and features for I(n-1).
    ptsAnt = pts;
    ftsAnt = fts;

    % Read I(n).
    img = read(imgSet, n);

    % Detect and extract SURF features for I(n).
    grayImg = rgb2gray(img);
    pts = detectSURFFeatures(grayImg);
    [fts, pts] = extractFeatures(grayImg, pts);

    % Find correspondences between I(n) and I(n-1).
    pares = matchFeatures(fts, ftsAnt, 'Unique', true);

    mtchdPts = pts(pares(:,1), :);
    mtchdPtsAnt = ptsAnt(pares(:,2), :);

    % Estimate the transformation between I(n) and I(n-1).
    tforms(n) = estimateGeometricTransform(mtchdPts, mtchdPtsAnt,...
    'projective', 'Confidence', 99.9, 'MaxNumTrials', 2000);

    % Compute T(1) * ... * T(n-1) * T(n)
    tforms(n).T = tforms(n-1).T * tforms(n).T;
end

imgSize = size(img);  % all the images are the same size

% Compute the output limits  for each transform
for i = 1:numel(tforms)
    [xlim(i,:), ylim(i,:)] = outputLimits(tforms(i), [1 imgSize(2)], [1 imgSize(1)]);
end

avgXLim = mean(xlim, 2);

[~, idx] = sort(avgXLim);

centerIdx = floor((numel(tforms)+1)/2);

centerImageIdx = idx(centerIdx);

Tinv = invert(tforms(centerImageIdx));

for i = 1:numel(tforms)
    tforms(i).T = Tinv.T * tforms(i).T;
end

for i = 1:numel(tforms)
    [xlim(i,:), ylim(i,:)] = outputLimits(tforms(i), [1 imgSize(2)], [1 imgSize(1)]);
end

% Find the minimum and maximum output limits
xMin = min([1; xlim(:)]);
xMax = max([imgSize(2); xlim(:)]);

yMin = min([1; ylim(:)]);
yMax = max([imgSize(1); ylim(:)]);

% Width and height of panorama.
width  = round(xMax - xMin);
height = round(yMax - yMin);

% Initialize the "empty" panorama.
panorama = zeros([height width 3], 'like', img);

blender = vision.AlphaBlender('Operation', 'Binary mask', ...
    'MaskSource', 'Input port');

% Create a 2-D spatial reference object defining the size of the panorama.
xLimits = [xMin xMax];
yLimits = [yMin yMax];
panoramaView = imref2d([height width], xLimits, yLimits);

% Create the panorama.
for i = 1:imgSet.Count

    img = read(imgSet, i);

    % Transform I into the panorama.
    warpedImage = imwarp(img, tforms(i), 'OutputView', panoramaView);

    % Create an mask for the overlay operation.
    warpedMask = imwarp(ones(size(img(:,:,1))), tforms(i), 'OutputView', panoramaView);

    % Clean up edge artifacts in the mask and convert to a binary image.
    warpedMask = warpedMask >= 1;

    % Overlay the warpedImage onto the panorama.
    panorama = step(blender, panorama, warpedImage, warpedMask);
end

figure
imshow(panorama)