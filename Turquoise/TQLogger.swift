import Swift

enum TQLoggingLevel : Int {
  case off   = 4  // do not log anything
  case error = 3  // log only errors
  case info  = 2  // log info and error messages
  case debug = 1  // log everything (verbose)

  static func >= (x: TQLoggingLevel, y: TQLoggingLevel) -> Bool {
    return x.rawValue >= y.rawValue
  }
}

// This is the constant that controls the amount of logging in the entire app.
let loggingLevel: TQLoggingLevel = .off

func printDebug(_ items: Any..., separator: String = " ", terminator: String = "\n") {
  tq_print(.debug, items, separator: separator, terminator: terminator)
}

func printInfo(_ items: Any..., separator: String = " ", terminator: String = "\n") {
  tq_print(.info, items, separator: separator, terminator: terminator)
}

func printError(_ items: Any..., separator: String = " ", terminator: String = "\n") {
  tq_print(.error, items, separator: separator, terminator: terminator)
}

func tq_print(_ level: TQLoggingLevel, _ items: Any..., separator: String = " ", terminator: String = "\n") {
  if level >= loggingLevel {
    print(items, separator, terminator)
  }
}
