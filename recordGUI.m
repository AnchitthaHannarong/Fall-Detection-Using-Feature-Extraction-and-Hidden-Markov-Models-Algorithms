function varargout = recordGUI(varargin)

% RECORDGUI MATLAB code for recordGUI.fig
%      RECORDGUI, by itself, creates a new RECORDGUI or raises the existing
%      singleton*.
%
%      H = RECORDGUI returns the handle to a new RECORDGUI or the handle to
%      the existing singleton*.
%
%      RECORDGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RECORDGUI.M with the given input arguments.
%
%      RECORDGUI('Property','Value',...) creates a new RECORDGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before recordGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to recordGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help recordGUI

% Last Modified by GUIDE v2.5 04-Jan-2019 14:56:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @recordGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @recordGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
end


% --- Executes just before recordGUI is made visible.
function recordGUI_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
global test;
global testline;

handles.imin = 0;
handles.k = 1;
handles.num = 1;
handles.imax = 0;
test = 0;
testline = 0;

guidata(hObject, handles);
delete(timerfindall);
initializeDisplay(handles);
myGUIdata = guidata(handles.multiScopeMainGUI);


set(myGUIdata.windowViewHandle,'visible','off');
set(myGUIdata.smallViewerPlotHandle,'visible','off');
set(myGUIdata.selectbtn,'enable','off');
set(myGUIdata.deletebtn,'enable','off');
set(myGUIdata.playAllbtn,'enable','off');
set(myGUIdata.playbtn,'enable','off');
set(myGUIdata.stopbtn,'enable','off');
set(myGUIdata.smallViewerAxis,'visible','on');
set(myGUIdata.domaintime,'visible','off');

timerEventInterval = 0.1; % in second
timer50ms = timer('TimerFcn',@synchDrawGUI, 'Period',timerEventInterval,'ExecutionMode','fixedRate', ...
    'userData',handles.multiScopeMainGUI);
myGUIdata.timer50ms = timer50ms;
timerEventIntervalForPlay = 0.10; % in second
timerForPlayer = timer('TimerFcn',@audioTimerServer, 'Period',timerEventIntervalForPlay,'ExecutionMode','fixedRate', ...
    'userData',handles.multiScopeMainGUI);
myGUIdata.timerForPlayer = timerForPlayer;
myGUIdata.player1 = audioplayer(zeros(1000,1),44100);
myGUIdata.player2 = audioplayer(zeros(1000,1),44100);
myGUIdata.player3 = audioplayer(zeros(1000,1),44100);
myGUIdata.player4 = audioplayer(zeros(1000,1),44100);
myGUIdata.player5 = audioplayer(zeros(1000,1),44100);
myGUIdata.maximumNumberOfAudioPlayers = 3;
myGUIdata.smallviewerWidth = 30; % 30 ms is defaule
myGUIdata.samplingFrequency = 44100;
myGUIdata.recordObj1 = audiorecorder(myGUIdata.samplingFrequency,24,1);
myGUIdata.liveData = 'yes';
myGUIdata.pointerMode = 'normal';
myGUIdata.initializeScrubbing = 0;
guidata(handles.multiScopeMainGUI,myGUIdata);
end

function audioTimerServer(obj, event, string_arg)
%global handleForTimer;
handleForTimer = get(obj,'userData');
myGUIdata = guidata(handleForTimer);
% visibleIndex = get(myGUIdata.cursorFringeHandle,'userdata');
% switch myGUIdata.pointerMode
%     case 'dragging'
%         switch get(myGUIdata.withAudioRadioButton,'value')
%             case 1
%                 if ~isplaying(myGUIdata.player1)
%                     play(myGUIdata.player1,[visibleIndex(1) visibleIndex(end)]);
%                     %myGUIdata.player1 = audioplayer(myGUIdata.audioData(visibleIndex),myGUIdata.samplingFrequency);
%                     %play(myGUIdata.player1);
%                 elseif myGUIdata.maximumNumberOfAudioPlayers >= 2 && ~isplaying(myGUIdata.player2)
%                     play(myGUIdata.player2,[visibleIndex(1) visibleIndex(end)]);
%                 elseif myGUIdata.maximumNumberOfAudioPlayers >= 3 && ~isplaying(myGUIdata.player3)
%                     play(myGUIdata.player3,[visibleIndex(1) visibleIndex(end)]);
%                 elseif myGUIdata.maximumNumberOfAudioPlayers >= 4 && ~isplaying(myGUIdata.player4)
%                     play(myGUIdata.player4,[visibleIndex(1) visibleIndex(end)]);
%                 elseif myGUIdata.maximumNumberOfAudioPlayers >= 5 && ~isplaying(myGUIdata.player5)
%                     play(myGUIdata.player5,[visibleIndex(1) visibleIndex(end)]);
%                 end
%         end;
% end;
end

function initializeDisplay(handles)
myGUIdata = guidata(handles.multiScopeMainGUI);
myGUIdata.maxAudioRecorderCount = 200;
myGUIdata.audioRecorderCount = myGUIdata.maxAudioRecorderCount;
myGUIdata.maxLevelIndicator = -100*ones(myGUIdata.maxAudioRecorderCount,1);
myGUIdata.yMax = 1;
axes(myGUIdata.smallViewerAxis);
myGUIdata.windowViewHandle = plot(randn(1000,1),'-g','linewidth',3);
hold on;
myGUIdata.smallViewerPlotHandle = plot(randn(1000,1),'b');
set(myGUIdata.smallViewerAxis,'xtick',[],'ytick',[]);
fs = 44100;
dataLength = round(30/1000*fs);
fftl = 2.0.^ceil(log2(dataLength));
fAxis = (0:fftl-1)/fftl*fs;
w = blackman(dataLength);
pw = 20*log10(abs(fft(randn(dataLength,1).*w,fftl)/sqrt(sum(w.^2))));
myGUIdata.axisType = 'Logarithmic';
myGUIdata.window = w;
myGUIdata.fAxis = fAxis;
switch myGUIdata.axisType
    case 'Linear'
        myGUIdata.largeViewerPlotHandle = plot(fAxis,pw);grid on;
        axis([0 fs/2 [-90 20]]);
    case 'Logarithmic'
        myGUIdata.largeViewerPlotHandle = semilogx(fAxis,pw);grid on;
        axis([10 fs/2 [-90 20]]);
end;


%  myGUIdata.wholeViewerHandle = plot(myGUIdata.maxLevelIndicator);
% axis([0 myGUIdata.maxAudioRecorderCount -100 0]);
% set(myGUIdata.wholeViewerAxis,'xtick',[],'ylim',[-80 0]);grid on;
% axes(myGUIdata.sgramAxis);
% myGUIdata.spectrogramHandle = imagesc(rand(1024,200));axis('xy');
%  hold on;
%  myGUIdata.cursorFringeHandle = plot([180 180 220 220],[-5 1027 1027 -5],'g','linewidth',2);
%  myGUIdata.cursorHandle = plot([200 200],[0 1024],'ws-','linewidth',4);
%  hold off;
%  axis('off')
% % set(myGUIdata.sgramAxis,'visible','off')
%  set(myGUIdata.cursorFringeHandle,'visible','off')
%  set(myGUIdata.cursorFringeHandle,'userdata',[0 1]);
%  set(myGUIdata.cursorHandle,'visible','off','userData',handles.multiScopeMainGUI);
% set(myGUIdata.cursotPositionText,'visible','off');
% myGUIdata.channelMenuString = cellstr(get(myGUIdata.channelPopupMenu,'String'));
% set(myGUIdata.channelPopupMenu,'visible','off');
% set(myGUIdata.withAudioRadioButton,'enable','off');
% set(myGUIdata.withAudioRadioButton,'value',0);
 myGUIdata.player = audioplayer(zeros(1000,1),44100);
 myGUIdata.maximumNumberOfAudioPlayers = 1;
 for ii = 1:myGUIdata.maximumNumberOfAudioPlayers
     myGUIdata.audioPlayerGroup(ii) = audioplayer(zeros(1000,1),44100);
 end;
guidata(handles.multiScopeMainGUI,myGUIdata);
end

function synchDrawGUI(obj, event, string_arg)
%global handleForTimer;
handleForTimer = get(obj,'userData');
myGUIdata = guidata(handleForTimer);
% myGUIdata.smallviewerWidth = get(myGUIdata.radiobutton10ms,'value')*10+ ...
%     get(myGUIdata.radiobutton30ms,'value')*30+ ...
%     get(myGUIdata.radiobutton100ms,'value')*100+ ...
%     get(myGUIdata.radiobutton300ms,'value')*300;\
numberOfSamples = round(myGUIdata.smallviewerWidth*myGUIdata.samplingFrequency/100);
if get(myGUIdata.recordObj1,'TotalSamples') > numberOfSamples
    tmpAudio = getaudiodata(myGUIdata.recordObj1);
    currentPoint = length(tmpAudio);
    xdata = 1:numberOfSamples;
    fs = myGUIdata.samplingFrequency;
    %disp(myGUIdata.audioRecorderCount)
    if length(currentPoint-numberOfSamples+1:currentPoint) > 10
        ydata = tmpAudio(currentPoint-numberOfSamples+1:currentPoint);
        myGUIdata.audioRecorderCount = myGUIdata.audioRecorderCount-1;
        set(myGUIdata.smallViewerPlotHandle,'xdata',xdata,'ydata',ydata);
        if myGUIdata.yMax < max(abs(ydata))
            myGUIdata.yMax = max(abs(ydata));
        else
            myGUIdata.yMax = myGUIdata.yMax*0.8;
        end;
        set(myGUIdata.smallViewerAxis,'xlim',[0 numberOfSamples],'ylim',myGUIdata.yMax*[-1 1]);
        fftl = 2^ceil(log2(numberOfSamples));
        fAxis = (0:fftl-1)/fftl*fs;     
        w = blackman(numberOfSamples);
        windowView = w*myGUIdata.yMax*2-myGUIdata.yMax;
        set(myGUIdata.windowViewHandle,'xdata',xdata,'ydata',windowView);
        pw = 20*log10(abs(fft(ydata.*w,fftl)/sqrt(sum(w.^2))));
        set(myGUIdata.largeViewerPlotHandle,'xdata',fAxis,'ydata',pw);
        myGUIdata.maxLevelIndicator(max(1,myGUIdata.maxAudioRecorderCount-myGUIdata.audioRecorderCount)) ...
            = max(20*log10(abs(ydata)));
%         set(myGUIdata.wholeViewerHandle,'ydata',myGUIdata.maxLevelIndicator);
    else
        disp('overrun!')
    end;
    if myGUIdata.audioRecorderCount < 0
        switch get(myGUIdata.timer50ms,'running')
            case 'on'
                stop(myGUIdata.timer50ms);
        end
        stop(myGUIdata.recordObj1);
        record(myGUIdata.recordObj1);
        myGUIdata.audioRecorderCount = myGUIdata.maxAudioRecorderCount;
        myGUIdata.maxLevelIndicator = 0;
        %    switch get(myGUIdata.timer50ms,'running')
        %        case 'on'
        %            stop(myGUIdata.timer50ms)
        %    end;
        switch get(myGUIdata.timer50ms,'running')
            case 'off'
                start(myGUIdata.timer50ms);
        end
    end;
    guidata(handleForTimer,myGUIdata);
else
    disp(['Recorded data is not enough! Skipping this interruption....at ' datestr(now,30)]);
end;
end

% --- Outputs from this function are returned to the command line.
function varargout = recordGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end


% --- Executes on button press in playAllbtn.
function playAllbtn_Callback(hObject, eventdata, handles)
% hObject    handle to playAllbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global test;
global testline;
global t;
global startt;
myGUIdata = guidata(handles.multiScopeMainGUI);
x = myGUIdata.audioData;
fs = myGUIdata.samplingFrequency;
moan = myGUIdata.audioData(:,1);
end_time = length(moan)/fs;
AxisLim = axis;
myGUIdata.player = audioplayer(x/max(abs(x))*0.9,fs);

isPushed = get(hObject,'Value');
strButton = get(hObject, 'string');
if(testline == 0)
    tic
    t = toc;
    testline = 1;    
    startt =0;
end
L = line([t t],[AxisLim(3) AxisLim(4)],'color','r','Marker','*','MarkerEdgeColor','r','LineStyle','-','linewidth',2);
while t<end_time
    if (testline == 2)
        tic
        t = toc + startt;
        testline = 1;
    end

    if (isPushed)&&(strcmp(strButton, 'PlayAll'))
        resume(myGUIdata.player);
%         axesHandlesToChildObjects = findobj(gca, 'Type', 'line');
        delete(L);
        set(hObject,'String','Pause');
        
        
 
    elseif (isPushed)&&(strcmp(strButton, 'Pause'))
        
        set(hObject,'String','PlayAll');
        drawnow
        pause(myGUIdata.player);
        startt = t;
        testline = 2;
        
    end
    if strcmp(strButton, 'PlayAll')
        axesHandlesToChildObjects = findobj(gca, 'Type', 'line');
        delete(axesHandlesToChildObjects);
        test=1;
        get_graph_Time(handles);
        L = line([t t],[AxisLim(3) AxisLim(4)],'color','r','Marker','*','MarkerEdgeColor','r','LineStyle','-','linewidth',2);
        set(L,'xdata',t*[1 1])
        drawnow
        t = toc+ startt;
    end
    
end

if(t>=end_time)
    delete(L);
    set(hObject,'String','PlayAll');
    testline = 0;
end
guidata(handles.multiScopeMainGUI,myGUIdata);
    
end


% --- Executes on button press in playbtn.
function playbtn_Callback(hObject, eventdata, handles)
% hObject    handle to playbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global imin;
global imax;
myGUIdata = guidata(handles.multiScopeMainGUI);
x = myGUIdata.audioData;
myGUIdata.player = audioplayer(x/max(abs(x))*0.99,44100);

% fs = 44100;

% moan = myGUIdata.audioData(:,1);
% AxisLim = axis;
% L = line([imin imin],[AxisLim(3) AxisLim(4)],'color','r','Marker','*','MarkerEdgeColor','r','LineStyle','-','linewidth',2);
playblocking(myGUIdata.player,[round(myGUIdata.player.SampleRate*imin) round(myGUIdata.player.SampleRate*imax)]);
% tic;
% t = toc;
%     for n = round(imin):round(imax)
%         set(L,'xdata',t*[1+n 1+n]);
%         drawnow;
%         t = toc;
%     end
%     delete(L);
guidata(handles.multiScopeMainGUI,myGUIdata);
end


% --- Executes on button press in recordbtn.
function recordbtn_Callback(hObject, eventdata, handles)
% hObject    handle to recordbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clc;
myGUIdata = guidata(handles.multiScopeMainGUI);
set(myGUIdata.selectbtn,'enable','off');
set(myGUIdata.deletebtn,'enable','off');
set(myGUIdata.windowViewHandle,'visible','on');
set(myGUIdata.smallViewerPlotHandle,'visible','on');
set(myGUIdata.smallViewerAxis,'visible','on');
set(myGUIdata.domaintime,'visible','off');
set(myGUIdata.playAllbtn,'enable','off');

if(~isvalid(myGUIdata.timerForPlayer))
    timerEventInterval = 0.1; % in second
    timer50ms = timer('TimerFcn',@synchDrawGUI, 'Period',timerEventInterval,'ExecutionMode','fixedRate', ...
    'userData',handles.multiScopeMainGUI);
    myGUIdata.timer50ms = timer50ms;
    timerEventIntervalForPlay = 0.10; % in second
    timerForPlayer = timer('TimerFcn',@audioTimerServer, 'Period',timerEventIntervalForPlay,'ExecutionMode','fixedRate', ...
    'userData',handles.multiScopeMainGUI);
    myGUIdata.timerForPlayer = timerForPlayer;
    myGUIdata.player1 = audioplayer(zeros(1000,1),44100);
    myGUIdata.player2 = audioplayer(zeros(1000,1),44100);
    myGUIdata.player3 = audioplayer(zeros(1000,1),44100);
    myGUIdata.player4 = audioplayer(zeros(1000,1),44100);
    myGUIdata.player5 = audioplayer(zeros(1000,1),44100);
    myGUIdata.maximumNumberOfAudioPlayers = 3;
    myGUIdata.smallviewerWidth = 30; % 30 ms is defaule
    myGUIdata.samplingFrequency = 44100;
    myGUIdata.recordObj1 = audiorecorder(myGUIdata.samplingFrequency,24,1);
    myGUIdata.liveData = 'yes';
    myGUIdata.pointerMode = 'normal';
    myGUIdata.initializeScrubbing = 0;
    guidata(handles.multiScopeMainGUI,myGUIdata);
end

switch myGUIdata.liveData
    case 'no'
        myGUIdata.liveData = 'yes';
        myGUIdata.samplingFrequency = 44100;
end;
 stop(myGUIdata.timerForPlayer);
 set(myGUIdata.stopbtn,'enable','on');
switch get(myGUIdata.timer50ms,'running')
    case 'on'
        stop(myGUIdata.timer50ms);
end
myGUIdata.audioRecorderCount = myGUIdata.maxAudioRecorderCount;
myGUIdata.maxLevelIndicator = -100*ones(myGUIdata.maxAudioRecorderCount,1);
myGUIdata.yMax = 1;
record(myGUIdata.recordObj1);
datacursormode off
switch get(myGUIdata.timer50ms,'running')
    case 'off'
        start(myGUIdata.timer50ms);
    case 'on'
    otherwise
        disp('timer is bloken!');
end
guidata(handles.multiScopeMainGUI,myGUIdata);
end



% --- Executes on button press in stopbtn.
function stopbtn_Callback(hObject, eventdata, handles)
clc;
global y;
% hObject    handle to stopbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
myGUIdata = guidata(handles.multiScopeMainGUI);
myGUIdata.audioData = getaudiodata(myGUIdata.recordObj1);

%disp('timer ends')
%set(myGUIdata.startButton,'enable','off');
set(myGUIdata.windowViewHandle,'visible','off');
set(myGUIdata.smallViewerPlotHandle,'visible','off');
set(myGUIdata.largeViewerPlotHandle,'visible','off');
set(myGUIdata.smallViewerAxis,'visible','off');
set(myGUIdata.domaintime,'visible','on');
set(myGUIdata.recordbtn,'enable','on');
set(myGUIdata.stopbtn,'enable','off');
set(myGUIdata.playAllbtn,'enable','on');
% set(myGUIdata.playbtn,'enable','on');
set(myGUIdata.selectbtn,'enable','on');
% set(myGUIdata.deletebtn,'enable','on');
datacursormode off
switch get(myGUIdata.timer50ms,'running')
    case 'on'
        stop(myGUIdata.timer50ms)
    case 'off'
    otherwise
        disp('timer is bloken!');
end;
stop(myGUIdata.recordObj1);
get_graph_Time(handles);
myGUIdata.player1 = audioplayer(myGUIdata.audioData,myGUIdata.samplingFrequency);
myGUIdata.player2 = audioplayer(myGUIdata.audioData,myGUIdata.samplingFrequency);
myGUIdata.player3 = audioplayer(myGUIdata.audioData,myGUIdata.samplingFrequency);
myGUIdata.player4 = audioplayer(myGUIdata.audioData,myGUIdata.samplingFrequency);
myGUIdata.player5 = audioplayer(myGUIdata.audioData,myGUIdata.samplingFrequency);
set(handles.multiScopeMainGUI,'pointer','watch');drawnow
% sgramStructure = stftSpectrogramStructure(myGUIdata.audioData,myGUIdata.samplingFrequency,15,2,'blackman');
% set(myGUIdata.spectrogramHandle,'cdata',max(-80,sgramStructure.dBspectrogram),'visible','on', ...
%     'xdata',sgramStructure.temporalPositions,'ydata',sgramStructure.frequencyAxis);
% set(myGUIdata.sgramAxis,'visible','on', ...
%     'xlim',[sgramStructure.temporalPositions(1) sgramStructure.temporalPositions(end)], ...
%     'ylim',[sgramStructure.frequencyAxis(1) sgramStructure.frequencyAxis(end)]);
% set(myGUIdata.wholeViewerAxis,'visible','off');
set(handles.multiScopeMainGUI,'pointer','arrow');drawnow
% set(myGUIdata.playTFregion,'enable','on');
% set(myGUIdata.scrubbingButton,'enable','on','value',0);
start(myGUIdata.timerForPlayer);
fs = 44100;
y = myGUIdata.audioData;
myGUIdata.player = audioplayer(y/max(abs(y))*0.9,fs);
guidata(handles.multiScopeMainGUI,myGUIdata);

% a = [1 2 3;1 5 1;1 1 1];F
% b = [4 5 1; 7 8 1;1 1 1];
% %c = [1 1 1; 2 2 2; 3 3 3];
% for(i = 1:3)
%     d(:,i)=a(:,i).*b(:,i);
% end
% disp(repmat(d,[2 3 3]));
%disp(triu(d))
end


function get_graph_Time(handles)
clc;
global test;
global y;

myGUIdata = guidata(handles.multiScopeMainGUI);

if(test==0)
    myGUIdata.audioData = getaudiodata(myGUIdata.recordObj1);
    
else
    myGUIdata.audioData = y;
    test =0;

end
    fs = 44100;
    dt = 1/fs;
    moan = myGUIdata.audioData(:,1);
    t = (0:dt:(length(moan)*dt)-dt);

    plot(myGUIdata.domaintime,t,moan);
    xlabel(myGUIdata.domaintime,'Time (seconds)');
    ylabel(myGUIdata.domaintime,'Amplitude');
    title(myGUIdata.domaintime,'Time Domain');
    xlim([0 t(end)]);
    guidata(handles.multiScopeMainGUI,myGUIdata);


% disp(axis)
end


% --- Executes on button press in selectbtn.
function selectbtn_Callback(hObject, eventdata, handles)
% hObject    handle to selectbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global imin;
global imax;
global rec;
delete(rec);
    RECT = getrect;
    AxisLim = axis;
   xmin = RECT(1);
   xmax = RECT(1) + RECT(3);
   ymin = RECT(2);
   ymax = RECT(2) + RECT(4);
   myGUIdata = guidata(handles.multiScopeMainGUI);
   
   signal = myGUIdata.audioData;

   % Set maximum zoom limits to the data edges
   xaxis_limits = get(myGUIdata.smallViewerAxis,'XLim');
   yaxis_limits = get(myGUIdata.smallViewerAxis,'YLim');
   yaxis_limits(2);
   xaxis_limits(2);
   
   if xmin < xaxis_limits(1)
      xmin = xaxis_limits(1);
   end
   
   if xmax > xaxis_limits(2)
      xmax = xaxis_limits(2);
      
   end

   if ymin < yaxis_limits(1)
      ymin = yaxis_limits(1);
   end
   
   if ymax > yaxis_limits(2)
      ymax = yaxis_limits(2);
       yaxis_limits(2);
   end
   % if the choosen zoom range is acceptable...
   if ~((ymin > ymax) | (xmin > xmax))
      % zoom in on the frequency data by adjusting the xaxis
      % limits to be the same as those of the time data
      % define the zoomed in data (for playback purposes)
%       imin = round(xmin*8000)+1;
%       imax = round(xmax*8000)+1;
        imin = xmin;
        imax = xmax;
   end
%     if length(signal(imin:imax) )~= 0
% %       sound(signal(imin:imax),44100);
%         imin = xmin;
%         imax = xmax;
%     end
%     disp(AxisLim)
    rec = rectangle('Position',[xmin,AxisLim(3),xmax-xmin,AxisLim(4)-AxisLim(3)],'EdgeColor','g','LineWidth',2)
    set(myGUIdata.playbtn,'enable','on');
    set(myGUIdata.deletebtn,'enable','on');
    guidata(handles.multiScopeMainGUI,myGUIdata);
end


% --- Executes on button press in deletebtn.
function deletebtn_Callback(hObject, eventdata, handles)
% hObject    handle to deletebtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global imin;
global imax;
global y;
 % if the choosen zoom range is acceptable...
 myGUIdata = guidata(handles.multiScopeMainGUI);
%  myGUIdata.audioData = getaudiodata(myGUIdata.recordObj1);
 button = questdlg('DO YOU WANT TO DELETE','Delete');
 switch button
     case {'Yes'}
         
         myGUIdata.audioData(round(myGUIdata.player.SampleRate*imin):round(myGUIdata.player.SampleRate*imax))=[];
         samp_len = length(myGUIdata.audioData)/44100;
         delta_t = 1/44100;
         t = 0:delta_t:(samp_len-delta_t);
%          disp(t((length(myGUIdata.audioData)-1)));
         % display the signal
         plot(myGUIdata.domaintime,t,myGUIdata.audioData), xlabel('Time (seconds)'), ylabel('Amplitude')
%          myGUIdata.domaintime([0 round(t((length(myGUIdata.audioData)-1))) -1 1 ]);
       
 end    
 set(myGUIdata.deletebtn,'enable','off');
 set(myGUIdata.playbtn,'enable','off');
myGUIdata.player = audioplayer(myGUIdata.audioData/max(abs(myGUIdata.audioData))*0.99,44100);
 y = myGUIdata.audioData;
 guidata(handles.multiScopeMainGUI,myGUIdata);
end


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end

% --------------------------------------------------------------------
function Graph_Callback(hObject, ~, handles)
% hObject    handle to Graph (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end

% --------------------------------------------------------------------
function LPC_Callback(hObject, eventdata, handles)
% hObject    handle to LPC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA
setappdata(handles.multiScopeMainGUI,'x',0);
vtlDisplay;
end


% --------------------------------------------------------------------
function Save_Callback(hObject, eventdata, handles)
% hObject    handle to Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
myGUIdata = guidata(handles.multiScopeMainGUI);
% myGUIdata.audioData = getaudiodata(myGUIdata.recordObj1);
Fs = 44100;      
filter = {'*.wav';'*.*'};
[file, path] = uiputfile(filter);
if isequal(file,0) || isequal(path,0)
   disp('User clicked Cancel.')
else
   disp(['User selected ',fullfile(path,file),...
         ' and then clicked Save.'])
     audiowrite(fullfile(path,file),myGUIdata.audioData,Fs);
end
end


% --------------------------------------------------------------------
function Load_Callback(hObject, eventdata, handles)
% hObject    handle to Load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clc;

global y;
global test;
myGUIdata = guidata(handles.multiScopeMainGUI);
% myGUIdata.audioData = getaudiodata(myGUIdata.recordObj1);
[filename,pathname] = uigetfile('*.wav');
if isequal(filename,0) || isequal(pathname,0)
    disp('User pressed cancel');
else
    disp(['User selected ', fullfile(pathname, filename)]);
    [y1,fs] = audioread([pathname filename]);
    
end
y = y1;
test = 1;
get_graph_Time(handles);
set(myGUIdata.smallViewerAxis,'visible','off');
set(myGUIdata.domaintime,'visible','on');
set(myGUIdata.recordbtn,'enable','on');
set(myGUIdata.stopbtn,'enable','off');
set(myGUIdata.playAllbtn,'enable','on');
set(myGUIdata.selectbtn,'enable','on');
myGUIdata.audioData = y;
x = myGUIdata.audioData;
myGUIdata.player = audioplayer(x/max(abs(x))*0.9,fs);
guidata(handles.multiScopeMainGUI,myGUIdata);

end


% --------------------------------------------------------------------
function Spectrogram_Callback(hObject, eventdata, handles)
% hObject    handle to Spectrogram (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setappdata(handles.multiScopeMainGUI,'x',0);
realtimeSpectrogramV3;
end


% --- Executes on button press in trainAll.
function trainAll_Callback(hObject, eventdata, handles)
% hObject    handle to trainAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clc
clear
close all

[audio_signals word_labels] = load_audio_from_folder('audio');

display(sprintf('Loaded a total of %d audio signals for the following words:', length(audio_signals)))
display(unique(word_labels))

vocabulary = Vocabulary;
vocabulary.train(audio_signals', word_labels', audio_signals');
disp('Finish!!!');
save audiosignals audio_signals
save wordlabels word_labels
save vocabulary vocabulary
end
