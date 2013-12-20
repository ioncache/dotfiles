#!/bin/bash

# to export these properly, use:
# . ./scripts/setenv.sh

PERL_MAJOR=5.14
export PATH=/oanda/system/perls/$PERL_MAJOR/local/tools/bin:/oanda/system/perls/$PERL_MAJOR/bin:/oanda/system/bin:$PATH
export PERL5LIB=/oanda/whitelabel-api/lib:/oanda/whitelabel-api/local/lib/perl5:/oanda/whitelabel-api/local/lib/perl5/i86pc-solaris:/oanda/system/perls/$PERL_MAJOR/local/tools/lib/perl5:/oanda/system/perls/$PERL_MAJOR/local/tools/lib/perl5/i86pc-solaris
export LD_LIBRARY_PATH=/oanda/db2i9732/sqllib/lib32:/oanda/db2i9732/sqllib/lib64:/oanda/db2inst1/sqllib/lib32:/oanda/db2inst1/sqllib/lib64
