import Foundation

public extension String {
  var tq_decodedString: String {
    // TODO: implement
    return self
  }

  var tq_newlineStrippedString: String {
    // TODO: implement
    return self
  }

  var tq_whitespaceAndNewlineStrippedString: String {
    return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
  }

  var tq_isEmpty: Bool {
    return self.tq_whitespaceAndNewlineStrippedString.count == 0
  }
}
