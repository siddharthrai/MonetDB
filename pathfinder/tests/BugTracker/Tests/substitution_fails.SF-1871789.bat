@echo off

set q=substitution_fails.SF-1871789.ok.xq
@echo "pf %q% >/dev/null"
@echo "pf %q% >/dev/null" >&2
@%PF% %q% > nul

set q=substitution_fails.SF-1871789.ko.xq
@echo "pf %q% >/dev/null"
@echo "pf %q% >/dev/null" >&2
@%PF% %q% > nul
