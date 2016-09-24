//
//  DimmingPresentationController.swift
//  StoreSearch
//
//  Created by Shouri on 17/01/16.
//  Copyright © 2016 Shouri. All rights reserved.
//

import UIKit

class DimmingPresentationController:UIPresentationController{
    
    override func shouldRemovePresentersView() -> Bool {
        return false
    }
}
