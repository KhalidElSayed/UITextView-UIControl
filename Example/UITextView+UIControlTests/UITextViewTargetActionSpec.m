#import <Kiwi/Kiwi.h>
#import <UITextView+UIControl/UITextView+APSUIControlTargetAction.h>

@interface TestTarget : NSObject
- (void)testAction:(id)sender;
@end
@implementation TestTarget
- (void)testAction:(id)sender { /* noop */ }
@end

SPEC_BEGIN(UITextViewTargetActionSpec)

describe(@"UITextView+APSUIControlTargetAction", ^{

    __block UITextView *textView;

    beforeEach(^{
        textView = [[UITextView alloc] initWithFrame:CGRectZero];
        [UIApplication.sharedApplication.delegate.window addSubview:textView];
    });

    it(@"responds to adding a target-action pair", ^{
        [[textView should] respondToSelector:@selector(addTarget:action:forControlEvents:)];
    });

    it(@"responds to removing a target-action pair", ^{
        [[textView should] respondToSelector:@selector(removeTarget:action:forControlEvents:)];
    });

    it(@"starts with zero targets", ^{
        [[textView.allTargets shouldNot] beNil];
        [[textView.allTargets should] beEmpty];
    });

    it(@"tracks the targets", ^{
        id target = [NSObject new];
        [textView addTarget:target action:@selector(doesNotMatter:) forControlEvents:UIControlEventEditingDidEnd];
        [[textView.allTargets should] contain:target];
    });

    it(@"starts with zero associated control events", ^{
        [[theValue(textView.allControlEvents) should] beZero];
    });

    it(@"tracks the associated control events", ^{
        id target = [NSObject new];
        [textView addTarget:target action:@selector(doesNotMatter:) forControlEvents:UIControlEventEditingDidEnd];
        [[theValue(textView.allControlEvents) should] equal:theValue(UIControlEventEditingDidEnd)];
    });

    it(@"tracks all actions for an associated target and control event", ^{
        id target = [NSObject new];
        [[[textView actionsForTarget:target forControlEvent:UIControlEventEditingDidBegin] should] beNil];

        [textView addTarget:target action:@selector(verySpecialAction:) forControlEvents:UIControlEventEditingChanged];

        NSArray *actions = [textView actionsForTarget:target forControlEvent:UIControlEventEditingChanged];
        [[actions shouldNot] beNil];
        [[actions should] equal:@[ @"verySpecialAction:" ]];
    });

    it(@"removes an associated target-action pair", ^{
        id target = [NSObject new];

        [textView addTarget:target action:@selector(verySpecialAction:) forControlEvents:UIControlEventEditingChanged];
        [[textView.allTargets should] contain:target];
        NSArray *actions = [textView actionsForTarget:target forControlEvent:UIControlEventEditingChanged];
        [[actions should] haveCountOf:1];

        [textView removeTarget:target action:@selector(verySpecialAction:) forControlEvents:UIControlEventEditingChanged];
        [[textView.allTargets shouldNot] contain:target];
        actions = [textView actionsForTarget:target forControlEvent:UIControlEventEditingChanged];
        [[actions should] beEmpty];
    });

    it(@"does not prematurely remove a target with multiple actions", ^{
        id target = [NSObject new];

        [textView addTarget:target action:@selector(someAction:) forControlEvents:UIControlEventEditingChanged];
        [textView addTarget:target action:@selector(someOtherAction:) forControlEvents:UIControlEventEditingDidBegin];

        [[textView.allTargets should] haveCountOf:1];

        [textView removeTarget:target action:@selector(someAction:) forControlEvents:UIControlEventEditingChanged];

        [[textView.allTargets should] haveCountOf:1];
    });

    context(@"bridging NSNotifications to target-actions", ^{

        __block NSNotificationCenter *notificationCenter;

        beforeEach(^{
            notificationCenter = [NSNotificationCenter new];
            [textView stub:@selector(aps_notificationCenter) andReturn:notificationCenter];
        });

        it(@"UITextViewTextDidBeginEditingNotification -> UIControlEventEditingDidBegin", ^{
            id target = [TestTarget new];
            [[[target should] receive] testAction:textView];

            [textView addTarget:target action:@selector(testAction:) forControlEvents:UIControlEventEditingDidBegin];
            [notificationCenter postNotificationName:UITextViewTextDidBeginEditingNotification object:textView];
        });

        it(@"UITextViewTextDidChangeNotification -> UIControlEventEditingChanged", ^{
            id target = [TestTarget new];
            [[[target should] receive] testAction:textView];

            [textView addTarget:target action:@selector(testAction:) forControlEvents:UIControlEventEditingChanged];
            [notificationCenter postNotificationName:UITextViewTextDidChangeNotification object:textView];
        });

        it(@"UITextViewTextDidEndEditingNotification -> UIControlEventEditingDidEnd", ^{
            id target = [TestTarget new];
            [[[target should] receive] testAction:textView];

            [textView addTarget:target action:@selector(testAction:) forControlEvents:UIControlEventEditingDidEnd];
            [notificationCenter postNotificationName:UITextViewTextDidEndEditingNotification object:textView];
        });

    });

});

SPEC_END
