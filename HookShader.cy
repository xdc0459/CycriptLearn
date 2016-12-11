
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
// call hook_glShaderSource or hook_glShaderSource2 only once
var old_glShaderSource = {};
function hook_glShaderSource() {
    MS.hookFunction(glShaderSource, function(shader, count, pstring, plength) {
        (*old_glShaderSource)(shader, count, pstring, plength);
	// NSLog(@"", a, nil)， if don't has a more 'nil' argument, will crash
	// 如果不多出一个nil参数的话，会crash	
        NSLog([new NSString initWithFormat:@"count %i;\n%@", count,[new NSString initWithUTF8String:*pstring], nil]);
    }, old_glShaderSource);
}
function hook_glShaderSource2() {
    MS.hookFunction(glShaderSource, function(shader, count, pstring, plength) {
	if (count > 1 && plength != NULL) {
            //NSLog([new NSString initWithFormat:@"shader count %i", count, nil]);
            for (var i = 0; i < count; ++i)
	    {
                var length = *(plength+i);
                if (lenght > 0) {
                    var p = malloc(lenght+1);
                    if (p != NULL) {
                        memset(p, 0x00, lenght+1); memcpy(p, *(pstring+i), lenght); // strncpy
	                // NSLog(@"", a, nil)， if don't has a more 'nil' argument, will crash
	                // 如果不多出一个nil参数的话，会crash
                        NSLog([new NSString initWithFormat:@"shader:\n%@", [new NSString initWithUTF8String:p], nil]);
                        free(p);
                    }
                }
            }
        } else if (pstring != NULL) {
	    // NSLog(@"", a, nil)， if don't has a more 'nil' argument, will crash
	    // 如果不多出一个nil参数的话，会crash
            NSLog([new NSString initWithFormat:@"count %i;\n%@", count,[new NSString initWithUTF8String:*pstring], nil]);
        }
	(*old_glShaderSource)(shader, count, pstring, plength);
    }, old_glShaderSource);
}

// void glShaderBinary (GLsizei n, const GLuint* shaders, GLenum binaryformat, const GLvoid* binary, GLsizei length)  
var old_glShaderBinary = {};
function hook_glShaderBinary() {
    MS.hookFunction(glShaderBinary, function(n, shaders, binaryformat, binary, length) {
        (*old_glShaderBinary)(n, shaders, binaryformat, binary, length);
	// NSLog(@"", a, nil)， if don't has a more 'nil' argument, will crash
	// 如果不多出一个nil参数的话，会crash
	NSLog([new NSString initWithFormat:@"glShaderBinary count %i, binaryformat:%i; \n%@", n, binaryformat, [new NSData initWithBytes:binary length:length], nil]); 
    }, old_glShaderBinary);
}
