clear;
dictionary=675;
tic

% Find the most frequent words
words=[];
fid=fopen('102.txt');
totalwords=0;
while 1
    tline=[lower(fgetl(fid))];
    if ~ischar(tline), break, end
    if length(regexp(tline,'\:'))==4
        line=regexp(tline,'(\w+).*?','tokens');
        t=str2num(line{1}{1})*60*60+str2num(line{2}{1})*60+str2num(line{3}{1});
        disp(t)
    else
        tline=[tline ' '];
        tline=regexprep(tline, '(\.|\;|\!|\?|\,|\-)', ' sb ');
        tline=regexprep(tline, '\[br\]', ' ');
        tline=regexprep(tline, '\''', ' ');
        tline=regexprep(tline, '\"', ' ');
        line=regexp(tline,'(\w+).*?','tokens');
        disp(tline)

        for i=1:length(line)
            match=strmatch(line{i}, words, 'exact');
            if match>0
                count(match)=count(match)+1;
            else
                words = [words line{i}];
                count(length(words))=1;
            end;
            totalwords=totalwords+1;
        end;
    end %4
end % while 1
fclose(fid);
[Y,In]=sortrows(count');
% Reduce it to the dictionary limit
words=words(In(length(In)-(dictionary-2):length(In)));
words{dictionary}='blabla';

% OK do it again
fid=fopen('102.txt');
j=1;
while 1
    tline=lower(fgetl(fid));
    if ~ischar(tline), break, end
    if length(regexp(tline,'\:'))==4
        line=regexp(tline,'(\w+).*?','tokens');
        t=str2num(line{1}{1})*60*60+str2num(line{2}{1})*60+str2num(line{3}{1});
    else
        tline=[tline ' '];
        tline=regexprep(tline, '(\.|\;|\!|\?|\,|\-)', ' sb ');
        tline=regexprep(tline, '\[br\]', ' ');
        tline=regexprep(tline, '\''', ' ');
        tline=regexprep(tline, '\"', ' ');
        line=regexp(tline,'(\w+).*?','tokens');
        for i=1:length(line)
            if isempty(strmatch(line{i}, words, 'exact'))
                corpus(j)=dictionary;
            else
                corpus(j)=strmatch(line{i}, words, 'exact');
            end;
            disp([line{i} words(corpus(j))])
            tt(j)=t-146;
            j=j+1;
        end;
    end; %4
end % while 1
fclose(fid);
load sp
m(1:5,:,:,:)=[];
alfa=ceil(sqrt(dictionary));

for i=1:length(corpus)
    corpus2(i*2-1)=floor(corpus(i)/alfa);
    corpus2(i*2  )=  mod(corpus(i),alfa);
end;

tt=ceil(filter(ones(1,20)/20,1,tt));
newr=zeros(size(r,1),length(corpus2));
for i=1:length(corpus2)
    newr(:,i)=squeeze(r(:,tt(ceil(i/2)),1));
    newm(i,:,:,:)=m(tt(ceil(i/2)),:,:,:);
    disp(i)
end;

for i=1:size(newr,2)
    rr(:,i)=(squeeze(newr(:,i,1))-squeeze(min(newr(:,i,1))))./squeeze(max(newr(:,i,1)));
end;
pause

[m ind]=min(rr(1:alfa,:))
for i=1:2:length(corpus2)
    subplot(2,1,1)
    image(squeeze(newm(i,:,:,:)))
    subplot(2,1,2)
    image(squeeze(f(ind(i),:,:,:)))
    title(words(corpus2(i)*alfa+corpus2(i+1)))
    pause
    test((1+i)/2)=corpus2(i)*alfa+corpus2(i+1);
end

w=100;
res=alfa;
rec=ones(size(newr,1),w,2);
control=ones(w,2);
for j=2922:size(newr,1)
    subplot(2,2,1)
    image(squeeze(f(j,:,:,:)));
    y=squeeze(newr(j,w/2+1:size(newr,2)-w/2))';
    upper=mean(y)+sqrt(var(y));
    lower=mean(y)-sqrt(var(y));
    y(find(y>upper))=upper;
    y(find(y<lower))=lower;
    y=y-min(y);
    y=y/max(y);

    p=randperm(length(y));
    for k=1:length(p)
        yc(k)=y(p(k));
    end;

    p=randperm(length(corpus));
    for k=1:length(p)
        corpusc(k)=corpus(p(k));
    end;

    pw=5; % permutation window
    corpusp=corpus;

    for i=1:length(corpusp)-pw-1
        p=randperm(pw);
        temp=corpus(i:i+pw-1);
        for k=1:pw
            temp(k)=corpusp(i+p(k)-1);
        end;
        corpus(i:i+pw-1)=temp;
    end;

    st=1;
    for i=1:st:w

        x=squeeze(corpus2(i:length(corpus2)-w+i-1))';
        xc=squeeze(corpusc(i:length(corpus)-w+i-1))';
        yx=squeeze(newr(j,i:length(newr)-w+i-1))';

        [t_i2j, t_j2i] = csl_schreiber(x,y,res);
        rec(j,i,1:2)=squeeze(rec(j,i,1:2))+[t_i2j, t_j2i]';
        subplot(2,2,2)
        [t_i2j, t_j2i] = csl_schreiber(xc,y,res);
        rec(i,3:4)=rec(i,3:4)+[t_i2j, t_j2i];
        [t_i2j, t_j2i] = csl_schreiber(x,yc',res);
        rec(i,5:6)=rec(i,5:6)+[t_i2j, t_j2i];
        [t_i2j, t_j2i] = csl_schreiber(xc,yc',res);
        rec(i,7:8)=rec(i,7:8)+[t_i2j, t_j2i];
        [t_i2j, t_j2i] = csl_schreiber(y,yx,res);
        control(i,1:2)=control(i,1:2)+[t_i2j, t_j2i];
        x->y - green op top
    end;
    
    lan=squeeze(mean(rec(:,:,1),1));
    vis=squeeze(mean(rec(:,:,2),1));
    lan=reshape(lan,2,50);
    lan=mean(lan);
    lan=reshape(repmat(lan,2,1),100,1);
    lan=lan./mean(lan);
    vis=vis./mean(vis);
    lan=lan'./mean([lan vis']');
    vis=vis./mean([lan' vis']');
    plot(lan,'b')
    hold on
    plot(vis,'r')
    hold off
    title(num2str(j))
    drawnow

end;
