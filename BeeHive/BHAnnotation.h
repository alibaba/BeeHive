//
//  BHAnnotation.h
//  Pods
//
//  Created by 寻峰 on 2016/11/5.
//
//

#import <Foundation/Foundation.h>

#ifndef BeehiveModSectName

#define BeehiveModSectName "BeehiveMods"

#endif

#ifndef BeehiveServiceSectName

#define BeehiveServiceSectName "BeehiveServices"

#endif


#define BeeHiveDATA(sectname) __attribute((used, section("__DATA,"#sectname" ")))



#define BeeHiveMod(name) \
char * k##name##_mod BeeHiveDATA(BeehiveMods) = ""#name"";

#define BeeHiveService(servicename,impl) \
char * k##servicename##_service BeeHiveDATA(BeehiveServices) = "{ \""#servicename"\" : \""#impl"\"}";

@interface BHAnnotation : NSObject

+ (NSArray<NSString *> *)AnnotationModules;
+ (NSArray<NSString *> *)AnnotationServices;

@end
