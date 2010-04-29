#if _WITH_LIBS
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
#endif
