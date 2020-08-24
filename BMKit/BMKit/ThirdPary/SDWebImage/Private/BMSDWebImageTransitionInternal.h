/*
* This file is part of the SDWebImage package.
* (c) Olivier Poitrey <rs@dailymotion.com>
*
* For the full copyright and license information, please view the LICENSE
* file that was distributed with this source code.
*/

#import "BMSDWebImageCompat.h"

#if BMSD_MAC

#import <QuartzCore/QuartzCore.h>

/// Helper method for Core Animation transition
FOUNDATION_EXPORT CAMediaTimingFunction * _Nullable SDTimingFunctionFromAnimationOptions(BMSDWebImageAnimationOptions options);
FOUNDATION_EXPORT CATransition * _Nullable SDTransitionFromAnimationOptions(BMSDWebImageAnimationOptions options);

#endif
