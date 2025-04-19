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


kHTT = 28                       ; 01h (Intel)

kPQOS = 12                      ; 01h (AMD)

kPSN = 18                       ; 03h

kWBINVD = 0                     ; 04h
kCacheInclusiveLowerLevels = 1
kComplexFunctionIndexCache = 2

kInterruptsBreakEventMWAIT = 1  ; 05h (Intel)

kEMX = 0                        ; 05h (AMD)
kIBE = 1

kARAT = 6                       ; 06h (AMD)
kEffFreq = 0

kSGX = 2                        ; 07h (Intel)

kIA32_PPIN = 0                  ; 07h (ecx = 1) (Intel)
kCPUIDMAXVAL_LIM_RMV = 3
kArchPerfmonExt = 8
kAVX10 = 19

kPSFD = 0                       ; 07h (ecx = 2) (Intel)
kIPRED_CTRL = 1
kRRSBA_CTRL = 2
kDDPD_U = 3
kBHI_CTRL = 4
kMCDT_NO = 5
kUCLockDisable = 6
kMONITOR_MITG_NO = 7

kAnyThread = 15                 ; 08h and 0ah (Intel)

kXSAVEOPT = 0                   ; 0dh (ecx = 1) (Intel/AMD)
kXSAVEC = 1
kXGETBV = 2
kIA32_XSS = 3
kXFD = 4
kCET_U = 11
kCET_S = 12

kU_S = 0                        ; 0dh (ecx = 11/12) (AMD)

kInvariantTSC = 8               ; 80000007h (Intel)

kMcaOverflowRecov = 0           ; 80000007h (AMD)
kSUCCOR = 1
kHWA = 2
kScalableMca = 3

kL3CacheIntelRDTM = 1           ; 0fh (Intel)
kIA32_QM_CTR = 8
kRDT_CMT = 9
kRDT_MBM = 10

kL3OccupancyMonitoring = 0      ; 0fh (ecx = 1) (Intel)
kL3TotalBandwidthMonitoring = 1
kL3LocalBandwidthMonitoring = 2
kL3CacheOccMon = 0
kL3CacheBWMonEvt0 = 1
kL3CacheBWMonEvt1 = 2

kL3CacheMon = 1                 ; 0fh (AMD)

kL3CacheAllocationTechnology = 1; 10h (Intel)
kL2CacheAllocationTechnology = 2
kMemoryBandwidthAllocation = 3

kL3CATNonCPUAgent = 1			; 10h (ecx = 1) (Intel)
kL3CPT = 2
kNonContiguousCapacityBitmask = 3

kL2CDPT = 2                     ; 10h (ecx = 2) (Intel)

kDelayValuesLinear = 2          ; 10h (ecx = 3) (Intel)

kL3Alloc = 1                    ; 10h (AMD)
kCDP = 2

kSGX1Leaf = 0                   ; 12h (Intel)
kSGX2Leaf = 1
kENCLVx = 5
kENCLSx = 6
kEVERIFYREPORT2 = 7
kEUPDATESVN = 10
kEDECCSSA = 11

kIA32_RTIT_CTL = 0              ; 14h (Intel)
kConfigurablePSB = 1
kIPFiltering = 2
kMTCTimingPacket = 3
kPTWRITE = 4
kPwrEvtEn = 5
kInjectPsbPmiOnEnable = 6
kEventEn = 7
kDisTNT = 8

kTracingIA32_RTIT_CTL = 0
kToPATables = 1
kSingleRangeOutput = 2
kTraceTransportSubsystem = 3
kIPPayloadsLIPValues = 31

kIsVendorScheme = 16            ; 17h (Intel)

k4PageSize = 0                  ; 18h (Intel)
k2MBPageSize = 1
k4MBPageSize = 2
k1GBPageSize = 3

kKLCPL0 = 0                     ; 19h (Intel)
kKLNoEncrypt = 1
kKLNoDecrypt = 2

kAESKLE = 0
kAESWideKeyLockerInstructions = 2
kKeyLockerMSRs = 4

kLOADIWKEYNoBackup = 0
kKeySourceEncodingOne = 1

kDeepCStateReset = 30           ; 1ch (Intel)
kIPValuesContainLIP = 31

kCPLFiltering = 0
kBranchFiltering = 1
kCallStackMode = 2

kMispredictBit = 0
kTimedLBRs = 1
kBranchTypeField = 2

kUnitMask2 = 0                  ; 23h (ecx = 0) (Intel)
kEQBit = 1

k128BitVector = 16              ; 24h (ecx = 0) (Intel)
k256BitVector = 17
k512BitVector = 18

kPQE = 15                       ; 80000000h (AMD)

kxAHF = 0                       ; 80000001h
kLZCNT = 5
kPREFETCHW = 8
kSYSCALL = 11
kExecuteDisableBit = 20
k1GBytePages = 26
kRDTSCP = 27
kIntel64Architecture = 29

kTopologyExtensions = 22        ; 80000001h (AMD)

kOneWayAssociative = 1          ; 80000005h (AMD)
kFullyAssociative = 255

kWBOINVD = 9                    ; 80000008h (Intel)

kFP128 = 0                      ; 8000001ah (AMD)
kMOVU = 1
kFP256 = 2

kLWP = 15                       ; 80000001h (AMD)

kLwpDataAddress = 5             ; 8000001ch (AMD)
kLwpBranchPrediction = 28
kLwpIpFiltering = 29
kLwpCacheLevels = 30
kLwpCacheLatency = 31

kSelfInitialization = 8         ; 8000001dh (AMD)
kFullyAssociative = 9

kWBINVD = 0                     ; 8000001dh (AMD)
kCacheInclusive = 1

kL3MBE = 1                      ; 80000020h (AMD)
kL3SMBE = 2
kBMEC = 3
kABMC = 5
kOverflowBit = 8
kSelect_COS = 0

kPerfMonV2 = 0                  ; 80000022h (AMD)
kLbrStack = 1
kLbrAndPmcFreeze = 2

kMemHmk = 0                     ; 80000023h (AMD)

kEfficiencyRankingAvailable = 29; 80000026h (AMD)
kHeterogeneousCores = 30
kAsymmetricTopology = 31

; ===================================================================================
; ===================================================================================