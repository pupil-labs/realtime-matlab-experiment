function [response] = pupil_labs_realtime_api(varargin)
% Function to call the simple API https://pupil-labs.github.io/realtime-network-api/
% directly from Matlab. This function makes use of the .net.http package
% from Matlab
% https://mathworks.com/help/matlab/ref/matlab.net.http-package.html#
%
% Usage:
%   r = pupil_labs_realtime_api();
%   or
%   r= pupil_labs_realtime_api('Command','start');
%
% Optional input parameters:
%
%   - 'Command' -> One of the valid commands 'status', 'start',
% 'save', 'cancel' or 'event'. Default is 'status'.
%
%   - 'EventName' -> A string with the annotation name for the event,
%   default is 'Test event'.
%
%   - 'URLhost' -> A string containing the URL of Pupil Labs Eyetracker, by
%   default is 'http://pi.local:8080/'
%
%
% 220719 mgg Initial function

opts= inputParser;

validCommands = {'status', 'start', 'save', 'cancel', 'event'};
checkCommands = @(x)any(validatestring(x, validCommands));

addParameter(opts,'Command','status', checkCommands);
addParameter(opts,'URLhost','http://pi.local:8080/', @ischar);
addParameter(opts,'EventName', 'Test event', @ischar);

parse(opts, varargin{:});
opts = opts.Results;

import matlab.net.*
import matlab.net.http.*

% Define headers to be used
headers=[...
    matlab.net.http.HeaderField('Content-Type', 'application/json') ...
    matlab.net.http.HeaderField('Accept', '*/*')...
    matlab.net.http.HeaderField('Access-Control-Allow-Origin', '*')...
    matlab.net.http.HeaderField('Access-Control-Allow-Methods','GET, POST')...
    matlab.net.http.HeaderField('Access-Control-Max-Age','151200')...
    matlab.net.http.HeaderField('Access-Control-Allow-Headers','origin,accept,content-type')...
    matlab.net.http.HeaderField('Content-Encoding','gzip, deflate')...
    matlab.net.http.HeaderField('Transfer-Encoding','gzip, deflate')...
    matlab.net.http.HeaderField('Date', [datestr(datetime('now','TimeZone','UTC'), 'ddd, dd mmm yyyy HH:MM:SS'), ' GMT'])...
    ];

% Create the request message
r = RequestMessage('POST',headers);

% Change url end and other params based on the command request
switch opts.Command
    case 'status'
        r.Method = 'GET';
        url_end = 'api/status';
    case 'start'
        url_end = 'api/recording:start';
    case 'save'
        url_end = 'api/recording:stop_and_save';
    case 'cancel'
        url_end = 'api/recording:cancel';
    case 'event'
        url_end = 'api/event';
        s.name = opts.EventName;
        r.Body = matlab.net.http.io.JSONProvider(s);
end

% Send the HTTP request
[response,~,~] = send(r,[opts.URLhost,url_end]);
end
