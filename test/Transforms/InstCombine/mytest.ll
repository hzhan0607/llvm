; RUN: opt -S -O3 < %s -correlated-propagation -instcombine -simplifycfg | FileCheck %s

; CHECK-NOT: sadd.with.overflow

@.src = private unnamed_addr constant [9 x i8] c"mytest.c\00", align 1
@0 = private unnamed_addr constant { i16, i16, [6 x i8] } { i16 0, i16 11, [6 x i8] c"'int'\00" }
@1 = private unnamed_addr global { { [9 x i8]*, i32, i32 }, { i16, i16, [6 x i8] }* } { { [9 x i8]*, i32, i32 } { [9 x i8]* @.src, i32 2, i32 13 }, { i16, i16, [6 x i8] }* @0 }

; Function Attrs: nounwind uwtable
define i32 @add(i32 %a, i32 %b, i32 %d) #0 {
entry:
  %a.addr = alloca i32, align 4
  %b.addr = alloca i32, align 4
  %d.addr = alloca i32, align 4
  %c = alloca i32, align 4
  store i32 %a, i32* %a.addr, align 4
  store i32 %b, i32* %b.addr, align 4
  store i32 %d, i32* %d.addr, align 4
  %0 = load i32, i32* %a.addr, align 4
  %1 = load i32, i32* %b.addr, align 4
  %2 = call { i32, i1 } @llvm.sadd.with.overflow.i32(i32 %0, i32 %1)
  %3 = extractvalue { i32, i1 } %2, 0
  %4 = extractvalue { i32, i1 } %2, 1
  %5 = xor i1 %4, true, !nosanitize !1
  br i1 %5, label %cont, label %handler.add_overflow, !prof !2, !nosanitize !1

handler.add_overflow:                             ; preds = %entry
  %6 = zext i32 %0 to i64, !nosanitize !1
  %7 = zext i32 %1 to i64, !nosanitize !1
  call void @__ubsan_handle_add_overflow(i8* bitcast ({ { [9 x i8]*, i32, i32 }, { i16, i16, [6 x i8] }* }* @1 to i8*), i64 %6, i64 %7) #3, !nosanitize !1
  br label %cont, !nosanitize !1

cont:                                             ; preds = %handler.add_overflow, %entry
  store i32 %3, i32* %c, align 4
  %8 = load i32, i32* %d.addr, align 4
  ret i32 %8
}

; CHECK: sadd.with.overflow

; Function Attrs: nounwind readnone
declare { i32, i1 } @llvm.sadd.with.overflow.i32(i32, i32) #1

; Function Attrs: uwtable
declare void @__ubsan_handle_add_overflow(i8*, i64, i64) #2

attributes #0 = { nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone }
attributes #2 = { uwtable }
attributes #3 = { nounwind }

!llvm.ident = !{!0}

!0 = !{!"clang version 4.0.0 (http://llvm.org/git/clang.git ba7b1350117d23eb86be5f2532bd5a5efd89e724) (http://llvm.org/git/llvm.git 37a12595eac9054e79b6aca3a7190ed4a3b822ab)"}
!1 = !{}
!2 = !{!"branch_weights", i32 1048575, i32 1}
