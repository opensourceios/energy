#import "ARInitialViewControllerSetupCoordinator.h"
#import "ARTopViewController.h"
#import "ARLoginViewController.h"
#import "ARSyncViewController.h"
#import "ARNavigationController.h"
#import "ARFolioMessageViewController.h"


@interface UIViewController (Property)
@property (nonatomic, strong) NSObject *transparentModalViewController;
@end

SpecBegin(ARInitialViewControllerSetupCoordinator);

__block ARInitialViewControllerSetupCoordinator *subject;

__block ARSync *sync;
__block UIWindow *window;
__block NSManagedObjectContext *context;

before(^{
    sync = [[ARSync alloc] init];
    sync.progress = [[ARSyncProgress alloc] init];
    window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 400, 400)];
    subject = [[ARInitialViewControllerSetupCoordinator alloc] initWithWindow:window sync:sync];
    context = [CoreDataManager stubbedManagedObjectContext];
});

describe(@"setting up the grid", ^{
    it(@"sets up a nav hosting a ARTopViewController on the window", ^{
        [subject setupFolioGridWithContext:context];

        UINavigationController *controller = (id)window.rootViewController;
        expect(window.rootViewController.class).to.equal(ARNavigationController.class);
        expect(controller.topViewController.class).to.equal(ARTopViewController.class);
    });

    it(@"passes the sync to the ARTopViewController", ^{
        [subject setupFolioGridWithContext:context];

        UINavigationController *controller = (id)window.rootViewController;
        ARTopViewController *topViewController = (id)[controller topViewController];
        expect([topViewController sync]).to.equal(sync);
    });
});


describe(@"setting up the login screen", ^{
    before(^{
        window.rootViewController = [[UIViewController alloc] init];
        [window makeKeyAndVisible];
        [subject presentLoginScreen:NO];
    });

    it(@"sets up a nav hosting a ARLoginViewController on the window", ^{
        UINavigationController *controller = (id)window.rootViewController.presentedViewController;

        expect(controller.class).to.equal(ARNavigationController.class);
        expect(controller.topViewController.class).to.equal(ARLoginViewController.class);
    });

    it(@"passes the sync to the ARLoginViewController", ^{
        UINavigationController *controller = (id)window.rootViewController.presentedViewController;
        ARLoginViewController *topViewController = (id)[controller topViewController];
        expect([topViewController sync]).to.equal(sync);
    });

    pending(@"login completion block opens the sync");
});


describe(@"setting up the sync screen", ^{
    before(^{
        window.rootViewController = [[UIViewController alloc] init];
        [window makeKeyAndVisible];
        [subject presentSyncScreen:NO startSync:NO context:context];
    });

    it(@"sets up a nav hosting a ARSyncViewController on the window", ^{
        UINavigationController *controller = (id)window.rootViewController.presentedViewController;
        expect(controller.class).to.equal(ARNavigationController.class);
        expect(controller.topViewController.class).to.equal(ARSyncViewController.class);
    });

    it(@"passes the sync to the ARSyncViewController", ^{
        UINavigationController *controller = (id)window.rootViewController.presentedViewController;
        ARSyncViewController *topViewController = (id)[controller topViewController];

        expect(sync.delegate).to.equal(topViewController);
        expect(sync.progress.delegate).to.equal(topViewController);
    });

    pending(@"sync completion block removes the sync vc");
    
    pending(@"sync completion block presents zero state screen if partner has no works");

});

describe(@"setting up the logout screen", ^{
    it(@"presents a logout screen", ^{
        window.rootViewController = [[UIViewController alloc] init];
        [window makeKeyAndVisible];

        [subject presentLogoutScreen:NO logout:NO];

        UINavigationController *controller = (id)window.rootViewController.presentedViewController;
        
        expect(controller.class).to.equal(ARNavigationController.class);
        expect(controller.topViewController.class).to.equal(ARLogoutViewController.class);
    });
});

describe(@"setting up the lockout screen", ^{
    it(@"presents a lockout screen", ^{
        window.rootViewController = [[UIViewController alloc] init];
        [window makeKeyAndVisible];
        
        [subject presentLockoutScreenContext:context];
        
        expect(window.rootViewController.transparentModalViewController.class).to.equal(ARFolioMessageViewController.class);
    });

    it(@"sets the right URL", ^{
        [Partner modelFromJSON:@{ @"id": @"_partner_" } inContext:context];
        [User modelFromJSON:@{ @"id": @"_user_", @"email": @"dev@artsymail.com" } inContext:context];

        window.rootViewController = [[UIViewController alloc] init];
        [window makeKeyAndVisible];
        [subject presentLockoutScreenContext:context];
        ARFolioMessageViewController *messageVC = (id)window.rootViewController.transparentModalViewController;

        expect(messageVC.callToActionAddress).to.equal(@"https://www.artsy.net/gallery-partnerships/tools?partner_id=_partner_&user_id=_user_&utm_medium=mobile&utm_source=folio&utm_campaign=fair_access");
    });
});


SpecEnd
