//
//  ExoabdButton.h
//  ExoabdButton
//
//  Created by reflog on 11/26/14.
//  Copyright (c) 2014 reflog. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for ExoabdButton.
FOUNDATION_EXPORT double ExpandButtonVersionNumber;

//! Project version string for ExoabdButton.
FOUNDATION_EXPORT const unsigned char ExpandButtonVersionString[];

//
//	DDExpandableButton.h
//	https://github.com/ddebin/DDExpandableButton
//

#ifndef __IPHONE_5_0
#warning "This project uses features only available in iOS SDK 5.0 and later."
#endif

#import <UIKit/UIKit.h>


#define DDView UIView <DDExpandableButtonViewSource>

@protocol DDExpandableButtonViewSource;

/**
 `DDExpandableButton` is a class designed to be used like an expandable `UIButton` ; as seen in the iOS Camera app for the "flash" button.
 */
IB_DESIGNABLE
@interface DDExpandableButton : UIControl
{
    CGFloat		cornerAdditionalPadding;
    CGFloat		leftWidth;
    CGFloat		maxHeight;
    CGFloat		maxWidth;
    DDView		*leftTitleView;
}

/**
 Current button status (if expanded or shrunk).
 */
@property (nonatomic,assign)	IBInspectable  BOOL		expanded;

/**
 Use animation during button state stransitions.
 */
@property (nonatomic,assign)	IBInspectable  BOOL		useAnimation;

/**
 Use button as a toggle (like "HDR On"/"HDR Off" button in camera app).
 */
@property (nonatomic,assign)	IBInspectable  BOOL		toggleMode;

/**
 To shrink the button after a timeout. Use `0` if you want to disable timeout.
 */
@property (nonatomic,assign)	IBInspectable  CGFloat		timeout;

/**
 Horizontal padding space between items.
 */
@property (nonatomic,assign)	IBInspectable  CGFloat		horizontalPadding;

/**
 Vertical padding space above and below items.
 */
@property (nonatomic,assign)	IBInspectable  CGFloat		verticalPadding;

/**
 Width (thickness) of the button border.
 */
@property (nonatomic,assign)	IBInspectable  CGFloat		borderWidth;

/**
 Width (thickness) of the inner borders between items.
 */
@property (nonatomic,assign)	IBInspectable  CGFloat		innerBorderWidth;

/**
 Selected item number.
 */
@property (nonatomic,assign)	IBInspectable  NSUInteger	selectedItem;

/**
 Color of the button and inner borders.
 */
@property (nonatomic,retain)	IBInspectable  UIColor		*borderColor;

/**
 Color of text labels.
 */
@property (nonatomic,retain)	IBInspectable  UIColor		*textColor;

/**
 Font of text labels.
 */
@property (nonatomic,retain)	IBInspectable  UIFont		*labelFont;

/**
 Font of unselected text labels. Nil if not different from labelFont.
 */
@property (nonatomic,retain)	IBInspectable  UIFont		*unSelectedLabelFont;

/**
 Access UIView used to draw labels.
 */
@property (nonatomic,readonly)	IBInspectable NSArray		*labels;

/**
 Creates and returns a `DDExpandableButton` with specific point / left title / buttons
 @param point Upper-left corner for `DDExpandableButton` frame
 @param leftTitle Left title in button
 @param buttons An array of `NSString`/`UIImage`/`UIView` objects
 @return A `DDExpandableButton`
 */
- (id)initWithPoint:(CGPoint)point leftTitle:(id)leftTitle buttons:(NSArray *)buttons;

/**
 Select specific item
 @param selected Index of selected item
 @param animated Animate selection
 */
- (void)setSelectedItem:(NSUInteger)selected animated:(BOOL)animated;

/**
 Set expanded state
 @param expanded Wether or not the button is expanded
 @param animated Animate expansion
 */
- (void)setExpanded:(BOOL)expanded animated:(BOOL)animated;

/**
 Set left title
 @param leftTitle A `NSString`/`UIImage`/`UIView` object
 */
- (void)setLeftTitle:(id)leftTitle;

/**
 Set buttons array
 @param buttons An array of `NSString`/`UIImage`/`UIView` objects
 */
- (void)setButtons:(NSArray *)buttons;

/**
 Disable "shrink" timeout
 */
- (void)disableTimeout;

/**
 Update button display
 */
- (void)updateDisplay;

@end

/**
 All `UIView` used by DDExpandableButton must conform to this protocol
 */
@protocol DDExpandableButtonViewSource <NSObject>

/**
 Return default frame size
 @return view frame size
 */
- (CGSize)defaultFrameSize;

@optional
/**
 Set highlighted state
 @param highlighted Wether or not view is highlighted
 */
- (void)setHighlighted:(BOOL)highlighted;

@end


