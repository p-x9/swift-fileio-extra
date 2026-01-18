import Foundation
import FileIO
import BinaryParseSupport

#if hasAttribute(retroactive)

extension MemoryMappedFile: @retroactive UnicodeStringsSource {}
extension MemoryMappedFileSlice: @retroactive UnicodeStringsSource {}

extension StreamedFile: @retroactive UnicodeStringsSource {}
extension StreamedFileSlice: @retroactive UnicodeStringsSource {}

extension ConcatenatedMemoryMappedFile: @retroactive UnicodeStringsSource {}
extension ConcatenatedStreamedFile: @retroactive UnicodeStringsSource {}

#else

extension MemoryMappedFile: UnicodeStringsSource {}
extension MemoryMappedFileSlice: UnicodeStringsSource {}

extension StreamedFile: UnicodeStringsSource {}
extension StreamedFileSlice: UnicodeStringsSource {}

extension ConcatenatedMemoryMappedFile: UnicodeStringsSource {}
extension ConcatenatedStreamedFile: UnicodeStringsSource {}

#endif
