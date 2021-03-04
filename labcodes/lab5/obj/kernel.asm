
bin/kernel：     文件格式 elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 f0 1a 00       	mov    $0x1af000,%eax
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
c0100020:	a3 00 f0 1a c0       	mov    %eax,0xc01af000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 e0 12 c0       	mov    $0xc012e000,%esp
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
c0100040:	b8 60 41 1b c0       	mov    $0xc01b4160,%eax
c0100045:	2d 00 10 1b c0       	sub    $0xc01b1000,%eax
c010004a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100055:	00 
c0100056:	c7 04 24 00 10 1b c0 	movl   $0xc01b1000,(%esp)
c010005d:	e8 48 b9 00 00       	call   c010b9aa <memset>

    cons_init();                // init the console
c0100062:	e8 be 1f 00 00       	call   c0102025 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100067:	c7 45 f4 e0 c2 10 c0 	movl   $0xc010c2e0,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100071:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100075:	c7 04 24 fc c2 10 c0 	movl   $0xc010c2fc,(%esp)
c010007c:	e8 50 02 00 00       	call   c01002d1 <cprintf>

    print_kerninfo();
c0100081:	e8 02 0a 00 00       	call   c0100a88 <print_kerninfo>

    grade_backtrace();
c0100086:	e8 ac 00 00 00       	call   c0100137 <grade_backtrace>

    pmm_init();                 // init physical memory management
c010008b:	e8 c6 3e 00 00       	call   c0103f56 <pmm_init>

    pic_init();                 // init interrupt controller
c0100090:	e8 0b 21 00 00       	call   c01021a0 <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100095:	e8 b0 22 00 00       	call   c010234a <idt_init>

    vmm_init();                 // init virtual memory management
c010009a:	e8 3f 5d 00 00       	call   c0105dde <vmm_init>
    proc_init();                // init process table
c010009f:	e8 2d b0 00 00       	call   c010b0d1 <proc_init>
    
    ide_init();                 // init ide devices
c01000a4:	e8 b1 0e 00 00       	call   c0100f5a <ide_init>
    swap_init();                // init swap
c01000a9:	e8 64 68 00 00       	call   c0106912 <swap_init>

    clock_init();               // init clock interrupt
c01000ae:	e8 b9 16 00 00       	call   c010176c <clock_init>
    intr_enable();              // enable irq interrupt
c01000b3:	e8 34 22 00 00       	call   c01022ec <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();
    
    cpu_idle();                 // run idle process
c01000b8:	e8 d7 b1 00 00       	call   c010b294 <cpu_idle>

c01000bd <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000bd:	f3 0f 1e fb          	endbr32 
c01000c1:	55                   	push   %ebp
c01000c2:	89 e5                	mov    %esp,%ebp
c01000c4:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
c01000c7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01000ce:	00 
c01000cf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000d6:	00 
c01000d7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01000de:	e8 04 0e 00 00       	call   c0100ee7 <mon_backtrace>
}
c01000e3:	90                   	nop
c01000e4:	c9                   	leave  
c01000e5:	c3                   	ret    

c01000e6 <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000e6:	f3 0f 1e fb          	endbr32 
c01000ea:	55                   	push   %ebp
c01000eb:	89 e5                	mov    %esp,%ebp
c01000ed:	53                   	push   %ebx
c01000ee:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000f1:	8d 4d 0c             	lea    0xc(%ebp),%ecx
c01000f4:	8b 55 0c             	mov    0xc(%ebp),%edx
c01000f7:	8d 5d 08             	lea    0x8(%ebp),%ebx
c01000fa:	8b 45 08             	mov    0x8(%ebp),%eax
c01000fd:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0100101:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100105:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0100109:	89 04 24             	mov    %eax,(%esp)
c010010c:	e8 ac ff ff ff       	call   c01000bd <grade_backtrace2>
}
c0100111:	90                   	nop
c0100112:	83 c4 14             	add    $0x14,%esp
c0100115:	5b                   	pop    %ebx
c0100116:	5d                   	pop    %ebp
c0100117:	c3                   	ret    

c0100118 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c0100118:	f3 0f 1e fb          	endbr32 
c010011c:	55                   	push   %ebp
c010011d:	89 e5                	mov    %esp,%ebp
c010011f:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
c0100122:	8b 45 10             	mov    0x10(%ebp),%eax
c0100125:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100129:	8b 45 08             	mov    0x8(%ebp),%eax
c010012c:	89 04 24             	mov    %eax,(%esp)
c010012f:	e8 b2 ff ff ff       	call   c01000e6 <grade_backtrace1>
}
c0100134:	90                   	nop
c0100135:	c9                   	leave  
c0100136:	c3                   	ret    

c0100137 <grade_backtrace>:

void
grade_backtrace(void) {
c0100137:	f3 0f 1e fb          	endbr32 
c010013b:	55                   	push   %ebp
c010013c:	89 e5                	mov    %esp,%ebp
c010013e:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c0100141:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c0100146:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
c010014d:	ff 
c010014e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100152:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100159:	e8 ba ff ff ff       	call   c0100118 <grade_backtrace0>
}
c010015e:	90                   	nop
c010015f:	c9                   	leave  
c0100160:	c3                   	ret    

c0100161 <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c0100161:	f3 0f 1e fb          	endbr32 
c0100165:	55                   	push   %ebp
c0100166:	89 e5                	mov    %esp,%ebp
c0100168:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c010016b:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c010016e:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c0100171:	8c 45 f2             	mov    %es,-0xe(%ebp)
c0100174:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c0100177:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010017b:	83 e0 03             	and    $0x3,%eax
c010017e:	89 c2                	mov    %eax,%edx
c0100180:	a1 00 10 1b c0       	mov    0xc01b1000,%eax
c0100185:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100189:	89 44 24 04          	mov    %eax,0x4(%esp)
c010018d:	c7 04 24 01 c3 10 c0 	movl   $0xc010c301,(%esp)
c0100194:	e8 38 01 00 00       	call   c01002d1 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c0100199:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010019d:	89 c2                	mov    %eax,%edx
c010019f:	a1 00 10 1b c0       	mov    0xc01b1000,%eax
c01001a4:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001a8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001ac:	c7 04 24 0f c3 10 c0 	movl   $0xc010c30f,(%esp)
c01001b3:	e8 19 01 00 00       	call   c01002d1 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c01001b8:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c01001bc:	89 c2                	mov    %eax,%edx
c01001be:	a1 00 10 1b c0       	mov    0xc01b1000,%eax
c01001c3:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001c7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001cb:	c7 04 24 1d c3 10 c0 	movl   $0xc010c31d,(%esp)
c01001d2:	e8 fa 00 00 00       	call   c01002d1 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001d7:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001db:	89 c2                	mov    %eax,%edx
c01001dd:	a1 00 10 1b c0       	mov    0xc01b1000,%eax
c01001e2:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001e6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001ea:	c7 04 24 2b c3 10 c0 	movl   $0xc010c32b,(%esp)
c01001f1:	e8 db 00 00 00       	call   c01002d1 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001f6:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001fa:	89 c2                	mov    %eax,%edx
c01001fc:	a1 00 10 1b c0       	mov    0xc01b1000,%eax
c0100201:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100205:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100209:	c7 04 24 39 c3 10 c0 	movl   $0xc010c339,(%esp)
c0100210:	e8 bc 00 00 00       	call   c01002d1 <cprintf>
    round ++;
c0100215:	a1 00 10 1b c0       	mov    0xc01b1000,%eax
c010021a:	40                   	inc    %eax
c010021b:	a3 00 10 1b c0       	mov    %eax,0xc01b1000
}
c0100220:	90                   	nop
c0100221:	c9                   	leave  
c0100222:	c3                   	ret    

c0100223 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c0100223:	f3 0f 1e fb          	endbr32 
c0100227:	55                   	push   %ebp
c0100228:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
c010022a:	90                   	nop
c010022b:	5d                   	pop    %ebp
c010022c:	c3                   	ret    

c010022d <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c010022d:	f3 0f 1e fb          	endbr32 
c0100231:	55                   	push   %ebp
c0100232:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
c0100234:	90                   	nop
c0100235:	5d                   	pop    %ebp
c0100236:	c3                   	ret    

c0100237 <lab1_switch_test>:

static void
lab1_switch_test(void) {
c0100237:	f3 0f 1e fb          	endbr32 
c010023b:	55                   	push   %ebp
c010023c:	89 e5                	mov    %esp,%ebp
c010023e:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
c0100241:	e8 1b ff ff ff       	call   c0100161 <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c0100246:	c7 04 24 48 c3 10 c0 	movl   $0xc010c348,(%esp)
c010024d:	e8 7f 00 00 00       	call   c01002d1 <cprintf>
    lab1_switch_to_user();
c0100252:	e8 cc ff ff ff       	call   c0100223 <lab1_switch_to_user>
    lab1_print_cur_status();
c0100257:	e8 05 ff ff ff       	call   c0100161 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c010025c:	c7 04 24 68 c3 10 c0 	movl   $0xc010c368,(%esp)
c0100263:	e8 69 00 00 00       	call   c01002d1 <cprintf>
    lab1_switch_to_kernel();
c0100268:	e8 c0 ff ff ff       	call   c010022d <lab1_switch_to_kernel>
    lab1_print_cur_status();
c010026d:	e8 ef fe ff ff       	call   c0100161 <lab1_print_cur_status>
}
c0100272:	90                   	nop
c0100273:	c9                   	leave  
c0100274:	c3                   	ret    

c0100275 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c0100275:	f3 0f 1e fb          	endbr32 
c0100279:	55                   	push   %ebp
c010027a:	89 e5                	mov    %esp,%ebp
c010027c:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c010027f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100282:	89 04 24             	mov    %eax,(%esp)
c0100285:	e8 cc 1d 00 00       	call   c0102056 <cons_putc>
    (*cnt) ++;
c010028a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010028d:	8b 00                	mov    (%eax),%eax
c010028f:	8d 50 01             	lea    0x1(%eax),%edx
c0100292:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100295:	89 10                	mov    %edx,(%eax)
}
c0100297:	90                   	nop
c0100298:	c9                   	leave  
c0100299:	c3                   	ret    

c010029a <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c010029a:	f3 0f 1e fb          	endbr32 
c010029e:	55                   	push   %ebp
c010029f:	89 e5                	mov    %esp,%ebp
c01002a1:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c01002a4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c01002ab:	8b 45 0c             	mov    0xc(%ebp),%eax
c01002ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01002b2:	8b 45 08             	mov    0x8(%ebp),%eax
c01002b5:	89 44 24 08          	mov    %eax,0x8(%esp)
c01002b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
c01002bc:	89 44 24 04          	mov    %eax,0x4(%esp)
c01002c0:	c7 04 24 75 02 10 c0 	movl   $0xc0100275,(%esp)
c01002c7:	e8 4a ba 00 00       	call   c010bd16 <vprintfmt>
    return cnt;
c01002cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01002cf:	c9                   	leave  
c01002d0:	c3                   	ret    

c01002d1 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c01002d1:	f3 0f 1e fb          	endbr32 
c01002d5:	55                   	push   %ebp
c01002d6:	89 e5                	mov    %esp,%ebp
c01002d8:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c01002db:	8d 45 0c             	lea    0xc(%ebp),%eax
c01002de:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c01002e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002e4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01002e8:	8b 45 08             	mov    0x8(%ebp),%eax
c01002eb:	89 04 24             	mov    %eax,(%esp)
c01002ee:	e8 a7 ff ff ff       	call   c010029a <vcprintf>
c01002f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c01002f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01002f9:	c9                   	leave  
c01002fa:	c3                   	ret    

c01002fb <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c01002fb:	f3 0f 1e fb          	endbr32 
c01002ff:	55                   	push   %ebp
c0100300:	89 e5                	mov    %esp,%ebp
c0100302:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0100305:	8b 45 08             	mov    0x8(%ebp),%eax
c0100308:	89 04 24             	mov    %eax,(%esp)
c010030b:	e8 46 1d 00 00       	call   c0102056 <cons_putc>
}
c0100310:	90                   	nop
c0100311:	c9                   	leave  
c0100312:	c3                   	ret    

c0100313 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c0100313:	f3 0f 1e fb          	endbr32 
c0100317:	55                   	push   %ebp
c0100318:	89 e5                	mov    %esp,%ebp
c010031a:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c010031d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c0100324:	eb 13                	jmp    c0100339 <cputs+0x26>
        cputch(c, &cnt);
c0100326:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c010032a:	8d 55 f0             	lea    -0x10(%ebp),%edx
c010032d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100331:	89 04 24             	mov    %eax,(%esp)
c0100334:	e8 3c ff ff ff       	call   c0100275 <cputch>
    while ((c = *str ++) != '\0') {
c0100339:	8b 45 08             	mov    0x8(%ebp),%eax
c010033c:	8d 50 01             	lea    0x1(%eax),%edx
c010033f:	89 55 08             	mov    %edx,0x8(%ebp)
c0100342:	0f b6 00             	movzbl (%eax),%eax
c0100345:	88 45 f7             	mov    %al,-0x9(%ebp)
c0100348:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c010034c:	75 d8                	jne    c0100326 <cputs+0x13>
    }
    cputch('\n', &cnt);
c010034e:	8d 45 f0             	lea    -0x10(%ebp),%eax
c0100351:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100355:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c010035c:	e8 14 ff ff ff       	call   c0100275 <cputch>
    return cnt;
c0100361:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0100364:	c9                   	leave  
c0100365:	c3                   	ret    

c0100366 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c0100366:	f3 0f 1e fb          	endbr32 
c010036a:	55                   	push   %ebp
c010036b:	89 e5                	mov    %esp,%ebp
c010036d:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c0100370:	90                   	nop
c0100371:	e8 21 1d 00 00       	call   c0102097 <cons_getc>
c0100376:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100379:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010037d:	74 f2                	je     c0100371 <getchar+0xb>
        /* do nothing */;
    return c;
c010037f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100382:	c9                   	leave  
c0100383:	c3                   	ret    

c0100384 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c0100384:	f3 0f 1e fb          	endbr32 
c0100388:	55                   	push   %ebp
c0100389:	89 e5                	mov    %esp,%ebp
c010038b:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c010038e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100392:	74 13                	je     c01003a7 <readline+0x23>
        cprintf("%s", prompt);
c0100394:	8b 45 08             	mov    0x8(%ebp),%eax
c0100397:	89 44 24 04          	mov    %eax,0x4(%esp)
c010039b:	c7 04 24 87 c3 10 c0 	movl   $0xc010c387,(%esp)
c01003a2:	e8 2a ff ff ff       	call   c01002d1 <cprintf>
    }
    int i = 0, c;
c01003a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c01003ae:	e8 b3 ff ff ff       	call   c0100366 <getchar>
c01003b3:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c01003b6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01003ba:	79 07                	jns    c01003c3 <readline+0x3f>
            return NULL;
c01003bc:	b8 00 00 00 00       	mov    $0x0,%eax
c01003c1:	eb 78                	jmp    c010043b <readline+0xb7>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c01003c3:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c01003c7:	7e 28                	jle    c01003f1 <readline+0x6d>
c01003c9:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c01003d0:	7f 1f                	jg     c01003f1 <readline+0x6d>
            cputchar(c);
c01003d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003d5:	89 04 24             	mov    %eax,(%esp)
c01003d8:	e8 1e ff ff ff       	call   c01002fb <cputchar>
            buf[i ++] = c;
c01003dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01003e0:	8d 50 01             	lea    0x1(%eax),%edx
c01003e3:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01003e6:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01003e9:	88 90 20 10 1b c0    	mov    %dl,-0x3fe4efe0(%eax)
c01003ef:	eb 45                	jmp    c0100436 <readline+0xb2>
        }
        else if (c == '\b' && i > 0) {
c01003f1:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c01003f5:	75 16                	jne    c010040d <readline+0x89>
c01003f7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01003fb:	7e 10                	jle    c010040d <readline+0x89>
            cputchar(c);
c01003fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100400:	89 04 24             	mov    %eax,(%esp)
c0100403:	e8 f3 fe ff ff       	call   c01002fb <cputchar>
            i --;
c0100408:	ff 4d f4             	decl   -0xc(%ebp)
c010040b:	eb 29                	jmp    c0100436 <readline+0xb2>
        }
        else if (c == '\n' || c == '\r') {
c010040d:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c0100411:	74 06                	je     c0100419 <readline+0x95>
c0100413:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c0100417:	75 95                	jne    c01003ae <readline+0x2a>
            cputchar(c);
c0100419:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010041c:	89 04 24             	mov    %eax,(%esp)
c010041f:	e8 d7 fe ff ff       	call   c01002fb <cputchar>
            buf[i] = '\0';
c0100424:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100427:	05 20 10 1b c0       	add    $0xc01b1020,%eax
c010042c:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c010042f:	b8 20 10 1b c0       	mov    $0xc01b1020,%eax
c0100434:	eb 05                	jmp    c010043b <readline+0xb7>
        c = getchar();
c0100436:	e9 73 ff ff ff       	jmp    c01003ae <readline+0x2a>
        }
    }
}
c010043b:	c9                   	leave  
c010043c:	c3                   	ret    

c010043d <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c010043d:	f3 0f 1e fb          	endbr32 
c0100441:	55                   	push   %ebp
c0100442:	89 e5                	mov    %esp,%ebp
c0100444:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c0100447:	a1 20 14 1b c0       	mov    0xc01b1420,%eax
c010044c:	85 c0                	test   %eax,%eax
c010044e:	75 5b                	jne    c01004ab <__panic+0x6e>
        goto panic_dead;
    }
    is_panic = 1;
c0100450:	c7 05 20 14 1b c0 01 	movl   $0x1,0xc01b1420
c0100457:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c010045a:	8d 45 14             	lea    0x14(%ebp),%eax
c010045d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0100460:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100463:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100467:	8b 45 08             	mov    0x8(%ebp),%eax
c010046a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010046e:	c7 04 24 8a c3 10 c0 	movl   $0xc010c38a,(%esp)
c0100475:	e8 57 fe ff ff       	call   c01002d1 <cprintf>
    vcprintf(fmt, ap);
c010047a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010047d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100481:	8b 45 10             	mov    0x10(%ebp),%eax
c0100484:	89 04 24             	mov    %eax,(%esp)
c0100487:	e8 0e fe ff ff       	call   c010029a <vcprintf>
    cprintf("\n");
c010048c:	c7 04 24 a6 c3 10 c0 	movl   $0xc010c3a6,(%esp)
c0100493:	e8 39 fe ff ff       	call   c01002d1 <cprintf>
    
    cprintf("stack trackback:\n");
c0100498:	c7 04 24 a8 c3 10 c0 	movl   $0xc010c3a8,(%esp)
c010049f:	e8 2d fe ff ff       	call   c01002d1 <cprintf>
    print_stackframe();
c01004a4:	e8 31 07 00 00       	call   c0100bda <print_stackframe>
c01004a9:	eb 01                	jmp    c01004ac <__panic+0x6f>
        goto panic_dead;
c01004ab:	90                   	nop
    
    va_end(ap);

panic_dead:
    intr_disable();
c01004ac:	e8 47 1e 00 00       	call   c01022f8 <intr_disable>
    while (1) {
        kmonitor(NULL);
c01004b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01004b8:	e8 51 09 00 00       	call   c0100e0e <kmonitor>
c01004bd:	eb f2                	jmp    c01004b1 <__panic+0x74>

c01004bf <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c01004bf:	f3 0f 1e fb          	endbr32 
c01004c3:	55                   	push   %ebp
c01004c4:	89 e5                	mov    %esp,%ebp
c01004c6:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c01004c9:	8d 45 14             	lea    0x14(%ebp),%eax
c01004cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c01004cf:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004d2:	89 44 24 08          	mov    %eax,0x8(%esp)
c01004d6:	8b 45 08             	mov    0x8(%ebp),%eax
c01004d9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01004dd:	c7 04 24 ba c3 10 c0 	movl   $0xc010c3ba,(%esp)
c01004e4:	e8 e8 fd ff ff       	call   c01002d1 <cprintf>
    vcprintf(fmt, ap);
c01004e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01004ec:	89 44 24 04          	mov    %eax,0x4(%esp)
c01004f0:	8b 45 10             	mov    0x10(%ebp),%eax
c01004f3:	89 04 24             	mov    %eax,(%esp)
c01004f6:	e8 9f fd ff ff       	call   c010029a <vcprintf>
    cprintf("\n");
c01004fb:	c7 04 24 a6 c3 10 c0 	movl   $0xc010c3a6,(%esp)
c0100502:	e8 ca fd ff ff       	call   c01002d1 <cprintf>
    va_end(ap);
}
c0100507:	90                   	nop
c0100508:	c9                   	leave  
c0100509:	c3                   	ret    

c010050a <is_kernel_panic>:

bool
is_kernel_panic(void) {
c010050a:	f3 0f 1e fb          	endbr32 
c010050e:	55                   	push   %ebp
c010050f:	89 e5                	mov    %esp,%ebp
    return is_panic;
c0100511:	a1 20 14 1b c0       	mov    0xc01b1420,%eax
}
c0100516:	5d                   	pop    %ebp
c0100517:	c3                   	ret    

c0100518 <stab_binsearch>:
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
               int type, uintptr_t addr)
{
c0100518:	f3 0f 1e fb          	endbr32 
c010051c:	55                   	push   %ebp
c010051d:	89 e5                	mov    %esp,%ebp
c010051f:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c0100522:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100525:	8b 00                	mov    (%eax),%eax
c0100527:	89 45 fc             	mov    %eax,-0x4(%ebp)
c010052a:	8b 45 10             	mov    0x10(%ebp),%eax
c010052d:	8b 00                	mov    (%eax),%eax
c010052f:	89 45 f8             	mov    %eax,-0x8(%ebp)
c0100532:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r)
c0100539:	e9 ca 00 00 00       	jmp    c0100608 <stab_binsearch+0xf0>
    {
        int true_m = (l + r) / 2, m = true_m;
c010053e:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100541:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100544:	01 d0                	add    %edx,%eax
c0100546:	89 c2                	mov    %eax,%edx
c0100548:	c1 ea 1f             	shr    $0x1f,%edx
c010054b:	01 d0                	add    %edx,%eax
c010054d:	d1 f8                	sar    %eax
c010054f:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0100552:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100555:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type)
c0100558:	eb 03                	jmp    c010055d <stab_binsearch+0x45>
        {
            m--;
c010055a:	ff 4d f0             	decl   -0x10(%ebp)
        while (m >= l && stabs[m].n_type != type)
c010055d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100560:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100563:	7c 1f                	jl     c0100584 <stab_binsearch+0x6c>
c0100565:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100568:	89 d0                	mov    %edx,%eax
c010056a:	01 c0                	add    %eax,%eax
c010056c:	01 d0                	add    %edx,%eax
c010056e:	c1 e0 02             	shl    $0x2,%eax
c0100571:	89 c2                	mov    %eax,%edx
c0100573:	8b 45 08             	mov    0x8(%ebp),%eax
c0100576:	01 d0                	add    %edx,%eax
c0100578:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010057c:	0f b6 c0             	movzbl %al,%eax
c010057f:	39 45 14             	cmp    %eax,0x14(%ebp)
c0100582:	75 d6                	jne    c010055a <stab_binsearch+0x42>
        }
        if (m < l)
c0100584:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100587:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010058a:	7d 09                	jge    c0100595 <stab_binsearch+0x7d>
        { // no match in [l, m]
            l = true_m + 1;
c010058c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010058f:	40                   	inc    %eax
c0100590:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c0100593:	eb 73                	jmp    c0100608 <stab_binsearch+0xf0>
        }

        // actual binary search
        any_matches = 1;
c0100595:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr)
c010059c:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010059f:	89 d0                	mov    %edx,%eax
c01005a1:	01 c0                	add    %eax,%eax
c01005a3:	01 d0                	add    %edx,%eax
c01005a5:	c1 e0 02             	shl    $0x2,%eax
c01005a8:	89 c2                	mov    %eax,%edx
c01005aa:	8b 45 08             	mov    0x8(%ebp),%eax
c01005ad:	01 d0                	add    %edx,%eax
c01005af:	8b 40 08             	mov    0x8(%eax),%eax
c01005b2:	39 45 18             	cmp    %eax,0x18(%ebp)
c01005b5:	76 11                	jbe    c01005c8 <stab_binsearch+0xb0>
        {
            *region_left = m;
c01005b7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005ba:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005bd:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c01005bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01005c2:	40                   	inc    %eax
c01005c3:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01005c6:	eb 40                	jmp    c0100608 <stab_binsearch+0xf0>
        }
        else if (stabs[m].n_value > addr)
c01005c8:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005cb:	89 d0                	mov    %edx,%eax
c01005cd:	01 c0                	add    %eax,%eax
c01005cf:	01 d0                	add    %edx,%eax
c01005d1:	c1 e0 02             	shl    $0x2,%eax
c01005d4:	89 c2                	mov    %eax,%edx
c01005d6:	8b 45 08             	mov    0x8(%ebp),%eax
c01005d9:	01 d0                	add    %edx,%eax
c01005db:	8b 40 08             	mov    0x8(%eax),%eax
c01005de:	39 45 18             	cmp    %eax,0x18(%ebp)
c01005e1:	73 14                	jae    c01005f7 <stab_binsearch+0xdf>
        {
            *region_right = m - 1;
c01005e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005e6:	8d 50 ff             	lea    -0x1(%eax),%edx
c01005e9:	8b 45 10             	mov    0x10(%ebp),%eax
c01005ec:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c01005ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005f1:	48                   	dec    %eax
c01005f2:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01005f5:	eb 11                	jmp    c0100608 <stab_binsearch+0xf0>
        }
        else
        {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c01005f7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005fa:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005fd:	89 10                	mov    %edx,(%eax)
            l = m;
c01005ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100602:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr++;
c0100605:	ff 45 18             	incl   0x18(%ebp)
    while (l <= r)
c0100608:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010060b:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c010060e:	0f 8e 2a ff ff ff    	jle    c010053e <stab_binsearch+0x26>
        }
    }

    if (!any_matches)
c0100614:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100618:	75 0f                	jne    c0100629 <stab_binsearch+0x111>
    {
        *region_right = *region_left - 1;
c010061a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010061d:	8b 00                	mov    (%eax),%eax
c010061f:	8d 50 ff             	lea    -0x1(%eax),%edx
c0100622:	8b 45 10             	mov    0x10(%ebp),%eax
c0100625:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l--)
            /* do nothing */;
        *region_left = l;
    }
}
c0100627:	eb 3e                	jmp    c0100667 <stab_binsearch+0x14f>
        l = *region_right;
c0100629:	8b 45 10             	mov    0x10(%ebp),%eax
c010062c:	8b 00                	mov    (%eax),%eax
c010062e:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l--)
c0100631:	eb 03                	jmp    c0100636 <stab_binsearch+0x11e>
c0100633:	ff 4d fc             	decl   -0x4(%ebp)
c0100636:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100639:	8b 00                	mov    (%eax),%eax
c010063b:	39 45 fc             	cmp    %eax,-0x4(%ebp)
c010063e:	7e 1f                	jle    c010065f <stab_binsearch+0x147>
c0100640:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100643:	89 d0                	mov    %edx,%eax
c0100645:	01 c0                	add    %eax,%eax
c0100647:	01 d0                	add    %edx,%eax
c0100649:	c1 e0 02             	shl    $0x2,%eax
c010064c:	89 c2                	mov    %eax,%edx
c010064e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100651:	01 d0                	add    %edx,%eax
c0100653:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100657:	0f b6 c0             	movzbl %al,%eax
c010065a:	39 45 14             	cmp    %eax,0x14(%ebp)
c010065d:	75 d4                	jne    c0100633 <stab_binsearch+0x11b>
        *region_left = l;
c010065f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100662:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100665:	89 10                	mov    %edx,(%eax)
}
c0100667:	90                   	nop
c0100668:	c9                   	leave  
c0100669:	c3                   	ret    

c010066a <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info)
{
c010066a:	f3 0f 1e fb          	endbr32 
c010066e:	55                   	push   %ebp
c010066f:	89 e5                	mov    %esp,%ebp
c0100671:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c0100674:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100677:	c7 00 d8 c3 10 c0    	movl   $0xc010c3d8,(%eax)
    info->eip_line = 0;
c010067d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100680:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c0100687:	8b 45 0c             	mov    0xc(%ebp),%eax
c010068a:	c7 40 08 d8 c3 10 c0 	movl   $0xc010c3d8,0x8(%eax)
    info->eip_fn_namelen = 9;
c0100691:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100694:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c010069b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010069e:	8b 55 08             	mov    0x8(%ebp),%edx
c01006a1:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c01006a4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006a7:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    // find the relevant set of stabs
    if (addr >= KERNBASE)
c01006ae:	81 7d 08 ff ff ff bf 	cmpl   $0xbfffffff,0x8(%ebp)
c01006b5:	76 21                	jbe    c01006d8 <debuginfo_eip+0x6e>
    {
        stabs = __STAB_BEGIN__;
c01006b7:	c7 45 f4 40 ec 10 c0 	movl   $0xc010ec40,-0xc(%ebp)
        stab_end = __STAB_END__;
c01006be:	c7 45 f0 fc 70 12 c0 	movl   $0xc01270fc,-0x10(%ebp)
        stabstr = __STABSTR_BEGIN__;
c01006c5:	c7 45 ec fd 70 12 c0 	movl   $0xc01270fd,-0x14(%ebp)
        stabstr_end = __STABSTR_END__;
c01006cc:	c7 45 e8 d4 be 12 c0 	movl   $0xc012bed4,-0x18(%ebp)
c01006d3:	e9 e6 00 00 00       	jmp    c01007be <debuginfo_eip+0x154>
    else
    {
        // user-program linker script, tools/user.ld puts the information about the
        // program's stabs (included __STAB_BEGIN__, __STAB_END__, __STABSTR_BEGIN__,
        // and __STABSTR_END__) in a structure located at virtual address USTAB.
        const struct userstabdata *usd = (struct userstabdata *)USTAB;
c01006d8:	c7 45 e4 00 00 20 00 	movl   $0x200000,-0x1c(%ebp)

        // make sure that debugger (current process) can access this memory
        struct mm_struct *mm;
        if (current == NULL || (mm = current->mm) == NULL)
c01006df:	a1 28 20 1b c0       	mov    0xc01b2028,%eax
c01006e4:	85 c0                	test   %eax,%eax
c01006e6:	74 11                	je     c01006f9 <debuginfo_eip+0x8f>
c01006e8:	a1 28 20 1b c0       	mov    0xc01b2028,%eax
c01006ed:	8b 40 18             	mov    0x18(%eax),%eax
c01006f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01006f3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01006f7:	75 0a                	jne    c0100703 <debuginfo_eip+0x99>
        {
            return -1;
c01006f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01006fe:	e9 83 03 00 00       	jmp    c0100a86 <debuginfo_eip+0x41c>
        }
        if (!user_mem_check(mm, (uintptr_t)usd, sizeof(struct userstabdata), 0))
c0100703:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100706:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010070d:	00 
c010070e:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c0100715:	00 
c0100716:	89 44 24 04          	mov    %eax,0x4(%esp)
c010071a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010071d:	89 04 24             	mov    %eax,(%esp)
c0100720:	e8 2b 60 00 00       	call   c0106750 <user_mem_check>
c0100725:	85 c0                	test   %eax,%eax
c0100727:	75 0a                	jne    c0100733 <debuginfo_eip+0xc9>
        {
            return -1;
c0100729:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010072e:	e9 53 03 00 00       	jmp    c0100a86 <debuginfo_eip+0x41c>
        }

        stabs = usd->stabs;
c0100733:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100736:	8b 00                	mov    (%eax),%eax
c0100738:	89 45 f4             	mov    %eax,-0xc(%ebp)
        stab_end = usd->stab_end;
c010073b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010073e:	8b 40 04             	mov    0x4(%eax),%eax
c0100741:	89 45 f0             	mov    %eax,-0x10(%ebp)
        stabstr = usd->stabstr;
c0100744:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100747:	8b 40 08             	mov    0x8(%eax),%eax
c010074a:	89 45 ec             	mov    %eax,-0x14(%ebp)
        stabstr_end = usd->stabstr_end;
c010074d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100750:	8b 40 0c             	mov    0xc(%eax),%eax
c0100753:	89 45 e8             	mov    %eax,-0x18(%ebp)

        // make sure the STABS and string table memory is valid
        if (!user_mem_check(mm, (uintptr_t)stabs, (uintptr_t)stab_end - (uintptr_t)stabs, 0))
c0100756:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100759:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010075c:	29 c2                	sub    %eax,%edx
c010075e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100761:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0100768:	00 
c0100769:	89 54 24 08          	mov    %edx,0x8(%esp)
c010076d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100771:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0100774:	89 04 24             	mov    %eax,(%esp)
c0100777:	e8 d4 5f 00 00       	call   c0106750 <user_mem_check>
c010077c:	85 c0                	test   %eax,%eax
c010077e:	75 0a                	jne    c010078a <debuginfo_eip+0x120>
        {
            return -1;
c0100780:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100785:	e9 fc 02 00 00       	jmp    c0100a86 <debuginfo_eip+0x41c>
        }
        if (!user_mem_check(mm, (uintptr_t)stabstr, stabstr_end - stabstr, 0))
c010078a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010078d:	2b 45 ec             	sub    -0x14(%ebp),%eax
c0100790:	89 c2                	mov    %eax,%edx
c0100792:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100795:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010079c:	00 
c010079d:	89 54 24 08          	mov    %edx,0x8(%esp)
c01007a1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01007a5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01007a8:	89 04 24             	mov    %eax,(%esp)
c01007ab:	e8 a0 5f 00 00       	call   c0106750 <user_mem_check>
c01007b0:	85 c0                	test   %eax,%eax
c01007b2:	75 0a                	jne    c01007be <debuginfo_eip+0x154>
        {
            return -1;
c01007b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01007b9:	e9 c8 02 00 00       	jmp    c0100a86 <debuginfo_eip+0x41c>
        }
    }

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
c01007be:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01007c1:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01007c4:	76 0b                	jbe    c01007d1 <debuginfo_eip+0x167>
c01007c6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01007c9:	48                   	dec    %eax
c01007ca:	0f b6 00             	movzbl (%eax),%eax
c01007cd:	84 c0                	test   %al,%al
c01007cf:	74 0a                	je     c01007db <debuginfo_eip+0x171>
    {
        return -1;
c01007d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01007d6:	e9 ab 02 00 00       	jmp    c0100a86 <debuginfo_eip+0x41c>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c01007db:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01007e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01007e5:	2b 45 f4             	sub    -0xc(%ebp),%eax
c01007e8:	c1 f8 02             	sar    $0x2,%eax
c01007eb:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c01007f1:	48                   	dec    %eax
c01007f2:	89 45 d8             	mov    %eax,-0x28(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c01007f5:	8b 45 08             	mov    0x8(%ebp),%eax
c01007f8:	89 44 24 10          	mov    %eax,0x10(%esp)
c01007fc:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c0100803:	00 
c0100804:	8d 45 d8             	lea    -0x28(%ebp),%eax
c0100807:	89 44 24 08          	mov    %eax,0x8(%esp)
c010080b:	8d 45 dc             	lea    -0x24(%ebp),%eax
c010080e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100812:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100815:	89 04 24             	mov    %eax,(%esp)
c0100818:	e8 fb fc ff ff       	call   c0100518 <stab_binsearch>
    if (lfile == 0)
c010081d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100820:	85 c0                	test   %eax,%eax
c0100822:	75 0a                	jne    c010082e <debuginfo_eip+0x1c4>
        return -1;
c0100824:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100829:	e9 58 02 00 00       	jmp    c0100a86 <debuginfo_eip+0x41c>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c010082e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100831:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0100834:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100837:	89 45 d0             	mov    %eax,-0x30(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c010083a:	8b 45 08             	mov    0x8(%ebp),%eax
c010083d:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100841:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c0100848:	00 
c0100849:	8d 45 d0             	lea    -0x30(%ebp),%eax
c010084c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100850:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c0100853:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100857:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010085a:	89 04 24             	mov    %eax,(%esp)
c010085d:	e8 b6 fc ff ff       	call   c0100518 <stab_binsearch>

    if (lfun <= rfun)
c0100862:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100865:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100868:	39 c2                	cmp    %eax,%edx
c010086a:	7f 78                	jg     c01008e4 <debuginfo_eip+0x27a>
    {
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr)
c010086c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010086f:	89 c2                	mov    %eax,%edx
c0100871:	89 d0                	mov    %edx,%eax
c0100873:	01 c0                	add    %eax,%eax
c0100875:	01 d0                	add    %edx,%eax
c0100877:	c1 e0 02             	shl    $0x2,%eax
c010087a:	89 c2                	mov    %eax,%edx
c010087c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010087f:	01 d0                	add    %edx,%eax
c0100881:	8b 10                	mov    (%eax),%edx
c0100883:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100886:	2b 45 ec             	sub    -0x14(%ebp),%eax
c0100889:	39 c2                	cmp    %eax,%edx
c010088b:	73 22                	jae    c01008af <debuginfo_eip+0x245>
        {
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c010088d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100890:	89 c2                	mov    %eax,%edx
c0100892:	89 d0                	mov    %edx,%eax
c0100894:	01 c0                	add    %eax,%eax
c0100896:	01 d0                	add    %edx,%eax
c0100898:	c1 e0 02             	shl    $0x2,%eax
c010089b:	89 c2                	mov    %eax,%edx
c010089d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008a0:	01 d0                	add    %edx,%eax
c01008a2:	8b 10                	mov    (%eax),%edx
c01008a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01008a7:	01 c2                	add    %eax,%edx
c01008a9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008ac:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c01008af:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008b2:	89 c2                	mov    %eax,%edx
c01008b4:	89 d0                	mov    %edx,%eax
c01008b6:	01 c0                	add    %eax,%eax
c01008b8:	01 d0                	add    %edx,%eax
c01008ba:	c1 e0 02             	shl    $0x2,%eax
c01008bd:	89 c2                	mov    %eax,%edx
c01008bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008c2:	01 d0                	add    %edx,%eax
c01008c4:	8b 50 08             	mov    0x8(%eax),%edx
c01008c7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008ca:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c01008cd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008d0:	8b 40 10             	mov    0x10(%eax),%eax
c01008d3:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c01008d6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008d9:	89 45 cc             	mov    %eax,-0x34(%ebp)
        rline = rfun;
c01008dc:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01008df:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01008e2:	eb 15                	jmp    c01008f9 <debuginfo_eip+0x28f>
    }
    else
    {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c01008e4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008e7:	8b 55 08             	mov    0x8(%ebp),%edx
c01008ea:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c01008ed:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01008f0:	89 45 cc             	mov    %eax,-0x34(%ebp)
        rline = rfile;
c01008f3:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01008f6:	89 45 c8             	mov    %eax,-0x38(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c01008f9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008fc:	8b 40 08             	mov    0x8(%eax),%eax
c01008ff:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c0100906:	00 
c0100907:	89 04 24             	mov    %eax,(%esp)
c010090a:	e8 0f af 00 00       	call   c010b81e <strfind>
c010090f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100912:	8b 52 08             	mov    0x8(%edx),%edx
c0100915:	29 d0                	sub    %edx,%eax
c0100917:	89 c2                	mov    %eax,%edx
c0100919:	8b 45 0c             	mov    0xc(%ebp),%eax
c010091c:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c010091f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100922:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100926:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c010092d:	00 
c010092e:	8d 45 c8             	lea    -0x38(%ebp),%eax
c0100931:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100935:	8d 45 cc             	lea    -0x34(%ebp),%eax
c0100938:	89 44 24 04          	mov    %eax,0x4(%esp)
c010093c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010093f:	89 04 24             	mov    %eax,(%esp)
c0100942:	e8 d1 fb ff ff       	call   c0100518 <stab_binsearch>
    if (lline <= rline)
c0100947:	8b 55 cc             	mov    -0x34(%ebp),%edx
c010094a:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010094d:	39 c2                	cmp    %eax,%edx
c010094f:	7f 23                	jg     c0100974 <debuginfo_eip+0x30a>
    {
        info->eip_line = stabs[rline].n_desc;
c0100951:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0100954:	89 c2                	mov    %eax,%edx
c0100956:	89 d0                	mov    %edx,%eax
c0100958:	01 c0                	add    %eax,%eax
c010095a:	01 d0                	add    %edx,%eax
c010095c:	c1 e0 02             	shl    $0x2,%eax
c010095f:	89 c2                	mov    %eax,%edx
c0100961:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100964:	01 d0                	add    %edx,%eax
c0100966:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c010096a:	89 c2                	mov    %eax,%edx
c010096c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010096f:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile && stabs[lline].n_type != N_SOL && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
c0100972:	eb 11                	jmp    c0100985 <debuginfo_eip+0x31b>
        return -1;
c0100974:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100979:	e9 08 01 00 00       	jmp    c0100a86 <debuginfo_eip+0x41c>
    {
        lline--;
c010097e:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0100981:	48                   	dec    %eax
c0100982:	89 45 cc             	mov    %eax,-0x34(%ebp)
    while (lline >= lfile && stabs[lline].n_type != N_SOL && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
c0100985:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0100988:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010098b:	39 c2                	cmp    %eax,%edx
c010098d:	7c 56                	jl     c01009e5 <debuginfo_eip+0x37b>
c010098f:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0100992:	89 c2                	mov    %eax,%edx
c0100994:	89 d0                	mov    %edx,%eax
c0100996:	01 c0                	add    %eax,%eax
c0100998:	01 d0                	add    %edx,%eax
c010099a:	c1 e0 02             	shl    $0x2,%eax
c010099d:	89 c2                	mov    %eax,%edx
c010099f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01009a2:	01 d0                	add    %edx,%eax
c01009a4:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01009a8:	3c 84                	cmp    $0x84,%al
c01009aa:	74 39                	je     c01009e5 <debuginfo_eip+0x37b>
c01009ac:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01009af:	89 c2                	mov    %eax,%edx
c01009b1:	89 d0                	mov    %edx,%eax
c01009b3:	01 c0                	add    %eax,%eax
c01009b5:	01 d0                	add    %edx,%eax
c01009b7:	c1 e0 02             	shl    $0x2,%eax
c01009ba:	89 c2                	mov    %eax,%edx
c01009bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01009bf:	01 d0                	add    %edx,%eax
c01009c1:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01009c5:	3c 64                	cmp    $0x64,%al
c01009c7:	75 b5                	jne    c010097e <debuginfo_eip+0x314>
c01009c9:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01009cc:	89 c2                	mov    %eax,%edx
c01009ce:	89 d0                	mov    %edx,%eax
c01009d0:	01 c0                	add    %eax,%eax
c01009d2:	01 d0                	add    %edx,%eax
c01009d4:	c1 e0 02             	shl    $0x2,%eax
c01009d7:	89 c2                	mov    %eax,%edx
c01009d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01009dc:	01 d0                	add    %edx,%eax
c01009de:	8b 40 08             	mov    0x8(%eax),%eax
c01009e1:	85 c0                	test   %eax,%eax
c01009e3:	74 99                	je     c010097e <debuginfo_eip+0x314>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
c01009e5:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01009e8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01009eb:	39 c2                	cmp    %eax,%edx
c01009ed:	7c 42                	jl     c0100a31 <debuginfo_eip+0x3c7>
c01009ef:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01009f2:	89 c2                	mov    %eax,%edx
c01009f4:	89 d0                	mov    %edx,%eax
c01009f6:	01 c0                	add    %eax,%eax
c01009f8:	01 d0                	add    %edx,%eax
c01009fa:	c1 e0 02             	shl    $0x2,%eax
c01009fd:	89 c2                	mov    %eax,%edx
c01009ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a02:	01 d0                	add    %edx,%eax
c0100a04:	8b 10                	mov    (%eax),%edx
c0100a06:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a09:	2b 45 ec             	sub    -0x14(%ebp),%eax
c0100a0c:	39 c2                	cmp    %eax,%edx
c0100a0e:	73 21                	jae    c0100a31 <debuginfo_eip+0x3c7>
    {
        info->eip_file = stabstr + stabs[lline].n_strx;
c0100a10:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0100a13:	89 c2                	mov    %eax,%edx
c0100a15:	89 d0                	mov    %edx,%eax
c0100a17:	01 c0                	add    %eax,%eax
c0100a19:	01 d0                	add    %edx,%eax
c0100a1b:	c1 e0 02             	shl    $0x2,%eax
c0100a1e:	89 c2                	mov    %eax,%edx
c0100a20:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a23:	01 d0                	add    %edx,%eax
c0100a25:	8b 10                	mov    (%eax),%edx
c0100a27:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100a2a:	01 c2                	add    %eax,%edx
c0100a2c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100a2f:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun)
c0100a31:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100a34:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100a37:	39 c2                	cmp    %eax,%edx
c0100a39:	7d 46                	jge    c0100a81 <debuginfo_eip+0x417>
    {
        for (lline = lfun + 1;
c0100a3b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100a3e:	40                   	inc    %eax
c0100a3f:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0100a42:	eb 16                	jmp    c0100a5a <debuginfo_eip+0x3f0>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline++)
        {
            info->eip_fn_narg++;
c0100a44:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100a47:	8b 40 14             	mov    0x14(%eax),%eax
c0100a4a:	8d 50 01             	lea    0x1(%eax),%edx
c0100a4d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100a50:	89 50 14             	mov    %edx,0x14(%eax)
             lline++)
c0100a53:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0100a56:	40                   	inc    %eax
c0100a57:	89 45 cc             	mov    %eax,-0x34(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100a5a:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0100a5d:	8b 45 d0             	mov    -0x30(%ebp),%eax
        for (lline = lfun + 1;
c0100a60:	39 c2                	cmp    %eax,%edx
c0100a62:	7d 1d                	jge    c0100a81 <debuginfo_eip+0x417>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100a64:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0100a67:	89 c2                	mov    %eax,%edx
c0100a69:	89 d0                	mov    %edx,%eax
c0100a6b:	01 c0                	add    %eax,%eax
c0100a6d:	01 d0                	add    %edx,%eax
c0100a6f:	c1 e0 02             	shl    $0x2,%eax
c0100a72:	89 c2                	mov    %eax,%edx
c0100a74:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a77:	01 d0                	add    %edx,%eax
c0100a79:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100a7d:	3c a0                	cmp    $0xa0,%al
c0100a7f:	74 c3                	je     c0100a44 <debuginfo_eip+0x3da>
        }
    }
    return 0;
c0100a81:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100a86:	c9                   	leave  
c0100a87:	c3                   	ret    

c0100a88 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void)
{
c0100a88:	f3 0f 1e fb          	endbr32 
c0100a8c:	55                   	push   %ebp
c0100a8d:	89 e5                	mov    %esp,%ebp
c0100a8f:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c0100a92:	c7 04 24 e2 c3 10 c0 	movl   $0xc010c3e2,(%esp)
c0100a99:	e8 33 f8 ff ff       	call   c01002d1 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c0100a9e:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c0100aa5:	c0 
c0100aa6:	c7 04 24 fb c3 10 c0 	movl   $0xc010c3fb,(%esp)
c0100aad:	e8 1f f8 ff ff       	call   c01002d1 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c0100ab2:	c7 44 24 04 d7 c2 10 	movl   $0xc010c2d7,0x4(%esp)
c0100ab9:	c0 
c0100aba:	c7 04 24 13 c4 10 c0 	movl   $0xc010c413,(%esp)
c0100ac1:	e8 0b f8 ff ff       	call   c01002d1 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c0100ac6:	c7 44 24 04 00 10 1b 	movl   $0xc01b1000,0x4(%esp)
c0100acd:	c0 
c0100ace:	c7 04 24 2b c4 10 c0 	movl   $0xc010c42b,(%esp)
c0100ad5:	e8 f7 f7 ff ff       	call   c01002d1 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c0100ada:	c7 44 24 04 60 41 1b 	movl   $0xc01b4160,0x4(%esp)
c0100ae1:	c0 
c0100ae2:	c7 04 24 43 c4 10 c0 	movl   $0xc010c443,(%esp)
c0100ae9:	e8 e3 f7 ff ff       	call   c01002d1 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023) / 1024);
c0100aee:	b8 60 41 1b c0       	mov    $0xc01b4160,%eax
c0100af3:	2d 36 00 10 c0       	sub    $0xc0100036,%eax
c0100af8:	05 ff 03 00 00       	add    $0x3ff,%eax
c0100afd:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c0100b03:	85 c0                	test   %eax,%eax
c0100b05:	0f 48 c2             	cmovs  %edx,%eax
c0100b08:	c1 f8 0a             	sar    $0xa,%eax
c0100b0b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b0f:	c7 04 24 5c c4 10 c0 	movl   $0xc010c45c,(%esp)
c0100b16:	e8 b6 f7 ff ff       	call   c01002d1 <cprintf>
}
c0100b1b:	90                   	nop
c0100b1c:	c9                   	leave  
c0100b1d:	c3                   	ret    

c0100b1e <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void print_debuginfo(uintptr_t eip)
{
c0100b1e:	f3 0f 1e fb          	endbr32 
c0100b22:	55                   	push   %ebp
c0100b23:	89 e5                	mov    %esp,%ebp
c0100b25:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0)
c0100b2b:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100b2e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b32:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b35:	89 04 24             	mov    %eax,(%esp)
c0100b38:	e8 2d fb ff ff       	call   c010066a <debuginfo_eip>
c0100b3d:	85 c0                	test   %eax,%eax
c0100b3f:	74 15                	je     c0100b56 <print_debuginfo+0x38>
    {
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c0100b41:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b44:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b48:	c7 04 24 86 c4 10 c0 	movl   $0xc010c486,(%esp)
c0100b4f:	e8 7d f7 ff ff       	call   c01002d1 <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
c0100b54:	eb 6c                	jmp    c0100bc2 <print_debuginfo+0xa4>
        for (j = 0; j < info.eip_fn_namelen; j++)
c0100b56:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100b5d:	eb 1b                	jmp    c0100b7a <print_debuginfo+0x5c>
            fnname[j] = info.eip_fn_name[j];
c0100b5f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100b62:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b65:	01 d0                	add    %edx,%eax
c0100b67:	0f b6 10             	movzbl (%eax),%edx
c0100b6a:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100b70:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b73:	01 c8                	add    %ecx,%eax
c0100b75:	88 10                	mov    %dl,(%eax)
        for (j = 0; j < info.eip_fn_namelen; j++)
c0100b77:	ff 45 f4             	incl   -0xc(%ebp)
c0100b7a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100b7d:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0100b80:	7c dd                	jl     c0100b5f <print_debuginfo+0x41>
        fnname[j] = '\0';
c0100b82:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100b88:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b8b:	01 d0                	add    %edx,%eax
c0100b8d:	c6 00 00             	movb   $0x0,(%eax)
                fnname, eip - info.eip_fn_addr);
c0100b90:	8b 45 ec             	mov    -0x14(%ebp),%eax
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0100b93:	8b 55 08             	mov    0x8(%ebp),%edx
c0100b96:	89 d1                	mov    %edx,%ecx
c0100b98:	29 c1                	sub    %eax,%ecx
c0100b9a:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0100b9d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100ba0:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0100ba4:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100baa:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0100bae:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100bb2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100bb6:	c7 04 24 a2 c4 10 c0 	movl   $0xc010c4a2,(%esp)
c0100bbd:	e8 0f f7 ff ff       	call   c01002d1 <cprintf>
}
c0100bc2:	90                   	nop
c0100bc3:	c9                   	leave  
c0100bc4:	c3                   	ret    

c0100bc5 <read_eip>:

static __noinline uint32_t
read_eip(void)
{
c0100bc5:	f3 0f 1e fb          	endbr32 
c0100bc9:	55                   	push   %ebp
c0100bca:	89 e5                	mov    %esp,%ebp
c0100bcc:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0"
c0100bcf:	8b 45 04             	mov    0x4(%ebp),%eax
c0100bd2:	89 45 fc             	mov    %eax,-0x4(%ebp)
                 : "=r"(eip));
    return eip;
c0100bd5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0100bd8:	c9                   	leave  
c0100bd9:	c3                   	ret    

c0100bda <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void print_stackframe(void)
{
c0100bda:	f3 0f 1e fb          	endbr32 
c0100bde:	55                   	push   %ebp
c0100bdf:	89 e5                	mov    %esp,%ebp
c0100be1:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c0100be4:	89 e8                	mov    %ebp,%eax
c0100be6:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
c0100be9:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp(), eip = read_eip();
c0100bec:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100bef:	e8 d1 ff ff ff       	call   c0100bc5 <read_eip>
c0100bf4:	89 45 f0             	mov    %eax,-0x10(%ebp)

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i++)
c0100bf7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0100bfe:	e9 84 00 00 00       	jmp    c0100c87 <print_stackframe+0xad>
    {
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
c0100c03:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100c06:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100c0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c0d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c11:	c7 04 24 b4 c4 10 c0 	movl   $0xc010c4b4,(%esp)
c0100c18:	e8 b4 f6 ff ff       	call   c01002d1 <cprintf>
        uint32_t *args = (uint32_t *)ebp + 2;
c0100c1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c20:	83 c0 08             	add    $0x8,%eax
c0100c23:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (j = 0; j < 4; j++)
c0100c26:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0100c2d:	eb 24                	jmp    c0100c53 <print_stackframe+0x79>
        {
            cprintf("0x%08x ", args[j]);
c0100c2f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100c32:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100c39:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100c3c:	01 d0                	add    %edx,%eax
c0100c3e:	8b 00                	mov    (%eax),%eax
c0100c40:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c44:	c7 04 24 d0 c4 10 c0 	movl   $0xc010c4d0,(%esp)
c0100c4b:	e8 81 f6 ff ff       	call   c01002d1 <cprintf>
        for (j = 0; j < 4; j++)
c0100c50:	ff 45 e8             	incl   -0x18(%ebp)
c0100c53:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
c0100c57:	7e d6                	jle    c0100c2f <print_stackframe+0x55>
        }
        cprintf("\n");
c0100c59:	c7 04 24 d8 c4 10 c0 	movl   $0xc010c4d8,(%esp)
c0100c60:	e8 6c f6 ff ff       	call   c01002d1 <cprintf>
        print_debuginfo(eip - 1);
c0100c65:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100c68:	48                   	dec    %eax
c0100c69:	89 04 24             	mov    %eax,(%esp)
c0100c6c:	e8 ad fe ff ff       	call   c0100b1e <print_debuginfo>
        eip = ((uint32_t *)ebp)[1];
c0100c71:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c74:	83 c0 04             	add    $0x4,%eax
c0100c77:	8b 00                	mov    (%eax),%eax
c0100c79:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = ((uint32_t *)ebp)[0];
c0100c7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c7f:	8b 00                	mov    (%eax),%eax
c0100c81:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i++)
c0100c84:	ff 45 ec             	incl   -0x14(%ebp)
c0100c87:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100c8b:	74 0a                	je     c0100c97 <print_stackframe+0xbd>
c0100c8d:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100c91:	0f 8e 6c ff ff ff    	jle    c0100c03 <print_stackframe+0x29>
    }
}
c0100c97:	90                   	nop
c0100c98:	c9                   	leave  
c0100c99:	c3                   	ret    

c0100c9a <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100c9a:	f3 0f 1e fb          	endbr32 
c0100c9e:	55                   	push   %ebp
c0100c9f:	89 e5                	mov    %esp,%ebp
c0100ca1:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100ca4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100cab:	eb 0c                	jmp    c0100cb9 <parse+0x1f>
            *buf ++ = '\0';
c0100cad:	8b 45 08             	mov    0x8(%ebp),%eax
c0100cb0:	8d 50 01             	lea    0x1(%eax),%edx
c0100cb3:	89 55 08             	mov    %edx,0x8(%ebp)
c0100cb6:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100cb9:	8b 45 08             	mov    0x8(%ebp),%eax
c0100cbc:	0f b6 00             	movzbl (%eax),%eax
c0100cbf:	84 c0                	test   %al,%al
c0100cc1:	74 1d                	je     c0100ce0 <parse+0x46>
c0100cc3:	8b 45 08             	mov    0x8(%ebp),%eax
c0100cc6:	0f b6 00             	movzbl (%eax),%eax
c0100cc9:	0f be c0             	movsbl %al,%eax
c0100ccc:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100cd0:	c7 04 24 5c c5 10 c0 	movl   $0xc010c55c,(%esp)
c0100cd7:	e8 0c ab 00 00       	call   c010b7e8 <strchr>
c0100cdc:	85 c0                	test   %eax,%eax
c0100cde:	75 cd                	jne    c0100cad <parse+0x13>
        }
        if (*buf == '\0') {
c0100ce0:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ce3:	0f b6 00             	movzbl (%eax),%eax
c0100ce6:	84 c0                	test   %al,%al
c0100ce8:	74 65                	je     c0100d4f <parse+0xb5>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100cea:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100cee:	75 14                	jne    c0100d04 <parse+0x6a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100cf0:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100cf7:	00 
c0100cf8:	c7 04 24 61 c5 10 c0 	movl   $0xc010c561,(%esp)
c0100cff:	e8 cd f5 ff ff       	call   c01002d1 <cprintf>
        }
        argv[argc ++] = buf;
c0100d04:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d07:	8d 50 01             	lea    0x1(%eax),%edx
c0100d0a:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100d0d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100d14:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100d17:	01 c2                	add    %eax,%edx
c0100d19:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d1c:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100d1e:	eb 03                	jmp    c0100d23 <parse+0x89>
            buf ++;
c0100d20:	ff 45 08             	incl   0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100d23:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d26:	0f b6 00             	movzbl (%eax),%eax
c0100d29:	84 c0                	test   %al,%al
c0100d2b:	74 8c                	je     c0100cb9 <parse+0x1f>
c0100d2d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d30:	0f b6 00             	movzbl (%eax),%eax
c0100d33:	0f be c0             	movsbl %al,%eax
c0100d36:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d3a:	c7 04 24 5c c5 10 c0 	movl   $0xc010c55c,(%esp)
c0100d41:	e8 a2 aa 00 00       	call   c010b7e8 <strchr>
c0100d46:	85 c0                	test   %eax,%eax
c0100d48:	74 d6                	je     c0100d20 <parse+0x86>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100d4a:	e9 6a ff ff ff       	jmp    c0100cb9 <parse+0x1f>
            break;
c0100d4f:	90                   	nop
        }
    }
    return argc;
c0100d50:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100d53:	c9                   	leave  
c0100d54:	c3                   	ret    

c0100d55 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100d55:	f3 0f 1e fb          	endbr32 
c0100d59:	55                   	push   %ebp
c0100d5a:	89 e5                	mov    %esp,%ebp
c0100d5c:	53                   	push   %ebx
c0100d5d:	83 ec 64             	sub    $0x64,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100d60:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100d63:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d67:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d6a:	89 04 24             	mov    %eax,(%esp)
c0100d6d:	e8 28 ff ff ff       	call   c0100c9a <parse>
c0100d72:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100d75:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100d79:	75 0a                	jne    c0100d85 <runcmd+0x30>
        return 0;
c0100d7b:	b8 00 00 00 00       	mov    $0x0,%eax
c0100d80:	e9 83 00 00 00       	jmp    c0100e08 <runcmd+0xb3>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d85:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100d8c:	eb 5a                	jmp    c0100de8 <runcmd+0x93>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100d8e:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0100d91:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d94:	89 d0                	mov    %edx,%eax
c0100d96:	01 c0                	add    %eax,%eax
c0100d98:	01 d0                	add    %edx,%eax
c0100d9a:	c1 e0 02             	shl    $0x2,%eax
c0100d9d:	05 00 e0 12 c0       	add    $0xc012e000,%eax
c0100da2:	8b 00                	mov    (%eax),%eax
c0100da4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0100da8:	89 04 24             	mov    %eax,(%esp)
c0100dab:	e8 94 a9 00 00       	call   c010b744 <strcmp>
c0100db0:	85 c0                	test   %eax,%eax
c0100db2:	75 31                	jne    c0100de5 <runcmd+0x90>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100db4:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100db7:	89 d0                	mov    %edx,%eax
c0100db9:	01 c0                	add    %eax,%eax
c0100dbb:	01 d0                	add    %edx,%eax
c0100dbd:	c1 e0 02             	shl    $0x2,%eax
c0100dc0:	05 08 e0 12 c0       	add    $0xc012e008,%eax
c0100dc5:	8b 10                	mov    (%eax),%edx
c0100dc7:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100dca:	83 c0 04             	add    $0x4,%eax
c0100dcd:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0100dd0:	8d 59 ff             	lea    -0x1(%ecx),%ebx
c0100dd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c0100dd6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100dda:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100dde:	89 1c 24             	mov    %ebx,(%esp)
c0100de1:	ff d2                	call   *%edx
c0100de3:	eb 23                	jmp    c0100e08 <runcmd+0xb3>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100de5:	ff 45 f4             	incl   -0xc(%ebp)
c0100de8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100deb:	83 f8 02             	cmp    $0x2,%eax
c0100dee:	76 9e                	jbe    c0100d8e <runcmd+0x39>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100df0:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100df3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100df7:	c7 04 24 7f c5 10 c0 	movl   $0xc010c57f,(%esp)
c0100dfe:	e8 ce f4 ff ff       	call   c01002d1 <cprintf>
    return 0;
c0100e03:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e08:	83 c4 64             	add    $0x64,%esp
c0100e0b:	5b                   	pop    %ebx
c0100e0c:	5d                   	pop    %ebp
c0100e0d:	c3                   	ret    

c0100e0e <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100e0e:	f3 0f 1e fb          	endbr32 
c0100e12:	55                   	push   %ebp
c0100e13:	89 e5                	mov    %esp,%ebp
c0100e15:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100e18:	c7 04 24 98 c5 10 c0 	movl   $0xc010c598,(%esp)
c0100e1f:	e8 ad f4 ff ff       	call   c01002d1 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100e24:	c7 04 24 c0 c5 10 c0 	movl   $0xc010c5c0,(%esp)
c0100e2b:	e8 a1 f4 ff ff       	call   c01002d1 <cprintf>

    if (tf != NULL) {
c0100e30:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100e34:	74 0b                	je     c0100e41 <kmonitor+0x33>
        print_trapframe(tf);
c0100e36:	8b 45 08             	mov    0x8(%ebp),%eax
c0100e39:	89 04 24             	mov    %eax,(%esp)
c0100e3c:	e8 cc 16 00 00       	call   c010250d <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100e41:	c7 04 24 e5 c5 10 c0 	movl   $0xc010c5e5,(%esp)
c0100e48:	e8 37 f5 ff ff       	call   c0100384 <readline>
c0100e4d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100e50:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100e54:	74 eb                	je     c0100e41 <kmonitor+0x33>
            if (runcmd(buf, tf) < 0) {
c0100e56:	8b 45 08             	mov    0x8(%ebp),%eax
c0100e59:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100e5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100e60:	89 04 24             	mov    %eax,(%esp)
c0100e63:	e8 ed fe ff ff       	call   c0100d55 <runcmd>
c0100e68:	85 c0                	test   %eax,%eax
c0100e6a:	78 02                	js     c0100e6e <kmonitor+0x60>
        if ((buf = readline("K> ")) != NULL) {
c0100e6c:	eb d3                	jmp    c0100e41 <kmonitor+0x33>
                break;
c0100e6e:	90                   	nop
            }
        }
    }
}
c0100e6f:	90                   	nop
c0100e70:	c9                   	leave  
c0100e71:	c3                   	ret    

c0100e72 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100e72:	f3 0f 1e fb          	endbr32 
c0100e76:	55                   	push   %ebp
c0100e77:	89 e5                	mov    %esp,%ebp
c0100e79:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100e7c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100e83:	eb 3d                	jmp    c0100ec2 <mon_help+0x50>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100e85:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100e88:	89 d0                	mov    %edx,%eax
c0100e8a:	01 c0                	add    %eax,%eax
c0100e8c:	01 d0                	add    %edx,%eax
c0100e8e:	c1 e0 02             	shl    $0x2,%eax
c0100e91:	05 04 e0 12 c0       	add    $0xc012e004,%eax
c0100e96:	8b 08                	mov    (%eax),%ecx
c0100e98:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100e9b:	89 d0                	mov    %edx,%eax
c0100e9d:	01 c0                	add    %eax,%eax
c0100e9f:	01 d0                	add    %edx,%eax
c0100ea1:	c1 e0 02             	shl    $0x2,%eax
c0100ea4:	05 00 e0 12 c0       	add    $0xc012e000,%eax
c0100ea9:	8b 00                	mov    (%eax),%eax
c0100eab:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100eaf:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100eb3:	c7 04 24 e9 c5 10 c0 	movl   $0xc010c5e9,(%esp)
c0100eba:	e8 12 f4 ff ff       	call   c01002d1 <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100ebf:	ff 45 f4             	incl   -0xc(%ebp)
c0100ec2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ec5:	83 f8 02             	cmp    $0x2,%eax
c0100ec8:	76 bb                	jbe    c0100e85 <mon_help+0x13>
    }
    return 0;
c0100eca:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100ecf:	c9                   	leave  
c0100ed0:	c3                   	ret    

c0100ed1 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100ed1:	f3 0f 1e fb          	endbr32 
c0100ed5:	55                   	push   %ebp
c0100ed6:	89 e5                	mov    %esp,%ebp
c0100ed8:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100edb:	e8 a8 fb ff ff       	call   c0100a88 <print_kerninfo>
    return 0;
c0100ee0:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100ee5:	c9                   	leave  
c0100ee6:	c3                   	ret    

c0100ee7 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100ee7:	f3 0f 1e fb          	endbr32 
c0100eeb:	55                   	push   %ebp
c0100eec:	89 e5                	mov    %esp,%ebp
c0100eee:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100ef1:	e8 e4 fc ff ff       	call   c0100bda <print_stackframe>
    return 0;
c0100ef6:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100efb:	c9                   	leave  
c0100efc:	c3                   	ret    

c0100efd <ide_wait_ready>:
    unsigned int size;          // Size in Sectors
    unsigned char model[41];    // Model in String
} ide_devices[MAX_IDE];

static int
ide_wait_ready(unsigned short iobase, bool check_error) {
c0100efd:	f3 0f 1e fb          	endbr32 
c0100f01:	55                   	push   %ebp
c0100f02:	89 e5                	mov    %esp,%ebp
c0100f04:	83 ec 14             	sub    $0x14,%esp
c0100f07:	8b 45 08             	mov    0x8(%ebp),%eax
c0100f0a:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    int r;
    while ((r = inb(iobase + ISA_STATUS)) & IDE_BSY)
c0100f0e:	90                   	nop
c0100f0f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100f12:	83 c0 07             	add    $0x7,%eax
c0100f15:	0f b7 c0             	movzwl %ax,%eax
c0100f18:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f1c:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100f20:	89 c2                	mov    %eax,%edx
c0100f22:	ec                   	in     (%dx),%al
c0100f23:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0100f26:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0100f2a:	0f b6 c0             	movzbl %al,%eax
c0100f2d:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100f30:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f33:	25 80 00 00 00       	and    $0x80,%eax
c0100f38:	85 c0                	test   %eax,%eax
c0100f3a:	75 d3                	jne    c0100f0f <ide_wait_ready+0x12>
        /* nothing */;
    if (check_error && (r & (IDE_DF | IDE_ERR)) != 0) {
c0100f3c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0100f40:	74 11                	je     c0100f53 <ide_wait_ready+0x56>
c0100f42:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f45:	83 e0 21             	and    $0x21,%eax
c0100f48:	85 c0                	test   %eax,%eax
c0100f4a:	74 07                	je     c0100f53 <ide_wait_ready+0x56>
        return -1;
c0100f4c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100f51:	eb 05                	jmp    c0100f58 <ide_wait_ready+0x5b>
    }
    return 0;
c0100f53:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100f58:	c9                   	leave  
c0100f59:	c3                   	ret    

c0100f5a <ide_init>:

void
ide_init(void) {
c0100f5a:	f3 0f 1e fb          	endbr32 
c0100f5e:	55                   	push   %ebp
c0100f5f:	89 e5                	mov    %esp,%ebp
c0100f61:	57                   	push   %edi
c0100f62:	53                   	push   %ebx
c0100f63:	81 ec 50 02 00 00    	sub    $0x250,%esp
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c0100f69:	66 c7 45 f6 00 00    	movw   $0x0,-0xa(%ebp)
c0100f6f:	e9 bd 02 00 00       	jmp    c0101231 <ide_init+0x2d7>
        /* assume that no device here */
        ide_devices[ideno].valid = 0;
c0100f74:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100f78:	89 d0                	mov    %edx,%eax
c0100f7a:	c1 e0 03             	shl    $0x3,%eax
c0100f7d:	29 d0                	sub    %edx,%eax
c0100f7f:	c1 e0 03             	shl    $0x3,%eax
c0100f82:	05 40 14 1b c0       	add    $0xc01b1440,%eax
c0100f87:	c6 00 00             	movb   $0x0,(%eax)

        iobase = IO_BASE(ideno);
c0100f8a:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100f8e:	d1 e8                	shr    %eax
c0100f90:	0f b7 c0             	movzwl %ax,%eax
c0100f93:	8b 04 85 f4 c5 10 c0 	mov    -0x3fef3a0c(,%eax,4),%eax
c0100f9a:	66 89 45 ea          	mov    %ax,-0x16(%ebp)

        /* wait device ready */
        ide_wait_ready(iobase, 0);
c0100f9e:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100fa2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100fa9:	00 
c0100faa:	89 04 24             	mov    %eax,(%esp)
c0100fad:	e8 4b ff ff ff       	call   c0100efd <ide_wait_ready>

        /* step1: select drive */
        outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4));
c0100fb2:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100fb6:	c1 e0 04             	shl    $0x4,%eax
c0100fb9:	24 10                	and    $0x10,%al
c0100fbb:	0c e0                	or     $0xe0,%al
c0100fbd:	0f b6 c0             	movzbl %al,%eax
c0100fc0:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100fc4:	83 c2 06             	add    $0x6,%edx
c0100fc7:	0f b7 d2             	movzwl %dx,%edx
c0100fca:	66 89 55 ca          	mov    %dx,-0x36(%ebp)
c0100fce:	88 45 c9             	mov    %al,-0x37(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100fd1:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c0100fd5:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c0100fd9:	ee                   	out    %al,(%dx)
}
c0100fda:	90                   	nop
        ide_wait_ready(iobase, 0);
c0100fdb:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100fdf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100fe6:	00 
c0100fe7:	89 04 24             	mov    %eax,(%esp)
c0100fea:	e8 0e ff ff ff       	call   c0100efd <ide_wait_ready>

        /* step2: send ATA identify command */
        outb(iobase + ISA_COMMAND, IDE_CMD_IDENTIFY);
c0100fef:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100ff3:	83 c0 07             	add    $0x7,%eax
c0100ff6:	0f b7 c0             	movzwl %ax,%eax
c0100ff9:	66 89 45 ce          	mov    %ax,-0x32(%ebp)
c0100ffd:	c6 45 cd ec          	movb   $0xec,-0x33(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101001:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c0101005:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c0101009:	ee                   	out    %al,(%dx)
}
c010100a:	90                   	nop
        ide_wait_ready(iobase, 0);
c010100b:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c010100f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101016:	00 
c0101017:	89 04 24             	mov    %eax,(%esp)
c010101a:	e8 de fe ff ff       	call   c0100efd <ide_wait_ready>

        /* step3: polling */
        if (inb(iobase + ISA_STATUS) == 0 || ide_wait_ready(iobase, 1) != 0) {
c010101f:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0101023:	83 c0 07             	add    $0x7,%eax
c0101026:	0f b7 c0             	movzwl %ax,%eax
c0101029:	66 89 45 d2          	mov    %ax,-0x2e(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010102d:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
c0101031:	89 c2                	mov    %eax,%edx
c0101033:	ec                   	in     (%dx),%al
c0101034:	88 45 d1             	mov    %al,-0x2f(%ebp)
    return data;
c0101037:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c010103b:	84 c0                	test   %al,%al
c010103d:	0f 84 e4 01 00 00    	je     c0101227 <ide_init+0x2cd>
c0101043:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0101047:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010104e:	00 
c010104f:	89 04 24             	mov    %eax,(%esp)
c0101052:	e8 a6 fe ff ff       	call   c0100efd <ide_wait_ready>
c0101057:	85 c0                	test   %eax,%eax
c0101059:	0f 85 c8 01 00 00    	jne    c0101227 <ide_init+0x2cd>
            continue ;
        }

        /* device is ok */
        ide_devices[ideno].valid = 1;
c010105f:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101063:	89 d0                	mov    %edx,%eax
c0101065:	c1 e0 03             	shl    $0x3,%eax
c0101068:	29 d0                	sub    %edx,%eax
c010106a:	c1 e0 03             	shl    $0x3,%eax
c010106d:	05 40 14 1b c0       	add    $0xc01b1440,%eax
c0101072:	c6 00 01             	movb   $0x1,(%eax)

        /* read identification space of the device */
        unsigned int buffer[128];
        insl(iobase + ISA_DATA, buffer, sizeof(buffer) / sizeof(unsigned int));
c0101075:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0101079:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c010107c:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c0101082:	89 45 c0             	mov    %eax,-0x40(%ebp)
c0101085:	c7 45 bc 80 00 00 00 	movl   $0x80,-0x44(%ebp)
    asm volatile (
c010108c:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c010108f:	8b 4d c0             	mov    -0x40(%ebp),%ecx
c0101092:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0101095:	89 cb                	mov    %ecx,%ebx
c0101097:	89 df                	mov    %ebx,%edi
c0101099:	89 c1                	mov    %eax,%ecx
c010109b:	fc                   	cld    
c010109c:	f2 6d                	repnz insl (%dx),%es:(%edi)
c010109e:	89 c8                	mov    %ecx,%eax
c01010a0:	89 fb                	mov    %edi,%ebx
c01010a2:	89 5d c0             	mov    %ebx,-0x40(%ebp)
c01010a5:	89 45 bc             	mov    %eax,-0x44(%ebp)
}
c01010a8:	90                   	nop

        unsigned char *ident = (unsigned char *)buffer;
c01010a9:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c01010af:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        unsigned int sectors;
        unsigned int cmdsets = *(unsigned int *)(ident + IDE_IDENT_CMDSETS);
c01010b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01010b5:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
c01010bb:	89 45 e0             	mov    %eax,-0x20(%ebp)
        /* device use 48-bits or 28-bits addressing */
        if (cmdsets & (1 << 26)) {
c01010be:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01010c1:	25 00 00 00 04       	and    $0x4000000,%eax
c01010c6:	85 c0                	test   %eax,%eax
c01010c8:	74 0e                	je     c01010d8 <ide_init+0x17e>
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA_EXT);
c01010ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01010cd:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
c01010d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01010d6:	eb 09                	jmp    c01010e1 <ide_init+0x187>
        }
        else {
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA);
c01010d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01010db:	8b 40 78             	mov    0x78(%eax),%eax
c01010de:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        ide_devices[ideno].sets = cmdsets;
c01010e1:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01010e5:	89 d0                	mov    %edx,%eax
c01010e7:	c1 e0 03             	shl    $0x3,%eax
c01010ea:	29 d0                	sub    %edx,%eax
c01010ec:	c1 e0 03             	shl    $0x3,%eax
c01010ef:	8d 90 44 14 1b c0    	lea    -0x3fe4ebbc(%eax),%edx
c01010f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01010f8:	89 02                	mov    %eax,(%edx)
        ide_devices[ideno].size = sectors;
c01010fa:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01010fe:	89 d0                	mov    %edx,%eax
c0101100:	c1 e0 03             	shl    $0x3,%eax
c0101103:	29 d0                	sub    %edx,%eax
c0101105:	c1 e0 03             	shl    $0x3,%eax
c0101108:	8d 90 48 14 1b c0    	lea    -0x3fe4ebb8(%eax),%edx
c010110e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101111:	89 02                	mov    %eax,(%edx)

        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);
c0101113:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101116:	83 c0 62             	add    $0x62,%eax
c0101119:	0f b7 00             	movzwl (%eax),%eax
c010111c:	25 00 02 00 00       	and    $0x200,%eax
c0101121:	85 c0                	test   %eax,%eax
c0101123:	75 24                	jne    c0101149 <ide_init+0x1ef>
c0101125:	c7 44 24 0c fc c5 10 	movl   $0xc010c5fc,0xc(%esp)
c010112c:	c0 
c010112d:	c7 44 24 08 3f c6 10 	movl   $0xc010c63f,0x8(%esp)
c0101134:	c0 
c0101135:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c010113c:	00 
c010113d:	c7 04 24 54 c6 10 c0 	movl   $0xc010c654,(%esp)
c0101144:	e8 f4 f2 ff ff       	call   c010043d <__panic>

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
c0101149:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010114d:	89 d0                	mov    %edx,%eax
c010114f:	c1 e0 03             	shl    $0x3,%eax
c0101152:	29 d0                	sub    %edx,%eax
c0101154:	c1 e0 03             	shl    $0x3,%eax
c0101157:	05 40 14 1b c0       	add    $0xc01b1440,%eax
c010115c:	83 c0 0c             	add    $0xc,%eax
c010115f:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0101162:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101165:	83 c0 36             	add    $0x36,%eax
c0101168:	89 45 d8             	mov    %eax,-0x28(%ebp)
        unsigned int i, length = 40;
c010116b:	c7 45 d4 28 00 00 00 	movl   $0x28,-0x2c(%ebp)
        for (i = 0; i < length; i += 2) {
c0101172:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0101179:	eb 34                	jmp    c01011af <ide_init+0x255>
            model[i] = data[i + 1], model[i + 1] = data[i];
c010117b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010117e:	8d 50 01             	lea    0x1(%eax),%edx
c0101181:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0101184:	01 c2                	add    %eax,%edx
c0101186:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0101189:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010118c:	01 c8                	add    %ecx,%eax
c010118e:	0f b6 12             	movzbl (%edx),%edx
c0101191:	88 10                	mov    %dl,(%eax)
c0101193:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0101196:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101199:	01 c2                	add    %eax,%edx
c010119b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010119e:	8d 48 01             	lea    0x1(%eax),%ecx
c01011a1:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01011a4:	01 c8                	add    %ecx,%eax
c01011a6:	0f b6 12             	movzbl (%edx),%edx
c01011a9:	88 10                	mov    %dl,(%eax)
        for (i = 0; i < length; i += 2) {
c01011ab:	83 45 ec 02          	addl   $0x2,-0x14(%ebp)
c01011af:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01011b2:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c01011b5:	72 c4                	jb     c010117b <ide_init+0x221>
        }
        do {
            model[i] = '\0';
c01011b7:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01011ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01011bd:	01 d0                	add    %edx,%eax
c01011bf:	c6 00 00             	movb   $0x0,(%eax)
        } while (i -- > 0 && model[i] == ' ');
c01011c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01011c5:	8d 50 ff             	lea    -0x1(%eax),%edx
c01011c8:	89 55 ec             	mov    %edx,-0x14(%ebp)
c01011cb:	85 c0                	test   %eax,%eax
c01011cd:	74 0f                	je     c01011de <ide_init+0x284>
c01011cf:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01011d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01011d5:	01 d0                	add    %edx,%eax
c01011d7:	0f b6 00             	movzbl (%eax),%eax
c01011da:	3c 20                	cmp    $0x20,%al
c01011dc:	74 d9                	je     c01011b7 <ide_init+0x25d>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
c01011de:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01011e2:	89 d0                	mov    %edx,%eax
c01011e4:	c1 e0 03             	shl    $0x3,%eax
c01011e7:	29 d0                	sub    %edx,%eax
c01011e9:	c1 e0 03             	shl    $0x3,%eax
c01011ec:	05 40 14 1b c0       	add    $0xc01b1440,%eax
c01011f1:	8d 48 0c             	lea    0xc(%eax),%ecx
c01011f4:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01011f8:	89 d0                	mov    %edx,%eax
c01011fa:	c1 e0 03             	shl    $0x3,%eax
c01011fd:	29 d0                	sub    %edx,%eax
c01011ff:	c1 e0 03             	shl    $0x3,%eax
c0101202:	05 48 14 1b c0       	add    $0xc01b1448,%eax
c0101207:	8b 10                	mov    (%eax),%edx
c0101209:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010120d:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0101211:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101215:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101219:	c7 04 24 66 c6 10 c0 	movl   $0xc010c666,(%esp)
c0101220:	e8 ac f0 ff ff       	call   c01002d1 <cprintf>
c0101225:	eb 01                	jmp    c0101228 <ide_init+0x2ce>
            continue ;
c0101227:	90                   	nop
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c0101228:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010122c:	40                   	inc    %eax
c010122d:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
c0101231:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101235:	83 f8 03             	cmp    $0x3,%eax
c0101238:	0f 86 36 fd ff ff    	jbe    c0100f74 <ide_init+0x1a>
    }

    // enable ide interrupt
    pic_enable(IRQ_IDE1);
c010123e:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
c0101245:	e8 1f 0f 00 00       	call   c0102169 <pic_enable>
    pic_enable(IRQ_IDE2);
c010124a:	c7 04 24 0f 00 00 00 	movl   $0xf,(%esp)
c0101251:	e8 13 0f 00 00       	call   c0102169 <pic_enable>
}
c0101256:	90                   	nop
c0101257:	81 c4 50 02 00 00    	add    $0x250,%esp
c010125d:	5b                   	pop    %ebx
c010125e:	5f                   	pop    %edi
c010125f:	5d                   	pop    %ebp
c0101260:	c3                   	ret    

c0101261 <ide_device_valid>:

bool
ide_device_valid(unsigned short ideno) {
c0101261:	f3 0f 1e fb          	endbr32 
c0101265:	55                   	push   %ebp
c0101266:	89 e5                	mov    %esp,%ebp
c0101268:	83 ec 04             	sub    $0x4,%esp
c010126b:	8b 45 08             	mov    0x8(%ebp),%eax
c010126e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    return VALID_IDE(ideno);
c0101272:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101276:	83 f8 03             	cmp    $0x3,%eax
c0101279:	77 21                	ja     c010129c <ide_device_valid+0x3b>
c010127b:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
c010127f:	89 d0                	mov    %edx,%eax
c0101281:	c1 e0 03             	shl    $0x3,%eax
c0101284:	29 d0                	sub    %edx,%eax
c0101286:	c1 e0 03             	shl    $0x3,%eax
c0101289:	05 40 14 1b c0       	add    $0xc01b1440,%eax
c010128e:	0f b6 00             	movzbl (%eax),%eax
c0101291:	84 c0                	test   %al,%al
c0101293:	74 07                	je     c010129c <ide_device_valid+0x3b>
c0101295:	b8 01 00 00 00       	mov    $0x1,%eax
c010129a:	eb 05                	jmp    c01012a1 <ide_device_valid+0x40>
c010129c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01012a1:	c9                   	leave  
c01012a2:	c3                   	ret    

c01012a3 <ide_device_size>:

size_t
ide_device_size(unsigned short ideno) {
c01012a3:	f3 0f 1e fb          	endbr32 
c01012a7:	55                   	push   %ebp
c01012a8:	89 e5                	mov    %esp,%ebp
c01012aa:	83 ec 08             	sub    $0x8,%esp
c01012ad:	8b 45 08             	mov    0x8(%ebp),%eax
c01012b0:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    if (ide_device_valid(ideno)) {
c01012b4:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c01012b8:	89 04 24             	mov    %eax,(%esp)
c01012bb:	e8 a1 ff ff ff       	call   c0101261 <ide_device_valid>
c01012c0:	85 c0                	test   %eax,%eax
c01012c2:	74 17                	je     c01012db <ide_device_size+0x38>
        return ide_devices[ideno].size;
c01012c4:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
c01012c8:	89 d0                	mov    %edx,%eax
c01012ca:	c1 e0 03             	shl    $0x3,%eax
c01012cd:	29 d0                	sub    %edx,%eax
c01012cf:	c1 e0 03             	shl    $0x3,%eax
c01012d2:	05 48 14 1b c0       	add    $0xc01b1448,%eax
c01012d7:	8b 00                	mov    (%eax),%eax
c01012d9:	eb 05                	jmp    c01012e0 <ide_device_size+0x3d>
    }
    return 0;
c01012db:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01012e0:	c9                   	leave  
c01012e1:	c3                   	ret    

c01012e2 <ide_read_secs>:

int
ide_read_secs(unsigned short ideno, uint32_t secno, void *dst, size_t nsecs) {
c01012e2:	f3 0f 1e fb          	endbr32 
c01012e6:	55                   	push   %ebp
c01012e7:	89 e5                	mov    %esp,%ebp
c01012e9:	57                   	push   %edi
c01012ea:	53                   	push   %ebx
c01012eb:	83 ec 50             	sub    $0x50,%esp
c01012ee:	8b 45 08             	mov    0x8(%ebp),%eax
c01012f1:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c01012f5:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c01012fc:	77 23                	ja     c0101321 <ide_read_secs+0x3f>
c01012fe:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101302:	83 f8 03             	cmp    $0x3,%eax
c0101305:	77 1a                	ja     c0101321 <ide_read_secs+0x3f>
c0101307:	0f b7 55 c4          	movzwl -0x3c(%ebp),%edx
c010130b:	89 d0                	mov    %edx,%eax
c010130d:	c1 e0 03             	shl    $0x3,%eax
c0101310:	29 d0                	sub    %edx,%eax
c0101312:	c1 e0 03             	shl    $0x3,%eax
c0101315:	05 40 14 1b c0       	add    $0xc01b1440,%eax
c010131a:	0f b6 00             	movzbl (%eax),%eax
c010131d:	84 c0                	test   %al,%al
c010131f:	75 24                	jne    c0101345 <ide_read_secs+0x63>
c0101321:	c7 44 24 0c 84 c6 10 	movl   $0xc010c684,0xc(%esp)
c0101328:	c0 
c0101329:	c7 44 24 08 3f c6 10 	movl   $0xc010c63f,0x8(%esp)
c0101330:	c0 
c0101331:	c7 44 24 04 9f 00 00 	movl   $0x9f,0x4(%esp)
c0101338:	00 
c0101339:	c7 04 24 54 c6 10 c0 	movl   $0xc010c654,(%esp)
c0101340:	e8 f8 f0 ff ff       	call   c010043d <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0101345:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c010134c:	77 0f                	ja     c010135d <ide_read_secs+0x7b>
c010134e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101351:	8b 45 14             	mov    0x14(%ebp),%eax
c0101354:	01 d0                	add    %edx,%eax
c0101356:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c010135b:	76 24                	jbe    c0101381 <ide_read_secs+0x9f>
c010135d:	c7 44 24 0c ac c6 10 	movl   $0xc010c6ac,0xc(%esp)
c0101364:	c0 
c0101365:	c7 44 24 08 3f c6 10 	movl   $0xc010c63f,0x8(%esp)
c010136c:	c0 
c010136d:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
c0101374:	00 
c0101375:	c7 04 24 54 c6 10 c0 	movl   $0xc010c654,(%esp)
c010137c:	e8 bc f0 ff ff       	call   c010043d <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0101381:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101385:	d1 e8                	shr    %eax
c0101387:	0f b7 c0             	movzwl %ax,%eax
c010138a:	8b 04 85 f4 c5 10 c0 	mov    -0x3fef3a0c(,%eax,4),%eax
c0101391:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101395:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101399:	d1 e8                	shr    %eax
c010139b:	0f b7 c0             	movzwl %ax,%eax
c010139e:	0f b7 04 85 f6 c5 10 	movzwl -0x3fef3a0a(,%eax,4),%eax
c01013a5:	c0 
c01013a6:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c01013aa:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01013ae:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01013b5:	00 
c01013b6:	89 04 24             	mov    %eax,(%esp)
c01013b9:	e8 3f fb ff ff       	call   c0100efd <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c01013be:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01013c1:	83 c0 02             	add    $0x2,%eax
c01013c4:	0f b7 c0             	movzwl %ax,%eax
c01013c7:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c01013cb:	c6 45 d5 00          	movb   $0x0,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01013cf:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c01013d3:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c01013d7:	ee                   	out    %al,(%dx)
}
c01013d8:	90                   	nop
    outb(iobase + ISA_SECCNT, nsecs);
c01013d9:	8b 45 14             	mov    0x14(%ebp),%eax
c01013dc:	0f b6 c0             	movzbl %al,%eax
c01013df:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01013e3:	83 c2 02             	add    $0x2,%edx
c01013e6:	0f b7 d2             	movzwl %dx,%edx
c01013e9:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c01013ed:	88 45 d9             	mov    %al,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01013f0:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c01013f4:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c01013f8:	ee                   	out    %al,(%dx)
}
c01013f9:	90                   	nop
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c01013fa:	8b 45 0c             	mov    0xc(%ebp),%eax
c01013fd:	0f b6 c0             	movzbl %al,%eax
c0101400:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101404:	83 c2 03             	add    $0x3,%edx
c0101407:	0f b7 d2             	movzwl %dx,%edx
c010140a:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c010140e:	88 45 dd             	mov    %al,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101411:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101415:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101419:	ee                   	out    %al,(%dx)
}
c010141a:	90                   	nop
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c010141b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010141e:	c1 e8 08             	shr    $0x8,%eax
c0101421:	0f b6 c0             	movzbl %al,%eax
c0101424:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101428:	83 c2 04             	add    $0x4,%edx
c010142b:	0f b7 d2             	movzwl %dx,%edx
c010142e:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0101432:	88 45 e1             	mov    %al,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101435:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101439:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c010143d:	ee                   	out    %al,(%dx)
}
c010143e:	90                   	nop
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c010143f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101442:	c1 e8 10             	shr    $0x10,%eax
c0101445:	0f b6 c0             	movzbl %al,%eax
c0101448:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010144c:	83 c2 05             	add    $0x5,%edx
c010144f:	0f b7 d2             	movzwl %dx,%edx
c0101452:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c0101456:	88 45 e5             	mov    %al,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101459:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c010145d:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101461:	ee                   	out    %al,(%dx)
}
c0101462:	90                   	nop
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c0101463:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0101466:	c0 e0 04             	shl    $0x4,%al
c0101469:	24 10                	and    $0x10,%al
c010146b:	88 c2                	mov    %al,%dl
c010146d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101470:	c1 e8 18             	shr    $0x18,%eax
c0101473:	24 0f                	and    $0xf,%al
c0101475:	08 d0                	or     %dl,%al
c0101477:	0c e0                	or     $0xe0,%al
c0101479:	0f b6 c0             	movzbl %al,%eax
c010147c:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101480:	83 c2 06             	add    $0x6,%edx
c0101483:	0f b7 d2             	movzwl %dx,%edx
c0101486:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c010148a:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010148d:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101491:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101495:	ee                   	out    %al,(%dx)
}
c0101496:	90                   	nop
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);
c0101497:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010149b:	83 c0 07             	add    $0x7,%eax
c010149e:	0f b7 c0             	movzwl %ax,%eax
c01014a1:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c01014a5:	c6 45 ed 20          	movb   $0x20,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01014a9:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01014ad:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01014b1:	ee                   	out    %al,(%dx)
}
c01014b2:	90                   	nop

    int ret = 0;
c01014b3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c01014ba:	eb 58                	jmp    c0101514 <ide_read_secs+0x232>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c01014bc:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01014c0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01014c7:	00 
c01014c8:	89 04 24             	mov    %eax,(%esp)
c01014cb:	e8 2d fa ff ff       	call   c0100efd <ide_wait_ready>
c01014d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01014d3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01014d7:	75 43                	jne    c010151c <ide_read_secs+0x23a>
            goto out;
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
c01014d9:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01014dd:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01014e0:	8b 45 10             	mov    0x10(%ebp),%eax
c01014e3:	89 45 cc             	mov    %eax,-0x34(%ebp)
c01014e6:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    asm volatile (
c01014ed:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01014f0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c01014f3:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01014f6:	89 cb                	mov    %ecx,%ebx
c01014f8:	89 df                	mov    %ebx,%edi
c01014fa:	89 c1                	mov    %eax,%ecx
c01014fc:	fc                   	cld    
c01014fd:	f2 6d                	repnz insl (%dx),%es:(%edi)
c01014ff:	89 c8                	mov    %ecx,%eax
c0101501:	89 fb                	mov    %edi,%ebx
c0101503:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c0101506:	89 45 c8             	mov    %eax,-0x38(%ebp)
}
c0101509:	90                   	nop
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c010150a:	ff 4d 14             	decl   0x14(%ebp)
c010150d:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c0101514:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0101518:	75 a2                	jne    c01014bc <ide_read_secs+0x1da>
    }

out:
c010151a:	eb 01                	jmp    c010151d <ide_read_secs+0x23b>
            goto out;
c010151c:	90                   	nop
    return ret;
c010151d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101520:	83 c4 50             	add    $0x50,%esp
c0101523:	5b                   	pop    %ebx
c0101524:	5f                   	pop    %edi
c0101525:	5d                   	pop    %ebp
c0101526:	c3                   	ret    

c0101527 <ide_write_secs>:

int
ide_write_secs(unsigned short ideno, uint32_t secno, const void *src, size_t nsecs) {
c0101527:	f3 0f 1e fb          	endbr32 
c010152b:	55                   	push   %ebp
c010152c:	89 e5                	mov    %esp,%ebp
c010152e:	56                   	push   %esi
c010152f:	53                   	push   %ebx
c0101530:	83 ec 50             	sub    $0x50,%esp
c0101533:	8b 45 08             	mov    0x8(%ebp),%eax
c0101536:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c010153a:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c0101541:	77 23                	ja     c0101566 <ide_write_secs+0x3f>
c0101543:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101547:	83 f8 03             	cmp    $0x3,%eax
c010154a:	77 1a                	ja     c0101566 <ide_write_secs+0x3f>
c010154c:	0f b7 55 c4          	movzwl -0x3c(%ebp),%edx
c0101550:	89 d0                	mov    %edx,%eax
c0101552:	c1 e0 03             	shl    $0x3,%eax
c0101555:	29 d0                	sub    %edx,%eax
c0101557:	c1 e0 03             	shl    $0x3,%eax
c010155a:	05 40 14 1b c0       	add    $0xc01b1440,%eax
c010155f:	0f b6 00             	movzbl (%eax),%eax
c0101562:	84 c0                	test   %al,%al
c0101564:	75 24                	jne    c010158a <ide_write_secs+0x63>
c0101566:	c7 44 24 0c 84 c6 10 	movl   $0xc010c684,0xc(%esp)
c010156d:	c0 
c010156e:	c7 44 24 08 3f c6 10 	movl   $0xc010c63f,0x8(%esp)
c0101575:	c0 
c0101576:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
c010157d:	00 
c010157e:	c7 04 24 54 c6 10 c0 	movl   $0xc010c654,(%esp)
c0101585:	e8 b3 ee ff ff       	call   c010043d <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c010158a:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101591:	77 0f                	ja     c01015a2 <ide_write_secs+0x7b>
c0101593:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101596:	8b 45 14             	mov    0x14(%ebp),%eax
c0101599:	01 d0                	add    %edx,%eax
c010159b:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c01015a0:	76 24                	jbe    c01015c6 <ide_write_secs+0x9f>
c01015a2:	c7 44 24 0c ac c6 10 	movl   $0xc010c6ac,0xc(%esp)
c01015a9:	c0 
c01015aa:	c7 44 24 08 3f c6 10 	movl   $0xc010c63f,0x8(%esp)
c01015b1:	c0 
c01015b2:	c7 44 24 04 bd 00 00 	movl   $0xbd,0x4(%esp)
c01015b9:	00 
c01015ba:	c7 04 24 54 c6 10 c0 	movl   $0xc010c654,(%esp)
c01015c1:	e8 77 ee ff ff       	call   c010043d <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c01015c6:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c01015ca:	d1 e8                	shr    %eax
c01015cc:	0f b7 c0             	movzwl %ax,%eax
c01015cf:	8b 04 85 f4 c5 10 c0 	mov    -0x3fef3a0c(,%eax,4),%eax
c01015d6:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c01015da:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c01015de:	d1 e8                	shr    %eax
c01015e0:	0f b7 c0             	movzwl %ax,%eax
c01015e3:	0f b7 04 85 f6 c5 10 	movzwl -0x3fef3a0a(,%eax,4),%eax
c01015ea:	c0 
c01015eb:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c01015ef:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01015f3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01015fa:	00 
c01015fb:	89 04 24             	mov    %eax,(%esp)
c01015fe:	e8 fa f8 ff ff       	call   c0100efd <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c0101603:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101606:	83 c0 02             	add    $0x2,%eax
c0101609:	0f b7 c0             	movzwl %ax,%eax
c010160c:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c0101610:	c6 45 d5 00          	movb   $0x0,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101614:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101618:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c010161c:	ee                   	out    %al,(%dx)
}
c010161d:	90                   	nop
    outb(iobase + ISA_SECCNT, nsecs);
c010161e:	8b 45 14             	mov    0x14(%ebp),%eax
c0101621:	0f b6 c0             	movzbl %al,%eax
c0101624:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101628:	83 c2 02             	add    $0x2,%edx
c010162b:	0f b7 d2             	movzwl %dx,%edx
c010162e:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c0101632:	88 45 d9             	mov    %al,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101635:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101639:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c010163d:	ee                   	out    %al,(%dx)
}
c010163e:	90                   	nop
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c010163f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101642:	0f b6 c0             	movzbl %al,%eax
c0101645:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101649:	83 c2 03             	add    $0x3,%edx
c010164c:	0f b7 d2             	movzwl %dx,%edx
c010164f:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c0101653:	88 45 dd             	mov    %al,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101656:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c010165a:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c010165e:	ee                   	out    %al,(%dx)
}
c010165f:	90                   	nop
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c0101660:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101663:	c1 e8 08             	shr    $0x8,%eax
c0101666:	0f b6 c0             	movzbl %al,%eax
c0101669:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010166d:	83 c2 04             	add    $0x4,%edx
c0101670:	0f b7 d2             	movzwl %dx,%edx
c0101673:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0101677:	88 45 e1             	mov    %al,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010167a:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c010167e:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101682:	ee                   	out    %al,(%dx)
}
c0101683:	90                   	nop
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c0101684:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101687:	c1 e8 10             	shr    $0x10,%eax
c010168a:	0f b6 c0             	movzbl %al,%eax
c010168d:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101691:	83 c2 05             	add    $0x5,%edx
c0101694:	0f b7 d2             	movzwl %dx,%edx
c0101697:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c010169b:	88 45 e5             	mov    %al,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010169e:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01016a2:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01016a6:	ee                   	out    %al,(%dx)
}
c01016a7:	90                   	nop
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c01016a8:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01016ab:	c0 e0 04             	shl    $0x4,%al
c01016ae:	24 10                	and    $0x10,%al
c01016b0:	88 c2                	mov    %al,%dl
c01016b2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01016b5:	c1 e8 18             	shr    $0x18,%eax
c01016b8:	24 0f                	and    $0xf,%al
c01016ba:	08 d0                	or     %dl,%al
c01016bc:	0c e0                	or     $0xe0,%al
c01016be:	0f b6 c0             	movzbl %al,%eax
c01016c1:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01016c5:	83 c2 06             	add    $0x6,%edx
c01016c8:	0f b7 d2             	movzwl %dx,%edx
c01016cb:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c01016cf:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01016d2:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01016d6:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01016da:	ee                   	out    %al,(%dx)
}
c01016db:	90                   	nop
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);
c01016dc:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01016e0:	83 c0 07             	add    $0x7,%eax
c01016e3:	0f b7 c0             	movzwl %ax,%eax
c01016e6:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c01016ea:	c6 45 ed 30          	movb   $0x30,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01016ee:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01016f2:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01016f6:	ee                   	out    %al,(%dx)
}
c01016f7:	90                   	nop

    int ret = 0;
c01016f8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c01016ff:	eb 58                	jmp    c0101759 <ide_write_secs+0x232>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c0101701:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101705:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010170c:	00 
c010170d:	89 04 24             	mov    %eax,(%esp)
c0101710:	e8 e8 f7 ff ff       	call   c0100efd <ide_wait_ready>
c0101715:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101718:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010171c:	75 43                	jne    c0101761 <ide_write_secs+0x23a>
            goto out;
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
c010171e:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101722:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0101725:	8b 45 10             	mov    0x10(%ebp),%eax
c0101728:	89 45 cc             	mov    %eax,-0x34(%ebp)
c010172b:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    asm volatile (
c0101732:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0101735:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c0101738:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010173b:	89 cb                	mov    %ecx,%ebx
c010173d:	89 de                	mov    %ebx,%esi
c010173f:	89 c1                	mov    %eax,%ecx
c0101741:	fc                   	cld    
c0101742:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
c0101744:	89 c8                	mov    %ecx,%eax
c0101746:	89 f3                	mov    %esi,%ebx
c0101748:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c010174b:	89 45 c8             	mov    %eax,-0x38(%ebp)
}
c010174e:	90                   	nop
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c010174f:	ff 4d 14             	decl   0x14(%ebp)
c0101752:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c0101759:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c010175d:	75 a2                	jne    c0101701 <ide_write_secs+0x1da>
    }

out:
c010175f:	eb 01                	jmp    c0101762 <ide_write_secs+0x23b>
            goto out;
c0101761:	90                   	nop
    return ret;
c0101762:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101765:	83 c4 50             	add    $0x50,%esp
c0101768:	5b                   	pop    %ebx
c0101769:	5e                   	pop    %esi
c010176a:	5d                   	pop    %ebp
c010176b:	c3                   	ret    

c010176c <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c010176c:	f3 0f 1e fb          	endbr32 
c0101770:	55                   	push   %ebp
c0101771:	89 e5                	mov    %esp,%ebp
c0101773:	83 ec 28             	sub    $0x28,%esp
c0101776:	66 c7 45 ee 43 00    	movw   $0x43,-0x12(%ebp)
c010177c:	c6 45 ed 34          	movb   $0x34,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101780:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101784:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101788:	ee                   	out    %al,(%dx)
}
c0101789:	90                   	nop
c010178a:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0101790:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101794:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101798:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010179c:	ee                   	out    %al,(%dx)
}
c010179d:	90                   	nop
c010179e:	66 c7 45 f6 40 00    	movw   $0x40,-0xa(%ebp)
c01017a4:	c6 45 f5 2e          	movb   $0x2e,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01017a8:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c01017ac:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01017b0:	ee                   	out    %al,(%dx)
}
c01017b1:	90                   	nop
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c01017b2:	c7 05 54 40 1b c0 00 	movl   $0x0,0xc01b4054
c01017b9:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c01017bc:	c7 04 24 e6 c6 10 c0 	movl   $0xc010c6e6,(%esp)
c01017c3:	e8 09 eb ff ff       	call   c01002d1 <cprintf>
    pic_enable(IRQ_TIMER);
c01017c8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01017cf:	e8 95 09 00 00       	call   c0102169 <pic_enable>
}
c01017d4:	90                   	nop
c01017d5:	c9                   	leave  
c01017d6:	c3                   	ret    

c01017d7 <__intr_save>:
#include <assert.h>
#include <atomic.h>
#include <sched.h>

static inline bool
__intr_save(void) {
c01017d7:	55                   	push   %ebp
c01017d8:	89 e5                	mov    %esp,%ebp
c01017da:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c01017dd:	9c                   	pushf  
c01017de:	58                   	pop    %eax
c01017df:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c01017e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c01017e5:	25 00 02 00 00       	and    $0x200,%eax
c01017ea:	85 c0                	test   %eax,%eax
c01017ec:	74 0c                	je     c01017fa <__intr_save+0x23>
        intr_disable();
c01017ee:	e8 05 0b 00 00       	call   c01022f8 <intr_disable>
        return 1;
c01017f3:	b8 01 00 00 00       	mov    $0x1,%eax
c01017f8:	eb 05                	jmp    c01017ff <__intr_save+0x28>
    }
    return 0;
c01017fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01017ff:	c9                   	leave  
c0101800:	c3                   	ret    

c0101801 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0101801:	55                   	push   %ebp
c0101802:	89 e5                	mov    %esp,%ebp
c0101804:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0101807:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010180b:	74 05                	je     c0101812 <__intr_restore+0x11>
        intr_enable();
c010180d:	e8 da 0a 00 00       	call   c01022ec <intr_enable>
    }
}
c0101812:	90                   	nop
c0101813:	c9                   	leave  
c0101814:	c3                   	ret    

c0101815 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0101815:	f3 0f 1e fb          	endbr32 
c0101819:	55                   	push   %ebp
c010181a:	89 e5                	mov    %esp,%ebp
c010181c:	83 ec 10             	sub    $0x10,%esp
c010181f:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101825:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101829:	89 c2                	mov    %eax,%edx
c010182b:	ec                   	in     (%dx),%al
c010182c:	88 45 f1             	mov    %al,-0xf(%ebp)
c010182f:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c0101835:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101839:	89 c2                	mov    %eax,%edx
c010183b:	ec                   	in     (%dx),%al
c010183c:	88 45 f5             	mov    %al,-0xb(%ebp)
c010183f:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0101845:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101849:	89 c2                	mov    %eax,%edx
c010184b:	ec                   	in     (%dx),%al
c010184c:	88 45 f9             	mov    %al,-0x7(%ebp)
c010184f:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
c0101855:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0101859:	89 c2                	mov    %eax,%edx
c010185b:	ec                   	in     (%dx),%al
c010185c:	88 45 fd             	mov    %al,-0x3(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c010185f:	90                   	nop
c0101860:	c9                   	leave  
c0101861:	c3                   	ret    

c0101862 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0101862:	f3 0f 1e fb          	endbr32 
c0101866:	55                   	push   %ebp
c0101867:	89 e5                	mov    %esp,%ebp
c0101869:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c010186c:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0101873:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101876:	0f b7 00             	movzwl (%eax),%eax
c0101879:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c010187d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101880:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0101885:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101888:	0f b7 00             	movzwl (%eax),%eax
c010188b:	0f b7 c0             	movzwl %ax,%eax
c010188e:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
c0101893:	74 12                	je     c01018a7 <cga_init+0x45>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0101895:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c010189c:	66 c7 05 26 15 1b c0 	movw   $0x3b4,0xc01b1526
c01018a3:	b4 03 
c01018a5:	eb 13                	jmp    c01018ba <cga_init+0x58>
    } else {
        *cp = was;
c01018a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018aa:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c01018ae:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c01018b1:	66 c7 05 26 15 1b c0 	movw   $0x3d4,0xc01b1526
c01018b8:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c01018ba:	0f b7 05 26 15 1b c0 	movzwl 0xc01b1526,%eax
c01018c1:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c01018c5:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018c9:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01018cd:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01018d1:	ee                   	out    %al,(%dx)
}
c01018d2:	90                   	nop
    pos = inb(addr_6845 + 1) << 8;
c01018d3:	0f b7 05 26 15 1b c0 	movzwl 0xc01b1526,%eax
c01018da:	40                   	inc    %eax
c01018db:	0f b7 c0             	movzwl %ax,%eax
c01018de:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01018e2:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01018e6:	89 c2                	mov    %eax,%edx
c01018e8:	ec                   	in     (%dx),%al
c01018e9:	88 45 e9             	mov    %al,-0x17(%ebp)
    return data;
c01018ec:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01018f0:	0f b6 c0             	movzbl %al,%eax
c01018f3:	c1 e0 08             	shl    $0x8,%eax
c01018f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c01018f9:	0f b7 05 26 15 1b c0 	movzwl 0xc01b1526,%eax
c0101900:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101904:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101908:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c010190c:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101910:	ee                   	out    %al,(%dx)
}
c0101911:	90                   	nop
    pos |= inb(addr_6845 + 1);
c0101912:	0f b7 05 26 15 1b c0 	movzwl 0xc01b1526,%eax
c0101919:	40                   	inc    %eax
c010191a:	0f b7 c0             	movzwl %ax,%eax
c010191d:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101921:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101925:	89 c2                	mov    %eax,%edx
c0101927:	ec                   	in     (%dx),%al
c0101928:	88 45 f1             	mov    %al,-0xf(%ebp)
    return data;
c010192b:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010192f:	0f b6 c0             	movzbl %al,%eax
c0101932:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c0101935:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101938:	a3 20 15 1b c0       	mov    %eax,0xc01b1520
    crt_pos = pos;
c010193d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101940:	0f b7 c0             	movzwl %ax,%eax
c0101943:	66 a3 24 15 1b c0    	mov    %ax,0xc01b1524
}
c0101949:	90                   	nop
c010194a:	c9                   	leave  
c010194b:	c3                   	ret    

c010194c <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c010194c:	f3 0f 1e fb          	endbr32 
c0101950:	55                   	push   %ebp
c0101951:	89 e5                	mov    %esp,%ebp
c0101953:	83 ec 48             	sub    $0x48,%esp
c0101956:	66 c7 45 d2 fa 03    	movw   $0x3fa,-0x2e(%ebp)
c010195c:	c6 45 d1 00          	movb   $0x0,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101960:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0101964:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c0101968:	ee                   	out    %al,(%dx)
}
c0101969:	90                   	nop
c010196a:	66 c7 45 d6 fb 03    	movw   $0x3fb,-0x2a(%ebp)
c0101970:	c6 45 d5 80          	movb   $0x80,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101974:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101978:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c010197c:	ee                   	out    %al,(%dx)
}
c010197d:	90                   	nop
c010197e:	66 c7 45 da f8 03    	movw   $0x3f8,-0x26(%ebp)
c0101984:	c6 45 d9 0c          	movb   $0xc,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101988:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c010198c:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101990:	ee                   	out    %al,(%dx)
}
c0101991:	90                   	nop
c0101992:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c0101998:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010199c:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c01019a0:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c01019a4:	ee                   	out    %al,(%dx)
}
c01019a5:	90                   	nop
c01019a6:	66 c7 45 e2 fb 03    	movw   $0x3fb,-0x1e(%ebp)
c01019ac:	c6 45 e1 03          	movb   $0x3,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01019b0:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c01019b4:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c01019b8:	ee                   	out    %al,(%dx)
}
c01019b9:	90                   	nop
c01019ba:	66 c7 45 e6 fc 03    	movw   $0x3fc,-0x1a(%ebp)
c01019c0:	c6 45 e5 00          	movb   $0x0,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01019c4:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01019c8:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01019cc:	ee                   	out    %al,(%dx)
}
c01019cd:	90                   	nop
c01019ce:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c01019d4:	c6 45 e9 01          	movb   $0x1,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01019d8:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01019dc:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01019e0:	ee                   	out    %al,(%dx)
}
c01019e1:	90                   	nop
c01019e2:	66 c7 45 ee fd 03    	movw   $0x3fd,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01019e8:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c01019ec:	89 c2                	mov    %eax,%edx
c01019ee:	ec                   	in     (%dx),%al
c01019ef:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c01019f2:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c01019f6:	3c ff                	cmp    $0xff,%al
c01019f8:	0f 95 c0             	setne  %al
c01019fb:	0f b6 c0             	movzbl %al,%eax
c01019fe:	a3 28 15 1b c0       	mov    %eax,0xc01b1528
c0101a03:	66 c7 45 f2 fa 03    	movw   $0x3fa,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101a09:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101a0d:	89 c2                	mov    %eax,%edx
c0101a0f:	ec                   	in     (%dx),%al
c0101a10:	88 45 f1             	mov    %al,-0xf(%ebp)
c0101a13:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c0101a19:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101a1d:	89 c2                	mov    %eax,%edx
c0101a1f:	ec                   	in     (%dx),%al
c0101a20:	88 45 f5             	mov    %al,-0xb(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c0101a23:	a1 28 15 1b c0       	mov    0xc01b1528,%eax
c0101a28:	85 c0                	test   %eax,%eax
c0101a2a:	74 0c                	je     c0101a38 <serial_init+0xec>
        pic_enable(IRQ_COM1);
c0101a2c:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0101a33:	e8 31 07 00 00       	call   c0102169 <pic_enable>
    }
}
c0101a38:	90                   	nop
c0101a39:	c9                   	leave  
c0101a3a:	c3                   	ret    

c0101a3b <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c0101a3b:	f3 0f 1e fb          	endbr32 
c0101a3f:	55                   	push   %ebp
c0101a40:	89 e5                	mov    %esp,%ebp
c0101a42:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0101a45:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101a4c:	eb 08                	jmp    c0101a56 <lpt_putc_sub+0x1b>
        delay();
c0101a4e:	e8 c2 fd ff ff       	call   c0101815 <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0101a53:	ff 45 fc             	incl   -0x4(%ebp)
c0101a56:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c0101a5c:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101a60:	89 c2                	mov    %eax,%edx
c0101a62:	ec                   	in     (%dx),%al
c0101a63:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101a66:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101a6a:	84 c0                	test   %al,%al
c0101a6c:	78 09                	js     c0101a77 <lpt_putc_sub+0x3c>
c0101a6e:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101a75:	7e d7                	jle    c0101a4e <lpt_putc_sub+0x13>
    }
    outb(LPTPORT + 0, c);
c0101a77:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a7a:	0f b6 c0             	movzbl %al,%eax
c0101a7d:	66 c7 45 ee 78 03    	movw   $0x378,-0x12(%ebp)
c0101a83:	88 45 ed             	mov    %al,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101a86:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101a8a:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101a8e:	ee                   	out    %al,(%dx)
}
c0101a8f:	90                   	nop
c0101a90:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c0101a96:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101a9a:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101a9e:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101aa2:	ee                   	out    %al,(%dx)
}
c0101aa3:	90                   	nop
c0101aa4:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
c0101aaa:	c6 45 f5 08          	movb   $0x8,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101aae:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101ab2:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101ab6:	ee                   	out    %al,(%dx)
}
c0101ab7:	90                   	nop
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c0101ab8:	90                   	nop
c0101ab9:	c9                   	leave  
c0101aba:	c3                   	ret    

c0101abb <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c0101abb:	f3 0f 1e fb          	endbr32 
c0101abf:	55                   	push   %ebp
c0101ac0:	89 e5                	mov    %esp,%ebp
c0101ac2:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c0101ac5:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101ac9:	74 0d                	je     c0101ad8 <lpt_putc+0x1d>
        lpt_putc_sub(c);
c0101acb:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ace:	89 04 24             	mov    %eax,(%esp)
c0101ad1:	e8 65 ff ff ff       	call   c0101a3b <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
c0101ad6:	eb 24                	jmp    c0101afc <lpt_putc+0x41>
        lpt_putc_sub('\b');
c0101ad8:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101adf:	e8 57 ff ff ff       	call   c0101a3b <lpt_putc_sub>
        lpt_putc_sub(' ');
c0101ae4:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101aeb:	e8 4b ff ff ff       	call   c0101a3b <lpt_putc_sub>
        lpt_putc_sub('\b');
c0101af0:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101af7:	e8 3f ff ff ff       	call   c0101a3b <lpt_putc_sub>
}
c0101afc:	90                   	nop
c0101afd:	c9                   	leave  
c0101afe:	c3                   	ret    

c0101aff <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c0101aff:	f3 0f 1e fb          	endbr32 
c0101b03:	55                   	push   %ebp
c0101b04:	89 e5                	mov    %esp,%ebp
c0101b06:	53                   	push   %ebx
c0101b07:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c0101b0a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b0d:	25 00 ff ff ff       	and    $0xffffff00,%eax
c0101b12:	85 c0                	test   %eax,%eax
c0101b14:	75 07                	jne    c0101b1d <cga_putc+0x1e>
        c |= 0x0700;
c0101b16:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c0101b1d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b20:	0f b6 c0             	movzbl %al,%eax
c0101b23:	83 f8 0d             	cmp    $0xd,%eax
c0101b26:	74 72                	je     c0101b9a <cga_putc+0x9b>
c0101b28:	83 f8 0d             	cmp    $0xd,%eax
c0101b2b:	0f 8f a3 00 00 00    	jg     c0101bd4 <cga_putc+0xd5>
c0101b31:	83 f8 08             	cmp    $0x8,%eax
c0101b34:	74 0a                	je     c0101b40 <cga_putc+0x41>
c0101b36:	83 f8 0a             	cmp    $0xa,%eax
c0101b39:	74 4c                	je     c0101b87 <cga_putc+0x88>
c0101b3b:	e9 94 00 00 00       	jmp    c0101bd4 <cga_putc+0xd5>
    case '\b':
        if (crt_pos > 0) {
c0101b40:	0f b7 05 24 15 1b c0 	movzwl 0xc01b1524,%eax
c0101b47:	85 c0                	test   %eax,%eax
c0101b49:	0f 84 af 00 00 00    	je     c0101bfe <cga_putc+0xff>
            crt_pos --;
c0101b4f:	0f b7 05 24 15 1b c0 	movzwl 0xc01b1524,%eax
c0101b56:	48                   	dec    %eax
c0101b57:	0f b7 c0             	movzwl %ax,%eax
c0101b5a:	66 a3 24 15 1b c0    	mov    %ax,0xc01b1524
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c0101b60:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b63:	98                   	cwtl   
c0101b64:	25 00 ff ff ff       	and    $0xffffff00,%eax
c0101b69:	98                   	cwtl   
c0101b6a:	83 c8 20             	or     $0x20,%eax
c0101b6d:	98                   	cwtl   
c0101b6e:	8b 15 20 15 1b c0    	mov    0xc01b1520,%edx
c0101b74:	0f b7 0d 24 15 1b c0 	movzwl 0xc01b1524,%ecx
c0101b7b:	01 c9                	add    %ecx,%ecx
c0101b7d:	01 ca                	add    %ecx,%edx
c0101b7f:	0f b7 c0             	movzwl %ax,%eax
c0101b82:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c0101b85:	eb 77                	jmp    c0101bfe <cga_putc+0xff>
    case '\n':
        crt_pos += CRT_COLS;
c0101b87:	0f b7 05 24 15 1b c0 	movzwl 0xc01b1524,%eax
c0101b8e:	83 c0 50             	add    $0x50,%eax
c0101b91:	0f b7 c0             	movzwl %ax,%eax
c0101b94:	66 a3 24 15 1b c0    	mov    %ax,0xc01b1524
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c0101b9a:	0f b7 1d 24 15 1b c0 	movzwl 0xc01b1524,%ebx
c0101ba1:	0f b7 0d 24 15 1b c0 	movzwl 0xc01b1524,%ecx
c0101ba8:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
c0101bad:	89 c8                	mov    %ecx,%eax
c0101baf:	f7 e2                	mul    %edx
c0101bb1:	c1 ea 06             	shr    $0x6,%edx
c0101bb4:	89 d0                	mov    %edx,%eax
c0101bb6:	c1 e0 02             	shl    $0x2,%eax
c0101bb9:	01 d0                	add    %edx,%eax
c0101bbb:	c1 e0 04             	shl    $0x4,%eax
c0101bbe:	29 c1                	sub    %eax,%ecx
c0101bc0:	89 c8                	mov    %ecx,%eax
c0101bc2:	0f b7 c0             	movzwl %ax,%eax
c0101bc5:	29 c3                	sub    %eax,%ebx
c0101bc7:	89 d8                	mov    %ebx,%eax
c0101bc9:	0f b7 c0             	movzwl %ax,%eax
c0101bcc:	66 a3 24 15 1b c0    	mov    %ax,0xc01b1524
        break;
c0101bd2:	eb 2b                	jmp    c0101bff <cga_putc+0x100>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c0101bd4:	8b 0d 20 15 1b c0    	mov    0xc01b1520,%ecx
c0101bda:	0f b7 05 24 15 1b c0 	movzwl 0xc01b1524,%eax
c0101be1:	8d 50 01             	lea    0x1(%eax),%edx
c0101be4:	0f b7 d2             	movzwl %dx,%edx
c0101be7:	66 89 15 24 15 1b c0 	mov    %dx,0xc01b1524
c0101bee:	01 c0                	add    %eax,%eax
c0101bf0:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c0101bf3:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bf6:	0f b7 c0             	movzwl %ax,%eax
c0101bf9:	66 89 02             	mov    %ax,(%edx)
        break;
c0101bfc:	eb 01                	jmp    c0101bff <cga_putc+0x100>
        break;
c0101bfe:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c0101bff:	0f b7 05 24 15 1b c0 	movzwl 0xc01b1524,%eax
c0101c06:	3d cf 07 00 00       	cmp    $0x7cf,%eax
c0101c0b:	76 5d                	jbe    c0101c6a <cga_putc+0x16b>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c0101c0d:	a1 20 15 1b c0       	mov    0xc01b1520,%eax
c0101c12:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c0101c18:	a1 20 15 1b c0       	mov    0xc01b1520,%eax
c0101c1d:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c0101c24:	00 
c0101c25:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101c29:	89 04 24             	mov    %eax,(%esp)
c0101c2c:	e8 bc 9d 00 00       	call   c010b9ed <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101c31:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c0101c38:	eb 14                	jmp    c0101c4e <cga_putc+0x14f>
            crt_buf[i] = 0x0700 | ' ';
c0101c3a:	a1 20 15 1b c0       	mov    0xc01b1520,%eax
c0101c3f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101c42:	01 d2                	add    %edx,%edx
c0101c44:	01 d0                	add    %edx,%eax
c0101c46:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101c4b:	ff 45 f4             	incl   -0xc(%ebp)
c0101c4e:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c0101c55:	7e e3                	jle    c0101c3a <cga_putc+0x13b>
        }
        crt_pos -= CRT_COLS;
c0101c57:	0f b7 05 24 15 1b c0 	movzwl 0xc01b1524,%eax
c0101c5e:	83 e8 50             	sub    $0x50,%eax
c0101c61:	0f b7 c0             	movzwl %ax,%eax
c0101c64:	66 a3 24 15 1b c0    	mov    %ax,0xc01b1524
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c0101c6a:	0f b7 05 26 15 1b c0 	movzwl 0xc01b1526,%eax
c0101c71:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c0101c75:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101c79:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101c7d:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101c81:	ee                   	out    %al,(%dx)
}
c0101c82:	90                   	nop
    outb(addr_6845 + 1, crt_pos >> 8);
c0101c83:	0f b7 05 24 15 1b c0 	movzwl 0xc01b1524,%eax
c0101c8a:	c1 e8 08             	shr    $0x8,%eax
c0101c8d:	0f b7 c0             	movzwl %ax,%eax
c0101c90:	0f b6 c0             	movzbl %al,%eax
c0101c93:	0f b7 15 26 15 1b c0 	movzwl 0xc01b1526,%edx
c0101c9a:	42                   	inc    %edx
c0101c9b:	0f b7 d2             	movzwl %dx,%edx
c0101c9e:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0101ca2:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101ca5:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101ca9:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101cad:	ee                   	out    %al,(%dx)
}
c0101cae:	90                   	nop
    outb(addr_6845, 15);
c0101caf:	0f b7 05 26 15 1b c0 	movzwl 0xc01b1526,%eax
c0101cb6:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101cba:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101cbe:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101cc2:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101cc6:	ee                   	out    %al,(%dx)
}
c0101cc7:	90                   	nop
    outb(addr_6845 + 1, crt_pos);
c0101cc8:	0f b7 05 24 15 1b c0 	movzwl 0xc01b1524,%eax
c0101ccf:	0f b6 c0             	movzbl %al,%eax
c0101cd2:	0f b7 15 26 15 1b c0 	movzwl 0xc01b1526,%edx
c0101cd9:	42                   	inc    %edx
c0101cda:	0f b7 d2             	movzwl %dx,%edx
c0101cdd:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
c0101ce1:	88 45 f1             	mov    %al,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101ce4:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101ce8:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101cec:	ee                   	out    %al,(%dx)
}
c0101ced:	90                   	nop
}
c0101cee:	90                   	nop
c0101cef:	83 c4 34             	add    $0x34,%esp
c0101cf2:	5b                   	pop    %ebx
c0101cf3:	5d                   	pop    %ebp
c0101cf4:	c3                   	ret    

c0101cf5 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c0101cf5:	f3 0f 1e fb          	endbr32 
c0101cf9:	55                   	push   %ebp
c0101cfa:	89 e5                	mov    %esp,%ebp
c0101cfc:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101cff:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101d06:	eb 08                	jmp    c0101d10 <serial_putc_sub+0x1b>
        delay();
c0101d08:	e8 08 fb ff ff       	call   c0101815 <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101d0d:	ff 45 fc             	incl   -0x4(%ebp)
c0101d10:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101d16:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101d1a:	89 c2                	mov    %eax,%edx
c0101d1c:	ec                   	in     (%dx),%al
c0101d1d:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101d20:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101d24:	0f b6 c0             	movzbl %al,%eax
c0101d27:	83 e0 20             	and    $0x20,%eax
c0101d2a:	85 c0                	test   %eax,%eax
c0101d2c:	75 09                	jne    c0101d37 <serial_putc_sub+0x42>
c0101d2e:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101d35:	7e d1                	jle    c0101d08 <serial_putc_sub+0x13>
    }
    outb(COM1 + COM_TX, c);
c0101d37:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d3a:	0f b6 c0             	movzbl %al,%eax
c0101d3d:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c0101d43:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101d46:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101d4a:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101d4e:	ee                   	out    %al,(%dx)
}
c0101d4f:	90                   	nop
}
c0101d50:	90                   	nop
c0101d51:	c9                   	leave  
c0101d52:	c3                   	ret    

c0101d53 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c0101d53:	f3 0f 1e fb          	endbr32 
c0101d57:	55                   	push   %ebp
c0101d58:	89 e5                	mov    %esp,%ebp
c0101d5a:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c0101d5d:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101d61:	74 0d                	je     c0101d70 <serial_putc+0x1d>
        serial_putc_sub(c);
c0101d63:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d66:	89 04 24             	mov    %eax,(%esp)
c0101d69:	e8 87 ff ff ff       	call   c0101cf5 <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
c0101d6e:	eb 24                	jmp    c0101d94 <serial_putc+0x41>
        serial_putc_sub('\b');
c0101d70:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101d77:	e8 79 ff ff ff       	call   c0101cf5 <serial_putc_sub>
        serial_putc_sub(' ');
c0101d7c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101d83:	e8 6d ff ff ff       	call   c0101cf5 <serial_putc_sub>
        serial_putc_sub('\b');
c0101d88:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101d8f:	e8 61 ff ff ff       	call   c0101cf5 <serial_putc_sub>
}
c0101d94:	90                   	nop
c0101d95:	c9                   	leave  
c0101d96:	c3                   	ret    

c0101d97 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c0101d97:	f3 0f 1e fb          	endbr32 
c0101d9b:	55                   	push   %ebp
c0101d9c:	89 e5                	mov    %esp,%ebp
c0101d9e:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c0101da1:	eb 33                	jmp    c0101dd6 <cons_intr+0x3f>
        if (c != 0) {
c0101da3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101da7:	74 2d                	je     c0101dd6 <cons_intr+0x3f>
            cons.buf[cons.wpos ++] = c;
c0101da9:	a1 44 17 1b c0       	mov    0xc01b1744,%eax
c0101dae:	8d 50 01             	lea    0x1(%eax),%edx
c0101db1:	89 15 44 17 1b c0    	mov    %edx,0xc01b1744
c0101db7:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101dba:	88 90 40 15 1b c0    	mov    %dl,-0x3fe4eac0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c0101dc0:	a1 44 17 1b c0       	mov    0xc01b1744,%eax
c0101dc5:	3d 00 02 00 00       	cmp    $0x200,%eax
c0101dca:	75 0a                	jne    c0101dd6 <cons_intr+0x3f>
                cons.wpos = 0;
c0101dcc:	c7 05 44 17 1b c0 00 	movl   $0x0,0xc01b1744
c0101dd3:	00 00 00 
    while ((c = (*proc)()) != -1) {
c0101dd6:	8b 45 08             	mov    0x8(%ebp),%eax
c0101dd9:	ff d0                	call   *%eax
c0101ddb:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101dde:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c0101de2:	75 bf                	jne    c0101da3 <cons_intr+0xc>
            }
        }
    }
}
c0101de4:	90                   	nop
c0101de5:	90                   	nop
c0101de6:	c9                   	leave  
c0101de7:	c3                   	ret    

c0101de8 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c0101de8:	f3 0f 1e fb          	endbr32 
c0101dec:	55                   	push   %ebp
c0101ded:	89 e5                	mov    %esp,%ebp
c0101def:	83 ec 10             	sub    $0x10,%esp
c0101df2:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101df8:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101dfc:	89 c2                	mov    %eax,%edx
c0101dfe:	ec                   	in     (%dx),%al
c0101dff:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101e02:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c0101e06:	0f b6 c0             	movzbl %al,%eax
c0101e09:	83 e0 01             	and    $0x1,%eax
c0101e0c:	85 c0                	test   %eax,%eax
c0101e0e:	75 07                	jne    c0101e17 <serial_proc_data+0x2f>
        return -1;
c0101e10:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101e15:	eb 2a                	jmp    c0101e41 <serial_proc_data+0x59>
c0101e17:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101e1d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101e21:	89 c2                	mov    %eax,%edx
c0101e23:	ec                   	in     (%dx),%al
c0101e24:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c0101e27:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c0101e2b:	0f b6 c0             	movzbl %al,%eax
c0101e2e:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c0101e31:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c0101e35:	75 07                	jne    c0101e3e <serial_proc_data+0x56>
        c = '\b';
c0101e37:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c0101e3e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0101e41:	c9                   	leave  
c0101e42:	c3                   	ret    

c0101e43 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c0101e43:	f3 0f 1e fb          	endbr32 
c0101e47:	55                   	push   %ebp
c0101e48:	89 e5                	mov    %esp,%ebp
c0101e4a:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c0101e4d:	a1 28 15 1b c0       	mov    0xc01b1528,%eax
c0101e52:	85 c0                	test   %eax,%eax
c0101e54:	74 0c                	je     c0101e62 <serial_intr+0x1f>
        cons_intr(serial_proc_data);
c0101e56:	c7 04 24 e8 1d 10 c0 	movl   $0xc0101de8,(%esp)
c0101e5d:	e8 35 ff ff ff       	call   c0101d97 <cons_intr>
    }
}
c0101e62:	90                   	nop
c0101e63:	c9                   	leave  
c0101e64:	c3                   	ret    

c0101e65 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c0101e65:	f3 0f 1e fb          	endbr32 
c0101e69:	55                   	push   %ebp
c0101e6a:	89 e5                	mov    %esp,%ebp
c0101e6c:	83 ec 38             	sub    $0x38,%esp
c0101e6f:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101e75:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101e78:	89 c2                	mov    %eax,%edx
c0101e7a:	ec                   	in     (%dx),%al
c0101e7b:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c0101e7e:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c0101e82:	0f b6 c0             	movzbl %al,%eax
c0101e85:	83 e0 01             	and    $0x1,%eax
c0101e88:	85 c0                	test   %eax,%eax
c0101e8a:	75 0a                	jne    c0101e96 <kbd_proc_data+0x31>
        return -1;
c0101e8c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101e91:	e9 56 01 00 00       	jmp    c0101fec <kbd_proc_data+0x187>
c0101e96:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101e9c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101e9f:	89 c2                	mov    %eax,%edx
c0101ea1:	ec                   	in     (%dx),%al
c0101ea2:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c0101ea5:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c0101ea9:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c0101eac:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c0101eb0:	75 17                	jne    c0101ec9 <kbd_proc_data+0x64>
        // E0 escape character
        shift |= E0ESC;
c0101eb2:	a1 48 17 1b c0       	mov    0xc01b1748,%eax
c0101eb7:	83 c8 40             	or     $0x40,%eax
c0101eba:	a3 48 17 1b c0       	mov    %eax,0xc01b1748
        return 0;
c0101ebf:	b8 00 00 00 00       	mov    $0x0,%eax
c0101ec4:	e9 23 01 00 00       	jmp    c0101fec <kbd_proc_data+0x187>
    } else if (data & 0x80) {
c0101ec9:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101ecd:	84 c0                	test   %al,%al
c0101ecf:	79 45                	jns    c0101f16 <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c0101ed1:	a1 48 17 1b c0       	mov    0xc01b1748,%eax
c0101ed6:	83 e0 40             	and    $0x40,%eax
c0101ed9:	85 c0                	test   %eax,%eax
c0101edb:	75 08                	jne    c0101ee5 <kbd_proc_data+0x80>
c0101edd:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101ee1:	24 7f                	and    $0x7f,%al
c0101ee3:	eb 04                	jmp    c0101ee9 <kbd_proc_data+0x84>
c0101ee5:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101ee9:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c0101eec:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101ef0:	0f b6 80 40 e0 12 c0 	movzbl -0x3fed1fc0(%eax),%eax
c0101ef7:	0c 40                	or     $0x40,%al
c0101ef9:	0f b6 c0             	movzbl %al,%eax
c0101efc:	f7 d0                	not    %eax
c0101efe:	89 c2                	mov    %eax,%edx
c0101f00:	a1 48 17 1b c0       	mov    0xc01b1748,%eax
c0101f05:	21 d0                	and    %edx,%eax
c0101f07:	a3 48 17 1b c0       	mov    %eax,0xc01b1748
        return 0;
c0101f0c:	b8 00 00 00 00       	mov    $0x0,%eax
c0101f11:	e9 d6 00 00 00       	jmp    c0101fec <kbd_proc_data+0x187>
    } else if (shift & E0ESC) {
c0101f16:	a1 48 17 1b c0       	mov    0xc01b1748,%eax
c0101f1b:	83 e0 40             	and    $0x40,%eax
c0101f1e:	85 c0                	test   %eax,%eax
c0101f20:	74 11                	je     c0101f33 <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c0101f22:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c0101f26:	a1 48 17 1b c0       	mov    0xc01b1748,%eax
c0101f2b:	83 e0 bf             	and    $0xffffffbf,%eax
c0101f2e:	a3 48 17 1b c0       	mov    %eax,0xc01b1748
    }

    shift |= shiftcode[data];
c0101f33:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101f37:	0f b6 80 40 e0 12 c0 	movzbl -0x3fed1fc0(%eax),%eax
c0101f3e:	0f b6 d0             	movzbl %al,%edx
c0101f41:	a1 48 17 1b c0       	mov    0xc01b1748,%eax
c0101f46:	09 d0                	or     %edx,%eax
c0101f48:	a3 48 17 1b c0       	mov    %eax,0xc01b1748
    shift ^= togglecode[data];
c0101f4d:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101f51:	0f b6 80 40 e1 12 c0 	movzbl -0x3fed1ec0(%eax),%eax
c0101f58:	0f b6 d0             	movzbl %al,%edx
c0101f5b:	a1 48 17 1b c0       	mov    0xc01b1748,%eax
c0101f60:	31 d0                	xor    %edx,%eax
c0101f62:	a3 48 17 1b c0       	mov    %eax,0xc01b1748

    c = charcode[shift & (CTL | SHIFT)][data];
c0101f67:	a1 48 17 1b c0       	mov    0xc01b1748,%eax
c0101f6c:	83 e0 03             	and    $0x3,%eax
c0101f6f:	8b 14 85 40 e5 12 c0 	mov    -0x3fed1ac0(,%eax,4),%edx
c0101f76:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101f7a:	01 d0                	add    %edx,%eax
c0101f7c:	0f b6 00             	movzbl (%eax),%eax
c0101f7f:	0f b6 c0             	movzbl %al,%eax
c0101f82:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c0101f85:	a1 48 17 1b c0       	mov    0xc01b1748,%eax
c0101f8a:	83 e0 08             	and    $0x8,%eax
c0101f8d:	85 c0                	test   %eax,%eax
c0101f8f:	74 22                	je     c0101fb3 <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
c0101f91:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c0101f95:	7e 0c                	jle    c0101fa3 <kbd_proc_data+0x13e>
c0101f97:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c0101f9b:	7f 06                	jg     c0101fa3 <kbd_proc_data+0x13e>
            c += 'A' - 'a';
c0101f9d:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c0101fa1:	eb 10                	jmp    c0101fb3 <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
c0101fa3:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c0101fa7:	7e 0a                	jle    c0101fb3 <kbd_proc_data+0x14e>
c0101fa9:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c0101fad:	7f 04                	jg     c0101fb3 <kbd_proc_data+0x14e>
            c += 'a' - 'A';
c0101faf:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c0101fb3:	a1 48 17 1b c0       	mov    0xc01b1748,%eax
c0101fb8:	f7 d0                	not    %eax
c0101fba:	83 e0 06             	and    $0x6,%eax
c0101fbd:	85 c0                	test   %eax,%eax
c0101fbf:	75 28                	jne    c0101fe9 <kbd_proc_data+0x184>
c0101fc1:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c0101fc8:	75 1f                	jne    c0101fe9 <kbd_proc_data+0x184>
        cprintf("Rebooting!\n");
c0101fca:	c7 04 24 01 c7 10 c0 	movl   $0xc010c701,(%esp)
c0101fd1:	e8 fb e2 ff ff       	call   c01002d1 <cprintf>
c0101fd6:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c0101fdc:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101fe0:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c0101fe4:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0101fe7:	ee                   	out    %al,(%dx)
}
c0101fe8:	90                   	nop
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c0101fe9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101fec:	c9                   	leave  
c0101fed:	c3                   	ret    

c0101fee <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c0101fee:	f3 0f 1e fb          	endbr32 
c0101ff2:	55                   	push   %ebp
c0101ff3:	89 e5                	mov    %esp,%ebp
c0101ff5:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c0101ff8:	c7 04 24 65 1e 10 c0 	movl   $0xc0101e65,(%esp)
c0101fff:	e8 93 fd ff ff       	call   c0101d97 <cons_intr>
}
c0102004:	90                   	nop
c0102005:	c9                   	leave  
c0102006:	c3                   	ret    

c0102007 <kbd_init>:

static void
kbd_init(void) {
c0102007:	f3 0f 1e fb          	endbr32 
c010200b:	55                   	push   %ebp
c010200c:	89 e5                	mov    %esp,%ebp
c010200e:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c0102011:	e8 d8 ff ff ff       	call   c0101fee <kbd_intr>
    pic_enable(IRQ_KBD);
c0102016:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010201d:	e8 47 01 00 00       	call   c0102169 <pic_enable>
}
c0102022:	90                   	nop
c0102023:	c9                   	leave  
c0102024:	c3                   	ret    

c0102025 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c0102025:	f3 0f 1e fb          	endbr32 
c0102029:	55                   	push   %ebp
c010202a:	89 e5                	mov    %esp,%ebp
c010202c:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c010202f:	e8 2e f8 ff ff       	call   c0101862 <cga_init>
    serial_init();
c0102034:	e8 13 f9 ff ff       	call   c010194c <serial_init>
    kbd_init();
c0102039:	e8 c9 ff ff ff       	call   c0102007 <kbd_init>
    if (!serial_exists) {
c010203e:	a1 28 15 1b c0       	mov    0xc01b1528,%eax
c0102043:	85 c0                	test   %eax,%eax
c0102045:	75 0c                	jne    c0102053 <cons_init+0x2e>
        cprintf("serial port does not exist!!\n");
c0102047:	c7 04 24 0d c7 10 c0 	movl   $0xc010c70d,(%esp)
c010204e:	e8 7e e2 ff ff       	call   c01002d1 <cprintf>
    }
}
c0102053:	90                   	nop
c0102054:	c9                   	leave  
c0102055:	c3                   	ret    

c0102056 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c0102056:	f3 0f 1e fb          	endbr32 
c010205a:	55                   	push   %ebp
c010205b:	89 e5                	mov    %esp,%ebp
c010205d:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0102060:	e8 72 f7 ff ff       	call   c01017d7 <__intr_save>
c0102065:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c0102068:	8b 45 08             	mov    0x8(%ebp),%eax
c010206b:	89 04 24             	mov    %eax,(%esp)
c010206e:	e8 48 fa ff ff       	call   c0101abb <lpt_putc>
        cga_putc(c);
c0102073:	8b 45 08             	mov    0x8(%ebp),%eax
c0102076:	89 04 24             	mov    %eax,(%esp)
c0102079:	e8 81 fa ff ff       	call   c0101aff <cga_putc>
        serial_putc(c);
c010207e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102081:	89 04 24             	mov    %eax,(%esp)
c0102084:	e8 ca fc ff ff       	call   c0101d53 <serial_putc>
    }
    local_intr_restore(intr_flag);
c0102089:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010208c:	89 04 24             	mov    %eax,(%esp)
c010208f:	e8 6d f7 ff ff       	call   c0101801 <__intr_restore>
}
c0102094:	90                   	nop
c0102095:	c9                   	leave  
c0102096:	c3                   	ret    

c0102097 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c0102097:	f3 0f 1e fb          	endbr32 
c010209b:	55                   	push   %ebp
c010209c:	89 e5                	mov    %esp,%ebp
c010209e:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c01020a1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c01020a8:	e8 2a f7 ff ff       	call   c01017d7 <__intr_save>
c01020ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c01020b0:	e8 8e fd ff ff       	call   c0101e43 <serial_intr>
        kbd_intr();
c01020b5:	e8 34 ff ff ff       	call   c0101fee <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c01020ba:	8b 15 40 17 1b c0    	mov    0xc01b1740,%edx
c01020c0:	a1 44 17 1b c0       	mov    0xc01b1744,%eax
c01020c5:	39 c2                	cmp    %eax,%edx
c01020c7:	74 31                	je     c01020fa <cons_getc+0x63>
            c = cons.buf[cons.rpos ++];
c01020c9:	a1 40 17 1b c0       	mov    0xc01b1740,%eax
c01020ce:	8d 50 01             	lea    0x1(%eax),%edx
c01020d1:	89 15 40 17 1b c0    	mov    %edx,0xc01b1740
c01020d7:	0f b6 80 40 15 1b c0 	movzbl -0x3fe4eac0(%eax),%eax
c01020de:	0f b6 c0             	movzbl %al,%eax
c01020e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c01020e4:	a1 40 17 1b c0       	mov    0xc01b1740,%eax
c01020e9:	3d 00 02 00 00       	cmp    $0x200,%eax
c01020ee:	75 0a                	jne    c01020fa <cons_getc+0x63>
                cons.rpos = 0;
c01020f0:	c7 05 40 17 1b c0 00 	movl   $0x0,0xc01b1740
c01020f7:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c01020fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01020fd:	89 04 24             	mov    %eax,(%esp)
c0102100:	e8 fc f6 ff ff       	call   c0101801 <__intr_restore>
    return c;
c0102105:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0102108:	c9                   	leave  
c0102109:	c3                   	ret    

c010210a <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c010210a:	f3 0f 1e fb          	endbr32 
c010210e:	55                   	push   %ebp
c010210f:	89 e5                	mov    %esp,%ebp
c0102111:	83 ec 14             	sub    $0x14,%esp
c0102114:	8b 45 08             	mov    0x8(%ebp),%eax
c0102117:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c010211b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010211e:	66 a3 50 e5 12 c0    	mov    %ax,0xc012e550
    if (did_init) {
c0102124:	a1 4c 17 1b c0       	mov    0xc01b174c,%eax
c0102129:	85 c0                	test   %eax,%eax
c010212b:	74 39                	je     c0102166 <pic_setmask+0x5c>
        outb(IO_PIC1 + 1, mask);
c010212d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102130:	0f b6 c0             	movzbl %al,%eax
c0102133:	66 c7 45 fa 21 00    	movw   $0x21,-0x6(%ebp)
c0102139:	88 45 f9             	mov    %al,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010213c:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0102140:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0102144:	ee                   	out    %al,(%dx)
}
c0102145:	90                   	nop
        outb(IO_PIC2 + 1, mask >> 8);
c0102146:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c010214a:	c1 e8 08             	shr    $0x8,%eax
c010214d:	0f b7 c0             	movzwl %ax,%eax
c0102150:	0f b6 c0             	movzbl %al,%eax
c0102153:	66 c7 45 fe a1 00    	movw   $0xa1,-0x2(%ebp)
c0102159:	88 45 fd             	mov    %al,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010215c:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0102160:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0102164:	ee                   	out    %al,(%dx)
}
c0102165:	90                   	nop
    }
}
c0102166:	90                   	nop
c0102167:	c9                   	leave  
c0102168:	c3                   	ret    

c0102169 <pic_enable>:

void
pic_enable(unsigned int irq) {
c0102169:	f3 0f 1e fb          	endbr32 
c010216d:	55                   	push   %ebp
c010216e:	89 e5                	mov    %esp,%ebp
c0102170:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c0102173:	8b 45 08             	mov    0x8(%ebp),%eax
c0102176:	ba 01 00 00 00       	mov    $0x1,%edx
c010217b:	88 c1                	mov    %al,%cl
c010217d:	d3 e2                	shl    %cl,%edx
c010217f:	89 d0                	mov    %edx,%eax
c0102181:	98                   	cwtl   
c0102182:	f7 d0                	not    %eax
c0102184:	0f bf d0             	movswl %ax,%edx
c0102187:	0f b7 05 50 e5 12 c0 	movzwl 0xc012e550,%eax
c010218e:	98                   	cwtl   
c010218f:	21 d0                	and    %edx,%eax
c0102191:	98                   	cwtl   
c0102192:	0f b7 c0             	movzwl %ax,%eax
c0102195:	89 04 24             	mov    %eax,(%esp)
c0102198:	e8 6d ff ff ff       	call   c010210a <pic_setmask>
}
c010219d:	90                   	nop
c010219e:	c9                   	leave  
c010219f:	c3                   	ret    

c01021a0 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c01021a0:	f3 0f 1e fb          	endbr32 
c01021a4:	55                   	push   %ebp
c01021a5:	89 e5                	mov    %esp,%ebp
c01021a7:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
c01021aa:	c7 05 4c 17 1b c0 01 	movl   $0x1,0xc01b174c
c01021b1:	00 00 00 
c01021b4:	66 c7 45 ca 21 00    	movw   $0x21,-0x36(%ebp)
c01021ba:	c6 45 c9 ff          	movb   $0xff,-0x37(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01021be:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c01021c2:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c01021c6:	ee                   	out    %al,(%dx)
}
c01021c7:	90                   	nop
c01021c8:	66 c7 45 ce a1 00    	movw   $0xa1,-0x32(%ebp)
c01021ce:	c6 45 cd ff          	movb   $0xff,-0x33(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01021d2:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c01021d6:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c01021da:	ee                   	out    %al,(%dx)
}
c01021db:	90                   	nop
c01021dc:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c01021e2:	c6 45 d1 11          	movb   $0x11,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01021e6:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c01021ea:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c01021ee:	ee                   	out    %al,(%dx)
}
c01021ef:	90                   	nop
c01021f0:	66 c7 45 d6 21 00    	movw   $0x21,-0x2a(%ebp)
c01021f6:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01021fa:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c01021fe:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0102202:	ee                   	out    %al,(%dx)
}
c0102203:	90                   	nop
c0102204:	66 c7 45 da 21 00    	movw   $0x21,-0x26(%ebp)
c010220a:	c6 45 d9 04          	movb   $0x4,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010220e:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0102212:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0102216:	ee                   	out    %al,(%dx)
}
c0102217:	90                   	nop
c0102218:	66 c7 45 de 21 00    	movw   $0x21,-0x22(%ebp)
c010221e:	c6 45 dd 03          	movb   $0x3,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102222:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0102226:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c010222a:	ee                   	out    %al,(%dx)
}
c010222b:	90                   	nop
c010222c:	66 c7 45 e2 a0 00    	movw   $0xa0,-0x1e(%ebp)
c0102232:	c6 45 e1 11          	movb   $0x11,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102236:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c010223a:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c010223e:	ee                   	out    %al,(%dx)
}
c010223f:	90                   	nop
c0102240:	66 c7 45 e6 a1 00    	movw   $0xa1,-0x1a(%ebp)
c0102246:	c6 45 e5 28          	movb   $0x28,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010224a:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c010224e:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0102252:	ee                   	out    %al,(%dx)
}
c0102253:	90                   	nop
c0102254:	66 c7 45 ea a1 00    	movw   $0xa1,-0x16(%ebp)
c010225a:	c6 45 e9 02          	movb   $0x2,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010225e:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0102262:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0102266:	ee                   	out    %al,(%dx)
}
c0102267:	90                   	nop
c0102268:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
c010226e:	c6 45 ed 03          	movb   $0x3,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102272:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0102276:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c010227a:	ee                   	out    %al,(%dx)
}
c010227b:	90                   	nop
c010227c:	66 c7 45 f2 20 00    	movw   $0x20,-0xe(%ebp)
c0102282:	c6 45 f1 68          	movb   $0x68,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102286:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010228a:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010228e:	ee                   	out    %al,(%dx)
}
c010228f:	90                   	nop
c0102290:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c0102296:	c6 45 f5 0a          	movb   $0xa,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010229a:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010229e:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01022a2:	ee                   	out    %al,(%dx)
}
c01022a3:	90                   	nop
c01022a4:	66 c7 45 fa a0 00    	movw   $0xa0,-0x6(%ebp)
c01022aa:	c6 45 f9 68          	movb   $0x68,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01022ae:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01022b2:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c01022b6:	ee                   	out    %al,(%dx)
}
c01022b7:	90                   	nop
c01022b8:	66 c7 45 fe a0 00    	movw   $0xa0,-0x2(%ebp)
c01022be:	c6 45 fd 0a          	movb   $0xa,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01022c2:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c01022c6:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c01022ca:	ee                   	out    %al,(%dx)
}
c01022cb:	90                   	nop
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c01022cc:	0f b7 05 50 e5 12 c0 	movzwl 0xc012e550,%eax
c01022d3:	3d ff ff 00 00       	cmp    $0xffff,%eax
c01022d8:	74 0f                	je     c01022e9 <pic_init+0x149>
        pic_setmask(irq_mask);
c01022da:	0f b7 05 50 e5 12 c0 	movzwl 0xc012e550,%eax
c01022e1:	89 04 24             	mov    %eax,(%esp)
c01022e4:	e8 21 fe ff ff       	call   c010210a <pic_setmask>
    }
}
c01022e9:	90                   	nop
c01022ea:	c9                   	leave  
c01022eb:	c3                   	ret    

c01022ec <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c01022ec:	f3 0f 1e fb          	endbr32 
c01022f0:	55                   	push   %ebp
c01022f1:	89 e5                	mov    %esp,%ebp
    asm volatile ("sti");
c01022f3:	fb                   	sti    
}
c01022f4:	90                   	nop
    sti();
}
c01022f5:	90                   	nop
c01022f6:	5d                   	pop    %ebp
c01022f7:	c3                   	ret    

c01022f8 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c01022f8:	f3 0f 1e fb          	endbr32 
c01022fc:	55                   	push   %ebp
c01022fd:	89 e5                	mov    %esp,%ebp
    asm volatile ("cli" ::: "memory");
c01022ff:	fa                   	cli    
}
c0102300:	90                   	nop
    cli();
}
c0102301:	90                   	nop
c0102302:	5d                   	pop    %ebp
c0102303:	c3                   	ret    

c0102304 <print_ticks>:
#include <sync.h>

#define TICK_NUM 100

static void print_ticks()
{
c0102304:	f3 0f 1e fb          	endbr32 
c0102308:	55                   	push   %ebp
c0102309:	89 e5                	mov    %esp,%ebp
c010230b:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n", TICK_NUM);
c010230e:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c0102315:	00 
c0102316:	c7 04 24 40 c7 10 c0 	movl   $0xc010c740,(%esp)
c010231d:	e8 af df ff ff       	call   c01002d1 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
c0102322:	c7 04 24 4a c7 10 c0 	movl   $0xc010c74a,(%esp)
c0102329:	e8 a3 df ff ff       	call   c01002d1 <cprintf>
    panic("EOT: kernel seems ok.");
c010232e:	c7 44 24 08 58 c7 10 	movl   $0xc010c758,0x8(%esp)
c0102335:	c0 
c0102336:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
c010233d:	00 
c010233e:	c7 04 24 6e c7 10 c0 	movl   $0xc010c76e,(%esp)
c0102345:	e8 f3 e0 ff ff       	call   c010043d <__panic>

c010234a <idt_init>:
static struct pseudodesc idt_pd = {
    sizeof(idt) - 1, (uintptr_t)idt};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void idt_init(void)
{
c010234a:	f3 0f 1e fb          	endbr32 
c010234e:	55                   	push   %ebp
c010234f:	89 e5                	mov    %esp,%ebp
c0102351:	83 ec 10             	sub    $0x10,%esp
    /* LAB5 YOUR CODE */
    //you should update your lab1 code (just add ONE or TWO lines of code), let user app to use syscall to get the service of ucore
    //so you should setup the syscall interrupt gate in here
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i++)
c0102354:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c010235b:	e9 c4 00 00 00       	jmp    c0102424 <idt_init+0xda>
    {
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c0102360:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102363:	8b 04 85 e0 e5 12 c0 	mov    -0x3fed1a20(,%eax,4),%eax
c010236a:	0f b7 d0             	movzwl %ax,%edx
c010236d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102370:	66 89 14 c5 60 17 1b 	mov    %dx,-0x3fe4e8a0(,%eax,8)
c0102377:	c0 
c0102378:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010237b:	66 c7 04 c5 62 17 1b 	movw   $0x8,-0x3fe4e89e(,%eax,8)
c0102382:	c0 08 00 
c0102385:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102388:	0f b6 14 c5 64 17 1b 	movzbl -0x3fe4e89c(,%eax,8),%edx
c010238f:	c0 
c0102390:	80 e2 e0             	and    $0xe0,%dl
c0102393:	88 14 c5 64 17 1b c0 	mov    %dl,-0x3fe4e89c(,%eax,8)
c010239a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010239d:	0f b6 14 c5 64 17 1b 	movzbl -0x3fe4e89c(,%eax,8),%edx
c01023a4:	c0 
c01023a5:	80 e2 1f             	and    $0x1f,%dl
c01023a8:	88 14 c5 64 17 1b c0 	mov    %dl,-0x3fe4e89c(,%eax,8)
c01023af:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01023b2:	0f b6 14 c5 65 17 1b 	movzbl -0x3fe4e89b(,%eax,8),%edx
c01023b9:	c0 
c01023ba:	80 e2 f0             	and    $0xf0,%dl
c01023bd:	80 ca 0e             	or     $0xe,%dl
c01023c0:	88 14 c5 65 17 1b c0 	mov    %dl,-0x3fe4e89b(,%eax,8)
c01023c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01023ca:	0f b6 14 c5 65 17 1b 	movzbl -0x3fe4e89b(,%eax,8),%edx
c01023d1:	c0 
c01023d2:	80 e2 ef             	and    $0xef,%dl
c01023d5:	88 14 c5 65 17 1b c0 	mov    %dl,-0x3fe4e89b(,%eax,8)
c01023dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01023df:	0f b6 14 c5 65 17 1b 	movzbl -0x3fe4e89b(,%eax,8),%edx
c01023e6:	c0 
c01023e7:	80 e2 9f             	and    $0x9f,%dl
c01023ea:	88 14 c5 65 17 1b c0 	mov    %dl,-0x3fe4e89b(,%eax,8)
c01023f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01023f4:	0f b6 14 c5 65 17 1b 	movzbl -0x3fe4e89b(,%eax,8),%edx
c01023fb:	c0 
c01023fc:	80 ca 80             	or     $0x80,%dl
c01023ff:	88 14 c5 65 17 1b c0 	mov    %dl,-0x3fe4e89b(,%eax,8)
c0102406:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102409:	8b 04 85 e0 e5 12 c0 	mov    -0x3fed1a20(,%eax,4),%eax
c0102410:	c1 e8 10             	shr    $0x10,%eax
c0102413:	0f b7 d0             	movzwl %ax,%edx
c0102416:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102419:	66 89 14 c5 66 17 1b 	mov    %dx,-0x3fe4e89a(,%eax,8)
c0102420:	c0 
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i++)
c0102421:	ff 45 fc             	incl   -0x4(%ebp)
c0102424:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102427:	3d ff 00 00 00       	cmp    $0xff,%eax
c010242c:	0f 86 2e ff ff ff    	jbe    c0102360 <idt_init+0x16>
    }
    SETGATE(idt[T_SYSCALL], 1, GD_KTEXT, __vectors[T_SYSCALL], DPL_USER);
c0102432:	a1 e0 e7 12 c0       	mov    0xc012e7e0,%eax
c0102437:	0f b7 c0             	movzwl %ax,%eax
c010243a:	66 a3 60 1b 1b c0    	mov    %ax,0xc01b1b60
c0102440:	66 c7 05 62 1b 1b c0 	movw   $0x8,0xc01b1b62
c0102447:	08 00 
c0102449:	0f b6 05 64 1b 1b c0 	movzbl 0xc01b1b64,%eax
c0102450:	24 e0                	and    $0xe0,%al
c0102452:	a2 64 1b 1b c0       	mov    %al,0xc01b1b64
c0102457:	0f b6 05 64 1b 1b c0 	movzbl 0xc01b1b64,%eax
c010245e:	24 1f                	and    $0x1f,%al
c0102460:	a2 64 1b 1b c0       	mov    %al,0xc01b1b64
c0102465:	0f b6 05 65 1b 1b c0 	movzbl 0xc01b1b65,%eax
c010246c:	0c 0f                	or     $0xf,%al
c010246e:	a2 65 1b 1b c0       	mov    %al,0xc01b1b65
c0102473:	0f b6 05 65 1b 1b c0 	movzbl 0xc01b1b65,%eax
c010247a:	24 ef                	and    $0xef,%al
c010247c:	a2 65 1b 1b c0       	mov    %al,0xc01b1b65
c0102481:	0f b6 05 65 1b 1b c0 	movzbl 0xc01b1b65,%eax
c0102488:	0c 60                	or     $0x60,%al
c010248a:	a2 65 1b 1b c0       	mov    %al,0xc01b1b65
c010248f:	0f b6 05 65 1b 1b c0 	movzbl 0xc01b1b65,%eax
c0102496:	0c 80                	or     $0x80,%al
c0102498:	a2 65 1b 1b c0       	mov    %al,0xc01b1b65
c010249d:	a1 e0 e7 12 c0       	mov    0xc012e7e0,%eax
c01024a2:	c1 e8 10             	shr    $0x10,%eax
c01024a5:	0f b7 c0             	movzwl %ax,%eax
c01024a8:	66 a3 66 1b 1b c0    	mov    %ax,0xc01b1b66
c01024ae:	c7 45 f8 60 e5 12 c0 	movl   $0xc012e560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c01024b5:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01024b8:	0f 01 18             	lidtl  (%eax)
}
c01024bb:	90                   	nop
    lidt(&idt_pd);
}
c01024bc:	90                   	nop
c01024bd:	c9                   	leave  
c01024be:	c3                   	ret    

c01024bf <trapname>:

static const char *
trapname(int trapno)
{
c01024bf:	f3 0f 1e fb          	endbr32 
c01024c3:	55                   	push   %ebp
c01024c4:	89 e5                	mov    %esp,%ebp
        "x87 FPU Floating-Point Error",
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"};

    if (trapno < sizeof(excnames) / sizeof(const char *const))
c01024c6:	8b 45 08             	mov    0x8(%ebp),%eax
c01024c9:	83 f8 13             	cmp    $0x13,%eax
c01024cc:	77 0c                	ja     c01024da <trapname+0x1b>
    {
        return excnames[trapno];
c01024ce:	8b 45 08             	mov    0x8(%ebp),%eax
c01024d1:	8b 04 85 80 cc 10 c0 	mov    -0x3fef3380(,%eax,4),%eax
c01024d8:	eb 18                	jmp    c01024f2 <trapname+0x33>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
c01024da:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c01024de:	7e 0d                	jle    c01024ed <trapname+0x2e>
c01024e0:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c01024e4:	7f 07                	jg     c01024ed <trapname+0x2e>
    {
        return "Hardware Interrupt";
c01024e6:	b8 7f c7 10 c0       	mov    $0xc010c77f,%eax
c01024eb:	eb 05                	jmp    c01024f2 <trapname+0x33>
    }
    return "(unknown trap)";
c01024ed:	b8 92 c7 10 c0       	mov    $0xc010c792,%eax
}
c01024f2:	5d                   	pop    %ebp
c01024f3:	c3                   	ret    

c01024f4 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf)
{
c01024f4:	f3 0f 1e fb          	endbr32 
c01024f8:	55                   	push   %ebp
c01024f9:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c01024fb:	8b 45 08             	mov    0x8(%ebp),%eax
c01024fe:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0102502:	83 f8 08             	cmp    $0x8,%eax
c0102505:	0f 94 c0             	sete   %al
c0102508:	0f b6 c0             	movzbl %al,%eax
}
c010250b:	5d                   	pop    %ebp
c010250c:	c3                   	ret    

c010250d <print_trapframe>:
    NULL,
    NULL,
};

void print_trapframe(struct trapframe *tf)
{
c010250d:	f3 0f 1e fb          	endbr32 
c0102511:	55                   	push   %ebp
c0102512:	89 e5                	mov    %esp,%ebp
c0102514:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c0102517:	8b 45 08             	mov    0x8(%ebp),%eax
c010251a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010251e:	c7 04 24 d3 c7 10 c0 	movl   $0xc010c7d3,(%esp)
c0102525:	e8 a7 dd ff ff       	call   c01002d1 <cprintf>
    print_regs(&tf->tf_regs);
c010252a:	8b 45 08             	mov    0x8(%ebp),%eax
c010252d:	89 04 24             	mov    %eax,(%esp)
c0102530:	e8 8d 01 00 00       	call   c01026c2 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c0102535:	8b 45 08             	mov    0x8(%ebp),%eax
c0102538:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c010253c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102540:	c7 04 24 e4 c7 10 c0 	movl   $0xc010c7e4,(%esp)
c0102547:	e8 85 dd ff ff       	call   c01002d1 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c010254c:	8b 45 08             	mov    0x8(%ebp),%eax
c010254f:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0102553:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102557:	c7 04 24 f7 c7 10 c0 	movl   $0xc010c7f7,(%esp)
c010255e:	e8 6e dd ff ff       	call   c01002d1 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0102563:	8b 45 08             	mov    0x8(%ebp),%eax
c0102566:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c010256a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010256e:	c7 04 24 0a c8 10 c0 	movl   $0xc010c80a,(%esp)
c0102575:	e8 57 dd ff ff       	call   c01002d1 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c010257a:	8b 45 08             	mov    0x8(%ebp),%eax
c010257d:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c0102581:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102585:	c7 04 24 1d c8 10 c0 	movl   $0xc010c81d,(%esp)
c010258c:	e8 40 dd ff ff       	call   c01002d1 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c0102591:	8b 45 08             	mov    0x8(%ebp),%eax
c0102594:	8b 40 30             	mov    0x30(%eax),%eax
c0102597:	89 04 24             	mov    %eax,(%esp)
c010259a:	e8 20 ff ff ff       	call   c01024bf <trapname>
c010259f:	8b 55 08             	mov    0x8(%ebp),%edx
c01025a2:	8b 52 30             	mov    0x30(%edx),%edx
c01025a5:	89 44 24 08          	mov    %eax,0x8(%esp)
c01025a9:	89 54 24 04          	mov    %edx,0x4(%esp)
c01025ad:	c7 04 24 30 c8 10 c0 	movl   $0xc010c830,(%esp)
c01025b4:	e8 18 dd ff ff       	call   c01002d1 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c01025b9:	8b 45 08             	mov    0x8(%ebp),%eax
c01025bc:	8b 40 34             	mov    0x34(%eax),%eax
c01025bf:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025c3:	c7 04 24 42 c8 10 c0 	movl   $0xc010c842,(%esp)
c01025ca:	e8 02 dd ff ff       	call   c01002d1 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c01025cf:	8b 45 08             	mov    0x8(%ebp),%eax
c01025d2:	8b 40 38             	mov    0x38(%eax),%eax
c01025d5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025d9:	c7 04 24 51 c8 10 c0 	movl   $0xc010c851,(%esp)
c01025e0:	e8 ec dc ff ff       	call   c01002d1 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c01025e5:	8b 45 08             	mov    0x8(%ebp),%eax
c01025e8:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01025ec:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025f0:	c7 04 24 60 c8 10 c0 	movl   $0xc010c860,(%esp)
c01025f7:	e8 d5 dc ff ff       	call   c01002d1 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c01025fc:	8b 45 08             	mov    0x8(%ebp),%eax
c01025ff:	8b 40 40             	mov    0x40(%eax),%eax
c0102602:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102606:	c7 04 24 73 c8 10 c0 	movl   $0xc010c873,(%esp)
c010260d:	e8 bf dc ff ff       	call   c01002d1 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i++, j <<= 1)
c0102612:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0102619:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c0102620:	eb 3d                	jmp    c010265f <print_trapframe+0x152>
    {
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL)
c0102622:	8b 45 08             	mov    0x8(%ebp),%eax
c0102625:	8b 50 40             	mov    0x40(%eax),%edx
c0102628:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010262b:	21 d0                	and    %edx,%eax
c010262d:	85 c0                	test   %eax,%eax
c010262f:	74 28                	je     c0102659 <print_trapframe+0x14c>
c0102631:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102634:	8b 04 85 80 e5 12 c0 	mov    -0x3fed1a80(,%eax,4),%eax
c010263b:	85 c0                	test   %eax,%eax
c010263d:	74 1a                	je     c0102659 <print_trapframe+0x14c>
        {
            cprintf("%s,", IA32flags[i]);
c010263f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102642:	8b 04 85 80 e5 12 c0 	mov    -0x3fed1a80(,%eax,4),%eax
c0102649:	89 44 24 04          	mov    %eax,0x4(%esp)
c010264d:	c7 04 24 82 c8 10 c0 	movl   $0xc010c882,(%esp)
c0102654:	e8 78 dc ff ff       	call   c01002d1 <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i++, j <<= 1)
c0102659:	ff 45 f4             	incl   -0xc(%ebp)
c010265c:	d1 65 f0             	shll   -0x10(%ebp)
c010265f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102662:	83 f8 17             	cmp    $0x17,%eax
c0102665:	76 bb                	jbe    c0102622 <print_trapframe+0x115>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c0102667:	8b 45 08             	mov    0x8(%ebp),%eax
c010266a:	8b 40 40             	mov    0x40(%eax),%eax
c010266d:	c1 e8 0c             	shr    $0xc,%eax
c0102670:	83 e0 03             	and    $0x3,%eax
c0102673:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102677:	c7 04 24 86 c8 10 c0 	movl   $0xc010c886,(%esp)
c010267e:	e8 4e dc ff ff       	call   c01002d1 <cprintf>

    if (!trap_in_kernel(tf))
c0102683:	8b 45 08             	mov    0x8(%ebp),%eax
c0102686:	89 04 24             	mov    %eax,(%esp)
c0102689:	e8 66 fe ff ff       	call   c01024f4 <trap_in_kernel>
c010268e:	85 c0                	test   %eax,%eax
c0102690:	75 2d                	jne    c01026bf <print_trapframe+0x1b2>
    {
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c0102692:	8b 45 08             	mov    0x8(%ebp),%eax
c0102695:	8b 40 44             	mov    0x44(%eax),%eax
c0102698:	89 44 24 04          	mov    %eax,0x4(%esp)
c010269c:	c7 04 24 8f c8 10 c0 	movl   $0xc010c88f,(%esp)
c01026a3:	e8 29 dc ff ff       	call   c01002d1 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c01026a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01026ab:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c01026af:	89 44 24 04          	mov    %eax,0x4(%esp)
c01026b3:	c7 04 24 9e c8 10 c0 	movl   $0xc010c89e,(%esp)
c01026ba:	e8 12 dc ff ff       	call   c01002d1 <cprintf>
    }
}
c01026bf:	90                   	nop
c01026c0:	c9                   	leave  
c01026c1:	c3                   	ret    

c01026c2 <print_regs>:

void print_regs(struct pushregs *regs)
{
c01026c2:	f3 0f 1e fb          	endbr32 
c01026c6:	55                   	push   %ebp
c01026c7:	89 e5                	mov    %esp,%ebp
c01026c9:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c01026cc:	8b 45 08             	mov    0x8(%ebp),%eax
c01026cf:	8b 00                	mov    (%eax),%eax
c01026d1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01026d5:	c7 04 24 b1 c8 10 c0 	movl   $0xc010c8b1,(%esp)
c01026dc:	e8 f0 db ff ff       	call   c01002d1 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c01026e1:	8b 45 08             	mov    0x8(%ebp),%eax
c01026e4:	8b 40 04             	mov    0x4(%eax),%eax
c01026e7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01026eb:	c7 04 24 c0 c8 10 c0 	movl   $0xc010c8c0,(%esp)
c01026f2:	e8 da db ff ff       	call   c01002d1 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c01026f7:	8b 45 08             	mov    0x8(%ebp),%eax
c01026fa:	8b 40 08             	mov    0x8(%eax),%eax
c01026fd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102701:	c7 04 24 cf c8 10 c0 	movl   $0xc010c8cf,(%esp)
c0102708:	e8 c4 db ff ff       	call   c01002d1 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c010270d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102710:	8b 40 0c             	mov    0xc(%eax),%eax
c0102713:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102717:	c7 04 24 de c8 10 c0 	movl   $0xc010c8de,(%esp)
c010271e:	e8 ae db ff ff       	call   c01002d1 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0102723:	8b 45 08             	mov    0x8(%ebp),%eax
c0102726:	8b 40 10             	mov    0x10(%eax),%eax
c0102729:	89 44 24 04          	mov    %eax,0x4(%esp)
c010272d:	c7 04 24 ed c8 10 c0 	movl   $0xc010c8ed,(%esp)
c0102734:	e8 98 db ff ff       	call   c01002d1 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c0102739:	8b 45 08             	mov    0x8(%ebp),%eax
c010273c:	8b 40 14             	mov    0x14(%eax),%eax
c010273f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102743:	c7 04 24 fc c8 10 c0 	movl   $0xc010c8fc,(%esp)
c010274a:	e8 82 db ff ff       	call   c01002d1 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c010274f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102752:	8b 40 18             	mov    0x18(%eax),%eax
c0102755:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102759:	c7 04 24 0b c9 10 c0 	movl   $0xc010c90b,(%esp)
c0102760:	e8 6c db ff ff       	call   c01002d1 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0102765:	8b 45 08             	mov    0x8(%ebp),%eax
c0102768:	8b 40 1c             	mov    0x1c(%eax),%eax
c010276b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010276f:	c7 04 24 1a c9 10 c0 	movl   $0xc010c91a,(%esp)
c0102776:	e8 56 db ff ff       	call   c01002d1 <cprintf>
}
c010277b:	90                   	nop
c010277c:	c9                   	leave  
c010277d:	c3                   	ret    

c010277e <print_pgfault>:

static inline void
print_pgfault(struct trapframe *tf)
{
c010277e:	55                   	push   %ebp
c010277f:	89 e5                	mov    %esp,%ebp
c0102781:	53                   	push   %ebx
c0102782:	83 ec 34             	sub    $0x34,%esp
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
c0102785:	8b 45 08             	mov    0x8(%ebp),%eax
c0102788:	8b 40 34             	mov    0x34(%eax),%eax
c010278b:	83 e0 01             	and    $0x1,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c010278e:	85 c0                	test   %eax,%eax
c0102790:	74 07                	je     c0102799 <print_pgfault+0x1b>
c0102792:	bb 29 c9 10 c0       	mov    $0xc010c929,%ebx
c0102797:	eb 05                	jmp    c010279e <print_pgfault+0x20>
c0102799:	bb 3a c9 10 c0       	mov    $0xc010c93a,%ebx
            (tf->tf_err & 2) ? 'W' : 'R',
c010279e:	8b 45 08             	mov    0x8(%ebp),%eax
c01027a1:	8b 40 34             	mov    0x34(%eax),%eax
c01027a4:	83 e0 02             	and    $0x2,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c01027a7:	85 c0                	test   %eax,%eax
c01027a9:	74 07                	je     c01027b2 <print_pgfault+0x34>
c01027ab:	b9 57 00 00 00       	mov    $0x57,%ecx
c01027b0:	eb 05                	jmp    c01027b7 <print_pgfault+0x39>
c01027b2:	b9 52 00 00 00       	mov    $0x52,%ecx
            (tf->tf_err & 4) ? 'U' : 'K',
c01027b7:	8b 45 08             	mov    0x8(%ebp),%eax
c01027ba:	8b 40 34             	mov    0x34(%eax),%eax
c01027bd:	83 e0 04             	and    $0x4,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c01027c0:	85 c0                	test   %eax,%eax
c01027c2:	74 07                	je     c01027cb <print_pgfault+0x4d>
c01027c4:	ba 55 00 00 00       	mov    $0x55,%edx
c01027c9:	eb 05                	jmp    c01027d0 <print_pgfault+0x52>
c01027cb:	ba 4b 00 00 00       	mov    $0x4b,%edx
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c01027d0:	0f 20 d0             	mov    %cr2,%eax
c01027d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr2;
c01027d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01027d9:	89 5c 24 10          	mov    %ebx,0x10(%esp)
c01027dd:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01027e1:	89 54 24 08          	mov    %edx,0x8(%esp)
c01027e5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01027e9:	c7 04 24 48 c9 10 c0 	movl   $0xc010c948,(%esp)
c01027f0:	e8 dc da ff ff       	call   c01002d1 <cprintf>
}
c01027f5:	90                   	nop
c01027f6:	83 c4 34             	add    $0x34,%esp
c01027f9:	5b                   	pop    %ebx
c01027fa:	5d                   	pop    %ebp
c01027fb:	c3                   	ret    

c01027fc <pgfault_handler>:

static int
pgfault_handler(struct trapframe *tf)
{
c01027fc:	f3 0f 1e fb          	endbr32 
c0102800:	55                   	push   %ebp
c0102801:	89 e5                	mov    %esp,%ebp
c0102803:	83 ec 28             	sub    $0x28,%esp
    extern struct mm_struct *check_mm_struct;
    if (check_mm_struct != NULL)
c0102806:	a1 64 40 1b c0       	mov    0xc01b4064,%eax
c010280b:	85 c0                	test   %eax,%eax
c010280d:	74 0b                	je     c010281a <pgfault_handler+0x1e>
    { //used for test check_swap
        print_pgfault(tf);
c010280f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102812:	89 04 24             	mov    %eax,(%esp)
c0102815:	e8 64 ff ff ff       	call   c010277e <print_pgfault>
    }
    struct mm_struct *mm;
    if (check_mm_struct != NULL)
c010281a:	a1 64 40 1b c0       	mov    0xc01b4064,%eax
c010281f:	85 c0                	test   %eax,%eax
c0102821:	74 3d                	je     c0102860 <pgfault_handler+0x64>
    {
        assert(current == idleproc);
c0102823:	8b 15 28 20 1b c0    	mov    0xc01b2028,%edx
c0102829:	a1 20 20 1b c0       	mov    0xc01b2020,%eax
c010282e:	39 c2                	cmp    %eax,%edx
c0102830:	74 24                	je     c0102856 <pgfault_handler+0x5a>
c0102832:	c7 44 24 0c 6b c9 10 	movl   $0xc010c96b,0xc(%esp)
c0102839:	c0 
c010283a:	c7 44 24 08 7f c9 10 	movl   $0xc010c97f,0x8(%esp)
c0102841:	c0 
c0102842:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
c0102849:	00 
c010284a:	c7 04 24 6e c7 10 c0 	movl   $0xc010c76e,(%esp)
c0102851:	e8 e7 db ff ff       	call   c010043d <__panic>
        mm = check_mm_struct;
c0102856:	a1 64 40 1b c0       	mov    0xc01b4064,%eax
c010285b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010285e:	eb 46                	jmp    c01028a6 <pgfault_handler+0xaa>
    }
    else
    {
        if (current == NULL)
c0102860:	a1 28 20 1b c0       	mov    0xc01b2028,%eax
c0102865:	85 c0                	test   %eax,%eax
c0102867:	75 32                	jne    c010289b <pgfault_handler+0x9f>
        {
            print_trapframe(tf);
c0102869:	8b 45 08             	mov    0x8(%ebp),%eax
c010286c:	89 04 24             	mov    %eax,(%esp)
c010286f:	e8 99 fc ff ff       	call   c010250d <print_trapframe>
            print_pgfault(tf);
c0102874:	8b 45 08             	mov    0x8(%ebp),%eax
c0102877:	89 04 24             	mov    %eax,(%esp)
c010287a:	e8 ff fe ff ff       	call   c010277e <print_pgfault>
            panic("unhandled page fault.\n");
c010287f:	c7 44 24 08 94 c9 10 	movl   $0xc010c994,0x8(%esp)
c0102886:	c0 
c0102887:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
c010288e:	00 
c010288f:	c7 04 24 6e c7 10 c0 	movl   $0xc010c76e,(%esp)
c0102896:	e8 a2 db ff ff       	call   c010043d <__panic>
        }
        mm = current->mm;
c010289b:	a1 28 20 1b c0       	mov    0xc01b2028,%eax
c01028a0:	8b 40 18             	mov    0x18(%eax),%eax
c01028a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c01028a6:	0f 20 d0             	mov    %cr2,%eax
c01028a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr2;
c01028ac:	8b 55 f0             	mov    -0x10(%ebp),%edx
    }
    return do_pgfault(mm, tf->tf_err, rcr2());
c01028af:	8b 45 08             	mov    0x8(%ebp),%eax
c01028b2:	8b 40 34             	mov    0x34(%eax),%eax
c01028b5:	89 54 24 08          	mov    %edx,0x8(%esp)
c01028b9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01028bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01028c0:	89 04 24             	mov    %eax,(%esp)
c01028c3:	e8 31 3c 00 00       	call   c01064f9 <do_pgfault>
}
c01028c8:	c9                   	leave  
c01028c9:	c3                   	ret    

c01028ca <trap_dispatch>:
static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

static void
trap_dispatch(struct trapframe *tf)
{
c01028ca:	f3 0f 1e fb          	endbr32 
c01028ce:	55                   	push   %ebp
c01028cf:	89 e5                	mov    %esp,%ebp
c01028d1:	83 ec 28             	sub    $0x28,%esp
    char c;

    int ret = 0;
c01028d4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    switch (tf->tf_trapno)
c01028db:	8b 45 08             	mov    0x8(%ebp),%eax
c01028de:	8b 40 30             	mov    0x30(%eax),%eax
c01028e1:	3d 80 00 00 00       	cmp    $0x80,%eax
c01028e6:	0f 84 f0 00 00 00    	je     c01029dc <trap_dispatch+0x112>
c01028ec:	3d 80 00 00 00       	cmp    $0x80,%eax
c01028f1:	0f 87 d4 01 00 00    	ja     c0102acb <trap_dispatch+0x201>
c01028f7:	83 f8 2f             	cmp    $0x2f,%eax
c01028fa:	77 1f                	ja     c010291b <trap_dispatch+0x51>
c01028fc:	83 f8 0e             	cmp    $0xe,%eax
c01028ff:	0f 82 c6 01 00 00    	jb     c0102acb <trap_dispatch+0x201>
c0102905:	83 e8 0e             	sub    $0xe,%eax
c0102908:	83 f8 21             	cmp    $0x21,%eax
c010290b:	0f 87 ba 01 00 00    	ja     c0102acb <trap_dispatch+0x201>
c0102911:	8b 04 85 a8 ca 10 c0 	mov    -0x3fef3558(,%eax,4),%eax
c0102918:	3e ff e0             	notrack jmp *%eax
c010291b:	83 e8 78             	sub    $0x78,%eax
c010291e:	83 f8 01             	cmp    $0x1,%eax
c0102921:	0f 87 a4 01 00 00    	ja     c0102acb <trap_dispatch+0x201>
c0102927:	e9 83 01 00 00       	jmp    c0102aaf <trap_dispatch+0x1e5>
    {
    case T_PGFLT: //page fault
        if ((ret = pgfault_handler(tf)) != 0)
c010292c:	8b 45 08             	mov    0x8(%ebp),%eax
c010292f:	89 04 24             	mov    %eax,(%esp)
c0102932:	e8 c5 fe ff ff       	call   c01027fc <pgfault_handler>
c0102937:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010293a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010293e:	0f 84 d2 01 00 00    	je     c0102b16 <trap_dispatch+0x24c>
        {
            print_trapframe(tf);
c0102944:	8b 45 08             	mov    0x8(%ebp),%eax
c0102947:	89 04 24             	mov    %eax,(%esp)
c010294a:	e8 be fb ff ff       	call   c010250d <print_trapframe>
            if (current == NULL)
c010294f:	a1 28 20 1b c0       	mov    0xc01b2028,%eax
c0102954:	85 c0                	test   %eax,%eax
c0102956:	75 23                	jne    c010297b <trap_dispatch+0xb1>
            {
                panic("handle pgfault failed. ret=%d\n", ret);
c0102958:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010295b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010295f:	c7 44 24 08 ac c9 10 	movl   $0xc010c9ac,0x8(%esp)
c0102966:	c0 
c0102967:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
c010296e:	00 
c010296f:	c7 04 24 6e c7 10 c0 	movl   $0xc010c76e,(%esp)
c0102976:	e8 c2 da ff ff       	call   c010043d <__panic>
            }
            else
            {
                if (trap_in_kernel(tf))
c010297b:	8b 45 08             	mov    0x8(%ebp),%eax
c010297e:	89 04 24             	mov    %eax,(%esp)
c0102981:	e8 6e fb ff ff       	call   c01024f4 <trap_in_kernel>
c0102986:	85 c0                	test   %eax,%eax
c0102988:	74 23                	je     c01029ad <trap_dispatch+0xe3>
                {
                    panic("handle pgfault failed in kernel mode. ret=%d\n", ret);
c010298a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010298d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102991:	c7 44 24 08 cc c9 10 	movl   $0xc010c9cc,0x8(%esp)
c0102998:	c0 
c0102999:	c7 44 24 04 f6 00 00 	movl   $0xf6,0x4(%esp)
c01029a0:	00 
c01029a1:	c7 04 24 6e c7 10 c0 	movl   $0xc010c76e,(%esp)
c01029a8:	e8 90 da ff ff       	call   c010043d <__panic>
                }
                cprintf("killed by kernel.\n");
c01029ad:	c7 04 24 fa c9 10 c0 	movl   $0xc010c9fa,(%esp)
c01029b4:	e8 18 d9 ff ff       	call   c01002d1 <cprintf>
                panic("handle user mode pgfault failed. ret=%d\n", ret);
c01029b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01029bc:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01029c0:	c7 44 24 08 10 ca 10 	movl   $0xc010ca10,0x8(%esp)
c01029c7:	c0 
c01029c8:	c7 44 24 04 f9 00 00 	movl   $0xf9,0x4(%esp)
c01029cf:	00 
c01029d0:	c7 04 24 6e c7 10 c0 	movl   $0xc010c76e,(%esp)
c01029d7:	e8 61 da ff ff       	call   c010043d <__panic>
                do_exit(-E_KILLED);
            }
        }
        break;
    case T_SYSCALL:
        syscall();
c01029dc:	e8 bd 8b 00 00       	call   c010b59e <syscall>
        break;
c01029e1:	e9 34 01 00 00       	jmp    c0102b1a <trap_dispatch+0x250>
         */
        /* LAB5 YOUR CODE */
        /* you should upate you lab1 code (just add ONE or TWO lines of code):
         *    Every TICK_NUM cycle, you should set current process's current->need_resched = 1
         */
        ticks++;
c01029e6:	a1 54 40 1b c0       	mov    0xc01b4054,%eax
c01029eb:	40                   	inc    %eax
c01029ec:	a3 54 40 1b c0       	mov    %eax,0xc01b4054
        if (ticks % TICK_NUM == 0)
c01029f1:	8b 0d 54 40 1b c0    	mov    0xc01b4054,%ecx
c01029f7:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c01029fc:	89 c8                	mov    %ecx,%eax
c01029fe:	f7 e2                	mul    %edx
c0102a00:	c1 ea 05             	shr    $0x5,%edx
c0102a03:	89 d0                	mov    %edx,%eax
c0102a05:	c1 e0 02             	shl    $0x2,%eax
c0102a08:	01 d0                	add    %edx,%eax
c0102a0a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0102a11:	01 d0                	add    %edx,%eax
c0102a13:	c1 e0 02             	shl    $0x2,%eax
c0102a16:	29 c1                	sub    %eax,%ecx
c0102a18:	89 ca                	mov    %ecx,%edx
c0102a1a:	85 d2                	test   %edx,%edx
c0102a1c:	0f 85 f7 00 00 00    	jne    c0102b19 <trap_dispatch+0x24f>
        {
            assert(current != NULL);
c0102a22:	a1 28 20 1b c0       	mov    0xc01b2028,%eax
c0102a27:	85 c0                	test   %eax,%eax
c0102a29:	75 24                	jne    c0102a4f <trap_dispatch+0x185>
c0102a2b:	c7 44 24 0c 39 ca 10 	movl   $0xc010ca39,0xc(%esp)
c0102a32:	c0 
c0102a33:	c7 44 24 08 7f c9 10 	movl   $0xc010c97f,0x8(%esp)
c0102a3a:	c0 
c0102a3b:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
c0102a42:	00 
c0102a43:	c7 04 24 6e c7 10 c0 	movl   $0xc010c76e,(%esp)
c0102a4a:	e8 ee d9 ff ff       	call   c010043d <__panic>
            current->need_resched = 1;
c0102a4f:	a1 28 20 1b c0       	mov    0xc01b2028,%eax
c0102a54:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
        }
        break;
c0102a5b:	e9 b9 00 00 00       	jmp    c0102b19 <trap_dispatch+0x24f>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c0102a60:	e8 32 f6 ff ff       	call   c0102097 <cons_getc>
c0102a65:	88 45 f3             	mov    %al,-0xd(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c0102a68:	0f be 55 f3          	movsbl -0xd(%ebp),%edx
c0102a6c:	0f be 45 f3          	movsbl -0xd(%ebp),%eax
c0102a70:	89 54 24 08          	mov    %edx,0x8(%esp)
c0102a74:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102a78:	c7 04 24 49 ca 10 c0 	movl   $0xc010ca49,(%esp)
c0102a7f:	e8 4d d8 ff ff       	call   c01002d1 <cprintf>
        break;
c0102a84:	e9 91 00 00 00       	jmp    c0102b1a <trap_dispatch+0x250>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c0102a89:	e8 09 f6 ff ff       	call   c0102097 <cons_getc>
c0102a8e:	88 45 f3             	mov    %al,-0xd(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c0102a91:	0f be 55 f3          	movsbl -0xd(%ebp),%edx
c0102a95:	0f be 45 f3          	movsbl -0xd(%ebp),%eax
c0102a99:	89 54 24 08          	mov    %edx,0x8(%esp)
c0102a9d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102aa1:	c7 04 24 5b ca 10 c0 	movl   $0xc010ca5b,(%esp)
c0102aa8:	e8 24 d8 ff ff       	call   c01002d1 <cprintf>
        break;
c0102aad:	eb 6b                	jmp    c0102b1a <trap_dispatch+0x250>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
c0102aaf:	c7 44 24 08 6a ca 10 	movl   $0xc010ca6a,0x8(%esp)
c0102ab6:	c0 
c0102ab7:	c7 44 24 04 22 01 00 	movl   $0x122,0x4(%esp)
c0102abe:	00 
c0102abf:	c7 04 24 6e c7 10 c0 	movl   $0xc010c76e,(%esp)
c0102ac6:	e8 72 d9 ff ff       	call   c010043d <__panic>
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        print_trapframe(tf);
c0102acb:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ace:	89 04 24             	mov    %eax,(%esp)
c0102ad1:	e8 37 fa ff ff       	call   c010250d <print_trapframe>
        if (current != NULL)
c0102ad6:	a1 28 20 1b c0       	mov    0xc01b2028,%eax
c0102adb:	85 c0                	test   %eax,%eax
c0102add:	74 18                	je     c0102af7 <trap_dispatch+0x22d>
        {
            cprintf("unhandled trap.\n");
c0102adf:	c7 04 24 7a ca 10 c0 	movl   $0xc010ca7a,(%esp)
c0102ae6:	e8 e6 d7 ff ff       	call   c01002d1 <cprintf>
            do_exit(-E_KILLED);
c0102aeb:	c7 04 24 f7 ff ff ff 	movl   $0xfffffff7,(%esp)
c0102af2:	e8 ca 77 00 00       	call   c010a2c1 <do_exit>
        }
        // in kernel, it must be a mistake
        panic("unexpected trap in kernel.\n");
c0102af7:	c7 44 24 08 8b ca 10 	movl   $0xc010ca8b,0x8(%esp)
c0102afe:	c0 
c0102aff:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
c0102b06:	00 
c0102b07:	c7 04 24 6e c7 10 c0 	movl   $0xc010c76e,(%esp)
c0102b0e:	e8 2a d9 ff ff       	call   c010043d <__panic>
        break;
c0102b13:	90                   	nop
c0102b14:	eb 04                	jmp    c0102b1a <trap_dispatch+0x250>
        break;
c0102b16:	90                   	nop
c0102b17:	eb 01                	jmp    c0102b1a <trap_dispatch+0x250>
        break;
c0102b19:	90                   	nop
    }
}
c0102b1a:	90                   	nop
c0102b1b:	c9                   	leave  
c0102b1c:	c3                   	ret    

c0102b1d <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf)
{
c0102b1d:	f3 0f 1e fb          	endbr32 
c0102b21:	55                   	push   %ebp
c0102b22:	89 e5                	mov    %esp,%ebp
c0102b24:	83 ec 28             	sub    $0x28,%esp
    // dispatch based on what type of trap occurred
    // used for previous projects
    if (current == NULL)
c0102b27:	a1 28 20 1b c0       	mov    0xc01b2028,%eax
c0102b2c:	85 c0                	test   %eax,%eax
c0102b2e:	75 0d                	jne    c0102b3d <trap+0x20>
    {
        trap_dispatch(tf);
c0102b30:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b33:	89 04 24             	mov    %eax,(%esp)
c0102b36:	e8 8f fd ff ff       	call   c01028ca <trap_dispatch>
            {
                schedule();
            }
        }
    }
}
c0102b3b:	eb 6c                	jmp    c0102ba9 <trap+0x8c>
        struct trapframe *otf = current->tf;
c0102b3d:	a1 28 20 1b c0       	mov    0xc01b2028,%eax
c0102b42:	8b 40 3c             	mov    0x3c(%eax),%eax
c0102b45:	89 45 f4             	mov    %eax,-0xc(%ebp)
        current->tf = tf;
c0102b48:	a1 28 20 1b c0       	mov    0xc01b2028,%eax
c0102b4d:	8b 55 08             	mov    0x8(%ebp),%edx
c0102b50:	89 50 3c             	mov    %edx,0x3c(%eax)
        bool in_kernel = trap_in_kernel(tf);
c0102b53:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b56:	89 04 24             	mov    %eax,(%esp)
c0102b59:	e8 96 f9 ff ff       	call   c01024f4 <trap_in_kernel>
c0102b5e:	89 45 f0             	mov    %eax,-0x10(%ebp)
        trap_dispatch(tf);
c0102b61:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b64:	89 04 24             	mov    %eax,(%esp)
c0102b67:	e8 5e fd ff ff       	call   c01028ca <trap_dispatch>
        current->tf = otf;
c0102b6c:	a1 28 20 1b c0       	mov    0xc01b2028,%eax
c0102b71:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0102b74:	89 50 3c             	mov    %edx,0x3c(%eax)
        if (!in_kernel)
c0102b77:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0102b7b:	75 2c                	jne    c0102ba9 <trap+0x8c>
            if (current->flags & PF_EXITING)
c0102b7d:	a1 28 20 1b c0       	mov    0xc01b2028,%eax
c0102b82:	8b 40 44             	mov    0x44(%eax),%eax
c0102b85:	83 e0 01             	and    $0x1,%eax
c0102b88:	85 c0                	test   %eax,%eax
c0102b8a:	74 0c                	je     c0102b98 <trap+0x7b>
                do_exit(-E_KILLED);
c0102b8c:	c7 04 24 f7 ff ff ff 	movl   $0xfffffff7,(%esp)
c0102b93:	e8 29 77 00 00       	call   c010a2c1 <do_exit>
            if (current->need_resched)
c0102b98:	a1 28 20 1b c0       	mov    0xc01b2028,%eax
c0102b9d:	8b 40 10             	mov    0x10(%eax),%eax
c0102ba0:	85 c0                	test   %eax,%eax
c0102ba2:	74 05                	je     c0102ba9 <trap+0x8c>
                schedule();
c0102ba4:	e8 cf 87 00 00       	call   c010b378 <schedule>
}
c0102ba9:	90                   	nop
c0102baa:	c9                   	leave  
c0102bab:	c3                   	ret    

c0102bac <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0102bac:	6a 00                	push   $0x0
  pushl $0
c0102bae:	6a 00                	push   $0x0
  jmp __alltraps
c0102bb0:	e9 69 0a 00 00       	jmp    c010361e <__alltraps>

c0102bb5 <vector1>:
.globl vector1
vector1:
  pushl $0
c0102bb5:	6a 00                	push   $0x0
  pushl $1
c0102bb7:	6a 01                	push   $0x1
  jmp __alltraps
c0102bb9:	e9 60 0a 00 00       	jmp    c010361e <__alltraps>

c0102bbe <vector2>:
.globl vector2
vector2:
  pushl $0
c0102bbe:	6a 00                	push   $0x0
  pushl $2
c0102bc0:	6a 02                	push   $0x2
  jmp __alltraps
c0102bc2:	e9 57 0a 00 00       	jmp    c010361e <__alltraps>

c0102bc7 <vector3>:
.globl vector3
vector3:
  pushl $0
c0102bc7:	6a 00                	push   $0x0
  pushl $3
c0102bc9:	6a 03                	push   $0x3
  jmp __alltraps
c0102bcb:	e9 4e 0a 00 00       	jmp    c010361e <__alltraps>

c0102bd0 <vector4>:
.globl vector4
vector4:
  pushl $0
c0102bd0:	6a 00                	push   $0x0
  pushl $4
c0102bd2:	6a 04                	push   $0x4
  jmp __alltraps
c0102bd4:	e9 45 0a 00 00       	jmp    c010361e <__alltraps>

c0102bd9 <vector5>:
.globl vector5
vector5:
  pushl $0
c0102bd9:	6a 00                	push   $0x0
  pushl $5
c0102bdb:	6a 05                	push   $0x5
  jmp __alltraps
c0102bdd:	e9 3c 0a 00 00       	jmp    c010361e <__alltraps>

c0102be2 <vector6>:
.globl vector6
vector6:
  pushl $0
c0102be2:	6a 00                	push   $0x0
  pushl $6
c0102be4:	6a 06                	push   $0x6
  jmp __alltraps
c0102be6:	e9 33 0a 00 00       	jmp    c010361e <__alltraps>

c0102beb <vector7>:
.globl vector7
vector7:
  pushl $0
c0102beb:	6a 00                	push   $0x0
  pushl $7
c0102bed:	6a 07                	push   $0x7
  jmp __alltraps
c0102bef:	e9 2a 0a 00 00       	jmp    c010361e <__alltraps>

c0102bf4 <vector8>:
.globl vector8
vector8:
  pushl $8
c0102bf4:	6a 08                	push   $0x8
  jmp __alltraps
c0102bf6:	e9 23 0a 00 00       	jmp    c010361e <__alltraps>

c0102bfb <vector9>:
.globl vector9
vector9:
  pushl $0
c0102bfb:	6a 00                	push   $0x0
  pushl $9
c0102bfd:	6a 09                	push   $0x9
  jmp __alltraps
c0102bff:	e9 1a 0a 00 00       	jmp    c010361e <__alltraps>

c0102c04 <vector10>:
.globl vector10
vector10:
  pushl $10
c0102c04:	6a 0a                	push   $0xa
  jmp __alltraps
c0102c06:	e9 13 0a 00 00       	jmp    c010361e <__alltraps>

c0102c0b <vector11>:
.globl vector11
vector11:
  pushl $11
c0102c0b:	6a 0b                	push   $0xb
  jmp __alltraps
c0102c0d:	e9 0c 0a 00 00       	jmp    c010361e <__alltraps>

c0102c12 <vector12>:
.globl vector12
vector12:
  pushl $12
c0102c12:	6a 0c                	push   $0xc
  jmp __alltraps
c0102c14:	e9 05 0a 00 00       	jmp    c010361e <__alltraps>

c0102c19 <vector13>:
.globl vector13
vector13:
  pushl $13
c0102c19:	6a 0d                	push   $0xd
  jmp __alltraps
c0102c1b:	e9 fe 09 00 00       	jmp    c010361e <__alltraps>

c0102c20 <vector14>:
.globl vector14
vector14:
  pushl $14
c0102c20:	6a 0e                	push   $0xe
  jmp __alltraps
c0102c22:	e9 f7 09 00 00       	jmp    c010361e <__alltraps>

c0102c27 <vector15>:
.globl vector15
vector15:
  pushl $0
c0102c27:	6a 00                	push   $0x0
  pushl $15
c0102c29:	6a 0f                	push   $0xf
  jmp __alltraps
c0102c2b:	e9 ee 09 00 00       	jmp    c010361e <__alltraps>

c0102c30 <vector16>:
.globl vector16
vector16:
  pushl $0
c0102c30:	6a 00                	push   $0x0
  pushl $16
c0102c32:	6a 10                	push   $0x10
  jmp __alltraps
c0102c34:	e9 e5 09 00 00       	jmp    c010361e <__alltraps>

c0102c39 <vector17>:
.globl vector17
vector17:
  pushl $17
c0102c39:	6a 11                	push   $0x11
  jmp __alltraps
c0102c3b:	e9 de 09 00 00       	jmp    c010361e <__alltraps>

c0102c40 <vector18>:
.globl vector18
vector18:
  pushl $0
c0102c40:	6a 00                	push   $0x0
  pushl $18
c0102c42:	6a 12                	push   $0x12
  jmp __alltraps
c0102c44:	e9 d5 09 00 00       	jmp    c010361e <__alltraps>

c0102c49 <vector19>:
.globl vector19
vector19:
  pushl $0
c0102c49:	6a 00                	push   $0x0
  pushl $19
c0102c4b:	6a 13                	push   $0x13
  jmp __alltraps
c0102c4d:	e9 cc 09 00 00       	jmp    c010361e <__alltraps>

c0102c52 <vector20>:
.globl vector20
vector20:
  pushl $0
c0102c52:	6a 00                	push   $0x0
  pushl $20
c0102c54:	6a 14                	push   $0x14
  jmp __alltraps
c0102c56:	e9 c3 09 00 00       	jmp    c010361e <__alltraps>

c0102c5b <vector21>:
.globl vector21
vector21:
  pushl $0
c0102c5b:	6a 00                	push   $0x0
  pushl $21
c0102c5d:	6a 15                	push   $0x15
  jmp __alltraps
c0102c5f:	e9 ba 09 00 00       	jmp    c010361e <__alltraps>

c0102c64 <vector22>:
.globl vector22
vector22:
  pushl $0
c0102c64:	6a 00                	push   $0x0
  pushl $22
c0102c66:	6a 16                	push   $0x16
  jmp __alltraps
c0102c68:	e9 b1 09 00 00       	jmp    c010361e <__alltraps>

c0102c6d <vector23>:
.globl vector23
vector23:
  pushl $0
c0102c6d:	6a 00                	push   $0x0
  pushl $23
c0102c6f:	6a 17                	push   $0x17
  jmp __alltraps
c0102c71:	e9 a8 09 00 00       	jmp    c010361e <__alltraps>

c0102c76 <vector24>:
.globl vector24
vector24:
  pushl $0
c0102c76:	6a 00                	push   $0x0
  pushl $24
c0102c78:	6a 18                	push   $0x18
  jmp __alltraps
c0102c7a:	e9 9f 09 00 00       	jmp    c010361e <__alltraps>

c0102c7f <vector25>:
.globl vector25
vector25:
  pushl $0
c0102c7f:	6a 00                	push   $0x0
  pushl $25
c0102c81:	6a 19                	push   $0x19
  jmp __alltraps
c0102c83:	e9 96 09 00 00       	jmp    c010361e <__alltraps>

c0102c88 <vector26>:
.globl vector26
vector26:
  pushl $0
c0102c88:	6a 00                	push   $0x0
  pushl $26
c0102c8a:	6a 1a                	push   $0x1a
  jmp __alltraps
c0102c8c:	e9 8d 09 00 00       	jmp    c010361e <__alltraps>

c0102c91 <vector27>:
.globl vector27
vector27:
  pushl $0
c0102c91:	6a 00                	push   $0x0
  pushl $27
c0102c93:	6a 1b                	push   $0x1b
  jmp __alltraps
c0102c95:	e9 84 09 00 00       	jmp    c010361e <__alltraps>

c0102c9a <vector28>:
.globl vector28
vector28:
  pushl $0
c0102c9a:	6a 00                	push   $0x0
  pushl $28
c0102c9c:	6a 1c                	push   $0x1c
  jmp __alltraps
c0102c9e:	e9 7b 09 00 00       	jmp    c010361e <__alltraps>

c0102ca3 <vector29>:
.globl vector29
vector29:
  pushl $0
c0102ca3:	6a 00                	push   $0x0
  pushl $29
c0102ca5:	6a 1d                	push   $0x1d
  jmp __alltraps
c0102ca7:	e9 72 09 00 00       	jmp    c010361e <__alltraps>

c0102cac <vector30>:
.globl vector30
vector30:
  pushl $0
c0102cac:	6a 00                	push   $0x0
  pushl $30
c0102cae:	6a 1e                	push   $0x1e
  jmp __alltraps
c0102cb0:	e9 69 09 00 00       	jmp    c010361e <__alltraps>

c0102cb5 <vector31>:
.globl vector31
vector31:
  pushl $0
c0102cb5:	6a 00                	push   $0x0
  pushl $31
c0102cb7:	6a 1f                	push   $0x1f
  jmp __alltraps
c0102cb9:	e9 60 09 00 00       	jmp    c010361e <__alltraps>

c0102cbe <vector32>:
.globl vector32
vector32:
  pushl $0
c0102cbe:	6a 00                	push   $0x0
  pushl $32
c0102cc0:	6a 20                	push   $0x20
  jmp __alltraps
c0102cc2:	e9 57 09 00 00       	jmp    c010361e <__alltraps>

c0102cc7 <vector33>:
.globl vector33
vector33:
  pushl $0
c0102cc7:	6a 00                	push   $0x0
  pushl $33
c0102cc9:	6a 21                	push   $0x21
  jmp __alltraps
c0102ccb:	e9 4e 09 00 00       	jmp    c010361e <__alltraps>

c0102cd0 <vector34>:
.globl vector34
vector34:
  pushl $0
c0102cd0:	6a 00                	push   $0x0
  pushl $34
c0102cd2:	6a 22                	push   $0x22
  jmp __alltraps
c0102cd4:	e9 45 09 00 00       	jmp    c010361e <__alltraps>

c0102cd9 <vector35>:
.globl vector35
vector35:
  pushl $0
c0102cd9:	6a 00                	push   $0x0
  pushl $35
c0102cdb:	6a 23                	push   $0x23
  jmp __alltraps
c0102cdd:	e9 3c 09 00 00       	jmp    c010361e <__alltraps>

c0102ce2 <vector36>:
.globl vector36
vector36:
  pushl $0
c0102ce2:	6a 00                	push   $0x0
  pushl $36
c0102ce4:	6a 24                	push   $0x24
  jmp __alltraps
c0102ce6:	e9 33 09 00 00       	jmp    c010361e <__alltraps>

c0102ceb <vector37>:
.globl vector37
vector37:
  pushl $0
c0102ceb:	6a 00                	push   $0x0
  pushl $37
c0102ced:	6a 25                	push   $0x25
  jmp __alltraps
c0102cef:	e9 2a 09 00 00       	jmp    c010361e <__alltraps>

c0102cf4 <vector38>:
.globl vector38
vector38:
  pushl $0
c0102cf4:	6a 00                	push   $0x0
  pushl $38
c0102cf6:	6a 26                	push   $0x26
  jmp __alltraps
c0102cf8:	e9 21 09 00 00       	jmp    c010361e <__alltraps>

c0102cfd <vector39>:
.globl vector39
vector39:
  pushl $0
c0102cfd:	6a 00                	push   $0x0
  pushl $39
c0102cff:	6a 27                	push   $0x27
  jmp __alltraps
c0102d01:	e9 18 09 00 00       	jmp    c010361e <__alltraps>

c0102d06 <vector40>:
.globl vector40
vector40:
  pushl $0
c0102d06:	6a 00                	push   $0x0
  pushl $40
c0102d08:	6a 28                	push   $0x28
  jmp __alltraps
c0102d0a:	e9 0f 09 00 00       	jmp    c010361e <__alltraps>

c0102d0f <vector41>:
.globl vector41
vector41:
  pushl $0
c0102d0f:	6a 00                	push   $0x0
  pushl $41
c0102d11:	6a 29                	push   $0x29
  jmp __alltraps
c0102d13:	e9 06 09 00 00       	jmp    c010361e <__alltraps>

c0102d18 <vector42>:
.globl vector42
vector42:
  pushl $0
c0102d18:	6a 00                	push   $0x0
  pushl $42
c0102d1a:	6a 2a                	push   $0x2a
  jmp __alltraps
c0102d1c:	e9 fd 08 00 00       	jmp    c010361e <__alltraps>

c0102d21 <vector43>:
.globl vector43
vector43:
  pushl $0
c0102d21:	6a 00                	push   $0x0
  pushl $43
c0102d23:	6a 2b                	push   $0x2b
  jmp __alltraps
c0102d25:	e9 f4 08 00 00       	jmp    c010361e <__alltraps>

c0102d2a <vector44>:
.globl vector44
vector44:
  pushl $0
c0102d2a:	6a 00                	push   $0x0
  pushl $44
c0102d2c:	6a 2c                	push   $0x2c
  jmp __alltraps
c0102d2e:	e9 eb 08 00 00       	jmp    c010361e <__alltraps>

c0102d33 <vector45>:
.globl vector45
vector45:
  pushl $0
c0102d33:	6a 00                	push   $0x0
  pushl $45
c0102d35:	6a 2d                	push   $0x2d
  jmp __alltraps
c0102d37:	e9 e2 08 00 00       	jmp    c010361e <__alltraps>

c0102d3c <vector46>:
.globl vector46
vector46:
  pushl $0
c0102d3c:	6a 00                	push   $0x0
  pushl $46
c0102d3e:	6a 2e                	push   $0x2e
  jmp __alltraps
c0102d40:	e9 d9 08 00 00       	jmp    c010361e <__alltraps>

c0102d45 <vector47>:
.globl vector47
vector47:
  pushl $0
c0102d45:	6a 00                	push   $0x0
  pushl $47
c0102d47:	6a 2f                	push   $0x2f
  jmp __alltraps
c0102d49:	e9 d0 08 00 00       	jmp    c010361e <__alltraps>

c0102d4e <vector48>:
.globl vector48
vector48:
  pushl $0
c0102d4e:	6a 00                	push   $0x0
  pushl $48
c0102d50:	6a 30                	push   $0x30
  jmp __alltraps
c0102d52:	e9 c7 08 00 00       	jmp    c010361e <__alltraps>

c0102d57 <vector49>:
.globl vector49
vector49:
  pushl $0
c0102d57:	6a 00                	push   $0x0
  pushl $49
c0102d59:	6a 31                	push   $0x31
  jmp __alltraps
c0102d5b:	e9 be 08 00 00       	jmp    c010361e <__alltraps>

c0102d60 <vector50>:
.globl vector50
vector50:
  pushl $0
c0102d60:	6a 00                	push   $0x0
  pushl $50
c0102d62:	6a 32                	push   $0x32
  jmp __alltraps
c0102d64:	e9 b5 08 00 00       	jmp    c010361e <__alltraps>

c0102d69 <vector51>:
.globl vector51
vector51:
  pushl $0
c0102d69:	6a 00                	push   $0x0
  pushl $51
c0102d6b:	6a 33                	push   $0x33
  jmp __alltraps
c0102d6d:	e9 ac 08 00 00       	jmp    c010361e <__alltraps>

c0102d72 <vector52>:
.globl vector52
vector52:
  pushl $0
c0102d72:	6a 00                	push   $0x0
  pushl $52
c0102d74:	6a 34                	push   $0x34
  jmp __alltraps
c0102d76:	e9 a3 08 00 00       	jmp    c010361e <__alltraps>

c0102d7b <vector53>:
.globl vector53
vector53:
  pushl $0
c0102d7b:	6a 00                	push   $0x0
  pushl $53
c0102d7d:	6a 35                	push   $0x35
  jmp __alltraps
c0102d7f:	e9 9a 08 00 00       	jmp    c010361e <__alltraps>

c0102d84 <vector54>:
.globl vector54
vector54:
  pushl $0
c0102d84:	6a 00                	push   $0x0
  pushl $54
c0102d86:	6a 36                	push   $0x36
  jmp __alltraps
c0102d88:	e9 91 08 00 00       	jmp    c010361e <__alltraps>

c0102d8d <vector55>:
.globl vector55
vector55:
  pushl $0
c0102d8d:	6a 00                	push   $0x0
  pushl $55
c0102d8f:	6a 37                	push   $0x37
  jmp __alltraps
c0102d91:	e9 88 08 00 00       	jmp    c010361e <__alltraps>

c0102d96 <vector56>:
.globl vector56
vector56:
  pushl $0
c0102d96:	6a 00                	push   $0x0
  pushl $56
c0102d98:	6a 38                	push   $0x38
  jmp __alltraps
c0102d9a:	e9 7f 08 00 00       	jmp    c010361e <__alltraps>

c0102d9f <vector57>:
.globl vector57
vector57:
  pushl $0
c0102d9f:	6a 00                	push   $0x0
  pushl $57
c0102da1:	6a 39                	push   $0x39
  jmp __alltraps
c0102da3:	e9 76 08 00 00       	jmp    c010361e <__alltraps>

c0102da8 <vector58>:
.globl vector58
vector58:
  pushl $0
c0102da8:	6a 00                	push   $0x0
  pushl $58
c0102daa:	6a 3a                	push   $0x3a
  jmp __alltraps
c0102dac:	e9 6d 08 00 00       	jmp    c010361e <__alltraps>

c0102db1 <vector59>:
.globl vector59
vector59:
  pushl $0
c0102db1:	6a 00                	push   $0x0
  pushl $59
c0102db3:	6a 3b                	push   $0x3b
  jmp __alltraps
c0102db5:	e9 64 08 00 00       	jmp    c010361e <__alltraps>

c0102dba <vector60>:
.globl vector60
vector60:
  pushl $0
c0102dba:	6a 00                	push   $0x0
  pushl $60
c0102dbc:	6a 3c                	push   $0x3c
  jmp __alltraps
c0102dbe:	e9 5b 08 00 00       	jmp    c010361e <__alltraps>

c0102dc3 <vector61>:
.globl vector61
vector61:
  pushl $0
c0102dc3:	6a 00                	push   $0x0
  pushl $61
c0102dc5:	6a 3d                	push   $0x3d
  jmp __alltraps
c0102dc7:	e9 52 08 00 00       	jmp    c010361e <__alltraps>

c0102dcc <vector62>:
.globl vector62
vector62:
  pushl $0
c0102dcc:	6a 00                	push   $0x0
  pushl $62
c0102dce:	6a 3e                	push   $0x3e
  jmp __alltraps
c0102dd0:	e9 49 08 00 00       	jmp    c010361e <__alltraps>

c0102dd5 <vector63>:
.globl vector63
vector63:
  pushl $0
c0102dd5:	6a 00                	push   $0x0
  pushl $63
c0102dd7:	6a 3f                	push   $0x3f
  jmp __alltraps
c0102dd9:	e9 40 08 00 00       	jmp    c010361e <__alltraps>

c0102dde <vector64>:
.globl vector64
vector64:
  pushl $0
c0102dde:	6a 00                	push   $0x0
  pushl $64
c0102de0:	6a 40                	push   $0x40
  jmp __alltraps
c0102de2:	e9 37 08 00 00       	jmp    c010361e <__alltraps>

c0102de7 <vector65>:
.globl vector65
vector65:
  pushl $0
c0102de7:	6a 00                	push   $0x0
  pushl $65
c0102de9:	6a 41                	push   $0x41
  jmp __alltraps
c0102deb:	e9 2e 08 00 00       	jmp    c010361e <__alltraps>

c0102df0 <vector66>:
.globl vector66
vector66:
  pushl $0
c0102df0:	6a 00                	push   $0x0
  pushl $66
c0102df2:	6a 42                	push   $0x42
  jmp __alltraps
c0102df4:	e9 25 08 00 00       	jmp    c010361e <__alltraps>

c0102df9 <vector67>:
.globl vector67
vector67:
  pushl $0
c0102df9:	6a 00                	push   $0x0
  pushl $67
c0102dfb:	6a 43                	push   $0x43
  jmp __alltraps
c0102dfd:	e9 1c 08 00 00       	jmp    c010361e <__alltraps>

c0102e02 <vector68>:
.globl vector68
vector68:
  pushl $0
c0102e02:	6a 00                	push   $0x0
  pushl $68
c0102e04:	6a 44                	push   $0x44
  jmp __alltraps
c0102e06:	e9 13 08 00 00       	jmp    c010361e <__alltraps>

c0102e0b <vector69>:
.globl vector69
vector69:
  pushl $0
c0102e0b:	6a 00                	push   $0x0
  pushl $69
c0102e0d:	6a 45                	push   $0x45
  jmp __alltraps
c0102e0f:	e9 0a 08 00 00       	jmp    c010361e <__alltraps>

c0102e14 <vector70>:
.globl vector70
vector70:
  pushl $0
c0102e14:	6a 00                	push   $0x0
  pushl $70
c0102e16:	6a 46                	push   $0x46
  jmp __alltraps
c0102e18:	e9 01 08 00 00       	jmp    c010361e <__alltraps>

c0102e1d <vector71>:
.globl vector71
vector71:
  pushl $0
c0102e1d:	6a 00                	push   $0x0
  pushl $71
c0102e1f:	6a 47                	push   $0x47
  jmp __alltraps
c0102e21:	e9 f8 07 00 00       	jmp    c010361e <__alltraps>

c0102e26 <vector72>:
.globl vector72
vector72:
  pushl $0
c0102e26:	6a 00                	push   $0x0
  pushl $72
c0102e28:	6a 48                	push   $0x48
  jmp __alltraps
c0102e2a:	e9 ef 07 00 00       	jmp    c010361e <__alltraps>

c0102e2f <vector73>:
.globl vector73
vector73:
  pushl $0
c0102e2f:	6a 00                	push   $0x0
  pushl $73
c0102e31:	6a 49                	push   $0x49
  jmp __alltraps
c0102e33:	e9 e6 07 00 00       	jmp    c010361e <__alltraps>

c0102e38 <vector74>:
.globl vector74
vector74:
  pushl $0
c0102e38:	6a 00                	push   $0x0
  pushl $74
c0102e3a:	6a 4a                	push   $0x4a
  jmp __alltraps
c0102e3c:	e9 dd 07 00 00       	jmp    c010361e <__alltraps>

c0102e41 <vector75>:
.globl vector75
vector75:
  pushl $0
c0102e41:	6a 00                	push   $0x0
  pushl $75
c0102e43:	6a 4b                	push   $0x4b
  jmp __alltraps
c0102e45:	e9 d4 07 00 00       	jmp    c010361e <__alltraps>

c0102e4a <vector76>:
.globl vector76
vector76:
  pushl $0
c0102e4a:	6a 00                	push   $0x0
  pushl $76
c0102e4c:	6a 4c                	push   $0x4c
  jmp __alltraps
c0102e4e:	e9 cb 07 00 00       	jmp    c010361e <__alltraps>

c0102e53 <vector77>:
.globl vector77
vector77:
  pushl $0
c0102e53:	6a 00                	push   $0x0
  pushl $77
c0102e55:	6a 4d                	push   $0x4d
  jmp __alltraps
c0102e57:	e9 c2 07 00 00       	jmp    c010361e <__alltraps>

c0102e5c <vector78>:
.globl vector78
vector78:
  pushl $0
c0102e5c:	6a 00                	push   $0x0
  pushl $78
c0102e5e:	6a 4e                	push   $0x4e
  jmp __alltraps
c0102e60:	e9 b9 07 00 00       	jmp    c010361e <__alltraps>

c0102e65 <vector79>:
.globl vector79
vector79:
  pushl $0
c0102e65:	6a 00                	push   $0x0
  pushl $79
c0102e67:	6a 4f                	push   $0x4f
  jmp __alltraps
c0102e69:	e9 b0 07 00 00       	jmp    c010361e <__alltraps>

c0102e6e <vector80>:
.globl vector80
vector80:
  pushl $0
c0102e6e:	6a 00                	push   $0x0
  pushl $80
c0102e70:	6a 50                	push   $0x50
  jmp __alltraps
c0102e72:	e9 a7 07 00 00       	jmp    c010361e <__alltraps>

c0102e77 <vector81>:
.globl vector81
vector81:
  pushl $0
c0102e77:	6a 00                	push   $0x0
  pushl $81
c0102e79:	6a 51                	push   $0x51
  jmp __alltraps
c0102e7b:	e9 9e 07 00 00       	jmp    c010361e <__alltraps>

c0102e80 <vector82>:
.globl vector82
vector82:
  pushl $0
c0102e80:	6a 00                	push   $0x0
  pushl $82
c0102e82:	6a 52                	push   $0x52
  jmp __alltraps
c0102e84:	e9 95 07 00 00       	jmp    c010361e <__alltraps>

c0102e89 <vector83>:
.globl vector83
vector83:
  pushl $0
c0102e89:	6a 00                	push   $0x0
  pushl $83
c0102e8b:	6a 53                	push   $0x53
  jmp __alltraps
c0102e8d:	e9 8c 07 00 00       	jmp    c010361e <__alltraps>

c0102e92 <vector84>:
.globl vector84
vector84:
  pushl $0
c0102e92:	6a 00                	push   $0x0
  pushl $84
c0102e94:	6a 54                	push   $0x54
  jmp __alltraps
c0102e96:	e9 83 07 00 00       	jmp    c010361e <__alltraps>

c0102e9b <vector85>:
.globl vector85
vector85:
  pushl $0
c0102e9b:	6a 00                	push   $0x0
  pushl $85
c0102e9d:	6a 55                	push   $0x55
  jmp __alltraps
c0102e9f:	e9 7a 07 00 00       	jmp    c010361e <__alltraps>

c0102ea4 <vector86>:
.globl vector86
vector86:
  pushl $0
c0102ea4:	6a 00                	push   $0x0
  pushl $86
c0102ea6:	6a 56                	push   $0x56
  jmp __alltraps
c0102ea8:	e9 71 07 00 00       	jmp    c010361e <__alltraps>

c0102ead <vector87>:
.globl vector87
vector87:
  pushl $0
c0102ead:	6a 00                	push   $0x0
  pushl $87
c0102eaf:	6a 57                	push   $0x57
  jmp __alltraps
c0102eb1:	e9 68 07 00 00       	jmp    c010361e <__alltraps>

c0102eb6 <vector88>:
.globl vector88
vector88:
  pushl $0
c0102eb6:	6a 00                	push   $0x0
  pushl $88
c0102eb8:	6a 58                	push   $0x58
  jmp __alltraps
c0102eba:	e9 5f 07 00 00       	jmp    c010361e <__alltraps>

c0102ebf <vector89>:
.globl vector89
vector89:
  pushl $0
c0102ebf:	6a 00                	push   $0x0
  pushl $89
c0102ec1:	6a 59                	push   $0x59
  jmp __alltraps
c0102ec3:	e9 56 07 00 00       	jmp    c010361e <__alltraps>

c0102ec8 <vector90>:
.globl vector90
vector90:
  pushl $0
c0102ec8:	6a 00                	push   $0x0
  pushl $90
c0102eca:	6a 5a                	push   $0x5a
  jmp __alltraps
c0102ecc:	e9 4d 07 00 00       	jmp    c010361e <__alltraps>

c0102ed1 <vector91>:
.globl vector91
vector91:
  pushl $0
c0102ed1:	6a 00                	push   $0x0
  pushl $91
c0102ed3:	6a 5b                	push   $0x5b
  jmp __alltraps
c0102ed5:	e9 44 07 00 00       	jmp    c010361e <__alltraps>

c0102eda <vector92>:
.globl vector92
vector92:
  pushl $0
c0102eda:	6a 00                	push   $0x0
  pushl $92
c0102edc:	6a 5c                	push   $0x5c
  jmp __alltraps
c0102ede:	e9 3b 07 00 00       	jmp    c010361e <__alltraps>

c0102ee3 <vector93>:
.globl vector93
vector93:
  pushl $0
c0102ee3:	6a 00                	push   $0x0
  pushl $93
c0102ee5:	6a 5d                	push   $0x5d
  jmp __alltraps
c0102ee7:	e9 32 07 00 00       	jmp    c010361e <__alltraps>

c0102eec <vector94>:
.globl vector94
vector94:
  pushl $0
c0102eec:	6a 00                	push   $0x0
  pushl $94
c0102eee:	6a 5e                	push   $0x5e
  jmp __alltraps
c0102ef0:	e9 29 07 00 00       	jmp    c010361e <__alltraps>

c0102ef5 <vector95>:
.globl vector95
vector95:
  pushl $0
c0102ef5:	6a 00                	push   $0x0
  pushl $95
c0102ef7:	6a 5f                	push   $0x5f
  jmp __alltraps
c0102ef9:	e9 20 07 00 00       	jmp    c010361e <__alltraps>

c0102efe <vector96>:
.globl vector96
vector96:
  pushl $0
c0102efe:	6a 00                	push   $0x0
  pushl $96
c0102f00:	6a 60                	push   $0x60
  jmp __alltraps
c0102f02:	e9 17 07 00 00       	jmp    c010361e <__alltraps>

c0102f07 <vector97>:
.globl vector97
vector97:
  pushl $0
c0102f07:	6a 00                	push   $0x0
  pushl $97
c0102f09:	6a 61                	push   $0x61
  jmp __alltraps
c0102f0b:	e9 0e 07 00 00       	jmp    c010361e <__alltraps>

c0102f10 <vector98>:
.globl vector98
vector98:
  pushl $0
c0102f10:	6a 00                	push   $0x0
  pushl $98
c0102f12:	6a 62                	push   $0x62
  jmp __alltraps
c0102f14:	e9 05 07 00 00       	jmp    c010361e <__alltraps>

c0102f19 <vector99>:
.globl vector99
vector99:
  pushl $0
c0102f19:	6a 00                	push   $0x0
  pushl $99
c0102f1b:	6a 63                	push   $0x63
  jmp __alltraps
c0102f1d:	e9 fc 06 00 00       	jmp    c010361e <__alltraps>

c0102f22 <vector100>:
.globl vector100
vector100:
  pushl $0
c0102f22:	6a 00                	push   $0x0
  pushl $100
c0102f24:	6a 64                	push   $0x64
  jmp __alltraps
c0102f26:	e9 f3 06 00 00       	jmp    c010361e <__alltraps>

c0102f2b <vector101>:
.globl vector101
vector101:
  pushl $0
c0102f2b:	6a 00                	push   $0x0
  pushl $101
c0102f2d:	6a 65                	push   $0x65
  jmp __alltraps
c0102f2f:	e9 ea 06 00 00       	jmp    c010361e <__alltraps>

c0102f34 <vector102>:
.globl vector102
vector102:
  pushl $0
c0102f34:	6a 00                	push   $0x0
  pushl $102
c0102f36:	6a 66                	push   $0x66
  jmp __alltraps
c0102f38:	e9 e1 06 00 00       	jmp    c010361e <__alltraps>

c0102f3d <vector103>:
.globl vector103
vector103:
  pushl $0
c0102f3d:	6a 00                	push   $0x0
  pushl $103
c0102f3f:	6a 67                	push   $0x67
  jmp __alltraps
c0102f41:	e9 d8 06 00 00       	jmp    c010361e <__alltraps>

c0102f46 <vector104>:
.globl vector104
vector104:
  pushl $0
c0102f46:	6a 00                	push   $0x0
  pushl $104
c0102f48:	6a 68                	push   $0x68
  jmp __alltraps
c0102f4a:	e9 cf 06 00 00       	jmp    c010361e <__alltraps>

c0102f4f <vector105>:
.globl vector105
vector105:
  pushl $0
c0102f4f:	6a 00                	push   $0x0
  pushl $105
c0102f51:	6a 69                	push   $0x69
  jmp __alltraps
c0102f53:	e9 c6 06 00 00       	jmp    c010361e <__alltraps>

c0102f58 <vector106>:
.globl vector106
vector106:
  pushl $0
c0102f58:	6a 00                	push   $0x0
  pushl $106
c0102f5a:	6a 6a                	push   $0x6a
  jmp __alltraps
c0102f5c:	e9 bd 06 00 00       	jmp    c010361e <__alltraps>

c0102f61 <vector107>:
.globl vector107
vector107:
  pushl $0
c0102f61:	6a 00                	push   $0x0
  pushl $107
c0102f63:	6a 6b                	push   $0x6b
  jmp __alltraps
c0102f65:	e9 b4 06 00 00       	jmp    c010361e <__alltraps>

c0102f6a <vector108>:
.globl vector108
vector108:
  pushl $0
c0102f6a:	6a 00                	push   $0x0
  pushl $108
c0102f6c:	6a 6c                	push   $0x6c
  jmp __alltraps
c0102f6e:	e9 ab 06 00 00       	jmp    c010361e <__alltraps>

c0102f73 <vector109>:
.globl vector109
vector109:
  pushl $0
c0102f73:	6a 00                	push   $0x0
  pushl $109
c0102f75:	6a 6d                	push   $0x6d
  jmp __alltraps
c0102f77:	e9 a2 06 00 00       	jmp    c010361e <__alltraps>

c0102f7c <vector110>:
.globl vector110
vector110:
  pushl $0
c0102f7c:	6a 00                	push   $0x0
  pushl $110
c0102f7e:	6a 6e                	push   $0x6e
  jmp __alltraps
c0102f80:	e9 99 06 00 00       	jmp    c010361e <__alltraps>

c0102f85 <vector111>:
.globl vector111
vector111:
  pushl $0
c0102f85:	6a 00                	push   $0x0
  pushl $111
c0102f87:	6a 6f                	push   $0x6f
  jmp __alltraps
c0102f89:	e9 90 06 00 00       	jmp    c010361e <__alltraps>

c0102f8e <vector112>:
.globl vector112
vector112:
  pushl $0
c0102f8e:	6a 00                	push   $0x0
  pushl $112
c0102f90:	6a 70                	push   $0x70
  jmp __alltraps
c0102f92:	e9 87 06 00 00       	jmp    c010361e <__alltraps>

c0102f97 <vector113>:
.globl vector113
vector113:
  pushl $0
c0102f97:	6a 00                	push   $0x0
  pushl $113
c0102f99:	6a 71                	push   $0x71
  jmp __alltraps
c0102f9b:	e9 7e 06 00 00       	jmp    c010361e <__alltraps>

c0102fa0 <vector114>:
.globl vector114
vector114:
  pushl $0
c0102fa0:	6a 00                	push   $0x0
  pushl $114
c0102fa2:	6a 72                	push   $0x72
  jmp __alltraps
c0102fa4:	e9 75 06 00 00       	jmp    c010361e <__alltraps>

c0102fa9 <vector115>:
.globl vector115
vector115:
  pushl $0
c0102fa9:	6a 00                	push   $0x0
  pushl $115
c0102fab:	6a 73                	push   $0x73
  jmp __alltraps
c0102fad:	e9 6c 06 00 00       	jmp    c010361e <__alltraps>

c0102fb2 <vector116>:
.globl vector116
vector116:
  pushl $0
c0102fb2:	6a 00                	push   $0x0
  pushl $116
c0102fb4:	6a 74                	push   $0x74
  jmp __alltraps
c0102fb6:	e9 63 06 00 00       	jmp    c010361e <__alltraps>

c0102fbb <vector117>:
.globl vector117
vector117:
  pushl $0
c0102fbb:	6a 00                	push   $0x0
  pushl $117
c0102fbd:	6a 75                	push   $0x75
  jmp __alltraps
c0102fbf:	e9 5a 06 00 00       	jmp    c010361e <__alltraps>

c0102fc4 <vector118>:
.globl vector118
vector118:
  pushl $0
c0102fc4:	6a 00                	push   $0x0
  pushl $118
c0102fc6:	6a 76                	push   $0x76
  jmp __alltraps
c0102fc8:	e9 51 06 00 00       	jmp    c010361e <__alltraps>

c0102fcd <vector119>:
.globl vector119
vector119:
  pushl $0
c0102fcd:	6a 00                	push   $0x0
  pushl $119
c0102fcf:	6a 77                	push   $0x77
  jmp __alltraps
c0102fd1:	e9 48 06 00 00       	jmp    c010361e <__alltraps>

c0102fd6 <vector120>:
.globl vector120
vector120:
  pushl $0
c0102fd6:	6a 00                	push   $0x0
  pushl $120
c0102fd8:	6a 78                	push   $0x78
  jmp __alltraps
c0102fda:	e9 3f 06 00 00       	jmp    c010361e <__alltraps>

c0102fdf <vector121>:
.globl vector121
vector121:
  pushl $0
c0102fdf:	6a 00                	push   $0x0
  pushl $121
c0102fe1:	6a 79                	push   $0x79
  jmp __alltraps
c0102fe3:	e9 36 06 00 00       	jmp    c010361e <__alltraps>

c0102fe8 <vector122>:
.globl vector122
vector122:
  pushl $0
c0102fe8:	6a 00                	push   $0x0
  pushl $122
c0102fea:	6a 7a                	push   $0x7a
  jmp __alltraps
c0102fec:	e9 2d 06 00 00       	jmp    c010361e <__alltraps>

c0102ff1 <vector123>:
.globl vector123
vector123:
  pushl $0
c0102ff1:	6a 00                	push   $0x0
  pushl $123
c0102ff3:	6a 7b                	push   $0x7b
  jmp __alltraps
c0102ff5:	e9 24 06 00 00       	jmp    c010361e <__alltraps>

c0102ffa <vector124>:
.globl vector124
vector124:
  pushl $0
c0102ffa:	6a 00                	push   $0x0
  pushl $124
c0102ffc:	6a 7c                	push   $0x7c
  jmp __alltraps
c0102ffe:	e9 1b 06 00 00       	jmp    c010361e <__alltraps>

c0103003 <vector125>:
.globl vector125
vector125:
  pushl $0
c0103003:	6a 00                	push   $0x0
  pushl $125
c0103005:	6a 7d                	push   $0x7d
  jmp __alltraps
c0103007:	e9 12 06 00 00       	jmp    c010361e <__alltraps>

c010300c <vector126>:
.globl vector126
vector126:
  pushl $0
c010300c:	6a 00                	push   $0x0
  pushl $126
c010300e:	6a 7e                	push   $0x7e
  jmp __alltraps
c0103010:	e9 09 06 00 00       	jmp    c010361e <__alltraps>

c0103015 <vector127>:
.globl vector127
vector127:
  pushl $0
c0103015:	6a 00                	push   $0x0
  pushl $127
c0103017:	6a 7f                	push   $0x7f
  jmp __alltraps
c0103019:	e9 00 06 00 00       	jmp    c010361e <__alltraps>

c010301e <vector128>:
.globl vector128
vector128:
  pushl $0
c010301e:	6a 00                	push   $0x0
  pushl $128
c0103020:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c0103025:	e9 f4 05 00 00       	jmp    c010361e <__alltraps>

c010302a <vector129>:
.globl vector129
vector129:
  pushl $0
c010302a:	6a 00                	push   $0x0
  pushl $129
c010302c:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c0103031:	e9 e8 05 00 00       	jmp    c010361e <__alltraps>

c0103036 <vector130>:
.globl vector130
vector130:
  pushl $0
c0103036:	6a 00                	push   $0x0
  pushl $130
c0103038:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c010303d:	e9 dc 05 00 00       	jmp    c010361e <__alltraps>

c0103042 <vector131>:
.globl vector131
vector131:
  pushl $0
c0103042:	6a 00                	push   $0x0
  pushl $131
c0103044:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c0103049:	e9 d0 05 00 00       	jmp    c010361e <__alltraps>

c010304e <vector132>:
.globl vector132
vector132:
  pushl $0
c010304e:	6a 00                	push   $0x0
  pushl $132
c0103050:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c0103055:	e9 c4 05 00 00       	jmp    c010361e <__alltraps>

c010305a <vector133>:
.globl vector133
vector133:
  pushl $0
c010305a:	6a 00                	push   $0x0
  pushl $133
c010305c:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c0103061:	e9 b8 05 00 00       	jmp    c010361e <__alltraps>

c0103066 <vector134>:
.globl vector134
vector134:
  pushl $0
c0103066:	6a 00                	push   $0x0
  pushl $134
c0103068:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c010306d:	e9 ac 05 00 00       	jmp    c010361e <__alltraps>

c0103072 <vector135>:
.globl vector135
vector135:
  pushl $0
c0103072:	6a 00                	push   $0x0
  pushl $135
c0103074:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0103079:	e9 a0 05 00 00       	jmp    c010361e <__alltraps>

c010307e <vector136>:
.globl vector136
vector136:
  pushl $0
c010307e:	6a 00                	push   $0x0
  pushl $136
c0103080:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c0103085:	e9 94 05 00 00       	jmp    c010361e <__alltraps>

c010308a <vector137>:
.globl vector137
vector137:
  pushl $0
c010308a:	6a 00                	push   $0x0
  pushl $137
c010308c:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c0103091:	e9 88 05 00 00       	jmp    c010361e <__alltraps>

c0103096 <vector138>:
.globl vector138
vector138:
  pushl $0
c0103096:	6a 00                	push   $0x0
  pushl $138
c0103098:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c010309d:	e9 7c 05 00 00       	jmp    c010361e <__alltraps>

c01030a2 <vector139>:
.globl vector139
vector139:
  pushl $0
c01030a2:	6a 00                	push   $0x0
  pushl $139
c01030a4:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c01030a9:	e9 70 05 00 00       	jmp    c010361e <__alltraps>

c01030ae <vector140>:
.globl vector140
vector140:
  pushl $0
c01030ae:	6a 00                	push   $0x0
  pushl $140
c01030b0:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c01030b5:	e9 64 05 00 00       	jmp    c010361e <__alltraps>

c01030ba <vector141>:
.globl vector141
vector141:
  pushl $0
c01030ba:	6a 00                	push   $0x0
  pushl $141
c01030bc:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c01030c1:	e9 58 05 00 00       	jmp    c010361e <__alltraps>

c01030c6 <vector142>:
.globl vector142
vector142:
  pushl $0
c01030c6:	6a 00                	push   $0x0
  pushl $142
c01030c8:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c01030cd:	e9 4c 05 00 00       	jmp    c010361e <__alltraps>

c01030d2 <vector143>:
.globl vector143
vector143:
  pushl $0
c01030d2:	6a 00                	push   $0x0
  pushl $143
c01030d4:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c01030d9:	e9 40 05 00 00       	jmp    c010361e <__alltraps>

c01030de <vector144>:
.globl vector144
vector144:
  pushl $0
c01030de:	6a 00                	push   $0x0
  pushl $144
c01030e0:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c01030e5:	e9 34 05 00 00       	jmp    c010361e <__alltraps>

c01030ea <vector145>:
.globl vector145
vector145:
  pushl $0
c01030ea:	6a 00                	push   $0x0
  pushl $145
c01030ec:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c01030f1:	e9 28 05 00 00       	jmp    c010361e <__alltraps>

c01030f6 <vector146>:
.globl vector146
vector146:
  pushl $0
c01030f6:	6a 00                	push   $0x0
  pushl $146
c01030f8:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c01030fd:	e9 1c 05 00 00       	jmp    c010361e <__alltraps>

c0103102 <vector147>:
.globl vector147
vector147:
  pushl $0
c0103102:	6a 00                	push   $0x0
  pushl $147
c0103104:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c0103109:	e9 10 05 00 00       	jmp    c010361e <__alltraps>

c010310e <vector148>:
.globl vector148
vector148:
  pushl $0
c010310e:	6a 00                	push   $0x0
  pushl $148
c0103110:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c0103115:	e9 04 05 00 00       	jmp    c010361e <__alltraps>

c010311a <vector149>:
.globl vector149
vector149:
  pushl $0
c010311a:	6a 00                	push   $0x0
  pushl $149
c010311c:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c0103121:	e9 f8 04 00 00       	jmp    c010361e <__alltraps>

c0103126 <vector150>:
.globl vector150
vector150:
  pushl $0
c0103126:	6a 00                	push   $0x0
  pushl $150
c0103128:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c010312d:	e9 ec 04 00 00       	jmp    c010361e <__alltraps>

c0103132 <vector151>:
.globl vector151
vector151:
  pushl $0
c0103132:	6a 00                	push   $0x0
  pushl $151
c0103134:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c0103139:	e9 e0 04 00 00       	jmp    c010361e <__alltraps>

c010313e <vector152>:
.globl vector152
vector152:
  pushl $0
c010313e:	6a 00                	push   $0x0
  pushl $152
c0103140:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c0103145:	e9 d4 04 00 00       	jmp    c010361e <__alltraps>

c010314a <vector153>:
.globl vector153
vector153:
  pushl $0
c010314a:	6a 00                	push   $0x0
  pushl $153
c010314c:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c0103151:	e9 c8 04 00 00       	jmp    c010361e <__alltraps>

c0103156 <vector154>:
.globl vector154
vector154:
  pushl $0
c0103156:	6a 00                	push   $0x0
  pushl $154
c0103158:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c010315d:	e9 bc 04 00 00       	jmp    c010361e <__alltraps>

c0103162 <vector155>:
.globl vector155
vector155:
  pushl $0
c0103162:	6a 00                	push   $0x0
  pushl $155
c0103164:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c0103169:	e9 b0 04 00 00       	jmp    c010361e <__alltraps>

c010316e <vector156>:
.globl vector156
vector156:
  pushl $0
c010316e:	6a 00                	push   $0x0
  pushl $156
c0103170:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c0103175:	e9 a4 04 00 00       	jmp    c010361e <__alltraps>

c010317a <vector157>:
.globl vector157
vector157:
  pushl $0
c010317a:	6a 00                	push   $0x0
  pushl $157
c010317c:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c0103181:	e9 98 04 00 00       	jmp    c010361e <__alltraps>

c0103186 <vector158>:
.globl vector158
vector158:
  pushl $0
c0103186:	6a 00                	push   $0x0
  pushl $158
c0103188:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c010318d:	e9 8c 04 00 00       	jmp    c010361e <__alltraps>

c0103192 <vector159>:
.globl vector159
vector159:
  pushl $0
c0103192:	6a 00                	push   $0x0
  pushl $159
c0103194:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c0103199:	e9 80 04 00 00       	jmp    c010361e <__alltraps>

c010319e <vector160>:
.globl vector160
vector160:
  pushl $0
c010319e:	6a 00                	push   $0x0
  pushl $160
c01031a0:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c01031a5:	e9 74 04 00 00       	jmp    c010361e <__alltraps>

c01031aa <vector161>:
.globl vector161
vector161:
  pushl $0
c01031aa:	6a 00                	push   $0x0
  pushl $161
c01031ac:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c01031b1:	e9 68 04 00 00       	jmp    c010361e <__alltraps>

c01031b6 <vector162>:
.globl vector162
vector162:
  pushl $0
c01031b6:	6a 00                	push   $0x0
  pushl $162
c01031b8:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c01031bd:	e9 5c 04 00 00       	jmp    c010361e <__alltraps>

c01031c2 <vector163>:
.globl vector163
vector163:
  pushl $0
c01031c2:	6a 00                	push   $0x0
  pushl $163
c01031c4:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c01031c9:	e9 50 04 00 00       	jmp    c010361e <__alltraps>

c01031ce <vector164>:
.globl vector164
vector164:
  pushl $0
c01031ce:	6a 00                	push   $0x0
  pushl $164
c01031d0:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c01031d5:	e9 44 04 00 00       	jmp    c010361e <__alltraps>

c01031da <vector165>:
.globl vector165
vector165:
  pushl $0
c01031da:	6a 00                	push   $0x0
  pushl $165
c01031dc:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c01031e1:	e9 38 04 00 00       	jmp    c010361e <__alltraps>

c01031e6 <vector166>:
.globl vector166
vector166:
  pushl $0
c01031e6:	6a 00                	push   $0x0
  pushl $166
c01031e8:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c01031ed:	e9 2c 04 00 00       	jmp    c010361e <__alltraps>

c01031f2 <vector167>:
.globl vector167
vector167:
  pushl $0
c01031f2:	6a 00                	push   $0x0
  pushl $167
c01031f4:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c01031f9:	e9 20 04 00 00       	jmp    c010361e <__alltraps>

c01031fe <vector168>:
.globl vector168
vector168:
  pushl $0
c01031fe:	6a 00                	push   $0x0
  pushl $168
c0103200:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c0103205:	e9 14 04 00 00       	jmp    c010361e <__alltraps>

c010320a <vector169>:
.globl vector169
vector169:
  pushl $0
c010320a:	6a 00                	push   $0x0
  pushl $169
c010320c:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c0103211:	e9 08 04 00 00       	jmp    c010361e <__alltraps>

c0103216 <vector170>:
.globl vector170
vector170:
  pushl $0
c0103216:	6a 00                	push   $0x0
  pushl $170
c0103218:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c010321d:	e9 fc 03 00 00       	jmp    c010361e <__alltraps>

c0103222 <vector171>:
.globl vector171
vector171:
  pushl $0
c0103222:	6a 00                	push   $0x0
  pushl $171
c0103224:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c0103229:	e9 f0 03 00 00       	jmp    c010361e <__alltraps>

c010322e <vector172>:
.globl vector172
vector172:
  pushl $0
c010322e:	6a 00                	push   $0x0
  pushl $172
c0103230:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c0103235:	e9 e4 03 00 00       	jmp    c010361e <__alltraps>

c010323a <vector173>:
.globl vector173
vector173:
  pushl $0
c010323a:	6a 00                	push   $0x0
  pushl $173
c010323c:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c0103241:	e9 d8 03 00 00       	jmp    c010361e <__alltraps>

c0103246 <vector174>:
.globl vector174
vector174:
  pushl $0
c0103246:	6a 00                	push   $0x0
  pushl $174
c0103248:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c010324d:	e9 cc 03 00 00       	jmp    c010361e <__alltraps>

c0103252 <vector175>:
.globl vector175
vector175:
  pushl $0
c0103252:	6a 00                	push   $0x0
  pushl $175
c0103254:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c0103259:	e9 c0 03 00 00       	jmp    c010361e <__alltraps>

c010325e <vector176>:
.globl vector176
vector176:
  pushl $0
c010325e:	6a 00                	push   $0x0
  pushl $176
c0103260:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c0103265:	e9 b4 03 00 00       	jmp    c010361e <__alltraps>

c010326a <vector177>:
.globl vector177
vector177:
  pushl $0
c010326a:	6a 00                	push   $0x0
  pushl $177
c010326c:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c0103271:	e9 a8 03 00 00       	jmp    c010361e <__alltraps>

c0103276 <vector178>:
.globl vector178
vector178:
  pushl $0
c0103276:	6a 00                	push   $0x0
  pushl $178
c0103278:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c010327d:	e9 9c 03 00 00       	jmp    c010361e <__alltraps>

c0103282 <vector179>:
.globl vector179
vector179:
  pushl $0
c0103282:	6a 00                	push   $0x0
  pushl $179
c0103284:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c0103289:	e9 90 03 00 00       	jmp    c010361e <__alltraps>

c010328e <vector180>:
.globl vector180
vector180:
  pushl $0
c010328e:	6a 00                	push   $0x0
  pushl $180
c0103290:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c0103295:	e9 84 03 00 00       	jmp    c010361e <__alltraps>

c010329a <vector181>:
.globl vector181
vector181:
  pushl $0
c010329a:	6a 00                	push   $0x0
  pushl $181
c010329c:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c01032a1:	e9 78 03 00 00       	jmp    c010361e <__alltraps>

c01032a6 <vector182>:
.globl vector182
vector182:
  pushl $0
c01032a6:	6a 00                	push   $0x0
  pushl $182
c01032a8:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c01032ad:	e9 6c 03 00 00       	jmp    c010361e <__alltraps>

c01032b2 <vector183>:
.globl vector183
vector183:
  pushl $0
c01032b2:	6a 00                	push   $0x0
  pushl $183
c01032b4:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c01032b9:	e9 60 03 00 00       	jmp    c010361e <__alltraps>

c01032be <vector184>:
.globl vector184
vector184:
  pushl $0
c01032be:	6a 00                	push   $0x0
  pushl $184
c01032c0:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c01032c5:	e9 54 03 00 00       	jmp    c010361e <__alltraps>

c01032ca <vector185>:
.globl vector185
vector185:
  pushl $0
c01032ca:	6a 00                	push   $0x0
  pushl $185
c01032cc:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c01032d1:	e9 48 03 00 00       	jmp    c010361e <__alltraps>

c01032d6 <vector186>:
.globl vector186
vector186:
  pushl $0
c01032d6:	6a 00                	push   $0x0
  pushl $186
c01032d8:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c01032dd:	e9 3c 03 00 00       	jmp    c010361e <__alltraps>

c01032e2 <vector187>:
.globl vector187
vector187:
  pushl $0
c01032e2:	6a 00                	push   $0x0
  pushl $187
c01032e4:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c01032e9:	e9 30 03 00 00       	jmp    c010361e <__alltraps>

c01032ee <vector188>:
.globl vector188
vector188:
  pushl $0
c01032ee:	6a 00                	push   $0x0
  pushl $188
c01032f0:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c01032f5:	e9 24 03 00 00       	jmp    c010361e <__alltraps>

c01032fa <vector189>:
.globl vector189
vector189:
  pushl $0
c01032fa:	6a 00                	push   $0x0
  pushl $189
c01032fc:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c0103301:	e9 18 03 00 00       	jmp    c010361e <__alltraps>

c0103306 <vector190>:
.globl vector190
vector190:
  pushl $0
c0103306:	6a 00                	push   $0x0
  pushl $190
c0103308:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c010330d:	e9 0c 03 00 00       	jmp    c010361e <__alltraps>

c0103312 <vector191>:
.globl vector191
vector191:
  pushl $0
c0103312:	6a 00                	push   $0x0
  pushl $191
c0103314:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c0103319:	e9 00 03 00 00       	jmp    c010361e <__alltraps>

c010331e <vector192>:
.globl vector192
vector192:
  pushl $0
c010331e:	6a 00                	push   $0x0
  pushl $192
c0103320:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c0103325:	e9 f4 02 00 00       	jmp    c010361e <__alltraps>

c010332a <vector193>:
.globl vector193
vector193:
  pushl $0
c010332a:	6a 00                	push   $0x0
  pushl $193
c010332c:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c0103331:	e9 e8 02 00 00       	jmp    c010361e <__alltraps>

c0103336 <vector194>:
.globl vector194
vector194:
  pushl $0
c0103336:	6a 00                	push   $0x0
  pushl $194
c0103338:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c010333d:	e9 dc 02 00 00       	jmp    c010361e <__alltraps>

c0103342 <vector195>:
.globl vector195
vector195:
  pushl $0
c0103342:	6a 00                	push   $0x0
  pushl $195
c0103344:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c0103349:	e9 d0 02 00 00       	jmp    c010361e <__alltraps>

c010334e <vector196>:
.globl vector196
vector196:
  pushl $0
c010334e:	6a 00                	push   $0x0
  pushl $196
c0103350:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c0103355:	e9 c4 02 00 00       	jmp    c010361e <__alltraps>

c010335a <vector197>:
.globl vector197
vector197:
  pushl $0
c010335a:	6a 00                	push   $0x0
  pushl $197
c010335c:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c0103361:	e9 b8 02 00 00       	jmp    c010361e <__alltraps>

c0103366 <vector198>:
.globl vector198
vector198:
  pushl $0
c0103366:	6a 00                	push   $0x0
  pushl $198
c0103368:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c010336d:	e9 ac 02 00 00       	jmp    c010361e <__alltraps>

c0103372 <vector199>:
.globl vector199
vector199:
  pushl $0
c0103372:	6a 00                	push   $0x0
  pushl $199
c0103374:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c0103379:	e9 a0 02 00 00       	jmp    c010361e <__alltraps>

c010337e <vector200>:
.globl vector200
vector200:
  pushl $0
c010337e:	6a 00                	push   $0x0
  pushl $200
c0103380:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c0103385:	e9 94 02 00 00       	jmp    c010361e <__alltraps>

c010338a <vector201>:
.globl vector201
vector201:
  pushl $0
c010338a:	6a 00                	push   $0x0
  pushl $201
c010338c:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c0103391:	e9 88 02 00 00       	jmp    c010361e <__alltraps>

c0103396 <vector202>:
.globl vector202
vector202:
  pushl $0
c0103396:	6a 00                	push   $0x0
  pushl $202
c0103398:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c010339d:	e9 7c 02 00 00       	jmp    c010361e <__alltraps>

c01033a2 <vector203>:
.globl vector203
vector203:
  pushl $0
c01033a2:	6a 00                	push   $0x0
  pushl $203
c01033a4:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c01033a9:	e9 70 02 00 00       	jmp    c010361e <__alltraps>

c01033ae <vector204>:
.globl vector204
vector204:
  pushl $0
c01033ae:	6a 00                	push   $0x0
  pushl $204
c01033b0:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c01033b5:	e9 64 02 00 00       	jmp    c010361e <__alltraps>

c01033ba <vector205>:
.globl vector205
vector205:
  pushl $0
c01033ba:	6a 00                	push   $0x0
  pushl $205
c01033bc:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c01033c1:	e9 58 02 00 00       	jmp    c010361e <__alltraps>

c01033c6 <vector206>:
.globl vector206
vector206:
  pushl $0
c01033c6:	6a 00                	push   $0x0
  pushl $206
c01033c8:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c01033cd:	e9 4c 02 00 00       	jmp    c010361e <__alltraps>

c01033d2 <vector207>:
.globl vector207
vector207:
  pushl $0
c01033d2:	6a 00                	push   $0x0
  pushl $207
c01033d4:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c01033d9:	e9 40 02 00 00       	jmp    c010361e <__alltraps>

c01033de <vector208>:
.globl vector208
vector208:
  pushl $0
c01033de:	6a 00                	push   $0x0
  pushl $208
c01033e0:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c01033e5:	e9 34 02 00 00       	jmp    c010361e <__alltraps>

c01033ea <vector209>:
.globl vector209
vector209:
  pushl $0
c01033ea:	6a 00                	push   $0x0
  pushl $209
c01033ec:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c01033f1:	e9 28 02 00 00       	jmp    c010361e <__alltraps>

c01033f6 <vector210>:
.globl vector210
vector210:
  pushl $0
c01033f6:	6a 00                	push   $0x0
  pushl $210
c01033f8:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c01033fd:	e9 1c 02 00 00       	jmp    c010361e <__alltraps>

c0103402 <vector211>:
.globl vector211
vector211:
  pushl $0
c0103402:	6a 00                	push   $0x0
  pushl $211
c0103404:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c0103409:	e9 10 02 00 00       	jmp    c010361e <__alltraps>

c010340e <vector212>:
.globl vector212
vector212:
  pushl $0
c010340e:	6a 00                	push   $0x0
  pushl $212
c0103410:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c0103415:	e9 04 02 00 00       	jmp    c010361e <__alltraps>

c010341a <vector213>:
.globl vector213
vector213:
  pushl $0
c010341a:	6a 00                	push   $0x0
  pushl $213
c010341c:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c0103421:	e9 f8 01 00 00       	jmp    c010361e <__alltraps>

c0103426 <vector214>:
.globl vector214
vector214:
  pushl $0
c0103426:	6a 00                	push   $0x0
  pushl $214
c0103428:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c010342d:	e9 ec 01 00 00       	jmp    c010361e <__alltraps>

c0103432 <vector215>:
.globl vector215
vector215:
  pushl $0
c0103432:	6a 00                	push   $0x0
  pushl $215
c0103434:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c0103439:	e9 e0 01 00 00       	jmp    c010361e <__alltraps>

c010343e <vector216>:
.globl vector216
vector216:
  pushl $0
c010343e:	6a 00                	push   $0x0
  pushl $216
c0103440:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c0103445:	e9 d4 01 00 00       	jmp    c010361e <__alltraps>

c010344a <vector217>:
.globl vector217
vector217:
  pushl $0
c010344a:	6a 00                	push   $0x0
  pushl $217
c010344c:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c0103451:	e9 c8 01 00 00       	jmp    c010361e <__alltraps>

c0103456 <vector218>:
.globl vector218
vector218:
  pushl $0
c0103456:	6a 00                	push   $0x0
  pushl $218
c0103458:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c010345d:	e9 bc 01 00 00       	jmp    c010361e <__alltraps>

c0103462 <vector219>:
.globl vector219
vector219:
  pushl $0
c0103462:	6a 00                	push   $0x0
  pushl $219
c0103464:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c0103469:	e9 b0 01 00 00       	jmp    c010361e <__alltraps>

c010346e <vector220>:
.globl vector220
vector220:
  pushl $0
c010346e:	6a 00                	push   $0x0
  pushl $220
c0103470:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c0103475:	e9 a4 01 00 00       	jmp    c010361e <__alltraps>

c010347a <vector221>:
.globl vector221
vector221:
  pushl $0
c010347a:	6a 00                	push   $0x0
  pushl $221
c010347c:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c0103481:	e9 98 01 00 00       	jmp    c010361e <__alltraps>

c0103486 <vector222>:
.globl vector222
vector222:
  pushl $0
c0103486:	6a 00                	push   $0x0
  pushl $222
c0103488:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c010348d:	e9 8c 01 00 00       	jmp    c010361e <__alltraps>

c0103492 <vector223>:
.globl vector223
vector223:
  pushl $0
c0103492:	6a 00                	push   $0x0
  pushl $223
c0103494:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c0103499:	e9 80 01 00 00       	jmp    c010361e <__alltraps>

c010349e <vector224>:
.globl vector224
vector224:
  pushl $0
c010349e:	6a 00                	push   $0x0
  pushl $224
c01034a0:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c01034a5:	e9 74 01 00 00       	jmp    c010361e <__alltraps>

c01034aa <vector225>:
.globl vector225
vector225:
  pushl $0
c01034aa:	6a 00                	push   $0x0
  pushl $225
c01034ac:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c01034b1:	e9 68 01 00 00       	jmp    c010361e <__alltraps>

c01034b6 <vector226>:
.globl vector226
vector226:
  pushl $0
c01034b6:	6a 00                	push   $0x0
  pushl $226
c01034b8:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c01034bd:	e9 5c 01 00 00       	jmp    c010361e <__alltraps>

c01034c2 <vector227>:
.globl vector227
vector227:
  pushl $0
c01034c2:	6a 00                	push   $0x0
  pushl $227
c01034c4:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c01034c9:	e9 50 01 00 00       	jmp    c010361e <__alltraps>

c01034ce <vector228>:
.globl vector228
vector228:
  pushl $0
c01034ce:	6a 00                	push   $0x0
  pushl $228
c01034d0:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c01034d5:	e9 44 01 00 00       	jmp    c010361e <__alltraps>

c01034da <vector229>:
.globl vector229
vector229:
  pushl $0
c01034da:	6a 00                	push   $0x0
  pushl $229
c01034dc:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c01034e1:	e9 38 01 00 00       	jmp    c010361e <__alltraps>

c01034e6 <vector230>:
.globl vector230
vector230:
  pushl $0
c01034e6:	6a 00                	push   $0x0
  pushl $230
c01034e8:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c01034ed:	e9 2c 01 00 00       	jmp    c010361e <__alltraps>

c01034f2 <vector231>:
.globl vector231
vector231:
  pushl $0
c01034f2:	6a 00                	push   $0x0
  pushl $231
c01034f4:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c01034f9:	e9 20 01 00 00       	jmp    c010361e <__alltraps>

c01034fe <vector232>:
.globl vector232
vector232:
  pushl $0
c01034fe:	6a 00                	push   $0x0
  pushl $232
c0103500:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c0103505:	e9 14 01 00 00       	jmp    c010361e <__alltraps>

c010350a <vector233>:
.globl vector233
vector233:
  pushl $0
c010350a:	6a 00                	push   $0x0
  pushl $233
c010350c:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c0103511:	e9 08 01 00 00       	jmp    c010361e <__alltraps>

c0103516 <vector234>:
.globl vector234
vector234:
  pushl $0
c0103516:	6a 00                	push   $0x0
  pushl $234
c0103518:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c010351d:	e9 fc 00 00 00       	jmp    c010361e <__alltraps>

c0103522 <vector235>:
.globl vector235
vector235:
  pushl $0
c0103522:	6a 00                	push   $0x0
  pushl $235
c0103524:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c0103529:	e9 f0 00 00 00       	jmp    c010361e <__alltraps>

c010352e <vector236>:
.globl vector236
vector236:
  pushl $0
c010352e:	6a 00                	push   $0x0
  pushl $236
c0103530:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c0103535:	e9 e4 00 00 00       	jmp    c010361e <__alltraps>

c010353a <vector237>:
.globl vector237
vector237:
  pushl $0
c010353a:	6a 00                	push   $0x0
  pushl $237
c010353c:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c0103541:	e9 d8 00 00 00       	jmp    c010361e <__alltraps>

c0103546 <vector238>:
.globl vector238
vector238:
  pushl $0
c0103546:	6a 00                	push   $0x0
  pushl $238
c0103548:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c010354d:	e9 cc 00 00 00       	jmp    c010361e <__alltraps>

c0103552 <vector239>:
.globl vector239
vector239:
  pushl $0
c0103552:	6a 00                	push   $0x0
  pushl $239
c0103554:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c0103559:	e9 c0 00 00 00       	jmp    c010361e <__alltraps>

c010355e <vector240>:
.globl vector240
vector240:
  pushl $0
c010355e:	6a 00                	push   $0x0
  pushl $240
c0103560:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c0103565:	e9 b4 00 00 00       	jmp    c010361e <__alltraps>

c010356a <vector241>:
.globl vector241
vector241:
  pushl $0
c010356a:	6a 00                	push   $0x0
  pushl $241
c010356c:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c0103571:	e9 a8 00 00 00       	jmp    c010361e <__alltraps>

c0103576 <vector242>:
.globl vector242
vector242:
  pushl $0
c0103576:	6a 00                	push   $0x0
  pushl $242
c0103578:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c010357d:	e9 9c 00 00 00       	jmp    c010361e <__alltraps>

c0103582 <vector243>:
.globl vector243
vector243:
  pushl $0
c0103582:	6a 00                	push   $0x0
  pushl $243
c0103584:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c0103589:	e9 90 00 00 00       	jmp    c010361e <__alltraps>

c010358e <vector244>:
.globl vector244
vector244:
  pushl $0
c010358e:	6a 00                	push   $0x0
  pushl $244
c0103590:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c0103595:	e9 84 00 00 00       	jmp    c010361e <__alltraps>

c010359a <vector245>:
.globl vector245
vector245:
  pushl $0
c010359a:	6a 00                	push   $0x0
  pushl $245
c010359c:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c01035a1:	e9 78 00 00 00       	jmp    c010361e <__alltraps>

c01035a6 <vector246>:
.globl vector246
vector246:
  pushl $0
c01035a6:	6a 00                	push   $0x0
  pushl $246
c01035a8:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c01035ad:	e9 6c 00 00 00       	jmp    c010361e <__alltraps>

c01035b2 <vector247>:
.globl vector247
vector247:
  pushl $0
c01035b2:	6a 00                	push   $0x0
  pushl $247
c01035b4:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c01035b9:	e9 60 00 00 00       	jmp    c010361e <__alltraps>

c01035be <vector248>:
.globl vector248
vector248:
  pushl $0
c01035be:	6a 00                	push   $0x0
  pushl $248
c01035c0:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c01035c5:	e9 54 00 00 00       	jmp    c010361e <__alltraps>

c01035ca <vector249>:
.globl vector249
vector249:
  pushl $0
c01035ca:	6a 00                	push   $0x0
  pushl $249
c01035cc:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c01035d1:	e9 48 00 00 00       	jmp    c010361e <__alltraps>

c01035d6 <vector250>:
.globl vector250
vector250:
  pushl $0
c01035d6:	6a 00                	push   $0x0
  pushl $250
c01035d8:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c01035dd:	e9 3c 00 00 00       	jmp    c010361e <__alltraps>

c01035e2 <vector251>:
.globl vector251
vector251:
  pushl $0
c01035e2:	6a 00                	push   $0x0
  pushl $251
c01035e4:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c01035e9:	e9 30 00 00 00       	jmp    c010361e <__alltraps>

c01035ee <vector252>:
.globl vector252
vector252:
  pushl $0
c01035ee:	6a 00                	push   $0x0
  pushl $252
c01035f0:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c01035f5:	e9 24 00 00 00       	jmp    c010361e <__alltraps>

c01035fa <vector253>:
.globl vector253
vector253:
  pushl $0
c01035fa:	6a 00                	push   $0x0
  pushl $253
c01035fc:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c0103601:	e9 18 00 00 00       	jmp    c010361e <__alltraps>

c0103606 <vector254>:
.globl vector254
vector254:
  pushl $0
c0103606:	6a 00                	push   $0x0
  pushl $254
c0103608:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c010360d:	e9 0c 00 00 00       	jmp    c010361e <__alltraps>

c0103612 <vector255>:
.globl vector255
vector255:
  pushl $0
c0103612:	6a 00                	push   $0x0
  pushl $255
c0103614:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c0103619:	e9 00 00 00 00       	jmp    c010361e <__alltraps>

c010361e <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c010361e:	1e                   	push   %ds
    pushl %es
c010361f:	06                   	push   %es
    pushl %fs
c0103620:	0f a0                	push   %fs
    pushl %gs
c0103622:	0f a8                	push   %gs
    pushal
c0103624:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0103625:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c010362a:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c010362c:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c010362e:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c010362f:	e8 e9 f4 ff ff       	call   c0102b1d <trap>

    # pop the pushed stack pointer
    popl %esp
c0103634:	5c                   	pop    %esp

c0103635 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0103635:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0103636:	0f a9                	pop    %gs
    popl %fs
c0103638:	0f a1                	pop    %fs
    popl %es
c010363a:	07                   	pop    %es
    popl %ds
c010363b:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c010363c:	83 c4 08             	add    $0x8,%esp
    iret
c010363f:	cf                   	iret   

c0103640 <forkrets>:

.globl forkrets
forkrets:
    # set stack to this new process's trapframe
    movl 4(%esp), %esp
c0103640:	8b 64 24 04          	mov    0x4(%esp),%esp
    jmp __trapret
c0103644:	eb ef                	jmp    c0103635 <__trapret>

c0103646 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0103646:	55                   	push   %ebp
c0103647:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0103649:	a1 60 40 1b c0       	mov    0xc01b4060,%eax
c010364e:	8b 55 08             	mov    0x8(%ebp),%edx
c0103651:	29 c2                	sub    %eax,%edx
c0103653:	89 d0                	mov    %edx,%eax
c0103655:	c1 f8 05             	sar    $0x5,%eax
}
c0103658:	5d                   	pop    %ebp
c0103659:	c3                   	ret    

c010365a <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c010365a:	55                   	push   %ebp
c010365b:	89 e5                	mov    %esp,%ebp
c010365d:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0103660:	8b 45 08             	mov    0x8(%ebp),%eax
c0103663:	89 04 24             	mov    %eax,(%esp)
c0103666:	e8 db ff ff ff       	call   c0103646 <page2ppn>
c010366b:	c1 e0 0c             	shl    $0xc,%eax
}
c010366e:	c9                   	leave  
c010366f:	c3                   	ret    

c0103670 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c0103670:	55                   	push   %ebp
c0103671:	89 e5                	mov    %esp,%ebp
c0103673:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0103676:	8b 45 08             	mov    0x8(%ebp),%eax
c0103679:	c1 e8 0c             	shr    $0xc,%eax
c010367c:	89 c2                	mov    %eax,%edx
c010367e:	a1 80 1f 1b c0       	mov    0xc01b1f80,%eax
c0103683:	39 c2                	cmp    %eax,%edx
c0103685:	72 1c                	jb     c01036a3 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0103687:	c7 44 24 08 d0 cc 10 	movl   $0xc010ccd0,0x8(%esp)
c010368e:	c0 
c010368f:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c0103696:	00 
c0103697:	c7 04 24 ef cc 10 c0 	movl   $0xc010ccef,(%esp)
c010369e:	e8 9a cd ff ff       	call   c010043d <__panic>
    }
    return &pages[PPN(pa)];
c01036a3:	a1 60 40 1b c0       	mov    0xc01b4060,%eax
c01036a8:	8b 55 08             	mov    0x8(%ebp),%edx
c01036ab:	c1 ea 0c             	shr    $0xc,%edx
c01036ae:	c1 e2 05             	shl    $0x5,%edx
c01036b1:	01 d0                	add    %edx,%eax
}
c01036b3:	c9                   	leave  
c01036b4:	c3                   	ret    

c01036b5 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c01036b5:	55                   	push   %ebp
c01036b6:	89 e5                	mov    %esp,%ebp
c01036b8:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c01036bb:	8b 45 08             	mov    0x8(%ebp),%eax
c01036be:	89 04 24             	mov    %eax,(%esp)
c01036c1:	e8 94 ff ff ff       	call   c010365a <page2pa>
c01036c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01036c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036cc:	c1 e8 0c             	shr    $0xc,%eax
c01036cf:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01036d2:	a1 80 1f 1b c0       	mov    0xc01b1f80,%eax
c01036d7:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01036da:	72 23                	jb     c01036ff <page2kva+0x4a>
c01036dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036df:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01036e3:	c7 44 24 08 00 cd 10 	movl   $0xc010cd00,0x8(%esp)
c01036ea:	c0 
c01036eb:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c01036f2:	00 
c01036f3:	c7 04 24 ef cc 10 c0 	movl   $0xc010ccef,(%esp)
c01036fa:	e8 3e cd ff ff       	call   c010043d <__panic>
c01036ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103702:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0103707:	c9                   	leave  
c0103708:	c3                   	ret    

c0103709 <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c0103709:	55                   	push   %ebp
c010370a:	89 e5                	mov    %esp,%ebp
c010370c:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c010370f:	8b 45 08             	mov    0x8(%ebp),%eax
c0103712:	83 e0 01             	and    $0x1,%eax
c0103715:	85 c0                	test   %eax,%eax
c0103717:	75 1c                	jne    c0103735 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0103719:	c7 44 24 08 24 cd 10 	movl   $0xc010cd24,0x8(%esp)
c0103720:	c0 
c0103721:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c0103728:	00 
c0103729:	c7 04 24 ef cc 10 c0 	movl   $0xc010ccef,(%esp)
c0103730:	e8 08 cd ff ff       	call   c010043d <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c0103735:	8b 45 08             	mov    0x8(%ebp),%eax
c0103738:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010373d:	89 04 24             	mov    %eax,(%esp)
c0103740:	e8 2b ff ff ff       	call   c0103670 <pa2page>
}
c0103745:	c9                   	leave  
c0103746:	c3                   	ret    

c0103747 <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
c0103747:	55                   	push   %ebp
c0103748:	89 e5                	mov    %esp,%ebp
c010374a:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c010374d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103750:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103755:	89 04 24             	mov    %eax,(%esp)
c0103758:	e8 13 ff ff ff       	call   c0103670 <pa2page>
}
c010375d:	c9                   	leave  
c010375e:	c3                   	ret    

c010375f <page_ref>:

static inline int
page_ref(struct Page *page) {
c010375f:	55                   	push   %ebp
c0103760:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0103762:	8b 45 08             	mov    0x8(%ebp),%eax
c0103765:	8b 00                	mov    (%eax),%eax
}
c0103767:	5d                   	pop    %ebp
c0103768:	c3                   	ret    

c0103769 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0103769:	55                   	push   %ebp
c010376a:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c010376c:	8b 45 08             	mov    0x8(%ebp),%eax
c010376f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103772:	89 10                	mov    %edx,(%eax)
}
c0103774:	90                   	nop
c0103775:	5d                   	pop    %ebp
c0103776:	c3                   	ret    

c0103777 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c0103777:	55                   	push   %ebp
c0103778:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c010377a:	8b 45 08             	mov    0x8(%ebp),%eax
c010377d:	8b 00                	mov    (%eax),%eax
c010377f:	8d 50 01             	lea    0x1(%eax),%edx
c0103782:	8b 45 08             	mov    0x8(%ebp),%eax
c0103785:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0103787:	8b 45 08             	mov    0x8(%ebp),%eax
c010378a:	8b 00                	mov    (%eax),%eax
}
c010378c:	5d                   	pop    %ebp
c010378d:	c3                   	ret    

c010378e <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c010378e:	55                   	push   %ebp
c010378f:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c0103791:	8b 45 08             	mov    0x8(%ebp),%eax
c0103794:	8b 00                	mov    (%eax),%eax
c0103796:	8d 50 ff             	lea    -0x1(%eax),%edx
c0103799:	8b 45 08             	mov    0x8(%ebp),%eax
c010379c:	89 10                	mov    %edx,(%eax)
    return page->ref;
c010379e:	8b 45 08             	mov    0x8(%ebp),%eax
c01037a1:	8b 00                	mov    (%eax),%eax
}
c01037a3:	5d                   	pop    %ebp
c01037a4:	c3                   	ret    

c01037a5 <__intr_save>:
__intr_save(void) {
c01037a5:	55                   	push   %ebp
c01037a6:	89 e5                	mov    %esp,%ebp
c01037a8:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c01037ab:	9c                   	pushf  
c01037ac:	58                   	pop    %eax
c01037ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c01037b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c01037b3:	25 00 02 00 00       	and    $0x200,%eax
c01037b8:	85 c0                	test   %eax,%eax
c01037ba:	74 0c                	je     c01037c8 <__intr_save+0x23>
        intr_disable();
c01037bc:	e8 37 eb ff ff       	call   c01022f8 <intr_disable>
        return 1;
c01037c1:	b8 01 00 00 00       	mov    $0x1,%eax
c01037c6:	eb 05                	jmp    c01037cd <__intr_save+0x28>
    return 0;
c01037c8:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01037cd:	c9                   	leave  
c01037ce:	c3                   	ret    

c01037cf <__intr_restore>:
__intr_restore(bool flag) {
c01037cf:	55                   	push   %ebp
c01037d0:	89 e5                	mov    %esp,%ebp
c01037d2:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c01037d5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01037d9:	74 05                	je     c01037e0 <__intr_restore+0x11>
        intr_enable();
c01037db:	e8 0c eb ff ff       	call   c01022ec <intr_enable>
}
c01037e0:	90                   	nop
c01037e1:	c9                   	leave  
c01037e2:	c3                   	ret    

c01037e3 <lgdt>:
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd)
{
c01037e3:	55                   	push   %ebp
c01037e4:	89 e5                	mov    %esp,%ebp
    asm volatile("lgdt (%0)" ::"r"(pd));
c01037e6:	8b 45 08             	mov    0x8(%ebp),%eax
c01037e9:	0f 01 10             	lgdtl  (%eax)
    asm volatile("movw %%ax, %%gs" ::"a"(USER_DS));
c01037ec:	b8 23 00 00 00       	mov    $0x23,%eax
c01037f1:	8e e8                	mov    %eax,%gs
    asm volatile("movw %%ax, %%fs" ::"a"(USER_DS));
c01037f3:	b8 23 00 00 00       	mov    $0x23,%eax
c01037f8:	8e e0                	mov    %eax,%fs
    asm volatile("movw %%ax, %%es" ::"a"(KERNEL_DS));
c01037fa:	b8 10 00 00 00       	mov    $0x10,%eax
c01037ff:	8e c0                	mov    %eax,%es
    asm volatile("movw %%ax, %%ds" ::"a"(KERNEL_DS));
c0103801:	b8 10 00 00 00       	mov    $0x10,%eax
c0103806:	8e d8                	mov    %eax,%ds
    asm volatile("movw %%ax, %%ss" ::"a"(KERNEL_DS));
c0103808:	b8 10 00 00 00       	mov    $0x10,%eax
c010380d:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile("ljmp %0, $1f\n 1:\n" ::"i"(KERNEL_CS));
c010380f:	ea 16 38 10 c0 08 00 	ljmp   $0x8,$0xc0103816
}
c0103816:	90                   	nop
c0103817:	5d                   	pop    %ebp
c0103818:	c3                   	ret    

c0103819 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void load_esp0(uintptr_t esp0)
{
c0103819:	f3 0f 1e fb          	endbr32 
c010381d:	55                   	push   %ebp
c010381e:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0103820:	8b 45 08             	mov    0x8(%ebp),%eax
c0103823:	a3 a4 1f 1b c0       	mov    %eax,0xc01b1fa4
}
c0103828:	90                   	nop
c0103829:	5d                   	pop    %ebp
c010382a:	c3                   	ret    

c010382b <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void)
{
c010382b:	f3 0f 1e fb          	endbr32 
c010382f:	55                   	push   %ebp
c0103830:	89 e5                	mov    %esp,%ebp
c0103832:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0103835:	b8 00 e0 12 c0       	mov    $0xc012e000,%eax
c010383a:	89 04 24             	mov    %eax,(%esp)
c010383d:	e8 d7 ff ff ff       	call   c0103819 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0103842:	66 c7 05 a8 1f 1b c0 	movw   $0x10,0xc01b1fa8
c0103849:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c010384b:	66 c7 05 28 ea 12 c0 	movw   $0x68,0xc012ea28
c0103852:	68 00 
c0103854:	b8 a0 1f 1b c0       	mov    $0xc01b1fa0,%eax
c0103859:	0f b7 c0             	movzwl %ax,%eax
c010385c:	66 a3 2a ea 12 c0    	mov    %ax,0xc012ea2a
c0103862:	b8 a0 1f 1b c0       	mov    $0xc01b1fa0,%eax
c0103867:	c1 e8 10             	shr    $0x10,%eax
c010386a:	a2 2c ea 12 c0       	mov    %al,0xc012ea2c
c010386f:	0f b6 05 2d ea 12 c0 	movzbl 0xc012ea2d,%eax
c0103876:	24 f0                	and    $0xf0,%al
c0103878:	0c 09                	or     $0x9,%al
c010387a:	a2 2d ea 12 c0       	mov    %al,0xc012ea2d
c010387f:	0f b6 05 2d ea 12 c0 	movzbl 0xc012ea2d,%eax
c0103886:	24 ef                	and    $0xef,%al
c0103888:	a2 2d ea 12 c0       	mov    %al,0xc012ea2d
c010388d:	0f b6 05 2d ea 12 c0 	movzbl 0xc012ea2d,%eax
c0103894:	24 9f                	and    $0x9f,%al
c0103896:	a2 2d ea 12 c0       	mov    %al,0xc012ea2d
c010389b:	0f b6 05 2d ea 12 c0 	movzbl 0xc012ea2d,%eax
c01038a2:	0c 80                	or     $0x80,%al
c01038a4:	a2 2d ea 12 c0       	mov    %al,0xc012ea2d
c01038a9:	0f b6 05 2e ea 12 c0 	movzbl 0xc012ea2e,%eax
c01038b0:	24 f0                	and    $0xf0,%al
c01038b2:	a2 2e ea 12 c0       	mov    %al,0xc012ea2e
c01038b7:	0f b6 05 2e ea 12 c0 	movzbl 0xc012ea2e,%eax
c01038be:	24 ef                	and    $0xef,%al
c01038c0:	a2 2e ea 12 c0       	mov    %al,0xc012ea2e
c01038c5:	0f b6 05 2e ea 12 c0 	movzbl 0xc012ea2e,%eax
c01038cc:	24 df                	and    $0xdf,%al
c01038ce:	a2 2e ea 12 c0       	mov    %al,0xc012ea2e
c01038d3:	0f b6 05 2e ea 12 c0 	movzbl 0xc012ea2e,%eax
c01038da:	0c 40                	or     $0x40,%al
c01038dc:	a2 2e ea 12 c0       	mov    %al,0xc012ea2e
c01038e1:	0f b6 05 2e ea 12 c0 	movzbl 0xc012ea2e,%eax
c01038e8:	24 7f                	and    $0x7f,%al
c01038ea:	a2 2e ea 12 c0       	mov    %al,0xc012ea2e
c01038ef:	b8 a0 1f 1b c0       	mov    $0xc01b1fa0,%eax
c01038f4:	c1 e8 18             	shr    $0x18,%eax
c01038f7:	a2 2f ea 12 c0       	mov    %al,0xc012ea2f

    // reload all segment registers
    lgdt(&gdt_pd);
c01038fc:	c7 04 24 30 ea 12 c0 	movl   $0xc012ea30,(%esp)
c0103903:	e8 db fe ff ff       	call   c01037e3 <lgdt>
c0103908:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c010390e:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0103912:	0f 00 d8             	ltr    %ax
}
c0103915:	90                   	nop

    // load the TSS
    ltr(GD_TSS);
}
c0103916:	90                   	nop
c0103917:	c9                   	leave  
c0103918:	c3                   	ret    

c0103919 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void)
{
c0103919:	f3 0f 1e fb          	endbr32 
c010391d:	55                   	push   %ebp
c010391e:	89 e5                	mov    %esp,%ebp
c0103920:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c0103923:	c7 05 58 40 1b c0 70 	movl   $0xc010e370,0xc01b4058
c010392a:	e3 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c010392d:	a1 58 40 1b c0       	mov    0xc01b4058,%eax
c0103932:	8b 00                	mov    (%eax),%eax
c0103934:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103938:	c7 04 24 50 cd 10 c0 	movl   $0xc010cd50,(%esp)
c010393f:	e8 8d c9 ff ff       	call   c01002d1 <cprintf>
    pmm_manager->init();
c0103944:	a1 58 40 1b c0       	mov    0xc01b4058,%eax
c0103949:	8b 40 04             	mov    0x4(%eax),%eax
c010394c:	ff d0                	call   *%eax
}
c010394e:	90                   	nop
c010394f:	c9                   	leave  
c0103950:	c3                   	ret    

c0103951 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory
static void
init_memmap(struct Page *base, size_t n)
{
c0103951:	f3 0f 1e fb          	endbr32 
c0103955:	55                   	push   %ebp
c0103956:	89 e5                	mov    %esp,%ebp
c0103958:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c010395b:	a1 58 40 1b c0       	mov    0xc01b4058,%eax
c0103960:	8b 40 08             	mov    0x8(%eax),%eax
c0103963:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103966:	89 54 24 04          	mov    %edx,0x4(%esp)
c010396a:	8b 55 08             	mov    0x8(%ebp),%edx
c010396d:	89 14 24             	mov    %edx,(%esp)
c0103970:	ff d0                	call   *%eax
}
c0103972:	90                   	nop
c0103973:	c9                   	leave  
c0103974:	c3                   	ret    

c0103975 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory
struct Page *
alloc_pages(size_t n)
{
c0103975:	f3 0f 1e fb          	endbr32 
c0103979:	55                   	push   %ebp
c010397a:	89 e5                	mov    %esp,%ebp
c010397c:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = NULL;
c010397f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;

    while (1)
    {
        local_intr_save(intr_flag);
c0103986:	e8 1a fe ff ff       	call   c01037a5 <__intr_save>
c010398b:	89 45 f0             	mov    %eax,-0x10(%ebp)
        {
            page = pmm_manager->alloc_pages(n);
c010398e:	a1 58 40 1b c0       	mov    0xc01b4058,%eax
c0103993:	8b 40 0c             	mov    0xc(%eax),%eax
c0103996:	8b 55 08             	mov    0x8(%ebp),%edx
c0103999:	89 14 24             	mov    %edx,(%esp)
c010399c:	ff d0                	call   *%eax
c010399e:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        local_intr_restore(intr_flag);
c01039a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01039a4:	89 04 24             	mov    %eax,(%esp)
c01039a7:	e8 23 fe ff ff       	call   c01037cf <__intr_restore>

        if (page != NULL || n > 1 || swap_init_ok == 0)
c01039ac:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01039b0:	75 2d                	jne    c01039df <alloc_pages+0x6a>
c01039b2:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
c01039b6:	77 27                	ja     c01039df <alloc_pages+0x6a>
c01039b8:	a1 10 20 1b c0       	mov    0xc01b2010,%eax
c01039bd:	85 c0                	test   %eax,%eax
c01039bf:	74 1e                	je     c01039df <alloc_pages+0x6a>
            break;

        extern struct mm_struct *check_mm_struct;
        //cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
c01039c1:	8b 55 08             	mov    0x8(%ebp),%edx
c01039c4:	a1 64 40 1b c0       	mov    0xc01b4064,%eax
c01039c9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01039d0:	00 
c01039d1:	89 54 24 04          	mov    %edx,0x4(%esp)
c01039d5:	89 04 24             	mov    %eax,(%esp)
c01039d8:	e8 55 30 00 00       	call   c0106a32 <swap_out>
    {
c01039dd:	eb a7                	jmp    c0103986 <alloc_pages+0x11>
    }
    //cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
c01039df:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01039e2:	c9                   	leave  
c01039e3:	c3                   	ret    

c01039e4 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n)
{
c01039e4:	f3 0f 1e fb          	endbr32 
c01039e8:	55                   	push   %ebp
c01039e9:	89 e5                	mov    %esp,%ebp
c01039eb:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c01039ee:	e8 b2 fd ff ff       	call   c01037a5 <__intr_save>
c01039f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c01039f6:	a1 58 40 1b c0       	mov    0xc01b4058,%eax
c01039fb:	8b 40 10             	mov    0x10(%eax),%eax
c01039fe:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103a01:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103a05:	8b 55 08             	mov    0x8(%ebp),%edx
c0103a08:	89 14 24             	mov    %edx,(%esp)
c0103a0b:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c0103a0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a10:	89 04 24             	mov    %eax,(%esp)
c0103a13:	e8 b7 fd ff ff       	call   c01037cf <__intr_restore>
}
c0103a18:	90                   	nop
c0103a19:	c9                   	leave  
c0103a1a:	c3                   	ret    

c0103a1b <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE)
//of current free memory
size_t
nr_free_pages(void)
{
c0103a1b:	f3 0f 1e fb          	endbr32 
c0103a1f:	55                   	push   %ebp
c0103a20:	89 e5                	mov    %esp,%ebp
c0103a22:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c0103a25:	e8 7b fd ff ff       	call   c01037a5 <__intr_save>
c0103a2a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c0103a2d:	a1 58 40 1b c0       	mov    0xc01b4058,%eax
c0103a32:	8b 40 14             	mov    0x14(%eax),%eax
c0103a35:	ff d0                	call   *%eax
c0103a37:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c0103a3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a3d:	89 04 24             	mov    %eax,(%esp)
c0103a40:	e8 8a fd ff ff       	call   c01037cf <__intr_restore>
    return ret;
c0103a45:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0103a48:	c9                   	leave  
c0103a49:	c3                   	ret    

c0103a4a <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void)
{
c0103a4a:	f3 0f 1e fb          	endbr32 
c0103a4e:	55                   	push   %ebp
c0103a4f:	89 e5                	mov    %esp,%ebp
c0103a51:	57                   	push   %edi
c0103a52:	56                   	push   %esi
c0103a53:	53                   	push   %ebx
c0103a54:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0103a5a:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0103a61:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0103a68:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0103a6f:	c7 04 24 67 cd 10 c0 	movl   $0xc010cd67,(%esp)
c0103a76:	e8 56 c8 ff ff       	call   c01002d1 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i++)
c0103a7b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0103a82:	e9 1a 01 00 00       	jmp    c0103ba1 <page_init+0x157>
    {
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0103a87:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103a8a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103a8d:	89 d0                	mov    %edx,%eax
c0103a8f:	c1 e0 02             	shl    $0x2,%eax
c0103a92:	01 d0                	add    %edx,%eax
c0103a94:	c1 e0 02             	shl    $0x2,%eax
c0103a97:	01 c8                	add    %ecx,%eax
c0103a99:	8b 50 08             	mov    0x8(%eax),%edx
c0103a9c:	8b 40 04             	mov    0x4(%eax),%eax
c0103a9f:	89 45 a0             	mov    %eax,-0x60(%ebp)
c0103aa2:	89 55 a4             	mov    %edx,-0x5c(%ebp)
c0103aa5:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103aa8:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103aab:	89 d0                	mov    %edx,%eax
c0103aad:	c1 e0 02             	shl    $0x2,%eax
c0103ab0:	01 d0                	add    %edx,%eax
c0103ab2:	c1 e0 02             	shl    $0x2,%eax
c0103ab5:	01 c8                	add    %ecx,%eax
c0103ab7:	8b 48 0c             	mov    0xc(%eax),%ecx
c0103aba:	8b 58 10             	mov    0x10(%eax),%ebx
c0103abd:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0103ac0:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0103ac3:	01 c8                	add    %ecx,%eax
c0103ac5:	11 da                	adc    %ebx,%edx
c0103ac7:	89 45 98             	mov    %eax,-0x68(%ebp)
c0103aca:	89 55 9c             	mov    %edx,-0x64(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0103acd:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103ad0:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103ad3:	89 d0                	mov    %edx,%eax
c0103ad5:	c1 e0 02             	shl    $0x2,%eax
c0103ad8:	01 d0                	add    %edx,%eax
c0103ada:	c1 e0 02             	shl    $0x2,%eax
c0103add:	01 c8                	add    %ecx,%eax
c0103adf:	83 c0 14             	add    $0x14,%eax
c0103ae2:	8b 00                	mov    (%eax),%eax
c0103ae4:	89 45 84             	mov    %eax,-0x7c(%ebp)
c0103ae7:	8b 45 98             	mov    -0x68(%ebp),%eax
c0103aea:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0103aed:	83 c0 ff             	add    $0xffffffff,%eax
c0103af0:	83 d2 ff             	adc    $0xffffffff,%edx
c0103af3:	89 85 78 ff ff ff    	mov    %eax,-0x88(%ebp)
c0103af9:	89 95 7c ff ff ff    	mov    %edx,-0x84(%ebp)
c0103aff:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103b02:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103b05:	89 d0                	mov    %edx,%eax
c0103b07:	c1 e0 02             	shl    $0x2,%eax
c0103b0a:	01 d0                	add    %edx,%eax
c0103b0c:	c1 e0 02             	shl    $0x2,%eax
c0103b0f:	01 c8                	add    %ecx,%eax
c0103b11:	8b 48 0c             	mov    0xc(%eax),%ecx
c0103b14:	8b 58 10             	mov    0x10(%eax),%ebx
c0103b17:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0103b1a:	89 54 24 1c          	mov    %edx,0x1c(%esp)
c0103b1e:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
c0103b24:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
c0103b2a:	89 44 24 14          	mov    %eax,0x14(%esp)
c0103b2e:	89 54 24 18          	mov    %edx,0x18(%esp)
c0103b32:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0103b35:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0103b38:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103b3c:	89 54 24 10          	mov    %edx,0x10(%esp)
c0103b40:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0103b44:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c0103b48:	c7 04 24 74 cd 10 c0 	movl   $0xc010cd74,(%esp)
c0103b4f:	e8 7d c7 ff ff       	call   c01002d1 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM)
c0103b54:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103b57:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103b5a:	89 d0                	mov    %edx,%eax
c0103b5c:	c1 e0 02             	shl    $0x2,%eax
c0103b5f:	01 d0                	add    %edx,%eax
c0103b61:	c1 e0 02             	shl    $0x2,%eax
c0103b64:	01 c8                	add    %ecx,%eax
c0103b66:	83 c0 14             	add    $0x14,%eax
c0103b69:	8b 00                	mov    (%eax),%eax
c0103b6b:	83 f8 01             	cmp    $0x1,%eax
c0103b6e:	75 2e                	jne    c0103b9e <page_init+0x154>
        {
            if (maxpa < end && begin < KMEMSIZE)
c0103b70:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103b73:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103b76:	3b 45 98             	cmp    -0x68(%ebp),%eax
c0103b79:	89 d0                	mov    %edx,%eax
c0103b7b:	1b 45 9c             	sbb    -0x64(%ebp),%eax
c0103b7e:	73 1e                	jae    c0103b9e <page_init+0x154>
c0103b80:	ba ff ff ff 37       	mov    $0x37ffffff,%edx
c0103b85:	b8 00 00 00 00       	mov    $0x0,%eax
c0103b8a:	3b 55 a0             	cmp    -0x60(%ebp),%edx
c0103b8d:	1b 45 a4             	sbb    -0x5c(%ebp),%eax
c0103b90:	72 0c                	jb     c0103b9e <page_init+0x154>
            {
                maxpa = end;
c0103b92:	8b 45 98             	mov    -0x68(%ebp),%eax
c0103b95:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0103b98:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0103b9b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i++)
c0103b9e:	ff 45 dc             	incl   -0x24(%ebp)
c0103ba1:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103ba4:	8b 00                	mov    (%eax),%eax
c0103ba6:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0103ba9:	0f 8c d8 fe ff ff    	jl     c0103a87 <page_init+0x3d>
            }
        }
    }
    if (maxpa > KMEMSIZE)
c0103baf:	ba 00 00 00 38       	mov    $0x38000000,%edx
c0103bb4:	b8 00 00 00 00       	mov    $0x0,%eax
c0103bb9:	3b 55 e0             	cmp    -0x20(%ebp),%edx
c0103bbc:	1b 45 e4             	sbb    -0x1c(%ebp),%eax
c0103bbf:	73 0e                	jae    c0103bcf <page_init+0x185>
    {
        maxpa = KMEMSIZE;
c0103bc1:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c0103bc8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c0103bcf:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103bd2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103bd5:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0103bd9:	c1 ea 0c             	shr    $0xc,%edx
c0103bdc:	a3 80 1f 1b c0       	mov    %eax,0xc01b1f80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c0103be1:	c7 45 c0 00 10 00 00 	movl   $0x1000,-0x40(%ebp)
c0103be8:	b8 60 41 1b c0       	mov    $0xc01b4160,%eax
c0103bed:	8d 50 ff             	lea    -0x1(%eax),%edx
c0103bf0:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0103bf3:	01 d0                	add    %edx,%eax
c0103bf5:	89 45 bc             	mov    %eax,-0x44(%ebp)
c0103bf8:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0103bfb:	ba 00 00 00 00       	mov    $0x0,%edx
c0103c00:	f7 75 c0             	divl   -0x40(%ebp)
c0103c03:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0103c06:	29 d0                	sub    %edx,%eax
c0103c08:	a3 60 40 1b c0       	mov    %eax,0xc01b4060

    for (i = 0; i < npage; i++)
c0103c0d:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0103c14:	eb 27                	jmp    c0103c3d <page_init+0x1f3>
    {
        SetPageReserved(pages + i);
c0103c16:	a1 60 40 1b c0       	mov    0xc01b4060,%eax
c0103c1b:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103c1e:	c1 e2 05             	shl    $0x5,%edx
c0103c21:	01 d0                	add    %edx,%eax
c0103c23:	83 c0 04             	add    $0x4,%eax
c0103c26:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
c0103c2d:	89 45 90             	mov    %eax,-0x70(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103c30:	8b 45 90             	mov    -0x70(%ebp),%eax
c0103c33:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0103c36:	0f ab 10             	bts    %edx,(%eax)
}
c0103c39:	90                   	nop
    for (i = 0; i < npage; i++)
c0103c3a:	ff 45 dc             	incl   -0x24(%ebp)
c0103c3d:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103c40:	a1 80 1f 1b c0       	mov    0xc01b1f80,%eax
c0103c45:	39 c2                	cmp    %eax,%edx
c0103c47:	72 cd                	jb     c0103c16 <page_init+0x1cc>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c0103c49:	a1 80 1f 1b c0       	mov    0xc01b1f80,%eax
c0103c4e:	c1 e0 05             	shl    $0x5,%eax
c0103c51:	89 c2                	mov    %eax,%edx
c0103c53:	a1 60 40 1b c0       	mov    0xc01b4060,%eax
c0103c58:	01 d0                	add    %edx,%eax
c0103c5a:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0103c5d:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
c0103c64:	77 23                	ja     c0103c89 <page_init+0x23f>
c0103c66:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0103c69:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103c6d:	c7 44 24 08 a4 cd 10 	movl   $0xc010cda4,0x8(%esp)
c0103c74:	c0 
c0103c75:	c7 44 24 04 f6 00 00 	movl   $0xf6,0x4(%esp)
c0103c7c:	00 
c0103c7d:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c0103c84:	e8 b4 c7 ff ff       	call   c010043d <__panic>
c0103c89:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0103c8c:	05 00 00 00 40       	add    $0x40000000,%eax
c0103c91:	89 45 b4             	mov    %eax,-0x4c(%ebp)

    for (i = 0; i < memmap->nr_map; i++)
c0103c94:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0103c9b:	e9 4b 01 00 00       	jmp    c0103deb <page_init+0x3a1>
    {
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0103ca0:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103ca3:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103ca6:	89 d0                	mov    %edx,%eax
c0103ca8:	c1 e0 02             	shl    $0x2,%eax
c0103cab:	01 d0                	add    %edx,%eax
c0103cad:	c1 e0 02             	shl    $0x2,%eax
c0103cb0:	01 c8                	add    %ecx,%eax
c0103cb2:	8b 50 08             	mov    0x8(%eax),%edx
c0103cb5:	8b 40 04             	mov    0x4(%eax),%eax
c0103cb8:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0103cbb:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0103cbe:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103cc1:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103cc4:	89 d0                	mov    %edx,%eax
c0103cc6:	c1 e0 02             	shl    $0x2,%eax
c0103cc9:	01 d0                	add    %edx,%eax
c0103ccb:	c1 e0 02             	shl    $0x2,%eax
c0103cce:	01 c8                	add    %ecx,%eax
c0103cd0:	8b 48 0c             	mov    0xc(%eax),%ecx
c0103cd3:	8b 58 10             	mov    0x10(%eax),%ebx
c0103cd6:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103cd9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103cdc:	01 c8                	add    %ecx,%eax
c0103cde:	11 da                	adc    %ebx,%edx
c0103ce0:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0103ce3:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM)
c0103ce6:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103ce9:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103cec:	89 d0                	mov    %edx,%eax
c0103cee:	c1 e0 02             	shl    $0x2,%eax
c0103cf1:	01 d0                	add    %edx,%eax
c0103cf3:	c1 e0 02             	shl    $0x2,%eax
c0103cf6:	01 c8                	add    %ecx,%eax
c0103cf8:	83 c0 14             	add    $0x14,%eax
c0103cfb:	8b 00                	mov    (%eax),%eax
c0103cfd:	83 f8 01             	cmp    $0x1,%eax
c0103d00:	0f 85 e2 00 00 00    	jne    c0103de8 <page_init+0x39e>
        {
            if (begin < freemem)
c0103d06:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103d09:	ba 00 00 00 00       	mov    $0x0,%edx
c0103d0e:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c0103d11:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c0103d14:	19 d1                	sbb    %edx,%ecx
c0103d16:	73 0d                	jae    c0103d25 <page_init+0x2db>
            {
                begin = freemem;
c0103d18:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103d1b:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0103d1e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE)
c0103d25:	ba 00 00 00 38       	mov    $0x38000000,%edx
c0103d2a:	b8 00 00 00 00       	mov    $0x0,%eax
c0103d2f:	3b 55 c8             	cmp    -0x38(%ebp),%edx
c0103d32:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c0103d35:	73 0e                	jae    c0103d45 <page_init+0x2fb>
            {
                end = KMEMSIZE;
c0103d37:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c0103d3e:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end)
c0103d45:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103d48:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103d4b:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0103d4e:	89 d0                	mov    %edx,%eax
c0103d50:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c0103d53:	0f 83 8f 00 00 00    	jae    c0103de8 <page_init+0x39e>
            {
                begin = ROUNDUP(begin, PGSIZE);
c0103d59:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
c0103d60:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0103d63:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0103d66:	01 d0                	add    %edx,%eax
c0103d68:	48                   	dec    %eax
c0103d69:	89 45 ac             	mov    %eax,-0x54(%ebp)
c0103d6c:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0103d6f:	ba 00 00 00 00       	mov    $0x0,%edx
c0103d74:	f7 75 b0             	divl   -0x50(%ebp)
c0103d77:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0103d7a:	29 d0                	sub    %edx,%eax
c0103d7c:	ba 00 00 00 00       	mov    $0x0,%edx
c0103d81:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0103d84:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c0103d87:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103d8a:	89 45 a8             	mov    %eax,-0x58(%ebp)
c0103d8d:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0103d90:	ba 00 00 00 00       	mov    $0x0,%edx
c0103d95:	89 c3                	mov    %eax,%ebx
c0103d97:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
c0103d9d:	89 de                	mov    %ebx,%esi
c0103d9f:	89 d0                	mov    %edx,%eax
c0103da1:	83 e0 00             	and    $0x0,%eax
c0103da4:	89 c7                	mov    %eax,%edi
c0103da6:	89 75 c8             	mov    %esi,-0x38(%ebp)
c0103da9:	89 7d cc             	mov    %edi,-0x34(%ebp)
                if (begin < end)
c0103dac:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103daf:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103db2:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0103db5:	89 d0                	mov    %edx,%eax
c0103db7:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c0103dba:	73 2c                	jae    c0103de8 <page_init+0x39e>
                {
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c0103dbc:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103dbf:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0103dc2:	2b 45 d0             	sub    -0x30(%ebp),%eax
c0103dc5:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
c0103dc8:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0103dcc:	c1 ea 0c             	shr    $0xc,%edx
c0103dcf:	89 c3                	mov    %eax,%ebx
c0103dd1:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103dd4:	89 04 24             	mov    %eax,(%esp)
c0103dd7:	e8 94 f8 ff ff       	call   c0103670 <pa2page>
c0103ddc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0103de0:	89 04 24             	mov    %eax,(%esp)
c0103de3:	e8 69 fb ff ff       	call   c0103951 <init_memmap>
    for (i = 0; i < memmap->nr_map; i++)
c0103de8:	ff 45 dc             	incl   -0x24(%ebp)
c0103deb:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103dee:	8b 00                	mov    (%eax),%eax
c0103df0:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0103df3:	0f 8c a7 fe ff ff    	jl     c0103ca0 <page_init+0x256>
                }
            }
        }
    }
}
c0103df9:	90                   	nop
c0103dfa:	90                   	nop
c0103dfb:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c0103e01:	5b                   	pop    %ebx
c0103e02:	5e                   	pop    %esi
c0103e03:	5f                   	pop    %edi
c0103e04:	5d                   	pop    %ebp
c0103e05:	c3                   	ret    

c0103e06 <boot_map_segment>:
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm)
{
c0103e06:	f3 0f 1e fb          	endbr32 
c0103e0a:	55                   	push   %ebp
c0103e0b:	89 e5                	mov    %esp,%ebp
c0103e0d:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c0103e10:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103e13:	33 45 14             	xor    0x14(%ebp),%eax
c0103e16:	25 ff 0f 00 00       	and    $0xfff,%eax
c0103e1b:	85 c0                	test   %eax,%eax
c0103e1d:	74 24                	je     c0103e43 <boot_map_segment+0x3d>
c0103e1f:	c7 44 24 0c d6 cd 10 	movl   $0xc010cdd6,0xc(%esp)
c0103e26:	c0 
c0103e27:	c7 44 24 08 ed cd 10 	movl   $0xc010cded,0x8(%esp)
c0103e2e:	c0 
c0103e2f:	c7 44 24 04 1b 01 00 	movl   $0x11b,0x4(%esp)
c0103e36:	00 
c0103e37:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c0103e3e:	e8 fa c5 ff ff       	call   c010043d <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c0103e43:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c0103e4a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103e4d:	25 ff 0f 00 00       	and    $0xfff,%eax
c0103e52:	89 c2                	mov    %eax,%edx
c0103e54:	8b 45 10             	mov    0x10(%ebp),%eax
c0103e57:	01 c2                	add    %eax,%edx
c0103e59:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103e5c:	01 d0                	add    %edx,%eax
c0103e5e:	48                   	dec    %eax
c0103e5f:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103e62:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103e65:	ba 00 00 00 00       	mov    $0x0,%edx
c0103e6a:	f7 75 f0             	divl   -0x10(%ebp)
c0103e6d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103e70:	29 d0                	sub    %edx,%eax
c0103e72:	c1 e8 0c             	shr    $0xc,%eax
c0103e75:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c0103e78:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103e7b:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103e7e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103e81:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103e86:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c0103e89:	8b 45 14             	mov    0x14(%ebp),%eax
c0103e8c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103e8f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103e92:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103e97:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n--, la += PGSIZE, pa += PGSIZE)
c0103e9a:	eb 68                	jmp    c0103f04 <boot_map_segment+0xfe>
    {
        pte_t *ptep = get_pte(pgdir, la, 1);
c0103e9c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0103ea3:	00 
c0103ea4:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103ea7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103eab:	8b 45 08             	mov    0x8(%ebp),%eax
c0103eae:	89 04 24             	mov    %eax,(%esp)
c0103eb1:	e8 8f 01 00 00       	call   c0104045 <get_pte>
c0103eb6:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c0103eb9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0103ebd:	75 24                	jne    c0103ee3 <boot_map_segment+0xdd>
c0103ebf:	c7 44 24 0c 02 ce 10 	movl   $0xc010ce02,0xc(%esp)
c0103ec6:	c0 
c0103ec7:	c7 44 24 08 ed cd 10 	movl   $0xc010cded,0x8(%esp)
c0103ece:	c0 
c0103ecf:	c7 44 24 04 22 01 00 	movl   $0x122,0x4(%esp)
c0103ed6:	00 
c0103ed7:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c0103ede:	e8 5a c5 ff ff       	call   c010043d <__panic>
        *ptep = pa | PTE_P | perm;
c0103ee3:	8b 45 14             	mov    0x14(%ebp),%eax
c0103ee6:	0b 45 18             	or     0x18(%ebp),%eax
c0103ee9:	83 c8 01             	or     $0x1,%eax
c0103eec:	89 c2                	mov    %eax,%edx
c0103eee:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103ef1:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n--, la += PGSIZE, pa += PGSIZE)
c0103ef3:	ff 4d f4             	decl   -0xc(%ebp)
c0103ef6:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c0103efd:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c0103f04:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103f08:	75 92                	jne    c0103e9c <boot_map_segment+0x96>
    }
}
c0103f0a:	90                   	nop
c0103f0b:	90                   	nop
c0103f0c:	c9                   	leave  
c0103f0d:	c3                   	ret    

c0103f0e <boot_alloc_page>:
//boot_alloc_page - allocate one page using pmm->alloc_pages(1)
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void)
{
c0103f0e:	f3 0f 1e fb          	endbr32 
c0103f12:	55                   	push   %ebp
c0103f13:	89 e5                	mov    %esp,%ebp
c0103f15:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c0103f18:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103f1f:	e8 51 fa ff ff       	call   c0103975 <alloc_pages>
c0103f24:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL)
c0103f27:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103f2b:	75 1c                	jne    c0103f49 <boot_alloc_page+0x3b>
    {
        panic("boot_alloc_page failed.\n");
c0103f2d:	c7 44 24 08 0f ce 10 	movl   $0xc010ce0f,0x8(%esp)
c0103f34:	c0 
c0103f35:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
c0103f3c:	00 
c0103f3d:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c0103f44:	e8 f4 c4 ff ff       	call   c010043d <__panic>
    }
    return page2kva(p);
c0103f49:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103f4c:	89 04 24             	mov    %eax,(%esp)
c0103f4f:	e8 61 f7 ff ff       	call   c01036b5 <page2kva>
}
c0103f54:	c9                   	leave  
c0103f55:	c3                   	ret    

c0103f56 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void pmm_init(void)
{
c0103f56:	f3 0f 1e fb          	endbr32 
c0103f5a:	55                   	push   %ebp
c0103f5b:	89 e5                	mov    %esp,%ebp
c0103f5d:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c0103f60:	a1 e0 e9 12 c0       	mov    0xc012e9e0,%eax
c0103f65:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103f68:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0103f6f:	77 23                	ja     c0103f94 <pmm_init+0x3e>
c0103f71:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103f74:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103f78:	c7 44 24 08 a4 cd 10 	movl   $0xc010cda4,0x8(%esp)
c0103f7f:	c0 
c0103f80:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
c0103f87:	00 
c0103f88:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c0103f8f:	e8 a9 c4 ff ff       	call   c010043d <__panic>
c0103f94:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103f97:	05 00 00 00 40       	add    $0x40000000,%eax
c0103f9c:	a3 5c 40 1b c0       	mov    %eax,0xc01b405c
    //We need to alloc/free the physical memory (granularity is 4KB or other size).
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory.
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c0103fa1:	e8 73 f9 ff ff       	call   c0103919 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c0103fa6:	e8 9f fa ff ff       	call   c0103a4a <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c0103fab:	e8 fc 08 00 00       	call   c01048ac <check_alloc_page>

    check_pgdir();
c0103fb0:	e8 1a 09 00 00       	call   c01048cf <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c0103fb5:	a1 e0 e9 12 c0       	mov    0xc012e9e0,%eax
c0103fba:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103fbd:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0103fc4:	77 23                	ja     c0103fe9 <pmm_init+0x93>
c0103fc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103fc9:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103fcd:	c7 44 24 08 a4 cd 10 	movl   $0xc010cda4,0x8(%esp)
c0103fd4:	c0 
c0103fd5:	c7 44 24 04 50 01 00 	movl   $0x150,0x4(%esp)
c0103fdc:	00 
c0103fdd:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c0103fe4:	e8 54 c4 ff ff       	call   c010043d <__panic>
c0103fe9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103fec:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c0103ff2:	a1 e0 e9 12 c0       	mov    0xc012e9e0,%eax
c0103ff7:	05 ac 0f 00 00       	add    $0xfac,%eax
c0103ffc:	83 ca 03             	or     $0x3,%edx
c0103fff:	89 10                	mov    %edx,(%eax)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c0104001:	a1 e0 e9 12 c0       	mov    0xc012e9e0,%eax
c0104006:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c010400d:	00 
c010400e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0104015:	00 
c0104016:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c010401d:	38 
c010401e:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c0104025:	c0 
c0104026:	89 04 24             	mov    %eax,(%esp)
c0104029:	e8 d8 fd ff ff       	call   c0103e06 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c010402e:	e8 f8 f7 ff ff       	call   c010382b <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c0104033:	e8 37 0f 00 00       	call   c0104f6f <check_boot_pgdir>

    print_pgdir();
c0104038:	e8 e6 13 00 00       	call   c0105423 <print_pgdir>

    kmalloc_init();
c010403d:	e8 74 39 00 00       	call   c01079b6 <kmalloc_init>
}
c0104042:	90                   	nop
c0104043:	c9                   	leave  
c0104044:	c3                   	ret    

c0104045 <get_pte>:
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create)
{
c0104045:	f3 0f 1e fb          	endbr32 
c0104049:	55                   	push   %ebp
c010404a:	89 e5                	mov    %esp,%ebp
c010404c:	83 ec 38             	sub    $0x38,%esp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
    pde_t *pdep = &pgdir[PDX(la)];
c010404f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104052:	c1 e8 16             	shr    $0x16,%eax
c0104055:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010405c:	8b 45 08             	mov    0x8(%ebp),%eax
c010405f:	01 d0                	add    %edx,%eax
c0104061:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P))
c0104064:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104067:	8b 00                	mov    (%eax),%eax
c0104069:	83 e0 01             	and    $0x1,%eax
c010406c:	85 c0                	test   %eax,%eax
c010406e:	0f 85 af 00 00 00    	jne    c0104123 <get_pte+0xde>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
c0104074:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0104078:	74 15                	je     c010408f <get_pte+0x4a>
c010407a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104081:	e8 ef f8 ff ff       	call   c0103975 <alloc_pages>
c0104086:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104089:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010408d:	75 0a                	jne    c0104099 <get_pte+0x54>
        {
            return NULL;
c010408f:	b8 00 00 00 00       	mov    $0x0,%eax
c0104094:	e9 e7 00 00 00       	jmp    c0104180 <get_pte+0x13b>
        }
        set_page_ref(page, 1);
c0104099:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01040a0:	00 
c01040a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01040a4:	89 04 24             	mov    %eax,(%esp)
c01040a7:	e8 bd f6 ff ff       	call   c0103769 <set_page_ref>
        uintptr_t pa = page2pa(page);
c01040ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01040af:	89 04 24             	mov    %eax,(%esp)
c01040b2:	e8 a3 f5 ff ff       	call   c010365a <page2pa>
c01040b7:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE);
c01040ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01040bd:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01040c0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01040c3:	c1 e8 0c             	shr    $0xc,%eax
c01040c6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01040c9:	a1 80 1f 1b c0       	mov    0xc01b1f80,%eax
c01040ce:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c01040d1:	72 23                	jb     c01040f6 <get_pte+0xb1>
c01040d3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01040d6:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01040da:	c7 44 24 08 00 cd 10 	movl   $0xc010cd00,0x8(%esp)
c01040e1:	c0 
c01040e2:	c7 44 24 04 9a 01 00 	movl   $0x19a,0x4(%esp)
c01040e9:	00 
c01040ea:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c01040f1:	e8 47 c3 ff ff       	call   c010043d <__panic>
c01040f6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01040f9:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01040fe:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0104105:	00 
c0104106:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010410d:	00 
c010410e:	89 04 24             	mov    %eax,(%esp)
c0104111:	e8 94 78 00 00       	call   c010b9aa <memset>
        *pdep = pa | PTE_U | PTE_W | PTE_P;
c0104116:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104119:	83 c8 07             	or     $0x7,%eax
c010411c:	89 c2                	mov    %eax,%edx
c010411e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104121:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
c0104123:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104126:	8b 00                	mov    (%eax),%eax
c0104128:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010412d:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0104130:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104133:	c1 e8 0c             	shr    $0xc,%eax
c0104136:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0104139:	a1 80 1f 1b c0       	mov    0xc01b1f80,%eax
c010413e:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0104141:	72 23                	jb     c0104166 <get_pte+0x121>
c0104143:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104146:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010414a:	c7 44 24 08 00 cd 10 	movl   $0xc010cd00,0x8(%esp)
c0104151:	c0 
c0104152:	c7 44 24 04 9d 01 00 	movl   $0x19d,0x4(%esp)
c0104159:	00 
c010415a:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c0104161:	e8 d7 c2 ff ff       	call   c010043d <__panic>
c0104166:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104169:	2d 00 00 00 40       	sub    $0x40000000,%eax
c010416e:	89 c2                	mov    %eax,%edx
c0104170:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104173:	c1 e8 0c             	shr    $0xc,%eax
c0104176:	25 ff 03 00 00       	and    $0x3ff,%eax
c010417b:	c1 e0 02             	shl    $0x2,%eax
c010417e:	01 d0                	add    %edx,%eax
}
c0104180:	c9                   	leave  
c0104181:	c3                   	ret    

c0104182 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store)
{
c0104182:	f3 0f 1e fb          	endbr32 
c0104186:	55                   	push   %ebp
c0104187:	89 e5                	mov    %esp,%ebp
c0104189:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c010418c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104193:	00 
c0104194:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104197:	89 44 24 04          	mov    %eax,0x4(%esp)
c010419b:	8b 45 08             	mov    0x8(%ebp),%eax
c010419e:	89 04 24             	mov    %eax,(%esp)
c01041a1:	e8 9f fe ff ff       	call   c0104045 <get_pte>
c01041a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL)
c01041a9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01041ad:	74 08                	je     c01041b7 <get_page+0x35>
    {
        *ptep_store = ptep;
c01041af:	8b 45 10             	mov    0x10(%ebp),%eax
c01041b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01041b5:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P)
c01041b7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01041bb:	74 1b                	je     c01041d8 <get_page+0x56>
c01041bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01041c0:	8b 00                	mov    (%eax),%eax
c01041c2:	83 e0 01             	and    $0x1,%eax
c01041c5:	85 c0                	test   %eax,%eax
c01041c7:	74 0f                	je     c01041d8 <get_page+0x56>
    {
        return pte2page(*ptep);
c01041c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01041cc:	8b 00                	mov    (%eax),%eax
c01041ce:	89 04 24             	mov    %eax,(%esp)
c01041d1:	e8 33 f5 ff ff       	call   c0103709 <pte2page>
c01041d6:	eb 05                	jmp    c01041dd <get_page+0x5b>
    }
    return NULL;
c01041d8:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01041dd:	c9                   	leave  
c01041de:	c3                   	ret    

c01041df <page_remove_pte>:
//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep)
{
c01041df:	55                   	push   %ebp
c01041e0:	89 e5                	mov    %esp,%ebp
c01041e2:	83 ec 28             	sub    $0x28,%esp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
    if (*ptep & PTE_P)
c01041e5:	8b 45 10             	mov    0x10(%ebp),%eax
c01041e8:	8b 00                	mov    (%eax),%eax
c01041ea:	83 e0 01             	and    $0x1,%eax
c01041ed:	85 c0                	test   %eax,%eax
c01041ef:	74 4d                	je     c010423e <page_remove_pte+0x5f>
    {
        struct Page *page = pte2page(*ptep);
c01041f1:	8b 45 10             	mov    0x10(%ebp),%eax
c01041f4:	8b 00                	mov    (%eax),%eax
c01041f6:	89 04 24             	mov    %eax,(%esp)
c01041f9:	e8 0b f5 ff ff       	call   c0103709 <pte2page>
c01041fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0)
c0104201:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104204:	89 04 24             	mov    %eax,(%esp)
c0104207:	e8 82 f5 ff ff       	call   c010378e <page_ref_dec>
c010420c:	85 c0                	test   %eax,%eax
c010420e:	75 13                	jne    c0104223 <page_remove_pte+0x44>
        {
            free_page(page);
c0104210:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104217:	00 
c0104218:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010421b:	89 04 24             	mov    %eax,(%esp)
c010421e:	e8 c1 f7 ff ff       	call   c01039e4 <free_pages>
        }
        *ptep = 0;
c0104223:	8b 45 10             	mov    0x10(%ebp),%eax
c0104226:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
c010422c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010422f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104233:	8b 45 08             	mov    0x8(%ebp),%eax
c0104236:	89 04 24             	mov    %eax,(%esp)
c0104239:	e8 35 05 00 00       	call   c0104773 <tlb_invalidate>
    }
}
c010423e:	90                   	nop
c010423f:	c9                   	leave  
c0104240:	c3                   	ret    

c0104241 <unmap_range>:

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end)
{
c0104241:	f3 0f 1e fb          	endbr32 
c0104245:	55                   	push   %ebp
c0104246:	89 e5                	mov    %esp,%ebp
c0104248:	83 ec 28             	sub    $0x28,%esp
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
c010424b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010424e:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104253:	85 c0                	test   %eax,%eax
c0104255:	75 0c                	jne    c0104263 <unmap_range+0x22>
c0104257:	8b 45 10             	mov    0x10(%ebp),%eax
c010425a:	25 ff 0f 00 00       	and    $0xfff,%eax
c010425f:	85 c0                	test   %eax,%eax
c0104261:	74 24                	je     c0104287 <unmap_range+0x46>
c0104263:	c7 44 24 0c 28 ce 10 	movl   $0xc010ce28,0xc(%esp)
c010426a:	c0 
c010426b:	c7 44 24 08 ed cd 10 	movl   $0xc010cded,0x8(%esp)
c0104272:	c0 
c0104273:	c7 44 24 04 dd 01 00 	movl   $0x1dd,0x4(%esp)
c010427a:	00 
c010427b:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c0104282:	e8 b6 c1 ff ff       	call   c010043d <__panic>
    assert(USER_ACCESS(start, end));
c0104287:	81 7d 0c ff ff 1f 00 	cmpl   $0x1fffff,0xc(%ebp)
c010428e:	76 11                	jbe    c01042a1 <unmap_range+0x60>
c0104290:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104293:	3b 45 10             	cmp    0x10(%ebp),%eax
c0104296:	73 09                	jae    c01042a1 <unmap_range+0x60>
c0104298:	81 7d 10 00 00 00 b0 	cmpl   $0xb0000000,0x10(%ebp)
c010429f:	76 24                	jbe    c01042c5 <unmap_range+0x84>
c01042a1:	c7 44 24 0c 51 ce 10 	movl   $0xc010ce51,0xc(%esp)
c01042a8:	c0 
c01042a9:	c7 44 24 08 ed cd 10 	movl   $0xc010cded,0x8(%esp)
c01042b0:	c0 
c01042b1:	c7 44 24 04 de 01 00 	movl   $0x1de,0x4(%esp)
c01042b8:	00 
c01042b9:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c01042c0:	e8 78 c1 ff ff       	call   c010043d <__panic>

    do
    {
        pte_t *ptep = get_pte(pgdir, start, 0);
c01042c5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01042cc:	00 
c01042cd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01042d0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01042d4:	8b 45 08             	mov    0x8(%ebp),%eax
c01042d7:	89 04 24             	mov    %eax,(%esp)
c01042da:	e8 66 fd ff ff       	call   c0104045 <get_pte>
c01042df:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (ptep == NULL)
c01042e2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01042e6:	75 18                	jne    c0104300 <unmap_range+0xbf>
        {
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
c01042e8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01042eb:	05 00 00 40 00       	add    $0x400000,%eax
c01042f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01042f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01042f6:	25 00 00 c0 ff       	and    $0xffc00000,%eax
c01042fb:	89 45 0c             	mov    %eax,0xc(%ebp)
            continue;
c01042fe:	eb 29                	jmp    c0104329 <unmap_range+0xe8>
        }
        if (*ptep != 0)
c0104300:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104303:	8b 00                	mov    (%eax),%eax
c0104305:	85 c0                	test   %eax,%eax
c0104307:	74 19                	je     c0104322 <unmap_range+0xe1>
        {
            page_remove_pte(pgdir, start, ptep);
c0104309:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010430c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104310:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104313:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104317:	8b 45 08             	mov    0x8(%ebp),%eax
c010431a:	89 04 24             	mov    %eax,(%esp)
c010431d:	e8 bd fe ff ff       	call   c01041df <page_remove_pte>
        }
        start += PGSIZE;
c0104322:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
    } while (start != 0 && start < end);
c0104329:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010432d:	74 08                	je     c0104337 <unmap_range+0xf6>
c010432f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104332:	3b 45 10             	cmp    0x10(%ebp),%eax
c0104335:	72 8e                	jb     c01042c5 <unmap_range+0x84>
}
c0104337:	90                   	nop
c0104338:	c9                   	leave  
c0104339:	c3                   	ret    

c010433a <exit_range>:

void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end)
{
c010433a:	f3 0f 1e fb          	endbr32 
c010433e:	55                   	push   %ebp
c010433f:	89 e5                	mov    %esp,%ebp
c0104341:	83 ec 28             	sub    $0x28,%esp
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
c0104344:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104347:	25 ff 0f 00 00       	and    $0xfff,%eax
c010434c:	85 c0                	test   %eax,%eax
c010434e:	75 0c                	jne    c010435c <exit_range+0x22>
c0104350:	8b 45 10             	mov    0x10(%ebp),%eax
c0104353:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104358:	85 c0                	test   %eax,%eax
c010435a:	74 24                	je     c0104380 <exit_range+0x46>
c010435c:	c7 44 24 0c 28 ce 10 	movl   $0xc010ce28,0xc(%esp)
c0104363:	c0 
c0104364:	c7 44 24 08 ed cd 10 	movl   $0xc010cded,0x8(%esp)
c010436b:	c0 
c010436c:	c7 44 24 04 f2 01 00 	movl   $0x1f2,0x4(%esp)
c0104373:	00 
c0104374:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c010437b:	e8 bd c0 ff ff       	call   c010043d <__panic>
    assert(USER_ACCESS(start, end));
c0104380:	81 7d 0c ff ff 1f 00 	cmpl   $0x1fffff,0xc(%ebp)
c0104387:	76 11                	jbe    c010439a <exit_range+0x60>
c0104389:	8b 45 0c             	mov    0xc(%ebp),%eax
c010438c:	3b 45 10             	cmp    0x10(%ebp),%eax
c010438f:	73 09                	jae    c010439a <exit_range+0x60>
c0104391:	81 7d 10 00 00 00 b0 	cmpl   $0xb0000000,0x10(%ebp)
c0104398:	76 24                	jbe    c01043be <exit_range+0x84>
c010439a:	c7 44 24 0c 51 ce 10 	movl   $0xc010ce51,0xc(%esp)
c01043a1:	c0 
c01043a2:	c7 44 24 08 ed cd 10 	movl   $0xc010cded,0x8(%esp)
c01043a9:	c0 
c01043aa:	c7 44 24 04 f3 01 00 	movl   $0x1f3,0x4(%esp)
c01043b1:	00 
c01043b2:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c01043b9:	e8 7f c0 ff ff       	call   c010043d <__panic>

    start = ROUNDDOWN(start, PTSIZE);
c01043be:	8b 45 0c             	mov    0xc(%ebp),%eax
c01043c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01043c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01043c7:	25 00 00 c0 ff       	and    $0xffc00000,%eax
c01043cc:	89 45 0c             	mov    %eax,0xc(%ebp)
    do
    {
        int pde_idx = PDX(start);
c01043cf:	8b 45 0c             	mov    0xc(%ebp),%eax
c01043d2:	c1 e8 16             	shr    $0x16,%eax
c01043d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (pgdir[pde_idx] & PTE_P)
c01043d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01043db:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01043e2:	8b 45 08             	mov    0x8(%ebp),%eax
c01043e5:	01 d0                	add    %edx,%eax
c01043e7:	8b 00                	mov    (%eax),%eax
c01043e9:	83 e0 01             	and    $0x1,%eax
c01043ec:	85 c0                	test   %eax,%eax
c01043ee:	74 3e                	je     c010442e <exit_range+0xf4>
        {
            free_page(pde2page(pgdir[pde_idx]));
c01043f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01043f3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01043fa:	8b 45 08             	mov    0x8(%ebp),%eax
c01043fd:	01 d0                	add    %edx,%eax
c01043ff:	8b 00                	mov    (%eax),%eax
c0104401:	89 04 24             	mov    %eax,(%esp)
c0104404:	e8 3e f3 ff ff       	call   c0103747 <pde2page>
c0104409:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104410:	00 
c0104411:	89 04 24             	mov    %eax,(%esp)
c0104414:	e8 cb f5 ff ff       	call   c01039e4 <free_pages>
            pgdir[pde_idx] = 0;
c0104419:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010441c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0104423:	8b 45 08             	mov    0x8(%ebp),%eax
c0104426:	01 d0                	add    %edx,%eax
c0104428:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        }
        start += PTSIZE;
c010442e:	81 45 0c 00 00 40 00 	addl   $0x400000,0xc(%ebp)
    } while (start != 0 && start < end);
c0104435:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0104439:	74 08                	je     c0104443 <exit_range+0x109>
c010443b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010443e:	3b 45 10             	cmp    0x10(%ebp),%eax
c0104441:	72 8c                	jb     c01043cf <exit_range+0x95>
}
c0104443:	90                   	nop
c0104444:	c9                   	leave  
c0104445:	c3                   	ret    

c0104446 <copy_range>:
 * @share: flags to indicate to dup OR share. We just use dup method, so it didn't be used.
 *
 * CALL GRAPH: copy_mm-->dup_mmap-->copy_range
 */
int copy_range(pde_t *to, pde_t *from, uintptr_t start, uintptr_t end, bool share)
{
c0104446:	f3 0f 1e fb          	endbr32 
c010444a:	55                   	push   %ebp
c010444b:	89 e5                	mov    %esp,%ebp
c010444d:	83 ec 48             	sub    $0x48,%esp
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
c0104450:	8b 45 10             	mov    0x10(%ebp),%eax
c0104453:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104458:	85 c0                	test   %eax,%eax
c010445a:	75 0c                	jne    c0104468 <copy_range+0x22>
c010445c:	8b 45 14             	mov    0x14(%ebp),%eax
c010445f:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104464:	85 c0                	test   %eax,%eax
c0104466:	74 24                	je     c010448c <copy_range+0x46>
c0104468:	c7 44 24 0c 28 ce 10 	movl   $0xc010ce28,0xc(%esp)
c010446f:	c0 
c0104470:	c7 44 24 08 ed cd 10 	movl   $0xc010cded,0x8(%esp)
c0104477:	c0 
c0104478:	c7 44 24 04 0a 02 00 	movl   $0x20a,0x4(%esp)
c010447f:	00 
c0104480:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c0104487:	e8 b1 bf ff ff       	call   c010043d <__panic>
    assert(USER_ACCESS(start, end));
c010448c:	81 7d 10 ff ff 1f 00 	cmpl   $0x1fffff,0x10(%ebp)
c0104493:	76 11                	jbe    c01044a6 <copy_range+0x60>
c0104495:	8b 45 10             	mov    0x10(%ebp),%eax
c0104498:	3b 45 14             	cmp    0x14(%ebp),%eax
c010449b:	73 09                	jae    c01044a6 <copy_range+0x60>
c010449d:	81 7d 14 00 00 00 b0 	cmpl   $0xb0000000,0x14(%ebp)
c01044a4:	76 24                	jbe    c01044ca <copy_range+0x84>
c01044a6:	c7 44 24 0c 51 ce 10 	movl   $0xc010ce51,0xc(%esp)
c01044ad:	c0 
c01044ae:	c7 44 24 08 ed cd 10 	movl   $0xc010cded,0x8(%esp)
c01044b5:	c0 
c01044b6:	c7 44 24 04 0b 02 00 	movl   $0x20b,0x4(%esp)
c01044bd:	00 
c01044be:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c01044c5:	e8 73 bf ff ff       	call   c010043d <__panic>
    // copy content by page unit.
    do
    {
        //call get_pte to find process A's pte according to the addr start
        pte_t *ptep = get_pte(from, start, 0), *nptep;
c01044ca:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01044d1:	00 
c01044d2:	8b 45 10             	mov    0x10(%ebp),%eax
c01044d5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01044d9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01044dc:	89 04 24             	mov    %eax,(%esp)
c01044df:	e8 61 fb ff ff       	call   c0104045 <get_pte>
c01044e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (ptep == NULL)
c01044e7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01044eb:	75 1b                	jne    c0104508 <copy_range+0xc2>
        {
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
c01044ed:	8b 45 10             	mov    0x10(%ebp),%eax
c01044f0:	05 00 00 40 00       	add    $0x400000,%eax
c01044f5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c01044f8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01044fb:	25 00 00 c0 ff       	and    $0xffc00000,%eax
c0104500:	89 45 10             	mov    %eax,0x10(%ebp)
            continue;
c0104503:	e9 4c 01 00 00       	jmp    c0104654 <copy_range+0x20e>
        }
        //call get_pte to find process B's pte according to the addr start. If pte is NULL, just alloc a PT
        if (*ptep & PTE_P)
c0104508:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010450b:	8b 00                	mov    (%eax),%eax
c010450d:	83 e0 01             	and    $0x1,%eax
c0104510:	85 c0                	test   %eax,%eax
c0104512:	0f 84 35 01 00 00    	je     c010464d <copy_range+0x207>
        {
            if ((nptep = get_pte(to, start, 1)) == NULL)
c0104518:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c010451f:	00 
c0104520:	8b 45 10             	mov    0x10(%ebp),%eax
c0104523:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104527:	8b 45 08             	mov    0x8(%ebp),%eax
c010452a:	89 04 24             	mov    %eax,(%esp)
c010452d:	e8 13 fb ff ff       	call   c0104045 <get_pte>
c0104532:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104535:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104539:	75 0a                	jne    c0104545 <copy_range+0xff>
            {
                return -E_NO_MEM;
c010453b:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0104540:	e9 26 01 00 00       	jmp    c010466b <copy_range+0x225>
            }
            uint32_t perm = (*ptep & PTE_USER);
c0104545:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104548:	8b 00                	mov    (%eax),%eax
c010454a:	83 e0 07             	and    $0x7,%eax
c010454d:	89 45 ec             	mov    %eax,-0x14(%ebp)
            //get page from ptep
            struct Page *page = pte2page(*ptep);
c0104550:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104553:	8b 00                	mov    (%eax),%eax
c0104555:	89 04 24             	mov    %eax,(%esp)
c0104558:	e8 ac f1 ff ff       	call   c0103709 <pte2page>
c010455d:	89 45 e8             	mov    %eax,-0x18(%ebp)
            // alloc a page for process B
            struct Page *npage = alloc_page();
c0104560:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104567:	e8 09 f4 ff ff       	call   c0103975 <alloc_pages>
c010456c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            assert(page != NULL);
c010456f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0104573:	75 24                	jne    c0104599 <copy_range+0x153>
c0104575:	c7 44 24 0c 69 ce 10 	movl   $0xc010ce69,0xc(%esp)
c010457c:	c0 
c010457d:	c7 44 24 08 ed cd 10 	movl   $0xc010cded,0x8(%esp)
c0104584:	c0 
c0104585:	c7 44 24 04 22 02 00 	movl   $0x222,0x4(%esp)
c010458c:	00 
c010458d:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c0104594:	e8 a4 be ff ff       	call   c010043d <__panic>
            assert(npage != NULL);
c0104599:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010459d:	75 24                	jne    c01045c3 <copy_range+0x17d>
c010459f:	c7 44 24 0c 76 ce 10 	movl   $0xc010ce76,0xc(%esp)
c01045a6:	c0 
c01045a7:	c7 44 24 08 ed cd 10 	movl   $0xc010cded,0x8(%esp)
c01045ae:	c0 
c01045af:	c7 44 24 04 23 02 00 	movl   $0x223,0x4(%esp)
c01045b6:	00 
c01045b7:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c01045be:	e8 7a be ff ff       	call   c010043d <__panic>
            int ret = 0;
c01045c3:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
         * (1) find src_kvaddr: the kernel virtual address of page
         * (2) find dst_kvaddr: the kernel virtual address of npage
         * (3) memory copy from src_kvaddr to dst_kvaddr, size is PGSIZE
         * (4) build the map of phy addr of  nage with the linear addr start
         */
            void *kva_src = page2kva(page);
c01045ca:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01045cd:	89 04 24             	mov    %eax,(%esp)
c01045d0:	e8 e0 f0 ff ff       	call   c01036b5 <page2kva>
c01045d5:	89 45 dc             	mov    %eax,-0x24(%ebp)
            void *kva_dst = page2kva(npage);
c01045d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01045db:	89 04 24             	mov    %eax,(%esp)
c01045de:	e8 d2 f0 ff ff       	call   c01036b5 <page2kva>
c01045e3:	89 45 d8             	mov    %eax,-0x28(%ebp)

            memcpy(kva_dst, kva_src, PGSIZE);
c01045e6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c01045ed:	00 
c01045ee:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01045f1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01045f5:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01045f8:	89 04 24             	mov    %eax,(%esp)
c01045fb:	e8 94 74 00 00       	call   c010ba94 <memcpy>

            ret = page_insert(to, npage, start, perm);
c0104600:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104603:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104607:	8b 45 10             	mov    0x10(%ebp),%eax
c010460a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010460e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104611:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104615:	8b 45 08             	mov    0x8(%ebp),%eax
c0104618:	89 04 24             	mov    %eax,(%esp)
c010461b:	e8 96 00 00 00       	call   c01046b6 <page_insert>
c0104620:	89 45 e0             	mov    %eax,-0x20(%ebp)
            assert(ret == 0);
c0104623:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0104627:	74 24                	je     c010464d <copy_range+0x207>
c0104629:	c7 44 24 0c 84 ce 10 	movl   $0xc010ce84,0xc(%esp)
c0104630:	c0 
c0104631:	c7 44 24 08 ed cd 10 	movl   $0xc010cded,0x8(%esp)
c0104638:	c0 
c0104639:	c7 44 24 04 39 02 00 	movl   $0x239,0x4(%esp)
c0104640:	00 
c0104641:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c0104648:	e8 f0 bd ff ff       	call   c010043d <__panic>
        }
        start += PGSIZE;
c010464d:	81 45 10 00 10 00 00 	addl   $0x1000,0x10(%ebp)
    } while (start != 0 && start < end);
c0104654:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0104658:	74 0c                	je     c0104666 <copy_range+0x220>
c010465a:	8b 45 10             	mov    0x10(%ebp),%eax
c010465d:	3b 45 14             	cmp    0x14(%ebp),%eax
c0104660:	0f 82 64 fe ff ff    	jb     c01044ca <copy_range+0x84>
    return 0;
c0104666:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010466b:	c9                   	leave  
c010466c:	c3                   	ret    

c010466d <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void page_remove(pde_t *pgdir, uintptr_t la)
{
c010466d:	f3 0f 1e fb          	endbr32 
c0104671:	55                   	push   %ebp
c0104672:	89 e5                	mov    %esp,%ebp
c0104674:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0104677:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010467e:	00 
c010467f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104682:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104686:	8b 45 08             	mov    0x8(%ebp),%eax
c0104689:	89 04 24             	mov    %eax,(%esp)
c010468c:	e8 b4 f9 ff ff       	call   c0104045 <get_pte>
c0104691:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL)
c0104694:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104698:	74 19                	je     c01046b3 <page_remove+0x46>
    {
        page_remove_pte(pgdir, la, ptep);
c010469a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010469d:	89 44 24 08          	mov    %eax,0x8(%esp)
c01046a1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01046a4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01046a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01046ab:	89 04 24             	mov    %eax,(%esp)
c01046ae:	e8 2c fb ff ff       	call   c01041df <page_remove_pte>
    }
}
c01046b3:	90                   	nop
c01046b4:	c9                   	leave  
c01046b5:	c3                   	ret    

c01046b6 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm)
{
c01046b6:	f3 0f 1e fb          	endbr32 
c01046ba:	55                   	push   %ebp
c01046bb:	89 e5                	mov    %esp,%ebp
c01046bd:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c01046c0:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c01046c7:	00 
c01046c8:	8b 45 10             	mov    0x10(%ebp),%eax
c01046cb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01046cf:	8b 45 08             	mov    0x8(%ebp),%eax
c01046d2:	89 04 24             	mov    %eax,(%esp)
c01046d5:	e8 6b f9 ff ff       	call   c0104045 <get_pte>
c01046da:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL)
c01046dd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01046e1:	75 0a                	jne    c01046ed <page_insert+0x37>
    {
        return -E_NO_MEM;
c01046e3:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c01046e8:	e9 84 00 00 00       	jmp    c0104771 <page_insert+0xbb>
    }
    page_ref_inc(page);
c01046ed:	8b 45 0c             	mov    0xc(%ebp),%eax
c01046f0:	89 04 24             	mov    %eax,(%esp)
c01046f3:	e8 7f f0 ff ff       	call   c0103777 <page_ref_inc>
    if (*ptep & PTE_P)
c01046f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046fb:	8b 00                	mov    (%eax),%eax
c01046fd:	83 e0 01             	and    $0x1,%eax
c0104700:	85 c0                	test   %eax,%eax
c0104702:	74 3e                	je     c0104742 <page_insert+0x8c>
    {
        struct Page *p = pte2page(*ptep);
c0104704:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104707:	8b 00                	mov    (%eax),%eax
c0104709:	89 04 24             	mov    %eax,(%esp)
c010470c:	e8 f8 ef ff ff       	call   c0103709 <pte2page>
c0104711:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page)
c0104714:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104717:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010471a:	75 0d                	jne    c0104729 <page_insert+0x73>
        {
            page_ref_dec(page);
c010471c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010471f:	89 04 24             	mov    %eax,(%esp)
c0104722:	e8 67 f0 ff ff       	call   c010378e <page_ref_dec>
c0104727:	eb 19                	jmp    c0104742 <page_insert+0x8c>
        }
        else
        {
            page_remove_pte(pgdir, la, ptep);
c0104729:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010472c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104730:	8b 45 10             	mov    0x10(%ebp),%eax
c0104733:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104737:	8b 45 08             	mov    0x8(%ebp),%eax
c010473a:	89 04 24             	mov    %eax,(%esp)
c010473d:	e8 9d fa ff ff       	call   c01041df <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c0104742:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104745:	89 04 24             	mov    %eax,(%esp)
c0104748:	e8 0d ef ff ff       	call   c010365a <page2pa>
c010474d:	0b 45 14             	or     0x14(%ebp),%eax
c0104750:	83 c8 01             	or     $0x1,%eax
c0104753:	89 c2                	mov    %eax,%edx
c0104755:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104758:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c010475a:	8b 45 10             	mov    0x10(%ebp),%eax
c010475d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104761:	8b 45 08             	mov    0x8(%ebp),%eax
c0104764:	89 04 24             	mov    %eax,(%esp)
c0104767:	e8 07 00 00 00       	call   c0104773 <tlb_invalidate>
    return 0;
c010476c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104771:	c9                   	leave  
c0104772:	c3                   	ret    

c0104773 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la)
{
c0104773:	f3 0f 1e fb          	endbr32 
c0104777:	55                   	push   %ebp
c0104778:	89 e5                	mov    %esp,%ebp
c010477a:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c010477d:	0f 20 d8             	mov    %cr3,%eax
c0104780:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c0104783:	8b 55 f0             	mov    -0x10(%ebp),%edx
    if (rcr3() == PADDR(pgdir))
c0104786:	8b 45 08             	mov    0x8(%ebp),%eax
c0104789:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010478c:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0104793:	77 23                	ja     c01047b8 <tlb_invalidate+0x45>
c0104795:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104798:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010479c:	c7 44 24 08 a4 cd 10 	movl   $0xc010cda4,0x8(%esp)
c01047a3:	c0 
c01047a4:	c7 44 24 04 6f 02 00 	movl   $0x26f,0x4(%esp)
c01047ab:	00 
c01047ac:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c01047b3:	e8 85 bc ff ff       	call   c010043d <__panic>
c01047b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047bb:	05 00 00 00 40       	add    $0x40000000,%eax
c01047c0:	39 d0                	cmp    %edx,%eax
c01047c2:	75 0d                	jne    c01047d1 <tlb_invalidate+0x5e>
    {
        invlpg((void *)la);
c01047c4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01047c7:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c01047ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01047cd:	0f 01 38             	invlpg (%eax)
}
c01047d0:	90                   	nop
    }
}
c01047d1:	90                   	nop
c01047d2:	c9                   	leave  
c01047d3:	c3                   	ret    

c01047d4 <pgdir_alloc_page>:
// pgdir_alloc_page - call alloc_page & page_insert functions to
//                  - allocate a page size memory & setup an addr map
//                  - pa<->la with linear address la and the PDT pgdir
struct Page *
pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm)
{
c01047d4:	f3 0f 1e fb          	endbr32 
c01047d8:	55                   	push   %ebp
c01047d9:	89 e5                	mov    %esp,%ebp
c01047db:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = alloc_page();
c01047de:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01047e5:	e8 8b f1 ff ff       	call   c0103975 <alloc_pages>
c01047ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL)
c01047ed:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01047f1:	0f 84 b0 00 00 00    	je     c01048a7 <pgdir_alloc_page+0xd3>
    {
        if (page_insert(pgdir, page, la, perm) != 0)
c01047f7:	8b 45 10             	mov    0x10(%ebp),%eax
c01047fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01047fe:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104801:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104805:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104808:	89 44 24 04          	mov    %eax,0x4(%esp)
c010480c:	8b 45 08             	mov    0x8(%ebp),%eax
c010480f:	89 04 24             	mov    %eax,(%esp)
c0104812:	e8 9f fe ff ff       	call   c01046b6 <page_insert>
c0104817:	85 c0                	test   %eax,%eax
c0104819:	74 1a                	je     c0104835 <pgdir_alloc_page+0x61>
        {
            free_page(page);
c010481b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104822:	00 
c0104823:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104826:	89 04 24             	mov    %eax,(%esp)
c0104829:	e8 b6 f1 ff ff       	call   c01039e4 <free_pages>
            return NULL;
c010482e:	b8 00 00 00 00       	mov    $0x0,%eax
c0104833:	eb 75                	jmp    c01048aa <pgdir_alloc_page+0xd6>
        }
        if (swap_init_ok)
c0104835:	a1 10 20 1b c0       	mov    0xc01b2010,%eax
c010483a:	85 c0                	test   %eax,%eax
c010483c:	74 69                	je     c01048a7 <pgdir_alloc_page+0xd3>
        {
            if (check_mm_struct != NULL)
c010483e:	a1 64 40 1b c0       	mov    0xc01b4064,%eax
c0104843:	85 c0                	test   %eax,%eax
c0104845:	74 60                	je     c01048a7 <pgdir_alloc_page+0xd3>
            {
                swap_map_swappable(check_mm_struct, la, page, 0);
c0104847:	a1 64 40 1b c0       	mov    0xc01b4064,%eax
c010484c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0104853:	00 
c0104854:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104857:	89 54 24 08          	mov    %edx,0x8(%esp)
c010485b:	8b 55 0c             	mov    0xc(%ebp),%edx
c010485e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104862:	89 04 24             	mov    %eax,(%esp)
c0104865:	e8 74 21 00 00       	call   c01069de <swap_map_swappable>
                page->pra_vaddr = la;
c010486a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010486d:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104870:	89 50 1c             	mov    %edx,0x1c(%eax)
                assert(page_ref(page) == 1);
c0104873:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104876:	89 04 24             	mov    %eax,(%esp)
c0104879:	e8 e1 ee ff ff       	call   c010375f <page_ref>
c010487e:	83 f8 01             	cmp    $0x1,%eax
c0104881:	74 24                	je     c01048a7 <pgdir_alloc_page+0xd3>
c0104883:	c7 44 24 0c 8d ce 10 	movl   $0xc010ce8d,0xc(%esp)
c010488a:	c0 
c010488b:	c7 44 24 08 ed cd 10 	movl   $0xc010cded,0x8(%esp)
c0104892:	c0 
c0104893:	c7 44 24 04 89 02 00 	movl   $0x289,0x4(%esp)
c010489a:	00 
c010489b:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c01048a2:	e8 96 bb ff ff       	call   c010043d <__panic>
                //panic("pgdir_alloc_page: no pages. now current is existed, should fix it in the future\n");
            }
        }
    }

    return page;
c01048a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01048aa:	c9                   	leave  
c01048ab:	c3                   	ret    

c01048ac <check_alloc_page>:

static void
check_alloc_page(void)
{
c01048ac:	f3 0f 1e fb          	endbr32 
c01048b0:	55                   	push   %ebp
c01048b1:	89 e5                	mov    %esp,%ebp
c01048b3:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c01048b6:	a1 58 40 1b c0       	mov    0xc01b4058,%eax
c01048bb:	8b 40 18             	mov    0x18(%eax),%eax
c01048be:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c01048c0:	c7 04 24 a4 ce 10 c0 	movl   $0xc010cea4,(%esp)
c01048c7:	e8 05 ba ff ff       	call   c01002d1 <cprintf>
}
c01048cc:	90                   	nop
c01048cd:	c9                   	leave  
c01048ce:	c3                   	ret    

c01048cf <check_pgdir>:

static void
check_pgdir(void)
{
c01048cf:	f3 0f 1e fb          	endbr32 
c01048d3:	55                   	push   %ebp
c01048d4:	89 e5                	mov    %esp,%ebp
c01048d6:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c01048d9:	a1 80 1f 1b c0       	mov    0xc01b1f80,%eax
c01048de:	3d 00 80 03 00       	cmp    $0x38000,%eax
c01048e3:	76 24                	jbe    c0104909 <check_pgdir+0x3a>
c01048e5:	c7 44 24 0c c3 ce 10 	movl   $0xc010cec3,0xc(%esp)
c01048ec:	c0 
c01048ed:	c7 44 24 08 ed cd 10 	movl   $0xc010cded,0x8(%esp)
c01048f4:	c0 
c01048f5:	c7 44 24 04 a3 02 00 	movl   $0x2a3,0x4(%esp)
c01048fc:	00 
c01048fd:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c0104904:	e8 34 bb ff ff       	call   c010043d <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c0104909:	a1 e0 e9 12 c0       	mov    0xc012e9e0,%eax
c010490e:	85 c0                	test   %eax,%eax
c0104910:	74 0e                	je     c0104920 <check_pgdir+0x51>
c0104912:	a1 e0 e9 12 c0       	mov    0xc012e9e0,%eax
c0104917:	25 ff 0f 00 00       	and    $0xfff,%eax
c010491c:	85 c0                	test   %eax,%eax
c010491e:	74 24                	je     c0104944 <check_pgdir+0x75>
c0104920:	c7 44 24 0c e0 ce 10 	movl   $0xc010cee0,0xc(%esp)
c0104927:	c0 
c0104928:	c7 44 24 08 ed cd 10 	movl   $0xc010cded,0x8(%esp)
c010492f:	c0 
c0104930:	c7 44 24 04 a4 02 00 	movl   $0x2a4,0x4(%esp)
c0104937:	00 
c0104938:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c010493f:	e8 f9 ba ff ff       	call   c010043d <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c0104944:	a1 e0 e9 12 c0       	mov    0xc012e9e0,%eax
c0104949:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104950:	00 
c0104951:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104958:	00 
c0104959:	89 04 24             	mov    %eax,(%esp)
c010495c:	e8 21 f8 ff ff       	call   c0104182 <get_page>
c0104961:	85 c0                	test   %eax,%eax
c0104963:	74 24                	je     c0104989 <check_pgdir+0xba>
c0104965:	c7 44 24 0c 18 cf 10 	movl   $0xc010cf18,0xc(%esp)
c010496c:	c0 
c010496d:	c7 44 24 08 ed cd 10 	movl   $0xc010cded,0x8(%esp)
c0104974:	c0 
c0104975:	c7 44 24 04 a5 02 00 	movl   $0x2a5,0x4(%esp)
c010497c:	00 
c010497d:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c0104984:	e8 b4 ba ff ff       	call   c010043d <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c0104989:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104990:	e8 e0 ef ff ff       	call   c0103975 <alloc_pages>
c0104995:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c0104998:	a1 e0 e9 12 c0       	mov    0xc012e9e0,%eax
c010499d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01049a4:	00 
c01049a5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01049ac:	00 
c01049ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01049b0:	89 54 24 04          	mov    %edx,0x4(%esp)
c01049b4:	89 04 24             	mov    %eax,(%esp)
c01049b7:	e8 fa fc ff ff       	call   c01046b6 <page_insert>
c01049bc:	85 c0                	test   %eax,%eax
c01049be:	74 24                	je     c01049e4 <check_pgdir+0x115>
c01049c0:	c7 44 24 0c 40 cf 10 	movl   $0xc010cf40,0xc(%esp)
c01049c7:	c0 
c01049c8:	c7 44 24 08 ed cd 10 	movl   $0xc010cded,0x8(%esp)
c01049cf:	c0 
c01049d0:	c7 44 24 04 a9 02 00 	movl   $0x2a9,0x4(%esp)
c01049d7:	00 
c01049d8:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c01049df:	e8 59 ba ff ff       	call   c010043d <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c01049e4:	a1 e0 e9 12 c0       	mov    0xc012e9e0,%eax
c01049e9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01049f0:	00 
c01049f1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01049f8:	00 
c01049f9:	89 04 24             	mov    %eax,(%esp)
c01049fc:	e8 44 f6 ff ff       	call   c0104045 <get_pte>
c0104a01:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104a04:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104a08:	75 24                	jne    c0104a2e <check_pgdir+0x15f>
c0104a0a:	c7 44 24 0c 6c cf 10 	movl   $0xc010cf6c,0xc(%esp)
c0104a11:	c0 
c0104a12:	c7 44 24 08 ed cd 10 	movl   $0xc010cded,0x8(%esp)
c0104a19:	c0 
c0104a1a:	c7 44 24 04 ac 02 00 	movl   $0x2ac,0x4(%esp)
c0104a21:	00 
c0104a22:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c0104a29:	e8 0f ba ff ff       	call   c010043d <__panic>
    assert(pte2page(*ptep) == p1);
c0104a2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a31:	8b 00                	mov    (%eax),%eax
c0104a33:	89 04 24             	mov    %eax,(%esp)
c0104a36:	e8 ce ec ff ff       	call   c0103709 <pte2page>
c0104a3b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0104a3e:	74 24                	je     c0104a64 <check_pgdir+0x195>
c0104a40:	c7 44 24 0c 99 cf 10 	movl   $0xc010cf99,0xc(%esp)
c0104a47:	c0 
c0104a48:	c7 44 24 08 ed cd 10 	movl   $0xc010cded,0x8(%esp)
c0104a4f:	c0 
c0104a50:	c7 44 24 04 ad 02 00 	movl   $0x2ad,0x4(%esp)
c0104a57:	00 
c0104a58:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c0104a5f:	e8 d9 b9 ff ff       	call   c010043d <__panic>
    assert(page_ref(p1) == 1);
c0104a64:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a67:	89 04 24             	mov    %eax,(%esp)
c0104a6a:	e8 f0 ec ff ff       	call   c010375f <page_ref>
c0104a6f:	83 f8 01             	cmp    $0x1,%eax
c0104a72:	74 24                	je     c0104a98 <check_pgdir+0x1c9>
c0104a74:	c7 44 24 0c af cf 10 	movl   $0xc010cfaf,0xc(%esp)
c0104a7b:	c0 
c0104a7c:	c7 44 24 08 ed cd 10 	movl   $0xc010cded,0x8(%esp)
c0104a83:	c0 
c0104a84:	c7 44 24 04 ae 02 00 	movl   $0x2ae,0x4(%esp)
c0104a8b:	00 
c0104a8c:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c0104a93:	e8 a5 b9 ff ff       	call   c010043d <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c0104a98:	a1 e0 e9 12 c0       	mov    0xc012e9e0,%eax
c0104a9d:	8b 00                	mov    (%eax),%eax
c0104a9f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104aa4:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104aa7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104aaa:	c1 e8 0c             	shr    $0xc,%eax
c0104aad:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104ab0:	a1 80 1f 1b c0       	mov    0xc01b1f80,%eax
c0104ab5:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0104ab8:	72 23                	jb     c0104add <check_pgdir+0x20e>
c0104aba:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104abd:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104ac1:	c7 44 24 08 00 cd 10 	movl   $0xc010cd00,0x8(%esp)
c0104ac8:	c0 
c0104ac9:	c7 44 24 04 b0 02 00 	movl   $0x2b0,0x4(%esp)
c0104ad0:	00 
c0104ad1:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c0104ad8:	e8 60 b9 ff ff       	call   c010043d <__panic>
c0104add:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104ae0:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0104ae5:	83 c0 04             	add    $0x4,%eax
c0104ae8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c0104aeb:	a1 e0 e9 12 c0       	mov    0xc012e9e0,%eax
c0104af0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104af7:	00 
c0104af8:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104aff:	00 
c0104b00:	89 04 24             	mov    %eax,(%esp)
c0104b03:	e8 3d f5 ff ff       	call   c0104045 <get_pte>
c0104b08:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0104b0b:	74 24                	je     c0104b31 <check_pgdir+0x262>
c0104b0d:	c7 44 24 0c c4 cf 10 	movl   $0xc010cfc4,0xc(%esp)
c0104b14:	c0 
c0104b15:	c7 44 24 08 ed cd 10 	movl   $0xc010cded,0x8(%esp)
c0104b1c:	c0 
c0104b1d:	c7 44 24 04 b1 02 00 	movl   $0x2b1,0x4(%esp)
c0104b24:	00 
c0104b25:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c0104b2c:	e8 0c b9 ff ff       	call   c010043d <__panic>

    p2 = alloc_page();
c0104b31:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104b38:	e8 38 ee ff ff       	call   c0103975 <alloc_pages>
c0104b3d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c0104b40:	a1 e0 e9 12 c0       	mov    0xc012e9e0,%eax
c0104b45:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c0104b4c:	00 
c0104b4d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0104b54:	00 
c0104b55:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104b58:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104b5c:	89 04 24             	mov    %eax,(%esp)
c0104b5f:	e8 52 fb ff ff       	call   c01046b6 <page_insert>
c0104b64:	85 c0                	test   %eax,%eax
c0104b66:	74 24                	je     c0104b8c <check_pgdir+0x2bd>
c0104b68:	c7 44 24 0c ec cf 10 	movl   $0xc010cfec,0xc(%esp)
c0104b6f:	c0 
c0104b70:	c7 44 24 08 ed cd 10 	movl   $0xc010cded,0x8(%esp)
c0104b77:	c0 
c0104b78:	c7 44 24 04 b4 02 00 	movl   $0x2b4,0x4(%esp)
c0104b7f:	00 
c0104b80:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c0104b87:	e8 b1 b8 ff ff       	call   c010043d <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0104b8c:	a1 e0 e9 12 c0       	mov    0xc012e9e0,%eax
c0104b91:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104b98:	00 
c0104b99:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104ba0:	00 
c0104ba1:	89 04 24             	mov    %eax,(%esp)
c0104ba4:	e8 9c f4 ff ff       	call   c0104045 <get_pte>
c0104ba9:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104bac:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104bb0:	75 24                	jne    c0104bd6 <check_pgdir+0x307>
c0104bb2:	c7 44 24 0c 24 d0 10 	movl   $0xc010d024,0xc(%esp)
c0104bb9:	c0 
c0104bba:	c7 44 24 08 ed cd 10 	movl   $0xc010cded,0x8(%esp)
c0104bc1:	c0 
c0104bc2:	c7 44 24 04 b5 02 00 	movl   $0x2b5,0x4(%esp)
c0104bc9:	00 
c0104bca:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c0104bd1:	e8 67 b8 ff ff       	call   c010043d <__panic>
    assert(*ptep & PTE_U);
c0104bd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104bd9:	8b 00                	mov    (%eax),%eax
c0104bdb:	83 e0 04             	and    $0x4,%eax
c0104bde:	85 c0                	test   %eax,%eax
c0104be0:	75 24                	jne    c0104c06 <check_pgdir+0x337>
c0104be2:	c7 44 24 0c 54 d0 10 	movl   $0xc010d054,0xc(%esp)
c0104be9:	c0 
c0104bea:	c7 44 24 08 ed cd 10 	movl   $0xc010cded,0x8(%esp)
c0104bf1:	c0 
c0104bf2:	c7 44 24 04 b6 02 00 	movl   $0x2b6,0x4(%esp)
c0104bf9:	00 
c0104bfa:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c0104c01:	e8 37 b8 ff ff       	call   c010043d <__panic>
    assert(*ptep & PTE_W);
c0104c06:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c09:	8b 00                	mov    (%eax),%eax
c0104c0b:	83 e0 02             	and    $0x2,%eax
c0104c0e:	85 c0                	test   %eax,%eax
c0104c10:	75 24                	jne    c0104c36 <check_pgdir+0x367>
c0104c12:	c7 44 24 0c 62 d0 10 	movl   $0xc010d062,0xc(%esp)
c0104c19:	c0 
c0104c1a:	c7 44 24 08 ed cd 10 	movl   $0xc010cded,0x8(%esp)
c0104c21:	c0 
c0104c22:	c7 44 24 04 b7 02 00 	movl   $0x2b7,0x4(%esp)
c0104c29:	00 
c0104c2a:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c0104c31:	e8 07 b8 ff ff       	call   c010043d <__panic>
    assert(boot_pgdir[0] & PTE_U);
c0104c36:	a1 e0 e9 12 c0       	mov    0xc012e9e0,%eax
c0104c3b:	8b 00                	mov    (%eax),%eax
c0104c3d:	83 e0 04             	and    $0x4,%eax
c0104c40:	85 c0                	test   %eax,%eax
c0104c42:	75 24                	jne    c0104c68 <check_pgdir+0x399>
c0104c44:	c7 44 24 0c 70 d0 10 	movl   $0xc010d070,0xc(%esp)
c0104c4b:	c0 
c0104c4c:	c7 44 24 08 ed cd 10 	movl   $0xc010cded,0x8(%esp)
c0104c53:	c0 
c0104c54:	c7 44 24 04 b8 02 00 	movl   $0x2b8,0x4(%esp)
c0104c5b:	00 
c0104c5c:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c0104c63:	e8 d5 b7 ff ff       	call   c010043d <__panic>
    assert(page_ref(p2) == 1);
c0104c68:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104c6b:	89 04 24             	mov    %eax,(%esp)
c0104c6e:	e8 ec ea ff ff       	call   c010375f <page_ref>
c0104c73:	83 f8 01             	cmp    $0x1,%eax
c0104c76:	74 24                	je     c0104c9c <check_pgdir+0x3cd>
c0104c78:	c7 44 24 0c 86 d0 10 	movl   $0xc010d086,0xc(%esp)
c0104c7f:	c0 
c0104c80:	c7 44 24 08 ed cd 10 	movl   $0xc010cded,0x8(%esp)
c0104c87:	c0 
c0104c88:	c7 44 24 04 b9 02 00 	movl   $0x2b9,0x4(%esp)
c0104c8f:	00 
c0104c90:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c0104c97:	e8 a1 b7 ff ff       	call   c010043d <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c0104c9c:	a1 e0 e9 12 c0       	mov    0xc012e9e0,%eax
c0104ca1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0104ca8:	00 
c0104ca9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0104cb0:	00 
c0104cb1:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104cb4:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104cb8:	89 04 24             	mov    %eax,(%esp)
c0104cbb:	e8 f6 f9 ff ff       	call   c01046b6 <page_insert>
c0104cc0:	85 c0                	test   %eax,%eax
c0104cc2:	74 24                	je     c0104ce8 <check_pgdir+0x419>
c0104cc4:	c7 44 24 0c 98 d0 10 	movl   $0xc010d098,0xc(%esp)
c0104ccb:	c0 
c0104ccc:	c7 44 24 08 ed cd 10 	movl   $0xc010cded,0x8(%esp)
c0104cd3:	c0 
c0104cd4:	c7 44 24 04 bb 02 00 	movl   $0x2bb,0x4(%esp)
c0104cdb:	00 
c0104cdc:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c0104ce3:	e8 55 b7 ff ff       	call   c010043d <__panic>
    assert(page_ref(p1) == 2);
c0104ce8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ceb:	89 04 24             	mov    %eax,(%esp)
c0104cee:	e8 6c ea ff ff       	call   c010375f <page_ref>
c0104cf3:	83 f8 02             	cmp    $0x2,%eax
c0104cf6:	74 24                	je     c0104d1c <check_pgdir+0x44d>
c0104cf8:	c7 44 24 0c c4 d0 10 	movl   $0xc010d0c4,0xc(%esp)
c0104cff:	c0 
c0104d00:	c7 44 24 08 ed cd 10 	movl   $0xc010cded,0x8(%esp)
c0104d07:	c0 
c0104d08:	c7 44 24 04 bc 02 00 	movl   $0x2bc,0x4(%esp)
c0104d0f:	00 
c0104d10:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c0104d17:	e8 21 b7 ff ff       	call   c010043d <__panic>
    assert(page_ref(p2) == 0);
c0104d1c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104d1f:	89 04 24             	mov    %eax,(%esp)
c0104d22:	e8 38 ea ff ff       	call   c010375f <page_ref>
c0104d27:	85 c0                	test   %eax,%eax
c0104d29:	74 24                	je     c0104d4f <check_pgdir+0x480>
c0104d2b:	c7 44 24 0c d6 d0 10 	movl   $0xc010d0d6,0xc(%esp)
c0104d32:	c0 
c0104d33:	c7 44 24 08 ed cd 10 	movl   $0xc010cded,0x8(%esp)
c0104d3a:	c0 
c0104d3b:	c7 44 24 04 bd 02 00 	movl   $0x2bd,0x4(%esp)
c0104d42:	00 
c0104d43:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c0104d4a:	e8 ee b6 ff ff       	call   c010043d <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0104d4f:	a1 e0 e9 12 c0       	mov    0xc012e9e0,%eax
c0104d54:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104d5b:	00 
c0104d5c:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104d63:	00 
c0104d64:	89 04 24             	mov    %eax,(%esp)
c0104d67:	e8 d9 f2 ff ff       	call   c0104045 <get_pte>
c0104d6c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104d6f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104d73:	75 24                	jne    c0104d99 <check_pgdir+0x4ca>
c0104d75:	c7 44 24 0c 24 d0 10 	movl   $0xc010d024,0xc(%esp)
c0104d7c:	c0 
c0104d7d:	c7 44 24 08 ed cd 10 	movl   $0xc010cded,0x8(%esp)
c0104d84:	c0 
c0104d85:	c7 44 24 04 be 02 00 	movl   $0x2be,0x4(%esp)
c0104d8c:	00 
c0104d8d:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c0104d94:	e8 a4 b6 ff ff       	call   c010043d <__panic>
    assert(pte2page(*ptep) == p1);
c0104d99:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d9c:	8b 00                	mov    (%eax),%eax
c0104d9e:	89 04 24             	mov    %eax,(%esp)
c0104da1:	e8 63 e9 ff ff       	call   c0103709 <pte2page>
c0104da6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0104da9:	74 24                	je     c0104dcf <check_pgdir+0x500>
c0104dab:	c7 44 24 0c 99 cf 10 	movl   $0xc010cf99,0xc(%esp)
c0104db2:	c0 
c0104db3:	c7 44 24 08 ed cd 10 	movl   $0xc010cded,0x8(%esp)
c0104dba:	c0 
c0104dbb:	c7 44 24 04 bf 02 00 	movl   $0x2bf,0x4(%esp)
c0104dc2:	00 
c0104dc3:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c0104dca:	e8 6e b6 ff ff       	call   c010043d <__panic>
    assert((*ptep & PTE_U) == 0);
c0104dcf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104dd2:	8b 00                	mov    (%eax),%eax
c0104dd4:	83 e0 04             	and    $0x4,%eax
c0104dd7:	85 c0                	test   %eax,%eax
c0104dd9:	74 24                	je     c0104dff <check_pgdir+0x530>
c0104ddb:	c7 44 24 0c e8 d0 10 	movl   $0xc010d0e8,0xc(%esp)
c0104de2:	c0 
c0104de3:	c7 44 24 08 ed cd 10 	movl   $0xc010cded,0x8(%esp)
c0104dea:	c0 
c0104deb:	c7 44 24 04 c0 02 00 	movl   $0x2c0,0x4(%esp)
c0104df2:	00 
c0104df3:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c0104dfa:	e8 3e b6 ff ff       	call   c010043d <__panic>

    page_remove(boot_pgdir, 0x0);
c0104dff:	a1 e0 e9 12 c0       	mov    0xc012e9e0,%eax
c0104e04:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104e0b:	00 
c0104e0c:	89 04 24             	mov    %eax,(%esp)
c0104e0f:	e8 59 f8 ff ff       	call   c010466d <page_remove>
    assert(page_ref(p1) == 1);
c0104e14:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e17:	89 04 24             	mov    %eax,(%esp)
c0104e1a:	e8 40 e9 ff ff       	call   c010375f <page_ref>
c0104e1f:	83 f8 01             	cmp    $0x1,%eax
c0104e22:	74 24                	je     c0104e48 <check_pgdir+0x579>
c0104e24:	c7 44 24 0c af cf 10 	movl   $0xc010cfaf,0xc(%esp)
c0104e2b:	c0 
c0104e2c:	c7 44 24 08 ed cd 10 	movl   $0xc010cded,0x8(%esp)
c0104e33:	c0 
c0104e34:	c7 44 24 04 c3 02 00 	movl   $0x2c3,0x4(%esp)
c0104e3b:	00 
c0104e3c:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c0104e43:	e8 f5 b5 ff ff       	call   c010043d <__panic>
    assert(page_ref(p2) == 0);
c0104e48:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104e4b:	89 04 24             	mov    %eax,(%esp)
c0104e4e:	e8 0c e9 ff ff       	call   c010375f <page_ref>
c0104e53:	85 c0                	test   %eax,%eax
c0104e55:	74 24                	je     c0104e7b <check_pgdir+0x5ac>
c0104e57:	c7 44 24 0c d6 d0 10 	movl   $0xc010d0d6,0xc(%esp)
c0104e5e:	c0 
c0104e5f:	c7 44 24 08 ed cd 10 	movl   $0xc010cded,0x8(%esp)
c0104e66:	c0 
c0104e67:	c7 44 24 04 c4 02 00 	movl   $0x2c4,0x4(%esp)
c0104e6e:	00 
c0104e6f:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c0104e76:	e8 c2 b5 ff ff       	call   c010043d <__panic>

    page_remove(boot_pgdir, PGSIZE);
c0104e7b:	a1 e0 e9 12 c0       	mov    0xc012e9e0,%eax
c0104e80:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104e87:	00 
c0104e88:	89 04 24             	mov    %eax,(%esp)
c0104e8b:	e8 dd f7 ff ff       	call   c010466d <page_remove>
    assert(page_ref(p1) == 0);
c0104e90:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e93:	89 04 24             	mov    %eax,(%esp)
c0104e96:	e8 c4 e8 ff ff       	call   c010375f <page_ref>
c0104e9b:	85 c0                	test   %eax,%eax
c0104e9d:	74 24                	je     c0104ec3 <check_pgdir+0x5f4>
c0104e9f:	c7 44 24 0c fd d0 10 	movl   $0xc010d0fd,0xc(%esp)
c0104ea6:	c0 
c0104ea7:	c7 44 24 08 ed cd 10 	movl   $0xc010cded,0x8(%esp)
c0104eae:	c0 
c0104eaf:	c7 44 24 04 c7 02 00 	movl   $0x2c7,0x4(%esp)
c0104eb6:	00 
c0104eb7:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c0104ebe:	e8 7a b5 ff ff       	call   c010043d <__panic>
    assert(page_ref(p2) == 0);
c0104ec3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104ec6:	89 04 24             	mov    %eax,(%esp)
c0104ec9:	e8 91 e8 ff ff       	call   c010375f <page_ref>
c0104ece:	85 c0                	test   %eax,%eax
c0104ed0:	74 24                	je     c0104ef6 <check_pgdir+0x627>
c0104ed2:	c7 44 24 0c d6 d0 10 	movl   $0xc010d0d6,0xc(%esp)
c0104ed9:	c0 
c0104eda:	c7 44 24 08 ed cd 10 	movl   $0xc010cded,0x8(%esp)
c0104ee1:	c0 
c0104ee2:	c7 44 24 04 c8 02 00 	movl   $0x2c8,0x4(%esp)
c0104ee9:	00 
c0104eea:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c0104ef1:	e8 47 b5 ff ff       	call   c010043d <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c0104ef6:	a1 e0 e9 12 c0       	mov    0xc012e9e0,%eax
c0104efb:	8b 00                	mov    (%eax),%eax
c0104efd:	89 04 24             	mov    %eax,(%esp)
c0104f00:	e8 42 e8 ff ff       	call   c0103747 <pde2page>
c0104f05:	89 04 24             	mov    %eax,(%esp)
c0104f08:	e8 52 e8 ff ff       	call   c010375f <page_ref>
c0104f0d:	83 f8 01             	cmp    $0x1,%eax
c0104f10:	74 24                	je     c0104f36 <check_pgdir+0x667>
c0104f12:	c7 44 24 0c 10 d1 10 	movl   $0xc010d110,0xc(%esp)
c0104f19:	c0 
c0104f1a:	c7 44 24 08 ed cd 10 	movl   $0xc010cded,0x8(%esp)
c0104f21:	c0 
c0104f22:	c7 44 24 04 ca 02 00 	movl   $0x2ca,0x4(%esp)
c0104f29:	00 
c0104f2a:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c0104f31:	e8 07 b5 ff ff       	call   c010043d <__panic>
    free_page(pde2page(boot_pgdir[0]));
c0104f36:	a1 e0 e9 12 c0       	mov    0xc012e9e0,%eax
c0104f3b:	8b 00                	mov    (%eax),%eax
c0104f3d:	89 04 24             	mov    %eax,(%esp)
c0104f40:	e8 02 e8 ff ff       	call   c0103747 <pde2page>
c0104f45:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104f4c:	00 
c0104f4d:	89 04 24             	mov    %eax,(%esp)
c0104f50:	e8 8f ea ff ff       	call   c01039e4 <free_pages>
    boot_pgdir[0] = 0;
c0104f55:	a1 e0 e9 12 c0       	mov    0xc012e9e0,%eax
c0104f5a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0104f60:	c7 04 24 37 d1 10 c0 	movl   $0xc010d137,(%esp)
c0104f67:	e8 65 b3 ff ff       	call   c01002d1 <cprintf>
}
c0104f6c:	90                   	nop
c0104f6d:	c9                   	leave  
c0104f6e:	c3                   	ret    

c0104f6f <check_boot_pgdir>:

static void
check_boot_pgdir(void)
{
c0104f6f:	f3 0f 1e fb          	endbr32 
c0104f73:	55                   	push   %ebp
c0104f74:	89 e5                	mov    %esp,%ebp
c0104f76:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE)
c0104f79:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104f80:	e9 ca 00 00 00       	jmp    c010504f <check_boot_pgdir+0xe0>
    {
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0104f85:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f88:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104f8b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104f8e:	c1 e8 0c             	shr    $0xc,%eax
c0104f91:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0104f94:	a1 80 1f 1b c0       	mov    0xc01b1f80,%eax
c0104f99:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0104f9c:	72 23                	jb     c0104fc1 <check_boot_pgdir+0x52>
c0104f9e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104fa1:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104fa5:	c7 44 24 08 00 cd 10 	movl   $0xc010cd00,0x8(%esp)
c0104fac:	c0 
c0104fad:	c7 44 24 04 d8 02 00 	movl   $0x2d8,0x4(%esp)
c0104fb4:	00 
c0104fb5:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c0104fbc:	e8 7c b4 ff ff       	call   c010043d <__panic>
c0104fc1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104fc4:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0104fc9:	89 c2                	mov    %eax,%edx
c0104fcb:	a1 e0 e9 12 c0       	mov    0xc012e9e0,%eax
c0104fd0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104fd7:	00 
c0104fd8:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104fdc:	89 04 24             	mov    %eax,(%esp)
c0104fdf:	e8 61 f0 ff ff       	call   c0104045 <get_pte>
c0104fe4:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0104fe7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0104feb:	75 24                	jne    c0105011 <check_boot_pgdir+0xa2>
c0104fed:	c7 44 24 0c 54 d1 10 	movl   $0xc010d154,0xc(%esp)
c0104ff4:	c0 
c0104ff5:	c7 44 24 08 ed cd 10 	movl   $0xc010cded,0x8(%esp)
c0104ffc:	c0 
c0104ffd:	c7 44 24 04 d8 02 00 	movl   $0x2d8,0x4(%esp)
c0105004:	00 
c0105005:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c010500c:	e8 2c b4 ff ff       	call   c010043d <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0105011:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105014:	8b 00                	mov    (%eax),%eax
c0105016:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010501b:	89 c2                	mov    %eax,%edx
c010501d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105020:	39 c2                	cmp    %eax,%edx
c0105022:	74 24                	je     c0105048 <check_boot_pgdir+0xd9>
c0105024:	c7 44 24 0c 91 d1 10 	movl   $0xc010d191,0xc(%esp)
c010502b:	c0 
c010502c:	c7 44 24 08 ed cd 10 	movl   $0xc010cded,0x8(%esp)
c0105033:	c0 
c0105034:	c7 44 24 04 d9 02 00 	movl   $0x2d9,0x4(%esp)
c010503b:	00 
c010503c:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c0105043:	e8 f5 b3 ff ff       	call   c010043d <__panic>
    for (i = 0; i < npage; i += PGSIZE)
c0105048:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c010504f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105052:	a1 80 1f 1b c0       	mov    0xc01b1f80,%eax
c0105057:	39 c2                	cmp    %eax,%edx
c0105059:	0f 82 26 ff ff ff    	jb     c0104f85 <check_boot_pgdir+0x16>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c010505f:	a1 e0 e9 12 c0       	mov    0xc012e9e0,%eax
c0105064:	05 ac 0f 00 00       	add    $0xfac,%eax
c0105069:	8b 00                	mov    (%eax),%eax
c010506b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105070:	89 c2                	mov    %eax,%edx
c0105072:	a1 e0 e9 12 c0       	mov    0xc012e9e0,%eax
c0105077:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010507a:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0105081:	77 23                	ja     c01050a6 <check_boot_pgdir+0x137>
c0105083:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105086:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010508a:	c7 44 24 08 a4 cd 10 	movl   $0xc010cda4,0x8(%esp)
c0105091:	c0 
c0105092:	c7 44 24 04 dc 02 00 	movl   $0x2dc,0x4(%esp)
c0105099:	00 
c010509a:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c01050a1:	e8 97 b3 ff ff       	call   c010043d <__panic>
c01050a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01050a9:	05 00 00 00 40       	add    $0x40000000,%eax
c01050ae:	39 d0                	cmp    %edx,%eax
c01050b0:	74 24                	je     c01050d6 <check_boot_pgdir+0x167>
c01050b2:	c7 44 24 0c a8 d1 10 	movl   $0xc010d1a8,0xc(%esp)
c01050b9:	c0 
c01050ba:	c7 44 24 08 ed cd 10 	movl   $0xc010cded,0x8(%esp)
c01050c1:	c0 
c01050c2:	c7 44 24 04 dc 02 00 	movl   $0x2dc,0x4(%esp)
c01050c9:	00 
c01050ca:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c01050d1:	e8 67 b3 ff ff       	call   c010043d <__panic>

    assert(boot_pgdir[0] == 0);
c01050d6:	a1 e0 e9 12 c0       	mov    0xc012e9e0,%eax
c01050db:	8b 00                	mov    (%eax),%eax
c01050dd:	85 c0                	test   %eax,%eax
c01050df:	74 24                	je     c0105105 <check_boot_pgdir+0x196>
c01050e1:	c7 44 24 0c dc d1 10 	movl   $0xc010d1dc,0xc(%esp)
c01050e8:	c0 
c01050e9:	c7 44 24 08 ed cd 10 	movl   $0xc010cded,0x8(%esp)
c01050f0:	c0 
c01050f1:	c7 44 24 04 de 02 00 	movl   $0x2de,0x4(%esp)
c01050f8:	00 
c01050f9:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c0105100:	e8 38 b3 ff ff       	call   c010043d <__panic>

    struct Page *p;
    p = alloc_page();
c0105105:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010510c:	e8 64 e8 ff ff       	call   c0103975 <alloc_pages>
c0105111:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0105114:	a1 e0 e9 12 c0       	mov    0xc012e9e0,%eax
c0105119:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0105120:	00 
c0105121:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c0105128:	00 
c0105129:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010512c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105130:	89 04 24             	mov    %eax,(%esp)
c0105133:	e8 7e f5 ff ff       	call   c01046b6 <page_insert>
c0105138:	85 c0                	test   %eax,%eax
c010513a:	74 24                	je     c0105160 <check_boot_pgdir+0x1f1>
c010513c:	c7 44 24 0c f0 d1 10 	movl   $0xc010d1f0,0xc(%esp)
c0105143:	c0 
c0105144:	c7 44 24 08 ed cd 10 	movl   $0xc010cded,0x8(%esp)
c010514b:	c0 
c010514c:	c7 44 24 04 e2 02 00 	movl   $0x2e2,0x4(%esp)
c0105153:	00 
c0105154:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c010515b:	e8 dd b2 ff ff       	call   c010043d <__panic>
    assert(page_ref(p) == 1);
c0105160:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105163:	89 04 24             	mov    %eax,(%esp)
c0105166:	e8 f4 e5 ff ff       	call   c010375f <page_ref>
c010516b:	83 f8 01             	cmp    $0x1,%eax
c010516e:	74 24                	je     c0105194 <check_boot_pgdir+0x225>
c0105170:	c7 44 24 0c 1e d2 10 	movl   $0xc010d21e,0xc(%esp)
c0105177:	c0 
c0105178:	c7 44 24 08 ed cd 10 	movl   $0xc010cded,0x8(%esp)
c010517f:	c0 
c0105180:	c7 44 24 04 e3 02 00 	movl   $0x2e3,0x4(%esp)
c0105187:	00 
c0105188:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c010518f:	e8 a9 b2 ff ff       	call   c010043d <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c0105194:	a1 e0 e9 12 c0       	mov    0xc012e9e0,%eax
c0105199:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c01051a0:	00 
c01051a1:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c01051a8:	00 
c01051a9:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01051ac:	89 54 24 04          	mov    %edx,0x4(%esp)
c01051b0:	89 04 24             	mov    %eax,(%esp)
c01051b3:	e8 fe f4 ff ff       	call   c01046b6 <page_insert>
c01051b8:	85 c0                	test   %eax,%eax
c01051ba:	74 24                	je     c01051e0 <check_boot_pgdir+0x271>
c01051bc:	c7 44 24 0c 30 d2 10 	movl   $0xc010d230,0xc(%esp)
c01051c3:	c0 
c01051c4:	c7 44 24 08 ed cd 10 	movl   $0xc010cded,0x8(%esp)
c01051cb:	c0 
c01051cc:	c7 44 24 04 e4 02 00 	movl   $0x2e4,0x4(%esp)
c01051d3:	00 
c01051d4:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c01051db:	e8 5d b2 ff ff       	call   c010043d <__panic>
    assert(page_ref(p) == 2);
c01051e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01051e3:	89 04 24             	mov    %eax,(%esp)
c01051e6:	e8 74 e5 ff ff       	call   c010375f <page_ref>
c01051eb:	83 f8 02             	cmp    $0x2,%eax
c01051ee:	74 24                	je     c0105214 <check_boot_pgdir+0x2a5>
c01051f0:	c7 44 24 0c 67 d2 10 	movl   $0xc010d267,0xc(%esp)
c01051f7:	c0 
c01051f8:	c7 44 24 08 ed cd 10 	movl   $0xc010cded,0x8(%esp)
c01051ff:	c0 
c0105200:	c7 44 24 04 e5 02 00 	movl   $0x2e5,0x4(%esp)
c0105207:	00 
c0105208:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c010520f:	e8 29 b2 ff ff       	call   c010043d <__panic>

    const char *str = "ucore: Hello world!!";
c0105214:	c7 45 e8 78 d2 10 c0 	movl   $0xc010d278,-0x18(%ebp)
    strcpy((void *)0x100, str);
c010521b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010521e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105222:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0105229:	e8 98 64 00 00       	call   c010b6c6 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c010522e:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c0105235:	00 
c0105236:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c010523d:	e8 02 65 00 00       	call   c010b744 <strcmp>
c0105242:	85 c0                	test   %eax,%eax
c0105244:	74 24                	je     c010526a <check_boot_pgdir+0x2fb>
c0105246:	c7 44 24 0c 90 d2 10 	movl   $0xc010d290,0xc(%esp)
c010524d:	c0 
c010524e:	c7 44 24 08 ed cd 10 	movl   $0xc010cded,0x8(%esp)
c0105255:	c0 
c0105256:	c7 44 24 04 e9 02 00 	movl   $0x2e9,0x4(%esp)
c010525d:	00 
c010525e:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c0105265:	e8 d3 b1 ff ff       	call   c010043d <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c010526a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010526d:	89 04 24             	mov    %eax,(%esp)
c0105270:	e8 40 e4 ff ff       	call   c01036b5 <page2kva>
c0105275:	05 00 01 00 00       	add    $0x100,%eax
c010527a:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c010527d:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0105284:	e8 df 63 00 00       	call   c010b668 <strlen>
c0105289:	85 c0                	test   %eax,%eax
c010528b:	74 24                	je     c01052b1 <check_boot_pgdir+0x342>
c010528d:	c7 44 24 0c c8 d2 10 	movl   $0xc010d2c8,0xc(%esp)
c0105294:	c0 
c0105295:	c7 44 24 08 ed cd 10 	movl   $0xc010cded,0x8(%esp)
c010529c:	c0 
c010529d:	c7 44 24 04 ec 02 00 	movl   $0x2ec,0x4(%esp)
c01052a4:	00 
c01052a5:	c7 04 24 c8 cd 10 c0 	movl   $0xc010cdc8,(%esp)
c01052ac:	e8 8c b1 ff ff       	call   c010043d <__panic>

    free_page(p);
c01052b1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01052b8:	00 
c01052b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01052bc:	89 04 24             	mov    %eax,(%esp)
c01052bf:	e8 20 e7 ff ff       	call   c01039e4 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c01052c4:	a1 e0 e9 12 c0       	mov    0xc012e9e0,%eax
c01052c9:	8b 00                	mov    (%eax),%eax
c01052cb:	89 04 24             	mov    %eax,(%esp)
c01052ce:	e8 74 e4 ff ff       	call   c0103747 <pde2page>
c01052d3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01052da:	00 
c01052db:	89 04 24             	mov    %eax,(%esp)
c01052de:	e8 01 e7 ff ff       	call   c01039e4 <free_pages>
    boot_pgdir[0] = 0;
c01052e3:	a1 e0 e9 12 c0       	mov    0xc012e9e0,%eax
c01052e8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    tlb_invalidate(boot_pgdir, 0x100);
c01052ee:	a1 e0 e9 12 c0       	mov    0xc012e9e0,%eax
c01052f3:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
c01052fa:	00 
c01052fb:	89 04 24             	mov    %eax,(%esp)
c01052fe:	e8 70 f4 ff ff       	call   c0104773 <tlb_invalidate>
    tlb_invalidate(boot_pgdir, 0x100 + PGSIZE);
c0105303:	a1 e0 e9 12 c0       	mov    0xc012e9e0,%eax
c0105308:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c010530f:	00 
c0105310:	89 04 24             	mov    %eax,(%esp)
c0105313:	e8 5b f4 ff ff       	call   c0104773 <tlb_invalidate>

    cprintf("check_boot_pgdir() succeeded!\n");
c0105318:	c7 04 24 ec d2 10 c0 	movl   $0xc010d2ec,(%esp)
c010531f:	e8 ad af ff ff       	call   c01002d1 <cprintf>
}
c0105324:	90                   	nop
c0105325:	c9                   	leave  
c0105326:	c3                   	ret    

c0105327 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm)
{
c0105327:	f3 0f 1e fb          	endbr32 
c010532b:	55                   	push   %ebp
c010532c:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c010532e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105331:	83 e0 04             	and    $0x4,%eax
c0105334:	85 c0                	test   %eax,%eax
c0105336:	74 04                	je     c010533c <perm2str+0x15>
c0105338:	b0 75                	mov    $0x75,%al
c010533a:	eb 02                	jmp    c010533e <perm2str+0x17>
c010533c:	b0 2d                	mov    $0x2d,%al
c010533e:	a2 08 20 1b c0       	mov    %al,0xc01b2008
    str[1] = 'r';
c0105343:	c6 05 09 20 1b c0 72 	movb   $0x72,0xc01b2009
    str[2] = (perm & PTE_W) ? 'w' : '-';
c010534a:	8b 45 08             	mov    0x8(%ebp),%eax
c010534d:	83 e0 02             	and    $0x2,%eax
c0105350:	85 c0                	test   %eax,%eax
c0105352:	74 04                	je     c0105358 <perm2str+0x31>
c0105354:	b0 77                	mov    $0x77,%al
c0105356:	eb 02                	jmp    c010535a <perm2str+0x33>
c0105358:	b0 2d                	mov    $0x2d,%al
c010535a:	a2 0a 20 1b c0       	mov    %al,0xc01b200a
    str[3] = '\0';
c010535f:	c6 05 0b 20 1b c0 00 	movb   $0x0,0xc01b200b
    return str;
c0105366:	b8 08 20 1b c0       	mov    $0xc01b2008,%eax
}
c010536b:	5d                   	pop    %ebp
c010536c:	c3                   	ret    

c010536d <get_pgtable_items>:
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store)
{
c010536d:	f3 0f 1e fb          	endbr32 
c0105371:	55                   	push   %ebp
c0105372:	89 e5                	mov    %esp,%ebp
c0105374:	83 ec 10             	sub    $0x10,%esp
    if (start >= right)
c0105377:	8b 45 10             	mov    0x10(%ebp),%eax
c010537a:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010537d:	72 0d                	jb     c010538c <get_pgtable_items+0x1f>
    {
        return 0;
c010537f:	b8 00 00 00 00       	mov    $0x0,%eax
c0105384:	e9 98 00 00 00       	jmp    c0105421 <get_pgtable_items+0xb4>
    }
    while (start < right && !(table[start] & PTE_P))
    {
        start++;
c0105389:	ff 45 10             	incl   0x10(%ebp)
    while (start < right && !(table[start] & PTE_P))
c010538c:	8b 45 10             	mov    0x10(%ebp),%eax
c010538f:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105392:	73 18                	jae    c01053ac <get_pgtable_items+0x3f>
c0105394:	8b 45 10             	mov    0x10(%ebp),%eax
c0105397:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010539e:	8b 45 14             	mov    0x14(%ebp),%eax
c01053a1:	01 d0                	add    %edx,%eax
c01053a3:	8b 00                	mov    (%eax),%eax
c01053a5:	83 e0 01             	and    $0x1,%eax
c01053a8:	85 c0                	test   %eax,%eax
c01053aa:	74 dd                	je     c0105389 <get_pgtable_items+0x1c>
    }
    if (start < right)
c01053ac:	8b 45 10             	mov    0x10(%ebp),%eax
c01053af:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01053b2:	73 68                	jae    c010541c <get_pgtable_items+0xaf>
    {
        if (left_store != NULL)
c01053b4:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c01053b8:	74 08                	je     c01053c2 <get_pgtable_items+0x55>
        {
            *left_store = start;
c01053ba:	8b 45 18             	mov    0x18(%ebp),%eax
c01053bd:	8b 55 10             	mov    0x10(%ebp),%edx
c01053c0:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start++] & PTE_USER);
c01053c2:	8b 45 10             	mov    0x10(%ebp),%eax
c01053c5:	8d 50 01             	lea    0x1(%eax),%edx
c01053c8:	89 55 10             	mov    %edx,0x10(%ebp)
c01053cb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01053d2:	8b 45 14             	mov    0x14(%ebp),%eax
c01053d5:	01 d0                	add    %edx,%eax
c01053d7:	8b 00                	mov    (%eax),%eax
c01053d9:	83 e0 07             	and    $0x7,%eax
c01053dc:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm)
c01053df:	eb 03                	jmp    c01053e4 <get_pgtable_items+0x77>
        {
            start++;
c01053e1:	ff 45 10             	incl   0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm)
c01053e4:	8b 45 10             	mov    0x10(%ebp),%eax
c01053e7:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01053ea:	73 1d                	jae    c0105409 <get_pgtable_items+0x9c>
c01053ec:	8b 45 10             	mov    0x10(%ebp),%eax
c01053ef:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01053f6:	8b 45 14             	mov    0x14(%ebp),%eax
c01053f9:	01 d0                	add    %edx,%eax
c01053fb:	8b 00                	mov    (%eax),%eax
c01053fd:	83 e0 07             	and    $0x7,%eax
c0105400:	89 c2                	mov    %eax,%edx
c0105402:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105405:	39 c2                	cmp    %eax,%edx
c0105407:	74 d8                	je     c01053e1 <get_pgtable_items+0x74>
        }
        if (right_store != NULL)
c0105409:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c010540d:	74 08                	je     c0105417 <get_pgtable_items+0xaa>
        {
            *right_store = start;
c010540f:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0105412:	8b 55 10             	mov    0x10(%ebp),%edx
c0105415:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c0105417:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010541a:	eb 05                	jmp    c0105421 <get_pgtable_items+0xb4>
    }
    return 0;
c010541c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105421:	c9                   	leave  
c0105422:	c3                   	ret    

c0105423 <print_pgdir>:

//print_pgdir - print the PDT&PT
void print_pgdir(void)
{
c0105423:	f3 0f 1e fb          	endbr32 
c0105427:	55                   	push   %ebp
c0105428:	89 e5                	mov    %esp,%ebp
c010542a:	57                   	push   %edi
c010542b:	56                   	push   %esi
c010542c:	53                   	push   %ebx
c010542d:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c0105430:	c7 04 24 0c d3 10 c0 	movl   $0xc010d30c,(%esp)
c0105437:	e8 95 ae ff ff       	call   c01002d1 <cprintf>
    size_t left, right = 0, perm;
c010543c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0)
c0105443:	e9 fa 00 00 00       	jmp    c0105542 <print_pgdir+0x11f>
    {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0105448:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010544b:	89 04 24             	mov    %eax,(%esp)
c010544e:	e8 d4 fe ff ff       	call   c0105327 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0105453:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0105456:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105459:	29 d1                	sub    %edx,%ecx
c010545b:	89 ca                	mov    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c010545d:	89 d6                	mov    %edx,%esi
c010545f:	c1 e6 16             	shl    $0x16,%esi
c0105462:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105465:	89 d3                	mov    %edx,%ebx
c0105467:	c1 e3 16             	shl    $0x16,%ebx
c010546a:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010546d:	89 d1                	mov    %edx,%ecx
c010546f:	c1 e1 16             	shl    $0x16,%ecx
c0105472:	8b 7d dc             	mov    -0x24(%ebp),%edi
c0105475:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105478:	29 d7                	sub    %edx,%edi
c010547a:	89 fa                	mov    %edi,%edx
c010547c:	89 44 24 14          	mov    %eax,0x14(%esp)
c0105480:	89 74 24 10          	mov    %esi,0x10(%esp)
c0105484:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0105488:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c010548c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105490:	c7 04 24 3d d3 10 c0 	movl   $0xc010d33d,(%esp)
c0105497:	e8 35 ae ff ff       	call   c01002d1 <cprintf>
        size_t l, r = left * NPTEENTRY;
c010549c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010549f:	c1 e0 0a             	shl    $0xa,%eax
c01054a2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0)
c01054a5:	eb 54                	jmp    c01054fb <print_pgdir+0xd8>
        {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c01054a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01054aa:	89 04 24             	mov    %eax,(%esp)
c01054ad:	e8 75 fe ff ff       	call   c0105327 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c01054b2:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c01054b5:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01054b8:	29 d1                	sub    %edx,%ecx
c01054ba:	89 ca                	mov    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c01054bc:	89 d6                	mov    %edx,%esi
c01054be:	c1 e6 0c             	shl    $0xc,%esi
c01054c1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01054c4:	89 d3                	mov    %edx,%ebx
c01054c6:	c1 e3 0c             	shl    $0xc,%ebx
c01054c9:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01054cc:	89 d1                	mov    %edx,%ecx
c01054ce:	c1 e1 0c             	shl    $0xc,%ecx
c01054d1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c01054d4:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01054d7:	29 d7                	sub    %edx,%edi
c01054d9:	89 fa                	mov    %edi,%edx
c01054db:	89 44 24 14          	mov    %eax,0x14(%esp)
c01054df:	89 74 24 10          	mov    %esi,0x10(%esp)
c01054e3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01054e7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01054eb:	89 54 24 04          	mov    %edx,0x4(%esp)
c01054ef:	c7 04 24 5c d3 10 c0 	movl   $0xc010d35c,(%esp)
c01054f6:	e8 d6 ad ff ff       	call   c01002d1 <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0)
c01054fb:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
c0105500:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105503:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105506:	89 d3                	mov    %edx,%ebx
c0105508:	c1 e3 0a             	shl    $0xa,%ebx
c010550b:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010550e:	89 d1                	mov    %edx,%ecx
c0105510:	c1 e1 0a             	shl    $0xa,%ecx
c0105513:	8d 55 d4             	lea    -0x2c(%ebp),%edx
c0105516:	89 54 24 14          	mov    %edx,0x14(%esp)
c010551a:	8d 55 d8             	lea    -0x28(%ebp),%edx
c010551d:	89 54 24 10          	mov    %edx,0x10(%esp)
c0105521:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0105525:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105529:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c010552d:	89 0c 24             	mov    %ecx,(%esp)
c0105530:	e8 38 fe ff ff       	call   c010536d <get_pgtable_items>
c0105535:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105538:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010553c:	0f 85 65 ff ff ff    	jne    c01054a7 <print_pgdir+0x84>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0)
c0105542:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
c0105547:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010554a:	8d 55 dc             	lea    -0x24(%ebp),%edx
c010554d:	89 54 24 14          	mov    %edx,0x14(%esp)
c0105551:	8d 55 e0             	lea    -0x20(%ebp),%edx
c0105554:	89 54 24 10          	mov    %edx,0x10(%esp)
c0105558:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c010555c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105560:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c0105567:	00 
c0105568:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010556f:	e8 f9 fd ff ff       	call   c010536d <get_pgtable_items>
c0105574:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105577:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010557b:	0f 85 c7 fe ff ff    	jne    c0105448 <print_pgdir+0x25>
        }
    }
    cprintf("--------------------- END ---------------------\n");
c0105581:	c7 04 24 80 d3 10 c0 	movl   $0xc010d380,(%esp)
c0105588:	e8 44 ad ff ff       	call   c01002d1 <cprintf>
}
c010558d:	90                   	nop
c010558e:	83 c4 4c             	add    $0x4c,%esp
c0105591:	5b                   	pop    %ebx
c0105592:	5e                   	pop    %esi
c0105593:	5f                   	pop    %edi
c0105594:	5d                   	pop    %ebp
c0105595:	c3                   	ret    

c0105596 <lock_init>:
#define local_intr_restore(x)   __intr_restore(x);

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
c0105596:	55                   	push   %ebp
c0105597:	89 e5                	mov    %esp,%ebp
    *lock = 0;
c0105599:	8b 45 08             	mov    0x8(%ebp),%eax
c010559c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
c01055a2:	90                   	nop
c01055a3:	5d                   	pop    %ebp
c01055a4:	c3                   	ret    

c01055a5 <mm_count>:
bool user_mem_check(struct mm_struct *mm, uintptr_t start, size_t len, bool write);
bool copy_from_user(struct mm_struct *mm, void *dst, const void *src, size_t len, bool writable);
bool copy_to_user(struct mm_struct *mm, void *dst, const void *src, size_t len);

static inline int
mm_count(struct mm_struct *mm) {
c01055a5:	55                   	push   %ebp
c01055a6:	89 e5                	mov    %esp,%ebp
    return mm->mm_count;
c01055a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01055ab:	8b 40 18             	mov    0x18(%eax),%eax
}
c01055ae:	5d                   	pop    %ebp
c01055af:	c3                   	ret    

c01055b0 <set_mm_count>:

static inline void
set_mm_count(struct mm_struct *mm, int val) {
c01055b0:	55                   	push   %ebp
c01055b1:	89 e5                	mov    %esp,%ebp
    mm->mm_count = val;
c01055b3:	8b 45 08             	mov    0x8(%ebp),%eax
c01055b6:	8b 55 0c             	mov    0xc(%ebp),%edx
c01055b9:	89 50 18             	mov    %edx,0x18(%eax)
}
c01055bc:	90                   	nop
c01055bd:	5d                   	pop    %ebp
c01055be:	c3                   	ret    

c01055bf <pa2page>:
pa2page(uintptr_t pa) {
c01055bf:	55                   	push   %ebp
c01055c0:	89 e5                	mov    %esp,%ebp
c01055c2:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c01055c5:	8b 45 08             	mov    0x8(%ebp),%eax
c01055c8:	c1 e8 0c             	shr    $0xc,%eax
c01055cb:	89 c2                	mov    %eax,%edx
c01055cd:	a1 80 1f 1b c0       	mov    0xc01b1f80,%eax
c01055d2:	39 c2                	cmp    %eax,%edx
c01055d4:	72 1c                	jb     c01055f2 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c01055d6:	c7 44 24 08 b4 d3 10 	movl   $0xc010d3b4,0x8(%esp)
c01055dd:	c0 
c01055de:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c01055e5:	00 
c01055e6:	c7 04 24 d3 d3 10 c0 	movl   $0xc010d3d3,(%esp)
c01055ed:	e8 4b ae ff ff       	call   c010043d <__panic>
    return &pages[PPN(pa)];
c01055f2:	a1 60 40 1b c0       	mov    0xc01b4060,%eax
c01055f7:	8b 55 08             	mov    0x8(%ebp),%edx
c01055fa:	c1 ea 0c             	shr    $0xc,%edx
c01055fd:	c1 e2 05             	shl    $0x5,%edx
c0105600:	01 d0                	add    %edx,%eax
}
c0105602:	c9                   	leave  
c0105603:	c3                   	ret    

c0105604 <pde2page>:
pde2page(pde_t pde) {
c0105604:	55                   	push   %ebp
c0105605:	89 e5                	mov    %esp,%ebp
c0105607:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c010560a:	8b 45 08             	mov    0x8(%ebp),%eax
c010560d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105612:	89 04 24             	mov    %eax,(%esp)
c0105615:	e8 a5 ff ff ff       	call   c01055bf <pa2page>
}
c010561a:	c9                   	leave  
c010561b:	c3                   	ret    

c010561c <mm_create>:
static void check_pgfault(void);

// mm_create -  alloc a mm_struct & initialize it.
struct mm_struct *
mm_create(void)
{
c010561c:	f3 0f 1e fb          	endbr32 
c0105620:	55                   	push   %ebp
c0105621:	89 e5                	mov    %esp,%ebp
c0105623:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
c0105626:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c010562d:	e8 db 24 00 00       	call   c0107b0d <kmalloc>
c0105632:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (mm != NULL)
c0105635:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105639:	74 7a                	je     c01056b5 <mm_create+0x99>
    {
        list_init(&(mm->mmap_list));
c010563b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010563e:	89 45 f0             	mov    %eax,-0x10(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0105641:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105644:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105647:	89 50 04             	mov    %edx,0x4(%eax)
c010564a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010564d:	8b 50 04             	mov    0x4(%eax),%edx
c0105650:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105653:	89 10                	mov    %edx,(%eax)
}
c0105655:	90                   	nop
        mm->mmap_cache = NULL;
c0105656:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105659:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        mm->pgdir = NULL;
c0105660:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105663:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        mm->map_count = 0;
c010566a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010566d:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)

        if (swap_init_ok)
c0105674:	a1 10 20 1b c0       	mov    0xc01b2010,%eax
c0105679:	85 c0                	test   %eax,%eax
c010567b:	74 0d                	je     c010568a <mm_create+0x6e>
            swap_init_mm(mm);
c010567d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105680:	89 04 24             	mov    %eax,(%esp)
c0105683:	e8 1e 13 00 00       	call   c01069a6 <swap_init_mm>
c0105688:	eb 0a                	jmp    c0105694 <mm_create+0x78>
        else
            mm->sm_priv = NULL;
c010568a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010568d:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

        set_mm_count(mm, 0);
c0105694:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010569b:	00 
c010569c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010569f:	89 04 24             	mov    %eax,(%esp)
c01056a2:	e8 09 ff ff ff       	call   c01055b0 <set_mm_count>
        lock_init(&(mm->mm_lock));
c01056a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01056aa:	83 c0 1c             	add    $0x1c,%eax
c01056ad:	89 04 24             	mov    %eax,(%esp)
c01056b0:	e8 e1 fe ff ff       	call   c0105596 <lock_init>
    }
    return mm;
c01056b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01056b8:	c9                   	leave  
c01056b9:	c3                   	ret    

c01056ba <vma_create>:

// vma_create - alloc a vma_struct & initialize it. (addr range: vm_start~vm_end)
struct vma_struct *
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags)
{
c01056ba:	f3 0f 1e fb          	endbr32 
c01056be:	55                   	push   %ebp
c01056bf:	89 e5                	mov    %esp,%ebp
c01056c1:	83 ec 28             	sub    $0x28,%esp
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
c01056c4:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
c01056cb:	e8 3d 24 00 00       	call   c0107b0d <kmalloc>
c01056d0:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (vma != NULL)
c01056d3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01056d7:	74 1b                	je     c01056f4 <vma_create+0x3a>
    {
        vma->vm_start = vm_start;
c01056d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01056dc:	8b 55 08             	mov    0x8(%ebp),%edx
c01056df:	89 50 04             	mov    %edx,0x4(%eax)
        vma->vm_end = vm_end;
c01056e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01056e5:	8b 55 0c             	mov    0xc(%ebp),%edx
c01056e8:	89 50 08             	mov    %edx,0x8(%eax)
        vma->vm_flags = vm_flags;
c01056eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01056ee:	8b 55 10             	mov    0x10(%ebp),%edx
c01056f1:	89 50 0c             	mov    %edx,0xc(%eax)
    }
    return vma;
c01056f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01056f7:	c9                   	leave  
c01056f8:	c3                   	ret    

c01056f9 <find_vma>:

// find_vma - find a vma  (vma->vm_start <= addr <= vma_vm_end)
struct vma_struct *
find_vma(struct mm_struct *mm, uintptr_t addr)
{
c01056f9:	f3 0f 1e fb          	endbr32 
c01056fd:	55                   	push   %ebp
c01056fe:	89 e5                	mov    %esp,%ebp
c0105700:	83 ec 20             	sub    $0x20,%esp
    struct vma_struct *vma = NULL;
c0105703:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    if (mm != NULL)
c010570a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010570e:	0f 84 95 00 00 00    	je     c01057a9 <find_vma+0xb0>
    {
        vma = mm->mmap_cache;
c0105714:	8b 45 08             	mov    0x8(%ebp),%eax
c0105717:	8b 40 08             	mov    0x8(%eax),%eax
c010571a:	89 45 fc             	mov    %eax,-0x4(%ebp)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
c010571d:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0105721:	74 16                	je     c0105739 <find_vma+0x40>
c0105723:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105726:	8b 40 04             	mov    0x4(%eax),%eax
c0105729:	39 45 0c             	cmp    %eax,0xc(%ebp)
c010572c:	72 0b                	jb     c0105739 <find_vma+0x40>
c010572e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105731:	8b 40 08             	mov    0x8(%eax),%eax
c0105734:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0105737:	72 61                	jb     c010579a <find_vma+0xa1>
        {
            bool found = 0;
c0105739:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
            list_entry_t *list = &(mm->mmap_list), *le = list;
c0105740:	8b 45 08             	mov    0x8(%ebp),%eax
c0105743:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105746:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105749:	89 45 f4             	mov    %eax,-0xc(%ebp)
            while ((le = list_next(le)) != list)
c010574c:	eb 28                	jmp    c0105776 <find_vma+0x7d>
            {
                vma = le2vma(le, list_link);
c010574e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105751:	83 e8 10             	sub    $0x10,%eax
c0105754:	89 45 fc             	mov    %eax,-0x4(%ebp)
                if (vma->vm_start <= addr && addr < vma->vm_end)
c0105757:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010575a:	8b 40 04             	mov    0x4(%eax),%eax
c010575d:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0105760:	72 14                	jb     c0105776 <find_vma+0x7d>
c0105762:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105765:	8b 40 08             	mov    0x8(%eax),%eax
c0105768:	39 45 0c             	cmp    %eax,0xc(%ebp)
c010576b:	73 09                	jae    c0105776 <find_vma+0x7d>
                {
                    found = 1;
c010576d:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%ebp)
                    break;
c0105774:	eb 17                	jmp    c010578d <find_vma+0x94>
c0105776:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105779:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c010577c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010577f:	8b 40 04             	mov    0x4(%eax),%eax
            while ((le = list_next(le)) != list)
c0105782:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105785:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105788:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c010578b:	75 c1                	jne    c010574e <find_vma+0x55>
                }
            }
            if (!found)
c010578d:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
c0105791:	75 07                	jne    c010579a <find_vma+0xa1>
            {
                vma = NULL;
c0105793:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
            }
        }
        if (vma != NULL)
c010579a:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c010579e:	74 09                	je     c01057a9 <find_vma+0xb0>
        {
            mm->mmap_cache = vma;
c01057a0:	8b 45 08             	mov    0x8(%ebp),%eax
c01057a3:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01057a6:	89 50 08             	mov    %edx,0x8(%eax)
        }
    }
    return vma;
c01057a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01057ac:	c9                   	leave  
c01057ad:	c3                   	ret    

c01057ae <check_vma_overlap>:

// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
{
c01057ae:	55                   	push   %ebp
c01057af:	89 e5                	mov    %esp,%ebp
c01057b1:	83 ec 18             	sub    $0x18,%esp
    assert(prev->vm_start < prev->vm_end);
c01057b4:	8b 45 08             	mov    0x8(%ebp),%eax
c01057b7:	8b 50 04             	mov    0x4(%eax),%edx
c01057ba:	8b 45 08             	mov    0x8(%ebp),%eax
c01057bd:	8b 40 08             	mov    0x8(%eax),%eax
c01057c0:	39 c2                	cmp    %eax,%edx
c01057c2:	72 24                	jb     c01057e8 <check_vma_overlap+0x3a>
c01057c4:	c7 44 24 0c e1 d3 10 	movl   $0xc010d3e1,0xc(%esp)
c01057cb:	c0 
c01057cc:	c7 44 24 08 ff d3 10 	movl   $0xc010d3ff,0x8(%esp)
c01057d3:	c0 
c01057d4:	c7 44 24 04 77 00 00 	movl   $0x77,0x4(%esp)
c01057db:	00 
c01057dc:	c7 04 24 14 d4 10 c0 	movl   $0xc010d414,(%esp)
c01057e3:	e8 55 ac ff ff       	call   c010043d <__panic>
    assert(prev->vm_end <= next->vm_start);
c01057e8:	8b 45 08             	mov    0x8(%ebp),%eax
c01057eb:	8b 50 08             	mov    0x8(%eax),%edx
c01057ee:	8b 45 0c             	mov    0xc(%ebp),%eax
c01057f1:	8b 40 04             	mov    0x4(%eax),%eax
c01057f4:	39 c2                	cmp    %eax,%edx
c01057f6:	76 24                	jbe    c010581c <check_vma_overlap+0x6e>
c01057f8:	c7 44 24 0c 24 d4 10 	movl   $0xc010d424,0xc(%esp)
c01057ff:	c0 
c0105800:	c7 44 24 08 ff d3 10 	movl   $0xc010d3ff,0x8(%esp)
c0105807:	c0 
c0105808:	c7 44 24 04 78 00 00 	movl   $0x78,0x4(%esp)
c010580f:	00 
c0105810:	c7 04 24 14 d4 10 c0 	movl   $0xc010d414,(%esp)
c0105817:	e8 21 ac ff ff       	call   c010043d <__panic>
    assert(next->vm_start < next->vm_end);
c010581c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010581f:	8b 50 04             	mov    0x4(%eax),%edx
c0105822:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105825:	8b 40 08             	mov    0x8(%eax),%eax
c0105828:	39 c2                	cmp    %eax,%edx
c010582a:	72 24                	jb     c0105850 <check_vma_overlap+0xa2>
c010582c:	c7 44 24 0c 43 d4 10 	movl   $0xc010d443,0xc(%esp)
c0105833:	c0 
c0105834:	c7 44 24 08 ff d3 10 	movl   $0xc010d3ff,0x8(%esp)
c010583b:	c0 
c010583c:	c7 44 24 04 79 00 00 	movl   $0x79,0x4(%esp)
c0105843:	00 
c0105844:	c7 04 24 14 d4 10 c0 	movl   $0xc010d414,(%esp)
c010584b:	e8 ed ab ff ff       	call   c010043d <__panic>
}
c0105850:	90                   	nop
c0105851:	c9                   	leave  
c0105852:	c3                   	ret    

c0105853 <insert_vma_struct>:

// insert_vma_struct -insert vma in mm's list link
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma)
{
c0105853:	f3 0f 1e fb          	endbr32 
c0105857:	55                   	push   %ebp
c0105858:	89 e5                	mov    %esp,%ebp
c010585a:	83 ec 48             	sub    $0x48,%esp
    assert(vma->vm_start < vma->vm_end);
c010585d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105860:	8b 50 04             	mov    0x4(%eax),%edx
c0105863:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105866:	8b 40 08             	mov    0x8(%eax),%eax
c0105869:	39 c2                	cmp    %eax,%edx
c010586b:	72 24                	jb     c0105891 <insert_vma_struct+0x3e>
c010586d:	c7 44 24 0c 61 d4 10 	movl   $0xc010d461,0xc(%esp)
c0105874:	c0 
c0105875:	c7 44 24 08 ff d3 10 	movl   $0xc010d3ff,0x8(%esp)
c010587c:	c0 
c010587d:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
c0105884:	00 
c0105885:	c7 04 24 14 d4 10 c0 	movl   $0xc010d414,(%esp)
c010588c:	e8 ac ab ff ff       	call   c010043d <__panic>
    list_entry_t *list = &(mm->mmap_list);
c0105891:	8b 45 08             	mov    0x8(%ebp),%eax
c0105894:	89 45 ec             	mov    %eax,-0x14(%ebp)
    list_entry_t *le_prev = list, *le_next;
c0105897:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010589a:	89 45 f4             	mov    %eax,-0xc(%ebp)

    list_entry_t *le = list;
c010589d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01058a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while ((le = list_next(le)) != list)
c01058a3:	eb 1f                	jmp    c01058c4 <insert_vma_struct+0x71>
    {
        struct vma_struct *mmap_prev = le2vma(le, list_link);
c01058a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01058a8:	83 e8 10             	sub    $0x10,%eax
c01058ab:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if (mmap_prev->vm_start > vma->vm_start)
c01058ae:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01058b1:	8b 50 04             	mov    0x4(%eax),%edx
c01058b4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01058b7:	8b 40 04             	mov    0x4(%eax),%eax
c01058ba:	39 c2                	cmp    %eax,%edx
c01058bc:	77 1f                	ja     c01058dd <insert_vma_struct+0x8a>
        {
            break;
        }
        le_prev = le;
c01058be:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01058c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01058c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01058c7:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01058ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01058cd:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != list)
c01058d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01058d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01058d6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01058d9:	75 ca                	jne    c01058a5 <insert_vma_struct+0x52>
c01058db:	eb 01                	jmp    c01058de <insert_vma_struct+0x8b>
            break;
c01058dd:	90                   	nop
c01058de:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01058e1:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01058e4:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01058e7:	8b 40 04             	mov    0x4(%eax),%eax
    }

    le_next = list_next(le_prev);
c01058ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    /* check overlap */
    if (le_prev != list)
c01058ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01058f0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01058f3:	74 15                	je     c010590a <insert_vma_struct+0xb7>
    {
        check_vma_overlap(le2vma(le_prev, list_link), vma);
c01058f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01058f8:	8d 50 f0             	lea    -0x10(%eax),%edx
c01058fb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01058fe:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105902:	89 14 24             	mov    %edx,(%esp)
c0105905:	e8 a4 fe ff ff       	call   c01057ae <check_vma_overlap>
    }
    if (le_next != list)
c010590a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010590d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0105910:	74 15                	je     c0105927 <insert_vma_struct+0xd4>
    {
        check_vma_overlap(vma, le2vma(le_next, list_link));
c0105912:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105915:	83 e8 10             	sub    $0x10,%eax
c0105918:	89 44 24 04          	mov    %eax,0x4(%esp)
c010591c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010591f:	89 04 24             	mov    %eax,(%esp)
c0105922:	e8 87 fe ff ff       	call   c01057ae <check_vma_overlap>
    }

    vma->vm_mm = mm;
c0105927:	8b 45 0c             	mov    0xc(%ebp),%eax
c010592a:	8b 55 08             	mov    0x8(%ebp),%edx
c010592d:	89 10                	mov    %edx,(%eax)
    list_add_after(le_prev, &(vma->list_link));
c010592f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105932:	8d 50 10             	lea    0x10(%eax),%edx
c0105935:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105938:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010593b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
    __list_add(elm, listelm, listelm->next);
c010593e:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105941:	8b 40 04             	mov    0x4(%eax),%eax
c0105944:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105947:	89 55 d0             	mov    %edx,-0x30(%ebp)
c010594a:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010594d:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0105950:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0105953:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0105956:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0105959:	89 10                	mov    %edx,(%eax)
c010595b:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010595e:	8b 10                	mov    (%eax),%edx
c0105960:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0105963:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0105966:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105969:	8b 55 c8             	mov    -0x38(%ebp),%edx
c010596c:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010596f:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105972:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0105975:	89 10                	mov    %edx,(%eax)
}
c0105977:	90                   	nop
}
c0105978:	90                   	nop

    mm->map_count++;
c0105979:	8b 45 08             	mov    0x8(%ebp),%eax
c010597c:	8b 40 10             	mov    0x10(%eax),%eax
c010597f:	8d 50 01             	lea    0x1(%eax),%edx
c0105982:	8b 45 08             	mov    0x8(%ebp),%eax
c0105985:	89 50 10             	mov    %edx,0x10(%eax)
}
c0105988:	90                   	nop
c0105989:	c9                   	leave  
c010598a:	c3                   	ret    

c010598b <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void mm_destroy(struct mm_struct *mm)
{
c010598b:	f3 0f 1e fb          	endbr32 
c010598f:	55                   	push   %ebp
c0105990:	89 e5                	mov    %esp,%ebp
c0105992:	83 ec 38             	sub    $0x38,%esp
    assert(mm_count(mm) == 0);
c0105995:	8b 45 08             	mov    0x8(%ebp),%eax
c0105998:	89 04 24             	mov    %eax,(%esp)
c010599b:	e8 05 fc ff ff       	call   c01055a5 <mm_count>
c01059a0:	85 c0                	test   %eax,%eax
c01059a2:	74 24                	je     c01059c8 <mm_destroy+0x3d>
c01059a4:	c7 44 24 0c 7d d4 10 	movl   $0xc010d47d,0xc(%esp)
c01059ab:	c0 
c01059ac:	c7 44 24 08 ff d3 10 	movl   $0xc010d3ff,0x8(%esp)
c01059b3:	c0 
c01059b4:	c7 44 24 04 a3 00 00 	movl   $0xa3,0x4(%esp)
c01059bb:	00 
c01059bc:	c7 04 24 14 d4 10 c0 	movl   $0xc010d414,(%esp)
c01059c3:	e8 75 aa ff ff       	call   c010043d <__panic>

    list_entry_t *list = &(mm->mmap_list), *le;
c01059c8:	8b 45 08             	mov    0x8(%ebp),%eax
c01059cb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_next(list)) != list)
c01059ce:	eb 38                	jmp    c0105a08 <mm_destroy+0x7d>
c01059d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01059d3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    __list_del(listelm->prev, listelm->next);
c01059d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01059d9:	8b 40 04             	mov    0x4(%eax),%eax
c01059dc:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01059df:	8b 12                	mov    (%edx),%edx
c01059e1:	89 55 e8             	mov    %edx,-0x18(%ebp)
c01059e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c01059e7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01059ea:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01059ed:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01059f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01059f3:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01059f6:	89 10                	mov    %edx,(%eax)
}
c01059f8:	90                   	nop
}
c01059f9:	90                   	nop
    {
        list_del(le);
        kfree(le2vma(le, list_link)); //kfree vma
c01059fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01059fd:	83 e8 10             	sub    $0x10,%eax
c0105a00:	89 04 24             	mov    %eax,(%esp)
c0105a03:	e8 24 21 00 00       	call   c0107b2c <kfree>
c0105a08:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a0b:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return listelm->next;
c0105a0e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105a11:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(list)) != list)
c0105a14:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105a17:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105a1a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0105a1d:	75 b1                	jne    c01059d0 <mm_destroy+0x45>
    }
    kfree(mm); //kfree mm
c0105a1f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a22:	89 04 24             	mov    %eax,(%esp)
c0105a25:	e8 02 21 00 00       	call   c0107b2c <kfree>
    mm = NULL;
c0105a2a:	c7 45 08 00 00 00 00 	movl   $0x0,0x8(%ebp)
}
c0105a31:	90                   	nop
c0105a32:	c9                   	leave  
c0105a33:	c3                   	ret    

c0105a34 <mm_map>:

int mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
           struct vma_struct **vma_store)
{
c0105a34:	f3 0f 1e fb          	endbr32 
c0105a38:	55                   	push   %ebp
c0105a39:	89 e5                	mov    %esp,%ebp
c0105a3b:	83 ec 38             	sub    $0x38,%esp
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
c0105a3e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a41:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105a44:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105a47:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105a4c:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105a4f:	c7 45 e8 00 10 00 00 	movl   $0x1000,-0x18(%ebp)
c0105a56:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105a59:	8b 45 10             	mov    0x10(%ebp),%eax
c0105a5c:	01 c2                	add    %eax,%edx
c0105a5e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105a61:	01 d0                	add    %edx,%eax
c0105a63:	48                   	dec    %eax
c0105a64:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105a67:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105a6a:	ba 00 00 00 00       	mov    $0x0,%edx
c0105a6f:	f7 75 e8             	divl   -0x18(%ebp)
c0105a72:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105a75:	29 d0                	sub    %edx,%eax
c0105a77:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if (!USER_ACCESS(start, end))
c0105a7a:	81 7d ec ff ff 1f 00 	cmpl   $0x1fffff,-0x14(%ebp)
c0105a81:	76 11                	jbe    c0105a94 <mm_map+0x60>
c0105a83:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105a86:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0105a89:	73 09                	jae    c0105a94 <mm_map+0x60>
c0105a8b:	81 7d e0 00 00 00 b0 	cmpl   $0xb0000000,-0x20(%ebp)
c0105a92:	76 0a                	jbe    c0105a9e <mm_map+0x6a>
    {
        return -E_INVAL;
c0105a94:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c0105a99:	e9 b0 00 00 00       	jmp    c0105b4e <mm_map+0x11a>
    }

    assert(mm != NULL);
c0105a9e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105aa2:	75 24                	jne    c0105ac8 <mm_map+0x94>
c0105aa4:	c7 44 24 0c 8f d4 10 	movl   $0xc010d48f,0xc(%esp)
c0105aab:	c0 
c0105aac:	c7 44 24 08 ff d3 10 	movl   $0xc010d3ff,0x8(%esp)
c0105ab3:	c0 
c0105ab4:	c7 44 24 04 b8 00 00 	movl   $0xb8,0x4(%esp)
c0105abb:	00 
c0105abc:	c7 04 24 14 d4 10 c0 	movl   $0xc010d414,(%esp)
c0105ac3:	e8 75 a9 ff ff       	call   c010043d <__panic>

    int ret = -E_INVAL;
c0105ac8:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start)
c0105acf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105ad2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105ad6:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ad9:	89 04 24             	mov    %eax,(%esp)
c0105adc:	e8 18 fc ff ff       	call   c01056f9 <find_vma>
c0105ae1:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0105ae4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0105ae8:	74 0b                	je     c0105af5 <mm_map+0xc1>
c0105aea:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105aed:	8b 40 04             	mov    0x4(%eax),%eax
c0105af0:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0105af3:	77 52                	ja     c0105b47 <mm_map+0x113>
    {
        goto out;
    }
    ret = -E_NO_MEM;
c0105af5:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

    if ((vma = vma_create(start, end, vm_flags)) == NULL)
c0105afc:	8b 45 14             	mov    0x14(%ebp),%eax
c0105aff:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105b03:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105b06:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105b0a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105b0d:	89 04 24             	mov    %eax,(%esp)
c0105b10:	e8 a5 fb ff ff       	call   c01056ba <vma_create>
c0105b15:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0105b18:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0105b1c:	74 2c                	je     c0105b4a <mm_map+0x116>
    {
        goto out;
    }
    insert_vma_struct(mm, vma);
c0105b1e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105b21:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105b25:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b28:	89 04 24             	mov    %eax,(%esp)
c0105b2b:	e8 23 fd ff ff       	call   c0105853 <insert_vma_struct>
    if (vma_store != NULL)
c0105b30:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0105b34:	74 08                	je     c0105b3e <mm_map+0x10a>
    {
        *vma_store = vma;
c0105b36:	8b 45 18             	mov    0x18(%ebp),%eax
c0105b39:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105b3c:	89 10                	mov    %edx,(%eax)
    }
    ret = 0;
c0105b3e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0105b45:	eb 04                	jmp    c0105b4b <mm_map+0x117>
        goto out;
c0105b47:	90                   	nop
c0105b48:	eb 01                	jmp    c0105b4b <mm_map+0x117>
        goto out;
c0105b4a:	90                   	nop

out:
    return ret;
c0105b4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105b4e:	c9                   	leave  
c0105b4f:	c3                   	ret    

c0105b50 <dup_mmap>:

int dup_mmap(struct mm_struct *to, struct mm_struct *from)
{
c0105b50:	f3 0f 1e fb          	endbr32 
c0105b54:	55                   	push   %ebp
c0105b55:	89 e5                	mov    %esp,%ebp
c0105b57:	56                   	push   %esi
c0105b58:	53                   	push   %ebx
c0105b59:	83 ec 40             	sub    $0x40,%esp
    assert(to != NULL && from != NULL);
c0105b5c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105b60:	74 06                	je     c0105b68 <dup_mmap+0x18>
c0105b62:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105b66:	75 24                	jne    c0105b8c <dup_mmap+0x3c>
c0105b68:	c7 44 24 0c 9a d4 10 	movl   $0xc010d49a,0xc(%esp)
c0105b6f:	c0 
c0105b70:	c7 44 24 08 ff d3 10 	movl   $0xc010d3ff,0x8(%esp)
c0105b77:	c0 
c0105b78:	c7 44 24 04 d4 00 00 	movl   $0xd4,0x4(%esp)
c0105b7f:	00 
c0105b80:	c7 04 24 14 d4 10 c0 	movl   $0xc010d414,(%esp)
c0105b87:	e8 b1 a8 ff ff       	call   c010043d <__panic>
    list_entry_t *list = &(from->mmap_list), *le = list;
c0105b8c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b8f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105b92:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105b95:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_prev(le)) != list)
c0105b98:	e9 92 00 00 00       	jmp    c0105c2f <dup_mmap+0xdf>
    {
        struct vma_struct *vma, *nvma;
        vma = le2vma(le, list_link);
c0105b9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105ba0:	83 e8 10             	sub    $0x10,%eax
c0105ba3:	89 45 ec             	mov    %eax,-0x14(%ebp)
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
c0105ba6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105ba9:	8b 48 0c             	mov    0xc(%eax),%ecx
c0105bac:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105baf:	8b 50 08             	mov    0x8(%eax),%edx
c0105bb2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105bb5:	8b 40 04             	mov    0x4(%eax),%eax
c0105bb8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0105bbc:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105bc0:	89 04 24             	mov    %eax,(%esp)
c0105bc3:	e8 f2 fa ff ff       	call   c01056ba <vma_create>
c0105bc8:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if (nvma == NULL)
c0105bcb:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105bcf:	75 07                	jne    c0105bd8 <dup_mmap+0x88>
        {
            return -E_NO_MEM;
c0105bd1:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0105bd6:	eb 76                	jmp    c0105c4e <dup_mmap+0xfe>
        }

        insert_vma_struct(to, nvma);
c0105bd8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105bdb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105bdf:	8b 45 08             	mov    0x8(%ebp),%eax
c0105be2:	89 04 24             	mov    %eax,(%esp)
c0105be5:	e8 69 fc ff ff       	call   c0105853 <insert_vma_struct>

        bool share = 0;
c0105bea:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0)
c0105bf1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105bf4:	8b 58 08             	mov    0x8(%eax),%ebx
c0105bf7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105bfa:	8b 48 04             	mov    0x4(%eax),%ecx
c0105bfd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c00:	8b 50 0c             	mov    0xc(%eax),%edx
c0105c03:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c06:	8b 40 0c             	mov    0xc(%eax),%eax
c0105c09:	8b 75 e4             	mov    -0x1c(%ebp),%esi
c0105c0c:	89 74 24 10          	mov    %esi,0x10(%esp)
c0105c10:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0105c14:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0105c18:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105c1c:	89 04 24             	mov    %eax,(%esp)
c0105c1f:	e8 22 e8 ff ff       	call   c0104446 <copy_range>
c0105c24:	85 c0                	test   %eax,%eax
c0105c26:	74 07                	je     c0105c2f <dup_mmap+0xdf>
        {
            return -E_NO_MEM;
c0105c28:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0105c2d:	eb 1f                	jmp    c0105c4e <dup_mmap+0xfe>
c0105c2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105c32:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return listelm->prev;
c0105c35:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105c38:	8b 00                	mov    (%eax),%eax
    while ((le = list_prev(le)) != list)
c0105c3a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105c3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105c40:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0105c43:	0f 85 54 ff ff ff    	jne    c0105b9d <dup_mmap+0x4d>
        }
    }
    return 0;
c0105c49:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105c4e:	83 c4 40             	add    $0x40,%esp
c0105c51:	5b                   	pop    %ebx
c0105c52:	5e                   	pop    %esi
c0105c53:	5d                   	pop    %ebp
c0105c54:	c3                   	ret    

c0105c55 <exit_mmap>:

void exit_mmap(struct mm_struct *mm)
{
c0105c55:	f3 0f 1e fb          	endbr32 
c0105c59:	55                   	push   %ebp
c0105c5a:	89 e5                	mov    %esp,%ebp
c0105c5c:	83 ec 38             	sub    $0x38,%esp
    assert(mm != NULL && mm_count(mm) == 0);
c0105c5f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105c63:	74 0f                	je     c0105c74 <exit_mmap+0x1f>
c0105c65:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c68:	89 04 24             	mov    %eax,(%esp)
c0105c6b:	e8 35 f9 ff ff       	call   c01055a5 <mm_count>
c0105c70:	85 c0                	test   %eax,%eax
c0105c72:	74 24                	je     c0105c98 <exit_mmap+0x43>
c0105c74:	c7 44 24 0c b8 d4 10 	movl   $0xc010d4b8,0xc(%esp)
c0105c7b:	c0 
c0105c7c:	c7 44 24 08 ff d3 10 	movl   $0xc010d3ff,0x8(%esp)
c0105c83:	c0 
c0105c84:	c7 44 24 04 ed 00 00 	movl   $0xed,0x4(%esp)
c0105c8b:	00 
c0105c8c:	c7 04 24 14 d4 10 c0 	movl   $0xc010d414,(%esp)
c0105c93:	e8 a5 a7 ff ff       	call   c010043d <__panic>
    pde_t *pgdir = mm->pgdir;
c0105c98:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c9b:	8b 40 0c             	mov    0xc(%eax),%eax
c0105c9e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    list_entry_t *list = &(mm->mmap_list), *le = list;
c0105ca1:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ca4:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105ca7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105caa:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_next(le)) != list)
c0105cad:	eb 28                	jmp    c0105cd7 <exit_mmap+0x82>
    {
        struct vma_struct *vma = le2vma(le, list_link);
c0105caf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105cb2:	83 e8 10             	sub    $0x10,%eax
c0105cb5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
c0105cb8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105cbb:	8b 50 08             	mov    0x8(%eax),%edx
c0105cbe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105cc1:	8b 40 04             	mov    0x4(%eax),%eax
c0105cc4:	89 54 24 08          	mov    %edx,0x8(%esp)
c0105cc8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105ccc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105ccf:	89 04 24             	mov    %eax,(%esp)
c0105cd2:	e8 6a e5 ff ff       	call   c0104241 <unmap_range>
c0105cd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105cda:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return listelm->next;
c0105cdd:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105ce0:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != list)
c0105ce3:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105ce6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105ce9:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0105cec:	75 c1                	jne    c0105caf <exit_mmap+0x5a>
    }
    while ((le = list_next(le)) != list)
c0105cee:	eb 28                	jmp    c0105d18 <exit_mmap+0xc3>
    {
        struct vma_struct *vma = le2vma(le, list_link);
c0105cf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105cf3:	83 e8 10             	sub    $0x10,%eax
c0105cf6:	89 45 e8             	mov    %eax,-0x18(%ebp)
        exit_range(pgdir, vma->vm_start, vma->vm_end);
c0105cf9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105cfc:	8b 50 08             	mov    0x8(%eax),%edx
c0105cff:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105d02:	8b 40 04             	mov    0x4(%eax),%eax
c0105d05:	89 54 24 08          	mov    %edx,0x8(%esp)
c0105d09:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105d0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105d10:	89 04 24             	mov    %eax,(%esp)
c0105d13:	e8 22 e6 ff ff       	call   c010433a <exit_range>
c0105d18:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105d1b:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0105d1e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105d21:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != list)
c0105d24:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105d27:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105d2a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0105d2d:	75 c1                	jne    c0105cf0 <exit_mmap+0x9b>
    }
}
c0105d2f:	90                   	nop
c0105d30:	90                   	nop
c0105d31:	c9                   	leave  
c0105d32:	c3                   	ret    

c0105d33 <copy_from_user>:

bool copy_from_user(struct mm_struct *mm, void *dst, const void *src, size_t len, bool writable)
{
c0105d33:	f3 0f 1e fb          	endbr32 
c0105d37:	55                   	push   %ebp
c0105d38:	89 e5                	mov    %esp,%ebp
c0105d3a:	83 ec 18             	sub    $0x18,%esp
    if (!user_mem_check(mm, (uintptr_t)src, len, writable))
c0105d3d:	8b 45 10             	mov    0x10(%ebp),%eax
c0105d40:	8b 55 18             	mov    0x18(%ebp),%edx
c0105d43:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0105d47:	8b 55 14             	mov    0x14(%ebp),%edx
c0105d4a:	89 54 24 08          	mov    %edx,0x8(%esp)
c0105d4e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105d52:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d55:	89 04 24             	mov    %eax,(%esp)
c0105d58:	e8 f3 09 00 00       	call   c0106750 <user_mem_check>
c0105d5d:	85 c0                	test   %eax,%eax
c0105d5f:	75 07                	jne    c0105d68 <copy_from_user+0x35>
    {
        return 0;
c0105d61:	b8 00 00 00 00       	mov    $0x0,%eax
c0105d66:	eb 1e                	jmp    c0105d86 <copy_from_user+0x53>
    }
    memcpy(dst, src, len);
c0105d68:	8b 45 14             	mov    0x14(%ebp),%eax
c0105d6b:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105d6f:	8b 45 10             	mov    0x10(%ebp),%eax
c0105d72:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105d76:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d79:	89 04 24             	mov    %eax,(%esp)
c0105d7c:	e8 13 5d 00 00       	call   c010ba94 <memcpy>
    return 1;
c0105d81:	b8 01 00 00 00       	mov    $0x1,%eax
}
c0105d86:	c9                   	leave  
c0105d87:	c3                   	ret    

c0105d88 <copy_to_user>:

bool copy_to_user(struct mm_struct *mm, void *dst, const void *src, size_t len)
{
c0105d88:	f3 0f 1e fb          	endbr32 
c0105d8c:	55                   	push   %ebp
c0105d8d:	89 e5                	mov    %esp,%ebp
c0105d8f:	83 ec 18             	sub    $0x18,%esp
    if (!user_mem_check(mm, (uintptr_t)dst, len, 1))
c0105d92:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d95:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
c0105d9c:	00 
c0105d9d:	8b 55 14             	mov    0x14(%ebp),%edx
c0105da0:	89 54 24 08          	mov    %edx,0x8(%esp)
c0105da4:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105da8:	8b 45 08             	mov    0x8(%ebp),%eax
c0105dab:	89 04 24             	mov    %eax,(%esp)
c0105dae:	e8 9d 09 00 00       	call   c0106750 <user_mem_check>
c0105db3:	85 c0                	test   %eax,%eax
c0105db5:	75 07                	jne    c0105dbe <copy_to_user+0x36>
    {
        return 0;
c0105db7:	b8 00 00 00 00       	mov    $0x0,%eax
c0105dbc:	eb 1e                	jmp    c0105ddc <copy_to_user+0x54>
    }
    memcpy(dst, src, len);
c0105dbe:	8b 45 14             	mov    0x14(%ebp),%eax
c0105dc1:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105dc5:	8b 45 10             	mov    0x10(%ebp),%eax
c0105dc8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105dcc:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105dcf:	89 04 24             	mov    %eax,(%esp)
c0105dd2:	e8 bd 5c 00 00       	call   c010ba94 <memcpy>
    return 1;
c0105dd7:	b8 01 00 00 00       	mov    $0x1,%eax
}
c0105ddc:	c9                   	leave  
c0105ddd:	c3                   	ret    

c0105dde <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void vmm_init(void)
{
c0105dde:	f3 0f 1e fb          	endbr32 
c0105de2:	55                   	push   %ebp
c0105de3:	89 e5                	mov    %esp,%ebp
c0105de5:	83 ec 08             	sub    $0x8,%esp
    check_vmm();
c0105de8:	e8 03 00 00 00       	call   c0105df0 <check_vmm>
}
c0105ded:	90                   	nop
c0105dee:	c9                   	leave  
c0105def:	c3                   	ret    

c0105df0 <check_vmm>:

// check_vmm - check correctness of vmm
static void
check_vmm(void)
{
c0105df0:	f3 0f 1e fb          	endbr32 
c0105df4:	55                   	push   %ebp
c0105df5:	89 e5                	mov    %esp,%ebp
c0105df7:	83 ec 28             	sub    $0x28,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0105dfa:	e8 1c dc ff ff       	call   c0103a1b <nr_free_pages>
c0105dff:	89 45 f4             	mov    %eax,-0xc(%ebp)

    check_vma_struct();
c0105e02:	e8 14 00 00 00       	call   c0105e1b <check_vma_struct>
    check_pgfault();
c0105e07:	e8 a5 04 00 00       	call   c01062b1 <check_pgfault>

    //    assert(nr_free_pages_store == nr_free_pages());

    cprintf("check_vmm() succeeded.\n");
c0105e0c:	c7 04 24 d8 d4 10 c0 	movl   $0xc010d4d8,(%esp)
c0105e13:	e8 b9 a4 ff ff       	call   c01002d1 <cprintf>
}
c0105e18:	90                   	nop
c0105e19:	c9                   	leave  
c0105e1a:	c3                   	ret    

c0105e1b <check_vma_struct>:

static void
check_vma_struct(void)
{
c0105e1b:	f3 0f 1e fb          	endbr32 
c0105e1f:	55                   	push   %ebp
c0105e20:	89 e5                	mov    %esp,%ebp
c0105e22:	83 ec 68             	sub    $0x68,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0105e25:	e8 f1 db ff ff       	call   c0103a1b <nr_free_pages>
c0105e2a:	89 45 ec             	mov    %eax,-0x14(%ebp)

    struct mm_struct *mm = mm_create();
c0105e2d:	e8 ea f7 ff ff       	call   c010561c <mm_create>
c0105e32:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(mm != NULL);
c0105e35:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105e39:	75 24                	jne    c0105e5f <check_vma_struct+0x44>
c0105e3b:	c7 44 24 0c 8f d4 10 	movl   $0xc010d48f,0xc(%esp)
c0105e42:	c0 
c0105e43:	c7 44 24 08 ff d3 10 	movl   $0xc010d3ff,0x8(%esp)
c0105e4a:	c0 
c0105e4b:	c7 44 24 04 2b 01 00 	movl   $0x12b,0x4(%esp)
c0105e52:	00 
c0105e53:	c7 04 24 14 d4 10 c0 	movl   $0xc010d414,(%esp)
c0105e5a:	e8 de a5 ff ff       	call   c010043d <__panic>

    int step1 = 10, step2 = step1 * 10;
c0105e5f:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%ebp)
c0105e66:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105e69:	89 d0                	mov    %edx,%eax
c0105e6b:	c1 e0 02             	shl    $0x2,%eax
c0105e6e:	01 d0                	add    %edx,%eax
c0105e70:	01 c0                	add    %eax,%eax
c0105e72:	89 45 e0             	mov    %eax,-0x20(%ebp)

    int i;
    for (i = step1; i >= 1; i--)
c0105e75:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105e78:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105e7b:	eb 6f                	jmp    c0105eec <check_vma_struct+0xd1>
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c0105e7d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105e80:	89 d0                	mov    %edx,%eax
c0105e82:	c1 e0 02             	shl    $0x2,%eax
c0105e85:	01 d0                	add    %edx,%eax
c0105e87:	83 c0 02             	add    $0x2,%eax
c0105e8a:	89 c1                	mov    %eax,%ecx
c0105e8c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105e8f:	89 d0                	mov    %edx,%eax
c0105e91:	c1 e0 02             	shl    $0x2,%eax
c0105e94:	01 d0                	add    %edx,%eax
c0105e96:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105e9d:	00 
c0105e9e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0105ea2:	89 04 24             	mov    %eax,(%esp)
c0105ea5:	e8 10 f8 ff ff       	call   c01056ba <vma_create>
c0105eaa:	89 45 bc             	mov    %eax,-0x44(%ebp)
        assert(vma != NULL);
c0105ead:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0105eb1:	75 24                	jne    c0105ed7 <check_vma_struct+0xbc>
c0105eb3:	c7 44 24 0c f0 d4 10 	movl   $0xc010d4f0,0xc(%esp)
c0105eba:	c0 
c0105ebb:	c7 44 24 08 ff d3 10 	movl   $0xc010d3ff,0x8(%esp)
c0105ec2:	c0 
c0105ec3:	c7 44 24 04 33 01 00 	movl   $0x133,0x4(%esp)
c0105eca:	00 
c0105ecb:	c7 04 24 14 d4 10 c0 	movl   $0xc010d414,(%esp)
c0105ed2:	e8 66 a5 ff ff       	call   c010043d <__panic>
        insert_vma_struct(mm, vma);
c0105ed7:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0105eda:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105ede:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105ee1:	89 04 24             	mov    %eax,(%esp)
c0105ee4:	e8 6a f9 ff ff       	call   c0105853 <insert_vma_struct>
    for (i = step1; i >= 1; i--)
c0105ee9:	ff 4d f4             	decl   -0xc(%ebp)
c0105eec:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105ef0:	7f 8b                	jg     c0105e7d <check_vma_struct+0x62>
    }

    for (i = step1 + 1; i <= step2; i++)
c0105ef2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105ef5:	40                   	inc    %eax
c0105ef6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105ef9:	eb 6f                	jmp    c0105f6a <check_vma_struct+0x14f>
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c0105efb:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105efe:	89 d0                	mov    %edx,%eax
c0105f00:	c1 e0 02             	shl    $0x2,%eax
c0105f03:	01 d0                	add    %edx,%eax
c0105f05:	83 c0 02             	add    $0x2,%eax
c0105f08:	89 c1                	mov    %eax,%ecx
c0105f0a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105f0d:	89 d0                	mov    %edx,%eax
c0105f0f:	c1 e0 02             	shl    $0x2,%eax
c0105f12:	01 d0                	add    %edx,%eax
c0105f14:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105f1b:	00 
c0105f1c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0105f20:	89 04 24             	mov    %eax,(%esp)
c0105f23:	e8 92 f7 ff ff       	call   c01056ba <vma_create>
c0105f28:	89 45 c0             	mov    %eax,-0x40(%ebp)
        assert(vma != NULL);
c0105f2b:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
c0105f2f:	75 24                	jne    c0105f55 <check_vma_struct+0x13a>
c0105f31:	c7 44 24 0c f0 d4 10 	movl   $0xc010d4f0,0xc(%esp)
c0105f38:	c0 
c0105f39:	c7 44 24 08 ff d3 10 	movl   $0xc010d3ff,0x8(%esp)
c0105f40:	c0 
c0105f41:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
c0105f48:	00 
c0105f49:	c7 04 24 14 d4 10 c0 	movl   $0xc010d414,(%esp)
c0105f50:	e8 e8 a4 ff ff       	call   c010043d <__panic>
        insert_vma_struct(mm, vma);
c0105f55:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0105f58:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105f5c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105f5f:	89 04 24             	mov    %eax,(%esp)
c0105f62:	e8 ec f8 ff ff       	call   c0105853 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i++)
c0105f67:	ff 45 f4             	incl   -0xc(%ebp)
c0105f6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105f6d:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0105f70:	7e 89                	jle    c0105efb <check_vma_struct+0xe0>
    }

    list_entry_t *le = list_next(&(mm->mmap_list));
c0105f72:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105f75:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0105f78:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0105f7b:	8b 40 04             	mov    0x4(%eax),%eax
c0105f7e:	89 45 f0             	mov    %eax,-0x10(%ebp)

    for (i = 1; i <= step2; i++)
c0105f81:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
c0105f88:	e9 96 00 00 00       	jmp    c0106023 <check_vma_struct+0x208>
    {
        assert(le != &(mm->mmap_list));
c0105f8d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105f90:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0105f93:	75 24                	jne    c0105fb9 <check_vma_struct+0x19e>
c0105f95:	c7 44 24 0c fc d4 10 	movl   $0xc010d4fc,0xc(%esp)
c0105f9c:	c0 
c0105f9d:	c7 44 24 08 ff d3 10 	movl   $0xc010d3ff,0x8(%esp)
c0105fa4:	c0 
c0105fa5:	c7 44 24 04 42 01 00 	movl   $0x142,0x4(%esp)
c0105fac:	00 
c0105fad:	c7 04 24 14 d4 10 c0 	movl   $0xc010d414,(%esp)
c0105fb4:	e8 84 a4 ff ff       	call   c010043d <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
c0105fb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105fbc:	83 e8 10             	sub    $0x10,%eax
c0105fbf:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
c0105fc2:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105fc5:	8b 48 04             	mov    0x4(%eax),%ecx
c0105fc8:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105fcb:	89 d0                	mov    %edx,%eax
c0105fcd:	c1 e0 02             	shl    $0x2,%eax
c0105fd0:	01 d0                	add    %edx,%eax
c0105fd2:	39 c1                	cmp    %eax,%ecx
c0105fd4:	75 17                	jne    c0105fed <check_vma_struct+0x1d2>
c0105fd6:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105fd9:	8b 48 08             	mov    0x8(%eax),%ecx
c0105fdc:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105fdf:	89 d0                	mov    %edx,%eax
c0105fe1:	c1 e0 02             	shl    $0x2,%eax
c0105fe4:	01 d0                	add    %edx,%eax
c0105fe6:	83 c0 02             	add    $0x2,%eax
c0105fe9:	39 c1                	cmp    %eax,%ecx
c0105feb:	74 24                	je     c0106011 <check_vma_struct+0x1f6>
c0105fed:	c7 44 24 0c 14 d5 10 	movl   $0xc010d514,0xc(%esp)
c0105ff4:	c0 
c0105ff5:	c7 44 24 08 ff d3 10 	movl   $0xc010d3ff,0x8(%esp)
c0105ffc:	c0 
c0105ffd:	c7 44 24 04 44 01 00 	movl   $0x144,0x4(%esp)
c0106004:	00 
c0106005:	c7 04 24 14 d4 10 c0 	movl   $0xc010d414,(%esp)
c010600c:	e8 2c a4 ff ff       	call   c010043d <__panic>
c0106011:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106014:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c0106017:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010601a:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c010601d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for (i = 1; i <= step2; i++)
c0106020:	ff 45 f4             	incl   -0xc(%ebp)
c0106023:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106026:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0106029:	0f 8e 5e ff ff ff    	jle    c0105f8d <check_vma_struct+0x172>
    }

    for (i = 5; i <= 5 * step2; i += 5)
c010602f:	c7 45 f4 05 00 00 00 	movl   $0x5,-0xc(%ebp)
c0106036:	e9 cb 01 00 00       	jmp    c0106206 <check_vma_struct+0x3eb>
    {
        struct vma_struct *vma1 = find_vma(mm, i);
c010603b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010603e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106042:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106045:	89 04 24             	mov    %eax,(%esp)
c0106048:	e8 ac f6 ff ff       	call   c01056f9 <find_vma>
c010604d:	89 45 d8             	mov    %eax,-0x28(%ebp)
        assert(vma1 != NULL);
c0106050:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0106054:	75 24                	jne    c010607a <check_vma_struct+0x25f>
c0106056:	c7 44 24 0c 49 d5 10 	movl   $0xc010d549,0xc(%esp)
c010605d:	c0 
c010605e:	c7 44 24 08 ff d3 10 	movl   $0xc010d3ff,0x8(%esp)
c0106065:	c0 
c0106066:	c7 44 24 04 4b 01 00 	movl   $0x14b,0x4(%esp)
c010606d:	00 
c010606e:	c7 04 24 14 d4 10 c0 	movl   $0xc010d414,(%esp)
c0106075:	e8 c3 a3 ff ff       	call   c010043d <__panic>
        struct vma_struct *vma2 = find_vma(mm, i + 1);
c010607a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010607d:	40                   	inc    %eax
c010607e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106082:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106085:	89 04 24             	mov    %eax,(%esp)
c0106088:	e8 6c f6 ff ff       	call   c01056f9 <find_vma>
c010608d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(vma2 != NULL);
c0106090:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
c0106094:	75 24                	jne    c01060ba <check_vma_struct+0x29f>
c0106096:	c7 44 24 0c 56 d5 10 	movl   $0xc010d556,0xc(%esp)
c010609d:	c0 
c010609e:	c7 44 24 08 ff d3 10 	movl   $0xc010d3ff,0x8(%esp)
c01060a5:	c0 
c01060a6:	c7 44 24 04 4d 01 00 	movl   $0x14d,0x4(%esp)
c01060ad:	00 
c01060ae:	c7 04 24 14 d4 10 c0 	movl   $0xc010d414,(%esp)
c01060b5:	e8 83 a3 ff ff       	call   c010043d <__panic>
        struct vma_struct *vma3 = find_vma(mm, i + 2);
c01060ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01060bd:	83 c0 02             	add    $0x2,%eax
c01060c0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01060c4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01060c7:	89 04 24             	mov    %eax,(%esp)
c01060ca:	e8 2a f6 ff ff       	call   c01056f9 <find_vma>
c01060cf:	89 45 d0             	mov    %eax,-0x30(%ebp)
        assert(vma3 == NULL);
c01060d2:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c01060d6:	74 24                	je     c01060fc <check_vma_struct+0x2e1>
c01060d8:	c7 44 24 0c 63 d5 10 	movl   $0xc010d563,0xc(%esp)
c01060df:	c0 
c01060e0:	c7 44 24 08 ff d3 10 	movl   $0xc010d3ff,0x8(%esp)
c01060e7:	c0 
c01060e8:	c7 44 24 04 4f 01 00 	movl   $0x14f,0x4(%esp)
c01060ef:	00 
c01060f0:	c7 04 24 14 d4 10 c0 	movl   $0xc010d414,(%esp)
c01060f7:	e8 41 a3 ff ff       	call   c010043d <__panic>
        struct vma_struct *vma4 = find_vma(mm, i + 3);
c01060fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01060ff:	83 c0 03             	add    $0x3,%eax
c0106102:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106106:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106109:	89 04 24             	mov    %eax,(%esp)
c010610c:	e8 e8 f5 ff ff       	call   c01056f9 <find_vma>
c0106111:	89 45 cc             	mov    %eax,-0x34(%ebp)
        assert(vma4 == NULL);
c0106114:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0106118:	74 24                	je     c010613e <check_vma_struct+0x323>
c010611a:	c7 44 24 0c 70 d5 10 	movl   $0xc010d570,0xc(%esp)
c0106121:	c0 
c0106122:	c7 44 24 08 ff d3 10 	movl   $0xc010d3ff,0x8(%esp)
c0106129:	c0 
c010612a:	c7 44 24 04 51 01 00 	movl   $0x151,0x4(%esp)
c0106131:	00 
c0106132:	c7 04 24 14 d4 10 c0 	movl   $0xc010d414,(%esp)
c0106139:	e8 ff a2 ff ff       	call   c010043d <__panic>
        struct vma_struct *vma5 = find_vma(mm, i + 4);
c010613e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106141:	83 c0 04             	add    $0x4,%eax
c0106144:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106148:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010614b:	89 04 24             	mov    %eax,(%esp)
c010614e:	e8 a6 f5 ff ff       	call   c01056f9 <find_vma>
c0106153:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(vma5 == NULL);
c0106156:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c010615a:	74 24                	je     c0106180 <check_vma_struct+0x365>
c010615c:	c7 44 24 0c 7d d5 10 	movl   $0xc010d57d,0xc(%esp)
c0106163:	c0 
c0106164:	c7 44 24 08 ff d3 10 	movl   $0xc010d3ff,0x8(%esp)
c010616b:	c0 
c010616c:	c7 44 24 04 53 01 00 	movl   $0x153,0x4(%esp)
c0106173:	00 
c0106174:	c7 04 24 14 d4 10 c0 	movl   $0xc010d414,(%esp)
c010617b:	e8 bd a2 ff ff       	call   c010043d <__panic>

        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
c0106180:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0106183:	8b 50 04             	mov    0x4(%eax),%edx
c0106186:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106189:	39 c2                	cmp    %eax,%edx
c010618b:	75 10                	jne    c010619d <check_vma_struct+0x382>
c010618d:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0106190:	8b 40 08             	mov    0x8(%eax),%eax
c0106193:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106196:	83 c2 02             	add    $0x2,%edx
c0106199:	39 d0                	cmp    %edx,%eax
c010619b:	74 24                	je     c01061c1 <check_vma_struct+0x3a6>
c010619d:	c7 44 24 0c 8c d5 10 	movl   $0xc010d58c,0xc(%esp)
c01061a4:	c0 
c01061a5:	c7 44 24 08 ff d3 10 	movl   $0xc010d3ff,0x8(%esp)
c01061ac:	c0 
c01061ad:	c7 44 24 04 55 01 00 	movl   $0x155,0x4(%esp)
c01061b4:	00 
c01061b5:	c7 04 24 14 d4 10 c0 	movl   $0xc010d414,(%esp)
c01061bc:	e8 7c a2 ff ff       	call   c010043d <__panic>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
c01061c1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01061c4:	8b 50 04             	mov    0x4(%eax),%edx
c01061c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01061ca:	39 c2                	cmp    %eax,%edx
c01061cc:	75 10                	jne    c01061de <check_vma_struct+0x3c3>
c01061ce:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01061d1:	8b 40 08             	mov    0x8(%eax),%eax
c01061d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01061d7:	83 c2 02             	add    $0x2,%edx
c01061da:	39 d0                	cmp    %edx,%eax
c01061dc:	74 24                	je     c0106202 <check_vma_struct+0x3e7>
c01061de:	c7 44 24 0c bc d5 10 	movl   $0xc010d5bc,0xc(%esp)
c01061e5:	c0 
c01061e6:	c7 44 24 08 ff d3 10 	movl   $0xc010d3ff,0x8(%esp)
c01061ed:	c0 
c01061ee:	c7 44 24 04 56 01 00 	movl   $0x156,0x4(%esp)
c01061f5:	00 
c01061f6:	c7 04 24 14 d4 10 c0 	movl   $0xc010d414,(%esp)
c01061fd:	e8 3b a2 ff ff       	call   c010043d <__panic>
    for (i = 5; i <= 5 * step2; i += 5)
c0106202:	83 45 f4 05          	addl   $0x5,-0xc(%ebp)
c0106206:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106209:	89 d0                	mov    %edx,%eax
c010620b:	c1 e0 02             	shl    $0x2,%eax
c010620e:	01 d0                	add    %edx,%eax
c0106210:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0106213:	0f 8e 22 fe ff ff    	jle    c010603b <check_vma_struct+0x220>
    }

    for (i = 4; i >= 0; i--)
c0106219:	c7 45 f4 04 00 00 00 	movl   $0x4,-0xc(%ebp)
c0106220:	eb 6f                	jmp    c0106291 <check_vma_struct+0x476>
    {
        struct vma_struct *vma_below_5 = find_vma(mm, i);
c0106222:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106225:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106229:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010622c:	89 04 24             	mov    %eax,(%esp)
c010622f:	e8 c5 f4 ff ff       	call   c01056f9 <find_vma>
c0106234:	89 45 dc             	mov    %eax,-0x24(%ebp)
        if (vma_below_5 != NULL)
c0106237:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010623b:	74 27                	je     c0106264 <check_vma_struct+0x449>
        {
            cprintf("vma_below_5: i %x, start %x, end %x\n", i, vma_below_5->vm_start, vma_below_5->vm_end);
c010623d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106240:	8b 50 08             	mov    0x8(%eax),%edx
c0106243:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106246:	8b 40 04             	mov    0x4(%eax),%eax
c0106249:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010624d:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106251:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106254:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106258:	c7 04 24 ec d5 10 c0 	movl   $0xc010d5ec,(%esp)
c010625f:	e8 6d a0 ff ff       	call   c01002d1 <cprintf>
        }
        assert(vma_below_5 == NULL);
c0106264:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0106268:	74 24                	je     c010628e <check_vma_struct+0x473>
c010626a:	c7 44 24 0c 11 d6 10 	movl   $0xc010d611,0xc(%esp)
c0106271:	c0 
c0106272:	c7 44 24 08 ff d3 10 	movl   $0xc010d3ff,0x8(%esp)
c0106279:	c0 
c010627a:	c7 44 24 04 60 01 00 	movl   $0x160,0x4(%esp)
c0106281:	00 
c0106282:	c7 04 24 14 d4 10 c0 	movl   $0xc010d414,(%esp)
c0106289:	e8 af a1 ff ff       	call   c010043d <__panic>
    for (i = 4; i >= 0; i--)
c010628e:	ff 4d f4             	decl   -0xc(%ebp)
c0106291:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106295:	79 8b                	jns    c0106222 <check_vma_struct+0x407>
    }

    mm_destroy(mm);
c0106297:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010629a:	89 04 24             	mov    %eax,(%esp)
c010629d:	e8 e9 f6 ff ff       	call   c010598b <mm_destroy>

    //    assert(nr_free_pages_store == nr_free_pages());

    cprintf("check_vma_struct() succeeded!\n");
c01062a2:	c7 04 24 28 d6 10 c0 	movl   $0xc010d628,(%esp)
c01062a9:	e8 23 a0 ff ff       	call   c01002d1 <cprintf>
}
c01062ae:	90                   	nop
c01062af:	c9                   	leave  
c01062b0:	c3                   	ret    

c01062b1 <check_pgfault>:
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void)
{
c01062b1:	f3 0f 1e fb          	endbr32 
c01062b5:	55                   	push   %ebp
c01062b6:	89 e5                	mov    %esp,%ebp
c01062b8:	83 ec 38             	sub    $0x38,%esp
    size_t nr_free_pages_store = nr_free_pages();
c01062bb:	e8 5b d7 ff ff       	call   c0103a1b <nr_free_pages>
c01062c0:	89 45 ec             	mov    %eax,-0x14(%ebp)

    check_mm_struct = mm_create();
c01062c3:	e8 54 f3 ff ff       	call   c010561c <mm_create>
c01062c8:	a3 64 40 1b c0       	mov    %eax,0xc01b4064
    assert(check_mm_struct != NULL);
c01062cd:	a1 64 40 1b c0       	mov    0xc01b4064,%eax
c01062d2:	85 c0                	test   %eax,%eax
c01062d4:	75 24                	jne    c01062fa <check_pgfault+0x49>
c01062d6:	c7 44 24 0c 47 d6 10 	movl   $0xc010d647,0xc(%esp)
c01062dd:	c0 
c01062de:	c7 44 24 08 ff d3 10 	movl   $0xc010d3ff,0x8(%esp)
c01062e5:	c0 
c01062e6:	c7 44 24 04 73 01 00 	movl   $0x173,0x4(%esp)
c01062ed:	00 
c01062ee:	c7 04 24 14 d4 10 c0 	movl   $0xc010d414,(%esp)
c01062f5:	e8 43 a1 ff ff       	call   c010043d <__panic>

    struct mm_struct *mm = check_mm_struct;
c01062fa:	a1 64 40 1b c0       	mov    0xc01b4064,%eax
c01062ff:	89 45 e8             	mov    %eax,-0x18(%ebp)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
c0106302:	8b 15 e0 e9 12 c0    	mov    0xc012e9e0,%edx
c0106308:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010630b:	89 50 0c             	mov    %edx,0xc(%eax)
c010630e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106311:	8b 40 0c             	mov    0xc(%eax),%eax
c0106314:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(pgdir[0] == 0);
c0106317:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010631a:	8b 00                	mov    (%eax),%eax
c010631c:	85 c0                	test   %eax,%eax
c010631e:	74 24                	je     c0106344 <check_pgfault+0x93>
c0106320:	c7 44 24 0c 5f d6 10 	movl   $0xc010d65f,0xc(%esp)
c0106327:	c0 
c0106328:	c7 44 24 08 ff d3 10 	movl   $0xc010d3ff,0x8(%esp)
c010632f:	c0 
c0106330:	c7 44 24 04 77 01 00 	movl   $0x177,0x4(%esp)
c0106337:	00 
c0106338:	c7 04 24 14 d4 10 c0 	movl   $0xc010d414,(%esp)
c010633f:	e8 f9 a0 ff ff       	call   c010043d <__panic>

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
c0106344:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
c010634b:	00 
c010634c:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
c0106353:	00 
c0106354:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010635b:	e8 5a f3 ff ff       	call   c01056ba <vma_create>
c0106360:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(vma != NULL);
c0106363:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0106367:	75 24                	jne    c010638d <check_pgfault+0xdc>
c0106369:	c7 44 24 0c f0 d4 10 	movl   $0xc010d4f0,0xc(%esp)
c0106370:	c0 
c0106371:	c7 44 24 08 ff d3 10 	movl   $0xc010d3ff,0x8(%esp)
c0106378:	c0 
c0106379:	c7 44 24 04 7a 01 00 	movl   $0x17a,0x4(%esp)
c0106380:	00 
c0106381:	c7 04 24 14 d4 10 c0 	movl   $0xc010d414,(%esp)
c0106388:	e8 b0 a0 ff ff       	call   c010043d <__panic>

    insert_vma_struct(mm, vma);
c010638d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106390:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106394:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106397:	89 04 24             	mov    %eax,(%esp)
c010639a:	e8 b4 f4 ff ff       	call   c0105853 <insert_vma_struct>

    uintptr_t addr = 0x100;
c010639f:	c7 45 dc 00 01 00 00 	movl   $0x100,-0x24(%ebp)
    assert(find_vma(mm, addr) == vma);
c01063a6:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01063a9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01063ad:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01063b0:	89 04 24             	mov    %eax,(%esp)
c01063b3:	e8 41 f3 ff ff       	call   c01056f9 <find_vma>
c01063b8:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c01063bb:	74 24                	je     c01063e1 <check_pgfault+0x130>
c01063bd:	c7 44 24 0c 6d d6 10 	movl   $0xc010d66d,0xc(%esp)
c01063c4:	c0 
c01063c5:	c7 44 24 08 ff d3 10 	movl   $0xc010d3ff,0x8(%esp)
c01063cc:	c0 
c01063cd:	c7 44 24 04 7f 01 00 	movl   $0x17f,0x4(%esp)
c01063d4:	00 
c01063d5:	c7 04 24 14 d4 10 c0 	movl   $0xc010d414,(%esp)
c01063dc:	e8 5c a0 ff ff       	call   c010043d <__panic>

    int i, sum = 0;
c01063e1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (i = 0; i < 100; i++)
c01063e8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01063ef:	eb 16                	jmp    c0106407 <check_pgfault+0x156>
    {
        *(char *)(addr + i) = i;
c01063f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01063f4:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01063f7:	01 d0                	add    %edx,%eax
c01063f9:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01063fc:	88 10                	mov    %dl,(%eax)
        sum += i;
c01063fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106401:	01 45 f0             	add    %eax,-0x10(%ebp)
    for (i = 0; i < 100; i++)
c0106404:	ff 45 f4             	incl   -0xc(%ebp)
c0106407:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c010640b:	7e e4                	jle    c01063f1 <check_pgfault+0x140>
    }
    for (i = 0; i < 100; i++)
c010640d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0106414:	eb 14                	jmp    c010642a <check_pgfault+0x179>
    {
        sum -= *(char *)(addr + i);
c0106416:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106419:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010641c:	01 d0                	add    %edx,%eax
c010641e:	0f b6 00             	movzbl (%eax),%eax
c0106421:	0f be c0             	movsbl %al,%eax
c0106424:	29 45 f0             	sub    %eax,-0x10(%ebp)
    for (i = 0; i < 100; i++)
c0106427:	ff 45 f4             	incl   -0xc(%ebp)
c010642a:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c010642e:	7e e6                	jle    c0106416 <check_pgfault+0x165>
    }
    assert(sum == 0);
c0106430:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0106434:	74 24                	je     c010645a <check_pgfault+0x1a9>
c0106436:	c7 44 24 0c 87 d6 10 	movl   $0xc010d687,0xc(%esp)
c010643d:	c0 
c010643e:	c7 44 24 08 ff d3 10 	movl   $0xc010d3ff,0x8(%esp)
c0106445:	c0 
c0106446:	c7 44 24 04 8b 01 00 	movl   $0x18b,0x4(%esp)
c010644d:	00 
c010644e:	c7 04 24 14 d4 10 c0 	movl   $0xc010d414,(%esp)
c0106455:	e8 e3 9f ff ff       	call   c010043d <__panic>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
c010645a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010645d:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0106460:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0106463:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106468:	89 44 24 04          	mov    %eax,0x4(%esp)
c010646c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010646f:	89 04 24             	mov    %eax,(%esp)
c0106472:	e8 f6 e1 ff ff       	call   c010466d <page_remove>
    free_page(pde2page(pgdir[0]));
c0106477:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010647a:	8b 00                	mov    (%eax),%eax
c010647c:	89 04 24             	mov    %eax,(%esp)
c010647f:	e8 80 f1 ff ff       	call   c0105604 <pde2page>
c0106484:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010648b:	00 
c010648c:	89 04 24             	mov    %eax,(%esp)
c010648f:	e8 50 d5 ff ff       	call   c01039e4 <free_pages>
    pgdir[0] = 0;
c0106494:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106497:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    mm->pgdir = NULL;
c010649d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01064a0:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    mm_destroy(mm);
c01064a7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01064aa:	89 04 24             	mov    %eax,(%esp)
c01064ad:	e8 d9 f4 ff ff       	call   c010598b <mm_destroy>
    check_mm_struct = NULL;
c01064b2:	c7 05 64 40 1b c0 00 	movl   $0x0,0xc01b4064
c01064b9:	00 00 00 

    assert(nr_free_pages_store == nr_free_pages());
c01064bc:	e8 5a d5 ff ff       	call   c0103a1b <nr_free_pages>
c01064c1:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c01064c4:	74 24                	je     c01064ea <check_pgfault+0x239>
c01064c6:	c7 44 24 0c 90 d6 10 	movl   $0xc010d690,0xc(%esp)
c01064cd:	c0 
c01064ce:	c7 44 24 08 ff d3 10 	movl   $0xc010d3ff,0x8(%esp)
c01064d5:	c0 
c01064d6:	c7 44 24 04 95 01 00 	movl   $0x195,0x4(%esp)
c01064dd:	00 
c01064de:	c7 04 24 14 d4 10 c0 	movl   $0xc010d414,(%esp)
c01064e5:	e8 53 9f ff ff       	call   c010043d <__panic>

    cprintf("check_pgfault() succeeded!\n");
c01064ea:	c7 04 24 b7 d6 10 c0 	movl   $0xc010d6b7,(%esp)
c01064f1:	e8 db 9d ff ff       	call   c01002d1 <cprintf>
}
c01064f6:	90                   	nop
c01064f7:	c9                   	leave  
c01064f8:	c3                   	ret    

c01064f9 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr)
{
c01064f9:	f3 0f 1e fb          	endbr32 
c01064fd:	55                   	push   %ebp
c01064fe:	89 e5                	mov    %esp,%ebp
c0106500:	83 ec 38             	sub    $0x38,%esp
    int ret = -E_INVAL;
c0106503:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
c010650a:	8b 45 10             	mov    0x10(%ebp),%eax
c010650d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106511:	8b 45 08             	mov    0x8(%ebp),%eax
c0106514:	89 04 24             	mov    %eax,(%esp)
c0106517:	e8 dd f1 ff ff       	call   c01056f9 <find_vma>
c010651c:	89 45 ec             	mov    %eax,-0x14(%ebp)

    pgfault_num++;
c010651f:	a1 0c 20 1b c0       	mov    0xc01b200c,%eax
c0106524:	40                   	inc    %eax
c0106525:	a3 0c 20 1b c0       	mov    %eax,0xc01b200c
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr)
c010652a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010652e:	74 0b                	je     c010653b <do_pgfault+0x42>
c0106530:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106533:	8b 40 04             	mov    0x4(%eax),%eax
c0106536:	39 45 10             	cmp    %eax,0x10(%ebp)
c0106539:	73 18                	jae    c0106553 <do_pgfault+0x5a>
    {
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
c010653b:	8b 45 10             	mov    0x10(%ebp),%eax
c010653e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106542:	c7 04 24 d4 d6 10 c0 	movl   $0xc010d6d4,(%esp)
c0106549:	e8 83 9d ff ff       	call   c01002d1 <cprintf>
        goto failed;
c010654e:	e9 f8 01 00 00       	jmp    c010674b <do_pgfault+0x252>
    }
    //check the error_code
    switch (error_code & 3)
c0106553:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106556:	83 e0 03             	and    $0x3,%eax
c0106559:	85 c0                	test   %eax,%eax
c010655b:	74 34                	je     c0106591 <do_pgfault+0x98>
c010655d:	83 f8 01             	cmp    $0x1,%eax
c0106560:	74 1e                	je     c0106580 <do_pgfault+0x87>
    {
    default:
        /* error code flag : default is 3 ( W/R=1, P=1): write, present */
    case 2: /* error code flag : (W/R=1, P=0): write, not present */
        if (!(vma->vm_flags & VM_WRITE))
c0106562:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106565:	8b 40 0c             	mov    0xc(%eax),%eax
c0106568:	83 e0 02             	and    $0x2,%eax
c010656b:	85 c0                	test   %eax,%eax
c010656d:	75 40                	jne    c01065af <do_pgfault+0xb6>
        {
            cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
c010656f:	c7 04 24 04 d7 10 c0 	movl   $0xc010d704,(%esp)
c0106576:	e8 56 9d ff ff       	call   c01002d1 <cprintf>
            goto failed;
c010657b:	e9 cb 01 00 00       	jmp    c010674b <do_pgfault+0x252>
        }
        break;
    case 1: /* error code flag : (W/R=0, P=1): read, present */
        cprintf("do_pgfault failed: error code flag = read AND present\n");
c0106580:	c7 04 24 64 d7 10 c0 	movl   $0xc010d764,(%esp)
c0106587:	e8 45 9d ff ff       	call   c01002d1 <cprintf>
        goto failed;
c010658c:	e9 ba 01 00 00       	jmp    c010674b <do_pgfault+0x252>
    case 0: /* error code flag : (W/R=0, P=0): read, not present */
        if (!(vma->vm_flags & (VM_READ | VM_EXEC)))
c0106591:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106594:	8b 40 0c             	mov    0xc(%eax),%eax
c0106597:	83 e0 05             	and    $0x5,%eax
c010659a:	85 c0                	test   %eax,%eax
c010659c:	75 12                	jne    c01065b0 <do_pgfault+0xb7>
        {
            cprintf("do_pgfault failed: error code flag = read AND not present, but the addr's vma cannot read or exec\n");
c010659e:	c7 04 24 9c d7 10 c0 	movl   $0xc010d79c,(%esp)
c01065a5:	e8 27 9d ff ff       	call   c01002d1 <cprintf>
            goto failed;
c01065aa:	e9 9c 01 00 00       	jmp    c010674b <do_pgfault+0x252>
        break;
c01065af:	90                   	nop
     *    (write an non_existed addr && addr is writable) OR
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
c01065b0:	c7 45 f0 04 00 00 00 	movl   $0x4,-0x10(%ebp)
    if (vma->vm_flags & VM_WRITE)
c01065b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01065ba:	8b 40 0c             	mov    0xc(%eax),%eax
c01065bd:	83 e0 02             	and    $0x2,%eax
c01065c0:	85 c0                	test   %eax,%eax
c01065c2:	74 04                	je     c01065c8 <do_pgfault+0xcf>
    {
        perm |= PTE_W;
c01065c4:	83 4d f0 02          	orl    $0x2,-0x10(%ebp)
    }
    addr = ROUNDDOWN(addr, PGSIZE);
c01065c8:	8b 45 10             	mov    0x10(%ebp),%eax
c01065cb:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01065ce:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01065d1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01065d6:	89 45 10             	mov    %eax,0x10(%ebp)

    ret = -E_NO_MEM;
c01065d9:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

    pte_t *ptep = NULL;
c01065e0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
        }
   }
#endif
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL)
c01065e7:	8b 45 08             	mov    0x8(%ebp),%eax
c01065ea:	8b 40 0c             	mov    0xc(%eax),%eax
c01065ed:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c01065f4:	00 
c01065f5:	8b 55 10             	mov    0x10(%ebp),%edx
c01065f8:	89 54 24 04          	mov    %edx,0x4(%esp)
c01065fc:	89 04 24             	mov    %eax,(%esp)
c01065ff:	e8 41 da ff ff       	call   c0104045 <get_pte>
c0106604:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106607:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010660b:	75 11                	jne    c010661e <do_pgfault+0x125>
    {
        cprintf("get_pte in do_pgfault failed\n");
c010660d:	c7 04 24 ff d7 10 c0 	movl   $0xc010d7ff,(%esp)
c0106614:	e8 b8 9c ff ff       	call   c01002d1 <cprintf>
        goto failed;
c0106619:	e9 2d 01 00 00       	jmp    c010674b <do_pgfault+0x252>
    }

    if (*ptep == 0)
c010661e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106621:	8b 00                	mov    (%eax),%eax
c0106623:	85 c0                	test   %eax,%eax
c0106625:	75 35                	jne    c010665c <do_pgfault+0x163>
    { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL)
c0106627:	8b 45 08             	mov    0x8(%ebp),%eax
c010662a:	8b 40 0c             	mov    0xc(%eax),%eax
c010662d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0106630:	89 54 24 08          	mov    %edx,0x8(%esp)
c0106634:	8b 55 10             	mov    0x10(%ebp),%edx
c0106637:	89 54 24 04          	mov    %edx,0x4(%esp)
c010663b:	89 04 24             	mov    %eax,(%esp)
c010663e:	e8 91 e1 ff ff       	call   c01047d4 <pgdir_alloc_page>
c0106643:	85 c0                	test   %eax,%eax
c0106645:	0f 85 f9 00 00 00    	jne    c0106744 <do_pgfault+0x24b>
        {
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
c010664b:	c7 04 24 20 d8 10 c0 	movl   $0xc010d820,(%esp)
c0106652:	e8 7a 9c ff ff       	call   c01002d1 <cprintf>
            goto failed;
c0106657:	e9 ef 00 00 00       	jmp    c010674b <do_pgfault+0x252>
        }
    }
    else
    {
        struct Page *page = NULL;
c010665c:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
        cprintf("do pgfault: ptep %x, pte %x\n", ptep, *ptep);
c0106663:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106666:	8b 00                	mov    (%eax),%eax
c0106668:	89 44 24 08          	mov    %eax,0x8(%esp)
c010666c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010666f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106673:	c7 04 24 47 d8 10 c0 	movl   $0xc010d847,(%esp)
c010667a:	e8 52 9c ff ff       	call   c01002d1 <cprintf>
        if (*ptep & PTE_P)
c010667f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106682:	8b 00                	mov    (%eax),%eax
c0106684:	83 e0 01             	and    $0x1,%eax
c0106687:	85 c0                	test   %eax,%eax
c0106689:	74 1c                	je     c01066a7 <do_pgfault+0x1ae>
        {
            //if process write to this existed readonly page (PTE_P means existed), then should be here now.
            //we can implement the delayed memory space copy for fork child process (AKA copy on write, COW).
            //we didn't implement now, we will do it in future.
            panic("error write a non-writable pte");
c010668b:	c7 44 24 08 64 d8 10 	movl   $0xc010d864,0x8(%esp)
c0106692:	c0 
c0106693:	c7 44 24 04 2f 02 00 	movl   $0x22f,0x4(%esp)
c010669a:	00 
c010669b:	c7 04 24 14 d4 10 c0 	movl   $0xc010d414,(%esp)
c01066a2:	e8 96 9d ff ff       	call   c010043d <__panic>
        }
        else
        {
            // if this pte is a swap entry, then load data from disk to a page with phy addr
            // and call page_insert to map the phy addr with logical addr
            if (swap_init_ok)
c01066a7:	a1 10 20 1b c0       	mov    0xc01b2010,%eax
c01066ac:	85 c0                	test   %eax,%eax
c01066ae:	74 30                	je     c01066e0 <do_pgfault+0x1e7>
            {
                if ((ret = swap_in(mm, addr, &page)) != 0)
c01066b0:	8d 45 e0             	lea    -0x20(%ebp),%eax
c01066b3:	89 44 24 08          	mov    %eax,0x8(%esp)
c01066b7:	8b 45 10             	mov    0x10(%ebp),%eax
c01066ba:	89 44 24 04          	mov    %eax,0x4(%esp)
c01066be:	8b 45 08             	mov    0x8(%ebp),%eax
c01066c1:	89 04 24             	mov    %eax,(%esp)
c01066c4:	e8 e3 04 00 00       	call   c0106bac <swap_in>
c01066c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01066cc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01066d0:	74 25                	je     c01066f7 <do_pgfault+0x1fe>
                {
                    cprintf("swap_in in do_pgfault failed\n");
c01066d2:	c7 04 24 83 d8 10 c0 	movl   $0xc010d883,(%esp)
c01066d9:	e8 f3 9b ff ff       	call   c01002d1 <cprintf>
                    goto failed;
c01066de:	eb 6b                	jmp    c010674b <do_pgfault+0x252>
                }
            }
            else
            {
                cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
c01066e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01066e3:	8b 00                	mov    (%eax),%eax
c01066e5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01066e9:	c7 04 24 a4 d8 10 c0 	movl   $0xc010d8a4,(%esp)
c01066f0:	e8 dc 9b ff ff       	call   c01002d1 <cprintf>
                goto failed;
c01066f5:	eb 54                	jmp    c010674b <do_pgfault+0x252>
            }
        }
        page_insert(mm->pgdir, page, addr, perm);
c01066f7:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01066fa:	8b 45 08             	mov    0x8(%ebp),%eax
c01066fd:	8b 40 0c             	mov    0xc(%eax),%eax
c0106700:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0106703:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0106707:	8b 4d 10             	mov    0x10(%ebp),%ecx
c010670a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c010670e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106712:	89 04 24             	mov    %eax,(%esp)
c0106715:	e8 9c df ff ff       	call   c01046b6 <page_insert>
        swap_map_swappable(mm, addr, page, 1);
c010671a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010671d:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
c0106724:	00 
c0106725:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106729:	8b 45 10             	mov    0x10(%ebp),%eax
c010672c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106730:	8b 45 08             	mov    0x8(%ebp),%eax
c0106733:	89 04 24             	mov    %eax,(%esp)
c0106736:	e8 a3 02 00 00       	call   c01069de <swap_map_swappable>
        page->pra_vaddr = addr;
c010673b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010673e:	8b 55 10             	mov    0x10(%ebp),%edx
c0106741:	89 50 1c             	mov    %edx,0x1c(%eax)
    }
    ret = 0;
c0106744:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
failed:
    return ret;
c010674b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010674e:	c9                   	leave  
c010674f:	c3                   	ret    

c0106750 <user_mem_check>:

bool user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write)
{
c0106750:	f3 0f 1e fb          	endbr32 
c0106754:	55                   	push   %ebp
c0106755:	89 e5                	mov    %esp,%ebp
c0106757:	83 ec 18             	sub    $0x18,%esp
    if (mm != NULL)
c010675a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010675e:	0f 84 e0 00 00 00    	je     c0106844 <user_mem_check+0xf4>
    {
        if (!USER_ACCESS(addr, addr + len))
c0106764:	81 7d 0c ff ff 1f 00 	cmpl   $0x1fffff,0xc(%ebp)
c010676b:	76 1c                	jbe    c0106789 <user_mem_check+0x39>
c010676d:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106770:	8b 45 10             	mov    0x10(%ebp),%eax
c0106773:	01 d0                	add    %edx,%eax
c0106775:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0106778:	73 0f                	jae    c0106789 <user_mem_check+0x39>
c010677a:	8b 55 0c             	mov    0xc(%ebp),%edx
c010677d:	8b 45 10             	mov    0x10(%ebp),%eax
c0106780:	01 d0                	add    %edx,%eax
c0106782:	3d 00 00 00 b0       	cmp    $0xb0000000,%eax
c0106787:	76 0a                	jbe    c0106793 <user_mem_check+0x43>
        {
            return 0;
c0106789:	b8 00 00 00 00       	mov    $0x0,%eax
c010678e:	e9 e2 00 00 00       	jmp    c0106875 <user_mem_check+0x125>
        }
        struct vma_struct *vma;
        uintptr_t start = addr, end = addr + len;
c0106793:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106796:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0106799:	8b 55 0c             	mov    0xc(%ebp),%edx
c010679c:	8b 45 10             	mov    0x10(%ebp),%eax
c010679f:	01 d0                	add    %edx,%eax
c01067a1:	89 45 f8             	mov    %eax,-0x8(%ebp)
        while (start < end)
c01067a4:	e9 88 00 00 00       	jmp    c0106831 <user_mem_check+0xe1>
        {
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start)
c01067a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01067ac:	89 44 24 04          	mov    %eax,0x4(%esp)
c01067b0:	8b 45 08             	mov    0x8(%ebp),%eax
c01067b3:	89 04 24             	mov    %eax,(%esp)
c01067b6:	e8 3e ef ff ff       	call   c01056f9 <find_vma>
c01067bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01067be:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01067c2:	74 0b                	je     c01067cf <user_mem_check+0x7f>
c01067c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01067c7:	8b 40 04             	mov    0x4(%eax),%eax
c01067ca:	39 45 fc             	cmp    %eax,-0x4(%ebp)
c01067cd:	73 0a                	jae    c01067d9 <user_mem_check+0x89>
            {
                return 0;
c01067cf:	b8 00 00 00 00       	mov    $0x0,%eax
c01067d4:	e9 9c 00 00 00       	jmp    c0106875 <user_mem_check+0x125>
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
c01067d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01067dc:	8b 40 0c             	mov    0xc(%eax),%eax
c01067df:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c01067e3:	74 07                	je     c01067ec <user_mem_check+0x9c>
c01067e5:	ba 02 00 00 00       	mov    $0x2,%edx
c01067ea:	eb 05                	jmp    c01067f1 <user_mem_check+0xa1>
c01067ec:	ba 01 00 00 00       	mov    $0x1,%edx
c01067f1:	21 d0                	and    %edx,%eax
c01067f3:	85 c0                	test   %eax,%eax
c01067f5:	75 07                	jne    c01067fe <user_mem_check+0xae>
            {
                return 0;
c01067f7:	b8 00 00 00 00       	mov    $0x0,%eax
c01067fc:	eb 77                	jmp    c0106875 <user_mem_check+0x125>
            }
            if (write && (vma->vm_flags & VM_STACK))
c01067fe:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0106802:	74 24                	je     c0106828 <user_mem_check+0xd8>
c0106804:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106807:	8b 40 0c             	mov    0xc(%eax),%eax
c010680a:	83 e0 08             	and    $0x8,%eax
c010680d:	85 c0                	test   %eax,%eax
c010680f:	74 17                	je     c0106828 <user_mem_check+0xd8>
            {
                if (start < vma->vm_start + PGSIZE)
c0106811:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106814:	8b 40 04             	mov    0x4(%eax),%eax
c0106817:	05 00 10 00 00       	add    $0x1000,%eax
c010681c:	39 45 fc             	cmp    %eax,-0x4(%ebp)
c010681f:	73 07                	jae    c0106828 <user_mem_check+0xd8>
                { //check stack start & size
                    return 0;
c0106821:	b8 00 00 00 00       	mov    $0x0,%eax
c0106826:	eb 4d                	jmp    c0106875 <user_mem_check+0x125>
                }
            }
            start = vma->vm_end;
c0106828:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010682b:	8b 40 08             	mov    0x8(%eax),%eax
c010682e:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < end)
c0106831:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106834:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c0106837:	0f 82 6c ff ff ff    	jb     c01067a9 <user_mem_check+0x59>
        }
        return 1;
c010683d:	b8 01 00 00 00       	mov    $0x1,%eax
c0106842:	eb 31                	jmp    c0106875 <user_mem_check+0x125>
    }
    return KERN_ACCESS(addr, addr + len);
c0106844:	81 7d 0c ff ff ff bf 	cmpl   $0xbfffffff,0xc(%ebp)
c010684b:	76 23                	jbe    c0106870 <user_mem_check+0x120>
c010684d:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106850:	8b 45 10             	mov    0x10(%ebp),%eax
c0106853:	01 d0                	add    %edx,%eax
c0106855:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0106858:	73 16                	jae    c0106870 <user_mem_check+0x120>
c010685a:	8b 55 0c             	mov    0xc(%ebp),%edx
c010685d:	8b 45 10             	mov    0x10(%ebp),%eax
c0106860:	01 d0                	add    %edx,%eax
c0106862:	3d 00 00 00 f8       	cmp    $0xf8000000,%eax
c0106867:	77 07                	ja     c0106870 <user_mem_check+0x120>
c0106869:	b8 01 00 00 00       	mov    $0x1,%eax
c010686e:	eb 05                	jmp    c0106875 <user_mem_check+0x125>
c0106870:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106875:	c9                   	leave  
c0106876:	c3                   	ret    

c0106877 <pa2page>:
pa2page(uintptr_t pa) {
c0106877:	55                   	push   %ebp
c0106878:	89 e5                	mov    %esp,%ebp
c010687a:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c010687d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106880:	c1 e8 0c             	shr    $0xc,%eax
c0106883:	89 c2                	mov    %eax,%edx
c0106885:	a1 80 1f 1b c0       	mov    0xc01b1f80,%eax
c010688a:	39 c2                	cmp    %eax,%edx
c010688c:	72 1c                	jb     c01068aa <pa2page+0x33>
        panic("pa2page called with invalid pa");
c010688e:	c7 44 24 08 cc d8 10 	movl   $0xc010d8cc,0x8(%esp)
c0106895:	c0 
c0106896:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c010689d:	00 
c010689e:	c7 04 24 eb d8 10 c0 	movl   $0xc010d8eb,(%esp)
c01068a5:	e8 93 9b ff ff       	call   c010043d <__panic>
    return &pages[PPN(pa)];
c01068aa:	a1 60 40 1b c0       	mov    0xc01b4060,%eax
c01068af:	8b 55 08             	mov    0x8(%ebp),%edx
c01068b2:	c1 ea 0c             	shr    $0xc,%edx
c01068b5:	c1 e2 05             	shl    $0x5,%edx
c01068b8:	01 d0                	add    %edx,%eax
}
c01068ba:	c9                   	leave  
c01068bb:	c3                   	ret    

c01068bc <pte2page>:
pte2page(pte_t pte) {
c01068bc:	55                   	push   %ebp
c01068bd:	89 e5                	mov    %esp,%ebp
c01068bf:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c01068c2:	8b 45 08             	mov    0x8(%ebp),%eax
c01068c5:	83 e0 01             	and    $0x1,%eax
c01068c8:	85 c0                	test   %eax,%eax
c01068ca:	75 1c                	jne    c01068e8 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c01068cc:	c7 44 24 08 fc d8 10 	movl   $0xc010d8fc,0x8(%esp)
c01068d3:	c0 
c01068d4:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c01068db:	00 
c01068dc:	c7 04 24 eb d8 10 c0 	movl   $0xc010d8eb,(%esp)
c01068e3:	e8 55 9b ff ff       	call   c010043d <__panic>
    return pa2page(PTE_ADDR(pte));
c01068e8:	8b 45 08             	mov    0x8(%ebp),%eax
c01068eb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01068f0:	89 04 24             	mov    %eax,(%esp)
c01068f3:	e8 7f ff ff ff       	call   c0106877 <pa2page>
}
c01068f8:	c9                   	leave  
c01068f9:	c3                   	ret    

c01068fa <pde2page>:
pde2page(pde_t pde) {
c01068fa:	55                   	push   %ebp
c01068fb:	89 e5                	mov    %esp,%ebp
c01068fd:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0106900:	8b 45 08             	mov    0x8(%ebp),%eax
c0106903:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106908:	89 04 24             	mov    %eax,(%esp)
c010690b:	e8 67 ff ff ff       	call   c0106877 <pa2page>
}
c0106910:	c9                   	leave  
c0106911:	c3                   	ret    

c0106912 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
c0106912:	f3 0f 1e fb          	endbr32 
c0106916:	55                   	push   %ebp
c0106917:	89 e5                	mov    %esp,%ebp
c0106919:	83 ec 28             	sub    $0x28,%esp
     swapfs_init();
c010691c:	e8 3e 2b 00 00       	call   c010945f <swapfs_init>

     if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
c0106921:	a1 1c 41 1b c0       	mov    0xc01b411c,%eax
c0106926:	3d ff 03 00 00       	cmp    $0x3ff,%eax
c010692b:	76 0c                	jbe    c0106939 <swap_init+0x27>
c010692d:	a1 1c 41 1b c0       	mov    0xc01b411c,%eax
c0106932:	3d ff ff ff 00       	cmp    $0xffffff,%eax
c0106937:	76 25                	jbe    c010695e <swap_init+0x4c>
     {
          panic("bad max_swap_offset %08x.\n", max_swap_offset);
c0106939:	a1 1c 41 1b c0       	mov    0xc01b411c,%eax
c010693e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106942:	c7 44 24 08 1d d9 10 	movl   $0xc010d91d,0x8(%esp)
c0106949:	c0 
c010694a:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
c0106951:	00 
c0106952:	c7 04 24 38 d9 10 c0 	movl   $0xc010d938,(%esp)
c0106959:	e8 df 9a ff ff       	call   c010043d <__panic>
     }
     

     sm = &swap_manager_fifo;
c010695e:	c7 05 18 20 1b c0 60 	movl   $0xc012ea60,0xc01b2018
c0106965:	ea 12 c0 
     int r = sm->init();
c0106968:	a1 18 20 1b c0       	mov    0xc01b2018,%eax
c010696d:	8b 40 04             	mov    0x4(%eax),%eax
c0106970:	ff d0                	call   *%eax
c0106972:	89 45 f4             	mov    %eax,-0xc(%ebp)
     
     if (r == 0)
c0106975:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106979:	75 26                	jne    c01069a1 <swap_init+0x8f>
     {
          swap_init_ok = 1;
c010697b:	c7 05 10 20 1b c0 01 	movl   $0x1,0xc01b2010
c0106982:	00 00 00 
          cprintf("SWAP: manager = %s\n", sm->name);
c0106985:	a1 18 20 1b c0       	mov    0xc01b2018,%eax
c010698a:	8b 00                	mov    (%eax),%eax
c010698c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106990:	c7 04 24 47 d9 10 c0 	movl   $0xc010d947,(%esp)
c0106997:	e8 35 99 ff ff       	call   c01002d1 <cprintf>
          check_swap();
c010699c:	e8 b6 04 00 00       	call   c0106e57 <check_swap>
     }

     return r;
c01069a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01069a4:	c9                   	leave  
c01069a5:	c3                   	ret    

c01069a6 <swap_init_mm>:

int
swap_init_mm(struct mm_struct *mm)
{
c01069a6:	f3 0f 1e fb          	endbr32 
c01069aa:	55                   	push   %ebp
c01069ab:	89 e5                	mov    %esp,%ebp
c01069ad:	83 ec 18             	sub    $0x18,%esp
     return sm->init_mm(mm);
c01069b0:	a1 18 20 1b c0       	mov    0xc01b2018,%eax
c01069b5:	8b 40 08             	mov    0x8(%eax),%eax
c01069b8:	8b 55 08             	mov    0x8(%ebp),%edx
c01069bb:	89 14 24             	mov    %edx,(%esp)
c01069be:	ff d0                	call   *%eax
}
c01069c0:	c9                   	leave  
c01069c1:	c3                   	ret    

c01069c2 <swap_tick_event>:

int
swap_tick_event(struct mm_struct *mm)
{
c01069c2:	f3 0f 1e fb          	endbr32 
c01069c6:	55                   	push   %ebp
c01069c7:	89 e5                	mov    %esp,%ebp
c01069c9:	83 ec 18             	sub    $0x18,%esp
     return sm->tick_event(mm);
c01069cc:	a1 18 20 1b c0       	mov    0xc01b2018,%eax
c01069d1:	8b 40 0c             	mov    0xc(%eax),%eax
c01069d4:	8b 55 08             	mov    0x8(%ebp),%edx
c01069d7:	89 14 24             	mov    %edx,(%esp)
c01069da:	ff d0                	call   *%eax
}
c01069dc:	c9                   	leave  
c01069dd:	c3                   	ret    

c01069de <swap_map_swappable>:

int
swap_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c01069de:	f3 0f 1e fb          	endbr32 
c01069e2:	55                   	push   %ebp
c01069e3:	89 e5                	mov    %esp,%ebp
c01069e5:	83 ec 18             	sub    $0x18,%esp
     return sm->map_swappable(mm, addr, page, swap_in);
c01069e8:	a1 18 20 1b c0       	mov    0xc01b2018,%eax
c01069ed:	8b 40 10             	mov    0x10(%eax),%eax
c01069f0:	8b 55 14             	mov    0x14(%ebp),%edx
c01069f3:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01069f7:	8b 55 10             	mov    0x10(%ebp),%edx
c01069fa:	89 54 24 08          	mov    %edx,0x8(%esp)
c01069fe:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106a01:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106a05:	8b 55 08             	mov    0x8(%ebp),%edx
c0106a08:	89 14 24             	mov    %edx,(%esp)
c0106a0b:	ff d0                	call   *%eax
}
c0106a0d:	c9                   	leave  
c0106a0e:	c3                   	ret    

c0106a0f <swap_set_unswappable>:

int
swap_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c0106a0f:	f3 0f 1e fb          	endbr32 
c0106a13:	55                   	push   %ebp
c0106a14:	89 e5                	mov    %esp,%ebp
c0106a16:	83 ec 18             	sub    $0x18,%esp
     return sm->set_unswappable(mm, addr);
c0106a19:	a1 18 20 1b c0       	mov    0xc01b2018,%eax
c0106a1e:	8b 40 14             	mov    0x14(%eax),%eax
c0106a21:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106a24:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106a28:	8b 55 08             	mov    0x8(%ebp),%edx
c0106a2b:	89 14 24             	mov    %edx,(%esp)
c0106a2e:	ff d0                	call   *%eax
}
c0106a30:	c9                   	leave  
c0106a31:	c3                   	ret    

c0106a32 <swap_out>:

volatile unsigned int swap_out_num=0;

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
c0106a32:	f3 0f 1e fb          	endbr32 
c0106a36:	55                   	push   %ebp
c0106a37:	89 e5                	mov    %esp,%ebp
c0106a39:	83 ec 38             	sub    $0x38,%esp
     int i;
     for (i = 0; i != n; ++ i)
c0106a3c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0106a43:	e9 53 01 00 00       	jmp    c0106b9b <swap_out+0x169>
     {
          uintptr_t v;
          //struct Page **ptr_page=NULL;
          struct Page *page;
          // cprintf("i %d, SWAP: call swap_out_victim\n",i);
          int r = sm->swap_out_victim(mm, &page, in_tick);
c0106a48:	a1 18 20 1b c0       	mov    0xc01b2018,%eax
c0106a4d:	8b 40 18             	mov    0x18(%eax),%eax
c0106a50:	8b 55 10             	mov    0x10(%ebp),%edx
c0106a53:	89 54 24 08          	mov    %edx,0x8(%esp)
c0106a57:	8d 55 e4             	lea    -0x1c(%ebp),%edx
c0106a5a:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106a5e:	8b 55 08             	mov    0x8(%ebp),%edx
c0106a61:	89 14 24             	mov    %edx,(%esp)
c0106a64:	ff d0                	call   *%eax
c0106a66:	89 45 f0             	mov    %eax,-0x10(%ebp)
          if (r != 0) {
c0106a69:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0106a6d:	74 18                	je     c0106a87 <swap_out+0x55>
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
c0106a6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106a72:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106a76:	c7 04 24 5c d9 10 c0 	movl   $0xc010d95c,(%esp)
c0106a7d:	e8 4f 98 ff ff       	call   c01002d1 <cprintf>
c0106a82:	e9 20 01 00 00       	jmp    c0106ba7 <swap_out+0x175>
          }          
          //assert(!PageReserved(page));

          //cprintf("SWAP: choose victim page 0x%08x\n", page);
          
          v=page->pra_vaddr; 
c0106a87:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106a8a:	8b 40 1c             	mov    0x1c(%eax),%eax
c0106a8d:	89 45 ec             	mov    %eax,-0x14(%ebp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
c0106a90:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a93:	8b 40 0c             	mov    0xc(%eax),%eax
c0106a96:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106a9d:	00 
c0106a9e:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106aa1:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106aa5:	89 04 24             	mov    %eax,(%esp)
c0106aa8:	e8 98 d5 ff ff       	call   c0104045 <get_pte>
c0106aad:	89 45 e8             	mov    %eax,-0x18(%ebp)
          assert((*ptep & PTE_P) != 0);
c0106ab0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106ab3:	8b 00                	mov    (%eax),%eax
c0106ab5:	83 e0 01             	and    $0x1,%eax
c0106ab8:	85 c0                	test   %eax,%eax
c0106aba:	75 24                	jne    c0106ae0 <swap_out+0xae>
c0106abc:	c7 44 24 0c 89 d9 10 	movl   $0xc010d989,0xc(%esp)
c0106ac3:	c0 
c0106ac4:	c7 44 24 08 9e d9 10 	movl   $0xc010d99e,0x8(%esp)
c0106acb:	c0 
c0106acc:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
c0106ad3:	00 
c0106ad4:	c7 04 24 38 d9 10 c0 	movl   $0xc010d938,(%esp)
c0106adb:	e8 5d 99 ff ff       	call   c010043d <__panic>

          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
c0106ae0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106ae3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106ae6:	8b 52 1c             	mov    0x1c(%edx),%edx
c0106ae9:	c1 ea 0c             	shr    $0xc,%edx
c0106aec:	42                   	inc    %edx
c0106aed:	c1 e2 08             	shl    $0x8,%edx
c0106af0:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106af4:	89 14 24             	mov    %edx,(%esp)
c0106af7:	e8 26 2a 00 00       	call   c0109522 <swapfs_write>
c0106afc:	85 c0                	test   %eax,%eax
c0106afe:	74 34                	je     c0106b34 <swap_out+0x102>
                    cprintf("SWAP: failed to save\n");
c0106b00:	c7 04 24 b3 d9 10 c0 	movl   $0xc010d9b3,(%esp)
c0106b07:	e8 c5 97 ff ff       	call   c01002d1 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
c0106b0c:	a1 18 20 1b c0       	mov    0xc01b2018,%eax
c0106b11:	8b 40 10             	mov    0x10(%eax),%eax
c0106b14:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106b17:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0106b1e:	00 
c0106b1f:	89 54 24 08          	mov    %edx,0x8(%esp)
c0106b23:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106b26:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106b2a:	8b 55 08             	mov    0x8(%ebp),%edx
c0106b2d:	89 14 24             	mov    %edx,(%esp)
c0106b30:	ff d0                	call   *%eax
c0106b32:	eb 64                	jmp    c0106b98 <swap_out+0x166>
                    continue;
          }
          else {
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
c0106b34:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106b37:	8b 40 1c             	mov    0x1c(%eax),%eax
c0106b3a:	c1 e8 0c             	shr    $0xc,%eax
c0106b3d:	40                   	inc    %eax
c0106b3e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106b42:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106b45:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106b49:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106b4c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106b50:	c7 04 24 cc d9 10 c0 	movl   $0xc010d9cc,(%esp)
c0106b57:	e8 75 97 ff ff       	call   c01002d1 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
c0106b5c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106b5f:	8b 40 1c             	mov    0x1c(%eax),%eax
c0106b62:	c1 e8 0c             	shr    $0xc,%eax
c0106b65:	40                   	inc    %eax
c0106b66:	c1 e0 08             	shl    $0x8,%eax
c0106b69:	89 c2                	mov    %eax,%edx
c0106b6b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106b6e:	89 10                	mov    %edx,(%eax)
                    free_page(page);
c0106b70:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106b73:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106b7a:	00 
c0106b7b:	89 04 24             	mov    %eax,(%esp)
c0106b7e:	e8 61 ce ff ff       	call   c01039e4 <free_pages>
          }
          
          tlb_invalidate(mm->pgdir, v);
c0106b83:	8b 45 08             	mov    0x8(%ebp),%eax
c0106b86:	8b 40 0c             	mov    0xc(%eax),%eax
c0106b89:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106b8c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106b90:	89 04 24             	mov    %eax,(%esp)
c0106b93:	e8 db db ff ff       	call   c0104773 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
c0106b98:	ff 45 f4             	incl   -0xc(%ebp)
c0106b9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106b9e:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106ba1:	0f 85 a1 fe ff ff    	jne    c0106a48 <swap_out+0x16>
     }
     return i;
c0106ba7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106baa:	c9                   	leave  
c0106bab:	c3                   	ret    

c0106bac <swap_in>:

int
swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result)
{
c0106bac:	f3 0f 1e fb          	endbr32 
c0106bb0:	55                   	push   %ebp
c0106bb1:	89 e5                	mov    %esp,%ebp
c0106bb3:	83 ec 28             	sub    $0x28,%esp
     struct Page *result = alloc_page();
c0106bb6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106bbd:	e8 b3 cd ff ff       	call   c0103975 <alloc_pages>
c0106bc2:	89 45 f4             	mov    %eax,-0xc(%ebp)
     assert(result!=NULL);
c0106bc5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106bc9:	75 24                	jne    c0106bef <swap_in+0x43>
c0106bcb:	c7 44 24 0c 0c da 10 	movl   $0xc010da0c,0xc(%esp)
c0106bd2:	c0 
c0106bd3:	c7 44 24 08 9e d9 10 	movl   $0xc010d99e,0x8(%esp)
c0106bda:	c0 
c0106bdb:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c0106be2:	00 
c0106be3:	c7 04 24 38 d9 10 c0 	movl   $0xc010d938,(%esp)
c0106bea:	e8 4e 98 ff ff       	call   c010043d <__panic>

     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
c0106bef:	8b 45 08             	mov    0x8(%ebp),%eax
c0106bf2:	8b 40 0c             	mov    0xc(%eax),%eax
c0106bf5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106bfc:	00 
c0106bfd:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106c00:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106c04:	89 04 24             	mov    %eax,(%esp)
c0106c07:	e8 39 d4 ff ff       	call   c0104045 <get_pte>
c0106c0c:	89 45 f0             	mov    %eax,-0x10(%ebp)
     // cprintf("SWAP: load ptep %x swap entry %d to vaddr 0x%08x, page %x, No %d\n", ptep, (*ptep)>>8, addr, result, (result-pages));
    
     int r;
     if ((r = swapfs_read((*ptep), result)) != 0)
c0106c0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106c12:	8b 00                	mov    (%eax),%eax
c0106c14:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106c17:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106c1b:	89 04 24             	mov    %eax,(%esp)
c0106c1e:	e8 89 28 00 00       	call   c01094ac <swapfs_read>
c0106c23:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106c26:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0106c2a:	74 2a                	je     c0106c56 <swap_in+0xaa>
     {
        assert(r!=0);
c0106c2c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0106c30:	75 24                	jne    c0106c56 <swap_in+0xaa>
c0106c32:	c7 44 24 0c 19 da 10 	movl   $0xc010da19,0xc(%esp)
c0106c39:	c0 
c0106c3a:	c7 44 24 08 9e d9 10 	movl   $0xc010d99e,0x8(%esp)
c0106c41:	c0 
c0106c42:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
c0106c49:	00 
c0106c4a:	c7 04 24 38 d9 10 c0 	movl   $0xc010d938,(%esp)
c0106c51:	e8 e7 97 ff ff       	call   c010043d <__panic>
     }
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
c0106c56:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106c59:	8b 00                	mov    (%eax),%eax
c0106c5b:	c1 e8 08             	shr    $0x8,%eax
c0106c5e:	89 c2                	mov    %eax,%edx
c0106c60:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106c63:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106c67:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106c6b:	c7 04 24 20 da 10 c0 	movl   $0xc010da20,(%esp)
c0106c72:	e8 5a 96 ff ff       	call   c01002d1 <cprintf>
     *ptr_result=result;
c0106c77:	8b 45 10             	mov    0x10(%ebp),%eax
c0106c7a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106c7d:	89 10                	mov    %edx,(%eax)
     return 0;
c0106c7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106c84:	c9                   	leave  
c0106c85:	c3                   	ret    

c0106c86 <check_content_set>:



static inline void
check_content_set(void)
{
c0106c86:	55                   	push   %ebp
c0106c87:	89 e5                	mov    %esp,%ebp
c0106c89:	83 ec 18             	sub    $0x18,%esp
     *(unsigned char *)0x1000 = 0x0a;
c0106c8c:	b8 00 10 00 00       	mov    $0x1000,%eax
c0106c91:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c0106c94:	a1 0c 20 1b c0       	mov    0xc01b200c,%eax
c0106c99:	83 f8 01             	cmp    $0x1,%eax
c0106c9c:	74 24                	je     c0106cc2 <check_content_set+0x3c>
c0106c9e:	c7 44 24 0c 5e da 10 	movl   $0xc010da5e,0xc(%esp)
c0106ca5:	c0 
c0106ca6:	c7 44 24 08 9e d9 10 	movl   $0xc010d99e,0x8(%esp)
c0106cad:	c0 
c0106cae:	c7 44 24 04 92 00 00 	movl   $0x92,0x4(%esp)
c0106cb5:	00 
c0106cb6:	c7 04 24 38 d9 10 c0 	movl   $0xc010d938,(%esp)
c0106cbd:	e8 7b 97 ff ff       	call   c010043d <__panic>
     *(unsigned char *)0x1010 = 0x0a;
c0106cc2:	b8 10 10 00 00       	mov    $0x1010,%eax
c0106cc7:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c0106cca:	a1 0c 20 1b c0       	mov    0xc01b200c,%eax
c0106ccf:	83 f8 01             	cmp    $0x1,%eax
c0106cd2:	74 24                	je     c0106cf8 <check_content_set+0x72>
c0106cd4:	c7 44 24 0c 5e da 10 	movl   $0xc010da5e,0xc(%esp)
c0106cdb:	c0 
c0106cdc:	c7 44 24 08 9e d9 10 	movl   $0xc010d99e,0x8(%esp)
c0106ce3:	c0 
c0106ce4:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
c0106ceb:	00 
c0106cec:	c7 04 24 38 d9 10 c0 	movl   $0xc010d938,(%esp)
c0106cf3:	e8 45 97 ff ff       	call   c010043d <__panic>
     *(unsigned char *)0x2000 = 0x0b;
c0106cf8:	b8 00 20 00 00       	mov    $0x2000,%eax
c0106cfd:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c0106d00:	a1 0c 20 1b c0       	mov    0xc01b200c,%eax
c0106d05:	83 f8 02             	cmp    $0x2,%eax
c0106d08:	74 24                	je     c0106d2e <check_content_set+0xa8>
c0106d0a:	c7 44 24 0c 6d da 10 	movl   $0xc010da6d,0xc(%esp)
c0106d11:	c0 
c0106d12:	c7 44 24 08 9e d9 10 	movl   $0xc010d99e,0x8(%esp)
c0106d19:	c0 
c0106d1a:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
c0106d21:	00 
c0106d22:	c7 04 24 38 d9 10 c0 	movl   $0xc010d938,(%esp)
c0106d29:	e8 0f 97 ff ff       	call   c010043d <__panic>
     *(unsigned char *)0x2010 = 0x0b;
c0106d2e:	b8 10 20 00 00       	mov    $0x2010,%eax
c0106d33:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c0106d36:	a1 0c 20 1b c0       	mov    0xc01b200c,%eax
c0106d3b:	83 f8 02             	cmp    $0x2,%eax
c0106d3e:	74 24                	je     c0106d64 <check_content_set+0xde>
c0106d40:	c7 44 24 0c 6d da 10 	movl   $0xc010da6d,0xc(%esp)
c0106d47:	c0 
c0106d48:	c7 44 24 08 9e d9 10 	movl   $0xc010d99e,0x8(%esp)
c0106d4f:	c0 
c0106d50:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
c0106d57:	00 
c0106d58:	c7 04 24 38 d9 10 c0 	movl   $0xc010d938,(%esp)
c0106d5f:	e8 d9 96 ff ff       	call   c010043d <__panic>
     *(unsigned char *)0x3000 = 0x0c;
c0106d64:	b8 00 30 00 00       	mov    $0x3000,%eax
c0106d69:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c0106d6c:	a1 0c 20 1b c0       	mov    0xc01b200c,%eax
c0106d71:	83 f8 03             	cmp    $0x3,%eax
c0106d74:	74 24                	je     c0106d9a <check_content_set+0x114>
c0106d76:	c7 44 24 0c 7c da 10 	movl   $0xc010da7c,0xc(%esp)
c0106d7d:	c0 
c0106d7e:	c7 44 24 08 9e d9 10 	movl   $0xc010d99e,0x8(%esp)
c0106d85:	c0 
c0106d86:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
c0106d8d:	00 
c0106d8e:	c7 04 24 38 d9 10 c0 	movl   $0xc010d938,(%esp)
c0106d95:	e8 a3 96 ff ff       	call   c010043d <__panic>
     *(unsigned char *)0x3010 = 0x0c;
c0106d9a:	b8 10 30 00 00       	mov    $0x3010,%eax
c0106d9f:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c0106da2:	a1 0c 20 1b c0       	mov    0xc01b200c,%eax
c0106da7:	83 f8 03             	cmp    $0x3,%eax
c0106daa:	74 24                	je     c0106dd0 <check_content_set+0x14a>
c0106dac:	c7 44 24 0c 7c da 10 	movl   $0xc010da7c,0xc(%esp)
c0106db3:	c0 
c0106db4:	c7 44 24 08 9e d9 10 	movl   $0xc010d99e,0x8(%esp)
c0106dbb:	c0 
c0106dbc:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
c0106dc3:	00 
c0106dc4:	c7 04 24 38 d9 10 c0 	movl   $0xc010d938,(%esp)
c0106dcb:	e8 6d 96 ff ff       	call   c010043d <__panic>
     *(unsigned char *)0x4000 = 0x0d;
c0106dd0:	b8 00 40 00 00       	mov    $0x4000,%eax
c0106dd5:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c0106dd8:	a1 0c 20 1b c0       	mov    0xc01b200c,%eax
c0106ddd:	83 f8 04             	cmp    $0x4,%eax
c0106de0:	74 24                	je     c0106e06 <check_content_set+0x180>
c0106de2:	c7 44 24 0c 8b da 10 	movl   $0xc010da8b,0xc(%esp)
c0106de9:	c0 
c0106dea:	c7 44 24 08 9e d9 10 	movl   $0xc010d99e,0x8(%esp)
c0106df1:	c0 
c0106df2:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
c0106df9:	00 
c0106dfa:	c7 04 24 38 d9 10 c0 	movl   $0xc010d938,(%esp)
c0106e01:	e8 37 96 ff ff       	call   c010043d <__panic>
     *(unsigned char *)0x4010 = 0x0d;
c0106e06:	b8 10 40 00 00       	mov    $0x4010,%eax
c0106e0b:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c0106e0e:	a1 0c 20 1b c0       	mov    0xc01b200c,%eax
c0106e13:	83 f8 04             	cmp    $0x4,%eax
c0106e16:	74 24                	je     c0106e3c <check_content_set+0x1b6>
c0106e18:	c7 44 24 0c 8b da 10 	movl   $0xc010da8b,0xc(%esp)
c0106e1f:	c0 
c0106e20:	c7 44 24 08 9e d9 10 	movl   $0xc010d99e,0x8(%esp)
c0106e27:	c0 
c0106e28:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
c0106e2f:	00 
c0106e30:	c7 04 24 38 d9 10 c0 	movl   $0xc010d938,(%esp)
c0106e37:	e8 01 96 ff ff       	call   c010043d <__panic>
}
c0106e3c:	90                   	nop
c0106e3d:	c9                   	leave  
c0106e3e:	c3                   	ret    

c0106e3f <check_content_access>:

static inline int
check_content_access(void)
{
c0106e3f:	55                   	push   %ebp
c0106e40:	89 e5                	mov    %esp,%ebp
c0106e42:	83 ec 18             	sub    $0x18,%esp
    int ret = sm->check_swap();
c0106e45:	a1 18 20 1b c0       	mov    0xc01b2018,%eax
c0106e4a:	8b 40 1c             	mov    0x1c(%eax),%eax
c0106e4d:	ff d0                	call   *%eax
c0106e4f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return ret;
c0106e52:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106e55:	c9                   	leave  
c0106e56:	c3                   	ret    

c0106e57 <check_swap>:
#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
check_swap(void)
{
c0106e57:	f3 0f 1e fb          	endbr32 
c0106e5b:	55                   	push   %ebp
c0106e5c:	89 e5                	mov    %esp,%ebp
c0106e5e:	83 ec 78             	sub    $0x78,%esp
    //backup mem env
     int ret, count = 0, total = 0, i;
c0106e61:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0106e68:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     list_entry_t *le = &free_list;
c0106e6f:	c7 45 e8 4c 41 1b c0 	movl   $0xc01b414c,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c0106e76:	eb 6a                	jmp    c0106ee2 <check_swap+0x8b>
        struct Page *p = le2page(le, page_link);
c0106e78:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106e7b:	83 e8 0c             	sub    $0xc,%eax
c0106e7e:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(PageProperty(p));
c0106e81:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0106e84:	83 c0 04             	add    $0x4,%eax
c0106e87:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c0106e8e:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106e91:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0106e94:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0106e97:	0f a3 10             	bt     %edx,(%eax)
c0106e9a:	19 c0                	sbb    %eax,%eax
c0106e9c:	89 45 bc             	mov    %eax,-0x44(%ebp)
    return oldbit != 0;
c0106e9f:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0106ea3:	0f 95 c0             	setne  %al
c0106ea6:	0f b6 c0             	movzbl %al,%eax
c0106ea9:	85 c0                	test   %eax,%eax
c0106eab:	75 24                	jne    c0106ed1 <check_swap+0x7a>
c0106ead:	c7 44 24 0c 9a da 10 	movl   $0xc010da9a,0xc(%esp)
c0106eb4:	c0 
c0106eb5:	c7 44 24 08 9e d9 10 	movl   $0xc010d99e,0x8(%esp)
c0106ebc:	c0 
c0106ebd:	c7 44 24 04 bb 00 00 	movl   $0xbb,0x4(%esp)
c0106ec4:	00 
c0106ec5:	c7 04 24 38 d9 10 c0 	movl   $0xc010d938,(%esp)
c0106ecc:	e8 6c 95 ff ff       	call   c010043d <__panic>
        count ++, total += p->property;
c0106ed1:	ff 45 f4             	incl   -0xc(%ebp)
c0106ed4:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0106ed7:	8b 50 08             	mov    0x8(%eax),%edx
c0106eda:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106edd:	01 d0                	add    %edx,%eax
c0106edf:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106ee2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106ee5:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0106ee8:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0106eeb:	8b 40 04             	mov    0x4(%eax),%eax
     while ((le = list_next(le)) != &free_list) {
c0106eee:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106ef1:	81 7d e8 4c 41 1b c0 	cmpl   $0xc01b414c,-0x18(%ebp)
c0106ef8:	0f 85 7a ff ff ff    	jne    c0106e78 <check_swap+0x21>
     }
     assert(total == nr_free_pages());
c0106efe:	e8 18 cb ff ff       	call   c0103a1b <nr_free_pages>
c0106f03:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0106f06:	39 d0                	cmp    %edx,%eax
c0106f08:	74 24                	je     c0106f2e <check_swap+0xd7>
c0106f0a:	c7 44 24 0c aa da 10 	movl   $0xc010daaa,0xc(%esp)
c0106f11:	c0 
c0106f12:	c7 44 24 08 9e d9 10 	movl   $0xc010d99e,0x8(%esp)
c0106f19:	c0 
c0106f1a:	c7 44 24 04 be 00 00 	movl   $0xbe,0x4(%esp)
c0106f21:	00 
c0106f22:	c7 04 24 38 d9 10 c0 	movl   $0xc010d938,(%esp)
c0106f29:	e8 0f 95 ff ff       	call   c010043d <__panic>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
c0106f2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106f31:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106f35:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106f38:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106f3c:	c7 04 24 c4 da 10 c0 	movl   $0xc010dac4,(%esp)
c0106f43:	e8 89 93 ff ff       	call   c01002d1 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
c0106f48:	e8 cf e6 ff ff       	call   c010561c <mm_create>
c0106f4d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
     assert(mm != NULL);
c0106f50:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106f54:	75 24                	jne    c0106f7a <check_swap+0x123>
c0106f56:	c7 44 24 0c ea da 10 	movl   $0xc010daea,0xc(%esp)
c0106f5d:	c0 
c0106f5e:	c7 44 24 08 9e d9 10 	movl   $0xc010d99e,0x8(%esp)
c0106f65:	c0 
c0106f66:	c7 44 24 04 c3 00 00 	movl   $0xc3,0x4(%esp)
c0106f6d:	00 
c0106f6e:	c7 04 24 38 d9 10 c0 	movl   $0xc010d938,(%esp)
c0106f75:	e8 c3 94 ff ff       	call   c010043d <__panic>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
c0106f7a:	a1 64 40 1b c0       	mov    0xc01b4064,%eax
c0106f7f:	85 c0                	test   %eax,%eax
c0106f81:	74 24                	je     c0106fa7 <check_swap+0x150>
c0106f83:	c7 44 24 0c f5 da 10 	movl   $0xc010daf5,0xc(%esp)
c0106f8a:	c0 
c0106f8b:	c7 44 24 08 9e d9 10 	movl   $0xc010d99e,0x8(%esp)
c0106f92:	c0 
c0106f93:	c7 44 24 04 c6 00 00 	movl   $0xc6,0x4(%esp)
c0106f9a:	00 
c0106f9b:	c7 04 24 38 d9 10 c0 	movl   $0xc010d938,(%esp)
c0106fa2:	e8 96 94 ff ff       	call   c010043d <__panic>

     check_mm_struct = mm;
c0106fa7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106faa:	a3 64 40 1b c0       	mov    %eax,0xc01b4064

     pde_t *pgdir = mm->pgdir = boot_pgdir;
c0106faf:	8b 15 e0 e9 12 c0    	mov    0xc012e9e0,%edx
c0106fb5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106fb8:	89 50 0c             	mov    %edx,0xc(%eax)
c0106fbb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106fbe:	8b 40 0c             	mov    0xc(%eax),%eax
c0106fc1:	89 45 e0             	mov    %eax,-0x20(%ebp)
     assert(pgdir[0] == 0);
c0106fc4:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106fc7:	8b 00                	mov    (%eax),%eax
c0106fc9:	85 c0                	test   %eax,%eax
c0106fcb:	74 24                	je     c0106ff1 <check_swap+0x19a>
c0106fcd:	c7 44 24 0c 0d db 10 	movl   $0xc010db0d,0xc(%esp)
c0106fd4:	c0 
c0106fd5:	c7 44 24 08 9e d9 10 	movl   $0xc010d99e,0x8(%esp)
c0106fdc:	c0 
c0106fdd:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
c0106fe4:	00 
c0106fe5:	c7 04 24 38 d9 10 c0 	movl   $0xc010d938,(%esp)
c0106fec:	e8 4c 94 ff ff       	call   c010043d <__panic>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
c0106ff1:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
c0106ff8:	00 
c0106ff9:	c7 44 24 04 00 60 00 	movl   $0x6000,0x4(%esp)
c0107000:	00 
c0107001:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
c0107008:	e8 ad e6 ff ff       	call   c01056ba <vma_create>
c010700d:	89 45 dc             	mov    %eax,-0x24(%ebp)
     assert(vma != NULL);
c0107010:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0107014:	75 24                	jne    c010703a <check_swap+0x1e3>
c0107016:	c7 44 24 0c 1b db 10 	movl   $0xc010db1b,0xc(%esp)
c010701d:	c0 
c010701e:	c7 44 24 08 9e d9 10 	movl   $0xc010d99e,0x8(%esp)
c0107025:	c0 
c0107026:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
c010702d:	00 
c010702e:	c7 04 24 38 d9 10 c0 	movl   $0xc010d938,(%esp)
c0107035:	e8 03 94 ff ff       	call   c010043d <__panic>

     insert_vma_struct(mm, vma);
c010703a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010703d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107041:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107044:	89 04 24             	mov    %eax,(%esp)
c0107047:	e8 07 e8 ff ff       	call   c0105853 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
c010704c:	c7 04 24 28 db 10 c0 	movl   $0xc010db28,(%esp)
c0107053:	e8 79 92 ff ff       	call   c01002d1 <cprintf>
     pte_t *temp_ptep=NULL;
c0107058:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
c010705f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107062:	8b 40 0c             	mov    0xc(%eax),%eax
c0107065:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c010706c:	00 
c010706d:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0107074:	00 
c0107075:	89 04 24             	mov    %eax,(%esp)
c0107078:	e8 c8 cf ff ff       	call   c0104045 <get_pte>
c010707d:	89 45 d8             	mov    %eax,-0x28(%ebp)
     assert(temp_ptep!= NULL);
c0107080:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0107084:	75 24                	jne    c01070aa <check_swap+0x253>
c0107086:	c7 44 24 0c 5c db 10 	movl   $0xc010db5c,0xc(%esp)
c010708d:	c0 
c010708e:	c7 44 24 08 9e d9 10 	movl   $0xc010d99e,0x8(%esp)
c0107095:	c0 
c0107096:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
c010709d:	00 
c010709e:	c7 04 24 38 d9 10 c0 	movl   $0xc010d938,(%esp)
c01070a5:	e8 93 93 ff ff       	call   c010043d <__panic>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
c01070aa:	c7 04 24 70 db 10 c0 	movl   $0xc010db70,(%esp)
c01070b1:	e8 1b 92 ff ff       	call   c01002d1 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01070b6:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01070bd:	e9 a2 00 00 00       	jmp    c0107164 <check_swap+0x30d>
          check_rp[i] = alloc_page();
c01070c2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01070c9:	e8 a7 c8 ff ff       	call   c0103975 <alloc_pages>
c01070ce:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01070d1:	89 04 95 80 40 1b c0 	mov    %eax,-0x3fe4bf80(,%edx,4)
          assert(check_rp[i] != NULL );
c01070d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01070db:	8b 04 85 80 40 1b c0 	mov    -0x3fe4bf80(,%eax,4),%eax
c01070e2:	85 c0                	test   %eax,%eax
c01070e4:	75 24                	jne    c010710a <check_swap+0x2b3>
c01070e6:	c7 44 24 0c 94 db 10 	movl   $0xc010db94,0xc(%esp)
c01070ed:	c0 
c01070ee:	c7 44 24 08 9e d9 10 	movl   $0xc010d99e,0x8(%esp)
c01070f5:	c0 
c01070f6:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
c01070fd:	00 
c01070fe:	c7 04 24 38 d9 10 c0 	movl   $0xc010d938,(%esp)
c0107105:	e8 33 93 ff ff       	call   c010043d <__panic>
          assert(!PageProperty(check_rp[i]));
c010710a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010710d:	8b 04 85 80 40 1b c0 	mov    -0x3fe4bf80(,%eax,4),%eax
c0107114:	83 c0 04             	add    $0x4,%eax
c0107117:	c7 45 b4 01 00 00 00 	movl   $0x1,-0x4c(%ebp)
c010711e:	89 45 b0             	mov    %eax,-0x50(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0107121:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0107124:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0107127:	0f a3 10             	bt     %edx,(%eax)
c010712a:	19 c0                	sbb    %eax,%eax
c010712c:	89 45 ac             	mov    %eax,-0x54(%ebp)
    return oldbit != 0;
c010712f:	83 7d ac 00          	cmpl   $0x0,-0x54(%ebp)
c0107133:	0f 95 c0             	setne  %al
c0107136:	0f b6 c0             	movzbl %al,%eax
c0107139:	85 c0                	test   %eax,%eax
c010713b:	74 24                	je     c0107161 <check_swap+0x30a>
c010713d:	c7 44 24 0c a8 db 10 	movl   $0xc010dba8,0xc(%esp)
c0107144:	c0 
c0107145:	c7 44 24 08 9e d9 10 	movl   $0xc010d99e,0x8(%esp)
c010714c:	c0 
c010714d:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
c0107154:	00 
c0107155:	c7 04 24 38 d9 10 c0 	movl   $0xc010d938,(%esp)
c010715c:	e8 dc 92 ff ff       	call   c010043d <__panic>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0107161:	ff 45 ec             	incl   -0x14(%ebp)
c0107164:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0107168:	0f 8e 54 ff ff ff    	jle    c01070c2 <check_swap+0x26b>
     }
     list_entry_t free_list_store = free_list;
c010716e:	a1 4c 41 1b c0       	mov    0xc01b414c,%eax
c0107173:	8b 15 50 41 1b c0    	mov    0xc01b4150,%edx
c0107179:	89 45 98             	mov    %eax,-0x68(%ebp)
c010717c:	89 55 9c             	mov    %edx,-0x64(%ebp)
c010717f:	c7 45 a4 4c 41 1b c0 	movl   $0xc01b414c,-0x5c(%ebp)
    elm->prev = elm->next = elm;
c0107186:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0107189:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c010718c:	89 50 04             	mov    %edx,0x4(%eax)
c010718f:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0107192:	8b 50 04             	mov    0x4(%eax),%edx
c0107195:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0107198:	89 10                	mov    %edx,(%eax)
}
c010719a:	90                   	nop
c010719b:	c7 45 a8 4c 41 1b c0 	movl   $0xc01b414c,-0x58(%ebp)
    return list->next == list;
c01071a2:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01071a5:	8b 40 04             	mov    0x4(%eax),%eax
c01071a8:	39 45 a8             	cmp    %eax,-0x58(%ebp)
c01071ab:	0f 94 c0             	sete   %al
c01071ae:	0f b6 c0             	movzbl %al,%eax
     list_init(&free_list);
     assert(list_empty(&free_list));
c01071b1:	85 c0                	test   %eax,%eax
c01071b3:	75 24                	jne    c01071d9 <check_swap+0x382>
c01071b5:	c7 44 24 0c c3 db 10 	movl   $0xc010dbc3,0xc(%esp)
c01071bc:	c0 
c01071bd:	c7 44 24 08 9e d9 10 	movl   $0xc010d99e,0x8(%esp)
c01071c4:	c0 
c01071c5:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
c01071cc:	00 
c01071cd:	c7 04 24 38 d9 10 c0 	movl   $0xc010d938,(%esp)
c01071d4:	e8 64 92 ff ff       	call   c010043d <__panic>
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
c01071d9:	a1 54 41 1b c0       	mov    0xc01b4154,%eax
c01071de:	89 45 d4             	mov    %eax,-0x2c(%ebp)
     nr_free = 0;
c01071e1:	c7 05 54 41 1b c0 00 	movl   $0x0,0xc01b4154
c01071e8:	00 00 00 
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01071eb:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01071f2:	eb 1d                	jmp    c0107211 <check_swap+0x3ba>
        free_pages(check_rp[i],1);
c01071f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01071f7:	8b 04 85 80 40 1b c0 	mov    -0x3fe4bf80(,%eax,4),%eax
c01071fe:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107205:	00 
c0107206:	89 04 24             	mov    %eax,(%esp)
c0107209:	e8 d6 c7 ff ff       	call   c01039e4 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c010720e:	ff 45 ec             	incl   -0x14(%ebp)
c0107211:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0107215:	7e dd                	jle    c01071f4 <check_swap+0x39d>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
c0107217:	a1 54 41 1b c0       	mov    0xc01b4154,%eax
c010721c:	83 f8 04             	cmp    $0x4,%eax
c010721f:	74 24                	je     c0107245 <check_swap+0x3ee>
c0107221:	c7 44 24 0c dc db 10 	movl   $0xc010dbdc,0xc(%esp)
c0107228:	c0 
c0107229:	c7 44 24 08 9e d9 10 	movl   $0xc010d99e,0x8(%esp)
c0107230:	c0 
c0107231:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
c0107238:	00 
c0107239:	c7 04 24 38 d9 10 c0 	movl   $0xc010d938,(%esp)
c0107240:	e8 f8 91 ff ff       	call   c010043d <__panic>
     
     cprintf("set up init env for check_swap begin!\n");
c0107245:	c7 04 24 00 dc 10 c0 	movl   $0xc010dc00,(%esp)
c010724c:	e8 80 90 ff ff       	call   c01002d1 <cprintf>
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
c0107251:	c7 05 0c 20 1b c0 00 	movl   $0x0,0xc01b200c
c0107258:	00 00 00 
     
     check_content_set();
c010725b:	e8 26 fa ff ff       	call   c0106c86 <check_content_set>
     assert( nr_free == 0);         
c0107260:	a1 54 41 1b c0       	mov    0xc01b4154,%eax
c0107265:	85 c0                	test   %eax,%eax
c0107267:	74 24                	je     c010728d <check_swap+0x436>
c0107269:	c7 44 24 0c 27 dc 10 	movl   $0xc010dc27,0xc(%esp)
c0107270:	c0 
c0107271:	c7 44 24 08 9e d9 10 	movl   $0xc010d99e,0x8(%esp)
c0107278:	c0 
c0107279:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
c0107280:	00 
c0107281:	c7 04 24 38 d9 10 c0 	movl   $0xc010d938,(%esp)
c0107288:	e8 b0 91 ff ff       	call   c010043d <__panic>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c010728d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0107294:	eb 25                	jmp    c01072bb <check_swap+0x464>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
c0107296:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107299:	c7 04 85 a0 40 1b c0 	movl   $0xffffffff,-0x3fe4bf60(,%eax,4)
c01072a0:	ff ff ff ff 
c01072a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01072a7:	8b 14 85 a0 40 1b c0 	mov    -0x3fe4bf60(,%eax,4),%edx
c01072ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01072b1:	89 14 85 e0 40 1b c0 	mov    %edx,-0x3fe4bf20(,%eax,4)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c01072b8:	ff 45 ec             	incl   -0x14(%ebp)
c01072bb:	83 7d ec 09          	cmpl   $0x9,-0x14(%ebp)
c01072bf:	7e d5                	jle    c0107296 <check_swap+0x43f>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01072c1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01072c8:	e9 e8 00 00 00       	jmp    c01073b5 <check_swap+0x55e>
         check_ptep[i]=0;
c01072cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01072d0:	c7 04 85 34 41 1b c0 	movl   $0x0,-0x3fe4becc(,%eax,4)
c01072d7:	00 00 00 00 
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
c01072db:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01072de:	40                   	inc    %eax
c01072df:	c1 e0 0c             	shl    $0xc,%eax
c01072e2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01072e9:	00 
c01072ea:	89 44 24 04          	mov    %eax,0x4(%esp)
c01072ee:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01072f1:	89 04 24             	mov    %eax,(%esp)
c01072f4:	e8 4c cd ff ff       	call   c0104045 <get_pte>
c01072f9:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01072fc:	89 04 95 34 41 1b c0 	mov    %eax,-0x3fe4becc(,%edx,4)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
c0107303:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107306:	8b 04 85 34 41 1b c0 	mov    -0x3fe4becc(,%eax,4),%eax
c010730d:	85 c0                	test   %eax,%eax
c010730f:	75 24                	jne    c0107335 <check_swap+0x4de>
c0107311:	c7 44 24 0c 34 dc 10 	movl   $0xc010dc34,0xc(%esp)
c0107318:	c0 
c0107319:	c7 44 24 08 9e d9 10 	movl   $0xc010d99e,0x8(%esp)
c0107320:	c0 
c0107321:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c0107328:	00 
c0107329:	c7 04 24 38 d9 10 c0 	movl   $0xc010d938,(%esp)
c0107330:	e8 08 91 ff ff       	call   c010043d <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
c0107335:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107338:	8b 04 85 34 41 1b c0 	mov    -0x3fe4becc(,%eax,4),%eax
c010733f:	8b 00                	mov    (%eax),%eax
c0107341:	89 04 24             	mov    %eax,(%esp)
c0107344:	e8 73 f5 ff ff       	call   c01068bc <pte2page>
c0107349:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010734c:	8b 14 95 80 40 1b c0 	mov    -0x3fe4bf80(,%edx,4),%edx
c0107353:	39 d0                	cmp    %edx,%eax
c0107355:	74 24                	je     c010737b <check_swap+0x524>
c0107357:	c7 44 24 0c 4c dc 10 	movl   $0xc010dc4c,0xc(%esp)
c010735e:	c0 
c010735f:	c7 44 24 08 9e d9 10 	movl   $0xc010d99e,0x8(%esp)
c0107366:	c0 
c0107367:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
c010736e:	00 
c010736f:	c7 04 24 38 d9 10 c0 	movl   $0xc010d938,(%esp)
c0107376:	e8 c2 90 ff ff       	call   c010043d <__panic>
         assert((*check_ptep[i] & PTE_P));          
c010737b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010737e:	8b 04 85 34 41 1b c0 	mov    -0x3fe4becc(,%eax,4),%eax
c0107385:	8b 00                	mov    (%eax),%eax
c0107387:	83 e0 01             	and    $0x1,%eax
c010738a:	85 c0                	test   %eax,%eax
c010738c:	75 24                	jne    c01073b2 <check_swap+0x55b>
c010738e:	c7 44 24 0c 74 dc 10 	movl   $0xc010dc74,0xc(%esp)
c0107395:	c0 
c0107396:	c7 44 24 08 9e d9 10 	movl   $0xc010d99e,0x8(%esp)
c010739d:	c0 
c010739e:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
c01073a5:	00 
c01073a6:	c7 04 24 38 d9 10 c0 	movl   $0xc010d938,(%esp)
c01073ad:	e8 8b 90 ff ff       	call   c010043d <__panic>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01073b2:	ff 45 ec             	incl   -0x14(%ebp)
c01073b5:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c01073b9:	0f 8e 0e ff ff ff    	jle    c01072cd <check_swap+0x476>
     }
     cprintf("set up init env for check_swap over!\n");
c01073bf:	c7 04 24 90 dc 10 c0 	movl   $0xc010dc90,(%esp)
c01073c6:	e8 06 8f ff ff       	call   c01002d1 <cprintf>
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
c01073cb:	e8 6f fa ff ff       	call   c0106e3f <check_content_access>
c01073d0:	89 45 d0             	mov    %eax,-0x30(%ebp)
     assert(ret==0);
c01073d3:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c01073d7:	74 24                	je     c01073fd <check_swap+0x5a6>
c01073d9:	c7 44 24 0c b6 dc 10 	movl   $0xc010dcb6,0xc(%esp)
c01073e0:	c0 
c01073e1:	c7 44 24 08 9e d9 10 	movl   $0xc010d99e,0x8(%esp)
c01073e8:	c0 
c01073e9:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
c01073f0:	00 
c01073f1:	c7 04 24 38 d9 10 c0 	movl   $0xc010d938,(%esp)
c01073f8:	e8 40 90 ff ff       	call   c010043d <__panic>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01073fd:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0107404:	eb 1d                	jmp    c0107423 <check_swap+0x5cc>
         free_pages(check_rp[i],1);
c0107406:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107409:	8b 04 85 80 40 1b c0 	mov    -0x3fe4bf80(,%eax,4),%eax
c0107410:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107417:	00 
c0107418:	89 04 24             	mov    %eax,(%esp)
c010741b:	e8 c4 c5 ff ff       	call   c01039e4 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0107420:	ff 45 ec             	incl   -0x14(%ebp)
c0107423:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0107427:	7e dd                	jle    c0107406 <check_swap+0x5af>
     } 

     //free_page(pte2page(*temp_ptep));
    free_page(pde2page(pgdir[0]));
c0107429:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010742c:	8b 00                	mov    (%eax),%eax
c010742e:	89 04 24             	mov    %eax,(%esp)
c0107431:	e8 c4 f4 ff ff       	call   c01068fa <pde2page>
c0107436:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010743d:	00 
c010743e:	89 04 24             	mov    %eax,(%esp)
c0107441:	e8 9e c5 ff ff       	call   c01039e4 <free_pages>
     pgdir[0] = 0;
c0107446:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107449:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
     mm->pgdir = NULL;
c010744f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107452:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
     mm_destroy(mm);
c0107459:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010745c:	89 04 24             	mov    %eax,(%esp)
c010745f:	e8 27 e5 ff ff       	call   c010598b <mm_destroy>
     check_mm_struct = NULL;
c0107464:	c7 05 64 40 1b c0 00 	movl   $0x0,0xc01b4064
c010746b:	00 00 00 
     
     nr_free = nr_free_store;
c010746e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0107471:	a3 54 41 1b c0       	mov    %eax,0xc01b4154
     free_list = free_list_store;
c0107476:	8b 45 98             	mov    -0x68(%ebp),%eax
c0107479:	8b 55 9c             	mov    -0x64(%ebp),%edx
c010747c:	a3 4c 41 1b c0       	mov    %eax,0xc01b414c
c0107481:	89 15 50 41 1b c0    	mov    %edx,0xc01b4150

     
     le = &free_list;
c0107487:	c7 45 e8 4c 41 1b c0 	movl   $0xc01b414c,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c010748e:	eb 1c                	jmp    c01074ac <check_swap+0x655>
         struct Page *p = le2page(le, page_link);
c0107490:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107493:	83 e8 0c             	sub    $0xc,%eax
c0107496:	89 45 cc             	mov    %eax,-0x34(%ebp)
         count --, total -= p->property;
c0107499:	ff 4d f4             	decl   -0xc(%ebp)
c010749c:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010749f:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01074a2:	8b 40 08             	mov    0x8(%eax),%eax
c01074a5:	29 c2                	sub    %eax,%edx
c01074a7:	89 d0                	mov    %edx,%eax
c01074a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01074ac:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01074af:	89 45 a0             	mov    %eax,-0x60(%ebp)
    return listelm->next;
c01074b2:	8b 45 a0             	mov    -0x60(%ebp),%eax
c01074b5:	8b 40 04             	mov    0x4(%eax),%eax
     while ((le = list_next(le)) != &free_list) {
c01074b8:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01074bb:	81 7d e8 4c 41 1b c0 	cmpl   $0xc01b414c,-0x18(%ebp)
c01074c2:	75 cc                	jne    c0107490 <check_swap+0x639>
     }
     cprintf("count is %d, total is %d\n",count,total);
c01074c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01074c7:	89 44 24 08          	mov    %eax,0x8(%esp)
c01074cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01074ce:	89 44 24 04          	mov    %eax,0x4(%esp)
c01074d2:	c7 04 24 bd dc 10 c0 	movl   $0xc010dcbd,(%esp)
c01074d9:	e8 f3 8d ff ff       	call   c01002d1 <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
c01074de:	c7 04 24 d7 dc 10 c0 	movl   $0xc010dcd7,(%esp)
c01074e5:	e8 e7 8d ff ff       	call   c01002d1 <cprintf>
}
c01074ea:	90                   	nop
c01074eb:	c9                   	leave  
c01074ec:	c3                   	ret    

c01074ed <__intr_save>:
__intr_save(void) {
c01074ed:	55                   	push   %ebp
c01074ee:	89 e5                	mov    %esp,%ebp
c01074f0:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c01074f3:	9c                   	pushf  
c01074f4:	58                   	pop    %eax
c01074f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c01074f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c01074fb:	25 00 02 00 00       	and    $0x200,%eax
c0107500:	85 c0                	test   %eax,%eax
c0107502:	74 0c                	je     c0107510 <__intr_save+0x23>
        intr_disable();
c0107504:	e8 ef ad ff ff       	call   c01022f8 <intr_disable>
        return 1;
c0107509:	b8 01 00 00 00       	mov    $0x1,%eax
c010750e:	eb 05                	jmp    c0107515 <__intr_save+0x28>
    return 0;
c0107510:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107515:	c9                   	leave  
c0107516:	c3                   	ret    

c0107517 <__intr_restore>:
__intr_restore(bool flag) {
c0107517:	55                   	push   %ebp
c0107518:	89 e5                	mov    %esp,%ebp
c010751a:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c010751d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0107521:	74 05                	je     c0107528 <__intr_restore+0x11>
        intr_enable();
c0107523:	e8 c4 ad ff ff       	call   c01022ec <intr_enable>
}
c0107528:	90                   	nop
c0107529:	c9                   	leave  
c010752a:	c3                   	ret    

c010752b <page2ppn>:
page2ppn(struct Page *page) {
c010752b:	55                   	push   %ebp
c010752c:	89 e5                	mov    %esp,%ebp
    return page - pages;
c010752e:	a1 60 40 1b c0       	mov    0xc01b4060,%eax
c0107533:	8b 55 08             	mov    0x8(%ebp),%edx
c0107536:	29 c2                	sub    %eax,%edx
c0107538:	89 d0                	mov    %edx,%eax
c010753a:	c1 f8 05             	sar    $0x5,%eax
}
c010753d:	5d                   	pop    %ebp
c010753e:	c3                   	ret    

c010753f <page2pa>:
page2pa(struct Page *page) {
c010753f:	55                   	push   %ebp
c0107540:	89 e5                	mov    %esp,%ebp
c0107542:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0107545:	8b 45 08             	mov    0x8(%ebp),%eax
c0107548:	89 04 24             	mov    %eax,(%esp)
c010754b:	e8 db ff ff ff       	call   c010752b <page2ppn>
c0107550:	c1 e0 0c             	shl    $0xc,%eax
}
c0107553:	c9                   	leave  
c0107554:	c3                   	ret    

c0107555 <pa2page>:
pa2page(uintptr_t pa) {
c0107555:	55                   	push   %ebp
c0107556:	89 e5                	mov    %esp,%ebp
c0107558:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c010755b:	8b 45 08             	mov    0x8(%ebp),%eax
c010755e:	c1 e8 0c             	shr    $0xc,%eax
c0107561:	89 c2                	mov    %eax,%edx
c0107563:	a1 80 1f 1b c0       	mov    0xc01b1f80,%eax
c0107568:	39 c2                	cmp    %eax,%edx
c010756a:	72 1c                	jb     c0107588 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c010756c:	c7 44 24 08 f0 dc 10 	movl   $0xc010dcf0,0x8(%esp)
c0107573:	c0 
c0107574:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c010757b:	00 
c010757c:	c7 04 24 0f dd 10 c0 	movl   $0xc010dd0f,(%esp)
c0107583:	e8 b5 8e ff ff       	call   c010043d <__panic>
    return &pages[PPN(pa)];
c0107588:	a1 60 40 1b c0       	mov    0xc01b4060,%eax
c010758d:	8b 55 08             	mov    0x8(%ebp),%edx
c0107590:	c1 ea 0c             	shr    $0xc,%edx
c0107593:	c1 e2 05             	shl    $0x5,%edx
c0107596:	01 d0                	add    %edx,%eax
}
c0107598:	c9                   	leave  
c0107599:	c3                   	ret    

c010759a <page2kva>:
page2kva(struct Page *page) {
c010759a:	55                   	push   %ebp
c010759b:	89 e5                	mov    %esp,%ebp
c010759d:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c01075a0:	8b 45 08             	mov    0x8(%ebp),%eax
c01075a3:	89 04 24             	mov    %eax,(%esp)
c01075a6:	e8 94 ff ff ff       	call   c010753f <page2pa>
c01075ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01075ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01075b1:	c1 e8 0c             	shr    $0xc,%eax
c01075b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01075b7:	a1 80 1f 1b c0       	mov    0xc01b1f80,%eax
c01075bc:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01075bf:	72 23                	jb     c01075e4 <page2kva+0x4a>
c01075c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01075c4:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01075c8:	c7 44 24 08 20 dd 10 	movl   $0xc010dd20,0x8(%esp)
c01075cf:	c0 
c01075d0:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c01075d7:	00 
c01075d8:	c7 04 24 0f dd 10 c0 	movl   $0xc010dd0f,(%esp)
c01075df:	e8 59 8e ff ff       	call   c010043d <__panic>
c01075e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01075e7:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c01075ec:	c9                   	leave  
c01075ed:	c3                   	ret    

c01075ee <kva2page>:
kva2page(void *kva) {
c01075ee:	55                   	push   %ebp
c01075ef:	89 e5                	mov    %esp,%ebp
c01075f1:	83 ec 28             	sub    $0x28,%esp
    return pa2page(PADDR(kva));
c01075f4:	8b 45 08             	mov    0x8(%ebp),%eax
c01075f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01075fa:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0107601:	77 23                	ja     c0107626 <kva2page+0x38>
c0107603:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107606:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010760a:	c7 44 24 08 44 dd 10 	movl   $0xc010dd44,0x8(%esp)
c0107611:	c0 
c0107612:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
c0107619:	00 
c010761a:	c7 04 24 0f dd 10 c0 	movl   $0xc010dd0f,(%esp)
c0107621:	e8 17 8e ff ff       	call   c010043d <__panic>
c0107626:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107629:	05 00 00 00 40       	add    $0x40000000,%eax
c010762e:	89 04 24             	mov    %eax,(%esp)
c0107631:	e8 1f ff ff ff       	call   c0107555 <pa2page>
}
c0107636:	c9                   	leave  
c0107637:	c3                   	ret    

c0107638 <__slob_get_free_pages>:
static slob_t *slobfree = &arena;
static bigblock_t *bigblocks;


static void* __slob_get_free_pages(gfp_t gfp, int order)
{
c0107638:	f3 0f 1e fb          	endbr32 
c010763c:	55                   	push   %ebp
c010763d:	89 e5                	mov    %esp,%ebp
c010763f:	83 ec 28             	sub    $0x28,%esp
  struct Page * page = alloc_pages(1 << order);
c0107642:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107645:	ba 01 00 00 00       	mov    $0x1,%edx
c010764a:	88 c1                	mov    %al,%cl
c010764c:	d3 e2                	shl    %cl,%edx
c010764e:	89 d0                	mov    %edx,%eax
c0107650:	89 04 24             	mov    %eax,(%esp)
c0107653:	e8 1d c3 ff ff       	call   c0103975 <alloc_pages>
c0107658:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!page)
c010765b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010765f:	75 07                	jne    c0107668 <__slob_get_free_pages+0x30>
    return NULL;
c0107661:	b8 00 00 00 00       	mov    $0x0,%eax
c0107666:	eb 0b                	jmp    c0107673 <__slob_get_free_pages+0x3b>
  return page2kva(page);
c0107668:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010766b:	89 04 24             	mov    %eax,(%esp)
c010766e:	e8 27 ff ff ff       	call   c010759a <page2kva>
}
c0107673:	c9                   	leave  
c0107674:	c3                   	ret    

c0107675 <__slob_free_pages>:

#define __slob_get_free_page(gfp) __slob_get_free_pages(gfp, 0)

static inline void __slob_free_pages(unsigned long kva, int order)
{
c0107675:	55                   	push   %ebp
c0107676:	89 e5                	mov    %esp,%ebp
c0107678:	53                   	push   %ebx
c0107679:	83 ec 14             	sub    $0x14,%esp
  free_pages(kva2page(kva), 1 << order);
c010767c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010767f:	ba 01 00 00 00       	mov    $0x1,%edx
c0107684:	88 c1                	mov    %al,%cl
c0107686:	d3 e2                	shl    %cl,%edx
c0107688:	89 d0                	mov    %edx,%eax
c010768a:	89 c3                	mov    %eax,%ebx
c010768c:	8b 45 08             	mov    0x8(%ebp),%eax
c010768f:	89 04 24             	mov    %eax,(%esp)
c0107692:	e8 57 ff ff ff       	call   c01075ee <kva2page>
c0107697:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c010769b:	89 04 24             	mov    %eax,(%esp)
c010769e:	e8 41 c3 ff ff       	call   c01039e4 <free_pages>
}
c01076a3:	90                   	nop
c01076a4:	83 c4 14             	add    $0x14,%esp
c01076a7:	5b                   	pop    %ebx
c01076a8:	5d                   	pop    %ebp
c01076a9:	c3                   	ret    

c01076aa <slob_alloc>:

static void slob_free(void *b, int size);

static void *slob_alloc(size_t size, gfp_t gfp, int align)
{
c01076aa:	f3 0f 1e fb          	endbr32 
c01076ae:	55                   	push   %ebp
c01076af:	89 e5                	mov    %esp,%ebp
c01076b1:	83 ec 38             	sub    $0x38,%esp
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
c01076b4:	8b 45 08             	mov    0x8(%ebp),%eax
c01076b7:	83 c0 08             	add    $0x8,%eax
c01076ba:	3d ff 0f 00 00       	cmp    $0xfff,%eax
c01076bf:	76 24                	jbe    c01076e5 <slob_alloc+0x3b>
c01076c1:	c7 44 24 0c 68 dd 10 	movl   $0xc010dd68,0xc(%esp)
c01076c8:	c0 
c01076c9:	c7 44 24 08 87 dd 10 	movl   $0xc010dd87,0x8(%esp)
c01076d0:	c0 
c01076d1:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c01076d8:	00 
c01076d9:	c7 04 24 9c dd 10 c0 	movl   $0xc010dd9c,(%esp)
c01076e0:	e8 58 8d ff ff       	call   c010043d <__panic>

	slob_t *prev, *cur, *aligned = 0;
c01076e5:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	int delta = 0, units = SLOB_UNITS(size);
c01076ec:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c01076f3:	8b 45 08             	mov    0x8(%ebp),%eax
c01076f6:	83 c0 07             	add    $0x7,%eax
c01076f9:	c1 e8 03             	shr    $0x3,%eax
c01076fc:	89 45 e0             	mov    %eax,-0x20(%ebp)
	unsigned long flags;

	spin_lock_irqsave(&slob_lock, flags);
c01076ff:	e8 e9 fd ff ff       	call   c01074ed <__intr_save>
c0107704:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	prev = slobfree;
c0107707:	a1 40 ea 12 c0       	mov    0xc012ea40,%eax
c010770c:	89 45 f4             	mov    %eax,-0xc(%ebp)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
c010770f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107712:	8b 40 04             	mov    0x4(%eax),%eax
c0107715:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if (align) {
c0107718:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010771c:	74 21                	je     c010773f <slob_alloc+0x95>
			aligned = (slob_t *)ALIGN((unsigned long)cur, align);
c010771e:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0107721:	8b 45 10             	mov    0x10(%ebp),%eax
c0107724:	01 d0                	add    %edx,%eax
c0107726:	8d 50 ff             	lea    -0x1(%eax),%edx
c0107729:	8b 45 10             	mov    0x10(%ebp),%eax
c010772c:	f7 d8                	neg    %eax
c010772e:	21 d0                	and    %edx,%eax
c0107730:	89 45 ec             	mov    %eax,-0x14(%ebp)
			delta = aligned - cur;
c0107733:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107736:	2b 45 f0             	sub    -0x10(%ebp),%eax
c0107739:	c1 f8 03             	sar    $0x3,%eax
c010773c:	89 45 e8             	mov    %eax,-0x18(%ebp)
		}
		if (cur->units >= units + delta) { /* room enough? */
c010773f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107742:	8b 00                	mov    (%eax),%eax
c0107744:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c0107747:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010774a:	01 ca                	add    %ecx,%edx
c010774c:	39 d0                	cmp    %edx,%eax
c010774e:	0f 8c aa 00 00 00    	jl     c01077fe <slob_alloc+0x154>
			if (delta) { /* need to fragment head to align? */
c0107754:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0107758:	74 38                	je     c0107792 <slob_alloc+0xe8>
				aligned->units = cur->units - delta;
c010775a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010775d:	8b 00                	mov    (%eax),%eax
c010775f:	2b 45 e8             	sub    -0x18(%ebp),%eax
c0107762:	89 c2                	mov    %eax,%edx
c0107764:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107767:	89 10                	mov    %edx,(%eax)
				aligned->next = cur->next;
c0107769:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010776c:	8b 50 04             	mov    0x4(%eax),%edx
c010776f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107772:	89 50 04             	mov    %edx,0x4(%eax)
				cur->next = aligned;
c0107775:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107778:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010777b:	89 50 04             	mov    %edx,0x4(%eax)
				cur->units = delta;
c010777e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107781:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0107784:	89 10                	mov    %edx,(%eax)
				prev = cur;
c0107786:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107789:	89 45 f4             	mov    %eax,-0xc(%ebp)
				cur = aligned;
c010778c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010778f:	89 45 f0             	mov    %eax,-0x10(%ebp)
			}

			if (cur->units == units) /* exact fit? */
c0107792:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107795:	8b 00                	mov    (%eax),%eax
c0107797:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c010779a:	75 0e                	jne    c01077aa <slob_alloc+0x100>
				prev->next = cur->next; /* unlink */
c010779c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010779f:	8b 50 04             	mov    0x4(%eax),%edx
c01077a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01077a5:	89 50 04             	mov    %edx,0x4(%eax)
c01077a8:	eb 3c                	jmp    c01077e6 <slob_alloc+0x13c>
			else { /* fragment */
				prev->next = cur + units;
c01077aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01077ad:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01077b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01077b7:	01 c2                	add    %eax,%edx
c01077b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01077bc:	89 50 04             	mov    %edx,0x4(%eax)
				prev->next->units = cur->units - units;
c01077bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01077c2:	8b 10                	mov    (%eax),%edx
c01077c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01077c7:	8b 40 04             	mov    0x4(%eax),%eax
c01077ca:	2b 55 e0             	sub    -0x20(%ebp),%edx
c01077cd:	89 10                	mov    %edx,(%eax)
				prev->next->next = cur->next;
c01077cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01077d2:	8b 40 04             	mov    0x4(%eax),%eax
c01077d5:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01077d8:	8b 52 04             	mov    0x4(%edx),%edx
c01077db:	89 50 04             	mov    %edx,0x4(%eax)
				cur->units = units;
c01077de:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01077e1:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01077e4:	89 10                	mov    %edx,(%eax)
			}

			slobfree = prev;
c01077e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01077e9:	a3 40 ea 12 c0       	mov    %eax,0xc012ea40
			spin_unlock_irqrestore(&slob_lock, flags);
c01077ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01077f1:	89 04 24             	mov    %eax,(%esp)
c01077f4:	e8 1e fd ff ff       	call   c0107517 <__intr_restore>
			return cur;
c01077f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01077fc:	eb 7f                	jmp    c010787d <slob_alloc+0x1d3>
		}
		if (cur == slobfree) {
c01077fe:	a1 40 ea 12 c0       	mov    0xc012ea40,%eax
c0107803:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0107806:	75 61                	jne    c0107869 <slob_alloc+0x1bf>
			spin_unlock_irqrestore(&slob_lock, flags);
c0107808:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010780b:	89 04 24             	mov    %eax,(%esp)
c010780e:	e8 04 fd ff ff       	call   c0107517 <__intr_restore>

			if (size == PAGE_SIZE) /* trying to shrink arena? */
c0107813:	81 7d 08 00 10 00 00 	cmpl   $0x1000,0x8(%ebp)
c010781a:	75 07                	jne    c0107823 <slob_alloc+0x179>
				return 0;
c010781c:	b8 00 00 00 00       	mov    $0x0,%eax
c0107821:	eb 5a                	jmp    c010787d <slob_alloc+0x1d3>

			cur = (slob_t *)__slob_get_free_page(gfp);
c0107823:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010782a:	00 
c010782b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010782e:	89 04 24             	mov    %eax,(%esp)
c0107831:	e8 02 fe ff ff       	call   c0107638 <__slob_get_free_pages>
c0107836:	89 45 f0             	mov    %eax,-0x10(%ebp)
			if (!cur)
c0107839:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010783d:	75 07                	jne    c0107846 <slob_alloc+0x19c>
				return 0;
c010783f:	b8 00 00 00 00       	mov    $0x0,%eax
c0107844:	eb 37                	jmp    c010787d <slob_alloc+0x1d3>

			slob_free(cur, PAGE_SIZE);
c0107846:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c010784d:	00 
c010784e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107851:	89 04 24             	mov    %eax,(%esp)
c0107854:	e8 26 00 00 00       	call   c010787f <slob_free>
			spin_lock_irqsave(&slob_lock, flags);
c0107859:	e8 8f fc ff ff       	call   c01074ed <__intr_save>
c010785e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			cur = slobfree;
c0107861:	a1 40 ea 12 c0       	mov    0xc012ea40,%eax
c0107866:	89 45 f0             	mov    %eax,-0x10(%ebp)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
c0107869:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010786c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010786f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107872:	8b 40 04             	mov    0x4(%eax),%eax
c0107875:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if (align) {
c0107878:	e9 9b fe ff ff       	jmp    c0107718 <slob_alloc+0x6e>
		}
	}
}
c010787d:	c9                   	leave  
c010787e:	c3                   	ret    

c010787f <slob_free>:

static void slob_free(void *block, int size)
{
c010787f:	f3 0f 1e fb          	endbr32 
c0107883:	55                   	push   %ebp
c0107884:	89 e5                	mov    %esp,%ebp
c0107886:	83 ec 28             	sub    $0x28,%esp
	slob_t *cur, *b = (slob_t *)block;
c0107889:	8b 45 08             	mov    0x8(%ebp),%eax
c010788c:	89 45 f0             	mov    %eax,-0x10(%ebp)
	unsigned long flags;

	if (!block)
c010788f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0107893:	0f 84 01 01 00 00    	je     c010799a <slob_free+0x11b>
		return;

	if (size)
c0107899:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010789d:	74 10                	je     c01078af <slob_free+0x30>
		b->units = SLOB_UNITS(size);
c010789f:	8b 45 0c             	mov    0xc(%ebp),%eax
c01078a2:	83 c0 07             	add    $0x7,%eax
c01078a5:	c1 e8 03             	shr    $0x3,%eax
c01078a8:	89 c2                	mov    %eax,%edx
c01078aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01078ad:	89 10                	mov    %edx,(%eax)

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
c01078af:	e8 39 fc ff ff       	call   c01074ed <__intr_save>
c01078b4:	89 45 ec             	mov    %eax,-0x14(%ebp)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
c01078b7:	a1 40 ea 12 c0       	mov    0xc012ea40,%eax
c01078bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01078bf:	eb 27                	jmp    c01078e8 <slob_free+0x69>
		if (cur >= cur->next && (b > cur || b < cur->next))
c01078c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01078c4:	8b 40 04             	mov    0x4(%eax),%eax
c01078c7:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01078ca:	72 13                	jb     c01078df <slob_free+0x60>
c01078cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01078cf:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01078d2:	77 27                	ja     c01078fb <slob_free+0x7c>
c01078d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01078d7:	8b 40 04             	mov    0x4(%eax),%eax
c01078da:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01078dd:	72 1c                	jb     c01078fb <slob_free+0x7c>
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
c01078df:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01078e2:	8b 40 04             	mov    0x4(%eax),%eax
c01078e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01078e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01078eb:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01078ee:	76 d1                	jbe    c01078c1 <slob_free+0x42>
c01078f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01078f3:	8b 40 04             	mov    0x4(%eax),%eax
c01078f6:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01078f9:	73 c6                	jae    c01078c1 <slob_free+0x42>
			break;

	if (b + b->units == cur->next) {
c01078fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01078fe:	8b 00                	mov    (%eax),%eax
c0107900:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0107907:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010790a:	01 c2                	add    %eax,%edx
c010790c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010790f:	8b 40 04             	mov    0x4(%eax),%eax
c0107912:	39 c2                	cmp    %eax,%edx
c0107914:	75 25                	jne    c010793b <slob_free+0xbc>
		b->units += cur->next->units;
c0107916:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107919:	8b 10                	mov    (%eax),%edx
c010791b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010791e:	8b 40 04             	mov    0x4(%eax),%eax
c0107921:	8b 00                	mov    (%eax),%eax
c0107923:	01 c2                	add    %eax,%edx
c0107925:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107928:	89 10                	mov    %edx,(%eax)
		b->next = cur->next->next;
c010792a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010792d:	8b 40 04             	mov    0x4(%eax),%eax
c0107930:	8b 50 04             	mov    0x4(%eax),%edx
c0107933:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107936:	89 50 04             	mov    %edx,0x4(%eax)
c0107939:	eb 0c                	jmp    c0107947 <slob_free+0xc8>
	} else
		b->next = cur->next;
c010793b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010793e:	8b 50 04             	mov    0x4(%eax),%edx
c0107941:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107944:	89 50 04             	mov    %edx,0x4(%eax)

	if (cur + cur->units == b) {
c0107947:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010794a:	8b 00                	mov    (%eax),%eax
c010794c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0107953:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107956:	01 d0                	add    %edx,%eax
c0107958:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010795b:	75 1f                	jne    c010797c <slob_free+0xfd>
		cur->units += b->units;
c010795d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107960:	8b 10                	mov    (%eax),%edx
c0107962:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107965:	8b 00                	mov    (%eax),%eax
c0107967:	01 c2                	add    %eax,%edx
c0107969:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010796c:	89 10                	mov    %edx,(%eax)
		cur->next = b->next;
c010796e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107971:	8b 50 04             	mov    0x4(%eax),%edx
c0107974:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107977:	89 50 04             	mov    %edx,0x4(%eax)
c010797a:	eb 09                	jmp    c0107985 <slob_free+0x106>
	} else
		cur->next = b;
c010797c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010797f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0107982:	89 50 04             	mov    %edx,0x4(%eax)

	slobfree = cur;
c0107985:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107988:	a3 40 ea 12 c0       	mov    %eax,0xc012ea40

	spin_unlock_irqrestore(&slob_lock, flags);
c010798d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107990:	89 04 24             	mov    %eax,(%esp)
c0107993:	e8 7f fb ff ff       	call   c0107517 <__intr_restore>
c0107998:	eb 01                	jmp    c010799b <slob_free+0x11c>
		return;
c010799a:	90                   	nop
}
c010799b:	c9                   	leave  
c010799c:	c3                   	ret    

c010799d <slob_init>:



void
slob_init(void) {
c010799d:	f3 0f 1e fb          	endbr32 
c01079a1:	55                   	push   %ebp
c01079a2:	89 e5                	mov    %esp,%ebp
c01079a4:	83 ec 18             	sub    $0x18,%esp
  cprintf("use SLOB allocator\n");
c01079a7:	c7 04 24 ae dd 10 c0 	movl   $0xc010ddae,(%esp)
c01079ae:	e8 1e 89 ff ff       	call   c01002d1 <cprintf>
}
c01079b3:	90                   	nop
c01079b4:	c9                   	leave  
c01079b5:	c3                   	ret    

c01079b6 <kmalloc_init>:

inline void 
kmalloc_init(void) {
c01079b6:	f3 0f 1e fb          	endbr32 
c01079ba:	55                   	push   %ebp
c01079bb:	89 e5                	mov    %esp,%ebp
c01079bd:	83 ec 18             	sub    $0x18,%esp
    slob_init();
c01079c0:	e8 d8 ff ff ff       	call   c010799d <slob_init>
    cprintf("kmalloc_init() succeeded!\n");
c01079c5:	c7 04 24 c2 dd 10 c0 	movl   $0xc010ddc2,(%esp)
c01079cc:	e8 00 89 ff ff       	call   c01002d1 <cprintf>
}
c01079d1:	90                   	nop
c01079d2:	c9                   	leave  
c01079d3:	c3                   	ret    

c01079d4 <slob_allocated>:

size_t
slob_allocated(void) {
c01079d4:	f3 0f 1e fb          	endbr32 
c01079d8:	55                   	push   %ebp
c01079d9:	89 e5                	mov    %esp,%ebp
  return 0;
c01079db:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01079e0:	5d                   	pop    %ebp
c01079e1:	c3                   	ret    

c01079e2 <kallocated>:

size_t
kallocated(void) {
c01079e2:	f3 0f 1e fb          	endbr32 
c01079e6:	55                   	push   %ebp
c01079e7:	89 e5                	mov    %esp,%ebp
   return slob_allocated();
c01079e9:	e8 e6 ff ff ff       	call   c01079d4 <slob_allocated>
}
c01079ee:	5d                   	pop    %ebp
c01079ef:	c3                   	ret    

c01079f0 <find_order>:

static int find_order(int size)
{
c01079f0:	f3 0f 1e fb          	endbr32 
c01079f4:	55                   	push   %ebp
c01079f5:	89 e5                	mov    %esp,%ebp
c01079f7:	83 ec 10             	sub    $0x10,%esp
	int order = 0;
c01079fa:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	for ( ; size > 4096 ; size >>=1)
c0107a01:	eb 06                	jmp    c0107a09 <find_order+0x19>
		order++;
c0107a03:	ff 45 fc             	incl   -0x4(%ebp)
	for ( ; size > 4096 ; size >>=1)
c0107a06:	d1 7d 08             	sarl   0x8(%ebp)
c0107a09:	81 7d 08 00 10 00 00 	cmpl   $0x1000,0x8(%ebp)
c0107a10:	7f f1                	jg     c0107a03 <find_order+0x13>
	return order;
c0107a12:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0107a15:	c9                   	leave  
c0107a16:	c3                   	ret    

c0107a17 <__kmalloc>:

static void *__kmalloc(size_t size, gfp_t gfp)
{
c0107a17:	f3 0f 1e fb          	endbr32 
c0107a1b:	55                   	push   %ebp
c0107a1c:	89 e5                	mov    %esp,%ebp
c0107a1e:	83 ec 28             	sub    $0x28,%esp
	slob_t *m;
	bigblock_t *bb;
	unsigned long flags;

	if (size < PAGE_SIZE - SLOB_UNIT) {
c0107a21:	81 7d 08 f7 0f 00 00 	cmpl   $0xff7,0x8(%ebp)
c0107a28:	77 3b                	ja     c0107a65 <__kmalloc+0x4e>
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
c0107a2a:	8b 45 08             	mov    0x8(%ebp),%eax
c0107a2d:	8d 50 08             	lea    0x8(%eax),%edx
c0107a30:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107a37:	00 
c0107a38:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107a3b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107a3f:	89 14 24             	mov    %edx,(%esp)
c0107a42:	e8 63 fc ff ff       	call   c01076aa <slob_alloc>
c0107a47:	89 45 ec             	mov    %eax,-0x14(%ebp)
		return m ? (void *)(m + 1) : 0;
c0107a4a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0107a4e:	74 0b                	je     c0107a5b <__kmalloc+0x44>
c0107a50:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107a53:	83 c0 08             	add    $0x8,%eax
c0107a56:	e9 b0 00 00 00       	jmp    c0107b0b <__kmalloc+0xf4>
c0107a5b:	b8 00 00 00 00       	mov    $0x0,%eax
c0107a60:	e9 a6 00 00 00       	jmp    c0107b0b <__kmalloc+0xf4>
	}

	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
c0107a65:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107a6c:	00 
c0107a6d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107a70:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107a74:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
c0107a7b:	e8 2a fc ff ff       	call   c01076aa <slob_alloc>
c0107a80:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (!bb)
c0107a83:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107a87:	75 07                	jne    c0107a90 <__kmalloc+0x79>
		return 0;
c0107a89:	b8 00 00 00 00       	mov    $0x0,%eax
c0107a8e:	eb 7b                	jmp    c0107b0b <__kmalloc+0xf4>

	bb->order = find_order(size);
c0107a90:	8b 45 08             	mov    0x8(%ebp),%eax
c0107a93:	89 04 24             	mov    %eax,(%esp)
c0107a96:	e8 55 ff ff ff       	call   c01079f0 <find_order>
c0107a9b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107a9e:	89 02                	mov    %eax,(%edx)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
c0107aa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107aa3:	8b 00                	mov    (%eax),%eax
c0107aa5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107aa9:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107aac:	89 04 24             	mov    %eax,(%esp)
c0107aaf:	e8 84 fb ff ff       	call   c0107638 <__slob_get_free_pages>
c0107ab4:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107ab7:	89 42 04             	mov    %eax,0x4(%edx)

	if (bb->pages) {
c0107aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107abd:	8b 40 04             	mov    0x4(%eax),%eax
c0107ac0:	85 c0                	test   %eax,%eax
c0107ac2:	74 2f                	je     c0107af3 <__kmalloc+0xdc>
		spin_lock_irqsave(&block_lock, flags);
c0107ac4:	e8 24 fa ff ff       	call   c01074ed <__intr_save>
c0107ac9:	89 45 f0             	mov    %eax,-0x10(%ebp)
		bb->next = bigblocks;
c0107acc:	8b 15 1c 20 1b c0    	mov    0xc01b201c,%edx
c0107ad2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107ad5:	89 50 08             	mov    %edx,0x8(%eax)
		bigblocks = bb;
c0107ad8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107adb:	a3 1c 20 1b c0       	mov    %eax,0xc01b201c
		spin_unlock_irqrestore(&block_lock, flags);
c0107ae0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107ae3:	89 04 24             	mov    %eax,(%esp)
c0107ae6:	e8 2c fa ff ff       	call   c0107517 <__intr_restore>
		return bb->pages;
c0107aeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107aee:	8b 40 04             	mov    0x4(%eax),%eax
c0107af1:	eb 18                	jmp    c0107b0b <__kmalloc+0xf4>
	}

	slob_free(bb, sizeof(bigblock_t));
c0107af3:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
c0107afa:	00 
c0107afb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107afe:	89 04 24             	mov    %eax,(%esp)
c0107b01:	e8 79 fd ff ff       	call   c010787f <slob_free>
	return 0;
c0107b06:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107b0b:	c9                   	leave  
c0107b0c:	c3                   	ret    

c0107b0d <kmalloc>:

void *
kmalloc(size_t size)
{
c0107b0d:	f3 0f 1e fb          	endbr32 
c0107b11:	55                   	push   %ebp
c0107b12:	89 e5                	mov    %esp,%ebp
c0107b14:	83 ec 18             	sub    $0x18,%esp
  return __kmalloc(size, 0);
c0107b17:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0107b1e:	00 
c0107b1f:	8b 45 08             	mov    0x8(%ebp),%eax
c0107b22:	89 04 24             	mov    %eax,(%esp)
c0107b25:	e8 ed fe ff ff       	call   c0107a17 <__kmalloc>
}
c0107b2a:	c9                   	leave  
c0107b2b:	c3                   	ret    

c0107b2c <kfree>:


void kfree(void *block)
{
c0107b2c:	f3 0f 1e fb          	endbr32 
c0107b30:	55                   	push   %ebp
c0107b31:	89 e5                	mov    %esp,%ebp
c0107b33:	83 ec 28             	sub    $0x28,%esp
	bigblock_t *bb, **last = &bigblocks;
c0107b36:	c7 45 f0 1c 20 1b c0 	movl   $0xc01b201c,-0x10(%ebp)
	unsigned long flags;

	if (!block)
c0107b3d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0107b41:	0f 84 a3 00 00 00    	je     c0107bea <kfree+0xbe>
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
c0107b47:	8b 45 08             	mov    0x8(%ebp),%eax
c0107b4a:	25 ff 0f 00 00       	and    $0xfff,%eax
c0107b4f:	85 c0                	test   %eax,%eax
c0107b51:	75 7f                	jne    c0107bd2 <kfree+0xa6>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
c0107b53:	e8 95 f9 ff ff       	call   c01074ed <__intr_save>
c0107b58:	89 45 ec             	mov    %eax,-0x14(%ebp)
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
c0107b5b:	a1 1c 20 1b c0       	mov    0xc01b201c,%eax
c0107b60:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107b63:	eb 5c                	jmp    c0107bc1 <kfree+0x95>
			if (bb->pages == block) {
c0107b65:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107b68:	8b 40 04             	mov    0x4(%eax),%eax
c0107b6b:	39 45 08             	cmp    %eax,0x8(%ebp)
c0107b6e:	75 3f                	jne    c0107baf <kfree+0x83>
				*last = bb->next;
c0107b70:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107b73:	8b 50 08             	mov    0x8(%eax),%edx
c0107b76:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107b79:	89 10                	mov    %edx,(%eax)
				spin_unlock_irqrestore(&block_lock, flags);
c0107b7b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107b7e:	89 04 24             	mov    %eax,(%esp)
c0107b81:	e8 91 f9 ff ff       	call   c0107517 <__intr_restore>
				__slob_free_pages((unsigned long)block, bb->order);
c0107b86:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107b89:	8b 10                	mov    (%eax),%edx
c0107b8b:	8b 45 08             	mov    0x8(%ebp),%eax
c0107b8e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107b92:	89 04 24             	mov    %eax,(%esp)
c0107b95:	e8 db fa ff ff       	call   c0107675 <__slob_free_pages>
				slob_free(bb, sizeof(bigblock_t));
c0107b9a:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
c0107ba1:	00 
c0107ba2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107ba5:	89 04 24             	mov    %eax,(%esp)
c0107ba8:	e8 d2 fc ff ff       	call   c010787f <slob_free>
				return;
c0107bad:	eb 3c                	jmp    c0107beb <kfree+0xbf>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
c0107baf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107bb2:	83 c0 08             	add    $0x8,%eax
c0107bb5:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107bb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107bbb:	8b 40 08             	mov    0x8(%eax),%eax
c0107bbe:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107bc1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107bc5:	75 9e                	jne    c0107b65 <kfree+0x39>
			}
		}
		spin_unlock_irqrestore(&block_lock, flags);
c0107bc7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107bca:	89 04 24             	mov    %eax,(%esp)
c0107bcd:	e8 45 f9 ff ff       	call   c0107517 <__intr_restore>
	}

	slob_free((slob_t *)block - 1, 0);
c0107bd2:	8b 45 08             	mov    0x8(%ebp),%eax
c0107bd5:	83 e8 08             	sub    $0x8,%eax
c0107bd8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0107bdf:	00 
c0107be0:	89 04 24             	mov    %eax,(%esp)
c0107be3:	e8 97 fc ff ff       	call   c010787f <slob_free>
	return;
c0107be8:	eb 01                	jmp    c0107beb <kfree+0xbf>
		return;
c0107bea:	90                   	nop
}
c0107beb:	c9                   	leave  
c0107bec:	c3                   	ret    

c0107bed <ksize>:


unsigned int ksize(const void *block)
{
c0107bed:	f3 0f 1e fb          	endbr32 
c0107bf1:	55                   	push   %ebp
c0107bf2:	89 e5                	mov    %esp,%ebp
c0107bf4:	83 ec 28             	sub    $0x28,%esp
	bigblock_t *bb;
	unsigned long flags;

	if (!block)
c0107bf7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0107bfb:	75 07                	jne    c0107c04 <ksize+0x17>
		return 0;
c0107bfd:	b8 00 00 00 00       	mov    $0x0,%eax
c0107c02:	eb 6b                	jmp    c0107c6f <ksize+0x82>

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
c0107c04:	8b 45 08             	mov    0x8(%ebp),%eax
c0107c07:	25 ff 0f 00 00       	and    $0xfff,%eax
c0107c0c:	85 c0                	test   %eax,%eax
c0107c0e:	75 54                	jne    c0107c64 <ksize+0x77>
		spin_lock_irqsave(&block_lock, flags);
c0107c10:	e8 d8 f8 ff ff       	call   c01074ed <__intr_save>
c0107c15:	89 45 f0             	mov    %eax,-0x10(%ebp)
		for (bb = bigblocks; bb; bb = bb->next)
c0107c18:	a1 1c 20 1b c0       	mov    0xc01b201c,%eax
c0107c1d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107c20:	eb 31                	jmp    c0107c53 <ksize+0x66>
			if (bb->pages == block) {
c0107c22:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107c25:	8b 40 04             	mov    0x4(%eax),%eax
c0107c28:	39 45 08             	cmp    %eax,0x8(%ebp)
c0107c2b:	75 1d                	jne    c0107c4a <ksize+0x5d>
				spin_unlock_irqrestore(&slob_lock, flags);
c0107c2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107c30:	89 04 24             	mov    %eax,(%esp)
c0107c33:	e8 df f8 ff ff       	call   c0107517 <__intr_restore>
				return PAGE_SIZE << bb->order;
c0107c38:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107c3b:	8b 00                	mov    (%eax),%eax
c0107c3d:	ba 00 10 00 00       	mov    $0x1000,%edx
c0107c42:	88 c1                	mov    %al,%cl
c0107c44:	d3 e2                	shl    %cl,%edx
c0107c46:	89 d0                	mov    %edx,%eax
c0107c48:	eb 25                	jmp    c0107c6f <ksize+0x82>
		for (bb = bigblocks; bb; bb = bb->next)
c0107c4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107c4d:	8b 40 08             	mov    0x8(%eax),%eax
c0107c50:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107c53:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107c57:	75 c9                	jne    c0107c22 <ksize+0x35>
			}
		spin_unlock_irqrestore(&block_lock, flags);
c0107c59:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107c5c:	89 04 24             	mov    %eax,(%esp)
c0107c5f:	e8 b3 f8 ff ff       	call   c0107517 <__intr_restore>
	}

	return ((slob_t *)block - 1)->units * SLOB_UNIT;
c0107c64:	8b 45 08             	mov    0x8(%ebp),%eax
c0107c67:	83 e8 08             	sub    $0x8,%eax
c0107c6a:	8b 00                	mov    (%eax),%eax
c0107c6c:	c1 e0 03             	shl    $0x3,%eax
}
c0107c6f:	c9                   	leave  
c0107c70:	c3                   	ret    

c0107c71 <_fifo_init_mm>:
 * (2) _fifo_init_mm: init pra_list_head and let  mm->sm_priv point to the addr of pra_list_head.
 *              Now, From the memory control struct mm_struct, we can access FIFO PRA
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{
c0107c71:	f3 0f 1e fb          	endbr32 
c0107c75:	55                   	push   %ebp
c0107c76:	89 e5                	mov    %esp,%ebp
c0107c78:	83 ec 10             	sub    $0x10,%esp
c0107c7b:	c7 45 fc 44 41 1b c0 	movl   $0xc01b4144,-0x4(%ebp)
    elm->prev = elm->next = elm;
c0107c82:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107c85:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0107c88:	89 50 04             	mov    %edx,0x4(%eax)
c0107c8b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107c8e:	8b 50 04             	mov    0x4(%eax),%edx
c0107c91:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107c94:	89 10                	mov    %edx,(%eax)
}
c0107c96:	90                   	nop
    list_init(&pra_list_head);
    mm->sm_priv = &pra_list_head;
c0107c97:	8b 45 08             	mov    0x8(%ebp),%eax
c0107c9a:	c7 40 14 44 41 1b c0 	movl   $0xc01b4144,0x14(%eax)
    //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
    return 0;
c0107ca1:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107ca6:	c9                   	leave  
c0107ca7:	c3                   	ret    

c0107ca8 <_fifo_map_swappable>:
/*
 * (3)_fifo_map_swappable: According FIFO PRA, we should link the most recent arrival page at the back of pra_list_head qeueue
 */
static int
_fifo_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c0107ca8:	f3 0f 1e fb          	endbr32 
c0107cac:	55                   	push   %ebp
c0107cad:	89 e5                	mov    %esp,%ebp
c0107caf:	83 ec 48             	sub    $0x48,%esp
    list_entry_t *head = (list_entry_t *)mm->sm_priv;
c0107cb2:	8b 45 08             	mov    0x8(%ebp),%eax
c0107cb5:	8b 40 14             	mov    0x14(%eax),%eax
c0107cb8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    list_entry_t *entry = &(page->pra_page_link);
c0107cbb:	8b 45 10             	mov    0x10(%ebp),%eax
c0107cbe:	83 c0 14             	add    $0x14,%eax
c0107cc1:	89 45 f0             	mov    %eax,-0x10(%ebp)

    assert(entry != NULL && head != NULL);
c0107cc4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0107cc8:	74 06                	je     c0107cd0 <_fifo_map_swappable+0x28>
c0107cca:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107cce:	75 24                	jne    c0107cf4 <_fifo_map_swappable+0x4c>
c0107cd0:	c7 44 24 0c e0 dd 10 	movl   $0xc010dde0,0xc(%esp)
c0107cd7:	c0 
c0107cd8:	c7 44 24 08 fe dd 10 	movl   $0xc010ddfe,0x8(%esp)
c0107cdf:	c0 
c0107ce0:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
c0107ce7:	00 
c0107ce8:	c7 04 24 13 de 10 c0 	movl   $0xc010de13,(%esp)
c0107cef:	e8 49 87 ff ff       	call   c010043d <__panic>
c0107cf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107cf7:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107cfa:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107cfd:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0107d00:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107d03:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0107d06:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107d09:	89 45 e0             	mov    %eax,-0x20(%ebp)
    __list_add(elm, listelm, listelm->next);
c0107d0c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107d0f:	8b 40 04             	mov    0x4(%eax),%eax
c0107d12:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0107d15:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0107d18:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107d1b:	89 55 d8             	mov    %edx,-0x28(%ebp)
c0107d1e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    prev->next = next->prev = elm;
c0107d21:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0107d24:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107d27:	89 10                	mov    %edx,(%eax)
c0107d29:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0107d2c:	8b 10                	mov    (%eax),%edx
c0107d2e:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0107d31:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0107d34:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107d37:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0107d3a:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0107d3d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107d40:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0107d43:	89 10                	mov    %edx,(%eax)
}
c0107d45:	90                   	nop
}
c0107d46:	90                   	nop
}
c0107d47:	90                   	nop
    //record the page access situlation
    /*LAB3 EXERCISE 2: YOUR CODE*/
    //(1)link the most recent arrival page at the back of the pra_list_head qeueue.
    list_add(head, entry);
    return 0;
c0107d48:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107d4d:	c9                   	leave  
c0107d4e:	c3                   	ret    

c0107d4f <_fifo_swap_out_victim>:
 *  (4)_fifo_swap_out_victim: According FIFO PRA, we should unlink the  earliest arrival page in front of pra_list_head qeueue,
 *                            then assign the value of *ptr_page to the addr of this page.
 */
static int
_fifo_swap_out_victim(struct mm_struct *mm, struct Page **ptr_page, int in_tick)
{
c0107d4f:	f3 0f 1e fb          	endbr32 
c0107d53:	55                   	push   %ebp
c0107d54:	89 e5                	mov    %esp,%ebp
c0107d56:	83 ec 38             	sub    $0x38,%esp
    list_entry_t *head = (list_entry_t *)mm->sm_priv;
c0107d59:	8b 45 08             	mov    0x8(%ebp),%eax
c0107d5c:	8b 40 14             	mov    0x14(%eax),%eax
c0107d5f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(head != NULL);
c0107d62:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107d66:	75 24                	jne    c0107d8c <_fifo_swap_out_victim+0x3d>
c0107d68:	c7 44 24 0c 27 de 10 	movl   $0xc010de27,0xc(%esp)
c0107d6f:	c0 
c0107d70:	c7 44 24 08 fe dd 10 	movl   $0xc010ddfe,0x8(%esp)
c0107d77:	c0 
c0107d78:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
c0107d7f:	00 
c0107d80:	c7 04 24 13 de 10 c0 	movl   $0xc010de13,(%esp)
c0107d87:	e8 b1 86 ff ff       	call   c010043d <__panic>
    assert(in_tick == 0);
c0107d8c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0107d90:	74 24                	je     c0107db6 <_fifo_swap_out_victim+0x67>
c0107d92:	c7 44 24 0c 34 de 10 	movl   $0xc010de34,0xc(%esp)
c0107d99:	c0 
c0107d9a:	c7 44 24 08 fe dd 10 	movl   $0xc010ddfe,0x8(%esp)
c0107da1:	c0 
c0107da2:	c7 44 24 04 42 00 00 	movl   $0x42,0x4(%esp)
c0107da9:	00 
c0107daa:	c7 04 24 13 de 10 c0 	movl   $0xc010de13,(%esp)
c0107db1:	e8 87 86 ff ff       	call   c010043d <__panic>
    /* Select the victim */
    /*LAB3 EXERCISE 2: YOUR CODE*/
    //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
    //(2)  assign the value of *ptr_page to the addr of this page
    /* Select the tail */
    list_entry_t *le = head->prev;
c0107db6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107db9:	8b 00                	mov    (%eax),%eax
c0107dbb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(head != le);
c0107dbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107dc1:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0107dc4:	75 24                	jne    c0107dea <_fifo_swap_out_victim+0x9b>
c0107dc6:	c7 44 24 0c 41 de 10 	movl   $0xc010de41,0xc(%esp)
c0107dcd:	c0 
c0107dce:	c7 44 24 08 fe dd 10 	movl   $0xc010ddfe,0x8(%esp)
c0107dd5:	c0 
c0107dd6:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
c0107ddd:	00 
c0107dde:	c7 04 24 13 de 10 c0 	movl   $0xc010de13,(%esp)
c0107de5:	e8 53 86 ff ff       	call   c010043d <__panic>
    struct Page *p = le2page(le, pra_page_link);
c0107dea:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107ded:	83 e8 14             	sub    $0x14,%eax
c0107df0:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107df3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107df6:	89 45 e8             	mov    %eax,-0x18(%ebp)
    __list_del(listelm->prev, listelm->next);
c0107df9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107dfc:	8b 40 04             	mov    0x4(%eax),%eax
c0107dff:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0107e02:	8b 12                	mov    (%edx),%edx
c0107e04:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0107e07:	89 45 e0             	mov    %eax,-0x20(%ebp)
    prev->next = next;
c0107e0a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107e0d:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0107e10:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0107e13:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107e16:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107e19:	89 10                	mov    %edx,(%eax)
}
c0107e1b:	90                   	nop
}
c0107e1c:	90                   	nop
    list_del(le);
    assert(p != NULL);
c0107e1d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0107e21:	75 24                	jne    c0107e47 <_fifo_swap_out_victim+0xf8>
c0107e23:	c7 44 24 0c 4c de 10 	movl   $0xc010de4c,0xc(%esp)
c0107e2a:	c0 
c0107e2b:	c7 44 24 08 fe dd 10 	movl   $0xc010ddfe,0x8(%esp)
c0107e32:	c0 
c0107e33:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
c0107e3a:	00 
c0107e3b:	c7 04 24 13 de 10 c0 	movl   $0xc010de13,(%esp)
c0107e42:	e8 f6 85 ff ff       	call   c010043d <__panic>
    *ptr_page = p;
c0107e47:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107e4a:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107e4d:	89 10                	mov    %edx,(%eax)
    return 0;
c0107e4f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107e54:	c9                   	leave  
c0107e55:	c3                   	ret    

c0107e56 <_fifo_check_swap>:

static int
_fifo_check_swap(void)
{
c0107e56:	f3 0f 1e fb          	endbr32 
c0107e5a:	55                   	push   %ebp
c0107e5b:	89 e5                	mov    %esp,%ebp
c0107e5d:	83 ec 18             	sub    $0x18,%esp
    cprintf("write Virt Page c in fifo_check_swap\n");
c0107e60:	c7 04 24 58 de 10 c0 	movl   $0xc010de58,(%esp)
c0107e67:	e8 65 84 ff ff       	call   c01002d1 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c0107e6c:	b8 00 30 00 00       	mov    $0x3000,%eax
c0107e71:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num == 4);
c0107e74:	a1 0c 20 1b c0       	mov    0xc01b200c,%eax
c0107e79:	83 f8 04             	cmp    $0x4,%eax
c0107e7c:	74 24                	je     c0107ea2 <_fifo_check_swap+0x4c>
c0107e7e:	c7 44 24 0c 7e de 10 	movl   $0xc010de7e,0xc(%esp)
c0107e85:	c0 
c0107e86:	c7 44 24 08 fe dd 10 	movl   $0xc010ddfe,0x8(%esp)
c0107e8d:	c0 
c0107e8e:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
c0107e95:	00 
c0107e96:	c7 04 24 13 de 10 c0 	movl   $0xc010de13,(%esp)
c0107e9d:	e8 9b 85 ff ff       	call   c010043d <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0107ea2:	c7 04 24 90 de 10 c0 	movl   $0xc010de90,(%esp)
c0107ea9:	e8 23 84 ff ff       	call   c01002d1 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c0107eae:	b8 00 10 00 00       	mov    $0x1000,%eax
c0107eb3:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num == 4);
c0107eb6:	a1 0c 20 1b c0       	mov    0xc01b200c,%eax
c0107ebb:	83 f8 04             	cmp    $0x4,%eax
c0107ebe:	74 24                	je     c0107ee4 <_fifo_check_swap+0x8e>
c0107ec0:	c7 44 24 0c 7e de 10 	movl   $0xc010de7e,0xc(%esp)
c0107ec7:	c0 
c0107ec8:	c7 44 24 08 fe dd 10 	movl   $0xc010ddfe,0x8(%esp)
c0107ecf:	c0 
c0107ed0:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
c0107ed7:	00 
c0107ed8:	c7 04 24 13 de 10 c0 	movl   $0xc010de13,(%esp)
c0107edf:	e8 59 85 ff ff       	call   c010043d <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c0107ee4:	c7 04 24 b8 de 10 c0 	movl   $0xc010deb8,(%esp)
c0107eeb:	e8 e1 83 ff ff       	call   c01002d1 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c0107ef0:	b8 00 40 00 00       	mov    $0x4000,%eax
c0107ef5:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num == 4);
c0107ef8:	a1 0c 20 1b c0       	mov    0xc01b200c,%eax
c0107efd:	83 f8 04             	cmp    $0x4,%eax
c0107f00:	74 24                	je     c0107f26 <_fifo_check_swap+0xd0>
c0107f02:	c7 44 24 0c 7e de 10 	movl   $0xc010de7e,0xc(%esp)
c0107f09:	c0 
c0107f0a:	c7 44 24 08 fe dd 10 	movl   $0xc010ddfe,0x8(%esp)
c0107f11:	c0 
c0107f12:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
c0107f19:	00 
c0107f1a:	c7 04 24 13 de 10 c0 	movl   $0xc010de13,(%esp)
c0107f21:	e8 17 85 ff ff       	call   c010043d <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0107f26:	c7 04 24 e0 de 10 c0 	movl   $0xc010dee0,(%esp)
c0107f2d:	e8 9f 83 ff ff       	call   c01002d1 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0107f32:	b8 00 20 00 00       	mov    $0x2000,%eax
c0107f37:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num == 4);
c0107f3a:	a1 0c 20 1b c0       	mov    0xc01b200c,%eax
c0107f3f:	83 f8 04             	cmp    $0x4,%eax
c0107f42:	74 24                	je     c0107f68 <_fifo_check_swap+0x112>
c0107f44:	c7 44 24 0c 7e de 10 	movl   $0xc010de7e,0xc(%esp)
c0107f4b:	c0 
c0107f4c:	c7 44 24 08 fe dd 10 	movl   $0xc010ddfe,0x8(%esp)
c0107f53:	c0 
c0107f54:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
c0107f5b:	00 
c0107f5c:	c7 04 24 13 de 10 c0 	movl   $0xc010de13,(%esp)
c0107f63:	e8 d5 84 ff ff       	call   c010043d <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c0107f68:	c7 04 24 08 df 10 c0 	movl   $0xc010df08,(%esp)
c0107f6f:	e8 5d 83 ff ff       	call   c01002d1 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c0107f74:	b8 00 50 00 00       	mov    $0x5000,%eax
c0107f79:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num == 5);
c0107f7c:	a1 0c 20 1b c0       	mov    0xc01b200c,%eax
c0107f81:	83 f8 05             	cmp    $0x5,%eax
c0107f84:	74 24                	je     c0107faa <_fifo_check_swap+0x154>
c0107f86:	c7 44 24 0c 2e df 10 	movl   $0xc010df2e,0xc(%esp)
c0107f8d:	c0 
c0107f8e:	c7 44 24 08 fe dd 10 	movl   $0xc010ddfe,0x8(%esp)
c0107f95:	c0 
c0107f96:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
c0107f9d:	00 
c0107f9e:	c7 04 24 13 de 10 c0 	movl   $0xc010de13,(%esp)
c0107fa5:	e8 93 84 ff ff       	call   c010043d <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0107faa:	c7 04 24 e0 de 10 c0 	movl   $0xc010dee0,(%esp)
c0107fb1:	e8 1b 83 ff ff       	call   c01002d1 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0107fb6:	b8 00 20 00 00       	mov    $0x2000,%eax
c0107fbb:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num == 5);
c0107fbe:	a1 0c 20 1b c0       	mov    0xc01b200c,%eax
c0107fc3:	83 f8 05             	cmp    $0x5,%eax
c0107fc6:	74 24                	je     c0107fec <_fifo_check_swap+0x196>
c0107fc8:	c7 44 24 0c 2e df 10 	movl   $0xc010df2e,0xc(%esp)
c0107fcf:	c0 
c0107fd0:	c7 44 24 08 fe dd 10 	movl   $0xc010ddfe,0x8(%esp)
c0107fd7:	c0 
c0107fd8:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c0107fdf:	00 
c0107fe0:	c7 04 24 13 de 10 c0 	movl   $0xc010de13,(%esp)
c0107fe7:	e8 51 84 ff ff       	call   c010043d <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0107fec:	c7 04 24 90 de 10 c0 	movl   $0xc010de90,(%esp)
c0107ff3:	e8 d9 82 ff ff       	call   c01002d1 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c0107ff8:	b8 00 10 00 00       	mov    $0x1000,%eax
c0107ffd:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num == 6);
c0108000:	a1 0c 20 1b c0       	mov    0xc01b200c,%eax
c0108005:	83 f8 06             	cmp    $0x6,%eax
c0108008:	74 24                	je     c010802e <_fifo_check_swap+0x1d8>
c010800a:	c7 44 24 0c 3f df 10 	movl   $0xc010df3f,0xc(%esp)
c0108011:	c0 
c0108012:	c7 44 24 08 fe dd 10 	movl   $0xc010ddfe,0x8(%esp)
c0108019:	c0 
c010801a:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
c0108021:	00 
c0108022:	c7 04 24 13 de 10 c0 	movl   $0xc010de13,(%esp)
c0108029:	e8 0f 84 ff ff       	call   c010043d <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c010802e:	c7 04 24 e0 de 10 c0 	movl   $0xc010dee0,(%esp)
c0108035:	e8 97 82 ff ff       	call   c01002d1 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c010803a:	b8 00 20 00 00       	mov    $0x2000,%eax
c010803f:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num == 7);
c0108042:	a1 0c 20 1b c0       	mov    0xc01b200c,%eax
c0108047:	83 f8 07             	cmp    $0x7,%eax
c010804a:	74 24                	je     c0108070 <_fifo_check_swap+0x21a>
c010804c:	c7 44 24 0c 50 df 10 	movl   $0xc010df50,0xc(%esp)
c0108053:	c0 
c0108054:	c7 44 24 08 fe dd 10 	movl   $0xc010ddfe,0x8(%esp)
c010805b:	c0 
c010805c:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
c0108063:	00 
c0108064:	c7 04 24 13 de 10 c0 	movl   $0xc010de13,(%esp)
c010806b:	e8 cd 83 ff ff       	call   c010043d <__panic>
    cprintf("write Virt Page c in fifo_check_swap\n");
c0108070:	c7 04 24 58 de 10 c0 	movl   $0xc010de58,(%esp)
c0108077:	e8 55 82 ff ff       	call   c01002d1 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c010807c:	b8 00 30 00 00       	mov    $0x3000,%eax
c0108081:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num == 8);
c0108084:	a1 0c 20 1b c0       	mov    0xc01b200c,%eax
c0108089:	83 f8 08             	cmp    $0x8,%eax
c010808c:	74 24                	je     c01080b2 <_fifo_check_swap+0x25c>
c010808e:	c7 44 24 0c 61 df 10 	movl   $0xc010df61,0xc(%esp)
c0108095:	c0 
c0108096:	c7 44 24 08 fe dd 10 	movl   $0xc010ddfe,0x8(%esp)
c010809d:	c0 
c010809e:	c7 44 24 04 6e 00 00 	movl   $0x6e,0x4(%esp)
c01080a5:	00 
c01080a6:	c7 04 24 13 de 10 c0 	movl   $0xc010de13,(%esp)
c01080ad:	e8 8b 83 ff ff       	call   c010043d <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c01080b2:	c7 04 24 b8 de 10 c0 	movl   $0xc010deb8,(%esp)
c01080b9:	e8 13 82 ff ff       	call   c01002d1 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c01080be:	b8 00 40 00 00       	mov    $0x4000,%eax
c01080c3:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num == 9);
c01080c6:	a1 0c 20 1b c0       	mov    0xc01b200c,%eax
c01080cb:	83 f8 09             	cmp    $0x9,%eax
c01080ce:	74 24                	je     c01080f4 <_fifo_check_swap+0x29e>
c01080d0:	c7 44 24 0c 72 df 10 	movl   $0xc010df72,0xc(%esp)
c01080d7:	c0 
c01080d8:	c7 44 24 08 fe dd 10 	movl   $0xc010ddfe,0x8(%esp)
c01080df:	c0 
c01080e0:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
c01080e7:	00 
c01080e8:	c7 04 24 13 de 10 c0 	movl   $0xc010de13,(%esp)
c01080ef:	e8 49 83 ff ff       	call   c010043d <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c01080f4:	c7 04 24 08 df 10 c0 	movl   $0xc010df08,(%esp)
c01080fb:	e8 d1 81 ff ff       	call   c01002d1 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c0108100:	b8 00 50 00 00       	mov    $0x5000,%eax
c0108105:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num == 10);
c0108108:	a1 0c 20 1b c0       	mov    0xc01b200c,%eax
c010810d:	83 f8 0a             	cmp    $0xa,%eax
c0108110:	74 24                	je     c0108136 <_fifo_check_swap+0x2e0>
c0108112:	c7 44 24 0c 83 df 10 	movl   $0xc010df83,0xc(%esp)
c0108119:	c0 
c010811a:	c7 44 24 08 fe dd 10 	movl   $0xc010ddfe,0x8(%esp)
c0108121:	c0 
c0108122:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
c0108129:	00 
c010812a:	c7 04 24 13 de 10 c0 	movl   $0xc010de13,(%esp)
c0108131:	e8 07 83 ff ff       	call   c010043d <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0108136:	c7 04 24 90 de 10 c0 	movl   $0xc010de90,(%esp)
c010813d:	e8 8f 81 ff ff       	call   c01002d1 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
c0108142:	b8 00 10 00 00       	mov    $0x1000,%eax
c0108147:	0f b6 00             	movzbl (%eax),%eax
c010814a:	3c 0a                	cmp    $0xa,%al
c010814c:	74 24                	je     c0108172 <_fifo_check_swap+0x31c>
c010814e:	c7 44 24 0c 98 df 10 	movl   $0xc010df98,0xc(%esp)
c0108155:	c0 
c0108156:	c7 44 24 08 fe dd 10 	movl   $0xc010ddfe,0x8(%esp)
c010815d:	c0 
c010815e:	c7 44 24 04 76 00 00 	movl   $0x76,0x4(%esp)
c0108165:	00 
c0108166:	c7 04 24 13 de 10 c0 	movl   $0xc010de13,(%esp)
c010816d:	e8 cb 82 ff ff       	call   c010043d <__panic>
    *(unsigned char *)0x1000 = 0x0a;
c0108172:	b8 00 10 00 00       	mov    $0x1000,%eax
c0108177:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num == 11);
c010817a:	a1 0c 20 1b c0       	mov    0xc01b200c,%eax
c010817f:	83 f8 0b             	cmp    $0xb,%eax
c0108182:	74 24                	je     c01081a8 <_fifo_check_swap+0x352>
c0108184:	c7 44 24 0c b9 df 10 	movl   $0xc010dfb9,0xc(%esp)
c010818b:	c0 
c010818c:	c7 44 24 08 fe dd 10 	movl   $0xc010ddfe,0x8(%esp)
c0108193:	c0 
c0108194:	c7 44 24 04 78 00 00 	movl   $0x78,0x4(%esp)
c010819b:	00 
c010819c:	c7 04 24 13 de 10 c0 	movl   $0xc010de13,(%esp)
c01081a3:	e8 95 82 ff ff       	call   c010043d <__panic>
    return 0;
c01081a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01081ad:	c9                   	leave  
c01081ae:	c3                   	ret    

c01081af <_fifo_init>:

static int
_fifo_init(void)
{
c01081af:	f3 0f 1e fb          	endbr32 
c01081b3:	55                   	push   %ebp
c01081b4:	89 e5                	mov    %esp,%ebp
    return 0;
c01081b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01081bb:	5d                   	pop    %ebp
c01081bc:	c3                   	ret    

c01081bd <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c01081bd:	f3 0f 1e fb          	endbr32 
c01081c1:	55                   	push   %ebp
c01081c2:	89 e5                	mov    %esp,%ebp
    return 0;
c01081c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01081c9:	5d                   	pop    %ebp
c01081ca:	c3                   	ret    

c01081cb <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{
c01081cb:	f3 0f 1e fb          	endbr32 
c01081cf:	55                   	push   %ebp
c01081d0:	89 e5                	mov    %esp,%ebp
    return 0;
c01081d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01081d7:	5d                   	pop    %ebp
c01081d8:	c3                   	ret    

c01081d9 <page2ppn>:
page2ppn(struct Page *page) {
c01081d9:	55                   	push   %ebp
c01081da:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01081dc:	a1 60 40 1b c0       	mov    0xc01b4060,%eax
c01081e1:	8b 55 08             	mov    0x8(%ebp),%edx
c01081e4:	29 c2                	sub    %eax,%edx
c01081e6:	89 d0                	mov    %edx,%eax
c01081e8:	c1 f8 05             	sar    $0x5,%eax
}
c01081eb:	5d                   	pop    %ebp
c01081ec:	c3                   	ret    

c01081ed <page2pa>:
page2pa(struct Page *page) {
c01081ed:	55                   	push   %ebp
c01081ee:	89 e5                	mov    %esp,%ebp
c01081f0:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01081f3:	8b 45 08             	mov    0x8(%ebp),%eax
c01081f6:	89 04 24             	mov    %eax,(%esp)
c01081f9:	e8 db ff ff ff       	call   c01081d9 <page2ppn>
c01081fe:	c1 e0 0c             	shl    $0xc,%eax
}
c0108201:	c9                   	leave  
c0108202:	c3                   	ret    

c0108203 <page_ref>:
page_ref(struct Page *page) {
c0108203:	55                   	push   %ebp
c0108204:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0108206:	8b 45 08             	mov    0x8(%ebp),%eax
c0108209:	8b 00                	mov    (%eax),%eax
}
c010820b:	5d                   	pop    %ebp
c010820c:	c3                   	ret    

c010820d <set_page_ref>:
set_page_ref(struct Page *page, int val) {
c010820d:	55                   	push   %ebp
c010820e:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0108210:	8b 45 08             	mov    0x8(%ebp),%eax
c0108213:	8b 55 0c             	mov    0xc(%ebp),%edx
c0108216:	89 10                	mov    %edx,(%eax)
}
c0108218:	90                   	nop
c0108219:	5d                   	pop    %ebp
c010821a:	c3                   	ret    

c010821b <default_init>:
#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void)
{
c010821b:	f3 0f 1e fb          	endbr32 
c010821f:	55                   	push   %ebp
c0108220:	89 e5                	mov    %esp,%ebp
c0108222:	83 ec 10             	sub    $0x10,%esp
c0108225:	c7 45 fc 4c 41 1b c0 	movl   $0xc01b414c,-0x4(%ebp)
    elm->prev = elm->next = elm;
c010822c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010822f:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0108232:	89 50 04             	mov    %edx,0x4(%eax)
c0108235:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108238:	8b 50 04             	mov    0x4(%eax),%edx
c010823b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010823e:	89 10                	mov    %edx,(%eax)
}
c0108240:	90                   	nop
    list_init(&free_list);
    nr_free = 0;
c0108241:	c7 05 54 41 1b c0 00 	movl   $0x0,0xc01b4154
c0108248:	00 00 00 
}
c010824b:	90                   	nop
c010824c:	c9                   	leave  
c010824d:	c3                   	ret    

c010824e <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n)
{
c010824e:	f3 0f 1e fb          	endbr32 
c0108252:	55                   	push   %ebp
c0108253:	89 e5                	mov    %esp,%ebp
c0108255:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
c0108258:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010825c:	75 24                	jne    c0108282 <default_init_memmap+0x34>
c010825e:	c7 44 24 0c e0 df 10 	movl   $0xc010dfe0,0xc(%esp)
c0108265:	c0 
c0108266:	c7 44 24 08 e6 df 10 	movl   $0xc010dfe6,0x8(%esp)
c010826d:	c0 
c010826e:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
c0108275:	00 
c0108276:	c7 04 24 fb df 10 c0 	movl   $0xc010dffb,(%esp)
c010827d:	e8 bb 81 ff ff       	call   c010043d <__panic>
    struct Page *p = base;
c0108282:	8b 45 08             	mov    0x8(%ebp),%eax
c0108285:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p++)
c0108288:	eb 7d                	jmp    c0108307 <default_init_memmap+0xb9>
    {
        assert(PageReserved(p));
c010828a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010828d:	83 c0 04             	add    $0x4,%eax
c0108290:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c0108297:	89 45 ec             	mov    %eax,-0x14(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010829a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010829d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01082a0:	0f a3 10             	bt     %edx,(%eax)
c01082a3:	19 c0                	sbb    %eax,%eax
c01082a5:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c01082a8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01082ac:	0f 95 c0             	setne  %al
c01082af:	0f b6 c0             	movzbl %al,%eax
c01082b2:	85 c0                	test   %eax,%eax
c01082b4:	75 24                	jne    c01082da <default_init_memmap+0x8c>
c01082b6:	c7 44 24 0c 11 e0 10 	movl   $0xc010e011,0xc(%esp)
c01082bd:	c0 
c01082be:	c7 44 24 08 e6 df 10 	movl   $0xc010dfe6,0x8(%esp)
c01082c5:	c0 
c01082c6:	c7 44 24 04 73 00 00 	movl   $0x73,0x4(%esp)
c01082cd:	00 
c01082ce:	c7 04 24 fb df 10 c0 	movl   $0xc010dffb,(%esp)
c01082d5:	e8 63 81 ff ff       	call   c010043d <__panic>
        p->flags = p->property = 0;
c01082da:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01082dd:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c01082e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01082e7:	8b 50 08             	mov    0x8(%eax),%edx
c01082ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01082ed:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
c01082f0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01082f7:	00 
c01082f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01082fb:	89 04 24             	mov    %eax,(%esp)
c01082fe:	e8 0a ff ff ff       	call   c010820d <set_page_ref>
    for (; p != base + n; p++)
c0108303:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c0108307:	8b 45 0c             	mov    0xc(%ebp),%eax
c010830a:	c1 e0 05             	shl    $0x5,%eax
c010830d:	89 c2                	mov    %eax,%edx
c010830f:	8b 45 08             	mov    0x8(%ebp),%eax
c0108312:	01 d0                	add    %edx,%eax
c0108314:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0108317:	0f 85 6d ff ff ff    	jne    c010828a <default_init_memmap+0x3c>
    }
    base->property = n;
c010831d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108320:	8b 55 0c             	mov    0xc(%ebp),%edx
c0108323:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0108326:	8b 45 08             	mov    0x8(%ebp),%eax
c0108329:	83 c0 04             	add    $0x4,%eax
c010832c:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0108333:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0108336:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0108339:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010833c:	0f ab 10             	bts    %edx,(%eax)
}
c010833f:	90                   	nop
    nr_free += n;
c0108340:	8b 15 54 41 1b c0    	mov    0xc01b4154,%edx
c0108346:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108349:	01 d0                	add    %edx,%eax
c010834b:	a3 54 41 1b c0       	mov    %eax,0xc01b4154
    list_add_before(&free_list, &(base->page_link));
c0108350:	8b 45 08             	mov    0x8(%ebp),%eax
c0108353:	83 c0 0c             	add    $0xc,%eax
c0108356:	c7 45 e4 4c 41 1b c0 	movl   $0xc01b414c,-0x1c(%ebp)
c010835d:	89 45 e0             	mov    %eax,-0x20(%ebp)
    __list_add(elm, listelm->prev, listelm);
c0108360:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108363:	8b 00                	mov    (%eax),%eax
c0108365:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0108368:	89 55 dc             	mov    %edx,-0x24(%ebp)
c010836b:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010836e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108371:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    prev->next = next->prev = elm;
c0108374:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0108377:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010837a:	89 10                	mov    %edx,(%eax)
c010837c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010837f:	8b 10                	mov    (%eax),%edx
c0108381:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108384:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0108387:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010838a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010838d:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0108390:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108393:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0108396:	89 10                	mov    %edx,(%eax)
}
c0108398:	90                   	nop
}
c0108399:	90                   	nop
}
c010839a:	90                   	nop
c010839b:	c9                   	leave  
c010839c:	c3                   	ret    

c010839d <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n)
{
c010839d:	f3 0f 1e fb          	endbr32 
c01083a1:	55                   	push   %ebp
c01083a2:	89 e5                	mov    %esp,%ebp
c01083a4:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c01083a7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01083ab:	75 24                	jne    c01083d1 <default_alloc_pages+0x34>
c01083ad:	c7 44 24 0c e0 df 10 	movl   $0xc010dfe0,0xc(%esp)
c01083b4:	c0 
c01083b5:	c7 44 24 08 e6 df 10 	movl   $0xc010dfe6,0x8(%esp)
c01083bc:	c0 
c01083bd:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
c01083c4:	00 
c01083c5:	c7 04 24 fb df 10 c0 	movl   $0xc010dffb,(%esp)
c01083cc:	e8 6c 80 ff ff       	call   c010043d <__panic>
    if (n > nr_free)
c01083d1:	a1 54 41 1b c0       	mov    0xc01b4154,%eax
c01083d6:	39 45 08             	cmp    %eax,0x8(%ebp)
c01083d9:	76 0a                	jbe    c01083e5 <default_alloc_pages+0x48>
    {
        return NULL;
c01083db:	b8 00 00 00 00       	mov    $0x0,%eax
c01083e0:	e9 3c 01 00 00       	jmp    c0108521 <default_alloc_pages+0x184>
    }
    struct Page *page = NULL;
c01083e5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
c01083ec:	c7 45 f0 4c 41 1b c0 	movl   $0xc01b414c,-0x10(%ebp)
    // TODO: optimize (next-fit)
    while ((le = list_next(le)) != &free_list)
c01083f3:	eb 1c                	jmp    c0108411 <default_alloc_pages+0x74>
    {
        struct Page *p = le2page(le, page_link);
c01083f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01083f8:	83 e8 0c             	sub    $0xc,%eax
c01083fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n)
c01083fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108401:	8b 40 08             	mov    0x8(%eax),%eax
c0108404:	39 45 08             	cmp    %eax,0x8(%ebp)
c0108407:	77 08                	ja     c0108411 <default_alloc_pages+0x74>
        {
            page = p;
c0108409:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010840c:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
c010840f:	eb 18                	jmp    c0108429 <default_alloc_pages+0x8c>
c0108411:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108414:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->next;
c0108417:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010841a:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list)
c010841d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108420:	81 7d f0 4c 41 1b c0 	cmpl   $0xc01b414c,-0x10(%ebp)
c0108427:	75 cc                	jne    c01083f5 <default_alloc_pages+0x58>
        }
    }
    if (page != NULL)
c0108429:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010842d:	0f 84 eb 00 00 00    	je     c010851e <default_alloc_pages+0x181>
    {
        if (page->property > n)
c0108433:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108436:	8b 40 08             	mov    0x8(%eax),%eax
c0108439:	39 45 08             	cmp    %eax,0x8(%ebp)
c010843c:	0f 83 88 00 00 00    	jae    c01084ca <default_alloc_pages+0x12d>
        {
            struct Page *p = page + n;
c0108442:	8b 45 08             	mov    0x8(%ebp),%eax
c0108445:	c1 e0 05             	shl    $0x5,%eax
c0108448:	89 c2                	mov    %eax,%edx
c010844a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010844d:	01 d0                	add    %edx,%eax
c010844f:	89 45 e8             	mov    %eax,-0x18(%ebp)
            p->property = page->property - n;
c0108452:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108455:	8b 40 08             	mov    0x8(%eax),%eax
c0108458:	2b 45 08             	sub    0x8(%ebp),%eax
c010845b:	89 c2                	mov    %eax,%edx
c010845d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108460:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(p);
c0108463:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108466:	83 c0 04             	add    $0x4,%eax
c0108469:	c7 45 cc 01 00 00 00 	movl   $0x1,-0x34(%ebp)
c0108470:	89 45 c8             	mov    %eax,-0x38(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0108473:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0108476:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0108479:	0f ab 10             	bts    %edx,(%eax)
}
c010847c:	90                   	nop
            list_add_after(&(page->page_link), &(p->page_link));
c010847d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108480:	83 c0 0c             	add    $0xc,%eax
c0108483:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108486:	83 c2 0c             	add    $0xc,%edx
c0108489:	89 55 e0             	mov    %edx,-0x20(%ebp)
c010848c:	89 45 dc             	mov    %eax,-0x24(%ebp)
    __list_add(elm, listelm, listelm->next);
c010848f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108492:	8b 40 04             	mov    0x4(%eax),%eax
c0108495:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0108498:	89 55 d8             	mov    %edx,-0x28(%ebp)
c010849b:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010849e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01084a1:	89 45 d0             	mov    %eax,-0x30(%ebp)
    prev->next = next->prev = elm;
c01084a4:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01084a7:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01084aa:	89 10                	mov    %edx,(%eax)
c01084ac:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01084af:	8b 10                	mov    (%eax),%edx
c01084b1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01084b4:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01084b7:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01084ba:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01084bd:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01084c0:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01084c3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01084c6:	89 10                	mov    %edx,(%eax)
}
c01084c8:	90                   	nop
}
c01084c9:	90                   	nop
        }
        list_del(&(page->page_link));
c01084ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01084cd:	83 c0 0c             	add    $0xc,%eax
c01084d0:	89 45 bc             	mov    %eax,-0x44(%ebp)
    __list_del(listelm->prev, listelm->next);
c01084d3:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01084d6:	8b 40 04             	mov    0x4(%eax),%eax
c01084d9:	8b 55 bc             	mov    -0x44(%ebp),%edx
c01084dc:	8b 12                	mov    (%edx),%edx
c01084de:	89 55 b8             	mov    %edx,-0x48(%ebp)
c01084e1:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    prev->next = next;
c01084e4:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01084e7:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01084ea:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01084ed:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01084f0:	8b 55 b8             	mov    -0x48(%ebp),%edx
c01084f3:	89 10                	mov    %edx,(%eax)
}
c01084f5:	90                   	nop
}
c01084f6:	90                   	nop
        nr_free -= n;
c01084f7:	a1 54 41 1b c0       	mov    0xc01b4154,%eax
c01084fc:	2b 45 08             	sub    0x8(%ebp),%eax
c01084ff:	a3 54 41 1b c0       	mov    %eax,0xc01b4154
        ClearPageProperty(page);
c0108504:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108507:	83 c0 04             	add    $0x4,%eax
c010850a:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c0108511:	89 45 c0             	mov    %eax,-0x40(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0108514:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0108517:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c010851a:	0f b3 10             	btr    %edx,(%eax)
}
c010851d:	90                   	nop
    }
    return page;
c010851e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0108521:	c9                   	leave  
c0108522:	c3                   	ret    

c0108523 <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n)
{
c0108523:	f3 0f 1e fb          	endbr32 
c0108527:	55                   	push   %ebp
c0108528:	89 e5                	mov    %esp,%ebp
c010852a:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
c0108530:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0108534:	75 24                	jne    c010855a <default_free_pages+0x37>
c0108536:	c7 44 24 0c e0 df 10 	movl   $0xc010dfe0,0xc(%esp)
c010853d:	c0 
c010853e:	c7 44 24 08 e6 df 10 	movl   $0xc010dfe6,0x8(%esp)
c0108545:	c0 
c0108546:	c7 44 24 04 a4 00 00 	movl   $0xa4,0x4(%esp)
c010854d:	00 
c010854e:	c7 04 24 fb df 10 c0 	movl   $0xc010dffb,(%esp)
c0108555:	e8 e3 7e ff ff       	call   c010043d <__panic>
    struct Page *p = base;
c010855a:	8b 45 08             	mov    0x8(%ebp),%eax
c010855d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p++)
c0108560:	e9 9d 00 00 00       	jmp    c0108602 <default_free_pages+0xdf>
    {
        assert(!PageReserved(p) && !PageProperty(p));
c0108565:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108568:	83 c0 04             	add    $0x4,%eax
c010856b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0108572:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0108575:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108578:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010857b:	0f a3 10             	bt     %edx,(%eax)
c010857e:	19 c0                	sbb    %eax,%eax
c0108580:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c0108583:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0108587:	0f 95 c0             	setne  %al
c010858a:	0f b6 c0             	movzbl %al,%eax
c010858d:	85 c0                	test   %eax,%eax
c010858f:	75 2c                	jne    c01085bd <default_free_pages+0x9a>
c0108591:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108594:	83 c0 04             	add    $0x4,%eax
c0108597:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c010859e:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01085a1:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01085a4:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01085a7:	0f a3 10             	bt     %edx,(%eax)
c01085aa:	19 c0                	sbb    %eax,%eax
c01085ac:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
c01085af:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c01085b3:	0f 95 c0             	setne  %al
c01085b6:	0f b6 c0             	movzbl %al,%eax
c01085b9:	85 c0                	test   %eax,%eax
c01085bb:	74 24                	je     c01085e1 <default_free_pages+0xbe>
c01085bd:	c7 44 24 0c 24 e0 10 	movl   $0xc010e024,0xc(%esp)
c01085c4:	c0 
c01085c5:	c7 44 24 08 e6 df 10 	movl   $0xc010dfe6,0x8(%esp)
c01085cc:	c0 
c01085cd:	c7 44 24 04 a8 00 00 	movl   $0xa8,0x4(%esp)
c01085d4:	00 
c01085d5:	c7 04 24 fb df 10 c0 	movl   $0xc010dffb,(%esp)
c01085dc:	e8 5c 7e ff ff       	call   c010043d <__panic>
        p->flags = 0;
c01085e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01085e4:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c01085eb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01085f2:	00 
c01085f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01085f6:	89 04 24             	mov    %eax,(%esp)
c01085f9:	e8 0f fc ff ff       	call   c010820d <set_page_ref>
    for (; p != base + n; p++)
c01085fe:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c0108602:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108605:	c1 e0 05             	shl    $0x5,%eax
c0108608:	89 c2                	mov    %eax,%edx
c010860a:	8b 45 08             	mov    0x8(%ebp),%eax
c010860d:	01 d0                	add    %edx,%eax
c010860f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0108612:	0f 85 4d ff ff ff    	jne    c0108565 <default_free_pages+0x42>
    }
    base->property = n;
c0108618:	8b 45 08             	mov    0x8(%ebp),%eax
c010861b:	8b 55 0c             	mov    0xc(%ebp),%edx
c010861e:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0108621:	8b 45 08             	mov    0x8(%ebp),%eax
c0108624:	83 c0 04             	add    $0x4,%eax
c0108627:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c010862e:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0108631:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0108634:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0108637:	0f ab 10             	bts    %edx,(%eax)
}
c010863a:	90                   	nop
c010863b:	c7 45 d4 4c 41 1b c0 	movl   $0xc01b414c,-0x2c(%ebp)
    return listelm->next;
c0108642:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0108645:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
c0108648:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list)
c010864b:	e9 00 01 00 00       	jmp    c0108750 <default_free_pages+0x22d>
    {
        p = le2page(le, page_link);
c0108650:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108653:	83 e8 0c             	sub    $0xc,%eax
c0108656:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108659:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010865c:	89 45 c8             	mov    %eax,-0x38(%ebp)
c010865f:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0108662:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0108665:	89 45 f0             	mov    %eax,-0x10(%ebp)
        // TODO: optimize
        if (base + base->property == p)
c0108668:	8b 45 08             	mov    0x8(%ebp),%eax
c010866b:	8b 40 08             	mov    0x8(%eax),%eax
c010866e:	c1 e0 05             	shl    $0x5,%eax
c0108671:	89 c2                	mov    %eax,%edx
c0108673:	8b 45 08             	mov    0x8(%ebp),%eax
c0108676:	01 d0                	add    %edx,%eax
c0108678:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010867b:	75 5d                	jne    c01086da <default_free_pages+0x1b7>
        {
            base->property += p->property;
c010867d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108680:	8b 50 08             	mov    0x8(%eax),%edx
c0108683:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108686:	8b 40 08             	mov    0x8(%eax),%eax
c0108689:	01 c2                	add    %eax,%edx
c010868b:	8b 45 08             	mov    0x8(%ebp),%eax
c010868e:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
c0108691:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108694:	83 c0 04             	add    $0x4,%eax
c0108697:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
c010869e:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01086a1:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01086a4:	8b 55 b8             	mov    -0x48(%ebp),%edx
c01086a7:	0f b3 10             	btr    %edx,(%eax)
}
c01086aa:	90                   	nop
            list_del(&(p->page_link));
c01086ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01086ae:	83 c0 0c             	add    $0xc,%eax
c01086b1:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    __list_del(listelm->prev, listelm->next);
c01086b4:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01086b7:	8b 40 04             	mov    0x4(%eax),%eax
c01086ba:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c01086bd:	8b 12                	mov    (%edx),%edx
c01086bf:	89 55 c0             	mov    %edx,-0x40(%ebp)
c01086c2:	89 45 bc             	mov    %eax,-0x44(%ebp)
    prev->next = next;
c01086c5:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01086c8:	8b 55 bc             	mov    -0x44(%ebp),%edx
c01086cb:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01086ce:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01086d1:	8b 55 c0             	mov    -0x40(%ebp),%edx
c01086d4:	89 10                	mov    %edx,(%eax)
}
c01086d6:	90                   	nop
}
c01086d7:	90                   	nop
c01086d8:	eb 76                	jmp    c0108750 <default_free_pages+0x22d>
        }
        else if (p + p->property == base)
c01086da:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01086dd:	8b 40 08             	mov    0x8(%eax),%eax
c01086e0:	c1 e0 05             	shl    $0x5,%eax
c01086e3:	89 c2                	mov    %eax,%edx
c01086e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01086e8:	01 d0                	add    %edx,%eax
c01086ea:	39 45 08             	cmp    %eax,0x8(%ebp)
c01086ed:	75 61                	jne    c0108750 <default_free_pages+0x22d>
        {
            p->property += base->property;
c01086ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01086f2:	8b 50 08             	mov    0x8(%eax),%edx
c01086f5:	8b 45 08             	mov    0x8(%ebp),%eax
c01086f8:	8b 40 08             	mov    0x8(%eax),%eax
c01086fb:	01 c2                	add    %eax,%edx
c01086fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108700:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
c0108703:	8b 45 08             	mov    0x8(%ebp),%eax
c0108706:	83 c0 04             	add    $0x4,%eax
c0108709:	c7 45 a4 01 00 00 00 	movl   $0x1,-0x5c(%ebp)
c0108710:	89 45 a0             	mov    %eax,-0x60(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0108713:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0108716:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0108719:	0f b3 10             	btr    %edx,(%eax)
}
c010871c:	90                   	nop
            base = p;
c010871d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108720:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
c0108723:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108726:	83 c0 0c             	add    $0xc,%eax
c0108729:	89 45 b0             	mov    %eax,-0x50(%ebp)
    __list_del(listelm->prev, listelm->next);
c010872c:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010872f:	8b 40 04             	mov    0x4(%eax),%eax
c0108732:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0108735:	8b 12                	mov    (%edx),%edx
c0108737:	89 55 ac             	mov    %edx,-0x54(%ebp)
c010873a:	89 45 a8             	mov    %eax,-0x58(%ebp)
    prev->next = next;
c010873d:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0108740:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0108743:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0108746:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0108749:	8b 55 ac             	mov    -0x54(%ebp),%edx
c010874c:	89 10                	mov    %edx,(%eax)
}
c010874e:	90                   	nop
}
c010874f:	90                   	nop
    while (le != &free_list)
c0108750:	81 7d f0 4c 41 1b c0 	cmpl   $0xc01b414c,-0x10(%ebp)
c0108757:	0f 85 f3 fe ff ff    	jne    c0108650 <default_free_pages+0x12d>
        }
    }
    nr_free += n;
c010875d:	8b 15 54 41 1b c0    	mov    0xc01b4154,%edx
c0108763:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108766:	01 d0                	add    %edx,%eax
c0108768:	a3 54 41 1b c0       	mov    %eax,0xc01b4154
c010876d:	c7 45 9c 4c 41 1b c0 	movl   $0xc01b414c,-0x64(%ebp)
    return listelm->next;
c0108774:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0108777:	8b 40 04             	mov    0x4(%eax),%eax
    le = list_next(&free_list);
c010877a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list)
c010877d:	eb 66                	jmp    c01087e5 <default_free_pages+0x2c2>
    {
        p = le2page(le, page_link);
c010877f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108782:	83 e8 0c             	sub    $0xc,%eax
c0108785:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (base + base->property <= p)
c0108788:	8b 45 08             	mov    0x8(%ebp),%eax
c010878b:	8b 40 08             	mov    0x8(%eax),%eax
c010878e:	c1 e0 05             	shl    $0x5,%eax
c0108791:	89 c2                	mov    %eax,%edx
c0108793:	8b 45 08             	mov    0x8(%ebp),%eax
c0108796:	01 d0                	add    %edx,%eax
c0108798:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010879b:	72 39                	jb     c01087d6 <default_free_pages+0x2b3>
        {
            assert(base + base->property != p);
c010879d:	8b 45 08             	mov    0x8(%ebp),%eax
c01087a0:	8b 40 08             	mov    0x8(%eax),%eax
c01087a3:	c1 e0 05             	shl    $0x5,%eax
c01087a6:	89 c2                	mov    %eax,%edx
c01087a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01087ab:	01 d0                	add    %edx,%eax
c01087ad:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01087b0:	75 3e                	jne    c01087f0 <default_free_pages+0x2cd>
c01087b2:	c7 44 24 0c 49 e0 10 	movl   $0xc010e049,0xc(%esp)
c01087b9:	c0 
c01087ba:	c7 44 24 08 e6 df 10 	movl   $0xc010dfe6,0x8(%esp)
c01087c1:	c0 
c01087c2:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
c01087c9:	00 
c01087ca:	c7 04 24 fb df 10 c0 	movl   $0xc010dffb,(%esp)
c01087d1:	e8 67 7c ff ff       	call   c010043d <__panic>
c01087d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01087d9:	89 45 98             	mov    %eax,-0x68(%ebp)
c01087dc:	8b 45 98             	mov    -0x68(%ebp),%eax
c01087df:	8b 40 04             	mov    0x4(%eax),%eax
            break;
        }
        le = list_next(le);
c01087e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list)
c01087e5:	81 7d f0 4c 41 1b c0 	cmpl   $0xc01b414c,-0x10(%ebp)
c01087ec:	75 91                	jne    c010877f <default_free_pages+0x25c>
c01087ee:	eb 01                	jmp    c01087f1 <default_free_pages+0x2ce>
            break;
c01087f0:	90                   	nop
    }
    list_add_before(le, &(base->page_link));
c01087f1:	8b 45 08             	mov    0x8(%ebp),%eax
c01087f4:	8d 50 0c             	lea    0xc(%eax),%edx
c01087f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01087fa:	89 45 94             	mov    %eax,-0x6c(%ebp)
c01087fd:	89 55 90             	mov    %edx,-0x70(%ebp)
    __list_add(elm, listelm->prev, listelm);
c0108800:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0108803:	8b 00                	mov    (%eax),%eax
c0108805:	8b 55 90             	mov    -0x70(%ebp),%edx
c0108808:	89 55 8c             	mov    %edx,-0x74(%ebp)
c010880b:	89 45 88             	mov    %eax,-0x78(%ebp)
c010880e:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0108811:	89 45 84             	mov    %eax,-0x7c(%ebp)
    prev->next = next->prev = elm;
c0108814:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0108817:	8b 55 8c             	mov    -0x74(%ebp),%edx
c010881a:	89 10                	mov    %edx,(%eax)
c010881c:	8b 45 84             	mov    -0x7c(%ebp),%eax
c010881f:	8b 10                	mov    (%eax),%edx
c0108821:	8b 45 88             	mov    -0x78(%ebp),%eax
c0108824:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0108827:	8b 45 8c             	mov    -0x74(%ebp),%eax
c010882a:	8b 55 84             	mov    -0x7c(%ebp),%edx
c010882d:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0108830:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0108833:	8b 55 88             	mov    -0x78(%ebp),%edx
c0108836:	89 10                	mov    %edx,(%eax)
}
c0108838:	90                   	nop
}
c0108839:	90                   	nop
}
c010883a:	90                   	nop
c010883b:	c9                   	leave  
c010883c:	c3                   	ret    

c010883d <default_nr_free_pages>:

static size_t
default_nr_free_pages(void)
{
c010883d:	f3 0f 1e fb          	endbr32 
c0108841:	55                   	push   %ebp
c0108842:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0108844:	a1 54 41 1b c0       	mov    0xc01b4154,%eax
}
c0108849:	5d                   	pop    %ebp
c010884a:	c3                   	ret    

c010884b <basic_check>:

static void
basic_check(void)
{
c010884b:	f3 0f 1e fb          	endbr32 
c010884f:	55                   	push   %ebp
c0108850:	89 e5                	mov    %esp,%ebp
c0108852:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0108855:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010885c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010885f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108862:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108865:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0108868:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010886f:	e8 01 b1 ff ff       	call   c0103975 <alloc_pages>
c0108874:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108877:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010887b:	75 24                	jne    c01088a1 <basic_check+0x56>
c010887d:	c7 44 24 0c 64 e0 10 	movl   $0xc010e064,0xc(%esp)
c0108884:	c0 
c0108885:	c7 44 24 08 e6 df 10 	movl   $0xc010dfe6,0x8(%esp)
c010888c:	c0 
c010888d:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
c0108894:	00 
c0108895:	c7 04 24 fb df 10 c0 	movl   $0xc010dffb,(%esp)
c010889c:	e8 9c 7b ff ff       	call   c010043d <__panic>
    assert((p1 = alloc_page()) != NULL);
c01088a1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01088a8:	e8 c8 b0 ff ff       	call   c0103975 <alloc_pages>
c01088ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01088b0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01088b4:	75 24                	jne    c01088da <basic_check+0x8f>
c01088b6:	c7 44 24 0c 80 e0 10 	movl   $0xc010e080,0xc(%esp)
c01088bd:	c0 
c01088be:	c7 44 24 08 e6 df 10 	movl   $0xc010dfe6,0x8(%esp)
c01088c5:	c0 
c01088c6:	c7 44 24 04 dd 00 00 	movl   $0xdd,0x4(%esp)
c01088cd:	00 
c01088ce:	c7 04 24 fb df 10 c0 	movl   $0xc010dffb,(%esp)
c01088d5:	e8 63 7b ff ff       	call   c010043d <__panic>
    assert((p2 = alloc_page()) != NULL);
c01088da:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01088e1:	e8 8f b0 ff ff       	call   c0103975 <alloc_pages>
c01088e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01088e9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01088ed:	75 24                	jne    c0108913 <basic_check+0xc8>
c01088ef:	c7 44 24 0c 9c e0 10 	movl   $0xc010e09c,0xc(%esp)
c01088f6:	c0 
c01088f7:	c7 44 24 08 e6 df 10 	movl   $0xc010dfe6,0x8(%esp)
c01088fe:	c0 
c01088ff:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
c0108906:	00 
c0108907:	c7 04 24 fb df 10 c0 	movl   $0xc010dffb,(%esp)
c010890e:	e8 2a 7b ff ff       	call   c010043d <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0108913:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108916:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0108919:	74 10                	je     c010892b <basic_check+0xe0>
c010891b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010891e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0108921:	74 08                	je     c010892b <basic_check+0xe0>
c0108923:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108926:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0108929:	75 24                	jne    c010894f <basic_check+0x104>
c010892b:	c7 44 24 0c b8 e0 10 	movl   $0xc010e0b8,0xc(%esp)
c0108932:	c0 
c0108933:	c7 44 24 08 e6 df 10 	movl   $0xc010dfe6,0x8(%esp)
c010893a:	c0 
c010893b:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
c0108942:	00 
c0108943:	c7 04 24 fb df 10 c0 	movl   $0xc010dffb,(%esp)
c010894a:	e8 ee 7a ff ff       	call   c010043d <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c010894f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108952:	89 04 24             	mov    %eax,(%esp)
c0108955:	e8 a9 f8 ff ff       	call   c0108203 <page_ref>
c010895a:	85 c0                	test   %eax,%eax
c010895c:	75 1e                	jne    c010897c <basic_check+0x131>
c010895e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108961:	89 04 24             	mov    %eax,(%esp)
c0108964:	e8 9a f8 ff ff       	call   c0108203 <page_ref>
c0108969:	85 c0                	test   %eax,%eax
c010896b:	75 0f                	jne    c010897c <basic_check+0x131>
c010896d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108970:	89 04 24             	mov    %eax,(%esp)
c0108973:	e8 8b f8 ff ff       	call   c0108203 <page_ref>
c0108978:	85 c0                	test   %eax,%eax
c010897a:	74 24                	je     c01089a0 <basic_check+0x155>
c010897c:	c7 44 24 0c dc e0 10 	movl   $0xc010e0dc,0xc(%esp)
c0108983:	c0 
c0108984:	c7 44 24 08 e6 df 10 	movl   $0xc010dfe6,0x8(%esp)
c010898b:	c0 
c010898c:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
c0108993:	00 
c0108994:	c7 04 24 fb df 10 c0 	movl   $0xc010dffb,(%esp)
c010899b:	e8 9d 7a ff ff       	call   c010043d <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c01089a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01089a3:	89 04 24             	mov    %eax,(%esp)
c01089a6:	e8 42 f8 ff ff       	call   c01081ed <page2pa>
c01089ab:	8b 15 80 1f 1b c0    	mov    0xc01b1f80,%edx
c01089b1:	c1 e2 0c             	shl    $0xc,%edx
c01089b4:	39 d0                	cmp    %edx,%eax
c01089b6:	72 24                	jb     c01089dc <basic_check+0x191>
c01089b8:	c7 44 24 0c 18 e1 10 	movl   $0xc010e118,0xc(%esp)
c01089bf:	c0 
c01089c0:	c7 44 24 08 e6 df 10 	movl   $0xc010dfe6,0x8(%esp)
c01089c7:	c0 
c01089c8:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
c01089cf:	00 
c01089d0:	c7 04 24 fb df 10 c0 	movl   $0xc010dffb,(%esp)
c01089d7:	e8 61 7a ff ff       	call   c010043d <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c01089dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01089df:	89 04 24             	mov    %eax,(%esp)
c01089e2:	e8 06 f8 ff ff       	call   c01081ed <page2pa>
c01089e7:	8b 15 80 1f 1b c0    	mov    0xc01b1f80,%edx
c01089ed:	c1 e2 0c             	shl    $0xc,%edx
c01089f0:	39 d0                	cmp    %edx,%eax
c01089f2:	72 24                	jb     c0108a18 <basic_check+0x1cd>
c01089f4:	c7 44 24 0c 35 e1 10 	movl   $0xc010e135,0xc(%esp)
c01089fb:	c0 
c01089fc:	c7 44 24 08 e6 df 10 	movl   $0xc010dfe6,0x8(%esp)
c0108a03:	c0 
c0108a04:	c7 44 24 04 e4 00 00 	movl   $0xe4,0x4(%esp)
c0108a0b:	00 
c0108a0c:	c7 04 24 fb df 10 c0 	movl   $0xc010dffb,(%esp)
c0108a13:	e8 25 7a ff ff       	call   c010043d <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0108a18:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108a1b:	89 04 24             	mov    %eax,(%esp)
c0108a1e:	e8 ca f7 ff ff       	call   c01081ed <page2pa>
c0108a23:	8b 15 80 1f 1b c0    	mov    0xc01b1f80,%edx
c0108a29:	c1 e2 0c             	shl    $0xc,%edx
c0108a2c:	39 d0                	cmp    %edx,%eax
c0108a2e:	72 24                	jb     c0108a54 <basic_check+0x209>
c0108a30:	c7 44 24 0c 52 e1 10 	movl   $0xc010e152,0xc(%esp)
c0108a37:	c0 
c0108a38:	c7 44 24 08 e6 df 10 	movl   $0xc010dfe6,0x8(%esp)
c0108a3f:	c0 
c0108a40:	c7 44 24 04 e5 00 00 	movl   $0xe5,0x4(%esp)
c0108a47:	00 
c0108a48:	c7 04 24 fb df 10 c0 	movl   $0xc010dffb,(%esp)
c0108a4f:	e8 e9 79 ff ff       	call   c010043d <__panic>

    list_entry_t free_list_store = free_list;
c0108a54:	a1 4c 41 1b c0       	mov    0xc01b414c,%eax
c0108a59:	8b 15 50 41 1b c0    	mov    0xc01b4150,%edx
c0108a5f:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0108a62:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0108a65:	c7 45 dc 4c 41 1b c0 	movl   $0xc01b414c,-0x24(%ebp)
    elm->prev = elm->next = elm;
c0108a6c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108a6f:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0108a72:	89 50 04             	mov    %edx,0x4(%eax)
c0108a75:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108a78:	8b 50 04             	mov    0x4(%eax),%edx
c0108a7b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108a7e:	89 10                	mov    %edx,(%eax)
}
c0108a80:	90                   	nop
c0108a81:	c7 45 e0 4c 41 1b c0 	movl   $0xc01b414c,-0x20(%ebp)
    return list->next == list;
c0108a88:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108a8b:	8b 40 04             	mov    0x4(%eax),%eax
c0108a8e:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0108a91:	0f 94 c0             	sete   %al
c0108a94:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0108a97:	85 c0                	test   %eax,%eax
c0108a99:	75 24                	jne    c0108abf <basic_check+0x274>
c0108a9b:	c7 44 24 0c 6f e1 10 	movl   $0xc010e16f,0xc(%esp)
c0108aa2:	c0 
c0108aa3:	c7 44 24 08 e6 df 10 	movl   $0xc010dfe6,0x8(%esp)
c0108aaa:	c0 
c0108aab:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
c0108ab2:	00 
c0108ab3:	c7 04 24 fb df 10 c0 	movl   $0xc010dffb,(%esp)
c0108aba:	e8 7e 79 ff ff       	call   c010043d <__panic>

    unsigned int nr_free_store = nr_free;
c0108abf:	a1 54 41 1b c0       	mov    0xc01b4154,%eax
c0108ac4:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c0108ac7:	c7 05 54 41 1b c0 00 	movl   $0x0,0xc01b4154
c0108ace:	00 00 00 

    assert(alloc_page() == NULL);
c0108ad1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0108ad8:	e8 98 ae ff ff       	call   c0103975 <alloc_pages>
c0108add:	85 c0                	test   %eax,%eax
c0108adf:	74 24                	je     c0108b05 <basic_check+0x2ba>
c0108ae1:	c7 44 24 0c 86 e1 10 	movl   $0xc010e186,0xc(%esp)
c0108ae8:	c0 
c0108ae9:	c7 44 24 08 e6 df 10 	movl   $0xc010dfe6,0x8(%esp)
c0108af0:	c0 
c0108af1:	c7 44 24 04 ee 00 00 	movl   $0xee,0x4(%esp)
c0108af8:	00 
c0108af9:	c7 04 24 fb df 10 c0 	movl   $0xc010dffb,(%esp)
c0108b00:	e8 38 79 ff ff       	call   c010043d <__panic>

    free_page(p0);
c0108b05:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0108b0c:	00 
c0108b0d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108b10:	89 04 24             	mov    %eax,(%esp)
c0108b13:	e8 cc ae ff ff       	call   c01039e4 <free_pages>
    free_page(p1);
c0108b18:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0108b1f:	00 
c0108b20:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108b23:	89 04 24             	mov    %eax,(%esp)
c0108b26:	e8 b9 ae ff ff       	call   c01039e4 <free_pages>
    free_page(p2);
c0108b2b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0108b32:	00 
c0108b33:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108b36:	89 04 24             	mov    %eax,(%esp)
c0108b39:	e8 a6 ae ff ff       	call   c01039e4 <free_pages>
    assert(nr_free == 3);
c0108b3e:	a1 54 41 1b c0       	mov    0xc01b4154,%eax
c0108b43:	83 f8 03             	cmp    $0x3,%eax
c0108b46:	74 24                	je     c0108b6c <basic_check+0x321>
c0108b48:	c7 44 24 0c 9b e1 10 	movl   $0xc010e19b,0xc(%esp)
c0108b4f:	c0 
c0108b50:	c7 44 24 08 e6 df 10 	movl   $0xc010dfe6,0x8(%esp)
c0108b57:	c0 
c0108b58:	c7 44 24 04 f3 00 00 	movl   $0xf3,0x4(%esp)
c0108b5f:	00 
c0108b60:	c7 04 24 fb df 10 c0 	movl   $0xc010dffb,(%esp)
c0108b67:	e8 d1 78 ff ff       	call   c010043d <__panic>

    assert((p0 = alloc_page()) != NULL);
c0108b6c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0108b73:	e8 fd ad ff ff       	call   c0103975 <alloc_pages>
c0108b78:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108b7b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0108b7f:	75 24                	jne    c0108ba5 <basic_check+0x35a>
c0108b81:	c7 44 24 0c 64 e0 10 	movl   $0xc010e064,0xc(%esp)
c0108b88:	c0 
c0108b89:	c7 44 24 08 e6 df 10 	movl   $0xc010dfe6,0x8(%esp)
c0108b90:	c0 
c0108b91:	c7 44 24 04 f5 00 00 	movl   $0xf5,0x4(%esp)
c0108b98:	00 
c0108b99:	c7 04 24 fb df 10 c0 	movl   $0xc010dffb,(%esp)
c0108ba0:	e8 98 78 ff ff       	call   c010043d <__panic>
    assert((p1 = alloc_page()) != NULL);
c0108ba5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0108bac:	e8 c4 ad ff ff       	call   c0103975 <alloc_pages>
c0108bb1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108bb4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0108bb8:	75 24                	jne    c0108bde <basic_check+0x393>
c0108bba:	c7 44 24 0c 80 e0 10 	movl   $0xc010e080,0xc(%esp)
c0108bc1:	c0 
c0108bc2:	c7 44 24 08 e6 df 10 	movl   $0xc010dfe6,0x8(%esp)
c0108bc9:	c0 
c0108bca:	c7 44 24 04 f6 00 00 	movl   $0xf6,0x4(%esp)
c0108bd1:	00 
c0108bd2:	c7 04 24 fb df 10 c0 	movl   $0xc010dffb,(%esp)
c0108bd9:	e8 5f 78 ff ff       	call   c010043d <__panic>
    assert((p2 = alloc_page()) != NULL);
c0108bde:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0108be5:	e8 8b ad ff ff       	call   c0103975 <alloc_pages>
c0108bea:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108bed:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108bf1:	75 24                	jne    c0108c17 <basic_check+0x3cc>
c0108bf3:	c7 44 24 0c 9c e0 10 	movl   $0xc010e09c,0xc(%esp)
c0108bfa:	c0 
c0108bfb:	c7 44 24 08 e6 df 10 	movl   $0xc010dfe6,0x8(%esp)
c0108c02:	c0 
c0108c03:	c7 44 24 04 f7 00 00 	movl   $0xf7,0x4(%esp)
c0108c0a:	00 
c0108c0b:	c7 04 24 fb df 10 c0 	movl   $0xc010dffb,(%esp)
c0108c12:	e8 26 78 ff ff       	call   c010043d <__panic>

    assert(alloc_page() == NULL);
c0108c17:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0108c1e:	e8 52 ad ff ff       	call   c0103975 <alloc_pages>
c0108c23:	85 c0                	test   %eax,%eax
c0108c25:	74 24                	je     c0108c4b <basic_check+0x400>
c0108c27:	c7 44 24 0c 86 e1 10 	movl   $0xc010e186,0xc(%esp)
c0108c2e:	c0 
c0108c2f:	c7 44 24 08 e6 df 10 	movl   $0xc010dfe6,0x8(%esp)
c0108c36:	c0 
c0108c37:	c7 44 24 04 f9 00 00 	movl   $0xf9,0x4(%esp)
c0108c3e:	00 
c0108c3f:	c7 04 24 fb df 10 c0 	movl   $0xc010dffb,(%esp)
c0108c46:	e8 f2 77 ff ff       	call   c010043d <__panic>

    free_page(p0);
c0108c4b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0108c52:	00 
c0108c53:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108c56:	89 04 24             	mov    %eax,(%esp)
c0108c59:	e8 86 ad ff ff       	call   c01039e4 <free_pages>
c0108c5e:	c7 45 d8 4c 41 1b c0 	movl   $0xc01b414c,-0x28(%ebp)
c0108c65:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108c68:	8b 40 04             	mov    0x4(%eax),%eax
c0108c6b:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0108c6e:	0f 94 c0             	sete   %al
c0108c71:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c0108c74:	85 c0                	test   %eax,%eax
c0108c76:	74 24                	je     c0108c9c <basic_check+0x451>
c0108c78:	c7 44 24 0c a8 e1 10 	movl   $0xc010e1a8,0xc(%esp)
c0108c7f:	c0 
c0108c80:	c7 44 24 08 e6 df 10 	movl   $0xc010dfe6,0x8(%esp)
c0108c87:	c0 
c0108c88:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
c0108c8f:	00 
c0108c90:	c7 04 24 fb df 10 c0 	movl   $0xc010dffb,(%esp)
c0108c97:	e8 a1 77 ff ff       	call   c010043d <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0108c9c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0108ca3:	e8 cd ac ff ff       	call   c0103975 <alloc_pages>
c0108ca8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0108cab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108cae:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0108cb1:	74 24                	je     c0108cd7 <basic_check+0x48c>
c0108cb3:	c7 44 24 0c c0 e1 10 	movl   $0xc010e1c0,0xc(%esp)
c0108cba:	c0 
c0108cbb:	c7 44 24 08 e6 df 10 	movl   $0xc010dfe6,0x8(%esp)
c0108cc2:	c0 
c0108cc3:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
c0108cca:	00 
c0108ccb:	c7 04 24 fb df 10 c0 	movl   $0xc010dffb,(%esp)
c0108cd2:	e8 66 77 ff ff       	call   c010043d <__panic>
    assert(alloc_page() == NULL);
c0108cd7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0108cde:	e8 92 ac ff ff       	call   c0103975 <alloc_pages>
c0108ce3:	85 c0                	test   %eax,%eax
c0108ce5:	74 24                	je     c0108d0b <basic_check+0x4c0>
c0108ce7:	c7 44 24 0c 86 e1 10 	movl   $0xc010e186,0xc(%esp)
c0108cee:	c0 
c0108cef:	c7 44 24 08 e6 df 10 	movl   $0xc010dfe6,0x8(%esp)
c0108cf6:	c0 
c0108cf7:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
c0108cfe:	00 
c0108cff:	c7 04 24 fb df 10 c0 	movl   $0xc010dffb,(%esp)
c0108d06:	e8 32 77 ff ff       	call   c010043d <__panic>

    assert(nr_free == 0);
c0108d0b:	a1 54 41 1b c0       	mov    0xc01b4154,%eax
c0108d10:	85 c0                	test   %eax,%eax
c0108d12:	74 24                	je     c0108d38 <basic_check+0x4ed>
c0108d14:	c7 44 24 0c d9 e1 10 	movl   $0xc010e1d9,0xc(%esp)
c0108d1b:	c0 
c0108d1c:	c7 44 24 08 e6 df 10 	movl   $0xc010dfe6,0x8(%esp)
c0108d23:	c0 
c0108d24:	c7 44 24 04 02 01 00 	movl   $0x102,0x4(%esp)
c0108d2b:	00 
c0108d2c:	c7 04 24 fb df 10 c0 	movl   $0xc010dffb,(%esp)
c0108d33:	e8 05 77 ff ff       	call   c010043d <__panic>
    free_list = free_list_store;
c0108d38:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0108d3b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0108d3e:	a3 4c 41 1b c0       	mov    %eax,0xc01b414c
c0108d43:	89 15 50 41 1b c0    	mov    %edx,0xc01b4150
    nr_free = nr_free_store;
c0108d49:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108d4c:	a3 54 41 1b c0       	mov    %eax,0xc01b4154

    free_page(p);
c0108d51:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0108d58:	00 
c0108d59:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108d5c:	89 04 24             	mov    %eax,(%esp)
c0108d5f:	e8 80 ac ff ff       	call   c01039e4 <free_pages>
    free_page(p1);
c0108d64:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0108d6b:	00 
c0108d6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108d6f:	89 04 24             	mov    %eax,(%esp)
c0108d72:	e8 6d ac ff ff       	call   c01039e4 <free_pages>
    free_page(p2);
c0108d77:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0108d7e:	00 
c0108d7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108d82:	89 04 24             	mov    %eax,(%esp)
c0108d85:	e8 5a ac ff ff       	call   c01039e4 <free_pages>
}
c0108d8a:	90                   	nop
c0108d8b:	c9                   	leave  
c0108d8c:	c3                   	ret    

c0108d8d <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1)
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void)
{
c0108d8d:	f3 0f 1e fb          	endbr32 
c0108d91:	55                   	push   %ebp
c0108d92:	89 e5                	mov    %esp,%ebp
c0108d94:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
c0108d9a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0108da1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c0108da8:	c7 45 ec 4c 41 1b c0 	movl   $0xc01b414c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list)
c0108daf:	eb 6a                	jmp    c0108e1b <default_check+0x8e>
    {
        struct Page *p = le2page(le, page_link);
c0108db1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108db4:	83 e8 0c             	sub    $0xc,%eax
c0108db7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(PageProperty(p));
c0108dba:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0108dbd:	83 c0 04             	add    $0x4,%eax
c0108dc0:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0108dc7:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0108dca:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0108dcd:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0108dd0:	0f a3 10             	bt     %edx,(%eax)
c0108dd3:	19 c0                	sbb    %eax,%eax
c0108dd5:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c0108dd8:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0108ddc:	0f 95 c0             	setne  %al
c0108ddf:	0f b6 c0             	movzbl %al,%eax
c0108de2:	85 c0                	test   %eax,%eax
c0108de4:	75 24                	jne    c0108e0a <default_check+0x7d>
c0108de6:	c7 44 24 0c e6 e1 10 	movl   $0xc010e1e6,0xc(%esp)
c0108ded:	c0 
c0108dee:	c7 44 24 08 e6 df 10 	movl   $0xc010dfe6,0x8(%esp)
c0108df5:	c0 
c0108df6:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
c0108dfd:	00 
c0108dfe:	c7 04 24 fb df 10 c0 	movl   $0xc010dffb,(%esp)
c0108e05:	e8 33 76 ff ff       	call   c010043d <__panic>
        count++, total += p->property;
c0108e0a:	ff 45 f4             	incl   -0xc(%ebp)
c0108e0d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0108e10:	8b 50 08             	mov    0x8(%eax),%edx
c0108e13:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108e16:	01 d0                	add    %edx,%eax
c0108e18:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108e1b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108e1e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
c0108e21:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0108e24:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list)
c0108e27:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108e2a:	81 7d ec 4c 41 1b c0 	cmpl   $0xc01b414c,-0x14(%ebp)
c0108e31:	0f 85 7a ff ff ff    	jne    c0108db1 <default_check+0x24>
    }
    assert(total == nr_free_pages());
c0108e37:	e8 df ab ff ff       	call   c0103a1b <nr_free_pages>
c0108e3c:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0108e3f:	39 d0                	cmp    %edx,%eax
c0108e41:	74 24                	je     c0108e67 <default_check+0xda>
c0108e43:	c7 44 24 0c f6 e1 10 	movl   $0xc010e1f6,0xc(%esp)
c0108e4a:	c0 
c0108e4b:	c7 44 24 08 e6 df 10 	movl   $0xc010dfe6,0x8(%esp)
c0108e52:	c0 
c0108e53:	c7 44 24 04 18 01 00 	movl   $0x118,0x4(%esp)
c0108e5a:	00 
c0108e5b:	c7 04 24 fb df 10 c0 	movl   $0xc010dffb,(%esp)
c0108e62:	e8 d6 75 ff ff       	call   c010043d <__panic>

    basic_check();
c0108e67:	e8 df f9 ff ff       	call   c010884b <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c0108e6c:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0108e73:	e8 fd aa ff ff       	call   c0103975 <alloc_pages>
c0108e78:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p0 != NULL);
c0108e7b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0108e7f:	75 24                	jne    c0108ea5 <default_check+0x118>
c0108e81:	c7 44 24 0c 0f e2 10 	movl   $0xc010e20f,0xc(%esp)
c0108e88:	c0 
c0108e89:	c7 44 24 08 e6 df 10 	movl   $0xc010dfe6,0x8(%esp)
c0108e90:	c0 
c0108e91:	c7 44 24 04 1d 01 00 	movl   $0x11d,0x4(%esp)
c0108e98:	00 
c0108e99:	c7 04 24 fb df 10 c0 	movl   $0xc010dffb,(%esp)
c0108ea0:	e8 98 75 ff ff       	call   c010043d <__panic>
    assert(!PageProperty(p0));
c0108ea5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108ea8:	83 c0 04             	add    $0x4,%eax
c0108eab:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0108eb2:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0108eb5:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0108eb8:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0108ebb:	0f a3 10             	bt     %edx,(%eax)
c0108ebe:	19 c0                	sbb    %eax,%eax
c0108ec0:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c0108ec3:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0108ec7:	0f 95 c0             	setne  %al
c0108eca:	0f b6 c0             	movzbl %al,%eax
c0108ecd:	85 c0                	test   %eax,%eax
c0108ecf:	74 24                	je     c0108ef5 <default_check+0x168>
c0108ed1:	c7 44 24 0c 1a e2 10 	movl   $0xc010e21a,0xc(%esp)
c0108ed8:	c0 
c0108ed9:	c7 44 24 08 e6 df 10 	movl   $0xc010dfe6,0x8(%esp)
c0108ee0:	c0 
c0108ee1:	c7 44 24 04 1e 01 00 	movl   $0x11e,0x4(%esp)
c0108ee8:	00 
c0108ee9:	c7 04 24 fb df 10 c0 	movl   $0xc010dffb,(%esp)
c0108ef0:	e8 48 75 ff ff       	call   c010043d <__panic>

    list_entry_t free_list_store = free_list;
c0108ef5:	a1 4c 41 1b c0       	mov    0xc01b414c,%eax
c0108efa:	8b 15 50 41 1b c0    	mov    0xc01b4150,%edx
c0108f00:	89 45 80             	mov    %eax,-0x80(%ebp)
c0108f03:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0108f06:	c7 45 b0 4c 41 1b c0 	movl   $0xc01b414c,-0x50(%ebp)
    elm->prev = elm->next = elm;
c0108f0d:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0108f10:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0108f13:	89 50 04             	mov    %edx,0x4(%eax)
c0108f16:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0108f19:	8b 50 04             	mov    0x4(%eax),%edx
c0108f1c:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0108f1f:	89 10                	mov    %edx,(%eax)
}
c0108f21:	90                   	nop
c0108f22:	c7 45 b4 4c 41 1b c0 	movl   $0xc01b414c,-0x4c(%ebp)
    return list->next == list;
c0108f29:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0108f2c:	8b 40 04             	mov    0x4(%eax),%eax
c0108f2f:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
c0108f32:	0f 94 c0             	sete   %al
c0108f35:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0108f38:	85 c0                	test   %eax,%eax
c0108f3a:	75 24                	jne    c0108f60 <default_check+0x1d3>
c0108f3c:	c7 44 24 0c 6f e1 10 	movl   $0xc010e16f,0xc(%esp)
c0108f43:	c0 
c0108f44:	c7 44 24 08 e6 df 10 	movl   $0xc010dfe6,0x8(%esp)
c0108f4b:	c0 
c0108f4c:	c7 44 24 04 22 01 00 	movl   $0x122,0x4(%esp)
c0108f53:	00 
c0108f54:	c7 04 24 fb df 10 c0 	movl   $0xc010dffb,(%esp)
c0108f5b:	e8 dd 74 ff ff       	call   c010043d <__panic>
    assert(alloc_page() == NULL);
c0108f60:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0108f67:	e8 09 aa ff ff       	call   c0103975 <alloc_pages>
c0108f6c:	85 c0                	test   %eax,%eax
c0108f6e:	74 24                	je     c0108f94 <default_check+0x207>
c0108f70:	c7 44 24 0c 86 e1 10 	movl   $0xc010e186,0xc(%esp)
c0108f77:	c0 
c0108f78:	c7 44 24 08 e6 df 10 	movl   $0xc010dfe6,0x8(%esp)
c0108f7f:	c0 
c0108f80:	c7 44 24 04 23 01 00 	movl   $0x123,0x4(%esp)
c0108f87:	00 
c0108f88:	c7 04 24 fb df 10 c0 	movl   $0xc010dffb,(%esp)
c0108f8f:	e8 a9 74 ff ff       	call   c010043d <__panic>

    unsigned int nr_free_store = nr_free;
c0108f94:	a1 54 41 1b c0       	mov    0xc01b4154,%eax
c0108f99:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nr_free = 0;
c0108f9c:	c7 05 54 41 1b c0 00 	movl   $0x0,0xc01b4154
c0108fa3:	00 00 00 

    free_pages(p0 + 2, 3);
c0108fa6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108fa9:	83 c0 40             	add    $0x40,%eax
c0108fac:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0108fb3:	00 
c0108fb4:	89 04 24             	mov    %eax,(%esp)
c0108fb7:	e8 28 aa ff ff       	call   c01039e4 <free_pages>
    assert(alloc_pages(4) == NULL);
c0108fbc:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0108fc3:	e8 ad a9 ff ff       	call   c0103975 <alloc_pages>
c0108fc8:	85 c0                	test   %eax,%eax
c0108fca:	74 24                	je     c0108ff0 <default_check+0x263>
c0108fcc:	c7 44 24 0c 2c e2 10 	movl   $0xc010e22c,0xc(%esp)
c0108fd3:	c0 
c0108fd4:	c7 44 24 08 e6 df 10 	movl   $0xc010dfe6,0x8(%esp)
c0108fdb:	c0 
c0108fdc:	c7 44 24 04 29 01 00 	movl   $0x129,0x4(%esp)
c0108fe3:	00 
c0108fe4:	c7 04 24 fb df 10 c0 	movl   $0xc010dffb,(%esp)
c0108feb:	e8 4d 74 ff ff       	call   c010043d <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c0108ff0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108ff3:	83 c0 40             	add    $0x40,%eax
c0108ff6:	83 c0 04             	add    $0x4,%eax
c0108ff9:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c0109000:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0109003:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0109006:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0109009:	0f a3 10             	bt     %edx,(%eax)
c010900c:	19 c0                	sbb    %eax,%eax
c010900e:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c0109011:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0109015:	0f 95 c0             	setne  %al
c0109018:	0f b6 c0             	movzbl %al,%eax
c010901b:	85 c0                	test   %eax,%eax
c010901d:	74 0e                	je     c010902d <default_check+0x2a0>
c010901f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109022:	83 c0 40             	add    $0x40,%eax
c0109025:	8b 40 08             	mov    0x8(%eax),%eax
c0109028:	83 f8 03             	cmp    $0x3,%eax
c010902b:	74 24                	je     c0109051 <default_check+0x2c4>
c010902d:	c7 44 24 0c 44 e2 10 	movl   $0xc010e244,0xc(%esp)
c0109034:	c0 
c0109035:	c7 44 24 08 e6 df 10 	movl   $0xc010dfe6,0x8(%esp)
c010903c:	c0 
c010903d:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
c0109044:	00 
c0109045:	c7 04 24 fb df 10 c0 	movl   $0xc010dffb,(%esp)
c010904c:	e8 ec 73 ff ff       	call   c010043d <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c0109051:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c0109058:	e8 18 a9 ff ff       	call   c0103975 <alloc_pages>
c010905d:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0109060:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0109064:	75 24                	jne    c010908a <default_check+0x2fd>
c0109066:	c7 44 24 0c 70 e2 10 	movl   $0xc010e270,0xc(%esp)
c010906d:	c0 
c010906e:	c7 44 24 08 e6 df 10 	movl   $0xc010dfe6,0x8(%esp)
c0109075:	c0 
c0109076:	c7 44 24 04 2b 01 00 	movl   $0x12b,0x4(%esp)
c010907d:	00 
c010907e:	c7 04 24 fb df 10 c0 	movl   $0xc010dffb,(%esp)
c0109085:	e8 b3 73 ff ff       	call   c010043d <__panic>
    assert(alloc_page() == NULL);
c010908a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0109091:	e8 df a8 ff ff       	call   c0103975 <alloc_pages>
c0109096:	85 c0                	test   %eax,%eax
c0109098:	74 24                	je     c01090be <default_check+0x331>
c010909a:	c7 44 24 0c 86 e1 10 	movl   $0xc010e186,0xc(%esp)
c01090a1:	c0 
c01090a2:	c7 44 24 08 e6 df 10 	movl   $0xc010dfe6,0x8(%esp)
c01090a9:	c0 
c01090aa:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
c01090b1:	00 
c01090b2:	c7 04 24 fb df 10 c0 	movl   $0xc010dffb,(%esp)
c01090b9:	e8 7f 73 ff ff       	call   c010043d <__panic>
    assert(p0 + 2 == p1);
c01090be:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01090c1:	83 c0 40             	add    $0x40,%eax
c01090c4:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c01090c7:	74 24                	je     c01090ed <default_check+0x360>
c01090c9:	c7 44 24 0c 8e e2 10 	movl   $0xc010e28e,0xc(%esp)
c01090d0:	c0 
c01090d1:	c7 44 24 08 e6 df 10 	movl   $0xc010dfe6,0x8(%esp)
c01090d8:	c0 
c01090d9:	c7 44 24 04 2d 01 00 	movl   $0x12d,0x4(%esp)
c01090e0:	00 
c01090e1:	c7 04 24 fb df 10 c0 	movl   $0xc010dffb,(%esp)
c01090e8:	e8 50 73 ff ff       	call   c010043d <__panic>

    p2 = p0 + 1;
c01090ed:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01090f0:	83 c0 20             	add    $0x20,%eax
c01090f3:	89 45 dc             	mov    %eax,-0x24(%ebp)
    free_page(p0);
c01090f6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01090fd:	00 
c01090fe:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109101:	89 04 24             	mov    %eax,(%esp)
c0109104:	e8 db a8 ff ff       	call   c01039e4 <free_pages>
    free_pages(p1, 3);
c0109109:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0109110:	00 
c0109111:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109114:	89 04 24             	mov    %eax,(%esp)
c0109117:	e8 c8 a8 ff ff       	call   c01039e4 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c010911c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010911f:	83 c0 04             	add    $0x4,%eax
c0109122:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c0109129:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010912c:	8b 45 9c             	mov    -0x64(%ebp),%eax
c010912f:	8b 55 a0             	mov    -0x60(%ebp),%edx
c0109132:	0f a3 10             	bt     %edx,(%eax)
c0109135:	19 c0                	sbb    %eax,%eax
c0109137:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c010913a:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c010913e:	0f 95 c0             	setne  %al
c0109141:	0f b6 c0             	movzbl %al,%eax
c0109144:	85 c0                	test   %eax,%eax
c0109146:	74 0b                	je     c0109153 <default_check+0x3c6>
c0109148:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010914b:	8b 40 08             	mov    0x8(%eax),%eax
c010914e:	83 f8 01             	cmp    $0x1,%eax
c0109151:	74 24                	je     c0109177 <default_check+0x3ea>
c0109153:	c7 44 24 0c 9c e2 10 	movl   $0xc010e29c,0xc(%esp)
c010915a:	c0 
c010915b:	c7 44 24 08 e6 df 10 	movl   $0xc010dfe6,0x8(%esp)
c0109162:	c0 
c0109163:	c7 44 24 04 32 01 00 	movl   $0x132,0x4(%esp)
c010916a:	00 
c010916b:	c7 04 24 fb df 10 c0 	movl   $0xc010dffb,(%esp)
c0109172:	e8 c6 72 ff ff       	call   c010043d <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c0109177:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010917a:	83 c0 04             	add    $0x4,%eax
c010917d:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c0109184:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0109187:	8b 45 90             	mov    -0x70(%ebp),%eax
c010918a:	8b 55 94             	mov    -0x6c(%ebp),%edx
c010918d:	0f a3 10             	bt     %edx,(%eax)
c0109190:	19 c0                	sbb    %eax,%eax
c0109192:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c0109195:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c0109199:	0f 95 c0             	setne  %al
c010919c:	0f b6 c0             	movzbl %al,%eax
c010919f:	85 c0                	test   %eax,%eax
c01091a1:	74 0b                	je     c01091ae <default_check+0x421>
c01091a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01091a6:	8b 40 08             	mov    0x8(%eax),%eax
c01091a9:	83 f8 03             	cmp    $0x3,%eax
c01091ac:	74 24                	je     c01091d2 <default_check+0x445>
c01091ae:	c7 44 24 0c c4 e2 10 	movl   $0xc010e2c4,0xc(%esp)
c01091b5:	c0 
c01091b6:	c7 44 24 08 e6 df 10 	movl   $0xc010dfe6,0x8(%esp)
c01091bd:	c0 
c01091be:	c7 44 24 04 33 01 00 	movl   $0x133,0x4(%esp)
c01091c5:	00 
c01091c6:	c7 04 24 fb df 10 c0 	movl   $0xc010dffb,(%esp)
c01091cd:	e8 6b 72 ff ff       	call   c010043d <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c01091d2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01091d9:	e8 97 a7 ff ff       	call   c0103975 <alloc_pages>
c01091de:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01091e1:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01091e4:	83 e8 20             	sub    $0x20,%eax
c01091e7:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c01091ea:	74 24                	je     c0109210 <default_check+0x483>
c01091ec:	c7 44 24 0c ea e2 10 	movl   $0xc010e2ea,0xc(%esp)
c01091f3:	c0 
c01091f4:	c7 44 24 08 e6 df 10 	movl   $0xc010dfe6,0x8(%esp)
c01091fb:	c0 
c01091fc:	c7 44 24 04 35 01 00 	movl   $0x135,0x4(%esp)
c0109203:	00 
c0109204:	c7 04 24 fb df 10 c0 	movl   $0xc010dffb,(%esp)
c010920b:	e8 2d 72 ff ff       	call   c010043d <__panic>
    free_page(p0);
c0109210:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0109217:	00 
c0109218:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010921b:	89 04 24             	mov    %eax,(%esp)
c010921e:	e8 c1 a7 ff ff       	call   c01039e4 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c0109223:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c010922a:	e8 46 a7 ff ff       	call   c0103975 <alloc_pages>
c010922f:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0109232:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0109235:	83 c0 20             	add    $0x20,%eax
c0109238:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c010923b:	74 24                	je     c0109261 <default_check+0x4d4>
c010923d:	c7 44 24 0c 08 e3 10 	movl   $0xc010e308,0xc(%esp)
c0109244:	c0 
c0109245:	c7 44 24 08 e6 df 10 	movl   $0xc010dfe6,0x8(%esp)
c010924c:	c0 
c010924d:	c7 44 24 04 37 01 00 	movl   $0x137,0x4(%esp)
c0109254:	00 
c0109255:	c7 04 24 fb df 10 c0 	movl   $0xc010dffb,(%esp)
c010925c:	e8 dc 71 ff ff       	call   c010043d <__panic>

    free_pages(p0, 2);
c0109261:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0109268:	00 
c0109269:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010926c:	89 04 24             	mov    %eax,(%esp)
c010926f:	e8 70 a7 ff ff       	call   c01039e4 <free_pages>
    free_page(p2);
c0109274:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010927b:	00 
c010927c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010927f:	89 04 24             	mov    %eax,(%esp)
c0109282:	e8 5d a7 ff ff       	call   c01039e4 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c0109287:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c010928e:	e8 e2 a6 ff ff       	call   c0103975 <alloc_pages>
c0109293:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0109296:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010929a:	75 24                	jne    c01092c0 <default_check+0x533>
c010929c:	c7 44 24 0c 28 e3 10 	movl   $0xc010e328,0xc(%esp)
c01092a3:	c0 
c01092a4:	c7 44 24 08 e6 df 10 	movl   $0xc010dfe6,0x8(%esp)
c01092ab:	c0 
c01092ac:	c7 44 24 04 3c 01 00 	movl   $0x13c,0x4(%esp)
c01092b3:	00 
c01092b4:	c7 04 24 fb df 10 c0 	movl   $0xc010dffb,(%esp)
c01092bb:	e8 7d 71 ff ff       	call   c010043d <__panic>
    assert(alloc_page() == NULL);
c01092c0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01092c7:	e8 a9 a6 ff ff       	call   c0103975 <alloc_pages>
c01092cc:	85 c0                	test   %eax,%eax
c01092ce:	74 24                	je     c01092f4 <default_check+0x567>
c01092d0:	c7 44 24 0c 86 e1 10 	movl   $0xc010e186,0xc(%esp)
c01092d7:	c0 
c01092d8:	c7 44 24 08 e6 df 10 	movl   $0xc010dfe6,0x8(%esp)
c01092df:	c0 
c01092e0:	c7 44 24 04 3d 01 00 	movl   $0x13d,0x4(%esp)
c01092e7:	00 
c01092e8:	c7 04 24 fb df 10 c0 	movl   $0xc010dffb,(%esp)
c01092ef:	e8 49 71 ff ff       	call   c010043d <__panic>

    assert(nr_free == 0);
c01092f4:	a1 54 41 1b c0       	mov    0xc01b4154,%eax
c01092f9:	85 c0                	test   %eax,%eax
c01092fb:	74 24                	je     c0109321 <default_check+0x594>
c01092fd:	c7 44 24 0c d9 e1 10 	movl   $0xc010e1d9,0xc(%esp)
c0109304:	c0 
c0109305:	c7 44 24 08 e6 df 10 	movl   $0xc010dfe6,0x8(%esp)
c010930c:	c0 
c010930d:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
c0109314:	00 
c0109315:	c7 04 24 fb df 10 c0 	movl   $0xc010dffb,(%esp)
c010931c:	e8 1c 71 ff ff       	call   c010043d <__panic>
    nr_free = nr_free_store;
c0109321:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109324:	a3 54 41 1b c0       	mov    %eax,0xc01b4154

    free_list = free_list_store;
c0109329:	8b 45 80             	mov    -0x80(%ebp),%eax
c010932c:	8b 55 84             	mov    -0x7c(%ebp),%edx
c010932f:	a3 4c 41 1b c0       	mov    %eax,0xc01b414c
c0109334:	89 15 50 41 1b c0    	mov    %edx,0xc01b4150
    free_pages(p0, 5);
c010933a:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c0109341:	00 
c0109342:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109345:	89 04 24             	mov    %eax,(%esp)
c0109348:	e8 97 a6 ff ff       	call   c01039e4 <free_pages>

    le = &free_list;
c010934d:	c7 45 ec 4c 41 1b c0 	movl   $0xc01b414c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list)
c0109354:	eb 1c                	jmp    c0109372 <default_check+0x5e5>
    {
        struct Page *p = le2page(le, page_link);
c0109356:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109359:	83 e8 0c             	sub    $0xc,%eax
c010935c:	89 45 d8             	mov    %eax,-0x28(%ebp)
        count--, total -= p->property;
c010935f:	ff 4d f4             	decl   -0xc(%ebp)
c0109362:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0109365:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0109368:	8b 40 08             	mov    0x8(%eax),%eax
c010936b:	29 c2                	sub    %eax,%edx
c010936d:	89 d0                	mov    %edx,%eax
c010936f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109372:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109375:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
c0109378:	8b 45 88             	mov    -0x78(%ebp),%eax
c010937b:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list)
c010937e:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0109381:	81 7d ec 4c 41 1b c0 	cmpl   $0xc01b414c,-0x14(%ebp)
c0109388:	75 cc                	jne    c0109356 <default_check+0x5c9>
    }
    assert(count == 0);
c010938a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010938e:	74 24                	je     c01093b4 <default_check+0x627>
c0109390:	c7 44 24 0c 46 e3 10 	movl   $0xc010e346,0xc(%esp)
c0109397:	c0 
c0109398:	c7 44 24 08 e6 df 10 	movl   $0xc010dfe6,0x8(%esp)
c010939f:	c0 
c01093a0:	c7 44 24 04 4b 01 00 	movl   $0x14b,0x4(%esp)
c01093a7:	00 
c01093a8:	c7 04 24 fb df 10 c0 	movl   $0xc010dffb,(%esp)
c01093af:	e8 89 70 ff ff       	call   c010043d <__panic>
    assert(total == 0);
c01093b4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01093b8:	74 24                	je     c01093de <default_check+0x651>
c01093ba:	c7 44 24 0c 51 e3 10 	movl   $0xc010e351,0xc(%esp)
c01093c1:	c0 
c01093c2:	c7 44 24 08 e6 df 10 	movl   $0xc010dfe6,0x8(%esp)
c01093c9:	c0 
c01093ca:	c7 44 24 04 4c 01 00 	movl   $0x14c,0x4(%esp)
c01093d1:	00 
c01093d2:	c7 04 24 fb df 10 c0 	movl   $0xc010dffb,(%esp)
c01093d9:	e8 5f 70 ff ff       	call   c010043d <__panic>
}
c01093de:	90                   	nop
c01093df:	c9                   	leave  
c01093e0:	c3                   	ret    

c01093e1 <page2ppn>:
page2ppn(struct Page *page) {
c01093e1:	55                   	push   %ebp
c01093e2:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01093e4:	a1 60 40 1b c0       	mov    0xc01b4060,%eax
c01093e9:	8b 55 08             	mov    0x8(%ebp),%edx
c01093ec:	29 c2                	sub    %eax,%edx
c01093ee:	89 d0                	mov    %edx,%eax
c01093f0:	c1 f8 05             	sar    $0x5,%eax
}
c01093f3:	5d                   	pop    %ebp
c01093f4:	c3                   	ret    

c01093f5 <page2pa>:
page2pa(struct Page *page) {
c01093f5:	55                   	push   %ebp
c01093f6:	89 e5                	mov    %esp,%ebp
c01093f8:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01093fb:	8b 45 08             	mov    0x8(%ebp),%eax
c01093fe:	89 04 24             	mov    %eax,(%esp)
c0109401:	e8 db ff ff ff       	call   c01093e1 <page2ppn>
c0109406:	c1 e0 0c             	shl    $0xc,%eax
}
c0109409:	c9                   	leave  
c010940a:	c3                   	ret    

c010940b <page2kva>:
page2kva(struct Page *page) {
c010940b:	55                   	push   %ebp
c010940c:	89 e5                	mov    %esp,%ebp
c010940e:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0109411:	8b 45 08             	mov    0x8(%ebp),%eax
c0109414:	89 04 24             	mov    %eax,(%esp)
c0109417:	e8 d9 ff ff ff       	call   c01093f5 <page2pa>
c010941c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010941f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109422:	c1 e8 0c             	shr    $0xc,%eax
c0109425:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109428:	a1 80 1f 1b c0       	mov    0xc01b1f80,%eax
c010942d:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0109430:	72 23                	jb     c0109455 <page2kva+0x4a>
c0109432:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109435:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109439:	c7 44 24 08 8c e3 10 	movl   $0xc010e38c,0x8(%esp)
c0109440:	c0 
c0109441:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c0109448:	00 
c0109449:	c7 04 24 af e3 10 c0 	movl   $0xc010e3af,(%esp)
c0109450:	e8 e8 6f ff ff       	call   c010043d <__panic>
c0109455:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109458:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c010945d:	c9                   	leave  
c010945e:	c3                   	ret    

c010945f <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
c010945f:	f3 0f 1e fb          	endbr32 
c0109463:	55                   	push   %ebp
c0109464:	89 e5                	mov    %esp,%ebp
c0109466:	83 ec 18             	sub    $0x18,%esp
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
c0109469:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0109470:	e8 ec 7d ff ff       	call   c0101261 <ide_device_valid>
c0109475:	85 c0                	test   %eax,%eax
c0109477:	75 1c                	jne    c0109495 <swapfs_init+0x36>
        panic("swap fs isn't available.\n");
c0109479:	c7 44 24 08 bd e3 10 	movl   $0xc010e3bd,0x8(%esp)
c0109480:	c0 
c0109481:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
c0109488:	00 
c0109489:	c7 04 24 d7 e3 10 c0 	movl   $0xc010e3d7,(%esp)
c0109490:	e8 a8 6f ff ff       	call   c010043d <__panic>
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
c0109495:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010949c:	e8 02 7e ff ff       	call   c01012a3 <ide_device_size>
c01094a1:	c1 e8 03             	shr    $0x3,%eax
c01094a4:	a3 1c 41 1b c0       	mov    %eax,0xc01b411c
}
c01094a9:	90                   	nop
c01094aa:	c9                   	leave  
c01094ab:	c3                   	ret    

c01094ac <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
c01094ac:	f3 0f 1e fb          	endbr32 
c01094b0:	55                   	push   %ebp
c01094b1:	89 e5                	mov    %esp,%ebp
c01094b3:	83 ec 28             	sub    $0x28,%esp
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c01094b6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01094b9:	89 04 24             	mov    %eax,(%esp)
c01094bc:	e8 4a ff ff ff       	call   c010940b <page2kva>
c01094c1:	8b 55 08             	mov    0x8(%ebp),%edx
c01094c4:	c1 ea 08             	shr    $0x8,%edx
c01094c7:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01094ca:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01094ce:	74 0b                	je     c01094db <swapfs_read+0x2f>
c01094d0:	8b 15 1c 41 1b c0    	mov    0xc01b411c,%edx
c01094d6:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c01094d9:	72 23                	jb     c01094fe <swapfs_read+0x52>
c01094db:	8b 45 08             	mov    0x8(%ebp),%eax
c01094de:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01094e2:	c7 44 24 08 e8 e3 10 	movl   $0xc010e3e8,0x8(%esp)
c01094e9:	c0 
c01094ea:	c7 44 24 04 14 00 00 	movl   $0x14,0x4(%esp)
c01094f1:	00 
c01094f2:	c7 04 24 d7 e3 10 c0 	movl   $0xc010e3d7,(%esp)
c01094f9:	e8 3f 6f ff ff       	call   c010043d <__panic>
c01094fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109501:	c1 e2 03             	shl    $0x3,%edx
c0109504:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c010950b:	00 
c010950c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109510:	89 54 24 04          	mov    %edx,0x4(%esp)
c0109514:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010951b:	e8 c2 7d ff ff       	call   c01012e2 <ide_read_secs>
}
c0109520:	c9                   	leave  
c0109521:	c3                   	ret    

c0109522 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
c0109522:	f3 0f 1e fb          	endbr32 
c0109526:	55                   	push   %ebp
c0109527:	89 e5                	mov    %esp,%ebp
c0109529:	83 ec 28             	sub    $0x28,%esp
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c010952c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010952f:	89 04 24             	mov    %eax,(%esp)
c0109532:	e8 d4 fe ff ff       	call   c010940b <page2kva>
c0109537:	8b 55 08             	mov    0x8(%ebp),%edx
c010953a:	c1 ea 08             	shr    $0x8,%edx
c010953d:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0109540:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109544:	74 0b                	je     c0109551 <swapfs_write+0x2f>
c0109546:	8b 15 1c 41 1b c0    	mov    0xc01b411c,%edx
c010954c:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c010954f:	72 23                	jb     c0109574 <swapfs_write+0x52>
c0109551:	8b 45 08             	mov    0x8(%ebp),%eax
c0109554:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109558:	c7 44 24 08 e8 e3 10 	movl   $0xc010e3e8,0x8(%esp)
c010955f:	c0 
c0109560:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
c0109567:	00 
c0109568:	c7 04 24 d7 e3 10 c0 	movl   $0xc010e3d7,(%esp)
c010956f:	e8 c9 6e ff ff       	call   c010043d <__panic>
c0109574:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109577:	c1 e2 03             	shl    $0x3,%edx
c010957a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c0109581:	00 
c0109582:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109586:	89 54 24 04          	mov    %edx,0x4(%esp)
c010958a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0109591:	e8 91 7f ff ff       	call   c0101527 <ide_write_secs>
}
c0109596:	c9                   	leave  
c0109597:	c3                   	ret    

c0109598 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)

    pushl %edx              # push arg
c0109598:	52                   	push   %edx
    call *%ebx              # call fn
c0109599:	ff d3                	call   *%ebx

    pushl %eax              # save the return value of fn(arg)
c010959b:	50                   	push   %eax
    call do_exit            # call do_exit to terminate current thread
c010959c:	e8 20 0d 00 00       	call   c010a2c1 <do_exit>

c01095a1 <switch_to>:
.text
.globl switch_to
switch_to:                      # switch_to(from, to)

    # save from's registers
    movl 4(%esp), %eax          # eax points to from
c01095a1:	8b 44 24 04          	mov    0x4(%esp),%eax
    popl 0(%eax)                # save eip !popl
c01095a5:	8f 00                	popl   (%eax)
    movl %esp, 4(%eax)
c01095a7:	89 60 04             	mov    %esp,0x4(%eax)
    movl %ebx, 8(%eax)
c01095aa:	89 58 08             	mov    %ebx,0x8(%eax)
    movl %ecx, 12(%eax)
c01095ad:	89 48 0c             	mov    %ecx,0xc(%eax)
    movl %edx, 16(%eax)
c01095b0:	89 50 10             	mov    %edx,0x10(%eax)
    movl %esi, 20(%eax)
c01095b3:	89 70 14             	mov    %esi,0x14(%eax)
    movl %edi, 24(%eax)
c01095b6:	89 78 18             	mov    %edi,0x18(%eax)
    movl %ebp, 28(%eax)
c01095b9:	89 68 1c             	mov    %ebp,0x1c(%eax)

    # restore to's registers
    movl 4(%esp), %eax          # not 8(%esp): popped return address already
c01095bc:	8b 44 24 04          	mov    0x4(%esp),%eax
                                # eax now points to to
    movl 28(%eax), %ebp
c01095c0:	8b 68 1c             	mov    0x1c(%eax),%ebp
    movl 24(%eax), %edi
c01095c3:	8b 78 18             	mov    0x18(%eax),%edi
    movl 20(%eax), %esi
c01095c6:	8b 70 14             	mov    0x14(%eax),%esi
    movl 16(%eax), %edx
c01095c9:	8b 50 10             	mov    0x10(%eax),%edx
    movl 12(%eax), %ecx
c01095cc:	8b 48 0c             	mov    0xc(%eax),%ecx
    movl 8(%eax), %ebx
c01095cf:	8b 58 08             	mov    0x8(%eax),%ebx
    movl 4(%eax), %esp
c01095d2:	8b 60 04             	mov    0x4(%eax),%esp

    pushl 0(%eax)               # push eip
c01095d5:	ff 30                	pushl  (%eax)

    ret
c01095d7:	c3                   	ret    

c01095d8 <test_and_set_bit>:
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool
test_and_set_bit(int nr, volatile void *addr) {
c01095d8:	55                   	push   %ebp
c01095d9:	89 e5                	mov    %esp,%ebp
c01095db:	83 ec 10             	sub    $0x10,%esp
    int oldbit;
    asm volatile ("btsl %2, %1; sbbl %0, %0" : "=r" (oldbit), "=m" (*(volatile long *)addr) : "Ir" (nr) : "memory");
c01095de:	8b 55 0c             	mov    0xc(%ebp),%edx
c01095e1:	8b 45 08             	mov    0x8(%ebp),%eax
c01095e4:	0f ab 02             	bts    %eax,(%edx)
c01095e7:	19 c0                	sbb    %eax,%eax
c01095e9:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return oldbit != 0;
c01095ec:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c01095f0:	0f 95 c0             	setne  %al
c01095f3:	0f b6 c0             	movzbl %al,%eax
}
c01095f6:	c9                   	leave  
c01095f7:	c3                   	ret    

c01095f8 <test_and_clear_bit>:
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool
test_and_clear_bit(int nr, volatile void *addr) {
c01095f8:	55                   	push   %ebp
c01095f9:	89 e5                	mov    %esp,%ebp
c01095fb:	83 ec 10             	sub    $0x10,%esp
    int oldbit;
    asm volatile ("btrl %2, %1; sbbl %0, %0" : "=r" (oldbit), "=m" (*(volatile long *)addr) : "Ir" (nr) : "memory");
c01095fe:	8b 55 0c             	mov    0xc(%ebp),%edx
c0109601:	8b 45 08             	mov    0x8(%ebp),%eax
c0109604:	0f b3 02             	btr    %eax,(%edx)
c0109607:	19 c0                	sbb    %eax,%eax
c0109609:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return oldbit != 0;
c010960c:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0109610:	0f 95 c0             	setne  %al
c0109613:	0f b6 c0             	movzbl %al,%eax
}
c0109616:	c9                   	leave  
c0109617:	c3                   	ret    

c0109618 <__intr_save>:
__intr_save(void) {
c0109618:	55                   	push   %ebp
c0109619:	89 e5                	mov    %esp,%ebp
c010961b:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c010961e:	9c                   	pushf  
c010961f:	58                   	pop    %eax
c0109620:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0109623:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0109626:	25 00 02 00 00       	and    $0x200,%eax
c010962b:	85 c0                	test   %eax,%eax
c010962d:	74 0c                	je     c010963b <__intr_save+0x23>
        intr_disable();
c010962f:	e8 c4 8c ff ff       	call   c01022f8 <intr_disable>
        return 1;
c0109634:	b8 01 00 00 00       	mov    $0x1,%eax
c0109639:	eb 05                	jmp    c0109640 <__intr_save+0x28>
    return 0;
c010963b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109640:	c9                   	leave  
c0109641:	c3                   	ret    

c0109642 <__intr_restore>:
__intr_restore(bool flag) {
c0109642:	55                   	push   %ebp
c0109643:	89 e5                	mov    %esp,%ebp
c0109645:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0109648:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010964c:	74 05                	je     c0109653 <__intr_restore+0x11>
        intr_enable();
c010964e:	e8 99 8c ff ff       	call   c01022ec <intr_enable>
}
c0109653:	90                   	nop
c0109654:	c9                   	leave  
c0109655:	c3                   	ret    

c0109656 <try_lock>:

static inline bool
try_lock(lock_t *lock) {
c0109656:	55                   	push   %ebp
c0109657:	89 e5                	mov    %esp,%ebp
c0109659:	83 ec 08             	sub    $0x8,%esp
    return !test_and_set_bit(0, lock);
c010965c:	8b 45 08             	mov    0x8(%ebp),%eax
c010965f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109663:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010966a:	e8 69 ff ff ff       	call   c01095d8 <test_and_set_bit>
c010966f:	85 c0                	test   %eax,%eax
c0109671:	0f 94 c0             	sete   %al
c0109674:	0f b6 c0             	movzbl %al,%eax
}
c0109677:	c9                   	leave  
c0109678:	c3                   	ret    

c0109679 <lock>:

static inline void
lock(lock_t *lock) {
c0109679:	55                   	push   %ebp
c010967a:	89 e5                	mov    %esp,%ebp
c010967c:	83 ec 18             	sub    $0x18,%esp
    while (!try_lock(lock)) {
c010967f:	eb 05                	jmp    c0109686 <lock+0xd>
        schedule();
c0109681:	e8 f2 1c 00 00       	call   c010b378 <schedule>
    while (!try_lock(lock)) {
c0109686:	8b 45 08             	mov    0x8(%ebp),%eax
c0109689:	89 04 24             	mov    %eax,(%esp)
c010968c:	e8 c5 ff ff ff       	call   c0109656 <try_lock>
c0109691:	85 c0                	test   %eax,%eax
c0109693:	74 ec                	je     c0109681 <lock+0x8>
    }
}
c0109695:	90                   	nop
c0109696:	90                   	nop
c0109697:	c9                   	leave  
c0109698:	c3                   	ret    

c0109699 <unlock>:

static inline void
unlock(lock_t *lock) {
c0109699:	55                   	push   %ebp
c010969a:	89 e5                	mov    %esp,%ebp
c010969c:	83 ec 18             	sub    $0x18,%esp
    if (!test_and_clear_bit(0, lock)) {
c010969f:	8b 45 08             	mov    0x8(%ebp),%eax
c01096a2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01096a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01096ad:	e8 46 ff ff ff       	call   c01095f8 <test_and_clear_bit>
c01096b2:	85 c0                	test   %eax,%eax
c01096b4:	75 1c                	jne    c01096d2 <unlock+0x39>
        panic("Unlock failed.\n");
c01096b6:	c7 44 24 08 08 e4 10 	movl   $0xc010e408,0x8(%esp)
c01096bd:	c0 
c01096be:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
c01096c5:	00 
c01096c6:	c7 04 24 18 e4 10 c0 	movl   $0xc010e418,(%esp)
c01096cd:	e8 6b 6d ff ff       	call   c010043d <__panic>
    }
}
c01096d2:	90                   	nop
c01096d3:	c9                   	leave  
c01096d4:	c3                   	ret    

c01096d5 <page2ppn>:
page2ppn(struct Page *page) {
c01096d5:	55                   	push   %ebp
c01096d6:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01096d8:	a1 60 40 1b c0       	mov    0xc01b4060,%eax
c01096dd:	8b 55 08             	mov    0x8(%ebp),%edx
c01096e0:	29 c2                	sub    %eax,%edx
c01096e2:	89 d0                	mov    %edx,%eax
c01096e4:	c1 f8 05             	sar    $0x5,%eax
}
c01096e7:	5d                   	pop    %ebp
c01096e8:	c3                   	ret    

c01096e9 <page2pa>:
page2pa(struct Page *page) {
c01096e9:	55                   	push   %ebp
c01096ea:	89 e5                	mov    %esp,%ebp
c01096ec:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01096ef:	8b 45 08             	mov    0x8(%ebp),%eax
c01096f2:	89 04 24             	mov    %eax,(%esp)
c01096f5:	e8 db ff ff ff       	call   c01096d5 <page2ppn>
c01096fa:	c1 e0 0c             	shl    $0xc,%eax
}
c01096fd:	c9                   	leave  
c01096fe:	c3                   	ret    

c01096ff <pa2page>:
pa2page(uintptr_t pa) {
c01096ff:	55                   	push   %ebp
c0109700:	89 e5                	mov    %esp,%ebp
c0109702:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0109705:	8b 45 08             	mov    0x8(%ebp),%eax
c0109708:	c1 e8 0c             	shr    $0xc,%eax
c010970b:	89 c2                	mov    %eax,%edx
c010970d:	a1 80 1f 1b c0       	mov    0xc01b1f80,%eax
c0109712:	39 c2                	cmp    %eax,%edx
c0109714:	72 1c                	jb     c0109732 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0109716:	c7 44 24 08 2c e4 10 	movl   $0xc010e42c,0x8(%esp)
c010971d:	c0 
c010971e:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c0109725:	00 
c0109726:	c7 04 24 4b e4 10 c0 	movl   $0xc010e44b,(%esp)
c010972d:	e8 0b 6d ff ff       	call   c010043d <__panic>
    return &pages[PPN(pa)];
c0109732:	a1 60 40 1b c0       	mov    0xc01b4060,%eax
c0109737:	8b 55 08             	mov    0x8(%ebp),%edx
c010973a:	c1 ea 0c             	shr    $0xc,%edx
c010973d:	c1 e2 05             	shl    $0x5,%edx
c0109740:	01 d0                	add    %edx,%eax
}
c0109742:	c9                   	leave  
c0109743:	c3                   	ret    

c0109744 <page2kva>:
page2kva(struct Page *page) {
c0109744:	55                   	push   %ebp
c0109745:	89 e5                	mov    %esp,%ebp
c0109747:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c010974a:	8b 45 08             	mov    0x8(%ebp),%eax
c010974d:	89 04 24             	mov    %eax,(%esp)
c0109750:	e8 94 ff ff ff       	call   c01096e9 <page2pa>
c0109755:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109758:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010975b:	c1 e8 0c             	shr    $0xc,%eax
c010975e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109761:	a1 80 1f 1b c0       	mov    0xc01b1f80,%eax
c0109766:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0109769:	72 23                	jb     c010978e <page2kva+0x4a>
c010976b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010976e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109772:	c7 44 24 08 5c e4 10 	movl   $0xc010e45c,0x8(%esp)
c0109779:	c0 
c010977a:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c0109781:	00 
c0109782:	c7 04 24 4b e4 10 c0 	movl   $0xc010e44b,(%esp)
c0109789:	e8 af 6c ff ff       	call   c010043d <__panic>
c010978e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109791:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0109796:	c9                   	leave  
c0109797:	c3                   	ret    

c0109798 <kva2page>:
kva2page(void *kva) {
c0109798:	55                   	push   %ebp
c0109799:	89 e5                	mov    %esp,%ebp
c010979b:	83 ec 28             	sub    $0x28,%esp
    return pa2page(PADDR(kva));
c010979e:	8b 45 08             	mov    0x8(%ebp),%eax
c01097a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01097a4:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01097ab:	77 23                	ja     c01097d0 <kva2page+0x38>
c01097ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01097b0:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01097b4:	c7 44 24 08 80 e4 10 	movl   $0xc010e480,0x8(%esp)
c01097bb:	c0 
c01097bc:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
c01097c3:	00 
c01097c4:	c7 04 24 4b e4 10 c0 	movl   $0xc010e44b,(%esp)
c01097cb:	e8 6d 6c ff ff       	call   c010043d <__panic>
c01097d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01097d3:	05 00 00 00 40       	add    $0x40000000,%eax
c01097d8:	89 04 24             	mov    %eax,(%esp)
c01097db:	e8 1f ff ff ff       	call   c01096ff <pa2page>
}
c01097e0:	c9                   	leave  
c01097e1:	c3                   	ret    

c01097e2 <mm_count_inc>:

static inline int
mm_count_inc(struct mm_struct *mm) {
c01097e2:	55                   	push   %ebp
c01097e3:	89 e5                	mov    %esp,%ebp
    mm->mm_count += 1;
c01097e5:	8b 45 08             	mov    0x8(%ebp),%eax
c01097e8:	8b 40 18             	mov    0x18(%eax),%eax
c01097eb:	8d 50 01             	lea    0x1(%eax),%edx
c01097ee:	8b 45 08             	mov    0x8(%ebp),%eax
c01097f1:	89 50 18             	mov    %edx,0x18(%eax)
    return mm->mm_count;
c01097f4:	8b 45 08             	mov    0x8(%ebp),%eax
c01097f7:	8b 40 18             	mov    0x18(%eax),%eax
}
c01097fa:	5d                   	pop    %ebp
c01097fb:	c3                   	ret    

c01097fc <mm_count_dec>:

static inline int
mm_count_dec(struct mm_struct *mm) {
c01097fc:	55                   	push   %ebp
c01097fd:	89 e5                	mov    %esp,%ebp
    mm->mm_count -= 1;
c01097ff:	8b 45 08             	mov    0x8(%ebp),%eax
c0109802:	8b 40 18             	mov    0x18(%eax),%eax
c0109805:	8d 50 ff             	lea    -0x1(%eax),%edx
c0109808:	8b 45 08             	mov    0x8(%ebp),%eax
c010980b:	89 50 18             	mov    %edx,0x18(%eax)
    return mm->mm_count;
c010980e:	8b 45 08             	mov    0x8(%ebp),%eax
c0109811:	8b 40 18             	mov    0x18(%eax),%eax
}
c0109814:	5d                   	pop    %ebp
c0109815:	c3                   	ret    

c0109816 <lock_mm>:

static inline void
lock_mm(struct mm_struct *mm) {
c0109816:	55                   	push   %ebp
c0109817:	89 e5                	mov    %esp,%ebp
c0109819:	83 ec 18             	sub    $0x18,%esp
    if (mm != NULL) {
c010981c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0109820:	74 0e                	je     c0109830 <lock_mm+0x1a>
        lock(&(mm->mm_lock));
c0109822:	8b 45 08             	mov    0x8(%ebp),%eax
c0109825:	83 c0 1c             	add    $0x1c,%eax
c0109828:	89 04 24             	mov    %eax,(%esp)
c010982b:	e8 49 fe ff ff       	call   c0109679 <lock>
    }
}
c0109830:	90                   	nop
c0109831:	c9                   	leave  
c0109832:	c3                   	ret    

c0109833 <unlock_mm>:

static inline void
unlock_mm(struct mm_struct *mm) {
c0109833:	55                   	push   %ebp
c0109834:	89 e5                	mov    %esp,%ebp
c0109836:	83 ec 18             	sub    $0x18,%esp
    if (mm != NULL) {
c0109839:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010983d:	74 0e                	je     c010984d <unlock_mm+0x1a>
        unlock(&(mm->mm_lock));
c010983f:	8b 45 08             	mov    0x8(%ebp),%eax
c0109842:	83 c0 1c             	add    $0x1c,%eax
c0109845:	89 04 24             	mov    %eax,(%esp)
c0109848:	e8 4c fe ff ff       	call   c0109699 <unlock>
    }
}
c010984d:	90                   	nop
c010984e:	c9                   	leave  
c010984f:	c3                   	ret    

c0109850 <alloc_proc>:
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void)
{
c0109850:	f3 0f 1e fb          	endbr32 
c0109854:	55                   	push   %ebp
c0109855:	89 e5                	mov    %esp,%ebp
c0109857:	83 ec 28             	sub    $0x28,%esp
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
c010985a:	c7 04 24 7c 00 00 00 	movl   $0x7c,(%esp)
c0109861:	e8 a7 e2 ff ff       	call   c0107b0d <kmalloc>
c0109866:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (proc != NULL)
c0109869:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010986d:	0f 84 cd 00 00 00    	je     c0109940 <alloc_proc+0xf0>
     *       struct trapframe *tf;                       // Trap frame for current interrupt
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */
        proc->state = PROC_UNINIT;
c0109873:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109876:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        proc->pid = -1;
c010987c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010987f:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
        proc->runs = 0;
c0109886:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109889:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        proc->kstack = 0;
c0109890:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109893:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        proc->need_resched = 0;
c010989a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010989d:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        proc->parent = NULL;
c01098a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01098a7:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        proc->mm = NULL;
c01098ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01098b1:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
        memset(&(proc->context), 0, sizeof(struct context));
c01098b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01098bb:	83 c0 1c             	add    $0x1c,%eax
c01098be:	c7 44 24 08 20 00 00 	movl   $0x20,0x8(%esp)
c01098c5:	00 
c01098c6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01098cd:	00 
c01098ce:	89 04 24             	mov    %eax,(%esp)
c01098d1:	e8 d4 20 00 00       	call   c010b9aa <memset>
        proc->tf = NULL;
c01098d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01098d9:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
        proc->cr3 = boot_cr3;
c01098e0:	8b 15 5c 40 1b c0    	mov    0xc01b405c,%edx
c01098e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01098e9:	89 50 40             	mov    %edx,0x40(%eax)
        proc->flags = 0;
c01098ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01098ef:	c7 40 44 00 00 00 00 	movl   $0x0,0x44(%eax)
        memset(proc->name, 0, PROC_NAME_LEN);
c01098f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01098f9:	83 c0 48             	add    $0x48,%eax
c01098fc:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c0109903:	00 
c0109904:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010990b:	00 
c010990c:	89 04 24             	mov    %eax,(%esp)
c010990f:	e8 96 20 00 00       	call   c010b9aa <memset>
        proc->wait_state = 0;
c0109914:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109917:	c7 40 6c 00 00 00 00 	movl   $0x0,0x6c(%eax)
        proc->cptr = proc->optr = proc->yptr = NULL;
c010991e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109921:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)
c0109928:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010992b:	8b 50 74             	mov    0x74(%eax),%edx
c010992e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109931:	89 50 78             	mov    %edx,0x78(%eax)
c0109934:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109937:	8b 50 78             	mov    0x78(%eax),%edx
c010993a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010993d:	89 50 70             	mov    %edx,0x70(%eax)
    }
    return proc;
c0109940:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0109943:	c9                   	leave  
c0109944:	c3                   	ret    

c0109945 <set_proc_name>:

// set_proc_name - set the name of proc
char *
set_proc_name(struct proc_struct *proc, const char *name)
{
c0109945:	f3 0f 1e fb          	endbr32 
c0109949:	55                   	push   %ebp
c010994a:	89 e5                	mov    %esp,%ebp
c010994c:	83 ec 18             	sub    $0x18,%esp
    memset(proc->name, 0, sizeof(proc->name));
c010994f:	8b 45 08             	mov    0x8(%ebp),%eax
c0109952:	83 c0 48             	add    $0x48,%eax
c0109955:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c010995c:	00 
c010995d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0109964:	00 
c0109965:	89 04 24             	mov    %eax,(%esp)
c0109968:	e8 3d 20 00 00       	call   c010b9aa <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
c010996d:	8b 45 08             	mov    0x8(%ebp),%eax
c0109970:	8d 50 48             	lea    0x48(%eax),%edx
c0109973:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c010997a:	00 
c010997b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010997e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109982:	89 14 24             	mov    %edx,(%esp)
c0109985:	e8 0a 21 00 00       	call   c010ba94 <memcpy>
}
c010998a:	c9                   	leave  
c010998b:	c3                   	ret    

c010998c <get_proc_name>:

// get_proc_name - get the name of proc
char *
get_proc_name(struct proc_struct *proc)
{
c010998c:	f3 0f 1e fb          	endbr32 
c0109990:	55                   	push   %ebp
c0109991:	89 e5                	mov    %esp,%ebp
c0109993:	83 ec 18             	sub    $0x18,%esp
    static char name[PROC_NAME_LEN + 1];
    memset(name, 0, sizeof(name));
c0109996:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c010999d:	00 
c010999e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01099a5:	00 
c01099a6:	c7 04 24 44 40 1b c0 	movl   $0xc01b4044,(%esp)
c01099ad:	e8 f8 1f 00 00       	call   c010b9aa <memset>
    return memcpy(name, proc->name, PROC_NAME_LEN);
c01099b2:	8b 45 08             	mov    0x8(%ebp),%eax
c01099b5:	83 c0 48             	add    $0x48,%eax
c01099b8:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c01099bf:	00 
c01099c0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01099c4:	c7 04 24 44 40 1b c0 	movl   $0xc01b4044,(%esp)
c01099cb:	e8 c4 20 00 00       	call   c010ba94 <memcpy>
}
c01099d0:	c9                   	leave  
c01099d1:	c3                   	ret    

c01099d2 <set_links>:

// set_links - set the relation links of process
static void
set_links(struct proc_struct *proc)
{
c01099d2:	f3 0f 1e fb          	endbr32 
c01099d6:	55                   	push   %ebp
c01099d7:	89 e5                	mov    %esp,%ebp
c01099d9:	83 ec 20             	sub    $0x20,%esp
    list_add(&proc_list, &(proc->list_link));
c01099dc:	8b 45 08             	mov    0x8(%ebp),%eax
c01099df:	83 c0 58             	add    $0x58,%eax
c01099e2:	c7 45 fc 58 41 1b c0 	movl   $0xc01b4158,-0x4(%ebp)
c01099e9:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01099ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01099ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01099f2:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01099f5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    __list_add(elm, listelm, listelm->next);
c01099f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01099fb:	8b 40 04             	mov    0x4(%eax),%eax
c01099fe:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0109a01:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0109a04:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109a07:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0109a0a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    prev->next = next->prev = elm;
c0109a0d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109a10:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0109a13:	89 10                	mov    %edx,(%eax)
c0109a15:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109a18:	8b 10                	mov    (%eax),%edx
c0109a1a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109a1d:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0109a20:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109a23:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0109a26:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0109a29:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109a2c:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0109a2f:	89 10                	mov    %edx,(%eax)
}
c0109a31:	90                   	nop
}
c0109a32:	90                   	nop
}
c0109a33:	90                   	nop
    proc->yptr = NULL;
c0109a34:	8b 45 08             	mov    0x8(%ebp),%eax
c0109a37:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)
    if ((proc->optr = proc->parent->cptr) != NULL)
c0109a3e:	8b 45 08             	mov    0x8(%ebp),%eax
c0109a41:	8b 40 14             	mov    0x14(%eax),%eax
c0109a44:	8b 50 70             	mov    0x70(%eax),%edx
c0109a47:	8b 45 08             	mov    0x8(%ebp),%eax
c0109a4a:	89 50 78             	mov    %edx,0x78(%eax)
c0109a4d:	8b 45 08             	mov    0x8(%ebp),%eax
c0109a50:	8b 40 78             	mov    0x78(%eax),%eax
c0109a53:	85 c0                	test   %eax,%eax
c0109a55:	74 0c                	je     c0109a63 <set_links+0x91>
    {
        proc->optr->yptr = proc;
c0109a57:	8b 45 08             	mov    0x8(%ebp),%eax
c0109a5a:	8b 40 78             	mov    0x78(%eax),%eax
c0109a5d:	8b 55 08             	mov    0x8(%ebp),%edx
c0109a60:	89 50 74             	mov    %edx,0x74(%eax)
    }
    proc->parent->cptr = proc;
c0109a63:	8b 45 08             	mov    0x8(%ebp),%eax
c0109a66:	8b 40 14             	mov    0x14(%eax),%eax
c0109a69:	8b 55 08             	mov    0x8(%ebp),%edx
c0109a6c:	89 50 70             	mov    %edx,0x70(%eax)
    nr_process++;
c0109a6f:	a1 40 40 1b c0       	mov    0xc01b4040,%eax
c0109a74:	40                   	inc    %eax
c0109a75:	a3 40 40 1b c0       	mov    %eax,0xc01b4040
}
c0109a7a:	90                   	nop
c0109a7b:	c9                   	leave  
c0109a7c:	c3                   	ret    

c0109a7d <remove_links>:

// remove_links - clean the relation links of process
static void
remove_links(struct proc_struct *proc)
{
c0109a7d:	f3 0f 1e fb          	endbr32 
c0109a81:	55                   	push   %ebp
c0109a82:	89 e5                	mov    %esp,%ebp
c0109a84:	83 ec 10             	sub    $0x10,%esp
    list_del(&(proc->list_link));
c0109a87:	8b 45 08             	mov    0x8(%ebp),%eax
c0109a8a:	83 c0 58             	add    $0x58,%eax
c0109a8d:	89 45 fc             	mov    %eax,-0x4(%ebp)
    __list_del(listelm->prev, listelm->next);
c0109a90:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109a93:	8b 40 04             	mov    0x4(%eax),%eax
c0109a96:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0109a99:	8b 12                	mov    (%edx),%edx
c0109a9b:	89 55 f8             	mov    %edx,-0x8(%ebp)
c0109a9e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    prev->next = next;
c0109aa1:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0109aa4:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109aa7:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0109aaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109aad:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0109ab0:	89 10                	mov    %edx,(%eax)
}
c0109ab2:	90                   	nop
}
c0109ab3:	90                   	nop
    if (proc->optr != NULL)
c0109ab4:	8b 45 08             	mov    0x8(%ebp),%eax
c0109ab7:	8b 40 78             	mov    0x78(%eax),%eax
c0109aba:	85 c0                	test   %eax,%eax
c0109abc:	74 0f                	je     c0109acd <remove_links+0x50>
    {
        proc->optr->yptr = proc->yptr;
c0109abe:	8b 45 08             	mov    0x8(%ebp),%eax
c0109ac1:	8b 40 78             	mov    0x78(%eax),%eax
c0109ac4:	8b 55 08             	mov    0x8(%ebp),%edx
c0109ac7:	8b 52 74             	mov    0x74(%edx),%edx
c0109aca:	89 50 74             	mov    %edx,0x74(%eax)
    }
    if (proc->yptr != NULL)
c0109acd:	8b 45 08             	mov    0x8(%ebp),%eax
c0109ad0:	8b 40 74             	mov    0x74(%eax),%eax
c0109ad3:	85 c0                	test   %eax,%eax
c0109ad5:	74 11                	je     c0109ae8 <remove_links+0x6b>
    {
        proc->yptr->optr = proc->optr;
c0109ad7:	8b 45 08             	mov    0x8(%ebp),%eax
c0109ada:	8b 40 74             	mov    0x74(%eax),%eax
c0109add:	8b 55 08             	mov    0x8(%ebp),%edx
c0109ae0:	8b 52 78             	mov    0x78(%edx),%edx
c0109ae3:	89 50 78             	mov    %edx,0x78(%eax)
c0109ae6:	eb 0f                	jmp    c0109af7 <remove_links+0x7a>
    }
    else
    {
        proc->parent->cptr = proc->optr;
c0109ae8:	8b 45 08             	mov    0x8(%ebp),%eax
c0109aeb:	8b 40 14             	mov    0x14(%eax),%eax
c0109aee:	8b 55 08             	mov    0x8(%ebp),%edx
c0109af1:	8b 52 78             	mov    0x78(%edx),%edx
c0109af4:	89 50 70             	mov    %edx,0x70(%eax)
    }
    nr_process--;
c0109af7:	a1 40 40 1b c0       	mov    0xc01b4040,%eax
c0109afc:	48                   	dec    %eax
c0109afd:	a3 40 40 1b c0       	mov    %eax,0xc01b4040
}
c0109b02:	90                   	nop
c0109b03:	c9                   	leave  
c0109b04:	c3                   	ret    

c0109b05 <get_pid>:

// get_pid - alloc a unique pid for process
static int
get_pid(void)
{
c0109b05:	f3 0f 1e fb          	endbr32 
c0109b09:	55                   	push   %ebp
c0109b0a:	89 e5                	mov    %esp,%ebp
c0109b0c:	83 ec 10             	sub    $0x10,%esp
    static_assert(MAX_PID > MAX_PROCESS);
    struct proc_struct *proc;
    list_entry_t *list = &proc_list, *le;
c0109b0f:	c7 45 f8 58 41 1b c0 	movl   $0xc01b4158,-0x8(%ebp)
    static int next_safe = MAX_PID, last_pid = MAX_PID;
    if (++last_pid >= MAX_PID)
c0109b16:	a1 80 ea 12 c0       	mov    0xc012ea80,%eax
c0109b1b:	40                   	inc    %eax
c0109b1c:	a3 80 ea 12 c0       	mov    %eax,0xc012ea80
c0109b21:	a1 80 ea 12 c0       	mov    0xc012ea80,%eax
c0109b26:	3d ff 1f 00 00       	cmp    $0x1fff,%eax
c0109b2b:	7e 0c                	jle    c0109b39 <get_pid+0x34>
    {
        last_pid = 1;
c0109b2d:	c7 05 80 ea 12 c0 01 	movl   $0x1,0xc012ea80
c0109b34:	00 00 00 
        goto inside;
c0109b37:	eb 14                	jmp    c0109b4d <get_pid+0x48>
    }
    if (last_pid >= next_safe)
c0109b39:	8b 15 80 ea 12 c0    	mov    0xc012ea80,%edx
c0109b3f:	a1 84 ea 12 c0       	mov    0xc012ea84,%eax
c0109b44:	39 c2                	cmp    %eax,%edx
c0109b46:	0f 8c ab 00 00 00    	jl     c0109bf7 <get_pid+0xf2>
    {
    inside:
c0109b4c:	90                   	nop
        next_safe = MAX_PID;
c0109b4d:	c7 05 84 ea 12 c0 00 	movl   $0x2000,0xc012ea84
c0109b54:	20 00 00 
    repeat:
        le = list;
c0109b57:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0109b5a:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while ((le = list_next(le)) != list)
c0109b5d:	eb 7d                	jmp    c0109bdc <get_pid+0xd7>
        {
            proc = le2proc(le, list_link);
c0109b5f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109b62:	83 e8 58             	sub    $0x58,%eax
c0109b65:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (proc->pid == last_pid)
c0109b68:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109b6b:	8b 50 04             	mov    0x4(%eax),%edx
c0109b6e:	a1 80 ea 12 c0       	mov    0xc012ea80,%eax
c0109b73:	39 c2                	cmp    %eax,%edx
c0109b75:	75 3c                	jne    c0109bb3 <get_pid+0xae>
            {
                if (++last_pid >= next_safe)
c0109b77:	a1 80 ea 12 c0       	mov    0xc012ea80,%eax
c0109b7c:	40                   	inc    %eax
c0109b7d:	a3 80 ea 12 c0       	mov    %eax,0xc012ea80
c0109b82:	8b 15 80 ea 12 c0    	mov    0xc012ea80,%edx
c0109b88:	a1 84 ea 12 c0       	mov    0xc012ea84,%eax
c0109b8d:	39 c2                	cmp    %eax,%edx
c0109b8f:	7c 4b                	jl     c0109bdc <get_pid+0xd7>
                {
                    if (last_pid >= MAX_PID)
c0109b91:	a1 80 ea 12 c0       	mov    0xc012ea80,%eax
c0109b96:	3d ff 1f 00 00       	cmp    $0x1fff,%eax
c0109b9b:	7e 0a                	jle    c0109ba7 <get_pid+0xa2>
                    {
                        last_pid = 1;
c0109b9d:	c7 05 80 ea 12 c0 01 	movl   $0x1,0xc012ea80
c0109ba4:	00 00 00 
                    }
                    next_safe = MAX_PID;
c0109ba7:	c7 05 84 ea 12 c0 00 	movl   $0x2000,0xc012ea84
c0109bae:	20 00 00 
                    goto repeat;
c0109bb1:	eb a4                	jmp    c0109b57 <get_pid+0x52>
                }
            }
            else if (proc->pid > last_pid && next_safe > proc->pid)
c0109bb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109bb6:	8b 50 04             	mov    0x4(%eax),%edx
c0109bb9:	a1 80 ea 12 c0       	mov    0xc012ea80,%eax
c0109bbe:	39 c2                	cmp    %eax,%edx
c0109bc0:	7e 1a                	jle    c0109bdc <get_pid+0xd7>
c0109bc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109bc5:	8b 50 04             	mov    0x4(%eax),%edx
c0109bc8:	a1 84 ea 12 c0       	mov    0xc012ea84,%eax
c0109bcd:	39 c2                	cmp    %eax,%edx
c0109bcf:	7d 0b                	jge    c0109bdc <get_pid+0xd7>
            {
                next_safe = proc->pid;
c0109bd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109bd4:	8b 40 04             	mov    0x4(%eax),%eax
c0109bd7:	a3 84 ea 12 c0       	mov    %eax,0xc012ea84
c0109bdc:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109bdf:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return listelm->next;
c0109be2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109be5:	8b 40 04             	mov    0x4(%eax),%eax
        while ((le = list_next(le)) != list)
c0109be8:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0109beb:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109bee:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c0109bf1:	0f 85 68 ff ff ff    	jne    c0109b5f <get_pid+0x5a>
            }
        }
    }
    return last_pid;
c0109bf7:	a1 80 ea 12 c0       	mov    0xc012ea80,%eax
}
c0109bfc:	c9                   	leave  
c0109bfd:	c3                   	ret    

c0109bfe <proc_run>:

// proc_run - make process "proc" running on cpu
// NOTE: before call switch_to, should load  base addr of "proc"'s new PDT
void proc_run(struct proc_struct *proc)
{
c0109bfe:	f3 0f 1e fb          	endbr32 
c0109c02:	55                   	push   %ebp
c0109c03:	89 e5                	mov    %esp,%ebp
c0109c05:	83 ec 28             	sub    $0x28,%esp
    if (proc != current)
c0109c08:	a1 28 20 1b c0       	mov    0xc01b2028,%eax
c0109c0d:	39 45 08             	cmp    %eax,0x8(%ebp)
c0109c10:	74 64                	je     c0109c76 <proc_run+0x78>
    {
        bool intr_flag;
        struct proc_struct *prev = current, *next = proc;
c0109c12:	a1 28 20 1b c0       	mov    0xc01b2028,%eax
c0109c17:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109c1a:	8b 45 08             	mov    0x8(%ebp),%eax
c0109c1d:	89 45 f0             	mov    %eax,-0x10(%ebp)
        local_intr_save(intr_flag);
c0109c20:	e8 f3 f9 ff ff       	call   c0109618 <__intr_save>
c0109c25:	89 45 ec             	mov    %eax,-0x14(%ebp)
        {
            current = proc;
c0109c28:	8b 45 08             	mov    0x8(%ebp),%eax
c0109c2b:	a3 28 20 1b c0       	mov    %eax,0xc01b2028
            load_esp0(next->kstack + KSTACKSIZE);
c0109c30:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109c33:	8b 40 0c             	mov    0xc(%eax),%eax
c0109c36:	05 00 20 00 00       	add    $0x2000,%eax
c0109c3b:	89 04 24             	mov    %eax,(%esp)
c0109c3e:	e8 d6 9b ff ff       	call   c0103819 <load_esp0>
            lcr3(next->cr3);
c0109c43:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109c46:	8b 40 40             	mov    0x40(%eax),%eax
c0109c49:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("mov %0, %%cr3" :: "r" (cr3) : "memory");
c0109c4c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109c4f:	0f 22 d8             	mov    %eax,%cr3
}
c0109c52:	90                   	nop
            switch_to(&(prev->context), &(next->context));
c0109c53:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109c56:	8d 50 1c             	lea    0x1c(%eax),%edx
c0109c59:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109c5c:	83 c0 1c             	add    $0x1c,%eax
c0109c5f:	89 54 24 04          	mov    %edx,0x4(%esp)
c0109c63:	89 04 24             	mov    %eax,(%esp)
c0109c66:	e8 36 f9 ff ff       	call   c01095a1 <switch_to>
        }
        local_intr_restore(intr_flag);
c0109c6b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109c6e:	89 04 24             	mov    %eax,(%esp)
c0109c71:	e8 cc f9 ff ff       	call   c0109642 <__intr_restore>
    }
}
c0109c76:	90                   	nop
c0109c77:	c9                   	leave  
c0109c78:	c3                   	ret    

c0109c79 <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void)
{
c0109c79:	f3 0f 1e fb          	endbr32 
c0109c7d:	55                   	push   %ebp
c0109c7e:	89 e5                	mov    %esp,%ebp
c0109c80:	83 ec 18             	sub    $0x18,%esp
    forkrets(current->tf);
c0109c83:	a1 28 20 1b c0       	mov    0xc01b2028,%eax
c0109c88:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109c8b:	89 04 24             	mov    %eax,(%esp)
c0109c8e:	e8 ad 99 ff ff       	call   c0103640 <forkrets>
}
c0109c93:	90                   	nop
c0109c94:	c9                   	leave  
c0109c95:	c3                   	ret    

c0109c96 <hash_proc>:

// hash_proc - add proc into proc hash_list
static void
hash_proc(struct proc_struct *proc)
{
c0109c96:	f3 0f 1e fb          	endbr32 
c0109c9a:	55                   	push   %ebp
c0109c9b:	89 e5                	mov    %esp,%ebp
c0109c9d:	53                   	push   %ebx
c0109c9e:	83 ec 34             	sub    $0x34,%esp
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
c0109ca1:	8b 45 08             	mov    0x8(%ebp),%eax
c0109ca4:	8d 58 60             	lea    0x60(%eax),%ebx
c0109ca7:	8b 45 08             	mov    0x8(%ebp),%eax
c0109caa:	8b 40 04             	mov    0x4(%eax),%eax
c0109cad:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
c0109cb4:	00 
c0109cb5:	89 04 24             	mov    %eax,(%esp)
c0109cb8:	e8 11 25 00 00       	call   c010c1ce <hash32>
c0109cbd:	c1 e0 03             	shl    $0x3,%eax
c0109cc0:	05 40 20 1b c0       	add    $0xc01b2040,%eax
c0109cc5:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109cc8:	89 5d f0             	mov    %ebx,-0x10(%ebp)
c0109ccb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109cce:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0109cd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109cd4:	89 45 e8             	mov    %eax,-0x18(%ebp)
    __list_add(elm, listelm, listelm->next);
c0109cd7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109cda:	8b 40 04             	mov    0x4(%eax),%eax
c0109cdd:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0109ce0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0109ce3:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0109ce6:	89 55 e0             	mov    %edx,-0x20(%ebp)
c0109ce9:	89 45 dc             	mov    %eax,-0x24(%ebp)
    prev->next = next->prev = elm;
c0109cec:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0109cef:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0109cf2:	89 10                	mov    %edx,(%eax)
c0109cf4:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0109cf7:	8b 10                	mov    (%eax),%edx
c0109cf9:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109cfc:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0109cff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109d02:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0109d05:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0109d08:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109d0b:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0109d0e:	89 10                	mov    %edx,(%eax)
}
c0109d10:	90                   	nop
}
c0109d11:	90                   	nop
}
c0109d12:	90                   	nop
}
c0109d13:	90                   	nop
c0109d14:	83 c4 34             	add    $0x34,%esp
c0109d17:	5b                   	pop    %ebx
c0109d18:	5d                   	pop    %ebp
c0109d19:	c3                   	ret    

c0109d1a <unhash_proc>:

// unhash_proc - delete proc from proc hash_list
static void
unhash_proc(struct proc_struct *proc)
{
c0109d1a:	f3 0f 1e fb          	endbr32 
c0109d1e:	55                   	push   %ebp
c0109d1f:	89 e5                	mov    %esp,%ebp
c0109d21:	83 ec 10             	sub    $0x10,%esp
    list_del(&(proc->hash_link));
c0109d24:	8b 45 08             	mov    0x8(%ebp),%eax
c0109d27:	83 c0 60             	add    $0x60,%eax
c0109d2a:	89 45 fc             	mov    %eax,-0x4(%ebp)
    __list_del(listelm->prev, listelm->next);
c0109d2d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109d30:	8b 40 04             	mov    0x4(%eax),%eax
c0109d33:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0109d36:	8b 12                	mov    (%edx),%edx
c0109d38:	89 55 f8             	mov    %edx,-0x8(%ebp)
c0109d3b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    prev->next = next;
c0109d3e:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0109d41:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109d44:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0109d47:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109d4a:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0109d4d:	89 10                	mov    %edx,(%eax)
}
c0109d4f:	90                   	nop
}
c0109d50:	90                   	nop
}
c0109d51:	90                   	nop
c0109d52:	c9                   	leave  
c0109d53:	c3                   	ret    

c0109d54 <find_proc>:

// find_proc - find proc frome proc hash_list according to pid
struct proc_struct *
find_proc(int pid)
{
c0109d54:	f3 0f 1e fb          	endbr32 
c0109d58:	55                   	push   %ebp
c0109d59:	89 e5                	mov    %esp,%ebp
c0109d5b:	83 ec 28             	sub    $0x28,%esp
    if (0 < pid && pid < MAX_PID)
c0109d5e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0109d62:	7e 5f                	jle    c0109dc3 <find_proc+0x6f>
c0109d64:	81 7d 08 ff 1f 00 00 	cmpl   $0x1fff,0x8(%ebp)
c0109d6b:	7f 56                	jg     c0109dc3 <find_proc+0x6f>
    {
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
c0109d6d:	8b 45 08             	mov    0x8(%ebp),%eax
c0109d70:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
c0109d77:	00 
c0109d78:	89 04 24             	mov    %eax,(%esp)
c0109d7b:	e8 4e 24 00 00       	call   c010c1ce <hash32>
c0109d80:	c1 e0 03             	shl    $0x3,%eax
c0109d83:	05 40 20 1b c0       	add    $0xc01b2040,%eax
c0109d88:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109d8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109d8e:	89 45 f4             	mov    %eax,-0xc(%ebp)
        while ((le = list_next(le)) != list)
c0109d91:	eb 19                	jmp    c0109dac <find_proc+0x58>
        {
            struct proc_struct *proc = le2proc(le, hash_link);
c0109d93:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109d96:	83 e8 60             	sub    $0x60,%eax
c0109d99:	89 45 ec             	mov    %eax,-0x14(%ebp)
            if (proc->pid == pid)
c0109d9c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109d9f:	8b 40 04             	mov    0x4(%eax),%eax
c0109da2:	39 45 08             	cmp    %eax,0x8(%ebp)
c0109da5:	75 05                	jne    c0109dac <find_proc+0x58>
            {
                return proc;
c0109da7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109daa:	eb 1c                	jmp    c0109dc8 <find_proc+0x74>
c0109dac:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109daf:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return listelm->next;
c0109db2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109db5:	8b 40 04             	mov    0x4(%eax),%eax
        while ((le = list_next(le)) != list)
c0109db8:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109dbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109dbe:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0109dc1:	75 d0                	jne    c0109d93 <find_proc+0x3f>
            }
        }
    }
    return NULL;
c0109dc3:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109dc8:	c9                   	leave  
c0109dc9:	c3                   	ret    

c0109dca <kernel_thread>:

// kernel_thread - create a kernel thread using "fn" function
// NOTE: the contents of temp trapframe tf will be copied to
//       proc->tf in do_fork-->copy_thread function
int kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags)
{
c0109dca:	f3 0f 1e fb          	endbr32 
c0109dce:	55                   	push   %ebp
c0109dcf:	89 e5                	mov    %esp,%ebp
c0109dd1:	83 ec 68             	sub    $0x68,%esp
    struct trapframe tf;
    memset(&tf, 0, sizeof(struct trapframe));
c0109dd4:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
c0109ddb:	00 
c0109ddc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0109de3:	00 
c0109de4:	8d 45 ac             	lea    -0x54(%ebp),%eax
c0109de7:	89 04 24             	mov    %eax,(%esp)
c0109dea:	e8 bb 1b 00 00       	call   c010b9aa <memset>
    tf.tf_cs = KERNEL_CS;
c0109def:	66 c7 45 e8 08 00    	movw   $0x8,-0x18(%ebp)
    tf.tf_ds = tf.tf_es = tf.tf_ss = KERNEL_DS;
c0109df5:	66 c7 45 f4 10 00    	movw   $0x10,-0xc(%ebp)
c0109dfb:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0109dff:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
c0109e03:	0f b7 45 d4          	movzwl -0x2c(%ebp),%eax
c0109e07:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
    tf.tf_regs.reg_ebx = (uint32_t)fn;
c0109e0b:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e0e:	89 45 bc             	mov    %eax,-0x44(%ebp)
    tf.tf_regs.reg_edx = (uint32_t)arg;
c0109e11:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109e14:	89 45 c0             	mov    %eax,-0x40(%ebp)
    tf.tf_eip = (uint32_t)kernel_thread_entry;
c0109e17:	b8 98 95 10 c0       	mov    $0xc0109598,%eax
c0109e1c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
c0109e1f:	8b 45 10             	mov    0x10(%ebp),%eax
c0109e22:	0d 00 01 00 00       	or     $0x100,%eax
c0109e27:	89 c2                	mov    %eax,%edx
c0109e29:	8d 45 ac             	lea    -0x54(%ebp),%eax
c0109e2c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109e30:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0109e37:	00 
c0109e38:	89 14 24             	mov    %edx,(%esp)
c0109e3b:	e8 54 03 00 00       	call   c010a194 <do_fork>
}
c0109e40:	c9                   	leave  
c0109e41:	c3                   	ret    

c0109e42 <setup_kstack>:

// setup_kstack - alloc pages with size KSTACKPAGE as process kernel stack
static int
setup_kstack(struct proc_struct *proc)
{
c0109e42:	f3 0f 1e fb          	endbr32 
c0109e46:	55                   	push   %ebp
c0109e47:	89 e5                	mov    %esp,%ebp
c0109e49:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = alloc_pages(KSTACKPAGE);
c0109e4c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0109e53:	e8 1d 9b ff ff       	call   c0103975 <alloc_pages>
c0109e58:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL)
c0109e5b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109e5f:	74 1a                	je     c0109e7b <setup_kstack+0x39>
    {
        proc->kstack = (uintptr_t)page2kva(page);
c0109e61:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109e64:	89 04 24             	mov    %eax,(%esp)
c0109e67:	e8 d8 f8 ff ff       	call   c0109744 <page2kva>
c0109e6c:	89 c2                	mov    %eax,%edx
c0109e6e:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e71:	89 50 0c             	mov    %edx,0xc(%eax)
        return 0;
c0109e74:	b8 00 00 00 00       	mov    $0x0,%eax
c0109e79:	eb 05                	jmp    c0109e80 <setup_kstack+0x3e>
    }
    return -E_NO_MEM;
c0109e7b:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
}
c0109e80:	c9                   	leave  
c0109e81:	c3                   	ret    

c0109e82 <put_kstack>:

// put_kstack - free the memory space of process kernel stack
static void
put_kstack(struct proc_struct *proc)
{
c0109e82:	f3 0f 1e fb          	endbr32 
c0109e86:	55                   	push   %ebp
c0109e87:	89 e5                	mov    %esp,%ebp
c0109e89:	83 ec 18             	sub    $0x18,%esp
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
c0109e8c:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e8f:	8b 40 0c             	mov    0xc(%eax),%eax
c0109e92:	89 04 24             	mov    %eax,(%esp)
c0109e95:	e8 fe f8 ff ff       	call   c0109798 <kva2page>
c0109e9a:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0109ea1:	00 
c0109ea2:	89 04 24             	mov    %eax,(%esp)
c0109ea5:	e8 3a 9b ff ff       	call   c01039e4 <free_pages>
}
c0109eaa:	90                   	nop
c0109eab:	c9                   	leave  
c0109eac:	c3                   	ret    

c0109ead <setup_pgdir>:

// setup_pgdir - alloc one page as PDT
static int
setup_pgdir(struct mm_struct *mm)
{
c0109ead:	f3 0f 1e fb          	endbr32 
c0109eb1:	55                   	push   %ebp
c0109eb2:	89 e5                	mov    %esp,%ebp
c0109eb4:	83 ec 28             	sub    $0x28,%esp
    struct Page *page;
    if ((page = alloc_page()) == NULL)
c0109eb7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0109ebe:	e8 b2 9a ff ff       	call   c0103975 <alloc_pages>
c0109ec3:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109ec6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109eca:	75 0a                	jne    c0109ed6 <setup_pgdir+0x29>
    {
        return -E_NO_MEM;
c0109ecc:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0109ed1:	e9 80 00 00 00       	jmp    c0109f56 <setup_pgdir+0xa9>
    }
    pde_t *pgdir = page2kva(page);
c0109ed6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109ed9:	89 04 24             	mov    %eax,(%esp)
c0109edc:	e8 63 f8 ff ff       	call   c0109744 <page2kva>
c0109ee1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memcpy(pgdir, boot_pgdir, PGSIZE);
c0109ee4:	a1 e0 e9 12 c0       	mov    0xc012e9e0,%eax
c0109ee9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0109ef0:	00 
c0109ef1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109ef5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109ef8:	89 04 24             	mov    %eax,(%esp)
c0109efb:	e8 94 1b 00 00       	call   c010ba94 <memcpy>
    pgdir[PDX(VPT)] = PADDR(pgdir) | PTE_P | PTE_W;
c0109f00:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109f03:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0109f06:	81 7d ec ff ff ff bf 	cmpl   $0xbfffffff,-0x14(%ebp)
c0109f0d:	77 23                	ja     c0109f32 <setup_pgdir+0x85>
c0109f0f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109f12:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109f16:	c7 44 24 08 80 e4 10 	movl   $0xc010e480,0x8(%esp)
c0109f1d:	c0 
c0109f1e:	c7 44 24 04 47 01 00 	movl   $0x147,0x4(%esp)
c0109f25:	00 
c0109f26:	c7 04 24 a4 e4 10 c0 	movl   $0xc010e4a4,(%esp)
c0109f2d:	e8 0b 65 ff ff       	call   c010043d <__panic>
c0109f32:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109f35:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c0109f3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109f3e:	05 ac 0f 00 00       	add    $0xfac,%eax
c0109f43:	83 ca 03             	or     $0x3,%edx
c0109f46:	89 10                	mov    %edx,(%eax)
    mm->pgdir = pgdir;
c0109f48:	8b 45 08             	mov    0x8(%ebp),%eax
c0109f4b:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0109f4e:	89 50 0c             	mov    %edx,0xc(%eax)
    return 0;
c0109f51:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109f56:	c9                   	leave  
c0109f57:	c3                   	ret    

c0109f58 <put_pgdir>:

// put_pgdir - free the memory space of PDT
static void
put_pgdir(struct mm_struct *mm)
{
c0109f58:	f3 0f 1e fb          	endbr32 
c0109f5c:	55                   	push   %ebp
c0109f5d:	89 e5                	mov    %esp,%ebp
c0109f5f:	83 ec 18             	sub    $0x18,%esp
    free_page(kva2page(mm->pgdir));
c0109f62:	8b 45 08             	mov    0x8(%ebp),%eax
c0109f65:	8b 40 0c             	mov    0xc(%eax),%eax
c0109f68:	89 04 24             	mov    %eax,(%esp)
c0109f6b:	e8 28 f8 ff ff       	call   c0109798 <kva2page>
c0109f70:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0109f77:	00 
c0109f78:	89 04 24             	mov    %eax,(%esp)
c0109f7b:	e8 64 9a ff ff       	call   c01039e4 <free_pages>
}
c0109f80:	90                   	nop
c0109f81:	c9                   	leave  
c0109f82:	c3                   	ret    

c0109f83 <copy_mm>:

// copy_mm - process "proc" duplicate OR share process "current"'s mm according clone_flags
//         - if clone_flags & CLONE_VM, then "share" ; else "duplicate"
static int
copy_mm(uint32_t clone_flags, struct proc_struct *proc)
{
c0109f83:	f3 0f 1e fb          	endbr32 
c0109f87:	55                   	push   %ebp
c0109f88:	89 e5                	mov    %esp,%ebp
c0109f8a:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm, *oldmm = current->mm;
c0109f8d:	a1 28 20 1b c0       	mov    0xc01b2028,%eax
c0109f92:	8b 40 18             	mov    0x18(%eax),%eax
c0109f95:	89 45 ec             	mov    %eax,-0x14(%ebp)

    /* current is a kernel thread */
    if (oldmm == NULL)
c0109f98:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0109f9c:	75 0a                	jne    c0109fa8 <copy_mm+0x25>
    {
        return 0;
c0109f9e:	b8 00 00 00 00       	mov    $0x0,%eax
c0109fa3:	e9 00 01 00 00       	jmp    c010a0a8 <copy_mm+0x125>
    }
    if (clone_flags & CLONE_VM)
c0109fa8:	8b 45 08             	mov    0x8(%ebp),%eax
c0109fab:	25 00 01 00 00       	and    $0x100,%eax
c0109fb0:	85 c0                	test   %eax,%eax
c0109fb2:	74 08                	je     c0109fbc <copy_mm+0x39>
    {
        mm = oldmm;
c0109fb4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109fb7:	89 45 f4             	mov    %eax,-0xc(%ebp)
        goto good_mm;
c0109fba:	eb 5e                	jmp    c010a01a <copy_mm+0x97>
    }

    int ret = -E_NO_MEM;
c0109fbc:	c7 45 f0 fc ff ff ff 	movl   $0xfffffffc,-0x10(%ebp)
    if ((mm = mm_create()) == NULL)
c0109fc3:	e8 54 b6 ff ff       	call   c010561c <mm_create>
c0109fc8:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109fcb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109fcf:	0f 84 cf 00 00 00    	je     c010a0a4 <copy_mm+0x121>
    {
        goto bad_mm;
    }
    if (setup_pgdir(mm) != 0)
c0109fd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109fd8:	89 04 24             	mov    %eax,(%esp)
c0109fdb:	e8 cd fe ff ff       	call   c0109ead <setup_pgdir>
c0109fe0:	85 c0                	test   %eax,%eax
c0109fe2:	0f 85 ae 00 00 00    	jne    c010a096 <copy_mm+0x113>
    {
        goto bad_pgdir_cleanup_mm;
    }

    lock_mm(oldmm);
c0109fe8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109feb:	89 04 24             	mov    %eax,(%esp)
c0109fee:	e8 23 f8 ff ff       	call   c0109816 <lock_mm>
    {
        ret = dup_mmap(mm, oldmm);
c0109ff3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109ff6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109ffa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109ffd:	89 04 24             	mov    %eax,(%esp)
c010a000:	e8 4b bb ff ff       	call   c0105b50 <dup_mmap>
c010a005:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    unlock_mm(oldmm);
c010a008:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a00b:	89 04 24             	mov    %eax,(%esp)
c010a00e:	e8 20 f8 ff ff       	call   c0109833 <unlock_mm>

    if (ret != 0)
c010a013:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a017:	75 60                	jne    c010a079 <copy_mm+0xf6>
    {
        goto bad_dup_cleanup_mmap;
    }

good_mm:
c010a019:	90                   	nop
    mm_count_inc(mm);
c010a01a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a01d:	89 04 24             	mov    %eax,(%esp)
c010a020:	e8 bd f7 ff ff       	call   c01097e2 <mm_count_inc>
    proc->mm = mm;
c010a025:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a028:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010a02b:	89 50 18             	mov    %edx,0x18(%eax)
    proc->cr3 = PADDR(mm->pgdir);
c010a02e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a031:	8b 40 0c             	mov    0xc(%eax),%eax
c010a034:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010a037:	81 7d e8 ff ff ff bf 	cmpl   $0xbfffffff,-0x18(%ebp)
c010a03e:	77 23                	ja     c010a063 <copy_mm+0xe0>
c010a040:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a043:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010a047:	c7 44 24 08 80 e4 10 	movl   $0xc010e480,0x8(%esp)
c010a04e:	c0 
c010a04f:	c7 44 24 04 7d 01 00 	movl   $0x17d,0x4(%esp)
c010a056:	00 
c010a057:	c7 04 24 a4 e4 10 c0 	movl   $0xc010e4a4,(%esp)
c010a05e:	e8 da 63 ff ff       	call   c010043d <__panic>
c010a063:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a066:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c010a06c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a06f:	89 50 40             	mov    %edx,0x40(%eax)
    return 0;
c010a072:	b8 00 00 00 00       	mov    $0x0,%eax
c010a077:	eb 2f                	jmp    c010a0a8 <copy_mm+0x125>
        goto bad_dup_cleanup_mmap;
c010a079:	90                   	nop
c010a07a:	f3 0f 1e fb          	endbr32 
bad_dup_cleanup_mmap:
    exit_mmap(mm);
c010a07e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a081:	89 04 24             	mov    %eax,(%esp)
c010a084:	e8 cc bb ff ff       	call   c0105c55 <exit_mmap>
    put_pgdir(mm);
c010a089:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a08c:	89 04 24             	mov    %eax,(%esp)
c010a08f:	e8 c4 fe ff ff       	call   c0109f58 <put_pgdir>
c010a094:	eb 01                	jmp    c010a097 <copy_mm+0x114>
        goto bad_pgdir_cleanup_mm;
c010a096:	90                   	nop
bad_pgdir_cleanup_mm:
    mm_destroy(mm);
c010a097:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a09a:	89 04 24             	mov    %eax,(%esp)
c010a09d:	e8 e9 b8 ff ff       	call   c010598b <mm_destroy>
c010a0a2:	eb 01                	jmp    c010a0a5 <copy_mm+0x122>
        goto bad_mm;
c010a0a4:	90                   	nop
bad_mm:
    return ret;
c010a0a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c010a0a8:	c9                   	leave  
c010a0a9:	c3                   	ret    

c010a0aa <copy_thread>:

// copy_thread - setup the trapframe on the  process's kernel stack top and
//             - setup the kernel entry point and stack of process
static void
copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf)
{
c010a0aa:	f3 0f 1e fb          	endbr32 
c010a0ae:	55                   	push   %ebp
c010a0af:	89 e5                	mov    %esp,%ebp
c010a0b1:	57                   	push   %edi
c010a0b2:	56                   	push   %esi
c010a0b3:	53                   	push   %ebx
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
c010a0b4:	8b 45 08             	mov    0x8(%ebp),%eax
c010a0b7:	8b 40 0c             	mov    0xc(%eax),%eax
c010a0ba:	05 b4 1f 00 00       	add    $0x1fb4,%eax
c010a0bf:	89 c2                	mov    %eax,%edx
c010a0c1:	8b 45 08             	mov    0x8(%ebp),%eax
c010a0c4:	89 50 3c             	mov    %edx,0x3c(%eax)
    *(proc->tf) = *tf;
c010a0c7:	8b 45 08             	mov    0x8(%ebp),%eax
c010a0ca:	8b 40 3c             	mov    0x3c(%eax),%eax
c010a0cd:	8b 55 10             	mov    0x10(%ebp),%edx
c010a0d0:	bb 4c 00 00 00       	mov    $0x4c,%ebx
c010a0d5:	89 c1                	mov    %eax,%ecx
c010a0d7:	83 e1 01             	and    $0x1,%ecx
c010a0da:	85 c9                	test   %ecx,%ecx
c010a0dc:	74 0c                	je     c010a0ea <copy_thread+0x40>
c010a0de:	0f b6 0a             	movzbl (%edx),%ecx
c010a0e1:	88 08                	mov    %cl,(%eax)
c010a0e3:	8d 40 01             	lea    0x1(%eax),%eax
c010a0e6:	8d 52 01             	lea    0x1(%edx),%edx
c010a0e9:	4b                   	dec    %ebx
c010a0ea:	89 c1                	mov    %eax,%ecx
c010a0ec:	83 e1 02             	and    $0x2,%ecx
c010a0ef:	85 c9                	test   %ecx,%ecx
c010a0f1:	74 0f                	je     c010a102 <copy_thread+0x58>
c010a0f3:	0f b7 0a             	movzwl (%edx),%ecx
c010a0f6:	66 89 08             	mov    %cx,(%eax)
c010a0f9:	8d 40 02             	lea    0x2(%eax),%eax
c010a0fc:	8d 52 02             	lea    0x2(%edx),%edx
c010a0ff:	83 eb 02             	sub    $0x2,%ebx
c010a102:	89 df                	mov    %ebx,%edi
c010a104:	83 e7 fc             	and    $0xfffffffc,%edi
c010a107:	b9 00 00 00 00       	mov    $0x0,%ecx
c010a10c:	8b 34 0a             	mov    (%edx,%ecx,1),%esi
c010a10f:	89 34 08             	mov    %esi,(%eax,%ecx,1)
c010a112:	83 c1 04             	add    $0x4,%ecx
c010a115:	39 f9                	cmp    %edi,%ecx
c010a117:	72 f3                	jb     c010a10c <copy_thread+0x62>
c010a119:	01 c8                	add    %ecx,%eax
c010a11b:	01 ca                	add    %ecx,%edx
c010a11d:	b9 00 00 00 00       	mov    $0x0,%ecx
c010a122:	89 de                	mov    %ebx,%esi
c010a124:	83 e6 02             	and    $0x2,%esi
c010a127:	85 f6                	test   %esi,%esi
c010a129:	74 0b                	je     c010a136 <copy_thread+0x8c>
c010a12b:	0f b7 34 0a          	movzwl (%edx,%ecx,1),%esi
c010a12f:	66 89 34 08          	mov    %si,(%eax,%ecx,1)
c010a133:	83 c1 02             	add    $0x2,%ecx
c010a136:	83 e3 01             	and    $0x1,%ebx
c010a139:	85 db                	test   %ebx,%ebx
c010a13b:	74 07                	je     c010a144 <copy_thread+0x9a>
c010a13d:	0f b6 14 0a          	movzbl (%edx,%ecx,1),%edx
c010a141:	88 14 08             	mov    %dl,(%eax,%ecx,1)
    proc->tf->tf_regs.reg_eax = 0;
c010a144:	8b 45 08             	mov    0x8(%ebp),%eax
c010a147:	8b 40 3c             	mov    0x3c(%eax),%eax
c010a14a:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
    proc->tf->tf_esp = esp;
c010a151:	8b 45 08             	mov    0x8(%ebp),%eax
c010a154:	8b 40 3c             	mov    0x3c(%eax),%eax
c010a157:	8b 55 0c             	mov    0xc(%ebp),%edx
c010a15a:	89 50 44             	mov    %edx,0x44(%eax)
    proc->tf->tf_eflags |= FL_IF;
c010a15d:	8b 45 08             	mov    0x8(%ebp),%eax
c010a160:	8b 40 3c             	mov    0x3c(%eax),%eax
c010a163:	8b 50 40             	mov    0x40(%eax),%edx
c010a166:	8b 45 08             	mov    0x8(%ebp),%eax
c010a169:	8b 40 3c             	mov    0x3c(%eax),%eax
c010a16c:	81 ca 00 02 00 00    	or     $0x200,%edx
c010a172:	89 50 40             	mov    %edx,0x40(%eax)

    proc->context.eip = (uintptr_t)forkret;
c010a175:	ba 79 9c 10 c0       	mov    $0xc0109c79,%edx
c010a17a:	8b 45 08             	mov    0x8(%ebp),%eax
c010a17d:	89 50 1c             	mov    %edx,0x1c(%eax)
    proc->context.esp = (uintptr_t)(proc->tf);
c010a180:	8b 45 08             	mov    0x8(%ebp),%eax
c010a183:	8b 40 3c             	mov    0x3c(%eax),%eax
c010a186:	89 c2                	mov    %eax,%edx
c010a188:	8b 45 08             	mov    0x8(%ebp),%eax
c010a18b:	89 50 20             	mov    %edx,0x20(%eax)
}
c010a18e:	90                   	nop
c010a18f:	5b                   	pop    %ebx
c010a190:	5e                   	pop    %esi
c010a191:	5f                   	pop    %edi
c010a192:	5d                   	pop    %ebp
c010a193:	c3                   	ret    

c010a194 <do_fork>:
 * @clone_flags: used to guide how to clone the child process
 * @stack:       the parent's user stack pointer. if stack==0, It means to fork a kernel thread.
 * @tf:          the trapframe info, which will be copied to child process's proc->tf
 */
int do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf)
{
c010a194:	f3 0f 1e fb          	endbr32 
c010a198:	55                   	push   %ebp
c010a199:	89 e5                	mov    %esp,%ebp
c010a19b:	83 ec 28             	sub    $0x28,%esp
    int ret = -E_NO_FREE_PROC;
c010a19e:	c7 45 f4 fb ff ff ff 	movl   $0xfffffffb,-0xc(%ebp)
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS)
c010a1a5:	a1 40 40 1b c0       	mov    0xc01b4040,%eax
c010a1aa:	3d ff 0f 00 00       	cmp    $0xfff,%eax
c010a1af:	0f 8f e1 00 00 00    	jg     c010a296 <do_fork+0x102>
    {
        goto fork_out;
    }
    ret = -E_NO_MEM;
c010a1b5:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)
    //    3. call copy_mm to dup OR share mm according clone_flag
    //    4. call copy_thread to setup tf & context in proc_struct
    //    5. insert proc_struct into hash_list && proc_list
    //    6. call wakeup_proc to make the new child process RUNNABLE
    //    7. set ret vaule using child proc's pid
    if ((proc = alloc_proc()) == NULL)
c010a1bc:	e8 8f f6 ff ff       	call   c0109850 <alloc_proc>
c010a1c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a1c4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a1c8:	0f 84 cb 00 00 00    	je     c010a299 <do_fork+0x105>
    {
        goto fork_out;
    }

    proc->parent = current;
c010a1ce:	8b 15 28 20 1b c0    	mov    0xc01b2028,%edx
c010a1d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a1d7:	89 50 14             	mov    %edx,0x14(%eax)
    assert(current->wait_state == 0);
c010a1da:	a1 28 20 1b c0       	mov    0xc01b2028,%eax
c010a1df:	8b 40 6c             	mov    0x6c(%eax),%eax
c010a1e2:	85 c0                	test   %eax,%eax
c010a1e4:	74 24                	je     c010a20a <do_fork+0x76>
c010a1e6:	c7 44 24 0c b8 e4 10 	movl   $0xc010e4b8,0xc(%esp)
c010a1ed:	c0 
c010a1ee:	c7 44 24 08 d1 e4 10 	movl   $0xc010e4d1,0x8(%esp)
c010a1f5:	c0 
c010a1f6:	c7 44 24 04 c4 01 00 	movl   $0x1c4,0x4(%esp)
c010a1fd:	00 
c010a1fe:	c7 04 24 a4 e4 10 c0 	movl   $0xc010e4a4,(%esp)
c010a205:	e8 33 62 ff ff       	call   c010043d <__panic>

    if (setup_kstack(proc) != 0)
c010a20a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a20d:	89 04 24             	mov    %eax,(%esp)
c010a210:	e8 2d fc ff ff       	call   c0109e42 <setup_kstack>
c010a215:	85 c0                	test   %eax,%eax
c010a217:	0f 85 94 00 00 00    	jne    c010a2b1 <do_fork+0x11d>
    {
        goto bad_fork_cleanup_proc;
    }
    if (copy_mm(clone_flags, proc) != 0)
c010a21d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a220:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a224:	8b 45 08             	mov    0x8(%ebp),%eax
c010a227:	89 04 24             	mov    %eax,(%esp)
c010a22a:	e8 54 fd ff ff       	call   c0109f83 <copy_mm>
c010a22f:	85 c0                	test   %eax,%eax
c010a231:	75 6c                	jne    c010a29f <do_fork+0x10b>
    {
        goto bad_fork_cleanup_kstack;
    }
    copy_thread(proc, stack, tf);
c010a233:	8b 45 10             	mov    0x10(%ebp),%eax
c010a236:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a23a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a23d:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a241:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a244:	89 04 24             	mov    %eax,(%esp)
c010a247:	e8 5e fe ff ff       	call   c010a0aa <copy_thread>

    bool intr_flag;
    local_intr_save(intr_flag);
c010a24c:	e8 c7 f3 ff ff       	call   c0109618 <__intr_save>
c010a251:	89 45 ec             	mov    %eax,-0x14(%ebp)
    {
        proc->pid = get_pid();
c010a254:	e8 ac f8 ff ff       	call   c0109b05 <get_pid>
c010a259:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010a25c:	89 42 04             	mov    %eax,0x4(%edx)
        hash_proc(proc);
c010a25f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a262:	89 04 24             	mov    %eax,(%esp)
c010a265:	e8 2c fa ff ff       	call   c0109c96 <hash_proc>
        set_links(proc);
c010a26a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a26d:	89 04 24             	mov    %eax,(%esp)
c010a270:	e8 5d f7 ff ff       	call   c01099d2 <set_links>
    }
    local_intr_restore(intr_flag);
c010a275:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a278:	89 04 24             	mov    %eax,(%esp)
c010a27b:	e8 c2 f3 ff ff       	call   c0109642 <__intr_restore>

    wakeup_proc(proc);
c010a280:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a283:	89 04 24             	mov    %eax,(%esp)
c010a286:	e8 64 10 00 00       	call   c010b2ef <wakeup_proc>

    ret = proc->pid;
c010a28b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a28e:	8b 40 04             	mov    0x4(%eax),%eax
c010a291:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a294:	eb 04                	jmp    c010a29a <do_fork+0x106>
        goto fork_out;
c010a296:	90                   	nop
c010a297:	eb 01                	jmp    c010a29a <do_fork+0x106>
        goto fork_out;
c010a299:	90                   	nop
fork_out:
    return ret;
c010a29a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a29d:	eb 20                	jmp    c010a2bf <do_fork+0x12b>
        goto bad_fork_cleanup_kstack;
c010a29f:	90                   	nop
c010a2a0:	f3 0f 1e fb          	endbr32 

bad_fork_cleanup_kstack:
    put_kstack(proc);
c010a2a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a2a7:	89 04 24             	mov    %eax,(%esp)
c010a2aa:	e8 d3 fb ff ff       	call   c0109e82 <put_kstack>
c010a2af:	eb 01                	jmp    c010a2b2 <do_fork+0x11e>
        goto bad_fork_cleanup_proc;
c010a2b1:	90                   	nop
bad_fork_cleanup_proc:
    kfree(proc);
c010a2b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a2b5:	89 04 24             	mov    %eax,(%esp)
c010a2b8:	e8 6f d8 ff ff       	call   c0107b2c <kfree>
    goto fork_out;
c010a2bd:	eb db                	jmp    c010a29a <do_fork+0x106>
}
c010a2bf:	c9                   	leave  
c010a2c0:	c3                   	ret    

c010a2c1 <do_exit>:
// do_exit - called by sys_exit
//   1. call exit_mmap & put_pgdir & mm_destroy to free the almost all memory space of process
//   2. set process' state as PROC_ZOMBIE, then call wakeup_proc(parent) to ask parent reclaim itself.
//   3. call scheduler to switch to other process
int do_exit(int error_code)
{
c010a2c1:	f3 0f 1e fb          	endbr32 
c010a2c5:	55                   	push   %ebp
c010a2c6:	89 e5                	mov    %esp,%ebp
c010a2c8:	83 ec 28             	sub    $0x28,%esp
    if (current == idleproc)
c010a2cb:	8b 15 28 20 1b c0    	mov    0xc01b2028,%edx
c010a2d1:	a1 20 20 1b c0       	mov    0xc01b2020,%eax
c010a2d6:	39 c2                	cmp    %eax,%edx
c010a2d8:	75 1c                	jne    c010a2f6 <do_exit+0x35>
    {
        panic("idleproc exit.\n");
c010a2da:	c7 44 24 08 e6 e4 10 	movl   $0xc010e4e6,0x8(%esp)
c010a2e1:	c0 
c010a2e2:	c7 44 24 04 ee 01 00 	movl   $0x1ee,0x4(%esp)
c010a2e9:	00 
c010a2ea:	c7 04 24 a4 e4 10 c0 	movl   $0xc010e4a4,(%esp)
c010a2f1:	e8 47 61 ff ff       	call   c010043d <__panic>
    }
    if (current == initproc)
c010a2f6:	8b 15 28 20 1b c0    	mov    0xc01b2028,%edx
c010a2fc:	a1 24 20 1b c0       	mov    0xc01b2024,%eax
c010a301:	39 c2                	cmp    %eax,%edx
c010a303:	75 1c                	jne    c010a321 <do_exit+0x60>
    {
        panic("initproc exit.\n");
c010a305:	c7 44 24 08 f6 e4 10 	movl   $0xc010e4f6,0x8(%esp)
c010a30c:	c0 
c010a30d:	c7 44 24 04 f2 01 00 	movl   $0x1f2,0x4(%esp)
c010a314:	00 
c010a315:	c7 04 24 a4 e4 10 c0 	movl   $0xc010e4a4,(%esp)
c010a31c:	e8 1c 61 ff ff       	call   c010043d <__panic>
    }

    struct mm_struct *mm = current->mm;
c010a321:	a1 28 20 1b c0       	mov    0xc01b2028,%eax
c010a326:	8b 40 18             	mov    0x18(%eax),%eax
c010a329:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (mm != NULL)
c010a32c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a330:	74 4b                	je     c010a37d <do_exit+0xbc>
    {
        lcr3(boot_cr3);
c010a332:	a1 5c 40 1b c0       	mov    0xc01b405c,%eax
c010a337:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("mov %0, %%cr3" :: "r" (cr3) : "memory");
c010a33a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a33d:	0f 22 d8             	mov    %eax,%cr3
}
c010a340:	90                   	nop
        if (mm_count_dec(mm) == 0)
c010a341:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a344:	89 04 24             	mov    %eax,(%esp)
c010a347:	e8 b0 f4 ff ff       	call   c01097fc <mm_count_dec>
c010a34c:	85 c0                	test   %eax,%eax
c010a34e:	75 21                	jne    c010a371 <do_exit+0xb0>
        {
            exit_mmap(mm);
c010a350:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a353:	89 04 24             	mov    %eax,(%esp)
c010a356:	e8 fa b8 ff ff       	call   c0105c55 <exit_mmap>
            put_pgdir(mm);
c010a35b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a35e:	89 04 24             	mov    %eax,(%esp)
c010a361:	e8 f2 fb ff ff       	call   c0109f58 <put_pgdir>
            mm_destroy(mm);
c010a366:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a369:	89 04 24             	mov    %eax,(%esp)
c010a36c:	e8 1a b6 ff ff       	call   c010598b <mm_destroy>
        }
        current->mm = NULL;
c010a371:	a1 28 20 1b c0       	mov    0xc01b2028,%eax
c010a376:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
    }
    current->state = PROC_ZOMBIE;
c010a37d:	a1 28 20 1b c0       	mov    0xc01b2028,%eax
c010a382:	c7 00 03 00 00 00    	movl   $0x3,(%eax)
    current->exit_code = error_code;
c010a388:	a1 28 20 1b c0       	mov    0xc01b2028,%eax
c010a38d:	8b 55 08             	mov    0x8(%ebp),%edx
c010a390:	89 50 68             	mov    %edx,0x68(%eax)

    bool intr_flag;
    struct proc_struct *proc;
    local_intr_save(intr_flag);
c010a393:	e8 80 f2 ff ff       	call   c0109618 <__intr_save>
c010a398:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        proc = current->parent;
c010a39b:	a1 28 20 1b c0       	mov    0xc01b2028,%eax
c010a3a0:	8b 40 14             	mov    0x14(%eax),%eax
c010a3a3:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (proc->wait_state == WT_CHILD)
c010a3a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a3a9:	8b 40 6c             	mov    0x6c(%eax),%eax
c010a3ac:	3d 01 00 00 80       	cmp    $0x80000001,%eax
c010a3b1:	0f 85 96 00 00 00    	jne    c010a44d <do_exit+0x18c>
        {
            wakeup_proc(proc);
c010a3b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a3ba:	89 04 24             	mov    %eax,(%esp)
c010a3bd:	e8 2d 0f 00 00       	call   c010b2ef <wakeup_proc>
        }
        while (current->cptr != NULL)
c010a3c2:	e9 86 00 00 00       	jmp    c010a44d <do_exit+0x18c>
        {
            proc = current->cptr;
c010a3c7:	a1 28 20 1b c0       	mov    0xc01b2028,%eax
c010a3cc:	8b 40 70             	mov    0x70(%eax),%eax
c010a3cf:	89 45 ec             	mov    %eax,-0x14(%ebp)
            current->cptr = proc->optr;
c010a3d2:	a1 28 20 1b c0       	mov    0xc01b2028,%eax
c010a3d7:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010a3da:	8b 52 78             	mov    0x78(%edx),%edx
c010a3dd:	89 50 70             	mov    %edx,0x70(%eax)

            proc->yptr = NULL;
c010a3e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a3e3:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)
            if ((proc->optr = initproc->cptr) != NULL)
c010a3ea:	a1 24 20 1b c0       	mov    0xc01b2024,%eax
c010a3ef:	8b 50 70             	mov    0x70(%eax),%edx
c010a3f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a3f5:	89 50 78             	mov    %edx,0x78(%eax)
c010a3f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a3fb:	8b 40 78             	mov    0x78(%eax),%eax
c010a3fe:	85 c0                	test   %eax,%eax
c010a400:	74 0e                	je     c010a410 <do_exit+0x14f>
            {
                initproc->cptr->yptr = proc;
c010a402:	a1 24 20 1b c0       	mov    0xc01b2024,%eax
c010a407:	8b 40 70             	mov    0x70(%eax),%eax
c010a40a:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010a40d:	89 50 74             	mov    %edx,0x74(%eax)
            }
            proc->parent = initproc;
c010a410:	8b 15 24 20 1b c0    	mov    0xc01b2024,%edx
c010a416:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a419:	89 50 14             	mov    %edx,0x14(%eax)
            initproc->cptr = proc;
c010a41c:	a1 24 20 1b c0       	mov    0xc01b2024,%eax
c010a421:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010a424:	89 50 70             	mov    %edx,0x70(%eax)
            if (proc->state == PROC_ZOMBIE)
c010a427:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a42a:	8b 00                	mov    (%eax),%eax
c010a42c:	83 f8 03             	cmp    $0x3,%eax
c010a42f:	75 1c                	jne    c010a44d <do_exit+0x18c>
            {
                if (initproc->wait_state == WT_CHILD)
c010a431:	a1 24 20 1b c0       	mov    0xc01b2024,%eax
c010a436:	8b 40 6c             	mov    0x6c(%eax),%eax
c010a439:	3d 01 00 00 80       	cmp    $0x80000001,%eax
c010a43e:	75 0d                	jne    c010a44d <do_exit+0x18c>
                {
                    wakeup_proc(initproc);
c010a440:	a1 24 20 1b c0       	mov    0xc01b2024,%eax
c010a445:	89 04 24             	mov    %eax,(%esp)
c010a448:	e8 a2 0e 00 00       	call   c010b2ef <wakeup_proc>
        while (current->cptr != NULL)
c010a44d:	a1 28 20 1b c0       	mov    0xc01b2028,%eax
c010a452:	8b 40 70             	mov    0x70(%eax),%eax
c010a455:	85 c0                	test   %eax,%eax
c010a457:	0f 85 6a ff ff ff    	jne    c010a3c7 <do_exit+0x106>
                }
            }
        }
    }
    local_intr_restore(intr_flag);
c010a45d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a460:	89 04 24             	mov    %eax,(%esp)
c010a463:	e8 da f1 ff ff       	call   c0109642 <__intr_restore>

    schedule();
c010a468:	e8 0b 0f 00 00       	call   c010b378 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
c010a46d:	a1 28 20 1b c0       	mov    0xc01b2028,%eax
c010a472:	8b 40 04             	mov    0x4(%eax),%eax
c010a475:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010a479:	c7 44 24 08 08 e5 10 	movl   $0xc010e508,0x8(%esp)
c010a480:	c0 
c010a481:	c7 44 24 04 25 02 00 	movl   $0x225,0x4(%esp)
c010a488:	00 
c010a489:	c7 04 24 a4 e4 10 c0 	movl   $0xc010e4a4,(%esp)
c010a490:	e8 a8 5f ff ff       	call   c010043d <__panic>

c010a495 <load_icode>:
 * @binary:  the memory addr of the content of binary program
 * @size:  the size of the content of binary program
 */
static int
load_icode(unsigned char *binary, size_t size)
{
c010a495:	f3 0f 1e fb          	endbr32 
c010a499:	55                   	push   %ebp
c010a49a:	89 e5                	mov    %esp,%ebp
c010a49c:	83 ec 78             	sub    $0x78,%esp
    if (current->mm != NULL)
c010a49f:	a1 28 20 1b c0       	mov    0xc01b2028,%eax
c010a4a4:	8b 40 18             	mov    0x18(%eax),%eax
c010a4a7:	85 c0                	test   %eax,%eax
c010a4a9:	74 1c                	je     c010a4c7 <load_icode+0x32>
    {
        panic("load_icode: current->mm must be empty.\n");
c010a4ab:	c7 44 24 08 28 e5 10 	movl   $0xc010e528,0x8(%esp)
c010a4b2:	c0 
c010a4b3:	c7 44 24 04 31 02 00 	movl   $0x231,0x4(%esp)
c010a4ba:	00 
c010a4bb:	c7 04 24 a4 e4 10 c0 	movl   $0xc010e4a4,(%esp)
c010a4c2:	e8 76 5f ff ff       	call   c010043d <__panic>
    }

    int ret = -E_NO_MEM;
c010a4c7:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)
    struct mm_struct *mm;
    //(1) create a new mm for current process
    if ((mm = mm_create()) == NULL)
c010a4ce:	e8 49 b1 ff ff       	call   c010561c <mm_create>
c010a4d3:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010a4d6:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c010a4da:	0f 84 0e 06 00 00    	je     c010aaee <load_icode+0x659>
    {
        goto bad_mm;
    }
    //(2) create a new PDT, and mm->pgdir= kernel virtual addr of PDT
    if (setup_pgdir(mm) != 0)
c010a4e0:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a4e3:	89 04 24             	mov    %eax,(%esp)
c010a4e6:	e8 c2 f9 ff ff       	call   c0109ead <setup_pgdir>
c010a4eb:	85 c0                	test   %eax,%eax
c010a4ed:	0f 85 ed 05 00 00    	jne    c010aae0 <load_icode+0x64b>
        goto bad_pgdir_cleanup_mm;
    }
    //(3) copy TEXT/DATA section, build BSS parts in binary to memory space of process
    struct Page *page;
    //(3.1) get the file header of the bianry program (ELF format)
    struct elfhdr *elf = (struct elfhdr *)binary;
c010a4f3:	8b 45 08             	mov    0x8(%ebp),%eax
c010a4f6:	89 45 cc             	mov    %eax,-0x34(%ebp)
    //(3.2) get the entry of the program section headers of the bianry program (ELF format)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
c010a4f9:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010a4fc:	8b 50 1c             	mov    0x1c(%eax),%edx
c010a4ff:	8b 45 08             	mov    0x8(%ebp),%eax
c010a502:	01 d0                	add    %edx,%eax
c010a504:	89 45 ec             	mov    %eax,-0x14(%ebp)
    //(3.3) This program is valid?
    if (elf->e_magic != ELF_MAGIC)
c010a507:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010a50a:	8b 00                	mov    (%eax),%eax
c010a50c:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
c010a511:	74 0c                	je     c010a51f <load_icode+0x8a>
    {
        ret = -E_INVAL_ELF;
c010a513:	c7 45 f4 f8 ff ff ff 	movl   $0xfffffff8,-0xc(%ebp)
        goto bad_elf_cleanup_pgdir;
c010a51a:	e9 b4 05 00 00       	jmp    c010aad3 <load_icode+0x63e>
    }

    uint32_t vm_flags, perm;
    struct proghdr *ph_end = ph + elf->e_phnum;
c010a51f:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010a522:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c010a526:	c1 e0 05             	shl    $0x5,%eax
c010a529:	89 c2                	mov    %eax,%edx
c010a52b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a52e:	01 d0                	add    %edx,%eax
c010a530:	89 45 c8             	mov    %eax,-0x38(%ebp)
    for (; ph < ph_end; ph++)
c010a533:	e9 01 03 00 00       	jmp    c010a839 <load_icode+0x3a4>
    {
        //(3.4) find every program section headers
        if (ph->p_type != ELF_PT_LOAD)
c010a538:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a53b:	8b 00                	mov    (%eax),%eax
c010a53d:	83 f8 01             	cmp    $0x1,%eax
c010a540:	0f 85 e8 02 00 00    	jne    c010a82e <load_icode+0x399>
        {
            continue;
        }
        if (ph->p_filesz > ph->p_memsz)
c010a546:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a549:	8b 50 10             	mov    0x10(%eax),%edx
c010a54c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a54f:	8b 40 14             	mov    0x14(%eax),%eax
c010a552:	39 c2                	cmp    %eax,%edx
c010a554:	76 0c                	jbe    c010a562 <load_icode+0xcd>
        {
            ret = -E_INVAL_ELF;
c010a556:	c7 45 f4 f8 ff ff ff 	movl   $0xfffffff8,-0xc(%ebp)
            goto bad_cleanup_mmap;
c010a55d:	e9 66 05 00 00       	jmp    c010aac8 <load_icode+0x633>
        }
        if (ph->p_filesz == 0)
c010a562:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a565:	8b 40 10             	mov    0x10(%eax),%eax
c010a568:	85 c0                	test   %eax,%eax
c010a56a:	0f 84 c1 02 00 00    	je     c010a831 <load_icode+0x39c>
        {
            continue;
        }
        //(3.5) call mm_map fun to setup the new vma ( ph->p_va, ph->p_memsz)
        vm_flags = 0, perm = PTE_U;
c010a570:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c010a577:	c7 45 e4 04 00 00 00 	movl   $0x4,-0x1c(%ebp)
        if (ph->p_flags & ELF_PF_X)
c010a57e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a581:	8b 40 18             	mov    0x18(%eax),%eax
c010a584:	83 e0 01             	and    $0x1,%eax
c010a587:	85 c0                	test   %eax,%eax
c010a589:	74 04                	je     c010a58f <load_icode+0xfa>
            vm_flags |= VM_EXEC;
c010a58b:	83 4d e8 04          	orl    $0x4,-0x18(%ebp)
        if (ph->p_flags & ELF_PF_W)
c010a58f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a592:	8b 40 18             	mov    0x18(%eax),%eax
c010a595:	83 e0 02             	and    $0x2,%eax
c010a598:	85 c0                	test   %eax,%eax
c010a59a:	74 04                	je     c010a5a0 <load_icode+0x10b>
            vm_flags |= VM_WRITE;
c010a59c:	83 4d e8 02          	orl    $0x2,-0x18(%ebp)
        if (ph->p_flags & ELF_PF_R)
c010a5a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a5a3:	8b 40 18             	mov    0x18(%eax),%eax
c010a5a6:	83 e0 04             	and    $0x4,%eax
c010a5a9:	85 c0                	test   %eax,%eax
c010a5ab:	74 04                	je     c010a5b1 <load_icode+0x11c>
            vm_flags |= VM_READ;
c010a5ad:	83 4d e8 01          	orl    $0x1,-0x18(%ebp)
        if (vm_flags & VM_WRITE)
c010a5b1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a5b4:	83 e0 02             	and    $0x2,%eax
c010a5b7:	85 c0                	test   %eax,%eax
c010a5b9:	74 04                	je     c010a5bf <load_icode+0x12a>
            perm |= PTE_W;
c010a5bb:	83 4d e4 02          	orl    $0x2,-0x1c(%ebp)
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0)
c010a5bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a5c2:	8b 50 14             	mov    0x14(%eax),%edx
c010a5c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a5c8:	8b 40 08             	mov    0x8(%eax),%eax
c010a5cb:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
c010a5d2:	00 
c010a5d3:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c010a5d6:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c010a5da:	89 54 24 08          	mov    %edx,0x8(%esp)
c010a5de:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a5e2:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a5e5:	89 04 24             	mov    %eax,(%esp)
c010a5e8:	e8 47 b4 ff ff       	call   c0105a34 <mm_map>
c010a5ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a5f0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a5f4:	0f 85 c4 04 00 00    	jne    c010aabe <load_icode+0x629>
        {
            goto bad_cleanup_mmap;
        }
        unsigned char *from = binary + ph->p_offset;
c010a5fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a5fd:	8b 50 04             	mov    0x4(%eax),%edx
c010a600:	8b 45 08             	mov    0x8(%ebp),%eax
c010a603:	01 d0                	add    %edx,%eax
c010a605:	89 45 e0             	mov    %eax,-0x20(%ebp)
        size_t off, size;
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
c010a608:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a60b:	8b 40 08             	mov    0x8(%eax),%eax
c010a60e:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010a611:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a614:	89 45 b8             	mov    %eax,-0x48(%ebp)
c010a617:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010a61a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010a61f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

        ret = -E_NO_MEM;
c010a622:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

        //(3.6) alloc memory, and  copy the contents of every program section (from, from+end) to process's memory (la, la+end)
        end = ph->p_va + ph->p_filesz;
c010a629:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a62c:	8b 50 08             	mov    0x8(%eax),%edx
c010a62f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a632:	8b 40 10             	mov    0x10(%eax),%eax
c010a635:	01 d0                	add    %edx,%eax
c010a637:	89 45 b4             	mov    %eax,-0x4c(%ebp)
        //(3.6.1) copy TEXT/DATA section of bianry program
        while (start < end)
c010a63a:	e9 87 00 00 00       	jmp    c010a6c6 <load_icode+0x231>
        {
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
c010a63f:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a642:	8b 40 0c             	mov    0xc(%eax),%eax
c010a645:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010a648:	89 54 24 08          	mov    %edx,0x8(%esp)
c010a64c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010a64f:	89 54 24 04          	mov    %edx,0x4(%esp)
c010a653:	89 04 24             	mov    %eax,(%esp)
c010a656:	e8 79 a1 ff ff       	call   c01047d4 <pgdir_alloc_page>
c010a65b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a65e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a662:	0f 84 59 04 00 00    	je     c010aac1 <load_icode+0x62c>
            {
                goto bad_cleanup_mmap;
            }
            off = start - la, size = PGSIZE - off, la += PGSIZE;
c010a668:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a66b:	2b 45 d4             	sub    -0x2c(%ebp),%eax
c010a66e:	89 45 b0             	mov    %eax,-0x50(%ebp)
c010a671:	b8 00 10 00 00       	mov    $0x1000,%eax
c010a676:	2b 45 b0             	sub    -0x50(%ebp),%eax
c010a679:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010a67c:	81 45 d4 00 10 00 00 	addl   $0x1000,-0x2c(%ebp)
            if (end < la)
c010a683:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010a686:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a689:	73 09                	jae    c010a694 <load_icode+0x1ff>
            {
                size -= la - end;
c010a68b:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010a68e:	2b 45 d4             	sub    -0x2c(%ebp),%eax
c010a691:	01 45 dc             	add    %eax,-0x24(%ebp)
            }
            memcpy(page2kva(page) + off, from, size);
c010a694:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a697:	89 04 24             	mov    %eax,(%esp)
c010a69a:	e8 a5 f0 ff ff       	call   c0109744 <page2kva>
c010a69f:	8b 55 b0             	mov    -0x50(%ebp),%edx
c010a6a2:	01 c2                	add    %eax,%edx
c010a6a4:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a6a7:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a6ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010a6ae:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a6b2:	89 14 24             	mov    %edx,(%esp)
c010a6b5:	e8 da 13 00 00       	call   c010ba94 <memcpy>
            start += size, from += size;
c010a6ba:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a6bd:	01 45 d8             	add    %eax,-0x28(%ebp)
c010a6c0:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a6c3:	01 45 e0             	add    %eax,-0x20(%ebp)
        while (start < end)
c010a6c6:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a6c9:	3b 45 b4             	cmp    -0x4c(%ebp),%eax
c010a6cc:	0f 82 6d ff ff ff    	jb     c010a63f <load_icode+0x1aa>
        }

        //(3.6.2) build BSS section of binary program
        end = ph->p_va + ph->p_memsz;
c010a6d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a6d5:	8b 50 08             	mov    0x8(%eax),%edx
c010a6d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a6db:	8b 40 14             	mov    0x14(%eax),%eax
c010a6de:	01 d0                	add    %edx,%eax
c010a6e0:	89 45 b4             	mov    %eax,-0x4c(%ebp)
        if (start < la)
c010a6e3:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a6e6:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a6e9:	0f 83 31 01 00 00    	jae    c010a820 <load_icode+0x38b>
        {
            /* ph->p_memsz == ph->p_filesz */
            if (start == end)
c010a6ef:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a6f2:	3b 45 b4             	cmp    -0x4c(%ebp),%eax
c010a6f5:	0f 84 39 01 00 00    	je     c010a834 <load_icode+0x39f>
            {
                continue;
            }
            off = start + PGSIZE - la, size = PGSIZE - off;
c010a6fb:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a6fe:	2b 45 d4             	sub    -0x2c(%ebp),%eax
c010a701:	05 00 10 00 00       	add    $0x1000,%eax
c010a706:	89 45 b0             	mov    %eax,-0x50(%ebp)
c010a709:	b8 00 10 00 00       	mov    $0x1000,%eax
c010a70e:	2b 45 b0             	sub    -0x50(%ebp),%eax
c010a711:	89 45 dc             	mov    %eax,-0x24(%ebp)
            if (end < la)
c010a714:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010a717:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a71a:	73 09                	jae    c010a725 <load_icode+0x290>
            {
                size -= la - end;
c010a71c:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010a71f:	2b 45 d4             	sub    -0x2c(%ebp),%eax
c010a722:	01 45 dc             	add    %eax,-0x24(%ebp)
            }
            memset(page2kva(page) + off, 0, size);
c010a725:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a728:	89 04 24             	mov    %eax,(%esp)
c010a72b:	e8 14 f0 ff ff       	call   c0109744 <page2kva>
c010a730:	8b 55 b0             	mov    -0x50(%ebp),%edx
c010a733:	01 c2                	add    %eax,%edx
c010a735:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a738:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a73c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010a743:	00 
c010a744:	89 14 24             	mov    %edx,(%esp)
c010a747:	e8 5e 12 00 00       	call   c010b9aa <memset>
            start += size;
c010a74c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a74f:	01 45 d8             	add    %eax,-0x28(%ebp)
            assert((end < la && start == end) || (end >= la && start == la));
c010a752:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010a755:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a758:	73 0c                	jae    c010a766 <load_icode+0x2d1>
c010a75a:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a75d:	3b 45 b4             	cmp    -0x4c(%ebp),%eax
c010a760:	0f 84 ba 00 00 00    	je     c010a820 <load_icode+0x38b>
c010a766:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010a769:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a76c:	72 0c                	jb     c010a77a <load_icode+0x2e5>
c010a76e:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a771:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a774:	0f 84 a6 00 00 00    	je     c010a820 <load_icode+0x38b>
c010a77a:	c7 44 24 0c 50 e5 10 	movl   $0xc010e550,0xc(%esp)
c010a781:	c0 
c010a782:	c7 44 24 08 d1 e4 10 	movl   $0xc010e4d1,0x8(%esp)
c010a789:	c0 
c010a78a:	c7 44 24 04 95 02 00 	movl   $0x295,0x4(%esp)
c010a791:	00 
c010a792:	c7 04 24 a4 e4 10 c0 	movl   $0xc010e4a4,(%esp)
c010a799:	e8 9f 5c ff ff       	call   c010043d <__panic>
        }
        while (start < end)
        {
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
c010a79e:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a7a1:	8b 40 0c             	mov    0xc(%eax),%eax
c010a7a4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010a7a7:	89 54 24 08          	mov    %edx,0x8(%esp)
c010a7ab:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010a7ae:	89 54 24 04          	mov    %edx,0x4(%esp)
c010a7b2:	89 04 24             	mov    %eax,(%esp)
c010a7b5:	e8 1a a0 ff ff       	call   c01047d4 <pgdir_alloc_page>
c010a7ba:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a7bd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a7c1:	0f 84 fd 02 00 00    	je     c010aac4 <load_icode+0x62f>
            {
                goto bad_cleanup_mmap;
            }
            off = start - la, size = PGSIZE - off, la += PGSIZE;
c010a7c7:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a7ca:	2b 45 d4             	sub    -0x2c(%ebp),%eax
c010a7cd:	89 45 b0             	mov    %eax,-0x50(%ebp)
c010a7d0:	b8 00 10 00 00       	mov    $0x1000,%eax
c010a7d5:	2b 45 b0             	sub    -0x50(%ebp),%eax
c010a7d8:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010a7db:	81 45 d4 00 10 00 00 	addl   $0x1000,-0x2c(%ebp)
            if (end < la)
c010a7e2:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010a7e5:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a7e8:	73 09                	jae    c010a7f3 <load_icode+0x35e>
            {
                size -= la - end;
c010a7ea:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010a7ed:	2b 45 d4             	sub    -0x2c(%ebp),%eax
c010a7f0:	01 45 dc             	add    %eax,-0x24(%ebp)
            }
            memset(page2kva(page) + off, 0, size);
c010a7f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a7f6:	89 04 24             	mov    %eax,(%esp)
c010a7f9:	e8 46 ef ff ff       	call   c0109744 <page2kva>
c010a7fe:	8b 55 b0             	mov    -0x50(%ebp),%edx
c010a801:	01 c2                	add    %eax,%edx
c010a803:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a806:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a80a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010a811:	00 
c010a812:	89 14 24             	mov    %edx,(%esp)
c010a815:	e8 90 11 00 00       	call   c010b9aa <memset>
            start += size;
c010a81a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a81d:	01 45 d8             	add    %eax,-0x28(%ebp)
        while (start < end)
c010a820:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a823:	3b 45 b4             	cmp    -0x4c(%ebp),%eax
c010a826:	0f 82 72 ff ff ff    	jb     c010a79e <load_icode+0x309>
c010a82c:	eb 07                	jmp    c010a835 <load_icode+0x3a0>
            continue;
c010a82e:	90                   	nop
c010a82f:	eb 04                	jmp    c010a835 <load_icode+0x3a0>
            continue;
c010a831:	90                   	nop
c010a832:	eb 01                	jmp    c010a835 <load_icode+0x3a0>
                continue;
c010a834:	90                   	nop
    for (; ph < ph_end; ph++)
c010a835:	83 45 ec 20          	addl   $0x20,-0x14(%ebp)
c010a839:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a83c:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c010a83f:	0f 82 f3 fc ff ff    	jb     c010a538 <load_icode+0xa3>
        }
    }
    //(4) build user stack memory
    vm_flags = VM_READ | VM_WRITE | VM_STACK;
c010a845:	c7 45 e8 0b 00 00 00 	movl   $0xb,-0x18(%ebp)
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0)
c010a84c:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
c010a853:	00 
c010a854:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a857:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010a85b:	c7 44 24 08 00 00 10 	movl   $0x100000,0x8(%esp)
c010a862:	00 
c010a863:	c7 44 24 04 00 00 f0 	movl   $0xaff00000,0x4(%esp)
c010a86a:	af 
c010a86b:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a86e:	89 04 24             	mov    %eax,(%esp)
c010a871:	e8 be b1 ff ff       	call   c0105a34 <mm_map>
c010a876:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a879:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a87d:	0f 85 44 02 00 00    	jne    c010aac7 <load_icode+0x632>
    {
        goto bad_cleanup_mmap;
    }
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) != NULL);
c010a883:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a886:	8b 40 0c             	mov    0xc(%eax),%eax
c010a889:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
c010a890:	00 
c010a891:	c7 44 24 04 00 f0 ff 	movl   $0xaffff000,0x4(%esp)
c010a898:	af 
c010a899:	89 04 24             	mov    %eax,(%esp)
c010a89c:	e8 33 9f ff ff       	call   c01047d4 <pgdir_alloc_page>
c010a8a1:	85 c0                	test   %eax,%eax
c010a8a3:	75 24                	jne    c010a8c9 <load_icode+0x434>
c010a8a5:	c7 44 24 0c 8c e5 10 	movl   $0xc010e58c,0xc(%esp)
c010a8ac:	c0 
c010a8ad:	c7 44 24 08 d1 e4 10 	movl   $0xc010e4d1,0x8(%esp)
c010a8b4:	c0 
c010a8b5:	c7 44 24 04 ac 02 00 	movl   $0x2ac,0x4(%esp)
c010a8bc:	00 
c010a8bd:	c7 04 24 a4 e4 10 c0 	movl   $0xc010e4a4,(%esp)
c010a8c4:	e8 74 5b ff ff       	call   c010043d <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) != NULL);
c010a8c9:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a8cc:	8b 40 0c             	mov    0xc(%eax),%eax
c010a8cf:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
c010a8d6:	00 
c010a8d7:	c7 44 24 04 00 e0 ff 	movl   $0xafffe000,0x4(%esp)
c010a8de:	af 
c010a8df:	89 04 24             	mov    %eax,(%esp)
c010a8e2:	e8 ed 9e ff ff       	call   c01047d4 <pgdir_alloc_page>
c010a8e7:	85 c0                	test   %eax,%eax
c010a8e9:	75 24                	jne    c010a90f <load_icode+0x47a>
c010a8eb:	c7 44 24 0c d0 e5 10 	movl   $0xc010e5d0,0xc(%esp)
c010a8f2:	c0 
c010a8f3:	c7 44 24 08 d1 e4 10 	movl   $0xc010e4d1,0x8(%esp)
c010a8fa:	c0 
c010a8fb:	c7 44 24 04 ad 02 00 	movl   $0x2ad,0x4(%esp)
c010a902:	00 
c010a903:	c7 04 24 a4 e4 10 c0 	movl   $0xc010e4a4,(%esp)
c010a90a:	e8 2e 5b ff ff       	call   c010043d <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) != NULL);
c010a90f:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a912:	8b 40 0c             	mov    0xc(%eax),%eax
c010a915:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
c010a91c:	00 
c010a91d:	c7 44 24 04 00 d0 ff 	movl   $0xafffd000,0x4(%esp)
c010a924:	af 
c010a925:	89 04 24             	mov    %eax,(%esp)
c010a928:	e8 a7 9e ff ff       	call   c01047d4 <pgdir_alloc_page>
c010a92d:	85 c0                	test   %eax,%eax
c010a92f:	75 24                	jne    c010a955 <load_icode+0x4c0>
c010a931:	c7 44 24 0c 18 e6 10 	movl   $0xc010e618,0xc(%esp)
c010a938:	c0 
c010a939:	c7 44 24 08 d1 e4 10 	movl   $0xc010e4d1,0x8(%esp)
c010a940:	c0 
c010a941:	c7 44 24 04 ae 02 00 	movl   $0x2ae,0x4(%esp)
c010a948:	00 
c010a949:	c7 04 24 a4 e4 10 c0 	movl   $0xc010e4a4,(%esp)
c010a950:	e8 e8 5a ff ff       	call   c010043d <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) != NULL);
c010a955:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a958:	8b 40 0c             	mov    0xc(%eax),%eax
c010a95b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
c010a962:	00 
c010a963:	c7 44 24 04 00 c0 ff 	movl   $0xafffc000,0x4(%esp)
c010a96a:	af 
c010a96b:	89 04 24             	mov    %eax,(%esp)
c010a96e:	e8 61 9e ff ff       	call   c01047d4 <pgdir_alloc_page>
c010a973:	85 c0                	test   %eax,%eax
c010a975:	75 24                	jne    c010a99b <load_icode+0x506>
c010a977:	c7 44 24 0c 60 e6 10 	movl   $0xc010e660,0xc(%esp)
c010a97e:	c0 
c010a97f:	c7 44 24 08 d1 e4 10 	movl   $0xc010e4d1,0x8(%esp)
c010a986:	c0 
c010a987:	c7 44 24 04 af 02 00 	movl   $0x2af,0x4(%esp)
c010a98e:	00 
c010a98f:	c7 04 24 a4 e4 10 c0 	movl   $0xc010e4a4,(%esp)
c010a996:	e8 a2 5a ff ff       	call   c010043d <__panic>

    //(5) set current process's mm, sr3, and set CR3 reg = physical addr of Page Directory
    mm_count_inc(mm);
c010a99b:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a99e:	89 04 24             	mov    %eax,(%esp)
c010a9a1:	e8 3c ee ff ff       	call   c01097e2 <mm_count_inc>
    current->mm = mm;
c010a9a6:	a1 28 20 1b c0       	mov    0xc01b2028,%eax
c010a9ab:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010a9ae:	89 50 18             	mov    %edx,0x18(%eax)
    current->cr3 = PADDR(mm->pgdir);
c010a9b1:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a9b4:	8b 40 0c             	mov    0xc(%eax),%eax
c010a9b7:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c010a9ba:	81 7d c4 ff ff ff bf 	cmpl   $0xbfffffff,-0x3c(%ebp)
c010a9c1:	77 23                	ja     c010a9e6 <load_icode+0x551>
c010a9c3:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010a9c6:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010a9ca:	c7 44 24 08 80 e4 10 	movl   $0xc010e480,0x8(%esp)
c010a9d1:	c0 
c010a9d2:	c7 44 24 04 b4 02 00 	movl   $0x2b4,0x4(%esp)
c010a9d9:	00 
c010a9da:	c7 04 24 a4 e4 10 c0 	movl   $0xc010e4a4,(%esp)
c010a9e1:	e8 57 5a ff ff       	call   c010043d <__panic>
c010a9e6:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010a9e9:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c010a9ef:	a1 28 20 1b c0       	mov    0xc01b2028,%eax
c010a9f4:	89 50 40             	mov    %edx,0x40(%eax)
    lcr3(PADDR(mm->pgdir));
c010a9f7:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a9fa:	8b 40 0c             	mov    0xc(%eax),%eax
c010a9fd:	89 45 c0             	mov    %eax,-0x40(%ebp)
c010aa00:	81 7d c0 ff ff ff bf 	cmpl   $0xbfffffff,-0x40(%ebp)
c010aa07:	77 23                	ja     c010aa2c <load_icode+0x597>
c010aa09:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010aa0c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010aa10:	c7 44 24 08 80 e4 10 	movl   $0xc010e480,0x8(%esp)
c010aa17:	c0 
c010aa18:	c7 44 24 04 b5 02 00 	movl   $0x2b5,0x4(%esp)
c010aa1f:	00 
c010aa20:	c7 04 24 a4 e4 10 c0 	movl   $0xc010e4a4,(%esp)
c010aa27:	e8 11 5a ff ff       	call   c010043d <__panic>
c010aa2c:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010aa2f:	05 00 00 00 40       	add    $0x40000000,%eax
c010aa34:	89 45 ac             	mov    %eax,-0x54(%ebp)
    asm volatile ("mov %0, %%cr3" :: "r" (cr3) : "memory");
c010aa37:	8b 45 ac             	mov    -0x54(%ebp),%eax
c010aa3a:	0f 22 d8             	mov    %eax,%cr3
}
c010aa3d:	90                   	nop

    //(6) setup trapframe for user environment
    struct trapframe *tf = current->tf;
c010aa3e:	a1 28 20 1b c0       	mov    0xc01b2028,%eax
c010aa43:	8b 40 3c             	mov    0x3c(%eax),%eax
c010aa46:	89 45 bc             	mov    %eax,-0x44(%ebp)
    memset(tf, 0, sizeof(struct trapframe));
c010aa49:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
c010aa50:	00 
c010aa51:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010aa58:	00 
c010aa59:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010aa5c:	89 04 24             	mov    %eax,(%esp)
c010aa5f:	e8 46 0f 00 00       	call   c010b9aa <memset>
     *          tf_ds=tf_es=tf_ss should be USER_DS segment
     *          tf_esp should be the top addr of user stack (USTACKTOP)
     *          tf_eip should be the entry point of this binary program (elf->e_entry)
     *          tf_eflags should be set to enable computer to produce Interrupt
     */
    tf->tf_cs = USER_CS;
c010aa64:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010aa67:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
    tf->tf_ds = tf->tf_es = tf->tf_ss = USER_DS;
c010aa6d:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010aa70:	66 c7 40 48 23 00    	movw   $0x23,0x48(%eax)
c010aa76:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010aa79:	0f b7 50 48          	movzwl 0x48(%eax),%edx
c010aa7d:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010aa80:	66 89 50 28          	mov    %dx,0x28(%eax)
c010aa84:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010aa87:	0f b7 50 28          	movzwl 0x28(%eax),%edx
c010aa8b:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010aa8e:	66 89 50 2c          	mov    %dx,0x2c(%eax)
    tf->tf_esp = USTACKTOP;
c010aa92:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010aa95:	c7 40 44 00 00 00 b0 	movl   $0xb0000000,0x44(%eax)
    tf->tf_eip = elf->e_entry;
c010aa9c:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010aa9f:	8b 50 18             	mov    0x18(%eax),%edx
c010aaa2:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010aaa5:	89 50 38             	mov    %edx,0x38(%eax)
    tf->tf_eflags = FL_IF;
c010aaa8:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010aaab:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
    ret = 0;
c010aab2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
out:
    return ret;
c010aab9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aabc:	eb 37                	jmp    c010aaf5 <load_icode+0x660>
            goto bad_cleanup_mmap;
c010aabe:	90                   	nop
c010aabf:	eb 07                	jmp    c010aac8 <load_icode+0x633>
                goto bad_cleanup_mmap;
c010aac1:	90                   	nop
c010aac2:	eb 04                	jmp    c010aac8 <load_icode+0x633>
                goto bad_cleanup_mmap;
c010aac4:	90                   	nop
c010aac5:	eb 01                	jmp    c010aac8 <load_icode+0x633>
        goto bad_cleanup_mmap;
c010aac7:	90                   	nop
bad_cleanup_mmap:
    exit_mmap(mm);
c010aac8:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010aacb:	89 04 24             	mov    %eax,(%esp)
c010aace:	e8 82 b1 ff ff       	call   c0105c55 <exit_mmap>
bad_elf_cleanup_pgdir:
    put_pgdir(mm);
c010aad3:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010aad6:	89 04 24             	mov    %eax,(%esp)
c010aad9:	e8 7a f4 ff ff       	call   c0109f58 <put_pgdir>
c010aade:	eb 01                	jmp    c010aae1 <load_icode+0x64c>
        goto bad_pgdir_cleanup_mm;
c010aae0:	90                   	nop
bad_pgdir_cleanup_mm:
    mm_destroy(mm);
c010aae1:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010aae4:	89 04 24             	mov    %eax,(%esp)
c010aae7:	e8 9f ae ff ff       	call   c010598b <mm_destroy>
bad_mm:
    goto out;
c010aaec:	eb cb                	jmp    c010aab9 <load_icode+0x624>
        goto bad_mm;
c010aaee:	90                   	nop
c010aaef:	f3 0f 1e fb          	endbr32 
    goto out;
c010aaf3:	eb c4                	jmp    c010aab9 <load_icode+0x624>
}
c010aaf5:	c9                   	leave  
c010aaf6:	c3                   	ret    

c010aaf7 <do_execve>:

// do_execve - call exit_mmap(mm)&put_pgdir(mm) to reclaim memory space of current process
//           - call load_icode to setup new memory space accroding binary prog.
int do_execve(const char *name, size_t len, unsigned char *binary, size_t size)
{
c010aaf7:	f3 0f 1e fb          	endbr32 
c010aafb:	55                   	push   %ebp
c010aafc:	89 e5                	mov    %esp,%ebp
c010aafe:	83 ec 38             	sub    $0x38,%esp
    struct mm_struct *mm = current->mm;
c010ab01:	a1 28 20 1b c0       	mov    0xc01b2028,%eax
c010ab06:	8b 40 18             	mov    0x18(%eax),%eax
c010ab09:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0))
c010ab0c:	8b 45 08             	mov    0x8(%ebp),%eax
c010ab0f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010ab16:	00 
c010ab17:	8b 55 0c             	mov    0xc(%ebp),%edx
c010ab1a:	89 54 24 08          	mov    %edx,0x8(%esp)
c010ab1e:	89 44 24 04          	mov    %eax,0x4(%esp)
c010ab22:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ab25:	89 04 24             	mov    %eax,(%esp)
c010ab28:	e8 23 bc ff ff       	call   c0106750 <user_mem_check>
c010ab2d:	85 c0                	test   %eax,%eax
c010ab2f:	75 0a                	jne    c010ab3b <do_execve+0x44>
    {
        return -E_INVAL;
c010ab31:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c010ab36:	e9 fb 00 00 00       	jmp    c010ac36 <do_execve+0x13f>
    }
    if (len > PROC_NAME_LEN)
c010ab3b:	83 7d 0c 0f          	cmpl   $0xf,0xc(%ebp)
c010ab3f:	76 07                	jbe    c010ab48 <do_execve+0x51>
    {
        len = PROC_NAME_LEN;
c010ab41:	c7 45 0c 0f 00 00 00 	movl   $0xf,0xc(%ebp)
    }

    char local_name[PROC_NAME_LEN + 1];
    memset(local_name, 0, sizeof(local_name));
c010ab48:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c010ab4f:	00 
c010ab50:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010ab57:	00 
c010ab58:	8d 45 dc             	lea    -0x24(%ebp),%eax
c010ab5b:	89 04 24             	mov    %eax,(%esp)
c010ab5e:	e8 47 0e 00 00       	call   c010b9aa <memset>
    memcpy(local_name, name, len);
c010ab63:	8b 45 0c             	mov    0xc(%ebp),%eax
c010ab66:	89 44 24 08          	mov    %eax,0x8(%esp)
c010ab6a:	8b 45 08             	mov    0x8(%ebp),%eax
c010ab6d:	89 44 24 04          	mov    %eax,0x4(%esp)
c010ab71:	8d 45 dc             	lea    -0x24(%ebp),%eax
c010ab74:	89 04 24             	mov    %eax,(%esp)
c010ab77:	e8 18 0f 00 00       	call   c010ba94 <memcpy>

    if (mm != NULL)
c010ab7c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010ab80:	74 4b                	je     c010abcd <do_execve+0xd6>
    {
        lcr3(boot_cr3);
c010ab82:	a1 5c 40 1b c0       	mov    0xc01b405c,%eax
c010ab87:	89 45 ec             	mov    %eax,-0x14(%ebp)
    asm volatile ("mov %0, %%cr3" :: "r" (cr3) : "memory");
c010ab8a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010ab8d:	0f 22 d8             	mov    %eax,%cr3
}
c010ab90:	90                   	nop
        if (mm_count_dec(mm) == 0)
c010ab91:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ab94:	89 04 24             	mov    %eax,(%esp)
c010ab97:	e8 60 ec ff ff       	call   c01097fc <mm_count_dec>
c010ab9c:	85 c0                	test   %eax,%eax
c010ab9e:	75 21                	jne    c010abc1 <do_execve+0xca>
        {
            exit_mmap(mm);
c010aba0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aba3:	89 04 24             	mov    %eax,(%esp)
c010aba6:	e8 aa b0 ff ff       	call   c0105c55 <exit_mmap>
            put_pgdir(mm);
c010abab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010abae:	89 04 24             	mov    %eax,(%esp)
c010abb1:	e8 a2 f3 ff ff       	call   c0109f58 <put_pgdir>
            mm_destroy(mm);
c010abb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010abb9:	89 04 24             	mov    %eax,(%esp)
c010abbc:	e8 ca ad ff ff       	call   c010598b <mm_destroy>
        }
        current->mm = NULL;
c010abc1:	a1 28 20 1b c0       	mov    0xc01b2028,%eax
c010abc6:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
    }
    int ret;
    if ((ret = load_icode(binary, size)) != 0)
c010abcd:	8b 45 14             	mov    0x14(%ebp),%eax
c010abd0:	89 44 24 04          	mov    %eax,0x4(%esp)
c010abd4:	8b 45 10             	mov    0x10(%ebp),%eax
c010abd7:	89 04 24             	mov    %eax,(%esp)
c010abda:	e8 b6 f8 ff ff       	call   c010a495 <load_icode>
c010abdf:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010abe2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010abe6:	75 1b                	jne    c010ac03 <do_execve+0x10c>
    {
        goto execve_exit;
    }
    set_proc_name(current, local_name);
c010abe8:	a1 28 20 1b c0       	mov    0xc01b2028,%eax
c010abed:	8d 55 dc             	lea    -0x24(%ebp),%edx
c010abf0:	89 54 24 04          	mov    %edx,0x4(%esp)
c010abf4:	89 04 24             	mov    %eax,(%esp)
c010abf7:	e8 49 ed ff ff       	call   c0109945 <set_proc_name>
    return 0;
c010abfc:	b8 00 00 00 00       	mov    $0x0,%eax
c010ac01:	eb 33                	jmp    c010ac36 <do_execve+0x13f>
        goto execve_exit;
c010ac03:	90                   	nop
c010ac04:	f3 0f 1e fb          	endbr32 

execve_exit:
    do_exit(ret);
c010ac08:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010ac0b:	89 04 24             	mov    %eax,(%esp)
c010ac0e:	e8 ae f6 ff ff       	call   c010a2c1 <do_exit>
    panic("already exit: %e.\n", ret);
c010ac13:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010ac16:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010ac1a:	c7 44 24 08 a6 e6 10 	movl   $0xc010e6a6,0x8(%esp)
c010ac21:	c0 
c010ac22:	c7 44 24 04 fc 02 00 	movl   $0x2fc,0x4(%esp)
c010ac29:	00 
c010ac2a:	c7 04 24 a4 e4 10 c0 	movl   $0xc010e4a4,(%esp)
c010ac31:	e8 07 58 ff ff       	call   c010043d <__panic>
}
c010ac36:	c9                   	leave  
c010ac37:	c3                   	ret    

c010ac38 <do_yield>:

// do_yield - ask the scheduler to reschedule
int do_yield(void)
{
c010ac38:	f3 0f 1e fb          	endbr32 
c010ac3c:	55                   	push   %ebp
c010ac3d:	89 e5                	mov    %esp,%ebp
    current->need_resched = 1;
c010ac3f:	a1 28 20 1b c0       	mov    0xc01b2028,%eax
c010ac44:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
    return 0;
c010ac4b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010ac50:	5d                   	pop    %ebp
c010ac51:	c3                   	ret    

c010ac52 <do_wait>:

// do_wait - wait one OR any children with PROC_ZOMBIE state, and free memory space of kernel stack
//         - proc struct of this child.
// NOTE: only after do_wait function, all resources of the child proces are free.
int do_wait(int pid, int *code_store)
{
c010ac52:	f3 0f 1e fb          	endbr32 
c010ac56:	55                   	push   %ebp
c010ac57:	89 e5                	mov    %esp,%ebp
c010ac59:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm = current->mm;
c010ac5c:	a1 28 20 1b c0       	mov    0xc01b2028,%eax
c010ac61:	8b 40 18             	mov    0x18(%eax),%eax
c010ac64:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if (code_store != NULL)
c010ac67:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010ac6b:	74 30                	je     c010ac9d <do_wait+0x4b>
    {
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1))
c010ac6d:	8b 45 0c             	mov    0xc(%ebp),%eax
c010ac70:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
c010ac77:	00 
c010ac78:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
c010ac7f:	00 
c010ac80:	89 44 24 04          	mov    %eax,0x4(%esp)
c010ac84:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010ac87:	89 04 24             	mov    %eax,(%esp)
c010ac8a:	e8 c1 ba ff ff       	call   c0106750 <user_mem_check>
c010ac8f:	85 c0                	test   %eax,%eax
c010ac91:	75 0a                	jne    c010ac9d <do_wait+0x4b>
        {
            return -E_INVAL;
c010ac93:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c010ac98:	e9 47 01 00 00       	jmp    c010ade4 <do_wait+0x192>
        }
    }

    struct proc_struct *proc;
    bool intr_flag, haskid;
repeat:
c010ac9d:	90                   	nop
    haskid = 0;
c010ac9e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    if (pid != 0)
c010aca5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010aca9:	74 36                	je     c010ace1 <do_wait+0x8f>
    {
        proc = find_proc(pid);
c010acab:	8b 45 08             	mov    0x8(%ebp),%eax
c010acae:	89 04 24             	mov    %eax,(%esp)
c010acb1:	e8 9e f0 ff ff       	call   c0109d54 <find_proc>
c010acb6:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (proc != NULL && proc->parent == current)
c010acb9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010acbd:	74 4f                	je     c010ad0e <do_wait+0xbc>
c010acbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010acc2:	8b 50 14             	mov    0x14(%eax),%edx
c010acc5:	a1 28 20 1b c0       	mov    0xc01b2028,%eax
c010acca:	39 c2                	cmp    %eax,%edx
c010accc:	75 40                	jne    c010ad0e <do_wait+0xbc>
        {
            haskid = 1;
c010acce:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
            if (proc->state == PROC_ZOMBIE)
c010acd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010acd8:	8b 00                	mov    (%eax),%eax
c010acda:	83 f8 03             	cmp    $0x3,%eax
c010acdd:	75 2f                	jne    c010ad0e <do_wait+0xbc>
            {
                goto found;
c010acdf:	eb 7e                	jmp    c010ad5f <do_wait+0x10d>
            }
        }
    }
    else
    {
        proc = current->cptr;
c010ace1:	a1 28 20 1b c0       	mov    0xc01b2028,%eax
c010ace6:	8b 40 70             	mov    0x70(%eax),%eax
c010ace9:	89 45 f4             	mov    %eax,-0xc(%ebp)
        for (; proc != NULL; proc = proc->optr)
c010acec:	eb 1a                	jmp    c010ad08 <do_wait+0xb6>
        {
            haskid = 1;
c010acee:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
            if (proc->state == PROC_ZOMBIE)
c010acf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010acf8:	8b 00                	mov    (%eax),%eax
c010acfa:	83 f8 03             	cmp    $0x3,%eax
c010acfd:	74 5f                	je     c010ad5e <do_wait+0x10c>
        for (; proc != NULL; proc = proc->optr)
c010acff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ad02:	8b 40 78             	mov    0x78(%eax),%eax
c010ad05:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010ad08:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010ad0c:	75 e0                	jne    c010acee <do_wait+0x9c>
            {
                goto found;
            }
        }
    }
    if (haskid)
c010ad0e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010ad12:	74 40                	je     c010ad54 <do_wait+0x102>
    {
        current->state = PROC_SLEEPING;
c010ad14:	a1 28 20 1b c0       	mov    0xc01b2028,%eax
c010ad19:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
        current->wait_state = WT_CHILD;
c010ad1f:	a1 28 20 1b c0       	mov    0xc01b2028,%eax
c010ad24:	c7 40 6c 01 00 00 80 	movl   $0x80000001,0x6c(%eax)
        schedule();
c010ad2b:	e8 48 06 00 00       	call   c010b378 <schedule>
        if (current->flags & PF_EXITING)
c010ad30:	a1 28 20 1b c0       	mov    0xc01b2028,%eax
c010ad35:	8b 40 44             	mov    0x44(%eax),%eax
c010ad38:	83 e0 01             	and    $0x1,%eax
c010ad3b:	85 c0                	test   %eax,%eax
c010ad3d:	0f 84 5b ff ff ff    	je     c010ac9e <do_wait+0x4c>
        {
            do_exit(-E_KILLED);
c010ad43:	c7 04 24 f7 ff ff ff 	movl   $0xfffffff7,(%esp)
c010ad4a:	e8 72 f5 ff ff       	call   c010a2c1 <do_exit>
        }
        goto repeat;
c010ad4f:	e9 4a ff ff ff       	jmp    c010ac9e <do_wait+0x4c>
    }
    return -E_BAD_PROC;
c010ad54:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
c010ad59:	e9 86 00 00 00       	jmp    c010ade4 <do_wait+0x192>
                goto found;
c010ad5e:	90                   	nop

found:
    if (proc == idleproc || proc == initproc)
c010ad5f:	a1 20 20 1b c0       	mov    0xc01b2020,%eax
c010ad64:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010ad67:	74 0a                	je     c010ad73 <do_wait+0x121>
c010ad69:	a1 24 20 1b c0       	mov    0xc01b2024,%eax
c010ad6e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010ad71:	75 1c                	jne    c010ad8f <do_wait+0x13d>
    {
        panic("wait idleproc or initproc.\n");
c010ad73:	c7 44 24 08 b9 e6 10 	movl   $0xc010e6b9,0x8(%esp)
c010ad7a:	c0 
c010ad7b:	c7 44 24 04 40 03 00 	movl   $0x340,0x4(%esp)
c010ad82:	00 
c010ad83:	c7 04 24 a4 e4 10 c0 	movl   $0xc010e4a4,(%esp)
c010ad8a:	e8 ae 56 ff ff       	call   c010043d <__panic>
    }
    if (code_store != NULL)
c010ad8f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010ad93:	74 0b                	je     c010ada0 <do_wait+0x14e>
    {
        *code_store = proc->exit_code;
c010ad95:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ad98:	8b 50 68             	mov    0x68(%eax),%edx
c010ad9b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010ad9e:	89 10                	mov    %edx,(%eax)
    }
    local_intr_save(intr_flag);
c010ada0:	e8 73 e8 ff ff       	call   c0109618 <__intr_save>
c010ada5:	89 45 e8             	mov    %eax,-0x18(%ebp)
    {
        unhash_proc(proc);
c010ada8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010adab:	89 04 24             	mov    %eax,(%esp)
c010adae:	e8 67 ef ff ff       	call   c0109d1a <unhash_proc>
        remove_links(proc);
c010adb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010adb6:	89 04 24             	mov    %eax,(%esp)
c010adb9:	e8 bf ec ff ff       	call   c0109a7d <remove_links>
    }
    local_intr_restore(intr_flag);
c010adbe:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010adc1:	89 04 24             	mov    %eax,(%esp)
c010adc4:	e8 79 e8 ff ff       	call   c0109642 <__intr_restore>
    put_kstack(proc);
c010adc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010adcc:	89 04 24             	mov    %eax,(%esp)
c010adcf:	e8 ae f0 ff ff       	call   c0109e82 <put_kstack>
    kfree(proc);
c010add4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010add7:	89 04 24             	mov    %eax,(%esp)
c010adda:	e8 4d cd ff ff       	call   c0107b2c <kfree>
    return 0;
c010addf:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010ade4:	c9                   	leave  
c010ade5:	c3                   	ret    

c010ade6 <do_kill>:

// do_kill - kill process with pid by set this process's flags with PF_EXITING
int do_kill(int pid)
{
c010ade6:	f3 0f 1e fb          	endbr32 
c010adea:	55                   	push   %ebp
c010adeb:	89 e5                	mov    %esp,%ebp
c010aded:	83 ec 28             	sub    $0x28,%esp
    struct proc_struct *proc;
    if ((proc = find_proc(pid)) != NULL)
c010adf0:	8b 45 08             	mov    0x8(%ebp),%eax
c010adf3:	89 04 24             	mov    %eax,(%esp)
c010adf6:	e8 59 ef ff ff       	call   c0109d54 <find_proc>
c010adfb:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010adfe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010ae02:	74 41                	je     c010ae45 <do_kill+0x5f>
    {
        if (!(proc->flags & PF_EXITING))
c010ae04:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ae07:	8b 40 44             	mov    0x44(%eax),%eax
c010ae0a:	83 e0 01             	and    $0x1,%eax
c010ae0d:	85 c0                	test   %eax,%eax
c010ae0f:	75 2d                	jne    c010ae3e <do_kill+0x58>
        {
            proc->flags |= PF_EXITING;
c010ae11:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ae14:	8b 40 44             	mov    0x44(%eax),%eax
c010ae17:	83 c8 01             	or     $0x1,%eax
c010ae1a:	89 c2                	mov    %eax,%edx
c010ae1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ae1f:	89 50 44             	mov    %edx,0x44(%eax)
            if (proc->wait_state & WT_INTERRUPTED)
c010ae22:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ae25:	8b 40 6c             	mov    0x6c(%eax),%eax
c010ae28:	85 c0                	test   %eax,%eax
c010ae2a:	79 0b                	jns    c010ae37 <do_kill+0x51>
            {
                wakeup_proc(proc);
c010ae2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ae2f:	89 04 24             	mov    %eax,(%esp)
c010ae32:	e8 b8 04 00 00       	call   c010b2ef <wakeup_proc>
            }
            return 0;
c010ae37:	b8 00 00 00 00       	mov    $0x0,%eax
c010ae3c:	eb 0c                	jmp    c010ae4a <do_kill+0x64>
        }
        return -E_KILLED;
c010ae3e:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
c010ae43:	eb 05                	jmp    c010ae4a <do_kill+0x64>
    }
    return -E_INVAL;
c010ae45:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
c010ae4a:	c9                   	leave  
c010ae4b:	c3                   	ret    

c010ae4c <kernel_execve>:

// kernel_execve - do SYS_exec syscall to exec a user program called by user_main kernel_thread
static int
kernel_execve(const char *name, unsigned char *binary, size_t size)
{
c010ae4c:	f3 0f 1e fb          	endbr32 
c010ae50:	55                   	push   %ebp
c010ae51:	89 e5                	mov    %esp,%ebp
c010ae53:	57                   	push   %edi
c010ae54:	56                   	push   %esi
c010ae55:	53                   	push   %ebx
c010ae56:	83 ec 2c             	sub    $0x2c,%esp
    int ret, len = strlen(name);
c010ae59:	8b 45 08             	mov    0x8(%ebp),%eax
c010ae5c:	89 04 24             	mov    %eax,(%esp)
c010ae5f:	e8 04 08 00 00       	call   c010b668 <strlen>
c010ae64:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    asm volatile(
c010ae67:	b8 04 00 00 00       	mov    $0x4,%eax
c010ae6c:	8b 55 08             	mov    0x8(%ebp),%edx
c010ae6f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
c010ae72:	8b 5d 0c             	mov    0xc(%ebp),%ebx
c010ae75:	8b 75 10             	mov    0x10(%ebp),%esi
c010ae78:	89 f7                	mov    %esi,%edi
c010ae7a:	cd 80                	int    $0x80
c010ae7c:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "int %1;"
        : "=a"(ret)
        : "i"(T_SYSCALL), "0"(SYS_exec), "d"(name), "c"(len), "b"(binary), "D"(size)
        : "memory");
    return ret;
c010ae7f:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
c010ae82:	83 c4 2c             	add    $0x2c,%esp
c010ae85:	5b                   	pop    %ebx
c010ae86:	5e                   	pop    %esi
c010ae87:	5f                   	pop    %edi
c010ae88:	5d                   	pop    %ebp
c010ae89:	c3                   	ret    

c010ae8a <user_main>:
#define KERNEL_EXECVE2(x, xstart, xsize) __KERNEL_EXECVE2(x, xstart, xsize)

// user_main - kernel thread used to exec a user program
static int
user_main(void *arg)
{
c010ae8a:	f3 0f 1e fb          	endbr32 
c010ae8e:	55                   	push   %ebp
c010ae8f:	89 e5                	mov    %esp,%ebp
c010ae91:	83 ec 18             	sub    $0x18,%esp
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
c010ae94:	a1 28 20 1b c0       	mov    0xc01b2028,%eax
c010ae99:	8b 40 04             	mov    0x4(%eax),%eax
c010ae9c:	c7 44 24 08 d5 e6 10 	movl   $0xc010e6d5,0x8(%esp)
c010aea3:	c0 
c010aea4:	89 44 24 04          	mov    %eax,0x4(%esp)
c010aea8:	c7 04 24 e0 e6 10 c0 	movl   $0xc010e6e0,(%esp)
c010aeaf:	e8 1d 54 ff ff       	call   c01002d1 <cprintf>
c010aeb4:	b8 8c 88 00 00       	mov    $0x888c,%eax
c010aeb9:	89 44 24 08          	mov    %eax,0x8(%esp)
c010aebd:	c7 44 24 04 d4 fb 13 	movl   $0xc013fbd4,0x4(%esp)
c010aec4:	c0 
c010aec5:	c7 04 24 d5 e6 10 c0 	movl   $0xc010e6d5,(%esp)
c010aecc:	e8 7b ff ff ff       	call   c010ae4c <kernel_execve>
#else
    KERNEL_EXECVE(exit);
#endif
    panic("user_main execve failed.\n");
c010aed1:	c7 44 24 08 07 e7 10 	movl   $0xc010e707,0x8(%esp)
c010aed8:	c0 
c010aed9:	c7 44 24 04 8f 03 00 	movl   $0x38f,0x4(%esp)
c010aee0:	00 
c010aee1:	c7 04 24 a4 e4 10 c0 	movl   $0xc010e4a4,(%esp)
c010aee8:	e8 50 55 ff ff       	call   c010043d <__panic>

c010aeed <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg)
{
c010aeed:	f3 0f 1e fb          	endbr32 
c010aef1:	55                   	push   %ebp
c010aef2:	89 e5                	mov    %esp,%ebp
c010aef4:	83 ec 38             	sub    $0x38,%esp
    size_t nr_free_pages_store = nr_free_pages();
c010aef7:	e8 1f 8b ff ff       	call   c0103a1b <nr_free_pages>
c010aefc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    size_t kernel_allocated_store = kallocated();
c010aeff:	e8 de ca ff ff       	call   c01079e2 <kallocated>
c010af04:	89 45 f0             	mov    %eax,-0x10(%ebp)

    int pid = kernel_thread(user_main, NULL, 0);
c010af07:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010af0e:	00 
c010af0f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010af16:	00 
c010af17:	c7 04 24 8a ae 10 c0 	movl   $0xc010ae8a,(%esp)
c010af1e:	e8 a7 ee ff ff       	call   c0109dca <kernel_thread>
c010af23:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if (pid <= 0)
c010af26:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010af2a:	7f 21                	jg     c010af4d <init_main+0x60>
    {
        panic("create user_main failed.\n");
c010af2c:	c7 44 24 08 21 e7 10 	movl   $0xc010e721,0x8(%esp)
c010af33:	c0 
c010af34:	c7 44 24 04 9c 03 00 	movl   $0x39c,0x4(%esp)
c010af3b:	00 
c010af3c:	c7 04 24 a4 e4 10 c0 	movl   $0xc010e4a4,(%esp)
c010af43:	e8 f5 54 ff ff       	call   c010043d <__panic>
    }

    while (do_wait(0, NULL) == 0)
    {
        schedule();
c010af48:	e8 2b 04 00 00       	call   c010b378 <schedule>
    while (do_wait(0, NULL) == 0)
c010af4d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010af54:	00 
c010af55:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010af5c:	e8 f1 fc ff ff       	call   c010ac52 <do_wait>
c010af61:	85 c0                	test   %eax,%eax
c010af63:	74 e3                	je     c010af48 <init_main+0x5b>
    }

    cprintf("all user-mode processes have quit.\n");
c010af65:	c7 04 24 3c e7 10 c0 	movl   $0xc010e73c,(%esp)
c010af6c:	e8 60 53 ff ff       	call   c01002d1 <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
c010af71:	a1 24 20 1b c0       	mov    0xc01b2024,%eax
c010af76:	8b 40 70             	mov    0x70(%eax),%eax
c010af79:	85 c0                	test   %eax,%eax
c010af7b:	75 18                	jne    c010af95 <init_main+0xa8>
c010af7d:	a1 24 20 1b c0       	mov    0xc01b2024,%eax
c010af82:	8b 40 74             	mov    0x74(%eax),%eax
c010af85:	85 c0                	test   %eax,%eax
c010af87:	75 0c                	jne    c010af95 <init_main+0xa8>
c010af89:	a1 24 20 1b c0       	mov    0xc01b2024,%eax
c010af8e:	8b 40 78             	mov    0x78(%eax),%eax
c010af91:	85 c0                	test   %eax,%eax
c010af93:	74 24                	je     c010afb9 <init_main+0xcc>
c010af95:	c7 44 24 0c 60 e7 10 	movl   $0xc010e760,0xc(%esp)
c010af9c:	c0 
c010af9d:	c7 44 24 08 d1 e4 10 	movl   $0xc010e4d1,0x8(%esp)
c010afa4:	c0 
c010afa5:	c7 44 24 04 a5 03 00 	movl   $0x3a5,0x4(%esp)
c010afac:	00 
c010afad:	c7 04 24 a4 e4 10 c0 	movl   $0xc010e4a4,(%esp)
c010afb4:	e8 84 54 ff ff       	call   c010043d <__panic>
    assert(nr_process == 2);
c010afb9:	a1 40 40 1b c0       	mov    0xc01b4040,%eax
c010afbe:	83 f8 02             	cmp    $0x2,%eax
c010afc1:	74 24                	je     c010afe7 <init_main+0xfa>
c010afc3:	c7 44 24 0c ab e7 10 	movl   $0xc010e7ab,0xc(%esp)
c010afca:	c0 
c010afcb:	c7 44 24 08 d1 e4 10 	movl   $0xc010e4d1,0x8(%esp)
c010afd2:	c0 
c010afd3:	c7 44 24 04 a6 03 00 	movl   $0x3a6,0x4(%esp)
c010afda:	00 
c010afdb:	c7 04 24 a4 e4 10 c0 	movl   $0xc010e4a4,(%esp)
c010afe2:	e8 56 54 ff ff       	call   c010043d <__panic>
c010afe7:	c7 45 e8 58 41 1b c0 	movl   $0xc01b4158,-0x18(%ebp)
c010afee:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010aff1:	8b 40 04             	mov    0x4(%eax),%eax
    assert(list_next(&proc_list) == &(initproc->list_link));
c010aff4:	8b 15 24 20 1b c0    	mov    0xc01b2024,%edx
c010affa:	83 c2 58             	add    $0x58,%edx
c010affd:	39 d0                	cmp    %edx,%eax
c010afff:	74 24                	je     c010b025 <init_main+0x138>
c010b001:	c7 44 24 0c bc e7 10 	movl   $0xc010e7bc,0xc(%esp)
c010b008:	c0 
c010b009:	c7 44 24 08 d1 e4 10 	movl   $0xc010e4d1,0x8(%esp)
c010b010:	c0 
c010b011:	c7 44 24 04 a7 03 00 	movl   $0x3a7,0x4(%esp)
c010b018:	00 
c010b019:	c7 04 24 a4 e4 10 c0 	movl   $0xc010e4a4,(%esp)
c010b020:	e8 18 54 ff ff       	call   c010043d <__panic>
c010b025:	c7 45 e4 58 41 1b c0 	movl   $0xc01b4158,-0x1c(%ebp)
    return listelm->prev;
c010b02c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010b02f:	8b 00                	mov    (%eax),%eax
    assert(list_prev(&proc_list) == &(initproc->list_link));
c010b031:	8b 15 24 20 1b c0    	mov    0xc01b2024,%edx
c010b037:	83 c2 58             	add    $0x58,%edx
c010b03a:	39 d0                	cmp    %edx,%eax
c010b03c:	74 24                	je     c010b062 <init_main+0x175>
c010b03e:	c7 44 24 0c ec e7 10 	movl   $0xc010e7ec,0xc(%esp)
c010b045:	c0 
c010b046:	c7 44 24 08 d1 e4 10 	movl   $0xc010e4d1,0x8(%esp)
c010b04d:	c0 
c010b04e:	c7 44 24 04 a8 03 00 	movl   $0x3a8,0x4(%esp)
c010b055:	00 
c010b056:	c7 04 24 a4 e4 10 c0 	movl   $0xc010e4a4,(%esp)
c010b05d:	e8 db 53 ff ff       	call   c010043d <__panic>
    assert(nr_free_pages_store == nr_free_pages());
c010b062:	e8 b4 89 ff ff       	call   c0103a1b <nr_free_pages>
c010b067:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010b06a:	74 24                	je     c010b090 <init_main+0x1a3>
c010b06c:	c7 44 24 0c 1c e8 10 	movl   $0xc010e81c,0xc(%esp)
c010b073:	c0 
c010b074:	c7 44 24 08 d1 e4 10 	movl   $0xc010e4d1,0x8(%esp)
c010b07b:	c0 
c010b07c:	c7 44 24 04 a9 03 00 	movl   $0x3a9,0x4(%esp)
c010b083:	00 
c010b084:	c7 04 24 a4 e4 10 c0 	movl   $0xc010e4a4,(%esp)
c010b08b:	e8 ad 53 ff ff       	call   c010043d <__panic>
    assert(kernel_allocated_store == kallocated());
c010b090:	e8 4d c9 ff ff       	call   c01079e2 <kallocated>
c010b095:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010b098:	74 24                	je     c010b0be <init_main+0x1d1>
c010b09a:	c7 44 24 0c 44 e8 10 	movl   $0xc010e844,0xc(%esp)
c010b0a1:	c0 
c010b0a2:	c7 44 24 08 d1 e4 10 	movl   $0xc010e4d1,0x8(%esp)
c010b0a9:	c0 
c010b0aa:	c7 44 24 04 aa 03 00 	movl   $0x3aa,0x4(%esp)
c010b0b1:	00 
c010b0b2:	c7 04 24 a4 e4 10 c0 	movl   $0xc010e4a4,(%esp)
c010b0b9:	e8 7f 53 ff ff       	call   c010043d <__panic>
    cprintf("init check memory pass.\n");
c010b0be:	c7 04 24 6b e8 10 c0 	movl   $0xc010e86b,(%esp)
c010b0c5:	e8 07 52 ff ff       	call   c01002d1 <cprintf>
    return 0;
c010b0ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b0cf:	c9                   	leave  
c010b0d0:	c3                   	ret    

c010b0d1 <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and
//           - create the second kernel thread init_main
void proc_init(void)
{
c010b0d1:	f3 0f 1e fb          	endbr32 
c010b0d5:	55                   	push   %ebp
c010b0d6:	89 e5                	mov    %esp,%ebp
c010b0d8:	83 ec 28             	sub    $0x28,%esp
c010b0db:	c7 45 ec 58 41 1b c0 	movl   $0xc01b4158,-0x14(%ebp)
    elm->prev = elm->next = elm;
c010b0e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010b0e5:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010b0e8:	89 50 04             	mov    %edx,0x4(%eax)
c010b0eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010b0ee:	8b 50 04             	mov    0x4(%eax),%edx
c010b0f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010b0f4:	89 10                	mov    %edx,(%eax)
}
c010b0f6:	90                   	nop
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i++)
c010b0f7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010b0fe:	eb 26                	jmp    c010b126 <proc_init+0x55>
    {
        list_init(hash_list + i);
c010b100:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b103:	c1 e0 03             	shl    $0x3,%eax
c010b106:	05 40 20 1b c0       	add    $0xc01b2040,%eax
c010b10b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    elm->prev = elm->next = elm;
c010b10e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b111:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010b114:	89 50 04             	mov    %edx,0x4(%eax)
c010b117:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b11a:	8b 50 04             	mov    0x4(%eax),%edx
c010b11d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b120:	89 10                	mov    %edx,(%eax)
}
c010b122:	90                   	nop
    for (i = 0; i < HASH_LIST_SIZE; i++)
c010b123:	ff 45 f4             	incl   -0xc(%ebp)
c010b126:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
c010b12d:	7e d1                	jle    c010b100 <proc_init+0x2f>
    }

    if ((idleproc = alloc_proc()) == NULL)
c010b12f:	e8 1c e7 ff ff       	call   c0109850 <alloc_proc>
c010b134:	a3 20 20 1b c0       	mov    %eax,0xc01b2020
c010b139:	a1 20 20 1b c0       	mov    0xc01b2020,%eax
c010b13e:	85 c0                	test   %eax,%eax
c010b140:	75 1c                	jne    c010b15e <proc_init+0x8d>
    {
        panic("cannot alloc idleproc.\n");
c010b142:	c7 44 24 08 84 e8 10 	movl   $0xc010e884,0x8(%esp)
c010b149:	c0 
c010b14a:	c7 44 24 04 bd 03 00 	movl   $0x3bd,0x4(%esp)
c010b151:	00 
c010b152:	c7 04 24 a4 e4 10 c0 	movl   $0xc010e4a4,(%esp)
c010b159:	e8 df 52 ff ff       	call   c010043d <__panic>
    }

    idleproc->pid = 0;
c010b15e:	a1 20 20 1b c0       	mov    0xc01b2020,%eax
c010b163:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    idleproc->state = PROC_RUNNABLE;
c010b16a:	a1 20 20 1b c0       	mov    0xc01b2020,%eax
c010b16f:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
    idleproc->kstack = (uintptr_t)bootstack;
c010b175:	a1 20 20 1b c0       	mov    0xc01b2020,%eax
c010b17a:	ba 00 c0 12 c0       	mov    $0xc012c000,%edx
c010b17f:	89 50 0c             	mov    %edx,0xc(%eax)
    idleproc->need_resched = 1;
c010b182:	a1 20 20 1b c0       	mov    0xc01b2020,%eax
c010b187:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
    set_proc_name(idleproc, "idle");
c010b18e:	a1 20 20 1b c0       	mov    0xc01b2020,%eax
c010b193:	c7 44 24 04 9c e8 10 	movl   $0xc010e89c,0x4(%esp)
c010b19a:	c0 
c010b19b:	89 04 24             	mov    %eax,(%esp)
c010b19e:	e8 a2 e7 ff ff       	call   c0109945 <set_proc_name>
    nr_process++;
c010b1a3:	a1 40 40 1b c0       	mov    0xc01b4040,%eax
c010b1a8:	40                   	inc    %eax
c010b1a9:	a3 40 40 1b c0       	mov    %eax,0xc01b4040

    current = idleproc;
c010b1ae:	a1 20 20 1b c0       	mov    0xc01b2020,%eax
c010b1b3:	a3 28 20 1b c0       	mov    %eax,0xc01b2028

    int pid = kernel_thread(init_main, NULL, 0);
c010b1b8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010b1bf:	00 
c010b1c0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010b1c7:	00 
c010b1c8:	c7 04 24 ed ae 10 c0 	movl   $0xc010aeed,(%esp)
c010b1cf:	e8 f6 eb ff ff       	call   c0109dca <kernel_thread>
c010b1d4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (pid <= 0)
c010b1d7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010b1db:	7f 1c                	jg     c010b1f9 <proc_init+0x128>
    {
        panic("create init_main failed.\n");
c010b1dd:	c7 44 24 08 a1 e8 10 	movl   $0xc010e8a1,0x8(%esp)
c010b1e4:	c0 
c010b1e5:	c7 44 24 04 cc 03 00 	movl   $0x3cc,0x4(%esp)
c010b1ec:	00 
c010b1ed:	c7 04 24 a4 e4 10 c0 	movl   $0xc010e4a4,(%esp)
c010b1f4:	e8 44 52 ff ff       	call   c010043d <__panic>
    }

    initproc = find_proc(pid);
c010b1f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b1fc:	89 04 24             	mov    %eax,(%esp)
c010b1ff:	e8 50 eb ff ff       	call   c0109d54 <find_proc>
c010b204:	a3 24 20 1b c0       	mov    %eax,0xc01b2024
    set_proc_name(initproc, "init");
c010b209:	a1 24 20 1b c0       	mov    0xc01b2024,%eax
c010b20e:	c7 44 24 04 bb e8 10 	movl   $0xc010e8bb,0x4(%esp)
c010b215:	c0 
c010b216:	89 04 24             	mov    %eax,(%esp)
c010b219:	e8 27 e7 ff ff       	call   c0109945 <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
c010b21e:	a1 20 20 1b c0       	mov    0xc01b2020,%eax
c010b223:	85 c0                	test   %eax,%eax
c010b225:	74 0c                	je     c010b233 <proc_init+0x162>
c010b227:	a1 20 20 1b c0       	mov    0xc01b2020,%eax
c010b22c:	8b 40 04             	mov    0x4(%eax),%eax
c010b22f:	85 c0                	test   %eax,%eax
c010b231:	74 24                	je     c010b257 <proc_init+0x186>
c010b233:	c7 44 24 0c c0 e8 10 	movl   $0xc010e8c0,0xc(%esp)
c010b23a:	c0 
c010b23b:	c7 44 24 08 d1 e4 10 	movl   $0xc010e4d1,0x8(%esp)
c010b242:	c0 
c010b243:	c7 44 24 04 d2 03 00 	movl   $0x3d2,0x4(%esp)
c010b24a:	00 
c010b24b:	c7 04 24 a4 e4 10 c0 	movl   $0xc010e4a4,(%esp)
c010b252:	e8 e6 51 ff ff       	call   c010043d <__panic>
    assert(initproc != NULL && initproc->pid == 1);
c010b257:	a1 24 20 1b c0       	mov    0xc01b2024,%eax
c010b25c:	85 c0                	test   %eax,%eax
c010b25e:	74 0d                	je     c010b26d <proc_init+0x19c>
c010b260:	a1 24 20 1b c0       	mov    0xc01b2024,%eax
c010b265:	8b 40 04             	mov    0x4(%eax),%eax
c010b268:	83 f8 01             	cmp    $0x1,%eax
c010b26b:	74 24                	je     c010b291 <proc_init+0x1c0>
c010b26d:	c7 44 24 0c e8 e8 10 	movl   $0xc010e8e8,0xc(%esp)
c010b274:	c0 
c010b275:	c7 44 24 08 d1 e4 10 	movl   $0xc010e4d1,0x8(%esp)
c010b27c:	c0 
c010b27d:	c7 44 24 04 d3 03 00 	movl   $0x3d3,0x4(%esp)
c010b284:	00 
c010b285:	c7 04 24 a4 e4 10 c0 	movl   $0xc010e4a4,(%esp)
c010b28c:	e8 ac 51 ff ff       	call   c010043d <__panic>
}
c010b291:	90                   	nop
c010b292:	c9                   	leave  
c010b293:	c3                   	ret    

c010b294 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void cpu_idle(void)
{
c010b294:	f3 0f 1e fb          	endbr32 
c010b298:	55                   	push   %ebp
c010b299:	89 e5                	mov    %esp,%ebp
c010b29b:	83 ec 08             	sub    $0x8,%esp
    while (1)
    {
        if (current->need_resched)
c010b29e:	a1 28 20 1b c0       	mov    0xc01b2028,%eax
c010b2a3:	8b 40 10             	mov    0x10(%eax),%eax
c010b2a6:	85 c0                	test   %eax,%eax
c010b2a8:	74 f4                	je     c010b29e <cpu_idle+0xa>
        {
            schedule();
c010b2aa:	e8 c9 00 00 00       	call   c010b378 <schedule>
        if (current->need_resched)
c010b2af:	eb ed                	jmp    c010b29e <cpu_idle+0xa>

c010b2b1 <__intr_save>:
__intr_save(void) {
c010b2b1:	55                   	push   %ebp
c010b2b2:	89 e5                	mov    %esp,%ebp
c010b2b4:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c010b2b7:	9c                   	pushf  
c010b2b8:	58                   	pop    %eax
c010b2b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c010b2bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c010b2bf:	25 00 02 00 00       	and    $0x200,%eax
c010b2c4:	85 c0                	test   %eax,%eax
c010b2c6:	74 0c                	je     c010b2d4 <__intr_save+0x23>
        intr_disable();
c010b2c8:	e8 2b 70 ff ff       	call   c01022f8 <intr_disable>
        return 1;
c010b2cd:	b8 01 00 00 00       	mov    $0x1,%eax
c010b2d2:	eb 05                	jmp    c010b2d9 <__intr_save+0x28>
    return 0;
c010b2d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b2d9:	c9                   	leave  
c010b2da:	c3                   	ret    

c010b2db <__intr_restore>:
__intr_restore(bool flag) {
c010b2db:	55                   	push   %ebp
c010b2dc:	89 e5                	mov    %esp,%ebp
c010b2de:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c010b2e1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010b2e5:	74 05                	je     c010b2ec <__intr_restore+0x11>
        intr_enable();
c010b2e7:	e8 00 70 ff ff       	call   c01022ec <intr_enable>
}
c010b2ec:	90                   	nop
c010b2ed:	c9                   	leave  
c010b2ee:	c3                   	ret    

c010b2ef <wakeup_proc>:
#include <proc.h>
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
c010b2ef:	f3 0f 1e fb          	endbr32 
c010b2f3:	55                   	push   %ebp
c010b2f4:	89 e5                	mov    %esp,%ebp
c010b2f6:	83 ec 28             	sub    $0x28,%esp
    assert(proc->state != PROC_ZOMBIE);
c010b2f9:	8b 45 08             	mov    0x8(%ebp),%eax
c010b2fc:	8b 00                	mov    (%eax),%eax
c010b2fe:	83 f8 03             	cmp    $0x3,%eax
c010b301:	75 24                	jne    c010b327 <wakeup_proc+0x38>
c010b303:	c7 44 24 0c 0f e9 10 	movl   $0xc010e90f,0xc(%esp)
c010b30a:	c0 
c010b30b:	c7 44 24 08 2a e9 10 	movl   $0xc010e92a,0x8(%esp)
c010b312:	c0 
c010b313:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
c010b31a:	00 
c010b31b:	c7 04 24 3f e9 10 c0 	movl   $0xc010e93f,(%esp)
c010b322:	e8 16 51 ff ff       	call   c010043d <__panic>
    bool intr_flag;
    local_intr_save(intr_flag);
c010b327:	e8 85 ff ff ff       	call   c010b2b1 <__intr_save>
c010b32c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        if (proc->state != PROC_RUNNABLE) {
c010b32f:	8b 45 08             	mov    0x8(%ebp),%eax
c010b332:	8b 00                	mov    (%eax),%eax
c010b334:	83 f8 02             	cmp    $0x2,%eax
c010b337:	74 15                	je     c010b34e <wakeup_proc+0x5f>
            proc->state = PROC_RUNNABLE;
c010b339:	8b 45 08             	mov    0x8(%ebp),%eax
c010b33c:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
            proc->wait_state = 0;
c010b342:	8b 45 08             	mov    0x8(%ebp),%eax
c010b345:	c7 40 6c 00 00 00 00 	movl   $0x0,0x6c(%eax)
c010b34c:	eb 1c                	jmp    c010b36a <wakeup_proc+0x7b>
        }
        else {
            warn("wakeup runnable process.\n");
c010b34e:	c7 44 24 08 55 e9 10 	movl   $0xc010e955,0x8(%esp)
c010b355:	c0 
c010b356:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
c010b35d:	00 
c010b35e:	c7 04 24 3f e9 10 c0 	movl   $0xc010e93f,(%esp)
c010b365:	e8 55 51 ff ff       	call   c01004bf <__warn>
        }
    }
    local_intr_restore(intr_flag);
c010b36a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b36d:	89 04 24             	mov    %eax,(%esp)
c010b370:	e8 66 ff ff ff       	call   c010b2db <__intr_restore>
}
c010b375:	90                   	nop
c010b376:	c9                   	leave  
c010b377:	c3                   	ret    

c010b378 <schedule>:

void
schedule(void) {
c010b378:	f3 0f 1e fb          	endbr32 
c010b37c:	55                   	push   %ebp
c010b37d:	89 e5                	mov    %esp,%ebp
c010b37f:	83 ec 38             	sub    $0x38,%esp
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
c010b382:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    local_intr_save(intr_flag);
c010b389:	e8 23 ff ff ff       	call   c010b2b1 <__intr_save>
c010b38e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    {
        current->need_resched = 0;
c010b391:	a1 28 20 1b c0       	mov    0xc01b2028,%eax
c010b396:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
c010b39d:	8b 15 28 20 1b c0    	mov    0xc01b2028,%edx
c010b3a3:	a1 20 20 1b c0       	mov    0xc01b2020,%eax
c010b3a8:	39 c2                	cmp    %eax,%edx
c010b3aa:	74 0a                	je     c010b3b6 <schedule+0x3e>
c010b3ac:	a1 28 20 1b c0       	mov    0xc01b2028,%eax
c010b3b1:	83 c0 58             	add    $0x58,%eax
c010b3b4:	eb 05                	jmp    c010b3bb <schedule+0x43>
c010b3b6:	b8 58 41 1b c0       	mov    $0xc01b4158,%eax
c010b3bb:	89 45 e8             	mov    %eax,-0x18(%ebp)
        le = last;
c010b3be:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b3c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b3c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b3c7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->next;
c010b3ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010b3cd:	8b 40 04             	mov    0x4(%eax),%eax
        do {
            if ((le = list_next(le)) != &proc_list) {
c010b3d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b3d3:	81 7d f4 58 41 1b c0 	cmpl   $0xc01b4158,-0xc(%ebp)
c010b3da:	74 13                	je     c010b3ef <schedule+0x77>
                next = le2proc(le, list_link);
c010b3dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b3df:	83 e8 58             	sub    $0x58,%eax
c010b3e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
                if (next->state == PROC_RUNNABLE) {
c010b3e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b3e8:	8b 00                	mov    (%eax),%eax
c010b3ea:	83 f8 02             	cmp    $0x2,%eax
c010b3ed:	74 0a                	je     c010b3f9 <schedule+0x81>
                    break;
                }
            }
        } while (le != last);
c010b3ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b3f2:	3b 45 e8             	cmp    -0x18(%ebp),%eax
c010b3f5:	75 cd                	jne    c010b3c4 <schedule+0x4c>
c010b3f7:	eb 01                	jmp    c010b3fa <schedule+0x82>
                    break;
c010b3f9:	90                   	nop
        if (next == NULL || next->state != PROC_RUNNABLE) {
c010b3fa:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010b3fe:	74 0a                	je     c010b40a <schedule+0x92>
c010b400:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b403:	8b 00                	mov    (%eax),%eax
c010b405:	83 f8 02             	cmp    $0x2,%eax
c010b408:	74 08                	je     c010b412 <schedule+0x9a>
            next = idleproc;
c010b40a:	a1 20 20 1b c0       	mov    0xc01b2020,%eax
c010b40f:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        next->runs ++;
c010b412:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b415:	8b 40 08             	mov    0x8(%eax),%eax
c010b418:	8d 50 01             	lea    0x1(%eax),%edx
c010b41b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b41e:	89 50 08             	mov    %edx,0x8(%eax)
        if (next != current) {
c010b421:	a1 28 20 1b c0       	mov    0xc01b2028,%eax
c010b426:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010b429:	74 0b                	je     c010b436 <schedule+0xbe>
            proc_run(next);
c010b42b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b42e:	89 04 24             	mov    %eax,(%esp)
c010b431:	e8 c8 e7 ff ff       	call   c0109bfe <proc_run>
        }
    }
    local_intr_restore(intr_flag);
c010b436:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010b439:	89 04 24             	mov    %eax,(%esp)
c010b43c:	e8 9a fe ff ff       	call   c010b2db <__intr_restore>
}
c010b441:	90                   	nop
c010b442:	c9                   	leave  
c010b443:	c3                   	ret    

c010b444 <sys_exit>:
#include <stdio.h>
#include <pmm.h>
#include <assert.h>

static int
sys_exit(uint32_t arg[]) {
c010b444:	f3 0f 1e fb          	endbr32 
c010b448:	55                   	push   %ebp
c010b449:	89 e5                	mov    %esp,%ebp
c010b44b:	83 ec 28             	sub    $0x28,%esp
    int error_code = (int)arg[0];
c010b44e:	8b 45 08             	mov    0x8(%ebp),%eax
c010b451:	8b 00                	mov    (%eax),%eax
c010b453:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return do_exit(error_code);
c010b456:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b459:	89 04 24             	mov    %eax,(%esp)
c010b45c:	e8 60 ee ff ff       	call   c010a2c1 <do_exit>
}
c010b461:	c9                   	leave  
c010b462:	c3                   	ret    

c010b463 <sys_fork>:

static int
sys_fork(uint32_t arg[]) {
c010b463:	f3 0f 1e fb          	endbr32 
c010b467:	55                   	push   %ebp
c010b468:	89 e5                	mov    %esp,%ebp
c010b46a:	83 ec 28             	sub    $0x28,%esp
    struct trapframe *tf = current->tf;
c010b46d:	a1 28 20 1b c0       	mov    0xc01b2028,%eax
c010b472:	8b 40 3c             	mov    0x3c(%eax),%eax
c010b475:	89 45 f4             	mov    %eax,-0xc(%ebp)
    uintptr_t stack = tf->tf_esp;
c010b478:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b47b:	8b 40 44             	mov    0x44(%eax),%eax
c010b47e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return do_fork(0, stack, tf);
c010b481:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b484:	89 44 24 08          	mov    %eax,0x8(%esp)
c010b488:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b48b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b48f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010b496:	e8 f9 ec ff ff       	call   c010a194 <do_fork>
}
c010b49b:	c9                   	leave  
c010b49c:	c3                   	ret    

c010b49d <sys_wait>:

static int
sys_wait(uint32_t arg[]) {
c010b49d:	f3 0f 1e fb          	endbr32 
c010b4a1:	55                   	push   %ebp
c010b4a2:	89 e5                	mov    %esp,%ebp
c010b4a4:	83 ec 28             	sub    $0x28,%esp
    int pid = (int)arg[0];
c010b4a7:	8b 45 08             	mov    0x8(%ebp),%eax
c010b4aa:	8b 00                	mov    (%eax),%eax
c010b4ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
    int *store = (int *)arg[1];
c010b4af:	8b 45 08             	mov    0x8(%ebp),%eax
c010b4b2:	83 c0 04             	add    $0x4,%eax
c010b4b5:	8b 00                	mov    (%eax),%eax
c010b4b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return do_wait(pid, store);
c010b4ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b4bd:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b4c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b4c4:	89 04 24             	mov    %eax,(%esp)
c010b4c7:	e8 86 f7 ff ff       	call   c010ac52 <do_wait>
}
c010b4cc:	c9                   	leave  
c010b4cd:	c3                   	ret    

c010b4ce <sys_exec>:

static int
sys_exec(uint32_t arg[]) {
c010b4ce:	f3 0f 1e fb          	endbr32 
c010b4d2:	55                   	push   %ebp
c010b4d3:	89 e5                	mov    %esp,%ebp
c010b4d5:	83 ec 28             	sub    $0x28,%esp
    const char *name = (const char *)arg[0];
c010b4d8:	8b 45 08             	mov    0x8(%ebp),%eax
c010b4db:	8b 00                	mov    (%eax),%eax
c010b4dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    size_t len = (size_t)arg[1];
c010b4e0:	8b 45 08             	mov    0x8(%ebp),%eax
c010b4e3:	83 c0 04             	add    $0x4,%eax
c010b4e6:	8b 00                	mov    (%eax),%eax
c010b4e8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    unsigned char *binary = (unsigned char *)arg[2];
c010b4eb:	8b 45 08             	mov    0x8(%ebp),%eax
c010b4ee:	83 c0 08             	add    $0x8,%eax
c010b4f1:	8b 00                	mov    (%eax),%eax
c010b4f3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    size_t size = (size_t)arg[3];
c010b4f6:	8b 45 08             	mov    0x8(%ebp),%eax
c010b4f9:	83 c0 0c             	add    $0xc,%eax
c010b4fc:	8b 00                	mov    (%eax),%eax
c010b4fe:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return do_execve(name, len, binary, size);
c010b501:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b504:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010b508:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010b50b:	89 44 24 08          	mov    %eax,0x8(%esp)
c010b50f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b512:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b516:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b519:	89 04 24             	mov    %eax,(%esp)
c010b51c:	e8 d6 f5 ff ff       	call   c010aaf7 <do_execve>
}
c010b521:	c9                   	leave  
c010b522:	c3                   	ret    

c010b523 <sys_yield>:

static int
sys_yield(uint32_t arg[]) {
c010b523:	f3 0f 1e fb          	endbr32 
c010b527:	55                   	push   %ebp
c010b528:	89 e5                	mov    %esp,%ebp
c010b52a:	83 ec 08             	sub    $0x8,%esp
    return do_yield();
c010b52d:	e8 06 f7 ff ff       	call   c010ac38 <do_yield>
}
c010b532:	c9                   	leave  
c010b533:	c3                   	ret    

c010b534 <sys_kill>:

static int
sys_kill(uint32_t arg[]) {
c010b534:	f3 0f 1e fb          	endbr32 
c010b538:	55                   	push   %ebp
c010b539:	89 e5                	mov    %esp,%ebp
c010b53b:	83 ec 28             	sub    $0x28,%esp
    int pid = (int)arg[0];
c010b53e:	8b 45 08             	mov    0x8(%ebp),%eax
c010b541:	8b 00                	mov    (%eax),%eax
c010b543:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return do_kill(pid);
c010b546:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b549:	89 04 24             	mov    %eax,(%esp)
c010b54c:	e8 95 f8 ff ff       	call   c010ade6 <do_kill>
}
c010b551:	c9                   	leave  
c010b552:	c3                   	ret    

c010b553 <sys_getpid>:

static int
sys_getpid(uint32_t arg[]) {
c010b553:	f3 0f 1e fb          	endbr32 
c010b557:	55                   	push   %ebp
c010b558:	89 e5                	mov    %esp,%ebp
    return current->pid;
c010b55a:	a1 28 20 1b c0       	mov    0xc01b2028,%eax
c010b55f:	8b 40 04             	mov    0x4(%eax),%eax
}
c010b562:	5d                   	pop    %ebp
c010b563:	c3                   	ret    

c010b564 <sys_putc>:

static int
sys_putc(uint32_t arg[]) {
c010b564:	f3 0f 1e fb          	endbr32 
c010b568:	55                   	push   %ebp
c010b569:	89 e5                	mov    %esp,%ebp
c010b56b:	83 ec 28             	sub    $0x28,%esp
    int c = (int)arg[0];
c010b56e:	8b 45 08             	mov    0x8(%ebp),%eax
c010b571:	8b 00                	mov    (%eax),%eax
c010b573:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cputchar(c);
c010b576:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b579:	89 04 24             	mov    %eax,(%esp)
c010b57c:	e8 7a 4d ff ff       	call   c01002fb <cputchar>
    return 0;
c010b581:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b586:	c9                   	leave  
c010b587:	c3                   	ret    

c010b588 <sys_pgdir>:

static int
sys_pgdir(uint32_t arg[]) {
c010b588:	f3 0f 1e fb          	endbr32 
c010b58c:	55                   	push   %ebp
c010b58d:	89 e5                	mov    %esp,%ebp
c010b58f:	83 ec 08             	sub    $0x8,%esp
    print_pgdir();
c010b592:	e8 8c 9e ff ff       	call   c0105423 <print_pgdir>
    return 0;
c010b597:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b59c:	c9                   	leave  
c010b59d:	c3                   	ret    

c010b59e <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
c010b59e:	f3 0f 1e fb          	endbr32 
c010b5a2:	55                   	push   %ebp
c010b5a3:	89 e5                	mov    %esp,%ebp
c010b5a5:	83 ec 48             	sub    $0x48,%esp
    struct trapframe *tf = current->tf;
c010b5a8:	a1 28 20 1b c0       	mov    0xc01b2028,%eax
c010b5ad:	8b 40 3c             	mov    0x3c(%eax),%eax
c010b5b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    uint32_t arg[5];
    int num = tf->tf_regs.reg_eax;
c010b5b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b5b6:	8b 40 1c             	mov    0x1c(%eax),%eax
c010b5b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (num >= 0 && num < NUM_SYSCALLS) {
c010b5bc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010b5c0:	78 5e                	js     c010b620 <syscall+0x82>
c010b5c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b5c5:	83 f8 1f             	cmp    $0x1f,%eax
c010b5c8:	77 56                	ja     c010b620 <syscall+0x82>
        if (syscalls[num] != NULL) {
c010b5ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b5cd:	8b 04 85 a0 ea 12 c0 	mov    -0x3fed1560(,%eax,4),%eax
c010b5d4:	85 c0                	test   %eax,%eax
c010b5d6:	74 48                	je     c010b620 <syscall+0x82>
            arg[0] = tf->tf_regs.reg_edx;
c010b5d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b5db:	8b 40 14             	mov    0x14(%eax),%eax
c010b5de:	89 45 dc             	mov    %eax,-0x24(%ebp)
            arg[1] = tf->tf_regs.reg_ecx;
c010b5e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b5e4:	8b 40 18             	mov    0x18(%eax),%eax
c010b5e7:	89 45 e0             	mov    %eax,-0x20(%ebp)
            arg[2] = tf->tf_regs.reg_ebx;
c010b5ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b5ed:	8b 40 10             	mov    0x10(%eax),%eax
c010b5f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            arg[3] = tf->tf_regs.reg_edi;
c010b5f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b5f6:	8b 00                	mov    (%eax),%eax
c010b5f8:	89 45 e8             	mov    %eax,-0x18(%ebp)
            arg[4] = tf->tf_regs.reg_esi;
c010b5fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b5fe:	8b 40 04             	mov    0x4(%eax),%eax
c010b601:	89 45 ec             	mov    %eax,-0x14(%ebp)
            tf->tf_regs.reg_eax = syscalls[num](arg);
c010b604:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b607:	8b 04 85 a0 ea 12 c0 	mov    -0x3fed1560(,%eax,4),%eax
c010b60e:	8d 55 dc             	lea    -0x24(%ebp),%edx
c010b611:	89 14 24             	mov    %edx,(%esp)
c010b614:	ff d0                	call   *%eax
c010b616:	89 c2                	mov    %eax,%edx
c010b618:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b61b:	89 50 1c             	mov    %edx,0x1c(%eax)
            return ;
c010b61e:	eb 46                	jmp    c010b666 <syscall+0xc8>
        }
    }
    print_trapframe(tf);
c010b620:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b623:	89 04 24             	mov    %eax,(%esp)
c010b626:	e8 e2 6e ff ff       	call   c010250d <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
c010b62b:	a1 28 20 1b c0       	mov    0xc01b2028,%eax
c010b630:	8d 50 48             	lea    0x48(%eax),%edx
c010b633:	a1 28 20 1b c0       	mov    0xc01b2028,%eax
c010b638:	8b 40 04             	mov    0x4(%eax),%eax
c010b63b:	89 54 24 14          	mov    %edx,0x14(%esp)
c010b63f:	89 44 24 10          	mov    %eax,0x10(%esp)
c010b643:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b646:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010b64a:	c7 44 24 08 70 e9 10 	movl   $0xc010e970,0x8(%esp)
c010b651:	c0 
c010b652:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
c010b659:	00 
c010b65a:	c7 04 24 9c e9 10 c0 	movl   $0xc010e99c,(%esp)
c010b661:	e8 d7 4d ff ff       	call   c010043d <__panic>
            num, current->pid, current->name);
}
c010b666:	c9                   	leave  
c010b667:	c3                   	ret    

c010b668 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c010b668:	f3 0f 1e fb          	endbr32 
c010b66c:	55                   	push   %ebp
c010b66d:	89 e5                	mov    %esp,%ebp
c010b66f:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c010b672:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c010b679:	eb 03                	jmp    c010b67e <strlen+0x16>
        cnt ++;
c010b67b:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
c010b67e:	8b 45 08             	mov    0x8(%ebp),%eax
c010b681:	8d 50 01             	lea    0x1(%eax),%edx
c010b684:	89 55 08             	mov    %edx,0x8(%ebp)
c010b687:	0f b6 00             	movzbl (%eax),%eax
c010b68a:	84 c0                	test   %al,%al
c010b68c:	75 ed                	jne    c010b67b <strlen+0x13>
    }
    return cnt;
c010b68e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010b691:	c9                   	leave  
c010b692:	c3                   	ret    

c010b693 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c010b693:	f3 0f 1e fb          	endbr32 
c010b697:	55                   	push   %ebp
c010b698:	89 e5                	mov    %esp,%ebp
c010b69a:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c010b69d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c010b6a4:	eb 03                	jmp    c010b6a9 <strnlen+0x16>
        cnt ++;
c010b6a6:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c010b6a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010b6ac:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010b6af:	73 10                	jae    c010b6c1 <strnlen+0x2e>
c010b6b1:	8b 45 08             	mov    0x8(%ebp),%eax
c010b6b4:	8d 50 01             	lea    0x1(%eax),%edx
c010b6b7:	89 55 08             	mov    %edx,0x8(%ebp)
c010b6ba:	0f b6 00             	movzbl (%eax),%eax
c010b6bd:	84 c0                	test   %al,%al
c010b6bf:	75 e5                	jne    c010b6a6 <strnlen+0x13>
    }
    return cnt;
c010b6c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010b6c4:	c9                   	leave  
c010b6c5:	c3                   	ret    

c010b6c6 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c010b6c6:	f3 0f 1e fb          	endbr32 
c010b6ca:	55                   	push   %ebp
c010b6cb:	89 e5                	mov    %esp,%ebp
c010b6cd:	57                   	push   %edi
c010b6ce:	56                   	push   %esi
c010b6cf:	83 ec 20             	sub    $0x20,%esp
c010b6d2:	8b 45 08             	mov    0x8(%ebp),%eax
c010b6d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b6d8:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b6db:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c010b6de:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010b6e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b6e4:	89 d1                	mov    %edx,%ecx
c010b6e6:	89 c2                	mov    %eax,%edx
c010b6e8:	89 ce                	mov    %ecx,%esi
c010b6ea:	89 d7                	mov    %edx,%edi
c010b6ec:	ac                   	lods   %ds:(%esi),%al
c010b6ed:	aa                   	stos   %al,%es:(%edi)
c010b6ee:	84 c0                	test   %al,%al
c010b6f0:	75 fa                	jne    c010b6ec <strcpy+0x26>
c010b6f2:	89 fa                	mov    %edi,%edx
c010b6f4:	89 f1                	mov    %esi,%ecx
c010b6f6:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010b6f9:	89 55 e8             	mov    %edx,-0x18(%ebp)
c010b6fc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c010b6ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c010b702:	83 c4 20             	add    $0x20,%esp
c010b705:	5e                   	pop    %esi
c010b706:	5f                   	pop    %edi
c010b707:	5d                   	pop    %ebp
c010b708:	c3                   	ret    

c010b709 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c010b709:	f3 0f 1e fb          	endbr32 
c010b70d:	55                   	push   %ebp
c010b70e:	89 e5                	mov    %esp,%ebp
c010b710:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c010b713:	8b 45 08             	mov    0x8(%ebp),%eax
c010b716:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c010b719:	eb 1e                	jmp    c010b739 <strncpy+0x30>
        if ((*p = *src) != '\0') {
c010b71b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b71e:	0f b6 10             	movzbl (%eax),%edx
c010b721:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010b724:	88 10                	mov    %dl,(%eax)
c010b726:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010b729:	0f b6 00             	movzbl (%eax),%eax
c010b72c:	84 c0                	test   %al,%al
c010b72e:	74 03                	je     c010b733 <strncpy+0x2a>
            src ++;
c010b730:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
c010b733:	ff 45 fc             	incl   -0x4(%ebp)
c010b736:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
c010b739:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010b73d:	75 dc                	jne    c010b71b <strncpy+0x12>
    }
    return dst;
c010b73f:	8b 45 08             	mov    0x8(%ebp),%eax
}
c010b742:	c9                   	leave  
c010b743:	c3                   	ret    

c010b744 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c010b744:	f3 0f 1e fb          	endbr32 
c010b748:	55                   	push   %ebp
c010b749:	89 e5                	mov    %esp,%ebp
c010b74b:	57                   	push   %edi
c010b74c:	56                   	push   %esi
c010b74d:	83 ec 20             	sub    $0x20,%esp
c010b750:	8b 45 08             	mov    0x8(%ebp),%eax
c010b753:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b756:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b759:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
c010b75c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010b75f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b762:	89 d1                	mov    %edx,%ecx
c010b764:	89 c2                	mov    %eax,%edx
c010b766:	89 ce                	mov    %ecx,%esi
c010b768:	89 d7                	mov    %edx,%edi
c010b76a:	ac                   	lods   %ds:(%esi),%al
c010b76b:	ae                   	scas   %es:(%edi),%al
c010b76c:	75 08                	jne    c010b776 <strcmp+0x32>
c010b76e:	84 c0                	test   %al,%al
c010b770:	75 f8                	jne    c010b76a <strcmp+0x26>
c010b772:	31 c0                	xor    %eax,%eax
c010b774:	eb 04                	jmp    c010b77a <strcmp+0x36>
c010b776:	19 c0                	sbb    %eax,%eax
c010b778:	0c 01                	or     $0x1,%al
c010b77a:	89 fa                	mov    %edi,%edx
c010b77c:	89 f1                	mov    %esi,%ecx
c010b77e:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010b781:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c010b784:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
c010b787:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c010b78a:	83 c4 20             	add    $0x20,%esp
c010b78d:	5e                   	pop    %esi
c010b78e:	5f                   	pop    %edi
c010b78f:	5d                   	pop    %ebp
c010b790:	c3                   	ret    

c010b791 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c010b791:	f3 0f 1e fb          	endbr32 
c010b795:	55                   	push   %ebp
c010b796:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c010b798:	eb 09                	jmp    c010b7a3 <strncmp+0x12>
        n --, s1 ++, s2 ++;
c010b79a:	ff 4d 10             	decl   0x10(%ebp)
c010b79d:	ff 45 08             	incl   0x8(%ebp)
c010b7a0:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c010b7a3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010b7a7:	74 1a                	je     c010b7c3 <strncmp+0x32>
c010b7a9:	8b 45 08             	mov    0x8(%ebp),%eax
c010b7ac:	0f b6 00             	movzbl (%eax),%eax
c010b7af:	84 c0                	test   %al,%al
c010b7b1:	74 10                	je     c010b7c3 <strncmp+0x32>
c010b7b3:	8b 45 08             	mov    0x8(%ebp),%eax
c010b7b6:	0f b6 10             	movzbl (%eax),%edx
c010b7b9:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b7bc:	0f b6 00             	movzbl (%eax),%eax
c010b7bf:	38 c2                	cmp    %al,%dl
c010b7c1:	74 d7                	je     c010b79a <strncmp+0x9>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c010b7c3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010b7c7:	74 18                	je     c010b7e1 <strncmp+0x50>
c010b7c9:	8b 45 08             	mov    0x8(%ebp),%eax
c010b7cc:	0f b6 00             	movzbl (%eax),%eax
c010b7cf:	0f b6 d0             	movzbl %al,%edx
c010b7d2:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b7d5:	0f b6 00             	movzbl (%eax),%eax
c010b7d8:	0f b6 c0             	movzbl %al,%eax
c010b7db:	29 c2                	sub    %eax,%edx
c010b7dd:	89 d0                	mov    %edx,%eax
c010b7df:	eb 05                	jmp    c010b7e6 <strncmp+0x55>
c010b7e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b7e6:	5d                   	pop    %ebp
c010b7e7:	c3                   	ret    

c010b7e8 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c010b7e8:	f3 0f 1e fb          	endbr32 
c010b7ec:	55                   	push   %ebp
c010b7ed:	89 e5                	mov    %esp,%ebp
c010b7ef:	83 ec 04             	sub    $0x4,%esp
c010b7f2:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b7f5:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c010b7f8:	eb 13                	jmp    c010b80d <strchr+0x25>
        if (*s == c) {
c010b7fa:	8b 45 08             	mov    0x8(%ebp),%eax
c010b7fd:	0f b6 00             	movzbl (%eax),%eax
c010b800:	38 45 fc             	cmp    %al,-0x4(%ebp)
c010b803:	75 05                	jne    c010b80a <strchr+0x22>
            return (char *)s;
c010b805:	8b 45 08             	mov    0x8(%ebp),%eax
c010b808:	eb 12                	jmp    c010b81c <strchr+0x34>
        }
        s ++;
c010b80a:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c010b80d:	8b 45 08             	mov    0x8(%ebp),%eax
c010b810:	0f b6 00             	movzbl (%eax),%eax
c010b813:	84 c0                	test   %al,%al
c010b815:	75 e3                	jne    c010b7fa <strchr+0x12>
    }
    return NULL;
c010b817:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b81c:	c9                   	leave  
c010b81d:	c3                   	ret    

c010b81e <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c010b81e:	f3 0f 1e fb          	endbr32 
c010b822:	55                   	push   %ebp
c010b823:	89 e5                	mov    %esp,%ebp
c010b825:	83 ec 04             	sub    $0x4,%esp
c010b828:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b82b:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c010b82e:	eb 0e                	jmp    c010b83e <strfind+0x20>
        if (*s == c) {
c010b830:	8b 45 08             	mov    0x8(%ebp),%eax
c010b833:	0f b6 00             	movzbl (%eax),%eax
c010b836:	38 45 fc             	cmp    %al,-0x4(%ebp)
c010b839:	74 0f                	je     c010b84a <strfind+0x2c>
            break;
        }
        s ++;
c010b83b:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c010b83e:	8b 45 08             	mov    0x8(%ebp),%eax
c010b841:	0f b6 00             	movzbl (%eax),%eax
c010b844:	84 c0                	test   %al,%al
c010b846:	75 e8                	jne    c010b830 <strfind+0x12>
c010b848:	eb 01                	jmp    c010b84b <strfind+0x2d>
            break;
c010b84a:	90                   	nop
    }
    return (char *)s;
c010b84b:	8b 45 08             	mov    0x8(%ebp),%eax
}
c010b84e:	c9                   	leave  
c010b84f:	c3                   	ret    

c010b850 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c010b850:	f3 0f 1e fb          	endbr32 
c010b854:	55                   	push   %ebp
c010b855:	89 e5                	mov    %esp,%ebp
c010b857:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c010b85a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c010b861:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c010b868:	eb 03                	jmp    c010b86d <strtol+0x1d>
        s ++;
c010b86a:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
c010b86d:	8b 45 08             	mov    0x8(%ebp),%eax
c010b870:	0f b6 00             	movzbl (%eax),%eax
c010b873:	3c 20                	cmp    $0x20,%al
c010b875:	74 f3                	je     c010b86a <strtol+0x1a>
c010b877:	8b 45 08             	mov    0x8(%ebp),%eax
c010b87a:	0f b6 00             	movzbl (%eax),%eax
c010b87d:	3c 09                	cmp    $0x9,%al
c010b87f:	74 e9                	je     c010b86a <strtol+0x1a>
    }

    // plus/minus sign
    if (*s == '+') {
c010b881:	8b 45 08             	mov    0x8(%ebp),%eax
c010b884:	0f b6 00             	movzbl (%eax),%eax
c010b887:	3c 2b                	cmp    $0x2b,%al
c010b889:	75 05                	jne    c010b890 <strtol+0x40>
        s ++;
c010b88b:	ff 45 08             	incl   0x8(%ebp)
c010b88e:	eb 14                	jmp    c010b8a4 <strtol+0x54>
    }
    else if (*s == '-') {
c010b890:	8b 45 08             	mov    0x8(%ebp),%eax
c010b893:	0f b6 00             	movzbl (%eax),%eax
c010b896:	3c 2d                	cmp    $0x2d,%al
c010b898:	75 0a                	jne    c010b8a4 <strtol+0x54>
        s ++, neg = 1;
c010b89a:	ff 45 08             	incl   0x8(%ebp)
c010b89d:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c010b8a4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010b8a8:	74 06                	je     c010b8b0 <strtol+0x60>
c010b8aa:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c010b8ae:	75 22                	jne    c010b8d2 <strtol+0x82>
c010b8b0:	8b 45 08             	mov    0x8(%ebp),%eax
c010b8b3:	0f b6 00             	movzbl (%eax),%eax
c010b8b6:	3c 30                	cmp    $0x30,%al
c010b8b8:	75 18                	jne    c010b8d2 <strtol+0x82>
c010b8ba:	8b 45 08             	mov    0x8(%ebp),%eax
c010b8bd:	40                   	inc    %eax
c010b8be:	0f b6 00             	movzbl (%eax),%eax
c010b8c1:	3c 78                	cmp    $0x78,%al
c010b8c3:	75 0d                	jne    c010b8d2 <strtol+0x82>
        s += 2, base = 16;
c010b8c5:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c010b8c9:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c010b8d0:	eb 29                	jmp    c010b8fb <strtol+0xab>
    }
    else if (base == 0 && s[0] == '0') {
c010b8d2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010b8d6:	75 16                	jne    c010b8ee <strtol+0x9e>
c010b8d8:	8b 45 08             	mov    0x8(%ebp),%eax
c010b8db:	0f b6 00             	movzbl (%eax),%eax
c010b8de:	3c 30                	cmp    $0x30,%al
c010b8e0:	75 0c                	jne    c010b8ee <strtol+0x9e>
        s ++, base = 8;
c010b8e2:	ff 45 08             	incl   0x8(%ebp)
c010b8e5:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c010b8ec:	eb 0d                	jmp    c010b8fb <strtol+0xab>
    }
    else if (base == 0) {
c010b8ee:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010b8f2:	75 07                	jne    c010b8fb <strtol+0xab>
        base = 10;
c010b8f4:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c010b8fb:	8b 45 08             	mov    0x8(%ebp),%eax
c010b8fe:	0f b6 00             	movzbl (%eax),%eax
c010b901:	3c 2f                	cmp    $0x2f,%al
c010b903:	7e 1b                	jle    c010b920 <strtol+0xd0>
c010b905:	8b 45 08             	mov    0x8(%ebp),%eax
c010b908:	0f b6 00             	movzbl (%eax),%eax
c010b90b:	3c 39                	cmp    $0x39,%al
c010b90d:	7f 11                	jg     c010b920 <strtol+0xd0>
            dig = *s - '0';
c010b90f:	8b 45 08             	mov    0x8(%ebp),%eax
c010b912:	0f b6 00             	movzbl (%eax),%eax
c010b915:	0f be c0             	movsbl %al,%eax
c010b918:	83 e8 30             	sub    $0x30,%eax
c010b91b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b91e:	eb 48                	jmp    c010b968 <strtol+0x118>
        }
        else if (*s >= 'a' && *s <= 'z') {
c010b920:	8b 45 08             	mov    0x8(%ebp),%eax
c010b923:	0f b6 00             	movzbl (%eax),%eax
c010b926:	3c 60                	cmp    $0x60,%al
c010b928:	7e 1b                	jle    c010b945 <strtol+0xf5>
c010b92a:	8b 45 08             	mov    0x8(%ebp),%eax
c010b92d:	0f b6 00             	movzbl (%eax),%eax
c010b930:	3c 7a                	cmp    $0x7a,%al
c010b932:	7f 11                	jg     c010b945 <strtol+0xf5>
            dig = *s - 'a' + 10;
c010b934:	8b 45 08             	mov    0x8(%ebp),%eax
c010b937:	0f b6 00             	movzbl (%eax),%eax
c010b93a:	0f be c0             	movsbl %al,%eax
c010b93d:	83 e8 57             	sub    $0x57,%eax
c010b940:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b943:	eb 23                	jmp    c010b968 <strtol+0x118>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c010b945:	8b 45 08             	mov    0x8(%ebp),%eax
c010b948:	0f b6 00             	movzbl (%eax),%eax
c010b94b:	3c 40                	cmp    $0x40,%al
c010b94d:	7e 3b                	jle    c010b98a <strtol+0x13a>
c010b94f:	8b 45 08             	mov    0x8(%ebp),%eax
c010b952:	0f b6 00             	movzbl (%eax),%eax
c010b955:	3c 5a                	cmp    $0x5a,%al
c010b957:	7f 31                	jg     c010b98a <strtol+0x13a>
            dig = *s - 'A' + 10;
c010b959:	8b 45 08             	mov    0x8(%ebp),%eax
c010b95c:	0f b6 00             	movzbl (%eax),%eax
c010b95f:	0f be c0             	movsbl %al,%eax
c010b962:	83 e8 37             	sub    $0x37,%eax
c010b965:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c010b968:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b96b:	3b 45 10             	cmp    0x10(%ebp),%eax
c010b96e:	7d 19                	jge    c010b989 <strtol+0x139>
            break;
        }
        s ++, val = (val * base) + dig;
c010b970:	ff 45 08             	incl   0x8(%ebp)
c010b973:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010b976:	0f af 45 10          	imul   0x10(%ebp),%eax
c010b97a:	89 c2                	mov    %eax,%edx
c010b97c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b97f:	01 d0                	add    %edx,%eax
c010b981:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
c010b984:	e9 72 ff ff ff       	jmp    c010b8fb <strtol+0xab>
            break;
c010b989:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
c010b98a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010b98e:	74 08                	je     c010b998 <strtol+0x148>
        *endptr = (char *) s;
c010b990:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b993:	8b 55 08             	mov    0x8(%ebp),%edx
c010b996:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c010b998:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c010b99c:	74 07                	je     c010b9a5 <strtol+0x155>
c010b99e:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010b9a1:	f7 d8                	neg    %eax
c010b9a3:	eb 03                	jmp    c010b9a8 <strtol+0x158>
c010b9a5:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c010b9a8:	c9                   	leave  
c010b9a9:	c3                   	ret    

c010b9aa <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c010b9aa:	f3 0f 1e fb          	endbr32 
c010b9ae:	55                   	push   %ebp
c010b9af:	89 e5                	mov    %esp,%ebp
c010b9b1:	57                   	push   %edi
c010b9b2:	83 ec 24             	sub    $0x24,%esp
c010b9b5:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b9b8:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c010b9bb:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
c010b9bf:	8b 45 08             	mov    0x8(%ebp),%eax
c010b9c2:	89 45 f8             	mov    %eax,-0x8(%ebp)
c010b9c5:	88 55 f7             	mov    %dl,-0x9(%ebp)
c010b9c8:	8b 45 10             	mov    0x10(%ebp),%eax
c010b9cb:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c010b9ce:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c010b9d1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c010b9d5:	8b 55 f8             	mov    -0x8(%ebp),%edx
c010b9d8:	89 d7                	mov    %edx,%edi
c010b9da:	f3 aa                	rep stos %al,%es:(%edi)
c010b9dc:	89 fa                	mov    %edi,%edx
c010b9de:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010b9e1:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c010b9e4:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c010b9e7:	83 c4 24             	add    $0x24,%esp
c010b9ea:	5f                   	pop    %edi
c010b9eb:	5d                   	pop    %ebp
c010b9ec:	c3                   	ret    

c010b9ed <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c010b9ed:	f3 0f 1e fb          	endbr32 
c010b9f1:	55                   	push   %ebp
c010b9f2:	89 e5                	mov    %esp,%ebp
c010b9f4:	57                   	push   %edi
c010b9f5:	56                   	push   %esi
c010b9f6:	53                   	push   %ebx
c010b9f7:	83 ec 30             	sub    $0x30,%esp
c010b9fa:	8b 45 08             	mov    0x8(%ebp),%eax
c010b9fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010ba00:	8b 45 0c             	mov    0xc(%ebp),%eax
c010ba03:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010ba06:	8b 45 10             	mov    0x10(%ebp),%eax
c010ba09:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c010ba0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010ba0f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010ba12:	73 42                	jae    c010ba56 <memmove+0x69>
c010ba14:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010ba17:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010ba1a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010ba1d:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010ba20:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010ba23:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c010ba26:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010ba29:	c1 e8 02             	shr    $0x2,%eax
c010ba2c:	89 c1                	mov    %eax,%ecx
    asm volatile (
c010ba2e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010ba31:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010ba34:	89 d7                	mov    %edx,%edi
c010ba36:	89 c6                	mov    %eax,%esi
c010ba38:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c010ba3a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c010ba3d:	83 e1 03             	and    $0x3,%ecx
c010ba40:	74 02                	je     c010ba44 <memmove+0x57>
c010ba42:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010ba44:	89 f0                	mov    %esi,%eax
c010ba46:	89 fa                	mov    %edi,%edx
c010ba48:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c010ba4b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010ba4e:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
c010ba51:	8b 45 e4             	mov    -0x1c(%ebp),%eax
        return __memcpy(dst, src, n);
c010ba54:	eb 36                	jmp    c010ba8c <memmove+0x9f>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c010ba56:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010ba59:	8d 50 ff             	lea    -0x1(%eax),%edx
c010ba5c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010ba5f:	01 c2                	add    %eax,%edx
c010ba61:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010ba64:	8d 48 ff             	lea    -0x1(%eax),%ecx
c010ba67:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010ba6a:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
c010ba6d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010ba70:	89 c1                	mov    %eax,%ecx
c010ba72:	89 d8                	mov    %ebx,%eax
c010ba74:	89 d6                	mov    %edx,%esi
c010ba76:	89 c7                	mov    %eax,%edi
c010ba78:	fd                   	std    
c010ba79:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010ba7b:	fc                   	cld    
c010ba7c:	89 f8                	mov    %edi,%eax
c010ba7e:	89 f2                	mov    %esi,%edx
c010ba80:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c010ba83:	89 55 c8             	mov    %edx,-0x38(%ebp)
c010ba86:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
c010ba89:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c010ba8c:	83 c4 30             	add    $0x30,%esp
c010ba8f:	5b                   	pop    %ebx
c010ba90:	5e                   	pop    %esi
c010ba91:	5f                   	pop    %edi
c010ba92:	5d                   	pop    %ebp
c010ba93:	c3                   	ret    

c010ba94 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c010ba94:	f3 0f 1e fb          	endbr32 
c010ba98:	55                   	push   %ebp
c010ba99:	89 e5                	mov    %esp,%ebp
c010ba9b:	57                   	push   %edi
c010ba9c:	56                   	push   %esi
c010ba9d:	83 ec 20             	sub    $0x20,%esp
c010baa0:	8b 45 08             	mov    0x8(%ebp),%eax
c010baa3:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010baa6:	8b 45 0c             	mov    0xc(%ebp),%eax
c010baa9:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010baac:	8b 45 10             	mov    0x10(%ebp),%eax
c010baaf:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c010bab2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010bab5:	c1 e8 02             	shr    $0x2,%eax
c010bab8:	89 c1                	mov    %eax,%ecx
    asm volatile (
c010baba:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010babd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bac0:	89 d7                	mov    %edx,%edi
c010bac2:	89 c6                	mov    %eax,%esi
c010bac4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c010bac6:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c010bac9:	83 e1 03             	and    $0x3,%ecx
c010bacc:	74 02                	je     c010bad0 <memcpy+0x3c>
c010bace:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010bad0:	89 f0                	mov    %esi,%eax
c010bad2:	89 fa                	mov    %edi,%edx
c010bad4:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c010bad7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010bada:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
c010badd:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c010bae0:	83 c4 20             	add    $0x20,%esp
c010bae3:	5e                   	pop    %esi
c010bae4:	5f                   	pop    %edi
c010bae5:	5d                   	pop    %ebp
c010bae6:	c3                   	ret    

c010bae7 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c010bae7:	f3 0f 1e fb          	endbr32 
c010baeb:	55                   	push   %ebp
c010baec:	89 e5                	mov    %esp,%ebp
c010baee:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c010baf1:	8b 45 08             	mov    0x8(%ebp),%eax
c010baf4:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c010baf7:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bafa:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c010bafd:	eb 2e                	jmp    c010bb2d <memcmp+0x46>
        if (*s1 != *s2) {
c010baff:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010bb02:	0f b6 10             	movzbl (%eax),%edx
c010bb05:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010bb08:	0f b6 00             	movzbl (%eax),%eax
c010bb0b:	38 c2                	cmp    %al,%dl
c010bb0d:	74 18                	je     c010bb27 <memcmp+0x40>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c010bb0f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010bb12:	0f b6 00             	movzbl (%eax),%eax
c010bb15:	0f b6 d0             	movzbl %al,%edx
c010bb18:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010bb1b:	0f b6 00             	movzbl (%eax),%eax
c010bb1e:	0f b6 c0             	movzbl %al,%eax
c010bb21:	29 c2                	sub    %eax,%edx
c010bb23:	89 d0                	mov    %edx,%eax
c010bb25:	eb 18                	jmp    c010bb3f <memcmp+0x58>
        }
        s1 ++, s2 ++;
c010bb27:	ff 45 fc             	incl   -0x4(%ebp)
c010bb2a:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
c010bb2d:	8b 45 10             	mov    0x10(%ebp),%eax
c010bb30:	8d 50 ff             	lea    -0x1(%eax),%edx
c010bb33:	89 55 10             	mov    %edx,0x10(%ebp)
c010bb36:	85 c0                	test   %eax,%eax
c010bb38:	75 c5                	jne    c010baff <memcmp+0x18>
    }
    return 0;
c010bb3a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010bb3f:	c9                   	leave  
c010bb40:	c3                   	ret    

c010bb41 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c010bb41:	f3 0f 1e fb          	endbr32 
c010bb45:	55                   	push   %ebp
c010bb46:	89 e5                	mov    %esp,%ebp
c010bb48:	83 ec 58             	sub    $0x58,%esp
c010bb4b:	8b 45 10             	mov    0x10(%ebp),%eax
c010bb4e:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010bb51:	8b 45 14             	mov    0x14(%ebp),%eax
c010bb54:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c010bb57:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010bb5a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010bb5d:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010bb60:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c010bb63:	8b 45 18             	mov    0x18(%ebp),%eax
c010bb66:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010bb69:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010bb6c:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010bb6f:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010bb72:	89 55 f0             	mov    %edx,-0x10(%ebp)
c010bb75:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bb78:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010bb7b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010bb7f:	74 1c                	je     c010bb9d <printnum+0x5c>
c010bb81:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bb84:	ba 00 00 00 00       	mov    $0x0,%edx
c010bb89:	f7 75 e4             	divl   -0x1c(%ebp)
c010bb8c:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010bb8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bb92:	ba 00 00 00 00       	mov    $0x0,%edx
c010bb97:	f7 75 e4             	divl   -0x1c(%ebp)
c010bb9a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010bb9d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010bba0:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010bba3:	f7 75 e4             	divl   -0x1c(%ebp)
c010bba6:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010bba9:	89 55 dc             	mov    %edx,-0x24(%ebp)
c010bbac:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010bbaf:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010bbb2:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010bbb5:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010bbb8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010bbbb:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c010bbbe:	8b 45 18             	mov    0x18(%ebp),%eax
c010bbc1:	ba 00 00 00 00       	mov    $0x0,%edx
c010bbc6:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c010bbc9:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c010bbcc:	19 d1                	sbb    %edx,%ecx
c010bbce:	72 4c                	jb     c010bc1c <printnum+0xdb>
        printnum(putch, putdat, result, base, width - 1, padc);
c010bbd0:	8b 45 1c             	mov    0x1c(%ebp),%eax
c010bbd3:	8d 50 ff             	lea    -0x1(%eax),%edx
c010bbd6:	8b 45 20             	mov    0x20(%ebp),%eax
c010bbd9:	89 44 24 18          	mov    %eax,0x18(%esp)
c010bbdd:	89 54 24 14          	mov    %edx,0x14(%esp)
c010bbe1:	8b 45 18             	mov    0x18(%ebp),%eax
c010bbe4:	89 44 24 10          	mov    %eax,0x10(%esp)
c010bbe8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010bbeb:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010bbee:	89 44 24 08          	mov    %eax,0x8(%esp)
c010bbf2:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010bbf6:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bbf9:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bbfd:	8b 45 08             	mov    0x8(%ebp),%eax
c010bc00:	89 04 24             	mov    %eax,(%esp)
c010bc03:	e8 39 ff ff ff       	call   c010bb41 <printnum>
c010bc08:	eb 1b                	jmp    c010bc25 <printnum+0xe4>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c010bc0a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bc0d:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bc11:	8b 45 20             	mov    0x20(%ebp),%eax
c010bc14:	89 04 24             	mov    %eax,(%esp)
c010bc17:	8b 45 08             	mov    0x8(%ebp),%eax
c010bc1a:	ff d0                	call   *%eax
        while (-- width > 0)
c010bc1c:	ff 4d 1c             	decl   0x1c(%ebp)
c010bc1f:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c010bc23:	7f e5                	jg     c010bc0a <printnum+0xc9>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c010bc25:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010bc28:	05 c4 ea 10 c0       	add    $0xc010eac4,%eax
c010bc2d:	0f b6 00             	movzbl (%eax),%eax
c010bc30:	0f be c0             	movsbl %al,%eax
c010bc33:	8b 55 0c             	mov    0xc(%ebp),%edx
c010bc36:	89 54 24 04          	mov    %edx,0x4(%esp)
c010bc3a:	89 04 24             	mov    %eax,(%esp)
c010bc3d:	8b 45 08             	mov    0x8(%ebp),%eax
c010bc40:	ff d0                	call   *%eax
}
c010bc42:	90                   	nop
c010bc43:	c9                   	leave  
c010bc44:	c3                   	ret    

c010bc45 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c010bc45:	f3 0f 1e fb          	endbr32 
c010bc49:	55                   	push   %ebp
c010bc4a:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010bc4c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c010bc50:	7e 14                	jle    c010bc66 <getuint+0x21>
        return va_arg(*ap, unsigned long long);
c010bc52:	8b 45 08             	mov    0x8(%ebp),%eax
c010bc55:	8b 00                	mov    (%eax),%eax
c010bc57:	8d 48 08             	lea    0x8(%eax),%ecx
c010bc5a:	8b 55 08             	mov    0x8(%ebp),%edx
c010bc5d:	89 0a                	mov    %ecx,(%edx)
c010bc5f:	8b 50 04             	mov    0x4(%eax),%edx
c010bc62:	8b 00                	mov    (%eax),%eax
c010bc64:	eb 30                	jmp    c010bc96 <getuint+0x51>
    }
    else if (lflag) {
c010bc66:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010bc6a:	74 16                	je     c010bc82 <getuint+0x3d>
        return va_arg(*ap, unsigned long);
c010bc6c:	8b 45 08             	mov    0x8(%ebp),%eax
c010bc6f:	8b 00                	mov    (%eax),%eax
c010bc71:	8d 48 04             	lea    0x4(%eax),%ecx
c010bc74:	8b 55 08             	mov    0x8(%ebp),%edx
c010bc77:	89 0a                	mov    %ecx,(%edx)
c010bc79:	8b 00                	mov    (%eax),%eax
c010bc7b:	ba 00 00 00 00       	mov    $0x0,%edx
c010bc80:	eb 14                	jmp    c010bc96 <getuint+0x51>
    }
    else {
        return va_arg(*ap, unsigned int);
c010bc82:	8b 45 08             	mov    0x8(%ebp),%eax
c010bc85:	8b 00                	mov    (%eax),%eax
c010bc87:	8d 48 04             	lea    0x4(%eax),%ecx
c010bc8a:	8b 55 08             	mov    0x8(%ebp),%edx
c010bc8d:	89 0a                	mov    %ecx,(%edx)
c010bc8f:	8b 00                	mov    (%eax),%eax
c010bc91:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c010bc96:	5d                   	pop    %ebp
c010bc97:	c3                   	ret    

c010bc98 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c010bc98:	f3 0f 1e fb          	endbr32 
c010bc9c:	55                   	push   %ebp
c010bc9d:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010bc9f:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c010bca3:	7e 14                	jle    c010bcb9 <getint+0x21>
        return va_arg(*ap, long long);
c010bca5:	8b 45 08             	mov    0x8(%ebp),%eax
c010bca8:	8b 00                	mov    (%eax),%eax
c010bcaa:	8d 48 08             	lea    0x8(%eax),%ecx
c010bcad:	8b 55 08             	mov    0x8(%ebp),%edx
c010bcb0:	89 0a                	mov    %ecx,(%edx)
c010bcb2:	8b 50 04             	mov    0x4(%eax),%edx
c010bcb5:	8b 00                	mov    (%eax),%eax
c010bcb7:	eb 28                	jmp    c010bce1 <getint+0x49>
    }
    else if (lflag) {
c010bcb9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010bcbd:	74 12                	je     c010bcd1 <getint+0x39>
        return va_arg(*ap, long);
c010bcbf:	8b 45 08             	mov    0x8(%ebp),%eax
c010bcc2:	8b 00                	mov    (%eax),%eax
c010bcc4:	8d 48 04             	lea    0x4(%eax),%ecx
c010bcc7:	8b 55 08             	mov    0x8(%ebp),%edx
c010bcca:	89 0a                	mov    %ecx,(%edx)
c010bccc:	8b 00                	mov    (%eax),%eax
c010bcce:	99                   	cltd   
c010bccf:	eb 10                	jmp    c010bce1 <getint+0x49>
    }
    else {
        return va_arg(*ap, int);
c010bcd1:	8b 45 08             	mov    0x8(%ebp),%eax
c010bcd4:	8b 00                	mov    (%eax),%eax
c010bcd6:	8d 48 04             	lea    0x4(%eax),%ecx
c010bcd9:	8b 55 08             	mov    0x8(%ebp),%edx
c010bcdc:	89 0a                	mov    %ecx,(%edx)
c010bcde:	8b 00                	mov    (%eax),%eax
c010bce0:	99                   	cltd   
    }
}
c010bce1:	5d                   	pop    %ebp
c010bce2:	c3                   	ret    

c010bce3 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c010bce3:	f3 0f 1e fb          	endbr32 
c010bce7:	55                   	push   %ebp
c010bce8:	89 e5                	mov    %esp,%ebp
c010bcea:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c010bced:	8d 45 14             	lea    0x14(%ebp),%eax
c010bcf0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c010bcf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010bcf6:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010bcfa:	8b 45 10             	mov    0x10(%ebp),%eax
c010bcfd:	89 44 24 08          	mov    %eax,0x8(%esp)
c010bd01:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bd04:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bd08:	8b 45 08             	mov    0x8(%ebp),%eax
c010bd0b:	89 04 24             	mov    %eax,(%esp)
c010bd0e:	e8 03 00 00 00       	call   c010bd16 <vprintfmt>
    va_end(ap);
}
c010bd13:	90                   	nop
c010bd14:	c9                   	leave  
c010bd15:	c3                   	ret    

c010bd16 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c010bd16:	f3 0f 1e fb          	endbr32 
c010bd1a:	55                   	push   %ebp
c010bd1b:	89 e5                	mov    %esp,%ebp
c010bd1d:	56                   	push   %esi
c010bd1e:	53                   	push   %ebx
c010bd1f:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010bd22:	eb 17                	jmp    c010bd3b <vprintfmt+0x25>
            if (ch == '\0') {
c010bd24:	85 db                	test   %ebx,%ebx
c010bd26:	0f 84 c0 03 00 00    	je     c010c0ec <vprintfmt+0x3d6>
                return;
            }
            putch(ch, putdat);
c010bd2c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bd2f:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bd33:	89 1c 24             	mov    %ebx,(%esp)
c010bd36:	8b 45 08             	mov    0x8(%ebp),%eax
c010bd39:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010bd3b:	8b 45 10             	mov    0x10(%ebp),%eax
c010bd3e:	8d 50 01             	lea    0x1(%eax),%edx
c010bd41:	89 55 10             	mov    %edx,0x10(%ebp)
c010bd44:	0f b6 00             	movzbl (%eax),%eax
c010bd47:	0f b6 d8             	movzbl %al,%ebx
c010bd4a:	83 fb 25             	cmp    $0x25,%ebx
c010bd4d:	75 d5                	jne    c010bd24 <vprintfmt+0xe>
        }

        // Process a %-escape sequence
        char padc = ' ';
c010bd4f:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c010bd53:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c010bd5a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010bd5d:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c010bd60:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010bd67:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010bd6a:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c010bd6d:	8b 45 10             	mov    0x10(%ebp),%eax
c010bd70:	8d 50 01             	lea    0x1(%eax),%edx
c010bd73:	89 55 10             	mov    %edx,0x10(%ebp)
c010bd76:	0f b6 00             	movzbl (%eax),%eax
c010bd79:	0f b6 d8             	movzbl %al,%ebx
c010bd7c:	8d 43 dd             	lea    -0x23(%ebx),%eax
c010bd7f:	83 f8 55             	cmp    $0x55,%eax
c010bd82:	0f 87 38 03 00 00    	ja     c010c0c0 <vprintfmt+0x3aa>
c010bd88:	8b 04 85 e8 ea 10 c0 	mov    -0x3fef1518(,%eax,4),%eax
c010bd8f:	3e ff e0             	notrack jmp *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c010bd92:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c010bd96:	eb d5                	jmp    c010bd6d <vprintfmt+0x57>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c010bd98:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c010bd9c:	eb cf                	jmp    c010bd6d <vprintfmt+0x57>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c010bd9e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c010bda5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010bda8:	89 d0                	mov    %edx,%eax
c010bdaa:	c1 e0 02             	shl    $0x2,%eax
c010bdad:	01 d0                	add    %edx,%eax
c010bdaf:	01 c0                	add    %eax,%eax
c010bdb1:	01 d8                	add    %ebx,%eax
c010bdb3:	83 e8 30             	sub    $0x30,%eax
c010bdb6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c010bdb9:	8b 45 10             	mov    0x10(%ebp),%eax
c010bdbc:	0f b6 00             	movzbl (%eax),%eax
c010bdbf:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c010bdc2:	83 fb 2f             	cmp    $0x2f,%ebx
c010bdc5:	7e 38                	jle    c010bdff <vprintfmt+0xe9>
c010bdc7:	83 fb 39             	cmp    $0x39,%ebx
c010bdca:	7f 33                	jg     c010bdff <vprintfmt+0xe9>
            for (precision = 0; ; ++ fmt) {
c010bdcc:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
c010bdcf:	eb d4                	jmp    c010bda5 <vprintfmt+0x8f>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
c010bdd1:	8b 45 14             	mov    0x14(%ebp),%eax
c010bdd4:	8d 50 04             	lea    0x4(%eax),%edx
c010bdd7:	89 55 14             	mov    %edx,0x14(%ebp)
c010bdda:	8b 00                	mov    (%eax),%eax
c010bddc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c010bddf:	eb 1f                	jmp    c010be00 <vprintfmt+0xea>

        case '.':
            if (width < 0)
c010bde1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010bde5:	79 86                	jns    c010bd6d <vprintfmt+0x57>
                width = 0;
c010bde7:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c010bdee:	e9 7a ff ff ff       	jmp    c010bd6d <vprintfmt+0x57>

        case '#':
            altflag = 1;
c010bdf3:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c010bdfa:	e9 6e ff ff ff       	jmp    c010bd6d <vprintfmt+0x57>
            goto process_precision;
c010bdff:	90                   	nop

        process_precision:
            if (width < 0)
c010be00:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010be04:	0f 89 63 ff ff ff    	jns    c010bd6d <vprintfmt+0x57>
                width = precision, precision = -1;
c010be0a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010be0d:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010be10:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c010be17:	e9 51 ff ff ff       	jmp    c010bd6d <vprintfmt+0x57>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c010be1c:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
c010be1f:	e9 49 ff ff ff       	jmp    c010bd6d <vprintfmt+0x57>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c010be24:	8b 45 14             	mov    0x14(%ebp),%eax
c010be27:	8d 50 04             	lea    0x4(%eax),%edx
c010be2a:	89 55 14             	mov    %edx,0x14(%ebp)
c010be2d:	8b 00                	mov    (%eax),%eax
c010be2f:	8b 55 0c             	mov    0xc(%ebp),%edx
c010be32:	89 54 24 04          	mov    %edx,0x4(%esp)
c010be36:	89 04 24             	mov    %eax,(%esp)
c010be39:	8b 45 08             	mov    0x8(%ebp),%eax
c010be3c:	ff d0                	call   *%eax
            break;
c010be3e:	e9 a4 02 00 00       	jmp    c010c0e7 <vprintfmt+0x3d1>

        // error message
        case 'e':
            err = va_arg(ap, int);
c010be43:	8b 45 14             	mov    0x14(%ebp),%eax
c010be46:	8d 50 04             	lea    0x4(%eax),%edx
c010be49:	89 55 14             	mov    %edx,0x14(%ebp)
c010be4c:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c010be4e:	85 db                	test   %ebx,%ebx
c010be50:	79 02                	jns    c010be54 <vprintfmt+0x13e>
                err = -err;
c010be52:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c010be54:	83 fb 18             	cmp    $0x18,%ebx
c010be57:	7f 0b                	jg     c010be64 <vprintfmt+0x14e>
c010be59:	8b 34 9d 60 ea 10 c0 	mov    -0x3fef15a0(,%ebx,4),%esi
c010be60:	85 f6                	test   %esi,%esi
c010be62:	75 23                	jne    c010be87 <vprintfmt+0x171>
                printfmt(putch, putdat, "error %d", err);
c010be64:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c010be68:	c7 44 24 08 d5 ea 10 	movl   $0xc010ead5,0x8(%esp)
c010be6f:	c0 
c010be70:	8b 45 0c             	mov    0xc(%ebp),%eax
c010be73:	89 44 24 04          	mov    %eax,0x4(%esp)
c010be77:	8b 45 08             	mov    0x8(%ebp),%eax
c010be7a:	89 04 24             	mov    %eax,(%esp)
c010be7d:	e8 61 fe ff ff       	call   c010bce3 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c010be82:	e9 60 02 00 00       	jmp    c010c0e7 <vprintfmt+0x3d1>
                printfmt(putch, putdat, "%s", p);
c010be87:	89 74 24 0c          	mov    %esi,0xc(%esp)
c010be8b:	c7 44 24 08 de ea 10 	movl   $0xc010eade,0x8(%esp)
c010be92:	c0 
c010be93:	8b 45 0c             	mov    0xc(%ebp),%eax
c010be96:	89 44 24 04          	mov    %eax,0x4(%esp)
c010be9a:	8b 45 08             	mov    0x8(%ebp),%eax
c010be9d:	89 04 24             	mov    %eax,(%esp)
c010bea0:	e8 3e fe ff ff       	call   c010bce3 <printfmt>
            break;
c010bea5:	e9 3d 02 00 00       	jmp    c010c0e7 <vprintfmt+0x3d1>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c010beaa:	8b 45 14             	mov    0x14(%ebp),%eax
c010bead:	8d 50 04             	lea    0x4(%eax),%edx
c010beb0:	89 55 14             	mov    %edx,0x14(%ebp)
c010beb3:	8b 30                	mov    (%eax),%esi
c010beb5:	85 f6                	test   %esi,%esi
c010beb7:	75 05                	jne    c010bebe <vprintfmt+0x1a8>
                p = "(null)";
c010beb9:	be e1 ea 10 c0       	mov    $0xc010eae1,%esi
            }
            if (width > 0 && padc != '-') {
c010bebe:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010bec2:	7e 76                	jle    c010bf3a <vprintfmt+0x224>
c010bec4:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c010bec8:	74 70                	je     c010bf3a <vprintfmt+0x224>
                for (width -= strnlen(p, precision); width > 0; width --) {
c010beca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010becd:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bed1:	89 34 24             	mov    %esi,(%esp)
c010bed4:	e8 ba f7 ff ff       	call   c010b693 <strnlen>
c010bed9:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010bedc:	29 c2                	sub    %eax,%edx
c010bede:	89 d0                	mov    %edx,%eax
c010bee0:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010bee3:	eb 16                	jmp    c010befb <vprintfmt+0x1e5>
                    putch(padc, putdat);
c010bee5:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c010bee9:	8b 55 0c             	mov    0xc(%ebp),%edx
c010beec:	89 54 24 04          	mov    %edx,0x4(%esp)
c010bef0:	89 04 24             	mov    %eax,(%esp)
c010bef3:	8b 45 08             	mov    0x8(%ebp),%eax
c010bef6:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
c010bef8:	ff 4d e8             	decl   -0x18(%ebp)
c010befb:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010beff:	7f e4                	jg     c010bee5 <vprintfmt+0x1cf>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c010bf01:	eb 37                	jmp    c010bf3a <vprintfmt+0x224>
                if (altflag && (ch < ' ' || ch > '~')) {
c010bf03:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010bf07:	74 1f                	je     c010bf28 <vprintfmt+0x212>
c010bf09:	83 fb 1f             	cmp    $0x1f,%ebx
c010bf0c:	7e 05                	jle    c010bf13 <vprintfmt+0x1fd>
c010bf0e:	83 fb 7e             	cmp    $0x7e,%ebx
c010bf11:	7e 15                	jle    c010bf28 <vprintfmt+0x212>
                    putch('?', putdat);
c010bf13:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bf16:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bf1a:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c010bf21:	8b 45 08             	mov    0x8(%ebp),%eax
c010bf24:	ff d0                	call   *%eax
c010bf26:	eb 0f                	jmp    c010bf37 <vprintfmt+0x221>
                }
                else {
                    putch(ch, putdat);
c010bf28:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bf2b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bf2f:	89 1c 24             	mov    %ebx,(%esp)
c010bf32:	8b 45 08             	mov    0x8(%ebp),%eax
c010bf35:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c010bf37:	ff 4d e8             	decl   -0x18(%ebp)
c010bf3a:	89 f0                	mov    %esi,%eax
c010bf3c:	8d 70 01             	lea    0x1(%eax),%esi
c010bf3f:	0f b6 00             	movzbl (%eax),%eax
c010bf42:	0f be d8             	movsbl %al,%ebx
c010bf45:	85 db                	test   %ebx,%ebx
c010bf47:	74 27                	je     c010bf70 <vprintfmt+0x25a>
c010bf49:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010bf4d:	78 b4                	js     c010bf03 <vprintfmt+0x1ed>
c010bf4f:	ff 4d e4             	decl   -0x1c(%ebp)
c010bf52:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010bf56:	79 ab                	jns    c010bf03 <vprintfmt+0x1ed>
                }
            }
            for (; width > 0; width --) {
c010bf58:	eb 16                	jmp    c010bf70 <vprintfmt+0x25a>
                putch(' ', putdat);
c010bf5a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bf5d:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bf61:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c010bf68:	8b 45 08             	mov    0x8(%ebp),%eax
c010bf6b:	ff d0                	call   *%eax
            for (; width > 0; width --) {
c010bf6d:	ff 4d e8             	decl   -0x18(%ebp)
c010bf70:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010bf74:	7f e4                	jg     c010bf5a <vprintfmt+0x244>
            }
            break;
c010bf76:	e9 6c 01 00 00       	jmp    c010c0e7 <vprintfmt+0x3d1>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c010bf7b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010bf7e:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bf82:	8d 45 14             	lea    0x14(%ebp),%eax
c010bf85:	89 04 24             	mov    %eax,(%esp)
c010bf88:	e8 0b fd ff ff       	call   c010bc98 <getint>
c010bf8d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010bf90:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c010bf93:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bf96:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010bf99:	85 d2                	test   %edx,%edx
c010bf9b:	79 26                	jns    c010bfc3 <vprintfmt+0x2ad>
                putch('-', putdat);
c010bf9d:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bfa0:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bfa4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c010bfab:	8b 45 08             	mov    0x8(%ebp),%eax
c010bfae:	ff d0                	call   *%eax
                num = -(long long)num;
c010bfb0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bfb3:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010bfb6:	f7 d8                	neg    %eax
c010bfb8:	83 d2 00             	adc    $0x0,%edx
c010bfbb:	f7 da                	neg    %edx
c010bfbd:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010bfc0:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c010bfc3:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c010bfca:	e9 a8 00 00 00       	jmp    c010c077 <vprintfmt+0x361>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c010bfcf:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010bfd2:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bfd6:	8d 45 14             	lea    0x14(%ebp),%eax
c010bfd9:	89 04 24             	mov    %eax,(%esp)
c010bfdc:	e8 64 fc ff ff       	call   c010bc45 <getuint>
c010bfe1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010bfe4:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c010bfe7:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c010bfee:	e9 84 00 00 00       	jmp    c010c077 <vprintfmt+0x361>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c010bff3:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010bff6:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bffa:	8d 45 14             	lea    0x14(%ebp),%eax
c010bffd:	89 04 24             	mov    %eax,(%esp)
c010c000:	e8 40 fc ff ff       	call   c010bc45 <getuint>
c010c005:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010c008:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c010c00b:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c010c012:	eb 63                	jmp    c010c077 <vprintfmt+0x361>

        // pointer
        case 'p':
            putch('0', putdat);
c010c014:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c017:	89 44 24 04          	mov    %eax,0x4(%esp)
c010c01b:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c010c022:	8b 45 08             	mov    0x8(%ebp),%eax
c010c025:	ff d0                	call   *%eax
            putch('x', putdat);
c010c027:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c02a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010c02e:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c010c035:	8b 45 08             	mov    0x8(%ebp),%eax
c010c038:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c010c03a:	8b 45 14             	mov    0x14(%ebp),%eax
c010c03d:	8d 50 04             	lea    0x4(%eax),%edx
c010c040:	89 55 14             	mov    %edx,0x14(%ebp)
c010c043:	8b 00                	mov    (%eax),%eax
c010c045:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010c048:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c010c04f:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c010c056:	eb 1f                	jmp    c010c077 <vprintfmt+0x361>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c010c058:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010c05b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010c05f:	8d 45 14             	lea    0x14(%ebp),%eax
c010c062:	89 04 24             	mov    %eax,(%esp)
c010c065:	e8 db fb ff ff       	call   c010bc45 <getuint>
c010c06a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010c06d:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c010c070:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c010c077:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c010c07b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010c07e:	89 54 24 18          	mov    %edx,0x18(%esp)
c010c082:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010c085:	89 54 24 14          	mov    %edx,0x14(%esp)
c010c089:	89 44 24 10          	mov    %eax,0x10(%esp)
c010c08d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010c090:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010c093:	89 44 24 08          	mov    %eax,0x8(%esp)
c010c097:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010c09b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c09e:	89 44 24 04          	mov    %eax,0x4(%esp)
c010c0a2:	8b 45 08             	mov    0x8(%ebp),%eax
c010c0a5:	89 04 24             	mov    %eax,(%esp)
c010c0a8:	e8 94 fa ff ff       	call   c010bb41 <printnum>
            break;
c010c0ad:	eb 38                	jmp    c010c0e7 <vprintfmt+0x3d1>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c010c0af:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c0b2:	89 44 24 04          	mov    %eax,0x4(%esp)
c010c0b6:	89 1c 24             	mov    %ebx,(%esp)
c010c0b9:	8b 45 08             	mov    0x8(%ebp),%eax
c010c0bc:	ff d0                	call   *%eax
            break;
c010c0be:	eb 27                	jmp    c010c0e7 <vprintfmt+0x3d1>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c010c0c0:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c0c3:	89 44 24 04          	mov    %eax,0x4(%esp)
c010c0c7:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c010c0ce:	8b 45 08             	mov    0x8(%ebp),%eax
c010c0d1:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c010c0d3:	ff 4d 10             	decl   0x10(%ebp)
c010c0d6:	eb 03                	jmp    c010c0db <vprintfmt+0x3c5>
c010c0d8:	ff 4d 10             	decl   0x10(%ebp)
c010c0db:	8b 45 10             	mov    0x10(%ebp),%eax
c010c0de:	48                   	dec    %eax
c010c0df:	0f b6 00             	movzbl (%eax),%eax
c010c0e2:	3c 25                	cmp    $0x25,%al
c010c0e4:	75 f2                	jne    c010c0d8 <vprintfmt+0x3c2>
                /* do nothing */;
            break;
c010c0e6:	90                   	nop
    while (1) {
c010c0e7:	e9 36 fc ff ff       	jmp    c010bd22 <vprintfmt+0xc>
                return;
c010c0ec:	90                   	nop
        }
    }
}
c010c0ed:	83 c4 40             	add    $0x40,%esp
c010c0f0:	5b                   	pop    %ebx
c010c0f1:	5e                   	pop    %esi
c010c0f2:	5d                   	pop    %ebp
c010c0f3:	c3                   	ret    

c010c0f4 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c010c0f4:	f3 0f 1e fb          	endbr32 
c010c0f8:	55                   	push   %ebp
c010c0f9:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c010c0fb:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c0fe:	8b 40 08             	mov    0x8(%eax),%eax
c010c101:	8d 50 01             	lea    0x1(%eax),%edx
c010c104:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c107:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c010c10a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c10d:	8b 10                	mov    (%eax),%edx
c010c10f:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c112:	8b 40 04             	mov    0x4(%eax),%eax
c010c115:	39 c2                	cmp    %eax,%edx
c010c117:	73 12                	jae    c010c12b <sprintputch+0x37>
        *b->buf ++ = ch;
c010c119:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c11c:	8b 00                	mov    (%eax),%eax
c010c11e:	8d 48 01             	lea    0x1(%eax),%ecx
c010c121:	8b 55 0c             	mov    0xc(%ebp),%edx
c010c124:	89 0a                	mov    %ecx,(%edx)
c010c126:	8b 55 08             	mov    0x8(%ebp),%edx
c010c129:	88 10                	mov    %dl,(%eax)
    }
}
c010c12b:	90                   	nop
c010c12c:	5d                   	pop    %ebp
c010c12d:	c3                   	ret    

c010c12e <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c010c12e:	f3 0f 1e fb          	endbr32 
c010c132:	55                   	push   %ebp
c010c133:	89 e5                	mov    %esp,%ebp
c010c135:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c010c138:	8d 45 14             	lea    0x14(%ebp),%eax
c010c13b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c010c13e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010c141:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010c145:	8b 45 10             	mov    0x10(%ebp),%eax
c010c148:	89 44 24 08          	mov    %eax,0x8(%esp)
c010c14c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c14f:	89 44 24 04          	mov    %eax,0x4(%esp)
c010c153:	8b 45 08             	mov    0x8(%ebp),%eax
c010c156:	89 04 24             	mov    %eax,(%esp)
c010c159:	e8 08 00 00 00       	call   c010c166 <vsnprintf>
c010c15e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c010c161:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010c164:	c9                   	leave  
c010c165:	c3                   	ret    

c010c166 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c010c166:	f3 0f 1e fb          	endbr32 
c010c16a:	55                   	push   %ebp
c010c16b:	89 e5                	mov    %esp,%ebp
c010c16d:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c010c170:	8b 45 08             	mov    0x8(%ebp),%eax
c010c173:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010c176:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c179:	8d 50 ff             	lea    -0x1(%eax),%edx
c010c17c:	8b 45 08             	mov    0x8(%ebp),%eax
c010c17f:	01 d0                	add    %edx,%eax
c010c181:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010c184:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c010c18b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010c18f:	74 0a                	je     c010c19b <vsnprintf+0x35>
c010c191:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010c194:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010c197:	39 c2                	cmp    %eax,%edx
c010c199:	76 07                	jbe    c010c1a2 <vsnprintf+0x3c>
        return -E_INVAL;
c010c19b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c010c1a0:	eb 2a                	jmp    c010c1cc <vsnprintf+0x66>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c010c1a2:	8b 45 14             	mov    0x14(%ebp),%eax
c010c1a5:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010c1a9:	8b 45 10             	mov    0x10(%ebp),%eax
c010c1ac:	89 44 24 08          	mov    %eax,0x8(%esp)
c010c1b0:	8d 45 ec             	lea    -0x14(%ebp),%eax
c010c1b3:	89 44 24 04          	mov    %eax,0x4(%esp)
c010c1b7:	c7 04 24 f4 c0 10 c0 	movl   $0xc010c0f4,(%esp)
c010c1be:	e8 53 fb ff ff       	call   c010bd16 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c010c1c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010c1c6:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c010c1c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010c1cc:	c9                   	leave  
c010c1cd:	c3                   	ret    

c010c1ce <hash32>:
 * @bits:   the number of bits in a return value
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
c010c1ce:	f3 0f 1e fb          	endbr32 
c010c1d2:	55                   	push   %ebp
c010c1d3:	89 e5                	mov    %esp,%ebp
c010c1d5:	83 ec 10             	sub    $0x10,%esp
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
c010c1d8:	8b 45 08             	mov    0x8(%ebp),%eax
c010c1db:	69 c0 01 00 37 9e    	imul   $0x9e370001,%eax,%eax
c010c1e1:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (hash >> (32 - bits));
c010c1e4:	b8 20 00 00 00       	mov    $0x20,%eax
c010c1e9:	2b 45 0c             	sub    0xc(%ebp),%eax
c010c1ec:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010c1ef:	88 c1                	mov    %al,%cl
c010c1f1:	d3 ea                	shr    %cl,%edx
c010c1f3:	89 d0                	mov    %edx,%eax
}
c010c1f5:	c9                   	leave  
c010c1f6:	c3                   	ret    

c010c1f7 <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
c010c1f7:	f3 0f 1e fb          	endbr32 
c010c1fb:	55                   	push   %ebp
c010c1fc:	89 e5                	mov    %esp,%ebp
c010c1fe:	57                   	push   %edi
c010c1ff:	56                   	push   %esi
c010c200:	53                   	push   %ebx
c010c201:	83 ec 24             	sub    $0x24,%esp
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
c010c204:	a1 20 eb 12 c0       	mov    0xc012eb20,%eax
c010c209:	8b 15 24 eb 12 c0    	mov    0xc012eb24,%edx
c010c20f:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
c010c215:	6b f0 05             	imul   $0x5,%eax,%esi
c010c218:	01 fe                	add    %edi,%esi
c010c21a:	bf 6d e6 ec de       	mov    $0xdeece66d,%edi
c010c21f:	f7 e7                	mul    %edi
c010c221:	01 d6                	add    %edx,%esi
c010c223:	89 f2                	mov    %esi,%edx
c010c225:	83 c0 0b             	add    $0xb,%eax
c010c228:	83 d2 00             	adc    $0x0,%edx
c010c22b:	89 c7                	mov    %eax,%edi
c010c22d:	83 e7 ff             	and    $0xffffffff,%edi
c010c230:	89 f9                	mov    %edi,%ecx
c010c232:	0f b7 da             	movzwl %dx,%ebx
c010c235:	89 0d 20 eb 12 c0    	mov    %ecx,0xc012eb20
c010c23b:	89 1d 24 eb 12 c0    	mov    %ebx,0xc012eb24
    unsigned long long result = (next >> 12);
c010c241:	a1 20 eb 12 c0       	mov    0xc012eb20,%eax
c010c246:	8b 15 24 eb 12 c0    	mov    0xc012eb24,%edx
c010c24c:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c010c250:	c1 ea 0c             	shr    $0xc,%edx
c010c253:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010c256:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
c010c259:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
c010c260:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010c263:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010c266:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010c269:	89 55 e8             	mov    %edx,-0x18(%ebp)
c010c26c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010c26f:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010c272:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010c276:	74 1c                	je     c010c294 <rand+0x9d>
c010c278:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010c27b:	ba 00 00 00 00       	mov    $0x0,%edx
c010c280:	f7 75 dc             	divl   -0x24(%ebp)
c010c283:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010c286:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010c289:	ba 00 00 00 00       	mov    $0x0,%edx
c010c28e:	f7 75 dc             	divl   -0x24(%ebp)
c010c291:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010c294:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010c297:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010c29a:	f7 75 dc             	divl   -0x24(%ebp)
c010c29d:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010c2a0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010c2a3:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010c2a6:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010c2a9:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010c2ac:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010c2af:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
c010c2b2:	83 c4 24             	add    $0x24,%esp
c010c2b5:	5b                   	pop    %ebx
c010c2b6:	5e                   	pop    %esi
c010c2b7:	5f                   	pop    %edi
c010c2b8:	5d                   	pop    %ebp
c010c2b9:	c3                   	ret    

c010c2ba <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
c010c2ba:	f3 0f 1e fb          	endbr32 
c010c2be:	55                   	push   %ebp
c010c2bf:	89 e5                	mov    %esp,%ebp
    next = seed;
c010c2c1:	8b 45 08             	mov    0x8(%ebp),%eax
c010c2c4:	ba 00 00 00 00       	mov    $0x0,%edx
c010c2c9:	a3 20 eb 12 c0       	mov    %eax,0xc012eb20
c010c2ce:	89 15 24 eb 12 c0    	mov    %edx,0xc012eb24
}
c010c2d4:	90                   	nop
c010c2d5:	5d                   	pop    %ebp
c010c2d6:	c3                   	ret    
