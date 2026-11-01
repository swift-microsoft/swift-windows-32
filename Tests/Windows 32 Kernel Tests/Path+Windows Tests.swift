#if os(Windows)

    import Path
    import Testing
    import Windows_32_Kernel

    @Suite("Path + Win32 grammar")
    struct Path_Windows_Tests {
        @Test func absolute() {
            let a: Path = #"C:\Users\a"#
            let b: Path = "C:/Users/a"
            let unc: Path = #"\\server\share\x"#
            let rel: Path = #"Users\a"#
            let driveRel: Path = "C:x"
            #expect(a.isAbsolute && b.isAbsolute && unc.isAbsolute)
            #expect(rel.isRelative && driveRel.isRelative)
        }
        @Test func roots() {
            let c: Path = #"C:\"#
            let unc: Path = #"\\server\share"#
            let deep: Path = #"\\server\share\x"#
            #expect(c.isRoot && unc.isRoot && !deep.isRoot)
        }
        @Test func parents() {
            let p: Path = #"C:\Users\a"#
            #expect(p.parent == #"C:\Users"#)
            #expect(p.parent?.parent == #"C:\"#)
            #expect(p.parent?.parent?.parent == nil)
            let mixed: Path = "C:/Users/a"
            #expect(mixed.parent == "C:/Users")
        }
        @Test func components() {
            let p: Path = #"C:\Users\\a/b\"#
            #expect(p.components.map(\.string) == ["C:", "Users", "a", "b"])
            #expect(p.lastComponent == "b")
        }
        @Test func appending() {
            let p: Path = #"C:\Users"#
            #expect(p / "a" == #"C:\Users\a"#)
            let slash: Path = #"C:\Users\"#
            #expect(slash / "a" == #"C:\Users\a"#)
            let abs: Path = #"D:\x"#
            #expect(p / abs == #"D:\x"#)
        }
        @Test func relative() {
            let p: Path = #"C:\Users\a\b.txt"#
            let base: Path = "C:/Users"
            #expect(p.relative(to: base) == #"a\b.txt"#)
            #expect(p.relative(to: p) == ".")
        }
        @Test func filenames() {
            for (text, error) in [
                ("CON", Windows.`32`.Filename.Error.reservedName), ("nul.txt", .reservedName), ("a:b", .containsReservedCharacter), ("a.", .trailingDotOrSpace), ("a\\b", .containsPathSeparator),
                ("", .empty),
            ] {
                #expect(throws: error) { _ = try Windows.`32`.Filename(text) }
            }
            #expect(throws: Never.self) { _ = try Windows.`32`.Filename("..") }
            #expect(throws: Never.self) { _ = try Windows.`32`.Filename("console.txt") }
        }
    }

#endif
