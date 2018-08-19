import Swift

// This is the constant that controls the amount of logging in the entire app.
#if RELEASE
  let loggingLevel: TQLoggingLevel = .off
#else
  let loggingLevel: TQLoggingLevel = .debug
#endif

enum TQLoggingLevel : Int {
  case off   = 4  // do not log anything
  case error = 3  // log only errors
  case info  = 2  // log info and error messages
  case debug = 1  // log everything (verbose)

  static func >= (x: TQLoggingLevel, y: TQLoggingLevel) -> Bool {
    return x.rawValue >= y.rawValue
  }

    func icon() -> String? {
        switch self {
        case .error:
            return "⛔"
        case .info:
            return "⚠️"
        default:
            return nil
        }
    }
}

func printDebug(_ items: Any..., separator: String = " ", terminator: String = "\n") {
  let output = items.map { "\($0)" }.joined(separator: separator)
  tq_print(.debug, output)
}

func printInfo(_ items: Any..., separator: String = " ", terminator: String = "\n") {
  let output = items.map { "\($0)" }.joined(separator: separator)
  tq_print(.info, output)
}

func printError(_ items: Any..., separator: String = " ", terminator: String = "\n") {
  let output = items.map { "\($0)" }.joined(separator: separator)
  tq_print(.error, output)
}

func tq_print(_ level: TQLoggingLevel, _ message: String) {
  if level >= loggingLevel {
    var string = message
    if let icon = level.icon() {
      string = "\(icon) \(message)"
    }
    print(string, separator: " ", terminator: "\n")
  }
}
