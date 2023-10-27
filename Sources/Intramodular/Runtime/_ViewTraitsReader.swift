//
// Copyright (c) Vatsal Maot
//

import SwiftUI

public struct _ViewTraitsReader<Key: _ViewTraitKey, Content: View>: View where Key.Value: Equatable {
    private let key: Key.Type
    private let content: ([AnyHashable: Key.Value]) -> Content
    
    @State private var value = [AnyHashable: Key.Value]()
    
    
    public init(
        _ key: Key.Type = Key.self,
        @ViewBuilder content: @escaping ([AnyHashable: Key.Value]) -> Content
    ) {
        self.key = key
        self.content = content
    }
    
    public var body: some View {
        content(value)._onViewTraitsChange(key) {
            self.value = $0
        }
    }
}

extension View {
    public func _onViewTraitsChange<K: _ViewTraitKey, ID: Hashable>(
        _ key: K.Type,
        id: @escaping (K.Value) -> ID,
        perform action: @escaping ([ID: K.Value]) -> Void
    ) -> some View where K.Value: Equatable {
        modifier(_OnChangeOfViewTraits(key: key, action: action, id: id))
    }
    
    public func _onViewTraitsChange<K: _ViewTraitKey, ID: Hashable>(
        _ key: K.Type,
        id: KeyPath<K.Value, ID>,
        perform action: @escaping ([ID: K.Value]) -> Void
    ) -> some View where K.Value: Equatable {
        _onViewTraitsChange(key, id: { $0[keyPath: id] }, perform: action)
    }
    
    public func _onViewTraitsChange<K: _ViewTraitKey>(
        _ key: K.Type,
        perform action: @escaping ([AnyHashable: K.Value]) -> Void
    ) -> some View where K.Value: Equatable {
        modifier(_OnChangeOfViewTraits(key: key, action: action, id: nil))
    }
}

struct _OnChangeOfViewTraits<Key: _ViewTraitKey, ID: Hashable>: ViewModifier where Key.Value: Equatable {
    typealias Payload = [ID: Key.Value]
    
    let key: Key.Type
    let action: ([ID: Key.Value]) -> Void
    let id: ((Key.Value) -> ID)?
    
    @ViewStorage private var payload: [AnyHashable: Key.Value] = [:]
    
    func body(content: Content) -> some View {
        _VariadicViewAdapter(content) { content in
            let traits = Payload(
                content.children.map { (subview: _VariadicViewChildren.Element) in
                    let trait = subview[Key.self]
                    let id = id?(trait) ?? AnyHashable(subview.id) as! ID
                    
                    return (id, trait)
                },
                uniquingKeysWith: { lhs, rhs in lhs }
            )
            
            _ForEachSubview(enumerating: content) { index, subview in
                subview.background {
                    Group {
                        // Only attach to the first view, we don't want to add a change observer n times.
                        if index == 0 {
                            subview.onChange(of: traits) { _ in
                                setPayload(traits)
                            }
                        }
                    }
                }
            }
            
            // Clear the payload if there are no views.
            if content.children.isEmpty && !payload.isEmpty {
                PerformAction {
                    self.payload = [:]
                }
            }
        }
    }
    
    private func setPayload(_ payload: Payload) {
        self.payload = payload
        
        action(payload)
    }
}
