% myData = rand(27,1000); % Sample data
% Define the mean function to be used with blockproc.
myMeanFunction = @(block_struct) mean(mean(block_struct.data));
% Get the means by each 1-by-20 block.
Test = blockproc(H, [20 20], myMeanFunction);

for i=1:2817
    hPreview(i,:)=blockMeans1(2818-i,:);
end

B=A';

D=ones(1424,2817);
for j=1:2817
    D(:,j)=j/2817;
end

for i=1:11268
    Z1(i,:)=Zpaul1(11269-i,:);
end

Z=Z1';

h_FullRes=zeros(11392,11268);
for i=1:11268
    h_FullRes(:,i)=i/11268;
end

for i=1:712
    for j=1:705
        if isnan(H(i,j))==true
            Errs(i,j)=H(i,j);
        end
    end
end


for i=1:712
    for j=1:132
        if isnan(Errs(i,j))==true
            Errs(i,j)=1;
        end
    end
end
