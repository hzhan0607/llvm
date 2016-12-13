; ModuleID = 'mytest.c'
source_filename = "mytest.c"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@.src = private unnamed_addr constant [9 x i8] c"mytest.c\00", align 1
@0 = private unnamed_addr constant { i16, i16, [6 x i8] } { i16 0, i16 11, [6 x i8] c"'int'\00" }
@1 = private unnamed_addr global { { [9 x i8]*, i32, i32 }, { i16, i16, [6 x i8] }* } { { [9 x i8]*, i32, i32 } { [9 x i8]* @.src, i32 3, i32 13 }, { i16, i16, [6 x i8] }* @0 }
@2 = private unnamed_addr global { { [9 x i8]*, i32, i32 }, { i16, i16, [6 x i8] }* } { { [9 x i8]*, i32, i32 } { [9 x i8]* @.src, i32 3, i32 17 }, { i16, i16, [6 x i8] }* @0 }
@3 = private unnamed_addr global { { [9 x i8]*, i32, i32 }, { i16, i16, [6 x i8] }* } { { [9 x i8]*, i32, i32 } { [9 x i8]* @.src, i32 4, i32 13 }, { i16, i16, [6 x i8] }* @0 }
@4 = private unnamed_addr global { { [9 x i8]*, i32, i32 }, { i16, i16, [6 x i8] }* } { { [9 x i8]*, i32, i32 } { [9 x i8]* @.src, i32 4, i32 19 }, { i16, i16, [6 x i8] }* @0 }
@5 = private unnamed_addr global { { [9 x i8]*, i32, i32 }, { i16, i16, [6 x i8] }* } { { [9 x i8]*, i32, i32 } { [9 x i8]* @.src, i32 4, i32 16 }, { i16, i16, [6 x i8] }* @0 }
@6 = private unnamed_addr global { { [9 x i8]*, i32, i32 }, { i16, i16, [6 x i8] }* } { { [9 x i8]*, i32, i32 } { [9 x i8]* @.src, i32 4, i32 25 }, { i16, i16, [6 x i8] }* @0 }
@7 = private unnamed_addr global { { [9 x i8]*, i32, i32 }, { i16, i16, [6 x i8] }* } { { [9 x i8]*, i32, i32 } { [9 x i8]* @.src, i32 4, i32 22 }, { i16, i16, [6 x i8] }* @0 }

; Function Attrs: nounwind uwtable
define i32 @add(i32 %a, i32 %b, i32 %d) #0 {
entry:
  %a.addr = alloca i32, align 4
  %b.addr = alloca i32, align 4
  %d.addr = alloca i32, align 4
  %c = alloca i32, align 4
  %c2 = alloca i32, align 4
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
  %8 = load i32, i32* %d.addr, align 4
  %9 = call { i32, i1 } @llvm.sadd.with.overflow.i32(i32 %3, i32 %8)
  %10 = extractvalue { i32, i1 } %9, 0
  %11 = extractvalue { i32, i1 } %9, 1
  %12 = xor i1 %11, true, !nosanitize !1
  br i1 %12, label %cont2, label %handler.add_overflow1, !prof !2, !nosanitize !1

handler.add_overflow1:                            ; preds = %cont
  %13 = zext i32 %3 to i64, !nosanitize !1
  %14 = zext i32 %8 to i64, !nosanitize !1
  call void @__ubsan_handle_add_overflow(i8* bitcast ({ { [9 x i8]*, i32, i32 }, { i16, i16, [6 x i8] }* }* @2 to i8*), i64 %13, i64 %14) #3, !nosanitize !1
  br label %cont2, !nosanitize !1

cont2:                                            ; preds = %handler.add_overflow1, %cont
  store i32 %10, i32* %c, align 4
  %15 = load i32, i32* %a.addr, align 4
  %16 = icmp ne i32 %15, -2147483648, !nosanitize !1
  %or = or i1 %16, true, !nosanitize !1
  %17 = and i1 true, %or, !nosanitize !1
  br i1 %17, label %cont3, label %handler.divrem_overflow, !prof !2, !nosanitize !1

handler.divrem_overflow:                          ; preds = %cont2
  %18 = zext i32 %15 to i64, !nosanitize !1
  call void @__ubsan_handle_divrem_overflow(i8* bitcast ({ { [9 x i8]*, i32, i32 }, { i16, i16, [6 x i8] }* }* @3 to i8*), i64 %18, i64 2) #3, !nosanitize !1
  br label %cont3, !nosanitize !1

cont3:                                            ; preds = %handler.divrem_overflow, %cont2
  %div = sdiv i32 %15, 2
  %19 = load i32, i32* %b.addr, align 4
  %20 = icmp ne i32 %19, -2147483648, !nosanitize !1
  %or4 = or i1 %20, true, !nosanitize !1
  %21 = and i1 true, %or4, !nosanitize !1
  br i1 %21, label %cont6, label %handler.divrem_overflow5, !prof !2, !nosanitize !1

handler.divrem_overflow5:                         ; preds = %cont3
  %22 = zext i32 %19 to i64, !nosanitize !1
  call void @__ubsan_handle_divrem_overflow(i8* bitcast ({ { [9 x i8]*, i32, i32 }, { i16, i16, [6 x i8] }* }* @4 to i8*), i64 %22, i64 2) #3, !nosanitize !1
  br label %cont6, !nosanitize !1

cont6:                                            ; preds = %handler.divrem_overflow5, %cont3
  %div7 = sdiv i32 %19, 2
  %23 = call { i32, i1 } @llvm.sadd.with.overflow.i32(i32 %div, i32 %div7)
  %24 = extractvalue { i32, i1 } %23, 0
  %25 = extractvalue { i32, i1 } %23, 1
  %26 = xor i1 %25, true, !nosanitize !1
  br i1 %26, label %cont9, label %handler.add_overflow8, !prof !2, !nosanitize !1

handler.add_overflow8:                            ; preds = %cont6
  %27 = zext i32 %div to i64, !nosanitize !1
  %28 = zext i32 %div7 to i64, !nosanitize !1
  call void @__ubsan_handle_add_overflow(i8* bitcast ({ { [9 x i8]*, i32, i32 }, { i16, i16, [6 x i8] }* }* @5 to i8*), i64 %27, i64 %28) #3, !nosanitize !1
  br label %cont9, !nosanitize !1

cont9:                                            ; preds = %handler.add_overflow8, %cont6
  %29 = load i32, i32* %d.addr, align 4
  %30 = icmp ne i32 %29, -2147483648, !nosanitize !1
  %or10 = or i1 %30, true, !nosanitize !1
  %31 = and i1 true, %or10, !nosanitize !1
  br i1 %31, label %cont12, label %handler.divrem_overflow11, !prof !2, !nosanitize !1

handler.divrem_overflow11:                        ; preds = %cont9
  %32 = zext i32 %29 to i64, !nosanitize !1
  call void @__ubsan_handle_divrem_overflow(i8* bitcast ({ { [9 x i8]*, i32, i32 }, { i16, i16, [6 x i8] }* }* @6 to i8*), i64 %32, i64 2) #3, !nosanitize !1
  br label %cont12, !nosanitize !1

cont12:                                           ; preds = %handler.divrem_overflow11, %cont9
  %div13 = sdiv i32 %29, 2
  %33 = call { i32, i1 } @llvm.sadd.with.overflow.i32(i32 %24, i32 %div13)
  %34 = extractvalue { i32, i1 } %33, 0
  %35 = extractvalue { i32, i1 } %33, 1
  %36 = xor i1 %35, true, !nosanitize !1
  br i1 %36, label %cont15, label %handler.add_overflow14, !prof !2, !nosanitize !1

handler.add_overflow14:                           ; preds = %cont12
  %37 = zext i32 %24 to i64, !nosanitize !1
  %38 = zext i32 %div13 to i64, !nosanitize !1
  call void @__ubsan_handle_add_overflow(i8* bitcast ({ { [9 x i8]*, i32, i32 }, { i16, i16, [6 x i8] }* }* @7 to i8*), i64 %37, i64 %38) #3, !nosanitize !1
  br label %cont15, !nosanitize !1

cont15:                                           ; preds = %handler.add_overflow14, %cont12
  store i32 %34, i32* %c2, align 4
  %39 = load i32, i32* %c2, align 4
  ret i32 %39
}

; Function Attrs: nounwind readnone
declare { i32, i1 } @llvm.sadd.with.overflow.i32(i32, i32) #1

; Function Attrs: uwtable
declare void @__ubsan_handle_add_overflow(i8*, i64, i64) #2

; Function Attrs: uwtable
declare void @__ubsan_handle_divrem_overflow(i8*, i64, i64) #2

attributes #0 = { nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone }
attributes #2 = { uwtable }
attributes #3 = { nounwind }

!llvm.ident = !{!0}

!0 = !{!"clang version 4.0.0 (http://llvm.org/git/clang.git ba7b1350117d23eb86be5f2532bd5a5efd89e724) (http://llvm.org/git/llvm.git 37a12595eac9054e79b6aca3a7190ed4a3b822ab)"}
!1 = !{}
!2 = !{!"branch_weights", i32 1048575, i32 1}
