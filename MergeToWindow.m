clear all;
clc;
close all;

wavFiles = find_wav('../selected_tiantian');
x={};
xtrain={};
xtrain_s_hh={};
fid=fopen('../selected_tiantian/tiantian.txt','r'); 
C=textscan(fid,'%s%s%d%d%s'); 
fclose(fid); 
  order1=C{1};
  order =C{2};
  spoint=C{3};
  epoint=C{4};
  letter=C{5};
  length=size(letter,1); 
  for i=1:length
      pat='[0-9]*';
    matche{i}=regexp(order{i},pat,'match');
    order2{i}=cell2mat(matche{i});
    order_n(i,:)=str2num(order2{i});
  end
  
  
for idx = 1:length
%idx=29;
    wavFile = strtrim(wavFiles(idx,:));
    pat='[0-9]*';
    matches=regexp(wavFile,pat,'match');
    a=matches;
    j1=cell2mat(a);
    j=str2num(j1);
    location=find(order_n==j);
if(strcmp(letter{location},'t')==1 && spoint(location,:)>4000)
   [x,fs,bits,opt_ck] = wavread(wavFile);
    startpoint=spoint(location,:);
    endpoint=epoint(location,:);

    ccc= FeatureExtract(x);
    %[mc,en]= mfcc(x);
    %x_fea=[mc,en];  %����ֵ��ÿһ֡6x1
    %x_fea=[mc(:,1:5),en];
    %x_fea=[ccc(:,1:5),ccc(:,13),ccc(:,14:18),ccc(:,26),ccc(:,27:31),ccc(:,39)];%mfcc����������һ�ף���������ֵ��ÿһ֡6x1
   % x_fea=[ccc(:,1:5),ccc(:,14:18),ccc(:,27:31)];
    x_fea=ccc;
    h_fea=size(x_fea,1);  %֡��
    n_fea=size(x_fea,2);  %ÿһ֡����ֵ����
    l_win=10;        %������10֡
    n_win=h_fea-l_win+1;       %����
    K=n_fea*l_win;  %ÿһ����������ֵ����
    %--������--%
    x_fe=x_fea';
    x_v=x_fe(:);
    x_v=x_v';
    x_win=zeros(K,n_win); 
        n=K;
    for i=1:n_win
        x_win(:,i)=x_v(n_fea*(i-1)+1:1:K+n_fea*(i-1));
    end   
    x_win=x_win';

    %-VAD�������������ʼ����յ�--%
    s_fra=startpoint/128; 
     if(s_fra<=1)
            s=1;
     elseif(s_fra==fix(s_fra))
            s=s_fra-1;    
     else
           s=fix(s_fra);    %������ʼ�����ڵ�֡��
     end
    e_fra=endpoint/128; 
    if(e_fra==fix(e_fra))
        e=e_fra-1;
    else
        e=fix(e_fra);    %������������ڵ�֡��
    end
    h_fea1=h_fea-5;

    %--ȷ�����������ε�λ�ú�SVMѵ�����ı�ǩ--%
    if(e>=h_fea-9)   %��������������һ��
        e_win=h_fea-9;  %������������ڵĴ���
        if(s<=6&&e>=h_fea1)  
         x_lable=ones(n_win,1); 
       elseif(s<=6&&e<h_fea1)
         x_lable(1:e_win-1,:)=ones(e_win-1,1);
         x_lable(e_win:n_win,:)=-ones(1,1);
       elseif(s>6&&e<h_fea1)
         x_lable(1:s-6,:)=-ones(s-6,1);
         x_lable(s-5:e_win-1,:)=ones(e_win-s+5,1);
         x_lable(e_win:n_win,:)=-ones(1,1);
       elseif (s>6&&e>=h_fea1)
         x_lable(1:s-6,:)=-ones(s-6,1);
         x_lable(s-5:n_win,:)=ones(n_win-s+6,1);     
       end       
    else       %��������㲻�����һ��
        e_win=e;
        if(s<=6)  
         x_lable(1:e_win-4,:)=ones(e_win-4,1);
         x_lable(e_win-3:n_win,:)=-ones(n_win-e_win+4,1); 
       elseif(s>6)
         x_lable(1:s-6,:)=-ones(s-6,1);
         x_lable(s-5:e_win-4,:)=ones(e_win-s+2,1);
         x_lable(e_win-3:n_win,:)=-ones(n_win-e_win+4,1);     
       end       
    end   
    %--SVMѵ����:���������ӱ�ǩ--%
    xtrain{idx}=[x_win,x_lable];
    xtrain_s_tt{idx} = xtrain{idx};
    x_win=[];
    x_lable=[]; 
end
end
id = cellfun('length',xtrain_s_tt);
xtrain_s_hh12(id==0)=[];

     