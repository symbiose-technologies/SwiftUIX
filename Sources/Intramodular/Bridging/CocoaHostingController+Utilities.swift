//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || os(macOS) || targetEnvironment(macCatalyst)
public struct CocoaHostingControllerContent<Content: View>: View  {
    weak var parent: (any _CocoaHostingControllerOrView)?

    public var parentConfiguration: CocoaHostingControllerConfiguration
    public var content: Content
    
    init(
        parent: CocoaViewController?,
        parentConfiguration: CocoaHostingControllerConfiguration,
        content: Content
    ) {
        self.parentConfiguration = parentConfiguration
        self.content = content
    }
    
    public var body: some View {
        content
            ._resolveAppKitOrUIKitViewController(with: (parent as? CocoaViewController))
            .modifiers(parentConfiguration.preferenceValueObservers)
            ._measureAndRecordSize(parentConfiguration._isMeasuringSize) { [weak parent] in
                parent?._configuration._measuredSizePublisher.send($0)
            }
    }
}
#endif

struct _CocoaHostingViewWrapped<Content: View> {
    struct Configuration {
        var edgesIgnoringSafeArea: Bool = false
    }
    
    private var configuration: Configuration
    private let mainView: Content
    
    init(mainView: Content) {
        self.configuration = .init()
        self.mainView = mainView
    }
    
    init(@ViewBuilder mainView: () -> Content) {
        self.init(mainView: mainView())
    }
}

extension _CocoaHostingViewWrapped {
    func edgesIgnoringSafeArea() -> Self {
        then({ $0.configuration.edgesIgnoringSafeArea = true })
    }
}

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
extension _CocoaHostingViewWrapped: AppKitOrUIKitViewControllerRepresentable {
    typealias AppKitOrUIKitViewControllerType = CocoaHostingController<Content>
    
    func makeAppKitOrUIKitViewController(context: Context) -> AppKitOrUIKitViewControllerType {
        let viewController = AppKitOrUIKitViewControllerType(mainView: mainView)
        
        #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        viewController.view.backgroundColor = .clear
        #endif
        
        if configuration.edgesIgnoringSafeArea {
            viewController._disableSafeAreaInsetsIfNecessary()
        }
        
        return viewController
    }
    
    func updateAppKitOrUIKitViewController(_ viewController: AppKitOrUIKitViewControllerType, context: Context) {
        viewController.mainView = mainView
    }
}
#else
extension _CocoaHostingViewWrapped: View {
    var body: some View {
        mainView
    }
}
#endif
