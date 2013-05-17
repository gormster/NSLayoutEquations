# NSLayoutConstraint+Equations.h

This adds two new methods to make constraints easier.

## The Formulae

The formula for constraints is simple: it's just `y = m * x + b`. Of course it can also be `y < m * x + b` or `y > m * x + b`. This is *exactly* what you'll write with these methods.

The format is:

    formula = <attribute> ( "=" | "<" | ">" ) [ <multiplier> "*" ] <attribute> [ "+" <constant> ]
    attribute = "baseline" | "bottom" | "centerX" | "centerY" | "height" | "leading" | "left" | "right" | "top" | "trailing" | "width"
    multiplier = <real-number>
    constant = <real-number>
    
With the forumla you supply references to the two views being constrainted as `LHS` and `RHS` (being left-hand and right-hand side respectively). The `attribute`s in the formula correspond to attribtues on these views.

There is a second format for simple constant constraints. It is:

    formula = <attribute> ( "=" | "<" | ">" ) <constant>

This format is invoked if RHS == nil.

## The methods

###  +[NSLayoutConstraint constraintWithFormula:LHS:RHS:]

**Signature** : `+ (NSLayoutConstraint*) constraintWithFormula:(NSString *)formula LHS:(id)lhs RHS:(id)rhs`

This generates a layout constraint with the formula used, referencing the two views passed in. Simple enough. Pass in nil for `rhs` if you're making a constant constraint.

###  -[UIView constrain:to:]

**Signature** : `-(void) constrain:(NSString *)formula to:(UIView *)otherView`

This generates a layout constraint using `constraintWithFormula:LHS:RHS:` with `self` as the LHS and `otherView` as the RHS, then finds the closest common ancestor of those two views and adds the constraint on it. If no common ancestor is found, an exception is thrown.

## Examples

Let's do some examples. Say I want the widths of two views to be equal, I would say:

    [NSLayoutConstraint constraintWithFormula:@"width = width" LHS:aView RHS:anotherView];

which is equivalent to:
    
    [NSLayoutConstraint constraintWithItem:aView
                                     attribute:NSLayoutAttributeWidth
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:anotherView
                                     attribute:NSLayoutAttributeWidth
                                    multiplier:1.0
                                      constant:0.0];

Or, if I really wanted to save time, I could write:

    [aView constrain:@"width = width" to:anotherView]

This has a slight performance penalty, as the common superview must be determined by code - but it's an extremely minimal penalty, especially if the view hierarchy is simple.

Something a bit more complicated: I have two side-by-side views and want to make sure the view on the right is always twice the width of the view on the left, and is always separated by ten points of space. Let's set up *all* the required constraints, even though you'd usually use the visual format for most of it. Our three views are called `leftView`, `rightView` and `superview`.

    [leftView constrain:@"leading = leading + 10" to:superview]
    [rightView constrain:@"trailing = trailing - 10" to:superview]
    [leftView constrain:@"trailing = leading - 10" to:rightView]
    [leftView constrain:@"top = top + 10" to:superview]
    [rightView constrain:@"top = top + 10" to:superview]
    [leftView constrain:@"bottom = bottom - 10" to:superview]
    [rightView constrain:@"bottom = bottom - 10" to:superview]
    [rightView constrain:@"width = 2 * width" to:leftView]