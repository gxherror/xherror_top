---
title: "SIMD Lab"
description: 学习
date: 2023-01-02T15:19:51Z
image: 
math: 
license: 
hidden: false
comments: true
categories:
 - SS
tags:
---
实验： SIMD 指令
目的： 了解并掌握 Intel SIMD 指令的基本用法
Exercise 1: 熟悉 SIMD intrinsics 函数
Intel 提供了大量的 SIMD intrinsics 函数，你需要学会找到自己想要使用的那些函
数。
你可以通过查看：[Intel® Intrinsics Guide](https://www.intel.com/content/www/us/en/docs/intrinsics-guide/index.html) ，勾选某个 checkboxes 你可以看到该
指令集下支持的所有操作及相关描述。
这些函数的用法，你还可以参考：
[Intrinsics 函数总结 - 百度文库 (baidu.com)](https://wenku.baidu.com/view/cd7f94ab24c52cc58bd63186bceb19e8b8f6ec95.html?_wkts_=1671590124421)
如果是 ARM 处理器，可以从官网或其他来源查看相关资料: [Neon – Arm®](https://www.arm.com/technologies/neon)

回答问题：找出能完成以下操作的 128-位 intrinsics 函数： (one for each):

⚫ Four floating point divisions in single precision (i.e. float)（4 个并行的单精度浮点数除法）

⚫ Sixteen max operations over unsigned 8-bit integers (i.e. char) （16 个并行求 8 位无符号整数的最大值）

⚫Arithmetic shift right of eight signed 16-bit integers (i.e.short) （8 个并行的 16 位带符号短整数的算术右移）

> Hint: Things that say “epi” or “pi” deal with integers,and say ”epu” deal with unsigned integers, and those that say “ps” or “pd” deal with single precision and double precision floats.



ANS:

```
__m128 _mm_div_ps (__m128 a, __m128 b)
Description
Divide packed single-precision (32-bit) floating-point elements in a by packed elements in b, and store the results in dst.

__m128i _mm_max_epu8 (__m128i a, __m128i b)
Description
Compare packed unsigned 8-bit integers in a and b, and store packed maximum values in dst.

//shirt right arithmetic immediate
__m128i _mm_srai_epi16 (__m128i a, int imm8)
Description
Shift packed 16-bit integers in a right by imm8 while shifting in sign bits, and store the results in dst.
```



Exercise 2： 阅读 SIMD 代码
本练习对 SIMD intrinsics 函数是使用进行了示范。
实现双精度浮点数的矩阵乘法：
这个操作会产生如下运算：

```
C[0] += A[0]*B[0] + A[2]*B[1];
C[1] += A[1]*B[0] + A[3]*B[1];
C[2] += A[0]*B[2] + A[2]*B[3];
C[3] += A[1]*B[2] + A[3]*B[3];
```

在 sseTest.c
文件中，可以看到矩阵乘法的 SIMD 实现，它使用了以下 intrinsics 函数:

![image-20221221102956674](/images/image-20221221102956674.png)

通过以下命令, 编译 sseTest.c 产生 x86 汇编文件:
```make sseTest.s```
回答问题： sseTest.s 文件的内容 ，哪些指令是执行 SIMD 操作的？

ANS:

```asm
instructions include xmm registers

pxor	xmm6, xmm6
movsd	xmm1, QWORD PTR .LC2[rip]
...
movsd	QWORD PTR 48[rsp], xmm1
movapd	xmm0, XMMWORD PTR 48[rsp]
movapd	xmm3, xmm9
...
mulpd	xmm2, xmm6
...
addpd	xmm6, xmm0
movapd	xmm2, xmm1
...
```





Exercise 3: 书写 SIMD 代码
以下代码是原始版本，用于将数组 a 中的内容累计求和。

```
static int sum_naive(int n, int *a)
{
int sum = 0;
for (int i = 0; i < n; i++)
{
sum += a[i];
}
return sum;
}
```

使用以下函数：
![image-20221221103043678](/images/image-20221221103043678.png)
修改 sum.c 文件中的 sum_vectorized()
函数
编译并运行你的程序：

```
make sum
./sum
```



ANS:

```c
static int sum_vectorized(int n, int *a)
{
	int result[4] = {0,0,0,0};
	__m128i sum = _mm_setzero_si128();
	for (int i = 0; i < n / 4 * 4; i += 4)
	{
		__m128i tmp =_mm_loadu_si128(a+i);
		sum = _mm_add_epi32(tmp,sum);
	}
	
	_mm_storeu_si128((__m128i_u *)result,sum);
	for (int i =n / 4 * 4;i < n ;i++){
		result[0]+=a[i];
	}
	return (result[0]+result[1]+result[2]+result[3]);
}

回答问题：性能是否有改善？ 输出结果是什么？
性能提高了
naive: 12.92 microseconds
unrolled: 10.03 microseconds
vectorized: 3.39 microseconds

```




Exercise 4: Loop Unrolling 循环展开
在 sum.c 中，我们提供了
sum_unrolled()函数的实现:

```c
static int sum_unrolled(int n, int *a)
{
int sum = 0;
// unrolled loop
    for (int i = 0; i < n / 4 * 4; i += 4)
    {
        sum += a[i+0];
        sum += a[i+1];
        sum += a[i+2];
        sum += a[i+3];
    }
    // tail case
    for (int i = n / 4 * 4; i < n; i++)
    {
        sum += a[i];
    }
return sum;
}
```


将 sum_vectorized()代码拷贝到sum_vectorized_unrolled()中并循环展开 4 次，编译并运行代码：

```
make sum
./sum
```

回答问题：性能是否有改善？ 输出结果是什么？将你修改后的源代码 sum.c 和实验文档
打包一并提交。



ANS:

```c
static int sum_vectorized_unrolled(int n, int *a)
{
    int result[4] = {0,0,0,0};
	__m128i sum = _mm_setzero_si128();
	for (int i = 0; i < n / 16 * 16; i += 16)
	{
		__m128i tmp0 =_mm_loadu_si128(a+i);
		sum = _mm_add_epi32(tmp0,sum);
		__m128i tmp1 =_mm_loadu_si128(a+i+4);
		sum = _mm_add_epi32(tmp1,sum);
		__m128i tmp2 =_mm_loadu_si128(a+i+8);
		sum = _mm_add_epi32(tmp2,sum);
		__m128i tmp3 =_mm_loadu_si128(a+i+12);
		sum = _mm_add_epi32(tmp3,sum);
	}
	
	_mm_storeu_si128((__m128i_u *)result,sum);
	for (int i =n / 16 * 16;i < n ;i++){
		result[0]+=a[i];
	}
	return (result[0]+result[1]+result[2]+result[3]);
}


naive: 14.72 microseconds
unrolled: 11.46 microseconds
vectorized: 3.89 microseconds
vectorized unrolled: 3.05 microseconds

```



Exercise 5:
我们提供的 makefile 没有采用编译器-o3 优化，你可以试试采用 gcc -o3 编译未向量化的原始文件 sum.c,观察程序是否会被编译器自动向量化，程序性能是否有改善，改善情况如何？你可以加入条件分支语句，例如：if (a[i]>0) sum+= a[i]; 观察自动向量化的效果。
这篇博客介绍了向量化编译供你参考：[向量化编译选项 - CSDN](https://www.csdn.net/tags/NtzaEg3sMzAyNjctYmxvZwO0O0OO0O0O.html)

我们提供的 makefile 采用的是-msse4.2 编译选项，该指令集支持的并行计算宽度是 128
位。你可以查看当前计算机所支持的指令集，例如 AVX 或 avx512f，找出相应的 256-位 或512 位并行度的 intrinsics 函数，修改 sum.c 文件中的 sum_vectorized()函数，将 SIMD指令的并行度提高，并选用合适的编译选项，例如 -O2 -mavx 或者 -O2 -mavx512f，观察程序性能的改善情况，分析后给出一些你的看法和结论。



ANS:

```asm
//FLAGS = -std=gnu99 -O2 -DNDEBUG -g0 -msse4.2
$objdump -S sum
00000000000012c0 <sum_naive>:
    12c0:	f3 0f 1e fa          	endbr64 
    12c4:	85 ff                	test   %edi,%edi
    12c6:	7e 20                	jle    12e8 <sum_naive+0x28>
    12c8:	8d 47 ff             	lea    -0x1(%rdi),%eax
    12cb:	48 8d 54 86 04       	lea    0x4(%rsi,%rax,4),%rdx
    12d0:	31 c0                	xor    %eax,%eax
    12d2:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
    12d8:	03 06                	add    (%rsi),%eax
    12da:	48 83 c6 04          	add    $0x4,%rsi
    12de:	48 39 d6             	cmp    %rdx,%rsi
    12e1:	75 f5                	jne    12d8 <sum_naive+0x18>
    12e3:	c3                   	retq   
    12e4:	0f 1f 40 00          	nopl   0x0(%rax)
    12e8:	31 c0                	xor    %eax,%eax
    12ea:	c3                   	retq   
    12eb:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)

//FLAGS = -std=gnu99 -O3 -DNDEBUG -g0 -msse4.2
$objdump -S sum
00000000000012c0 <sum_naive>:
	...
    12dd:	66 0f ef c0          	pxor   %xmm0,%xmm0
    12e1:	c1 ea 02             	shr    $0x2,%edx
    12e4:	48 c1 e2 04          	shl    $0x4,%rdx
    12e8:	48 01 f2             	add    %rsi,%rdx
    12eb:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
    12f0:	f3 0f 6f 10          	movdqu (%rax),%xmm2
    12f4:	48 83 c0 10          	add    $0x10,%rax
    12f8:	66 0f fe c2          	paddd  %xmm2,%xmm0
    12fc:	48 39 d0             	cmp    %rdx,%rax
    12ff:	75 ef                	jne    12f0 <sum_naive+0x30>
    1301:	66 0f 6f c8          	movdqa %xmm0,%xmm1
    1305:	89 fa                	mov    %edi,%edx
    1307:	66 0f 73 d9 08       	psrldq $0x8,%xmm1
    130c:	83 e2 fc             	and    $0xfffffffc,%edx
    130f:	66 0f fe c1          	paddd  %xmm1,%xmm0
    1313:	66 0f 6f c8          	movdqa %xmm0,%xmm1
    1317:	66 0f 73 d9 04       	psrldq $0x4,%xmm1
    131c:	66 0f fe c1          	paddd  %xmm1,%xmm0
    1320:	66 0f 7e c0          	movd   %xmm0,%eax
    ...
$ ./sum 
naive: 5.13 microseconds
//速度有所上升，但相比vectorized较慢
```

```c
Synopsis
__m512i _mm512_setzero_si512 ()
#include <immintrin.h>
Instruction: vpxorq zmm, zmm, zmm
CPUID Flags: AVX512F
    
//发现CPU不支持avx512f,只能用avx2
$cat /proc/cpuinfo |grep avx
Flags:avx avx2

//FLAGS = -std=gnu99 -O2 -DNDEBUG -g0 -mavx -msse4.2 -mavx2
static int sum_vectorized_256(int n, int *a)
{
	int result[8] = {0,0,0,0,0,0,0,0};
	__m256i sum = _mm256_setzero_si256();
	for (int i = 0; i < n / 8 * 8; i += 8)
	{
		__m256i tmp =_mm256_loadu_si256(a+i);
		sum = _mm256_add_epi32(tmp,sum);
	}
	
	_mm256_storeu_si256((__m256i_u *)result,sum);
	for (int i =n / 8 * 8;i < n ;i++){
		result[0]+=a[i];
	}
	int tot=0;
	for (int i=0;i<8;i++){
		tot+=result[i];
	}
	return tot;
}

vectorized: 5.80 microseconds
vectorized_256: 3.14 microseconds
```

