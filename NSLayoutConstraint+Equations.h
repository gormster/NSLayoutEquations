//
//  NSLayoutConstraint+Equations.h
//  Rubrik
//
//  Created by Morgan Harris on 24/01/13.
//  Copyright (c) 2013 Morgan Harris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSLayoutConstraint (Equations)

+ (NSLayoutConstraint*) constraintWithFormula:(NSString*)formula LHS:(id)lhs RHS:(id)rhs;

@end

@interface UIView (Equations)

- (void) constrain:(NSString*)formula to:(UIView*)otherView;

@end