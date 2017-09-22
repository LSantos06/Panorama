% Universidade de Brasilia
% Departamento de Ciencia da Computacao 
% Projeto Demonstrativo 1
% Principios de Visao Computacional, Turma A, 2/2017
% Filipe Teixeira (14/0139486) & Lucas Santos (14/0151010)

% Objetivo: Construir um panorama a partir de 10 imagens da Praca dos Tres Poderes, DF

clear all;
close all;

%% Imagens a serem processadas
imgs = fullfile('imagens_praca3poderes_menores');
imgSet = imageSet(imgs);
numImages = 4;%imgSet.Count;
center = ceil(numImages/2);

% Mostra as imagens que serao processadas
figure(1), montage(imgSet.ImageLocation), title('Imagens originais'), pause;

% Inicializando vetor de homografias estimadas
homographies(numImages) = projective2d(eye(3));

%% Imagem Central
% Leitura da Imagem Central
img = readimage(imgSet, center);
% Detectando features e pontos para a Imagem Central
grayImage = rgb2gray(img);
points = detectSURFFeatures(grayImage);
[features, points] = extractFeatures(grayImage, points);

%% Imagens subsequentes em pares
%% Centro para a direita
for n = (center+1):1:numImages
    %% Imagem (n-1)
    % Le a imagem (n-1).
    imgPrevious = readimage(imgSet, n-1);
    % Guarda os pontos e features da imagem (n-1).
    pointsPrevious = points;
    featuresPrevious = features;
    % Selecionando os pontos mais relevantes
    strongestPointsPrev = pointsPrevious.selectStrongest(100);
    % Mostrando os pontos de interesse da imagem
    figure(2), imshow(imgPrevious), hold on, title( ['Pontos de interesse da Imagem ' num2str(n-1) ] ), strongestPointsPrev.plot('showOrientation',true), pause;

    %% Imagem (n)
    % Le a imagem (n).
    img = readimage(imgSet, n);
    % Detectando features e pontos para a imagem (n)
    grayImage = rgb2gray(img);
    points = detectSURFFeatures(grayImage);
    [features, points] = extractFeatures(grayImage, points);
    % Selecionando os pontos mais relevantes    
    strongestPoints = points.selectStrongest(100);
    % Mostrando os pontos de interesse da imagem
    figure(3), imshow(img), hold on, title( ['Pontos de interesse da Imagem ' num2str(n) ] ), strongestPoints.plot('showOrientation',true), pause;
    
    %% Casamento entre o par de imagens (n) e (n-1).
    indexPairs = matchFeatures(features, featuresPrevious, 'Unique', true);
    matchedPoints = points(indexPairs(:,1), :);
    matchedPointsPrev = pointsPrevious(indexPairs(:,2), :);
    % Mostra os pontos de interesse em comum entre o par de imagens atual
    figure(4), showMatchedFeatures(imgPrevious, img, matchedPointsPrev, matchedPoints),title( ['Pontos de interesse em comum entre a Imagem ' num2str(n-1) '(R) e a Imagem ' num2str(n) '(GB), com outliers' ] ), legend(['Pontos de interesse da Imagem ' num2str(n-1) ], ['Pontos de interesse da Imagem ' num2str(n) ]),  pause;
    
    %% Homografia estimada para as imagens (n) e (n-1)
    [homographies(n),inlierPts,inlierPtsPrev] = ...
        estimateGeometricTransform(matchedPoints,matchedPointsPrev,...
        'projective', 'Confidence', 99.9, 'MaxNumTrials', 2000);
    % Mostra os inliers obtidos a partir da homografia aproximada
    figure(5), showMatchedFeatures(imgPrevious, img, inlierPtsPrev, inlierPts),title( ['Pontos de interesse em comum entre a Imagem ' num2str(n-1) '(R) e a Imagem ' num2str(n) '(GB), sem outliers' ] ), legend(['Pontos de interesse da Imagem ' num2str(n-1) ], ['Pontos de interesse da Imagem ' num2str(n) ]),  pause;
    
    %% Acumulacao das transformadas
    homographies(n).T = homographies(n-1).T * homographies(n).T;
    disp(homographies(n).T);
end

%% Imagem Central
% Leitura da Imagem Central
img = readimage(imgSet, center);
% Detectando features e pontos para a Imagem Central
grayImage = rgb2gray(img);
points = detectSURFFeatures(grayImage);
[features, points] = extractFeatures(grayImage, points);

%% Centro para a esquerda
for m = (center-1):-1:1
    %% Imagem (m+1)
    % Le a imagem (m+1).
    imgPrevious = readimage(imgSet, m+1);
    % Guarda os pontos e features da imagem (m+1).
    pointsPrevious = points;
    featuresPrevious = features;
    % Selecionando os pontos mais relevantes
    strongestPointsPrev = pointsPrevious.selectStrongest(100);
    % Mostrando os pontos de interesse da imagem
    figure(2), imshow(imgPrevious), hold on, title( ['Pontos de interesse da Imagem ' num2str(m+1) ] ), strongestPointsPrev.plot('showOrientation',true), pause;

    %% Imagem (m)
    % Le a imagem (m).
    img = readimage(imgSet, m);
    % Detectando features e pontos para a imagem (m)
    grayImage = rgb2gray(img);
    points = detectSURFFeatures(grayImage);
    [features, points] = extractFeatures(grayImage, points);
    % Selecionando os pontos mais relevantes    
    strongestPoints = points.selectStrongest(100);
    % Mostrando os pontos de interesse da imagem
    figure(3), imshow(img), hold on, title( ['Pontos de interesse da Imagem ' num2str(m) ] ), strongestPoints.plot('showOrientation',true), pause;
    
    %% Casamento entre o par de imagens (m) e (m+1).
    indexPairs = matchFeatures(features, featuresPrevious, 'Unique', true);
    matchedPoints = points(indexPairs(:,1), :);
    matchedPointsPrev = pointsPrevious(indexPairs(:,2), :);
    % Mostra os pontos de interesse em comum entre o par de imagens atual
    figure(4), showMatchedFeatures(imgPrevious, img, matchedPointsPrev, matchedPoints),title( ['Pontos de interesse em comum entre a Imagem ' num2str(m+1) '(R) e a Imagem ' num2str(m) '(GB), com outliers' ] ), legend(['Pontos de interesse da Imagem ' num2str(m+1) ], ['Pontos de interesse da Imagem ' num2str(m) ]),  pause;
    
    %% Homografia estimada para as imagens (m) e (m+1)
    [homographies(m),inlierPts,inlierPtsPrev] = ...
        estimateGeometricTransform(matchedPoints,matchedPointsPrev,...
        'projective', 'Confidence', 99.9, 'MaxNumTrials', 2000);
    % Mostra os inliers obtidos a partir da homografia aproximada
    figure(5), showMatchedFeatures(imgPrevious, img, inlierPtsPrev, inlierPts),title( ['Pontos de interesse em comum entre a Imagem ' num2str(m+1) '(R) e a Imagem ' num2str(m) '(GB), sem outliers' ] ), legend(['Pontos de interesse da Imagem ' num2str(m+1) ], ['Pontos de interesse da Imagem ' num2str(m) ]),  pause;
    
    %% Acumulacao das transformadas
    homographies(m).T = homographies(m+1).T * homographies(m).T;
    disp(homographies(m).T);
end

%% Inicializacao do Panorama

% Tamanho da imagem (igual para todas) e numero total de homografias
imageSize = size(img); 
numHomographies = numel(homographies);

for i = 1:numHomographies
    [xlim(i,:), ylim(i,:)] = outputLimits(homographies(i), [1 imageSize(2)], [1 imageSize(1)]);
end

xMin = min([1; xlim(:)]);
xMax = max([imageSize(2); xlim(:)]);

yMin = min([1; ylim(:)]);
yMax = max([imageSize(1); ylim(:)]);

width  = round(xMax - xMin);
height = round(yMax - yMin);

% Definicao do tamanho do panorama
panorama = zeros([height width 3], 'like', img);

%% Construcao do panorama
blender = vision.AlphaBlender('Operation', 'Binary mask', ...
    'MaskSource', 'Input port');

xLimits = [xMin xMax];
yLimits = [yMin yMax];
panoramaView = imref2d([height width], xLimits, yLimits);

for i = 1:numImages

    img = readimage(imgSet, i);

    % Transforma a imagem para o plano do panorama
    warpedImage = imwarp(img, homographies(i), 'OutputView', panoramaView);
    figure(), imshow(warpedImage), pause;

    mask = imwarp(true(size(img,1),size(img,2)), homographies(i), 'OutputView', panoramaView);
    %figure(7), imshow(mask), pause;
    
    panorama = step(blender, panorama, warpedImage, mask);
end

figure()
imshow(panorama)
