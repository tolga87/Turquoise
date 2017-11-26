import Foundation

extension String {
  var tq_decodedString: String {

    if self.count < 4 {
      return self
    }

    if !self.contains("=?") {
      return self
    }

    let scanner = Scanner(string:self)
    let delimiterCharSet = CharacterSet(charactersIn: "=?_")
    var prefix: NSString?
    var encoding: NSString?

    var mutString = ""

    scanner.scanUpTo("=?", into: &prefix)
    if prefix != nil && prefix!.length > 0 {
      // prefix will be nil if the string begins with "=?"
      mutString += prefix! as String
    }
    scanner.scanCharacters(from: delimiterCharSet, into: nil)

    let charSetRead = scanner.scanUpTo("?", into: nil)
    if !charSetRead {
      printError("Invalid character set")
      return self
    }
    scanner.scanCharacters(from: CharacterSet(charactersIn: "?"), into: nil)

    let encodingRead = scanner.scanUpTo("?", into: &encoding)
    if !encodingRead {
      printError("Invalid encoding")
      return self
    }
    scanner.scanCharacters(from: CharacterSet(charactersIn: "?"), into: nil)

    let charIndex = self.index(self.startIndex, offsetBy: scanner.scanLocation)
    let messageBody = self.substring(from: charIndex)
    var decodedMessage: String?

    if let encoding = encoding as String? {
      switch encoding.uppercased() {
      case "Q":
        decodedMessage = self.qDecode(string: messageBody)
      case "B":
        decodedMessage = self.base64Decode(string: messageBody)
      default:
        // this should not happen
        decodedMessage = messageBody
      }
    }

    if let decodedMessage = decodedMessage {
      mutString += decodedMessage
    }
    return mutString
  }

  private func qDecode(string: String) -> String {
    var scanner = Scanner()
    var mutString = ""

    // The maximum number of bytes per character is 4
    let bufferLength = 4
    var decodingBuffer: [UInt8] = Array.init(repeating: UInt8(0), count: bufferLength)
    var bufferIndex = 0
    var decodedSequence: String?

    func resetDecodingBuffer() {
      for i in 0..<bufferLength {
        decodingBuffer[i] = UInt8(0)
      }
    }

    // I can't mutate the for loop index inside the loop,
    // so I use this variable to skip particular indexes.
    var indexesToSkip = 0

    for charIndex in 0 ..< string.count {
      if indexesToSkip > 0 {
        indexesToSkip -= 1
        continue
      }

      let curChar = string[string.index(string.startIndex, offsetBy: charIndex)]
      if curChar == "_" {
        mutString += " "
      } else if curChar == "?" {
        break
      } else if curChar != "=" {
        mutString += String(curChar)
      } else {
        // curChar == '='

        let startIndex = string.index(string.startIndex, offsetBy: charIndex)
        if string.index(startIndex, offsetBy: 2) >= string.endIndex {
          printError("Parsing error in Q-decoding")
          break
        }

        let range = (string.index(startIndex, offsetBy: 1)) ..< (string.index(startIndex, offsetBy: 3))
        let encodedCharString = string.substring(with: range)
        scanner = Scanner(string: encodedCharString)

        var decodedChar: UInt32 = 0
        scanner.scanHexInt32(&decodedChar)
        decodingBuffer[bufferIndex] = UInt8(decodedChar)

        if bufferIndex == bufferLength - 1 {
          // this is the last byte of this multi-byte character.
          // if we can't convert it to something readable here, there's something wrong.
          let data = Data(bytes: decodingBuffer)
          decodedSequence = String(data: data, encoding: .utf8)
          if decodedSequence == nil || decodedSequence == "" {
            decodedSequence = "?"
          }
          bufferIndex = 0
          resetDecodingBuffer()
        } else {
          // this could be a 1-, 2-, 3- or 4-byte character.
          // try to decode byte(s) we have first. if it fails, this must be a longer character.
          let data = Data(bytes: decodingBuffer[0...bufferIndex])
          decodedSequence = String(data: data, encoding: .utf8)
          if decodedSequence == nil || decodedSequence == "" {
            bufferIndex += 1
          } else {
            bufferIndex = 0
            resetDecodingBuffer()
          }
        }

        if let decodedSequence = decodedSequence {
          mutString += decodedSequence
        }

        indexesToSkip = 2
      }
    }

    return mutString
  }

  private func base64Decode(string: String) -> String {
    if string.count < 2 {
      return string
    }

    var encodedString = string
    if string.hasSuffix("?=") {
      let toIndex = string.index(string.endIndex, offsetBy: -2)
      encodedString = string.substring(to: toIndex)
    }

    guard let decodedData = Data(base64Encoded: encodedString) else {
      return string
    }

    let decodedString = String(data: decodedData, encoding: .utf8)
    return decodedString ?? string
  }

  var tq_newlineStrippedString: String {
    let newline = "\r\n"
    if self.hasSuffix(newline) {
      let suffixIndex = self.index(self.endIndex, offsetBy: -newline.count)
      return self.substring(to: suffixIndex)
    } else {
      return self
    }
  }

  var tq_whitespaceAndNewlineStrippedString: String {
    return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
  }

  var tq_isEmpty: Bool {
    return self.tq_whitespaceAndNewlineStrippedString.count == 0
  }
}
