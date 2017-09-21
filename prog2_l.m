% Universidade de Brasilia
% Departamento de Ciencia da Computacao 
% Projeto Demonstrativo 1
% Principios de Visao Computacional, Turma A, 2/2017
% Filipe Teixeira (14/0139486) & Lucas Santos (14/0151010)

% Objetivo: Construir um panorama a partir de 10 imagens da Praca dos Tres Poderes, DF

%% Imagens a serem processadas
imgs = fullfile('imagens_praca3poderes_menores');
imgSet = imageSet(imgs);
numImgs = imgSet.Count;

% Mostra as imagens que serao processadas
figure(1), montage(imgSet.ImageLocation), title('Imagens originais'), pause;

%% Primeira Imagem
% Leitura da Primeira Imagem
img = readimage(imgSet, 1);
% Detectando features e pontos para a imagem (1)
grayImage = rgb2gray(img);
points = detectSURFFeatures(grayImage);
[features, points] = extractFeatures(grayImage, points);

%% Imagens subsequentes em pares
for n = 2:numImgs
    %% Imagem (n-1)
    % Le a imagem (n-1).
    imgPrevious = readimage(imgSet, n-1);
    % Guarda os pontos e features da imagem I(n-1).
    pointsPrevious = points;
    featuresPrevious = features;
    % Selecionando os pontos mais relevantes
    strongestPointsPrev = pointsPrevious.selectStrongest(20);
    % Mostrando os pontos de interesse da imagem
    figure(2), imshow(imgPrevious), hold on, title( ['Pontos de interesse da Imagem ' num2str(n-1) ] ), strongestPointsPrev.plot('showOrientation',true), pause;

    %% Imagem (n)
    % Le a imagem (n).
    img = readimage(imgSet, n);
    % Detectando features e pontos para a imagem I(n)
    grayImage = rgb2gray(img);
    points = detectSURFFeatures(grayImage);
    [features, points] = extractFeatures(grayImage, points);
    % Selecionando os pontos mais relevantes    
    strongestPoints = points.selectStrongest(20);
    % Mostrando os pontos de interesse da imagem
    figure(3), imshow(img), hold on, title( ['Pontos de interesse da Imagem ' num2str(n) ] ), strongestPoints.plot('showOrientation',true), pause;
    
    %% Casamanetro entre o par de imagens (n) e (n-1).
    indexPairs = matchFeatures(features, featuresPrevious, 'Unique', true);
    matchedPoints = points(indexPairs(:,1), :);
    matchedPointsPrev = pointsPrevious(indexPairs(:,2), :);
    % Mostra os pontos de interesse em comum entre o par de imagens atual
    figure(4), showMatchedFeatures(imgPrevious, img, matchedPointsPrev, matchedPoints),title( ['Pontos de interesse em comum entre a Imagem ' num2str(n-1) '(GB) e a Imagem ' num2str(n) '(R)' ] ), legend(['Pontos de interesse da Imagem ' num2str(n-1) ], ['Pontos de interesse da Imagem ' num2str(n) ]),  pause;
    
end