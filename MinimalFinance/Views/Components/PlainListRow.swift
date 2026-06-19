import SwiftUI

extension View {
    func plainListRow() -> some View {
        listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
            .listSectionSeparator(.hidden)
            .listRowBackground(AppTheme.background)
    }
}
