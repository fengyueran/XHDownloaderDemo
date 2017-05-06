//
//  XHMediaFile.m
//  XHDownloaderDemo
//
//  Created by xinghun meng on 03/05/2017.
//  Copyright © 2017 xinghun meng. All rights reserved.
//

#import "XHMediaFile.h"

@implementation XHMediaFile

- (void)setState:(MediaFileState)state {
    _state = state;
    _stateBlock(_state);
    
}

- (NSDictionary*) toDictionary {
    NSMutableDictionary* dict = [NSMutableDictionary new];
    dict[@"ID"] = self.ID;
//    dict[@"name"] = self.name;
    dict[@"addDate"] = [self stringFromDate:self.addDate];
    dict[@"totalSize"] = [[NSNumber alloc] initWithLongLong:self.totalLength];
    dict[@"downloadedBytes"] = [[NSNumber alloc] initWithLongLong:self.downloadedBytes];
    dict[@"progress"] = [[NSNumber alloc] initWithFloat:self.progress];
    dict[@"completed"] = [[NSNumber alloc] initWithBool:self.completed];
    dict[@"url"] = self.url;

    return dict;
}

- (NSString*)stringFromDate:(NSDate*)date  {
    NSDateFormatter *DATEFORMATER = [[NSDateFormatter alloc]init];
    [DATEFORMATER setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'"];
    [DATEFORMATER setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    return [DATEFORMATER stringFromDate:date];
}

- (NSDictionary*) getJSONObject {
    NSMutableDictionary* dict = [NSMutableDictionary new];
    [dict setObject:[self toDictionary] forKey:@"info"];
    return dict;
}

@end
