//
//  NSLayoutConstraint+Equations.h
//  Rubrik
//
//  Created by Morgan Harris on 24/01/13.
//  Copyright (c) 2013 Morgan Harris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSLayoutConstraint (Equations)

+ (NSLayoutConstraint *)constraintWithFormula:(NSString*)formula LHS:(id)lhs RHS:(id)rhs;

@end

@interface UIView (Equations)

- (NSLayoutConstraint *)constrain:(NSString*)formula to:(UIView*)otherView;
- (NSLayoutConstraint *)buildConstraint:(NSString *)formula with:(UIView *)otherView;
- (NSLayoutConstraint *)buildConstraint:(NSString *)formula with:(UIView *)otherView priority:(UILayoutPriority)priority;

@end