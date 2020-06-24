//
//  YSRoomModel.h
//  YSRoomSDK
//
//  Created by jiang deng on 2020/5/18.
//  Copyright © 2020 Road of Cloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YSRoomModel : NSObject

/// 当前用户进入房间的角色
@property (nonatomic, assign) YSUserRoleType roomrole;
/// 当前用户自定义的ID
@property (nonatomic, strong) NSString *thirdid;

/// 公司ID
@property (nonatomic, strong) NSString *companyid;
/// 房间ID 同serial
@property (nonatomic, strong) NSString *roomid;

/// 房间使用场景  3：小班课  4：直播   6：会议
@property (nonatomic, assign) YSRoomUseType roomtype;

/// 房间类型 0:表示一对一教室  1:表示一对多教室 roomusertype目前返回值不正确，使用maxvideo去判断
@property (nonatomic, assign, readonly) YSRoomUserType roomUserType;

/// 房间logo
@property (nonatomic, strong) NSString *classroomlogo;
/// 房间名称
@property (nonatomic, strong) NSString *roomname;


/// 房间最大视频数
@property (nonatomic, assign) NSUInteger maxvideo;
/// 视频类型
@property (nonatomic, assign) NSUInteger videotype;
/// 房间最大分辨率 视频宽
@property (nonatomic, assign) NSUInteger videowidth;
/// 房间最大分辨率 视频高
@property (nonatomic, assign) NSUInteger videoheight;

/// 视频编码格式 integer
@property (nonatomic, strong) NSString *vcodec;


/// 房间最大分辨率 视频fps
@property (nonatomic, assign) NSUInteger videoframerate;
/// 高清音质参数
@property (nonatomic, assign) NSUInteger audiobitrate;

/// 房间文档服务器地址
@property (nonatomic, strong) NSString *ClassDocServerAddr;
/// 当前连接的服务器
@property (nonatomic, strong) NSString *currentServer;

/// 房间配置项
@property (nonatomic, strong) NSString *chairmancontrol;

+ (instancetype)roomModelWithDic:(NSDictionary *)dic;
- (void)updateWithDic:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END




# if 0
Printing description of response:
{
    ClassDocServerAddr = "rddoccdndemows.roadofcloud.net";
    ClassDocServerAddrBackup = "rddocdemo.roadofcloud.net";
    DocServerAddrBackup = ".roadofcloud.net";
    LiveDocServerAddr = "rddoccdndemows.roadofcloud.net";
    LiveDocServerAddrBackup = "demo.roadofcloud.net";
    RecordFilepath = "/uploadrecord/";
    backcourseaddr =     (
    );
    helpcallbackurl = "";
    httpport = 80;
    httpsport = 443;
    ipinfo =     {
        area = "\U5317\U4eac";
        city = "\U5317\U4eac";
        country = "\U4e2d\U56fd";
        perators = "\U7535\U4fe1";
        selfip = "103.219.187.51";
    };
    newcourseaddr =     (
                {
            change = "";
            docaddr =             (
                "rddocdemo.roadofcloud.net"
            );
            name = demo;
            signaladdr = "demo1.roadofcloud.net";
            signalport = 8889;
            webaddr = "demo.roadofcloud.net";
        },
                {
            change = "";
            docaddr =             (
                "rddocdemo.roadofcloud.net"
            );
            name = "demoweb-fc-api";
            signaladdr = "demoweb-fc-api1.roadofcloud.net";
            signalport = 8889;
            webaddr = "demoweb-fc-api.roadofcloud.net";
        }
    );
    nickname = iPad;
    realpoint = 1000;
    realsilentpoint = 100;
    result = 0;
    room =     {
        allowchild = 0;
        audiomode = 42;
        barrage = 0;
        begintime = "";
        chairmancontrol = 111100000010000000000000000000000101001100011000101011000001011111111110100000000100100000000000010000001000101000001001000001000001000000010000101000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
        chairmanfunc = 11100;
        classroomlogo = "";
        colourid = 0;
        companyid = 10099;
        companyidentify = 1;
        confusernum = "-1";
        createtime = 1589787267;
        "door_chain" = "";
        duration = "";
        endtime = 1621323242;
        firstname = admin;
        foregroundpic = "";
        icoaddr = "";
        iscontrol = 0;
        ismodifysetting = 1;
        isregisteruser = 0;
        istemplate = 0;
        linkname = "";
        linkurl = "";
        livebypass = 0;
        liverecordtype = "<null>";
        localrecordtype = mp3;
        loginpattern = 0;
        maxaudio = 9;
        maxvideo = 13;
        networkbandwidth = 0;
        newendtime = "2021-05-18 15:34:02";
        newstarttime = "2020-05-18 15:34:27";
        notifystatus = 0;
        passwordrequired = 0;
        phoneusernum = 0;
        producttype = 0;
        pullid = "";
        pushflowaddr = "";
        recorduploadaddr = "";
        robotnum = 0;
        robotprop = "";
        roomlabel = 0;
        roomlayout = 0;
        roomname = "! V N";
        roomstate = 0;
        roomsubject = "";
        roomtype = 3;
        roomusertype = 00;
        savechat = 0;
        saveqa = 0;
        scheduleinfo = "";
        serial = 365612379;
        sharedesk = 1;
        sharemedia = 0;
        sidelineusernum = "-1";
        sideuserdelaytime = 0;
        skinId = default;
        skinResource = "";
        skinid = "<null>";
        speakerinfo = "";
        starttime = 1589787267;
        studentvideoheight = 240;
        studentvideotype = 1;
        studentvideowidth = 320;
        thirdroomid = "";
        tplId = default;
        trophy = "<null>";
        userid = 130584;
        vcodec = 0;
        version = 12777;
        videoencode = 0;
        videoframerate = 10;
        videoheight = 240;
        videotype = 1;
        videowidth = 320;
        visibleroom = 0;
        voicefile = "";
        welcomepage = 0;
        whiteboardcolor = 1;
    };
    roomrole = 0;
    roomuser =     (
                {
            account = admin;
            email = "123@qq.com";
            firstname = admin;
            receiptflag = 1;
            receiveid = 130584;
            sendflag = 1;
            sendid = 130584;
            serial = 365612379;
            state = 0;
            version = 12777;
        }
    );
    serial = 365612379;
    studentvideotype = "";
    thirdid = "";
    urlhead = demo;
    videotype = "";
}
#endif
