//
//  UISegmentedControl+Binding.swift
//  MvvmSwift
//
//  Created by Colin Eberhardt on 08/11/2014.
//  Copyright (c) 2014 Colin Eberhardt. All rights reserved.
//

import Foundation
import UIKit

// MARK:- Public API
extension UISegmentedControl {
  
  /// An bindable array that represent the segment titles
  public var segments: AnyObject? {
    get {
      return itemsController.items
    }
    set(newValue) {
      itemsController.items = newValue
    }
  }
  
}

// MARK:- Private API
extension UISegmentedControl {
  // an accessor for the controller that handles updating the segmented control
  var itemsController: SegmentedControlItemsController {
    return lazyAssociatedProperty(self, &AssociationKey.itemsController) {
      return SegmentedControlItemsController(segmentedControl: self)
    }
  }
}

// A controller that handles updating the state of a segmented control
class SegmentedControlItemsController: ItemsController {
  
  private let segmentedControl: UISegmentedControl
  
  init(segmentedControl: UISegmentedControl) {
    self.segmentedControl = segmentedControl
    super.init()
  }
  
  override func reloadAllItems() {
    segmentedControl.removeAllSegments()
    if let arrayFacade = arrayFacade {
      for var i = 0; i < arrayFacade.count; i++ {
        if let item = arrayFacade.itemAtIndex(i) as? String {
          segmentedControl.insertSegmentWithTitle(item, atIndex: i, animated: false)
        } else {
          // TODO: Log an error
        }
      }
    }
  }
  
  override func arrayUpdated(update: ArrayUpdateType) {
    switch update {
    case .ItemAdded(let index, let item):
      if let itemString = item as? String {
        segmentedControl.insertSegmentWithTitle(itemString, atIndex: index, animated: true)
      } else {
        // TODO: Log an error
      }
      break
    case .ItemRemoved(let index, let item):
      segmentedControl.removeSegmentAtIndex(index, animated: true)
      break
    }
  }
}