% Input:150dimensions 

loaddata;
% trainset
posSet = x1(x1(:, end)==1, :);
negSet = x1(x1(:, end)==-1, :);

aa = randperm(9933);
trainSet = posSet(aa(1:8000), :);

bb = randperm(52205);
trainSet = [trainSet; negSet(bb(1:8000), :)];

% testset
testSet = posSet(aa(8001:end), :);
testSet = [testSet; negSet(bb(8001:10000), :)];

% write to file
%dlmwrite('TorchTrain_150d.txt',trainSet,'delimiter',' ');
%dlmwrite('TorchTest_150d.txt',testSet,'delimiter',' ');
fidTrain = fopen('LightTrain_150d.txt','w');
fidTest = fopen('LightTest_150d.txt','w');
for idx = 1:size(trainSet, 1)
    one = trainSet(idx, :);
    fprintf(fidTrain,'%+d ',int8(one(end)));
    for j = 1:(size(trainSet,2)-1)
        fprintf(fidTrain,[int2str(j) ':%f '], one(j));
    end
    fprintf(fidTrain,'\n');
end

for idx = 1:size(testSet, 1)
    one = testSet(idx, :);
    fprintf(fidTest,'%+d ',int8(one(end)));
    for j = 1:(size(testSet,2)-1)
        fprintf(fidTest,[int2str(j) ':%f '], one(j));
    end
    fprintf(fidTest,'\n');
end


fclose(fidTrain);
fclose (fidTest);

