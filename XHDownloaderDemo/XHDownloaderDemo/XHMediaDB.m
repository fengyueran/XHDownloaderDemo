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
    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(doSave) userInfo:nil repeats:YES];
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
	
    [stream close];
	if (json == nil) {
		return [NSDictionary new];
    } else {
        NSLog(@"%@", json);
    }
	return json;
}

- (NSString *)filesPath {
    return [self.pathRoot stringByAppendingPathComponent:@"files.json"];
}

- (NSString *)fileInfoWithID:(NSString *)ID {
    return [self.pathRoot stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json", ID]];
}

- (void)saveProject:(XHFileManager *) mm {
    self.projectProvider = mm;
}

- (void)saveFile:(XHMediaFile*) mf {
    self.fileProviders[mf.ID] = mf;
}

- (NSDictionary*)loadFile:(NSString*)ID {
    NSInputStream* stream = [NSInputStream inputStreamWithFileAtPath:[self fileInfoWithID:ID]];
    NSError* error = nil;
    [stream open];
    NSDictionary* json = [NSJSONSerialization JSONObjectWithStream: stream options:NSJSONReadingMutableContainers error: &error];
    NSLog(@"%@", json);
    [stream close];
    return json;
}

- (void) doSave {
    NSMutableDictionary* fileProviders = [self.fileProviders mutableCopy];
    for (NSString* ID in fileProviders) {
        XHMediaFile* provider = self.fileProviders[ID];
        NSOutputStream* stream = [NSOutputStream outputStreamToFileAtPath:[self fileInfoWithID:ID] append:NO];
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

- (void)cleanByID:(NSString*)ID {
    NSFileManager *fm = [NSFileManager new];
    [fm removeItemAtPath:[self fileInfoWithID:ID] error:nil];
    NSString *filePath = [self.pathRoot stringByAppendingPathComponent:ID];
    [fm removeItemAtPath:filePath error:nil];
    [self doSave];
}
@end
