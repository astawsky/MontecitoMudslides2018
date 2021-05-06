% Below is the code for creating the movies for h,H,h(i)-h(1), and
% H(i)-H(1).

% Modifications will be needed to change between h and H but they are minor
% and are explained below.


% X will contain strings of the names of the
% waterframes, h, in the correct order
Xframes4Info=dir('DifferentsmallhWaterFrames'); % put in the name of the folder we get the frames from
X={};
[n,~]=size(Xframes4Info);
for j=1:n
    X{j}=Xframes4Info(j).name;
end
X=natsortfiles(X);


for j=4:n
    if j<=n
        Nexth=load(X{j});
        Nexth.h([540:570],:)=[];
        Nexth.h([1:30],:)=[];
        Nexth.h(:,[200:564])=[];
        Nexth.h(:,[1:40])=[];
        h=Nexth.h;
        save(sprintf('DifferentsmallhWaterFrames_cutcut/frame_%d', j-3), 'h');
    end
end