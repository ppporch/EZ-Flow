import SwiftUI

struct DripComponentEditor: View {
    @Environment(\.dismiss) private var dismiss
    @State private var component: DripComponent
    let onSave: (DripComponent) -> Void

    init(component: DripComponent, onSave: @escaping (DripComponent) -> Void) {
        _component = State(initialValue: component)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Group") {
                    TextField("Name, for example Raised bed", text: $component.name)
                    Picker("Type", selection: $component.kind) {
                        ForEach(DripComponentKind.allCases) { kind in Text(kind.title).tag(kind) }
                    }
                }
                Section("Emitter details") {
                    if component.kind == .drippers {
                        IntegerInput(title: "Number of drippers", value: $component.count)
                    } else {
                        DecimalInput(title: "Total line length (feet)", value: $component.lengthFeet)
                        DecimalInput(title: "Emitter spacing (inches)", value: $component.spacingInches)
                        Text("Use the combined length of lines with this same spacing and emitter rating. Read the spacing and flow per emitter from the packaging.")
                            .font(.footnote).foregroundStyle(.secondary)
                    }
                    DecimalInput(title: "Flow per emitter (GPH)", value: $component.emitterGPH)
                }
                if component.isValid {
                    Section("Group total") {
                        LabeledContent("Flow", value: "\(component.flowGPH.formatted(.number.precision(.fractionLength(0...2)))) GPH")
                        if component.kind == .dripLine {
                            Text("Approximately \(component.estimatedEmitters.formatted(.number.precision(.fractionLength(0...1)))) emitters. Actual count depends on where the line is cut.")
                                .font(.footnote).foregroundStyle(.secondary)
                        }
                    }
                } else {
                    Section { Text("Enter a name and positive values. A line must be at least one emitter spacing long.").foregroundStyle(.secondary) }
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Drippers & lines").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                KeyboardDoneToolbar()
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Save", action: save).disabled(!component.isValid) }
            }
        }
    }

    private func save() { onSave(component); dismiss() }
}
