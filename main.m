// FastSpaceSwitch - instant Ctrl+Left / Ctrl+Right desktop switching.
//
// What it does, and nothing else:
//   1. Registers exactly two hotkeys with macOS: Ctrl+Left and Ctrl+Right.
//      (RegisterEventHotKey only ever tells us when those two combos are
//      pressed. It never sees any other keystroke.)
//   2. When one fires, posts a fake trackpad "dock swipe" with a huge
//      velocity, so the Dock switches desktops without the slide animation.
//
// No network, no files, no other input, no screen access.
//
#import <Cocoa/Cocoa.h>
#include <ApplicationServices/ApplicationServices.h>
#include <Carbon/Carbon.h>
#include <stdio.h>
#include <string.h>

// Private CGEvent fields the Dock reads for trackpad swipes.
static const CGEventField kFieldEventType     = (CGEventField)55;
static const CGEventField kFieldGestureHIDType = (CGEventField)110;
static const CGEventField kFieldSwipeMotion   = (CGEventField)123;
static const CGEventField kFieldSwipeProgress = (CGEventField)124;
static const CGEventField kFieldSwipeVelocityX = (CGEventField)129;
static const CGEventField kFieldSwipeVelocityY = (CGEventField)130;
static const CGEventField kFieldGesturePhase  = (CGEventField)132;

static const int64_t kEventTypeDockControl = 30;
static const int64_t kHIDEventTypeDockSwipe = 23;
static const int64_t kMotionHorizontal = 1;

enum { kPhaseBegan = 1, kPhaseChanged = 2, kPhaseEnded = 4 };

static const double kVelocity = 2000.0;
static const double kProgress = 0.000016;

static void post_swipe(int phase, bool right) {
    CGEventRef ev = CGEventCreate(NULL);
    if (!ev) return;
    CGEventSetIntegerValueField(ev, kFieldEventType, kEventTypeDockControl);
    CGEventSetIntegerValueField(ev, kFieldGestureHIDType, kHIDEventTypeDockSwipe);
    CGEventSetIntegerValueField(ev, kFieldGesturePhase, phase);
    CGEventSetIntegerValueField(ev, kFieldSwipeMotion, kMotionHorizontal);
    CGEventSetDoubleValueField(ev, kFieldSwipeProgress, right ? kProgress : -kProgress);
    CGEventSetDoubleValueField(ev, kFieldSwipeVelocityX, right ? kVelocity : -kVelocity);
    CGEventSetDoubleValueField(ev, kFieldSwipeVelocityY, right ? kVelocity : -kVelocity);
    CGEventPost(kCGSessionEventTap, ev);
    CFRelease(ev);
}

// Private window-server calls for reading (not changing) the desktop list.
typedef int32_t CGSConnectionID;
extern CGSConnectionID CGSMainConnectionID(void);
extern uint64_t CGSGetActiveSpace(CGSConnectionID cid);
extern CFStringRef CGSCopyActiveMenuBarDisplayIdentifier(CGSConnectionID cid);
extern CFArrayRef CGSCopyManagedDisplaySpaces(CGSConnectionID cid);

static uint64_t space_id(CFDictionaryRef space) {
    uint64_t id = 0;
    CFNumberRef n = space ? CFDictionaryGetValue(space, CFSTR("id64")) : NULL;
    if (n) CFNumberGetValue(n, kCFNumberSInt64Type, &id);
    return id;
}

// Is there a desktop in that direction on the active display? If the desktop
// list can't be read, allow the switch rather than break it.
static bool can_move(bool right) {
    CGSConnectionID cid = CGSMainConnectionID();
    CFArrayRef displays = CGSCopyManagedDisplaySpaces(cid);
    if (!displays) return true;
    CFStringRef menuBarDisplay = CGSCopyActiveMenuBarDisplayIdentifier(cid);
    uint64_t active = CGSGetActiveSpace(cid);

    bool allowed = true;
    for (CFIndex d = 0; d < CFArrayGetCount(displays); d++) {
        CFDictionaryRef display = CFArrayGetValueAtIndex(displays, d);
        CFStringRef identifier = CFDictionaryGetValue(display, CFSTR("Display Identifier"));
        CFDictionaryRef current = CFDictionaryGetValue(display, CFSTR("Current Space"));
        bool isActiveDisplay = menuBarDisplay && identifier ? CFEqual(identifier, menuBarDisplay)
                                                            : space_id(current) == active;
        if (!isActiveDisplay) continue;

        uint64_t currentID = current ? space_id(current) : active;
        CFArrayRef spaces = CFDictionaryGetValue(display, CFSTR("Spaces"));
        CFIndex count = spaces ? CFArrayGetCount(spaces) : 0;
        for (CFIndex i = 0; i < count; i++) {
            if (space_id(CFArrayGetValueAtIndex(spaces, i)) == currentID) {
                allowed = right ? i + 1 < count : i > 0;
                break;
            }
        }
        break;
    }

    if (menuBarDisplay) CFRelease(menuBarDisplay);
    CFRelease(displays);
    return allowed;
}

// Began, Changed, Ended: all three are needed or the Dock ignores it.
static void switch_space(bool right) {
    if (!can_move(right)) return;
    post_swipe(kPhaseBegan, right);
    post_swipe(kPhaseChanged, right);
    post_swipe(kPhaseEnded, right);
}

enum { kHotKeyLeft = 1, kHotKeyRight = 2 };

static OSStatus on_hotkey(EventHandlerCallRef next, EventRef event, void *data) {
    (void)next;
    (void)data;
    EventHotKeyID id = { 0, 0 };
    if (GetEventParameter(event, kEventParamDirectObject, typeEventHotKeyID, NULL,
                          sizeof(id), NULL, &id) != noErr) return noErr;
    if (id.id == kHotKeyLeft) switch_space(false);
    if (id.id == kHotKeyRight) switch_space(true);
    return noErr;
}

int main(int argc, char **argv) {
    // `FastSpaceSwitch left|right` switches once and exits (for testing).
    if (argc == 2 && (strcmp(argv[1], "left") == 0 || strcmp(argv[1], "right") == 0)) {
        switch_space(strcmp(argv[1], "right") == 0);
        return 0;
    }
    // `FastSpaceSwitch status` prints which directions are available.
    if (argc == 2 && strcmp(argv[1], "status") == 0) {
        printf("left: %s, right: %s\n", can_move(false) ? "yes" : "no", can_move(true) ? "yes" : "no");
        return 0;
    }

    // Ask for Accessibility once; macOS needs it before posting the swipe.
    const void *keys[] = { kAXTrustedCheckOptionPrompt };
    const void *values[] = { kCFBooleanTrue };
    CFDictionaryRef opts = CFDictionaryCreate(NULL, keys, values, 1,
        &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    if (!AXIsProcessTrustedWithOptions(opts)) {
        fprintf(stderr, "FastSpaceSwitch: waiting for Accessibility permission\n");
    }
    CFRelease(opts);

    EventTypeSpec spec = { kEventClassKeyboard, kEventHotKeyPressed };
    InstallApplicationEventHandler(&on_hotkey, 1, &spec, NULL, NULL);

    EventHotKeyRef left, right;
    OSStatus l = RegisterEventHotKey(kVK_LeftArrow, controlKey,
        (EventHotKeyID){ 'FSSw', kHotKeyLeft }, GetApplicationEventTarget(), 0, &left);
    OSStatus r = RegisterEventHotKey(kVK_RightArrow, controlKey,
        (EventHotKeyID){ 'FSSw', kHotKeyRight }, GetApplicationEventTarget(), 0, &right);
    if (l != noErr || r != noErr) {
        fprintf(stderr, "FastSpaceSwitch: could not register hotkeys (%d, %d)\n", (int)l, (int)r);
        return 1;
    }

    fprintf(stderr, "FastSpaceSwitch: running\n");
    [NSApplication sharedApplication];
    [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];
    [NSApp run];
    return 0;
}
