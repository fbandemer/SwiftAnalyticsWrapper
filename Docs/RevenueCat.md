@ -0,0 +1,641 @@
Initialize and Configure the SDK

📘ONLY USE YOUR PUBLIC SDK KEY TO CONFIGURE PURCHASES
You can get your public SDK key from the API keys tab under Project settings in the dashboard.
You should only configure the shared instance of Purchases once, usually on app launch. After that, the same instance is shared throughout your app by accessing the .shared instance in the SDK.

See our guide on Configuring SDK for more information and best practices.

Make sure you configure Purchases with your public SDK key only. This API key can be found in the API Keys Project settings page. You can read more about the different API keys available in our Authentication guide.

Swift
Obj-C
Kotlin
Kotlin Multiplatform
Java
Flutter
React Native
Capacitor
Cordova
Unity
// on iOS and tvOS, use `application:didFinishLaunchingWithOptions:`
// on macOS and watchOS use `applicationDidFinishLaunching:`

func application(_ application: UIApplication,
                 didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

    Purchases.logLevel = .debug
    Purchases.configure(withAPIKey: <revenuecat_project_apple_api_key>, appUserID: <app_user_id>)

}


The app_user_id field in .configure is how RevenueCat identifies users of your app. You can provide a custom value here or omit it for us to generate an anonymous id. For more information, see our Identifying Users guide.

When in development, we recommend enabling more verbose debug logs. For more information about these logs, see our Debugging guide.

If you're planning to use RevenueCat alongside your existing purchase code, be sure to tell the SDK that your app will complete the purchases

📘CONFIGURING PURCHASES WITH USER IDS
If you have a user authentication system in your app, you can provide a user identifier at the time of configuration or at a later date with a call to .logIn(). To learn more, check out our guide on Identifying Users.
Present a Paywall

At this point, you're ready to present a paywall to your users. If you skipped the paywall setup earlier, that's okay! The SDK will display a default, non-customized paywall. If you want to customize a paywall first, head back up to the Build and Design Your Paywall section.

The SDK will automatically fetch the configured Offerings and retrieve the product information from Apple, Google, or Amazon. Thus, available products will already be loaded when customers launch your paywall.

Presenting a paywall varies depending on your platform. See Displaying Paywalls to see in-depth examples for each platform.

Present a Paywall →

Want to display your products manually? See Displaying Products.

SDK not fetching products or offerings?

A common issue when displaying your paywall or making a purchase is missing or empty offerings. This is almost always a configuration issue.

If you're running into this error, please see our community post for troubleshooting steps.

Make a Purchase

Once your paywall is presented, select one of your products to make a purchase. The SDK will handle the purchase flow automatically and send the purchase information to RevenueCat. The RevenueCat SDK will automatically handle sandbox vs. production environments.

Each platform requires slightly different configuration steps to test in sandbox. See Sandbox Testing for more information.

When the purchase is complete, you can find the purchase associated to the customer in the RevenueCat dashboard. You can search for the customer by their App User ID that you configured, or by the automatically assigned $RCAnonymousID that you'll find in your logs.

Note: RevenueCat always validates transactions with the respective store. The dashboard will only reflect purchases that have been successfully validated by the store.

Additionally, the SDK will automatically update the customer's CustomerInfo object with the new purchase information. This object contains all the information about the customer's purchases and subscriptions.

Want to manually call the purchase method? See Making Purchases.

Check Subscription Status

The SDK makes it easy to check what active subscriptions the current customer has, too. This can be done by checking a user's CustomerInfo object to see if a specific Entitlement is active, or by checking if the active Entitlements array contains a specific Entitlement ID.

If you're not using Entitlements (you probably should be!) you can check the array of active subscriptions to see what product IDs from the respective store it contains.

Swift
Obj-C
Kotlin
Kotlin Multiplatform
Java
Flutter
React Native
Capacitor
Cordova
Unity
Web
// Using Swift Concurrency
let customerInfo = try await Purchases.shared.customerInfo()
if customerInfo.entitlements.all[<your_entitlement_id>]?.isActive == true {
    // User is "premium"
}
// Using Completion Blocks
Purchases.shared.getCustomerInfo { (customerInfo, error) in
    if customerInfo?.entitlements.all[<your_entitlement_id>]?.isActive == true {
        // User is "premium"
    }
}


You can use this method whenever you need to get the latest status, and it's safe to call this repeatedly throughout the lifecycle of your app. Purchases automatically caches the latest CustomerInfo whenever it updates — so in most cases, this method pulls from the cache and runs very fast.

It's typical to call this method when deciding which UI to show the user and whenever the user performs an action that requires a certain entitlement level.

📘HERE'S A TIP!
You can access a lot more information about a subscription than simply whether it's active or not. See our guide on Subscription Status to learn if subscription is set to renew, if there's an issue detected with the user's credit card, and more.
Reacting to Subscription Status Changes

You can respond to any changes in a customer's CustomerInfo by conforming to an optional delegate method, purchases:receivedUpdated:.

This method will fire whenever the SDK receives an updated CustomerInfo object from calls to getCustomerInfo(), purchase(package:), purchase(product:), or restorePurchases().

Note: CustomerInfo updates are not pushed to your app from the RevenueCat backend, updates can only happen from an outbound network request to RevenueCat, as mentioned above.

Depending on your app, it may be sufficient to ignore the delegate and simply handle changes to customer information the next time your app is launched or in the completion blocks of the SDK methods.

Swift
Obj-C
Kotlin
Kotlin Multiplatform
Java
Flutter
React Native
Capacitor
Cordova
Unity
// Additional configure setup
// on iOS and tvOS, use `application:didFinishLaunchingWithOptions:`
// on macOS and watchOS use `applicationDidFinishLaunching:` 

func application(_ application: UIApplication,
                 didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

    Purchases.logLevel = .debug
    Purchases.configure(withAPIKey: <revenuecat_api_key>)
    Purchases.shared.delegate = self // make sure to set this after calling configure

    return true
}

extension AppDelegate: PurchasesDelegate {
    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        /// - handle any changes to the user's CustomerInfo
    }
}


Restore Purchases

RevenueCat enables your users to restore their in-app purchases, reactivating any content that they previously purchased from the same store account (Apple, Google, or Amazon account). We recommend that all apps have some way for users to trigger the restore method. Note that Apple does require a restore mechanism in the event a user loses access to their purchases (e.g: uninstalling/reinstalling the app, losing their account information, etc).

By default, RevenueCat Paywalls include a 'Restore Purchases' button. You can also trigger this method programmatically.

Swift
Obj-C
Kotlin
Kotlin Multiplatform
Java
Flutter
React Native
Capacitor
Cordova
Unity
Purchases.shared.restorePurchases { customerInfo, error in
    // ... check customerInfo to see if entitlement is now active
}


If two different App User IDs restore transactions from the same underlying store account (Apple, Google, or Amazon account) RevenueCat may attempt to create an alias between the two App User IDs and count them as the same user going forward. See our guide on Restoring Purchases for more information on the different configurable restore behaviors.

👍YOU DID IT!
You have now implemented a fully-featured subscription purchasing system without spending a month writing server code. Congrats!


Initialization

Once you've installed the SDK for your app, it's time to initialize and configure it.

You should only configure Purchases once, usually early in your application lifecycle. After configuration, the same instance is shared throughout your app by accessing the .shared instance in the SDK.

Make sure you configure Purchases with your public SDK key only. You can read more about the different API keys available in our Authentication guide.

Note: If you're using a hybrid SDK, such as React Native or Flutter, you'll need to initialize the SDK with a separate API key for each platform (i.e., iOS and Android). The keys can be found in the RevenueCat dashboard under Project Settings > API keys > App specific keys.

SwiftUI
Swift
Objective-C
Kotlin
Kotlin MP
Java
Flutter
React Native
Cordova
Capacitor
Unity
Web (JS/TS)
import RevenueCat

@main
struct SampleApp: App {
    init() {
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: <public_apple_api_key>, appUserID: <app_user_id>)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}


Enabling Debug Logs

Be sure to enable and view debug logs while implementing the SDK and testing your app. Debug logs contain important information about what's happening behind the scenes and should be the first thing you check if your app is behaving unexpectedly.

As detailed in the sample code above, debug logs can be enabled or disabled by setting the Purchases.logLevel property before configuring Purchases.

Debug logs will provide detailed log output in Xcode or LogCat for what is going on behind the scenes and should be the first thing you check if your app is behaving unexpectedly, and also to confirm there aren't any unhandled warnings or errors.

Additional Configuration

The SDK allows additional configuration on first setup:

API Key (required): The public API key that corresponds to your app, found via Project Settings > API keys > App specific keys in the RevenueCat dashboard.
App User ID (optional): An identifier for the current user. Pass null if you don't have a user identifier at the time of configuration, RevenueCat will generate an anonymous App User ID for you. See our guide on identifying users for more information.
Purchases Completed By (optional): A boolean value to tell RevenueCat not to complete purchases. Only set purchase completion to your app if you have your own code handling purchases.
User Defaults (optional, iOS only): A key to override the standard user defaults used to cache CustomerInfo. This is required if you need to access CustomerInfo in an iOS App Extension.
Proxies & configuration for users in Mainland China

We’ve received reports of our API being blocked in mainland China.

While we work on a long-term solution, if your app has a significant user base in this region, set the proxyURL property to https://api.rc-backup.com/ before initializing the RevenueCat SDK. Ensure this configuration occurs prior to SDK setup to prevent connection issues for users in mainland China.

📘IF YOU ALREADY HAVE A PROXY SERVER
If you have your own proxy server and already use the proxyURL API, you don't need any further configuration.
Swift
Objective-C
Kotlin
Kotlin MP
Java
Flutter
React Native
Cordova
Capacitor
Unity
Purchases.proxyURL = URL(string: "https://api.rc-backup.com/")!


iOS

Listening for CustomerInfo updates

📘NOTE
RevenueCat doesn't push new data to the SDK, so this method is only called when CustomerInfo is updated from another SDK method or after a purchase is made on the current device.
Implement the following delegate method to receive updates to the CustomerInfo object:

purchases:receivedUpdated

Called whenever Purchases receives an updated CustomerInfo object. This may happen periodically throughout the life of the app if new information becomes available (e.g. after making a purchase).

Handling Promoted Purchases

Implement the following delegate method to handle promoted purchases:

purchases:readyForPromotedProduct

Called when a user initiates a promoted in-app purchase from the App Store. If your app is able to handle a purchase at the current time, run the defermentBlock in this method.

If the app is not in a state to make a purchase: cache the defermentBlock, then call the defermentBlock when the app is ready to make the promoted purchase.

If the purchase should never be made, you don't need to ever call the defermentBlock and Purchases will not proceed with promoted purchases.

Android

Listening for CustomerInfo updates

📘NOTE
RevenueCat doesn't push new data to the SDK, so this method is only called when CustomerInfo is updated from another SDK method or after a purchase is made on the current device.
Implement the following listener to receive updates to the CustomerInfo object:

UpdatedCustomerInfoListener

Called whenever Purchases receives an updated CustomerInfo object. This may happen periodically throughout the life of the app if new information becomes available (e.g. after making a purchase).



Configuring for App Extensions

To enable data sharing between the main app and extensions, you'll need to use Xcode or the Developer portal to enable app groups for the containing app and its contained app extensions. Then, register the app group in the portal and specify the app group to use in the containing app. If you are building a Safari extension, you will need to configure and interact with the RevenueCat SDK in the Swift code, rather than in the Javascript code.

After you enable app groups, you will be able to access a user's active subscriptions in your App Extension by configuring Purchases with a custom UserDefaults that's shared across your App Extension.

Swift
Purchases.configure(
  with: Configuration.Builder(withAPIKey: <your_api_key)
    .with(appUserID: <app_user_id>)
    .with(userDefaults: .init(suiteName: <group.your.bundle.here>))
    .build()
)


Now the app extension and parent app can both use the a shared UserDefaults suite.


Identifying Customers

RevenueCat provides a source of truth for a customer's subscription status across different platforms. User identity is one of the most important components of many mobile applications, and it's crucial to make sure the subscription status that RevenueCat is tracking is associated with the correct user.

For an overview of what a customer is in RevenueCat, see What is a Customer?.

Anonymous App User IDs

By default, if you don't provide an App User ID when configuring the Purchases SDK, RevenueCat will generate a new random App User ID (prefixed with $RCAnonymousID:) for you, and will cache it on the device.

In the event that the user deletes and reinstalls the app, the cache will be cleared and a new random anonymous App User ID will be generated.

Anonymous App User IDs are not able to share subscription status across apps and platforms, but are suitable for many apps that don't require authentication and only support a single platform.

Swift
Obj-C
Kotlin
Kotlin Multiplatform
Java
Flutter
React Native
Cordova
Capacitor
Unity
Purchases.configure(withAPIKey: <my_api_key>)


Custom App User IDs

Setting your own App User ID will allow you to reference users in the RevenueCat dashboard, via the API, as well as in the webhooks and other integrations.

Using an externally managed App User ID also provides a mechanism by which to restore purchases in a few scenarios:

When a user deletes and reinstalls your app - using the same App User ID will ensure they still have access to subscriptions previously started without requiring a restore .
When the user logs in on multiple devices - you can honor a subscription that was purchased on one device across any other platform.
App User IDs are case-sensitive and are scoped to a whole Project. A user logged into the same App User ID on different platforms will be considered the same user and can access the entitlements they have purchased on any platform.

📘MANAGING SUBSCRIPTIONS
A user can only manage their subscription on the platform it was purchased from.
Logging in during configuration

If you have your own App User IDs at app launch, you can pass those on instantiation to Purchases. Make sure to not hard-code this identifier, if you do all users will be considered the same one and will share purchases.

Swift
Obj-C
Kotlin
Kotlin Multiplatform
Java
Flutter
React Native
Cordova
Capacitor
Unity
Purchases.configure(withAPIKey: <my_api_key>, appUserID: <my_app_user_id>)


Often times, you may not have your own App User IDs until later in the application lifecycle. In these cases, you can pass the App User ID later through the .logIn() method.

Logging in after configuration

If your app doesn't receive its own App User ID until later in its lifecycle, you can set (or change) the App User ID at any time by calling .logIn(). If the logged in identity does not already exist in RevenueCat, it will be created automatically.

This flow will generate an anonymous App User ID for the user first, then may (see below) alias the anonymous App User ID to the provided custom App User ID. In this case if you integrated webhooks, original_app_user_id will be the anonymous id and app_user_id will be the provided id.

Swift
Obj-C
Kotlin
Kotlin Multiplatform
Java
Flutter
React Native
Cordova
Capacitor
Unity
// Configure Purchases on app launch
Purchases.configure(withAPIKey: <my_api_key>)

// ...

// Later log in provided user Id
Purchases.shared.logIn(<my_app_user_id>) { (customerInfo, created, error) in
    // customerInfo updated for my_app_user_id
}


logIn() method alias behavior
Logging Out

When an identified user logs out of your application you should call the logOut() method within the SDK. This will generate a new anonymous App User ID for the logged out state. However, if you plan to use only custom App User ID's, you can follow the instructions from the "How to force only using Custom App User IDs" section in the Advanced Topics.

Logging back in

To log in a new user, the provided App User ID should be set again with .logIn().

Switching accounts

If you need to switch from one provided App User ID to another, it's okay to call the .logIn() method directly - you do not need to call logOut() first.

Supporting your customers

We strongly recommend revealing the App User ID to your customers somewhere within your app. Typically, developers choose to display the App User ID in a settings screen.

Allowing your customers to view and copy their App User ID can help with troubleshooting and support if they need to contact you or your support team.

You can retrieve the currently identified App User ID via the Purchases.shared.appUserID property.

Aliases

If you use a combination of anonymous and custom App User IDs, it’s expected that Customers may be merged over time due to various actions they perform within the app, like logins or restores. Scenarios explaining when merges occur are covered in more detail below, and will depend on the restore behavior you select for your project.

When a merge of customers occurs, there will be only one App User ID within the original_app_user_id field. If you’re listening to Webhooks, the other App User IDs associated with the customer will be within an array in the aliases field.

When referenced via the SDK or API, any merged App User IDs will all be treated as the same “customer”. Looking up any of the merged App User IDs in RevenueCat will return the same CustomerInfo, customer history, customer attributes, subscription status, etc.

Tips for Setting Custom App User IDs

ℹ️ Every app user ID must be unique per user.

If you don't have your own user IDs for some of your users, you should not pass any value for the App User ID on configuration, which will then rely on the anonymous IDs created by RevenueCat.

ℹ️ App User IDs should not be guessable

RevenueCat provides subscription status via the public API; it is not good to have App User IDs that are easily guessed. A non-guessable pseudo-random ID, like a UUID (RFC 4122 version 4), is recommended.

ℹ️ Length limitations

App User IDs should not be longer than 100 characters.

⚠️ Don't set emails as App User IDs

For the above reasons about guessability, and GDPR compliance, we don't recommend using email addresses as App User IDs.

⚠️ Don't set IDFA as App User IDs

Advertising identifiers should not be used as App User IDs since they can be easily rotated and are not unique across users if limit ad tracking is enabled.

🚨 Don't hardcode strings as App User IDs

You should never hardcode a string as an App User ID, since every install will be treated as the same user in RevenueCat. This will create problems and could unlock entitlements for users that haven't actually purchased.

Blocked App User IDs

Certain App User IDs are blocked in RevenueCat. This is by design to help developers that may be unintentionally passing non-unique strings as user identifiers.

The current block-list is: 'no_user', 'null', 'none', 'nil', '(null)', 'NaN, '\\x00'(NULL character), ''(empty string), 'unidentified', 'undefined', 'unknown', 'anonymous', 'guest', '-1', '0', '[]', '{}', '[object Object]' and any App User IDs containing the character /.

Advanced Topics

How to force only using Custom App User IDs
To only use custom App User IDs, you must take care not to generate any anonymous App User IDs in the SDK.

Anonymous App User IDs are generated when the SDK is configured without a provided custom App User ID, and are also created on logOut() as mentioned above. Many apps use a combination of anonymous App User IDs and their own custom App User IDs via an authentication system to provide flexibility in their user purchase flows. However, some applications are intended only to be used while using a known App User ID, without anonymous users at all.

Some limits of anonymous IDs include added difficulty in personalization of user experiences, optimization of monetization strategies, and not being able to share subscriptions across platforms. Depending on the application's transfer behavior, a provided user's subscription may be transferred to an anonymous ID - which can only be brought back through a restore on the original purchase platform.

In any case, to never see Anonymous IDs, you only need to make sure to do the following: Only configure the SDK with a custom App User ID, and never call .logout().

Only Configure the SDK with a custom App User ID

The most frequent place that anonymous App User IDs are created is when the SDK is first configured. Calling .configure on the SDK without providing a known user ID will cause the SDK to generate an anonymous ID for the current user. To avoid anonymous IDs, you will need to identify the user’s ID before configuring the SDK. Many applications use their own authentication system, often shared on multiple platforms, to identify users and provide their unique App User IDs.

Do not Logout the User

After the user is logged in with a known App User ID, they may want to logout or switch accounts on your application (e.g., logout and then login with a different known ID). However, calling logout in the SDK will result in an anonymous App User ID being created. To resolve this, simply do not logout the SDK. In the case of switching accounts, you can call login when the user logs in to the different account with their new App User ID.

Getting Subscription Status

RevenueCat makes it easy to determine subscription status and more with the RevenueCat SDK and REST API.

Getting subscription status via the SDK

The CustomerInfo object contains all of the purchase and subscription data available about a customer.

This object is updated whenever a purchase or restore occurs and periodically throughout the lifecycle of your app. The latest information can always be retrieved by calling getCustomerInfo():

Swift
Obj-C
Kotlin
Java
Flutter
React Native
Cordova
Capacitor
Unity
Web (JS/TS)
// Using Swift Concurrency
do {
    let customerInfo = try await Purchases.shared.customerInfo()
} catch {
    // handle error
}
// Using Completion Blocks
Purchases.shared.getCustomerInfo { (customerInfo, error) in
    // access latest customerInfo
}


It's safe to call getCustomerInfo() frequently throughout your app. Since the SDK updates and caches the latest CustomerInfo when the app becomes active, the completion block won't need to make a network request in most cases.

Checking If A User Is Subscribed

The subscription status for a user can easily be determined with the CustomerInfo and EntitlementInfo objects.

For most apps that only have one entitlement, the isActive status can be quickly checked for your entitlement ID.

Swift
Obj-C
Kotlin
Java
Flutter
React Native
Cordova
Unity
Web (JS/TS)
if customerInfo.entitlements[<your_entitlement_id>]?.isActive == true {
  // user has access to "your_entitlement_id"                
}


If your app has multiple entitlements, you might also want to check if the customer has any active entitlements:

Swift
Obj-C
Kotlin
Java
Flutter
React Native
Cordova
Unity
Web (JS/TS)
if !customerInfo.entitlements.active.isEmpty {
    // user has access to some entitlement
}


It's important to note that CustomerInfo will be empty if no purchases have been made and no transactions have been synced. This means that entitlements may not exist in CustomerInfo even if they have been set up in the RevenueCat dashboard.

Restoring Purchases

Restoring purchases is a mechanism by which your user can restore their in-app purchases, reactivating any content that had previously been purchased from the same store account (Apple, Google, or Amazon).

It is recommended that all apps have some way for users to trigger the restorePurchases method, even if you require all customers to create accounts.

See our Restoring Purchases guide for more information.

Cache

The SDK caches the user's subscription information to reduce your app's reliance on the network.

Users who unlock entitlements will be able to access them even without an internet connection. The SDK will update the cache if it's older than 5 minutes, but only if you call getCustomerInfo(), make a purchase, or restore purchases, so it's a good idea to call getCustomerInfo() any time a user accesses premium content.

Listening For CustomerInfo Updates

Since Purchases SDK works seamlessly on any platform, a user's CustomerInfo may change from a variety of sources. You can respond to any changes in CustomerInfo by conforming to an optional delegate method, purchases:receivedUpdated:. This will fire whenever we receive a change in CustomerInfo on the current device and you should expect it to be called at launch and throughout the life of the app.

CustomerInfo updates are not pushed to your app from the RevenueCat backend, updates can only happen from an outbound network request to RevenueCat.

Depending on your app, it may be sufficient to ignore the delegate and simply handle changes to customer information the next time your app is launched. Or throughout your app as you request new CustomerInfo objects.

Swift
Obj-C
Kotlin
Kotlin Multiplatform
Java
Flutter
React Native
Cordova
Capacitor
Unity
// Option 1: using PurchasesDelegate:
Purchases.logLevel = .debug
Purchases.configure(withAPIKey: <public_sdk_key>)
Purchases.shared.delegate = self // make sure to set this after calling configure

extension AppDelegate: PurchasesDelegate {
    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: Purchases.CustomerInfo) {
        // handle any changes to customerInfo
    }
}

// Option 2: using Swift Concurrency:
for try await customerInfo in Purchases.shared.customerInfoStream {
    // handle any changes to customerInfo
}


Reference

CustomerInfo Reference
The CustomerInfo object gives you access to the following information about a user:

Name	Description
Request Date	The server date when the current CustomerInfo object was fetched. This is affected by the cache on device so you should not use it when you need the current time to calculate info such as time elapsed since purchase date. For that you should use device time.
Original App User ID	The original App User ID recorded for this user. May be the same as their current App User ID. See our Identifying Users guide for more information.
First Seen	The date this user was first seen in RevenueCat. This is the install date in most cases
Original Application Version	iOS only. The version number for the first version of the app this user downloaded. Will be nil unless a receipt has been recorded for the user through a purchase, restore, or import.

Note in sandbox this will always be "1.0"

Useful for migrating existing apps to subscriptions.
Original Purchase Date	iOS only. The date that the app was first purchased/downloaded by the user. Will be nil if no receipt is recorded for the user. Useful for migrating existing apps to subscriptions.
Management URL	URL to manage the active subscription of the user. If the user has an active iOS subscription, this will point to the App Store, if the user has an active Play Store subscription it will point there. For Stripe subscriptions, there is no Management URL.

If there are no active subscriptions it will be null.

If the user has multiple active subscriptions for different platforms, this will take the value of the OS in the X-Platform header into consideration:
 - If the request was made on an OS for which there are active subscriptions, this will return the URL for the store that matches the header.
 - If the request was made on a different OS or the OS was not included in the X-Platform header, this will return the URL for the store of the subscription with the farthest future expiration date.
All Purchased Product Identifiers	An array of product identifiers purchased by the user regardless of expiration.
All Expiration Dates By Product	A map of product identifiers to expiration dates.
All Purchase Dates By Product	A map of product identifiers to purchase dates.
Non Subscription Transactions	A list of all the non-subscription transactions purchased by the user.
Latest Expiration Date	The latest expiration date of all purchased products.
Active Subscriptions	An array of subscription product identifiers that are active. You should be using entitlement though.
Entitlements	EntitlementInfo objects that contain information about the user's entitlements, such as subscription state. See more below.
EntitlementInfo Reference
The EntitlementInfo object gives you access to all of the information about the status of a user's entitlements.

Name	Description
Identifier	The entitlement identifier configured in the RevenueCat dashboard.
Product Identifier	The product identifier that unlocked this entitlement.
Is Active	Whether or not the user has access to this entitlement.
Will Renew	Whether or not the entitlement is set to renew at the end of the current period. Note there may be a multiple hour delay between the value of this property and the actual state in the App Store / Play Store.
Period Type	The period type this entitlement is in, can be one of: - Trial: In a free trial period - Promotional: In a promotional period - Intro: In an introductory price period - Normal: In the default period
Latest Purchase Date	The latest purchase or renewal date for this entitlement.
Original Purchase Date	The first date this entitlement was purchased. May be the same as the latest purchase date.
Expiration Date	The expiration date for the entitlement, can be null for lifetime access. If the period type is trial then this is the trial expiration date.
Store	The store that unlocked this entitlement, can be one of: - App Store - Mac App Store - Play Store - Amazon Appstore - Stripe - Promotional (RevenueCat)
Is Sandbox	Whether this entitlement was unlocked from a sandbox or production purchase.
Unsubscribe Detected At	The date an unsubscribe was detected. An unsubscribe does not mean that the entitlement is inactive. Note there may be a multiple hour delay between the value of this property and the actual state in the App Store / Play Store. This delay can be reduced by enabling Platform Server Notifications.
Billing Issue Detected At	The date a billing issue was detected, will be null again once billing issue resolved. A billing issue does not mean that the entitlement is inactive. Note there may be a multiple hour delay between the value of this property and the actual state in the App Store / Play Store. This delay can be reduced by enabling Platform Server Notifications.
Ownership Type	Whether this purchase was made by this user or shared to them by a family member (iOS only).
Product Plan Identifier	The base plan identifier that unlocked this entitlement (Google only).