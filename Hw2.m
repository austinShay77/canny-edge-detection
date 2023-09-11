baseImage = double(imread("circles1.gif"))/255;
image = im2gray(baseImage);

%imwrite(image, "greyScale.jpg");

kernalSize = 4;
sigma = 1.2;
[x, y] = meshgrid(-kernalSize:kernalSize, -kernalSize:kernalSize);
N = size(y, 1) - 1;

kernel = exp(-(x.^2 + y.^2) / (2 * sigma * sigma)) / (2 * pi * sigma * sigma);

blurredImage = image;

for i = N: size(image, 1) - N
    for j = N: size(image, 2) - N
        temp = image(i: i + N, j: j + N).*kernel;
        blurredImage(i, j) = sum(temp(:));
    end
end

%blurredImage = uint8(blurredImage*255);
%subplot(1,2,1), imshow(blurredImage);
%imwrite(blurredImage, "9x9Kernal1.2sigma.jpg")

gradientX = zeros(size(image));
gradientY =  zeros(size(image));
magnitude = zeros(size(image));
ykernel = [0 -0.5 0; 0 0 0; 0 0.5 0];
xkernel = [0 0 0; -0.5 0 0.5; 0 0 0];

for i = 1: size(image, 1) - 2
    for j = 1: size(image, 2) - 2
        tempy = image(i: i + 2, j: j + 2).*ykernel;
        tempx = image(i: i + 2, j: j + 2).*xkernel;
        gradientX(i, j) = abs(sum(tempx(:)));
        gradientY(i, j) = abs(sum(tempy(:)));
    end
end

gradientMagnitude = gradientY + gradientY;
%gradientX = uint8(gradientX*255);
%gradientY = uint8(gradientY*255);
%subplot(1,2,2), imshow(gradientY);
%subplot(1,2,2), imshow(gradientMagnitude);
%subplot(1,2,2), imshow(gradientY);
%imwrite(gradientMagnitude, "gradientMagnitude.jpg")


%nonMaximimunSuppression = uint8(nonMaximimunSuppression*255);
%imwrite(nonMaximimunSuppression, "circlesnonMaximunSuppression.jpg")
%imshow(gradientMagnitude)

lowThreshold = 45;
highThreshold = 65;
hysterisis = uint8(gradientMagnitude*255);
hysterisisImage = zeros(size(hysterisis));
padding = zeros(size(hysterisis));

for i = 1: size(hysterisis, 1)
    for j = 1: size(hysterisis, 2)
        if (hysterisis(i,j) > lowThreshold)% && (hysterisis(i,j) < highThreshold)
            padding(i,j) = hysterisis(i,j);
            eightWayCheck = hysterisis(conv2(padding, [1 1 1; 1 0 1; 1 1 1], 'same')>0);
            I = find(eightWayCheck > highThreshold);
            if size(I,1) > 0
                hysterisisImage(i,j) = 1;
            else
                hysterisisImage(i,j) = 0;
            end
        elseif hysterisis(i,j) >= highThreshold
            hysterisisImage(i,j) = 1;
        elseif hysterisis(i,j) < lowThreshold
            hysterisisImage(i,j) = 0;
        end
    end
end

%imwrite(hysterisisImage, "dataSethysterisis.jpg");
nonMaximimunSuppression = hysterisisImage;

for i = 1: size(image, 1)
    for j = 1: size(image, 2)
        magnitude = gradientX(i, j) + gradientY(i, j);
        angle = atan2(double(gradientY(i,j)), double(gradientX(i,j)));

        %left and right
        if (angle < pi/8 || angle >= (15*pi)/8 || (angle >= (7*pi)/8 && angle < (9*pi)/8)) && (j > 1 && j < size(image, 2))
            leftMagnitude = gradientX(i, j-1) + gradientY(i, j-1);
            rightMagnitude = gradientX(i, j+1) + gradientY(i, j-1);
            if (leftMagnitude > magnitude) && (leftMagnitude > rightMagnitude)
                nonMaximimunSuppression(i,j) = leftMagnitude;
            elseif (rightMagnitude > magnitude) && (rightMagnitude > leftMagnitude)
                nonMaximimunSuppression(i,j) = rightMagnitude;
            end

        %up and down
        elseif ((angle >= (3*pi)/8 && angle < (5*pi)/8) || (angle >= (11*pi)/8 && angle < (13*pi)/8)) && (i > 1 && i < size(image, 1))
            upMagnitude = gradientX(i-1, j) + gradientY(i-1, j);
            downMagnitude = gradientX(i+1, j) + gradientY(i+1,j);
            if (upMagnitude > magnitude) && (upMagnitude > downMagnitude)
                nonMaximimunSuppression(i,j) = upMagnitude;
            elseif (downMagnitude > magnitude) && (downMagnitude > upMagnitude)
                nonMaximimunSuppression(i,j) = downMagnitude;
            end

        %upleft downright
        elseif ((angle >= pi/8 && angle < (3*pi)/8) || (angle >= (9*pi)/8 && angle < (11*pi)/8))  && ((i > 1 && i < size(image, 1)) && (j > 1 && j < size(image, 2)))
            upLeftMagnitude = gradientX(i-1, j-1) + gradientY(i-1, j-1);
            downRightMagnitude = gradientX(i+1, j+1) + gradientY(i+1, j+1);
            if (upLeftMagnitude > magnitude) && (upLeftMagnitude > downRightMagnitude)
                nonMaximimunSuppression(i,j) = upLeftMagnitude;
            elseif (downRightMagnitude > magnitude) && (downRightMagnitude > upLeftMagnitude)
                nonMaximimunSuppression(i,j) = downRightMagnitude;
            end
        
        %upright and downleft
        elseif ((angle >= (5*pi)/8 && angle < (7*pi)/8) || (angle >= (13*pi)/8 && angle < (15*pi)/8)) && ((i > 1 && i < size(image, 1)) && (j > 1 && j < size(image, 2)))
            upRightMagnitude = gradientX(i-1, j+1) + gradientY(i-1, j+1);
            downLeftMagnitude = gradientX(i+1, j-1) + gradientY(i+1, j-1);
            if (upRightMagnitude > magnitude) && (upRightMagnitude > downLeftMagnitude)
                nonMaximimunSuppression(i,j) = upRightMagnitude;
            elseif (downLeftMagnitude > magnitude) && (downLeftMagnitude > upRightMagnitude)
                nonMaximimunSuppression(i,j) = downLeftMagnitude;
            end
        end
        nonMaximimunSuppression(i,j) = magnitude;
    end
end

%imwrite(nonMaximimunSuppression, "nonMaximunSuppression.jpg")
%subplot(1,2,2), imshow(hysterisisImage);
%imwrite(hysterisisImage, "circleshysterisis.jpg");
imshow(nonMaximimunSuppression)


