% plot balanced accuracy in sessions and average across sessions

format long

clear all
close all
clc

savefig=0;
period=2;

type=2;                                            % 1 for plus, 2 for minus

namep={'target','test'};
namea={'V1','V4'};
namet={'plus','minus'};

savefile='/home/veronika/Dropbox/struct_pop/figure/sign/svm/';

figname=[namet{type},'_',namep{period}];
pos_vec=[0,0,12,9]; 

lw=1.0;     % linewidth
ms=6;       % markersize
fs=10;      % fontsize
lwa=1;

blue=[0,0.48,0.74];
gray=[0.7,0.7,0.7];
col={'r',blue};

%% load the results of the linear SVM

addpath('/home/veronika/synced/struct_result/classification/svm_sign/')
addpath('/home/veronika/synced/struct_result/classification/svm_regular/')

accsign=cell(2,1);
accp=cell(2,1);

namevar={'bac_minus','bac_plus'};
for ba=1:2
        
    loadname=['svm_sign_',namea{ba},namep{period},'.mat'];
    load(loadname,namevar{type});
    
    accsign{ba}=cellfun(@mean, eval(namevar{type}));  % reversed names while computing :(
 
    loadname=['svm_regular_',namea{ba},namep{period},'.mat'];
    load(loadname,'bac_allp');
    
    accp{ba}=bac_allp;
    
end

%%
sm=cellfun(@(x) nanmean(x),accsign);                
smp=cellfun(@(x) squeeze(nanmean(x)),accp,'UniformOutput',false);
display(sm)

%% test with permutation test: BAC is significantly bigger than chance

pval=zeros(2,1);
for ba=1:2
    
    x=sm(ba);
    x0=smp{ba};
    pval(ba)=sum(x<x0)./length(x0);
    
end
hyp=pval<(0.05/numel(pval));
display(pval,'p-value linear SVM')

%% plot sessions and average


yt=0.5:0.1:0.7; % y tick
xt=[1,7,14;1,4,8];

pltidx={[1,2],[4,5]};

H=figure('name',figname,'visible','on');
for ba=1:2
    
    y=squeeze(accsign{ba});         % regular
    
    [~,order]=sort(y);          % sort test results
    order=flip(order);
    y=y(order);
    y0=accp{ba};
    
    subplot(2,3,pltidx{ba})
    hold on
    plot(1:length(y),y,'x','color',col{type},'markersize',ms,'Linewidth',lw+1);
    bs=boxplot(y0','colors',[0.5,0.5,0.5]);
    plot(0:length(x)+1,ones(length(x)+2,1).*0.5,'--','color',[0.5,0.5,0.5,0.5],'linewidth',lw)
    hold off
    
    axis([0,length(y)+1,0.4,0.8])
    box off
    grid on
    
    hout=findobj(gca,'tag','Outliers');
    delete(hout)
    
    set(gca,'XTick',xt(ba,:))
    set(gca,'XTickLabel',xt(ba,:),'FontName','Arial','fontsize',fs)
    
    set(gca,'YTick',yt)
    set(gca,'YTickLabel',yt,'fontsize',fs,'FontName','Arial')
    
    if ba==1
        text(0.5,0.82,namet{type},'units','normalized','color',col{type},'fontsize',fs,'FontName','Arial')
        text(0.5,0.69,'permuted label','units','normalized','color',[0.5,0.5,0.5,0.5],'fontsize',fs,'FontName','Arial')
    end
    
    set(gca,'LineWidth',1.0,'TickLength',[0.025 0.025]);
    
end

yt=[0.50,0.55];
ylimit=[0.47,0.60];
xh=0.58;

ym=0.57;
dy=0.005;

for ba=1:2
     
    x=sm(ba,:);
    x0=cell2mat(smp(1,:)')';
    
    subplot(2,3,ba*3)
    hold on
    
    bs=boxplot(x0,'colors',[0.5,0.5,0.5]);
    set(bs,{'linew'},{1})
    plot(1,x,'x','color',col{type},'markersize',ms,'Linewidth',lw+1);
    plot(0:3,ones(4,1).*0.5,'--','color',[0.5,0.5,0.5],'linewidth',lw)
   
    hold off
    
    text(1.03,0.5,namea{ba},'units','normalized','fontsize',fs,'FontName','Arial')
  
    ylim(ylimit)
    xlim([0.5,1.5])
    box off
    grid on
    
    hout=findobj(gca,'tag','Outliers');
    delete(hout)
    
    set(gca,'XTick',1)
    set(gca,'YTick',yt)
    set(gca,'YTickLabel',[])
    set(gca,'XTickLabel', [])
    
    set(gca,'YTickLabel',yt,'fontsize',fs)
    
    set(gca,'LineWidth',1.0,'TickLength',[0.025 0.025]);
   
end

axes

h1 = xlabel ('Session index (sorted)','Position',[0.3,-0.07],'FontName','Arial','fontsize',fs);
h2 = ylabel ('Balanced accuracy','units','normalized','Position',[-0.1,0.5,0],'FontName','Arial','fontsize',fs);
set(gca,'Visible','off')
set(h2,'visible','on')
set(h1,'visible','on')

set(H, 'Units','centimeters', 'Position', pos_vec) 
set(H,'PaperPositionMode','Auto','PaperUnits', 'centimeters','PaperSize',[pos_vec(3), pos_vec(4)]) 

if savefig==1
    saveas(H,[savefile,figname],'pdf');
end

