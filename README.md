# swift-windows-32

Use this package when your Swift code runs on Windows and needs to call the Win32 kernel directly: files, directories, environment, processes and jobs, threads, sockets, I/O completion ports, memory mapping, file locks, the console and loading DLLs, each with typed errors and handles that close themselves. Start from ``Windows.`32`.Kernel.Descriptor`` and the namespace for your task under ``Windows.`32`.Kernel``, such as ``Windows.`32`.Kernel.File.Open`` or ``Windows.`32`.Kernel.IO.Completion.Port``. Each area is its own product, so you can depend on only the one you need. For code that must also run on macOS and Linux, use swift-kernel. For a higher-level layer over this package, use swift-windows.

## Laws

- Everything that calls Win32 is compiled only when building for Windows. On other platforms the products build but hold only the platform-neutral types.
- A descriptor owns its handle and closes it when it goes out of scope. A raw value of 0 or of all bits set is invalid, and closing, flushing, reading or writing an invalid descriptor fails without calling the system.
- ``Windows.`32`.Kernel.File.Open.Options`` chooses how a file is opened. `create` with `exclusive` creates a new file and fails if it exists. `create` with `truncate` always creates or empties it. `create` alone opens or creates. `truncate` alone empties an existing file. No options opens an existing file only.
- Files are always opened so that other handles may read, write and delete them at the same time. With `append`, every write goes to the end of the file. With `direct`, the system cache is bypassed and writes go through to the disk.
- A path made from text gets backslashes in place of forward slashes, unless it starts with the verbatim prefix `\\?\`.
- `Path.Canonical.canonicalize(_:)` resolves the path through links to the file it names. It drops the `\\?\` prefix only when the result stays shorter than 260 characters and every component is an ordinary name, so a reserved name such as `NUL` or a component ending in a dot keeps the prefix.
- Reading at end of file returns 0 bytes rather than failing, and so does reading into an empty buffer. ``Windows.`32`.Kernel.IO.Read.pread(_:into:at:)`` moves the file position, reads, and moves it back, so it is not safe alongside other reads on the same handle.
- ``Windows.`32`.Kernel.File.Flush.flushData(_:)`` flushes everything, the same as ``Windows.`32`.Kernel.File.Flush.flush(_:)``.
- A file lock range whose end equals its start locks nothing and succeeds. An end before the start fails. A range made for a mapping has its end rounded up to the allocation granularity, and an end that would overflow is clamped to the largest offset. A ``Windows.`32`.Kernel.Lock.Token`` releases its lock when it goes out of scope.
- ``Windows.`32`.Kernel.File.Direct.Mode`` resolves `uncached` to buffered I/O. Requirements built from a path are always unknown, so `direct` fails as not supported and `auto` falls back or fails as its policy says.
- ``Windows.`32`.Kernel.Event`` starts unsignaled and, once signaled, stays signaled for every waiter.
- An I/O completion port hands back completions in the order they were posted. Waiting for one completion fails on timeout, while waiting for a batch returns 0. A completion for an I/O that failed comes back as an item with an error status rather than as a thrown error.
- Listing a directory includes `.` and `..`. An entry with the directory attribute is a directory even when it is a link. Any other reparse point is reported as a symbolic link.
- Removing an environment variable that does not exist succeeds. Setting one with `overwrite` false leaves an existing value in place. Entries whose name starts with `=` are skipped.
- A spawned process inherits only the handles its actions list. When they list none, it inherits only the standard handles that are inheritable. A process spawned into a job starts suspended and is added to the job before it runs. If that fails, it is terminated.
- Looking up a symbol in the default scope searches only the main executable. The next scope always fails on Windows. Opening the same library twice gives the same handle.
