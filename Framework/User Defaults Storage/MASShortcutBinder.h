#import "MASShortcutMonitor.h"

/**
 Binds actions to user defaults keys.

 If you store shortcuts in user defaults (for example by binding
 a `MASShortcutView` to user defaults), you can use this class to
 connect an action directly to a user defaults key. If the shortcut
 stored under the key changes, the action will get automatically
 updated to the new one.

 This class is mostly a wrapper around a `MASShortcutMonitor`. It
 watches the changes in user defaults and updates the shortcut monitor
 accordingly with the new shortcuts.
*/
@interface MASShortcutBinder : NSObject

/**
 A convenience shared instance.

 You may use it so that you don’t have to manage an instance by hand,
 but it’s perfectly fine to allocate and use a separate instance instead.
*/
+ (instancetype) sharedBinder;

/**
 The underlying shortcut monitor.
*/
@property(strong) MASShortcutMonitor *shortcutMonitor;

/// 绑定快捷键，如果用户修改了快捷键，那么使用用户的快捷键，反之设置该快捷键
- (void)registerWithKey:(NSString*)key shortcut:(MASShortcut *)shortcut toAction:(dispatch_block_t)action;

- (void)unregisterWithKey:(NSString *)key;

@end
