; RUN: opt < %s -correlated-propagation -instcombine -simplifycfg -S | FileCheck %s


@.src = private unnamed_addr constant [10 x i8] c"mytest2.c\00", align 1
@0 = private unnamed_addr constant { i16, i16, [6 x i8] } { i16 0, i16 11, [6 x i8] c"'int'\00" }
@1 = private unnamed_addr global { { [10 x i8]*, i32, i32 }, { i16, i16, [6 x i8] }* } { { [10 x i8]*, i32, i32 } { [10 x i8]* @.src, i32 5, i32 12 }, { i16, i16, [6 x i8] }* @0 }
@2 = private unnamed_addr global { { [10 x i8]*, i32, i32 }, { i16, i16, [6 x i8] }* } { { [10 x i8]*, i32, i32 } { [10 x i8]* @.src, i32 11, i32 12 }, { i16, i16, [6 x i8] }* @0 }

; CHECK-NOT: sadd.with.overflow
; int add(int a, int b, int d) {
;   a = (a < INT_MAX/2 ? INT_MAX-1: 1);
;   return a + 1;
; }


; Function Attrs: nounwind uwtable
define i32 @add(i32 %a, i32 %b, i32 %d) local_unnamed_addr #0 {
entry:
  %cmp = icmp slt i32 %a, 1073741823
  %cond = select i1 %cmp, i32 2147483646, i32 1
  %0 = tail call { i32, i1 } @llvm.sadd.with.overflow.i32(i32 %cond, i32 1)
  %1 = extractvalue { i32, i1 } %0, 0
  %2 = extractvalue { i32, i1 } %0, 1
  br i1 %2, label %handler.add_overflow, label %cont2, !prof !1, !nosanitize !2

handler.add_overflow:                             ; preds = %entry
  %3 = zext i32 %cond to i64, !nosanitize !2
  tail call void @__ubsan_handle_add_overflow(i8* bitcast ({ { [10 x i8]*, i32, i32 }, { i16, i16, [6 x i8] }* }* @1 to i8*), i64 %3, i64 1) #3, !nosanitize !2
  br label %cont2, !nosanitize !2

cont2:                                            ; preds = %entry, %handler.add_overflow
  ret i32 %1
}

; I am still working on modifying your previous patch, looks like such simple
; case that should be covered by constant range analysis, but failed to optimize
; the overflow check

; CHECK: sadd.with.overflow
; int add2(int a, int b, int d) {
;   a = (a < INT_MAX/2 ? a: 1);
;   b = (a < INT_MAX/2 ? b: 1);
;   return a + b;
; }
; Function Attrs: nounwind uwtable
define i32 @add2(i32 %a, i32 %b, i32 %d) local_unnamed_addr #0 {
entry:
  %cmp = icmp slt i32 %a, 1073741823
  %cond = select i1 %cmp, i32 %a, i32 1
  %0 = tail call { i32, i1 } @llvm.sadd.with.overflow.i32(i32 %cond, i32 %b)
  %1 = extractvalue { i32, i1 } %0, 0
  %2 = extractvalue { i32, i1 } %0, 1
  br i1 %2, label %handler.add_overflow, label %cont8, !prof !1, !nosanitize !2

handler.add_overflow:                             ; preds = %entry
  %3 = zext i32 %cond to i64, !nosanitize !2
  %4 = zext i32 %b to i64, !nosanitize !2
  tail call void @__ubsan_handle_add_overflow(i8* bitcast ({ { [10 x i8]*, i32, i32 }, { i16, i16, [6 x i8] }* }* @2 to i8*), i64 %3, i64 %4) #3, !nosanitize !2
  br label %cont8, !nosanitize !2

cont8:                                            ; preds = %entry, %handler.add_overflow
  ret i32 %1
}

; Function Attrs: nounwind readnone
declare { i32, i1 } @llvm.sadd.with.overflow.i32(i32, i32) #1

; Function Attrs: uwtable
declare void @__ubsan_handle_add_overflow(i8*, i64, i64) local_unnamed_addr #2

attributes #0 = { nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone }
attributes #2 = { uwtable }
attributes #3 = { nounwind }

!llvm.ident = !{!0}

!0 = !{!"clang version 4.0.0 (http://llvm.org/git/clang.git ba7b1350117d23eb86be5f2532bd5a5efd89e724) (http://llvm.org/git/llvm.git 37a12595eac9054e79b6aca3a7190ed4a3b822ab)"}
!1 = !{!"branch_weights", i32 1, i32 1048575}
!2 = !{}
