//
//  db.h
//  Sample
//
//  Created by lining on 08/12/2016.
//  Copyright © 2016 CyberyTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XHMediaFile;
@class XHFileManager;

@interface XHMediaDB : NSObject

- (id)initWithPathRoot:(NSString *)pathRoot;
- (NSDictionary*)loadProject;
- (void)saveProject:(XHFileManager*)mm;
- (void)saveFile:(XHMediaFile*)mf;
- (NSDictionary*)loadFile:(NSString*)ID;
- (void)forceSaveAll;
- (void)cleanByID:(NSString*)ID;
- (void)cleanAll;

@end
