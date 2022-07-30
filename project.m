%Final Project
folder = dir(['D:\NTPU\影像處理\Final_project\sample','*.jpg']);
files = 'D:\NTPU\影像處理\Final_project\sample';

fid = fopen('E:\MATexercise\final_project\output\output.txt', 'w');
clear = [];
fprintf(fid, '%s', clear);
for s = 1:length(folder)
%自動讀檔
filename = strcat(files, folder(s).name);
cin = imread(filename);
%figure,imshow(cin);

%影像前處理
%Step 1 : 影像灰階化
cin = rgb2gray(cin);
c = cin(166:386,336:900);
%figure,imshow(c)

%Step 2 : 直方圖等化
ch = histeq(c);
%figure,imshow(ch)

%Step 3 : 邊緣偵測
f1 = [-1 0 1];
f2 = [1 0 -1];
edge1 = imfilter(ch,f1);
edge2 = imfilter(ch,f2);
edge = edge1 + edge2;
%figure,imshow(edge1)
%figure,imshow(edge2)
%figure,imshow(edge)

%Step 4 : 平均濾波與二值化 去雜訊
a = fspecial('average',3);
ca = imfilter(edge,a);
%figure,imshow(ca)
cb = ca>85;
%figure,imshow(cb)

%Step 5 : 形態學
%元素結構
sq = ones(3,3);
cr = [0 1 0; 1 1 1; 0 1 0;];
%closing去除雜訊
%opening連結區塊
cm = imclose(imopen(cb,cr),cr); 
%figure,imshow(cm)
cdi = cm;
for i = 1:7
cdi = imdilate(cdi,sq);
%figure,imshow(cdi)
end
%figure,imshow(cdi),impixelinfo

%車牌定位
%Step 7 : 連通標記
cl = bwlabel(cdi);
num = max(cl(:));

%Step 8 : 篩選車牌區塊
[r,c] = size(cl);
maybe = [];
for i = 1:num
check = cl==i;
minr = 900; maxr = 0; minc = 900; maxc = 0;
for j = 1:r
    for k = 1:c
        if(check(j,k)==1)
            if(j<minr)
                minr = j;
            end
            if(j>maxr)
                maxr = j;
            end
            if(k<minc)
                minc = k;
            end
            if(k>maxc)
                maxc = k;
            end
        end
    end
end
check2 = check(minr:maxr,minc:maxc);
[r2,c2] = size(check2);
%figure,imshow(check2),impixelinfo
if(r2*c2>4200)
    if(c2<180)
        if(1.5<(c2/r2) && (c2/r2)<5)
            maybe = i;
        end
    end
end
end
check = cl==maybe;
%figure,imshow(check),impixelinfo

%字元切割
%Step 9 : 車牌切割
pminr = 900; pmaxr = 0; pminc = 900; pmaxc = 0;
for j = 1:r
    for k = 1:c
        if(check(j,k)==1)
            if(j<pminr)
                pminr = j;
            end
            if(j>pmaxr)
                pmaxr = j;
            end
            if(k<pminc)
                pminc = k;
            end
            if(k>pmaxc)
                pmaxc = k;
            end
        end
    end
end
pminr = 166+pminr;
pmaxr = 166+pmaxr;
pminc = 336+pminc;
pmaxc = 336+pmaxc;
p = cin(pminr:pmaxr,pminc:pmaxc);
%figure,imshow(p),impixelinfo

%Step 10 : 字元連通標記
ph = histeq(p);
pb = ph>100;
pb = pb==0;
%figure,imshow(pb)
pl = bwlabel(pb);
pnum = max(pl(:));

%Step 11 : 字元篩選
[pr,pc] = size(pl);
carmaybe = [];
carplot = [];
carnum = 0;
for i = 1:pnum
carcheck = pl==i;
carminr = 900; carmaxr = 0; carminc = 900; carmaxc = 0;
for j = 1:pr
    for k = 1:pc
        if(carcheck(j,k)==1)
            if(j<carminr)
                carminr = j;
            end
            if(j>carmaxr)
                carmaxr = j;
            end
            if(k<carminc)
                carminc = k;
            end
            if(k>carmaxc)
                carmaxc = k;
            end
        end
    end
end
carcheck2 = carcheck(carminr:carmaxr,carminc:carmaxc);
[pr2,pc2] = size(carcheck2);
%figure,imshow(carcheck2),impixelinfo
if(pr2*pc2>50)
    if(pr2>15 && pc2>3)
        if(1.5<(pr2/pc2))
            carnum = carnum + 1;
            carmaybe(carnum) = i;
            carplotr1(carnum) = carminr;
            carplotr2(carnum) = carmaxr;
            carplotc1(carnum) = carminc;
            carplotc2(carnum) = carmaxc;
        end
    end
end
end

%Step 12 : 字元座標輸出
fid = fopen('E:\MATexercise\final_project\output\output.txt', 'a');
fprintf(fid, '%s\r\n', filename(35:41));
carplotr1 = carplotr1 + pminr;
carplotr2 = carplotr2 + pminr;
carplotc1 = carplotc1 + pminc;
carplotc2 = carplotc2 + pminc;
for i = 1:carnum
    r1 = carplotr1(i)-2;
    r2 = carplotr2(i);
    c1 = carplotc1(i)-2;
    c2 = carplotc2(i);
    %figure,imshow(cin(r1:r2,c1:c2))
    fprintf(fid, '%d %d %d %d\r\n', c1, r1, c2, r2);
end
fclose(fid);
end