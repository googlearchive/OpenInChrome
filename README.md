# Opening links in Chrome for iOS #
The easiest way to have your iOS app open links in Chrome is to use the OpenInChromeController class. This API is described here along with the URI schemes it supports.

## Using OpenInChromeController to open links ##
The `OpenInChromeController` class provides methods that encapsulate the URI schemes and the scheme replacement process also described in this document. Use this class to check if Chrome is installed, to specify the URL to open, to provide a callback URL, and to force opening in a new tab.

### Methods ###
  * `isChromeInstalled`: returns YES if Chrome is installed
  * `openInChrome`: opens a given URL in Chrome; can be used with or without the following
    * `withCallbackURL`: the URL to which a callback is sent
    * `createNewTab`: forces the calling app to open the URL in a new tab

For example, use the OpenInChromeController class as follows:
```
if ([openInController_ isChromeInstalled]) {
  [openInController_ openInChrome:urlToOpen
     withCallbackURL:callbackURL
     createNewTab:createNewTab];
}
```

## Downloading the class file ##
The OpenInChromeController class file is available [here](https://github.com/GoogleChrome/OpenInChrome). Copy it into your Xcode installation.

The rest of this document describes the underpinnings of this API.

## URI schemes ##

Chrome for iOS handles the following URI Schemes:
  * `googlechrome` for http
  * `googlechromes` for https
  * `googlechrome-x-callback` for callbacks

To check if Chrome is installed, an app can simply check if either of these URI schemes is available:
```
[[UIApplication sharedApplication] canOpenURL:
    [NSURL URLWithString:@"googlechrome://"]];
```

This step is useful in case an app would like to change the UI depending on if Chrome is installed or not. For instance the app could add an option to open URLs in Chrome in a share menu or action sheet.

To actually open a URL in Chrome, the URI scheme provided in the URL must be changed from `http` or `https` to the Google Chrome equivalent. 

The following sample code opens a URL in Chrome:
```
NSURL *inputURL = <the URL to open>;
NSString *scheme = inputURL.scheme;

// Replace the URL Scheme with the Chrome equivalent.
NSString *chromeScheme = nil;
if ([scheme isEqualToString:@"http"]) {
  chromeScheme = @"googlechrome";
} else if ([scheme isEqualToString:@"https"]) {
  chromeScheme = @"googlechromes";
}

// Proceed only if a valid Google Chrome URI Scheme is available.
if (chromeScheme) {
  NSString *absoluteString = [inputURL absoluteString];
  NSRange rangeForScheme = [absoluteString rangeOfString:@":"];
  NSString *urlNoScheme =
      [absoluteString substringFromIndex:rangeForScheme.location];
  NSString *chromeURLString =
      [chromeScheme stringByAppendingString:urlNoScheme];
  NSURL *chromeURL = [NSURL URLWithString:chromeURLString];

  // Open the URL with Chrome.
  [[UIApplication sharedApplication] openURL:chromeURL];
}
```

If Chrome is installed, the above code converts the URI scheme found in the URL to the Google Chrome equivalent. When Google Chrome opens, the URL passed as a parameter will be opened in a new tab.

If Chrome is not installed the user can be prompted to download it from the App Store. If the user agrees, the app can open the App Store download page using the following:
```
[[UIApplication sharedApplication] openURL:[NSURL URLWithString:
    @"itms-apps://itunes.apple.com/us/app/chrome/id535886823"]];
```

## Using the x-callback-url registration scheme to return ##
Chrome for iOS also supports [x-callback-url](http://x-callback-url.com/specifications/), an open specification for inter-app communications and messaging between iOS apps that provides a way for the application opened in Chrome to specify a callback URL to return to the calling app. Applications supporting `x-callback-url` have to register a URL scheme that will be used to call the app with compliant URLs.

The URI scheme that Chrome registers for x-callback-url is:
  * `googlechrome-x-callback`

This scheme will accept `x-callback-url` compliant URLs with the *open* action and the following parameters:
  * `url`: (required) the URL to open
  * `x-success`: (optional) the URL to call for the return when the operation completes successfully
  * `x-source`: (optional; required if x-success is specified): the application name to where the calling app returns
  * `create-new-tab`: (optional) forces the creation of a new tab in the calling app

For example:
```
googlechrome-x-callback://x-callback-url/open/?url=http%3A%2F%2Fwww.google.com
```

## Checking if x-callback-url is available in Chrome ##

The `x-callback-url` parameters are supported in Google Chrome as of version 23.0. Previous versions of Chrome are not registered for the `googlechrome-x-callback` URL scheme. It’s important for apps to check if the URL scheme is registered before trying to invoke the `googlechrome-x-callback` scheme.

To check if Chrome with `x-callback-url` is installed, an app can use the following code:
```
[[UIApplication sharedApplication] canOpenURL:
    [NSURL URLWithString:@"googlechrome-x-callback://"]];
```

Once it has been determined that Google Chrome with `x-callback-url` is installed, the app can then open a URL in Chrome specifying a callback URL as in the following example.
```
// Method to escape parameters in the URL.
static NSString * encodeByAddingPercentEscapes(NSString *input) {
  NSString *encodedValue =
      (NSString *)CFURLCreateStringByAddingPercentEscapes(
          kCFAllocatorDefault,
          (CFStringRef)input,
          NULL,
          (CFStringRef)@"!*'();:@&=+$,/?%#[]",
          kCFStringEncodingUTF8);
  return [encodedValue autorelease];
}
…
NSString *appName =
    [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
NSURL *inputURL = <the URL to open>;
NSURL *callbackURL = <the callback URL>;

NSString *scheme = inputURL.scheme;

// Proceed only if scheme is http or https.
if ([scheme isEqualToString:@"http"] ||
    [scheme isEqualToString:@"https"]) {
  NSString *chromeURLString = [NSString stringWithFormat:
      @"googlechrome-x-callback://x-callback-url/open/?x-source=%@&x-success=%@&url=%@",
      encodeByAddingPercentEscapes(appName),
      encodeByAddingPercentEscapes([callbackURL absoluteString]),
      encodeByAddingPercentEscapes([inputURL absoluteString])];
  NSURL *chromeURL = [NSURL URLWithString:chromeURLString];

  // Open the URL with Google Chrome.
  [[UIApplication sharedApplication] openURL:chromeURL];
}
```

## Enabling a callback with x-success ##
The calling application can also specify a URL as callback when the user finishes the navigation using the `x-success` parameter in the `x-callback-url`. When specifying `x-success` with the callback URL you must also specify the application name (via the `x-source` parameter), which will be displayed in Chrome as a hint to the user for how to return to the calling application. Failing to provide the app name will result in the `x-success` parameter to be discarded and ignored.

For example:
```
googlechrome-x-callback://x-callback-url/open/?x-source=MyApp&x-success=com.myapp.callback%3A%2F%2F&url=http%3A%2F%2Fwww.google.com
```

In this case the callback URL specified is `com.myapp.callback://` and Chrome will call back to the calling app on that URL when the user has finished the navigation. The application name, specified using the x-source parameter, is *MyApp*, and it will be shown as a replacement of the back button when the user can return to the calling application.

### Creating a new tab ###
By default, Chrome reuses the same tab when opened by the same application. To override this default behavior, the calling app should provide the `create-new-tab` parameter as part of the action parameter in the x-callback-url URL.
For example:
```
googlechrome-x-callback://x-callback-url/open/?x-source=MyApp&x-success=com.myapp.callback%3A%2F%2F&url=http%3A%2F%2Fwww.google.com&create-new-tab
```

