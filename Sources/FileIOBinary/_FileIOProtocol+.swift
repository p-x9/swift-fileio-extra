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

    @inline(__always)
    public func readString(
        offset: UInt64,
        step: Int = 10
    ) -> String? {
        if let fileHandle = self as? (any _MemoryMappedFileIOProtocol) {
            return String(
                cString: fileHandle.ptr
                    .advanced(by: numericCast(offset))
                    .assumingMemoryBound(to: CChar.self)
            )
        } else {
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
}

extension _FileIOProtocol {
    @inline(__always)
    public func _readString<Encoding: _UnicodeEncoding>(
        offset: Int,
        as encoding: Encoding.Type
    ) -> (string: String, numberOfBytes: Int)? {
        if let fileHandle = self as? (any _MemoryMappedFileIOProtocol) {
            return UnsafeRawPointer(fileHandle.ptr)
                .advanced(by: offset)
                .assumingMemoryBound(to: Encoding.CodeUnit.self)
                .readString(
                    as: Encoding.self
                )
        } else {
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
