//#!usr/bin/cycript

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



function gx_printMethods(classObj, fileName, showLog) {
    var string = [new NSMutableString init];
    var count = new new Type("I");
    var methods = class_copyMethodList(classObj, count);
    for(var i = 0; i < *count; i++) {
        var method = methods[i];
        if (method != NULL) {
           [string appendFormat:@"{selector:%s, imp:%p}\n", method_getName(method), method_getImplementation(method), nil];
        }
    }
    free(methods);
    return string;
}

function gx_printView(window, fileName, showLog) {
    window = window != nil ? window : [[[UIApplication sharedApplication] delegate] window];
    window = window != nil ? window : [[UIApplication sharedApplication] keyWindow];
    window = window != nil ? window : [[[UIApplication sharedApplication] windows] firstObject];
    var recursivStr = window.recursiveDescription();
    if (recursivStr && [recursivStr length] > 0 && fileName != nil && [fileName length] > 0) {
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

function gx_printAllSubClassOfClass2(superClass) {
    //var numClasses = objc_getClassList(NULL, 0);
    //var classSize = 8;//is64Bit() ? 8 : 4;
    //var pclasses = malloc(classSize * numClasses);
    //if (pclasses == NULL) return nil;
    //memset(pclasses, 0, classSize * numClasses)
    //numClasses = objc_getClassList(pclasses, numClasses);
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
    //var self = this;
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
+ gx_printViewControllerList:(UIWindow *)window {
    return gx_printViewControllerList(window);
}
@end
	      
function gx_printViewControllerList(window) {
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


var gx_cacheImagePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/HookImg"];
[[NSFileManager defaultManager] createDirectoryAtPath:gx_cacheImagePath withIntermediateDirectories:YES attributes:nil error:nil];
// - (nullable instancetype)initWithData:(NSData *)data scale:(CGFloat)scale
// - (nullable instancetype)initWithData:(NSData *)data
// var imageOriginInitData;
// function hook_UIImage_initWithData() {var imageOriginInitData = UIImage.prototype['initWithData:'];UIImage.prototype['initWithData:'] = function(arg1) {var path = [new NSString initWithFormat:@"%@/%@", gx_cacheImagePath, [new NSUUID init].UUIDString, nil];NSLog(@"UIImage.prototype['initWithData:'] %@", path, nil);[arg1 writeToFile:path atomically:YES]; return imageOriginInitData.call(this, arg1);}}
function gx_hook_UIImage_initWithData() {
    imageOriginInitData = UIImage.prototype['initWithData:'];
    UIImage.prototype['initWithData:'] = function(arg1) {
        var result = imageOriginInitData.call(this, arg1);
        if (result != nil) {
            var path = [new NSString initWithFormat:@"%@/%@", gx_cacheImagePath, [new NSUUID init].UUIDString, nil];
            NSLog(@"UIImage.prototype['initWithData:'] %@", path, nil);
            [arg1 writeToFile:path atomically:YES]; 
        }
        return result;
    }
}

// - (nullable instancetype)initWithData:(NSData *)data scale:(CGFloat)scale
function gx_hook_UIImage_initWithDataScale() {
    imageOriginInitDataScale = UIImage.prototype['initWithData:scale:'];
    UIImage.prototype['initWithData:scale:'] = function(arg1, arg2) {
        var result = imageOriginInitDataScale.call(this, arg1, arg2);
        if (result != nil) {
             var path = [new NSString initWithFormat:@"%@/%@", gx_cacheImagePath, [new NSUUID init].UUIDString, nil];
             NSLog(@"UIImage.prototype['initWithData:scale:'] %@", path, nil);
             [arg1 writeToFile:path atomically:YES]; 
        }
        return result;
    }
}
		   
// NSData  initWithContentsOfFile:(NSString *)path options:(NSDataReadingOptions)readOptionsMask error:(NSError **)errorPtr
function gx_hook_NSData_initWithContentsOfFileOptionError() {
    dataOriginInitFileOptionError = NSData.prototype['initWithContentsOfFile:options:error:'];
    NSData.prototype['initWithContentsOfFile:options:error:'] = function(arg1, arg2, arg3) {
        var result = dataOriginInitFileOptionError.call(this, arg1, arg2, arg3);
        if (result != nil) {
             NSLog(@"NSData.prototype['initWithContentsOfFile:options:error:'] %@", arg1, nil);
        }
        return result;
    }
}
function gx_hook_NSData_initWithContentsOfFile() {
    dataOriginInitFile = NSData.prototype['initWithContentsOfFile:'];
    NSData.prototype['initWithContentsOfFile:'] = function(arg1) {
        var result = dataOriginInitFile.call(this, arg1);
        if (result != nil) {
             NSLog(@"NSData.prototype['initWithContentsOfFile:'] %@", arg1, nil);
        }
        return result;
    }
}

@implementation GPUImageOutput (ChildShow)
- gx_FilterDescInternal {
    return [NSString stringWithFormat:@"%@:%p", NSStringFromClass([self class]), self];
}
- gx_printFilterList:(NSMutableString *)string depth:(int)depth {
    var spaceNumPerDepth = 4;
    string = string != nil ? string : [NSMutableString string];
    [string appendFormat:@"%*s{", depth * spaceNumPerDepth, ""];
    [string appendFormat:@"%@", [self gx_FilterDescInternal]];
    
    if ([self isKindOfClass:[GPUImageFilterGroup class]]) {
        var subfilters = [self valueForKey:@"filters"];
        if (subfilters != nil && [subfilters count] > 0) {
            [string appendFormat:@" = ["];
            for (var i = 0; i < [subfilters count]; ++i) {
                [string appendFormat:@" {%@}, ", [subfilters[i] gx_FilterDescInternal]];
            }
            [string appendFormat:@"]"];
        }
    }
    [string appendFormat:@"};"];
    
    if ([self isKindOfClass:[GPUImageOutput class]]) {
        var target = [self targets];
        if (target != nil && [target count] > 0) {
            [string appendFormat:@" targets=>\n"];
            for (var i = 0; i < [target count]; ++i) {
                var subTar = target[i];
                if ([subTar isKindOfClass:[GPUImageOutput class]]) {
                    [subTar gx_printFilterList:string depth:(depth+1)];
                } else {
                    [string appendFormat:@"%*s{%@:%p},", (depth+1) * spaceNumPerDepth, "", NSStringFromClass([subTar class]), subTar];
                }
            }
        } else {
            [string appendFormat:@"\n"];
	}
    } else {
        [string appendFormat:@"\n"];
    }
    return string;
}
- gx_printFilterList {
    return [self gx_printFilterList:nil depth:0];
}
@end

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
	      
// GPUImagePicture
// - (id)initWithCGImage:(CGImageRef)newImageSource smoothlyScaleOutput:(BOOL)smoothlyScaleOutput removePremultiplication:(BOOL)removePremultiplication
function gx_hook_GPUImagePicture_initWithCGImage() {
    filterOriginSetTexture = GPUImageFilter.prototype['initWithCGImage:smoothlyScaleOutput:removePremultiplication:'];
    GPUImageFilter.prototype['initWithCGImage:smoothlyScaleOutput:removePremultiplication:'] = function(arg1, arg2, arg3) {
        filterOriginSetTexture.call(this, arg1, arg2, arg3);
        if (arg1 != nil) {
            var path = [new NSString initWithFormat:@"%@/%@_%@.png", gx_cacheImagePath, NSStringFromClass(this), [NSDate date], nil];
            [UIImagePNGRepresentation(arg1) writeToFile:path atomically:YES]
        }
    }
}
	    
//
function gx_hook_GPUImageFilter_setInputTexture() {
    filterOriginSetTexture = GPUImageFilter.prototype['setInputTextureformImage:atIndex:'];
    GPUImageFilter.prototype['setInputTextureformImage:atIndex:'] = function(arg1, arg2) {
        filterOriginSetTexture.call(this, arg1, arg2);
        if (arg1 != nil) {
            var path = [new NSString initWithFormat:@"%@/%@_%zi_%@.png", gx_cacheImagePath, NSStringFromClass(this), arg2, [NSDate date], nil];
            [UIImagePNGRepresentation(arg1) writeToFile:path atomically:YES]
        }
    }
}
	    

