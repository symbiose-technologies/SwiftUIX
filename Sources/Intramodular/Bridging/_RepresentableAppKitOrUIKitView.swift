//
// Copyright (c) Vatsal Manot
//

import SwiftUI

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

struct _AppKitOrUIKitRepresentableContext {
    var _isSwiftUIRuntimeUpdateActive: Bool = false
    var _isSwiftUIRuntimeDismantled: Bool = false
    var proposedSize: _SwiftUIX_ProposedSize?
}

protocol _RepresentableAppKitOrUIKitView: AppKitOrUIKitView {
    var representableContext: _AppKitOrUIKitRepresentableContext { get set }
}

protocol _RepresentableAppKitOrUIKitViewController: AppKitOrUIKitViewController {
    var representableContext: _AppKitOrUIKitRepresentableContext { get set }
}

extension AppKitOrUIKitViewRepresentable where AppKitOrUIKitViewType: _RepresentableAppKitOrUIKitView {
    @MainActor
    func makeUIView(context: Context) -> AppKitOrUIKitViewType {
        makeAppKitOrUIKitView(context: context)
    }

    @MainActor
    func updateUIView(_ view: AppKitOrUIKitViewType, context: Context) {
        updateAppKitOrUIKitView(view, context: context)
    }

    @MainActor
    static func dismantleUIView(_ view: AppKitOrUIKitViewType, coordinator: Coordinator) {
        dismantleAppKitOrUIKitView(view, coordinator: coordinator)
    }

    #if os(iOS)
    @MainActor
    func _overrideSizeThatFits(
        _ size: inout CGSize,
        in proposedSize: _ProposedSize,
        uiView: AppKitOrUIKitViewType
    ) {
        uiView.representableContext.proposedSize = .init(proposedSize)
    }
    #endif
}

extension AppKitOrUIKitViewControllerRepresentable where AppKitOrUIKitViewControllerType: _RepresentableAppKitOrUIKitViewController {
    @MainActor
    func makeUIVieWController(context: Context) -> AppKitOrUIKitViewControllerType {
        makeAppKitOrUIKitViewController(context: context)
    }

    @MainActor
    func updateUIView(
        _ viewController: AppKitOrUIKitViewControllerType,
        context: Context
    ) {
        updateAppKitOrUIKitViewController(viewController, context: context)
    }

    @MainActor
    static func dismantleUIViewController(
        _ viewController: AppKitOrUIKitViewControllerType,
        coordinator: Coordinator
    ) {
        dismantleAppKitOrUIKitViewController(viewController, coordinator: coordinator)
    }
}

#endif

// MARK: - Auxiliary

struct _SwiftUIX_ProposedSize: Hashable {
    let width: CGFloat?
    let height: CGFloat?

    init(_ proposedSize: SwiftUI._ProposedSize) {
        self.width = proposedSize.width
        self.height = proposedSize.height
    }
 
    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    init(_ proposedSize: SwiftUI.ProposedViewSize) {
        self.width = proposedSize.width
        self.height = proposedSize.height
    }
}

extension OptionalDimensions {
    init(_ proposedSize: _SwiftUIX_ProposedSize) {
        self.init(width: proposedSize.width, height: proposedSize.height)
    }
}

extension SwiftUI._ProposedSize {
    var width: CGFloat? {
        Mirror(reflecting: self).children.lazy.compactMap { label, value in
            label == "width" ? value as? CGFloat : nil
        }.first
    }

    var height: CGFloat? {
        Mirror(reflecting: self).children.lazy.compactMap { label, value in
            label == "height" ? value as? CGFloat : nil
        }.first
    }
}
