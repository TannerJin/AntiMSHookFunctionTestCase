//
//  AppDelegate.swift
//  SwiftAntiMSHook
//
//  Created by jintao on 2020/5/8.
//  Copyright © 2020 jintao. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = ViewController()
        
        #if arch(arm64)
        testCase()
        #endif
        return true
    }
}


func denyDebugger(_ value: Int) -> Bool {
    NSLog("DenyDebugger Begin")
    let attach: CInt = 31 // PT_DENY_ATTACH
    let handle = dlopen("/usr/lib/libc.dylib", RTLD_NOW)
    defer {
        dlclose(handle)
    }
    let sym = dlsym(handle, "ptrace")
    
    typealias PtraceAlias = @convention(c) (CInt, pid_t, CInt, CInt) -> CInt
    let closeDebug = unsafeBitCast(sym, to: PtraceAlias.self)
    let ret = closeDebug(attach, 0, 0, 0)
    return ret == 1
}

#if arch(arm64)
func testCase() {
    typealias FunctionType = @convention(thin) (Int)->Bool

    let func_denyDebugger: FunctionType = denyDebugger    // `: FunctionType` is must
    let func_addr = unsafeBitCast(func_denyDebugger, to: UnsafeMutableRawPointer.self)
     
    if let original_denyDebugger = IOSSecuritySuite.denyMSHookFunction(func_addr) {
        NSLog("DenyMSHookFunction Success 🚀🚀🚀")
        _ = unsafeBitCast(original_denyDebugger, to: FunctionType.self)(996)
    } else {
        _ = denyDebugger(996)
    }
}
#endif
