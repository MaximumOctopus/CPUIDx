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
; ===================================================================================
; =================================================================================== 

; CPUID.01H:ECX
__FeatureStringSize = 66        ; 65 + null terminator
__FeatureString1:               db "SSE3              (Streaming SIMD Extensions 3)                  ", 0
                                db "PCLMULQDQ         (PCLMULQDQ instruction)                        ", 0
                                db "DTES64            (64-bit DS Area)                               ", 0
                                db "MONITOR           (MONITOR/MWAIT)                                ", 0
                                db "DS-CPL            (CPL Qualified Debug Store)                    ", 0
                                db "VMX               (Virtual Machine Extensions)                   ", 0
                                db "SMX               (Safer Mode Extensions)                        ", 0
                                db "EIST              (Enhanced Intel SpeedStep technology)          ", 0
                                db "TM2               (Thermal Monitor 2)                            ", 0
                                db "SSSE3             (Supplemental Streaming SIMD Extensions 3)     ", 0
                                db "L1_CONTEXT_ID     (L1 Context ID)                                ", 0
                                db "DEBUG_INTERFACE   (IA32_DEBUG_INTERFACE MSR)                     ", 0
                                db "FMA               (FMA extensions using YMM state)               ", 0
                                db "CMPXCHG16B        (CMPXCHG16B Available)                         ", 0
                                db "xTPR              (Supports IA32_MISC_ENABLE)                    ", 0
                                db "PERF_CAPABILITIES (Perfmon and Debug Capability)                 ", 0
                                db "Reserved                                                         ", 0
                                db "PCID              (Process-context identifiers)                  ", 0
                                db "DCA               (Prefetch data from a memory-mapped device)    ", 0
                                db "SSE4_1            (SSE4.1)                                       ", 0
                                db "SSE4_2            (SSE4.2)                                       ", 0
                                db "X2APIC            (x2APIC feature)                               ", 0
                                db "MOVBE             (instruction)                                  ", 0
                                db "POPCNT            (instruction)                                  ", 0
                                db "TSC_DEADLINE      (TSC deadline)                                 ", 0
                                db "AESNI             (AESNI instruction extensions)                 ", 0
                                db "XSAVE             (XSAVE/XRSTOR processor extended states)       ", 0
                                db "OSXSAVE           (XSETBV/XGETBV instructions)                   ", 0
                                db "AVX               (AVX instruction extensions)                   ", 0
                                db "F16C              (16-bit floating-point conversion instructions)", 0
                                db "RDRAND            (RDRAND instruction)                           ", 0
                                db "Not used                                                         ", 0 ; Intel processors always return 0. Allocated for use by software emulation.

; CPUID.01H:EDX
__FeatureString2:               db "FPU               (Floating-Point Unit On-Chip)                  ", 0
                                db "VME               (Virtual 8086 Mode Enhancements)               ", 0
                                db "DE                (Debugging Extensions)                         ", 0
                                db "PSE               (Page Size Extension)                          ", 0
                                db "TSC               (Time Stamp Counter)                           ", 0
                                db "MSR               (Model Specific Registers + RDMSR/WRMSR instr.)", 0
                                db "PAE               (Physical Address Extension)                   ", 0
                                db "MCE               (Machine Check Exception)                      ", 0
                                db "CMPXCHG8B         (CMPXCHG8B Instruction)                        ", 0
                                db "APIC              (APIC On-Chip)                                 ", 0
                                db "Reserved                                                         ", 0
                                db "SEP               (SYSENTER and SYSEXIT Instructions)            ", 0
                                db "MTRR              (Memory Type Range Registers)                  ", 0
                                db "PGE               (Page Global Bit)                              ", 0
                                db "MCA               (Machine Check Architecture)                   ", 0
                                db "CMOV              (Conditional Move Instructions)                ", 0
                                db "PAT               (Page Attribute Table)                         ", 0
                                db "PSE_36            (36-Bit Page Size Extension)                   ", 0
                                db "PSN               (Processor Serial Number)                      ", 0
                                db "CLFLUSH           (CLFLUSH Instruction)                          ", 0
                                db "Reserved                                                         ", 0
                                db "DS                (Supports Debug Store feature)                 ", 0
                                db "ACPI              (Thermal Monitor and Software Controlled Clock)", 0
                                db "MMX               (Intel MMX Technology)                         ", 0
                                db "FXSR              (FXSAVE and FXRSTOR Instructions)              ", 0
                                db "SSE               (SSE extensions)                               ", 0
                                db "SSE2              (SSE2 extensions)                              ", 0
                                db "SELF_SNOOP        (Self Snoop)                                   ", 0
                                db "HTT               (Max APIC IDs reserved field is Valid)         ", 0
                                db "TM                (Thermal Monitor)                              ", 0
                                db "Reserved                                                         ", 0
                                db "PBE               (Pending Break Enable)                         ", 0

; CPUID.02H, data stored in eax, ebx, ecx, and edx
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

; CPUID.02H text table
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

; CPUID.06H:EAX
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
                                                   
; CPUID.07H:EBX (intel)
__StructuredExtendedFeatureFlags1Size = 45      ; 44 + null terminator
__StructuredExtendedFeatureFlags1:
                                db "FSGSBASE                                    ", 0
                                db "TSC_ADJUST IA32_TSC_ADJUST MSR              ", 0
                                db "SGX  (Software Guard Extensions)            ", 0
                                db "BMI1                                        ", 0
                                db "HLE                                         ", 0
                                db "AVX2 (Intel Advanced Vector Extensions 2)   ", 0
                                db "FDP_EXCPTN_ONLY                             ", 0
                                db "SMEP (Supervisor-Mode Execution Prevention) ", 0 
                                db "BMI2                                        ", 0
                                db "ENH_REP_MOVSB_STOSB Enhanced REP MOVSB/STOSB", 0
                                db "INVPCID instruction                         ", 0  
                                db "RTM                                         ", 0
                                db "RDT_M                                       ", 0
                                db "FCS_FDS_DEPRECATION Deprecates FPU CS/FPU DS", 0
                                db "MPX  (Intel Memory Protection Extensions)   ", 0
                                db "RDT_A (Intel Resource Director Technology)  ", 0
                                db "AVX512F                                     ", 0
                                db "AVX512DQ                                    ", 0
                                db "RDSEED                                      ", 0
                                db "ADX                                         ", 0
                                db "SMAP (Supervisor-Mode Access Prevention)    ", 0
                                db "AVX512_IFMA                                 ", 0
                                db "Reserved                                    ", 0
                                db "CLFLUSHOPT                                  ", 0
                                db "CLWB                                        ", 0
                                db "INTEL_PROC_TRACE Intel Processor Trace      ", 0
                                db "AVX512PF (Intel Xeon Phi only)              ", 0
                                db "AVX512ER (Intel Xeon Phi only)              ", 0
                                db "AVX512CD                                    ", 0
                                db "SHA (Intel Secure Hash Algorithm Extensions)", 0
                                db "AVX512BW                                    ", 0
                                db "AVX512VL                                    ", 0

; CPUID.07H.00H:ECX (intel)
__StructuredExtendedFeatureFlags2Size = 50      ; 49 + null terminator
__StructuredExtendedFeatureFlags2:
                                db "PREFETCHWT1 (Intel Xeon Phi only)                ", 0
                                db "AVX512_VBMI                                      ", 0
                                db "UMIP (user-mode instruction prevention           ", 0
                                db "PKU (protection keys for user-mode pages)        ", 0
                                db "OSPKE (CR4.PKE (and RDPKRU/WRPKRU))              ", 0
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
                                db "MPX_MAWAU (used by BNDLDX/BNDSTX in 64-bit mode) ", 0
                                db "RDPID     (IA32_TSC_AUX MSR is available)        ", 0
                                db "KEY_LOCKER (support)                             ", 0
                                db "BUS_LOCK_DETECT                                  ", 0
                                db "Reserved                                         ", 0
                                db "RDPID and IA32_TSC_AUX                           ", 0
                                db "KEY_LOCKER (Key Locker)                          ", 0
                                db "BUS_LOCK_DETECT, supports OS bus-lock detection  ", 0
                                db "CLDEMOTE (Supports cache line demote)            ", 0
                                db "Reserved                                         ", 0
                                db "MOVDIRI                                          ", 0
                                db "MOVDIR64B                                        ", 0
                                db "ENQCMD (Enqueue Stores)                          ", 0
                                db "SGX_LC (SGX Launch Configuration)                ", 0
                                db "PKS (protection keys for supervisor-mode pages)  ", 0
                                                                
; CPUID.07H.00H:EDX (intel)
__StructuredExtendedFeatureFlags3Size = 35      ; 34 + null terminator
__StructuredExtendedFeatureFlags3:
                                db "Reserved                          ", 0
                                db "SGX_KEYS                          ", 0
                                db "AVX512_4VNNIW. Intel Xeon Phi only", 0
                                db "AVX512_4FMAPS. Intel Xeon Phi only", 0
                                db "FAST_SHORT_REP_MOVSB              ", 0
                                db "UINTR                             ", 0
                                db "Reserved                          ", 0
                                db "Reserved                          ", 0
                                db "AVX512_VP2INTERSECT               ", 0
                                db "MCU_OPT_CTRL                      ", 0
                                db "MD_CLEAR                          ", 0
                                db "RTM_ALWAYS_ABORT                  ", 0
                                db "Reserved                          ", 0
                                db "RTM_FORCE_ABORT                   ", 0
                                db "SERIALIZE                         ", 0
                                db "HYBRID                            ", 0
                                db "TSXLDTRK                          ", 0
                                db "Reserved                          ", 0
                                db "PCONFIG                           ", 0
                                db "ARCH_LBRS Architectural LBRs      ", 0
                                db "CET_IBT                           ", 0
                                db "Reserved                          ", 0
                                db "AAMX_BF16                         ", 0
                                db "AVX512_FP16                       ", 0
                                db "AMX_TILE                          ", 0
                                db "AMX_INT8                          ", 0
                                db "IBRS and IBPB. IA32_SPEC_CTRL MSR ", 0
                                db "SPEC_CTRL_ST_PREDICTORS           ", 0
                                db "L1D_FLUSH_INTERFACE               ", 0
                                db "ARCH_CAPABILITIES                 ", 0
                                db "CORE_CAPABILITIES                 ", 0
                                db "SPEC_CTRL_SSBD                    ", 0
                                                                
; CPUID.07.01H:EAX (intel)
__StructuredExtendedFeatureSubLeaf1aFlagsSize = 71      ; 70 + null terminator
__StructuredExtendedFeatureSubLeaf1aFlags:
                                db "SHA512           SHA512 instructions supported                        ", 0
                                db "SM3              SM3 instructions supported                           ", 0
                                db "SM4              SM4 instructions supported                           ", 0
                                db "Reserved                                                              ", 0
                                db "AVX_VNNI         AVX (VEX-encoded) versions of the VNNI               ", 0
                                db "AVX512_BF16      VNNI supports BFLOAT16 inputs and conversion         ", 0
                                db "LASS             Supports Linear Address Space Separation             ", 0
                                db "CMPCCXADD        Supports the CMPccXADD instruction                   ", 0
                                db "ARCH_PERFMON_EXT Supports ArchPerfmonExt, Leaf (EAX=23H)              ", 0
                                db "Reserved                                                              ", 0
                                db "FAST_REP_MOVSB   Fast zero-length instructions supported              ", 0
                                db "FAST_REP_STOSB   Supports fast short instructions                     ", 0
                                db "FAST_REP_CMPSB_SCASB. Supports fast short instructions                ", 0
                                db "FRED             Supports Flexible Return and Event Delivery          ", 0
                                db "LKGS             Supports 'load into IA32_KERNEL_GS_BASE' instruction ", 0
                                db "Reserved                                                              ", 0
                                db "Reserved                                                              ", 0
                                db "Reserved                                                              ", 0
                                db "Reserved                                                              ", 0
                                db "WRMSRNS          WRMSRNS instruction supported                        ", 0
                                db "Reserved                                                              ", 0
                                db "AMX_FP16         Supports tile computational operations on FP16 floats", 0
                                db "HRESET           HRESET instruction and IA32_HRESET_ENABLE, Leaf 20H  ", 0
                                db "AVX_IFMA         Supports the AVX-IFMA instructions                   ", 0
                                db "Reserved                                                              ", 0
                                db "Reserved                                                              ", 0
                                db "LAM              Supports Linear Address Masking                      ", 0
                                db "MSRLIST          Supports RDMSRLIST and WRMSRLIST, IA32_BARRIER MSR   ", 0
                                db "Reserved                                                              ", 0
                                db "Reserved                                                              ", 0
                                db "INVD_DISABLE_POST_BIOS_DONE. INVD execution prevention after BIOS Done", 0
                                db "Reserved                                                              ", 0

; CPUID.07H.01H::EDX (intel)
__StructuredExtendedFeatureSubLeaf1dFlagsSize = 55      ; 54 + null terminator
__StructuredExtendedFeatureSubLeaf1dFlags:
                                db "Reserved                                              ", 0
                                db "Reserved                                              ", 0
                                db "Reserved                                              ", 0
                                db "Reserved                                              ", 0
                                db "AVX_VNNI_INT8   Supports AVX-VNNI-INT8 instructions   ", 0
                                db "AVX_NE_CONVERT  AVX-NE-CONVERT instructions           ", 0
                                db "Reserved                                              ", 0
                                db "Reserved                                              ", 0
                                db "Reserved                                              ", 0
                                db "Reserved                                              ", 0
                                db "AVX_VNNI_INT16  Supports AVX-VNNI-INT16 instructions  ", 0
                                db "Reserved                                              ", 0
                                db "Reserved                                              ", 0
                                db "Reserved                                              ", 0
                                db "PREFETCHI       Supports PREFETCHIT0/1 instructions   ", 0
                                db "Reserved                                              ", 0
                                db "Reserved                                              ", 0
                                db "UIRET_UIF       UIRET sets UIF to bit 1 of RFLAGS     ", 0
                                db "CET_SSS         OS can enable supervisor shadow stacks", 0
                                db "AVX10           Intel AVX10 instructions supported    ", 0
                                db "Reserved                                              ", 0
                                db "Reserved                                              ", 0
                                db "SEC-TEE-ATTESTATION                                   ", 0
                                db "MWAIT           MWAIT is supported                    ", 0
                                db "SLSM            Supports IA32_INTEGRITY_STATUS MSR    ", 0
                                db "Reserved                                              ", 0
                                db "Reserved                                              ", 0
                                db "Reserved                                              ", 0
                                db "Reserved                                              ", 0
                                db "Reserved                                              ", 0
                                db "Reserved                                              ", 0
                                db "Reserved                                              ", 0
                                                                
; CPUID.07H.02H:EDX (intel) TO DO TO DO

; CPUID.0DH.00H:EAX (intel)
__ProcExtStateEnumMainSize00 = 52 ; 51 + null terminator
__ProcExtStateEnumMain00:       db "X87 state                                          ", 0
                                db "SSE state                                          ", 0
                                db "AVX state                                          ", 0
                                db "MPX_BNDREGS      (MPX state)                       ", 0
                                db "MPX_BNDCSR       (MPX state)                       ", 0
                                db "AVX512_OPMASK    (AVX-512 opmask state)            ", 0
                                db "AVX512_ZMM_HI256 (AVX-512 ZMM upper 256 data state)", 0
                                db "AVX512_HI16_ZMM  (AVX-512 upper 16 ZMM state)      ", 0
                                db "Always return 0  (Allocated for IA32_XSS)          ", 0
                                db "PKRU state                                         ", 0
                                db "Always return 0  (Allocated for IA32_XSS)          ", 0
                                db "Always return 0  (Allocated for IA32_XSS)          ", 0
                                db "Always return 0  (Allocated for IA32_XSS)          ", 0
                                db "Always return 0  (Allocated for IA32_XSS)          ", 0
                                db "Always return 0  (Allocated for IA32_XSS)          ", 0
                                db "Always return 0  (Allocated for IA32_XSS)          ", 0
                                db "Always return 0  (Allocated for IA32_XSS)          ", 0
                                db "AMX_TILECFG      (TILECFG state)                   ", 0
                                db "AMX_TILEDATA     (TILEDATA state)                  ", 0                                                             

; CPUID.0DH.01H:ECX (intel)
__ProcExtStateEnumMainSize01 = 52 ; 51 + null terminator                                                                
__ProcExtStateEnumMain01:       db "Always return 0  (Allocated for XCR0)              ", 0
                                db "Always return 0  (Allocated for XCR0)              ", 0
                                db "Always return 0  (Allocated for XCR0)              ", 0
                                db "Always return 0  (Allocated for XCR0)              ", 0
                                db "Always return 0  (Allocated for XCR0)              ", 0
                                db "Always return 0  (Allocated for XCR0)              ", 0
                                db "Always return 0  (Allocated for XCR0)              ", 0
                                db "Always return 0  (Allocated for XCR0)              ", 0
                                db "PT               (PT State)                        ", 0
                                                                db "Always return 0  (Allocated for XCR0)              ", 0
                                db "PASID            (PASID state)                     ", 0
                                db "CET_U            (CET user state)                  ", 0
                                db "CET_S            (CET supervisor state)            ", 0
                                db "HDC              (HDC state)                       ", 0
                                db "UINTR            (UINTR state)                     ", 0
                                db "LBR              (LBR state (architectural only)   ", 0
                                db "HWP              (HWP state)                       ", 0
                                db "Always return 0  (Allocated for XCR0)              ", 0
                                db "Always return 0  (Allocated for XCR0)              ", 0
                                ; ECX[31:19] are Reserved
                                                                
; CPUID.0DH.01H:EDX (intel)                                                             
                                ; EDX[31:0] are Reserved

; CPUID.12H.02H:ECX (intel)     ECX[3:0]EPC_SECTION_PROPERTY
__SGXEPCSubLeaf2Size = 67       ; 66 + null terminator
__SGXEPCSubLeaf2:               db "This section has confidentiality, integrity, and replay protection", 0
                                db "This section has confidentiality protection only                  ", 0
                                db "This section has confidentiality and integrity protection         ", 0
                                                                

; CPUID.18H.ECX >= 1, EDX[04:00]TYPE
__DATCacheTypeSize = 13         ; 12 + null terminator
__DATCacheType:                 db "Unknown    :", 0
                                db "Data       :", 0
                                db "Instruction:", 0
                                db "Unified    :", 0
                                db "Load Only  :", 0
                                db "Store Only :", 0

; CPUID.1FH.ECX >= 0, ECX[15:08]DOMAIN_TYPE
__LevelTypeSize = 8             ; 7 + null terminator
__LevelType:                    db "Invalid", 0
                                db "Logical", 0
                                db "Core   ", 0
                                db "Module ", 0
                                db "Tile   ", 0
                                db "Die    ", 0
                                db "Die/Grp", 0

; CPUID.23H.03H, EAX[12:00]
__APMES3Size = 43               ; 42 + null terminator
__APMES3:                       db "CORE_CYC       Core cycles                ", 0 
                                db "INSTR_RET      Instructions retired       ", 0
                                db "REF_CYC        Reference cycles           ", 0
                                db "LLC_REF        Last level cache references", 0
                                db "LLC_MISSES     Last level cache misses    ", 0
                                db "BR_INSTR_RET   Branch instructions retired", 0
                                db "BR_MISPRED_RET Branch mispredicts retired ", 0
                                db "SLOTS          Topdown slots              ", 0
                                db "BACKEND        Topdown backend bound      ", 0
                                db "BADSPEC        Topdown bad speculation    ", 0
                                db "FRONTEND       Topdown frontend bound     ", 0
                                db "RETIRING       Topdown retiring           ", 0
                                db "LBR_INSERTS    LBR inserts                ", 0

; CPUID.80000006, ECX[15:12]
__IntelLevelTwoCacheSize = 19   ; 18 + null terminator
__IntelLevelTwoCache:           db "Disabled          ", 0
                                db "1 way (direct map)", 0
                                db "2 ways            ", 0
                                db "Reserved          ", 0
                                db "4 ways            ", 0
                                db "Reserved          ", 0
                                db "8 ways            ", 0
                                db "See 04H.02H       ", 0 
                                db "16 ways           ", 0
                                db "Reserved          ", 0
                                db "32 ways           ", 0
                                db "48 ways           ", 0
                                db "64 ways           ", 0
                                db "96 ways           ", 0
                                db "128 ways          ", 0
                                db "Fully associative ", 0
                                                                
; ===================================================================================
; ===================================================================================