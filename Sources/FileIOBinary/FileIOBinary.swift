import Foundation
import FileIO
import BinaryParseSupport

extension MemoryMappedFile: @retroactive UnicodeStringsSource {}
extension MemoryMappedFileSlice: @retroactive UnicodeStringsSource {}

extension StreamedFile: @retroactive UnicodeStringsSource {}
extension StreamedFileSlice: @retroactive UnicodeStringsSource {}

extension ConcatenatedMemoryMappedFile: @retroactive UnicodeStringsSource {}
extension ConcatenatedStreamedFile: @retroactive UnicodeStringsSource {}
