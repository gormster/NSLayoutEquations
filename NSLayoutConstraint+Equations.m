//
//  NSLayoutConstraint+Equations.m
//  Rubrik
//
//  Created by Morgan Harris on 24/01/13.
//  Copyright (c) 2013 Morgan Harris. All rights reserved.
//

#import "NSLayoutConstraint+Equations.h"

@implementation NSLayoutConstraint (Equations)

+ (NSLayoutConstraint*) constraintWithFormula:(NSString *)formula LHS:(id)lhs RHS:(id)rhs
{
    //parse the formula
    //the format is property { = | < | > } [multiplier *] property [+ constant]
    
    NSString *lhsPropertyString, *rhsPropertyString, *relationString;
    CGFloat multiplier = 1.0, constant = 0.0;
    
    static NSRegularExpression* expr = nil;
    static NSDictionary* layoutDict;
    static NSDictionary* relationDict;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString* pattern = @"([a-zA-Z_][a-zA-Z0-9_]*)\\s*(=|<|>)\\s*(?:(\\d+(?:\\.\\d+)?)\\s*\\*)?\\s*([a-zA-Z_][a-zA-Z0-9_]+)\\s*(?:\\+\\s*(\\d+(?:\\.\\d+)?))?";
        NSError* err;
        expr = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&err];
        if (expr == nil) {
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
    
    NSTextCheckingResult* rslt = [expr firstMatchInString:formula options:0 range:NSMakeRange(0, formula.length)];
    
    //assign our strings
    lhsPropertyString = [formula substringWithRange:[rslt rangeAtIndex:1]];
    relationString = [formula substringWithRange:[rslt rangeAtIndex:2]];
    
    if ([rslt rangeAtIndex:3].length > 0) {
        multiplier = [[formula substringWithRange:[rslt rangeAtIndex:3]] floatValue];
    }
    
    rhsPropertyString = [formula substringWithRange:[rslt rangeAtIndex:4]];
    
    if ([rslt rangeAtIndex:5].length > 0) {
        constant = [[formula substringWithRange:[rslt rangeAtIndex:5]] floatValue];
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

@end

@implementation UIView (Equations)

-(void) constrain:(NSString *)formula to:(UIView *)otherView
{
    if ([self isEqual:otherView]) {
        //can't constrain a view to itself
        //TODO: do this properly
        @throw [NSError errorWithDomain:@"Layout" code:-1 userInfo:nil];
    }
    
    // The first thing we do is find the closest common ancestor.
    // We do this by adding all the ancestors, one by one, to two sets
    // As soon as they have a common object, we've got the closest
    // common ancestor.
    NSMutableSet * s1, * s2;
    s1 = [NSMutableSet setWithObject:self];
    s2 = [NSMutableSet setWithObject:otherView];
    
    UIView* v1 = self, *v2 = otherView;
    UIView* commonSuperview = nil;

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
    
    if (commonSuperview == nil) {
        //no common superview
        //TODO: do this properly
        @throw [NSError errorWithDomain:@"Layout" code:-2 userInfo:nil];
    }
    
    //Now we've got the closest common ancestor, we just make the constraint and add it
    NSLayoutConstraint* constraint = [NSLayoutConstraint constraintWithFormula:formula LHS:self RHS:otherView];
    [commonSuperview addConstraint:constraint];
    
}

@end