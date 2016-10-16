%{
% % % % % % % % % % % % % % % % % % % % % % % 
%
% Basic Matching - Lizi Chen
% http://www.vlfeat.org/overview/sift.html
%
% % % % % % % % % % % % % % % % % % % % % % % 
%}
colormap 'gray'; % somehow the rgb2gray(I) does not work, use this colormap to set globally.
Iscene = imread('scene.pgm');
Ibook = imread('book.pgm');
Iscene = single(Iscene);
Ibook = single(Ibook);
rows1 = size(Iscene,1);
rows2 = size(Ibook,1);
if (rows1 < rows2)
     Iscene(rows2, 1) = 0;
else
     Ibook(rows1, 1) = 0;
end
jointedImg = [Iscene, Ibook]; % Now append both images side-by-side.
%figure('Position', [100 100 size(jointedImg,2) size(jointedImg,1)]);
imagesc(jointedImg);% Display the jointed image
[fscene, dscene] = vl_sift(Iscene);
[fbook, dbook] = vl_sift(Ibook);
[matches, scores] = vl_ubcmatch(dscene, dbook, 1.5); 

    xa = fscene(1, matches(1,:));
    xb = fbook(1, matches(2,:)) + size(Iscene,2) ;
    ya = fscene(2, matches(1,:));
    yb = fbook(2, matches(2,:));
    hold on;
    h = line([xa ; xb], [ya ; yb]);
    set(h,'linewidth', 1, 'color', 'b') ;
    vl_plotframe(fscene(:,matches(1,:))) ;
    fbook(1,:) = fbook(1,:) + size(Iscene,2) ;
    vl_plotframe(fbook(:,matches(2,:))) ;

[fscene, dscene] = vl_sift(Iscene); % re-do, for another figure
[fbook, dbook] = vl_sift(Ibook);
    
GoodPoints1 = zeros(148,2);
GoodPoints2 = zeros(148,2);
goodPointCursor = 1;
for i = 1: 100 %repeat N = 100 times
   perm = randperm(size(matches,2));%number of matched points
   sel = perm(1:5) ;% randomly pick 5 points
   xalist = fscene(1, matches(1,sel));
   xblist = fbook(1, matches(2,sel));
   yalist = fscene(2, matches(1,sel));
   yblist = fbook(2, matches(2,sel));
   pointlist1 = horzcat(xalist',yalist');
   pointlist2 = horzcat(xblist',yblist');
   tform = fitgeotrans(pointlist2, pointlist1, 'affine');
   transformedPointlist2 = transformPointsForward(tform, pointlist2);
   for j = 1 : 5 % compare transformedPointlist1 with pointlist2
        distance = pdist([transformedPointlist2(j,:);pointlist1(j,:)], 'euclidean');
        if(distance < 10)% save the ones that distance less than 10 pixels to the group of inliers 
            GoodPoints2(goodPointCursor,:) = pointlist2(j,:);
            GoodPoints1(goodPointCursor,:) = pointlist1(j,:);
            goodPointCursor = goodPointCursor + 1;
        end    
   end    
end
% use the saved inliers - group of points to run the fitgeotrans again to get the overall best tform.
tform2 = fitgeotrans(GoodPoints2, GoodPoints1, 'affine');
figure;
finalImage = imwarp(Ibook, tform2); %'OutputView', imref2d(size(Ibook)));
colormap 'gray';
imagesc(finalImage);

%{
    figure(2) ; clf ;
    imagesc(cat(2, Ia, Ib)) ;

    xa = fa(1,matches(1,:)) ;
    xb = fb(1,matches(2,:)) + size(Ia,2) ;
    ya = fa(2,matches(1,:)) ;
    yb = fb(2,matches(2,:)) ;

    hold on ;
    h = line([xa ; xb], [ya ; yb]) ;
    set(h,'linewidth', 1, 'color', 'b') ;

    vl_plotframe(fa(:,matches(1,:))) ;
    fb(1,:) = fb(1,:) + size(Ia,2) ;
    vl_plotframe(fb(:,matches(2,:))) ;
    axis image off ;
%}

%{
cols1 = size(im1,2);
for i = 1: size(des1, 1)
  if (match(i) > 0)
    line([loc1(i,2) loc2(match(i),2)+cols1], ...
         [loc1(i,1) loc2(match(i),1)], 'Color', 'c');
  end
end
hold off;
%}

%{
[fscene, dscene] = vl_sift(Iscene);
    permS = randperm(size(fscene,2));
    selS = permS(1:50);
    h_S = vl_plotframe(fscene(:,selS));
    set(h_S,'color','r','linewidth',3) ;

[fbook, dbook] = vl_sift(Ibook);
    permB = randperm(size(fbook,2));
    selB = permB(1:50);
    
    h_B = vl_plotframe(fbook(:,selB));
    set(h_B,'color','y','linewidth',2) ;
%}  

%{
    [F1, D1] = vl_sift(Iscene);
    [F2, D2] = vl_sift(Ibook);
    % Where 1.5 = ratio between euclidean distance of NN2/NN1
    [matches, score] = vl_ubcmatch(D1,D2,1.25); 

    subplot(1,2,1);
    imshow(uint8(Iscene));
    hold on;
    plot(F1(1,matches(1,:)),F1(2,matches(1,:)),'b*');

    subplot(1,2,2);
    imshow(uint8(Ibook));
    hold on;
    plot(F2(1,matches(2,:)),F2(2,matches(2,:)),'r*');
%}  
