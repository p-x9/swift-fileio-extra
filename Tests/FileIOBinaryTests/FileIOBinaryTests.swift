import XCTest
import FileIO
@testable import FileIOBinary

final class FileIOBinaryTests: XCTestCase {}

extension FileIOBinaryTests {
    /// Writes one temporary file per element and hands back their urls.
    private func withTemporaryFiles(
        _ contents: [Data],
        _ body: ([URL]) throws -> Void
    ) throws {
        let directory = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("FileIOBinaryTests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )
        defer { try? FileManager.default.removeItem(at: directory) }

        let urls = try contents.enumerated().map { index, data -> URL in
            let url = directory.appendingPathComponent("\(index).bin")
            try data.write(to: url)
            return url
        }
        try body(urls)
    }

    private func utf16Bytes(_ string: String, terminated: Bool = true) -> Data {
        var units = Array(string.utf16)
        if terminated { units.append(0) }
        return units.withUnsafeBufferPointer { Data(buffer: $0) }
    }
}

extension FileIOBinaryTests {
    func testReadStringFromMappedFile() throws {
        try withTemporaryFiles([Data("hello\0world\0".utf8)]) { urls in
            let file = try MemoryMappedFile.open(url: urls[0], isWritable: false)
            XCTAssertEqual(file.readString(offset: 0), "hello")
            XCTAssertEqual(file.readString(offset: 6), "world")
        }
    }

    func testReadStringFromStreamedFile() throws {
        try withTemporaryFiles([Data("hello\0world\0".utf8)]) { urls in
            let file = try StreamedFile.open(url: urls[0], isWritable: false)
            XCTAssertEqual(file.readString(offset: 0), "hello")
            XCTAssertEqual(file.readString(offset: 6), "world")
        }
    }

    /// The string starts in one segment and its terminator is in the next.
    /// Each file is mapped separately, so scanning on from the first
    /// segment's pointer would leave that mapping. The run is bounded, so
    /// this falls back to a path that crosses segments.
    func testReadStringAcrossASegmentBoundary() throws {
        try withTemporaryFiles([Data("abcde".utf8), Data("fgh\0".utf8)]) { urls in
            let file = try ConcatenatedMemoryMappedFile.open(
                urls: urls,
                isWritable: false
            )
            XCTAssertEqual(file.size, 9)
            XCTAssertEqual(file.readString(offset: 0), "abcdefgh")
        }
    }

    /// A terminator inside the run takes the mapped path, which must stop at
    /// it rather than run to the end of the segment.
    func testReadStringStopsAtTheTerminatorWithinASegment() throws {
        try withTemporaryFiles([Data("ab\0cd".utf8), Data("ef\0".utf8)]) { urls in
            let file = try ConcatenatedMemoryMappedFile.open(
                urls: urls,
                isWritable: false
            )
            XCTAssertEqual(file.readString(offset: 0), "ab")
            XCTAssertEqual(file.readString(offset: 3), "cdef")
        }
    }
}

extension FileIOBinaryTests {
    func testTypedReadStringFromMappedFile() throws {
        try withTemporaryFiles([utf16Bytes("hello")]) { urls in
            let file = try MemoryMappedFile.open(url: urls[0], isWritable: false)
            let result = file._readString(offset: 0, as: UTF16.self)
            XCTAssertEqual(result?.string, "hello")
            XCTAssertEqual(result?.numberOfBytes, 12)
        }
    }

    /// The same boundary case, with the terminating code unit in the second
    /// segment.
    func testTypedReadStringAcrossASegmentBoundary() throws {
        try withTemporaryFiles([
            utf16Bytes("abc", terminated: false),
            utf16Bytes("de"),
        ]) { urls in
            let file = try ConcatenatedMemoryMappedFile.open(
                urls: urls,
                isWritable: false
            )
            let result = file._readString(offset: 0, as: UTF16.self)
            XCTAssertEqual(result?.string, "abcde")
            XCTAssertEqual(result?.numberOfBytes, 12)
        }
    }
}

extension FileIOBinaryTests {
    /// A record whose string fills its slot exactly, with the terminator
    /// outside it. Reading on past `size` used to return whatever followed in
    /// memory, which varied between runs.
    ///
    /// The fixture keeps going after the slot, with its own terminator much
    /// later, so `size` is the only thing that can stop the read: an
    /// implementation bounded by the mapping rather than by `size` returns
    /// the whole lot and fails here.
    func testSizedReadStopsAtTheEndOfTheRange() throws {
        let contents = Data("Intersect ShapesUnion ShapesSubtract Shapes\0".utf8)
        try withTemporaryFiles([contents]) { urls in
            let mapped = try MemoryMappedFile.open(url: urls[0], isWritable: false)
            XCTAssertEqual(
                mapped.readString(offset: 0, size: 16),
                "Intersect Shapes"
            )
            XCTAssertEqual(
                mapped.readString(offset: 16, size: 12),
                "Union Shapes"
            )

            let streamed = try StreamedFile.open(url: urls[0], isWritable: false)
            XCTAssertEqual(
                streamed.readString(offset: 0, size: 16),
                "Intersect Shapes"
            )
            XCTAssertEqual(
                streamed.readString(offset: 16, size: 12),
                "Union Shapes"
            )
        }
    }

    /// The padded shape, which is what a load command name looks like. More
    /// data follows the slot here too, for the same reason as above.
    func testSizedReadStopsAtATerminatorInsideTheRange() throws {
        try withTemporaryFiles([Data("abc\0\0\0defghi\0".utf8)]) { urls in
            let file = try MemoryMappedFile.open(url: urls[0], isWritable: false)
            XCTAssertEqual(file.readString(offset: 0, size: 6), "abc")
            XCTAssertEqual(file.readString(offset: 4, size: 2), "")
            XCTAssertEqual(file.readString(offset: 6, size: 3), "def")
        }
    }

    /// A range that spans two segments cannot come from one mapping, so it
    /// takes the copying path instead.
    func testSizedReadAcrossASegmentBoundary() throws {
        try withTemporaryFiles([Data("abc".utf8), Data("def".utf8)]) { urls in
            let file = try ConcatenatedMemoryMappedFile.open(
                urls: urls,
                isWritable: false
            )
            XCTAssertEqual(file.readString(offset: 0, size: 6), "abcdef")
            XCTAssertEqual(file.readString(offset: 2, size: 3), "cde")
        }
    }

    func testSizedReadRejectsEmptyAndOutOfRange() throws {
        try withTemporaryFiles([Data("abcdef".utf8)]) { urls in
            let file = try MemoryMappedFile.open(url: urls[0], isWritable: false)
            XCTAssertNil(file.readString(offset: 0, size: 0))
            XCTAssertNil(file.readString(offset: 0, size: 99))
            XCTAssertNil(file.readString(offset: 99, size: 1))
        }
    }
}
