
NSLog_ = dlsym(RTLD_DEFAULT, "NSLog");
WCDLog = function() { var types = 'v', args = [], count = arguments.length; for (var i = 0; i != count; ++i) { types += '@'; args.push(arguments[i]); } new Functor(NSLog_, types).apply(null, args); }

_method_copyReturnType=new Functor(dlsym(RTLD_DEFAULT,"method_copyReturnType"),"*^{objc_method=}");
_method_copyArgumentType=new Functor(dlsym(RTLD_DEFAULT,"method_copyArgumentType"),"*^{objc_method=}I");
__sysctlbyname=new Functor(dlsym(-2,"sysctlbyname"),"v*^?^i^?i");

function is64Bit(){
	size=new int;
	__sysctlbyname("hw.cpu64bit_capable",NULL,size,NULL,0);
	is64Bit=new BOOL;
	__sysctlbyname("hw.cpu64bit_capable",is64Bit,size,NULL,0);
	return *is64Bit;
}

@import com.saurik.substrate.MS;
extern "C" void glShaderSource(GLuint shader, GLsizei count, const GLchar* const *string, const GLint* length);

// var oldgl= {};
// MS.hookFunction(glShaderSource, function(shader, count, pstring, length) { (*oldgl)(shader, count, pstring, length); NSLog([new NSString initWithFormat:@"\n%@", [new  NSString initWithUTF8String:*pstring], nil]); }, oldgl)

var old_glShaderSource = {};
function hook_glShaderSource() {
    MS.hookFunction(glShaderSource, function(shader, count, pstring, plength) {
        (*old_glShaderSource)(shader, count, pstring, plength);
	NSLog([new NSString initWithFormat:@"\n%@", [new  NSString initWithUTF8String:*pstring], nil]); 
    }, old_glShaderSource);
}
function hook_glShaderSource2() {
    MS.hookFunction(glShaderSource, function(shader, count, pstring, plength) {
        (*old_glShaderSource)(shader, count, pstring, plength);
        for (var i = 0; i < count; ++i) {
            var length = plength[i];
            if (lenght > 0) {
                var p = malloc(lenght+2);
                if (p != NULL) {
                    memset(p, 0x00, lenght+2); 
                    memcpy(p, pstring[i], lenght);
                    NSLog([new NSString initWithFormat:@"shader %i:\n%@", i, [new  NSString initWithUTF8String:p], nil]);
                    free(p);
                }
            }
        }
    }, old_glShaderSource);
}
