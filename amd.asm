; ===================================================================================
; ===================================================================================
;
;  (c) Paul Alan Freshney 2022-2025
;  v0.19, April 19th 2025
;
;  Source code:
;      https://github.com/MaximumOctopus/CPUIDx
;
;  Assembled using "Flat Assembler"
;      https://flatassembler.net/
;
; ===================================================================================
; =================================================================================== 

; leaf 05h, data in eax, ebx, ecx
; amd implementation
AMDMonitorMWait:

        mov esi, dword __Leaf05
        call ShowLeafInformation

        mov eax, 0x05                
        cpuid

        cinvoke printf, "  Monitor / MWAIT (EAX:0x%x EBX:0x%x ECX:0x%x) %c", eax, ebx, ecx, 10

        mov eax, 0x05                
        cpuid
                
        mov edi, ecx            ; make a backup 
                
        push eax
        push ebx
        cinvoke printf, "    Smallest monitor-line size: %d bytes %c", eax, 10
        pop ebx
        pop eax
                
        push ebx
        cinvoke printf, "    Largest monitor-line size : %d bytes %c", ebx, 10
        pop ebx
                
.bit0:  bt edi, kEMX
        jnc .bit1
                
        cinvoke printf, "    MONITOR/MWAIT extensions are supported %c", 10
                
.bit1:  bt edi, kIBE
        jnc .fin
                
        cinvoke printf, "    IBE. Interrupt break-event. MWAIT can use ECX bit 0 to allow interrupts %c", 10
        cinvoke printf, "      to cause an exit from the monitor event pending state %c", 10
                
.fin:

        ret

; =============================================================================================

; 06h leaf, data in eax and ecx
; AMD implementation
PowerManagementRelated:

        mov esi, dword __Leaf06
        call ShowLeafInformation

        cinvoke printf, "  Power Management Related Features %c", 10

        mov eax, 0x06
        cpuid

        mov edi, ecx

        bt eax, kARAT
        jnc .c0

        cinvoke printf, "    Timebase for the local APIC timer is not affected by processor p-state %c", 10

.c0:    bt edi, kEffFreq
        jnc .fin

        cinvoke printf, "    Effective frequency interface support %c", 10
        cinvoke printf, "      indicates presence of MSR0000_00E7 (MPERF) and MSR0000_00E8 (APERF) %c", 10

.fin:   ret

; =============================================================================================

; 07h leaf, flags in ebx, ecx, and edx
; amd implementation
AMDStructuredExtendedFeatureIDs:

        mov esi, dword __Leaf0700
        call ShowLeafInformation

        mov ecx, 0
        mov eax, 0x07           ; first pass
        cpuid

        cinvoke printf, "  Structured Extended Feature Identifiers %c", 10

        mov edi, __AMDStructuredExtendedFeatureIDs1

        mov esi, 0              ; bit counter

.lf1:   bt  ebx, esi
        jnc .nextb

        push ebx
        cinvoke printf, "    %02d::%s %c", esi, edi, 10
        pop ebx

.nextb: add edi, __AMDStructuredExtendedFeatureIDs1Size

        inc esi

        cmp esi, 32

        jne .lf1

        mov ecx, 0
        mov eax, 0x07           ; first pass
        cpuid

        mov edi, __AMDStructuredExtendedFeatureIDs2

        mov esi, 0              ; bit counter

.lf2:   bt  ecx, esi
        jnc .nextc

        push ecx
        cinvoke printf, "    %02d::%s %c", esi, edi, 10
        pop ecx

.nextc: add edi, __AMDStructuredExtendedFeatureIDs2Size

        inc esi

        cmp esi, 32

        jne .lf2

.fin:   ret

; =============================================================================================

;leaf 0bh, data in eax, ebc, edx
; AMD implementation
; for ecx = 0: ecx only contains thread level (1) in 15:8, and ecx input (0) in 7:0
; for ecx = 1: ecx only contains thread level (2) in 15:8, and ecx input (1) in 7:0
AMDProcExtTopologyEnum:

        cmp [__MaxBasic], 0x0b
        jl .fin
                
        mov esi, dword __Leaf0B00
        call ShowLeafInformation

        cinvoke printf, "  Extended Topology Enumeration %c", 10

        mov ecx, 0
        mov eax, 0x0b
        cpuid

        mov edi, ebx

        cinvoke printf, "    ThreadMaskWidth (bits to shift x2APIC_ID) %d; APIC_ID 0x%x %c", eax, edx, 10

        and edi, 0x0000FFFF     ; NumLogProc

        cinvoke printf, "    Number of logical processors in a core: %d %c", edi, 10

        mov esi, dword __Leaf0B01
        call ShowLeafInformation

        mov ecx, 1
        mov eax, 0x0b
        cpuid
                
        mov edi, ebx

        cinvoke printf, "    CoreMaskWidth (bits to shift x2APIC_ID) %d; APIC_ID 0x%x %c", eax, edx, 10

        and edi, 0x0000FFFF     ; NumLogCores

        cinvoke printf, "    Number of logical cores in a socket: %d %c", edi, 10

.fin:   ret

; =============================================================================================

; leaf 0dh
; amd implementation
AMDProcExtStateEnum:

        cmp [__MaxBasic], 0x0d
        jl .fin
                
        mov esi, dword __Leaf0D00
        call ShowLeafInformation
                
        cinvoke printf, "  Processor Extended State Enumeration %c", 10
                
        mov ecx, 0
        mov eax, 0x0d                
        cpuid
                
        mov edi, ecx
        mov esi, edx
                
        push ebx
        cinvoke printf, "    XFeatureSupportedMask    0x%x %c", eax, 10
        pop ebx
                
        cinvoke printf, "    XFeatureEnabledSizeMax   0x%x %c", ebx, 10
                
        cinvoke printf, "    Size XSAVE/XRSTOR area for all features that the logical processor supports %c", 10
        cinvoke printf, "                             %d bytes %c", edi, 10
                
        cinvoke printf, "    XFeatureSupportedSizeMax 0x%x %c", esi, 10

        mov esi, dword __Leaf0D01
        call ShowLeafInformation

        mov ecx, 1
        mov eax, 0x0d                
        cpuid
                
        mov edi, eax
        mov esi, ecx

.01a0:  bt edi, kXSAVEOPT
        jnc .01a1

        cinvoke printf, "    XSAVEOPT is available %c", 10

.01a1:  bt edi, kXSAVEC
        jnc .01a2

        cinvoke printf, "    XSAVEC and compact XRSTOR supported %c", 10

.01a2:  bt edi, kXGETBV
        jnc .01a3

        cinvoke printf, "    XGETBV with ECX = 1 supported %c", 10

.01a3:  bt edi, kIA32_XSS
        jnc .01c11
        
        cinvoke printf, "    XSAVES, XRSTOR, and XSS are supported %c", 10

.01c11: bt esi, kCET_U
        jnc .01c12

        cinvoke printf, "    CET_U. CET user state %c", 10
                
.01c12: bt esi, kCET_S
        jnc .func2

        cinvoke printf, "    CET_S. CET supervisor %c", 10

.func2: mov esi, dword __Leaf0D02
        call ShowLeafInformation
                
        mov ecx, 2
        mov eax, 0x0d                
        cpuid
                
        mov edi, ebx

        cinvoke printf, "    YMM register save area: %d bytes %c", eax, 10 

        cinvoke printf, "    YMM state save offset : %d bytes %c", edi, 10 

.funcb: mov esi, dword __Leaf0D0B
        call ShowLeafInformation

        mov ecx, 11
        mov eax, 0x0d
        cpuid

        mov edi, ebx
        mov esi, ecx

        cinvoke printf, "    CET user state save size: %d bytes %c", eax, 10 

        cinvoke printf, "    CET User state offset   : %d bytes %c", edi, 10 

        bt edi, kU_S
        jnc .funcC

        cinvoke printf, "    Supervisor state component %c", 10 

.funcC: mov esi, dword __Leaf0D0C
        call ShowLeafInformation

        mov ecx, 12
        mov eax, 0x0d
        cpuid

        mov edi, ebx
        mov esi, ecx

        cinvoke printf, "    CET supervisor state save size: %d bytes %c", eax, 10 

        cinvoke printf, "    CET supervisor state offset   : %d bytes %c", edi, 10 
 
        bt edi, kU_S
        jnc .func62

        cinvoke printf, "    Supervisor state component %c", 10 

.func62:

        mov esi, dword __Leaf0D3E
        call ShowLeafInformation

        mov ecx, 62
        mov eax, 0x0d
        cpuid

        mov edi, ebx

        cinvoke printf, "    LWP state save area size  : %d bytes %c", eax, 10 

        cinvoke printf, "    LWP state save byte offset: %d bytes %c", edi, 10 

.fin:   ret

; =============================================================================================

; leaf 0fh, data in eax, ebx, ecx, edx
; amd implementation
AMDPQOSMonitoring:

        mov eax, [__Features2]
        bt eax, kPQOS
                
        jnc .fin
                
        mov esi, dword __Leaf0F00
        call ShowLeafInformation
                
        mov ecx, 0
        mov eax, 0x0f
        cpuid           

        cinvoke printf, "  AMD PQOS Monitoring (PQM) (EBX:0x%x EDX:0x%x) %c", ebx, edx, 10

        mov ecx, 0
        mov eax, 0x0f
        cpuid
                
        mov esi, edx
                
        cinvoke printf, "    Largest RMID supported, any resource: 0x%x %c", ebx, 10

        bt esi, kL3CacheMon
        jnc .ecx1

        cinvoke printf, "    L3CacheMon. L3 Cache monitoring supported %c", 10

.ecx1:  mov esi, dword __Leaf0F01
        call ShowLeafInformation

        mov ecx, 1
        mov eax, 0x0f
        cpuid

        mov edi, ebx

        cinvoke printf, "    Largest RMID supported by L3CacheMon: 0x%x %c", ecx, 10

        cinvoke printf, "    Scale factor of value from QOS_CTR: 0x%x %c", edi, 10

        mov ecx, 1
        mov eax, 0x0f
        cpuid

        mov edi, eax
        mov esi, edx
                
        and eax, 0x000000FF
        add eax, 24             ; CounterSize is offset from 24 bits
                
        cinvoke printf, "    CM_CTR counter width: %d %c", eax, 10
                
        bt edi, kOverflowBit
        jnc .edx0

        cinvoke printf, "    MSR QM_CTR bit 61 is a counter overflow bit %c", 10

.edx0:  bt esi, kL3CacheOccMon
        jnc .edx1
                
        cinvoke printf, "    L3 Cache Occupancy Monitoring Event %c", 10
                
.edx1:  bt esi, kL3CacheBWMonEvt0
        jnc .edx2
                
        cinvoke printf, "    L3 Cache Bandwidth Monitoring Event 0 %c", 10

.edx2:  bt esi, kL3CacheBWMonEvt1
        jnc .fin
                
        cinvoke printf, "    L3 Cache Bandwidth Monitoring Event 1 %c", 10

.fin:   ret

; =============================================================================================

; leaf 10h, data in eax, ebx, ecx, and edx
; amd implementation
AMDPQECapabilities:

        mov eax, [__MaxExtended]
        bt eax, kPQE
                
        jnc .fin
                
        mov esi, dword __Leaf1000
        call ShowLeafInformation
                
        cinvoke printf, "  PQOS Enforcement (PQE) %c", 10
                
        mov ecx, 0
        mov eax, 0x10
        cpuid           

        bt eax, kL3Alloc
        jnc .ecx1
                
        cinvoke printf, "    L3 Cache Allocation Enforcement Support %c", 10
                
.ecx1:                          ; L3 Cache Allocation Enforcement Capabilities

        mov esi, dword __Leaf1001
        call ShowLeafInformation

        mov ecx, 1
        mov eax, 0x10
        cpuid
                
        mov edi, ebx

        and eax, 0x0000001F
                
        add eax, 1              ; CBM_LEN, bit mask length minus 1
                
        cinvoke printf, "    L3 cache capacity bit mask length: %d %c", eax, 10
                
        cinvoke printf, "    L3 cache allocation sharing mask : 0x%x %c", edi, 10
                
        mov ecx, 1
        mov eax, 0x10
        cpuid
                
        mov edi, edx
                
        bt eax, kCDP
        jnc .edx

        cinvoke printf, "    Code-Data Prioritization support %c", 10

.edx:   and edi, 0x000000FF     ; COS_MAX

        cinvoke printf, "    Maximum COS supported by L3 cache allocation enforcement: %d %c", edi, 10

.fin:   ret

; =============================================================================================
; =============================================================================================

; extended leaf 80000001h
ExtendedFeatures:

        mov eax, dword [__MaxExtended]

        cmp eax, 0x80000001

        jl .notsupported
                
.intel: cmp dword [__VendorID + 8], 0x6c65746e
        jne .amd

        mov esi, dword __Leaf80__01
        call ShowLeafInformation

        mov eax, 0x80000001
        cpuid

        mov edi, ecx
        mov esi, edx

        cinvoke printf, "  Extended CPU Features (ECX:0x%x EDX:0x%x) %c", edi, esi, 10

        bt edi, kxAHF
        jnc .lzcnt

        cinvoke printf, "    LAHF/SAHF available in 64-bit mode %c", 10

.lzcnt:

        bt edi, kLZCNT
        jnc .prefetchw

        cinvoke printf, "    LZCNT (count the number of leading zero bits) %c", 10

.prefetchw:

        bt edi, kPREFETCHW
        jnc .syscall

        cinvoke printf, "    PREFETCHW (software prefetches) %c", 10

.syscall:

        bt esi, kSYSCALL
        jnc .execdis

        cinvoke printf, "    SYSCALL/SYSRET %c", 10

.execdis:

        bt esi, kExecuteDisableBit
        jnc .onegig

        cinvoke printf, "    Execute Disable Bit available %c", 10

.onegig:

        bt esi, k1GBytePages
        jnc .rdtscp

        cinvoke printf, "    1-GByte pages are available %c", 10

.rdtscp:

        bt esi, kRDTSCP
        jnc .i64arch

        cinvoke printf, "    RDTSCP and IA32_TSC_AUX available %c", 10

.i64arch:

        bt esi, kIntel64Architecture
        jnc .fin

        cinvoke printf, "    Intel(r) 64 Architecture available %c", 10

        ret

.notsupported:

        cinvoke printf, "  Extended Features not supported %c", 10

        ret
                
        cmp dword [__VendorID + 8], 0x444d4163
        jne .fin                        
                                
.amd:   mov eax, 0x80000001
        cpuid

        push ecx
        push edx
        cinvoke printf, "  Extended CPU Features (ECX:0x%x EDX:0x%x) %c", ecx, edx, 10
        pop edx
        pop ecx

        mov edi, dword __AMDFeatureIdentifiers1
                        
.showc: mov esi, 0              ; bit counter

.cx:    bt  ecx, esi
        jnc .nxtc

        push ecx
        push edx
        cinvoke printf, "    %02d::%s %c", esi, edi, 10
        pop edx
        pop ecx

.nxtc:  add edi, __AMDFeatureIdentifiers1Size

        inc esi

        cmp esi, 32             ; bits to check

        jne .cx

        push edx
        cinvoke printf, "%c", 10
        pop edx

        mov esi, 0
        mov edi, dword __AMDFeatureIdentifiers2
                        
.showd: mov esi, 0

.dx:    bt  edx, esi
        jnc .nxtd

        push edx
        cinvoke printf, "    %02d::%s %c", esi, edi, 10
        pop edx

.nxtd:  add edi, __AMDFeatureIdentifiers2Size

        inc esi

        cmp esi, 32             ; bits to text

        jne .dx

.fin:   ret

; =============================================================================================

; extended leaf 80000005h
; AMD only
AMDCacheTLBLevelOne:

        mov eax, dword [__MaxExtended]

        cmp eax, 0x80000005
        jl .notsupported
                
        mov esi, dword __Leaf80__05
        call ShowLeafInformation

        cinvoke printf, "  L1 Cache and TLB Information %c", 10

        mov eax, 0x80000005
        cpuid
                
        mov edi, eax
                
        and eax, 0x000000FF     ; L1ITlb2and4MSize

        cinvoke printf, "    L1 instruction TLB, entries for 2MB/4MB pages: %d %c", eax, 10

        mov eax, edi
        shr eax, 8
        and eax, 0x000000FF     ; L1ITlb2and4MAssoc
                
        call AMDCacheTLBLevelOneFromTable

        mov eax, edi

        shr eax, 16
        and eax, 0x000000FF     ; L1DTlb2and4MSize

        cinvoke printf, "    L1 data TLB, entries for 2MB/4MB pages: %d %c", eax, 10

        mov eax, edi
        shr eax, 24
        and eax, 0x000000FF     ; L1DTlb2and4MAssoc
                
        call AMDCacheTLBLevelOneFromTable

        mov eax, 0x80000005     ; pass 2 (ebx)
        cpuid
                
        mov edi, ebx

        mov eax, ebx

        and eax, 0x000000FF     ; L1ITlb4KSize

        cinvoke printf, "    Instruction TLB number of entries for 4KB pages: %d %c", eax, 10

        mov eax, edi
        shr eax, 8
        and eax, 0x000000FF     ; L1ITlb4KAssoc

        call AMDCacheTLBLevelOneFromTable

        mov eax, edi
        shr eax, 16
        and eax, 0x000000FF     ; L1DTlb4KSize

        cinvoke printf, "    Data TLB number of entries for 4KB pages: %d %c", eax, 10

        mov eax, edi
        shr eax, 24
        and eax, 0x000000FF     ; L1DTlb4KAssoc
                
        call AMDCacheTLBLevelOneFromTable
                
        mov eax, 0x80000005     ; pass 3 (ecx)
        cpuid

        mov edi, ecx
        mov eax, ecx

        and eax, 0x000000FF     ; L1DcLineSize

        cinvoke printf, "    L1 data cache line size    : %d bytes %c", eax, 10

        mov eax, edi
        shr eax, 8
        and eax, 0x000000FF     ; L1DcLinesPerTag

        cinvoke printf, "    L1 data cache lines per tag: %d %c", eax, 10

        mov eax, edi
        shr eax, 16
        and eax, 0x000000FF     ; L1DcAssoc

        call AMDCacheTLBLevelOneFromTable

        mov eax, edi
        shr eax, 24
        and eax, 0x000000FF     ; L1DcSize

        cinvoke printf, "    L1 data cache size               : %d KB %c", eax, 10

        mov eax, 0x80000005     ; pass 4 (edx)
        cpuid

        mov edi, edx
        mov eax, edx

        and eax, 0x000000FF     ; L1IcLineSize
                
        cinvoke printf, "    L1 instruction cache line size   : %d bytes %c", eax, 10
                
        mov eax, edi
                
        shr eax, 8
        and eax, 0x000000FF     ; L1IcLinesPerTag
                
        cinvoke printf, "    L1 instruction cache line per tag: %d %c", eax, 10
                
        mov eax, edi
                
        shr eax, 16
        and eax, 0x000000FF     ; L1IcAssoc
                
        call AMDCacheTLBLevelOneFromTable
                
        mov eax, edi
                
        shr eax, 24
        and eax, 0x000000FF     ; L1IcSize

        cinvoke printf, "    L1 instruction cache size        : %d KB %c", eax, 10

.notsupported:

        ret
        

; expects cache tlb level in eax
; does not preserve eax, ebx, ecx, or edx
AMDCacheTLBLevelOneFromTable:

        cmp eax, 0
        je .reserved
                
        cmp eax, kOneWayAssociative
        je .oneway
                
        cmp eax, kFullyAssociative
        je .fully
                
        cinvoke printf, "    %d-way associative %c", eax, 10
                
        ret
                
.fully: cinvoke printf, "    Fully associative %c", 10

        ret
                
.oneway:

        cinvoke printf, "    1-way (direct mapped) %c", 10

        ret

.reserved:

        cinvoke printf, "    Reserved %c", 10

        ret
          
; =============================================================================================

; extended leaf 80000006h
; AMD implementation
AMDCacheTLBLevelThreeCache:

        mov eax, dword [__MaxExtended]

        cmp eax, 0x80000006
        jl .notsupported
                
        mov esi, dword __Leaf80__06
        call ShowLeafInformation
                
        cinvoke printf, "  L2 Cache and TLB and L3 Cache Information %c", 10

        mov eax, 0x80000006
        cpuid

        mov edi, eax
                
        and eax, 0x00000FFF     ; L2ITlb2and4MSize [11:0]

        cinvoke printf, "    L2 instruction TLB, entries for 2MB/4MB pages: %d %c", eax, 10
                
        mov eax, edi
                
        shr eax, 12
        and eax, 0x0000000F     ; L2ITlb2and4MAssoc [15:12]
                
        mov edx, __AMDLevelTwoTLB
        imul eax, __AMDLevelTwoTLBSize
        add edx, eax

        cinvoke printf, "    %s %c", edx, 10
                
        mov eax, edi
                
        shr eax, 16
        and eax, 0x00000FFF     ; L2DTlb2and4MSize [27:16]
                
        cinvoke printf, "    L2 data TLB, entries for 2MB/4MB pages: %d %c", eax, 10
                
        mov eax, edi
                
        shr eax, 28
        and eax, 0x0000000F     ; L2DTlb2and4MAssoc [31:28]
                
        mov esi, __AMDLevelTwoTLB
        imul eax, __AMDLevelTwoTLBSize
        add esi, eax
                
        cinvoke printf, "    %s %c", esi, 10
                
        mov eax, 0x80000006
        cpuid                   ; 2nd pass for data in ebx

        mov edi, ebx

        and ebx, 0x00000FFF     ; L2ITlb4KSize [1:0]

        cinvoke printf, "    L2 instruction TLB, entries for 2KB/4KB pages: %d %c", eax, 10

        mov eax, edi

        shr eax, 12
        and eax, 0x0000000F     ; L2ITlb4KAssoc [15:12]

        mov esi, __AMDLevelTwoTLB
        imul eax, __AMDLevelTwoTLBSize
        add esi, eax

        cinvoke printf, "    %s %c", esi, 10
                
        mov eax, edi
                
        shr eax, 16
        and eax, 0x00000FFF     ; L2DTlb4KSize [27:16]
                
        cinvoke printf, "    L2 data TLB, entries for 2KB/4KB pages: %d %c", eax, 10
                
        mov eax, edi
                
        shr eax, 28
        and eax, 0x0000000F     ; L2DTlb4KAssoc [31:28]
                
        mov esi, __AMDLevelTwoTLB
        imul eax, __AMDLevelTwoTLBSize
        add esi, eax
                
        cinvoke printf, "    %s %c", esi, 10
                
        mov eax, 0x80000006
        cpuid                   ; 3rd pass for data in ecx

        mov edi, ecx

        and ecx, 0x000000FF     ; L2LineSize [7:0]

        cinvoke printf, "    L2 cache line size    : %d bytes %c", ecx, 10

        mov ecx, edi

        shr ecx, 8
        and ecx, 0x0000000F     ; L2LinesPerTag [11:8]

        cinvoke printf, "    L2 cache lines per tag: %d %c", ecx, 10

        mov ecx, edi

        shr ecx, 12
        and ecx, 0x0000000F     ; L2Assoc [15:12]

        mov esi, __AMDLevelTwoTLB
        imul ecx, __AMDLevelTwoTLBSize
        add esi, ecx

        cinvoke printf, "    %s %c", esi, 10

        mov ecx, edi

        shr ecx, 16
        and ecx, 0x0000FFFF     ; L2Size [31:16]
                
        cinvoke printf, "    L2 cache size        g: %d KB %c", ecx, 10
                
        mov eax, 0x80000006
        cpuid                   ; 4th pass for data in edx

        mov edi, edx

        and edx, 0x0000000F     ; L3LineSize [7:0]

        cinvoke printf, "    L3 cache line size    : %d bytes %c", edx, 10

        mov edx, edi

        shr edx, 8
        and edx, 0x0000000F     ; L3LinesPerTag [11:8]

        cinvoke printf, "    L2 cache lines per tag: %d %c", edx, 10

        mov edx, edi

        shr edx, 12
        and edx, 0x0000000F     ; L3Assoc [15:12]

        mov esi, __AMDLevelTwoTLB
        imul edx, __AMDLevelTwoTLBSize
        add esi, edx

        cinvoke printf, "    %s %c", esi, 10

        mov esi, edi

        shr edi, 18
        and edi, 0x00003FFF     ; L3Size [31:18]

        imul edi, 512

        inc esi
        imul esi, 512

        cinvoke printf, "    L3 cache size range %d KB -> %d KB %c", edi, esi, 10

.notsupported:

.fin:   ret

; =============================================================================================

; extended lead 80000007h, data in ebx, ecx, and edx
; AMD implementation
PPMandRAS:

        mov eax, dword [__MaxExtended]

        cmp eax, 0x80000007
        jl .notsupported

        mov esi, dword __Leaf80__07
        call ShowLeafInformation

        cinvoke printf, "  Processor Power Management and RAS Capabilities %c", 10

        mov eax, 0x80000007
        cpuid
                
        mov edi, ecx
        mov esi, edx
                
        bt ebx, kMcaOverflowRecov
        jnc .bit1

        push ebx
        cinvoke printf, "    MCA overflow recovery support %c", 10
        pop ebx

.bit1:  bt ebx, kSUCCOR
        jnc .bit2

        push ebx
        cinvoke printf, "    Software uncorrectable error containment and recovery capability %c", 10
        pop ebx

.bit2:  bt ebx, kHWA
        jnc .bit3

        push ebx
        cinvoke printf, "    Hardware assert support (MSRC001_10) %c", 10
        pop ebx

.bit3:  bt ebx, kScalableMca
        jnc .ecx

        push ebx
        cinvoke printf, "    Support for MCAX MSRs %c", 10
        pop ebx

.ecx:   cmp ecx, 0
        je .apmf

        cinvoke printf, "    Compute unit power acc sample period to TSC counter ratio %d %c", ecx, 10

        mov edx, esi

.apmf:  mov esi, 0
        mov edi, dword __AMDAPMFeatures
                        
        mov esi, 0

.dx:    bt  edx, esi
        jnc .nxtd

        push edx
        cinvoke printf, "    %02d::%s %c", esi, edi, 10
        pop edx

.nxtd:  add edi, __AMDAPMFeaturesSize

        inc esi

        cmp esi, 12             ; bits to text

        jne .dx

.notsupported:

        ret

; =============================================================================================

; extended leaf 80000008h, data in eax, ebx, ecx, and edx
; AMD implementation
ProcessorCapacityParameters:

        mov eax, dword [__MaxExtended]

        cmp eax, 0x80000008
        jl .notsupported
                
        mov esi, dword __Leaf80__08
        call ShowLeafInformation
                                
        cinvoke printf, "    %c", 10

        mov eax, 0x80000008
        cpuid
                
        mov edi, eax
        mov esi, ebx
                
        and eax, 0x000000FF
                
        cinvoke printf, "    Physical Address Bits              : %d %c", eax, 10
                
        mov eax, edi
        shr eax, 8
        and eax, 0x000000FF
                
        cinvoke printf, "    Maximum Linear Address size        : %d bits %c", eax, 10
                
        mov eax, edi
        shr eax, 16
        and eax, 0x000000FF
                
        cinvoke printf, "    Maximum Guest Physical Address size: %d bits %c", eax, 10

.ebx:   mov ebx, esi

        mov esi, 0
        mov edi, dword __AMDExtendedFeatureID
                        
        mov esi, 0

.dx:    bt  ebx, esi
        jnc .nxtd

        push ebx
        cinvoke printf, "    %02d::%s %c", esi, edi, 10
        pop ebx

.nxtd:  add edi, __AMDExtendedFeatureIDSize

        inc esi

        cmp esi, 32             ; bits to text

        jne .dx

.ec:    mov eax, 0x80000008
        cpuid

        mov edi, ecx

        mov esi, __AMDSizeIndentifiersDescription

        shr ecx, 16
        and ecx, 0x03           ; PerfTscSize
                
        imul ecx, __AMDSizeIndentifiersDescriptionSize

        add esi, ecx

        cinvoke printf, "    Size of performance time-standard counter: %s %c", esi, 10

        mov eax, edi
        and eax, 0x000000FF     ; NC - 1

        add eax, 1

        cinvoke printf, "    Number of physical threads: %d %c", eax, 10

.ed:    mov eax, 0x80000008
        cpuid

        mov edi, edx

        and edx, 0x0000FFFF     ; InvlpgbCountMax

        cinvoke printf, "    Maximum page count for INVLPGB: %d %c", edx, 10

        shr edi, 16
        and edi, 0x0000FFFF     ; MaxRdpruID

        cinvoke printf, "    The maximum ECX value recognized by RDPRU: %d %c", edi, 10

.notsupported:

        ret

; =============================================================================================

; leaf 8000000Ah
; AMD only, data in eax, ebx, and edx
AMDSVM: 

        mov eax, dword [__MaxExtended]

        cmp eax, 0x8000000A
        jl .fin

        mov esi, dword __Leaf80__0A
        call ShowLeafInformation

        cinvoke printf, "  AMD Secure Virtual Machine Architecture (SVM) %c", 10
                
        mov eax, 0x8000000A
        cpuid
                
        mov edi, ebx
        mov esi, edx
                
        and eax, 0x000000FF
                
        cinvoke printf, "    SVM Revision : %d %c", eax, 10
                
        cinvoke printf, "    ASIDs        : %d %c", edi, 10
                
        mov eax, esi
                
        mov esi, 0              ; bit counter
        mov edi, __SVMFeatureInformation

.loop:  bt  eax, esi
        jnc .next

        push eax
        cinvoke printf, "    %02d::%s %c", esi, edi, 10
        pop eax

.next:  add edi, __SVMFeatureInformationSize

        inc esi

        cmp esi, 32             ; number of bits to test

        jne .loop

.fin:   ret

; =============================================================================================

; extended leaf 800000019h, data in eax and ebx
; AMD only
AMDTLBCharacteristics:

        mov eax, dword [__MaxExtended]

        cmp eax, 0x80000019
        jl .notsupported

        mov esi, dword __Leaf80__19
        call ShowLeafInformation

        cinvoke printf, "  TLB Characteristics for 1GB pages %c", 10

        mov eax, 0x80000019                
        cpuid

        mov edi, eax
        mov esi, ebx

        and eax, 0x00000FFF

        cinvoke printf, "    L1 instruction TLB entries for 1GB pages: %d %c", eax, 10

        mov eax, edi
                
        shr eax, 12
        and eax, 0x0000000F
                
        imul eax, __AMDLevelTwoTLBSize                
        mov ebx, __AMDLevelTwoTLB

        add ebx, eax

        cinvoke printf, "    %s %c", ebx, 10

        mov eax, edi
                
        shr  eax, 16
        and eax, 0x00000FFF

        cinvoke printf, "    L1 data TLB entries for 1GB pages: %d %c", eax, 10

        mov eax, edi

        shr eax, 28
        and eax, 0x0000000F

        imul eax, __AMDLevelTwoTLBSize                
        mov ebx, __AMDLevelTwoTLB

        add ebx, eax

        cinvoke printf, "    %s %c", ebx, 10
                
; data from ebx
                
        mov eax, esi
                
        and eax, 0x00000FFF

        cinvoke printf, "    L2 instruction TLB entries for 1GB pages: %d %c", eax, 10
                
        mov eax, esi
                
        shr eax, 12
        and eax, 0x0000000F
                
        imul eax, __AMDLevelTwoTLBSize                
        mov ebx, __AMDLevelTwoTLB
                
        add ebx, eax

        cinvoke printf, "    %s %c", ebx, 10
                
        mov eax, esi
                
        shr eax, 16
        and eax, 0x00000FFF
                
        cinvoke printf, "    L2 data TLB entries for 1GB pages: %d %c", eax, 10

        mov eax, esi
                
        shr eax, 28
        and eax, 0x0000000F
                
        imul eax, __AMDLevelTwoTLBSize                
        mov ebx, __AMDLevelTwoTLB
                
        add ebx, eax

        cinvoke printf, "    %s %c", ebx, 10            

.notsupported:

.fin:   ret

; =============================================================================================

; extended leaf 8000001Ah, data in eax
; AMD only
AMDPerformanceOptimisation:

        mov eax, dword [__MaxExtended]

        cmp eax, 0x8000001A
        jl .notsupported
                
        mov esi, dword __Leaf80__1A
        call ShowLeafInformation
                                
        cinvoke printf, "  Performance Optimization %c", 10

        mov eax, 0x8000001A
        cpuid
                
        mov edi, eax
                
        bt edi, kFP128
        jnc .bit1
                
        cinvoke printf, "    FP128. The internal FP/SIMD execution data path is 128 bits wide %c", 10

.bit1:  bt edi, kMOVU
        jnc .bit2

        cinvoke printf, "    MOVU.  MOVU SSE instructions are more efficient and should be preferred to SSE %c", 10
        cinvoke printf, "           MOVL/MOVH. MOVUPS is more efficient than MOVLPS/MOVHPS. %c", 10
        cinvoke printf, "           MOVUPD is more efficient than MOVLPD/MOVHPD. %c", 10

.bit2:  bt edi, kFP256
        jnc .fin

        cinvoke printf, "    FP256. The internal FP/SIMD execution data path is 256 bits wide %c", 10

.notsupported:

.fin:   ret

; =============================================================================================

; extended leaf 80000001Bh, data in eax
; AMD only
AMDIBS: mov eax, dword [__MaxExtended]

        cmp eax, 0x8000001B
        jl .fin

        mov esi, dword __Leaf80__1B
        call ShowLeafInformation

        cinvoke printf, "  AMD Instruction-Based Sampling (IBS) %c", 10

        mov eax, 0x8000001B
        cpuid

        mov esi, 0              ; bit counter
        mov edi, __IBSFeatures

.loop:  bt  eax, esi
        jnc .next

        push eax
        cinvoke printf, "    %02d::%s %c", esi, edi, 10
        pop eax

.next:  add edi, __IBSFeaturesSize

        inc esi

        cmp esi, 12             ; number of bits to test

        jne .loop

.fin:   ret
            

; =============================================================================================

; leaf 8000001ch, data in eax, ebx, and ecx
; amd only
AMDLightweightProfiling:

        mov eax, 0x80000001
        cpuid

        bt ecx, kLWP
        jc .cont

        ret

.cont:  mov esi, dword __Leaf80__1C
        call ShowLeafInformation

        cinvoke printf, "  Lightweight Profiling Capabilities %c", 10

        mov eax, 0x8000001C
        cpuid                   ; pass 1 for eax

        mov edi, dword __AMDLWPEAX
  
        push eax
        cinvoke printf, "    Lightweight Profiling Capabilities 0 (EAX:0x%x) %c", eax, 10
        pop eax

showa:  mov esi, 0              ; bit counter

.lfa:   bt  eax, esi
        jnc .nexta

        push eax
        cinvoke printf, "    %02d::%s %c", esi, edi, 10
        pop eax

.nexta: add edi, __AMDLWPEAXSize

        inc esi

        cmp esi, 32

        jne .lfa
                
        mov eax, 0x8000001C
        cpuid                   ; pass 2 for ecx
                
        mov edi, ebx
                
        cinvoke printf, "    Lightweight Profiling Capabilities 0 (EBX:0x%x) %c", edi, 10
                
        mov eax, edi
        and eax, 0x000000FF
                
        cinvoke printf, "    LwpCbSize, Control block size (quadwords) of the LWPCB                    : %d %c", eax, 10
                
        mov eax, edi
        shr eax, 8
        and eax, 0x000000FF
                
        cinvoke printf, "    LwpEventSize, Event record size (bytes) event record LWP event ring buffer: %d %c", eax, 10
                
        mov eax, edi
        shr eax, 16
        and eax, 0x000000FF
                
        cinvoke printf, "    LwpMaxEvents, Maximum EventId value supported                             : %d %c", eax, 10
                
        mov eax, edi
        shr eax, 24
        and eax, 0x000000FF
                
        cinvoke printf, "    LwpEventOffset, Offset (bytes) from the start of LWPCB to EventInterval1 : %d %c", eax, 10

        mov eax, 0x8000001C
        cpuid                   ; pass 3 for ecx
                
        mov edi, ecx
                
        cinvoke printf, "    Lightweight Profiling Capabilities 0 (ECX:0x%x) %c", edi, 10

        mov eax, edi
        and eax, 0x0000001F
        
        cinvoke printf, "    LwpLatencyMax, Latency counter size (bits) of the cache latency counters: %d %c", eax, 10
        
        bt edi, kLwpDataAddress
        jnc .LRnd

        cinvoke printf, "    LwpDataAddress, Data cache miss address valid. Address is valid for cache miss event records %c", 10
                
.LRnd:  mov eax, edi 
        shr eax, 6
        and eax, 0x00000007
                
        cinvoke printf, "    LwpLatencyRnd, Amount by which cache latency is rounded: %d %c", eax, 10
                
        mov eax, edi
        shr eax, 9
        and eax, 0x0000007F
                
        cinvoke printf, "    LwpVersion, Version of LWP implementation: %d %c", eax, 10

        mov eax, edi
        shr eax, 16
        and eax, 0x000000FF

        cinvoke printf, "    LwpMinBufferSize, Minimum size of the LWP event ring buffer, in units of 32 event records: %d %c", eax, 10
                
        bt edi, kLwpBranchPrediction
        jnc .LpF
                
        cinvoke printf, "    Branch prediction filtering supported. Branches Retired events can be filtered based on whether the branch was predicted properly. %c", 10
                
.LpF:   bt edi, kLwpIpFiltering
        jnc .Lvls
                
        cinvoke printf, "    IP filtering supported. %c", 10
                
.Lvls:  bt edi, kLwpCacheLevels
        jnc .Lncy
                
        cinvoke printf, "    Cache level filtering supported. Cache-related events can be filtered by the cache level that returned the data. %c", 10
                
.Lncy:  bt edi, kLwpCacheLatency
        jnc .fin
                
        cinvoke printf, "    Cache latency filtering supported. Cache-related events can be filtered by latency. %c", 10

        mov eax, 0x8000001C
        cpuid                   ; pass 4 for edx

        mov edi, dword __AMDLWPEDX
  
        push edx
        cinvoke printf, "    Lightweight Profiling Capabilities 0 (EDX:0x%x) %c", edx, 10
        pop edx

        mov esi, 0              ; bit counter

.lfd:   bt  edx, esi
        jnc .nextd

        push edx
        cinvoke printf, "    %02d::%s %c", esi, edi, 10
        pop edx

.nextd: add edi, __AMDLWPEDXSize

        inc esi

        cmp esi, 32

        jne .lfd

.fin:   ret

; =============================================================================================

; leaf 8000001dh, data in eax, ebx, ecx, and edx
; AMD only, data in eax
AMDCache:

        mov eax, dword [__MaxExtended]

        cmp eax, 0x8000001D
        jl .fin
                
        mov esi, dword __Leaf80__1D
        call ShowLeafInformation

        cinvoke printf, "  Cache Properties %c", 10

        mov esi, 0              ; bit counter

.next:  mov ecx, esi
        mov eax, 0x8000001D
        cpuid

        mov edi, eax

        and edi, 0x0000001F

        cmp edi, 0
        je .fin

.ct1:   cmp edi, 1
        jne .ct2

        cinvoke printf, "    CacheType : Data Cache %c", 10

.ct2:   cmp edi, 2
        jne .ct3

        cinvoke printf, "    CacheType : Instruction Cache %c", 10

.ct3:   cmp edi, 3
        jne .cl1

        cinvoke printf, "    CacheType : Unified Cache %c", 10

        mov ecx, esi
        mov eax, 0x8000001D
        cpuid

        mov edi, eax

        shr edi, 5
        and edi, 0x00000007

.cl1:   cmp edi, 1
        jne .cl2

        cinvoke printf, "    CacheLevel: 1 %c", 10

.cl2:   cmp edi, 2
        jne .cl3

        cinvoke printf, "    CacheLevel: 2 %c", 10

.cl3:   cmp edi, 3
        jne .si

        cinvoke printf, "    CacheLevel: 3 %c", 10

        mov ecx, esi
        mov eax, 0x8000001D
        cpuid

        mov edi, eax

.si:    bt edi, kSelfInitialization
        jnc .nsi

        cinvoke printf, "    SelfInitialization. Self-initializing cache %c", 10

        jmp .fa

.nsi:   cinvoke printf, "    SelfInitialization. Hardware does not initialize this cache %c", 10

.fa:    bt edi, kFullyAssociative
        jnc .nfa

        cinvoke printf, "    FullyAssociative. Cache is fully associative %c", 10

        jmp .nextl

.nfa:   cinvoke printf, "    FullyAssociative. Cache is set associative %c", 10

.nextl: mov ecx, esi            ; first pass
        mov eax, 0x8000001D
        cpuid

        inc ecx

        cinvoke printf, "    CacheNumSets: %d %c", ecx, 10

.nsc:   shr edi, 14
        and edi, 0x00000FFF

        inc edi

        cinvoke printf, "    NumSharingCache: %d %c", edi, 10

        mov ecx, esi
        mov eax, 0x8000001D
        cpuid
                
        mov edi, ebx
                
        and ebx, 0x00000FFF
        inc ebx
                
        cinvoke printf, "    CacheLineSize      : %d %c", ebx, 10
                
        mov ebx, edi
                
        shr ebx, 12
        and ebx, 0x000003FF
        inc ebx

        cinvoke printf, "    CachePhysPartitions: %d %c", ebx, 10

        shr edi, 22
        and edi, 0x000003FF
        inc edi
                
        cinvoke printf, "    CacheNumWays       : %d %c", edi, 10

        mov ecx, esi            ; second pass
        mov eax, 0x8000001D
        cpuid
                
        cinvoke printf, "%c", 10

        mov edi, edx
        
        cinvoke printf, "    Write-Back Invalidate/Invalidate execution scope %c", 10
        
        bt edi, kWBINVD
        jnc .wni

        cinvoke printf, "      WBINVD/INVD instruction is not guaranteed to invalidate all lower level caches %c", 10

        jmp .ci

.wni:   cinvoke printf, "      WBINVD/INVD instruction invalidates all lower level caches of non-originating logical processors sharing this cache %c", 10

.ci:    bt edi, kCacheInclusive
        jnc .cni

        cinvoke printf, "    CacheInclusive. Cache is inclusive of lower cache levels %c", 10

        jmp .inc
                
.cni:   cinvoke printf, "    CacheInclusive. Cache is not inclusive of lower cache levels %c", 10

.inc:   inc esi

        jmp .next

.fin:   ret

; =============================================================================================

; leaf 8000001eh, data in eax, ebx, and ecx
; AMD only
AMDProcTopology:

        mov eax, dword [__MaxExtended]

        cmp eax, 0x8000001E
        jl .fin

        mov eax, 0x80000001                
        cpuid
                
        bt ecx, kTopologyExtensions
        jnc .fin
                
        mov esi, dword __Leaf80__1E
        call ShowLeafInformation
                                
        cinvoke printf, "  Processor Topology Information %c", 10

        mov eax, 0x8000001E
        cpuid
                
        mov edi, ebx
        mov esi, ecx
                
        cinvoke printf, "    Extended APIC ID 0x%x %c", eax, 10

        mov eax, edi
                
        and eax, 0x000000FF

        cinvoke printf, "    ComputeUnitId         0x%x %c", eax, 10
                
        mov eax, edi
        shr eax, 8
        and eax, 0x000000FF
                
        cinvoke printf, "    ThreadsPerComputeUnit 0x%x %c", eax, 10
                
        mov eax, esi
        and eax, 0x000000FF
                
        cinvoke printf, "    NodeId                0x%x %c", eax, 10
                
        mov eax, esi
        shr eax, 8
        and eax, 0x00000007
                
        cinvoke printf, "    NodesPerProcessor     %d %c", eax, 10

.fin:   ret

; =============================================================================================             

; leaf 8000001fh
; AMD only, data in eax
AMDEMS: mov eax, dword [__MaxExtended]

        cmp eax, 0x8000001F
        jl .fin

        mov esi, dword __Leaf80__1F
        call ShowLeafInformation

        cinvoke printf, "  Encrypted Memory Capabilities %c", 10

        mov eax, 0x8000001F
        cpuid

        mov esi, 0
        mov edi, __AMDSecureEncryption

.loop:  bt  eax, esi
        jnc .next

        push eax
        cinvoke printf, "    %02d::%s %c", esi, edi, 10
        pop eax

.next:  add edi, __AMDSecureEncryptionSize

        inc esi

        cmp esi, 32             ; number of bits to test

        jne .loop
                
        cinvoke printf, "%c", 10

        mov eax, 0x8000001F
        cpuid

        mov edi, ebx
        mov esi, ebx

        and edi, 0x1F

        cinvoke printf, "    C-bit location in page table              : %d %c", edi, 10

        mov edi, esi
        shr edi, 6
        and edi, 0x3F
 
        cinvoke printf, "    Physical Address Bit Reducion             : %d %c", edi, 10

        mov edi, esi
        shr edi, 12
        and edi, 0xF

        cinvoke printf, "    VM Permissions Levels                     : %d %c", edi, 10

        mov eax, 0x8000001F
        cpuid

        mov edi, ecx
        mov esi, edx

        cinvoke printf, "    Encrypted guests supported simultaneously : 0x%x %c", edi, 10

        cinvoke printf, "    Minimum ASID value for an SEV enabled     : 0x%x %c", esi, 10

.fin:   ret

; =============================================================================================            

; leaf 80000020h
; AMD only, data in eax, ebx, ecx, and edx 
AMDQOS: mov eax, dword [__MaxExtended]

        cmp eax, 0x80000020
        jl .fin

        mov esi, dword __Leaf80__20
        call ShowLeafInformation

        cinvoke printf, "  PQoS Extended Features %c", 10

        mov ecx, 0
        mov eax, 0x80000020
        cpuid

        mov [__AMDPQOS], ebx
                
        mov edi, __AMDPQOSExtendedFeatures

.showf: mov esi, 0              ; bit counter

.lf1:   bt  ebx, esi
        jnc .next

        push ebx
        cinvoke printf, "    %02d::%s %c", esi, edi, 10
        pop ebx

.next:  add edi, __AMDPQOSExtendedFeaturesSize

        inc esi

        cmp esi, 7

        jne lf1

.ecx1:  bt [__AMDPQOS], kL3MBE
        jnc .ecx2

        mov esi, dword __Leaf80__20_1
        call ShowLeafInformation

        cinvoke printf, "  L3 Memory Bandwidth Enforcement Information %c", 10

        mov ecx, 1
        mov eax, 0x80000020
        cpuid

        mov edi, edx
                
        cinvoke printf, "    Size of L3QOS_BW_Control_n: 0x%x %c", eax, 10

        cinvoke printf, "    Number of COS number supported by L3MBE: 0x%x %c", edi, 10

.ecx2:  bt [__AMDPQOS], kL3SMBE
        jnc .ecx3

        mov esi, dword __Leaf80__20_2
        call ShowLeafInformation

        cinvoke printf, "  L3 Slow Memory Bandwidth Enforcement Information %c", 10

        mov ecx, 2
        mov eax, 0x80000020
        cpuid

        mov edi, edx            ; COS_MAX

        cinvoke printf, "    Size of L3QOS_SLOWBW_Control_n: 0x%x %c", eax, 10

        cinvoke printf, "    Number of COS number supported by L3SMBE: 0x%x %c", edi, 10
                
.ecx3:  bt [__AMDPQOS], kBMEC
        jnc .ecx5

        mov esi, dword __Leaf80__20_3
        call ShowLeafInformation

        cinvoke printf, "  Bandwidth Monitoring Event Counters Information %c", 10
                
        mov ecx, 3
        mov eax, 0x80000020
        cpuid           
                
        mov edi, ecx
                
        and ebx, 0x000000FF     ; EVT_NUM
                
        cinvoke printf, "    Number of configurable bandwidth events: 0x%x %c", ebx, 10
                
        mov ebx, edi
                
        mov edi, __AMDPQOSExtendedFeaturesBMEC

.show3: mov esi, 0              ; bit counter

.l203:  bt  ebx, esi
        jnc .next3

        push ebx
        cinvoke printf, "    %02d::%s %c", esi, edi, 10
        pop ebx

.next3: add edi, __AMDPQOSExtendedFeaturesBMECSize

        inc esi

        cmp esi, 7

        jne .l203

.ecx5:  bt [__AMDPQOS], kABMC   ; ABMC
        jnc .fin
                
        mov esi, dword __Leaf80__20_5
        call ShowLeafInformation

        cinvoke printf, "  Assignable Bandwidth Monitoring Counters Information %c", 10

        mov ecx, 5
        mov eax, 0x80000020
        cpuid
                
        mov edi, eax

        bt eax, kOverflowBit    ; OverflowBit
        jnc .cs
                
        cinvoke printf, "    QM_CTR bit 61 is an overflow bit %c", 10

.cs:    mov eax, edi

        and eax, 0x000000FF
        add eax, 24             ; CounterSize, offset from 24 bits

        cinvoke printf, "    QM_CTR counter width: %d %c", eax, 10

        mov ecx, 5
        mov eax, 0x80000020
        cpuid
                
        mov edi, ecx            ; MAX_ABMC

        and ebx, 0x0000FFFF

        cinvoke printf, "    Maximum supported ABMC counter ID: %d %c", ebx, 10
                
        bt edi, kSelect_COS     ; Select_COS
                
        cinvoke printf, "    Bandwidth counters can be configured to measure bandwidth consumed by a COS instead of an RMID %c", 10

.fin:   ret

; =============================================================================================

; leaf 80000021h
; AMD only, data in eax and ebx
AMDEFI2: 

        mov eax, dword [__MaxExtended]

        cmp eax, 0x80000021
        jl .fin
                
        mov esi, dword __Leaf80__21
        call ShowLeafInformation

        mov eax, 0x80000021
        cpuid

        push eax
        cinvoke printf, "  Extended Feature Identification 2 (EAX:0x%x) %c", eax, 10
        pop eax

        mov esi, 0              ; bit counter
        mov edi, __AMDExtendedFeatureIdentifiers2

.loop:  bt  eax, esi
        jnc .next

        push eax
        cinvoke printf, "    %02d::%s %c", esi, edi, 10
        pop eax

.next:  add edi, __AMDExtendedFeatureIdentifiers2Size

        inc esi

        cmp esi, 18             ; number of bits to test

        jne .loop

.fin:   ret

; =============================================================================================

; leaf 80000022h
; AMD only, data in eax and ebx
AMDExtPMandD:

        mov eax, dword [__MaxExtended]

        cmp eax, 0x80000022
        jl .fin

        mov esi, dword __Leaf80__22
        call ShowLeafInformation

        mov eax, 0x80000022                
        cpuid

        cinvoke printf, "  Extended Performance Monitoring and Debug (EAX:0x%x EBX:0x%x) %c", eax, ebx, 10
                
        mov eax, 0x80000022                
        cpuid

        mov edi, eax
        mov esi, ebx

.a00:   bt edi, kPerfMonV2
        jnc .a01

        cinvoke printf, "    Performance Monitoring Version 2 supported %c", 10

.a01:   bt edi, kLbrStack 
        jnc .a02

        cinvoke printf, "    Last Branch Record Stack supported %c", 10

.a02:   bt edi, kLbrAndPmcFreeze
        jnc .num

        cinvoke printf, "    Freezing Core Performance Counters and %c", 10
        cinvoke printf, "      LBR Stack on Core Performance Counter overflow supported %c", 10

.num:   mov edi, esi
        and edi, 0x0000000F     ; NumPerfCtrCore

        cinvoke printf, "    Core Performance Counters        : %d %c", edi, 10

        mov edi, esi
        shr edi, 4
        and edi, 0x0000003F     ; LbrStackSize

        cinvoke printf, "    Last Branch Record Stack Entries : %d %c", edi, 10

        shr esi, 10
        and esi, 0x0000003F     ; NumPerfCtrNB

        cinvoke printf, "    Northbridge Perf Monitor Counters: %d %c", esi, 10

.fin:   ret
                
; =============================================================================================

; leaf 80000023h
; AMD only, data in eax and ebx
AMDMultiKeyEMC:

        mov eax, dword [__MaxExtended]

        cmp eax, 0x80000023
        jl .fin

        mov esi, dword __Leaf80__23
        call ShowLeafInformation

        mov eax, 0x80000023
        cpuid

        cinvoke printf, "  Extended Performance Monitoring and Debug (EAX:0x%x EBX:0x%x) %c", eax, ebx, 10
                
        mov eax, 0x80000023
        cpuid

        mov edi, eax
        mov esi, ebx

        bt edi, kMemHmk
        jnc .b15

        cinvoke printf, "    Secure Host Multi-Key Memory (MEM-HMK) Encryption Mode Supported %c", 10

.b15:   and esi, 0x0000FFFF     ; MaxMemHmkEncrKeyID

        cinvoke printf, "    Simultaneously available host encryption key IDs in MEM-HMK encryption mode: %d %c", esi, 10

.fin:   ret

; =============================================================================================

; leaf 80000026h
; AMD only, data in eax and ebx
AMDExtendedCPUTop:

        mov eax, dword [__MaxExtended]

        cmp eax, 0x80000026
        jl .fin
                
        mov esi, dword __Leaf80__26
        call ShowLeafInformation

        cinvoke printf, "  Extended CPU Topology %c", 10

        mov esi, 0              ; bit counter

.next:  mov ecx, esi
        mov eax, 0x80000026                
        cpuid

        mov edi, ecx

        shr ecx, 8
        and ecx, 0x0000FFFF
        cmp ecx, 0

        je .fin

        mov edx, __AMDLevelType

        shr edi, 8
        and edi, 0x000000FF

        cmp edi, 4              ; only four types are specified in the 2022 docs
        jg .areg

        dec edi

        lea edi, [edx + edi*8]
                
        push eax
        cinvoke printf, "    LevelType: %s %c", edi, 10
        pop eax

.areg:  mov edi, eax

.a29:   bt edi, kEfficiencyRankingAvailable
        jnc .a30

        cinvoke printf, "    Processor power efficiency ranking (PwrEfficiencyRanking) is %c", 10
        cinvoke printf, "        available and varies between cores %c", 10

.a30:   bt edi, kHeterogeneousCores
        jnc .a31

        cinvoke printf, "    All components at the current hierarchy level do not consist of %c", 10
        cinvoke printf, "        the cores that report the same core type (CoreType) %c", 10

.a31:   bt edi, kAsymmetricTopology
        jnc .breg

        cinvoke printf, "    All components at the current hierarchy level do not report the same %c", 10
        cinvoke printf, "        number of logical processors (NumLogProc) %c", 10

.breg:  mov ecx, esi
        mov eax, 0x80000026                
        cpuid

        mov edi, ebx

        and ebx, 0x0000FFFF

        cinvoke printf, "    NumLogProc: %d %c", ebx, 10

        mov ebx,  edi
        shr ebx, 16
        and ebx, 0x000000FF

        cinvoke printf, "    PwrEfficiencyRanking: %d %c", ebx, 10

        mov ebx,  edi
        shr ebx, 24
        and ebx, 0x0000000F

        cinvoke printf, "    NativeModelID: %d %c", ebx, 10

        mov ebx, edi
        shr ebx, 28
        and ebx, 0x0000000F

        cinvoke printf, "    CoreType     : %d %c", ebx, 10             

        inc esi

        jmp .next

.fin:   ret

; =============================================================================================
; =============================================================================================