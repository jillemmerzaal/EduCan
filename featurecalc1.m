function [feature1] = featurecalc1(data_1,b)
% 
norm_1=vecnorm(data_1(:,1:3),2,2);
points=floor(length(data_1)/b)*b;
j=1;
for i=1:b:points
    feature1(j,1)=mean(norm_1(i:i+b-1));
    feature1(j,2)=mean(data_1(i:i+b-1,1));
    feature1(j,3)=mean(data_1(i:i+b-1,2));
    feature1(j,4)=mean(data_1(i:i+b-1,3));
    feature1(j,5)=var(norm_1(i:i+b-1));
    feature1(j,6)=var(data_1(i:i+b-1,1));
    feature1(j,7)=var(data_1(i:i+b-1,2));
    feature1(j,8)=var(data_1(i:i+b-1,3));
    feature1(j,9)=max(norm_1(i:i+b-1));
    feature1(j,10)=max(data_1(i:i+b-1,1));
    feature1(j,11)=max(data_1(i:i+b-1,2));
    feature1(j,12)=max(data_1(i:i+b-1,3));
    feature1(j,13)= min(norm_1(i:i+b-1));
    feature1(j,14)=min(data_1(i:i+b-1,1));
    feature1(j,15)=min(data_1(i:i+b-1,2));
    feature1(j,16)=min(data_1(i:i+b-1,3));   
    feature1(j,17)=entropy(norm_1(i:i+b-1)); 
    j=j+1;
end