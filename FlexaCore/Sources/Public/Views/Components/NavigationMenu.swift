import SwiftUI
import Factory

public struct NavigationMenu<LabelContent: View>: View {
    private typealias MenuStrings = CoreStrings.NavigationMenu.Settings.Items
    @Injected(\.authStore) var authStore
    @Environment(\.openURL) private var openURL
    @ViewBuilder let labelContent: () -> LabelContent

    public init(_ labelContent: @escaping () -> LabelContent) {
        self.labelContent = labelContent
    }

    public var body: some View {
        Menu {
            Section {
                Button {
                    if let url = FlexaLink.merchantList.url {
                        openURL(url)
                    }
                } label: {
                    Label(MenuStrings.FindPlacesToPay.title, systemImage: "magnifyingglass")
                }
            }
            Section {
                Button {
                    openAccount()
                } label: {
                    Label(MenuStrings.ManageFlexaId.title, systemImage: "person.text.rectangle")
                }
                Menu {
                    Button {
                        if let url = FlexaLink.howToPay.url {
                            openURL(url)
                        }
                    } label: {
                        Label(MenuStrings.Help.Items.HowToPay.title, systemImage: "rays")
                    }
                    Button {
                        if let url = FlexaLink.reportIssue.url {
                            openURL(url)
                        }
                    } label: {
                        Label(MenuStrings.Help.Items.ReportIssue.title, systemImage: "exclamationmark.bubble")
                    }
                } label: {
                    Label(MenuStrings.Help.title, systemImage: "questionmark.circle")
                }
            }
        } label: {
            labelContent()
        }
    }

    private func openAccount() {
        if authStore.isSignedIn {
            if let url = FlexaLink.account.url {
                openURL(url)
            }
        } else {
            Flexa
                .buildIdentity()
                .delayCallbacks(false)
                .build()
                .open()
        }
    }
}
