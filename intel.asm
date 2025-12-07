; ===================================================================================
; ===================================================================================
;
;  (c) Paul Alan Freshney 2022-2025
;  v0.21, December 5th 2025
;
;  Source code:
;      https://github.com/MaximumOctopus/CPUIDx
;
;  Assembled using "Flat Assembler"
;      https://flatassembler.net/
;
; ===================================================================================
; =================================================================================== 

; CPUID.02H, returns data (as bytes, max of 4 per register) in eax, ebc, ecx, and edx
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

; CPUID.04H.00H, data returned in eax, ebx, and ecx
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

; CPUID.05H, data in eax, ebx, ecx, edx
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
                
        bt edi, kINTERRUPT_AS_BREAK_EVENT
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

; CPUID.06H, data in eax
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

; =================================================================================== 

; CPUID.07H, flags in ebx, ecx, and edx
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
                
; CPUID.07H.01:EBX

        mov ecx, 0x01
        mov eax, 0x07           ; sub-leaf 1   
        cpuid
                
        mov esi, ebx
                
        cmp eax, 0              ; eax returns 0 if sub-leaf index (1) is invald
        je subleaf2

        cinvoke printf, "    ebx %02d", esi, 10

.b0100: bt esi, kIA32_PPIN
        jnc .b0103
                
        cinvoke printf, "    PPIN: IA32_PPIN and IA32_PPIN_CTL MSRs %c", 10
                
.b0103: bt esi, kCPUIDMAXVAL_LIM_RMV
        jnc .sl1d
                
        cinvoke printf, "    CPUIDMAXVAL_LIM_RMV. IA32_MISC_ENABLE cannot be set to 1 to limit CPUID.00H:EAX[bits 7:0] %c", 10

; CPUID.07H.01H

.sl1d:  mov ecx, 0x01
        mov eax, 0x07           ; sub-leaf 1   
        cpuid
                
        cmp edx, 0              ; edx returns 0 if sub-leaf index (1) is invald
        je subleaf2
                
        push edx
        cinvoke printf, "    edx %02d", edx, 10         
        pop edx
                
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
                
        jmp sl72

; CPUID.07H.02H

subleaf2: ; sub-leaf 2

        mov esi, dword __LeafInvalid
        call ShowLeafInformation

        ret

sl72:  mov esi, dword __Leaf0702
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
                
.d0206: bt edi, kUC_LOCK_DISABLE
        jnc .d0207

        cinvoke printf, "    Supports the UC-lock disable feature and it causes #AC %c", 10             

.d0207: bt edi, kMONITOR_MITG_NO
        jnc .fin

        cinvoke printf, "    MONITOR_MITG_NO. %c", 10
        cinvoke printf, "    MONITOR/UMONITOR instructions are not affected by performance or power issues %c", 10

.invalid2:

        mov esi, dword __LeafInvalid
        call ShowLeafInformation        

.fin:
        ret

; =============================================================================================
; CPUID.08H (intel)
;
; reserved
;
; =============================================================================================

; CPUID.09H, data in eax only
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

; CPUID.0AH
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

.b1:    bt esi, kCORE_CYC_NA
        jc .b1n

        cmp edi, 1
        jle .b1n
                
.b1y:   cinvoke printf, "    Core cycle event available %c", 10
        jmp .b2

.b1n:   cinvoke printf, "    Core cycle event not available %c", 10

.b2:    bt esi, kINTR_RET_NA
        jc .b2n

        cmp edi, 2
        jle .b2n
                
.b2y:   cinvoke printf, "    Instruction retired event available %c", 10
        jmp .b3

.b2n:   cinvoke printf, "    Instruction retired event not available %c", 10

.b3:    bt esi, kREF_CYC_NA
        jc .b3n

        cmp edi, 3
        jle .b3n
                
.b3y:   cinvoke printf, "    Reference cycles event available %c", 10
        jmp .b4

.b3n:   cinvoke printf, "    Reference cycles event not available %c", 10

.b4:    bt esi, kLLC_CYC_NA
        jc .b4n

        cmp edi, 4
        jle .b4n
                
.b4y:   cinvoke printf, "    Last-level cache reference event available %c", 10
        jmp .b5

.b4n:   cinvoke printf, "    Last-level cache reference event not available %c", 10

.b5:    bt esi, kLLC_MISSES_NA
        jc .b5n

        cmp edi, 5
        jle .b5n
                
.b5y:   cinvoke printf, "    Last-level cache misses event available %c", 10
        jmp .b6

.b5n:   cinvoke printf, "    Last-level cache misses event not available %c", 10

.b6:    bt esi, kBR_INSTR_RET_NA
        jc .b6n

        cmp edi, 6
        jle .b6n
                
.b6y:   cinvoke printf, "    Branch instruction retired event available %c", 10
        jmp .b7

.b6n:   cinvoke printf, "    Branch instruction retired event not available %c", 10

.b7:    bt esi, kBR_MISPRED_RET_NA
        jc .b7n

        cmp edi, 7
        jle .b8n
                
.b7y:   cinvoke printf, "    Branch mispredict retired event available %c", 10
        jmp .b8

.b7n:   cinvoke printf, "    Branch mispredict retired event not available %c", 10

.b8:    bt esi, kSLOTS_NA
        jc .b8n

        cmp edi, 8
        jle .b8n
                
.b8y:   cinvoke printf, "    Top-down slots event available %c", 10
        jmp .fin

.b8n:   cinvoke printf, "    Top-down slots event not available %c", 10

.fin:   ret

; =============================================================================================

; CPUID.0BH, data in eax, ebx, ecx, and edx
; intel implementation
ExtendedTopology:

        cmp [__MaxBasic], 0x1F                  ; 0x1f is the preferred topology leaf, if it's valid on this CPU, ignore 0bh
        jge .fin
                
        mov esi, dword __Leaf1F00
        call ShowLeafInformation
                
        mov ecx, 0
        mov eax, 0x1F                
        cpuid              

        cinvoke printf, "  Extended Topology Enumeration (EAX:0x%x EBX:0x%x ECX:0x%x EDX:0x%x) %c", eax, ebx, ecx, edx, 10

        mov ecx, 0
        mov eax, 0x1F   
        cpuid
                
        cmp eax, 0
        je .fin
                
        mov [__X2APICID], edx
                
        cinvoke printf, "    x2APIC ID of the current logical processor     : %d %c", edx, 10
                
        mov esi, 0                      ; sub-leaf index

        cinvoke printf, "%c", 10

        mov ecx, 0
.loop:  mov eax, 0x1F  
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
; CPUID.0CH (intel)
;
; reserved
;
; =============================================================================================

; CPUID.0DH.00H, data in eax, ebx, ecx
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

; CPUID.0DH.01H, data in eax, ebx, ecx

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
; CPUID.0EH (intel)
;
; reserved
;
; =============================================================================================

; CPUID.0FH.00H
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

        bt edi, kCMT_L3
        jnc .subleaf
                
        cinvoke printf, "    Supports L3 Cache Intel RDT Monitoring %c", 10
                
; CPUID.0FH.01H				
				
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

.bit8:  bt edi, kRDT_M_OVF
        jnc .bit9
                
        cinvoke printf, "    Overflow bit in IA32_QM_CTR MSR bit 61 %c", 10
                
.bit9:  bt edi, kIO_QOS_CMT
        jnc .bita

        cinvoke printf, "    Non-CPU agent Intel RDT CMT support %c", 10
                
.bita:  bt edi, kIO_QOS_MBM
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

        bt esi, kCMT_L3_OCCUP
        jnc .bit1

        cinvoke printf, "    Supports L3 occupancy monitoring %c", 10
                
.bit1:  bt esi, kCMT_L3_TOTAL
        jnc .bit2
                
        cinvoke printf, "    Supports L3 Total Bandwidth monitoring %c", 10
                
.bit2:  bt esi, kCMT_L3_LOCAL
        jnc .fin

        cinvoke printf, "    Supports L3 Local Bandwidth monitoring %c", 10

.fin:   ret

; =============================================================================================                     

; CPUID.10H.00H (data in ebx only)
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
                
.bit1:  bt edi, kCAT_L3
        jnc .bit2
                
        cinvoke printf, "    Supports L3 Cache Allocation Technology %c", 10

.bit2:  bt edi, kCAT_L2
        jnc .bit3
                
        cinvoke printf, "    Supports L2 Cache Allocation Technology %c", 10

.bit3:  bt edi, kMBA
        jnc .subleaf1
                
        cinvoke printf, "    Supports Memory Bandwidth Allocation %c", 10
                
; CPUID.10H.01H (data in eax, ebx, ecx, and edx)

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
                
.bit11: bt edi, kCAT_L3_NONCPU
        jnc .bit12
                                
        cinvoke printf, "    L3 CAT for non-CPU agents is supported %c", 10
                                
.bit12: bt edi, kCAT_L3_CDP
        jnc .cpns1
                
        cinvoke printf, "    L3 Code and Prioritization Technology supported %c", 10
                
        jmp .bit13
                
.cpns1:

        cinvoke printf, "    L3 Code and Prioritization Technology not supported %c", 10

.bit13: bt edi, kCAT_L3_NONCONTIG
        jnc .hcos1
                
        cinvoke printf, "    Non-contiguous capacity bitmask is supported %c", 10
        cinvoke printf, "        The bits in IA32_L3_MASK_n registers do not have to be contiguous %c", 10

.hcos1:

        and esi, 0x0000FFFF
                
        cinvoke printf, "    Highest CLOS number supported for ResID: %d %c", esi, 10

; CPUID.10H.02H (data in eax, ebx, ecx, and edx)

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
                
.bit22: bt edi, kCAT_L2_CDP
        jnc .bit23
                
        cinvoke printf, "    L2 Code and Data Prioritization Technology supported %c", 10
                
        jmp .hcos2
                
.cpns2:

        cinvoke printf, "    Code and Prioritization Technology not supported %c", 10

.bit23: bt edi, kCAT_L2_NONCONTIG
        jnc .hcos2

        cinvoke printf, "    Non-contiguous capacity bitmask is supported %c", 10
        cinvoke printf, "        The bits in IA32_L2_MASK_n registers do not have to be contiguous %c", 10

.hcos2:

        and esi, 0x0000FFFF
                
        cinvoke printf, "    Highest COS number supported for ResID 2: %d %c", esi, 10

; CPUID.10H.03H (data in eax, ecx, and edx)

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
                
        bt edi, kMBA_LINEAR
        jnc .dnl
                
        cinvoke printf, "    Response of the delay values is linear %c", 10
                
        jmp .hcos3
                
.dnl:   cinvoke printf, "    Response of the delay values is not linear %c", 10

.hcos3: and esi, 0x0000FFFF	; MBA_MAX_CLOS

        cinvoke printf, "    Highest COS number supported for ResID 3: %d %c", esi, 10

.fin:

        ret

; =============================================================================================
; CPUID.11H (intel)
;
; reserved
;
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
                
        bt eax, kSGX1
        jnc .bit1
                
        push eax
        cinvoke printf, "    Intel SGX supports the collection of SGX1 leaf functions %c", 10
        pop eax
                
.bit1:  bt eax, kSGX2
        jnc .bit7
                
        push eax
        cinvoke printf, "    Intel SGX supports the collection of SGX2 leaf functions %c", 10
        pop eax
                
;.bit5:  bt eax, kENCLVx	; removed in the June 2025 update
;        jnc .bit6
;
;        push eax
;        cinvoke printf, "    Intel SGX supports ENCLV instructions (EINCVIRTCHILD, EDECVIRTCHILD, and ESETCONTEXT) %c", 10
;        pop eax

;.bit6:  bt eax, kENCLSx
;        jnc .bit7
                
;        push eax
;        cinvoke printf, "    Intel SGX supports ENCLS instructions (ETRACKC, ERDINFO, ELDBC, and ELDUC) %c", 10
;        pop eax
                
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
                
        cinvoke printf, "    MAX_ENCLAVE_SIZE_NOT_64 = 2^%d %c", eax, 10
                
        shr esi, 8
        and esi, 0x000000FF

        cinvoke printf, "    MAX_ENCLAVE_SIZE_64 = 2^%d %c", esi, 10

; CPUID.12H.01H, data in eax, ebx, ecx, and edx

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

; CPUID.12H.02H, data in eax, ebx, ecx, and edx

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
; CPUID.13H (intel)
;
; reserved
;
; =============================================================================================

; CPUID.14H, data in eax, ebx, and ecx
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
                
.bbit0: bt edi, kCR3_FILTER
        jnc .bbit1
                
        cinvoke printf, "    IA32_RTIT_CTL.CR3Filter can be set to 1, IA32_RTIT_CR3_MATCH MSR can be accessed %c", 10

.bbit1: bt edi, kCYC_ACC
        jnc .bbit2

        cinvoke printf, "    Configurable PSB and Cycle-Accurate Mod is supported %c", 10

.bbit2: bt edi, kIP_FILTER
        jnc .bbit3

        cinvoke printf, "    IP Filtering, TraceStop filtering, and preservation of Intel PT MSRs across warm reset. %c", 10

.bbit3: bt edi, kMTC
        jnc .bbit4

        cinvoke printf, "    MTC timing packet and suppression of COFI-based packets is supported %c", 10

.bbit4: bt edi, kPTWRITE
        jnc .bbit5

        cinvoke printf, "    PTWRITE. Writes can set IA32_RTIT_CTL[12] (PTWEn) and IA32_RTIT_CTL[5] (FUPonPTW),%c", 10
        cinvoke printf, "      and PTWRITE can generate packets is supported %c", 10

.bbit5: bt edi, kPWR_EVT_TRACE
        jnc .bbit6

        cinvoke printf, "    Power Event Trace. Writes can set IA32_RTIT_CTL[4] (PwrEvtEn), enabling Power Event Trace packet generation. %c", 10

.bbit6: bt edi, kPMI_PRESERVE
        jnc .bbit7

        cinvoke printf, "    PSB and PMI preservation. Writes can set IA32_RTIT_CTL[56] (InjectPsbPmiOnEnable), enabling the processor %c", 10 
        cinvoke printf, "      to set IA32_RTIT_STATUS[7] (PendTopaPMI) and/or IA32_RTIT_STATUS[6] (PendPSB) in order to preserve ToPA PMIs %c", 10
        cinvoke printf, "      and/or PSBs otherwise lost due to Intel PT disable. Writes can also set PendToPAPMI and PendPSB. %c", 10

.bbit7: bt edi, kEVENT_TRACE
        jnc .bbit8

        cinvoke printf, "    Writes can set IA32_RTIT_CTL[31] (EventEn), enabling Event Trace packet generation %c", 10

.bbit8: bt edi, kTNT_DIS
        jnc .cbit0

        cinvoke printf, "    Writes can set IA32_RTIT_CTL[55] (DisTNT), disabling TNT packet generation %c", 10

.cbit0: bt esi, kTOPAOUT
        jnc .cbit1

        cinvoke printf, "    Tracing can be enabled with IA32_RTIT_CTL.ToPA = 1, hence utilizing the ToPA output scheme; %c", 10
        cinvoke printf, "      IA32_RTIT_OUTPUT_BASE and IA32_RTIT_OUTPUT_MASK_PTRS MSRs can be accessed %c", 10
                
.cbit1: bt esi, kMENTRY
        jnc .cbit2

        cinvoke printf, "    ToPA tables can hold any number of output entries, up to the maximum allowed by the MaskOrTableOffset %c", 10
        cinvoke printf, "      field of IA32_RTIT_OUTPUT_MASK_PTRS %c", 10
                
.cbit2: bt esi, kSNGL_RNG_OUT
        jnc .cbit3

        cinvoke printf, "    Single-Range Output scheme is supported %c", 10

.cbit3: bt esi, kTRACE_TRANSPORT_SUBSYSTEM
        jnc .cbitx

        cinvoke printf, "    Indicates support of output to Trace Transport subsystem %c", 10

.cbitx: bt esi, kLIP
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

; CPUID.15H, data in eax, ebx, and ecx
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
                
.nf:    cmp edi, 0       ; NOMINAL_ART_FREQUENCY
        je .nfnotenumerated
                
        cinvoke printf, "    Core crystal clock nominal freq: %d Hz %c", edi, 10
                
        ret
                
.nfnotenumerated:

        cinvoke printf, "    Core crystal clock nominal freq not enumerated %c", 10

.fin:   ret

; =============================================================================================

; CPUID.16H, data in eax, ebx, and ecx
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

.bf:    cmp eax, 0      ; PROCESSOR_BASE_FREQUENCY
        je .bfns

        cinvoke printf, "    Base Frequency      : %d MHz %c", eax, 10

        jmp .mf
                
.bfns:  cinvoke printf, "    Base Frequency      : Unknown %c", 10

.mf:    cmp edi, 0       ; MAXIMUM_FREQUENCY
        je .mfns

        cinvoke printf, "    Maximum Frequency   : %d MHz %c", edi, 10
                
        jmp .rf
                
.mfns:  cinvoke printf, "    Maximum Frequency   : Unknown %c", 10
                
.rf:    cmp esi, 0       ; BUS_FREQUENCY
        je .rfns
                
        cinvoke printf, "    Bus (Ref) Frequency :  %d MHz %c", esi, 10
                
        jmp .fin
                
.rfns:  cinvoke printf, "    Bus (Ref) Frequency : Unknown %c", 10

.fin:   ret

; =============================================================================================

; CPUID.17H, data in eax, ebx, ecx, and edx
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

        bt edi, kIS_VENDOR_SCHEME
        jnc .p2

        cinvoke printf, "    IS_VENDOR_SCHEME (vendor ID is industry standard) %c", ebx, 10

.p2:    mov ecx, 0
        mov eax, 0x17
        cpuid

        mov edi, ecx
        mov esi, edx

        cinvoke printf, "    Project ID : 0x%x %c", edi, 10

        cinvoke printf, "    Stepping ID: 0x%x %c", esi, 10

.fin:   ret

; =============================================================================================

; CPUID.18H, data in eax, ebx, ecx, and edx
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

.bit0:  bt ebx, k4KB_ENTRIES
        jnc .bit1

        cinvoke printf, "    %s 4K page size, %d ways of associativity, %d sets %c", edi, eax, ecx, 10

.bit1:  bt ebx, k2MB_ENTRIES
        jnc .bit2
                
        cinvoke printf, "    %s 2MB page size, %d ways of associativity, %d sets %c", edi, eax, ecx, 10

.bit2:  bt ebx, k4MB_ENTRIES
        jnc .bit3

        cinvoke printf, "    %s 4MB page size, %d ways of associativity, %d sets %c", edi, eax, ecx, 10

.bit3:  bt ebx, k1GB_ENTRIES
        jnc .next
                
        cinvoke printf, "    %s 1GB page size, %d ways of associativity, %d sets %c", edi, eax, ecx, 10

.next:  inc esi

        jmp .loop

.fin:   ret

; =============================================================================================

; CPUID.19H, data in eax, ebx, and ecx
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

        bt edi, kCPL0_RESTRICT
        jnc .a01

        cinvoke printf, "    Key Locker restriction of CPL0-only supported %c", 10

.a01:   bt edi, kNO_ENCRYPT_RESTRICT
        jnc .a02

        cinvoke printf, "    Key Locker restriction of no-encrypt supported %c", 10

.a02:   bt edi, kNO_DECRYPT_RESTRICT
        jnc .b00

        cinvoke printf, "    Key Locker restriction of no-decrypt supported %c", 10

.b00:   mov eax, 0x19
        cpuid
                
        mov edi, ebx
        mov esi, ecx

        bt edi, kAESKLE
        jnc .b02
                
        cinvoke printf, "    AESKLE. AES Key Locker instructions are fully enabled %c", 10
                
.b02:   bt edi, kAES_WIDE
        jnc .b04
                
        cinvoke printf, "    AES wide Key Locker instructions are supported %c", 10

.b04:   bt edi, kIWKEYBACKUP
        jnc .c00

        cinvoke printf, "    Platform supports the Key Locker MSRs %c", 10
        cinvoke printf, "      (IA32_COPY_LOCAL_TO_PLATFORM, IA23_COPY_PLATFORM_TO_LOCAL, %c", 10
        cinvoke printf, "       IA32_COPY_STATUS, and IA32_IWKEYBACKUP_STATUS) %c", 10

.c00:   bt esi, kNOBACKUP
        jnc .c01

        cinvoke printf, "    NoBackup parameter to LOADIWKEY is supported %c", 10

.c01:   bt esi, kRAND_IWKEY
        jnc .fin

        cinvoke printf, "    KeySource encoding of 1 (randomization of the internal wrapping key) is supported %c", 10

.fin:   ret

; =============================================================================================

; CPUID.1AH, data in eax
; intel only
NativeModelIDEnumeration:

        cmp [__MaxBasic], 0x1A
        jl .finish
                
        mov esi, dword __Leaf1A00
        call ShowLeafInformation

        cinvoke printf, "  Native Model ID Enumeration %c", 10

        mov ecx, 0
        mov eax, 0x1A   
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

; CPUID.1BH, data in eax, ebx, ecx, and edx
; intel only
GetPCONFIG:

        mov esi, dword __Leaf1B00
        call ShowLeafInformation

        mov ecx, 0
        mov eax, 0x1B                
        cpuid
                
        cmp eax, 0              ; value of 0 in eax indicates no support
        je .fin
                
        mov ecx, 1              ; only other sub-leaf currently supported
        mov eax, 0x1B  
        cpuid

        cinvoke printf, "  PCONFIG: EAX:0x%x EBX:0x%x ECX:0x%x EDX:0x%x %c", eax, ebx, ecx, edx, 10
                
.fin:   ret

; =============================================================================================

; CPUID.1CH, data in eax, ebx, and ecx
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
                
        bt edi, kDEEP_C_STATE_RESET
        jnc .a31
                
        cinvoke printf, "    Deep C-state Reset %c", 10
                
.a31:   bt edi, kIP_VALUES_CONTAIN_LIP
        jnc .pass2
                
        cinvoke printf, "    IP Values Contain LIP %c", 10
                
.pass2: mov eax, 0x1C   
        cpuid
                
        mov edi, ebx
        mov esi, ecx
                
.b00:   bt edi, kCPL_FILTERING
        jnc .b01
                
        cinvoke printf, "    CPL Filtering Supported %c", 10
                
.b01:   bt edi, kBRANCH_FILTERING
        jnc .b02
                
        cinvoke printf, "    Branch Filtering Supported %c", 10
                
.b02:   bt edi, kCALL_STACK_MODE
        jnc .c00
                
        cinvoke printf, "    Call-stack Mode Supported %c", 10
                
.c00:   bt esi, kMISPREDICT_BIT
        jnc .c01

        cinvoke printf, "    Mispredict Bit Supported %c", 10

.c01:   bt esi, kTIMED_LBRS
        jnc .c02

        cinvoke printf, "    Timed LBRs Supported %c", 10

.c02:   bt esi, kBRANCH_TYPE_FIELD_SUPPORTED
        jnc .c03

        cinvoke printf, "    Branch Type Field Supported %c", 10

.c03:   shr esi, 16             ; bits 19-16 are event logging supported bitmap (EVENT_LOGGING_BITMAP)
        and esi, 0x0F
                
        cinvoke printf, "    Event logging supported bitmap 0x%x %c", esi, 10

.fin:   ret

; =============================================================================================

; CPUID.1DH.00H
; CPUID.1DH.01H
; data in eax, ebx, ecx
; intel only
TileInformation:

        cmp [__MaxBasic], 0x1D
        jl .fin

        mov esi, dword __Leaf1D00
        call ShowLeafInformation

        cinvoke printf, "  Tile Information %c", 10

        mov ecx, 0
        mov eax, 0x1D
        cpuid
                
        cinvoke printf, "    MAX_PALETTE: %d %c", eax, 10

        mov ecx, 1
        mov eax, 0x1D
        cpuid

        mov edi, eax
        mov esi, ebx

        and eax, 0x0000FFFF

        cinvoke printf, "    TOTAL_TILE_BYTES          : %d %c", eax, 10
                
        shr edi, 16
        and edi, 0x0000FFFF
                
        cinvoke printf, "    BYTES_PER_TILE            : %d %c", edi, 10
                
        mov eax, esi
                
        and eax, 0x0000FFFF
                
        cinvoke printf, "    BYTES_PER_ROW             : %d %c", eax, 10

        shr esi, 16
        and esi, 0x0000FFFF
                
        cinvoke printf, "    MAX_NAMES (tile_registers): %d %c", esi, 10
                
        mov ecx, 1
        mov eax, 0x1D
        cpuid
                
        and ecx, 0x0000FFFF
                
        cinvoke printf, "    MAX_ROWS                  : %d %c", ecx, 10

.fin:   ret

; =============================================================================================

; CPUID.1EH.00H, data in ebx
; intel only
TMULInformation:

        cmp [__MaxBasic], 0x1E
        jl .fin
                
        mov esi, dword __Leaf1E00
        call ShowLeafInformation

        cinvoke printf, "  Branch Type Field Supported %c", 10

        mov ecx, 0
        mov eax, 0x1E
        cpuid
                
        mov edi, eax
        mov esi, eax
                
        and edi, 0x000000FF
                
        cinvoke printf, "    TMUL_MAXK = %d %c", edi, 10
                
        shr esi, 8
        and esi, 0x0000FFFF
                
        cinvoke printf, "    TMUL_MAXN = %d %c", esi, 10
                
.fin:   ret

; =============================================================================================

; CPUID.1FH, data in eax, ebx, ecx, and edx
; intel only
V2ExtendedTopology:

        cmp [__MaxBasic], 0x1F
        jl .fin

        mov esi, dword __Leaf1F00
        call ShowLeafInformation

        cinvoke printf, "  V2 Extended Topology Enumeration %c", 10

        mov ecx, 0
        mov eax, 0x1F   
        cpuid
                
        cmp eax, 0
        je .fin
                
        mov [__X2APICID], edx
                
        cinvoke printf, "    x2APIC ID of the current logical processor     : %d %c", edx, 10
                
        mov esi, 0              ; sub-leaf index

        cinvoke printf, "%c", 10

        mov ecx, 0
.loop:  mov eax, 0x1F   
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

; CPUID.20H, data in eax and ebx
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

; CPUID.21H
; Intel only

; Reserved. EAX/EBX/ECX/EDX = 0
;

; =============================================================================================

; CPUID.22H
; Intel only

; Reserved. EAX/EBX/ECX/EDX = 0
                  
; =============================================================================================

; CPUID.23H.00H, data in eax, ebx, ecx (edx reserved)
; intel only

APMEMain:

        mov ecx, 0x01
        mov eax, 0x07           ; sub-leaf 1   
        cpuid
                
        bt eax, kARCH_PERFMON_EXT ; if set, then 23h is supported
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

.bb0:   bt edi, kUNITMASK2
        jnc .bb1

        cinvoke printf, "    UNITMASK2. Supports UnitMask2 field in IA32_PERFEVTSELx MSRs. %c", 10

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

; CPUID.23H.01H, data in eax, ebx (ecx/edx reserved)
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

; CPUID.23H.02H, data in eax, ebx, ecx, edx
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

; CPUID.23H.03H, data in eax (ebx/ecx/edx reserved)
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

; CPUID.24H.00H, data in eax, ebx (ecx/edx reserved)
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

        cinvoke printf, "    Sub-leaves supported by 24H: %c", edi, 10

        mov edi, esi 

        and esi, 0x000000FF       ; bits 07-00

        cinvoke printf, "    Intel AVX10 Converged Vector ISA version 0x%x (%d) %c", esi, esi, 10

		; changed in March 2025 update (see 24H.00H, EBX[18:16 in the spec)
		; all processors supporting AVX10 support all vector widths.
        cinvoke printf, "    128/256/512-bit vector widths supported %c", 10

.fin:   ret

; =============================================================================================

; 40000000h to 400000FFh — Reserved for Hypervisor Use
; These function numbers are reserved for use by the virtual machine monitor.

; =============================================================================================

; CPUID.80000002H / CPUID.80000003H / CPUID.80000004H
; data in eax, ebx, ecx, and edx
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

; CPUID.80000005H
; Intel only

; Reserved. EAX/EBX/ECX/EDX = 0
                  
; =============================================================================================
          
; CPUID.80000006H, data in ecx
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

; CPUID.80000007H, data in edx
; Intel implementation
InvariantTSC:

        mov eax, dword [__MaxExtended]

        cmp eax, 0x80000007
        jl .notsupported

        mov esi, dword __Leaf80__07
        call ShowLeafInformation

        mov eax, 0x80000007
        cpuid
                
        bt edx, kTSC_INVARIANT
        jnc .notavailable
                
        cinvoke printf, "    Invariant TSC available %c", 10
                
        ret
                
.notavailable:

        cinvoke printf, "    Invariant TSC not available %c", 10
                
.notsupported:

        ret

; =============================================================================================

; CPUID.80000008H, data in eax and ebx
; intel implementation
AddressBits:

        mov eax, dword [__MaxExtended]

        cmp eax, 0x80000008
        jl .fin

        mov esi, dword __Leaf80__08
        call ShowLeafInformation

        mov eax, 0x80000008
        cpuid

        mov esi, eax

        and eax, 0x000000FF     ; isolate EAX[7:0] (PHYS_ADDR_SIZE)

        mov edi, esi

        shr edi, 8              ; isolate EAX[15:08] (LIN_ADDR_SIZE)
        and edi, 0x000000FF

        shr esi, 16             ; isolate EAX[23:16] (GUEST_PHYS_ADDR_SIZE)
        and esi, 0x000000FF
                
        cinvoke printf, "    #Physical Address Bits       : %d %c", eax, 10
        cinvoke printf, "    #Linear Address Bits         : %d %c", edi, 10
        cinvoke printf, "    #Guest Physical Address Bits*: %d %c", esi, 10
        cinvoke printf, "     *This value applies only to software operating in a virtual machine %c", 10
        cinvoke printf, "      (Intel processors enumerate this value as zero). When this field is zero, refer to %c", 10
        cinvoke printf, "      #Physical Address Bits for the number of guest physical address bits %c %c", 10, 10
             
        mov eax, 0x80000008
        cpuid
                
        bt ebx, kWBNOINVD
        jnc .notsupported
                
        cinvoke printf, "    WBNOINVD is available %c", 10

        ret

.notsupported:

        cinvoke printf, "    WBNOINVD is not available %c", 10

.fin:   ret

; =============================================================================================
; =============================================================================================