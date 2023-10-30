1.3   / 2015-11-04
==================
  * Make glossary() faster by not introspecting loaded shell functions
  * Remove brittle and incomplete test suite
  * Fixes for shellcheck.net

1.2.4 / 2015-08-29
==================
  * Minor updates for latest shellcheck.net codes
  * Fix write() function, thanks @IsoLinearCHiP!

1.2.3 / 2015-04-01
==================
  * Minor fixes for latest shellcheck.net codes
  * Better wrapping for long about metadata
  * Support leading hyphens in function names

1.2.2 / 2015-01-16
==================
various fixes, including contributions from:
  * @nilbus
  * @martinlauer
  * @DrVanScott

1.2.1 / 2014-01-05
==================
  * Tab completion for revise(), new compost() func
  * Improve shell determination and bootstrapping sequence

1.2.0 / 2013-11-17
==================
  * Auto-load composed functions

1.1.1 / 2013-10-29
==================
  * Fix issue with zsh noclobber option

1.1.0 / 2013-10-23
==================
  * Auto-revise drafted functions
  * Populate author metadata on draft
  * Use tpope-style commit msgs
  * Respect XDG_DATA_HOME

1.0.4 / 2013-08-30
==================

  * increase letterpress spacing
  * refactor composure extras

1.0.3 / 2012-11-29
==================

  * make revise() smarter
  * write() includes shebang and main() invocation

1.0.2 / 2012-05-24
==================

  * use _plumbing nomenclature

1.0.1 / 2012-05-19
==================

  * revise() takes an optional -e flag
  * revise() aborts on an empty file
  * metadata cleaned up

1.0 / 2012-05-17
==================

  * performance improvements
  * fix draft(): ensure alias names are not used for function names
  * porcelain is self-referential
  * consolidate plumbing fns
  * add diagram
  * write() porcelain
  * apidoc for author & version
  * second-order functions
  * asciicast demo!
  * prompt for git repo creation
  * full POSIX compatibility
  * revised documentation
  * sed-fu rescues case blocks - solves #1
  * basic git tracking
  * remove hyphens from function names
  * fix for non-interactive shells
  * respect EDITOR preference
  * add readme
  * initial commit
