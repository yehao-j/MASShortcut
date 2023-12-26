#import "MASShortcutBinder.h"
#import "MASShortcut.h"

@interface MASShortcutBinder ()

@property(strong, nonatomic) NSMutableDictionary *actions;
@property(strong, nonatomic) NSMutableDictionary *shortcuts;

@end

@implementation MASShortcutBinder

#pragma mark Initialization

- (instancetype)init {
    self = [super init];
    [self setActions:[NSMutableDictionary dictionary]];
    [self setShortcuts:[NSMutableDictionary dictionary]];
    [self setShortcutMonitor:[MASShortcutMonitor sharedMonitor]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeShortcut:) name:@"ChangeShortCut" object:nil];
    
    return self;
}

+ (instancetype)sharedBinder {
    static dispatch_once_t once;
    static MASShortcutBinder *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark Registration

- (void)changeShortcut:(NSNotification *)notification {
    NSDictionary *dict = notification.object;
    if (dict) {
        NSString *key = dict[@"key"];
        MASShortcut *shortcut = dict[@"value"];
        
        if (shortcut == nil) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
            
            [self removeKey:key];
        } else {
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:shortcut requiringSecureCoding:NO error:nil];
            [[NSUserDefaults standardUserDefaults] setValue:data forKey:key];
            
            [self saveKey:key];
        }
        
        [self monitorShortcut:shortcut forKey:key];
    }
}

- (void)registerWithKey:(NSString*)key shortcut:(MASShortcut *)shortcut toAction:(dispatch_block_t)action {
    [_actions setObject:[action copy] forKey:key];
    
    NSData *data = [[NSUserDefaults standardUserDefaults] valueForKey:key];
    MASShortcut *bindShortcut = shortcut;
    /// 假设已经存在该key对应快捷键，那么就不进行保存
    if (data == nil) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:shortcut requiringSecureCoding:NO error:nil];
        [[NSUserDefaults standardUserDefaults] setValue:data forKey:key];
        
        [self saveKey:key];
    } else {
        MASShortcut *archiveShortcut = [NSKeyedUnarchiver unarchivedObjectOfClass:[MASShortcut class] fromData:data error:nil];
        bindShortcut = archiveShortcut;
    }
    
    if (bindShortcut) {
        [self monitorShortcut:bindShortcut forKey:key];
    }
}

- (void)unregisterWithKey:(NSString *)key {
    if ([self.shortcuts objectForKey:key]) {
        [_shortcutMonitor unregisterShortcut:[_shortcuts objectForKey:key]];
        [_shortcuts removeObjectForKey:key];
        [_actions removeObjectForKey:key];
        
        [self removeKey:key];
    }
}

- (void)removeKey:(NSString *)key {
    NSMutableArray *keys = nil;
    NSArray *array = [[NSUserDefaults standardUserDefaults] arrayForKey:@"MASShortcutKeys"];
    if (array) {
        keys = [NSMutableArray arrayWithArray:array];
    } else {
        keys = [NSMutableArray array];
    }
    
    [keys removeObject:key];
    [[NSUserDefaults standardUserDefaults] setValue:keys forKey:@"MASShortcutKeys"];
}

- (void)saveKey:(NSString *)key {
    NSMutableArray *keys = nil;
    NSArray *array = [[NSUserDefaults standardUserDefaults] arrayForKey:@"MASShortcutKeys"];
    if (array) {
        keys = [NSMutableArray arrayWithArray:array];
    } else {
        keys = [NSMutableArray array];
    }
    
    if (![keys containsObject:key]) {
        [keys addObject:key];
        [[NSUserDefaults standardUserDefaults] setValue:keys forKey:@"MASShortcutKeys"];
    }
}

/// 如果存在该key的快捷键，那么就先解除，然后重新绑定
- (void)monitorShortcut:(MASShortcut *)shortcut forKey:(NSString *)key {
    if (![self isRegisteredAction:key]) {
        return;
    }
    
    MASShortcut *currentShortcut = [_shortcuts objectForKey:key];
    if (currentShortcut != nil) {
        [_shortcutMonitor unregisterShortcut:currentShortcut];
    }
    
    if (shortcut == nil) {
        [_shortcuts removeObjectForKey:key];
        return;
    }
    
    [_shortcuts setObject:shortcut forKey:key];
    [_shortcutMonitor registerShortcut:shortcut withAction:[_actions objectForKey:key]];
}

#pragma mark Bindings

- (BOOL)isRegisteredAction:(NSString*)name {
    return [_actions objectForKey:name] != nil;
}

@end
