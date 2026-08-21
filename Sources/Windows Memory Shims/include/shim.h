#ifndef CWINDOWS_MEMORY_SHIM_H
#define CWINDOWS_MEMORY_SHIM_H

#if defined(_WIN32)

#include <windows.h>

#define PSAPI_VERSION 2
#include <psapi.h>

typedef struct {
    SIZE_T allocations;
    SIZE_T deallocations;
    SIZE_T bytes_allocated;
} WindowsMemoryStats;

static inline WindowsMemoryStats windows_heap_statistics(void) {
    WindowsMemoryStats stats = {0, 0, 0};

    PROCESS_MEMORY_COUNTERS_EX pmc;
    if (GetProcessMemoryInfo(GetCurrentProcess(), (PROCESS_MEMORY_COUNTERS*)&pmc, sizeof(pmc))) {
        stats.bytes_allocated = pmc.WorkingSetSize;
        stats.allocations = pmc.PageFaultCount;
    }

    return stats;
}

#endif

#endif
