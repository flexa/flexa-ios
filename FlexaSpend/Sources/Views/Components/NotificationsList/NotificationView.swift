//
//  NotificationView.swift
//  FlexasSpend
//
//  Created by Rodrigo Ordeix on 8/8/24.
//  Copyright © 2022 Flexa. All rights reserved.
//

import SwiftUI
import FlexaUICore
import SVGView
import Factory

struct NotificationView: View {
    @Environment(\.theme.containers.notifications) var theme
    @State var showWebView = false

    var notification: AppNotification
    var closeAction: () -> Void

    private var isSvgLogo: Bool {
        notification.iconUrl?.pathExtension.lowercased() == "svg"
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button {
                closeAction()
            } label: {
                Image(systemName: "xmark")
                    .resizable()
                    .font(.body.weight(.semibold))
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Asset.messageCloseButton)
                    .frame(width: 14, height: 14, alignment: .center)
                    .padding(4)
            }.padding([.trailing, .top], 12)

            HStack(alignment: .top, spacing: 16) {
                logoView
                VStack(alignment: .leading, spacing: 0) {
                    Text(notification.title)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .font(.body.weight(.semibold))
                        .minimumScaleFactor(0.5)
                        .padding(.top, 18)
                        .padding(.trailing, 40)
                        .padding(.bottom, 4)
                    Text(notification.body)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .font(.subheadline.weight(.light))
                        .minimumScaleFactor(0.5)
                        .foregroundColor(.secondary)
                        .padding(.trailing, 15)
                        .padding(.bottom, 14)
                    Divider().foregroundColor(.secondary)
                    Text(.init(notification.actionText))
                        .multilineTextAlignment(.leading)
                        .font(.body.weight(.semibold))
                        .tint(.flexaTintColor)
                        .foregroundColor(.flexaTintColor)
                        .padding([.trailing, .bottom], 16)
                        .padding(.top, 12)

                }.padding(0)
            }
        }
        .frame(maxWidth: .infinity)
        .modifier(RoundedView(color: backgroundColor, cornerRadius: cornerRadius))
    }

    @ViewBuilder
    private var logoView: some View {
        ZStack {
            if let iconUrl = notification.iconUrl {
                if isSvgLogo {
                    RemoteSvgView(
                        url: iconUrl,
                        content: { view in
                            AnyView(view)
                        },
                        placeholder: { failed in
                            if !failed {
                                ProgressView()
                            } else {
                                RoundedRectangle(cornerSize: CGSize(width: 8, height: 8))
                                    .fill(.gray)
                                    .frame(width: 36, height: 36)
                            }
                        }
                    )
                } else {
                    RemoteImageView(
                        url: iconUrl,
                        content: { image in
                            image.resizable()
                                .frame(width: 36, height: 36)
                                .aspectRatio(contentMode: .fill)
                                .scaledToFit()
                        },
                        placeholder: {
                            ProgressView()
                        }
                    )
                }
            }
        }.frame(width: 36, height: 36)
            .padding([.leading, .top], 18)
    }

}

// MARK: Theming
private extension NotificationView {
    var cornerRadius: CGFloat {
        theme.borderRadius
    }

    var backgroundColor: Color {
        theme.backgroundColor
    }
}

private extension AppNotification {
    var actionText: String {
        guard let action, let url = action.url else {
            return ""
        }
        return "[\(action.label)](\(url))"
    }
}
