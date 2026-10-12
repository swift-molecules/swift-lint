public import SwiftSyntax

extension Lint.Source {

  public struct Index: Sendable, Equatable {

    public var valueGenericTypes: Swift::Set<Swift::String>

    public var associatedTypes: [Swift::String: Swift::Set<Swift::String>]

    public var conformances: [Swift::String: Swift::Set<Swift::String>]

    @inlinable
    public init(
      valueGenericTypes: Swift::Set<Swift::String> = [],
      associatedTypes: [Swift::String: Swift::Set<Swift::String>] = [:],
      conformances: [Swift::String: Swift::Set<Swift::String>] = [:]
    ) {
      self.valueGenericTypes = valueGenericTypes
      self.associatedTypes = associatedTypes
      self.conformances = conformances
    }
  }
}

extension Lint.Source.Index {

  public static func collect(from tree: SourceFileSyntax) -> Self {
    let collector = Lint.Source.IndexCollector(viewMode: .sourceAccurate)
    collector.walk(tree)
    return collector.index
  }

  public mutating func merge(_ other: Self) {
    valueGenericTypes.formUnion(other.valueGenericTypes)
    associatedTypes.merge(other.associatedTypes) { $0.union($1) }
    conformances.merge(other.conformances) { $0.union($1) }
  }

  public func protocols(of type: Swift::String) -> Swift::Set<Swift::String> {
    conformances[type] ?? conformances[Self.leaf(of: type)] ?? []
  }

  public func isValueGeneric(_ type: Swift::String) -> Swift::Bool {
    valueGenericTypes.contains(type) || valueGenericTypes.contains(Self.leaf(of: type))
  }

  public func witnessesAssociatedType(
    named name: Swift::String,
    on type: Swift::String
  ) -> Swift::Bool {
    var pending = Swift::Array(protocols(of: type))
    var seen: Swift::Set<Swift::String> = []
    while let next = pending.popLast() {
      guard seen.insert(next).inserted else { continue }
      if associatedTypes[next]?.contains(name) ?? false { return true }
      pending.append(contentsOf: conformances[next] ?? [])
    }
    return false
  }

  @usableFromInline
  internal static func leaf(of type: Swift::String) -> Swift::String {
    type.split(separator: ".").last.map(Swift::String.init) ?? type
  }

  @usableFromInline
  internal static func spelling(of type: TypeSyntax) -> Swift::String {
    if let identifier = type.as(IdentifierTypeSyntax.self) {
      return identifier.name.text
    }
    if let member = type.as(MemberTypeSyntax.self) {
      return spelling(of: member.baseType) + "." + member.name.text
    }
    if let attributed = type.as(AttributedTypeSyntax.self) {
      return spelling(of: attributed.baseType)
    }
    return type.trimmedDescription
  }
}
