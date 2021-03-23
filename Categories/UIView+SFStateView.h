//
//  UIView+SFStateView.h
//  StanfyUI
//
//  Created by Slavik Bubnov on 26.03.11.
//  Copyright 2010 Stanfy, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFStateView.h"


/**
 Category, that adds the methods to working with state views in view.
 @see SFStateView
 */
@interface UIView (SFStateView)


/**
 View state getter and setter
 When view state changed - proper state view will be presented (if exists)
 */
- (NSInteger)viewState;
- (void)setViewState:(NSInteger)newViewState;


/**
 Set state view for state
 When view's state will become |state| - |stateView| will be presented
 */
- (void)setStateView:(SFStateView *)stateView forViewState:(NSInteger)state;


/**
 Return state view for state, if it's set
 @return SFStateView or nil
 */
- (SFStateView *)stateViewForViewState:(NSInteger)state;


/**
 Return current appeared state view
 @return SFStateView or nil
 */
- (SFStateView *)currentStateView;


/**
 Remove all state views of the view
 */
- (void)removeAllStateViews;


/**
 Shows state view in the view
 */
- (void)showStateView:(SFStateView *)stateView;


/**
 Hides state view
 */
- (void)hideStateView;


@end
