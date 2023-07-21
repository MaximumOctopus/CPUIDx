===========================================================================================================================

  CPUidX 0.8
  (c) Paul Alan Freshney 2022-2023

  paul@freshney.org

  Source code and executable
    https://github.com/MaximumOctopus/CPUIDx
  
  Assembled using "Flat Assembler"
    https://flatassembler.net/
	
  References
    AMD64 Architecture Programmer’s Manual Volume 3: General-Purpose and System Instructions (October 2022)
    AMD64 Architecture Programmer’s Manual Volume 3: General-Purpose and System Instructions (June 2023)
    Intel® 64 and IA-32 Architectures Software Developer's Manual Volume 2 (December 2022)
    Intel® 64 and IA-32 Architectures Software Developer's Manual Volume 2 (March 2023)	
  
===========================================================================================================================

Run it from a command prompt.

To see which cpuid leaf each section comes from, run it:
  cpuidx /x  

Save the report to a file:
  cpuidx >cpuidx.txt

Known issues:
  Lack of support for earlier Intel and AMD CPUs.
  AMD testing is lacking (I only have Intel CPUs to hand)

===========================================================================================================================

 Credits:

   All coding       : Paul A Freshney
   Development Cats : Rutherford, Freeman, and Maxwell
					  
   Dedicated to Julie, Adam, and Dyanne.

All of my software is free and open source; please consider donating to a local cat charity or shelter. Thanks.

===========================================================================================================================

Release History

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

===========================================================================================================================