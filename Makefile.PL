use ExtUtils::MakeMaker;
WriteMakefile(
    'NAME'	=> 'XdaDevelopers::CompressUtils',
    ($] < 5.005 ? () : (
		'AUTHOR'        	=> 'Willem Hengeveld <itsme@xs4all.nl>',
		'ABSTRACT'      	=> 'Utility functions for wince rom compression',
    )),   

    'VERSION_FROM' => 'CompressUtils.pm',
    'dist'	=> {COMPRESS => 'gzip -9f', SUFFIX => 'gz'},
	'clean' => {FILES => ''},
    # current problem: symbol name mismatch: in lib: _GetLastError@0, in object: _GetLastError
    'LDFROM' => 'nkcompr$(LIB_EXT) cecompress$(LIB_EXT) $(BASEEXT)$(OBJ_EXT)',
    'LIBS' => [ '-L/usr/lib/w32api -lkernel32' ],
);

