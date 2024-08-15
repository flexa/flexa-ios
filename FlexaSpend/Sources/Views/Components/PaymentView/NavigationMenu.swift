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
                    FlexaLogger.debug("Find Places to Pay")
                    showBrandDirectory = true
                } label: {
                    Label(MenuStrings.FindPlacesToPay.title, systemImage: "magnifyingglass")
                }
            }
            Section {
                Button {
                    FlexaLogger.debug("Manage Flexa Account")
                    showManageFlexaIDModal = true
                } label: {
                    Label(MenuStrings.ManageFlexaId.title, systemImage: "person.text.rectangle")
                }
                Menu {
                    Button {
                        FlexaLogger.debug("Learn how to pay")
                    } label: {
                        Label(MenuStrings.Help.Items.HowToPay.title, systemImage: "rays")
                    }
                    Button {
                        FlexaLogger.debug("Report an issue")
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

struct NavigationMenu_Previews: PreviewProvider {
    struct ParentView: View {
        @State var showBrandDirectory: Bool = false
        @State var showManageFlexaIDModal: Bool = false
        var body: some View {
            NavigationMenu(
                showBrandDirectory: $showBrandDirectory,
                showManageFlexaIDModal: $showManageFlexaIDModal
            )
        }
    }

    static var previews: some View {
        ParentView()
    }
}
