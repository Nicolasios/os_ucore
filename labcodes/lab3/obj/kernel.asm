
bin/kernel：     文件格式 elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 30 12 00       	mov    $0x123000,%eax
    movl %eax, %cr3
c0100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
c0100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
c010000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
c0100010:	83 e0 f3             	and    $0xfffffff3,%eax
    movl %eax, %cr0
c0100013:	0f 22 c0             	mov    %eax,%cr0

    # update eip
    # now, eip = 0x1.....
    leal next, %eax
c0100016:	8d 05 1e 00 10 c0    	lea    0xc010001e,%eax
    # set eip = KERNBASE + 0x1.....
    jmp *%eax
c010001c:	ff e0                	jmp    *%eax

c010001e <next>:
next:

    # unmap va 0 ~ 4M, it's temporary mapping
    xorl %eax, %eax
c010001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
c0100020:	a3 00 30 12 c0       	mov    %eax,0xc0123000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 20 12 c0       	mov    $0xc0122000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
c010002f:	e8 02 00 00 00       	call   c0100036 <kern_init>

c0100034 <spin>:

# should never get here
spin:
    jmp spin
c0100034:	eb fe                	jmp    c0100034 <spin>

c0100036 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
c0100036:	f3 0f 1e fb          	endbr32 
c010003a:	55                   	push   %ebp
c010003b:	89 e5                	mov    %esp,%ebp
c010003d:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
c0100040:	b8 18 61 12 c0       	mov    $0xc0126118,%eax
c0100045:	2d 00 50 12 c0       	sub    $0xc0125000,%eax
c010004a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100055:	00 
c0100056:	c7 04 24 00 50 12 c0 	movl   $0xc0125000,(%esp)
c010005d:	e8 55 7f 00 00       	call   c0107fb7 <memset>

    cons_init();                // init the console
c0100062:	e8 0c 1e 00 00       	call   c0101e73 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100067:	c7 45 f4 c0 88 10 c0 	movl   $0xc01088c0,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100071:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100075:	c7 04 24 dc 88 10 c0 	movl   $0xc01088dc,(%esp)
c010007c:	e8 48 02 00 00       	call   c01002c9 <cprintf>

    print_kerninfo();
c0100081:	e8 06 09 00 00       	call   c010098c <print_kerninfo>

    grade_backtrace();
c0100086:	e8 a4 00 00 00       	call   c010012f <grade_backtrace>

    pmm_init();                 // init physical memory management
c010008b:	e8 d8 39 00 00       	call   c0103a68 <pmm_init>

    pic_init();                 // init interrupt controller
c0100090:	e8 59 1f 00 00       	call   c0101fee <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100095:	e8 fe 20 00 00       	call   c0102198 <idt_init>

    vmm_init();                 // init virtual memory management
c010009a:	e8 8a 4f 00 00       	call   c0105029 <vmm_init>

    ide_init();                 // init ide devices
c010009f:	e8 04 0d 00 00       	call   c0100da8 <ide_init>
    swap_init();                // init swap
c01000a4:	e8 6b 58 00 00       	call   c0105914 <swap_init>

    clock_init();               // init clock interrupt
c01000a9:	e8 0c 15 00 00       	call   c01015ba <clock_init>
    intr_enable();              // enable irq interrupt
c01000ae:	e8 87 20 00 00       	call   c010213a <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
c01000b3:	eb fe                	jmp    c01000b3 <kern_init+0x7d>

c01000b5 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000b5:	f3 0f 1e fb          	endbr32 
c01000b9:	55                   	push   %ebp
c01000ba:	89 e5                	mov    %esp,%ebp
c01000bc:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
c01000bf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01000c6:	00 
c01000c7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000ce:	00 
c01000cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01000d6:	e8 5a 0c 00 00       	call   c0100d35 <mon_backtrace>
}
c01000db:	90                   	nop
c01000dc:	c9                   	leave  
c01000dd:	c3                   	ret    

c01000de <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000de:	f3 0f 1e fb          	endbr32 
c01000e2:	55                   	push   %ebp
c01000e3:	89 e5                	mov    %esp,%ebp
c01000e5:	53                   	push   %ebx
c01000e6:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000e9:	8d 4d 0c             	lea    0xc(%ebp),%ecx
c01000ec:	8b 55 0c             	mov    0xc(%ebp),%edx
c01000ef:	8d 5d 08             	lea    0x8(%ebp),%ebx
c01000f2:	8b 45 08             	mov    0x8(%ebp),%eax
c01000f5:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01000f9:	89 54 24 08          	mov    %edx,0x8(%esp)
c01000fd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0100101:	89 04 24             	mov    %eax,(%esp)
c0100104:	e8 ac ff ff ff       	call   c01000b5 <grade_backtrace2>
}
c0100109:	90                   	nop
c010010a:	83 c4 14             	add    $0x14,%esp
c010010d:	5b                   	pop    %ebx
c010010e:	5d                   	pop    %ebp
c010010f:	c3                   	ret    

c0100110 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c0100110:	f3 0f 1e fb          	endbr32 
c0100114:	55                   	push   %ebp
c0100115:	89 e5                	mov    %esp,%ebp
c0100117:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
c010011a:	8b 45 10             	mov    0x10(%ebp),%eax
c010011d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100121:	8b 45 08             	mov    0x8(%ebp),%eax
c0100124:	89 04 24             	mov    %eax,(%esp)
c0100127:	e8 b2 ff ff ff       	call   c01000de <grade_backtrace1>
}
c010012c:	90                   	nop
c010012d:	c9                   	leave  
c010012e:	c3                   	ret    

c010012f <grade_backtrace>:

void
grade_backtrace(void) {
c010012f:	f3 0f 1e fb          	endbr32 
c0100133:	55                   	push   %ebp
c0100134:	89 e5                	mov    %esp,%ebp
c0100136:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c0100139:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c010013e:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
c0100145:	ff 
c0100146:	89 44 24 04          	mov    %eax,0x4(%esp)
c010014a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100151:	e8 ba ff ff ff       	call   c0100110 <grade_backtrace0>
}
c0100156:	90                   	nop
c0100157:	c9                   	leave  
c0100158:	c3                   	ret    

c0100159 <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c0100159:	f3 0f 1e fb          	endbr32 
c010015d:	55                   	push   %ebp
c010015e:	89 e5                	mov    %esp,%ebp
c0100160:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c0100163:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c0100166:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c0100169:	8c 45 f2             	mov    %es,-0xe(%ebp)
c010016c:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c010016f:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100173:	83 e0 03             	and    $0x3,%eax
c0100176:	89 c2                	mov    %eax,%edx
c0100178:	a1 00 50 12 c0       	mov    0xc0125000,%eax
c010017d:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100181:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100185:	c7 04 24 e1 88 10 c0 	movl   $0xc01088e1,(%esp)
c010018c:	e8 38 01 00 00       	call   c01002c9 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c0100191:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100195:	89 c2                	mov    %eax,%edx
c0100197:	a1 00 50 12 c0       	mov    0xc0125000,%eax
c010019c:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001a0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001a4:	c7 04 24 ef 88 10 c0 	movl   $0xc01088ef,(%esp)
c01001ab:	e8 19 01 00 00       	call   c01002c9 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c01001b0:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c01001b4:	89 c2                	mov    %eax,%edx
c01001b6:	a1 00 50 12 c0       	mov    0xc0125000,%eax
c01001bb:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001bf:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001c3:	c7 04 24 fd 88 10 c0 	movl   $0xc01088fd,(%esp)
c01001ca:	e8 fa 00 00 00       	call   c01002c9 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001cf:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001d3:	89 c2                	mov    %eax,%edx
c01001d5:	a1 00 50 12 c0       	mov    0xc0125000,%eax
c01001da:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001de:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001e2:	c7 04 24 0b 89 10 c0 	movl   $0xc010890b,(%esp)
c01001e9:	e8 db 00 00 00       	call   c01002c9 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001ee:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001f2:	89 c2                	mov    %eax,%edx
c01001f4:	a1 00 50 12 c0       	mov    0xc0125000,%eax
c01001f9:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001fd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100201:	c7 04 24 19 89 10 c0 	movl   $0xc0108919,(%esp)
c0100208:	e8 bc 00 00 00       	call   c01002c9 <cprintf>
    round ++;
c010020d:	a1 00 50 12 c0       	mov    0xc0125000,%eax
c0100212:	40                   	inc    %eax
c0100213:	a3 00 50 12 c0       	mov    %eax,0xc0125000
}
c0100218:	90                   	nop
c0100219:	c9                   	leave  
c010021a:	c3                   	ret    

c010021b <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c010021b:	f3 0f 1e fb          	endbr32 
c010021f:	55                   	push   %ebp
c0100220:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
c0100222:	90                   	nop
c0100223:	5d                   	pop    %ebp
c0100224:	c3                   	ret    

c0100225 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c0100225:	f3 0f 1e fb          	endbr32 
c0100229:	55                   	push   %ebp
c010022a:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
c010022c:	90                   	nop
c010022d:	5d                   	pop    %ebp
c010022e:	c3                   	ret    

c010022f <lab1_switch_test>:

static void
lab1_switch_test(void) {
c010022f:	f3 0f 1e fb          	endbr32 
c0100233:	55                   	push   %ebp
c0100234:	89 e5                	mov    %esp,%ebp
c0100236:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
c0100239:	e8 1b ff ff ff       	call   c0100159 <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c010023e:	c7 04 24 28 89 10 c0 	movl   $0xc0108928,(%esp)
c0100245:	e8 7f 00 00 00       	call   c01002c9 <cprintf>
    lab1_switch_to_user();
c010024a:	e8 cc ff ff ff       	call   c010021b <lab1_switch_to_user>
    lab1_print_cur_status();
c010024f:	e8 05 ff ff ff       	call   c0100159 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c0100254:	c7 04 24 48 89 10 c0 	movl   $0xc0108948,(%esp)
c010025b:	e8 69 00 00 00       	call   c01002c9 <cprintf>
    lab1_switch_to_kernel();
c0100260:	e8 c0 ff ff ff       	call   c0100225 <lab1_switch_to_kernel>
    lab1_print_cur_status();
c0100265:	e8 ef fe ff ff       	call   c0100159 <lab1_print_cur_status>
}
c010026a:	90                   	nop
c010026b:	c9                   	leave  
c010026c:	c3                   	ret    

c010026d <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c010026d:	f3 0f 1e fb          	endbr32 
c0100271:	55                   	push   %ebp
c0100272:	89 e5                	mov    %esp,%ebp
c0100274:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0100277:	8b 45 08             	mov    0x8(%ebp),%eax
c010027a:	89 04 24             	mov    %eax,(%esp)
c010027d:	e8 22 1c 00 00       	call   c0101ea4 <cons_putc>
    (*cnt) ++;
c0100282:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100285:	8b 00                	mov    (%eax),%eax
c0100287:	8d 50 01             	lea    0x1(%eax),%edx
c010028a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010028d:	89 10                	mov    %edx,(%eax)
}
c010028f:	90                   	nop
c0100290:	c9                   	leave  
c0100291:	c3                   	ret    

c0100292 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c0100292:	f3 0f 1e fb          	endbr32 
c0100296:	55                   	push   %ebp
c0100297:	89 e5                	mov    %esp,%ebp
c0100299:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c010029c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c01002a3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01002a6:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01002aa:	8b 45 08             	mov    0x8(%ebp),%eax
c01002ad:	89 44 24 08          	mov    %eax,0x8(%esp)
c01002b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
c01002b4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01002b8:	c7 04 24 6d 02 10 c0 	movl   $0xc010026d,(%esp)
c01002bf:	e8 5f 80 00 00       	call   c0108323 <vprintfmt>
    return cnt;
c01002c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01002c7:	c9                   	leave  
c01002c8:	c3                   	ret    

c01002c9 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c01002c9:	f3 0f 1e fb          	endbr32 
c01002cd:	55                   	push   %ebp
c01002ce:	89 e5                	mov    %esp,%ebp
c01002d0:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c01002d3:	8d 45 0c             	lea    0xc(%ebp),%eax
c01002d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c01002d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002dc:	89 44 24 04          	mov    %eax,0x4(%esp)
c01002e0:	8b 45 08             	mov    0x8(%ebp),%eax
c01002e3:	89 04 24             	mov    %eax,(%esp)
c01002e6:	e8 a7 ff ff ff       	call   c0100292 <vcprintf>
c01002eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c01002ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01002f1:	c9                   	leave  
c01002f2:	c3                   	ret    

c01002f3 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c01002f3:	f3 0f 1e fb          	endbr32 
c01002f7:	55                   	push   %ebp
c01002f8:	89 e5                	mov    %esp,%ebp
c01002fa:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c01002fd:	8b 45 08             	mov    0x8(%ebp),%eax
c0100300:	89 04 24             	mov    %eax,(%esp)
c0100303:	e8 9c 1b 00 00       	call   c0101ea4 <cons_putc>
}
c0100308:	90                   	nop
c0100309:	c9                   	leave  
c010030a:	c3                   	ret    

c010030b <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c010030b:	f3 0f 1e fb          	endbr32 
c010030f:	55                   	push   %ebp
c0100310:	89 e5                	mov    %esp,%ebp
c0100312:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c0100315:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c010031c:	eb 13                	jmp    c0100331 <cputs+0x26>
        cputch(c, &cnt);
c010031e:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0100322:	8d 55 f0             	lea    -0x10(%ebp),%edx
c0100325:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100329:	89 04 24             	mov    %eax,(%esp)
c010032c:	e8 3c ff ff ff       	call   c010026d <cputch>
    while ((c = *str ++) != '\0') {
c0100331:	8b 45 08             	mov    0x8(%ebp),%eax
c0100334:	8d 50 01             	lea    0x1(%eax),%edx
c0100337:	89 55 08             	mov    %edx,0x8(%ebp)
c010033a:	0f b6 00             	movzbl (%eax),%eax
c010033d:	88 45 f7             	mov    %al,-0x9(%ebp)
c0100340:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c0100344:	75 d8                	jne    c010031e <cputs+0x13>
    }
    cputch('\n', &cnt);
c0100346:	8d 45 f0             	lea    -0x10(%ebp),%eax
c0100349:	89 44 24 04          	mov    %eax,0x4(%esp)
c010034d:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c0100354:	e8 14 ff ff ff       	call   c010026d <cputch>
    return cnt;
c0100359:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c010035c:	c9                   	leave  
c010035d:	c3                   	ret    

c010035e <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c010035e:	f3 0f 1e fb          	endbr32 
c0100362:	55                   	push   %ebp
c0100363:	89 e5                	mov    %esp,%ebp
c0100365:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c0100368:	90                   	nop
c0100369:	e8 77 1b 00 00       	call   c0101ee5 <cons_getc>
c010036e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100371:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100375:	74 f2                	je     c0100369 <getchar+0xb>
        /* do nothing */;
    return c;
c0100377:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010037a:	c9                   	leave  
c010037b:	c3                   	ret    

c010037c <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c010037c:	f3 0f 1e fb          	endbr32 
c0100380:	55                   	push   %ebp
c0100381:	89 e5                	mov    %esp,%ebp
c0100383:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c0100386:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010038a:	74 13                	je     c010039f <readline+0x23>
        cprintf("%s", prompt);
c010038c:	8b 45 08             	mov    0x8(%ebp),%eax
c010038f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100393:	c7 04 24 67 89 10 c0 	movl   $0xc0108967,(%esp)
c010039a:	e8 2a ff ff ff       	call   c01002c9 <cprintf>
    }
    int i = 0, c;
c010039f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c01003a6:	e8 b3 ff ff ff       	call   c010035e <getchar>
c01003ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c01003ae:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01003b2:	79 07                	jns    c01003bb <readline+0x3f>
            return NULL;
c01003b4:	b8 00 00 00 00       	mov    $0x0,%eax
c01003b9:	eb 78                	jmp    c0100433 <readline+0xb7>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c01003bb:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c01003bf:	7e 28                	jle    c01003e9 <readline+0x6d>
c01003c1:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c01003c8:	7f 1f                	jg     c01003e9 <readline+0x6d>
            cputchar(c);
c01003ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003cd:	89 04 24             	mov    %eax,(%esp)
c01003d0:	e8 1e ff ff ff       	call   c01002f3 <cputchar>
            buf[i ++] = c;
c01003d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01003d8:	8d 50 01             	lea    0x1(%eax),%edx
c01003db:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01003de:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01003e1:	88 90 20 50 12 c0    	mov    %dl,-0x3fedafe0(%eax)
c01003e7:	eb 45                	jmp    c010042e <readline+0xb2>
        }
        else if (c == '\b' && i > 0) {
c01003e9:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c01003ed:	75 16                	jne    c0100405 <readline+0x89>
c01003ef:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01003f3:	7e 10                	jle    c0100405 <readline+0x89>
            cputchar(c);
c01003f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003f8:	89 04 24             	mov    %eax,(%esp)
c01003fb:	e8 f3 fe ff ff       	call   c01002f3 <cputchar>
            i --;
c0100400:	ff 4d f4             	decl   -0xc(%ebp)
c0100403:	eb 29                	jmp    c010042e <readline+0xb2>
        }
        else if (c == '\n' || c == '\r') {
c0100405:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c0100409:	74 06                	je     c0100411 <readline+0x95>
c010040b:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c010040f:	75 95                	jne    c01003a6 <readline+0x2a>
            cputchar(c);
c0100411:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100414:	89 04 24             	mov    %eax,(%esp)
c0100417:	e8 d7 fe ff ff       	call   c01002f3 <cputchar>
            buf[i] = '\0';
c010041c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010041f:	05 20 50 12 c0       	add    $0xc0125020,%eax
c0100424:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c0100427:	b8 20 50 12 c0       	mov    $0xc0125020,%eax
c010042c:	eb 05                	jmp    c0100433 <readline+0xb7>
        c = getchar();
c010042e:	e9 73 ff ff ff       	jmp    c01003a6 <readline+0x2a>
        }
    }
}
c0100433:	c9                   	leave  
c0100434:	c3                   	ret    

c0100435 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c0100435:	f3 0f 1e fb          	endbr32 
c0100439:	55                   	push   %ebp
c010043a:	89 e5                	mov    %esp,%ebp
c010043c:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c010043f:	a1 20 54 12 c0       	mov    0xc0125420,%eax
c0100444:	85 c0                	test   %eax,%eax
c0100446:	75 5b                	jne    c01004a3 <__panic+0x6e>
        goto panic_dead;
    }
    is_panic = 1;
c0100448:	c7 05 20 54 12 c0 01 	movl   $0x1,0xc0125420
c010044f:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0100452:	8d 45 14             	lea    0x14(%ebp),%eax
c0100455:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0100458:	8b 45 0c             	mov    0xc(%ebp),%eax
c010045b:	89 44 24 08          	mov    %eax,0x8(%esp)
c010045f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100462:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100466:	c7 04 24 6a 89 10 c0 	movl   $0xc010896a,(%esp)
c010046d:	e8 57 fe ff ff       	call   c01002c9 <cprintf>
    vcprintf(fmt, ap);
c0100472:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100475:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100479:	8b 45 10             	mov    0x10(%ebp),%eax
c010047c:	89 04 24             	mov    %eax,(%esp)
c010047f:	e8 0e fe ff ff       	call   c0100292 <vcprintf>
    cprintf("\n");
c0100484:	c7 04 24 86 89 10 c0 	movl   $0xc0108986,(%esp)
c010048b:	e8 39 fe ff ff       	call   c01002c9 <cprintf>
    
    cprintf("stack trackback:\n");
c0100490:	c7 04 24 88 89 10 c0 	movl   $0xc0108988,(%esp)
c0100497:	e8 2d fe ff ff       	call   c01002c9 <cprintf>
    print_stackframe();
c010049c:	e8 3d 06 00 00       	call   c0100ade <print_stackframe>
c01004a1:	eb 01                	jmp    c01004a4 <__panic+0x6f>
        goto panic_dead;
c01004a3:	90                   	nop
    
    va_end(ap);

panic_dead:
    intr_disable();
c01004a4:	e8 9d 1c 00 00       	call   c0102146 <intr_disable>
    while (1) {
        kmonitor(NULL);
c01004a9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01004b0:	e8 a7 07 00 00       	call   c0100c5c <kmonitor>
c01004b5:	eb f2                	jmp    c01004a9 <__panic+0x74>

c01004b7 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c01004b7:	f3 0f 1e fb          	endbr32 
c01004bb:	55                   	push   %ebp
c01004bc:	89 e5                	mov    %esp,%ebp
c01004be:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c01004c1:	8d 45 14             	lea    0x14(%ebp),%eax
c01004c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c01004c7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004ca:	89 44 24 08          	mov    %eax,0x8(%esp)
c01004ce:	8b 45 08             	mov    0x8(%ebp),%eax
c01004d1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01004d5:	c7 04 24 9a 89 10 c0 	movl   $0xc010899a,(%esp)
c01004dc:	e8 e8 fd ff ff       	call   c01002c9 <cprintf>
    vcprintf(fmt, ap);
c01004e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01004e4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01004e8:	8b 45 10             	mov    0x10(%ebp),%eax
c01004eb:	89 04 24             	mov    %eax,(%esp)
c01004ee:	e8 9f fd ff ff       	call   c0100292 <vcprintf>
    cprintf("\n");
c01004f3:	c7 04 24 86 89 10 c0 	movl   $0xc0108986,(%esp)
c01004fa:	e8 ca fd ff ff       	call   c01002c9 <cprintf>
    va_end(ap);
}
c01004ff:	90                   	nop
c0100500:	c9                   	leave  
c0100501:	c3                   	ret    

c0100502 <is_kernel_panic>:

bool
is_kernel_panic(void) {
c0100502:	f3 0f 1e fb          	endbr32 
c0100506:	55                   	push   %ebp
c0100507:	89 e5                	mov    %esp,%ebp
    return is_panic;
c0100509:	a1 20 54 12 c0       	mov    0xc0125420,%eax
}
c010050e:	5d                   	pop    %ebp
c010050f:	c3                   	ret    

c0100510 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c0100510:	f3 0f 1e fb          	endbr32 
c0100514:	55                   	push   %ebp
c0100515:	89 e5                	mov    %esp,%ebp
c0100517:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c010051a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010051d:	8b 00                	mov    (%eax),%eax
c010051f:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100522:	8b 45 10             	mov    0x10(%ebp),%eax
c0100525:	8b 00                	mov    (%eax),%eax
c0100527:	89 45 f8             	mov    %eax,-0x8(%ebp)
c010052a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c0100531:	e9 ca 00 00 00       	jmp    c0100600 <stab_binsearch+0xf0>
        int true_m = (l + r) / 2, m = true_m;
c0100536:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100539:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010053c:	01 d0                	add    %edx,%eax
c010053e:	89 c2                	mov    %eax,%edx
c0100540:	c1 ea 1f             	shr    $0x1f,%edx
c0100543:	01 d0                	add    %edx,%eax
c0100545:	d1 f8                	sar    %eax
c0100547:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010054a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010054d:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c0100550:	eb 03                	jmp    c0100555 <stab_binsearch+0x45>
            m --;
c0100552:	ff 4d f0             	decl   -0x10(%ebp)
        while (m >= l && stabs[m].n_type != type) {
c0100555:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100558:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010055b:	7c 1f                	jl     c010057c <stab_binsearch+0x6c>
c010055d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100560:	89 d0                	mov    %edx,%eax
c0100562:	01 c0                	add    %eax,%eax
c0100564:	01 d0                	add    %edx,%eax
c0100566:	c1 e0 02             	shl    $0x2,%eax
c0100569:	89 c2                	mov    %eax,%edx
c010056b:	8b 45 08             	mov    0x8(%ebp),%eax
c010056e:	01 d0                	add    %edx,%eax
c0100570:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100574:	0f b6 c0             	movzbl %al,%eax
c0100577:	39 45 14             	cmp    %eax,0x14(%ebp)
c010057a:	75 d6                	jne    c0100552 <stab_binsearch+0x42>
        }
        if (m < l) {    // no match in [l, m]
c010057c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010057f:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100582:	7d 09                	jge    c010058d <stab_binsearch+0x7d>
            l = true_m + 1;
c0100584:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100587:	40                   	inc    %eax
c0100588:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c010058b:	eb 73                	jmp    c0100600 <stab_binsearch+0xf0>
        }

        // actual binary search
        any_matches = 1;
c010058d:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c0100594:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100597:	89 d0                	mov    %edx,%eax
c0100599:	01 c0                	add    %eax,%eax
c010059b:	01 d0                	add    %edx,%eax
c010059d:	c1 e0 02             	shl    $0x2,%eax
c01005a0:	89 c2                	mov    %eax,%edx
c01005a2:	8b 45 08             	mov    0x8(%ebp),%eax
c01005a5:	01 d0                	add    %edx,%eax
c01005a7:	8b 40 08             	mov    0x8(%eax),%eax
c01005aa:	39 45 18             	cmp    %eax,0x18(%ebp)
c01005ad:	76 11                	jbe    c01005c0 <stab_binsearch+0xb0>
            *region_left = m;
c01005af:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005b2:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005b5:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c01005b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01005ba:	40                   	inc    %eax
c01005bb:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01005be:	eb 40                	jmp    c0100600 <stab_binsearch+0xf0>
        } else if (stabs[m].n_value > addr) {
c01005c0:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005c3:	89 d0                	mov    %edx,%eax
c01005c5:	01 c0                	add    %eax,%eax
c01005c7:	01 d0                	add    %edx,%eax
c01005c9:	c1 e0 02             	shl    $0x2,%eax
c01005cc:	89 c2                	mov    %eax,%edx
c01005ce:	8b 45 08             	mov    0x8(%ebp),%eax
c01005d1:	01 d0                	add    %edx,%eax
c01005d3:	8b 40 08             	mov    0x8(%eax),%eax
c01005d6:	39 45 18             	cmp    %eax,0x18(%ebp)
c01005d9:	73 14                	jae    c01005ef <stab_binsearch+0xdf>
            *region_right = m - 1;
c01005db:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005de:	8d 50 ff             	lea    -0x1(%eax),%edx
c01005e1:	8b 45 10             	mov    0x10(%ebp),%eax
c01005e4:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c01005e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005e9:	48                   	dec    %eax
c01005ea:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01005ed:	eb 11                	jmp    c0100600 <stab_binsearch+0xf0>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c01005ef:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005f2:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005f5:	89 10                	mov    %edx,(%eax)
            l = m;
c01005f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005fa:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c01005fd:	ff 45 18             	incl   0x18(%ebp)
    while (l <= r) {
c0100600:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100603:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c0100606:	0f 8e 2a ff ff ff    	jle    c0100536 <stab_binsearch+0x26>
        }
    }

    if (!any_matches) {
c010060c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100610:	75 0f                	jne    c0100621 <stab_binsearch+0x111>
        *region_right = *region_left - 1;
c0100612:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100615:	8b 00                	mov    (%eax),%eax
c0100617:	8d 50 ff             	lea    -0x1(%eax),%edx
c010061a:	8b 45 10             	mov    0x10(%ebp),%eax
c010061d:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
c010061f:	eb 3e                	jmp    c010065f <stab_binsearch+0x14f>
        l = *region_right;
c0100621:	8b 45 10             	mov    0x10(%ebp),%eax
c0100624:	8b 00                	mov    (%eax),%eax
c0100626:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c0100629:	eb 03                	jmp    c010062e <stab_binsearch+0x11e>
c010062b:	ff 4d fc             	decl   -0x4(%ebp)
c010062e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100631:	8b 00                	mov    (%eax),%eax
c0100633:	39 45 fc             	cmp    %eax,-0x4(%ebp)
c0100636:	7e 1f                	jle    c0100657 <stab_binsearch+0x147>
c0100638:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010063b:	89 d0                	mov    %edx,%eax
c010063d:	01 c0                	add    %eax,%eax
c010063f:	01 d0                	add    %edx,%eax
c0100641:	c1 e0 02             	shl    $0x2,%eax
c0100644:	89 c2                	mov    %eax,%edx
c0100646:	8b 45 08             	mov    0x8(%ebp),%eax
c0100649:	01 d0                	add    %edx,%eax
c010064b:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010064f:	0f b6 c0             	movzbl %al,%eax
c0100652:	39 45 14             	cmp    %eax,0x14(%ebp)
c0100655:	75 d4                	jne    c010062b <stab_binsearch+0x11b>
        *region_left = l;
c0100657:	8b 45 0c             	mov    0xc(%ebp),%eax
c010065a:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010065d:	89 10                	mov    %edx,(%eax)
}
c010065f:	90                   	nop
c0100660:	c9                   	leave  
c0100661:	c3                   	ret    

c0100662 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c0100662:	f3 0f 1e fb          	endbr32 
c0100666:	55                   	push   %ebp
c0100667:	89 e5                	mov    %esp,%ebp
c0100669:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c010066c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010066f:	c7 00 b8 89 10 c0    	movl   $0xc01089b8,(%eax)
    info->eip_line = 0;
c0100675:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100678:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c010067f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100682:	c7 40 08 b8 89 10 c0 	movl   $0xc01089b8,0x8(%eax)
    info->eip_fn_namelen = 9;
c0100689:	8b 45 0c             	mov    0xc(%ebp),%eax
c010068c:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c0100693:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100696:	8b 55 08             	mov    0x8(%ebp),%edx
c0100699:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c010069c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010069f:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c01006a6:	c7 45 f4 84 a8 10 c0 	movl   $0xc010a884,-0xc(%ebp)
    stab_end = __STAB_END__;
c01006ad:	c7 45 f0 50 ba 11 c0 	movl   $0xc011ba50,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c01006b4:	c7 45 ec 51 ba 11 c0 	movl   $0xc011ba51,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c01006bb:	c7 45 e8 ad f3 11 c0 	movl   $0xc011f3ad,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c01006c2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01006c5:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01006c8:	76 0b                	jbe    c01006d5 <debuginfo_eip+0x73>
c01006ca:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01006cd:	48                   	dec    %eax
c01006ce:	0f b6 00             	movzbl (%eax),%eax
c01006d1:	84 c0                	test   %al,%al
c01006d3:	74 0a                	je     c01006df <debuginfo_eip+0x7d>
        return -1;
c01006d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01006da:	e9 ab 02 00 00       	jmp    c010098a <debuginfo_eip+0x328>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c01006df:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c01006e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01006e9:	2b 45 f4             	sub    -0xc(%ebp),%eax
c01006ec:	c1 f8 02             	sar    $0x2,%eax
c01006ef:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c01006f5:	48                   	dec    %eax
c01006f6:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c01006f9:	8b 45 08             	mov    0x8(%ebp),%eax
c01006fc:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100700:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c0100707:	00 
c0100708:	8d 45 e0             	lea    -0x20(%ebp),%eax
c010070b:	89 44 24 08          	mov    %eax,0x8(%esp)
c010070f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c0100712:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100716:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100719:	89 04 24             	mov    %eax,(%esp)
c010071c:	e8 ef fd ff ff       	call   c0100510 <stab_binsearch>
    if (lfile == 0)
c0100721:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100724:	85 c0                	test   %eax,%eax
c0100726:	75 0a                	jne    c0100732 <debuginfo_eip+0xd0>
        return -1;
c0100728:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010072d:	e9 58 02 00 00       	jmp    c010098a <debuginfo_eip+0x328>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c0100732:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100735:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0100738:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010073b:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c010073e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100741:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100745:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c010074c:	00 
c010074d:	8d 45 d8             	lea    -0x28(%ebp),%eax
c0100750:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100754:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100757:	89 44 24 04          	mov    %eax,0x4(%esp)
c010075b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010075e:	89 04 24             	mov    %eax,(%esp)
c0100761:	e8 aa fd ff ff       	call   c0100510 <stab_binsearch>

    if (lfun <= rfun) {
c0100766:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100769:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010076c:	39 c2                	cmp    %eax,%edx
c010076e:	7f 78                	jg     c01007e8 <debuginfo_eip+0x186>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c0100770:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100773:	89 c2                	mov    %eax,%edx
c0100775:	89 d0                	mov    %edx,%eax
c0100777:	01 c0                	add    %eax,%eax
c0100779:	01 d0                	add    %edx,%eax
c010077b:	c1 e0 02             	shl    $0x2,%eax
c010077e:	89 c2                	mov    %eax,%edx
c0100780:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100783:	01 d0                	add    %edx,%eax
c0100785:	8b 10                	mov    (%eax),%edx
c0100787:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010078a:	2b 45 ec             	sub    -0x14(%ebp),%eax
c010078d:	39 c2                	cmp    %eax,%edx
c010078f:	73 22                	jae    c01007b3 <debuginfo_eip+0x151>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c0100791:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100794:	89 c2                	mov    %eax,%edx
c0100796:	89 d0                	mov    %edx,%eax
c0100798:	01 c0                	add    %eax,%eax
c010079a:	01 d0                	add    %edx,%eax
c010079c:	c1 e0 02             	shl    $0x2,%eax
c010079f:	89 c2                	mov    %eax,%edx
c01007a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007a4:	01 d0                	add    %edx,%eax
c01007a6:	8b 10                	mov    (%eax),%edx
c01007a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01007ab:	01 c2                	add    %eax,%edx
c01007ad:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007b0:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c01007b3:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01007b6:	89 c2                	mov    %eax,%edx
c01007b8:	89 d0                	mov    %edx,%eax
c01007ba:	01 c0                	add    %eax,%eax
c01007bc:	01 d0                	add    %edx,%eax
c01007be:	c1 e0 02             	shl    $0x2,%eax
c01007c1:	89 c2                	mov    %eax,%edx
c01007c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007c6:	01 d0                	add    %edx,%eax
c01007c8:	8b 50 08             	mov    0x8(%eax),%edx
c01007cb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007ce:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c01007d1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007d4:	8b 40 10             	mov    0x10(%eax),%eax
c01007d7:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c01007da:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01007dd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c01007e0:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01007e3:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01007e6:	eb 15                	jmp    c01007fd <debuginfo_eip+0x19b>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c01007e8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007eb:	8b 55 08             	mov    0x8(%ebp),%edx
c01007ee:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c01007f1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01007f4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c01007f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01007fa:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c01007fd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100800:	8b 40 08             	mov    0x8(%eax),%eax
c0100803:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c010080a:	00 
c010080b:	89 04 24             	mov    %eax,(%esp)
c010080e:	e8 18 76 00 00       	call   c0107e2b <strfind>
c0100813:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100816:	8b 52 08             	mov    0x8(%edx),%edx
c0100819:	29 d0                	sub    %edx,%eax
c010081b:	89 c2                	mov    %eax,%edx
c010081d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100820:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c0100823:	8b 45 08             	mov    0x8(%ebp),%eax
c0100826:	89 44 24 10          	mov    %eax,0x10(%esp)
c010082a:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c0100831:	00 
c0100832:	8d 45 d0             	lea    -0x30(%ebp),%eax
c0100835:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100839:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c010083c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100840:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100843:	89 04 24             	mov    %eax,(%esp)
c0100846:	e8 c5 fc ff ff       	call   c0100510 <stab_binsearch>
    if (lline <= rline) {
c010084b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010084e:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100851:	39 c2                	cmp    %eax,%edx
c0100853:	7f 23                	jg     c0100878 <debuginfo_eip+0x216>
        info->eip_line = stabs[rline].n_desc;
c0100855:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100858:	89 c2                	mov    %eax,%edx
c010085a:	89 d0                	mov    %edx,%eax
c010085c:	01 c0                	add    %eax,%eax
c010085e:	01 d0                	add    %edx,%eax
c0100860:	c1 e0 02             	shl    $0x2,%eax
c0100863:	89 c2                	mov    %eax,%edx
c0100865:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100868:	01 d0                	add    %edx,%eax
c010086a:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c010086e:	89 c2                	mov    %eax,%edx
c0100870:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100873:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100876:	eb 11                	jmp    c0100889 <debuginfo_eip+0x227>
        return -1;
c0100878:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010087d:	e9 08 01 00 00       	jmp    c010098a <debuginfo_eip+0x328>
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c0100882:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100885:	48                   	dec    %eax
c0100886:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while (lline >= lfile
c0100889:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010088c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010088f:	39 c2                	cmp    %eax,%edx
c0100891:	7c 56                	jl     c01008e9 <debuginfo_eip+0x287>
           && stabs[lline].n_type != N_SOL
c0100893:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100896:	89 c2                	mov    %eax,%edx
c0100898:	89 d0                	mov    %edx,%eax
c010089a:	01 c0                	add    %eax,%eax
c010089c:	01 d0                	add    %edx,%eax
c010089e:	c1 e0 02             	shl    $0x2,%eax
c01008a1:	89 c2                	mov    %eax,%edx
c01008a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008a6:	01 d0                	add    %edx,%eax
c01008a8:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01008ac:	3c 84                	cmp    $0x84,%al
c01008ae:	74 39                	je     c01008e9 <debuginfo_eip+0x287>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c01008b0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008b3:	89 c2                	mov    %eax,%edx
c01008b5:	89 d0                	mov    %edx,%eax
c01008b7:	01 c0                	add    %eax,%eax
c01008b9:	01 d0                	add    %edx,%eax
c01008bb:	c1 e0 02             	shl    $0x2,%eax
c01008be:	89 c2                	mov    %eax,%edx
c01008c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008c3:	01 d0                	add    %edx,%eax
c01008c5:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01008c9:	3c 64                	cmp    $0x64,%al
c01008cb:	75 b5                	jne    c0100882 <debuginfo_eip+0x220>
c01008cd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008d0:	89 c2                	mov    %eax,%edx
c01008d2:	89 d0                	mov    %edx,%eax
c01008d4:	01 c0                	add    %eax,%eax
c01008d6:	01 d0                	add    %edx,%eax
c01008d8:	c1 e0 02             	shl    $0x2,%eax
c01008db:	89 c2                	mov    %eax,%edx
c01008dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008e0:	01 d0                	add    %edx,%eax
c01008e2:	8b 40 08             	mov    0x8(%eax),%eax
c01008e5:	85 c0                	test   %eax,%eax
c01008e7:	74 99                	je     c0100882 <debuginfo_eip+0x220>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c01008e9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01008ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01008ef:	39 c2                	cmp    %eax,%edx
c01008f1:	7c 42                	jl     c0100935 <debuginfo_eip+0x2d3>
c01008f3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008f6:	89 c2                	mov    %eax,%edx
c01008f8:	89 d0                	mov    %edx,%eax
c01008fa:	01 c0                	add    %eax,%eax
c01008fc:	01 d0                	add    %edx,%eax
c01008fe:	c1 e0 02             	shl    $0x2,%eax
c0100901:	89 c2                	mov    %eax,%edx
c0100903:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100906:	01 d0                	add    %edx,%eax
c0100908:	8b 10                	mov    (%eax),%edx
c010090a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010090d:	2b 45 ec             	sub    -0x14(%ebp),%eax
c0100910:	39 c2                	cmp    %eax,%edx
c0100912:	73 21                	jae    c0100935 <debuginfo_eip+0x2d3>
        info->eip_file = stabstr + stabs[lline].n_strx;
c0100914:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100917:	89 c2                	mov    %eax,%edx
c0100919:	89 d0                	mov    %edx,%eax
c010091b:	01 c0                	add    %eax,%eax
c010091d:	01 d0                	add    %edx,%eax
c010091f:	c1 e0 02             	shl    $0x2,%eax
c0100922:	89 c2                	mov    %eax,%edx
c0100924:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100927:	01 d0                	add    %edx,%eax
c0100929:	8b 10                	mov    (%eax),%edx
c010092b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010092e:	01 c2                	add    %eax,%edx
c0100930:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100933:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c0100935:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100938:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010093b:	39 c2                	cmp    %eax,%edx
c010093d:	7d 46                	jge    c0100985 <debuginfo_eip+0x323>
        for (lline = lfun + 1;
c010093f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100942:	40                   	inc    %eax
c0100943:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0100946:	eb 16                	jmp    c010095e <debuginfo_eip+0x2fc>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c0100948:	8b 45 0c             	mov    0xc(%ebp),%eax
c010094b:	8b 40 14             	mov    0x14(%eax),%eax
c010094e:	8d 50 01             	lea    0x1(%eax),%edx
c0100951:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100954:	89 50 14             	mov    %edx,0x14(%eax)
             lline ++) {
c0100957:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010095a:	40                   	inc    %eax
c010095b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
c010095e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100961:	8b 45 d8             	mov    -0x28(%ebp),%eax
        for (lline = lfun + 1;
c0100964:	39 c2                	cmp    %eax,%edx
c0100966:	7d 1d                	jge    c0100985 <debuginfo_eip+0x323>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100968:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010096b:	89 c2                	mov    %eax,%edx
c010096d:	89 d0                	mov    %edx,%eax
c010096f:	01 c0                	add    %eax,%eax
c0100971:	01 d0                	add    %edx,%eax
c0100973:	c1 e0 02             	shl    $0x2,%eax
c0100976:	89 c2                	mov    %eax,%edx
c0100978:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010097b:	01 d0                	add    %edx,%eax
c010097d:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100981:	3c a0                	cmp    $0xa0,%al
c0100983:	74 c3                	je     c0100948 <debuginfo_eip+0x2e6>
        }
    }
    return 0;
c0100985:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010098a:	c9                   	leave  
c010098b:	c3                   	ret    

c010098c <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c010098c:	f3 0f 1e fb          	endbr32 
c0100990:	55                   	push   %ebp
c0100991:	89 e5                	mov    %esp,%ebp
c0100993:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c0100996:	c7 04 24 c2 89 10 c0 	movl   $0xc01089c2,(%esp)
c010099d:	e8 27 f9 ff ff       	call   c01002c9 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c01009a2:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c01009a9:	c0 
c01009aa:	c7 04 24 db 89 10 c0 	movl   $0xc01089db,(%esp)
c01009b1:	e8 13 f9 ff ff       	call   c01002c9 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c01009b6:	c7 44 24 04 bb 88 10 	movl   $0xc01088bb,0x4(%esp)
c01009bd:	c0 
c01009be:	c7 04 24 f3 89 10 c0 	movl   $0xc01089f3,(%esp)
c01009c5:	e8 ff f8 ff ff       	call   c01002c9 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c01009ca:	c7 44 24 04 00 50 12 	movl   $0xc0125000,0x4(%esp)
c01009d1:	c0 
c01009d2:	c7 04 24 0b 8a 10 c0 	movl   $0xc0108a0b,(%esp)
c01009d9:	e8 eb f8 ff ff       	call   c01002c9 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c01009de:	c7 44 24 04 18 61 12 	movl   $0xc0126118,0x4(%esp)
c01009e5:	c0 
c01009e6:	c7 04 24 23 8a 10 c0 	movl   $0xc0108a23,(%esp)
c01009ed:	e8 d7 f8 ff ff       	call   c01002c9 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c01009f2:	b8 18 61 12 c0       	mov    $0xc0126118,%eax
c01009f7:	2d 36 00 10 c0       	sub    $0xc0100036,%eax
c01009fc:	05 ff 03 00 00       	add    $0x3ff,%eax
c0100a01:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c0100a07:	85 c0                	test   %eax,%eax
c0100a09:	0f 48 c2             	cmovs  %edx,%eax
c0100a0c:	c1 f8 0a             	sar    $0xa,%eax
c0100a0f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a13:	c7 04 24 3c 8a 10 c0 	movl   $0xc0108a3c,(%esp)
c0100a1a:	e8 aa f8 ff ff       	call   c01002c9 <cprintf>
}
c0100a1f:	90                   	nop
c0100a20:	c9                   	leave  
c0100a21:	c3                   	ret    

c0100a22 <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c0100a22:	f3 0f 1e fb          	endbr32 
c0100a26:	55                   	push   %ebp
c0100a27:	89 e5                	mov    %esp,%ebp
c0100a29:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c0100a2f:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100a32:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a36:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a39:	89 04 24             	mov    %eax,(%esp)
c0100a3c:	e8 21 fc ff ff       	call   c0100662 <debuginfo_eip>
c0100a41:	85 c0                	test   %eax,%eax
c0100a43:	74 15                	je     c0100a5a <print_debuginfo+0x38>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c0100a45:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a48:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a4c:	c7 04 24 66 8a 10 c0 	movl   $0xc0108a66,(%esp)
c0100a53:	e8 71 f8 ff ff       	call   c01002c9 <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
c0100a58:	eb 6c                	jmp    c0100ac6 <print_debuginfo+0xa4>
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a5a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100a61:	eb 1b                	jmp    c0100a7e <print_debuginfo+0x5c>
            fnname[j] = info.eip_fn_name[j];
c0100a63:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100a66:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a69:	01 d0                	add    %edx,%eax
c0100a6b:	0f b6 10             	movzbl (%eax),%edx
c0100a6e:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a74:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a77:	01 c8                	add    %ecx,%eax
c0100a79:	88 10                	mov    %dl,(%eax)
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a7b:	ff 45 f4             	incl   -0xc(%ebp)
c0100a7e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a81:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0100a84:	7c dd                	jl     c0100a63 <print_debuginfo+0x41>
        fnname[j] = '\0';
c0100a86:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100a8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a8f:	01 d0                	add    %edx,%eax
c0100a91:	c6 00 00             	movb   $0x0,(%eax)
                fnname, eip - info.eip_fn_addr);
c0100a94:	8b 45 ec             	mov    -0x14(%ebp),%eax
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0100a97:	8b 55 08             	mov    0x8(%ebp),%edx
c0100a9a:	89 d1                	mov    %edx,%ecx
c0100a9c:	29 c1                	sub    %eax,%ecx
c0100a9e:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0100aa1:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100aa4:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0100aa8:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100aae:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0100ab2:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100ab6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100aba:	c7 04 24 82 8a 10 c0 	movl   $0xc0108a82,(%esp)
c0100ac1:	e8 03 f8 ff ff       	call   c01002c9 <cprintf>
}
c0100ac6:	90                   	nop
c0100ac7:	c9                   	leave  
c0100ac8:	c3                   	ret    

c0100ac9 <read_eip>:

static __noinline uint32_t
read_eip(void) {
c0100ac9:	f3 0f 1e fb          	endbr32 
c0100acd:	55                   	push   %ebp
c0100ace:	89 e5                	mov    %esp,%ebp
c0100ad0:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c0100ad3:	8b 45 04             	mov    0x4(%ebp),%eax
c0100ad6:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c0100ad9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0100adc:	c9                   	leave  
c0100add:	c3                   	ret    

c0100ade <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c0100ade:	f3 0f 1e fb          	endbr32 
c0100ae2:	55                   	push   %ebp
c0100ae3:	89 e5                	mov    %esp,%ebp
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
}
c0100ae5:	90                   	nop
c0100ae6:	5d                   	pop    %ebp
c0100ae7:	c3                   	ret    

c0100ae8 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100ae8:	f3 0f 1e fb          	endbr32 
c0100aec:	55                   	push   %ebp
c0100aed:	89 e5                	mov    %esp,%ebp
c0100aef:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100af2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100af9:	eb 0c                	jmp    c0100b07 <parse+0x1f>
            *buf ++ = '\0';
c0100afb:	8b 45 08             	mov    0x8(%ebp),%eax
c0100afe:	8d 50 01             	lea    0x1(%eax),%edx
c0100b01:	89 55 08             	mov    %edx,0x8(%ebp)
c0100b04:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b07:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b0a:	0f b6 00             	movzbl (%eax),%eax
c0100b0d:	84 c0                	test   %al,%al
c0100b0f:	74 1d                	je     c0100b2e <parse+0x46>
c0100b11:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b14:	0f b6 00             	movzbl (%eax),%eax
c0100b17:	0f be c0             	movsbl %al,%eax
c0100b1a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b1e:	c7 04 24 14 8b 10 c0 	movl   $0xc0108b14,(%esp)
c0100b25:	e8 cb 72 00 00       	call   c0107df5 <strchr>
c0100b2a:	85 c0                	test   %eax,%eax
c0100b2c:	75 cd                	jne    c0100afb <parse+0x13>
        }
        if (*buf == '\0') {
c0100b2e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b31:	0f b6 00             	movzbl (%eax),%eax
c0100b34:	84 c0                	test   %al,%al
c0100b36:	74 65                	je     c0100b9d <parse+0xb5>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100b38:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100b3c:	75 14                	jne    c0100b52 <parse+0x6a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100b3e:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100b45:	00 
c0100b46:	c7 04 24 19 8b 10 c0 	movl   $0xc0108b19,(%esp)
c0100b4d:	e8 77 f7 ff ff       	call   c01002c9 <cprintf>
        }
        argv[argc ++] = buf;
c0100b52:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b55:	8d 50 01             	lea    0x1(%eax),%edx
c0100b58:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100b5b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100b62:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100b65:	01 c2                	add    %eax,%edx
c0100b67:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b6a:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100b6c:	eb 03                	jmp    c0100b71 <parse+0x89>
            buf ++;
c0100b6e:	ff 45 08             	incl   0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100b71:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b74:	0f b6 00             	movzbl (%eax),%eax
c0100b77:	84 c0                	test   %al,%al
c0100b79:	74 8c                	je     c0100b07 <parse+0x1f>
c0100b7b:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b7e:	0f b6 00             	movzbl (%eax),%eax
c0100b81:	0f be c0             	movsbl %al,%eax
c0100b84:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b88:	c7 04 24 14 8b 10 c0 	movl   $0xc0108b14,(%esp)
c0100b8f:	e8 61 72 00 00       	call   c0107df5 <strchr>
c0100b94:	85 c0                	test   %eax,%eax
c0100b96:	74 d6                	je     c0100b6e <parse+0x86>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b98:	e9 6a ff ff ff       	jmp    c0100b07 <parse+0x1f>
            break;
c0100b9d:	90                   	nop
        }
    }
    return argc;
c0100b9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100ba1:	c9                   	leave  
c0100ba2:	c3                   	ret    

c0100ba3 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100ba3:	f3 0f 1e fb          	endbr32 
c0100ba7:	55                   	push   %ebp
c0100ba8:	89 e5                	mov    %esp,%ebp
c0100baa:	53                   	push   %ebx
c0100bab:	83 ec 64             	sub    $0x64,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100bae:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100bb1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100bb5:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bb8:	89 04 24             	mov    %eax,(%esp)
c0100bbb:	e8 28 ff ff ff       	call   c0100ae8 <parse>
c0100bc0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100bc3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100bc7:	75 0a                	jne    c0100bd3 <runcmd+0x30>
        return 0;
c0100bc9:	b8 00 00 00 00       	mov    $0x0,%eax
c0100bce:	e9 83 00 00 00       	jmp    c0100c56 <runcmd+0xb3>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100bd3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100bda:	eb 5a                	jmp    c0100c36 <runcmd+0x93>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100bdc:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0100bdf:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100be2:	89 d0                	mov    %edx,%eax
c0100be4:	01 c0                	add    %eax,%eax
c0100be6:	01 d0                	add    %edx,%eax
c0100be8:	c1 e0 02             	shl    $0x2,%eax
c0100beb:	05 00 20 12 c0       	add    $0xc0122000,%eax
c0100bf0:	8b 00                	mov    (%eax),%eax
c0100bf2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0100bf6:	89 04 24             	mov    %eax,(%esp)
c0100bf9:	e8 53 71 00 00       	call   c0107d51 <strcmp>
c0100bfe:	85 c0                	test   %eax,%eax
c0100c00:	75 31                	jne    c0100c33 <runcmd+0x90>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100c02:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c05:	89 d0                	mov    %edx,%eax
c0100c07:	01 c0                	add    %eax,%eax
c0100c09:	01 d0                	add    %edx,%eax
c0100c0b:	c1 e0 02             	shl    $0x2,%eax
c0100c0e:	05 08 20 12 c0       	add    $0xc0122008,%eax
c0100c13:	8b 10                	mov    (%eax),%edx
c0100c15:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100c18:	83 c0 04             	add    $0x4,%eax
c0100c1b:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0100c1e:	8d 59 ff             	lea    -0x1(%ecx),%ebx
c0100c21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c0100c24:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100c28:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c2c:	89 1c 24             	mov    %ebx,(%esp)
c0100c2f:	ff d2                	call   *%edx
c0100c31:	eb 23                	jmp    c0100c56 <runcmd+0xb3>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c33:	ff 45 f4             	incl   -0xc(%ebp)
c0100c36:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c39:	83 f8 02             	cmp    $0x2,%eax
c0100c3c:	76 9e                	jbe    c0100bdc <runcmd+0x39>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100c3e:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100c41:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c45:	c7 04 24 37 8b 10 c0 	movl   $0xc0108b37,(%esp)
c0100c4c:	e8 78 f6 ff ff       	call   c01002c9 <cprintf>
    return 0;
c0100c51:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100c56:	83 c4 64             	add    $0x64,%esp
c0100c59:	5b                   	pop    %ebx
c0100c5a:	5d                   	pop    %ebp
c0100c5b:	c3                   	ret    

c0100c5c <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100c5c:	f3 0f 1e fb          	endbr32 
c0100c60:	55                   	push   %ebp
c0100c61:	89 e5                	mov    %esp,%ebp
c0100c63:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100c66:	c7 04 24 50 8b 10 c0 	movl   $0xc0108b50,(%esp)
c0100c6d:	e8 57 f6 ff ff       	call   c01002c9 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100c72:	c7 04 24 78 8b 10 c0 	movl   $0xc0108b78,(%esp)
c0100c79:	e8 4b f6 ff ff       	call   c01002c9 <cprintf>

    if (tf != NULL) {
c0100c7e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100c82:	74 0b                	je     c0100c8f <kmonitor+0x33>
        print_trapframe(tf);
c0100c84:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c87:	89 04 24             	mov    %eax,(%esp)
c0100c8a:	e8 61 15 00 00       	call   c01021f0 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100c8f:	c7 04 24 9d 8b 10 c0 	movl   $0xc0108b9d,(%esp)
c0100c96:	e8 e1 f6 ff ff       	call   c010037c <readline>
c0100c9b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100c9e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100ca2:	74 eb                	je     c0100c8f <kmonitor+0x33>
            if (runcmd(buf, tf) < 0) {
c0100ca4:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ca7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100cab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100cae:	89 04 24             	mov    %eax,(%esp)
c0100cb1:	e8 ed fe ff ff       	call   c0100ba3 <runcmd>
c0100cb6:	85 c0                	test   %eax,%eax
c0100cb8:	78 02                	js     c0100cbc <kmonitor+0x60>
        if ((buf = readline("K> ")) != NULL) {
c0100cba:	eb d3                	jmp    c0100c8f <kmonitor+0x33>
                break;
c0100cbc:	90                   	nop
            }
        }
    }
}
c0100cbd:	90                   	nop
c0100cbe:	c9                   	leave  
c0100cbf:	c3                   	ret    

c0100cc0 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100cc0:	f3 0f 1e fb          	endbr32 
c0100cc4:	55                   	push   %ebp
c0100cc5:	89 e5                	mov    %esp,%ebp
c0100cc7:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100cca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100cd1:	eb 3d                	jmp    c0100d10 <mon_help+0x50>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100cd3:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100cd6:	89 d0                	mov    %edx,%eax
c0100cd8:	01 c0                	add    %eax,%eax
c0100cda:	01 d0                	add    %edx,%eax
c0100cdc:	c1 e0 02             	shl    $0x2,%eax
c0100cdf:	05 04 20 12 c0       	add    $0xc0122004,%eax
c0100ce4:	8b 08                	mov    (%eax),%ecx
c0100ce6:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100ce9:	89 d0                	mov    %edx,%eax
c0100ceb:	01 c0                	add    %eax,%eax
c0100ced:	01 d0                	add    %edx,%eax
c0100cef:	c1 e0 02             	shl    $0x2,%eax
c0100cf2:	05 00 20 12 c0       	add    $0xc0122000,%eax
c0100cf7:	8b 00                	mov    (%eax),%eax
c0100cf9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100cfd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d01:	c7 04 24 a1 8b 10 c0 	movl   $0xc0108ba1,(%esp)
c0100d08:	e8 bc f5 ff ff       	call   c01002c9 <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d0d:	ff 45 f4             	incl   -0xc(%ebp)
c0100d10:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d13:	83 f8 02             	cmp    $0x2,%eax
c0100d16:	76 bb                	jbe    c0100cd3 <mon_help+0x13>
    }
    return 0;
c0100d18:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d1d:	c9                   	leave  
c0100d1e:	c3                   	ret    

c0100d1f <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100d1f:	f3 0f 1e fb          	endbr32 
c0100d23:	55                   	push   %ebp
c0100d24:	89 e5                	mov    %esp,%ebp
c0100d26:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100d29:	e8 5e fc ff ff       	call   c010098c <print_kerninfo>
    return 0;
c0100d2e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d33:	c9                   	leave  
c0100d34:	c3                   	ret    

c0100d35 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100d35:	f3 0f 1e fb          	endbr32 
c0100d39:	55                   	push   %ebp
c0100d3a:	89 e5                	mov    %esp,%ebp
c0100d3c:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100d3f:	e8 9a fd ff ff       	call   c0100ade <print_stackframe>
    return 0;
c0100d44:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d49:	c9                   	leave  
c0100d4a:	c3                   	ret    

c0100d4b <ide_wait_ready>:
    unsigned int size;          // Size in Sectors
    unsigned char model[41];    // Model in String
} ide_devices[MAX_IDE];

static int
ide_wait_ready(unsigned short iobase, bool check_error) {
c0100d4b:	f3 0f 1e fb          	endbr32 
c0100d4f:	55                   	push   %ebp
c0100d50:	89 e5                	mov    %esp,%ebp
c0100d52:	83 ec 14             	sub    $0x14,%esp
c0100d55:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d58:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    int r;
    while ((r = inb(iobase + ISA_STATUS)) & IDE_BSY)
c0100d5c:	90                   	nop
c0100d5d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100d60:	83 c0 07             	add    $0x7,%eax
c0100d63:	0f b7 c0             	movzwl %ax,%eax
c0100d66:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100d6a:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100d6e:	89 c2                	mov    %eax,%edx
c0100d70:	ec                   	in     (%dx),%al
c0100d71:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0100d74:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0100d78:	0f b6 c0             	movzbl %al,%eax
c0100d7b:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100d7e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100d81:	25 80 00 00 00       	and    $0x80,%eax
c0100d86:	85 c0                	test   %eax,%eax
c0100d88:	75 d3                	jne    c0100d5d <ide_wait_ready+0x12>
        /* nothing */;
    if (check_error && (r & (IDE_DF | IDE_ERR)) != 0) {
c0100d8a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0100d8e:	74 11                	je     c0100da1 <ide_wait_ready+0x56>
c0100d90:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100d93:	83 e0 21             	and    $0x21,%eax
c0100d96:	85 c0                	test   %eax,%eax
c0100d98:	74 07                	je     c0100da1 <ide_wait_ready+0x56>
        return -1;
c0100d9a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100d9f:	eb 05                	jmp    c0100da6 <ide_wait_ready+0x5b>
    }
    return 0;
c0100da1:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100da6:	c9                   	leave  
c0100da7:	c3                   	ret    

c0100da8 <ide_init>:

void
ide_init(void) {
c0100da8:	f3 0f 1e fb          	endbr32 
c0100dac:	55                   	push   %ebp
c0100dad:	89 e5                	mov    %esp,%ebp
c0100daf:	57                   	push   %edi
c0100db0:	53                   	push   %ebx
c0100db1:	81 ec 50 02 00 00    	sub    $0x250,%esp
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c0100db7:	66 c7 45 f6 00 00    	movw   $0x0,-0xa(%ebp)
c0100dbd:	e9 bd 02 00 00       	jmp    c010107f <ide_init+0x2d7>
        /* assume that no device here */
        ide_devices[ideno].valid = 0;
c0100dc2:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100dc6:	89 d0                	mov    %edx,%eax
c0100dc8:	c1 e0 03             	shl    $0x3,%eax
c0100dcb:	29 d0                	sub    %edx,%eax
c0100dcd:	c1 e0 03             	shl    $0x3,%eax
c0100dd0:	05 40 54 12 c0       	add    $0xc0125440,%eax
c0100dd5:	c6 00 00             	movb   $0x0,(%eax)

        iobase = IO_BASE(ideno);
c0100dd8:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100ddc:	d1 e8                	shr    %eax
c0100dde:	0f b7 c0             	movzwl %ax,%eax
c0100de1:	8b 04 85 ac 8b 10 c0 	mov    -0x3fef7454(,%eax,4),%eax
c0100de8:	66 89 45 ea          	mov    %ax,-0x16(%ebp)

        /* wait device ready */
        ide_wait_ready(iobase, 0);
c0100dec:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100df0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100df7:	00 
c0100df8:	89 04 24             	mov    %eax,(%esp)
c0100dfb:	e8 4b ff ff ff       	call   c0100d4b <ide_wait_ready>

        /* step1: select drive */
        outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4));
c0100e00:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100e04:	c1 e0 04             	shl    $0x4,%eax
c0100e07:	24 10                	and    $0x10,%al
c0100e09:	0c e0                	or     $0xe0,%al
c0100e0b:	0f b6 c0             	movzbl %al,%eax
c0100e0e:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100e12:	83 c2 06             	add    $0x6,%edx
c0100e15:	0f b7 d2             	movzwl %dx,%edx
c0100e18:	66 89 55 ca          	mov    %dx,-0x36(%ebp)
c0100e1c:	88 45 c9             	mov    %al,-0x37(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100e1f:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c0100e23:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c0100e27:	ee                   	out    %al,(%dx)
}
c0100e28:	90                   	nop
        ide_wait_ready(iobase, 0);
c0100e29:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100e2d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100e34:	00 
c0100e35:	89 04 24             	mov    %eax,(%esp)
c0100e38:	e8 0e ff ff ff       	call   c0100d4b <ide_wait_ready>

        /* step2: send ATA identify command */
        outb(iobase + ISA_COMMAND, IDE_CMD_IDENTIFY);
c0100e3d:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100e41:	83 c0 07             	add    $0x7,%eax
c0100e44:	0f b7 c0             	movzwl %ax,%eax
c0100e47:	66 89 45 ce          	mov    %ax,-0x32(%ebp)
c0100e4b:	c6 45 cd ec          	movb   $0xec,-0x33(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100e4f:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c0100e53:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c0100e57:	ee                   	out    %al,(%dx)
}
c0100e58:	90                   	nop
        ide_wait_ready(iobase, 0);
c0100e59:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100e5d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100e64:	00 
c0100e65:	89 04 24             	mov    %eax,(%esp)
c0100e68:	e8 de fe ff ff       	call   c0100d4b <ide_wait_ready>

        /* step3: polling */
        if (inb(iobase + ISA_STATUS) == 0 || ide_wait_ready(iobase, 1) != 0) {
c0100e6d:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100e71:	83 c0 07             	add    $0x7,%eax
c0100e74:	0f b7 c0             	movzwl %ax,%eax
c0100e77:	66 89 45 d2          	mov    %ax,-0x2e(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100e7b:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
c0100e7f:	89 c2                	mov    %eax,%edx
c0100e81:	ec                   	in     (%dx),%al
c0100e82:	88 45 d1             	mov    %al,-0x2f(%ebp)
    return data;
c0100e85:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0100e89:	84 c0                	test   %al,%al
c0100e8b:	0f 84 e4 01 00 00    	je     c0101075 <ide_init+0x2cd>
c0100e91:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100e95:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0100e9c:	00 
c0100e9d:	89 04 24             	mov    %eax,(%esp)
c0100ea0:	e8 a6 fe ff ff       	call   c0100d4b <ide_wait_ready>
c0100ea5:	85 c0                	test   %eax,%eax
c0100ea7:	0f 85 c8 01 00 00    	jne    c0101075 <ide_init+0x2cd>
            continue ;
        }

        /* device is ok */
        ide_devices[ideno].valid = 1;
c0100ead:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100eb1:	89 d0                	mov    %edx,%eax
c0100eb3:	c1 e0 03             	shl    $0x3,%eax
c0100eb6:	29 d0                	sub    %edx,%eax
c0100eb8:	c1 e0 03             	shl    $0x3,%eax
c0100ebb:	05 40 54 12 c0       	add    $0xc0125440,%eax
c0100ec0:	c6 00 01             	movb   $0x1,(%eax)

        /* read identification space of the device */
        unsigned int buffer[128];
        insl(iobase + ISA_DATA, buffer, sizeof(buffer) / sizeof(unsigned int));
c0100ec3:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100ec7:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c0100eca:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c0100ed0:	89 45 c0             	mov    %eax,-0x40(%ebp)
c0100ed3:	c7 45 bc 80 00 00 00 	movl   $0x80,-0x44(%ebp)
    asm volatile (
c0100eda:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0100edd:	8b 4d c0             	mov    -0x40(%ebp),%ecx
c0100ee0:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0100ee3:	89 cb                	mov    %ecx,%ebx
c0100ee5:	89 df                	mov    %ebx,%edi
c0100ee7:	89 c1                	mov    %eax,%ecx
c0100ee9:	fc                   	cld    
c0100eea:	f2 6d                	repnz insl (%dx),%es:(%edi)
c0100eec:	89 c8                	mov    %ecx,%eax
c0100eee:	89 fb                	mov    %edi,%ebx
c0100ef0:	89 5d c0             	mov    %ebx,-0x40(%ebp)
c0100ef3:	89 45 bc             	mov    %eax,-0x44(%ebp)
}
c0100ef6:	90                   	nop

        unsigned char *ident = (unsigned char *)buffer;
c0100ef7:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c0100efd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        unsigned int sectors;
        unsigned int cmdsets = *(unsigned int *)(ident + IDE_IDENT_CMDSETS);
c0100f00:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100f03:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
c0100f09:	89 45 e0             	mov    %eax,-0x20(%ebp)
        /* device use 48-bits or 28-bits addressing */
        if (cmdsets & (1 << 26)) {
c0100f0c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0100f0f:	25 00 00 00 04       	and    $0x4000000,%eax
c0100f14:	85 c0                	test   %eax,%eax
c0100f16:	74 0e                	je     c0100f26 <ide_init+0x17e>
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA_EXT);
c0100f18:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100f1b:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
c0100f21:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100f24:	eb 09                	jmp    c0100f2f <ide_init+0x187>
        }
        else {
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA);
c0100f26:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100f29:	8b 40 78             	mov    0x78(%eax),%eax
c0100f2c:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        ide_devices[ideno].sets = cmdsets;
c0100f2f:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100f33:	89 d0                	mov    %edx,%eax
c0100f35:	c1 e0 03             	shl    $0x3,%eax
c0100f38:	29 d0                	sub    %edx,%eax
c0100f3a:	c1 e0 03             	shl    $0x3,%eax
c0100f3d:	8d 90 44 54 12 c0    	lea    -0x3fedabbc(%eax),%edx
c0100f43:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0100f46:	89 02                	mov    %eax,(%edx)
        ide_devices[ideno].size = sectors;
c0100f48:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100f4c:	89 d0                	mov    %edx,%eax
c0100f4e:	c1 e0 03             	shl    $0x3,%eax
c0100f51:	29 d0                	sub    %edx,%eax
c0100f53:	c1 e0 03             	shl    $0x3,%eax
c0100f56:	8d 90 48 54 12 c0    	lea    -0x3fedabb8(%eax),%edx
c0100f5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100f5f:	89 02                	mov    %eax,(%edx)

        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);
c0100f61:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100f64:	83 c0 62             	add    $0x62,%eax
c0100f67:	0f b7 00             	movzwl (%eax),%eax
c0100f6a:	25 00 02 00 00       	and    $0x200,%eax
c0100f6f:	85 c0                	test   %eax,%eax
c0100f71:	75 24                	jne    c0100f97 <ide_init+0x1ef>
c0100f73:	c7 44 24 0c b4 8b 10 	movl   $0xc0108bb4,0xc(%esp)
c0100f7a:	c0 
c0100f7b:	c7 44 24 08 f7 8b 10 	movl   $0xc0108bf7,0x8(%esp)
c0100f82:	c0 
c0100f83:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c0100f8a:	00 
c0100f8b:	c7 04 24 0c 8c 10 c0 	movl   $0xc0108c0c,(%esp)
c0100f92:	e8 9e f4 ff ff       	call   c0100435 <__panic>

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
c0100f97:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100f9b:	89 d0                	mov    %edx,%eax
c0100f9d:	c1 e0 03             	shl    $0x3,%eax
c0100fa0:	29 d0                	sub    %edx,%eax
c0100fa2:	c1 e0 03             	shl    $0x3,%eax
c0100fa5:	05 40 54 12 c0       	add    $0xc0125440,%eax
c0100faa:	83 c0 0c             	add    $0xc,%eax
c0100fad:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0100fb0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100fb3:	83 c0 36             	add    $0x36,%eax
c0100fb6:	89 45 d8             	mov    %eax,-0x28(%ebp)
        unsigned int i, length = 40;
c0100fb9:	c7 45 d4 28 00 00 00 	movl   $0x28,-0x2c(%ebp)
        for (i = 0; i < length; i += 2) {
c0100fc0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0100fc7:	eb 34                	jmp    c0100ffd <ide_init+0x255>
            model[i] = data[i + 1], model[i + 1] = data[i];
c0100fc9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100fcc:	8d 50 01             	lea    0x1(%eax),%edx
c0100fcf:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100fd2:	01 c2                	add    %eax,%edx
c0100fd4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0100fd7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100fda:	01 c8                	add    %ecx,%eax
c0100fdc:	0f b6 12             	movzbl (%edx),%edx
c0100fdf:	88 10                	mov    %dl,(%eax)
c0100fe1:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0100fe4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100fe7:	01 c2                	add    %eax,%edx
c0100fe9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100fec:	8d 48 01             	lea    0x1(%eax),%ecx
c0100fef:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100ff2:	01 c8                	add    %ecx,%eax
c0100ff4:	0f b6 12             	movzbl (%edx),%edx
c0100ff7:	88 10                	mov    %dl,(%eax)
        for (i = 0; i < length; i += 2) {
c0100ff9:	83 45 ec 02          	addl   $0x2,-0x14(%ebp)
c0100ffd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101000:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c0101003:	72 c4                	jb     c0100fc9 <ide_init+0x221>
        }
        do {
            model[i] = '\0';
c0101005:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101008:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010100b:	01 d0                	add    %edx,%eax
c010100d:	c6 00 00             	movb   $0x0,(%eax)
        } while (i -- > 0 && model[i] == ' ');
c0101010:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101013:	8d 50 ff             	lea    -0x1(%eax),%edx
c0101016:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0101019:	85 c0                	test   %eax,%eax
c010101b:	74 0f                	je     c010102c <ide_init+0x284>
c010101d:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101020:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101023:	01 d0                	add    %edx,%eax
c0101025:	0f b6 00             	movzbl (%eax),%eax
c0101028:	3c 20                	cmp    $0x20,%al
c010102a:	74 d9                	je     c0101005 <ide_init+0x25d>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
c010102c:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101030:	89 d0                	mov    %edx,%eax
c0101032:	c1 e0 03             	shl    $0x3,%eax
c0101035:	29 d0                	sub    %edx,%eax
c0101037:	c1 e0 03             	shl    $0x3,%eax
c010103a:	05 40 54 12 c0       	add    $0xc0125440,%eax
c010103f:	8d 48 0c             	lea    0xc(%eax),%ecx
c0101042:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101046:	89 d0                	mov    %edx,%eax
c0101048:	c1 e0 03             	shl    $0x3,%eax
c010104b:	29 d0                	sub    %edx,%eax
c010104d:	c1 e0 03             	shl    $0x3,%eax
c0101050:	05 48 54 12 c0       	add    $0xc0125448,%eax
c0101055:	8b 10                	mov    (%eax),%edx
c0101057:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010105b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c010105f:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101063:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101067:	c7 04 24 1e 8c 10 c0 	movl   $0xc0108c1e,(%esp)
c010106e:	e8 56 f2 ff ff       	call   c01002c9 <cprintf>
c0101073:	eb 01                	jmp    c0101076 <ide_init+0x2ce>
            continue ;
c0101075:	90                   	nop
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c0101076:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010107a:	40                   	inc    %eax
c010107b:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
c010107f:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101083:	83 f8 03             	cmp    $0x3,%eax
c0101086:	0f 86 36 fd ff ff    	jbe    c0100dc2 <ide_init+0x1a>
    }

    // enable ide interrupt
    pic_enable(IRQ_IDE1);
c010108c:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
c0101093:	e8 1f 0f 00 00       	call   c0101fb7 <pic_enable>
    pic_enable(IRQ_IDE2);
c0101098:	c7 04 24 0f 00 00 00 	movl   $0xf,(%esp)
c010109f:	e8 13 0f 00 00       	call   c0101fb7 <pic_enable>
}
c01010a4:	90                   	nop
c01010a5:	81 c4 50 02 00 00    	add    $0x250,%esp
c01010ab:	5b                   	pop    %ebx
c01010ac:	5f                   	pop    %edi
c01010ad:	5d                   	pop    %ebp
c01010ae:	c3                   	ret    

c01010af <ide_device_valid>:

bool
ide_device_valid(unsigned short ideno) {
c01010af:	f3 0f 1e fb          	endbr32 
c01010b3:	55                   	push   %ebp
c01010b4:	89 e5                	mov    %esp,%ebp
c01010b6:	83 ec 04             	sub    $0x4,%esp
c01010b9:	8b 45 08             	mov    0x8(%ebp),%eax
c01010bc:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    return VALID_IDE(ideno);
c01010c0:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c01010c4:	83 f8 03             	cmp    $0x3,%eax
c01010c7:	77 21                	ja     c01010ea <ide_device_valid+0x3b>
c01010c9:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
c01010cd:	89 d0                	mov    %edx,%eax
c01010cf:	c1 e0 03             	shl    $0x3,%eax
c01010d2:	29 d0                	sub    %edx,%eax
c01010d4:	c1 e0 03             	shl    $0x3,%eax
c01010d7:	05 40 54 12 c0       	add    $0xc0125440,%eax
c01010dc:	0f b6 00             	movzbl (%eax),%eax
c01010df:	84 c0                	test   %al,%al
c01010e1:	74 07                	je     c01010ea <ide_device_valid+0x3b>
c01010e3:	b8 01 00 00 00       	mov    $0x1,%eax
c01010e8:	eb 05                	jmp    c01010ef <ide_device_valid+0x40>
c01010ea:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01010ef:	c9                   	leave  
c01010f0:	c3                   	ret    

c01010f1 <ide_device_size>:

size_t
ide_device_size(unsigned short ideno) {
c01010f1:	f3 0f 1e fb          	endbr32 
c01010f5:	55                   	push   %ebp
c01010f6:	89 e5                	mov    %esp,%ebp
c01010f8:	83 ec 08             	sub    $0x8,%esp
c01010fb:	8b 45 08             	mov    0x8(%ebp),%eax
c01010fe:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    if (ide_device_valid(ideno)) {
c0101102:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101106:	89 04 24             	mov    %eax,(%esp)
c0101109:	e8 a1 ff ff ff       	call   c01010af <ide_device_valid>
c010110e:	85 c0                	test   %eax,%eax
c0101110:	74 17                	je     c0101129 <ide_device_size+0x38>
        return ide_devices[ideno].size;
c0101112:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
c0101116:	89 d0                	mov    %edx,%eax
c0101118:	c1 e0 03             	shl    $0x3,%eax
c010111b:	29 d0                	sub    %edx,%eax
c010111d:	c1 e0 03             	shl    $0x3,%eax
c0101120:	05 48 54 12 c0       	add    $0xc0125448,%eax
c0101125:	8b 00                	mov    (%eax),%eax
c0101127:	eb 05                	jmp    c010112e <ide_device_size+0x3d>
    }
    return 0;
c0101129:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010112e:	c9                   	leave  
c010112f:	c3                   	ret    

c0101130 <ide_read_secs>:

int
ide_read_secs(unsigned short ideno, uint32_t secno, void *dst, size_t nsecs) {
c0101130:	f3 0f 1e fb          	endbr32 
c0101134:	55                   	push   %ebp
c0101135:	89 e5                	mov    %esp,%ebp
c0101137:	57                   	push   %edi
c0101138:	53                   	push   %ebx
c0101139:	83 ec 50             	sub    $0x50,%esp
c010113c:	8b 45 08             	mov    0x8(%ebp),%eax
c010113f:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c0101143:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c010114a:	77 23                	ja     c010116f <ide_read_secs+0x3f>
c010114c:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101150:	83 f8 03             	cmp    $0x3,%eax
c0101153:	77 1a                	ja     c010116f <ide_read_secs+0x3f>
c0101155:	0f b7 55 c4          	movzwl -0x3c(%ebp),%edx
c0101159:	89 d0                	mov    %edx,%eax
c010115b:	c1 e0 03             	shl    $0x3,%eax
c010115e:	29 d0                	sub    %edx,%eax
c0101160:	c1 e0 03             	shl    $0x3,%eax
c0101163:	05 40 54 12 c0       	add    $0xc0125440,%eax
c0101168:	0f b6 00             	movzbl (%eax),%eax
c010116b:	84 c0                	test   %al,%al
c010116d:	75 24                	jne    c0101193 <ide_read_secs+0x63>
c010116f:	c7 44 24 0c 3c 8c 10 	movl   $0xc0108c3c,0xc(%esp)
c0101176:	c0 
c0101177:	c7 44 24 08 f7 8b 10 	movl   $0xc0108bf7,0x8(%esp)
c010117e:	c0 
c010117f:	c7 44 24 04 9f 00 00 	movl   $0x9f,0x4(%esp)
c0101186:	00 
c0101187:	c7 04 24 0c 8c 10 c0 	movl   $0xc0108c0c,(%esp)
c010118e:	e8 a2 f2 ff ff       	call   c0100435 <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0101193:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c010119a:	77 0f                	ja     c01011ab <ide_read_secs+0x7b>
c010119c:	8b 55 0c             	mov    0xc(%ebp),%edx
c010119f:	8b 45 14             	mov    0x14(%ebp),%eax
c01011a2:	01 d0                	add    %edx,%eax
c01011a4:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c01011a9:	76 24                	jbe    c01011cf <ide_read_secs+0x9f>
c01011ab:	c7 44 24 0c 64 8c 10 	movl   $0xc0108c64,0xc(%esp)
c01011b2:	c0 
c01011b3:	c7 44 24 08 f7 8b 10 	movl   $0xc0108bf7,0x8(%esp)
c01011ba:	c0 
c01011bb:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
c01011c2:	00 
c01011c3:	c7 04 24 0c 8c 10 c0 	movl   $0xc0108c0c,(%esp)
c01011ca:	e8 66 f2 ff ff       	call   c0100435 <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c01011cf:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c01011d3:	d1 e8                	shr    %eax
c01011d5:	0f b7 c0             	movzwl %ax,%eax
c01011d8:	8b 04 85 ac 8b 10 c0 	mov    -0x3fef7454(,%eax,4),%eax
c01011df:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c01011e3:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c01011e7:	d1 e8                	shr    %eax
c01011e9:	0f b7 c0             	movzwl %ax,%eax
c01011ec:	0f b7 04 85 ae 8b 10 	movzwl -0x3fef7452(,%eax,4),%eax
c01011f3:	c0 
c01011f4:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c01011f8:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01011fc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101203:	00 
c0101204:	89 04 24             	mov    %eax,(%esp)
c0101207:	e8 3f fb ff ff       	call   c0100d4b <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c010120c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010120f:	83 c0 02             	add    $0x2,%eax
c0101212:	0f b7 c0             	movzwl %ax,%eax
c0101215:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c0101219:	c6 45 d5 00          	movb   $0x0,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010121d:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101221:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101225:	ee                   	out    %al,(%dx)
}
c0101226:	90                   	nop
    outb(iobase + ISA_SECCNT, nsecs);
c0101227:	8b 45 14             	mov    0x14(%ebp),%eax
c010122a:	0f b6 c0             	movzbl %al,%eax
c010122d:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101231:	83 c2 02             	add    $0x2,%edx
c0101234:	0f b7 d2             	movzwl %dx,%edx
c0101237:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c010123b:	88 45 d9             	mov    %al,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010123e:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101242:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101246:	ee                   	out    %al,(%dx)
}
c0101247:	90                   	nop
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c0101248:	8b 45 0c             	mov    0xc(%ebp),%eax
c010124b:	0f b6 c0             	movzbl %al,%eax
c010124e:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101252:	83 c2 03             	add    $0x3,%edx
c0101255:	0f b7 d2             	movzwl %dx,%edx
c0101258:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c010125c:	88 45 dd             	mov    %al,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010125f:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101263:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101267:	ee                   	out    %al,(%dx)
}
c0101268:	90                   	nop
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c0101269:	8b 45 0c             	mov    0xc(%ebp),%eax
c010126c:	c1 e8 08             	shr    $0x8,%eax
c010126f:	0f b6 c0             	movzbl %al,%eax
c0101272:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101276:	83 c2 04             	add    $0x4,%edx
c0101279:	0f b7 d2             	movzwl %dx,%edx
c010127c:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0101280:	88 45 e1             	mov    %al,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101283:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101287:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c010128b:	ee                   	out    %al,(%dx)
}
c010128c:	90                   	nop
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c010128d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101290:	c1 e8 10             	shr    $0x10,%eax
c0101293:	0f b6 c0             	movzbl %al,%eax
c0101296:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010129a:	83 c2 05             	add    $0x5,%edx
c010129d:	0f b7 d2             	movzwl %dx,%edx
c01012a0:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c01012a4:	88 45 e5             	mov    %al,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01012a7:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01012ab:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01012af:	ee                   	out    %al,(%dx)
}
c01012b0:	90                   	nop
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c01012b1:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01012b4:	c0 e0 04             	shl    $0x4,%al
c01012b7:	24 10                	and    $0x10,%al
c01012b9:	88 c2                	mov    %al,%dl
c01012bb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01012be:	c1 e8 18             	shr    $0x18,%eax
c01012c1:	24 0f                	and    $0xf,%al
c01012c3:	08 d0                	or     %dl,%al
c01012c5:	0c e0                	or     $0xe0,%al
c01012c7:	0f b6 c0             	movzbl %al,%eax
c01012ca:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01012ce:	83 c2 06             	add    $0x6,%edx
c01012d1:	0f b7 d2             	movzwl %dx,%edx
c01012d4:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c01012d8:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01012db:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01012df:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01012e3:	ee                   	out    %al,(%dx)
}
c01012e4:	90                   	nop
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);
c01012e5:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01012e9:	83 c0 07             	add    $0x7,%eax
c01012ec:	0f b7 c0             	movzwl %ax,%eax
c01012ef:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c01012f3:	c6 45 ed 20          	movb   $0x20,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01012f7:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01012fb:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01012ff:	ee                   	out    %al,(%dx)
}
c0101300:	90                   	nop

    int ret = 0;
c0101301:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0101308:	eb 58                	jmp    c0101362 <ide_read_secs+0x232>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c010130a:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010130e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0101315:	00 
c0101316:	89 04 24             	mov    %eax,(%esp)
c0101319:	e8 2d fa ff ff       	call   c0100d4b <ide_wait_ready>
c010131e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101321:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101325:	75 43                	jne    c010136a <ide_read_secs+0x23a>
            goto out;
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
c0101327:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010132b:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010132e:	8b 45 10             	mov    0x10(%ebp),%eax
c0101331:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0101334:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    asm volatile (
c010133b:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010133e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c0101341:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0101344:	89 cb                	mov    %ecx,%ebx
c0101346:	89 df                	mov    %ebx,%edi
c0101348:	89 c1                	mov    %eax,%ecx
c010134a:	fc                   	cld    
c010134b:	f2 6d                	repnz insl (%dx),%es:(%edi)
c010134d:	89 c8                	mov    %ecx,%eax
c010134f:	89 fb                	mov    %edi,%ebx
c0101351:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c0101354:	89 45 c8             	mov    %eax,-0x38(%ebp)
}
c0101357:	90                   	nop
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0101358:	ff 4d 14             	decl   0x14(%ebp)
c010135b:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c0101362:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0101366:	75 a2                	jne    c010130a <ide_read_secs+0x1da>
    }

out:
c0101368:	eb 01                	jmp    c010136b <ide_read_secs+0x23b>
            goto out;
c010136a:	90                   	nop
    return ret;
c010136b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010136e:	83 c4 50             	add    $0x50,%esp
c0101371:	5b                   	pop    %ebx
c0101372:	5f                   	pop    %edi
c0101373:	5d                   	pop    %ebp
c0101374:	c3                   	ret    

c0101375 <ide_write_secs>:

int
ide_write_secs(unsigned short ideno, uint32_t secno, const void *src, size_t nsecs) {
c0101375:	f3 0f 1e fb          	endbr32 
c0101379:	55                   	push   %ebp
c010137a:	89 e5                	mov    %esp,%ebp
c010137c:	56                   	push   %esi
c010137d:	53                   	push   %ebx
c010137e:	83 ec 50             	sub    $0x50,%esp
c0101381:	8b 45 08             	mov    0x8(%ebp),%eax
c0101384:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c0101388:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c010138f:	77 23                	ja     c01013b4 <ide_write_secs+0x3f>
c0101391:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101395:	83 f8 03             	cmp    $0x3,%eax
c0101398:	77 1a                	ja     c01013b4 <ide_write_secs+0x3f>
c010139a:	0f b7 55 c4          	movzwl -0x3c(%ebp),%edx
c010139e:	89 d0                	mov    %edx,%eax
c01013a0:	c1 e0 03             	shl    $0x3,%eax
c01013a3:	29 d0                	sub    %edx,%eax
c01013a5:	c1 e0 03             	shl    $0x3,%eax
c01013a8:	05 40 54 12 c0       	add    $0xc0125440,%eax
c01013ad:	0f b6 00             	movzbl (%eax),%eax
c01013b0:	84 c0                	test   %al,%al
c01013b2:	75 24                	jne    c01013d8 <ide_write_secs+0x63>
c01013b4:	c7 44 24 0c 3c 8c 10 	movl   $0xc0108c3c,0xc(%esp)
c01013bb:	c0 
c01013bc:	c7 44 24 08 f7 8b 10 	movl   $0xc0108bf7,0x8(%esp)
c01013c3:	c0 
c01013c4:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
c01013cb:	00 
c01013cc:	c7 04 24 0c 8c 10 c0 	movl   $0xc0108c0c,(%esp)
c01013d3:	e8 5d f0 ff ff       	call   c0100435 <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c01013d8:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c01013df:	77 0f                	ja     c01013f0 <ide_write_secs+0x7b>
c01013e1:	8b 55 0c             	mov    0xc(%ebp),%edx
c01013e4:	8b 45 14             	mov    0x14(%ebp),%eax
c01013e7:	01 d0                	add    %edx,%eax
c01013e9:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c01013ee:	76 24                	jbe    c0101414 <ide_write_secs+0x9f>
c01013f0:	c7 44 24 0c 64 8c 10 	movl   $0xc0108c64,0xc(%esp)
c01013f7:	c0 
c01013f8:	c7 44 24 08 f7 8b 10 	movl   $0xc0108bf7,0x8(%esp)
c01013ff:	c0 
c0101400:	c7 44 24 04 bd 00 00 	movl   $0xbd,0x4(%esp)
c0101407:	00 
c0101408:	c7 04 24 0c 8c 10 c0 	movl   $0xc0108c0c,(%esp)
c010140f:	e8 21 f0 ff ff       	call   c0100435 <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0101414:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101418:	d1 e8                	shr    %eax
c010141a:	0f b7 c0             	movzwl %ax,%eax
c010141d:	8b 04 85 ac 8b 10 c0 	mov    -0x3fef7454(,%eax,4),%eax
c0101424:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101428:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c010142c:	d1 e8                	shr    %eax
c010142e:	0f b7 c0             	movzwl %ax,%eax
c0101431:	0f b7 04 85 ae 8b 10 	movzwl -0x3fef7452(,%eax,4),%eax
c0101438:	c0 
c0101439:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c010143d:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101441:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101448:	00 
c0101449:	89 04 24             	mov    %eax,(%esp)
c010144c:	e8 fa f8 ff ff       	call   c0100d4b <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c0101451:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101454:	83 c0 02             	add    $0x2,%eax
c0101457:	0f b7 c0             	movzwl %ax,%eax
c010145a:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c010145e:	c6 45 d5 00          	movb   $0x0,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101462:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101466:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c010146a:	ee                   	out    %al,(%dx)
}
c010146b:	90                   	nop
    outb(iobase + ISA_SECCNT, nsecs);
c010146c:	8b 45 14             	mov    0x14(%ebp),%eax
c010146f:	0f b6 c0             	movzbl %al,%eax
c0101472:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101476:	83 c2 02             	add    $0x2,%edx
c0101479:	0f b7 d2             	movzwl %dx,%edx
c010147c:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c0101480:	88 45 d9             	mov    %al,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101483:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101487:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c010148b:	ee                   	out    %al,(%dx)
}
c010148c:	90                   	nop
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c010148d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101490:	0f b6 c0             	movzbl %al,%eax
c0101493:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101497:	83 c2 03             	add    $0x3,%edx
c010149a:	0f b7 d2             	movzwl %dx,%edx
c010149d:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c01014a1:	88 45 dd             	mov    %al,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01014a4:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c01014a8:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c01014ac:	ee                   	out    %al,(%dx)
}
c01014ad:	90                   	nop
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c01014ae:	8b 45 0c             	mov    0xc(%ebp),%eax
c01014b1:	c1 e8 08             	shr    $0x8,%eax
c01014b4:	0f b6 c0             	movzbl %al,%eax
c01014b7:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01014bb:	83 c2 04             	add    $0x4,%edx
c01014be:	0f b7 d2             	movzwl %dx,%edx
c01014c1:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c01014c5:	88 45 e1             	mov    %al,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01014c8:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c01014cc:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c01014d0:	ee                   	out    %al,(%dx)
}
c01014d1:	90                   	nop
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c01014d2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01014d5:	c1 e8 10             	shr    $0x10,%eax
c01014d8:	0f b6 c0             	movzbl %al,%eax
c01014db:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01014df:	83 c2 05             	add    $0x5,%edx
c01014e2:	0f b7 d2             	movzwl %dx,%edx
c01014e5:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c01014e9:	88 45 e5             	mov    %al,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01014ec:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01014f0:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01014f4:	ee                   	out    %al,(%dx)
}
c01014f5:	90                   	nop
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c01014f6:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01014f9:	c0 e0 04             	shl    $0x4,%al
c01014fc:	24 10                	and    $0x10,%al
c01014fe:	88 c2                	mov    %al,%dl
c0101500:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101503:	c1 e8 18             	shr    $0x18,%eax
c0101506:	24 0f                	and    $0xf,%al
c0101508:	08 d0                	or     %dl,%al
c010150a:	0c e0                	or     $0xe0,%al
c010150c:	0f b6 c0             	movzbl %al,%eax
c010150f:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101513:	83 c2 06             	add    $0x6,%edx
c0101516:	0f b7 d2             	movzwl %dx,%edx
c0101519:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c010151d:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101520:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101524:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101528:	ee                   	out    %al,(%dx)
}
c0101529:	90                   	nop
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);
c010152a:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010152e:	83 c0 07             	add    $0x7,%eax
c0101531:	0f b7 c0             	movzwl %ax,%eax
c0101534:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101538:	c6 45 ed 30          	movb   $0x30,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010153c:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101540:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101544:	ee                   	out    %al,(%dx)
}
c0101545:	90                   	nop

    int ret = 0;
c0101546:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c010154d:	eb 58                	jmp    c01015a7 <ide_write_secs+0x232>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c010154f:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101553:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010155a:	00 
c010155b:	89 04 24             	mov    %eax,(%esp)
c010155e:	e8 e8 f7 ff ff       	call   c0100d4b <ide_wait_ready>
c0101563:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101566:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010156a:	75 43                	jne    c01015af <ide_write_secs+0x23a>
            goto out;
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
c010156c:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101570:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0101573:	8b 45 10             	mov    0x10(%ebp),%eax
c0101576:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0101579:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    asm volatile ("outw %0, %1" :: "a" (data), "d" (port) : "memory");
}

static inline void
outsl(uint32_t port, const void *addr, int cnt) {
    asm volatile (
c0101580:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0101583:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c0101586:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0101589:	89 cb                	mov    %ecx,%ebx
c010158b:	89 de                	mov    %ebx,%esi
c010158d:	89 c1                	mov    %eax,%ecx
c010158f:	fc                   	cld    
c0101590:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
c0101592:	89 c8                	mov    %ecx,%eax
c0101594:	89 f3                	mov    %esi,%ebx
c0101596:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c0101599:	89 45 c8             	mov    %eax,-0x38(%ebp)
        "cld;"
        "repne; outsl;"
        : "=S" (addr), "=c" (cnt)
        : "d" (port), "0" (addr), "1" (cnt)
        : "memory", "cc");
}
c010159c:	90                   	nop
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c010159d:	ff 4d 14             	decl   0x14(%ebp)
c01015a0:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c01015a7:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c01015ab:	75 a2                	jne    c010154f <ide_write_secs+0x1da>
    }

out:
c01015ad:	eb 01                	jmp    c01015b0 <ide_write_secs+0x23b>
            goto out;
c01015af:	90                   	nop
    return ret;
c01015b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01015b3:	83 c4 50             	add    $0x50,%esp
c01015b6:	5b                   	pop    %ebx
c01015b7:	5e                   	pop    %esi
c01015b8:	5d                   	pop    %ebp
c01015b9:	c3                   	ret    

c01015ba <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c01015ba:	f3 0f 1e fb          	endbr32 
c01015be:	55                   	push   %ebp
c01015bf:	89 e5                	mov    %esp,%ebp
c01015c1:	83 ec 28             	sub    $0x28,%esp
c01015c4:	66 c7 45 ee 43 00    	movw   $0x43,-0x12(%ebp)
c01015ca:	c6 45 ed 34          	movb   $0x34,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01015ce:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01015d2:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01015d6:	ee                   	out    %al,(%dx)
}
c01015d7:	90                   	nop
c01015d8:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c01015de:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01015e2:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01015e6:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01015ea:	ee                   	out    %al,(%dx)
}
c01015eb:	90                   	nop
c01015ec:	66 c7 45 f6 40 00    	movw   $0x40,-0xa(%ebp)
c01015f2:	c6 45 f5 2e          	movb   $0x2e,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01015f6:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c01015fa:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01015fe:	ee                   	out    %al,(%dx)
}
c01015ff:	90                   	nop
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0101600:	c7 05 1c 60 12 c0 00 	movl   $0x0,0xc012601c
c0101607:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c010160a:	c7 04 24 9e 8c 10 c0 	movl   $0xc0108c9e,(%esp)
c0101611:	e8 b3 ec ff ff       	call   c01002c9 <cprintf>
    pic_enable(IRQ_TIMER);
c0101616:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010161d:	e8 95 09 00 00       	call   c0101fb7 <pic_enable>
}
c0101622:	90                   	nop
c0101623:	c9                   	leave  
c0101624:	c3                   	ret    

c0101625 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0101625:	55                   	push   %ebp
c0101626:	89 e5                	mov    %esp,%ebp
c0101628:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c010162b:	9c                   	pushf  
c010162c:	58                   	pop    %eax
c010162d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0101630:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0101633:	25 00 02 00 00       	and    $0x200,%eax
c0101638:	85 c0                	test   %eax,%eax
c010163a:	74 0c                	je     c0101648 <__intr_save+0x23>
        intr_disable();
c010163c:	e8 05 0b 00 00       	call   c0102146 <intr_disable>
        return 1;
c0101641:	b8 01 00 00 00       	mov    $0x1,%eax
c0101646:	eb 05                	jmp    c010164d <__intr_save+0x28>
    }
    return 0;
c0101648:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010164d:	c9                   	leave  
c010164e:	c3                   	ret    

c010164f <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c010164f:	55                   	push   %ebp
c0101650:	89 e5                	mov    %esp,%ebp
c0101652:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0101655:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0101659:	74 05                	je     c0101660 <__intr_restore+0x11>
        intr_enable();
c010165b:	e8 da 0a 00 00       	call   c010213a <intr_enable>
    }
}
c0101660:	90                   	nop
c0101661:	c9                   	leave  
c0101662:	c3                   	ret    

c0101663 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0101663:	f3 0f 1e fb          	endbr32 
c0101667:	55                   	push   %ebp
c0101668:	89 e5                	mov    %esp,%ebp
c010166a:	83 ec 10             	sub    $0x10,%esp
c010166d:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101673:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101677:	89 c2                	mov    %eax,%edx
c0101679:	ec                   	in     (%dx),%al
c010167a:	88 45 f1             	mov    %al,-0xf(%ebp)
c010167d:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c0101683:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101687:	89 c2                	mov    %eax,%edx
c0101689:	ec                   	in     (%dx),%al
c010168a:	88 45 f5             	mov    %al,-0xb(%ebp)
c010168d:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0101693:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101697:	89 c2                	mov    %eax,%edx
c0101699:	ec                   	in     (%dx),%al
c010169a:	88 45 f9             	mov    %al,-0x7(%ebp)
c010169d:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
c01016a3:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c01016a7:	89 c2                	mov    %eax,%edx
c01016a9:	ec                   	in     (%dx),%al
c01016aa:	88 45 fd             	mov    %al,-0x3(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c01016ad:	90                   	nop
c01016ae:	c9                   	leave  
c01016af:	c3                   	ret    

c01016b0 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c01016b0:	f3 0f 1e fb          	endbr32 
c01016b4:	55                   	push   %ebp
c01016b5:	89 e5                	mov    %esp,%ebp
c01016b7:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c01016ba:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c01016c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01016c4:	0f b7 00             	movzwl (%eax),%eax
c01016c7:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c01016cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01016ce:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c01016d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01016d6:	0f b7 00             	movzwl (%eax),%eax
c01016d9:	0f b7 c0             	movzwl %ax,%eax
c01016dc:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
c01016e1:	74 12                	je     c01016f5 <cga_init+0x45>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c01016e3:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c01016ea:	66 c7 05 26 55 12 c0 	movw   $0x3b4,0xc0125526
c01016f1:	b4 03 
c01016f3:	eb 13                	jmp    c0101708 <cga_init+0x58>
    } else {
        *cp = was;
c01016f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01016f8:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c01016fc:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c01016ff:	66 c7 05 26 55 12 c0 	movw   $0x3d4,0xc0125526
c0101706:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0101708:	0f b7 05 26 55 12 c0 	movzwl 0xc0125526,%eax
c010170f:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c0101713:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101717:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c010171b:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c010171f:	ee                   	out    %al,(%dx)
}
c0101720:	90                   	nop
    pos = inb(addr_6845 + 1) << 8;
c0101721:	0f b7 05 26 55 12 c0 	movzwl 0xc0125526,%eax
c0101728:	40                   	inc    %eax
c0101729:	0f b7 c0             	movzwl %ax,%eax
c010172c:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101730:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0101734:	89 c2                	mov    %eax,%edx
c0101736:	ec                   	in     (%dx),%al
c0101737:	88 45 e9             	mov    %al,-0x17(%ebp)
    return data;
c010173a:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c010173e:	0f b6 c0             	movzbl %al,%eax
c0101741:	c1 e0 08             	shl    $0x8,%eax
c0101744:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0101747:	0f b7 05 26 55 12 c0 	movzwl 0xc0125526,%eax
c010174e:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101752:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101756:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c010175a:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c010175e:	ee                   	out    %al,(%dx)
}
c010175f:	90                   	nop
    pos |= inb(addr_6845 + 1);
c0101760:	0f b7 05 26 55 12 c0 	movzwl 0xc0125526,%eax
c0101767:	40                   	inc    %eax
c0101768:	0f b7 c0             	movzwl %ax,%eax
c010176b:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010176f:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101773:	89 c2                	mov    %eax,%edx
c0101775:	ec                   	in     (%dx),%al
c0101776:	88 45 f1             	mov    %al,-0xf(%ebp)
    return data;
c0101779:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010177d:	0f b6 c0             	movzbl %al,%eax
c0101780:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c0101783:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101786:	a3 20 55 12 c0       	mov    %eax,0xc0125520
    crt_pos = pos;
c010178b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010178e:	0f b7 c0             	movzwl %ax,%eax
c0101791:	66 a3 24 55 12 c0    	mov    %ax,0xc0125524
}
c0101797:	90                   	nop
c0101798:	c9                   	leave  
c0101799:	c3                   	ret    

c010179a <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c010179a:	f3 0f 1e fb          	endbr32 
c010179e:	55                   	push   %ebp
c010179f:	89 e5                	mov    %esp,%ebp
c01017a1:	83 ec 48             	sub    $0x48,%esp
c01017a4:	66 c7 45 d2 fa 03    	movw   $0x3fa,-0x2e(%ebp)
c01017aa:	c6 45 d1 00          	movb   $0x0,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01017ae:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c01017b2:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c01017b6:	ee                   	out    %al,(%dx)
}
c01017b7:	90                   	nop
c01017b8:	66 c7 45 d6 fb 03    	movw   $0x3fb,-0x2a(%ebp)
c01017be:	c6 45 d5 80          	movb   $0x80,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01017c2:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c01017c6:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c01017ca:	ee                   	out    %al,(%dx)
}
c01017cb:	90                   	nop
c01017cc:	66 c7 45 da f8 03    	movw   $0x3f8,-0x26(%ebp)
c01017d2:	c6 45 d9 0c          	movb   $0xc,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01017d6:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c01017da:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c01017de:	ee                   	out    %al,(%dx)
}
c01017df:	90                   	nop
c01017e0:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c01017e6:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01017ea:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c01017ee:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c01017f2:	ee                   	out    %al,(%dx)
}
c01017f3:	90                   	nop
c01017f4:	66 c7 45 e2 fb 03    	movw   $0x3fb,-0x1e(%ebp)
c01017fa:	c6 45 e1 03          	movb   $0x3,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01017fe:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101802:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101806:	ee                   	out    %al,(%dx)
}
c0101807:	90                   	nop
c0101808:	66 c7 45 e6 fc 03    	movw   $0x3fc,-0x1a(%ebp)
c010180e:	c6 45 e5 00          	movb   $0x0,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101812:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101816:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c010181a:	ee                   	out    %al,(%dx)
}
c010181b:	90                   	nop
c010181c:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c0101822:	c6 45 e9 01          	movb   $0x1,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101826:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c010182a:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c010182e:	ee                   	out    %al,(%dx)
}
c010182f:	90                   	nop
c0101830:	66 c7 45 ee fd 03    	movw   $0x3fd,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101836:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c010183a:	89 c2                	mov    %eax,%edx
c010183c:	ec                   	in     (%dx),%al
c010183d:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c0101840:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c0101844:	3c ff                	cmp    $0xff,%al
c0101846:	0f 95 c0             	setne  %al
c0101849:	0f b6 c0             	movzbl %al,%eax
c010184c:	a3 28 55 12 c0       	mov    %eax,0xc0125528
c0101851:	66 c7 45 f2 fa 03    	movw   $0x3fa,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101857:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010185b:	89 c2                	mov    %eax,%edx
c010185d:	ec                   	in     (%dx),%al
c010185e:	88 45 f1             	mov    %al,-0xf(%ebp)
c0101861:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c0101867:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010186b:	89 c2                	mov    %eax,%edx
c010186d:	ec                   	in     (%dx),%al
c010186e:	88 45 f5             	mov    %al,-0xb(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c0101871:	a1 28 55 12 c0       	mov    0xc0125528,%eax
c0101876:	85 c0                	test   %eax,%eax
c0101878:	74 0c                	je     c0101886 <serial_init+0xec>
        pic_enable(IRQ_COM1);
c010187a:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0101881:	e8 31 07 00 00       	call   c0101fb7 <pic_enable>
    }
}
c0101886:	90                   	nop
c0101887:	c9                   	leave  
c0101888:	c3                   	ret    

c0101889 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c0101889:	f3 0f 1e fb          	endbr32 
c010188d:	55                   	push   %ebp
c010188e:	89 e5                	mov    %esp,%ebp
c0101890:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0101893:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c010189a:	eb 08                	jmp    c01018a4 <lpt_putc_sub+0x1b>
        delay();
c010189c:	e8 c2 fd ff ff       	call   c0101663 <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c01018a1:	ff 45 fc             	incl   -0x4(%ebp)
c01018a4:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c01018aa:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01018ae:	89 c2                	mov    %eax,%edx
c01018b0:	ec                   	in     (%dx),%al
c01018b1:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01018b4:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01018b8:	84 c0                	test   %al,%al
c01018ba:	78 09                	js     c01018c5 <lpt_putc_sub+0x3c>
c01018bc:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c01018c3:	7e d7                	jle    c010189c <lpt_putc_sub+0x13>
    }
    outb(LPTPORT + 0, c);
c01018c5:	8b 45 08             	mov    0x8(%ebp),%eax
c01018c8:	0f b6 c0             	movzbl %al,%eax
c01018cb:	66 c7 45 ee 78 03    	movw   $0x378,-0x12(%ebp)
c01018d1:	88 45 ed             	mov    %al,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018d4:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01018d8:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01018dc:	ee                   	out    %al,(%dx)
}
c01018dd:	90                   	nop
c01018de:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c01018e4:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018e8:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01018ec:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01018f0:	ee                   	out    %al,(%dx)
}
c01018f1:	90                   	nop
c01018f2:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
c01018f8:	c6 45 f5 08          	movb   $0x8,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018fc:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101900:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101904:	ee                   	out    %al,(%dx)
}
c0101905:	90                   	nop
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c0101906:	90                   	nop
c0101907:	c9                   	leave  
c0101908:	c3                   	ret    

c0101909 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c0101909:	f3 0f 1e fb          	endbr32 
c010190d:	55                   	push   %ebp
c010190e:	89 e5                	mov    %esp,%ebp
c0101910:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c0101913:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101917:	74 0d                	je     c0101926 <lpt_putc+0x1d>
        lpt_putc_sub(c);
c0101919:	8b 45 08             	mov    0x8(%ebp),%eax
c010191c:	89 04 24             	mov    %eax,(%esp)
c010191f:	e8 65 ff ff ff       	call   c0101889 <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
c0101924:	eb 24                	jmp    c010194a <lpt_putc+0x41>
        lpt_putc_sub('\b');
c0101926:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010192d:	e8 57 ff ff ff       	call   c0101889 <lpt_putc_sub>
        lpt_putc_sub(' ');
c0101932:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101939:	e8 4b ff ff ff       	call   c0101889 <lpt_putc_sub>
        lpt_putc_sub('\b');
c010193e:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101945:	e8 3f ff ff ff       	call   c0101889 <lpt_putc_sub>
}
c010194a:	90                   	nop
c010194b:	c9                   	leave  
c010194c:	c3                   	ret    

c010194d <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c010194d:	f3 0f 1e fb          	endbr32 
c0101951:	55                   	push   %ebp
c0101952:	89 e5                	mov    %esp,%ebp
c0101954:	53                   	push   %ebx
c0101955:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c0101958:	8b 45 08             	mov    0x8(%ebp),%eax
c010195b:	25 00 ff ff ff       	and    $0xffffff00,%eax
c0101960:	85 c0                	test   %eax,%eax
c0101962:	75 07                	jne    c010196b <cga_putc+0x1e>
        c |= 0x0700;
c0101964:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c010196b:	8b 45 08             	mov    0x8(%ebp),%eax
c010196e:	0f b6 c0             	movzbl %al,%eax
c0101971:	83 f8 0d             	cmp    $0xd,%eax
c0101974:	74 72                	je     c01019e8 <cga_putc+0x9b>
c0101976:	83 f8 0d             	cmp    $0xd,%eax
c0101979:	0f 8f a3 00 00 00    	jg     c0101a22 <cga_putc+0xd5>
c010197f:	83 f8 08             	cmp    $0x8,%eax
c0101982:	74 0a                	je     c010198e <cga_putc+0x41>
c0101984:	83 f8 0a             	cmp    $0xa,%eax
c0101987:	74 4c                	je     c01019d5 <cga_putc+0x88>
c0101989:	e9 94 00 00 00       	jmp    c0101a22 <cga_putc+0xd5>
    case '\b':
        if (crt_pos > 0) {
c010198e:	0f b7 05 24 55 12 c0 	movzwl 0xc0125524,%eax
c0101995:	85 c0                	test   %eax,%eax
c0101997:	0f 84 af 00 00 00    	je     c0101a4c <cga_putc+0xff>
            crt_pos --;
c010199d:	0f b7 05 24 55 12 c0 	movzwl 0xc0125524,%eax
c01019a4:	48                   	dec    %eax
c01019a5:	0f b7 c0             	movzwl %ax,%eax
c01019a8:	66 a3 24 55 12 c0    	mov    %ax,0xc0125524
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c01019ae:	8b 45 08             	mov    0x8(%ebp),%eax
c01019b1:	98                   	cwtl   
c01019b2:	25 00 ff ff ff       	and    $0xffffff00,%eax
c01019b7:	98                   	cwtl   
c01019b8:	83 c8 20             	or     $0x20,%eax
c01019bb:	98                   	cwtl   
c01019bc:	8b 15 20 55 12 c0    	mov    0xc0125520,%edx
c01019c2:	0f b7 0d 24 55 12 c0 	movzwl 0xc0125524,%ecx
c01019c9:	01 c9                	add    %ecx,%ecx
c01019cb:	01 ca                	add    %ecx,%edx
c01019cd:	0f b7 c0             	movzwl %ax,%eax
c01019d0:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c01019d3:	eb 77                	jmp    c0101a4c <cga_putc+0xff>
    case '\n':
        crt_pos += CRT_COLS;
c01019d5:	0f b7 05 24 55 12 c0 	movzwl 0xc0125524,%eax
c01019dc:	83 c0 50             	add    $0x50,%eax
c01019df:	0f b7 c0             	movzwl %ax,%eax
c01019e2:	66 a3 24 55 12 c0    	mov    %ax,0xc0125524
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c01019e8:	0f b7 1d 24 55 12 c0 	movzwl 0xc0125524,%ebx
c01019ef:	0f b7 0d 24 55 12 c0 	movzwl 0xc0125524,%ecx
c01019f6:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
c01019fb:	89 c8                	mov    %ecx,%eax
c01019fd:	f7 e2                	mul    %edx
c01019ff:	c1 ea 06             	shr    $0x6,%edx
c0101a02:	89 d0                	mov    %edx,%eax
c0101a04:	c1 e0 02             	shl    $0x2,%eax
c0101a07:	01 d0                	add    %edx,%eax
c0101a09:	c1 e0 04             	shl    $0x4,%eax
c0101a0c:	29 c1                	sub    %eax,%ecx
c0101a0e:	89 c8                	mov    %ecx,%eax
c0101a10:	0f b7 c0             	movzwl %ax,%eax
c0101a13:	29 c3                	sub    %eax,%ebx
c0101a15:	89 d8                	mov    %ebx,%eax
c0101a17:	0f b7 c0             	movzwl %ax,%eax
c0101a1a:	66 a3 24 55 12 c0    	mov    %ax,0xc0125524
        break;
c0101a20:	eb 2b                	jmp    c0101a4d <cga_putc+0x100>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c0101a22:	8b 0d 20 55 12 c0    	mov    0xc0125520,%ecx
c0101a28:	0f b7 05 24 55 12 c0 	movzwl 0xc0125524,%eax
c0101a2f:	8d 50 01             	lea    0x1(%eax),%edx
c0101a32:	0f b7 d2             	movzwl %dx,%edx
c0101a35:	66 89 15 24 55 12 c0 	mov    %dx,0xc0125524
c0101a3c:	01 c0                	add    %eax,%eax
c0101a3e:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c0101a41:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a44:	0f b7 c0             	movzwl %ax,%eax
c0101a47:	66 89 02             	mov    %ax,(%edx)
        break;
c0101a4a:	eb 01                	jmp    c0101a4d <cga_putc+0x100>
        break;
c0101a4c:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c0101a4d:	0f b7 05 24 55 12 c0 	movzwl 0xc0125524,%eax
c0101a54:	3d cf 07 00 00       	cmp    $0x7cf,%eax
c0101a59:	76 5d                	jbe    c0101ab8 <cga_putc+0x16b>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c0101a5b:	a1 20 55 12 c0       	mov    0xc0125520,%eax
c0101a60:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c0101a66:	a1 20 55 12 c0       	mov    0xc0125520,%eax
c0101a6b:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c0101a72:	00 
c0101a73:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101a77:	89 04 24             	mov    %eax,(%esp)
c0101a7a:	e8 7b 65 00 00       	call   c0107ffa <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101a7f:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c0101a86:	eb 14                	jmp    c0101a9c <cga_putc+0x14f>
            crt_buf[i] = 0x0700 | ' ';
c0101a88:	a1 20 55 12 c0       	mov    0xc0125520,%eax
c0101a8d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101a90:	01 d2                	add    %edx,%edx
c0101a92:	01 d0                	add    %edx,%eax
c0101a94:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101a99:	ff 45 f4             	incl   -0xc(%ebp)
c0101a9c:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c0101aa3:	7e e3                	jle    c0101a88 <cga_putc+0x13b>
        }
        crt_pos -= CRT_COLS;
c0101aa5:	0f b7 05 24 55 12 c0 	movzwl 0xc0125524,%eax
c0101aac:	83 e8 50             	sub    $0x50,%eax
c0101aaf:	0f b7 c0             	movzwl %ax,%eax
c0101ab2:	66 a3 24 55 12 c0    	mov    %ax,0xc0125524
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c0101ab8:	0f b7 05 26 55 12 c0 	movzwl 0xc0125526,%eax
c0101abf:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c0101ac3:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101ac7:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101acb:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101acf:	ee                   	out    %al,(%dx)
}
c0101ad0:	90                   	nop
    outb(addr_6845 + 1, crt_pos >> 8);
c0101ad1:	0f b7 05 24 55 12 c0 	movzwl 0xc0125524,%eax
c0101ad8:	c1 e8 08             	shr    $0x8,%eax
c0101adb:	0f b7 c0             	movzwl %ax,%eax
c0101ade:	0f b6 c0             	movzbl %al,%eax
c0101ae1:	0f b7 15 26 55 12 c0 	movzwl 0xc0125526,%edx
c0101ae8:	42                   	inc    %edx
c0101ae9:	0f b7 d2             	movzwl %dx,%edx
c0101aec:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0101af0:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101af3:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101af7:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101afb:	ee                   	out    %al,(%dx)
}
c0101afc:	90                   	nop
    outb(addr_6845, 15);
c0101afd:	0f b7 05 26 55 12 c0 	movzwl 0xc0125526,%eax
c0101b04:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101b08:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101b0c:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101b10:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101b14:	ee                   	out    %al,(%dx)
}
c0101b15:	90                   	nop
    outb(addr_6845 + 1, crt_pos);
c0101b16:	0f b7 05 24 55 12 c0 	movzwl 0xc0125524,%eax
c0101b1d:	0f b6 c0             	movzbl %al,%eax
c0101b20:	0f b7 15 26 55 12 c0 	movzwl 0xc0125526,%edx
c0101b27:	42                   	inc    %edx
c0101b28:	0f b7 d2             	movzwl %dx,%edx
c0101b2b:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
c0101b2f:	88 45 f1             	mov    %al,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101b32:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101b36:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101b3a:	ee                   	out    %al,(%dx)
}
c0101b3b:	90                   	nop
}
c0101b3c:	90                   	nop
c0101b3d:	83 c4 34             	add    $0x34,%esp
c0101b40:	5b                   	pop    %ebx
c0101b41:	5d                   	pop    %ebp
c0101b42:	c3                   	ret    

c0101b43 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c0101b43:	f3 0f 1e fb          	endbr32 
c0101b47:	55                   	push   %ebp
c0101b48:	89 e5                	mov    %esp,%ebp
c0101b4a:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101b4d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101b54:	eb 08                	jmp    c0101b5e <serial_putc_sub+0x1b>
        delay();
c0101b56:	e8 08 fb ff ff       	call   c0101663 <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101b5b:	ff 45 fc             	incl   -0x4(%ebp)
c0101b5e:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101b64:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101b68:	89 c2                	mov    %eax,%edx
c0101b6a:	ec                   	in     (%dx),%al
c0101b6b:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101b6e:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101b72:	0f b6 c0             	movzbl %al,%eax
c0101b75:	83 e0 20             	and    $0x20,%eax
c0101b78:	85 c0                	test   %eax,%eax
c0101b7a:	75 09                	jne    c0101b85 <serial_putc_sub+0x42>
c0101b7c:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101b83:	7e d1                	jle    c0101b56 <serial_putc_sub+0x13>
    }
    outb(COM1 + COM_TX, c);
c0101b85:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b88:	0f b6 c0             	movzbl %al,%eax
c0101b8b:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c0101b91:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101b94:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101b98:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101b9c:	ee                   	out    %al,(%dx)
}
c0101b9d:	90                   	nop
}
c0101b9e:	90                   	nop
c0101b9f:	c9                   	leave  
c0101ba0:	c3                   	ret    

c0101ba1 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c0101ba1:	f3 0f 1e fb          	endbr32 
c0101ba5:	55                   	push   %ebp
c0101ba6:	89 e5                	mov    %esp,%ebp
c0101ba8:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c0101bab:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101baf:	74 0d                	je     c0101bbe <serial_putc+0x1d>
        serial_putc_sub(c);
c0101bb1:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bb4:	89 04 24             	mov    %eax,(%esp)
c0101bb7:	e8 87 ff ff ff       	call   c0101b43 <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
c0101bbc:	eb 24                	jmp    c0101be2 <serial_putc+0x41>
        serial_putc_sub('\b');
c0101bbe:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101bc5:	e8 79 ff ff ff       	call   c0101b43 <serial_putc_sub>
        serial_putc_sub(' ');
c0101bca:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101bd1:	e8 6d ff ff ff       	call   c0101b43 <serial_putc_sub>
        serial_putc_sub('\b');
c0101bd6:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101bdd:	e8 61 ff ff ff       	call   c0101b43 <serial_putc_sub>
}
c0101be2:	90                   	nop
c0101be3:	c9                   	leave  
c0101be4:	c3                   	ret    

c0101be5 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c0101be5:	f3 0f 1e fb          	endbr32 
c0101be9:	55                   	push   %ebp
c0101bea:	89 e5                	mov    %esp,%ebp
c0101bec:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c0101bef:	eb 33                	jmp    c0101c24 <cons_intr+0x3f>
        if (c != 0) {
c0101bf1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101bf5:	74 2d                	je     c0101c24 <cons_intr+0x3f>
            cons.buf[cons.wpos ++] = c;
c0101bf7:	a1 44 57 12 c0       	mov    0xc0125744,%eax
c0101bfc:	8d 50 01             	lea    0x1(%eax),%edx
c0101bff:	89 15 44 57 12 c0    	mov    %edx,0xc0125744
c0101c05:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101c08:	88 90 40 55 12 c0    	mov    %dl,-0x3fedaac0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c0101c0e:	a1 44 57 12 c0       	mov    0xc0125744,%eax
c0101c13:	3d 00 02 00 00       	cmp    $0x200,%eax
c0101c18:	75 0a                	jne    c0101c24 <cons_intr+0x3f>
                cons.wpos = 0;
c0101c1a:	c7 05 44 57 12 c0 00 	movl   $0x0,0xc0125744
c0101c21:	00 00 00 
    while ((c = (*proc)()) != -1) {
c0101c24:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c27:	ff d0                	call   *%eax
c0101c29:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101c2c:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c0101c30:	75 bf                	jne    c0101bf1 <cons_intr+0xc>
            }
        }
    }
}
c0101c32:	90                   	nop
c0101c33:	90                   	nop
c0101c34:	c9                   	leave  
c0101c35:	c3                   	ret    

c0101c36 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c0101c36:	f3 0f 1e fb          	endbr32 
c0101c3a:	55                   	push   %ebp
c0101c3b:	89 e5                	mov    %esp,%ebp
c0101c3d:	83 ec 10             	sub    $0x10,%esp
c0101c40:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101c46:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101c4a:	89 c2                	mov    %eax,%edx
c0101c4c:	ec                   	in     (%dx),%al
c0101c4d:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101c50:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c0101c54:	0f b6 c0             	movzbl %al,%eax
c0101c57:	83 e0 01             	and    $0x1,%eax
c0101c5a:	85 c0                	test   %eax,%eax
c0101c5c:	75 07                	jne    c0101c65 <serial_proc_data+0x2f>
        return -1;
c0101c5e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101c63:	eb 2a                	jmp    c0101c8f <serial_proc_data+0x59>
c0101c65:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101c6b:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101c6f:	89 c2                	mov    %eax,%edx
c0101c71:	ec                   	in     (%dx),%al
c0101c72:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c0101c75:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c0101c79:	0f b6 c0             	movzbl %al,%eax
c0101c7c:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c0101c7f:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c0101c83:	75 07                	jne    c0101c8c <serial_proc_data+0x56>
        c = '\b';
c0101c85:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c0101c8c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0101c8f:	c9                   	leave  
c0101c90:	c3                   	ret    

c0101c91 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c0101c91:	f3 0f 1e fb          	endbr32 
c0101c95:	55                   	push   %ebp
c0101c96:	89 e5                	mov    %esp,%ebp
c0101c98:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c0101c9b:	a1 28 55 12 c0       	mov    0xc0125528,%eax
c0101ca0:	85 c0                	test   %eax,%eax
c0101ca2:	74 0c                	je     c0101cb0 <serial_intr+0x1f>
        cons_intr(serial_proc_data);
c0101ca4:	c7 04 24 36 1c 10 c0 	movl   $0xc0101c36,(%esp)
c0101cab:	e8 35 ff ff ff       	call   c0101be5 <cons_intr>
    }
}
c0101cb0:	90                   	nop
c0101cb1:	c9                   	leave  
c0101cb2:	c3                   	ret    

c0101cb3 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c0101cb3:	f3 0f 1e fb          	endbr32 
c0101cb7:	55                   	push   %ebp
c0101cb8:	89 e5                	mov    %esp,%ebp
c0101cba:	83 ec 38             	sub    $0x38,%esp
c0101cbd:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101cc3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101cc6:	89 c2                	mov    %eax,%edx
c0101cc8:	ec                   	in     (%dx),%al
c0101cc9:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c0101ccc:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c0101cd0:	0f b6 c0             	movzbl %al,%eax
c0101cd3:	83 e0 01             	and    $0x1,%eax
c0101cd6:	85 c0                	test   %eax,%eax
c0101cd8:	75 0a                	jne    c0101ce4 <kbd_proc_data+0x31>
        return -1;
c0101cda:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101cdf:	e9 56 01 00 00       	jmp    c0101e3a <kbd_proc_data+0x187>
c0101ce4:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101cea:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101ced:	89 c2                	mov    %eax,%edx
c0101cef:	ec                   	in     (%dx),%al
c0101cf0:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c0101cf3:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c0101cf7:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c0101cfa:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c0101cfe:	75 17                	jne    c0101d17 <kbd_proc_data+0x64>
        // E0 escape character
        shift |= E0ESC;
c0101d00:	a1 48 57 12 c0       	mov    0xc0125748,%eax
c0101d05:	83 c8 40             	or     $0x40,%eax
c0101d08:	a3 48 57 12 c0       	mov    %eax,0xc0125748
        return 0;
c0101d0d:	b8 00 00 00 00       	mov    $0x0,%eax
c0101d12:	e9 23 01 00 00       	jmp    c0101e3a <kbd_proc_data+0x187>
    } else if (data & 0x80) {
c0101d17:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101d1b:	84 c0                	test   %al,%al
c0101d1d:	79 45                	jns    c0101d64 <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c0101d1f:	a1 48 57 12 c0       	mov    0xc0125748,%eax
c0101d24:	83 e0 40             	and    $0x40,%eax
c0101d27:	85 c0                	test   %eax,%eax
c0101d29:	75 08                	jne    c0101d33 <kbd_proc_data+0x80>
c0101d2b:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101d2f:	24 7f                	and    $0x7f,%al
c0101d31:	eb 04                	jmp    c0101d37 <kbd_proc_data+0x84>
c0101d33:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101d37:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c0101d3a:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101d3e:	0f b6 80 40 20 12 c0 	movzbl -0x3feddfc0(%eax),%eax
c0101d45:	0c 40                	or     $0x40,%al
c0101d47:	0f b6 c0             	movzbl %al,%eax
c0101d4a:	f7 d0                	not    %eax
c0101d4c:	89 c2                	mov    %eax,%edx
c0101d4e:	a1 48 57 12 c0       	mov    0xc0125748,%eax
c0101d53:	21 d0                	and    %edx,%eax
c0101d55:	a3 48 57 12 c0       	mov    %eax,0xc0125748
        return 0;
c0101d5a:	b8 00 00 00 00       	mov    $0x0,%eax
c0101d5f:	e9 d6 00 00 00       	jmp    c0101e3a <kbd_proc_data+0x187>
    } else if (shift & E0ESC) {
c0101d64:	a1 48 57 12 c0       	mov    0xc0125748,%eax
c0101d69:	83 e0 40             	and    $0x40,%eax
c0101d6c:	85 c0                	test   %eax,%eax
c0101d6e:	74 11                	je     c0101d81 <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c0101d70:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c0101d74:	a1 48 57 12 c0       	mov    0xc0125748,%eax
c0101d79:	83 e0 bf             	and    $0xffffffbf,%eax
c0101d7c:	a3 48 57 12 c0       	mov    %eax,0xc0125748
    }

    shift |= shiftcode[data];
c0101d81:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101d85:	0f b6 80 40 20 12 c0 	movzbl -0x3feddfc0(%eax),%eax
c0101d8c:	0f b6 d0             	movzbl %al,%edx
c0101d8f:	a1 48 57 12 c0       	mov    0xc0125748,%eax
c0101d94:	09 d0                	or     %edx,%eax
c0101d96:	a3 48 57 12 c0       	mov    %eax,0xc0125748
    shift ^= togglecode[data];
c0101d9b:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101d9f:	0f b6 80 40 21 12 c0 	movzbl -0x3feddec0(%eax),%eax
c0101da6:	0f b6 d0             	movzbl %al,%edx
c0101da9:	a1 48 57 12 c0       	mov    0xc0125748,%eax
c0101dae:	31 d0                	xor    %edx,%eax
c0101db0:	a3 48 57 12 c0       	mov    %eax,0xc0125748

    c = charcode[shift & (CTL | SHIFT)][data];
c0101db5:	a1 48 57 12 c0       	mov    0xc0125748,%eax
c0101dba:	83 e0 03             	and    $0x3,%eax
c0101dbd:	8b 14 85 40 25 12 c0 	mov    -0x3feddac0(,%eax,4),%edx
c0101dc4:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101dc8:	01 d0                	add    %edx,%eax
c0101dca:	0f b6 00             	movzbl (%eax),%eax
c0101dcd:	0f b6 c0             	movzbl %al,%eax
c0101dd0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c0101dd3:	a1 48 57 12 c0       	mov    0xc0125748,%eax
c0101dd8:	83 e0 08             	and    $0x8,%eax
c0101ddb:	85 c0                	test   %eax,%eax
c0101ddd:	74 22                	je     c0101e01 <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
c0101ddf:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c0101de3:	7e 0c                	jle    c0101df1 <kbd_proc_data+0x13e>
c0101de5:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c0101de9:	7f 06                	jg     c0101df1 <kbd_proc_data+0x13e>
            c += 'A' - 'a';
c0101deb:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c0101def:	eb 10                	jmp    c0101e01 <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
c0101df1:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c0101df5:	7e 0a                	jle    c0101e01 <kbd_proc_data+0x14e>
c0101df7:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c0101dfb:	7f 04                	jg     c0101e01 <kbd_proc_data+0x14e>
            c += 'a' - 'A';
c0101dfd:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c0101e01:	a1 48 57 12 c0       	mov    0xc0125748,%eax
c0101e06:	f7 d0                	not    %eax
c0101e08:	83 e0 06             	and    $0x6,%eax
c0101e0b:	85 c0                	test   %eax,%eax
c0101e0d:	75 28                	jne    c0101e37 <kbd_proc_data+0x184>
c0101e0f:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c0101e16:	75 1f                	jne    c0101e37 <kbd_proc_data+0x184>
        cprintf("Rebooting!\n");
c0101e18:	c7 04 24 b9 8c 10 c0 	movl   $0xc0108cb9,(%esp)
c0101e1f:	e8 a5 e4 ff ff       	call   c01002c9 <cprintf>
c0101e24:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c0101e2a:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101e2e:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c0101e32:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0101e35:	ee                   	out    %al,(%dx)
}
c0101e36:	90                   	nop
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c0101e37:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101e3a:	c9                   	leave  
c0101e3b:	c3                   	ret    

c0101e3c <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c0101e3c:	f3 0f 1e fb          	endbr32 
c0101e40:	55                   	push   %ebp
c0101e41:	89 e5                	mov    %esp,%ebp
c0101e43:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c0101e46:	c7 04 24 b3 1c 10 c0 	movl   $0xc0101cb3,(%esp)
c0101e4d:	e8 93 fd ff ff       	call   c0101be5 <cons_intr>
}
c0101e52:	90                   	nop
c0101e53:	c9                   	leave  
c0101e54:	c3                   	ret    

c0101e55 <kbd_init>:

static void
kbd_init(void) {
c0101e55:	f3 0f 1e fb          	endbr32 
c0101e59:	55                   	push   %ebp
c0101e5a:	89 e5                	mov    %esp,%ebp
c0101e5c:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c0101e5f:	e8 d8 ff ff ff       	call   c0101e3c <kbd_intr>
    pic_enable(IRQ_KBD);
c0101e64:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0101e6b:	e8 47 01 00 00       	call   c0101fb7 <pic_enable>
}
c0101e70:	90                   	nop
c0101e71:	c9                   	leave  
c0101e72:	c3                   	ret    

c0101e73 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c0101e73:	f3 0f 1e fb          	endbr32 
c0101e77:	55                   	push   %ebp
c0101e78:	89 e5                	mov    %esp,%ebp
c0101e7a:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c0101e7d:	e8 2e f8 ff ff       	call   c01016b0 <cga_init>
    serial_init();
c0101e82:	e8 13 f9 ff ff       	call   c010179a <serial_init>
    kbd_init();
c0101e87:	e8 c9 ff ff ff       	call   c0101e55 <kbd_init>
    if (!serial_exists) {
c0101e8c:	a1 28 55 12 c0       	mov    0xc0125528,%eax
c0101e91:	85 c0                	test   %eax,%eax
c0101e93:	75 0c                	jne    c0101ea1 <cons_init+0x2e>
        cprintf("serial port does not exist!!\n");
c0101e95:	c7 04 24 c5 8c 10 c0 	movl   $0xc0108cc5,(%esp)
c0101e9c:	e8 28 e4 ff ff       	call   c01002c9 <cprintf>
    }
}
c0101ea1:	90                   	nop
c0101ea2:	c9                   	leave  
c0101ea3:	c3                   	ret    

c0101ea4 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c0101ea4:	f3 0f 1e fb          	endbr32 
c0101ea8:	55                   	push   %ebp
c0101ea9:	89 e5                	mov    %esp,%ebp
c0101eab:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0101eae:	e8 72 f7 ff ff       	call   c0101625 <__intr_save>
c0101eb3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c0101eb6:	8b 45 08             	mov    0x8(%ebp),%eax
c0101eb9:	89 04 24             	mov    %eax,(%esp)
c0101ebc:	e8 48 fa ff ff       	call   c0101909 <lpt_putc>
        cga_putc(c);
c0101ec1:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ec4:	89 04 24             	mov    %eax,(%esp)
c0101ec7:	e8 81 fa ff ff       	call   c010194d <cga_putc>
        serial_putc(c);
c0101ecc:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ecf:	89 04 24             	mov    %eax,(%esp)
c0101ed2:	e8 ca fc ff ff       	call   c0101ba1 <serial_putc>
    }
    local_intr_restore(intr_flag);
c0101ed7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101eda:	89 04 24             	mov    %eax,(%esp)
c0101edd:	e8 6d f7 ff ff       	call   c010164f <__intr_restore>
}
c0101ee2:	90                   	nop
c0101ee3:	c9                   	leave  
c0101ee4:	c3                   	ret    

c0101ee5 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c0101ee5:	f3 0f 1e fb          	endbr32 
c0101ee9:	55                   	push   %ebp
c0101eea:	89 e5                	mov    %esp,%ebp
c0101eec:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c0101eef:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0101ef6:	e8 2a f7 ff ff       	call   c0101625 <__intr_save>
c0101efb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c0101efe:	e8 8e fd ff ff       	call   c0101c91 <serial_intr>
        kbd_intr();
c0101f03:	e8 34 ff ff ff       	call   c0101e3c <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c0101f08:	8b 15 40 57 12 c0    	mov    0xc0125740,%edx
c0101f0e:	a1 44 57 12 c0       	mov    0xc0125744,%eax
c0101f13:	39 c2                	cmp    %eax,%edx
c0101f15:	74 31                	je     c0101f48 <cons_getc+0x63>
            c = cons.buf[cons.rpos ++];
c0101f17:	a1 40 57 12 c0       	mov    0xc0125740,%eax
c0101f1c:	8d 50 01             	lea    0x1(%eax),%edx
c0101f1f:	89 15 40 57 12 c0    	mov    %edx,0xc0125740
c0101f25:	0f b6 80 40 55 12 c0 	movzbl -0x3fedaac0(%eax),%eax
c0101f2c:	0f b6 c0             	movzbl %al,%eax
c0101f2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c0101f32:	a1 40 57 12 c0       	mov    0xc0125740,%eax
c0101f37:	3d 00 02 00 00       	cmp    $0x200,%eax
c0101f3c:	75 0a                	jne    c0101f48 <cons_getc+0x63>
                cons.rpos = 0;
c0101f3e:	c7 05 40 57 12 c0 00 	movl   $0x0,0xc0125740
c0101f45:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c0101f48:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101f4b:	89 04 24             	mov    %eax,(%esp)
c0101f4e:	e8 fc f6 ff ff       	call   c010164f <__intr_restore>
    return c;
c0101f53:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101f56:	c9                   	leave  
c0101f57:	c3                   	ret    

c0101f58 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c0101f58:	f3 0f 1e fb          	endbr32 
c0101f5c:	55                   	push   %ebp
c0101f5d:	89 e5                	mov    %esp,%ebp
c0101f5f:	83 ec 14             	sub    $0x14,%esp
c0101f62:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f65:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c0101f69:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101f6c:	66 a3 50 25 12 c0    	mov    %ax,0xc0122550
    if (did_init) {
c0101f72:	a1 4c 57 12 c0       	mov    0xc012574c,%eax
c0101f77:	85 c0                	test   %eax,%eax
c0101f79:	74 39                	je     c0101fb4 <pic_setmask+0x5c>
        outb(IO_PIC1 + 1, mask);
c0101f7b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101f7e:	0f b6 c0             	movzbl %al,%eax
c0101f81:	66 c7 45 fa 21 00    	movw   $0x21,-0x6(%ebp)
c0101f87:	88 45 f9             	mov    %al,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101f8a:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101f8e:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101f92:	ee                   	out    %al,(%dx)
}
c0101f93:	90                   	nop
        outb(IO_PIC2 + 1, mask >> 8);
c0101f94:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101f98:	c1 e8 08             	shr    $0x8,%eax
c0101f9b:	0f b7 c0             	movzwl %ax,%eax
c0101f9e:	0f b6 c0             	movzbl %al,%eax
c0101fa1:	66 c7 45 fe a1 00    	movw   $0xa1,-0x2(%ebp)
c0101fa7:	88 45 fd             	mov    %al,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101faa:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0101fae:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101fb2:	ee                   	out    %al,(%dx)
}
c0101fb3:	90                   	nop
    }
}
c0101fb4:	90                   	nop
c0101fb5:	c9                   	leave  
c0101fb6:	c3                   	ret    

c0101fb7 <pic_enable>:

void
pic_enable(unsigned int irq) {
c0101fb7:	f3 0f 1e fb          	endbr32 
c0101fbb:	55                   	push   %ebp
c0101fbc:	89 e5                	mov    %esp,%ebp
c0101fbe:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c0101fc1:	8b 45 08             	mov    0x8(%ebp),%eax
c0101fc4:	ba 01 00 00 00       	mov    $0x1,%edx
c0101fc9:	88 c1                	mov    %al,%cl
c0101fcb:	d3 e2                	shl    %cl,%edx
c0101fcd:	89 d0                	mov    %edx,%eax
c0101fcf:	98                   	cwtl   
c0101fd0:	f7 d0                	not    %eax
c0101fd2:	0f bf d0             	movswl %ax,%edx
c0101fd5:	0f b7 05 50 25 12 c0 	movzwl 0xc0122550,%eax
c0101fdc:	98                   	cwtl   
c0101fdd:	21 d0                	and    %edx,%eax
c0101fdf:	98                   	cwtl   
c0101fe0:	0f b7 c0             	movzwl %ax,%eax
c0101fe3:	89 04 24             	mov    %eax,(%esp)
c0101fe6:	e8 6d ff ff ff       	call   c0101f58 <pic_setmask>
}
c0101feb:	90                   	nop
c0101fec:	c9                   	leave  
c0101fed:	c3                   	ret    

c0101fee <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c0101fee:	f3 0f 1e fb          	endbr32 
c0101ff2:	55                   	push   %ebp
c0101ff3:	89 e5                	mov    %esp,%ebp
c0101ff5:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
c0101ff8:	c7 05 4c 57 12 c0 01 	movl   $0x1,0xc012574c
c0101fff:	00 00 00 
c0102002:	66 c7 45 ca 21 00    	movw   $0x21,-0x36(%ebp)
c0102008:	c6 45 c9 ff          	movb   $0xff,-0x37(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010200c:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c0102010:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c0102014:	ee                   	out    %al,(%dx)
}
c0102015:	90                   	nop
c0102016:	66 c7 45 ce a1 00    	movw   $0xa1,-0x32(%ebp)
c010201c:	c6 45 cd ff          	movb   $0xff,-0x33(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102020:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c0102024:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c0102028:	ee                   	out    %al,(%dx)
}
c0102029:	90                   	nop
c010202a:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c0102030:	c6 45 d1 11          	movb   $0x11,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102034:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0102038:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c010203c:	ee                   	out    %al,(%dx)
}
c010203d:	90                   	nop
c010203e:	66 c7 45 d6 21 00    	movw   $0x21,-0x2a(%ebp)
c0102044:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102048:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c010204c:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0102050:	ee                   	out    %al,(%dx)
}
c0102051:	90                   	nop
c0102052:	66 c7 45 da 21 00    	movw   $0x21,-0x26(%ebp)
c0102058:	c6 45 d9 04          	movb   $0x4,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010205c:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0102060:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0102064:	ee                   	out    %al,(%dx)
}
c0102065:	90                   	nop
c0102066:	66 c7 45 de 21 00    	movw   $0x21,-0x22(%ebp)
c010206c:	c6 45 dd 03          	movb   $0x3,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102070:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0102074:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0102078:	ee                   	out    %al,(%dx)
}
c0102079:	90                   	nop
c010207a:	66 c7 45 e2 a0 00    	movw   $0xa0,-0x1e(%ebp)
c0102080:	c6 45 e1 11          	movb   $0x11,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102084:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0102088:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c010208c:	ee                   	out    %al,(%dx)
}
c010208d:	90                   	nop
c010208e:	66 c7 45 e6 a1 00    	movw   $0xa1,-0x1a(%ebp)
c0102094:	c6 45 e5 28          	movb   $0x28,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102098:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c010209c:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01020a0:	ee                   	out    %al,(%dx)
}
c01020a1:	90                   	nop
c01020a2:	66 c7 45 ea a1 00    	movw   $0xa1,-0x16(%ebp)
c01020a8:	c6 45 e9 02          	movb   $0x2,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01020ac:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01020b0:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01020b4:	ee                   	out    %al,(%dx)
}
c01020b5:	90                   	nop
c01020b6:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
c01020bc:	c6 45 ed 03          	movb   $0x3,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01020c0:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01020c4:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01020c8:	ee                   	out    %al,(%dx)
}
c01020c9:	90                   	nop
c01020ca:	66 c7 45 f2 20 00    	movw   $0x20,-0xe(%ebp)
c01020d0:	c6 45 f1 68          	movb   $0x68,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01020d4:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01020d8:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01020dc:	ee                   	out    %al,(%dx)
}
c01020dd:	90                   	nop
c01020de:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c01020e4:	c6 45 f5 0a          	movb   $0xa,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01020e8:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c01020ec:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01020f0:	ee                   	out    %al,(%dx)
}
c01020f1:	90                   	nop
c01020f2:	66 c7 45 fa a0 00    	movw   $0xa0,-0x6(%ebp)
c01020f8:	c6 45 f9 68          	movb   $0x68,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01020fc:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0102100:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0102104:	ee                   	out    %al,(%dx)
}
c0102105:	90                   	nop
c0102106:	66 c7 45 fe a0 00    	movw   $0xa0,-0x2(%ebp)
c010210c:	c6 45 fd 0a          	movb   $0xa,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102110:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0102114:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0102118:	ee                   	out    %al,(%dx)
}
c0102119:	90                   	nop
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c010211a:	0f b7 05 50 25 12 c0 	movzwl 0xc0122550,%eax
c0102121:	3d ff ff 00 00       	cmp    $0xffff,%eax
c0102126:	74 0f                	je     c0102137 <pic_init+0x149>
        pic_setmask(irq_mask);
c0102128:	0f b7 05 50 25 12 c0 	movzwl 0xc0122550,%eax
c010212f:	89 04 24             	mov    %eax,(%esp)
c0102132:	e8 21 fe ff ff       	call   c0101f58 <pic_setmask>
    }
}
c0102137:	90                   	nop
c0102138:	c9                   	leave  
c0102139:	c3                   	ret    

c010213a <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c010213a:	f3 0f 1e fb          	endbr32 
c010213e:	55                   	push   %ebp
c010213f:	89 e5                	mov    %esp,%ebp
    asm volatile ("sti");
c0102141:	fb                   	sti    
}
c0102142:	90                   	nop
    sti();
}
c0102143:	90                   	nop
c0102144:	5d                   	pop    %ebp
c0102145:	c3                   	ret    

c0102146 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c0102146:	f3 0f 1e fb          	endbr32 
c010214a:	55                   	push   %ebp
c010214b:	89 e5                	mov    %esp,%ebp
    asm volatile ("cli" ::: "memory");
c010214d:	fa                   	cli    
}
c010214e:	90                   	nop
    cli();
}
c010214f:	90                   	nop
c0102150:	5d                   	pop    %ebp
c0102151:	c3                   	ret    

c0102152 <print_ticks>:
#include <swap.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
c0102152:	f3 0f 1e fb          	endbr32 
c0102156:	55                   	push   %ebp
c0102157:	89 e5                	mov    %esp,%ebp
c0102159:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c010215c:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c0102163:	00 
c0102164:	c7 04 24 00 8d 10 c0 	movl   $0xc0108d00,(%esp)
c010216b:	e8 59 e1 ff ff       	call   c01002c9 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
c0102170:	c7 04 24 0a 8d 10 c0 	movl   $0xc0108d0a,(%esp)
c0102177:	e8 4d e1 ff ff       	call   c01002c9 <cprintf>
    panic("EOT: kernel seems ok.");
c010217c:	c7 44 24 08 18 8d 10 	movl   $0xc0108d18,0x8(%esp)
c0102183:	c0 
c0102184:	c7 44 24 04 14 00 00 	movl   $0x14,0x4(%esp)
c010218b:	00 
c010218c:	c7 04 24 2e 8d 10 c0 	movl   $0xc0108d2e,(%esp)
c0102193:	e8 9d e2 ff ff       	call   c0100435 <__panic>

c0102198 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c0102198:	f3 0f 1e fb          	endbr32 
c010219c:	55                   	push   %ebp
c010219d:	89 e5                	mov    %esp,%ebp
      *     Can you see idt[256] in this file? Yes, it's IDT! you can use SETGATE macro to setup each item of IDT
      * (3) After setup the contents of IDT, you will let CPU know where is the IDT by using 'lidt' instruction.
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
}
c010219f:	90                   	nop
c01021a0:	5d                   	pop    %ebp
c01021a1:	c3                   	ret    

c01021a2 <trapname>:

static const char *
trapname(int trapno) {
c01021a2:	f3 0f 1e fb          	endbr32 
c01021a6:	55                   	push   %ebp
c01021a7:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c01021a9:	8b 45 08             	mov    0x8(%ebp),%eax
c01021ac:	83 f8 13             	cmp    $0x13,%eax
c01021af:	77 0c                	ja     c01021bd <trapname+0x1b>
        return excnames[trapno];
c01021b1:	8b 45 08             	mov    0x8(%ebp),%eax
c01021b4:	8b 04 85 80 91 10 c0 	mov    -0x3fef6e80(,%eax,4),%eax
c01021bb:	eb 18                	jmp    c01021d5 <trapname+0x33>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c01021bd:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c01021c1:	7e 0d                	jle    c01021d0 <trapname+0x2e>
c01021c3:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c01021c7:	7f 07                	jg     c01021d0 <trapname+0x2e>
        return "Hardware Interrupt";
c01021c9:	b8 3f 8d 10 c0       	mov    $0xc0108d3f,%eax
c01021ce:	eb 05                	jmp    c01021d5 <trapname+0x33>
    }
    return "(unknown trap)";
c01021d0:	b8 52 8d 10 c0       	mov    $0xc0108d52,%eax
}
c01021d5:	5d                   	pop    %ebp
c01021d6:	c3                   	ret    

c01021d7 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c01021d7:	f3 0f 1e fb          	endbr32 
c01021db:	55                   	push   %ebp
c01021dc:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c01021de:	8b 45 08             	mov    0x8(%ebp),%eax
c01021e1:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01021e5:	83 f8 08             	cmp    $0x8,%eax
c01021e8:	0f 94 c0             	sete   %al
c01021eb:	0f b6 c0             	movzbl %al,%eax
}
c01021ee:	5d                   	pop    %ebp
c01021ef:	c3                   	ret    

c01021f0 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c01021f0:	f3 0f 1e fb          	endbr32 
c01021f4:	55                   	push   %ebp
c01021f5:	89 e5                	mov    %esp,%ebp
c01021f7:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c01021fa:	8b 45 08             	mov    0x8(%ebp),%eax
c01021fd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102201:	c7 04 24 93 8d 10 c0 	movl   $0xc0108d93,(%esp)
c0102208:	e8 bc e0 ff ff       	call   c01002c9 <cprintf>
    print_regs(&tf->tf_regs);
c010220d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102210:	89 04 24             	mov    %eax,(%esp)
c0102213:	e8 8d 01 00 00       	call   c01023a5 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c0102218:	8b 45 08             	mov    0x8(%ebp),%eax
c010221b:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c010221f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102223:	c7 04 24 a4 8d 10 c0 	movl   $0xc0108da4,(%esp)
c010222a:	e8 9a e0 ff ff       	call   c01002c9 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c010222f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102232:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0102236:	89 44 24 04          	mov    %eax,0x4(%esp)
c010223a:	c7 04 24 b7 8d 10 c0 	movl   $0xc0108db7,(%esp)
c0102241:	e8 83 e0 ff ff       	call   c01002c9 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0102246:	8b 45 08             	mov    0x8(%ebp),%eax
c0102249:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c010224d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102251:	c7 04 24 ca 8d 10 c0 	movl   $0xc0108dca,(%esp)
c0102258:	e8 6c e0 ff ff       	call   c01002c9 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c010225d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102260:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c0102264:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102268:	c7 04 24 dd 8d 10 c0 	movl   $0xc0108ddd,(%esp)
c010226f:	e8 55 e0 ff ff       	call   c01002c9 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c0102274:	8b 45 08             	mov    0x8(%ebp),%eax
c0102277:	8b 40 30             	mov    0x30(%eax),%eax
c010227a:	89 04 24             	mov    %eax,(%esp)
c010227d:	e8 20 ff ff ff       	call   c01021a2 <trapname>
c0102282:	8b 55 08             	mov    0x8(%ebp),%edx
c0102285:	8b 52 30             	mov    0x30(%edx),%edx
c0102288:	89 44 24 08          	mov    %eax,0x8(%esp)
c010228c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0102290:	c7 04 24 f0 8d 10 c0 	movl   $0xc0108df0,(%esp)
c0102297:	e8 2d e0 ff ff       	call   c01002c9 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c010229c:	8b 45 08             	mov    0x8(%ebp),%eax
c010229f:	8b 40 34             	mov    0x34(%eax),%eax
c01022a2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01022a6:	c7 04 24 02 8e 10 c0 	movl   $0xc0108e02,(%esp)
c01022ad:	e8 17 e0 ff ff       	call   c01002c9 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c01022b2:	8b 45 08             	mov    0x8(%ebp),%eax
c01022b5:	8b 40 38             	mov    0x38(%eax),%eax
c01022b8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01022bc:	c7 04 24 11 8e 10 c0 	movl   $0xc0108e11,(%esp)
c01022c3:	e8 01 e0 ff ff       	call   c01002c9 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c01022c8:	8b 45 08             	mov    0x8(%ebp),%eax
c01022cb:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01022cf:	89 44 24 04          	mov    %eax,0x4(%esp)
c01022d3:	c7 04 24 20 8e 10 c0 	movl   $0xc0108e20,(%esp)
c01022da:	e8 ea df ff ff       	call   c01002c9 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c01022df:	8b 45 08             	mov    0x8(%ebp),%eax
c01022e2:	8b 40 40             	mov    0x40(%eax),%eax
c01022e5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01022e9:	c7 04 24 33 8e 10 c0 	movl   $0xc0108e33,(%esp)
c01022f0:	e8 d4 df ff ff       	call   c01002c9 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c01022f5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01022fc:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c0102303:	eb 3d                	jmp    c0102342 <print_trapframe+0x152>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c0102305:	8b 45 08             	mov    0x8(%ebp),%eax
c0102308:	8b 50 40             	mov    0x40(%eax),%edx
c010230b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010230e:	21 d0                	and    %edx,%eax
c0102310:	85 c0                	test   %eax,%eax
c0102312:	74 28                	je     c010233c <print_trapframe+0x14c>
c0102314:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102317:	8b 04 85 80 25 12 c0 	mov    -0x3fedda80(,%eax,4),%eax
c010231e:	85 c0                	test   %eax,%eax
c0102320:	74 1a                	je     c010233c <print_trapframe+0x14c>
            cprintf("%s,", IA32flags[i]);
c0102322:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102325:	8b 04 85 80 25 12 c0 	mov    -0x3fedda80(,%eax,4),%eax
c010232c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102330:	c7 04 24 42 8e 10 c0 	movl   $0xc0108e42,(%esp)
c0102337:	e8 8d df ff ff       	call   c01002c9 <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c010233c:	ff 45 f4             	incl   -0xc(%ebp)
c010233f:	d1 65 f0             	shll   -0x10(%ebp)
c0102342:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102345:	83 f8 17             	cmp    $0x17,%eax
c0102348:	76 bb                	jbe    c0102305 <print_trapframe+0x115>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c010234a:	8b 45 08             	mov    0x8(%ebp),%eax
c010234d:	8b 40 40             	mov    0x40(%eax),%eax
c0102350:	c1 e8 0c             	shr    $0xc,%eax
c0102353:	83 e0 03             	and    $0x3,%eax
c0102356:	89 44 24 04          	mov    %eax,0x4(%esp)
c010235a:	c7 04 24 46 8e 10 c0 	movl   $0xc0108e46,(%esp)
c0102361:	e8 63 df ff ff       	call   c01002c9 <cprintf>

    if (!trap_in_kernel(tf)) {
c0102366:	8b 45 08             	mov    0x8(%ebp),%eax
c0102369:	89 04 24             	mov    %eax,(%esp)
c010236c:	e8 66 fe ff ff       	call   c01021d7 <trap_in_kernel>
c0102371:	85 c0                	test   %eax,%eax
c0102373:	75 2d                	jne    c01023a2 <print_trapframe+0x1b2>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c0102375:	8b 45 08             	mov    0x8(%ebp),%eax
c0102378:	8b 40 44             	mov    0x44(%eax),%eax
c010237b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010237f:	c7 04 24 4f 8e 10 c0 	movl   $0xc0108e4f,(%esp)
c0102386:	e8 3e df ff ff       	call   c01002c9 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c010238b:	8b 45 08             	mov    0x8(%ebp),%eax
c010238e:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c0102392:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102396:	c7 04 24 5e 8e 10 c0 	movl   $0xc0108e5e,(%esp)
c010239d:	e8 27 df ff ff       	call   c01002c9 <cprintf>
    }
}
c01023a2:	90                   	nop
c01023a3:	c9                   	leave  
c01023a4:	c3                   	ret    

c01023a5 <print_regs>:

void
print_regs(struct pushregs *regs) {
c01023a5:	f3 0f 1e fb          	endbr32 
c01023a9:	55                   	push   %ebp
c01023aa:	89 e5                	mov    %esp,%ebp
c01023ac:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c01023af:	8b 45 08             	mov    0x8(%ebp),%eax
c01023b2:	8b 00                	mov    (%eax),%eax
c01023b4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023b8:	c7 04 24 71 8e 10 c0 	movl   $0xc0108e71,(%esp)
c01023bf:	e8 05 df ff ff       	call   c01002c9 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c01023c4:	8b 45 08             	mov    0x8(%ebp),%eax
c01023c7:	8b 40 04             	mov    0x4(%eax),%eax
c01023ca:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023ce:	c7 04 24 80 8e 10 c0 	movl   $0xc0108e80,(%esp)
c01023d5:	e8 ef de ff ff       	call   c01002c9 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c01023da:	8b 45 08             	mov    0x8(%ebp),%eax
c01023dd:	8b 40 08             	mov    0x8(%eax),%eax
c01023e0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023e4:	c7 04 24 8f 8e 10 c0 	movl   $0xc0108e8f,(%esp)
c01023eb:	e8 d9 de ff ff       	call   c01002c9 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c01023f0:	8b 45 08             	mov    0x8(%ebp),%eax
c01023f3:	8b 40 0c             	mov    0xc(%eax),%eax
c01023f6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023fa:	c7 04 24 9e 8e 10 c0 	movl   $0xc0108e9e,(%esp)
c0102401:	e8 c3 de ff ff       	call   c01002c9 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0102406:	8b 45 08             	mov    0x8(%ebp),%eax
c0102409:	8b 40 10             	mov    0x10(%eax),%eax
c010240c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102410:	c7 04 24 ad 8e 10 c0 	movl   $0xc0108ead,(%esp)
c0102417:	e8 ad de ff ff       	call   c01002c9 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c010241c:	8b 45 08             	mov    0x8(%ebp),%eax
c010241f:	8b 40 14             	mov    0x14(%eax),%eax
c0102422:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102426:	c7 04 24 bc 8e 10 c0 	movl   $0xc0108ebc,(%esp)
c010242d:	e8 97 de ff ff       	call   c01002c9 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0102432:	8b 45 08             	mov    0x8(%ebp),%eax
c0102435:	8b 40 18             	mov    0x18(%eax),%eax
c0102438:	89 44 24 04          	mov    %eax,0x4(%esp)
c010243c:	c7 04 24 cb 8e 10 c0 	movl   $0xc0108ecb,(%esp)
c0102443:	e8 81 de ff ff       	call   c01002c9 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0102448:	8b 45 08             	mov    0x8(%ebp),%eax
c010244b:	8b 40 1c             	mov    0x1c(%eax),%eax
c010244e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102452:	c7 04 24 da 8e 10 c0 	movl   $0xc0108eda,(%esp)
c0102459:	e8 6b de ff ff       	call   c01002c9 <cprintf>
}
c010245e:	90                   	nop
c010245f:	c9                   	leave  
c0102460:	c3                   	ret    

c0102461 <print_pgfault>:

static inline void
print_pgfault(struct trapframe *tf) {
c0102461:	55                   	push   %ebp
c0102462:	89 e5                	mov    %esp,%ebp
c0102464:	53                   	push   %ebx
c0102465:	83 ec 34             	sub    $0x34,%esp
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
c0102468:	8b 45 08             	mov    0x8(%ebp),%eax
c010246b:	8b 40 34             	mov    0x34(%eax),%eax
c010246e:	83 e0 01             	and    $0x1,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c0102471:	85 c0                	test   %eax,%eax
c0102473:	74 07                	je     c010247c <print_pgfault+0x1b>
c0102475:	bb e9 8e 10 c0       	mov    $0xc0108ee9,%ebx
c010247a:	eb 05                	jmp    c0102481 <print_pgfault+0x20>
c010247c:	bb fa 8e 10 c0       	mov    $0xc0108efa,%ebx
            (tf->tf_err & 2) ? 'W' : 'R',
c0102481:	8b 45 08             	mov    0x8(%ebp),%eax
c0102484:	8b 40 34             	mov    0x34(%eax),%eax
c0102487:	83 e0 02             	and    $0x2,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c010248a:	85 c0                	test   %eax,%eax
c010248c:	74 07                	je     c0102495 <print_pgfault+0x34>
c010248e:	b9 57 00 00 00       	mov    $0x57,%ecx
c0102493:	eb 05                	jmp    c010249a <print_pgfault+0x39>
c0102495:	b9 52 00 00 00       	mov    $0x52,%ecx
            (tf->tf_err & 4) ? 'U' : 'K',
c010249a:	8b 45 08             	mov    0x8(%ebp),%eax
c010249d:	8b 40 34             	mov    0x34(%eax),%eax
c01024a0:	83 e0 04             	and    $0x4,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c01024a3:	85 c0                	test   %eax,%eax
c01024a5:	74 07                	je     c01024ae <print_pgfault+0x4d>
c01024a7:	ba 55 00 00 00       	mov    $0x55,%edx
c01024ac:	eb 05                	jmp    c01024b3 <print_pgfault+0x52>
c01024ae:	ba 4b 00 00 00       	mov    $0x4b,%edx
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c01024b3:	0f 20 d0             	mov    %cr2,%eax
c01024b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr2;
c01024b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01024bc:	89 5c 24 10          	mov    %ebx,0x10(%esp)
c01024c0:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01024c4:	89 54 24 08          	mov    %edx,0x8(%esp)
c01024c8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024cc:	c7 04 24 08 8f 10 c0 	movl   $0xc0108f08,(%esp)
c01024d3:	e8 f1 dd ff ff       	call   c01002c9 <cprintf>
}
c01024d8:	90                   	nop
c01024d9:	83 c4 34             	add    $0x34,%esp
c01024dc:	5b                   	pop    %ebx
c01024dd:	5d                   	pop    %ebp
c01024de:	c3                   	ret    

c01024df <pgfault_handler>:

static int
pgfault_handler(struct trapframe *tf) {
c01024df:	f3 0f 1e fb          	endbr32 
c01024e3:	55                   	push   %ebp
c01024e4:	89 e5                	mov    %esp,%ebp
c01024e6:	83 ec 28             	sub    $0x28,%esp
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
c01024e9:	8b 45 08             	mov    0x8(%ebp),%eax
c01024ec:	89 04 24             	mov    %eax,(%esp)
c01024ef:	e8 6d ff ff ff       	call   c0102461 <print_pgfault>
    if (check_mm_struct != NULL) {
c01024f4:	a1 2c 60 12 c0       	mov    0xc012602c,%eax
c01024f9:	85 c0                	test   %eax,%eax
c01024fb:	74 26                	je     c0102523 <pgfault_handler+0x44>
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c01024fd:	0f 20 d0             	mov    %cr2,%eax
c0102500:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr2;
c0102503:	8b 4d f4             	mov    -0xc(%ebp),%ecx
        return do_pgfault(check_mm_struct, tf->tf_err, rcr2());
c0102506:	8b 45 08             	mov    0x8(%ebp),%eax
c0102509:	8b 50 34             	mov    0x34(%eax),%edx
c010250c:	a1 2c 60 12 c0       	mov    0xc012602c,%eax
c0102511:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0102515:	89 54 24 04          	mov    %edx,0x4(%esp)
c0102519:	89 04 24             	mov    %eax,(%esp)
c010251c:	e8 7f 32 00 00       	call   c01057a0 <do_pgfault>
c0102521:	eb 1c                	jmp    c010253f <pgfault_handler+0x60>
    }
    panic("unhandled page fault.\n");
c0102523:	c7 44 24 08 2b 8f 10 	movl   $0xc0108f2b,0x8(%esp)
c010252a:	c0 
c010252b:	c7 44 24 04 9f 00 00 	movl   $0x9f,0x4(%esp)
c0102532:	00 
c0102533:	c7 04 24 2e 8d 10 c0 	movl   $0xc0108d2e,(%esp)
c010253a:	e8 f6 de ff ff       	call   c0100435 <__panic>
}
c010253f:	c9                   	leave  
c0102540:	c3                   	ret    

c0102541 <trap_dispatch>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

static void
trap_dispatch(struct trapframe *tf) {
c0102541:	f3 0f 1e fb          	endbr32 
c0102545:	55                   	push   %ebp
c0102546:	89 e5                	mov    %esp,%ebp
c0102548:	83 ec 28             	sub    $0x28,%esp
    char c;

    int ret;

    switch (tf->tf_trapno) {
c010254b:	8b 45 08             	mov    0x8(%ebp),%eax
c010254e:	8b 40 30             	mov    0x30(%eax),%eax
c0102551:	83 f8 2f             	cmp    $0x2f,%eax
c0102554:	77 1f                	ja     c0102575 <trap_dispatch+0x34>
c0102556:	83 f8 0e             	cmp    $0xe,%eax
c0102559:	0f 82 d5 00 00 00    	jb     c0102634 <trap_dispatch+0xf3>
c010255f:	83 e8 0e             	sub    $0xe,%eax
c0102562:	83 f8 21             	cmp    $0x21,%eax
c0102565:	0f 87 c9 00 00 00    	ja     c0102634 <trap_dispatch+0xf3>
c010256b:	8b 04 85 ac 8f 10 c0 	mov    -0x3fef7054(,%eax,4),%eax
c0102572:	3e ff e0             	notrack jmp *%eax
c0102575:	83 e8 78             	sub    $0x78,%eax
c0102578:	83 f8 01             	cmp    $0x1,%eax
c010257b:	0f 87 b3 00 00 00    	ja     c0102634 <trap_dispatch+0xf3>
c0102581:	e9 92 00 00 00       	jmp    c0102618 <trap_dispatch+0xd7>
    case T_PGFLT:  //page fault
        if ((ret = pgfault_handler(tf)) != 0) {
c0102586:	8b 45 08             	mov    0x8(%ebp),%eax
c0102589:	89 04 24             	mov    %eax,(%esp)
c010258c:	e8 4e ff ff ff       	call   c01024df <pgfault_handler>
c0102591:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102594:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0102598:	0f 84 ce 00 00 00    	je     c010266c <trap_dispatch+0x12b>
            print_trapframe(tf);
c010259e:	8b 45 08             	mov    0x8(%ebp),%eax
c01025a1:	89 04 24             	mov    %eax,(%esp)
c01025a4:	e8 47 fc ff ff       	call   c01021f0 <print_trapframe>
            panic("handle pgfault failed. %e\n", ret);
c01025a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01025ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01025b0:	c7 44 24 08 42 8f 10 	movl   $0xc0108f42,0x8(%esp)
c01025b7:	c0 
c01025b8:	c7 44 24 04 af 00 00 	movl   $0xaf,0x4(%esp)
c01025bf:	00 
c01025c0:	c7 04 24 2e 8d 10 c0 	movl   $0xc0108d2e,(%esp)
c01025c7:	e8 69 de ff ff       	call   c0100435 <__panic>
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        break;
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c01025cc:	e8 14 f9 ff ff       	call   c0101ee5 <cons_getc>
c01025d1:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c01025d4:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c01025d8:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01025dc:	89 54 24 08          	mov    %edx,0x8(%esp)
c01025e0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025e4:	c7 04 24 5d 8f 10 c0 	movl   $0xc0108f5d,(%esp)
c01025eb:	e8 d9 dc ff ff       	call   c01002c9 <cprintf>
        break;
c01025f0:	eb 7b                	jmp    c010266d <trap_dispatch+0x12c>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c01025f2:	e8 ee f8 ff ff       	call   c0101ee5 <cons_getc>
c01025f7:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c01025fa:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c01025fe:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0102602:	89 54 24 08          	mov    %edx,0x8(%esp)
c0102606:	89 44 24 04          	mov    %eax,0x4(%esp)
c010260a:	c7 04 24 6f 8f 10 c0 	movl   $0xc0108f6f,(%esp)
c0102611:	e8 b3 dc ff ff       	call   c01002c9 <cprintf>
        break;
c0102616:	eb 55                	jmp    c010266d <trap_dispatch+0x12c>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
c0102618:	c7 44 24 08 7e 8f 10 	movl   $0xc0108f7e,0x8(%esp)
c010261f:	c0 
c0102620:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
c0102627:	00 
c0102628:	c7 04 24 2e 8d 10 c0 	movl   $0xc0108d2e,(%esp)
c010262f:	e8 01 de ff ff       	call   c0100435 <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c0102634:	8b 45 08             	mov    0x8(%ebp),%eax
c0102637:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c010263b:	83 e0 03             	and    $0x3,%eax
c010263e:	85 c0                	test   %eax,%eax
c0102640:	75 2b                	jne    c010266d <trap_dispatch+0x12c>
            print_trapframe(tf);
c0102642:	8b 45 08             	mov    0x8(%ebp),%eax
c0102645:	89 04 24             	mov    %eax,(%esp)
c0102648:	e8 a3 fb ff ff       	call   c01021f0 <print_trapframe>
            panic("unexpected trap in kernel.\n");
c010264d:	c7 44 24 08 8e 8f 10 	movl   $0xc0108f8e,0x8(%esp)
c0102654:	c0 
c0102655:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
c010265c:	00 
c010265d:	c7 04 24 2e 8d 10 c0 	movl   $0xc0108d2e,(%esp)
c0102664:	e8 cc dd ff ff       	call   c0100435 <__panic>
        break;
c0102669:	90                   	nop
c010266a:	eb 01                	jmp    c010266d <trap_dispatch+0x12c>
        break;
c010266c:	90                   	nop
        }
    }
}
c010266d:	90                   	nop
c010266e:	c9                   	leave  
c010266f:	c3                   	ret    

c0102670 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c0102670:	f3 0f 1e fb          	endbr32 
c0102674:	55                   	push   %ebp
c0102675:	89 e5                	mov    %esp,%ebp
c0102677:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c010267a:	8b 45 08             	mov    0x8(%ebp),%eax
c010267d:	89 04 24             	mov    %eax,(%esp)
c0102680:	e8 bc fe ff ff       	call   c0102541 <trap_dispatch>
}
c0102685:	90                   	nop
c0102686:	c9                   	leave  
c0102687:	c3                   	ret    

c0102688 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0102688:	6a 00                	push   $0x0
  pushl $0
c010268a:	6a 00                	push   $0x0
  jmp __alltraps
c010268c:	e9 69 0a 00 00       	jmp    c01030fa <__alltraps>

c0102691 <vector1>:
.globl vector1
vector1:
  pushl $0
c0102691:	6a 00                	push   $0x0
  pushl $1
c0102693:	6a 01                	push   $0x1
  jmp __alltraps
c0102695:	e9 60 0a 00 00       	jmp    c01030fa <__alltraps>

c010269a <vector2>:
.globl vector2
vector2:
  pushl $0
c010269a:	6a 00                	push   $0x0
  pushl $2
c010269c:	6a 02                	push   $0x2
  jmp __alltraps
c010269e:	e9 57 0a 00 00       	jmp    c01030fa <__alltraps>

c01026a3 <vector3>:
.globl vector3
vector3:
  pushl $0
c01026a3:	6a 00                	push   $0x0
  pushl $3
c01026a5:	6a 03                	push   $0x3
  jmp __alltraps
c01026a7:	e9 4e 0a 00 00       	jmp    c01030fa <__alltraps>

c01026ac <vector4>:
.globl vector4
vector4:
  pushl $0
c01026ac:	6a 00                	push   $0x0
  pushl $4
c01026ae:	6a 04                	push   $0x4
  jmp __alltraps
c01026b0:	e9 45 0a 00 00       	jmp    c01030fa <__alltraps>

c01026b5 <vector5>:
.globl vector5
vector5:
  pushl $0
c01026b5:	6a 00                	push   $0x0
  pushl $5
c01026b7:	6a 05                	push   $0x5
  jmp __alltraps
c01026b9:	e9 3c 0a 00 00       	jmp    c01030fa <__alltraps>

c01026be <vector6>:
.globl vector6
vector6:
  pushl $0
c01026be:	6a 00                	push   $0x0
  pushl $6
c01026c0:	6a 06                	push   $0x6
  jmp __alltraps
c01026c2:	e9 33 0a 00 00       	jmp    c01030fa <__alltraps>

c01026c7 <vector7>:
.globl vector7
vector7:
  pushl $0
c01026c7:	6a 00                	push   $0x0
  pushl $7
c01026c9:	6a 07                	push   $0x7
  jmp __alltraps
c01026cb:	e9 2a 0a 00 00       	jmp    c01030fa <__alltraps>

c01026d0 <vector8>:
.globl vector8
vector8:
  pushl $8
c01026d0:	6a 08                	push   $0x8
  jmp __alltraps
c01026d2:	e9 23 0a 00 00       	jmp    c01030fa <__alltraps>

c01026d7 <vector9>:
.globl vector9
vector9:
  pushl $0
c01026d7:	6a 00                	push   $0x0
  pushl $9
c01026d9:	6a 09                	push   $0x9
  jmp __alltraps
c01026db:	e9 1a 0a 00 00       	jmp    c01030fa <__alltraps>

c01026e0 <vector10>:
.globl vector10
vector10:
  pushl $10
c01026e0:	6a 0a                	push   $0xa
  jmp __alltraps
c01026e2:	e9 13 0a 00 00       	jmp    c01030fa <__alltraps>

c01026e7 <vector11>:
.globl vector11
vector11:
  pushl $11
c01026e7:	6a 0b                	push   $0xb
  jmp __alltraps
c01026e9:	e9 0c 0a 00 00       	jmp    c01030fa <__alltraps>

c01026ee <vector12>:
.globl vector12
vector12:
  pushl $12
c01026ee:	6a 0c                	push   $0xc
  jmp __alltraps
c01026f0:	e9 05 0a 00 00       	jmp    c01030fa <__alltraps>

c01026f5 <vector13>:
.globl vector13
vector13:
  pushl $13
c01026f5:	6a 0d                	push   $0xd
  jmp __alltraps
c01026f7:	e9 fe 09 00 00       	jmp    c01030fa <__alltraps>

c01026fc <vector14>:
.globl vector14
vector14:
  pushl $14
c01026fc:	6a 0e                	push   $0xe
  jmp __alltraps
c01026fe:	e9 f7 09 00 00       	jmp    c01030fa <__alltraps>

c0102703 <vector15>:
.globl vector15
vector15:
  pushl $0
c0102703:	6a 00                	push   $0x0
  pushl $15
c0102705:	6a 0f                	push   $0xf
  jmp __alltraps
c0102707:	e9 ee 09 00 00       	jmp    c01030fa <__alltraps>

c010270c <vector16>:
.globl vector16
vector16:
  pushl $0
c010270c:	6a 00                	push   $0x0
  pushl $16
c010270e:	6a 10                	push   $0x10
  jmp __alltraps
c0102710:	e9 e5 09 00 00       	jmp    c01030fa <__alltraps>

c0102715 <vector17>:
.globl vector17
vector17:
  pushl $17
c0102715:	6a 11                	push   $0x11
  jmp __alltraps
c0102717:	e9 de 09 00 00       	jmp    c01030fa <__alltraps>

c010271c <vector18>:
.globl vector18
vector18:
  pushl $0
c010271c:	6a 00                	push   $0x0
  pushl $18
c010271e:	6a 12                	push   $0x12
  jmp __alltraps
c0102720:	e9 d5 09 00 00       	jmp    c01030fa <__alltraps>

c0102725 <vector19>:
.globl vector19
vector19:
  pushl $0
c0102725:	6a 00                	push   $0x0
  pushl $19
c0102727:	6a 13                	push   $0x13
  jmp __alltraps
c0102729:	e9 cc 09 00 00       	jmp    c01030fa <__alltraps>

c010272e <vector20>:
.globl vector20
vector20:
  pushl $0
c010272e:	6a 00                	push   $0x0
  pushl $20
c0102730:	6a 14                	push   $0x14
  jmp __alltraps
c0102732:	e9 c3 09 00 00       	jmp    c01030fa <__alltraps>

c0102737 <vector21>:
.globl vector21
vector21:
  pushl $0
c0102737:	6a 00                	push   $0x0
  pushl $21
c0102739:	6a 15                	push   $0x15
  jmp __alltraps
c010273b:	e9 ba 09 00 00       	jmp    c01030fa <__alltraps>

c0102740 <vector22>:
.globl vector22
vector22:
  pushl $0
c0102740:	6a 00                	push   $0x0
  pushl $22
c0102742:	6a 16                	push   $0x16
  jmp __alltraps
c0102744:	e9 b1 09 00 00       	jmp    c01030fa <__alltraps>

c0102749 <vector23>:
.globl vector23
vector23:
  pushl $0
c0102749:	6a 00                	push   $0x0
  pushl $23
c010274b:	6a 17                	push   $0x17
  jmp __alltraps
c010274d:	e9 a8 09 00 00       	jmp    c01030fa <__alltraps>

c0102752 <vector24>:
.globl vector24
vector24:
  pushl $0
c0102752:	6a 00                	push   $0x0
  pushl $24
c0102754:	6a 18                	push   $0x18
  jmp __alltraps
c0102756:	e9 9f 09 00 00       	jmp    c01030fa <__alltraps>

c010275b <vector25>:
.globl vector25
vector25:
  pushl $0
c010275b:	6a 00                	push   $0x0
  pushl $25
c010275d:	6a 19                	push   $0x19
  jmp __alltraps
c010275f:	e9 96 09 00 00       	jmp    c01030fa <__alltraps>

c0102764 <vector26>:
.globl vector26
vector26:
  pushl $0
c0102764:	6a 00                	push   $0x0
  pushl $26
c0102766:	6a 1a                	push   $0x1a
  jmp __alltraps
c0102768:	e9 8d 09 00 00       	jmp    c01030fa <__alltraps>

c010276d <vector27>:
.globl vector27
vector27:
  pushl $0
c010276d:	6a 00                	push   $0x0
  pushl $27
c010276f:	6a 1b                	push   $0x1b
  jmp __alltraps
c0102771:	e9 84 09 00 00       	jmp    c01030fa <__alltraps>

c0102776 <vector28>:
.globl vector28
vector28:
  pushl $0
c0102776:	6a 00                	push   $0x0
  pushl $28
c0102778:	6a 1c                	push   $0x1c
  jmp __alltraps
c010277a:	e9 7b 09 00 00       	jmp    c01030fa <__alltraps>

c010277f <vector29>:
.globl vector29
vector29:
  pushl $0
c010277f:	6a 00                	push   $0x0
  pushl $29
c0102781:	6a 1d                	push   $0x1d
  jmp __alltraps
c0102783:	e9 72 09 00 00       	jmp    c01030fa <__alltraps>

c0102788 <vector30>:
.globl vector30
vector30:
  pushl $0
c0102788:	6a 00                	push   $0x0
  pushl $30
c010278a:	6a 1e                	push   $0x1e
  jmp __alltraps
c010278c:	e9 69 09 00 00       	jmp    c01030fa <__alltraps>

c0102791 <vector31>:
.globl vector31
vector31:
  pushl $0
c0102791:	6a 00                	push   $0x0
  pushl $31
c0102793:	6a 1f                	push   $0x1f
  jmp __alltraps
c0102795:	e9 60 09 00 00       	jmp    c01030fa <__alltraps>

c010279a <vector32>:
.globl vector32
vector32:
  pushl $0
c010279a:	6a 00                	push   $0x0
  pushl $32
c010279c:	6a 20                	push   $0x20
  jmp __alltraps
c010279e:	e9 57 09 00 00       	jmp    c01030fa <__alltraps>

c01027a3 <vector33>:
.globl vector33
vector33:
  pushl $0
c01027a3:	6a 00                	push   $0x0
  pushl $33
c01027a5:	6a 21                	push   $0x21
  jmp __alltraps
c01027a7:	e9 4e 09 00 00       	jmp    c01030fa <__alltraps>

c01027ac <vector34>:
.globl vector34
vector34:
  pushl $0
c01027ac:	6a 00                	push   $0x0
  pushl $34
c01027ae:	6a 22                	push   $0x22
  jmp __alltraps
c01027b0:	e9 45 09 00 00       	jmp    c01030fa <__alltraps>

c01027b5 <vector35>:
.globl vector35
vector35:
  pushl $0
c01027b5:	6a 00                	push   $0x0
  pushl $35
c01027b7:	6a 23                	push   $0x23
  jmp __alltraps
c01027b9:	e9 3c 09 00 00       	jmp    c01030fa <__alltraps>

c01027be <vector36>:
.globl vector36
vector36:
  pushl $0
c01027be:	6a 00                	push   $0x0
  pushl $36
c01027c0:	6a 24                	push   $0x24
  jmp __alltraps
c01027c2:	e9 33 09 00 00       	jmp    c01030fa <__alltraps>

c01027c7 <vector37>:
.globl vector37
vector37:
  pushl $0
c01027c7:	6a 00                	push   $0x0
  pushl $37
c01027c9:	6a 25                	push   $0x25
  jmp __alltraps
c01027cb:	e9 2a 09 00 00       	jmp    c01030fa <__alltraps>

c01027d0 <vector38>:
.globl vector38
vector38:
  pushl $0
c01027d0:	6a 00                	push   $0x0
  pushl $38
c01027d2:	6a 26                	push   $0x26
  jmp __alltraps
c01027d4:	e9 21 09 00 00       	jmp    c01030fa <__alltraps>

c01027d9 <vector39>:
.globl vector39
vector39:
  pushl $0
c01027d9:	6a 00                	push   $0x0
  pushl $39
c01027db:	6a 27                	push   $0x27
  jmp __alltraps
c01027dd:	e9 18 09 00 00       	jmp    c01030fa <__alltraps>

c01027e2 <vector40>:
.globl vector40
vector40:
  pushl $0
c01027e2:	6a 00                	push   $0x0
  pushl $40
c01027e4:	6a 28                	push   $0x28
  jmp __alltraps
c01027e6:	e9 0f 09 00 00       	jmp    c01030fa <__alltraps>

c01027eb <vector41>:
.globl vector41
vector41:
  pushl $0
c01027eb:	6a 00                	push   $0x0
  pushl $41
c01027ed:	6a 29                	push   $0x29
  jmp __alltraps
c01027ef:	e9 06 09 00 00       	jmp    c01030fa <__alltraps>

c01027f4 <vector42>:
.globl vector42
vector42:
  pushl $0
c01027f4:	6a 00                	push   $0x0
  pushl $42
c01027f6:	6a 2a                	push   $0x2a
  jmp __alltraps
c01027f8:	e9 fd 08 00 00       	jmp    c01030fa <__alltraps>

c01027fd <vector43>:
.globl vector43
vector43:
  pushl $0
c01027fd:	6a 00                	push   $0x0
  pushl $43
c01027ff:	6a 2b                	push   $0x2b
  jmp __alltraps
c0102801:	e9 f4 08 00 00       	jmp    c01030fa <__alltraps>

c0102806 <vector44>:
.globl vector44
vector44:
  pushl $0
c0102806:	6a 00                	push   $0x0
  pushl $44
c0102808:	6a 2c                	push   $0x2c
  jmp __alltraps
c010280a:	e9 eb 08 00 00       	jmp    c01030fa <__alltraps>

c010280f <vector45>:
.globl vector45
vector45:
  pushl $0
c010280f:	6a 00                	push   $0x0
  pushl $45
c0102811:	6a 2d                	push   $0x2d
  jmp __alltraps
c0102813:	e9 e2 08 00 00       	jmp    c01030fa <__alltraps>

c0102818 <vector46>:
.globl vector46
vector46:
  pushl $0
c0102818:	6a 00                	push   $0x0
  pushl $46
c010281a:	6a 2e                	push   $0x2e
  jmp __alltraps
c010281c:	e9 d9 08 00 00       	jmp    c01030fa <__alltraps>

c0102821 <vector47>:
.globl vector47
vector47:
  pushl $0
c0102821:	6a 00                	push   $0x0
  pushl $47
c0102823:	6a 2f                	push   $0x2f
  jmp __alltraps
c0102825:	e9 d0 08 00 00       	jmp    c01030fa <__alltraps>

c010282a <vector48>:
.globl vector48
vector48:
  pushl $0
c010282a:	6a 00                	push   $0x0
  pushl $48
c010282c:	6a 30                	push   $0x30
  jmp __alltraps
c010282e:	e9 c7 08 00 00       	jmp    c01030fa <__alltraps>

c0102833 <vector49>:
.globl vector49
vector49:
  pushl $0
c0102833:	6a 00                	push   $0x0
  pushl $49
c0102835:	6a 31                	push   $0x31
  jmp __alltraps
c0102837:	e9 be 08 00 00       	jmp    c01030fa <__alltraps>

c010283c <vector50>:
.globl vector50
vector50:
  pushl $0
c010283c:	6a 00                	push   $0x0
  pushl $50
c010283e:	6a 32                	push   $0x32
  jmp __alltraps
c0102840:	e9 b5 08 00 00       	jmp    c01030fa <__alltraps>

c0102845 <vector51>:
.globl vector51
vector51:
  pushl $0
c0102845:	6a 00                	push   $0x0
  pushl $51
c0102847:	6a 33                	push   $0x33
  jmp __alltraps
c0102849:	e9 ac 08 00 00       	jmp    c01030fa <__alltraps>

c010284e <vector52>:
.globl vector52
vector52:
  pushl $0
c010284e:	6a 00                	push   $0x0
  pushl $52
c0102850:	6a 34                	push   $0x34
  jmp __alltraps
c0102852:	e9 a3 08 00 00       	jmp    c01030fa <__alltraps>

c0102857 <vector53>:
.globl vector53
vector53:
  pushl $0
c0102857:	6a 00                	push   $0x0
  pushl $53
c0102859:	6a 35                	push   $0x35
  jmp __alltraps
c010285b:	e9 9a 08 00 00       	jmp    c01030fa <__alltraps>

c0102860 <vector54>:
.globl vector54
vector54:
  pushl $0
c0102860:	6a 00                	push   $0x0
  pushl $54
c0102862:	6a 36                	push   $0x36
  jmp __alltraps
c0102864:	e9 91 08 00 00       	jmp    c01030fa <__alltraps>

c0102869 <vector55>:
.globl vector55
vector55:
  pushl $0
c0102869:	6a 00                	push   $0x0
  pushl $55
c010286b:	6a 37                	push   $0x37
  jmp __alltraps
c010286d:	e9 88 08 00 00       	jmp    c01030fa <__alltraps>

c0102872 <vector56>:
.globl vector56
vector56:
  pushl $0
c0102872:	6a 00                	push   $0x0
  pushl $56
c0102874:	6a 38                	push   $0x38
  jmp __alltraps
c0102876:	e9 7f 08 00 00       	jmp    c01030fa <__alltraps>

c010287b <vector57>:
.globl vector57
vector57:
  pushl $0
c010287b:	6a 00                	push   $0x0
  pushl $57
c010287d:	6a 39                	push   $0x39
  jmp __alltraps
c010287f:	e9 76 08 00 00       	jmp    c01030fa <__alltraps>

c0102884 <vector58>:
.globl vector58
vector58:
  pushl $0
c0102884:	6a 00                	push   $0x0
  pushl $58
c0102886:	6a 3a                	push   $0x3a
  jmp __alltraps
c0102888:	e9 6d 08 00 00       	jmp    c01030fa <__alltraps>

c010288d <vector59>:
.globl vector59
vector59:
  pushl $0
c010288d:	6a 00                	push   $0x0
  pushl $59
c010288f:	6a 3b                	push   $0x3b
  jmp __alltraps
c0102891:	e9 64 08 00 00       	jmp    c01030fa <__alltraps>

c0102896 <vector60>:
.globl vector60
vector60:
  pushl $0
c0102896:	6a 00                	push   $0x0
  pushl $60
c0102898:	6a 3c                	push   $0x3c
  jmp __alltraps
c010289a:	e9 5b 08 00 00       	jmp    c01030fa <__alltraps>

c010289f <vector61>:
.globl vector61
vector61:
  pushl $0
c010289f:	6a 00                	push   $0x0
  pushl $61
c01028a1:	6a 3d                	push   $0x3d
  jmp __alltraps
c01028a3:	e9 52 08 00 00       	jmp    c01030fa <__alltraps>

c01028a8 <vector62>:
.globl vector62
vector62:
  pushl $0
c01028a8:	6a 00                	push   $0x0
  pushl $62
c01028aa:	6a 3e                	push   $0x3e
  jmp __alltraps
c01028ac:	e9 49 08 00 00       	jmp    c01030fa <__alltraps>

c01028b1 <vector63>:
.globl vector63
vector63:
  pushl $0
c01028b1:	6a 00                	push   $0x0
  pushl $63
c01028b3:	6a 3f                	push   $0x3f
  jmp __alltraps
c01028b5:	e9 40 08 00 00       	jmp    c01030fa <__alltraps>

c01028ba <vector64>:
.globl vector64
vector64:
  pushl $0
c01028ba:	6a 00                	push   $0x0
  pushl $64
c01028bc:	6a 40                	push   $0x40
  jmp __alltraps
c01028be:	e9 37 08 00 00       	jmp    c01030fa <__alltraps>

c01028c3 <vector65>:
.globl vector65
vector65:
  pushl $0
c01028c3:	6a 00                	push   $0x0
  pushl $65
c01028c5:	6a 41                	push   $0x41
  jmp __alltraps
c01028c7:	e9 2e 08 00 00       	jmp    c01030fa <__alltraps>

c01028cc <vector66>:
.globl vector66
vector66:
  pushl $0
c01028cc:	6a 00                	push   $0x0
  pushl $66
c01028ce:	6a 42                	push   $0x42
  jmp __alltraps
c01028d0:	e9 25 08 00 00       	jmp    c01030fa <__alltraps>

c01028d5 <vector67>:
.globl vector67
vector67:
  pushl $0
c01028d5:	6a 00                	push   $0x0
  pushl $67
c01028d7:	6a 43                	push   $0x43
  jmp __alltraps
c01028d9:	e9 1c 08 00 00       	jmp    c01030fa <__alltraps>

c01028de <vector68>:
.globl vector68
vector68:
  pushl $0
c01028de:	6a 00                	push   $0x0
  pushl $68
c01028e0:	6a 44                	push   $0x44
  jmp __alltraps
c01028e2:	e9 13 08 00 00       	jmp    c01030fa <__alltraps>

c01028e7 <vector69>:
.globl vector69
vector69:
  pushl $0
c01028e7:	6a 00                	push   $0x0
  pushl $69
c01028e9:	6a 45                	push   $0x45
  jmp __alltraps
c01028eb:	e9 0a 08 00 00       	jmp    c01030fa <__alltraps>

c01028f0 <vector70>:
.globl vector70
vector70:
  pushl $0
c01028f0:	6a 00                	push   $0x0
  pushl $70
c01028f2:	6a 46                	push   $0x46
  jmp __alltraps
c01028f4:	e9 01 08 00 00       	jmp    c01030fa <__alltraps>

c01028f9 <vector71>:
.globl vector71
vector71:
  pushl $0
c01028f9:	6a 00                	push   $0x0
  pushl $71
c01028fb:	6a 47                	push   $0x47
  jmp __alltraps
c01028fd:	e9 f8 07 00 00       	jmp    c01030fa <__alltraps>

c0102902 <vector72>:
.globl vector72
vector72:
  pushl $0
c0102902:	6a 00                	push   $0x0
  pushl $72
c0102904:	6a 48                	push   $0x48
  jmp __alltraps
c0102906:	e9 ef 07 00 00       	jmp    c01030fa <__alltraps>

c010290b <vector73>:
.globl vector73
vector73:
  pushl $0
c010290b:	6a 00                	push   $0x0
  pushl $73
c010290d:	6a 49                	push   $0x49
  jmp __alltraps
c010290f:	e9 e6 07 00 00       	jmp    c01030fa <__alltraps>

c0102914 <vector74>:
.globl vector74
vector74:
  pushl $0
c0102914:	6a 00                	push   $0x0
  pushl $74
c0102916:	6a 4a                	push   $0x4a
  jmp __alltraps
c0102918:	e9 dd 07 00 00       	jmp    c01030fa <__alltraps>

c010291d <vector75>:
.globl vector75
vector75:
  pushl $0
c010291d:	6a 00                	push   $0x0
  pushl $75
c010291f:	6a 4b                	push   $0x4b
  jmp __alltraps
c0102921:	e9 d4 07 00 00       	jmp    c01030fa <__alltraps>

c0102926 <vector76>:
.globl vector76
vector76:
  pushl $0
c0102926:	6a 00                	push   $0x0
  pushl $76
c0102928:	6a 4c                	push   $0x4c
  jmp __alltraps
c010292a:	e9 cb 07 00 00       	jmp    c01030fa <__alltraps>

c010292f <vector77>:
.globl vector77
vector77:
  pushl $0
c010292f:	6a 00                	push   $0x0
  pushl $77
c0102931:	6a 4d                	push   $0x4d
  jmp __alltraps
c0102933:	e9 c2 07 00 00       	jmp    c01030fa <__alltraps>

c0102938 <vector78>:
.globl vector78
vector78:
  pushl $0
c0102938:	6a 00                	push   $0x0
  pushl $78
c010293a:	6a 4e                	push   $0x4e
  jmp __alltraps
c010293c:	e9 b9 07 00 00       	jmp    c01030fa <__alltraps>

c0102941 <vector79>:
.globl vector79
vector79:
  pushl $0
c0102941:	6a 00                	push   $0x0
  pushl $79
c0102943:	6a 4f                	push   $0x4f
  jmp __alltraps
c0102945:	e9 b0 07 00 00       	jmp    c01030fa <__alltraps>

c010294a <vector80>:
.globl vector80
vector80:
  pushl $0
c010294a:	6a 00                	push   $0x0
  pushl $80
c010294c:	6a 50                	push   $0x50
  jmp __alltraps
c010294e:	e9 a7 07 00 00       	jmp    c01030fa <__alltraps>

c0102953 <vector81>:
.globl vector81
vector81:
  pushl $0
c0102953:	6a 00                	push   $0x0
  pushl $81
c0102955:	6a 51                	push   $0x51
  jmp __alltraps
c0102957:	e9 9e 07 00 00       	jmp    c01030fa <__alltraps>

c010295c <vector82>:
.globl vector82
vector82:
  pushl $0
c010295c:	6a 00                	push   $0x0
  pushl $82
c010295e:	6a 52                	push   $0x52
  jmp __alltraps
c0102960:	e9 95 07 00 00       	jmp    c01030fa <__alltraps>

c0102965 <vector83>:
.globl vector83
vector83:
  pushl $0
c0102965:	6a 00                	push   $0x0
  pushl $83
c0102967:	6a 53                	push   $0x53
  jmp __alltraps
c0102969:	e9 8c 07 00 00       	jmp    c01030fa <__alltraps>

c010296e <vector84>:
.globl vector84
vector84:
  pushl $0
c010296e:	6a 00                	push   $0x0
  pushl $84
c0102970:	6a 54                	push   $0x54
  jmp __alltraps
c0102972:	e9 83 07 00 00       	jmp    c01030fa <__alltraps>

c0102977 <vector85>:
.globl vector85
vector85:
  pushl $0
c0102977:	6a 00                	push   $0x0
  pushl $85
c0102979:	6a 55                	push   $0x55
  jmp __alltraps
c010297b:	e9 7a 07 00 00       	jmp    c01030fa <__alltraps>

c0102980 <vector86>:
.globl vector86
vector86:
  pushl $0
c0102980:	6a 00                	push   $0x0
  pushl $86
c0102982:	6a 56                	push   $0x56
  jmp __alltraps
c0102984:	e9 71 07 00 00       	jmp    c01030fa <__alltraps>

c0102989 <vector87>:
.globl vector87
vector87:
  pushl $0
c0102989:	6a 00                	push   $0x0
  pushl $87
c010298b:	6a 57                	push   $0x57
  jmp __alltraps
c010298d:	e9 68 07 00 00       	jmp    c01030fa <__alltraps>

c0102992 <vector88>:
.globl vector88
vector88:
  pushl $0
c0102992:	6a 00                	push   $0x0
  pushl $88
c0102994:	6a 58                	push   $0x58
  jmp __alltraps
c0102996:	e9 5f 07 00 00       	jmp    c01030fa <__alltraps>

c010299b <vector89>:
.globl vector89
vector89:
  pushl $0
c010299b:	6a 00                	push   $0x0
  pushl $89
c010299d:	6a 59                	push   $0x59
  jmp __alltraps
c010299f:	e9 56 07 00 00       	jmp    c01030fa <__alltraps>

c01029a4 <vector90>:
.globl vector90
vector90:
  pushl $0
c01029a4:	6a 00                	push   $0x0
  pushl $90
c01029a6:	6a 5a                	push   $0x5a
  jmp __alltraps
c01029a8:	e9 4d 07 00 00       	jmp    c01030fa <__alltraps>

c01029ad <vector91>:
.globl vector91
vector91:
  pushl $0
c01029ad:	6a 00                	push   $0x0
  pushl $91
c01029af:	6a 5b                	push   $0x5b
  jmp __alltraps
c01029b1:	e9 44 07 00 00       	jmp    c01030fa <__alltraps>

c01029b6 <vector92>:
.globl vector92
vector92:
  pushl $0
c01029b6:	6a 00                	push   $0x0
  pushl $92
c01029b8:	6a 5c                	push   $0x5c
  jmp __alltraps
c01029ba:	e9 3b 07 00 00       	jmp    c01030fa <__alltraps>

c01029bf <vector93>:
.globl vector93
vector93:
  pushl $0
c01029bf:	6a 00                	push   $0x0
  pushl $93
c01029c1:	6a 5d                	push   $0x5d
  jmp __alltraps
c01029c3:	e9 32 07 00 00       	jmp    c01030fa <__alltraps>

c01029c8 <vector94>:
.globl vector94
vector94:
  pushl $0
c01029c8:	6a 00                	push   $0x0
  pushl $94
c01029ca:	6a 5e                	push   $0x5e
  jmp __alltraps
c01029cc:	e9 29 07 00 00       	jmp    c01030fa <__alltraps>

c01029d1 <vector95>:
.globl vector95
vector95:
  pushl $0
c01029d1:	6a 00                	push   $0x0
  pushl $95
c01029d3:	6a 5f                	push   $0x5f
  jmp __alltraps
c01029d5:	e9 20 07 00 00       	jmp    c01030fa <__alltraps>

c01029da <vector96>:
.globl vector96
vector96:
  pushl $0
c01029da:	6a 00                	push   $0x0
  pushl $96
c01029dc:	6a 60                	push   $0x60
  jmp __alltraps
c01029de:	e9 17 07 00 00       	jmp    c01030fa <__alltraps>

c01029e3 <vector97>:
.globl vector97
vector97:
  pushl $0
c01029e3:	6a 00                	push   $0x0
  pushl $97
c01029e5:	6a 61                	push   $0x61
  jmp __alltraps
c01029e7:	e9 0e 07 00 00       	jmp    c01030fa <__alltraps>

c01029ec <vector98>:
.globl vector98
vector98:
  pushl $0
c01029ec:	6a 00                	push   $0x0
  pushl $98
c01029ee:	6a 62                	push   $0x62
  jmp __alltraps
c01029f0:	e9 05 07 00 00       	jmp    c01030fa <__alltraps>

c01029f5 <vector99>:
.globl vector99
vector99:
  pushl $0
c01029f5:	6a 00                	push   $0x0
  pushl $99
c01029f7:	6a 63                	push   $0x63
  jmp __alltraps
c01029f9:	e9 fc 06 00 00       	jmp    c01030fa <__alltraps>

c01029fe <vector100>:
.globl vector100
vector100:
  pushl $0
c01029fe:	6a 00                	push   $0x0
  pushl $100
c0102a00:	6a 64                	push   $0x64
  jmp __alltraps
c0102a02:	e9 f3 06 00 00       	jmp    c01030fa <__alltraps>

c0102a07 <vector101>:
.globl vector101
vector101:
  pushl $0
c0102a07:	6a 00                	push   $0x0
  pushl $101
c0102a09:	6a 65                	push   $0x65
  jmp __alltraps
c0102a0b:	e9 ea 06 00 00       	jmp    c01030fa <__alltraps>

c0102a10 <vector102>:
.globl vector102
vector102:
  pushl $0
c0102a10:	6a 00                	push   $0x0
  pushl $102
c0102a12:	6a 66                	push   $0x66
  jmp __alltraps
c0102a14:	e9 e1 06 00 00       	jmp    c01030fa <__alltraps>

c0102a19 <vector103>:
.globl vector103
vector103:
  pushl $0
c0102a19:	6a 00                	push   $0x0
  pushl $103
c0102a1b:	6a 67                	push   $0x67
  jmp __alltraps
c0102a1d:	e9 d8 06 00 00       	jmp    c01030fa <__alltraps>

c0102a22 <vector104>:
.globl vector104
vector104:
  pushl $0
c0102a22:	6a 00                	push   $0x0
  pushl $104
c0102a24:	6a 68                	push   $0x68
  jmp __alltraps
c0102a26:	e9 cf 06 00 00       	jmp    c01030fa <__alltraps>

c0102a2b <vector105>:
.globl vector105
vector105:
  pushl $0
c0102a2b:	6a 00                	push   $0x0
  pushl $105
c0102a2d:	6a 69                	push   $0x69
  jmp __alltraps
c0102a2f:	e9 c6 06 00 00       	jmp    c01030fa <__alltraps>

c0102a34 <vector106>:
.globl vector106
vector106:
  pushl $0
c0102a34:	6a 00                	push   $0x0
  pushl $106
c0102a36:	6a 6a                	push   $0x6a
  jmp __alltraps
c0102a38:	e9 bd 06 00 00       	jmp    c01030fa <__alltraps>

c0102a3d <vector107>:
.globl vector107
vector107:
  pushl $0
c0102a3d:	6a 00                	push   $0x0
  pushl $107
c0102a3f:	6a 6b                	push   $0x6b
  jmp __alltraps
c0102a41:	e9 b4 06 00 00       	jmp    c01030fa <__alltraps>

c0102a46 <vector108>:
.globl vector108
vector108:
  pushl $0
c0102a46:	6a 00                	push   $0x0
  pushl $108
c0102a48:	6a 6c                	push   $0x6c
  jmp __alltraps
c0102a4a:	e9 ab 06 00 00       	jmp    c01030fa <__alltraps>

c0102a4f <vector109>:
.globl vector109
vector109:
  pushl $0
c0102a4f:	6a 00                	push   $0x0
  pushl $109
c0102a51:	6a 6d                	push   $0x6d
  jmp __alltraps
c0102a53:	e9 a2 06 00 00       	jmp    c01030fa <__alltraps>

c0102a58 <vector110>:
.globl vector110
vector110:
  pushl $0
c0102a58:	6a 00                	push   $0x0
  pushl $110
c0102a5a:	6a 6e                	push   $0x6e
  jmp __alltraps
c0102a5c:	e9 99 06 00 00       	jmp    c01030fa <__alltraps>

c0102a61 <vector111>:
.globl vector111
vector111:
  pushl $0
c0102a61:	6a 00                	push   $0x0
  pushl $111
c0102a63:	6a 6f                	push   $0x6f
  jmp __alltraps
c0102a65:	e9 90 06 00 00       	jmp    c01030fa <__alltraps>

c0102a6a <vector112>:
.globl vector112
vector112:
  pushl $0
c0102a6a:	6a 00                	push   $0x0
  pushl $112
c0102a6c:	6a 70                	push   $0x70
  jmp __alltraps
c0102a6e:	e9 87 06 00 00       	jmp    c01030fa <__alltraps>

c0102a73 <vector113>:
.globl vector113
vector113:
  pushl $0
c0102a73:	6a 00                	push   $0x0
  pushl $113
c0102a75:	6a 71                	push   $0x71
  jmp __alltraps
c0102a77:	e9 7e 06 00 00       	jmp    c01030fa <__alltraps>

c0102a7c <vector114>:
.globl vector114
vector114:
  pushl $0
c0102a7c:	6a 00                	push   $0x0
  pushl $114
c0102a7e:	6a 72                	push   $0x72
  jmp __alltraps
c0102a80:	e9 75 06 00 00       	jmp    c01030fa <__alltraps>

c0102a85 <vector115>:
.globl vector115
vector115:
  pushl $0
c0102a85:	6a 00                	push   $0x0
  pushl $115
c0102a87:	6a 73                	push   $0x73
  jmp __alltraps
c0102a89:	e9 6c 06 00 00       	jmp    c01030fa <__alltraps>

c0102a8e <vector116>:
.globl vector116
vector116:
  pushl $0
c0102a8e:	6a 00                	push   $0x0
  pushl $116
c0102a90:	6a 74                	push   $0x74
  jmp __alltraps
c0102a92:	e9 63 06 00 00       	jmp    c01030fa <__alltraps>

c0102a97 <vector117>:
.globl vector117
vector117:
  pushl $0
c0102a97:	6a 00                	push   $0x0
  pushl $117
c0102a99:	6a 75                	push   $0x75
  jmp __alltraps
c0102a9b:	e9 5a 06 00 00       	jmp    c01030fa <__alltraps>

c0102aa0 <vector118>:
.globl vector118
vector118:
  pushl $0
c0102aa0:	6a 00                	push   $0x0
  pushl $118
c0102aa2:	6a 76                	push   $0x76
  jmp __alltraps
c0102aa4:	e9 51 06 00 00       	jmp    c01030fa <__alltraps>

c0102aa9 <vector119>:
.globl vector119
vector119:
  pushl $0
c0102aa9:	6a 00                	push   $0x0
  pushl $119
c0102aab:	6a 77                	push   $0x77
  jmp __alltraps
c0102aad:	e9 48 06 00 00       	jmp    c01030fa <__alltraps>

c0102ab2 <vector120>:
.globl vector120
vector120:
  pushl $0
c0102ab2:	6a 00                	push   $0x0
  pushl $120
c0102ab4:	6a 78                	push   $0x78
  jmp __alltraps
c0102ab6:	e9 3f 06 00 00       	jmp    c01030fa <__alltraps>

c0102abb <vector121>:
.globl vector121
vector121:
  pushl $0
c0102abb:	6a 00                	push   $0x0
  pushl $121
c0102abd:	6a 79                	push   $0x79
  jmp __alltraps
c0102abf:	e9 36 06 00 00       	jmp    c01030fa <__alltraps>

c0102ac4 <vector122>:
.globl vector122
vector122:
  pushl $0
c0102ac4:	6a 00                	push   $0x0
  pushl $122
c0102ac6:	6a 7a                	push   $0x7a
  jmp __alltraps
c0102ac8:	e9 2d 06 00 00       	jmp    c01030fa <__alltraps>

c0102acd <vector123>:
.globl vector123
vector123:
  pushl $0
c0102acd:	6a 00                	push   $0x0
  pushl $123
c0102acf:	6a 7b                	push   $0x7b
  jmp __alltraps
c0102ad1:	e9 24 06 00 00       	jmp    c01030fa <__alltraps>

c0102ad6 <vector124>:
.globl vector124
vector124:
  pushl $0
c0102ad6:	6a 00                	push   $0x0
  pushl $124
c0102ad8:	6a 7c                	push   $0x7c
  jmp __alltraps
c0102ada:	e9 1b 06 00 00       	jmp    c01030fa <__alltraps>

c0102adf <vector125>:
.globl vector125
vector125:
  pushl $0
c0102adf:	6a 00                	push   $0x0
  pushl $125
c0102ae1:	6a 7d                	push   $0x7d
  jmp __alltraps
c0102ae3:	e9 12 06 00 00       	jmp    c01030fa <__alltraps>

c0102ae8 <vector126>:
.globl vector126
vector126:
  pushl $0
c0102ae8:	6a 00                	push   $0x0
  pushl $126
c0102aea:	6a 7e                	push   $0x7e
  jmp __alltraps
c0102aec:	e9 09 06 00 00       	jmp    c01030fa <__alltraps>

c0102af1 <vector127>:
.globl vector127
vector127:
  pushl $0
c0102af1:	6a 00                	push   $0x0
  pushl $127
c0102af3:	6a 7f                	push   $0x7f
  jmp __alltraps
c0102af5:	e9 00 06 00 00       	jmp    c01030fa <__alltraps>

c0102afa <vector128>:
.globl vector128
vector128:
  pushl $0
c0102afa:	6a 00                	push   $0x0
  pushl $128
c0102afc:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c0102b01:	e9 f4 05 00 00       	jmp    c01030fa <__alltraps>

c0102b06 <vector129>:
.globl vector129
vector129:
  pushl $0
c0102b06:	6a 00                	push   $0x0
  pushl $129
c0102b08:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c0102b0d:	e9 e8 05 00 00       	jmp    c01030fa <__alltraps>

c0102b12 <vector130>:
.globl vector130
vector130:
  pushl $0
c0102b12:	6a 00                	push   $0x0
  pushl $130
c0102b14:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c0102b19:	e9 dc 05 00 00       	jmp    c01030fa <__alltraps>

c0102b1e <vector131>:
.globl vector131
vector131:
  pushl $0
c0102b1e:	6a 00                	push   $0x0
  pushl $131
c0102b20:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c0102b25:	e9 d0 05 00 00       	jmp    c01030fa <__alltraps>

c0102b2a <vector132>:
.globl vector132
vector132:
  pushl $0
c0102b2a:	6a 00                	push   $0x0
  pushl $132
c0102b2c:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c0102b31:	e9 c4 05 00 00       	jmp    c01030fa <__alltraps>

c0102b36 <vector133>:
.globl vector133
vector133:
  pushl $0
c0102b36:	6a 00                	push   $0x0
  pushl $133
c0102b38:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c0102b3d:	e9 b8 05 00 00       	jmp    c01030fa <__alltraps>

c0102b42 <vector134>:
.globl vector134
vector134:
  pushl $0
c0102b42:	6a 00                	push   $0x0
  pushl $134
c0102b44:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c0102b49:	e9 ac 05 00 00       	jmp    c01030fa <__alltraps>

c0102b4e <vector135>:
.globl vector135
vector135:
  pushl $0
c0102b4e:	6a 00                	push   $0x0
  pushl $135
c0102b50:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0102b55:	e9 a0 05 00 00       	jmp    c01030fa <__alltraps>

c0102b5a <vector136>:
.globl vector136
vector136:
  pushl $0
c0102b5a:	6a 00                	push   $0x0
  pushl $136
c0102b5c:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c0102b61:	e9 94 05 00 00       	jmp    c01030fa <__alltraps>

c0102b66 <vector137>:
.globl vector137
vector137:
  pushl $0
c0102b66:	6a 00                	push   $0x0
  pushl $137
c0102b68:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c0102b6d:	e9 88 05 00 00       	jmp    c01030fa <__alltraps>

c0102b72 <vector138>:
.globl vector138
vector138:
  pushl $0
c0102b72:	6a 00                	push   $0x0
  pushl $138
c0102b74:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c0102b79:	e9 7c 05 00 00       	jmp    c01030fa <__alltraps>

c0102b7e <vector139>:
.globl vector139
vector139:
  pushl $0
c0102b7e:	6a 00                	push   $0x0
  pushl $139
c0102b80:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c0102b85:	e9 70 05 00 00       	jmp    c01030fa <__alltraps>

c0102b8a <vector140>:
.globl vector140
vector140:
  pushl $0
c0102b8a:	6a 00                	push   $0x0
  pushl $140
c0102b8c:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c0102b91:	e9 64 05 00 00       	jmp    c01030fa <__alltraps>

c0102b96 <vector141>:
.globl vector141
vector141:
  pushl $0
c0102b96:	6a 00                	push   $0x0
  pushl $141
c0102b98:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c0102b9d:	e9 58 05 00 00       	jmp    c01030fa <__alltraps>

c0102ba2 <vector142>:
.globl vector142
vector142:
  pushl $0
c0102ba2:	6a 00                	push   $0x0
  pushl $142
c0102ba4:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c0102ba9:	e9 4c 05 00 00       	jmp    c01030fa <__alltraps>

c0102bae <vector143>:
.globl vector143
vector143:
  pushl $0
c0102bae:	6a 00                	push   $0x0
  pushl $143
c0102bb0:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c0102bb5:	e9 40 05 00 00       	jmp    c01030fa <__alltraps>

c0102bba <vector144>:
.globl vector144
vector144:
  pushl $0
c0102bba:	6a 00                	push   $0x0
  pushl $144
c0102bbc:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c0102bc1:	e9 34 05 00 00       	jmp    c01030fa <__alltraps>

c0102bc6 <vector145>:
.globl vector145
vector145:
  pushl $0
c0102bc6:	6a 00                	push   $0x0
  pushl $145
c0102bc8:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c0102bcd:	e9 28 05 00 00       	jmp    c01030fa <__alltraps>

c0102bd2 <vector146>:
.globl vector146
vector146:
  pushl $0
c0102bd2:	6a 00                	push   $0x0
  pushl $146
c0102bd4:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c0102bd9:	e9 1c 05 00 00       	jmp    c01030fa <__alltraps>

c0102bde <vector147>:
.globl vector147
vector147:
  pushl $0
c0102bde:	6a 00                	push   $0x0
  pushl $147
c0102be0:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c0102be5:	e9 10 05 00 00       	jmp    c01030fa <__alltraps>

c0102bea <vector148>:
.globl vector148
vector148:
  pushl $0
c0102bea:	6a 00                	push   $0x0
  pushl $148
c0102bec:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c0102bf1:	e9 04 05 00 00       	jmp    c01030fa <__alltraps>

c0102bf6 <vector149>:
.globl vector149
vector149:
  pushl $0
c0102bf6:	6a 00                	push   $0x0
  pushl $149
c0102bf8:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c0102bfd:	e9 f8 04 00 00       	jmp    c01030fa <__alltraps>

c0102c02 <vector150>:
.globl vector150
vector150:
  pushl $0
c0102c02:	6a 00                	push   $0x0
  pushl $150
c0102c04:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c0102c09:	e9 ec 04 00 00       	jmp    c01030fa <__alltraps>

c0102c0e <vector151>:
.globl vector151
vector151:
  pushl $0
c0102c0e:	6a 00                	push   $0x0
  pushl $151
c0102c10:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c0102c15:	e9 e0 04 00 00       	jmp    c01030fa <__alltraps>

c0102c1a <vector152>:
.globl vector152
vector152:
  pushl $0
c0102c1a:	6a 00                	push   $0x0
  pushl $152
c0102c1c:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c0102c21:	e9 d4 04 00 00       	jmp    c01030fa <__alltraps>

c0102c26 <vector153>:
.globl vector153
vector153:
  pushl $0
c0102c26:	6a 00                	push   $0x0
  pushl $153
c0102c28:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c0102c2d:	e9 c8 04 00 00       	jmp    c01030fa <__alltraps>

c0102c32 <vector154>:
.globl vector154
vector154:
  pushl $0
c0102c32:	6a 00                	push   $0x0
  pushl $154
c0102c34:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c0102c39:	e9 bc 04 00 00       	jmp    c01030fa <__alltraps>

c0102c3e <vector155>:
.globl vector155
vector155:
  pushl $0
c0102c3e:	6a 00                	push   $0x0
  pushl $155
c0102c40:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c0102c45:	e9 b0 04 00 00       	jmp    c01030fa <__alltraps>

c0102c4a <vector156>:
.globl vector156
vector156:
  pushl $0
c0102c4a:	6a 00                	push   $0x0
  pushl $156
c0102c4c:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c0102c51:	e9 a4 04 00 00       	jmp    c01030fa <__alltraps>

c0102c56 <vector157>:
.globl vector157
vector157:
  pushl $0
c0102c56:	6a 00                	push   $0x0
  pushl $157
c0102c58:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c0102c5d:	e9 98 04 00 00       	jmp    c01030fa <__alltraps>

c0102c62 <vector158>:
.globl vector158
vector158:
  pushl $0
c0102c62:	6a 00                	push   $0x0
  pushl $158
c0102c64:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c0102c69:	e9 8c 04 00 00       	jmp    c01030fa <__alltraps>

c0102c6e <vector159>:
.globl vector159
vector159:
  pushl $0
c0102c6e:	6a 00                	push   $0x0
  pushl $159
c0102c70:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c0102c75:	e9 80 04 00 00       	jmp    c01030fa <__alltraps>

c0102c7a <vector160>:
.globl vector160
vector160:
  pushl $0
c0102c7a:	6a 00                	push   $0x0
  pushl $160
c0102c7c:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c0102c81:	e9 74 04 00 00       	jmp    c01030fa <__alltraps>

c0102c86 <vector161>:
.globl vector161
vector161:
  pushl $0
c0102c86:	6a 00                	push   $0x0
  pushl $161
c0102c88:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c0102c8d:	e9 68 04 00 00       	jmp    c01030fa <__alltraps>

c0102c92 <vector162>:
.globl vector162
vector162:
  pushl $0
c0102c92:	6a 00                	push   $0x0
  pushl $162
c0102c94:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c0102c99:	e9 5c 04 00 00       	jmp    c01030fa <__alltraps>

c0102c9e <vector163>:
.globl vector163
vector163:
  pushl $0
c0102c9e:	6a 00                	push   $0x0
  pushl $163
c0102ca0:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c0102ca5:	e9 50 04 00 00       	jmp    c01030fa <__alltraps>

c0102caa <vector164>:
.globl vector164
vector164:
  pushl $0
c0102caa:	6a 00                	push   $0x0
  pushl $164
c0102cac:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c0102cb1:	e9 44 04 00 00       	jmp    c01030fa <__alltraps>

c0102cb6 <vector165>:
.globl vector165
vector165:
  pushl $0
c0102cb6:	6a 00                	push   $0x0
  pushl $165
c0102cb8:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c0102cbd:	e9 38 04 00 00       	jmp    c01030fa <__alltraps>

c0102cc2 <vector166>:
.globl vector166
vector166:
  pushl $0
c0102cc2:	6a 00                	push   $0x0
  pushl $166
c0102cc4:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c0102cc9:	e9 2c 04 00 00       	jmp    c01030fa <__alltraps>

c0102cce <vector167>:
.globl vector167
vector167:
  pushl $0
c0102cce:	6a 00                	push   $0x0
  pushl $167
c0102cd0:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c0102cd5:	e9 20 04 00 00       	jmp    c01030fa <__alltraps>

c0102cda <vector168>:
.globl vector168
vector168:
  pushl $0
c0102cda:	6a 00                	push   $0x0
  pushl $168
c0102cdc:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c0102ce1:	e9 14 04 00 00       	jmp    c01030fa <__alltraps>

c0102ce6 <vector169>:
.globl vector169
vector169:
  pushl $0
c0102ce6:	6a 00                	push   $0x0
  pushl $169
c0102ce8:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c0102ced:	e9 08 04 00 00       	jmp    c01030fa <__alltraps>

c0102cf2 <vector170>:
.globl vector170
vector170:
  pushl $0
c0102cf2:	6a 00                	push   $0x0
  pushl $170
c0102cf4:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c0102cf9:	e9 fc 03 00 00       	jmp    c01030fa <__alltraps>

c0102cfe <vector171>:
.globl vector171
vector171:
  pushl $0
c0102cfe:	6a 00                	push   $0x0
  pushl $171
c0102d00:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c0102d05:	e9 f0 03 00 00       	jmp    c01030fa <__alltraps>

c0102d0a <vector172>:
.globl vector172
vector172:
  pushl $0
c0102d0a:	6a 00                	push   $0x0
  pushl $172
c0102d0c:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c0102d11:	e9 e4 03 00 00       	jmp    c01030fa <__alltraps>

c0102d16 <vector173>:
.globl vector173
vector173:
  pushl $0
c0102d16:	6a 00                	push   $0x0
  pushl $173
c0102d18:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c0102d1d:	e9 d8 03 00 00       	jmp    c01030fa <__alltraps>

c0102d22 <vector174>:
.globl vector174
vector174:
  pushl $0
c0102d22:	6a 00                	push   $0x0
  pushl $174
c0102d24:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c0102d29:	e9 cc 03 00 00       	jmp    c01030fa <__alltraps>

c0102d2e <vector175>:
.globl vector175
vector175:
  pushl $0
c0102d2e:	6a 00                	push   $0x0
  pushl $175
c0102d30:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c0102d35:	e9 c0 03 00 00       	jmp    c01030fa <__alltraps>

c0102d3a <vector176>:
.globl vector176
vector176:
  pushl $0
c0102d3a:	6a 00                	push   $0x0
  pushl $176
c0102d3c:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c0102d41:	e9 b4 03 00 00       	jmp    c01030fa <__alltraps>

c0102d46 <vector177>:
.globl vector177
vector177:
  pushl $0
c0102d46:	6a 00                	push   $0x0
  pushl $177
c0102d48:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c0102d4d:	e9 a8 03 00 00       	jmp    c01030fa <__alltraps>

c0102d52 <vector178>:
.globl vector178
vector178:
  pushl $0
c0102d52:	6a 00                	push   $0x0
  pushl $178
c0102d54:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c0102d59:	e9 9c 03 00 00       	jmp    c01030fa <__alltraps>

c0102d5e <vector179>:
.globl vector179
vector179:
  pushl $0
c0102d5e:	6a 00                	push   $0x0
  pushl $179
c0102d60:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c0102d65:	e9 90 03 00 00       	jmp    c01030fa <__alltraps>

c0102d6a <vector180>:
.globl vector180
vector180:
  pushl $0
c0102d6a:	6a 00                	push   $0x0
  pushl $180
c0102d6c:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c0102d71:	e9 84 03 00 00       	jmp    c01030fa <__alltraps>

c0102d76 <vector181>:
.globl vector181
vector181:
  pushl $0
c0102d76:	6a 00                	push   $0x0
  pushl $181
c0102d78:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c0102d7d:	e9 78 03 00 00       	jmp    c01030fa <__alltraps>

c0102d82 <vector182>:
.globl vector182
vector182:
  pushl $0
c0102d82:	6a 00                	push   $0x0
  pushl $182
c0102d84:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c0102d89:	e9 6c 03 00 00       	jmp    c01030fa <__alltraps>

c0102d8e <vector183>:
.globl vector183
vector183:
  pushl $0
c0102d8e:	6a 00                	push   $0x0
  pushl $183
c0102d90:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c0102d95:	e9 60 03 00 00       	jmp    c01030fa <__alltraps>

c0102d9a <vector184>:
.globl vector184
vector184:
  pushl $0
c0102d9a:	6a 00                	push   $0x0
  pushl $184
c0102d9c:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c0102da1:	e9 54 03 00 00       	jmp    c01030fa <__alltraps>

c0102da6 <vector185>:
.globl vector185
vector185:
  pushl $0
c0102da6:	6a 00                	push   $0x0
  pushl $185
c0102da8:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c0102dad:	e9 48 03 00 00       	jmp    c01030fa <__alltraps>

c0102db2 <vector186>:
.globl vector186
vector186:
  pushl $0
c0102db2:	6a 00                	push   $0x0
  pushl $186
c0102db4:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c0102db9:	e9 3c 03 00 00       	jmp    c01030fa <__alltraps>

c0102dbe <vector187>:
.globl vector187
vector187:
  pushl $0
c0102dbe:	6a 00                	push   $0x0
  pushl $187
c0102dc0:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c0102dc5:	e9 30 03 00 00       	jmp    c01030fa <__alltraps>

c0102dca <vector188>:
.globl vector188
vector188:
  pushl $0
c0102dca:	6a 00                	push   $0x0
  pushl $188
c0102dcc:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c0102dd1:	e9 24 03 00 00       	jmp    c01030fa <__alltraps>

c0102dd6 <vector189>:
.globl vector189
vector189:
  pushl $0
c0102dd6:	6a 00                	push   $0x0
  pushl $189
c0102dd8:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c0102ddd:	e9 18 03 00 00       	jmp    c01030fa <__alltraps>

c0102de2 <vector190>:
.globl vector190
vector190:
  pushl $0
c0102de2:	6a 00                	push   $0x0
  pushl $190
c0102de4:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c0102de9:	e9 0c 03 00 00       	jmp    c01030fa <__alltraps>

c0102dee <vector191>:
.globl vector191
vector191:
  pushl $0
c0102dee:	6a 00                	push   $0x0
  pushl $191
c0102df0:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c0102df5:	e9 00 03 00 00       	jmp    c01030fa <__alltraps>

c0102dfa <vector192>:
.globl vector192
vector192:
  pushl $0
c0102dfa:	6a 00                	push   $0x0
  pushl $192
c0102dfc:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c0102e01:	e9 f4 02 00 00       	jmp    c01030fa <__alltraps>

c0102e06 <vector193>:
.globl vector193
vector193:
  pushl $0
c0102e06:	6a 00                	push   $0x0
  pushl $193
c0102e08:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c0102e0d:	e9 e8 02 00 00       	jmp    c01030fa <__alltraps>

c0102e12 <vector194>:
.globl vector194
vector194:
  pushl $0
c0102e12:	6a 00                	push   $0x0
  pushl $194
c0102e14:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c0102e19:	e9 dc 02 00 00       	jmp    c01030fa <__alltraps>

c0102e1e <vector195>:
.globl vector195
vector195:
  pushl $0
c0102e1e:	6a 00                	push   $0x0
  pushl $195
c0102e20:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c0102e25:	e9 d0 02 00 00       	jmp    c01030fa <__alltraps>

c0102e2a <vector196>:
.globl vector196
vector196:
  pushl $0
c0102e2a:	6a 00                	push   $0x0
  pushl $196
c0102e2c:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c0102e31:	e9 c4 02 00 00       	jmp    c01030fa <__alltraps>

c0102e36 <vector197>:
.globl vector197
vector197:
  pushl $0
c0102e36:	6a 00                	push   $0x0
  pushl $197
c0102e38:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c0102e3d:	e9 b8 02 00 00       	jmp    c01030fa <__alltraps>

c0102e42 <vector198>:
.globl vector198
vector198:
  pushl $0
c0102e42:	6a 00                	push   $0x0
  pushl $198
c0102e44:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c0102e49:	e9 ac 02 00 00       	jmp    c01030fa <__alltraps>

c0102e4e <vector199>:
.globl vector199
vector199:
  pushl $0
c0102e4e:	6a 00                	push   $0x0
  pushl $199
c0102e50:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c0102e55:	e9 a0 02 00 00       	jmp    c01030fa <__alltraps>

c0102e5a <vector200>:
.globl vector200
vector200:
  pushl $0
c0102e5a:	6a 00                	push   $0x0
  pushl $200
c0102e5c:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c0102e61:	e9 94 02 00 00       	jmp    c01030fa <__alltraps>

c0102e66 <vector201>:
.globl vector201
vector201:
  pushl $0
c0102e66:	6a 00                	push   $0x0
  pushl $201
c0102e68:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c0102e6d:	e9 88 02 00 00       	jmp    c01030fa <__alltraps>

c0102e72 <vector202>:
.globl vector202
vector202:
  pushl $0
c0102e72:	6a 00                	push   $0x0
  pushl $202
c0102e74:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c0102e79:	e9 7c 02 00 00       	jmp    c01030fa <__alltraps>

c0102e7e <vector203>:
.globl vector203
vector203:
  pushl $0
c0102e7e:	6a 00                	push   $0x0
  pushl $203
c0102e80:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c0102e85:	e9 70 02 00 00       	jmp    c01030fa <__alltraps>

c0102e8a <vector204>:
.globl vector204
vector204:
  pushl $0
c0102e8a:	6a 00                	push   $0x0
  pushl $204
c0102e8c:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c0102e91:	e9 64 02 00 00       	jmp    c01030fa <__alltraps>

c0102e96 <vector205>:
.globl vector205
vector205:
  pushl $0
c0102e96:	6a 00                	push   $0x0
  pushl $205
c0102e98:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c0102e9d:	e9 58 02 00 00       	jmp    c01030fa <__alltraps>

c0102ea2 <vector206>:
.globl vector206
vector206:
  pushl $0
c0102ea2:	6a 00                	push   $0x0
  pushl $206
c0102ea4:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c0102ea9:	e9 4c 02 00 00       	jmp    c01030fa <__alltraps>

c0102eae <vector207>:
.globl vector207
vector207:
  pushl $0
c0102eae:	6a 00                	push   $0x0
  pushl $207
c0102eb0:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c0102eb5:	e9 40 02 00 00       	jmp    c01030fa <__alltraps>

c0102eba <vector208>:
.globl vector208
vector208:
  pushl $0
c0102eba:	6a 00                	push   $0x0
  pushl $208
c0102ebc:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c0102ec1:	e9 34 02 00 00       	jmp    c01030fa <__alltraps>

c0102ec6 <vector209>:
.globl vector209
vector209:
  pushl $0
c0102ec6:	6a 00                	push   $0x0
  pushl $209
c0102ec8:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c0102ecd:	e9 28 02 00 00       	jmp    c01030fa <__alltraps>

c0102ed2 <vector210>:
.globl vector210
vector210:
  pushl $0
c0102ed2:	6a 00                	push   $0x0
  pushl $210
c0102ed4:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c0102ed9:	e9 1c 02 00 00       	jmp    c01030fa <__alltraps>

c0102ede <vector211>:
.globl vector211
vector211:
  pushl $0
c0102ede:	6a 00                	push   $0x0
  pushl $211
c0102ee0:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c0102ee5:	e9 10 02 00 00       	jmp    c01030fa <__alltraps>

c0102eea <vector212>:
.globl vector212
vector212:
  pushl $0
c0102eea:	6a 00                	push   $0x0
  pushl $212
c0102eec:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c0102ef1:	e9 04 02 00 00       	jmp    c01030fa <__alltraps>

c0102ef6 <vector213>:
.globl vector213
vector213:
  pushl $0
c0102ef6:	6a 00                	push   $0x0
  pushl $213
c0102ef8:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c0102efd:	e9 f8 01 00 00       	jmp    c01030fa <__alltraps>

c0102f02 <vector214>:
.globl vector214
vector214:
  pushl $0
c0102f02:	6a 00                	push   $0x0
  pushl $214
c0102f04:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c0102f09:	e9 ec 01 00 00       	jmp    c01030fa <__alltraps>

c0102f0e <vector215>:
.globl vector215
vector215:
  pushl $0
c0102f0e:	6a 00                	push   $0x0
  pushl $215
c0102f10:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c0102f15:	e9 e0 01 00 00       	jmp    c01030fa <__alltraps>

c0102f1a <vector216>:
.globl vector216
vector216:
  pushl $0
c0102f1a:	6a 00                	push   $0x0
  pushl $216
c0102f1c:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c0102f21:	e9 d4 01 00 00       	jmp    c01030fa <__alltraps>

c0102f26 <vector217>:
.globl vector217
vector217:
  pushl $0
c0102f26:	6a 00                	push   $0x0
  pushl $217
c0102f28:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c0102f2d:	e9 c8 01 00 00       	jmp    c01030fa <__alltraps>

c0102f32 <vector218>:
.globl vector218
vector218:
  pushl $0
c0102f32:	6a 00                	push   $0x0
  pushl $218
c0102f34:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c0102f39:	e9 bc 01 00 00       	jmp    c01030fa <__alltraps>

c0102f3e <vector219>:
.globl vector219
vector219:
  pushl $0
c0102f3e:	6a 00                	push   $0x0
  pushl $219
c0102f40:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c0102f45:	e9 b0 01 00 00       	jmp    c01030fa <__alltraps>

c0102f4a <vector220>:
.globl vector220
vector220:
  pushl $0
c0102f4a:	6a 00                	push   $0x0
  pushl $220
c0102f4c:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c0102f51:	e9 a4 01 00 00       	jmp    c01030fa <__alltraps>

c0102f56 <vector221>:
.globl vector221
vector221:
  pushl $0
c0102f56:	6a 00                	push   $0x0
  pushl $221
c0102f58:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c0102f5d:	e9 98 01 00 00       	jmp    c01030fa <__alltraps>

c0102f62 <vector222>:
.globl vector222
vector222:
  pushl $0
c0102f62:	6a 00                	push   $0x0
  pushl $222
c0102f64:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c0102f69:	e9 8c 01 00 00       	jmp    c01030fa <__alltraps>

c0102f6e <vector223>:
.globl vector223
vector223:
  pushl $0
c0102f6e:	6a 00                	push   $0x0
  pushl $223
c0102f70:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c0102f75:	e9 80 01 00 00       	jmp    c01030fa <__alltraps>

c0102f7a <vector224>:
.globl vector224
vector224:
  pushl $0
c0102f7a:	6a 00                	push   $0x0
  pushl $224
c0102f7c:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c0102f81:	e9 74 01 00 00       	jmp    c01030fa <__alltraps>

c0102f86 <vector225>:
.globl vector225
vector225:
  pushl $0
c0102f86:	6a 00                	push   $0x0
  pushl $225
c0102f88:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c0102f8d:	e9 68 01 00 00       	jmp    c01030fa <__alltraps>

c0102f92 <vector226>:
.globl vector226
vector226:
  pushl $0
c0102f92:	6a 00                	push   $0x0
  pushl $226
c0102f94:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c0102f99:	e9 5c 01 00 00       	jmp    c01030fa <__alltraps>

c0102f9e <vector227>:
.globl vector227
vector227:
  pushl $0
c0102f9e:	6a 00                	push   $0x0
  pushl $227
c0102fa0:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c0102fa5:	e9 50 01 00 00       	jmp    c01030fa <__alltraps>

c0102faa <vector228>:
.globl vector228
vector228:
  pushl $0
c0102faa:	6a 00                	push   $0x0
  pushl $228
c0102fac:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c0102fb1:	e9 44 01 00 00       	jmp    c01030fa <__alltraps>

c0102fb6 <vector229>:
.globl vector229
vector229:
  pushl $0
c0102fb6:	6a 00                	push   $0x0
  pushl $229
c0102fb8:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c0102fbd:	e9 38 01 00 00       	jmp    c01030fa <__alltraps>

c0102fc2 <vector230>:
.globl vector230
vector230:
  pushl $0
c0102fc2:	6a 00                	push   $0x0
  pushl $230
c0102fc4:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c0102fc9:	e9 2c 01 00 00       	jmp    c01030fa <__alltraps>

c0102fce <vector231>:
.globl vector231
vector231:
  pushl $0
c0102fce:	6a 00                	push   $0x0
  pushl $231
c0102fd0:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c0102fd5:	e9 20 01 00 00       	jmp    c01030fa <__alltraps>

c0102fda <vector232>:
.globl vector232
vector232:
  pushl $0
c0102fda:	6a 00                	push   $0x0
  pushl $232
c0102fdc:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c0102fe1:	e9 14 01 00 00       	jmp    c01030fa <__alltraps>

c0102fe6 <vector233>:
.globl vector233
vector233:
  pushl $0
c0102fe6:	6a 00                	push   $0x0
  pushl $233
c0102fe8:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c0102fed:	e9 08 01 00 00       	jmp    c01030fa <__alltraps>

c0102ff2 <vector234>:
.globl vector234
vector234:
  pushl $0
c0102ff2:	6a 00                	push   $0x0
  pushl $234
c0102ff4:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c0102ff9:	e9 fc 00 00 00       	jmp    c01030fa <__alltraps>

c0102ffe <vector235>:
.globl vector235
vector235:
  pushl $0
c0102ffe:	6a 00                	push   $0x0
  pushl $235
c0103000:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c0103005:	e9 f0 00 00 00       	jmp    c01030fa <__alltraps>

c010300a <vector236>:
.globl vector236
vector236:
  pushl $0
c010300a:	6a 00                	push   $0x0
  pushl $236
c010300c:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c0103011:	e9 e4 00 00 00       	jmp    c01030fa <__alltraps>

c0103016 <vector237>:
.globl vector237
vector237:
  pushl $0
c0103016:	6a 00                	push   $0x0
  pushl $237
c0103018:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c010301d:	e9 d8 00 00 00       	jmp    c01030fa <__alltraps>

c0103022 <vector238>:
.globl vector238
vector238:
  pushl $0
c0103022:	6a 00                	push   $0x0
  pushl $238
c0103024:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c0103029:	e9 cc 00 00 00       	jmp    c01030fa <__alltraps>

c010302e <vector239>:
.globl vector239
vector239:
  pushl $0
c010302e:	6a 00                	push   $0x0
  pushl $239
c0103030:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c0103035:	e9 c0 00 00 00       	jmp    c01030fa <__alltraps>

c010303a <vector240>:
.globl vector240
vector240:
  pushl $0
c010303a:	6a 00                	push   $0x0
  pushl $240
c010303c:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c0103041:	e9 b4 00 00 00       	jmp    c01030fa <__alltraps>

c0103046 <vector241>:
.globl vector241
vector241:
  pushl $0
c0103046:	6a 00                	push   $0x0
  pushl $241
c0103048:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c010304d:	e9 a8 00 00 00       	jmp    c01030fa <__alltraps>

c0103052 <vector242>:
.globl vector242
vector242:
  pushl $0
c0103052:	6a 00                	push   $0x0
  pushl $242
c0103054:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c0103059:	e9 9c 00 00 00       	jmp    c01030fa <__alltraps>

c010305e <vector243>:
.globl vector243
vector243:
  pushl $0
c010305e:	6a 00                	push   $0x0
  pushl $243
c0103060:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c0103065:	e9 90 00 00 00       	jmp    c01030fa <__alltraps>

c010306a <vector244>:
.globl vector244
vector244:
  pushl $0
c010306a:	6a 00                	push   $0x0
  pushl $244
c010306c:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c0103071:	e9 84 00 00 00       	jmp    c01030fa <__alltraps>

c0103076 <vector245>:
.globl vector245
vector245:
  pushl $0
c0103076:	6a 00                	push   $0x0
  pushl $245
c0103078:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c010307d:	e9 78 00 00 00       	jmp    c01030fa <__alltraps>

c0103082 <vector246>:
.globl vector246
vector246:
  pushl $0
c0103082:	6a 00                	push   $0x0
  pushl $246
c0103084:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c0103089:	e9 6c 00 00 00       	jmp    c01030fa <__alltraps>

c010308e <vector247>:
.globl vector247
vector247:
  pushl $0
c010308e:	6a 00                	push   $0x0
  pushl $247
c0103090:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c0103095:	e9 60 00 00 00       	jmp    c01030fa <__alltraps>

c010309a <vector248>:
.globl vector248
vector248:
  pushl $0
c010309a:	6a 00                	push   $0x0
  pushl $248
c010309c:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c01030a1:	e9 54 00 00 00       	jmp    c01030fa <__alltraps>

c01030a6 <vector249>:
.globl vector249
vector249:
  pushl $0
c01030a6:	6a 00                	push   $0x0
  pushl $249
c01030a8:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c01030ad:	e9 48 00 00 00       	jmp    c01030fa <__alltraps>

c01030b2 <vector250>:
.globl vector250
vector250:
  pushl $0
c01030b2:	6a 00                	push   $0x0
  pushl $250
c01030b4:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c01030b9:	e9 3c 00 00 00       	jmp    c01030fa <__alltraps>

c01030be <vector251>:
.globl vector251
vector251:
  pushl $0
c01030be:	6a 00                	push   $0x0
  pushl $251
c01030c0:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c01030c5:	e9 30 00 00 00       	jmp    c01030fa <__alltraps>

c01030ca <vector252>:
.globl vector252
vector252:
  pushl $0
c01030ca:	6a 00                	push   $0x0
  pushl $252
c01030cc:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c01030d1:	e9 24 00 00 00       	jmp    c01030fa <__alltraps>

c01030d6 <vector253>:
.globl vector253
vector253:
  pushl $0
c01030d6:	6a 00                	push   $0x0
  pushl $253
c01030d8:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c01030dd:	e9 18 00 00 00       	jmp    c01030fa <__alltraps>

c01030e2 <vector254>:
.globl vector254
vector254:
  pushl $0
c01030e2:	6a 00                	push   $0x0
  pushl $254
c01030e4:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c01030e9:	e9 0c 00 00 00       	jmp    c01030fa <__alltraps>

c01030ee <vector255>:
.globl vector255
vector255:
  pushl $0
c01030ee:	6a 00                	push   $0x0
  pushl $255
c01030f0:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c01030f5:	e9 00 00 00 00       	jmp    c01030fa <__alltraps>

c01030fa <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c01030fa:	1e                   	push   %ds
    pushl %es
c01030fb:	06                   	push   %es
    pushl %fs
c01030fc:	0f a0                	push   %fs
    pushl %gs
c01030fe:	0f a8                	push   %gs
    pushal
c0103100:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0103101:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c0103106:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c0103108:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c010310a:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c010310b:	e8 60 f5 ff ff       	call   c0102670 <trap>

    # pop the pushed stack pointer
    popl %esp
c0103110:	5c                   	pop    %esp

c0103111 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0103111:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0103112:	0f a9                	pop    %gs
    popl %fs
c0103114:	0f a1                	pop    %fs
    popl %es
c0103116:	07                   	pop    %es
    popl %ds
c0103117:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c0103118:	83 c4 08             	add    $0x8,%esp
    iret
c010311b:	cf                   	iret   

c010311c <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c010311c:	55                   	push   %ebp
c010311d:	89 e5                	mov    %esp,%ebp
    return page - pages;
c010311f:	a1 28 60 12 c0       	mov    0xc0126028,%eax
c0103124:	8b 55 08             	mov    0x8(%ebp),%edx
c0103127:	29 c2                	sub    %eax,%edx
c0103129:	89 d0                	mov    %edx,%eax
c010312b:	c1 f8 05             	sar    $0x5,%eax
}
c010312e:	5d                   	pop    %ebp
c010312f:	c3                   	ret    

c0103130 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0103130:	55                   	push   %ebp
c0103131:	89 e5                	mov    %esp,%ebp
c0103133:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0103136:	8b 45 08             	mov    0x8(%ebp),%eax
c0103139:	89 04 24             	mov    %eax,(%esp)
c010313c:	e8 db ff ff ff       	call   c010311c <page2ppn>
c0103141:	c1 e0 0c             	shl    $0xc,%eax
}
c0103144:	c9                   	leave  
c0103145:	c3                   	ret    

c0103146 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c0103146:	55                   	push   %ebp
c0103147:	89 e5                	mov    %esp,%ebp
c0103149:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c010314c:	8b 45 08             	mov    0x8(%ebp),%eax
c010314f:	c1 e8 0c             	shr    $0xc,%eax
c0103152:	89 c2                	mov    %eax,%edx
c0103154:	a1 80 5f 12 c0       	mov    0xc0125f80,%eax
c0103159:	39 c2                	cmp    %eax,%edx
c010315b:	72 1c                	jb     c0103179 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c010315d:	c7 44 24 08 d0 91 10 	movl   $0xc01091d0,0x8(%esp)
c0103164:	c0 
c0103165:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
c010316c:	00 
c010316d:	c7 04 24 ef 91 10 c0 	movl   $0xc01091ef,(%esp)
c0103174:	e8 bc d2 ff ff       	call   c0100435 <__panic>
    }
    return &pages[PPN(pa)];
c0103179:	a1 28 60 12 c0       	mov    0xc0126028,%eax
c010317e:	8b 55 08             	mov    0x8(%ebp),%edx
c0103181:	c1 ea 0c             	shr    $0xc,%edx
c0103184:	c1 e2 05             	shl    $0x5,%edx
c0103187:	01 d0                	add    %edx,%eax
}
c0103189:	c9                   	leave  
c010318a:	c3                   	ret    

c010318b <page2kva>:

static inline void *
page2kva(struct Page *page) {
c010318b:	55                   	push   %ebp
c010318c:	89 e5                	mov    %esp,%ebp
c010318e:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0103191:	8b 45 08             	mov    0x8(%ebp),%eax
c0103194:	89 04 24             	mov    %eax,(%esp)
c0103197:	e8 94 ff ff ff       	call   c0103130 <page2pa>
c010319c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010319f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01031a2:	c1 e8 0c             	shr    $0xc,%eax
c01031a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01031a8:	a1 80 5f 12 c0       	mov    0xc0125f80,%eax
c01031ad:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01031b0:	72 23                	jb     c01031d5 <page2kva+0x4a>
c01031b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01031b5:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01031b9:	c7 44 24 08 00 92 10 	movl   $0xc0109200,0x8(%esp)
c01031c0:	c0 
c01031c1:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
c01031c8:	00 
c01031c9:	c7 04 24 ef 91 10 c0 	movl   $0xc01091ef,(%esp)
c01031d0:	e8 60 d2 ff ff       	call   c0100435 <__panic>
c01031d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01031d8:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c01031dd:	c9                   	leave  
c01031de:	c3                   	ret    

c01031df <kva2page>:

static inline struct Page *
kva2page(void *kva) {
c01031df:	55                   	push   %ebp
c01031e0:	89 e5                	mov    %esp,%ebp
c01031e2:	83 ec 28             	sub    $0x28,%esp
    return pa2page(PADDR(kva));
c01031e5:	8b 45 08             	mov    0x8(%ebp),%eax
c01031e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01031eb:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01031f2:	77 23                	ja     c0103217 <kva2page+0x38>
c01031f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01031f7:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01031fb:	c7 44 24 08 24 92 10 	movl   $0xc0109224,0x8(%esp)
c0103202:	c0 
c0103203:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
c010320a:	00 
c010320b:	c7 04 24 ef 91 10 c0 	movl   $0xc01091ef,(%esp)
c0103212:	e8 1e d2 ff ff       	call   c0100435 <__panic>
c0103217:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010321a:	05 00 00 00 40       	add    $0x40000000,%eax
c010321f:	89 04 24             	mov    %eax,(%esp)
c0103222:	e8 1f ff ff ff       	call   c0103146 <pa2page>
}
c0103227:	c9                   	leave  
c0103228:	c3                   	ret    

c0103229 <pte2page>:

static inline struct Page *
pte2page(pte_t pte) {
c0103229:	55                   	push   %ebp
c010322a:	89 e5                	mov    %esp,%ebp
c010322c:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c010322f:	8b 45 08             	mov    0x8(%ebp),%eax
c0103232:	83 e0 01             	and    $0x1,%eax
c0103235:	85 c0                	test   %eax,%eax
c0103237:	75 1c                	jne    c0103255 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0103239:	c7 44 24 08 48 92 10 	movl   $0xc0109248,0x8(%esp)
c0103240:	c0 
c0103241:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c0103248:	00 
c0103249:	c7 04 24 ef 91 10 c0 	movl   $0xc01091ef,(%esp)
c0103250:	e8 e0 d1 ff ff       	call   c0100435 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c0103255:	8b 45 08             	mov    0x8(%ebp),%eax
c0103258:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010325d:	89 04 24             	mov    %eax,(%esp)
c0103260:	e8 e1 fe ff ff       	call   c0103146 <pa2page>
}
c0103265:	c9                   	leave  
c0103266:	c3                   	ret    

c0103267 <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
c0103267:	55                   	push   %ebp
c0103268:	89 e5                	mov    %esp,%ebp
c010326a:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c010326d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103270:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103275:	89 04 24             	mov    %eax,(%esp)
c0103278:	e8 c9 fe ff ff       	call   c0103146 <pa2page>
}
c010327d:	c9                   	leave  
c010327e:	c3                   	ret    

c010327f <page_ref>:

static inline int
page_ref(struct Page *page) {
c010327f:	55                   	push   %ebp
c0103280:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0103282:	8b 45 08             	mov    0x8(%ebp),%eax
c0103285:	8b 00                	mov    (%eax),%eax
}
c0103287:	5d                   	pop    %ebp
c0103288:	c3                   	ret    

c0103289 <page_ref_inc>:
set_page_ref(struct Page *page, int val) {
    page->ref = val;
}

static inline int
page_ref_inc(struct Page *page) {
c0103289:	55                   	push   %ebp
c010328a:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c010328c:	8b 45 08             	mov    0x8(%ebp),%eax
c010328f:	8b 00                	mov    (%eax),%eax
c0103291:	8d 50 01             	lea    0x1(%eax),%edx
c0103294:	8b 45 08             	mov    0x8(%ebp),%eax
c0103297:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0103299:	8b 45 08             	mov    0x8(%ebp),%eax
c010329c:	8b 00                	mov    (%eax),%eax
}
c010329e:	5d                   	pop    %ebp
c010329f:	c3                   	ret    

c01032a0 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c01032a0:	55                   	push   %ebp
c01032a1:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c01032a3:	8b 45 08             	mov    0x8(%ebp),%eax
c01032a6:	8b 00                	mov    (%eax),%eax
c01032a8:	8d 50 ff             	lea    -0x1(%eax),%edx
c01032ab:	8b 45 08             	mov    0x8(%ebp),%eax
c01032ae:	89 10                	mov    %edx,(%eax)
    return page->ref;
c01032b0:	8b 45 08             	mov    0x8(%ebp),%eax
c01032b3:	8b 00                	mov    (%eax),%eax
}
c01032b5:	5d                   	pop    %ebp
c01032b6:	c3                   	ret    

c01032b7 <__intr_save>:
__intr_save(void) {
c01032b7:	55                   	push   %ebp
c01032b8:	89 e5                	mov    %esp,%ebp
c01032ba:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c01032bd:	9c                   	pushf  
c01032be:	58                   	pop    %eax
c01032bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c01032c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c01032c5:	25 00 02 00 00       	and    $0x200,%eax
c01032ca:	85 c0                	test   %eax,%eax
c01032cc:	74 0c                	je     c01032da <__intr_save+0x23>
        intr_disable();
c01032ce:	e8 73 ee ff ff       	call   c0102146 <intr_disable>
        return 1;
c01032d3:	b8 01 00 00 00       	mov    $0x1,%eax
c01032d8:	eb 05                	jmp    c01032df <__intr_save+0x28>
    return 0;
c01032da:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01032df:	c9                   	leave  
c01032e0:	c3                   	ret    

c01032e1 <__intr_restore>:
__intr_restore(bool flag) {
c01032e1:	55                   	push   %ebp
c01032e2:	89 e5                	mov    %esp,%ebp
c01032e4:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c01032e7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01032eb:	74 05                	je     c01032f2 <__intr_restore+0x11>
        intr_enable();
c01032ed:	e8 48 ee ff ff       	call   c010213a <intr_enable>
}
c01032f2:	90                   	nop
c01032f3:	c9                   	leave  
c01032f4:	c3                   	ret    

c01032f5 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c01032f5:	55                   	push   %ebp
c01032f6:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c01032f8:	8b 45 08             	mov    0x8(%ebp),%eax
c01032fb:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c01032fe:	b8 23 00 00 00       	mov    $0x23,%eax
c0103303:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c0103305:	b8 23 00 00 00       	mov    $0x23,%eax
c010330a:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c010330c:	b8 10 00 00 00       	mov    $0x10,%eax
c0103311:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c0103313:	b8 10 00 00 00       	mov    $0x10,%eax
c0103318:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c010331a:	b8 10 00 00 00       	mov    $0x10,%eax
c010331f:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0103321:	ea 28 33 10 c0 08 00 	ljmp   $0x8,$0xc0103328
}
c0103328:	90                   	nop
c0103329:	5d                   	pop    %ebp
c010332a:	c3                   	ret    

c010332b <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c010332b:	f3 0f 1e fb          	endbr32 
c010332f:	55                   	push   %ebp
c0103330:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0103332:	8b 45 08             	mov    0x8(%ebp),%eax
c0103335:	a3 a4 5f 12 c0       	mov    %eax,0xc0125fa4
}
c010333a:	90                   	nop
c010333b:	5d                   	pop    %ebp
c010333c:	c3                   	ret    

c010333d <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c010333d:	f3 0f 1e fb          	endbr32 
c0103341:	55                   	push   %ebp
c0103342:	89 e5                	mov    %esp,%ebp
c0103344:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0103347:	b8 00 20 12 c0       	mov    $0xc0122000,%eax
c010334c:	89 04 24             	mov    %eax,(%esp)
c010334f:	e8 d7 ff ff ff       	call   c010332b <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0103354:	66 c7 05 a8 5f 12 c0 	movw   $0x10,0xc0125fa8
c010335b:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c010335d:	66 c7 05 28 2a 12 c0 	movw   $0x68,0xc0122a28
c0103364:	68 00 
c0103366:	b8 a0 5f 12 c0       	mov    $0xc0125fa0,%eax
c010336b:	0f b7 c0             	movzwl %ax,%eax
c010336e:	66 a3 2a 2a 12 c0    	mov    %ax,0xc0122a2a
c0103374:	b8 a0 5f 12 c0       	mov    $0xc0125fa0,%eax
c0103379:	c1 e8 10             	shr    $0x10,%eax
c010337c:	a2 2c 2a 12 c0       	mov    %al,0xc0122a2c
c0103381:	0f b6 05 2d 2a 12 c0 	movzbl 0xc0122a2d,%eax
c0103388:	24 f0                	and    $0xf0,%al
c010338a:	0c 09                	or     $0x9,%al
c010338c:	a2 2d 2a 12 c0       	mov    %al,0xc0122a2d
c0103391:	0f b6 05 2d 2a 12 c0 	movzbl 0xc0122a2d,%eax
c0103398:	24 ef                	and    $0xef,%al
c010339a:	a2 2d 2a 12 c0       	mov    %al,0xc0122a2d
c010339f:	0f b6 05 2d 2a 12 c0 	movzbl 0xc0122a2d,%eax
c01033a6:	24 9f                	and    $0x9f,%al
c01033a8:	a2 2d 2a 12 c0       	mov    %al,0xc0122a2d
c01033ad:	0f b6 05 2d 2a 12 c0 	movzbl 0xc0122a2d,%eax
c01033b4:	0c 80                	or     $0x80,%al
c01033b6:	a2 2d 2a 12 c0       	mov    %al,0xc0122a2d
c01033bb:	0f b6 05 2e 2a 12 c0 	movzbl 0xc0122a2e,%eax
c01033c2:	24 f0                	and    $0xf0,%al
c01033c4:	a2 2e 2a 12 c0       	mov    %al,0xc0122a2e
c01033c9:	0f b6 05 2e 2a 12 c0 	movzbl 0xc0122a2e,%eax
c01033d0:	24 ef                	and    $0xef,%al
c01033d2:	a2 2e 2a 12 c0       	mov    %al,0xc0122a2e
c01033d7:	0f b6 05 2e 2a 12 c0 	movzbl 0xc0122a2e,%eax
c01033de:	24 df                	and    $0xdf,%al
c01033e0:	a2 2e 2a 12 c0       	mov    %al,0xc0122a2e
c01033e5:	0f b6 05 2e 2a 12 c0 	movzbl 0xc0122a2e,%eax
c01033ec:	0c 40                	or     $0x40,%al
c01033ee:	a2 2e 2a 12 c0       	mov    %al,0xc0122a2e
c01033f3:	0f b6 05 2e 2a 12 c0 	movzbl 0xc0122a2e,%eax
c01033fa:	24 7f                	and    $0x7f,%al
c01033fc:	a2 2e 2a 12 c0       	mov    %al,0xc0122a2e
c0103401:	b8 a0 5f 12 c0       	mov    $0xc0125fa0,%eax
c0103406:	c1 e8 18             	shr    $0x18,%eax
c0103409:	a2 2f 2a 12 c0       	mov    %al,0xc0122a2f

    // reload all segment registers
    lgdt(&gdt_pd);
c010340e:	c7 04 24 30 2a 12 c0 	movl   $0xc0122a30,(%esp)
c0103415:	e8 db fe ff ff       	call   c01032f5 <lgdt>
c010341a:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c0103420:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0103424:	0f 00 d8             	ltr    %ax
}
c0103427:	90                   	nop

    // load the TSS
    ltr(GD_TSS);
}
c0103428:	90                   	nop
c0103429:	c9                   	leave  
c010342a:	c3                   	ret    

c010342b <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c010342b:	f3 0f 1e fb          	endbr32 
c010342f:	55                   	push   %ebp
c0103430:	89 e5                	mov    %esp,%ebp
c0103432:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c0103435:	c7 05 20 60 12 c0 f0 	movl   $0xc010a5f0,0xc0126020
c010343c:	a5 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c010343f:	a1 20 60 12 c0       	mov    0xc0126020,%eax
c0103444:	8b 00                	mov    (%eax),%eax
c0103446:	89 44 24 04          	mov    %eax,0x4(%esp)
c010344a:	c7 04 24 74 92 10 c0 	movl   $0xc0109274,(%esp)
c0103451:	e8 73 ce ff ff       	call   c01002c9 <cprintf>
    pmm_manager->init();
c0103456:	a1 20 60 12 c0       	mov    0xc0126020,%eax
c010345b:	8b 40 04             	mov    0x4(%eax),%eax
c010345e:	ff d0                	call   *%eax
}
c0103460:	90                   	nop
c0103461:	c9                   	leave  
c0103462:	c3                   	ret    

c0103463 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c0103463:	f3 0f 1e fb          	endbr32 
c0103467:	55                   	push   %ebp
c0103468:	89 e5                	mov    %esp,%ebp
c010346a:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c010346d:	a1 20 60 12 c0       	mov    0xc0126020,%eax
c0103472:	8b 40 08             	mov    0x8(%eax),%eax
c0103475:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103478:	89 54 24 04          	mov    %edx,0x4(%esp)
c010347c:	8b 55 08             	mov    0x8(%ebp),%edx
c010347f:	89 14 24             	mov    %edx,(%esp)
c0103482:	ff d0                	call   *%eax
}
c0103484:	90                   	nop
c0103485:	c9                   	leave  
c0103486:	c3                   	ret    

c0103487 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c0103487:	f3 0f 1e fb          	endbr32 
c010348b:	55                   	push   %ebp
c010348c:	89 e5                	mov    %esp,%ebp
c010348e:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c0103491:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    
    while (1)
    {
         local_intr_save(intr_flag);
c0103498:	e8 1a fe ff ff       	call   c01032b7 <__intr_save>
c010349d:	89 45 f0             	mov    %eax,-0x10(%ebp)
         {
              page = pmm_manager->alloc_pages(n);
c01034a0:	a1 20 60 12 c0       	mov    0xc0126020,%eax
c01034a5:	8b 40 0c             	mov    0xc(%eax),%eax
c01034a8:	8b 55 08             	mov    0x8(%ebp),%edx
c01034ab:	89 14 24             	mov    %edx,(%esp)
c01034ae:	ff d0                	call   *%eax
c01034b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
         }
         local_intr_restore(intr_flag);
c01034b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01034b6:	89 04 24             	mov    %eax,(%esp)
c01034b9:	e8 23 fe ff ff       	call   c01032e1 <__intr_restore>

         if (page != NULL || n > 1 || swap_init_ok == 0) break;
c01034be:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01034c2:	75 2d                	jne    c01034f1 <alloc_pages+0x6a>
c01034c4:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
c01034c8:	77 27                	ja     c01034f1 <alloc_pages+0x6a>
c01034ca:	a1 10 60 12 c0       	mov    0xc0126010,%eax
c01034cf:	85 c0                	test   %eax,%eax
c01034d1:	74 1e                	je     c01034f1 <alloc_pages+0x6a>
         
         extern struct mm_struct *check_mm_struct;
         //cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
         swap_out(check_mm_struct, n, 0);
c01034d3:	8b 55 08             	mov    0x8(%ebp),%edx
c01034d6:	a1 2c 60 12 c0       	mov    0xc012602c,%eax
c01034db:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01034e2:	00 
c01034e3:	89 54 24 04          	mov    %edx,0x4(%esp)
c01034e7:	89 04 24             	mov    %eax,(%esp)
c01034ea:	e8 45 25 00 00       	call   c0105a34 <swap_out>
    {
c01034ef:	eb a7                	jmp    c0103498 <alloc_pages+0x11>
    }
    //cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
c01034f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01034f4:	c9                   	leave  
c01034f5:	c3                   	ret    

c01034f6 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c01034f6:	f3 0f 1e fb          	endbr32 
c01034fa:	55                   	push   %ebp
c01034fb:	89 e5                	mov    %esp,%ebp
c01034fd:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0103500:	e8 b2 fd ff ff       	call   c01032b7 <__intr_save>
c0103505:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c0103508:	a1 20 60 12 c0       	mov    0xc0126020,%eax
c010350d:	8b 40 10             	mov    0x10(%eax),%eax
c0103510:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103513:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103517:	8b 55 08             	mov    0x8(%ebp),%edx
c010351a:	89 14 24             	mov    %edx,(%esp)
c010351d:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c010351f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103522:	89 04 24             	mov    %eax,(%esp)
c0103525:	e8 b7 fd ff ff       	call   c01032e1 <__intr_restore>
}
c010352a:	90                   	nop
c010352b:	c9                   	leave  
c010352c:	c3                   	ret    

c010352d <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c010352d:	f3 0f 1e fb          	endbr32 
c0103531:	55                   	push   %ebp
c0103532:	89 e5                	mov    %esp,%ebp
c0103534:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c0103537:	e8 7b fd ff ff       	call   c01032b7 <__intr_save>
c010353c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c010353f:	a1 20 60 12 c0       	mov    0xc0126020,%eax
c0103544:	8b 40 14             	mov    0x14(%eax),%eax
c0103547:	ff d0                	call   *%eax
c0103549:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c010354c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010354f:	89 04 24             	mov    %eax,(%esp)
c0103552:	e8 8a fd ff ff       	call   c01032e1 <__intr_restore>
    return ret;
c0103557:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c010355a:	c9                   	leave  
c010355b:	c3                   	ret    

c010355c <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c010355c:	f3 0f 1e fb          	endbr32 
c0103560:	55                   	push   %ebp
c0103561:	89 e5                	mov    %esp,%ebp
c0103563:	57                   	push   %edi
c0103564:	56                   	push   %esi
c0103565:	53                   	push   %ebx
c0103566:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c010356c:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0103573:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c010357a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0103581:	c7 04 24 8b 92 10 c0 	movl   $0xc010928b,(%esp)
c0103588:	e8 3c cd ff ff       	call   c01002c9 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c010358d:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0103594:	e9 1a 01 00 00       	jmp    c01036b3 <page_init+0x157>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0103599:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010359c:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010359f:	89 d0                	mov    %edx,%eax
c01035a1:	c1 e0 02             	shl    $0x2,%eax
c01035a4:	01 d0                	add    %edx,%eax
c01035a6:	c1 e0 02             	shl    $0x2,%eax
c01035a9:	01 c8                	add    %ecx,%eax
c01035ab:	8b 50 08             	mov    0x8(%eax),%edx
c01035ae:	8b 40 04             	mov    0x4(%eax),%eax
c01035b1:	89 45 a0             	mov    %eax,-0x60(%ebp)
c01035b4:	89 55 a4             	mov    %edx,-0x5c(%ebp)
c01035b7:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01035ba:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01035bd:	89 d0                	mov    %edx,%eax
c01035bf:	c1 e0 02             	shl    $0x2,%eax
c01035c2:	01 d0                	add    %edx,%eax
c01035c4:	c1 e0 02             	shl    $0x2,%eax
c01035c7:	01 c8                	add    %ecx,%eax
c01035c9:	8b 48 0c             	mov    0xc(%eax),%ecx
c01035cc:	8b 58 10             	mov    0x10(%eax),%ebx
c01035cf:	8b 45 a0             	mov    -0x60(%ebp),%eax
c01035d2:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c01035d5:	01 c8                	add    %ecx,%eax
c01035d7:	11 da                	adc    %ebx,%edx
c01035d9:	89 45 98             	mov    %eax,-0x68(%ebp)
c01035dc:	89 55 9c             	mov    %edx,-0x64(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c01035df:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01035e2:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01035e5:	89 d0                	mov    %edx,%eax
c01035e7:	c1 e0 02             	shl    $0x2,%eax
c01035ea:	01 d0                	add    %edx,%eax
c01035ec:	c1 e0 02             	shl    $0x2,%eax
c01035ef:	01 c8                	add    %ecx,%eax
c01035f1:	83 c0 14             	add    $0x14,%eax
c01035f4:	8b 00                	mov    (%eax),%eax
c01035f6:	89 45 84             	mov    %eax,-0x7c(%ebp)
c01035f9:	8b 45 98             	mov    -0x68(%ebp),%eax
c01035fc:	8b 55 9c             	mov    -0x64(%ebp),%edx
c01035ff:	83 c0 ff             	add    $0xffffffff,%eax
c0103602:	83 d2 ff             	adc    $0xffffffff,%edx
c0103605:	89 85 78 ff ff ff    	mov    %eax,-0x88(%ebp)
c010360b:	89 95 7c ff ff ff    	mov    %edx,-0x84(%ebp)
c0103611:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103614:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103617:	89 d0                	mov    %edx,%eax
c0103619:	c1 e0 02             	shl    $0x2,%eax
c010361c:	01 d0                	add    %edx,%eax
c010361e:	c1 e0 02             	shl    $0x2,%eax
c0103621:	01 c8                	add    %ecx,%eax
c0103623:	8b 48 0c             	mov    0xc(%eax),%ecx
c0103626:	8b 58 10             	mov    0x10(%eax),%ebx
c0103629:	8b 55 84             	mov    -0x7c(%ebp),%edx
c010362c:	89 54 24 1c          	mov    %edx,0x1c(%esp)
c0103630:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
c0103636:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
c010363c:	89 44 24 14          	mov    %eax,0x14(%esp)
c0103640:	89 54 24 18          	mov    %edx,0x18(%esp)
c0103644:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0103647:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c010364a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010364e:	89 54 24 10          	mov    %edx,0x10(%esp)
c0103652:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0103656:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c010365a:	c7 04 24 98 92 10 c0 	movl   $0xc0109298,(%esp)
c0103661:	e8 63 cc ff ff       	call   c01002c9 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c0103666:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103669:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010366c:	89 d0                	mov    %edx,%eax
c010366e:	c1 e0 02             	shl    $0x2,%eax
c0103671:	01 d0                	add    %edx,%eax
c0103673:	c1 e0 02             	shl    $0x2,%eax
c0103676:	01 c8                	add    %ecx,%eax
c0103678:	83 c0 14             	add    $0x14,%eax
c010367b:	8b 00                	mov    (%eax),%eax
c010367d:	83 f8 01             	cmp    $0x1,%eax
c0103680:	75 2e                	jne    c01036b0 <page_init+0x154>
            if (maxpa < end && begin < KMEMSIZE) {
c0103682:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103685:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103688:	3b 45 98             	cmp    -0x68(%ebp),%eax
c010368b:	89 d0                	mov    %edx,%eax
c010368d:	1b 45 9c             	sbb    -0x64(%ebp),%eax
c0103690:	73 1e                	jae    c01036b0 <page_init+0x154>
c0103692:	ba ff ff ff 37       	mov    $0x37ffffff,%edx
c0103697:	b8 00 00 00 00       	mov    $0x0,%eax
c010369c:	3b 55 a0             	cmp    -0x60(%ebp),%edx
c010369f:	1b 45 a4             	sbb    -0x5c(%ebp),%eax
c01036a2:	72 0c                	jb     c01036b0 <page_init+0x154>
                maxpa = end;
c01036a4:	8b 45 98             	mov    -0x68(%ebp),%eax
c01036a7:	8b 55 9c             	mov    -0x64(%ebp),%edx
c01036aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01036ad:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
c01036b0:	ff 45 dc             	incl   -0x24(%ebp)
c01036b3:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01036b6:	8b 00                	mov    (%eax),%eax
c01036b8:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c01036bb:	0f 8c d8 fe ff ff    	jl     c0103599 <page_init+0x3d>
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c01036c1:	ba 00 00 00 38       	mov    $0x38000000,%edx
c01036c6:	b8 00 00 00 00       	mov    $0x0,%eax
c01036cb:	3b 55 e0             	cmp    -0x20(%ebp),%edx
c01036ce:	1b 45 e4             	sbb    -0x1c(%ebp),%eax
c01036d1:	73 0e                	jae    c01036e1 <page_init+0x185>
        maxpa = KMEMSIZE;
c01036d3:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c01036da:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c01036e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01036e4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01036e7:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c01036eb:	c1 ea 0c             	shr    $0xc,%edx
c01036ee:	a3 80 5f 12 c0       	mov    %eax,0xc0125f80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c01036f3:	c7 45 c0 00 10 00 00 	movl   $0x1000,-0x40(%ebp)
c01036fa:	b8 18 61 12 c0       	mov    $0xc0126118,%eax
c01036ff:	8d 50 ff             	lea    -0x1(%eax),%edx
c0103702:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0103705:	01 d0                	add    %edx,%eax
c0103707:	89 45 bc             	mov    %eax,-0x44(%ebp)
c010370a:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010370d:	ba 00 00 00 00       	mov    $0x0,%edx
c0103712:	f7 75 c0             	divl   -0x40(%ebp)
c0103715:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0103718:	29 d0                	sub    %edx,%eax
c010371a:	a3 28 60 12 c0       	mov    %eax,0xc0126028

    for (i = 0; i < npage; i ++) {
c010371f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0103726:	eb 27                	jmp    c010374f <page_init+0x1f3>
        SetPageReserved(pages + i);
c0103728:	a1 28 60 12 c0       	mov    0xc0126028,%eax
c010372d:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103730:	c1 e2 05             	shl    $0x5,%edx
c0103733:	01 d0                	add    %edx,%eax
c0103735:	83 c0 04             	add    $0x4,%eax
c0103738:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
c010373f:	89 45 90             	mov    %eax,-0x70(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103742:	8b 45 90             	mov    -0x70(%ebp),%eax
c0103745:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0103748:	0f ab 10             	bts    %edx,(%eax)
}
c010374b:	90                   	nop
    for (i = 0; i < npage; i ++) {
c010374c:	ff 45 dc             	incl   -0x24(%ebp)
c010374f:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103752:	a1 80 5f 12 c0       	mov    0xc0125f80,%eax
c0103757:	39 c2                	cmp    %eax,%edx
c0103759:	72 cd                	jb     c0103728 <page_init+0x1cc>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c010375b:	a1 80 5f 12 c0       	mov    0xc0125f80,%eax
c0103760:	c1 e0 05             	shl    $0x5,%eax
c0103763:	89 c2                	mov    %eax,%edx
c0103765:	a1 28 60 12 c0       	mov    0xc0126028,%eax
c010376a:	01 d0                	add    %edx,%eax
c010376c:	89 45 b8             	mov    %eax,-0x48(%ebp)
c010376f:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
c0103776:	77 23                	ja     c010379b <page_init+0x23f>
c0103778:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010377b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010377f:	c7 44 24 08 24 92 10 	movl   $0xc0109224,0x8(%esp)
c0103786:	c0 
c0103787:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
c010378e:	00 
c010378f:	c7 04 24 c8 92 10 c0 	movl   $0xc01092c8,(%esp)
c0103796:	e8 9a cc ff ff       	call   c0100435 <__panic>
c010379b:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010379e:	05 00 00 00 40       	add    $0x40000000,%eax
c01037a3:	89 45 b4             	mov    %eax,-0x4c(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c01037a6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01037ad:	e9 4b 01 00 00       	jmp    c01038fd <page_init+0x3a1>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c01037b2:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01037b5:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01037b8:	89 d0                	mov    %edx,%eax
c01037ba:	c1 e0 02             	shl    $0x2,%eax
c01037bd:	01 d0                	add    %edx,%eax
c01037bf:	c1 e0 02             	shl    $0x2,%eax
c01037c2:	01 c8                	add    %ecx,%eax
c01037c4:	8b 50 08             	mov    0x8(%eax),%edx
c01037c7:	8b 40 04             	mov    0x4(%eax),%eax
c01037ca:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01037cd:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01037d0:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01037d3:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01037d6:	89 d0                	mov    %edx,%eax
c01037d8:	c1 e0 02             	shl    $0x2,%eax
c01037db:	01 d0                	add    %edx,%eax
c01037dd:	c1 e0 02             	shl    $0x2,%eax
c01037e0:	01 c8                	add    %ecx,%eax
c01037e2:	8b 48 0c             	mov    0xc(%eax),%ecx
c01037e5:	8b 58 10             	mov    0x10(%eax),%ebx
c01037e8:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01037eb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01037ee:	01 c8                	add    %ecx,%eax
c01037f0:	11 da                	adc    %ebx,%edx
c01037f2:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01037f5:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c01037f8:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01037fb:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01037fe:	89 d0                	mov    %edx,%eax
c0103800:	c1 e0 02             	shl    $0x2,%eax
c0103803:	01 d0                	add    %edx,%eax
c0103805:	c1 e0 02             	shl    $0x2,%eax
c0103808:	01 c8                	add    %ecx,%eax
c010380a:	83 c0 14             	add    $0x14,%eax
c010380d:	8b 00                	mov    (%eax),%eax
c010380f:	83 f8 01             	cmp    $0x1,%eax
c0103812:	0f 85 e2 00 00 00    	jne    c01038fa <page_init+0x39e>
            if (begin < freemem) {
c0103818:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010381b:	ba 00 00 00 00       	mov    $0x0,%edx
c0103820:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c0103823:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c0103826:	19 d1                	sbb    %edx,%ecx
c0103828:	73 0d                	jae    c0103837 <page_init+0x2db>
                begin = freemem;
c010382a:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010382d:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0103830:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c0103837:	ba 00 00 00 38       	mov    $0x38000000,%edx
c010383c:	b8 00 00 00 00       	mov    $0x0,%eax
c0103841:	3b 55 c8             	cmp    -0x38(%ebp),%edx
c0103844:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c0103847:	73 0e                	jae    c0103857 <page_init+0x2fb>
                end = KMEMSIZE;
c0103849:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c0103850:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c0103857:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010385a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010385d:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0103860:	89 d0                	mov    %edx,%eax
c0103862:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c0103865:	0f 83 8f 00 00 00    	jae    c01038fa <page_init+0x39e>
                begin = ROUNDUP(begin, PGSIZE);
c010386b:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
c0103872:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0103875:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0103878:	01 d0                	add    %edx,%eax
c010387a:	48                   	dec    %eax
c010387b:	89 45 ac             	mov    %eax,-0x54(%ebp)
c010387e:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0103881:	ba 00 00 00 00       	mov    $0x0,%edx
c0103886:	f7 75 b0             	divl   -0x50(%ebp)
c0103889:	8b 45 ac             	mov    -0x54(%ebp),%eax
c010388c:	29 d0                	sub    %edx,%eax
c010388e:	ba 00 00 00 00       	mov    $0x0,%edx
c0103893:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0103896:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c0103899:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010389c:	89 45 a8             	mov    %eax,-0x58(%ebp)
c010389f:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01038a2:	ba 00 00 00 00       	mov    $0x0,%edx
c01038a7:	89 c3                	mov    %eax,%ebx
c01038a9:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
c01038af:	89 de                	mov    %ebx,%esi
c01038b1:	89 d0                	mov    %edx,%eax
c01038b3:	83 e0 00             	and    $0x0,%eax
c01038b6:	89 c7                	mov    %eax,%edi
c01038b8:	89 75 c8             	mov    %esi,-0x38(%ebp)
c01038bb:	89 7d cc             	mov    %edi,-0x34(%ebp)
                if (begin < end) {
c01038be:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01038c1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01038c4:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c01038c7:	89 d0                	mov    %edx,%eax
c01038c9:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c01038cc:	73 2c                	jae    c01038fa <page_init+0x39e>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c01038ce:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01038d1:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01038d4:	2b 45 d0             	sub    -0x30(%ebp),%eax
c01038d7:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
c01038da:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c01038de:	c1 ea 0c             	shr    $0xc,%edx
c01038e1:	89 c3                	mov    %eax,%ebx
c01038e3:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01038e6:	89 04 24             	mov    %eax,(%esp)
c01038e9:	e8 58 f8 ff ff       	call   c0103146 <pa2page>
c01038ee:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01038f2:	89 04 24             	mov    %eax,(%esp)
c01038f5:	e8 69 fb ff ff       	call   c0103463 <init_memmap>
    for (i = 0; i < memmap->nr_map; i ++) {
c01038fa:	ff 45 dc             	incl   -0x24(%ebp)
c01038fd:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103900:	8b 00                	mov    (%eax),%eax
c0103902:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0103905:	0f 8c a7 fe ff ff    	jl     c01037b2 <page_init+0x256>
                }
            }
        }
    }
}
c010390b:	90                   	nop
c010390c:	90                   	nop
c010390d:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c0103913:	5b                   	pop    %ebx
c0103914:	5e                   	pop    %esi
c0103915:	5f                   	pop    %edi
c0103916:	5d                   	pop    %ebp
c0103917:	c3                   	ret    

c0103918 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c0103918:	f3 0f 1e fb          	endbr32 
c010391c:	55                   	push   %ebp
c010391d:	89 e5                	mov    %esp,%ebp
c010391f:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c0103922:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103925:	33 45 14             	xor    0x14(%ebp),%eax
c0103928:	25 ff 0f 00 00       	and    $0xfff,%eax
c010392d:	85 c0                	test   %eax,%eax
c010392f:	74 24                	je     c0103955 <boot_map_segment+0x3d>
c0103931:	c7 44 24 0c d6 92 10 	movl   $0xc01092d6,0xc(%esp)
c0103938:	c0 
c0103939:	c7 44 24 08 ed 92 10 	movl   $0xc01092ed,0x8(%esp)
c0103940:	c0 
c0103941:	c7 44 24 04 07 01 00 	movl   $0x107,0x4(%esp)
c0103948:	00 
c0103949:	c7 04 24 c8 92 10 c0 	movl   $0xc01092c8,(%esp)
c0103950:	e8 e0 ca ff ff       	call   c0100435 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c0103955:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c010395c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010395f:	25 ff 0f 00 00       	and    $0xfff,%eax
c0103964:	89 c2                	mov    %eax,%edx
c0103966:	8b 45 10             	mov    0x10(%ebp),%eax
c0103969:	01 c2                	add    %eax,%edx
c010396b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010396e:	01 d0                	add    %edx,%eax
c0103970:	48                   	dec    %eax
c0103971:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103974:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103977:	ba 00 00 00 00       	mov    $0x0,%edx
c010397c:	f7 75 f0             	divl   -0x10(%ebp)
c010397f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103982:	29 d0                	sub    %edx,%eax
c0103984:	c1 e8 0c             	shr    $0xc,%eax
c0103987:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c010398a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010398d:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103990:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103993:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103998:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c010399b:	8b 45 14             	mov    0x14(%ebp),%eax
c010399e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01039a1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01039a4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01039a9:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c01039ac:	eb 68                	jmp    c0103a16 <boot_map_segment+0xfe>
        pte_t *ptep = get_pte(pgdir, la, 1);
c01039ae:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c01039b5:	00 
c01039b6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01039b9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01039bd:	8b 45 08             	mov    0x8(%ebp),%eax
c01039c0:	89 04 24             	mov    %eax,(%esp)
c01039c3:	e8 8a 01 00 00       	call   c0103b52 <get_pte>
c01039c8:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c01039cb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01039cf:	75 24                	jne    c01039f5 <boot_map_segment+0xdd>
c01039d1:	c7 44 24 0c 02 93 10 	movl   $0xc0109302,0xc(%esp)
c01039d8:	c0 
c01039d9:	c7 44 24 08 ed 92 10 	movl   $0xc01092ed,0x8(%esp)
c01039e0:	c0 
c01039e1:	c7 44 24 04 0d 01 00 	movl   $0x10d,0x4(%esp)
c01039e8:	00 
c01039e9:	c7 04 24 c8 92 10 c0 	movl   $0xc01092c8,(%esp)
c01039f0:	e8 40 ca ff ff       	call   c0100435 <__panic>
        *ptep = pa | PTE_P | perm;
c01039f5:	8b 45 14             	mov    0x14(%ebp),%eax
c01039f8:	0b 45 18             	or     0x18(%ebp),%eax
c01039fb:	83 c8 01             	or     $0x1,%eax
c01039fe:	89 c2                	mov    %eax,%edx
c0103a00:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103a03:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0103a05:	ff 4d f4             	decl   -0xc(%ebp)
c0103a08:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c0103a0f:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c0103a16:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103a1a:	75 92                	jne    c01039ae <boot_map_segment+0x96>
    }
}
c0103a1c:	90                   	nop
c0103a1d:	90                   	nop
c0103a1e:	c9                   	leave  
c0103a1f:	c3                   	ret    

c0103a20 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c0103a20:	f3 0f 1e fb          	endbr32 
c0103a24:	55                   	push   %ebp
c0103a25:	89 e5                	mov    %esp,%ebp
c0103a27:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c0103a2a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103a31:	e8 51 fa ff ff       	call   c0103487 <alloc_pages>
c0103a36:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c0103a39:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103a3d:	75 1c                	jne    c0103a5b <boot_alloc_page+0x3b>
        panic("boot_alloc_page failed.\n");
c0103a3f:	c7 44 24 08 0f 93 10 	movl   $0xc010930f,0x8(%esp)
c0103a46:	c0 
c0103a47:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
c0103a4e:	00 
c0103a4f:	c7 04 24 c8 92 10 c0 	movl   $0xc01092c8,(%esp)
c0103a56:	e8 da c9 ff ff       	call   c0100435 <__panic>
    }
    return page2kva(p);
c0103a5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a5e:	89 04 24             	mov    %eax,(%esp)
c0103a61:	e8 25 f7 ff ff       	call   c010318b <page2kva>
}
c0103a66:	c9                   	leave  
c0103a67:	c3                   	ret    

c0103a68 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c0103a68:	f3 0f 1e fb          	endbr32 
c0103a6c:	55                   	push   %ebp
c0103a6d:	89 e5                	mov    %esp,%ebp
c0103a6f:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c0103a72:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c0103a77:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103a7a:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0103a81:	77 23                	ja     c0103aa6 <pmm_init+0x3e>
c0103a83:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a86:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103a8a:	c7 44 24 08 24 92 10 	movl   $0xc0109224,0x8(%esp)
c0103a91:	c0 
c0103a92:	c7 44 24 04 23 01 00 	movl   $0x123,0x4(%esp)
c0103a99:	00 
c0103a9a:	c7 04 24 c8 92 10 c0 	movl   $0xc01092c8,(%esp)
c0103aa1:	e8 8f c9 ff ff       	call   c0100435 <__panic>
c0103aa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103aa9:	05 00 00 00 40       	add    $0x40000000,%eax
c0103aae:	a3 24 60 12 c0       	mov    %eax,0xc0126024
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c0103ab3:	e8 73 f9 ff ff       	call   c010342b <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c0103ab8:	e8 9f fa ff ff       	call   c010355c <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c0103abd:	e8 33 03 00 00       	call   c0103df5 <check_alloc_page>

    check_pgdir();
c0103ac2:	e8 51 03 00 00       	call   c0103e18 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c0103ac7:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c0103acc:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103acf:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0103ad6:	77 23                	ja     c0103afb <pmm_init+0x93>
c0103ad8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103adb:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103adf:	c7 44 24 08 24 92 10 	movl   $0xc0109224,0x8(%esp)
c0103ae6:	c0 
c0103ae7:	c7 44 24 04 39 01 00 	movl   $0x139,0x4(%esp)
c0103aee:	00 
c0103aef:	c7 04 24 c8 92 10 c0 	movl   $0xc01092c8,(%esp)
c0103af6:	e8 3a c9 ff ff       	call   c0100435 <__panic>
c0103afb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103afe:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c0103b04:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c0103b09:	05 ac 0f 00 00       	add    $0xfac,%eax
c0103b0e:	83 ca 03             	or     $0x3,%edx
c0103b11:	89 10                	mov    %edx,(%eax)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c0103b13:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c0103b18:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c0103b1f:	00 
c0103b20:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0103b27:	00 
c0103b28:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c0103b2f:	38 
c0103b30:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c0103b37:	c0 
c0103b38:	89 04 24             	mov    %eax,(%esp)
c0103b3b:	e8 d8 fd ff ff       	call   c0103918 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c0103b40:	e8 f8 f7 ff ff       	call   c010333d <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c0103b45:	e8 6e 09 00 00       	call   c01044b8 <check_boot_pgdir>

    print_pgdir();
c0103b4a:	e8 f3 0d 00 00       	call   c0104942 <print_pgdir>

}
c0103b4f:	90                   	nop
c0103b50:	c9                   	leave  
c0103b51:	c3                   	ret    

c0103b52 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c0103b52:	f3 0f 1e fb          	endbr32 
c0103b56:	55                   	push   %ebp
c0103b57:	89 e5                	mov    %esp,%ebp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
}
c0103b59:	90                   	nop
c0103b5a:	5d                   	pop    %ebp
c0103b5b:	c3                   	ret    

c0103b5c <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c0103b5c:	f3 0f 1e fb          	endbr32 
c0103b60:	55                   	push   %ebp
c0103b61:	89 e5                	mov    %esp,%ebp
c0103b63:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0103b66:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103b6d:	00 
c0103b6e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103b71:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103b75:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b78:	89 04 24             	mov    %eax,(%esp)
c0103b7b:	e8 d2 ff ff ff       	call   c0103b52 <get_pte>
c0103b80:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c0103b83:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0103b87:	74 08                	je     c0103b91 <get_page+0x35>
        *ptep_store = ptep;
c0103b89:	8b 45 10             	mov    0x10(%ebp),%eax
c0103b8c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103b8f:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c0103b91:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103b95:	74 1b                	je     c0103bb2 <get_page+0x56>
c0103b97:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b9a:	8b 00                	mov    (%eax),%eax
c0103b9c:	83 e0 01             	and    $0x1,%eax
c0103b9f:	85 c0                	test   %eax,%eax
c0103ba1:	74 0f                	je     c0103bb2 <get_page+0x56>
        return pte2page(*ptep);
c0103ba3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103ba6:	8b 00                	mov    (%eax),%eax
c0103ba8:	89 04 24             	mov    %eax,(%esp)
c0103bab:	e8 79 f6 ff ff       	call   c0103229 <pte2page>
c0103bb0:	eb 05                	jmp    c0103bb7 <get_page+0x5b>
    }
    return NULL;
c0103bb2:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103bb7:	c9                   	leave  
c0103bb8:	c3                   	ret    

c0103bb9 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c0103bb9:	55                   	push   %ebp
c0103bba:	89 e5                	mov    %esp,%ebp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
}
c0103bbc:	90                   	nop
c0103bbd:	5d                   	pop    %ebp
c0103bbe:	c3                   	ret    

c0103bbf <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c0103bbf:	f3 0f 1e fb          	endbr32 
c0103bc3:	55                   	push   %ebp
c0103bc4:	89 e5                	mov    %esp,%ebp
c0103bc6:	83 ec 1c             	sub    $0x1c,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0103bc9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103bd0:	00 
c0103bd1:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103bd4:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103bd8:	8b 45 08             	mov    0x8(%ebp),%eax
c0103bdb:	89 04 24             	mov    %eax,(%esp)
c0103bde:	e8 6f ff ff ff       	call   c0103b52 <get_pte>
c0103be3:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (ptep != NULL) {
c0103be6:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0103bea:	74 19                	je     c0103c05 <page_remove+0x46>
        page_remove_pte(pgdir, la, ptep);
c0103bec:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103bef:	89 44 24 08          	mov    %eax,0x8(%esp)
c0103bf3:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103bf6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103bfa:	8b 45 08             	mov    0x8(%ebp),%eax
c0103bfd:	89 04 24             	mov    %eax,(%esp)
c0103c00:	e8 b4 ff ff ff       	call   c0103bb9 <page_remove_pte>
    }
}
c0103c05:	90                   	nop
c0103c06:	c9                   	leave  
c0103c07:	c3                   	ret    

c0103c08 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c0103c08:	f3 0f 1e fb          	endbr32 
c0103c0c:	55                   	push   %ebp
c0103c0d:	89 e5                	mov    %esp,%ebp
c0103c0f:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c0103c12:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0103c19:	00 
c0103c1a:	8b 45 10             	mov    0x10(%ebp),%eax
c0103c1d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103c21:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c24:	89 04 24             	mov    %eax,(%esp)
c0103c27:	e8 26 ff ff ff       	call   c0103b52 <get_pte>
c0103c2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c0103c2f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103c33:	75 0a                	jne    c0103c3f <page_insert+0x37>
        return -E_NO_MEM;
c0103c35:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0103c3a:	e9 84 00 00 00       	jmp    c0103cc3 <page_insert+0xbb>
    }
    page_ref_inc(page);
c0103c3f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103c42:	89 04 24             	mov    %eax,(%esp)
c0103c45:	e8 3f f6 ff ff       	call   c0103289 <page_ref_inc>
    if (*ptep & PTE_P) {
c0103c4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103c4d:	8b 00                	mov    (%eax),%eax
c0103c4f:	83 e0 01             	and    $0x1,%eax
c0103c52:	85 c0                	test   %eax,%eax
c0103c54:	74 3e                	je     c0103c94 <page_insert+0x8c>
        struct Page *p = pte2page(*ptep);
c0103c56:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103c59:	8b 00                	mov    (%eax),%eax
c0103c5b:	89 04 24             	mov    %eax,(%esp)
c0103c5e:	e8 c6 f5 ff ff       	call   c0103229 <pte2page>
c0103c63:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c0103c66:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103c69:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0103c6c:	75 0d                	jne    c0103c7b <page_insert+0x73>
            page_ref_dec(page);
c0103c6e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103c71:	89 04 24             	mov    %eax,(%esp)
c0103c74:	e8 27 f6 ff ff       	call   c01032a0 <page_ref_dec>
c0103c79:	eb 19                	jmp    c0103c94 <page_insert+0x8c>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c0103c7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103c7e:	89 44 24 08          	mov    %eax,0x8(%esp)
c0103c82:	8b 45 10             	mov    0x10(%ebp),%eax
c0103c85:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103c89:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c8c:	89 04 24             	mov    %eax,(%esp)
c0103c8f:	e8 25 ff ff ff       	call   c0103bb9 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c0103c94:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103c97:	89 04 24             	mov    %eax,(%esp)
c0103c9a:	e8 91 f4 ff ff       	call   c0103130 <page2pa>
c0103c9f:	0b 45 14             	or     0x14(%ebp),%eax
c0103ca2:	83 c8 01             	or     $0x1,%eax
c0103ca5:	89 c2                	mov    %eax,%edx
c0103ca7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103caa:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c0103cac:	8b 45 10             	mov    0x10(%ebp),%eax
c0103caf:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103cb3:	8b 45 08             	mov    0x8(%ebp),%eax
c0103cb6:	89 04 24             	mov    %eax,(%esp)
c0103cb9:	e8 07 00 00 00       	call   c0103cc5 <tlb_invalidate>
    return 0;
c0103cbe:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103cc3:	c9                   	leave  
c0103cc4:	c3                   	ret    

c0103cc5 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c0103cc5:	f3 0f 1e fb          	endbr32 
c0103cc9:	55                   	push   %ebp
c0103cca:	89 e5                	mov    %esp,%ebp
c0103ccc:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c0103ccf:	0f 20 d8             	mov    %cr3,%eax
c0103cd2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c0103cd5:	8b 55 f0             	mov    -0x10(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
c0103cd8:	8b 45 08             	mov    0x8(%ebp),%eax
c0103cdb:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103cde:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0103ce5:	77 23                	ja     c0103d0a <tlb_invalidate+0x45>
c0103ce7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103cea:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103cee:	c7 44 24 08 24 92 10 	movl   $0xc0109224,0x8(%esp)
c0103cf5:	c0 
c0103cf6:	c7 44 24 04 d0 01 00 	movl   $0x1d0,0x4(%esp)
c0103cfd:	00 
c0103cfe:	c7 04 24 c8 92 10 c0 	movl   $0xc01092c8,(%esp)
c0103d05:	e8 2b c7 ff ff       	call   c0100435 <__panic>
c0103d0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103d0d:	05 00 00 00 40       	add    $0x40000000,%eax
c0103d12:	39 d0                	cmp    %edx,%eax
c0103d14:	75 0d                	jne    c0103d23 <tlb_invalidate+0x5e>
        invlpg((void *)la);
c0103d16:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103d19:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c0103d1c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103d1f:	0f 01 38             	invlpg (%eax)
}
c0103d22:	90                   	nop
    }
}
c0103d23:	90                   	nop
c0103d24:	c9                   	leave  
c0103d25:	c3                   	ret    

c0103d26 <pgdir_alloc_page>:

// pgdir_alloc_page - call alloc_page & page_insert functions to 
//                  - allocate a page size memory & setup an addr map
//                  - pa<->la with linear address la and the PDT pgdir
struct Page *
pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
c0103d26:	f3 0f 1e fb          	endbr32 
c0103d2a:	55                   	push   %ebp
c0103d2b:	89 e5                	mov    %esp,%ebp
c0103d2d:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = alloc_page();
c0103d30:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103d37:	e8 4b f7 ff ff       	call   c0103487 <alloc_pages>
c0103d3c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c0103d3f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103d43:	0f 84 a7 00 00 00    	je     c0103df0 <pgdir_alloc_page+0xca>
        if (page_insert(pgdir, page, la, perm) != 0) {
c0103d49:	8b 45 10             	mov    0x10(%ebp),%eax
c0103d4c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103d50:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103d53:	89 44 24 08          	mov    %eax,0x8(%esp)
c0103d57:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103d5a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103d5e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103d61:	89 04 24             	mov    %eax,(%esp)
c0103d64:	e8 9f fe ff ff       	call   c0103c08 <page_insert>
c0103d69:	85 c0                	test   %eax,%eax
c0103d6b:	74 1a                	je     c0103d87 <pgdir_alloc_page+0x61>
            free_page(page);
c0103d6d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103d74:	00 
c0103d75:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103d78:	89 04 24             	mov    %eax,(%esp)
c0103d7b:	e8 76 f7 ff ff       	call   c01034f6 <free_pages>
            return NULL;
c0103d80:	b8 00 00 00 00       	mov    $0x0,%eax
c0103d85:	eb 6c                	jmp    c0103df3 <pgdir_alloc_page+0xcd>
        }
        if (swap_init_ok){
c0103d87:	a1 10 60 12 c0       	mov    0xc0126010,%eax
c0103d8c:	85 c0                	test   %eax,%eax
c0103d8e:	74 60                	je     c0103df0 <pgdir_alloc_page+0xca>
            swap_map_swappable(check_mm_struct, la, page, 0);
c0103d90:	a1 2c 60 12 c0       	mov    0xc012602c,%eax
c0103d95:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0103d9c:	00 
c0103d9d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103da0:	89 54 24 08          	mov    %edx,0x8(%esp)
c0103da4:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103da7:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103dab:	89 04 24             	mov    %eax,(%esp)
c0103dae:	e8 2d 1c 00 00       	call   c01059e0 <swap_map_swappable>
            page->pra_vaddr=la;
c0103db3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103db6:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103db9:	89 50 1c             	mov    %edx,0x1c(%eax)
            assert(page_ref(page) == 1);
c0103dbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103dbf:	89 04 24             	mov    %eax,(%esp)
c0103dc2:	e8 b8 f4 ff ff       	call   c010327f <page_ref>
c0103dc7:	83 f8 01             	cmp    $0x1,%eax
c0103dca:	74 24                	je     c0103df0 <pgdir_alloc_page+0xca>
c0103dcc:	c7 44 24 0c 28 93 10 	movl   $0xc0109328,0xc(%esp)
c0103dd3:	c0 
c0103dd4:	c7 44 24 08 ed 92 10 	movl   $0xc01092ed,0x8(%esp)
c0103ddb:	c0 
c0103ddc:	c7 44 24 04 e3 01 00 	movl   $0x1e3,0x4(%esp)
c0103de3:	00 
c0103de4:	c7 04 24 c8 92 10 c0 	movl   $0xc01092c8,(%esp)
c0103deb:	e8 45 c6 ff ff       	call   c0100435 <__panic>
            //cprintf("get No. %d  page: pra_vaddr %x, pra_link.prev %x, pra_link_next %x in pgdir_alloc_page\n", (page-pages), page->pra_vaddr,page->pra_page_link.prev, page->pra_page_link.next);
        }

    }

    return page;
c0103df0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0103df3:	c9                   	leave  
c0103df4:	c3                   	ret    

c0103df5 <check_alloc_page>:

static void
check_alloc_page(void) {
c0103df5:	f3 0f 1e fb          	endbr32 
c0103df9:	55                   	push   %ebp
c0103dfa:	89 e5                	mov    %esp,%ebp
c0103dfc:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c0103dff:	a1 20 60 12 c0       	mov    0xc0126020,%eax
c0103e04:	8b 40 18             	mov    0x18(%eax),%eax
c0103e07:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c0103e09:	c7 04 24 3c 93 10 c0 	movl   $0xc010933c,(%esp)
c0103e10:	e8 b4 c4 ff ff       	call   c01002c9 <cprintf>
}
c0103e15:	90                   	nop
c0103e16:	c9                   	leave  
c0103e17:	c3                   	ret    

c0103e18 <check_pgdir>:

static void
check_pgdir(void) {
c0103e18:	f3 0f 1e fb          	endbr32 
c0103e1c:	55                   	push   %ebp
c0103e1d:	89 e5                	mov    %esp,%ebp
c0103e1f:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c0103e22:	a1 80 5f 12 c0       	mov    0xc0125f80,%eax
c0103e27:	3d 00 80 03 00       	cmp    $0x38000,%eax
c0103e2c:	76 24                	jbe    c0103e52 <check_pgdir+0x3a>
c0103e2e:	c7 44 24 0c 5b 93 10 	movl   $0xc010935b,0xc(%esp)
c0103e35:	c0 
c0103e36:	c7 44 24 08 ed 92 10 	movl   $0xc01092ed,0x8(%esp)
c0103e3d:	c0 
c0103e3e:	c7 44 24 04 f4 01 00 	movl   $0x1f4,0x4(%esp)
c0103e45:	00 
c0103e46:	c7 04 24 c8 92 10 c0 	movl   $0xc01092c8,(%esp)
c0103e4d:	e8 e3 c5 ff ff       	call   c0100435 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c0103e52:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c0103e57:	85 c0                	test   %eax,%eax
c0103e59:	74 0e                	je     c0103e69 <check_pgdir+0x51>
c0103e5b:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c0103e60:	25 ff 0f 00 00       	and    $0xfff,%eax
c0103e65:	85 c0                	test   %eax,%eax
c0103e67:	74 24                	je     c0103e8d <check_pgdir+0x75>
c0103e69:	c7 44 24 0c 78 93 10 	movl   $0xc0109378,0xc(%esp)
c0103e70:	c0 
c0103e71:	c7 44 24 08 ed 92 10 	movl   $0xc01092ed,0x8(%esp)
c0103e78:	c0 
c0103e79:	c7 44 24 04 f5 01 00 	movl   $0x1f5,0x4(%esp)
c0103e80:	00 
c0103e81:	c7 04 24 c8 92 10 c0 	movl   $0xc01092c8,(%esp)
c0103e88:	e8 a8 c5 ff ff       	call   c0100435 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c0103e8d:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c0103e92:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103e99:	00 
c0103e9a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103ea1:	00 
c0103ea2:	89 04 24             	mov    %eax,(%esp)
c0103ea5:	e8 b2 fc ff ff       	call   c0103b5c <get_page>
c0103eaa:	85 c0                	test   %eax,%eax
c0103eac:	74 24                	je     c0103ed2 <check_pgdir+0xba>
c0103eae:	c7 44 24 0c b0 93 10 	movl   $0xc01093b0,0xc(%esp)
c0103eb5:	c0 
c0103eb6:	c7 44 24 08 ed 92 10 	movl   $0xc01092ed,0x8(%esp)
c0103ebd:	c0 
c0103ebe:	c7 44 24 04 f6 01 00 	movl   $0x1f6,0x4(%esp)
c0103ec5:	00 
c0103ec6:	c7 04 24 c8 92 10 c0 	movl   $0xc01092c8,(%esp)
c0103ecd:	e8 63 c5 ff ff       	call   c0100435 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c0103ed2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103ed9:	e8 a9 f5 ff ff       	call   c0103487 <alloc_pages>
c0103ede:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c0103ee1:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c0103ee6:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0103eed:	00 
c0103eee:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103ef5:	00 
c0103ef6:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103ef9:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103efd:	89 04 24             	mov    %eax,(%esp)
c0103f00:	e8 03 fd ff ff       	call   c0103c08 <page_insert>
c0103f05:	85 c0                	test   %eax,%eax
c0103f07:	74 24                	je     c0103f2d <check_pgdir+0x115>
c0103f09:	c7 44 24 0c d8 93 10 	movl   $0xc01093d8,0xc(%esp)
c0103f10:	c0 
c0103f11:	c7 44 24 08 ed 92 10 	movl   $0xc01092ed,0x8(%esp)
c0103f18:	c0 
c0103f19:	c7 44 24 04 fa 01 00 	movl   $0x1fa,0x4(%esp)
c0103f20:	00 
c0103f21:	c7 04 24 c8 92 10 c0 	movl   $0xc01092c8,(%esp)
c0103f28:	e8 08 c5 ff ff       	call   c0100435 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c0103f2d:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c0103f32:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103f39:	00 
c0103f3a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103f41:	00 
c0103f42:	89 04 24             	mov    %eax,(%esp)
c0103f45:	e8 08 fc ff ff       	call   c0103b52 <get_pte>
c0103f4a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103f4d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103f51:	75 24                	jne    c0103f77 <check_pgdir+0x15f>
c0103f53:	c7 44 24 0c 04 94 10 	movl   $0xc0109404,0xc(%esp)
c0103f5a:	c0 
c0103f5b:	c7 44 24 08 ed 92 10 	movl   $0xc01092ed,0x8(%esp)
c0103f62:	c0 
c0103f63:	c7 44 24 04 fd 01 00 	movl   $0x1fd,0x4(%esp)
c0103f6a:	00 
c0103f6b:	c7 04 24 c8 92 10 c0 	movl   $0xc01092c8,(%esp)
c0103f72:	e8 be c4 ff ff       	call   c0100435 <__panic>
    assert(pte2page(*ptep) == p1);
c0103f77:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103f7a:	8b 00                	mov    (%eax),%eax
c0103f7c:	89 04 24             	mov    %eax,(%esp)
c0103f7f:	e8 a5 f2 ff ff       	call   c0103229 <pte2page>
c0103f84:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0103f87:	74 24                	je     c0103fad <check_pgdir+0x195>
c0103f89:	c7 44 24 0c 31 94 10 	movl   $0xc0109431,0xc(%esp)
c0103f90:	c0 
c0103f91:	c7 44 24 08 ed 92 10 	movl   $0xc01092ed,0x8(%esp)
c0103f98:	c0 
c0103f99:	c7 44 24 04 fe 01 00 	movl   $0x1fe,0x4(%esp)
c0103fa0:	00 
c0103fa1:	c7 04 24 c8 92 10 c0 	movl   $0xc01092c8,(%esp)
c0103fa8:	e8 88 c4 ff ff       	call   c0100435 <__panic>
    assert(page_ref(p1) == 1);
c0103fad:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103fb0:	89 04 24             	mov    %eax,(%esp)
c0103fb3:	e8 c7 f2 ff ff       	call   c010327f <page_ref>
c0103fb8:	83 f8 01             	cmp    $0x1,%eax
c0103fbb:	74 24                	je     c0103fe1 <check_pgdir+0x1c9>
c0103fbd:	c7 44 24 0c 47 94 10 	movl   $0xc0109447,0xc(%esp)
c0103fc4:	c0 
c0103fc5:	c7 44 24 08 ed 92 10 	movl   $0xc01092ed,0x8(%esp)
c0103fcc:	c0 
c0103fcd:	c7 44 24 04 ff 01 00 	movl   $0x1ff,0x4(%esp)
c0103fd4:	00 
c0103fd5:	c7 04 24 c8 92 10 c0 	movl   $0xc01092c8,(%esp)
c0103fdc:	e8 54 c4 ff ff       	call   c0100435 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c0103fe1:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c0103fe6:	8b 00                	mov    (%eax),%eax
c0103fe8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103fed:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103ff0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103ff3:	c1 e8 0c             	shr    $0xc,%eax
c0103ff6:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103ff9:	a1 80 5f 12 c0       	mov    0xc0125f80,%eax
c0103ffe:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0104001:	72 23                	jb     c0104026 <check_pgdir+0x20e>
c0104003:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104006:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010400a:	c7 44 24 08 00 92 10 	movl   $0xc0109200,0x8(%esp)
c0104011:	c0 
c0104012:	c7 44 24 04 01 02 00 	movl   $0x201,0x4(%esp)
c0104019:	00 
c010401a:	c7 04 24 c8 92 10 c0 	movl   $0xc01092c8,(%esp)
c0104021:	e8 0f c4 ff ff       	call   c0100435 <__panic>
c0104026:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104029:	2d 00 00 00 40       	sub    $0x40000000,%eax
c010402e:	83 c0 04             	add    $0x4,%eax
c0104031:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c0104034:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c0104039:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104040:	00 
c0104041:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104048:	00 
c0104049:	89 04 24             	mov    %eax,(%esp)
c010404c:	e8 01 fb ff ff       	call   c0103b52 <get_pte>
c0104051:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0104054:	74 24                	je     c010407a <check_pgdir+0x262>
c0104056:	c7 44 24 0c 5c 94 10 	movl   $0xc010945c,0xc(%esp)
c010405d:	c0 
c010405e:	c7 44 24 08 ed 92 10 	movl   $0xc01092ed,0x8(%esp)
c0104065:	c0 
c0104066:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
c010406d:	00 
c010406e:	c7 04 24 c8 92 10 c0 	movl   $0xc01092c8,(%esp)
c0104075:	e8 bb c3 ff ff       	call   c0100435 <__panic>

    p2 = alloc_page();
c010407a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104081:	e8 01 f4 ff ff       	call   c0103487 <alloc_pages>
c0104086:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c0104089:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c010408e:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c0104095:	00 
c0104096:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c010409d:	00 
c010409e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01040a1:	89 54 24 04          	mov    %edx,0x4(%esp)
c01040a5:	89 04 24             	mov    %eax,(%esp)
c01040a8:	e8 5b fb ff ff       	call   c0103c08 <page_insert>
c01040ad:	85 c0                	test   %eax,%eax
c01040af:	74 24                	je     c01040d5 <check_pgdir+0x2bd>
c01040b1:	c7 44 24 0c 84 94 10 	movl   $0xc0109484,0xc(%esp)
c01040b8:	c0 
c01040b9:	c7 44 24 08 ed 92 10 	movl   $0xc01092ed,0x8(%esp)
c01040c0:	c0 
c01040c1:	c7 44 24 04 05 02 00 	movl   $0x205,0x4(%esp)
c01040c8:	00 
c01040c9:	c7 04 24 c8 92 10 c0 	movl   $0xc01092c8,(%esp)
c01040d0:	e8 60 c3 ff ff       	call   c0100435 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c01040d5:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c01040da:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01040e1:	00 
c01040e2:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01040e9:	00 
c01040ea:	89 04 24             	mov    %eax,(%esp)
c01040ed:	e8 60 fa ff ff       	call   c0103b52 <get_pte>
c01040f2:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01040f5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01040f9:	75 24                	jne    c010411f <check_pgdir+0x307>
c01040fb:	c7 44 24 0c bc 94 10 	movl   $0xc01094bc,0xc(%esp)
c0104102:	c0 
c0104103:	c7 44 24 08 ed 92 10 	movl   $0xc01092ed,0x8(%esp)
c010410a:	c0 
c010410b:	c7 44 24 04 06 02 00 	movl   $0x206,0x4(%esp)
c0104112:	00 
c0104113:	c7 04 24 c8 92 10 c0 	movl   $0xc01092c8,(%esp)
c010411a:	e8 16 c3 ff ff       	call   c0100435 <__panic>
    assert(*ptep & PTE_U);
c010411f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104122:	8b 00                	mov    (%eax),%eax
c0104124:	83 e0 04             	and    $0x4,%eax
c0104127:	85 c0                	test   %eax,%eax
c0104129:	75 24                	jne    c010414f <check_pgdir+0x337>
c010412b:	c7 44 24 0c ec 94 10 	movl   $0xc01094ec,0xc(%esp)
c0104132:	c0 
c0104133:	c7 44 24 08 ed 92 10 	movl   $0xc01092ed,0x8(%esp)
c010413a:	c0 
c010413b:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
c0104142:	00 
c0104143:	c7 04 24 c8 92 10 c0 	movl   $0xc01092c8,(%esp)
c010414a:	e8 e6 c2 ff ff       	call   c0100435 <__panic>
    assert(*ptep & PTE_W);
c010414f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104152:	8b 00                	mov    (%eax),%eax
c0104154:	83 e0 02             	and    $0x2,%eax
c0104157:	85 c0                	test   %eax,%eax
c0104159:	75 24                	jne    c010417f <check_pgdir+0x367>
c010415b:	c7 44 24 0c fa 94 10 	movl   $0xc01094fa,0xc(%esp)
c0104162:	c0 
c0104163:	c7 44 24 08 ed 92 10 	movl   $0xc01092ed,0x8(%esp)
c010416a:	c0 
c010416b:	c7 44 24 04 08 02 00 	movl   $0x208,0x4(%esp)
c0104172:	00 
c0104173:	c7 04 24 c8 92 10 c0 	movl   $0xc01092c8,(%esp)
c010417a:	e8 b6 c2 ff ff       	call   c0100435 <__panic>
    assert(boot_pgdir[0] & PTE_U);
c010417f:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c0104184:	8b 00                	mov    (%eax),%eax
c0104186:	83 e0 04             	and    $0x4,%eax
c0104189:	85 c0                	test   %eax,%eax
c010418b:	75 24                	jne    c01041b1 <check_pgdir+0x399>
c010418d:	c7 44 24 0c 08 95 10 	movl   $0xc0109508,0xc(%esp)
c0104194:	c0 
c0104195:	c7 44 24 08 ed 92 10 	movl   $0xc01092ed,0x8(%esp)
c010419c:	c0 
c010419d:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
c01041a4:	00 
c01041a5:	c7 04 24 c8 92 10 c0 	movl   $0xc01092c8,(%esp)
c01041ac:	e8 84 c2 ff ff       	call   c0100435 <__panic>
    assert(page_ref(p2) == 1);
c01041b1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01041b4:	89 04 24             	mov    %eax,(%esp)
c01041b7:	e8 c3 f0 ff ff       	call   c010327f <page_ref>
c01041bc:	83 f8 01             	cmp    $0x1,%eax
c01041bf:	74 24                	je     c01041e5 <check_pgdir+0x3cd>
c01041c1:	c7 44 24 0c 1e 95 10 	movl   $0xc010951e,0xc(%esp)
c01041c8:	c0 
c01041c9:	c7 44 24 08 ed 92 10 	movl   $0xc01092ed,0x8(%esp)
c01041d0:	c0 
c01041d1:	c7 44 24 04 0a 02 00 	movl   $0x20a,0x4(%esp)
c01041d8:	00 
c01041d9:	c7 04 24 c8 92 10 c0 	movl   $0xc01092c8,(%esp)
c01041e0:	e8 50 c2 ff ff       	call   c0100435 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c01041e5:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c01041ea:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01041f1:	00 
c01041f2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c01041f9:	00 
c01041fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01041fd:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104201:	89 04 24             	mov    %eax,(%esp)
c0104204:	e8 ff f9 ff ff       	call   c0103c08 <page_insert>
c0104209:	85 c0                	test   %eax,%eax
c010420b:	74 24                	je     c0104231 <check_pgdir+0x419>
c010420d:	c7 44 24 0c 30 95 10 	movl   $0xc0109530,0xc(%esp)
c0104214:	c0 
c0104215:	c7 44 24 08 ed 92 10 	movl   $0xc01092ed,0x8(%esp)
c010421c:	c0 
c010421d:	c7 44 24 04 0c 02 00 	movl   $0x20c,0x4(%esp)
c0104224:	00 
c0104225:	c7 04 24 c8 92 10 c0 	movl   $0xc01092c8,(%esp)
c010422c:	e8 04 c2 ff ff       	call   c0100435 <__panic>
    assert(page_ref(p1) == 2);
c0104231:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104234:	89 04 24             	mov    %eax,(%esp)
c0104237:	e8 43 f0 ff ff       	call   c010327f <page_ref>
c010423c:	83 f8 02             	cmp    $0x2,%eax
c010423f:	74 24                	je     c0104265 <check_pgdir+0x44d>
c0104241:	c7 44 24 0c 5c 95 10 	movl   $0xc010955c,0xc(%esp)
c0104248:	c0 
c0104249:	c7 44 24 08 ed 92 10 	movl   $0xc01092ed,0x8(%esp)
c0104250:	c0 
c0104251:	c7 44 24 04 0d 02 00 	movl   $0x20d,0x4(%esp)
c0104258:	00 
c0104259:	c7 04 24 c8 92 10 c0 	movl   $0xc01092c8,(%esp)
c0104260:	e8 d0 c1 ff ff       	call   c0100435 <__panic>
    assert(page_ref(p2) == 0);
c0104265:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104268:	89 04 24             	mov    %eax,(%esp)
c010426b:	e8 0f f0 ff ff       	call   c010327f <page_ref>
c0104270:	85 c0                	test   %eax,%eax
c0104272:	74 24                	je     c0104298 <check_pgdir+0x480>
c0104274:	c7 44 24 0c 6e 95 10 	movl   $0xc010956e,0xc(%esp)
c010427b:	c0 
c010427c:	c7 44 24 08 ed 92 10 	movl   $0xc01092ed,0x8(%esp)
c0104283:	c0 
c0104284:	c7 44 24 04 0e 02 00 	movl   $0x20e,0x4(%esp)
c010428b:	00 
c010428c:	c7 04 24 c8 92 10 c0 	movl   $0xc01092c8,(%esp)
c0104293:	e8 9d c1 ff ff       	call   c0100435 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0104298:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c010429d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01042a4:	00 
c01042a5:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01042ac:	00 
c01042ad:	89 04 24             	mov    %eax,(%esp)
c01042b0:	e8 9d f8 ff ff       	call   c0103b52 <get_pte>
c01042b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01042b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01042bc:	75 24                	jne    c01042e2 <check_pgdir+0x4ca>
c01042be:	c7 44 24 0c bc 94 10 	movl   $0xc01094bc,0xc(%esp)
c01042c5:	c0 
c01042c6:	c7 44 24 08 ed 92 10 	movl   $0xc01092ed,0x8(%esp)
c01042cd:	c0 
c01042ce:	c7 44 24 04 0f 02 00 	movl   $0x20f,0x4(%esp)
c01042d5:	00 
c01042d6:	c7 04 24 c8 92 10 c0 	movl   $0xc01092c8,(%esp)
c01042dd:	e8 53 c1 ff ff       	call   c0100435 <__panic>
    assert(pte2page(*ptep) == p1);
c01042e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01042e5:	8b 00                	mov    (%eax),%eax
c01042e7:	89 04 24             	mov    %eax,(%esp)
c01042ea:	e8 3a ef ff ff       	call   c0103229 <pte2page>
c01042ef:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01042f2:	74 24                	je     c0104318 <check_pgdir+0x500>
c01042f4:	c7 44 24 0c 31 94 10 	movl   $0xc0109431,0xc(%esp)
c01042fb:	c0 
c01042fc:	c7 44 24 08 ed 92 10 	movl   $0xc01092ed,0x8(%esp)
c0104303:	c0 
c0104304:	c7 44 24 04 10 02 00 	movl   $0x210,0x4(%esp)
c010430b:	00 
c010430c:	c7 04 24 c8 92 10 c0 	movl   $0xc01092c8,(%esp)
c0104313:	e8 1d c1 ff ff       	call   c0100435 <__panic>
    assert((*ptep & PTE_U) == 0);
c0104318:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010431b:	8b 00                	mov    (%eax),%eax
c010431d:	83 e0 04             	and    $0x4,%eax
c0104320:	85 c0                	test   %eax,%eax
c0104322:	74 24                	je     c0104348 <check_pgdir+0x530>
c0104324:	c7 44 24 0c 80 95 10 	movl   $0xc0109580,0xc(%esp)
c010432b:	c0 
c010432c:	c7 44 24 08 ed 92 10 	movl   $0xc01092ed,0x8(%esp)
c0104333:	c0 
c0104334:	c7 44 24 04 11 02 00 	movl   $0x211,0x4(%esp)
c010433b:	00 
c010433c:	c7 04 24 c8 92 10 c0 	movl   $0xc01092c8,(%esp)
c0104343:	e8 ed c0 ff ff       	call   c0100435 <__panic>

    page_remove(boot_pgdir, 0x0);
c0104348:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c010434d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104354:	00 
c0104355:	89 04 24             	mov    %eax,(%esp)
c0104358:	e8 62 f8 ff ff       	call   c0103bbf <page_remove>
    assert(page_ref(p1) == 1);
c010435d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104360:	89 04 24             	mov    %eax,(%esp)
c0104363:	e8 17 ef ff ff       	call   c010327f <page_ref>
c0104368:	83 f8 01             	cmp    $0x1,%eax
c010436b:	74 24                	je     c0104391 <check_pgdir+0x579>
c010436d:	c7 44 24 0c 47 94 10 	movl   $0xc0109447,0xc(%esp)
c0104374:	c0 
c0104375:	c7 44 24 08 ed 92 10 	movl   $0xc01092ed,0x8(%esp)
c010437c:	c0 
c010437d:	c7 44 24 04 14 02 00 	movl   $0x214,0x4(%esp)
c0104384:	00 
c0104385:	c7 04 24 c8 92 10 c0 	movl   $0xc01092c8,(%esp)
c010438c:	e8 a4 c0 ff ff       	call   c0100435 <__panic>
    assert(page_ref(p2) == 0);
c0104391:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104394:	89 04 24             	mov    %eax,(%esp)
c0104397:	e8 e3 ee ff ff       	call   c010327f <page_ref>
c010439c:	85 c0                	test   %eax,%eax
c010439e:	74 24                	je     c01043c4 <check_pgdir+0x5ac>
c01043a0:	c7 44 24 0c 6e 95 10 	movl   $0xc010956e,0xc(%esp)
c01043a7:	c0 
c01043a8:	c7 44 24 08 ed 92 10 	movl   $0xc01092ed,0x8(%esp)
c01043af:	c0 
c01043b0:	c7 44 24 04 15 02 00 	movl   $0x215,0x4(%esp)
c01043b7:	00 
c01043b8:	c7 04 24 c8 92 10 c0 	movl   $0xc01092c8,(%esp)
c01043bf:	e8 71 c0 ff ff       	call   c0100435 <__panic>

    page_remove(boot_pgdir, PGSIZE);
c01043c4:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c01043c9:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01043d0:	00 
c01043d1:	89 04 24             	mov    %eax,(%esp)
c01043d4:	e8 e6 f7 ff ff       	call   c0103bbf <page_remove>
    assert(page_ref(p1) == 0);
c01043d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01043dc:	89 04 24             	mov    %eax,(%esp)
c01043df:	e8 9b ee ff ff       	call   c010327f <page_ref>
c01043e4:	85 c0                	test   %eax,%eax
c01043e6:	74 24                	je     c010440c <check_pgdir+0x5f4>
c01043e8:	c7 44 24 0c 95 95 10 	movl   $0xc0109595,0xc(%esp)
c01043ef:	c0 
c01043f0:	c7 44 24 08 ed 92 10 	movl   $0xc01092ed,0x8(%esp)
c01043f7:	c0 
c01043f8:	c7 44 24 04 18 02 00 	movl   $0x218,0x4(%esp)
c01043ff:	00 
c0104400:	c7 04 24 c8 92 10 c0 	movl   $0xc01092c8,(%esp)
c0104407:	e8 29 c0 ff ff       	call   c0100435 <__panic>
    assert(page_ref(p2) == 0);
c010440c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010440f:	89 04 24             	mov    %eax,(%esp)
c0104412:	e8 68 ee ff ff       	call   c010327f <page_ref>
c0104417:	85 c0                	test   %eax,%eax
c0104419:	74 24                	je     c010443f <check_pgdir+0x627>
c010441b:	c7 44 24 0c 6e 95 10 	movl   $0xc010956e,0xc(%esp)
c0104422:	c0 
c0104423:	c7 44 24 08 ed 92 10 	movl   $0xc01092ed,0x8(%esp)
c010442a:	c0 
c010442b:	c7 44 24 04 19 02 00 	movl   $0x219,0x4(%esp)
c0104432:	00 
c0104433:	c7 04 24 c8 92 10 c0 	movl   $0xc01092c8,(%esp)
c010443a:	e8 f6 bf ff ff       	call   c0100435 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c010443f:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c0104444:	8b 00                	mov    (%eax),%eax
c0104446:	89 04 24             	mov    %eax,(%esp)
c0104449:	e8 19 ee ff ff       	call   c0103267 <pde2page>
c010444e:	89 04 24             	mov    %eax,(%esp)
c0104451:	e8 29 ee ff ff       	call   c010327f <page_ref>
c0104456:	83 f8 01             	cmp    $0x1,%eax
c0104459:	74 24                	je     c010447f <check_pgdir+0x667>
c010445b:	c7 44 24 0c a8 95 10 	movl   $0xc01095a8,0xc(%esp)
c0104462:	c0 
c0104463:	c7 44 24 08 ed 92 10 	movl   $0xc01092ed,0x8(%esp)
c010446a:	c0 
c010446b:	c7 44 24 04 1b 02 00 	movl   $0x21b,0x4(%esp)
c0104472:	00 
c0104473:	c7 04 24 c8 92 10 c0 	movl   $0xc01092c8,(%esp)
c010447a:	e8 b6 bf ff ff       	call   c0100435 <__panic>
    free_page(pde2page(boot_pgdir[0]));
c010447f:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c0104484:	8b 00                	mov    (%eax),%eax
c0104486:	89 04 24             	mov    %eax,(%esp)
c0104489:	e8 d9 ed ff ff       	call   c0103267 <pde2page>
c010448e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104495:	00 
c0104496:	89 04 24             	mov    %eax,(%esp)
c0104499:	e8 58 f0 ff ff       	call   c01034f6 <free_pages>
    boot_pgdir[0] = 0;
c010449e:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c01044a3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c01044a9:	c7 04 24 cf 95 10 c0 	movl   $0xc01095cf,(%esp)
c01044b0:	e8 14 be ff ff       	call   c01002c9 <cprintf>
}
c01044b5:	90                   	nop
c01044b6:	c9                   	leave  
c01044b7:	c3                   	ret    

c01044b8 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c01044b8:	f3 0f 1e fb          	endbr32 
c01044bc:	55                   	push   %ebp
c01044bd:	89 e5                	mov    %esp,%ebp
c01044bf:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c01044c2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01044c9:	e9 ca 00 00 00       	jmp    c0104598 <check_boot_pgdir+0xe0>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c01044ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01044d1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01044d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01044d7:	c1 e8 0c             	shr    $0xc,%eax
c01044da:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01044dd:	a1 80 5f 12 c0       	mov    0xc0125f80,%eax
c01044e2:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c01044e5:	72 23                	jb     c010450a <check_boot_pgdir+0x52>
c01044e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01044ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01044ee:	c7 44 24 08 00 92 10 	movl   $0xc0109200,0x8(%esp)
c01044f5:	c0 
c01044f6:	c7 44 24 04 27 02 00 	movl   $0x227,0x4(%esp)
c01044fd:	00 
c01044fe:	c7 04 24 c8 92 10 c0 	movl   $0xc01092c8,(%esp)
c0104505:	e8 2b bf ff ff       	call   c0100435 <__panic>
c010450a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010450d:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0104512:	89 c2                	mov    %eax,%edx
c0104514:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c0104519:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104520:	00 
c0104521:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104525:	89 04 24             	mov    %eax,(%esp)
c0104528:	e8 25 f6 ff ff       	call   c0103b52 <get_pte>
c010452d:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0104530:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0104534:	75 24                	jne    c010455a <check_boot_pgdir+0xa2>
c0104536:	c7 44 24 0c ec 95 10 	movl   $0xc01095ec,0xc(%esp)
c010453d:	c0 
c010453e:	c7 44 24 08 ed 92 10 	movl   $0xc01092ed,0x8(%esp)
c0104545:	c0 
c0104546:	c7 44 24 04 27 02 00 	movl   $0x227,0x4(%esp)
c010454d:	00 
c010454e:	c7 04 24 c8 92 10 c0 	movl   $0xc01092c8,(%esp)
c0104555:	e8 db be ff ff       	call   c0100435 <__panic>
        assert(PTE_ADDR(*ptep) == i);
c010455a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010455d:	8b 00                	mov    (%eax),%eax
c010455f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104564:	89 c2                	mov    %eax,%edx
c0104566:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104569:	39 c2                	cmp    %eax,%edx
c010456b:	74 24                	je     c0104591 <check_boot_pgdir+0xd9>
c010456d:	c7 44 24 0c 29 96 10 	movl   $0xc0109629,0xc(%esp)
c0104574:	c0 
c0104575:	c7 44 24 08 ed 92 10 	movl   $0xc01092ed,0x8(%esp)
c010457c:	c0 
c010457d:	c7 44 24 04 28 02 00 	movl   $0x228,0x4(%esp)
c0104584:	00 
c0104585:	c7 04 24 c8 92 10 c0 	movl   $0xc01092c8,(%esp)
c010458c:	e8 a4 be ff ff       	call   c0100435 <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
c0104591:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c0104598:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010459b:	a1 80 5f 12 c0       	mov    0xc0125f80,%eax
c01045a0:	39 c2                	cmp    %eax,%edx
c01045a2:	0f 82 26 ff ff ff    	jb     c01044ce <check_boot_pgdir+0x16>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c01045a8:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c01045ad:	05 ac 0f 00 00       	add    $0xfac,%eax
c01045b2:	8b 00                	mov    (%eax),%eax
c01045b4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01045b9:	89 c2                	mov    %eax,%edx
c01045bb:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c01045c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01045c3:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c01045ca:	77 23                	ja     c01045ef <check_boot_pgdir+0x137>
c01045cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01045cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01045d3:	c7 44 24 08 24 92 10 	movl   $0xc0109224,0x8(%esp)
c01045da:	c0 
c01045db:	c7 44 24 04 2b 02 00 	movl   $0x22b,0x4(%esp)
c01045e2:	00 
c01045e3:	c7 04 24 c8 92 10 c0 	movl   $0xc01092c8,(%esp)
c01045ea:	e8 46 be ff ff       	call   c0100435 <__panic>
c01045ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01045f2:	05 00 00 00 40       	add    $0x40000000,%eax
c01045f7:	39 d0                	cmp    %edx,%eax
c01045f9:	74 24                	je     c010461f <check_boot_pgdir+0x167>
c01045fb:	c7 44 24 0c 40 96 10 	movl   $0xc0109640,0xc(%esp)
c0104602:	c0 
c0104603:	c7 44 24 08 ed 92 10 	movl   $0xc01092ed,0x8(%esp)
c010460a:	c0 
c010460b:	c7 44 24 04 2b 02 00 	movl   $0x22b,0x4(%esp)
c0104612:	00 
c0104613:	c7 04 24 c8 92 10 c0 	movl   $0xc01092c8,(%esp)
c010461a:	e8 16 be ff ff       	call   c0100435 <__panic>

    assert(boot_pgdir[0] == 0);
c010461f:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c0104624:	8b 00                	mov    (%eax),%eax
c0104626:	85 c0                	test   %eax,%eax
c0104628:	74 24                	je     c010464e <check_boot_pgdir+0x196>
c010462a:	c7 44 24 0c 74 96 10 	movl   $0xc0109674,0xc(%esp)
c0104631:	c0 
c0104632:	c7 44 24 08 ed 92 10 	movl   $0xc01092ed,0x8(%esp)
c0104639:	c0 
c010463a:	c7 44 24 04 2d 02 00 	movl   $0x22d,0x4(%esp)
c0104641:	00 
c0104642:	c7 04 24 c8 92 10 c0 	movl   $0xc01092c8,(%esp)
c0104649:	e8 e7 bd ff ff       	call   c0100435 <__panic>

    struct Page *p;
    p = alloc_page();
c010464e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104655:	e8 2d ee ff ff       	call   c0103487 <alloc_pages>
c010465a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c010465d:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c0104662:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0104669:	00 
c010466a:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c0104671:	00 
c0104672:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104675:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104679:	89 04 24             	mov    %eax,(%esp)
c010467c:	e8 87 f5 ff ff       	call   c0103c08 <page_insert>
c0104681:	85 c0                	test   %eax,%eax
c0104683:	74 24                	je     c01046a9 <check_boot_pgdir+0x1f1>
c0104685:	c7 44 24 0c 88 96 10 	movl   $0xc0109688,0xc(%esp)
c010468c:	c0 
c010468d:	c7 44 24 08 ed 92 10 	movl   $0xc01092ed,0x8(%esp)
c0104694:	c0 
c0104695:	c7 44 24 04 31 02 00 	movl   $0x231,0x4(%esp)
c010469c:	00 
c010469d:	c7 04 24 c8 92 10 c0 	movl   $0xc01092c8,(%esp)
c01046a4:	e8 8c bd ff ff       	call   c0100435 <__panic>
    assert(page_ref(p) == 1);
c01046a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01046ac:	89 04 24             	mov    %eax,(%esp)
c01046af:	e8 cb eb ff ff       	call   c010327f <page_ref>
c01046b4:	83 f8 01             	cmp    $0x1,%eax
c01046b7:	74 24                	je     c01046dd <check_boot_pgdir+0x225>
c01046b9:	c7 44 24 0c b6 96 10 	movl   $0xc01096b6,0xc(%esp)
c01046c0:	c0 
c01046c1:	c7 44 24 08 ed 92 10 	movl   $0xc01092ed,0x8(%esp)
c01046c8:	c0 
c01046c9:	c7 44 24 04 32 02 00 	movl   $0x232,0x4(%esp)
c01046d0:	00 
c01046d1:	c7 04 24 c8 92 10 c0 	movl   $0xc01092c8,(%esp)
c01046d8:	e8 58 bd ff ff       	call   c0100435 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c01046dd:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c01046e2:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c01046e9:	00 
c01046ea:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c01046f1:	00 
c01046f2:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01046f5:	89 54 24 04          	mov    %edx,0x4(%esp)
c01046f9:	89 04 24             	mov    %eax,(%esp)
c01046fc:	e8 07 f5 ff ff       	call   c0103c08 <page_insert>
c0104701:	85 c0                	test   %eax,%eax
c0104703:	74 24                	je     c0104729 <check_boot_pgdir+0x271>
c0104705:	c7 44 24 0c c8 96 10 	movl   $0xc01096c8,0xc(%esp)
c010470c:	c0 
c010470d:	c7 44 24 08 ed 92 10 	movl   $0xc01092ed,0x8(%esp)
c0104714:	c0 
c0104715:	c7 44 24 04 33 02 00 	movl   $0x233,0x4(%esp)
c010471c:	00 
c010471d:	c7 04 24 c8 92 10 c0 	movl   $0xc01092c8,(%esp)
c0104724:	e8 0c bd ff ff       	call   c0100435 <__panic>
    assert(page_ref(p) == 2);
c0104729:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010472c:	89 04 24             	mov    %eax,(%esp)
c010472f:	e8 4b eb ff ff       	call   c010327f <page_ref>
c0104734:	83 f8 02             	cmp    $0x2,%eax
c0104737:	74 24                	je     c010475d <check_boot_pgdir+0x2a5>
c0104739:	c7 44 24 0c ff 96 10 	movl   $0xc01096ff,0xc(%esp)
c0104740:	c0 
c0104741:	c7 44 24 08 ed 92 10 	movl   $0xc01092ed,0x8(%esp)
c0104748:	c0 
c0104749:	c7 44 24 04 34 02 00 	movl   $0x234,0x4(%esp)
c0104750:	00 
c0104751:	c7 04 24 c8 92 10 c0 	movl   $0xc01092c8,(%esp)
c0104758:	e8 d8 bc ff ff       	call   c0100435 <__panic>

    const char *str = "ucore: Hello world!!";
c010475d:	c7 45 e8 10 97 10 c0 	movl   $0xc0109710,-0x18(%ebp)
    strcpy((void *)0x100, str);
c0104764:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104767:	89 44 24 04          	mov    %eax,0x4(%esp)
c010476b:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0104772:	e8 5c 35 00 00       	call   c0107cd3 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c0104777:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c010477e:	00 
c010477f:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0104786:	e8 c6 35 00 00       	call   c0107d51 <strcmp>
c010478b:	85 c0                	test   %eax,%eax
c010478d:	74 24                	je     c01047b3 <check_boot_pgdir+0x2fb>
c010478f:	c7 44 24 0c 28 97 10 	movl   $0xc0109728,0xc(%esp)
c0104796:	c0 
c0104797:	c7 44 24 08 ed 92 10 	movl   $0xc01092ed,0x8(%esp)
c010479e:	c0 
c010479f:	c7 44 24 04 38 02 00 	movl   $0x238,0x4(%esp)
c01047a6:	00 
c01047a7:	c7 04 24 c8 92 10 c0 	movl   $0xc01092c8,(%esp)
c01047ae:	e8 82 bc ff ff       	call   c0100435 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c01047b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01047b6:	89 04 24             	mov    %eax,(%esp)
c01047b9:	e8 cd e9 ff ff       	call   c010318b <page2kva>
c01047be:	05 00 01 00 00       	add    $0x100,%eax
c01047c3:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c01047c6:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c01047cd:	e8 a3 34 00 00       	call   c0107c75 <strlen>
c01047d2:	85 c0                	test   %eax,%eax
c01047d4:	74 24                	je     c01047fa <check_boot_pgdir+0x342>
c01047d6:	c7 44 24 0c 60 97 10 	movl   $0xc0109760,0xc(%esp)
c01047dd:	c0 
c01047de:	c7 44 24 08 ed 92 10 	movl   $0xc01092ed,0x8(%esp)
c01047e5:	c0 
c01047e6:	c7 44 24 04 3b 02 00 	movl   $0x23b,0x4(%esp)
c01047ed:	00 
c01047ee:	c7 04 24 c8 92 10 c0 	movl   $0xc01092c8,(%esp)
c01047f5:	e8 3b bc ff ff       	call   c0100435 <__panic>

    free_page(p);
c01047fa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104801:	00 
c0104802:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104805:	89 04 24             	mov    %eax,(%esp)
c0104808:	e8 e9 ec ff ff       	call   c01034f6 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c010480d:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c0104812:	8b 00                	mov    (%eax),%eax
c0104814:	89 04 24             	mov    %eax,(%esp)
c0104817:	e8 4b ea ff ff       	call   c0103267 <pde2page>
c010481c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104823:	00 
c0104824:	89 04 24             	mov    %eax,(%esp)
c0104827:	e8 ca ec ff ff       	call   c01034f6 <free_pages>
    boot_pgdir[0] = 0;
c010482c:	a1 e0 29 12 c0       	mov    0xc01229e0,%eax
c0104831:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c0104837:	c7 04 24 84 97 10 c0 	movl   $0xc0109784,(%esp)
c010483e:	e8 86 ba ff ff       	call   c01002c9 <cprintf>
}
c0104843:	90                   	nop
c0104844:	c9                   	leave  
c0104845:	c3                   	ret    

c0104846 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0104846:	f3 0f 1e fb          	endbr32 
c010484a:	55                   	push   %ebp
c010484b:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c010484d:	8b 45 08             	mov    0x8(%ebp),%eax
c0104850:	83 e0 04             	and    $0x4,%eax
c0104853:	85 c0                	test   %eax,%eax
c0104855:	74 04                	je     c010485b <perm2str+0x15>
c0104857:	b0 75                	mov    $0x75,%al
c0104859:	eb 02                	jmp    c010485d <perm2str+0x17>
c010485b:	b0 2d                	mov    $0x2d,%al
c010485d:	a2 08 60 12 c0       	mov    %al,0xc0126008
    str[1] = 'r';
c0104862:	c6 05 09 60 12 c0 72 	movb   $0x72,0xc0126009
    str[2] = (perm & PTE_W) ? 'w' : '-';
c0104869:	8b 45 08             	mov    0x8(%ebp),%eax
c010486c:	83 e0 02             	and    $0x2,%eax
c010486f:	85 c0                	test   %eax,%eax
c0104871:	74 04                	je     c0104877 <perm2str+0x31>
c0104873:	b0 77                	mov    $0x77,%al
c0104875:	eb 02                	jmp    c0104879 <perm2str+0x33>
c0104877:	b0 2d                	mov    $0x2d,%al
c0104879:	a2 0a 60 12 c0       	mov    %al,0xc012600a
    str[3] = '\0';
c010487e:	c6 05 0b 60 12 c0 00 	movb   $0x0,0xc012600b
    return str;
c0104885:	b8 08 60 12 c0       	mov    $0xc0126008,%eax
}
c010488a:	5d                   	pop    %ebp
c010488b:	c3                   	ret    

c010488c <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c010488c:	f3 0f 1e fb          	endbr32 
c0104890:	55                   	push   %ebp
c0104891:	89 e5                	mov    %esp,%ebp
c0104893:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c0104896:	8b 45 10             	mov    0x10(%ebp),%eax
c0104899:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010489c:	72 0d                	jb     c01048ab <get_pgtable_items+0x1f>
        return 0;
c010489e:	b8 00 00 00 00       	mov    $0x0,%eax
c01048a3:	e9 98 00 00 00       	jmp    c0104940 <get_pgtable_items+0xb4>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
c01048a8:	ff 45 10             	incl   0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
c01048ab:	8b 45 10             	mov    0x10(%ebp),%eax
c01048ae:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01048b1:	73 18                	jae    c01048cb <get_pgtable_items+0x3f>
c01048b3:	8b 45 10             	mov    0x10(%ebp),%eax
c01048b6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01048bd:	8b 45 14             	mov    0x14(%ebp),%eax
c01048c0:	01 d0                	add    %edx,%eax
c01048c2:	8b 00                	mov    (%eax),%eax
c01048c4:	83 e0 01             	and    $0x1,%eax
c01048c7:	85 c0                	test   %eax,%eax
c01048c9:	74 dd                	je     c01048a8 <get_pgtable_items+0x1c>
    }
    if (start < right) {
c01048cb:	8b 45 10             	mov    0x10(%ebp),%eax
c01048ce:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01048d1:	73 68                	jae    c010493b <get_pgtable_items+0xaf>
        if (left_store != NULL) {
c01048d3:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c01048d7:	74 08                	je     c01048e1 <get_pgtable_items+0x55>
            *left_store = start;
c01048d9:	8b 45 18             	mov    0x18(%ebp),%eax
c01048dc:	8b 55 10             	mov    0x10(%ebp),%edx
c01048df:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c01048e1:	8b 45 10             	mov    0x10(%ebp),%eax
c01048e4:	8d 50 01             	lea    0x1(%eax),%edx
c01048e7:	89 55 10             	mov    %edx,0x10(%ebp)
c01048ea:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01048f1:	8b 45 14             	mov    0x14(%ebp),%eax
c01048f4:	01 d0                	add    %edx,%eax
c01048f6:	8b 00                	mov    (%eax),%eax
c01048f8:	83 e0 07             	and    $0x7,%eax
c01048fb:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c01048fe:	eb 03                	jmp    c0104903 <get_pgtable_items+0x77>
            start ++;
c0104900:	ff 45 10             	incl   0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0104903:	8b 45 10             	mov    0x10(%ebp),%eax
c0104906:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104909:	73 1d                	jae    c0104928 <get_pgtable_items+0x9c>
c010490b:	8b 45 10             	mov    0x10(%ebp),%eax
c010490e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0104915:	8b 45 14             	mov    0x14(%ebp),%eax
c0104918:	01 d0                	add    %edx,%eax
c010491a:	8b 00                	mov    (%eax),%eax
c010491c:	83 e0 07             	and    $0x7,%eax
c010491f:	89 c2                	mov    %eax,%edx
c0104921:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104924:	39 c2                	cmp    %eax,%edx
c0104926:	74 d8                	je     c0104900 <get_pgtable_items+0x74>
        }
        if (right_store != NULL) {
c0104928:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c010492c:	74 08                	je     c0104936 <get_pgtable_items+0xaa>
            *right_store = start;
c010492e:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0104931:	8b 55 10             	mov    0x10(%ebp),%edx
c0104934:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c0104936:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104939:	eb 05                	jmp    c0104940 <get_pgtable_items+0xb4>
    }
    return 0;
c010493b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104940:	c9                   	leave  
c0104941:	c3                   	ret    

c0104942 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c0104942:	f3 0f 1e fb          	endbr32 
c0104946:	55                   	push   %ebp
c0104947:	89 e5                	mov    %esp,%ebp
c0104949:	57                   	push   %edi
c010494a:	56                   	push   %esi
c010494b:	53                   	push   %ebx
c010494c:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c010494f:	c7 04 24 a4 97 10 c0 	movl   $0xc01097a4,(%esp)
c0104956:	e8 6e b9 ff ff       	call   c01002c9 <cprintf>
    size_t left, right = 0, perm;
c010495b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0104962:	e9 fa 00 00 00       	jmp    c0104a61 <print_pgdir+0x11f>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0104967:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010496a:	89 04 24             	mov    %eax,(%esp)
c010496d:	e8 d4 fe ff ff       	call   c0104846 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0104972:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0104975:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104978:	29 d1                	sub    %edx,%ecx
c010497a:	89 ca                	mov    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c010497c:	89 d6                	mov    %edx,%esi
c010497e:	c1 e6 16             	shl    $0x16,%esi
c0104981:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104984:	89 d3                	mov    %edx,%ebx
c0104986:	c1 e3 16             	shl    $0x16,%ebx
c0104989:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010498c:	89 d1                	mov    %edx,%ecx
c010498e:	c1 e1 16             	shl    $0x16,%ecx
c0104991:	8b 7d dc             	mov    -0x24(%ebp),%edi
c0104994:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104997:	29 d7                	sub    %edx,%edi
c0104999:	89 fa                	mov    %edi,%edx
c010499b:	89 44 24 14          	mov    %eax,0x14(%esp)
c010499f:	89 74 24 10          	mov    %esi,0x10(%esp)
c01049a3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01049a7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01049ab:	89 54 24 04          	mov    %edx,0x4(%esp)
c01049af:	c7 04 24 d5 97 10 c0 	movl   $0xc01097d5,(%esp)
c01049b6:	e8 0e b9 ff ff       	call   c01002c9 <cprintf>
        size_t l, r = left * NPTEENTRY;
c01049bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01049be:	c1 e0 0a             	shl    $0xa,%eax
c01049c1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c01049c4:	eb 54                	jmp    c0104a1a <print_pgdir+0xd8>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c01049c6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01049c9:	89 04 24             	mov    %eax,(%esp)
c01049cc:	e8 75 fe ff ff       	call   c0104846 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c01049d1:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c01049d4:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01049d7:	29 d1                	sub    %edx,%ecx
c01049d9:	89 ca                	mov    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c01049db:	89 d6                	mov    %edx,%esi
c01049dd:	c1 e6 0c             	shl    $0xc,%esi
c01049e0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01049e3:	89 d3                	mov    %edx,%ebx
c01049e5:	c1 e3 0c             	shl    $0xc,%ebx
c01049e8:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01049eb:	89 d1                	mov    %edx,%ecx
c01049ed:	c1 e1 0c             	shl    $0xc,%ecx
c01049f0:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c01049f3:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01049f6:	29 d7                	sub    %edx,%edi
c01049f8:	89 fa                	mov    %edi,%edx
c01049fa:	89 44 24 14          	mov    %eax,0x14(%esp)
c01049fe:	89 74 24 10          	mov    %esi,0x10(%esp)
c0104a02:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0104a06:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0104a0a:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104a0e:	c7 04 24 f4 97 10 c0 	movl   $0xc01097f4,(%esp)
c0104a15:	e8 af b8 ff ff       	call   c01002c9 <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0104a1a:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
c0104a1f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104a22:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104a25:	89 d3                	mov    %edx,%ebx
c0104a27:	c1 e3 0a             	shl    $0xa,%ebx
c0104a2a:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104a2d:	89 d1                	mov    %edx,%ecx
c0104a2f:	c1 e1 0a             	shl    $0xa,%ecx
c0104a32:	8d 55 d4             	lea    -0x2c(%ebp),%edx
c0104a35:	89 54 24 14          	mov    %edx,0x14(%esp)
c0104a39:	8d 55 d8             	lea    -0x28(%ebp),%edx
c0104a3c:	89 54 24 10          	mov    %edx,0x10(%esp)
c0104a40:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0104a44:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104a48:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0104a4c:	89 0c 24             	mov    %ecx,(%esp)
c0104a4f:	e8 38 fe ff ff       	call   c010488c <get_pgtable_items>
c0104a54:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104a57:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0104a5b:	0f 85 65 ff ff ff    	jne    c01049c6 <print_pgdir+0x84>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0104a61:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
c0104a66:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104a69:	8d 55 dc             	lea    -0x24(%ebp),%edx
c0104a6c:	89 54 24 14          	mov    %edx,0x14(%esp)
c0104a70:	8d 55 e0             	lea    -0x20(%ebp),%edx
c0104a73:	89 54 24 10          	mov    %edx,0x10(%esp)
c0104a77:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0104a7b:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104a7f:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c0104a86:	00 
c0104a87:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0104a8e:	e8 f9 fd ff ff       	call   c010488c <get_pgtable_items>
c0104a93:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104a96:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0104a9a:	0f 85 c7 fe ff ff    	jne    c0104967 <print_pgdir+0x25>
        }
    }
    cprintf("--------------------- END ---------------------\n");
c0104aa0:	c7 04 24 18 98 10 c0 	movl   $0xc0109818,(%esp)
c0104aa7:	e8 1d b8 ff ff       	call   c01002c9 <cprintf>
}
c0104aac:	90                   	nop
c0104aad:	83 c4 4c             	add    $0x4c,%esp
c0104ab0:	5b                   	pop    %ebx
c0104ab1:	5e                   	pop    %esi
c0104ab2:	5f                   	pop    %edi
c0104ab3:	5d                   	pop    %ebp
c0104ab4:	c3                   	ret    

c0104ab5 <kmalloc>:

void *
kmalloc(size_t n) {
c0104ab5:	f3 0f 1e fb          	endbr32 
c0104ab9:	55                   	push   %ebp
c0104aba:	89 e5                	mov    %esp,%ebp
c0104abc:	83 ec 28             	sub    $0x28,%esp
    void * ptr=NULL;
c0104abf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    struct Page *base=NULL;
c0104ac6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    assert(n > 0 && n < 1024*0124);
c0104acd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104ad1:	74 09                	je     c0104adc <kmalloc+0x27>
c0104ad3:	81 7d 08 ff 4f 01 00 	cmpl   $0x14fff,0x8(%ebp)
c0104ada:	76 24                	jbe    c0104b00 <kmalloc+0x4b>
c0104adc:	c7 44 24 0c 49 98 10 	movl   $0xc0109849,0xc(%esp)
c0104ae3:	c0 
c0104ae4:	c7 44 24 08 ed 92 10 	movl   $0xc01092ed,0x8(%esp)
c0104aeb:	c0 
c0104aec:	c7 44 24 04 87 02 00 	movl   $0x287,0x4(%esp)
c0104af3:	00 
c0104af4:	c7 04 24 c8 92 10 c0 	movl   $0xc01092c8,(%esp)
c0104afb:	e8 35 b9 ff ff       	call   c0100435 <__panic>
    int num_pages=(n+PGSIZE-1)/PGSIZE;
c0104b00:	8b 45 08             	mov    0x8(%ebp),%eax
c0104b03:	05 ff 0f 00 00       	add    $0xfff,%eax
c0104b08:	c1 e8 0c             	shr    $0xc,%eax
c0104b0b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    base = alloc_pages(num_pages);
c0104b0e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104b11:	89 04 24             	mov    %eax,(%esp)
c0104b14:	e8 6e e9 ff ff       	call   c0103487 <alloc_pages>
c0104b19:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(base != NULL);
c0104b1c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104b20:	75 24                	jne    c0104b46 <kmalloc+0x91>
c0104b22:	c7 44 24 0c 60 98 10 	movl   $0xc0109860,0xc(%esp)
c0104b29:	c0 
c0104b2a:	c7 44 24 08 ed 92 10 	movl   $0xc01092ed,0x8(%esp)
c0104b31:	c0 
c0104b32:	c7 44 24 04 8a 02 00 	movl   $0x28a,0x4(%esp)
c0104b39:	00 
c0104b3a:	c7 04 24 c8 92 10 c0 	movl   $0xc01092c8,(%esp)
c0104b41:	e8 ef b8 ff ff       	call   c0100435 <__panic>
    ptr=page2kva(base);
c0104b46:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b49:	89 04 24             	mov    %eax,(%esp)
c0104b4c:	e8 3a e6 ff ff       	call   c010318b <page2kva>
c0104b51:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return ptr;
c0104b54:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0104b57:	c9                   	leave  
c0104b58:	c3                   	ret    

c0104b59 <kfree>:

void 
kfree(void *ptr, size_t n) {
c0104b59:	f3 0f 1e fb          	endbr32 
c0104b5d:	55                   	push   %ebp
c0104b5e:	89 e5                	mov    %esp,%ebp
c0104b60:	83 ec 28             	sub    $0x28,%esp
    assert(n > 0 && n < 1024*0124);
c0104b63:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0104b67:	74 09                	je     c0104b72 <kfree+0x19>
c0104b69:	81 7d 0c ff 4f 01 00 	cmpl   $0x14fff,0xc(%ebp)
c0104b70:	76 24                	jbe    c0104b96 <kfree+0x3d>
c0104b72:	c7 44 24 0c 49 98 10 	movl   $0xc0109849,0xc(%esp)
c0104b79:	c0 
c0104b7a:	c7 44 24 08 ed 92 10 	movl   $0xc01092ed,0x8(%esp)
c0104b81:	c0 
c0104b82:	c7 44 24 04 91 02 00 	movl   $0x291,0x4(%esp)
c0104b89:	00 
c0104b8a:	c7 04 24 c8 92 10 c0 	movl   $0xc01092c8,(%esp)
c0104b91:	e8 9f b8 ff ff       	call   c0100435 <__panic>
    assert(ptr != NULL);
c0104b96:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104b9a:	75 24                	jne    c0104bc0 <kfree+0x67>
c0104b9c:	c7 44 24 0c 6d 98 10 	movl   $0xc010986d,0xc(%esp)
c0104ba3:	c0 
c0104ba4:	c7 44 24 08 ed 92 10 	movl   $0xc01092ed,0x8(%esp)
c0104bab:	c0 
c0104bac:	c7 44 24 04 92 02 00 	movl   $0x292,0x4(%esp)
c0104bb3:	00 
c0104bb4:	c7 04 24 c8 92 10 c0 	movl   $0xc01092c8,(%esp)
c0104bbb:	e8 75 b8 ff ff       	call   c0100435 <__panic>
    struct Page *base=NULL;
c0104bc0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    int num_pages=(n+PGSIZE-1)/PGSIZE;
c0104bc7:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104bca:	05 ff 0f 00 00       	add    $0xfff,%eax
c0104bcf:	c1 e8 0c             	shr    $0xc,%eax
c0104bd2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    base = kva2page(ptr);
c0104bd5:	8b 45 08             	mov    0x8(%ebp),%eax
c0104bd8:	89 04 24             	mov    %eax,(%esp)
c0104bdb:	e8 ff e5 ff ff       	call   c01031df <kva2page>
c0104be0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    free_pages(base, num_pages);
c0104be3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104be6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104bea:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104bed:	89 04 24             	mov    %eax,(%esp)
c0104bf0:	e8 01 e9 ff ff       	call   c01034f6 <free_pages>
}
c0104bf5:	90                   	nop
c0104bf6:	c9                   	leave  
c0104bf7:	c3                   	ret    

c0104bf8 <pa2page>:
pa2page(uintptr_t pa) {
c0104bf8:	55                   	push   %ebp
c0104bf9:	89 e5                	mov    %esp,%ebp
c0104bfb:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0104bfe:	8b 45 08             	mov    0x8(%ebp),%eax
c0104c01:	c1 e8 0c             	shr    $0xc,%eax
c0104c04:	89 c2                	mov    %eax,%edx
c0104c06:	a1 80 5f 12 c0       	mov    0xc0125f80,%eax
c0104c0b:	39 c2                	cmp    %eax,%edx
c0104c0d:	72 1c                	jb     c0104c2b <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0104c0f:	c7 44 24 08 7c 98 10 	movl   $0xc010987c,0x8(%esp)
c0104c16:	c0 
c0104c17:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
c0104c1e:	00 
c0104c1f:	c7 04 24 9b 98 10 c0 	movl   $0xc010989b,(%esp)
c0104c26:	e8 0a b8 ff ff       	call   c0100435 <__panic>
    return &pages[PPN(pa)];
c0104c2b:	a1 28 60 12 c0       	mov    0xc0126028,%eax
c0104c30:	8b 55 08             	mov    0x8(%ebp),%edx
c0104c33:	c1 ea 0c             	shr    $0xc,%edx
c0104c36:	c1 e2 05             	shl    $0x5,%edx
c0104c39:	01 d0                	add    %edx,%eax
}
c0104c3b:	c9                   	leave  
c0104c3c:	c3                   	ret    

c0104c3d <pde2page>:
pde2page(pde_t pde) {
c0104c3d:	55                   	push   %ebp
c0104c3e:	89 e5                	mov    %esp,%ebp
c0104c40:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0104c43:	8b 45 08             	mov    0x8(%ebp),%eax
c0104c46:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104c4b:	89 04 24             	mov    %eax,(%esp)
c0104c4e:	e8 a5 ff ff ff       	call   c0104bf8 <pa2page>
}
c0104c53:	c9                   	leave  
c0104c54:	c3                   	ret    

c0104c55 <mm_create>:
static void check_vma_struct(void);
static void check_pgfault(void);

// mm_create -  alloc a mm_struct & initialize it.
struct mm_struct *
mm_create(void) {
c0104c55:	f3 0f 1e fb          	endbr32 
c0104c59:	55                   	push   %ebp
c0104c5a:	89 e5                	mov    %esp,%ebp
c0104c5c:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
c0104c5f:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
c0104c66:	e8 4a fe ff ff       	call   c0104ab5 <kmalloc>
c0104c6b:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (mm != NULL) {
c0104c6e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104c72:	74 59                	je     c0104ccd <mm_create+0x78>
        list_init(&(mm->mmap_list));
c0104c74:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c77:	89 45 f0             	mov    %eax,-0x10(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0104c7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c7d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104c80:	89 50 04             	mov    %edx,0x4(%eax)
c0104c83:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c86:	8b 50 04             	mov    0x4(%eax),%edx
c0104c89:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c8c:	89 10                	mov    %edx,(%eax)
}
c0104c8e:	90                   	nop
        mm->mmap_cache = NULL;
c0104c8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c92:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        mm->pgdir = NULL;
c0104c99:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c9c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        mm->map_count = 0;
c0104ca3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ca6:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)

        if (swap_init_ok) swap_init_mm(mm);
c0104cad:	a1 10 60 12 c0       	mov    0xc0126010,%eax
c0104cb2:	85 c0                	test   %eax,%eax
c0104cb4:	74 0d                	je     c0104cc3 <mm_create+0x6e>
c0104cb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104cb9:	89 04 24             	mov    %eax,(%esp)
c0104cbc:	e8 e7 0c 00 00       	call   c01059a8 <swap_init_mm>
c0104cc1:	eb 0a                	jmp    c0104ccd <mm_create+0x78>
        else mm->sm_priv = NULL;
c0104cc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104cc6:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
    }
    return mm;
c0104ccd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0104cd0:	c9                   	leave  
c0104cd1:	c3                   	ret    

c0104cd2 <vma_create>:

// vma_create - alloc a vma_struct & initialize it. (addr range: vm_start~vm_end)
struct vma_struct *
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
c0104cd2:	f3 0f 1e fb          	endbr32 
c0104cd6:	55                   	push   %ebp
c0104cd7:	89 e5                	mov    %esp,%ebp
c0104cd9:	83 ec 28             	sub    $0x28,%esp
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
c0104cdc:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
c0104ce3:	e8 cd fd ff ff       	call   c0104ab5 <kmalloc>
c0104ce8:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (vma != NULL) {
c0104ceb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104cef:	74 1b                	je     c0104d0c <vma_create+0x3a>
        vma->vm_start = vm_start;
c0104cf1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104cf4:	8b 55 08             	mov    0x8(%ebp),%edx
c0104cf7:	89 50 04             	mov    %edx,0x4(%eax)
        vma->vm_end = vm_end;
c0104cfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104cfd:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104d00:	89 50 08             	mov    %edx,0x8(%eax)
        vma->vm_flags = vm_flags;
c0104d03:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d06:	8b 55 10             	mov    0x10(%ebp),%edx
c0104d09:	89 50 0c             	mov    %edx,0xc(%eax)
    }
    return vma;
c0104d0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0104d0f:	c9                   	leave  
c0104d10:	c3                   	ret    

c0104d11 <find_vma>:


// find_vma - find a vma  (vma->vm_start <= addr <= vma_vm_end)
struct vma_struct *
find_vma(struct mm_struct *mm, uintptr_t addr) {
c0104d11:	f3 0f 1e fb          	endbr32 
c0104d15:	55                   	push   %ebp
c0104d16:	89 e5                	mov    %esp,%ebp
c0104d18:	83 ec 20             	sub    $0x20,%esp
    struct vma_struct *vma = NULL;
c0104d1b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    if (mm != NULL) {
c0104d22:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104d26:	0f 84 95 00 00 00    	je     c0104dc1 <find_vma+0xb0>
        vma = mm->mmap_cache;
c0104d2c:	8b 45 08             	mov    0x8(%ebp),%eax
c0104d2f:	8b 40 08             	mov    0x8(%eax),%eax
c0104d32:	89 45 fc             	mov    %eax,-0x4(%ebp)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
c0104d35:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0104d39:	74 16                	je     c0104d51 <find_vma+0x40>
c0104d3b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104d3e:	8b 40 04             	mov    0x4(%eax),%eax
c0104d41:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0104d44:	72 0b                	jb     c0104d51 <find_vma+0x40>
c0104d46:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104d49:	8b 40 08             	mov    0x8(%eax),%eax
c0104d4c:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0104d4f:	72 61                	jb     c0104db2 <find_vma+0xa1>
                bool found = 0;
c0104d51:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
                list_entry_t *list = &(mm->mmap_list), *le = list;
c0104d58:	8b 45 08             	mov    0x8(%ebp),%eax
c0104d5b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104d5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d61:	89 45 f4             	mov    %eax,-0xc(%ebp)
                while ((le = list_next(le)) != list) {
c0104d64:	eb 28                	jmp    c0104d8e <find_vma+0x7d>
                    vma = le2vma(le, list_link);
c0104d66:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d69:	83 e8 10             	sub    $0x10,%eax
c0104d6c:	89 45 fc             	mov    %eax,-0x4(%ebp)
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
c0104d6f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104d72:	8b 40 04             	mov    0x4(%eax),%eax
c0104d75:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0104d78:	72 14                	jb     c0104d8e <find_vma+0x7d>
c0104d7a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104d7d:	8b 40 08             	mov    0x8(%eax),%eax
c0104d80:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0104d83:	73 09                	jae    c0104d8e <find_vma+0x7d>
                        found = 1;
c0104d85:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%ebp)
                        break;
c0104d8c:	eb 17                	jmp    c0104da5 <find_vma+0x94>
c0104d8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d91:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0104d94:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104d97:	8b 40 04             	mov    0x4(%eax),%eax
                while ((le = list_next(le)) != list) {
c0104d9a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104d9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104da0:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0104da3:	75 c1                	jne    c0104d66 <find_vma+0x55>
                    }
                }
                if (!found) {
c0104da5:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
c0104da9:	75 07                	jne    c0104db2 <find_vma+0xa1>
                    vma = NULL;
c0104dab:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
                }
        }
        if (vma != NULL) {
c0104db2:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0104db6:	74 09                	je     c0104dc1 <find_vma+0xb0>
            mm->mmap_cache = vma;
c0104db8:	8b 45 08             	mov    0x8(%ebp),%eax
c0104dbb:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0104dbe:	89 50 08             	mov    %edx,0x8(%eax)
        }
    }
    return vma;
c0104dc1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0104dc4:	c9                   	leave  
c0104dc5:	c3                   	ret    

c0104dc6 <check_vma_overlap>:


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
c0104dc6:	55                   	push   %ebp
c0104dc7:	89 e5                	mov    %esp,%ebp
c0104dc9:	83 ec 18             	sub    $0x18,%esp
    assert(prev->vm_start < prev->vm_end);
c0104dcc:	8b 45 08             	mov    0x8(%ebp),%eax
c0104dcf:	8b 50 04             	mov    0x4(%eax),%edx
c0104dd2:	8b 45 08             	mov    0x8(%ebp),%eax
c0104dd5:	8b 40 08             	mov    0x8(%eax),%eax
c0104dd8:	39 c2                	cmp    %eax,%edx
c0104dda:	72 24                	jb     c0104e00 <check_vma_overlap+0x3a>
c0104ddc:	c7 44 24 0c a9 98 10 	movl   $0xc01098a9,0xc(%esp)
c0104de3:	c0 
c0104de4:	c7 44 24 08 c7 98 10 	movl   $0xc01098c7,0x8(%esp)
c0104deb:	c0 
c0104dec:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
c0104df3:	00 
c0104df4:	c7 04 24 dc 98 10 c0 	movl   $0xc01098dc,(%esp)
c0104dfb:	e8 35 b6 ff ff       	call   c0100435 <__panic>
    assert(prev->vm_end <= next->vm_start);
c0104e00:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e03:	8b 50 08             	mov    0x8(%eax),%edx
c0104e06:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104e09:	8b 40 04             	mov    0x4(%eax),%eax
c0104e0c:	39 c2                	cmp    %eax,%edx
c0104e0e:	76 24                	jbe    c0104e34 <check_vma_overlap+0x6e>
c0104e10:	c7 44 24 0c ec 98 10 	movl   $0xc01098ec,0xc(%esp)
c0104e17:	c0 
c0104e18:	c7 44 24 08 c7 98 10 	movl   $0xc01098c7,0x8(%esp)
c0104e1f:	c0 
c0104e20:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
c0104e27:	00 
c0104e28:	c7 04 24 dc 98 10 c0 	movl   $0xc01098dc,(%esp)
c0104e2f:	e8 01 b6 ff ff       	call   c0100435 <__panic>
    assert(next->vm_start < next->vm_end);
c0104e34:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104e37:	8b 50 04             	mov    0x4(%eax),%edx
c0104e3a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104e3d:	8b 40 08             	mov    0x8(%eax),%eax
c0104e40:	39 c2                	cmp    %eax,%edx
c0104e42:	72 24                	jb     c0104e68 <check_vma_overlap+0xa2>
c0104e44:	c7 44 24 0c 0b 99 10 	movl   $0xc010990b,0xc(%esp)
c0104e4b:	c0 
c0104e4c:	c7 44 24 08 c7 98 10 	movl   $0xc01098c7,0x8(%esp)
c0104e53:	c0 
c0104e54:	c7 44 24 04 69 00 00 	movl   $0x69,0x4(%esp)
c0104e5b:	00 
c0104e5c:	c7 04 24 dc 98 10 c0 	movl   $0xc01098dc,(%esp)
c0104e63:	e8 cd b5 ff ff       	call   c0100435 <__panic>
}
c0104e68:	90                   	nop
c0104e69:	c9                   	leave  
c0104e6a:	c3                   	ret    

c0104e6b <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
c0104e6b:	f3 0f 1e fb          	endbr32 
c0104e6f:	55                   	push   %ebp
c0104e70:	89 e5                	mov    %esp,%ebp
c0104e72:	83 ec 48             	sub    $0x48,%esp
    assert(vma->vm_start < vma->vm_end);
c0104e75:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104e78:	8b 50 04             	mov    0x4(%eax),%edx
c0104e7b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104e7e:	8b 40 08             	mov    0x8(%eax),%eax
c0104e81:	39 c2                	cmp    %eax,%edx
c0104e83:	72 24                	jb     c0104ea9 <insert_vma_struct+0x3e>
c0104e85:	c7 44 24 0c 29 99 10 	movl   $0xc0109929,0xc(%esp)
c0104e8c:	c0 
c0104e8d:	c7 44 24 08 c7 98 10 	movl   $0xc01098c7,0x8(%esp)
c0104e94:	c0 
c0104e95:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c0104e9c:	00 
c0104e9d:	c7 04 24 dc 98 10 c0 	movl   $0xc01098dc,(%esp)
c0104ea4:	e8 8c b5 ff ff       	call   c0100435 <__panic>
    list_entry_t *list = &(mm->mmap_list);
c0104ea9:	8b 45 08             	mov    0x8(%ebp),%eax
c0104eac:	89 45 ec             	mov    %eax,-0x14(%ebp)
    list_entry_t *le_prev = list, *le_next;
c0104eaf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104eb2:	89 45 f4             	mov    %eax,-0xc(%ebp)

        list_entry_t *le = list;
c0104eb5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104eb8:	89 45 f0             	mov    %eax,-0x10(%ebp)
        while ((le = list_next(le)) != list) {
c0104ebb:	eb 1f                	jmp    c0104edc <insert_vma_struct+0x71>
            struct vma_struct *mmap_prev = le2vma(le, list_link);
c0104ebd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104ec0:	83 e8 10             	sub    $0x10,%eax
c0104ec3:	89 45 e8             	mov    %eax,-0x18(%ebp)
            if (mmap_prev->vm_start > vma->vm_start) {
c0104ec6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104ec9:	8b 50 04             	mov    0x4(%eax),%edx
c0104ecc:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104ecf:	8b 40 04             	mov    0x4(%eax),%eax
c0104ed2:	39 c2                	cmp    %eax,%edx
c0104ed4:	77 1f                	ja     c0104ef5 <insert_vma_struct+0x8a>
                break;
            }
            le_prev = le;
c0104ed6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104ed9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104edc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104edf:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0104ee2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104ee5:	8b 40 04             	mov    0x4(%eax),%eax
        while ((le = list_next(le)) != list) {
c0104ee8:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104eeb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104eee:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0104ef1:	75 ca                	jne    c0104ebd <insert_vma_struct+0x52>
c0104ef3:	eb 01                	jmp    c0104ef6 <insert_vma_struct+0x8b>
                break;
c0104ef5:	90                   	nop
c0104ef6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ef9:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0104efc:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104eff:	8b 40 04             	mov    0x4(%eax),%eax
        }

    le_next = list_next(le_prev);
c0104f02:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    /* check overlap */
    if (le_prev != list) {
c0104f05:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f08:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0104f0b:	74 15                	je     c0104f22 <insert_vma_struct+0xb7>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
c0104f0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f10:	8d 50 f0             	lea    -0x10(%eax),%edx
c0104f13:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104f16:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104f1a:	89 14 24             	mov    %edx,(%esp)
c0104f1d:	e8 a4 fe ff ff       	call   c0104dc6 <check_vma_overlap>
    }
    if (le_next != list) {
c0104f22:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104f25:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0104f28:	74 15                	je     c0104f3f <insert_vma_struct+0xd4>
        check_vma_overlap(vma, le2vma(le_next, list_link));
c0104f2a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104f2d:	83 e8 10             	sub    $0x10,%eax
c0104f30:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104f34:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104f37:	89 04 24             	mov    %eax,(%esp)
c0104f3a:	e8 87 fe ff ff       	call   c0104dc6 <check_vma_overlap>
    }

    vma->vm_mm = mm;
c0104f3f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104f42:	8b 55 08             	mov    0x8(%ebp),%edx
c0104f45:	89 10                	mov    %edx,(%eax)
    list_add_after(le_prev, &(vma->list_link));
c0104f47:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104f4a:	8d 50 10             	lea    0x10(%eax),%edx
c0104f4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f50:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0104f53:	89 55 d4             	mov    %edx,-0x2c(%ebp)
    __list_add(elm, listelm, listelm->next);
c0104f56:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104f59:	8b 40 04             	mov    0x4(%eax),%eax
c0104f5c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104f5f:	89 55 d0             	mov    %edx,-0x30(%ebp)
c0104f62:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104f65:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0104f68:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0104f6b:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104f6e:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104f71:	89 10                	mov    %edx,(%eax)
c0104f73:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104f76:	8b 10                	mov    (%eax),%edx
c0104f78:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104f7b:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0104f7e:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104f81:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0104f84:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0104f87:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104f8a:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0104f8d:	89 10                	mov    %edx,(%eax)
}
c0104f8f:	90                   	nop
}
c0104f90:	90                   	nop

    mm->map_count ++;
c0104f91:	8b 45 08             	mov    0x8(%ebp),%eax
c0104f94:	8b 40 10             	mov    0x10(%eax),%eax
c0104f97:	8d 50 01             	lea    0x1(%eax),%edx
c0104f9a:	8b 45 08             	mov    0x8(%ebp),%eax
c0104f9d:	89 50 10             	mov    %edx,0x10(%eax)
}
c0104fa0:	90                   	nop
c0104fa1:	c9                   	leave  
c0104fa2:	c3                   	ret    

c0104fa3 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
c0104fa3:	f3 0f 1e fb          	endbr32 
c0104fa7:	55                   	push   %ebp
c0104fa8:	89 e5                	mov    %esp,%ebp
c0104faa:	83 ec 38             	sub    $0x38,%esp

    list_entry_t *list = &(mm->mmap_list), *le;
c0104fad:	8b 45 08             	mov    0x8(%ebp),%eax
c0104fb0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_next(list)) != list) {
c0104fb3:	eb 40                	jmp    c0104ff5 <mm_destroy+0x52>
c0104fb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104fb8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    __list_del(listelm->prev, listelm->next);
c0104fbb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104fbe:	8b 40 04             	mov    0x4(%eax),%eax
c0104fc1:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104fc4:	8b 12                	mov    (%edx),%edx
c0104fc6:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0104fc9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0104fcc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104fcf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104fd2:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0104fd5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104fd8:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0104fdb:	89 10                	mov    %edx,(%eax)
}
c0104fdd:	90                   	nop
}
c0104fde:	90                   	nop
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
c0104fdf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104fe2:	83 e8 10             	sub    $0x10,%eax
c0104fe5:	c7 44 24 04 18 00 00 	movl   $0x18,0x4(%esp)
c0104fec:	00 
c0104fed:	89 04 24             	mov    %eax,(%esp)
c0104ff0:	e8 64 fb ff ff       	call   c0104b59 <kfree>
c0104ff5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ff8:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return listelm->next;
c0104ffb:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104ffe:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(list)) != list) {
c0105001:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105004:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105007:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010500a:	75 a9                	jne    c0104fb5 <mm_destroy+0x12>
    }
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
c010500c:	c7 44 24 04 18 00 00 	movl   $0x18,0x4(%esp)
c0105013:	00 
c0105014:	8b 45 08             	mov    0x8(%ebp),%eax
c0105017:	89 04 24             	mov    %eax,(%esp)
c010501a:	e8 3a fb ff ff       	call   c0104b59 <kfree>
    mm=NULL;
c010501f:	c7 45 08 00 00 00 00 	movl   $0x0,0x8(%ebp)
}
c0105026:	90                   	nop
c0105027:	c9                   	leave  
c0105028:	c3                   	ret    

c0105029 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
c0105029:	f3 0f 1e fb          	endbr32 
c010502d:	55                   	push   %ebp
c010502e:	89 e5                	mov    %esp,%ebp
c0105030:	83 ec 08             	sub    $0x8,%esp
    check_vmm();
c0105033:	e8 03 00 00 00       	call   c010503b <check_vmm>
}
c0105038:	90                   	nop
c0105039:	c9                   	leave  
c010503a:	c3                   	ret    

c010503b <check_vmm>:

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
c010503b:	f3 0f 1e fb          	endbr32 
c010503f:	55                   	push   %ebp
c0105040:	89 e5                	mov    %esp,%ebp
c0105042:	83 ec 28             	sub    $0x28,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0105045:	e8 e3 e4 ff ff       	call   c010352d <nr_free_pages>
c010504a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    
    check_vma_struct();
c010504d:	e8 42 00 00 00       	call   c0105094 <check_vma_struct>
    check_pgfault();
c0105052:	e8 01 05 00 00       	call   c0105558 <check_pgfault>

    assert(nr_free_pages_store == nr_free_pages());
c0105057:	e8 d1 e4 ff ff       	call   c010352d <nr_free_pages>
c010505c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010505f:	74 24                	je     c0105085 <check_vmm+0x4a>
c0105061:	c7 44 24 0c 48 99 10 	movl   $0xc0109948,0xc(%esp)
c0105068:	c0 
c0105069:	c7 44 24 08 c7 98 10 	movl   $0xc01098c7,0x8(%esp)
c0105070:	c0 
c0105071:	c7 44 24 04 a9 00 00 	movl   $0xa9,0x4(%esp)
c0105078:	00 
c0105079:	c7 04 24 dc 98 10 c0 	movl   $0xc01098dc,(%esp)
c0105080:	e8 b0 b3 ff ff       	call   c0100435 <__panic>

    cprintf("check_vmm() succeeded.\n");
c0105085:	c7 04 24 6f 99 10 c0 	movl   $0xc010996f,(%esp)
c010508c:	e8 38 b2 ff ff       	call   c01002c9 <cprintf>
}
c0105091:	90                   	nop
c0105092:	c9                   	leave  
c0105093:	c3                   	ret    

c0105094 <check_vma_struct>:

static void
check_vma_struct(void) {
c0105094:	f3 0f 1e fb          	endbr32 
c0105098:	55                   	push   %ebp
c0105099:	89 e5                	mov    %esp,%ebp
c010509b:	83 ec 68             	sub    $0x68,%esp
    size_t nr_free_pages_store = nr_free_pages();
c010509e:	e8 8a e4 ff ff       	call   c010352d <nr_free_pages>
c01050a3:	89 45 ec             	mov    %eax,-0x14(%ebp)

    struct mm_struct *mm = mm_create();
c01050a6:	e8 aa fb ff ff       	call   c0104c55 <mm_create>
c01050ab:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(mm != NULL);
c01050ae:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01050b2:	75 24                	jne    c01050d8 <check_vma_struct+0x44>
c01050b4:	c7 44 24 0c 87 99 10 	movl   $0xc0109987,0xc(%esp)
c01050bb:	c0 
c01050bc:	c7 44 24 08 c7 98 10 	movl   $0xc01098c7,0x8(%esp)
c01050c3:	c0 
c01050c4:	c7 44 24 04 b3 00 00 	movl   $0xb3,0x4(%esp)
c01050cb:	00 
c01050cc:	c7 04 24 dc 98 10 c0 	movl   $0xc01098dc,(%esp)
c01050d3:	e8 5d b3 ff ff       	call   c0100435 <__panic>

    int step1 = 10, step2 = step1 * 10;
c01050d8:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%ebp)
c01050df:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01050e2:	89 d0                	mov    %edx,%eax
c01050e4:	c1 e0 02             	shl    $0x2,%eax
c01050e7:	01 d0                	add    %edx,%eax
c01050e9:	01 c0                	add    %eax,%eax
c01050eb:	89 45 e0             	mov    %eax,-0x20(%ebp)

    int i;
    for (i = step1; i >= 1; i --) {
c01050ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01050f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01050f4:	eb 6f                	jmp    c0105165 <check_vma_struct+0xd1>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c01050f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01050f9:	89 d0                	mov    %edx,%eax
c01050fb:	c1 e0 02             	shl    $0x2,%eax
c01050fe:	01 d0                	add    %edx,%eax
c0105100:	83 c0 02             	add    $0x2,%eax
c0105103:	89 c1                	mov    %eax,%ecx
c0105105:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105108:	89 d0                	mov    %edx,%eax
c010510a:	c1 e0 02             	shl    $0x2,%eax
c010510d:	01 d0                	add    %edx,%eax
c010510f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105116:	00 
c0105117:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c010511b:	89 04 24             	mov    %eax,(%esp)
c010511e:	e8 af fb ff ff       	call   c0104cd2 <vma_create>
c0105123:	89 45 bc             	mov    %eax,-0x44(%ebp)
        assert(vma != NULL);
c0105126:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c010512a:	75 24                	jne    c0105150 <check_vma_struct+0xbc>
c010512c:	c7 44 24 0c 92 99 10 	movl   $0xc0109992,0xc(%esp)
c0105133:	c0 
c0105134:	c7 44 24 08 c7 98 10 	movl   $0xc01098c7,0x8(%esp)
c010513b:	c0 
c010513c:	c7 44 24 04 ba 00 00 	movl   $0xba,0x4(%esp)
c0105143:	00 
c0105144:	c7 04 24 dc 98 10 c0 	movl   $0xc01098dc,(%esp)
c010514b:	e8 e5 b2 ff ff       	call   c0100435 <__panic>
        insert_vma_struct(mm, vma);
c0105150:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0105153:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105157:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010515a:	89 04 24             	mov    %eax,(%esp)
c010515d:	e8 09 fd ff ff       	call   c0104e6b <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
c0105162:	ff 4d f4             	decl   -0xc(%ebp)
c0105165:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105169:	7f 8b                	jg     c01050f6 <check_vma_struct+0x62>
    }

    for (i = step1 + 1; i <= step2; i ++) {
c010516b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010516e:	40                   	inc    %eax
c010516f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105172:	eb 6f                	jmp    c01051e3 <check_vma_struct+0x14f>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c0105174:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105177:	89 d0                	mov    %edx,%eax
c0105179:	c1 e0 02             	shl    $0x2,%eax
c010517c:	01 d0                	add    %edx,%eax
c010517e:	83 c0 02             	add    $0x2,%eax
c0105181:	89 c1                	mov    %eax,%ecx
c0105183:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105186:	89 d0                	mov    %edx,%eax
c0105188:	c1 e0 02             	shl    $0x2,%eax
c010518b:	01 d0                	add    %edx,%eax
c010518d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105194:	00 
c0105195:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0105199:	89 04 24             	mov    %eax,(%esp)
c010519c:	e8 31 fb ff ff       	call   c0104cd2 <vma_create>
c01051a1:	89 45 c0             	mov    %eax,-0x40(%ebp)
        assert(vma != NULL);
c01051a4:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
c01051a8:	75 24                	jne    c01051ce <check_vma_struct+0x13a>
c01051aa:	c7 44 24 0c 92 99 10 	movl   $0xc0109992,0xc(%esp)
c01051b1:	c0 
c01051b2:	c7 44 24 08 c7 98 10 	movl   $0xc01098c7,0x8(%esp)
c01051b9:	c0 
c01051ba:	c7 44 24 04 c0 00 00 	movl   $0xc0,0x4(%esp)
c01051c1:	00 
c01051c2:	c7 04 24 dc 98 10 c0 	movl   $0xc01098dc,(%esp)
c01051c9:	e8 67 b2 ff ff       	call   c0100435 <__panic>
        insert_vma_struct(mm, vma);
c01051ce:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01051d1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01051d5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01051d8:	89 04 24             	mov    %eax,(%esp)
c01051db:	e8 8b fc ff ff       	call   c0104e6b <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
c01051e0:	ff 45 f4             	incl   -0xc(%ebp)
c01051e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01051e6:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01051e9:	7e 89                	jle    c0105174 <check_vma_struct+0xe0>
    }

    list_entry_t *le = list_next(&(mm->mmap_list));
c01051eb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01051ee:	89 45 b8             	mov    %eax,-0x48(%ebp)
c01051f1:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01051f4:	8b 40 04             	mov    0x4(%eax),%eax
c01051f7:	89 45 f0             	mov    %eax,-0x10(%ebp)

    for (i = 1; i <= step2; i ++) {
c01051fa:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
c0105201:	e9 96 00 00 00       	jmp    c010529c <check_vma_struct+0x208>
        assert(le != &(mm->mmap_list));
c0105206:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105209:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010520c:	75 24                	jne    c0105232 <check_vma_struct+0x19e>
c010520e:	c7 44 24 0c 9e 99 10 	movl   $0xc010999e,0xc(%esp)
c0105215:	c0 
c0105216:	c7 44 24 08 c7 98 10 	movl   $0xc01098c7,0x8(%esp)
c010521d:	c0 
c010521e:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
c0105225:	00 
c0105226:	c7 04 24 dc 98 10 c0 	movl   $0xc01098dc,(%esp)
c010522d:	e8 03 b2 ff ff       	call   c0100435 <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
c0105232:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105235:	83 e8 10             	sub    $0x10,%eax
c0105238:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
c010523b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010523e:	8b 48 04             	mov    0x4(%eax),%ecx
c0105241:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105244:	89 d0                	mov    %edx,%eax
c0105246:	c1 e0 02             	shl    $0x2,%eax
c0105249:	01 d0                	add    %edx,%eax
c010524b:	39 c1                	cmp    %eax,%ecx
c010524d:	75 17                	jne    c0105266 <check_vma_struct+0x1d2>
c010524f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105252:	8b 48 08             	mov    0x8(%eax),%ecx
c0105255:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105258:	89 d0                	mov    %edx,%eax
c010525a:	c1 e0 02             	shl    $0x2,%eax
c010525d:	01 d0                	add    %edx,%eax
c010525f:	83 c0 02             	add    $0x2,%eax
c0105262:	39 c1                	cmp    %eax,%ecx
c0105264:	74 24                	je     c010528a <check_vma_struct+0x1f6>
c0105266:	c7 44 24 0c b8 99 10 	movl   $0xc01099b8,0xc(%esp)
c010526d:	c0 
c010526e:	c7 44 24 08 c7 98 10 	movl   $0xc01098c7,0x8(%esp)
c0105275:	c0 
c0105276:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
c010527d:	00 
c010527e:	c7 04 24 dc 98 10 c0 	movl   $0xc01098dc,(%esp)
c0105285:	e8 ab b1 ff ff       	call   c0100435 <__panic>
c010528a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010528d:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c0105290:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0105293:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0105296:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for (i = 1; i <= step2; i ++) {
c0105299:	ff 45 f4             	incl   -0xc(%ebp)
c010529c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010529f:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01052a2:	0f 8e 5e ff ff ff    	jle    c0105206 <check_vma_struct+0x172>
    }

    for (i = 5; i <= 5 * step2; i +=5) {
c01052a8:	c7 45 f4 05 00 00 00 	movl   $0x5,-0xc(%ebp)
c01052af:	e9 cb 01 00 00       	jmp    c010547f <check_vma_struct+0x3eb>
        struct vma_struct *vma1 = find_vma(mm, i);
c01052b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01052b7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01052bb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01052be:	89 04 24             	mov    %eax,(%esp)
c01052c1:	e8 4b fa ff ff       	call   c0104d11 <find_vma>
c01052c6:	89 45 d8             	mov    %eax,-0x28(%ebp)
        assert(vma1 != NULL);
c01052c9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c01052cd:	75 24                	jne    c01052f3 <check_vma_struct+0x25f>
c01052cf:	c7 44 24 0c ed 99 10 	movl   $0xc01099ed,0xc(%esp)
c01052d6:	c0 
c01052d7:	c7 44 24 08 c7 98 10 	movl   $0xc01098c7,0x8(%esp)
c01052de:	c0 
c01052df:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
c01052e6:	00 
c01052e7:	c7 04 24 dc 98 10 c0 	movl   $0xc01098dc,(%esp)
c01052ee:	e8 42 b1 ff ff       	call   c0100435 <__panic>
        struct vma_struct *vma2 = find_vma(mm, i+1);
c01052f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01052f6:	40                   	inc    %eax
c01052f7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01052fb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01052fe:	89 04 24             	mov    %eax,(%esp)
c0105301:	e8 0b fa ff ff       	call   c0104d11 <find_vma>
c0105306:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(vma2 != NULL);
c0105309:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
c010530d:	75 24                	jne    c0105333 <check_vma_struct+0x29f>
c010530f:	c7 44 24 0c fa 99 10 	movl   $0xc01099fa,0xc(%esp)
c0105316:	c0 
c0105317:	c7 44 24 08 c7 98 10 	movl   $0xc01098c7,0x8(%esp)
c010531e:	c0 
c010531f:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
c0105326:	00 
c0105327:	c7 04 24 dc 98 10 c0 	movl   $0xc01098dc,(%esp)
c010532e:	e8 02 b1 ff ff       	call   c0100435 <__panic>
        struct vma_struct *vma3 = find_vma(mm, i+2);
c0105333:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105336:	83 c0 02             	add    $0x2,%eax
c0105339:	89 44 24 04          	mov    %eax,0x4(%esp)
c010533d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105340:	89 04 24             	mov    %eax,(%esp)
c0105343:	e8 c9 f9 ff ff       	call   c0104d11 <find_vma>
c0105348:	89 45 d0             	mov    %eax,-0x30(%ebp)
        assert(vma3 == NULL);
c010534b:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c010534f:	74 24                	je     c0105375 <check_vma_struct+0x2e1>
c0105351:	c7 44 24 0c 07 9a 10 	movl   $0xc0109a07,0xc(%esp)
c0105358:	c0 
c0105359:	c7 44 24 08 c7 98 10 	movl   $0xc01098c7,0x8(%esp)
c0105360:	c0 
c0105361:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
c0105368:	00 
c0105369:	c7 04 24 dc 98 10 c0 	movl   $0xc01098dc,(%esp)
c0105370:	e8 c0 b0 ff ff       	call   c0100435 <__panic>
        struct vma_struct *vma4 = find_vma(mm, i+3);
c0105375:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105378:	83 c0 03             	add    $0x3,%eax
c010537b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010537f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105382:	89 04 24             	mov    %eax,(%esp)
c0105385:	e8 87 f9 ff ff       	call   c0104d11 <find_vma>
c010538a:	89 45 cc             	mov    %eax,-0x34(%ebp)
        assert(vma4 == NULL);
c010538d:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0105391:	74 24                	je     c01053b7 <check_vma_struct+0x323>
c0105393:	c7 44 24 0c 14 9a 10 	movl   $0xc0109a14,0xc(%esp)
c010539a:	c0 
c010539b:	c7 44 24 08 c7 98 10 	movl   $0xc01098c7,0x8(%esp)
c01053a2:	c0 
c01053a3:	c7 44 24 04 d5 00 00 	movl   $0xd5,0x4(%esp)
c01053aa:	00 
c01053ab:	c7 04 24 dc 98 10 c0 	movl   $0xc01098dc,(%esp)
c01053b2:	e8 7e b0 ff ff       	call   c0100435 <__panic>
        struct vma_struct *vma5 = find_vma(mm, i+4);
c01053b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01053ba:	83 c0 04             	add    $0x4,%eax
c01053bd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01053c1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01053c4:	89 04 24             	mov    %eax,(%esp)
c01053c7:	e8 45 f9 ff ff       	call   c0104d11 <find_vma>
c01053cc:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(vma5 == NULL);
c01053cf:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c01053d3:	74 24                	je     c01053f9 <check_vma_struct+0x365>
c01053d5:	c7 44 24 0c 21 9a 10 	movl   $0xc0109a21,0xc(%esp)
c01053dc:	c0 
c01053dd:	c7 44 24 08 c7 98 10 	movl   $0xc01098c7,0x8(%esp)
c01053e4:	c0 
c01053e5:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
c01053ec:	00 
c01053ed:	c7 04 24 dc 98 10 c0 	movl   $0xc01098dc,(%esp)
c01053f4:	e8 3c b0 ff ff       	call   c0100435 <__panic>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
c01053f9:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01053fc:	8b 50 04             	mov    0x4(%eax),%edx
c01053ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105402:	39 c2                	cmp    %eax,%edx
c0105404:	75 10                	jne    c0105416 <check_vma_struct+0x382>
c0105406:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105409:	8b 40 08             	mov    0x8(%eax),%eax
c010540c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010540f:	83 c2 02             	add    $0x2,%edx
c0105412:	39 d0                	cmp    %edx,%eax
c0105414:	74 24                	je     c010543a <check_vma_struct+0x3a6>
c0105416:	c7 44 24 0c 30 9a 10 	movl   $0xc0109a30,0xc(%esp)
c010541d:	c0 
c010541e:	c7 44 24 08 c7 98 10 	movl   $0xc01098c7,0x8(%esp)
c0105425:	c0 
c0105426:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
c010542d:	00 
c010542e:	c7 04 24 dc 98 10 c0 	movl   $0xc01098dc,(%esp)
c0105435:	e8 fb af ff ff       	call   c0100435 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
c010543a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010543d:	8b 50 04             	mov    0x4(%eax),%edx
c0105440:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105443:	39 c2                	cmp    %eax,%edx
c0105445:	75 10                	jne    c0105457 <check_vma_struct+0x3c3>
c0105447:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010544a:	8b 40 08             	mov    0x8(%eax),%eax
c010544d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105450:	83 c2 02             	add    $0x2,%edx
c0105453:	39 d0                	cmp    %edx,%eax
c0105455:	74 24                	je     c010547b <check_vma_struct+0x3e7>
c0105457:	c7 44 24 0c 60 9a 10 	movl   $0xc0109a60,0xc(%esp)
c010545e:	c0 
c010545f:	c7 44 24 08 c7 98 10 	movl   $0xc01098c7,0x8(%esp)
c0105466:	c0 
c0105467:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
c010546e:	00 
c010546f:	c7 04 24 dc 98 10 c0 	movl   $0xc01098dc,(%esp)
c0105476:	e8 ba af ff ff       	call   c0100435 <__panic>
    for (i = 5; i <= 5 * step2; i +=5) {
c010547b:	83 45 f4 05          	addl   $0x5,-0xc(%ebp)
c010547f:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105482:	89 d0                	mov    %edx,%eax
c0105484:	c1 e0 02             	shl    $0x2,%eax
c0105487:	01 d0                	add    %edx,%eax
c0105489:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010548c:	0f 8e 22 fe ff ff    	jle    c01052b4 <check_vma_struct+0x220>
    }

    for (i =4; i>=0; i--) {
c0105492:	c7 45 f4 04 00 00 00 	movl   $0x4,-0xc(%ebp)
c0105499:	eb 6f                	jmp    c010550a <check_vma_struct+0x476>
        struct vma_struct *vma_below_5= find_vma(mm,i);
c010549b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010549e:	89 44 24 04          	mov    %eax,0x4(%esp)
c01054a2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01054a5:	89 04 24             	mov    %eax,(%esp)
c01054a8:	e8 64 f8 ff ff       	call   c0104d11 <find_vma>
c01054ad:	89 45 dc             	mov    %eax,-0x24(%ebp)
        if (vma_below_5 != NULL ) {
c01054b0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c01054b4:	74 27                	je     c01054dd <check_vma_struct+0x449>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
c01054b6:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01054b9:	8b 50 08             	mov    0x8(%eax),%edx
c01054bc:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01054bf:	8b 40 04             	mov    0x4(%eax),%eax
c01054c2:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01054c6:	89 44 24 08          	mov    %eax,0x8(%esp)
c01054ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01054cd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01054d1:	c7 04 24 90 9a 10 c0 	movl   $0xc0109a90,(%esp)
c01054d8:	e8 ec ad ff ff       	call   c01002c9 <cprintf>
        }
        assert(vma_below_5 == NULL);
c01054dd:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c01054e1:	74 24                	je     c0105507 <check_vma_struct+0x473>
c01054e3:	c7 44 24 0c b5 9a 10 	movl   $0xc0109ab5,0xc(%esp)
c01054ea:	c0 
c01054eb:	c7 44 24 08 c7 98 10 	movl   $0xc01098c7,0x8(%esp)
c01054f2:	c0 
c01054f3:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
c01054fa:	00 
c01054fb:	c7 04 24 dc 98 10 c0 	movl   $0xc01098dc,(%esp)
c0105502:	e8 2e af ff ff       	call   c0100435 <__panic>
    for (i =4; i>=0; i--) {
c0105507:	ff 4d f4             	decl   -0xc(%ebp)
c010550a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010550e:	79 8b                	jns    c010549b <check_vma_struct+0x407>
    }

    mm_destroy(mm);
c0105510:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105513:	89 04 24             	mov    %eax,(%esp)
c0105516:	e8 88 fa ff ff       	call   c0104fa3 <mm_destroy>

    assert(nr_free_pages_store == nr_free_pages());
c010551b:	e8 0d e0 ff ff       	call   c010352d <nr_free_pages>
c0105520:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0105523:	74 24                	je     c0105549 <check_vma_struct+0x4b5>
c0105525:	c7 44 24 0c 48 99 10 	movl   $0xc0109948,0xc(%esp)
c010552c:	c0 
c010552d:	c7 44 24 08 c7 98 10 	movl   $0xc01098c7,0x8(%esp)
c0105534:	c0 
c0105535:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
c010553c:	00 
c010553d:	c7 04 24 dc 98 10 c0 	movl   $0xc01098dc,(%esp)
c0105544:	e8 ec ae ff ff       	call   c0100435 <__panic>

    cprintf("check_vma_struct() succeeded!\n");
c0105549:	c7 04 24 cc 9a 10 c0 	movl   $0xc0109acc,(%esp)
c0105550:	e8 74 ad ff ff       	call   c01002c9 <cprintf>
}
c0105555:	90                   	nop
c0105556:	c9                   	leave  
c0105557:	c3                   	ret    

c0105558 <check_pgfault>:

struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
c0105558:	f3 0f 1e fb          	endbr32 
c010555c:	55                   	push   %ebp
c010555d:	89 e5                	mov    %esp,%ebp
c010555f:	83 ec 38             	sub    $0x38,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0105562:	e8 c6 df ff ff       	call   c010352d <nr_free_pages>
c0105567:	89 45 ec             	mov    %eax,-0x14(%ebp)

    check_mm_struct = mm_create();
c010556a:	e8 e6 f6 ff ff       	call   c0104c55 <mm_create>
c010556f:	a3 2c 60 12 c0       	mov    %eax,0xc012602c
    assert(check_mm_struct != NULL);
c0105574:	a1 2c 60 12 c0       	mov    0xc012602c,%eax
c0105579:	85 c0                	test   %eax,%eax
c010557b:	75 24                	jne    c01055a1 <check_pgfault+0x49>
c010557d:	c7 44 24 0c eb 9a 10 	movl   $0xc0109aeb,0xc(%esp)
c0105584:	c0 
c0105585:	c7 44 24 08 c7 98 10 	movl   $0xc01098c7,0x8(%esp)
c010558c:	c0 
c010558d:	c7 44 24 04 f4 00 00 	movl   $0xf4,0x4(%esp)
c0105594:	00 
c0105595:	c7 04 24 dc 98 10 c0 	movl   $0xc01098dc,(%esp)
c010559c:	e8 94 ae ff ff       	call   c0100435 <__panic>

    struct mm_struct *mm = check_mm_struct;
c01055a1:	a1 2c 60 12 c0       	mov    0xc012602c,%eax
c01055a6:	89 45 e8             	mov    %eax,-0x18(%ebp)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
c01055a9:	8b 15 e0 29 12 c0    	mov    0xc01229e0,%edx
c01055af:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01055b2:	89 50 0c             	mov    %edx,0xc(%eax)
c01055b5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01055b8:	8b 40 0c             	mov    0xc(%eax),%eax
c01055bb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(pgdir[0] == 0);
c01055be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01055c1:	8b 00                	mov    (%eax),%eax
c01055c3:	85 c0                	test   %eax,%eax
c01055c5:	74 24                	je     c01055eb <check_pgfault+0x93>
c01055c7:	c7 44 24 0c 03 9b 10 	movl   $0xc0109b03,0xc(%esp)
c01055ce:	c0 
c01055cf:	c7 44 24 08 c7 98 10 	movl   $0xc01098c7,0x8(%esp)
c01055d6:	c0 
c01055d7:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
c01055de:	00 
c01055df:	c7 04 24 dc 98 10 c0 	movl   $0xc01098dc,(%esp)
c01055e6:	e8 4a ae ff ff       	call   c0100435 <__panic>

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
c01055eb:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
c01055f2:	00 
c01055f3:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
c01055fa:	00 
c01055fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0105602:	e8 cb f6 ff ff       	call   c0104cd2 <vma_create>
c0105607:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(vma != NULL);
c010560a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c010560e:	75 24                	jne    c0105634 <check_pgfault+0xdc>
c0105610:	c7 44 24 0c 92 99 10 	movl   $0xc0109992,0xc(%esp)
c0105617:	c0 
c0105618:	c7 44 24 08 c7 98 10 	movl   $0xc01098c7,0x8(%esp)
c010561f:	c0 
c0105620:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
c0105627:	00 
c0105628:	c7 04 24 dc 98 10 c0 	movl   $0xc01098dc,(%esp)
c010562f:	e8 01 ae ff ff       	call   c0100435 <__panic>

    insert_vma_struct(mm, vma);
c0105634:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105637:	89 44 24 04          	mov    %eax,0x4(%esp)
c010563b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010563e:	89 04 24             	mov    %eax,(%esp)
c0105641:	e8 25 f8 ff ff       	call   c0104e6b <insert_vma_struct>

    uintptr_t addr = 0x100;
c0105646:	c7 45 dc 00 01 00 00 	movl   $0x100,-0x24(%ebp)
    assert(find_vma(mm, addr) == vma);
c010564d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105650:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105654:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105657:	89 04 24             	mov    %eax,(%esp)
c010565a:	e8 b2 f6 ff ff       	call   c0104d11 <find_vma>
c010565f:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0105662:	74 24                	je     c0105688 <check_pgfault+0x130>
c0105664:	c7 44 24 0c 11 9b 10 	movl   $0xc0109b11,0xc(%esp)
c010566b:	c0 
c010566c:	c7 44 24 08 c7 98 10 	movl   $0xc01098c7,0x8(%esp)
c0105673:	c0 
c0105674:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
c010567b:	00 
c010567c:	c7 04 24 dc 98 10 c0 	movl   $0xc01098dc,(%esp)
c0105683:	e8 ad ad ff ff       	call   c0100435 <__panic>

    int i, sum = 0;
c0105688:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c010568f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0105696:	eb 16                	jmp    c01056ae <check_pgfault+0x156>
        *(char *)(addr + i) = i;
c0105698:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010569b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010569e:	01 d0                	add    %edx,%eax
c01056a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01056a3:	88 10                	mov    %dl,(%eax)
        sum += i;
c01056a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01056a8:	01 45 f0             	add    %eax,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c01056ab:	ff 45 f4             	incl   -0xc(%ebp)
c01056ae:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c01056b2:	7e e4                	jle    c0105698 <check_pgfault+0x140>
    }
    for (i = 0; i < 100; i ++) {
c01056b4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01056bb:	eb 14                	jmp    c01056d1 <check_pgfault+0x179>
        sum -= *(char *)(addr + i);
c01056bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01056c0:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01056c3:	01 d0                	add    %edx,%eax
c01056c5:	0f b6 00             	movzbl (%eax),%eax
c01056c8:	0f be c0             	movsbl %al,%eax
c01056cb:	29 45 f0             	sub    %eax,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c01056ce:	ff 45 f4             	incl   -0xc(%ebp)
c01056d1:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c01056d5:	7e e6                	jle    c01056bd <check_pgfault+0x165>
    }
    assert(sum == 0);
c01056d7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01056db:	74 24                	je     c0105701 <check_pgfault+0x1a9>
c01056dd:	c7 44 24 0c 2b 9b 10 	movl   $0xc0109b2b,0xc(%esp)
c01056e4:	c0 
c01056e5:	c7 44 24 08 c7 98 10 	movl   $0xc01098c7,0x8(%esp)
c01056ec:	c0 
c01056ed:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
c01056f4:	00 
c01056f5:	c7 04 24 dc 98 10 c0 	movl   $0xc01098dc,(%esp)
c01056fc:	e8 34 ad ff ff       	call   c0100435 <__panic>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
c0105701:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105704:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0105707:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010570a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010570f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105713:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105716:	89 04 24             	mov    %eax,(%esp)
c0105719:	e8 a1 e4 ff ff       	call   c0103bbf <page_remove>
    free_page(pde2page(pgdir[0]));
c010571e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105721:	8b 00                	mov    (%eax),%eax
c0105723:	89 04 24             	mov    %eax,(%esp)
c0105726:	e8 12 f5 ff ff       	call   c0104c3d <pde2page>
c010572b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105732:	00 
c0105733:	89 04 24             	mov    %eax,(%esp)
c0105736:	e8 bb dd ff ff       	call   c01034f6 <free_pages>
    pgdir[0] = 0;
c010573b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010573e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    mm->pgdir = NULL;
c0105744:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105747:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    mm_destroy(mm);
c010574e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105751:	89 04 24             	mov    %eax,(%esp)
c0105754:	e8 4a f8 ff ff       	call   c0104fa3 <mm_destroy>
    check_mm_struct = NULL;
c0105759:	c7 05 2c 60 12 c0 00 	movl   $0x0,0xc012602c
c0105760:	00 00 00 

    assert(nr_free_pages_store == nr_free_pages());
c0105763:	e8 c5 dd ff ff       	call   c010352d <nr_free_pages>
c0105768:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c010576b:	74 24                	je     c0105791 <check_pgfault+0x239>
c010576d:	c7 44 24 0c 48 99 10 	movl   $0xc0109948,0xc(%esp)
c0105774:	c0 
c0105775:	c7 44 24 08 c7 98 10 	movl   $0xc01098c7,0x8(%esp)
c010577c:	c0 
c010577d:	c7 44 24 04 14 01 00 	movl   $0x114,0x4(%esp)
c0105784:	00 
c0105785:	c7 04 24 dc 98 10 c0 	movl   $0xc01098dc,(%esp)
c010578c:	e8 a4 ac ff ff       	call   c0100435 <__panic>

    cprintf("check_pgfault() succeeded!\n");
c0105791:	c7 04 24 34 9b 10 c0 	movl   $0xc0109b34,(%esp)
c0105798:	e8 2c ab ff ff       	call   c01002c9 <cprintf>
}
c010579d:	90                   	nop
c010579e:	c9                   	leave  
c010579f:	c3                   	ret    

c01057a0 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
c01057a0:	f3 0f 1e fb          	endbr32 
c01057a4:	55                   	push   %ebp
c01057a5:	89 e5                	mov    %esp,%ebp
c01057a7:	83 ec 38             	sub    $0x38,%esp
    int ret = -E_INVAL;
c01057aa:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
c01057b1:	8b 45 10             	mov    0x10(%ebp),%eax
c01057b4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01057b8:	8b 45 08             	mov    0x8(%ebp),%eax
c01057bb:	89 04 24             	mov    %eax,(%esp)
c01057be:	e8 4e f5 ff ff       	call   c0104d11 <find_vma>
c01057c3:	89 45 f0             	mov    %eax,-0x10(%ebp)

    pgfault_num++;
c01057c6:	a1 0c 60 12 c0       	mov    0xc012600c,%eax
c01057cb:	40                   	inc    %eax
c01057cc:	a3 0c 60 12 c0       	mov    %eax,0xc012600c
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
c01057d1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01057d5:	74 0b                	je     c01057e2 <do_pgfault+0x42>
c01057d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01057da:	8b 40 04             	mov    0x4(%eax),%eax
c01057dd:	39 45 10             	cmp    %eax,0x10(%ebp)
c01057e0:	73 18                	jae    c01057fa <do_pgfault+0x5a>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
c01057e2:	8b 45 10             	mov    0x10(%ebp),%eax
c01057e5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01057e9:	c7 04 24 50 9b 10 c0 	movl   $0xc0109b50,(%esp)
c01057f0:	e8 d4 aa ff ff       	call   c01002c9 <cprintf>
        goto failed;
c01057f5:	e9 92 00 00 00       	jmp    c010588c <do_pgfault+0xec>
    }
    //check the error_code
    switch (error_code & 3) {
c01057fa:	8b 45 0c             	mov    0xc(%ebp),%eax
c01057fd:	83 e0 03             	and    $0x3,%eax
c0105800:	85 c0                	test   %eax,%eax
c0105802:	74 2e                	je     c0105832 <do_pgfault+0x92>
c0105804:	83 f8 01             	cmp    $0x1,%eax
c0105807:	74 1b                	je     c0105824 <do_pgfault+0x84>
    default:
            /* error code flag : default is 3 ( W/R=1, P=1): write, present */
    case 2: /* error code flag : (W/R=1, P=0): write, not present */
        if (!(vma->vm_flags & VM_WRITE)) {
c0105809:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010580c:	8b 40 0c             	mov    0xc(%eax),%eax
c010580f:	83 e0 02             	and    $0x2,%eax
c0105812:	85 c0                	test   %eax,%eax
c0105814:	75 37                	jne    c010584d <do_pgfault+0xad>
            cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
c0105816:	c7 04 24 80 9b 10 c0 	movl   $0xc0109b80,(%esp)
c010581d:	e8 a7 aa ff ff       	call   c01002c9 <cprintf>
            goto failed;
c0105822:	eb 68                	jmp    c010588c <do_pgfault+0xec>
        }
        break;
    case 1: /* error code flag : (W/R=0, P=1): read, present */
        cprintf("do_pgfault failed: error code flag = read AND present\n");
c0105824:	c7 04 24 e0 9b 10 c0 	movl   $0xc0109be0,(%esp)
c010582b:	e8 99 aa ff ff       	call   c01002c9 <cprintf>
        goto failed;
c0105830:	eb 5a                	jmp    c010588c <do_pgfault+0xec>
    case 0: /* error code flag : (W/R=0, P=0): read, not present */
        if (!(vma->vm_flags & (VM_READ | VM_EXEC))) {
c0105832:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105835:	8b 40 0c             	mov    0xc(%eax),%eax
c0105838:	83 e0 05             	and    $0x5,%eax
c010583b:	85 c0                	test   %eax,%eax
c010583d:	75 0f                	jne    c010584e <do_pgfault+0xae>
            cprintf("do_pgfault failed: error code flag = read AND not present, but the addr's vma cannot read or exec\n");
c010583f:	c7 04 24 18 9c 10 c0 	movl   $0xc0109c18,(%esp)
c0105846:	e8 7e aa ff ff       	call   c01002c9 <cprintf>
            goto failed;
c010584b:	eb 3f                	jmp    c010588c <do_pgfault+0xec>
        break;
c010584d:	90                   	nop
     *    (write an non_existed addr && addr is writable) OR
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
c010584e:	c7 45 ec 04 00 00 00 	movl   $0x4,-0x14(%ebp)
    if (vma->vm_flags & VM_WRITE) {
c0105855:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105858:	8b 40 0c             	mov    0xc(%eax),%eax
c010585b:	83 e0 02             	and    $0x2,%eax
c010585e:	85 c0                	test   %eax,%eax
c0105860:	74 04                	je     c0105866 <do_pgfault+0xc6>
        perm |= PTE_W;
c0105862:	83 4d ec 02          	orl    $0x2,-0x14(%ebp)
    }
    addr = ROUNDDOWN(addr, PGSIZE);
c0105866:	8b 45 10             	mov    0x10(%ebp),%eax
c0105869:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010586c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010586f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105874:	89 45 10             	mov    %eax,0x10(%ebp)

    ret = -E_NO_MEM;
c0105877:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

    pte_t *ptep=NULL;
c010587e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
            goto failed;
        }
   }
#endif
   ret = 0;
c0105885:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
failed:
    return ret;
c010588c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010588f:	c9                   	leave  
c0105890:	c3                   	ret    

c0105891 <pa2page>:
pa2page(uintptr_t pa) {
c0105891:	55                   	push   %ebp
c0105892:	89 e5                	mov    %esp,%ebp
c0105894:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0105897:	8b 45 08             	mov    0x8(%ebp),%eax
c010589a:	c1 e8 0c             	shr    $0xc,%eax
c010589d:	89 c2                	mov    %eax,%edx
c010589f:	a1 80 5f 12 c0       	mov    0xc0125f80,%eax
c01058a4:	39 c2                	cmp    %eax,%edx
c01058a6:	72 1c                	jb     c01058c4 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c01058a8:	c7 44 24 08 7c 9c 10 	movl   $0xc0109c7c,0x8(%esp)
c01058af:	c0 
c01058b0:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
c01058b7:	00 
c01058b8:	c7 04 24 9b 9c 10 c0 	movl   $0xc0109c9b,(%esp)
c01058bf:	e8 71 ab ff ff       	call   c0100435 <__panic>
    return &pages[PPN(pa)];
c01058c4:	a1 28 60 12 c0       	mov    0xc0126028,%eax
c01058c9:	8b 55 08             	mov    0x8(%ebp),%edx
c01058cc:	c1 ea 0c             	shr    $0xc,%edx
c01058cf:	c1 e2 05             	shl    $0x5,%edx
c01058d2:	01 d0                	add    %edx,%eax
}
c01058d4:	c9                   	leave  
c01058d5:	c3                   	ret    

c01058d6 <pte2page>:
pte2page(pte_t pte) {
c01058d6:	55                   	push   %ebp
c01058d7:	89 e5                	mov    %esp,%ebp
c01058d9:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c01058dc:	8b 45 08             	mov    0x8(%ebp),%eax
c01058df:	83 e0 01             	and    $0x1,%eax
c01058e2:	85 c0                	test   %eax,%eax
c01058e4:	75 1c                	jne    c0105902 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c01058e6:	c7 44 24 08 ac 9c 10 	movl   $0xc0109cac,0x8(%esp)
c01058ed:	c0 
c01058ee:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c01058f5:	00 
c01058f6:	c7 04 24 9b 9c 10 c0 	movl   $0xc0109c9b,(%esp)
c01058fd:	e8 33 ab ff ff       	call   c0100435 <__panic>
    return pa2page(PTE_ADDR(pte));
c0105902:	8b 45 08             	mov    0x8(%ebp),%eax
c0105905:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010590a:	89 04 24             	mov    %eax,(%esp)
c010590d:	e8 7f ff ff ff       	call   c0105891 <pa2page>
}
c0105912:	c9                   	leave  
c0105913:	c3                   	ret    

c0105914 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
c0105914:	f3 0f 1e fb          	endbr32 
c0105918:	55                   	push   %ebp
c0105919:	89 e5                	mov    %esp,%ebp
c010591b:	83 ec 28             	sub    $0x28,%esp
     swapfs_init();
c010591e:	e8 19 22 00 00       	call   c0107b3c <swapfs_init>

     if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
c0105923:	a1 dc 60 12 c0       	mov    0xc01260dc,%eax
c0105928:	3d ff 03 00 00       	cmp    $0x3ff,%eax
c010592d:	76 0c                	jbe    c010593b <swap_init+0x27>
c010592f:	a1 dc 60 12 c0       	mov    0xc01260dc,%eax
c0105934:	3d ff ff ff 00       	cmp    $0xffffff,%eax
c0105939:	76 25                	jbe    c0105960 <swap_init+0x4c>
     {
          panic("bad max_swap_offset %08x.\n", max_swap_offset);
c010593b:	a1 dc 60 12 c0       	mov    0xc01260dc,%eax
c0105940:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105944:	c7 44 24 08 cd 9c 10 	movl   $0xc0109ccd,0x8(%esp)
c010594b:	c0 
c010594c:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
c0105953:	00 
c0105954:	c7 04 24 e8 9c 10 c0 	movl   $0xc0109ce8,(%esp)
c010595b:	e8 d5 aa ff ff       	call   c0100435 <__panic>
     }
     

     sm = &swap_manager_fifo;
c0105960:	c7 05 18 60 12 c0 40 	movl   $0xc0122a40,0xc0126018
c0105967:	2a 12 c0 
     int r = sm->init();
c010596a:	a1 18 60 12 c0       	mov    0xc0126018,%eax
c010596f:	8b 40 04             	mov    0x4(%eax),%eax
c0105972:	ff d0                	call   *%eax
c0105974:	89 45 f4             	mov    %eax,-0xc(%ebp)
     
     if (r == 0)
c0105977:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010597b:	75 26                	jne    c01059a3 <swap_init+0x8f>
     {
          swap_init_ok = 1;
c010597d:	c7 05 10 60 12 c0 01 	movl   $0x1,0xc0126010
c0105984:	00 00 00 
          cprintf("SWAP: manager = %s\n", sm->name);
c0105987:	a1 18 60 12 c0       	mov    0xc0126018,%eax
c010598c:	8b 00                	mov    (%eax),%eax
c010598e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105992:	c7 04 24 f7 9c 10 c0 	movl   $0xc0109cf7,(%esp)
c0105999:	e8 2b a9 ff ff       	call   c01002c9 <cprintf>
          check_swap();
c010599e:	e8 b6 04 00 00       	call   c0105e59 <check_swap>
     }

     return r;
c01059a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01059a6:	c9                   	leave  
c01059a7:	c3                   	ret    

c01059a8 <swap_init_mm>:

int
swap_init_mm(struct mm_struct *mm)
{
c01059a8:	f3 0f 1e fb          	endbr32 
c01059ac:	55                   	push   %ebp
c01059ad:	89 e5                	mov    %esp,%ebp
c01059af:	83 ec 18             	sub    $0x18,%esp
     return sm->init_mm(mm);
c01059b2:	a1 18 60 12 c0       	mov    0xc0126018,%eax
c01059b7:	8b 40 08             	mov    0x8(%eax),%eax
c01059ba:	8b 55 08             	mov    0x8(%ebp),%edx
c01059bd:	89 14 24             	mov    %edx,(%esp)
c01059c0:	ff d0                	call   *%eax
}
c01059c2:	c9                   	leave  
c01059c3:	c3                   	ret    

c01059c4 <swap_tick_event>:

int
swap_tick_event(struct mm_struct *mm)
{
c01059c4:	f3 0f 1e fb          	endbr32 
c01059c8:	55                   	push   %ebp
c01059c9:	89 e5                	mov    %esp,%ebp
c01059cb:	83 ec 18             	sub    $0x18,%esp
     return sm->tick_event(mm);
c01059ce:	a1 18 60 12 c0       	mov    0xc0126018,%eax
c01059d3:	8b 40 0c             	mov    0xc(%eax),%eax
c01059d6:	8b 55 08             	mov    0x8(%ebp),%edx
c01059d9:	89 14 24             	mov    %edx,(%esp)
c01059dc:	ff d0                	call   *%eax
}
c01059de:	c9                   	leave  
c01059df:	c3                   	ret    

c01059e0 <swap_map_swappable>:

int
swap_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c01059e0:	f3 0f 1e fb          	endbr32 
c01059e4:	55                   	push   %ebp
c01059e5:	89 e5                	mov    %esp,%ebp
c01059e7:	83 ec 18             	sub    $0x18,%esp
     return sm->map_swappable(mm, addr, page, swap_in);
c01059ea:	a1 18 60 12 c0       	mov    0xc0126018,%eax
c01059ef:	8b 40 10             	mov    0x10(%eax),%eax
c01059f2:	8b 55 14             	mov    0x14(%ebp),%edx
c01059f5:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01059f9:	8b 55 10             	mov    0x10(%ebp),%edx
c01059fc:	89 54 24 08          	mov    %edx,0x8(%esp)
c0105a00:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105a03:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105a07:	8b 55 08             	mov    0x8(%ebp),%edx
c0105a0a:	89 14 24             	mov    %edx,(%esp)
c0105a0d:	ff d0                	call   *%eax
}
c0105a0f:	c9                   	leave  
c0105a10:	c3                   	ret    

c0105a11 <swap_set_unswappable>:

int
swap_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c0105a11:	f3 0f 1e fb          	endbr32 
c0105a15:	55                   	push   %ebp
c0105a16:	89 e5                	mov    %esp,%ebp
c0105a18:	83 ec 18             	sub    $0x18,%esp
     return sm->set_unswappable(mm, addr);
c0105a1b:	a1 18 60 12 c0       	mov    0xc0126018,%eax
c0105a20:	8b 40 14             	mov    0x14(%eax),%eax
c0105a23:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105a26:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105a2a:	8b 55 08             	mov    0x8(%ebp),%edx
c0105a2d:	89 14 24             	mov    %edx,(%esp)
c0105a30:	ff d0                	call   *%eax
}
c0105a32:	c9                   	leave  
c0105a33:	c3                   	ret    

c0105a34 <swap_out>:

volatile unsigned int swap_out_num=0;

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
c0105a34:	f3 0f 1e fb          	endbr32 
c0105a38:	55                   	push   %ebp
c0105a39:	89 e5                	mov    %esp,%ebp
c0105a3b:	83 ec 38             	sub    $0x38,%esp
     int i;
     for (i = 0; i != n; ++ i)
c0105a3e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0105a45:	e9 53 01 00 00       	jmp    c0105b9d <swap_out+0x169>
     {
          uintptr_t v;
          //struct Page **ptr_page=NULL;
          struct Page *page;
          // cprintf("i %d, SWAP: call swap_out_victim\n",i);
          int r = sm->swap_out_victim(mm, &page, in_tick);
c0105a4a:	a1 18 60 12 c0       	mov    0xc0126018,%eax
c0105a4f:	8b 40 18             	mov    0x18(%eax),%eax
c0105a52:	8b 55 10             	mov    0x10(%ebp),%edx
c0105a55:	89 54 24 08          	mov    %edx,0x8(%esp)
c0105a59:	8d 55 e4             	lea    -0x1c(%ebp),%edx
c0105a5c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105a60:	8b 55 08             	mov    0x8(%ebp),%edx
c0105a63:	89 14 24             	mov    %edx,(%esp)
c0105a66:	ff d0                	call   *%eax
c0105a68:	89 45 f0             	mov    %eax,-0x10(%ebp)
          if (r != 0) {
c0105a6b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105a6f:	74 18                	je     c0105a89 <swap_out+0x55>
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
c0105a71:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a74:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105a78:	c7 04 24 0c 9d 10 c0 	movl   $0xc0109d0c,(%esp)
c0105a7f:	e8 45 a8 ff ff       	call   c01002c9 <cprintf>
c0105a84:	e9 20 01 00 00       	jmp    c0105ba9 <swap_out+0x175>
          }          
          //assert(!PageReserved(page));

          //cprintf("SWAP: choose victim page 0x%08x\n", page);
          
          v=page->pra_vaddr; 
c0105a89:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105a8c:	8b 40 1c             	mov    0x1c(%eax),%eax
c0105a8f:	89 45 ec             	mov    %eax,-0x14(%ebp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
c0105a92:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a95:	8b 40 0c             	mov    0xc(%eax),%eax
c0105a98:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105a9f:	00 
c0105aa0:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105aa3:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105aa7:	89 04 24             	mov    %eax,(%esp)
c0105aaa:	e8 a3 e0 ff ff       	call   c0103b52 <get_pte>
c0105aaf:	89 45 e8             	mov    %eax,-0x18(%ebp)
          assert((*ptep & PTE_P) != 0);
c0105ab2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105ab5:	8b 00                	mov    (%eax),%eax
c0105ab7:	83 e0 01             	and    $0x1,%eax
c0105aba:	85 c0                	test   %eax,%eax
c0105abc:	75 24                	jne    c0105ae2 <swap_out+0xae>
c0105abe:	c7 44 24 0c 39 9d 10 	movl   $0xc0109d39,0xc(%esp)
c0105ac5:	c0 
c0105ac6:	c7 44 24 08 4e 9d 10 	movl   $0xc0109d4e,0x8(%esp)
c0105acd:	c0 
c0105ace:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c0105ad5:	00 
c0105ad6:	c7 04 24 e8 9c 10 c0 	movl   $0xc0109ce8,(%esp)
c0105add:	e8 53 a9 ff ff       	call   c0100435 <__panic>

          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
c0105ae2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105ae5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105ae8:	8b 52 1c             	mov    0x1c(%edx),%edx
c0105aeb:	c1 ea 0c             	shr    $0xc,%edx
c0105aee:	42                   	inc    %edx
c0105aef:	c1 e2 08             	shl    $0x8,%edx
c0105af2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105af6:	89 14 24             	mov    %edx,(%esp)
c0105af9:	e8 01 21 00 00       	call   c0107bff <swapfs_write>
c0105afe:	85 c0                	test   %eax,%eax
c0105b00:	74 34                	je     c0105b36 <swap_out+0x102>
                    cprintf("SWAP: failed to save\n");
c0105b02:	c7 04 24 63 9d 10 c0 	movl   $0xc0109d63,(%esp)
c0105b09:	e8 bb a7 ff ff       	call   c01002c9 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
c0105b0e:	a1 18 60 12 c0       	mov    0xc0126018,%eax
c0105b13:	8b 40 10             	mov    0x10(%eax),%eax
c0105b16:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105b19:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0105b20:	00 
c0105b21:	89 54 24 08          	mov    %edx,0x8(%esp)
c0105b25:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105b28:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105b2c:	8b 55 08             	mov    0x8(%ebp),%edx
c0105b2f:	89 14 24             	mov    %edx,(%esp)
c0105b32:	ff d0                	call   *%eax
c0105b34:	eb 64                	jmp    c0105b9a <swap_out+0x166>
                    continue;
          }
          else {
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
c0105b36:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105b39:	8b 40 1c             	mov    0x1c(%eax),%eax
c0105b3c:	c1 e8 0c             	shr    $0xc,%eax
c0105b3f:	40                   	inc    %eax
c0105b40:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105b44:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105b47:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105b4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105b4e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105b52:	c7 04 24 7c 9d 10 c0 	movl   $0xc0109d7c,(%esp)
c0105b59:	e8 6b a7 ff ff       	call   c01002c9 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
c0105b5e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105b61:	8b 40 1c             	mov    0x1c(%eax),%eax
c0105b64:	c1 e8 0c             	shr    $0xc,%eax
c0105b67:	40                   	inc    %eax
c0105b68:	c1 e0 08             	shl    $0x8,%eax
c0105b6b:	89 c2                	mov    %eax,%edx
c0105b6d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105b70:	89 10                	mov    %edx,(%eax)
                    free_page(page);
c0105b72:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105b75:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105b7c:	00 
c0105b7d:	89 04 24             	mov    %eax,(%esp)
c0105b80:	e8 71 d9 ff ff       	call   c01034f6 <free_pages>
          }
          
          tlb_invalidate(mm->pgdir, v);
c0105b85:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b88:	8b 40 0c             	mov    0xc(%eax),%eax
c0105b8b:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105b8e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105b92:	89 04 24             	mov    %eax,(%esp)
c0105b95:	e8 2b e1 ff ff       	call   c0103cc5 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
c0105b9a:	ff 45 f4             	incl   -0xc(%ebp)
c0105b9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105ba0:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105ba3:	0f 85 a1 fe ff ff    	jne    c0105a4a <swap_out+0x16>
     }
     return i;
c0105ba9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105bac:	c9                   	leave  
c0105bad:	c3                   	ret    

c0105bae <swap_in>:

int
swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result)
{
c0105bae:	f3 0f 1e fb          	endbr32 
c0105bb2:	55                   	push   %ebp
c0105bb3:	89 e5                	mov    %esp,%ebp
c0105bb5:	83 ec 28             	sub    $0x28,%esp
     struct Page *result = alloc_page();
c0105bb8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105bbf:	e8 c3 d8 ff ff       	call   c0103487 <alloc_pages>
c0105bc4:	89 45 f4             	mov    %eax,-0xc(%ebp)
     assert(result!=NULL);
c0105bc7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105bcb:	75 24                	jne    c0105bf1 <swap_in+0x43>
c0105bcd:	c7 44 24 0c bc 9d 10 	movl   $0xc0109dbc,0xc(%esp)
c0105bd4:	c0 
c0105bd5:	c7 44 24 08 4e 9d 10 	movl   $0xc0109d4e,0x8(%esp)
c0105bdc:	c0 
c0105bdd:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
c0105be4:	00 
c0105be5:	c7 04 24 e8 9c 10 c0 	movl   $0xc0109ce8,(%esp)
c0105bec:	e8 44 a8 ff ff       	call   c0100435 <__panic>

     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
c0105bf1:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bf4:	8b 40 0c             	mov    0xc(%eax),%eax
c0105bf7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105bfe:	00 
c0105bff:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105c02:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105c06:	89 04 24             	mov    %eax,(%esp)
c0105c09:	e8 44 df ff ff       	call   c0103b52 <get_pte>
c0105c0e:	89 45 f0             	mov    %eax,-0x10(%ebp)
     // cprintf("SWAP: load ptep %x swap entry %d to vaddr 0x%08x, page %x, No %d\n", ptep, (*ptep)>>8, addr, result, (result-pages));
    
     int r;
     if ((r = swapfs_read((*ptep), result)) != 0)
c0105c11:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105c14:	8b 00                	mov    (%eax),%eax
c0105c16:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105c19:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105c1d:	89 04 24             	mov    %eax,(%esp)
c0105c20:	e8 64 1f 00 00       	call   c0107b89 <swapfs_read>
c0105c25:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105c28:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0105c2c:	74 2a                	je     c0105c58 <swap_in+0xaa>
     {
        assert(r!=0);
c0105c2e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0105c32:	75 24                	jne    c0105c58 <swap_in+0xaa>
c0105c34:	c7 44 24 0c c9 9d 10 	movl   $0xc0109dc9,0xc(%esp)
c0105c3b:	c0 
c0105c3c:	c7 44 24 08 4e 9d 10 	movl   $0xc0109d4e,0x8(%esp)
c0105c43:	c0 
c0105c44:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
c0105c4b:	00 
c0105c4c:	c7 04 24 e8 9c 10 c0 	movl   $0xc0109ce8,(%esp)
c0105c53:	e8 dd a7 ff ff       	call   c0100435 <__panic>
     }
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
c0105c58:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105c5b:	8b 00                	mov    (%eax),%eax
c0105c5d:	c1 e8 08             	shr    $0x8,%eax
c0105c60:	89 c2                	mov    %eax,%edx
c0105c62:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c65:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105c69:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105c6d:	c7 04 24 d0 9d 10 c0 	movl   $0xc0109dd0,(%esp)
c0105c74:	e8 50 a6 ff ff       	call   c01002c9 <cprintf>
     *ptr_result=result;
c0105c79:	8b 45 10             	mov    0x10(%ebp),%eax
c0105c7c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105c7f:	89 10                	mov    %edx,(%eax)
     return 0;
c0105c81:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105c86:	c9                   	leave  
c0105c87:	c3                   	ret    

c0105c88 <check_content_set>:



static inline void
check_content_set(void)
{
c0105c88:	55                   	push   %ebp
c0105c89:	89 e5                	mov    %esp,%ebp
c0105c8b:	83 ec 18             	sub    $0x18,%esp
     *(unsigned char *)0x1000 = 0x0a;
c0105c8e:	b8 00 10 00 00       	mov    $0x1000,%eax
c0105c93:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c0105c96:	a1 0c 60 12 c0       	mov    0xc012600c,%eax
c0105c9b:	83 f8 01             	cmp    $0x1,%eax
c0105c9e:	74 24                	je     c0105cc4 <check_content_set+0x3c>
c0105ca0:	c7 44 24 0c 0e 9e 10 	movl   $0xc0109e0e,0xc(%esp)
c0105ca7:	c0 
c0105ca8:	c7 44 24 08 4e 9d 10 	movl   $0xc0109d4e,0x8(%esp)
c0105caf:	c0 
c0105cb0:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
c0105cb7:	00 
c0105cb8:	c7 04 24 e8 9c 10 c0 	movl   $0xc0109ce8,(%esp)
c0105cbf:	e8 71 a7 ff ff       	call   c0100435 <__panic>
     *(unsigned char *)0x1010 = 0x0a;
c0105cc4:	b8 10 10 00 00       	mov    $0x1010,%eax
c0105cc9:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c0105ccc:	a1 0c 60 12 c0       	mov    0xc012600c,%eax
c0105cd1:	83 f8 01             	cmp    $0x1,%eax
c0105cd4:	74 24                	je     c0105cfa <check_content_set+0x72>
c0105cd6:	c7 44 24 0c 0e 9e 10 	movl   $0xc0109e0e,0xc(%esp)
c0105cdd:	c0 
c0105cde:	c7 44 24 08 4e 9d 10 	movl   $0xc0109d4e,0x8(%esp)
c0105ce5:	c0 
c0105ce6:	c7 44 24 04 92 00 00 	movl   $0x92,0x4(%esp)
c0105ced:	00 
c0105cee:	c7 04 24 e8 9c 10 c0 	movl   $0xc0109ce8,(%esp)
c0105cf5:	e8 3b a7 ff ff       	call   c0100435 <__panic>
     *(unsigned char *)0x2000 = 0x0b;
c0105cfa:	b8 00 20 00 00       	mov    $0x2000,%eax
c0105cff:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c0105d02:	a1 0c 60 12 c0       	mov    0xc012600c,%eax
c0105d07:	83 f8 02             	cmp    $0x2,%eax
c0105d0a:	74 24                	je     c0105d30 <check_content_set+0xa8>
c0105d0c:	c7 44 24 0c 1d 9e 10 	movl   $0xc0109e1d,0xc(%esp)
c0105d13:	c0 
c0105d14:	c7 44 24 08 4e 9d 10 	movl   $0xc0109d4e,0x8(%esp)
c0105d1b:	c0 
c0105d1c:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
c0105d23:	00 
c0105d24:	c7 04 24 e8 9c 10 c0 	movl   $0xc0109ce8,(%esp)
c0105d2b:	e8 05 a7 ff ff       	call   c0100435 <__panic>
     *(unsigned char *)0x2010 = 0x0b;
c0105d30:	b8 10 20 00 00       	mov    $0x2010,%eax
c0105d35:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c0105d38:	a1 0c 60 12 c0       	mov    0xc012600c,%eax
c0105d3d:	83 f8 02             	cmp    $0x2,%eax
c0105d40:	74 24                	je     c0105d66 <check_content_set+0xde>
c0105d42:	c7 44 24 0c 1d 9e 10 	movl   $0xc0109e1d,0xc(%esp)
c0105d49:	c0 
c0105d4a:	c7 44 24 08 4e 9d 10 	movl   $0xc0109d4e,0x8(%esp)
c0105d51:	c0 
c0105d52:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
c0105d59:	00 
c0105d5a:	c7 04 24 e8 9c 10 c0 	movl   $0xc0109ce8,(%esp)
c0105d61:	e8 cf a6 ff ff       	call   c0100435 <__panic>
     *(unsigned char *)0x3000 = 0x0c;
c0105d66:	b8 00 30 00 00       	mov    $0x3000,%eax
c0105d6b:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c0105d6e:	a1 0c 60 12 c0       	mov    0xc012600c,%eax
c0105d73:	83 f8 03             	cmp    $0x3,%eax
c0105d76:	74 24                	je     c0105d9c <check_content_set+0x114>
c0105d78:	c7 44 24 0c 2c 9e 10 	movl   $0xc0109e2c,0xc(%esp)
c0105d7f:	c0 
c0105d80:	c7 44 24 08 4e 9d 10 	movl   $0xc0109d4e,0x8(%esp)
c0105d87:	c0 
c0105d88:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
c0105d8f:	00 
c0105d90:	c7 04 24 e8 9c 10 c0 	movl   $0xc0109ce8,(%esp)
c0105d97:	e8 99 a6 ff ff       	call   c0100435 <__panic>
     *(unsigned char *)0x3010 = 0x0c;
c0105d9c:	b8 10 30 00 00       	mov    $0x3010,%eax
c0105da1:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c0105da4:	a1 0c 60 12 c0       	mov    0xc012600c,%eax
c0105da9:	83 f8 03             	cmp    $0x3,%eax
c0105dac:	74 24                	je     c0105dd2 <check_content_set+0x14a>
c0105dae:	c7 44 24 0c 2c 9e 10 	movl   $0xc0109e2c,0xc(%esp)
c0105db5:	c0 
c0105db6:	c7 44 24 08 4e 9d 10 	movl   $0xc0109d4e,0x8(%esp)
c0105dbd:	c0 
c0105dbe:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
c0105dc5:	00 
c0105dc6:	c7 04 24 e8 9c 10 c0 	movl   $0xc0109ce8,(%esp)
c0105dcd:	e8 63 a6 ff ff       	call   c0100435 <__panic>
     *(unsigned char *)0x4000 = 0x0d;
c0105dd2:	b8 00 40 00 00       	mov    $0x4000,%eax
c0105dd7:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c0105dda:	a1 0c 60 12 c0       	mov    0xc012600c,%eax
c0105ddf:	83 f8 04             	cmp    $0x4,%eax
c0105de2:	74 24                	je     c0105e08 <check_content_set+0x180>
c0105de4:	c7 44 24 0c 3b 9e 10 	movl   $0xc0109e3b,0xc(%esp)
c0105deb:	c0 
c0105dec:	c7 44 24 08 4e 9d 10 	movl   $0xc0109d4e,0x8(%esp)
c0105df3:	c0 
c0105df4:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
c0105dfb:	00 
c0105dfc:	c7 04 24 e8 9c 10 c0 	movl   $0xc0109ce8,(%esp)
c0105e03:	e8 2d a6 ff ff       	call   c0100435 <__panic>
     *(unsigned char *)0x4010 = 0x0d;
c0105e08:	b8 10 40 00 00       	mov    $0x4010,%eax
c0105e0d:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c0105e10:	a1 0c 60 12 c0       	mov    0xc012600c,%eax
c0105e15:	83 f8 04             	cmp    $0x4,%eax
c0105e18:	74 24                	je     c0105e3e <check_content_set+0x1b6>
c0105e1a:	c7 44 24 0c 3b 9e 10 	movl   $0xc0109e3b,0xc(%esp)
c0105e21:	c0 
c0105e22:	c7 44 24 08 4e 9d 10 	movl   $0xc0109d4e,0x8(%esp)
c0105e29:	c0 
c0105e2a:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
c0105e31:	00 
c0105e32:	c7 04 24 e8 9c 10 c0 	movl   $0xc0109ce8,(%esp)
c0105e39:	e8 f7 a5 ff ff       	call   c0100435 <__panic>
}
c0105e3e:	90                   	nop
c0105e3f:	c9                   	leave  
c0105e40:	c3                   	ret    

c0105e41 <check_content_access>:

static inline int
check_content_access(void)
{
c0105e41:	55                   	push   %ebp
c0105e42:	89 e5                	mov    %esp,%ebp
c0105e44:	83 ec 18             	sub    $0x18,%esp
    int ret = sm->check_swap();
c0105e47:	a1 18 60 12 c0       	mov    0xc0126018,%eax
c0105e4c:	8b 40 1c             	mov    0x1c(%eax),%eax
c0105e4f:	ff d0                	call   *%eax
c0105e51:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return ret;
c0105e54:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105e57:	c9                   	leave  
c0105e58:	c3                   	ret    

c0105e59 <check_swap>:
#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
check_swap(void)
{
c0105e59:	f3 0f 1e fb          	endbr32 
c0105e5d:	55                   	push   %ebp
c0105e5e:	89 e5                	mov    %esp,%ebp
c0105e60:	83 ec 78             	sub    $0x78,%esp
    //backup mem env
     int ret, count = 0, total = 0, i;
c0105e63:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0105e6a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     list_entry_t *le = &free_list;
c0105e71:	c7 45 e8 0c 61 12 c0 	movl   $0xc012610c,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c0105e78:	eb 6a                	jmp    c0105ee4 <check_swap+0x8b>
        struct Page *p = le2page(le, page_link);
c0105e7a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105e7d:	83 e8 0c             	sub    $0xc,%eax
c0105e80:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(PageProperty(p));
c0105e83:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0105e86:	83 c0 04             	add    $0x4,%eax
c0105e89:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c0105e90:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105e93:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0105e96:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0105e99:	0f a3 10             	bt     %edx,(%eax)
c0105e9c:	19 c0                	sbb    %eax,%eax
c0105e9e:	89 45 bc             	mov    %eax,-0x44(%ebp)
    return oldbit != 0;
c0105ea1:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0105ea5:	0f 95 c0             	setne  %al
c0105ea8:	0f b6 c0             	movzbl %al,%eax
c0105eab:	85 c0                	test   %eax,%eax
c0105ead:	75 24                	jne    c0105ed3 <check_swap+0x7a>
c0105eaf:	c7 44 24 0c 4a 9e 10 	movl   $0xc0109e4a,0xc(%esp)
c0105eb6:	c0 
c0105eb7:	c7 44 24 08 4e 9d 10 	movl   $0xc0109d4e,0x8(%esp)
c0105ebe:	c0 
c0105ebf:	c7 44 24 04 b9 00 00 	movl   $0xb9,0x4(%esp)
c0105ec6:	00 
c0105ec7:	c7 04 24 e8 9c 10 c0 	movl   $0xc0109ce8,(%esp)
c0105ece:	e8 62 a5 ff ff       	call   c0100435 <__panic>
        count ++, total += p->property;
c0105ed3:	ff 45 f4             	incl   -0xc(%ebp)
c0105ed6:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0105ed9:	8b 50 08             	mov    0x8(%eax),%edx
c0105edc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105edf:	01 d0                	add    %edx,%eax
c0105ee1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105ee4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105ee7:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0105eea:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0105eed:	8b 40 04             	mov    0x4(%eax),%eax
     while ((le = list_next(le)) != &free_list) {
c0105ef0:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105ef3:	81 7d e8 0c 61 12 c0 	cmpl   $0xc012610c,-0x18(%ebp)
c0105efa:	0f 85 7a ff ff ff    	jne    c0105e7a <check_swap+0x21>
     }
     assert(total == nr_free_pages());
c0105f00:	e8 28 d6 ff ff       	call   c010352d <nr_free_pages>
c0105f05:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105f08:	39 d0                	cmp    %edx,%eax
c0105f0a:	74 24                	je     c0105f30 <check_swap+0xd7>
c0105f0c:	c7 44 24 0c 5a 9e 10 	movl   $0xc0109e5a,0xc(%esp)
c0105f13:	c0 
c0105f14:	c7 44 24 08 4e 9d 10 	movl   $0xc0109d4e,0x8(%esp)
c0105f1b:	c0 
c0105f1c:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
c0105f23:	00 
c0105f24:	c7 04 24 e8 9c 10 c0 	movl   $0xc0109ce8,(%esp)
c0105f2b:	e8 05 a5 ff ff       	call   c0100435 <__panic>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
c0105f30:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105f33:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105f37:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105f3a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105f3e:	c7 04 24 74 9e 10 c0 	movl   $0xc0109e74,(%esp)
c0105f45:	e8 7f a3 ff ff       	call   c01002c9 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
c0105f4a:	e8 06 ed ff ff       	call   c0104c55 <mm_create>
c0105f4f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
     assert(mm != NULL);
c0105f52:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105f56:	75 24                	jne    c0105f7c <check_swap+0x123>
c0105f58:	c7 44 24 0c 9a 9e 10 	movl   $0xc0109e9a,0xc(%esp)
c0105f5f:	c0 
c0105f60:	c7 44 24 08 4e 9d 10 	movl   $0xc0109d4e,0x8(%esp)
c0105f67:	c0 
c0105f68:	c7 44 24 04 c1 00 00 	movl   $0xc1,0x4(%esp)
c0105f6f:	00 
c0105f70:	c7 04 24 e8 9c 10 c0 	movl   $0xc0109ce8,(%esp)
c0105f77:	e8 b9 a4 ff ff       	call   c0100435 <__panic>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
c0105f7c:	a1 2c 60 12 c0       	mov    0xc012602c,%eax
c0105f81:	85 c0                	test   %eax,%eax
c0105f83:	74 24                	je     c0105fa9 <check_swap+0x150>
c0105f85:	c7 44 24 0c a5 9e 10 	movl   $0xc0109ea5,0xc(%esp)
c0105f8c:	c0 
c0105f8d:	c7 44 24 08 4e 9d 10 	movl   $0xc0109d4e,0x8(%esp)
c0105f94:	c0 
c0105f95:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
c0105f9c:	00 
c0105f9d:	c7 04 24 e8 9c 10 c0 	movl   $0xc0109ce8,(%esp)
c0105fa4:	e8 8c a4 ff ff       	call   c0100435 <__panic>

     check_mm_struct = mm;
c0105fa9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105fac:	a3 2c 60 12 c0       	mov    %eax,0xc012602c

     pde_t *pgdir = mm->pgdir = boot_pgdir;
c0105fb1:	8b 15 e0 29 12 c0    	mov    0xc01229e0,%edx
c0105fb7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105fba:	89 50 0c             	mov    %edx,0xc(%eax)
c0105fbd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105fc0:	8b 40 0c             	mov    0xc(%eax),%eax
c0105fc3:	89 45 e0             	mov    %eax,-0x20(%ebp)
     assert(pgdir[0] == 0);
c0105fc6:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105fc9:	8b 00                	mov    (%eax),%eax
c0105fcb:	85 c0                	test   %eax,%eax
c0105fcd:	74 24                	je     c0105ff3 <check_swap+0x19a>
c0105fcf:	c7 44 24 0c bd 9e 10 	movl   $0xc0109ebd,0xc(%esp)
c0105fd6:	c0 
c0105fd7:	c7 44 24 08 4e 9d 10 	movl   $0xc0109d4e,0x8(%esp)
c0105fde:	c0 
c0105fdf:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
c0105fe6:	00 
c0105fe7:	c7 04 24 e8 9c 10 c0 	movl   $0xc0109ce8,(%esp)
c0105fee:	e8 42 a4 ff ff       	call   c0100435 <__panic>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
c0105ff3:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
c0105ffa:	00 
c0105ffb:	c7 44 24 04 00 60 00 	movl   $0x6000,0x4(%esp)
c0106002:	00 
c0106003:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
c010600a:	e8 c3 ec ff ff       	call   c0104cd2 <vma_create>
c010600f:	89 45 dc             	mov    %eax,-0x24(%ebp)
     assert(vma != NULL);
c0106012:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0106016:	75 24                	jne    c010603c <check_swap+0x1e3>
c0106018:	c7 44 24 0c cb 9e 10 	movl   $0xc0109ecb,0xc(%esp)
c010601f:	c0 
c0106020:	c7 44 24 08 4e 9d 10 	movl   $0xc0109d4e,0x8(%esp)
c0106027:	c0 
c0106028:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
c010602f:	00 
c0106030:	c7 04 24 e8 9c 10 c0 	movl   $0xc0109ce8,(%esp)
c0106037:	e8 f9 a3 ff ff       	call   c0100435 <__panic>

     insert_vma_struct(mm, vma);
c010603c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010603f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106043:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106046:	89 04 24             	mov    %eax,(%esp)
c0106049:	e8 1d ee ff ff       	call   c0104e6b <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
c010604e:	c7 04 24 d8 9e 10 c0 	movl   $0xc0109ed8,(%esp)
c0106055:	e8 6f a2 ff ff       	call   c01002c9 <cprintf>
     pte_t *temp_ptep=NULL;
c010605a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
c0106061:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106064:	8b 40 0c             	mov    0xc(%eax),%eax
c0106067:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c010606e:	00 
c010606f:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0106076:	00 
c0106077:	89 04 24             	mov    %eax,(%esp)
c010607a:	e8 d3 da ff ff       	call   c0103b52 <get_pte>
c010607f:	89 45 d8             	mov    %eax,-0x28(%ebp)
     assert(temp_ptep!= NULL);
c0106082:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0106086:	75 24                	jne    c01060ac <check_swap+0x253>
c0106088:	c7 44 24 0c 0c 9f 10 	movl   $0xc0109f0c,0xc(%esp)
c010608f:	c0 
c0106090:	c7 44 24 08 4e 9d 10 	movl   $0xc0109d4e,0x8(%esp)
c0106097:	c0 
c0106098:	c7 44 24 04 d4 00 00 	movl   $0xd4,0x4(%esp)
c010609f:	00 
c01060a0:	c7 04 24 e8 9c 10 c0 	movl   $0xc0109ce8,(%esp)
c01060a7:	e8 89 a3 ff ff       	call   c0100435 <__panic>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
c01060ac:	c7 04 24 20 9f 10 c0 	movl   $0xc0109f20,(%esp)
c01060b3:	e8 11 a2 ff ff       	call   c01002c9 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01060b8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01060bf:	e9 a2 00 00 00       	jmp    c0106166 <check_swap+0x30d>
          check_rp[i] = alloc_page();
c01060c4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01060cb:	e8 b7 d3 ff ff       	call   c0103487 <alloc_pages>
c01060d0:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01060d3:	89 04 95 40 60 12 c0 	mov    %eax,-0x3fed9fc0(,%edx,4)
          assert(check_rp[i] != NULL );
c01060da:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01060dd:	8b 04 85 40 60 12 c0 	mov    -0x3fed9fc0(,%eax,4),%eax
c01060e4:	85 c0                	test   %eax,%eax
c01060e6:	75 24                	jne    c010610c <check_swap+0x2b3>
c01060e8:	c7 44 24 0c 44 9f 10 	movl   $0xc0109f44,0xc(%esp)
c01060ef:	c0 
c01060f0:	c7 44 24 08 4e 9d 10 	movl   $0xc0109d4e,0x8(%esp)
c01060f7:	c0 
c01060f8:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
c01060ff:	00 
c0106100:	c7 04 24 e8 9c 10 c0 	movl   $0xc0109ce8,(%esp)
c0106107:	e8 29 a3 ff ff       	call   c0100435 <__panic>
          assert(!PageProperty(check_rp[i]));
c010610c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010610f:	8b 04 85 40 60 12 c0 	mov    -0x3fed9fc0(,%eax,4),%eax
c0106116:	83 c0 04             	add    $0x4,%eax
c0106119:	c7 45 b4 01 00 00 00 	movl   $0x1,-0x4c(%ebp)
c0106120:	89 45 b0             	mov    %eax,-0x50(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106123:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0106126:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0106129:	0f a3 10             	bt     %edx,(%eax)
c010612c:	19 c0                	sbb    %eax,%eax
c010612e:	89 45 ac             	mov    %eax,-0x54(%ebp)
    return oldbit != 0;
c0106131:	83 7d ac 00          	cmpl   $0x0,-0x54(%ebp)
c0106135:	0f 95 c0             	setne  %al
c0106138:	0f b6 c0             	movzbl %al,%eax
c010613b:	85 c0                	test   %eax,%eax
c010613d:	74 24                	je     c0106163 <check_swap+0x30a>
c010613f:	c7 44 24 0c 58 9f 10 	movl   $0xc0109f58,0xc(%esp)
c0106146:	c0 
c0106147:	c7 44 24 08 4e 9d 10 	movl   $0xc0109d4e,0x8(%esp)
c010614e:	c0 
c010614f:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
c0106156:	00 
c0106157:	c7 04 24 e8 9c 10 c0 	movl   $0xc0109ce8,(%esp)
c010615e:	e8 d2 a2 ff ff       	call   c0100435 <__panic>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106163:	ff 45 ec             	incl   -0x14(%ebp)
c0106166:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c010616a:	0f 8e 54 ff ff ff    	jle    c01060c4 <check_swap+0x26b>
     }
     list_entry_t free_list_store = free_list;
c0106170:	a1 0c 61 12 c0       	mov    0xc012610c,%eax
c0106175:	8b 15 10 61 12 c0    	mov    0xc0126110,%edx
c010617b:	89 45 98             	mov    %eax,-0x68(%ebp)
c010617e:	89 55 9c             	mov    %edx,-0x64(%ebp)
c0106181:	c7 45 a4 0c 61 12 c0 	movl   $0xc012610c,-0x5c(%ebp)
    elm->prev = elm->next = elm;
c0106188:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c010618b:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c010618e:	89 50 04             	mov    %edx,0x4(%eax)
c0106191:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0106194:	8b 50 04             	mov    0x4(%eax),%edx
c0106197:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c010619a:	89 10                	mov    %edx,(%eax)
}
c010619c:	90                   	nop
c010619d:	c7 45 a8 0c 61 12 c0 	movl   $0xc012610c,-0x58(%ebp)
    return list->next == list;
c01061a4:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01061a7:	8b 40 04             	mov    0x4(%eax),%eax
c01061aa:	39 45 a8             	cmp    %eax,-0x58(%ebp)
c01061ad:	0f 94 c0             	sete   %al
c01061b0:	0f b6 c0             	movzbl %al,%eax
     list_init(&free_list);
     assert(list_empty(&free_list));
c01061b3:	85 c0                	test   %eax,%eax
c01061b5:	75 24                	jne    c01061db <check_swap+0x382>
c01061b7:	c7 44 24 0c 73 9f 10 	movl   $0xc0109f73,0xc(%esp)
c01061be:	c0 
c01061bf:	c7 44 24 08 4e 9d 10 	movl   $0xc0109d4e,0x8(%esp)
c01061c6:	c0 
c01061c7:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
c01061ce:	00 
c01061cf:	c7 04 24 e8 9c 10 c0 	movl   $0xc0109ce8,(%esp)
c01061d6:	e8 5a a2 ff ff       	call   c0100435 <__panic>
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
c01061db:	a1 14 61 12 c0       	mov    0xc0126114,%eax
c01061e0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
     nr_free = 0;
c01061e3:	c7 05 14 61 12 c0 00 	movl   $0x0,0xc0126114
c01061ea:	00 00 00 
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01061ed:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01061f4:	eb 1d                	jmp    c0106213 <check_swap+0x3ba>
        free_pages(check_rp[i],1);
c01061f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01061f9:	8b 04 85 40 60 12 c0 	mov    -0x3fed9fc0(,%eax,4),%eax
c0106200:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106207:	00 
c0106208:	89 04 24             	mov    %eax,(%esp)
c010620b:	e8 e6 d2 ff ff       	call   c01034f6 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106210:	ff 45 ec             	incl   -0x14(%ebp)
c0106213:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0106217:	7e dd                	jle    c01061f6 <check_swap+0x39d>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
c0106219:	a1 14 61 12 c0       	mov    0xc0126114,%eax
c010621e:	83 f8 04             	cmp    $0x4,%eax
c0106221:	74 24                	je     c0106247 <check_swap+0x3ee>
c0106223:	c7 44 24 0c 8c 9f 10 	movl   $0xc0109f8c,0xc(%esp)
c010622a:	c0 
c010622b:	c7 44 24 08 4e 9d 10 	movl   $0xc0109d4e,0x8(%esp)
c0106232:	c0 
c0106233:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
c010623a:	00 
c010623b:	c7 04 24 e8 9c 10 c0 	movl   $0xc0109ce8,(%esp)
c0106242:	e8 ee a1 ff ff       	call   c0100435 <__panic>
     
     cprintf("set up init env for check_swap begin!\n");
c0106247:	c7 04 24 b0 9f 10 c0 	movl   $0xc0109fb0,(%esp)
c010624e:	e8 76 a0 ff ff       	call   c01002c9 <cprintf>
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
c0106253:	c7 05 0c 60 12 c0 00 	movl   $0x0,0xc012600c
c010625a:	00 00 00 
     
     check_content_set();
c010625d:	e8 26 fa ff ff       	call   c0105c88 <check_content_set>
     assert( nr_free == 0);         
c0106262:	a1 14 61 12 c0       	mov    0xc0126114,%eax
c0106267:	85 c0                	test   %eax,%eax
c0106269:	74 24                	je     c010628f <check_swap+0x436>
c010626b:	c7 44 24 0c d7 9f 10 	movl   $0xc0109fd7,0xc(%esp)
c0106272:	c0 
c0106273:	c7 44 24 08 4e 9d 10 	movl   $0xc0109d4e,0x8(%esp)
c010627a:	c0 
c010627b:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
c0106282:	00 
c0106283:	c7 04 24 e8 9c 10 c0 	movl   $0xc0109ce8,(%esp)
c010628a:	e8 a6 a1 ff ff       	call   c0100435 <__panic>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c010628f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0106296:	eb 25                	jmp    c01062bd <check_swap+0x464>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
c0106298:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010629b:	c7 04 85 60 60 12 c0 	movl   $0xffffffff,-0x3fed9fa0(,%eax,4)
c01062a2:	ff ff ff ff 
c01062a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01062a9:	8b 14 85 60 60 12 c0 	mov    -0x3fed9fa0(,%eax,4),%edx
c01062b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01062b3:	89 14 85 a0 60 12 c0 	mov    %edx,-0x3fed9f60(,%eax,4)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c01062ba:	ff 45 ec             	incl   -0x14(%ebp)
c01062bd:	83 7d ec 09          	cmpl   $0x9,-0x14(%ebp)
c01062c1:	7e d5                	jle    c0106298 <check_swap+0x43f>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01062c3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01062ca:	e9 e8 00 00 00       	jmp    c01063b7 <check_swap+0x55e>
         check_ptep[i]=0;
c01062cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01062d2:	c7 04 85 f4 60 12 c0 	movl   $0x0,-0x3fed9f0c(,%eax,4)
c01062d9:	00 00 00 00 
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
c01062dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01062e0:	40                   	inc    %eax
c01062e1:	c1 e0 0c             	shl    $0xc,%eax
c01062e4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01062eb:	00 
c01062ec:	89 44 24 04          	mov    %eax,0x4(%esp)
c01062f0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01062f3:	89 04 24             	mov    %eax,(%esp)
c01062f6:	e8 57 d8 ff ff       	call   c0103b52 <get_pte>
c01062fb:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01062fe:	89 04 95 f4 60 12 c0 	mov    %eax,-0x3fed9f0c(,%edx,4)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
c0106305:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106308:	8b 04 85 f4 60 12 c0 	mov    -0x3fed9f0c(,%eax,4),%eax
c010630f:	85 c0                	test   %eax,%eax
c0106311:	75 24                	jne    c0106337 <check_swap+0x4de>
c0106313:	c7 44 24 0c e4 9f 10 	movl   $0xc0109fe4,0xc(%esp)
c010631a:	c0 
c010631b:	c7 44 24 08 4e 9d 10 	movl   $0xc0109d4e,0x8(%esp)
c0106322:	c0 
c0106323:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
c010632a:	00 
c010632b:	c7 04 24 e8 9c 10 c0 	movl   $0xc0109ce8,(%esp)
c0106332:	e8 fe a0 ff ff       	call   c0100435 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
c0106337:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010633a:	8b 04 85 f4 60 12 c0 	mov    -0x3fed9f0c(,%eax,4),%eax
c0106341:	8b 00                	mov    (%eax),%eax
c0106343:	89 04 24             	mov    %eax,(%esp)
c0106346:	e8 8b f5 ff ff       	call   c01058d6 <pte2page>
c010634b:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010634e:	8b 14 95 40 60 12 c0 	mov    -0x3fed9fc0(,%edx,4),%edx
c0106355:	39 d0                	cmp    %edx,%eax
c0106357:	74 24                	je     c010637d <check_swap+0x524>
c0106359:	c7 44 24 0c fc 9f 10 	movl   $0xc0109ffc,0xc(%esp)
c0106360:	c0 
c0106361:	c7 44 24 08 4e 9d 10 	movl   $0xc0109d4e,0x8(%esp)
c0106368:	c0 
c0106369:	c7 44 24 04 f9 00 00 	movl   $0xf9,0x4(%esp)
c0106370:	00 
c0106371:	c7 04 24 e8 9c 10 c0 	movl   $0xc0109ce8,(%esp)
c0106378:	e8 b8 a0 ff ff       	call   c0100435 <__panic>
         assert((*check_ptep[i] & PTE_P));          
c010637d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106380:	8b 04 85 f4 60 12 c0 	mov    -0x3fed9f0c(,%eax,4),%eax
c0106387:	8b 00                	mov    (%eax),%eax
c0106389:	83 e0 01             	and    $0x1,%eax
c010638c:	85 c0                	test   %eax,%eax
c010638e:	75 24                	jne    c01063b4 <check_swap+0x55b>
c0106390:	c7 44 24 0c 24 a0 10 	movl   $0xc010a024,0xc(%esp)
c0106397:	c0 
c0106398:	c7 44 24 08 4e 9d 10 	movl   $0xc0109d4e,0x8(%esp)
c010639f:	c0 
c01063a0:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c01063a7:	00 
c01063a8:	c7 04 24 e8 9c 10 c0 	movl   $0xc0109ce8,(%esp)
c01063af:	e8 81 a0 ff ff       	call   c0100435 <__panic>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01063b4:	ff 45 ec             	incl   -0x14(%ebp)
c01063b7:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c01063bb:	0f 8e 0e ff ff ff    	jle    c01062cf <check_swap+0x476>
     }
     cprintf("set up init env for check_swap over!\n");
c01063c1:	c7 04 24 40 a0 10 c0 	movl   $0xc010a040,(%esp)
c01063c8:	e8 fc 9e ff ff       	call   c01002c9 <cprintf>
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
c01063cd:	e8 6f fa ff ff       	call   c0105e41 <check_content_access>
c01063d2:	89 45 d0             	mov    %eax,-0x30(%ebp)
     assert(ret==0);
c01063d5:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c01063d9:	74 24                	je     c01063ff <check_swap+0x5a6>
c01063db:	c7 44 24 0c 66 a0 10 	movl   $0xc010a066,0xc(%esp)
c01063e2:	c0 
c01063e3:	c7 44 24 08 4e 9d 10 	movl   $0xc0109d4e,0x8(%esp)
c01063ea:	c0 
c01063eb:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
c01063f2:	00 
c01063f3:	c7 04 24 e8 9c 10 c0 	movl   $0xc0109ce8,(%esp)
c01063fa:	e8 36 a0 ff ff       	call   c0100435 <__panic>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01063ff:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0106406:	eb 1d                	jmp    c0106425 <check_swap+0x5cc>
         free_pages(check_rp[i],1);
c0106408:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010640b:	8b 04 85 40 60 12 c0 	mov    -0x3fed9fc0(,%eax,4),%eax
c0106412:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106419:	00 
c010641a:	89 04 24             	mov    %eax,(%esp)
c010641d:	e8 d4 d0 ff ff       	call   c01034f6 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106422:	ff 45 ec             	incl   -0x14(%ebp)
c0106425:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0106429:	7e dd                	jle    c0106408 <check_swap+0x5af>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
c010642b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010642e:	89 04 24             	mov    %eax,(%esp)
c0106431:	e8 6d eb ff ff       	call   c0104fa3 <mm_destroy>
         
     nr_free = nr_free_store;
c0106436:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0106439:	a3 14 61 12 c0       	mov    %eax,0xc0126114
     free_list = free_list_store;
c010643e:	8b 45 98             	mov    -0x68(%ebp),%eax
c0106441:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0106444:	a3 0c 61 12 c0       	mov    %eax,0xc012610c
c0106449:	89 15 10 61 12 c0    	mov    %edx,0xc0126110

     
     le = &free_list;
c010644f:	c7 45 e8 0c 61 12 c0 	movl   $0xc012610c,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c0106456:	eb 1c                	jmp    c0106474 <check_swap+0x61b>
         struct Page *p = le2page(le, page_link);
c0106458:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010645b:	83 e8 0c             	sub    $0xc,%eax
c010645e:	89 45 cc             	mov    %eax,-0x34(%ebp)
         count --, total -= p->property;
c0106461:	ff 4d f4             	decl   -0xc(%ebp)
c0106464:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0106467:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010646a:	8b 40 08             	mov    0x8(%eax),%eax
c010646d:	29 c2                	sub    %eax,%edx
c010646f:	89 d0                	mov    %edx,%eax
c0106471:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106474:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106477:	89 45 a0             	mov    %eax,-0x60(%ebp)
    return listelm->next;
c010647a:	8b 45 a0             	mov    -0x60(%ebp),%eax
c010647d:	8b 40 04             	mov    0x4(%eax),%eax
     while ((le = list_next(le)) != &free_list) {
c0106480:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106483:	81 7d e8 0c 61 12 c0 	cmpl   $0xc012610c,-0x18(%ebp)
c010648a:	75 cc                	jne    c0106458 <check_swap+0x5ff>
     }
     cprintf("count is %d, total is %d\n",count,total);
c010648c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010648f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106493:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106496:	89 44 24 04          	mov    %eax,0x4(%esp)
c010649a:	c7 04 24 6d a0 10 c0 	movl   $0xc010a06d,(%esp)
c01064a1:	e8 23 9e ff ff       	call   c01002c9 <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
c01064a6:	c7 04 24 87 a0 10 c0 	movl   $0xc010a087,(%esp)
c01064ad:	e8 17 9e ff ff       	call   c01002c9 <cprintf>
}
c01064b2:	90                   	nop
c01064b3:	c9                   	leave  
c01064b4:	c3                   	ret    

c01064b5 <_fifo_init_mm>:
 * (2) _fifo_init_mm: init pra_list_head and let  mm->sm_priv point to the addr of pra_list_head.
 *              Now, From the memory control struct mm_struct, we can access FIFO PRA
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
c01064b5:	f3 0f 1e fb          	endbr32 
c01064b9:	55                   	push   %ebp
c01064ba:	89 e5                	mov    %esp,%ebp
c01064bc:	83 ec 10             	sub    $0x10,%esp
c01064bf:	c7 45 fc 04 61 12 c0 	movl   $0xc0126104,-0x4(%ebp)
    elm->prev = elm->next = elm;
c01064c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01064c9:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01064cc:	89 50 04             	mov    %edx,0x4(%eax)
c01064cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01064d2:	8b 50 04             	mov    0x4(%eax),%edx
c01064d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01064d8:	89 10                	mov    %edx,(%eax)
}
c01064da:	90                   	nop
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
c01064db:	8b 45 08             	mov    0x8(%ebp),%eax
c01064de:	c7 40 14 04 61 12 c0 	movl   $0xc0126104,0x14(%eax)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
c01064e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01064ea:	c9                   	leave  
c01064eb:	c3                   	ret    

c01064ec <_fifo_map_swappable>:
/*
 * (3)_fifo_map_swappable: According FIFO PRA, we should link the most recent arrival page at the back of pra_list_head qeueue
 */
static int
_fifo_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c01064ec:	f3 0f 1e fb          	endbr32 
c01064f0:	55                   	push   %ebp
c01064f1:	89 e5                	mov    %esp,%ebp
c01064f3:	83 ec 28             	sub    $0x28,%esp
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
c01064f6:	8b 45 08             	mov    0x8(%ebp),%eax
c01064f9:	8b 40 14             	mov    0x14(%eax),%eax
c01064fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    list_entry_t *entry=&(page->pra_page_link);
c01064ff:	8b 45 10             	mov    0x10(%ebp),%eax
c0106502:	83 c0 14             	add    $0x14,%eax
c0106505:	89 45 f0             	mov    %eax,-0x10(%ebp)
 
    assert(entry != NULL && head != NULL);
c0106508:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010650c:	74 06                	je     c0106514 <_fifo_map_swappable+0x28>
c010650e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106512:	75 24                	jne    c0106538 <_fifo_map_swappable+0x4c>
c0106514:	c7 44 24 0c a0 a0 10 	movl   $0xc010a0a0,0xc(%esp)
c010651b:	c0 
c010651c:	c7 44 24 08 be a0 10 	movl   $0xc010a0be,0x8(%esp)
c0106523:	c0 
c0106524:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
c010652b:	00 
c010652c:	c7 04 24 d3 a0 10 c0 	movl   $0xc010a0d3,(%esp)
c0106533:	e8 fd 9e ff ff       	call   c0100435 <__panic>
    //record the page access situlation
    /*LAB3 EXERCISE 2: YOUR CODE*/ 
    //(1)link the most recent arrival page at the back of the pra_list_head qeueue.
    return 0;
c0106538:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010653d:	c9                   	leave  
c010653e:	c3                   	ret    

c010653f <_fifo_swap_out_victim>:
 *  (4)_fifo_swap_out_victim: According FIFO PRA, we should unlink the  earliest arrival page in front of pra_list_head qeueue,
 *                            then assign the value of *ptr_page to the addr of this page.
 */
static int
_fifo_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
c010653f:	f3 0f 1e fb          	endbr32 
c0106543:	55                   	push   %ebp
c0106544:	89 e5                	mov    %esp,%ebp
c0106546:	83 ec 28             	sub    $0x28,%esp
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
c0106549:	8b 45 08             	mov    0x8(%ebp),%eax
c010654c:	8b 40 14             	mov    0x14(%eax),%eax
c010654f:	89 45 f4             	mov    %eax,-0xc(%ebp)
         assert(head != NULL);
c0106552:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106556:	75 24                	jne    c010657c <_fifo_swap_out_victim+0x3d>
c0106558:	c7 44 24 0c e7 a0 10 	movl   $0xc010a0e7,0xc(%esp)
c010655f:	c0 
c0106560:	c7 44 24 08 be a0 10 	movl   $0xc010a0be,0x8(%esp)
c0106567:	c0 
c0106568:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
c010656f:	00 
c0106570:	c7 04 24 d3 a0 10 c0 	movl   $0xc010a0d3,(%esp)
c0106577:	e8 b9 9e ff ff       	call   c0100435 <__panic>
     assert(in_tick==0);
c010657c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106580:	74 24                	je     c01065a6 <_fifo_swap_out_victim+0x67>
c0106582:	c7 44 24 0c f4 a0 10 	movl   $0xc010a0f4,0xc(%esp)
c0106589:	c0 
c010658a:	c7 44 24 08 be a0 10 	movl   $0xc010a0be,0x8(%esp)
c0106591:	c0 
c0106592:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
c0106599:	00 
c010659a:	c7 04 24 d3 a0 10 c0 	movl   $0xc010a0d3,(%esp)
c01065a1:	e8 8f 9e ff ff       	call   c0100435 <__panic>
     /* Select the victim */
     /*LAB3 EXERCISE 2: YOUR CODE*/ 
     //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
     //(2)  assign the value of *ptr_page to the addr of this page
     return 0;
c01065a6:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01065ab:	c9                   	leave  
c01065ac:	c3                   	ret    

c01065ad <_fifo_check_swap>:

static int
_fifo_check_swap(void) {
c01065ad:	f3 0f 1e fb          	endbr32 
c01065b1:	55                   	push   %ebp
c01065b2:	89 e5                	mov    %esp,%ebp
c01065b4:	83 ec 18             	sub    $0x18,%esp
    cprintf("write Virt Page c in fifo_check_swap\n");
c01065b7:	c7 04 24 00 a1 10 c0 	movl   $0xc010a100,(%esp)
c01065be:	e8 06 9d ff ff       	call   c01002c9 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c01065c3:	b8 00 30 00 00       	mov    $0x3000,%eax
c01065c8:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==4);
c01065cb:	a1 0c 60 12 c0       	mov    0xc012600c,%eax
c01065d0:	83 f8 04             	cmp    $0x4,%eax
c01065d3:	74 24                	je     c01065f9 <_fifo_check_swap+0x4c>
c01065d5:	c7 44 24 0c 26 a1 10 	movl   $0xc010a126,0xc(%esp)
c01065dc:	c0 
c01065dd:	c7 44 24 08 be a0 10 	movl   $0xc010a0be,0x8(%esp)
c01065e4:	c0 
c01065e5:	c7 44 24 04 4d 00 00 	movl   $0x4d,0x4(%esp)
c01065ec:	00 
c01065ed:	c7 04 24 d3 a0 10 c0 	movl   $0xc010a0d3,(%esp)
c01065f4:	e8 3c 9e ff ff       	call   c0100435 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c01065f9:	c7 04 24 38 a1 10 c0 	movl   $0xc010a138,(%esp)
c0106600:	e8 c4 9c ff ff       	call   c01002c9 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c0106605:	b8 00 10 00 00       	mov    $0x1000,%eax
c010660a:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==4);
c010660d:	a1 0c 60 12 c0       	mov    0xc012600c,%eax
c0106612:	83 f8 04             	cmp    $0x4,%eax
c0106615:	74 24                	je     c010663b <_fifo_check_swap+0x8e>
c0106617:	c7 44 24 0c 26 a1 10 	movl   $0xc010a126,0xc(%esp)
c010661e:	c0 
c010661f:	c7 44 24 08 be a0 10 	movl   $0xc010a0be,0x8(%esp)
c0106626:	c0 
c0106627:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
c010662e:	00 
c010662f:	c7 04 24 d3 a0 10 c0 	movl   $0xc010a0d3,(%esp)
c0106636:	e8 fa 9d ff ff       	call   c0100435 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c010663b:	c7 04 24 60 a1 10 c0 	movl   $0xc010a160,(%esp)
c0106642:	e8 82 9c ff ff       	call   c01002c9 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c0106647:	b8 00 40 00 00       	mov    $0x4000,%eax
c010664c:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==4);
c010664f:	a1 0c 60 12 c0       	mov    0xc012600c,%eax
c0106654:	83 f8 04             	cmp    $0x4,%eax
c0106657:	74 24                	je     c010667d <_fifo_check_swap+0xd0>
c0106659:	c7 44 24 0c 26 a1 10 	movl   $0xc010a126,0xc(%esp)
c0106660:	c0 
c0106661:	c7 44 24 08 be a0 10 	movl   $0xc010a0be,0x8(%esp)
c0106668:	c0 
c0106669:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
c0106670:	00 
c0106671:	c7 04 24 d3 a0 10 c0 	movl   $0xc010a0d3,(%esp)
c0106678:	e8 b8 9d ff ff       	call   c0100435 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c010667d:	c7 04 24 88 a1 10 c0 	movl   $0xc010a188,(%esp)
c0106684:	e8 40 9c ff ff       	call   c01002c9 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0106689:	b8 00 20 00 00       	mov    $0x2000,%eax
c010668e:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==4);
c0106691:	a1 0c 60 12 c0       	mov    0xc012600c,%eax
c0106696:	83 f8 04             	cmp    $0x4,%eax
c0106699:	74 24                	je     c01066bf <_fifo_check_swap+0x112>
c010669b:	c7 44 24 0c 26 a1 10 	movl   $0xc010a126,0xc(%esp)
c01066a2:	c0 
c01066a3:	c7 44 24 08 be a0 10 	movl   $0xc010a0be,0x8(%esp)
c01066aa:	c0 
c01066ab:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
c01066b2:	00 
c01066b3:	c7 04 24 d3 a0 10 c0 	movl   $0xc010a0d3,(%esp)
c01066ba:	e8 76 9d ff ff       	call   c0100435 <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c01066bf:	c7 04 24 b0 a1 10 c0 	movl   $0xc010a1b0,(%esp)
c01066c6:	e8 fe 9b ff ff       	call   c01002c9 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c01066cb:	b8 00 50 00 00       	mov    $0x5000,%eax
c01066d0:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==5);
c01066d3:	a1 0c 60 12 c0       	mov    0xc012600c,%eax
c01066d8:	83 f8 05             	cmp    $0x5,%eax
c01066db:	74 24                	je     c0106701 <_fifo_check_swap+0x154>
c01066dd:	c7 44 24 0c d6 a1 10 	movl   $0xc010a1d6,0xc(%esp)
c01066e4:	c0 
c01066e5:	c7 44 24 08 be a0 10 	movl   $0xc010a0be,0x8(%esp)
c01066ec:	c0 
c01066ed:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
c01066f4:	00 
c01066f5:	c7 04 24 d3 a0 10 c0 	movl   $0xc010a0d3,(%esp)
c01066fc:	e8 34 9d ff ff       	call   c0100435 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0106701:	c7 04 24 88 a1 10 c0 	movl   $0xc010a188,(%esp)
c0106708:	e8 bc 9b ff ff       	call   c01002c9 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c010670d:	b8 00 20 00 00       	mov    $0x2000,%eax
c0106712:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==5);
c0106715:	a1 0c 60 12 c0       	mov    0xc012600c,%eax
c010671a:	83 f8 05             	cmp    $0x5,%eax
c010671d:	74 24                	je     c0106743 <_fifo_check_swap+0x196>
c010671f:	c7 44 24 0c d6 a1 10 	movl   $0xc010a1d6,0xc(%esp)
c0106726:	c0 
c0106727:	c7 44 24 08 be a0 10 	movl   $0xc010a0be,0x8(%esp)
c010672e:	c0 
c010672f:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
c0106736:	00 
c0106737:	c7 04 24 d3 a0 10 c0 	movl   $0xc010a0d3,(%esp)
c010673e:	e8 f2 9c ff ff       	call   c0100435 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0106743:	c7 04 24 38 a1 10 c0 	movl   $0xc010a138,(%esp)
c010674a:	e8 7a 9b ff ff       	call   c01002c9 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c010674f:	b8 00 10 00 00       	mov    $0x1000,%eax
c0106754:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==6);
c0106757:	a1 0c 60 12 c0       	mov    0xc012600c,%eax
c010675c:	83 f8 06             	cmp    $0x6,%eax
c010675f:	74 24                	je     c0106785 <_fifo_check_swap+0x1d8>
c0106761:	c7 44 24 0c e5 a1 10 	movl   $0xc010a1e5,0xc(%esp)
c0106768:	c0 
c0106769:	c7 44 24 08 be a0 10 	movl   $0xc010a0be,0x8(%esp)
c0106770:	c0 
c0106771:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
c0106778:	00 
c0106779:	c7 04 24 d3 a0 10 c0 	movl   $0xc010a0d3,(%esp)
c0106780:	e8 b0 9c ff ff       	call   c0100435 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0106785:	c7 04 24 88 a1 10 c0 	movl   $0xc010a188,(%esp)
c010678c:	e8 38 9b ff ff       	call   c01002c9 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0106791:	b8 00 20 00 00       	mov    $0x2000,%eax
c0106796:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==7);
c0106799:	a1 0c 60 12 c0       	mov    0xc012600c,%eax
c010679e:	83 f8 07             	cmp    $0x7,%eax
c01067a1:	74 24                	je     c01067c7 <_fifo_check_swap+0x21a>
c01067a3:	c7 44 24 0c f4 a1 10 	movl   $0xc010a1f4,0xc(%esp)
c01067aa:	c0 
c01067ab:	c7 44 24 08 be a0 10 	movl   $0xc010a0be,0x8(%esp)
c01067b2:	c0 
c01067b3:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
c01067ba:	00 
c01067bb:	c7 04 24 d3 a0 10 c0 	movl   $0xc010a0d3,(%esp)
c01067c2:	e8 6e 9c ff ff       	call   c0100435 <__panic>
    cprintf("write Virt Page c in fifo_check_swap\n");
c01067c7:	c7 04 24 00 a1 10 c0 	movl   $0xc010a100,(%esp)
c01067ce:	e8 f6 9a ff ff       	call   c01002c9 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c01067d3:	b8 00 30 00 00       	mov    $0x3000,%eax
c01067d8:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==8);
c01067db:	a1 0c 60 12 c0       	mov    0xc012600c,%eax
c01067e0:	83 f8 08             	cmp    $0x8,%eax
c01067e3:	74 24                	je     c0106809 <_fifo_check_swap+0x25c>
c01067e5:	c7 44 24 0c 03 a2 10 	movl   $0xc010a203,0xc(%esp)
c01067ec:	c0 
c01067ed:	c7 44 24 08 be a0 10 	movl   $0xc010a0be,0x8(%esp)
c01067f4:	c0 
c01067f5:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c01067fc:	00 
c01067fd:	c7 04 24 d3 a0 10 c0 	movl   $0xc010a0d3,(%esp)
c0106804:	e8 2c 9c ff ff       	call   c0100435 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c0106809:	c7 04 24 60 a1 10 c0 	movl   $0xc010a160,(%esp)
c0106810:	e8 b4 9a ff ff       	call   c01002c9 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c0106815:	b8 00 40 00 00       	mov    $0x4000,%eax
c010681a:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==9);
c010681d:	a1 0c 60 12 c0       	mov    0xc012600c,%eax
c0106822:	83 f8 09             	cmp    $0x9,%eax
c0106825:	74 24                	je     c010684b <_fifo_check_swap+0x29e>
c0106827:	c7 44 24 0c 12 a2 10 	movl   $0xc010a212,0xc(%esp)
c010682e:	c0 
c010682f:	c7 44 24 08 be a0 10 	movl   $0xc010a0be,0x8(%esp)
c0106836:	c0 
c0106837:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
c010683e:	00 
c010683f:	c7 04 24 d3 a0 10 c0 	movl   $0xc010a0d3,(%esp)
c0106846:	e8 ea 9b ff ff       	call   c0100435 <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c010684b:	c7 04 24 b0 a1 10 c0 	movl   $0xc010a1b0,(%esp)
c0106852:	e8 72 9a ff ff       	call   c01002c9 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c0106857:	b8 00 50 00 00       	mov    $0x5000,%eax
c010685c:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==10);
c010685f:	a1 0c 60 12 c0       	mov    0xc012600c,%eax
c0106864:	83 f8 0a             	cmp    $0xa,%eax
c0106867:	74 24                	je     c010688d <_fifo_check_swap+0x2e0>
c0106869:	c7 44 24 0c 21 a2 10 	movl   $0xc010a221,0xc(%esp)
c0106870:	c0 
c0106871:	c7 44 24 08 be a0 10 	movl   $0xc010a0be,0x8(%esp)
c0106878:	c0 
c0106879:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
c0106880:	00 
c0106881:	c7 04 24 d3 a0 10 c0 	movl   $0xc010a0d3,(%esp)
c0106888:	e8 a8 9b ff ff       	call   c0100435 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c010688d:	c7 04 24 38 a1 10 c0 	movl   $0xc010a138,(%esp)
c0106894:	e8 30 9a ff ff       	call   c01002c9 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
c0106899:	b8 00 10 00 00       	mov    $0x1000,%eax
c010689e:	0f b6 00             	movzbl (%eax),%eax
c01068a1:	3c 0a                	cmp    $0xa,%al
c01068a3:	74 24                	je     c01068c9 <_fifo_check_swap+0x31c>
c01068a5:	c7 44 24 0c 34 a2 10 	movl   $0xc010a234,0xc(%esp)
c01068ac:	c0 
c01068ad:	c7 44 24 08 be a0 10 	movl   $0xc010a0be,0x8(%esp)
c01068b4:	c0 
c01068b5:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c01068bc:	00 
c01068bd:	c7 04 24 d3 a0 10 c0 	movl   $0xc010a0d3,(%esp)
c01068c4:	e8 6c 9b ff ff       	call   c0100435 <__panic>
    *(unsigned char *)0x1000 = 0x0a;
c01068c9:	b8 00 10 00 00       	mov    $0x1000,%eax
c01068ce:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==11);
c01068d1:	a1 0c 60 12 c0       	mov    0xc012600c,%eax
c01068d6:	83 f8 0b             	cmp    $0xb,%eax
c01068d9:	74 24                	je     c01068ff <_fifo_check_swap+0x352>
c01068db:	c7 44 24 0c 55 a2 10 	movl   $0xc010a255,0xc(%esp)
c01068e2:	c0 
c01068e3:	c7 44 24 08 be a0 10 	movl   $0xc010a0be,0x8(%esp)
c01068ea:	c0 
c01068eb:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
c01068f2:	00 
c01068f3:	c7 04 24 d3 a0 10 c0 	movl   $0xc010a0d3,(%esp)
c01068fa:	e8 36 9b ff ff       	call   c0100435 <__panic>
    return 0;
c01068ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106904:	c9                   	leave  
c0106905:	c3                   	ret    

c0106906 <_fifo_init>:


static int
_fifo_init(void)
{
c0106906:	f3 0f 1e fb          	endbr32 
c010690a:	55                   	push   %ebp
c010690b:	89 e5                	mov    %esp,%ebp
    return 0;
c010690d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106912:	5d                   	pop    %ebp
c0106913:	c3                   	ret    

c0106914 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c0106914:	f3 0f 1e fb          	endbr32 
c0106918:	55                   	push   %ebp
c0106919:	89 e5                	mov    %esp,%ebp
    return 0;
c010691b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106920:	5d                   	pop    %ebp
c0106921:	c3                   	ret    

c0106922 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
c0106922:	f3 0f 1e fb          	endbr32 
c0106926:	55                   	push   %ebp
c0106927:	89 e5                	mov    %esp,%ebp
c0106929:	b8 00 00 00 00       	mov    $0x0,%eax
c010692e:	5d                   	pop    %ebp
c010692f:	c3                   	ret    

c0106930 <page2ppn>:
page2ppn(struct Page *page) {
c0106930:	55                   	push   %ebp
c0106931:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0106933:	a1 28 60 12 c0       	mov    0xc0126028,%eax
c0106938:	8b 55 08             	mov    0x8(%ebp),%edx
c010693b:	29 c2                	sub    %eax,%edx
c010693d:	89 d0                	mov    %edx,%eax
c010693f:	c1 f8 05             	sar    $0x5,%eax
}
c0106942:	5d                   	pop    %ebp
c0106943:	c3                   	ret    

c0106944 <page2pa>:
page2pa(struct Page *page) {
c0106944:	55                   	push   %ebp
c0106945:	89 e5                	mov    %esp,%ebp
c0106947:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c010694a:	8b 45 08             	mov    0x8(%ebp),%eax
c010694d:	89 04 24             	mov    %eax,(%esp)
c0106950:	e8 db ff ff ff       	call   c0106930 <page2ppn>
c0106955:	c1 e0 0c             	shl    $0xc,%eax
}
c0106958:	c9                   	leave  
c0106959:	c3                   	ret    

c010695a <page_ref>:
page_ref(struct Page *page) {
c010695a:	55                   	push   %ebp
c010695b:	89 e5                	mov    %esp,%ebp
    return page->ref;
c010695d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106960:	8b 00                	mov    (%eax),%eax
}
c0106962:	5d                   	pop    %ebp
c0106963:	c3                   	ret    

c0106964 <set_page_ref>:
set_page_ref(struct Page *page, int val) {
c0106964:	55                   	push   %ebp
c0106965:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0106967:	8b 45 08             	mov    0x8(%ebp),%eax
c010696a:	8b 55 0c             	mov    0xc(%ebp),%edx
c010696d:	89 10                	mov    %edx,(%eax)
}
c010696f:	90                   	nop
c0106970:	5d                   	pop    %ebp
c0106971:	c3                   	ret    

c0106972 <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c0106972:	f3 0f 1e fb          	endbr32 
c0106976:	55                   	push   %ebp
c0106977:	89 e5                	mov    %esp,%ebp
c0106979:	83 ec 10             	sub    $0x10,%esp
c010697c:	c7 45 fc 0c 61 12 c0 	movl   $0xc012610c,-0x4(%ebp)
    elm->prev = elm->next = elm;
c0106983:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106986:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0106989:	89 50 04             	mov    %edx,0x4(%eax)
c010698c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010698f:	8b 50 04             	mov    0x4(%eax),%edx
c0106992:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106995:	89 10                	mov    %edx,(%eax)
}
c0106997:	90                   	nop
    list_init(&free_list);
    nr_free = 0;
c0106998:	c7 05 14 61 12 c0 00 	movl   $0x0,0xc0126114
c010699f:	00 00 00 
}
c01069a2:	90                   	nop
c01069a3:	c9                   	leave  
c01069a4:	c3                   	ret    

c01069a5 <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c01069a5:	f3 0f 1e fb          	endbr32 
c01069a9:	55                   	push   %ebp
c01069aa:	89 e5                	mov    %esp,%ebp
c01069ac:	83 ec 58             	sub    $0x58,%esp
    assert(n > 0);
c01069af:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01069b3:	75 24                	jne    c01069d9 <default_init_memmap+0x34>
c01069b5:	c7 44 24 0c 78 a2 10 	movl   $0xc010a278,0xc(%esp)
c01069bc:	c0 
c01069bd:	c7 44 24 08 7e a2 10 	movl   $0xc010a27e,0x8(%esp)
c01069c4:	c0 
c01069c5:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c01069cc:	00 
c01069cd:	c7 04 24 93 a2 10 c0 	movl   $0xc010a293,(%esp)
c01069d4:	e8 5c 9a ff ff       	call   c0100435 <__panic>
    struct Page *p = base;
c01069d9:	8b 45 08             	mov    0x8(%ebp),%eax
c01069dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c01069df:	eb 7d                	jmp    c0106a5e <default_init_memmap+0xb9>
        assert(PageReserved(p));
c01069e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01069e4:	83 c0 04             	add    $0x4,%eax
c01069e7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c01069ee:	89 45 ec             	mov    %eax,-0x14(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01069f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01069f4:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01069f7:	0f a3 10             	bt     %edx,(%eax)
c01069fa:	19 c0                	sbb    %eax,%eax
c01069fc:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c01069ff:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0106a03:	0f 95 c0             	setne  %al
c0106a06:	0f b6 c0             	movzbl %al,%eax
c0106a09:	85 c0                	test   %eax,%eax
c0106a0b:	75 24                	jne    c0106a31 <default_init_memmap+0x8c>
c0106a0d:	c7 44 24 0c a9 a2 10 	movl   $0xc010a2a9,0xc(%esp)
c0106a14:	c0 
c0106a15:	c7 44 24 08 7e a2 10 	movl   $0xc010a27e,0x8(%esp)
c0106a1c:	c0 
c0106a1d:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c0106a24:	00 
c0106a25:	c7 04 24 93 a2 10 c0 	movl   $0xc010a293,(%esp)
c0106a2c:	e8 04 9a ff ff       	call   c0100435 <__panic>
        p->flags = p->property = 0;
c0106a31:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106a34:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c0106a3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106a3e:	8b 50 08             	mov    0x8(%eax),%edx
c0106a41:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106a44:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
c0106a47:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0106a4e:	00 
c0106a4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106a52:	89 04 24             	mov    %eax,(%esp)
c0106a55:	e8 0a ff ff ff       	call   c0106964 <set_page_ref>
    for (; p != base + n; p ++) {
c0106a5a:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c0106a5e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106a61:	c1 e0 05             	shl    $0x5,%eax
c0106a64:	89 c2                	mov    %eax,%edx
c0106a66:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a69:	01 d0                	add    %edx,%eax
c0106a6b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0106a6e:	0f 85 6d ff ff ff    	jne    c01069e1 <default_init_memmap+0x3c>
    }
    base->property = n;
c0106a74:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a77:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106a7a:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0106a7d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a80:	83 c0 04             	add    $0x4,%eax
c0106a83:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
c0106a8a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0106a8d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0106a90:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0106a93:	0f ab 10             	bts    %edx,(%eax)
}
c0106a96:	90                   	nop
    nr_free += n;
c0106a97:	8b 15 14 61 12 c0    	mov    0xc0126114,%edx
c0106a9d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106aa0:	01 d0                	add    %edx,%eax
c0106aa2:	a3 14 61 12 c0       	mov    %eax,0xc0126114
    list_add(&free_list, &(base->page_link));
c0106aa7:	8b 45 08             	mov    0x8(%ebp),%eax
c0106aaa:	83 c0 0c             	add    $0xc,%eax
c0106aad:	c7 45 e4 0c 61 12 c0 	movl   $0xc012610c,-0x1c(%ebp)
c0106ab4:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0106ab7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106aba:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0106abd:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106ac0:	89 45 d8             	mov    %eax,-0x28(%ebp)
    __list_add(elm, listelm, listelm->next);
c0106ac3:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106ac6:	8b 40 04             	mov    0x4(%eax),%eax
c0106ac9:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0106acc:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0106acf:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106ad2:	89 55 d0             	mov    %edx,-0x30(%ebp)
c0106ad5:	89 45 cc             	mov    %eax,-0x34(%ebp)
    prev->next = next->prev = elm;
c0106ad8:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0106adb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106ade:	89 10                	mov    %edx,(%eax)
c0106ae0:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0106ae3:	8b 10                	mov    (%eax),%edx
c0106ae5:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0106ae8:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0106aeb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0106aee:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0106af1:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0106af4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0106af7:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0106afa:	89 10                	mov    %edx,(%eax)
}
c0106afc:	90                   	nop
}
c0106afd:	90                   	nop
}
c0106afe:	90                   	nop
}
c0106aff:	90                   	nop
c0106b00:	c9                   	leave  
c0106b01:	c3                   	ret    

c0106b02 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c0106b02:	f3 0f 1e fb          	endbr32 
c0106b06:	55                   	push   %ebp
c0106b07:	89 e5                	mov    %esp,%ebp
c0106b09:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c0106b0c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0106b10:	75 24                	jne    c0106b36 <default_alloc_pages+0x34>
c0106b12:	c7 44 24 0c 78 a2 10 	movl   $0xc010a278,0xc(%esp)
c0106b19:	c0 
c0106b1a:	c7 44 24 08 7e a2 10 	movl   $0xc010a27e,0x8(%esp)
c0106b21:	c0 
c0106b22:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
c0106b29:	00 
c0106b2a:	c7 04 24 93 a2 10 c0 	movl   $0xc010a293,(%esp)
c0106b31:	e8 ff 98 ff ff       	call   c0100435 <__panic>
    if (n > nr_free) {
c0106b36:	a1 14 61 12 c0       	mov    0xc0126114,%eax
c0106b3b:	39 45 08             	cmp    %eax,0x8(%ebp)
c0106b3e:	76 0a                	jbe    c0106b4a <default_alloc_pages+0x48>
        return NULL;
c0106b40:	b8 00 00 00 00       	mov    $0x0,%eax
c0106b45:	e9 29 01 00 00       	jmp    c0106c73 <default_alloc_pages+0x171>
    }
    struct Page *page = NULL;
c0106b4a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
c0106b51:	c7 45 f0 0c 61 12 c0 	movl   $0xc012610c,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0106b58:	eb 1c                	jmp    c0106b76 <default_alloc_pages+0x74>
        struct Page *p = le2page(le, page_link);
c0106b5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106b5d:	83 e8 0c             	sub    $0xc,%eax
c0106b60:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
c0106b63:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106b66:	8b 40 08             	mov    0x8(%eax),%eax
c0106b69:	39 45 08             	cmp    %eax,0x8(%ebp)
c0106b6c:	77 08                	ja     c0106b76 <default_alloc_pages+0x74>
            page = p;
c0106b6e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106b71:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
c0106b74:	eb 18                	jmp    c0106b8e <default_alloc_pages+0x8c>
c0106b76:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106b79:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->next;
c0106b7c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106b7f:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0106b82:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106b85:	81 7d f0 0c 61 12 c0 	cmpl   $0xc012610c,-0x10(%ebp)
c0106b8c:	75 cc                	jne    c0106b5a <default_alloc_pages+0x58>
        }
    }
    if (page != NULL) {
c0106b8e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106b92:	0f 84 d8 00 00 00    	je     c0106c70 <default_alloc_pages+0x16e>
        list_del(&(page->page_link));
c0106b98:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106b9b:	83 c0 0c             	add    $0xc,%eax
c0106b9e:	89 45 e0             	mov    %eax,-0x20(%ebp)
    __list_del(listelm->prev, listelm->next);
c0106ba1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106ba4:	8b 40 04             	mov    0x4(%eax),%eax
c0106ba7:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106baa:	8b 12                	mov    (%edx),%edx
c0106bac:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0106baf:	89 45 d8             	mov    %eax,-0x28(%ebp)
    prev->next = next;
c0106bb2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106bb5:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0106bb8:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0106bbb:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0106bbe:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106bc1:	89 10                	mov    %edx,(%eax)
}
c0106bc3:	90                   	nop
}
c0106bc4:	90                   	nop
        if (page->property > n) {
c0106bc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106bc8:	8b 40 08             	mov    0x8(%eax),%eax
c0106bcb:	39 45 08             	cmp    %eax,0x8(%ebp)
c0106bce:	73 79                	jae    c0106c49 <default_alloc_pages+0x147>
            struct Page *p = page + n;
c0106bd0:	8b 45 08             	mov    0x8(%ebp),%eax
c0106bd3:	c1 e0 05             	shl    $0x5,%eax
c0106bd6:	89 c2                	mov    %eax,%edx
c0106bd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106bdb:	01 d0                	add    %edx,%eax
c0106bdd:	89 45 e8             	mov    %eax,-0x18(%ebp)
            p->property = page->property - n;
c0106be0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106be3:	8b 40 08             	mov    0x8(%eax),%eax
c0106be6:	2b 45 08             	sub    0x8(%ebp),%eax
c0106be9:	89 c2                	mov    %eax,%edx
c0106beb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106bee:	89 50 08             	mov    %edx,0x8(%eax)
            list_add(&free_list, &(p->page_link));
c0106bf1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106bf4:	83 c0 0c             	add    $0xc,%eax
c0106bf7:	c7 45 d4 0c 61 12 c0 	movl   $0xc012610c,-0x2c(%ebp)
c0106bfe:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0106c01:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0106c04:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0106c07:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0106c0a:	89 45 c8             	mov    %eax,-0x38(%ebp)
    __list_add(elm, listelm, listelm->next);
c0106c0d:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0106c10:	8b 40 04             	mov    0x4(%eax),%eax
c0106c13:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0106c16:	89 55 c4             	mov    %edx,-0x3c(%ebp)
c0106c19:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0106c1c:	89 55 c0             	mov    %edx,-0x40(%ebp)
c0106c1f:	89 45 bc             	mov    %eax,-0x44(%ebp)
    prev->next = next->prev = elm;
c0106c22:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0106c25:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0106c28:	89 10                	mov    %edx,(%eax)
c0106c2a:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0106c2d:	8b 10                	mov    (%eax),%edx
c0106c2f:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0106c32:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0106c35:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0106c38:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0106c3b:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0106c3e:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0106c41:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0106c44:	89 10                	mov    %edx,(%eax)
}
c0106c46:	90                   	nop
}
c0106c47:	90                   	nop
}
c0106c48:	90                   	nop
    }
        nr_free -= n;
c0106c49:	a1 14 61 12 c0       	mov    0xc0126114,%eax
c0106c4e:	2b 45 08             	sub    0x8(%ebp),%eax
c0106c51:	a3 14 61 12 c0       	mov    %eax,0xc0126114
        ClearPageProperty(page);
c0106c56:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106c59:	83 c0 04             	add    $0x4,%eax
c0106c5c:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
c0106c63:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0106c66:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0106c69:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0106c6c:	0f b3 10             	btr    %edx,(%eax)
}
c0106c6f:	90                   	nop
    }
    return page;
c0106c70:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106c73:	c9                   	leave  
c0106c74:	c3                   	ret    

c0106c75 <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c0106c75:	f3 0f 1e fb          	endbr32 
c0106c79:	55                   	push   %ebp
c0106c7a:	89 e5                	mov    %esp,%ebp
c0106c7c:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
c0106c82:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0106c86:	75 24                	jne    c0106cac <default_free_pages+0x37>
c0106c88:	c7 44 24 0c 78 a2 10 	movl   $0xc010a278,0xc(%esp)
c0106c8f:	c0 
c0106c90:	c7 44 24 08 7e a2 10 	movl   $0xc010a27e,0x8(%esp)
c0106c97:	c0 
c0106c98:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
c0106c9f:	00 
c0106ca0:	c7 04 24 93 a2 10 c0 	movl   $0xc010a293,(%esp)
c0106ca7:	e8 89 97 ff ff       	call   c0100435 <__panic>
    struct Page *p = base;
c0106cac:	8b 45 08             	mov    0x8(%ebp),%eax
c0106caf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c0106cb2:	e9 9d 00 00 00       	jmp    c0106d54 <default_free_pages+0xdf>
        assert(!PageReserved(p) && !PageProperty(p));
c0106cb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106cba:	83 c0 04             	add    $0x4,%eax
c0106cbd:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0106cc4:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106cc7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106cca:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106ccd:	0f a3 10             	bt     %edx,(%eax)
c0106cd0:	19 c0                	sbb    %eax,%eax
c0106cd2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c0106cd5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106cd9:	0f 95 c0             	setne  %al
c0106cdc:	0f b6 c0             	movzbl %al,%eax
c0106cdf:	85 c0                	test   %eax,%eax
c0106ce1:	75 2c                	jne    c0106d0f <default_free_pages+0x9a>
c0106ce3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106ce6:	83 c0 04             	add    $0x4,%eax
c0106ce9:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c0106cf0:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106cf3:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106cf6:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106cf9:	0f a3 10             	bt     %edx,(%eax)
c0106cfc:	19 c0                	sbb    %eax,%eax
c0106cfe:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
c0106d01:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0106d05:	0f 95 c0             	setne  %al
c0106d08:	0f b6 c0             	movzbl %al,%eax
c0106d0b:	85 c0                	test   %eax,%eax
c0106d0d:	74 24                	je     c0106d33 <default_free_pages+0xbe>
c0106d0f:	c7 44 24 0c bc a2 10 	movl   $0xc010a2bc,0xc(%esp)
c0106d16:	c0 
c0106d17:	c7 44 24 08 7e a2 10 	movl   $0xc010a27e,0x8(%esp)
c0106d1e:	c0 
c0106d1f:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
c0106d26:	00 
c0106d27:	c7 04 24 93 a2 10 c0 	movl   $0xc010a293,(%esp)
c0106d2e:	e8 02 97 ff ff       	call   c0100435 <__panic>
        p->flags = 0;
c0106d33:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106d36:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c0106d3d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0106d44:	00 
c0106d45:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106d48:	89 04 24             	mov    %eax,(%esp)
c0106d4b:	e8 14 fc ff ff       	call   c0106964 <set_page_ref>
    for (; p != base + n; p ++) {
c0106d50:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c0106d54:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106d57:	c1 e0 05             	shl    $0x5,%eax
c0106d5a:	89 c2                	mov    %eax,%edx
c0106d5c:	8b 45 08             	mov    0x8(%ebp),%eax
c0106d5f:	01 d0                	add    %edx,%eax
c0106d61:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0106d64:	0f 85 4d ff ff ff    	jne    c0106cb7 <default_free_pages+0x42>
    }
    base->property = n;
c0106d6a:	8b 45 08             	mov    0x8(%ebp),%eax
c0106d6d:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106d70:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0106d73:	8b 45 08             	mov    0x8(%ebp),%eax
c0106d76:	83 c0 04             	add    $0x4,%eax
c0106d79:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0106d80:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0106d83:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0106d86:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0106d89:	0f ab 10             	bts    %edx,(%eax)
}
c0106d8c:	90                   	nop
c0106d8d:	c7 45 d4 0c 61 12 c0 	movl   $0xc012610c,-0x2c(%ebp)
    return listelm->next;
c0106d94:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0106d97:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
c0106d9a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c0106d9d:	e9 00 01 00 00       	jmp    c0106ea2 <default_free_pages+0x22d>
        p = le2page(le, page_link);
c0106da2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106da5:	83 e8 0c             	sub    $0xc,%eax
c0106da8:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106dab:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106dae:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0106db1:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0106db4:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0106db7:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (base + base->property == p) {
c0106dba:	8b 45 08             	mov    0x8(%ebp),%eax
c0106dbd:	8b 40 08             	mov    0x8(%eax),%eax
c0106dc0:	c1 e0 05             	shl    $0x5,%eax
c0106dc3:	89 c2                	mov    %eax,%edx
c0106dc5:	8b 45 08             	mov    0x8(%ebp),%eax
c0106dc8:	01 d0                	add    %edx,%eax
c0106dca:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0106dcd:	75 5d                	jne    c0106e2c <default_free_pages+0x1b7>
            base->property += p->property;
c0106dcf:	8b 45 08             	mov    0x8(%ebp),%eax
c0106dd2:	8b 50 08             	mov    0x8(%eax),%edx
c0106dd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106dd8:	8b 40 08             	mov    0x8(%eax),%eax
c0106ddb:	01 c2                	add    %eax,%edx
c0106ddd:	8b 45 08             	mov    0x8(%ebp),%eax
c0106de0:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
c0106de3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106de6:	83 c0 04             	add    $0x4,%eax
c0106de9:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
c0106df0:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0106df3:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0106df6:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0106df9:	0f b3 10             	btr    %edx,(%eax)
}
c0106dfc:	90                   	nop
            list_del(&(p->page_link));
c0106dfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106e00:	83 c0 0c             	add    $0xc,%eax
c0106e03:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    __list_del(listelm->prev, listelm->next);
c0106e06:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0106e09:	8b 40 04             	mov    0x4(%eax),%eax
c0106e0c:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0106e0f:	8b 12                	mov    (%edx),%edx
c0106e11:	89 55 c0             	mov    %edx,-0x40(%ebp)
c0106e14:	89 45 bc             	mov    %eax,-0x44(%ebp)
    prev->next = next;
c0106e17:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0106e1a:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0106e1d:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0106e20:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0106e23:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0106e26:	89 10                	mov    %edx,(%eax)
}
c0106e28:	90                   	nop
}
c0106e29:	90                   	nop
c0106e2a:	eb 76                	jmp    c0106ea2 <default_free_pages+0x22d>
        }
        else if (p + p->property == base) {
c0106e2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106e2f:	8b 40 08             	mov    0x8(%eax),%eax
c0106e32:	c1 e0 05             	shl    $0x5,%eax
c0106e35:	89 c2                	mov    %eax,%edx
c0106e37:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106e3a:	01 d0                	add    %edx,%eax
c0106e3c:	39 45 08             	cmp    %eax,0x8(%ebp)
c0106e3f:	75 61                	jne    c0106ea2 <default_free_pages+0x22d>
            p->property += base->property;
c0106e41:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106e44:	8b 50 08             	mov    0x8(%eax),%edx
c0106e47:	8b 45 08             	mov    0x8(%ebp),%eax
c0106e4a:	8b 40 08             	mov    0x8(%eax),%eax
c0106e4d:	01 c2                	add    %eax,%edx
c0106e4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106e52:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
c0106e55:	8b 45 08             	mov    0x8(%ebp),%eax
c0106e58:	83 c0 04             	add    $0x4,%eax
c0106e5b:	c7 45 a4 01 00 00 00 	movl   $0x1,-0x5c(%ebp)
c0106e62:	89 45 a0             	mov    %eax,-0x60(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0106e65:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0106e68:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0106e6b:	0f b3 10             	btr    %edx,(%eax)
}
c0106e6e:	90                   	nop
            base = p;
c0106e6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106e72:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
c0106e75:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106e78:	83 c0 0c             	add    $0xc,%eax
c0106e7b:	89 45 b0             	mov    %eax,-0x50(%ebp)
    __list_del(listelm->prev, listelm->next);
c0106e7e:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0106e81:	8b 40 04             	mov    0x4(%eax),%eax
c0106e84:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0106e87:	8b 12                	mov    (%edx),%edx
c0106e89:	89 55 ac             	mov    %edx,-0x54(%ebp)
c0106e8c:	89 45 a8             	mov    %eax,-0x58(%ebp)
    prev->next = next;
c0106e8f:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0106e92:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0106e95:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0106e98:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0106e9b:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0106e9e:	89 10                	mov    %edx,(%eax)
}
c0106ea0:	90                   	nop
}
c0106ea1:	90                   	nop
    while (le != &free_list) {
c0106ea2:	81 7d f0 0c 61 12 c0 	cmpl   $0xc012610c,-0x10(%ebp)
c0106ea9:	0f 85 f3 fe ff ff    	jne    c0106da2 <default_free_pages+0x12d>
        }
    }
    nr_free += n;
c0106eaf:	8b 15 14 61 12 c0    	mov    0xc0126114,%edx
c0106eb5:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106eb8:	01 d0                	add    %edx,%eax
c0106eba:	a3 14 61 12 c0       	mov    %eax,0xc0126114
    list_add(&free_list, &(base->page_link));
c0106ebf:	8b 45 08             	mov    0x8(%ebp),%eax
c0106ec2:	83 c0 0c             	add    $0xc,%eax
c0106ec5:	c7 45 9c 0c 61 12 c0 	movl   $0xc012610c,-0x64(%ebp)
c0106ecc:	89 45 98             	mov    %eax,-0x68(%ebp)
c0106ecf:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0106ed2:	89 45 94             	mov    %eax,-0x6c(%ebp)
c0106ed5:	8b 45 98             	mov    -0x68(%ebp),%eax
c0106ed8:	89 45 90             	mov    %eax,-0x70(%ebp)
    __list_add(elm, listelm, listelm->next);
c0106edb:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0106ede:	8b 40 04             	mov    0x4(%eax),%eax
c0106ee1:	8b 55 90             	mov    -0x70(%ebp),%edx
c0106ee4:	89 55 8c             	mov    %edx,-0x74(%ebp)
c0106ee7:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0106eea:	89 55 88             	mov    %edx,-0x78(%ebp)
c0106eed:	89 45 84             	mov    %eax,-0x7c(%ebp)
    prev->next = next->prev = elm;
c0106ef0:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0106ef3:	8b 55 8c             	mov    -0x74(%ebp),%edx
c0106ef6:	89 10                	mov    %edx,(%eax)
c0106ef8:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0106efb:	8b 10                	mov    (%eax),%edx
c0106efd:	8b 45 88             	mov    -0x78(%ebp),%eax
c0106f00:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0106f03:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0106f06:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0106f09:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0106f0c:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0106f0f:	8b 55 88             	mov    -0x78(%ebp),%edx
c0106f12:	89 10                	mov    %edx,(%eax)
}
c0106f14:	90                   	nop
}
c0106f15:	90                   	nop
}
c0106f16:	90                   	nop
}
c0106f17:	90                   	nop
c0106f18:	c9                   	leave  
c0106f19:	c3                   	ret    

c0106f1a <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c0106f1a:	f3 0f 1e fb          	endbr32 
c0106f1e:	55                   	push   %ebp
c0106f1f:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0106f21:	a1 14 61 12 c0       	mov    0xc0126114,%eax
}
c0106f26:	5d                   	pop    %ebp
c0106f27:	c3                   	ret    

c0106f28 <basic_check>:

static void
basic_check(void) {
c0106f28:	f3 0f 1e fb          	endbr32 
c0106f2c:	55                   	push   %ebp
c0106f2d:	89 e5                	mov    %esp,%ebp
c0106f2f:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0106f32:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0106f39:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106f3c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106f3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106f42:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0106f45:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106f4c:	e8 36 c5 ff ff       	call   c0103487 <alloc_pages>
c0106f51:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106f54:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0106f58:	75 24                	jne    c0106f7e <basic_check+0x56>
c0106f5a:	c7 44 24 0c e1 a2 10 	movl   $0xc010a2e1,0xc(%esp)
c0106f61:	c0 
c0106f62:	c7 44 24 08 7e a2 10 	movl   $0xc010a27e,0x8(%esp)
c0106f69:	c0 
c0106f6a:	c7 44 24 04 be 00 00 	movl   $0xbe,0x4(%esp)
c0106f71:	00 
c0106f72:	c7 04 24 93 a2 10 c0 	movl   $0xc010a293,(%esp)
c0106f79:	e8 b7 94 ff ff       	call   c0100435 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0106f7e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106f85:	e8 fd c4 ff ff       	call   c0103487 <alloc_pages>
c0106f8a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106f8d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0106f91:	75 24                	jne    c0106fb7 <basic_check+0x8f>
c0106f93:	c7 44 24 0c fd a2 10 	movl   $0xc010a2fd,0xc(%esp)
c0106f9a:	c0 
c0106f9b:	c7 44 24 08 7e a2 10 	movl   $0xc010a27e,0x8(%esp)
c0106fa2:	c0 
c0106fa3:	c7 44 24 04 bf 00 00 	movl   $0xbf,0x4(%esp)
c0106faa:	00 
c0106fab:	c7 04 24 93 a2 10 c0 	movl   $0xc010a293,(%esp)
c0106fb2:	e8 7e 94 ff ff       	call   c0100435 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0106fb7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106fbe:	e8 c4 c4 ff ff       	call   c0103487 <alloc_pages>
c0106fc3:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106fc6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106fca:	75 24                	jne    c0106ff0 <basic_check+0xc8>
c0106fcc:	c7 44 24 0c 19 a3 10 	movl   $0xc010a319,0xc(%esp)
c0106fd3:	c0 
c0106fd4:	c7 44 24 08 7e a2 10 	movl   $0xc010a27e,0x8(%esp)
c0106fdb:	c0 
c0106fdc:	c7 44 24 04 c0 00 00 	movl   $0xc0,0x4(%esp)
c0106fe3:	00 
c0106fe4:	c7 04 24 93 a2 10 c0 	movl   $0xc010a293,(%esp)
c0106feb:	e8 45 94 ff ff       	call   c0100435 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0106ff0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106ff3:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0106ff6:	74 10                	je     c0107008 <basic_check+0xe0>
c0106ff8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106ffb:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0106ffe:	74 08                	je     c0107008 <basic_check+0xe0>
c0107000:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107003:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0107006:	75 24                	jne    c010702c <basic_check+0x104>
c0107008:	c7 44 24 0c 38 a3 10 	movl   $0xc010a338,0xc(%esp)
c010700f:	c0 
c0107010:	c7 44 24 08 7e a2 10 	movl   $0xc010a27e,0x8(%esp)
c0107017:	c0 
c0107018:	c7 44 24 04 c2 00 00 	movl   $0xc2,0x4(%esp)
c010701f:	00 
c0107020:	c7 04 24 93 a2 10 c0 	movl   $0xc010a293,(%esp)
c0107027:	e8 09 94 ff ff       	call   c0100435 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c010702c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010702f:	89 04 24             	mov    %eax,(%esp)
c0107032:	e8 23 f9 ff ff       	call   c010695a <page_ref>
c0107037:	85 c0                	test   %eax,%eax
c0107039:	75 1e                	jne    c0107059 <basic_check+0x131>
c010703b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010703e:	89 04 24             	mov    %eax,(%esp)
c0107041:	e8 14 f9 ff ff       	call   c010695a <page_ref>
c0107046:	85 c0                	test   %eax,%eax
c0107048:	75 0f                	jne    c0107059 <basic_check+0x131>
c010704a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010704d:	89 04 24             	mov    %eax,(%esp)
c0107050:	e8 05 f9 ff ff       	call   c010695a <page_ref>
c0107055:	85 c0                	test   %eax,%eax
c0107057:	74 24                	je     c010707d <basic_check+0x155>
c0107059:	c7 44 24 0c 5c a3 10 	movl   $0xc010a35c,0xc(%esp)
c0107060:	c0 
c0107061:	c7 44 24 08 7e a2 10 	movl   $0xc010a27e,0x8(%esp)
c0107068:	c0 
c0107069:	c7 44 24 04 c3 00 00 	movl   $0xc3,0x4(%esp)
c0107070:	00 
c0107071:	c7 04 24 93 a2 10 c0 	movl   $0xc010a293,(%esp)
c0107078:	e8 b8 93 ff ff       	call   c0100435 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c010707d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107080:	89 04 24             	mov    %eax,(%esp)
c0107083:	e8 bc f8 ff ff       	call   c0106944 <page2pa>
c0107088:	8b 15 80 5f 12 c0    	mov    0xc0125f80,%edx
c010708e:	c1 e2 0c             	shl    $0xc,%edx
c0107091:	39 d0                	cmp    %edx,%eax
c0107093:	72 24                	jb     c01070b9 <basic_check+0x191>
c0107095:	c7 44 24 0c 98 a3 10 	movl   $0xc010a398,0xc(%esp)
c010709c:	c0 
c010709d:	c7 44 24 08 7e a2 10 	movl   $0xc010a27e,0x8(%esp)
c01070a4:	c0 
c01070a5:	c7 44 24 04 c5 00 00 	movl   $0xc5,0x4(%esp)
c01070ac:	00 
c01070ad:	c7 04 24 93 a2 10 c0 	movl   $0xc010a293,(%esp)
c01070b4:	e8 7c 93 ff ff       	call   c0100435 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c01070b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01070bc:	89 04 24             	mov    %eax,(%esp)
c01070bf:	e8 80 f8 ff ff       	call   c0106944 <page2pa>
c01070c4:	8b 15 80 5f 12 c0    	mov    0xc0125f80,%edx
c01070ca:	c1 e2 0c             	shl    $0xc,%edx
c01070cd:	39 d0                	cmp    %edx,%eax
c01070cf:	72 24                	jb     c01070f5 <basic_check+0x1cd>
c01070d1:	c7 44 24 0c b5 a3 10 	movl   $0xc010a3b5,0xc(%esp)
c01070d8:	c0 
c01070d9:	c7 44 24 08 7e a2 10 	movl   $0xc010a27e,0x8(%esp)
c01070e0:	c0 
c01070e1:	c7 44 24 04 c6 00 00 	movl   $0xc6,0x4(%esp)
c01070e8:	00 
c01070e9:	c7 04 24 93 a2 10 c0 	movl   $0xc010a293,(%esp)
c01070f0:	e8 40 93 ff ff       	call   c0100435 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c01070f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01070f8:	89 04 24             	mov    %eax,(%esp)
c01070fb:	e8 44 f8 ff ff       	call   c0106944 <page2pa>
c0107100:	8b 15 80 5f 12 c0    	mov    0xc0125f80,%edx
c0107106:	c1 e2 0c             	shl    $0xc,%edx
c0107109:	39 d0                	cmp    %edx,%eax
c010710b:	72 24                	jb     c0107131 <basic_check+0x209>
c010710d:	c7 44 24 0c d2 a3 10 	movl   $0xc010a3d2,0xc(%esp)
c0107114:	c0 
c0107115:	c7 44 24 08 7e a2 10 	movl   $0xc010a27e,0x8(%esp)
c010711c:	c0 
c010711d:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
c0107124:	00 
c0107125:	c7 04 24 93 a2 10 c0 	movl   $0xc010a293,(%esp)
c010712c:	e8 04 93 ff ff       	call   c0100435 <__panic>

    list_entry_t free_list_store = free_list;
c0107131:	a1 0c 61 12 c0       	mov    0xc012610c,%eax
c0107136:	8b 15 10 61 12 c0    	mov    0xc0126110,%edx
c010713c:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010713f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0107142:	c7 45 dc 0c 61 12 c0 	movl   $0xc012610c,-0x24(%ebp)
    elm->prev = elm->next = elm;
c0107149:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010714c:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010714f:	89 50 04             	mov    %edx,0x4(%eax)
c0107152:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107155:	8b 50 04             	mov    0x4(%eax),%edx
c0107158:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010715b:	89 10                	mov    %edx,(%eax)
}
c010715d:	90                   	nop
c010715e:	c7 45 e0 0c 61 12 c0 	movl   $0xc012610c,-0x20(%ebp)
    return list->next == list;
c0107165:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107168:	8b 40 04             	mov    0x4(%eax),%eax
c010716b:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c010716e:	0f 94 c0             	sete   %al
c0107171:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0107174:	85 c0                	test   %eax,%eax
c0107176:	75 24                	jne    c010719c <basic_check+0x274>
c0107178:	c7 44 24 0c ef a3 10 	movl   $0xc010a3ef,0xc(%esp)
c010717f:	c0 
c0107180:	c7 44 24 08 7e a2 10 	movl   $0xc010a27e,0x8(%esp)
c0107187:	c0 
c0107188:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
c010718f:	00 
c0107190:	c7 04 24 93 a2 10 c0 	movl   $0xc010a293,(%esp)
c0107197:	e8 99 92 ff ff       	call   c0100435 <__panic>

    unsigned int nr_free_store = nr_free;
c010719c:	a1 14 61 12 c0       	mov    0xc0126114,%eax
c01071a1:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c01071a4:	c7 05 14 61 12 c0 00 	movl   $0x0,0xc0126114
c01071ab:	00 00 00 

    assert(alloc_page() == NULL);
c01071ae:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01071b5:	e8 cd c2 ff ff       	call   c0103487 <alloc_pages>
c01071ba:	85 c0                	test   %eax,%eax
c01071bc:	74 24                	je     c01071e2 <basic_check+0x2ba>
c01071be:	c7 44 24 0c 06 a4 10 	movl   $0xc010a406,0xc(%esp)
c01071c5:	c0 
c01071c6:	c7 44 24 08 7e a2 10 	movl   $0xc010a27e,0x8(%esp)
c01071cd:	c0 
c01071ce:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
c01071d5:	00 
c01071d6:	c7 04 24 93 a2 10 c0 	movl   $0xc010a293,(%esp)
c01071dd:	e8 53 92 ff ff       	call   c0100435 <__panic>

    free_page(p0);
c01071e2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01071e9:	00 
c01071ea:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01071ed:	89 04 24             	mov    %eax,(%esp)
c01071f0:	e8 01 c3 ff ff       	call   c01034f6 <free_pages>
    free_page(p1);
c01071f5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01071fc:	00 
c01071fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107200:	89 04 24             	mov    %eax,(%esp)
c0107203:	e8 ee c2 ff ff       	call   c01034f6 <free_pages>
    free_page(p2);
c0107208:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010720f:	00 
c0107210:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107213:	89 04 24             	mov    %eax,(%esp)
c0107216:	e8 db c2 ff ff       	call   c01034f6 <free_pages>
    assert(nr_free == 3);
c010721b:	a1 14 61 12 c0       	mov    0xc0126114,%eax
c0107220:	83 f8 03             	cmp    $0x3,%eax
c0107223:	74 24                	je     c0107249 <basic_check+0x321>
c0107225:	c7 44 24 0c 1b a4 10 	movl   $0xc010a41b,0xc(%esp)
c010722c:	c0 
c010722d:	c7 44 24 08 7e a2 10 	movl   $0xc010a27e,0x8(%esp)
c0107234:	c0 
c0107235:	c7 44 24 04 d5 00 00 	movl   $0xd5,0x4(%esp)
c010723c:	00 
c010723d:	c7 04 24 93 a2 10 c0 	movl   $0xc010a293,(%esp)
c0107244:	e8 ec 91 ff ff       	call   c0100435 <__panic>

    assert((p0 = alloc_page()) != NULL);
c0107249:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107250:	e8 32 c2 ff ff       	call   c0103487 <alloc_pages>
c0107255:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107258:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010725c:	75 24                	jne    c0107282 <basic_check+0x35a>
c010725e:	c7 44 24 0c e1 a2 10 	movl   $0xc010a2e1,0xc(%esp)
c0107265:	c0 
c0107266:	c7 44 24 08 7e a2 10 	movl   $0xc010a27e,0x8(%esp)
c010726d:	c0 
c010726e:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
c0107275:	00 
c0107276:	c7 04 24 93 a2 10 c0 	movl   $0xc010a293,(%esp)
c010727d:	e8 b3 91 ff ff       	call   c0100435 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0107282:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107289:	e8 f9 c1 ff ff       	call   c0103487 <alloc_pages>
c010728e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107291:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0107295:	75 24                	jne    c01072bb <basic_check+0x393>
c0107297:	c7 44 24 0c fd a2 10 	movl   $0xc010a2fd,0xc(%esp)
c010729e:	c0 
c010729f:	c7 44 24 08 7e a2 10 	movl   $0xc010a27e,0x8(%esp)
c01072a6:	c0 
c01072a7:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
c01072ae:	00 
c01072af:	c7 04 24 93 a2 10 c0 	movl   $0xc010a293,(%esp)
c01072b6:	e8 7a 91 ff ff       	call   c0100435 <__panic>
    assert((p2 = alloc_page()) != NULL);
c01072bb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01072c2:	e8 c0 c1 ff ff       	call   c0103487 <alloc_pages>
c01072c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01072ca:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01072ce:	75 24                	jne    c01072f4 <basic_check+0x3cc>
c01072d0:	c7 44 24 0c 19 a3 10 	movl   $0xc010a319,0xc(%esp)
c01072d7:	c0 
c01072d8:	c7 44 24 08 7e a2 10 	movl   $0xc010a27e,0x8(%esp)
c01072df:	c0 
c01072e0:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
c01072e7:	00 
c01072e8:	c7 04 24 93 a2 10 c0 	movl   $0xc010a293,(%esp)
c01072ef:	e8 41 91 ff ff       	call   c0100435 <__panic>

    assert(alloc_page() == NULL);
c01072f4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01072fb:	e8 87 c1 ff ff       	call   c0103487 <alloc_pages>
c0107300:	85 c0                	test   %eax,%eax
c0107302:	74 24                	je     c0107328 <basic_check+0x400>
c0107304:	c7 44 24 0c 06 a4 10 	movl   $0xc010a406,0xc(%esp)
c010730b:	c0 
c010730c:	c7 44 24 08 7e a2 10 	movl   $0xc010a27e,0x8(%esp)
c0107313:	c0 
c0107314:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
c010731b:	00 
c010731c:	c7 04 24 93 a2 10 c0 	movl   $0xc010a293,(%esp)
c0107323:	e8 0d 91 ff ff       	call   c0100435 <__panic>

    free_page(p0);
c0107328:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010732f:	00 
c0107330:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107333:	89 04 24             	mov    %eax,(%esp)
c0107336:	e8 bb c1 ff ff       	call   c01034f6 <free_pages>
c010733b:	c7 45 d8 0c 61 12 c0 	movl   $0xc012610c,-0x28(%ebp)
c0107342:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0107345:	8b 40 04             	mov    0x4(%eax),%eax
c0107348:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c010734b:	0f 94 c0             	sete   %al
c010734e:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c0107351:	85 c0                	test   %eax,%eax
c0107353:	74 24                	je     c0107379 <basic_check+0x451>
c0107355:	c7 44 24 0c 28 a4 10 	movl   $0xc010a428,0xc(%esp)
c010735c:	c0 
c010735d:	c7 44 24 08 7e a2 10 	movl   $0xc010a27e,0x8(%esp)
c0107364:	c0 
c0107365:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
c010736c:	00 
c010736d:	c7 04 24 93 a2 10 c0 	movl   $0xc010a293,(%esp)
c0107374:	e8 bc 90 ff ff       	call   c0100435 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0107379:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107380:	e8 02 c1 ff ff       	call   c0103487 <alloc_pages>
c0107385:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0107388:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010738b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010738e:	74 24                	je     c01073b4 <basic_check+0x48c>
c0107390:	c7 44 24 0c 40 a4 10 	movl   $0xc010a440,0xc(%esp)
c0107397:	c0 
c0107398:	c7 44 24 08 7e a2 10 	movl   $0xc010a27e,0x8(%esp)
c010739f:	c0 
c01073a0:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
c01073a7:	00 
c01073a8:	c7 04 24 93 a2 10 c0 	movl   $0xc010a293,(%esp)
c01073af:	e8 81 90 ff ff       	call   c0100435 <__panic>
    assert(alloc_page() == NULL);
c01073b4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01073bb:	e8 c7 c0 ff ff       	call   c0103487 <alloc_pages>
c01073c0:	85 c0                	test   %eax,%eax
c01073c2:	74 24                	je     c01073e8 <basic_check+0x4c0>
c01073c4:	c7 44 24 0c 06 a4 10 	movl   $0xc010a406,0xc(%esp)
c01073cb:	c0 
c01073cc:	c7 44 24 08 7e a2 10 	movl   $0xc010a27e,0x8(%esp)
c01073d3:	c0 
c01073d4:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
c01073db:	00 
c01073dc:	c7 04 24 93 a2 10 c0 	movl   $0xc010a293,(%esp)
c01073e3:	e8 4d 90 ff ff       	call   c0100435 <__panic>

    assert(nr_free == 0);
c01073e8:	a1 14 61 12 c0       	mov    0xc0126114,%eax
c01073ed:	85 c0                	test   %eax,%eax
c01073ef:	74 24                	je     c0107415 <basic_check+0x4ed>
c01073f1:	c7 44 24 0c 59 a4 10 	movl   $0xc010a459,0xc(%esp)
c01073f8:	c0 
c01073f9:	c7 44 24 08 7e a2 10 	movl   $0xc010a27e,0x8(%esp)
c0107400:	c0 
c0107401:	c7 44 24 04 e4 00 00 	movl   $0xe4,0x4(%esp)
c0107408:	00 
c0107409:	c7 04 24 93 a2 10 c0 	movl   $0xc010a293,(%esp)
c0107410:	e8 20 90 ff ff       	call   c0100435 <__panic>
    free_list = free_list_store;
c0107415:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0107418:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010741b:	a3 0c 61 12 c0       	mov    %eax,0xc012610c
c0107420:	89 15 10 61 12 c0    	mov    %edx,0xc0126110
    nr_free = nr_free_store;
c0107426:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107429:	a3 14 61 12 c0       	mov    %eax,0xc0126114

    free_page(p);
c010742e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107435:	00 
c0107436:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107439:	89 04 24             	mov    %eax,(%esp)
c010743c:	e8 b5 c0 ff ff       	call   c01034f6 <free_pages>
    free_page(p1);
c0107441:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107448:	00 
c0107449:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010744c:	89 04 24             	mov    %eax,(%esp)
c010744f:	e8 a2 c0 ff ff       	call   c01034f6 <free_pages>
    free_page(p2);
c0107454:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010745b:	00 
c010745c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010745f:	89 04 24             	mov    %eax,(%esp)
c0107462:	e8 8f c0 ff ff       	call   c01034f6 <free_pages>
}
c0107467:	90                   	nop
c0107468:	c9                   	leave  
c0107469:	c3                   	ret    

c010746a <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c010746a:	f3 0f 1e fb          	endbr32 
c010746e:	55                   	push   %ebp
c010746f:	89 e5                	mov    %esp,%ebp
c0107471:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
c0107477:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010747e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c0107485:	c7 45 ec 0c 61 12 c0 	movl   $0xc012610c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c010748c:	eb 6a                	jmp    c01074f8 <default_check+0x8e>
        struct Page *p = le2page(le, page_link);
c010748e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107491:	83 e8 0c             	sub    $0xc,%eax
c0107494:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(PageProperty(p));
c0107497:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010749a:	83 c0 04             	add    $0x4,%eax
c010749d:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c01074a4:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01074a7:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01074aa:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01074ad:	0f a3 10             	bt     %edx,(%eax)
c01074b0:	19 c0                	sbb    %eax,%eax
c01074b2:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c01074b5:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c01074b9:	0f 95 c0             	setne  %al
c01074bc:	0f b6 c0             	movzbl %al,%eax
c01074bf:	85 c0                	test   %eax,%eax
c01074c1:	75 24                	jne    c01074e7 <default_check+0x7d>
c01074c3:	c7 44 24 0c 66 a4 10 	movl   $0xc010a466,0xc(%esp)
c01074ca:	c0 
c01074cb:	c7 44 24 08 7e a2 10 	movl   $0xc010a27e,0x8(%esp)
c01074d2:	c0 
c01074d3:	c7 44 24 04 f5 00 00 	movl   $0xf5,0x4(%esp)
c01074da:	00 
c01074db:	c7 04 24 93 a2 10 c0 	movl   $0xc010a293,(%esp)
c01074e2:	e8 4e 8f ff ff       	call   c0100435 <__panic>
        count ++, total += p->property;
c01074e7:	ff 45 f4             	incl   -0xc(%ebp)
c01074ea:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01074ed:	8b 50 08             	mov    0x8(%eax),%edx
c01074f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01074f3:	01 d0                	add    %edx,%eax
c01074f5:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01074f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01074fb:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
c01074fe:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0107501:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0107504:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107507:	81 7d ec 0c 61 12 c0 	cmpl   $0xc012610c,-0x14(%ebp)
c010750e:	0f 85 7a ff ff ff    	jne    c010748e <default_check+0x24>
    }
    assert(total == nr_free_pages());
c0107514:	e8 14 c0 ff ff       	call   c010352d <nr_free_pages>
c0107519:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010751c:	39 d0                	cmp    %edx,%eax
c010751e:	74 24                	je     c0107544 <default_check+0xda>
c0107520:	c7 44 24 0c 76 a4 10 	movl   $0xc010a476,0xc(%esp)
c0107527:	c0 
c0107528:	c7 44 24 08 7e a2 10 	movl   $0xc010a27e,0x8(%esp)
c010752f:	c0 
c0107530:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
c0107537:	00 
c0107538:	c7 04 24 93 a2 10 c0 	movl   $0xc010a293,(%esp)
c010753f:	e8 f1 8e ff ff       	call   c0100435 <__panic>

    basic_check();
c0107544:	e8 df f9 ff ff       	call   c0106f28 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c0107549:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0107550:	e8 32 bf ff ff       	call   c0103487 <alloc_pages>
c0107555:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p0 != NULL);
c0107558:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010755c:	75 24                	jne    c0107582 <default_check+0x118>
c010755e:	c7 44 24 0c 8f a4 10 	movl   $0xc010a48f,0xc(%esp)
c0107565:	c0 
c0107566:	c7 44 24 08 7e a2 10 	movl   $0xc010a27e,0x8(%esp)
c010756d:	c0 
c010756e:	c7 44 24 04 fd 00 00 	movl   $0xfd,0x4(%esp)
c0107575:	00 
c0107576:	c7 04 24 93 a2 10 c0 	movl   $0xc010a293,(%esp)
c010757d:	e8 b3 8e ff ff       	call   c0100435 <__panic>
    assert(!PageProperty(p0));
c0107582:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107585:	83 c0 04             	add    $0x4,%eax
c0107588:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c010758f:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0107592:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0107595:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0107598:	0f a3 10             	bt     %edx,(%eax)
c010759b:	19 c0                	sbb    %eax,%eax
c010759d:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c01075a0:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c01075a4:	0f 95 c0             	setne  %al
c01075a7:	0f b6 c0             	movzbl %al,%eax
c01075aa:	85 c0                	test   %eax,%eax
c01075ac:	74 24                	je     c01075d2 <default_check+0x168>
c01075ae:	c7 44 24 0c 9a a4 10 	movl   $0xc010a49a,0xc(%esp)
c01075b5:	c0 
c01075b6:	c7 44 24 08 7e a2 10 	movl   $0xc010a27e,0x8(%esp)
c01075bd:	c0 
c01075be:	c7 44 24 04 fe 00 00 	movl   $0xfe,0x4(%esp)
c01075c5:	00 
c01075c6:	c7 04 24 93 a2 10 c0 	movl   $0xc010a293,(%esp)
c01075cd:	e8 63 8e ff ff       	call   c0100435 <__panic>

    list_entry_t free_list_store = free_list;
c01075d2:	a1 0c 61 12 c0       	mov    0xc012610c,%eax
c01075d7:	8b 15 10 61 12 c0    	mov    0xc0126110,%edx
c01075dd:	89 45 80             	mov    %eax,-0x80(%ebp)
c01075e0:	89 55 84             	mov    %edx,-0x7c(%ebp)
c01075e3:	c7 45 b0 0c 61 12 c0 	movl   $0xc012610c,-0x50(%ebp)
    elm->prev = elm->next = elm;
c01075ea:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01075ed:	8b 55 b0             	mov    -0x50(%ebp),%edx
c01075f0:	89 50 04             	mov    %edx,0x4(%eax)
c01075f3:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01075f6:	8b 50 04             	mov    0x4(%eax),%edx
c01075f9:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01075fc:	89 10                	mov    %edx,(%eax)
}
c01075fe:	90                   	nop
c01075ff:	c7 45 b4 0c 61 12 c0 	movl   $0xc012610c,-0x4c(%ebp)
    return list->next == list;
c0107606:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0107609:	8b 40 04             	mov    0x4(%eax),%eax
c010760c:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
c010760f:	0f 94 c0             	sete   %al
c0107612:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0107615:	85 c0                	test   %eax,%eax
c0107617:	75 24                	jne    c010763d <default_check+0x1d3>
c0107619:	c7 44 24 0c ef a3 10 	movl   $0xc010a3ef,0xc(%esp)
c0107620:	c0 
c0107621:	c7 44 24 08 7e a2 10 	movl   $0xc010a27e,0x8(%esp)
c0107628:	c0 
c0107629:	c7 44 24 04 02 01 00 	movl   $0x102,0x4(%esp)
c0107630:	00 
c0107631:	c7 04 24 93 a2 10 c0 	movl   $0xc010a293,(%esp)
c0107638:	e8 f8 8d ff ff       	call   c0100435 <__panic>
    assert(alloc_page() == NULL);
c010763d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107644:	e8 3e be ff ff       	call   c0103487 <alloc_pages>
c0107649:	85 c0                	test   %eax,%eax
c010764b:	74 24                	je     c0107671 <default_check+0x207>
c010764d:	c7 44 24 0c 06 a4 10 	movl   $0xc010a406,0xc(%esp)
c0107654:	c0 
c0107655:	c7 44 24 08 7e a2 10 	movl   $0xc010a27e,0x8(%esp)
c010765c:	c0 
c010765d:	c7 44 24 04 03 01 00 	movl   $0x103,0x4(%esp)
c0107664:	00 
c0107665:	c7 04 24 93 a2 10 c0 	movl   $0xc010a293,(%esp)
c010766c:	e8 c4 8d ff ff       	call   c0100435 <__panic>

    unsigned int nr_free_store = nr_free;
c0107671:	a1 14 61 12 c0       	mov    0xc0126114,%eax
c0107676:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nr_free = 0;
c0107679:	c7 05 14 61 12 c0 00 	movl   $0x0,0xc0126114
c0107680:	00 00 00 

    free_pages(p0 + 2, 3);
c0107683:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107686:	83 c0 40             	add    $0x40,%eax
c0107689:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0107690:	00 
c0107691:	89 04 24             	mov    %eax,(%esp)
c0107694:	e8 5d be ff ff       	call   c01034f6 <free_pages>
    assert(alloc_pages(4) == NULL);
c0107699:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c01076a0:	e8 e2 bd ff ff       	call   c0103487 <alloc_pages>
c01076a5:	85 c0                	test   %eax,%eax
c01076a7:	74 24                	je     c01076cd <default_check+0x263>
c01076a9:	c7 44 24 0c ac a4 10 	movl   $0xc010a4ac,0xc(%esp)
c01076b0:	c0 
c01076b1:	c7 44 24 08 7e a2 10 	movl   $0xc010a27e,0x8(%esp)
c01076b8:	c0 
c01076b9:	c7 44 24 04 09 01 00 	movl   $0x109,0x4(%esp)
c01076c0:	00 
c01076c1:	c7 04 24 93 a2 10 c0 	movl   $0xc010a293,(%esp)
c01076c8:	e8 68 8d ff ff       	call   c0100435 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c01076cd:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01076d0:	83 c0 40             	add    $0x40,%eax
c01076d3:	83 c0 04             	add    $0x4,%eax
c01076d6:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c01076dd:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01076e0:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01076e3:	8b 55 ac             	mov    -0x54(%ebp),%edx
c01076e6:	0f a3 10             	bt     %edx,(%eax)
c01076e9:	19 c0                	sbb    %eax,%eax
c01076eb:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c01076ee:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c01076f2:	0f 95 c0             	setne  %al
c01076f5:	0f b6 c0             	movzbl %al,%eax
c01076f8:	85 c0                	test   %eax,%eax
c01076fa:	74 0e                	je     c010770a <default_check+0x2a0>
c01076fc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01076ff:	83 c0 40             	add    $0x40,%eax
c0107702:	8b 40 08             	mov    0x8(%eax),%eax
c0107705:	83 f8 03             	cmp    $0x3,%eax
c0107708:	74 24                	je     c010772e <default_check+0x2c4>
c010770a:	c7 44 24 0c c4 a4 10 	movl   $0xc010a4c4,0xc(%esp)
c0107711:	c0 
c0107712:	c7 44 24 08 7e a2 10 	movl   $0xc010a27e,0x8(%esp)
c0107719:	c0 
c010771a:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
c0107721:	00 
c0107722:	c7 04 24 93 a2 10 c0 	movl   $0xc010a293,(%esp)
c0107729:	e8 07 8d ff ff       	call   c0100435 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c010772e:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c0107735:	e8 4d bd ff ff       	call   c0103487 <alloc_pages>
c010773a:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010773d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0107741:	75 24                	jne    c0107767 <default_check+0x2fd>
c0107743:	c7 44 24 0c f0 a4 10 	movl   $0xc010a4f0,0xc(%esp)
c010774a:	c0 
c010774b:	c7 44 24 08 7e a2 10 	movl   $0xc010a27e,0x8(%esp)
c0107752:	c0 
c0107753:	c7 44 24 04 0b 01 00 	movl   $0x10b,0x4(%esp)
c010775a:	00 
c010775b:	c7 04 24 93 a2 10 c0 	movl   $0xc010a293,(%esp)
c0107762:	e8 ce 8c ff ff       	call   c0100435 <__panic>
    assert(alloc_page() == NULL);
c0107767:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010776e:	e8 14 bd ff ff       	call   c0103487 <alloc_pages>
c0107773:	85 c0                	test   %eax,%eax
c0107775:	74 24                	je     c010779b <default_check+0x331>
c0107777:	c7 44 24 0c 06 a4 10 	movl   $0xc010a406,0xc(%esp)
c010777e:	c0 
c010777f:	c7 44 24 08 7e a2 10 	movl   $0xc010a27e,0x8(%esp)
c0107786:	c0 
c0107787:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
c010778e:	00 
c010778f:	c7 04 24 93 a2 10 c0 	movl   $0xc010a293,(%esp)
c0107796:	e8 9a 8c ff ff       	call   c0100435 <__panic>
    assert(p0 + 2 == p1);
c010779b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010779e:	83 c0 40             	add    $0x40,%eax
c01077a1:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c01077a4:	74 24                	je     c01077ca <default_check+0x360>
c01077a6:	c7 44 24 0c 0e a5 10 	movl   $0xc010a50e,0xc(%esp)
c01077ad:	c0 
c01077ae:	c7 44 24 08 7e a2 10 	movl   $0xc010a27e,0x8(%esp)
c01077b5:	c0 
c01077b6:	c7 44 24 04 0d 01 00 	movl   $0x10d,0x4(%esp)
c01077bd:	00 
c01077be:	c7 04 24 93 a2 10 c0 	movl   $0xc010a293,(%esp)
c01077c5:	e8 6b 8c ff ff       	call   c0100435 <__panic>

    p2 = p0 + 1;
c01077ca:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01077cd:	83 c0 20             	add    $0x20,%eax
c01077d0:	89 45 dc             	mov    %eax,-0x24(%ebp)
    free_page(p0);
c01077d3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01077da:	00 
c01077db:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01077de:	89 04 24             	mov    %eax,(%esp)
c01077e1:	e8 10 bd ff ff       	call   c01034f6 <free_pages>
    free_pages(p1, 3);
c01077e6:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c01077ed:	00 
c01077ee:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01077f1:	89 04 24             	mov    %eax,(%esp)
c01077f4:	e8 fd bc ff ff       	call   c01034f6 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c01077f9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01077fc:	83 c0 04             	add    $0x4,%eax
c01077ff:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c0107806:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0107809:	8b 45 9c             	mov    -0x64(%ebp),%eax
c010780c:	8b 55 a0             	mov    -0x60(%ebp),%edx
c010780f:	0f a3 10             	bt     %edx,(%eax)
c0107812:	19 c0                	sbb    %eax,%eax
c0107814:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c0107817:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c010781b:	0f 95 c0             	setne  %al
c010781e:	0f b6 c0             	movzbl %al,%eax
c0107821:	85 c0                	test   %eax,%eax
c0107823:	74 0b                	je     c0107830 <default_check+0x3c6>
c0107825:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107828:	8b 40 08             	mov    0x8(%eax),%eax
c010782b:	83 f8 01             	cmp    $0x1,%eax
c010782e:	74 24                	je     c0107854 <default_check+0x3ea>
c0107830:	c7 44 24 0c 1c a5 10 	movl   $0xc010a51c,0xc(%esp)
c0107837:	c0 
c0107838:	c7 44 24 08 7e a2 10 	movl   $0xc010a27e,0x8(%esp)
c010783f:	c0 
c0107840:	c7 44 24 04 12 01 00 	movl   $0x112,0x4(%esp)
c0107847:	00 
c0107848:	c7 04 24 93 a2 10 c0 	movl   $0xc010a293,(%esp)
c010784f:	e8 e1 8b ff ff       	call   c0100435 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c0107854:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107857:	83 c0 04             	add    $0x4,%eax
c010785a:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c0107861:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0107864:	8b 45 90             	mov    -0x70(%ebp),%eax
c0107867:	8b 55 94             	mov    -0x6c(%ebp),%edx
c010786a:	0f a3 10             	bt     %edx,(%eax)
c010786d:	19 c0                	sbb    %eax,%eax
c010786f:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c0107872:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c0107876:	0f 95 c0             	setne  %al
c0107879:	0f b6 c0             	movzbl %al,%eax
c010787c:	85 c0                	test   %eax,%eax
c010787e:	74 0b                	je     c010788b <default_check+0x421>
c0107880:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107883:	8b 40 08             	mov    0x8(%eax),%eax
c0107886:	83 f8 03             	cmp    $0x3,%eax
c0107889:	74 24                	je     c01078af <default_check+0x445>
c010788b:	c7 44 24 0c 44 a5 10 	movl   $0xc010a544,0xc(%esp)
c0107892:	c0 
c0107893:	c7 44 24 08 7e a2 10 	movl   $0xc010a27e,0x8(%esp)
c010789a:	c0 
c010789b:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
c01078a2:	00 
c01078a3:	c7 04 24 93 a2 10 c0 	movl   $0xc010a293,(%esp)
c01078aa:	e8 86 8b ff ff       	call   c0100435 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c01078af:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01078b6:	e8 cc bb ff ff       	call   c0103487 <alloc_pages>
c01078bb:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01078be:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01078c1:	83 e8 20             	sub    $0x20,%eax
c01078c4:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c01078c7:	74 24                	je     c01078ed <default_check+0x483>
c01078c9:	c7 44 24 0c 6a a5 10 	movl   $0xc010a56a,0xc(%esp)
c01078d0:	c0 
c01078d1:	c7 44 24 08 7e a2 10 	movl   $0xc010a27e,0x8(%esp)
c01078d8:	c0 
c01078d9:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
c01078e0:	00 
c01078e1:	c7 04 24 93 a2 10 c0 	movl   $0xc010a293,(%esp)
c01078e8:	e8 48 8b ff ff       	call   c0100435 <__panic>
    free_page(p0);
c01078ed:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01078f4:	00 
c01078f5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01078f8:	89 04 24             	mov    %eax,(%esp)
c01078fb:	e8 f6 bb ff ff       	call   c01034f6 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c0107900:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0107907:	e8 7b bb ff ff       	call   c0103487 <alloc_pages>
c010790c:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010790f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107912:	83 c0 20             	add    $0x20,%eax
c0107915:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0107918:	74 24                	je     c010793e <default_check+0x4d4>
c010791a:	c7 44 24 0c 88 a5 10 	movl   $0xc010a588,0xc(%esp)
c0107921:	c0 
c0107922:	c7 44 24 08 7e a2 10 	movl   $0xc010a27e,0x8(%esp)
c0107929:	c0 
c010792a:	c7 44 24 04 17 01 00 	movl   $0x117,0x4(%esp)
c0107931:	00 
c0107932:	c7 04 24 93 a2 10 c0 	movl   $0xc010a293,(%esp)
c0107939:	e8 f7 8a ff ff       	call   c0100435 <__panic>

    free_pages(p0, 2);
c010793e:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0107945:	00 
c0107946:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107949:	89 04 24             	mov    %eax,(%esp)
c010794c:	e8 a5 bb ff ff       	call   c01034f6 <free_pages>
    free_page(p2);
c0107951:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107958:	00 
c0107959:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010795c:	89 04 24             	mov    %eax,(%esp)
c010795f:	e8 92 bb ff ff       	call   c01034f6 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c0107964:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c010796b:	e8 17 bb ff ff       	call   c0103487 <alloc_pages>
c0107970:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0107973:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0107977:	75 24                	jne    c010799d <default_check+0x533>
c0107979:	c7 44 24 0c a8 a5 10 	movl   $0xc010a5a8,0xc(%esp)
c0107980:	c0 
c0107981:	c7 44 24 08 7e a2 10 	movl   $0xc010a27e,0x8(%esp)
c0107988:	c0 
c0107989:	c7 44 24 04 1c 01 00 	movl   $0x11c,0x4(%esp)
c0107990:	00 
c0107991:	c7 04 24 93 a2 10 c0 	movl   $0xc010a293,(%esp)
c0107998:	e8 98 8a ff ff       	call   c0100435 <__panic>
    assert(alloc_page() == NULL);
c010799d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01079a4:	e8 de ba ff ff       	call   c0103487 <alloc_pages>
c01079a9:	85 c0                	test   %eax,%eax
c01079ab:	74 24                	je     c01079d1 <default_check+0x567>
c01079ad:	c7 44 24 0c 06 a4 10 	movl   $0xc010a406,0xc(%esp)
c01079b4:	c0 
c01079b5:	c7 44 24 08 7e a2 10 	movl   $0xc010a27e,0x8(%esp)
c01079bc:	c0 
c01079bd:	c7 44 24 04 1d 01 00 	movl   $0x11d,0x4(%esp)
c01079c4:	00 
c01079c5:	c7 04 24 93 a2 10 c0 	movl   $0xc010a293,(%esp)
c01079cc:	e8 64 8a ff ff       	call   c0100435 <__panic>

    assert(nr_free == 0);
c01079d1:	a1 14 61 12 c0       	mov    0xc0126114,%eax
c01079d6:	85 c0                	test   %eax,%eax
c01079d8:	74 24                	je     c01079fe <default_check+0x594>
c01079da:	c7 44 24 0c 59 a4 10 	movl   $0xc010a459,0xc(%esp)
c01079e1:	c0 
c01079e2:	c7 44 24 08 7e a2 10 	movl   $0xc010a27e,0x8(%esp)
c01079e9:	c0 
c01079ea:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
c01079f1:	00 
c01079f2:	c7 04 24 93 a2 10 c0 	movl   $0xc010a293,(%esp)
c01079f9:	e8 37 8a ff ff       	call   c0100435 <__panic>
    nr_free = nr_free_store;
c01079fe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107a01:	a3 14 61 12 c0       	mov    %eax,0xc0126114

    free_list = free_list_store;
c0107a06:	8b 45 80             	mov    -0x80(%ebp),%eax
c0107a09:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0107a0c:	a3 0c 61 12 c0       	mov    %eax,0xc012610c
c0107a11:	89 15 10 61 12 c0    	mov    %edx,0xc0126110
    free_pages(p0, 5);
c0107a17:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c0107a1e:	00 
c0107a1f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107a22:	89 04 24             	mov    %eax,(%esp)
c0107a25:	e8 cc ba ff ff       	call   c01034f6 <free_pages>

    le = &free_list;
c0107a2a:	c7 45 ec 0c 61 12 c0 	movl   $0xc012610c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0107a31:	eb 1c                	jmp    c0107a4f <default_check+0x5e5>
        struct Page *p = le2page(le, page_link);
c0107a33:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107a36:	83 e8 0c             	sub    $0xc,%eax
c0107a39:	89 45 d8             	mov    %eax,-0x28(%ebp)
        count --, total -= p->property;
c0107a3c:	ff 4d f4             	decl   -0xc(%ebp)
c0107a3f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0107a42:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0107a45:	8b 40 08             	mov    0x8(%eax),%eax
c0107a48:	29 c2                	sub    %eax,%edx
c0107a4a:	89 d0                	mov    %edx,%eax
c0107a4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107a4f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107a52:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
c0107a55:	8b 45 88             	mov    -0x78(%ebp),%eax
c0107a58:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0107a5b:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107a5e:	81 7d ec 0c 61 12 c0 	cmpl   $0xc012610c,-0x14(%ebp)
c0107a65:	75 cc                	jne    c0107a33 <default_check+0x5c9>
    }
    assert(count == 0);
c0107a67:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107a6b:	74 24                	je     c0107a91 <default_check+0x627>
c0107a6d:	c7 44 24 0c c6 a5 10 	movl   $0xc010a5c6,0xc(%esp)
c0107a74:	c0 
c0107a75:	c7 44 24 08 7e a2 10 	movl   $0xc010a27e,0x8(%esp)
c0107a7c:	c0 
c0107a7d:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
c0107a84:	00 
c0107a85:	c7 04 24 93 a2 10 c0 	movl   $0xc010a293,(%esp)
c0107a8c:	e8 a4 89 ff ff       	call   c0100435 <__panic>
    assert(total == 0);
c0107a91:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0107a95:	74 24                	je     c0107abb <default_check+0x651>
c0107a97:	c7 44 24 0c d1 a5 10 	movl   $0xc010a5d1,0xc(%esp)
c0107a9e:	c0 
c0107a9f:	c7 44 24 08 7e a2 10 	movl   $0xc010a27e,0x8(%esp)
c0107aa6:	c0 
c0107aa7:	c7 44 24 04 2b 01 00 	movl   $0x12b,0x4(%esp)
c0107aae:	00 
c0107aaf:	c7 04 24 93 a2 10 c0 	movl   $0xc010a293,(%esp)
c0107ab6:	e8 7a 89 ff ff       	call   c0100435 <__panic>
}
c0107abb:	90                   	nop
c0107abc:	c9                   	leave  
c0107abd:	c3                   	ret    

c0107abe <page2ppn>:
page2ppn(struct Page *page) {
c0107abe:	55                   	push   %ebp
c0107abf:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0107ac1:	a1 28 60 12 c0       	mov    0xc0126028,%eax
c0107ac6:	8b 55 08             	mov    0x8(%ebp),%edx
c0107ac9:	29 c2                	sub    %eax,%edx
c0107acb:	89 d0                	mov    %edx,%eax
c0107acd:	c1 f8 05             	sar    $0x5,%eax
}
c0107ad0:	5d                   	pop    %ebp
c0107ad1:	c3                   	ret    

c0107ad2 <page2pa>:
page2pa(struct Page *page) {
c0107ad2:	55                   	push   %ebp
c0107ad3:	89 e5                	mov    %esp,%ebp
c0107ad5:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0107ad8:	8b 45 08             	mov    0x8(%ebp),%eax
c0107adb:	89 04 24             	mov    %eax,(%esp)
c0107ade:	e8 db ff ff ff       	call   c0107abe <page2ppn>
c0107ae3:	c1 e0 0c             	shl    $0xc,%eax
}
c0107ae6:	c9                   	leave  
c0107ae7:	c3                   	ret    

c0107ae8 <page2kva>:
page2kva(struct Page *page) {
c0107ae8:	55                   	push   %ebp
c0107ae9:	89 e5                	mov    %esp,%ebp
c0107aeb:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0107aee:	8b 45 08             	mov    0x8(%ebp),%eax
c0107af1:	89 04 24             	mov    %eax,(%esp)
c0107af4:	e8 d9 ff ff ff       	call   c0107ad2 <page2pa>
c0107af9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107afc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107aff:	c1 e8 0c             	shr    $0xc,%eax
c0107b02:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107b05:	a1 80 5f 12 c0       	mov    0xc0125f80,%eax
c0107b0a:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0107b0d:	72 23                	jb     c0107b32 <page2kva+0x4a>
c0107b0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107b12:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0107b16:	c7 44 24 08 0c a6 10 	movl   $0xc010a60c,0x8(%esp)
c0107b1d:	c0 
c0107b1e:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
c0107b25:	00 
c0107b26:	c7 04 24 2f a6 10 c0 	movl   $0xc010a62f,(%esp)
c0107b2d:	e8 03 89 ff ff       	call   c0100435 <__panic>
c0107b32:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107b35:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0107b3a:	c9                   	leave  
c0107b3b:	c3                   	ret    

c0107b3c <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
c0107b3c:	f3 0f 1e fb          	endbr32 
c0107b40:	55                   	push   %ebp
c0107b41:	89 e5                	mov    %esp,%ebp
c0107b43:	83 ec 18             	sub    $0x18,%esp
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
c0107b46:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107b4d:	e8 5d 95 ff ff       	call   c01010af <ide_device_valid>
c0107b52:	85 c0                	test   %eax,%eax
c0107b54:	75 1c                	jne    c0107b72 <swapfs_init+0x36>
        panic("swap fs isn't available.\n");
c0107b56:	c7 44 24 08 3d a6 10 	movl   $0xc010a63d,0x8(%esp)
c0107b5d:	c0 
c0107b5e:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
c0107b65:	00 
c0107b66:	c7 04 24 57 a6 10 c0 	movl   $0xc010a657,(%esp)
c0107b6d:	e8 c3 88 ff ff       	call   c0100435 <__panic>
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
c0107b72:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107b79:	e8 73 95 ff ff       	call   c01010f1 <ide_device_size>
c0107b7e:	c1 e8 03             	shr    $0x3,%eax
c0107b81:	a3 dc 60 12 c0       	mov    %eax,0xc01260dc
}
c0107b86:	90                   	nop
c0107b87:	c9                   	leave  
c0107b88:	c3                   	ret    

c0107b89 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
c0107b89:	f3 0f 1e fb          	endbr32 
c0107b8d:	55                   	push   %ebp
c0107b8e:	89 e5                	mov    %esp,%ebp
c0107b90:	83 ec 28             	sub    $0x28,%esp
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c0107b93:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107b96:	89 04 24             	mov    %eax,(%esp)
c0107b99:	e8 4a ff ff ff       	call   c0107ae8 <page2kva>
c0107b9e:	8b 55 08             	mov    0x8(%ebp),%edx
c0107ba1:	c1 ea 08             	shr    $0x8,%edx
c0107ba4:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0107ba7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107bab:	74 0b                	je     c0107bb8 <swapfs_read+0x2f>
c0107bad:	8b 15 dc 60 12 c0    	mov    0xc01260dc,%edx
c0107bb3:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c0107bb6:	72 23                	jb     c0107bdb <swapfs_read+0x52>
c0107bb8:	8b 45 08             	mov    0x8(%ebp),%eax
c0107bbb:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0107bbf:	c7 44 24 08 68 a6 10 	movl   $0xc010a668,0x8(%esp)
c0107bc6:	c0 
c0107bc7:	c7 44 24 04 14 00 00 	movl   $0x14,0x4(%esp)
c0107bce:	00 
c0107bcf:	c7 04 24 57 a6 10 c0 	movl   $0xc010a657,(%esp)
c0107bd6:	e8 5a 88 ff ff       	call   c0100435 <__panic>
c0107bdb:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107bde:	c1 e2 03             	shl    $0x3,%edx
c0107be1:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c0107be8:	00 
c0107be9:	89 44 24 08          	mov    %eax,0x8(%esp)
c0107bed:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107bf1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107bf8:	e8 33 95 ff ff       	call   c0101130 <ide_read_secs>
}
c0107bfd:	c9                   	leave  
c0107bfe:	c3                   	ret    

c0107bff <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
c0107bff:	f3 0f 1e fb          	endbr32 
c0107c03:	55                   	push   %ebp
c0107c04:	89 e5                	mov    %esp,%ebp
c0107c06:	83 ec 28             	sub    $0x28,%esp
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c0107c09:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107c0c:	89 04 24             	mov    %eax,(%esp)
c0107c0f:	e8 d4 fe ff ff       	call   c0107ae8 <page2kva>
c0107c14:	8b 55 08             	mov    0x8(%ebp),%edx
c0107c17:	c1 ea 08             	shr    $0x8,%edx
c0107c1a:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0107c1d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107c21:	74 0b                	je     c0107c2e <swapfs_write+0x2f>
c0107c23:	8b 15 dc 60 12 c0    	mov    0xc01260dc,%edx
c0107c29:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c0107c2c:	72 23                	jb     c0107c51 <swapfs_write+0x52>
c0107c2e:	8b 45 08             	mov    0x8(%ebp),%eax
c0107c31:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0107c35:	c7 44 24 08 68 a6 10 	movl   $0xc010a668,0x8(%esp)
c0107c3c:	c0 
c0107c3d:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
c0107c44:	00 
c0107c45:	c7 04 24 57 a6 10 c0 	movl   $0xc010a657,(%esp)
c0107c4c:	e8 e4 87 ff ff       	call   c0100435 <__panic>
c0107c51:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107c54:	c1 e2 03             	shl    $0x3,%edx
c0107c57:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c0107c5e:	00 
c0107c5f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0107c63:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107c67:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107c6e:	e8 02 97 ff ff       	call   c0101375 <ide_write_secs>
}
c0107c73:	c9                   	leave  
c0107c74:	c3                   	ret    

c0107c75 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c0107c75:	f3 0f 1e fb          	endbr32 
c0107c79:	55                   	push   %ebp
c0107c7a:	89 e5                	mov    %esp,%ebp
c0107c7c:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0107c7f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c0107c86:	eb 03                	jmp    c0107c8b <strlen+0x16>
        cnt ++;
c0107c88:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
c0107c8b:	8b 45 08             	mov    0x8(%ebp),%eax
c0107c8e:	8d 50 01             	lea    0x1(%eax),%edx
c0107c91:	89 55 08             	mov    %edx,0x8(%ebp)
c0107c94:	0f b6 00             	movzbl (%eax),%eax
c0107c97:	84 c0                	test   %al,%al
c0107c99:	75 ed                	jne    c0107c88 <strlen+0x13>
    }
    return cnt;
c0107c9b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0107c9e:	c9                   	leave  
c0107c9f:	c3                   	ret    

c0107ca0 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c0107ca0:	f3 0f 1e fb          	endbr32 
c0107ca4:	55                   	push   %ebp
c0107ca5:	89 e5                	mov    %esp,%ebp
c0107ca7:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0107caa:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0107cb1:	eb 03                	jmp    c0107cb6 <strnlen+0x16>
        cnt ++;
c0107cb3:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0107cb6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107cb9:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0107cbc:	73 10                	jae    c0107cce <strnlen+0x2e>
c0107cbe:	8b 45 08             	mov    0x8(%ebp),%eax
c0107cc1:	8d 50 01             	lea    0x1(%eax),%edx
c0107cc4:	89 55 08             	mov    %edx,0x8(%ebp)
c0107cc7:	0f b6 00             	movzbl (%eax),%eax
c0107cca:	84 c0                	test   %al,%al
c0107ccc:	75 e5                	jne    c0107cb3 <strnlen+0x13>
    }
    return cnt;
c0107cce:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0107cd1:	c9                   	leave  
c0107cd2:	c3                   	ret    

c0107cd3 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c0107cd3:	f3 0f 1e fb          	endbr32 
c0107cd7:	55                   	push   %ebp
c0107cd8:	89 e5                	mov    %esp,%ebp
c0107cda:	57                   	push   %edi
c0107cdb:	56                   	push   %esi
c0107cdc:	83 ec 20             	sub    $0x20,%esp
c0107cdf:	8b 45 08             	mov    0x8(%ebp),%eax
c0107ce2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107ce5:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107ce8:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c0107ceb:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0107cee:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107cf1:	89 d1                	mov    %edx,%ecx
c0107cf3:	89 c2                	mov    %eax,%edx
c0107cf5:	89 ce                	mov    %ecx,%esi
c0107cf7:	89 d7                	mov    %edx,%edi
c0107cf9:	ac                   	lods   %ds:(%esi),%al
c0107cfa:	aa                   	stos   %al,%es:(%edi)
c0107cfb:	84 c0                	test   %al,%al
c0107cfd:	75 fa                	jne    c0107cf9 <strcpy+0x26>
c0107cff:	89 fa                	mov    %edi,%edx
c0107d01:	89 f1                	mov    %esi,%ecx
c0107d03:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0107d06:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0107d09:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c0107d0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c0107d0f:	83 c4 20             	add    $0x20,%esp
c0107d12:	5e                   	pop    %esi
c0107d13:	5f                   	pop    %edi
c0107d14:	5d                   	pop    %ebp
c0107d15:	c3                   	ret    

c0107d16 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c0107d16:	f3 0f 1e fb          	endbr32 
c0107d1a:	55                   	push   %ebp
c0107d1b:	89 e5                	mov    %esp,%ebp
c0107d1d:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c0107d20:	8b 45 08             	mov    0x8(%ebp),%eax
c0107d23:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c0107d26:	eb 1e                	jmp    c0107d46 <strncpy+0x30>
        if ((*p = *src) != '\0') {
c0107d28:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107d2b:	0f b6 10             	movzbl (%eax),%edx
c0107d2e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107d31:	88 10                	mov    %dl,(%eax)
c0107d33:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107d36:	0f b6 00             	movzbl (%eax),%eax
c0107d39:	84 c0                	test   %al,%al
c0107d3b:	74 03                	je     c0107d40 <strncpy+0x2a>
            src ++;
c0107d3d:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
c0107d40:	ff 45 fc             	incl   -0x4(%ebp)
c0107d43:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
c0107d46:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0107d4a:	75 dc                	jne    c0107d28 <strncpy+0x12>
    }
    return dst;
c0107d4c:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0107d4f:	c9                   	leave  
c0107d50:	c3                   	ret    

c0107d51 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c0107d51:	f3 0f 1e fb          	endbr32 
c0107d55:	55                   	push   %ebp
c0107d56:	89 e5                	mov    %esp,%ebp
c0107d58:	57                   	push   %edi
c0107d59:	56                   	push   %esi
c0107d5a:	83 ec 20             	sub    $0x20,%esp
c0107d5d:	8b 45 08             	mov    0x8(%ebp),%eax
c0107d60:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107d63:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107d66:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
c0107d69:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107d6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107d6f:	89 d1                	mov    %edx,%ecx
c0107d71:	89 c2                	mov    %eax,%edx
c0107d73:	89 ce                	mov    %ecx,%esi
c0107d75:	89 d7                	mov    %edx,%edi
c0107d77:	ac                   	lods   %ds:(%esi),%al
c0107d78:	ae                   	scas   %es:(%edi),%al
c0107d79:	75 08                	jne    c0107d83 <strcmp+0x32>
c0107d7b:	84 c0                	test   %al,%al
c0107d7d:	75 f8                	jne    c0107d77 <strcmp+0x26>
c0107d7f:	31 c0                	xor    %eax,%eax
c0107d81:	eb 04                	jmp    c0107d87 <strcmp+0x36>
c0107d83:	19 c0                	sbb    %eax,%eax
c0107d85:	0c 01                	or     $0x1,%al
c0107d87:	89 fa                	mov    %edi,%edx
c0107d89:	89 f1                	mov    %esi,%ecx
c0107d8b:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107d8e:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0107d91:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
c0107d94:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c0107d97:	83 c4 20             	add    $0x20,%esp
c0107d9a:	5e                   	pop    %esi
c0107d9b:	5f                   	pop    %edi
c0107d9c:	5d                   	pop    %ebp
c0107d9d:	c3                   	ret    

c0107d9e <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c0107d9e:	f3 0f 1e fb          	endbr32 
c0107da2:	55                   	push   %ebp
c0107da3:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0107da5:	eb 09                	jmp    c0107db0 <strncmp+0x12>
        n --, s1 ++, s2 ++;
c0107da7:	ff 4d 10             	decl   0x10(%ebp)
c0107daa:	ff 45 08             	incl   0x8(%ebp)
c0107dad:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0107db0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0107db4:	74 1a                	je     c0107dd0 <strncmp+0x32>
c0107db6:	8b 45 08             	mov    0x8(%ebp),%eax
c0107db9:	0f b6 00             	movzbl (%eax),%eax
c0107dbc:	84 c0                	test   %al,%al
c0107dbe:	74 10                	je     c0107dd0 <strncmp+0x32>
c0107dc0:	8b 45 08             	mov    0x8(%ebp),%eax
c0107dc3:	0f b6 10             	movzbl (%eax),%edx
c0107dc6:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107dc9:	0f b6 00             	movzbl (%eax),%eax
c0107dcc:	38 c2                	cmp    %al,%dl
c0107dce:	74 d7                	je     c0107da7 <strncmp+0x9>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c0107dd0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0107dd4:	74 18                	je     c0107dee <strncmp+0x50>
c0107dd6:	8b 45 08             	mov    0x8(%ebp),%eax
c0107dd9:	0f b6 00             	movzbl (%eax),%eax
c0107ddc:	0f b6 d0             	movzbl %al,%edx
c0107ddf:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107de2:	0f b6 00             	movzbl (%eax),%eax
c0107de5:	0f b6 c0             	movzbl %al,%eax
c0107de8:	29 c2                	sub    %eax,%edx
c0107dea:	89 d0                	mov    %edx,%eax
c0107dec:	eb 05                	jmp    c0107df3 <strncmp+0x55>
c0107dee:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107df3:	5d                   	pop    %ebp
c0107df4:	c3                   	ret    

c0107df5 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c0107df5:	f3 0f 1e fb          	endbr32 
c0107df9:	55                   	push   %ebp
c0107dfa:	89 e5                	mov    %esp,%ebp
c0107dfc:	83 ec 04             	sub    $0x4,%esp
c0107dff:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107e02:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0107e05:	eb 13                	jmp    c0107e1a <strchr+0x25>
        if (*s == c) {
c0107e07:	8b 45 08             	mov    0x8(%ebp),%eax
c0107e0a:	0f b6 00             	movzbl (%eax),%eax
c0107e0d:	38 45 fc             	cmp    %al,-0x4(%ebp)
c0107e10:	75 05                	jne    c0107e17 <strchr+0x22>
            return (char *)s;
c0107e12:	8b 45 08             	mov    0x8(%ebp),%eax
c0107e15:	eb 12                	jmp    c0107e29 <strchr+0x34>
        }
        s ++;
c0107e17:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c0107e1a:	8b 45 08             	mov    0x8(%ebp),%eax
c0107e1d:	0f b6 00             	movzbl (%eax),%eax
c0107e20:	84 c0                	test   %al,%al
c0107e22:	75 e3                	jne    c0107e07 <strchr+0x12>
    }
    return NULL;
c0107e24:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107e29:	c9                   	leave  
c0107e2a:	c3                   	ret    

c0107e2b <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c0107e2b:	f3 0f 1e fb          	endbr32 
c0107e2f:	55                   	push   %ebp
c0107e30:	89 e5                	mov    %esp,%ebp
c0107e32:	83 ec 04             	sub    $0x4,%esp
c0107e35:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107e38:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0107e3b:	eb 0e                	jmp    c0107e4b <strfind+0x20>
        if (*s == c) {
c0107e3d:	8b 45 08             	mov    0x8(%ebp),%eax
c0107e40:	0f b6 00             	movzbl (%eax),%eax
c0107e43:	38 45 fc             	cmp    %al,-0x4(%ebp)
c0107e46:	74 0f                	je     c0107e57 <strfind+0x2c>
            break;
        }
        s ++;
c0107e48:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c0107e4b:	8b 45 08             	mov    0x8(%ebp),%eax
c0107e4e:	0f b6 00             	movzbl (%eax),%eax
c0107e51:	84 c0                	test   %al,%al
c0107e53:	75 e8                	jne    c0107e3d <strfind+0x12>
c0107e55:	eb 01                	jmp    c0107e58 <strfind+0x2d>
            break;
c0107e57:	90                   	nop
    }
    return (char *)s;
c0107e58:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0107e5b:	c9                   	leave  
c0107e5c:	c3                   	ret    

c0107e5d <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c0107e5d:	f3 0f 1e fb          	endbr32 
c0107e61:	55                   	push   %ebp
c0107e62:	89 e5                	mov    %esp,%ebp
c0107e64:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c0107e67:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c0107e6e:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0107e75:	eb 03                	jmp    c0107e7a <strtol+0x1d>
        s ++;
c0107e77:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
c0107e7a:	8b 45 08             	mov    0x8(%ebp),%eax
c0107e7d:	0f b6 00             	movzbl (%eax),%eax
c0107e80:	3c 20                	cmp    $0x20,%al
c0107e82:	74 f3                	je     c0107e77 <strtol+0x1a>
c0107e84:	8b 45 08             	mov    0x8(%ebp),%eax
c0107e87:	0f b6 00             	movzbl (%eax),%eax
c0107e8a:	3c 09                	cmp    $0x9,%al
c0107e8c:	74 e9                	je     c0107e77 <strtol+0x1a>
    }

    // plus/minus sign
    if (*s == '+') {
c0107e8e:	8b 45 08             	mov    0x8(%ebp),%eax
c0107e91:	0f b6 00             	movzbl (%eax),%eax
c0107e94:	3c 2b                	cmp    $0x2b,%al
c0107e96:	75 05                	jne    c0107e9d <strtol+0x40>
        s ++;
c0107e98:	ff 45 08             	incl   0x8(%ebp)
c0107e9b:	eb 14                	jmp    c0107eb1 <strtol+0x54>
    }
    else if (*s == '-') {
c0107e9d:	8b 45 08             	mov    0x8(%ebp),%eax
c0107ea0:	0f b6 00             	movzbl (%eax),%eax
c0107ea3:	3c 2d                	cmp    $0x2d,%al
c0107ea5:	75 0a                	jne    c0107eb1 <strtol+0x54>
        s ++, neg = 1;
c0107ea7:	ff 45 08             	incl   0x8(%ebp)
c0107eaa:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c0107eb1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0107eb5:	74 06                	je     c0107ebd <strtol+0x60>
c0107eb7:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c0107ebb:	75 22                	jne    c0107edf <strtol+0x82>
c0107ebd:	8b 45 08             	mov    0x8(%ebp),%eax
c0107ec0:	0f b6 00             	movzbl (%eax),%eax
c0107ec3:	3c 30                	cmp    $0x30,%al
c0107ec5:	75 18                	jne    c0107edf <strtol+0x82>
c0107ec7:	8b 45 08             	mov    0x8(%ebp),%eax
c0107eca:	40                   	inc    %eax
c0107ecb:	0f b6 00             	movzbl (%eax),%eax
c0107ece:	3c 78                	cmp    $0x78,%al
c0107ed0:	75 0d                	jne    c0107edf <strtol+0x82>
        s += 2, base = 16;
c0107ed2:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c0107ed6:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c0107edd:	eb 29                	jmp    c0107f08 <strtol+0xab>
    }
    else if (base == 0 && s[0] == '0') {
c0107edf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0107ee3:	75 16                	jne    c0107efb <strtol+0x9e>
c0107ee5:	8b 45 08             	mov    0x8(%ebp),%eax
c0107ee8:	0f b6 00             	movzbl (%eax),%eax
c0107eeb:	3c 30                	cmp    $0x30,%al
c0107eed:	75 0c                	jne    c0107efb <strtol+0x9e>
        s ++, base = 8;
c0107eef:	ff 45 08             	incl   0x8(%ebp)
c0107ef2:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c0107ef9:	eb 0d                	jmp    c0107f08 <strtol+0xab>
    }
    else if (base == 0) {
c0107efb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0107eff:	75 07                	jne    c0107f08 <strtol+0xab>
        base = 10;
c0107f01:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c0107f08:	8b 45 08             	mov    0x8(%ebp),%eax
c0107f0b:	0f b6 00             	movzbl (%eax),%eax
c0107f0e:	3c 2f                	cmp    $0x2f,%al
c0107f10:	7e 1b                	jle    c0107f2d <strtol+0xd0>
c0107f12:	8b 45 08             	mov    0x8(%ebp),%eax
c0107f15:	0f b6 00             	movzbl (%eax),%eax
c0107f18:	3c 39                	cmp    $0x39,%al
c0107f1a:	7f 11                	jg     c0107f2d <strtol+0xd0>
            dig = *s - '0';
c0107f1c:	8b 45 08             	mov    0x8(%ebp),%eax
c0107f1f:	0f b6 00             	movzbl (%eax),%eax
c0107f22:	0f be c0             	movsbl %al,%eax
c0107f25:	83 e8 30             	sub    $0x30,%eax
c0107f28:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107f2b:	eb 48                	jmp    c0107f75 <strtol+0x118>
        }
        else if (*s >= 'a' && *s <= 'z') {
c0107f2d:	8b 45 08             	mov    0x8(%ebp),%eax
c0107f30:	0f b6 00             	movzbl (%eax),%eax
c0107f33:	3c 60                	cmp    $0x60,%al
c0107f35:	7e 1b                	jle    c0107f52 <strtol+0xf5>
c0107f37:	8b 45 08             	mov    0x8(%ebp),%eax
c0107f3a:	0f b6 00             	movzbl (%eax),%eax
c0107f3d:	3c 7a                	cmp    $0x7a,%al
c0107f3f:	7f 11                	jg     c0107f52 <strtol+0xf5>
            dig = *s - 'a' + 10;
c0107f41:	8b 45 08             	mov    0x8(%ebp),%eax
c0107f44:	0f b6 00             	movzbl (%eax),%eax
c0107f47:	0f be c0             	movsbl %al,%eax
c0107f4a:	83 e8 57             	sub    $0x57,%eax
c0107f4d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107f50:	eb 23                	jmp    c0107f75 <strtol+0x118>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c0107f52:	8b 45 08             	mov    0x8(%ebp),%eax
c0107f55:	0f b6 00             	movzbl (%eax),%eax
c0107f58:	3c 40                	cmp    $0x40,%al
c0107f5a:	7e 3b                	jle    c0107f97 <strtol+0x13a>
c0107f5c:	8b 45 08             	mov    0x8(%ebp),%eax
c0107f5f:	0f b6 00             	movzbl (%eax),%eax
c0107f62:	3c 5a                	cmp    $0x5a,%al
c0107f64:	7f 31                	jg     c0107f97 <strtol+0x13a>
            dig = *s - 'A' + 10;
c0107f66:	8b 45 08             	mov    0x8(%ebp),%eax
c0107f69:	0f b6 00             	movzbl (%eax),%eax
c0107f6c:	0f be c0             	movsbl %al,%eax
c0107f6f:	83 e8 37             	sub    $0x37,%eax
c0107f72:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c0107f75:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107f78:	3b 45 10             	cmp    0x10(%ebp),%eax
c0107f7b:	7d 19                	jge    c0107f96 <strtol+0x139>
            break;
        }
        s ++, val = (val * base) + dig;
c0107f7d:	ff 45 08             	incl   0x8(%ebp)
c0107f80:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0107f83:	0f af 45 10          	imul   0x10(%ebp),%eax
c0107f87:	89 c2                	mov    %eax,%edx
c0107f89:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107f8c:	01 d0                	add    %edx,%eax
c0107f8e:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
c0107f91:	e9 72 ff ff ff       	jmp    c0107f08 <strtol+0xab>
            break;
c0107f96:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
c0107f97:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0107f9b:	74 08                	je     c0107fa5 <strtol+0x148>
        *endptr = (char *) s;
c0107f9d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107fa0:	8b 55 08             	mov    0x8(%ebp),%edx
c0107fa3:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c0107fa5:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0107fa9:	74 07                	je     c0107fb2 <strtol+0x155>
c0107fab:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0107fae:	f7 d8                	neg    %eax
c0107fb0:	eb 03                	jmp    c0107fb5 <strtol+0x158>
c0107fb2:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c0107fb5:	c9                   	leave  
c0107fb6:	c3                   	ret    

c0107fb7 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c0107fb7:	f3 0f 1e fb          	endbr32 
c0107fbb:	55                   	push   %ebp
c0107fbc:	89 e5                	mov    %esp,%ebp
c0107fbe:	57                   	push   %edi
c0107fbf:	83 ec 24             	sub    $0x24,%esp
c0107fc2:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107fc5:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c0107fc8:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
c0107fcc:	8b 45 08             	mov    0x8(%ebp),%eax
c0107fcf:	89 45 f8             	mov    %eax,-0x8(%ebp)
c0107fd2:	88 55 f7             	mov    %dl,-0x9(%ebp)
c0107fd5:	8b 45 10             	mov    0x10(%ebp),%eax
c0107fd8:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c0107fdb:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0107fde:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c0107fe2:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0107fe5:	89 d7                	mov    %edx,%edi
c0107fe7:	f3 aa                	rep stos %al,%es:(%edi)
c0107fe9:	89 fa                	mov    %edi,%edx
c0107feb:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0107fee:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c0107ff1:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c0107ff4:	83 c4 24             	add    $0x24,%esp
c0107ff7:	5f                   	pop    %edi
c0107ff8:	5d                   	pop    %ebp
c0107ff9:	c3                   	ret    

c0107ffa <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c0107ffa:	f3 0f 1e fb          	endbr32 
c0107ffe:	55                   	push   %ebp
c0107fff:	89 e5                	mov    %esp,%ebp
c0108001:	57                   	push   %edi
c0108002:	56                   	push   %esi
c0108003:	53                   	push   %ebx
c0108004:	83 ec 30             	sub    $0x30,%esp
c0108007:	8b 45 08             	mov    0x8(%ebp),%eax
c010800a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010800d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108010:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108013:	8b 45 10             	mov    0x10(%ebp),%eax
c0108016:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c0108019:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010801c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010801f:	73 42                	jae    c0108063 <memmove+0x69>
c0108021:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108024:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0108027:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010802a:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010802d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108030:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0108033:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108036:	c1 e8 02             	shr    $0x2,%eax
c0108039:	89 c1                	mov    %eax,%ecx
    asm volatile (
c010803b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010803e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108041:	89 d7                	mov    %edx,%edi
c0108043:	89 c6                	mov    %eax,%esi
c0108045:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0108047:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c010804a:	83 e1 03             	and    $0x3,%ecx
c010804d:	74 02                	je     c0108051 <memmove+0x57>
c010804f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0108051:	89 f0                	mov    %esi,%eax
c0108053:	89 fa                	mov    %edi,%edx
c0108055:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c0108058:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010805b:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
c010805e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
        return __memcpy(dst, src, n);
c0108061:	eb 36                	jmp    c0108099 <memmove+0x9f>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c0108063:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108066:	8d 50 ff             	lea    -0x1(%eax),%edx
c0108069:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010806c:	01 c2                	add    %eax,%edx
c010806e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108071:	8d 48 ff             	lea    -0x1(%eax),%ecx
c0108074:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108077:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
c010807a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010807d:	89 c1                	mov    %eax,%ecx
c010807f:	89 d8                	mov    %ebx,%eax
c0108081:	89 d6                	mov    %edx,%esi
c0108083:	89 c7                	mov    %eax,%edi
c0108085:	fd                   	std    
c0108086:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0108088:	fc                   	cld    
c0108089:	89 f8                	mov    %edi,%eax
c010808b:	89 f2                	mov    %esi,%edx
c010808d:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c0108090:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0108093:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
c0108096:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c0108099:	83 c4 30             	add    $0x30,%esp
c010809c:	5b                   	pop    %ebx
c010809d:	5e                   	pop    %esi
c010809e:	5f                   	pop    %edi
c010809f:	5d                   	pop    %ebp
c01080a0:	c3                   	ret    

c01080a1 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c01080a1:	f3 0f 1e fb          	endbr32 
c01080a5:	55                   	push   %ebp
c01080a6:	89 e5                	mov    %esp,%ebp
c01080a8:	57                   	push   %edi
c01080a9:	56                   	push   %esi
c01080aa:	83 ec 20             	sub    $0x20,%esp
c01080ad:	8b 45 08             	mov    0x8(%ebp),%eax
c01080b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01080b3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01080b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01080b9:	8b 45 10             	mov    0x10(%ebp),%eax
c01080bc:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c01080bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01080c2:	c1 e8 02             	shr    $0x2,%eax
c01080c5:	89 c1                	mov    %eax,%ecx
    asm volatile (
c01080c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01080ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01080cd:	89 d7                	mov    %edx,%edi
c01080cf:	89 c6                	mov    %eax,%esi
c01080d1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c01080d3:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c01080d6:	83 e1 03             	and    $0x3,%ecx
c01080d9:	74 02                	je     c01080dd <memcpy+0x3c>
c01080db:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c01080dd:	89 f0                	mov    %esi,%eax
c01080df:	89 fa                	mov    %edi,%edx
c01080e1:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c01080e4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c01080e7:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
c01080ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c01080ed:	83 c4 20             	add    $0x20,%esp
c01080f0:	5e                   	pop    %esi
c01080f1:	5f                   	pop    %edi
c01080f2:	5d                   	pop    %ebp
c01080f3:	c3                   	ret    

c01080f4 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c01080f4:	f3 0f 1e fb          	endbr32 
c01080f8:	55                   	push   %ebp
c01080f9:	89 e5                	mov    %esp,%ebp
c01080fb:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c01080fe:	8b 45 08             	mov    0x8(%ebp),%eax
c0108101:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c0108104:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108107:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c010810a:	eb 2e                	jmp    c010813a <memcmp+0x46>
        if (*s1 != *s2) {
c010810c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010810f:	0f b6 10             	movzbl (%eax),%edx
c0108112:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0108115:	0f b6 00             	movzbl (%eax),%eax
c0108118:	38 c2                	cmp    %al,%dl
c010811a:	74 18                	je     c0108134 <memcmp+0x40>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c010811c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010811f:	0f b6 00             	movzbl (%eax),%eax
c0108122:	0f b6 d0             	movzbl %al,%edx
c0108125:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0108128:	0f b6 00             	movzbl (%eax),%eax
c010812b:	0f b6 c0             	movzbl %al,%eax
c010812e:	29 c2                	sub    %eax,%edx
c0108130:	89 d0                	mov    %edx,%eax
c0108132:	eb 18                	jmp    c010814c <memcmp+0x58>
        }
        s1 ++, s2 ++;
c0108134:	ff 45 fc             	incl   -0x4(%ebp)
c0108137:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
c010813a:	8b 45 10             	mov    0x10(%ebp),%eax
c010813d:	8d 50 ff             	lea    -0x1(%eax),%edx
c0108140:	89 55 10             	mov    %edx,0x10(%ebp)
c0108143:	85 c0                	test   %eax,%eax
c0108145:	75 c5                	jne    c010810c <memcmp+0x18>
    }
    return 0;
c0108147:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010814c:	c9                   	leave  
c010814d:	c3                   	ret    

c010814e <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c010814e:	f3 0f 1e fb          	endbr32 
c0108152:	55                   	push   %ebp
c0108153:	89 e5                	mov    %esp,%ebp
c0108155:	83 ec 58             	sub    $0x58,%esp
c0108158:	8b 45 10             	mov    0x10(%ebp),%eax
c010815b:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010815e:	8b 45 14             	mov    0x14(%ebp),%eax
c0108161:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c0108164:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0108167:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010816a:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010816d:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c0108170:	8b 45 18             	mov    0x18(%ebp),%eax
c0108173:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0108176:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108179:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010817c:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010817f:	89 55 f0             	mov    %edx,-0x10(%ebp)
c0108182:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108185:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108188:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010818c:	74 1c                	je     c01081aa <printnum+0x5c>
c010818e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108191:	ba 00 00 00 00       	mov    $0x0,%edx
c0108196:	f7 75 e4             	divl   -0x1c(%ebp)
c0108199:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010819c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010819f:	ba 00 00 00 00       	mov    $0x0,%edx
c01081a4:	f7 75 e4             	divl   -0x1c(%ebp)
c01081a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01081aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01081ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01081b0:	f7 75 e4             	divl   -0x1c(%ebp)
c01081b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01081b6:	89 55 dc             	mov    %edx,-0x24(%ebp)
c01081b9:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01081bc:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01081bf:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01081c2:	89 55 ec             	mov    %edx,-0x14(%ebp)
c01081c5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01081c8:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c01081cb:	8b 45 18             	mov    0x18(%ebp),%eax
c01081ce:	ba 00 00 00 00       	mov    $0x0,%edx
c01081d3:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c01081d6:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c01081d9:	19 d1                	sbb    %edx,%ecx
c01081db:	72 4c                	jb     c0108229 <printnum+0xdb>
        printnum(putch, putdat, result, base, width - 1, padc);
c01081dd:	8b 45 1c             	mov    0x1c(%ebp),%eax
c01081e0:	8d 50 ff             	lea    -0x1(%eax),%edx
c01081e3:	8b 45 20             	mov    0x20(%ebp),%eax
c01081e6:	89 44 24 18          	mov    %eax,0x18(%esp)
c01081ea:	89 54 24 14          	mov    %edx,0x14(%esp)
c01081ee:	8b 45 18             	mov    0x18(%ebp),%eax
c01081f1:	89 44 24 10          	mov    %eax,0x10(%esp)
c01081f5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01081f8:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01081fb:	89 44 24 08          	mov    %eax,0x8(%esp)
c01081ff:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0108203:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108206:	89 44 24 04          	mov    %eax,0x4(%esp)
c010820a:	8b 45 08             	mov    0x8(%ebp),%eax
c010820d:	89 04 24             	mov    %eax,(%esp)
c0108210:	e8 39 ff ff ff       	call   c010814e <printnum>
c0108215:	eb 1b                	jmp    c0108232 <printnum+0xe4>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c0108217:	8b 45 0c             	mov    0xc(%ebp),%eax
c010821a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010821e:	8b 45 20             	mov    0x20(%ebp),%eax
c0108221:	89 04 24             	mov    %eax,(%esp)
c0108224:	8b 45 08             	mov    0x8(%ebp),%eax
c0108227:	ff d0                	call   *%eax
        while (-- width > 0)
c0108229:	ff 4d 1c             	decl   0x1c(%ebp)
c010822c:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0108230:	7f e5                	jg     c0108217 <printnum+0xc9>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c0108232:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108235:	05 08 a7 10 c0       	add    $0xc010a708,%eax
c010823a:	0f b6 00             	movzbl (%eax),%eax
c010823d:	0f be c0             	movsbl %al,%eax
c0108240:	8b 55 0c             	mov    0xc(%ebp),%edx
c0108243:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108247:	89 04 24             	mov    %eax,(%esp)
c010824a:	8b 45 08             	mov    0x8(%ebp),%eax
c010824d:	ff d0                	call   *%eax
}
c010824f:	90                   	nop
c0108250:	c9                   	leave  
c0108251:	c3                   	ret    

c0108252 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c0108252:	f3 0f 1e fb          	endbr32 
c0108256:	55                   	push   %ebp
c0108257:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0108259:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c010825d:	7e 14                	jle    c0108273 <getuint+0x21>
        return va_arg(*ap, unsigned long long);
c010825f:	8b 45 08             	mov    0x8(%ebp),%eax
c0108262:	8b 00                	mov    (%eax),%eax
c0108264:	8d 48 08             	lea    0x8(%eax),%ecx
c0108267:	8b 55 08             	mov    0x8(%ebp),%edx
c010826a:	89 0a                	mov    %ecx,(%edx)
c010826c:	8b 50 04             	mov    0x4(%eax),%edx
c010826f:	8b 00                	mov    (%eax),%eax
c0108271:	eb 30                	jmp    c01082a3 <getuint+0x51>
    }
    else if (lflag) {
c0108273:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0108277:	74 16                	je     c010828f <getuint+0x3d>
        return va_arg(*ap, unsigned long);
c0108279:	8b 45 08             	mov    0x8(%ebp),%eax
c010827c:	8b 00                	mov    (%eax),%eax
c010827e:	8d 48 04             	lea    0x4(%eax),%ecx
c0108281:	8b 55 08             	mov    0x8(%ebp),%edx
c0108284:	89 0a                	mov    %ecx,(%edx)
c0108286:	8b 00                	mov    (%eax),%eax
c0108288:	ba 00 00 00 00       	mov    $0x0,%edx
c010828d:	eb 14                	jmp    c01082a3 <getuint+0x51>
    }
    else {
        return va_arg(*ap, unsigned int);
c010828f:	8b 45 08             	mov    0x8(%ebp),%eax
c0108292:	8b 00                	mov    (%eax),%eax
c0108294:	8d 48 04             	lea    0x4(%eax),%ecx
c0108297:	8b 55 08             	mov    0x8(%ebp),%edx
c010829a:	89 0a                	mov    %ecx,(%edx)
c010829c:	8b 00                	mov    (%eax),%eax
c010829e:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c01082a3:	5d                   	pop    %ebp
c01082a4:	c3                   	ret    

c01082a5 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c01082a5:	f3 0f 1e fb          	endbr32 
c01082a9:	55                   	push   %ebp
c01082aa:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c01082ac:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c01082b0:	7e 14                	jle    c01082c6 <getint+0x21>
        return va_arg(*ap, long long);
c01082b2:	8b 45 08             	mov    0x8(%ebp),%eax
c01082b5:	8b 00                	mov    (%eax),%eax
c01082b7:	8d 48 08             	lea    0x8(%eax),%ecx
c01082ba:	8b 55 08             	mov    0x8(%ebp),%edx
c01082bd:	89 0a                	mov    %ecx,(%edx)
c01082bf:	8b 50 04             	mov    0x4(%eax),%edx
c01082c2:	8b 00                	mov    (%eax),%eax
c01082c4:	eb 28                	jmp    c01082ee <getint+0x49>
    }
    else if (lflag) {
c01082c6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01082ca:	74 12                	je     c01082de <getint+0x39>
        return va_arg(*ap, long);
c01082cc:	8b 45 08             	mov    0x8(%ebp),%eax
c01082cf:	8b 00                	mov    (%eax),%eax
c01082d1:	8d 48 04             	lea    0x4(%eax),%ecx
c01082d4:	8b 55 08             	mov    0x8(%ebp),%edx
c01082d7:	89 0a                	mov    %ecx,(%edx)
c01082d9:	8b 00                	mov    (%eax),%eax
c01082db:	99                   	cltd   
c01082dc:	eb 10                	jmp    c01082ee <getint+0x49>
    }
    else {
        return va_arg(*ap, int);
c01082de:	8b 45 08             	mov    0x8(%ebp),%eax
c01082e1:	8b 00                	mov    (%eax),%eax
c01082e3:	8d 48 04             	lea    0x4(%eax),%ecx
c01082e6:	8b 55 08             	mov    0x8(%ebp),%edx
c01082e9:	89 0a                	mov    %ecx,(%edx)
c01082eb:	8b 00                	mov    (%eax),%eax
c01082ed:	99                   	cltd   
    }
}
c01082ee:	5d                   	pop    %ebp
c01082ef:	c3                   	ret    

c01082f0 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c01082f0:	f3 0f 1e fb          	endbr32 
c01082f4:	55                   	push   %ebp
c01082f5:	89 e5                	mov    %esp,%ebp
c01082f7:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c01082fa:	8d 45 14             	lea    0x14(%ebp),%eax
c01082fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c0108300:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108303:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108307:	8b 45 10             	mov    0x10(%ebp),%eax
c010830a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010830e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108311:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108315:	8b 45 08             	mov    0x8(%ebp),%eax
c0108318:	89 04 24             	mov    %eax,(%esp)
c010831b:	e8 03 00 00 00       	call   c0108323 <vprintfmt>
    va_end(ap);
}
c0108320:	90                   	nop
c0108321:	c9                   	leave  
c0108322:	c3                   	ret    

c0108323 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c0108323:	f3 0f 1e fb          	endbr32 
c0108327:	55                   	push   %ebp
c0108328:	89 e5                	mov    %esp,%ebp
c010832a:	56                   	push   %esi
c010832b:	53                   	push   %ebx
c010832c:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010832f:	eb 17                	jmp    c0108348 <vprintfmt+0x25>
            if (ch == '\0') {
c0108331:	85 db                	test   %ebx,%ebx
c0108333:	0f 84 c0 03 00 00    	je     c01086f9 <vprintfmt+0x3d6>
                return;
            }
            putch(ch, putdat);
c0108339:	8b 45 0c             	mov    0xc(%ebp),%eax
c010833c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108340:	89 1c 24             	mov    %ebx,(%esp)
c0108343:	8b 45 08             	mov    0x8(%ebp),%eax
c0108346:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0108348:	8b 45 10             	mov    0x10(%ebp),%eax
c010834b:	8d 50 01             	lea    0x1(%eax),%edx
c010834e:	89 55 10             	mov    %edx,0x10(%ebp)
c0108351:	0f b6 00             	movzbl (%eax),%eax
c0108354:	0f b6 d8             	movzbl %al,%ebx
c0108357:	83 fb 25             	cmp    $0x25,%ebx
c010835a:	75 d5                	jne    c0108331 <vprintfmt+0xe>
        }

        // Process a %-escape sequence
        char padc = ' ';
c010835c:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c0108360:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c0108367:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010836a:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c010836d:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0108374:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108377:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c010837a:	8b 45 10             	mov    0x10(%ebp),%eax
c010837d:	8d 50 01             	lea    0x1(%eax),%edx
c0108380:	89 55 10             	mov    %edx,0x10(%ebp)
c0108383:	0f b6 00             	movzbl (%eax),%eax
c0108386:	0f b6 d8             	movzbl %al,%ebx
c0108389:	8d 43 dd             	lea    -0x23(%ebx),%eax
c010838c:	83 f8 55             	cmp    $0x55,%eax
c010838f:	0f 87 38 03 00 00    	ja     c01086cd <vprintfmt+0x3aa>
c0108395:	8b 04 85 2c a7 10 c0 	mov    -0x3fef58d4(,%eax,4),%eax
c010839c:	3e ff e0             	notrack jmp *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c010839f:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c01083a3:	eb d5                	jmp    c010837a <vprintfmt+0x57>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c01083a5:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c01083a9:	eb cf                	jmp    c010837a <vprintfmt+0x57>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c01083ab:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c01083b2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01083b5:	89 d0                	mov    %edx,%eax
c01083b7:	c1 e0 02             	shl    $0x2,%eax
c01083ba:	01 d0                	add    %edx,%eax
c01083bc:	01 c0                	add    %eax,%eax
c01083be:	01 d8                	add    %ebx,%eax
c01083c0:	83 e8 30             	sub    $0x30,%eax
c01083c3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c01083c6:	8b 45 10             	mov    0x10(%ebp),%eax
c01083c9:	0f b6 00             	movzbl (%eax),%eax
c01083cc:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c01083cf:	83 fb 2f             	cmp    $0x2f,%ebx
c01083d2:	7e 38                	jle    c010840c <vprintfmt+0xe9>
c01083d4:	83 fb 39             	cmp    $0x39,%ebx
c01083d7:	7f 33                	jg     c010840c <vprintfmt+0xe9>
            for (precision = 0; ; ++ fmt) {
c01083d9:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
c01083dc:	eb d4                	jmp    c01083b2 <vprintfmt+0x8f>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
c01083de:	8b 45 14             	mov    0x14(%ebp),%eax
c01083e1:	8d 50 04             	lea    0x4(%eax),%edx
c01083e4:	89 55 14             	mov    %edx,0x14(%ebp)
c01083e7:	8b 00                	mov    (%eax),%eax
c01083e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c01083ec:	eb 1f                	jmp    c010840d <vprintfmt+0xea>

        case '.':
            if (width < 0)
c01083ee:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01083f2:	79 86                	jns    c010837a <vprintfmt+0x57>
                width = 0;
c01083f4:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c01083fb:	e9 7a ff ff ff       	jmp    c010837a <vprintfmt+0x57>

        case '#':
            altflag = 1;
c0108400:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c0108407:	e9 6e ff ff ff       	jmp    c010837a <vprintfmt+0x57>
            goto process_precision;
c010840c:	90                   	nop

        process_precision:
            if (width < 0)
c010840d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0108411:	0f 89 63 ff ff ff    	jns    c010837a <vprintfmt+0x57>
                width = precision, precision = -1;
c0108417:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010841a:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010841d:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c0108424:	e9 51 ff ff ff       	jmp    c010837a <vprintfmt+0x57>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c0108429:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
c010842c:	e9 49 ff ff ff       	jmp    c010837a <vprintfmt+0x57>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c0108431:	8b 45 14             	mov    0x14(%ebp),%eax
c0108434:	8d 50 04             	lea    0x4(%eax),%edx
c0108437:	89 55 14             	mov    %edx,0x14(%ebp)
c010843a:	8b 00                	mov    (%eax),%eax
c010843c:	8b 55 0c             	mov    0xc(%ebp),%edx
c010843f:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108443:	89 04 24             	mov    %eax,(%esp)
c0108446:	8b 45 08             	mov    0x8(%ebp),%eax
c0108449:	ff d0                	call   *%eax
            break;
c010844b:	e9 a4 02 00 00       	jmp    c01086f4 <vprintfmt+0x3d1>

        // error message
        case 'e':
            err = va_arg(ap, int);
c0108450:	8b 45 14             	mov    0x14(%ebp),%eax
c0108453:	8d 50 04             	lea    0x4(%eax),%edx
c0108456:	89 55 14             	mov    %edx,0x14(%ebp)
c0108459:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c010845b:	85 db                	test   %ebx,%ebx
c010845d:	79 02                	jns    c0108461 <vprintfmt+0x13e>
                err = -err;
c010845f:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c0108461:	83 fb 06             	cmp    $0x6,%ebx
c0108464:	7f 0b                	jg     c0108471 <vprintfmt+0x14e>
c0108466:	8b 34 9d ec a6 10 c0 	mov    -0x3fef5914(,%ebx,4),%esi
c010846d:	85 f6                	test   %esi,%esi
c010846f:	75 23                	jne    c0108494 <vprintfmt+0x171>
                printfmt(putch, putdat, "error %d", err);
c0108471:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0108475:	c7 44 24 08 19 a7 10 	movl   $0xc010a719,0x8(%esp)
c010847c:	c0 
c010847d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108480:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108484:	8b 45 08             	mov    0x8(%ebp),%eax
c0108487:	89 04 24             	mov    %eax,(%esp)
c010848a:	e8 61 fe ff ff       	call   c01082f0 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c010848f:	e9 60 02 00 00       	jmp    c01086f4 <vprintfmt+0x3d1>
                printfmt(putch, putdat, "%s", p);
c0108494:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0108498:	c7 44 24 08 22 a7 10 	movl   $0xc010a722,0x8(%esp)
c010849f:	c0 
c01084a0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01084a3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01084a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01084aa:	89 04 24             	mov    %eax,(%esp)
c01084ad:	e8 3e fe ff ff       	call   c01082f0 <printfmt>
            break;
c01084b2:	e9 3d 02 00 00       	jmp    c01086f4 <vprintfmt+0x3d1>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c01084b7:	8b 45 14             	mov    0x14(%ebp),%eax
c01084ba:	8d 50 04             	lea    0x4(%eax),%edx
c01084bd:	89 55 14             	mov    %edx,0x14(%ebp)
c01084c0:	8b 30                	mov    (%eax),%esi
c01084c2:	85 f6                	test   %esi,%esi
c01084c4:	75 05                	jne    c01084cb <vprintfmt+0x1a8>
                p = "(null)";
c01084c6:	be 25 a7 10 c0       	mov    $0xc010a725,%esi
            }
            if (width > 0 && padc != '-') {
c01084cb:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01084cf:	7e 76                	jle    c0108547 <vprintfmt+0x224>
c01084d1:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c01084d5:	74 70                	je     c0108547 <vprintfmt+0x224>
                for (width -= strnlen(p, precision); width > 0; width --) {
c01084d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01084da:	89 44 24 04          	mov    %eax,0x4(%esp)
c01084de:	89 34 24             	mov    %esi,(%esp)
c01084e1:	e8 ba f7 ff ff       	call   c0107ca0 <strnlen>
c01084e6:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01084e9:	29 c2                	sub    %eax,%edx
c01084eb:	89 d0                	mov    %edx,%eax
c01084ed:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01084f0:	eb 16                	jmp    c0108508 <vprintfmt+0x1e5>
                    putch(padc, putdat);
c01084f2:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c01084f6:	8b 55 0c             	mov    0xc(%ebp),%edx
c01084f9:	89 54 24 04          	mov    %edx,0x4(%esp)
c01084fd:	89 04 24             	mov    %eax,(%esp)
c0108500:	8b 45 08             	mov    0x8(%ebp),%eax
c0108503:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
c0108505:	ff 4d e8             	decl   -0x18(%ebp)
c0108508:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010850c:	7f e4                	jg     c01084f2 <vprintfmt+0x1cf>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c010850e:	eb 37                	jmp    c0108547 <vprintfmt+0x224>
                if (altflag && (ch < ' ' || ch > '~')) {
c0108510:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0108514:	74 1f                	je     c0108535 <vprintfmt+0x212>
c0108516:	83 fb 1f             	cmp    $0x1f,%ebx
c0108519:	7e 05                	jle    c0108520 <vprintfmt+0x1fd>
c010851b:	83 fb 7e             	cmp    $0x7e,%ebx
c010851e:	7e 15                	jle    c0108535 <vprintfmt+0x212>
                    putch('?', putdat);
c0108520:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108523:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108527:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c010852e:	8b 45 08             	mov    0x8(%ebp),%eax
c0108531:	ff d0                	call   *%eax
c0108533:	eb 0f                	jmp    c0108544 <vprintfmt+0x221>
                }
                else {
                    putch(ch, putdat);
c0108535:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108538:	89 44 24 04          	mov    %eax,0x4(%esp)
c010853c:	89 1c 24             	mov    %ebx,(%esp)
c010853f:	8b 45 08             	mov    0x8(%ebp),%eax
c0108542:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0108544:	ff 4d e8             	decl   -0x18(%ebp)
c0108547:	89 f0                	mov    %esi,%eax
c0108549:	8d 70 01             	lea    0x1(%eax),%esi
c010854c:	0f b6 00             	movzbl (%eax),%eax
c010854f:	0f be d8             	movsbl %al,%ebx
c0108552:	85 db                	test   %ebx,%ebx
c0108554:	74 27                	je     c010857d <vprintfmt+0x25a>
c0108556:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010855a:	78 b4                	js     c0108510 <vprintfmt+0x1ed>
c010855c:	ff 4d e4             	decl   -0x1c(%ebp)
c010855f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0108563:	79 ab                	jns    c0108510 <vprintfmt+0x1ed>
                }
            }
            for (; width > 0; width --) {
c0108565:	eb 16                	jmp    c010857d <vprintfmt+0x25a>
                putch(' ', putdat);
c0108567:	8b 45 0c             	mov    0xc(%ebp),%eax
c010856a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010856e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0108575:	8b 45 08             	mov    0x8(%ebp),%eax
c0108578:	ff d0                	call   *%eax
            for (; width > 0; width --) {
c010857a:	ff 4d e8             	decl   -0x18(%ebp)
c010857d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0108581:	7f e4                	jg     c0108567 <vprintfmt+0x244>
            }
            break;
c0108583:	e9 6c 01 00 00       	jmp    c01086f4 <vprintfmt+0x3d1>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c0108588:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010858b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010858f:	8d 45 14             	lea    0x14(%ebp),%eax
c0108592:	89 04 24             	mov    %eax,(%esp)
c0108595:	e8 0b fd ff ff       	call   c01082a5 <getint>
c010859a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010859d:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c01085a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01085a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01085a6:	85 d2                	test   %edx,%edx
c01085a8:	79 26                	jns    c01085d0 <vprintfmt+0x2ad>
                putch('-', putdat);
c01085aa:	8b 45 0c             	mov    0xc(%ebp),%eax
c01085ad:	89 44 24 04          	mov    %eax,0x4(%esp)
c01085b1:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c01085b8:	8b 45 08             	mov    0x8(%ebp),%eax
c01085bb:	ff d0                	call   *%eax
                num = -(long long)num;
c01085bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01085c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01085c3:	f7 d8                	neg    %eax
c01085c5:	83 d2 00             	adc    $0x0,%edx
c01085c8:	f7 da                	neg    %edx
c01085ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01085cd:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c01085d0:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c01085d7:	e9 a8 00 00 00       	jmp    c0108684 <vprintfmt+0x361>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c01085dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01085df:	89 44 24 04          	mov    %eax,0x4(%esp)
c01085e3:	8d 45 14             	lea    0x14(%ebp),%eax
c01085e6:	89 04 24             	mov    %eax,(%esp)
c01085e9:	e8 64 fc ff ff       	call   c0108252 <getuint>
c01085ee:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01085f1:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c01085f4:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c01085fb:	e9 84 00 00 00       	jmp    c0108684 <vprintfmt+0x361>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c0108600:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108603:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108607:	8d 45 14             	lea    0x14(%ebp),%eax
c010860a:	89 04 24             	mov    %eax,(%esp)
c010860d:	e8 40 fc ff ff       	call   c0108252 <getuint>
c0108612:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108615:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c0108618:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c010861f:	eb 63                	jmp    c0108684 <vprintfmt+0x361>

        // pointer
        case 'p':
            putch('0', putdat);
c0108621:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108624:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108628:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c010862f:	8b 45 08             	mov    0x8(%ebp),%eax
c0108632:	ff d0                	call   *%eax
            putch('x', putdat);
c0108634:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108637:	89 44 24 04          	mov    %eax,0x4(%esp)
c010863b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c0108642:	8b 45 08             	mov    0x8(%ebp),%eax
c0108645:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c0108647:	8b 45 14             	mov    0x14(%ebp),%eax
c010864a:	8d 50 04             	lea    0x4(%eax),%edx
c010864d:	89 55 14             	mov    %edx,0x14(%ebp)
c0108650:	8b 00                	mov    (%eax),%eax
c0108652:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108655:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c010865c:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c0108663:	eb 1f                	jmp    c0108684 <vprintfmt+0x361>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c0108665:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108668:	89 44 24 04          	mov    %eax,0x4(%esp)
c010866c:	8d 45 14             	lea    0x14(%ebp),%eax
c010866f:	89 04 24             	mov    %eax,(%esp)
c0108672:	e8 db fb ff ff       	call   c0108252 <getuint>
c0108677:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010867a:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c010867d:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c0108684:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c0108688:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010868b:	89 54 24 18          	mov    %edx,0x18(%esp)
c010868f:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0108692:	89 54 24 14          	mov    %edx,0x14(%esp)
c0108696:	89 44 24 10          	mov    %eax,0x10(%esp)
c010869a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010869d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01086a0:	89 44 24 08          	mov    %eax,0x8(%esp)
c01086a4:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01086a8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01086ab:	89 44 24 04          	mov    %eax,0x4(%esp)
c01086af:	8b 45 08             	mov    0x8(%ebp),%eax
c01086b2:	89 04 24             	mov    %eax,(%esp)
c01086b5:	e8 94 fa ff ff       	call   c010814e <printnum>
            break;
c01086ba:	eb 38                	jmp    c01086f4 <vprintfmt+0x3d1>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c01086bc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01086bf:	89 44 24 04          	mov    %eax,0x4(%esp)
c01086c3:	89 1c 24             	mov    %ebx,(%esp)
c01086c6:	8b 45 08             	mov    0x8(%ebp),%eax
c01086c9:	ff d0                	call   *%eax
            break;
c01086cb:	eb 27                	jmp    c01086f4 <vprintfmt+0x3d1>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c01086cd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01086d0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01086d4:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c01086db:	8b 45 08             	mov    0x8(%ebp),%eax
c01086de:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c01086e0:	ff 4d 10             	decl   0x10(%ebp)
c01086e3:	eb 03                	jmp    c01086e8 <vprintfmt+0x3c5>
c01086e5:	ff 4d 10             	decl   0x10(%ebp)
c01086e8:	8b 45 10             	mov    0x10(%ebp),%eax
c01086eb:	48                   	dec    %eax
c01086ec:	0f b6 00             	movzbl (%eax),%eax
c01086ef:	3c 25                	cmp    $0x25,%al
c01086f1:	75 f2                	jne    c01086e5 <vprintfmt+0x3c2>
                /* do nothing */;
            break;
c01086f3:	90                   	nop
    while (1) {
c01086f4:	e9 36 fc ff ff       	jmp    c010832f <vprintfmt+0xc>
                return;
c01086f9:	90                   	nop
        }
    }
}
c01086fa:	83 c4 40             	add    $0x40,%esp
c01086fd:	5b                   	pop    %ebx
c01086fe:	5e                   	pop    %esi
c01086ff:	5d                   	pop    %ebp
c0108700:	c3                   	ret    

c0108701 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c0108701:	f3 0f 1e fb          	endbr32 
c0108705:	55                   	push   %ebp
c0108706:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c0108708:	8b 45 0c             	mov    0xc(%ebp),%eax
c010870b:	8b 40 08             	mov    0x8(%eax),%eax
c010870e:	8d 50 01             	lea    0x1(%eax),%edx
c0108711:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108714:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c0108717:	8b 45 0c             	mov    0xc(%ebp),%eax
c010871a:	8b 10                	mov    (%eax),%edx
c010871c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010871f:	8b 40 04             	mov    0x4(%eax),%eax
c0108722:	39 c2                	cmp    %eax,%edx
c0108724:	73 12                	jae    c0108738 <sprintputch+0x37>
        *b->buf ++ = ch;
c0108726:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108729:	8b 00                	mov    (%eax),%eax
c010872b:	8d 48 01             	lea    0x1(%eax),%ecx
c010872e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0108731:	89 0a                	mov    %ecx,(%edx)
c0108733:	8b 55 08             	mov    0x8(%ebp),%edx
c0108736:	88 10                	mov    %dl,(%eax)
    }
}
c0108738:	90                   	nop
c0108739:	5d                   	pop    %ebp
c010873a:	c3                   	ret    

c010873b <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c010873b:	f3 0f 1e fb          	endbr32 
c010873f:	55                   	push   %ebp
c0108740:	89 e5                	mov    %esp,%ebp
c0108742:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0108745:	8d 45 14             	lea    0x14(%ebp),%eax
c0108748:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c010874b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010874e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108752:	8b 45 10             	mov    0x10(%ebp),%eax
c0108755:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108759:	8b 45 0c             	mov    0xc(%ebp),%eax
c010875c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108760:	8b 45 08             	mov    0x8(%ebp),%eax
c0108763:	89 04 24             	mov    %eax,(%esp)
c0108766:	e8 08 00 00 00       	call   c0108773 <vsnprintf>
c010876b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c010876e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0108771:	c9                   	leave  
c0108772:	c3                   	ret    

c0108773 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c0108773:	f3 0f 1e fb          	endbr32 
c0108777:	55                   	push   %ebp
c0108778:	89 e5                	mov    %esp,%ebp
c010877a:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c010877d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108780:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108783:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108786:	8d 50 ff             	lea    -0x1(%eax),%edx
c0108789:	8b 45 08             	mov    0x8(%ebp),%eax
c010878c:	01 d0                	add    %edx,%eax
c010878e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108791:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c0108798:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010879c:	74 0a                	je     c01087a8 <vsnprintf+0x35>
c010879e:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01087a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01087a4:	39 c2                	cmp    %eax,%edx
c01087a6:	76 07                	jbe    c01087af <vsnprintf+0x3c>
        return -E_INVAL;
c01087a8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c01087ad:	eb 2a                	jmp    c01087d9 <vsnprintf+0x66>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c01087af:	8b 45 14             	mov    0x14(%ebp),%eax
c01087b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01087b6:	8b 45 10             	mov    0x10(%ebp),%eax
c01087b9:	89 44 24 08          	mov    %eax,0x8(%esp)
c01087bd:	8d 45 ec             	lea    -0x14(%ebp),%eax
c01087c0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01087c4:	c7 04 24 01 87 10 c0 	movl   $0xc0108701,(%esp)
c01087cb:	e8 53 fb ff ff       	call   c0108323 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c01087d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01087d3:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c01087d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01087d9:	c9                   	leave  
c01087da:	c3                   	ret    

c01087db <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
c01087db:	f3 0f 1e fb          	endbr32 
c01087df:	55                   	push   %ebp
c01087e0:	89 e5                	mov    %esp,%ebp
c01087e2:	57                   	push   %edi
c01087e3:	56                   	push   %esi
c01087e4:	53                   	push   %ebx
c01087e5:	83 ec 24             	sub    $0x24,%esp
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
c01087e8:	a1 60 2a 12 c0       	mov    0xc0122a60,%eax
c01087ed:	8b 15 64 2a 12 c0    	mov    0xc0122a64,%edx
c01087f3:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
c01087f9:	6b f0 05             	imul   $0x5,%eax,%esi
c01087fc:	01 fe                	add    %edi,%esi
c01087fe:	bf 6d e6 ec de       	mov    $0xdeece66d,%edi
c0108803:	f7 e7                	mul    %edi
c0108805:	01 d6                	add    %edx,%esi
c0108807:	89 f2                	mov    %esi,%edx
c0108809:	83 c0 0b             	add    $0xb,%eax
c010880c:	83 d2 00             	adc    $0x0,%edx
c010880f:	89 c7                	mov    %eax,%edi
c0108811:	83 e7 ff             	and    $0xffffffff,%edi
c0108814:	89 f9                	mov    %edi,%ecx
c0108816:	0f b7 da             	movzwl %dx,%ebx
c0108819:	89 0d 60 2a 12 c0    	mov    %ecx,0xc0122a60
c010881f:	89 1d 64 2a 12 c0    	mov    %ebx,0xc0122a64
    unsigned long long result = (next >> 12);
c0108825:	a1 60 2a 12 c0       	mov    0xc0122a60,%eax
c010882a:	8b 15 64 2a 12 c0    	mov    0xc0122a64,%edx
c0108830:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0108834:	c1 ea 0c             	shr    $0xc,%edx
c0108837:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010883a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
c010883d:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
c0108844:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108847:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010884a:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010884d:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0108850:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108853:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108856:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010885a:	74 1c                	je     c0108878 <rand+0x9d>
c010885c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010885f:	ba 00 00 00 00       	mov    $0x0,%edx
c0108864:	f7 75 dc             	divl   -0x24(%ebp)
c0108867:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010886a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010886d:	ba 00 00 00 00       	mov    $0x0,%edx
c0108872:	f7 75 dc             	divl   -0x24(%ebp)
c0108875:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108878:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010887b:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010887e:	f7 75 dc             	divl   -0x24(%ebp)
c0108881:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0108884:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0108887:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010888a:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010888d:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0108890:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0108893:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
c0108896:	83 c4 24             	add    $0x24,%esp
c0108899:	5b                   	pop    %ebx
c010889a:	5e                   	pop    %esi
c010889b:	5f                   	pop    %edi
c010889c:	5d                   	pop    %ebp
c010889d:	c3                   	ret    

c010889e <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
c010889e:	f3 0f 1e fb          	endbr32 
c01088a2:	55                   	push   %ebp
c01088a3:	89 e5                	mov    %esp,%ebp
    next = seed;
c01088a5:	8b 45 08             	mov    0x8(%ebp),%eax
c01088a8:	ba 00 00 00 00       	mov    $0x0,%edx
c01088ad:	a3 60 2a 12 c0       	mov    %eax,0xc0122a60
c01088b2:	89 15 64 2a 12 c0    	mov    %edx,0xc0122a64
}
c01088b8:	90                   	nop
c01088b9:	5d                   	pop    %ebp
c01088ba:	c3                   	ret    
