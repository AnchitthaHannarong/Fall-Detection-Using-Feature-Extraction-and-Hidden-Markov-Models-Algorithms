function varargout = testrealtimeGUI(varargin)
global rec;
% TESTREALTIMEGUI MATLAB code for testrealtimeGUI.fig
%      TESTREALTIMEGUI, by itself, creates a new TESTREALTIMEGUI or raises the existing
%      singleton*.
%
%      H = TESTREALTIMEGUI returns the handle to a new TESTREALTIMEGUI or the handle to
%      the existing singleton*.
%
%      TESTREALTIMEGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TESTREALTIMEGUI.M with the given input arguments.
%
%      TESTREALTIMEGUI('Property','Value',...) creates a new TESTREALTIMEGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before testrealtimeGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to testrealtimeGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help testrealtimeGUI

% Last Modified by GUIDE v2.5 09-Jan-2019 18:51:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @testrealtimeGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @testrealtimeGUI_OutputFcn, ...
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


% --- Executes just before testrealtimeGUI is made visible.
function testrealtimeGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to testrealtimeGUI (see VARARGIN)

% Choose default command line output for testrealtimeGUI
global test;
global detectfall;
global count;
global testline;



handles.output = hObject;

% Update handles structure
handles.imin = 0;
handles.k = 1;
handles.num = 1;
handles.imax = 0;
test = 0;
testline = 0;
detectfall = '';

count = 1;

guidata(hObject, handles);


delete(timerfindall);
initializeDisplay(handles);
myGUIdata = guidata(handles.multiScopeMainGUI);

set(myGUIdata.windowViewHandle,'visible','off');
set(myGUIdata.smallViewerPlotHandle,'visible','off');
set(myGUIdata.testSegment,'enable','off');
set(myGUIdata.test,'enable','off');
set(myGUIdata.selectbtn,'enable','off');
set(myGUIdata.deletebtn,'enable','off');
set(myGUIdata.playAllbtn,'enable','off');
set(myGUIdata.playbtn,'enable','off');


set(myGUIdata.stopbtn,'enable','off');
set(myGUIdata.smallViewerAxis,'visible','on');
set(myGUIdata.domaintime,'visible','off');

timerEventInterval = 0.5; % in second
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
myGUIdata.smallviewerWidth = 100; % 30 ms is defaule
myGUIdata.samplingFrequency = 44100;
myGUIdata.recordObj1 = audiorecorder(myGUIdata.samplingFrequency,24,1);
myGUIdata.liveData = 'yes';
myGUIdata.pointerMode = 'normal';
myGUIdata.initializeScrubbing = 0;

guidata(handles.multiScopeMainGUI,myGUIdata);
end

function audioTimerServer(obj, event, string_arg)
handleForTimer = get(obj,'userData');
myGUIdata = guidata(handleForTimer);

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
 myGUIdata.player = audioplayer(zeros(1000,1),44100);
 myGUIdata.maximumNumberOfAudioPlayers = 1;
 for ii = 1:myGUIdata.maximumNumberOfAudioPlayers
     myGUIdata.audioPlayerGroup(ii) = audioplayer(zeros(1000,1),44100);
 end;
guidata(handles.multiScopeMainGUI,myGUIdata);
end

function synchDrawGUI(obj, event, string_arg)
global detectfall
global count

handleForTimer = get(obj,'userData');
myGUIdata = guidata(handleForTimer);
if ((strcmp(detectfall,'fall'))||(strcmp(detectfall,'fallbath')))
    disp('FALL DETECTION!!!')
    switch get(myGUIdata.timer50ms,'running')
         case 'on'
             stop(myGUIdata.timer50ms);
    end
    stop(myGUIdata.recordObj1);
    count = 1;
    guidata(handleForTimer,myGUIdata);
else
    handleForTimer = get(obj,'userData');
    myGUIdata = guidata(handleForTimer);
    numberOfSamples = round(myGUIdata.smallviewerWidth*myGUIdata.samplingFrequency/100);
    if get(myGUIdata.recordObj1,'TotalSamples') > numberOfSamples
        tmpAudio = getaudiodata(myGUIdata.recordObj1);
        currentPoint = length(tmpAudio);
        fs = myGUIdata.samplingFrequency;
        dt = 1/fs;
        t = (0:dt:(length(tmpAudio)*dt)-dt);
        xdata = 1:numberOfSamples;
        
        
        if length(currentPoint-numberOfSamples+1:currentPoint) > 10
            ydata = tmpAudio(currentPoint-numberOfSamples+1:currentPoint);
            myGUIdata.audioRecorderCount = myGUIdata.audioRecorderCount-1;
            set(myGUIdata.smallViewerPlotHandle,'xdata',xdata,'ydata',ydata);
            if myGUIdata.yMax < max(abs(ydata))
                myGUIdata.yMax = max(abs(ydata));
            else
                myGUIdata.yMax = myGUIdata.yMax*0.8;
            end;

            load('vocabulary.mat');
            predicted_word_labels = vocabulary.test(ydata);
%             detectfall = predicted_word_labels;
%             if ((strcmp(detectfall,'fall'))||(strcmp(detectfall,'fallbath')))
%                 figure
%              plot(xdata,ydata);
%              title('fall')
%             else
%                 figure
%              plot(xdata,ydata);
%              title('nonfall')
%             end
             count = count + 1;
            
             
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

end

% --- Outputs from this function are returned to the command line.
function varargout = testrealtimeGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end


% --- Executes on button press in playAllbtn.
function playAllbtn_Callback(hObject, ~, handles)
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
myGUIdata.player = audioplayer(x/max(abs(x))*0.9,fs);
AxisLim = axis;

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
function playbtn_Callback(hObject, ~, handles)
% hObject    handle to playbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global imin;
global imax;
myGUIdata = guidata(handles.multiScopeMainGUI);

x = myGUIdata.audioData;
myGUIdata.player = audioplayer(x/max(abs(x))*0.99,44100);
playblocking(myGUIdata.player,[round(myGUIdata.player.SampleRate*imin) round(myGUIdata.player.SampleRate*imax)]);
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
set(myGUIdata.test,'enable','on');

if(~isvalid(myGUIdata.timerForPlayer))
    timerEventInterval = 0.5; % in second
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
    myGUIdata.smallviewerWidth = 100;
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

myGUIdata = guidata(handles.multiScopeMainGUI);
myGUIdata.audioData = getaudiodata(myGUIdata.recordObj1);
set(myGUIdata.windowViewHandle,'visible','off');
set(myGUIdata.smallViewerPlotHandle,'visible','off');
set(myGUIdata.largeViewerPlotHandle,'visible','off');
set(myGUIdata.smallViewerAxis,'visible','off');
set(myGUIdata.domaintime,'visible','on');
set(myGUIdata.recordbtn,'enable','on');
set(myGUIdata.stopbtn,'enable','off');

set(myGUIdata.playAllbtn,'enable','on');
set(myGUIdata.selectbtn,'enable','on');
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
set(handles.multiScopeMainGUI,'pointer','arrow');drawnow
start(myGUIdata.timerForPlayer);
fs = 44100;
y = myGUIdata.audioData;
myGUIdata.player = audioplayer(y/max(abs(y))*0.9,fs);
guidata(handles.multiScopeMainGUI,myGUIdata);
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
   if ~((ymin > ymax) | (xmin > xmax))
        imin = xmin;
        imax = xmax;
   end
    rec = rectangle('Position',[xmin,AxisLim(3),xmax-xmin,AxisLim(4)-AxisLim(3)],'EdgeColor','g','LineWidth',2)
    set(myGUIdata.playbtn,'enable','on');
    set(myGUIdata.deletebtn,'enable','on');
    set(myGUIdata.testSegment,'enable','on');
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
 myGUIdata = guidata(handles.multiScopeMainGUI);
 button = questdlg('DO YOU WANT TO DELETE','Delete');
 switch button
     case {'Yes'}
         
         myGUIdata.audioData(round(myGUIdata.player.SampleRate*imin):round(myGUIdata.player.SampleRate*imax))=[];
         samp_len = length(myGUIdata.audioData)/44100;
         delta_t = 1/44100;
         t = 0:delta_t:(samp_len-delta_t);
         plot(myGUIdata.domaintime,t,myGUIdata.audioData), xlabel('Time (seconds)'), ylabel('Amplitude')     
 end    
 set(myGUIdata.deletebtn,'enable','off');
 set(myGUIdata.playbtn,'enable','off');
 set(myGUIdata.testSegment,'enable','off');
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
function Save_Callback(hObject, eventdata, handles)
% hObject    handle to Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
myGUIdata = guidata(handles.multiScopeMainGUI);
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
set(myGUIdata.test,'enable','on');
myGUIdata.audioData = y;
myGUIdata.player = audioplayer(y/max(abs(y))*0.9,fs);
guidata(handles.multiScopeMainGUI,myGUIdata);

end



% --- Executes on button press in test.
function test_Callback(hObject, eventdata, handles)
% hObject    handle to test (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
myGUIdata = guidata(handles.multiScopeMainGUI);
load('vocabulary.mat');
predicted_word_labels = vocabulary.test(myGUIdata.audioData);
detectfall = predicted_word_labels;
guidata(handles.multiScopeMainGUI,myGUIdata);
        
end



function textInput_Callback(hObject, eventdata, handles)
% hObject    handle to textInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textInput as text
%        str2double(get(hObject,'String')) returns contents of textInput as a double
end


% --- Executes during object creation, after setting all properties.
function textInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on button press in mcr.
function mcr()
% hObject    handle to mcr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load('wordlabels.mat');
load('vocabulary.mat');
load('audiosignals.mat');


predicted_word_labels = vocabulary.mcr(audio_signals', word_labels', audio_signals');
TP = 0;
TN = 0;
FP = 0;
FN = 0;
for i = 1:length(word_labels)
    fact  = word_labels(i);
    guess = predicted_word_labels(i);
    if(strcmp(fact, 'fall'))||(strcmp(fact, 'fallbath'))
        fact = 'fall';
    else
        fact = 'nonfall';
    end
    
    if(strcmp(guess, 'fall'))||(strcmp(guess, 'fallbath'))
        guess = 'fall';
    else
        guess = 'nonfall';
    end
    
    
    
    if (strcmp(fact, 'fall'))||(strcmp(guess, 'fall'))
        TP = TP+1;
    elseif(strcmp(fact, 'nonfall'))||(strcmp(guess, 'nonfall'))
        TN = TN+1;
    elseif(strcmp(fact, 'nonfall'))||(strcmp(guess, 'fall'))
        FP = FP+1;
    else
        FN = FN+1;
    end
end

sen = (TP/(TP+FN))*100;
spec = TN/(TN+FP)*100;
accu = (TP+TN)/(TP+FN+FP+TN)*100;
disp(sen);
disp(spec);
disp(accu);
end


% --- Executes on button press in testSegment.
function testSegment_Callback(hObject, eventdata, handles)
% hObject    handle to testSegment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global imin;
global imax;
myGUIdata = guidata(handles.multiScopeMainGUI);
load('vocabulary.mat');
predicted_word_labels = vocabulary.test(myGUIdata.audioData(round(myGUIdata.player.SampleRate*imin):round(myGUIdata.player.SampleRate*imax)));
end


% --- Executes on button press in mcr.
function mcr_Callback(hObject, eventdata, handles)
% hObject    handle to mcr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load('wordlabels.mat');
load('vocabulary.mat');
load('audiosignals.mat');


predicted_word_labels = vocabulary.mcr(audio_signals', word_labels', audio_signals');
TP = 0;
TN = 0;
FP = 0;
FN = 0;
for i = 1:length(word_labels)
    fact  = word_labels(i);
    guess = predicted_word_labels(i);
    if(strcmp(fact, 'fall'))||(strcmp(fact, 'fallbath'))
        fact = 'fall';
    else
        fact = 'nonfall';
    end
    
    if(strcmp(guess, 'fall'))||(strcmp(guess, 'fallbath'))
        guess = 'fall';
    else
        guess = 'nonfall';
    end
    
    
    
    if (strcmp(fact, 'fall'))&&(strcmp(guess, 'fall'))
        TP = TP+1;
    elseif(strcmp(fact, 'nonfall'))&&(strcmp(guess, 'nonfall'))
        TN = TN+1;
    elseif(strcmp(fact, 'nonfall'))&&(strcmp(guess, 'fall'))
        FP = FP+1;
    else
        FN = FN+1;
    end
end

sen = (TP/(TP+FN))*100;
spec = TN/(TN+FP)*100;
accu = (TP+TN)/(TP+FN+FP+TN)*100;
disp(TP);
disp(TN);
disp(FP);
disp(FN);
disp(sen);
disp(spec);
disp(accu);
end
