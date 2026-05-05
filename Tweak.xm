#import <UIKit/UIKit.h>

%hook TFNScrollingSegmentedViewController
- (id)initWithDataSource:(id)dataSource delegate:(id)delegate externalLabelBar:(UIView *)externalLabelBar addLabelBarToNavigationBarBlur:(BOOL)addLabelBarToNavigationBarBlur useAlternateBackgroundColor:(BOOL)useAlternateBackgroundColor {
    BOOL home = [dataSource isKindOfClass:NSClassFromString(@"_TtC32TwitterHomeFeatureImplementation35HomeTimelineContainerViewController")];
    id result = %orig(dataSource, delegate, externalLabelBar, home ? NO : addLabelBarToNavigationBarBlur, useAlternateBackgroundColor);
    return result;
}
- (void)setLabelBarHideMode:(NSInteger)mode {
    for (id parent = self; parent; parent = [parent parentViewController]) {
        if ([parent isKindOfClass:NSClassFromString(@"_TtC32TwitterHomeFeatureImplementation35HomeTimelineContainerViewController")] && mode == 0) {
            %orig(1);
            return;
        }
    }
    %orig;
}
%end

%hook _TtC32TwitterHomeFeatureImplementation35HomeTimelineContainerViewController
- (NSInteger)numberOfEntriesForSegmentedViewController:(id)controller {
    return MIN(%orig, 1);
}
- (UIViewController *)segmentedViewController:(id)controller viewControllerAtIndex:(NSInteger)index {
    return %orig(controller, index ?: 1);
}
%end

%hook THFURTHomeTimelineStream
- (void)setVisibleScrollPositionState:(id)state {
    if (state)
        %orig;
}
%end

%hook TFNTwitterAccount
- (NSInteger)restartFromTopNavigationMinBackgroundMinutes {
    return -1;
}
%end