import SwiftUI
import UIKit

extension View {
    /// Selects all text in a focused text field once its insertion point has been placed.
    func selectAllOnFocus(_ focusedField: FocusState<FocusedField?>.Binding, equals field: FocusedField) -> some View {
        onChange(of: focusedField.wrappedValue) {
            guard focusedField.wrappedValue == field else { return }
            // Select after the tap has finished placing the insertion point.
            DispatchQueue.main.async {
                guard focusedField.wrappedValue == field else { return }
                UIApplication.shared.sendAction(
                    #selector(UIResponder.selectAll(_:)), to: nil, from: nil, for: nil
                )
            }
        }
    }
}
