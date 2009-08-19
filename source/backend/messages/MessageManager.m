//
//  MessageManager.m
//  Facebook
//
//  Created by Lee Byron on 8/13/09.
//  Copyright 2009 Facebook. All rights reserved.
//

#import "MessageManager.h"
#import "FBMessage.h"

@implementation MessageManager

@synthesize allMessages, unreadMessages;

-(id)init
{
  self = [super init];
  if (self) {
    allDict = [[NSMutableDictionary alloc] init];
    allMessages = [[NSMutableArray alloc] init];
    unreadMessages = [[NSMutableArray alloc] init];
    mostRecentUpdateTime = 0;
  }
  return self;
}

- (void)dealloc
{
  [allDict release];
  [allMessages release];
  [unreadMessages release];
  [super dealloc];
}

-(NSArray *)addMessagesFromXML:(NSXMLNode *)xml
{
  // remember the new messages
  NSMutableArray *newMessages = [[[NSMutableArray alloc] init] autorelease];

  for (NSXMLNode *node in [xml children]) {
    FBMessage *message = [FBMessage messageWithXMLNode:node manager:self];

    NSString *threadID = [message objForKey:@"threadId"];
    FBMessage *existingMessage = [allDict objectForKey:threadID];

    if (existingMessage) {
      if (![[existingMessage objForKey:@"updatedTime"] isEqual:[message objForKey:@"updatedTime"]]) {
        [newMessages addObject:message];
      }
      [allMessages removeObject:existingMessage];
      if ([existingMessage boolForKey:@"unread"]) {
        [unreadMessages removeObject:existingMessage];
      }
      [allDict removeObjectForKey:threadID];
    } else {
      [newMessages addObject:message];
    }

    [allDict setObject:message forKey:threadID];
    [allMessages addObject:message];
    if ([message boolForKey:@"unread"]) {
      [unreadMessages addObject:message];
    }

    // TODO: at this point we need to sort allMessages

    // update most recent time
    mostRecentUpdateTime = MAX(mostRecentUpdateTime,
                               [[message objForKey:@"updatedTime"] intValue]);
  }
  return newMessages;
}

-(int)unreadCount {
  return [unreadMessages count];
}

-(int)mostRecentUpdateTime {
  return mostRecentUpdateTime;
}

@end