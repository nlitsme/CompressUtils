#ifdef _WITH_LIBS
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
#endif

