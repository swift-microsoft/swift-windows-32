import Path
import Testing

@testable import Windows_32_Kernel_File

@Suite
struct `Path.Canonical conventional form` {

    static func conventional(_ extended: Swift.String) -> Swift.String {
        var units = Array(extended.utf16)
        let start = Path.Canonical.conventionalStart(of: units.span)
        guard let start else { return extended }
        if start == 6 { units[start] = 0x5C }
        return Swift.String(decoding: units[start...], as: UTF16.self)
    }

    @Test(arguments: [
        (#"\\?\C:\Users\runner\work"#, #"C:\Users\runner\work"#),
        (#"\\?\d:\"#, #"d:\"#),
        (#"\\?\C:\a\b.txt"#, #"C:\a\b.txt"#),
        (#"\\?\UNC\server\share\dir"#, #"\\server\share\dir"#),
        (#"\\?\unc\server\share"#, #"\\server\share"#),
        (#"\\?\C:\CONSOLE\COM10\LPT0"#, #"C:\CONSOLE\COM10\LPT0"#),
    ])
    func `strips the extended prefix when the path is expressible`(extended: Swift.String, expected: Swift.String) {
        #expect(Self.conventional(extended) == expected)
    }

    @Test(arguments: [
        #"\\?\Volume{0b5c1c4e-0000-0000-0000-100000000000}\dir"#,
        #"\\?\C:\dir\name."#,
        #"\\?\C:\dir\name "#,
        #"\\?\C:\dir\a/b"#,
        #"\\?\C:\dir\CON"#,
        #"\\?\C:\dir\nul.txt"#,
        #"\\?\C:\dir\Com1"#,
        #"\\?\C:\dir\LPT9.log"#,
        #"\\?\C:\dir\COM¹"#,
        #"\\?\C:\dir\aux .txt"#,
        #"\\?\UNC\\share"#,
        #"C:\already\conventional"#,
        #"\\?\C:"#,
    ])
    func `keeps the extended form when stripping would change the meaning`(extended: Swift.String) {
        #expect(Self.conventional(extended) == extended)
    }

    @Test
    func `keeps the extended form at MAX_PATH and beyond`() {
        let fits = #"\\?\C:\"# + Swift.String(repeating: "a", count: 256)
        let tooLong = #"\\?\C:\"# + Swift.String(repeating: "a", count: 257)
        #expect(Self.conventional(fits) == #"C:\"# + Swift.String(repeating: "a", count: 256))
        #expect(Self.conventional(tooLong) == tooLong)
    }
}
