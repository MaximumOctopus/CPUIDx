==============================================================================

  CPUidX 0.22
  (c) Paul Alan Freshney 2022-2025

  paul@freshney.org

  Source code and executable
    https://github.com/MaximumOctopus/CPUIDx
  
  Assembled using "Flat Assembler"
    https://flatassembler.net/
	
  References
      AMD64 Architecture Programmer’s Manual Volume 3: General-Purpose and System Instructions
          2022 October
          2023 June
          2024 March
          2025 July
      Intel® 64 and IA-32 Architectures Software Developer's Manual Volume 2
          2022 December
          2023 March, September, December
          2024 March, June, October, December
          2025 March, June, October
          2026 February

          Intel® 64 and IA-32 Architectures Software Developer's Manual Documentation Changes
              https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html
			  
==============================================================================

Run it from a command prompt.

To see which cpuid leaf each section comes from, run it as follows:
  cpuidx /x  

Save the report to a file:
  cpuidx >cpuidx.txt

Known issues:
  Lack of support for earlier Intel and AMD CPUs.
  
If you find a bug then please email me at the address at the top of this readme.

==============================================================================

 Credits:

   All coding       : Paul A Freshney
   Development Cats : Rutherford, Freeman, and Maxwell
					  
   Dedicated to Dad, Julie, Adam, and Dyanne.

All of my software is free and open source; please consider donating to a local cat charity or shelter. Thanks.

==============================================================================

Release History

0.22 / February 20th 2026

Several changes and new leafs (27H, 28H, 23H.04H, 23H.05H) from the February 2026 updated docs.

0.21 / December 5th 2025

Quite a few changes based on the October 2025 Intel document. Several field name changes, and
a restyling of the leaf identifiers: leaf 07h becomes CPUID.07H; leaf 07h, ecx = 2 becomes CPUID.07H.02H.

Also a few minor tweaks.

0.20 / August 1st 2025

Some very minor Intel changes based on their lastest docs.

Many changes based on the latest AMD docs (including 80000025h, a new leaf).

0.19 / April 19th 2025

A single change from the March 2025 Intel docs: 24h, all CPUs that support AVX10 support 128/256/512-bit vector widths.

0.18 / Decemember 30th 2024

A few very minor changes present in the December 2024 Intel docs (including leaf 80000008h).

A couple of tweaks and minor bug fixes.

0.17 / December 12th 2024

Fixed a few errors for AMD CPUs.

Fixed a bug in the CPU Features #1 list caused by a (C) symbol. This unicode character pushed everything below it forwards
by one byte, meaning the first character sent to printf was a null character. This caused the correct bit position value
to be output, but the flag's description was blank :(

Split the AMD- and Intel-specific constants into their own file. Code will likely go next.

0.16 / December 6th 2024

Changes based on the October Intel docs. 
Adds support for the new Architectural Performance Monitoring extended information (23h) and AVX10 (24h) leaves and sub-leaves.

Modified all reference to leaf IDs to be consistent with Intel terminology (eg. leaf 01h)

Split some constants into a new file (more tidying coming soon!).

A couple of minor bug fixes and tweaks.

0.15 / July 29th 2024

A couple of minor modifications based on the June version of the Intel dev docs.

0.14 / April 23rd 2024

Tidied up the output, a couple of minor fixes (including a missing cpuid instruction!).

0.13 / April 20th 2024

A couple of minor fixes. Added some more detail to some AMD feature bits.

0.12 / April 14th 2024

A few minor modifications from the March editions of the Intel and AMD dev manuals.

0.11 / January 27th 2024

A minor modification based on the December 2023 update of the Intel dev manual
     Leaf 07h, subleaf 1

0.10 / October 24th 2023

A few modifications based on the latest Intel dev manual (Sept 2023).
     Leafs 0Fh and 10h.

0.9 / September 22nd 2023

Added logical core count

0.8 / July 20th 2023

A few modifications based on the latest AMD developer manual (June 2023).
Added descriptions to a few bits.
Several minor tweaks and bug fixes.

0.7 / June 21st 2023

Added detail option via the command-line (shows cpuid leaf information for each section)

0.6 / June 13th 2023

Fixed a couple of bugs with CPU features.
Added raw register data to all parameters.

0.5 / April 17th 2023

A few minor modifications based on the latest Intel developer manual (March 2023).
Fixed a few printf issues.

0.4 / February 16th 2023

Added descriptions to many of the feature bits.
Added the remaining to-do leafs.

0.3 / January 15th 2023

Added more leafs
Minor tweaks

0.2 / January 13th 2023

Added bit value to enumerated data
Added several new leafs
Fixed a couple of minor bugs

0.1 / January 9th 2023

First public release.

==============================================================================