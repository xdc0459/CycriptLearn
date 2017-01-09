//#!usr/bin/cycript

@import com.saurik.substrate.MS;

extern "C" void glShaderSource(GLuint shader, GLsizei count, const GLchar* const *string, const GLint* length);
// var oldgl= {};
// MS.hookFunction(glShaderSource, function(shader, count, pstring, length) { (*oldgl)(shader, count, pstring, length); NSLog([new NSString initWithFormat:@"\n%@", [new  NSString initWithUTF8String:*pstring], nil]); }, oldgl)
// extern "C" void glShaderSource(GLuint shader, GLsizei count, const GLchar* const *string, const GLint* length);
// void glTexImage2D(GLenum target, GLint level, GLint internalformat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum type, const GLvoid* pixels);
// call hook_glShaderSource or hook_glShaderSource2 only once
var old_glShaderSource = {};
function gx_hook_glShaderSource() {
    MS.hookFunction(glShaderSource, function(shader, count, pstring, plength) {
        (*old_glShaderSource)(shader, count, pstring, plength);
	// NSLog(@"", a, nil)， if don't has a more 'nil' argument, will crash
	// 如果不多出一个nil参数的话，会crash	
        NSLog([new NSString initWithFormat:@"count %i;\n%@", count, [new NSString initWithUTF8String:*pstring], nil]);
    }, old_glShaderSource);
}
function gx_hook_glShaderSource2() {
    MS.hookFunction(glShaderSource, function(shader, count, pstring, plength) {
	if (count > 1 && plength != NULL) {
            //NSLog([new NSString initWithFormat:@"shader count %i", count, nil]);
	    var shadersStr = [new NSMutableString];
            for (var i = 0; i < count; ++i)
	    {
                var length = *(plength+i);
                if (lenght > 0) {
                    var p = malloc(lenght+1);
                    if (p != NULL) {
                        memset(p, 0x00, lenght+1); memcpy(p, *(pstring+i), lenght); // strncpy
	                // NSLog(@"", a, nil)， if don't has a more 'nil' argument, will crash
	                // 如果不多出一个nil参数的话，会crash
			[shadersStr addendFormat:@"shader %i:\n%@", i, [new NSString initWithUTF8String:p], nil];
                        free(p);
                    }
                } else {
		    NSLog([new NSString initWithFormat:@"shader %i:\n%@", i, [new NSString initWithUTF8String:pstring[i]], nil]);
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
function gx_hook_glShaderBinary() {
    MS.hookFunction(glShaderBinary, function(n, shaders, binaryformat, binary, length) {
        (*old_glShaderBinary)(n, shaders, binaryformat, binary, length);
	// NSLog(@"", a, nil)， if don't has a more 'nil' argument, will crash
	// 如果不多出一个nil参数的话，会crash
	NSLog([new NSString initWithFormat:@"glShaderBinary count %i, binaryformat:%i; \n%@", n, binaryformat, [new NSData initWithBytes:binary length:length], nil]); 
    }, old_glShaderBinary);
}

// + (nullable CIFilter *) filterWithName:(NSString *) name;
// + (nullable CIFilter *)filterWithName:(NSString *)name keysAndValues:key0, ... NS_REQUIRES_NIL_TERMINATION
// + (nullable CIFilter *)filterWithName:(NSString *)name withInputParameters:(nullable NSDictionary<NSString *,id> *)params
// TODO : a qusetion = I don't know how to hook 'filterWithName:keysAndValues:key0, ...'
var old_CIFilter_filterWithName = {};
function gx_hook_CIFilter_filterWithName() {
    MS.hookMessage(CIFilter->isa, @selector(filterWithName:), function(arg1) {
       NSLog(@"%@", arg1, nil);
       return old_CIFilter_filterWithName->call(this, arg1);
    }, old_CIFilter_filterWithName);
}

var old_CIFilter_filterWithName_withInputParameters = {};
function gx_hook_CIFilter_filterWithName_withInputParameters() {
    MS.hookMessage(CIFilter->isa, @selector(filterWithName:withInputParameters:), function(arg1, params) {
       NSLog(@"CIFilter filterWithName : %@, %@", arg1, params, nil);
       return old_CIFilter_filterWithName_withInputParameters->call(this, arg1, params);
    }, old_CIFilter_filterWithName_withInputParameters);
}

// GPUImageFilter
// - (id)initWithVertexShaderFromString:(NSString *)vertexShaderString fragmentShaderFromString:(NSString *)fragmentShaderString
function gx_hook_GPUImageFilter_initWithShader() {
    filterOriginInitShader = GPUImageFilter.prototype['initWithVertexShaderFromString:fragmentShaderFromString:'];
    GPUImageFilter.prototype['initWithVertexShaderFromString:fragmentShaderFromString:'] = function(arg1, arg2) {
        var result = filterOriginInitShader.call(this, arg1, arg2);
        NSLog(@"GPUImageFilter initWithShader:%@=#%p,\nvshader=\n%@\nfshader=\n%@\n", NSStringFromClass(this), this, arg1, arg2, nil);
        return result;
    }
}

