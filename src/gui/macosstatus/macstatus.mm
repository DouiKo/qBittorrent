#import "macstatus.h"
#import <AppKit/AppKit.h>

// 预声明
class MacStatus;

// 菜单处理类：负责转发菜单事件给 Qt
@interface MenuHandler : NSObject
@property (nonatomic, assign) MacStatus *statusItemController;

- (void)onShowMainWindow:(id)sender;
- (void)onQuitApp:(id)sender;
@end

@implementation MenuHandler

- (void)onShowMainWindow:(id)sender {
    if (self.statusItemController) {
        emit self.statusItemController->showMainWindowRequested();
    }
}

- (void)onQuitApp:(id)sender {
    [NSApp terminate:nil];
}

@end

static MenuHandler *menuHandler_ = nil;
static NSStatusItem *statusItem_ = nil;
static NSMenu *contextMenu_ = nil;

MacStatus::MacStatus(QObject *parent)
    : QObject(parent)
{
}

MacStatus::~MacStatus()
{
}

void MacStatus::initialize()
{
    if (statusItem_) return;
    createStatusItem();
    createContextMenu();
}

void MacStatus::createStatusItem()
{
    statusItem_ = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];

    NSString *iconPath = @":/icons/qbittorrent-tray-dark.svg";
    NSImage *icon = [[NSImage alloc] initWithContentsOfFile:iconPath];
    [icon setSize:NSMakeSize(18, 18)];
    statusItem_.button.image = icon;
    statusItem_.button.imagePosition = NSImageLeft;
    statusItem_.button.title = @"↑ 0 KB/s ↓ 0 KB/s";
}

void MacStatus::updateSpeedText(const QString &text)
{
    if (!statusItem_) return;

    NSString *nativeText = text.toNSString();
    dispatch_async(dispatch_get_main_queue(), ^{
        statusItem_.button.title = nativeText;
    });
}

void MacStatus::createContextMenu()
{
    if (contextMenu_) return;

    contextMenu_ = [[NSMenu alloc] init];
    menuHandler_ = [[MenuHandler alloc] init];
    menuHandler_.statusItemController = this;

    NSMenuItem *showWindowItem = [[NSMenuItem alloc] initWithTitle:@"显示主窗口"
                                                            action:@selector(onShowMainWindow:)
                                                     keyEquivalent:@""];
    [showWindowItem setTarget:menuHandler_];
    [contextMenu_ addItem:showWindowItem];

    NSMenuItem *quitItem = [[NSMenuItem alloc] initWithTitle:@"退出"
                                                      action:@selector(onQuitApp:)
                                               keyEquivalent:@""];
    [quitItem setTarget:menuHandler_];
    [contextMenu_ addItem:quitItem];

    statusItem_.menu = contextMenu_;
}

void MacStatus::showAppDock()
{
    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
}

void MacStatus::hideAppDock()
{
    [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];
}
