//
//  ImageItem.swift
//  iChat
//
//  Created by Oleg Chebotarev on 07.11.2020.
//

import UIKit
import MessageKit

struct ImageItem: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}
