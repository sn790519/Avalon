//
//  AvalonTests.swift
//  AvalonTests
//
//  Created by Colin Eberhardt on 09/11/2014.
//  Copyright (c) 2014 Colin Eberhardt. All rights reserved.
//

import UIKit
import XCTest
import Avalon

class PersonViewModel: NSObject {
  dynamic var name = "Bob"
  let surname = "Eggbert"
  let age = 22
  dynamic var isFemale = true
  dynamic var address = AddressViewModel()
}

class AddressViewModel: NSObject {
  dynamic var city = "Newcastle"
}

class AvalonTests: XCTestCase {
  
  func test_kvoBinding() {
    
    let source = PersonViewModel()
    source.name = "Phil"
    let destination = PersonViewModel()
    
    // create the binding
    let binding = KVOBinding(source: source, sourceKeyPath: "name", destination: destination, destinationKeyPath: "name")
    
    // check the initial value is copied
    XCTAssertEqual(destination.name, "Phil")
    
    // update source and verify propagation
    source.name = "Frank"
    XCTAssertEqual(destination.name, "Frank")
  }
  
  func test_bindingContext_isAppliedToViewHierarchy() {
    
    // create a view and a bound label
    let view = UIView()
    let label = UILabel()
    label.bindings = [Binding(source: "name", destination: "text")]
    view.addSubview(label)
    
    // add a view model
    view.bindingContext = PersonViewModel()
    
    XCTAssertEqual(label.text!, "Bob")
  }
  
  
  func test_bindingContext_isAppliedToView() {
    
    // create a view and a bound label
    let label = UILabel()
    label.bindings = [Binding(source: "name", destination: "text")]
    
    // add a view model
    label.bindingContext = PersonViewModel()
    
    XCTAssertEqual(label.text!, "Bob")
  }
  
  
  func test_bindingContext_supportsBindingsAcrossTheHierarchy() {
    
    // create a view and a bound label
    let view = UILabel()
    view.bindings = [Binding(source: "name", destination: "text")]
    let label = UILabel()
    label.bindings = [Binding(source: "name", destination: "text")]
    view.addSubview(label)
    
    // create two new vms
    let viewModelOne = PersonViewModel()
    let viewModelTwo = PersonViewModel()
    viewModelTwo.name = "Frank"
    
    // bind each vm to a different part of the view
    view.bindingContext = viewModelOne
    XCTAssertEqual(label.text!, "Bob")
    XCTAssertEqual(view.text!, "Bob")
    
    label.bindingContext = viewModelTwo
    XCTAssertEqual(view.text!, "Bob")
    XCTAssertEqual(label.text!, "Frank")
  }

  
  func test_bindingContext_canBeBound() {
    
    // create a view and a bound label
    let view = UILabel()
    view.bindings = [Binding(source: "name", destination: "text")]
    let label = UILabel()
    label.bindings = [Binding(source: "address", destination: "bindingContext"),
      Binding(source: "city", destination: "text")]
    view.addSubview(label)
    
    // bind the view model
    view.bindingContext = PersonViewModel()
    XCTAssertEqual(view.text!, "Bob")
    XCTAssertEqual(label.text!, "Newcastle")
    
    // update the view model
    let newViewModel = PersonViewModel()
    newViewModel.name = "Frank"
    newViewModel.address.city = "Jamaica"
    
    view.bindingContext = newViewModel
    XCTAssertEqual(view.text!, "Frank")
    XCTAssertEqual(label.text!, "Jamaica")
  }
  
  func test_bindingContext_canBeChanged() {
    
    // create a bound label
    let label = UILabel()
    label.bindings = [Binding(source: "surname", destination: "text")]
    
    // bind twice
    label.bindingContext = PersonViewModel()
    label.bindingContext = PersonViewModel()
    
    // verify state
    XCTAssertEqual(label.text!, "Eggbert")
  }
  
  func test_binding_supportsConstantProperties() {
    
    // create a bound label
    let label = UILabel()
    label.bindings = [Binding(source: "surname", destination: "text")]
    
    // add a view model
    let viewModel = PersonViewModel()
    label.bindingContext = viewModel
    
    // verify state
    XCTAssertEqual(label.text!, "Eggbert")
  }
  
  func test_binding_updatesDestinationOnSourceChange() {
    
    // create a bound label
    let label = UILabel()
    label.bindings = [Binding(source: "name", destination: "text")]
    
    // add a view model
    let viewModel = PersonViewModel()
    label.bindingContext = viewModel
    
    // verify initial state
    XCTAssertEqual(label.text!, "Bob")
    
    // mutate
    viewModel.name = "Frank"
    
    XCTAssertEqual(label.text!, "Frank")
  }
  
  func test_binding_supportsSourcePropertyPaths() {
    
    // create a bound label
    let label = UILabel()
    label.bindings = [Binding(source: "address.city", destination: "text")]
    
    // add a view model
    let viewModel = PersonViewModel()
    label.bindingContext = viewModel
    
    // verify
    XCTAssertEqual(label.text!, "Newcastle")
  }
  
  func test_binding_propertyPathSupportsUpdatedOfTarget() {
    
    // create a bound label
    let label = UILabel()
    label.bindings = [Binding(source: "address.city", destination: "text")]
    
    // add a view model
    let viewModel = PersonViewModel()
    label.bindingContext = viewModel
    
    // verify
    XCTAssertEqual(label.text!, "Newcastle")
    
    // mutate
    viewModel.address.city = "Leeds"
    
    // verify
    XCTAssertEqual(label.text!, "Leeds")
  }
  
  func test_binding_propertyPathSupportsUpdatedInPropertyChain() {
    
    // create a bound label
    let label = UILabel()
    label.bindings = [Binding(source: "address.city", destination: "text")]
    
    // add a view model
    let viewModel = PersonViewModel()
    label.bindingContext = viewModel
    
    // verify
    XCTAssertEqual(label.text!, "Newcastle")
    
    // mutate
    let newAddress = AddressViewModel()
    newAddress.city = "Leeds"
    viewModel.address = newAddress
    
    // verify
    XCTAssertEqual(label.text!, "Leeds")
  }
  
  func test_binding_multipleProperties() {
    
    // create a bound label
    let label = UILabel()
    label.bindings = [Binding(source: "name", destination: "text"),
      Binding(source: "isFemale", destination: "hidden")]
    
    // add a view model
    let viewModel = PersonViewModel()
    label.bindingContext = viewModel
    
    // state
    XCTAssertEqual(label.text!, "Bob")
    XCTAssertEqual(label.hidden, true)
    
  }
  
  
  class AgeToString: ValueConverter {
    override func convert(sourceValue: AnyObject) -> AnyObject {
      let age: Int = sourceValue as Int
      return String(age)
    }
  }
  
  func test_binding_supportsValueConversion() {
    
    // create a bound label
    let label = UILabel()
    label.bindings = [Binding(source: "age", destination: "text", converter: AgeToString())]
    
    // add a view model
    let viewModel = PersonViewModel()
    label.bindingContext = viewModel
    
    // state
    XCTAssertEqual(label.text!, "22")
  }

}