//
//  UIImageView+RemoteImage.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 01/23/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import UIKit
import Factory

public extension UIImageView {
    func setRemoteImage(withUrl url: URL?) {
        guard let url else {
            return
        }

        Task.detached {
            let image = await Container.shared.imageLoader().loadImage(fromUrl: url)
            DispatchQueue.main.async { [weak self] in
                guard let self else {
                    return
                }
                self.image = image
                UIView.animate(withDuration: 0.5) {
                    self.alpha = 1
                }
            }
        }
    }
}
