
obj/__user_badarg.out：     文件格式 elf32-i386


Disassembly of section .text:

00800020 <__panic>:
#include <stdio.h>
#include <ulib.h>
#include <error.h>

void
__panic(const char *file, int line, const char *fmt, ...) {
  800020:	f3 0f 1e fb          	endbr32 
  800024:	55                   	push   %ebp
  800025:	89 e5                	mov    %esp,%ebp
  800027:	83 ec 28             	sub    $0x28,%esp
    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  80002a:	8d 45 14             	lea    0x14(%ebp),%eax
  80002d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("user panic at %s:%d:\n    ", file, line);
  800030:	8b 45 0c             	mov    0xc(%ebp),%eax
  800033:	89 44 24 08          	mov    %eax,0x8(%esp)
  800037:	8b 45 08             	mov    0x8(%ebp),%eax
  80003a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80003e:	c7 04 24 80 11 80 00 	movl   $0x801180,(%esp)
  800045:	e8 d6 02 00 00       	call   800320 <cprintf>
    vcprintf(fmt, ap);
  80004a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80004d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800051:	8b 45 10             	mov    0x10(%ebp),%eax
  800054:	89 04 24             	mov    %eax,(%esp)
  800057:	e8 8d 02 00 00       	call   8002e9 <vcprintf>
    cprintf("\n");
  80005c:	c7 04 24 9a 11 80 00 	movl   $0x80119a,(%esp)
  800063:	e8 b8 02 00 00       	call   800320 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  800068:	c7 04 24 f6 ff ff ff 	movl   $0xfffffff6,(%esp)
  80006f:	e8 83 01 00 00       	call   8001f7 <exit>

00800074 <__warn>:
}

void
__warn(const char *file, int line, const char *fmt, ...) {
  800074:	f3 0f 1e fb          	endbr32 
  800078:	55                   	push   %ebp
  800079:	89 e5                	mov    %esp,%ebp
  80007b:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
  80007e:	8d 45 14             	lea    0x14(%ebp),%eax
  800081:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("user warning at %s:%d:\n    ", file, line);
  800084:	8b 45 0c             	mov    0xc(%ebp),%eax
  800087:	89 44 24 08          	mov    %eax,0x8(%esp)
  80008b:	8b 45 08             	mov    0x8(%ebp),%eax
  80008e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800092:	c7 04 24 9c 11 80 00 	movl   $0x80119c,(%esp)
  800099:	e8 82 02 00 00       	call   800320 <cprintf>
    vcprintf(fmt, ap);
  80009e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000a5:	8b 45 10             	mov    0x10(%ebp),%eax
  8000a8:	89 04 24             	mov    %eax,(%esp)
  8000ab:	e8 39 02 00 00       	call   8002e9 <vcprintf>
    cprintf("\n");
  8000b0:	c7 04 24 9a 11 80 00 	movl   $0x80119a,(%esp)
  8000b7:	e8 64 02 00 00       	call   800320 <cprintf>
    va_end(ap);
}
  8000bc:	90                   	nop
  8000bd:	c9                   	leave  
  8000be:	c3                   	ret    

008000bf <syscall>:
#include <syscall.h>

#define MAX_ARGS            5

static inline int
syscall(int num, ...) {
  8000bf:	55                   	push   %ebp
  8000c0:	89 e5                	mov    %esp,%ebp
  8000c2:	57                   	push   %edi
  8000c3:	56                   	push   %esi
  8000c4:	53                   	push   %ebx
  8000c5:	83 ec 20             	sub    $0x20,%esp
    va_list ap;
    va_start(ap, num);
  8000c8:	8d 45 0c             	lea    0xc(%ebp),%eax
  8000cb:	89 45 e8             	mov    %eax,-0x18(%ebp)
    uint32_t a[MAX_ARGS];
    int i, ret;
    for (i = 0; i < MAX_ARGS; i ++) {
  8000ce:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8000d5:	eb 15                	jmp    8000ec <syscall+0x2d>
        a[i] = va_arg(ap, uint32_t);
  8000d7:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8000da:	8d 50 04             	lea    0x4(%eax),%edx
  8000dd:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8000e0:	8b 10                	mov    (%eax),%edx
  8000e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8000e5:	89 54 85 d4          	mov    %edx,-0x2c(%ebp,%eax,4)
    for (i = 0; i < MAX_ARGS; i ++) {
  8000e9:	ff 45 f0             	incl   -0x10(%ebp)
  8000ec:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
  8000f0:	7e e5                	jle    8000d7 <syscall+0x18>
    asm volatile (
        "int %1;"
        : "=a" (ret)
        : "i" (T_SYSCALL),
          "a" (num),
          "d" (a[0]),
  8000f2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
          "c" (a[1]),
  8000f5:	8b 4d d8             	mov    -0x28(%ebp),%ecx
          "b" (a[2]),
  8000f8:	8b 5d dc             	mov    -0x24(%ebp),%ebx
          "D" (a[3]),
  8000fb:	8b 7d e0             	mov    -0x20(%ebp),%edi
          "S" (a[4])
  8000fe:	8b 75 e4             	mov    -0x1c(%ebp),%esi
    asm volatile (
  800101:	8b 45 08             	mov    0x8(%ebp),%eax
  800104:	cd 80                	int    $0x80
  800106:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "cc", "memory");
    return ret;
  800109:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
  80010c:	83 c4 20             	add    $0x20,%esp
  80010f:	5b                   	pop    %ebx
  800110:	5e                   	pop    %esi
  800111:	5f                   	pop    %edi
  800112:	5d                   	pop    %ebp
  800113:	c3                   	ret    

00800114 <sys_exit>:

int
sys_exit(int error_code) {
  800114:	f3 0f 1e fb          	endbr32 
  800118:	55                   	push   %ebp
  800119:	89 e5                	mov    %esp,%ebp
  80011b:	83 ec 08             	sub    $0x8,%esp
    return syscall(SYS_exit, error_code);
  80011e:	8b 45 08             	mov    0x8(%ebp),%eax
  800121:	89 44 24 04          	mov    %eax,0x4(%esp)
  800125:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80012c:	e8 8e ff ff ff       	call   8000bf <syscall>
}
  800131:	c9                   	leave  
  800132:	c3                   	ret    

00800133 <sys_fork>:

int
sys_fork(void) {
  800133:	f3 0f 1e fb          	endbr32 
  800137:	55                   	push   %ebp
  800138:	89 e5                	mov    %esp,%ebp
  80013a:	83 ec 04             	sub    $0x4,%esp
    return syscall(SYS_fork);
  80013d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800144:	e8 76 ff ff ff       	call   8000bf <syscall>
}
  800149:	c9                   	leave  
  80014a:	c3                   	ret    

0080014b <sys_wait>:

int
sys_wait(int pid, int *store) {
  80014b:	f3 0f 1e fb          	endbr32 
  80014f:	55                   	push   %ebp
  800150:	89 e5                	mov    %esp,%ebp
  800152:	83 ec 0c             	sub    $0xc,%esp
    return syscall(SYS_wait, pid, store);
  800155:	8b 45 0c             	mov    0xc(%ebp),%eax
  800158:	89 44 24 08          	mov    %eax,0x8(%esp)
  80015c:	8b 45 08             	mov    0x8(%ebp),%eax
  80015f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800163:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  80016a:	e8 50 ff ff ff       	call   8000bf <syscall>
}
  80016f:	c9                   	leave  
  800170:	c3                   	ret    

00800171 <sys_yield>:

int
sys_yield(void) {
  800171:	f3 0f 1e fb          	endbr32 
  800175:	55                   	push   %ebp
  800176:	89 e5                	mov    %esp,%ebp
  800178:	83 ec 04             	sub    $0x4,%esp
    return syscall(SYS_yield);
  80017b:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800182:	e8 38 ff ff ff       	call   8000bf <syscall>
}
  800187:	c9                   	leave  
  800188:	c3                   	ret    

00800189 <sys_kill>:

int
sys_kill(int pid) {
  800189:	f3 0f 1e fb          	endbr32 
  80018d:	55                   	push   %ebp
  80018e:	89 e5                	mov    %esp,%ebp
  800190:	83 ec 08             	sub    $0x8,%esp
    return syscall(SYS_kill, pid);
  800193:	8b 45 08             	mov    0x8(%ebp),%eax
  800196:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019a:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  8001a1:	e8 19 ff ff ff       	call   8000bf <syscall>
}
  8001a6:	c9                   	leave  
  8001a7:	c3                   	ret    

008001a8 <sys_getpid>:

int
sys_getpid(void) {
  8001a8:	f3 0f 1e fb          	endbr32 
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	83 ec 04             	sub    $0x4,%esp
    return syscall(SYS_getpid);
  8001b2:	c7 04 24 12 00 00 00 	movl   $0x12,(%esp)
  8001b9:	e8 01 ff ff ff       	call   8000bf <syscall>
}
  8001be:	c9                   	leave  
  8001bf:	c3                   	ret    

008001c0 <sys_putc>:

int
sys_putc(int c) {
  8001c0:	f3 0f 1e fb          	endbr32 
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	83 ec 08             	sub    $0x8,%esp
    return syscall(SYS_putc, c);
  8001ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8001cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d1:	c7 04 24 1e 00 00 00 	movl   $0x1e,(%esp)
  8001d8:	e8 e2 fe ff ff       	call   8000bf <syscall>
}
  8001dd:	c9                   	leave  
  8001de:	c3                   	ret    

008001df <sys_pgdir>:

int
sys_pgdir(void) {
  8001df:	f3 0f 1e fb          	endbr32 
  8001e3:	55                   	push   %ebp
  8001e4:	89 e5                	mov    %esp,%ebp
  8001e6:	83 ec 04             	sub    $0x4,%esp
    return syscall(SYS_pgdir);
  8001e9:	c7 04 24 1f 00 00 00 	movl   $0x1f,(%esp)
  8001f0:	e8 ca fe ff ff       	call   8000bf <syscall>
}
  8001f5:	c9                   	leave  
  8001f6:	c3                   	ret    

008001f7 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8001f7:	f3 0f 1e fb          	endbr32 
  8001fb:	55                   	push   %ebp
  8001fc:	89 e5                	mov    %esp,%ebp
  8001fe:	83 ec 18             	sub    $0x18,%esp
    sys_exit(error_code);
  800201:	8b 45 08             	mov    0x8(%ebp),%eax
  800204:	89 04 24             	mov    %eax,(%esp)
  800207:	e8 08 ff ff ff       	call   800114 <sys_exit>
    cprintf("BUG: exit failed.\n");
  80020c:	c7 04 24 b8 11 80 00 	movl   $0x8011b8,(%esp)
  800213:	e8 08 01 00 00       	call   800320 <cprintf>
    while (1);
  800218:	eb fe                	jmp    800218 <exit+0x21>

0080021a <fork>:
}

int
fork(void) {
  80021a:	f3 0f 1e fb          	endbr32 
  80021e:	55                   	push   %ebp
  80021f:	89 e5                	mov    %esp,%ebp
  800221:	83 ec 08             	sub    $0x8,%esp
    return sys_fork();
  800224:	e8 0a ff ff ff       	call   800133 <sys_fork>
}
  800229:	c9                   	leave  
  80022a:	c3                   	ret    

0080022b <wait>:

int
wait(void) {
  80022b:	f3 0f 1e fb          	endbr32 
  80022f:	55                   	push   %ebp
  800230:	89 e5                	mov    %esp,%ebp
  800232:	83 ec 18             	sub    $0x18,%esp
    return sys_wait(0, NULL);
  800235:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80023c:	00 
  80023d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800244:	e8 02 ff ff ff       	call   80014b <sys_wait>
}
  800249:	c9                   	leave  
  80024a:	c3                   	ret    

0080024b <waitpid>:

int
waitpid(int pid, int *store) {
  80024b:	f3 0f 1e fb          	endbr32 
  80024f:	55                   	push   %ebp
  800250:	89 e5                	mov    %esp,%ebp
  800252:	83 ec 18             	sub    $0x18,%esp
    return sys_wait(pid, store);
  800255:	8b 45 0c             	mov    0xc(%ebp),%eax
  800258:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025c:	8b 45 08             	mov    0x8(%ebp),%eax
  80025f:	89 04 24             	mov    %eax,(%esp)
  800262:	e8 e4 fe ff ff       	call   80014b <sys_wait>
}
  800267:	c9                   	leave  
  800268:	c3                   	ret    

00800269 <yield>:

void
yield(void) {
  800269:	f3 0f 1e fb          	endbr32 
  80026d:	55                   	push   %ebp
  80026e:	89 e5                	mov    %esp,%ebp
  800270:	83 ec 08             	sub    $0x8,%esp
    sys_yield();
  800273:	e8 f9 fe ff ff       	call   800171 <sys_yield>
}
  800278:	90                   	nop
  800279:	c9                   	leave  
  80027a:	c3                   	ret    

0080027b <kill>:

int
kill(int pid) {
  80027b:	f3 0f 1e fb          	endbr32 
  80027f:	55                   	push   %ebp
  800280:	89 e5                	mov    %esp,%ebp
  800282:	83 ec 18             	sub    $0x18,%esp
    return sys_kill(pid);
  800285:	8b 45 08             	mov    0x8(%ebp),%eax
  800288:	89 04 24             	mov    %eax,(%esp)
  80028b:	e8 f9 fe ff ff       	call   800189 <sys_kill>
}
  800290:	c9                   	leave  
  800291:	c3                   	ret    

00800292 <getpid>:

int
getpid(void) {
  800292:	f3 0f 1e fb          	endbr32 
  800296:	55                   	push   %ebp
  800297:	89 e5                	mov    %esp,%ebp
  800299:	83 ec 08             	sub    $0x8,%esp
    return sys_getpid();
  80029c:	e8 07 ff ff ff       	call   8001a8 <sys_getpid>
}
  8002a1:	c9                   	leave  
  8002a2:	c3                   	ret    

008002a3 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
  8002a3:	f3 0f 1e fb          	endbr32 
  8002a7:	55                   	push   %ebp
  8002a8:	89 e5                	mov    %esp,%ebp
  8002aa:	83 ec 08             	sub    $0x8,%esp
    sys_pgdir();
  8002ad:	e8 2d ff ff ff       	call   8001df <sys_pgdir>
}
  8002b2:	90                   	nop
  8002b3:	c9                   	leave  
  8002b4:	c3                   	ret    

008002b5 <_start>:
.text
.globl _start
_start:
    # set ebp for backtrace
    movl $0x0, %ebp
  8002b5:	bd 00 00 00 00       	mov    $0x0,%ebp

    # move down the esp register
    # since it may cause page fault in backtrace
    subl $0x20, %esp
  8002ba:	83 ec 20             	sub    $0x20,%esp

    # call user-program function
    call umain
  8002bd:	e8 db 00 00 00       	call   80039d <umain>
1:  jmp 1b
  8002c2:	eb fe                	jmp    8002c2 <_start+0xd>

008002c4 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  8002c4:	f3 0f 1e fb          	endbr32 
  8002c8:	55                   	push   %ebp
  8002c9:	89 e5                	mov    %esp,%ebp
  8002cb:	83 ec 18             	sub    $0x18,%esp
    sys_putc(c);
  8002ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d1:	89 04 24             	mov    %eax,(%esp)
  8002d4:	e8 e7 fe ff ff       	call   8001c0 <sys_putc>
    (*cnt) ++;
  8002d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002dc:	8b 00                	mov    (%eax),%eax
  8002de:	8d 50 01             	lea    0x1(%eax),%edx
  8002e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002e4:	89 10                	mov    %edx,(%eax)
}
  8002e6:	90                   	nop
  8002e7:	c9                   	leave  
  8002e8:	c3                   	ret    

008002e9 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  8002e9:	f3 0f 1e fb          	endbr32 
  8002ed:	55                   	push   %ebp
  8002ee:	89 e5                	mov    %esp,%ebp
  8002f0:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  8002f3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8002fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002fd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800301:	8b 45 08             	mov    0x8(%ebp),%eax
  800304:	89 44 24 08          	mov    %eax,0x8(%esp)
  800308:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80030b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80030f:	c7 04 24 c4 02 80 00 	movl   $0x8002c4,(%esp)
  800316:	e8 4d 07 00 00       	call   800a68 <vprintfmt>
    return cnt;
  80031b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80031e:	c9                   	leave  
  80031f:	c3                   	ret    

00800320 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  800320:	f3 0f 1e fb          	endbr32 
  800324:	55                   	push   %ebp
  800325:	89 e5                	mov    %esp,%ebp
  800327:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  80032a:	8d 45 0c             	lea    0xc(%ebp),%eax
  80032d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    int cnt = vcprintf(fmt, ap);
  800330:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800333:	89 44 24 04          	mov    %eax,0x4(%esp)
  800337:	8b 45 08             	mov    0x8(%ebp),%eax
  80033a:	89 04 24             	mov    %eax,(%esp)
  80033d:	e8 a7 ff ff ff       	call   8002e9 <vcprintf>
  800342:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);

    return cnt;
  800345:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800348:	c9                   	leave  
  800349:	c3                   	ret    

0080034a <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  80034a:	f3 0f 1e fb          	endbr32 
  80034e:	55                   	push   %ebp
  80034f:	89 e5                	mov    %esp,%ebp
  800351:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  800354:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  80035b:	eb 13                	jmp    800370 <cputs+0x26>
        cputch(c, &cnt);
  80035d:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  800361:	8d 55 f0             	lea    -0x10(%ebp),%edx
  800364:	89 54 24 04          	mov    %edx,0x4(%esp)
  800368:	89 04 24             	mov    %eax,(%esp)
  80036b:	e8 54 ff ff ff       	call   8002c4 <cputch>
    while ((c = *str ++) != '\0') {
  800370:	8b 45 08             	mov    0x8(%ebp),%eax
  800373:	8d 50 01             	lea    0x1(%eax),%edx
  800376:	89 55 08             	mov    %edx,0x8(%ebp)
  800379:	0f b6 00             	movzbl (%eax),%eax
  80037c:	88 45 f7             	mov    %al,-0x9(%ebp)
  80037f:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  800383:	75 d8                	jne    80035d <cputs+0x13>
    }
    cputch('\n', &cnt);
  800385:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800388:	89 44 24 04          	mov    %eax,0x4(%esp)
  80038c:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800393:	e8 2c ff ff ff       	call   8002c4 <cputch>
    return cnt;
  800398:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  80039b:	c9                   	leave  
  80039c:	c3                   	ret    

0080039d <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  80039d:	f3 0f 1e fb          	endbr32 
  8003a1:	55                   	push   %ebp
  8003a2:	89 e5                	mov    %esp,%ebp
  8003a4:	83 ec 28             	sub    $0x28,%esp
    int ret = main();
  8003a7:	e8 7d 0c 00 00       	call   801029 <main>
  8003ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
    exit(ret);
  8003af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8003b2:	89 04 24             	mov    %eax,(%esp)
  8003b5:	e8 3d fe ff ff       	call   8001f7 <exit>

008003ba <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  8003ba:	f3 0f 1e fb          	endbr32 
  8003be:	55                   	push   %ebp
  8003bf:	89 e5                	mov    %esp,%ebp
  8003c1:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  8003c4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  8003cb:	eb 03                	jmp    8003d0 <strlen+0x16>
        cnt ++;
  8003cd:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
  8003d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d3:	8d 50 01             	lea    0x1(%eax),%edx
  8003d6:	89 55 08             	mov    %edx,0x8(%ebp)
  8003d9:	0f b6 00             	movzbl (%eax),%eax
  8003dc:	84 c0                	test   %al,%al
  8003de:	75 ed                	jne    8003cd <strlen+0x13>
    }
    return cnt;
  8003e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8003e3:	c9                   	leave  
  8003e4:	c3                   	ret    

008003e5 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  8003e5:	f3 0f 1e fb          	endbr32 
  8003e9:	55                   	push   %ebp
  8003ea:	89 e5                	mov    %esp,%ebp
  8003ec:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  8003ef:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  8003f6:	eb 03                	jmp    8003fb <strnlen+0x16>
        cnt ++;
  8003f8:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  8003fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8003fe:	3b 45 0c             	cmp    0xc(%ebp),%eax
  800401:	73 10                	jae    800413 <strnlen+0x2e>
  800403:	8b 45 08             	mov    0x8(%ebp),%eax
  800406:	8d 50 01             	lea    0x1(%eax),%edx
  800409:	89 55 08             	mov    %edx,0x8(%ebp)
  80040c:	0f b6 00             	movzbl (%eax),%eax
  80040f:	84 c0                	test   %al,%al
  800411:	75 e5                	jne    8003f8 <strnlen+0x13>
    }
    return cnt;
  800413:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800416:	c9                   	leave  
  800417:	c3                   	ret    

00800418 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  800418:	f3 0f 1e fb          	endbr32 
  80041c:	55                   	push   %ebp
  80041d:	89 e5                	mov    %esp,%ebp
  80041f:	57                   	push   %edi
  800420:	56                   	push   %esi
  800421:	83 ec 20             	sub    $0x20,%esp
  800424:	8b 45 08             	mov    0x8(%ebp),%eax
  800427:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80042a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80042d:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  800430:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800433:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800436:	89 d1                	mov    %edx,%ecx
  800438:	89 c2                	mov    %eax,%edx
  80043a:	89 ce                	mov    %ecx,%esi
  80043c:	89 d7                	mov    %edx,%edi
  80043e:	ac                   	lods   %ds:(%esi),%al
  80043f:	aa                   	stos   %al,%es:(%edi)
  800440:	84 c0                	test   %al,%al
  800442:	75 fa                	jne    80043e <strcpy+0x26>
  800444:	89 fa                	mov    %edi,%edx
  800446:	89 f1                	mov    %esi,%ecx
  800448:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  80044b:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80044e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
  800451:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  800454:	83 c4 20             	add    $0x20,%esp
  800457:	5e                   	pop    %esi
  800458:	5f                   	pop    %edi
  800459:	5d                   	pop    %ebp
  80045a:	c3                   	ret    

0080045b <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  80045b:	f3 0f 1e fb          	endbr32 
  80045f:	55                   	push   %ebp
  800460:	89 e5                	mov    %esp,%ebp
  800462:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  800465:	8b 45 08             	mov    0x8(%ebp),%eax
  800468:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  80046b:	eb 1e                	jmp    80048b <strncpy+0x30>
        if ((*p = *src) != '\0') {
  80046d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800470:	0f b6 10             	movzbl (%eax),%edx
  800473:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800476:	88 10                	mov    %dl,(%eax)
  800478:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80047b:	0f b6 00             	movzbl (%eax),%eax
  80047e:	84 c0                	test   %al,%al
  800480:	74 03                	je     800485 <strncpy+0x2a>
            src ++;
  800482:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
  800485:	ff 45 fc             	incl   -0x4(%ebp)
  800488:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
  80048b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80048f:	75 dc                	jne    80046d <strncpy+0x12>
    }
    return dst;
  800491:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800494:	c9                   	leave  
  800495:	c3                   	ret    

00800496 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  800496:	f3 0f 1e fb          	endbr32 
  80049a:	55                   	push   %ebp
  80049b:	89 e5                	mov    %esp,%ebp
  80049d:	57                   	push   %edi
  80049e:	56                   	push   %esi
  80049f:	83 ec 20             	sub    $0x20,%esp
  8004a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8004a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
  8004ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8004b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004b4:	89 d1                	mov    %edx,%ecx
  8004b6:	89 c2                	mov    %eax,%edx
  8004b8:	89 ce                	mov    %ecx,%esi
  8004ba:	89 d7                	mov    %edx,%edi
  8004bc:	ac                   	lods   %ds:(%esi),%al
  8004bd:	ae                   	scas   %es:(%edi),%al
  8004be:	75 08                	jne    8004c8 <strcmp+0x32>
  8004c0:	84 c0                	test   %al,%al
  8004c2:	75 f8                	jne    8004bc <strcmp+0x26>
  8004c4:	31 c0                	xor    %eax,%eax
  8004c6:	eb 04                	jmp    8004cc <strcmp+0x36>
  8004c8:	19 c0                	sbb    %eax,%eax
  8004ca:	0c 01                	or     $0x1,%al
  8004cc:	89 fa                	mov    %edi,%edx
  8004ce:	89 f1                	mov    %esi,%ecx
  8004d0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8004d3:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  8004d6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
  8004d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  8004dc:	83 c4 20             	add    $0x20,%esp
  8004df:	5e                   	pop    %esi
  8004e0:	5f                   	pop    %edi
  8004e1:	5d                   	pop    %ebp
  8004e2:	c3                   	ret    

008004e3 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  8004e3:	f3 0f 1e fb          	endbr32 
  8004e7:	55                   	push   %ebp
  8004e8:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  8004ea:	eb 09                	jmp    8004f5 <strncmp+0x12>
        n --, s1 ++, s2 ++;
  8004ec:	ff 4d 10             	decl   0x10(%ebp)
  8004ef:	ff 45 08             	incl   0x8(%ebp)
  8004f2:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  8004f5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8004f9:	74 1a                	je     800515 <strncmp+0x32>
  8004fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8004fe:	0f b6 00             	movzbl (%eax),%eax
  800501:	84 c0                	test   %al,%al
  800503:	74 10                	je     800515 <strncmp+0x32>
  800505:	8b 45 08             	mov    0x8(%ebp),%eax
  800508:	0f b6 10             	movzbl (%eax),%edx
  80050b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80050e:	0f b6 00             	movzbl (%eax),%eax
  800511:	38 c2                	cmp    %al,%dl
  800513:	74 d7                	je     8004ec <strncmp+0x9>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  800515:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800519:	74 18                	je     800533 <strncmp+0x50>
  80051b:	8b 45 08             	mov    0x8(%ebp),%eax
  80051e:	0f b6 00             	movzbl (%eax),%eax
  800521:	0f b6 d0             	movzbl %al,%edx
  800524:	8b 45 0c             	mov    0xc(%ebp),%eax
  800527:	0f b6 00             	movzbl (%eax),%eax
  80052a:	0f b6 c0             	movzbl %al,%eax
  80052d:	29 c2                	sub    %eax,%edx
  80052f:	89 d0                	mov    %edx,%eax
  800531:	eb 05                	jmp    800538 <strncmp+0x55>
  800533:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800538:	5d                   	pop    %ebp
  800539:	c3                   	ret    

0080053a <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  80053a:	f3 0f 1e fb          	endbr32 
  80053e:	55                   	push   %ebp
  80053f:	89 e5                	mov    %esp,%ebp
  800541:	83 ec 04             	sub    $0x4,%esp
  800544:	8b 45 0c             	mov    0xc(%ebp),%eax
  800547:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  80054a:	eb 13                	jmp    80055f <strchr+0x25>
        if (*s == c) {
  80054c:	8b 45 08             	mov    0x8(%ebp),%eax
  80054f:	0f b6 00             	movzbl (%eax),%eax
  800552:	38 45 fc             	cmp    %al,-0x4(%ebp)
  800555:	75 05                	jne    80055c <strchr+0x22>
            return (char *)s;
  800557:	8b 45 08             	mov    0x8(%ebp),%eax
  80055a:	eb 12                	jmp    80056e <strchr+0x34>
        }
        s ++;
  80055c:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  80055f:	8b 45 08             	mov    0x8(%ebp),%eax
  800562:	0f b6 00             	movzbl (%eax),%eax
  800565:	84 c0                	test   %al,%al
  800567:	75 e3                	jne    80054c <strchr+0x12>
    }
    return NULL;
  800569:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80056e:	c9                   	leave  
  80056f:	c3                   	ret    

00800570 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  800570:	f3 0f 1e fb          	endbr32 
  800574:	55                   	push   %ebp
  800575:	89 e5                	mov    %esp,%ebp
  800577:	83 ec 04             	sub    $0x4,%esp
  80057a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80057d:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  800580:	eb 0e                	jmp    800590 <strfind+0x20>
        if (*s == c) {
  800582:	8b 45 08             	mov    0x8(%ebp),%eax
  800585:	0f b6 00             	movzbl (%eax),%eax
  800588:	38 45 fc             	cmp    %al,-0x4(%ebp)
  80058b:	74 0f                	je     80059c <strfind+0x2c>
            break;
        }
        s ++;
  80058d:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  800590:	8b 45 08             	mov    0x8(%ebp),%eax
  800593:	0f b6 00             	movzbl (%eax),%eax
  800596:	84 c0                	test   %al,%al
  800598:	75 e8                	jne    800582 <strfind+0x12>
  80059a:	eb 01                	jmp    80059d <strfind+0x2d>
            break;
  80059c:	90                   	nop
    }
    return (char *)s;
  80059d:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8005a0:	c9                   	leave  
  8005a1:	c3                   	ret    

008005a2 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  8005a2:	f3 0f 1e fb          	endbr32 
  8005a6:	55                   	push   %ebp
  8005a7:	89 e5                	mov    %esp,%ebp
  8005a9:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  8005ac:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  8005b3:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  8005ba:	eb 03                	jmp    8005bf <strtol+0x1d>
        s ++;
  8005bc:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
  8005bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8005c2:	0f b6 00             	movzbl (%eax),%eax
  8005c5:	3c 20                	cmp    $0x20,%al
  8005c7:	74 f3                	je     8005bc <strtol+0x1a>
  8005c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8005cc:	0f b6 00             	movzbl (%eax),%eax
  8005cf:	3c 09                	cmp    $0x9,%al
  8005d1:	74 e9                	je     8005bc <strtol+0x1a>
    }

    // plus/minus sign
    if (*s == '+') {
  8005d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8005d6:	0f b6 00             	movzbl (%eax),%eax
  8005d9:	3c 2b                	cmp    $0x2b,%al
  8005db:	75 05                	jne    8005e2 <strtol+0x40>
        s ++;
  8005dd:	ff 45 08             	incl   0x8(%ebp)
  8005e0:	eb 14                	jmp    8005f6 <strtol+0x54>
    }
    else if (*s == '-') {
  8005e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e5:	0f b6 00             	movzbl (%eax),%eax
  8005e8:	3c 2d                	cmp    $0x2d,%al
  8005ea:	75 0a                	jne    8005f6 <strtol+0x54>
        s ++, neg = 1;
  8005ec:	ff 45 08             	incl   0x8(%ebp)
  8005ef:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  8005f6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8005fa:	74 06                	je     800602 <strtol+0x60>
  8005fc:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800600:	75 22                	jne    800624 <strtol+0x82>
  800602:	8b 45 08             	mov    0x8(%ebp),%eax
  800605:	0f b6 00             	movzbl (%eax),%eax
  800608:	3c 30                	cmp    $0x30,%al
  80060a:	75 18                	jne    800624 <strtol+0x82>
  80060c:	8b 45 08             	mov    0x8(%ebp),%eax
  80060f:	40                   	inc    %eax
  800610:	0f b6 00             	movzbl (%eax),%eax
  800613:	3c 78                	cmp    $0x78,%al
  800615:	75 0d                	jne    800624 <strtol+0x82>
        s += 2, base = 16;
  800617:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  80061b:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800622:	eb 29                	jmp    80064d <strtol+0xab>
    }
    else if (base == 0 && s[0] == '0') {
  800624:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800628:	75 16                	jne    800640 <strtol+0x9e>
  80062a:	8b 45 08             	mov    0x8(%ebp),%eax
  80062d:	0f b6 00             	movzbl (%eax),%eax
  800630:	3c 30                	cmp    $0x30,%al
  800632:	75 0c                	jne    800640 <strtol+0x9e>
        s ++, base = 8;
  800634:	ff 45 08             	incl   0x8(%ebp)
  800637:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  80063e:	eb 0d                	jmp    80064d <strtol+0xab>
    }
    else if (base == 0) {
  800640:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800644:	75 07                	jne    80064d <strtol+0xab>
        base = 10;
  800646:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  80064d:	8b 45 08             	mov    0x8(%ebp),%eax
  800650:	0f b6 00             	movzbl (%eax),%eax
  800653:	3c 2f                	cmp    $0x2f,%al
  800655:	7e 1b                	jle    800672 <strtol+0xd0>
  800657:	8b 45 08             	mov    0x8(%ebp),%eax
  80065a:	0f b6 00             	movzbl (%eax),%eax
  80065d:	3c 39                	cmp    $0x39,%al
  80065f:	7f 11                	jg     800672 <strtol+0xd0>
            dig = *s - '0';
  800661:	8b 45 08             	mov    0x8(%ebp),%eax
  800664:	0f b6 00             	movzbl (%eax),%eax
  800667:	0f be c0             	movsbl %al,%eax
  80066a:	83 e8 30             	sub    $0x30,%eax
  80066d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800670:	eb 48                	jmp    8006ba <strtol+0x118>
        }
        else if (*s >= 'a' && *s <= 'z') {
  800672:	8b 45 08             	mov    0x8(%ebp),%eax
  800675:	0f b6 00             	movzbl (%eax),%eax
  800678:	3c 60                	cmp    $0x60,%al
  80067a:	7e 1b                	jle    800697 <strtol+0xf5>
  80067c:	8b 45 08             	mov    0x8(%ebp),%eax
  80067f:	0f b6 00             	movzbl (%eax),%eax
  800682:	3c 7a                	cmp    $0x7a,%al
  800684:	7f 11                	jg     800697 <strtol+0xf5>
            dig = *s - 'a' + 10;
  800686:	8b 45 08             	mov    0x8(%ebp),%eax
  800689:	0f b6 00             	movzbl (%eax),%eax
  80068c:	0f be c0             	movsbl %al,%eax
  80068f:	83 e8 57             	sub    $0x57,%eax
  800692:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800695:	eb 23                	jmp    8006ba <strtol+0x118>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  800697:	8b 45 08             	mov    0x8(%ebp),%eax
  80069a:	0f b6 00             	movzbl (%eax),%eax
  80069d:	3c 40                	cmp    $0x40,%al
  80069f:	7e 3b                	jle    8006dc <strtol+0x13a>
  8006a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a4:	0f b6 00             	movzbl (%eax),%eax
  8006a7:	3c 5a                	cmp    $0x5a,%al
  8006a9:	7f 31                	jg     8006dc <strtol+0x13a>
            dig = *s - 'A' + 10;
  8006ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ae:	0f b6 00             	movzbl (%eax),%eax
  8006b1:	0f be c0             	movsbl %al,%eax
  8006b4:	83 e8 37             	sub    $0x37,%eax
  8006b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  8006ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006bd:	3b 45 10             	cmp    0x10(%ebp),%eax
  8006c0:	7d 19                	jge    8006db <strtol+0x139>
            break;
        }
        s ++, val = (val * base) + dig;
  8006c2:	ff 45 08             	incl   0x8(%ebp)
  8006c5:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8006c8:	0f af 45 10          	imul   0x10(%ebp),%eax
  8006cc:	89 c2                	mov    %eax,%edx
  8006ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006d1:	01 d0                	add    %edx,%eax
  8006d3:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
  8006d6:	e9 72 ff ff ff       	jmp    80064d <strtol+0xab>
            break;
  8006db:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
  8006dc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8006e0:	74 08                	je     8006ea <strtol+0x148>
        *endptr = (char *) s;
  8006e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8006e8:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  8006ea:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  8006ee:	74 07                	je     8006f7 <strtol+0x155>
  8006f0:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8006f3:	f7 d8                	neg    %eax
  8006f5:	eb 03                	jmp    8006fa <strtol+0x158>
  8006f7:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  8006fa:	c9                   	leave  
  8006fb:	c3                   	ret    

008006fc <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  8006fc:	f3 0f 1e fb          	endbr32 
  800700:	55                   	push   %ebp
  800701:	89 e5                	mov    %esp,%ebp
  800703:	57                   	push   %edi
  800704:	83 ec 24             	sub    $0x24,%esp
  800707:	8b 45 0c             	mov    0xc(%ebp),%eax
  80070a:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  80070d:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800711:	8b 45 08             	mov    0x8(%ebp),%eax
  800714:	89 45 f8             	mov    %eax,-0x8(%ebp)
  800717:	88 55 f7             	mov    %dl,-0x9(%ebp)
  80071a:	8b 45 10             	mov    0x10(%ebp),%eax
  80071d:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  800720:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  800723:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800727:	8b 55 f8             	mov    -0x8(%ebp),%edx
  80072a:	89 d7                	mov    %edx,%edi
  80072c:	f3 aa                	rep stos %al,%es:(%edi)
  80072e:	89 fa                	mov    %edi,%edx
  800730:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  800733:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
  800736:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  800739:	83 c4 24             	add    $0x24,%esp
  80073c:	5f                   	pop    %edi
  80073d:	5d                   	pop    %ebp
  80073e:	c3                   	ret    

0080073f <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  80073f:	f3 0f 1e fb          	endbr32 
  800743:	55                   	push   %ebp
  800744:	89 e5                	mov    %esp,%ebp
  800746:	57                   	push   %edi
  800747:	56                   	push   %esi
  800748:	53                   	push   %ebx
  800749:	83 ec 30             	sub    $0x30,%esp
  80074c:	8b 45 08             	mov    0x8(%ebp),%eax
  80074f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800752:	8b 45 0c             	mov    0xc(%ebp),%eax
  800755:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800758:	8b 45 10             	mov    0x10(%ebp),%eax
  80075b:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  80075e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800761:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800764:	73 42                	jae    8007a8 <memmove+0x69>
  800766:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800769:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80076c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80076f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800772:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800775:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  800778:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80077b:	c1 e8 02             	shr    $0x2,%eax
  80077e:	89 c1                	mov    %eax,%ecx
    asm volatile (
  800780:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800783:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800786:	89 d7                	mov    %edx,%edi
  800788:	89 c6                	mov    %eax,%esi
  80078a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80078c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80078f:	83 e1 03             	and    $0x3,%ecx
  800792:	74 02                	je     800796 <memmove+0x57>
  800794:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  800796:	89 f0                	mov    %esi,%eax
  800798:	89 fa                	mov    %edi,%edx
  80079a:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  80079d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8007a0:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
  8007a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
        return __memcpy(dst, src, n);
  8007a6:	eb 36                	jmp    8007de <memmove+0x9f>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  8007a8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8007ab:	8d 50 ff             	lea    -0x1(%eax),%edx
  8007ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007b1:	01 c2                	add    %eax,%edx
  8007b3:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8007b6:	8d 48 ff             	lea    -0x1(%eax),%ecx
  8007b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007bc:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
  8007bf:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8007c2:	89 c1                	mov    %eax,%ecx
  8007c4:	89 d8                	mov    %ebx,%eax
  8007c6:	89 d6                	mov    %edx,%esi
  8007c8:	89 c7                	mov    %eax,%edi
  8007ca:	fd                   	std    
  8007cb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  8007cd:	fc                   	cld    
  8007ce:	89 f8                	mov    %edi,%eax
  8007d0:	89 f2                	mov    %esi,%edx
  8007d2:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8007d5:	89 55 c8             	mov    %edx,-0x38(%ebp)
  8007d8:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
  8007db:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  8007de:	83 c4 30             	add    $0x30,%esp
  8007e1:	5b                   	pop    %ebx
  8007e2:	5e                   	pop    %esi
  8007e3:	5f                   	pop    %edi
  8007e4:	5d                   	pop    %ebp
  8007e5:	c3                   	ret    

008007e6 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  8007e6:	f3 0f 1e fb          	endbr32 
  8007ea:	55                   	push   %ebp
  8007eb:	89 e5                	mov    %esp,%ebp
  8007ed:	57                   	push   %edi
  8007ee:	56                   	push   %esi
  8007ef:	83 ec 20             	sub    $0x20,%esp
  8007f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8007f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007fe:	8b 45 10             	mov    0x10(%ebp),%eax
  800801:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  800804:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800807:	c1 e8 02             	shr    $0x2,%eax
  80080a:	89 c1                	mov    %eax,%ecx
    asm volatile (
  80080c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80080f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800812:	89 d7                	mov    %edx,%edi
  800814:	89 c6                	mov    %eax,%esi
  800816:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800818:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  80081b:	83 e1 03             	and    $0x3,%ecx
  80081e:	74 02                	je     800822 <memcpy+0x3c>
  800820:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  800822:	89 f0                	mov    %esi,%eax
  800824:	89 fa                	mov    %edi,%edx
  800826:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  800829:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80082c:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
  80082f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  800832:	83 c4 20             	add    $0x20,%esp
  800835:	5e                   	pop    %esi
  800836:	5f                   	pop    %edi
  800837:	5d                   	pop    %ebp
  800838:	c3                   	ret    

00800839 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  800839:	f3 0f 1e fb          	endbr32 
  80083d:	55                   	push   %ebp
  80083e:	89 e5                	mov    %esp,%ebp
  800840:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  800843:	8b 45 08             	mov    0x8(%ebp),%eax
  800846:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  800849:	8b 45 0c             	mov    0xc(%ebp),%eax
  80084c:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  80084f:	eb 2e                	jmp    80087f <memcmp+0x46>
        if (*s1 != *s2) {
  800851:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800854:	0f b6 10             	movzbl (%eax),%edx
  800857:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80085a:	0f b6 00             	movzbl (%eax),%eax
  80085d:	38 c2                	cmp    %al,%dl
  80085f:	74 18                	je     800879 <memcmp+0x40>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  800861:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800864:	0f b6 00             	movzbl (%eax),%eax
  800867:	0f b6 d0             	movzbl %al,%edx
  80086a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80086d:	0f b6 00             	movzbl (%eax),%eax
  800870:	0f b6 c0             	movzbl %al,%eax
  800873:	29 c2                	sub    %eax,%edx
  800875:	89 d0                	mov    %edx,%eax
  800877:	eb 18                	jmp    800891 <memcmp+0x58>
        }
        s1 ++, s2 ++;
  800879:	ff 45 fc             	incl   -0x4(%ebp)
  80087c:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
  80087f:	8b 45 10             	mov    0x10(%ebp),%eax
  800882:	8d 50 ff             	lea    -0x1(%eax),%edx
  800885:	89 55 10             	mov    %edx,0x10(%ebp)
  800888:	85 c0                	test   %eax,%eax
  80088a:	75 c5                	jne    800851 <memcmp+0x18>
    }
    return 0;
  80088c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800891:	c9                   	leave  
  800892:	c3                   	ret    

00800893 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  800893:	f3 0f 1e fb          	endbr32 
  800897:	55                   	push   %ebp
  800898:	89 e5                	mov    %esp,%ebp
  80089a:	83 ec 58             	sub    $0x58,%esp
  80089d:	8b 45 10             	mov    0x10(%ebp),%eax
  8008a0:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8008a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  8008a9:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8008ac:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8008af:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8008b2:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  8008b5:	8b 45 18             	mov    0x18(%ebp),%eax
  8008b8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008bb:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8008be:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8008c1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008c4:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8008c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8008cd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8008d1:	74 1c                	je     8008ef <printnum+0x5c>
  8008d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8008db:	f7 75 e4             	divl   -0x1c(%ebp)
  8008de:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8008e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8008e9:	f7 75 e4             	divl   -0x1c(%ebp)
  8008ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8008ef:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8008f5:	f7 75 e4             	divl   -0x1c(%ebp)
  8008f8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008fb:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8008fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800901:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800904:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800907:	89 55 ec             	mov    %edx,-0x14(%ebp)
  80090a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80090d:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  800910:	8b 45 18             	mov    0x18(%ebp),%eax
  800913:	ba 00 00 00 00       	mov    $0x0,%edx
  800918:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80091b:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  80091e:	19 d1                	sbb    %edx,%ecx
  800920:	72 4c                	jb     80096e <printnum+0xdb>
        printnum(putch, putdat, result, base, width - 1, padc);
  800922:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800925:	8d 50 ff             	lea    -0x1(%eax),%edx
  800928:	8b 45 20             	mov    0x20(%ebp),%eax
  80092b:	89 44 24 18          	mov    %eax,0x18(%esp)
  80092f:	89 54 24 14          	mov    %edx,0x14(%esp)
  800933:	8b 45 18             	mov    0x18(%ebp),%eax
  800936:	89 44 24 10          	mov    %eax,0x10(%esp)
  80093a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80093d:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800940:	89 44 24 08          	mov    %eax,0x8(%esp)
  800944:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800948:	8b 45 0c             	mov    0xc(%ebp),%eax
  80094b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80094f:	8b 45 08             	mov    0x8(%ebp),%eax
  800952:	89 04 24             	mov    %eax,(%esp)
  800955:	e8 39 ff ff ff       	call   800893 <printnum>
  80095a:	eb 1b                	jmp    800977 <printnum+0xe4>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  80095c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80095f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800963:	8b 45 20             	mov    0x20(%ebp),%eax
  800966:	89 04 24             	mov    %eax,(%esp)
  800969:	8b 45 08             	mov    0x8(%ebp),%eax
  80096c:	ff d0                	call   *%eax
        while (-- width > 0)
  80096e:	ff 4d 1c             	decl   0x1c(%ebp)
  800971:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800975:	7f e5                	jg     80095c <printnum+0xc9>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800977:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80097a:	05 e4 12 80 00       	add    $0x8012e4,%eax
  80097f:	0f b6 00             	movzbl (%eax),%eax
  800982:	0f be c0             	movsbl %al,%eax
  800985:	8b 55 0c             	mov    0xc(%ebp),%edx
  800988:	89 54 24 04          	mov    %edx,0x4(%esp)
  80098c:	89 04 24             	mov    %eax,(%esp)
  80098f:	8b 45 08             	mov    0x8(%ebp),%eax
  800992:	ff d0                	call   *%eax
}
  800994:	90                   	nop
  800995:	c9                   	leave  
  800996:	c3                   	ret    

00800997 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  800997:	f3 0f 1e fb          	endbr32 
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  80099e:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8009a2:	7e 14                	jle    8009b8 <getuint+0x21>
        return va_arg(*ap, unsigned long long);
  8009a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a7:	8b 00                	mov    (%eax),%eax
  8009a9:	8d 48 08             	lea    0x8(%eax),%ecx
  8009ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8009af:	89 0a                	mov    %ecx,(%edx)
  8009b1:	8b 50 04             	mov    0x4(%eax),%edx
  8009b4:	8b 00                	mov    (%eax),%eax
  8009b6:	eb 30                	jmp    8009e8 <getuint+0x51>
    }
    else if (lflag) {
  8009b8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8009bc:	74 16                	je     8009d4 <getuint+0x3d>
        return va_arg(*ap, unsigned long);
  8009be:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c1:	8b 00                	mov    (%eax),%eax
  8009c3:	8d 48 04             	lea    0x4(%eax),%ecx
  8009c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8009c9:	89 0a                	mov    %ecx,(%edx)
  8009cb:	8b 00                	mov    (%eax),%eax
  8009cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8009d2:	eb 14                	jmp    8009e8 <getuint+0x51>
    }
    else {
        return va_arg(*ap, unsigned int);
  8009d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d7:	8b 00                	mov    (%eax),%eax
  8009d9:	8d 48 04             	lea    0x4(%eax),%ecx
  8009dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8009df:	89 0a                	mov    %ecx,(%edx)
  8009e1:	8b 00                	mov    (%eax),%eax
  8009e3:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  8009e8:	5d                   	pop    %ebp
  8009e9:	c3                   	ret    

008009ea <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  8009ea:	f3 0f 1e fb          	endbr32 
  8009ee:	55                   	push   %ebp
  8009ef:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  8009f1:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8009f5:	7e 14                	jle    800a0b <getint+0x21>
        return va_arg(*ap, long long);
  8009f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fa:	8b 00                	mov    (%eax),%eax
  8009fc:	8d 48 08             	lea    0x8(%eax),%ecx
  8009ff:	8b 55 08             	mov    0x8(%ebp),%edx
  800a02:	89 0a                	mov    %ecx,(%edx)
  800a04:	8b 50 04             	mov    0x4(%eax),%edx
  800a07:	8b 00                	mov    (%eax),%eax
  800a09:	eb 28                	jmp    800a33 <getint+0x49>
    }
    else if (lflag) {
  800a0b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a0f:	74 12                	je     800a23 <getint+0x39>
        return va_arg(*ap, long);
  800a11:	8b 45 08             	mov    0x8(%ebp),%eax
  800a14:	8b 00                	mov    (%eax),%eax
  800a16:	8d 48 04             	lea    0x4(%eax),%ecx
  800a19:	8b 55 08             	mov    0x8(%ebp),%edx
  800a1c:	89 0a                	mov    %ecx,(%edx)
  800a1e:	8b 00                	mov    (%eax),%eax
  800a20:	99                   	cltd   
  800a21:	eb 10                	jmp    800a33 <getint+0x49>
    }
    else {
        return va_arg(*ap, int);
  800a23:	8b 45 08             	mov    0x8(%ebp),%eax
  800a26:	8b 00                	mov    (%eax),%eax
  800a28:	8d 48 04             	lea    0x4(%eax),%ecx
  800a2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800a2e:	89 0a                	mov    %ecx,(%edx)
  800a30:	8b 00                	mov    (%eax),%eax
  800a32:	99                   	cltd   
    }
}
  800a33:	5d                   	pop    %ebp
  800a34:	c3                   	ret    

00800a35 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800a35:	f3 0f 1e fb          	endbr32 
  800a39:	55                   	push   %ebp
  800a3a:	89 e5                	mov    %esp,%ebp
  800a3c:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  800a3f:	8d 45 14             	lea    0x14(%ebp),%eax
  800a42:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  800a45:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a48:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a4c:	8b 45 10             	mov    0x10(%ebp),%eax
  800a4f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a53:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a56:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5d:	89 04 24             	mov    %eax,(%esp)
  800a60:	e8 03 00 00 00       	call   800a68 <vprintfmt>
    va_end(ap);
}
  800a65:	90                   	nop
  800a66:	c9                   	leave  
  800a67:	c3                   	ret    

00800a68 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  800a68:	f3 0f 1e fb          	endbr32 
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	56                   	push   %esi
  800a70:	53                   	push   %ebx
  800a71:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800a74:	eb 17                	jmp    800a8d <vprintfmt+0x25>
            if (ch == '\0') {
  800a76:	85 db                	test   %ebx,%ebx
  800a78:	0f 84 c0 03 00 00    	je     800e3e <vprintfmt+0x3d6>
                return;
            }
            putch(ch, putdat);
  800a7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a81:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a85:	89 1c 24             	mov    %ebx,(%esp)
  800a88:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8b:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800a8d:	8b 45 10             	mov    0x10(%ebp),%eax
  800a90:	8d 50 01             	lea    0x1(%eax),%edx
  800a93:	89 55 10             	mov    %edx,0x10(%ebp)
  800a96:	0f b6 00             	movzbl (%eax),%eax
  800a99:	0f b6 d8             	movzbl %al,%ebx
  800a9c:	83 fb 25             	cmp    $0x25,%ebx
  800a9f:	75 d5                	jne    800a76 <vprintfmt+0xe>
        }

        // Process a %-escape sequence
        char padc = ' ';
  800aa1:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  800aa5:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800aac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800aaf:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  800ab2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800ab9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800abc:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  800abf:	8b 45 10             	mov    0x10(%ebp),%eax
  800ac2:	8d 50 01             	lea    0x1(%eax),%edx
  800ac5:	89 55 10             	mov    %edx,0x10(%ebp)
  800ac8:	0f b6 00             	movzbl (%eax),%eax
  800acb:	0f b6 d8             	movzbl %al,%ebx
  800ace:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800ad1:	83 f8 55             	cmp    $0x55,%eax
  800ad4:	0f 87 38 03 00 00    	ja     800e12 <vprintfmt+0x3aa>
  800ada:	8b 04 85 08 13 80 00 	mov    0x801308(,%eax,4),%eax
  800ae1:	3e ff e0             	notrack jmp *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  800ae4:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  800ae8:	eb d5                	jmp    800abf <vprintfmt+0x57>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  800aea:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  800aee:	eb cf                	jmp    800abf <vprintfmt+0x57>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  800af0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  800af7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800afa:	89 d0                	mov    %edx,%eax
  800afc:	c1 e0 02             	shl    $0x2,%eax
  800aff:	01 d0                	add    %edx,%eax
  800b01:	01 c0                	add    %eax,%eax
  800b03:	01 d8                	add    %ebx,%eax
  800b05:	83 e8 30             	sub    $0x30,%eax
  800b08:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  800b0b:	8b 45 10             	mov    0x10(%ebp),%eax
  800b0e:	0f b6 00             	movzbl (%eax),%eax
  800b11:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  800b14:	83 fb 2f             	cmp    $0x2f,%ebx
  800b17:	7e 38                	jle    800b51 <vprintfmt+0xe9>
  800b19:	83 fb 39             	cmp    $0x39,%ebx
  800b1c:	7f 33                	jg     800b51 <vprintfmt+0xe9>
            for (precision = 0; ; ++ fmt) {
  800b1e:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
  800b21:	eb d4                	jmp    800af7 <vprintfmt+0x8f>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
  800b23:	8b 45 14             	mov    0x14(%ebp),%eax
  800b26:	8d 50 04             	lea    0x4(%eax),%edx
  800b29:	89 55 14             	mov    %edx,0x14(%ebp)
  800b2c:	8b 00                	mov    (%eax),%eax
  800b2e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  800b31:	eb 1f                	jmp    800b52 <vprintfmt+0xea>

        case '.':
            if (width < 0)
  800b33:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800b37:	79 86                	jns    800abf <vprintfmt+0x57>
                width = 0;
  800b39:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  800b40:	e9 7a ff ff ff       	jmp    800abf <vprintfmt+0x57>

        case '#':
            altflag = 1;
  800b45:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  800b4c:	e9 6e ff ff ff       	jmp    800abf <vprintfmt+0x57>
            goto process_precision;
  800b51:	90                   	nop

        process_precision:
            if (width < 0)
  800b52:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800b56:	0f 89 63 ff ff ff    	jns    800abf <vprintfmt+0x57>
                width = precision, precision = -1;
  800b5c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800b5f:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800b62:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  800b69:	e9 51 ff ff ff       	jmp    800abf <vprintfmt+0x57>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  800b6e:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
  800b71:	e9 49 ff ff ff       	jmp    800abf <vprintfmt+0x57>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  800b76:	8b 45 14             	mov    0x14(%ebp),%eax
  800b79:	8d 50 04             	lea    0x4(%eax),%edx
  800b7c:	89 55 14             	mov    %edx,0x14(%ebp)
  800b7f:	8b 00                	mov    (%eax),%eax
  800b81:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b84:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b88:	89 04 24             	mov    %eax,(%esp)
  800b8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8e:	ff d0                	call   *%eax
            break;
  800b90:	e9 a4 02 00 00       	jmp    800e39 <vprintfmt+0x3d1>

        // error message
        case 'e':
            err = va_arg(ap, int);
  800b95:	8b 45 14             	mov    0x14(%ebp),%eax
  800b98:	8d 50 04             	lea    0x4(%eax),%edx
  800b9b:	89 55 14             	mov    %edx,0x14(%ebp)
  800b9e:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  800ba0:	85 db                	test   %ebx,%ebx
  800ba2:	79 02                	jns    800ba6 <vprintfmt+0x13e>
                err = -err;
  800ba4:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800ba6:	83 fb 18             	cmp    $0x18,%ebx
  800ba9:	7f 0b                	jg     800bb6 <vprintfmt+0x14e>
  800bab:	8b 34 9d 80 12 80 00 	mov    0x801280(,%ebx,4),%esi
  800bb2:	85 f6                	test   %esi,%esi
  800bb4:	75 23                	jne    800bd9 <vprintfmt+0x171>
                printfmt(putch, putdat, "error %d", err);
  800bb6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800bba:	c7 44 24 08 f5 12 80 	movl   $0x8012f5,0x8(%esp)
  800bc1:	00 
  800bc2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bc5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bcc:	89 04 24             	mov    %eax,(%esp)
  800bcf:	e8 61 fe ff ff       	call   800a35 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  800bd4:	e9 60 02 00 00       	jmp    800e39 <vprintfmt+0x3d1>
                printfmt(putch, putdat, "%s", p);
  800bd9:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800bdd:	c7 44 24 08 fe 12 80 	movl   $0x8012fe,0x8(%esp)
  800be4:	00 
  800be5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800be8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bec:	8b 45 08             	mov    0x8(%ebp),%eax
  800bef:	89 04 24             	mov    %eax,(%esp)
  800bf2:	e8 3e fe ff ff       	call   800a35 <printfmt>
            break;
  800bf7:	e9 3d 02 00 00       	jmp    800e39 <vprintfmt+0x3d1>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  800bfc:	8b 45 14             	mov    0x14(%ebp),%eax
  800bff:	8d 50 04             	lea    0x4(%eax),%edx
  800c02:	89 55 14             	mov    %edx,0x14(%ebp)
  800c05:	8b 30                	mov    (%eax),%esi
  800c07:	85 f6                	test   %esi,%esi
  800c09:	75 05                	jne    800c10 <vprintfmt+0x1a8>
                p = "(null)";
  800c0b:	be 01 13 80 00       	mov    $0x801301,%esi
            }
            if (width > 0 && padc != '-') {
  800c10:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800c14:	7e 76                	jle    800c8c <vprintfmt+0x224>
  800c16:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800c1a:	74 70                	je     800c8c <vprintfmt+0x224>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800c1c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c1f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c23:	89 34 24             	mov    %esi,(%esp)
  800c26:	e8 ba f7 ff ff       	call   8003e5 <strnlen>
  800c2b:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800c2e:	29 c2                	sub    %eax,%edx
  800c30:	89 d0                	mov    %edx,%eax
  800c32:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800c35:	eb 16                	jmp    800c4d <vprintfmt+0x1e5>
                    putch(padc, putdat);
  800c37:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800c3b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c3e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c42:	89 04 24             	mov    %eax,(%esp)
  800c45:	8b 45 08             	mov    0x8(%ebp),%eax
  800c48:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
  800c4a:	ff 4d e8             	decl   -0x18(%ebp)
  800c4d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800c51:	7f e4                	jg     800c37 <vprintfmt+0x1cf>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800c53:	eb 37                	jmp    800c8c <vprintfmt+0x224>
                if (altflag && (ch < ' ' || ch > '~')) {
  800c55:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800c59:	74 1f                	je     800c7a <vprintfmt+0x212>
  800c5b:	83 fb 1f             	cmp    $0x1f,%ebx
  800c5e:	7e 05                	jle    800c65 <vprintfmt+0x1fd>
  800c60:	83 fb 7e             	cmp    $0x7e,%ebx
  800c63:	7e 15                	jle    800c7a <vprintfmt+0x212>
                    putch('?', putdat);
  800c65:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c68:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c6c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800c73:	8b 45 08             	mov    0x8(%ebp),%eax
  800c76:	ff d0                	call   *%eax
  800c78:	eb 0f                	jmp    800c89 <vprintfmt+0x221>
                }
                else {
                    putch(ch, putdat);
  800c7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c7d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c81:	89 1c 24             	mov    %ebx,(%esp)
  800c84:	8b 45 08             	mov    0x8(%ebp),%eax
  800c87:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800c89:	ff 4d e8             	decl   -0x18(%ebp)
  800c8c:	89 f0                	mov    %esi,%eax
  800c8e:	8d 70 01             	lea    0x1(%eax),%esi
  800c91:	0f b6 00             	movzbl (%eax),%eax
  800c94:	0f be d8             	movsbl %al,%ebx
  800c97:	85 db                	test   %ebx,%ebx
  800c99:	74 27                	je     800cc2 <vprintfmt+0x25a>
  800c9b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800c9f:	78 b4                	js     800c55 <vprintfmt+0x1ed>
  800ca1:	ff 4d e4             	decl   -0x1c(%ebp)
  800ca4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ca8:	79 ab                	jns    800c55 <vprintfmt+0x1ed>
                }
            }
            for (; width > 0; width --) {
  800caa:	eb 16                	jmp    800cc2 <vprintfmt+0x25a>
                putch(' ', putdat);
  800cac:	8b 45 0c             	mov    0xc(%ebp),%eax
  800caf:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cb3:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800cba:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbd:	ff d0                	call   *%eax
            for (; width > 0; width --) {
  800cbf:	ff 4d e8             	decl   -0x18(%ebp)
  800cc2:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800cc6:	7f e4                	jg     800cac <vprintfmt+0x244>
            }
            break;
  800cc8:	e9 6c 01 00 00       	jmp    800e39 <vprintfmt+0x3d1>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  800ccd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800cd0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cd4:	8d 45 14             	lea    0x14(%ebp),%eax
  800cd7:	89 04 24             	mov    %eax,(%esp)
  800cda:	e8 0b fd ff ff       	call   8009ea <getint>
  800cdf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800ce2:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  800ce5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ce8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ceb:	85 d2                	test   %edx,%edx
  800ced:	79 26                	jns    800d15 <vprintfmt+0x2ad>
                putch('-', putdat);
  800cef:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cf2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cf6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800cfd:	8b 45 08             	mov    0x8(%ebp),%eax
  800d00:	ff d0                	call   *%eax
                num = -(long long)num;
  800d02:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d05:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d08:	f7 d8                	neg    %eax
  800d0a:	83 d2 00             	adc    $0x0,%edx
  800d0d:	f7 da                	neg    %edx
  800d0f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800d12:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  800d15:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  800d1c:	e9 a8 00 00 00       	jmp    800dc9 <vprintfmt+0x361>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  800d21:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800d24:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d28:	8d 45 14             	lea    0x14(%ebp),%eax
  800d2b:	89 04 24             	mov    %eax,(%esp)
  800d2e:	e8 64 fc ff ff       	call   800997 <getuint>
  800d33:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800d36:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  800d39:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  800d40:	e9 84 00 00 00       	jmp    800dc9 <vprintfmt+0x361>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  800d45:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800d48:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d4c:	8d 45 14             	lea    0x14(%ebp),%eax
  800d4f:	89 04 24             	mov    %eax,(%esp)
  800d52:	e8 40 fc ff ff       	call   800997 <getuint>
  800d57:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800d5a:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  800d5d:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  800d64:	eb 63                	jmp    800dc9 <vprintfmt+0x361>

        // pointer
        case 'p':
            putch('0', putdat);
  800d66:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d69:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d6d:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800d74:	8b 45 08             	mov    0x8(%ebp),%eax
  800d77:	ff d0                	call   *%eax
            putch('x', putdat);
  800d79:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d7c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d80:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800d87:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8a:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800d8c:	8b 45 14             	mov    0x14(%ebp),%eax
  800d8f:	8d 50 04             	lea    0x4(%eax),%edx
  800d92:	89 55 14             	mov    %edx,0x14(%ebp)
  800d95:	8b 00                	mov    (%eax),%eax
  800d97:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800d9a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  800da1:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  800da8:	eb 1f                	jmp    800dc9 <vprintfmt+0x361>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  800daa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800dad:	89 44 24 04          	mov    %eax,0x4(%esp)
  800db1:	8d 45 14             	lea    0x14(%ebp),%eax
  800db4:	89 04 24             	mov    %eax,(%esp)
  800db7:	e8 db fb ff ff       	call   800997 <getuint>
  800dbc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800dbf:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  800dc2:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  800dc9:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800dcd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800dd0:	89 54 24 18          	mov    %edx,0x18(%esp)
  800dd4:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800dd7:	89 54 24 14          	mov    %edx,0x14(%esp)
  800ddb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ddf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800de2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800de5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800de9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ded:	8b 45 0c             	mov    0xc(%ebp),%eax
  800df0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800df4:	8b 45 08             	mov    0x8(%ebp),%eax
  800df7:	89 04 24             	mov    %eax,(%esp)
  800dfa:	e8 94 fa ff ff       	call   800893 <printnum>
            break;
  800dff:	eb 38                	jmp    800e39 <vprintfmt+0x3d1>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  800e01:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e04:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e08:	89 1c 24             	mov    %ebx,(%esp)
  800e0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0e:	ff d0                	call   *%eax
            break;
  800e10:	eb 27                	jmp    800e39 <vprintfmt+0x3d1>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  800e12:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e15:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e19:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800e20:	8b 45 08             	mov    0x8(%ebp),%eax
  800e23:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  800e25:	ff 4d 10             	decl   0x10(%ebp)
  800e28:	eb 03                	jmp    800e2d <vprintfmt+0x3c5>
  800e2a:	ff 4d 10             	decl   0x10(%ebp)
  800e2d:	8b 45 10             	mov    0x10(%ebp),%eax
  800e30:	48                   	dec    %eax
  800e31:	0f b6 00             	movzbl (%eax),%eax
  800e34:	3c 25                	cmp    $0x25,%al
  800e36:	75 f2                	jne    800e2a <vprintfmt+0x3c2>
                /* do nothing */;
            break;
  800e38:	90                   	nop
    while (1) {
  800e39:	e9 36 fc ff ff       	jmp    800a74 <vprintfmt+0xc>
                return;
  800e3e:	90                   	nop
        }
    }
}
  800e3f:	83 c4 40             	add    $0x40,%esp
  800e42:	5b                   	pop    %ebx
  800e43:	5e                   	pop    %esi
  800e44:	5d                   	pop    %ebp
  800e45:	c3                   	ret    

00800e46 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  800e46:	f3 0f 1e fb          	endbr32 
  800e4a:	55                   	push   %ebp
  800e4b:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  800e4d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e50:	8b 40 08             	mov    0x8(%eax),%eax
  800e53:	8d 50 01             	lea    0x1(%eax),%edx
  800e56:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e59:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  800e5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e5f:	8b 10                	mov    (%eax),%edx
  800e61:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e64:	8b 40 04             	mov    0x4(%eax),%eax
  800e67:	39 c2                	cmp    %eax,%edx
  800e69:	73 12                	jae    800e7d <sprintputch+0x37>
        *b->buf ++ = ch;
  800e6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e6e:	8b 00                	mov    (%eax),%eax
  800e70:	8d 48 01             	lea    0x1(%eax),%ecx
  800e73:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e76:	89 0a                	mov    %ecx,(%edx)
  800e78:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7b:	88 10                	mov    %dl,(%eax)
    }
}
  800e7d:	90                   	nop
  800e7e:	5d                   	pop    %ebp
  800e7f:	c3                   	ret    

00800e80 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  800e80:	f3 0f 1e fb          	endbr32 
  800e84:	55                   	push   %ebp
  800e85:	89 e5                	mov    %esp,%ebp
  800e87:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  800e8a:	8d 45 14             	lea    0x14(%ebp),%eax
  800e8d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  800e90:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e93:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e97:	8b 45 10             	mov    0x10(%ebp),%eax
  800e9a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e9e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ea1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ea5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea8:	89 04 24             	mov    %eax,(%esp)
  800eab:	e8 08 00 00 00       	call   800eb8 <vsnprintf>
  800eb0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  800eb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800eb6:	c9                   	leave  
  800eb7:	c3                   	ret    

00800eb8 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  800eb8:	f3 0f 1e fb          	endbr32 
  800ebc:	55                   	push   %ebp
  800ebd:	89 e5                	mov    %esp,%ebp
  800ebf:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  800ec2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ec8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ecb:	8d 50 ff             	lea    -0x1(%eax),%edx
  800ece:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed1:	01 d0                	add    %edx,%eax
  800ed3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800ed6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  800edd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800ee1:	74 0a                	je     800eed <vsnprintf+0x35>
  800ee3:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800ee6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ee9:	39 c2                	cmp    %eax,%edx
  800eeb:	76 07                	jbe    800ef4 <vsnprintf+0x3c>
        return -E_INVAL;
  800eed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ef2:	eb 2a                	jmp    800f1e <vsnprintf+0x66>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ef4:	8b 45 14             	mov    0x14(%ebp),%eax
  800ef7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800efb:	8b 45 10             	mov    0x10(%ebp),%eax
  800efe:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f02:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800f05:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f09:	c7 04 24 46 0e 80 00 	movl   $0x800e46,(%esp)
  800f10:	e8 53 fb ff ff       	call   800a68 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  800f15:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f18:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  800f1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800f1e:	c9                   	leave  
  800f1f:	c3                   	ret    

00800f20 <hash32>:
 * @bits:   the number of bits in a return value
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
  800f20:	f3 0f 1e fb          	endbr32 
  800f24:	55                   	push   %ebp
  800f25:	89 e5                	mov    %esp,%ebp
  800f27:	83 ec 10             	sub    $0x10,%esp
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
  800f2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f2d:	69 c0 01 00 37 9e    	imul   $0x9e370001,%eax,%eax
  800f33:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (hash >> (32 - bits));
  800f36:	b8 20 00 00 00       	mov    $0x20,%eax
  800f3b:	2b 45 0c             	sub    0xc(%ebp),%eax
  800f3e:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800f41:	88 c1                	mov    %al,%cl
  800f43:	d3 ea                	shr    %cl,%edx
  800f45:	89 d0                	mov    %edx,%eax
}
  800f47:	c9                   	leave  
  800f48:	c3                   	ret    

00800f49 <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
  800f49:	f3 0f 1e fb          	endbr32 
  800f4d:	55                   	push   %ebp
  800f4e:	89 e5                	mov    %esp,%ebp
  800f50:	57                   	push   %edi
  800f51:	56                   	push   %esi
  800f52:	53                   	push   %ebx
  800f53:	83 ec 24             	sub    $0x24,%esp
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
  800f56:	a1 00 20 80 00       	mov    0x802000,%eax
  800f5b:	8b 15 04 20 80 00    	mov    0x802004,%edx
  800f61:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
  800f67:	6b f0 05             	imul   $0x5,%eax,%esi
  800f6a:	01 fe                	add    %edi,%esi
  800f6c:	bf 6d e6 ec de       	mov    $0xdeece66d,%edi
  800f71:	f7 e7                	mul    %edi
  800f73:	01 d6                	add    %edx,%esi
  800f75:	89 f2                	mov    %esi,%edx
  800f77:	83 c0 0b             	add    $0xb,%eax
  800f7a:	83 d2 00             	adc    $0x0,%edx
  800f7d:	89 c7                	mov    %eax,%edi
  800f7f:	83 e7 ff             	and    $0xffffffff,%edi
  800f82:	89 f9                	mov    %edi,%ecx
  800f84:	0f b7 da             	movzwl %dx,%ebx
  800f87:	89 0d 00 20 80 00    	mov    %ecx,0x802000
  800f8d:	89 1d 04 20 80 00    	mov    %ebx,0x802004
    unsigned long long result = (next >> 12);
  800f93:	a1 00 20 80 00       	mov    0x802000,%eax
  800f98:	8b 15 04 20 80 00    	mov    0x802004,%edx
  800f9e:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  800fa2:	c1 ea 0c             	shr    $0xc,%edx
  800fa5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800fa8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
  800fab:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
  800fb2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fb5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800fb8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800fbb:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800fbe:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800fc1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800fc4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800fc8:	74 1c                	je     800fe6 <rand+0x9d>
  800fca:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800fcd:	ba 00 00 00 00       	mov    $0x0,%edx
  800fd2:	f7 75 dc             	divl   -0x24(%ebp)
  800fd5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800fd8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800fdb:	ba 00 00 00 00       	mov    $0x0,%edx
  800fe0:	f7 75 dc             	divl   -0x24(%ebp)
  800fe3:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800fe6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800fe9:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800fec:	f7 75 dc             	divl   -0x24(%ebp)
  800fef:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ff2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800ff5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800ff8:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800ffb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800ffe:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801001:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
  801004:	83 c4 24             	add    $0x24,%esp
  801007:	5b                   	pop    %ebx
  801008:	5e                   	pop    %esi
  801009:	5f                   	pop    %edi
  80100a:	5d                   	pop    %ebp
  80100b:	c3                   	ret    

0080100c <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
  80100c:	f3 0f 1e fb          	endbr32 
  801010:	55                   	push   %ebp
  801011:	89 e5                	mov    %esp,%ebp
    next = seed;
  801013:	8b 45 08             	mov    0x8(%ebp),%eax
  801016:	ba 00 00 00 00       	mov    $0x0,%edx
  80101b:	a3 00 20 80 00       	mov    %eax,0x802000
  801020:	89 15 04 20 80 00    	mov    %edx,0x802004
}
  801026:	90                   	nop
  801027:	5d                   	pop    %ebp
  801028:	c3                   	ret    

00801029 <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
  801029:	f3 0f 1e fb          	endbr32 
  80102d:	55                   	push   %ebp
  80102e:	89 e5                	mov    %esp,%ebp
  801030:	83 e4 f0             	and    $0xfffffff0,%esp
  801033:	83 ec 20             	sub    $0x20,%esp
    int pid, exit_code;
    if ((pid = fork()) == 0) {
  801036:	e8 df f1 ff ff       	call   80021a <fork>
  80103b:	89 44 24 18          	mov    %eax,0x18(%esp)
  80103f:	83 7c 24 18 00       	cmpl   $0x0,0x18(%esp)
  801044:	75 32                	jne    801078 <main+0x4f>
        cprintf("fork ok.\n");
  801046:	c7 04 24 60 14 80 00 	movl   $0x801460,(%esp)
  80104d:	e8 ce f2 ff ff       	call   800320 <cprintf>
        int i;
        for (i = 0; i < 10; i ++) {
  801052:	c7 44 24 1c 00 00 00 	movl   $0x0,0x1c(%esp)
  801059:	00 
  80105a:	eb 09                	jmp    801065 <main+0x3c>
            yield();
  80105c:	e8 08 f2 ff ff       	call   800269 <yield>
        for (i = 0; i < 10; i ++) {
  801061:	ff 44 24 1c          	incl   0x1c(%esp)
  801065:	83 7c 24 1c 09       	cmpl   $0x9,0x1c(%esp)
  80106a:	7e f0                	jle    80105c <main+0x33>
        }
        exit(0xbeaf);
  80106c:	c7 04 24 af be 00 00 	movl   $0xbeaf,(%esp)
  801073:	e8 7f f1 ff ff       	call   8001f7 <exit>
    }
    assert(pid > 0);
  801078:	83 7c 24 18 00       	cmpl   $0x0,0x18(%esp)
  80107d:	7f 24                	jg     8010a3 <main+0x7a>
  80107f:	c7 44 24 0c 6a 14 80 	movl   $0x80146a,0xc(%esp)
  801086:	00 
  801087:	c7 44 24 08 72 14 80 	movl   $0x801472,0x8(%esp)
  80108e:	00 
  80108f:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  801096:	00 
  801097:	c7 04 24 87 14 80 00 	movl   $0x801487,(%esp)
  80109e:	e8 7d ef ff ff       	call   800020 <__panic>
    assert(waitpid(-1, NULL) != 0);
  8010a3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010aa:	00 
  8010ab:	c7 04 24 ff ff ff ff 	movl   $0xffffffff,(%esp)
  8010b2:	e8 94 f1 ff ff       	call   80024b <waitpid>
  8010b7:	85 c0                	test   %eax,%eax
  8010b9:	75 24                	jne    8010df <main+0xb6>
  8010bb:	c7 44 24 0c 95 14 80 	movl   $0x801495,0xc(%esp)
  8010c2:	00 
  8010c3:	c7 44 24 08 72 14 80 	movl   $0x801472,0x8(%esp)
  8010ca:	00 
  8010cb:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  8010d2:	00 
  8010d3:	c7 04 24 87 14 80 00 	movl   $0x801487,(%esp)
  8010da:	e8 41 ef ff ff       	call   800020 <__panic>
    assert(waitpid(pid, (void *)0xC0000000) != 0);
  8010df:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
  8010e6:	c0 
  8010e7:	8b 44 24 18          	mov    0x18(%esp),%eax
  8010eb:	89 04 24             	mov    %eax,(%esp)
  8010ee:	e8 58 f1 ff ff       	call   80024b <waitpid>
  8010f3:	85 c0                	test   %eax,%eax
  8010f5:	75 24                	jne    80111b <main+0xf2>
  8010f7:	c7 44 24 0c ac 14 80 	movl   $0x8014ac,0xc(%esp)
  8010fe:	00 
  8010ff:	c7 44 24 08 72 14 80 	movl   $0x801472,0x8(%esp)
  801106:	00 
  801107:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  80110e:	00 
  80110f:	c7 04 24 87 14 80 00 	movl   $0x801487,(%esp)
  801116:	e8 05 ef ff ff       	call   800020 <__panic>
    assert(waitpid(pid, &exit_code) == 0 && exit_code == 0xbeaf);
  80111b:	8d 44 24 14          	lea    0x14(%esp),%eax
  80111f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801123:	8b 44 24 18          	mov    0x18(%esp),%eax
  801127:	89 04 24             	mov    %eax,(%esp)
  80112a:	e8 1c f1 ff ff       	call   80024b <waitpid>
  80112f:	85 c0                	test   %eax,%eax
  801131:	75 0b                	jne    80113e <main+0x115>
  801133:	8b 44 24 14          	mov    0x14(%esp),%eax
  801137:	3d af be 00 00       	cmp    $0xbeaf,%eax
  80113c:	74 24                	je     801162 <main+0x139>
  80113e:	c7 44 24 0c d4 14 80 	movl   $0x8014d4,0xc(%esp)
  801145:	00 
  801146:	c7 44 24 08 72 14 80 	movl   $0x801472,0x8(%esp)
  80114d:	00 
  80114e:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  801155:	00 
  801156:	c7 04 24 87 14 80 00 	movl   $0x801487,(%esp)
  80115d:	e8 be ee ff ff       	call   800020 <__panic>
    cprintf("badarg pass.\n");
  801162:	c7 04 24 09 15 80 00 	movl   $0x801509,(%esp)
  801169:	e8 b2 f1 ff ff       	call   800320 <cprintf>
    return 0;
  80116e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801173:	c9                   	leave  
  801174:	c3                   	ret    
