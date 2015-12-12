function varargout = viewcall_gui(varargin)
% VIEWCALL_GUI MATLAB code for viewcall_gui.fig
%      VIEWCALL_GUI, by itself, creates a new VIEWCALL_GUI or raises the existing
%      singleton*.
%
%      H = VIEWCALL_GUI returns the handle to a new VIEWCALL_GUI or the handle to
%      the existing singleton*.
%
%      VIEWCALL_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VIEWCALL_GUI.M with the given input arguments.
%
%      VIEWCALL_GUI('Property','Value',...) creates a new VIEWCALL_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before viewcall_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to viewcall_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help viewcall_gui

% Last Modified by GUIDE v2.5 11-Dec-2015 15:21:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @viewcall_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @viewcall_gui_OutputFcn, ...
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


% --- Executes just before viewcall_gui is made visible.
function viewcall_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to viewcall_gui (see VARARGIN)

handles.dir = uigetdir;
if not(handles.dir)
    error('No directory selected.')
end
cd(handles.dir);
handles.d_struct = dir([handles.dir '/*.WAV']);
handles.start_path = '';

while isempty(handles.d_struct)
    h = msgbox('No .WAV files found. Please close the GUI and select another directory.','Error','error');   
    uiwait(h);
    handles.dir = uigetdir;
    handles.d_struct = dir([handles.dir '/*.WAV']);
end
handles.struct_index = 1;
handles = get_info(hObject,handles);

initial_plt(handles.current_data,handles.fs,handles.thresh,handles.axes1,handles.axes2,handles.file_name);



% Choose default command line output for viewcall_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes viewcall_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = viewcall_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    sound(handles.current_data, 200000);
    

% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles) %MAKE SPECTROGRAM
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    axes(handles.axes2);
    spectrogram(handles.current_data,512,[],[],handles.fs,'power','minthreshold',handles.thresh,'yaxis'); colormap('jet');

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    axes(handles.axes2);
    meanfreq(handles.current_data,handles.fs);
    
% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles) %SPLICE 
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    zoom(handles.axes1,'out'); % zoom out to original plots
    zoom(handles.axes2,'out'); 
    [x_times,y_vals]=ginput;
    [x_times,y_vals]=check_intervals(handles.axes1,x_times,y_vals);
    lines=make_lines(x_times,handles.axes1);
    x_times = keep_intervals(handles.axes1,lines,x_times);
    if isempty(x_times)
        return
    end
    splices = vec_splice(handles.current_data,x_times,handles.axes1.XLim(2));
    setappdata(0,'splices',splices);
    setappdata(0,'file_name',handles.file_name);
    delete(lines);
    splice_gui; 
    
function vec_splices = vec_splice(vec,times,xlim) %takes an array of time intervals and splices the vector accordingly; returns cell array of vectors
    k=1; i = 1;
    num_splices = length(times)/2;
    vec_splices = cell(1,num_splices);
    while k < length(times)
        t_1 = round(length(vec)*times(k)/xlim);
        t_2 = round(length(vec)*times(k+1)/xlim);
        new_vec = vec(t_1:t_2);
        vec_splices{i} = new_vec;  
        k = k + 2; %iterating over odd indices
        i = i + 1;
    end

function x_keep=keep_intervals(ax,lines,x)
    answer = questdlg('Keep these intervals?');
    while strcmp(answer,'No')
        delete(lines);
        [x,y_vals]=ginput;
        [x,y_vals]=check_intervals(ax,x,y_vals);
        lines=make_lines(x,ax);
        answer = questdlg('Keep these intervals?');
    end
    if strcmp(answer,'Yes')
        x_keep=x;
    else
        delete(lines);
        x_keep = [];
    end
    
        
function lines=make_lines(x_vals,ax1) %# of x_vals should be even
    lines = [];
    for j = 1:(length(x_vals)/2)
            if mod(j,2) == 0
                color_val = [1 0 0]; %red
            else
                color_val = [0 0 0]; %black
            end
            
            l1 = line([x_vals(2*j-1) x_vals(2*j-1)], ax1.YLim,'color',color_val);
            l2 = line([x_vals(2*j) x_vals(2*j)], ax1.YLim,'color',color_val);
          
            lines = [lines l1 l2];
    end

    
function [x,y]=check_intervals(ax,x,y)
    while not(in_bounds(ax,x,y))||not(is_even(x))
        h=msgbox('You chose a coordinate out of bounds or an odd number of coordinates. Please pick again.');
        uiwait(h);
        [x,y]=ginput;
    end
    x = sort(x); %order doesn't matter
    
function bool=in_bounds(ax,x_vals,y_vals) 
    xl = ax.XLim; yl = ax.YLim;
    upper_bound_x = (x_vals >= xl(2)); lower_bound_x = (x_vals <= xl(1));
    upper_bound_y = (y_vals >= yl(2)); lower_bound_y = (y_vals <= yl(1));
    if any(upper_bound_x)||any(lower_bound_x)||any(upper_bound_y)||any(lower_bound_y)
        bool = 0; % x_vals or y_vals are out of bounds
    else
        bool = 1; % x_vals and y_vals are in bounds
    end
    
function bool=is_even(x)
    if mod(length(x),2)==0;
        bool = 1;
    else
        bool = 0;
    end
    
function initial_plt(data,fs,thresh,ax1,ax2,file_name) %MAKE PLOTS
    axes(ax1);
    t = 0:1/fs:(length(data)-1)/fs;
    plot(t,data); xlabel('Time(secs)'); ylabel('Amplitude'); title(file_name);
    ax1.XLim = [0 t(end)];
    axes(ax2);
    spectrogram(data,512,[],[],fs,'power','minthreshold',thresh,'yaxis'); colormap('jet');
    ax2.Position(3) = ax1.Position(3); %aligning the axes for splicing purposes

    %ch = colorbar; pause(1); delete(ch);
    
function handles=get_info(varargin) %MODIFIES THE HANDLE WITH UPDATED DATA
    handles = varargin{2};
    handles.current_file = handles.d_struct(handles.struct_index);
    handles.file_name = handles.current_file.name;
    [handles.current_data, handles.fs] = audioread([handles.dir '/' handles.file_name]);
    handles.g_noise=0.0000001*randn(size(handles.current_data)); %gaussian noise used to calculate threshold value
    handles.thresh=-snr(handles.current_data,handles.g_noise); %threshold value for spectrogram
    handles.zoom = 1;
    
% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles) %RAISE THRESHHOLD
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    axes(handles.axes2);
    handles.thresh = handles.thresh + 2.5;
    spectrogram(handles.current_data,512,[],[],handles.fs,'power','minthreshold',handles.thresh,'yaxis'); colormap('jet');
    guidata(hObject,handles);
    
% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles) %LOWER THRESHHOLD
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA) 
    axes(handles.axes2);
    handles.thresh = handles.thresh - 2.5;
    spectrogram(handles.current_data,512,[],[],handles.fs,'power','minthreshold',handles.thresh,'yaxis'); colormap('jet');
    guidata(hObject,handles);
    


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles) %NEXT FILE
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles.struct_index = handles.struct_index + 1;
    if handles.struct_index == length(handles.d_struct) + 1
        handles.struct_index = length(handles.d_struct);
        m=msgbox('End of directory reached.');
        uiwait(m);
    end
    
    handles = get_info(hObject,handles);
    initial_plt(handles.current_data,handles.fs,handles.thresh,handles.axes1,handles.axes2,handles.file_name);
    guidata(hObject,handles);
    zoom off;
    
% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles) %PREV FILE
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles.struct_index = handles.struct_index - 1;
    if handles.struct_index == 0
        handles.struct_index = 1;
        m=msgbox('Beginning of directory reached.');
        uiwait(m);
    end
    handles = get_info(hObject,handles);
    initial_plt(handles.current_data,handles.fs,handles.thresh,handles.axes1,handles.axes2,handles.file_name);
    guidata(hObject,handles);
    zoom off;
    
 % --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles) %JUMP TO FILE
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    answer = uigetfile('./*.WAV'); 
    if not(answer)
        answer = handles.file_name;
    end
    handles.struct_index = find(ismember({handles.d_struct.name},answer));
    handles = get_info(hObject,handles);
    initial_plt(handles.current_data,handles.fs,handles.thresh,handles.axes1,handles.axes2,handles.file_name);
    guidata(hObject,handles);
    zoom off;


% --- Executes on button press in pushbutton14.
function pushbutton14_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if handles.zoom == 1
        zoom on
    else
        zoom off
    end
    handles.zoom = not(handles.zoom);
    guidata(hObject,handles);
    


% --- Executes on button press in pushbutton18.
function pushbutton18_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    answer = uigetdir(handles.start_path);
    if isempty(answer)
        return
    elseif not(strcmp(fileparts(answer),handles.start_path))
        handles.start_path = fileparts(answer); %gets parent folder
    end
    copyfile(handles.file_name,answer);
    
    guidata(hObject,handles);
        