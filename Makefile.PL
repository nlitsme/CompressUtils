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
    'EXE_FILES' => [ qw(cecompr_nt.dll CECompressv3.dll CECompressv4.dll) ],
    'H'    => [],
);
# .. only using dll's
#'LDFROM' => 'nkcompr$(LIB_EXT) cecompress$(LIB_EXT) $(BASEEXT)$(OBJ_EXT)',

if ($^O eq 'cygwin') {
    $args{LIBS} = [ '-L/usr/lib/w32api -lkernel32' ];
}
elsif ($^O eq 'darwin') {
    $args{OBJECT} = '$(BASEEXT)$(OBJ_EXT)  dllloader$(OBJ_EXT)';
    $args{LIBS} = [ '-lstdc++.6' ];
    $args{CCFLAGS} = '-mstackrealign';
}
# else: MSWin32

WriteMakefile(%args);

