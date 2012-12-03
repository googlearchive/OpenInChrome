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

#import "NSURL+XCallbackURL.h"

NSString * const kXCallbackURLHost = @"x-callback-url";
NSString * const kSourceParameterName = @"x-source";
NSString * const kSuccessURLParameterName = @"x-success";
NSString * const kErrorURLParameterName = @"x-error";
NSString * const kCancelURLParameterName = @"x-cancel";

// Encodes the |input| string adding percentage escapes for certain chars.
static NSString* encodeByAddingPercentEscapes(NSString *input) {
  NSString *encodedValue =
      (NSString *)CFURLCreateStringByAddingPercentEscapes(
          kCFAllocatorDefault,
          (CFStringRef)input,
          NULL,
          (CFStringRef)@"!*'();:@&=+$,/?%#[]",
          kCFStringEncodingUTF8);
  return [encodedValue autorelease];
}

// Decodes the |input| string replacing percentage escapes for certain chars.
static NSString* decodeByReplacingPercentEscapes(NSString *input) {
  NSString *decodedCallbackURLString =
      (NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(
          kCFAllocatorDefault,
          (CFStringRef)input,
          CFSTR(""),
          kCFStringEncodingUTF8);
  return [decodedCallbackURLString autorelease];
}

@implementation NSURL (XCallbackURL)

+ (NSURL *)XCallbackURLWithScheme:(NSString *)scheme
                           action:(NSString *)action
                           source:(NSString *)source
                       successURL:(NSURL *)successURL
                         errorURL:(NSURL *)errorURL
                        cancelURL:(NSURL *)cancelURL
                       parameters:(NSDictionary *)parameters {
  if (!scheme) {
    return nil;
  }
  NSMutableString *urlString = [NSMutableString string];
  if (!action) {
    action = @"";
  }
  [urlString appendFormat:@"%@://%@/%@",
      scheme, kXCallbackURLHost, encodeByAddingPercentEscapes(action)];

  NSMutableArray *paramsArray = [NSMutableArray array];

  if (source) {
    [paramsArray addObject:[NSString stringWithFormat:@"%@=%@",
        kSourceParameterName,
        encodeByAddingPercentEscapes(source)]];
  }

  if (successURL) {
    [paramsArray addObject:[NSString stringWithFormat:@"%@=%@",
        kSuccessURLParameterName,
        encodeByAddingPercentEscapes([successURL absoluteString])]];
  }

  if (errorURL) {
    [paramsArray addObject:[NSString stringWithFormat:@"%@=%@",
        kErrorURLParameterName,
        encodeByAddingPercentEscapes([errorURL absoluteString])]];
  }

  if (cancelURL) {
    [paramsArray addObject:[NSString stringWithFormat:@"%@=%@",
        kCancelURLParameterName,
        encodeByAddingPercentEscapes([cancelURL absoluteString])]];
  }

  NSArray *paramKeys = [parameters allKeys];
  for (NSUInteger i = 0; i < [paramKeys count]; i++) {
    NSString *key = [paramKeys objectAtIndex:i];
    id value = [parameters objectForKey:key];
    if ([NSNull null] != value) {
      [paramsArray addObject:[NSString stringWithFormat:@"%@=%@",
          encodeByAddingPercentEscapes(key),
          encodeByAddingPercentEscapes(value)]];
    } else {
      [paramsArray addObject:[NSString stringWithFormat:@"%@",
          encodeByAddingPercentEscapes(key)]];
    }
  }

  if ([paramsArray count]) {
    [urlString appendFormat:@"?%@",
        [paramsArray componentsJoinedByString:@"&"]];
  }

  return [NSURL URLWithString:urlString];
}

- (NSDictionary *)xCallbackURL_queryParameters {
  NSString *query = [self query];
  NSMutableDictionary *queryParams = [NSMutableDictionary dictionary];
  for (NSString *keyValuePair in [query componentsSeparatedByString:@"&"]) {
    NSArray *keyAndValueArray = [keyValuePair componentsSeparatedByString:@"="];
    if ([keyAndValueArray count] < 1) {
      continue;
    }
    NSString *key =
        decodeByReplacingPercentEscapes([keyAndValueArray objectAtIndex:0]);
    id value = [NSNull null];
    if ([keyAndValueArray count] > 1) {
      value =
          decodeByReplacingPercentEscapes([keyAndValueArray objectAtIndex:1]);
    }
    [queryParams setObject:value forKey:key];
  }
  return queryParams;
}

- (BOOL)isXCallbackURL {
  return [[self host] isEqualToString:kXCallbackURLHost];
}

@end
