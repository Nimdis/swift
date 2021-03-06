// RUN: %empty-directory(%t)
// RUN: %target-swift-frontend -emit-module -swift-version 5 -enable-implicit-dynamic %S/Inputs/dynamicReplacementA.swift -o %t -module-name A
// RUN: %target-swift-frontend -emit-module -swift-version 5 -enable-implicit-dynamic -c %S/Inputs/dynamicReplacementB.swift -o %t -I %t -module-name B
// RUN: %target-swift-frontend -emit-module -swift-version 5 -enable-implicit-dynamic -c %S/Inputs/dynamicReplacementC.swift -o %t -I %t -module-name C
// RUN: %target-typecheck-verify-swift -swift-version 5 -enable-implicit-dynamic  -I %t
import A
import B
import C

// rdar://problem/46737657: static properties
struct StaticProperties {
  dynamic var property: Int { return 1 }
  dynamic static var property: Int { return 11 }
}

extension StaticProperties {
  @_dynamicReplacement(for: property)
  var replacement_property: Int { return 2 }
}

// Replacements involving different types.
extension TheReplaceables {
  @_dynamicReplacement(for: property1) // expected-error{{replaced accessor for 'property1' occurs in multiple places}}
  var replace_property1: Int { return 0 }
  
  @_dynamicReplacement(for: property2)
  var replace_property2_int: Int { return 1 }
  
  @_dynamicReplacement(for: property2)
  var replace_property2_string: String { return "replaced" }

  @_dynamicReplacement(for: subscript(_:)) // expected-error{{replaced accessor for 'subscript(_:)' occurs in multiple places}}
  subscript (int_int i: Int) -> Int { return 0 }

  @_dynamicReplacement(for: subscript(_:))
  subscript (int_string i: Int) -> String { return "" }

  @_dynamicReplacement(for: subscript(_:))
  subscript (string_string i: String) -> String { return "" }
}

extension K {
  @_dynamicReplacement(for: init(i:)) // expected-error{{replaced constructor 'init(i:)' is not marked as convenience}}
  convenience init(ri: Int) { }

  @_dynamicReplacement(for: init(c:)) // expected-error{{replaced constructor 'init(c:)' is marked as convenience}})
  init(rc: Int) { }
}

extension undeclared { // expected-error{{use of undeclared type 'undeclared'}}
  @_dynamicReplacement(for: property) // expected-error{{replaced accessor for 'property' could not be found}}
  var replacement_property: Int { return 2 }

  @_dynamicReplacement(for: func) // expected-error{{replaced function 'func' could not be found}}
  func func2() -> Int { return 2 }
}
