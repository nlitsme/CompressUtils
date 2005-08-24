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
#define PVOID void*
#define LPVOID void*
#define LPCVOID const void*
#define LPBYTE unsigned char*
#define VOID void
#define DWORD unsigned long
#define PDWORD unsigned long*
#define WORD unsigned short
#define BYTE unsigned char
#define HMODULE LPVOID
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

// functions interfacing with Compress.dll
#define MY_CXT_KEY "XdaDevelopers::CompressUtils::_guts" XS_VERSION
                                                 
typedef DWORD (*CECOMPRESS)(const LPBYTE  lpbSrc, DWORD cbSrc, LPBYTE lpbDest, DWORD cbDest, WORD wStep, DWORD dwPagesize);
typedef DWORD (*CEDECOMPRESS)(const LPBYTE  lpbSrc, DWORD cbSrc, LPBYTE  lpbDest, DWORD cbDest, DWORD dwSkip, WORD wStep, DWORD dwPagesize);
typedef struct {
    HMODULE hDll3;
    CECOMPRESS compress3;
    CEDECOMPRESS decompress3;
    CEDECOMPRESS decompressRom3;
    HMODULE hDll4;
    CECOMPRESS compress4;
    CEDECOMPRESS decompress4;
} my_cxt_t;
                                                 
START_MY_CXT

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

STDAPI_(DWORD) CeRapiInvoke(LPCWSTR, LPCWSTR,DWORD,BYTE *, DWORD *,BYTE **, LPVOID,DWORD);
STDAPI_(DWORD) CeRapiInit();
STDAPI_(DWORD) CeRapiGetError();
STDAPI_(DWORD) CeGetLastError();
bool CheckITSDll()
{
    if (FAILED(CeRapiInit())) {
        printf("le=%08lx re=%08lx ce=%08lx\n", GetLastError(), CeRapiGetError(), CeGetLastError());
        return FALSE;
    }
    return TRUE;
}
#define ITSCOMP_XPR_DECODE 0
#define ITSCOMP_XPR_ENCODE 1
#define ITSCOMP_LZX_DECODE 2
#define ITSCOMP_LZX_ENCODE 3
typedef struct _tagCompressParams {
    DWORD dwType;       // lzx/xpr compress/decompress
    DWORD dwMaxBlockSize;   // from volume header ... fixed to 0x1000 for now
    DWORD outlength;
    DWORD insize;
    BYTE  data[1];
} CompressParams;
typedef struct _tagCompressResult {
    DWORD outlength;
    BYTE  data[1];
} CompressResult;

SV* XPR_DecompressDecode(const unsigned char *data, int length, U32 outlength)
{
    SV *result= NULL;
    DWORD res= 0;
    int insize= sizeof(CompressParams)+length;
    CompressParams *inbuf= NULL;
    DWORD outsize=0;
    CompressResult *outbuf=NULL;

    if (length==0) return &PL_sv_undef;

    if (!CheckITSDll())
        return &PL_sv_undef;

    inbuf= (CompressParams*)LocalAlloc(LPTR, insize);

    memcpy(inbuf->data, data, length);
    inbuf->dwType= ITSCOMP_XPR_DECODE;
    inbuf->dwMaxBlockSize= 0x1000;
    inbuf->insize= length;
    inbuf->outlength= outlength;
    printf("xprlzx(%d, %08lx, %08lx)\n", inbuf->dwType, inbuf->insize, inbuf->outlength);
    res= CeRapiInvoke(L"\\Windows\\ItsUtils.dll", L"ITS_XPRLZX_Compress",
            insize, (BYTE*)inbuf,
            &outsize, (BYTE**)&outbuf, NULL, 0);
    printf("le=%08lx re=%08lx ce=%08lx res=%08lx\n", GetLastError(), CeRapiGetError(), CeGetLastError(), res);
    if (res || outbuf==NULL) {
        return &PL_sv_undef;
    }

    result= newSV(outbuf->outlength); SvPOK_on(result); SvCUR_set(result, outbuf->outlength);
    memcpy(SvPV_nolen(result), outbuf->data, outbuf->outlength);

    LocalFree(outbuf);
    return result;
}

SV* XPR_CompressEncode(const unsigned char *data, int length)
{
    SV *result= NULL;
    DWORD res= 0;
    int insize= sizeof(CompressParams)+length;
    CompressParams *inbuf= NULL;
    DWORD outsize=0;
    CompressResult *outbuf=NULL;

    if (length==0) return &PL_sv_undef;

    if (!CheckITSDll())
        return &PL_sv_undef;

    inbuf= (CompressParams*)LocalAlloc(LPTR, insize);

    memcpy(inbuf->data, data, length);
    inbuf->dwType= ITSCOMP_XPR_ENCODE;
    inbuf->dwMaxBlockSize= 0x1000;
    inbuf->insize= length;
    inbuf->outlength= length-1;
    printf("xprlzx(%d, %08lx, %08lx)\n", inbuf->dwType, inbuf->insize, inbuf->outlength);
    res= CeRapiInvoke(L"\\Windows\\ItsUtils.dll", L"ITS_XPRLZX_Compress",
            insize, (BYTE*)inbuf,
            &outsize, (BYTE**)&outbuf, NULL, 0);
    if (res || outbuf==NULL) {
        return &PL_sv_undef;
    }

    result= newSV(outbuf->outlength); SvPOK_on(result); SvCUR_set(result, outbuf->outlength);
    memcpy(SvPV_nolen(result), outbuf->data, outbuf->outlength);

    LocalFree(outbuf);
    return result;
}

SV* LZX_DecompressDecode(const unsigned char *data, int length, U32 outlength)
{
    SV *result= NULL;
    DWORD res= 0;
    int insize= sizeof(CompressParams)+length;
    CompressParams *inbuf= NULL;
    DWORD outsize=0;
    CompressResult *outbuf=NULL;

    if (length==0) return &PL_sv_undef;

    if (!CheckITSDll())
        return &PL_sv_undef;

    inbuf= (CompressParams*)LocalAlloc(LPTR, insize);

    memcpy(inbuf->data, data, length);
    inbuf->dwType= ITSCOMP_LZX_DECODE;
    inbuf->dwMaxBlockSize= 0x1000;
    inbuf->insize= length;
    inbuf->outlength= outlength;
    printf("xprlzx(%d, %08lx, %08lx)\n", inbuf->dwType, inbuf->insize, inbuf->outlength);
    res= CeRapiInvoke(L"\\Windows\\ItsUtils.dll", L"ITS_XPRLZX_Compress",
            insize, (BYTE*)inbuf,
            &outsize, (BYTE**)&outbuf, NULL, 0);
    if (res || outbuf==NULL) {
        return &PL_sv_undef;
    }

    result= newSV(outbuf->outlength); SvPOK_on(result); SvCUR_set(result, outbuf->outlength);
    memcpy(SvPV_nolen(result), outbuf->data, outbuf->outlength);

    LocalFree(outbuf);
    return result;
}

SV* LZX_CompressEncode(const unsigned char *data, int length)
{
    SV *result= NULL;
    DWORD res= 0;
    int insize= sizeof(CompressParams)+length;
    CompressParams *inbuf= NULL;
    DWORD outsize=0;
    CompressResult *outbuf=NULL;

    if (length==0) return &PL_sv_undef;

    if (!CheckITSDll())
        return &PL_sv_undef;

    inbuf= (CompressParams*)LocalAlloc(LPTR, insize);

    memcpy(inbuf->data, data, length);
    inbuf->dwType= ITSCOMP_LZX_ENCODE;
    inbuf->dwMaxBlockSize= 0x1000;
    inbuf->insize= length;
    inbuf->outlength= length-1;
    printf("xprlzx(%d, %08lx, %08lx)\n", inbuf->dwType, inbuf->insize, inbuf->outlength);
    res= CeRapiInvoke(L"\\Windows\\ItsUtils.dll", L"ITS_XPRLZX_Compress",
            insize, (BYTE*)inbuf,
            &outsize, (BYTE**)&outbuf, NULL, 0);
    if (res || outbuf==NULL) {
        return &PL_sv_undef;
    }

    result= newSV(outbuf->outlength); SvPOK_on(result); SvCUR_set(result, outbuf->outlength);
    memcpy(SvPV_nolen(result), outbuf->data, outbuf->outlength);

    LocalFree(outbuf);
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
    if (MY_CXT.hDll4) {
        MY_CXT.compress4= (CECOMPRESS)GetProcAddress(MY_CXT.hDll4, "CECompress");
        MY_CXT.decompress4= (CEDECOMPRESS)GetProcAddress(MY_CXT.hDll4, "CEDecompress");
    }
    else {
        printf("%08lx: failed to load dll4\n", GetLastError());
    }

    MY_CXT.compress3= NULL;
    MY_CXT.decompress3= NULL;
    MY_CXT.decompressRom3= NULL;
    MY_CXT.hDll3= LoadLibrary("CECompressv3.dll");
    if (MY_CXT.hDll3) {
        MY_CXT.compress3= (CECOMPRESS)GetProcAddress(MY_CXT.hDll3, "CECompress");
        MY_CXT.decompress3= (CEDECOMPRESS)GetProcAddress(MY_CXT.hDll3, "CEDecompress");
        MY_CXT.decompressRom3= (CEDECOMPRESS)GetProcAddress(MY_CXT.hDll3, "CEDecompressROM");
    }
    else {
        printf("%08lx: failed to load dll3\n", GetLastError());
    }
}
