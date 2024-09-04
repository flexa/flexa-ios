import SwiftUI
import FlexaUICore

struct NavigationMenu: View {
    private typealias MenuStrings = L10n.Payment.Settings.Items

    @Binding var showBrandDirectory: Bool
    @Binding var showManageFlexaIDModal: Bool

    init(showBrandDirectory: Binding<Bool>, showManageFlexaIDModal: Binding<Bool>) {
        _showBrandDirectory = showBrandDirectory
        _showManageFlexaIDModal = showManageFlexaIDModal
    }

    var body: some View {
        Menu {
            Section {
                Button {
                    showBrandDirectory = true
                } label: {
                    Label(MenuStrings.FindPlacesToPay.title, systemImage: "magnifyingglass")
                }
            }
            Section {
                Button {
                    showManageFlexaIDModal = true
                } label: {
                    Label(MenuStrings.ManageFlexaId.title, systemImage: "person.text.rectangle")
                }
                Menu {
                    Button {
                    } label: {
                        Label(MenuStrings.Help.Items.HowToPay.title, systemImage: "rays")
                    }
                    Button {
                    } label: {
                        Label(MenuStrings.Help.Items.ReportIssue.title, systemImage: "exclamationmark.bubble")
                    }
                } label: {
                    Label(MenuStrings.Help.title, systemImage: "questionmark.circle")
                }

            }
        } label: {
            FlexaRoundedButton(.settings)
        }
    }
}
