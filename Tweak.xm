#import <UIKit/UIKit.h>
#import <float.h>

static id LastDeepScrollState;
static NSString *TimelineTabKey = @"THFHomeTimelineContainerViewController.lastSelectedTimelineTabIdentifier";
static NSString *FollowingTimelineTabValue = @"latest";
static NSInteger MostRecentTimelineVariant = 1;

static BOOL StateIsAtTop(id state) {
    id value = [state isKindOfClass:NSDictionary.class] ? [state objectForKey:@"atTopLeft"] : nil;
    return [value respondsToSelector:@selector(boolValue)] && [value boolValue];
}

static CGFloat StateContentOffsetY(id state) {
    id value = [state isKindOfClass:NSDictionary.class] ? [state objectForKey:@"contentOffset"] : nil;

    if ([value isKindOfClass:NSString.class]) {
        return CGPointFromString(value).y;
    }

    if ([value isKindOfClass:NSValue.class]) {
        return [value CGPointValue].y;
    }

    return 0;
}

static BOOL ShouldPreserveScrollState(id state) {
    return state && !StateIsAtTop(state) && StateContentOffsetY(state) > 0;
}

%hook TFNScrollingSegmentedViewController
- (id)initWithDataSource:(id)dataSource delegate:(id)delegate externalLabelBar:(UIView *)externalLabelBar addLabelBarToNavigationBarBlur:(BOOL)addLabelBarToNavigationBarBlur useAlternateBackgroundColor:(BOOL)useAlternateBackgroundColor {
    BOOL home = [dataSource isKindOfClass:NSClassFromString(@"_TtC32TwitterHomeFeatureImplementation35HomeTimelineContainerViewController")];
    return %orig(dataSource, delegate, externalLabelBar, home ? NO : addLabelBarToNavigationBarBlur, useAlternateBackgroundColor);
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

- (NSString *)segmentedViewController:(id)controller titleAtIndex:(NSInteger)index {
    return %orig(controller, index ?: 1);
}

- (NSAttributedString *)segmentedViewController:(id)controller attributedTitleAtIndex:(NSInteger)index {
    return %orig(controller, index ?: 1);
}

- (NSString *)segmentedViewController:(id)controller accessibilityLabelAtIndex:(NSInteger)index {
    return %orig(controller, index ?: 1);
}

- (BOOL)tfn_supportsTabBarCollapsing {
    return NO;
}

- (BOOL)tfn_supportsNavigationBarCollapsing {
    return NO;
}

- (BOOL)segmentedViewControllerShouldAutoHideNavigationBar:(id)controller {
    return NO;
}

- (void)clearLastSelectedTabIdentifier {
}

- (void)selectTimelineVariant:(NSInteger)variant shouldRefresh:(BOOL)shouldRefresh {
    %orig(MostRecentTimelineVariant, shouldRefresh);
}

- (void)selectFilteredTimelineVariant:(NSInteger)variant shouldRefresh:(BOOL)shouldRefresh {
    %orig(MostRecentTimelineVariant, shouldRefresh);
}
%end

%hook THFURTHomeTimelineStream
- (void)setVisibleScrollPositionState:(id)state {
    if (ShouldPreserveScrollState(state)) {
        LastDeepScrollState = state;
    }

    if (StateIsAtTop(state) && LastDeepScrollState) {
        return;
    }

    if (state) {
        %orig;
    }
}

- (id)getVisibleScrollPositionState {
    id state = %orig;

    if (ShouldPreserveScrollState(state)) {
        LastDeepScrollState = state;
    }

    if (StateIsAtTop(state) && LastDeepScrollState) {
        state = LastDeepScrollState;
    }

    return state;
}
%end

%hook TFNTwitterAccount
- (NSInteger)restartFromTopNavigationMinBackgroundMinutes {
    return -1;
}
%end

%hook TwitterHomeFeatures
- (double)homeTimelineForegroundRefreshMinBackgroundSeconds {
    return DBL_MAX;
}

- (double)homeTimelineWarmStartMinBackgroundMinutes {
    return DBL_MAX;
}

- (NSInteger)restartFromTopNavigationMinBackgroundMinutes {
    return NSIntegerMax;
}

- (NSInteger)jumpToTopNavigationMinBackgroundMinutes {
    return NSIntegerMax;
}

- (double)homeTimelineFetchNewerOnNavigateMinMinutes {
    return DBL_MAX;
}

- (BOOL)isHomeTimelineFetchNewerOnNavigationEnabled {
    return NO;
}
%end

%hook NSUserDefaults
- (id)objectForKey:(NSString *)key {
    if ([key isEqualToString:TimelineTabKey]) {
        return FollowingTimelineTabValue;
    }

    return %orig;
}

- (NSString *)stringForKey:(NSString *)key {
    if ([key isEqualToString:TimelineTabKey]) {
        return FollowingTimelineTabValue;
    }

    return %orig;
}

- (void)setObject:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:TimelineTabKey]) {
        %orig(FollowingTimelineTabValue, key);
        return;
    }

    %orig(value, key);
}

- (void)removeObjectForKey:(NSString *)key {
    if ([key isEqualToString:TimelineTabKey]) {
        return;
    }

    %orig(key);
}
%end

%hook THFHomeTimelineFilterStateProvider
- (BOOL)isRankedFollowingTimelineEnabled {
    return NO;
}
%end

%hook URTHomeTimelineStream
- (BOOL)enableRankedFollowingTimeline {
    return NO;
}
%end
