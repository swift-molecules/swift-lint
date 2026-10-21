extension Lint {

    public struct Finding: Sendable, Hashable {

        public let record: Diagnostic.Record

        public let visibility: Lint.Visibility?

        @inlinable
        public init(
            record: Diagnostic.Record,
            visibility: Lint.Visibility? = nil
        ) {
            self.record = record
            self.visibility = visibility
        }
    }
}
