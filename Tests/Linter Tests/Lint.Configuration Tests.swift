import Linter_Test_Support
import Testing

extension Lint.Configuration {
  @Suite
  struct Test {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
  }
}

extension Lint.Configuration.Test.Unit {
  @Test
  func `Empty configuration has no rules and no excluded paths`() {
    let config = Lint.Configuration.empty
    #expect(config.rules.entries.isEmpty)
    #expect(config.excluded.isEmpty)
    #expect(config.parent == nil)
  }

  @Test
  func `Configuration captures rules from result-builder block`() {
    let config = Lint.Configuration {

    }
    #expect(config.rules.entries.isEmpty)
  }

  @Test
  func `Configuration captures excluded paths`() {
    let config = Lint.Configuration(
      excluded: ["Tests/Fixtures", ".build"]
    ) { [] }
    #expect(config.excluded == ["Tests/Fixtures", ".build"])
  }

  @Test
  func `Configuration captures parent inheritance`() {
    let parent = Lint.Configuration { [] }
    let child = Lint.Configuration(inheriting: parent) { [] }
    #expect(child.parent != nil)
  }

  @Test
  func `rules effective entries empty for empty configuration`() {
    let config = Lint.Configuration.empty
    #expect(config.rules.effective.entries.isEmpty)
  }
}

extension Lint.Filter {
  @Suite
  struct Test {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
  }
}

extension Lint.Filter.Test.Unit {
  @Test
  func `all filter has no constraints`() {
    let filter = Lint.Filter.all
    #expect(filter.included.isEmpty)
    #expect(filter.excluded.isEmpty)
  }

  @Test
  func `including factory captures included prefixes`() {
    let filter = Lint.Filter.including(["Sources"])
    #expect(filter.included == ["Sources"])
    #expect(filter.excluded.isEmpty)
  }

  @Test
  func `excluding factory captures excluded prefixes`() {
    let filter = Lint.Filter.excluding(["Tests/Fixtures"])
    #expect(filter.included.isEmpty)
    #expect(filter.excluded == ["Tests/Fixtures"])
  }
}
