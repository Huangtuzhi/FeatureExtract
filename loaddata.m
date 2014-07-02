clear all;
clc;
close all;
%load xtrain_s_hh;
load data_hh;

total_length=0;
x1=zeros(62000,151);
%for i=1:length(xtrain_s_cc)
%    a=xtrain_s_cc{i};
%    current_length=total_length;
%    total_length=total_length+size(a,1);
%    for j=1:size(a,1)
%        x1(current_length+j,:)=xtrain_s_cc{i}(j,:);
%    end
%end

for i=1:length(xtrain_s_hh)
    a=xtrain_s_hh{i};
    current_length=total_length;
    total_length=total_length+size(a,1);
    for j=1:size(a,1)
        x1(current_length+j,:)=xtrain_s_hh{i}(j,:);
    end
end

%clear xtrain_s_cc;
clear data_hh;
load  data_tt;

for i=1:100
    a=xtrain_s_tt{i};
    current_length=total_length;
    total_length=total_length+size(a,1);
    for j=1:size(a,1)
        x1(current_length+j,:)=xtrain_s_tt{i}(j,:);
    end
end
clear data_tt;


%x2=zeros(149500,451);
%index1=1;
%index2=1;
%for index1=1:size(x1,1)
%    if (isempty(x1(index1,:))~=1)
%        x2(index2,:)=x1(index1,:);
%       index2=index2+1;
%    end
%end