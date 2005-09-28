/*
    # (C) 2005 XDA Developers  itsme@xs4all.nl
    #
    # CompressUtils - utility functions for rom compression
    #
    # Version: 0.10
    # Date: 4 Jul 2005
    # Author: Willem Hengeveld <itsme@xs4all.nl>
 */

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#define CROAK croak

#ifndef _MSC_VER
#include <windows.h>
//#define PVOID void*
//#define LPVOID void*
//#define LPCVOID const void*
//#define LPBYTE unsigned char*
//#define VOID void
//#define DWORD unsigned long
//#define PDWORD unsigned long*
//#define WORD unsigned short
//#define BYTE unsigned char
//#define HMODULE LPVOID
//#define HANDLE LPVOID
#endif

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
                                                 
// prototypes of cecompressv3.dll and cecompressv4.dll
typedef DWORD (*CECOMPRESS)(const LPBYTE  lpbSrc, DWORD cbSrc, LPBYTE lpbDest, DWORD cbDest, WORD wStep, DWORD dwPagesize);
typedef DWORD (*CEDECOMPRESS)(const LPBYTE  lpbSrc, DWORD cbSrc, LPBYTE  lpbDest, DWORD cbDest, DWORD dwSkip, WORD wStep, DWORD dwPagesize);

// prototypes of cecompr_nt.dll
typedef LPVOID (*FNCompressAlloc)(DWORD AllocSize);
typedef VOID (*FNCompressFree)(LPVOID Address);
typedef DWORD (*FNCompressOpen)( DWORD dwParam1, DWORD MaxOrigSize, FNCompressAlloc AllocFn, FNCompressFree FreeFn, DWORD dwUnknown);
typedef DWORD (*FNCompressConvert)( DWORD ConvertStream, LPVOID CompAdr, DWORD CompSize, LPCVOID OrigAdr, DWORD OrigSize); 
typedef VOID (*FNCompressClose)( DWORD ConvertStream);


typedef struct {

    HMODULE hDll3;
    CECOMPRESS compress3;
    CEDECOMPRESS decompress3;
    CEDECOMPRESS decompressRom3;

    HMODULE hDll4;
    CECOMPRESS compress4;
    CEDECOMPRESS decompress4;

    HMODULE hDllnt;
    FNCompressClose LZX_CompressClose;
    FNCompressConvert LZX_CompressEncode;
    FNCompressOpen LZX_CompressOpen;
    FNCompressClose LZX_DecompressClose;
    FNCompressConvert LZX_DecompressDecode;
    FNCompressOpen LZX_DecompressOpen;
    FNCompressClose XPR_CompressClose;
    FNCompressConvert XPR_CompressEncode;
    FNCompressOpen XPR_CompressOpen;
    FNCompressClose XPR_DecompressClose;
    FNCompressConvert XPR_DecompressDecode;
    FNCompressOpen XPR_DecompressOpen;

} my_cxt_t;
                                                 
START_MY_CXT


// ............................................................
// functions interfacing with nkcompr.lib
DWORD CEDecompressROM(const LPBYTE BufIn, DWORD InSize, LPBYTE BufOut, DWORD OutSize, DWORD skip, DWORD n, DWORD blocksize);
DWORD CEDecompress(const LPBYTE BufIn, DWORD InSize, LPBYTE BufOut, DWORD OutSize, DWORD skip, DWORD n, DWORD blocksize);
DWORD CECompressROM(const LPBYTE  lpbSrc, DWORD cbSrc, LPBYTE lpbDest, DWORD cbDest, WORD wStep, DWORD dwPagesize);
DWORD CECompress(const LPBYTE  lpbSrc, DWORD cbSrc, LPBYTE lpbDest, DWORD cbDest, WORD wStep, DWORD dwPagesize);
int BinDecompressROM(const PVOID pvSource, DWORD  cbSource, PVOID  pvDestination, PDWORD pcbDestination);
// hCompress= _DecompressOpen(0x10000, 0x1000, &allocmem, &freemem, 0)
// _DecompressDecode(hCompress, short, ptr, dword, short)
// _DecompressClose(hCompress)
SV* romcompress_v3(const unsigned char *data, int length)
{
    SV *result; DWORD res;
    if (length==0) return &PL_sv_undef;
    result= newSV(length); SvPOK_on(result); SvCUR_set(result, length);
    res= CECompress(data, length, SvPV_nolen(result), length-1, 1, 4096);
    if (res==0xffffffff) {
        sv_setsv(result, &PL_sv_undef);
    }
    else
        SvCUR_set(result, res);

    return result;
}
SV* romuncompress_v3(const unsigned char *data, int length, int outlength)
{
    SV *result; DWORD res;
    if (length==0) return &PL_sv_undef;
    result= newSV(outlength); SvPOK_on(result); SvCUR_set(result, outlength);
    res= CEDecompress(data, length, SvPV_nolen(result), outlength, 0, 1, 4096);
    if (res==0xffffffff) {
        sv_setsv(result, &PL_sv_undef);
    }
    else
        SvCUR_set(result, res);

    return result;
}

SV* romuncompress_v4(const unsigned char *data, int length, int outlength)
{
    SV *result; DWORD res;
    if (length==0) return &PL_sv_undef;
    result= newSV(outlength); SvPOK_on(result); SvCUR_set(result, outlength);
    res= CEDecompressROM(data, length, SvPV_nolen(result), outlength, 0, 1, 4096);
    if (res==0xffffffff) {
        sv_setsv(result, &PL_sv_undef);
    }
    else {
        SvCUR_set(result, res);
    }

    return result;
}
SV* romuncompress_v5(const unsigned char *data, int length, int outlength)
{
    SV *result; DWORD res;
    if (length==0) return &PL_sv_undef;
    result= newSV(outlength); SvPOK_on(result); SvCUR_set(result, outlength);
    res= BinDecompressROM(data, length, SvPV_nolen(result), &outlength);
    if (res==0xffffffff) {
        sv_setsv(result, &PL_sv_undef);
    }
    else {
        SvCUR_set(result, outlength);
    }

    return result;
}

// .........................................................
// interface to cecompressv3.dll
//
SV* rom3compress(const unsigned char *data, int length)
{
    dMY_CXT;
    SV *result; DWORD res;
    if (length==0 || MY_CXT.compress3==NULL) return &PL_sv_undef;
    result= newSV(length); SvPOK_on(result); SvCUR_set(result, length);
    res= MY_CXT.compress3(data, length, SvPV_nolen(result), length-1, 1, 4096);
    if (res==0xffffffff) {
        sv_setsv(result, &PL_sv_undef);
    }
    else
        SvCUR_set(result, res);

    return result;
}
SV* rom3uncompress(const unsigned char *data, int length, int outlength)
{
    dMY_CXT;
    SV *result; DWORD res;
    if (length==0 || MY_CXT.decompress3==NULL) return &PL_sv_undef;
    result= newSV(outlength); SvPOK_on(result); SvCUR_set(result, outlength);
    res= MY_CXT.decompress3(data, length, SvPV_nolen(result), outlength, 0, 1, 4096);
    if (res==0xffffffff) {
        sv_setsv(result, &PL_sv_undef);
    }
    else
        SvCUR_set(result, res);

    return result;
}
SV* rom3uncompressRom(const unsigned char *data, int length, int outlength)
{
    dMY_CXT;
    SV *result; DWORD res;
    if (length==0 || MY_CXT.decompressRom3==NULL) return &PL_sv_undef;
    result= newSV(outlength); SvPOK_on(result); SvCUR_set(result, outlength);
    res= MY_CXT.decompressRom3(data, length, SvPV_nolen(result), outlength, 0, 1, 4096);
    if (res==0xffffffff) {
        sv_setsv(result, &PL_sv_undef);
    }
    else
        SvCUR_set(result, res);

    return result;
}

// .........................................................
// interface to cecompressv4.dll
//
SV* rom4compress(const unsigned char *data, int length)
{
    dMY_CXT;
    SV *result; DWORD res;
    if (length==0 || MY_CXT.compress4==NULL) return &PL_sv_undef;
    //printf("rom4compress(%08lx, %08lx)", data, length);
    result= newSV(length); SvPOK_on(result); SvCUR_set(result, length);
    res= MY_CXT.compress4(data, length, SvPV_nolen(result), length-1, 1, 4096);
    if (res==0xffffffff) {
        sv_setsv(result, &PL_sv_undef);
    }
    else
        SvCUR_set(result, res);

    //printf(" -> %08lx\n", res);
    return result;
}
SV* rom4uncompress(const unsigned char *data, int length, int outlength)
{
    dMY_CXT;
    SV *result; DWORD res;
    if (length==0 || MY_CXT.decompress4==NULL) return &PL_sv_undef;
    //printf("rom4uncompress(%08lx, %08lx, %08lx)", data, length, outlength);
    result= newSV(outlength); SvPOK_on(result); SvCUR_set(result, outlength);
    res= MY_CXT.decompress4(data, length, SvPV_nolen(result), outlength, 0, 1, 4096);
    if (res==0xffffffff) {
        sv_setsv(result, &PL_sv_undef);
    }
    else
        SvCUR_set(result, res);

    //printf(" -> %08lx\n", res);
    return result;
}

// ..................................................................
// functions interfacing with CeCompress.lib
#define CECOMPRESS_MAX_BLOCK_LOG 16
#define CECOMPRESS_MAX_BLOCK (1 << CECOMPRESS_MAX_BLOCK_LOG)
#define CECOMPRESS_ALIGNMENT 8
typedef LPVOID CeCompressAllocFn( LPVOID Context, DWORD AllocSize);
typedef VOID CeCompressFreeFn( LPVOID Context, LPVOID Address);
typedef struct {DWORD CeCompressEncodeDummy;} *CeCompressEncodeStream;
CeCompressEncodeStream CeCompressEncodeCreate( DWORD MaxOrigSize, LPVOID Context, CeCompressAllocFn *AllocFn);
DWORD CeCompressEncode( CeCompressEncodeStream EncodeStream, LPVOID CompAdr, DWORD CompSize, LPCVOID OrigAdr, DWORD OrigSize); 
VOID CeCompressEncodeClose( CeCompressEncodeStream EncodeStream, LPVOID Context, CeCompressFreeFn *FreeFn);
typedef struct {int CeCompressDecodeDummy;} *CeCompressDecodeStream;
CeCompressDecodeStream CeCompressDecodeCreate( LPVOID Context, CeCompressAllocFn *AllocFn);
DWORD CeCompressDecode( CeCompressDecodeStream DecodeStream, LPVOID OrigAdr, DWORD OrigSize, DWORD DecodeSize, LPCVOID CompAdr, DWORD CompSize);
VOID CeCompressDecodeClose( CeCompressDecodeStream DecodeStream, LPVOID Context, CeCompressFreeFn *FreeFn);

#define XPRESS_MAX_BLOCK_LOG 16
#define XPRESS_MAX_BLOCK (1 << XPRESS_MAX_BLOCK_LOG)
#define XPRESS_ALIGNMENT 8
typedef LPVOID XpressAllocFn( LPVOID Context, DWORD AllocSize);
typedef VOID XpressFreeFn( LPVOID Context, LPVOID Address);
typedef struct {DWORD XpressEncodeDummy;} *XpressEncodeStream;
XpressEncodeStream XpressEncodeCreate( DWORD MaxOrigSize, LPVOID Context, XpressAllocFn *AllocFn);
DWORD XpressEncode( XpressEncodeStream EncodeStream, LPVOID CompAdr, DWORD CompSize, LPCVOID OrigAdr, DWORD OrigSize); 
VOID XpressEncodeClose( XpressEncodeStream EncodeStream, LPVOID Context, XpressFreeFn *FreeFn);
typedef struct {int XpressDecodeDummy;} *XpressDecodeStream;
XpressDecodeStream XpressDecodeCreate( LPVOID Context, XpressAllocFn *AllocFn);
DWORD XpressDecode( XpressDecodeStream DecodeStream, LPVOID OrigAdr, DWORD OrigSize, DWORD DecodeSize, LPCVOID CompAdr, DWORD CompSize);
VOID XpressDecodeClose( XpressDecodeStream DecodeStream, LPVOID Context, XpressFreeFn *FreeFn);

void *AllocFunction(void *Context, U32 AllocSize)
{
    BYTE *ptr;
    New(0, ptr, AllocSize, BYTE);
    return ptr;
}

void FreeFunction(void *Context, void *Address)
{
    Safefree(Address);
}

SV* DoCeCompressDecode(const unsigned char *data, int length, U32 outlength)
{
    SV *result; DWORD res;
    CeCompressDecodeStream stream;
    if (length==0) return &PL_sv_undef;
    //printf("DoCeCompressDecode(%08lx, %08lx, %08lx)", data, length, outlength);
    result= newSV(outlength); SvPOK_on(result); SvCUR_set(result, outlength);

    stream = CeCompressDecodeCreate(NULL, AllocFunction);
    res= CeCompressDecode(stream, SvPV_nolen(result), CECOMPRESS_MAX_BLOCK, outlength, data, length);
    if (res==0) {
        sv_setsv(result, &PL_sv_undef);
    }
    else {
        SvCUR_set(result, res);
    }
    CeCompressDecodeClose(stream, NULL, FreeFunction);
    //printf(" -> %08lx\n", res);
    return result;
}

SV* DoCeCompressEncode(const unsigned char *data, int length)
{
    SV *result; DWORD res;
    CeCompressEncodeStream stream;
    if (length==0) return &PL_sv_undef;
    result= newSV(length); SvPOK_on(result); SvCUR_set(result, length);

    stream = CeCompressEncodeCreate(CECOMPRESS_MAX_BLOCK, NULL, AllocFunction);
    res= CeCompressEncode(stream, SvPV_nolen(result), length-1, data, length);
    if (res==0) {
        sv_setsv(result, &PL_sv_undef);
    }
    else {
        SvCUR_set(result, res);
    }
    CeCompressEncodeClose(stream, NULL, FreeFunction);
    return result;
}

SV* DoXpressDecode(const unsigned char *data, int length, U32 outlength)
{
    SV *result; DWORD res;
    XpressDecodeStream stream;
    if (length==0) return &PL_sv_undef;
    result= newSV(outlength); SvPOK_on(result); SvCUR_set(result, outlength);

    stream = XpressDecodeCreate(NULL, AllocFunction);
    res= XpressDecode(stream, SvPV_nolen(result), XPRESS_MAX_BLOCK, outlength, data, length);
    if (res==0) {
        sv_setsv(result, &PL_sv_undef);
    }
    else {
        SvCUR_set(result, res);
    }
    XpressDecodeClose(stream, NULL, FreeFunction);
    return result;

}

SV* DoXpressEncode(const unsigned char *data, int length)
{
    SV *result; DWORD res;
    XpressEncodeStream stream;
    if (length==0) return &PL_sv_undef;
    result= newSV(length); SvPOK_on(result); SvCUR_set(result, length);

    stream = XpressEncodeCreate(XPRESS_MAX_BLOCK, NULL, AllocFunction);
    res= XpressEncode(stream, SvPV_nolen(result), length-1, data, length);
    if (res==0) {
        sv_setsv(result, &PL_sv_undef);
    }
    else {
        SvCUR_set(result, res);
    }
    XpressEncodeClose(stream, NULL, FreeFunction);
    return result;

}

// ....................................................................
// interface to cecompr_nt.dll

LPVOID Compress_AllocFunc(DWORD AllocSize)
{
    LPVOID p= LocalAlloc(LPTR, AllocSize);

    //printf("Compress_AllocFunc(%08lx) -> %08lx\n", AllocSize, p);

    return p;
}
VOID Compress_FreeFunc(LPVOID Address)
{
    //printf("Compress_FreeFunc(%08lx)\n", Address);
    LocalFree(Address);
}

#define ITSCOMP_XPR_DECODE 0
#define ITSCOMP_XPR_ENCODE 1
#define ITSCOMP_LZX_DECODE 2
#define ITSCOMP_LZX_ENCODE 3

BOOL DoCompressConvert(int dwType, DWORD dwMaxBlockSize, SV*out, DWORD outlength, const BYTE *data, DWORD insize)
{
    dMY_CXT;
    DWORD stream;
    DWORD res;
    BYTE *in;

    FNCompressOpen CompressOpen= NULL;
    FNCompressConvert CompressConvert= NULL;
    FNCompressClose CompressClose= NULL;

    if (MY_CXT.hDllnt==NULL)
        return FALSE;
    switch(dwType) {
    case ITSCOMP_XPR_DECODE:
        CompressOpen= MY_CXT.XPR_DecompressOpen;
        CompressConvert= MY_CXT.XPR_DecompressDecode;
        CompressClose= MY_CXT.XPR_DecompressClose;
        break;
    case ITSCOMP_XPR_ENCODE:
        CompressOpen= MY_CXT.XPR_CompressOpen;
        CompressConvert= MY_CXT.XPR_CompressEncode;
        CompressClose= MY_CXT.XPR_CompressClose;
        break;
    case ITSCOMP_LZX_DECODE:
        CompressOpen= MY_CXT.LZX_DecompressOpen;
        CompressConvert= MY_CXT.LZX_DecompressDecode;
        CompressClose= MY_CXT.LZX_DecompressClose;
        break;
    case ITSCOMP_LZX_ENCODE:
        CompressOpen= MY_CXT.LZX_CompressOpen;
        CompressConvert= MY_CXT.LZX_CompressEncode;
        CompressClose= MY_CXT.LZX_CompressClose;
        break;
    }
    if (CompressOpen==NULL || CompressConvert==NULL || CompressClose==NULL) {
        return FALSE;
    }
    stream= CompressOpen(0x10000, dwMaxBlockSize, Compress_AllocFunc, Compress_FreeFunc, 0);
    if (stream==NULL || stream==0xFFFFFFFF) {
        return FALSE;
    }

    New(0, in, dwMaxBlockSize, BYTE);
    Copy(data, in, insize, BYTE);

    //printf("DoCompressConvert(%d, %08lx, %08lx %08lx, (%08lx-%08lx)->(%08lx-%08lx), %08lx)\n", dwType, stream, SvPV_nolen(out), outlength, data, data+insize, in, in+insize, insize);
    res= CompressConvert(stream, SvPV_nolen(out), outlength, in, insize);
    if (res!=0 && res!=0xffffffff) {
        SvCUR_set(out, res);
    }
    Safefree(in);

    CompressClose(stream);
    return (res!=0 && res!=0xffffffff);
}
SV* XPR_DecompressDecode(const unsigned char *data, int length, U32 outlength)
{
    SV *result= NULL;
    DWORD res= 0;
    DWORD dwMaxBlockSize= 0x2000;

    if (length==0) return &PL_sv_undef;

    result= newSV(dwMaxBlockSize); SvPOK_on(result); SvCUR_set(result, dwMaxBlockSize);

    if (!DoCompressConvert(ITSCOMP_XPR_DECODE, dwMaxBlockSize, result, outlength, data, length)) {
        sv_setsv(result, &PL_sv_undef);
    }
    return result;
}

SV* XPR_CompressEncode(const unsigned char *data, int length)
{
    SV *result= NULL;
    DWORD res= 0;
    DWORD dwMaxBlockSize= 0x2000;

    if (length==0) return &PL_sv_undef;

    result= newSV(dwMaxBlockSize); SvPOK_on(result); SvCUR_set(result, dwMaxBlockSize);

    if (!DoCompressConvert(ITSCOMP_XPR_ENCODE, dwMaxBlockSize, result, length-1, data, length)) {
        sv_setsv(result, &PL_sv_undef);
    }
    return result;
}
SV* LZX_DecompressDecode(const unsigned char *data, int length, U32 outlength)
{
    SV *result= NULL;
    DWORD res= 0;
    DWORD dwMaxBlockSize= 0x2000;

    if (length==0) return &PL_sv_undef;

    result= newSV(dwMaxBlockSize); SvPOK_on(result); SvCUR_set(result, dwMaxBlockSize);

    if (!DoCompressConvert(ITSCOMP_LZX_DECODE, dwMaxBlockSize, result, outlength, data, length)) {
        sv_setsv(result, &PL_sv_undef);
    }
    return result;
}
SV* LZX_CompressEncode(const unsigned char *data, int length)
{
    SV *result= NULL;
    DWORD res= 0;
    DWORD dwMaxBlockSize= 0x2000;

    if (length==0) return &PL_sv_undef;

    result= newSV(dwMaxBlockSize); SvPOK_on(result); SvCUR_set(result, dwMaxBlockSize);

    if (!DoCompressConvert(ITSCOMP_LZX_ENCODE, dwMaxBlockSize, result, length-1, data, length)) {
        sv_setsv(result, &PL_sv_undef);
    }
    return result;
}

MODULE = XdaDevelopers::CompressUtils   PACKAGE = XdaDevelopers::CompressUtils

PROTOTYPES: DISABLE

SV* romcompress_v3(unsigned char *data, int length(data))

SV* romuncompress_v3(unsigned char *data, int length(data), U32 outlength)

SV* romuncompress_v4(unsigned char *data, int length(data), U32 outlength)

SV* romuncompress_v5(unsigned char *data, int length(data), U32 outlength)

SV* rom3uncompressRom(unsigned char *data, int length(data), U32 outlength)

SV* rom3uncompress(unsigned char *data, int length(data), U32 outlength)

SV* rom3compress(unsigned char *data, int length(data))

SV* rom4uncompress(unsigned char *data, int length(data), U32 outlength)

SV* rom4compress(unsigned char *data, int length(data))

SV* DoCeCompressDecode(unsigned char *data, int length(data), U32 outlength)

SV* DoCeCompressEncode(unsigned char *data, int length(data))

SV* DoXpressDecode(unsigned char *data, int length(data), U32 outlength)

SV* DoXpressEncode(unsigned char *data, int length(data))

SV* XPR_DecompressDecode(unsigned char *data, int length(data), U32 outlength)

SV* XPR_CompressEncode(unsigned char *data, int length(data))

SV* LZX_DecompressDecode(unsigned char *data, int length(data), U32 outlength)

SV* LZX_CompressEncode(unsigned char *data, int length(data))


BOOT:
{
    MY_CXT_INIT;
    MY_CXT.compress4= NULL;
    MY_CXT.decompress4= NULL;
    MY_CXT.hDll4= LoadLibrary("CECompressv4.dll");
    if (MY_CXT.hDll4!=NULL && MY_CXT.hDll4!=INVALID_HANDLE_VALUE) {
        MY_CXT.compress4= (CECOMPRESS)GetProcAddress(MY_CXT.hDll4, "CECompress");
        MY_CXT.decompress4= (CEDECOMPRESS)GetProcAddress(MY_CXT.hDll4, "CEDecompress");
    }
    else {
        MY_CXT.hDll4= NULL;
        printf("%08lx: failed to load dll4\n", GetLastError());
    }

    MY_CXT.compress3= NULL;
    MY_CXT.decompress3= NULL;
    MY_CXT.decompressRom3= NULL;
    MY_CXT.hDll3= LoadLibrary("CECompressv3.dll");
    if (MY_CXT.hDll3!=NULL && MY_CXT.hDll3!=INVALID_HANDLE_VALUE) {
        MY_CXT.compress3= (CECOMPRESS)GetProcAddress(MY_CXT.hDll3, "CECompress");
        MY_CXT.decompress3= (CEDECOMPRESS)GetProcAddress(MY_CXT.hDll3, "CEDecompress");
        MY_CXT.decompressRom3= (CEDECOMPRESS)GetProcAddress(MY_CXT.hDll3, "CEDecompressROM");
    }
    else {
        MY_CXT.hDll3= NULL;
        printf("%08lx: failed to load dll3\n", GetLastError());
    }

    MY_CXT.LZX_CompressClose= NULL;
    MY_CXT.LZX_CompressEncode= NULL;
    MY_CXT.LZX_CompressOpen= NULL;
    MY_CXT.LZX_DecompressClose= NULL;
    MY_CXT.LZX_DecompressDecode= NULL;
    MY_CXT.LZX_DecompressOpen= NULL;
    MY_CXT.XPR_CompressClose= NULL;
    MY_CXT.XPR_CompressEncode= NULL;
    MY_CXT.XPR_CompressOpen= NULL;
    MY_CXT.XPR_DecompressClose= NULL;
    MY_CXT.XPR_DecompressDecode= NULL;
    MY_CXT.XPR_DecompressOpen= NULL;
    MY_CXT.hDllnt= LoadLibrary("cecompr_nt.dll");
    if (MY_CXT.hDllnt!=NULL && MY_CXT.hDllnt!=INVALID_HANDLE_VALUE) {
        MY_CXT.LZX_CompressClose= (FNCompressClose)GetProcAddress(MY_CXT.hDllnt, "LZX_CompressClose");
        MY_CXT.LZX_CompressEncode= (FNCompressConvert)GetProcAddress(MY_CXT.hDllnt, "LZX_CompressEncode");
        MY_CXT.LZX_CompressOpen= (FNCompressOpen)GetProcAddress(MY_CXT.hDllnt, "LZX_CompressOpen");
        MY_CXT.LZX_DecompressClose= (FNCompressClose)GetProcAddress(MY_CXT.hDllnt, "LZX_DecompressClose");
        MY_CXT.LZX_DecompressDecode= (FNCompressConvert)GetProcAddress(MY_CXT.hDllnt, "LZX_DecompressDecode");
        MY_CXT.LZX_DecompressOpen= (FNCompressOpen)GetProcAddress(MY_CXT.hDllnt, "LZX_DecompressOpen");
        MY_CXT.XPR_CompressClose= (FNCompressClose)GetProcAddress(MY_CXT.hDllnt, "XPR_CompressClose");
        MY_CXT.XPR_CompressEncode= (FNCompressConvert)GetProcAddress(MY_CXT.hDllnt, "XPR_CompressEncode");
        MY_CXT.XPR_CompressOpen= (FNCompressOpen)GetProcAddress(MY_CXT.hDllnt, "XPR_CompressOpen");
        MY_CXT.XPR_DecompressClose= (FNCompressClose)GetProcAddress(MY_CXT.hDllnt, "XPR_DecompressClose");
        MY_CXT.XPR_DecompressDecode= (FNCompressConvert)GetProcAddress(MY_CXT.hDllnt, "XPR_DecompressDecode");
        MY_CXT.XPR_DecompressOpen= (FNCompressOpen)GetProcAddress(MY_CXT.hDllnt, "XPR_DecompressOpen");
    }
    else {
        MY_CXT.hDllnt= NULL;
        printf("%08lx: failed to load dllnt\n", GetLastError());
    }
}
