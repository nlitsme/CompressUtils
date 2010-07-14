use ExtUtils::MakeMaker;
my %args= (
    'NAME'	=> 'XdaDevelopers::CompressUtils',
    ($] < 5.005 ? () : (
		'AUTHOR'        	=> 'Willem Hengeveld <itsme@xs4all.nl>',
		'ABSTRACT'      	=> 'Utility functions for wince rom compression',
    )),   

    'VERSION_FROM' => 'CompressUtils.pm',
    'dist'	=> {COMPRESS => 'gzip -9f', SUFFIX => 'gz'},
    'clean' => {FILES => ''},
    'EXE_FILES' => [ qw(cecompr_nt-v2.dll cecompr_nt_xphxpr.dll CECompressv3.dll CECompressv4.dll) ],
    'H'    => [],
);
# .. only using dll's
#'LDFROM' => 'nkcompr$(LIB_EXT) cecompress$(LIB_EXT) $(BASEEXT)$(OBJ_EXT)',

if ($^O eq 'cygwin') {
    $args{LIBS} = [ '-L/usr/lib/w32api -lkernel32' ];
    $args{CCFLAGS} .= ' -x c++';
}
elsif ($^O eq 'darwin') {
    system("make -f svr.mk compressserver") && die "make svr error\n";
    push @{$args{EXE_FILES}}, 'compressserver';
    $args{CC}='g++';
    $args{OBJECT} = '$(BASEEXT)$(OBJ_EXT)';
    #   dllloader$(OBJ_EXT) -- only when !use64bitall
    $args{LIBS} = [ '-lstdc++.6' ];
# todo: figure out how to distinguish between 64bit and 32bit osx
    #    -mstackrealign is only needed for 32bit osx
    # to build 32bit binaries: add -m32
    $args{CCFLAGS} .= ' -DUSE_PIPE -I ../../itsutils/common -I ../../itsutils/include/win32 -D_UNIX';
#   $args{CCFLAGS} .= ' -mstackrealign -m32';
#   $args{LDDLFLAGS} = '-m32 -L/opt/local/lib -bundle -undefined dynamic_lookup -L/usr/local/lib';


    #todo: add make -f svr.mk clean
}
elsif ($^O eq 'MSWin32') {
    $args{CCFLAGS} .= ' -TP -DWIN32';
}

WriteMakefile(%args);

