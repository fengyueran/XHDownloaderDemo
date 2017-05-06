//
//  db.m
//  Sample
//
//  Created by lining on 08/12/2016.
//  Copyright © 2016 CyberyTech. All rights reserved.
//

#import "XHMediaDB.h"
#import "XHFileManager.h"
#import "XHMediaFile.h"

@interface XHMediaDB()

@property (nonatomic, strong) NSString* pathRoot;
@property (nonatomic, strong) XHFileManager* projectProvider;
@property (nonatomic, strong) NSMutableDictionary* fileProviders;

@end

@implementation XHMediaDB

- (instancetype)init {
    self = [super init];
    [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(doSave) userInfo:nil repeats:YES];
    self.fileProviders = [NSMutableDictionary new];
    return self;
}

- (id)initWithPathRoot:(NSString *)pathRoot {
	self = [self init];
	self.pathRoot =  pathRoot;
	return self;
}


- (NSDictionary*)loadProject {
	NSInputStream* stream = [NSInputStream inputStreamWithFileAtPath:[self filesPath]];
	NSError* error = nil;
	[stream open];
	NSDictionary* json = [NSJSONSerialization JSONObjectWithStream: stream options:NSJSONReadingMutableContainers error: &error];
	NSLog(@"%@", json);
    [stream close];
	if (json == nil) {
		return [NSDictionary new];
	}
	return json;
}

- (NSString *)filesPath {
    return [self.pathRoot stringByAppendingPathComponent:@"files.json"];
}
- (void)saveProject:(XHFileManager *) mm {
    self.projectProvider = mm;
}

- (void)saveFile:(XHMediaFile*) mf {
    self.fileProviders[mf.ID] = mf;
}

- (NSDictionary*)loadFile:(NSString*)ID {
    NSString* infoPath = [self.pathRoot stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json", ID]];
    NSInputStream* stream = [NSInputStream inputStreamWithFileAtPath:infoPath];
    NSError* error = nil;
    [stream open];
    NSDictionary* json = [NSJSONSerialization JSONObjectWithStream: stream options:NSJSONReadingMutableContainers error: &error];
    NSLog(@"%@", json);
    [stream close];
    return json;
}

- (void) doSave {
    for (NSString* ID in self.fileProviders) {
        XHMediaFile* provider = self.fileProviders[ID];
        NSString* infoPath = [self.pathRoot stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json", ID]];
        NSOutputStream* stream = [NSOutputStream outputStreamToFileAtPath:infoPath append:NO];
        [stream open];
        NSError* error = NULL;
//        if (self.projectProvider != nil && [self.projectProvider getMediaByID:ID] == nil) {
//            continue;
//        }
        [NSJSONSerialization writeJSONObject:[provider getJSONObject] toStream:stream options:NSJSONWritingPrettyPrinted error:&error];
        [stream close];
    }
    self.fileProviders = [NSMutableDictionary new];

    if (self.projectProvider != nil) {
        NSOutputStream *stream = [NSOutputStream outputStreamToFileAtPath:[self filesPath] append:NO];
        [stream open];
        NSError* error = NULL;
        [NSJSONSerialization writeJSONObject:[self.projectProvider getJSONObject] toStream:stream options:NSJSONWritingPrettyPrinted error:&error];
        [stream close];
        self.projectProvider = nil;
    }
}

- (void)forceSaveAll {
    [self doSave];
}

@end
