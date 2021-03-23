//
//  SFStateView.m
//  StanfyUI
//
//  Created by Bubnov Slavik on 10/18/11.
//  Copyright (c) 2011 Stanfy, LLC. All rights reserved.
//

#import "SFStateView.h"


@implementation SFStateView

@synthesize
contentView = _contentView,
delegate = _delegate, 
keepStateViewBackgroundColor = _keepStateViewBackgroundColor,
showDuration = _showDuration, 
hideDuration = _hideDuration;


static const NSInteger _kStateViewTag = -500;
static const NSInteger _kStateViewRemovingTag = -501;



+ (SFStateView *)stateViewWithDelegate:(id<SFStateViewDelegate>)delegate {
   SFStateView *view = [[[self class] alloc] initWithStateViewDelegate:delegate];
   return view;
}


- (id)initWithStateViewDelegate:(id<SFStateViewDelegate>)delegate {
   if ((self = [super initWithFrame:CGRectMake(0, 0, 100, 100)])) { // Use non-zero frame here!
      _delegate = delegate;
      
      // Defaults
      self.keepStateViewBackgroundColor = NO;
      self.showDuration = self.hideDuration = 0.25f;
      
      // State view configuration
      self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
      self.backgroundColor = [UIColor clearColor];
      
      // Load state view content from nib...
      if ([self nibName]) {
         [[NSBundle mainBundle] loadNibNamed:[self nibName] owner:self options:nil];
         _contentView.frame = self.frame;

         if ( ! self.keepStateViewBackgroundColor) {
            _contentView.backgroundColor = [UIColor clearColor];
         }
         
         [self addSubview:_contentView];
      }
      
      // ...or create it by hands
      else {
         [self createUI];
      }
   }
   return self;
}


- (NSString *)nibName {
   // If state view is an instance of generic SFStateView class, it hasn't nib
   // Otherwise, if state view is a child - using class name as a nib name
   return [self isMemberOfClass:[SFStateView class]] ? nil : NSStringFromClass([self class]);
}


- (void)createUI {
   // Do nothing by default. Should be overriden in child
}


- (void)willMoveToSuperview:(UIView *)newSuperview {
   [super willMoveToSuperview:newSuperview];
   
   if ( ! newSuperview) {
      return;
   }
   
   // When state view moving to superview we have to set proper frame 
   // for it. If state view has delegate - trying to ask him for frame. 
   // Otherwise, using superview's bounds.
   
   CGRect frame = CGRectZero;
   
   if (_delegate && [_delegate respondsToSelector:@selector(stateViewContainerRect:)]) {
      frame = [_delegate stateViewContainerRect:self];
   } else {
      frame = newSuperview.bounds;
   }
   
   self.frame = frame;
}



#pragma mark -

- (void)showInView:(UIView *)view {
   // Do nothing if view is nil
   if ( ! view) {
      return;
   }
   
   // Try to find previous state view. If it is exists and it's animation 
   // is in progress - cancel it and remove
   SFStateView *previousStateView = (SFStateView *)[view viewWithTag:_kStateViewTag];
   if (previousStateView && [previousStateView isKindOfClass:[SFStateView class]]) {
      // If previous state view is not the same as current state view
      if (previousStateView != self) {
         // Clear tag because new state view is upcoming
         previousStateView.tag = 0;
         
         // Send hide message with delay to prevent animation flicking 
         // if state views switching very fast.
         [previousStateView performSelector:@selector(hide) withObject:nil afterDelay:0.1];
      }
   }
   
   // Add state view to the view
   if (self.superview != view) {
      [view addSubview:self];
      self.tag = _kStateViewTag;
   }
   
   // Prepare state view
   [self willShow];
   
    // Show state view
    __weak typeof(self) weakSelf = self;
   [UIView animateWithDuration:[self showDuration] 
                         delay:0 
                       options:UIViewAnimationOptionBeginFromCurrentState
                    animations:^{
                       // Configurate state view for showed state
                       [self didShow];
                    } completion:^(BOOL finished) {
                       if (finished) {
                          // Inform delegate that state view did show
                          if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(stateViewDidShow:)]) {
                             [weakSelf.delegate performSelector:@selector(stateViewDidShow:) withObject:weakSelf];
                          }
                       }
                    }];
}


- (void)hide {
   // Prepare state view for hidding
   [self willHide];

   self.tag = _kStateViewRemovingTag;
   
   // Hide state view
    __weak typeof(self) weakSelf = self;
   [UIView animateWithDuration:[self hideDuration] 
                         delay:0 
                       options:UIViewAnimationOptionBeginFromCurrentState
                    animations:^{
                       // Configurate state view for hidden state
                       [weakSelf didHide];
                    } completion:^(BOOL finished) {
                       if (finished) {
                          // Inform delegate that state view did hide
                          if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(stateViewDidHide:)]) {
                             [weakSelf.delegate performSelector:@selector(stateViewDidHide:) withObject:weakSelf];
                          }
                       
                          // Remove state view from superview
                          [weakSelf removeFromSuperview];
                       }
                    }];
}



#pragma mark -

- (void)willShow {
   // Informing delegate that state view is going to be showed
   if (self.delegate && [self.delegate respondsToSelector:@selector(stateViewWillShow:)]) {
      [self.delegate performSelector:@selector(stateViewWillShow:) withObject:self];
   }
   
   // Prepare state view for appearing
   self.alpha = 0;
}


- (void)didShow {
   self.alpha = 1;
}


- (void)willHide {
   // Inform delegate that state view is going to hide
   if (self.delegate && [self.delegate respondsToSelector:@selector(stateViewWillHide:)]) {
      [self.delegate performSelector:@selector(stateViewWillHide:) withObject:self];
   }
   
   // Override in child
}


- (void)didHide {
   self.alpha = 0;
}


@end
