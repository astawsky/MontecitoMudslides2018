% for the mudframes in FullResMudframes_cut1

% import the image
imget=imread('OtherFEMAdata.jpg');

% x plane and y plane are inversed
% resize it
B=imresize(imget,[564 570]);

% cut it
B(:,[540:570],:)=[]; % x left
B(:,[1:30],:)=[]; % x Right
B([264:564],:,:)=[]; % y bottom
B([1:264],:,:)=[]; % y top

% rotate it to face the right way
C=imrotate(B,270);

% resize it to put it under the surface
L=imresize(C,[509 159]);

% surf the Biggest Difference and image is at 0
surf(H29-H1,'FaceAlpha',.5)
colormap hot
shading interp
view(-90,90)
hold on
imagesc(flip(L,1))
hold off
