package XdaDevelopers::CompressUtils;
# (C) 2003-2007 Willem Jan Hengeveld <itsme@xs4all.nl>
# Web: http://www.xs4all.nl/~itsme/
#      http://wiki.xda-developers.com/
#
# $Id$
#
use strict;
use warnings;

require Exporter;
require DynaLoader;
our @ISA = qw(Exporter DynaLoader);

our $VERSION = '0.30';

bootstrap XdaDevelopers::CompressUtils $VERSION;

1;
