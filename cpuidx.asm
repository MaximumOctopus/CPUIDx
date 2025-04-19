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
;          December  2024
;          March     2025
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

About:  cinvoke printf, "%c    CPUidx v0.19 :: April 19th 2025 :: Paul A Freshney %c", 10, 10

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

        cinvoke GetActiveProcessorCount, 0xffff  ; all processor groups

        cinvoke printf, "    Logical processors %d %c", eax, 10

        ret

.singlecore:

        cinvoke printf, "    Single core CPU %c", 10

        ret

.amd:

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