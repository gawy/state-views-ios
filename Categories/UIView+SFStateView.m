//
//  UIView+SFStateView.m
//  StanfyUI
//
//  Created by Slavik Bubnov on 26.03.11.
//  Copyright 2010 Stanfy, LLC. All rights reserved.
//

#import "UIView+SFStateView.h"
#import <objc/runtime.h>


@implementation UIView (SFStateView)


static char *_viewStateKey;
static char *_stateViewsKey;


- (NSString *)keyForState:(NSInteger)state {
   return [NSString stringWithFormat:@"%d", state];
}


- (NSMutableDictionary *)stateViews {
   // Get state views dictionary or create lazily
   // This method used only if we are going to set new state view to the dictionary, 
   // because there are no reasons to create assosiated dictionary, 
   // if we need just read from dictionary.
   NSMutableDictionary *stateViews = objc_getAssociatedObject(self, &_stateViewsKey);
   if ( ! stateViews) {
      stateViews = [NSMutableDictionary dictionary];
      objc_setAssociatedObject(self, &_stateViewsKey, stateViews, OBJC_ASSOCIATION_RETAIN);
   }
   return stateViews;
}


- (void)setStateView:(SFStateView *)stateView forViewState:(NSInteger)state {
   // Validate state view
   if ( ! stateView || ! [stateView isKindOfClass:[SFStateView class]]) {
      return;
   }
   
   // Add state view for state
   [[self stateViews] setObject:stateView forKey:[self keyForState:state]];
}


- (SFStateView *)stateViewForViewState:(NSInteger)state {
   NSMutableDictionary *stateViews = objc_getAssociatedObject(self, &_stateViewsKey);
   if (stateViews) {
      return [stateViews objectForKey:[self keyForState:state]];
   }
   return nil;
}


- (SFStateView *)currentStateView {
   for (UIView *subview in self.subviews) {
      if ([subview isKindOfClass:[SFStateView class]] && subview.tag == -500) {
         return (SFStateView *)subview;
      }
   }
   return nil;
}


- (void)removeAllStateViews {
   // Remove state views
   NSMutableArray *stateViews = objc_getAssociatedObject(self, &_stateViewsKey);
   if (stateViews) {
      [stateViews removeAllObjects];
   }
   
   // Clear assosiated dictionary
   objc_setAssociatedObject(self, &_stateViewsKey, nil, OBJC_ASSOCIATION_ASSIGN);
}



#pragma mark -

- (NSInteger)viewState {
   // Read view state from associated object
   NSNumber *viewState = objc_getAssociatedObject(self, &_viewStateKey);
   return [viewState intValue];
}


- (void)setViewState:(NSInteger)newViewState {
   if (self.viewState != newViewState) {
      // Remember the state associated object
      objc_setAssociatedObject(self, &_viewStateKey, [NSNumber numberWithInt:newViewState], OBJC_ASSOCIATION_RETAIN);
      
      // Try to show proper state view
      // If state view for state isn't set - just hide current state view if exists
      SFStateView *stateView = [self stateViewForViewState:newViewState];
      if (stateView) {
         [stateView showInView:self];
      } else {
         [self hideStateView];
      }
   }
}



#pragma mark -

- (void)showStateView:(SFStateView *)stateView {
   // Validate state view
   if ( ! stateView || ! [stateView isKindOfClass:[SFStateView class]]) {
      return;
   }
   
   // Show state view
   [stateView showInView:self];
}


- (void)hideStateView {
   // Find state view and hide it
   for (UIView *subview in self.subviews) {
      if ([subview isKindOfClass:[SFStateView class]]) {
         // Send hide message with delay to prevent animation flicking 
         // if state views switching very fast.
         [(SFStateView *)subview performSelector:@selector(hide) withObject:nil afterDelay:0.1];
      }
   }
}


@end
