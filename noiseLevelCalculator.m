% �������, ����������� ��������� ���������� ������ ����� � ������������� ������� � �������� ��������� ������  

function [levels, f1, f2, Tavg] = noiseLevelCalculator(inputFileName,dataPa,Fs,lowerFreq,upperFreq,Tavg,plotFlag,outputFolder,plotLowFreq,plotUpFreq)

% ������� ���������:
% inputFileName - ������ ���� � ����� ��� ���������
% lowerFreq � upperFreq - ������� ������ ������ ��� ���������
% Tavg - ����� ����������
% plotFlag - ����� 1 - �������� �������������
% ����� �������:
% levels - ������ ����� �� ��������� ����� ������������� Tavg

% ���������� �������� ����� � ��� ������� �������������
%[data,Fs] = audioread(inputFileName);
data = dataPa;
outputFileName = strcat(outputFolder,'\','spectrogram_',erase(inputFileName,'.wav'),'.png');

% ���������� ������������� (��� �������������)
if plotFlag == 'savespec'
    spectrogram(data,rectwin(Fs),0,1:Fs/2,Fs) 
    h = colorbar;
    h.Label.String = '������ ����,  ��(��^2/��)';
    xlim([plotLowFreq/1000 plotUpFreq/1000])
    title(['������������� ������ ' inputFileName],'Interpreter','none')
    xlabel('�������, ���')
    ylabel('�����, ������')
    print(gcf,outputFileName,'-dpng','-r800'); 
   % saveas(gcf,outputFileName)
end 

% ��������� ������� ������������ ��������� �������� �� �������� ������� � ������ ���� ������ ������� ������������� (df = 1 ��, dt = 1c), ���
% ����������, ������������� �� �������� �� �������� ������� ������������� 
[~,f,t,ps] = spectrogram(data,Fs,0, 1:Fs/2 ,Fs);  
ps = ps*2;                                          % ����� �� ������ �������, ��������� ���������� �� 2

% save(replace(outputFileName,'png','mat'),'ps');

if lowerFreq<min(f) || lowerFreq>max(f)
    disp(['������ ������� ������� ������ ���� ������ �� ', num2str(min(f)),' �� �� ',num2str(max(f)),' ��'])
    return
end
if upperFreq<min(f) || upperFreq>max(f)
    disp(['������ ������� ������� ������ ���� ������ �� ', num2str(min(f)),' �� �� ',num2str(max(f)),' ��'])
    return
end

%  ���������� ��������� �� �������� � �������
df = (max(f) - min(f))/ (length(f)-1);      % ���������� ���� �� �������
% ���������� ��������� � ��������� ��������� �� �������
freqStart  = find( abs(f-lowerFreq) < df/2);
freqFinish = find( abs(f-upperFreq) < df/2);
f1 = f(freqStart);
f2 = f(freqFinish);

if abs(f-lowerFreq) ~= 0
    disp(['������ ������� ������� ���� ��������������� �� ���������� �������� ������������� �����: ',num2str(f1),' ��'])
end
if abs(f-upperFreq) ~= 0
    disp(['������� ������� ������� ���� ��������������� �� ���������� �������� ������������� �����: ',num2str(f2),' ��'])
end

dt = (max(t) - min(t))/ (length(t)-1); % ���������� ���� �� �������

% �������� � ���������� (��� �������������) ������������ ����. 
% ����� ��� �������� �� ����� ����� ��������� �� �������
if mod(size(ps,2),Tavg) ~= 0
    Tavg = round(Tavg);
    disp(['����� ���������� �� ������������ � ����� ����� ���������, ��� ���� ��������� �� ',num2str(Tavg),' �'])
end

numOfWindows = floor(size(ps,2)/Tavg); % ����� ����
levels = zeros(1,numOfWindows);        % ��������������� ������� �������� ������ ����


  for k = 1:numOfWindows                                                       % ���� �� ���� �����
    timeStart     = 1 + (k-1)*(Tavg/dt);                                       % ������ �������� ����, � ��������
    timeFinish    = k*(Tavg/dt);                                               % ����� �������� ����, � ��������
    currentWindow = (ps( freqStart:freqFinish , timeStart:timeFinish ));       % ������� ���� �� ������� � �������
    energy        = sum(sum(currentWindow));                                   % ������� � ������� ����                                    
    power         = energy/(Tavg/dt);                                          % �������� � ������� ����                             
    levels(k)     = sqrt(power);                                               % ���������� ��������� � ������ ����
  end
    
end
