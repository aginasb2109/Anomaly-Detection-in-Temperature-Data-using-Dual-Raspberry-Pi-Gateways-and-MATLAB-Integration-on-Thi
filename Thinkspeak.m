temperatureThreshold = 50; 
channelID = ; //Please give your channel id of your Thingspeak
livingRoomFieldID = 1; 
bedRoomFieldID = 2;
readAPIKey = ''; //Please give your Read Api key of that channel of your Thingspeak

urlLivingRoom = sprintf('https://api.thingspeak.com/channels/%d/fields/%d.json?api_key=%s', ...
    channelID, livingRoomFieldID, readAPIKey);

urlBedRoom = sprintf('https://api.thingspeak.com/channels/%d/fields/%d.json?api_key=%s', ...
    channelID, bedRoomFieldID, readAPIKey);

try
    % Fetch living room data
    livingRoomData = webread(urlLivingRoom);
    if isempty(livingRoomData.feeds)
        error('No data available in the living room field.');
    end
    
    livingRoomTemperature = NaN;
    if isfield(livingRoomData.feeds(1), 'field1')
        livingRoomTemperature = str2double(livingRoomData.feeds(1).field1);
    end
    
    if isnan(livingRoomTemperature)
        disp('Error: Invalid living room temperature data received.');
    else
        disp(['Living Room Temperature: ', num2str(livingRoomTemperature), '°C']);
    end
    
    if livingRoomTemperature > temperatureThreshold
        sendAlert('Living Room', livingRoomTemperature, temperatureThreshold);
    end
    
    % Fetch bedroom data
    bedRoomData = webread(urlBedRoom);
    if isempty(bedRoomData.feeds)
        error('No data available in the bedroom field.');
    end
    
    bedRoomTemperature = NaN;
    if isfield(bedRoomData.feeds(1), 'field2')
        bedRoomTemperature = str2double(bedRoomData.feeds(1).field2);
    end
    
    if isnan(bedRoomTemperature)
        disp('Error: Invalid bedroom temperature data received.');
    else
        disp(['Bedroom Temperature: ', num2str(bedRoomTemperature), '°C']);
    end
    
    if bedRoomTemperature > temperatureThreshold
        sendAlert('Bedroom', bedRoomTemperature, temperatureThreshold);
    end

catch exception
    disp(['Error: ', exception.message]);
end

function sendAlert(roomName, temperature, threshold)
    alert_subject = sprintf('Alert: %s Temperature above Threshold', roomName);
    alert_body = sprintf('The temperature in the %s (%.2f°C) has risen above the threshold of %.2f°C.', ...
        roomName, temperature, threshold);
    
    alert_api_key = 'TAK3mNeByX/pJOL3/z5'; % Use your ThingSpeak Alert API Key
    alert_url = 'https://api.thingspeak.com/alerts/send'; % API endpoint for sending the alert
    alert_data = struct('subject', alert_subject, 'body', alert_body);
    jsonmessage = jsonencode(alert_data);
    
    headers = {
        'Thingspeak-Alerts-API-Key', alert_api_key;
        'Content-Type', 'application/json'
    };
    
    options = weboptions('HeaderFields', headers);
    
    % Send the alert through ThingSpeak API
    try
        result = webwrite(alert_url, jsonmessage, options);
        disp(['Email alert sent for ', roomName, '!']);
    catch
        disp(['Error: Could not send email for ', roomName, '.']);
    end
end
