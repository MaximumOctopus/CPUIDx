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


; 07h leaf (amd), bits in ebx
__AMDStructuredExtendedFeatureIDs1Size = 49     ; 48 + null terminator
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
__AMDStructuredExtendedFeatureIDs2Size = 47     ; 46 + null terminator
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
                                                                
; ===================================================================================
; ===================================================================================