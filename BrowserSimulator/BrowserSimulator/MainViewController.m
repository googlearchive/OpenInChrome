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

#import "MainViewController.h"
#import "NSURL+XCallbackURL.h"

@interface MainViewController ()
@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) NSString *sourceApp;
@property (nonatomic, retain) NSURL *successURL;
@property (nonatomic, retain) NSMutableString* information;
@end

@implementation MainViewController

@synthesize flipsidePopoverController = flipsidePopoverController_;
@synthesize navigationBar = navigationBar_;
@synthesize webView = webView_;

@synthesize url = url_;
@synthesize sourceApp = sourceApp_;
@synthesize successURL = successURL_;
@synthesize information = information_;

#pragma mark -

- (void)dealloc {
  [flipsidePopoverController_ release];
  [navigationBar_ release];
  [url_ release];
  [sourceApp_ release];
  [successURL_ release];
  [information_ release];
  [webView_ release];
  
  [super dealloc];
}

#pragma mark - UIView lifecycle

- (void)viewDidLoad {
  [self load:nil];
}

#pragma mark -

- (void)load:(NSURL *)url {
  self.information = [NSMutableString string];
  if ([url isXCallbackURL]) {
    [self.information appendFormat:@"%@\n\n", [url absoluteString]];
    [self.information appendFormat:@"Chrome Scheme: %@\n\n", [url scheme]];
    [self.information appendString:@"URL is compliant with x-callback-url specs\n\n"];
    NSDictionary *params = [url xCallbackURL_queryParameters];

    BOOL createNewTab = [params objectForKey:@"create-new-tab"] != nil;

    self.url = [NSURL URLWithString:[params objectForKey:@"url"]];
    self.sourceApp = [params objectForKey:@"x-source"];
    self.successURL = [NSURL URLWithString:[params objectForKey:@"x-success"]];
    [self.information appendFormat:@"URL: %@\n", [self.url absoluteString]];
    [self.information appendFormat:@"SourceApp: %@\n", self.sourceApp];
    [self.information appendFormat:@"CallbackURL: %@\n",
        [self.successURL absoluteString]];
    [self.information appendFormat:@"create-new-tab: %@\n",
        createNewTab ? @"YES" : @"NO"];
  } else if (url) {
    [self.information appendFormat:@"%@\n\n", [url absoluteString]];
    [self.information appendFormat:@"Chrome Scheme: %@\n\n", [url scheme]];
    NSString *urlStr = [url absoluteString];
    NSRange fullRange = NSMakeRange(0, [urlStr length]);
    urlStr = [urlStr stringByReplacingOccurrencesOfString:@"googlechrome"
                                               withString:@"http"
                                                  options:NSAnchoredSearch
                                                    range:fullRange];
    self.url = [NSURL URLWithString:urlStr];
    self.sourceApp = nil;
    self.successURL = nil;
    [self.information appendFormat:@"URL: %@\n", [self.url absoluteString]];
  } else {
    self.url = nil;
    self.sourceApp = nil;
    self.successURL = nil;
  }
  
  [self.navigationBar setItems:[NSArray array] animated:NO];

  UINavigationItem *item =
      [[[UINavigationItem alloc] initWithTitle:nil] autorelease];
  item.title = self.sourceApp;
  [self.navigationBar pushNavigationItem:item animated:NO];

  item = [[[UINavigationItem alloc] initWithTitle:nil] autorelease];
  if (!self.sourceApp) {
    item.leftBarButtonItem =
        [[[UIBarButtonItem alloc] initWithTitle:@""
                                          style:UIBarButtonItemStyleBordered
                                         target:nil
                                         action:nil] autorelease];
  }

  UITextField *urlField =
      [[[UITextField alloc] initWithFrame:CGRectMake(0, 0,
          self.view.frame.size.width - 120, 30)] autorelease];
  urlField.backgroundColor = [UIColor whiteColor];
  urlField.font = [UIFont systemFontOfSize:14];
  urlField.adjustsFontSizeToFitWidth = YES;
  urlField.minimumFontSize = 10.0;
  urlField.contentVerticalAlignment = UIControlContentHorizontalAlignmentCenter;
  urlField.borderStyle = UITextBorderStyleRoundedRect;
  urlField.userInteractionEnabled = NO;
  item.titleView = urlField;
  urlField.text = [self.url absoluteString];

  UIBarButtonItem *infoButton =
      [[[UIBarButtonItem alloc] initWithTitle:@"Info"
                                        style:UIBarButtonItemStyleBordered
                                       target:self
                                       action:@selector(showInfo:)]
          autorelease];

  item.rightBarButtonItem = infoButton;

  [self.navigationBar pushNavigationItem:item animated:NO];

  if (self.url) {
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
  } else {
    [self.webView loadRequest:[NSURLRequest requestWithURL:
                                  [NSURL URLWithString:@"about:blank"]]];
  }
}

#pragma mark - UINavigationBarDelegate methods

- (BOOL)navigationBar:(UINavigationBar *)navigationBar
        shouldPopItem:(UINavigationItem *)item {
  if (self.successURL) {
    [[UIApplication sharedApplication] openURL:self.successURL];
    [self load:nil];
  }
  return NO;
}

#pragma mark - Flipside View Controller

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller {
  if ([[UIDevice currentDevice] userInterfaceIdiom] ==
      UIUserInterfaceIdiomPhone) {
    [self dismissViewControllerAnimated:YES completion:nil];
  } else {
    [self.flipsidePopoverController dismissPopoverAnimated:YES];
  }
}

- (void)showInfo:(id)sender {
  if ([[UIDevice currentDevice] userInterfaceIdiom] ==
      UIUserInterfaceIdiomPhone) {
    FlipsideViewController *controller = [[[FlipsideViewController alloc]
        initWithNibName:@"FlipsideViewController"
                 bundle:nil]
             autorelease];
    controller.delegate = self;
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:controller animated:YES completion:nil];
  } else {
    if (!self.flipsidePopoverController) {
      FlipsideViewController *controller = [[[FlipsideViewController alloc]
          initWithNibName:@"FlipsideViewController"
                   bundle:nil]
              autorelease];
      controller.delegate = self;

      self.flipsidePopoverController = [[[UIPopoverController alloc]
          initWithContentViewController:controller]
              autorelease];
    }
    if ([self.flipsidePopoverController isPopoverVisible]) {
      [self.flipsidePopoverController dismissPopoverAnimated:YES];
    } else {
      [self.flipsidePopoverController presentPopoverFromBarButtonItem:sender
          permittedArrowDirections:UIPopoverArrowDirectionAny
                          animated:YES];
    }
  }
}

@end
