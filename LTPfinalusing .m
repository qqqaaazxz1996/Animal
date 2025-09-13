
%---- Data Reading ----
 [fname,pname] = uigetfile('*.plx'); 
 file = [pname,fname];
 channal='请输入分析的通道';
 channal= char(inputdlg(channal));
 eventnum='请输入分析参考的事件';
 eventnum= char(inputdlg(eventnum));
 [adfreq, n, ts, fn, ad] = plx_ad(file, channal);
 [n, events, sv] = plx_event_ts(file,eventnum);
 %Event = PL2EventTs(file,eventnum); for pl2-format file
 pre=0.01;
 post=0.02;                                                                                                                                                    
 t=length(ad)/adfreq;
 time_step = 1/adfreq;
 timestamp = ts:time_step:t;
 data=filter(WB,ad);
 %data=ad;
 %检查一下event的时间点！！！
 norm = zeros(1200,length(events));

%---- Extract signals around events ---- 
for i=1:length(events)
aligneddata{i}=data(find(timestamp<events(i)+post & timestamp>(events(i)-pre)));
nor_data{i}=aligneddata{i}-mean(aligneddata{i}(1:post/time_step));
if length(nor_data{i})==1200
norm(:,i)=nor_data{i};
else
norm(1:1199,i) = nor_data{i}(1:1199);
end
plot(nor_data{i},'k')
set(gca,'YLim',[-20000 20000]);
hold on;
end

 average_baselinea=mean(norm,2);
 plot(average_baselinea,'g','LineWidth',2);
 hold on

%---- Exclude artifacts from raw data ----
n=1;
for i=1:length(norm(1,:))
plot(norm(:,i),'k')
a='yes or no';
a=str2num(char(inputdlg(a)));
if a==1
new(1:1200,n)=norm(:,i);
n=n+1;
end
end

%---- Detect markers ----
norm1=new;%%**注意修改 
 average_baseline=mean(norm1,2);
 plot(average_baseline,'b','LineWidth',2);
norm=norm1;
for m=1:floor(size(norm,2)/4)
    figure
    %set(gca, 'Position', [100, 100, 500, 500])
    
    for n=((m-1)*4+1):m*4
        plot(norm(:,n),'k')
        hold on
        datax(:,(n-(m-1)*4))=norm(:,n);
    end
    
   average_data=mean(datax,2);
   plot(average_data,'r','LineWidth',2);
    a=0.004;
    b=0.009;
        part=average_data((pre+a)/time_step:(pre+b)/time_step);

        [Minvalue,IndMin]=min(part);
        IndMax=find(diff(sign(diff(part)))~=0)+1;
        Ind=find(diff(sign(diff(diff(part))))~=0)+2;
        hold on;
        x=(pre+a)/time_step;
        plot(IndMin+x,part(IndMin),'r^')
        plot(IndMax+x,part(IndMax),'k*')
        plot(Ind+x,part(Ind),'b^')
        display(IndMax);
        display(IndMin);
        display(Ind);
end

%---- Data Processing ----
for m=1:floor(size(norm,2)/4)
    figure
    for n=((m-1)*4+1):m*4
        plot(norm(:,n),'k')
        hold on
        datax(:,(n-(m-1)*4))=norm(:,n);
    end
   average_data=mean(datax,2);
   plot(average_data,'r','LineWidth',2);
     a=0.0035;%User-defined
        b=0.009;%User-defined
        part=average_data((pre+a)/time_step:(pre+b)/time_step);
       % IndMin=find(diff(sign(diff(part)))>0)+1;%获得局部最小值的位置
        [Minvalue,IndMin]=min(part);
        IndMax=find(diff(sign(diff(part)))~=0)+1;%获得局部最大值的位置
        Ind=find(diff(sign(diff(diff(part))))~=0)+2;
        hold on;
        x=(pre+a)/time_step;
        plot(IndMin+x,part(IndMin),'r^')
        plot(IndMax+x,part(IndMax),'k*')
         plot(Ind+x,part(Ind),'b^')
        display(IndMax);
        display(Ind);
        spot1='第一个点';
        spot1=str2num(char(inputdlg(spot1)));
        spot2='第二个点';
        spot2=str2num(char(inputdlg(spot2)));
        spot3='第三个点';
        spot3=str2num(char(inputdlg(spot3)));
        %spot3=max(IndMin);
        y1=part(spot1);
        y2=part(spot2);
        y3=part(spot3);
        y4=y2-(y2-y3)*0.1;
        y5=y2-(y2-y3)*0.9;
        part1=part(spot2:spot3);
        c=find(part1<y4& part1>y4-2000);
        e=min(c);
        d=find(part1<y5+2000& part1>y5);
        f=max(d);
        k(m)=(y4-y5)/((f-e)*time_step)/y1;
        L(m)=(y2-y3)/((spot2-spot3)*time_step)/y1;
        MK(m)=(y4-y5)/((f-e)*time_step);
        LK(m)=(y2-y3)/((spot2-spot3)*time_step);
        y(m)=y1-average_data(51);
        A(m)=f-e;
        B(m)=spot2-spot3;
        
end
p=[k' L' LK' MK' y' A' B'];
 
 clc
 clear all
 close all
 
 


   

   
