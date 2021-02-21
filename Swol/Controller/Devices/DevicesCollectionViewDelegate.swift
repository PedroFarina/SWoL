//
//  DevicesCollectionViewDelegate.swift
//  Swol
//
//  Created by Pedro Giuliano Farina on 21/02/21.
//  Copyright © 2021 Pedro Giuliano Farina. All rights reserved.
//

import UIKit

internal class DevicesCollectionViewDelegate: NSObject,
                                              UICollectionViewDelegate,
                                              UICollectionViewDelegateFlowLayout {
    internal var frame: () -> CGRect?

    internal init(frame: @escaping () -> CGRect?) {
        self.frame = frame
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if var size = frame()?.size {
            size.width *= 0.9
            size.height *= 0.9
            return size
        } else {
            return CGSize(width: 1, height: 1)
        }
    }

    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let ver = (frame()?.size.height ?? 0) * 0.05
        let hor = (frame()?.size.width ?? 0) * 0.05
        return UIEdgeInsets(top: ver, left: hor, bottom: ver, right: hor)
    }
}
