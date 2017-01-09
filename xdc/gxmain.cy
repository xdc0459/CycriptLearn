//#!usr/bin/cycript

// TODO : must modify this argument if you move xdccycript to a diffent directory;
// scp -P 2222 -r ./xdc root@localhost:”/gx_cycript_code_dir.superDir” (not contain lat path component “/xdc” )
// e.g: scp -P 2222 -r ./xdc root@localhost:/usr/lib/cycript0.9/com

// ssh the device then : cycript run the script and cycript the process
// cycript -p Sight /usr/lib/cycript0.9/com/xdc/gxmain.cy 
// cycript -p Sight

var gx_cycript_code_dir = "/usr/lib/cycript0.9/com/xdc/";
// include other .cy files
function gx_include(name) {
  var fn = gx_cycript_code_dir + name;

  var t = [new NSTask init]; [t setLaunchPath:@"/usr/bin/cycript"]; [t setArguments:["-c", fn]];
  var p = [NSPipe pipe]; [t setStandardOutput:p]; [t launch]; [t waitUntilExit]; 
  var s = [new NSString initWithData:[[p fileHandleForReading] readDataToEndOfFile] encoding:4];
  return this.eval(s.toString());
}

//@import ./HookShader.cy;
//#include "./HookShader.cy";
//include("./HookShader.cy");
//gx_include("HookShader.cy");

gx_include("common.cy");
gx_include("HookGLShader.cy");
gx_include("HookImage.cy");
