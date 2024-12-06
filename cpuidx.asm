; ===================================================================================
; ===================================================================================
;
;  (c) Paul Alan Freshney 2023-2024
;  v0.16, December 6th 2024
;
;  Source code:
;      https://github.com/MaximumOctopus/CPUIDx
;
;  Assembled using "Flat Assembler"
;      https://flatassembler.net/
;
;  Resources used:
;      AMD64 Architecture Programmer’s Manual Volume 3: General-Purpose and System Instructions
;          October   2022
;          June      2023
;          March     2024
;      Intel® 64 and IA-32 Architectures Software Developer's Manual Volume 2
;          December  2022
;          March     2023
;          September 2023
;          December  2023
;          March     2024
;          June      2024
;          October   2024
;
; ===================================================================================
; ===================================================================================

format PE console
include 'WIN32AX.INC'
include 'cpuidx.inc'

; ===================================================================================
section '.code' code readable executable
; ===================================================================================

start:  call Arguments
        call About

        xor eax, eax        
        cpuid

        mov [__MaxBasic], eax
        mov dword [__VendorID], ebx
        mov dword [__VendorID + 4], edx
        mov dword [__VendorID + 8], ecx

        cinvoke printf, "  Vendor ID: %s %c", __VendorID, 10

        mov eax, 0x80000000                
        cpuid
                
        mov [__MaxExtended], eax

        cmp eax, 0x80000004

        jl .01h

        call BrandString                        ; 0x80000002/3/4

.01h:   call FamilyModel
                
        call CoreCount

        call ShowFamilyModel

        call ShowFeatures1
                
        call ShowFeatures2

        cmp dword [__VendorID + 8], 0x6c65746e
        jne .AMDoptions
                
; =============================================================================================
; =============================================================================================
; == Intel ====================================================================================
; =============================================================================================
; =============================================================================================                         
                                
        cinvoke printf, "%c      == Intel-specific ======================== %c %c", 10, 10, 10

        call ProcessorSerialNumber              ; 03h

        call MonitorMWait                       ; 05h

        call ThermalPower                       ; 06h

        call StructuredExtendedFeatureFlags     ; 07h

        call DirectCacheAccessInfo              ; 09h

        call ArchitecturalPerfMon               ; 0ah
                
        call ExtendedTopology                   ; 0bh

        call ProcExtStateEnumMain               ; 0dh, ecx = 0

        call ProcExtStateEnumSub1               ; 0dh, ecx = 1          

        call InternalCache                      ; 02h

        call CacheTlb                           ; 04h

        call IntelRDTMonitoring                 ; 0fh

        call IntelRDTAllocEnum                  ; 10h

        call IntelSGXCapability                 ; 12h

        call IntelProcessorTrace                ; 14h

        call TimeStampCounter                   ; 15h

        call ProcessorFreqInfo                  ; 16h

        call SoCVendor                          ; 17h

        call DATParameters                      ; 18h

        call KeyLocker                          ; 19h

        call NativeModelIDEnumeration           ; 1ah
                
        call GetPCONFIG                         ; 1bh

        call LastBranchRecords                  ; 1ch

        call TileInformation                    ; 1dh

        call TMULInformation                    ; 1eh
                
        call V2ExtendedTopology                 ; 1fh
                
        call ProcessorHistoryReset              ; 20h
                
        call APMEMain                           ; 23h
                
        call ConvergedVectorISAMain             ; 24h

; =============================================================================================
                
        mov [__MaxExtended], eax
        cmp eax, 0x80000000

        jl .finish
                
        cinvoke printf, "%c      == Extended Leafs ======================== %c %c", 10, 10, 10

        call ExtendedFeatures                   ; 0x80000001
                
        call IntelCacheInformation              ; 0x80000006

        call InvariantTSC                       ; 0x80000007

        call AddressBits                        ; 0x80000008

        jmp .finish

; =============================================================================================
; =============================================================================================
; == AMD ======================================================================================
; =============================================================================================
; =============================================================================================

.AMDoptions:

        cmp dword [__VendorID + 8], 0x444d4163
        jne .finish

        cinvoke printf, "%c      == AMD-specific ========================== %c %c", 10, 10, 10
                
        call AMDMonitorMWait                    ; 05h

        call PowerManagementRelated             ; 06h
                
        call AMDStructuredExtendedFeatureIDs    ; 07h

        call AMDProcExtTopologyEnum             ; 0bh

        call AMDProcExtStateEnum                ; 0dh
                
        call AMDPQOSMonitoring                  ; 0fh
                
        call AMDPQECapabilities                 ; 10h
                
; =============================================================================================
                
        mov [__MaxExtended], eax
        cmp eax, 0x80000000

        jl .finish              
                
        cinvoke printf, "%c      == Extended Leafs ======================== %c %c", 10, 10, 10

        call ExtendedFeatures                   ; 0x80000001

        call AMDCacheTLBLevelOne                ; 0x80000005

        call AMDCacheTLBLevelThreeCache         ; 0x80000006

        call PPMandRAS                          ; 0x80000007

        call ProcessorCapacityParameters        ; 0x80000008

        call AMDSVM                             ; 0x8000000A

        call AMDTLBCharacteristics              ; 0x80000019

        call AMDPerformanceOptimisation         ; 0x8000001A

        call AMDIBS                             ; 0x8000001B

        call AMDLightweightProfiling            ; 0x8000001C

        call AMDCache                           ; 0x8000001D

        call AMDEMS                             ; 0x8000001F

        call AMDQOS                             ; 0x80000020

        call AMDEFI2                            ; 0x80000021

        call AMDExtPMandD                       ; 0x80000022

        call AMDMultiKeyEMC                     ; 0x80000023

        call AMDExtendedCPUTop                  ; 0x80000026

.finish:

        cinvoke printf, "%c %c -- End of Report %c", 10, 10, 10

        xor eax, eax
        ret

; =============================================================================================
; =============================================================================================

About:  cinvoke printf, "%c    CPUidx v0.16 :: December 6th 2024 :: Paul A Freshney %c", 10, 10

        cinvoke printf, "       https://github.com/MaximumOctopus/CPUIDx %c %c", 10, 10

        ret

; =============================================================================================

; this only checks to see if there *is* an argument, that's enough to enable extended output mode
; if I need more arguments in future then this will do actual argument matching...
Arguments:

        cinvoke __getmainargs, __argc, __argv, __env, 0, NULL

        mov eax, [__argc]

        cmp eax, 0x01                   ; value in eax (argument count) is 1 if no command-line parameters
        jle .finish                     ; if <=1 then exit (should never be zero. probably)
                
        mov [__ShowDetail], 1           ; set flag

.finish:

        ret

; =============================================================================================

; only outputs if the user has set the "show extra detail" flag from the command line
; requires string pointer in esi
; does not preserve eax, ebx, ecx, or edx
ShowLeafInformation:

        mov al, [__ShowDetail]
        cmp al, 1
        jne .finish

        cinvoke printf, "%s %c", esi, 10
                
.finish:

        ret

; =============================================================================================
; =============================================================================================

FamilyModel:

        mov eax, 1                
        cpuid

        mov [__BrandIndex], al
        mov [__System], ebx
        mov [__Features1], ecx
        mov [__Features2], edx
                
        mov bl, al
        and bl, 0x0F
        mov [__SteppingID], bl
                
        mov bl, al
        shr bl, 4
        mov [__Model], bl
                
        mov bl, ah
        and bl, 0x0F
        mov [__Family], bl
                
        mov ebx, eax
        shr ebx, 16
        and bl, 0x0F
        mov [__ModelExt], bl
                
        mov ebx, eax
        shr ebx, 20
        mov [__FamilyExt], bl
                
        ret

; =============================================================================================

ShowFamilyModel:

        mov eax, dword [__MaxBasic]
        mov ebx, dword [__MaxExtended]

        cinvoke printf, "    Max Leaf %xh, Max Extended Leaf %xh %c", eax, ebx, 10

        movzx edi, byte [__Family]

        cmp edi, 0x0F

        jne .model

        movzx eax, byte [__FamilyExt]

        add edi, eax

.model: movzx esi, byte [__Family]

        cmp esi, 0x0F
        je .yesex

        cmp esi, 0x06
        jne .notex

.yesex: movzx esi, [__ModelExt]
        shl esi, 4

        movzx eax, byte [__Model]
        add esi, eax

        jmp .show

.notex: movzx esi, byte [__Model]

.show:  movzx edx, byte [__SteppingID]

        cinvoke printf, "    Family 0x%x, Model 0x%x, Stepping 0x%x %c", edi, esi, edx, 10

        ret

; =============================================================================================

ShowFeatures1:

        mov esi, dword __Leaf01ECX
        call ShowLeafInformation

        mov eax, [__Features1]
        mov edi, dword __FeatureString1

        push eax        
        cinvoke printf, "  CPU Features #1 (0x%x) %c", eax, 10
        pop eax
                
        jmp showf
                
ShowFeatures2:

        mov esi, dword __Leaf01EDX
        call ShowLeafInformation

        mov eax, [__Features2]
        mov edi, dword __FeatureString2
                
        push eax
        cinvoke printf, "  CPU Features #2 (0x%x) %c", eax, 10
        pop eax
                
showf:  mov esi, 0

lf1:    bt  eax, esi
        jnc .next

        push eax
        cinvoke printf, "    %02d::%s %c", esi, edi, 10
        pop eax

.next:  add edi, __FeatureStringSize

        inc esi

        cmp esi, 32

        jne lf1

        ret

; =============================================================================================

CoreCount:

        cmp dword [__VendorID + 8], 0x6c65746e
        jne .amd

.intel: mov eax, [__Features2]

        bt eax, kHTT
        jnc .singlecore

        invoke GetActiveProcessorCount, 0xffff  ; all processor groups

        cinvoke printf, "    Logical processors %d %c", eax, 10

        ret

.singlecore:

        cinvoke printf, "    Single core CPU %c", 10

        ret

.amd:

        ret

; =============================================================================================

; leaf 04, data returned in eax, ebx, and ecx
; Intel only, not supported by AMD
CacheTlb:

        cmp dword [__VendorID + 8], 0x6c65746e
        jne .finish
                
        mov esi, dword __Leaf0400
        call ShowLeafInformation

        mov ecx, 0x00
        mov eax, 0x04
        cpuid

        cinvoke printf, "  Cache List (EAX:0x%x EBX:0x%x ECX:0x%x EDX:0x%x) %c", eax, ebx, ecx, edx, 10

        mov ecx, 0x00
        mov edi, 0x00
.list:  mov eax, 0x04
        cpuid

        cmp eax, 0              ; indicates no more caches to display
        jz .finish

        call ShowCache

        inc edi                 ; next cache
        mov ecx, edi

        jmp .list

.finish:

        ret

; =============================================================================================

; from volume 2A of the cpuid docs
; eax contains cache level and type
; ebx contains cache size parameters
; ecx contains number of sets
; doesn't trash edi
ShowCache:

        push edx

        mov esi, eax

        shr esi, 5              ; extract level from bits 5:7 (cache level)
        and esi, 0x07

        mov edx, ebx

        and edx, 0xFFF          ; extract System Coherency Line Size
        inc edx                 ; all values in ebx are value-1

        mov eax, edx            ; keep a copy of System Coherency Line Size

        inc ecx                 ; ecx value is value-1

        imul edx, ecx           ; edx will be updated with cache size

        mov ecx, ebx

        shr ecx, 12             ; extract Physical Line partitions
        and ecx, 0x3FF

        inc ecx                 ; all values from ecx are value-1

        imul edx, ecx

        mov ecx, ebx

        shr ecx, 22             ; extract Ways of Associativity
        and ecx, 0x1FF

        inc ecx                 ; all values from ecx are value-1

        imul edx, ecx

        shr edx, 10             ; convert bytes to kilobytes (divide by 1024)

        cinvoke printf, "    Level %d, %d KB (%d-way set associative, %d-byte line size) %c", esi, edx, ecx, eax, 10
                
        pop edx
                
        mov esi, edx

        bt esi, kWBINVD
        jnc .d00
                
.d01:   cinvoke printf, "      WBINVD/INVD is not guaranteed to act upon lower level caches of non-originating threads sharing this cache %c", 10

        jnc .dbit1
                
.d00:   cinvoke printf, "      WBINVD/INVD from threads sharing this cache acts upon lower level caches for threads sharing this cache %c", 10
                
.dbit1: bt esi, kCacheInclusiveLowerLevels
        jnc .d10
                
.d11:   cinvoke printf, "      Cache is inclusive of lower cache levels %c", 10

        jnc .dbit2
                
.d10:   cinvoke printf, "      Cache is not inclusive of lower cache levels %c", 10
                
.dbit2: bt esi, kComplexFunctionIndexCache
        jnc .d20
                
.d21:   cinvoke printf, "      A complex function is used to index the cache, potentially using all address bits %c", 10

        jnc .next
                
.d20:   cinvoke printf, "      Direct mapped cache %c", 10 
                
.next:  ret
                
; =============================================================================================

; leaf 02h, returns data (as bytes, max of 4 per register) in eax, ebc, ecx, and edx
; Intel only, not supported by AMD
InternalCache:

        cmp dword [__VendorID + 8], 0x6c65746e
        jne .fin

        mov esi, __Leaf02
        call ShowLeafInformation

        mov eax, 0x02
        cpuid

        cinvoke printf, "  TLB/Cache/Prefetch Information (EAX:0x%x EBX:0x%x ECX:0x%x EDX:0x%x) %c", eax, ebx, ecx, edx, 10

        mov eax, 0x02
        cpuid
                
        mov al, 0xFF            ; mask out eax's 0x01 after 04h leaf (simplifies code)
                
        mov edi, 0
.start: mov esi, 0
                
        bt eax, 31              ; 1 in the most-significant bit signifies valid 1-byte values in the register
        jc .nextregister
        
.nextbyte:

        ;push eax
        ;push ebx
        ;push ecx
        ;push edx
        ;cinvoke printf, "  0x%x 0x%x 0x%x 0x%x %d %c", eax, ebx, ecx, edx, edi, 10
        ;pop edx
        ;pop ecx
        ;pop ebx
        ;pop eax

        cmp al, 0x00
        je .cont

        push esi

        push edi
        call GetStringAddress
        pop edi
                
        cmp esi, 0x00
        je .contp
                
        push eax
        push ebx
        push ecx
        push edx
        cinvoke printf, "    %s %c", esi, 10
        pop edx
        pop ecx
        pop ebx
        pop eax
                
.contp: pop esi

.cont:  shr eax, 8
                
        inc esi

        cmp esi, 4
        jne .nextbyte
                
.nextregister:          

        inc edi
                
        cmp edi, 4
        je .fin

        cmp edi, 3
        jne .ecx
                
.edx:   mov eax, edx
        jmp .start
        
.ecx:   cmp edi, 2
        jne .ebx
                
        mov eax, ecx
        jmp .start

.ebx:   mov eax, ebx
        jmp .start

.fin:
        ret
        
; expects byte descriptor to be in al
; returns text address in esi or 0x00 for not found
GetStringAddress:

        mov edi, 0
        mov esi, __CacheTlbValueTable
                
.search:

        cmp [esi], al
        je .found

        inc edi
        inc esi
                
        cmp edi, 111
        jne .search
                
        mov esi, 0x00
                
        ret

.found: mov esi, __CacheTlbAddressTable

        lea esi, [esi + edi*4]

        mov esi, [esi]

        ret
                
; =============================================================================================

; leaf 03h, data in ecx, and edx
; Available in Pentium III processor only; otherwise, the value in this register is reserved
ProcessorSerialNumber:

        mov eax, 0x01                
        cpuid
                
        bt edx, kPSN            ; check if PSN is supported
        jnc .fin

        cinvoke printf, "  Processor serial number (bits 0-63) 0x%x%x %c", edx, ecx, 10

.fin:   ret

; =============================================================================================

; leaf 05h, data in eax, ebx, ecx, edx
; intel implementation
MonitorMWait:

        mov esi, dword __Leaf05
        call ShowLeafInformation

        mov eax, 0x05                
        cpuid

        cinvoke printf, "  Monitor / MWAIT (EAX:0x%x EBX:0x%x ECX:0x%x EDX:0x%x) %c", eax, ebx, ecx, edx, 10

        mov eax, 0x05                
        cpuid
                
        mov edi, ecx            ; make a backup 
        mov esi, edx
                
        push eax
        push ebx
        cinvoke printf, "    Smallest monitor-line size: %d bytes %c", eax, 10
        pop ebx
        pop eax
                
        push eax
        push ebx
        cinvoke printf, "    Largest monitor-line size : %d bytes %c", ebx, 10
        pop ebx
        pop eax
                
        bt edi, 0
        jnc .notsupported       ; Monitor-Wait extension beyond EAX/EBX not supported
                
        bt edi, kInterruptsBreakEventMWAIT
        jnc .cstates
                
        cinvoke printf, "    Supports treating interrupts as break-event for MWAIT, even when interrupts disabled. %c", 10
                
.cstates:

        mov edi, 0
                
.next:  mov eax, esi
                
        and eax, 0x0000000F
                
        cinvoke printf, "    Number of C%d sub C-states supported using MWAIT: %d %c", edi, eax, 10
                
        inc edi

        shr esi, 4

        cmp edi, 8
        jne .next

.fin:

        ret

.notsupported:

        ret

; =============================================================================================

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

; 06h leaf, data in eax
; Intel implementation
ThermalPower:

        mov esi, dword __Leaf06
        call ShowLeafInformation

        mov eax, 0x06
        cpuid

        mov edi, dword __ThermalPower1                

        push eax
        cinvoke printf, "  Thermal and Power Management (0x%x) %c", eax, 10
        pop eax
                
        mov esi, 0

.tloop: bt  eax, esi
        jnc .tnext

        push eax
        cinvoke printf, "    %02d::%s %c", esi, edi, 10
        pop eax

.tnext: add edi, __ThermalPower1Size

        inc esi

        cmp esi, 32

        jne .tloop

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
        cinvoke printf, "      idicates presence of MSR0000_00E7 (MPERF) and MSR0000_00E8 (APERF) %c", 10

.fin:   ret

; =============================================================================================

; 07h leaf, flags in ebx, ecx, and edx
; intel implementation
StructuredExtendedFeatureFlags:

        mov esi, dword __Leaf0700
        call ShowLeafInformation

        mov ecx, 0
        mov eax, 0x07           ; first pass
        cpuid
                
        mov edi, dword __StructuredExtendedFeatureFlags1
                
        push ebx
        cinvoke printf, "  Structured Extended Feature 1 (EBX:0x%x) %c", ebx, 10
        pop ebx

        cmp ebx, 0
        jne showb

        cinvoke printf, "    No features available. %c", 10

        jmp pass2
                
showb:  mov esi, 0

.lf1:   bt  ebx, esi
        jnc .nextb

        push ebx
        cinvoke printf, "    %02d::%s %c", esi, edi, 10
        pop ebx

.nextb: add edi, __StructuredExtendedFeatureFlags1Size

        inc esi

        cmp esi, 32

        jne .lf1

pass2:  mov ecx, 0
        mov eax, 0x07           ; second pass   
        cpuid
                
        mov edi, dword __StructuredExtendedFeatureFlags2
                
        push ecx
        cinvoke printf, "  Structured Extended Feature 2 (0x%x) %c", ecx, 10
        pop ecx

        cmp ecx, 0
        jne showc

        push ecx
        cinvoke printf, "    No features available. %c", 10
        pop ecx

        jmp pass3
                
showc:  mov esi, 0

.lf2:   bt  ecx, esi
        jnc .nextc

        push ecx
        cinvoke printf, "    %02d::%s %c", esi, edi, 10
        pop ecx

.nextc: add edi, __StructuredExtendedFeatureFlags2Size

        inc esi

        cmp esi, 32

        jne .lf2
                
pass3:  mov ecx, 0
        mov eax, 0x07           ; third pass
        cpuid
                
        mov edi, dword __StructuredExtendedFeatureFlags3
                
        push edx
        cinvoke printf, "  Structured Extended Feature 3 (0x%x) %c", edx, 10
        pop edx
                
showd:  mov esi, 0

.lf3:   bt  edx, esi
        jnc .nextd

        push edx
        cinvoke printf, "    %02d::%s %c", esi, edi, 10
        pop edx

.nextd: add edi, __StructuredExtendedFeatureFlags3Size

        inc esi

        cmp esi, 32

        jne .lf3

        mov esi, dword __Leaf0701
        call ShowLeafInformation

        mov ecx, 0x01
        mov eax, 0x07           ; sub-leaf 1   
        cpuid
               
        cmp eax, 0              ; eax returns 0 if sub-leaf index (1) is invald
        je subleaf2
               
        push eax
        cinvoke printf, "  Structured Extended Feature Sub-leaf 1 (0x%x) %c", eax, 10
        pop eax

        mov edi, dword __StructuredExtendedFeatureSubLeaf1aFlags
                
showe:  mov esi, 0

.lfs1:  bt  eax, esi
        jnc .nexte

        push eax
        cinvoke printf, "    %02d::%s %c", esi, edi, 10
        pop eax

.nexte: add edi, __StructuredExtendedFeatureSubLeaf1aFlagsSize

        inc esi

        cmp esi, 32

        jne .lfs1
                
; sub-leaf 1, ebx

        mov ecx, 0x01
        mov eax, 0x07           ; sub-leaf 1   
        cpuid
                
        mov esi, ebx
                
        cmp eax, 0              ; eax returns 0 if sub-leaf index (1) is invald
        je subleaf2

        cinvoke printf, "    ebx %02d", esi, 10

.b0100: bt esi, kIA32_PPIN
        jnc .b0103
                
        cinvoke printf, "    IA32_PPIN and IA32_PPIN_CTL MSRs %c", 10
                
.b0103: bt esi, kCPUIDMAXVAL_LIM_RMV
        jnc .sl1d
                
        cinvoke printf, "    CPUIDMAXVAL_LIM_RMV. IA32_MISC_ENABLE cannot be set to 1 to limit CPUID.00H:EAX[bits 7:0] %c", 10
                
; sub-leaf 1, ecx
; ecx is reserved
                
; sub-leaf 1, edx

.sl1d:  mov ecx, 0x01
        mov eax, 0x07           ; sub-leaf 1   
        cpuid
                
        cmp edx, 0              ; edx returns 0 if sub-leaf index (1) is invald
        je subleaf2
                
        pop edx
        cinvoke printf, "    edx %02d", edx, 10         
        push edx
                
        mov edi, dword __StructuredExtendedFeatureSubLeaf1dFlags
                
showg:  mov esi, 0

.lfs1d: bt  edx, esi
        jnc .nextf

        push edx
        cinvoke printf, "    %02d::%s %c", esi, edi, 10
        pop edx

.nextf: add edi, __StructuredExtendedFeatureSubLeaf1dFlagsSize

        inc esi

        cmp esi, 32

        jne .lfs1d

subleaf2: ; sub-leaf 2

        mov esi, dword __LeafInvalid
        call ShowLeafInformation                

.sl72:  mov esi, dword __Leaf0702
        call ShowLeafInformation
        
        mov ecx, 0x02           ; sub-leaf 2
        mov eax, 0x07
        cpuid

        cmp eax, 0
        je .invalid2
                
        mov edi, edx
                
.d0200: bt edi, kPSFD
        jnc .d0201
                
        cinvoke printf, "    PSFD. Indicates bit 7 of the IA32_SPEC_CTRL MSR is supported %c", 10

.d0201: bt edi, kIPRED_CTRL
        jnc .d0202

        cinvoke printf, "    IPRED_CTRL. Bits 3 and 4 of the IA32_SPEC_CTRL MSR are supported %c", 10

.d0202: bt edi, kRRSBA_CTRL
        jnc .d0203

        cinvoke printf, "    RRSBA_CTRL. Bits 5 and 6 of the IA32_SPEC_CTRL MSR are supported %c", 10

.d0203: bt edi, kDDPD_U
        jnc .d0204

        cinvoke printf, "    DDPD_U. Bit 8 of the IA32_SPEC_CTRL MSR is supported %c", 10

.d0204: bt edi, kBHI_CTRL
        jnc .d0205

        cinvoke printf, "    BHI_CTRL. Bit 10 of the IA32_SPEC_CTRL MSR is supported %c", 10
                
.d0205: bt edi, kMCDT_NO
        jnc .d0206

        cinvoke printf, "    MCDT_NO. %c", 10
        cinvoke printf, "    Processor does not exhibit MXCSR Configuration Dependent Timing (MCDT) %c", 10
                
.d0206: bt edi, kUCLockDisable
        jnc .d0207

        cinvoke printf, "    Supports the UC-lock disable feature and it causes #AC %c", 10             

.d0207: bt edi, 7
        jnc .fin

        cinvoke printf, "    MONITOR_MITG_NO. %c", 10
        cinvoke printf, "    MONITOR/UMONITOR instructions are not affected by performance or power issues %c", 10

.invalid2:

        mov esi, dword __LeafInvalid
        call ShowLeafInformation        

.fin:
        ret
                
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

; leaf 09h, data in eax only
; Intel only, not supported by AMD
DirectCacheAccessInfo:

        cmp dword [__VendorID + 8], 0x6c65746e
        jne .fin

        mov esi, dword __Leaf09
        call ShowLeafInformation

        mov eax, 0x09                
        cpuid
                
        cinvoke printf, "  Value of IA32_PLATFORM_DCA_CAP MSR (@ 0x1F8): 0x%x %c", eax, 10

.fin:
        ret

; =============================================================================================

; leaf 0ah
; intel only
ArchitecturalPerfMon:

        cmp [__MaxBasic], 0x0A
        jl .fin
                
        mov esi, dword __Leaf0A
        call ShowLeafInformation

        mov eax, 0x0A
        cpuid

        mov edi, eax
        mov esi, edx

        cinvoke printf, "  Architectural Performance Monitoring (EAX:0x%x EBX:0x%x ECX:0x%x EDX:0x%x) %c", edi, ebx, ecx, esi, 10

        mov eax, edi
        and eax, 0x000000FF
                
        cinvoke printf, "    Version ID of APM                 : %d %c", eax, 10

        mov eax, edi

        shr eax, 8
        and eax, 0x000000FF
                
        cinvoke printf, "    Perf counter per logical processor: %d %c", eax, 10

        mov eax, edi

        shr eax, 16
        and eax, 0x000000FF

        cinvoke printf, "    Bit width of perf monitor counter : %d %c", eax, 10

        mov eax, edi

        shr eax, 24
        and eax, 0x000000FF
                
        cinvoke printf, "    EBX bit vector : 0x%x %c", eax, 10         

        mov eax, esi
        and eax, 0x0000001F

        cinvoke printf, "    Contiguous fixed-function performance counters starting from 0: %d %c", eax, 10

        mov eax, esi
        shr eax, 5
        and eax, 0x000000FF

        cinvoke printf, "    Bit width of fixed-function performance counters: %d %c", eax, 10

        bt esi, kAnyThread
        jnc .sfcbm

        cinvoke printf, "    AnyThread deprecation %c", 10

.sfcbm: mov eax, 0x0A
        cpuid

        cinvoke printf, "    Supported fixed counters bit mask: 0x%x %c", ecx, 10
		cinvoke printf, "%c", 10
		
        mov eax, 0x0A
        cpuid

        shr eax, 24
        and eax, 0x000000FF     ; isolate event bit vector EAX[31:24]
		mov edi, eax
        mov esi, ebx

.b1:    bt esi, 0
        jc .b1n

        cmp edi, 1
        jle .b1n
		
.b1y:   cinvoke printf, "    Core cycle event available %c", 10
        jmp .b2

.b1n:   cinvoke printf, "    Core cycle event not available %c", 10

.b2:    bt esi, 1
        jc .b2n

        cmp edi, 2
        jle .b2n
		
.b2y:   cinvoke printf, "    Instruction retired event available %c", 10
        jmp .b3

.b2n:   cinvoke printf, "    Instruction retired event not available %c", 10

.b3:    bt esi, 2
        jc .b3n

        cmp edi, 3
        jle .b3n
		
.b3y:   cinvoke printf, "    Reference cycles event available %c", 10
        jmp .b4

.b3n:   cinvoke printf, "    Reference cycles event not available %c", 10

.b4:    bt esi, 3
        jc .b4n

        cmp edi, 4
        jle .b4n
		
.b4y:   cinvoke printf, "    Last-level cache reference event available %c", 10
        jmp .b5

.b4n:   cinvoke printf, "    Last-level cache reference event not available %c", 10

.b5:    bt esi, 4
        jc .b5n

        cmp edi, 5
        jle .b5n
		
.b5y:   cinvoke printf, "    Last-level cache misses event available %c", 10
        jmp .b6

.b5n:   cinvoke printf, "    Last-level cache misses event not available %c", 10

.b6:    bt esi, 5
        jc .b6n

        cmp edi, 6
        jle .b6n
		
.b6y:   cinvoke printf, "    Branch instruction retired event available %c", 10
        jmp .b7

.b6n:   cinvoke printf, "    Branch instruction retired event not available %c", 10

.b7:    bt esi, 6
        jc .b7n

        cmp edi, 7
        jle .b8n
		
.b7y:   cinvoke printf, "    Branch mispredict retired event available %c", 10
        jmp .b8

.b7n:   cinvoke printf, "    Branch mispredict retired event not available %c", 10

.b8:    bt esi, 7
        jc .b8n

        cmp edi, 8
        jle .b8n
		
.b8y:   cinvoke printf, "    Top-down slots event available %c", 10
        jmp .fin

.b8n:   cinvoke printf, "    Top-down slots event not available %c", 10

.fin:   ret

; =============================================================================================

; leaf 0bh, data in eax, ebx, ecx, and edx
; intel implementation
ExtendedTopology:

        cmp [__MaxBasic], 0x1f                  ; 0x1f is the preferred topology leaf, if it's valid on this CPU, ignore 0bh
        jge .fin
                
        mov esi, dword __Leaf1F00
        call ShowLeafInformation
                
        mov ecx, 0
        mov eax, 0x1f                
        cpuid              

        cinvoke printf, "  Extended Topology Enumeration (EAX:0x%x EBX:0x%x ECX:0x%x EDX:0x%x) %c", eax, ebx, ecx, edx, 10

        mov ecx, 0
        mov eax, 0x1f   
        cpuid
                
        cmp eax, 0
        je .fin
                
        mov [__X2APICID], edx
                
        cinvoke printf, "    x2APIC ID of the current logical processor     : %d %c", edx, 10
                
        mov esi, 0                      ; sub-leaf index

        cinvoke printf, "%c", 10

        mov ecx, 0
.loop:  mov eax, 0x1f   
        cpuid
                
        cmp eax, 0
        je .fin
                
        shr ecx, 8
        and ecx, 0x000000FF             ; get level type from bits 15:08
        
        cmp ecx, 0                      ; ecx[15:08] = 0 is invalid, exit
        je .fin
                
        imul ecx, __LevelTypeSize
        add ecx, __LevelType
                
        push eax
        push ebx
        cinvoke printf, "    Level Type                                     : %s %c", ecx, 10
        pop ebx
        pop eax
                
        and eax, 0x0000001F
        and ebx, 0x0000FFFF
                        
        push ebx
        cinvoke printf, "    Bits to shift right on x2APIC                  : %d %c", eax, 10
        ; to get a unique topology ID of the next level type
        pop ebx
                        
        cinvoke printf, "    Number of logical processors at this level type: %d %c", ebx, 10
        cinvoke printf, "%c", 10

        inc esi
        mov ecx, esi
        jp .loop

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

;leaf 0dh (ecx=0), data in eax, ebx, ecx
; intel implementation
ProcExtStateEnumMain:

        cmp [__MaxBasic], 0x0D
        jl .fin
                
        mov esi, dword __Leaf0D00
        call ShowLeafInformation

        mov ecx, 0x00
        mov eax, 0x0D
        cpuid
                
        mov edi, __ProcExtStateEnumMain

        push eax
        cinvoke printf, "  Processor Extended State Enumeration (EAX:0x%x EBX:0x%x ECX:0x%x) %c", eax, ebx, ecx, 10
        pop eax

        mov esi, 0              ; bit counter

.loop:  bt  eax, esi
        jnc .next

        push eax
        cinvoke printf, "    %02d::%s %c", esi, edi, 10
        pop eax

.next:  add edi, __ProcExtStateEnumMainSize

        inc esi

        cmp esi, 32             ; number of bits to test

        jne .loop

        mov ecx, 0x00
        mov eax, 0x0D
        cpuid

        mov edi, __ProcExtStateEnumMain

        mov edi, ebx
        mov esi, ecx
                
        cinvoke printf, "    Maximum size required by enabled features: %d bytes %c", edi, 10
        cinvoke printf, "    Maximum size of the save area            : %d bytes %c", esi, 10

.fin:   ret

;leaf 0dh (ecx=1), data in eax, ebx, ecx
ProcExtStateEnumSub1:

        cmp [__MaxBasic], 0x0D
        jl .fin
                
        mov esi, dword __Leaf0D01
        call ShowLeafInformation

        mov ecx, 0x01
        mov eax, 0x0D
        cpuid
                
        mov edi, eax
        mov esi, ebx
                
        bt edi, kXSAVEOPT
        jnc .bit1
                
        cinvoke printf, "    XSAVEOPT available %c", 10
                
.bit1:  bt edi, kXSAVEC
        jnc .bit2
                
        cinvoke printf, "    Supports XSAVEC and the compacted form of XRSTOR %c", 10
                
.bit2:  bt edi, kXGETBV
        jnc .bit3
                
        cinvoke printf, "    Supports XGETBV %c", 10

.bit3:  bt edi, kIA32_XSS
        jnc .bit4
                
        cinvoke printf, "    Supports XSAVES/XRSTORS and IA32_XSS %c", 10
                
.bit4:  bt edi, kXFD
        jnc .size
                
        cinvoke printf, "    Supports extended feature disable (XFD) %c", 10            

.size:  cinvoke printf, "    XSAVE area containing all states enabled by XCR0 | IA32_XSS: %d bytes %c", esi, 10

        mov ecx, 0x01
        mov eax, 0x0D
        cpuid   
                
        cinvoke printf, "    IA32_XSS MSR 0x%08X%08X %c", edx, ecx, 10

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

; leaf 0fh, sub leaf 0 and 1
; intel implementation
IntelRDTMonitoring:

        cmp [__MaxBasic], 0x0F
        jl .fin
                
        mov esi, dword __Leaf0F00
        call ShowLeafInformation
                
        mov ecx, 0
        mov eax, 0x0F
        cpuid           

        cinvoke printf, "  Intel Resource Director Technology (EAX:0x%x EDX:0x%x) %c", eax, edx, 10

        mov ecx, 0
        mov eax, 0x0F
        cpuid

        mov edi, edx
                
        inc eax
                
        cinvoke printf, "    Max Range of RMID within this physical processor: 0x%x %c", eax, 10

        bt edi, kL3CacheIntelRDTM
        jnc .subleaf
                
        cinvoke printf, "    Supports L3 Cache Intel RDT Monitoring %c", 10
                
.subleaf:

        mov esi, dword __Leaf0F01
        call ShowLeafInformation

        mov ecx, 1
        mov eax, 0x0F                
        cpuid

        cinvoke printf, "  L3 Cache Intel RDT Monitoring Capability (EAX:0x%x EBX:0x%x ECX:0x%x EDX:0x%x) %c", eax, ebx, ecx, edx, 10

        mov ecx, 1              ; eax and ebx
        mov eax, 0x0F                
        cpuid

        mov edi, eax
        mov esi, ebx

        and eax, 0xFF           ; counter width is bits 0-7
        add eax, 24             ; counter width is encoded from an offset of 24

        cinvoke printf, "    %d-bit counters are supported %c", eax, 10

.bit8:  bt edi, kIA32_QM_CTR
        jnc .bit9
                
        cinvoke printf, "    Overflow bit in IA32_QM_CTR MSR bit 61 %c", 10
                
.bit9:  bt edi, kRDT_CMT
        jnc .bita

        cinvoke printf, "    Non-CPU agent Intel RDT CMT support %c", 10
                
.bita:  bt edi, kRDT_MBM
        jnc .next               
                
        cinvoke printf, "    Non-CPU agent Intel RDT MBM support %c", 10

.next:  cinvoke printf, "    IA32_QM_CTR conversion factor: 0x%x bytes %c", esi, 10
                                
        mov ecx, 1              ; ecx and edx                   
        mov eax, 0x0F                
        cpuid                           
                                
        inc ecx
                
        mov edi, ecx
        mov esi, edx

        cinvoke printf, "    Maximum range of RMID of this resource type: 0x%x %c", edi, 10

        bt esi, kL3OccupancyMonitoring
        jnc .bit1

        cinvoke printf, "    Supports L3 occupancy monitoring %c", 10
                
.bit1:  bt esi, kL3TotalBandwidthMonitoring
        jnc .bit2
                
        cinvoke printf, "    Supports L3 Total Bandwidth monitoring %c", 10
                
.bit2:  bt esi, kL3LocalBandwidthMonitoring
        jnc .fin

        cinvoke printf, "    Supports L3 Local Bandwidth monitoring %c", 10

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

; leaf 10h, sub-leaf 0 (data in ebx only)
; intel implementation
IntelRDTAllocEnum:

        cmp [__MaxBasic], 0x10
        jl .fin
                
        mov esi, dword __Leaf1000
        call ShowLeafInformation

        mov ecx, 0
        mov eax, 0x10
        cpuid
                
        mov edi, ebx
                
        cinvoke printf, "  Intel Resource Director Technology Allocation Enumeration (EBX:0x%x) %c", edi, 10
                
.bit1:  bt edi, kL3CacheAllocationTechnology
        jnc .bit2
                
        cinvoke printf, "    Supports L3 Cache Allocation Technology %c", 10

.bit2:  bt edi, kL2CacheAllocationTechnology
        jnc .bit3
                
        cinvoke printf, "    Supports L2 Cache Allocation Technology %c", 10

.bit3:  bt edi, kMemoryBandwidthAllocation
        jnc .subleaf1
                
        cinvoke printf, "    Supports Memory Bandwidth Allocation %c", 10
                
; leaf 10h, leaf 1 (data in eax, ebx, ecx, and edx)

.subleaf1:

        mov esi, dword __Leaf1001
        call ShowLeafInformation

        mov ecx, 1
        mov eax, 0x10                
        cpuid

        cinvoke printf, "  L3 Cache Allocation Technology Enumeration (EAX:0x%x EBX:0x%x ECX:0x%x EDX:0x%x) %c", eax, ebx, ecx, edx, 10
                
        mov ecx, 1
        mov eax, 0x10   
        cpuid
                
        mov edi, eax
        mov esi, eax
                
        and edi, 0x0000001F
        inc edi
                
        cinvoke printf, "    ResID 1 Capacity bit mask length: %d %c", edi, 10
        cinvoke printf, "    Bit-granular map of isolation/contention of allocation units: 0x%x %c", esi, 10
                
        mov ecx, 1
        mov eax, 0x10   
        cpuid
                
        mov edi, ecx
        mov esi, edx
                
.bit11: bt edi, kL3CATNonCPUAgent
        jnc .bit12
                                
        cinvoke printf, "    L3 CAT for non-CPU agents is supported %c", 10
                                
.bit12: bt edi, kL3CPT
        jnc .cpns1
                
        cinvoke printf, "    L3 Code and Prioritization Technology supported %c", 10
                
        jmp .bit13
                
.cpns1:

        cinvoke printf, "    L3 Code and Prioritization Technology not supported %c", 10

.bit13: bt edi, kNonContiguousCapacityBitmask
        jnc .hcos1
                
        cinvoke printf, "    Non-contiguous capacity bitmask is supported %c", 10
        cinvoke printf, "        The bits in IA32_L3_MASK_n registers do not have to be contiguous %c", 10

.hcos1:

        and esi, 0x0000FFFF
                
        cinvoke printf, "    Highest CLOS number supported for ResID: %d %c", esi, 10

; leaf 10h, sub-leaf 2 (data in eax, ebx, ecx, and edx)

.subleaf2:

        mov esi, dword __Leaf1002
        call ShowLeafInformation

        mov ecx, 2
        mov eax, 0x10                
        cpuid

        cinvoke printf, "  L2 Cache Allocation Technology Enumeration (EAX:0x%x EBX:0x%x ECX:0x%x EDX:0x%x) %c", eax, ebx, ecx, edx, 10
                
        mov ecx, 2
        mov eax, 0x10   
        cpuid
                
        mov edi, eax
        mov esi, ebx
                
        and edi, 0x0000001F
        inc edi
                
        cinvoke printf, "    ResID 2 Capacity bit mask length: %d %c", edi, 10
        cinvoke printf, "    Bit-granular map of isolation/contention of allocation units: 0x%x %c", esi, 10
                
        mov ecx, 2
        mov eax, 0x10   
        cpuid
                
        mov edi, ecx
        mov esi, edx
                
.bit22: bt edi, kL2CDPT
        jnc .bit23
                
        cinvoke printf, "    L2 Code and Data Prioritization Technology supported %c", 10
                
        jmp .hcos2
                
.cpns2:

        cinvoke printf, "    Code and Prioritization Technology not supported %c", 10

.bit23: bt edi, kNonContiguousCapacityBitmask
        jnc .hcos2

        cinvoke printf, "    Non-contiguous capacity bitmask is supported %c", 10
        cinvoke printf, "        The bits in IA32_L2_MASK_n registers do not have to be contiguous %c", 10

.hcos2:

        and esi, 0x0000FFFF
                
        cinvoke printf, "    Highest COS number supported for ResID 2: %d %c", esi, 10

; leaf 10h, sub-leaf 3 (data in eax, ecx, and edx)

.subleaf3:

        mov esi, dword __Leaf1003
        call ShowLeafInformation

        mov ecx, 3
        mov eax, 0x10                
        cpuid

        cinvoke printf, "  Memory Bandwidth Allocation Enumeration (EAX:0x%x ECX:0x%x EDX:0x%x) %c", eax, ecx, edx, 10
                
        mov ecx, 3
        mov eax, 0x10   
        cpuid
                
        mov edi, ecx
        mov esi, edx
                
        and eax, 0x00000FFF
        inc eax
                
        cinvoke printf, "    Max MBA throttling value supported by ResID 3: %d %c", eax, 10
                
        bt edi, kDelayValuesLinear
        jnc .dnl
                
        cinvoke printf, "    Response of the delay values is linear %c", 10
                
        jmp .hcos3
                
.dnl:   cinvoke printf, "    Response of the delay values is not linear %c", 10

.hcos3: and esi, 0x0000FFFF

        cinvoke printf, "    Highest COS number supported for ResID 3: %d %c", esi, 10

.fin:

        ret

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

; leaf 12h, ecx = 1, data in eax, ebx, and edx
; intel only
IntelSGXCapability:

        cmp [__MaxBasic], 0x12
        jl .fin
                
        mov esi, dword __Leaf1200
        call ShowLeafInformation
                
        mov ecx, 0
        mov eax, 0x07           ; just getting SGX values  
        cpuid           

        cinvoke printf, "  Intel SGX Capability Enumeration (EAX:0x%x EBX:0x%x EDX:0x%x) %c", eax, ebx, edx, 10
                
        mov ecx, 0
        mov eax, 0x07           ; get extended features   
        cpuid
                
        bt ebx, kSGX
        jnc .notsupported

        mov ecx, 0
        mov eax, 0x12   
        cpuid
                
        mov edi, ebx
        mov esi, edx
                
        bt eax, kSGX1Leaf
        jnc .bit1
                
        push eax
        cinvoke printf, "    Intel SGX supports the collection of SGX1 leaf functions %c", 10
        pop eax
                
.bit1:  bt eax, kSGX2Leaf
        jnc .bit5
                
        push eax
        cinvoke printf, "    Intel SGX supports the collection of SGX2 leaf functions %c", 10
        pop eax
                
.bit5:  bt eax, kENCLVx
        jnc .bit6

        push eax
        cinvoke printf, "    Intel SGX supports ENCLV instructions (EINCVIRTCHILD, EDECVIRTCHILD, and ESETCONTEXT) %c", 10
        pop eax

.bit6:  bt eax, kENCLSx
        jnc .bit7
                
        push eax
        cinvoke printf, "    Intel SGX supports ENCLS instructions (ETRACKC, ERDINFO, ELDBC, and ELDUC) %c", 10
        pop eax
                
.bit7:  bt eax, kEVERIFYREPORT2
        jnc .bit10
                
        push eax
        cinvoke printf, "    Intel SGX supports ENCLU instruction leaf EVERIFYREPORT2 %c", 10
        pop eax

.bit10: bt eax, kEUPDATESVN
        jnc .bit11
                
        push eax
        cinvoke printf, "    Intel SGX supports ENCLS instruction leaf EUPDATESVN %c", 10
        pop eax

.bit11: bt eax, kEDECCSSA
        jnc .ebx
                
        push eax
        cinvoke printf, "    Intel SGX supports ENCLU instruction leaf EDECCSSA %c", 10
        pop eax         
                
.ebx:   cinvoke printf, "    MISCSELECT, supported extended SGX features: %d %c", edi, 10
                
        mov eax, esi
                
        and eax, 0x000000FF
                
        cinvoke printf, "    MaxEnclaveSize_Not64 = 2^%d %c", eax, 10
                
        shr esi, 8
        and esi, 0x000000FF

        cinvoke printf, "    MaxEnclaveSize_64 = 2^%d %c", esi, 10

; leaf 12h ecx = 1, data in eax, ebx, ecx, and edx

        cinvoke printf, "%c", 10

        mov esi, dword __Leaf1201
        call ShowLeafInformation

        mov ecx, 1
        mov eax, 0x12

        mov edi, ecx
        mov esi, edx

        push ebx
        cinvoke printf, "    SECS.ATTRIBUTES[31:0]   = 0x%x %c", eax, 10
        pop ebx

        cinvoke printf, "    SECS.ATTRIBUTES[63:32]  = 0x%x %c", ebx, 10

        cinvoke printf, "    SECS.ATTRIBUTES[95:64]  = 0x%x %c", edi, 10

        cinvoke printf, "    SECS.ATTRIBUTES[127:96] = 0x%x %c", esi, 10

; leaf 12h ecx = 2, data in eax, ebx, ecx, and edx

        mov esi, dword __Leaf1202
        call ShowLeafInformation

        mov ecx, 2
        mov eax, 0x12
                
        bt eax, 1
        jnc .fin

        mov edi, ecx
        mov esi, edx

        shr eax, 12
        shr ebx, 20
                                
        cinvoke printf, "    Bits 31:12 (0x%x), 51:32 (0x%x) of the physical address of the base of the EPC section %c", eax, ebx, 10
                
        mov ecx, edi
                
        and ecx, 0x0000000F
        cmp ecx, 0
        jne .fin

        dec ecx ; zero-index to the string table
                
        imul ecx, __SGXEPCSubLeaf2Size
        add ecx, __SGXEPCSubLeaf2
                                
        cinvoke printf, "%s %c", ecx, 10

.ecx:   shr edi, 12
        and edi, 0x000FFFFF

        and esi, 0x000FFFFF
                
        cinvoke printf, "    Bits 31:12 (0x%x), 51:32 (0x%x) size of the EPC section within the Processor Reserved Memory. %c", edi, esi, 10

.fin:   ret

.notsupported:

        cinvoke printf, "    Not supported. %c", 10

        ret

; =============================================================================================

; leaf 14h, data in eax, ebx, and ecx
; Intel only
IntelProcessorTrace:

        cmp [__MaxBasic], 0x14
        jl .fin
                
        mov esi, dword __Leaf1400
        call ShowLeafInformation
                                
        mov ecx, 0
        mov eax, 0x14
        cpuid

        cinvoke printf, "  Intel Processor Trace Enumeration (EAX:0x%x EBX:0x%x ECX:0x%x) %c", eax, ebx, ecx, 10

        mov ecx, 0
        mov eax, 0x14
        cpuid

        mov edi, ebx
        mov esi, ecx
                
.bbit0: bt edi, kIA32_RTIT_CTL
        jnc .bbit1
                
        cinvoke printf, "    IA32_RTIT_CTL.CR3Filter can be set to 1, IA32_RTIT_CR3_MATCH MSR can be accessed %c", 10

.bbit1: bt edi, kConfigurablePSB
        jnc .bbit2

        cinvoke printf, "    Configurable PSB and Cycle-Accurate Mod is supported %c", 10

.bbit2: bt edi, kIPFiltering
        jnc .bbit3

        cinvoke printf, "    IP Filtering, TraceStop filtering, and preservation of Intel PT MSRs across warm reset. %c", 10

.bbit3: bt edi, kMTCTimingPacket
        jnc .bbit4

        cinvoke printf, "    MTC timing packet and suppression of COFI-based packets is supported %c", 10

.bbit4: bt edi, kPTWRITE
        jnc .bbit5

        cinvoke printf, "    PTWRITE. Writes can set IA32_RTIT_CTL[12] (PTWEn) and IA32_RTIT_CTL[5] (FUPonPTW),%c", 10
        cinvoke printf, "      and PTWRITE can generate packets is supported %c", 10

.bbit5: bt edi, kPwrEvtEn
        jnc .bbit6

        cinvoke printf, "    Power Event Trace. Writes can set IA32_RTIT_CTL[4] (PwrEvtEn), enabling Power Event Trace packet generation. %c", 10

.bbit6: bt edi, kInjectPsbPmiOnEnable
        jnc .bbit7

        cinvoke printf, "    PSB and PMI preservation. Writes can set IA32_RTIT_CTL[56] (InjectPsbPmiOnEnable), enabling the processor %c", 10 
        cinvoke printf, "      to set IA32_RTIT_STATUS[7] (PendTopaPMI) and/or IA32_RTIT_STATUS[6] (PendPSB) in order to preserve ToPA PMIs %c", 10
        cinvoke printf, "      and/or PSBs otherwise lost due to Intel PT disable. Writes can also set PendToPAPMI and PendPSB. %c", 10

.bbit7: bt edi, kEventEn
        jnc .bbit8

        cinvoke printf, "    Writes can set IA32_RTIT_CTL[31] (EventEn), enabling Event Trace packet generation %c", 10

.bbit8: bt edi, kDisTNT
        jnc .cbit0

        cinvoke printf, "    Writes can set IA32_RTIT_CTL[55] (DisTNT), disabling TNT packet generation %c", 10

.cbit0: bt esi, kTracingIA32_RTIT_CTL
        jnc .cbit1

        cinvoke printf, "    Tracing can be enabled with IA32_RTIT_CTL.ToPA = 1, hence utilizing the ToPA output scheme; %c", 10
        cinvoke printf, "      IA32_RTIT_OUTPUT_BASE and IA32_RTIT_OUTPUT_MASK_PTRS MSRs can be accessed %c", 10
                
.cbit1: bt esi, kToPATables
        jnc .cbit2

        cinvoke printf, "    ToPA tables can hold any number of output entries, up to the maximum allowed by the MaskOrTableOffset %c", 10
        cinvoke printf, "      field of IA32_RTIT_OUTPUT_MASK_PTRS %c", 10
                
.cbit2: bt esi, kSingleRangeOutput
        jnc .cbit3

        cinvoke printf, "    Single-Range Output scheme is supported %c", 10

.cbit3: bt esi, kTraceTransportSubsystem
        jnc .cbitx

        cinvoke printf, "    Indicates support of output to Trace Transport subsystem %c", 10

.cbitx: bt esi, kIPPayloadsLIPValues
        jnc .fin

        cinvoke printf, "    Generated packets which contain IP payloads have LIP values, which include the CS base component %c", 10

        mov ecx, 0
        mov eax, 0x14
        cpuid

        cmp eax, 1
        jl .invalid
                
        mov esi, dword __Leaf1401
        call ShowLeafInformation                

        mov ecx, 1
        mov eax, 0x14
        cpuid

        mov edi, eax
        mov esi, ebx

        and eax, 0x00000007

        cinvoke printf, "    Configurable Address Ranges for filtering: %d %c", eax, 10

        shr edi, 16
        and edi, 0x0000FFFF

        cinvoke printf, "    Bitmap of supported MTC period encodings: 0x%x %c", edi, 10

        mov eax, esi

        and eax, 0x0000FFFF

        cinvoke printf, "    Bitmap of supported MTC period encodings: 0x%x %c", eax, 10

        shr esi, 16
        and esi, 0x0000FFFF

        cinvoke printf, "    Bitmap of supported Configurable PSB freq encodings: 0x%x %c", esi, 10

.fin:   ret

.invalid:

        mov esi, dword __LeafInvalid
        call ShowLeafInformation

        ret

; =============================================================================================

; leaf 15h, data in eax, ebx, and ecx
; intel only
TimeStampCounter:

        cmp [__MaxBasic], 0x15
        jl .fin
                
        mov esi, dword __Leaf15
        call ShowLeafInformation
                                
        mov eax, 0x15                
        cpuid
 
        cinvoke printf, "  Time Stamp Counter and Core Crystal Clock (EAX:0x%x EBX:0x%x ECX:0x%x) %c", eax, ebx, ecx, 10

        mov eax, 0x15
                
        cpuid

        mov edi, ecx
                
        cmp ebx, 0
        je .ccnotenumerated
                
        cinvoke printf, "    Core crystal clock ratio: %d/%d %c", ebx, eax, 10
        
        jmp .nf
        
.ccnotenumerated:

        cinvoke printf, "    Core crystal clock is not enumerated %c", 10
                
.nf:    cmp edi, 0
        je .nfnotenumerated
                
        cinvoke printf, "    Core crystal clock nominal freq: %d Hz %c", edi, 10
                
        ret
                
.nfnotenumerated:

        cinvoke printf, "    Core crystal clock nominal freq not enumerated %c", 10

.fin:   ret

; =============================================================================================

; leaf 16h, data in eax, ebx, and ecx
; intel only
ProcessorFreqInfo:

        cmp [__MaxBasic], 0x16
        jl .fin

        mov esi, dword __Leaf16
        call ShowLeafInformation

        mov eax, 0x16
        cpuid

        and eax, 0x0000FFFF     ; bits 16-31 are reserved, so let's mask them out
        and ebx, 0x0000FFFF     ;
        and ecx, 0x0000FFFF     ;

        mov edi, ebx
        mov esi, ecx
                
        push eax
        cinvoke printf, "  Processor Frequency Information (EAX:0x%x EBX:0x%x ECX:0x%x) %c", eax, edi, esi, 10
        pop eax

.bf:    cmp eax, 0
        je .bfns

        cinvoke printf, "    Base Frequency      : %d MHz %c", eax, 10

        jmp .mf
                
.bfns:  cinvoke printf, "    Base Frequency      : Unknown %c", 10

.mf:    cmp edi, 0
        je .mfns

        cinvoke printf, "    Maximum Frequency   : %d MHz %c", edi, 10
                
        jmp .rf
                
.mfns:  cinvoke printf, "    Maximum Frequency   : Unknown %c", 10
                
.rf:    cmp esi, 0
        je .rfns
                
        cinvoke printf, "    Bus (Ref) Frequency :  %d MHz %c", esi, 10
                
        jmp .fin
                
.rfns:  cinvoke printf, "    Bus (Ref) Frequency : Unknown %c", 10

.fin:   ret

; =============================================================================================

; leaf 17h, data in eax, ebx, ecx, and edx
; intel only
SoCVendor:

        cmp [__MaxBasic], 0x17
        jl .fin

        mov esi, dword __Leaf1700
        call ShowLeafInformation

        mov ecx, 0
        mov eax, 0x17
        cpuid

        cmp eax, 3
        jl .fin

        cinvoke printf, "  System-On-Chip Vendor Attributes %c", 10

        mov edi, ebx

        and ebx, 0x0000FFFF

        cinvoke printf, "    SOC Vendor ID: 0x%x %c", ebx, 10

        bt edi, kIsVendorScheme
        jnc .p2

        cinvoke printf, "    IsVendorScheme (vendor ID is industry standard) %c", ebx, 10

.p2:    mov ecx, 0
        mov eax, 0x17
        cpuid

        mov edi, ecx
        mov esi, edx

        cinvoke printf, "    Project ID : 0x%x %c", edi, 10

        cinvoke printf, "    Stepping ID: 0x%x %c", esi, 10

.fin:   ret

; =============================================================================================

; leaf 18h, data in eax, ebx, ecx, and edx
; intel only
DATParameters:

        cmp [__MaxBasic], 0x18
        jl .fin
                
        mov esi, dword __Leaf18
        call ShowLeafInformation

        cinvoke printf, "  Deterministic Address Translation Parameters %c", 10  

        mov esi, 0

.loop:  mov ecx, esi
        mov eax, 0x18
        cpuid

        mov edi, edx
        and edi, 0x0000001F
                
        cmp edi, 0
        je .fin
                
        mov eax, ebx
                
        shr eax, 16             ; ways of associativiy now stored in eax
        and eax, 0x0000FFFF

        and ebx, 0x0000000F     ; page size stored in ebx

        mov edi, __DATCacheType

        and edx, 0x0000001F

.ctd:   cmp edx, 1
        jne .cti

        add edi, 13
        jmp .bit0

.cti:   cmp edx, 2
        jne .ctu

        add edi, 13*2
        jmp .bit0

.ctu:   cmp edx, 3
        jne .ctlo

        add edi, 13*3
        jmp .bit0

.ctlo:  cmp edx, 4
        jne .ctsol

        add edi, 13*4
        jmp .bit0

.ctsol: cmp edx, 5
        jne .bit0

        add edi, 13*5

.bit0:  bt ebx, k4PageSize
        jnc .bit1

        cinvoke printf, "    %s 4K page size, %d ways of associativity, %d sets %c", edi, eax, ecx, 10

.bit1:  bt ebx, k2MBPageSize
        jnc .bit2
                
        cinvoke printf, "    %s 2MB page size, %d ways of associativity, %d sets %c", edi, eax, ecx, 10

.bit2:  bt ebx, k4MBPageSize
        jnc .bit3

        cinvoke printf, "    %s 4MB page size, %d ways of associativity, %d sets %c", edi, eax, ecx, 10

.bit3:  bt ebx, k1GBPageSize
        jnc .next
                
        cinvoke printf, "    %s 1GB page size, %d ways of associativity, %d sets %c", edi, eax, ecx, 10

.next:  inc esi

        jmp .loop

.fin:   ret

; =============================================================================================

; leaf 19h, data in eax, ebx, and ecx
; intel only
KeyLocker:

        cmp [__MaxBasic], 0x19
        jl .fin

        mov esi, dword __Leaf19
        call ShowLeafInformation

        mov eax, 0x19
        cpuid

        cinvoke printf, "  Key Locker Leaf (EAX:0x%x EBX:0x%x ECX:0x%x) %c", eax, ebx, ecx, 10
                
        mov eax, 0x19
        cpuid

        mov edi, eax

        bt edi, kKLCPL0
        jnc .a01

        cinvoke printf, "    Key Locker restriction of CPL0-only supported %c", 10

.a01:   bt edi, kKLNoEncrypt
        jnc .a02

        cinvoke printf, "    Key Locker restriction of no-encrypt supported %c", 10

.a02:   bt edi, kKLNoDecrypt
        jnc .b00

        cinvoke printf, "    Key Locker restriction of no-decrypt supported %c", 10

.b00:   mov eax, 0x19
        cpuid
                
        mov edi, ebx
        mov esi, ecx

        bt edi, kAESKLE
        jnc .b02
                
        cinvoke printf, "    AESKLE. AES Key Locker instructions are fully enabled %c", 10
                
.b02:   bt edi, kAESWideKeyLockerInstructions
        jnc .b04
                
        cinvoke printf, "    AES wide Key Locker instructions are supported %c", 10

.b04:   bt edi, kKeyLockerMSRs
        jnc .c00

        cinvoke printf, "    Platform supports the Key Locker MSRs %c", 10
        cinvoke printf, "      (IA32_COPY_LOCAL_TO_PLATFORM, IA23_COPY_PLATFORM_TO_LOCAL, %c", 10
        cinvoke printf, "       IA32_COPY_STATUS, and IA32_IWKEYBACKUP_STATUS) %c", 10

.c00:   bt esi, kLOADIWKEYNoBackup
        jnc .c01

        cinvoke printf, "    NoBackup parameter to LOADIWKEY is supported %c", 10

.c01:   bt esi, kKeySourceEncodingOne
        jnc .fin

        cinvoke printf, "    KeySource encoding of 1 (randomization of the internal wrapping key) is supported %c", 10

.fin:   ret

; =============================================================================================

; leaf 1ah, data in eax
; intel only
NativeModelIDEnumeration:

        cmp [__MaxBasic], 0x1a
        jl .finish
                
        mov esi, dword __Leaf1A00
        call ShowLeafInformation

        cinvoke printf, "  Native Model ID Enumeration %c", 10

        mov ecx, 0
        mov eax, 0x1a   
        cpuid
                
        cmp eax, 0
        je .finish
                
        mov edi, eax
                
        shr eax, 24
        and eax, 0xFF

        cmp eax, 0x20
        jne .core
                
        cinvoke printf, "    Core type       : Intel Atom %c", 10
                
.core:  cmp eax, 0x40
        jne .id
                
        cinvoke printf, "    Core type       : Intel Core %c", 10
                
.id:    and edi, 0x00FFFFFF

        cinvoke printf, "    Native Model ID : 0x%x %c", edi, 10

.finish: 

        ret

; =============================================================================================

; leaf 1bh, data in eax, ebx, ecx, and edx
; intel only
GetPCONFIG:

        mov esi, dword __Leaf1B00
        call ShowLeafInformation

        mov ecx, 0
        mov eax, 0x1b                
        cpuid
                
        cmp eax, 0              ; value of 0 in eax indicates no support
        je .fin
                
        mov ecx, 1              ; only other sub-leaf currently supported
        mov eax, 0x1b   
        cpuid

        cinvoke printf, "  PCONFIG: EAX:0x%x EBX:0x%x ECX:0x%x EDX:0x%x %c", eax, ebx, ecx, edx, 10
                
.fin:   ret

; =============================================================================================

; leaf 1ch, data in eax, ebx, and ecx
; intel only
LastBranchRecords:

        mov esi, dword __Leaf1C00
        call ShowLeafInformation

        mov eax, 0x1C                
        cpuid

        cinvoke printf, "  Last Branch Records Information (EAX:0x%x EBX:0x%x ECX:0x%x) %c", eax, ebx, ecx, 10

        mov eax, 0x1C   
        cpuid
                
        mov edi, eax
                
        mov esi, 0
                
.lbr:   bt edi, esi
        jnc .next
                
        mov ebx, esi            ; for each bit n (esi), lbr depth value 8 * (n + 1) is supported
        inc ebx
        imul ebx, 8
                
        cinvoke printf, "    IA32_LBR_DEPTH.DEPTH value %d is supported %c", ebx, 10
                
.next:  inc esi
        cmp esi, 8
        jne .lbr
                
        bt edi, kDeepCStateReset
        jnc .a31
                
        cinvoke printf, "    Deep C-state Reset %c", 10
                
.a31:   bt edi, kIPValuesContainLIP
        jnc .pass2
                
        cinvoke printf, "    IP Values Contain LIP %c", 10
                
.pass2: mov eax, 0x1C   
        cpuid
                
        mov edi, ebx
        mov esi, ecx
                
.b00:   bt edi, kCPLFiltering
        jnc .b01
                
        cinvoke printf, "    CPL Filtering Supported %c", 10
                
.b01:   bt edi, kBranchFiltering
        jnc .b02
                
        cinvoke printf, "    Branch Filtering Supported %c", 10
                
.b02:   bt edi, kCallStackMode
        jnc .c00
                
        cinvoke printf, "    Call-stack Mode Supported %c", 10
                
.c00:   bt esi, kMispredictBit
        jnc .c01

        cinvoke printf, "    Mispredict Bit Supported %c", 10

.c01:   bt esi, kTimedLBRs
        jnc .c02

        cinvoke printf, "    Timed LBRs Supported %c", 10

.c02:   bt esi, kBranchTypeField
        jnc .c03

        cinvoke printf, "    Branch Type Field Supported %c", 10

.c03:   shr esi, 16             ; bits 19-16 are event logging supported bitmap
        and esi, 0x0f
                
        cinvoke printf, "    Event logging supported bitmap 0x%x %c", esi, 10

.fin:   ret

; =============================================================================================

; leaf 1dh, data in eax and ebx
; intel only
TileInformation:

        cmp [__MaxBasic], 0x1d
        jl .fin

        mov esi, dword __Leaf1D00
        call ShowLeafInformation

        cinvoke printf, "  Tile Information %c", 10

        mov ecx, 0
        mov eax, 0x1d
        cpuid
                
        cinvoke printf, "    max_palette: %d %c", eax, 10

        mov ecx, 1
        mov eax, 0x1d
        cpuid

        mov edi, eax
        mov esi, ebx

        and eax, 0x0000FFFF

        cinvoke printf, "    total_tile_bytes          : %d %c", eax, 10
                
        shr edi, 16
        and edi, 0x0000FFFF
                
        cinvoke printf, "    bytes_per_tile            : %d %c", edi, 10
                
        mov eax, esi
                
        and eax, 0x0000FFFF
                
        cinvoke printf, "    bytes_per_row             : %d %c", eax, 10

        shr esi, 16
        and esi, 0x0000FFFF
                
        cinvoke printf, "    max_names (tile_registers): %d %c", esi, 10
                
        mov ecx, 1
        mov eax, 0x1d
        cpuid
                
        and ecx, 0x0000FFFF
                
        cinvoke printf, "    max_rows                  : %d %c", ecx, 10

.fin:   ret

; =============================================================================================

; leaf 1eh, data in ebx
; intel only
TMULInformation:

        cmp [__MaxBasic], 0x1e
        jl .fin
                
        mov esi, dword __Leaf1E00
        call ShowLeafInformation

        cinvoke printf, "  Branch Type Field Supported %c", 10

        mov ecx, 0
        mov eax, 0x1e   
        cpuid
                
        mov edi, eax
        mov esi, eax
                
        and edi, 0x000000FF
                
        cinvoke printf, "    tmul_maxk = %d %c", edi, 10
                
        shr esi, 8
        and esi, 0x0000FFFF
                
        cinvoke printf, "    tmul_maxn = %d %c", esi, 10
                
.fin:   ret

; =============================================================================================

; leaf 1fh, data in eax, ebx, ecx, and edx
; intel only
V2ExtendedTopology:

        cmp [__MaxBasic], 0x1f
        jl .fin

        mov esi, dword __Leaf1F00
        call ShowLeafInformation

        cinvoke printf, "  V2 Extended Topology Enumeration %c", 10

        mov ecx, 0
        mov eax, 0x1f   
        cpuid
                
        cmp eax, 0
        je .fin
                
        mov [__X2APICID], edx
                
        cinvoke printf, "    x2APIC ID of the current logical processor     : %d %c", edx, 10
                
        mov esi, 0              ; sub-leaf index

        cinvoke printf, "%c", 10

        mov ecx, 0
.loop:  mov eax, 0x1f   
        cpuid
                
        cmp eax, 0
        je .fin
                
        shr ecx, 8
        and ecx, 0x000000FF     ; get level type from bits 15:08
        
        cmp ecx, 0              ; ecx[15:08] = 0 is invalid, exit
        je .fin
                
        imul ecx, __LevelTypeSize
        add ecx, __LevelType
                
        push eax
        push ebx
        cinvoke printf, "    Domain Type                                    : %s %c", ecx, 10
        pop ebx
        pop eax
                
        and eax, 0x1F
        and ebx, 0x0000FFFF
                        
        push ebx
        cinvoke printf, "    Bits to shift right on x2APIC                  : %d %c", eax, 10
        cinvoke printf, "      (to get a unique topology ID of the next level type) %c", eax, 10
        pop ebx
                        
        cinvoke printf, "    Number of logical processors at this level type: %d %c", ebx, 10
        cinvoke printf, "%c", 10

        inc esi
        mov ecx, esi
        jp .loop

.fin:   ret

; =============================================================================================

; leaf 20h, data in eax and ebx
; intel only
ProcessorHistoryReset:

        cmp [__MaxBasic], 0x20
        jl .fin

        mov esi, dword __Leaf20
        call ShowLeafInformation

        cinvoke printf, "  Processor History Reset %c", 10

        mov ecx, 0
        mov eax, 0x20
        cpuid
                
        mov edi, ebx

        cinvoke printf, "    Sub-leafs supported: %d %c", eax, 10
                
        cinvoke printf, "    IA32_HRESET_ENABLE MSR bits: 0x%x %c", edi, 10
                
        bt edi, 0
        jnc .fin

        cinvoke printf, "      support for both HRESET’s EAX[0] parameter, and IA32_HRESET_ENABLE[0] %c", 10
        cinvoke printf, "      OS to enable reset of Intel® Thread Director history %c", 10

.fin:   ret

; =============================================================================================
; =============================================================================================
;
; As per the Intel docs:
;
; No existing or future CPU will return processor identification or feature information if the initial
; EAX value is 21H. If the value returned by CPUID.0:EAX (the maximum input value for basic CPUID
; information) is at least 21H, 0 is returned in the reg
;
; No existing or future CPU will return processor identification or feature information if the initial
; EAX value is in the range 40000000H to 4FFFFFFFH.
;
; As per the AMD docs:
;
; 40000000h to 400000FFh — Reserved for Hypervisor Use
; These function numbers are reserved for use by the virtual machine monitor.
;
; =============================================================================================
; =============================================================================================

; leaf 23h, ecx=0, data in eax, ebx, ecx (edx reserved)
; intel only

APMEMain:

        mov ecx, 0x01
        mov eax, 0x07           ; sub-leaf 1   
        cpuid
                
        bt eax, kArchPerfmonExt ; if set, then 23h is supported
        jc .go

        ret

.go:    mov esi, dword __Leaf2300
        call ShowLeafInformation

        cinvoke printf, "  Architectural Performance Monitoring Main Leaf %c", 10

        mov ecx, 0
        mov eax, 0x23
        cpuid

        mov [__APMESubLeafs], eax

        mov edi, ebx
        mov esi, ecx

.bb0:   bt edi, kUnitMask2
        jnc .bb1

        cinvoke printf, "    UnitMask2. Supports UnitMask2 field in IA32_PERFEVTSELx MSRs. %c", 10

.bb1:   bt edi, kEQBit
        jnc .bex

        cinvoke printf, "    EQ-bit. Supports the equal flag in the IA32_PERFEVTSELx MSRs %c", 10

.bex:   cinvoke printf, "    Number of Top-down Microarchitecture Analysis (TMA) slots per cycle: 0x%x %c", esi, 10
        cinvoke printf, "    This number can be multiplied by the number of cycles (from CPU_CLK_UNHALTED.THREAD / CPU_CLK_UNHALTED.CORE %c", 10
        cinvoke printf, "    or IA32_FIXED_CTR1) to determine the total number of slots. %c", 10

        mov eax, [__APMESubLeafs]

.sl1:   bt eax, 0
        jnc .sl2

        call APMESub1

        mov eax, [__APMESubLeafs]

.sl2:   bt eax, 1
        jnc .sl3

        call APMESub2

        mov eax, [__APMESubLeafs]

.sl3:   bt eax, 2
        jnc .fin
                
        call APMESub3

.fin:   ret

; =============================================================================================

; leaf 23h, ecx=1, data in eax, ebx (ecx/edx reserved)
; intel only

APMESub1:

        mov esi, dword __Leaf2301
        call ShowLeafInformation

        cinvoke printf, "  Architectural Performance Monitoring Extended Sub-Leaf 1 %c", 10

        mov ecx, 1
        mov eax, 0x23
        cpuid

        mov edi, eax
        mov esi, ebx

        cinvoke printf, "    General-purpose performance counters bitmap 0x%x %c", edi, 10
        cinvoke printf, "    Fixed-function performance counters bitmap 0x%x %c", esi, 10
                
        ret

; =============================================================================================

; leaf 23h, ecx=2, data in eax, ebx, ecx, edx
; intel only

APMESub2:

        mov esi, dword __Leaf2302
        call ShowLeafInformation

        cinvoke printf, "  Architectural Performance Monitoring Extended Sub-Leaf 2 %c", 10

        mov ecx, 2
        mov eax, 0x23
        cpuid

        mov edi, eax
        mov esi, ebx

        cinvoke printf, "    Auto Counter Reload (ACR) general counters that can be reloaded %c", 10
        cinvoke printf, "      for general-purpose performance monitoring counter 0x%x %c", edi, 10

        cinvoke printf, "    Auto Counter Reload (ACR) fixed counters that can be reloaded %c", 10
        cinvoke printf, "      for fixed-function performance monitoring counter 0x%x %c", esi, 10

        mov ecx, 2
        mov eax, 0x23
        cpuid

        mov edi, ecx
        mov esi, edx

        cinvoke printf, "    Auto Counter Reload (ACR) general counters that can cause reloads %c", 10
        cinvoke printf, "     for general-purpose performance monitoring counter 0x%x %c", edi, 10

        cinvoke printf, "    Auto Counter Reload (ACR) fixed counters that can cause reloads %c", 10
        cinvoke printf, "      for fixed-function performance monitoring counter 0x%x %c", esi, 10

        ret

; =============================================================================================

; leaf 23h, ecx=3, data in eax (ebx/ecx/edx reserved)
; intel only

APMESub3:

        mov esi, dword __Leaf2303
        call ShowLeafInformation

        cinvoke printf, "  Architectural Performance Monitoring Extended Sub-Leaf 3 %c", 10             
        cinvoke printf, "    APM supports the following events: %c", 10

        mov ecx, 3
        mov eax, 0x23
        cpuid

        mov edi, __APMES3

        mov esi, 0              ; bit counter

.loop:  bt  eax, esi
        jnc .nextb

        push eax
        cinvoke printf, "    %02d::%s %c", esi, edi, 10
        pop eax

.nextb: add edi, __APMES3Size

        inc esi

        cmp esi, 13

        jne .loop

        ret

; =============================================================================================

; leaf 24h, ecx=0, data in eax, ebx (ecx/edx reserved)
; intel only

ConvergedVectorISAMain:

        mov ecx, 0x01
        mov eax, 0x07           ; sub-leaf 1   
        cpuid
                
        bt edx, kAVX10          ; if set, then 24h is supported
        jc .go

        ret

.go:    mov esi, dword __Leaf2400
        call ShowLeafInformation

        cinvoke printf, "  Converged Vector ISA Main Leaf %c", 10

        mov ecx, 0
        mov eax, 0x24
        cpuid

        mov edi, eax
        mov esi, ebx

        cinvoke printf, "    Sub-leaves supported by 24h: %c", edi, 10

        mov edi, esi 

        and esi, 0x000000ff       ; bits 07-00

        cinvoke printf, "    Intel AVX10 Converged Vector ISA version 0x%x (%d) %c", esi, esi, 10

        mov esi, edi

.b16:   bt esi, k128BitVector
        jnc .b17

        cinvoke printf, "    128-bit vector support %c", 10

.b17:   bt esi, k256BitVector
        jnc .b18

        cinvoke printf, "    256-bit vector support %c", 10

.b18:   bt esi, k512BitVector
        jnc .fin

        cinvoke printf, "    512-bit vector support %c", 10

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
        push edx
        push ecx        

        mov edi, dword __AMDFeatureIdentifiers1
                        
.showc: mov esi, 0              ; bit counter

.cx:    bt  ecx, esi
        jnc .nxtc

        push ecx
        push edx
        cinvoke printf, "    %02d::%s %c", esi, edi, 10
        push edx
        pop ecx

.nxtc:  add edi, __AMDFeatureIdentifiers1Size

        inc esi

        cmp esi, 32             ; bits to check

        jne .cx

        mov esi, 0
        mov edi, dword __AMDFeatureIdentifiers2
                        
.showd: mov esi, 0

.dx:    bt  edx, esi
        jnc .nxtd

        push edx
        cinvoke printf, "    %02d::%s %c", esi, edi, 10
        push edx

.nxtd:  add edi, __AMDFeatureIdentifiers2Size

        inc esi

        cmp esi, 32             ; bits to text

        jne .dx

.fin:   ret

; =============================================================================================

; extended leaf 80000002h, data in eax, ebx, ecx, and edx
; intel and amd
BrandString:

        mov eax, 0x80000002                
        cpuid
                
        mov dword [__BrandString], eax
        mov dword [__BrandString + 4], ebx
        mov dword [__BrandString + 8], ecx
        mov dword [__BrandString + 12], edx
                
        mov eax, 0x80000003                
        cpuid
                
        mov dword [__BrandString + 16], eax
        mov dword [__BrandString + 20], ebx
        mov dword [__BrandString + 24], ecx
        mov dword [__BrandString + 28], edx
                
        mov eax, 0x80000004                
        cpuid
                
        mov dword [__BrandString + 32], eax
        mov dword [__BrandString + 36], ebx
        mov dword [__BrandString + 40], ecx
        mov dword [__BrandString + 44], edx
                
        cinvoke printf, "    %s %c", __BrandString, 10
                
        ret

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

; extended leaf 80000005h
; Intel only

; Reserved. EAX/EBX/ECX/EDX = 0
                  
; =============================================================================================
          
; extended leaf 80000006h, data in ecx
; Intel implementation
IntelCacheInformation:

        mov eax, dword [__MaxExtended]

        cmp eax, 0x80000006
        jl .notsupported
        
        mov esi, dword __Leaf80__06
        call ShowLeafInformation
        
        mov eax, 0x80000006
        cpuid

        mov esi, ecx

        cinvoke printf, "  Cache Information (ECX:0x%x) %c", esi, 10

        mov ecx, esi
        mov edi, esi

        and ecx, 0x000000FF

        cinvoke printf, "    Cache line size: %d bytes %c", ecx, 10

        mov ecx, edi

        shr ecx, 12
        and ecx, 0x0000000F

        mov esi, __IntelLevelTwoCache

        imul ecx, __IntelLevelTwoCacheSize
        add esi, ecx

        cinvoke printf, "    %s %c", esi, 10

        mov ecx, edi

        shr ecx, 16
        and ecx, 0x0000FFFF
                
        cinvoke printf, "    Cache size in 1K units: %d %c", ecx, 10

.notsupported:

.fin:   ret
                  
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

; extended leaf 80000007h, data in edx
; Intel implementation
InvariantTSC:

        mov eax, dword [__MaxExtended]

        cmp eax, 0x80000007
        jl .notsupported

        mov esi, dword __Leaf80__07
        call ShowLeafInformation

        mov eax, 0x80000007
        cpuid
                
        bt edx, kInvariantTSC
        jnc .notavailable
                
        cinvoke printf, "    Invariant TSC available %c", 10
                
        ret
                
.notavailable:

        cinvoke printf, "    Invariant TSC not available %c", 10
                
.notsupported:

        ret

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
        push edx

.nxtd:  add edi, __AMDAPMFeaturesSize

        inc esi

        cmp esi, 12             ; bits to text

        jne .dx

.notsupported:

        ret

; =============================================================================================

; extended leaf 80000008h, data in eax and ebx
; intel implementation
AddressBits:

        mov eax, dword [__MaxExtended]

        cmp eax, 0x80000008
        jl .notsupported

        mov esi, dword __Leaf80__08
        call ShowLeafInformation

        mov eax, 0x80000008
        cpuid

        mov edx, eax

        and eax, 0x000000FF     ; isolate bits 7:0 from eax

        shr edx, 8              ; isolate bits 15:08 from eax (copied to edx)
        and edx, 0x000000FF

        mov edi, ebx
                
        cinvoke printf, "    Physical Address Bits: %d; Linear Address Bits: %d %c", eax, edx, 10
                
        bt edi, kWBOINVD
        jnc .notsupported
                
        cinvoke printf, "    WBOINVD is available %c", 10

        ret

.notsupported:

        cinvoke printf, "    WBOINVD is not available %c", 10

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
        push ebx

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
section '.data' data readable writeable
; =============================================================================================
; =============================================================================================

__ShowDetail    db 0

__BrandIndex    db 0

__MaxBasic      dd 0
__MaxExtended   dd 0

__X2APICID      dd 0

__VendorID      db "            ",0
__BrandString   db "                                                ",0

__SteppingID    db 0
__Family        db 0
__FamilyExt     db 0
__Model         db 0
__ModelExt      db 0
__Cores         db 0

__System        dd 0
__Features1     dd 0
__Features2     dd 0
__APMESubLeafs  dd 0
__AMDPQOS       dd 0

__argc dd ?
__argv dd ?
__env dd ?


; =============================================================================================
; =============================================================================================
section '.data2' data readable
; =============================================================================================
; =============================================================================================

; 01h leaf, bits in ecx
__FeatureStringSize = 59                        ; 58 + null terminator
__FeatureString1:               db "SSE3       (Streaming SIMD Extensions 3)                  ", 0
                                db "PCLMULQDQ  (PCLMULQDQ instruction)                        ", 0
                                db "DTES64     (64-bit DS Area)                               ", 0
                                db "MONITOR    (MONITOR/MWAIT)                                ", 0
                                db "DS-CPL     (CPL Qualified Debug Store)                    ", 0
                                db "VMX        (Virtual Machine Extensions)                   ", 0
                                db "SMX        (Safer Mode Extensions)                        ", 0
                                db "EIST       (Enhanced Intel SpeedStep® technology)         ", 0
                                db "TM2        (Thermal Monitor 2)                            ", 0
                                db "SSSE3      (Supplemental Streaming SIMD Extensions 3)     ", 0
                                db "CNXT-ID    (L1 Context ID)                                ", 0
                                db "SDBG       (IA32_DEBUG_INTERFACE MSR)                     ", 0
                                db "FMA        (FMA extensions using YMM state)               ", 0
                                db "CMPXCHG16B (CMPXCHG16B Available)                         ", 0
                                db "xTPR       (xTPR Update Control)                          ", 0
                                db "PDCM       (Perfmon and Debug Capability)                 ", 0
                                db "Reserved                                                  ", 0
                                db "PCID       (Process-context identifiers)                  ", 0
                                db "DCA        (Prefetch data from a memory-mapped device)    ", 0
                                db "SSE4_1     (SSE4.1)                                       ", 0
                                db "SSE4_2     (SSE4.2)                                       ", 0
                                db "x2APIC     (x2APIC feature)                               ", 0
                                db "MOVBE      (instruction)                                  ", 0
                                db "POPCNT     (instruction)                                  ", 0
                                db "TSC        (TSC deadline)                                 ", 0
                                db "AESNI      (AESNI instruction extensions)                 ", 0
                                db "XSAVE      (XSAVE/XRSTOR processor extended states)       ", 0
                                db "OSXSAVE    (XSETBV/XGETBV instructions)                   ", 0
                                db "AVX        (AVX instruction extensions)                   ", 0
                                db "F16C       (16-bit floating-point conversion instructions)", 0
                                db "RDRAND     (RDRAND instruction)                           ", 0
                                db "Not used                                                  ", 0

; 01h leaf, bits in edx
__FeatureString2:               db "FPU-x87    (Floating-Point Unit On-Chip)                  ", 0
                                db "VME        (Virtual 8086 Mode Enhancements)               ", 0
                                db "DE         (Debugging Extensions)                         ", 0
                                db "PSE        (Page Size Extension)                          ", 0
                                db "TSC        (Time Stamp Counter)                           ", 0
                                db "MSR        (Model Specific Registers + RDMSR/WRMSR instr.)", 0
                                db "PAE        (Physical Address Extension)                   ", 0
                                db "MCE        (Machine Check Exception)                      ", 0
                                db "CX8        (CMPXCHG8B Instruction)                        ", 0
                                db "APIC       (APIC On-Chip)                                 ", 0
                                db "Reserved                                                  ", 0
                                db "SEP        (SYSENTER and SYSEXIT Instructions)            ", 0
                                db "MTRR       (Memory Type Range Registers)                  ", 0
                                db "PGE        (Page Global Bit)                              ", 0
                                db "MCA        (Machine Check Architecture)                   ", 0
                                db "CMOV       (Conditional Move Instructions)                ", 0
                                db "PAT        (Page Attribute Table)                         ", 0
                                db "PSE-36     (36-Bit Page Size Extension)                   ", 0
                                db "PSN        (Processor Serial Number)                      ", 0
                                db "CLFSH      (LFLUSH Instruction)                           ", 0
                                db "Reserved                                                  ", 0
                                db "DS         (Debug Store)                                  ", 0
                                db "ACPI       (Thermal Monitor and Software Controlled Clock)", 0
                                db "MMX        (Intel MMX Technology)                         ", 0
                                db "FXSR       (FXSAVE and FXRSTOR Instructions)              ", 0
                                db "SSE        (SSE extensions)                               ", 0
                                db "SSE2       (SSE2 extensions)                              ", 0
                                db "SS         (Self Snoop)                                   ", 0
                                db "HTT        (Max APIC IDs reserved field is Valid)         ", 0
                                db "TM         (Thermal Monitor)                              ", 0
                                db "Reserved                                                  ", 0
                                db "PBE        (Pending Break Enable)                         ", 0

; 02h leaf, data stored in eax, ebx, ecx, and edx
__CacheTlbValueTable            db 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E
                                db 0x1D 
                                db 0x21, 0x22, 0x23, 0x24, 0x25, 0x29, 0x2C
                                db 0x30
                                db 0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x4A, 0x4B, 0x4C, 0x4D, 0x4E, 0x4F
                                db 0x50, 0x51, 0x52, 0x55, 0x56, 0x57, 0x59, 0x5A, 0x5B, 0x5C, 0x5D
                                db 0x60, 0x61, 0x63, 0x64, 0x66, 0x67, 0x68, 0x6A, 0x6B, 0x6C, 0x6D
                                db 0x70, 0x71, 0x72, 0x76, 0x78, 0x79, 0x7A, 0x7B, 0x7C, 0x7D, 0x7F
                                db 0x80, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87
                                db 0xA0
                                db 0xB0, 0xB1, 0xB2, 0xB3, 0xB4, 0xB5, 0xB6, 0xBA
                                db 0xC0, 0xC1, 0xC2, 0xC3, 0xC4, 0xCA
                                db 0xD0, 0xD1, 0xD2, 0xD6, 0xD7, 0xD8, 0xDC, 0xDD, 0xDE
                                db 0xE2, 0xE3, 0xE4, 0xEA, 0xEB, 0xEC
                                db 0xF0, 0xF1
                                                                
__CacheTlbAddressTable          dd __S01, __S02, __S03, __S04, __S05, __S06, __S08, __S09, __S0A, __S0B, __S0C, __S0D, __S0E
                                dd __S1D 
                                dd __S21, __S22, __S23, __S24, __S25, __S29, __S2C
                                dd __S30
                                dd __S40, __S41, __S42, __S43, __S44, __S45, __S46, __S47, __S48, __S49, __S4A, __S4B, __S4C, __S4D, __S4E, __S4F
                                dd __S50, __S51, __S52, __S55, __S56, __S57, __S59, __S5A, __S5B, __S5C, __S5D
                                dd __S60, __S61, __S63, __S64, __S66, __S67, __S68, __S6A, __S6B, __S6C, __S6D
                                dd __S70, __S71, __S72, __S76, __S78, __S79, __S7A, __S7B, __S7C, __S7D, __S7F
                                dd __S80, __S82, __S83, __S84, __S85, __S86, __S87
                                dd __SA0
                                dd __SB0, __SB1, __SB2, __SB3, __SB4, __SB5, __SB6, __SBA
                                dd __SC0, __SC1, __SC2, __SC3, __SC4, __SCA
                                dd __SD0, __SD1, __SD2, __SD6, __SD7, __SD8, __SDC, __SDD, __SDE
                                dd __SE2, __SE3, __SE4, __SEA, __SEB, __SEC
                                dd __SF0, __SF1         

; 02h leaf text table
__S01                           db "TLB: 4 KByte pages, 4-way set associative, 32 entries", 0
__S02                           db "TLB: 4 MByte pages, fully associative, 2 entries", 0
__S03                           db "TLB: 4 KByte pages, 4-way set associative, 64 entries", 0
__S04                           db "TLB: 4 MByte pages, 4-way set associative, 8 entries", 0
__S05                           db "TLB1: 4 MByte pages, 4-way set associative, 32 entries", 0
__S06                           db "1st-level instruction cache: 8 KBytes, 4-way set associative, 32 byte line size", 0
__S08                           db "1st-level instruction cache: 16 KBytes, 4-way set associative, 32 byte line size", 0
__S09                           db "1st-level instruction cache: 32KBytes, 4-way set associative, 64 byte line size", 0
__S0A                           db "1st-level data cache: 8 KBytes, 2-way set associative, 32 byte line size", 0
__S0B                           db "TLB: 4 MByte pages, 4-way set associative, 4 entries", 0
__S0C                           db "1st-level data cache: 16 KBytes, 4-way set associative, 32 byte line size", 0
__S0D                           db "1st-level data cache: 16 KBytes, 4-way set associative, 64 byte line size", 0
__S0E                           db "1st-level data cache: 24 KBytes, 6-way set associative, 64 byte line size", 0
__S1D                           db "2nd-level cache: 128 KBytes, 2-way set associative, 64 byte line size", 0
__S21                           db "2nd-level cache: 256 KBytes, 8-way set associative, 64 byte line size", 0
__S22                           db "3rd-level cache: 512 KBytes, 4-way set associative, 64 byte line size, 2 lines per sector", 0
__S23                           db "3rd-level cache: 1 MBytes, 8-way set associative, 64 byte line size, 2 lines per sector", 0
__S24                           db "2nd-level cache: 1 MBytes, 16-way set associative, 64 byte line size", 0
__S25                           db "3rd-level cache: 2 MBytes, 8-way set associative, 64 byte line size, 2 lines per sector", 0
__S29                           db "3rd-level cache: 4 MBytes, 8-way set associative, 64 byte line size, 2 lines per sector", 0
__S2C                           db "1st-level data cache: 32 KBytes, 8-way set associative, 64 byte line size", 0
__S30                           db "1st-level instruction cache: 32 KBytes, 8-way set associative, 64 byte line size", 0
__S40                           db "No 2nd-level cache or, if processor contains a valid 2nd-level cache, no 3rd-level cache", 0
__S41                           db "2nd-level cache: 128 KBytes, 4-way set associative, 32 byte line size", 0
__S42                           db "2nd-level cache: 256 KBytes, 4-way set associative, 32 byte line size", 0
__S43                           db "2nd-level cache: 512 KBytes, 4-way set associative, 32 byte line size", 0
__S44                           db "2nd-level cache: 1 MByte, 4-way set associative, 32 byte line size", 0
__S45                           db "2nd-level cache: 2 MByte, 4-way set associative, 32 byte line size", 0
__S46                           db "3rd-level cache: 4 MByte, 4-way set associative, 64 byte line size", 0
__S47                           db "3rd-level cache: 8 MByte, 8-way set associative, 64 byte line size", 0
__S48                           db "2nd-level cache: 3MByte, 12-way set associative, 64 byte line size", 0
__S49                           db "3rd-level cache: 4MB, 16-way set associative, 64-byte line size (Intel Xeon processor MP, Family 0FH, Model 06H); 2nd-level cache: 4 MByte, 16-way set associative, 64 byte line size", 0
__S4A                           db "3rd-level cache: 6MByte, 12-way set associative, 64 byte line size", 0
__S4B                           db "3rd-level cache: 8MByte, 16-way set associative, 64 byte line size", 0
__S4C                           db "3rd-level cache: 12MByte, 12-way set associative, 64 byte line size", 0
__S4D                           db "3rd-level cache: 16MByte, 16-way set associative, 64 byte line size", 0
__S4E                           db "2nd-level cache: 6MByte, 24-way set associative, 64 byte line size", 0
__S4F                           db "TLB: 4 KByte pages, 32 entries", 0
__S50                           db "TLB: 4 KByte and 2-MByte or 4-MByte pages, 64 entries", 0
__S51                           db "TLB: 4 KByte and 2-MByte or 4-MByte pages, 128 entries", 0
__S52                           db "TLB: 4 KByte and 2-MByte or 4-MByte pages, 256 entries", 0
__S55                           db "TLB: 2-MByte or 4-MByte pages, fully associative, 7 entries", 0
__S56                           db "TLB0: 4 MByte pages, 4-way set associative, 16 entries", 0
__S57                           db "TLB0: 4 KByte pages, 4-way associative, 16 entries", 0
__S59                           db "TLB0: 4 KByte pages, fully associative, 16 entries", 0
__S5A                           db "TLB0: 2 MByte or 4 MByte pages, 4-way set associative, 32 entries", 0
__S5B                           db "TLB: 4 KByte and 4 MByte pages, 64 entries", 0
__S5C                           db "TLB: 4 KByte and 4 MByte pages,128 entries", 0
__S5D                           db "TLB: 4 KByte and 4 MByte pages,256 entries", 0
__S60                           db "1st-level data cache: 16 KByte, 8-way set associative, 64 byte line size", 0
__S61                           db "TLB: 4 KByte pages, fully associative, 48 entries", 0
__S63                           db "TLB: 2 MByte or 4 MByte pages, 4-way set associative, 32 entries and a separate array with 1 GByte pages, 4-way set associative, 4 entries", 0
__S64                           db "TLB: 4 KByte pages, 4-way set associative, 512 entries", 0
__S66                           db "1st-level data cache: 8 KByte, 4-way set associative, 64 byte line size", 0
__S67                           db "1st-level data cache: 16 KByte, 4-way set associative, 64 byte line size", 0
__S68                           db "1st-level data cache: 32 KByte, 4-way set associative, 64 byte line size", 0
__S6A                           db "uTLB: 4 KByte pages, 8-way set associative, 64 entries", 0
__S6B                           db "DTLB: 4 KByte pages, 8-way set associative, 256 entries", 0
__S6C                           db "DTLB: 2M/4M pages, 8-way set associative, 128 entries", 0
__S6D                           db "DTLB: 1 GByte pages, fully associative, 16 entries", 0
__S70                           db "Trace cache: 12 K-µop, 8-way set associative", 0
__S71                           db "Trace cache: 16 K-µop, 8-way set associative", 0
__S72                           db "Trace cache: 32 K-µop, 8-way set associative", 0
__S76                           db "TLB: 2M/4M pages, fully associative, 8 entries", 0
__S78                           db "2nd-level cache: 1 MByte, 4-way set associative, 64byte line size", 0
__S79                           db "2nd-level cache: 128 KByte, 8-way set associative, 64 byte line size, 2 lines per sector", 0
__S7A                           db "2nd-level cache: 256 KByte, 8-way set associative, 64 byte line size, 2 lines per sector", 0
__S7B                           db "2nd-level cache: 512 KByte, 8-way set associative, 64 byte line size, 2 lines per sector", 0
__S7C                           db "2nd-level cache: 1 MByte, 8-way set associative, 64 byte line size, 2 lines per sector", 0
__S7D                           db "2nd-level cache: 2 MByte, 8-way set associative, 64byte line size", 0
__S7F                           db "2nd-level cache: 512 KByte, 2-way set associative, 64-byte line size", 0
__S80                           db "2nd-level cache: 512 KByte, 8-way set associative, 64-byte line size", 0
__S82                           db "2nd-level cache: 256 KByte, 8-way set associative, 32 byte line size", 0
__S83                           db "2nd-level cache: 512 KByte, 8-way set associative, 32 byte line size", 0
__S84                           db "2nd-level cache: 1 MByte, 8-way set associative, 32 byte line size", 0
__S85                           db "2nd-level cache: 2 MByte, 8-way set associative, 32 byte line size", 0
__S86                           db "2nd-level cache: 512 KByte, 4-way set associative, 64 byte line size", 0
__S87                           db "2nd-level cache: 1 MByte, 8-way set associative, 64 byte line size", 0
__SA0                           db "DTLB: 4k pages, fully associative, 32 entries", 0
__SB0                           db "TLB: 4 KByte pages, 4-way set associative, 128 entries", 0
__SB1                           db "TLB: 2M pages, 4-way, 8 entries or 4M pages, 4-way, 4 entries", 0
__SB2                           db "TLB: 4KByte pages, 4-way set associative, 64 entries", 0
__SB3                           db "TLB: 4 KByte pages, 4-way set associative, 128 entries", 0
__SB4                           db "TLB1: 4 KByte pages, 4-way associative, 256 entries", 0
__SB5                           db "TLB: 4KByte pages, 8-way set associative, 64 entries", 0
__SB6                           db "TLB: 4KByte pages, 8-way set associative, 128 entries", 0
__SBA                           db "TLB1: 4 KByte pages, 4-way associative, 64 entries", 0
__SC0                           db "TLB: 4 KByte and 4 MByte pages, 4-way associative, 8 entries", 0
__SC1                           db "Shared 2nd-Level TLB: 4 KByte/2MByte pages, 8-way associative, 1024 entries", 0
__SC2                           db "DTLB: 4 KByte/2 MByte pages, 4-way associative, 16 entries", 0
__SC3                           db "Shared 2nd-Level TLB: 4 KByte /2 MByte pages, 6-way associative, 1536 entries. Also 1GBbyte pages, 4-way, 16 entries.", 0
__SC4                           db "DTLB: 2M/4M Byte pages, 4-way associative, 32 entries", 0
__SCA                           db "Shared 2nd-Level TLB: 4 KByte pages, 4-way associative, 512 entries", 0
__SD0                           db "3rd-level cache: 512 KByte, 4-way set associative, 64 byte line size", 0
__SD1                           db "3rd-level cache: 1 MByte, 4-way set associative, 64 byte line size", 0
__SD2                           db "3rd-level cache: 2 MByte, 4-way set associative, 64 byte line size", 0
__SD6                           db "3rd-level cache: 1 MByte, 8-way set associative, 64 byte line size", 0
__SD7                           db "3rd-level cache: 2 MByte, 8-way set associative, 64 byte line size", 0
__SD8                           db "3rd-level cache: 4 MByte, 8-way set associative, 64 byte line size", 0
__SDC                           db "3rd-level cache: 1.5 MByte, 12-way set associative, 64 byte line size", 0
__SDD                           db "3rd-level cache: 3 MByte, 12-way set associative, 64 byte line size", 0
__SDE                           db "3rd-level cache: 6 MByte, 12-way set associative, 64 byte line size", 0
__SE2                           db "3rd-level cache: 2 MByte, 16-way set associative, 64 byte line size", 0
__SE3                           db "3rd-level cache: 4 MByte, 16-way set associative, 64 byte line size", 0
__SE4                           db "3rd-level cache: 8 MByte, 16-way set associative, 64 byte line size", 0
__SEA                           db "3rd-level cache: 12MByte, 24-way set associative, 64 byte line size", 0
__SEB                           db "3rd-level cache: 18MByte, 24-way set associative, 64 byte line size", 0
__SEC                           db "3rd-level cache: 24MByte, 24-way set associative, 64 byte line size", 0
__SF0                           db "64-Byte prefetching", 0
__SF1                           db "128-Byte prefetching", 0                                                           

; 06h leaf, bits in eax
__ThermalPower1Size = 46        ; 45 + null terminator
__ThermalPower1:                db "Digital temperature sensor supported         ", 0
                                db "Intel Turbo Boost Technology                 ", 0
                                db "ARAT. APIC-Timer-always-running              ", 0
                                db "Reserved.                                    ", 0
                                db "PLN (Power limit notification controls)      ", 0
                                db "ECMD (Clock modulation duty cycle extension) ", 0
                                db "PTM (Package thermal management)             ", 0
                                db "HWP base registers                           ", 0
                                db "HWP_Notification                             ", 0
                                db "HWP_Activity_Window                          ", 0
                                db "HWP_Energy_Performance_Preference            ", 0
                                db "HWP_Package_Level_Request                    ", 0
                                db "Reserved.                                    ", 0
                                db "HDC. HDC base registers                      ", 0
                                db "Intel Turbo Boost Max Technology 3.0         ", 0
                                db "HWP Capabilities. Highest Performance change ", 0
                                db "HWP PECI override is supported if set        ", 0
                                db "Flexible HWP is supported if set.            ", 0
                                db "Fast access mode for the IA32_HWP_REQUEST MSR", 0
                                db "HW_FEEDBACK                                  ", 0
                                db "Ignoring Idle Logical Processor HWP request  ", 0
                                db "Reserved.                                    ", 0
                                db "HWP Control MSR support (IA32_HWP_CTL MSR)   ", 0
                                db "Intel® Thread Director supported             ", 0
                                db "IA32_THERM_INTERRUPT MSR bit 25 is supported ", 0
                                db "Reserved.                                    ", 0
                                db "Reserved.                                    ", 0
                                db "Reserved.                                    ", 0
                                db "Reserved.                                    ", 0
                                db "Reserved.                                    ", 0
                                db "Reserved.                                    ", 0
                                db "Reserved.                                    ", 0
                                                   
; 07h leaf (intel), bits in ebx
__StructuredExtendedFeatureFlags1Size = 45      ; 44 + null terminator
__StructuredExtendedFeatureFlags1:
                                db "FSGSBASE                                    ", 0
                                db "IA32_TSC_ADJUST MSR                         ", 0
                                db "SGX (Software Guard Extensions)             ", 0
                                db "BMI1                                        ", 0
                                db "HLE                                         ", 0
                                db "AVX2 (Intel Advanced Vector Extensions 2)   ", 0
                                db "FDP_EXCPTN_ONLY                             ", 0
                                db "SMEP (Supervisor-Mode Execution Prevention) ", 0 
                                db "BMI2                                        ", 0
                                db "Enhanced REP MOVSB/STOSB                    ", 0
                                db "INVPCID instruction                         ", 0  
                                db "RTM                                         ", 0
                                db "RDT-M                                       ", 0
                                db "Deprecates FPU CS and FPU DS                ", 0
                                db "MPX (Intel Memory Protection Extensions)    ", 0
                                db "RDT-A (Intel Resource Director Technology)  ", 0
                                db "AVX512F                                     ", 0
                                db "AVX512DQ                                    ", 0
                                db "RDSEED                                      ", 0
                                db "ADX                                         ", 0
                                db "SMAP (Supervisor-Mode Access Prevention)    ", 0
                                db "AVX512_IFMA                                 ", 0
                                db "Reserved                                    ", 0
                                db "CLFLUSHOPT                                  ", 0
                                db "CLWB                                        ", 0
                                db "Intel Processor Trace                       ", 0
                                db "AVX512PF (Intel Xeon Phi only)              ", 0
                                db "AVX512ER (Intel Xeon Phi only)              ", 0
                                db "AVX512CD                                    ", 0
                                db "SHA (Intel Secure Hash Algorithm Extensions)", 0
                                db "AVX512BW                                    ", 0
                                db "AVX512VL                                    ", 0

; 07h leaf (intel), bits in ecx
__StructuredExtendedFeatureFlags2Size = 50      ; 49 + null terminator
__StructuredExtendedFeatureFlags2:
                                db "PREFETCHWT1. Intel Xeon Phi only                 ", 0
                                db "AVX512_VBMI                                      ", 0
                                db "UMIP (user-mode instruction prevention           ", 0
                                db "PKU (protection keys for user-mode pages)        ", 0
                                db "OSPKE. CR4.PKE (and RDPKRU/WRPKRU)               ", 0
                                db "WAITPKG                                          ", 0
                                db "AVX512_VBMI2                                     ", 0
                                db "CET_SS                                           ", 0
                                db "GFNI                                             ", 0
                                db "VAES                                             ", 0
                                db "VPCLMULQDQ                                       ", 0
                                db "AVX512_VNNI                                      ", 0
                                db "AVX512_BITALG                                    ", 0
                                db "TIME_EN                                          ", 0
                                db "AVX512_VPOPCNTDQ                                 ", 0   
                                db "Reserved.                                        ", 0
                                db "LA57 (57-bit linear addresses and 5-level paging)", 0
                                db "Reserved.                                        ", 0
                                db "Reserved.                                        ", 0
                                db "Reserved.                                        ", 0
                                db "Reserved.                                        ", 0
                                db "Reserved.                                        ", 0
                                db "RDPID and IA32_TSC_AUX                           ", 0
                                db "KL (Key Locker)                                  ", 0
                                db "BUS_LOCK_DETECT, supports OS bus-lock detection  ", 0
                                db "CLDEMOTE (Supports cache line demote)            ", 0
                                db "Reserved                                         ", 0
                                db "MOVDIRI                                          ", 0
                                db "MOVDIR64B                                        ", 0
                                db "ENQCMD (Enqueue Stores)                          ", 0
                                db "SGX_LC (SGX Launch Configuration)                ", 0
                                db "PKS (protection keys for supervisor-mode pages)  ", 0
                                                                
; 07h leaf (intel), bits in edx
__StructuredExtendedFeatureFlags3Size = 35      ; 34 + null terminator
__StructuredExtendedFeatureFlags3:
                                db "Reserved                          ", 0
                                db "SGX-KEYS                          ", 0
                                db "AVX512_4VNNIW. Intel Xeon Phi only", 0
                                db "AVX512_4FMAPS. Intel Xeon Phi only", 0
                                db "Fast Short REP MOV                ", 0
                                db "UINTR                             ", 0
                                db "Reserved.                         ", 0
                                db "Reserved.                         ", 0
                                db "AVX512_VP2INTERSECT               ", 0
                                db "SRBDS_CTRL                        ", 0
                                db "MD_CLEAR                          ", 0
                                db "RTM_ALWAYS_ABORT                  ", 0
                                db "Reserved.                         ", 0
                                db "RTM_FORCE_ABORT                   ", 0
                                db "SERIALIZE                         ", 0
                                db "Hybrid                            ", 0
                                db "TSXLDTRK.                         ", 0
                                db "Reserved.                         ", 0
                                db "PCONFIG                           ", 0
                                db "Architectural LBRs                ", 0
                                db "CET_IBT                           ", 0
                                db "Reserved.                         ", 0
                                db "AMX-BF16                          ", 0
                                db "AVX512_FP16                       ", 0
                                db "AMX-TILE                          ", 0
                                db "AMX-INT8                          ", 0
                                db "IBRS and IBPB. IA32_SPEC_CTRL MSR ", 0
                                db "STIBP. IA32_SPEC_CTRL MSR         ", 0
                                db "L1D_FLUSH. IA32_FLUSH_CMD MSR     ", 0
                                db "IA32_ARCH_CAPABILITIES MSR        ", 0
                                db "IA32_CORE_CAPABILITIES MSR        ", 0
                                db "SSBD. IA32_SPEC_CTRL MSR          ", 0
                                                                
; 07h leaf (intel), bits in eax
__StructuredExtendedFeatureSubLeaf1aFlagsSize = 71      ; 70 + null terminator
__StructuredExtendedFeatureSubLeaf1aFlags:
                                db "SHA512.        SHA512 instructions supported                          ", 0
                                db "SM3.           SM3 instructions supported                             ", 0
                                db "SM4.           SM4 instructions supported                             ", 0
                                db "Reserved                                                              ", 0
                                db "AVX-VNNI.      AVX (VEX-encoded) versions of the VNNI                 ", 0
                                db "AVX512_BF16.   VNNI supports BFLOAT16 inputs and conversion           ", 0
                                db "LASS.          Supports Linear Address Space Separation               ", 0
                                db "CMPCCXADD.     Supports the CMPccXADD instruction                     ", 0
                                db "ArchPerfmonExt Supports ArchPerfmonExt, Leaf (EAX=23H)                ", 0
                                db "Reserved                                                              ", 0
                                db "REP MOVSB.     Fast zero-length instructions supported                ", 0
                                db "REP STOSB.     Supports fast short instructions                       ", 0
                                db "REP CMPSB, REP SCASB. Supports fast short instructions                ", 0
                                db "Reserved                                                              ", 0
                                db "Reserved                                                              ", 0
                                db "Reserved                                                              ", 0
                                db "Reserved                                                              ", 0
                                db "Reserved                                                              ", 0
                                db "Reserved                                                              ", 0
                                db "WRMSRNS.       WRMSRNS instruction supported                          ", 0
                                db "Reserved                                                              ", 0
                                db "AMX-FP16.      Supports tile computational operations on FP16 numbers ", 0
                                db "HRESET.        HRESET instruction and IA32_HRESET_ENABLE, Leaf 20H    ", 0
                                db "AVX-IFMA.      Supports the AVX-IFMA instructions                     ", 0
                                db "Reserved                                                              ", 0
                                db "Reserved                                                              ", 0
                                db "LAM.           Supports Linear Address Masking                        ", 0
                                db "MSRLIST        Supports RDMSRLIST and WRMSRLIST, IA32_BARRIER MSR     ", 0
                                db "Reserved                                                              ", 0
                                db "Reserved                                                              ", 0
                                db "INVD_DISABLE_POST_BIOS_DONE. INVD execution prevention after BIOS Done", 0
                                db "Reserved                                                              ", 0

; 07h leaf (intel), bits in edx
__StructuredExtendedFeatureSubLeaf1dFlagsSize = 55      ; 54 + null terminator
__StructuredExtendedFeatureSubLeaf1dFlags:
                                db "Reserved                                              ", 0
                                db "Reserved                                              ", 0
                                db "Reserved                                              ", 0
                                db "Reserved                                              ", 0
                                db "AVX-VNNI-INT8.  Supports AVX-VNNI-INT8 instructions   ", 0
                                db "AVX-NE-CONVERT. AVX-NE-CONVERT instructions           ", 0
                                db "Reserved                                              ", 0
                                db "Reserved                                              ", 0
                                db "Reserved                                              ", 0
                                db "Reserved                                              ", 0
                                db "AVX-VNNI-INT16. Supports AVX-VNNI-INT16 instructions  ", 0
                                db "Reserved                                              ", 0
                                db "Reserved                                              ", 0
                                db "Reserved                                              ", 0
                                db "PREFETCHI.      Supports PREFETCHIT0/1 instructions   ", 0
                                db "Reserved                                              ", 0
                                db "Reserved                                              ", 0
                                db "UIRET_UIF.      UIRET sets UIF to bit 1 of RFLAGS     ", 0
                                db "CET_SSS.        OS can enable supervisor shadow stacks", 0
                                db "AVX10.          Intel AVX10 instructions supported    ", 0
                                db "Reserved                                              ", 0
                                db "Reserved                                              ", 0
                                db "Reserved                                              ", 0
                                db "Reserved                                              ", 0
                                db "Reserved                                              ", 0
                                db "Reserved                                              ", 0
                                db "Reserved                                              ", 0
                                db "Reserved                                              ", 0
                                db "Reserved                                              ", 0
                                db "Reserved                                              ", 0
                                db "Reserved                                              ", 0
                                db "Reserved                                              ", 0

; 07h leaf (amd), bits in ebx
__AMDStructuredExtendedFeatureIDs1Size = 50     ; 48 + null terminator
__AMDStructuredExtendedFeatureIDs1:
                                db "FSGSBASE (FS and GS base read/write instruction)", 0
                                db "Reserved                                        ", 0
                                db "Reserved                                        ", 0
                                db "BMI1     (Bit manipulation group 1 instruction) ", 0
                                db "Reserved                                        ", 0
                                db "AVX2     (AVX2 instruction subset support)      ", 0
                                db "Reserved                                        ", 0
                                db "SMEP     (Supervisor mode execution prevention) ", 0
                                db "BMI2     (Bit manipulation group 2 instruction) ", 0
                                db "Reserved                                        ", 0
                                db "INVPCID  (instruction support)                  ", 0
                                db "Reserved                                        ", 0
                                db "PQM      (Platform QOS Monitoring)              ", 0 
                                db "Reserved                                        ", 0
                                db "Reserved                                        ", 0
                                db "PQE      (Platform QOS Enforcement)             ", 0
                                db "Reserved                                        ", 0
                                db "Reserved                                        ", 0
                                db "RDSEED   (instruction support)                  ", 0
                                db "ADX      (ADCX, ADOX instructions)              ", 0
                                db "SMAP     (Supervisor mode access prevention)    ", 0
                                db "Reserved                                        ", 0
                                db "Reserved                                        ", 0
                                db "CLFLUSHOPT (instruction support)                ", 0
                                db "CLWB     (instruction support)                  ", 0
                                db "Reserved                                        ", 0
                                db "Reserved                                        ", 0
                                db "Reserved                                        ", 0
                                db "Reserved                                        ", 0
                                db "SHA      (Secure Hash Algorithm instruction)    ", 0
                                db "Reserved                                        ", 0
                                db "Reserved                                        ", 0

; 07h leaf (amd), bits in ecx
__AMDStructuredExtendedFeatureIDs2Size = 48     ; 47 + null terminator
__AMDStructuredExtendedFeatureIDs2:
                                db "Reserved                                      ", 0
                                db "Reserved                                      ", 0
                                db "UMIP       (User mode instruction prevention) ", 0
                                db "PKU        (Memory Protection Keys supported  ", 0
                                db "OSPKE      (Memory Protection Keys enabled)   ", 0
                                db "Reserved                                      ", 0
                                db "Reserved                                      ", 0
                                db "CET_SS     (Shadow Stacks supported)          ", 0                               
                                db "Reserved                                      ", 0
                                db "VAES       (VAES 256-bit instructions)        ", 0
                                db "VPCMULQDQ  (VPCLMULQDQ 256-bit instruction    ", 0
                                db "Reserved                                      ", 0
                                db "Reserved                                      ", 0
                                db "Reserved                                      ", 0
                                db "Reserved                                      ", 0
                                db "Reserved                                      ", 0
                                db "LA57       (5-Level paging support)           ", 0
                                db "Reserved                                      ", 0
                                db "Reserved                                      ", 0
                                db "Reserved                                      ", 0
                                db "Reserved                                      ", 0
                                db "Reserved                                      ", 0
                                db "RDPID      (RDPID instruction and TSC_AUX MSR)", 0
                                db "Reserved                                      ", 0
                                db "BUSLOCKTRAP (Bus Lock Trap (#DB))             ", 0
                                db "Reserved                                      ", 0
                                db "Reserved                                      ", 0
                                db "Reserved                                      ", 0
                                db "Reserved                                      ", 0
                                db "Reserved                                      ", 0
                                db "Reserved                                      ", 0
                                db "Reserved                                      ", 0

; 0dh, eax[18:00]
__ProcExtStateEnumMainSize = 30 ; 29 + null terminator
__ProcExtStateEnumMain:         db "X87 state                    ", 0
                                db "SSE state                    ", 0
                                db "AVX state                    ", 0
                                db "BNDREG    (MPX state)        ", 0
                                db "BNDCSR    (MPX state)        ", 0
                                db "opmask    (AVX-512 state)    ", 0
                                db "ZMM_hi256 (AVX-512 state)    ", 0
                                db "Hi16_ZMM  (AVX-512 state)    ", 0
                                db "IA32_XSS state               ", 0
                                db "PKRU state                   ", 0
                                db "ENQCMD    (used for IA32_XSS)", 0
                                db "CETU      (used for IA32_XSS)", 0
                                db "CETS      (used for IA32_XSS)", 0
                                db "HDC       (used for IA32_XSS)", 0
                                db "UINTR     (used for IA32_XSS)", 0
                                db "ALBR      (used for IA32_XSS)", 0
                                db "HWP       (used for IA32_XSS)", 0
                                db "TILECFG state                ", 0
                                db "TILEDATA state               ", 0
                                                                
; 12h ecx = 2, ecx[03:00]
__SGXEPCSubLeaf2Size = 67       ; 66 + null terminator
__SGXEPCSubLeaf2:               db "This section has confidentiality, integrity, and replay protection", 0
                                db "This section has confidentiality protection only                  ", 0
                                db "This section has confidentiality and integrity protection         ", 0
                                                                

; 18h, edx[04:00]
__DATCacheTypeSize = 13         ; 12 + null terminator
__DATCacheType:                 db "Unknown    :", 0
                                db "Data       :", 0
                                db "Instruction:", 0
                                db "Unified    :", 0
                                db "Load Only  :", 0
                                db "Store Only :", 0

; 1fh, ecx[15:08]
__LevelTypeSize = 8             ; 7 + null terminator
__LevelType:                    db "Invalid", 0
                                db "Logical", 0
                                db "Core   ", 0
                                db "Module ", 0
                                db "Tile   ", 0
                                db "Die    ", 0
                                db "Die/Grp", 0

; 23h, ecx=3; eax[12:00]
__APMES3Size = 28               ; 27 + null terminator
__APMES3:                       db "Core cycles                ", 0 
                                db "Instructions retired       ", 0
                                db "Reference cycles           ", 0
                                db "Last level cache references", 0
                                db "Last level cache misses    ", 0
                                db "Branch instructions retired", 0
                                db "Branch mispredicts retired ", 0
                                db "Topdown slots              ", 0
                                db "Topdown backend bound      ", 0
                                db "Topdown bad speculation    ", 0
                                db "Topdown frontend bound     ", 0
                                db "Topdown retiring           ", 0
                                db "LBR inserts                ", 0

; AMD: 80000001_ECX
__AMDFeatureIdentifiers1Size = 70 ; 69 + null terminator
__AMDFeatureIdentifiers1:       db "LahfSahf           (LAHF/SAHF instruction support in 64-bit mode)    ", 0
                                db "CmpLegacy          (Core multi-processing legacy mode)               ", 0
                                db "SVM                (Secure virtual machine)                          ", 0
                                db "ExtApicSpace       (Extended APIC space)                             ", 0
                                db "AltMovCr8          (LOCK MOV CR0 means MOV CR8)                      ", 0
                                db "ABM                (Advanced bit manipulation. LZCNT instruction)    ", 0
                                db "SSE4A              (EXTRQ/INSERTQ/MOVNTSS/MOVNTSD instruction)       ", 0
                                db "MisAlignSse        (Misaligned SSE mode)                             ", 0
                                db "3DNowPrefetch      (PREFETCH and PREFETCHW instruction support)      ", 0
                                db "OSVW               (OS visible workaround)                           ", 0
                                db "IBS                (Instruction based sampling)                      ", 0
                                db "XOP                (Extended operation support)                      ", 0
                                db "SKINIT             (SKINIT and STGI are supported)                   ", 0
                                db "WDT                (Watchdog timer support)                          ", 0
                                db "Reserved                                                             ", 0
                                db "LWP                (Lightweight profiling support)                   ", 0
                                db "FMA4               (Four-operand FMA instruction support)            ", 0
                                db "TCE                (Translation Cache Extension support)             ", 0
                                db "Reserved                                                             ", 0
                                db "Reserved                                                             ", 0
                                db "Reserved                                                             ", 0
                                db "TBM                (Trailing bit manipulation instruction support)   ", 0
                                db "TopologyExtensions (Topology extensions support)                     ", 0
                                db "PerfCtrExtCore     (Processor performance counter extensions support)", 0
                                db "PerfCtrExtNB       (NB performance counter extensions support)       ", 0
                                db "Reserved                                                             ", 0
                                db "DataBkptExt        (Data access breakpoint extension)                ", 0
                                db "PerfTsc            (Performance time-stamp counter)                  ", 0
                                db "PerfCtrExtLLC      (Support for L3 performance counter extension)    ", 0
                                db "MONITORX           (Support for MWAITX and MONITORX instructions)    ", 0
                                db "AddrMaskExt        (Breakpoint Addressing masking extended to bit 31)", 0
                                db "Reserved                                                             ", 0

; AMD: 80000001_EDX
__AMDFeatureIdentifiers2Size = 64               ; 63 + null terminator
__AMDFeatureIdentifiers2:       db "FPU x87            (x87 floating-point unit on-chip)           ", 0
                                db "VME                (Virtual-mode enhancements)                 ", 0
                                db "DE                 (Debugging extensions)                      ", 0
                                db "PSE                (Page-size extensions)                      ", 0
                                db "TSC                (Time stamp counter)                        ", 0
                                db "MSR                (AMD model-specific registers)              ", 0
                                db "PAE                (Physical-address extensions)               ", 0
                                db "MCE                (Machine check exception)                   ", 0
                                db "CMPXCHG8B          (instruction)                               ", 0
                                db "APIC               (Advanced programmable interrupt controller)", 0
                                db "Reserved                                                       ", 0
                                db "SysCallSysRet      (SYSCALL and SYSRET instructions)           ", 0
                                db "MTRR               (Memory-type range registers)               ", 0
                                db "PGE                (Page global extension)                     ", 0
                                db "MCA                (Machine check architecture)                ", 0
                                db "CMOV               (Conditional move instructions)             ", 0
                                db "PAT                (Page attribute table)                      ", 0
                                db "PSE36              (Page-size extensions)                      ", 0
                                db "Reserved                                                       ", 0
                                db "Reserved                                                       ", 0
                                db "NX                 (No-execute page protection)                ", 0
                                db "Reserved                                                       ", 0
                                db "MmxExt             (AMD extensions to MMX instructions)        ", 0
                                db "MMX                (MMX(TM) instructions)                      ", 0
                                db "FXSR               (FXSAVE/FXRSTOR instructions)               ", 0
                                db "FFXSR              (FXSAV/FXRSTOR instruction optimizations)   ", 0
                                db "Page1GB            (1-GB large page support)                   ", 0
                                db "RDTSCP             (RDTSCP instruction)                        ", 0
                                db "Reserved                                                       ", 0
                                db "LM                 (Long mode)                                 ", 0
                                db "3DNowExt           (AMD extensions to 3DNow! instructions)     ", 0
                                db "3DNow              (3DNow!(TM) instructions)                   ", 0

; Intel 0x80000006; ecx, bits 12-15
__IntelLevelTwoCacheSize = 19   ; 18 + null terminator
__IntelLevelTwoCache:           db "Disabled          ", 0
                                db "1 way (direct map)", 0
                                db "2 ways            ", 0
                                db "Reserved          ", 0
                                db "4 ways            ", 0
                                db "Reserved          ", 0
                                db "8 ways            ", 0
                                db "See leaf 04h      ", 0 
                                db "16 ways           ", 0
                                db "Reserved          ", 0
                                db "32 ways           ", 0
                                db "48 ways           ", 0
                                db "64 ways           ", 0
                                db "96 ways           ", 0
                                db "128 ways          ", 0
                                db "Fully associative ", 0

; AMD; 80000006
__AMDLevelTwoTLBSize = 31       ; 30 + null terminator
__AMDLevelTwoTLB:               db "L2/L3 cache or TLB is disabled", 0
                                db "Direct mapped                 ", 0
                                db "2-way associative             ", 0
                                db "3-way associative             ", 0
                                db "4 to 5-way associative        ", 0
                                db "6 to 7-way associative        ", 0
                                db "8 to 15-way associative       ", 0
                                db "Permanently reserved          ", 0
                                db "16 to 31-way associative      ", 0
                                db "Determined from Fn8000_001D   ", 0
                                db "32 to 47-way associative      ", 0
                                db "48 to 63-way associative      ", 0
                                db "64 to 95-way associative      ", 0
                                db "96 to 127-way associative     ", 0
                                db ">128-way not fully associative", 0
                                db "Fully associative             ", 0

; AMD; 80000007_EDX
__AMDAPMFeaturesSize = 29       ; 28 + null terminator
__AMDAPMFeatures:               db "TS, Temperature sensor      ", 0
                                db "FID, Frequency ID control   ", 0
                                db "VID, Voltage ID control     ", 0
                                db "TTP, THERMTRIP              ", 0
                                db "TM, Hardware thermal control", 0
                                db "Reserved                    ", 0
                                db "100MHzSteps                 ", 0
                                db "HwPstate. MSRC001_0061      ", 0
                                db "TscInvariant                ", 0
                                db "CPB, Core performance boost ", 0
                                db "EffFreqRO                   ", 0
                                db "ProcFeedbackInterface       ", 0
                                db "ProcPowerReporting          ", 0
                                                                
; AMD; 80000008_EBX
__AMDExtendedFeatureIDSize = 61 ; 60 + null terminator
__AMDExtendedFeatureID:         db "CLZERO (instruction)                                        ", 0
                                db "InstRetCntMsr (Instruction Retired Counter MSR)             ", 0
                                db "RstrFpErrPtrs (FP Error Pointers Restored by XRSTOR)        ", 0
                                db "INVLPGB (INVLPGB TLBSYNC instructions)                      ", 0
                                db "RDPRU (instruction)                                         ", 0
                                db "Reserved                                                    ", 0
                                db "BE (Bandwidth Enforcement Extension)                        ", 0
                                db "Reserved                                                    ", 0
                                db "MCOMMIT (instruction)                                       ", 0
                                db "WBNOINVD (instruction)                                      ", 0
                                db "Reserved                                                    ", 0
                                db "Reserved                                                    ", 0
                                db "IBPB (Indirect Branch Prediction Barrier)                   ", 0
                                db "INT_WBINVD (WBINVD/WBNOINVD are interruptible)              ", 0
                                db "IBRS (Indirect Branch Restricted Speculation)               ", 0
                                db "STIBP (Single Thread Indirect Branch Prediction mode)       ", 0
                                db "IbrsAlwaysOn (Processor prefers that IBRS be left on)       ", 0
                                db "StibpAlwaysOn (Processor prefers that STIBP be left on)     ", 0
                                db "IbrsPreferred (IBRS is preferred over software solution)    ", 0
                                db "IbrsSameMode (IBRS provides same mode speculation limits)   ", 0
                                db "EferLmsleUnsupported (EFER.LMSLE is unsupported)            ", 0
                                db "INVLPGBnestedPages (INVLPGB suppor)                         ", 0
                                db "Reserved                                                    ", 0
                                db "Reserved                                                    ", 0
                                db "SSBD (Speculative Store Bypass Disable)                     ", 0
                                db "SsbdVirtSpecCtrl (Use VIRT_SPEC_CTL for SSBD)               ", 0
                                db "SsbdNotRequired (SSBD not needed on this processor)         ", 0
                                db "CPPC (Collaborative Processor Performance Control.          ", 0
                                db "PSFD (Predictive Store Forward Disable)                     ", 0
                                db "BTC_NO (Not affected by branch type confusion)              ", 0
                                db "IBPB_RET (clears return address predictor MSR PRED_CMD.IBPB)", 0
                                db "Reserved                                                    ", 0
                                                               
; AMD; 80000008_ECX
__AMDSizeIndentifiersDescriptionSize = 8        ; 7 + null terminator
__AMDSizeIndentifiersDescription:
                                db "40 bits", 0
                                db "48 bits", 0
                                db "56 bits", 0
                                db "64 bits", 0
                                                                                                                           
; AMD; 8000000A_EDX
__SVMFeatureInformationSize = 71; 70 + null terminator
__SVMFeatureInformation:        db "NP (Nested paging)                                                    ", 0
                                db "LbrVirt (LBR virtualization)                                          ", 0
                                db "SVML (SVM lock)                                                       ", 0
                                db "NRIPS (NRIP save)                                                     ", 0
                                db "TscRateMsr (MSR based TSC rate control)                               ", 0
                                db "VmcbClean (VMCB clean bits)                                           ", 0
                                db "FlushByAsid (Flush by ASID)                                           ", 0
                                db "DecodeAssists (Decode assists)                                        ", 0
                                db "PmcVirt (PMC virtualization)                                          ", 0
                                db "Reserved                                                              ", 0
                                db "PauseFilter (Pause intercept filter)                                  ", 0
                                db "Reserved                                                              ", 0
                                db "PauseFilterThreshold (PAUSE filter threshold)                         ", 0
                                db "AVIC (Support AMD advanced virtual interrupt controller)              ", 0
                                db "Reserved                                                              ", 0
                                db "VMSAVEvirt (VMSAVE and VMLOAD virtualization)                         ", 0
                                db "VGIF (Virtualize the Global Interrupt Flag)                           ", 0
                                db "GMET (Guest Mode Execution Trap)                                      ", 0
                                db "x2AVIC (Support AMD advanced virtual interrupt controller x2APIC mode)", 0
                                db "SSSCheck (SVM supervisor shadow stack restrictions)                   ", 0
                                db "SpecCtrl (SPEC_CTRL virtualization)                                   ", 0
                                db "ROGPT (Read-Only Guest Page Table feature support)                    ", 0
                                db "Reserved                                                              ", 0
                                db "HOST_MCE_OVERRIDE                                                     ", 0
                                db "TlbiCtl (INVLPGB/TLBSYNC hypervisor enable)                           ", 0
                                db "VNMI (NMI Virtualization)                                             ", 0
                                db "IbsVirt (IBS Virtualization)                                          ", 0
                                db "ExtLvtAvicAccessChg                                                   ", 0
                                db "NestedVirtVmcbAddrChk (Guest VMCB address check)                      ", 0
                                db "BusLockThreshold (Bus Lock Threshold)                                 ", 0
                                db "IdleHltIntercept (Idle HLT intercept)                                 ", 0
                                db "Reserved                                                              ", 0

; AMD; 8000001B_EAX
__IBSFeaturesSize = 57          ; 56 + null terminator
__IBSFeatures:                  db "IBSFFV (IBS feature flags valid)                        ", 0
                                db "FetchSam (IBS fetch sampling supported)                 ", 0
                                db "OpSam (IBS execution sampling supported)                ", 0
                                db "RdWrOpCnt (Read write of op counter supported)          ", 0
                                db "OpCnt (Op counting mode supported)                      ", 0
                                db "BrnTrgt (Branch target address reporting)               ", 0
                                db "OpCntExt (IbsOpCurCnt and IbsOpMaxCnt extend by 7 bits) ", 0
                                db "RipInvalidChk (Invalid RIP indication supported)        ", 0
                                db "OpBrnFuse (Fused branch micro-op indication supported)  ", 0
                                db "Reserved                                                ", 0
                                db "Reserved                                                ", 0
                                db "IbsL3MissFiltering (L3 Miss Filtering for IBS supported)", 0
                                                                
; AMD; 8000001C_EAX             
__AMDLWPEAXSize = 56            ; 55 + null terminator
__AMDLWPEAX:                    db "LwpAvail. The LWP feature is supported                 ", 0
                                db "LwpVAL.   LWPVAL instruction                           ", 0
                                db "LwpIRE.   Instructions retired event                   ", 0
                                db "LwpBRE.   Branch retired event                         ", 0
                                db "LwpDME.   DC miss event                                ", 0
                                db "LwpCNH.   Core clocks not halted event                 ", 0
                                db "LwpRNH.   Core reference clocks not halted event       ", 0
                                db "Reserved                                               ", 0
                                db "Reserved                                               ", 0
                                db "Reserved                                               ", 0
                                db "Reserved                                               ", 0
                                db "Reserved                                               ", 0
                                db "Reserved                                               ", 0
                                db "Reserved                                               ", 0
                                db "Reserved                                               ", 0
                                db "Reserved                                               ", 0
                                db "Reserved                                               ", 0
                                db "Reserved                                               ", 0
                                db "Reserved                                               ", 0
                                db "Reserved                                               ", 0
                                db "Reserved                                               ", 0
                                db "Reserved                                               ", 0
                                db "Reserved                                               ", 0
                                db "Reserved                                               ", 0
                                db "Reserved                                               ", 0
                                db "Reserved                                               ", 0
                                db "Reserved                                               ", 0
                                db "Reserved                                               ", 0
                                db "Reserved                                               ", 0
                                db "LwpCont. Sampling in continuous mode                   ", 0
                                db "LwpPTSC. Performance time stamp counter in event record", 0
                                db "LwpInt.  Interrupt on threshold overflow               ", 0

; AMD; 8000001C_EDX
__AMDLWPEDXSize = 55            ; 54 + null terminator                    
__AMDLWPEDX:                    db "LwpAvail Lightweight profiling                        ", 0
                                db "LwpVAL LWPVAL instruction                             ", 0
                                db "LwpIRE Instructions retired event                     ", 0
                                db "LwpBRE Branch retired event                           ", 0
                                db "LwpDME DC miss event                                  ", 0
                                db "LwpCNH Core clocks not halted event is supported      ", 0
                                db "LwpRNH Core reference clocks not halted event         ", 0
                                db "Reserved                                              ", 0
                                db "Reserved                                              ", 0
                                db "Reserved                                              ", 0
                                db "Reserved                                              ", 0
                                db "Reserved                                              ", 0
                                db "Reserved                                              ", 0
                                db "Reserved                                              ", 0
                                db "Reserved                                              ", 0
                                db "Reserved                                              ", 0
                                db "Reserved                                              ", 0
                                db "Reserved                                              ", 0
                                db "Reserved                                              ", 0
                                db "Reserved                                              ", 0
                                db "Reserved                                              ", 0
                                db "Reserved                                              ", 0
                                db "Reserved                                              ", 0
                                db "Reserved                                              ", 0
                                db "Reserved                                              ", 0
                                db "Reserved                                              ", 0
                                db "Reserved                                              ", 0
                                db "Reserved                                              ", 0
                                db "Reserved                                              ", 0
                                db "LwpCont Sampling in continuous mode                   ", 0
                                db "LwpPTSC Performance time stamp counter in event record", 0
                                db "LwpInt  Interrupt on threshold overflow               ", 0

; AMD; 8000001F_EAX
__AMDSecureEncryptionSize = 77  ; 76 + null terminator
__AMDSecureEncryption:          db "SME (Secure Memory Encryption)                                              ", 0
                                db "SEV (Secure Encrypted Virtualization)                                       ", 0
                                db "PageFlushMsr (Page Flush MSR available)                                     ", 0
                                db "SEV-ES (SEV Encrypted State)                                                ", 0
                                db "SEV-SNP (SEV Secure Nested Paging)                                          ", 0
                                db "VMPL (VM Permission Levels)                                                 ", 0
                                db "RMPQUERY (RMPQUERY Instruction)                                             ", 0
                                db "VmplSSS (VMPL Supervisor Shadow Stack)                                      ", 0
                                db "SecureTsc (Secure TSC)                                                      ", 0
                                db "TscAuxVirtualization (TSC AUX Virtualization)                               ", 0
                                db "HwEnfCacheCoh (Hardware cache coherency across encryption domains enforced) ", 0
                                db "64BitHost (SEV guest execution only allowed from a 64-bit host)             ", 0
                                db "RestrictedInjection (Restricted Injection)                                  ", 0
                                db "AlternateInjection (Alternate Injection)                                    ", 0
                                db "DebugVirt (Full debug state virtualization)                                 ", 0
                                db "PreventHostIbs (Disallowing IBS use by the host)                            ", 0
                                db "VTE (Virtual Transparent Encryption)                                        ", 0
                                db "VmgexitParameter (VMGEXIT Parameter)                                        ", 0
                                db "VirtualTomMsr (Virtual TOM MSR)                                             ", 0
                                db "IbsVirtGuestCtl (IBS Virtualization)                                        ", 0
                                db "PmcVirtGuestCtl (PMC Virtualization)                                        ", 0
                                db "RMPREAD (Instruction)                                                       ", 0
                                db "Reserved                                                                    ", 0
                                db "Reserved                                                                    ", 0
                                db "VmsaRegProt (VMSA Register Protection)                                      ", 0
                                db "SmtProtection (SMT Protection)                                              ", 0
                                db "SecureAvic (Secure AVIC)                                                    ", 0
                                db "AllowedSevFeatures (Allowed SEV Features)                                   ", 0
                                db "SvsmCommPageMSR (SVSM Communication Page MSR)                               ", 0
                                db "NestedVirtSnpMsr (VIRT_RMPUPDATE MSR0)                                      ", 0
                                db "HvInUseWrAllowed (Writes to Hypervisor-Owned pages allowed if marked in-use)", 0
                                db "IbpbOnEntry (IBPB on Entry)                                                 ", 0

; AMD; 80000020_EBX
__AMDPQOSExtendedFeaturesSize = 49          ; 48 + null terminator
__AMDPQOSExtendedFeatures:      
                                db "Reserved                                        ", 0
                                db "L3MBE   Memory Bandwidth Enforcement            ", 0
                                db "L3SMBE  Slow Memory Bandwidth Enforcement       ", 0
                                db "BMEC    Bandwidth Monitoring Event Config       ", 0
                                db "L3RR    L3 Range Reservations                   ", 0
                                db "ABMC    Assignable Bandwidth Monitoring Counters", 0
                                db "SDCIAE  Smart Data Cache Injection              ", 0

; AMD; 80000020 ECX = 3, ECX
__AMDPQOSExtendedFeaturesBMECSize = 24       ; 23 + null terminator
__AMDPQOSExtendedFeaturesBMEC:  
                                db "L3CacheLclBwFillMon    ", 0
                                db "L3CacheRmtBwFillMon    ", 0
                                db "L3CacheLclBwNtWrMon    ", 0
                                db "L3CacheRmtBwNtWrMon    ", 0
                                db "L3CacheLclSlowBwFIllMon", 0
                                db "L3CacheRmtSlowBwFIllMon", 0
                                db "L3CacheVicMon          ", 0

; AMD; 80000021_EAX
__AMDExtendedFeatureIdentifiers2Size = 66       ; 65 + null terminator
__AMDExtendedFeatureIdentifiers2:
                                db "NoNestedDataBp          Processor ignores nested data breakpoints", 0
                                db "Reserved                                                         ", 0
                                db "LFenceAlwaysSerializing LFENCE is always dispatch serializing    ", 0
                                db "SmmPgCfgLock            SMM paging configuration lock supported  ", 0
                                db "Reserved                                                         ", 0
                                db "Reserved                                                         ", 0
                                db "NullSelectClearsBase    Null segment selector loads clear dest.  ", 0
                                db "UpperAddressIgnore      Upper Address Ignore is supported        ", 0
                                db "AutomaticIBRS           Automatic IBRS                           ", 0
                                db "NoSmmCtlMSR             SMM_CTL MSR (C001_0116h) is not supported", 0
                                db "Reserved                                                         ", 0
                                db "Reserved                                                         ", 0
                                db "Reserved                                                         ", 0
                                db "PrefetchCtlMsr          Prefetch control MSR supported           ", 0
                                db "Reserved                                                         ", 0
                                db "Reserved                                                         ", 0
                                db "Reserved                                                         ", 0
                                db "CpuidUserDis            CPUID disable for non-privileged software", 0
                                                                
; AMD; 80000026_ECX
__AMDLevelTypeSize = 8 ; 7 + null terminator
__AMDLevelType:                 db "Core   ", 0
                                db "Complex", 0
                                db "Die    ", 0
                                db "Socket ", 0

; =============================================================================================
; =============================================================================================
; =============================================================================================

__LeafInvalid:                  db "  Invalid", 0
__Leaf01ECX:                    db "(Leaf 01h (from ecx))", 0
__Leaf01EDX:                    db "(Leaf 01h (from edx))", 0
__Leaf02:                       db "(Leaf 02h)", 0
__Leaf0400:                     db "(Leaf 04h, ecx = 0x00)", 0
__Leaf05:                       db "(Leaf 05h)", 0
__Leaf06:                       db "(Leaf 06h)", 0
__Leaf0700:                     db "(Leaf 07h, ecx = 0x00)", 0
__Leaf0701:                     db "(Leaf 07h, ecx = 0x01)", 0
__Leaf0702:                     db "(Leaf 07h, ecx = 0x02)", 0
__Leaf09:                       db "(Leaf 09h)", 0
__Leaf0A:                       db "(Leaf 0Ah)", 0
__Leaf0B00:                     db "(Leaf 0Bh, ecx = 0x00)", 0
__Leaf0B01:                     db "(Leaf 0Bh, ecx = 0x01)", 0
__Leaf0D00:                     db "(Leaf 0Dh, ecx = 0x00)", 0
__Leaf0D01:                     db "(Leaf 0Dh, ecx = 0x01)", 0
__Leaf0D02:                     db "(Leaf 0Dh, ecx = 0x02)", 0
__Leaf0D0B:                     db "(Leaf 0Dh, ecx = 0x0b)", 0
__Leaf0D0C:                     db "(Leaf 0Dh, ecx = 0x0c)", 0
__Leaf0D3E:                     db "(Leaf 0Dh, ecx = 0x3e)", 0
__Leaf0F00:                     db "(Leaf 0Fh, ecx = 0x00)", 0
__Leaf0F01:                     db "(Leaf 0Fh, ecx = 0x01)", 0
__Leaf1000:                     db "(Leaf 10h, ecx = 0x00)", 0
__Leaf1001:                     db "(Leaf 10h, ecx = 0x01)", 0
__Leaf1002:                     db "(Leaf 10h, ecx = 0x02)", 0
__Leaf1003:                     db "(Leaf 10h, ecx = 0x03)", 0
__Leaf1200:                     db "(Leaf 12h, ecx = 0x00)", 0
__Leaf1201:                     db "(Leaf 12h, ecx = 0x01)", 0
__Leaf1202:                     db "(Leaf 12h, ecx = 0x02)", 0
__Leaf1400:                     db "(Leaf 14h, ecx = 0x00)", 0
__Leaf1401:                     db "(Leaf 14h, ecx = 0x01)", 0
__Leaf15:                       db "(Leaf 15h)", 0
__Leaf16:                       db "(Leaf 16h)", 0
__Leaf1700:                     db "(Leaf 17h, ecx = 0x00)", 0
__Leaf18:                       db "(Leaf 18h)", 0
__Leaf19:                       db "(Leaf 19h)", 0
__Leaf1A00:                     db "(Leaf 1Ah, ecx = 0x00)", 0
__Leaf1B00:                     db "(Leaf 1Bh, ecx = 0x00)", 0
__Leaf1C00:                     db "(Leaf 1Ch, ecx = 0x00)", 0
__Leaf1D00:                     db "(Leaf 1Dh, ecx = 0x00)", 0
__Leaf1D01:                     db "(Leaf 1Dh, ecx = 0x01)", 0
__Leaf1E00:                     db "(Leaf 1Eh, ecx = 0x00)", 0
__Leaf1F00:                     db "(Leaf 1Fh, ecx = 0x00)", 0
__Leaf20:                       db "(Leaf 20h)", 0
__Leaf2300:                     db "(Leaf 23h, ecx = 0x00)", 0
__Leaf2301:                     db "(Leaf 23h, ecx = 0x01)", 0
__Leaf2302:                     db "(Leaf 23h, ecx = 0x02)", 0
__Leaf2303:                     db "(Leaf 23h, ecx = 0x03)", 0
__Leaf2400:                     db "(Leaf 24h, ecx = 0x00)", 0
__Leaf80__01:                   db "(Leaf 80000001h)", 0
__Leaf80__02:                   db "(Leaf 80000002h)", 0
__Leaf80__05:                   db "(Leaf 80000005h)", 0
__Leaf80__06:                   db "(Leaf 80000006h)", 0
__Leaf80__07:                   db "(Leaf 80000007h)", 0
__Leaf80__08:                   db "(Leaf 80000008h)", 0
__Leaf80__0A:                   db "(Leaf 8000000Ah)", 0
__Leaf80__0F:                   db "(Leaf 8000000Fh)", 0
__Leaf80__19:                   db "(Leaf 80000019h)", 0
__Leaf80__1A:                   db "(Leaf 8000001Ah)", 0
__Leaf80__1B:                   db "(Leaf 8000001Bh)", 0
__Leaf80__1C:                   db "(Leaf 8000001Ch)", 0
__Leaf80__1D:                   db "(Leaf 8000001Dh)", 0
__Leaf80__1E:                   db "(Leaf 8000001Eh)", 0
__Leaf80__1F:                   db "(Leaf 8000001Fh)", 0
__Leaf80__20:                   db "(Leaf 80000020h)", 0
__Leaf80__20_1:                 db "(Leaf 80000020h, ecx = 0x01)", 0
__Leaf80__20_2:                 db "(Leaf 80000020h, ecx = 0x02)", 0
__Leaf80__20_3:                 db "(Leaf 80000020h, ecx = 0x03)", 0
__Leaf80__20_5:                 db "(Leaf 80000020h, ecx = 0x05)", 0
__Leaf80__21:                   db "(Leaf 80000021h)", 0
__Leaf80__22:                   db "(Leaf 80000022h)", 0
__Leaf80__23:                   db "(Leaf 80000023h)", 0
__Leaf80__26:                   db "(Leaf 80000026h)", 0
__Leaf80__FF:                   db "(Leaf 800000FFh)", 0

; =============================================================================================
; =============================================================================================
section '.idata' import data readable
; =============================================================================================
; =============================================================================================

library msvcrt,'msvcrt.dll',kernel32,'KERNEL32.DLL'
import msvcrt,printf,'printf', __getmainargs,'__getmainargs'
import kernel32,GetActiveProcessorCount,'GetActiveProcessorCount'

; =============================================================================================
; =============================================================================================