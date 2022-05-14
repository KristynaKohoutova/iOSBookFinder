//
//  UIProgressView.swift
//  NURAPI Swift Demo
//
//  Created by Daniel Kohout on 08.05.2021.
//  Copyright © 2021 Jan Ekholm. All rights reserved.
//

import Foundation

class UIProgressView{
override func layoutSubviews() {
        super.layoutSubviews()

        let maskLayerPath = UIBezierPath(roundedRect: bounds, cornerRadius: 4.0)
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskLayerPath.cgPath
        layer.mask = maskLayer
    }
}
