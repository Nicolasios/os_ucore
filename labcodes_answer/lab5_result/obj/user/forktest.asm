
obj/__user_forktest.out：     文件格式 elf32-i386


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
  800027:	83 ec 18             	sub    $0x18,%esp
    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  80002a:	8d 45 14             	lea    0x14(%ebp),%eax
  80002d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("user panic at %s:%d:\n    ", file, line);
  800030:	83 ec 04             	sub    $0x4,%esp
  800033:	ff 75 0c             	pushl  0xc(%ebp)
  800036:	ff 75 08             	pushl  0x8(%ebp)
  800039:	68 a0 10 80 00       	push   $0x8010a0
  80003e:	e8 9d 02 00 00       	call   8002e0 <cprintf>
  800043:	83 c4 10             	add    $0x10,%esp
    vcprintf(fmt, ap);
  800046:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800049:	83 ec 08             	sub    $0x8,%esp
  80004c:	50                   	push   %eax
  80004d:	ff 75 10             	pushl  0x10(%ebp)
  800050:	e8 5e 02 00 00       	call   8002b3 <vcprintf>
  800055:	83 c4 10             	add    $0x10,%esp
    cprintf("\n");
  800058:	83 ec 0c             	sub    $0xc,%esp
  80005b:	68 ba 10 80 00       	push   $0x8010ba
  800060:	e8 7b 02 00 00       	call   8002e0 <cprintf>
  800065:	83 c4 10             	add    $0x10,%esp
    va_end(ap);
    exit(-E_PANIC);
  800068:	83 ec 0c             	sub    $0xc,%esp
  80006b:	6a f6                	push   $0xfffffff6
  80006d:	e8 48 01 00 00       	call   8001ba <exit>

00800072 <__warn>:
}

void
__warn(const char *file, int line, const char *fmt, ...) {
  800072:	f3 0f 1e fb          	endbr32 
  800076:	55                   	push   %ebp
  800077:	89 e5                	mov    %esp,%ebp
  800079:	83 ec 18             	sub    $0x18,%esp
    va_list ap;
    va_start(ap, fmt);
  80007c:	8d 45 14             	lea    0x14(%ebp),%eax
  80007f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("user warning at %s:%d:\n    ", file, line);
  800082:	83 ec 04             	sub    $0x4,%esp
  800085:	ff 75 0c             	pushl  0xc(%ebp)
  800088:	ff 75 08             	pushl  0x8(%ebp)
  80008b:	68 bc 10 80 00       	push   $0x8010bc
  800090:	e8 4b 02 00 00       	call   8002e0 <cprintf>
  800095:	83 c4 10             	add    $0x10,%esp
    vcprintf(fmt, ap);
  800098:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80009b:	83 ec 08             	sub    $0x8,%esp
  80009e:	50                   	push   %eax
  80009f:	ff 75 10             	pushl  0x10(%ebp)
  8000a2:	e8 0c 02 00 00       	call   8002b3 <vcprintf>
  8000a7:	83 c4 10             	add    $0x10,%esp
    cprintf("\n");
  8000aa:	83 ec 0c             	sub    $0xc,%esp
  8000ad:	68 ba 10 80 00       	push   $0x8010ba
  8000b2:	e8 29 02 00 00       	call   8002e0 <cprintf>
  8000b7:	83 c4 10             	add    $0x10,%esp
    va_end(ap);
}
  8000ba:	90                   	nop
  8000bb:	c9                   	leave  
  8000bc:	c3                   	ret    

008000bd <syscall>:
#include <syscall.h>

#define MAX_ARGS            5

static inline int
syscall(int num, ...) {
  8000bd:	55                   	push   %ebp
  8000be:	89 e5                	mov    %esp,%ebp
  8000c0:	57                   	push   %edi
  8000c1:	56                   	push   %esi
  8000c2:	53                   	push   %ebx
  8000c3:	83 ec 20             	sub    $0x20,%esp
    va_list ap;
    va_start(ap, num);
  8000c6:	8d 45 0c             	lea    0xc(%ebp),%eax
  8000c9:	89 45 e8             	mov    %eax,-0x18(%ebp)
    uint32_t a[MAX_ARGS];
    int i, ret;
    for (i = 0; i < MAX_ARGS; i ++) {
  8000cc:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8000d3:	eb 16                	jmp    8000eb <syscall+0x2e>
        a[i] = va_arg(ap, uint32_t);
  8000d5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8000d8:	8d 50 04             	lea    0x4(%eax),%edx
  8000db:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8000de:	8b 10                	mov    (%eax),%edx
  8000e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8000e3:	89 54 85 d4          	mov    %edx,-0x2c(%ebp,%eax,4)
    for (i = 0; i < MAX_ARGS; i ++) {
  8000e7:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  8000eb:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
  8000ef:	7e e4                	jle    8000d5 <syscall+0x18>
    asm volatile (
        "int %1;"
        : "=a" (ret)
        : "i" (T_SYSCALL),
          "a" (num),
          "d" (a[0]),
  8000f1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
          "c" (a[1]),
  8000f4:	8b 4d d8             	mov    -0x28(%ebp),%ecx
          "b" (a[2]),
  8000f7:	8b 5d dc             	mov    -0x24(%ebp),%ebx
          "D" (a[3]),
  8000fa:	8b 7d e0             	mov    -0x20(%ebp),%edi
          "S" (a[4])
  8000fd:	8b 75 e4             	mov    -0x1c(%ebp),%esi
    asm volatile (
  800100:	8b 45 08             	mov    0x8(%ebp),%eax
  800103:	cd 80                	int    $0x80
  800105:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "cc", "memory");
    return ret;
  800108:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
  80010b:	83 c4 20             	add    $0x20,%esp
  80010e:	5b                   	pop    %ebx
  80010f:	5e                   	pop    %esi
  800110:	5f                   	pop    %edi
  800111:	5d                   	pop    %ebp
  800112:	c3                   	ret    

00800113 <sys_exit>:

int
sys_exit(int error_code) {
  800113:	f3 0f 1e fb          	endbr32 
  800117:	55                   	push   %ebp
  800118:	89 e5                	mov    %esp,%ebp
    return syscall(SYS_exit, error_code);
  80011a:	ff 75 08             	pushl  0x8(%ebp)
  80011d:	6a 01                	push   $0x1
  80011f:	e8 99 ff ff ff       	call   8000bd <syscall>
  800124:	83 c4 08             	add    $0x8,%esp
}
  800127:	c9                   	leave  
  800128:	c3                   	ret    

00800129 <sys_fork>:

int
sys_fork(void) {
  800129:	f3 0f 1e fb          	endbr32 
  80012d:	55                   	push   %ebp
  80012e:	89 e5                	mov    %esp,%ebp
    return syscall(SYS_fork);
  800130:	6a 02                	push   $0x2
  800132:	e8 86 ff ff ff       	call   8000bd <syscall>
  800137:	83 c4 04             	add    $0x4,%esp
}
  80013a:	c9                   	leave  
  80013b:	c3                   	ret    

0080013c <sys_wait>:

int
sys_wait(int pid, int *store) {
  80013c:	f3 0f 1e fb          	endbr32 
  800140:	55                   	push   %ebp
  800141:	89 e5                	mov    %esp,%ebp
    return syscall(SYS_wait, pid, store);
  800143:	ff 75 0c             	pushl  0xc(%ebp)
  800146:	ff 75 08             	pushl  0x8(%ebp)
  800149:	6a 03                	push   $0x3
  80014b:	e8 6d ff ff ff       	call   8000bd <syscall>
  800150:	83 c4 0c             	add    $0xc,%esp
}
  800153:	c9                   	leave  
  800154:	c3                   	ret    

00800155 <sys_yield>:

int
sys_yield(void) {
  800155:	f3 0f 1e fb          	endbr32 
  800159:	55                   	push   %ebp
  80015a:	89 e5                	mov    %esp,%ebp
    return syscall(SYS_yield);
  80015c:	6a 0a                	push   $0xa
  80015e:	e8 5a ff ff ff       	call   8000bd <syscall>
  800163:	83 c4 04             	add    $0x4,%esp
}
  800166:	c9                   	leave  
  800167:	c3                   	ret    

00800168 <sys_kill>:

int
sys_kill(int pid) {
  800168:	f3 0f 1e fb          	endbr32 
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
    return syscall(SYS_kill, pid);
  80016f:	ff 75 08             	pushl  0x8(%ebp)
  800172:	6a 0c                	push   $0xc
  800174:	e8 44 ff ff ff       	call   8000bd <syscall>
  800179:	83 c4 08             	add    $0x8,%esp
}
  80017c:	c9                   	leave  
  80017d:	c3                   	ret    

0080017e <sys_getpid>:

int
sys_getpid(void) {
  80017e:	f3 0f 1e fb          	endbr32 
  800182:	55                   	push   %ebp
  800183:	89 e5                	mov    %esp,%ebp
    return syscall(SYS_getpid);
  800185:	6a 12                	push   $0x12
  800187:	e8 31 ff ff ff       	call   8000bd <syscall>
  80018c:	83 c4 04             	add    $0x4,%esp
}
  80018f:	c9                   	leave  
  800190:	c3                   	ret    

00800191 <sys_putc>:

int
sys_putc(int c) {
  800191:	f3 0f 1e fb          	endbr32 
  800195:	55                   	push   %ebp
  800196:	89 e5                	mov    %esp,%ebp
    return syscall(SYS_putc, c);
  800198:	ff 75 08             	pushl  0x8(%ebp)
  80019b:	6a 1e                	push   $0x1e
  80019d:	e8 1b ff ff ff       	call   8000bd <syscall>
  8001a2:	83 c4 08             	add    $0x8,%esp
}
  8001a5:	c9                   	leave  
  8001a6:	c3                   	ret    

008001a7 <sys_pgdir>:

int
sys_pgdir(void) {
  8001a7:	f3 0f 1e fb          	endbr32 
  8001ab:	55                   	push   %ebp
  8001ac:	89 e5                	mov    %esp,%ebp
    return syscall(SYS_pgdir);
  8001ae:	6a 1f                	push   $0x1f
  8001b0:	e8 08 ff ff ff       	call   8000bd <syscall>
  8001b5:	83 c4 04             	add    $0x4,%esp
}
  8001b8:	c9                   	leave  
  8001b9:	c3                   	ret    

008001ba <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8001ba:	f3 0f 1e fb          	endbr32 
  8001be:	55                   	push   %ebp
  8001bf:	89 e5                	mov    %esp,%ebp
  8001c1:	83 ec 08             	sub    $0x8,%esp
    sys_exit(error_code);
  8001c4:	83 ec 0c             	sub    $0xc,%esp
  8001c7:	ff 75 08             	pushl  0x8(%ebp)
  8001ca:	e8 44 ff ff ff       	call   800113 <sys_exit>
  8001cf:	83 c4 10             	add    $0x10,%esp
    cprintf("BUG: exit failed.\n");
  8001d2:	83 ec 0c             	sub    $0xc,%esp
  8001d5:	68 d8 10 80 00       	push   $0x8010d8
  8001da:	e8 01 01 00 00       	call   8002e0 <cprintf>
  8001df:	83 c4 10             	add    $0x10,%esp
    while (1);
  8001e2:	eb fe                	jmp    8001e2 <exit+0x28>

008001e4 <fork>:
}

int
fork(void) {
  8001e4:	f3 0f 1e fb          	endbr32 
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	83 ec 08             	sub    $0x8,%esp
    return sys_fork();
  8001ee:	e8 36 ff ff ff       	call   800129 <sys_fork>
}
  8001f3:	c9                   	leave  
  8001f4:	c3                   	ret    

008001f5 <wait>:

int
wait(void) {
  8001f5:	f3 0f 1e fb          	endbr32 
  8001f9:	55                   	push   %ebp
  8001fa:	89 e5                	mov    %esp,%ebp
  8001fc:	83 ec 08             	sub    $0x8,%esp
    return sys_wait(0, NULL);
  8001ff:	83 ec 08             	sub    $0x8,%esp
  800202:	6a 00                	push   $0x0
  800204:	6a 00                	push   $0x0
  800206:	e8 31 ff ff ff       	call   80013c <sys_wait>
  80020b:	83 c4 10             	add    $0x10,%esp
}
  80020e:	c9                   	leave  
  80020f:	c3                   	ret    

00800210 <waitpid>:

int
waitpid(int pid, int *store) {
  800210:	f3 0f 1e fb          	endbr32 
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	83 ec 08             	sub    $0x8,%esp
    return sys_wait(pid, store);
  80021a:	83 ec 08             	sub    $0x8,%esp
  80021d:	ff 75 0c             	pushl  0xc(%ebp)
  800220:	ff 75 08             	pushl  0x8(%ebp)
  800223:	e8 14 ff ff ff       	call   80013c <sys_wait>
  800228:	83 c4 10             	add    $0x10,%esp
}
  80022b:	c9                   	leave  
  80022c:	c3                   	ret    

0080022d <yield>:

void
yield(void) {
  80022d:	f3 0f 1e fb          	endbr32 
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
  800234:	83 ec 08             	sub    $0x8,%esp
    sys_yield();
  800237:	e8 19 ff ff ff       	call   800155 <sys_yield>
}
  80023c:	90                   	nop
  80023d:	c9                   	leave  
  80023e:	c3                   	ret    

0080023f <kill>:

int
kill(int pid) {
  80023f:	f3 0f 1e fb          	endbr32 
  800243:	55                   	push   %ebp
  800244:	89 e5                	mov    %esp,%ebp
  800246:	83 ec 08             	sub    $0x8,%esp
    return sys_kill(pid);
  800249:	83 ec 0c             	sub    $0xc,%esp
  80024c:	ff 75 08             	pushl  0x8(%ebp)
  80024f:	e8 14 ff ff ff       	call   800168 <sys_kill>
  800254:	83 c4 10             	add    $0x10,%esp
}
  800257:	c9                   	leave  
  800258:	c3                   	ret    

00800259 <getpid>:

int
getpid(void) {
  800259:	f3 0f 1e fb          	endbr32 
  80025d:	55                   	push   %ebp
  80025e:	89 e5                	mov    %esp,%ebp
  800260:	83 ec 08             	sub    $0x8,%esp
    return sys_getpid();
  800263:	e8 16 ff ff ff       	call   80017e <sys_getpid>
}
  800268:	c9                   	leave  
  800269:	c3                   	ret    

0080026a <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
  80026a:	f3 0f 1e fb          	endbr32 
  80026e:	55                   	push   %ebp
  80026f:	89 e5                	mov    %esp,%ebp
  800271:	83 ec 08             	sub    $0x8,%esp
    sys_pgdir();
  800274:	e8 2e ff ff ff       	call   8001a7 <sys_pgdir>
}
  800279:	90                   	nop
  80027a:	c9                   	leave  
  80027b:	c3                   	ret    

0080027c <_start>:
.text
.globl _start
_start:
    # set ebp for backtrace
    movl $0x0, %ebp
  80027c:	bd 00 00 00 00       	mov    $0x0,%ebp

    # move down the esp register
    # since it may cause page fault in backtrace
    subl $0x20, %esp
  800281:	83 ec 20             	sub    $0x20,%esp

    # call user-program function
    call umain
  800284:	e8 d3 00 00 00       	call   80035c <umain>
1:  jmp 1b
  800289:	eb fe                	jmp    800289 <_start+0xd>

0080028b <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  80028b:	f3 0f 1e fb          	endbr32 
  80028f:	55                   	push   %ebp
  800290:	89 e5                	mov    %esp,%ebp
  800292:	83 ec 08             	sub    $0x8,%esp
    sys_putc(c);
  800295:	83 ec 0c             	sub    $0xc,%esp
  800298:	ff 75 08             	pushl  0x8(%ebp)
  80029b:	e8 f1 fe ff ff       	call   800191 <sys_putc>
  8002a0:	83 c4 10             	add    $0x10,%esp
    (*cnt) ++;
  8002a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002a6:	8b 00                	mov    (%eax),%eax
  8002a8:	8d 50 01             	lea    0x1(%eax),%edx
  8002ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002ae:	89 10                	mov    %edx,(%eax)
}
  8002b0:	90                   	nop
  8002b1:	c9                   	leave  
  8002b2:	c3                   	ret    

008002b3 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  8002b3:	f3 0f 1e fb          	endbr32 
  8002b7:	55                   	push   %ebp
  8002b8:	89 e5                	mov    %esp,%ebp
  8002ba:	83 ec 18             	sub    $0x18,%esp
    int cnt = 0;
  8002bd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8002c4:	ff 75 0c             	pushl  0xc(%ebp)
  8002c7:	ff 75 08             	pushl  0x8(%ebp)
  8002ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8002cd:	50                   	push   %eax
  8002ce:	68 8b 02 80 00       	push   $0x80028b
  8002d3:	e8 43 07 00 00       	call   800a1b <vprintfmt>
  8002d8:	83 c4 10             	add    $0x10,%esp
    return cnt;
  8002db:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8002de:	c9                   	leave  
  8002df:	c3                   	ret    

008002e0 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  8002e0:	f3 0f 1e fb          	endbr32 
  8002e4:	55                   	push   %ebp
  8002e5:	89 e5                	mov    %esp,%ebp
  8002e7:	83 ec 18             	sub    $0x18,%esp
    va_list ap;

    va_start(ap, fmt);
  8002ea:	8d 45 0c             	lea    0xc(%ebp),%eax
  8002ed:	89 45 f0             	mov    %eax,-0x10(%ebp)
    int cnt = vcprintf(fmt, ap);
  8002f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8002f3:	83 ec 08             	sub    $0x8,%esp
  8002f6:	50                   	push   %eax
  8002f7:	ff 75 08             	pushl  0x8(%ebp)
  8002fa:	e8 b4 ff ff ff       	call   8002b3 <vcprintf>
  8002ff:	83 c4 10             	add    $0x10,%esp
  800302:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);

    return cnt;
  800305:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800308:	c9                   	leave  
  800309:	c3                   	ret    

0080030a <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  80030a:	f3 0f 1e fb          	endbr32 
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	83 ec 18             	sub    $0x18,%esp
    int cnt = 0;
  800314:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  80031b:	eb 14                	jmp    800331 <cputs+0x27>
        cputch(c, &cnt);
  80031d:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  800321:	83 ec 08             	sub    $0x8,%esp
  800324:	8d 55 f0             	lea    -0x10(%ebp),%edx
  800327:	52                   	push   %edx
  800328:	50                   	push   %eax
  800329:	e8 5d ff ff ff       	call   80028b <cputch>
  80032e:	83 c4 10             	add    $0x10,%esp
    while ((c = *str ++) != '\0') {
  800331:	8b 45 08             	mov    0x8(%ebp),%eax
  800334:	8d 50 01             	lea    0x1(%eax),%edx
  800337:	89 55 08             	mov    %edx,0x8(%ebp)
  80033a:	0f b6 00             	movzbl (%eax),%eax
  80033d:	88 45 f7             	mov    %al,-0x9(%ebp)
  800340:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  800344:	75 d7                	jne    80031d <cputs+0x13>
    }
    cputch('\n', &cnt);
  800346:	83 ec 08             	sub    $0x8,%esp
  800349:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80034c:	50                   	push   %eax
  80034d:	6a 0a                	push   $0xa
  80034f:	e8 37 ff ff ff       	call   80028b <cputch>
  800354:	83 c4 10             	add    $0x10,%esp
    return cnt;
  800357:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  80035a:	c9                   	leave  
  80035b:	c3                   	ret    

0080035c <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  80035c:	f3 0f 1e fb          	endbr32 
  800360:	55                   	push   %ebp
  800361:	89 e5                	mov    %esp,%ebp
  800363:	83 ec 18             	sub    $0x18,%esp
    int ret = main();
  800366:	e8 2b 0c 00 00       	call   800f96 <main>
  80036b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    exit(ret);
  80036e:	83 ec 0c             	sub    $0xc,%esp
  800371:	ff 75 f4             	pushl  -0xc(%ebp)
  800374:	e8 41 fe ff ff       	call   8001ba <exit>

00800379 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  800379:	f3 0f 1e fb          	endbr32 
  80037d:	55                   	push   %ebp
  80037e:	89 e5                	mov    %esp,%ebp
  800380:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  800383:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  80038a:	eb 04                	jmp    800390 <strlen+0x17>
        cnt ++;
  80038c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    while (*s ++ != '\0') {
  800390:	8b 45 08             	mov    0x8(%ebp),%eax
  800393:	8d 50 01             	lea    0x1(%eax),%edx
  800396:	89 55 08             	mov    %edx,0x8(%ebp)
  800399:	0f b6 00             	movzbl (%eax),%eax
  80039c:	84 c0                	test   %al,%al
  80039e:	75 ec                	jne    80038c <strlen+0x13>
    }
    return cnt;
  8003a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8003a3:	c9                   	leave  
  8003a4:	c3                   	ret    

008003a5 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  8003a5:	f3 0f 1e fb          	endbr32 
  8003a9:	55                   	push   %ebp
  8003aa:	89 e5                	mov    %esp,%ebp
  8003ac:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  8003af:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  8003b6:	eb 04                	jmp    8003bc <strnlen+0x17>
        cnt ++;
  8003b8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  8003bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8003bf:	3b 45 0c             	cmp    0xc(%ebp),%eax
  8003c2:	73 10                	jae    8003d4 <strnlen+0x2f>
  8003c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c7:	8d 50 01             	lea    0x1(%eax),%edx
  8003ca:	89 55 08             	mov    %edx,0x8(%ebp)
  8003cd:	0f b6 00             	movzbl (%eax),%eax
  8003d0:	84 c0                	test   %al,%al
  8003d2:	75 e4                	jne    8003b8 <strnlen+0x13>
    }
    return cnt;
  8003d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8003d7:	c9                   	leave  
  8003d8:	c3                   	ret    

008003d9 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  8003d9:	f3 0f 1e fb          	endbr32 
  8003dd:	55                   	push   %ebp
  8003de:	89 e5                	mov    %esp,%ebp
  8003e0:	57                   	push   %edi
  8003e1:	56                   	push   %esi
  8003e2:	83 ec 20             	sub    $0x20,%esp
  8003e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8003eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003ee:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  8003f1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8003f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8003f7:	89 d1                	mov    %edx,%ecx
  8003f9:	89 c2                	mov    %eax,%edx
  8003fb:	89 ce                	mov    %ecx,%esi
  8003fd:	89 d7                	mov    %edx,%edi
  8003ff:	ac                   	lods   %ds:(%esi),%al
  800400:	aa                   	stos   %al,%es:(%edi)
  800401:	84 c0                	test   %al,%al
  800403:	75 fa                	jne    8003ff <strcpy+0x26>
  800405:	89 fa                	mov    %edi,%edx
  800407:	89 f1                	mov    %esi,%ecx
  800409:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  80040c:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80040f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
  800412:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  800415:	83 c4 20             	add    $0x20,%esp
  800418:	5e                   	pop    %esi
  800419:	5f                   	pop    %edi
  80041a:	5d                   	pop    %ebp
  80041b:	c3                   	ret    

0080041c <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  80041c:	f3 0f 1e fb          	endbr32 
  800420:	55                   	push   %ebp
  800421:	89 e5                	mov    %esp,%ebp
  800423:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  800426:	8b 45 08             	mov    0x8(%ebp),%eax
  800429:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  80042c:	eb 21                	jmp    80044f <strncpy+0x33>
        if ((*p = *src) != '\0') {
  80042e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800431:	0f b6 10             	movzbl (%eax),%edx
  800434:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800437:	88 10                	mov    %dl,(%eax)
  800439:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80043c:	0f b6 00             	movzbl (%eax),%eax
  80043f:	84 c0                	test   %al,%al
  800441:	74 04                	je     800447 <strncpy+0x2b>
            src ++;
  800443:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
  800447:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  80044b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    while (len > 0) {
  80044f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800453:	75 d9                	jne    80042e <strncpy+0x12>
    }
    return dst;
  800455:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800458:	c9                   	leave  
  800459:	c3                   	ret    

0080045a <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  80045a:	f3 0f 1e fb          	endbr32 
  80045e:	55                   	push   %ebp
  80045f:	89 e5                	mov    %esp,%ebp
  800461:	57                   	push   %edi
  800462:	56                   	push   %esi
  800463:	83 ec 20             	sub    $0x20,%esp
  800466:	8b 45 08             	mov    0x8(%ebp),%eax
  800469:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80046c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80046f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
  800472:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800475:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800478:	89 d1                	mov    %edx,%ecx
  80047a:	89 c2                	mov    %eax,%edx
  80047c:	89 ce                	mov    %ecx,%esi
  80047e:	89 d7                	mov    %edx,%edi
  800480:	ac                   	lods   %ds:(%esi),%al
  800481:	ae                   	scas   %es:(%edi),%al
  800482:	75 08                	jne    80048c <strcmp+0x32>
  800484:	84 c0                	test   %al,%al
  800486:	75 f8                	jne    800480 <strcmp+0x26>
  800488:	31 c0                	xor    %eax,%eax
  80048a:	eb 04                	jmp    800490 <strcmp+0x36>
  80048c:	19 c0                	sbb    %eax,%eax
  80048e:	0c 01                	or     $0x1,%al
  800490:	89 fa                	mov    %edi,%edx
  800492:	89 f1                	mov    %esi,%ecx
  800494:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800497:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  80049a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
  80049d:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  8004a0:	83 c4 20             	add    $0x20,%esp
  8004a3:	5e                   	pop    %esi
  8004a4:	5f                   	pop    %edi
  8004a5:	5d                   	pop    %ebp
  8004a6:	c3                   	ret    

008004a7 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  8004a7:	f3 0f 1e fb          	endbr32 
  8004ab:	55                   	push   %ebp
  8004ac:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  8004ae:	eb 0c                	jmp    8004bc <strncmp+0x15>
        n --, s1 ++, s2 ++;
  8004b0:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8004b4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8004b8:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  8004bc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8004c0:	74 1a                	je     8004dc <strncmp+0x35>
  8004c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c5:	0f b6 00             	movzbl (%eax),%eax
  8004c8:	84 c0                	test   %al,%al
  8004ca:	74 10                	je     8004dc <strncmp+0x35>
  8004cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8004cf:	0f b6 10             	movzbl (%eax),%edx
  8004d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004d5:	0f b6 00             	movzbl (%eax),%eax
  8004d8:	38 c2                	cmp    %al,%dl
  8004da:	74 d4                	je     8004b0 <strncmp+0x9>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  8004dc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8004e0:	74 18                	je     8004fa <strncmp+0x53>
  8004e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e5:	0f b6 00             	movzbl (%eax),%eax
  8004e8:	0f b6 d0             	movzbl %al,%edx
  8004eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004ee:	0f b6 00             	movzbl (%eax),%eax
  8004f1:	0f b6 c0             	movzbl %al,%eax
  8004f4:	29 c2                	sub    %eax,%edx
  8004f6:	89 d0                	mov    %edx,%eax
  8004f8:	eb 05                	jmp    8004ff <strncmp+0x58>
  8004fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8004ff:	5d                   	pop    %ebp
  800500:	c3                   	ret    

00800501 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  800501:	f3 0f 1e fb          	endbr32 
  800505:	55                   	push   %ebp
  800506:	89 e5                	mov    %esp,%ebp
  800508:	83 ec 04             	sub    $0x4,%esp
  80050b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80050e:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  800511:	eb 14                	jmp    800527 <strchr+0x26>
        if (*s == c) {
  800513:	8b 45 08             	mov    0x8(%ebp),%eax
  800516:	0f b6 00             	movzbl (%eax),%eax
  800519:	38 45 fc             	cmp    %al,-0x4(%ebp)
  80051c:	75 05                	jne    800523 <strchr+0x22>
            return (char *)s;
  80051e:	8b 45 08             	mov    0x8(%ebp),%eax
  800521:	eb 13                	jmp    800536 <strchr+0x35>
        }
        s ++;
  800523:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s != '\0') {
  800527:	8b 45 08             	mov    0x8(%ebp),%eax
  80052a:	0f b6 00             	movzbl (%eax),%eax
  80052d:	84 c0                	test   %al,%al
  80052f:	75 e2                	jne    800513 <strchr+0x12>
    }
    return NULL;
  800531:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800536:	c9                   	leave  
  800537:	c3                   	ret    

00800538 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  800538:	f3 0f 1e fb          	endbr32 
  80053c:	55                   	push   %ebp
  80053d:	89 e5                	mov    %esp,%ebp
  80053f:	83 ec 04             	sub    $0x4,%esp
  800542:	8b 45 0c             	mov    0xc(%ebp),%eax
  800545:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  800548:	eb 0f                	jmp    800559 <strfind+0x21>
        if (*s == c) {
  80054a:	8b 45 08             	mov    0x8(%ebp),%eax
  80054d:	0f b6 00             	movzbl (%eax),%eax
  800550:	38 45 fc             	cmp    %al,-0x4(%ebp)
  800553:	74 10                	je     800565 <strfind+0x2d>
            break;
        }
        s ++;
  800555:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s != '\0') {
  800559:	8b 45 08             	mov    0x8(%ebp),%eax
  80055c:	0f b6 00             	movzbl (%eax),%eax
  80055f:	84 c0                	test   %al,%al
  800561:	75 e7                	jne    80054a <strfind+0x12>
  800563:	eb 01                	jmp    800566 <strfind+0x2e>
            break;
  800565:	90                   	nop
    }
    return (char *)s;
  800566:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800569:	c9                   	leave  
  80056a:	c3                   	ret    

0080056b <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  80056b:	f3 0f 1e fb          	endbr32 
  80056f:	55                   	push   %ebp
  800570:	89 e5                	mov    %esp,%ebp
  800572:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  800575:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  80057c:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  800583:	eb 04                	jmp    800589 <strtol+0x1e>
        s ++;
  800585:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
  800589:	8b 45 08             	mov    0x8(%ebp),%eax
  80058c:	0f b6 00             	movzbl (%eax),%eax
  80058f:	3c 20                	cmp    $0x20,%al
  800591:	74 f2                	je     800585 <strtol+0x1a>
  800593:	8b 45 08             	mov    0x8(%ebp),%eax
  800596:	0f b6 00             	movzbl (%eax),%eax
  800599:	3c 09                	cmp    $0x9,%al
  80059b:	74 e8                	je     800585 <strtol+0x1a>
    }

    // plus/minus sign
    if (*s == '+') {
  80059d:	8b 45 08             	mov    0x8(%ebp),%eax
  8005a0:	0f b6 00             	movzbl (%eax),%eax
  8005a3:	3c 2b                	cmp    $0x2b,%al
  8005a5:	75 06                	jne    8005ad <strtol+0x42>
        s ++;
  8005a7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8005ab:	eb 15                	jmp    8005c2 <strtol+0x57>
    }
    else if (*s == '-') {
  8005ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8005b0:	0f b6 00             	movzbl (%eax),%eax
  8005b3:	3c 2d                	cmp    $0x2d,%al
  8005b5:	75 0b                	jne    8005c2 <strtol+0x57>
        s ++, neg = 1;
  8005b7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8005bb:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  8005c2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8005c6:	74 06                	je     8005ce <strtol+0x63>
  8005c8:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  8005cc:	75 24                	jne    8005f2 <strtol+0x87>
  8005ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8005d1:	0f b6 00             	movzbl (%eax),%eax
  8005d4:	3c 30                	cmp    $0x30,%al
  8005d6:	75 1a                	jne    8005f2 <strtol+0x87>
  8005d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8005db:	83 c0 01             	add    $0x1,%eax
  8005de:	0f b6 00             	movzbl (%eax),%eax
  8005e1:	3c 78                	cmp    $0x78,%al
  8005e3:	75 0d                	jne    8005f2 <strtol+0x87>
        s += 2, base = 16;
  8005e5:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  8005e9:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  8005f0:	eb 2a                	jmp    80061c <strtol+0xb1>
    }
    else if (base == 0 && s[0] == '0') {
  8005f2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8005f6:	75 17                	jne    80060f <strtol+0xa4>
  8005f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8005fb:	0f b6 00             	movzbl (%eax),%eax
  8005fe:	3c 30                	cmp    $0x30,%al
  800600:	75 0d                	jne    80060f <strtol+0xa4>
        s ++, base = 8;
  800602:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800606:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  80060d:	eb 0d                	jmp    80061c <strtol+0xb1>
    }
    else if (base == 0) {
  80060f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800613:	75 07                	jne    80061c <strtol+0xb1>
        base = 10;
  800615:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  80061c:	8b 45 08             	mov    0x8(%ebp),%eax
  80061f:	0f b6 00             	movzbl (%eax),%eax
  800622:	3c 2f                	cmp    $0x2f,%al
  800624:	7e 1b                	jle    800641 <strtol+0xd6>
  800626:	8b 45 08             	mov    0x8(%ebp),%eax
  800629:	0f b6 00             	movzbl (%eax),%eax
  80062c:	3c 39                	cmp    $0x39,%al
  80062e:	7f 11                	jg     800641 <strtol+0xd6>
            dig = *s - '0';
  800630:	8b 45 08             	mov    0x8(%ebp),%eax
  800633:	0f b6 00             	movzbl (%eax),%eax
  800636:	0f be c0             	movsbl %al,%eax
  800639:	83 e8 30             	sub    $0x30,%eax
  80063c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80063f:	eb 48                	jmp    800689 <strtol+0x11e>
        }
        else if (*s >= 'a' && *s <= 'z') {
  800641:	8b 45 08             	mov    0x8(%ebp),%eax
  800644:	0f b6 00             	movzbl (%eax),%eax
  800647:	3c 60                	cmp    $0x60,%al
  800649:	7e 1b                	jle    800666 <strtol+0xfb>
  80064b:	8b 45 08             	mov    0x8(%ebp),%eax
  80064e:	0f b6 00             	movzbl (%eax),%eax
  800651:	3c 7a                	cmp    $0x7a,%al
  800653:	7f 11                	jg     800666 <strtol+0xfb>
            dig = *s - 'a' + 10;
  800655:	8b 45 08             	mov    0x8(%ebp),%eax
  800658:	0f b6 00             	movzbl (%eax),%eax
  80065b:	0f be c0             	movsbl %al,%eax
  80065e:	83 e8 57             	sub    $0x57,%eax
  800661:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800664:	eb 23                	jmp    800689 <strtol+0x11e>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  800666:	8b 45 08             	mov    0x8(%ebp),%eax
  800669:	0f b6 00             	movzbl (%eax),%eax
  80066c:	3c 40                	cmp    $0x40,%al
  80066e:	7e 3c                	jle    8006ac <strtol+0x141>
  800670:	8b 45 08             	mov    0x8(%ebp),%eax
  800673:	0f b6 00             	movzbl (%eax),%eax
  800676:	3c 5a                	cmp    $0x5a,%al
  800678:	7f 32                	jg     8006ac <strtol+0x141>
            dig = *s - 'A' + 10;
  80067a:	8b 45 08             	mov    0x8(%ebp),%eax
  80067d:	0f b6 00             	movzbl (%eax),%eax
  800680:	0f be c0             	movsbl %al,%eax
  800683:	83 e8 37             	sub    $0x37,%eax
  800686:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  800689:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80068c:	3b 45 10             	cmp    0x10(%ebp),%eax
  80068f:	7d 1a                	jge    8006ab <strtol+0x140>
            break;
        }
        s ++, val = (val * base) + dig;
  800691:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800695:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800698:	0f af 45 10          	imul   0x10(%ebp),%eax
  80069c:	89 c2                	mov    %eax,%edx
  80069e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006a1:	01 d0                	add    %edx,%eax
  8006a3:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
  8006a6:	e9 71 ff ff ff       	jmp    80061c <strtol+0xb1>
            break;
  8006ab:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
  8006ac:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8006b0:	74 08                	je     8006ba <strtol+0x14f>
        *endptr = (char *) s;
  8006b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8006b8:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  8006ba:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  8006be:	74 07                	je     8006c7 <strtol+0x15c>
  8006c0:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8006c3:	f7 d8                	neg    %eax
  8006c5:	eb 03                	jmp    8006ca <strtol+0x15f>
  8006c7:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  8006ca:	c9                   	leave  
  8006cb:	c3                   	ret    

008006cc <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  8006cc:	f3 0f 1e fb          	endbr32 
  8006d0:	55                   	push   %ebp
  8006d1:	89 e5                	mov    %esp,%ebp
  8006d3:	57                   	push   %edi
  8006d4:	83 ec 24             	sub    $0x24,%esp
  8006d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006da:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  8006dd:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8006e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8006e4:	89 55 f8             	mov    %edx,-0x8(%ebp)
  8006e7:	88 45 f7             	mov    %al,-0x9(%ebp)
  8006ea:	8b 45 10             	mov    0x10(%ebp),%eax
  8006ed:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  8006f0:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8006f3:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8006f7:	8b 55 f8             	mov    -0x8(%ebp),%edx
  8006fa:	89 d7                	mov    %edx,%edi
  8006fc:	f3 aa                	rep stos %al,%es:(%edi)
  8006fe:	89 fa                	mov    %edi,%edx
  800700:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  800703:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
  800706:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  800709:	83 c4 24             	add    $0x24,%esp
  80070c:	5f                   	pop    %edi
  80070d:	5d                   	pop    %ebp
  80070e:	c3                   	ret    

0080070f <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  80070f:	f3 0f 1e fb          	endbr32 
  800713:	55                   	push   %ebp
  800714:	89 e5                	mov    %esp,%ebp
  800716:	57                   	push   %edi
  800717:	56                   	push   %esi
  800718:	53                   	push   %ebx
  800719:	83 ec 30             	sub    $0x30,%esp
  80071c:	8b 45 08             	mov    0x8(%ebp),%eax
  80071f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800722:	8b 45 0c             	mov    0xc(%ebp),%eax
  800725:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800728:	8b 45 10             	mov    0x10(%ebp),%eax
  80072b:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  80072e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800731:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800734:	73 42                	jae    800778 <memmove+0x69>
  800736:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800739:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80073c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80073f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800742:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800745:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  800748:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80074b:	c1 e8 02             	shr    $0x2,%eax
  80074e:	89 c1                	mov    %eax,%ecx
    asm volatile (
  800750:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800753:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800756:	89 d7                	mov    %edx,%edi
  800758:	89 c6                	mov    %eax,%esi
  80075a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80075c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80075f:	83 e1 03             	and    $0x3,%ecx
  800762:	74 02                	je     800766 <memmove+0x57>
  800764:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  800766:	89 f0                	mov    %esi,%eax
  800768:	89 fa                	mov    %edi,%edx
  80076a:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  80076d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800770:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
  800773:	8b 45 e4             	mov    -0x1c(%ebp),%eax
        return __memcpy(dst, src, n);
  800776:	eb 36                	jmp    8007ae <memmove+0x9f>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  800778:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80077b:	8d 50 ff             	lea    -0x1(%eax),%edx
  80077e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800781:	01 c2                	add    %eax,%edx
  800783:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800786:	8d 48 ff             	lea    -0x1(%eax),%ecx
  800789:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80078c:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
  80078f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800792:	89 c1                	mov    %eax,%ecx
  800794:	89 d8                	mov    %ebx,%eax
  800796:	89 d6                	mov    %edx,%esi
  800798:	89 c7                	mov    %eax,%edi
  80079a:	fd                   	std    
  80079b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  80079d:	fc                   	cld    
  80079e:	89 f8                	mov    %edi,%eax
  8007a0:	89 f2                	mov    %esi,%edx
  8007a2:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8007a5:	89 55 c8             	mov    %edx,-0x38(%ebp)
  8007a8:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
  8007ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  8007ae:	83 c4 30             	add    $0x30,%esp
  8007b1:	5b                   	pop    %ebx
  8007b2:	5e                   	pop    %esi
  8007b3:	5f                   	pop    %edi
  8007b4:	5d                   	pop    %ebp
  8007b5:	c3                   	ret    

008007b6 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  8007b6:	f3 0f 1e fb          	endbr32 
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
  8007bd:	57                   	push   %edi
  8007be:	56                   	push   %esi
  8007bf:	83 ec 20             	sub    $0x20,%esp
  8007c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8007c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007cb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007ce:	8b 45 10             	mov    0x10(%ebp),%eax
  8007d1:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  8007d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007d7:	c1 e8 02             	shr    $0x2,%eax
  8007da:	89 c1                	mov    %eax,%ecx
    asm volatile (
  8007dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e2:	89 d7                	mov    %edx,%edi
  8007e4:	89 c6                	mov    %eax,%esi
  8007e6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8007e8:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  8007eb:	83 e1 03             	and    $0x3,%ecx
  8007ee:	74 02                	je     8007f2 <memcpy+0x3c>
  8007f0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  8007f2:	89 f0                	mov    %esi,%eax
  8007f4:	89 fa                	mov    %edi,%edx
  8007f6:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  8007f9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8007fc:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
  8007ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  800802:	83 c4 20             	add    $0x20,%esp
  800805:	5e                   	pop    %esi
  800806:	5f                   	pop    %edi
  800807:	5d                   	pop    %ebp
  800808:	c3                   	ret    

00800809 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  800809:	f3 0f 1e fb          	endbr32 
  80080d:	55                   	push   %ebp
  80080e:	89 e5                	mov    %esp,%ebp
  800810:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  800813:	8b 45 08             	mov    0x8(%ebp),%eax
  800816:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  800819:	8b 45 0c             	mov    0xc(%ebp),%eax
  80081c:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  80081f:	eb 30                	jmp    800851 <memcmp+0x48>
        if (*s1 != *s2) {
  800821:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800824:	0f b6 10             	movzbl (%eax),%edx
  800827:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80082a:	0f b6 00             	movzbl (%eax),%eax
  80082d:	38 c2                	cmp    %al,%dl
  80082f:	74 18                	je     800849 <memcmp+0x40>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  800831:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800834:	0f b6 00             	movzbl (%eax),%eax
  800837:	0f b6 d0             	movzbl %al,%edx
  80083a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80083d:	0f b6 00             	movzbl (%eax),%eax
  800840:	0f b6 c0             	movzbl %al,%eax
  800843:	29 c2                	sub    %eax,%edx
  800845:	89 d0                	mov    %edx,%eax
  800847:	eb 1a                	jmp    800863 <memcmp+0x5a>
        }
        s1 ++, s2 ++;
  800849:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  80084d:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
    while (n -- > 0) {
  800851:	8b 45 10             	mov    0x10(%ebp),%eax
  800854:	8d 50 ff             	lea    -0x1(%eax),%edx
  800857:	89 55 10             	mov    %edx,0x10(%ebp)
  80085a:	85 c0                	test   %eax,%eax
  80085c:	75 c3                	jne    800821 <memcmp+0x18>
    }
    return 0;
  80085e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800863:	c9                   	leave  
  800864:	c3                   	ret    

00800865 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  800865:	f3 0f 1e fb          	endbr32 
  800869:	55                   	push   %ebp
  80086a:	89 e5                	mov    %esp,%ebp
  80086c:	83 ec 38             	sub    $0x38,%esp
  80086f:	8b 45 10             	mov    0x10(%ebp),%eax
  800872:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800875:	8b 45 14             	mov    0x14(%ebp),%eax
  800878:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  80087b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80087e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800881:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800884:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  800887:	8b 45 18             	mov    0x18(%ebp),%eax
  80088a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80088d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800890:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800893:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800896:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800899:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80089c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80089f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8008a3:	74 1c                	je     8008c1 <printnum+0x5c>
  8008a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8008ad:	f7 75 e4             	divl   -0x1c(%ebp)
  8008b0:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8008b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8008bb:	f7 75 e4             	divl   -0x1c(%ebp)
  8008be:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8008c1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008c4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8008c7:	f7 75 e4             	divl   -0x1c(%ebp)
  8008ca:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008cd:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8008d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008d3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8008d6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8008d9:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8008dc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8008df:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  8008e2:	8b 45 18             	mov    0x18(%ebp),%eax
  8008e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8008ea:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8008ed:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  8008f0:	19 d1                	sbb    %edx,%ecx
  8008f2:	72 37                	jb     80092b <printnum+0xc6>
        printnum(putch, putdat, result, base, width - 1, padc);
  8008f4:	8b 45 1c             	mov    0x1c(%ebp),%eax
  8008f7:	83 e8 01             	sub    $0x1,%eax
  8008fa:	83 ec 04             	sub    $0x4,%esp
  8008fd:	ff 75 20             	pushl  0x20(%ebp)
  800900:	50                   	push   %eax
  800901:	ff 75 18             	pushl  0x18(%ebp)
  800904:	ff 75 ec             	pushl  -0x14(%ebp)
  800907:	ff 75 e8             	pushl  -0x18(%ebp)
  80090a:	ff 75 0c             	pushl  0xc(%ebp)
  80090d:	ff 75 08             	pushl  0x8(%ebp)
  800910:	e8 50 ff ff ff       	call   800865 <printnum>
  800915:	83 c4 20             	add    $0x20,%esp
  800918:	eb 1b                	jmp    800935 <printnum+0xd0>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  80091a:	83 ec 08             	sub    $0x8,%esp
  80091d:	ff 75 0c             	pushl  0xc(%ebp)
  800920:	ff 75 20             	pushl  0x20(%ebp)
  800923:	8b 45 08             	mov    0x8(%ebp),%eax
  800926:	ff d0                	call   *%eax
  800928:	83 c4 10             	add    $0x10,%esp
        while (-- width > 0)
  80092b:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  80092f:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800933:	7f e5                	jg     80091a <printnum+0xb5>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800935:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800938:	05 04 12 80 00       	add    $0x801204,%eax
  80093d:	0f b6 00             	movzbl (%eax),%eax
  800940:	0f be c0             	movsbl %al,%eax
  800943:	83 ec 08             	sub    $0x8,%esp
  800946:	ff 75 0c             	pushl  0xc(%ebp)
  800949:	50                   	push   %eax
  80094a:	8b 45 08             	mov    0x8(%ebp),%eax
  80094d:	ff d0                	call   *%eax
  80094f:	83 c4 10             	add    $0x10,%esp
}
  800952:	90                   	nop
  800953:	c9                   	leave  
  800954:	c3                   	ret    

00800955 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  800955:	f3 0f 1e fb          	endbr32 
  800959:	55                   	push   %ebp
  80095a:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  80095c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800960:	7e 14                	jle    800976 <getuint+0x21>
        return va_arg(*ap, unsigned long long);
  800962:	8b 45 08             	mov    0x8(%ebp),%eax
  800965:	8b 00                	mov    (%eax),%eax
  800967:	8d 48 08             	lea    0x8(%eax),%ecx
  80096a:	8b 55 08             	mov    0x8(%ebp),%edx
  80096d:	89 0a                	mov    %ecx,(%edx)
  80096f:	8b 50 04             	mov    0x4(%eax),%edx
  800972:	8b 00                	mov    (%eax),%eax
  800974:	eb 30                	jmp    8009a6 <getuint+0x51>
    }
    else if (lflag) {
  800976:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80097a:	74 16                	je     800992 <getuint+0x3d>
        return va_arg(*ap, unsigned long);
  80097c:	8b 45 08             	mov    0x8(%ebp),%eax
  80097f:	8b 00                	mov    (%eax),%eax
  800981:	8d 48 04             	lea    0x4(%eax),%ecx
  800984:	8b 55 08             	mov    0x8(%ebp),%edx
  800987:	89 0a                	mov    %ecx,(%edx)
  800989:	8b 00                	mov    (%eax),%eax
  80098b:	ba 00 00 00 00       	mov    $0x0,%edx
  800990:	eb 14                	jmp    8009a6 <getuint+0x51>
    }
    else {
        return va_arg(*ap, unsigned int);
  800992:	8b 45 08             	mov    0x8(%ebp),%eax
  800995:	8b 00                	mov    (%eax),%eax
  800997:	8d 48 04             	lea    0x4(%eax),%ecx
  80099a:	8b 55 08             	mov    0x8(%ebp),%edx
  80099d:	89 0a                	mov    %ecx,(%edx)
  80099f:	8b 00                	mov    (%eax),%eax
  8009a1:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  8009a6:	5d                   	pop    %ebp
  8009a7:	c3                   	ret    

008009a8 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  8009a8:	f3 0f 1e fb          	endbr32 
  8009ac:	55                   	push   %ebp
  8009ad:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  8009af:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8009b3:	7e 14                	jle    8009c9 <getint+0x21>
        return va_arg(*ap, long long);
  8009b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b8:	8b 00                	mov    (%eax),%eax
  8009ba:	8d 48 08             	lea    0x8(%eax),%ecx
  8009bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8009c0:	89 0a                	mov    %ecx,(%edx)
  8009c2:	8b 50 04             	mov    0x4(%eax),%edx
  8009c5:	8b 00                	mov    (%eax),%eax
  8009c7:	eb 28                	jmp    8009f1 <getint+0x49>
    }
    else if (lflag) {
  8009c9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8009cd:	74 12                	je     8009e1 <getint+0x39>
        return va_arg(*ap, long);
  8009cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d2:	8b 00                	mov    (%eax),%eax
  8009d4:	8d 48 04             	lea    0x4(%eax),%ecx
  8009d7:	8b 55 08             	mov    0x8(%ebp),%edx
  8009da:	89 0a                	mov    %ecx,(%edx)
  8009dc:	8b 00                	mov    (%eax),%eax
  8009de:	99                   	cltd   
  8009df:	eb 10                	jmp    8009f1 <getint+0x49>
    }
    else {
        return va_arg(*ap, int);
  8009e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e4:	8b 00                	mov    (%eax),%eax
  8009e6:	8d 48 04             	lea    0x4(%eax),%ecx
  8009e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8009ec:	89 0a                	mov    %ecx,(%edx)
  8009ee:	8b 00                	mov    (%eax),%eax
  8009f0:	99                   	cltd   
    }
}
  8009f1:	5d                   	pop    %ebp
  8009f2:	c3                   	ret    

008009f3 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8009f3:	f3 0f 1e fb          	endbr32 
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	83 ec 18             	sub    $0x18,%esp
    va_list ap;

    va_start(ap, fmt);
  8009fd:	8d 45 14             	lea    0x14(%ebp),%eax
  800a00:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  800a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a06:	50                   	push   %eax
  800a07:	ff 75 10             	pushl  0x10(%ebp)
  800a0a:	ff 75 0c             	pushl  0xc(%ebp)
  800a0d:	ff 75 08             	pushl  0x8(%ebp)
  800a10:	e8 06 00 00 00       	call   800a1b <vprintfmt>
  800a15:	83 c4 10             	add    $0x10,%esp
    va_end(ap);
}
  800a18:	90                   	nop
  800a19:	c9                   	leave  
  800a1a:	c3                   	ret    

00800a1b <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  800a1b:	f3 0f 1e fb          	endbr32 
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	56                   	push   %esi
  800a23:	53                   	push   %ebx
  800a24:	83 ec 20             	sub    $0x20,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800a27:	eb 17                	jmp    800a40 <vprintfmt+0x25>
            if (ch == '\0') {
  800a29:	85 db                	test   %ebx,%ebx
  800a2b:	0f 84 8f 03 00 00    	je     800dc0 <vprintfmt+0x3a5>
                return;
            }
            putch(ch, putdat);
  800a31:	83 ec 08             	sub    $0x8,%esp
  800a34:	ff 75 0c             	pushl  0xc(%ebp)
  800a37:	53                   	push   %ebx
  800a38:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3b:	ff d0                	call   *%eax
  800a3d:	83 c4 10             	add    $0x10,%esp
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800a40:	8b 45 10             	mov    0x10(%ebp),%eax
  800a43:	8d 50 01             	lea    0x1(%eax),%edx
  800a46:	89 55 10             	mov    %edx,0x10(%ebp)
  800a49:	0f b6 00             	movzbl (%eax),%eax
  800a4c:	0f b6 d8             	movzbl %al,%ebx
  800a4f:	83 fb 25             	cmp    $0x25,%ebx
  800a52:	75 d5                	jne    800a29 <vprintfmt+0xe>
        }

        // Process a %-escape sequence
        char padc = ' ';
  800a54:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  800a58:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800a5f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800a62:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  800a65:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800a6c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800a6f:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  800a72:	8b 45 10             	mov    0x10(%ebp),%eax
  800a75:	8d 50 01             	lea    0x1(%eax),%edx
  800a78:	89 55 10             	mov    %edx,0x10(%ebp)
  800a7b:	0f b6 00             	movzbl (%eax),%eax
  800a7e:	0f b6 d8             	movzbl %al,%ebx
  800a81:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800a84:	83 f8 55             	cmp    $0x55,%eax
  800a87:	0f 87 06 03 00 00    	ja     800d93 <vprintfmt+0x378>
  800a8d:	8b 04 85 28 12 80 00 	mov    0x801228(,%eax,4),%eax
  800a94:	3e ff e0             	notrack jmp *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  800a97:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  800a9b:	eb d5                	jmp    800a72 <vprintfmt+0x57>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  800a9d:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  800aa1:	eb cf                	jmp    800a72 <vprintfmt+0x57>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  800aa3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  800aaa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800aad:	89 d0                	mov    %edx,%eax
  800aaf:	c1 e0 02             	shl    $0x2,%eax
  800ab2:	01 d0                	add    %edx,%eax
  800ab4:	01 c0                	add    %eax,%eax
  800ab6:	01 d8                	add    %ebx,%eax
  800ab8:	83 e8 30             	sub    $0x30,%eax
  800abb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  800abe:	8b 45 10             	mov    0x10(%ebp),%eax
  800ac1:	0f b6 00             	movzbl (%eax),%eax
  800ac4:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  800ac7:	83 fb 2f             	cmp    $0x2f,%ebx
  800aca:	7e 39                	jle    800b05 <vprintfmt+0xea>
  800acc:	83 fb 39             	cmp    $0x39,%ebx
  800acf:	7f 34                	jg     800b05 <vprintfmt+0xea>
            for (precision = 0; ; ++ fmt) {
  800ad1:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
  800ad5:	eb d3                	jmp    800aaa <vprintfmt+0x8f>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
  800ad7:	8b 45 14             	mov    0x14(%ebp),%eax
  800ada:	8d 50 04             	lea    0x4(%eax),%edx
  800add:	89 55 14             	mov    %edx,0x14(%ebp)
  800ae0:	8b 00                	mov    (%eax),%eax
  800ae2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  800ae5:	eb 1f                	jmp    800b06 <vprintfmt+0xeb>

        case '.':
            if (width < 0)
  800ae7:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800aeb:	79 85                	jns    800a72 <vprintfmt+0x57>
                width = 0;
  800aed:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  800af4:	e9 79 ff ff ff       	jmp    800a72 <vprintfmt+0x57>

        case '#':
            altflag = 1;
  800af9:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  800b00:	e9 6d ff ff ff       	jmp    800a72 <vprintfmt+0x57>
            goto process_precision;
  800b05:	90                   	nop

        process_precision:
            if (width < 0)
  800b06:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800b0a:	0f 89 62 ff ff ff    	jns    800a72 <vprintfmt+0x57>
                width = precision, precision = -1;
  800b10:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800b13:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800b16:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  800b1d:	e9 50 ff ff ff       	jmp    800a72 <vprintfmt+0x57>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  800b22:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
  800b26:	e9 47 ff ff ff       	jmp    800a72 <vprintfmt+0x57>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  800b2b:	8b 45 14             	mov    0x14(%ebp),%eax
  800b2e:	8d 50 04             	lea    0x4(%eax),%edx
  800b31:	89 55 14             	mov    %edx,0x14(%ebp)
  800b34:	8b 00                	mov    (%eax),%eax
  800b36:	83 ec 08             	sub    $0x8,%esp
  800b39:	ff 75 0c             	pushl  0xc(%ebp)
  800b3c:	50                   	push   %eax
  800b3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b40:	ff d0                	call   *%eax
  800b42:	83 c4 10             	add    $0x10,%esp
            break;
  800b45:	e9 71 02 00 00       	jmp    800dbb <vprintfmt+0x3a0>

        // error message
        case 'e':
            err = va_arg(ap, int);
  800b4a:	8b 45 14             	mov    0x14(%ebp),%eax
  800b4d:	8d 50 04             	lea    0x4(%eax),%edx
  800b50:	89 55 14             	mov    %edx,0x14(%ebp)
  800b53:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  800b55:	85 db                	test   %ebx,%ebx
  800b57:	79 02                	jns    800b5b <vprintfmt+0x140>
                err = -err;
  800b59:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800b5b:	83 fb 18             	cmp    $0x18,%ebx
  800b5e:	7f 0b                	jg     800b6b <vprintfmt+0x150>
  800b60:	8b 34 9d a0 11 80 00 	mov    0x8011a0(,%ebx,4),%esi
  800b67:	85 f6                	test   %esi,%esi
  800b69:	75 19                	jne    800b84 <vprintfmt+0x169>
                printfmt(putch, putdat, "error %d", err);
  800b6b:	53                   	push   %ebx
  800b6c:	68 15 12 80 00       	push   $0x801215
  800b71:	ff 75 0c             	pushl  0xc(%ebp)
  800b74:	ff 75 08             	pushl  0x8(%ebp)
  800b77:	e8 77 fe ff ff       	call   8009f3 <printfmt>
  800b7c:	83 c4 10             	add    $0x10,%esp
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  800b7f:	e9 37 02 00 00       	jmp    800dbb <vprintfmt+0x3a0>
                printfmt(putch, putdat, "%s", p);
  800b84:	56                   	push   %esi
  800b85:	68 1e 12 80 00       	push   $0x80121e
  800b8a:	ff 75 0c             	pushl  0xc(%ebp)
  800b8d:	ff 75 08             	pushl  0x8(%ebp)
  800b90:	e8 5e fe ff ff       	call   8009f3 <printfmt>
  800b95:	83 c4 10             	add    $0x10,%esp
            break;
  800b98:	e9 1e 02 00 00       	jmp    800dbb <vprintfmt+0x3a0>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  800b9d:	8b 45 14             	mov    0x14(%ebp),%eax
  800ba0:	8d 50 04             	lea    0x4(%eax),%edx
  800ba3:	89 55 14             	mov    %edx,0x14(%ebp)
  800ba6:	8b 30                	mov    (%eax),%esi
  800ba8:	85 f6                	test   %esi,%esi
  800baa:	75 05                	jne    800bb1 <vprintfmt+0x196>
                p = "(null)";
  800bac:	be 21 12 80 00       	mov    $0x801221,%esi
            }
            if (width > 0 && padc != '-') {
  800bb1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800bb5:	7e 76                	jle    800c2d <vprintfmt+0x212>
  800bb7:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800bbb:	74 70                	je     800c2d <vprintfmt+0x212>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800bbd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800bc0:	83 ec 08             	sub    $0x8,%esp
  800bc3:	50                   	push   %eax
  800bc4:	56                   	push   %esi
  800bc5:	e8 db f7 ff ff       	call   8003a5 <strnlen>
  800bca:	83 c4 10             	add    $0x10,%esp
  800bcd:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800bd0:	29 c2                	sub    %eax,%edx
  800bd2:	89 d0                	mov    %edx,%eax
  800bd4:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800bd7:	eb 17                	jmp    800bf0 <vprintfmt+0x1d5>
                    putch(padc, putdat);
  800bd9:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800bdd:	83 ec 08             	sub    $0x8,%esp
  800be0:	ff 75 0c             	pushl  0xc(%ebp)
  800be3:	50                   	push   %eax
  800be4:	8b 45 08             	mov    0x8(%ebp),%eax
  800be7:	ff d0                	call   *%eax
  800be9:	83 c4 10             	add    $0x10,%esp
                for (width -= strnlen(p, precision); width > 0; width --) {
  800bec:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  800bf0:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800bf4:	7f e3                	jg     800bd9 <vprintfmt+0x1be>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800bf6:	eb 35                	jmp    800c2d <vprintfmt+0x212>
                if (altflag && (ch < ' ' || ch > '~')) {
  800bf8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800bfc:	74 1c                	je     800c1a <vprintfmt+0x1ff>
  800bfe:	83 fb 1f             	cmp    $0x1f,%ebx
  800c01:	7e 05                	jle    800c08 <vprintfmt+0x1ed>
  800c03:	83 fb 7e             	cmp    $0x7e,%ebx
  800c06:	7e 12                	jle    800c1a <vprintfmt+0x1ff>
                    putch('?', putdat);
  800c08:	83 ec 08             	sub    $0x8,%esp
  800c0b:	ff 75 0c             	pushl  0xc(%ebp)
  800c0e:	6a 3f                	push   $0x3f
  800c10:	8b 45 08             	mov    0x8(%ebp),%eax
  800c13:	ff d0                	call   *%eax
  800c15:	83 c4 10             	add    $0x10,%esp
  800c18:	eb 0f                	jmp    800c29 <vprintfmt+0x20e>
                }
                else {
                    putch(ch, putdat);
  800c1a:	83 ec 08             	sub    $0x8,%esp
  800c1d:	ff 75 0c             	pushl  0xc(%ebp)
  800c20:	53                   	push   %ebx
  800c21:	8b 45 08             	mov    0x8(%ebp),%eax
  800c24:	ff d0                	call   *%eax
  800c26:	83 c4 10             	add    $0x10,%esp
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800c29:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  800c2d:	89 f0                	mov    %esi,%eax
  800c2f:	8d 70 01             	lea    0x1(%eax),%esi
  800c32:	0f b6 00             	movzbl (%eax),%eax
  800c35:	0f be d8             	movsbl %al,%ebx
  800c38:	85 db                	test   %ebx,%ebx
  800c3a:	74 26                	je     800c62 <vprintfmt+0x247>
  800c3c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800c40:	78 b6                	js     800bf8 <vprintfmt+0x1dd>
  800c42:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800c46:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800c4a:	79 ac                	jns    800bf8 <vprintfmt+0x1dd>
                }
            }
            for (; width > 0; width --) {
  800c4c:	eb 14                	jmp    800c62 <vprintfmt+0x247>
                putch(' ', putdat);
  800c4e:	83 ec 08             	sub    $0x8,%esp
  800c51:	ff 75 0c             	pushl  0xc(%ebp)
  800c54:	6a 20                	push   $0x20
  800c56:	8b 45 08             	mov    0x8(%ebp),%eax
  800c59:	ff d0                	call   *%eax
  800c5b:	83 c4 10             	add    $0x10,%esp
            for (; width > 0; width --) {
  800c5e:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  800c62:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800c66:	7f e6                	jg     800c4e <vprintfmt+0x233>
            }
            break;
  800c68:	e9 4e 01 00 00       	jmp    800dbb <vprintfmt+0x3a0>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  800c6d:	83 ec 08             	sub    $0x8,%esp
  800c70:	ff 75 e0             	pushl  -0x20(%ebp)
  800c73:	8d 45 14             	lea    0x14(%ebp),%eax
  800c76:	50                   	push   %eax
  800c77:	e8 2c fd ff ff       	call   8009a8 <getint>
  800c7c:	83 c4 10             	add    $0x10,%esp
  800c7f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800c82:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  800c85:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c88:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c8b:	85 d2                	test   %edx,%edx
  800c8d:	79 23                	jns    800cb2 <vprintfmt+0x297>
                putch('-', putdat);
  800c8f:	83 ec 08             	sub    $0x8,%esp
  800c92:	ff 75 0c             	pushl  0xc(%ebp)
  800c95:	6a 2d                	push   $0x2d
  800c97:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9a:	ff d0                	call   *%eax
  800c9c:	83 c4 10             	add    $0x10,%esp
                num = -(long long)num;
  800c9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ca2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ca5:	f7 d8                	neg    %eax
  800ca7:	83 d2 00             	adc    $0x0,%edx
  800caa:	f7 da                	neg    %edx
  800cac:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800caf:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  800cb2:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  800cb9:	e9 9f 00 00 00       	jmp    800d5d <vprintfmt+0x342>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  800cbe:	83 ec 08             	sub    $0x8,%esp
  800cc1:	ff 75 e0             	pushl  -0x20(%ebp)
  800cc4:	8d 45 14             	lea    0x14(%ebp),%eax
  800cc7:	50                   	push   %eax
  800cc8:	e8 88 fc ff ff       	call   800955 <getuint>
  800ccd:	83 c4 10             	add    $0x10,%esp
  800cd0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800cd3:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  800cd6:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  800cdd:	eb 7e                	jmp    800d5d <vprintfmt+0x342>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  800cdf:	83 ec 08             	sub    $0x8,%esp
  800ce2:	ff 75 e0             	pushl  -0x20(%ebp)
  800ce5:	8d 45 14             	lea    0x14(%ebp),%eax
  800ce8:	50                   	push   %eax
  800ce9:	e8 67 fc ff ff       	call   800955 <getuint>
  800cee:	83 c4 10             	add    $0x10,%esp
  800cf1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800cf4:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  800cf7:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  800cfe:	eb 5d                	jmp    800d5d <vprintfmt+0x342>

        // pointer
        case 'p':
            putch('0', putdat);
  800d00:	83 ec 08             	sub    $0x8,%esp
  800d03:	ff 75 0c             	pushl  0xc(%ebp)
  800d06:	6a 30                	push   $0x30
  800d08:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0b:	ff d0                	call   *%eax
  800d0d:	83 c4 10             	add    $0x10,%esp
            putch('x', putdat);
  800d10:	83 ec 08             	sub    $0x8,%esp
  800d13:	ff 75 0c             	pushl  0xc(%ebp)
  800d16:	6a 78                	push   $0x78
  800d18:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1b:	ff d0                	call   *%eax
  800d1d:	83 c4 10             	add    $0x10,%esp
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800d20:	8b 45 14             	mov    0x14(%ebp),%eax
  800d23:	8d 50 04             	lea    0x4(%eax),%edx
  800d26:	89 55 14             	mov    %edx,0x14(%ebp)
  800d29:	8b 00                	mov    (%eax),%eax
  800d2b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800d2e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  800d35:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  800d3c:	eb 1f                	jmp    800d5d <vprintfmt+0x342>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  800d3e:	83 ec 08             	sub    $0x8,%esp
  800d41:	ff 75 e0             	pushl  -0x20(%ebp)
  800d44:	8d 45 14             	lea    0x14(%ebp),%eax
  800d47:	50                   	push   %eax
  800d48:	e8 08 fc ff ff       	call   800955 <getuint>
  800d4d:	83 c4 10             	add    $0x10,%esp
  800d50:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800d53:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  800d56:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  800d5d:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800d61:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d64:	83 ec 04             	sub    $0x4,%esp
  800d67:	52                   	push   %edx
  800d68:	ff 75 e8             	pushl  -0x18(%ebp)
  800d6b:	50                   	push   %eax
  800d6c:	ff 75 f4             	pushl  -0xc(%ebp)
  800d6f:	ff 75 f0             	pushl  -0x10(%ebp)
  800d72:	ff 75 0c             	pushl  0xc(%ebp)
  800d75:	ff 75 08             	pushl  0x8(%ebp)
  800d78:	e8 e8 fa ff ff       	call   800865 <printnum>
  800d7d:	83 c4 20             	add    $0x20,%esp
            break;
  800d80:	eb 39                	jmp    800dbb <vprintfmt+0x3a0>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  800d82:	83 ec 08             	sub    $0x8,%esp
  800d85:	ff 75 0c             	pushl  0xc(%ebp)
  800d88:	53                   	push   %ebx
  800d89:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8c:	ff d0                	call   *%eax
  800d8e:	83 c4 10             	add    $0x10,%esp
            break;
  800d91:	eb 28                	jmp    800dbb <vprintfmt+0x3a0>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  800d93:	83 ec 08             	sub    $0x8,%esp
  800d96:	ff 75 0c             	pushl  0xc(%ebp)
  800d99:	6a 25                	push   $0x25
  800d9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9e:	ff d0                	call   *%eax
  800da0:	83 c4 10             	add    $0x10,%esp
            for (fmt --; fmt[-1] != '%'; fmt --)
  800da3:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800da7:	eb 04                	jmp    800dad <vprintfmt+0x392>
  800da9:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800dad:	8b 45 10             	mov    0x10(%ebp),%eax
  800db0:	83 e8 01             	sub    $0x1,%eax
  800db3:	0f b6 00             	movzbl (%eax),%eax
  800db6:	3c 25                	cmp    $0x25,%al
  800db8:	75 ef                	jne    800da9 <vprintfmt+0x38e>
                /* do nothing */;
            break;
  800dba:	90                   	nop
    while (1) {
  800dbb:	e9 67 fc ff ff       	jmp    800a27 <vprintfmt+0xc>
                return;
  800dc0:	90                   	nop
        }
    }
}
  800dc1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800dc4:	5b                   	pop    %ebx
  800dc5:	5e                   	pop    %esi
  800dc6:	5d                   	pop    %ebp
  800dc7:	c3                   	ret    

00800dc8 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  800dc8:	f3 0f 1e fb          	endbr32 
  800dcc:	55                   	push   %ebp
  800dcd:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  800dcf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dd2:	8b 40 08             	mov    0x8(%eax),%eax
  800dd5:	8d 50 01             	lea    0x1(%eax),%edx
  800dd8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ddb:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  800dde:	8b 45 0c             	mov    0xc(%ebp),%eax
  800de1:	8b 10                	mov    (%eax),%edx
  800de3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800de6:	8b 40 04             	mov    0x4(%eax),%eax
  800de9:	39 c2                	cmp    %eax,%edx
  800deb:	73 12                	jae    800dff <sprintputch+0x37>
        *b->buf ++ = ch;
  800ded:	8b 45 0c             	mov    0xc(%ebp),%eax
  800df0:	8b 00                	mov    (%eax),%eax
  800df2:	8d 48 01             	lea    0x1(%eax),%ecx
  800df5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800df8:	89 0a                	mov    %ecx,(%edx)
  800dfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfd:	88 10                	mov    %dl,(%eax)
    }
}
  800dff:	90                   	nop
  800e00:	5d                   	pop    %ebp
  800e01:	c3                   	ret    

00800e02 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  800e02:	f3 0f 1e fb          	endbr32 
  800e06:	55                   	push   %ebp
  800e07:	89 e5                	mov    %esp,%ebp
  800e09:	83 ec 18             	sub    $0x18,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  800e0c:	8d 45 14             	lea    0x14(%ebp),%eax
  800e0f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  800e12:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e15:	50                   	push   %eax
  800e16:	ff 75 10             	pushl  0x10(%ebp)
  800e19:	ff 75 0c             	pushl  0xc(%ebp)
  800e1c:	ff 75 08             	pushl  0x8(%ebp)
  800e1f:	e8 0b 00 00 00       	call   800e2f <vsnprintf>
  800e24:	83 c4 10             	add    $0x10,%esp
  800e27:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  800e2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800e2d:	c9                   	leave  
  800e2e:	c3                   	ret    

00800e2f <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  800e2f:	f3 0f 1e fb          	endbr32 
  800e33:	55                   	push   %ebp
  800e34:	89 e5                	mov    %esp,%ebp
  800e36:	83 ec 18             	sub    $0x18,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  800e39:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800e3f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e42:	8d 50 ff             	lea    -0x1(%eax),%edx
  800e45:	8b 45 08             	mov    0x8(%ebp),%eax
  800e48:	01 d0                	add    %edx,%eax
  800e4a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800e4d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  800e54:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800e58:	74 0a                	je     800e64 <vsnprintf+0x35>
  800e5a:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800e5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e60:	39 c2                	cmp    %eax,%edx
  800e62:	76 07                	jbe    800e6b <vsnprintf+0x3c>
        return -E_INVAL;
  800e64:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e69:	eb 20                	jmp    800e8b <vsnprintf+0x5c>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  800e6b:	ff 75 14             	pushl  0x14(%ebp)
  800e6e:	ff 75 10             	pushl  0x10(%ebp)
  800e71:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800e74:	50                   	push   %eax
  800e75:	68 c8 0d 80 00       	push   $0x800dc8
  800e7a:	e8 9c fb ff ff       	call   800a1b <vprintfmt>
  800e7f:	83 c4 10             	add    $0x10,%esp
    // null terminate the buffer
    *b.buf = '\0';
  800e82:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e85:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  800e88:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800e8b:	c9                   	leave  
  800e8c:	c3                   	ret    

00800e8d <hash32>:
 * @bits:   the number of bits in a return value
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
  800e8d:	f3 0f 1e fb          	endbr32 
  800e91:	55                   	push   %ebp
  800e92:	89 e5                	mov    %esp,%ebp
  800e94:	83 ec 10             	sub    $0x10,%esp
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
  800e97:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9a:	69 c0 01 00 37 9e    	imul   $0x9e370001,%eax,%eax
  800ea0:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (hash >> (32 - bits));
  800ea3:	b8 20 00 00 00       	mov    $0x20,%eax
  800ea8:	2b 45 0c             	sub    0xc(%ebp),%eax
  800eab:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800eae:	89 c1                	mov    %eax,%ecx
  800eb0:	d3 ea                	shr    %cl,%edx
  800eb2:	89 d0                	mov    %edx,%eax
}
  800eb4:	c9                   	leave  
  800eb5:	c3                   	ret    

00800eb6 <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
  800eb6:	f3 0f 1e fb          	endbr32 
  800eba:	55                   	push   %ebp
  800ebb:	89 e5                	mov    %esp,%ebp
  800ebd:	57                   	push   %edi
  800ebe:	56                   	push   %esi
  800ebf:	53                   	push   %ebx
  800ec0:	83 ec 24             	sub    $0x24,%esp
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
  800ec3:	a1 00 20 80 00       	mov    0x802000,%eax
  800ec8:	8b 15 04 20 80 00    	mov    0x802004,%edx
  800ece:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
  800ed4:	6b f0 05             	imul   $0x5,%eax,%esi
  800ed7:	01 fe                	add    %edi,%esi
  800ed9:	bf 6d e6 ec de       	mov    $0xdeece66d,%edi
  800ede:	f7 e7                	mul    %edi
  800ee0:	01 d6                	add    %edx,%esi
  800ee2:	89 f2                	mov    %esi,%edx
  800ee4:	83 c0 0b             	add    $0xb,%eax
  800ee7:	83 d2 00             	adc    $0x0,%edx
  800eea:	89 c7                	mov    %eax,%edi
  800eec:	83 e7 ff             	and    $0xffffffff,%edi
  800eef:	89 f9                	mov    %edi,%ecx
  800ef1:	0f b7 da             	movzwl %dx,%ebx
  800ef4:	89 0d 00 20 80 00    	mov    %ecx,0x802000
  800efa:	89 1d 04 20 80 00    	mov    %ebx,0x802004
    unsigned long long result = (next >> 12);
  800f00:	a1 00 20 80 00       	mov    0x802000,%eax
  800f05:	8b 15 04 20 80 00    	mov    0x802004,%edx
  800f0b:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  800f0f:	c1 ea 0c             	shr    $0xc,%edx
  800f12:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f15:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
  800f18:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
  800f1f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f22:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800f25:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800f28:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800f2b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800f2e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800f31:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800f35:	74 1c                	je     800f53 <rand+0x9d>
  800f37:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800f3a:	ba 00 00 00 00       	mov    $0x0,%edx
  800f3f:	f7 75 dc             	divl   -0x24(%ebp)
  800f42:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800f45:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800f48:	ba 00 00 00 00       	mov    $0x0,%edx
  800f4d:	f7 75 dc             	divl   -0x24(%ebp)
  800f50:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800f53:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800f56:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800f59:	f7 75 dc             	divl   -0x24(%ebp)
  800f5c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800f5f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800f62:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800f65:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800f68:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f6b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800f6e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
  800f71:	83 c4 24             	add    $0x24,%esp
  800f74:	5b                   	pop    %ebx
  800f75:	5e                   	pop    %esi
  800f76:	5f                   	pop    %edi
  800f77:	5d                   	pop    %ebp
  800f78:	c3                   	ret    

00800f79 <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
  800f79:	f3 0f 1e fb          	endbr32 
  800f7d:	55                   	push   %ebp
  800f7e:	89 e5                	mov    %esp,%ebp
    next = seed;
  800f80:	8b 45 08             	mov    0x8(%ebp),%eax
  800f83:	ba 00 00 00 00       	mov    $0x0,%edx
  800f88:	a3 00 20 80 00       	mov    %eax,0x802000
  800f8d:	89 15 04 20 80 00    	mov    %edx,0x802004
}
  800f93:	90                   	nop
  800f94:	5d                   	pop    %ebp
  800f95:	c3                   	ret    

00800f96 <main>:
#include <stdio.h>

const int max_child = 32;

int
main(void) {
  800f96:	f3 0f 1e fb          	endbr32 
  800f9a:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  800f9e:	83 e4 f0             	and    $0xfffffff0,%esp
  800fa1:	ff 71 fc             	pushl  -0x4(%ecx)
  800fa4:	55                   	push   %ebp
  800fa5:	89 e5                	mov    %esp,%ebp
  800fa7:	51                   	push   %ecx
  800fa8:	83 ec 14             	sub    $0x14,%esp
    int n, pid;
    for (n = 0; n < max_child; n ++) {
  800fab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  800fb2:	eb 4b                	jmp    800fff <main+0x69>
        if ((pid = fork()) == 0) {
  800fb4:	e8 2b f2 ff ff       	call   8001e4 <fork>
  800fb9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800fbc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800fc0:	75 1d                	jne    800fdf <main+0x49>
            cprintf("I am child %d\n", n);
  800fc2:	83 ec 08             	sub    $0x8,%esp
  800fc5:	ff 75 f4             	pushl  -0xc(%ebp)
  800fc8:	68 84 13 80 00       	push   $0x801384
  800fcd:	e8 0e f3 ff ff       	call   8002e0 <cprintf>
  800fd2:	83 c4 10             	add    $0x10,%esp
            exit(0);
  800fd5:	83 ec 0c             	sub    $0xc,%esp
  800fd8:	6a 00                	push   $0x0
  800fda:	e8 db f1 ff ff       	call   8001ba <exit>
        }
        assert(pid > 0);
  800fdf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800fe3:	7f 16                	jg     800ffb <main+0x65>
  800fe5:	68 93 13 80 00       	push   $0x801393
  800fea:	68 9b 13 80 00       	push   $0x80139b
  800fef:	6a 0e                	push   $0xe
  800ff1:	68 b0 13 80 00       	push   $0x8013b0
  800ff6:	e8 25 f0 ff ff       	call   800020 <__panic>
    for (n = 0; n < max_child; n ++) {
  800ffb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  800fff:	b8 20 00 00 00       	mov    $0x20,%eax
  801004:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  801007:	7c ab                	jl     800fb4 <main+0x1e>
    }

    if (n > max_child) {
  801009:	b8 20 00 00 00       	mov    $0x20,%eax
  80100e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  801011:	7e 35                	jle    801048 <main+0xb2>
        panic("fork claimed to work %d times!\n", n);
  801013:	ff 75 f4             	pushl  -0xc(%ebp)
  801016:	68 c0 13 80 00       	push   $0x8013c0
  80101b:	6a 12                	push   $0x12
  80101d:	68 b0 13 80 00       	push   $0x8013b0
  801022:	e8 f9 ef ff ff       	call   800020 <__panic>
    }

    for (; n > 0; n --) {
        if (wait() != 0) {
  801027:	e8 c9 f1 ff ff       	call   8001f5 <wait>
  80102c:	85 c0                	test   %eax,%eax
  80102e:	74 14                	je     801044 <main+0xae>
            panic("wait stopped early\n");
  801030:	83 ec 04             	sub    $0x4,%esp
  801033:	68 e0 13 80 00       	push   $0x8013e0
  801038:	6a 17                	push   $0x17
  80103a:	68 b0 13 80 00       	push   $0x8013b0
  80103f:	e8 dc ef ff ff       	call   800020 <__panic>
    for (; n > 0; n --) {
  801044:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  801048:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  80104c:	7f d9                	jg     801027 <main+0x91>
        }
    }

    if (wait() == 0) {
  80104e:	e8 a2 f1 ff ff       	call   8001f5 <wait>
  801053:	85 c0                	test   %eax,%eax
  801055:	75 14                	jne    80106b <main+0xd5>
        panic("wait got too many\n");
  801057:	83 ec 04             	sub    $0x4,%esp
  80105a:	68 f4 13 80 00       	push   $0x8013f4
  80105f:	6a 1c                	push   $0x1c
  801061:	68 b0 13 80 00       	push   $0x8013b0
  801066:	e8 b5 ef ff ff       	call   800020 <__panic>
    }

    cprintf("forktest pass.\n");
  80106b:	83 ec 0c             	sub    $0xc,%esp
  80106e:	68 07 14 80 00       	push   $0x801407
  801073:	e8 68 f2 ff ff       	call   8002e0 <cprintf>
  801078:	83 c4 10             	add    $0x10,%esp
    return 0;
  80107b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801080:	8b 4d fc             	mov    -0x4(%ebp),%ecx
  801083:	c9                   	leave  
  801084:	8d 61 fc             	lea    -0x4(%ecx),%esp
  801087:	c3                   	ret    
