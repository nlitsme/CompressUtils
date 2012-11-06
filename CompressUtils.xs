/*
    # (C) 2003-2007 Willem Jan Hengeveld <itsme@xs4all.nl>
    # Web: http://www.xs4all.nl/~itsme/
    #      http://wiki.xda-developers.com/
    #
    # $Id$
    #
    # CompressUtils - utility functions for rom compression
    #
    # Version: 0.10
    # Date: 4 Jul 2005
    # Author: Willem Hengeveld <itsme@xs4all.nl>
 */

#include "compress_msgs.h"

#ifdef __LP64__
#include "win32compress_client.h"
#else
#include "win32compress_loader.h"
#endif

// perl headers should be last since they define many global macro's
//   confusing c++ headers
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#define CROAK croak


#pragma optimize("", off)

/*
 * some Perl macros for backward compatibility
 */
#ifdef NT_BUILD_NUMBER
#define boolSV(b) ((b) ? &sv_yes : &sv_no)
#endif

#ifndef PL_na
#	define PL_na na
#endif

#ifndef SvPV_nolen
#	define SvPV_nolen(sv) SvPV(sv, PL_na)
#endif

#ifndef call_pv
#	define call_pv(name, flags) perl_call_pv(name, flags)
#endif

#ifndef call_method
#	define call_method(name, flags) perl_call_method(name, flags)
#endif

// .......................................................................
// global module context, containing functions from dynamically loaded libraries.

#define MY_CXT_KEY "XdaDevelopers::CompressUtils::_guts" XS_VERSION
                                                 

typedef struct {

#ifdef __LP64__
    win32compress_client client;
#else
    win32compress_loader client;
#endif

} my_cxt_t;
                                                 
START_MY_CXT

// .........................................................
// interface to cecompressv3.dll
//
SV* rom3compress(const unsigned char *data, int length)
{
    dMY_CXT;
    SV *result=NULL;

    if (length==0) return &PL_sv_undef;

    result= newSV(length); SvPOK_on(result); SvCUR_set(result, length);

    U32 res= MY_CXT.client.DoCompressConvert(ITSCOMP_ROM3_ENCODE, (unsigned char*)SvPV_nolen(result), length-1, data, length);
    if (res==0xFFFFFFFF) {
        sv_setsv(result, &PL_sv_undef);
    }
    else {
        SvCUR_set(result, res);
    }

    return result;
}
SV* rom3uncompress(const unsigned char *data, int length, int outlength)
{
    dMY_CXT;
    SV *result=NULL;

    if (length==0) return &PL_sv_undef;

    result= newSV(outlength); SvPOK_on(result); SvCUR_set(result, outlength);

    U32 res= MY_CXT.client.DoCompressConvert(ITSCOMP_ROM3_DECODE, (unsigned char*)SvPV_nolen(result), outlength, data, length);
    if (res==0xFFFFFFFF) {
        sv_setsv(result, &PL_sv_undef);
    }
    else {
        SvCUR_set(result, res);
    }

    return result;
}

SV* rom4compress(const unsigned char *data, int length)
{
    dMY_CXT;
    SV *result=NULL;

    if (length==0) return &PL_sv_undef;

    result= newSV(length); SvPOK_on(result); SvCUR_set(result, length);

    U32 res= MY_CXT.client.DoCompressConvert(ITSCOMP_ROM4_ENCODE, (unsigned char*)SvPV_nolen(result), length-1, data, length);
    if (res==0xFFFFFFFF) {
        sv_setsv(result, &PL_sv_undef);
    }
    else {
        SvCUR_set(result, res);
    }

    return result;
}
SV* rom4uncompress(const unsigned char *data, int length, int outlength)
{
    dMY_CXT;
    SV *result=NULL;

    if (length==0) return &PL_sv_undef;

    result= newSV(outlength); SvPOK_on(result); SvCUR_set(result, outlength);

    U32 res= MY_CXT.client.DoCompressConvert(ITSCOMP_ROM4_DECODE, (unsigned char*)SvPV_nolen(result), outlength, data, length);
    if (res==0xFFFFFFFF) {
        sv_setsv(result, &PL_sv_undef);
    }
    else {
        SvCUR_set(result, res);
    }

    return result;
}


SV* XPR_DecompressDecode(const unsigned char *data, int length, U32 outlength)
{
    dMY_CXT;
    SV *result= NULL;
    U32 dwMaxBlockSize= 0x2000;

    if (length==0) return &PL_sv_undef;

    result= newSV(dwMaxBlockSize); SvPOK_on(result); SvCUR_set(result, dwMaxBlockSize);

    U32 res= MY_CXT.client.DoCompressConvert(ITSCOMP_XPR_DECODE, (unsigned char*)SvPV_nolen(result), outlength, data, length);
    if (res==0xFFFFFFFF) {
        sv_setsv(result, &PL_sv_undef);
    }
    else {
        SvCUR_set(result, res);
    }
    return result;
}

SV* XPR_CompressEncode(const unsigned char *data, int length)
{
    dMY_CXT;
    SV *result= NULL;
    U32 dwMaxBlockSize= 0x2000;

    if (length==0) return &PL_sv_undef;

    result= newSV(dwMaxBlockSize); SvPOK_on(result); SvCUR_set(result, dwMaxBlockSize);

    U32 res= MY_CXT.client.DoCompressConvert(ITSCOMP_XPR_ENCODE, (unsigned char*)SvPV_nolen(result), length-1, data, length);
    if (res==0xFFFFFFFF) {
        sv_setsv(result, &PL_sv_undef);
    }
    else {
        SvCUR_set(result, res);
    }
    return result;
}

SV* XPH_DecompressDecode(const unsigned char *data, int length, U32 outlength)
{
    dMY_CXT;
    SV *result= NULL;
    U32 dwMaxBlockSize= 0x2000;

    if (length==0) return &PL_sv_undef;

    result= newSV(dwMaxBlockSize); SvPOK_on(result); SvCUR_set(result, dwMaxBlockSize);

    U32 res= MY_CXT.client.DoCompressConvert(ITSCOMP_XPH_DECODE, (unsigned char*)SvPV_nolen(result), outlength, data, length);
    if (res==0xFFFFFFFF) {
        sv_setsv(result, &PL_sv_undef);
    }
    else {
        SvCUR_set(result, res);
    }
    return result;
}

SV* XPH_CompressEncode(const unsigned char *data, int length)
{
    dMY_CXT;
    SV *result= NULL;
    U32 dwMaxBlockSize= 0x2000;

    if (length==0) return &PL_sv_undef;

    result= newSV(dwMaxBlockSize); SvPOK_on(result); SvCUR_set(result, dwMaxBlockSize);

    U32 res= MY_CXT.client.DoCompressConvert(ITSCOMP_XPH_ENCODE, (unsigned char*)SvPV_nolen(result), length-1, data, length);
    if (res==0xFFFFFFFF) {
        sv_setsv(result, &PL_sv_undef);
    }
    else {
        SvCUR_set(result, res);
    }
    return result;
}

SV* LZX_DecompressDecode(const unsigned char *data, int length, U32 outlength)
{
    dMY_CXT;
    SV *result= NULL;
    U32 dwMaxBlockSize= 0x2000;

    if (length==0) return &PL_sv_undef;

    result= newSV(dwMaxBlockSize); SvPOK_on(result); SvCUR_set(result, dwMaxBlockSize);

    U32 res= MY_CXT.client.DoCompressConvert(ITSCOMP_LZX_DECODE, (unsigned char*)SvPV_nolen(result), outlength, data, length);
    if (res==0xFFFFFFFF) {
        sv_setsv(result, &PL_sv_undef);
    }
    else {
        SvCUR_set(result, res);
    }
    return result;
}
SV* LZX_CompressEncode(const unsigned char *data, int length)
{
    dMY_CXT;
    SV *result= NULL;
    U32 dwMaxBlockSize= 0x2000;

    if (length==0) return &PL_sv_undef;

    result= newSV(dwMaxBlockSize); SvPOK_on(result); SvCUR_set(result, dwMaxBlockSize);

    U32 res= MY_CXT.client.DoCompressConvert(ITSCOMP_LZX_ENCODE, (unsigned char*)SvPV_nolen(result), length-1, data, length);
    if (res==0xFFFFFFFF) {
        sv_setsv(result, &PL_sv_undef);
    }
    else {
        SvCUR_set(result, res);
    }
    return result;
}

MODULE = XdaDevelopers::CompressUtils   PACKAGE = XdaDevelopers::CompressUtils

PROTOTYPES: DISABLE

#if _WITH_LIBS

SV* romcompress_v3(unsigned char *data, int length(data))

SV* romuncompress_v3(unsigned char *data, int length(data), U32 outlength)

SV* romuncompress_v4(unsigned char *data, int length(data), U32 outlength)

SV* romuncompress_v5(unsigned char *data, int length(data), U32 outlength)

#endif

SV* rom3uncompress(unsigned char *data, int length(data), U32 outlength)

SV* rom3compress(unsigned char *data, int length(data))

SV* rom4uncompress(unsigned char *data, int length(data), U32 outlength)

SV* rom4compress(unsigned char *data, int length(data))

#if _WITH_LIBS

SV* DoCeCompressDecode(unsigned char *data, int length(data), U32 outlength)

SV* DoCeCompressEncode(unsigned char *data, int length(data))

SV* DoXpressDecode(unsigned char *data, int length(data), U32 outlength)

SV* DoXpressEncode(unsigned char *data, int length(data))

#endif

SV* XPR_DecompressDecode(unsigned char *data, int length(data), U32 outlength)

SV* XPR_CompressEncode(unsigned char *data, int length(data))

SV* XPH_DecompressDecode(unsigned char *data, int length(data), U32 outlength)

SV* XPH_CompressEncode(unsigned char *data, int length(data))

SV* LZX_DecompressDecode(unsigned char *data, int length(data), U32 outlength)

SV* LZX_CompressEncode(unsigned char *data, int length(data))


BOOT:
{
    MY_CXT_INIT;

# apparently the constructor of members of 'client' is not called.
    MY_CXT.client.loaddlls();
}
