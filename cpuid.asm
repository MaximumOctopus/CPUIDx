; ================================================================================================
;
; (c) Paul Alan Freshney 2023
; v0.1, January 9th 2023
;
; Source code:
;   https://github.com/MaximumOctopus/CPUIDx
;
; Assembled using "Flat Assembler"
;   https://flatassembler.net/
;
; Resources used:
;   AMD64 Architecture Programmer’s Manual Volume 3: General-Purpose and System Instructions (October 2022)
;   Intel® 64 and IA-32 Architectures Software Developer's Manual Volume 2 (December 2022)
;
; ================================================================================================

format PE console
include 'win32ax.inc'

; ================================================================================================
section '.code' code readable executable
; ================================================================================================

start:  call About

        xor eax, eax
        
        cpuid
        
        mov dword [__MaxBasic], eax
        mov dword [__VendorID], ebx
        mov dword [__VendorID + 4], edx
        mov dword [__VendorID + 8], ecx

        cinvoke printf, "  Vendor ID: %s %c", __VendorID, 10

        mov eax, 0x80000000
                
        cpuid
                
        mov dword [__MaxExtended], eax

        cmp eax, 0x80000004

        jl .01h

        call BrandString                        ; 0x80000002/3/4

.01h:   call FamilyModel
                
        call CoreCount

        call ShowFamilyModel

        call ShowFeatures1
                
        call ShowFeatures2

        call StructuredExtendedFeatureFlags     ; 07h
                
        call ThermalPower                       ; 06h

        call MonitorMWait                       ; 05h
                
        call DirectCacheAccessInfo              ; 09h
                
        call ArchitecturalPerfMon               ; 0ah
                
        call ProcExtStateEnumMain               ; 0dh, ecx = 0
                
        call ProcExtStateEnumSub1               ; 0dh, ecx = 1
                
        cmp dword [__VendorID + 8], 0x6c65746e
        jne .AMDoptions

        call InternalCache                      ; 02h

        call CacheTlb                           ; 04h

        call IntelRDTMonitoring                 ; 0fh
                
        call IntelRDTAllocEnum                  ; 10h
                
        call IntelSGXCapability                 ; 12h
                
        call TimeStampCounter                   ; 15h
                
        call IntelProcessorTrace                ; 14h
                                
        call ProcessorFreqInfo                  ; 16h

        call SoCVendor                          ; 17h
                
        call KeyLocker                          ; 19h
                        
        call NativeModelIDEnumeration           ; 1ah
                
        call LastBranchRecords                  ; 1ch
                
        call TileInformation                    ; 1dh
                
        call TMULInformation                    ; 1eh
                
        call ExtendedFeatures                   ; 0x80000001
                
        call InvariantTSC                       ; 0x80000007
                
        call AddressBits                        ; 0x80000008
                
        jmp .finish
                
; extended AMD-only options

.AMDoptions:

        cmp dword [__VendorID + 8], 0x444d4163
        jne .finish
                
        call AMDSVM                             ; 0x8000000A
                
        call AMDPerformanceOptimisation         ; 0x8000001A
                
        call AMDIBS                             ; 0x8000001B
                
        call AMDCache                           ; 0x8000001D
                
        call AMDEMS                             ; 0x8000001F
                
        call AMDQOS                             ; 0x80000020
                
        call AMDEFI2                            ; 0x80000021
                
        call AMDExtPMandD                       ; 0x80000022
                
        call AMDMultiKeyEMC                     ; 0x80000023

        call AMDExtendedCPUTop                  ; 0x80000026

        call ExtendedFeatures                   ; 0x80000001

        call PPMandRAS                          ; 0x80000007
                
        call ProcessorCapacityParameters        ; 0x80000008 

.finish:

        xor eax, eax
        ret

; ================================================================================================

About:  cinvoke printf, "%c    CPUidX v0.1 :: January 9th 2023 :: Paul A Freshney %c", 10, 10

        cinvoke printf, "      https://github.com/MaximumOctopus/CPUIDx %c %c", 10, 10

        ret

; ================================================================================================

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

; ================================================================================================

ShowFamilyModel:

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

        cinvoke printf, "  Family 0x%x, Model 0x%X, Stepping 0x%X %c", edi, esi, edx, 10

        ret

; ================================================================================================

ShowFeatures1:

        mov eax, [__Features1]
        mov edi, dword __FeatureString1

        push eax
        cinvoke printf, "  CPU Features #1 (0x%X) %c", eax, 10
        pop eax
                
        jmp showf
                
ShowFeatures2:

        mov eax, [__Features2]
        mov edi, dword __FeatureString2
                
        push eax
        cinvoke printf, "  CPU Features #2 (0x%X) %c", eax, 10
        pop eax
                
showf:  mov esi, 0

lf1:    bt  eax, esi
        jnc .next

        push eax
        cinvoke printf, "    %s %c", edi, 10
        pop eax

.next:  add edi, 11

        inc esi

        cmp esi, 32

        jne lf1

        ret

; ================================================================================================

CoreCount:

        cmp dword [__VendorID + 8], 0x6c65746e
        jne .AMDoptions
                
        mov eax, [__Features2]
                
        bt eax, 28
        jnc .singlecore

        mov eax, 0x01

        cpuid

        shr eax, 16
        and eax, 0x000000FF

        cinvoke printf, "    Cores: %d %c", eax, 10
                
        ret

.singlecore:

        cinvoke printf, "    Single core CPU %c", 10
                
        ret
                
.AMDoptions:            
                
        ret

; ================================================================================================

; leaf 04, data returned in eax, ebx, and ecx
; Intel only, not supported by AMD
CacheTlb:

        cmp dword [__VendorID + 8], 0x6c65746e
        jne .finish

        cinvoke printf, "  Cache List: %c", 10

        mov eax, 0x04

        cpuid

        cinvoke printf, "    0x%X 0x%x 0x%x 0x%x %c", eax, ebx, ecx, edx, 10

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

; ================================================================================================

; from volume 2A of the cpuid docs
; eax contains cache level and type
; ebx contains cache size parameters
; ecx contains number of sets
ShowCache:

        mov esi, eax

        shr esi, 5              ; extract level from bits 5-7
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

        inc ecx                 ; all values from ebx are value-1

        imul edx, ecx

        mov ecx, ebx

        shr ecx, 22             ; extract Ways of Associativity
        and ecx, 0x1FF

        inc ecx                 ; all values from ebx are value-1

        imul edx, ecx

        shr edx, 10             ; convert bytes to kilobytes (divide by 1024)

        cinvoke printf, "    Level %d, %d KB (%d-way set associative, %d-byte line size) %c", esi, edx, ecx, eax, 10
                
        ret
                
; ================================================================================================

; leaf 02h, returns data (as bytes, max of 4 per register) in eax, ebc, ecx, and edx
; Intel only, not supported by AMD
InternalCache:

        cmp dword [__VendorID + 8], 0x6c65746e
        jne .fin

        mov eax, 0x02

        cpuid

        push eax
        push ebx
        push ecx
        push edx
        cinvoke printf, "  TLB/Cache/Prefetch Information (0x%X 0x%X 0x%X 0x%x) %c", eax, ebx, ecx, edx, 10
        pop edx
        pop ecx
        pop ebx
        pop eax
                
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
        ;cinvoke printf, "  0x%X 0x%X 0x%X 0x%X %d %c", eax, ebx, ecx, edx, edi, 10
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
                
; ================================================================================================

; leaf 05h, data in eax, ebx, ecx, edx
MonitorMWait:

        cinvoke printf, "  Monitor / MWAIT %c", 10

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
                
        bt edi, 1
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

; ================================================================================================

; 06h leaf, data in eax
ThermalPower:

        mov eax, 0x06
        mov edi, dword __ThermalPower1
                
        cpuid

        push eax
        cinvoke printf, "  Thermal and Power Management (0x%X) %c", eax, 10
        pop eax
                
        mov esi, 0

.tloop: bt  eax, esi
        jnc .tnext

        push eax
        cinvoke printf, "    %s %c", edi, 10
        pop eax

.tnext: add edi, 46

        inc esi

        cmp esi, 32

        jne .tloop

        ret             

; ================================================================================================

; 07h leaf, flags in ebx, ecx, and edx
StructuredExtendedFeatureFlags:

        mov ecx, 0
        mov eax, 0x07           ; first pass
                
        cpuid
                
        mov edi, dword __StructuredExtendedFeatureFlags1
                
        push ebx
        cinvoke printf, "  Structured Extended Feature 1 (0x%X) %c", ebx, 10
        pop ebx

        cmp ebx, 0
        jne showb

        cinvoke printf, "    No features available. %c", 10

        jmp pass2
                
showb:  mov esi, 0

.lf1:   bt  ebx, esi
        jnc .nextb

        push ebx
        cinvoke printf, "    %s %c", edi, 10
        pop ebx

.nextb: add edi, 30

        inc esi

        cmp esi, 32

        jne .lf1

pass2:  mov eax, 0x07           ; second pass
                
        cpuid
                
        mov edi, dword __StructuredExtendedFeatureFlags2
                
        push ecx
        cinvoke printf, "  Structured Extended Feature 2 (0x%X) %c", ecx, 10
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
        cinvoke printf, "    %s %c", edi, 10
        pop ecx

.nextc: add edi, 40

        inc esi

        cmp esi, 32

        jne .lf2
                
pass3:  mov eax, 0x07           ; third pass
                
        cpuid
                
        mov edi, dword __StructuredExtendedFeatureFlags3
                
        push edx
        cinvoke printf, "  Structured Extended Feature 3 (0x%X) %c", edx, 10
        pop edx
                
showd:  mov esi, 0

.lf3:   bt  edx, esi
        jnc .nextd

        push edx
        cinvoke printf, "    %s %c", edi, 10
        pop edx

.nextd: add edi, 35

        inc esi

        cmp esi, 32

        jne .lf3
                
        mov ecx, 0x01
        mov eax, 0x07           ; sub-leaf 1
                
        cpuid
                
        mov edi, ebx
        mov esi, edx
                
        cmp eax, 0
        je .sl72

        bt eax, 4
        jnc .a0105

        push eax
        cinvoke printf, "    AVX-VNNI. AVX (VEX-encoded) versions of the Vector Neural Network Instructions %c", 10
        pop eax
                
.a0105: bt eax, 5
        jnc .a010A

        push eax
        cinvoke printf, "    AVX512_BF16. Vector Neural Network Instructions supporting BFLOAT16 inputs and conversion instructions from IEEE single precision %c", 10
        pop eax

.a010A: bt eax, 10
        jnc .a010B
                
        push eax
        cinvoke printf, "    Fast zero-length REP MOVSB %c", 10
        pop eax
                
.a010B: bt eax, 11
        jnc .a010C

        push eax
        cinvoke printf, "    Fast short REP STOSB %c", 10
        pop eax

.a010C: bt eax, 12
       jnc .a010X

        push eax
        cinvoke printf, "    Fast short REP CMPSB, REP SCASB %c", 10
        pop eax

.a010X: bt eax, 22
        jnc .b0100

        cinvoke printf, "    HRESET. History reset via the HRESET instruction and the IA32_HRESET_ENABLE MSR %c", 10

.b0100: bt edi, 0
        jnc .d0118
                
        cinvoke printf, "    IA32_PPIN and IA32_PPIN_CTL MSRs %c", 10


.d0118: bt esi, 18
        jnc .sl72
                
        cinvoke printf, "    CET_SSS %c", 10
                
.sl72:  mov ecx, 0x02
        mov eax, 0x07           ; sub-leaf 2

        cmp eax, 0
        je .fin
                
        mov edi, edx
                
.d0200: bt edi, 0
        jnc .d0201
                
        cinvoke printf, "    PSFD. Indicates bit 7 of the IA32_SPEC_CTRL MSR is supported %c", 10

.d0201: bt edi, 1
        jnc .d0202

        cinvoke printf, "    IPRED_CTRL. Bits 3 and 4 of the IA32_SPEC_CTRL MSR are supported %c", 10

.d0202: bt edi, 0
        jnc .d0203

        cinvoke printf, "    RRSBA_CTRL. Bits 5 and 6 of the IA32_SPEC_CTRL MSR are supported %c", 10

.d0203: bt edi, 0
        jnc .d0204

        cinvoke printf, "    DDPD_U. Bit 8 of the IA32_SPEC_CTRL MSR is supported %c", 10

.d0204: bt edi, 0
        jnc .d0205

        cinvoke printf, "    BHI_CTRL. Bit 10 of the IA32_SPEC_CTRL MSR is supported %c", 10
                
.d0205: bt edi, 0
        jnc .fin

        cinvoke printf, "    MCDT_NO. %c", 10

.fin:
        ret
                
; ================================================================================================

; leaf 09h
; Intel only, not supported by AMD
DirectCacheAccessInfo:

        cmp dword [__VendorID + 8], 0x6c65746e
        jne .fin

        mov eax, 0x09
                
        cpuid
                
        cinvoke printf, "  IA32_PLATFORM_DCA_CAP MSR (0x1F8): 0x%X %c", eax, 10

.fin:
        ret

; ================================================================================================

; leaf 0ah
ArchitecturalPerfMon:

        cmp [__MaxBasic], 0x0A
        jl .fin

        cinvoke printf, "  Architectural Performance Monitoring %c", 10

        mov eax, 0x0A

        cpuid

        mov edi, eax
        mov esi, edx

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

        mov eax, esi
        and eax, 0x0000001F

        cinvoke printf, "    Contiguous fixed-function performance counters starting from 0: %d %c", eax, 10

        mov eax, esi
        shr eax, 8
        and eax, 0x000000FF

        cinvoke printf, "    Bit width of fixed-function performance counters: %d %c", eax, 10

        bt esi, 15
        jnc .fin

        cinvoke printf, "    AnyThread deprecation %c", 10

.fin:   ret

; ================================================================================================

;lead 0dh (ecx=0), data in eax, ebx, ecx
ProcExtStateEnumMain:

        cmp [__MaxBasic], 0x0D
        jl .fin

        mov ecx, 0x00
        mov eax, 0x0D
        mov edi, __ProcExtStateEnumMain

        cpuid

        push eax
        cinvoke printf, "  Processor Extended State Enumeration (0x%X) %c", eax, 10
        pop eax

        mov esi, 0

.loop:  bt  eax, esi
        jnc .next

        push eax
        cinvoke printf, "    %s %c", edi, 10
        pop eax

.next:  add edi, 13             ; size of string data

        inc esi

        cmp esi, 32             ; number of bits to test

        jne .loop

        mov ecx, 0x00
        mov eax, 0x0D
        mov edi, __ProcExtStateEnumMain

        cpuid
                
        mov edi, ebx
        mov esi, ecx
                
        cinvoke printf, "    Maximum size required by enabled features: %d bytes %c", edi, 10
        cinvoke printf, "    Maximum size of the save area            : %d bytes %c", esi, 10

.fin:   ret

;leaf 0dh (ecx=1), data in eax, ebx, ecx
ProcExtStateEnumSub1:

        cmp [__MaxBasic], 0x0D
        jl .fin

        mov ecx, 0x01
        mov eax, 0x0D

        cpuid
                
        mov edi, eax
        mov esi, ebx
                
        bt edi, 0
        jnc .bit1
                
        cinvoke printf, "    XSAVEOPT available %c", 10
                
.bit1:  bt edi, 1
        jnc .bit2
                
        cinvoke printf, "    Supports XSAVEC and the compacted form of XRSTOR %c", 10
                
.bit2:  bt edi, 2
        jnc .bit3
                
        cinvoke printf, "    Supports XGETBV %c", 10

.bit3:  bt edi, 3
        jnc .bit4
                
        cinvoke printf, "    Supports XSAVES/XRSTORS and IA32_XSS %c", 10
                
.bit4:  bt edi, 4
        jnc .size
                
        cinvoke printf, "    Supports extended feature disable (XFD) %c", 10            

.size:  cinvoke printf, "    XSAVE area containing all states enabled by XCR0 | IA32_XSS: %d bytes %c", esi, 10

        mov ecx, 0x01
        mov eax, 0x0D

        cpuid   

.fin:   ret
                
; ================================================================================================

; leaf 0fh, sub leaf 0 and 1
IntelRDTMonitoring:

        cmp [__MaxBasic], 0x0F
        jl .fin

        cinvoke printf, "  Intel Resource Director Technology %c", 10

        mov ecx, 0
        mov eax, 0x0F

        cpuid

        mov edi, edx
                
        inc eax
                
        cinvoke printf, "    Max Range of RMID within this physical processor: 0x%X %c", eax, 10

        bt edi, 1
        jnc .subleaf
                
        cinvoke printf, "    Supports L3 Cache Intel RDT Monitoring %c", 10
                
.subleaf:

        cinvoke printf, "  L3 Cache Intel RDT Monitoring Capability %c", 10

        mov ecx, 1
        mov eax, 0x0F
                
        cpuid
                
        inc ecx
                
        mov edi, ecx
        mov esi, edx
                
        cinvoke printf, "    IA32_QM_CTR conversion factor: 0x%X bytes %c", ebx, 10

        cinvoke printf, "    Maximum range of RMID of this resource type: 0x%X %c", edi, 10

        bt esi, 0
        jnc .bit1

        cinvoke printf, "    Supports L3 occupancy monitoring %c", 10
                
.bit1:  bt esi, 1
        jnc .bit2
                
        cinvoke printf, "    Supports L3 Total Bandwidth monitoring %c", 10
                
.bit2:  bt esi, 2
        jnc .fin

        cinvoke printf, "    Supports L3 Local Bandwidth monitoring %c", 10

.fin:   ret

; ================================================================================================              

; leaf 10h, leaf 0 (data in ebx only)
IntelRDTAllocEnum:

        cmp [__MaxBasic], 0x10
        jl .fin

        cinvoke printf, "  Intel Resource Director Technology Allocation Enumeration %c", 10

        mov ecx, 0
        mov eax, 0x10

        cpuid
                
        mov edi, ebx
                
.bit1:  bt edi, 1
        jnc .bit2
                
        cinvoke printf, "    Supports L3 Cache Allocation Technology %c", 10

.bit2:  bt edi, 1
        jnc .bit3
                
        cinvoke printf, "    Supports L2 Cache Allocation Technology %c", 10

.bit3:  bt edi, 1
        jnc .subleaf1
                
        cinvoke printf, "    Supports Memory Bandwidth Allocation %c", 10
                
; leaf 10h, leaf 1 (data in eax, ebx, ecx, and edx)

.subleaf1:

        cinvoke printf, "  L3 Cache Allocation Technology Enumeration %c", 10
                
        mov ecx, 1
        mov eax, 0x10
                
        cpuid
                
        mov edi, eax
        mov esi, eax
                
        and edi, 0x0000001F
        inc edi
                
        cinvoke printf, "    ResID 1 Capacity bit mask length: %d %c", edi, 10
        cinvoke printf, "    Bit-granular map of isolation/contention of allocation units: 0x%X %c", esi, 10
                
        mov ecx, 1
        mov eax, 0x10
                
        cpuid
                
        mov edi, ecx
        mov esi, edx
                
        bt edi, 2
        jnc .cpns1
                
        cinvoke printf, "    Code and Prioritization Technology supported %c", 10
                
        jmp .hcos1
                
.cpns1:

        cinvoke printf, "    Code and Prioritization Technology not supported %c", 10

.hcos1:

        and esi, 0x0000FFFF
                
        cinvoke printf, "    Highest COS number supported for ResID1: %d %c", esi, 10

; leaf 10h, leaf 2 (data in eax, ebx, ecx, and edx)

.subleaf2:

        cinvoke printf, "  L2 Cache Allocation Technology Enumeration %c", 10
                
        mov ecx, 2
        mov eax, 0x10
                
        cpuid
                
        mov edi, eax
        mov esi, ebx
                
        and edi, 0x0000001F
        inc edi
                
        cinvoke printf, "    ResID 2 Capacity bit mask length: %d %c", edi, 10
        cinvoke printf, "    Bit-granular map of isolation/contention of allocation units: 0x%X %c", esi, 10
                
        mov ecx, 2
        mov eax, 0x10
                
        cpuid
                
        mov edi, ecx
        mov esi, edx
                
        bt edi, 2
        jnc .cpns2
                
        cinvoke printf, "    Code and Prioritization Technology supported %c", 10
                
        jmp .hcos2
                
.cpns2:

        cinvoke printf, "    Code and Prioritization Technology not supported %c", 10

.hcos2:

        and esi, 0x0000FFFF
                
        cinvoke printf, "    Highest COS number supported for ResID 2: %d %c", esi, 10

; leaf 10h, leaf 3 (data in eax, ecx, and edx)

.subleaf3:

        cinvoke printf, "  Memory Bandwidth Allocation Enumeration %c", 10
                
        mov ecx, 3
        mov eax, 0x10
                
        cpuid
                
        mov edi, ecx
        mov esi, edx
                
        and eax, 0x00000FFF
        inc eax
                
        cinvoke printf, "    Max MBA throttling value supported by ResID 3: %d %c", eax, 10
                
        bt edi, 2
        jnc .dnl
                
        cinvoke printf, "    Response of the delay values is linear %c", 10
                
        jmp .hcos3
                
.dnl:   cinvoke printf, "    Response of the delay values is not linear %c", 10

.hcos3: and esi, 0x0000FFFF

        cinvoke printf, "    Highest COS number supported for ResID 3: %d %c", esi, 10

.fin:

        ret

; ================================================================================================

; leaf 12h, ecx = 1, data in eax, ebx, and edx
IntelSGXCapability:

        cmp [__MaxBasic], 0x12
        jl .fin

        cinvoke printf, "  Intel SGX Capability Enumeration %c", 10
                
        mov ecx, 0
        mov eax, 0x07           ;
                
        cpuid
                
        bt ebx, 2               ; check SGX bit
        jnc .notsupported

        mov ecx, 0
        mov eax, 0x12
                
        cpuid
                
        mov edi, ebx
        mov esi, edx
                
        bt eax, 0
        jnc .bit1
                
        push eax
        cinvoke printf, "    Intel SGX supports the collection of SGX1 leaf functions %c", 10
        pop eax
                
.bit1:  bt eax, 1
        jnc .bit5
                
        push eax
        cinvoke printf, "    Intel SGX supports the collection of SGX2 leaf functions %c", 10
        pop eax
                
.bit5:  bt eax, 5
        jnc .bit6

        push eax
        cinvoke printf, "    Intel SGX supports ENCLV instructions (EINCVIRTCHILD, EDECVIRTCHILD, and ESETCONTEXT) %c", 10
        pop eax

.bit6:  bt eax, 6
        jnc .ebx
                
        push eax
        cinvoke printf, "    Intel SGX supports ENCLS instructions (ETRACKC, ERDINFO, ELDBC, and ELDUC) %c", 10
        pop eax
                
.ebx:   cinvoke printf, "    MISCSELECT, supported extended SGX features: %d %c", edi, 10
                
        mov eax, esi
                
        and eax, 0x000000FF
                
        cinvoke printf, "    MaxEnclaveSize_Not64 = 2^%d %c", eax, 10
                
        shr esi, 8
        and esi, 0x000000FF

        cinvoke printf, "    MaxEnclaveSize_64 = 2^%d %c", esi, 10

.fin:   ret

.notsupported:

        cinvoke printf, "    Not supported. %c", 10

        ret

; ================================================================================================

; leaf 14h, data in eax, ebx, and ecx
; Intel only
IntelProcessorTrace:

        cmp [__MaxBasic], 0x14
        jl .fin

        cinvoke printf, "  Intel Processor Trace Enumeration %c", 10

        mov ecx, 0
        mov eax, 0x14

        cpuid

        mov edi, ebx
        mov esi, ecx
                
.bbit0: bt edi, 0
        jnc .bbit1
                
        cinvoke printf, "    IA32_RTIT_CTL.CR3Filter can be set to 1, IA32_RTIT_CR3_MATCH MSR can be accessed %c", 10

.bbit1: bt edi, 1
        jnc .bbit2

        cinvoke printf, "    Configurable PSB and Cycle-Accurate Mod is supported %c", 10

.bbit2: bt edi, 2
        jnc .bbit3

        cinvoke printf, "    IP Filtering, TraceStop filtering, and preservation of Intel PT MSRs across warm reset. %c", 10

.bbit3: bt edi, 3
        jnc .bbit4

        cinvoke printf, "    MTC timing packet and suppression of COFI-based packets is supported %c", 10

.bbit4: bt edi, 4
        jnc .bbit5

        cinvoke printf, "    PTWRITE. Writes can set IA32_RTIT_CTL[12] (PTWEn) and IA32_RTIT_CTL[5] (FUPonPTW),%c", 10
        cinvoke printf, "      and PTWRITE can generate packets is supported %c", 10

.bbit5: bt edi, 5
        jnc .bbit6

        cinvoke printf, "    Power Event Trace. Writes can set IA32_RTIT_CTL[4] (PwrEvtEn), enabling Power Event Trace packet generation. %c", 10

.bbit6: bt edi, 6
        jnc .bbit7

        cinvoke printf, "    PSB and PMI preservation. Writes can set IA32_RTIT_CTL[56] (InjectPsbPmiOnEnable), enabling the processor %c", 10 
        cinvoke printf, "      to set IA32_RTIT_STATUS[7] (PendTopaPMI) and/or IA32_RTIT_STATUS[6] (PendPSB) in order to preserve ToPA PMIs %c", 10
        cinvoke printf, "      and/or PSBs otherwise lost due to Intel PT disable. Writes can also set PendToPAPMI and PendPSB. %c", 10

.bbit7: bt edi, 7
        jnc .bbit8

        cinvoke printf, "    Writes can set IA32_RTIT_CTL[31] (EventEn), enabling Event Trace packet generation %c", 10

.bbit8: bt edi, 8
        jnc .cbit0

        cinvoke printf, "    Writes can set IA32_RTIT_CTL[55] (DisTNT), disabling TNT packet generation %c", 10

.cbit0: bt esi, 0
        jnc .cbit1

        cinvoke printf, "    Tracing can be enabled with IA32_RTIT_CTL.ToPA = 1, hence utilizing the ToPA output scheme; %c", 10
        cinvoke printf, "      IA32_RTIT_OUTPUT_BASE and IA32_RTIT_OUTPUT_MASK_PTRS MSRs can be accessed %c", 10
                
.cbit1: bt esi, 1
        jnc .cbit2

        cinvoke printf, "    ToPA tables can hold any number of output entries, up to the maximum allowed by the MaskOrTableOffset %c", 10
        cinvoke printf, "      field of IA32_RTIT_OUTPUT_MASK_PTRS %c", 10
                
.cbit2: bt esi, 2
        jnc .cbit3

        cinvoke printf, "    Single-Range Output scheme is supported %c", 10

.cbit3: bt esi, 3
        jnc .cbitx

        cinvoke printf, "    Indicates support of output to Trace Transport subsystem %c", 10

.cbitx: bt esi, 31
        jnc .fin

        cinvoke printf, "    Generated packets which contain IP payloads have LIP values, which include the CS base component %c", 10

        mov ecx, 0
        mov eax, 0x14

        cpuid

        cmp eax, 1
        jl .fin

        mov ecx, 1
        mov eax, 0x14

        cpuid

        mov edi, eax
        mov esi, ebx

        and eax, 0x00000007

        cinvoke printf, "    Configurable Address Ranges for filtering: %d %c", eax, 10

        shr edi, 16
        and edi, 0x0000FFFF

        cinvoke printf, "    Bitmap of supported MTC period encodings: 0x%X %c", edi, 10

        mov eax, esi

        and eax, 0x0000FFFF

        cinvoke printf, "    Bitmap of supported MTC period encodings: 0x%X %c", eax, 10

        shr esi, 16
        and esi, 0x0000FFFF

        cinvoke printf, "    Bitmap of supported Configurable PSB freq encodings: 0x%X %c", esi, 10

.fin:   ret

; ================================================================================================

; leaf 15h, data in eax, ebx, and ecx
TimeStampCounter:

        cmp [__MaxBasic], 0x15
        jl .fin

        cinvoke printf, "  Time Stamp Counter and Core Crystal Clock %c", 10

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

; ================================================================================================

; leaf 16h, data in eax, ebx, and ecx
ProcessorFreqInfo:

        cmp [__MaxBasic], 0x16
        jl .fin

        cinvoke printf, "  Processor Frequency Information %c", 10

        mov eax, 0x16

        cpuid

        and eax, 0x0000FFFF     ; bits 16-31 are reserved, so let's mask them out
        and ebx, 0x0000FFFF     ;
        and ecx, 0x0000FFFF     ;

        mov edi, ebx
        mov esi, ecx

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
                
        cinvoke printf, "    Bus (Ref) Frequency : %d MHz %c", esi, 10
                
        jmp .fin
                
.rfns:  cinvoke printf, "    Bus (Ref) Frequency : Unknown %c", 10

.fin:   ret

; ================================================================================================

; leaf 17h, data in eax, ebx, ecx, and edx
SoCVendor:

        cmp [__MaxBasic], 0x17
        jl .fin

        mov ecx, 0
        mov eax, 0x17

        cpuid

        cmp eax, 3
        jl .fin

        cinvoke printf, "  System-On-Chip Vendor Attributes %c", 10

        mov edi, ebx

        and ebx, 0x0000FFFF

        cinvoke printf, "    SOC Vendor ID: 0x%X %c", ebx, 10

        bt edi, 16
        jnc .p2

        cinvoke printf, "    IsVendorScheme (vendor ID is industry standard) %c", ebx, 10

.p2:    mov ecx, 0
        mov eax, 0x17

        cpuid

        mov edi, ecx
        mov esi, edx

        cinvoke printf, "    Project ID : 0x%X %c", edi, 10

        cinvoke printf, "    Stepping ID: 0x%X %c", esi, 10

.fin:   ret

; ================================================================================================

; leaf 19h, data in eax, ebx, and ecx
KeyLocker:

        cinvoke printf, "  Key Locker Leaf %c", 10
                
        mov eax, 0x19

        cpuid

        mov edi, eax

        bt edi, 0
        jnc .a01

        cinvoke printf, "    Key Locker restriction of CPL0-only supported %c", 10

.a01:   bt edi, 1
        jnc .a02

        cinvoke printf, "    Key Locker restriction of no-encrypt supported %c", 10

.a02:   bt edi, 2
        jnc .b00

        cinvoke printf, "    Key Locker restriction of no-decrypt supported %c", 10

.b00:   mov eax, 0x19
                
        cpuid
                
        mov edi, ebx
        mov esi, ecx

        bt edi, 0
        jnc .b02
                
        cinvoke printf, "    AESKLE. AES Key Locker instructions are fully enabled %c", 10
                
.b02:   bt edi, 2
        jnc .b04
                
        cinvoke printf, "    AES wide Key Locker instructions are supported %c", 10

.b04:   bt edi, 4
        jnc .c00

        cinvoke printf, "    Platform supports the Key Locker MSRs %c", 10
        cinvoke printf, "      (IA32_COPY_LOCAL_TO_PLATFORM, IA23_COPY_PLATFORM_TO_LOCAL, %c", 10
        cinvoke printf, "       IA32_COPY_STATUS, and IA32_IWKEYBACKUP_STATUS) %c", 10

.c00:   bt esi, 0
        jnc .c01

        cinvoke printf, "    NoBackup parameter to LOADIWKEY is supported %c", 10

.c01:   bt esi, 1
        jnc .fin

        cinvoke printf, "    KeySource encoding of 1 (randomization of the internal wrapping key) is supported %c", 10

.fin:   ret

; ================================================================================================

; leaf 1ah, data in eax
NativeModelIDEnumeration:

        cmp [__MaxBasic], 0x1a
        jl .finish

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
                
        cinvoke printf, "    Core type      : Intel Atom %c", 10
                
.core:  cmp eax, 0x40
        jne .id
                
        cinvoke printf, "    Core type      : Intel Core %c", 10
                
.id:    and edi, 0x00FFFFFF

        cinvoke printf, "    Native Model ID: 0x%X %c", 10

.finish: 

        ret

; ================================================================================================

; leaf 1ch, data in eax, ebx, and ecx
LastBranchRecords:

        cinvoke printf, "  Last Branch Records Information %c", 10

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
                
        bt edi, 30
        jnc .a31
                
        cinvoke printf, "    Deep C-state Reset %c", 10
                
.a31:   bt edi, 31
        jnc .pass2
                
        cinvoke printf, "    IP Values Contain LIP %c", 10
                
.pass2: mov eax, 0x1C
                
        cpuid
                
        mov edi, ebx
        mov esi, ecx
                
.b00:   bt edi, 0
        jnc .b01
                
        cinvoke printf, "    CPL Filtering Supported %c", 10
                
.b01:   bt edi, 1
        jnc .b02
                
        cinvoke printf, "    Branch Filtering Supported %c", 10
                
.b02:   bt edi, 2
        jnc .c00
                
        cinvoke printf, "    Call-stack Mode Supported %c", 10
                
.c00:   bt esi, 0
        jnc .c01

        cinvoke printf, "    Mispredict Bit Supported %c", 10

.c01:   bt esi, 1
        jnc .c02

        cinvoke printf, "    Timed LBRs Supported %c", 10

.c02:   bt esi, 2
        jnc .fin

        cinvoke printf, "    Branch Type Field Supported %c", 10

.fin:   ret


; ================================================================================================

; leaf 1dh, data in eax and ebx
TileInformation:

        cmp [__MaxBasic], 0x1d
        jl .fin

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

; ================================================================================================

; leaf 1eh, data in ebx
TMULInformation:

        cmp [__MaxBasic], 0x1e
        jl .fin

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

; ================================================================================================

; extended leaf 80000001h
ExtendedFeatures:

        mov eax, dword [__MaxExtended]

        cmp eax, 0x80000001

        jl .notsupported
                
.intel: cmp dword [__VendorID + 8], 0x6c65746e
        jne .amd

        mov eax, 0x80000001

        cpuid

        mov edi, ecx
        mov esi, edx

        cinvoke printf, "  Extended CPU Features (0x%X 0x%X) %c", edi, esi, 10

        bt edi, 0
        jnc .lzcnt

        cinvoke printf, "    LAHF/SAHF available in 64-bit mode %c", 10

.lzcnt:

        bt edi, 5
        jnc .prefetchw

        cinvoke printf, "    LZCNT %c", 10

.prefetchw:

        bt edi, 8
        jnc .syscall

        cinvoke printf, "    PREFETCHW %c", 10

.syscall:

        bt esi, 11
        jnc .execdis

        cinvoke printf, "    SYSCALL/SYSRET %c", 10

.execdis:

        bt esi, 20
        jnc .onegig

        cinvoke printf, "    Execute Disable Bit available %c", 10

.onegig:

        bt esi, 26
        jnc .rdtscp

        cinvoke printf, "    1-GByte pages are available %c", 10

.rdtscp:

        bt esi, 26
        jnc .i64arch

        cinvoke printf, "    RDTSCP and IA32_TSC_AUX  %c", 10

.i64arch:

        bt esi, 26
        jnc .fin

        cinvoke printf, "    Intel(r) 64 Architecture %c", 10

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
                cinvoke printf, "  Extended CPU Features (0x%X 0x%X) %c", ecx, edx, 10
        push edx
        push ecx        

        mov esi, 0
        mov edi, dword __AMDFeatureIdentifiers1
                        
.showc: mov esi, 0

.cx:    bt  ecx, esi
        jnc .nxtc

        push ecx
        push edx
        cinvoke printf, "    %s %c", edi, 10
        push edx
        pop ecx

.nxtc:  add edi, 19             ; size of text in bytes

        inc esi

        cmp esi, 32             ; bits to check

        jne .cx

        mov esi, 0
        mov edi, dword __AMDFeatureIdentifiers2
                        
.showd: mov esi, 0

.dx:    bt  edx, esi
        jnc .nxtd

        push edx
        cinvoke printf, "    %s %c", edi, 10
        push edx

.nxtd:  add edi, 14             ; size of text in bytes

        inc esi

        cmp esi, 32             ; bits to text

        jne .dx

.fin:   ret

; ================================================================================================

; extended leaf 80000002h, data in eax, ebx, ecx, and edx
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

; ================================================================================================

; extended leaf 80000007h, data in edx
; Intel only
InvariantTSC:

        mov eax, dword [__MaxExtended]

        cmp eax, 0x80000007
        jl .notsupported

        mov eax, 0x80000007

        cpuid
                
        bt edx, 8
        jnc .notavailable
                
        cinvoke printf, "    Invariant TSC available %c", 10
                
        ret
                
.notavailable:

        cinvoke printf, "    Invariant TSC not available %c", 10
                
.notsupported:

        ret

; ================================================================================================

; extended lead 80000007h, data in ebx, ecx, and edx
; AMD only
PPMandRAS:

        mov eax, dword [__MaxExtended]

        cmp eax, 0x80000007
        jl .notsupported

        cinvoke printf, "  Processor Power Management and RAS Capabilities %c", 10

        mov eax, 0x80000007

        cpuid
                
        mov edi, ecx
        mov esi, edx
                
        bt ebx, 0
        jnc .bit1

        push ebx
        cinvoke printf, "    McaOverflowRecov %c", 10
        pop ebx

.bit1:  bt ebx, 1
        jnc .bit2

        push ebx
        cinvoke printf, "    SUCCOR %c", 10
        pop ebx

.bit2:  bt ebx, 1
        jnc .bit3

        push ebx
        cinvoke printf, "    HWA %c", 10
        pop ebx

.bit3:  bt ebx, 1
        jnc .ecx

        push ebx
        cinvoke printf, "    ScalableMca %c", 10
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
        cinvoke printf, "    %s %c", edi, 10
        push edx

.nxtd:  add edi, 29             ; size of text in bytes

        inc esi

        cmp esi, 12             ; bits to text

        jne .dx

.notsupported:

        ret

; ================================================================================================

; extended leaf 80000008h, data in eax and ebx
; intel only
AddressBits:

        mov eax, dword [__MaxExtended]

        cmp eax, 0x80000008
        jl .notsupported

        mov eax, 0x80000008

        cpuid

        mov edx, eax

        and eax, 0x000000FF             ; isolate bits 0-7 from eax

        shr edx, 8                      ; isolate bits 8-15 from eax (copied to edx)
        and edx, 0x000000FF

        mov edi, ebx
                
        cinvoke printf, "    Physical Address Bits: %d, Linear Address Bits: %d %c", eax, edx, 10
                
        bt edi, 9
        jnc .notsupported
                
        cinvoke printf, "    WBOINVD is available %c", 10

        ret

.notsupported:

        cinvoke printf, "    WBOINVD is not available %c", 10

        ret
                
; ================================================================================================

; extended leaf 80000008h, data in eax, ebx, ecx, and edx
; AMD only
ProcessorCapacityParameters:

        mov eax, dword [__MaxExtended]

        cmp eax, 0x80000008
        jl .notsupported
                
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
        cinvoke printf, "    %s %c", edi, 10
        push ebx

.nxtd:  add edi, 24             ; size of text in bytes

        inc esi

        cmp esi, 32             ; bits to text

        jne .dx

.edx:   mov eax, 0x80000008

        cpuid
                
        mov edi, edx
                
        and edx, 0x000000FF
                
        cinvoke printf, "    Maximum page count for INVLPGB: %d %c", edx, 10
                
        shr edi, 16
        and edi, 0x000000FF
                
        cinvoke printf, "    The maximum ECX value recognized by RDPRU: %d %c", edi, 10

.notsupported:

        ret

; ================================================================================================

; AMD only, data in eax, ebx, and edx
AMDSVM: 

        mov eax, dword [__MaxExtended]

        cmp eax, 0x8000000A
        jl .fin

        cinvoke printf, "  AMD Secure Virtual Machine Architecture (SVM) %c", 10
                
        mov eax, 0x8000000A

        cpuid
                
        mov edi, ebx
        mov esi, edx
                
        and eax, 0x000000FF
                
        cinvoke printf, "    SVM Revision : %d %c", eax, 10
                
        cinvoke printf, "    ASIDs : %d %c", edi, 10
                
        mov eax, esi
                
        mov esi, 0
        mov edi, __SVMFeatureInformation

.loop:  bt  eax, esi
        jnc .next

        push eax
        cinvoke printf, "    %s %c", edi, 10
        pop eax

.next:  add edi, 21             ; size of string data

        inc esi

        cmp esi, 32             ; number of bits to test

        jne .loop

.fin:   ret

; ================================================================================================

; extended leaf 80000001Ah, data in eax
; AMD only
AMDPerformanceOptimisation:

        mov eax, dword [__MaxExtended]

        cmp eax, 0x8000001A
        jl .notsupported
                
        cinvoke printf, "  Performance Optimization %c", 10

        mov eax, 0x8000001A

        cpuid
                
        mov edi, eax
                
        bt edi, 0
        jnc .bit1
                
        cinvoke printf, "    FP128. The internal FP/SIMD execution data path is 128 bits wide %c", 10

.bit1:  bt edi, 1
        jnc .bit2

        cinvoke printf, "    MOVU. MOVU SSE instructions are more efficient and should be preferred to SSE %c", 10
        cinvoke printf, "          MOVL/MOVH. MOVUPS is more efficient than MOVLPS/MOVHPS. %c", 10
        cinvoke printf, "          MOVUPD is more efficient than MOVLPD/MOVHPD. %c", 10

.bit2:  bt edi, 2
        jnc .fin

        cinvoke printf, "    FP256. The internal FP/SIMD execution data path is 256 bits wide %c", 10

.notsupported:

.fin:   ret

; ================================================================================================

; AMD only, data in eax
AMDIBS: mov eax, dword [__MaxExtended]

        cmp eax, 0x8000001B
        jl .fin

        cinvoke printf, "  AMD Instruction-Based Sampling (IBS) %c", 10

        mov eax, 0x8000001B

        cpuid

        mov esi, 0
        mov edi, __IBSFeatures

.loop:  bt  eax, esi
        jnc .next

        push eax
        cinvoke printf, "    %s %c", edi, 10
        pop eax

.next:  add edi, 19             ; size of string data

        inc esi

        cmp esi, 12             ; number of bits to test

        jne .loop

.fin:   ret
            

; ================================================================================================

; leaf 8000001fd, data in eax, ebx, ecx, and edx
; AMD only, data in eax
AMDCache:

        mov eax, dword [__MaxExtended]

        cmp eax, 0x8000001D
        jl .fin

        cinvoke printf, "  Cache Properties %c", 10

        mov esi, 0

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
                
.si:    bt edi, 8
        jnc .fa
                
        cinvoke printf, "    SelfInitialization %c", 10

.fa:    bt edi, 9
        jnc .nsc
                
        cinvoke printf, "    FullyAssociative %c", 10
                
        mov ecx, esi
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

        mov ecx, esi
        mov eax, 0x8000001D

        cpuid
                
        cinvoke printf, "%c", 10

        mov edi, edx
                
        bt edi, 0
        jnc .ci

        cinvoke printf, "    WBINVD %c", 10

.ci:    bt edi, 1
        jnc .inc

        cinvoke printf, "    CacheInclusive %c", 10

.inc:   inc esi

        jmp .next

.fin:   ret

; ================================================================================================              

; leaf 8000001fh
; AMD only, data in eax
AMDEMS: mov eax, dword [__MaxExtended]

        cmp eax, 0x8000001F
        jl .fin

        cinvoke printf, "  AMD Encrypted Memory Capabilities %c", 10

        mov eax, 0x8000001F

        cpuid

        mov esi, 0
        mov edi, __AMDSecureEncryption

.loop:  bt  eax, esi
        jnc .next

        push eax
        cinvoke printf, "    %s %c", edi, 10
        pop eax

.next:  add edi, 21             ; size of string data

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
                
        cinvoke printf, "    Encrypted guests supported simultaneously : 0x%X %c", edi, 10
                
        cinvoke printf, "    Minimum ASID value for an SEV enabled     : 0x%X %c", esi, 10

.fin:   ret

; ================================================================================================              

; AMD only, data in ebx
AMDQOS: mov eax, dword [__MaxExtended]

        cmp eax, 0x80000020
        jl .fin

        cinvoke printf, "  QoS Extended Features %c", 10

        mov eax, 0x80000020

        cpuid

        bt ebx, 4
        jnc .ns

        cinvoke printf, "    L3 Range Reservation is supported %c", 10

        ret

.ns:    cinvoke printf, "    L3 Range Reservation is not supported %c", 10

.fin:   ret

; ================================================================================================

; AMD only, data in eax and ebx
AMDEFI2: 

        mov eax, dword [__MaxExtended]

        cmp eax, 0x80000021
        jl .fin

        cinvoke printf, "  Extended Feature Identification 2 %c", 10
                
        mov eax, 0x80000021

        cpuid

        mov esi, 0
        mov edi, __AMDExtendedFeatureIdentifiers2

.loop:  bt  eax, esi
        jnc .next

        push eax
        cinvoke printf, "    %s %c", edi, 10
        pop eax

.next:  add edi, 24             ; size of string data

        inc esi

        cmp esi, 12             ; number of bits to test

        jne .loop

.fin:   ret

; ================================================================================================

; AMD only, data in eax and ebx
AMDExtPMandD:

        mov eax, dword [__MaxExtended]

        cmp eax, 0x80000022
        jl .fin

        cinvoke printf, "  Extended Performance Monitoring and Debug %c", 10
                
        mov eax, 0x80000022
                
        cpuid
                
        mov edi, eax
        mov esi, ebx
                
.a00:   bt edi, 0
        jnc .a01
                
        cinvoke printf, "    PerfMonV2 %c", 10
                
.a01:   bt edi, 1
        jnc .a02
                
        cinvoke printf, "    LbrStack %c", 10

.a02:   bt edi, 2
        jnc .num
                
        cinvoke printf, "    LbrAndPmcFreeze %c", 10
                
.num:   mov edi, esi
        and edi, 0x0000000F
                
        cinvoke printf, "    Northbridge Perf Mon Counters   : %d %c", edi, 10

        mov edi, esi
        shr edi, 4
        and edi, 0x0000003F
                
        cinvoke printf, "    Last Branch Record Stack Entries: %d %c", edi, 10
                
        shr esi, 10
        and esi, 0x0000007F
                
        cinvoke printf, "    Core Performance Counters       : %d %c", esi, 10
                
.fin:   ret
                
; ================================================================================================

; AMD only, data in eax and ebx
AMDMultiKeyEMC:

        mov eax, dword [__MaxExtended]

        cmp eax, 0x80000023
        jl .fin

        cinvoke printf, "  Extended Performance Monitoring and Debug %c", 10
                
        mov eax, 0x80000023
                
        cpuid
                
        mov edi, eax
        mov esi, ebx
                
        bt edi, 0
        jnc .b15
                
        cinvoke printf, "    Secure Host Multi-Key Memory (MEM-HMK) Encryption Mode Supported %c", 10
                
.b15:   and esi, 0x0000FFFF

        cinvoke printf, "    Simultaneously available host encryption key IDs in MEM-HMK encryption mode: %d %c", esi, 10
                
.fin:   ret

; ================================================================================================

; AMD only, data in eax and ebx
AMDExtendedCPUTop:

        mov eax, dword [__MaxExtended]

        cmp eax, 0x80000026
        jl .fin

        cinvoke printf, "  Extended CPU Topology %c", 10

        mov esi, 0

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

        lea edi, [edx + edi*4]
                
        push eax
        cinvoke printf, "    LevelType: %s %c", edi, 10
        pop eax
                
.areg:  mov edi, eax
                
.a29:   bt edi, 29
        jnc .a30
                
        cinvoke printf, "    EfficiencyRankingAvailable %c", 10

.a30:   bt edi, 30
        jnc .a31

        cinvoke printf, "    HeterogeneousCores %c", 10

.a31:   bt edi, 31
        jnc .breg

        cinvoke printf, "    AsymmetricTopology %c", 10

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

        cinvoke printf, "    NativeModelID: %d %c", ebx, 10             

        inc esi

        jmp .next

.fin:   ret

; ================================================================================================
section '.data' data readable writeable
; ================================================================================================

__BrandIndex    db 0

__MaxBasic      dw 0
__MaxExtended   dw 0

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


; ================================================================================================
section '.data2' data readable
; ================================================================================================

; 01h leaf, bits in ecx
__FeatureString1                db "SSE3      ",0
                                db "PCLMULQDQ ",0
                                db "DTES64    ",0
                                db "MONITOR   ",0
                                db "DS-CPL    ",0
                                db "VMX       ",0
                                db "SMX       ",0
                                db "EIST      ",0
                                db "TM2       ",0
                                db "SSSE3     ",0
                                db "CNXT-ID   ",0
                                db "SDBG      ",0
                                db "FMA       ",0
                                db "CMPXCHG16B",0
                                db "xTPR      ",0
                                db "PDCM      ",0
                                db "Reserved  ",0
                                db "PCID      ",0
                                db "DCA       ",0
                                db "SSE4_1    ",0
                                db "SSE4_2    ",0
                                db "x2APIC    ",0
                                db "MOVBE     ",0
                                db "POPCNT    ",0
                                db "TSC       ",0
                                db "AES       ",0
                                db "XSAVE     ",0
                                db "OSXSAVE   ",0
                                db "AVX       ",0
                                db "F16C      ",0
                                db "RDRAND    ",0
                                db "          ",0

; 01h leaf, bits in edx
__FeatureString2                db "FPU-x87   ",0
                                db "VME       ",0
                                db "DE        ",0
                                db "PSE       ",0
                                db "TSC       ",0
                                db "MSR       ",0
                                db "PAE       ",0
                                db "MCE       ",0
                                db "CX8       ",0
                                db "APIC      ",0
                                db "Reserved  ",0
                                db "SEP       ",0
                                db "MTRR      ",0
                                db "PGE       ",0
                                db "MCA       ",0
                                db "CMOV      ",0
                                db "PAT       ",0
                                db "PSE-36    ",0
                                db "PSN       ",0
                                db "CLFSH     ",0
                                db "Reserved  ",0
                                db "DS        ",0
                                db "ACPI      ",0
                                db "MMX       ",0
                                db "FXSR      ",0
                                db "SSE       ",0
                                db "SSE2      ",0
                                db "SS        ",0
                                db "HTT       ",0
                                db "TM        ",0
                                db "Reserved  ",0
                                db "PBE       ",0

; 02h leaf                                                                                                 
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
__SF1                           db "Prefetch 128-Byte prefetching", 0                                                           

; 06h leaf, bits in eax
__ThermalPower1                 db "Digital temperature sensor supported         ", 0
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
                                db "Reserved.                                    ", 0
                                db "Intel® Thread Director supported             ", 0
                                db "IA32_THERM_INTERRUPT MSR bit 25 is supported ", 0
                                db "Reserved.                                    ", 0
                                db "Reserved.                                    ", 0
                                db "Reserved.                                    ", 0
                                db "Reserved.                                    ", 0
                                db "Reserved.                                    ", 0
                                db "Reserved.                                    ", 0
                                db "Reserved.                                    ", 0
                                                   
; 07h leaf, bits in ebx
__StructuredExtendedFeatureFlags1:
                                db "FSGSBASE                     ", 0
                                db "IA32_TSC_ADJUST              ", 0
                                db "SGX                          ", 0
                                db "BMI1                         ", 0
                                db "HLE                          ", 0
                                db "AVX2                         ", 0
                                db "FDP_EXCPTN_ONLY              ", 0
                                db "SMEP                         ", 0 
                                db "BMI2                         ", 0
                                db "Enhanced REP MOVSB/STOSB     ", 0
                                db "INVPCID                      ", 0  
                                db "RTM                          ", 0
                                db "RDT-M                        ", 0
                                db "Deprecates FPU CS and FPU DS ", 0
                                db "MPX                          ", 0
                                db "RDT-A                        ", 0
                                db "AVX512F                      ", 0
                                db "AVX512DQ                     ", 0
                                db "RDSEED                       ", 0
                                db "ADX                          ", 0
                                db "SMAP                         ", 0
                                db "AVX512_IFMA                  ", 0
                                db "Reserved                     ", 0
                                db "CLFLUSHOPT                   ", 0
                                db "CLWB                         ", 0
                                db "Intel Processor Trace        ", 0
                                db "AVX512PF. Intel Xeon Phi only", 0
                                db "AVX512ER. Intel Xeon Phi only", 0
                                db "AVX512CD                     ", 0
                                db "SHA                          ", 0
                                db "AVX512BW                     ", 0
                                db "AVX512VL                     ", 0

; 07h leaf, bits in ecx
__StructuredExtendedFeatureFlags2:
                                db "PREFETCHWT1. Intel Xeon Phi only      ", 0
                                db "AVX512_VBMI                           ", 0
                                db "UMIP                                  ", 0
                                db "PKU                                   ", 0
                                db "OSPKE. CR4.PKE (and RDPKRU/WRPKRU)    ", 0
                                db "WAITPKG                               ", 0
                                db "AVX512_VBMI2                          ", 0
                                db "CET_SS                                ", 0
                                db "GFNI                                  ", 0
                                db "VAES                                  ", 0
                                db "VPCLMULQDQ                            ", 0
                                db "AVX512_VNNI                           ", 0
                                db "AVX512_BITALG                         ", 0
                                db "TIME_EN                               ", 0
                                db "AVX512_VPOPCNTDQ                      ", 0   
                                db "Reserved.                             ", 0
                                db "LA57                                  ", 0
                                db "                                      ", 0
                                db "                                      ", 0
                                db "                                      ", 0
                                db "                                      ", 0
                                db "                                      ", 0
                                db "RDPID and IA32_TSC_AUX                ", 0
                                db "KL                                    ", 0
                                db "Reserved.                             ", 0
                                db "CLDEMOTE                              ", 0
                                db "Reserved                              ", 0
                                db "MOVDIRI                               ", 0
                                db "MOVDIR64B                             ", 0
                                db "ENQCMD                                ", 0
                                db "SGX_LC                                ", 0
                                db "PKS                                   ", 0

; 07h leaf, bits in edx
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

; 0Dh, bits in eax

__ProcExtStateEnumMain          db "00:X87      ", 0
                                db "01:SSE      ", 0
                                db "02:ACX      ", 0
                                db "03:BNDREG   ", 0
                                db "04:BNDCSR   ", 0
                                db "05:opmask   ", 0
                                db "06:ZMM_hi256", 0
                                db "07:Hi16_ZMM ", 0
                                db "08:IA32_XSS.", 0
                                db "09:PKRU     ", 0
                                db "0A:ENQCMD   ", 0
                                db "0B:CETU     ", 0
                                db "0C:CETS     ", 0
                                db "0D:HDC      ", 0
                                db "0E:UINTR    ", 0
                                db "0F:ALBR     ", 0
                                db "10:HWP      ", 0
                                db "11:TILECFG  ", 0
                                db "12:TILEDATA ", 0
                                                                
; AMD: 80000001_ECX
__AMDFeatureIdentifiers1:       db "LahfSahf          ", 0
                                db "CmpLegacy         ", 0
                                db "SVM               ", 0
                                db "ExtApicSpace      ", 0
                                db "AltMovCr8         ", 0
                                db "ABM               ", 0
                                db "SSE4A             ", 0
                                db "MisAlignSse       ", 0
                                db "3DNowPrefetch     ", 0
                                db "OSVW              ", 0
                                db "IBS               ", 0
                                db "XOP               ", 0
                                db "SKINIT            ", 0
                                db "WDT               ", 0
                                db "Reserved          ", 0           
                                db "LWP               ", 0
                                db "FMA4              ", 0
                                db "TCE               ", 0
                                db "Reserved          ", 0
                                db "Reserved          ", 0
                                db "Reserved          ", 0
                                db "TBM               ", 0
                                db "TopologyExtensions", 0
                                db "PerfCtrExtCore    ", 0
                                db "PerfCtrExtNB      ", 0
                                db "Reserved          ", 0
                                db "DataBkptExt       ", 0
                                db "PerfTsc           ", 0
                                db "PerfCtrExtLLC     ", 0
                                db "MONITORX          ", 0
                                db "AddrMaskExt       ", 0
                                db "Reserved          ", 0

; AMD: 80000001_EDX
__AMDFeatureIdentifiers2:       db "FPU x87      ", 0
                                db "VME          ", 0
                                db "DE           ", 0
                                db "PSE          ", 0
                                db "TSC          ", 0
                                db "MSR          ", 0
                                db "PAE          ", 0
                                db "MCE          ", 0
                                db "CMPXCHG8B    ", 0
                                db "APIC         ", 0
                                db "Reserved     ", 0
                                db "SysCallSysRet", 0
                                db "MTRR         ", 0
                                db "PGE          ", 0
                                db "MCA          ", 0
                                db "CMOV         ", 0
                                db "PAT          ", 0
                                db "PSE36        ", 0
                                db "Reserved     ", 0
                                db "Reserved     ", 0
                                db "NX           ", 0
                                db "Reserved     ", 0
                                db "MmxExt       ", 0
                                db "MMX          ", 0
                                db "FXSR         ", 0
                                db "FFXSR        ", 0
                                db "Page1GB      ", 0
                                db "RDTSCP       ", 0
                                db "Reserved     ", 0
                                db "LM           ", 0
                                db "3DNowExt     ", 0
                                db "3DNow        ", 0
                                                           
; AMD; 80000007_EDX
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
__AMDExtendedFeatureID:         db "CLZERO                 ", 0
                                db "InstRetCntMsr          ", 0
                                db "RstrFpErrPtrs          ", 0
                                db "INVLPGB INVLPGB TLBSYNC", 0
                                db "RDPRU                  ", 0
                                db "Reserved               ", 0
                                db "Reserved               ", 0
                                db "Reserved               ", 0
                                db "MCOMMIT                ", 0
                                db "WBNOINVD               ", 0
                                db "Reserved               ", 0
                                db "Reserved               ", 0
                                db "IBPB                   ", 0
                                db "INT_WBINVD             ", 0
                                db "IBRS                   ", 0
                                db "STIBP                  ", 0
                                db "IbrsAlwaysOn           ", 0
                                db "StibpAlwaysOn          ", 0
                                db "IbrsPreferred          ", 0
                                db "IbrsSameMode           ", 0
                                db "EferLmsleUnsupported   ", 0
                                db "INVLPGBnestedPages     ", 0
                                db "Reserved               ", 0
                                db "Reserved               ", 0
                                db "SSBD                   ", 0
                                db "SsbdVirtSpecCtrl       ", 0
                                db "SsbdNotRequired        ", 0
                                db "Reserved               ", 0
                                db "PSFD                   ", 0
                                db "BTC_NO                 ", 0
                                db "Reserved               ", 0
                                db "Reserved               ", 0
                                                                                                                   
; AMD; 8000000A_EDX
__SVMFeatureInformation:        db "NP                  ", 0
                                db "LbrVirt             ", 0
                                db "SVML                ", 0
                                db "NRIPS               ", 0
                                db "TscRateMsr          ", 0
                                db "VmcbClean           ", 0
                                db "FlushByAsid         ", 0
                                db "DecodeAssists       ", 0
                                db "Reserved            ", 0
                                db "Reserved            ", 0
                                db "PauseFilter         ", 0
                                db "Reserved            ", 0
                                db "PauseFilterThreshold", 0
                                db "AVIC                ", 0
                                db "Reserved            ", 0
                                db "VMSAVEvirt          ", 0
                                db "VGIF                ", 0
                                db "GMET                ", 0
                                db "x2AVIC              ", 0
                                db "SSSCheck            ", 0
                                db "SpecCtrl            ", 0
                                db "ROGPT               ", 0
                                db "Reserved            ", 0
                                db "HOST_MCE_OVERRIDE   ", 0
                                db "TlbiCtl             ", 0
                                db "VNMI                ", 0
                                db "IbsVirt             ", 0
                                db "Reserved            ", 0
                                db "Reserved            ", 0
                                db "Reserved            ", 0
                                db "Reserved            ", 0
                                db "Reserved            ", 0

; AMD; 8000001B_EAX
__IBSFeatures:                  db "IBSFFV            ", 0
                                db "FetchSam          ", 0
                                db "OpSam             ", 0
                                db "RdWrOpCnt         ", 0
                                db "OpCnt             ", 0
                                db "BrnTrgt           ", 0
                                db "OpCntExt          ", 0
                                db "RipInvalidChk     ", 0
                                db "OpBrnFuse         ", 0
                                db "Reserved          ", 0
                                db "Reserved          ", 0
                                db "IbsL3MissFiltering", 0
                                                                
; AMD; 8000001F_EAX
__AMDSecureEncryption:          db "SME                 ", 0
                                db "SEV                 ", 0
                                db "PageFlushMsr        ", 0
                                db "SEV-ES              ", 0
                                db "SEV-SNP             ", 0
                                db "VMPL                ", 0
                                db "RMPQUERY            ", 0
                                db "VmplSSS             ", 0
                                db "SecureTsc           ", 0
                                db "TscAuxVirtualization", 0
                                db "HwEnfCacheCoh       ", 0
                                db "64BitHost           ", 0
                                db "RestrictedInjection ", 0
                                db "AlternateInjection  ", 0
                                db "DebugSwap           ", 0
                                db "PreventHostIbs      ", 0
                                db "VTE                 ", 0
                                db "VmgexitParameter    ", 0
                                db "VirtualTomMsr       ", 0
                                db "IbsVirtGuestCtl     ", 0
                                db "Reserved            ", 0
                                db "Reserved            ", 0
                                db "Reserved            ", 0
                                db "Reserved            ", 0
                                db "VmsaRegProt         ", 0
                                db "SmtProtection       ", 0
                                db "Reserved            ", 0
                                db "Reserved            ", 0
                                db "SvsmCommPageMSR     ", 0
                                db "NestedVirtSnpMsr    ", 0
                                db "Reserved            ", 0
                                db "Reserved            ", 0

; AMD; 80000021_EAX
__AMDExtendedFeatureIdentifiers2:
                                db "NoNestedDataBp         ", 0
                                db "Reserved               ", 0
                                db "LFenceAlwaysSerializing", 0
                                db "SmmPgCfgLock           ", 0
                                db "Reserved               ", 0
                                db "Reserved               ", 0
                                db "NullSelectClearsBase   ", 0
                                db "UpperAddressIgnore     ", 0
                                db "AutomaticIBRS          ", 0
                                db "NoSmmCtlMSR            ", 0
                                db "Reserved               ", 0
                                db "Reserved               ", 0
                                db "Reserved               ", 0
                                db "PrefetchCtlMsr         ", 0
                                db "Reserved               ", 0
                                db "Reserved               ", 0
                                db "Reserved               ", 0
                                db "CpuidUserDis           ", 0
                                                                
; AMD; 80000026_ECX
__AMDLevelType                  db "Core   ", 0
                                db "Complex", 0
                                db "Die    ", 0
                                db "Socket ", 0


; ================================================================================================
section '.idata' import data readable
; ================================================================================================

library msvcrt,'msvcrt.dll',kernal32,'kernal.dll'
import msvcrt,printf,'printf'
