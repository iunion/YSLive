/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 * (c) Jamie Pinkham
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "BMSDWebImageCompat.h"

FOUNDATION_EXPORT NSErrorDomain const _Nonnull BMSDWebImageErrorDomain;

/// The response instance for invalid download response (NSURLResponse *)
FOUNDATION_EXPORT NSErrorUserInfoKey const _Nonnull BMSDWebImageErrorDownloadResponseKey;
/// The HTTP status code for invalid download response (NSNumber *)
FOUNDATION_EXPORT NSErrorUserInfoKey const _Nonnull BMSDWebImageErrorDownloadStatusCodeKey;
/// The HTTP MIME content type for invalid download response (NSString *)
FOUNDATION_EXPORT NSErrorUserInfoKey const _Nonnull BMSDWebImageErrorDownloadContentTypeKey;

/// SDWebImage error domain and codes
typedef NS_ERROR_ENUM(BMSDWebImageErrorDomain, BMSDWebImageError) {
    BMSDWebImageErrorInvalidURL = 1000, // The URL is invalid, such as nil URL or corrupted URL
    BMSDWebImageErrorBadImageData = 1001, // The image data can not be decoded to image, or the image data is empty
    BMSDWebImageErrorCacheNotModified = 1002, // The remote location specify that the cached image is not modified, such as the HTTP response 304 code. It's useful for `SDWebImageRefreshCached`
    BMSDWebImageErrorBlackListed = 1003, // The URL is blacklisted because of unrecoverable failure marked by downloader (such as 404), you can use `.retryFailed` option to avoid this
    BMSDWebImageErrorInvalidDownloadOperation = 2000, // The image download operation is invalid, such as nil operation or unexpected error occur when operation initialized
    BMSDWebImageErrorInvalidDownloadStatusCode = 2001, // The image download response a invalid status code. You can check the status code in error's userInfo under `SDWebImageErrorDownloadStatusCodeKey`
    BMSDWebImageErrorCancelled = 2002, // The image loading operation is cancelled before finished, during either async disk cache query, or waiting before actual network request. For actual network request error, check `NSURLErrorDomain` error domain and code.
    BMSDWebImageErrorInvalidDownloadResponse = 2003, // When using response modifier, the modified download response is nil and marked as failed.
    BMSDWebImageErrorInvalidDownloadContentType = 2004, // The image download response a invalid content type. You can check the MIME content type in error's userInfo under `SDWebImageErrorDownloadContentTypeKey`
};
