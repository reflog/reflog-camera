cordova.define("org.reflog.camera.plugin.ReflogCamera", function(require, exports, module) { var exec = require('cordova/exec');

_logMessage = function(message){
  return console.log(message);
};

exports.openCamera = function(success, error) {
  success = success || _logMessage;
  error = error || _logMessage;
  exec(success, error, "reflogcamera", "openCamera", []);
};

exports.takePhoto = function(success, error, title) {
  success = success || _logMessage;
  error = error || _logMessage;
  exec(success, error, "reflogcamera", "takePhoto", [title]);
};

exports.closeCamera = function(success, error) {
  success = success || _logMessage;
  error = error || _logMessage;
  exec(success, error, "reflogcamera", "closeCamera", []);
};

});
