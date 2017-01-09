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


var gx_spaceNumPerDepth = 4;

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
- gx_printViewControllerDesc:(int)depth {
    //var self = this;
    var str = [NSMutableString stringWithFormat:@"%*s[#%p %@]", depth*gx_spaceNumPerDepth, "", self, NSStringFromClass([self class])];
    if ([[self childViewControllers] count] > 0) {
        if ([self isKindOfClass:[UITabBarController class]]) {
            [str appendFormat:@", selIndex=%tu, childs:", [self selectedIndex]];
        } else {
            [str appendFormat:@", childs:"];
        }
        
        for (var i = 0; i < [[self childViewControllers] count]; ++i) {
            var child = [self childViewControllers][i];
            [str appendFormat:@"\n%@", [child gx_printViewControllerDesc:(depth+1)]];
        }
    }
    return str;
}
- gx_printViewControllerDesc {
    return [self gx_printViewControllerDesc:0];
}
@end
	      
function gx_printViewControllerList(window) {
    window = window != nil ? window : [[[UIApplication sharedApplication] delegate] window];
    window = window != nil ? window : [[UIApplication sharedApplication] keyWindow];
    window = window != nil ? window : [[[UIApplication sharedApplication] windows] firstObject];
    
    var controller = [window rootViewController];
    return [controller gx_printViewControllerDesc];
}

//
//
//
// GPUImageOutput filter chain
//
@implementation GPUImageOutput (ChildShow)
- gx_FilterDescInternal {
    return [NSString stringWithFormat:@"%@:%p", NSStringFromClass([self class]), self];
}

- gx_printFilterList:(NSMutableString *)string depth:(int)depth {
    string = string != nil ? string : [NSMutableString string];
    [string appendFormat:@"%*s{", depth * gx_spaceNumPerDepth, ""];
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
                    [string appendFormat:@"%*s{%@:%p},", (depth+1) * gx_spaceNumPerDepth, "", NSStringFromClass([subTar class]), subTar];
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
