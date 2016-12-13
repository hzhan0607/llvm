; RUN: opt < %s -correlated-propagation -instcombine -simplifycfg -S | FileCheck %s

@.src = private unnamed_addr constant [19 x i8] c"my-overflow-test.c\00", align 1
@0 = private unnamed_addr constant { i16, i16, [6 x i8] } { i16 0, i16 11, [6 x i8] c"'int'\00" }
@1 = private unnamed_addr global { { [19 x i8]*, i32, i32 }, { i16, i16, [6 x i8] }* } { { [19 x i8]*, i32, i32 } { [19 x i8]* @.src, i32 5, i32 13 }, { i16, i16, [6 x i8] }* @0 }
@2 = private unnamed_addr global { { [19 x i8]*, i32, i32 }, { i16, i16, [6 x i8] }* } { { [19 x i8]*, i32, i32 } { [19 x i8]* @.src, i32 5, i32 15 }, { i16, i16, [6 x i8] }* @0 }

; CHECK-NOT: sadd.with.overflow

; Function Attrs: nounwind uwtable
define i32 @func(i32 %x, i32 %y, i32 %z) #0 {
entry:
  %retval = alloca i32, align 4
  %x.addr = alloca i32, align 4
  %y.addr = alloca i32, align 4
  %z.addr = alloca i32, align 4
  store i32 %x, i32* %x.addr, align 4
  store i32 %y, i32* %y.addr, align 4
  store i32 %z, i32* %z.addr, align 4
  %0 = load i32, i32* %x.addr, align 4
  %cmp = icmp slt i32 %0, 100
  br i1 %cmp, label %land.lhs.true, label %if.else

land.lhs.true:                                    ; preds = %entry
  %1 = load i32, i32* %x.addr, align 4
  %cmp1 = icmp sgt i32 %1, 0
  br i1 %cmp1, label %land.lhs.true2, label %if.else

land.lhs.true2:                                   ; preds = %land.lhs.true
  %2 = load i32, i32* %y.addr, align 4
  %cmp3 = icmp sgt i32 %2, 0
  br i1 %cmp3, label %land.lhs.true4, label %if.else

land.lhs.true4:                                   ; preds = %land.lhs.true2
  %3 = load i32, i32* %y.addr, align 4
  %cmp5 = icmp slt i32 %3, 100
  br i1 %cmp5, label %land.lhs.true6, label %if.else

land.lhs.true6:                                   ; preds = %land.lhs.true4
  %4 = load i32, i32* %z.addr, align 4
  %cmp7 = icmp sgt i32 %4, 0
  br i1 %cmp7, label %land.lhs.true8, label %if.else

land.lhs.true8:                                   ; preds = %land.lhs.true6
  %5 = load i32, i32* %z.addr, align 4
  %cmp9 = icmp slt i32 %5, 100
  br i1 %cmp9, label %if.then, label %if.else

if.then:                                          ; preds = %land.lhs.true8
  %6 = load i32, i32* %x.addr, align 4
  %7 = load i32, i32* %y.addr, align 4
  %8 = call { i32, i1 } @llvm.sadd.with.overflow.i32(i32 %6, i32 %7)
  %9 = extractvalue { i32, i1 } %8, 0
  %10 = extractvalue { i32, i1 } %8, 1
  %11 = xor i1 %10, true, !nosanitize !1
  br i1 %11, label %cont, label %handler.add_overflow, !prof !2, !nosanitize !1

handler.add_overflow:                             ; preds = %if.then
  %12 = zext i32 %6 to i64, !nosanitize !1
  %13 = zext i32 %7 to i64, !nosanitize !1
  call void @__ubsan_handle_add_overflow(i8* bitcast ({ { [19 x i8]*, i32, i32 }, { i16, i16, [6 x i8] }* }* @1 to i8*), i64 %12, i64 %13) #3, !nosanitize !1
  br label %cont, !nosanitize !1

cont:                                             ; preds = %handler.add_overflow, %if.then
  %14 = load i32, i32* %z.addr, align 4
  %15 = call { i32, i1 } @llvm.sadd.with.overflow.i32(i32 %9, i32 %14)
  %16 = extractvalue { i32, i1 } %15, 0
  %17 = extractvalue { i32, i1 } %15, 1
  %18 = xor i1 %17, true, !nosanitize !1
  br i1 %18, label %cont11, label %handler.add_overflow10, !prof !2, !nosanitize !1

handler.add_overflow10:                           ; preds = %cont
  %19 = zext i32 %9 to i64, !nosanitize !1
  %20 = zext i32 %14 to i64, !nosanitize !1
  call void @__ubsan_handle_add_overflow(i8* bitcast ({ { [19 x i8]*, i32, i32 }, { i16, i16, [6 x i8] }* }* @2 to i8*), i64 %19, i64 %20) #3, !nosanitize !1
  br label %cont11, !nosanitize !1

cont11:                                           ; preds = %handler.add_overflow10, %cont
  store i32 %16, i32* %retval, align 4
  br label %return

if.else:                                          ; preds = %land.lhs.true8, %land.lhs.true6, %land.lhs.true4, %land.lhs.true2, %land.lhs.true, %entry
  store i32 0, i32* %retval, align 4
  br label %return

return:                                           ; preds = %if.else, %cont11
  %21 = load i32, i32* %retval, align 4
  ret i32 %21
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
