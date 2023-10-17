//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

import SwiftUI

@available(macCatalystApplicationExtension, unavailable)
@available(iOSApplicationExtension, unavailable)
@available(tvOSApplicationExtension, unavailable)
extension AppKitOrUIKitWindow {
    public static var _firstKeyInstance: AppKitOrUIKitWindow? {
        #if os(iOS) || os(macOS)
        return AppKitOrUIKitApplication.shared.firstKeyWindow
        #else
        assertionFailure("unimplemented")
        
        return nil
        #endif
    }
    
    public func _forceFirstResponderToResign() {
        #if os(macOS)
        makeFirstResponder(nil)
        #else
        resignFirstResponder()
        endEditing(true)
        #endif
    }
    
}

#if os(iOS) || os(tvOS)
extension AppKitOrUIKitWindow {
    public var _SwiftUIX_contentView: AppKitOrUIKitView? {
        self
    }

    public var _SwiftUIX_macOS_titleBarHeight: CGFloat? {
        nil
    }
}
#elseif os(macOS)
extension AppKitOrUIKitWindow {
    public var _SwiftUIX_contentView: AppKitOrUIKitView? {
        contentView
    }
    
    public var _SwiftUIX_macOS_titleBarHeight: CGFloat? {
        guard let windowFrame = self._SwiftUIX_contentView?.superview?.frame, let contentFrame = self.contentView?.frame else {
            return nil
        }
        
        let titleBarHeight = windowFrame.height - contentFrame.height
        
        return titleBarHeight > 0 ? titleBarHeight : nil
    }
}
#endif

#endif
