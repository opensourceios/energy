#import "ARSync.h"
#import "ARNetworkQualityIndicator.h"


@class ARSyncStatusViewModel;

typedef NS_ENUM(NSInteger, ARSyncStatus) {
    ARSyncStatusSyncing,
    ARSyncStatusUpToDate,
    ARSyncStatusRecommendSync,
    ARSyncStatusOffline,
};

typedef NS_ENUM(NSInteger, ARSyncImageNotification) {
    ARSyncImageNotificationUpToDate,
    ARSyncImageNotificationRecommendSync,
    ARSyncImageNotificationNone,
};


@interface ARSyncStatusViewModel : NSObject <ARSyncDelegate, ARSyncProgressDelegate>

@property (nonatomic, assign) NSTimeInterval timeRemainingInSync;
@property (nonatomic, assign) CGFloat currentSyncPercentDone;

@property (nonatomic, assign) BOOL isActivelySyncing;
@property (nonatomic, assign) ARNetworkQuality networkQuality;

- (instancetype)initWithSync:(ARSync *)sync context:(NSManagedObjectContext *)context;

- (void)startSync;

- (NSString *)titleText;
- (NSString *)subtitleText;
- (NSString *)syncInProgressTitle;

- (BOOL)shouldShowSyncButton;
- (BOOL)shouldEnableSyncButton;
- (NSString *)syncButtonTitle;
- (UIColor *)syncButtonColor;

- (CGFloat)syncActivityViewAlpha;

- (ARSyncImageNotification)currentSyncImageNotification;

/// Returns the number of syncs logged on device
- (NSInteger)syncLogCount;

/// Returns an array of formatted date strings for all recorded syncs
- (NSArray<NSString *> *)previousSyncDateStrings;

@end
