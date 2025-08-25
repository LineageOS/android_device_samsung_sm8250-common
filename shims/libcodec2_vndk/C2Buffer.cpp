/*
 * Copyright (C) 2025 The LineageOS Project
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include <C2BufferPriv.h>

extern "C" void _ZN17C2PooledBlockPoolC1ERKNSt3__110shared_ptrI11C2AllocatorEEmNS_13BufferPoolVerE(const std::shared_ptr<C2Allocator> &allocator, const C2BlockPool::local_id_t localId, C2PooledBlockPool::BufferPoolVer ver);

extern "C" void _ZN17C2PooledBlockPoolC1ERKNSt3__110shared_ptrI11C2AllocatorEEm(const std::shared_ptr<C2Allocator> &allocator, const C2BlockPool::local_id_t localId) 
{
    _ZN17C2PooledBlockPoolC1ERKNSt3__110shared_ptrI11C2AllocatorEEmNS_13BufferPoolVerE(allocator, localId, C2PooledBlockPool::VER_HIDL);
}
