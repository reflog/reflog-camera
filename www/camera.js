var exec = require('cordova/exec');

_logMessage = function(message){
  return console.log(message);
};

exports.openCamera = function(title, success, error) {
    success = success || _logMessage;
    error = error || _logMessage;
    exec(success, error, "reflogcamera", "openCamera", [title]);
};

exports.closeCamera = function(success, error) {
    success = success || _logMessage;
    error = error || _logMessage;
    exec(success, error, "reflogcamera", "closeCamera", []);
};
