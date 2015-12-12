function varargout = splice_gui(varargin)
% SPLICE_GUI MATLAB code for splice_gui.fig
%      SPLICE_GUI, by itself, creates a new SPLICE_GUI or raises the existing
%      singleton*.
%
%      H = SPLICE_GUI returns the handle to a new SPLICE_GUI or the handle to
%      the existing singleton*.
%
%      SPLICE_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SPLICE_GUI.M with the given input arguments.
%
%      SPLICE_GUI('Property','Value',...) creates a new SPLICE_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before splice_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to splice_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help splice_gui

% Last Modified by GUIDE v2.5 10-Dec-2015 14:27:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @splice_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @splice_gui_OutputFcn, ...
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


% --- Executes just before splice_gui is made visible.
function splice_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to splice_gui (see VARARGIN)
handles.vec_cell = getappdata(0,'splices');
handles.file_name = getappdata(0,'file_name');
handles.syll_list = cell(1,length(handles.vec_cell));
for k = 1:length(handles.vec_cell)
    handles.syll_list{k} = [handles.file_name 'syll' int2str(k)];
end
handles.syll_index = 1;
handles = get_info(hObject,handles);
initial_plt(handles.curr_data, handles.fs, handles.thresh, handles.axes1,handles.axes2,handles);
% Choose default command line output for splice_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes splice_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = splice_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function handles=get_info(varargin) %MODIFIES THE HANDLE WITH UPDATED DATA
    handles = varargin{2};
    handles.fs = 250000;
    handles.curr_data = handles.vec_cell{handles.syll_index};
    handles.g_noise=0.0000001*randn(size(handles.curr_data)); %gaussian noise used to calculate threshold value
    handles.thresh=-snr(handles.curr_data,handles.g_noise); %threshold value for spectrogram

    
function initial_plt(data,fs,thresh,ax1,ax2,handles) %MAKE PLOTS
    axes(ax1); 
    t = 0:1/fs:(length(data)-1)/fs;
    plot(t,data); xlabel('Time(secs)'); ylabel('Amplitude'); 
    ax1.XLim = [0 t(end)];
    title(handles.syll_list{handles.syll_index});
    axes(ax2);
    spectrogram(data,256,[],[],fs,'power','minthreshold',thresh,'yaxis'); colormap('jet');
    ax2.Position(3) = ax1.Position(3); %aligning the axes for splicing purposes

    %ch = colorbar; pause(1); delete(ch);


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles) %NEXT
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles.syll_index = handles.syll_index + 1;
    if handles.syll_index == length(handles.vec_cell) + 1
        handles.syll_index = length(handles.vec_cell);
        m=msgbox('End of intervals.');
        uiwait(m);
    end
    handles = get_info(hObject,handles);
    initial_plt(handles.curr_data,handles.fs,handles.thresh,handles.axes1,handles.axes2,handles);
    guidata(hObject,handles);

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles) %PREVIOUS
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles.syll_index = handles.syll_index - 1;
    if handles.syll_index == 0
        handles.syll_index = 1;
        m=msgbox('Beginning of intervals.');
        uiwait(m);
    end
    handles = get_info(hObject,handles);
    initial_plt(handles.curr_data,handles.fs,handles.thresh,handles.axes1,handles.axes2,handles);
    guidata(hObject,handles);

% --- Executes on button press in pushbutton4. %SPECTROGRAM
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    axes(handles.axes2);
    spectrogram(handles.curr_data,256,[],[],handles.fs,'power','minthreshold',handles.thresh,'yaxis'); colormap('jet');

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles) %MEAN FREQ.
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    axes(handles.axes2);
    meanfreq(handles.curr_data,handles.fs);


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    axes(handles.axes2);
    handles.thresh = handles.thresh - 2.5;
    spectrogram(handles.curr_data,256,[],[],handles.fs,'power','minthreshold',handles.thresh,'yaxis'); colormap('jet');
    guidata(hObject,handles);
    

% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    axes(handles.axes2);
    handles.thresh = handles.thresh + 2.5;
    spectrogram(handles.curr_data,256,[],[],handles.fs,'power','minthreshold',handles.thresh,'yaxis'); colormap('jet');
    guidata(hObject,handles);

% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    sound(handles.curr_data, 200000);


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    folder_name = [uigetdir('') '/'];
    syllables = handles.vec_cell;
    save([folder_name handles.file_name(1:end-4) '.MAT'],'syllables');
