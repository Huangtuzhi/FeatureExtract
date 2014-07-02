clear all;
clc;
close all;

% load xtrain_s_hh;
% x1=xtrain_s_hh{1};
% for i=1:length(xtrain_s_hh)
%     a=xtrain_s_hh{i};
%     x1=[x1;a];
%     a=[];
% end

%load the data of huahua and tiantian
loaddata; 

xpos = x1(x1(:,end)==1, :);
xneg = x1(x1(:,end)==-1, :);
xpos_num=length(xpos);
xpos_train_num=fix(0.8*xpos_num);
xpos_test_num=xpos_num-xpos_train_num;

xneg_num=length(xneg);
xneg_train_num=2*xpos_train_num;
xneg_test_num=xneg_num-xneg_train_num;
xneg_train_percent=(2*xpos_train_num) / xneg_num;


%To get the $xpos_train $xpos_test $xneg_train $xneg_test
randVec = rand(1, xpos_num);
xpos_train=zeros(xpos_train_num-300,451);
xpos_test=zeros(xpos_test_num-300,451);

row1=1;
row2=1;
for idx = 1:xpos_num
    one = xpos(idx, :);
    if randVec(idx) < 0.8
        xpos_train(row1,:)=one;
        row1=row1+1;
    else
        xpos_test(row2,:)=one;
        row2=row2+1;
    end
end

randVec1 = rand(1, xneg_num);
xneg_train=zeros(xneg_train_num-300,451);
xneg_test=zeros(xneg_test_num-300,451);

row1=1;
row2=1;
for idx = 1:xneg_num
    one = xneg(idx, :);
    if randVec1(idx) < xneg_train_percent
        xneg_train(row1,:)=one;
        row1=row1+1;
    else
        xneg_test(row2,:)=one;
        row2=row2+1;
    end
end
% Merge to get $xtrain $xtest
xtrain=[xpos_train;xneg_train];
xtest=[xpos_test;xneg_test];


% Lab1---Extract necessary coloums
xtrain_lab1=[];
for gap=0:9
    temp=[xtrain(:,(13+gap*45):(15+gap*45)),xtrain(:,(28+gap*45):(30+gap*45)),xtrain(:,(43+gap*45):(45+gap*45))];
    xtrain_lab1=[xtrain_lab1,temp]; %90 dimensions
end
xtrain_lab1=[xtrain_lab1,xtrain(:,451)];

xtest_lab1=[];
for gap=0:9
    temp=[xtest(:,(13+gap*45):(15+gap*45)),xtest(:,(28+gap*45):(30+gap*45)),xtest(:,(43+gap*45):(45+gap*45))];
    xtest_lab1=[xtest_lab1,temp]; %90 dimensions
end
xtest_lab1=[xtest_lab1,xtest(:,451)];

% Lab2---Reduce dimensions
xtrain_lab2=xtrain_lab1(:,1:end-1);  
retain_dimensions = 11;     
[U,S,V] = svd(cov(xtrain_lab2));

%buff=[];
%for plot=1:90
%   arr(plot)=S(plot,plot);
%end
reduced_x = xtrain_lab2*U(:,1:retain_dimensions);
xtrain_lab2=[reduced_x,xtrain(:,end)];


xtest_lab2=xtest_lab1(:,1:end-1);  
retain_dimensions = 11;     
[U,S,V] = svd(cov(xtest_lab2));
reduced_x = xtest_lab2*U(:,1:retain_dimensions);
xtest_lab2=[reduced_x,xtest(:,end)];

% Lab3
xtrain_lab3=[];
for gap=0:9
    %temp=[xtrain(:,(1+gap*45):(5+gap*45)),xtrain(:,(13+gap*45):(15+gap*45)),xtrain(:,(16+gap*45):(20+gap*45)),xtrain(:,(28+gap*45):(30+gap*45)),xtrain(:,(31+gap*45):(35+gap*45)),xtrain(:,(43+gap*45):(45+gap*45))];
    temp=[xtrain(:,(1+gap*45):(5+gap*45)),xtrain(:,(13+gap*45):(15+gap*45)),xtrain(:,(28+gap*45):(30+gap*45)),xtrain(:,(43+gap*45):(45+gap*45))];
    xtrain_lab3=[xtrain_lab3,temp]; 
end
xtrain_lab3=[xtrain_lab3,xtrain(:,end)];


xtest_lab3=[];
for gap=0:9
    temp=[xtest(:,(1+gap*45):(5+gap*45)),xtest(:,(13+gap*45):(15+gap*45)),xtest(:,(28+gap*45):(30+gap*45)),xtest(:,(43+gap*45):(45+gap*45))];
    xtest_lab3=[xtest_lab3,temp]; 
end
xtest_lab3=[xtest_lab3,xtest(:,end)];

% Write lab1 data [90 dimensions without SVD]
%dlmwrite('xtrain_hh_90.txt',xtrain_lab1,'delimiter',' ');
%dlmwrite('xtest_hh_90.txt',xtest_lab1,'delimiter',' ');

% Write lab2 data [90 dimensions with SVD]
dlmwrite('xtrain_hhtt_12d.txt',xtrain_lab2,'delimiter',' ');
dlmwrite('xtest_hhtt_12d.txt',xtest_lab2,'delimiter',' ');

% Write lab3 data [ (9 dimensions + 5 MFCC)*10 without SVD ]
%dlmwrite('xtrain_lab3.txt',xtrain_lab3,'delimiter',' ');
%dlmwrite('xtest_lab3.txt',xtest_lab3,'delimiter',' ');

