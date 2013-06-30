#import "UITextView+APSUIControlTargetAction.h"
#import <objc/runtime.h>

static void *APSUIControlTargetActionEventsTargetActionsMapKey = &APSUIControlTargetActionEventsTargetActionsMapKey;

@implementation UITextView (APSUIControlTargetAction)

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    NSMutableSet *targetActions = self.aps_eventsTargetActionsMap[@(controlEvents)];
    if (targetActions == nil) {
        targetActions = [NSMutableSet set];
        self.aps_eventsTargetActionsMap[@(controlEvents)] = targetActions;
    }
    [targetActions addObject:@{ @"target": target, @"action": NSStringFromSelector(action) }];
}

- (void)removeTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    NSMutableSet *targetActions = self.aps_eventsTargetActionsMap[@(controlEvents)];
    NSDictionary *targetAction = nil;
    for (NSDictionary *ta in targetActions) {
        if (ta[@"target"] == target && [ta[@"action"] isEqualToString:NSStringFromSelector(action)]) {
            targetAction = ta;
            break;
        }
    }
    if (targetAction) {
        [targetActions removeObject:targetAction];
    }
}

- (NSSet *)allTargets
{
    NSMutableSet *targets = [NSMutableSet set];
    [self.aps_eventsTargetActionsMap enumerateKeysAndObjectsUsingBlock:^(id key, NSSet *targetActions, BOOL *stop) {
        for (NSDictionary *ta in targetActions) { [targets addObject:ta[@"target"]]; }
    }];
    return targets;
}

- (UIControlEvents)allControlEvents
{
    NSArray *arrayOfEvents = self.aps_eventsTargetActionsMap.allKeys;
    UIControlEvents allControlEvents = 0;
    for (NSNumber *e in arrayOfEvents) {
        allControlEvents = allControlEvents|e.unsignedIntegerValue;
    };
    return allControlEvents;
}

- (NSArray *)actionsForTarget:(id)target forControlEvent:(UIControlEvents)controlEvent
{
    NSMutableSet *targetActions = [NSMutableSet set];
    for (NSNumber *ce in self.aps_eventsTargetActionsMap.allKeys) {
        if (ce.unsignedIntegerValue & controlEvent) {
            [targetActions addObjectsFromArray:[self.aps_eventsTargetActionsMap[ce] allObjects]];
        }
    }

    NSMutableArray *actions = [NSMutableArray array];
    for (NSDictionary *ta in targetActions) {
        if (ta[@"target"] == target) [actions addObject:ta[@"action"]];
    }

    return actions.count ? actions : nil;
}

- (void)sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event
{
#warning TODO: Implement me
}

- (void)sendActionsForControlEvents:(UIControlEvents)controlEvents
{
#warning TODO: Implement me
}

#pragma mark Private

- (NSMutableDictionary *)aps_eventsTargetActionsMap
{
    NSMutableDictionary *eventsTargetActionsMap = objc_getAssociatedObject(self, APSUIControlTargetActionEventsTargetActionsMapKey);
    if (eventsTargetActionsMap == nil) {
        eventsTargetActionsMap = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(
            self,
            APSUIControlTargetActionEventsTargetActionsMapKey,
            eventsTargetActionsMap,
            OBJC_ASSOCIATION_RETAIN_NONATOMIC
        );
    }
    return eventsTargetActionsMap;
}

@end
