==============================================================================

  CPUidX 0.15
  (c) Paul Alan Freshney 2022-2024

  paul@freshney.org

  Source code and executable
    https://github.com/MaximumOctopus/CPUIDx
  
  Assembled using "Flat Assembler"
    https://flatassembler.net/
	
  References
      AMD64 Architecture Programmer’s Manual Volume 3: General-Purpose and System Instructions
          October   2022
          June      2023
          March     2024
      Intel® 64 and IA-32 Architectures Software Developer's Manual Volume 2
          December  2022
          March     2023
          September 2023
          December  2023
          March     2024  	
          June      2024
  
==============================================================================

Run it from a command prompt.

To see which cpuid leaf each section comes from, run it:
  cpuidx /x  

Save the report to a file:
  cpuidx >cpuidx.txt

Known issues:
  Lack of support for earlier Intel and AMD CPUs.
  AMD testing is lacking (I only have Intel CPUs to hand)
  
If you find a bug then please email me at the address at the top of this readme.

==============================================================================

 Credits:

   All coding       : Paul A Freshney
   Development Cats : Rutherford, Freeman, and Maxwell
					  
   Dedicated to Dad, Julie, Adam, and Dyanne.

All of my software is free and open source; please consider donating to a local cat charity or shelter. Thanks.

==============================================================================

Release History

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