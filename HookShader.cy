
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

function printMethods(className, isa) {
    var count = new new Type("I");
    var classObj = (isa != undefined) ? objc_getClass(className)->isa : objc_getClass(className);
    var methods = class_copyMethodList(classObj, count);
    var methodsArray = [];
    for(var i = 0; i < *count; i++) {
        var method = methods[i];
        methodsArray.push({selector:method_getName(method), implementation:method_getImplementation(method)});
    }
    free(methods);
    return methodsArray;
}

function gx_showView(window, fileName, showLog) {
    window = window != nil ? window : [[[UIApplication sharedApplication] delegate] window];
    window = window != nil ? window : [[UIApplication sharedApplication] keyWindow];
    window = window != nil ? window : [[[UIApplication sharedApplication] windows] firstObject];
    var recursivStr = window.recursiveDescription();
    if ([recursivStr length] > 0 && [fileName length] > 0) {
        var path = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:fileName];
	// NSUTF8StringEncoding = 4
        if ([recursivStr writeToFile:path atomically:YES encoding:4 error:nil]){
	    if (!showLog) {
                recursivStr = [new NSString initWithFormat:@"had write to file : %@", path, nil];
	    }
	} else {
            
	}
    }
    return recursivStr.toString();
}

//[c for each (c in ObjectiveC.classes) if (class_getSuperclass(c) && [c isSubclassOfClass:UIView])]
function gx_printSubclassOfClass(superClass) {
    var string = [new NSMutableString init];
    for each (c in ObjectiveC.classes) {
        if (class_getSuperclass(c) && [c isSubclassOfClass:superClass]) {
            [string appendFormat:@"%@, ", NSStringFromClass(c), nil];
        }
    }
    return string;
}
    //var numClasses = objc_getClassList(NULL, 0);
    //var classSize = 8;//is64Bit() ? 8 : 4;
    //var pclasses = malloc(classSize * numClasses);
    //if (pclasses == NULL) return nil;
    //memset(pclasses, 0, classSize * numClasses)
    //numClasses = objc_getClassList(pclasses, numClasses);
function gx_printAllSubClassOfClass2(superClass) {
    var count = new new Type("I");
    var pclasses = objc_copyClassList(count);
    var numClasses = *count;
    if (pclasses == NULL) return nil;
    
    var string = [new NSMutableString init];
    for (var i = 0; i < numClasses; i++) {
        var temp = pclasses[i];
        if (temp != NULL) {
	    if (class_getSuperclass(temp))
            if (superClass != NULL) {
                if ([temp isSubclassOfClass:superClass]) {
                    [string appendFormat:@"%@, ", NSStringFromClass(temp), nil];
		}
            } else {
                [string appendFormat:@"%@, ", NSStringFromClass(temp), nil];
            }
        }
    }
    free(pclasses);
    return string;
}
/*
function gx_printAllSubClassFromClass2(superClass) {
    int numClasses = objc_getClassList(NULL, 0);
    var pclasses = malloc((is64Bit() ? 8 : 4) * numClasses);
    if (pclasses == NULL) return nil;
    numClasses = objc_getClassList(pclasses, numClasses);
    
    var string = [new NSMutableString init];
    for (int i = 0; i < numClasses; i++) {
        var class = pclasses[i];
        if (class != NULL) {
            if (superClass != NULL) {
                //if ([class isSubclassOfClass:superClass])
                Class sClass = class;
                while (sClass != NULL && sClass != [NSObject class]) {
                    if (sClass == superClass) {
                        [string appendFormat:@"%@,", NSStringFromClass(class)];
                        break;
                    }
                    sClass = class_getSuperclass(sClass);
                }
            } else {
                [string appendFormat:@"%@,", NSStringFromClass(class)];
            }
        }
    }
    free(pclasses);
    return string;
}
*/

@implementation UIViewController (ChildShow)
- gx_printViewControllerDesc {
    var self = this;
    var str = [NSMutableString stringWithFormat:@"[#%p %@]", self, NSStringFromClass([self class])];
    if ([[self childViewControllers] count] > 0) {
        if ([self isKindOfClass:[UITabBarController class]]) {
            [str appendFormat:@", selIndex=%tu, childs=", [self selectedIndex]];
        } else {
            [str appendFormat:@", childs=["];
        }
        
        for (var i = 0; i < [[self childViewControllers] count]; ++i) {
            var child = [self childViewControllers][i];
            [str appendFormat:@"{%i:%@}", i, [child gx_printViewControllerDesc]];
        }
        [str appendFormat:@"]."];
    }
    return str;
}
+ gx_printViewControllerList:(UIWindow *)window
{
    return gx_printViewControllerList(window);
}
@end
	      
function gx_printViewControllerList(UIWindow *window) {
    window = window != nil ? window : [[[UIApplication sharedApplication] delegate] window];
    window = window != nil ? window : [[UIApplication sharedApplication] keyWindow];
    window = window != nil ? window : [[[UIApplication sharedApplication] windows] firstObject];
    
    var controller = [window rootViewController];
    var list = [];
    while (controller) {
        if ([[controller childViewControllers] count] > 0) {
            NSLog(@"[#%p %@], child=%@", controller, NSStringFromClass([controller class]), [controller childViewControllers]);
            var str = [new NSString initWithFormat:@"[#%p %@], child=%@", controller, NSStringFromClass([controller class]), [controller childViewControllers], nil];
            list.push({str});
        } else {
            NSLog(@"[#%p %@]", controller, NSStringFromClass([controller class]));
            var str = [new NSString initWithFormat:@"[#%p %@]", controller, NSStringFromClass([controller class]), nil];
            list.push({str});
        }
        controller = [controller presentedViewController];
    }
    return list;
}

// 
// 
// 
//
@import com.saurik.substrate.MS;
extern "C" void glShaderSource(GLuint shader, GLsizei count, const GLchar* const *string, const GLint* length);

// var oldgl= {};
// MS.hookFunction(glShaderSource, function(shader, count, pstring, length) { (*oldgl)(shader, count, pstring, length); NSLog([new NSString initWithFormat:@"\n%@", [new  NSString initWithUTF8String:*pstring], nil]); }, oldgl)
// extern "C" void glShaderSource(GLuint shader, GLsizei count, const GLchar* const *string, const GLint* length);
// void glTexImage2D(GLenum target, GLint level, GLint internalformat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum type, const GLvoid* pixels);
// call hook_glShaderSource or hook_glShaderSource2 only once
var old_glShaderSource = {};
function hook_glShaderSource() {
    MS.hookFunction(glShaderSource, function(shader, count, pstring, plength) {
        (*old_glShaderSource)(shader, count, pstring, plength);
	// NSLog(@"", a, nil)， if don't has a more 'nil' argument, will crash
	// 如果不多出一个nil参数的话，会crash	
        NSLog([new NSString initWithFormat:@"count %i;\n%@", count, [new NSString initWithUTF8String:*pstring], nil]);
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

// + (nullable CIFilter *) filterWithName:(NSString *) name;
// + (nullable CIFilter *)filterWithName:(NSString *)name keysAndValues:key0, ... NS_REQUIRES_NIL_TERMINATION
// + (nullable CIFilter *)filterWithName:(NSString *)name withInputParameters:(nullable NSDictionary<NSString *,id> *)params
// TODO : a qusetion = I don't know how to hook 'filterWithName:keysAndValues:key0, ...'
var old_CIFilter_filterWithName = {};
function hook_CIFilter_filterWithName() {
    MS.hookMessage(CIFilter->isa, @selector(filterWithName:), function(arg1) {
       NSLog(@"%@", arg1, nil);
       return old_CIFilter_filterWithName->call(this, arg1);
    }, old_CIFilter_filterWithName);
}

var old_CIFilter_filterWithName_withInputParameters = {};
function hook_CIFilter_filterWithName_withInputParameters() {
    MS.hookMessage(CIFilter->isa, @selector(filterWithName:withInputParameters:), function(arg1, params) {
       NSLog(@"CIFilter filterWithName : %@, %@", arg1, params, nil);
       return old_CIFilter_filterWithName_withInputParameters->call(this, arg1, params);
    }, old_CIFilter_filterWithName_withInputParameters);
}

// - (nullable instancetype)initWithData:(NSData *)data scale:(CGFloat)scale
// - (nullable instancetype)initWithData:(NSData *)data
//var imageOriginInitData;
//function hook_UIImage_initWithData() {var imageOriginInitData = UIImage.prototype['initWithData:'];UIImage.prototype['initWithData:'] = function(arg1) {var path = [new NSString initWithFormat:@"%@/Documents/hookUIImage/%@", NSHomeDirectory(), [new NSUUID init].UUIDString, nil];NSLog(@"UIImage.prototype['initWithData:'] %@", path, nil);[arg1 writeToFile:path atomically:YES]; return imageOriginInitData.call(this, arg1);}}
[[NSFileManager defaultManager] createDirectoryAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/HookImg"] withIntermediateDirectries:YES attributes:nil error:nil]

function hook_UIImage_initWithData() {
    imageOriginInitData = UIImage.prototype['initWithData:'];
    UIImage.prototype['initWithData:'] = function(arg1) {
        var result = imageOriginInitData.call(this, arg1);
        if (result != nil) {
            var path = [new NSString initWithFormat:@"%@/Documents/HookImg/%@", NSHomeDirectory(), [new NSUUID init].UUIDString, nil];
            NSLog(@"UIImage.prototype['initWithData:'] %@", path, nil);
           [arg1 writeToFile:path atomically:YES]; 
	}
        return result;
    }
}
function hook_UIImage_initWithDataScale() {
    imageOriginInitDataScale = UIImage.prototype['initWithData:scale:'];

    UIImage.prototype['initWithData:scale:'] = function(arg1, arg2) {
        var result = imageOriginInitDataScale.call(this, arg1, arg2);
        if (result != nil) {
             var path = [new NSString initWithFormat:@"%@/Documents/HookImg/%@", NSHomeDirectory(), [new NSUUID init].UUIDString, nil];
             NSLog(@"UIImage.prototype['initWithData:scale:'] %@", path, nil);
             [arg1 writeToFile:path atomically:YES]; 
	}
        return result;
    }
}
