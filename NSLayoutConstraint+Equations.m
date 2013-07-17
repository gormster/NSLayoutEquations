//
//  NSLayoutConstraint+Equations.m
//  Rubrik
//
//  Created by Morgan Harris on 24/01/13.
//  Copyright (c) 2013 Morgan Harris. All rights reserved.
//

#import "NSLayoutConstraint+Equations.h"

#define PROPERTY "[a-zA-Z_][a-zA-Z0-9_]*"
#define WHITESPACE "\\s*"
#define RELATION "=|<|>"
#define NUMBER "\\d+(?:\\.\\d+)?"

@implementation NSLayoutConstraint (Equations)

+ (NSLayoutConstraint*) constraintWithFormula:(NSString *)formula LHS:(id)lhs RHS:(id)rhs
{
    //parse the formula
    //the format is property { = | < | > } [multiplier *] property [{ + | - } constant]
    //or if RHS is nil property { = | < | > } constant

    NSString *lhsPropertyString, *rhsPropertyString, *relationString;
    CGFloat multiplier = 1.0, constant = 0.0;

    static NSRegularExpression* expr = nil;
    static NSRegularExpression* constExpr = nil;
    static NSDictionary* layoutDict;
    static NSDictionary* relationDict;
    static dispatch_once_t onceToken;

    static int indexLHS = 1;
    static int indexRelation = 2;
    static int indexMultiplier = 3;
    static int indexConstant_noRHS = 3; // Used to index unary view expressions
    static int indexRHS = 4;
    static int indexOp = 5;
    static int indexConstant = 6;

    dispatch_once(&onceToken, ^{
        NSString* pattern = @"(" PROPERTY ")" WHITESPACE "(" RELATION ")" WHITESPACE "(?:(" NUMBER ")" WHITESPACE "\\*)?" WHITESPACE "(" PROPERTY ")" WHITESPACE "(?:([\\+-])" WHITESPACE "(" NUMBER "))?";
        NSError* err;
        expr = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&err];
        if (expr == nil) {
            NSLog(@"%@",err);
            abort();
        }

        pattern = @"(" PROPERTY ")" WHITESPACE "(" RELATION ")" WHITESPACE "(" NUMBER ")";
        constExpr = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&err];
        if (constExpr == nil) {
            NSLog(@"%@",err);
            abort();
        }

        layoutDict = @{
                       @"baseline" : @(NSLayoutAttributeBaseline),
                       @"bottom" : @(NSLayoutAttributeBottom),
                       @"centerX" : @(NSLayoutAttributeCenterX),
                       @"centerY" : @(NSLayoutAttributeCenterY),
                       @"height" : @(NSLayoutAttributeHeight),
                       @"leading" : @(NSLayoutAttributeLeading),
                       @"left" : @(NSLayoutAttributeLeft),
                       @"right" : @(NSLayoutAttributeRight),
                       @"top" : @(NSLayoutAttributeTop),
                       @"trailing" : @(NSLayoutAttributeTrailing),
                       @"width" : @(NSLayoutAttributeWidth)
                       };

        relationDict = @{
                         @"=" : @(NSLayoutRelationEqual),
                         @"<" : @(NSLayoutRelationLessThanOrEqual),
                         @">" : @(NSLayoutRelationGreaterThanOrEqual)
                         };
    });


    if (rhs == nil) {
        NSTextCheckingResult* rslt = [constExpr firstMatchInString:formula options:0 range:NSMakeRange(0, formula.length)];

        lhsPropertyString = [formula substringWithRange:[rslt rangeAtIndex:indexLHS]];
        relationString = [formula substringWithRange:[rslt rangeAtIndex:indexRelation]];
        constant = [[formula substringWithRange:[rslt rangeAtIndex:indexConstant_noRHS]] floatValue];

        NSLayoutAttribute lhsAttribute = [layoutDict[lhsPropertyString] integerValue];
        NSLayoutRelation relation = [relationDict[relationString] integerValue];

        return [self constraintWithItem:lhs
                              attribute:lhsAttribute
                              relatedBy:relation
                                 toItem:nil
                              attribute:NSLayoutAttributeNotAnAttribute
                             multiplier:1.0
                               constant:constant];
    } else {

        NSTextCheckingResult* rslt = [expr firstMatchInString:formula options:0 range:NSMakeRange(0, formula.length)];

        //assign our strings
        lhsPropertyString = [formula substringWithRange:[rslt rangeAtIndex:indexLHS]];
        relationString = [formula substringWithRange:[rslt rangeAtIndex:indexRelation]];

        if ([rslt rangeAtIndex:indexMultiplier].length > 0) {
            multiplier = [[formula substringWithRange:[rslt rangeAtIndex:indexMultiplier]] floatValue];
        }

        rhsPropertyString = [formula substringWithRange:[rslt rangeAtIndex:indexRHS]];

        if ([rslt rangeAtIndex:indexConstant].length > 0) {
            NSString *op = [formula substringWithRange:[rslt rangeAtIndex:indexOp]];
            constant = [[formula substringWithRange:[rslt rangeAtIndex:indexConstant]] floatValue];

            if ([op isEqual:@"-"]) {
                constant *= -1;
            }
        }

        //translate property strings to properties
        NSLayoutAttribute lhsAttribute = [layoutDict[lhsPropertyString] integerValue];
        NSLayoutAttribute rhsAttribute = [layoutDict[rhsPropertyString] integerValue];

        NSLayoutRelation relation = [relationDict[relationString] integerValue];

        return [self constraintWithItem:lhs
                              attribute:lhsAttribute
                              relatedBy:relation
                                 toItem:rhs
                              attribute:rhsAttribute
                             multiplier:multiplier
                               constant:constant];
    }
}

@end

@implementation UIView (Equations)

- (NSLayoutConstraint *)buildConstraint:(NSString *)formula with:(UIView *)otherView priority:(UILayoutPriority)priority
{
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithFormula:formula LHS:self RHS:otherView];
    constraint.priority = priority;
    return constraint;
}

- (NSLayoutConstraint *)buildConstraint:(NSString *)formula with:(UIView *)otherView
{
    // Build constraints a bit more naturally

    return [self buildConstraint:formula with:otherView priority:UILayoutPriorityRequired];
}

- (NSLayoutConstraint *)constrain:(NSString *)formula to:(UIView *)otherView
{
    NSAssert([self isEqual:otherView] == NO, @"can't constrain a view to itself");

    UIView* commonSuperview = nil;

    if (otherView != nil) {
        // The first thing we do is find the closest common ancestor.
        // We do this by adding all the ancestors, one by one, to two sets
        // As soon as they have a common object, we've got the closest
        // common ancestor.
        NSMutableSet * s1, * s2;
        s1 = [NSMutableSet setWithObject:self];
        s2 = [NSMutableSet setWithObject:otherView];

        UIView* v1 = self, *v2 = otherView;

        do {
            v1 = v1.superview;
            v2 = v2.superview;
            if (v1)
                [s1 addObject:v1];
            if (v2)
                [s2 addObject:v2];

            if ([s1 intersectsSet:s2]) {
                [s1 intersectSet:s2];
                commonSuperview = [s1 anyObject];
                break;
            }
        } while (v1 && v2);

        NSAssert(commonSuperview != nil, @"no common superview");
    } else {
        commonSuperview = self.superview;
    }

    //Now we've got the closest common ancestor, we just make the constraint and add it
    NSLayoutConstraint* constraint = [self buildConstraint:formula with:otherView];
    [commonSuperview addConstraint:constraint];
    return constraint;
}

@end
