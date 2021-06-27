clc; clear all; close all;

I = imread('myimage.jpg');
I1 = I;

[row,coln] = size(I);       % görüntünün boyutunun tutulmasý
reml = rem(row,8);
row=row-reml;

rem2 = rem(coln,8);
coln = coln-rem2;

I = imresize(I,[row coln]);
I = double(I);

% her görüntüden 128 piksel deðeri çýkarma
I = I - (128*ones(row, coln));
I = I - 128;
quality = input('Hangi kalitede sýkýþtýrmaya ihtiyacýnýz var? - ');

% Kalite Matrisi Formülasyonu
Q50 = [16 11 10 16 24 40 51 61;
    12 12 14 19 26 58 60 55;
    14 13 16 24 40 57 69 56;
    14 17 22 29 51 87 80 62;
    18 22 37 56 68 109 103 77;
    24 35 55 64 81 104 113 92;
    49 64 78 87 103 121 120 101;
    72 92 95 98 112 100 103 99];

if quality > 50
    QX = round(Q50.*(ones(8)*((100-quality)/50)));
    QX = uint8(QX);
elseif quality <50
    QX = round(Q50.*(ones(8)*(50/quality)));
    QX = uint8(QX);
elseif quality == 50
    QX = Q50;
    
end

% Ýleri DCT Matrisi Ve Ters DCT Matrisinin Formülü
DCT_matrix8 = dct(eye(8));
iDCT_matrix8 = DCT_matrix8';

% Jpeg Sýkýþtýrmasý
dct_restored = zeros(row,coln);
QX = double(QX);

% Ayrýk Kosinüs Dönüþümü
for i1 = [1:8:row]
    for i2 = [1:8:coln]
        zBLOCK = I(i1:i1+7, i2:i2+7);
        win1 = DCT_matrix8*zBLOCK*iDCT_matrix8;
        dct_domain(i1:i1+7, i2:i2+7) = win1;
    end
end

%DCT Katsayýlarýnýn Nicelleþtirilmesi
for i1 = [1:8:row]
    for i2 = [1:8:coln]
        win1 = dct_domain(i1:i1+7, i2:i2+7);
        win2 = round(win1./QX);
        dct_quantized(i1:i1+7, i2:i2+7) = win2;
    end
end

compresed_img = dct_quantized;

% DCT Katsayýlarýnýn Dekuantizasyonu
for i1 = [1:8:row]
    for i2 = [1:8:coln]
        win2 = dct_quantized(i1:i1+7, i2:i2+7);
        win3 = win2.*QX;
        dct_dequantized(i1:i1+7, i2:i2+7) = win3;
    end
end

% Ters Ayrýk Kosinüs Dönüþümü
for i1 = [1:8:row]
    for i2 = [1:8:coln]
        win3 = dct_dequantized(i1:i1+7, i2:i2+7);
        win4 = iDCT_matrix8*win3*DCT_matrix8;
        dct_restored(i1:i1+7, i2:i2+7) = win4;
    end
end
I2 = dct_restored;

% Görüntü Matrisini Yoðunluk Görüntüsüne Dönüþtürme
K = mat2gray(I2);

% Sonuçlarýn Gösterimi
figure(1); imshow(I1); title('Orjinal Fotoðraf');

figure(2);imshow(compresed_img);title('Dct Noktalarý');

figure(3); imshow(K); title('Sýkýþtýrýlmýþ Görüntü');