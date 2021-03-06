//
//  Attribute.swift
//  QueryKit
//
//  Created by Kyle Fuller on 19/06/2014.
//
//

import Foundation

/// An attribute, representing an attribute on a model
public struct Attribute<AttributeType> : Equatable {
  public let name:String

  public init(_ name:String) {
    self.name = name
  }

  /// Builds a compound attribute with other key paths
  public init(attributes:Array<String>) {
    self.init(".".join(attributes))
  }

  /// Returns an expression for the attribute
  public var expression:NSExpression {
    return NSExpression(forKeyPath: name)
  }

  // MARK: Sorting

  /// Returns an ascending sort descriptor for the attribute
  public func ascending() -> NSSortDescriptor {
    return NSSortDescriptor(key: name, ascending: true)
  }

  /// Returns a descending sort descriptor for the attribute
  public func descending() -> NSSortDescriptor {
    return NSSortDescriptor(key: name, ascending: false)
  }

  func expressionForValue(value:AttributeType) -> NSExpression {
    // TODO: Find a cleaner implementation
    if let value = value as? NSObject {
      return NSExpression(forConstantValue: value as NSObject)
    }

    if sizeof(value.dynamicType) == sizeof(uintptr_t) {
      let value = unsafeBitCast(value, Optional<NSObject>.self)
      if let value = value {
        return NSExpression(forConstantValue: value)
      }
    }

    let value = unsafeBitCast(value, Optional<String>.self)
    if let value = value {
      return NSExpression(forConstantValue: value)
    }

    return NSExpression(forConstantValue: NSNull())
  }
}


/// Returns true if two attributes have the same name
public func == <AttributeType>(lhs: Attribute<AttributeType>, rhs: Attribute<AttributeType>) -> Bool {
  return lhs.name == rhs.name
}

public func == <AttributeType>(left: Attribute<AttributeType>, right: AttributeType) -> NSPredicate {
  return left.expression == left.expressionForValue(right)
}

public func != <AttributeType>(left: Attribute<AttributeType>, right: AttributeType) -> NSPredicate {
  return left.expression != left.expressionForValue(right)
}

public func > <AttributeType>(left: Attribute<AttributeType>, right: AttributeType) -> NSPredicate {
  return left.expression > left.expressionForValue(right)
}

public func >= <AttributeType>(left: Attribute<AttributeType>, right: AttributeType) -> NSPredicate {
  return left.expression >= left.expressionForValue(right)
}

public func < <AttributeType>(left: Attribute<AttributeType>, right: AttributeType) -> NSPredicate {
  return left.expression < left.expressionForValue(right)
}

public func <= <AttributeType>(left: Attribute<AttributeType>, right: AttributeType) -> NSPredicate {
  return left.expression <= left.expressionForValue(right)
}

public func ~= <AttributeType>(left: Attribute<AttributeType>, right: AttributeType) -> NSPredicate {
  return left.expression ~= left.expressionForValue(right)
}

public func << <AttributeType>(left: Attribute<AttributeType>, right: [AttributeType]) -> NSPredicate {
    let value = map(right) { value in return value as! NSObject }
    return left.expression << NSExpression(forConstantValue: value)
}

public func << <AttributeType>(left: Attribute<AttributeType>, right: Range<AttributeType>) -> NSPredicate {
    let value = [right.startIndex as! NSObject, right.endIndex as! NSObject] as NSArray
    let rightExpression = NSExpression(forConstantValue: value)

  return NSComparisonPredicate(leftExpression: left.expression, rightExpression: rightExpression, modifier: NSComparisonPredicateModifier.DirectPredicateModifier, type: NSPredicateOperatorType.BetweenPredicateOperatorType, options: NSComparisonPredicateOptions(0))
}

/// MARK: Bool Attributes

prefix public func ! (left: Attribute<Bool>) -> NSPredicate {
  return left == false
}

public extension QuerySet {
  public func filter(attribute:Attribute<Bool>) -> QuerySet<ModelType> {
    return filter(attribute == true)
  }

  public func exclude(attribute:Attribute<Bool>) -> QuerySet<ModelType> {
    return filter(attribute == false)
  }
}

// MARK: Collections

public func count(attribute:Attribute<NSSet>) -> Attribute<Int> {
  return Attribute<Int>(attributes: [attribute.name, "@count"])
}

public func count(attribute:Attribute<NSOrderedSet>) -> Attribute<Int> {
  return Attribute<Int>(attributes: [attribute.name, "@count"])
}
