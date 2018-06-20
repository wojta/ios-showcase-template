//
//  RootRouter.swift
//  ios-showcase-template
//
//  Created by Wei Li on 08/11/2017.
//

import AGSAuth
import Foundation
import UIKit

/*
 The router for the root view module. It is responsible to load child modules and attach them to the view.
 It should call the child module's corresponding builder class to build the child module, pass on the dependencies that are required.
 */
protocol RootRouter {
    var appComponents: AppComponents { get }
    var rootViewController: RootViewController { get }

    func launchFromWindow(window: UIWindow)
    func launchHomeView()
    func launchAuthenticationView()
    func launchStorageView()
    func launchDeviceTrustView()
    func launchPushView()
    func launchMetricsView()
    func launchURL(_ urlString: String)
    func openDocsPage(withLink docUrl: DocsURL, andTitle title: String)
    func launchUnderconstructionView(_ viewTitle: String)
    func launchLandingPageView(withTitle title: String, andContent content: ServiceDesciption)
}

class RootRouterImpl: RootRouter {
    let navViewController: UINavigationController
    let rootViewController: RootViewController
    let appComponents: AppComponents

    var homeRouter: HomeRouter?
    var authenticationRouter: AuthenticationRouter?
    var storageRouter: StorageRouter?
    var deviceTrustRouter: DeviceTrustRouter?
    var pushRouter: PushRouter?
    var metricsRouter: MetricsRouter?
    var webviewRouter: WebviewRouter?
    var underconstructionRouter: UnderconstructionRouter?
    var landingPageRouter: LandingPagesRouter?

    init(navViewController: UINavigationController, viewController: RootViewController, appComponents: AppComponents) {
        self.navViewController = navViewController
        self.rootViewController = viewController
        self.appComponents = appComponents
    }

    func launchFromWindow(window: UIWindow) {
        window.rootViewController = self.navViewController
        window.makeKeyAndVisible()
    }

    func launchHomeView() {
        if self.homeRouter == nil {
            self.homeRouter = HomeBuilder().build()
        }
        self.rootViewController.title = RootViewController.MENU_ITEM_TITLE_HOME
        self.rootViewController.presentViewController(self.homeRouter!.viewController, true)
    }

    func launchAuthenticationView() {
        if self.authenticationRouter == nil {
            let authViewOptions = AuthenticationViewOptions(authLoginNavigationTitle: RootViewController.MENU_ITEM_TITLE_IDM_AUTH, authDetailsNavigationTitle: RootViewController.SUBMENU_ITEM_TITLE_IDM_AUTH_DETAILS, titleViewController: self.rootViewController)
            self.authenticationRouter = AuthenticationBuilder(appComponents: self.appComponents, authViewOptions).build()
        }
        self.rootViewController.presentViewController(self.authenticationRouter!.initialViewController(user: self.resolveCurrentUser()), true)
    }

    // Storage View
    func launchStorageView() {
        if self.storageRouter == nil {
            self.storageRouter = StorageBuilder(appComponents: self.appComponents).build()
        }
        self.rootViewController.title = RootViewController.MENU_ITEM_TITLE_SEC_STORAGE
        self.rootViewController.presentViewController(self.storageRouter!.viewController, true)
    }

    // Device Trust View
    func launchDeviceTrustView() {
        if self.deviceTrustRouter == nil {
            self.deviceTrustRouter = DeviceTrustBuilder(appComponents: self.appComponents).build()
        }
        self.rootViewController.title = RootViewController.MENU_ITEM_TITLE_SEC_TRUST
        self.rootViewController.presentViewController(self.deviceTrustRouter!.viewController, true)
    }

    func launchPushView() {
        if self.pushRouter == nil {
            self.pushRouter = PushBuilder().build()
        }
        self.rootViewController.title = RootViewController.MENU_ITEM_TITLE_PUSH_MESSAGE
        self.rootViewController.presentViewController(self.pushRouter!.viewController, true)
    }
    
    func launchMetricsView() {
        if self.metricsRouter == nil {
            self.metricsRouter = MetricsBuilder().build()
        }
        self.rootViewController.title = RootViewController.MENU_ITEM_TITLE_METRICS
        self.rootViewController.presentViewController(self.metricsRouter!.viewController, true)
    }
    
    func launchURL(_ urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:])
        }
    }

    func resolveCurrentUser() -> User? {
        let authService = self.appComponents.resolveAuthService()
        return try! authService.currentUser()
    }
    
    func openDocsPage(withLink docUrl: DocsURL, andTitle title: String) {
        if self.webviewRouter == nil {
            self.webviewRouter = WebviewBuilder().build()
        }
        self.rootViewController.title = title
        self.rootViewController.presentViewController(self.webviewRouter!.viewController, true)
        self.webviewRouter?.viewController.loadUrl(docUrl.toURL())
    }
    
    func launchUnderconstructionView(_ viewTitle: String) {
        if self.underconstructionRouter == nil {
            self.underconstructionRouter = UnderconstructionBuilder().build()
        }
        self.rootViewController.title = viewTitle
        self.rootViewController.presentViewController(self.underconstructionRouter!.viewController, true)
    }
    
    func launchLandingPageView(withTitle title: String, andContent content: ServiceDesciption) {
        if self.landingPageRouter == nil {
            self.landingPageRouter = LandingPagesBuilder().build()
        }
        self.rootViewController.title = title
        self.rootViewController.presentViewController(self.landingPageRouter!.viewController, true)
        self.landingPageRouter?.viewController.loadText(header: content.header, contentList: content.contentList, footer: content.footer)
    }
}
