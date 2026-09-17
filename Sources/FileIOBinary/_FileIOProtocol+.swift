//
//  _FileIOProtocol+.swift
//  MachOKit
//
//  Created by p-x9 on 2025/05/06
//
//

import Foundation
import FileIO
@_spi(Core) import BinaryParseSupport

// `memchr` below. Foundation re-exports libc on Darwin and Glibc but not on
// Android, so the unqualified name needs this.
#if os(Windows)
import ucrt
#elseif canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#elseif canImport(Musl)
import Musl
#elseif canImport(WASILibc)
import WASILibc
#elseif canImport(Android)
import Android
#endif

extension _FileIOProtocol {
    public func readDataSequence<Element>(
        offset: UInt64,
        numberOfElements: Int,
        swapHandler: ((inout Data) -> Void)? = nil
    ) /*throws*/ -> DataSequence<Element> where Element: LayoutWrapper {
        let size = Element.layoutSize * numberOfElements
        var data = try! readData(
            offset: numericCast(offset),
            length: size
        )
        precondition(
            Element.layoutSize == MemoryLayout<Element>.size,
            "Invalid Layout Size"
        )
        precondition(
            data.count >= size,
            "Invalid Data Size"
        )
        if let swapHandler { swapHandler(&data) }
        return .init(
            data: data,
            numberOfElements: numberOfElements
        )
    }

    @_disfavoredOverload
    public func readDataSequence<Element>(
        offset: UInt64,
        numberOfElements: Int,
        swapHandler: ((inout Data) -> Void)? = nil
    ) /*throws*/ -> DataSequence<Element> {
        let size = MemoryLayout<Element>.size * numberOfElements
        var data = try! readData(
            offset: numericCast(offset),
            length: size
        )
        precondition(
            data.count >= size,
            "Invalid Data Size"
        )
        if let swapHandler { swapHandler(&data) }
        return .init(
            data: data,
            numberOfElements: numberOfElements
        )
    }

    public func readDataSequence<Element>(
        offset: UInt64,
        entrySize: Int,
        numberOfElements: Int,
        swapHandler: ((inout Data) -> Void)? = nil
    ) -> DataSequence<Element> where Element: LayoutWrapper {
        let size = entrySize * numberOfElements
        var data = try! readData(
            offset: numericCast(offset),
            length: size
        )
        precondition(
            Element.layoutSize == MemoryLayout<Element>.size,
            "Invalid Layout Size"
        )
        precondition(
            data.count >= size,
            "Invalid Data Size"
        )
        if let swapHandler { swapHandler(&data) }
        return .init(
            data: data,
            entrySize: entrySize
        )
    }

    @_disfavoredOverload
    public func readDataSequence<Element>(
        offset: UInt64,
        entrySize: Int,
        numberOfElements: Int,
        swapHandler: ((inout Data) -> Void)? = nil
    ) -> DataSequence<Element> {
        let size = entrySize * numberOfElements
        var data = try! readData(
            offset: numericCast(offset),
            length: size
        )
        precondition(
            data.count >= size,
            "Invalid Data Size"
        )
        if let swapHandler { swapHandler(&data) }
        return .init(
            data: data,
            entrySize: entrySize
        )
    }
}

extension _FileIOProtocol {
    @inline(__always)
    public func read<Element>(
        offset: UInt64
    ) -> Optional<Element> where Element: LayoutWrapper {
        precondition(
            Element.layoutSize == MemoryLayout<Element>.size,
            "Invalid Layout Size"
        )
        return try! read(offset: numericCast(offset), as: Element.self)
    }

    @inline(__always)
    public func read<Element>(
        offset: UInt64
    ) -> Optional<Element> {
        try! read(offset: numericCast(offset), as: Element.self)
    }


    @_disfavoredOverload
    @inline(__always)
    public func read<Element>(
        offset: UInt64
    ) -> Element where Element: LayoutWrapper {
        precondition(
            Element.layoutSize == MemoryLayout<Element>.size,
            "Invalid Layout Size"
        )
        return try! read(offset: numericCast(offset), as: Element.self)
    }

    @_disfavoredOverload
    @inline(__always)
    public func read<Element>(
        offset: UInt64
    ) -> Element {
        try! read(offset: numericCast(offset), as: Element.self)
    }
}

extension _FileIOProtocol {
    public func read<Element>(
        offset: UInt64,
        swapHandler: ((inout Data) -> Void)?
    ) -> Optional<Element> where Element: LayoutWrapper {
        var data = try! readData(
            offset: numericCast(offset),
            length: Element.layoutSize
        )
        precondition(
            Element.layoutSize == MemoryLayout<Element>.size,
            "Invalid Layout Size"
        )
        precondition(
            data.count >= Element.layoutSize,
            "Invalid Data Size"
        )
        if let swapHandler { swapHandler(&data) }
        return data.withUnsafeBytes {
            $0.load(as: Element.self)
        }
    }

    public func read<Element>(
        offset: UInt64,
        swapHandler: ((inout Data) -> Void)?
    ) -> Optional<Element> {
        var data = try! readData(
            offset: numericCast(offset),
            length: MemoryLayout<Element>.size
        )
        precondition(
            data.count >= MemoryLayout<Element>.size,
            "Invalid Data Size"
        )
        if let swapHandler { swapHandler(&data) }
        return data.withUnsafeBytes {
            $0.load(as: Element.self)
        }
    }

    @_disfavoredOverload
    public func read<Element>(
        offset: UInt64,
        swapHandler: ((inout Data) -> Void)?
    ) -> Element where Element: LayoutWrapper {
        var data = try! readData(
            offset: numericCast(offset),
            length: Element.layoutSize
        )
        precondition(
            Element.layoutSize == MemoryLayout<Element>.size,
            "Invalid Layout Size"
        )
        precondition(
            data.count >= Element.layoutSize,
            "Invalid Data Size"
        )
        if let swapHandler { swapHandler(&data) }
        return data.withUnsafeBytes {
            $0.load(as: Element.self)
        }
    }

    @_disfavoredOverload
    public func read<Element>(
        offset: UInt64,
        swapHandler: ((inout Data) -> Void)?
    ) -> Element {
        var data = try! readData(
            offset: numericCast(offset),
            length: MemoryLayout<Element>.size
        )
        precondition(
            data.count >= MemoryLayout<Element>.size,
            "Invalid Data Size"
        )
        if let swapHandler { swapHandler(&data) }
        return data.withUnsafeBytes {
            $0.load(as: Element.self)
        }
    }
}

extension _FileIOProtocol {
    @inline(__always)
    public func readString(
        offset: UInt64,
        size: Int
    ) -> String? {
        let data = try! readData(
            offset: numericCast(offset),
            length: size
        )
        return String(cString: data)
    }

    @inlinable
    @inline(__always)
    public func readString(
        offset: UInt64,
        step: Int = 10
    ) -> String? {
        // The run reported here is bounded: a concatenated mapping holds one
        // mapping per file, so scanning for the terminator past `count` would
        // leave the segment. Without a terminator inside the run, fall
        // through to the copying path, which crosses segments.
        //
        // `memchr` rather than a scan written here: it is the bounded form of
        // `strlen`, and optimised the same way. Scanning by hand costs 40%
        // more on long strings.
        if let fileHandle = self as? (any _MemoryMappedFileIOProtocol),
           let region = try? fileHandle.unsafeRegion(at: numericCast(offset)),
           let terminator = memchr(region.pointer, 0, region.count) {
            let length = UnsafeRawPointer(terminator)
                - UnsafeRawPointer(region.pointer)
            return String(
                decoding: UnsafeRawBufferPointer(
                    start: region.pointer,
                    count: length
                ),
                as: UTF8.self
            )
        }

        var data = Data()
        var offset = offset
        while true {
            guard let new = try? readData(
                offset: numericCast(offset),
                upToCount: step
            ) else { break }
            if new.isEmpty { break }
            data.append(new)
            if new.contains(0) { break }
            offset += UInt64(new.count)
        }

        return String(cString: data)
    }
}

extension _FileIOProtocol {
    @inlinable
    @inline(__always)
    public func _readString<Encoding: _UnicodeEncoding>(
        offset: Int,
        as encoding: Encoding.Type
    ) -> (string: String, numberOfBytes: Int)? {
        // Bounded by the contiguous run for the same reason as `readString`
        // above, and falling through to the copying path when the terminator
        // is not inside it.
        //
        // Only the scan is bounded; the string still comes from
        // `String(decodingCString:)`. Building it from the bounded buffer
        // means `String(decoding:as:)` over a generic `Encoding`, which does
        // not specialise and costs 20x. A code unit wider than a byte has no
        // `memchr`, so this scan is written out.
        if let fileHandle = self as? (any _MemoryMappedFileIOProtocol),
           let region = try? fileHandle.unsafeRegion(at: offset) {
            let start = UnsafeRawPointer(region.pointer)
                .assumingMemoryBound(to: Encoding.CodeUnit.self)
            let count = region.count / MemoryLayout<Encoding.CodeUnit>.size
            var index = 0
            while index < count, start[index] != 0 { index += 1 }
            if index < count {
                return (
                    String(decodingCString: start, as: Encoding.self),
                    (index + 1) * MemoryLayout<Encoding.CodeUnit>.size
                )
            }
        }

        // Scoped so that `offset` below can shadow the parameter.
        do {
            var count = 0
            var offset: Int = offset

            var characters: [Encoding.CodeUnit] = []

            while let char = try? read(
                offset: offset,
                as: Encoding.CodeUnit.self
            ), char != 0 {
                characters.append(char)
                count += 1
                offset += MemoryLayout<Encoding.CodeUnit>.size
            }

            characters.append(0)

            return characters.withUnsafeBytes { bufferPtr in
                guard let baseAddress = bufferPtr.baseAddress else {
                    return nil
                }
                let string = String(
                    decodingCString: baseAddress
                        .assumingMemoryBound(to: Encoding.CodeUnit.self),
                    as: Encoding.self
                )
                let length = (count + 1) * MemoryLayout<Encoding.CodeUnit>.size
                return (string, length)
            }
        }
    }
}
