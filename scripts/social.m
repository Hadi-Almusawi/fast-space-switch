// Render a local sharing image with system fonts.
#import <AppKit/AppKit.h>
static void label(NSString *text, CGFloat y, CGFloat size, NSColor *color) {
    [text drawAtPoint:NSMakePoint(70, y) withAttributes:@{
        NSFontAttributeName: [NSFont systemFontOfSize:size weight:NSFontWeightMedium],
        NSForegroundColorAttributeName: color
    }];
}
int main(void) {
    @autoreleasepool {
        NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL pixelsWide:1200 pixelsHigh:630 bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES isPlanar:NO colorSpaceName:NSDeviceRGBColorSpace bytesPerRow:0 bitsPerPixel:0];
        [NSGraphicsContext saveGraphicsState];
        [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:bitmap]];
        [[NSColor colorWithCalibratedRed:.93 green:.95 blue:1 alpha:1] setFill];
        NSRectFill(NSMakeRect(0, 0, 1200, 630));
        NSColor *ink = [NSColor colorWithCalibratedRed:.09 green:.15 blue:.26 alpha:1];
        NSColor *blue = [NSColor colorWithCalibratedRed:.14 green:.31 blue:.78 alpha:1];
        label(@"FastSpaceSwitch", 520, 28, blue);
        label(@"Your next desktop.", 370, 72, ink);
        label(@"Without the slide.", 275, 72, ink);
        label(@"Ctrl + Left / Right", 150, 32, blue);
        label(@"Free and open source for macOS Tahoe 26", 65, 24, ink);
        [NSGraphicsContext restoreGraphicsState];
        NSData *png = [bitmap representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
        return [png writeToFile:@"docs/social.png" atomically:YES] ? 0 : 1;
    }
}
