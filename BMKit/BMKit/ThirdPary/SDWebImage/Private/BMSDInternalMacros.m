/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "BMSDInternalMacros.h"

void bmsd_executeCleanupBlock (__strong bmsd_cleanupBlock_t *block) {
    (*block)();
}
