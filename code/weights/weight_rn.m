% compute weights of the linear SVM, regular and permuted class labels; for
% data with removed noise correlations

close all
clear all
clc
format long

%%%%%%%%%%%

place=1;                                                                    % 0 for the server, 1 for the office computer
saveres=1; 
showfig=1;

period=2;
type=1;                                                                     % 1~ regular model, 2~ permuted weights

ba=1;                                                                       % brain area: 1 for V1, 2 for V4
window=3;                                                                                                                                            

%%

if type==2
    nperm=1000;
end

start_vec=[500,500,750] - 300*(period==1);                                    % beginning of the time window 
start=start_vec(window);
Kvec=[500,250,250];
K=Kvec(window);
display([start,start+K],'window')

Cvec=[0.0012,0.00135,0.0015,0.002,0.005,0.01, 0.1,0.5];                         % range of tested regularization parameters
nfold=10;                                                                    % number of folds for computing the regularization param

namea={'V1','V4'};
namep={'target','test'};
namet={'regular','permuted'};
namew={'','first_half_','second_half_'};

%%

addpath('/home/veronika/synced/struct_result/input/')
if place==1
    addpath('/home/veronika/Dropbox/struct_pop/code/function/')
else
    addpath('/home/veronika/struct_pop/code/function/')
end

loadname=['spike_train_',namea{ba},'_',namep{period},'.mat'];                  % load spike trains
load(loadname);
nbses=size(spiketrain,1);
sc=cellfun(@(x) sum(x(:,:,start:start+K-1),3),spiketrain,'UniformOutput', false);

display(['compute decoding weights ' namea{ba},' ',namep{period},' ', namet{type},' ',namew{window}])

%% compute decoding weights

if type==1
    weight_all=cell(nbses,1);
else
    weight_perm_all=cell(nbses,1);
end

tic
parfor sess=1:nbses
    
    warning('off','all');
    
    s1=sc{sess,1};
    s2=sc{sess,2};
    N=size(s1,2);
    
    count=cell(2,1);
    for j=1:N
        count{1}(:,j) = s1(randperm(size(s1,1)),j);
        count{2}(:,j) = s2(randperm(size(s2,1)),j);
    end
    
    if type==1    
        weight_all{sess} = (compute_svmw_fun(count,nfold,Cvec))';
    else
        
        wp=zeros(N,nperm);
        for perm=1:nperm
            
            count_all=cat(1,count{1},count{2});
            rp=randperm(size(count_all,1));
            count_allp=count_all(rp,:);
            count{1}=count_allp(1:size(count{1},1),:);
            count{2}=count_allp(size(count{1},1)+1:end,:);
            wp(:,perm) = compute_svmw_fun(count,nfold,Cvec);
        
        end
        
        weight_perm_all{sess}=wp; 
                             
    end
    
end
toc

%% save results

if saveres==1
    
    if type==1
        address='/home/veronika/synced/struct_result/weights/weights_rn/';
        filename=['svmw_rn_', namew{window},namea{ba},namep{period}];
        save([address, filename],'weight_all')
        
    else
        address='/home/veronika/synced/struct_result/weights/weights_permuted/';
        filename=['svmw_rnp_', namew{window},namea{ba},namep{period}];
        save([address, filename],'weight_perm_all')
        
    end
end
%%
if showfig==1
    
    if type==2
        wpmat=(cell2mat(weight_perm_all'));
        
        figure()
        subplot(2,1,1)
        hold on
        boxplot(wpmat)
        plot(mean(wpmat,1),'m')
        plot(zeros(size(wpmat,2),1))
        xlabel('neuron index')
        
        subplot(2,1,2)
        hold on
        boxplot(wpmat')
        plot(mean(wpmat,2))
        plot(zeros(size(wpmat,1),1))
        xlabel('permutation index')
        
        mean_mean=mean(mean(wpmat));
    else
        w=cell2mat(weight_all);
        figure()
        
        subplot(2,1,1)
        plot(w)
        
        subplot(2,1,2)
        ksdensity(w)
        
    end
end



