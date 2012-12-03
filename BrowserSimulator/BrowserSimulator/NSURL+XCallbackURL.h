// Copyright 2012, Google Inc.
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
//
//     * Redistributions of source code must retain the above copyright
// notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above
// copyright notice, this list of conditions and the following disclaimer
// in the documentation and/or other materials provided with the
// distribution.
//     * Neither the name of Google Inc. nor the names of its
// contributors may be used to endorse or promote products derived from
// this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
// OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
// LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
// THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import <Foundation/Foundation.h>

extern NSString * const kXCallbackURLHost;
extern NSString * const kSourceParameterName;
extern NSString * const kSuccessURLParameterName;
extern NSString * const kErrorURLParameterName;
extern NSString * const kCancelURLParameterName;

// This category provides method to handle URL Schemes conforming with the
// x-callback-url specifications (http://x-callback-url.com/ )
@interface NSURL (XCallbackURL)

// Returns an autoreleased NSURL compliant to the x-callback-url specs.
+ (NSURL *)XCallbackURLWithScheme:(NSString *)scheme
                           action:(NSString *)action
                           source:(NSString *)source
                       successURL:(NSURL *)successURL
                         errorURL:(NSURL *)errorURL
                        cancelURL:(NSURL *)cancelURL
                       parameters:(NSDictionary *)parameters;

// Returns a dictionary with all the parameters in the query string.
- (NSDictionary *)xCallbackURL_queryParameters;

// Returns YES if the URL is compliant to the x-callback-url specs.
- (BOOL)isXCallbackURL;

@end
