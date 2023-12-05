//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2023 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import os.lock

internal struct _ManagedCriticalState<State> {

    private let lock: Lock
    final private class LockedBuffer: ManagedBuffer<State, UnsafeRawPointer> { }

    private let buffer: ManagedBuffer<State, UnsafeRawPointer>

    internal init(_ buffer: ManagedBuffer<State, UnsafeRawPointer>) {
        self.buffer = buffer
        self.lock = Lock()
    }

    internal init(_ initial: State) {
        let roundedSize = (MemoryLayout<UnsafeRawPointer>.size - 1) / MemoryLayout<UnsafeRawPointer>.size
        self.init(LockedBuffer.create(minimumCapacity: Swift.max(roundedSize, 1)) { buffer in
            return initial
        })
    }

    internal func withCriticalRegion<R>(
        _ critical: (inout State) throws -> R
    ) rethrows -> R {
        try buffer.withUnsafeMutablePointers { header, _ in
            self.lock.lock()
            defer {
                self.lock.unlock()
            }
            return try critical(&header.pointee)
        }
    }
}

extension _ManagedCriticalState: @unchecked Sendable where State: Sendable { }

extension _ManagedCriticalState: Identifiable {
    internal var id: ObjectIdentifier {
        ObjectIdentifier(buffer)
    }
}

private extension _ManagedCriticalState {
    final class Lock {
        private let _lock: os_unfair_lock_t

        init() {
            self._lock = .allocate(capacity: 1)
            self._lock.initialize(to: os_unfair_lock())
        }

        func lock() {
            os_unfair_lock_lock(_lock)
        }

        func unlock() {
            os_unfair_lock_unlock(_lock)
        }

        deinit {
            self._lock.deinitialize(count: 1)
            self._lock.deallocate()
        }
    }
}
