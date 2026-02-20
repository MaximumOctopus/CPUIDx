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


kHTT = 28                       ; CPUID.01H:EDX (Intel)

kPQOS = 12                      ; CPUID.01H (AMD)

kPSN = 18                       ; CPUID.03H

kWBINVD = 0                     ; CPUID.04H
kCacheInclusiveLowerLevels = 1
kComplexFunctionIndexCache = 2

kINTERRUPT_AS_BREAK_EVENT  = 1  ; CPUID.05H (Intel)

kEMX = 0                        ; CPUID.05H (AMD)
kIBE = 1

kARAT = 6                       ; CPUID.06H (AMD)
kEffFreq = 0

kSGX = 2                        ; CPUID.07H.00H:EBX (Intel)

kIA32_PPIN = 0                  ; CPUID.07H.01H (Intel)
kPBNDKB = 1
kCPUIDMAXVAL_LIM_RMV = 3
kARCH_PERFMON_EXT = 8
kAVX10 = 19

kPSFD = 0                       ; CPUID.07H.02H (Intel)
kIPRED_CTRL = 1
kRRSBA_CTRL = 2
kDDPD_U = 3
kBHI_CTRL = 4
kMCDT_NO = 5
kUC_LOCK_DISABLE = 6
kMONITOR_MITG_NO = 7

kAnyThread = 15                 ; CPUID.08H and CPUID.0AH (Intel)

kCORE_CYC_NA = 0;               ; CPUID.0AH
kINTR_RET_NA = 1;
kREF_CYC_NA = 2;
kLLC_CYC_NA = 3;
kLLC_MISSES_NA = 4;
kBR_INSTR_RET_NA = 5;
kBR_MISPRED_RET_NA = 6;
kSLOTS_NA = 7;

kXSAVEOPT = 0                   ; CPUID.0DH.01H (Intel/AMD)
kXSAVEC = 1
kXGETBV = 2
kIA32_XSS = 3
kXFD = 4
kCET_U = 11
kCET_S = 12

kU_S = 0                        ; CPUID.0DH (ecx = 11/12) (AMD)

kTSC_INVARIANT = 8              ; CPUID.80000007H EDX[8] (Intel)

kMcaOverflowRecov = 0           ; CPUID.80000007H (AMD)
kSUCCOR = 1
kHWA = 2
kScalableMca = 3

kL3_MON = 1                     ; CPUID.0FH.00H (Intel)
kRDT_M_OVF = 8
kIO_RDT_CMT = 9
kIO_RDT_MBM = 10

kCMT_L3_OCCUP = 0               ; CPUID.0FH.01H (Intel)
kMBM_L3_TOTAL = 1
kMBM_L3_LOCAL = 2
kL3CacheOccMon = 0
kL3CacheBWMonEvt0 = 1
kL3CacheBWMonEvt1 = 2

kL3CacheMon = 1                 ; CPUID.0FH (AMD)

kCAT_L3 = 1                     ; CPUID.10H (Intel)
kCAT_L2 = 2
kMBA = 3

kCAT_L3_NONCPU = 1			    ; CPUID.10H.01H (Intel)
kCAT_L3_CDP = 2
kCAT_L3_NONCONTIG = 3

kCAT_L2_CDP = 2                 ; CPUID.10H.02H (Intel)
kCAT_L2_NONCONTIG = 3

kMBA_LINEAR = 2                 ; CPUID.10H.03H (Intel)

kL3Alloc = 1                    ; CPUID.10H (AMD)
kCDP = 2

kSGX1 = 0                       ; CPUID.12H (Intel)
kSGX2 = 1
kENCLVx = 5
kENCLSx = 6
kEVERIFYREPORT2 = 7
kEUPDATESVN = 10
kEDECCSSA = 11

kCR3_FILTER = 0                 ; CPUID.14H (Intel)
kCYC_ACC = 1
kIP_FILTER = 2
kMTC = 3
kPTWRITE = 4
kPWR_EVT_TRACE = 5
kPMI_PRESERVE = 6
kEVENT_TRACE = 7
kTNT_DIS = 8
kPTTT = 9

kICNT = 0						; CPUID.14H.01H (Intel)
kTRIGGER_PAUSE = 1
kTRIGGER_DR_MATCH = 2

kTOPAOUT = 0
kMENTRY = 1
kSNGL_RNG_OUT = 2
kTRACE_TRANSPORT_SUBSYSTEM = 3
kLIP = 31

kIS_VENDOR_SCHEME = 16          ; CPUID.17H (Intel)

k4KB_ENTRIES = 0                ; CPUID.18H (Intel)
k2MB_ENTRIES = 1
k4MB_ENTRIES = 2
k1GB_ENTRIES = 3

kCPL0_RESTRICT = 0              ; CPUID.19H (Intel)
kNO_ENCRYPT_RESTRICT = 1
kNO_DECRYPT_RESTRICT = 2

kAESKLE = 0
kAES_WIDE = 2
kIWKEYBACKUP = 4

kNOBACKUP = 0
kRAND_IWKEY = 1

kDEEP_C_STATE_RESET = 30        ; CPUID.1CH (Intel)
kIP_VALUES_CONTAIN_LIP = 31

kCPL_FILTERING = 0
kBRANCH_FILTERING = 1
kCALL_STACK_MODE = 2

kMISPREDICT_BIT = 0
kTIMED_LBRS = 1
kBRANCH_TYPE_FIELD_SUPPORTED = 2

kUNITMASK2 = 0                  ; CPUID.23H.00H (Intel)
kEQBit = 1                      ;

kALLOW_IN_RECORD = 3            ; CPUID.23H.04H (Intel)
kCNTR_GP = 4
kCNTR_FIXED = 5
kCNTR_METRICS = 6
kGPR = 29
kAUX = 30

k128BitVector = 16              ; CPUID.24H.00H (Intel)
k256BitVector = 17
k512BitVector = 18

;kL3_MON = 1                    ; CPUID.27H.00H (Intel)

kRDT_M_OVF = 8
kIO_RDT_CMT = 9
kIO_RDT_MBM = 10

kCMT_L3_OCCUP = 0
kMBM_L3_TOTAL = 1
kMBM_L3_LOCAL = 2

;kCAT_L3_NONCPU = 1              ; CPUID.28H.01H (Intel)
;kCAT_L3_CDP = 2
;kCAT_L3_NONCONTIG = 3

;kCAT_L2_CDP = 2                 ; CPUID.28H.02H (Intel)
;kCAT_L2_NONCONTIG = 3

kPER_THREAD_MBA = 0             ; CPUID.28H.03H (Intel)
kMBA_LINEAR = 2

kPQE = 15                       ; CPUID.80000000H (AMD)

kxAHF = 0                       ; CPUID.80000001H
kLZCNT = 5
kPREFETCHW = 8
kSYSCALL = 11
kExecuteDisableBit = 20
k1GBytePages = 26
kRDTSCP = 27
kIntel64Architecture = 29

kTopologyExtensions = 22        ; CPUID.80000001H (AMD)

kOneWayAssociative = 1          ; CPUID.80000005H (AMD)
kFullyAssociativeValue = 255

kWBNOINVD = 9                   ; CPUID.80000008H (Intel)

kFP128 = 0                      ; CPUID.8000001AH (AMD)
kMOVU = 1
kFP256 = 2

kLWP = 15                       ; CPUID.80000001H (AMD)

kLwpDataAddress = 5             ; CPUID.8000001CH (AMD)
kLwpBranchPrediction = 28
kLwpIpFiltering = 29
kLwpCacheLevels = 30
kLwpCacheLatency = 31

kSelfInitialization = 8         ; CPUID.8000001DH (AMD)
kBitFullyAssociative = 9

kWBINVD = 0                     ; CPUID.8000001DH (AMD)
kCacheInclusive = 1

kL3MBE = 1                      ; CPUID.80000020H (AMD)
kL3SMBE = 2
kBMEC = 3
kABMC = 5
kOverflowBit = 8
kSelect_COS = 0

kPerfMonV2 = 0                  ; CPUID.80000022H (AMD)
kLbrStack = 1
kLbrAndPmcFreeze = 2

kMemHmk = 0                     ; CPUID.80000023H (AMD)

kNumSegReduction = 10           ; CPUID.80000025H (AMD)

kEfficiencyRankingAvailable = 29; CPUID.80000026H (AMD)
kHeterogeneousCores = 30
kAsymmetricTopology = 31

; ===================================================================================
; ===================================================================================