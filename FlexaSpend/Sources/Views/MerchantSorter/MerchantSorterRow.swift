//
//  MerchantSorterRow.swift
//  FlexaSpend
//
//  Created by Rodrigo Ordeix on 9/26/23.
//  Copyright © 2023 Flexa. All rights reserved.
//

import SwiftUI
import FlexaUICore

extension MerchantSorter {
    struct Row: View {
        var pinned: Bool
        var brand: Brand

        var imageName: String {
            pinned ? "minus.circle.fill" : "pin.circle.fill"
        }

        var imageColor: Color {
            pinned ? .red : .yellow
        }

        var action: (Brand, Bool) -> Void

        var body: some View {
            HStack(spacing: 10) {
                Text(
                    Image(systemName: imageName)
                )
                .font(.title2)
                .foregroundColor(imageColor)
                .onTapGesture {
                    action(brand, pinned)
                }

                RemoteImageView(
                    url: brand.logoUrl,
                    content: { image in
                        image.resizable()
                            .frame(width: 30, height: 30)
                            .cornerRadius(6)
                            .aspectRatio(contentMode: .fill)
                            .scaledToFit()
                            .padding(.leading, 6)
                    },
                    placeholder: {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.gray)
                            .frame(width: 30, height: 30)
                    }
                )

                Text(brand.name).font(.body)

                if pinned {
                    Spacer()
                    Image(systemName: "line.3.horizontal")
                        .font(.body)
                        .foregroundColor(Color(UIColor.quaternaryLabel))
                }
            }
        }
    }
}
