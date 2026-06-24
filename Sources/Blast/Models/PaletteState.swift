enum PaletteState: Equatable {
    case dismissed
    case presenting
    case idle
    case filtering(String)
    case action(String)
    case asking(String)
    case thinking(String)
    case dismissing
}
