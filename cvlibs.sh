rm -rf lib_cecompress
mkdir -p lib_cecompress/obj/x86/retail
cd lib_cecompress
ar x ../cecompress.lib
for i in obj/x86/retail/*; do
    objcopy -O pe-i386 $i `basename $i .obj`.o
done
ar q cecompress.a *.o
mv cecompress.a ..
cd ..

rm -rf lib_nkcompr
mkdir -p lib_nkcompr/obj/x86/retail
cd lib_nkcompr
ar x ../nkcompr.lib
for i in obj/x86/retail/*; do
    objcopy -O pe-i386 $i `basename $i .obj`.o
done
ar q nkcompr.a *.o
mv nkcompr.a ..
