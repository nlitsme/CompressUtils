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
    'LIBS' => [ 'nkcompr.lib' ],
);

