//
//  UIDevice+BMCategory.m
//  BMBasekit
//
//  Created by DennisDeng on 12-1-11.
//  Copyright (c) 2012年 DennisDeng. All rights reserved.
//

#import "UIDevice+BMCategory.h"
#import "NSString+BMCategory.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#include <sys/socket.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <mach/mach.h>

#import "sys/utsname.h"

@implementation UIDevice (BMCategory)

+ (NSString *)bm_deviceModel
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    return deviceModel;
}

+ (NSString *)bm_localizedModel
{
    return [UIDevice currentDevice].localizedModel;
}

+ (NSString *)bm_devicePlatform
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform;
}

+ (NSString *)bm_devicePlatformString
{
    NSString *platform = [self bm_devicePlatform];
    // iPhone
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 2G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4 (GSM)";
    //if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4 (Rev. A)";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"iPhone 4 (CDMA)";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5 (GSM)";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (CDMA)";
    if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone 5C (GSM)";
    if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone 5C (Global)";
    if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5S (GSM)";
    if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5S (Global)";
    if ([platform isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone8,1"])    return @"iPhone 6S";
    if ([platform isEqualToString:@"iPhone8,2"])    return @"iPhone 6S Plus";
    if ([platform isEqualToString:@"iPhone8,3"])    return @"iPhone SE";
    if ([platform isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    if ([platform isEqualToString:@"iPhone9,1"])    return @"iPhone 7";
    if ([platform isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus";
    if ([platform isEqualToString:@"iPhone9,3"])    return @"iPhone 7";
    if ([platform isEqualToString:@"iPhone9,4"])    return @"iPhone 7 Plus";
    if ([platform isEqualToString:@"iPhone10,1"])   return @"iPhone 8";
    if ([platform isEqualToString:@"iPhone10,2"])   return @"iPhone 8 Plus";
    if ([platform isEqualToString:@"iPhone10,3"])   return @"iPhone X";
    if ([platform isEqualToString:@"iPhone10,4"])   return @"iPhone 8";
    if ([platform isEqualToString:@"iPhone10,5"])   return @"iPhone 8 Plus";
    if ([platform isEqualToString:@"iPhone10,6"])   return @"iPhone X";
    if ([platform isEqualToString:@"iPhone11,2"])   return @"iPhone XS";
    if ([platform isEqualToString:@"iPhone11,4"])   return @"iPhone XS MAX";
    if ([platform isEqualToString:@"iPhone11,6"])   return @"iPhone XS MAX";
    if ([platform isEqualToString:@"iPhone11,8"])   return @"iPhone XR";

    // iPod
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    if ([platform isEqualToString:@"iPod7,1"])      return @"iPod Touch 6G";
    // iPad
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad 1";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2 (32nm)";
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (CDMA)";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3 (GSM)";
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4 (GSM)";
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4 (CDMA)";
    if ([platform isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([platform isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([platform isEqualToString:@"iPad4,3"])      return @"iPad Air (China)";
    if ([platform isEqualToString:@"iPad5,3"])      return @"iPad Air 2 (WiFi)";
    if ([platform isEqualToString:@"iPad5,4"])      return @"iPad Air 2 (Cellular)";
    // iPad mini
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad mini (WiFi)";
    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad mini (GSM)";
    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad mini (CDMA)";
    if ([platform isEqualToString:@"iPad4,4"])      return @"iPad mini 2 (WiFi)";
    if ([platform isEqualToString:@"iPad4,5"])      return @"iPad mini 2 (Cellular)";
    if ([platform isEqualToString:@"iPad4,6"])      return @"iPad mini 2 (China)";
    if ([platform isEqualToString:@"iPad4,7"])      return @"iPad mini 3 (WiFi)";
    if ([platform isEqualToString:@"iPad4,8"])      return @"iPad mini 3 (Cellular)";
    if ([platform isEqualToString:@"iPad4,9"])      return @"iPad mini 3 (China)";
    if ([platform isEqualToString:@"iPad5,1"])      return @"iPad mini 4 (WiFi)";
    if ([platform isEqualToString:@"iPad5,2"])      return @"iPad mini 4 (Cellular)";
    // iPad Pro 9.7
    if ([platform isEqualToString:@"iPad6,3"])      return @"iPad Pro 9.7 (WiFi)";
    if ([platform isEqualToString:@"iPad6,4"])      return @"iPad Pro 9.7 (Cellular)";
    // iPad Pro 12.9
    if ([platform isEqualToString:@"iPad6,7"])      return @"iPad Pro 12.9 (WiFi)";
    if ([platform isEqualToString:@"iPad6,8"])      return @"iPad Pro 12.9 (Cellular)";
    // iPad (5th generation)
    if ([platform isEqualToString:@"iPad6,11"])     return @"iPad (5th generation)";
    if ([platform isEqualToString:@"iPad6,12"])     return @"iPad (5th generation)";
    // iPad Pro (12.9-inch, 2nd generation)
    if ([platform isEqualToString:@"iPad7,1"])      return @"iPad Pro (12.9-inch) 2G";
    if ([platform isEqualToString:@"iPad7,2"])      return @"iPad Pro (12.9-inch) 2G";
    // iPad Pro (10.5-inch)
    if ([platform isEqualToString:@"iPad7,3"])      return @"iPad Pro (10.5-inch)";
    if ([platform isEqualToString:@"iPad7,4"])      return @"iPad Pro (10.5-inch)";
    if ([platform isEqualToString:@"iPad7,5"])      return @"iPad 6G";
    if ([platform isEqualToString:@"iPad7,6"])      return @"iPad 6G";

    if ([platform isEqualToString:@"iPad8,1"])      return @"iPad Pro (11-inch)";
    if ([platform isEqualToString:@"iPad8,2"])      return @"iPad Pro (11-inch)";
    if ([platform isEqualToString:@"iPad8,3"])      return @"iPad Pro (11-inch)";
    if ([platform isEqualToString:@"iPad8,4"])      return @"iPad Pro (11-inch)";
    if ([platform isEqualToString:@"iPad8,5"])      return @"iPad Pro (12.9-inch) 3G";
    if ([platform isEqualToString:@"iPad8,6"])      return @"iPad Pro (12.9-inch) 3G";
    if ([platform isEqualToString:@"iPad8,7"])      return @"iPad Pro (12.9-inch) 3G";
    if ([platform isEqualToString:@"iPad8,8"])      return @"iPad Pro (12.9-inch) 3G";
    if ([platform isEqualToString:@"iPad11,1"])     return @"iPad Mini 5G";
    if ([platform isEqualToString:@"iPad11,2"])     return @"iPad Mini 5G";
    if ([platform isEqualToString:@"iPad11,3"])     return @"iPad Air 3G";
    if ([platform isEqualToString:@"iPad11,4"])     return @"iPad Air 3G";

    // Apple TV
    if ([platform isEqualToString:@"AppleTV2,1"])   return @"Apple TV (2nd generation)";
    if ([platform isEqualToString:@"AppleTV3,1"])   return @"Apple TV (3rd generation)";
    if ([platform isEqualToString:@"AppleTV3,2"])   return @"Apple TV (3rd generation)";
    if ([platform isEqualToString:@"AppleTV5,3"])   return @"Apple TV (4th generation)";
    if ([platform isEqualToString:@"AppleTV6,2"])   return @"Apple TV 4K";
    // Apple Watch
    if ([platform isEqualToString:@"Watch1,1"])     return @"Apple Watch (1st generation) 38mm";
    if ([platform isEqualToString:@"Watch1,2"])     return @"Apple Watch (1st generation) 42mm";
    if ([platform isEqualToString:@"Watch2,6"])     return @"Apple Watch Series 1 38mm";
    if ([platform isEqualToString:@"Watch2,7"])     return @"Apple Watch Series 1 42mm";
    if ([platform isEqualToString:@"Watch2,3"])     return @"Apple Watch Series 2 38mm";
    if ([platform isEqualToString:@"Watch2,4"])     return @"Apple Watch Series 2 42mm";
    if ([platform isEqualToString:@"Watch3,1"])     return @"Apple Watch Series 3 38mm";
    if ([platform isEqualToString:@"Watch3,2"])     return @"Apple Watch Series 3 42mm";
    if ([platform isEqualToString:@"Watch3,3"])     return @"Apple Watch Series 3 38mm";
    if ([platform isEqualToString:@"Watch3,4"])     return @"Apple Watch Series 3 42mm";
    // Simulator
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    
    return platform;
}

+ (BOOL)bm_isiPad
{
    if ([[[self bm_devicePlatform] substringToIndex:4] isEqualToString:@"iPad"])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+ (BOOL)bm_isiPhone
{
    if ([[[self bm_devicePlatform] substringToIndex:6] isEqualToString:@"iPhone"])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+ (BOOL)bm_isiPod
{
    if ([[[self bm_devicePlatform] substringToIndex:4] isEqualToString:@"iPod"])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+ (BOOL)bm_isAppleTV
{
    if ([[[self bm_devicePlatform] substringToIndex:7] isEqualToString:@"AppleTV"])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+ (BOOL)bm_isAppleWatch
{
    if ([[[self bm_devicePlatform] substringToIndex:5] isEqualToString:@"Watch"])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+ (BOOL)bm_isSimulator
{
    if ([[self bm_devicePlatform] isEqualToString:@"i386"] || [[self bm_devicePlatform] isEqualToString:@"x86_64"])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+ (BOOL)bm_isRetina
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0 || [UIScreen mainScreen].scale == 3.0))
        return YES;
    else
        return NO;
}

+ (BOOL)bm_isRetinaHD
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 3.0))
        return YES;
    else
        return NO;
}

+ (CGFloat)bm_iOSVersion
{
    static float version;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        version = [UIDevice currentDevice].systemVersion.floatValue;
    });
    return version;
}

+ (NSUInteger)getSysInfo:(uint)typeSpecifier
{
    size_t size = sizeof(int);
    int results;
    int mib[2] = {CTL_HW, typeSpecifier};
    sysctl(mib, 2, &results, &size, NULL, 0);
    return (NSUInteger) results;
}

+ (NSDate *)bm_systemUptime
{
    NSTimeInterval time = [[NSProcessInfo processInfo] systemUptime];
    return [[NSDate alloc] initWithTimeIntervalSinceNow:(0.0f - time)];
}


#pragma mark - CPU

+ (NSString *)bm_cpuType
{
//    host_info_t hostInfo;
    host_basic_info_data_t hostInfo;
    mach_msg_type_number_t infoCount = HOST_BASIC_INFO_COUNT;
    kern_return_t ret = host_info(mach_host_self(), HOST_BASIC_INFO, (host_info_t)&hostInfo, &infoCount);
    NSString *cpuType = @"Unknow";
    if (ret == KERN_SUCCESS)
    {
        switch (hostInfo.cpu_type)
        {
            case CPU_TYPE_ARM:
                cpuType = @"ARM";//armv7 armv7s
                break;
                
            case CPU_TYPE_ARM64:
                cpuType = @"ARM64";
                break;
                
            case CPU_TYPE_X86://CPU_TYPE_I386
                cpuType = @"i386";
                break;
                
            case CPU_TYPE_X86_64:
                cpuType = @"X86_64";
                break;
                
            default:
                break;
        }
    }
    
    return cpuType;
}

+ (CGFloat)bm_cpuUsage
{
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
    
    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {
        return -1.0f;
    }
    
    task_basic_info_t      basic_info;
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
    
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
    
    thread_basic_info_t basic_info_th;
    uint32_t stat_thread = 0; // Mach threads
    
    basic_info = (task_basic_info_t)tinfo;
    
        // get threads in the task
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1.0f;
    }
    if (thread_count > 0)
        stat_thread += thread_count;
    
    long tot_sec = 0;
    long tot_usec = 0;
    float tot_cpu = 0;
    int j;
    
    for (j = 0; j < thread_count; j++) {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1.0f;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->user_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }
    } // for each thread
    
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
    NSInteger cpuCount = [UIDevice bm_cpuNumber];
    CGFloat useage_cpu = tot_cpu / cpuCount;
    return useage_cpu;
}

+ (NSUInteger)bm_cpuFrequency
{
    return [self getSysInfo:HW_CPU_FREQ];
}

+ (NSUInteger)bm_busFrequency
{
    return [self getSysInfo:HW_TB_FREQ];
}

+ (NSUInteger)bm_ramSize
{
    return [self getSysInfo:HW_MEMSIZE];
}

+ (NSUInteger)bm_cpuNumber
{
    return [self getSysInfo:HW_NCPU];
}

+ (NSUInteger)bm_cpuAvailableCount
{
    return [self getSysInfo:HW_AVAILCPU];
}


#pragma mark - Memory

+ (NSUInteger)bm_totalMemory
{
    return [self getSysInfo:HW_PHYSMEM];
}

+ (NSUInteger)bm_userMemory
{
    return [self getSysInfo:HW_USERMEM];
}

+ (NSUInteger)bm_freeMemory
{
    return ([self getSysInfo:HW_PHYSMEM] - [self getSysInfo:HW_USERMEM]);
}

+ (NSUInteger)bm_maxSocketBufferSize
{
    return [self getSysInfo:KIPC_MAXSOCKBUF];
}

+ (int64_t)bm_activeMemory
{
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t page_size;
    vm_statistics_data_t vm_stat;
    kern_return_t kern;
    
    kern = host_page_size(host_port, &page_size);
    if (kern != KERN_SUCCESS) return -1;
    kern = host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size);
    if (kern != KERN_SUCCESS) return -1;
    return vm_stat.active_count * page_size;
}

+ (int64_t)bm_inActiveMemory
{
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t page_size;
    vm_statistics_data_t vm_stat;
    kern_return_t kern;
    
    kern = host_page_size(host_port, &page_size);
    if (kern != KERN_SUCCESS) return -1;
    kern = host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size);
    if (kern != KERN_SUCCESS) return -1;
    return vm_stat.inactive_count * page_size;
}

+ (int64_t)bm_wiredMemory
{
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t page_size;
    vm_statistics_data_t vm_stat;
    kern_return_t kern;
    
    kern = host_page_size(host_port, &page_size);
    if (kern != KERN_SUCCESS) return -1;
    kern = host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size);
    if (kern != KERN_SUCCESS) return -1;
    return vm_stat.wire_count * page_size;
}

+ (int64_t)bm_purgableMemory
{
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t page_size;
    vm_statistics_data_t vm_stat;
    kern_return_t kern;
    
    kern = host_page_size(host_port, &page_size);
    if (kern != KERN_SUCCESS) return -1;
    kern = host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size);
    if (kern != KERN_SUCCESS) return -1;
    return vm_stat.purgeable_count * page_size;
}


#pragma mark - Disk

+ (NSString *)bm_applicationSize
{
    unsigned long long documentSize = [NSString bm_sizeOfFolder:[NSString bm_documentsPath]];
    unsigned long long librarySize = [NSString bm_sizeOfFolder:[NSString bm_libraryPath]];
    unsigned long long cacheSize = [NSString bm_sizeOfFolder:[NSString bm_cachesPath]];
    
    unsigned long long total = documentSize + librarySize + cacheSize;
    
    NSString *applicationSize = [NSByteCountFormatter stringFromByteCount:total countStyle:NSByteCountFormatterCountStyleFile];
    return applicationSize;
}

+ (NSNumber *)bm_totalDiskSpace
{
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [attributes objectForKey:NSFileSystemSize];
}

+ (NSString *)bm_totalDiskSpaceString
{
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    float totalSpace = [[attributes objectForKey:NSFileSystemSize] floatValue];
    return [NSString bm_storeStringWithBitSize:totalSpace];
}

+ (NSNumber *)bm_usedDiskSpace
{
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    float totalSpace = [[attributes objectForKey:NSFileSystemSize] floatValue];
    float freeSpace = [[attributes objectForKey:NSFileSystemFreeSize] floatValue];
    float usedSpace = totalSpace - freeSpace;
    
    return [NSNumber numberWithFloat:usedSpace];
}

+ (NSString *)bm_usedDiskSpaceString
{
    // 通过NSFileManager所有信息
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    float totalSpace = [[attributes objectForKey:NSFileSystemSize] floatValue];
    float freeSpace = [[attributes objectForKey:NSFileSystemFreeSize] floatValue];
    float usedSpace = totalSpace - freeSpace;
    return [NSString bm_storeStringWithBitSize:usedSpace];
}

+ (NSNumber *)bm_freeDiskSpace
{
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [attributes objectForKey:NSFileSystemFreeSize];
}

+ (NSString *)bm_freeDiskSpaceString
{
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    float freeSpace = [[attributes objectForKey:NSFileSystemFreeSize] floatValue];
    return [NSString bm_storeStringWithBitSize:freeSpace];
}

+ (NSString *)bm_deviceName
{
    return [UIDevice currentDevice].name;
}

+ (NSString *)bm_OSVersion
{
    return [UIDevice currentDevice].systemVersion;
}

+ (BOOL)bm_isMultitaskingSupported
{
    return [[UIDevice currentDevice] isMultitaskingSupported];
}

+ (BOOL)bm_hasJailBroken
{
#if !(TARGET_IPHONE_SIMULATOR)
    // Check 1 : existence of files that are common for jailbroken devices
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Applications/Cydia.app"] ||
        [[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/MobileSubstrate.dylib"] ||
        [[NSFileManager defaultManager] fileExistsAtPath:@"/bin/bash"] ||
        [[NSFileManager defaultManager] fileExistsAtPath:@"/usr/sbin/sshd"] ||
        [[NSFileManager defaultManager] fileExistsAtPath:@"/private/var/lib/apt/"] ||
        [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://package/com.example.package"]])
    {
        return YES;
    }
    
    FILE *f = NULL ;
    if ((f = fopen("/bin/bash", "r")) ||
        (f = fopen("/Applications/Cydia.app", "r")) ||
        (f = fopen("/Library/MobileSubstrate/MobileSubstrate.dylib", "r")) ||
        (f = fopen("/usr/sbin/sshd", "r")) ||
        (f = fopen("/etc/apt", "r")))
    {
        fclose(f);
        return YES;
    }
    fclose(f);
    // Check 2 : Reading and writing in system directories (sandbox violation)
    NSError *error;
    NSString *stringToBeWritten = @"Jailbreak Test.";
    [stringToBeWritten writeToFile:@"/private/jailbreak.txt" atomically:YES
                          encoding:NSUTF8StringEncoding error:&error];
    if (error == nil)
    {
        //Device is jailbroken
        return YES;
    }
    else
    {
        [[NSFileManager defaultManager] removeItemAtPath:@"/private/jailbreak.txt" error:nil];
    }
#endif
    return NO;
}

@end
