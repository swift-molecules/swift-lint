extension Lint.Rule.Repair {

    public enum Proposal: Sendable, Equatable {
        case unchanged
        case edits([Edit])
        case refused(Lint.Rule.Reason)
    }
}
