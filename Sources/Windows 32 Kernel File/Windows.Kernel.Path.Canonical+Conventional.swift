internal import Path

extension Path.Canonical {

    internal static func conventionalStart(of units: Swift.Span<UInt16>) -> Int? {
        let backslash: UInt16 = 0x5C
        guard units.count >= 7,
            units[0] == backslash,
            units[1] == backslash,
            units[2] == 0x3F,
            units[3] == backslash
        else { return nil }

        let start: Int
        let firstComponent: Int
        if isLetter(units[4]), units[5] == 0x3A, units[6] == backslash {
            start = 4
            firstComponent = 7
        } else if units.count > 8,
            uppercased(units[4]) == 0x55,
            uppercased(units[5]) == 0x4E,
            uppercased(units[6]) == 0x43,
            units[7] == backslash,
            units[8] != backslash
        {
            start = 6
            firstComponent = 8
        } else {
            return nil
        }

        guard units.count - start < 260 else { return nil }

        var componentStart = firstComponent
        for index in firstComponent...units.count {
            guard index == units.count || units[index] == backslash else {
                guard units[index] != 0x2F else { return nil }
                continue
            }
            if index > componentStart {
                guard isPortable(units.extracting(componentStart..<index)) else { return nil }
            }
            componentStart = index + 1
        }
        return start
    }

    private static func isLetter(_ unit: UInt16) -> Bool {
        (0x41...0x5A).contains(unit) || (0x61...0x7A).contains(unit)
    }

    private static func uppercased(_ unit: UInt16) -> UInt16 {
        (0x61...0x7A).contains(unit) ? unit - 0x20 : unit
    }

    private static func isPortable(_ component: Swift.Span<UInt16>) -> Bool {
        let last = component[component.count - 1]
        guard last != 0x2E, last != 0x20 else { return false }
        var base: [UInt16] = []
        for index in component.indices {
            guard component[index] != 0x2E else { break }
            base.append(uppercased(component[index]))
        }
        while base.last == 0x20 { base.removeLast() }
        return !reserved(base)
    }

    private static func reserved(_ base: [UInt16]) -> Bool {
        let names = ["CON", "PRN", "AUX", "NUL", "CONIN$", "CONOUT$"]
        if names.contains(where: { Array($0.utf16) == base }) { return true }
        guard base.count == 4 else { return false }
        let stem = Array(base.prefix(3))
        guard stem == Array("COM".utf16) || stem == Array("LPT".utf16) else { return false }
        let digit = base[3]
        return (0x31...0x39).contains(digit) || digit == 0xB9 || digit == 0xB2 || digit == 0xB3
    }
}
