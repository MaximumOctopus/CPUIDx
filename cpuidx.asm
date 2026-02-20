; ===================================================================================
; ===================================================================================
;
;  (c) Paul Alan Freshney 2022-2026
;  v0.22, February 20th 2026
;
;  Source code:
;      https://github.com/MaximumOctopus/CPUIDx
;
;  Assembled using "Flat Assembler"
;      https://flatassembler.net/
;
;  Resources used:
;      AMD64 Architecture Programmer’s Manual Volume 3: General-Purpose and System Instructions
;         2022 October
;         2023 June
;         2024 March
;         2025 July
;      Intel® 64 and IA-32 Architectures Software Developer's Manual Volume 2
;         2022 December
;         2023 March, September, December
;         2024 March, June, October, December
;         2025 March, June, October
;         2026 February
;
;      Intel® 64 and IA-32 Architectures Software Developer's Manual Documentation Changes
;         https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html
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

        call BrandString                        ; CPUID.80000002H, CPUID.80000003H, CPUID.80000004H

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

        call ProcessorSerialNumber              ; CPUID.03H

        call MonitorMWait                       ; CPUID.05H

        call ThermalPower                       ; CPUID.06H

        call StructuredExtendedFeatureFlags     ; CPUID.07H

        call DirectCacheAccessInfo              ; CPUID.09H

        call ArchitecturalPerfMon               ; CPUID.0AH
                
        call ExtendedTopology                   ; CPUID.0BH

        call ProcExtStateEnumMain               ; CPUID.0DH.00H

        call ProcExtStateEnumSub1               ; CPUID.0DH.01H          

        call InternalCache                      ; CPUID.02H

        call CacheTlb                           ; CPUID.04H

        call IntelRDTMonitoring                 ; CPUID.0FH

        call IntelRDTAllocEnum                  ; CPUID.10H

        call IntelSGXCapability                 ; CPUID.12H

        call IntelProcessorTrace                ; CPUID.14H

        call TimeStampCounter                   ; CPUID.15H

        call ProcessorFreqInfo                  ; CPUID.16H

        call SoCVendor                          ; CPUID.17H

        call DATParameters                      ; CPUID.18H

        call KeyLocker                          ; CPUID.19H

        call NativeModelIDEnumeration           ; CPUID.1AH
                
        call GetPCONFIG                         ; CPUID.1BH

        call LastBranchRecords                  ; CPUID.1CH

        call TileInformation                    ; CPUID.1DH

        call TMULInformation                    ; CPUID.1EH
                
        call V2ExtendedTopology                 ; CPUID.1FH
                
        call ProcessorHistoryReset              ; CPUID.20H
                
        call APMEMain                           ; CPUID.23H
                
        call ConvergedVectorISAMain             ; CPUID.24H

        call IRDTAM                             ; CPUID.27H
		
        call IRDTAA                             ; CPUID.28H		

; =============================================================================================
                
        mov [__MaxExtended], eax
        cmp eax, 0x80000000

        jl .finish
                
        cinvoke printf, "%c      == Extended Leafs ======================== %c %c", 10, 10, 10

        call ExtendedFeatures                   ; CPUID.80000001H
                
        call IntelCacheInformation              ; CPUID.80000006H

        call InvariantTSC                       ; CPUID.80000007H

        call AddressBits                        ; CPUID.80000008H

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
                
        call AMDMonitorMWait                    ; CPUID.05H

        call PowerManagementRelated             ; CPUID.06H
                
        call AMDStructuredExtendedFeatureIDs    ; CPUID.07H

        call AMDProcExtTopologyEnum             ; CPUID.0BH

        call AMDProcExtStateEnum                ; CPUID.0DH
                
        call AMDPQOSMonitoring                  ; CPUID.0FH
                
        call AMDPQECapabilities                 ; CPUID.10H
                
; =============================================================================================
                
        mov [__MaxExtended], eax
        cmp eax, 0x80000000

        jl .finish              
                
        cinvoke printf, "%c      == Extended Leafs ======================== %c %c", 10, 10, 10

        call ExtendedFeatures                   ; CPUID.80000001H

        call AMDCacheTLBLevelOne                ; CPUID.80000005H

        call AMDCacheTLBLevelThreeCache         ; CPUID.80000006H

        call PPMandRAS                          ; CPUID.80000007H

        call ProcessorCapacityParameters        ; CPUID.80000008H

        call AMDSVM                             ; CPUID.8000000AH

        call AMDTLBCharacteristics              ; CPUID.80000019H

        call AMDPerformanceOptimisation         ; CPUID.8000001AH

        call AMDIBS                             ; CPUID.8000001BH

        call AMDLightweightProfiling            ; CPUID.8000001CH

        call AMDCache                           ; CPUID.8000001DH

        call AMDEMS                             ; CPUID.8000001FH

        call AMDQOS                             ; CPUID.80000020H

        call AMDEFI2                            ; CPUID.80000021H

        call AMDExtPMandD                       ; CPUID.80000022H

        call AMDMultiKeyEMC                     ; CPUID.80000023H
                
        call AMDSEV2                            ; CPUID.80000025H

        call AMDExtendedCPUTop                  ; CPUID.80000026H

.finish:

        cinvoke printf, "%c %c -- End of Report %c", 10, 10, 10

        xor eax, eax
        ret

; =============================================================================================
; =============================================================================================

About:  cinvoke printf, "%c    CPUidx v0.22 :: February 20th 2026 :: Paul A Freshney %c", 10, 10

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

        ret

.finish:

        cinvoke printf, "%c", 10

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

lf1:    bt eax, esi
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

        cinvoke printf, "    Logical processors: %d %c", eax, 10

        ret

.singlecore:

        cinvoke printf, "    Single core CPU %c", 10

        ret

.amd:

        ret

; =============================================================================================

; CPUID.03H, data in ecx, and edx
; Available in Pentium III processor only; otherwise, the value in this register is reserved
ProcessorSerialNumber:

        mov eax, 0x01                
        cpuid
                
        bt edx, kPSN            ; check if PSN is supported
        jnc .fin

        cinvoke printf, "  Processor serial number (bits 0-63) 0x%x%x %c", edx, ecx, 10

.fin:   ret

; =============================================================================================

include "amd.asm"

include "intel.asm"

; =============================================================================================

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

include 'intel.inc'

include 'amd.inc'

; =============================================================================================
; =============================================================================================
; =============================================================================================

__LeafInvalid:                  db "  Invalid", 0
__Leaf01ECX:                    db "(CPUID.01H:ECX)", 0
__Leaf01EDX:                    db "(CPUID.01H:EDX)", 0
__Leaf02:                       db "(CPUID.02H)", 0
__Leaf0400:                     db "(CPUID.04H:00H)", 0
__Leaf05:                       db "(CPUID.05H)", 0
__Leaf06:                       db "(CPUID.06H)", 0
__Leaf0700:                     db "(CPUID.07H.00H)", 0
__Leaf0701:                     db "(CPUID.07H.01H)", 0
__Leaf0702:                     db "(CPUID.07H.02H)", 0
__Leaf09:                       db "(CPUID.09H)", 0
__Leaf0A:                       db "(CPUID.0AH)", 0
__Leaf0B00:                     db "(CPUID.0BH.00H)", 0
__Leaf0B01:                     db "(CPUID.0BH.01H)", 0
__Leaf0D00:                     db "(CPUID.0DH.00H)", 0
__Leaf0D01:                     db "(CPUID.0DH.01H)", 0
__Leaf0D02:                     db "(CPUID.0DH.02H)", 0
__Leaf0D0B:                     db "(CPUID.0DH.0BH)", 0
__Leaf0D0C:                     db "(CPUID.0DH.0CH)", 0
__Leaf0D3E:                     db "(CPUID.0DH.3EH)", 0
__Leaf0F00:                     db "(CPUID.0FH.00H)", 0
__Leaf0F01:                     db "(CPUID.0FH.01H)", 0
__Leaf1000:                     db "(CPUID.10H.00H)", 0
__Leaf1001:                     db "(CPUID.10H.01H)", 0
__Leaf1002:                     db "(CPUID.10H.02H)", 0
__Leaf1003:                     db "(CPUID.10H.03H)", 0
__Leaf1200:                     db "(CPUID.12H.00H)", 0
__Leaf1201:                     db "(CPUID.12H.01H)", 0
__Leaf1202:                     db "(CPUID.12H.02H)", 0
__Leaf1400:                     db "(CPUID.14H.00H)", 0
__Leaf1401:                     db "(CPUID.14H.01H)", 0
__Leaf15:                       db "(CPUID.15H)", 0
__Leaf16:                       db "(CPUID.16H)", 0
__Leaf1700:                     db "(CPUID.17H.00H)", 0
__Leaf18:                       db "(CPUID.18H)", 0
__Leaf19:                       db "(CPUID.19H)", 0
__Leaf1A00:                     db "(CPUID.1AH.00H)", 0
__Leaf1B00:                     db "(CPUID.1BH.00H)", 0
__Leaf1C00:                     db "(CPUID.1CH.00H)", 0
__Leaf1D00:                     db "(CPUID.1DH.00H)", 0
__Leaf1D01:                     db "(CPUID.1DH.01H)", 0
__Leaf1E00:                     db "(CPUID.1EH.00H)", 0
__Leaf1F00:                     db "(CPUID.1FH.00H)", 0
__Leaf20:                       db "(CPUID.20H)", 0
__Leaf2300:                     db "(CPUID.23H.00H)", 0
__Leaf2301:                     db "(CPUID.23H.01H)", 0
__Leaf2302:                     db "(CPUID.23H.02H)", 0
__Leaf2303:                     db "(CPUID.23H.03H)", 0
__Leaf2304:                     db "(CPUID.23H.04H)", 0
__Leaf2305:                     db "(CPUID.23H.05H)", 0
__Leaf2400:                     db "(CPUID.24H.00H)", 0
__Leaf2700:                     db "(CPUID.27H.00H)", 0
__Leaf2701:                     db "(CPUID.27H.01H)", 0
__Leaf2800:                     db "(CPUID.28H.00H)", 0
__Leaf2801:                     db "(CPUID.28H.01H)", 0
__Leaf2802:                     db "(CPUID.28H.02H)", 0
__Leaf2803:                     db "(CPUID.28H.03H)", 0
__Leaf80__01:                   db "(CPUID.80000001H)", 0
__Leaf80__02:                   db "(CPUID.80000002H)", 0
__Leaf80__05:                   db "(CPUID.80000005H)", 0
__Leaf80__06:                   db "(CPUID.80000006H)", 0
__Leaf80__07:                   db "(CPUID.80000007H)", 0
__Leaf80__08:                   db "(CPUID.80000008H)", 0
__Leaf80__0A:                   db "(CPUID.8000000AH)", 0
__Leaf80__0F:                   db "(CPUID.8000000FH)", 0
__Leaf80__19:                   db "(CPUID.80000019H)", 0
__Leaf80__1A:                   db "(CPUID.8000001AH)", 0
__Leaf80__1B:                   db "(CPUID.8000001BH)", 0
__Leaf80__1C:                   db "(CPUID.8000001CH)", 0
__Leaf80__1D:                   db "(CPUID.8000001DH)", 0
__Leaf80__1E:                   db "(CPUID.8000001EH)", 0
__Leaf80__1F:                   db "(CPUID.8000001FH)", 0
__Leaf80__20:                   db "(CPUID.80000020H)", 0
__Leaf80__20_1:                 db "(CPUID.80000020H.01H)", 0
__Leaf80__20_2:                 db "(CPUID.80000020H.02H)", 0
__Leaf80__20_3:                 db "(CPUID.80000020H.03H)", 0
__Leaf80__20_5:                 db "(CPUID.80000020H.05H)", 0
__Leaf80__21:                   db "(CPUID.80000021H)", 0
__Leaf80__22:                   db "(CPUID.80000022H)", 0
__Leaf80__23:                   db "(CPUID.80000023H)", 0
__Leaf80__25:                   db "(CPUID.80000025H)", 0
__Leaf80__26:                   db "(CPUID.80000026H)", 0
__Leaf80__FF:                   db "(CPUID.800000FFH)", 0

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