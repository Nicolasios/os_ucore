
bin/kernel：     文件格式 elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 90 12 00       	mov    $0x129000,%eax
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
c0100020:	a3 00 90 12 c0       	mov    %eax,0xc0129000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 80 12 c0       	mov    $0xc0128000,%esp
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
c0100040:	b8 60 e1 12 c0       	mov    $0xc012e160,%eax
c0100045:	2d 00 b0 12 c0       	sub    $0xc012b000,%eax
c010004a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100055:	00 
c0100056:	c7 04 24 00 b0 12 c0 	movl   $0xc012b000,(%esp)
c010005d:	e8 60 96 00 00       	call   c01096c2 <memset>

    cons_init();                // init the console
c0100062:	e8 ca 1e 00 00       	call   c0101f31 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100067:	c7 45 f4 00 a0 10 c0 	movl   $0xc010a000,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100071:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100075:	c7 04 24 1c a0 10 c0 	movl   $0xc010a01c,(%esp)
c010007c:	e8 50 02 00 00       	call   c01002d1 <cprintf>

    print_kerninfo();
c0100081:	e8 0e 09 00 00       	call   c0100994 <print_kerninfo>

    grade_backtrace();
c0100086:	e8 ac 00 00 00       	call   c0100137 <grade_backtrace>

    pmm_init();                 // init physical memory management
c010008b:	e8 60 3a 00 00       	call   c0103af0 <pmm_init>

    pic_init();                 // init interrupt controller
c0100090:	e8 17 20 00 00       	call   c01020ac <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100095:	e8 bc 21 00 00       	call   c0102256 <idt_init>

    vmm_init();                 // init virtual memory management
c010009a:	e8 53 50 00 00       	call   c01050f2 <vmm_init>
    proc_init();                // init process table
c010009f:	e8 a4 8f 00 00       	call   c0109048 <proc_init>
    
    ide_init();                 // init ide devices
c01000a4:	e8 bd 0d 00 00       	call   c0100e66 <ide_init>
    swap_init();                // init swap
c01000a9:	e8 fb 59 00 00       	call   c0105aa9 <swap_init>

    clock_init();               // init clock interrupt
c01000ae:	e8 c5 15 00 00       	call   c0101678 <clock_init>
    intr_enable();              // enable irq interrupt
c01000b3:	e8 40 21 00 00       	call   c01021f8 <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();
    
    cpu_idle();                 // run idle process
c01000b8:	e8 4e 91 00 00       	call   c010920b <cpu_idle>

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
c01000de:	e8 10 0d 00 00       	call   c0100df3 <mon_backtrace>
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
c0100180:	a1 00 b0 12 c0       	mov    0xc012b000,%eax
c0100185:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100189:	89 44 24 04          	mov    %eax,0x4(%esp)
c010018d:	c7 04 24 21 a0 10 c0 	movl   $0xc010a021,(%esp)
c0100194:	e8 38 01 00 00       	call   c01002d1 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c0100199:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010019d:	89 c2                	mov    %eax,%edx
c010019f:	a1 00 b0 12 c0       	mov    0xc012b000,%eax
c01001a4:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001a8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001ac:	c7 04 24 2f a0 10 c0 	movl   $0xc010a02f,(%esp)
c01001b3:	e8 19 01 00 00       	call   c01002d1 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c01001b8:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c01001bc:	89 c2                	mov    %eax,%edx
c01001be:	a1 00 b0 12 c0       	mov    0xc012b000,%eax
c01001c3:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001c7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001cb:	c7 04 24 3d a0 10 c0 	movl   $0xc010a03d,(%esp)
c01001d2:	e8 fa 00 00 00       	call   c01002d1 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001d7:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001db:	89 c2                	mov    %eax,%edx
c01001dd:	a1 00 b0 12 c0       	mov    0xc012b000,%eax
c01001e2:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001e6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001ea:	c7 04 24 4b a0 10 c0 	movl   $0xc010a04b,(%esp)
c01001f1:	e8 db 00 00 00       	call   c01002d1 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001f6:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001fa:	89 c2                	mov    %eax,%edx
c01001fc:	a1 00 b0 12 c0       	mov    0xc012b000,%eax
c0100201:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100205:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100209:	c7 04 24 59 a0 10 c0 	movl   $0xc010a059,(%esp)
c0100210:	e8 bc 00 00 00       	call   c01002d1 <cprintf>
    round ++;
c0100215:	a1 00 b0 12 c0       	mov    0xc012b000,%eax
c010021a:	40                   	inc    %eax
c010021b:	a3 00 b0 12 c0       	mov    %eax,0xc012b000
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
c0100246:	c7 04 24 68 a0 10 c0 	movl   $0xc010a068,(%esp)
c010024d:	e8 7f 00 00 00       	call   c01002d1 <cprintf>
    lab1_switch_to_user();
c0100252:	e8 cc ff ff ff       	call   c0100223 <lab1_switch_to_user>
    lab1_print_cur_status();
c0100257:	e8 05 ff ff ff       	call   c0100161 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c010025c:	c7 04 24 88 a0 10 c0 	movl   $0xc010a088,(%esp)
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
c0100285:	e8 d8 1c 00 00       	call   c0101f62 <cons_putc>
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
c01002c7:	e8 62 97 00 00       	call   c0109a2e <vprintfmt>
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
c010030b:	e8 52 1c 00 00       	call   c0101f62 <cons_putc>
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
c0100371:	e8 2d 1c 00 00       	call   c0101fa3 <cons_getc>
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
c010039b:	c7 04 24 a7 a0 10 c0 	movl   $0xc010a0a7,(%esp)
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
c01003e9:	88 90 20 b0 12 c0    	mov    %dl,-0x3fed4fe0(%eax)
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
c0100427:	05 20 b0 12 c0       	add    $0xc012b020,%eax
c010042c:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c010042f:	b8 20 b0 12 c0       	mov    $0xc012b020,%eax
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
c0100447:	a1 20 b4 12 c0       	mov    0xc012b420,%eax
c010044c:	85 c0                	test   %eax,%eax
c010044e:	75 5b                	jne    c01004ab <__panic+0x6e>
        goto panic_dead;
    }
    is_panic = 1;
c0100450:	c7 05 20 b4 12 c0 01 	movl   $0x1,0xc012b420
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
c010046e:	c7 04 24 aa a0 10 c0 	movl   $0xc010a0aa,(%esp)
c0100475:	e8 57 fe ff ff       	call   c01002d1 <cprintf>
    vcprintf(fmt, ap);
c010047a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010047d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100481:	8b 45 10             	mov    0x10(%ebp),%eax
c0100484:	89 04 24             	mov    %eax,(%esp)
c0100487:	e8 0e fe ff ff       	call   c010029a <vcprintf>
    cprintf("\n");
c010048c:	c7 04 24 c6 a0 10 c0 	movl   $0xc010a0c6,(%esp)
c0100493:	e8 39 fe ff ff       	call   c01002d1 <cprintf>
    
    cprintf("stack trackback:\n");
c0100498:	c7 04 24 c8 a0 10 c0 	movl   $0xc010a0c8,(%esp)
c010049f:	e8 2d fe ff ff       	call   c01002d1 <cprintf>
    print_stackframe();
c01004a4:	e8 3d 06 00 00       	call   c0100ae6 <print_stackframe>
c01004a9:	eb 01                	jmp    c01004ac <__panic+0x6f>
        goto panic_dead;
c01004ab:	90                   	nop
    
    va_end(ap);

panic_dead:
    intr_disable();
c01004ac:	e8 53 1d 00 00       	call   c0102204 <intr_disable>
    while (1) {
        kmonitor(NULL);
c01004b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01004b8:	e8 5d 08 00 00       	call   c0100d1a <kmonitor>
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
c01004dd:	c7 04 24 da a0 10 c0 	movl   $0xc010a0da,(%esp)
c01004e4:	e8 e8 fd ff ff       	call   c01002d1 <cprintf>
    vcprintf(fmt, ap);
c01004e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01004ec:	89 44 24 04          	mov    %eax,0x4(%esp)
c01004f0:	8b 45 10             	mov    0x10(%ebp),%eax
c01004f3:	89 04 24             	mov    %eax,(%esp)
c01004f6:	e8 9f fd ff ff       	call   c010029a <vcprintf>
    cprintf("\n");
c01004fb:	c7 04 24 c6 a0 10 c0 	movl   $0xc010a0c6,(%esp)
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
c0100511:	a1 20 b4 12 c0       	mov    0xc012b420,%eax
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
c0100677:	c7 00 f8 a0 10 c0    	movl   $0xc010a0f8,(%eax)
    info->eip_line = 0;
c010067d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100680:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c0100687:	8b 45 0c             	mov    0xc(%ebp),%eax
c010068a:	c7 40 08 f8 a0 10 c0 	movl   $0xc010a0f8,0x8(%eax)
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

    stabs = __STAB_BEGIN__;
c01006ae:	c7 45 f4 8c c3 10 c0 	movl   $0xc010c38c,-0xc(%ebp)
    stab_end = __STAB_END__;
c01006b5:	c7 45 f0 dc 0b 12 c0 	movl   $0xc0120bdc,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c01006bc:	c7 45 ec dd 0b 12 c0 	movl   $0xc0120bdd,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c01006c3:	c7 45 e8 d2 54 12 c0 	movl   $0xc01254d2,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
c01006ca:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01006cd:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01006d0:	76 0b                	jbe    c01006dd <debuginfo_eip+0x73>
c01006d2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01006d5:	48                   	dec    %eax
c01006d6:	0f b6 00             	movzbl (%eax),%eax
c01006d9:	84 c0                	test   %al,%al
c01006db:	74 0a                	je     c01006e7 <debuginfo_eip+0x7d>
    {
        return -1;
c01006dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01006e2:	e9 ab 02 00 00       	jmp    c0100992 <debuginfo_eip+0x328>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c01006e7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c01006ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01006f1:	2b 45 f4             	sub    -0xc(%ebp),%eax
c01006f4:	c1 f8 02             	sar    $0x2,%eax
c01006f7:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c01006fd:	48                   	dec    %eax
c01006fe:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c0100701:	8b 45 08             	mov    0x8(%ebp),%eax
c0100704:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100708:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c010070f:	00 
c0100710:	8d 45 e0             	lea    -0x20(%ebp),%eax
c0100713:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100717:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c010071a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010071e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100721:	89 04 24             	mov    %eax,(%esp)
c0100724:	e8 ef fd ff ff       	call   c0100518 <stab_binsearch>
    if (lfile == 0)
c0100729:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010072c:	85 c0                	test   %eax,%eax
c010072e:	75 0a                	jne    c010073a <debuginfo_eip+0xd0>
        return -1;
c0100730:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100735:	e9 58 02 00 00       	jmp    c0100992 <debuginfo_eip+0x328>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c010073a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010073d:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0100740:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0100743:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c0100746:	8b 45 08             	mov    0x8(%ebp),%eax
c0100749:	89 44 24 10          	mov    %eax,0x10(%esp)
c010074d:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c0100754:	00 
c0100755:	8d 45 d8             	lea    -0x28(%ebp),%eax
c0100758:	89 44 24 08          	mov    %eax,0x8(%esp)
c010075c:	8d 45 dc             	lea    -0x24(%ebp),%eax
c010075f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100763:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100766:	89 04 24             	mov    %eax,(%esp)
c0100769:	e8 aa fd ff ff       	call   c0100518 <stab_binsearch>

    if (lfun <= rfun)
c010076e:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100771:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100774:	39 c2                	cmp    %eax,%edx
c0100776:	7f 78                	jg     c01007f0 <debuginfo_eip+0x186>
    {
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr)
c0100778:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010077b:	89 c2                	mov    %eax,%edx
c010077d:	89 d0                	mov    %edx,%eax
c010077f:	01 c0                	add    %eax,%eax
c0100781:	01 d0                	add    %edx,%eax
c0100783:	c1 e0 02             	shl    $0x2,%eax
c0100786:	89 c2                	mov    %eax,%edx
c0100788:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010078b:	01 d0                	add    %edx,%eax
c010078d:	8b 10                	mov    (%eax),%edx
c010078f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100792:	2b 45 ec             	sub    -0x14(%ebp),%eax
c0100795:	39 c2                	cmp    %eax,%edx
c0100797:	73 22                	jae    c01007bb <debuginfo_eip+0x151>
        {
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c0100799:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010079c:	89 c2                	mov    %eax,%edx
c010079e:	89 d0                	mov    %edx,%eax
c01007a0:	01 c0                	add    %eax,%eax
c01007a2:	01 d0                	add    %edx,%eax
c01007a4:	c1 e0 02             	shl    $0x2,%eax
c01007a7:	89 c2                	mov    %eax,%edx
c01007a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007ac:	01 d0                	add    %edx,%eax
c01007ae:	8b 10                	mov    (%eax),%edx
c01007b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01007b3:	01 c2                	add    %eax,%edx
c01007b5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007b8:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c01007bb:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01007be:	89 c2                	mov    %eax,%edx
c01007c0:	89 d0                	mov    %edx,%eax
c01007c2:	01 c0                	add    %eax,%eax
c01007c4:	01 d0                	add    %edx,%eax
c01007c6:	c1 e0 02             	shl    $0x2,%eax
c01007c9:	89 c2                	mov    %eax,%edx
c01007cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007ce:	01 d0                	add    %edx,%eax
c01007d0:	8b 50 08             	mov    0x8(%eax),%edx
c01007d3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007d6:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c01007d9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007dc:	8b 40 10             	mov    0x10(%eax),%eax
c01007df:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c01007e2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01007e5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c01007e8:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01007eb:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01007ee:	eb 15                	jmp    c0100805 <debuginfo_eip+0x19b>
    }
    else
    {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c01007f0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007f3:	8b 55 08             	mov    0x8(%ebp),%edx
c01007f6:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c01007f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01007fc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c01007ff:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0100802:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c0100805:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100808:	8b 40 08             	mov    0x8(%eax),%eax
c010080b:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c0100812:	00 
c0100813:	89 04 24             	mov    %eax,(%esp)
c0100816:	e8 1b 8d 00 00       	call   c0109536 <strfind>
c010081b:	8b 55 0c             	mov    0xc(%ebp),%edx
c010081e:	8b 52 08             	mov    0x8(%edx),%edx
c0100821:	29 d0                	sub    %edx,%eax
c0100823:	89 c2                	mov    %eax,%edx
c0100825:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100828:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c010082b:	8b 45 08             	mov    0x8(%ebp),%eax
c010082e:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100832:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c0100839:	00 
c010083a:	8d 45 d0             	lea    -0x30(%ebp),%eax
c010083d:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100841:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c0100844:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100848:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010084b:	89 04 24             	mov    %eax,(%esp)
c010084e:	e8 c5 fc ff ff       	call   c0100518 <stab_binsearch>
    if (lline <= rline)
c0100853:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100856:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100859:	39 c2                	cmp    %eax,%edx
c010085b:	7f 23                	jg     c0100880 <debuginfo_eip+0x216>
    {
        info->eip_line = stabs[rline].n_desc;
c010085d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100860:	89 c2                	mov    %eax,%edx
c0100862:	89 d0                	mov    %edx,%eax
c0100864:	01 c0                	add    %eax,%eax
c0100866:	01 d0                	add    %edx,%eax
c0100868:	c1 e0 02             	shl    $0x2,%eax
c010086b:	89 c2                	mov    %eax,%edx
c010086d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100870:	01 d0                	add    %edx,%eax
c0100872:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c0100876:	89 c2                	mov    %eax,%edx
c0100878:	8b 45 0c             	mov    0xc(%ebp),%eax
c010087b:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile && stabs[lline].n_type != N_SOL && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
c010087e:	eb 11                	jmp    c0100891 <debuginfo_eip+0x227>
        return -1;
c0100880:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100885:	e9 08 01 00 00       	jmp    c0100992 <debuginfo_eip+0x328>
    {
        lline--;
c010088a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010088d:	48                   	dec    %eax
c010088e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while (lline >= lfile && stabs[lline].n_type != N_SOL && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
c0100891:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100894:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100897:	39 c2                	cmp    %eax,%edx
c0100899:	7c 56                	jl     c01008f1 <debuginfo_eip+0x287>
c010089b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010089e:	89 c2                	mov    %eax,%edx
c01008a0:	89 d0                	mov    %edx,%eax
c01008a2:	01 c0                	add    %eax,%eax
c01008a4:	01 d0                	add    %edx,%eax
c01008a6:	c1 e0 02             	shl    $0x2,%eax
c01008a9:	89 c2                	mov    %eax,%edx
c01008ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008ae:	01 d0                	add    %edx,%eax
c01008b0:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01008b4:	3c 84                	cmp    $0x84,%al
c01008b6:	74 39                	je     c01008f1 <debuginfo_eip+0x287>
c01008b8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008bb:	89 c2                	mov    %eax,%edx
c01008bd:	89 d0                	mov    %edx,%eax
c01008bf:	01 c0                	add    %eax,%eax
c01008c1:	01 d0                	add    %edx,%eax
c01008c3:	c1 e0 02             	shl    $0x2,%eax
c01008c6:	89 c2                	mov    %eax,%edx
c01008c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008cb:	01 d0                	add    %edx,%eax
c01008cd:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01008d1:	3c 64                	cmp    $0x64,%al
c01008d3:	75 b5                	jne    c010088a <debuginfo_eip+0x220>
c01008d5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008d8:	89 c2                	mov    %eax,%edx
c01008da:	89 d0                	mov    %edx,%eax
c01008dc:	01 c0                	add    %eax,%eax
c01008de:	01 d0                	add    %edx,%eax
c01008e0:	c1 e0 02             	shl    $0x2,%eax
c01008e3:	89 c2                	mov    %eax,%edx
c01008e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008e8:	01 d0                	add    %edx,%eax
c01008ea:	8b 40 08             	mov    0x8(%eax),%eax
c01008ed:	85 c0                	test   %eax,%eax
c01008ef:	74 99                	je     c010088a <debuginfo_eip+0x220>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
c01008f1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01008f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01008f7:	39 c2                	cmp    %eax,%edx
c01008f9:	7c 42                	jl     c010093d <debuginfo_eip+0x2d3>
c01008fb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008fe:	89 c2                	mov    %eax,%edx
c0100900:	89 d0                	mov    %edx,%eax
c0100902:	01 c0                	add    %eax,%eax
c0100904:	01 d0                	add    %edx,%eax
c0100906:	c1 e0 02             	shl    $0x2,%eax
c0100909:	89 c2                	mov    %eax,%edx
c010090b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010090e:	01 d0                	add    %edx,%eax
c0100910:	8b 10                	mov    (%eax),%edx
c0100912:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100915:	2b 45 ec             	sub    -0x14(%ebp),%eax
c0100918:	39 c2                	cmp    %eax,%edx
c010091a:	73 21                	jae    c010093d <debuginfo_eip+0x2d3>
    {
        info->eip_file = stabstr + stabs[lline].n_strx;
c010091c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010091f:	89 c2                	mov    %eax,%edx
c0100921:	89 d0                	mov    %edx,%eax
c0100923:	01 c0                	add    %eax,%eax
c0100925:	01 d0                	add    %edx,%eax
c0100927:	c1 e0 02             	shl    $0x2,%eax
c010092a:	89 c2                	mov    %eax,%edx
c010092c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010092f:	01 d0                	add    %edx,%eax
c0100931:	8b 10                	mov    (%eax),%edx
c0100933:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100936:	01 c2                	add    %eax,%edx
c0100938:	8b 45 0c             	mov    0xc(%ebp),%eax
c010093b:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun)
c010093d:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100940:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100943:	39 c2                	cmp    %eax,%edx
c0100945:	7d 46                	jge    c010098d <debuginfo_eip+0x323>
    {
        for (lline = lfun + 1;
c0100947:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010094a:	40                   	inc    %eax
c010094b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c010094e:	eb 16                	jmp    c0100966 <debuginfo_eip+0x2fc>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline++)
        {
            info->eip_fn_narg++;
c0100950:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100953:	8b 40 14             	mov    0x14(%eax),%eax
c0100956:	8d 50 01             	lea    0x1(%eax),%edx
c0100959:	8b 45 0c             	mov    0xc(%ebp),%eax
c010095c:	89 50 14             	mov    %edx,0x14(%eax)
             lline++)
c010095f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100962:	40                   	inc    %eax
c0100963:	89 45 d4             	mov    %eax,-0x2c(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100966:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100969:	8b 45 d8             	mov    -0x28(%ebp),%eax
        for (lline = lfun + 1;
c010096c:	39 c2                	cmp    %eax,%edx
c010096e:	7d 1d                	jge    c010098d <debuginfo_eip+0x323>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100970:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100973:	89 c2                	mov    %eax,%edx
c0100975:	89 d0                	mov    %edx,%eax
c0100977:	01 c0                	add    %eax,%eax
c0100979:	01 d0                	add    %edx,%eax
c010097b:	c1 e0 02             	shl    $0x2,%eax
c010097e:	89 c2                	mov    %eax,%edx
c0100980:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100983:	01 d0                	add    %edx,%eax
c0100985:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100989:	3c a0                	cmp    $0xa0,%al
c010098b:	74 c3                	je     c0100950 <debuginfo_eip+0x2e6>
        }
    }
    return 0;
c010098d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100992:	c9                   	leave  
c0100993:	c3                   	ret    

c0100994 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void)
{
c0100994:	f3 0f 1e fb          	endbr32 
c0100998:	55                   	push   %ebp
c0100999:	89 e5                	mov    %esp,%ebp
c010099b:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c010099e:	c7 04 24 02 a1 10 c0 	movl   $0xc010a102,(%esp)
c01009a5:	e8 27 f9 ff ff       	call   c01002d1 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c01009aa:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c01009b1:	c0 
c01009b2:	c7 04 24 1b a1 10 c0 	movl   $0xc010a11b,(%esp)
c01009b9:	e8 13 f9 ff ff       	call   c01002d1 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c01009be:	c7 44 24 04 ef 9f 10 	movl   $0xc0109fef,0x4(%esp)
c01009c5:	c0 
c01009c6:	c7 04 24 33 a1 10 c0 	movl   $0xc010a133,(%esp)
c01009cd:	e8 ff f8 ff ff       	call   c01002d1 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c01009d2:	c7 44 24 04 00 b0 12 	movl   $0xc012b000,0x4(%esp)
c01009d9:	c0 
c01009da:	c7 04 24 4b a1 10 c0 	movl   $0xc010a14b,(%esp)
c01009e1:	e8 eb f8 ff ff       	call   c01002d1 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c01009e6:	c7 44 24 04 60 e1 12 	movl   $0xc012e160,0x4(%esp)
c01009ed:	c0 
c01009ee:	c7 04 24 63 a1 10 c0 	movl   $0xc010a163,(%esp)
c01009f5:	e8 d7 f8 ff ff       	call   c01002d1 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023) / 1024);
c01009fa:	b8 60 e1 12 c0       	mov    $0xc012e160,%eax
c01009ff:	2d 36 00 10 c0       	sub    $0xc0100036,%eax
c0100a04:	05 ff 03 00 00       	add    $0x3ff,%eax
c0100a09:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c0100a0f:	85 c0                	test   %eax,%eax
c0100a11:	0f 48 c2             	cmovs  %edx,%eax
c0100a14:	c1 f8 0a             	sar    $0xa,%eax
c0100a17:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a1b:	c7 04 24 7c a1 10 c0 	movl   $0xc010a17c,(%esp)
c0100a22:	e8 aa f8 ff ff       	call   c01002d1 <cprintf>
}
c0100a27:	90                   	nop
c0100a28:	c9                   	leave  
c0100a29:	c3                   	ret    

c0100a2a <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void print_debuginfo(uintptr_t eip)
{
c0100a2a:	f3 0f 1e fb          	endbr32 
c0100a2e:	55                   	push   %ebp
c0100a2f:	89 e5                	mov    %esp,%ebp
c0100a31:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0)
c0100a37:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100a3a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a3e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a41:	89 04 24             	mov    %eax,(%esp)
c0100a44:	e8 21 fc ff ff       	call   c010066a <debuginfo_eip>
c0100a49:	85 c0                	test   %eax,%eax
c0100a4b:	74 15                	je     c0100a62 <print_debuginfo+0x38>
    {
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c0100a4d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a50:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a54:	c7 04 24 a6 a1 10 c0 	movl   $0xc010a1a6,(%esp)
c0100a5b:	e8 71 f8 ff ff       	call   c01002d1 <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
c0100a60:	eb 6c                	jmp    c0100ace <print_debuginfo+0xa4>
        for (j = 0; j < info.eip_fn_namelen; j++)
c0100a62:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100a69:	eb 1b                	jmp    c0100a86 <print_debuginfo+0x5c>
            fnname[j] = info.eip_fn_name[j];
c0100a6b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100a6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a71:	01 d0                	add    %edx,%eax
c0100a73:	0f b6 10             	movzbl (%eax),%edx
c0100a76:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a7f:	01 c8                	add    %ecx,%eax
c0100a81:	88 10                	mov    %dl,(%eax)
        for (j = 0; j < info.eip_fn_namelen; j++)
c0100a83:	ff 45 f4             	incl   -0xc(%ebp)
c0100a86:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a89:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0100a8c:	7c dd                	jl     c0100a6b <print_debuginfo+0x41>
        fnname[j] = '\0';
c0100a8e:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100a94:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a97:	01 d0                	add    %edx,%eax
c0100a99:	c6 00 00             	movb   $0x0,(%eax)
                fnname, eip - info.eip_fn_addr);
c0100a9c:	8b 45 ec             	mov    -0x14(%ebp),%eax
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0100a9f:	8b 55 08             	mov    0x8(%ebp),%edx
c0100aa2:	89 d1                	mov    %edx,%ecx
c0100aa4:	29 c1                	sub    %eax,%ecx
c0100aa6:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0100aa9:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100aac:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0100ab0:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100ab6:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0100aba:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100abe:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ac2:	c7 04 24 c2 a1 10 c0 	movl   $0xc010a1c2,(%esp)
c0100ac9:	e8 03 f8 ff ff       	call   c01002d1 <cprintf>
}
c0100ace:	90                   	nop
c0100acf:	c9                   	leave  
c0100ad0:	c3                   	ret    

c0100ad1 <read_eip>:

static __noinline uint32_t
read_eip(void)
{
c0100ad1:	f3 0f 1e fb          	endbr32 
c0100ad5:	55                   	push   %ebp
c0100ad6:	89 e5                	mov    %esp,%ebp
c0100ad8:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0"
c0100adb:	8b 45 04             	mov    0x4(%ebp),%eax
c0100ade:	89 45 fc             	mov    %eax,-0x4(%ebp)
                 : "=r"(eip));
    return eip;
c0100ae1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0100ae4:	c9                   	leave  
c0100ae5:	c3                   	ret    

c0100ae6 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void print_stackframe(void)
{
c0100ae6:	f3 0f 1e fb          	endbr32 
c0100aea:	55                   	push   %ebp
c0100aeb:	89 e5                	mov    %esp,%ebp
c0100aed:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c0100af0:	89 e8                	mov    %ebp,%eax
c0100af2:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
c0100af5:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp(), eip = read_eip();
c0100af8:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100afb:	e8 d1 ff ff ff       	call   c0100ad1 <read_eip>
c0100b00:	89 45 f0             	mov    %eax,-0x10(%ebp)

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i++)
c0100b03:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0100b0a:	e9 84 00 00 00       	jmp    c0100b93 <print_stackframe+0xad>
    {
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
c0100b0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b12:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100b16:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b19:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b1d:	c7 04 24 d4 a1 10 c0 	movl   $0xc010a1d4,(%esp)
c0100b24:	e8 a8 f7 ff ff       	call   c01002d1 <cprintf>
        uint32_t *args = (uint32_t *)ebp + 2;
c0100b29:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b2c:	83 c0 08             	add    $0x8,%eax
c0100b2f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (j = 0; j < 4; j++)
c0100b32:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0100b39:	eb 24                	jmp    c0100b5f <print_stackframe+0x79>
        {
            cprintf("0x%08x ", args[j]);
c0100b3b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100b3e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100b45:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100b48:	01 d0                	add    %edx,%eax
c0100b4a:	8b 00                	mov    (%eax),%eax
c0100b4c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b50:	c7 04 24 f0 a1 10 c0 	movl   $0xc010a1f0,(%esp)
c0100b57:	e8 75 f7 ff ff       	call   c01002d1 <cprintf>
        for (j = 0; j < 4; j++)
c0100b5c:	ff 45 e8             	incl   -0x18(%ebp)
c0100b5f:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
c0100b63:	7e d6                	jle    c0100b3b <print_stackframe+0x55>
        }
        cprintf("\n");
c0100b65:	c7 04 24 f8 a1 10 c0 	movl   $0xc010a1f8,(%esp)
c0100b6c:	e8 60 f7 ff ff       	call   c01002d1 <cprintf>
        print_debuginfo(eip - 1);
c0100b71:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b74:	48                   	dec    %eax
c0100b75:	89 04 24             	mov    %eax,(%esp)
c0100b78:	e8 ad fe ff ff       	call   c0100a2a <print_debuginfo>
        eip = ((uint32_t *)ebp)[1];
c0100b7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b80:	83 c0 04             	add    $0x4,%eax
c0100b83:	8b 00                	mov    (%eax),%eax
c0100b85:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = ((uint32_t *)ebp)[0];
c0100b88:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b8b:	8b 00                	mov    (%eax),%eax
c0100b8d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i++)
c0100b90:	ff 45 ec             	incl   -0x14(%ebp)
c0100b93:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100b97:	74 0a                	je     c0100ba3 <print_stackframe+0xbd>
c0100b99:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100b9d:	0f 8e 6c ff ff ff    	jle    c0100b0f <print_stackframe+0x29>
    }
}
c0100ba3:	90                   	nop
c0100ba4:	c9                   	leave  
c0100ba5:	c3                   	ret    

c0100ba6 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100ba6:	f3 0f 1e fb          	endbr32 
c0100baa:	55                   	push   %ebp
c0100bab:	89 e5                	mov    %esp,%ebp
c0100bad:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100bb0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100bb7:	eb 0c                	jmp    c0100bc5 <parse+0x1f>
            *buf ++ = '\0';
c0100bb9:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bbc:	8d 50 01             	lea    0x1(%eax),%edx
c0100bbf:	89 55 08             	mov    %edx,0x8(%ebp)
c0100bc2:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100bc5:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bc8:	0f b6 00             	movzbl (%eax),%eax
c0100bcb:	84 c0                	test   %al,%al
c0100bcd:	74 1d                	je     c0100bec <parse+0x46>
c0100bcf:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bd2:	0f b6 00             	movzbl (%eax),%eax
c0100bd5:	0f be c0             	movsbl %al,%eax
c0100bd8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100bdc:	c7 04 24 7c a2 10 c0 	movl   $0xc010a27c,(%esp)
c0100be3:	e8 18 89 00 00       	call   c0109500 <strchr>
c0100be8:	85 c0                	test   %eax,%eax
c0100bea:	75 cd                	jne    c0100bb9 <parse+0x13>
        }
        if (*buf == '\0') {
c0100bec:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bef:	0f b6 00             	movzbl (%eax),%eax
c0100bf2:	84 c0                	test   %al,%al
c0100bf4:	74 65                	je     c0100c5b <parse+0xb5>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100bf6:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100bfa:	75 14                	jne    c0100c10 <parse+0x6a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100bfc:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100c03:	00 
c0100c04:	c7 04 24 81 a2 10 c0 	movl   $0xc010a281,(%esp)
c0100c0b:	e8 c1 f6 ff ff       	call   c01002d1 <cprintf>
        }
        argv[argc ++] = buf;
c0100c10:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c13:	8d 50 01             	lea    0x1(%eax),%edx
c0100c16:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100c19:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100c20:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100c23:	01 c2                	add    %eax,%edx
c0100c25:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c28:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100c2a:	eb 03                	jmp    c0100c2f <parse+0x89>
            buf ++;
c0100c2c:	ff 45 08             	incl   0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100c2f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c32:	0f b6 00             	movzbl (%eax),%eax
c0100c35:	84 c0                	test   %al,%al
c0100c37:	74 8c                	je     c0100bc5 <parse+0x1f>
c0100c39:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c3c:	0f b6 00             	movzbl (%eax),%eax
c0100c3f:	0f be c0             	movsbl %al,%eax
c0100c42:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c46:	c7 04 24 7c a2 10 c0 	movl   $0xc010a27c,(%esp)
c0100c4d:	e8 ae 88 00 00       	call   c0109500 <strchr>
c0100c52:	85 c0                	test   %eax,%eax
c0100c54:	74 d6                	je     c0100c2c <parse+0x86>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100c56:	e9 6a ff ff ff       	jmp    c0100bc5 <parse+0x1f>
            break;
c0100c5b:	90                   	nop
        }
    }
    return argc;
c0100c5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100c5f:	c9                   	leave  
c0100c60:	c3                   	ret    

c0100c61 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100c61:	f3 0f 1e fb          	endbr32 
c0100c65:	55                   	push   %ebp
c0100c66:	89 e5                	mov    %esp,%ebp
c0100c68:	53                   	push   %ebx
c0100c69:	83 ec 64             	sub    $0x64,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100c6c:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100c6f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c73:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c76:	89 04 24             	mov    %eax,(%esp)
c0100c79:	e8 28 ff ff ff       	call   c0100ba6 <parse>
c0100c7e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100c81:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100c85:	75 0a                	jne    c0100c91 <runcmd+0x30>
        return 0;
c0100c87:	b8 00 00 00 00       	mov    $0x0,%eax
c0100c8c:	e9 83 00 00 00       	jmp    c0100d14 <runcmd+0xb3>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c91:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100c98:	eb 5a                	jmp    c0100cf4 <runcmd+0x93>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100c9a:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0100c9d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100ca0:	89 d0                	mov    %edx,%eax
c0100ca2:	01 c0                	add    %eax,%eax
c0100ca4:	01 d0                	add    %edx,%eax
c0100ca6:	c1 e0 02             	shl    $0x2,%eax
c0100ca9:	05 00 80 12 c0       	add    $0xc0128000,%eax
c0100cae:	8b 00                	mov    (%eax),%eax
c0100cb0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0100cb4:	89 04 24             	mov    %eax,(%esp)
c0100cb7:	e8 a0 87 00 00       	call   c010945c <strcmp>
c0100cbc:	85 c0                	test   %eax,%eax
c0100cbe:	75 31                	jne    c0100cf1 <runcmd+0x90>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100cc0:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100cc3:	89 d0                	mov    %edx,%eax
c0100cc5:	01 c0                	add    %eax,%eax
c0100cc7:	01 d0                	add    %edx,%eax
c0100cc9:	c1 e0 02             	shl    $0x2,%eax
c0100ccc:	05 08 80 12 c0       	add    $0xc0128008,%eax
c0100cd1:	8b 10                	mov    (%eax),%edx
c0100cd3:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100cd6:	83 c0 04             	add    $0x4,%eax
c0100cd9:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0100cdc:	8d 59 ff             	lea    -0x1(%ecx),%ebx
c0100cdf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c0100ce2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100ce6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100cea:	89 1c 24             	mov    %ebx,(%esp)
c0100ced:	ff d2                	call   *%edx
c0100cef:	eb 23                	jmp    c0100d14 <runcmd+0xb3>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100cf1:	ff 45 f4             	incl   -0xc(%ebp)
c0100cf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100cf7:	83 f8 02             	cmp    $0x2,%eax
c0100cfa:	76 9e                	jbe    c0100c9a <runcmd+0x39>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100cfc:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100cff:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d03:	c7 04 24 9f a2 10 c0 	movl   $0xc010a29f,(%esp)
c0100d0a:	e8 c2 f5 ff ff       	call   c01002d1 <cprintf>
    return 0;
c0100d0f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d14:	83 c4 64             	add    $0x64,%esp
c0100d17:	5b                   	pop    %ebx
c0100d18:	5d                   	pop    %ebp
c0100d19:	c3                   	ret    

c0100d1a <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100d1a:	f3 0f 1e fb          	endbr32 
c0100d1e:	55                   	push   %ebp
c0100d1f:	89 e5                	mov    %esp,%ebp
c0100d21:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100d24:	c7 04 24 b8 a2 10 c0 	movl   $0xc010a2b8,(%esp)
c0100d2b:	e8 a1 f5 ff ff       	call   c01002d1 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100d30:	c7 04 24 e0 a2 10 c0 	movl   $0xc010a2e0,(%esp)
c0100d37:	e8 95 f5 ff ff       	call   c01002d1 <cprintf>

    if (tf != NULL) {
c0100d3c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100d40:	74 0b                	je     c0100d4d <kmonitor+0x33>
        print_trapframe(tf);
c0100d42:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d45:	89 04 24             	mov    %eax,(%esp)
c0100d48:	e8 61 15 00 00       	call   c01022ae <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100d4d:	c7 04 24 05 a3 10 c0 	movl   $0xc010a305,(%esp)
c0100d54:	e8 2b f6 ff ff       	call   c0100384 <readline>
c0100d59:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100d5c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100d60:	74 eb                	je     c0100d4d <kmonitor+0x33>
            if (runcmd(buf, tf) < 0) {
c0100d62:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d65:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d69:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d6c:	89 04 24             	mov    %eax,(%esp)
c0100d6f:	e8 ed fe ff ff       	call   c0100c61 <runcmd>
c0100d74:	85 c0                	test   %eax,%eax
c0100d76:	78 02                	js     c0100d7a <kmonitor+0x60>
        if ((buf = readline("K> ")) != NULL) {
c0100d78:	eb d3                	jmp    c0100d4d <kmonitor+0x33>
                break;
c0100d7a:	90                   	nop
            }
        }
    }
}
c0100d7b:	90                   	nop
c0100d7c:	c9                   	leave  
c0100d7d:	c3                   	ret    

c0100d7e <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100d7e:	f3 0f 1e fb          	endbr32 
c0100d82:	55                   	push   %ebp
c0100d83:	89 e5                	mov    %esp,%ebp
c0100d85:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d88:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100d8f:	eb 3d                	jmp    c0100dce <mon_help+0x50>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100d91:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d94:	89 d0                	mov    %edx,%eax
c0100d96:	01 c0                	add    %eax,%eax
c0100d98:	01 d0                	add    %edx,%eax
c0100d9a:	c1 e0 02             	shl    $0x2,%eax
c0100d9d:	05 04 80 12 c0       	add    $0xc0128004,%eax
c0100da2:	8b 08                	mov    (%eax),%ecx
c0100da4:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100da7:	89 d0                	mov    %edx,%eax
c0100da9:	01 c0                	add    %eax,%eax
c0100dab:	01 d0                	add    %edx,%eax
c0100dad:	c1 e0 02             	shl    $0x2,%eax
c0100db0:	05 00 80 12 c0       	add    $0xc0128000,%eax
c0100db5:	8b 00                	mov    (%eax),%eax
c0100db7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100dbb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100dbf:	c7 04 24 09 a3 10 c0 	movl   $0xc010a309,(%esp)
c0100dc6:	e8 06 f5 ff ff       	call   c01002d1 <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100dcb:	ff 45 f4             	incl   -0xc(%ebp)
c0100dce:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100dd1:	83 f8 02             	cmp    $0x2,%eax
c0100dd4:	76 bb                	jbe    c0100d91 <mon_help+0x13>
    }
    return 0;
c0100dd6:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100ddb:	c9                   	leave  
c0100ddc:	c3                   	ret    

c0100ddd <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100ddd:	f3 0f 1e fb          	endbr32 
c0100de1:	55                   	push   %ebp
c0100de2:	89 e5                	mov    %esp,%ebp
c0100de4:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100de7:	e8 a8 fb ff ff       	call   c0100994 <print_kerninfo>
    return 0;
c0100dec:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100df1:	c9                   	leave  
c0100df2:	c3                   	ret    

c0100df3 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100df3:	f3 0f 1e fb          	endbr32 
c0100df7:	55                   	push   %ebp
c0100df8:	89 e5                	mov    %esp,%ebp
c0100dfa:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100dfd:	e8 e4 fc ff ff       	call   c0100ae6 <print_stackframe>
    return 0;
c0100e02:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e07:	c9                   	leave  
c0100e08:	c3                   	ret    

c0100e09 <ide_wait_ready>:
    unsigned int size;          // Size in Sectors
    unsigned char model[41];    // Model in String
} ide_devices[MAX_IDE];

static int
ide_wait_ready(unsigned short iobase, bool check_error) {
c0100e09:	f3 0f 1e fb          	endbr32 
c0100e0d:	55                   	push   %ebp
c0100e0e:	89 e5                	mov    %esp,%ebp
c0100e10:	83 ec 14             	sub    $0x14,%esp
c0100e13:	8b 45 08             	mov    0x8(%ebp),%eax
c0100e16:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    int r;
    while ((r = inb(iobase + ISA_STATUS)) & IDE_BSY)
c0100e1a:	90                   	nop
c0100e1b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100e1e:	83 c0 07             	add    $0x7,%eax
c0100e21:	0f b7 c0             	movzwl %ax,%eax
c0100e24:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100e28:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100e2c:	89 c2                	mov    %eax,%edx
c0100e2e:	ec                   	in     (%dx),%al
c0100e2f:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0100e32:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0100e36:	0f b6 c0             	movzbl %al,%eax
c0100e39:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100e3c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e3f:	25 80 00 00 00       	and    $0x80,%eax
c0100e44:	85 c0                	test   %eax,%eax
c0100e46:	75 d3                	jne    c0100e1b <ide_wait_ready+0x12>
        /* nothing */;
    if (check_error && (r & (IDE_DF | IDE_ERR)) != 0) {
c0100e48:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0100e4c:	74 11                	je     c0100e5f <ide_wait_ready+0x56>
c0100e4e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e51:	83 e0 21             	and    $0x21,%eax
c0100e54:	85 c0                	test   %eax,%eax
c0100e56:	74 07                	je     c0100e5f <ide_wait_ready+0x56>
        return -1;
c0100e58:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100e5d:	eb 05                	jmp    c0100e64 <ide_wait_ready+0x5b>
    }
    return 0;
c0100e5f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e64:	c9                   	leave  
c0100e65:	c3                   	ret    

c0100e66 <ide_init>:

void
ide_init(void) {
c0100e66:	f3 0f 1e fb          	endbr32 
c0100e6a:	55                   	push   %ebp
c0100e6b:	89 e5                	mov    %esp,%ebp
c0100e6d:	57                   	push   %edi
c0100e6e:	53                   	push   %ebx
c0100e6f:	81 ec 50 02 00 00    	sub    $0x250,%esp
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c0100e75:	66 c7 45 f6 00 00    	movw   $0x0,-0xa(%ebp)
c0100e7b:	e9 bd 02 00 00       	jmp    c010113d <ide_init+0x2d7>
        /* assume that no device here */
        ide_devices[ideno].valid = 0;
c0100e80:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100e84:	89 d0                	mov    %edx,%eax
c0100e86:	c1 e0 03             	shl    $0x3,%eax
c0100e89:	29 d0                	sub    %edx,%eax
c0100e8b:	c1 e0 03             	shl    $0x3,%eax
c0100e8e:	05 40 b4 12 c0       	add    $0xc012b440,%eax
c0100e93:	c6 00 00             	movb   $0x0,(%eax)

        iobase = IO_BASE(ideno);
c0100e96:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100e9a:	d1 e8                	shr    %eax
c0100e9c:	0f b7 c0             	movzwl %ax,%eax
c0100e9f:	8b 04 85 14 a3 10 c0 	mov    -0x3fef5cec(,%eax,4),%eax
c0100ea6:	66 89 45 ea          	mov    %ax,-0x16(%ebp)

        /* wait device ready */
        ide_wait_ready(iobase, 0);
c0100eaa:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100eae:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100eb5:	00 
c0100eb6:	89 04 24             	mov    %eax,(%esp)
c0100eb9:	e8 4b ff ff ff       	call   c0100e09 <ide_wait_ready>

        /* step1: select drive */
        outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4));
c0100ebe:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100ec2:	c1 e0 04             	shl    $0x4,%eax
c0100ec5:	24 10                	and    $0x10,%al
c0100ec7:	0c e0                	or     $0xe0,%al
c0100ec9:	0f b6 c0             	movzbl %al,%eax
c0100ecc:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100ed0:	83 c2 06             	add    $0x6,%edx
c0100ed3:	0f b7 d2             	movzwl %dx,%edx
c0100ed6:	66 89 55 ca          	mov    %dx,-0x36(%ebp)
c0100eda:	88 45 c9             	mov    %al,-0x37(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100edd:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c0100ee1:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c0100ee5:	ee                   	out    %al,(%dx)
}
c0100ee6:	90                   	nop
        ide_wait_ready(iobase, 0);
c0100ee7:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100eeb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100ef2:	00 
c0100ef3:	89 04 24             	mov    %eax,(%esp)
c0100ef6:	e8 0e ff ff ff       	call   c0100e09 <ide_wait_ready>

        /* step2: send ATA identify command */
        outb(iobase + ISA_COMMAND, IDE_CMD_IDENTIFY);
c0100efb:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100eff:	83 c0 07             	add    $0x7,%eax
c0100f02:	0f b7 c0             	movzwl %ax,%eax
c0100f05:	66 89 45 ce          	mov    %ax,-0x32(%ebp)
c0100f09:	c6 45 cd ec          	movb   $0xec,-0x33(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f0d:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c0100f11:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c0100f15:	ee                   	out    %al,(%dx)
}
c0100f16:	90                   	nop
        ide_wait_ready(iobase, 0);
c0100f17:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100f1b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100f22:	00 
c0100f23:	89 04 24             	mov    %eax,(%esp)
c0100f26:	e8 de fe ff ff       	call   c0100e09 <ide_wait_ready>

        /* step3: polling */
        if (inb(iobase + ISA_STATUS) == 0 || ide_wait_ready(iobase, 1) != 0) {
c0100f2b:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100f2f:	83 c0 07             	add    $0x7,%eax
c0100f32:	0f b7 c0             	movzwl %ax,%eax
c0100f35:	66 89 45 d2          	mov    %ax,-0x2e(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f39:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
c0100f3d:	89 c2                	mov    %eax,%edx
c0100f3f:	ec                   	in     (%dx),%al
c0100f40:	88 45 d1             	mov    %al,-0x2f(%ebp)
    return data;
c0100f43:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0100f47:	84 c0                	test   %al,%al
c0100f49:	0f 84 e4 01 00 00    	je     c0101133 <ide_init+0x2cd>
c0100f4f:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100f53:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0100f5a:	00 
c0100f5b:	89 04 24             	mov    %eax,(%esp)
c0100f5e:	e8 a6 fe ff ff       	call   c0100e09 <ide_wait_ready>
c0100f63:	85 c0                	test   %eax,%eax
c0100f65:	0f 85 c8 01 00 00    	jne    c0101133 <ide_init+0x2cd>
            continue ;
        }

        /* device is ok */
        ide_devices[ideno].valid = 1;
c0100f6b:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100f6f:	89 d0                	mov    %edx,%eax
c0100f71:	c1 e0 03             	shl    $0x3,%eax
c0100f74:	29 d0                	sub    %edx,%eax
c0100f76:	c1 e0 03             	shl    $0x3,%eax
c0100f79:	05 40 b4 12 c0       	add    $0xc012b440,%eax
c0100f7e:	c6 00 01             	movb   $0x1,(%eax)

        /* read identification space of the device */
        unsigned int buffer[128];
        insl(iobase + ISA_DATA, buffer, sizeof(buffer) / sizeof(unsigned int));
c0100f81:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100f85:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c0100f88:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c0100f8e:	89 45 c0             	mov    %eax,-0x40(%ebp)
c0100f91:	c7 45 bc 80 00 00 00 	movl   $0x80,-0x44(%ebp)
    asm volatile (
c0100f98:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0100f9b:	8b 4d c0             	mov    -0x40(%ebp),%ecx
c0100f9e:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0100fa1:	89 cb                	mov    %ecx,%ebx
c0100fa3:	89 df                	mov    %ebx,%edi
c0100fa5:	89 c1                	mov    %eax,%ecx
c0100fa7:	fc                   	cld    
c0100fa8:	f2 6d                	repnz insl (%dx),%es:(%edi)
c0100faa:	89 c8                	mov    %ecx,%eax
c0100fac:	89 fb                	mov    %edi,%ebx
c0100fae:	89 5d c0             	mov    %ebx,-0x40(%ebp)
c0100fb1:	89 45 bc             	mov    %eax,-0x44(%ebp)
}
c0100fb4:	90                   	nop

        unsigned char *ident = (unsigned char *)buffer;
c0100fb5:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c0100fbb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        unsigned int sectors;
        unsigned int cmdsets = *(unsigned int *)(ident + IDE_IDENT_CMDSETS);
c0100fbe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100fc1:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
c0100fc7:	89 45 e0             	mov    %eax,-0x20(%ebp)
        /* device use 48-bits or 28-bits addressing */
        if (cmdsets & (1 << 26)) {
c0100fca:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0100fcd:	25 00 00 00 04       	and    $0x4000000,%eax
c0100fd2:	85 c0                	test   %eax,%eax
c0100fd4:	74 0e                	je     c0100fe4 <ide_init+0x17e>
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA_EXT);
c0100fd6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100fd9:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
c0100fdf:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100fe2:	eb 09                	jmp    c0100fed <ide_init+0x187>
        }
        else {
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA);
c0100fe4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100fe7:	8b 40 78             	mov    0x78(%eax),%eax
c0100fea:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        ide_devices[ideno].sets = cmdsets;
c0100fed:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100ff1:	89 d0                	mov    %edx,%eax
c0100ff3:	c1 e0 03             	shl    $0x3,%eax
c0100ff6:	29 d0                	sub    %edx,%eax
c0100ff8:	c1 e0 03             	shl    $0x3,%eax
c0100ffb:	8d 90 44 b4 12 c0    	lea    -0x3fed4bbc(%eax),%edx
c0101001:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0101004:	89 02                	mov    %eax,(%edx)
        ide_devices[ideno].size = sectors;
c0101006:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010100a:	89 d0                	mov    %edx,%eax
c010100c:	c1 e0 03             	shl    $0x3,%eax
c010100f:	29 d0                	sub    %edx,%eax
c0101011:	c1 e0 03             	shl    $0x3,%eax
c0101014:	8d 90 48 b4 12 c0    	lea    -0x3fed4bb8(%eax),%edx
c010101a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010101d:	89 02                	mov    %eax,(%edx)

        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);
c010101f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101022:	83 c0 62             	add    $0x62,%eax
c0101025:	0f b7 00             	movzwl (%eax),%eax
c0101028:	25 00 02 00 00       	and    $0x200,%eax
c010102d:	85 c0                	test   %eax,%eax
c010102f:	75 24                	jne    c0101055 <ide_init+0x1ef>
c0101031:	c7 44 24 0c 1c a3 10 	movl   $0xc010a31c,0xc(%esp)
c0101038:	c0 
c0101039:	c7 44 24 08 5f a3 10 	movl   $0xc010a35f,0x8(%esp)
c0101040:	c0 
c0101041:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c0101048:	00 
c0101049:	c7 04 24 74 a3 10 c0 	movl   $0xc010a374,(%esp)
c0101050:	e8 e8 f3 ff ff       	call   c010043d <__panic>

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
c0101055:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101059:	89 d0                	mov    %edx,%eax
c010105b:	c1 e0 03             	shl    $0x3,%eax
c010105e:	29 d0                	sub    %edx,%eax
c0101060:	c1 e0 03             	shl    $0x3,%eax
c0101063:	05 40 b4 12 c0       	add    $0xc012b440,%eax
c0101068:	83 c0 0c             	add    $0xc,%eax
c010106b:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010106e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101071:	83 c0 36             	add    $0x36,%eax
c0101074:	89 45 d8             	mov    %eax,-0x28(%ebp)
        unsigned int i, length = 40;
c0101077:	c7 45 d4 28 00 00 00 	movl   $0x28,-0x2c(%ebp)
        for (i = 0; i < length; i += 2) {
c010107e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0101085:	eb 34                	jmp    c01010bb <ide_init+0x255>
            model[i] = data[i + 1], model[i + 1] = data[i];
c0101087:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010108a:	8d 50 01             	lea    0x1(%eax),%edx
c010108d:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0101090:	01 c2                	add    %eax,%edx
c0101092:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0101095:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101098:	01 c8                	add    %ecx,%eax
c010109a:	0f b6 12             	movzbl (%edx),%edx
c010109d:	88 10                	mov    %dl,(%eax)
c010109f:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01010a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01010a5:	01 c2                	add    %eax,%edx
c01010a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01010aa:	8d 48 01             	lea    0x1(%eax),%ecx
c01010ad:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01010b0:	01 c8                	add    %ecx,%eax
c01010b2:	0f b6 12             	movzbl (%edx),%edx
c01010b5:	88 10                	mov    %dl,(%eax)
        for (i = 0; i < length; i += 2) {
c01010b7:	83 45 ec 02          	addl   $0x2,-0x14(%ebp)
c01010bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01010be:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c01010c1:	72 c4                	jb     c0101087 <ide_init+0x221>
        }
        do {
            model[i] = '\0';
c01010c3:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01010c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01010c9:	01 d0                	add    %edx,%eax
c01010cb:	c6 00 00             	movb   $0x0,(%eax)
        } while (i -- > 0 && model[i] == ' ');
c01010ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01010d1:	8d 50 ff             	lea    -0x1(%eax),%edx
c01010d4:	89 55 ec             	mov    %edx,-0x14(%ebp)
c01010d7:	85 c0                	test   %eax,%eax
c01010d9:	74 0f                	je     c01010ea <ide_init+0x284>
c01010db:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01010de:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01010e1:	01 d0                	add    %edx,%eax
c01010e3:	0f b6 00             	movzbl (%eax),%eax
c01010e6:	3c 20                	cmp    $0x20,%al
c01010e8:	74 d9                	je     c01010c3 <ide_init+0x25d>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
c01010ea:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01010ee:	89 d0                	mov    %edx,%eax
c01010f0:	c1 e0 03             	shl    $0x3,%eax
c01010f3:	29 d0                	sub    %edx,%eax
c01010f5:	c1 e0 03             	shl    $0x3,%eax
c01010f8:	05 40 b4 12 c0       	add    $0xc012b440,%eax
c01010fd:	8d 48 0c             	lea    0xc(%eax),%ecx
c0101100:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101104:	89 d0                	mov    %edx,%eax
c0101106:	c1 e0 03             	shl    $0x3,%eax
c0101109:	29 d0                	sub    %edx,%eax
c010110b:	c1 e0 03             	shl    $0x3,%eax
c010110e:	05 48 b4 12 c0       	add    $0xc012b448,%eax
c0101113:	8b 10                	mov    (%eax),%edx
c0101115:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101119:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c010111d:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101121:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101125:	c7 04 24 86 a3 10 c0 	movl   $0xc010a386,(%esp)
c010112c:	e8 a0 f1 ff ff       	call   c01002d1 <cprintf>
c0101131:	eb 01                	jmp    c0101134 <ide_init+0x2ce>
            continue ;
c0101133:	90                   	nop
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c0101134:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101138:	40                   	inc    %eax
c0101139:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
c010113d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101141:	83 f8 03             	cmp    $0x3,%eax
c0101144:	0f 86 36 fd ff ff    	jbe    c0100e80 <ide_init+0x1a>
    }

    // enable ide interrupt
    pic_enable(IRQ_IDE1);
c010114a:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
c0101151:	e8 1f 0f 00 00       	call   c0102075 <pic_enable>
    pic_enable(IRQ_IDE2);
c0101156:	c7 04 24 0f 00 00 00 	movl   $0xf,(%esp)
c010115d:	e8 13 0f 00 00       	call   c0102075 <pic_enable>
}
c0101162:	90                   	nop
c0101163:	81 c4 50 02 00 00    	add    $0x250,%esp
c0101169:	5b                   	pop    %ebx
c010116a:	5f                   	pop    %edi
c010116b:	5d                   	pop    %ebp
c010116c:	c3                   	ret    

c010116d <ide_device_valid>:

bool
ide_device_valid(unsigned short ideno) {
c010116d:	f3 0f 1e fb          	endbr32 
c0101171:	55                   	push   %ebp
c0101172:	89 e5                	mov    %esp,%ebp
c0101174:	83 ec 04             	sub    $0x4,%esp
c0101177:	8b 45 08             	mov    0x8(%ebp),%eax
c010117a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    return VALID_IDE(ideno);
c010117e:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101182:	83 f8 03             	cmp    $0x3,%eax
c0101185:	77 21                	ja     c01011a8 <ide_device_valid+0x3b>
c0101187:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
c010118b:	89 d0                	mov    %edx,%eax
c010118d:	c1 e0 03             	shl    $0x3,%eax
c0101190:	29 d0                	sub    %edx,%eax
c0101192:	c1 e0 03             	shl    $0x3,%eax
c0101195:	05 40 b4 12 c0       	add    $0xc012b440,%eax
c010119a:	0f b6 00             	movzbl (%eax),%eax
c010119d:	84 c0                	test   %al,%al
c010119f:	74 07                	je     c01011a8 <ide_device_valid+0x3b>
c01011a1:	b8 01 00 00 00       	mov    $0x1,%eax
c01011a6:	eb 05                	jmp    c01011ad <ide_device_valid+0x40>
c01011a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01011ad:	c9                   	leave  
c01011ae:	c3                   	ret    

c01011af <ide_device_size>:

size_t
ide_device_size(unsigned short ideno) {
c01011af:	f3 0f 1e fb          	endbr32 
c01011b3:	55                   	push   %ebp
c01011b4:	89 e5                	mov    %esp,%ebp
c01011b6:	83 ec 08             	sub    $0x8,%esp
c01011b9:	8b 45 08             	mov    0x8(%ebp),%eax
c01011bc:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    if (ide_device_valid(ideno)) {
c01011c0:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c01011c4:	89 04 24             	mov    %eax,(%esp)
c01011c7:	e8 a1 ff ff ff       	call   c010116d <ide_device_valid>
c01011cc:	85 c0                	test   %eax,%eax
c01011ce:	74 17                	je     c01011e7 <ide_device_size+0x38>
        return ide_devices[ideno].size;
c01011d0:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
c01011d4:	89 d0                	mov    %edx,%eax
c01011d6:	c1 e0 03             	shl    $0x3,%eax
c01011d9:	29 d0                	sub    %edx,%eax
c01011db:	c1 e0 03             	shl    $0x3,%eax
c01011de:	05 48 b4 12 c0       	add    $0xc012b448,%eax
c01011e3:	8b 00                	mov    (%eax),%eax
c01011e5:	eb 05                	jmp    c01011ec <ide_device_size+0x3d>
    }
    return 0;
c01011e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01011ec:	c9                   	leave  
c01011ed:	c3                   	ret    

c01011ee <ide_read_secs>:

int
ide_read_secs(unsigned short ideno, uint32_t secno, void *dst, size_t nsecs) {
c01011ee:	f3 0f 1e fb          	endbr32 
c01011f2:	55                   	push   %ebp
c01011f3:	89 e5                	mov    %esp,%ebp
c01011f5:	57                   	push   %edi
c01011f6:	53                   	push   %ebx
c01011f7:	83 ec 50             	sub    $0x50,%esp
c01011fa:	8b 45 08             	mov    0x8(%ebp),%eax
c01011fd:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c0101201:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c0101208:	77 23                	ja     c010122d <ide_read_secs+0x3f>
c010120a:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c010120e:	83 f8 03             	cmp    $0x3,%eax
c0101211:	77 1a                	ja     c010122d <ide_read_secs+0x3f>
c0101213:	0f b7 55 c4          	movzwl -0x3c(%ebp),%edx
c0101217:	89 d0                	mov    %edx,%eax
c0101219:	c1 e0 03             	shl    $0x3,%eax
c010121c:	29 d0                	sub    %edx,%eax
c010121e:	c1 e0 03             	shl    $0x3,%eax
c0101221:	05 40 b4 12 c0       	add    $0xc012b440,%eax
c0101226:	0f b6 00             	movzbl (%eax),%eax
c0101229:	84 c0                	test   %al,%al
c010122b:	75 24                	jne    c0101251 <ide_read_secs+0x63>
c010122d:	c7 44 24 0c a4 a3 10 	movl   $0xc010a3a4,0xc(%esp)
c0101234:	c0 
c0101235:	c7 44 24 08 5f a3 10 	movl   $0xc010a35f,0x8(%esp)
c010123c:	c0 
c010123d:	c7 44 24 04 9f 00 00 	movl   $0x9f,0x4(%esp)
c0101244:	00 
c0101245:	c7 04 24 74 a3 10 c0 	movl   $0xc010a374,(%esp)
c010124c:	e8 ec f1 ff ff       	call   c010043d <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0101251:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101258:	77 0f                	ja     c0101269 <ide_read_secs+0x7b>
c010125a:	8b 55 0c             	mov    0xc(%ebp),%edx
c010125d:	8b 45 14             	mov    0x14(%ebp),%eax
c0101260:	01 d0                	add    %edx,%eax
c0101262:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0101267:	76 24                	jbe    c010128d <ide_read_secs+0x9f>
c0101269:	c7 44 24 0c cc a3 10 	movl   $0xc010a3cc,0xc(%esp)
c0101270:	c0 
c0101271:	c7 44 24 08 5f a3 10 	movl   $0xc010a35f,0x8(%esp)
c0101278:	c0 
c0101279:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
c0101280:	00 
c0101281:	c7 04 24 74 a3 10 c0 	movl   $0xc010a374,(%esp)
c0101288:	e8 b0 f1 ff ff       	call   c010043d <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c010128d:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101291:	d1 e8                	shr    %eax
c0101293:	0f b7 c0             	movzwl %ax,%eax
c0101296:	8b 04 85 14 a3 10 c0 	mov    -0x3fef5cec(,%eax,4),%eax
c010129d:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c01012a1:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c01012a5:	d1 e8                	shr    %eax
c01012a7:	0f b7 c0             	movzwl %ax,%eax
c01012aa:	0f b7 04 85 16 a3 10 	movzwl -0x3fef5cea(,%eax,4),%eax
c01012b1:	c0 
c01012b2:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c01012b6:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01012ba:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01012c1:	00 
c01012c2:	89 04 24             	mov    %eax,(%esp)
c01012c5:	e8 3f fb ff ff       	call   c0100e09 <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c01012ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01012cd:	83 c0 02             	add    $0x2,%eax
c01012d0:	0f b7 c0             	movzwl %ax,%eax
c01012d3:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c01012d7:	c6 45 d5 00          	movb   $0x0,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01012db:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c01012df:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c01012e3:	ee                   	out    %al,(%dx)
}
c01012e4:	90                   	nop
    outb(iobase + ISA_SECCNT, nsecs);
c01012e5:	8b 45 14             	mov    0x14(%ebp),%eax
c01012e8:	0f b6 c0             	movzbl %al,%eax
c01012eb:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01012ef:	83 c2 02             	add    $0x2,%edx
c01012f2:	0f b7 d2             	movzwl %dx,%edx
c01012f5:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c01012f9:	88 45 d9             	mov    %al,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01012fc:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101300:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101304:	ee                   	out    %al,(%dx)
}
c0101305:	90                   	nop
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c0101306:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101309:	0f b6 c0             	movzbl %al,%eax
c010130c:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101310:	83 c2 03             	add    $0x3,%edx
c0101313:	0f b7 d2             	movzwl %dx,%edx
c0101316:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c010131a:	88 45 dd             	mov    %al,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010131d:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101321:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101325:	ee                   	out    %al,(%dx)
}
c0101326:	90                   	nop
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c0101327:	8b 45 0c             	mov    0xc(%ebp),%eax
c010132a:	c1 e8 08             	shr    $0x8,%eax
c010132d:	0f b6 c0             	movzbl %al,%eax
c0101330:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101334:	83 c2 04             	add    $0x4,%edx
c0101337:	0f b7 d2             	movzwl %dx,%edx
c010133a:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c010133e:	88 45 e1             	mov    %al,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101341:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101345:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101349:	ee                   	out    %al,(%dx)
}
c010134a:	90                   	nop
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c010134b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010134e:	c1 e8 10             	shr    $0x10,%eax
c0101351:	0f b6 c0             	movzbl %al,%eax
c0101354:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101358:	83 c2 05             	add    $0x5,%edx
c010135b:	0f b7 d2             	movzwl %dx,%edx
c010135e:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c0101362:	88 45 e5             	mov    %al,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101365:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101369:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c010136d:	ee                   	out    %al,(%dx)
}
c010136e:	90                   	nop
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c010136f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0101372:	c0 e0 04             	shl    $0x4,%al
c0101375:	24 10                	and    $0x10,%al
c0101377:	88 c2                	mov    %al,%dl
c0101379:	8b 45 0c             	mov    0xc(%ebp),%eax
c010137c:	c1 e8 18             	shr    $0x18,%eax
c010137f:	24 0f                	and    $0xf,%al
c0101381:	08 d0                	or     %dl,%al
c0101383:	0c e0                	or     $0xe0,%al
c0101385:	0f b6 c0             	movzbl %al,%eax
c0101388:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010138c:	83 c2 06             	add    $0x6,%edx
c010138f:	0f b7 d2             	movzwl %dx,%edx
c0101392:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0101396:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101399:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c010139d:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01013a1:	ee                   	out    %al,(%dx)
}
c01013a2:	90                   	nop
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);
c01013a3:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01013a7:	83 c0 07             	add    $0x7,%eax
c01013aa:	0f b7 c0             	movzwl %ax,%eax
c01013ad:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c01013b1:	c6 45 ed 20          	movb   $0x20,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01013b5:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01013b9:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01013bd:	ee                   	out    %al,(%dx)
}
c01013be:	90                   	nop

    int ret = 0;
c01013bf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c01013c6:	eb 58                	jmp    c0101420 <ide_read_secs+0x232>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c01013c8:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01013cc:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01013d3:	00 
c01013d4:	89 04 24             	mov    %eax,(%esp)
c01013d7:	e8 2d fa ff ff       	call   c0100e09 <ide_wait_ready>
c01013dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01013df:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01013e3:	75 43                	jne    c0101428 <ide_read_secs+0x23a>
            goto out;
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
c01013e5:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01013e9:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01013ec:	8b 45 10             	mov    0x10(%ebp),%eax
c01013ef:	89 45 cc             	mov    %eax,-0x34(%ebp)
c01013f2:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    asm volatile (
c01013f9:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01013fc:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c01013ff:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0101402:	89 cb                	mov    %ecx,%ebx
c0101404:	89 df                	mov    %ebx,%edi
c0101406:	89 c1                	mov    %eax,%ecx
c0101408:	fc                   	cld    
c0101409:	f2 6d                	repnz insl (%dx),%es:(%edi)
c010140b:	89 c8                	mov    %ecx,%eax
c010140d:	89 fb                	mov    %edi,%ebx
c010140f:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c0101412:	89 45 c8             	mov    %eax,-0x38(%ebp)
}
c0101415:	90                   	nop
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0101416:	ff 4d 14             	decl   0x14(%ebp)
c0101419:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c0101420:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0101424:	75 a2                	jne    c01013c8 <ide_read_secs+0x1da>
    }

out:
c0101426:	eb 01                	jmp    c0101429 <ide_read_secs+0x23b>
            goto out;
c0101428:	90                   	nop
    return ret;
c0101429:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010142c:	83 c4 50             	add    $0x50,%esp
c010142f:	5b                   	pop    %ebx
c0101430:	5f                   	pop    %edi
c0101431:	5d                   	pop    %ebp
c0101432:	c3                   	ret    

c0101433 <ide_write_secs>:

int
ide_write_secs(unsigned short ideno, uint32_t secno, const void *src, size_t nsecs) {
c0101433:	f3 0f 1e fb          	endbr32 
c0101437:	55                   	push   %ebp
c0101438:	89 e5                	mov    %esp,%ebp
c010143a:	56                   	push   %esi
c010143b:	53                   	push   %ebx
c010143c:	83 ec 50             	sub    $0x50,%esp
c010143f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101442:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c0101446:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c010144d:	77 23                	ja     c0101472 <ide_write_secs+0x3f>
c010144f:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101453:	83 f8 03             	cmp    $0x3,%eax
c0101456:	77 1a                	ja     c0101472 <ide_write_secs+0x3f>
c0101458:	0f b7 55 c4          	movzwl -0x3c(%ebp),%edx
c010145c:	89 d0                	mov    %edx,%eax
c010145e:	c1 e0 03             	shl    $0x3,%eax
c0101461:	29 d0                	sub    %edx,%eax
c0101463:	c1 e0 03             	shl    $0x3,%eax
c0101466:	05 40 b4 12 c0       	add    $0xc012b440,%eax
c010146b:	0f b6 00             	movzbl (%eax),%eax
c010146e:	84 c0                	test   %al,%al
c0101470:	75 24                	jne    c0101496 <ide_write_secs+0x63>
c0101472:	c7 44 24 0c a4 a3 10 	movl   $0xc010a3a4,0xc(%esp)
c0101479:	c0 
c010147a:	c7 44 24 08 5f a3 10 	movl   $0xc010a35f,0x8(%esp)
c0101481:	c0 
c0101482:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
c0101489:	00 
c010148a:	c7 04 24 74 a3 10 c0 	movl   $0xc010a374,(%esp)
c0101491:	e8 a7 ef ff ff       	call   c010043d <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0101496:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c010149d:	77 0f                	ja     c01014ae <ide_write_secs+0x7b>
c010149f:	8b 55 0c             	mov    0xc(%ebp),%edx
c01014a2:	8b 45 14             	mov    0x14(%ebp),%eax
c01014a5:	01 d0                	add    %edx,%eax
c01014a7:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c01014ac:	76 24                	jbe    c01014d2 <ide_write_secs+0x9f>
c01014ae:	c7 44 24 0c cc a3 10 	movl   $0xc010a3cc,0xc(%esp)
c01014b5:	c0 
c01014b6:	c7 44 24 08 5f a3 10 	movl   $0xc010a35f,0x8(%esp)
c01014bd:	c0 
c01014be:	c7 44 24 04 bd 00 00 	movl   $0xbd,0x4(%esp)
c01014c5:	00 
c01014c6:	c7 04 24 74 a3 10 c0 	movl   $0xc010a374,(%esp)
c01014cd:	e8 6b ef ff ff       	call   c010043d <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c01014d2:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c01014d6:	d1 e8                	shr    %eax
c01014d8:	0f b7 c0             	movzwl %ax,%eax
c01014db:	8b 04 85 14 a3 10 c0 	mov    -0x3fef5cec(,%eax,4),%eax
c01014e2:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c01014e6:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c01014ea:	d1 e8                	shr    %eax
c01014ec:	0f b7 c0             	movzwl %ax,%eax
c01014ef:	0f b7 04 85 16 a3 10 	movzwl -0x3fef5cea(,%eax,4),%eax
c01014f6:	c0 
c01014f7:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c01014fb:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01014ff:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101506:	00 
c0101507:	89 04 24             	mov    %eax,(%esp)
c010150a:	e8 fa f8 ff ff       	call   c0100e09 <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c010150f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101512:	83 c0 02             	add    $0x2,%eax
c0101515:	0f b7 c0             	movzwl %ax,%eax
c0101518:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c010151c:	c6 45 d5 00          	movb   $0x0,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101520:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101524:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101528:	ee                   	out    %al,(%dx)
}
c0101529:	90                   	nop
    outb(iobase + ISA_SECCNT, nsecs);
c010152a:	8b 45 14             	mov    0x14(%ebp),%eax
c010152d:	0f b6 c0             	movzbl %al,%eax
c0101530:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101534:	83 c2 02             	add    $0x2,%edx
c0101537:	0f b7 d2             	movzwl %dx,%edx
c010153a:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c010153e:	88 45 d9             	mov    %al,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101541:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101545:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101549:	ee                   	out    %al,(%dx)
}
c010154a:	90                   	nop
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c010154b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010154e:	0f b6 c0             	movzbl %al,%eax
c0101551:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101555:	83 c2 03             	add    $0x3,%edx
c0101558:	0f b7 d2             	movzwl %dx,%edx
c010155b:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c010155f:	88 45 dd             	mov    %al,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101562:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101566:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c010156a:	ee                   	out    %al,(%dx)
}
c010156b:	90                   	nop
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c010156c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010156f:	c1 e8 08             	shr    $0x8,%eax
c0101572:	0f b6 c0             	movzbl %al,%eax
c0101575:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101579:	83 c2 04             	add    $0x4,%edx
c010157c:	0f b7 d2             	movzwl %dx,%edx
c010157f:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0101583:	88 45 e1             	mov    %al,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101586:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c010158a:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c010158e:	ee                   	out    %al,(%dx)
}
c010158f:	90                   	nop
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c0101590:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101593:	c1 e8 10             	shr    $0x10,%eax
c0101596:	0f b6 c0             	movzbl %al,%eax
c0101599:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010159d:	83 c2 05             	add    $0x5,%edx
c01015a0:	0f b7 d2             	movzwl %dx,%edx
c01015a3:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c01015a7:	88 45 e5             	mov    %al,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01015aa:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01015ae:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01015b2:	ee                   	out    %al,(%dx)
}
c01015b3:	90                   	nop
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c01015b4:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01015b7:	c0 e0 04             	shl    $0x4,%al
c01015ba:	24 10                	and    $0x10,%al
c01015bc:	88 c2                	mov    %al,%dl
c01015be:	8b 45 0c             	mov    0xc(%ebp),%eax
c01015c1:	c1 e8 18             	shr    $0x18,%eax
c01015c4:	24 0f                	and    $0xf,%al
c01015c6:	08 d0                	or     %dl,%al
c01015c8:	0c e0                	or     $0xe0,%al
c01015ca:	0f b6 c0             	movzbl %al,%eax
c01015cd:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01015d1:	83 c2 06             	add    $0x6,%edx
c01015d4:	0f b7 d2             	movzwl %dx,%edx
c01015d7:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c01015db:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01015de:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01015e2:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01015e6:	ee                   	out    %al,(%dx)
}
c01015e7:	90                   	nop
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);
c01015e8:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01015ec:	83 c0 07             	add    $0x7,%eax
c01015ef:	0f b7 c0             	movzwl %ax,%eax
c01015f2:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c01015f6:	c6 45 ed 30          	movb   $0x30,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01015fa:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01015fe:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101602:	ee                   	out    %al,(%dx)
}
c0101603:	90                   	nop

    int ret = 0;
c0101604:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c010160b:	eb 58                	jmp    c0101665 <ide_write_secs+0x232>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c010160d:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101611:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0101618:	00 
c0101619:	89 04 24             	mov    %eax,(%esp)
c010161c:	e8 e8 f7 ff ff       	call   c0100e09 <ide_wait_ready>
c0101621:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101624:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101628:	75 43                	jne    c010166d <ide_write_secs+0x23a>
            goto out;
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
c010162a:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010162e:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0101631:	8b 45 10             	mov    0x10(%ebp),%eax
c0101634:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0101637:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    asm volatile (
c010163e:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0101641:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c0101644:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0101647:	89 cb                	mov    %ecx,%ebx
c0101649:	89 de                	mov    %ebx,%esi
c010164b:	89 c1                	mov    %eax,%ecx
c010164d:	fc                   	cld    
c010164e:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
c0101650:	89 c8                	mov    %ecx,%eax
c0101652:	89 f3                	mov    %esi,%ebx
c0101654:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c0101657:	89 45 c8             	mov    %eax,-0x38(%ebp)
}
c010165a:	90                   	nop
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c010165b:	ff 4d 14             	decl   0x14(%ebp)
c010165e:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c0101665:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0101669:	75 a2                	jne    c010160d <ide_write_secs+0x1da>
    }

out:
c010166b:	eb 01                	jmp    c010166e <ide_write_secs+0x23b>
            goto out;
c010166d:	90                   	nop
    return ret;
c010166e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101671:	83 c4 50             	add    $0x50,%esp
c0101674:	5b                   	pop    %ebx
c0101675:	5e                   	pop    %esi
c0101676:	5d                   	pop    %ebp
c0101677:	c3                   	ret    

c0101678 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0101678:	f3 0f 1e fb          	endbr32 
c010167c:	55                   	push   %ebp
c010167d:	89 e5                	mov    %esp,%ebp
c010167f:	83 ec 28             	sub    $0x28,%esp
c0101682:	66 c7 45 ee 43 00    	movw   $0x43,-0x12(%ebp)
c0101688:	c6 45 ed 34          	movb   $0x34,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010168c:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101690:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101694:	ee                   	out    %al,(%dx)
}
c0101695:	90                   	nop
c0101696:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c010169c:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01016a0:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01016a4:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01016a8:	ee                   	out    %al,(%dx)
}
c01016a9:	90                   	nop
c01016aa:	66 c7 45 f6 40 00    	movw   $0x40,-0xa(%ebp)
c01016b0:	c6 45 f5 2e          	movb   $0x2e,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01016b4:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c01016b8:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01016bc:	ee                   	out    %al,(%dx)
}
c01016bd:	90                   	nop
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c01016be:	c7 05 54 e0 12 c0 00 	movl   $0x0,0xc012e054
c01016c5:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c01016c8:	c7 04 24 06 a4 10 c0 	movl   $0xc010a406,(%esp)
c01016cf:	e8 fd eb ff ff       	call   c01002d1 <cprintf>
    pic_enable(IRQ_TIMER);
c01016d4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01016db:	e8 95 09 00 00       	call   c0102075 <pic_enable>
}
c01016e0:	90                   	nop
c01016e1:	c9                   	leave  
c01016e2:	c3                   	ret    

c01016e3 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c01016e3:	55                   	push   %ebp
c01016e4:	89 e5                	mov    %esp,%ebp
c01016e6:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c01016e9:	9c                   	pushf  
c01016ea:	58                   	pop    %eax
c01016eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c01016ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c01016f1:	25 00 02 00 00       	and    $0x200,%eax
c01016f6:	85 c0                	test   %eax,%eax
c01016f8:	74 0c                	je     c0101706 <__intr_save+0x23>
        intr_disable();
c01016fa:	e8 05 0b 00 00       	call   c0102204 <intr_disable>
        return 1;
c01016ff:	b8 01 00 00 00       	mov    $0x1,%eax
c0101704:	eb 05                	jmp    c010170b <__intr_save+0x28>
    }
    return 0;
c0101706:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010170b:	c9                   	leave  
c010170c:	c3                   	ret    

c010170d <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c010170d:	55                   	push   %ebp
c010170e:	89 e5                	mov    %esp,%ebp
c0101710:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0101713:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0101717:	74 05                	je     c010171e <__intr_restore+0x11>
        intr_enable();
c0101719:	e8 da 0a 00 00       	call   c01021f8 <intr_enable>
    }
}
c010171e:	90                   	nop
c010171f:	c9                   	leave  
c0101720:	c3                   	ret    

c0101721 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0101721:	f3 0f 1e fb          	endbr32 
c0101725:	55                   	push   %ebp
c0101726:	89 e5                	mov    %esp,%ebp
c0101728:	83 ec 10             	sub    $0x10,%esp
c010172b:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101731:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101735:	89 c2                	mov    %eax,%edx
c0101737:	ec                   	in     (%dx),%al
c0101738:	88 45 f1             	mov    %al,-0xf(%ebp)
c010173b:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c0101741:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101745:	89 c2                	mov    %eax,%edx
c0101747:	ec                   	in     (%dx),%al
c0101748:	88 45 f5             	mov    %al,-0xb(%ebp)
c010174b:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0101751:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101755:	89 c2                	mov    %eax,%edx
c0101757:	ec                   	in     (%dx),%al
c0101758:	88 45 f9             	mov    %al,-0x7(%ebp)
c010175b:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
c0101761:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0101765:	89 c2                	mov    %eax,%edx
c0101767:	ec                   	in     (%dx),%al
c0101768:	88 45 fd             	mov    %al,-0x3(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c010176b:	90                   	nop
c010176c:	c9                   	leave  
c010176d:	c3                   	ret    

c010176e <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c010176e:	f3 0f 1e fb          	endbr32 
c0101772:	55                   	push   %ebp
c0101773:	89 e5                	mov    %esp,%ebp
c0101775:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0101778:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c010177f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101782:	0f b7 00             	movzwl (%eax),%eax
c0101785:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0101789:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010178c:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0101791:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101794:	0f b7 00             	movzwl (%eax),%eax
c0101797:	0f b7 c0             	movzwl %ax,%eax
c010179a:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
c010179f:	74 12                	je     c01017b3 <cga_init+0x45>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c01017a1:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c01017a8:	66 c7 05 26 b5 12 c0 	movw   $0x3b4,0xc012b526
c01017af:	b4 03 
c01017b1:	eb 13                	jmp    c01017c6 <cga_init+0x58>
    } else {
        *cp = was;
c01017b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01017b6:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c01017ba:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c01017bd:	66 c7 05 26 b5 12 c0 	movw   $0x3d4,0xc012b526
c01017c4:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c01017c6:	0f b7 05 26 b5 12 c0 	movzwl 0xc012b526,%eax
c01017cd:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c01017d1:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01017d5:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01017d9:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01017dd:	ee                   	out    %al,(%dx)
}
c01017de:	90                   	nop
    pos = inb(addr_6845 + 1) << 8;
c01017df:	0f b7 05 26 b5 12 c0 	movzwl 0xc012b526,%eax
c01017e6:	40                   	inc    %eax
c01017e7:	0f b7 c0             	movzwl %ax,%eax
c01017ea:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01017ee:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01017f2:	89 c2                	mov    %eax,%edx
c01017f4:	ec                   	in     (%dx),%al
c01017f5:	88 45 e9             	mov    %al,-0x17(%ebp)
    return data;
c01017f8:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01017fc:	0f b6 c0             	movzbl %al,%eax
c01017ff:	c1 e0 08             	shl    $0x8,%eax
c0101802:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0101805:	0f b7 05 26 b5 12 c0 	movzwl 0xc012b526,%eax
c010180c:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101810:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101814:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101818:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c010181c:	ee                   	out    %al,(%dx)
}
c010181d:	90                   	nop
    pos |= inb(addr_6845 + 1);
c010181e:	0f b7 05 26 b5 12 c0 	movzwl 0xc012b526,%eax
c0101825:	40                   	inc    %eax
c0101826:	0f b7 c0             	movzwl %ax,%eax
c0101829:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010182d:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101831:	89 c2                	mov    %eax,%edx
c0101833:	ec                   	in     (%dx),%al
c0101834:	88 45 f1             	mov    %al,-0xf(%ebp)
    return data;
c0101837:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010183b:	0f b6 c0             	movzbl %al,%eax
c010183e:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c0101841:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101844:	a3 20 b5 12 c0       	mov    %eax,0xc012b520
    crt_pos = pos;
c0101849:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010184c:	0f b7 c0             	movzwl %ax,%eax
c010184f:	66 a3 24 b5 12 c0    	mov    %ax,0xc012b524
}
c0101855:	90                   	nop
c0101856:	c9                   	leave  
c0101857:	c3                   	ret    

c0101858 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c0101858:	f3 0f 1e fb          	endbr32 
c010185c:	55                   	push   %ebp
c010185d:	89 e5                	mov    %esp,%ebp
c010185f:	83 ec 48             	sub    $0x48,%esp
c0101862:	66 c7 45 d2 fa 03    	movw   $0x3fa,-0x2e(%ebp)
c0101868:	c6 45 d1 00          	movb   $0x0,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010186c:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0101870:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c0101874:	ee                   	out    %al,(%dx)
}
c0101875:	90                   	nop
c0101876:	66 c7 45 d6 fb 03    	movw   $0x3fb,-0x2a(%ebp)
c010187c:	c6 45 d5 80          	movb   $0x80,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101880:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101884:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101888:	ee                   	out    %al,(%dx)
}
c0101889:	90                   	nop
c010188a:	66 c7 45 da f8 03    	movw   $0x3f8,-0x26(%ebp)
c0101890:	c6 45 d9 0c          	movb   $0xc,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101894:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101898:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c010189c:	ee                   	out    %al,(%dx)
}
c010189d:	90                   	nop
c010189e:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c01018a4:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018a8:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c01018ac:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c01018b0:	ee                   	out    %al,(%dx)
}
c01018b1:	90                   	nop
c01018b2:	66 c7 45 e2 fb 03    	movw   $0x3fb,-0x1e(%ebp)
c01018b8:	c6 45 e1 03          	movb   $0x3,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018bc:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c01018c0:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c01018c4:	ee                   	out    %al,(%dx)
}
c01018c5:	90                   	nop
c01018c6:	66 c7 45 e6 fc 03    	movw   $0x3fc,-0x1a(%ebp)
c01018cc:	c6 45 e5 00          	movb   $0x0,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018d0:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01018d4:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01018d8:	ee                   	out    %al,(%dx)
}
c01018d9:	90                   	nop
c01018da:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c01018e0:	c6 45 e9 01          	movb   $0x1,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018e4:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01018e8:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01018ec:	ee                   	out    %al,(%dx)
}
c01018ed:	90                   	nop
c01018ee:	66 c7 45 ee fd 03    	movw   $0x3fd,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01018f4:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c01018f8:	89 c2                	mov    %eax,%edx
c01018fa:	ec                   	in     (%dx),%al
c01018fb:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c01018fe:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c0101902:	3c ff                	cmp    $0xff,%al
c0101904:	0f 95 c0             	setne  %al
c0101907:	0f b6 c0             	movzbl %al,%eax
c010190a:	a3 28 b5 12 c0       	mov    %eax,0xc012b528
c010190f:	66 c7 45 f2 fa 03    	movw   $0x3fa,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101915:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101919:	89 c2                	mov    %eax,%edx
c010191b:	ec                   	in     (%dx),%al
c010191c:	88 45 f1             	mov    %al,-0xf(%ebp)
c010191f:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c0101925:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101929:	89 c2                	mov    %eax,%edx
c010192b:	ec                   	in     (%dx),%al
c010192c:	88 45 f5             	mov    %al,-0xb(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c010192f:	a1 28 b5 12 c0       	mov    0xc012b528,%eax
c0101934:	85 c0                	test   %eax,%eax
c0101936:	74 0c                	je     c0101944 <serial_init+0xec>
        pic_enable(IRQ_COM1);
c0101938:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c010193f:	e8 31 07 00 00       	call   c0102075 <pic_enable>
    }
}
c0101944:	90                   	nop
c0101945:	c9                   	leave  
c0101946:	c3                   	ret    

c0101947 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c0101947:	f3 0f 1e fb          	endbr32 
c010194b:	55                   	push   %ebp
c010194c:	89 e5                	mov    %esp,%ebp
c010194e:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0101951:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101958:	eb 08                	jmp    c0101962 <lpt_putc_sub+0x1b>
        delay();
c010195a:	e8 c2 fd ff ff       	call   c0101721 <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c010195f:	ff 45 fc             	incl   -0x4(%ebp)
c0101962:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c0101968:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c010196c:	89 c2                	mov    %eax,%edx
c010196e:	ec                   	in     (%dx),%al
c010196f:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101972:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101976:	84 c0                	test   %al,%al
c0101978:	78 09                	js     c0101983 <lpt_putc_sub+0x3c>
c010197a:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101981:	7e d7                	jle    c010195a <lpt_putc_sub+0x13>
    }
    outb(LPTPORT + 0, c);
c0101983:	8b 45 08             	mov    0x8(%ebp),%eax
c0101986:	0f b6 c0             	movzbl %al,%eax
c0101989:	66 c7 45 ee 78 03    	movw   $0x378,-0x12(%ebp)
c010198f:	88 45 ed             	mov    %al,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101992:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101996:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c010199a:	ee                   	out    %al,(%dx)
}
c010199b:	90                   	nop
c010199c:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c01019a2:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01019a6:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01019aa:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01019ae:	ee                   	out    %al,(%dx)
}
c01019af:	90                   	nop
c01019b0:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
c01019b6:	c6 45 f5 08          	movb   $0x8,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01019ba:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c01019be:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01019c2:	ee                   	out    %al,(%dx)
}
c01019c3:	90                   	nop
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c01019c4:	90                   	nop
c01019c5:	c9                   	leave  
c01019c6:	c3                   	ret    

c01019c7 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c01019c7:	f3 0f 1e fb          	endbr32 
c01019cb:	55                   	push   %ebp
c01019cc:	89 e5                	mov    %esp,%ebp
c01019ce:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c01019d1:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c01019d5:	74 0d                	je     c01019e4 <lpt_putc+0x1d>
        lpt_putc_sub(c);
c01019d7:	8b 45 08             	mov    0x8(%ebp),%eax
c01019da:	89 04 24             	mov    %eax,(%esp)
c01019dd:	e8 65 ff ff ff       	call   c0101947 <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
c01019e2:	eb 24                	jmp    c0101a08 <lpt_putc+0x41>
        lpt_putc_sub('\b');
c01019e4:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01019eb:	e8 57 ff ff ff       	call   c0101947 <lpt_putc_sub>
        lpt_putc_sub(' ');
c01019f0:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c01019f7:	e8 4b ff ff ff       	call   c0101947 <lpt_putc_sub>
        lpt_putc_sub('\b');
c01019fc:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101a03:	e8 3f ff ff ff       	call   c0101947 <lpt_putc_sub>
}
c0101a08:	90                   	nop
c0101a09:	c9                   	leave  
c0101a0a:	c3                   	ret    

c0101a0b <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c0101a0b:	f3 0f 1e fb          	endbr32 
c0101a0f:	55                   	push   %ebp
c0101a10:	89 e5                	mov    %esp,%ebp
c0101a12:	53                   	push   %ebx
c0101a13:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c0101a16:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a19:	25 00 ff ff ff       	and    $0xffffff00,%eax
c0101a1e:	85 c0                	test   %eax,%eax
c0101a20:	75 07                	jne    c0101a29 <cga_putc+0x1e>
        c |= 0x0700;
c0101a22:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c0101a29:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a2c:	0f b6 c0             	movzbl %al,%eax
c0101a2f:	83 f8 0d             	cmp    $0xd,%eax
c0101a32:	74 72                	je     c0101aa6 <cga_putc+0x9b>
c0101a34:	83 f8 0d             	cmp    $0xd,%eax
c0101a37:	0f 8f a3 00 00 00    	jg     c0101ae0 <cga_putc+0xd5>
c0101a3d:	83 f8 08             	cmp    $0x8,%eax
c0101a40:	74 0a                	je     c0101a4c <cga_putc+0x41>
c0101a42:	83 f8 0a             	cmp    $0xa,%eax
c0101a45:	74 4c                	je     c0101a93 <cga_putc+0x88>
c0101a47:	e9 94 00 00 00       	jmp    c0101ae0 <cga_putc+0xd5>
    case '\b':
        if (crt_pos > 0) {
c0101a4c:	0f b7 05 24 b5 12 c0 	movzwl 0xc012b524,%eax
c0101a53:	85 c0                	test   %eax,%eax
c0101a55:	0f 84 af 00 00 00    	je     c0101b0a <cga_putc+0xff>
            crt_pos --;
c0101a5b:	0f b7 05 24 b5 12 c0 	movzwl 0xc012b524,%eax
c0101a62:	48                   	dec    %eax
c0101a63:	0f b7 c0             	movzwl %ax,%eax
c0101a66:	66 a3 24 b5 12 c0    	mov    %ax,0xc012b524
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c0101a6c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a6f:	98                   	cwtl   
c0101a70:	25 00 ff ff ff       	and    $0xffffff00,%eax
c0101a75:	98                   	cwtl   
c0101a76:	83 c8 20             	or     $0x20,%eax
c0101a79:	98                   	cwtl   
c0101a7a:	8b 15 20 b5 12 c0    	mov    0xc012b520,%edx
c0101a80:	0f b7 0d 24 b5 12 c0 	movzwl 0xc012b524,%ecx
c0101a87:	01 c9                	add    %ecx,%ecx
c0101a89:	01 ca                	add    %ecx,%edx
c0101a8b:	0f b7 c0             	movzwl %ax,%eax
c0101a8e:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c0101a91:	eb 77                	jmp    c0101b0a <cga_putc+0xff>
    case '\n':
        crt_pos += CRT_COLS;
c0101a93:	0f b7 05 24 b5 12 c0 	movzwl 0xc012b524,%eax
c0101a9a:	83 c0 50             	add    $0x50,%eax
c0101a9d:	0f b7 c0             	movzwl %ax,%eax
c0101aa0:	66 a3 24 b5 12 c0    	mov    %ax,0xc012b524
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c0101aa6:	0f b7 1d 24 b5 12 c0 	movzwl 0xc012b524,%ebx
c0101aad:	0f b7 0d 24 b5 12 c0 	movzwl 0xc012b524,%ecx
c0101ab4:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
c0101ab9:	89 c8                	mov    %ecx,%eax
c0101abb:	f7 e2                	mul    %edx
c0101abd:	c1 ea 06             	shr    $0x6,%edx
c0101ac0:	89 d0                	mov    %edx,%eax
c0101ac2:	c1 e0 02             	shl    $0x2,%eax
c0101ac5:	01 d0                	add    %edx,%eax
c0101ac7:	c1 e0 04             	shl    $0x4,%eax
c0101aca:	29 c1                	sub    %eax,%ecx
c0101acc:	89 c8                	mov    %ecx,%eax
c0101ace:	0f b7 c0             	movzwl %ax,%eax
c0101ad1:	29 c3                	sub    %eax,%ebx
c0101ad3:	89 d8                	mov    %ebx,%eax
c0101ad5:	0f b7 c0             	movzwl %ax,%eax
c0101ad8:	66 a3 24 b5 12 c0    	mov    %ax,0xc012b524
        break;
c0101ade:	eb 2b                	jmp    c0101b0b <cga_putc+0x100>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c0101ae0:	8b 0d 20 b5 12 c0    	mov    0xc012b520,%ecx
c0101ae6:	0f b7 05 24 b5 12 c0 	movzwl 0xc012b524,%eax
c0101aed:	8d 50 01             	lea    0x1(%eax),%edx
c0101af0:	0f b7 d2             	movzwl %dx,%edx
c0101af3:	66 89 15 24 b5 12 c0 	mov    %dx,0xc012b524
c0101afa:	01 c0                	add    %eax,%eax
c0101afc:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c0101aff:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b02:	0f b7 c0             	movzwl %ax,%eax
c0101b05:	66 89 02             	mov    %ax,(%edx)
        break;
c0101b08:	eb 01                	jmp    c0101b0b <cga_putc+0x100>
        break;
c0101b0a:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c0101b0b:	0f b7 05 24 b5 12 c0 	movzwl 0xc012b524,%eax
c0101b12:	3d cf 07 00 00       	cmp    $0x7cf,%eax
c0101b17:	76 5d                	jbe    c0101b76 <cga_putc+0x16b>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c0101b19:	a1 20 b5 12 c0       	mov    0xc012b520,%eax
c0101b1e:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c0101b24:	a1 20 b5 12 c0       	mov    0xc012b520,%eax
c0101b29:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c0101b30:	00 
c0101b31:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101b35:	89 04 24             	mov    %eax,(%esp)
c0101b38:	e8 c8 7b 00 00       	call   c0109705 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101b3d:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c0101b44:	eb 14                	jmp    c0101b5a <cga_putc+0x14f>
            crt_buf[i] = 0x0700 | ' ';
c0101b46:	a1 20 b5 12 c0       	mov    0xc012b520,%eax
c0101b4b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101b4e:	01 d2                	add    %edx,%edx
c0101b50:	01 d0                	add    %edx,%eax
c0101b52:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101b57:	ff 45 f4             	incl   -0xc(%ebp)
c0101b5a:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c0101b61:	7e e3                	jle    c0101b46 <cga_putc+0x13b>
        }
        crt_pos -= CRT_COLS;
c0101b63:	0f b7 05 24 b5 12 c0 	movzwl 0xc012b524,%eax
c0101b6a:	83 e8 50             	sub    $0x50,%eax
c0101b6d:	0f b7 c0             	movzwl %ax,%eax
c0101b70:	66 a3 24 b5 12 c0    	mov    %ax,0xc012b524
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c0101b76:	0f b7 05 26 b5 12 c0 	movzwl 0xc012b526,%eax
c0101b7d:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c0101b81:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101b85:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101b89:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101b8d:	ee                   	out    %al,(%dx)
}
c0101b8e:	90                   	nop
    outb(addr_6845 + 1, crt_pos >> 8);
c0101b8f:	0f b7 05 24 b5 12 c0 	movzwl 0xc012b524,%eax
c0101b96:	c1 e8 08             	shr    $0x8,%eax
c0101b99:	0f b7 c0             	movzwl %ax,%eax
c0101b9c:	0f b6 c0             	movzbl %al,%eax
c0101b9f:	0f b7 15 26 b5 12 c0 	movzwl 0xc012b526,%edx
c0101ba6:	42                   	inc    %edx
c0101ba7:	0f b7 d2             	movzwl %dx,%edx
c0101baa:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0101bae:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101bb1:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101bb5:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101bb9:	ee                   	out    %al,(%dx)
}
c0101bba:	90                   	nop
    outb(addr_6845, 15);
c0101bbb:	0f b7 05 26 b5 12 c0 	movzwl 0xc012b526,%eax
c0101bc2:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101bc6:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101bca:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101bce:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101bd2:	ee                   	out    %al,(%dx)
}
c0101bd3:	90                   	nop
    outb(addr_6845 + 1, crt_pos);
c0101bd4:	0f b7 05 24 b5 12 c0 	movzwl 0xc012b524,%eax
c0101bdb:	0f b6 c0             	movzbl %al,%eax
c0101bde:	0f b7 15 26 b5 12 c0 	movzwl 0xc012b526,%edx
c0101be5:	42                   	inc    %edx
c0101be6:	0f b7 d2             	movzwl %dx,%edx
c0101be9:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
c0101bed:	88 45 f1             	mov    %al,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101bf0:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101bf4:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101bf8:	ee                   	out    %al,(%dx)
}
c0101bf9:	90                   	nop
}
c0101bfa:	90                   	nop
c0101bfb:	83 c4 34             	add    $0x34,%esp
c0101bfe:	5b                   	pop    %ebx
c0101bff:	5d                   	pop    %ebp
c0101c00:	c3                   	ret    

c0101c01 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c0101c01:	f3 0f 1e fb          	endbr32 
c0101c05:	55                   	push   %ebp
c0101c06:	89 e5                	mov    %esp,%ebp
c0101c08:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101c0b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101c12:	eb 08                	jmp    c0101c1c <serial_putc_sub+0x1b>
        delay();
c0101c14:	e8 08 fb ff ff       	call   c0101721 <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101c19:	ff 45 fc             	incl   -0x4(%ebp)
c0101c1c:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101c22:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101c26:	89 c2                	mov    %eax,%edx
c0101c28:	ec                   	in     (%dx),%al
c0101c29:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101c2c:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101c30:	0f b6 c0             	movzbl %al,%eax
c0101c33:	83 e0 20             	and    $0x20,%eax
c0101c36:	85 c0                	test   %eax,%eax
c0101c38:	75 09                	jne    c0101c43 <serial_putc_sub+0x42>
c0101c3a:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101c41:	7e d1                	jle    c0101c14 <serial_putc_sub+0x13>
    }
    outb(COM1 + COM_TX, c);
c0101c43:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c46:	0f b6 c0             	movzbl %al,%eax
c0101c49:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c0101c4f:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101c52:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101c56:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101c5a:	ee                   	out    %al,(%dx)
}
c0101c5b:	90                   	nop
}
c0101c5c:	90                   	nop
c0101c5d:	c9                   	leave  
c0101c5e:	c3                   	ret    

c0101c5f <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c0101c5f:	f3 0f 1e fb          	endbr32 
c0101c63:	55                   	push   %ebp
c0101c64:	89 e5                	mov    %esp,%ebp
c0101c66:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c0101c69:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101c6d:	74 0d                	je     c0101c7c <serial_putc+0x1d>
        serial_putc_sub(c);
c0101c6f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c72:	89 04 24             	mov    %eax,(%esp)
c0101c75:	e8 87 ff ff ff       	call   c0101c01 <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
c0101c7a:	eb 24                	jmp    c0101ca0 <serial_putc+0x41>
        serial_putc_sub('\b');
c0101c7c:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101c83:	e8 79 ff ff ff       	call   c0101c01 <serial_putc_sub>
        serial_putc_sub(' ');
c0101c88:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101c8f:	e8 6d ff ff ff       	call   c0101c01 <serial_putc_sub>
        serial_putc_sub('\b');
c0101c94:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101c9b:	e8 61 ff ff ff       	call   c0101c01 <serial_putc_sub>
}
c0101ca0:	90                   	nop
c0101ca1:	c9                   	leave  
c0101ca2:	c3                   	ret    

c0101ca3 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c0101ca3:	f3 0f 1e fb          	endbr32 
c0101ca7:	55                   	push   %ebp
c0101ca8:	89 e5                	mov    %esp,%ebp
c0101caa:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c0101cad:	eb 33                	jmp    c0101ce2 <cons_intr+0x3f>
        if (c != 0) {
c0101caf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101cb3:	74 2d                	je     c0101ce2 <cons_intr+0x3f>
            cons.buf[cons.wpos ++] = c;
c0101cb5:	a1 44 b7 12 c0       	mov    0xc012b744,%eax
c0101cba:	8d 50 01             	lea    0x1(%eax),%edx
c0101cbd:	89 15 44 b7 12 c0    	mov    %edx,0xc012b744
c0101cc3:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101cc6:	88 90 40 b5 12 c0    	mov    %dl,-0x3fed4ac0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c0101ccc:	a1 44 b7 12 c0       	mov    0xc012b744,%eax
c0101cd1:	3d 00 02 00 00       	cmp    $0x200,%eax
c0101cd6:	75 0a                	jne    c0101ce2 <cons_intr+0x3f>
                cons.wpos = 0;
c0101cd8:	c7 05 44 b7 12 c0 00 	movl   $0x0,0xc012b744
c0101cdf:	00 00 00 
    while ((c = (*proc)()) != -1) {
c0101ce2:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ce5:	ff d0                	call   *%eax
c0101ce7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101cea:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c0101cee:	75 bf                	jne    c0101caf <cons_intr+0xc>
            }
        }
    }
}
c0101cf0:	90                   	nop
c0101cf1:	90                   	nop
c0101cf2:	c9                   	leave  
c0101cf3:	c3                   	ret    

c0101cf4 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c0101cf4:	f3 0f 1e fb          	endbr32 
c0101cf8:	55                   	push   %ebp
c0101cf9:	89 e5                	mov    %esp,%ebp
c0101cfb:	83 ec 10             	sub    $0x10,%esp
c0101cfe:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101d04:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101d08:	89 c2                	mov    %eax,%edx
c0101d0a:	ec                   	in     (%dx),%al
c0101d0b:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101d0e:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c0101d12:	0f b6 c0             	movzbl %al,%eax
c0101d15:	83 e0 01             	and    $0x1,%eax
c0101d18:	85 c0                	test   %eax,%eax
c0101d1a:	75 07                	jne    c0101d23 <serial_proc_data+0x2f>
        return -1;
c0101d1c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101d21:	eb 2a                	jmp    c0101d4d <serial_proc_data+0x59>
c0101d23:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101d29:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101d2d:	89 c2                	mov    %eax,%edx
c0101d2f:	ec                   	in     (%dx),%al
c0101d30:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c0101d33:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c0101d37:	0f b6 c0             	movzbl %al,%eax
c0101d3a:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c0101d3d:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c0101d41:	75 07                	jne    c0101d4a <serial_proc_data+0x56>
        c = '\b';
c0101d43:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c0101d4a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0101d4d:	c9                   	leave  
c0101d4e:	c3                   	ret    

c0101d4f <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c0101d4f:	f3 0f 1e fb          	endbr32 
c0101d53:	55                   	push   %ebp
c0101d54:	89 e5                	mov    %esp,%ebp
c0101d56:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c0101d59:	a1 28 b5 12 c0       	mov    0xc012b528,%eax
c0101d5e:	85 c0                	test   %eax,%eax
c0101d60:	74 0c                	je     c0101d6e <serial_intr+0x1f>
        cons_intr(serial_proc_data);
c0101d62:	c7 04 24 f4 1c 10 c0 	movl   $0xc0101cf4,(%esp)
c0101d69:	e8 35 ff ff ff       	call   c0101ca3 <cons_intr>
    }
}
c0101d6e:	90                   	nop
c0101d6f:	c9                   	leave  
c0101d70:	c3                   	ret    

c0101d71 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c0101d71:	f3 0f 1e fb          	endbr32 
c0101d75:	55                   	push   %ebp
c0101d76:	89 e5                	mov    %esp,%ebp
c0101d78:	83 ec 38             	sub    $0x38,%esp
c0101d7b:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101d81:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101d84:	89 c2                	mov    %eax,%edx
c0101d86:	ec                   	in     (%dx),%al
c0101d87:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c0101d8a:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c0101d8e:	0f b6 c0             	movzbl %al,%eax
c0101d91:	83 e0 01             	and    $0x1,%eax
c0101d94:	85 c0                	test   %eax,%eax
c0101d96:	75 0a                	jne    c0101da2 <kbd_proc_data+0x31>
        return -1;
c0101d98:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101d9d:	e9 56 01 00 00       	jmp    c0101ef8 <kbd_proc_data+0x187>
c0101da2:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101da8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101dab:	89 c2                	mov    %eax,%edx
c0101dad:	ec                   	in     (%dx),%al
c0101dae:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c0101db1:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c0101db5:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c0101db8:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c0101dbc:	75 17                	jne    c0101dd5 <kbd_proc_data+0x64>
        // E0 escape character
        shift |= E0ESC;
c0101dbe:	a1 48 b7 12 c0       	mov    0xc012b748,%eax
c0101dc3:	83 c8 40             	or     $0x40,%eax
c0101dc6:	a3 48 b7 12 c0       	mov    %eax,0xc012b748
        return 0;
c0101dcb:	b8 00 00 00 00       	mov    $0x0,%eax
c0101dd0:	e9 23 01 00 00       	jmp    c0101ef8 <kbd_proc_data+0x187>
    } else if (data & 0x80) {
c0101dd5:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101dd9:	84 c0                	test   %al,%al
c0101ddb:	79 45                	jns    c0101e22 <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c0101ddd:	a1 48 b7 12 c0       	mov    0xc012b748,%eax
c0101de2:	83 e0 40             	and    $0x40,%eax
c0101de5:	85 c0                	test   %eax,%eax
c0101de7:	75 08                	jne    c0101df1 <kbd_proc_data+0x80>
c0101de9:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101ded:	24 7f                	and    $0x7f,%al
c0101def:	eb 04                	jmp    c0101df5 <kbd_proc_data+0x84>
c0101df1:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101df5:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c0101df8:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101dfc:	0f b6 80 40 80 12 c0 	movzbl -0x3fed7fc0(%eax),%eax
c0101e03:	0c 40                	or     $0x40,%al
c0101e05:	0f b6 c0             	movzbl %al,%eax
c0101e08:	f7 d0                	not    %eax
c0101e0a:	89 c2                	mov    %eax,%edx
c0101e0c:	a1 48 b7 12 c0       	mov    0xc012b748,%eax
c0101e11:	21 d0                	and    %edx,%eax
c0101e13:	a3 48 b7 12 c0       	mov    %eax,0xc012b748
        return 0;
c0101e18:	b8 00 00 00 00       	mov    $0x0,%eax
c0101e1d:	e9 d6 00 00 00       	jmp    c0101ef8 <kbd_proc_data+0x187>
    } else if (shift & E0ESC) {
c0101e22:	a1 48 b7 12 c0       	mov    0xc012b748,%eax
c0101e27:	83 e0 40             	and    $0x40,%eax
c0101e2a:	85 c0                	test   %eax,%eax
c0101e2c:	74 11                	je     c0101e3f <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c0101e2e:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c0101e32:	a1 48 b7 12 c0       	mov    0xc012b748,%eax
c0101e37:	83 e0 bf             	and    $0xffffffbf,%eax
c0101e3a:	a3 48 b7 12 c0       	mov    %eax,0xc012b748
    }

    shift |= shiftcode[data];
c0101e3f:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101e43:	0f b6 80 40 80 12 c0 	movzbl -0x3fed7fc0(%eax),%eax
c0101e4a:	0f b6 d0             	movzbl %al,%edx
c0101e4d:	a1 48 b7 12 c0       	mov    0xc012b748,%eax
c0101e52:	09 d0                	or     %edx,%eax
c0101e54:	a3 48 b7 12 c0       	mov    %eax,0xc012b748
    shift ^= togglecode[data];
c0101e59:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101e5d:	0f b6 80 40 81 12 c0 	movzbl -0x3fed7ec0(%eax),%eax
c0101e64:	0f b6 d0             	movzbl %al,%edx
c0101e67:	a1 48 b7 12 c0       	mov    0xc012b748,%eax
c0101e6c:	31 d0                	xor    %edx,%eax
c0101e6e:	a3 48 b7 12 c0       	mov    %eax,0xc012b748

    c = charcode[shift & (CTL | SHIFT)][data];
c0101e73:	a1 48 b7 12 c0       	mov    0xc012b748,%eax
c0101e78:	83 e0 03             	and    $0x3,%eax
c0101e7b:	8b 14 85 40 85 12 c0 	mov    -0x3fed7ac0(,%eax,4),%edx
c0101e82:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101e86:	01 d0                	add    %edx,%eax
c0101e88:	0f b6 00             	movzbl (%eax),%eax
c0101e8b:	0f b6 c0             	movzbl %al,%eax
c0101e8e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c0101e91:	a1 48 b7 12 c0       	mov    0xc012b748,%eax
c0101e96:	83 e0 08             	and    $0x8,%eax
c0101e99:	85 c0                	test   %eax,%eax
c0101e9b:	74 22                	je     c0101ebf <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
c0101e9d:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c0101ea1:	7e 0c                	jle    c0101eaf <kbd_proc_data+0x13e>
c0101ea3:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c0101ea7:	7f 06                	jg     c0101eaf <kbd_proc_data+0x13e>
            c += 'A' - 'a';
c0101ea9:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c0101ead:	eb 10                	jmp    c0101ebf <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
c0101eaf:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c0101eb3:	7e 0a                	jle    c0101ebf <kbd_proc_data+0x14e>
c0101eb5:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c0101eb9:	7f 04                	jg     c0101ebf <kbd_proc_data+0x14e>
            c += 'a' - 'A';
c0101ebb:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c0101ebf:	a1 48 b7 12 c0       	mov    0xc012b748,%eax
c0101ec4:	f7 d0                	not    %eax
c0101ec6:	83 e0 06             	and    $0x6,%eax
c0101ec9:	85 c0                	test   %eax,%eax
c0101ecb:	75 28                	jne    c0101ef5 <kbd_proc_data+0x184>
c0101ecd:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c0101ed4:	75 1f                	jne    c0101ef5 <kbd_proc_data+0x184>
        cprintf("Rebooting!\n");
c0101ed6:	c7 04 24 21 a4 10 c0 	movl   $0xc010a421,(%esp)
c0101edd:	e8 ef e3 ff ff       	call   c01002d1 <cprintf>
c0101ee2:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c0101ee8:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101eec:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c0101ef0:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0101ef3:	ee                   	out    %al,(%dx)
}
c0101ef4:	90                   	nop
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c0101ef5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101ef8:	c9                   	leave  
c0101ef9:	c3                   	ret    

c0101efa <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c0101efa:	f3 0f 1e fb          	endbr32 
c0101efe:	55                   	push   %ebp
c0101eff:	89 e5                	mov    %esp,%ebp
c0101f01:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c0101f04:	c7 04 24 71 1d 10 c0 	movl   $0xc0101d71,(%esp)
c0101f0b:	e8 93 fd ff ff       	call   c0101ca3 <cons_intr>
}
c0101f10:	90                   	nop
c0101f11:	c9                   	leave  
c0101f12:	c3                   	ret    

c0101f13 <kbd_init>:

static void
kbd_init(void) {
c0101f13:	f3 0f 1e fb          	endbr32 
c0101f17:	55                   	push   %ebp
c0101f18:	89 e5                	mov    %esp,%ebp
c0101f1a:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c0101f1d:	e8 d8 ff ff ff       	call   c0101efa <kbd_intr>
    pic_enable(IRQ_KBD);
c0101f22:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0101f29:	e8 47 01 00 00       	call   c0102075 <pic_enable>
}
c0101f2e:	90                   	nop
c0101f2f:	c9                   	leave  
c0101f30:	c3                   	ret    

c0101f31 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c0101f31:	f3 0f 1e fb          	endbr32 
c0101f35:	55                   	push   %ebp
c0101f36:	89 e5                	mov    %esp,%ebp
c0101f38:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c0101f3b:	e8 2e f8 ff ff       	call   c010176e <cga_init>
    serial_init();
c0101f40:	e8 13 f9 ff ff       	call   c0101858 <serial_init>
    kbd_init();
c0101f45:	e8 c9 ff ff ff       	call   c0101f13 <kbd_init>
    if (!serial_exists) {
c0101f4a:	a1 28 b5 12 c0       	mov    0xc012b528,%eax
c0101f4f:	85 c0                	test   %eax,%eax
c0101f51:	75 0c                	jne    c0101f5f <cons_init+0x2e>
        cprintf("serial port does not exist!!\n");
c0101f53:	c7 04 24 2d a4 10 c0 	movl   $0xc010a42d,(%esp)
c0101f5a:	e8 72 e3 ff ff       	call   c01002d1 <cprintf>
    }
}
c0101f5f:	90                   	nop
c0101f60:	c9                   	leave  
c0101f61:	c3                   	ret    

c0101f62 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c0101f62:	f3 0f 1e fb          	endbr32 
c0101f66:	55                   	push   %ebp
c0101f67:	89 e5                	mov    %esp,%ebp
c0101f69:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0101f6c:	e8 72 f7 ff ff       	call   c01016e3 <__intr_save>
c0101f71:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c0101f74:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f77:	89 04 24             	mov    %eax,(%esp)
c0101f7a:	e8 48 fa ff ff       	call   c01019c7 <lpt_putc>
        cga_putc(c);
c0101f7f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f82:	89 04 24             	mov    %eax,(%esp)
c0101f85:	e8 81 fa ff ff       	call   c0101a0b <cga_putc>
        serial_putc(c);
c0101f8a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f8d:	89 04 24             	mov    %eax,(%esp)
c0101f90:	e8 ca fc ff ff       	call   c0101c5f <serial_putc>
    }
    local_intr_restore(intr_flag);
c0101f95:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101f98:	89 04 24             	mov    %eax,(%esp)
c0101f9b:	e8 6d f7 ff ff       	call   c010170d <__intr_restore>
}
c0101fa0:	90                   	nop
c0101fa1:	c9                   	leave  
c0101fa2:	c3                   	ret    

c0101fa3 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c0101fa3:	f3 0f 1e fb          	endbr32 
c0101fa7:	55                   	push   %ebp
c0101fa8:	89 e5                	mov    %esp,%ebp
c0101faa:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c0101fad:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0101fb4:	e8 2a f7 ff ff       	call   c01016e3 <__intr_save>
c0101fb9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c0101fbc:	e8 8e fd ff ff       	call   c0101d4f <serial_intr>
        kbd_intr();
c0101fc1:	e8 34 ff ff ff       	call   c0101efa <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c0101fc6:	8b 15 40 b7 12 c0    	mov    0xc012b740,%edx
c0101fcc:	a1 44 b7 12 c0       	mov    0xc012b744,%eax
c0101fd1:	39 c2                	cmp    %eax,%edx
c0101fd3:	74 31                	je     c0102006 <cons_getc+0x63>
            c = cons.buf[cons.rpos ++];
c0101fd5:	a1 40 b7 12 c0       	mov    0xc012b740,%eax
c0101fda:	8d 50 01             	lea    0x1(%eax),%edx
c0101fdd:	89 15 40 b7 12 c0    	mov    %edx,0xc012b740
c0101fe3:	0f b6 80 40 b5 12 c0 	movzbl -0x3fed4ac0(%eax),%eax
c0101fea:	0f b6 c0             	movzbl %al,%eax
c0101fed:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c0101ff0:	a1 40 b7 12 c0       	mov    0xc012b740,%eax
c0101ff5:	3d 00 02 00 00       	cmp    $0x200,%eax
c0101ffa:	75 0a                	jne    c0102006 <cons_getc+0x63>
                cons.rpos = 0;
c0101ffc:	c7 05 40 b7 12 c0 00 	movl   $0x0,0xc012b740
c0102003:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c0102006:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102009:	89 04 24             	mov    %eax,(%esp)
c010200c:	e8 fc f6 ff ff       	call   c010170d <__intr_restore>
    return c;
c0102011:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0102014:	c9                   	leave  
c0102015:	c3                   	ret    

c0102016 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c0102016:	f3 0f 1e fb          	endbr32 
c010201a:	55                   	push   %ebp
c010201b:	89 e5                	mov    %esp,%ebp
c010201d:	83 ec 14             	sub    $0x14,%esp
c0102020:	8b 45 08             	mov    0x8(%ebp),%eax
c0102023:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c0102027:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010202a:	66 a3 50 85 12 c0    	mov    %ax,0xc0128550
    if (did_init) {
c0102030:	a1 4c b7 12 c0       	mov    0xc012b74c,%eax
c0102035:	85 c0                	test   %eax,%eax
c0102037:	74 39                	je     c0102072 <pic_setmask+0x5c>
        outb(IO_PIC1 + 1, mask);
c0102039:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010203c:	0f b6 c0             	movzbl %al,%eax
c010203f:	66 c7 45 fa 21 00    	movw   $0x21,-0x6(%ebp)
c0102045:	88 45 f9             	mov    %al,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102048:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010204c:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0102050:	ee                   	out    %al,(%dx)
}
c0102051:	90                   	nop
        outb(IO_PIC2 + 1, mask >> 8);
c0102052:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0102056:	c1 e8 08             	shr    $0x8,%eax
c0102059:	0f b7 c0             	movzwl %ax,%eax
c010205c:	0f b6 c0             	movzbl %al,%eax
c010205f:	66 c7 45 fe a1 00    	movw   $0xa1,-0x2(%ebp)
c0102065:	88 45 fd             	mov    %al,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102068:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c010206c:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0102070:	ee                   	out    %al,(%dx)
}
c0102071:	90                   	nop
    }
}
c0102072:	90                   	nop
c0102073:	c9                   	leave  
c0102074:	c3                   	ret    

c0102075 <pic_enable>:

void
pic_enable(unsigned int irq) {
c0102075:	f3 0f 1e fb          	endbr32 
c0102079:	55                   	push   %ebp
c010207a:	89 e5                	mov    %esp,%ebp
c010207c:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c010207f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102082:	ba 01 00 00 00       	mov    $0x1,%edx
c0102087:	88 c1                	mov    %al,%cl
c0102089:	d3 e2                	shl    %cl,%edx
c010208b:	89 d0                	mov    %edx,%eax
c010208d:	98                   	cwtl   
c010208e:	f7 d0                	not    %eax
c0102090:	0f bf d0             	movswl %ax,%edx
c0102093:	0f b7 05 50 85 12 c0 	movzwl 0xc0128550,%eax
c010209a:	98                   	cwtl   
c010209b:	21 d0                	and    %edx,%eax
c010209d:	98                   	cwtl   
c010209e:	0f b7 c0             	movzwl %ax,%eax
c01020a1:	89 04 24             	mov    %eax,(%esp)
c01020a4:	e8 6d ff ff ff       	call   c0102016 <pic_setmask>
}
c01020a9:	90                   	nop
c01020aa:	c9                   	leave  
c01020ab:	c3                   	ret    

c01020ac <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c01020ac:	f3 0f 1e fb          	endbr32 
c01020b0:	55                   	push   %ebp
c01020b1:	89 e5                	mov    %esp,%ebp
c01020b3:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
c01020b6:	c7 05 4c b7 12 c0 01 	movl   $0x1,0xc012b74c
c01020bd:	00 00 00 
c01020c0:	66 c7 45 ca 21 00    	movw   $0x21,-0x36(%ebp)
c01020c6:	c6 45 c9 ff          	movb   $0xff,-0x37(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01020ca:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c01020ce:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c01020d2:	ee                   	out    %al,(%dx)
}
c01020d3:	90                   	nop
c01020d4:	66 c7 45 ce a1 00    	movw   $0xa1,-0x32(%ebp)
c01020da:	c6 45 cd ff          	movb   $0xff,-0x33(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01020de:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c01020e2:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c01020e6:	ee                   	out    %al,(%dx)
}
c01020e7:	90                   	nop
c01020e8:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c01020ee:	c6 45 d1 11          	movb   $0x11,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01020f2:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c01020f6:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c01020fa:	ee                   	out    %al,(%dx)
}
c01020fb:	90                   	nop
c01020fc:	66 c7 45 d6 21 00    	movw   $0x21,-0x2a(%ebp)
c0102102:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102106:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c010210a:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c010210e:	ee                   	out    %al,(%dx)
}
c010210f:	90                   	nop
c0102110:	66 c7 45 da 21 00    	movw   $0x21,-0x26(%ebp)
c0102116:	c6 45 d9 04          	movb   $0x4,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010211a:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c010211e:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0102122:	ee                   	out    %al,(%dx)
}
c0102123:	90                   	nop
c0102124:	66 c7 45 de 21 00    	movw   $0x21,-0x22(%ebp)
c010212a:	c6 45 dd 03          	movb   $0x3,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010212e:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0102132:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0102136:	ee                   	out    %al,(%dx)
}
c0102137:	90                   	nop
c0102138:	66 c7 45 e2 a0 00    	movw   $0xa0,-0x1e(%ebp)
c010213e:	c6 45 e1 11          	movb   $0x11,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102142:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0102146:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c010214a:	ee                   	out    %al,(%dx)
}
c010214b:	90                   	nop
c010214c:	66 c7 45 e6 a1 00    	movw   $0xa1,-0x1a(%ebp)
c0102152:	c6 45 e5 28          	movb   $0x28,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102156:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c010215a:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c010215e:	ee                   	out    %al,(%dx)
}
c010215f:	90                   	nop
c0102160:	66 c7 45 ea a1 00    	movw   $0xa1,-0x16(%ebp)
c0102166:	c6 45 e9 02          	movb   $0x2,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010216a:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c010216e:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0102172:	ee                   	out    %al,(%dx)
}
c0102173:	90                   	nop
c0102174:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
c010217a:	c6 45 ed 03          	movb   $0x3,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010217e:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0102182:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0102186:	ee                   	out    %al,(%dx)
}
c0102187:	90                   	nop
c0102188:	66 c7 45 f2 20 00    	movw   $0x20,-0xe(%ebp)
c010218e:	c6 45 f1 68          	movb   $0x68,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102192:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0102196:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010219a:	ee                   	out    %al,(%dx)
}
c010219b:	90                   	nop
c010219c:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c01021a2:	c6 45 f5 0a          	movb   $0xa,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01021a6:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c01021aa:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01021ae:	ee                   	out    %al,(%dx)
}
c01021af:	90                   	nop
c01021b0:	66 c7 45 fa a0 00    	movw   $0xa0,-0x6(%ebp)
c01021b6:	c6 45 f9 68          	movb   $0x68,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01021ba:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01021be:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c01021c2:	ee                   	out    %al,(%dx)
}
c01021c3:	90                   	nop
c01021c4:	66 c7 45 fe a0 00    	movw   $0xa0,-0x2(%ebp)
c01021ca:	c6 45 fd 0a          	movb   $0xa,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01021ce:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c01021d2:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c01021d6:	ee                   	out    %al,(%dx)
}
c01021d7:	90                   	nop
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c01021d8:	0f b7 05 50 85 12 c0 	movzwl 0xc0128550,%eax
c01021df:	3d ff ff 00 00       	cmp    $0xffff,%eax
c01021e4:	74 0f                	je     c01021f5 <pic_init+0x149>
        pic_setmask(irq_mask);
c01021e6:	0f b7 05 50 85 12 c0 	movzwl 0xc0128550,%eax
c01021ed:	89 04 24             	mov    %eax,(%esp)
c01021f0:	e8 21 fe ff ff       	call   c0102016 <pic_setmask>
    }
}
c01021f5:	90                   	nop
c01021f6:	c9                   	leave  
c01021f7:	c3                   	ret    

c01021f8 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c01021f8:	f3 0f 1e fb          	endbr32 
c01021fc:	55                   	push   %ebp
c01021fd:	89 e5                	mov    %esp,%ebp
    asm volatile ("sti");
c01021ff:	fb                   	sti    
}
c0102200:	90                   	nop
    sti();
}
c0102201:	90                   	nop
c0102202:	5d                   	pop    %ebp
c0102203:	c3                   	ret    

c0102204 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c0102204:	f3 0f 1e fb          	endbr32 
c0102208:	55                   	push   %ebp
c0102209:	89 e5                	mov    %esp,%ebp
    asm volatile ("cli" ::: "memory");
c010220b:	fa                   	cli    
}
c010220c:	90                   	nop
    cli();
}
c010220d:	90                   	nop
c010220e:	5d                   	pop    %ebp
c010220f:	c3                   	ret    

c0102210 <print_ticks>:
#include <swap.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
c0102210:	f3 0f 1e fb          	endbr32 
c0102214:	55                   	push   %ebp
c0102215:	89 e5                	mov    %esp,%ebp
c0102217:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c010221a:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c0102221:	00 
c0102222:	c7 04 24 60 a4 10 c0 	movl   $0xc010a460,(%esp)
c0102229:	e8 a3 e0 ff ff       	call   c01002d1 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
c010222e:	c7 04 24 6a a4 10 c0 	movl   $0xc010a46a,(%esp)
c0102235:	e8 97 e0 ff ff       	call   c01002d1 <cprintf>
    panic("EOT: kernel seems ok.");
c010223a:	c7 44 24 08 78 a4 10 	movl   $0xc010a478,0x8(%esp)
c0102241:	c0 
c0102242:	c7 44 24 04 14 00 00 	movl   $0x14,0x4(%esp)
c0102249:	00 
c010224a:	c7 04 24 8e a4 10 c0 	movl   $0xc010a48e,(%esp)
c0102251:	e8 e7 e1 ff ff       	call   c010043d <__panic>

c0102256 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c0102256:	f3 0f 1e fb          	endbr32 
c010225a:	55                   	push   %ebp
c010225b:	89 e5                	mov    %esp,%ebp
      *     Can you see idt[256] in this file? Yes, it's IDT! you can use SETGATE macro to setup each item of IDT
      * (3) After setup the contents of IDT, you will let CPU know where is the IDT by using 'lidt' instruction.
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
}
c010225d:	90                   	nop
c010225e:	5d                   	pop    %ebp
c010225f:	c3                   	ret    

c0102260 <trapname>:

static const char *
trapname(int trapno) {
c0102260:	f3 0f 1e fb          	endbr32 
c0102264:	55                   	push   %ebp
c0102265:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c0102267:	8b 45 08             	mov    0x8(%ebp),%eax
c010226a:	83 f8 13             	cmp    $0x13,%eax
c010226d:	77 0c                	ja     c010227b <trapname+0x1b>
        return excnames[trapno];
c010226f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102272:	8b 04 85 e0 a8 10 c0 	mov    -0x3fef5720(,%eax,4),%eax
c0102279:	eb 18                	jmp    c0102293 <trapname+0x33>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c010227b:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c010227f:	7e 0d                	jle    c010228e <trapname+0x2e>
c0102281:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c0102285:	7f 07                	jg     c010228e <trapname+0x2e>
        return "Hardware Interrupt";
c0102287:	b8 9f a4 10 c0       	mov    $0xc010a49f,%eax
c010228c:	eb 05                	jmp    c0102293 <trapname+0x33>
    }
    return "(unknown trap)";
c010228e:	b8 b2 a4 10 c0       	mov    $0xc010a4b2,%eax
}
c0102293:	5d                   	pop    %ebp
c0102294:	c3                   	ret    

c0102295 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c0102295:	f3 0f 1e fb          	endbr32 
c0102299:	55                   	push   %ebp
c010229a:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c010229c:	8b 45 08             	mov    0x8(%ebp),%eax
c010229f:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01022a3:	83 f8 08             	cmp    $0x8,%eax
c01022a6:	0f 94 c0             	sete   %al
c01022a9:	0f b6 c0             	movzbl %al,%eax
}
c01022ac:	5d                   	pop    %ebp
c01022ad:	c3                   	ret    

c01022ae <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c01022ae:	f3 0f 1e fb          	endbr32 
c01022b2:	55                   	push   %ebp
c01022b3:	89 e5                	mov    %esp,%ebp
c01022b5:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c01022b8:	8b 45 08             	mov    0x8(%ebp),%eax
c01022bb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01022bf:	c7 04 24 f3 a4 10 c0 	movl   $0xc010a4f3,(%esp)
c01022c6:	e8 06 e0 ff ff       	call   c01002d1 <cprintf>
    print_regs(&tf->tf_regs);
c01022cb:	8b 45 08             	mov    0x8(%ebp),%eax
c01022ce:	89 04 24             	mov    %eax,(%esp)
c01022d1:	e8 8d 01 00 00       	call   c0102463 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c01022d6:	8b 45 08             	mov    0x8(%ebp),%eax
c01022d9:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c01022dd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01022e1:	c7 04 24 04 a5 10 c0 	movl   $0xc010a504,(%esp)
c01022e8:	e8 e4 df ff ff       	call   c01002d1 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c01022ed:	8b 45 08             	mov    0x8(%ebp),%eax
c01022f0:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c01022f4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01022f8:	c7 04 24 17 a5 10 c0 	movl   $0xc010a517,(%esp)
c01022ff:	e8 cd df ff ff       	call   c01002d1 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0102304:	8b 45 08             	mov    0x8(%ebp),%eax
c0102307:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c010230b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010230f:	c7 04 24 2a a5 10 c0 	movl   $0xc010a52a,(%esp)
c0102316:	e8 b6 df ff ff       	call   c01002d1 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c010231b:	8b 45 08             	mov    0x8(%ebp),%eax
c010231e:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c0102322:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102326:	c7 04 24 3d a5 10 c0 	movl   $0xc010a53d,(%esp)
c010232d:	e8 9f df ff ff       	call   c01002d1 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c0102332:	8b 45 08             	mov    0x8(%ebp),%eax
c0102335:	8b 40 30             	mov    0x30(%eax),%eax
c0102338:	89 04 24             	mov    %eax,(%esp)
c010233b:	e8 20 ff ff ff       	call   c0102260 <trapname>
c0102340:	8b 55 08             	mov    0x8(%ebp),%edx
c0102343:	8b 52 30             	mov    0x30(%edx),%edx
c0102346:	89 44 24 08          	mov    %eax,0x8(%esp)
c010234a:	89 54 24 04          	mov    %edx,0x4(%esp)
c010234e:	c7 04 24 50 a5 10 c0 	movl   $0xc010a550,(%esp)
c0102355:	e8 77 df ff ff       	call   c01002d1 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c010235a:	8b 45 08             	mov    0x8(%ebp),%eax
c010235d:	8b 40 34             	mov    0x34(%eax),%eax
c0102360:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102364:	c7 04 24 62 a5 10 c0 	movl   $0xc010a562,(%esp)
c010236b:	e8 61 df ff ff       	call   c01002d1 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c0102370:	8b 45 08             	mov    0x8(%ebp),%eax
c0102373:	8b 40 38             	mov    0x38(%eax),%eax
c0102376:	89 44 24 04          	mov    %eax,0x4(%esp)
c010237a:	c7 04 24 71 a5 10 c0 	movl   $0xc010a571,(%esp)
c0102381:	e8 4b df ff ff       	call   c01002d1 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c0102386:	8b 45 08             	mov    0x8(%ebp),%eax
c0102389:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c010238d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102391:	c7 04 24 80 a5 10 c0 	movl   $0xc010a580,(%esp)
c0102398:	e8 34 df ff ff       	call   c01002d1 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c010239d:	8b 45 08             	mov    0x8(%ebp),%eax
c01023a0:	8b 40 40             	mov    0x40(%eax),%eax
c01023a3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023a7:	c7 04 24 93 a5 10 c0 	movl   $0xc010a593,(%esp)
c01023ae:	e8 1e df ff ff       	call   c01002d1 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c01023b3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01023ba:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c01023c1:	eb 3d                	jmp    c0102400 <print_trapframe+0x152>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c01023c3:	8b 45 08             	mov    0x8(%ebp),%eax
c01023c6:	8b 50 40             	mov    0x40(%eax),%edx
c01023c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01023cc:	21 d0                	and    %edx,%eax
c01023ce:	85 c0                	test   %eax,%eax
c01023d0:	74 28                	je     c01023fa <print_trapframe+0x14c>
c01023d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01023d5:	8b 04 85 80 85 12 c0 	mov    -0x3fed7a80(,%eax,4),%eax
c01023dc:	85 c0                	test   %eax,%eax
c01023de:	74 1a                	je     c01023fa <print_trapframe+0x14c>
            cprintf("%s,", IA32flags[i]);
c01023e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01023e3:	8b 04 85 80 85 12 c0 	mov    -0x3fed7a80(,%eax,4),%eax
c01023ea:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023ee:	c7 04 24 a2 a5 10 c0 	movl   $0xc010a5a2,(%esp)
c01023f5:	e8 d7 de ff ff       	call   c01002d1 <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c01023fa:	ff 45 f4             	incl   -0xc(%ebp)
c01023fd:	d1 65 f0             	shll   -0x10(%ebp)
c0102400:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102403:	83 f8 17             	cmp    $0x17,%eax
c0102406:	76 bb                	jbe    c01023c3 <print_trapframe+0x115>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c0102408:	8b 45 08             	mov    0x8(%ebp),%eax
c010240b:	8b 40 40             	mov    0x40(%eax),%eax
c010240e:	c1 e8 0c             	shr    $0xc,%eax
c0102411:	83 e0 03             	and    $0x3,%eax
c0102414:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102418:	c7 04 24 a6 a5 10 c0 	movl   $0xc010a5a6,(%esp)
c010241f:	e8 ad de ff ff       	call   c01002d1 <cprintf>

    if (!trap_in_kernel(tf)) {
c0102424:	8b 45 08             	mov    0x8(%ebp),%eax
c0102427:	89 04 24             	mov    %eax,(%esp)
c010242a:	e8 66 fe ff ff       	call   c0102295 <trap_in_kernel>
c010242f:	85 c0                	test   %eax,%eax
c0102431:	75 2d                	jne    c0102460 <print_trapframe+0x1b2>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c0102433:	8b 45 08             	mov    0x8(%ebp),%eax
c0102436:	8b 40 44             	mov    0x44(%eax),%eax
c0102439:	89 44 24 04          	mov    %eax,0x4(%esp)
c010243d:	c7 04 24 af a5 10 c0 	movl   $0xc010a5af,(%esp)
c0102444:	e8 88 de ff ff       	call   c01002d1 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c0102449:	8b 45 08             	mov    0x8(%ebp),%eax
c010244c:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c0102450:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102454:	c7 04 24 be a5 10 c0 	movl   $0xc010a5be,(%esp)
c010245b:	e8 71 de ff ff       	call   c01002d1 <cprintf>
    }
}
c0102460:	90                   	nop
c0102461:	c9                   	leave  
c0102462:	c3                   	ret    

c0102463 <print_regs>:

void
print_regs(struct pushregs *regs) {
c0102463:	f3 0f 1e fb          	endbr32 
c0102467:	55                   	push   %ebp
c0102468:	89 e5                	mov    %esp,%ebp
c010246a:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c010246d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102470:	8b 00                	mov    (%eax),%eax
c0102472:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102476:	c7 04 24 d1 a5 10 c0 	movl   $0xc010a5d1,(%esp)
c010247d:	e8 4f de ff ff       	call   c01002d1 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c0102482:	8b 45 08             	mov    0x8(%ebp),%eax
c0102485:	8b 40 04             	mov    0x4(%eax),%eax
c0102488:	89 44 24 04          	mov    %eax,0x4(%esp)
c010248c:	c7 04 24 e0 a5 10 c0 	movl   $0xc010a5e0,(%esp)
c0102493:	e8 39 de ff ff       	call   c01002d1 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c0102498:	8b 45 08             	mov    0x8(%ebp),%eax
c010249b:	8b 40 08             	mov    0x8(%eax),%eax
c010249e:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024a2:	c7 04 24 ef a5 10 c0 	movl   $0xc010a5ef,(%esp)
c01024a9:	e8 23 de ff ff       	call   c01002d1 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c01024ae:	8b 45 08             	mov    0x8(%ebp),%eax
c01024b1:	8b 40 0c             	mov    0xc(%eax),%eax
c01024b4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024b8:	c7 04 24 fe a5 10 c0 	movl   $0xc010a5fe,(%esp)
c01024bf:	e8 0d de ff ff       	call   c01002d1 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c01024c4:	8b 45 08             	mov    0x8(%ebp),%eax
c01024c7:	8b 40 10             	mov    0x10(%eax),%eax
c01024ca:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024ce:	c7 04 24 0d a6 10 c0 	movl   $0xc010a60d,(%esp)
c01024d5:	e8 f7 dd ff ff       	call   c01002d1 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c01024da:	8b 45 08             	mov    0x8(%ebp),%eax
c01024dd:	8b 40 14             	mov    0x14(%eax),%eax
c01024e0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024e4:	c7 04 24 1c a6 10 c0 	movl   $0xc010a61c,(%esp)
c01024eb:	e8 e1 dd ff ff       	call   c01002d1 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c01024f0:	8b 45 08             	mov    0x8(%ebp),%eax
c01024f3:	8b 40 18             	mov    0x18(%eax),%eax
c01024f6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024fa:	c7 04 24 2b a6 10 c0 	movl   $0xc010a62b,(%esp)
c0102501:	e8 cb dd ff ff       	call   c01002d1 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0102506:	8b 45 08             	mov    0x8(%ebp),%eax
c0102509:	8b 40 1c             	mov    0x1c(%eax),%eax
c010250c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102510:	c7 04 24 3a a6 10 c0 	movl   $0xc010a63a,(%esp)
c0102517:	e8 b5 dd ff ff       	call   c01002d1 <cprintf>
}
c010251c:	90                   	nop
c010251d:	c9                   	leave  
c010251e:	c3                   	ret    

c010251f <print_pgfault>:

static inline void
print_pgfault(struct trapframe *tf) {
c010251f:	55                   	push   %ebp
c0102520:	89 e5                	mov    %esp,%ebp
c0102522:	53                   	push   %ebx
c0102523:	83 ec 34             	sub    $0x34,%esp
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
c0102526:	8b 45 08             	mov    0x8(%ebp),%eax
c0102529:	8b 40 34             	mov    0x34(%eax),%eax
c010252c:	83 e0 01             	and    $0x1,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c010252f:	85 c0                	test   %eax,%eax
c0102531:	74 07                	je     c010253a <print_pgfault+0x1b>
c0102533:	bb 49 a6 10 c0       	mov    $0xc010a649,%ebx
c0102538:	eb 05                	jmp    c010253f <print_pgfault+0x20>
c010253a:	bb 5a a6 10 c0       	mov    $0xc010a65a,%ebx
            (tf->tf_err & 2) ? 'W' : 'R',
c010253f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102542:	8b 40 34             	mov    0x34(%eax),%eax
c0102545:	83 e0 02             	and    $0x2,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c0102548:	85 c0                	test   %eax,%eax
c010254a:	74 07                	je     c0102553 <print_pgfault+0x34>
c010254c:	b9 57 00 00 00       	mov    $0x57,%ecx
c0102551:	eb 05                	jmp    c0102558 <print_pgfault+0x39>
c0102553:	b9 52 00 00 00       	mov    $0x52,%ecx
            (tf->tf_err & 4) ? 'U' : 'K',
c0102558:	8b 45 08             	mov    0x8(%ebp),%eax
c010255b:	8b 40 34             	mov    0x34(%eax),%eax
c010255e:	83 e0 04             	and    $0x4,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c0102561:	85 c0                	test   %eax,%eax
c0102563:	74 07                	je     c010256c <print_pgfault+0x4d>
c0102565:	ba 55 00 00 00       	mov    $0x55,%edx
c010256a:	eb 05                	jmp    c0102571 <print_pgfault+0x52>
c010256c:	ba 4b 00 00 00       	mov    $0x4b,%edx
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c0102571:	0f 20 d0             	mov    %cr2,%eax
c0102574:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr2;
c0102577:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010257a:	89 5c 24 10          	mov    %ebx,0x10(%esp)
c010257e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0102582:	89 54 24 08          	mov    %edx,0x8(%esp)
c0102586:	89 44 24 04          	mov    %eax,0x4(%esp)
c010258a:	c7 04 24 68 a6 10 c0 	movl   $0xc010a668,(%esp)
c0102591:	e8 3b dd ff ff       	call   c01002d1 <cprintf>
}
c0102596:	90                   	nop
c0102597:	83 c4 34             	add    $0x34,%esp
c010259a:	5b                   	pop    %ebx
c010259b:	5d                   	pop    %ebp
c010259c:	c3                   	ret    

c010259d <pgfault_handler>:

static int
pgfault_handler(struct trapframe *tf) {
c010259d:	f3 0f 1e fb          	endbr32 
c01025a1:	55                   	push   %ebp
c01025a2:	89 e5                	mov    %esp,%ebp
c01025a4:	83 ec 28             	sub    $0x28,%esp
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
c01025a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01025aa:	89 04 24             	mov    %eax,(%esp)
c01025ad:	e8 6d ff ff ff       	call   c010251f <print_pgfault>
    if (check_mm_struct != NULL) {
c01025b2:	a1 64 e0 12 c0       	mov    0xc012e064,%eax
c01025b7:	85 c0                	test   %eax,%eax
c01025b9:	74 26                	je     c01025e1 <pgfault_handler+0x44>
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c01025bb:	0f 20 d0             	mov    %cr2,%eax
c01025be:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr2;
c01025c1:	8b 4d f4             	mov    -0xc(%ebp),%ecx
        return do_pgfault(check_mm_struct, tf->tf_err, rcr2());
c01025c4:	8b 45 08             	mov    0x8(%ebp),%eax
c01025c7:	8b 50 34             	mov    0x34(%eax),%edx
c01025ca:	a1 64 e0 12 c0       	mov    0xc012e064,%eax
c01025cf:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01025d3:	89 54 24 04          	mov    %edx,0x4(%esp)
c01025d7:	89 04 24             	mov    %eax,(%esp)
c01025da:	e8 2e 32 00 00       	call   c010580d <do_pgfault>
c01025df:	eb 1c                	jmp    c01025fd <pgfault_handler+0x60>
    }
    panic("unhandled page fault.\n");
c01025e1:	c7 44 24 08 8b a6 10 	movl   $0xc010a68b,0x8(%esp)
c01025e8:	c0 
c01025e9:	c7 44 24 04 9f 00 00 	movl   $0x9f,0x4(%esp)
c01025f0:	00 
c01025f1:	c7 04 24 8e a4 10 c0 	movl   $0xc010a48e,(%esp)
c01025f8:	e8 40 de ff ff       	call   c010043d <__panic>
}
c01025fd:	c9                   	leave  
c01025fe:	c3                   	ret    

c01025ff <trap_dispatch>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

static void
trap_dispatch(struct trapframe *tf) {
c01025ff:	f3 0f 1e fb          	endbr32 
c0102603:	55                   	push   %ebp
c0102604:	89 e5                	mov    %esp,%ebp
c0102606:	83 ec 28             	sub    $0x28,%esp
    char c;

    int ret;

    switch (tf->tf_trapno) {
c0102609:	8b 45 08             	mov    0x8(%ebp),%eax
c010260c:	8b 40 30             	mov    0x30(%eax),%eax
c010260f:	83 f8 2f             	cmp    $0x2f,%eax
c0102612:	77 1f                	ja     c0102633 <trap_dispatch+0x34>
c0102614:	83 f8 0e             	cmp    $0xe,%eax
c0102617:	0f 82 d5 00 00 00    	jb     c01026f2 <trap_dispatch+0xf3>
c010261d:	83 e8 0e             	sub    $0xe,%eax
c0102620:	83 f8 21             	cmp    $0x21,%eax
c0102623:	0f 87 c9 00 00 00    	ja     c01026f2 <trap_dispatch+0xf3>
c0102629:	8b 04 85 0c a7 10 c0 	mov    -0x3fef58f4(,%eax,4),%eax
c0102630:	3e ff e0             	notrack jmp *%eax
c0102633:	83 e8 78             	sub    $0x78,%eax
c0102636:	83 f8 01             	cmp    $0x1,%eax
c0102639:	0f 87 b3 00 00 00    	ja     c01026f2 <trap_dispatch+0xf3>
c010263f:	e9 92 00 00 00       	jmp    c01026d6 <trap_dispatch+0xd7>
    case T_PGFLT:  //page fault
        if ((ret = pgfault_handler(tf)) != 0) {
c0102644:	8b 45 08             	mov    0x8(%ebp),%eax
c0102647:	89 04 24             	mov    %eax,(%esp)
c010264a:	e8 4e ff ff ff       	call   c010259d <pgfault_handler>
c010264f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102652:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0102656:	0f 84 ce 00 00 00    	je     c010272a <trap_dispatch+0x12b>
            print_trapframe(tf);
c010265c:	8b 45 08             	mov    0x8(%ebp),%eax
c010265f:	89 04 24             	mov    %eax,(%esp)
c0102662:	e8 47 fc ff ff       	call   c01022ae <print_trapframe>
            panic("handle pgfault failed. %e\n", ret);
c0102667:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010266a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010266e:	c7 44 24 08 a2 a6 10 	movl   $0xc010a6a2,0x8(%esp)
c0102675:	c0 
c0102676:	c7 44 24 04 af 00 00 	movl   $0xaf,0x4(%esp)
c010267d:	00 
c010267e:	c7 04 24 8e a4 10 c0 	movl   $0xc010a48e,(%esp)
c0102685:	e8 b3 dd ff ff       	call   c010043d <__panic>
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        break;
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c010268a:	e8 14 f9 ff ff       	call   c0101fa3 <cons_getc>
c010268f:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c0102692:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0102696:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c010269a:	89 54 24 08          	mov    %edx,0x8(%esp)
c010269e:	89 44 24 04          	mov    %eax,0x4(%esp)
c01026a2:	c7 04 24 bd a6 10 c0 	movl   $0xc010a6bd,(%esp)
c01026a9:	e8 23 dc ff ff       	call   c01002d1 <cprintf>
        break;
c01026ae:	eb 7b                	jmp    c010272b <trap_dispatch+0x12c>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c01026b0:	e8 ee f8 ff ff       	call   c0101fa3 <cons_getc>
c01026b5:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c01026b8:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c01026bc:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01026c0:	89 54 24 08          	mov    %edx,0x8(%esp)
c01026c4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01026c8:	c7 04 24 cf a6 10 c0 	movl   $0xc010a6cf,(%esp)
c01026cf:	e8 fd db ff ff       	call   c01002d1 <cprintf>
        break;
c01026d4:	eb 55                	jmp    c010272b <trap_dispatch+0x12c>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
c01026d6:	c7 44 24 08 de a6 10 	movl   $0xc010a6de,0x8(%esp)
c01026dd:	c0 
c01026de:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
c01026e5:	00 
c01026e6:	c7 04 24 8e a4 10 c0 	movl   $0xc010a48e,(%esp)
c01026ed:	e8 4b dd ff ff       	call   c010043d <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c01026f2:	8b 45 08             	mov    0x8(%ebp),%eax
c01026f5:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01026f9:	83 e0 03             	and    $0x3,%eax
c01026fc:	85 c0                	test   %eax,%eax
c01026fe:	75 2b                	jne    c010272b <trap_dispatch+0x12c>
            print_trapframe(tf);
c0102700:	8b 45 08             	mov    0x8(%ebp),%eax
c0102703:	89 04 24             	mov    %eax,(%esp)
c0102706:	e8 a3 fb ff ff       	call   c01022ae <print_trapframe>
            panic("unexpected trap in kernel.\n");
c010270b:	c7 44 24 08 ee a6 10 	movl   $0xc010a6ee,0x8(%esp)
c0102712:	c0 
c0102713:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
c010271a:	00 
c010271b:	c7 04 24 8e a4 10 c0 	movl   $0xc010a48e,(%esp)
c0102722:	e8 16 dd ff ff       	call   c010043d <__panic>
        break;
c0102727:	90                   	nop
c0102728:	eb 01                	jmp    c010272b <trap_dispatch+0x12c>
        break;
c010272a:	90                   	nop
        }
    }
}
c010272b:	90                   	nop
c010272c:	c9                   	leave  
c010272d:	c3                   	ret    

c010272e <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c010272e:	f3 0f 1e fb          	endbr32 
c0102732:	55                   	push   %ebp
c0102733:	89 e5                	mov    %esp,%ebp
c0102735:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c0102738:	8b 45 08             	mov    0x8(%ebp),%eax
c010273b:	89 04 24             	mov    %eax,(%esp)
c010273e:	e8 bc fe ff ff       	call   c01025ff <trap_dispatch>
}
c0102743:	90                   	nop
c0102744:	c9                   	leave  
c0102745:	c3                   	ret    

c0102746 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0102746:	6a 00                	push   $0x0
  pushl $0
c0102748:	6a 00                	push   $0x0
  jmp __alltraps
c010274a:	e9 69 0a 00 00       	jmp    c01031b8 <__alltraps>

c010274f <vector1>:
.globl vector1
vector1:
  pushl $0
c010274f:	6a 00                	push   $0x0
  pushl $1
c0102751:	6a 01                	push   $0x1
  jmp __alltraps
c0102753:	e9 60 0a 00 00       	jmp    c01031b8 <__alltraps>

c0102758 <vector2>:
.globl vector2
vector2:
  pushl $0
c0102758:	6a 00                	push   $0x0
  pushl $2
c010275a:	6a 02                	push   $0x2
  jmp __alltraps
c010275c:	e9 57 0a 00 00       	jmp    c01031b8 <__alltraps>

c0102761 <vector3>:
.globl vector3
vector3:
  pushl $0
c0102761:	6a 00                	push   $0x0
  pushl $3
c0102763:	6a 03                	push   $0x3
  jmp __alltraps
c0102765:	e9 4e 0a 00 00       	jmp    c01031b8 <__alltraps>

c010276a <vector4>:
.globl vector4
vector4:
  pushl $0
c010276a:	6a 00                	push   $0x0
  pushl $4
c010276c:	6a 04                	push   $0x4
  jmp __alltraps
c010276e:	e9 45 0a 00 00       	jmp    c01031b8 <__alltraps>

c0102773 <vector5>:
.globl vector5
vector5:
  pushl $0
c0102773:	6a 00                	push   $0x0
  pushl $5
c0102775:	6a 05                	push   $0x5
  jmp __alltraps
c0102777:	e9 3c 0a 00 00       	jmp    c01031b8 <__alltraps>

c010277c <vector6>:
.globl vector6
vector6:
  pushl $0
c010277c:	6a 00                	push   $0x0
  pushl $6
c010277e:	6a 06                	push   $0x6
  jmp __alltraps
c0102780:	e9 33 0a 00 00       	jmp    c01031b8 <__alltraps>

c0102785 <vector7>:
.globl vector7
vector7:
  pushl $0
c0102785:	6a 00                	push   $0x0
  pushl $7
c0102787:	6a 07                	push   $0x7
  jmp __alltraps
c0102789:	e9 2a 0a 00 00       	jmp    c01031b8 <__alltraps>

c010278e <vector8>:
.globl vector8
vector8:
  pushl $8
c010278e:	6a 08                	push   $0x8
  jmp __alltraps
c0102790:	e9 23 0a 00 00       	jmp    c01031b8 <__alltraps>

c0102795 <vector9>:
.globl vector9
vector9:
  pushl $0
c0102795:	6a 00                	push   $0x0
  pushl $9
c0102797:	6a 09                	push   $0x9
  jmp __alltraps
c0102799:	e9 1a 0a 00 00       	jmp    c01031b8 <__alltraps>

c010279e <vector10>:
.globl vector10
vector10:
  pushl $10
c010279e:	6a 0a                	push   $0xa
  jmp __alltraps
c01027a0:	e9 13 0a 00 00       	jmp    c01031b8 <__alltraps>

c01027a5 <vector11>:
.globl vector11
vector11:
  pushl $11
c01027a5:	6a 0b                	push   $0xb
  jmp __alltraps
c01027a7:	e9 0c 0a 00 00       	jmp    c01031b8 <__alltraps>

c01027ac <vector12>:
.globl vector12
vector12:
  pushl $12
c01027ac:	6a 0c                	push   $0xc
  jmp __alltraps
c01027ae:	e9 05 0a 00 00       	jmp    c01031b8 <__alltraps>

c01027b3 <vector13>:
.globl vector13
vector13:
  pushl $13
c01027b3:	6a 0d                	push   $0xd
  jmp __alltraps
c01027b5:	e9 fe 09 00 00       	jmp    c01031b8 <__alltraps>

c01027ba <vector14>:
.globl vector14
vector14:
  pushl $14
c01027ba:	6a 0e                	push   $0xe
  jmp __alltraps
c01027bc:	e9 f7 09 00 00       	jmp    c01031b8 <__alltraps>

c01027c1 <vector15>:
.globl vector15
vector15:
  pushl $0
c01027c1:	6a 00                	push   $0x0
  pushl $15
c01027c3:	6a 0f                	push   $0xf
  jmp __alltraps
c01027c5:	e9 ee 09 00 00       	jmp    c01031b8 <__alltraps>

c01027ca <vector16>:
.globl vector16
vector16:
  pushl $0
c01027ca:	6a 00                	push   $0x0
  pushl $16
c01027cc:	6a 10                	push   $0x10
  jmp __alltraps
c01027ce:	e9 e5 09 00 00       	jmp    c01031b8 <__alltraps>

c01027d3 <vector17>:
.globl vector17
vector17:
  pushl $17
c01027d3:	6a 11                	push   $0x11
  jmp __alltraps
c01027d5:	e9 de 09 00 00       	jmp    c01031b8 <__alltraps>

c01027da <vector18>:
.globl vector18
vector18:
  pushl $0
c01027da:	6a 00                	push   $0x0
  pushl $18
c01027dc:	6a 12                	push   $0x12
  jmp __alltraps
c01027de:	e9 d5 09 00 00       	jmp    c01031b8 <__alltraps>

c01027e3 <vector19>:
.globl vector19
vector19:
  pushl $0
c01027e3:	6a 00                	push   $0x0
  pushl $19
c01027e5:	6a 13                	push   $0x13
  jmp __alltraps
c01027e7:	e9 cc 09 00 00       	jmp    c01031b8 <__alltraps>

c01027ec <vector20>:
.globl vector20
vector20:
  pushl $0
c01027ec:	6a 00                	push   $0x0
  pushl $20
c01027ee:	6a 14                	push   $0x14
  jmp __alltraps
c01027f0:	e9 c3 09 00 00       	jmp    c01031b8 <__alltraps>

c01027f5 <vector21>:
.globl vector21
vector21:
  pushl $0
c01027f5:	6a 00                	push   $0x0
  pushl $21
c01027f7:	6a 15                	push   $0x15
  jmp __alltraps
c01027f9:	e9 ba 09 00 00       	jmp    c01031b8 <__alltraps>

c01027fe <vector22>:
.globl vector22
vector22:
  pushl $0
c01027fe:	6a 00                	push   $0x0
  pushl $22
c0102800:	6a 16                	push   $0x16
  jmp __alltraps
c0102802:	e9 b1 09 00 00       	jmp    c01031b8 <__alltraps>

c0102807 <vector23>:
.globl vector23
vector23:
  pushl $0
c0102807:	6a 00                	push   $0x0
  pushl $23
c0102809:	6a 17                	push   $0x17
  jmp __alltraps
c010280b:	e9 a8 09 00 00       	jmp    c01031b8 <__alltraps>

c0102810 <vector24>:
.globl vector24
vector24:
  pushl $0
c0102810:	6a 00                	push   $0x0
  pushl $24
c0102812:	6a 18                	push   $0x18
  jmp __alltraps
c0102814:	e9 9f 09 00 00       	jmp    c01031b8 <__alltraps>

c0102819 <vector25>:
.globl vector25
vector25:
  pushl $0
c0102819:	6a 00                	push   $0x0
  pushl $25
c010281b:	6a 19                	push   $0x19
  jmp __alltraps
c010281d:	e9 96 09 00 00       	jmp    c01031b8 <__alltraps>

c0102822 <vector26>:
.globl vector26
vector26:
  pushl $0
c0102822:	6a 00                	push   $0x0
  pushl $26
c0102824:	6a 1a                	push   $0x1a
  jmp __alltraps
c0102826:	e9 8d 09 00 00       	jmp    c01031b8 <__alltraps>

c010282b <vector27>:
.globl vector27
vector27:
  pushl $0
c010282b:	6a 00                	push   $0x0
  pushl $27
c010282d:	6a 1b                	push   $0x1b
  jmp __alltraps
c010282f:	e9 84 09 00 00       	jmp    c01031b8 <__alltraps>

c0102834 <vector28>:
.globl vector28
vector28:
  pushl $0
c0102834:	6a 00                	push   $0x0
  pushl $28
c0102836:	6a 1c                	push   $0x1c
  jmp __alltraps
c0102838:	e9 7b 09 00 00       	jmp    c01031b8 <__alltraps>

c010283d <vector29>:
.globl vector29
vector29:
  pushl $0
c010283d:	6a 00                	push   $0x0
  pushl $29
c010283f:	6a 1d                	push   $0x1d
  jmp __alltraps
c0102841:	e9 72 09 00 00       	jmp    c01031b8 <__alltraps>

c0102846 <vector30>:
.globl vector30
vector30:
  pushl $0
c0102846:	6a 00                	push   $0x0
  pushl $30
c0102848:	6a 1e                	push   $0x1e
  jmp __alltraps
c010284a:	e9 69 09 00 00       	jmp    c01031b8 <__alltraps>

c010284f <vector31>:
.globl vector31
vector31:
  pushl $0
c010284f:	6a 00                	push   $0x0
  pushl $31
c0102851:	6a 1f                	push   $0x1f
  jmp __alltraps
c0102853:	e9 60 09 00 00       	jmp    c01031b8 <__alltraps>

c0102858 <vector32>:
.globl vector32
vector32:
  pushl $0
c0102858:	6a 00                	push   $0x0
  pushl $32
c010285a:	6a 20                	push   $0x20
  jmp __alltraps
c010285c:	e9 57 09 00 00       	jmp    c01031b8 <__alltraps>

c0102861 <vector33>:
.globl vector33
vector33:
  pushl $0
c0102861:	6a 00                	push   $0x0
  pushl $33
c0102863:	6a 21                	push   $0x21
  jmp __alltraps
c0102865:	e9 4e 09 00 00       	jmp    c01031b8 <__alltraps>

c010286a <vector34>:
.globl vector34
vector34:
  pushl $0
c010286a:	6a 00                	push   $0x0
  pushl $34
c010286c:	6a 22                	push   $0x22
  jmp __alltraps
c010286e:	e9 45 09 00 00       	jmp    c01031b8 <__alltraps>

c0102873 <vector35>:
.globl vector35
vector35:
  pushl $0
c0102873:	6a 00                	push   $0x0
  pushl $35
c0102875:	6a 23                	push   $0x23
  jmp __alltraps
c0102877:	e9 3c 09 00 00       	jmp    c01031b8 <__alltraps>

c010287c <vector36>:
.globl vector36
vector36:
  pushl $0
c010287c:	6a 00                	push   $0x0
  pushl $36
c010287e:	6a 24                	push   $0x24
  jmp __alltraps
c0102880:	e9 33 09 00 00       	jmp    c01031b8 <__alltraps>

c0102885 <vector37>:
.globl vector37
vector37:
  pushl $0
c0102885:	6a 00                	push   $0x0
  pushl $37
c0102887:	6a 25                	push   $0x25
  jmp __alltraps
c0102889:	e9 2a 09 00 00       	jmp    c01031b8 <__alltraps>

c010288e <vector38>:
.globl vector38
vector38:
  pushl $0
c010288e:	6a 00                	push   $0x0
  pushl $38
c0102890:	6a 26                	push   $0x26
  jmp __alltraps
c0102892:	e9 21 09 00 00       	jmp    c01031b8 <__alltraps>

c0102897 <vector39>:
.globl vector39
vector39:
  pushl $0
c0102897:	6a 00                	push   $0x0
  pushl $39
c0102899:	6a 27                	push   $0x27
  jmp __alltraps
c010289b:	e9 18 09 00 00       	jmp    c01031b8 <__alltraps>

c01028a0 <vector40>:
.globl vector40
vector40:
  pushl $0
c01028a0:	6a 00                	push   $0x0
  pushl $40
c01028a2:	6a 28                	push   $0x28
  jmp __alltraps
c01028a4:	e9 0f 09 00 00       	jmp    c01031b8 <__alltraps>

c01028a9 <vector41>:
.globl vector41
vector41:
  pushl $0
c01028a9:	6a 00                	push   $0x0
  pushl $41
c01028ab:	6a 29                	push   $0x29
  jmp __alltraps
c01028ad:	e9 06 09 00 00       	jmp    c01031b8 <__alltraps>

c01028b2 <vector42>:
.globl vector42
vector42:
  pushl $0
c01028b2:	6a 00                	push   $0x0
  pushl $42
c01028b4:	6a 2a                	push   $0x2a
  jmp __alltraps
c01028b6:	e9 fd 08 00 00       	jmp    c01031b8 <__alltraps>

c01028bb <vector43>:
.globl vector43
vector43:
  pushl $0
c01028bb:	6a 00                	push   $0x0
  pushl $43
c01028bd:	6a 2b                	push   $0x2b
  jmp __alltraps
c01028bf:	e9 f4 08 00 00       	jmp    c01031b8 <__alltraps>

c01028c4 <vector44>:
.globl vector44
vector44:
  pushl $0
c01028c4:	6a 00                	push   $0x0
  pushl $44
c01028c6:	6a 2c                	push   $0x2c
  jmp __alltraps
c01028c8:	e9 eb 08 00 00       	jmp    c01031b8 <__alltraps>

c01028cd <vector45>:
.globl vector45
vector45:
  pushl $0
c01028cd:	6a 00                	push   $0x0
  pushl $45
c01028cf:	6a 2d                	push   $0x2d
  jmp __alltraps
c01028d1:	e9 e2 08 00 00       	jmp    c01031b8 <__alltraps>

c01028d6 <vector46>:
.globl vector46
vector46:
  pushl $0
c01028d6:	6a 00                	push   $0x0
  pushl $46
c01028d8:	6a 2e                	push   $0x2e
  jmp __alltraps
c01028da:	e9 d9 08 00 00       	jmp    c01031b8 <__alltraps>

c01028df <vector47>:
.globl vector47
vector47:
  pushl $0
c01028df:	6a 00                	push   $0x0
  pushl $47
c01028e1:	6a 2f                	push   $0x2f
  jmp __alltraps
c01028e3:	e9 d0 08 00 00       	jmp    c01031b8 <__alltraps>

c01028e8 <vector48>:
.globl vector48
vector48:
  pushl $0
c01028e8:	6a 00                	push   $0x0
  pushl $48
c01028ea:	6a 30                	push   $0x30
  jmp __alltraps
c01028ec:	e9 c7 08 00 00       	jmp    c01031b8 <__alltraps>

c01028f1 <vector49>:
.globl vector49
vector49:
  pushl $0
c01028f1:	6a 00                	push   $0x0
  pushl $49
c01028f3:	6a 31                	push   $0x31
  jmp __alltraps
c01028f5:	e9 be 08 00 00       	jmp    c01031b8 <__alltraps>

c01028fa <vector50>:
.globl vector50
vector50:
  pushl $0
c01028fa:	6a 00                	push   $0x0
  pushl $50
c01028fc:	6a 32                	push   $0x32
  jmp __alltraps
c01028fe:	e9 b5 08 00 00       	jmp    c01031b8 <__alltraps>

c0102903 <vector51>:
.globl vector51
vector51:
  pushl $0
c0102903:	6a 00                	push   $0x0
  pushl $51
c0102905:	6a 33                	push   $0x33
  jmp __alltraps
c0102907:	e9 ac 08 00 00       	jmp    c01031b8 <__alltraps>

c010290c <vector52>:
.globl vector52
vector52:
  pushl $0
c010290c:	6a 00                	push   $0x0
  pushl $52
c010290e:	6a 34                	push   $0x34
  jmp __alltraps
c0102910:	e9 a3 08 00 00       	jmp    c01031b8 <__alltraps>

c0102915 <vector53>:
.globl vector53
vector53:
  pushl $0
c0102915:	6a 00                	push   $0x0
  pushl $53
c0102917:	6a 35                	push   $0x35
  jmp __alltraps
c0102919:	e9 9a 08 00 00       	jmp    c01031b8 <__alltraps>

c010291e <vector54>:
.globl vector54
vector54:
  pushl $0
c010291e:	6a 00                	push   $0x0
  pushl $54
c0102920:	6a 36                	push   $0x36
  jmp __alltraps
c0102922:	e9 91 08 00 00       	jmp    c01031b8 <__alltraps>

c0102927 <vector55>:
.globl vector55
vector55:
  pushl $0
c0102927:	6a 00                	push   $0x0
  pushl $55
c0102929:	6a 37                	push   $0x37
  jmp __alltraps
c010292b:	e9 88 08 00 00       	jmp    c01031b8 <__alltraps>

c0102930 <vector56>:
.globl vector56
vector56:
  pushl $0
c0102930:	6a 00                	push   $0x0
  pushl $56
c0102932:	6a 38                	push   $0x38
  jmp __alltraps
c0102934:	e9 7f 08 00 00       	jmp    c01031b8 <__alltraps>

c0102939 <vector57>:
.globl vector57
vector57:
  pushl $0
c0102939:	6a 00                	push   $0x0
  pushl $57
c010293b:	6a 39                	push   $0x39
  jmp __alltraps
c010293d:	e9 76 08 00 00       	jmp    c01031b8 <__alltraps>

c0102942 <vector58>:
.globl vector58
vector58:
  pushl $0
c0102942:	6a 00                	push   $0x0
  pushl $58
c0102944:	6a 3a                	push   $0x3a
  jmp __alltraps
c0102946:	e9 6d 08 00 00       	jmp    c01031b8 <__alltraps>

c010294b <vector59>:
.globl vector59
vector59:
  pushl $0
c010294b:	6a 00                	push   $0x0
  pushl $59
c010294d:	6a 3b                	push   $0x3b
  jmp __alltraps
c010294f:	e9 64 08 00 00       	jmp    c01031b8 <__alltraps>

c0102954 <vector60>:
.globl vector60
vector60:
  pushl $0
c0102954:	6a 00                	push   $0x0
  pushl $60
c0102956:	6a 3c                	push   $0x3c
  jmp __alltraps
c0102958:	e9 5b 08 00 00       	jmp    c01031b8 <__alltraps>

c010295d <vector61>:
.globl vector61
vector61:
  pushl $0
c010295d:	6a 00                	push   $0x0
  pushl $61
c010295f:	6a 3d                	push   $0x3d
  jmp __alltraps
c0102961:	e9 52 08 00 00       	jmp    c01031b8 <__alltraps>

c0102966 <vector62>:
.globl vector62
vector62:
  pushl $0
c0102966:	6a 00                	push   $0x0
  pushl $62
c0102968:	6a 3e                	push   $0x3e
  jmp __alltraps
c010296a:	e9 49 08 00 00       	jmp    c01031b8 <__alltraps>

c010296f <vector63>:
.globl vector63
vector63:
  pushl $0
c010296f:	6a 00                	push   $0x0
  pushl $63
c0102971:	6a 3f                	push   $0x3f
  jmp __alltraps
c0102973:	e9 40 08 00 00       	jmp    c01031b8 <__alltraps>

c0102978 <vector64>:
.globl vector64
vector64:
  pushl $0
c0102978:	6a 00                	push   $0x0
  pushl $64
c010297a:	6a 40                	push   $0x40
  jmp __alltraps
c010297c:	e9 37 08 00 00       	jmp    c01031b8 <__alltraps>

c0102981 <vector65>:
.globl vector65
vector65:
  pushl $0
c0102981:	6a 00                	push   $0x0
  pushl $65
c0102983:	6a 41                	push   $0x41
  jmp __alltraps
c0102985:	e9 2e 08 00 00       	jmp    c01031b8 <__alltraps>

c010298a <vector66>:
.globl vector66
vector66:
  pushl $0
c010298a:	6a 00                	push   $0x0
  pushl $66
c010298c:	6a 42                	push   $0x42
  jmp __alltraps
c010298e:	e9 25 08 00 00       	jmp    c01031b8 <__alltraps>

c0102993 <vector67>:
.globl vector67
vector67:
  pushl $0
c0102993:	6a 00                	push   $0x0
  pushl $67
c0102995:	6a 43                	push   $0x43
  jmp __alltraps
c0102997:	e9 1c 08 00 00       	jmp    c01031b8 <__alltraps>

c010299c <vector68>:
.globl vector68
vector68:
  pushl $0
c010299c:	6a 00                	push   $0x0
  pushl $68
c010299e:	6a 44                	push   $0x44
  jmp __alltraps
c01029a0:	e9 13 08 00 00       	jmp    c01031b8 <__alltraps>

c01029a5 <vector69>:
.globl vector69
vector69:
  pushl $0
c01029a5:	6a 00                	push   $0x0
  pushl $69
c01029a7:	6a 45                	push   $0x45
  jmp __alltraps
c01029a9:	e9 0a 08 00 00       	jmp    c01031b8 <__alltraps>

c01029ae <vector70>:
.globl vector70
vector70:
  pushl $0
c01029ae:	6a 00                	push   $0x0
  pushl $70
c01029b0:	6a 46                	push   $0x46
  jmp __alltraps
c01029b2:	e9 01 08 00 00       	jmp    c01031b8 <__alltraps>

c01029b7 <vector71>:
.globl vector71
vector71:
  pushl $0
c01029b7:	6a 00                	push   $0x0
  pushl $71
c01029b9:	6a 47                	push   $0x47
  jmp __alltraps
c01029bb:	e9 f8 07 00 00       	jmp    c01031b8 <__alltraps>

c01029c0 <vector72>:
.globl vector72
vector72:
  pushl $0
c01029c0:	6a 00                	push   $0x0
  pushl $72
c01029c2:	6a 48                	push   $0x48
  jmp __alltraps
c01029c4:	e9 ef 07 00 00       	jmp    c01031b8 <__alltraps>

c01029c9 <vector73>:
.globl vector73
vector73:
  pushl $0
c01029c9:	6a 00                	push   $0x0
  pushl $73
c01029cb:	6a 49                	push   $0x49
  jmp __alltraps
c01029cd:	e9 e6 07 00 00       	jmp    c01031b8 <__alltraps>

c01029d2 <vector74>:
.globl vector74
vector74:
  pushl $0
c01029d2:	6a 00                	push   $0x0
  pushl $74
c01029d4:	6a 4a                	push   $0x4a
  jmp __alltraps
c01029d6:	e9 dd 07 00 00       	jmp    c01031b8 <__alltraps>

c01029db <vector75>:
.globl vector75
vector75:
  pushl $0
c01029db:	6a 00                	push   $0x0
  pushl $75
c01029dd:	6a 4b                	push   $0x4b
  jmp __alltraps
c01029df:	e9 d4 07 00 00       	jmp    c01031b8 <__alltraps>

c01029e4 <vector76>:
.globl vector76
vector76:
  pushl $0
c01029e4:	6a 00                	push   $0x0
  pushl $76
c01029e6:	6a 4c                	push   $0x4c
  jmp __alltraps
c01029e8:	e9 cb 07 00 00       	jmp    c01031b8 <__alltraps>

c01029ed <vector77>:
.globl vector77
vector77:
  pushl $0
c01029ed:	6a 00                	push   $0x0
  pushl $77
c01029ef:	6a 4d                	push   $0x4d
  jmp __alltraps
c01029f1:	e9 c2 07 00 00       	jmp    c01031b8 <__alltraps>

c01029f6 <vector78>:
.globl vector78
vector78:
  pushl $0
c01029f6:	6a 00                	push   $0x0
  pushl $78
c01029f8:	6a 4e                	push   $0x4e
  jmp __alltraps
c01029fa:	e9 b9 07 00 00       	jmp    c01031b8 <__alltraps>

c01029ff <vector79>:
.globl vector79
vector79:
  pushl $0
c01029ff:	6a 00                	push   $0x0
  pushl $79
c0102a01:	6a 4f                	push   $0x4f
  jmp __alltraps
c0102a03:	e9 b0 07 00 00       	jmp    c01031b8 <__alltraps>

c0102a08 <vector80>:
.globl vector80
vector80:
  pushl $0
c0102a08:	6a 00                	push   $0x0
  pushl $80
c0102a0a:	6a 50                	push   $0x50
  jmp __alltraps
c0102a0c:	e9 a7 07 00 00       	jmp    c01031b8 <__alltraps>

c0102a11 <vector81>:
.globl vector81
vector81:
  pushl $0
c0102a11:	6a 00                	push   $0x0
  pushl $81
c0102a13:	6a 51                	push   $0x51
  jmp __alltraps
c0102a15:	e9 9e 07 00 00       	jmp    c01031b8 <__alltraps>

c0102a1a <vector82>:
.globl vector82
vector82:
  pushl $0
c0102a1a:	6a 00                	push   $0x0
  pushl $82
c0102a1c:	6a 52                	push   $0x52
  jmp __alltraps
c0102a1e:	e9 95 07 00 00       	jmp    c01031b8 <__alltraps>

c0102a23 <vector83>:
.globl vector83
vector83:
  pushl $0
c0102a23:	6a 00                	push   $0x0
  pushl $83
c0102a25:	6a 53                	push   $0x53
  jmp __alltraps
c0102a27:	e9 8c 07 00 00       	jmp    c01031b8 <__alltraps>

c0102a2c <vector84>:
.globl vector84
vector84:
  pushl $0
c0102a2c:	6a 00                	push   $0x0
  pushl $84
c0102a2e:	6a 54                	push   $0x54
  jmp __alltraps
c0102a30:	e9 83 07 00 00       	jmp    c01031b8 <__alltraps>

c0102a35 <vector85>:
.globl vector85
vector85:
  pushl $0
c0102a35:	6a 00                	push   $0x0
  pushl $85
c0102a37:	6a 55                	push   $0x55
  jmp __alltraps
c0102a39:	e9 7a 07 00 00       	jmp    c01031b8 <__alltraps>

c0102a3e <vector86>:
.globl vector86
vector86:
  pushl $0
c0102a3e:	6a 00                	push   $0x0
  pushl $86
c0102a40:	6a 56                	push   $0x56
  jmp __alltraps
c0102a42:	e9 71 07 00 00       	jmp    c01031b8 <__alltraps>

c0102a47 <vector87>:
.globl vector87
vector87:
  pushl $0
c0102a47:	6a 00                	push   $0x0
  pushl $87
c0102a49:	6a 57                	push   $0x57
  jmp __alltraps
c0102a4b:	e9 68 07 00 00       	jmp    c01031b8 <__alltraps>

c0102a50 <vector88>:
.globl vector88
vector88:
  pushl $0
c0102a50:	6a 00                	push   $0x0
  pushl $88
c0102a52:	6a 58                	push   $0x58
  jmp __alltraps
c0102a54:	e9 5f 07 00 00       	jmp    c01031b8 <__alltraps>

c0102a59 <vector89>:
.globl vector89
vector89:
  pushl $0
c0102a59:	6a 00                	push   $0x0
  pushl $89
c0102a5b:	6a 59                	push   $0x59
  jmp __alltraps
c0102a5d:	e9 56 07 00 00       	jmp    c01031b8 <__alltraps>

c0102a62 <vector90>:
.globl vector90
vector90:
  pushl $0
c0102a62:	6a 00                	push   $0x0
  pushl $90
c0102a64:	6a 5a                	push   $0x5a
  jmp __alltraps
c0102a66:	e9 4d 07 00 00       	jmp    c01031b8 <__alltraps>

c0102a6b <vector91>:
.globl vector91
vector91:
  pushl $0
c0102a6b:	6a 00                	push   $0x0
  pushl $91
c0102a6d:	6a 5b                	push   $0x5b
  jmp __alltraps
c0102a6f:	e9 44 07 00 00       	jmp    c01031b8 <__alltraps>

c0102a74 <vector92>:
.globl vector92
vector92:
  pushl $0
c0102a74:	6a 00                	push   $0x0
  pushl $92
c0102a76:	6a 5c                	push   $0x5c
  jmp __alltraps
c0102a78:	e9 3b 07 00 00       	jmp    c01031b8 <__alltraps>

c0102a7d <vector93>:
.globl vector93
vector93:
  pushl $0
c0102a7d:	6a 00                	push   $0x0
  pushl $93
c0102a7f:	6a 5d                	push   $0x5d
  jmp __alltraps
c0102a81:	e9 32 07 00 00       	jmp    c01031b8 <__alltraps>

c0102a86 <vector94>:
.globl vector94
vector94:
  pushl $0
c0102a86:	6a 00                	push   $0x0
  pushl $94
c0102a88:	6a 5e                	push   $0x5e
  jmp __alltraps
c0102a8a:	e9 29 07 00 00       	jmp    c01031b8 <__alltraps>

c0102a8f <vector95>:
.globl vector95
vector95:
  pushl $0
c0102a8f:	6a 00                	push   $0x0
  pushl $95
c0102a91:	6a 5f                	push   $0x5f
  jmp __alltraps
c0102a93:	e9 20 07 00 00       	jmp    c01031b8 <__alltraps>

c0102a98 <vector96>:
.globl vector96
vector96:
  pushl $0
c0102a98:	6a 00                	push   $0x0
  pushl $96
c0102a9a:	6a 60                	push   $0x60
  jmp __alltraps
c0102a9c:	e9 17 07 00 00       	jmp    c01031b8 <__alltraps>

c0102aa1 <vector97>:
.globl vector97
vector97:
  pushl $0
c0102aa1:	6a 00                	push   $0x0
  pushl $97
c0102aa3:	6a 61                	push   $0x61
  jmp __alltraps
c0102aa5:	e9 0e 07 00 00       	jmp    c01031b8 <__alltraps>

c0102aaa <vector98>:
.globl vector98
vector98:
  pushl $0
c0102aaa:	6a 00                	push   $0x0
  pushl $98
c0102aac:	6a 62                	push   $0x62
  jmp __alltraps
c0102aae:	e9 05 07 00 00       	jmp    c01031b8 <__alltraps>

c0102ab3 <vector99>:
.globl vector99
vector99:
  pushl $0
c0102ab3:	6a 00                	push   $0x0
  pushl $99
c0102ab5:	6a 63                	push   $0x63
  jmp __alltraps
c0102ab7:	e9 fc 06 00 00       	jmp    c01031b8 <__alltraps>

c0102abc <vector100>:
.globl vector100
vector100:
  pushl $0
c0102abc:	6a 00                	push   $0x0
  pushl $100
c0102abe:	6a 64                	push   $0x64
  jmp __alltraps
c0102ac0:	e9 f3 06 00 00       	jmp    c01031b8 <__alltraps>

c0102ac5 <vector101>:
.globl vector101
vector101:
  pushl $0
c0102ac5:	6a 00                	push   $0x0
  pushl $101
c0102ac7:	6a 65                	push   $0x65
  jmp __alltraps
c0102ac9:	e9 ea 06 00 00       	jmp    c01031b8 <__alltraps>

c0102ace <vector102>:
.globl vector102
vector102:
  pushl $0
c0102ace:	6a 00                	push   $0x0
  pushl $102
c0102ad0:	6a 66                	push   $0x66
  jmp __alltraps
c0102ad2:	e9 e1 06 00 00       	jmp    c01031b8 <__alltraps>

c0102ad7 <vector103>:
.globl vector103
vector103:
  pushl $0
c0102ad7:	6a 00                	push   $0x0
  pushl $103
c0102ad9:	6a 67                	push   $0x67
  jmp __alltraps
c0102adb:	e9 d8 06 00 00       	jmp    c01031b8 <__alltraps>

c0102ae0 <vector104>:
.globl vector104
vector104:
  pushl $0
c0102ae0:	6a 00                	push   $0x0
  pushl $104
c0102ae2:	6a 68                	push   $0x68
  jmp __alltraps
c0102ae4:	e9 cf 06 00 00       	jmp    c01031b8 <__alltraps>

c0102ae9 <vector105>:
.globl vector105
vector105:
  pushl $0
c0102ae9:	6a 00                	push   $0x0
  pushl $105
c0102aeb:	6a 69                	push   $0x69
  jmp __alltraps
c0102aed:	e9 c6 06 00 00       	jmp    c01031b8 <__alltraps>

c0102af2 <vector106>:
.globl vector106
vector106:
  pushl $0
c0102af2:	6a 00                	push   $0x0
  pushl $106
c0102af4:	6a 6a                	push   $0x6a
  jmp __alltraps
c0102af6:	e9 bd 06 00 00       	jmp    c01031b8 <__alltraps>

c0102afb <vector107>:
.globl vector107
vector107:
  pushl $0
c0102afb:	6a 00                	push   $0x0
  pushl $107
c0102afd:	6a 6b                	push   $0x6b
  jmp __alltraps
c0102aff:	e9 b4 06 00 00       	jmp    c01031b8 <__alltraps>

c0102b04 <vector108>:
.globl vector108
vector108:
  pushl $0
c0102b04:	6a 00                	push   $0x0
  pushl $108
c0102b06:	6a 6c                	push   $0x6c
  jmp __alltraps
c0102b08:	e9 ab 06 00 00       	jmp    c01031b8 <__alltraps>

c0102b0d <vector109>:
.globl vector109
vector109:
  pushl $0
c0102b0d:	6a 00                	push   $0x0
  pushl $109
c0102b0f:	6a 6d                	push   $0x6d
  jmp __alltraps
c0102b11:	e9 a2 06 00 00       	jmp    c01031b8 <__alltraps>

c0102b16 <vector110>:
.globl vector110
vector110:
  pushl $0
c0102b16:	6a 00                	push   $0x0
  pushl $110
c0102b18:	6a 6e                	push   $0x6e
  jmp __alltraps
c0102b1a:	e9 99 06 00 00       	jmp    c01031b8 <__alltraps>

c0102b1f <vector111>:
.globl vector111
vector111:
  pushl $0
c0102b1f:	6a 00                	push   $0x0
  pushl $111
c0102b21:	6a 6f                	push   $0x6f
  jmp __alltraps
c0102b23:	e9 90 06 00 00       	jmp    c01031b8 <__alltraps>

c0102b28 <vector112>:
.globl vector112
vector112:
  pushl $0
c0102b28:	6a 00                	push   $0x0
  pushl $112
c0102b2a:	6a 70                	push   $0x70
  jmp __alltraps
c0102b2c:	e9 87 06 00 00       	jmp    c01031b8 <__alltraps>

c0102b31 <vector113>:
.globl vector113
vector113:
  pushl $0
c0102b31:	6a 00                	push   $0x0
  pushl $113
c0102b33:	6a 71                	push   $0x71
  jmp __alltraps
c0102b35:	e9 7e 06 00 00       	jmp    c01031b8 <__alltraps>

c0102b3a <vector114>:
.globl vector114
vector114:
  pushl $0
c0102b3a:	6a 00                	push   $0x0
  pushl $114
c0102b3c:	6a 72                	push   $0x72
  jmp __alltraps
c0102b3e:	e9 75 06 00 00       	jmp    c01031b8 <__alltraps>

c0102b43 <vector115>:
.globl vector115
vector115:
  pushl $0
c0102b43:	6a 00                	push   $0x0
  pushl $115
c0102b45:	6a 73                	push   $0x73
  jmp __alltraps
c0102b47:	e9 6c 06 00 00       	jmp    c01031b8 <__alltraps>

c0102b4c <vector116>:
.globl vector116
vector116:
  pushl $0
c0102b4c:	6a 00                	push   $0x0
  pushl $116
c0102b4e:	6a 74                	push   $0x74
  jmp __alltraps
c0102b50:	e9 63 06 00 00       	jmp    c01031b8 <__alltraps>

c0102b55 <vector117>:
.globl vector117
vector117:
  pushl $0
c0102b55:	6a 00                	push   $0x0
  pushl $117
c0102b57:	6a 75                	push   $0x75
  jmp __alltraps
c0102b59:	e9 5a 06 00 00       	jmp    c01031b8 <__alltraps>

c0102b5e <vector118>:
.globl vector118
vector118:
  pushl $0
c0102b5e:	6a 00                	push   $0x0
  pushl $118
c0102b60:	6a 76                	push   $0x76
  jmp __alltraps
c0102b62:	e9 51 06 00 00       	jmp    c01031b8 <__alltraps>

c0102b67 <vector119>:
.globl vector119
vector119:
  pushl $0
c0102b67:	6a 00                	push   $0x0
  pushl $119
c0102b69:	6a 77                	push   $0x77
  jmp __alltraps
c0102b6b:	e9 48 06 00 00       	jmp    c01031b8 <__alltraps>

c0102b70 <vector120>:
.globl vector120
vector120:
  pushl $0
c0102b70:	6a 00                	push   $0x0
  pushl $120
c0102b72:	6a 78                	push   $0x78
  jmp __alltraps
c0102b74:	e9 3f 06 00 00       	jmp    c01031b8 <__alltraps>

c0102b79 <vector121>:
.globl vector121
vector121:
  pushl $0
c0102b79:	6a 00                	push   $0x0
  pushl $121
c0102b7b:	6a 79                	push   $0x79
  jmp __alltraps
c0102b7d:	e9 36 06 00 00       	jmp    c01031b8 <__alltraps>

c0102b82 <vector122>:
.globl vector122
vector122:
  pushl $0
c0102b82:	6a 00                	push   $0x0
  pushl $122
c0102b84:	6a 7a                	push   $0x7a
  jmp __alltraps
c0102b86:	e9 2d 06 00 00       	jmp    c01031b8 <__alltraps>

c0102b8b <vector123>:
.globl vector123
vector123:
  pushl $0
c0102b8b:	6a 00                	push   $0x0
  pushl $123
c0102b8d:	6a 7b                	push   $0x7b
  jmp __alltraps
c0102b8f:	e9 24 06 00 00       	jmp    c01031b8 <__alltraps>

c0102b94 <vector124>:
.globl vector124
vector124:
  pushl $0
c0102b94:	6a 00                	push   $0x0
  pushl $124
c0102b96:	6a 7c                	push   $0x7c
  jmp __alltraps
c0102b98:	e9 1b 06 00 00       	jmp    c01031b8 <__alltraps>

c0102b9d <vector125>:
.globl vector125
vector125:
  pushl $0
c0102b9d:	6a 00                	push   $0x0
  pushl $125
c0102b9f:	6a 7d                	push   $0x7d
  jmp __alltraps
c0102ba1:	e9 12 06 00 00       	jmp    c01031b8 <__alltraps>

c0102ba6 <vector126>:
.globl vector126
vector126:
  pushl $0
c0102ba6:	6a 00                	push   $0x0
  pushl $126
c0102ba8:	6a 7e                	push   $0x7e
  jmp __alltraps
c0102baa:	e9 09 06 00 00       	jmp    c01031b8 <__alltraps>

c0102baf <vector127>:
.globl vector127
vector127:
  pushl $0
c0102baf:	6a 00                	push   $0x0
  pushl $127
c0102bb1:	6a 7f                	push   $0x7f
  jmp __alltraps
c0102bb3:	e9 00 06 00 00       	jmp    c01031b8 <__alltraps>

c0102bb8 <vector128>:
.globl vector128
vector128:
  pushl $0
c0102bb8:	6a 00                	push   $0x0
  pushl $128
c0102bba:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c0102bbf:	e9 f4 05 00 00       	jmp    c01031b8 <__alltraps>

c0102bc4 <vector129>:
.globl vector129
vector129:
  pushl $0
c0102bc4:	6a 00                	push   $0x0
  pushl $129
c0102bc6:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c0102bcb:	e9 e8 05 00 00       	jmp    c01031b8 <__alltraps>

c0102bd0 <vector130>:
.globl vector130
vector130:
  pushl $0
c0102bd0:	6a 00                	push   $0x0
  pushl $130
c0102bd2:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c0102bd7:	e9 dc 05 00 00       	jmp    c01031b8 <__alltraps>

c0102bdc <vector131>:
.globl vector131
vector131:
  pushl $0
c0102bdc:	6a 00                	push   $0x0
  pushl $131
c0102bde:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c0102be3:	e9 d0 05 00 00       	jmp    c01031b8 <__alltraps>

c0102be8 <vector132>:
.globl vector132
vector132:
  pushl $0
c0102be8:	6a 00                	push   $0x0
  pushl $132
c0102bea:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c0102bef:	e9 c4 05 00 00       	jmp    c01031b8 <__alltraps>

c0102bf4 <vector133>:
.globl vector133
vector133:
  pushl $0
c0102bf4:	6a 00                	push   $0x0
  pushl $133
c0102bf6:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c0102bfb:	e9 b8 05 00 00       	jmp    c01031b8 <__alltraps>

c0102c00 <vector134>:
.globl vector134
vector134:
  pushl $0
c0102c00:	6a 00                	push   $0x0
  pushl $134
c0102c02:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c0102c07:	e9 ac 05 00 00       	jmp    c01031b8 <__alltraps>

c0102c0c <vector135>:
.globl vector135
vector135:
  pushl $0
c0102c0c:	6a 00                	push   $0x0
  pushl $135
c0102c0e:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0102c13:	e9 a0 05 00 00       	jmp    c01031b8 <__alltraps>

c0102c18 <vector136>:
.globl vector136
vector136:
  pushl $0
c0102c18:	6a 00                	push   $0x0
  pushl $136
c0102c1a:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c0102c1f:	e9 94 05 00 00       	jmp    c01031b8 <__alltraps>

c0102c24 <vector137>:
.globl vector137
vector137:
  pushl $0
c0102c24:	6a 00                	push   $0x0
  pushl $137
c0102c26:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c0102c2b:	e9 88 05 00 00       	jmp    c01031b8 <__alltraps>

c0102c30 <vector138>:
.globl vector138
vector138:
  pushl $0
c0102c30:	6a 00                	push   $0x0
  pushl $138
c0102c32:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c0102c37:	e9 7c 05 00 00       	jmp    c01031b8 <__alltraps>

c0102c3c <vector139>:
.globl vector139
vector139:
  pushl $0
c0102c3c:	6a 00                	push   $0x0
  pushl $139
c0102c3e:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c0102c43:	e9 70 05 00 00       	jmp    c01031b8 <__alltraps>

c0102c48 <vector140>:
.globl vector140
vector140:
  pushl $0
c0102c48:	6a 00                	push   $0x0
  pushl $140
c0102c4a:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c0102c4f:	e9 64 05 00 00       	jmp    c01031b8 <__alltraps>

c0102c54 <vector141>:
.globl vector141
vector141:
  pushl $0
c0102c54:	6a 00                	push   $0x0
  pushl $141
c0102c56:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c0102c5b:	e9 58 05 00 00       	jmp    c01031b8 <__alltraps>

c0102c60 <vector142>:
.globl vector142
vector142:
  pushl $0
c0102c60:	6a 00                	push   $0x0
  pushl $142
c0102c62:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c0102c67:	e9 4c 05 00 00       	jmp    c01031b8 <__alltraps>

c0102c6c <vector143>:
.globl vector143
vector143:
  pushl $0
c0102c6c:	6a 00                	push   $0x0
  pushl $143
c0102c6e:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c0102c73:	e9 40 05 00 00       	jmp    c01031b8 <__alltraps>

c0102c78 <vector144>:
.globl vector144
vector144:
  pushl $0
c0102c78:	6a 00                	push   $0x0
  pushl $144
c0102c7a:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c0102c7f:	e9 34 05 00 00       	jmp    c01031b8 <__alltraps>

c0102c84 <vector145>:
.globl vector145
vector145:
  pushl $0
c0102c84:	6a 00                	push   $0x0
  pushl $145
c0102c86:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c0102c8b:	e9 28 05 00 00       	jmp    c01031b8 <__alltraps>

c0102c90 <vector146>:
.globl vector146
vector146:
  pushl $0
c0102c90:	6a 00                	push   $0x0
  pushl $146
c0102c92:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c0102c97:	e9 1c 05 00 00       	jmp    c01031b8 <__alltraps>

c0102c9c <vector147>:
.globl vector147
vector147:
  pushl $0
c0102c9c:	6a 00                	push   $0x0
  pushl $147
c0102c9e:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c0102ca3:	e9 10 05 00 00       	jmp    c01031b8 <__alltraps>

c0102ca8 <vector148>:
.globl vector148
vector148:
  pushl $0
c0102ca8:	6a 00                	push   $0x0
  pushl $148
c0102caa:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c0102caf:	e9 04 05 00 00       	jmp    c01031b8 <__alltraps>

c0102cb4 <vector149>:
.globl vector149
vector149:
  pushl $0
c0102cb4:	6a 00                	push   $0x0
  pushl $149
c0102cb6:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c0102cbb:	e9 f8 04 00 00       	jmp    c01031b8 <__alltraps>

c0102cc0 <vector150>:
.globl vector150
vector150:
  pushl $0
c0102cc0:	6a 00                	push   $0x0
  pushl $150
c0102cc2:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c0102cc7:	e9 ec 04 00 00       	jmp    c01031b8 <__alltraps>

c0102ccc <vector151>:
.globl vector151
vector151:
  pushl $0
c0102ccc:	6a 00                	push   $0x0
  pushl $151
c0102cce:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c0102cd3:	e9 e0 04 00 00       	jmp    c01031b8 <__alltraps>

c0102cd8 <vector152>:
.globl vector152
vector152:
  pushl $0
c0102cd8:	6a 00                	push   $0x0
  pushl $152
c0102cda:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c0102cdf:	e9 d4 04 00 00       	jmp    c01031b8 <__alltraps>

c0102ce4 <vector153>:
.globl vector153
vector153:
  pushl $0
c0102ce4:	6a 00                	push   $0x0
  pushl $153
c0102ce6:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c0102ceb:	e9 c8 04 00 00       	jmp    c01031b8 <__alltraps>

c0102cf0 <vector154>:
.globl vector154
vector154:
  pushl $0
c0102cf0:	6a 00                	push   $0x0
  pushl $154
c0102cf2:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c0102cf7:	e9 bc 04 00 00       	jmp    c01031b8 <__alltraps>

c0102cfc <vector155>:
.globl vector155
vector155:
  pushl $0
c0102cfc:	6a 00                	push   $0x0
  pushl $155
c0102cfe:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c0102d03:	e9 b0 04 00 00       	jmp    c01031b8 <__alltraps>

c0102d08 <vector156>:
.globl vector156
vector156:
  pushl $0
c0102d08:	6a 00                	push   $0x0
  pushl $156
c0102d0a:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c0102d0f:	e9 a4 04 00 00       	jmp    c01031b8 <__alltraps>

c0102d14 <vector157>:
.globl vector157
vector157:
  pushl $0
c0102d14:	6a 00                	push   $0x0
  pushl $157
c0102d16:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c0102d1b:	e9 98 04 00 00       	jmp    c01031b8 <__alltraps>

c0102d20 <vector158>:
.globl vector158
vector158:
  pushl $0
c0102d20:	6a 00                	push   $0x0
  pushl $158
c0102d22:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c0102d27:	e9 8c 04 00 00       	jmp    c01031b8 <__alltraps>

c0102d2c <vector159>:
.globl vector159
vector159:
  pushl $0
c0102d2c:	6a 00                	push   $0x0
  pushl $159
c0102d2e:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c0102d33:	e9 80 04 00 00       	jmp    c01031b8 <__alltraps>

c0102d38 <vector160>:
.globl vector160
vector160:
  pushl $0
c0102d38:	6a 00                	push   $0x0
  pushl $160
c0102d3a:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c0102d3f:	e9 74 04 00 00       	jmp    c01031b8 <__alltraps>

c0102d44 <vector161>:
.globl vector161
vector161:
  pushl $0
c0102d44:	6a 00                	push   $0x0
  pushl $161
c0102d46:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c0102d4b:	e9 68 04 00 00       	jmp    c01031b8 <__alltraps>

c0102d50 <vector162>:
.globl vector162
vector162:
  pushl $0
c0102d50:	6a 00                	push   $0x0
  pushl $162
c0102d52:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c0102d57:	e9 5c 04 00 00       	jmp    c01031b8 <__alltraps>

c0102d5c <vector163>:
.globl vector163
vector163:
  pushl $0
c0102d5c:	6a 00                	push   $0x0
  pushl $163
c0102d5e:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c0102d63:	e9 50 04 00 00       	jmp    c01031b8 <__alltraps>

c0102d68 <vector164>:
.globl vector164
vector164:
  pushl $0
c0102d68:	6a 00                	push   $0x0
  pushl $164
c0102d6a:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c0102d6f:	e9 44 04 00 00       	jmp    c01031b8 <__alltraps>

c0102d74 <vector165>:
.globl vector165
vector165:
  pushl $0
c0102d74:	6a 00                	push   $0x0
  pushl $165
c0102d76:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c0102d7b:	e9 38 04 00 00       	jmp    c01031b8 <__alltraps>

c0102d80 <vector166>:
.globl vector166
vector166:
  pushl $0
c0102d80:	6a 00                	push   $0x0
  pushl $166
c0102d82:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c0102d87:	e9 2c 04 00 00       	jmp    c01031b8 <__alltraps>

c0102d8c <vector167>:
.globl vector167
vector167:
  pushl $0
c0102d8c:	6a 00                	push   $0x0
  pushl $167
c0102d8e:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c0102d93:	e9 20 04 00 00       	jmp    c01031b8 <__alltraps>

c0102d98 <vector168>:
.globl vector168
vector168:
  pushl $0
c0102d98:	6a 00                	push   $0x0
  pushl $168
c0102d9a:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c0102d9f:	e9 14 04 00 00       	jmp    c01031b8 <__alltraps>

c0102da4 <vector169>:
.globl vector169
vector169:
  pushl $0
c0102da4:	6a 00                	push   $0x0
  pushl $169
c0102da6:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c0102dab:	e9 08 04 00 00       	jmp    c01031b8 <__alltraps>

c0102db0 <vector170>:
.globl vector170
vector170:
  pushl $0
c0102db0:	6a 00                	push   $0x0
  pushl $170
c0102db2:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c0102db7:	e9 fc 03 00 00       	jmp    c01031b8 <__alltraps>

c0102dbc <vector171>:
.globl vector171
vector171:
  pushl $0
c0102dbc:	6a 00                	push   $0x0
  pushl $171
c0102dbe:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c0102dc3:	e9 f0 03 00 00       	jmp    c01031b8 <__alltraps>

c0102dc8 <vector172>:
.globl vector172
vector172:
  pushl $0
c0102dc8:	6a 00                	push   $0x0
  pushl $172
c0102dca:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c0102dcf:	e9 e4 03 00 00       	jmp    c01031b8 <__alltraps>

c0102dd4 <vector173>:
.globl vector173
vector173:
  pushl $0
c0102dd4:	6a 00                	push   $0x0
  pushl $173
c0102dd6:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c0102ddb:	e9 d8 03 00 00       	jmp    c01031b8 <__alltraps>

c0102de0 <vector174>:
.globl vector174
vector174:
  pushl $0
c0102de0:	6a 00                	push   $0x0
  pushl $174
c0102de2:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c0102de7:	e9 cc 03 00 00       	jmp    c01031b8 <__alltraps>

c0102dec <vector175>:
.globl vector175
vector175:
  pushl $0
c0102dec:	6a 00                	push   $0x0
  pushl $175
c0102dee:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c0102df3:	e9 c0 03 00 00       	jmp    c01031b8 <__alltraps>

c0102df8 <vector176>:
.globl vector176
vector176:
  pushl $0
c0102df8:	6a 00                	push   $0x0
  pushl $176
c0102dfa:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c0102dff:	e9 b4 03 00 00       	jmp    c01031b8 <__alltraps>

c0102e04 <vector177>:
.globl vector177
vector177:
  pushl $0
c0102e04:	6a 00                	push   $0x0
  pushl $177
c0102e06:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c0102e0b:	e9 a8 03 00 00       	jmp    c01031b8 <__alltraps>

c0102e10 <vector178>:
.globl vector178
vector178:
  pushl $0
c0102e10:	6a 00                	push   $0x0
  pushl $178
c0102e12:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c0102e17:	e9 9c 03 00 00       	jmp    c01031b8 <__alltraps>

c0102e1c <vector179>:
.globl vector179
vector179:
  pushl $0
c0102e1c:	6a 00                	push   $0x0
  pushl $179
c0102e1e:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c0102e23:	e9 90 03 00 00       	jmp    c01031b8 <__alltraps>

c0102e28 <vector180>:
.globl vector180
vector180:
  pushl $0
c0102e28:	6a 00                	push   $0x0
  pushl $180
c0102e2a:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c0102e2f:	e9 84 03 00 00       	jmp    c01031b8 <__alltraps>

c0102e34 <vector181>:
.globl vector181
vector181:
  pushl $0
c0102e34:	6a 00                	push   $0x0
  pushl $181
c0102e36:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c0102e3b:	e9 78 03 00 00       	jmp    c01031b8 <__alltraps>

c0102e40 <vector182>:
.globl vector182
vector182:
  pushl $0
c0102e40:	6a 00                	push   $0x0
  pushl $182
c0102e42:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c0102e47:	e9 6c 03 00 00       	jmp    c01031b8 <__alltraps>

c0102e4c <vector183>:
.globl vector183
vector183:
  pushl $0
c0102e4c:	6a 00                	push   $0x0
  pushl $183
c0102e4e:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c0102e53:	e9 60 03 00 00       	jmp    c01031b8 <__alltraps>

c0102e58 <vector184>:
.globl vector184
vector184:
  pushl $0
c0102e58:	6a 00                	push   $0x0
  pushl $184
c0102e5a:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c0102e5f:	e9 54 03 00 00       	jmp    c01031b8 <__alltraps>

c0102e64 <vector185>:
.globl vector185
vector185:
  pushl $0
c0102e64:	6a 00                	push   $0x0
  pushl $185
c0102e66:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c0102e6b:	e9 48 03 00 00       	jmp    c01031b8 <__alltraps>

c0102e70 <vector186>:
.globl vector186
vector186:
  pushl $0
c0102e70:	6a 00                	push   $0x0
  pushl $186
c0102e72:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c0102e77:	e9 3c 03 00 00       	jmp    c01031b8 <__alltraps>

c0102e7c <vector187>:
.globl vector187
vector187:
  pushl $0
c0102e7c:	6a 00                	push   $0x0
  pushl $187
c0102e7e:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c0102e83:	e9 30 03 00 00       	jmp    c01031b8 <__alltraps>

c0102e88 <vector188>:
.globl vector188
vector188:
  pushl $0
c0102e88:	6a 00                	push   $0x0
  pushl $188
c0102e8a:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c0102e8f:	e9 24 03 00 00       	jmp    c01031b8 <__alltraps>

c0102e94 <vector189>:
.globl vector189
vector189:
  pushl $0
c0102e94:	6a 00                	push   $0x0
  pushl $189
c0102e96:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c0102e9b:	e9 18 03 00 00       	jmp    c01031b8 <__alltraps>

c0102ea0 <vector190>:
.globl vector190
vector190:
  pushl $0
c0102ea0:	6a 00                	push   $0x0
  pushl $190
c0102ea2:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c0102ea7:	e9 0c 03 00 00       	jmp    c01031b8 <__alltraps>

c0102eac <vector191>:
.globl vector191
vector191:
  pushl $0
c0102eac:	6a 00                	push   $0x0
  pushl $191
c0102eae:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c0102eb3:	e9 00 03 00 00       	jmp    c01031b8 <__alltraps>

c0102eb8 <vector192>:
.globl vector192
vector192:
  pushl $0
c0102eb8:	6a 00                	push   $0x0
  pushl $192
c0102eba:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c0102ebf:	e9 f4 02 00 00       	jmp    c01031b8 <__alltraps>

c0102ec4 <vector193>:
.globl vector193
vector193:
  pushl $0
c0102ec4:	6a 00                	push   $0x0
  pushl $193
c0102ec6:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c0102ecb:	e9 e8 02 00 00       	jmp    c01031b8 <__alltraps>

c0102ed0 <vector194>:
.globl vector194
vector194:
  pushl $0
c0102ed0:	6a 00                	push   $0x0
  pushl $194
c0102ed2:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c0102ed7:	e9 dc 02 00 00       	jmp    c01031b8 <__alltraps>

c0102edc <vector195>:
.globl vector195
vector195:
  pushl $0
c0102edc:	6a 00                	push   $0x0
  pushl $195
c0102ede:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c0102ee3:	e9 d0 02 00 00       	jmp    c01031b8 <__alltraps>

c0102ee8 <vector196>:
.globl vector196
vector196:
  pushl $0
c0102ee8:	6a 00                	push   $0x0
  pushl $196
c0102eea:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c0102eef:	e9 c4 02 00 00       	jmp    c01031b8 <__alltraps>

c0102ef4 <vector197>:
.globl vector197
vector197:
  pushl $0
c0102ef4:	6a 00                	push   $0x0
  pushl $197
c0102ef6:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c0102efb:	e9 b8 02 00 00       	jmp    c01031b8 <__alltraps>

c0102f00 <vector198>:
.globl vector198
vector198:
  pushl $0
c0102f00:	6a 00                	push   $0x0
  pushl $198
c0102f02:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c0102f07:	e9 ac 02 00 00       	jmp    c01031b8 <__alltraps>

c0102f0c <vector199>:
.globl vector199
vector199:
  pushl $0
c0102f0c:	6a 00                	push   $0x0
  pushl $199
c0102f0e:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c0102f13:	e9 a0 02 00 00       	jmp    c01031b8 <__alltraps>

c0102f18 <vector200>:
.globl vector200
vector200:
  pushl $0
c0102f18:	6a 00                	push   $0x0
  pushl $200
c0102f1a:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c0102f1f:	e9 94 02 00 00       	jmp    c01031b8 <__alltraps>

c0102f24 <vector201>:
.globl vector201
vector201:
  pushl $0
c0102f24:	6a 00                	push   $0x0
  pushl $201
c0102f26:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c0102f2b:	e9 88 02 00 00       	jmp    c01031b8 <__alltraps>

c0102f30 <vector202>:
.globl vector202
vector202:
  pushl $0
c0102f30:	6a 00                	push   $0x0
  pushl $202
c0102f32:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c0102f37:	e9 7c 02 00 00       	jmp    c01031b8 <__alltraps>

c0102f3c <vector203>:
.globl vector203
vector203:
  pushl $0
c0102f3c:	6a 00                	push   $0x0
  pushl $203
c0102f3e:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c0102f43:	e9 70 02 00 00       	jmp    c01031b8 <__alltraps>

c0102f48 <vector204>:
.globl vector204
vector204:
  pushl $0
c0102f48:	6a 00                	push   $0x0
  pushl $204
c0102f4a:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c0102f4f:	e9 64 02 00 00       	jmp    c01031b8 <__alltraps>

c0102f54 <vector205>:
.globl vector205
vector205:
  pushl $0
c0102f54:	6a 00                	push   $0x0
  pushl $205
c0102f56:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c0102f5b:	e9 58 02 00 00       	jmp    c01031b8 <__alltraps>

c0102f60 <vector206>:
.globl vector206
vector206:
  pushl $0
c0102f60:	6a 00                	push   $0x0
  pushl $206
c0102f62:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c0102f67:	e9 4c 02 00 00       	jmp    c01031b8 <__alltraps>

c0102f6c <vector207>:
.globl vector207
vector207:
  pushl $0
c0102f6c:	6a 00                	push   $0x0
  pushl $207
c0102f6e:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c0102f73:	e9 40 02 00 00       	jmp    c01031b8 <__alltraps>

c0102f78 <vector208>:
.globl vector208
vector208:
  pushl $0
c0102f78:	6a 00                	push   $0x0
  pushl $208
c0102f7a:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c0102f7f:	e9 34 02 00 00       	jmp    c01031b8 <__alltraps>

c0102f84 <vector209>:
.globl vector209
vector209:
  pushl $0
c0102f84:	6a 00                	push   $0x0
  pushl $209
c0102f86:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c0102f8b:	e9 28 02 00 00       	jmp    c01031b8 <__alltraps>

c0102f90 <vector210>:
.globl vector210
vector210:
  pushl $0
c0102f90:	6a 00                	push   $0x0
  pushl $210
c0102f92:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c0102f97:	e9 1c 02 00 00       	jmp    c01031b8 <__alltraps>

c0102f9c <vector211>:
.globl vector211
vector211:
  pushl $0
c0102f9c:	6a 00                	push   $0x0
  pushl $211
c0102f9e:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c0102fa3:	e9 10 02 00 00       	jmp    c01031b8 <__alltraps>

c0102fa8 <vector212>:
.globl vector212
vector212:
  pushl $0
c0102fa8:	6a 00                	push   $0x0
  pushl $212
c0102faa:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c0102faf:	e9 04 02 00 00       	jmp    c01031b8 <__alltraps>

c0102fb4 <vector213>:
.globl vector213
vector213:
  pushl $0
c0102fb4:	6a 00                	push   $0x0
  pushl $213
c0102fb6:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c0102fbb:	e9 f8 01 00 00       	jmp    c01031b8 <__alltraps>

c0102fc0 <vector214>:
.globl vector214
vector214:
  pushl $0
c0102fc0:	6a 00                	push   $0x0
  pushl $214
c0102fc2:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c0102fc7:	e9 ec 01 00 00       	jmp    c01031b8 <__alltraps>

c0102fcc <vector215>:
.globl vector215
vector215:
  pushl $0
c0102fcc:	6a 00                	push   $0x0
  pushl $215
c0102fce:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c0102fd3:	e9 e0 01 00 00       	jmp    c01031b8 <__alltraps>

c0102fd8 <vector216>:
.globl vector216
vector216:
  pushl $0
c0102fd8:	6a 00                	push   $0x0
  pushl $216
c0102fda:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c0102fdf:	e9 d4 01 00 00       	jmp    c01031b8 <__alltraps>

c0102fe4 <vector217>:
.globl vector217
vector217:
  pushl $0
c0102fe4:	6a 00                	push   $0x0
  pushl $217
c0102fe6:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c0102feb:	e9 c8 01 00 00       	jmp    c01031b8 <__alltraps>

c0102ff0 <vector218>:
.globl vector218
vector218:
  pushl $0
c0102ff0:	6a 00                	push   $0x0
  pushl $218
c0102ff2:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c0102ff7:	e9 bc 01 00 00       	jmp    c01031b8 <__alltraps>

c0102ffc <vector219>:
.globl vector219
vector219:
  pushl $0
c0102ffc:	6a 00                	push   $0x0
  pushl $219
c0102ffe:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c0103003:	e9 b0 01 00 00       	jmp    c01031b8 <__alltraps>

c0103008 <vector220>:
.globl vector220
vector220:
  pushl $0
c0103008:	6a 00                	push   $0x0
  pushl $220
c010300a:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c010300f:	e9 a4 01 00 00       	jmp    c01031b8 <__alltraps>

c0103014 <vector221>:
.globl vector221
vector221:
  pushl $0
c0103014:	6a 00                	push   $0x0
  pushl $221
c0103016:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c010301b:	e9 98 01 00 00       	jmp    c01031b8 <__alltraps>

c0103020 <vector222>:
.globl vector222
vector222:
  pushl $0
c0103020:	6a 00                	push   $0x0
  pushl $222
c0103022:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c0103027:	e9 8c 01 00 00       	jmp    c01031b8 <__alltraps>

c010302c <vector223>:
.globl vector223
vector223:
  pushl $0
c010302c:	6a 00                	push   $0x0
  pushl $223
c010302e:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c0103033:	e9 80 01 00 00       	jmp    c01031b8 <__alltraps>

c0103038 <vector224>:
.globl vector224
vector224:
  pushl $0
c0103038:	6a 00                	push   $0x0
  pushl $224
c010303a:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c010303f:	e9 74 01 00 00       	jmp    c01031b8 <__alltraps>

c0103044 <vector225>:
.globl vector225
vector225:
  pushl $0
c0103044:	6a 00                	push   $0x0
  pushl $225
c0103046:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c010304b:	e9 68 01 00 00       	jmp    c01031b8 <__alltraps>

c0103050 <vector226>:
.globl vector226
vector226:
  pushl $0
c0103050:	6a 00                	push   $0x0
  pushl $226
c0103052:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c0103057:	e9 5c 01 00 00       	jmp    c01031b8 <__alltraps>

c010305c <vector227>:
.globl vector227
vector227:
  pushl $0
c010305c:	6a 00                	push   $0x0
  pushl $227
c010305e:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c0103063:	e9 50 01 00 00       	jmp    c01031b8 <__alltraps>

c0103068 <vector228>:
.globl vector228
vector228:
  pushl $0
c0103068:	6a 00                	push   $0x0
  pushl $228
c010306a:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c010306f:	e9 44 01 00 00       	jmp    c01031b8 <__alltraps>

c0103074 <vector229>:
.globl vector229
vector229:
  pushl $0
c0103074:	6a 00                	push   $0x0
  pushl $229
c0103076:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c010307b:	e9 38 01 00 00       	jmp    c01031b8 <__alltraps>

c0103080 <vector230>:
.globl vector230
vector230:
  pushl $0
c0103080:	6a 00                	push   $0x0
  pushl $230
c0103082:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c0103087:	e9 2c 01 00 00       	jmp    c01031b8 <__alltraps>

c010308c <vector231>:
.globl vector231
vector231:
  pushl $0
c010308c:	6a 00                	push   $0x0
  pushl $231
c010308e:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c0103093:	e9 20 01 00 00       	jmp    c01031b8 <__alltraps>

c0103098 <vector232>:
.globl vector232
vector232:
  pushl $0
c0103098:	6a 00                	push   $0x0
  pushl $232
c010309a:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c010309f:	e9 14 01 00 00       	jmp    c01031b8 <__alltraps>

c01030a4 <vector233>:
.globl vector233
vector233:
  pushl $0
c01030a4:	6a 00                	push   $0x0
  pushl $233
c01030a6:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c01030ab:	e9 08 01 00 00       	jmp    c01031b8 <__alltraps>

c01030b0 <vector234>:
.globl vector234
vector234:
  pushl $0
c01030b0:	6a 00                	push   $0x0
  pushl $234
c01030b2:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c01030b7:	e9 fc 00 00 00       	jmp    c01031b8 <__alltraps>

c01030bc <vector235>:
.globl vector235
vector235:
  pushl $0
c01030bc:	6a 00                	push   $0x0
  pushl $235
c01030be:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c01030c3:	e9 f0 00 00 00       	jmp    c01031b8 <__alltraps>

c01030c8 <vector236>:
.globl vector236
vector236:
  pushl $0
c01030c8:	6a 00                	push   $0x0
  pushl $236
c01030ca:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c01030cf:	e9 e4 00 00 00       	jmp    c01031b8 <__alltraps>

c01030d4 <vector237>:
.globl vector237
vector237:
  pushl $0
c01030d4:	6a 00                	push   $0x0
  pushl $237
c01030d6:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c01030db:	e9 d8 00 00 00       	jmp    c01031b8 <__alltraps>

c01030e0 <vector238>:
.globl vector238
vector238:
  pushl $0
c01030e0:	6a 00                	push   $0x0
  pushl $238
c01030e2:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c01030e7:	e9 cc 00 00 00       	jmp    c01031b8 <__alltraps>

c01030ec <vector239>:
.globl vector239
vector239:
  pushl $0
c01030ec:	6a 00                	push   $0x0
  pushl $239
c01030ee:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c01030f3:	e9 c0 00 00 00       	jmp    c01031b8 <__alltraps>

c01030f8 <vector240>:
.globl vector240
vector240:
  pushl $0
c01030f8:	6a 00                	push   $0x0
  pushl $240
c01030fa:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c01030ff:	e9 b4 00 00 00       	jmp    c01031b8 <__alltraps>

c0103104 <vector241>:
.globl vector241
vector241:
  pushl $0
c0103104:	6a 00                	push   $0x0
  pushl $241
c0103106:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c010310b:	e9 a8 00 00 00       	jmp    c01031b8 <__alltraps>

c0103110 <vector242>:
.globl vector242
vector242:
  pushl $0
c0103110:	6a 00                	push   $0x0
  pushl $242
c0103112:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c0103117:	e9 9c 00 00 00       	jmp    c01031b8 <__alltraps>

c010311c <vector243>:
.globl vector243
vector243:
  pushl $0
c010311c:	6a 00                	push   $0x0
  pushl $243
c010311e:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c0103123:	e9 90 00 00 00       	jmp    c01031b8 <__alltraps>

c0103128 <vector244>:
.globl vector244
vector244:
  pushl $0
c0103128:	6a 00                	push   $0x0
  pushl $244
c010312a:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c010312f:	e9 84 00 00 00       	jmp    c01031b8 <__alltraps>

c0103134 <vector245>:
.globl vector245
vector245:
  pushl $0
c0103134:	6a 00                	push   $0x0
  pushl $245
c0103136:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c010313b:	e9 78 00 00 00       	jmp    c01031b8 <__alltraps>

c0103140 <vector246>:
.globl vector246
vector246:
  pushl $0
c0103140:	6a 00                	push   $0x0
  pushl $246
c0103142:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c0103147:	e9 6c 00 00 00       	jmp    c01031b8 <__alltraps>

c010314c <vector247>:
.globl vector247
vector247:
  pushl $0
c010314c:	6a 00                	push   $0x0
  pushl $247
c010314e:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c0103153:	e9 60 00 00 00       	jmp    c01031b8 <__alltraps>

c0103158 <vector248>:
.globl vector248
vector248:
  pushl $0
c0103158:	6a 00                	push   $0x0
  pushl $248
c010315a:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c010315f:	e9 54 00 00 00       	jmp    c01031b8 <__alltraps>

c0103164 <vector249>:
.globl vector249
vector249:
  pushl $0
c0103164:	6a 00                	push   $0x0
  pushl $249
c0103166:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c010316b:	e9 48 00 00 00       	jmp    c01031b8 <__alltraps>

c0103170 <vector250>:
.globl vector250
vector250:
  pushl $0
c0103170:	6a 00                	push   $0x0
  pushl $250
c0103172:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c0103177:	e9 3c 00 00 00       	jmp    c01031b8 <__alltraps>

c010317c <vector251>:
.globl vector251
vector251:
  pushl $0
c010317c:	6a 00                	push   $0x0
  pushl $251
c010317e:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c0103183:	e9 30 00 00 00       	jmp    c01031b8 <__alltraps>

c0103188 <vector252>:
.globl vector252
vector252:
  pushl $0
c0103188:	6a 00                	push   $0x0
  pushl $252
c010318a:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c010318f:	e9 24 00 00 00       	jmp    c01031b8 <__alltraps>

c0103194 <vector253>:
.globl vector253
vector253:
  pushl $0
c0103194:	6a 00                	push   $0x0
  pushl $253
c0103196:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c010319b:	e9 18 00 00 00       	jmp    c01031b8 <__alltraps>

c01031a0 <vector254>:
.globl vector254
vector254:
  pushl $0
c01031a0:	6a 00                	push   $0x0
  pushl $254
c01031a2:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c01031a7:	e9 0c 00 00 00       	jmp    c01031b8 <__alltraps>

c01031ac <vector255>:
.globl vector255
vector255:
  pushl $0
c01031ac:	6a 00                	push   $0x0
  pushl $255
c01031ae:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c01031b3:	e9 00 00 00 00       	jmp    c01031b8 <__alltraps>

c01031b8 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c01031b8:	1e                   	push   %ds
    pushl %es
c01031b9:	06                   	push   %es
    pushl %fs
c01031ba:	0f a0                	push   %fs
    pushl %gs
c01031bc:	0f a8                	push   %gs
    pushal
c01031be:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c01031bf:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c01031c4:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c01031c6:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c01031c8:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c01031c9:	e8 60 f5 ff ff       	call   c010272e <trap>

    # pop the pushed stack pointer
    popl %esp
c01031ce:	5c                   	pop    %esp

c01031cf <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c01031cf:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c01031d0:	0f a9                	pop    %gs
    popl %fs
c01031d2:	0f a1                	pop    %fs
    popl %es
c01031d4:	07                   	pop    %es
    popl %ds
c01031d5:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c01031d6:	83 c4 08             	add    $0x8,%esp
    iret
c01031d9:	cf                   	iret   

c01031da <forkrets>:

.globl forkrets
forkrets:
    # set stack to this new process's trapframe
    movl 4(%esp), %esp
c01031da:	8b 64 24 04          	mov    0x4(%esp),%esp
    jmp __trapret
c01031de:	eb ef                	jmp    c01031cf <__trapret>

c01031e0 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c01031e0:	55                   	push   %ebp
c01031e1:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01031e3:	a1 60 e0 12 c0       	mov    0xc012e060,%eax
c01031e8:	8b 55 08             	mov    0x8(%ebp),%edx
c01031eb:	29 c2                	sub    %eax,%edx
c01031ed:	89 d0                	mov    %edx,%eax
c01031ef:	c1 f8 05             	sar    $0x5,%eax
}
c01031f2:	5d                   	pop    %ebp
c01031f3:	c3                   	ret    

c01031f4 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c01031f4:	55                   	push   %ebp
c01031f5:	89 e5                	mov    %esp,%ebp
c01031f7:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01031fa:	8b 45 08             	mov    0x8(%ebp),%eax
c01031fd:	89 04 24             	mov    %eax,(%esp)
c0103200:	e8 db ff ff ff       	call   c01031e0 <page2ppn>
c0103205:	c1 e0 0c             	shl    $0xc,%eax
}
c0103208:	c9                   	leave  
c0103209:	c3                   	ret    

c010320a <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c010320a:	55                   	push   %ebp
c010320b:	89 e5                	mov    %esp,%ebp
c010320d:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0103210:	8b 45 08             	mov    0x8(%ebp),%eax
c0103213:	c1 e8 0c             	shr    $0xc,%eax
c0103216:	89 c2                	mov    %eax,%edx
c0103218:	a1 80 bf 12 c0       	mov    0xc012bf80,%eax
c010321d:	39 c2                	cmp    %eax,%edx
c010321f:	72 1c                	jb     c010323d <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0103221:	c7 44 24 08 30 a9 10 	movl   $0xc010a930,0x8(%esp)
c0103228:	c0 
c0103229:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
c0103230:	00 
c0103231:	c7 04 24 4f a9 10 c0 	movl   $0xc010a94f,(%esp)
c0103238:	e8 00 d2 ff ff       	call   c010043d <__panic>
    }
    return &pages[PPN(pa)];
c010323d:	a1 60 e0 12 c0       	mov    0xc012e060,%eax
c0103242:	8b 55 08             	mov    0x8(%ebp),%edx
c0103245:	c1 ea 0c             	shr    $0xc,%edx
c0103248:	c1 e2 05             	shl    $0x5,%edx
c010324b:	01 d0                	add    %edx,%eax
}
c010324d:	c9                   	leave  
c010324e:	c3                   	ret    

c010324f <page2kva>:

static inline void *
page2kva(struct Page *page) {
c010324f:	55                   	push   %ebp
c0103250:	89 e5                	mov    %esp,%ebp
c0103252:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0103255:	8b 45 08             	mov    0x8(%ebp),%eax
c0103258:	89 04 24             	mov    %eax,(%esp)
c010325b:	e8 94 ff ff ff       	call   c01031f4 <page2pa>
c0103260:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103263:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103266:	c1 e8 0c             	shr    $0xc,%eax
c0103269:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010326c:	a1 80 bf 12 c0       	mov    0xc012bf80,%eax
c0103271:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0103274:	72 23                	jb     c0103299 <page2kva+0x4a>
c0103276:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103279:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010327d:	c7 44 24 08 60 a9 10 	movl   $0xc010a960,0x8(%esp)
c0103284:	c0 
c0103285:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
c010328c:	00 
c010328d:	c7 04 24 4f a9 10 c0 	movl   $0xc010a94f,(%esp)
c0103294:	e8 a4 d1 ff ff       	call   c010043d <__panic>
c0103299:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010329c:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c01032a1:	c9                   	leave  
c01032a2:	c3                   	ret    

c01032a3 <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c01032a3:	55                   	push   %ebp
c01032a4:	89 e5                	mov    %esp,%ebp
c01032a6:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c01032a9:	8b 45 08             	mov    0x8(%ebp),%eax
c01032ac:	83 e0 01             	and    $0x1,%eax
c01032af:	85 c0                	test   %eax,%eax
c01032b1:	75 1c                	jne    c01032cf <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c01032b3:	c7 44 24 08 84 a9 10 	movl   $0xc010a984,0x8(%esp)
c01032ba:	c0 
c01032bb:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
c01032c2:	00 
c01032c3:	c7 04 24 4f a9 10 c0 	movl   $0xc010a94f,(%esp)
c01032ca:	e8 6e d1 ff ff       	call   c010043d <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c01032cf:	8b 45 08             	mov    0x8(%ebp),%eax
c01032d2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01032d7:	89 04 24             	mov    %eax,(%esp)
c01032da:	e8 2b ff ff ff       	call   c010320a <pa2page>
}
c01032df:	c9                   	leave  
c01032e0:	c3                   	ret    

c01032e1 <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
c01032e1:	55                   	push   %ebp
c01032e2:	89 e5                	mov    %esp,%ebp
c01032e4:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c01032e7:	8b 45 08             	mov    0x8(%ebp),%eax
c01032ea:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01032ef:	89 04 24             	mov    %eax,(%esp)
c01032f2:	e8 13 ff ff ff       	call   c010320a <pa2page>
}
c01032f7:	c9                   	leave  
c01032f8:	c3                   	ret    

c01032f9 <page_ref>:

static inline int
page_ref(struct Page *page) {
c01032f9:	55                   	push   %ebp
c01032fa:	89 e5                	mov    %esp,%ebp
    return page->ref;
c01032fc:	8b 45 08             	mov    0x8(%ebp),%eax
c01032ff:	8b 00                	mov    (%eax),%eax
}
c0103301:	5d                   	pop    %ebp
c0103302:	c3                   	ret    

c0103303 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0103303:	55                   	push   %ebp
c0103304:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0103306:	8b 45 08             	mov    0x8(%ebp),%eax
c0103309:	8b 55 0c             	mov    0xc(%ebp),%edx
c010330c:	89 10                	mov    %edx,(%eax)
}
c010330e:	90                   	nop
c010330f:	5d                   	pop    %ebp
c0103310:	c3                   	ret    

c0103311 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c0103311:	55                   	push   %ebp
c0103312:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c0103314:	8b 45 08             	mov    0x8(%ebp),%eax
c0103317:	8b 00                	mov    (%eax),%eax
c0103319:	8d 50 01             	lea    0x1(%eax),%edx
c010331c:	8b 45 08             	mov    0x8(%ebp),%eax
c010331f:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0103321:	8b 45 08             	mov    0x8(%ebp),%eax
c0103324:	8b 00                	mov    (%eax),%eax
}
c0103326:	5d                   	pop    %ebp
c0103327:	c3                   	ret    

c0103328 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c0103328:	55                   	push   %ebp
c0103329:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c010332b:	8b 45 08             	mov    0x8(%ebp),%eax
c010332e:	8b 00                	mov    (%eax),%eax
c0103330:	8d 50 ff             	lea    -0x1(%eax),%edx
c0103333:	8b 45 08             	mov    0x8(%ebp),%eax
c0103336:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0103338:	8b 45 08             	mov    0x8(%ebp),%eax
c010333b:	8b 00                	mov    (%eax),%eax
}
c010333d:	5d                   	pop    %ebp
c010333e:	c3                   	ret    

c010333f <__intr_save>:
__intr_save(void) {
c010333f:	55                   	push   %ebp
c0103340:	89 e5                	mov    %esp,%ebp
c0103342:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0103345:	9c                   	pushf  
c0103346:	58                   	pop    %eax
c0103347:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c010334a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c010334d:	25 00 02 00 00       	and    $0x200,%eax
c0103352:	85 c0                	test   %eax,%eax
c0103354:	74 0c                	je     c0103362 <__intr_save+0x23>
        intr_disable();
c0103356:	e8 a9 ee ff ff       	call   c0102204 <intr_disable>
        return 1;
c010335b:	b8 01 00 00 00       	mov    $0x1,%eax
c0103360:	eb 05                	jmp    c0103367 <__intr_save+0x28>
    return 0;
c0103362:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103367:	c9                   	leave  
c0103368:	c3                   	ret    

c0103369 <__intr_restore>:
__intr_restore(bool flag) {
c0103369:	55                   	push   %ebp
c010336a:	89 e5                	mov    %esp,%ebp
c010336c:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c010336f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0103373:	74 05                	je     c010337a <__intr_restore+0x11>
        intr_enable();
c0103375:	e8 7e ee ff ff       	call   c01021f8 <intr_enable>
}
c010337a:	90                   	nop
c010337b:	c9                   	leave  
c010337c:	c3                   	ret    

c010337d <lgdt>:
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd)
{
c010337d:	55                   	push   %ebp
c010337e:	89 e5                	mov    %esp,%ebp
    asm volatile("lgdt (%0)" ::"r"(pd));
c0103380:	8b 45 08             	mov    0x8(%ebp),%eax
c0103383:	0f 01 10             	lgdtl  (%eax)
    asm volatile("movw %%ax, %%gs" ::"a"(USER_DS));
c0103386:	b8 23 00 00 00       	mov    $0x23,%eax
c010338b:	8e e8                	mov    %eax,%gs
    asm volatile("movw %%ax, %%fs" ::"a"(USER_DS));
c010338d:	b8 23 00 00 00       	mov    $0x23,%eax
c0103392:	8e e0                	mov    %eax,%fs
    asm volatile("movw %%ax, %%es" ::"a"(KERNEL_DS));
c0103394:	b8 10 00 00 00       	mov    $0x10,%eax
c0103399:	8e c0                	mov    %eax,%es
    asm volatile("movw %%ax, %%ds" ::"a"(KERNEL_DS));
c010339b:	b8 10 00 00 00       	mov    $0x10,%eax
c01033a0:	8e d8                	mov    %eax,%ds
    asm volatile("movw %%ax, %%ss" ::"a"(KERNEL_DS));
c01033a2:	b8 10 00 00 00       	mov    $0x10,%eax
c01033a7:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile("ljmp %0, $1f\n 1:\n" ::"i"(KERNEL_CS));
c01033a9:	ea b0 33 10 c0 08 00 	ljmp   $0x8,$0xc01033b0
}
c01033b0:	90                   	nop
c01033b1:	5d                   	pop    %ebp
c01033b2:	c3                   	ret    

c01033b3 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void load_esp0(uintptr_t esp0)
{
c01033b3:	f3 0f 1e fb          	endbr32 
c01033b7:	55                   	push   %ebp
c01033b8:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c01033ba:	8b 45 08             	mov    0x8(%ebp),%eax
c01033bd:	a3 a4 bf 12 c0       	mov    %eax,0xc012bfa4
}
c01033c2:	90                   	nop
c01033c3:	5d                   	pop    %ebp
c01033c4:	c3                   	ret    

c01033c5 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void)
{
c01033c5:	f3 0f 1e fb          	endbr32 
c01033c9:	55                   	push   %ebp
c01033ca:	89 e5                	mov    %esp,%ebp
c01033cc:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c01033cf:	b8 00 80 12 c0       	mov    $0xc0128000,%eax
c01033d4:	89 04 24             	mov    %eax,(%esp)
c01033d7:	e8 d7 ff ff ff       	call   c01033b3 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c01033dc:	66 c7 05 a8 bf 12 c0 	movw   $0x10,0xc012bfa8
c01033e3:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c01033e5:	66 c7 05 28 8a 12 c0 	movw   $0x68,0xc0128a28
c01033ec:	68 00 
c01033ee:	b8 a0 bf 12 c0       	mov    $0xc012bfa0,%eax
c01033f3:	0f b7 c0             	movzwl %ax,%eax
c01033f6:	66 a3 2a 8a 12 c0    	mov    %ax,0xc0128a2a
c01033fc:	b8 a0 bf 12 c0       	mov    $0xc012bfa0,%eax
c0103401:	c1 e8 10             	shr    $0x10,%eax
c0103404:	a2 2c 8a 12 c0       	mov    %al,0xc0128a2c
c0103409:	0f b6 05 2d 8a 12 c0 	movzbl 0xc0128a2d,%eax
c0103410:	24 f0                	and    $0xf0,%al
c0103412:	0c 09                	or     $0x9,%al
c0103414:	a2 2d 8a 12 c0       	mov    %al,0xc0128a2d
c0103419:	0f b6 05 2d 8a 12 c0 	movzbl 0xc0128a2d,%eax
c0103420:	24 ef                	and    $0xef,%al
c0103422:	a2 2d 8a 12 c0       	mov    %al,0xc0128a2d
c0103427:	0f b6 05 2d 8a 12 c0 	movzbl 0xc0128a2d,%eax
c010342e:	24 9f                	and    $0x9f,%al
c0103430:	a2 2d 8a 12 c0       	mov    %al,0xc0128a2d
c0103435:	0f b6 05 2d 8a 12 c0 	movzbl 0xc0128a2d,%eax
c010343c:	0c 80                	or     $0x80,%al
c010343e:	a2 2d 8a 12 c0       	mov    %al,0xc0128a2d
c0103443:	0f b6 05 2e 8a 12 c0 	movzbl 0xc0128a2e,%eax
c010344a:	24 f0                	and    $0xf0,%al
c010344c:	a2 2e 8a 12 c0       	mov    %al,0xc0128a2e
c0103451:	0f b6 05 2e 8a 12 c0 	movzbl 0xc0128a2e,%eax
c0103458:	24 ef                	and    $0xef,%al
c010345a:	a2 2e 8a 12 c0       	mov    %al,0xc0128a2e
c010345f:	0f b6 05 2e 8a 12 c0 	movzbl 0xc0128a2e,%eax
c0103466:	24 df                	and    $0xdf,%al
c0103468:	a2 2e 8a 12 c0       	mov    %al,0xc0128a2e
c010346d:	0f b6 05 2e 8a 12 c0 	movzbl 0xc0128a2e,%eax
c0103474:	0c 40                	or     $0x40,%al
c0103476:	a2 2e 8a 12 c0       	mov    %al,0xc0128a2e
c010347b:	0f b6 05 2e 8a 12 c0 	movzbl 0xc0128a2e,%eax
c0103482:	24 7f                	and    $0x7f,%al
c0103484:	a2 2e 8a 12 c0       	mov    %al,0xc0128a2e
c0103489:	b8 a0 bf 12 c0       	mov    $0xc012bfa0,%eax
c010348e:	c1 e8 18             	shr    $0x18,%eax
c0103491:	a2 2f 8a 12 c0       	mov    %al,0xc0128a2f

    // reload all segment registers
    lgdt(&gdt_pd);
c0103496:	c7 04 24 30 8a 12 c0 	movl   $0xc0128a30,(%esp)
c010349d:	e8 db fe ff ff       	call   c010337d <lgdt>
c01034a2:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c01034a8:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c01034ac:	0f 00 d8             	ltr    %ax
}
c01034af:	90                   	nop

    // load the TSS
    ltr(GD_TSS);
}
c01034b0:	90                   	nop
c01034b1:	c9                   	leave  
c01034b2:	c3                   	ret    

c01034b3 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void)
{
c01034b3:	f3 0f 1e fb          	endbr32 
c01034b7:	55                   	push   %ebp
c01034b8:	89 e5                	mov    %esp,%ebp
c01034ba:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c01034bd:	c7 05 58 e0 12 c0 dc 	movl   $0xc010bedc,0xc012e058
c01034c4:	be 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c01034c7:	a1 58 e0 12 c0       	mov    0xc012e058,%eax
c01034cc:	8b 00                	mov    (%eax),%eax
c01034ce:	89 44 24 04          	mov    %eax,0x4(%esp)
c01034d2:	c7 04 24 b0 a9 10 c0 	movl   $0xc010a9b0,(%esp)
c01034d9:	e8 f3 cd ff ff       	call   c01002d1 <cprintf>
    pmm_manager->init();
c01034de:	a1 58 e0 12 c0       	mov    0xc012e058,%eax
c01034e3:	8b 40 04             	mov    0x4(%eax),%eax
c01034e6:	ff d0                	call   *%eax
}
c01034e8:	90                   	nop
c01034e9:	c9                   	leave  
c01034ea:	c3                   	ret    

c01034eb <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory
static void
init_memmap(struct Page *base, size_t n)
{
c01034eb:	f3 0f 1e fb          	endbr32 
c01034ef:	55                   	push   %ebp
c01034f0:	89 e5                	mov    %esp,%ebp
c01034f2:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c01034f5:	a1 58 e0 12 c0       	mov    0xc012e058,%eax
c01034fa:	8b 40 08             	mov    0x8(%eax),%eax
c01034fd:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103500:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103504:	8b 55 08             	mov    0x8(%ebp),%edx
c0103507:	89 14 24             	mov    %edx,(%esp)
c010350a:	ff d0                	call   *%eax
}
c010350c:	90                   	nop
c010350d:	c9                   	leave  
c010350e:	c3                   	ret    

c010350f <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory
struct Page *
alloc_pages(size_t n)
{
c010350f:	f3 0f 1e fb          	endbr32 
c0103513:	55                   	push   %ebp
c0103514:	89 e5                	mov    %esp,%ebp
c0103516:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = NULL;
c0103519:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;

    while (1)
    {
        local_intr_save(intr_flag);
c0103520:	e8 1a fe ff ff       	call   c010333f <__intr_save>
c0103525:	89 45 f0             	mov    %eax,-0x10(%ebp)
        {
            page = pmm_manager->alloc_pages(n);
c0103528:	a1 58 e0 12 c0       	mov    0xc012e058,%eax
c010352d:	8b 40 0c             	mov    0xc(%eax),%eax
c0103530:	8b 55 08             	mov    0x8(%ebp),%edx
c0103533:	89 14 24             	mov    %edx,(%esp)
c0103536:	ff d0                	call   *%eax
c0103538:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        local_intr_restore(intr_flag);
c010353b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010353e:	89 04 24             	mov    %eax,(%esp)
c0103541:	e8 23 fe ff ff       	call   c0103369 <__intr_restore>

        if (page != NULL || n > 1 || swap_init_ok == 0)
c0103546:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010354a:	75 2d                	jne    c0103579 <alloc_pages+0x6a>
c010354c:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
c0103550:	77 27                	ja     c0103579 <alloc_pages+0x6a>
c0103552:	a1 10 c0 12 c0       	mov    0xc012c010,%eax
c0103557:	85 c0                	test   %eax,%eax
c0103559:	74 1e                	je     c0103579 <alloc_pages+0x6a>
            break;

        extern struct mm_struct *check_mm_struct;
        //cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
c010355b:	8b 55 08             	mov    0x8(%ebp),%edx
c010355e:	a1 64 e0 12 c0       	mov    0xc012e064,%eax
c0103563:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010356a:	00 
c010356b:	89 54 24 04          	mov    %edx,0x4(%esp)
c010356f:	89 04 24             	mov    %eax,(%esp)
c0103572:	e8 52 26 00 00       	call   c0105bc9 <swap_out>
    {
c0103577:	eb a7                	jmp    c0103520 <alloc_pages+0x11>
    }
    //cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
c0103579:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010357c:	c9                   	leave  
c010357d:	c3                   	ret    

c010357e <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n)
{
c010357e:	f3 0f 1e fb          	endbr32 
c0103582:	55                   	push   %ebp
c0103583:	89 e5                	mov    %esp,%ebp
c0103585:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0103588:	e8 b2 fd ff ff       	call   c010333f <__intr_save>
c010358d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c0103590:	a1 58 e0 12 c0       	mov    0xc012e058,%eax
c0103595:	8b 40 10             	mov    0x10(%eax),%eax
c0103598:	8b 55 0c             	mov    0xc(%ebp),%edx
c010359b:	89 54 24 04          	mov    %edx,0x4(%esp)
c010359f:	8b 55 08             	mov    0x8(%ebp),%edx
c01035a2:	89 14 24             	mov    %edx,(%esp)
c01035a5:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c01035a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035aa:	89 04 24             	mov    %eax,(%esp)
c01035ad:	e8 b7 fd ff ff       	call   c0103369 <__intr_restore>
}
c01035b2:	90                   	nop
c01035b3:	c9                   	leave  
c01035b4:	c3                   	ret    

c01035b5 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE)
//of current free memory
size_t
nr_free_pages(void)
{
c01035b5:	f3 0f 1e fb          	endbr32 
c01035b9:	55                   	push   %ebp
c01035ba:	89 e5                	mov    %esp,%ebp
c01035bc:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c01035bf:	e8 7b fd ff ff       	call   c010333f <__intr_save>
c01035c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c01035c7:	a1 58 e0 12 c0       	mov    0xc012e058,%eax
c01035cc:	8b 40 14             	mov    0x14(%eax),%eax
c01035cf:	ff d0                	call   *%eax
c01035d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c01035d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035d7:	89 04 24             	mov    %eax,(%esp)
c01035da:	e8 8a fd ff ff       	call   c0103369 <__intr_restore>
    return ret;
c01035df:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c01035e2:	c9                   	leave  
c01035e3:	c3                   	ret    

c01035e4 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void)
{
c01035e4:	f3 0f 1e fb          	endbr32 
c01035e8:	55                   	push   %ebp
c01035e9:	89 e5                	mov    %esp,%ebp
c01035eb:	57                   	push   %edi
c01035ec:	56                   	push   %esi
c01035ed:	53                   	push   %ebx
c01035ee:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c01035f4:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c01035fb:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0103602:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0103609:	c7 04 24 c7 a9 10 c0 	movl   $0xc010a9c7,(%esp)
c0103610:	e8 bc cc ff ff       	call   c01002d1 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i++)
c0103615:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010361c:	e9 1a 01 00 00       	jmp    c010373b <page_init+0x157>
    {
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0103621:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103624:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103627:	89 d0                	mov    %edx,%eax
c0103629:	c1 e0 02             	shl    $0x2,%eax
c010362c:	01 d0                	add    %edx,%eax
c010362e:	c1 e0 02             	shl    $0x2,%eax
c0103631:	01 c8                	add    %ecx,%eax
c0103633:	8b 50 08             	mov    0x8(%eax),%edx
c0103636:	8b 40 04             	mov    0x4(%eax),%eax
c0103639:	89 45 a0             	mov    %eax,-0x60(%ebp)
c010363c:	89 55 a4             	mov    %edx,-0x5c(%ebp)
c010363f:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103642:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103645:	89 d0                	mov    %edx,%eax
c0103647:	c1 e0 02             	shl    $0x2,%eax
c010364a:	01 d0                	add    %edx,%eax
c010364c:	c1 e0 02             	shl    $0x2,%eax
c010364f:	01 c8                	add    %ecx,%eax
c0103651:	8b 48 0c             	mov    0xc(%eax),%ecx
c0103654:	8b 58 10             	mov    0x10(%eax),%ebx
c0103657:	8b 45 a0             	mov    -0x60(%ebp),%eax
c010365a:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c010365d:	01 c8                	add    %ecx,%eax
c010365f:	11 da                	adc    %ebx,%edx
c0103661:	89 45 98             	mov    %eax,-0x68(%ebp)
c0103664:	89 55 9c             	mov    %edx,-0x64(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0103667:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010366a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010366d:	89 d0                	mov    %edx,%eax
c010366f:	c1 e0 02             	shl    $0x2,%eax
c0103672:	01 d0                	add    %edx,%eax
c0103674:	c1 e0 02             	shl    $0x2,%eax
c0103677:	01 c8                	add    %ecx,%eax
c0103679:	83 c0 14             	add    $0x14,%eax
c010367c:	8b 00                	mov    (%eax),%eax
c010367e:	89 45 84             	mov    %eax,-0x7c(%ebp)
c0103681:	8b 45 98             	mov    -0x68(%ebp),%eax
c0103684:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0103687:	83 c0 ff             	add    $0xffffffff,%eax
c010368a:	83 d2 ff             	adc    $0xffffffff,%edx
c010368d:	89 85 78 ff ff ff    	mov    %eax,-0x88(%ebp)
c0103693:	89 95 7c ff ff ff    	mov    %edx,-0x84(%ebp)
c0103699:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010369c:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010369f:	89 d0                	mov    %edx,%eax
c01036a1:	c1 e0 02             	shl    $0x2,%eax
c01036a4:	01 d0                	add    %edx,%eax
c01036a6:	c1 e0 02             	shl    $0x2,%eax
c01036a9:	01 c8                	add    %ecx,%eax
c01036ab:	8b 48 0c             	mov    0xc(%eax),%ecx
c01036ae:	8b 58 10             	mov    0x10(%eax),%ebx
c01036b1:	8b 55 84             	mov    -0x7c(%ebp),%edx
c01036b4:	89 54 24 1c          	mov    %edx,0x1c(%esp)
c01036b8:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
c01036be:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
c01036c4:	89 44 24 14          	mov    %eax,0x14(%esp)
c01036c8:	89 54 24 18          	mov    %edx,0x18(%esp)
c01036cc:	8b 45 a0             	mov    -0x60(%ebp),%eax
c01036cf:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c01036d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01036d6:	89 54 24 10          	mov    %edx,0x10(%esp)
c01036da:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c01036de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c01036e2:	c7 04 24 d4 a9 10 c0 	movl   $0xc010a9d4,(%esp)
c01036e9:	e8 e3 cb ff ff       	call   c01002d1 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM)
c01036ee:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01036f1:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01036f4:	89 d0                	mov    %edx,%eax
c01036f6:	c1 e0 02             	shl    $0x2,%eax
c01036f9:	01 d0                	add    %edx,%eax
c01036fb:	c1 e0 02             	shl    $0x2,%eax
c01036fe:	01 c8                	add    %ecx,%eax
c0103700:	83 c0 14             	add    $0x14,%eax
c0103703:	8b 00                	mov    (%eax),%eax
c0103705:	83 f8 01             	cmp    $0x1,%eax
c0103708:	75 2e                	jne    c0103738 <page_init+0x154>
        {
            if (maxpa < end && begin < KMEMSIZE)
c010370a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010370d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103710:	3b 45 98             	cmp    -0x68(%ebp),%eax
c0103713:	89 d0                	mov    %edx,%eax
c0103715:	1b 45 9c             	sbb    -0x64(%ebp),%eax
c0103718:	73 1e                	jae    c0103738 <page_init+0x154>
c010371a:	ba ff ff ff 37       	mov    $0x37ffffff,%edx
c010371f:	b8 00 00 00 00       	mov    $0x0,%eax
c0103724:	3b 55 a0             	cmp    -0x60(%ebp),%edx
c0103727:	1b 45 a4             	sbb    -0x5c(%ebp),%eax
c010372a:	72 0c                	jb     c0103738 <page_init+0x154>
            {
                maxpa = end;
c010372c:	8b 45 98             	mov    -0x68(%ebp),%eax
c010372f:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0103732:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0103735:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i++)
c0103738:	ff 45 dc             	incl   -0x24(%ebp)
c010373b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010373e:	8b 00                	mov    (%eax),%eax
c0103740:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0103743:	0f 8c d8 fe ff ff    	jl     c0103621 <page_init+0x3d>
            }
        }
    }
    if (maxpa > KMEMSIZE)
c0103749:	ba 00 00 00 38       	mov    $0x38000000,%edx
c010374e:	b8 00 00 00 00       	mov    $0x0,%eax
c0103753:	3b 55 e0             	cmp    -0x20(%ebp),%edx
c0103756:	1b 45 e4             	sbb    -0x1c(%ebp),%eax
c0103759:	73 0e                	jae    c0103769 <page_init+0x185>
    {
        maxpa = KMEMSIZE;
c010375b:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c0103762:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c0103769:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010376c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010376f:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0103773:	c1 ea 0c             	shr    $0xc,%edx
c0103776:	a3 80 bf 12 c0       	mov    %eax,0xc012bf80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c010377b:	c7 45 c0 00 10 00 00 	movl   $0x1000,-0x40(%ebp)
c0103782:	b8 60 e1 12 c0       	mov    $0xc012e160,%eax
c0103787:	8d 50 ff             	lea    -0x1(%eax),%edx
c010378a:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010378d:	01 d0                	add    %edx,%eax
c010378f:	89 45 bc             	mov    %eax,-0x44(%ebp)
c0103792:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0103795:	ba 00 00 00 00       	mov    $0x0,%edx
c010379a:	f7 75 c0             	divl   -0x40(%ebp)
c010379d:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01037a0:	29 d0                	sub    %edx,%eax
c01037a2:	a3 60 e0 12 c0       	mov    %eax,0xc012e060

    for (i = 0; i < npage; i++)
c01037a7:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01037ae:	eb 27                	jmp    c01037d7 <page_init+0x1f3>
    {
        SetPageReserved(pages + i);
c01037b0:	a1 60 e0 12 c0       	mov    0xc012e060,%eax
c01037b5:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01037b8:	c1 e2 05             	shl    $0x5,%edx
c01037bb:	01 d0                	add    %edx,%eax
c01037bd:	83 c0 04             	add    $0x4,%eax
c01037c0:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
c01037c7:	89 45 90             	mov    %eax,-0x70(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01037ca:	8b 45 90             	mov    -0x70(%ebp),%eax
c01037cd:	8b 55 94             	mov    -0x6c(%ebp),%edx
c01037d0:	0f ab 10             	bts    %edx,(%eax)
}
c01037d3:	90                   	nop
    for (i = 0; i < npage; i++)
c01037d4:	ff 45 dc             	incl   -0x24(%ebp)
c01037d7:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01037da:	a1 80 bf 12 c0       	mov    0xc012bf80,%eax
c01037df:	39 c2                	cmp    %eax,%edx
c01037e1:	72 cd                	jb     c01037b0 <page_init+0x1cc>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c01037e3:	a1 80 bf 12 c0       	mov    0xc012bf80,%eax
c01037e8:	c1 e0 05             	shl    $0x5,%eax
c01037eb:	89 c2                	mov    %eax,%edx
c01037ed:	a1 60 e0 12 c0       	mov    0xc012e060,%eax
c01037f2:	01 d0                	add    %edx,%eax
c01037f4:	89 45 b8             	mov    %eax,-0x48(%ebp)
c01037f7:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
c01037fe:	77 23                	ja     c0103823 <page_init+0x23f>
c0103800:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0103803:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103807:	c7 44 24 08 04 aa 10 	movl   $0xc010aa04,0x8(%esp)
c010380e:	c0 
c010380f:	c7 44 24 04 f6 00 00 	movl   $0xf6,0x4(%esp)
c0103816:	00 
c0103817:	c7 04 24 28 aa 10 c0 	movl   $0xc010aa28,(%esp)
c010381e:	e8 1a cc ff ff       	call   c010043d <__panic>
c0103823:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0103826:	05 00 00 00 40       	add    $0x40000000,%eax
c010382b:	89 45 b4             	mov    %eax,-0x4c(%ebp)

    for (i = 0; i < memmap->nr_map; i++)
c010382e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0103835:	e9 4b 01 00 00       	jmp    c0103985 <page_init+0x3a1>
    {
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c010383a:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010383d:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103840:	89 d0                	mov    %edx,%eax
c0103842:	c1 e0 02             	shl    $0x2,%eax
c0103845:	01 d0                	add    %edx,%eax
c0103847:	c1 e0 02             	shl    $0x2,%eax
c010384a:	01 c8                	add    %ecx,%eax
c010384c:	8b 50 08             	mov    0x8(%eax),%edx
c010384f:	8b 40 04             	mov    0x4(%eax),%eax
c0103852:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0103855:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0103858:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010385b:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010385e:	89 d0                	mov    %edx,%eax
c0103860:	c1 e0 02             	shl    $0x2,%eax
c0103863:	01 d0                	add    %edx,%eax
c0103865:	c1 e0 02             	shl    $0x2,%eax
c0103868:	01 c8                	add    %ecx,%eax
c010386a:	8b 48 0c             	mov    0xc(%eax),%ecx
c010386d:	8b 58 10             	mov    0x10(%eax),%ebx
c0103870:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103873:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103876:	01 c8                	add    %ecx,%eax
c0103878:	11 da                	adc    %ebx,%edx
c010387a:	89 45 c8             	mov    %eax,-0x38(%ebp)
c010387d:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM)
c0103880:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103883:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103886:	89 d0                	mov    %edx,%eax
c0103888:	c1 e0 02             	shl    $0x2,%eax
c010388b:	01 d0                	add    %edx,%eax
c010388d:	c1 e0 02             	shl    $0x2,%eax
c0103890:	01 c8                	add    %ecx,%eax
c0103892:	83 c0 14             	add    $0x14,%eax
c0103895:	8b 00                	mov    (%eax),%eax
c0103897:	83 f8 01             	cmp    $0x1,%eax
c010389a:	0f 85 e2 00 00 00    	jne    c0103982 <page_init+0x39e>
        {
            if (begin < freemem)
c01038a0:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01038a3:	ba 00 00 00 00       	mov    $0x0,%edx
c01038a8:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c01038ab:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c01038ae:	19 d1                	sbb    %edx,%ecx
c01038b0:	73 0d                	jae    c01038bf <page_init+0x2db>
            {
                begin = freemem;
c01038b2:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01038b5:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01038b8:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE)
c01038bf:	ba 00 00 00 38       	mov    $0x38000000,%edx
c01038c4:	b8 00 00 00 00       	mov    $0x0,%eax
c01038c9:	3b 55 c8             	cmp    -0x38(%ebp),%edx
c01038cc:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c01038cf:	73 0e                	jae    c01038df <page_init+0x2fb>
            {
                end = KMEMSIZE;
c01038d1:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c01038d8:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end)
c01038df:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01038e2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01038e5:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c01038e8:	89 d0                	mov    %edx,%eax
c01038ea:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c01038ed:	0f 83 8f 00 00 00    	jae    c0103982 <page_init+0x39e>
            {
                begin = ROUNDUP(begin, PGSIZE);
c01038f3:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
c01038fa:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01038fd:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0103900:	01 d0                	add    %edx,%eax
c0103902:	48                   	dec    %eax
c0103903:	89 45 ac             	mov    %eax,-0x54(%ebp)
c0103906:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0103909:	ba 00 00 00 00       	mov    $0x0,%edx
c010390e:	f7 75 b0             	divl   -0x50(%ebp)
c0103911:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0103914:	29 d0                	sub    %edx,%eax
c0103916:	ba 00 00 00 00       	mov    $0x0,%edx
c010391b:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010391e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c0103921:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103924:	89 45 a8             	mov    %eax,-0x58(%ebp)
c0103927:	8b 45 a8             	mov    -0x58(%ebp),%eax
c010392a:	ba 00 00 00 00       	mov    $0x0,%edx
c010392f:	89 c3                	mov    %eax,%ebx
c0103931:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
c0103937:	89 de                	mov    %ebx,%esi
c0103939:	89 d0                	mov    %edx,%eax
c010393b:	83 e0 00             	and    $0x0,%eax
c010393e:	89 c7                	mov    %eax,%edi
c0103940:	89 75 c8             	mov    %esi,-0x38(%ebp)
c0103943:	89 7d cc             	mov    %edi,-0x34(%ebp)
                if (begin < end)
c0103946:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103949:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010394c:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c010394f:	89 d0                	mov    %edx,%eax
c0103951:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c0103954:	73 2c                	jae    c0103982 <page_init+0x39e>
                {
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c0103956:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103959:	8b 55 cc             	mov    -0x34(%ebp),%edx
c010395c:	2b 45 d0             	sub    -0x30(%ebp),%eax
c010395f:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
c0103962:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0103966:	c1 ea 0c             	shr    $0xc,%edx
c0103969:	89 c3                	mov    %eax,%ebx
c010396b:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010396e:	89 04 24             	mov    %eax,(%esp)
c0103971:	e8 94 f8 ff ff       	call   c010320a <pa2page>
c0103976:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c010397a:	89 04 24             	mov    %eax,(%esp)
c010397d:	e8 69 fb ff ff       	call   c01034eb <init_memmap>
    for (i = 0; i < memmap->nr_map; i++)
c0103982:	ff 45 dc             	incl   -0x24(%ebp)
c0103985:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103988:	8b 00                	mov    (%eax),%eax
c010398a:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c010398d:	0f 8c a7 fe ff ff    	jl     c010383a <page_init+0x256>
                }
            }
        }
    }
}
c0103993:	90                   	nop
c0103994:	90                   	nop
c0103995:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c010399b:	5b                   	pop    %ebx
c010399c:	5e                   	pop    %esi
c010399d:	5f                   	pop    %edi
c010399e:	5d                   	pop    %ebp
c010399f:	c3                   	ret    

c01039a0 <boot_map_segment>:
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm)
{
c01039a0:	f3 0f 1e fb          	endbr32 
c01039a4:	55                   	push   %ebp
c01039a5:	89 e5                	mov    %esp,%ebp
c01039a7:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c01039aa:	8b 45 0c             	mov    0xc(%ebp),%eax
c01039ad:	33 45 14             	xor    0x14(%ebp),%eax
c01039b0:	25 ff 0f 00 00       	and    $0xfff,%eax
c01039b5:	85 c0                	test   %eax,%eax
c01039b7:	74 24                	je     c01039dd <boot_map_segment+0x3d>
c01039b9:	c7 44 24 0c 36 aa 10 	movl   $0xc010aa36,0xc(%esp)
c01039c0:	c0 
c01039c1:	c7 44 24 08 4d aa 10 	movl   $0xc010aa4d,0x8(%esp)
c01039c8:	c0 
c01039c9:	c7 44 24 04 1b 01 00 	movl   $0x11b,0x4(%esp)
c01039d0:	00 
c01039d1:	c7 04 24 28 aa 10 c0 	movl   $0xc010aa28,(%esp)
c01039d8:	e8 60 ca ff ff       	call   c010043d <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c01039dd:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c01039e4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01039e7:	25 ff 0f 00 00       	and    $0xfff,%eax
c01039ec:	89 c2                	mov    %eax,%edx
c01039ee:	8b 45 10             	mov    0x10(%ebp),%eax
c01039f1:	01 c2                	add    %eax,%edx
c01039f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01039f6:	01 d0                	add    %edx,%eax
c01039f8:	48                   	dec    %eax
c01039f9:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01039fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01039ff:	ba 00 00 00 00       	mov    $0x0,%edx
c0103a04:	f7 75 f0             	divl   -0x10(%ebp)
c0103a07:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103a0a:	29 d0                	sub    %edx,%eax
c0103a0c:	c1 e8 0c             	shr    $0xc,%eax
c0103a0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c0103a12:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103a15:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103a18:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103a1b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103a20:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c0103a23:	8b 45 14             	mov    0x14(%ebp),%eax
c0103a26:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103a29:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103a2c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103a31:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n--, la += PGSIZE, pa += PGSIZE)
c0103a34:	eb 68                	jmp    c0103a9e <boot_map_segment+0xfe>
    {
        pte_t *ptep = get_pte(pgdir, la, 1);
c0103a36:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0103a3d:	00 
c0103a3e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103a41:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103a45:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a48:	89 04 24             	mov    %eax,(%esp)
c0103a4b:	e8 8f 01 00 00       	call   c0103bdf <get_pte>
c0103a50:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c0103a53:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0103a57:	75 24                	jne    c0103a7d <boot_map_segment+0xdd>
c0103a59:	c7 44 24 0c 62 aa 10 	movl   $0xc010aa62,0xc(%esp)
c0103a60:	c0 
c0103a61:	c7 44 24 08 4d aa 10 	movl   $0xc010aa4d,0x8(%esp)
c0103a68:	c0 
c0103a69:	c7 44 24 04 22 01 00 	movl   $0x122,0x4(%esp)
c0103a70:	00 
c0103a71:	c7 04 24 28 aa 10 c0 	movl   $0xc010aa28,(%esp)
c0103a78:	e8 c0 c9 ff ff       	call   c010043d <__panic>
        *ptep = pa | PTE_P | perm;
c0103a7d:	8b 45 14             	mov    0x14(%ebp),%eax
c0103a80:	0b 45 18             	or     0x18(%ebp),%eax
c0103a83:	83 c8 01             	or     $0x1,%eax
c0103a86:	89 c2                	mov    %eax,%edx
c0103a88:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103a8b:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n--, la += PGSIZE, pa += PGSIZE)
c0103a8d:	ff 4d f4             	decl   -0xc(%ebp)
c0103a90:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c0103a97:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c0103a9e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103aa2:	75 92                	jne    c0103a36 <boot_map_segment+0x96>
    }
}
c0103aa4:	90                   	nop
c0103aa5:	90                   	nop
c0103aa6:	c9                   	leave  
c0103aa7:	c3                   	ret    

c0103aa8 <boot_alloc_page>:
//boot_alloc_page - allocate one page using pmm->alloc_pages(1)
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void)
{
c0103aa8:	f3 0f 1e fb          	endbr32 
c0103aac:	55                   	push   %ebp
c0103aad:	89 e5                	mov    %esp,%ebp
c0103aaf:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c0103ab2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103ab9:	e8 51 fa ff ff       	call   c010350f <alloc_pages>
c0103abe:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL)
c0103ac1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103ac5:	75 1c                	jne    c0103ae3 <boot_alloc_page+0x3b>
    {
        panic("boot_alloc_page failed.\n");
c0103ac7:	c7 44 24 08 6f aa 10 	movl   $0xc010aa6f,0x8(%esp)
c0103ace:	c0 
c0103acf:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
c0103ad6:	00 
c0103ad7:	c7 04 24 28 aa 10 c0 	movl   $0xc010aa28,(%esp)
c0103ade:	e8 5a c9 ff ff       	call   c010043d <__panic>
    }
    return page2kva(p);
c0103ae3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103ae6:	89 04 24             	mov    %eax,(%esp)
c0103ae9:	e8 61 f7 ff ff       	call   c010324f <page2kva>
}
c0103aee:	c9                   	leave  
c0103aef:	c3                   	ret    

c0103af0 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void pmm_init(void)
{
c0103af0:	f3 0f 1e fb          	endbr32 
c0103af4:	55                   	push   %ebp
c0103af5:	89 e5                	mov    %esp,%ebp
c0103af7:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c0103afa:	a1 e0 89 12 c0       	mov    0xc01289e0,%eax
c0103aff:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103b02:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0103b09:	77 23                	ja     c0103b2e <pmm_init+0x3e>
c0103b0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b0e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103b12:	c7 44 24 08 04 aa 10 	movl   $0xc010aa04,0x8(%esp)
c0103b19:	c0 
c0103b1a:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
c0103b21:	00 
c0103b22:	c7 04 24 28 aa 10 c0 	movl   $0xc010aa28,(%esp)
c0103b29:	e8 0f c9 ff ff       	call   c010043d <__panic>
c0103b2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b31:	05 00 00 00 40       	add    $0x40000000,%eax
c0103b36:	a3 5c e0 12 c0       	mov    %eax,0xc012e05c
    //We need to alloc/free the physical memory (granularity is 4KB or other size).
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory.
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c0103b3b:	e8 73 f9 ff ff       	call   c01034b3 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c0103b40:	e8 9f fa ff ff       	call   c01035e4 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c0103b45:	e8 c7 04 00 00       	call   c0104011 <check_alloc_page>

    check_pgdir();
c0103b4a:	e8 e5 04 00 00       	call   c0104034 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c0103b4f:	a1 e0 89 12 c0       	mov    0xc01289e0,%eax
c0103b54:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103b57:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0103b5e:	77 23                	ja     c0103b83 <pmm_init+0x93>
c0103b60:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103b63:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103b67:	c7 44 24 08 04 aa 10 	movl   $0xc010aa04,0x8(%esp)
c0103b6e:	c0 
c0103b6f:	c7 44 24 04 50 01 00 	movl   $0x150,0x4(%esp)
c0103b76:	00 
c0103b77:	c7 04 24 28 aa 10 c0 	movl   $0xc010aa28,(%esp)
c0103b7e:	e8 ba c8 ff ff       	call   c010043d <__panic>
c0103b83:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103b86:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c0103b8c:	a1 e0 89 12 c0       	mov    0xc01289e0,%eax
c0103b91:	05 ac 0f 00 00       	add    $0xfac,%eax
c0103b96:	83 ca 03             	or     $0x3,%edx
c0103b99:	89 10                	mov    %edx,(%eax)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c0103b9b:	a1 e0 89 12 c0       	mov    0xc01289e0,%eax
c0103ba0:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c0103ba7:	00 
c0103ba8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0103baf:	00 
c0103bb0:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c0103bb7:	38 
c0103bb8:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c0103bbf:	c0 
c0103bc0:	89 04 24             	mov    %eax,(%esp)
c0103bc3:	e8 d8 fd ff ff       	call   c01039a0 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c0103bc8:	e8 f8 f7 ff ff       	call   c01033c5 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c0103bcd:	e8 02 0b 00 00       	call   c01046d4 <check_boot_pgdir>

    print_pgdir();
c0103bd2:	e8 87 0f 00 00       	call   c0104b5e <print_pgdir>

    kmalloc_init();
c0103bd7:	e8 37 2f 00 00       	call   c0106b13 <kmalloc_init>
}
c0103bdc:	90                   	nop
c0103bdd:	c9                   	leave  
c0103bde:	c3                   	ret    

c0103bdf <get_pte>:
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create)
{
c0103bdf:	f3 0f 1e fb          	endbr32 
c0103be3:	55                   	push   %ebp
c0103be4:	89 e5                	mov    %esp,%ebp
c0103be6:	83 ec 38             	sub    $0x38,%esp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
    pde_t *pdep = &pgdir[PDX(la)];
c0103be9:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103bec:	c1 e8 16             	shr    $0x16,%eax
c0103bef:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0103bf6:	8b 45 08             	mov    0x8(%ebp),%eax
c0103bf9:	01 d0                	add    %edx,%eax
c0103bfb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P))
c0103bfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103c01:	8b 00                	mov    (%eax),%eax
c0103c03:	83 e0 01             	and    $0x1,%eax
c0103c06:	85 c0                	test   %eax,%eax
c0103c08:	0f 85 af 00 00 00    	jne    c0103cbd <get_pte+0xde>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
c0103c0e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0103c12:	74 15                	je     c0103c29 <get_pte+0x4a>
c0103c14:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103c1b:	e8 ef f8 ff ff       	call   c010350f <alloc_pages>
c0103c20:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103c23:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103c27:	75 0a                	jne    c0103c33 <get_pte+0x54>
        {
            return NULL;
c0103c29:	b8 00 00 00 00       	mov    $0x0,%eax
c0103c2e:	e9 e7 00 00 00       	jmp    c0103d1a <get_pte+0x13b>
        }
        set_page_ref(page, 1);
c0103c33:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103c3a:	00 
c0103c3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103c3e:	89 04 24             	mov    %eax,(%esp)
c0103c41:	e8 bd f6 ff ff       	call   c0103303 <set_page_ref>
        uintptr_t pa = page2pa(page);
c0103c46:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103c49:	89 04 24             	mov    %eax,(%esp)
c0103c4c:	e8 a3 f5 ff ff       	call   c01031f4 <page2pa>
c0103c51:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE);
c0103c54:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103c57:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103c5a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103c5d:	c1 e8 0c             	shr    $0xc,%eax
c0103c60:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103c63:	a1 80 bf 12 c0       	mov    0xc012bf80,%eax
c0103c68:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c0103c6b:	72 23                	jb     c0103c90 <get_pte+0xb1>
c0103c6d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103c70:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103c74:	c7 44 24 08 60 a9 10 	movl   $0xc010a960,0x8(%esp)
c0103c7b:	c0 
c0103c7c:	c7 44 24 04 9a 01 00 	movl   $0x19a,0x4(%esp)
c0103c83:	00 
c0103c84:	c7 04 24 28 aa 10 c0 	movl   $0xc010aa28,(%esp)
c0103c8b:	e8 ad c7 ff ff       	call   c010043d <__panic>
c0103c90:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103c93:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0103c98:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0103c9f:	00 
c0103ca0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103ca7:	00 
c0103ca8:	89 04 24             	mov    %eax,(%esp)
c0103cab:	e8 12 5a 00 00       	call   c01096c2 <memset>
        *pdep = pa | PTE_U | PTE_W | PTE_P;
c0103cb0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103cb3:	83 c8 07             	or     $0x7,%eax
c0103cb6:	89 c2                	mov    %eax,%edx
c0103cb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103cbb:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
c0103cbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103cc0:	8b 00                	mov    (%eax),%eax
c0103cc2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103cc7:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0103cca:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103ccd:	c1 e8 0c             	shr    $0xc,%eax
c0103cd0:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0103cd3:	a1 80 bf 12 c0       	mov    0xc012bf80,%eax
c0103cd8:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0103cdb:	72 23                	jb     c0103d00 <get_pte+0x121>
c0103cdd:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103ce0:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103ce4:	c7 44 24 08 60 a9 10 	movl   $0xc010a960,0x8(%esp)
c0103ceb:	c0 
c0103cec:	c7 44 24 04 9d 01 00 	movl   $0x19d,0x4(%esp)
c0103cf3:	00 
c0103cf4:	c7 04 24 28 aa 10 c0 	movl   $0xc010aa28,(%esp)
c0103cfb:	e8 3d c7 ff ff       	call   c010043d <__panic>
c0103d00:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103d03:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0103d08:	89 c2                	mov    %eax,%edx
c0103d0a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103d0d:	c1 e8 0c             	shr    $0xc,%eax
c0103d10:	25 ff 03 00 00       	and    $0x3ff,%eax
c0103d15:	c1 e0 02             	shl    $0x2,%eax
c0103d18:	01 d0                	add    %edx,%eax
}
c0103d1a:	c9                   	leave  
c0103d1b:	c3                   	ret    

c0103d1c <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store)
{
c0103d1c:	f3 0f 1e fb          	endbr32 
c0103d20:	55                   	push   %ebp
c0103d21:	89 e5                	mov    %esp,%ebp
c0103d23:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0103d26:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103d2d:	00 
c0103d2e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103d31:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103d35:	8b 45 08             	mov    0x8(%ebp),%eax
c0103d38:	89 04 24             	mov    %eax,(%esp)
c0103d3b:	e8 9f fe ff ff       	call   c0103bdf <get_pte>
c0103d40:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL)
c0103d43:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0103d47:	74 08                	je     c0103d51 <get_page+0x35>
    {
        *ptep_store = ptep;
c0103d49:	8b 45 10             	mov    0x10(%ebp),%eax
c0103d4c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103d4f:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P)
c0103d51:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103d55:	74 1b                	je     c0103d72 <get_page+0x56>
c0103d57:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103d5a:	8b 00                	mov    (%eax),%eax
c0103d5c:	83 e0 01             	and    $0x1,%eax
c0103d5f:	85 c0                	test   %eax,%eax
c0103d61:	74 0f                	je     c0103d72 <get_page+0x56>
    {
        return pte2page(*ptep);
c0103d63:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103d66:	8b 00                	mov    (%eax),%eax
c0103d68:	89 04 24             	mov    %eax,(%esp)
c0103d6b:	e8 33 f5 ff ff       	call   c01032a3 <pte2page>
c0103d70:	eb 05                	jmp    c0103d77 <get_page+0x5b>
    }
    return NULL;
c0103d72:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103d77:	c9                   	leave  
c0103d78:	c3                   	ret    

c0103d79 <page_remove_pte>:
//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep)
{
c0103d79:	55                   	push   %ebp
c0103d7a:	89 e5                	mov    %esp,%ebp
c0103d7c:	83 ec 28             	sub    $0x28,%esp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
    if (*ptep & PTE_P)
c0103d7f:	8b 45 10             	mov    0x10(%ebp),%eax
c0103d82:	8b 00                	mov    (%eax),%eax
c0103d84:	83 e0 01             	and    $0x1,%eax
c0103d87:	85 c0                	test   %eax,%eax
c0103d89:	74 4d                	je     c0103dd8 <page_remove_pte+0x5f>
    {
        struct Page *page = pte2page(*ptep);
c0103d8b:	8b 45 10             	mov    0x10(%ebp),%eax
c0103d8e:	8b 00                	mov    (%eax),%eax
c0103d90:	89 04 24             	mov    %eax,(%esp)
c0103d93:	e8 0b f5 ff ff       	call   c01032a3 <pte2page>
c0103d98:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0)
c0103d9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103d9e:	89 04 24             	mov    %eax,(%esp)
c0103da1:	e8 82 f5 ff ff       	call   c0103328 <page_ref_dec>
c0103da6:	85 c0                	test   %eax,%eax
c0103da8:	75 13                	jne    c0103dbd <page_remove_pte+0x44>
        {
            free_page(page);
c0103daa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103db1:	00 
c0103db2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103db5:	89 04 24             	mov    %eax,(%esp)
c0103db8:	e8 c1 f7 ff ff       	call   c010357e <free_pages>
        }
        *ptep = 0;
c0103dbd:	8b 45 10             	mov    0x10(%ebp),%eax
c0103dc0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
c0103dc6:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103dc9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103dcd:	8b 45 08             	mov    0x8(%ebp),%eax
c0103dd0:	89 04 24             	mov    %eax,(%esp)
c0103dd3:	e8 09 01 00 00       	call   c0103ee1 <tlb_invalidate>
    }
}
c0103dd8:	90                   	nop
c0103dd9:	c9                   	leave  
c0103dda:	c3                   	ret    

c0103ddb <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void page_remove(pde_t *pgdir, uintptr_t la)
{
c0103ddb:	f3 0f 1e fb          	endbr32 
c0103ddf:	55                   	push   %ebp
c0103de0:	89 e5                	mov    %esp,%ebp
c0103de2:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0103de5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103dec:	00 
c0103ded:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103df0:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103df4:	8b 45 08             	mov    0x8(%ebp),%eax
c0103df7:	89 04 24             	mov    %eax,(%esp)
c0103dfa:	e8 e0 fd ff ff       	call   c0103bdf <get_pte>
c0103dff:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL)
c0103e02:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103e06:	74 19                	je     c0103e21 <page_remove+0x46>
    {
        page_remove_pte(pgdir, la, ptep);
c0103e08:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103e0b:	89 44 24 08          	mov    %eax,0x8(%esp)
c0103e0f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103e12:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103e16:	8b 45 08             	mov    0x8(%ebp),%eax
c0103e19:	89 04 24             	mov    %eax,(%esp)
c0103e1c:	e8 58 ff ff ff       	call   c0103d79 <page_remove_pte>
    }
}
c0103e21:	90                   	nop
c0103e22:	c9                   	leave  
c0103e23:	c3                   	ret    

c0103e24 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm)
{
c0103e24:	f3 0f 1e fb          	endbr32 
c0103e28:	55                   	push   %ebp
c0103e29:	89 e5                	mov    %esp,%ebp
c0103e2b:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c0103e2e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0103e35:	00 
c0103e36:	8b 45 10             	mov    0x10(%ebp),%eax
c0103e39:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103e3d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103e40:	89 04 24             	mov    %eax,(%esp)
c0103e43:	e8 97 fd ff ff       	call   c0103bdf <get_pte>
c0103e48:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL)
c0103e4b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103e4f:	75 0a                	jne    c0103e5b <page_insert+0x37>
    {
        return -E_NO_MEM;
c0103e51:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0103e56:	e9 84 00 00 00       	jmp    c0103edf <page_insert+0xbb>
    }
    page_ref_inc(page);
c0103e5b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103e5e:	89 04 24             	mov    %eax,(%esp)
c0103e61:	e8 ab f4 ff ff       	call   c0103311 <page_ref_inc>
    if (*ptep & PTE_P)
c0103e66:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103e69:	8b 00                	mov    (%eax),%eax
c0103e6b:	83 e0 01             	and    $0x1,%eax
c0103e6e:	85 c0                	test   %eax,%eax
c0103e70:	74 3e                	je     c0103eb0 <page_insert+0x8c>
    {
        struct Page *p = pte2page(*ptep);
c0103e72:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103e75:	8b 00                	mov    (%eax),%eax
c0103e77:	89 04 24             	mov    %eax,(%esp)
c0103e7a:	e8 24 f4 ff ff       	call   c01032a3 <pte2page>
c0103e7f:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page)
c0103e82:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103e85:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0103e88:	75 0d                	jne    c0103e97 <page_insert+0x73>
        {
            page_ref_dec(page);
c0103e8a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103e8d:	89 04 24             	mov    %eax,(%esp)
c0103e90:	e8 93 f4 ff ff       	call   c0103328 <page_ref_dec>
c0103e95:	eb 19                	jmp    c0103eb0 <page_insert+0x8c>
        }
        else
        {
            page_remove_pte(pgdir, la, ptep);
c0103e97:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103e9a:	89 44 24 08          	mov    %eax,0x8(%esp)
c0103e9e:	8b 45 10             	mov    0x10(%ebp),%eax
c0103ea1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103ea5:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ea8:	89 04 24             	mov    %eax,(%esp)
c0103eab:	e8 c9 fe ff ff       	call   c0103d79 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c0103eb0:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103eb3:	89 04 24             	mov    %eax,(%esp)
c0103eb6:	e8 39 f3 ff ff       	call   c01031f4 <page2pa>
c0103ebb:	0b 45 14             	or     0x14(%ebp),%eax
c0103ebe:	83 c8 01             	or     $0x1,%eax
c0103ec1:	89 c2                	mov    %eax,%edx
c0103ec3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103ec6:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c0103ec8:	8b 45 10             	mov    0x10(%ebp),%eax
c0103ecb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103ecf:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ed2:	89 04 24             	mov    %eax,(%esp)
c0103ed5:	e8 07 00 00 00       	call   c0103ee1 <tlb_invalidate>
    return 0;
c0103eda:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103edf:	c9                   	leave  
c0103ee0:	c3                   	ret    

c0103ee1 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la)
{
c0103ee1:	f3 0f 1e fb          	endbr32 
c0103ee5:	55                   	push   %ebp
c0103ee6:	89 e5                	mov    %esp,%ebp
c0103ee8:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c0103eeb:	0f 20 d8             	mov    %cr3,%eax
c0103eee:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c0103ef1:	8b 55 f0             	mov    -0x10(%ebp),%edx
    if (rcr3() == PADDR(pgdir))
c0103ef4:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ef7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103efa:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0103f01:	77 23                	ja     c0103f26 <tlb_invalidate+0x45>
c0103f03:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103f06:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103f0a:	c7 44 24 08 04 aa 10 	movl   $0xc010aa04,0x8(%esp)
c0103f11:	c0 
c0103f12:	c7 44 24 04 0a 02 00 	movl   $0x20a,0x4(%esp)
c0103f19:	00 
c0103f1a:	c7 04 24 28 aa 10 c0 	movl   $0xc010aa28,(%esp)
c0103f21:	e8 17 c5 ff ff       	call   c010043d <__panic>
c0103f26:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103f29:	05 00 00 00 40       	add    $0x40000000,%eax
c0103f2e:	39 d0                	cmp    %edx,%eax
c0103f30:	75 0d                	jne    c0103f3f <tlb_invalidate+0x5e>
    {
        invlpg((void *)la);
c0103f32:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103f35:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c0103f38:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103f3b:	0f 01 38             	invlpg (%eax)
}
c0103f3e:	90                   	nop
    }
}
c0103f3f:	90                   	nop
c0103f40:	c9                   	leave  
c0103f41:	c3                   	ret    

c0103f42 <pgdir_alloc_page>:
// pgdir_alloc_page - call alloc_page & page_insert functions to
//                  - allocate a page size memory & setup an addr map
//                  - pa<->la with linear address la and the PDT pgdir
struct Page *
pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm)
{
c0103f42:	f3 0f 1e fb          	endbr32 
c0103f46:	55                   	push   %ebp
c0103f47:	89 e5                	mov    %esp,%ebp
c0103f49:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = alloc_page();
c0103f4c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103f53:	e8 b7 f5 ff ff       	call   c010350f <alloc_pages>
c0103f58:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL)
c0103f5b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103f5f:	0f 84 a7 00 00 00    	je     c010400c <pgdir_alloc_page+0xca>
    {
        if (page_insert(pgdir, page, la, perm) != 0)
c0103f65:	8b 45 10             	mov    0x10(%ebp),%eax
c0103f68:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103f6c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103f6f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0103f73:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103f76:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103f7a:	8b 45 08             	mov    0x8(%ebp),%eax
c0103f7d:	89 04 24             	mov    %eax,(%esp)
c0103f80:	e8 9f fe ff ff       	call   c0103e24 <page_insert>
c0103f85:	85 c0                	test   %eax,%eax
c0103f87:	74 1a                	je     c0103fa3 <pgdir_alloc_page+0x61>
        {
            free_page(page);
c0103f89:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103f90:	00 
c0103f91:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103f94:	89 04 24             	mov    %eax,(%esp)
c0103f97:	e8 e2 f5 ff ff       	call   c010357e <free_pages>
            return NULL;
c0103f9c:	b8 00 00 00 00       	mov    $0x0,%eax
c0103fa1:	eb 6c                	jmp    c010400f <pgdir_alloc_page+0xcd>
        }
        if (swap_init_ok)
c0103fa3:	a1 10 c0 12 c0       	mov    0xc012c010,%eax
c0103fa8:	85 c0                	test   %eax,%eax
c0103faa:	74 60                	je     c010400c <pgdir_alloc_page+0xca>
        {
            swap_map_swappable(check_mm_struct, la, page, 0);
c0103fac:	a1 64 e0 12 c0       	mov    0xc012e064,%eax
c0103fb1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0103fb8:	00 
c0103fb9:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103fbc:	89 54 24 08          	mov    %edx,0x8(%esp)
c0103fc0:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103fc3:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103fc7:	89 04 24             	mov    %eax,(%esp)
c0103fca:	e8 a6 1b 00 00       	call   c0105b75 <swap_map_swappable>
            page->pra_vaddr = la;
c0103fcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103fd2:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103fd5:	89 50 1c             	mov    %edx,0x1c(%eax)
            assert(page_ref(page) == 1);
c0103fd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103fdb:	89 04 24             	mov    %eax,(%esp)
c0103fde:	e8 16 f3 ff ff       	call   c01032f9 <page_ref>
c0103fe3:	83 f8 01             	cmp    $0x1,%eax
c0103fe6:	74 24                	je     c010400c <pgdir_alloc_page+0xca>
c0103fe8:	c7 44 24 0c 88 aa 10 	movl   $0xc010aa88,0xc(%esp)
c0103fef:	c0 
c0103ff0:	c7 44 24 08 4d aa 10 	movl   $0xc010aa4d,0x8(%esp)
c0103ff7:	c0 
c0103ff8:	c7 44 24 04 22 02 00 	movl   $0x222,0x4(%esp)
c0103fff:	00 
c0104000:	c7 04 24 28 aa 10 c0 	movl   $0xc010aa28,(%esp)
c0104007:	e8 31 c4 ff ff       	call   c010043d <__panic>
            //cprintf("get No. %d  page: pra_vaddr %x, pra_link.prev %x, pra_link_next %x in pgdir_alloc_page\n", (page-pages), page->pra_vaddr,page->pra_page_link.prev, page->pra_page_link.next);
        }
    }

    return page;
c010400c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010400f:	c9                   	leave  
c0104010:	c3                   	ret    

c0104011 <check_alloc_page>:

static void
check_alloc_page(void)
{
c0104011:	f3 0f 1e fb          	endbr32 
c0104015:	55                   	push   %ebp
c0104016:	89 e5                	mov    %esp,%ebp
c0104018:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c010401b:	a1 58 e0 12 c0       	mov    0xc012e058,%eax
c0104020:	8b 40 18             	mov    0x18(%eax),%eax
c0104023:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c0104025:	c7 04 24 9c aa 10 c0 	movl   $0xc010aa9c,(%esp)
c010402c:	e8 a0 c2 ff ff       	call   c01002d1 <cprintf>
}
c0104031:	90                   	nop
c0104032:	c9                   	leave  
c0104033:	c3                   	ret    

c0104034 <check_pgdir>:

static void
check_pgdir(void)
{
c0104034:	f3 0f 1e fb          	endbr32 
c0104038:	55                   	push   %ebp
c0104039:	89 e5                	mov    %esp,%ebp
c010403b:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c010403e:	a1 80 bf 12 c0       	mov    0xc012bf80,%eax
c0104043:	3d 00 80 03 00       	cmp    $0x38000,%eax
c0104048:	76 24                	jbe    c010406e <check_pgdir+0x3a>
c010404a:	c7 44 24 0c bb aa 10 	movl   $0xc010aabb,0xc(%esp)
c0104051:	c0 
c0104052:	c7 44 24 08 4d aa 10 	movl   $0xc010aa4d,0x8(%esp)
c0104059:	c0 
c010405a:	c7 44 24 04 34 02 00 	movl   $0x234,0x4(%esp)
c0104061:	00 
c0104062:	c7 04 24 28 aa 10 c0 	movl   $0xc010aa28,(%esp)
c0104069:	e8 cf c3 ff ff       	call   c010043d <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c010406e:	a1 e0 89 12 c0       	mov    0xc01289e0,%eax
c0104073:	85 c0                	test   %eax,%eax
c0104075:	74 0e                	je     c0104085 <check_pgdir+0x51>
c0104077:	a1 e0 89 12 c0       	mov    0xc01289e0,%eax
c010407c:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104081:	85 c0                	test   %eax,%eax
c0104083:	74 24                	je     c01040a9 <check_pgdir+0x75>
c0104085:	c7 44 24 0c d8 aa 10 	movl   $0xc010aad8,0xc(%esp)
c010408c:	c0 
c010408d:	c7 44 24 08 4d aa 10 	movl   $0xc010aa4d,0x8(%esp)
c0104094:	c0 
c0104095:	c7 44 24 04 35 02 00 	movl   $0x235,0x4(%esp)
c010409c:	00 
c010409d:	c7 04 24 28 aa 10 c0 	movl   $0xc010aa28,(%esp)
c01040a4:	e8 94 c3 ff ff       	call   c010043d <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c01040a9:	a1 e0 89 12 c0       	mov    0xc01289e0,%eax
c01040ae:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01040b5:	00 
c01040b6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01040bd:	00 
c01040be:	89 04 24             	mov    %eax,(%esp)
c01040c1:	e8 56 fc ff ff       	call   c0103d1c <get_page>
c01040c6:	85 c0                	test   %eax,%eax
c01040c8:	74 24                	je     c01040ee <check_pgdir+0xba>
c01040ca:	c7 44 24 0c 10 ab 10 	movl   $0xc010ab10,0xc(%esp)
c01040d1:	c0 
c01040d2:	c7 44 24 08 4d aa 10 	movl   $0xc010aa4d,0x8(%esp)
c01040d9:	c0 
c01040da:	c7 44 24 04 36 02 00 	movl   $0x236,0x4(%esp)
c01040e1:	00 
c01040e2:	c7 04 24 28 aa 10 c0 	movl   $0xc010aa28,(%esp)
c01040e9:	e8 4f c3 ff ff       	call   c010043d <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c01040ee:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01040f5:	e8 15 f4 ff ff       	call   c010350f <alloc_pages>
c01040fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c01040fd:	a1 e0 89 12 c0       	mov    0xc01289e0,%eax
c0104102:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0104109:	00 
c010410a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104111:	00 
c0104112:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104115:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104119:	89 04 24             	mov    %eax,(%esp)
c010411c:	e8 03 fd ff ff       	call   c0103e24 <page_insert>
c0104121:	85 c0                	test   %eax,%eax
c0104123:	74 24                	je     c0104149 <check_pgdir+0x115>
c0104125:	c7 44 24 0c 38 ab 10 	movl   $0xc010ab38,0xc(%esp)
c010412c:	c0 
c010412d:	c7 44 24 08 4d aa 10 	movl   $0xc010aa4d,0x8(%esp)
c0104134:	c0 
c0104135:	c7 44 24 04 3a 02 00 	movl   $0x23a,0x4(%esp)
c010413c:	00 
c010413d:	c7 04 24 28 aa 10 c0 	movl   $0xc010aa28,(%esp)
c0104144:	e8 f4 c2 ff ff       	call   c010043d <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c0104149:	a1 e0 89 12 c0       	mov    0xc01289e0,%eax
c010414e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104155:	00 
c0104156:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010415d:	00 
c010415e:	89 04 24             	mov    %eax,(%esp)
c0104161:	e8 79 fa ff ff       	call   c0103bdf <get_pte>
c0104166:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104169:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010416d:	75 24                	jne    c0104193 <check_pgdir+0x15f>
c010416f:	c7 44 24 0c 64 ab 10 	movl   $0xc010ab64,0xc(%esp)
c0104176:	c0 
c0104177:	c7 44 24 08 4d aa 10 	movl   $0xc010aa4d,0x8(%esp)
c010417e:	c0 
c010417f:	c7 44 24 04 3d 02 00 	movl   $0x23d,0x4(%esp)
c0104186:	00 
c0104187:	c7 04 24 28 aa 10 c0 	movl   $0xc010aa28,(%esp)
c010418e:	e8 aa c2 ff ff       	call   c010043d <__panic>
    assert(pte2page(*ptep) == p1);
c0104193:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104196:	8b 00                	mov    (%eax),%eax
c0104198:	89 04 24             	mov    %eax,(%esp)
c010419b:	e8 03 f1 ff ff       	call   c01032a3 <pte2page>
c01041a0:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01041a3:	74 24                	je     c01041c9 <check_pgdir+0x195>
c01041a5:	c7 44 24 0c 91 ab 10 	movl   $0xc010ab91,0xc(%esp)
c01041ac:	c0 
c01041ad:	c7 44 24 08 4d aa 10 	movl   $0xc010aa4d,0x8(%esp)
c01041b4:	c0 
c01041b5:	c7 44 24 04 3e 02 00 	movl   $0x23e,0x4(%esp)
c01041bc:	00 
c01041bd:	c7 04 24 28 aa 10 c0 	movl   $0xc010aa28,(%esp)
c01041c4:	e8 74 c2 ff ff       	call   c010043d <__panic>
    assert(page_ref(p1) == 1);
c01041c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01041cc:	89 04 24             	mov    %eax,(%esp)
c01041cf:	e8 25 f1 ff ff       	call   c01032f9 <page_ref>
c01041d4:	83 f8 01             	cmp    $0x1,%eax
c01041d7:	74 24                	je     c01041fd <check_pgdir+0x1c9>
c01041d9:	c7 44 24 0c a7 ab 10 	movl   $0xc010aba7,0xc(%esp)
c01041e0:	c0 
c01041e1:	c7 44 24 08 4d aa 10 	movl   $0xc010aa4d,0x8(%esp)
c01041e8:	c0 
c01041e9:	c7 44 24 04 3f 02 00 	movl   $0x23f,0x4(%esp)
c01041f0:	00 
c01041f1:	c7 04 24 28 aa 10 c0 	movl   $0xc010aa28,(%esp)
c01041f8:	e8 40 c2 ff ff       	call   c010043d <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c01041fd:	a1 e0 89 12 c0       	mov    0xc01289e0,%eax
c0104202:	8b 00                	mov    (%eax),%eax
c0104204:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104209:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010420c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010420f:	c1 e8 0c             	shr    $0xc,%eax
c0104212:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104215:	a1 80 bf 12 c0       	mov    0xc012bf80,%eax
c010421a:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c010421d:	72 23                	jb     c0104242 <check_pgdir+0x20e>
c010421f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104222:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104226:	c7 44 24 08 60 a9 10 	movl   $0xc010a960,0x8(%esp)
c010422d:	c0 
c010422e:	c7 44 24 04 41 02 00 	movl   $0x241,0x4(%esp)
c0104235:	00 
c0104236:	c7 04 24 28 aa 10 c0 	movl   $0xc010aa28,(%esp)
c010423d:	e8 fb c1 ff ff       	call   c010043d <__panic>
c0104242:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104245:	2d 00 00 00 40       	sub    $0x40000000,%eax
c010424a:	83 c0 04             	add    $0x4,%eax
c010424d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c0104250:	a1 e0 89 12 c0       	mov    0xc01289e0,%eax
c0104255:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010425c:	00 
c010425d:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104264:	00 
c0104265:	89 04 24             	mov    %eax,(%esp)
c0104268:	e8 72 f9 ff ff       	call   c0103bdf <get_pte>
c010426d:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0104270:	74 24                	je     c0104296 <check_pgdir+0x262>
c0104272:	c7 44 24 0c bc ab 10 	movl   $0xc010abbc,0xc(%esp)
c0104279:	c0 
c010427a:	c7 44 24 08 4d aa 10 	movl   $0xc010aa4d,0x8(%esp)
c0104281:	c0 
c0104282:	c7 44 24 04 42 02 00 	movl   $0x242,0x4(%esp)
c0104289:	00 
c010428a:	c7 04 24 28 aa 10 c0 	movl   $0xc010aa28,(%esp)
c0104291:	e8 a7 c1 ff ff       	call   c010043d <__panic>

    p2 = alloc_page();
c0104296:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010429d:	e8 6d f2 ff ff       	call   c010350f <alloc_pages>
c01042a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c01042a5:	a1 e0 89 12 c0       	mov    0xc01289e0,%eax
c01042aa:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c01042b1:	00 
c01042b2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c01042b9:	00 
c01042ba:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01042bd:	89 54 24 04          	mov    %edx,0x4(%esp)
c01042c1:	89 04 24             	mov    %eax,(%esp)
c01042c4:	e8 5b fb ff ff       	call   c0103e24 <page_insert>
c01042c9:	85 c0                	test   %eax,%eax
c01042cb:	74 24                	je     c01042f1 <check_pgdir+0x2bd>
c01042cd:	c7 44 24 0c e4 ab 10 	movl   $0xc010abe4,0xc(%esp)
c01042d4:	c0 
c01042d5:	c7 44 24 08 4d aa 10 	movl   $0xc010aa4d,0x8(%esp)
c01042dc:	c0 
c01042dd:	c7 44 24 04 45 02 00 	movl   $0x245,0x4(%esp)
c01042e4:	00 
c01042e5:	c7 04 24 28 aa 10 c0 	movl   $0xc010aa28,(%esp)
c01042ec:	e8 4c c1 ff ff       	call   c010043d <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c01042f1:	a1 e0 89 12 c0       	mov    0xc01289e0,%eax
c01042f6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01042fd:	00 
c01042fe:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104305:	00 
c0104306:	89 04 24             	mov    %eax,(%esp)
c0104309:	e8 d1 f8 ff ff       	call   c0103bdf <get_pte>
c010430e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104311:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104315:	75 24                	jne    c010433b <check_pgdir+0x307>
c0104317:	c7 44 24 0c 1c ac 10 	movl   $0xc010ac1c,0xc(%esp)
c010431e:	c0 
c010431f:	c7 44 24 08 4d aa 10 	movl   $0xc010aa4d,0x8(%esp)
c0104326:	c0 
c0104327:	c7 44 24 04 46 02 00 	movl   $0x246,0x4(%esp)
c010432e:	00 
c010432f:	c7 04 24 28 aa 10 c0 	movl   $0xc010aa28,(%esp)
c0104336:	e8 02 c1 ff ff       	call   c010043d <__panic>
    assert(*ptep & PTE_U);
c010433b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010433e:	8b 00                	mov    (%eax),%eax
c0104340:	83 e0 04             	and    $0x4,%eax
c0104343:	85 c0                	test   %eax,%eax
c0104345:	75 24                	jne    c010436b <check_pgdir+0x337>
c0104347:	c7 44 24 0c 4c ac 10 	movl   $0xc010ac4c,0xc(%esp)
c010434e:	c0 
c010434f:	c7 44 24 08 4d aa 10 	movl   $0xc010aa4d,0x8(%esp)
c0104356:	c0 
c0104357:	c7 44 24 04 47 02 00 	movl   $0x247,0x4(%esp)
c010435e:	00 
c010435f:	c7 04 24 28 aa 10 c0 	movl   $0xc010aa28,(%esp)
c0104366:	e8 d2 c0 ff ff       	call   c010043d <__panic>
    assert(*ptep & PTE_W);
c010436b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010436e:	8b 00                	mov    (%eax),%eax
c0104370:	83 e0 02             	and    $0x2,%eax
c0104373:	85 c0                	test   %eax,%eax
c0104375:	75 24                	jne    c010439b <check_pgdir+0x367>
c0104377:	c7 44 24 0c 5a ac 10 	movl   $0xc010ac5a,0xc(%esp)
c010437e:	c0 
c010437f:	c7 44 24 08 4d aa 10 	movl   $0xc010aa4d,0x8(%esp)
c0104386:	c0 
c0104387:	c7 44 24 04 48 02 00 	movl   $0x248,0x4(%esp)
c010438e:	00 
c010438f:	c7 04 24 28 aa 10 c0 	movl   $0xc010aa28,(%esp)
c0104396:	e8 a2 c0 ff ff       	call   c010043d <__panic>
    assert(boot_pgdir[0] & PTE_U);
c010439b:	a1 e0 89 12 c0       	mov    0xc01289e0,%eax
c01043a0:	8b 00                	mov    (%eax),%eax
c01043a2:	83 e0 04             	and    $0x4,%eax
c01043a5:	85 c0                	test   %eax,%eax
c01043a7:	75 24                	jne    c01043cd <check_pgdir+0x399>
c01043a9:	c7 44 24 0c 68 ac 10 	movl   $0xc010ac68,0xc(%esp)
c01043b0:	c0 
c01043b1:	c7 44 24 08 4d aa 10 	movl   $0xc010aa4d,0x8(%esp)
c01043b8:	c0 
c01043b9:	c7 44 24 04 49 02 00 	movl   $0x249,0x4(%esp)
c01043c0:	00 
c01043c1:	c7 04 24 28 aa 10 c0 	movl   $0xc010aa28,(%esp)
c01043c8:	e8 70 c0 ff ff       	call   c010043d <__panic>
    assert(page_ref(p2) == 1);
c01043cd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01043d0:	89 04 24             	mov    %eax,(%esp)
c01043d3:	e8 21 ef ff ff       	call   c01032f9 <page_ref>
c01043d8:	83 f8 01             	cmp    $0x1,%eax
c01043db:	74 24                	je     c0104401 <check_pgdir+0x3cd>
c01043dd:	c7 44 24 0c 7e ac 10 	movl   $0xc010ac7e,0xc(%esp)
c01043e4:	c0 
c01043e5:	c7 44 24 08 4d aa 10 	movl   $0xc010aa4d,0x8(%esp)
c01043ec:	c0 
c01043ed:	c7 44 24 04 4a 02 00 	movl   $0x24a,0x4(%esp)
c01043f4:	00 
c01043f5:	c7 04 24 28 aa 10 c0 	movl   $0xc010aa28,(%esp)
c01043fc:	e8 3c c0 ff ff       	call   c010043d <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c0104401:	a1 e0 89 12 c0       	mov    0xc01289e0,%eax
c0104406:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010440d:	00 
c010440e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0104415:	00 
c0104416:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104419:	89 54 24 04          	mov    %edx,0x4(%esp)
c010441d:	89 04 24             	mov    %eax,(%esp)
c0104420:	e8 ff f9 ff ff       	call   c0103e24 <page_insert>
c0104425:	85 c0                	test   %eax,%eax
c0104427:	74 24                	je     c010444d <check_pgdir+0x419>
c0104429:	c7 44 24 0c 90 ac 10 	movl   $0xc010ac90,0xc(%esp)
c0104430:	c0 
c0104431:	c7 44 24 08 4d aa 10 	movl   $0xc010aa4d,0x8(%esp)
c0104438:	c0 
c0104439:	c7 44 24 04 4c 02 00 	movl   $0x24c,0x4(%esp)
c0104440:	00 
c0104441:	c7 04 24 28 aa 10 c0 	movl   $0xc010aa28,(%esp)
c0104448:	e8 f0 bf ff ff       	call   c010043d <__panic>
    assert(page_ref(p1) == 2);
c010444d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104450:	89 04 24             	mov    %eax,(%esp)
c0104453:	e8 a1 ee ff ff       	call   c01032f9 <page_ref>
c0104458:	83 f8 02             	cmp    $0x2,%eax
c010445b:	74 24                	je     c0104481 <check_pgdir+0x44d>
c010445d:	c7 44 24 0c bc ac 10 	movl   $0xc010acbc,0xc(%esp)
c0104464:	c0 
c0104465:	c7 44 24 08 4d aa 10 	movl   $0xc010aa4d,0x8(%esp)
c010446c:	c0 
c010446d:	c7 44 24 04 4d 02 00 	movl   $0x24d,0x4(%esp)
c0104474:	00 
c0104475:	c7 04 24 28 aa 10 c0 	movl   $0xc010aa28,(%esp)
c010447c:	e8 bc bf ff ff       	call   c010043d <__panic>
    assert(page_ref(p2) == 0);
c0104481:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104484:	89 04 24             	mov    %eax,(%esp)
c0104487:	e8 6d ee ff ff       	call   c01032f9 <page_ref>
c010448c:	85 c0                	test   %eax,%eax
c010448e:	74 24                	je     c01044b4 <check_pgdir+0x480>
c0104490:	c7 44 24 0c ce ac 10 	movl   $0xc010acce,0xc(%esp)
c0104497:	c0 
c0104498:	c7 44 24 08 4d aa 10 	movl   $0xc010aa4d,0x8(%esp)
c010449f:	c0 
c01044a0:	c7 44 24 04 4e 02 00 	movl   $0x24e,0x4(%esp)
c01044a7:	00 
c01044a8:	c7 04 24 28 aa 10 c0 	movl   $0xc010aa28,(%esp)
c01044af:	e8 89 bf ff ff       	call   c010043d <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c01044b4:	a1 e0 89 12 c0       	mov    0xc01289e0,%eax
c01044b9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01044c0:	00 
c01044c1:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01044c8:	00 
c01044c9:	89 04 24             	mov    %eax,(%esp)
c01044cc:	e8 0e f7 ff ff       	call   c0103bdf <get_pte>
c01044d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01044d4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01044d8:	75 24                	jne    c01044fe <check_pgdir+0x4ca>
c01044da:	c7 44 24 0c 1c ac 10 	movl   $0xc010ac1c,0xc(%esp)
c01044e1:	c0 
c01044e2:	c7 44 24 08 4d aa 10 	movl   $0xc010aa4d,0x8(%esp)
c01044e9:	c0 
c01044ea:	c7 44 24 04 4f 02 00 	movl   $0x24f,0x4(%esp)
c01044f1:	00 
c01044f2:	c7 04 24 28 aa 10 c0 	movl   $0xc010aa28,(%esp)
c01044f9:	e8 3f bf ff ff       	call   c010043d <__panic>
    assert(pte2page(*ptep) == p1);
c01044fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104501:	8b 00                	mov    (%eax),%eax
c0104503:	89 04 24             	mov    %eax,(%esp)
c0104506:	e8 98 ed ff ff       	call   c01032a3 <pte2page>
c010450b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010450e:	74 24                	je     c0104534 <check_pgdir+0x500>
c0104510:	c7 44 24 0c 91 ab 10 	movl   $0xc010ab91,0xc(%esp)
c0104517:	c0 
c0104518:	c7 44 24 08 4d aa 10 	movl   $0xc010aa4d,0x8(%esp)
c010451f:	c0 
c0104520:	c7 44 24 04 50 02 00 	movl   $0x250,0x4(%esp)
c0104527:	00 
c0104528:	c7 04 24 28 aa 10 c0 	movl   $0xc010aa28,(%esp)
c010452f:	e8 09 bf ff ff       	call   c010043d <__panic>
    assert((*ptep & PTE_U) == 0);
c0104534:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104537:	8b 00                	mov    (%eax),%eax
c0104539:	83 e0 04             	and    $0x4,%eax
c010453c:	85 c0                	test   %eax,%eax
c010453e:	74 24                	je     c0104564 <check_pgdir+0x530>
c0104540:	c7 44 24 0c e0 ac 10 	movl   $0xc010ace0,0xc(%esp)
c0104547:	c0 
c0104548:	c7 44 24 08 4d aa 10 	movl   $0xc010aa4d,0x8(%esp)
c010454f:	c0 
c0104550:	c7 44 24 04 51 02 00 	movl   $0x251,0x4(%esp)
c0104557:	00 
c0104558:	c7 04 24 28 aa 10 c0 	movl   $0xc010aa28,(%esp)
c010455f:	e8 d9 be ff ff       	call   c010043d <__panic>

    page_remove(boot_pgdir, 0x0);
c0104564:	a1 e0 89 12 c0       	mov    0xc01289e0,%eax
c0104569:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104570:	00 
c0104571:	89 04 24             	mov    %eax,(%esp)
c0104574:	e8 62 f8 ff ff       	call   c0103ddb <page_remove>
    assert(page_ref(p1) == 1);
c0104579:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010457c:	89 04 24             	mov    %eax,(%esp)
c010457f:	e8 75 ed ff ff       	call   c01032f9 <page_ref>
c0104584:	83 f8 01             	cmp    $0x1,%eax
c0104587:	74 24                	je     c01045ad <check_pgdir+0x579>
c0104589:	c7 44 24 0c a7 ab 10 	movl   $0xc010aba7,0xc(%esp)
c0104590:	c0 
c0104591:	c7 44 24 08 4d aa 10 	movl   $0xc010aa4d,0x8(%esp)
c0104598:	c0 
c0104599:	c7 44 24 04 54 02 00 	movl   $0x254,0x4(%esp)
c01045a0:	00 
c01045a1:	c7 04 24 28 aa 10 c0 	movl   $0xc010aa28,(%esp)
c01045a8:	e8 90 be ff ff       	call   c010043d <__panic>
    assert(page_ref(p2) == 0);
c01045ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01045b0:	89 04 24             	mov    %eax,(%esp)
c01045b3:	e8 41 ed ff ff       	call   c01032f9 <page_ref>
c01045b8:	85 c0                	test   %eax,%eax
c01045ba:	74 24                	je     c01045e0 <check_pgdir+0x5ac>
c01045bc:	c7 44 24 0c ce ac 10 	movl   $0xc010acce,0xc(%esp)
c01045c3:	c0 
c01045c4:	c7 44 24 08 4d aa 10 	movl   $0xc010aa4d,0x8(%esp)
c01045cb:	c0 
c01045cc:	c7 44 24 04 55 02 00 	movl   $0x255,0x4(%esp)
c01045d3:	00 
c01045d4:	c7 04 24 28 aa 10 c0 	movl   $0xc010aa28,(%esp)
c01045db:	e8 5d be ff ff       	call   c010043d <__panic>

    page_remove(boot_pgdir, PGSIZE);
c01045e0:	a1 e0 89 12 c0       	mov    0xc01289e0,%eax
c01045e5:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01045ec:	00 
c01045ed:	89 04 24             	mov    %eax,(%esp)
c01045f0:	e8 e6 f7 ff ff       	call   c0103ddb <page_remove>
    assert(page_ref(p1) == 0);
c01045f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045f8:	89 04 24             	mov    %eax,(%esp)
c01045fb:	e8 f9 ec ff ff       	call   c01032f9 <page_ref>
c0104600:	85 c0                	test   %eax,%eax
c0104602:	74 24                	je     c0104628 <check_pgdir+0x5f4>
c0104604:	c7 44 24 0c f5 ac 10 	movl   $0xc010acf5,0xc(%esp)
c010460b:	c0 
c010460c:	c7 44 24 08 4d aa 10 	movl   $0xc010aa4d,0x8(%esp)
c0104613:	c0 
c0104614:	c7 44 24 04 58 02 00 	movl   $0x258,0x4(%esp)
c010461b:	00 
c010461c:	c7 04 24 28 aa 10 c0 	movl   $0xc010aa28,(%esp)
c0104623:	e8 15 be ff ff       	call   c010043d <__panic>
    assert(page_ref(p2) == 0);
c0104628:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010462b:	89 04 24             	mov    %eax,(%esp)
c010462e:	e8 c6 ec ff ff       	call   c01032f9 <page_ref>
c0104633:	85 c0                	test   %eax,%eax
c0104635:	74 24                	je     c010465b <check_pgdir+0x627>
c0104637:	c7 44 24 0c ce ac 10 	movl   $0xc010acce,0xc(%esp)
c010463e:	c0 
c010463f:	c7 44 24 08 4d aa 10 	movl   $0xc010aa4d,0x8(%esp)
c0104646:	c0 
c0104647:	c7 44 24 04 59 02 00 	movl   $0x259,0x4(%esp)
c010464e:	00 
c010464f:	c7 04 24 28 aa 10 c0 	movl   $0xc010aa28,(%esp)
c0104656:	e8 e2 bd ff ff       	call   c010043d <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c010465b:	a1 e0 89 12 c0       	mov    0xc01289e0,%eax
c0104660:	8b 00                	mov    (%eax),%eax
c0104662:	89 04 24             	mov    %eax,(%esp)
c0104665:	e8 77 ec ff ff       	call   c01032e1 <pde2page>
c010466a:	89 04 24             	mov    %eax,(%esp)
c010466d:	e8 87 ec ff ff       	call   c01032f9 <page_ref>
c0104672:	83 f8 01             	cmp    $0x1,%eax
c0104675:	74 24                	je     c010469b <check_pgdir+0x667>
c0104677:	c7 44 24 0c 08 ad 10 	movl   $0xc010ad08,0xc(%esp)
c010467e:	c0 
c010467f:	c7 44 24 08 4d aa 10 	movl   $0xc010aa4d,0x8(%esp)
c0104686:	c0 
c0104687:	c7 44 24 04 5b 02 00 	movl   $0x25b,0x4(%esp)
c010468e:	00 
c010468f:	c7 04 24 28 aa 10 c0 	movl   $0xc010aa28,(%esp)
c0104696:	e8 a2 bd ff ff       	call   c010043d <__panic>
    free_page(pde2page(boot_pgdir[0]));
c010469b:	a1 e0 89 12 c0       	mov    0xc01289e0,%eax
c01046a0:	8b 00                	mov    (%eax),%eax
c01046a2:	89 04 24             	mov    %eax,(%esp)
c01046a5:	e8 37 ec ff ff       	call   c01032e1 <pde2page>
c01046aa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01046b1:	00 
c01046b2:	89 04 24             	mov    %eax,(%esp)
c01046b5:	e8 c4 ee ff ff       	call   c010357e <free_pages>
    boot_pgdir[0] = 0;
c01046ba:	a1 e0 89 12 c0       	mov    0xc01289e0,%eax
c01046bf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c01046c5:	c7 04 24 2f ad 10 c0 	movl   $0xc010ad2f,(%esp)
c01046cc:	e8 00 bc ff ff       	call   c01002d1 <cprintf>
}
c01046d1:	90                   	nop
c01046d2:	c9                   	leave  
c01046d3:	c3                   	ret    

c01046d4 <check_boot_pgdir>:

static void
check_boot_pgdir(void)
{
c01046d4:	f3 0f 1e fb          	endbr32 
c01046d8:	55                   	push   %ebp
c01046d9:	89 e5                	mov    %esp,%ebp
c01046db:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE)
c01046de:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01046e5:	e9 ca 00 00 00       	jmp    c01047b4 <check_boot_pgdir+0xe0>
    {
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c01046ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046ed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01046f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01046f3:	c1 e8 0c             	shr    $0xc,%eax
c01046f6:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01046f9:	a1 80 bf 12 c0       	mov    0xc012bf80,%eax
c01046fe:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0104701:	72 23                	jb     c0104726 <check_boot_pgdir+0x52>
c0104703:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104706:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010470a:	c7 44 24 08 60 a9 10 	movl   $0xc010a960,0x8(%esp)
c0104711:	c0 
c0104712:	c7 44 24 04 69 02 00 	movl   $0x269,0x4(%esp)
c0104719:	00 
c010471a:	c7 04 24 28 aa 10 c0 	movl   $0xc010aa28,(%esp)
c0104721:	e8 17 bd ff ff       	call   c010043d <__panic>
c0104726:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104729:	2d 00 00 00 40       	sub    $0x40000000,%eax
c010472e:	89 c2                	mov    %eax,%edx
c0104730:	a1 e0 89 12 c0       	mov    0xc01289e0,%eax
c0104735:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010473c:	00 
c010473d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104741:	89 04 24             	mov    %eax,(%esp)
c0104744:	e8 96 f4 ff ff       	call   c0103bdf <get_pte>
c0104749:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010474c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0104750:	75 24                	jne    c0104776 <check_boot_pgdir+0xa2>
c0104752:	c7 44 24 0c 4c ad 10 	movl   $0xc010ad4c,0xc(%esp)
c0104759:	c0 
c010475a:	c7 44 24 08 4d aa 10 	movl   $0xc010aa4d,0x8(%esp)
c0104761:	c0 
c0104762:	c7 44 24 04 69 02 00 	movl   $0x269,0x4(%esp)
c0104769:	00 
c010476a:	c7 04 24 28 aa 10 c0 	movl   $0xc010aa28,(%esp)
c0104771:	e8 c7 bc ff ff       	call   c010043d <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0104776:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104779:	8b 00                	mov    (%eax),%eax
c010477b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104780:	89 c2                	mov    %eax,%edx
c0104782:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104785:	39 c2                	cmp    %eax,%edx
c0104787:	74 24                	je     c01047ad <check_boot_pgdir+0xd9>
c0104789:	c7 44 24 0c 89 ad 10 	movl   $0xc010ad89,0xc(%esp)
c0104790:	c0 
c0104791:	c7 44 24 08 4d aa 10 	movl   $0xc010aa4d,0x8(%esp)
c0104798:	c0 
c0104799:	c7 44 24 04 6a 02 00 	movl   $0x26a,0x4(%esp)
c01047a0:	00 
c01047a1:	c7 04 24 28 aa 10 c0 	movl   $0xc010aa28,(%esp)
c01047a8:	e8 90 bc ff ff       	call   c010043d <__panic>
    for (i = 0; i < npage; i += PGSIZE)
c01047ad:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c01047b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01047b7:	a1 80 bf 12 c0       	mov    0xc012bf80,%eax
c01047bc:	39 c2                	cmp    %eax,%edx
c01047be:	0f 82 26 ff ff ff    	jb     c01046ea <check_boot_pgdir+0x16>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c01047c4:	a1 e0 89 12 c0       	mov    0xc01289e0,%eax
c01047c9:	05 ac 0f 00 00       	add    $0xfac,%eax
c01047ce:	8b 00                	mov    (%eax),%eax
c01047d0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01047d5:	89 c2                	mov    %eax,%edx
c01047d7:	a1 e0 89 12 c0       	mov    0xc01289e0,%eax
c01047dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01047df:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c01047e6:	77 23                	ja     c010480b <check_boot_pgdir+0x137>
c01047e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01047eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01047ef:	c7 44 24 08 04 aa 10 	movl   $0xc010aa04,0x8(%esp)
c01047f6:	c0 
c01047f7:	c7 44 24 04 6d 02 00 	movl   $0x26d,0x4(%esp)
c01047fe:	00 
c01047ff:	c7 04 24 28 aa 10 c0 	movl   $0xc010aa28,(%esp)
c0104806:	e8 32 bc ff ff       	call   c010043d <__panic>
c010480b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010480e:	05 00 00 00 40       	add    $0x40000000,%eax
c0104813:	39 d0                	cmp    %edx,%eax
c0104815:	74 24                	je     c010483b <check_boot_pgdir+0x167>
c0104817:	c7 44 24 0c a0 ad 10 	movl   $0xc010ada0,0xc(%esp)
c010481e:	c0 
c010481f:	c7 44 24 08 4d aa 10 	movl   $0xc010aa4d,0x8(%esp)
c0104826:	c0 
c0104827:	c7 44 24 04 6d 02 00 	movl   $0x26d,0x4(%esp)
c010482e:	00 
c010482f:	c7 04 24 28 aa 10 c0 	movl   $0xc010aa28,(%esp)
c0104836:	e8 02 bc ff ff       	call   c010043d <__panic>

    assert(boot_pgdir[0] == 0);
c010483b:	a1 e0 89 12 c0       	mov    0xc01289e0,%eax
c0104840:	8b 00                	mov    (%eax),%eax
c0104842:	85 c0                	test   %eax,%eax
c0104844:	74 24                	je     c010486a <check_boot_pgdir+0x196>
c0104846:	c7 44 24 0c d4 ad 10 	movl   $0xc010add4,0xc(%esp)
c010484d:	c0 
c010484e:	c7 44 24 08 4d aa 10 	movl   $0xc010aa4d,0x8(%esp)
c0104855:	c0 
c0104856:	c7 44 24 04 6f 02 00 	movl   $0x26f,0x4(%esp)
c010485d:	00 
c010485e:	c7 04 24 28 aa 10 c0 	movl   $0xc010aa28,(%esp)
c0104865:	e8 d3 bb ff ff       	call   c010043d <__panic>

    struct Page *p;
    p = alloc_page();
c010486a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104871:	e8 99 ec ff ff       	call   c010350f <alloc_pages>
c0104876:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0104879:	a1 e0 89 12 c0       	mov    0xc01289e0,%eax
c010487e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0104885:	00 
c0104886:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c010488d:	00 
c010488e:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104891:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104895:	89 04 24             	mov    %eax,(%esp)
c0104898:	e8 87 f5 ff ff       	call   c0103e24 <page_insert>
c010489d:	85 c0                	test   %eax,%eax
c010489f:	74 24                	je     c01048c5 <check_boot_pgdir+0x1f1>
c01048a1:	c7 44 24 0c e8 ad 10 	movl   $0xc010ade8,0xc(%esp)
c01048a8:	c0 
c01048a9:	c7 44 24 08 4d aa 10 	movl   $0xc010aa4d,0x8(%esp)
c01048b0:	c0 
c01048b1:	c7 44 24 04 73 02 00 	movl   $0x273,0x4(%esp)
c01048b8:	00 
c01048b9:	c7 04 24 28 aa 10 c0 	movl   $0xc010aa28,(%esp)
c01048c0:	e8 78 bb ff ff       	call   c010043d <__panic>
    assert(page_ref(p) == 1);
c01048c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01048c8:	89 04 24             	mov    %eax,(%esp)
c01048cb:	e8 29 ea ff ff       	call   c01032f9 <page_ref>
c01048d0:	83 f8 01             	cmp    $0x1,%eax
c01048d3:	74 24                	je     c01048f9 <check_boot_pgdir+0x225>
c01048d5:	c7 44 24 0c 16 ae 10 	movl   $0xc010ae16,0xc(%esp)
c01048dc:	c0 
c01048dd:	c7 44 24 08 4d aa 10 	movl   $0xc010aa4d,0x8(%esp)
c01048e4:	c0 
c01048e5:	c7 44 24 04 74 02 00 	movl   $0x274,0x4(%esp)
c01048ec:	00 
c01048ed:	c7 04 24 28 aa 10 c0 	movl   $0xc010aa28,(%esp)
c01048f4:	e8 44 bb ff ff       	call   c010043d <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c01048f9:	a1 e0 89 12 c0       	mov    0xc01289e0,%eax
c01048fe:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0104905:	00 
c0104906:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c010490d:	00 
c010490e:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104911:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104915:	89 04 24             	mov    %eax,(%esp)
c0104918:	e8 07 f5 ff ff       	call   c0103e24 <page_insert>
c010491d:	85 c0                	test   %eax,%eax
c010491f:	74 24                	je     c0104945 <check_boot_pgdir+0x271>
c0104921:	c7 44 24 0c 28 ae 10 	movl   $0xc010ae28,0xc(%esp)
c0104928:	c0 
c0104929:	c7 44 24 08 4d aa 10 	movl   $0xc010aa4d,0x8(%esp)
c0104930:	c0 
c0104931:	c7 44 24 04 75 02 00 	movl   $0x275,0x4(%esp)
c0104938:	00 
c0104939:	c7 04 24 28 aa 10 c0 	movl   $0xc010aa28,(%esp)
c0104940:	e8 f8 ba ff ff       	call   c010043d <__panic>
    assert(page_ref(p) == 2);
c0104945:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104948:	89 04 24             	mov    %eax,(%esp)
c010494b:	e8 a9 e9 ff ff       	call   c01032f9 <page_ref>
c0104950:	83 f8 02             	cmp    $0x2,%eax
c0104953:	74 24                	je     c0104979 <check_boot_pgdir+0x2a5>
c0104955:	c7 44 24 0c 5f ae 10 	movl   $0xc010ae5f,0xc(%esp)
c010495c:	c0 
c010495d:	c7 44 24 08 4d aa 10 	movl   $0xc010aa4d,0x8(%esp)
c0104964:	c0 
c0104965:	c7 44 24 04 76 02 00 	movl   $0x276,0x4(%esp)
c010496c:	00 
c010496d:	c7 04 24 28 aa 10 c0 	movl   $0xc010aa28,(%esp)
c0104974:	e8 c4 ba ff ff       	call   c010043d <__panic>

    const char *str = "ucore: Hello world!!";
c0104979:	c7 45 e8 70 ae 10 c0 	movl   $0xc010ae70,-0x18(%ebp)
    strcpy((void *)0x100, str);
c0104980:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104983:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104987:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c010498e:	e8 4b 4a 00 00       	call   c01093de <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c0104993:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c010499a:	00 
c010499b:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c01049a2:	e8 b5 4a 00 00       	call   c010945c <strcmp>
c01049a7:	85 c0                	test   %eax,%eax
c01049a9:	74 24                	je     c01049cf <check_boot_pgdir+0x2fb>
c01049ab:	c7 44 24 0c 88 ae 10 	movl   $0xc010ae88,0xc(%esp)
c01049b2:	c0 
c01049b3:	c7 44 24 08 4d aa 10 	movl   $0xc010aa4d,0x8(%esp)
c01049ba:	c0 
c01049bb:	c7 44 24 04 7a 02 00 	movl   $0x27a,0x4(%esp)
c01049c2:	00 
c01049c3:	c7 04 24 28 aa 10 c0 	movl   $0xc010aa28,(%esp)
c01049ca:	e8 6e ba ff ff       	call   c010043d <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c01049cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01049d2:	89 04 24             	mov    %eax,(%esp)
c01049d5:	e8 75 e8 ff ff       	call   c010324f <page2kva>
c01049da:	05 00 01 00 00       	add    $0x100,%eax
c01049df:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c01049e2:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c01049e9:	e8 92 49 00 00       	call   c0109380 <strlen>
c01049ee:	85 c0                	test   %eax,%eax
c01049f0:	74 24                	je     c0104a16 <check_boot_pgdir+0x342>
c01049f2:	c7 44 24 0c c0 ae 10 	movl   $0xc010aec0,0xc(%esp)
c01049f9:	c0 
c01049fa:	c7 44 24 08 4d aa 10 	movl   $0xc010aa4d,0x8(%esp)
c0104a01:	c0 
c0104a02:	c7 44 24 04 7d 02 00 	movl   $0x27d,0x4(%esp)
c0104a09:	00 
c0104a0a:	c7 04 24 28 aa 10 c0 	movl   $0xc010aa28,(%esp)
c0104a11:	e8 27 ba ff ff       	call   c010043d <__panic>

    free_page(p);
c0104a16:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104a1d:	00 
c0104a1e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104a21:	89 04 24             	mov    %eax,(%esp)
c0104a24:	e8 55 eb ff ff       	call   c010357e <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c0104a29:	a1 e0 89 12 c0       	mov    0xc01289e0,%eax
c0104a2e:	8b 00                	mov    (%eax),%eax
c0104a30:	89 04 24             	mov    %eax,(%esp)
c0104a33:	e8 a9 e8 ff ff       	call   c01032e1 <pde2page>
c0104a38:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104a3f:	00 
c0104a40:	89 04 24             	mov    %eax,(%esp)
c0104a43:	e8 36 eb ff ff       	call   c010357e <free_pages>
    boot_pgdir[0] = 0;
c0104a48:	a1 e0 89 12 c0       	mov    0xc01289e0,%eax
c0104a4d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c0104a53:	c7 04 24 e4 ae 10 c0 	movl   $0xc010aee4,(%esp)
c0104a5a:	e8 72 b8 ff ff       	call   c01002d1 <cprintf>
}
c0104a5f:	90                   	nop
c0104a60:	c9                   	leave  
c0104a61:	c3                   	ret    

c0104a62 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm)
{
c0104a62:	f3 0f 1e fb          	endbr32 
c0104a66:	55                   	push   %ebp
c0104a67:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c0104a69:	8b 45 08             	mov    0x8(%ebp),%eax
c0104a6c:	83 e0 04             	and    $0x4,%eax
c0104a6f:	85 c0                	test   %eax,%eax
c0104a71:	74 04                	je     c0104a77 <perm2str+0x15>
c0104a73:	b0 75                	mov    $0x75,%al
c0104a75:	eb 02                	jmp    c0104a79 <perm2str+0x17>
c0104a77:	b0 2d                	mov    $0x2d,%al
c0104a79:	a2 08 c0 12 c0       	mov    %al,0xc012c008
    str[1] = 'r';
c0104a7e:	c6 05 09 c0 12 c0 72 	movb   $0x72,0xc012c009
    str[2] = (perm & PTE_W) ? 'w' : '-';
c0104a85:	8b 45 08             	mov    0x8(%ebp),%eax
c0104a88:	83 e0 02             	and    $0x2,%eax
c0104a8b:	85 c0                	test   %eax,%eax
c0104a8d:	74 04                	je     c0104a93 <perm2str+0x31>
c0104a8f:	b0 77                	mov    $0x77,%al
c0104a91:	eb 02                	jmp    c0104a95 <perm2str+0x33>
c0104a93:	b0 2d                	mov    $0x2d,%al
c0104a95:	a2 0a c0 12 c0       	mov    %al,0xc012c00a
    str[3] = '\0';
c0104a9a:	c6 05 0b c0 12 c0 00 	movb   $0x0,0xc012c00b
    return str;
c0104aa1:	b8 08 c0 12 c0       	mov    $0xc012c008,%eax
}
c0104aa6:	5d                   	pop    %ebp
c0104aa7:	c3                   	ret    

c0104aa8 <get_pgtable_items>:
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store)
{
c0104aa8:	f3 0f 1e fb          	endbr32 
c0104aac:	55                   	push   %ebp
c0104aad:	89 e5                	mov    %esp,%ebp
c0104aaf:	83 ec 10             	sub    $0x10,%esp
    if (start >= right)
c0104ab2:	8b 45 10             	mov    0x10(%ebp),%eax
c0104ab5:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104ab8:	72 0d                	jb     c0104ac7 <get_pgtable_items+0x1f>
    {
        return 0;
c0104aba:	b8 00 00 00 00       	mov    $0x0,%eax
c0104abf:	e9 98 00 00 00       	jmp    c0104b5c <get_pgtable_items+0xb4>
    }
    while (start < right && !(table[start] & PTE_P))
    {
        start++;
c0104ac4:	ff 45 10             	incl   0x10(%ebp)
    while (start < right && !(table[start] & PTE_P))
c0104ac7:	8b 45 10             	mov    0x10(%ebp),%eax
c0104aca:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104acd:	73 18                	jae    c0104ae7 <get_pgtable_items+0x3f>
c0104acf:	8b 45 10             	mov    0x10(%ebp),%eax
c0104ad2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0104ad9:	8b 45 14             	mov    0x14(%ebp),%eax
c0104adc:	01 d0                	add    %edx,%eax
c0104ade:	8b 00                	mov    (%eax),%eax
c0104ae0:	83 e0 01             	and    $0x1,%eax
c0104ae3:	85 c0                	test   %eax,%eax
c0104ae5:	74 dd                	je     c0104ac4 <get_pgtable_items+0x1c>
    }
    if (start < right)
c0104ae7:	8b 45 10             	mov    0x10(%ebp),%eax
c0104aea:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104aed:	73 68                	jae    c0104b57 <get_pgtable_items+0xaf>
    {
        if (left_store != NULL)
c0104aef:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0104af3:	74 08                	je     c0104afd <get_pgtable_items+0x55>
        {
            *left_store = start;
c0104af5:	8b 45 18             	mov    0x18(%ebp),%eax
c0104af8:	8b 55 10             	mov    0x10(%ebp),%edx
c0104afb:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start++] & PTE_USER);
c0104afd:	8b 45 10             	mov    0x10(%ebp),%eax
c0104b00:	8d 50 01             	lea    0x1(%eax),%edx
c0104b03:	89 55 10             	mov    %edx,0x10(%ebp)
c0104b06:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0104b0d:	8b 45 14             	mov    0x14(%ebp),%eax
c0104b10:	01 d0                	add    %edx,%eax
c0104b12:	8b 00                	mov    (%eax),%eax
c0104b14:	83 e0 07             	and    $0x7,%eax
c0104b17:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm)
c0104b1a:	eb 03                	jmp    c0104b1f <get_pgtable_items+0x77>
        {
            start++;
c0104b1c:	ff 45 10             	incl   0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm)
c0104b1f:	8b 45 10             	mov    0x10(%ebp),%eax
c0104b22:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104b25:	73 1d                	jae    c0104b44 <get_pgtable_items+0x9c>
c0104b27:	8b 45 10             	mov    0x10(%ebp),%eax
c0104b2a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0104b31:	8b 45 14             	mov    0x14(%ebp),%eax
c0104b34:	01 d0                	add    %edx,%eax
c0104b36:	8b 00                	mov    (%eax),%eax
c0104b38:	83 e0 07             	and    $0x7,%eax
c0104b3b:	89 c2                	mov    %eax,%edx
c0104b3d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104b40:	39 c2                	cmp    %eax,%edx
c0104b42:	74 d8                	je     c0104b1c <get_pgtable_items+0x74>
        }
        if (right_store != NULL)
c0104b44:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0104b48:	74 08                	je     c0104b52 <get_pgtable_items+0xaa>
        {
            *right_store = start;
c0104b4a:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0104b4d:	8b 55 10             	mov    0x10(%ebp),%edx
c0104b50:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c0104b52:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104b55:	eb 05                	jmp    c0104b5c <get_pgtable_items+0xb4>
    }
    return 0;
c0104b57:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104b5c:	c9                   	leave  
c0104b5d:	c3                   	ret    

c0104b5e <print_pgdir>:

//print_pgdir - print the PDT&PT
void print_pgdir(void)
{
c0104b5e:	f3 0f 1e fb          	endbr32 
c0104b62:	55                   	push   %ebp
c0104b63:	89 e5                	mov    %esp,%ebp
c0104b65:	57                   	push   %edi
c0104b66:	56                   	push   %esi
c0104b67:	53                   	push   %ebx
c0104b68:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c0104b6b:	c7 04 24 04 af 10 c0 	movl   $0xc010af04,(%esp)
c0104b72:	e8 5a b7 ff ff       	call   c01002d1 <cprintf>
    size_t left, right = 0, perm;
c0104b77:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0)
c0104b7e:	e9 fa 00 00 00       	jmp    c0104c7d <print_pgdir+0x11f>
    {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0104b83:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104b86:	89 04 24             	mov    %eax,(%esp)
c0104b89:	e8 d4 fe ff ff       	call   c0104a62 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0104b8e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0104b91:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104b94:	29 d1                	sub    %edx,%ecx
c0104b96:	89 ca                	mov    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0104b98:	89 d6                	mov    %edx,%esi
c0104b9a:	c1 e6 16             	shl    $0x16,%esi
c0104b9d:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104ba0:	89 d3                	mov    %edx,%ebx
c0104ba2:	c1 e3 16             	shl    $0x16,%ebx
c0104ba5:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104ba8:	89 d1                	mov    %edx,%ecx
c0104baa:	c1 e1 16             	shl    $0x16,%ecx
c0104bad:	8b 7d dc             	mov    -0x24(%ebp),%edi
c0104bb0:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104bb3:	29 d7                	sub    %edx,%edi
c0104bb5:	89 fa                	mov    %edi,%edx
c0104bb7:	89 44 24 14          	mov    %eax,0x14(%esp)
c0104bbb:	89 74 24 10          	mov    %esi,0x10(%esp)
c0104bbf:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0104bc3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0104bc7:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104bcb:	c7 04 24 35 af 10 c0 	movl   $0xc010af35,(%esp)
c0104bd2:	e8 fa b6 ff ff       	call   c01002d1 <cprintf>
        size_t l, r = left * NPTEENTRY;
c0104bd7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104bda:	c1 e0 0a             	shl    $0xa,%eax
c0104bdd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0)
c0104be0:	eb 54                	jmp    c0104c36 <print_pgdir+0xd8>
        {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0104be2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104be5:	89 04 24             	mov    %eax,(%esp)
c0104be8:	e8 75 fe ff ff       	call   c0104a62 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c0104bed:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c0104bf0:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104bf3:	29 d1                	sub    %edx,%ecx
c0104bf5:	89 ca                	mov    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0104bf7:	89 d6                	mov    %edx,%esi
c0104bf9:	c1 e6 0c             	shl    $0xc,%esi
c0104bfc:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104bff:	89 d3                	mov    %edx,%ebx
c0104c01:	c1 e3 0c             	shl    $0xc,%ebx
c0104c04:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104c07:	89 d1                	mov    %edx,%ecx
c0104c09:	c1 e1 0c             	shl    $0xc,%ecx
c0104c0c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c0104c0f:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104c12:	29 d7                	sub    %edx,%edi
c0104c14:	89 fa                	mov    %edi,%edx
c0104c16:	89 44 24 14          	mov    %eax,0x14(%esp)
c0104c1a:	89 74 24 10          	mov    %esi,0x10(%esp)
c0104c1e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0104c22:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0104c26:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104c2a:	c7 04 24 54 af 10 c0 	movl   $0xc010af54,(%esp)
c0104c31:	e8 9b b6 ff ff       	call   c01002d1 <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0)
c0104c36:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
c0104c3b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104c3e:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104c41:	89 d3                	mov    %edx,%ebx
c0104c43:	c1 e3 0a             	shl    $0xa,%ebx
c0104c46:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104c49:	89 d1                	mov    %edx,%ecx
c0104c4b:	c1 e1 0a             	shl    $0xa,%ecx
c0104c4e:	8d 55 d4             	lea    -0x2c(%ebp),%edx
c0104c51:	89 54 24 14          	mov    %edx,0x14(%esp)
c0104c55:	8d 55 d8             	lea    -0x28(%ebp),%edx
c0104c58:	89 54 24 10          	mov    %edx,0x10(%esp)
c0104c5c:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0104c60:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104c64:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0104c68:	89 0c 24             	mov    %ecx,(%esp)
c0104c6b:	e8 38 fe ff ff       	call   c0104aa8 <get_pgtable_items>
c0104c70:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104c73:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0104c77:	0f 85 65 ff ff ff    	jne    c0104be2 <print_pgdir+0x84>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0)
c0104c7d:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
c0104c82:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104c85:	8d 55 dc             	lea    -0x24(%ebp),%edx
c0104c88:	89 54 24 14          	mov    %edx,0x14(%esp)
c0104c8c:	8d 55 e0             	lea    -0x20(%ebp),%edx
c0104c8f:	89 54 24 10          	mov    %edx,0x10(%esp)
c0104c93:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0104c97:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104c9b:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c0104ca2:	00 
c0104ca3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0104caa:	e8 f9 fd ff ff       	call   c0104aa8 <get_pgtable_items>
c0104caf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104cb2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0104cb6:	0f 85 c7 fe ff ff    	jne    c0104b83 <print_pgdir+0x25>
        }
    }
    cprintf("--------------------- END ---------------------\n");
c0104cbc:	c7 04 24 78 af 10 c0 	movl   $0xc010af78,(%esp)
c0104cc3:	e8 09 b6 ff ff       	call   c01002d1 <cprintf>
}
c0104cc8:	90                   	nop
c0104cc9:	83 c4 4c             	add    $0x4c,%esp
c0104ccc:	5b                   	pop    %ebx
c0104ccd:	5e                   	pop    %esi
c0104cce:	5f                   	pop    %edi
c0104ccf:	5d                   	pop    %ebp
c0104cd0:	c3                   	ret    

c0104cd1 <pa2page>:
pa2page(uintptr_t pa) {
c0104cd1:	55                   	push   %ebp
c0104cd2:	89 e5                	mov    %esp,%ebp
c0104cd4:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0104cd7:	8b 45 08             	mov    0x8(%ebp),%eax
c0104cda:	c1 e8 0c             	shr    $0xc,%eax
c0104cdd:	89 c2                	mov    %eax,%edx
c0104cdf:	a1 80 bf 12 c0       	mov    0xc012bf80,%eax
c0104ce4:	39 c2                	cmp    %eax,%edx
c0104ce6:	72 1c                	jb     c0104d04 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0104ce8:	c7 44 24 08 ac af 10 	movl   $0xc010afac,0x8(%esp)
c0104cef:	c0 
c0104cf0:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
c0104cf7:	00 
c0104cf8:	c7 04 24 cb af 10 c0 	movl   $0xc010afcb,(%esp)
c0104cff:	e8 39 b7 ff ff       	call   c010043d <__panic>
    return &pages[PPN(pa)];
c0104d04:	a1 60 e0 12 c0       	mov    0xc012e060,%eax
c0104d09:	8b 55 08             	mov    0x8(%ebp),%edx
c0104d0c:	c1 ea 0c             	shr    $0xc,%edx
c0104d0f:	c1 e2 05             	shl    $0x5,%edx
c0104d12:	01 d0                	add    %edx,%eax
}
c0104d14:	c9                   	leave  
c0104d15:	c3                   	ret    

c0104d16 <pde2page>:
pde2page(pde_t pde) {
c0104d16:	55                   	push   %ebp
c0104d17:	89 e5                	mov    %esp,%ebp
c0104d19:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0104d1c:	8b 45 08             	mov    0x8(%ebp),%eax
c0104d1f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104d24:	89 04 24             	mov    %eax,(%esp)
c0104d27:	e8 a5 ff ff ff       	call   c0104cd1 <pa2page>
}
c0104d2c:	c9                   	leave  
c0104d2d:	c3                   	ret    

c0104d2e <mm_create>:
static void check_pgfault(void);

// mm_create -  alloc a mm_struct & initialize it.
struct mm_struct *
mm_create(void)
{
c0104d2e:	f3 0f 1e fb          	endbr32 
c0104d32:	55                   	push   %ebp
c0104d33:	89 e5                	mov    %esp,%ebp
c0104d35:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
c0104d38:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
c0104d3f:	e8 26 1f 00 00       	call   c0106c6a <kmalloc>
c0104d44:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (mm != NULL)
c0104d47:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104d4b:	74 59                	je     c0104da6 <mm_create+0x78>
    {
        list_init(&(mm->mmap_list));
c0104d4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d50:	89 45 f0             	mov    %eax,-0x10(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0104d53:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d56:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104d59:	89 50 04             	mov    %edx,0x4(%eax)
c0104d5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d5f:	8b 50 04             	mov    0x4(%eax),%edx
c0104d62:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d65:	89 10                	mov    %edx,(%eax)
}
c0104d67:	90                   	nop
        mm->mmap_cache = NULL;
c0104d68:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d6b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        mm->pgdir = NULL;
c0104d72:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d75:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        mm->map_count = 0;
c0104d7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d7f:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)

        if (swap_init_ok)
c0104d86:	a1 10 c0 12 c0       	mov    0xc012c010,%eax
c0104d8b:	85 c0                	test   %eax,%eax
c0104d8d:	74 0d                	je     c0104d9c <mm_create+0x6e>
            swap_init_mm(mm);
c0104d8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d92:	89 04 24             	mov    %eax,(%esp)
c0104d95:	e8 a3 0d 00 00       	call   c0105b3d <swap_init_mm>
c0104d9a:	eb 0a                	jmp    c0104da6 <mm_create+0x78>
        else
            mm->sm_priv = NULL;
c0104d9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d9f:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
    }
    return mm;
c0104da6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0104da9:	c9                   	leave  
c0104daa:	c3                   	ret    

c0104dab <vma_create>:

// vma_create - alloc a vma_struct & initialize it. (addr range: vm_start~vm_end)
struct vma_struct *
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags)
{
c0104dab:	f3 0f 1e fb          	endbr32 
c0104daf:	55                   	push   %ebp
c0104db0:	89 e5                	mov    %esp,%ebp
c0104db2:	83 ec 28             	sub    $0x28,%esp
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
c0104db5:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
c0104dbc:	e8 a9 1e 00 00       	call   c0106c6a <kmalloc>
c0104dc1:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (vma != NULL)
c0104dc4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104dc8:	74 1b                	je     c0104de5 <vma_create+0x3a>
    {
        vma->vm_start = vm_start;
c0104dca:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104dcd:	8b 55 08             	mov    0x8(%ebp),%edx
c0104dd0:	89 50 04             	mov    %edx,0x4(%eax)
        vma->vm_end = vm_end;
c0104dd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104dd6:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104dd9:	89 50 08             	mov    %edx,0x8(%eax)
        vma->vm_flags = vm_flags;
c0104ddc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ddf:	8b 55 10             	mov    0x10(%ebp),%edx
c0104de2:	89 50 0c             	mov    %edx,0xc(%eax)
    }
    return vma;
c0104de5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0104de8:	c9                   	leave  
c0104de9:	c3                   	ret    

c0104dea <find_vma>:

// find_vma - find a vma  (vma->vm_start <= addr <= vma_vm_end)
struct vma_struct *
find_vma(struct mm_struct *mm, uintptr_t addr)
{
c0104dea:	f3 0f 1e fb          	endbr32 
c0104dee:	55                   	push   %ebp
c0104def:	89 e5                	mov    %esp,%ebp
c0104df1:	83 ec 20             	sub    $0x20,%esp
    struct vma_struct *vma = NULL;
c0104df4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    if (mm != NULL)
c0104dfb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104dff:	0f 84 95 00 00 00    	je     c0104e9a <find_vma+0xb0>
    {
        vma = mm->mmap_cache;
c0104e05:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e08:	8b 40 08             	mov    0x8(%eax),%eax
c0104e0b:	89 45 fc             	mov    %eax,-0x4(%ebp)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
c0104e0e:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0104e12:	74 16                	je     c0104e2a <find_vma+0x40>
c0104e14:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104e17:	8b 40 04             	mov    0x4(%eax),%eax
c0104e1a:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0104e1d:	72 0b                	jb     c0104e2a <find_vma+0x40>
c0104e1f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104e22:	8b 40 08             	mov    0x8(%eax),%eax
c0104e25:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0104e28:	72 61                	jb     c0104e8b <find_vma+0xa1>
        {
            bool found = 0;
c0104e2a:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
            list_entry_t *list = &(mm->mmap_list), *le = list;
c0104e31:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e34:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104e37:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104e3a:	89 45 f4             	mov    %eax,-0xc(%ebp)
            while ((le = list_next(le)) != list)
c0104e3d:	eb 28                	jmp    c0104e67 <find_vma+0x7d>
            {
                vma = le2vma(le, list_link);
c0104e3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e42:	83 e8 10             	sub    $0x10,%eax
c0104e45:	89 45 fc             	mov    %eax,-0x4(%ebp)
                if (vma->vm_start <= addr && addr < vma->vm_end)
c0104e48:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104e4b:	8b 40 04             	mov    0x4(%eax),%eax
c0104e4e:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0104e51:	72 14                	jb     c0104e67 <find_vma+0x7d>
c0104e53:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104e56:	8b 40 08             	mov    0x8(%eax),%eax
c0104e59:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0104e5c:	73 09                	jae    c0104e67 <find_vma+0x7d>
                {
                    found = 1;
c0104e5e:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%ebp)
                    break;
c0104e65:	eb 17                	jmp    c0104e7e <find_vma+0x94>
c0104e67:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e6a:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0104e6d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104e70:	8b 40 04             	mov    0x4(%eax),%eax
            while ((le = list_next(le)) != list)
c0104e73:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104e76:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e79:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0104e7c:	75 c1                	jne    c0104e3f <find_vma+0x55>
                }
            }
            if (!found)
c0104e7e:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
c0104e82:	75 07                	jne    c0104e8b <find_vma+0xa1>
            {
                vma = NULL;
c0104e84:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
            }
        }
        if (vma != NULL)
c0104e8b:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0104e8f:	74 09                	je     c0104e9a <find_vma+0xb0>
        {
            mm->mmap_cache = vma;
c0104e91:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e94:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0104e97:	89 50 08             	mov    %edx,0x8(%eax)
        }
    }
    return vma;
c0104e9a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0104e9d:	c9                   	leave  
c0104e9e:	c3                   	ret    

c0104e9f <check_vma_overlap>:

// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
{
c0104e9f:	55                   	push   %ebp
c0104ea0:	89 e5                	mov    %esp,%ebp
c0104ea2:	83 ec 18             	sub    $0x18,%esp
    assert(prev->vm_start < prev->vm_end);
c0104ea5:	8b 45 08             	mov    0x8(%ebp),%eax
c0104ea8:	8b 50 04             	mov    0x4(%eax),%edx
c0104eab:	8b 45 08             	mov    0x8(%ebp),%eax
c0104eae:	8b 40 08             	mov    0x8(%eax),%eax
c0104eb1:	39 c2                	cmp    %eax,%edx
c0104eb3:	72 24                	jb     c0104ed9 <check_vma_overlap+0x3a>
c0104eb5:	c7 44 24 0c d9 af 10 	movl   $0xc010afd9,0xc(%esp)
c0104ebc:	c0 
c0104ebd:	c7 44 24 08 f7 af 10 	movl   $0xc010aff7,0x8(%esp)
c0104ec4:	c0 
c0104ec5:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
c0104ecc:	00 
c0104ecd:	c7 04 24 0c b0 10 c0 	movl   $0xc010b00c,(%esp)
c0104ed4:	e8 64 b5 ff ff       	call   c010043d <__panic>
    assert(prev->vm_end <= next->vm_start);
c0104ed9:	8b 45 08             	mov    0x8(%ebp),%eax
c0104edc:	8b 50 08             	mov    0x8(%eax),%edx
c0104edf:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104ee2:	8b 40 04             	mov    0x4(%eax),%eax
c0104ee5:	39 c2                	cmp    %eax,%edx
c0104ee7:	76 24                	jbe    c0104f0d <check_vma_overlap+0x6e>
c0104ee9:	c7 44 24 0c 1c b0 10 	movl   $0xc010b01c,0xc(%esp)
c0104ef0:	c0 
c0104ef1:	c7 44 24 08 f7 af 10 	movl   $0xc010aff7,0x8(%esp)
c0104ef8:	c0 
c0104ef9:	c7 44 24 04 75 00 00 	movl   $0x75,0x4(%esp)
c0104f00:	00 
c0104f01:	c7 04 24 0c b0 10 c0 	movl   $0xc010b00c,(%esp)
c0104f08:	e8 30 b5 ff ff       	call   c010043d <__panic>
    assert(next->vm_start < next->vm_end);
c0104f0d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104f10:	8b 50 04             	mov    0x4(%eax),%edx
c0104f13:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104f16:	8b 40 08             	mov    0x8(%eax),%eax
c0104f19:	39 c2                	cmp    %eax,%edx
c0104f1b:	72 24                	jb     c0104f41 <check_vma_overlap+0xa2>
c0104f1d:	c7 44 24 0c 3b b0 10 	movl   $0xc010b03b,0xc(%esp)
c0104f24:	c0 
c0104f25:	c7 44 24 08 f7 af 10 	movl   $0xc010aff7,0x8(%esp)
c0104f2c:	c0 
c0104f2d:	c7 44 24 04 76 00 00 	movl   $0x76,0x4(%esp)
c0104f34:	00 
c0104f35:	c7 04 24 0c b0 10 c0 	movl   $0xc010b00c,(%esp)
c0104f3c:	e8 fc b4 ff ff       	call   c010043d <__panic>
}
c0104f41:	90                   	nop
c0104f42:	c9                   	leave  
c0104f43:	c3                   	ret    

c0104f44 <insert_vma_struct>:

// insert_vma_struct -insert vma in mm's list link
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma)
{
c0104f44:	f3 0f 1e fb          	endbr32 
c0104f48:	55                   	push   %ebp
c0104f49:	89 e5                	mov    %esp,%ebp
c0104f4b:	83 ec 48             	sub    $0x48,%esp
    assert(vma->vm_start < vma->vm_end);
c0104f4e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104f51:	8b 50 04             	mov    0x4(%eax),%edx
c0104f54:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104f57:	8b 40 08             	mov    0x8(%eax),%eax
c0104f5a:	39 c2                	cmp    %eax,%edx
c0104f5c:	72 24                	jb     c0104f82 <insert_vma_struct+0x3e>
c0104f5e:	c7 44 24 0c 59 b0 10 	movl   $0xc010b059,0xc(%esp)
c0104f65:	c0 
c0104f66:	c7 44 24 08 f7 af 10 	movl   $0xc010aff7,0x8(%esp)
c0104f6d:	c0 
c0104f6e:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
c0104f75:	00 
c0104f76:	c7 04 24 0c b0 10 c0 	movl   $0xc010b00c,(%esp)
c0104f7d:	e8 bb b4 ff ff       	call   c010043d <__panic>
    list_entry_t *list = &(mm->mmap_list);
c0104f82:	8b 45 08             	mov    0x8(%ebp),%eax
c0104f85:	89 45 ec             	mov    %eax,-0x14(%ebp)
    list_entry_t *le_prev = list, *le_next;
c0104f88:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104f8b:	89 45 f4             	mov    %eax,-0xc(%ebp)

    list_entry_t *le = list;
c0104f8e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104f91:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while ((le = list_next(le)) != list)
c0104f94:	eb 1f                	jmp    c0104fb5 <insert_vma_struct+0x71>
    {
        struct vma_struct *mmap_prev = le2vma(le, list_link);
c0104f96:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f99:	83 e8 10             	sub    $0x10,%eax
c0104f9c:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if (mmap_prev->vm_start > vma->vm_start)
c0104f9f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104fa2:	8b 50 04             	mov    0x4(%eax),%edx
c0104fa5:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104fa8:	8b 40 04             	mov    0x4(%eax),%eax
c0104fab:	39 c2                	cmp    %eax,%edx
c0104fad:	77 1f                	ja     c0104fce <insert_vma_struct+0x8a>
        {
            break;
        }
        le_prev = le;
c0104faf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104fb2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104fb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104fb8:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0104fbb:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104fbe:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != list)
c0104fc1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104fc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104fc7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0104fca:	75 ca                	jne    c0104f96 <insert_vma_struct+0x52>
c0104fcc:	eb 01                	jmp    c0104fcf <insert_vma_struct+0x8b>
            break;
c0104fce:	90                   	nop
c0104fcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104fd2:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0104fd5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104fd8:	8b 40 04             	mov    0x4(%eax),%eax
    }

    le_next = list_next(le_prev);
c0104fdb:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    /* check overlap */
    if (le_prev != list)
c0104fde:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104fe1:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0104fe4:	74 15                	je     c0104ffb <insert_vma_struct+0xb7>
    {
        check_vma_overlap(le2vma(le_prev, list_link), vma);
c0104fe6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104fe9:	8d 50 f0             	lea    -0x10(%eax),%edx
c0104fec:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104fef:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104ff3:	89 14 24             	mov    %edx,(%esp)
c0104ff6:	e8 a4 fe ff ff       	call   c0104e9f <check_vma_overlap>
    }
    if (le_next != list)
c0104ffb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104ffe:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0105001:	74 15                	je     c0105018 <insert_vma_struct+0xd4>
    {
        check_vma_overlap(vma, le2vma(le_next, list_link));
c0105003:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105006:	83 e8 10             	sub    $0x10,%eax
c0105009:	89 44 24 04          	mov    %eax,0x4(%esp)
c010500d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105010:	89 04 24             	mov    %eax,(%esp)
c0105013:	e8 87 fe ff ff       	call   c0104e9f <check_vma_overlap>
    }

    vma->vm_mm = mm;
c0105018:	8b 45 0c             	mov    0xc(%ebp),%eax
c010501b:	8b 55 08             	mov    0x8(%ebp),%edx
c010501e:	89 10                	mov    %edx,(%eax)
    list_add_after(le_prev, &(vma->list_link));
c0105020:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105023:	8d 50 10             	lea    0x10(%eax),%edx
c0105026:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105029:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010502c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
    __list_add(elm, listelm, listelm->next);
c010502f:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105032:	8b 40 04             	mov    0x4(%eax),%eax
c0105035:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105038:	89 55 d0             	mov    %edx,-0x30(%ebp)
c010503b:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010503e:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0105041:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0105044:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0105047:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010504a:	89 10                	mov    %edx,(%eax)
c010504c:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010504f:	8b 10                	mov    (%eax),%edx
c0105051:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0105054:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0105057:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010505a:	8b 55 c8             	mov    -0x38(%ebp),%edx
c010505d:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0105060:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105063:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0105066:	89 10                	mov    %edx,(%eax)
}
c0105068:	90                   	nop
}
c0105069:	90                   	nop

    mm->map_count++;
c010506a:	8b 45 08             	mov    0x8(%ebp),%eax
c010506d:	8b 40 10             	mov    0x10(%eax),%eax
c0105070:	8d 50 01             	lea    0x1(%eax),%edx
c0105073:	8b 45 08             	mov    0x8(%ebp),%eax
c0105076:	89 50 10             	mov    %edx,0x10(%eax)
}
c0105079:	90                   	nop
c010507a:	c9                   	leave  
c010507b:	c3                   	ret    

c010507c <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void mm_destroy(struct mm_struct *mm)
{
c010507c:	f3 0f 1e fb          	endbr32 
c0105080:	55                   	push   %ebp
c0105081:	89 e5                	mov    %esp,%ebp
c0105083:	83 ec 38             	sub    $0x38,%esp

    list_entry_t *list = &(mm->mmap_list), *le;
c0105086:	8b 45 08             	mov    0x8(%ebp),%eax
c0105089:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_next(list)) != list)
c010508c:	eb 38                	jmp    c01050c6 <mm_destroy+0x4a>
c010508e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105091:	89 45 ec             	mov    %eax,-0x14(%ebp)
    __list_del(listelm->prev, listelm->next);
c0105094:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105097:	8b 40 04             	mov    0x4(%eax),%eax
c010509a:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010509d:	8b 12                	mov    (%edx),%edx
c010509f:	89 55 e8             	mov    %edx,-0x18(%ebp)
c01050a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c01050a5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01050a8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01050ab:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01050ae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01050b1:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01050b4:	89 10                	mov    %edx,(%eax)
}
c01050b6:	90                   	nop
}
c01050b7:	90                   	nop
    {
        list_del(le);
        kfree(le2vma(le, list_link)); //kfree vma
c01050b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01050bb:	83 e8 10             	sub    $0x10,%eax
c01050be:	89 04 24             	mov    %eax,(%esp)
c01050c1:	e8 c3 1b 00 00       	call   c0106c89 <kfree>
c01050c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01050c9:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return listelm->next;
c01050cc:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01050cf:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(list)) != list)
c01050d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01050d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01050d8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01050db:	75 b1                	jne    c010508e <mm_destroy+0x12>
    }
    kfree(mm); //kfree mm
c01050dd:	8b 45 08             	mov    0x8(%ebp),%eax
c01050e0:	89 04 24             	mov    %eax,(%esp)
c01050e3:	e8 a1 1b 00 00       	call   c0106c89 <kfree>
    mm = NULL;
c01050e8:	c7 45 08 00 00 00 00 	movl   $0x0,0x8(%ebp)
}
c01050ef:	90                   	nop
c01050f0:	c9                   	leave  
c01050f1:	c3                   	ret    

c01050f2 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void vmm_init(void)
{
c01050f2:	f3 0f 1e fb          	endbr32 
c01050f6:	55                   	push   %ebp
c01050f7:	89 e5                	mov    %esp,%ebp
c01050f9:	83 ec 08             	sub    $0x8,%esp
    check_vmm();
c01050fc:	e8 03 00 00 00       	call   c0105104 <check_vmm>
}
c0105101:	90                   	nop
c0105102:	c9                   	leave  
c0105103:	c3                   	ret    

c0105104 <check_vmm>:

// check_vmm - check correctness of vmm
static void
check_vmm(void)
{
c0105104:	f3 0f 1e fb          	endbr32 
c0105108:	55                   	push   %ebp
c0105109:	89 e5                	mov    %esp,%ebp
c010510b:	83 ec 28             	sub    $0x28,%esp
    size_t nr_free_pages_store = nr_free_pages();
c010510e:	e8 a2 e4 ff ff       	call   c01035b5 <nr_free_pages>
c0105113:	89 45 f4             	mov    %eax,-0xc(%ebp)

    check_vma_struct();
c0105116:	e8 14 00 00 00       	call   c010512f <check_vma_struct>
    check_pgfault();
c010511b:	e8 a5 04 00 00       	call   c01055c5 <check_pgfault>

    //   assert(nr_free_pages_store == nr_free_pages());

    cprintf("check_vmm() succeeded.\n");
c0105120:	c7 04 24 75 b0 10 c0 	movl   $0xc010b075,(%esp)
c0105127:	e8 a5 b1 ff ff       	call   c01002d1 <cprintf>
}
c010512c:	90                   	nop
c010512d:	c9                   	leave  
c010512e:	c3                   	ret    

c010512f <check_vma_struct>:

static void
check_vma_struct(void)
{
c010512f:	f3 0f 1e fb          	endbr32 
c0105133:	55                   	push   %ebp
c0105134:	89 e5                	mov    %esp,%ebp
c0105136:	83 ec 68             	sub    $0x68,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0105139:	e8 77 e4 ff ff       	call   c01035b5 <nr_free_pages>
c010513e:	89 45 ec             	mov    %eax,-0x14(%ebp)

    struct mm_struct *mm = mm_create();
c0105141:	e8 e8 fb ff ff       	call   c0104d2e <mm_create>
c0105146:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(mm != NULL);
c0105149:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010514d:	75 24                	jne    c0105173 <check_vma_struct+0x44>
c010514f:	c7 44 24 0c 8d b0 10 	movl   $0xc010b08d,0xc(%esp)
c0105156:	c0 
c0105157:	c7 44 24 08 f7 af 10 	movl   $0xc010aff7,0x8(%esp)
c010515e:	c0 
c010515f:	c7 44 24 04 c6 00 00 	movl   $0xc6,0x4(%esp)
c0105166:	00 
c0105167:	c7 04 24 0c b0 10 c0 	movl   $0xc010b00c,(%esp)
c010516e:	e8 ca b2 ff ff       	call   c010043d <__panic>

    int step1 = 10, step2 = step1 * 10;
c0105173:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%ebp)
c010517a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010517d:	89 d0                	mov    %edx,%eax
c010517f:	c1 e0 02             	shl    $0x2,%eax
c0105182:	01 d0                	add    %edx,%eax
c0105184:	01 c0                	add    %eax,%eax
c0105186:	89 45 e0             	mov    %eax,-0x20(%ebp)

    int i;
    for (i = step1; i >= 1; i--)
c0105189:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010518c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010518f:	eb 6f                	jmp    c0105200 <check_vma_struct+0xd1>
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c0105191:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105194:	89 d0                	mov    %edx,%eax
c0105196:	c1 e0 02             	shl    $0x2,%eax
c0105199:	01 d0                	add    %edx,%eax
c010519b:	83 c0 02             	add    $0x2,%eax
c010519e:	89 c1                	mov    %eax,%ecx
c01051a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01051a3:	89 d0                	mov    %edx,%eax
c01051a5:	c1 e0 02             	shl    $0x2,%eax
c01051a8:	01 d0                	add    %edx,%eax
c01051aa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01051b1:	00 
c01051b2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c01051b6:	89 04 24             	mov    %eax,(%esp)
c01051b9:	e8 ed fb ff ff       	call   c0104dab <vma_create>
c01051be:	89 45 bc             	mov    %eax,-0x44(%ebp)
        assert(vma != NULL);
c01051c1:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c01051c5:	75 24                	jne    c01051eb <check_vma_struct+0xbc>
c01051c7:	c7 44 24 0c 98 b0 10 	movl   $0xc010b098,0xc(%esp)
c01051ce:	c0 
c01051cf:	c7 44 24 08 f7 af 10 	movl   $0xc010aff7,0x8(%esp)
c01051d6:	c0 
c01051d7:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
c01051de:	00 
c01051df:	c7 04 24 0c b0 10 c0 	movl   $0xc010b00c,(%esp)
c01051e6:	e8 52 b2 ff ff       	call   c010043d <__panic>
        insert_vma_struct(mm, vma);
c01051eb:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01051ee:	89 44 24 04          	mov    %eax,0x4(%esp)
c01051f2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01051f5:	89 04 24             	mov    %eax,(%esp)
c01051f8:	e8 47 fd ff ff       	call   c0104f44 <insert_vma_struct>
    for (i = step1; i >= 1; i--)
c01051fd:	ff 4d f4             	decl   -0xc(%ebp)
c0105200:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105204:	7f 8b                	jg     c0105191 <check_vma_struct+0x62>
    }

    for (i = step1 + 1; i <= step2; i++)
c0105206:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105209:	40                   	inc    %eax
c010520a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010520d:	eb 6f                	jmp    c010527e <check_vma_struct+0x14f>
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c010520f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105212:	89 d0                	mov    %edx,%eax
c0105214:	c1 e0 02             	shl    $0x2,%eax
c0105217:	01 d0                	add    %edx,%eax
c0105219:	83 c0 02             	add    $0x2,%eax
c010521c:	89 c1                	mov    %eax,%ecx
c010521e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105221:	89 d0                	mov    %edx,%eax
c0105223:	c1 e0 02             	shl    $0x2,%eax
c0105226:	01 d0                	add    %edx,%eax
c0105228:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010522f:	00 
c0105230:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0105234:	89 04 24             	mov    %eax,(%esp)
c0105237:	e8 6f fb ff ff       	call   c0104dab <vma_create>
c010523c:	89 45 c0             	mov    %eax,-0x40(%ebp)
        assert(vma != NULL);
c010523f:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
c0105243:	75 24                	jne    c0105269 <check_vma_struct+0x13a>
c0105245:	c7 44 24 0c 98 b0 10 	movl   $0xc010b098,0xc(%esp)
c010524c:	c0 
c010524d:	c7 44 24 08 f7 af 10 	movl   $0xc010aff7,0x8(%esp)
c0105254:	c0 
c0105255:	c7 44 24 04 d5 00 00 	movl   $0xd5,0x4(%esp)
c010525c:	00 
c010525d:	c7 04 24 0c b0 10 c0 	movl   $0xc010b00c,(%esp)
c0105264:	e8 d4 b1 ff ff       	call   c010043d <__panic>
        insert_vma_struct(mm, vma);
c0105269:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010526c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105270:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105273:	89 04 24             	mov    %eax,(%esp)
c0105276:	e8 c9 fc ff ff       	call   c0104f44 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i++)
c010527b:	ff 45 f4             	incl   -0xc(%ebp)
c010527e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105281:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0105284:	7e 89                	jle    c010520f <check_vma_struct+0xe0>
    }

    list_entry_t *le = list_next(&(mm->mmap_list));
c0105286:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105289:	89 45 b8             	mov    %eax,-0x48(%ebp)
c010528c:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010528f:	8b 40 04             	mov    0x4(%eax),%eax
c0105292:	89 45 f0             	mov    %eax,-0x10(%ebp)

    for (i = 1; i <= step2; i++)
c0105295:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
c010529c:	e9 96 00 00 00       	jmp    c0105337 <check_vma_struct+0x208>
    {
        assert(le != &(mm->mmap_list));
c01052a1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01052a4:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01052a7:	75 24                	jne    c01052cd <check_vma_struct+0x19e>
c01052a9:	c7 44 24 0c a4 b0 10 	movl   $0xc010b0a4,0xc(%esp)
c01052b0:	c0 
c01052b1:	c7 44 24 08 f7 af 10 	movl   $0xc010aff7,0x8(%esp)
c01052b8:	c0 
c01052b9:	c7 44 24 04 dd 00 00 	movl   $0xdd,0x4(%esp)
c01052c0:	00 
c01052c1:	c7 04 24 0c b0 10 c0 	movl   $0xc010b00c,(%esp)
c01052c8:	e8 70 b1 ff ff       	call   c010043d <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
c01052cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01052d0:	83 e8 10             	sub    $0x10,%eax
c01052d3:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
c01052d6:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01052d9:	8b 48 04             	mov    0x4(%eax),%ecx
c01052dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01052df:	89 d0                	mov    %edx,%eax
c01052e1:	c1 e0 02             	shl    $0x2,%eax
c01052e4:	01 d0                	add    %edx,%eax
c01052e6:	39 c1                	cmp    %eax,%ecx
c01052e8:	75 17                	jne    c0105301 <check_vma_struct+0x1d2>
c01052ea:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01052ed:	8b 48 08             	mov    0x8(%eax),%ecx
c01052f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01052f3:	89 d0                	mov    %edx,%eax
c01052f5:	c1 e0 02             	shl    $0x2,%eax
c01052f8:	01 d0                	add    %edx,%eax
c01052fa:	83 c0 02             	add    $0x2,%eax
c01052fd:	39 c1                	cmp    %eax,%ecx
c01052ff:	74 24                	je     c0105325 <check_vma_struct+0x1f6>
c0105301:	c7 44 24 0c bc b0 10 	movl   $0xc010b0bc,0xc(%esp)
c0105308:	c0 
c0105309:	c7 44 24 08 f7 af 10 	movl   $0xc010aff7,0x8(%esp)
c0105310:	c0 
c0105311:	c7 44 24 04 df 00 00 	movl   $0xdf,0x4(%esp)
c0105318:	00 
c0105319:	c7 04 24 0c b0 10 c0 	movl   $0xc010b00c,(%esp)
c0105320:	e8 18 b1 ff ff       	call   c010043d <__panic>
c0105325:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105328:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c010532b:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010532e:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0105331:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for (i = 1; i <= step2; i++)
c0105334:	ff 45 f4             	incl   -0xc(%ebp)
c0105337:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010533a:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c010533d:	0f 8e 5e ff ff ff    	jle    c01052a1 <check_vma_struct+0x172>
    }

    for (i = 5; i <= 5 * step2; i += 5)
c0105343:	c7 45 f4 05 00 00 00 	movl   $0x5,-0xc(%ebp)
c010534a:	e9 cb 01 00 00       	jmp    c010551a <check_vma_struct+0x3eb>
    {
        struct vma_struct *vma1 = find_vma(mm, i);
c010534f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105352:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105356:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105359:	89 04 24             	mov    %eax,(%esp)
c010535c:	e8 89 fa ff ff       	call   c0104dea <find_vma>
c0105361:	89 45 d8             	mov    %eax,-0x28(%ebp)
        assert(vma1 != NULL);
c0105364:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0105368:	75 24                	jne    c010538e <check_vma_struct+0x25f>
c010536a:	c7 44 24 0c f1 b0 10 	movl   $0xc010b0f1,0xc(%esp)
c0105371:	c0 
c0105372:	c7 44 24 08 f7 af 10 	movl   $0xc010aff7,0x8(%esp)
c0105379:	c0 
c010537a:	c7 44 24 04 e6 00 00 	movl   $0xe6,0x4(%esp)
c0105381:	00 
c0105382:	c7 04 24 0c b0 10 c0 	movl   $0xc010b00c,(%esp)
c0105389:	e8 af b0 ff ff       	call   c010043d <__panic>
        struct vma_struct *vma2 = find_vma(mm, i + 1);
c010538e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105391:	40                   	inc    %eax
c0105392:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105396:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105399:	89 04 24             	mov    %eax,(%esp)
c010539c:	e8 49 fa ff ff       	call   c0104dea <find_vma>
c01053a1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(vma2 != NULL);
c01053a4:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
c01053a8:	75 24                	jne    c01053ce <check_vma_struct+0x29f>
c01053aa:	c7 44 24 0c fe b0 10 	movl   $0xc010b0fe,0xc(%esp)
c01053b1:	c0 
c01053b2:	c7 44 24 08 f7 af 10 	movl   $0xc010aff7,0x8(%esp)
c01053b9:	c0 
c01053ba:	c7 44 24 04 e8 00 00 	movl   $0xe8,0x4(%esp)
c01053c1:	00 
c01053c2:	c7 04 24 0c b0 10 c0 	movl   $0xc010b00c,(%esp)
c01053c9:	e8 6f b0 ff ff       	call   c010043d <__panic>
        struct vma_struct *vma3 = find_vma(mm, i + 2);
c01053ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01053d1:	83 c0 02             	add    $0x2,%eax
c01053d4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01053d8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01053db:	89 04 24             	mov    %eax,(%esp)
c01053de:	e8 07 fa ff ff       	call   c0104dea <find_vma>
c01053e3:	89 45 d0             	mov    %eax,-0x30(%ebp)
        assert(vma3 == NULL);
c01053e6:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c01053ea:	74 24                	je     c0105410 <check_vma_struct+0x2e1>
c01053ec:	c7 44 24 0c 0b b1 10 	movl   $0xc010b10b,0xc(%esp)
c01053f3:	c0 
c01053f4:	c7 44 24 08 f7 af 10 	movl   $0xc010aff7,0x8(%esp)
c01053fb:	c0 
c01053fc:	c7 44 24 04 ea 00 00 	movl   $0xea,0x4(%esp)
c0105403:	00 
c0105404:	c7 04 24 0c b0 10 c0 	movl   $0xc010b00c,(%esp)
c010540b:	e8 2d b0 ff ff       	call   c010043d <__panic>
        struct vma_struct *vma4 = find_vma(mm, i + 3);
c0105410:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105413:	83 c0 03             	add    $0x3,%eax
c0105416:	89 44 24 04          	mov    %eax,0x4(%esp)
c010541a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010541d:	89 04 24             	mov    %eax,(%esp)
c0105420:	e8 c5 f9 ff ff       	call   c0104dea <find_vma>
c0105425:	89 45 cc             	mov    %eax,-0x34(%ebp)
        assert(vma4 == NULL);
c0105428:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c010542c:	74 24                	je     c0105452 <check_vma_struct+0x323>
c010542e:	c7 44 24 0c 18 b1 10 	movl   $0xc010b118,0xc(%esp)
c0105435:	c0 
c0105436:	c7 44 24 08 f7 af 10 	movl   $0xc010aff7,0x8(%esp)
c010543d:	c0 
c010543e:	c7 44 24 04 ec 00 00 	movl   $0xec,0x4(%esp)
c0105445:	00 
c0105446:	c7 04 24 0c b0 10 c0 	movl   $0xc010b00c,(%esp)
c010544d:	e8 eb af ff ff       	call   c010043d <__panic>
        struct vma_struct *vma5 = find_vma(mm, i + 4);
c0105452:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105455:	83 c0 04             	add    $0x4,%eax
c0105458:	89 44 24 04          	mov    %eax,0x4(%esp)
c010545c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010545f:	89 04 24             	mov    %eax,(%esp)
c0105462:	e8 83 f9 ff ff       	call   c0104dea <find_vma>
c0105467:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(vma5 == NULL);
c010546a:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c010546e:	74 24                	je     c0105494 <check_vma_struct+0x365>
c0105470:	c7 44 24 0c 25 b1 10 	movl   $0xc010b125,0xc(%esp)
c0105477:	c0 
c0105478:	c7 44 24 08 f7 af 10 	movl   $0xc010aff7,0x8(%esp)
c010547f:	c0 
c0105480:	c7 44 24 04 ee 00 00 	movl   $0xee,0x4(%esp)
c0105487:	00 
c0105488:	c7 04 24 0c b0 10 c0 	movl   $0xc010b00c,(%esp)
c010548f:	e8 a9 af ff ff       	call   c010043d <__panic>

        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
c0105494:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105497:	8b 50 04             	mov    0x4(%eax),%edx
c010549a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010549d:	39 c2                	cmp    %eax,%edx
c010549f:	75 10                	jne    c01054b1 <check_vma_struct+0x382>
c01054a1:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01054a4:	8b 40 08             	mov    0x8(%eax),%eax
c01054a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01054aa:	83 c2 02             	add    $0x2,%edx
c01054ad:	39 d0                	cmp    %edx,%eax
c01054af:	74 24                	je     c01054d5 <check_vma_struct+0x3a6>
c01054b1:	c7 44 24 0c 34 b1 10 	movl   $0xc010b134,0xc(%esp)
c01054b8:	c0 
c01054b9:	c7 44 24 08 f7 af 10 	movl   $0xc010aff7,0x8(%esp)
c01054c0:	c0 
c01054c1:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
c01054c8:	00 
c01054c9:	c7 04 24 0c b0 10 c0 	movl   $0xc010b00c,(%esp)
c01054d0:	e8 68 af ff ff       	call   c010043d <__panic>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
c01054d5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01054d8:	8b 50 04             	mov    0x4(%eax),%edx
c01054db:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01054de:	39 c2                	cmp    %eax,%edx
c01054e0:	75 10                	jne    c01054f2 <check_vma_struct+0x3c3>
c01054e2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01054e5:	8b 40 08             	mov    0x8(%eax),%eax
c01054e8:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01054eb:	83 c2 02             	add    $0x2,%edx
c01054ee:	39 d0                	cmp    %edx,%eax
c01054f0:	74 24                	je     c0105516 <check_vma_struct+0x3e7>
c01054f2:	c7 44 24 0c 64 b1 10 	movl   $0xc010b164,0xc(%esp)
c01054f9:	c0 
c01054fa:	c7 44 24 08 f7 af 10 	movl   $0xc010aff7,0x8(%esp)
c0105501:	c0 
c0105502:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
c0105509:	00 
c010550a:	c7 04 24 0c b0 10 c0 	movl   $0xc010b00c,(%esp)
c0105511:	e8 27 af ff ff       	call   c010043d <__panic>
    for (i = 5; i <= 5 * step2; i += 5)
c0105516:	83 45 f4 05          	addl   $0x5,-0xc(%ebp)
c010551a:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010551d:	89 d0                	mov    %edx,%eax
c010551f:	c1 e0 02             	shl    $0x2,%eax
c0105522:	01 d0                	add    %edx,%eax
c0105524:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0105527:	0f 8e 22 fe ff ff    	jle    c010534f <check_vma_struct+0x220>
    }

    for (i = 4; i >= 0; i--)
c010552d:	c7 45 f4 04 00 00 00 	movl   $0x4,-0xc(%ebp)
c0105534:	eb 6f                	jmp    c01055a5 <check_vma_struct+0x476>
    {
        struct vma_struct *vma_below_5 = find_vma(mm, i);
c0105536:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105539:	89 44 24 04          	mov    %eax,0x4(%esp)
c010553d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105540:	89 04 24             	mov    %eax,(%esp)
c0105543:	e8 a2 f8 ff ff       	call   c0104dea <find_vma>
c0105548:	89 45 dc             	mov    %eax,-0x24(%ebp)
        if (vma_below_5 != NULL)
c010554b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010554f:	74 27                	je     c0105578 <check_vma_struct+0x449>
        {
            cprintf("vma_below_5: i %x, start %x, end %x\n", i, vma_below_5->vm_start, vma_below_5->vm_end);
c0105551:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105554:	8b 50 08             	mov    0x8(%eax),%edx
c0105557:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010555a:	8b 40 04             	mov    0x4(%eax),%eax
c010555d:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0105561:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105565:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105568:	89 44 24 04          	mov    %eax,0x4(%esp)
c010556c:	c7 04 24 94 b1 10 c0 	movl   $0xc010b194,(%esp)
c0105573:	e8 59 ad ff ff       	call   c01002d1 <cprintf>
        }
        assert(vma_below_5 == NULL);
c0105578:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010557c:	74 24                	je     c01055a2 <check_vma_struct+0x473>
c010557e:	c7 44 24 0c b9 b1 10 	movl   $0xc010b1b9,0xc(%esp)
c0105585:	c0 
c0105586:	c7 44 24 08 f7 af 10 	movl   $0xc010aff7,0x8(%esp)
c010558d:	c0 
c010558e:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
c0105595:	00 
c0105596:	c7 04 24 0c b0 10 c0 	movl   $0xc010b00c,(%esp)
c010559d:	e8 9b ae ff ff       	call   c010043d <__panic>
    for (i = 4; i >= 0; i--)
c01055a2:	ff 4d f4             	decl   -0xc(%ebp)
c01055a5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01055a9:	79 8b                	jns    c0105536 <check_vma_struct+0x407>
    }

    mm_destroy(mm);
c01055ab:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01055ae:	89 04 24             	mov    %eax,(%esp)
c01055b1:	e8 c6 fa ff ff       	call   c010507c <mm_destroy>

    //    assert(nr_free_pages_store == nr_free_pages());

    cprintf("check_vma_struct() succeeded!\n");
c01055b6:	c7 04 24 d0 b1 10 c0 	movl   $0xc010b1d0,(%esp)
c01055bd:	e8 0f ad ff ff       	call   c01002d1 <cprintf>
}
c01055c2:	90                   	nop
c01055c3:	c9                   	leave  
c01055c4:	c3                   	ret    

c01055c5 <check_pgfault>:
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void)
{
c01055c5:	f3 0f 1e fb          	endbr32 
c01055c9:	55                   	push   %ebp
c01055ca:	89 e5                	mov    %esp,%ebp
c01055cc:	83 ec 38             	sub    $0x38,%esp
    size_t nr_free_pages_store = nr_free_pages();
c01055cf:	e8 e1 df ff ff       	call   c01035b5 <nr_free_pages>
c01055d4:	89 45 ec             	mov    %eax,-0x14(%ebp)

    check_mm_struct = mm_create();
c01055d7:	e8 52 f7 ff ff       	call   c0104d2e <mm_create>
c01055dc:	a3 64 e0 12 c0       	mov    %eax,0xc012e064
    assert(check_mm_struct != NULL);
c01055e1:	a1 64 e0 12 c0       	mov    0xc012e064,%eax
c01055e6:	85 c0                	test   %eax,%eax
c01055e8:	75 24                	jne    c010560e <check_pgfault+0x49>
c01055ea:	c7 44 24 0c ef b1 10 	movl   $0xc010b1ef,0xc(%esp)
c01055f1:	c0 
c01055f2:	c7 44 24 08 f7 af 10 	movl   $0xc010aff7,0x8(%esp)
c01055f9:	c0 
c01055fa:	c7 44 24 04 0e 01 00 	movl   $0x10e,0x4(%esp)
c0105601:	00 
c0105602:	c7 04 24 0c b0 10 c0 	movl   $0xc010b00c,(%esp)
c0105609:	e8 2f ae ff ff       	call   c010043d <__panic>

    struct mm_struct *mm = check_mm_struct;
c010560e:	a1 64 e0 12 c0       	mov    0xc012e064,%eax
c0105613:	89 45 e8             	mov    %eax,-0x18(%ebp)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
c0105616:	8b 15 e0 89 12 c0    	mov    0xc01289e0,%edx
c010561c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010561f:	89 50 0c             	mov    %edx,0xc(%eax)
c0105622:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105625:	8b 40 0c             	mov    0xc(%eax),%eax
c0105628:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(pgdir[0] == 0);
c010562b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010562e:	8b 00                	mov    (%eax),%eax
c0105630:	85 c0                	test   %eax,%eax
c0105632:	74 24                	je     c0105658 <check_pgfault+0x93>
c0105634:	c7 44 24 0c 07 b2 10 	movl   $0xc010b207,0xc(%esp)
c010563b:	c0 
c010563c:	c7 44 24 08 f7 af 10 	movl   $0xc010aff7,0x8(%esp)
c0105643:	c0 
c0105644:	c7 44 24 04 12 01 00 	movl   $0x112,0x4(%esp)
c010564b:	00 
c010564c:	c7 04 24 0c b0 10 c0 	movl   $0xc010b00c,(%esp)
c0105653:	e8 e5 ad ff ff       	call   c010043d <__panic>

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
c0105658:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
c010565f:	00 
c0105660:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
c0105667:	00 
c0105668:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010566f:	e8 37 f7 ff ff       	call   c0104dab <vma_create>
c0105674:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(vma != NULL);
c0105677:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c010567b:	75 24                	jne    c01056a1 <check_pgfault+0xdc>
c010567d:	c7 44 24 0c 98 b0 10 	movl   $0xc010b098,0xc(%esp)
c0105684:	c0 
c0105685:	c7 44 24 08 f7 af 10 	movl   $0xc010aff7,0x8(%esp)
c010568c:	c0 
c010568d:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
c0105694:	00 
c0105695:	c7 04 24 0c b0 10 c0 	movl   $0xc010b00c,(%esp)
c010569c:	e8 9c ad ff ff       	call   c010043d <__panic>

    insert_vma_struct(mm, vma);
c01056a1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01056a4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01056a8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01056ab:	89 04 24             	mov    %eax,(%esp)
c01056ae:	e8 91 f8 ff ff       	call   c0104f44 <insert_vma_struct>

    uintptr_t addr = 0x100;
c01056b3:	c7 45 dc 00 01 00 00 	movl   $0x100,-0x24(%ebp)
    assert(find_vma(mm, addr) == vma);
c01056ba:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01056bd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01056c1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01056c4:	89 04 24             	mov    %eax,(%esp)
c01056c7:	e8 1e f7 ff ff       	call   c0104dea <find_vma>
c01056cc:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c01056cf:	74 24                	je     c01056f5 <check_pgfault+0x130>
c01056d1:	c7 44 24 0c 15 b2 10 	movl   $0xc010b215,0xc(%esp)
c01056d8:	c0 
c01056d9:	c7 44 24 08 f7 af 10 	movl   $0xc010aff7,0x8(%esp)
c01056e0:	c0 
c01056e1:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
c01056e8:	00 
c01056e9:	c7 04 24 0c b0 10 c0 	movl   $0xc010b00c,(%esp)
c01056f0:	e8 48 ad ff ff       	call   c010043d <__panic>

    int i, sum = 0;
c01056f5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (i = 0; i < 100; i++)
c01056fc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0105703:	eb 16                	jmp    c010571b <check_pgfault+0x156>
    {
        *(char *)(addr + i) = i;
c0105705:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105708:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010570b:	01 d0                	add    %edx,%eax
c010570d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105710:	88 10                	mov    %dl,(%eax)
        sum += i;
c0105712:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105715:	01 45 f0             	add    %eax,-0x10(%ebp)
    for (i = 0; i < 100; i++)
c0105718:	ff 45 f4             	incl   -0xc(%ebp)
c010571b:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c010571f:	7e e4                	jle    c0105705 <check_pgfault+0x140>
    }
    for (i = 0; i < 100; i++)
c0105721:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0105728:	eb 14                	jmp    c010573e <check_pgfault+0x179>
    {
        sum -= *(char *)(addr + i);
c010572a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010572d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105730:	01 d0                	add    %edx,%eax
c0105732:	0f b6 00             	movzbl (%eax),%eax
c0105735:	0f be c0             	movsbl %al,%eax
c0105738:	29 45 f0             	sub    %eax,-0x10(%ebp)
    for (i = 0; i < 100; i++)
c010573b:	ff 45 f4             	incl   -0xc(%ebp)
c010573e:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c0105742:	7e e6                	jle    c010572a <check_pgfault+0x165>
    }
    assert(sum == 0);
c0105744:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105748:	74 24                	je     c010576e <check_pgfault+0x1a9>
c010574a:	c7 44 24 0c 2f b2 10 	movl   $0xc010b22f,0xc(%esp)
c0105751:	c0 
c0105752:	c7 44 24 08 f7 af 10 	movl   $0xc010aff7,0x8(%esp)
c0105759:	c0 
c010575a:	c7 44 24 04 26 01 00 	movl   $0x126,0x4(%esp)
c0105761:	00 
c0105762:	c7 04 24 0c b0 10 c0 	movl   $0xc010b00c,(%esp)
c0105769:	e8 cf ac ff ff       	call   c010043d <__panic>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
c010576e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105771:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0105774:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105777:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010577c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105780:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105783:	89 04 24             	mov    %eax,(%esp)
c0105786:	e8 50 e6 ff ff       	call   c0103ddb <page_remove>
    free_page(pde2page(pgdir[0]));
c010578b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010578e:	8b 00                	mov    (%eax),%eax
c0105790:	89 04 24             	mov    %eax,(%esp)
c0105793:	e8 7e f5 ff ff       	call   c0104d16 <pde2page>
c0105798:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010579f:	00 
c01057a0:	89 04 24             	mov    %eax,(%esp)
c01057a3:	e8 d6 dd ff ff       	call   c010357e <free_pages>
    pgdir[0] = 0;
c01057a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01057ab:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    mm->pgdir = NULL;
c01057b1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01057b4:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    mm_destroy(mm);
c01057bb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01057be:	89 04 24             	mov    %eax,(%esp)
c01057c1:	e8 b6 f8 ff ff       	call   c010507c <mm_destroy>
    check_mm_struct = NULL;
c01057c6:	c7 05 64 e0 12 c0 00 	movl   $0x0,0xc012e064
c01057cd:	00 00 00 

    assert(nr_free_pages_store == nr_free_pages());
c01057d0:	e8 e0 dd ff ff       	call   c01035b5 <nr_free_pages>
c01057d5:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c01057d8:	74 24                	je     c01057fe <check_pgfault+0x239>
c01057da:	c7 44 24 0c 38 b2 10 	movl   $0xc010b238,0xc(%esp)
c01057e1:	c0 
c01057e2:	c7 44 24 08 f7 af 10 	movl   $0xc010aff7,0x8(%esp)
c01057e9:	c0 
c01057ea:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
c01057f1:	00 
c01057f2:	c7 04 24 0c b0 10 c0 	movl   $0xc010b00c,(%esp)
c01057f9:	e8 3f ac ff ff       	call   c010043d <__panic>

    cprintf("check_pgfault() succeeded!\n");
c01057fe:	c7 04 24 5f b2 10 c0 	movl   $0xc010b25f,(%esp)
c0105805:	e8 c7 aa ff ff       	call   c01002d1 <cprintf>
}
c010580a:	90                   	nop
c010580b:	c9                   	leave  
c010580c:	c3                   	ret    

c010580d <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr)
{
c010580d:	f3 0f 1e fb          	endbr32 
c0105811:	55                   	push   %ebp
c0105812:	89 e5                	mov    %esp,%ebp
c0105814:	83 ec 38             	sub    $0x38,%esp
    int ret = -E_INVAL;
c0105817:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
c010581e:	8b 45 10             	mov    0x10(%ebp),%eax
c0105821:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105825:	8b 45 08             	mov    0x8(%ebp),%eax
c0105828:	89 04 24             	mov    %eax,(%esp)
c010582b:	e8 ba f5 ff ff       	call   c0104dea <find_vma>
c0105830:	89 45 ec             	mov    %eax,-0x14(%ebp)

    pgfault_num++;
c0105833:	a1 0c c0 12 c0       	mov    0xc012c00c,%eax
c0105838:	40                   	inc    %eax
c0105839:	a3 0c c0 12 c0       	mov    %eax,0xc012c00c
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr)
c010583e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0105842:	74 0b                	je     c010584f <do_pgfault+0x42>
c0105844:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105847:	8b 40 04             	mov    0x4(%eax),%eax
c010584a:	39 45 10             	cmp    %eax,0x10(%ebp)
c010584d:	73 18                	jae    c0105867 <do_pgfault+0x5a>
    {
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
c010584f:	8b 45 10             	mov    0x10(%ebp),%eax
c0105852:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105856:	c7 04 24 7c b2 10 c0 	movl   $0xc010b27c,(%esp)
c010585d:	e8 6f aa ff ff       	call   c01002d1 <cprintf>
        goto failed;
c0105862:	e9 ba 01 00 00       	jmp    c0105a21 <do_pgfault+0x214>
    }
    //check the error_code
    switch (error_code & 3)
c0105867:	8b 45 0c             	mov    0xc(%ebp),%eax
c010586a:	83 e0 03             	and    $0x3,%eax
c010586d:	85 c0                	test   %eax,%eax
c010586f:	74 34                	je     c01058a5 <do_pgfault+0x98>
c0105871:	83 f8 01             	cmp    $0x1,%eax
c0105874:	74 1e                	je     c0105894 <do_pgfault+0x87>
    {
    default:
        /* error code flag : default is 3 ( W/R=1, P=1): write, present */
    case 2: /* error code flag : (W/R=1, P=0): write, not present */
        if (!(vma->vm_flags & VM_WRITE))
c0105876:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105879:	8b 40 0c             	mov    0xc(%eax),%eax
c010587c:	83 e0 02             	and    $0x2,%eax
c010587f:	85 c0                	test   %eax,%eax
c0105881:	75 40                	jne    c01058c3 <do_pgfault+0xb6>
        {
            cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
c0105883:	c7 04 24 ac b2 10 c0 	movl   $0xc010b2ac,(%esp)
c010588a:	e8 42 aa ff ff       	call   c01002d1 <cprintf>
            goto failed;
c010588f:	e9 8d 01 00 00       	jmp    c0105a21 <do_pgfault+0x214>
        }
        break;
    case 1: /* error code flag : (W/R=0, P=1): read, present */
        cprintf("do_pgfault failed: error code flag = read AND present\n");
c0105894:	c7 04 24 0c b3 10 c0 	movl   $0xc010b30c,(%esp)
c010589b:	e8 31 aa ff ff       	call   c01002d1 <cprintf>
        goto failed;
c01058a0:	e9 7c 01 00 00       	jmp    c0105a21 <do_pgfault+0x214>
    case 0: /* error code flag : (W/R=0, P=0): read, not present */
        if (!(vma->vm_flags & (VM_READ | VM_EXEC)))
c01058a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01058a8:	8b 40 0c             	mov    0xc(%eax),%eax
c01058ab:	83 e0 05             	and    $0x5,%eax
c01058ae:	85 c0                	test   %eax,%eax
c01058b0:	75 12                	jne    c01058c4 <do_pgfault+0xb7>
        {
            cprintf("do_pgfault failed: error code flag = read AND not present, but the addr's vma cannot read or exec\n");
c01058b2:	c7 04 24 44 b3 10 c0 	movl   $0xc010b344,(%esp)
c01058b9:	e8 13 aa ff ff       	call   c01002d1 <cprintf>
            goto failed;
c01058be:	e9 5e 01 00 00       	jmp    c0105a21 <do_pgfault+0x214>
        break;
c01058c3:	90                   	nop
     *    (write an non_existed addr && addr is writable) OR
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
c01058c4:	c7 45 f0 04 00 00 00 	movl   $0x4,-0x10(%ebp)
    if (vma->vm_flags & VM_WRITE)
c01058cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01058ce:	8b 40 0c             	mov    0xc(%eax),%eax
c01058d1:	83 e0 02             	and    $0x2,%eax
c01058d4:	85 c0                	test   %eax,%eax
c01058d6:	74 04                	je     c01058dc <do_pgfault+0xcf>
    {
        perm |= PTE_W;
c01058d8:	83 4d f0 02          	orl    $0x2,-0x10(%ebp)
    }
    addr = ROUNDDOWN(addr, PGSIZE);
c01058dc:	8b 45 10             	mov    0x10(%ebp),%eax
c01058df:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01058e2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01058e5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01058ea:	89 45 10             	mov    %eax,0x10(%ebp)

    ret = -E_NO_MEM;
c01058ed:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

    pte_t *ptep = NULL;
c01058f4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
        }
   }
#endif
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL)
c01058fb:	8b 45 08             	mov    0x8(%ebp),%eax
c01058fe:	8b 40 0c             	mov    0xc(%eax),%eax
c0105901:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0105908:	00 
c0105909:	8b 55 10             	mov    0x10(%ebp),%edx
c010590c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105910:	89 04 24             	mov    %eax,(%esp)
c0105913:	e8 c7 e2 ff ff       	call   c0103bdf <get_pte>
c0105918:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010591b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010591f:	75 11                	jne    c0105932 <do_pgfault+0x125>
    {
        cprintf("get_pte in do_pgfault failed\n");
c0105921:	c7 04 24 a7 b3 10 c0 	movl   $0xc010b3a7,(%esp)
c0105928:	e8 a4 a9 ff ff       	call   c01002d1 <cprintf>
        goto failed;
c010592d:	e9 ef 00 00 00       	jmp    c0105a21 <do_pgfault+0x214>
    }

    if (*ptep == 0)
c0105932:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105935:	8b 00                	mov    (%eax),%eax
c0105937:	85 c0                	test   %eax,%eax
c0105939:	75 35                	jne    c0105970 <do_pgfault+0x163>
    { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL)
c010593b:	8b 45 08             	mov    0x8(%ebp),%eax
c010593e:	8b 40 0c             	mov    0xc(%eax),%eax
c0105941:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105944:	89 54 24 08          	mov    %edx,0x8(%esp)
c0105948:	8b 55 10             	mov    0x10(%ebp),%edx
c010594b:	89 54 24 04          	mov    %edx,0x4(%esp)
c010594f:	89 04 24             	mov    %eax,(%esp)
c0105952:	e8 eb e5 ff ff       	call   c0103f42 <pgdir_alloc_page>
c0105957:	85 c0                	test   %eax,%eax
c0105959:	0f 85 bb 00 00 00    	jne    c0105a1a <do_pgfault+0x20d>
        {
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
c010595f:	c7 04 24 c8 b3 10 c0 	movl   $0xc010b3c8,(%esp)
c0105966:	e8 66 a9 ff ff       	call   c01002d1 <cprintf>
            goto failed;
c010596b:	e9 b1 00 00 00       	jmp    c0105a21 <do_pgfault+0x214>
        }
    }
    else
    {   // if this pte is a swap entry, then load data from disk to a page with phy addr
        // and call page_insert to map the phy addr with logical addr
        if (swap_init_ok)
c0105970:	a1 10 c0 12 c0       	mov    0xc012c010,%eax
c0105975:	85 c0                	test   %eax,%eax
c0105977:	0f 84 86 00 00 00    	je     c0105a03 <do_pgfault+0x1f6>
        {
            struct Page *page = NULL;
c010597d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
            if ((ret = swap_in(mm, addr, &page)) != 0)
c0105984:	8d 45 e0             	lea    -0x20(%ebp),%eax
c0105987:	89 44 24 08          	mov    %eax,0x8(%esp)
c010598b:	8b 45 10             	mov    0x10(%ebp),%eax
c010598e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105992:	8b 45 08             	mov    0x8(%ebp),%eax
c0105995:	89 04 24             	mov    %eax,(%esp)
c0105998:	e8 a6 03 00 00       	call   c0105d43 <swap_in>
c010599d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01059a0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01059a4:	74 0e                	je     c01059b4 <do_pgfault+0x1a7>
            {
                cprintf("swap_in in do_pgfault failed\n");
c01059a6:	c7 04 24 ef b3 10 c0 	movl   $0xc010b3ef,(%esp)
c01059ad:	e8 1f a9 ff ff       	call   c01002d1 <cprintf>
c01059b2:	eb 6d                	jmp    c0105a21 <do_pgfault+0x214>
                goto failed;
            }
            page_insert(mm->pgdir, page, addr, perm);
c01059b4:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01059b7:	8b 45 08             	mov    0x8(%ebp),%eax
c01059ba:	8b 40 0c             	mov    0xc(%eax),%eax
c01059bd:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c01059c0:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01059c4:	8b 4d 10             	mov    0x10(%ebp),%ecx
c01059c7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01059cb:	89 54 24 04          	mov    %edx,0x4(%esp)
c01059cf:	89 04 24             	mov    %eax,(%esp)
c01059d2:	e8 4d e4 ff ff       	call   c0103e24 <page_insert>
            swap_map_swappable(mm, addr, page, 1);
c01059d7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01059da:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
c01059e1:	00 
c01059e2:	89 44 24 08          	mov    %eax,0x8(%esp)
c01059e6:	8b 45 10             	mov    0x10(%ebp),%eax
c01059e9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01059ed:	8b 45 08             	mov    0x8(%ebp),%eax
c01059f0:	89 04 24             	mov    %eax,(%esp)
c01059f3:	e8 7d 01 00 00       	call   c0105b75 <swap_map_swappable>
            page->pra_vaddr = addr;
c01059f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01059fb:	8b 55 10             	mov    0x10(%ebp),%edx
c01059fe:	89 50 1c             	mov    %edx,0x1c(%eax)
c0105a01:	eb 17                	jmp    c0105a1a <do_pgfault+0x20d>
        }
        else
        {
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
c0105a03:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105a06:	8b 00                	mov    (%eax),%eax
c0105a08:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105a0c:	c7 04 24 10 b4 10 c0 	movl   $0xc010b410,(%esp)
c0105a13:	e8 b9 a8 ff ff       	call   c01002d1 <cprintf>
            goto failed;
c0105a18:	eb 07                	jmp    c0105a21 <do_pgfault+0x214>
        }
    }
    ret = 0;
c0105a1a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
failed:
    return ret;
c0105a21:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105a24:	c9                   	leave  
c0105a25:	c3                   	ret    

c0105a26 <pa2page>:
pa2page(uintptr_t pa) {
c0105a26:	55                   	push   %ebp
c0105a27:	89 e5                	mov    %esp,%ebp
c0105a29:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0105a2c:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a2f:	c1 e8 0c             	shr    $0xc,%eax
c0105a32:	89 c2                	mov    %eax,%edx
c0105a34:	a1 80 bf 12 c0       	mov    0xc012bf80,%eax
c0105a39:	39 c2                	cmp    %eax,%edx
c0105a3b:	72 1c                	jb     c0105a59 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0105a3d:	c7 44 24 08 38 b4 10 	movl   $0xc010b438,0x8(%esp)
c0105a44:	c0 
c0105a45:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
c0105a4c:	00 
c0105a4d:	c7 04 24 57 b4 10 c0 	movl   $0xc010b457,(%esp)
c0105a54:	e8 e4 a9 ff ff       	call   c010043d <__panic>
    return &pages[PPN(pa)];
c0105a59:	a1 60 e0 12 c0       	mov    0xc012e060,%eax
c0105a5e:	8b 55 08             	mov    0x8(%ebp),%edx
c0105a61:	c1 ea 0c             	shr    $0xc,%edx
c0105a64:	c1 e2 05             	shl    $0x5,%edx
c0105a67:	01 d0                	add    %edx,%eax
}
c0105a69:	c9                   	leave  
c0105a6a:	c3                   	ret    

c0105a6b <pte2page>:
pte2page(pte_t pte) {
c0105a6b:	55                   	push   %ebp
c0105a6c:	89 e5                	mov    %esp,%ebp
c0105a6e:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0105a71:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a74:	83 e0 01             	and    $0x1,%eax
c0105a77:	85 c0                	test   %eax,%eax
c0105a79:	75 1c                	jne    c0105a97 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0105a7b:	c7 44 24 08 68 b4 10 	movl   $0xc010b468,0x8(%esp)
c0105a82:	c0 
c0105a83:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
c0105a8a:	00 
c0105a8b:	c7 04 24 57 b4 10 c0 	movl   $0xc010b457,(%esp)
c0105a92:	e8 a6 a9 ff ff       	call   c010043d <__panic>
    return pa2page(PTE_ADDR(pte));
c0105a97:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a9a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105a9f:	89 04 24             	mov    %eax,(%esp)
c0105aa2:	e8 7f ff ff ff       	call   c0105a26 <pa2page>
}
c0105aa7:	c9                   	leave  
c0105aa8:	c3                   	ret    

c0105aa9 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
c0105aa9:	f3 0f 1e fb          	endbr32 
c0105aad:	55                   	push   %ebp
c0105aae:	89 e5                	mov    %esp,%ebp
c0105ab0:	83 ec 28             	sub    $0x28,%esp
     swapfs_init();
c0105ab3:	e8 04 2b 00 00       	call   c01085bc <swapfs_init>

     if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
c0105ab8:	a1 1c e1 12 c0       	mov    0xc012e11c,%eax
c0105abd:	3d ff 03 00 00       	cmp    $0x3ff,%eax
c0105ac2:	76 0c                	jbe    c0105ad0 <swap_init+0x27>
c0105ac4:	a1 1c e1 12 c0       	mov    0xc012e11c,%eax
c0105ac9:	3d ff ff ff 00       	cmp    $0xffffff,%eax
c0105ace:	76 25                	jbe    c0105af5 <swap_init+0x4c>
     {
          panic("bad max_swap_offset %08x.\n", max_swap_offset);
c0105ad0:	a1 1c e1 12 c0       	mov    0xc012e11c,%eax
c0105ad5:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105ad9:	c7 44 24 08 89 b4 10 	movl   $0xc010b489,0x8(%esp)
c0105ae0:	c0 
c0105ae1:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
c0105ae8:	00 
c0105ae9:	c7 04 24 a4 b4 10 c0 	movl   $0xc010b4a4,(%esp)
c0105af0:	e8 48 a9 ff ff       	call   c010043d <__panic>
     }
     

     sm = &swap_manager_fifo;
c0105af5:	c7 05 18 c0 12 c0 60 	movl   $0xc0128a60,0xc012c018
c0105afc:	8a 12 c0 
     int r = sm->init();
c0105aff:	a1 18 c0 12 c0       	mov    0xc012c018,%eax
c0105b04:	8b 40 04             	mov    0x4(%eax),%eax
c0105b07:	ff d0                	call   *%eax
c0105b09:	89 45 f4             	mov    %eax,-0xc(%ebp)
     
     if (r == 0)
c0105b0c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105b10:	75 26                	jne    c0105b38 <swap_init+0x8f>
     {
          swap_init_ok = 1;
c0105b12:	c7 05 10 c0 12 c0 01 	movl   $0x1,0xc012c010
c0105b19:	00 00 00 
          cprintf("SWAP: manager = %s\n", sm->name);
c0105b1c:	a1 18 c0 12 c0       	mov    0xc012c018,%eax
c0105b21:	8b 00                	mov    (%eax),%eax
c0105b23:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105b27:	c7 04 24 b3 b4 10 c0 	movl   $0xc010b4b3,(%esp)
c0105b2e:	e8 9e a7 ff ff       	call   c01002d1 <cprintf>
          check_swap();
c0105b33:	e8 b6 04 00 00       	call   c0105fee <check_swap>
     }

     return r;
c0105b38:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105b3b:	c9                   	leave  
c0105b3c:	c3                   	ret    

c0105b3d <swap_init_mm>:

int
swap_init_mm(struct mm_struct *mm)
{
c0105b3d:	f3 0f 1e fb          	endbr32 
c0105b41:	55                   	push   %ebp
c0105b42:	89 e5                	mov    %esp,%ebp
c0105b44:	83 ec 18             	sub    $0x18,%esp
     return sm->init_mm(mm);
c0105b47:	a1 18 c0 12 c0       	mov    0xc012c018,%eax
c0105b4c:	8b 40 08             	mov    0x8(%eax),%eax
c0105b4f:	8b 55 08             	mov    0x8(%ebp),%edx
c0105b52:	89 14 24             	mov    %edx,(%esp)
c0105b55:	ff d0                	call   *%eax
}
c0105b57:	c9                   	leave  
c0105b58:	c3                   	ret    

c0105b59 <swap_tick_event>:

int
swap_tick_event(struct mm_struct *mm)
{
c0105b59:	f3 0f 1e fb          	endbr32 
c0105b5d:	55                   	push   %ebp
c0105b5e:	89 e5                	mov    %esp,%ebp
c0105b60:	83 ec 18             	sub    $0x18,%esp
     return sm->tick_event(mm);
c0105b63:	a1 18 c0 12 c0       	mov    0xc012c018,%eax
c0105b68:	8b 40 0c             	mov    0xc(%eax),%eax
c0105b6b:	8b 55 08             	mov    0x8(%ebp),%edx
c0105b6e:	89 14 24             	mov    %edx,(%esp)
c0105b71:	ff d0                	call   *%eax
}
c0105b73:	c9                   	leave  
c0105b74:	c3                   	ret    

c0105b75 <swap_map_swappable>:

int
swap_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c0105b75:	f3 0f 1e fb          	endbr32 
c0105b79:	55                   	push   %ebp
c0105b7a:	89 e5                	mov    %esp,%ebp
c0105b7c:	83 ec 18             	sub    $0x18,%esp
     return sm->map_swappable(mm, addr, page, swap_in);
c0105b7f:	a1 18 c0 12 c0       	mov    0xc012c018,%eax
c0105b84:	8b 40 10             	mov    0x10(%eax),%eax
c0105b87:	8b 55 14             	mov    0x14(%ebp),%edx
c0105b8a:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0105b8e:	8b 55 10             	mov    0x10(%ebp),%edx
c0105b91:	89 54 24 08          	mov    %edx,0x8(%esp)
c0105b95:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105b98:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105b9c:	8b 55 08             	mov    0x8(%ebp),%edx
c0105b9f:	89 14 24             	mov    %edx,(%esp)
c0105ba2:	ff d0                	call   *%eax
}
c0105ba4:	c9                   	leave  
c0105ba5:	c3                   	ret    

c0105ba6 <swap_set_unswappable>:

int
swap_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c0105ba6:	f3 0f 1e fb          	endbr32 
c0105baa:	55                   	push   %ebp
c0105bab:	89 e5                	mov    %esp,%ebp
c0105bad:	83 ec 18             	sub    $0x18,%esp
     return sm->set_unswappable(mm, addr);
c0105bb0:	a1 18 c0 12 c0       	mov    0xc012c018,%eax
c0105bb5:	8b 40 14             	mov    0x14(%eax),%eax
c0105bb8:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105bbb:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105bbf:	8b 55 08             	mov    0x8(%ebp),%edx
c0105bc2:	89 14 24             	mov    %edx,(%esp)
c0105bc5:	ff d0                	call   *%eax
}
c0105bc7:	c9                   	leave  
c0105bc8:	c3                   	ret    

c0105bc9 <swap_out>:

volatile unsigned int swap_out_num=0;

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
c0105bc9:	f3 0f 1e fb          	endbr32 
c0105bcd:	55                   	push   %ebp
c0105bce:	89 e5                	mov    %esp,%ebp
c0105bd0:	83 ec 38             	sub    $0x38,%esp
     int i;
     for (i = 0; i != n; ++ i)
c0105bd3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0105bda:	e9 53 01 00 00       	jmp    c0105d32 <swap_out+0x169>
     {
          uintptr_t v;
          //struct Page **ptr_page=NULL;
          struct Page *page;
          // cprintf("i %d, SWAP: call swap_out_victim\n",i);
          int r = sm->swap_out_victim(mm, &page, in_tick);
c0105bdf:	a1 18 c0 12 c0       	mov    0xc012c018,%eax
c0105be4:	8b 40 18             	mov    0x18(%eax),%eax
c0105be7:	8b 55 10             	mov    0x10(%ebp),%edx
c0105bea:	89 54 24 08          	mov    %edx,0x8(%esp)
c0105bee:	8d 55 e4             	lea    -0x1c(%ebp),%edx
c0105bf1:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105bf5:	8b 55 08             	mov    0x8(%ebp),%edx
c0105bf8:	89 14 24             	mov    %edx,(%esp)
c0105bfb:	ff d0                	call   *%eax
c0105bfd:	89 45 f0             	mov    %eax,-0x10(%ebp)
          if (r != 0) {
c0105c00:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105c04:	74 18                	je     c0105c1e <swap_out+0x55>
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
c0105c06:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105c09:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105c0d:	c7 04 24 c8 b4 10 c0 	movl   $0xc010b4c8,(%esp)
c0105c14:	e8 b8 a6 ff ff       	call   c01002d1 <cprintf>
c0105c19:	e9 20 01 00 00       	jmp    c0105d3e <swap_out+0x175>
          }          
          //assert(!PageReserved(page));

          //cprintf("SWAP: choose victim page 0x%08x\n", page);
          
          v=page->pra_vaddr; 
c0105c1e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105c21:	8b 40 1c             	mov    0x1c(%eax),%eax
c0105c24:	89 45 ec             	mov    %eax,-0x14(%ebp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
c0105c27:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c2a:	8b 40 0c             	mov    0xc(%eax),%eax
c0105c2d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105c34:	00 
c0105c35:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105c38:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105c3c:	89 04 24             	mov    %eax,(%esp)
c0105c3f:	e8 9b df ff ff       	call   c0103bdf <get_pte>
c0105c44:	89 45 e8             	mov    %eax,-0x18(%ebp)
          assert((*ptep & PTE_P) != 0);
c0105c47:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105c4a:	8b 00                	mov    (%eax),%eax
c0105c4c:	83 e0 01             	and    $0x1,%eax
c0105c4f:	85 c0                	test   %eax,%eax
c0105c51:	75 24                	jne    c0105c77 <swap_out+0xae>
c0105c53:	c7 44 24 0c f5 b4 10 	movl   $0xc010b4f5,0xc(%esp)
c0105c5a:	c0 
c0105c5b:	c7 44 24 08 0a b5 10 	movl   $0xc010b50a,0x8(%esp)
c0105c62:	c0 
c0105c63:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c0105c6a:	00 
c0105c6b:	c7 04 24 a4 b4 10 c0 	movl   $0xc010b4a4,(%esp)
c0105c72:	e8 c6 a7 ff ff       	call   c010043d <__panic>

          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
c0105c77:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105c7a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105c7d:	8b 52 1c             	mov    0x1c(%edx),%edx
c0105c80:	c1 ea 0c             	shr    $0xc,%edx
c0105c83:	42                   	inc    %edx
c0105c84:	c1 e2 08             	shl    $0x8,%edx
c0105c87:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105c8b:	89 14 24             	mov    %edx,(%esp)
c0105c8e:	e8 ec 29 00 00       	call   c010867f <swapfs_write>
c0105c93:	85 c0                	test   %eax,%eax
c0105c95:	74 34                	je     c0105ccb <swap_out+0x102>
                    cprintf("SWAP: failed to save\n");
c0105c97:	c7 04 24 1f b5 10 c0 	movl   $0xc010b51f,(%esp)
c0105c9e:	e8 2e a6 ff ff       	call   c01002d1 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
c0105ca3:	a1 18 c0 12 c0       	mov    0xc012c018,%eax
c0105ca8:	8b 40 10             	mov    0x10(%eax),%eax
c0105cab:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105cae:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0105cb5:	00 
c0105cb6:	89 54 24 08          	mov    %edx,0x8(%esp)
c0105cba:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105cbd:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105cc1:	8b 55 08             	mov    0x8(%ebp),%edx
c0105cc4:	89 14 24             	mov    %edx,(%esp)
c0105cc7:	ff d0                	call   *%eax
c0105cc9:	eb 64                	jmp    c0105d2f <swap_out+0x166>
                    continue;
          }
          else {
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
c0105ccb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105cce:	8b 40 1c             	mov    0x1c(%eax),%eax
c0105cd1:	c1 e8 0c             	shr    $0xc,%eax
c0105cd4:	40                   	inc    %eax
c0105cd5:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105cd9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105cdc:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105ce0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105ce3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105ce7:	c7 04 24 38 b5 10 c0 	movl   $0xc010b538,(%esp)
c0105cee:	e8 de a5 ff ff       	call   c01002d1 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
c0105cf3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105cf6:	8b 40 1c             	mov    0x1c(%eax),%eax
c0105cf9:	c1 e8 0c             	shr    $0xc,%eax
c0105cfc:	40                   	inc    %eax
c0105cfd:	c1 e0 08             	shl    $0x8,%eax
c0105d00:	89 c2                	mov    %eax,%edx
c0105d02:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105d05:	89 10                	mov    %edx,(%eax)
                    free_page(page);
c0105d07:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105d0a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105d11:	00 
c0105d12:	89 04 24             	mov    %eax,(%esp)
c0105d15:	e8 64 d8 ff ff       	call   c010357e <free_pages>
          }
          
          tlb_invalidate(mm->pgdir, v);
c0105d1a:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d1d:	8b 40 0c             	mov    0xc(%eax),%eax
c0105d20:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105d23:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105d27:	89 04 24             	mov    %eax,(%esp)
c0105d2a:	e8 b2 e1 ff ff       	call   c0103ee1 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
c0105d2f:	ff 45 f4             	incl   -0xc(%ebp)
c0105d32:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105d35:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105d38:	0f 85 a1 fe ff ff    	jne    c0105bdf <swap_out+0x16>
     }
     return i;
c0105d3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105d41:	c9                   	leave  
c0105d42:	c3                   	ret    

c0105d43 <swap_in>:

int
swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result)
{
c0105d43:	f3 0f 1e fb          	endbr32 
c0105d47:	55                   	push   %ebp
c0105d48:	89 e5                	mov    %esp,%ebp
c0105d4a:	83 ec 28             	sub    $0x28,%esp
     struct Page *result = alloc_page();
c0105d4d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105d54:	e8 b6 d7 ff ff       	call   c010350f <alloc_pages>
c0105d59:	89 45 f4             	mov    %eax,-0xc(%ebp)
     assert(result!=NULL);
c0105d5c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105d60:	75 24                	jne    c0105d86 <swap_in+0x43>
c0105d62:	c7 44 24 0c 78 b5 10 	movl   $0xc010b578,0xc(%esp)
c0105d69:	c0 
c0105d6a:	c7 44 24 08 0a b5 10 	movl   $0xc010b50a,0x8(%esp)
c0105d71:	c0 
c0105d72:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
c0105d79:	00 
c0105d7a:	c7 04 24 a4 b4 10 c0 	movl   $0xc010b4a4,(%esp)
c0105d81:	e8 b7 a6 ff ff       	call   c010043d <__panic>

     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
c0105d86:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d89:	8b 40 0c             	mov    0xc(%eax),%eax
c0105d8c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105d93:	00 
c0105d94:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105d97:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105d9b:	89 04 24             	mov    %eax,(%esp)
c0105d9e:	e8 3c de ff ff       	call   c0103bdf <get_pte>
c0105da3:	89 45 f0             	mov    %eax,-0x10(%ebp)
     // cprintf("SWAP: load ptep %x swap entry %d to vaddr 0x%08x, page %x, No %d\n", ptep, (*ptep)>>8, addr, result, (result-pages));
    
     int r;
     if ((r = swapfs_read((*ptep), result)) != 0)
c0105da6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105da9:	8b 00                	mov    (%eax),%eax
c0105dab:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105dae:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105db2:	89 04 24             	mov    %eax,(%esp)
c0105db5:	e8 4f 28 00 00       	call   c0108609 <swapfs_read>
c0105dba:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105dbd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0105dc1:	74 2a                	je     c0105ded <swap_in+0xaa>
     {
        assert(r!=0);
c0105dc3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0105dc7:	75 24                	jne    c0105ded <swap_in+0xaa>
c0105dc9:	c7 44 24 0c 85 b5 10 	movl   $0xc010b585,0xc(%esp)
c0105dd0:	c0 
c0105dd1:	c7 44 24 08 0a b5 10 	movl   $0xc010b50a,0x8(%esp)
c0105dd8:	c0 
c0105dd9:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
c0105de0:	00 
c0105de1:	c7 04 24 a4 b4 10 c0 	movl   $0xc010b4a4,(%esp)
c0105de8:	e8 50 a6 ff ff       	call   c010043d <__panic>
     }
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
c0105ded:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105df0:	8b 00                	mov    (%eax),%eax
c0105df2:	c1 e8 08             	shr    $0x8,%eax
c0105df5:	89 c2                	mov    %eax,%edx
c0105df7:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105dfa:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105dfe:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105e02:	c7 04 24 8c b5 10 c0 	movl   $0xc010b58c,(%esp)
c0105e09:	e8 c3 a4 ff ff       	call   c01002d1 <cprintf>
     *ptr_result=result;
c0105e0e:	8b 45 10             	mov    0x10(%ebp),%eax
c0105e11:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105e14:	89 10                	mov    %edx,(%eax)
     return 0;
c0105e16:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105e1b:	c9                   	leave  
c0105e1c:	c3                   	ret    

c0105e1d <check_content_set>:



static inline void
check_content_set(void)
{
c0105e1d:	55                   	push   %ebp
c0105e1e:	89 e5                	mov    %esp,%ebp
c0105e20:	83 ec 18             	sub    $0x18,%esp
     *(unsigned char *)0x1000 = 0x0a;
c0105e23:	b8 00 10 00 00       	mov    $0x1000,%eax
c0105e28:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c0105e2b:	a1 0c c0 12 c0       	mov    0xc012c00c,%eax
c0105e30:	83 f8 01             	cmp    $0x1,%eax
c0105e33:	74 24                	je     c0105e59 <check_content_set+0x3c>
c0105e35:	c7 44 24 0c ca b5 10 	movl   $0xc010b5ca,0xc(%esp)
c0105e3c:	c0 
c0105e3d:	c7 44 24 08 0a b5 10 	movl   $0xc010b50a,0x8(%esp)
c0105e44:	c0 
c0105e45:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
c0105e4c:	00 
c0105e4d:	c7 04 24 a4 b4 10 c0 	movl   $0xc010b4a4,(%esp)
c0105e54:	e8 e4 a5 ff ff       	call   c010043d <__panic>
     *(unsigned char *)0x1010 = 0x0a;
c0105e59:	b8 10 10 00 00       	mov    $0x1010,%eax
c0105e5e:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c0105e61:	a1 0c c0 12 c0       	mov    0xc012c00c,%eax
c0105e66:	83 f8 01             	cmp    $0x1,%eax
c0105e69:	74 24                	je     c0105e8f <check_content_set+0x72>
c0105e6b:	c7 44 24 0c ca b5 10 	movl   $0xc010b5ca,0xc(%esp)
c0105e72:	c0 
c0105e73:	c7 44 24 08 0a b5 10 	movl   $0xc010b50a,0x8(%esp)
c0105e7a:	c0 
c0105e7b:	c7 44 24 04 92 00 00 	movl   $0x92,0x4(%esp)
c0105e82:	00 
c0105e83:	c7 04 24 a4 b4 10 c0 	movl   $0xc010b4a4,(%esp)
c0105e8a:	e8 ae a5 ff ff       	call   c010043d <__panic>
     *(unsigned char *)0x2000 = 0x0b;
c0105e8f:	b8 00 20 00 00       	mov    $0x2000,%eax
c0105e94:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c0105e97:	a1 0c c0 12 c0       	mov    0xc012c00c,%eax
c0105e9c:	83 f8 02             	cmp    $0x2,%eax
c0105e9f:	74 24                	je     c0105ec5 <check_content_set+0xa8>
c0105ea1:	c7 44 24 0c d9 b5 10 	movl   $0xc010b5d9,0xc(%esp)
c0105ea8:	c0 
c0105ea9:	c7 44 24 08 0a b5 10 	movl   $0xc010b50a,0x8(%esp)
c0105eb0:	c0 
c0105eb1:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
c0105eb8:	00 
c0105eb9:	c7 04 24 a4 b4 10 c0 	movl   $0xc010b4a4,(%esp)
c0105ec0:	e8 78 a5 ff ff       	call   c010043d <__panic>
     *(unsigned char *)0x2010 = 0x0b;
c0105ec5:	b8 10 20 00 00       	mov    $0x2010,%eax
c0105eca:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c0105ecd:	a1 0c c0 12 c0       	mov    0xc012c00c,%eax
c0105ed2:	83 f8 02             	cmp    $0x2,%eax
c0105ed5:	74 24                	je     c0105efb <check_content_set+0xde>
c0105ed7:	c7 44 24 0c d9 b5 10 	movl   $0xc010b5d9,0xc(%esp)
c0105ede:	c0 
c0105edf:	c7 44 24 08 0a b5 10 	movl   $0xc010b50a,0x8(%esp)
c0105ee6:	c0 
c0105ee7:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
c0105eee:	00 
c0105eef:	c7 04 24 a4 b4 10 c0 	movl   $0xc010b4a4,(%esp)
c0105ef6:	e8 42 a5 ff ff       	call   c010043d <__panic>
     *(unsigned char *)0x3000 = 0x0c;
c0105efb:	b8 00 30 00 00       	mov    $0x3000,%eax
c0105f00:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c0105f03:	a1 0c c0 12 c0       	mov    0xc012c00c,%eax
c0105f08:	83 f8 03             	cmp    $0x3,%eax
c0105f0b:	74 24                	je     c0105f31 <check_content_set+0x114>
c0105f0d:	c7 44 24 0c e8 b5 10 	movl   $0xc010b5e8,0xc(%esp)
c0105f14:	c0 
c0105f15:	c7 44 24 08 0a b5 10 	movl   $0xc010b50a,0x8(%esp)
c0105f1c:	c0 
c0105f1d:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
c0105f24:	00 
c0105f25:	c7 04 24 a4 b4 10 c0 	movl   $0xc010b4a4,(%esp)
c0105f2c:	e8 0c a5 ff ff       	call   c010043d <__panic>
     *(unsigned char *)0x3010 = 0x0c;
c0105f31:	b8 10 30 00 00       	mov    $0x3010,%eax
c0105f36:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c0105f39:	a1 0c c0 12 c0       	mov    0xc012c00c,%eax
c0105f3e:	83 f8 03             	cmp    $0x3,%eax
c0105f41:	74 24                	je     c0105f67 <check_content_set+0x14a>
c0105f43:	c7 44 24 0c e8 b5 10 	movl   $0xc010b5e8,0xc(%esp)
c0105f4a:	c0 
c0105f4b:	c7 44 24 08 0a b5 10 	movl   $0xc010b50a,0x8(%esp)
c0105f52:	c0 
c0105f53:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
c0105f5a:	00 
c0105f5b:	c7 04 24 a4 b4 10 c0 	movl   $0xc010b4a4,(%esp)
c0105f62:	e8 d6 a4 ff ff       	call   c010043d <__panic>
     *(unsigned char *)0x4000 = 0x0d;
c0105f67:	b8 00 40 00 00       	mov    $0x4000,%eax
c0105f6c:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c0105f6f:	a1 0c c0 12 c0       	mov    0xc012c00c,%eax
c0105f74:	83 f8 04             	cmp    $0x4,%eax
c0105f77:	74 24                	je     c0105f9d <check_content_set+0x180>
c0105f79:	c7 44 24 0c f7 b5 10 	movl   $0xc010b5f7,0xc(%esp)
c0105f80:	c0 
c0105f81:	c7 44 24 08 0a b5 10 	movl   $0xc010b50a,0x8(%esp)
c0105f88:	c0 
c0105f89:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
c0105f90:	00 
c0105f91:	c7 04 24 a4 b4 10 c0 	movl   $0xc010b4a4,(%esp)
c0105f98:	e8 a0 a4 ff ff       	call   c010043d <__panic>
     *(unsigned char *)0x4010 = 0x0d;
c0105f9d:	b8 10 40 00 00       	mov    $0x4010,%eax
c0105fa2:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c0105fa5:	a1 0c c0 12 c0       	mov    0xc012c00c,%eax
c0105faa:	83 f8 04             	cmp    $0x4,%eax
c0105fad:	74 24                	je     c0105fd3 <check_content_set+0x1b6>
c0105faf:	c7 44 24 0c f7 b5 10 	movl   $0xc010b5f7,0xc(%esp)
c0105fb6:	c0 
c0105fb7:	c7 44 24 08 0a b5 10 	movl   $0xc010b50a,0x8(%esp)
c0105fbe:	c0 
c0105fbf:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
c0105fc6:	00 
c0105fc7:	c7 04 24 a4 b4 10 c0 	movl   $0xc010b4a4,(%esp)
c0105fce:	e8 6a a4 ff ff       	call   c010043d <__panic>
}
c0105fd3:	90                   	nop
c0105fd4:	c9                   	leave  
c0105fd5:	c3                   	ret    

c0105fd6 <check_content_access>:

static inline int
check_content_access(void)
{
c0105fd6:	55                   	push   %ebp
c0105fd7:	89 e5                	mov    %esp,%ebp
c0105fd9:	83 ec 18             	sub    $0x18,%esp
    int ret = sm->check_swap();
c0105fdc:	a1 18 c0 12 c0       	mov    0xc012c018,%eax
c0105fe1:	8b 40 1c             	mov    0x1c(%eax),%eax
c0105fe4:	ff d0                	call   *%eax
c0105fe6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return ret;
c0105fe9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105fec:	c9                   	leave  
c0105fed:	c3                   	ret    

c0105fee <check_swap>:
#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
check_swap(void)
{
c0105fee:	f3 0f 1e fb          	endbr32 
c0105ff2:	55                   	push   %ebp
c0105ff3:	89 e5                	mov    %esp,%ebp
c0105ff5:	83 ec 78             	sub    $0x78,%esp
    //backup mem env
     int ret, count = 0, total = 0, i;
c0105ff8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0105fff:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     list_entry_t *le = &free_list;
c0106006:	c7 45 e8 4c e1 12 c0 	movl   $0xc012e14c,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c010600d:	eb 6a                	jmp    c0106079 <check_swap+0x8b>
        struct Page *p = le2page(le, page_link);
c010600f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106012:	83 e8 0c             	sub    $0xc,%eax
c0106015:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(PageProperty(p));
c0106018:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010601b:	83 c0 04             	add    $0x4,%eax
c010601e:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c0106025:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106028:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010602b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c010602e:	0f a3 10             	bt     %edx,(%eax)
c0106031:	19 c0                	sbb    %eax,%eax
c0106033:	89 45 bc             	mov    %eax,-0x44(%ebp)
    return oldbit != 0;
c0106036:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c010603a:	0f 95 c0             	setne  %al
c010603d:	0f b6 c0             	movzbl %al,%eax
c0106040:	85 c0                	test   %eax,%eax
c0106042:	75 24                	jne    c0106068 <check_swap+0x7a>
c0106044:	c7 44 24 0c 06 b6 10 	movl   $0xc010b606,0xc(%esp)
c010604b:	c0 
c010604c:	c7 44 24 08 0a b5 10 	movl   $0xc010b50a,0x8(%esp)
c0106053:	c0 
c0106054:	c7 44 24 04 b9 00 00 	movl   $0xb9,0x4(%esp)
c010605b:	00 
c010605c:	c7 04 24 a4 b4 10 c0 	movl   $0xc010b4a4,(%esp)
c0106063:	e8 d5 a3 ff ff       	call   c010043d <__panic>
        count ++, total += p->property;
c0106068:	ff 45 f4             	incl   -0xc(%ebp)
c010606b:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010606e:	8b 50 08             	mov    0x8(%eax),%edx
c0106071:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106074:	01 d0                	add    %edx,%eax
c0106076:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106079:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010607c:	89 45 b8             	mov    %eax,-0x48(%ebp)
c010607f:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0106082:	8b 40 04             	mov    0x4(%eax),%eax
     while ((le = list_next(le)) != &free_list) {
c0106085:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106088:	81 7d e8 4c e1 12 c0 	cmpl   $0xc012e14c,-0x18(%ebp)
c010608f:	0f 85 7a ff ff ff    	jne    c010600f <check_swap+0x21>
     }
     assert(total == nr_free_pages());
c0106095:	e8 1b d5 ff ff       	call   c01035b5 <nr_free_pages>
c010609a:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010609d:	39 d0                	cmp    %edx,%eax
c010609f:	74 24                	je     c01060c5 <check_swap+0xd7>
c01060a1:	c7 44 24 0c 16 b6 10 	movl   $0xc010b616,0xc(%esp)
c01060a8:	c0 
c01060a9:	c7 44 24 08 0a b5 10 	movl   $0xc010b50a,0x8(%esp)
c01060b0:	c0 
c01060b1:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
c01060b8:	00 
c01060b9:	c7 04 24 a4 b4 10 c0 	movl   $0xc010b4a4,(%esp)
c01060c0:	e8 78 a3 ff ff       	call   c010043d <__panic>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
c01060c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01060c8:	89 44 24 08          	mov    %eax,0x8(%esp)
c01060cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01060cf:	89 44 24 04          	mov    %eax,0x4(%esp)
c01060d3:	c7 04 24 30 b6 10 c0 	movl   $0xc010b630,(%esp)
c01060da:	e8 f2 a1 ff ff       	call   c01002d1 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
c01060df:	e8 4a ec ff ff       	call   c0104d2e <mm_create>
c01060e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
     assert(mm != NULL);
c01060e7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01060eb:	75 24                	jne    c0106111 <check_swap+0x123>
c01060ed:	c7 44 24 0c 56 b6 10 	movl   $0xc010b656,0xc(%esp)
c01060f4:	c0 
c01060f5:	c7 44 24 08 0a b5 10 	movl   $0xc010b50a,0x8(%esp)
c01060fc:	c0 
c01060fd:	c7 44 24 04 c1 00 00 	movl   $0xc1,0x4(%esp)
c0106104:	00 
c0106105:	c7 04 24 a4 b4 10 c0 	movl   $0xc010b4a4,(%esp)
c010610c:	e8 2c a3 ff ff       	call   c010043d <__panic>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
c0106111:	a1 64 e0 12 c0       	mov    0xc012e064,%eax
c0106116:	85 c0                	test   %eax,%eax
c0106118:	74 24                	je     c010613e <check_swap+0x150>
c010611a:	c7 44 24 0c 61 b6 10 	movl   $0xc010b661,0xc(%esp)
c0106121:	c0 
c0106122:	c7 44 24 08 0a b5 10 	movl   $0xc010b50a,0x8(%esp)
c0106129:	c0 
c010612a:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
c0106131:	00 
c0106132:	c7 04 24 a4 b4 10 c0 	movl   $0xc010b4a4,(%esp)
c0106139:	e8 ff a2 ff ff       	call   c010043d <__panic>

     check_mm_struct = mm;
c010613e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106141:	a3 64 e0 12 c0       	mov    %eax,0xc012e064

     pde_t *pgdir = mm->pgdir = boot_pgdir;
c0106146:	8b 15 e0 89 12 c0    	mov    0xc01289e0,%edx
c010614c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010614f:	89 50 0c             	mov    %edx,0xc(%eax)
c0106152:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106155:	8b 40 0c             	mov    0xc(%eax),%eax
c0106158:	89 45 e0             	mov    %eax,-0x20(%ebp)
     assert(pgdir[0] == 0);
c010615b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010615e:	8b 00                	mov    (%eax),%eax
c0106160:	85 c0                	test   %eax,%eax
c0106162:	74 24                	je     c0106188 <check_swap+0x19a>
c0106164:	c7 44 24 0c 79 b6 10 	movl   $0xc010b679,0xc(%esp)
c010616b:	c0 
c010616c:	c7 44 24 08 0a b5 10 	movl   $0xc010b50a,0x8(%esp)
c0106173:	c0 
c0106174:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
c010617b:	00 
c010617c:	c7 04 24 a4 b4 10 c0 	movl   $0xc010b4a4,(%esp)
c0106183:	e8 b5 a2 ff ff       	call   c010043d <__panic>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
c0106188:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
c010618f:	00 
c0106190:	c7 44 24 04 00 60 00 	movl   $0x6000,0x4(%esp)
c0106197:	00 
c0106198:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
c010619f:	e8 07 ec ff ff       	call   c0104dab <vma_create>
c01061a4:	89 45 dc             	mov    %eax,-0x24(%ebp)
     assert(vma != NULL);
c01061a7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c01061ab:	75 24                	jne    c01061d1 <check_swap+0x1e3>
c01061ad:	c7 44 24 0c 87 b6 10 	movl   $0xc010b687,0xc(%esp)
c01061b4:	c0 
c01061b5:	c7 44 24 08 0a b5 10 	movl   $0xc010b50a,0x8(%esp)
c01061bc:	c0 
c01061bd:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
c01061c4:	00 
c01061c5:	c7 04 24 a4 b4 10 c0 	movl   $0xc010b4a4,(%esp)
c01061cc:	e8 6c a2 ff ff       	call   c010043d <__panic>

     insert_vma_struct(mm, vma);
c01061d1:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01061d4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01061d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01061db:	89 04 24             	mov    %eax,(%esp)
c01061de:	e8 61 ed ff ff       	call   c0104f44 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
c01061e3:	c7 04 24 94 b6 10 c0 	movl   $0xc010b694,(%esp)
c01061ea:	e8 e2 a0 ff ff       	call   c01002d1 <cprintf>
     pte_t *temp_ptep=NULL;
c01061ef:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
c01061f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01061f9:	8b 40 0c             	mov    0xc(%eax),%eax
c01061fc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0106203:	00 
c0106204:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c010620b:	00 
c010620c:	89 04 24             	mov    %eax,(%esp)
c010620f:	e8 cb d9 ff ff       	call   c0103bdf <get_pte>
c0106214:	89 45 d8             	mov    %eax,-0x28(%ebp)
     assert(temp_ptep!= NULL);
c0106217:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c010621b:	75 24                	jne    c0106241 <check_swap+0x253>
c010621d:	c7 44 24 0c c8 b6 10 	movl   $0xc010b6c8,0xc(%esp)
c0106224:	c0 
c0106225:	c7 44 24 08 0a b5 10 	movl   $0xc010b50a,0x8(%esp)
c010622c:	c0 
c010622d:	c7 44 24 04 d4 00 00 	movl   $0xd4,0x4(%esp)
c0106234:	00 
c0106235:	c7 04 24 a4 b4 10 c0 	movl   $0xc010b4a4,(%esp)
c010623c:	e8 fc a1 ff ff       	call   c010043d <__panic>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
c0106241:	c7 04 24 dc b6 10 c0 	movl   $0xc010b6dc,(%esp)
c0106248:	e8 84 a0 ff ff       	call   c01002d1 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c010624d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0106254:	e9 a2 00 00 00       	jmp    c01062fb <check_swap+0x30d>
          check_rp[i] = alloc_page();
c0106259:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106260:	e8 aa d2 ff ff       	call   c010350f <alloc_pages>
c0106265:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106268:	89 04 95 80 e0 12 c0 	mov    %eax,-0x3fed1f80(,%edx,4)
          assert(check_rp[i] != NULL );
c010626f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106272:	8b 04 85 80 e0 12 c0 	mov    -0x3fed1f80(,%eax,4),%eax
c0106279:	85 c0                	test   %eax,%eax
c010627b:	75 24                	jne    c01062a1 <check_swap+0x2b3>
c010627d:	c7 44 24 0c 00 b7 10 	movl   $0xc010b700,0xc(%esp)
c0106284:	c0 
c0106285:	c7 44 24 08 0a b5 10 	movl   $0xc010b50a,0x8(%esp)
c010628c:	c0 
c010628d:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
c0106294:	00 
c0106295:	c7 04 24 a4 b4 10 c0 	movl   $0xc010b4a4,(%esp)
c010629c:	e8 9c a1 ff ff       	call   c010043d <__panic>
          assert(!PageProperty(check_rp[i]));
c01062a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01062a4:	8b 04 85 80 e0 12 c0 	mov    -0x3fed1f80(,%eax,4),%eax
c01062ab:	83 c0 04             	add    $0x4,%eax
c01062ae:	c7 45 b4 01 00 00 00 	movl   $0x1,-0x4c(%ebp)
c01062b5:	89 45 b0             	mov    %eax,-0x50(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01062b8:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01062bb:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01062be:	0f a3 10             	bt     %edx,(%eax)
c01062c1:	19 c0                	sbb    %eax,%eax
c01062c3:	89 45 ac             	mov    %eax,-0x54(%ebp)
    return oldbit != 0;
c01062c6:	83 7d ac 00          	cmpl   $0x0,-0x54(%ebp)
c01062ca:	0f 95 c0             	setne  %al
c01062cd:	0f b6 c0             	movzbl %al,%eax
c01062d0:	85 c0                	test   %eax,%eax
c01062d2:	74 24                	je     c01062f8 <check_swap+0x30a>
c01062d4:	c7 44 24 0c 14 b7 10 	movl   $0xc010b714,0xc(%esp)
c01062db:	c0 
c01062dc:	c7 44 24 08 0a b5 10 	movl   $0xc010b50a,0x8(%esp)
c01062e3:	c0 
c01062e4:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
c01062eb:	00 
c01062ec:	c7 04 24 a4 b4 10 c0 	movl   $0xc010b4a4,(%esp)
c01062f3:	e8 45 a1 ff ff       	call   c010043d <__panic>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01062f8:	ff 45 ec             	incl   -0x14(%ebp)
c01062fb:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c01062ff:	0f 8e 54 ff ff ff    	jle    c0106259 <check_swap+0x26b>
     }
     list_entry_t free_list_store = free_list;
c0106305:	a1 4c e1 12 c0       	mov    0xc012e14c,%eax
c010630a:	8b 15 50 e1 12 c0    	mov    0xc012e150,%edx
c0106310:	89 45 98             	mov    %eax,-0x68(%ebp)
c0106313:	89 55 9c             	mov    %edx,-0x64(%ebp)
c0106316:	c7 45 a4 4c e1 12 c0 	movl   $0xc012e14c,-0x5c(%ebp)
    elm->prev = elm->next = elm;
c010631d:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0106320:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0106323:	89 50 04             	mov    %edx,0x4(%eax)
c0106326:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0106329:	8b 50 04             	mov    0x4(%eax),%edx
c010632c:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c010632f:	89 10                	mov    %edx,(%eax)
}
c0106331:	90                   	nop
c0106332:	c7 45 a8 4c e1 12 c0 	movl   $0xc012e14c,-0x58(%ebp)
    return list->next == list;
c0106339:	8b 45 a8             	mov    -0x58(%ebp),%eax
c010633c:	8b 40 04             	mov    0x4(%eax),%eax
c010633f:	39 45 a8             	cmp    %eax,-0x58(%ebp)
c0106342:	0f 94 c0             	sete   %al
c0106345:	0f b6 c0             	movzbl %al,%eax
     list_init(&free_list);
     assert(list_empty(&free_list));
c0106348:	85 c0                	test   %eax,%eax
c010634a:	75 24                	jne    c0106370 <check_swap+0x382>
c010634c:	c7 44 24 0c 2f b7 10 	movl   $0xc010b72f,0xc(%esp)
c0106353:	c0 
c0106354:	c7 44 24 08 0a b5 10 	movl   $0xc010b50a,0x8(%esp)
c010635b:	c0 
c010635c:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
c0106363:	00 
c0106364:	c7 04 24 a4 b4 10 c0 	movl   $0xc010b4a4,(%esp)
c010636b:	e8 cd a0 ff ff       	call   c010043d <__panic>
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
c0106370:	a1 54 e1 12 c0       	mov    0xc012e154,%eax
c0106375:	89 45 d4             	mov    %eax,-0x2c(%ebp)
     nr_free = 0;
c0106378:	c7 05 54 e1 12 c0 00 	movl   $0x0,0xc012e154
c010637f:	00 00 00 
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106382:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0106389:	eb 1d                	jmp    c01063a8 <check_swap+0x3ba>
        free_pages(check_rp[i],1);
c010638b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010638e:	8b 04 85 80 e0 12 c0 	mov    -0x3fed1f80(,%eax,4),%eax
c0106395:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010639c:	00 
c010639d:	89 04 24             	mov    %eax,(%esp)
c01063a0:	e8 d9 d1 ff ff       	call   c010357e <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01063a5:	ff 45 ec             	incl   -0x14(%ebp)
c01063a8:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c01063ac:	7e dd                	jle    c010638b <check_swap+0x39d>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
c01063ae:	a1 54 e1 12 c0       	mov    0xc012e154,%eax
c01063b3:	83 f8 04             	cmp    $0x4,%eax
c01063b6:	74 24                	je     c01063dc <check_swap+0x3ee>
c01063b8:	c7 44 24 0c 48 b7 10 	movl   $0xc010b748,0xc(%esp)
c01063bf:	c0 
c01063c0:	c7 44 24 08 0a b5 10 	movl   $0xc010b50a,0x8(%esp)
c01063c7:	c0 
c01063c8:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
c01063cf:	00 
c01063d0:	c7 04 24 a4 b4 10 c0 	movl   $0xc010b4a4,(%esp)
c01063d7:	e8 61 a0 ff ff       	call   c010043d <__panic>
     
     cprintf("set up init env for check_swap begin!\n");
c01063dc:	c7 04 24 6c b7 10 c0 	movl   $0xc010b76c,(%esp)
c01063e3:	e8 e9 9e ff ff       	call   c01002d1 <cprintf>
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
c01063e8:	c7 05 0c c0 12 c0 00 	movl   $0x0,0xc012c00c
c01063ef:	00 00 00 
     
     check_content_set();
c01063f2:	e8 26 fa ff ff       	call   c0105e1d <check_content_set>
     assert( nr_free == 0);         
c01063f7:	a1 54 e1 12 c0       	mov    0xc012e154,%eax
c01063fc:	85 c0                	test   %eax,%eax
c01063fe:	74 24                	je     c0106424 <check_swap+0x436>
c0106400:	c7 44 24 0c 93 b7 10 	movl   $0xc010b793,0xc(%esp)
c0106407:	c0 
c0106408:	c7 44 24 08 0a b5 10 	movl   $0xc010b50a,0x8(%esp)
c010640f:	c0 
c0106410:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
c0106417:	00 
c0106418:	c7 04 24 a4 b4 10 c0 	movl   $0xc010b4a4,(%esp)
c010641f:	e8 19 a0 ff ff       	call   c010043d <__panic>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c0106424:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c010642b:	eb 25                	jmp    c0106452 <check_swap+0x464>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
c010642d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106430:	c7 04 85 a0 e0 12 c0 	movl   $0xffffffff,-0x3fed1f60(,%eax,4)
c0106437:	ff ff ff ff 
c010643b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010643e:	8b 14 85 a0 e0 12 c0 	mov    -0x3fed1f60(,%eax,4),%edx
c0106445:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106448:	89 14 85 e0 e0 12 c0 	mov    %edx,-0x3fed1f20(,%eax,4)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c010644f:	ff 45 ec             	incl   -0x14(%ebp)
c0106452:	83 7d ec 09          	cmpl   $0x9,-0x14(%ebp)
c0106456:	7e d5                	jle    c010642d <check_swap+0x43f>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106458:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c010645f:	e9 e8 00 00 00       	jmp    c010654c <check_swap+0x55e>
         check_ptep[i]=0;
c0106464:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106467:	c7 04 85 34 e1 12 c0 	movl   $0x0,-0x3fed1ecc(,%eax,4)
c010646e:	00 00 00 00 
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
c0106472:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106475:	40                   	inc    %eax
c0106476:	c1 e0 0c             	shl    $0xc,%eax
c0106479:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106480:	00 
c0106481:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106485:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106488:	89 04 24             	mov    %eax,(%esp)
c010648b:	e8 4f d7 ff ff       	call   c0103bdf <get_pte>
c0106490:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106493:	89 04 95 34 e1 12 c0 	mov    %eax,-0x3fed1ecc(,%edx,4)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
c010649a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010649d:	8b 04 85 34 e1 12 c0 	mov    -0x3fed1ecc(,%eax,4),%eax
c01064a4:	85 c0                	test   %eax,%eax
c01064a6:	75 24                	jne    c01064cc <check_swap+0x4de>
c01064a8:	c7 44 24 0c a0 b7 10 	movl   $0xc010b7a0,0xc(%esp)
c01064af:	c0 
c01064b0:	c7 44 24 08 0a b5 10 	movl   $0xc010b50a,0x8(%esp)
c01064b7:	c0 
c01064b8:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
c01064bf:	00 
c01064c0:	c7 04 24 a4 b4 10 c0 	movl   $0xc010b4a4,(%esp)
c01064c7:	e8 71 9f ff ff       	call   c010043d <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
c01064cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01064cf:	8b 04 85 34 e1 12 c0 	mov    -0x3fed1ecc(,%eax,4),%eax
c01064d6:	8b 00                	mov    (%eax),%eax
c01064d8:	89 04 24             	mov    %eax,(%esp)
c01064db:	e8 8b f5 ff ff       	call   c0105a6b <pte2page>
c01064e0:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01064e3:	8b 14 95 80 e0 12 c0 	mov    -0x3fed1f80(,%edx,4),%edx
c01064ea:	39 d0                	cmp    %edx,%eax
c01064ec:	74 24                	je     c0106512 <check_swap+0x524>
c01064ee:	c7 44 24 0c b8 b7 10 	movl   $0xc010b7b8,0xc(%esp)
c01064f5:	c0 
c01064f6:	c7 44 24 08 0a b5 10 	movl   $0xc010b50a,0x8(%esp)
c01064fd:	c0 
c01064fe:	c7 44 24 04 f9 00 00 	movl   $0xf9,0x4(%esp)
c0106505:	00 
c0106506:	c7 04 24 a4 b4 10 c0 	movl   $0xc010b4a4,(%esp)
c010650d:	e8 2b 9f ff ff       	call   c010043d <__panic>
         assert((*check_ptep[i] & PTE_P));          
c0106512:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106515:	8b 04 85 34 e1 12 c0 	mov    -0x3fed1ecc(,%eax,4),%eax
c010651c:	8b 00                	mov    (%eax),%eax
c010651e:	83 e0 01             	and    $0x1,%eax
c0106521:	85 c0                	test   %eax,%eax
c0106523:	75 24                	jne    c0106549 <check_swap+0x55b>
c0106525:	c7 44 24 0c e0 b7 10 	movl   $0xc010b7e0,0xc(%esp)
c010652c:	c0 
c010652d:	c7 44 24 08 0a b5 10 	movl   $0xc010b50a,0x8(%esp)
c0106534:	c0 
c0106535:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c010653c:	00 
c010653d:	c7 04 24 a4 b4 10 c0 	movl   $0xc010b4a4,(%esp)
c0106544:	e8 f4 9e ff ff       	call   c010043d <__panic>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106549:	ff 45 ec             	incl   -0x14(%ebp)
c010654c:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0106550:	0f 8e 0e ff ff ff    	jle    c0106464 <check_swap+0x476>
     }
     cprintf("set up init env for check_swap over!\n");
c0106556:	c7 04 24 fc b7 10 c0 	movl   $0xc010b7fc,(%esp)
c010655d:	e8 6f 9d ff ff       	call   c01002d1 <cprintf>
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
c0106562:	e8 6f fa ff ff       	call   c0105fd6 <check_content_access>
c0106567:	89 45 d0             	mov    %eax,-0x30(%ebp)
     assert(ret==0);
c010656a:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c010656e:	74 24                	je     c0106594 <check_swap+0x5a6>
c0106570:	c7 44 24 0c 22 b8 10 	movl   $0xc010b822,0xc(%esp)
c0106577:	c0 
c0106578:	c7 44 24 08 0a b5 10 	movl   $0xc010b50a,0x8(%esp)
c010657f:	c0 
c0106580:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
c0106587:	00 
c0106588:	c7 04 24 a4 b4 10 c0 	movl   $0xc010b4a4,(%esp)
c010658f:	e8 a9 9e ff ff       	call   c010043d <__panic>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106594:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c010659b:	eb 1d                	jmp    c01065ba <check_swap+0x5cc>
         free_pages(check_rp[i],1);
c010659d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01065a0:	8b 04 85 80 e0 12 c0 	mov    -0x3fed1f80(,%eax,4),%eax
c01065a7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01065ae:	00 
c01065af:	89 04 24             	mov    %eax,(%esp)
c01065b2:	e8 c7 cf ff ff       	call   c010357e <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01065b7:	ff 45 ec             	incl   -0x14(%ebp)
c01065ba:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c01065be:	7e dd                	jle    c010659d <check_swap+0x5af>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
c01065c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01065c3:	89 04 24             	mov    %eax,(%esp)
c01065c6:	e8 b1 ea ff ff       	call   c010507c <mm_destroy>
         
     nr_free = nr_free_store;
c01065cb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01065ce:	a3 54 e1 12 c0       	mov    %eax,0xc012e154
     free_list = free_list_store;
c01065d3:	8b 45 98             	mov    -0x68(%ebp),%eax
c01065d6:	8b 55 9c             	mov    -0x64(%ebp),%edx
c01065d9:	a3 4c e1 12 c0       	mov    %eax,0xc012e14c
c01065de:	89 15 50 e1 12 c0    	mov    %edx,0xc012e150

     
     le = &free_list;
c01065e4:	c7 45 e8 4c e1 12 c0 	movl   $0xc012e14c,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c01065eb:	eb 1c                	jmp    c0106609 <check_swap+0x61b>
         struct Page *p = le2page(le, page_link);
c01065ed:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01065f0:	83 e8 0c             	sub    $0xc,%eax
c01065f3:	89 45 cc             	mov    %eax,-0x34(%ebp)
         count --, total -= p->property;
c01065f6:	ff 4d f4             	decl   -0xc(%ebp)
c01065f9:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01065fc:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01065ff:	8b 40 08             	mov    0x8(%eax),%eax
c0106602:	29 c2                	sub    %eax,%edx
c0106604:	89 d0                	mov    %edx,%eax
c0106606:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106609:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010660c:	89 45 a0             	mov    %eax,-0x60(%ebp)
    return listelm->next;
c010660f:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0106612:	8b 40 04             	mov    0x4(%eax),%eax
     while ((le = list_next(le)) != &free_list) {
c0106615:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106618:	81 7d e8 4c e1 12 c0 	cmpl   $0xc012e14c,-0x18(%ebp)
c010661f:	75 cc                	jne    c01065ed <check_swap+0x5ff>
     }
     cprintf("count is %d, total is %d\n",count,total);
c0106621:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106624:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106628:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010662b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010662f:	c7 04 24 29 b8 10 c0 	movl   $0xc010b829,(%esp)
c0106636:	e8 96 9c ff ff       	call   c01002d1 <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
c010663b:	c7 04 24 43 b8 10 c0 	movl   $0xc010b843,(%esp)
c0106642:	e8 8a 9c ff ff       	call   c01002d1 <cprintf>
}
c0106647:	90                   	nop
c0106648:	c9                   	leave  
c0106649:	c3                   	ret    

c010664a <__intr_save>:
__intr_save(void) {
c010664a:	55                   	push   %ebp
c010664b:	89 e5                	mov    %esp,%ebp
c010664d:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0106650:	9c                   	pushf  
c0106651:	58                   	pop    %eax
c0106652:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0106655:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0106658:	25 00 02 00 00       	and    $0x200,%eax
c010665d:	85 c0                	test   %eax,%eax
c010665f:	74 0c                	je     c010666d <__intr_save+0x23>
        intr_disable();
c0106661:	e8 9e bb ff ff       	call   c0102204 <intr_disable>
        return 1;
c0106666:	b8 01 00 00 00       	mov    $0x1,%eax
c010666b:	eb 05                	jmp    c0106672 <__intr_save+0x28>
    return 0;
c010666d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106672:	c9                   	leave  
c0106673:	c3                   	ret    

c0106674 <__intr_restore>:
__intr_restore(bool flag) {
c0106674:	55                   	push   %ebp
c0106675:	89 e5                	mov    %esp,%ebp
c0106677:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c010667a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010667e:	74 05                	je     c0106685 <__intr_restore+0x11>
        intr_enable();
c0106680:	e8 73 bb ff ff       	call   c01021f8 <intr_enable>
}
c0106685:	90                   	nop
c0106686:	c9                   	leave  
c0106687:	c3                   	ret    

c0106688 <page2ppn>:
page2ppn(struct Page *page) {
c0106688:	55                   	push   %ebp
c0106689:	89 e5                	mov    %esp,%ebp
    return page - pages;
c010668b:	a1 60 e0 12 c0       	mov    0xc012e060,%eax
c0106690:	8b 55 08             	mov    0x8(%ebp),%edx
c0106693:	29 c2                	sub    %eax,%edx
c0106695:	89 d0                	mov    %edx,%eax
c0106697:	c1 f8 05             	sar    $0x5,%eax
}
c010669a:	5d                   	pop    %ebp
c010669b:	c3                   	ret    

c010669c <page2pa>:
page2pa(struct Page *page) {
c010669c:	55                   	push   %ebp
c010669d:	89 e5                	mov    %esp,%ebp
c010669f:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01066a2:	8b 45 08             	mov    0x8(%ebp),%eax
c01066a5:	89 04 24             	mov    %eax,(%esp)
c01066a8:	e8 db ff ff ff       	call   c0106688 <page2ppn>
c01066ad:	c1 e0 0c             	shl    $0xc,%eax
}
c01066b0:	c9                   	leave  
c01066b1:	c3                   	ret    

c01066b2 <pa2page>:
pa2page(uintptr_t pa) {
c01066b2:	55                   	push   %ebp
c01066b3:	89 e5                	mov    %esp,%ebp
c01066b5:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c01066b8:	8b 45 08             	mov    0x8(%ebp),%eax
c01066bb:	c1 e8 0c             	shr    $0xc,%eax
c01066be:	89 c2                	mov    %eax,%edx
c01066c0:	a1 80 bf 12 c0       	mov    0xc012bf80,%eax
c01066c5:	39 c2                	cmp    %eax,%edx
c01066c7:	72 1c                	jb     c01066e5 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c01066c9:	c7 44 24 08 5c b8 10 	movl   $0xc010b85c,0x8(%esp)
c01066d0:	c0 
c01066d1:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
c01066d8:	00 
c01066d9:	c7 04 24 7b b8 10 c0 	movl   $0xc010b87b,(%esp)
c01066e0:	e8 58 9d ff ff       	call   c010043d <__panic>
    return &pages[PPN(pa)];
c01066e5:	a1 60 e0 12 c0       	mov    0xc012e060,%eax
c01066ea:	8b 55 08             	mov    0x8(%ebp),%edx
c01066ed:	c1 ea 0c             	shr    $0xc,%edx
c01066f0:	c1 e2 05             	shl    $0x5,%edx
c01066f3:	01 d0                	add    %edx,%eax
}
c01066f5:	c9                   	leave  
c01066f6:	c3                   	ret    

c01066f7 <page2kva>:
page2kva(struct Page *page) {
c01066f7:	55                   	push   %ebp
c01066f8:	89 e5                	mov    %esp,%ebp
c01066fa:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c01066fd:	8b 45 08             	mov    0x8(%ebp),%eax
c0106700:	89 04 24             	mov    %eax,(%esp)
c0106703:	e8 94 ff ff ff       	call   c010669c <page2pa>
c0106708:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010670b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010670e:	c1 e8 0c             	shr    $0xc,%eax
c0106711:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106714:	a1 80 bf 12 c0       	mov    0xc012bf80,%eax
c0106719:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010671c:	72 23                	jb     c0106741 <page2kva+0x4a>
c010671e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106721:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106725:	c7 44 24 08 8c b8 10 	movl   $0xc010b88c,0x8(%esp)
c010672c:	c0 
c010672d:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
c0106734:	00 
c0106735:	c7 04 24 7b b8 10 c0 	movl   $0xc010b87b,(%esp)
c010673c:	e8 fc 9c ff ff       	call   c010043d <__panic>
c0106741:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106744:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0106749:	c9                   	leave  
c010674a:	c3                   	ret    

c010674b <kva2page>:
kva2page(void *kva) {
c010674b:	55                   	push   %ebp
c010674c:	89 e5                	mov    %esp,%ebp
c010674e:	83 ec 28             	sub    $0x28,%esp
    return pa2page(PADDR(kva));
c0106751:	8b 45 08             	mov    0x8(%ebp),%eax
c0106754:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106757:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c010675e:	77 23                	ja     c0106783 <kva2page+0x38>
c0106760:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106763:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106767:	c7 44 24 08 b0 b8 10 	movl   $0xc010b8b0,0x8(%esp)
c010676e:	c0 
c010676f:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
c0106776:	00 
c0106777:	c7 04 24 7b b8 10 c0 	movl   $0xc010b87b,(%esp)
c010677e:	e8 ba 9c ff ff       	call   c010043d <__panic>
c0106783:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106786:	05 00 00 00 40       	add    $0x40000000,%eax
c010678b:	89 04 24             	mov    %eax,(%esp)
c010678e:	e8 1f ff ff ff       	call   c01066b2 <pa2page>
}
c0106793:	c9                   	leave  
c0106794:	c3                   	ret    

c0106795 <__slob_get_free_pages>:
static slob_t *slobfree = &arena;
static bigblock_t *bigblocks;


static void* __slob_get_free_pages(gfp_t gfp, int order)
{
c0106795:	f3 0f 1e fb          	endbr32 
c0106799:	55                   	push   %ebp
c010679a:	89 e5                	mov    %esp,%ebp
c010679c:	83 ec 28             	sub    $0x28,%esp
  struct Page * page = alloc_pages(1 << order);
c010679f:	8b 45 0c             	mov    0xc(%ebp),%eax
c01067a2:	ba 01 00 00 00       	mov    $0x1,%edx
c01067a7:	88 c1                	mov    %al,%cl
c01067a9:	d3 e2                	shl    %cl,%edx
c01067ab:	89 d0                	mov    %edx,%eax
c01067ad:	89 04 24             	mov    %eax,(%esp)
c01067b0:	e8 5a cd ff ff       	call   c010350f <alloc_pages>
c01067b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!page)
c01067b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01067bc:	75 07                	jne    c01067c5 <__slob_get_free_pages+0x30>
    return NULL;
c01067be:	b8 00 00 00 00       	mov    $0x0,%eax
c01067c3:	eb 0b                	jmp    c01067d0 <__slob_get_free_pages+0x3b>
  return page2kva(page);
c01067c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01067c8:	89 04 24             	mov    %eax,(%esp)
c01067cb:	e8 27 ff ff ff       	call   c01066f7 <page2kva>
}
c01067d0:	c9                   	leave  
c01067d1:	c3                   	ret    

c01067d2 <__slob_free_pages>:

#define __slob_get_free_page(gfp) __slob_get_free_pages(gfp, 0)

static inline void __slob_free_pages(unsigned long kva, int order)
{
c01067d2:	55                   	push   %ebp
c01067d3:	89 e5                	mov    %esp,%ebp
c01067d5:	53                   	push   %ebx
c01067d6:	83 ec 14             	sub    $0x14,%esp
  free_pages(kva2page(kva), 1 << order);
c01067d9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01067dc:	ba 01 00 00 00       	mov    $0x1,%edx
c01067e1:	88 c1                	mov    %al,%cl
c01067e3:	d3 e2                	shl    %cl,%edx
c01067e5:	89 d0                	mov    %edx,%eax
c01067e7:	89 c3                	mov    %eax,%ebx
c01067e9:	8b 45 08             	mov    0x8(%ebp),%eax
c01067ec:	89 04 24             	mov    %eax,(%esp)
c01067ef:	e8 57 ff ff ff       	call   c010674b <kva2page>
c01067f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01067f8:	89 04 24             	mov    %eax,(%esp)
c01067fb:	e8 7e cd ff ff       	call   c010357e <free_pages>
}
c0106800:	90                   	nop
c0106801:	83 c4 14             	add    $0x14,%esp
c0106804:	5b                   	pop    %ebx
c0106805:	5d                   	pop    %ebp
c0106806:	c3                   	ret    

c0106807 <slob_alloc>:

static void slob_free(void *b, int size);

static void *slob_alloc(size_t size, gfp_t gfp, int align)
{
c0106807:	f3 0f 1e fb          	endbr32 
c010680b:	55                   	push   %ebp
c010680c:	89 e5                	mov    %esp,%ebp
c010680e:	83 ec 38             	sub    $0x38,%esp
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
c0106811:	8b 45 08             	mov    0x8(%ebp),%eax
c0106814:	83 c0 08             	add    $0x8,%eax
c0106817:	3d ff 0f 00 00       	cmp    $0xfff,%eax
c010681c:	76 24                	jbe    c0106842 <slob_alloc+0x3b>
c010681e:	c7 44 24 0c d4 b8 10 	movl   $0xc010b8d4,0xc(%esp)
c0106825:	c0 
c0106826:	c7 44 24 08 f3 b8 10 	movl   $0xc010b8f3,0x8(%esp)
c010682d:	c0 
c010682e:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c0106835:	00 
c0106836:	c7 04 24 08 b9 10 c0 	movl   $0xc010b908,(%esp)
c010683d:	e8 fb 9b ff ff       	call   c010043d <__panic>

	slob_t *prev, *cur, *aligned = 0;
c0106842:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	int delta = 0, units = SLOB_UNITS(size);
c0106849:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0106850:	8b 45 08             	mov    0x8(%ebp),%eax
c0106853:	83 c0 07             	add    $0x7,%eax
c0106856:	c1 e8 03             	shr    $0x3,%eax
c0106859:	89 45 e0             	mov    %eax,-0x20(%ebp)
	unsigned long flags;

	spin_lock_irqsave(&slob_lock, flags);
c010685c:	e8 e9 fd ff ff       	call   c010664a <__intr_save>
c0106861:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	prev = slobfree;
c0106864:	a1 40 8a 12 c0       	mov    0xc0128a40,%eax
c0106869:	89 45 f4             	mov    %eax,-0xc(%ebp)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
c010686c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010686f:	8b 40 04             	mov    0x4(%eax),%eax
c0106872:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if (align) {
c0106875:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106879:	74 21                	je     c010689c <slob_alloc+0x95>
			aligned = (slob_t *)ALIGN((unsigned long)cur, align);
c010687b:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010687e:	8b 45 10             	mov    0x10(%ebp),%eax
c0106881:	01 d0                	add    %edx,%eax
c0106883:	8d 50 ff             	lea    -0x1(%eax),%edx
c0106886:	8b 45 10             	mov    0x10(%ebp),%eax
c0106889:	f7 d8                	neg    %eax
c010688b:	21 d0                	and    %edx,%eax
c010688d:	89 45 ec             	mov    %eax,-0x14(%ebp)
			delta = aligned - cur;
c0106890:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106893:	2b 45 f0             	sub    -0x10(%ebp),%eax
c0106896:	c1 f8 03             	sar    $0x3,%eax
c0106899:	89 45 e8             	mov    %eax,-0x18(%ebp)
		}
		if (cur->units >= units + delta) { /* room enough? */
c010689c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010689f:	8b 00                	mov    (%eax),%eax
c01068a1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c01068a4:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01068a7:	01 ca                	add    %ecx,%edx
c01068a9:	39 d0                	cmp    %edx,%eax
c01068ab:	0f 8c aa 00 00 00    	jl     c010695b <slob_alloc+0x154>
			if (delta) { /* need to fragment head to align? */
c01068b1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01068b5:	74 38                	je     c01068ef <slob_alloc+0xe8>
				aligned->units = cur->units - delta;
c01068b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01068ba:	8b 00                	mov    (%eax),%eax
c01068bc:	2b 45 e8             	sub    -0x18(%ebp),%eax
c01068bf:	89 c2                	mov    %eax,%edx
c01068c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01068c4:	89 10                	mov    %edx,(%eax)
				aligned->next = cur->next;
c01068c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01068c9:	8b 50 04             	mov    0x4(%eax),%edx
c01068cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01068cf:	89 50 04             	mov    %edx,0x4(%eax)
				cur->next = aligned;
c01068d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01068d5:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01068d8:	89 50 04             	mov    %edx,0x4(%eax)
				cur->units = delta;
c01068db:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01068de:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01068e1:	89 10                	mov    %edx,(%eax)
				prev = cur;
c01068e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01068e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
				cur = aligned;
c01068e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01068ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
			}

			if (cur->units == units) /* exact fit? */
c01068ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01068f2:	8b 00                	mov    (%eax),%eax
c01068f4:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c01068f7:	75 0e                	jne    c0106907 <slob_alloc+0x100>
				prev->next = cur->next; /* unlink */
c01068f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01068fc:	8b 50 04             	mov    0x4(%eax),%edx
c01068ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106902:	89 50 04             	mov    %edx,0x4(%eax)
c0106905:	eb 3c                	jmp    c0106943 <slob_alloc+0x13c>
			else { /* fragment */
				prev->next = cur + units;
c0106907:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010690a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0106911:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106914:	01 c2                	add    %eax,%edx
c0106916:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106919:	89 50 04             	mov    %edx,0x4(%eax)
				prev->next->units = cur->units - units;
c010691c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010691f:	8b 10                	mov    (%eax),%edx
c0106921:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106924:	8b 40 04             	mov    0x4(%eax),%eax
c0106927:	2b 55 e0             	sub    -0x20(%ebp),%edx
c010692a:	89 10                	mov    %edx,(%eax)
				prev->next->next = cur->next;
c010692c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010692f:	8b 40 04             	mov    0x4(%eax),%eax
c0106932:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0106935:	8b 52 04             	mov    0x4(%edx),%edx
c0106938:	89 50 04             	mov    %edx,0x4(%eax)
				cur->units = units;
c010693b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010693e:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106941:	89 10                	mov    %edx,(%eax)
			}

			slobfree = prev;
c0106943:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106946:	a3 40 8a 12 c0       	mov    %eax,0xc0128a40
			spin_unlock_irqrestore(&slob_lock, flags);
c010694b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010694e:	89 04 24             	mov    %eax,(%esp)
c0106951:	e8 1e fd ff ff       	call   c0106674 <__intr_restore>
			return cur;
c0106956:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106959:	eb 7f                	jmp    c01069da <slob_alloc+0x1d3>
		}
		if (cur == slobfree) {
c010695b:	a1 40 8a 12 c0       	mov    0xc0128a40,%eax
c0106960:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0106963:	75 61                	jne    c01069c6 <slob_alloc+0x1bf>
			spin_unlock_irqrestore(&slob_lock, flags);
c0106965:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106968:	89 04 24             	mov    %eax,(%esp)
c010696b:	e8 04 fd ff ff       	call   c0106674 <__intr_restore>

			if (size == PAGE_SIZE) /* trying to shrink arena? */
c0106970:	81 7d 08 00 10 00 00 	cmpl   $0x1000,0x8(%ebp)
c0106977:	75 07                	jne    c0106980 <slob_alloc+0x179>
				return 0;
c0106979:	b8 00 00 00 00       	mov    $0x0,%eax
c010697e:	eb 5a                	jmp    c01069da <slob_alloc+0x1d3>

			cur = (slob_t *)__slob_get_free_page(gfp);
c0106980:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0106987:	00 
c0106988:	8b 45 0c             	mov    0xc(%ebp),%eax
c010698b:	89 04 24             	mov    %eax,(%esp)
c010698e:	e8 02 fe ff ff       	call   c0106795 <__slob_get_free_pages>
c0106993:	89 45 f0             	mov    %eax,-0x10(%ebp)
			if (!cur)
c0106996:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010699a:	75 07                	jne    c01069a3 <slob_alloc+0x19c>
				return 0;
c010699c:	b8 00 00 00 00       	mov    $0x0,%eax
c01069a1:	eb 37                	jmp    c01069da <slob_alloc+0x1d3>

			slob_free(cur, PAGE_SIZE);
c01069a3:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01069aa:	00 
c01069ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01069ae:	89 04 24             	mov    %eax,(%esp)
c01069b1:	e8 26 00 00 00       	call   c01069dc <slob_free>
			spin_lock_irqsave(&slob_lock, flags);
c01069b6:	e8 8f fc ff ff       	call   c010664a <__intr_save>
c01069bb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			cur = slobfree;
c01069be:	a1 40 8a 12 c0       	mov    0xc0128a40,%eax
c01069c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
c01069c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01069c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01069cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01069cf:	8b 40 04             	mov    0x4(%eax),%eax
c01069d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if (align) {
c01069d5:	e9 9b fe ff ff       	jmp    c0106875 <slob_alloc+0x6e>
		}
	}
}
c01069da:	c9                   	leave  
c01069db:	c3                   	ret    

c01069dc <slob_free>:

static void slob_free(void *block, int size)
{
c01069dc:	f3 0f 1e fb          	endbr32 
c01069e0:	55                   	push   %ebp
c01069e1:	89 e5                	mov    %esp,%ebp
c01069e3:	83 ec 28             	sub    $0x28,%esp
	slob_t *cur, *b = (slob_t *)block;
c01069e6:	8b 45 08             	mov    0x8(%ebp),%eax
c01069e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
	unsigned long flags;

	if (!block)
c01069ec:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01069f0:	0f 84 01 01 00 00    	je     c0106af7 <slob_free+0x11b>
		return;

	if (size)
c01069f6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01069fa:	74 10                	je     c0106a0c <slob_free+0x30>
		b->units = SLOB_UNITS(size);
c01069fc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01069ff:	83 c0 07             	add    $0x7,%eax
c0106a02:	c1 e8 03             	shr    $0x3,%eax
c0106a05:	89 c2                	mov    %eax,%edx
c0106a07:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106a0a:	89 10                	mov    %edx,(%eax)

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
c0106a0c:	e8 39 fc ff ff       	call   c010664a <__intr_save>
c0106a11:	89 45 ec             	mov    %eax,-0x14(%ebp)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
c0106a14:	a1 40 8a 12 c0       	mov    0xc0128a40,%eax
c0106a19:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106a1c:	eb 27                	jmp    c0106a45 <slob_free+0x69>
		if (cur >= cur->next && (b > cur || b < cur->next))
c0106a1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106a21:	8b 40 04             	mov    0x4(%eax),%eax
c0106a24:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0106a27:	72 13                	jb     c0106a3c <slob_free+0x60>
c0106a29:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106a2c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0106a2f:	77 27                	ja     c0106a58 <slob_free+0x7c>
c0106a31:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106a34:	8b 40 04             	mov    0x4(%eax),%eax
c0106a37:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0106a3a:	72 1c                	jb     c0106a58 <slob_free+0x7c>
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
c0106a3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106a3f:	8b 40 04             	mov    0x4(%eax),%eax
c0106a42:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106a45:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106a48:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0106a4b:	76 d1                	jbe    c0106a1e <slob_free+0x42>
c0106a4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106a50:	8b 40 04             	mov    0x4(%eax),%eax
c0106a53:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0106a56:	73 c6                	jae    c0106a1e <slob_free+0x42>
			break;

	if (b + b->units == cur->next) {
c0106a58:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106a5b:	8b 00                	mov    (%eax),%eax
c0106a5d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0106a64:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106a67:	01 c2                	add    %eax,%edx
c0106a69:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106a6c:	8b 40 04             	mov    0x4(%eax),%eax
c0106a6f:	39 c2                	cmp    %eax,%edx
c0106a71:	75 25                	jne    c0106a98 <slob_free+0xbc>
		b->units += cur->next->units;
c0106a73:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106a76:	8b 10                	mov    (%eax),%edx
c0106a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106a7b:	8b 40 04             	mov    0x4(%eax),%eax
c0106a7e:	8b 00                	mov    (%eax),%eax
c0106a80:	01 c2                	add    %eax,%edx
c0106a82:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106a85:	89 10                	mov    %edx,(%eax)
		b->next = cur->next->next;
c0106a87:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106a8a:	8b 40 04             	mov    0x4(%eax),%eax
c0106a8d:	8b 50 04             	mov    0x4(%eax),%edx
c0106a90:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106a93:	89 50 04             	mov    %edx,0x4(%eax)
c0106a96:	eb 0c                	jmp    c0106aa4 <slob_free+0xc8>
	} else
		b->next = cur->next;
c0106a98:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106a9b:	8b 50 04             	mov    0x4(%eax),%edx
c0106a9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106aa1:	89 50 04             	mov    %edx,0x4(%eax)

	if (cur + cur->units == b) {
c0106aa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106aa7:	8b 00                	mov    (%eax),%eax
c0106aa9:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0106ab0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106ab3:	01 d0                	add    %edx,%eax
c0106ab5:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0106ab8:	75 1f                	jne    c0106ad9 <slob_free+0xfd>
		cur->units += b->units;
c0106aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106abd:	8b 10                	mov    (%eax),%edx
c0106abf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106ac2:	8b 00                	mov    (%eax),%eax
c0106ac4:	01 c2                	add    %eax,%edx
c0106ac6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106ac9:	89 10                	mov    %edx,(%eax)
		cur->next = b->next;
c0106acb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106ace:	8b 50 04             	mov    0x4(%eax),%edx
c0106ad1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106ad4:	89 50 04             	mov    %edx,0x4(%eax)
c0106ad7:	eb 09                	jmp    c0106ae2 <slob_free+0x106>
	} else
		cur->next = b;
c0106ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106adc:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0106adf:	89 50 04             	mov    %edx,0x4(%eax)

	slobfree = cur;
c0106ae2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106ae5:	a3 40 8a 12 c0       	mov    %eax,0xc0128a40

	spin_unlock_irqrestore(&slob_lock, flags);
c0106aea:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106aed:	89 04 24             	mov    %eax,(%esp)
c0106af0:	e8 7f fb ff ff       	call   c0106674 <__intr_restore>
c0106af5:	eb 01                	jmp    c0106af8 <slob_free+0x11c>
		return;
c0106af7:	90                   	nop
}
c0106af8:	c9                   	leave  
c0106af9:	c3                   	ret    

c0106afa <slob_init>:



void
slob_init(void) {
c0106afa:	f3 0f 1e fb          	endbr32 
c0106afe:	55                   	push   %ebp
c0106aff:	89 e5                	mov    %esp,%ebp
c0106b01:	83 ec 18             	sub    $0x18,%esp
  cprintf("use SLOB allocator\n");
c0106b04:	c7 04 24 1a b9 10 c0 	movl   $0xc010b91a,(%esp)
c0106b0b:	e8 c1 97 ff ff       	call   c01002d1 <cprintf>
}
c0106b10:	90                   	nop
c0106b11:	c9                   	leave  
c0106b12:	c3                   	ret    

c0106b13 <kmalloc_init>:

inline void 
kmalloc_init(void) {
c0106b13:	f3 0f 1e fb          	endbr32 
c0106b17:	55                   	push   %ebp
c0106b18:	89 e5                	mov    %esp,%ebp
c0106b1a:	83 ec 18             	sub    $0x18,%esp
    slob_init();
c0106b1d:	e8 d8 ff ff ff       	call   c0106afa <slob_init>
    cprintf("kmalloc_init() succeeded!\n");
c0106b22:	c7 04 24 2e b9 10 c0 	movl   $0xc010b92e,(%esp)
c0106b29:	e8 a3 97 ff ff       	call   c01002d1 <cprintf>
}
c0106b2e:	90                   	nop
c0106b2f:	c9                   	leave  
c0106b30:	c3                   	ret    

c0106b31 <slob_allocated>:

size_t
slob_allocated(void) {
c0106b31:	f3 0f 1e fb          	endbr32 
c0106b35:	55                   	push   %ebp
c0106b36:	89 e5                	mov    %esp,%ebp
  return 0;
c0106b38:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106b3d:	5d                   	pop    %ebp
c0106b3e:	c3                   	ret    

c0106b3f <kallocated>:

size_t
kallocated(void) {
c0106b3f:	f3 0f 1e fb          	endbr32 
c0106b43:	55                   	push   %ebp
c0106b44:	89 e5                	mov    %esp,%ebp
   return slob_allocated();
c0106b46:	e8 e6 ff ff ff       	call   c0106b31 <slob_allocated>
}
c0106b4b:	5d                   	pop    %ebp
c0106b4c:	c3                   	ret    

c0106b4d <find_order>:

static int find_order(int size)
{
c0106b4d:	f3 0f 1e fb          	endbr32 
c0106b51:	55                   	push   %ebp
c0106b52:	89 e5                	mov    %esp,%ebp
c0106b54:	83 ec 10             	sub    $0x10,%esp
	int order = 0;
c0106b57:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	for ( ; size > 4096 ; size >>=1)
c0106b5e:	eb 06                	jmp    c0106b66 <find_order+0x19>
		order++;
c0106b60:	ff 45 fc             	incl   -0x4(%ebp)
	for ( ; size > 4096 ; size >>=1)
c0106b63:	d1 7d 08             	sarl   0x8(%ebp)
c0106b66:	81 7d 08 00 10 00 00 	cmpl   $0x1000,0x8(%ebp)
c0106b6d:	7f f1                	jg     c0106b60 <find_order+0x13>
	return order;
c0106b6f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0106b72:	c9                   	leave  
c0106b73:	c3                   	ret    

c0106b74 <__kmalloc>:

static void *__kmalloc(size_t size, gfp_t gfp)
{
c0106b74:	f3 0f 1e fb          	endbr32 
c0106b78:	55                   	push   %ebp
c0106b79:	89 e5                	mov    %esp,%ebp
c0106b7b:	83 ec 28             	sub    $0x28,%esp
	slob_t *m;
	bigblock_t *bb;
	unsigned long flags;

	if (size < PAGE_SIZE - SLOB_UNIT) {
c0106b7e:	81 7d 08 f7 0f 00 00 	cmpl   $0xff7,0x8(%ebp)
c0106b85:	77 3b                	ja     c0106bc2 <__kmalloc+0x4e>
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
c0106b87:	8b 45 08             	mov    0x8(%ebp),%eax
c0106b8a:	8d 50 08             	lea    0x8(%eax),%edx
c0106b8d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106b94:	00 
c0106b95:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106b98:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106b9c:	89 14 24             	mov    %edx,(%esp)
c0106b9f:	e8 63 fc ff ff       	call   c0106807 <slob_alloc>
c0106ba4:	89 45 ec             	mov    %eax,-0x14(%ebp)
		return m ? (void *)(m + 1) : 0;
c0106ba7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0106bab:	74 0b                	je     c0106bb8 <__kmalloc+0x44>
c0106bad:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106bb0:	83 c0 08             	add    $0x8,%eax
c0106bb3:	e9 b0 00 00 00       	jmp    c0106c68 <__kmalloc+0xf4>
c0106bb8:	b8 00 00 00 00       	mov    $0x0,%eax
c0106bbd:	e9 a6 00 00 00       	jmp    c0106c68 <__kmalloc+0xf4>
	}

	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
c0106bc2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106bc9:	00 
c0106bca:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106bcd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106bd1:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
c0106bd8:	e8 2a fc ff ff       	call   c0106807 <slob_alloc>
c0106bdd:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (!bb)
c0106be0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106be4:	75 07                	jne    c0106bed <__kmalloc+0x79>
		return 0;
c0106be6:	b8 00 00 00 00       	mov    $0x0,%eax
c0106beb:	eb 7b                	jmp    c0106c68 <__kmalloc+0xf4>

	bb->order = find_order(size);
c0106bed:	8b 45 08             	mov    0x8(%ebp),%eax
c0106bf0:	89 04 24             	mov    %eax,(%esp)
c0106bf3:	e8 55 ff ff ff       	call   c0106b4d <find_order>
c0106bf8:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106bfb:	89 02                	mov    %eax,(%edx)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
c0106bfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106c00:	8b 00                	mov    (%eax),%eax
c0106c02:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106c06:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106c09:	89 04 24             	mov    %eax,(%esp)
c0106c0c:	e8 84 fb ff ff       	call   c0106795 <__slob_get_free_pages>
c0106c11:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106c14:	89 42 04             	mov    %eax,0x4(%edx)

	if (bb->pages) {
c0106c17:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106c1a:	8b 40 04             	mov    0x4(%eax),%eax
c0106c1d:	85 c0                	test   %eax,%eax
c0106c1f:	74 2f                	je     c0106c50 <__kmalloc+0xdc>
		spin_lock_irqsave(&block_lock, flags);
c0106c21:	e8 24 fa ff ff       	call   c010664a <__intr_save>
c0106c26:	89 45 f0             	mov    %eax,-0x10(%ebp)
		bb->next = bigblocks;
c0106c29:	8b 15 1c c0 12 c0    	mov    0xc012c01c,%edx
c0106c2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106c32:	89 50 08             	mov    %edx,0x8(%eax)
		bigblocks = bb;
c0106c35:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106c38:	a3 1c c0 12 c0       	mov    %eax,0xc012c01c
		spin_unlock_irqrestore(&block_lock, flags);
c0106c3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106c40:	89 04 24             	mov    %eax,(%esp)
c0106c43:	e8 2c fa ff ff       	call   c0106674 <__intr_restore>
		return bb->pages;
c0106c48:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106c4b:	8b 40 04             	mov    0x4(%eax),%eax
c0106c4e:	eb 18                	jmp    c0106c68 <__kmalloc+0xf4>
	}

	slob_free(bb, sizeof(bigblock_t));
c0106c50:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
c0106c57:	00 
c0106c58:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106c5b:	89 04 24             	mov    %eax,(%esp)
c0106c5e:	e8 79 fd ff ff       	call   c01069dc <slob_free>
	return 0;
c0106c63:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106c68:	c9                   	leave  
c0106c69:	c3                   	ret    

c0106c6a <kmalloc>:

void *
kmalloc(size_t size)
{
c0106c6a:	f3 0f 1e fb          	endbr32 
c0106c6e:	55                   	push   %ebp
c0106c6f:	89 e5                	mov    %esp,%ebp
c0106c71:	83 ec 18             	sub    $0x18,%esp
  return __kmalloc(size, 0);
c0106c74:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0106c7b:	00 
c0106c7c:	8b 45 08             	mov    0x8(%ebp),%eax
c0106c7f:	89 04 24             	mov    %eax,(%esp)
c0106c82:	e8 ed fe ff ff       	call   c0106b74 <__kmalloc>
}
c0106c87:	c9                   	leave  
c0106c88:	c3                   	ret    

c0106c89 <kfree>:


void kfree(void *block)
{
c0106c89:	f3 0f 1e fb          	endbr32 
c0106c8d:	55                   	push   %ebp
c0106c8e:	89 e5                	mov    %esp,%ebp
c0106c90:	83 ec 28             	sub    $0x28,%esp
	bigblock_t *bb, **last = &bigblocks;
c0106c93:	c7 45 f0 1c c0 12 c0 	movl   $0xc012c01c,-0x10(%ebp)
	unsigned long flags;

	if (!block)
c0106c9a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0106c9e:	0f 84 a3 00 00 00    	je     c0106d47 <kfree+0xbe>
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
c0106ca4:	8b 45 08             	mov    0x8(%ebp),%eax
c0106ca7:	25 ff 0f 00 00       	and    $0xfff,%eax
c0106cac:	85 c0                	test   %eax,%eax
c0106cae:	75 7f                	jne    c0106d2f <kfree+0xa6>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
c0106cb0:	e8 95 f9 ff ff       	call   c010664a <__intr_save>
c0106cb5:	89 45 ec             	mov    %eax,-0x14(%ebp)
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
c0106cb8:	a1 1c c0 12 c0       	mov    0xc012c01c,%eax
c0106cbd:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106cc0:	eb 5c                	jmp    c0106d1e <kfree+0x95>
			if (bb->pages == block) {
c0106cc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106cc5:	8b 40 04             	mov    0x4(%eax),%eax
c0106cc8:	39 45 08             	cmp    %eax,0x8(%ebp)
c0106ccb:	75 3f                	jne    c0106d0c <kfree+0x83>
				*last = bb->next;
c0106ccd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106cd0:	8b 50 08             	mov    0x8(%eax),%edx
c0106cd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106cd6:	89 10                	mov    %edx,(%eax)
				spin_unlock_irqrestore(&block_lock, flags);
c0106cd8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106cdb:	89 04 24             	mov    %eax,(%esp)
c0106cde:	e8 91 f9 ff ff       	call   c0106674 <__intr_restore>
				__slob_free_pages((unsigned long)block, bb->order);
c0106ce3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106ce6:	8b 10                	mov    (%eax),%edx
c0106ce8:	8b 45 08             	mov    0x8(%ebp),%eax
c0106ceb:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106cef:	89 04 24             	mov    %eax,(%esp)
c0106cf2:	e8 db fa ff ff       	call   c01067d2 <__slob_free_pages>
				slob_free(bb, sizeof(bigblock_t));
c0106cf7:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
c0106cfe:	00 
c0106cff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106d02:	89 04 24             	mov    %eax,(%esp)
c0106d05:	e8 d2 fc ff ff       	call   c01069dc <slob_free>
				return;
c0106d0a:	eb 3c                	jmp    c0106d48 <kfree+0xbf>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
c0106d0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106d0f:	83 c0 08             	add    $0x8,%eax
c0106d12:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106d15:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106d18:	8b 40 08             	mov    0x8(%eax),%eax
c0106d1b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106d1e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106d22:	75 9e                	jne    c0106cc2 <kfree+0x39>
			}
		}
		spin_unlock_irqrestore(&block_lock, flags);
c0106d24:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106d27:	89 04 24             	mov    %eax,(%esp)
c0106d2a:	e8 45 f9 ff ff       	call   c0106674 <__intr_restore>
	}

	slob_free((slob_t *)block - 1, 0);
c0106d2f:	8b 45 08             	mov    0x8(%ebp),%eax
c0106d32:	83 e8 08             	sub    $0x8,%eax
c0106d35:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0106d3c:	00 
c0106d3d:	89 04 24             	mov    %eax,(%esp)
c0106d40:	e8 97 fc ff ff       	call   c01069dc <slob_free>
	return;
c0106d45:	eb 01                	jmp    c0106d48 <kfree+0xbf>
		return;
c0106d47:	90                   	nop
}
c0106d48:	c9                   	leave  
c0106d49:	c3                   	ret    

c0106d4a <ksize>:


unsigned int ksize(const void *block)
{
c0106d4a:	f3 0f 1e fb          	endbr32 
c0106d4e:	55                   	push   %ebp
c0106d4f:	89 e5                	mov    %esp,%ebp
c0106d51:	83 ec 28             	sub    $0x28,%esp
	bigblock_t *bb;
	unsigned long flags;

	if (!block)
c0106d54:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0106d58:	75 07                	jne    c0106d61 <ksize+0x17>
		return 0;
c0106d5a:	b8 00 00 00 00       	mov    $0x0,%eax
c0106d5f:	eb 6b                	jmp    c0106dcc <ksize+0x82>

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
c0106d61:	8b 45 08             	mov    0x8(%ebp),%eax
c0106d64:	25 ff 0f 00 00       	and    $0xfff,%eax
c0106d69:	85 c0                	test   %eax,%eax
c0106d6b:	75 54                	jne    c0106dc1 <ksize+0x77>
		spin_lock_irqsave(&block_lock, flags);
c0106d6d:	e8 d8 f8 ff ff       	call   c010664a <__intr_save>
c0106d72:	89 45 f0             	mov    %eax,-0x10(%ebp)
		for (bb = bigblocks; bb; bb = bb->next)
c0106d75:	a1 1c c0 12 c0       	mov    0xc012c01c,%eax
c0106d7a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106d7d:	eb 31                	jmp    c0106db0 <ksize+0x66>
			if (bb->pages == block) {
c0106d7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106d82:	8b 40 04             	mov    0x4(%eax),%eax
c0106d85:	39 45 08             	cmp    %eax,0x8(%ebp)
c0106d88:	75 1d                	jne    c0106da7 <ksize+0x5d>
				spin_unlock_irqrestore(&slob_lock, flags);
c0106d8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106d8d:	89 04 24             	mov    %eax,(%esp)
c0106d90:	e8 df f8 ff ff       	call   c0106674 <__intr_restore>
				return PAGE_SIZE << bb->order;
c0106d95:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106d98:	8b 00                	mov    (%eax),%eax
c0106d9a:	ba 00 10 00 00       	mov    $0x1000,%edx
c0106d9f:	88 c1                	mov    %al,%cl
c0106da1:	d3 e2                	shl    %cl,%edx
c0106da3:	89 d0                	mov    %edx,%eax
c0106da5:	eb 25                	jmp    c0106dcc <ksize+0x82>
		for (bb = bigblocks; bb; bb = bb->next)
c0106da7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106daa:	8b 40 08             	mov    0x8(%eax),%eax
c0106dad:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106db0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106db4:	75 c9                	jne    c0106d7f <ksize+0x35>
			}
		spin_unlock_irqrestore(&block_lock, flags);
c0106db6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106db9:	89 04 24             	mov    %eax,(%esp)
c0106dbc:	e8 b3 f8 ff ff       	call   c0106674 <__intr_restore>
	}

	return ((slob_t *)block - 1)->units * SLOB_UNIT;
c0106dc1:	8b 45 08             	mov    0x8(%ebp),%eax
c0106dc4:	83 e8 08             	sub    $0x8,%eax
c0106dc7:	8b 00                	mov    (%eax),%eax
c0106dc9:	c1 e0 03             	shl    $0x3,%eax
}
c0106dcc:	c9                   	leave  
c0106dcd:	c3                   	ret    

c0106dce <_fifo_init_mm>:
 * (2) _fifo_init_mm: init pra_list_head and let  mm->sm_priv point to the addr of pra_list_head.
 *              Now, From the memory control struct mm_struct, we can access FIFO PRA
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{
c0106dce:	f3 0f 1e fb          	endbr32 
c0106dd2:	55                   	push   %ebp
c0106dd3:	89 e5                	mov    %esp,%ebp
c0106dd5:	83 ec 10             	sub    $0x10,%esp
c0106dd8:	c7 45 fc 44 e1 12 c0 	movl   $0xc012e144,-0x4(%ebp)
    elm->prev = elm->next = elm;
c0106ddf:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106de2:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0106de5:	89 50 04             	mov    %edx,0x4(%eax)
c0106de8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106deb:	8b 50 04             	mov    0x4(%eax),%edx
c0106dee:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106df1:	89 10                	mov    %edx,(%eax)
}
c0106df3:	90                   	nop
    list_init(&pra_list_head);
    mm->sm_priv = &pra_list_head;
c0106df4:	8b 45 08             	mov    0x8(%ebp),%eax
c0106df7:	c7 40 14 44 e1 12 c0 	movl   $0xc012e144,0x14(%eax)
    //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
    return 0;
c0106dfe:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106e03:	c9                   	leave  
c0106e04:	c3                   	ret    

c0106e05 <_fifo_map_swappable>:
/*
 * (3)_fifo_map_swappable: According FIFO PRA, we should link the most recent arrival page at the back of pra_list_head qeueue
 */
static int
_fifo_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c0106e05:	f3 0f 1e fb          	endbr32 
c0106e09:	55                   	push   %ebp
c0106e0a:	89 e5                	mov    %esp,%ebp
c0106e0c:	83 ec 48             	sub    $0x48,%esp
    list_entry_t *head = (list_entry_t *)mm->sm_priv;
c0106e0f:	8b 45 08             	mov    0x8(%ebp),%eax
c0106e12:	8b 40 14             	mov    0x14(%eax),%eax
c0106e15:	89 45 f4             	mov    %eax,-0xc(%ebp)
    list_entry_t *entry = &(page->pra_page_link);
c0106e18:	8b 45 10             	mov    0x10(%ebp),%eax
c0106e1b:	83 c0 14             	add    $0x14,%eax
c0106e1e:	89 45 f0             	mov    %eax,-0x10(%ebp)

    assert(entry != NULL && head != NULL);
c0106e21:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0106e25:	74 06                	je     c0106e2d <_fifo_map_swappable+0x28>
c0106e27:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106e2b:	75 24                	jne    c0106e51 <_fifo_map_swappable+0x4c>
c0106e2d:	c7 44 24 0c 4c b9 10 	movl   $0xc010b94c,0xc(%esp)
c0106e34:	c0 
c0106e35:	c7 44 24 08 6a b9 10 	movl   $0xc010b96a,0x8(%esp)
c0106e3c:	c0 
c0106e3d:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
c0106e44:	00 
c0106e45:	c7 04 24 7f b9 10 c0 	movl   $0xc010b97f,(%esp)
c0106e4c:	e8 ec 95 ff ff       	call   c010043d <__panic>
c0106e51:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106e54:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106e57:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106e5a:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106e5d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106e60:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106e63:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106e66:	89 45 e0             	mov    %eax,-0x20(%ebp)
    __list_add(elm, listelm, listelm->next);
c0106e69:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106e6c:	8b 40 04             	mov    0x4(%eax),%eax
c0106e6f:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106e72:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0106e75:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106e78:	89 55 d8             	mov    %edx,-0x28(%ebp)
c0106e7b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    prev->next = next->prev = elm;
c0106e7e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0106e81:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106e84:	89 10                	mov    %edx,(%eax)
c0106e86:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0106e89:	8b 10                	mov    (%eax),%edx
c0106e8b:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0106e8e:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0106e91:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106e94:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106e97:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0106e9a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106e9d:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0106ea0:	89 10                	mov    %edx,(%eax)
}
c0106ea2:	90                   	nop
}
c0106ea3:	90                   	nop
}
c0106ea4:	90                   	nop
    //record the page access situlation
    /*LAB3 EXERCISE 2: YOUR CODE*/
    //(1)link the most recent arrival page at the back of the pra_list_head qeueue.
    list_add(head, entry);
    return 0;
c0106ea5:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106eaa:	c9                   	leave  
c0106eab:	c3                   	ret    

c0106eac <_fifo_swap_out_victim>:
 *  (4)_fifo_swap_out_victim: According FIFO PRA, we should unlink the  earliest arrival page in front of pra_list_head qeueue,
 *                            then assign the value of *ptr_page to the addr of this page.
 */
static int
_fifo_swap_out_victim(struct mm_struct *mm, struct Page **ptr_page, int in_tick)
{
c0106eac:	f3 0f 1e fb          	endbr32 
c0106eb0:	55                   	push   %ebp
c0106eb1:	89 e5                	mov    %esp,%ebp
c0106eb3:	83 ec 38             	sub    $0x38,%esp
    list_entry_t *head = (list_entry_t *)mm->sm_priv;
c0106eb6:	8b 45 08             	mov    0x8(%ebp),%eax
c0106eb9:	8b 40 14             	mov    0x14(%eax),%eax
c0106ebc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(head != NULL);
c0106ebf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106ec3:	75 24                	jne    c0106ee9 <_fifo_swap_out_victim+0x3d>
c0106ec5:	c7 44 24 0c 93 b9 10 	movl   $0xc010b993,0xc(%esp)
c0106ecc:	c0 
c0106ecd:	c7 44 24 08 6a b9 10 	movl   $0xc010b96a,0x8(%esp)
c0106ed4:	c0 
c0106ed5:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
c0106edc:	00 
c0106edd:	c7 04 24 7f b9 10 c0 	movl   $0xc010b97f,(%esp)
c0106ee4:	e8 54 95 ff ff       	call   c010043d <__panic>
    assert(in_tick == 0);
c0106ee9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106eed:	74 24                	je     c0106f13 <_fifo_swap_out_victim+0x67>
c0106eef:	c7 44 24 0c a0 b9 10 	movl   $0xc010b9a0,0xc(%esp)
c0106ef6:	c0 
c0106ef7:	c7 44 24 08 6a b9 10 	movl   $0xc010b96a,0x8(%esp)
c0106efe:	c0 
c0106eff:	c7 44 24 04 42 00 00 	movl   $0x42,0x4(%esp)
c0106f06:	00 
c0106f07:	c7 04 24 7f b9 10 c0 	movl   $0xc010b97f,(%esp)
c0106f0e:	e8 2a 95 ff ff       	call   c010043d <__panic>
    /* Select the victim */
    /*LAB3 EXERCISE 2: YOUR CODE*/
    //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
    //(2)  assign the value of *ptr_page to the addr of this page
    /* Select the tail */
    list_entry_t *le = head->prev;
c0106f13:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106f16:	8b 00                	mov    (%eax),%eax
c0106f18:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(head != le);
c0106f1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106f1e:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0106f21:	75 24                	jne    c0106f47 <_fifo_swap_out_victim+0x9b>
c0106f23:	c7 44 24 0c ad b9 10 	movl   $0xc010b9ad,0xc(%esp)
c0106f2a:	c0 
c0106f2b:	c7 44 24 08 6a b9 10 	movl   $0xc010b96a,0x8(%esp)
c0106f32:	c0 
c0106f33:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
c0106f3a:	00 
c0106f3b:	c7 04 24 7f b9 10 c0 	movl   $0xc010b97f,(%esp)
c0106f42:	e8 f6 94 ff ff       	call   c010043d <__panic>
    struct Page *p = le2page(le, pra_page_link);
c0106f47:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106f4a:	83 e8 14             	sub    $0x14,%eax
c0106f4d:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106f50:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106f53:	89 45 e8             	mov    %eax,-0x18(%ebp)
    __list_del(listelm->prev, listelm->next);
c0106f56:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106f59:	8b 40 04             	mov    0x4(%eax),%eax
c0106f5c:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0106f5f:	8b 12                	mov    (%edx),%edx
c0106f61:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0106f64:	89 45 e0             	mov    %eax,-0x20(%ebp)
    prev->next = next;
c0106f67:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106f6a:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106f6d:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0106f70:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106f73:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106f76:	89 10                	mov    %edx,(%eax)
}
c0106f78:	90                   	nop
}
c0106f79:	90                   	nop
    list_del(le);
    assert(p != NULL);
c0106f7a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0106f7e:	75 24                	jne    c0106fa4 <_fifo_swap_out_victim+0xf8>
c0106f80:	c7 44 24 0c b8 b9 10 	movl   $0xc010b9b8,0xc(%esp)
c0106f87:	c0 
c0106f88:	c7 44 24 08 6a b9 10 	movl   $0xc010b96a,0x8(%esp)
c0106f8f:	c0 
c0106f90:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
c0106f97:	00 
c0106f98:	c7 04 24 7f b9 10 c0 	movl   $0xc010b97f,(%esp)
c0106f9f:	e8 99 94 ff ff       	call   c010043d <__panic>
    *ptr_page = p;
c0106fa4:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106fa7:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106faa:	89 10                	mov    %edx,(%eax)
    return 0;
c0106fac:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106fb1:	c9                   	leave  
c0106fb2:	c3                   	ret    

c0106fb3 <_fifo_check_swap>:

static int
_fifo_check_swap(void)
{
c0106fb3:	f3 0f 1e fb          	endbr32 
c0106fb7:	55                   	push   %ebp
c0106fb8:	89 e5                	mov    %esp,%ebp
c0106fba:	83 ec 18             	sub    $0x18,%esp
    cprintf("write Virt Page c in fifo_check_swap\n");
c0106fbd:	c7 04 24 c4 b9 10 c0 	movl   $0xc010b9c4,(%esp)
c0106fc4:	e8 08 93 ff ff       	call   c01002d1 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c0106fc9:	b8 00 30 00 00       	mov    $0x3000,%eax
c0106fce:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num == 4);
c0106fd1:	a1 0c c0 12 c0       	mov    0xc012c00c,%eax
c0106fd6:	83 f8 04             	cmp    $0x4,%eax
c0106fd9:	74 24                	je     c0106fff <_fifo_check_swap+0x4c>
c0106fdb:	c7 44 24 0c ea b9 10 	movl   $0xc010b9ea,0xc(%esp)
c0106fe2:	c0 
c0106fe3:	c7 44 24 08 6a b9 10 	movl   $0xc010b96a,0x8(%esp)
c0106fea:	c0 
c0106feb:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
c0106ff2:	00 
c0106ff3:	c7 04 24 7f b9 10 c0 	movl   $0xc010b97f,(%esp)
c0106ffa:	e8 3e 94 ff ff       	call   c010043d <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0106fff:	c7 04 24 fc b9 10 c0 	movl   $0xc010b9fc,(%esp)
c0107006:	e8 c6 92 ff ff       	call   c01002d1 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c010700b:	b8 00 10 00 00       	mov    $0x1000,%eax
c0107010:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num == 4);
c0107013:	a1 0c c0 12 c0       	mov    0xc012c00c,%eax
c0107018:	83 f8 04             	cmp    $0x4,%eax
c010701b:	74 24                	je     c0107041 <_fifo_check_swap+0x8e>
c010701d:	c7 44 24 0c ea b9 10 	movl   $0xc010b9ea,0xc(%esp)
c0107024:	c0 
c0107025:	c7 44 24 08 6a b9 10 	movl   $0xc010b96a,0x8(%esp)
c010702c:	c0 
c010702d:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
c0107034:	00 
c0107035:	c7 04 24 7f b9 10 c0 	movl   $0xc010b97f,(%esp)
c010703c:	e8 fc 93 ff ff       	call   c010043d <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c0107041:	c7 04 24 24 ba 10 c0 	movl   $0xc010ba24,(%esp)
c0107048:	e8 84 92 ff ff       	call   c01002d1 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c010704d:	b8 00 40 00 00       	mov    $0x4000,%eax
c0107052:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num == 4);
c0107055:	a1 0c c0 12 c0       	mov    0xc012c00c,%eax
c010705a:	83 f8 04             	cmp    $0x4,%eax
c010705d:	74 24                	je     c0107083 <_fifo_check_swap+0xd0>
c010705f:	c7 44 24 0c ea b9 10 	movl   $0xc010b9ea,0xc(%esp)
c0107066:	c0 
c0107067:	c7 44 24 08 6a b9 10 	movl   $0xc010b96a,0x8(%esp)
c010706e:	c0 
c010706f:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
c0107076:	00 
c0107077:	c7 04 24 7f b9 10 c0 	movl   $0xc010b97f,(%esp)
c010707e:	e8 ba 93 ff ff       	call   c010043d <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0107083:	c7 04 24 4c ba 10 c0 	movl   $0xc010ba4c,(%esp)
c010708a:	e8 42 92 ff ff       	call   c01002d1 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c010708f:	b8 00 20 00 00       	mov    $0x2000,%eax
c0107094:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num == 4);
c0107097:	a1 0c c0 12 c0       	mov    0xc012c00c,%eax
c010709c:	83 f8 04             	cmp    $0x4,%eax
c010709f:	74 24                	je     c01070c5 <_fifo_check_swap+0x112>
c01070a1:	c7 44 24 0c ea b9 10 	movl   $0xc010b9ea,0xc(%esp)
c01070a8:	c0 
c01070a9:	c7 44 24 08 6a b9 10 	movl   $0xc010b96a,0x8(%esp)
c01070b0:	c0 
c01070b1:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
c01070b8:	00 
c01070b9:	c7 04 24 7f b9 10 c0 	movl   $0xc010b97f,(%esp)
c01070c0:	e8 78 93 ff ff       	call   c010043d <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c01070c5:	c7 04 24 74 ba 10 c0 	movl   $0xc010ba74,(%esp)
c01070cc:	e8 00 92 ff ff       	call   c01002d1 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c01070d1:	b8 00 50 00 00       	mov    $0x5000,%eax
c01070d6:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num == 5);
c01070d9:	a1 0c c0 12 c0       	mov    0xc012c00c,%eax
c01070de:	83 f8 05             	cmp    $0x5,%eax
c01070e1:	74 24                	je     c0107107 <_fifo_check_swap+0x154>
c01070e3:	c7 44 24 0c 9a ba 10 	movl   $0xc010ba9a,0xc(%esp)
c01070ea:	c0 
c01070eb:	c7 44 24 08 6a b9 10 	movl   $0xc010b96a,0x8(%esp)
c01070f2:	c0 
c01070f3:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
c01070fa:	00 
c01070fb:	c7 04 24 7f b9 10 c0 	movl   $0xc010b97f,(%esp)
c0107102:	e8 36 93 ff ff       	call   c010043d <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0107107:	c7 04 24 4c ba 10 c0 	movl   $0xc010ba4c,(%esp)
c010710e:	e8 be 91 ff ff       	call   c01002d1 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0107113:	b8 00 20 00 00       	mov    $0x2000,%eax
c0107118:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num == 5);
c010711b:	a1 0c c0 12 c0       	mov    0xc012c00c,%eax
c0107120:	83 f8 05             	cmp    $0x5,%eax
c0107123:	74 24                	je     c0107149 <_fifo_check_swap+0x196>
c0107125:	c7 44 24 0c 9a ba 10 	movl   $0xc010ba9a,0xc(%esp)
c010712c:	c0 
c010712d:	c7 44 24 08 6a b9 10 	movl   $0xc010b96a,0x8(%esp)
c0107134:	c0 
c0107135:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c010713c:	00 
c010713d:	c7 04 24 7f b9 10 c0 	movl   $0xc010b97f,(%esp)
c0107144:	e8 f4 92 ff ff       	call   c010043d <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0107149:	c7 04 24 fc b9 10 c0 	movl   $0xc010b9fc,(%esp)
c0107150:	e8 7c 91 ff ff       	call   c01002d1 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c0107155:	b8 00 10 00 00       	mov    $0x1000,%eax
c010715a:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num == 6);
c010715d:	a1 0c c0 12 c0       	mov    0xc012c00c,%eax
c0107162:	83 f8 06             	cmp    $0x6,%eax
c0107165:	74 24                	je     c010718b <_fifo_check_swap+0x1d8>
c0107167:	c7 44 24 0c ab ba 10 	movl   $0xc010baab,0xc(%esp)
c010716e:	c0 
c010716f:	c7 44 24 08 6a b9 10 	movl   $0xc010b96a,0x8(%esp)
c0107176:	c0 
c0107177:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
c010717e:	00 
c010717f:	c7 04 24 7f b9 10 c0 	movl   $0xc010b97f,(%esp)
c0107186:	e8 b2 92 ff ff       	call   c010043d <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c010718b:	c7 04 24 4c ba 10 c0 	movl   $0xc010ba4c,(%esp)
c0107192:	e8 3a 91 ff ff       	call   c01002d1 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0107197:	b8 00 20 00 00       	mov    $0x2000,%eax
c010719c:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num == 7);
c010719f:	a1 0c c0 12 c0       	mov    0xc012c00c,%eax
c01071a4:	83 f8 07             	cmp    $0x7,%eax
c01071a7:	74 24                	je     c01071cd <_fifo_check_swap+0x21a>
c01071a9:	c7 44 24 0c bc ba 10 	movl   $0xc010babc,0xc(%esp)
c01071b0:	c0 
c01071b1:	c7 44 24 08 6a b9 10 	movl   $0xc010b96a,0x8(%esp)
c01071b8:	c0 
c01071b9:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
c01071c0:	00 
c01071c1:	c7 04 24 7f b9 10 c0 	movl   $0xc010b97f,(%esp)
c01071c8:	e8 70 92 ff ff       	call   c010043d <__panic>
    cprintf("write Virt Page c in fifo_check_swap\n");
c01071cd:	c7 04 24 c4 b9 10 c0 	movl   $0xc010b9c4,(%esp)
c01071d4:	e8 f8 90 ff ff       	call   c01002d1 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c01071d9:	b8 00 30 00 00       	mov    $0x3000,%eax
c01071de:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num == 8);
c01071e1:	a1 0c c0 12 c0       	mov    0xc012c00c,%eax
c01071e6:	83 f8 08             	cmp    $0x8,%eax
c01071e9:	74 24                	je     c010720f <_fifo_check_swap+0x25c>
c01071eb:	c7 44 24 0c cd ba 10 	movl   $0xc010bacd,0xc(%esp)
c01071f2:	c0 
c01071f3:	c7 44 24 08 6a b9 10 	movl   $0xc010b96a,0x8(%esp)
c01071fa:	c0 
c01071fb:	c7 44 24 04 6e 00 00 	movl   $0x6e,0x4(%esp)
c0107202:	00 
c0107203:	c7 04 24 7f b9 10 c0 	movl   $0xc010b97f,(%esp)
c010720a:	e8 2e 92 ff ff       	call   c010043d <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c010720f:	c7 04 24 24 ba 10 c0 	movl   $0xc010ba24,(%esp)
c0107216:	e8 b6 90 ff ff       	call   c01002d1 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c010721b:	b8 00 40 00 00       	mov    $0x4000,%eax
c0107220:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num == 9);
c0107223:	a1 0c c0 12 c0       	mov    0xc012c00c,%eax
c0107228:	83 f8 09             	cmp    $0x9,%eax
c010722b:	74 24                	je     c0107251 <_fifo_check_swap+0x29e>
c010722d:	c7 44 24 0c de ba 10 	movl   $0xc010bade,0xc(%esp)
c0107234:	c0 
c0107235:	c7 44 24 08 6a b9 10 	movl   $0xc010b96a,0x8(%esp)
c010723c:	c0 
c010723d:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
c0107244:	00 
c0107245:	c7 04 24 7f b9 10 c0 	movl   $0xc010b97f,(%esp)
c010724c:	e8 ec 91 ff ff       	call   c010043d <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c0107251:	c7 04 24 74 ba 10 c0 	movl   $0xc010ba74,(%esp)
c0107258:	e8 74 90 ff ff       	call   c01002d1 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c010725d:	b8 00 50 00 00       	mov    $0x5000,%eax
c0107262:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num == 10);
c0107265:	a1 0c c0 12 c0       	mov    0xc012c00c,%eax
c010726a:	83 f8 0a             	cmp    $0xa,%eax
c010726d:	74 24                	je     c0107293 <_fifo_check_swap+0x2e0>
c010726f:	c7 44 24 0c ef ba 10 	movl   $0xc010baef,0xc(%esp)
c0107276:	c0 
c0107277:	c7 44 24 08 6a b9 10 	movl   $0xc010b96a,0x8(%esp)
c010727e:	c0 
c010727f:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
c0107286:	00 
c0107287:	c7 04 24 7f b9 10 c0 	movl   $0xc010b97f,(%esp)
c010728e:	e8 aa 91 ff ff       	call   c010043d <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0107293:	c7 04 24 fc b9 10 c0 	movl   $0xc010b9fc,(%esp)
c010729a:	e8 32 90 ff ff       	call   c01002d1 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
c010729f:	b8 00 10 00 00       	mov    $0x1000,%eax
c01072a4:	0f b6 00             	movzbl (%eax),%eax
c01072a7:	3c 0a                	cmp    $0xa,%al
c01072a9:	74 24                	je     c01072cf <_fifo_check_swap+0x31c>
c01072ab:	c7 44 24 0c 04 bb 10 	movl   $0xc010bb04,0xc(%esp)
c01072b2:	c0 
c01072b3:	c7 44 24 08 6a b9 10 	movl   $0xc010b96a,0x8(%esp)
c01072ba:	c0 
c01072bb:	c7 44 24 04 76 00 00 	movl   $0x76,0x4(%esp)
c01072c2:	00 
c01072c3:	c7 04 24 7f b9 10 c0 	movl   $0xc010b97f,(%esp)
c01072ca:	e8 6e 91 ff ff       	call   c010043d <__panic>
    *(unsigned char *)0x1000 = 0x0a;
c01072cf:	b8 00 10 00 00       	mov    $0x1000,%eax
c01072d4:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num == 11);
c01072d7:	a1 0c c0 12 c0       	mov    0xc012c00c,%eax
c01072dc:	83 f8 0b             	cmp    $0xb,%eax
c01072df:	74 24                	je     c0107305 <_fifo_check_swap+0x352>
c01072e1:	c7 44 24 0c 25 bb 10 	movl   $0xc010bb25,0xc(%esp)
c01072e8:	c0 
c01072e9:	c7 44 24 08 6a b9 10 	movl   $0xc010b96a,0x8(%esp)
c01072f0:	c0 
c01072f1:	c7 44 24 04 78 00 00 	movl   $0x78,0x4(%esp)
c01072f8:	00 
c01072f9:	c7 04 24 7f b9 10 c0 	movl   $0xc010b97f,(%esp)
c0107300:	e8 38 91 ff ff       	call   c010043d <__panic>
    return 0;
c0107305:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010730a:	c9                   	leave  
c010730b:	c3                   	ret    

c010730c <_fifo_init>:

static int
_fifo_init(void)
{
c010730c:	f3 0f 1e fb          	endbr32 
c0107310:	55                   	push   %ebp
c0107311:	89 e5                	mov    %esp,%ebp
    return 0;
c0107313:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107318:	5d                   	pop    %ebp
c0107319:	c3                   	ret    

c010731a <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c010731a:	f3 0f 1e fb          	endbr32 
c010731e:	55                   	push   %ebp
c010731f:	89 e5                	mov    %esp,%ebp
    return 0;
c0107321:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107326:	5d                   	pop    %ebp
c0107327:	c3                   	ret    

c0107328 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{
c0107328:	f3 0f 1e fb          	endbr32 
c010732c:	55                   	push   %ebp
c010732d:	89 e5                	mov    %esp,%ebp
    return 0;
c010732f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107334:	5d                   	pop    %ebp
c0107335:	c3                   	ret    

c0107336 <page2ppn>:
page2ppn(struct Page *page) {
c0107336:	55                   	push   %ebp
c0107337:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0107339:	a1 60 e0 12 c0       	mov    0xc012e060,%eax
c010733e:	8b 55 08             	mov    0x8(%ebp),%edx
c0107341:	29 c2                	sub    %eax,%edx
c0107343:	89 d0                	mov    %edx,%eax
c0107345:	c1 f8 05             	sar    $0x5,%eax
}
c0107348:	5d                   	pop    %ebp
c0107349:	c3                   	ret    

c010734a <page2pa>:
page2pa(struct Page *page) {
c010734a:	55                   	push   %ebp
c010734b:	89 e5                	mov    %esp,%ebp
c010734d:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0107350:	8b 45 08             	mov    0x8(%ebp),%eax
c0107353:	89 04 24             	mov    %eax,(%esp)
c0107356:	e8 db ff ff ff       	call   c0107336 <page2ppn>
c010735b:	c1 e0 0c             	shl    $0xc,%eax
}
c010735e:	c9                   	leave  
c010735f:	c3                   	ret    

c0107360 <page_ref>:
page_ref(struct Page *page) {
c0107360:	55                   	push   %ebp
c0107361:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0107363:	8b 45 08             	mov    0x8(%ebp),%eax
c0107366:	8b 00                	mov    (%eax),%eax
}
c0107368:	5d                   	pop    %ebp
c0107369:	c3                   	ret    

c010736a <set_page_ref>:
set_page_ref(struct Page *page, int val) {
c010736a:	55                   	push   %ebp
c010736b:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c010736d:	8b 45 08             	mov    0x8(%ebp),%eax
c0107370:	8b 55 0c             	mov    0xc(%ebp),%edx
c0107373:	89 10                	mov    %edx,(%eax)
}
c0107375:	90                   	nop
c0107376:	5d                   	pop    %ebp
c0107377:	c3                   	ret    

c0107378 <default_init>:
#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void)
{
c0107378:	f3 0f 1e fb          	endbr32 
c010737c:	55                   	push   %ebp
c010737d:	89 e5                	mov    %esp,%ebp
c010737f:	83 ec 10             	sub    $0x10,%esp
c0107382:	c7 45 fc 4c e1 12 c0 	movl   $0xc012e14c,-0x4(%ebp)
    elm->prev = elm->next = elm;
c0107389:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010738c:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010738f:	89 50 04             	mov    %edx,0x4(%eax)
c0107392:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107395:	8b 50 04             	mov    0x4(%eax),%edx
c0107398:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010739b:	89 10                	mov    %edx,(%eax)
}
c010739d:	90                   	nop
    list_init(&free_list);
    nr_free = 0;
c010739e:	c7 05 54 e1 12 c0 00 	movl   $0x0,0xc012e154
c01073a5:	00 00 00 
}
c01073a8:	90                   	nop
c01073a9:	c9                   	leave  
c01073aa:	c3                   	ret    

c01073ab <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n)
{
c01073ab:	f3 0f 1e fb          	endbr32 
c01073af:	55                   	push   %ebp
c01073b0:	89 e5                	mov    %esp,%ebp
c01073b2:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
c01073b5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01073b9:	75 24                	jne    c01073df <default_init_memmap+0x34>
c01073bb:	c7 44 24 0c 4c bb 10 	movl   $0xc010bb4c,0xc(%esp)
c01073c2:	c0 
c01073c3:	c7 44 24 08 52 bb 10 	movl   $0xc010bb52,0x8(%esp)
c01073ca:	c0 
c01073cb:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
c01073d2:	00 
c01073d3:	c7 04 24 67 bb 10 c0 	movl   $0xc010bb67,(%esp)
c01073da:	e8 5e 90 ff ff       	call   c010043d <__panic>
    struct Page *p = base;
c01073df:	8b 45 08             	mov    0x8(%ebp),%eax
c01073e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p++)
c01073e5:	eb 7d                	jmp    c0107464 <default_init_memmap+0xb9>
    {
        assert(PageReserved(p));
c01073e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01073ea:	83 c0 04             	add    $0x4,%eax
c01073ed:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c01073f4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01073f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01073fa:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01073fd:	0f a3 10             	bt     %edx,(%eax)
c0107400:	19 c0                	sbb    %eax,%eax
c0107402:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c0107405:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0107409:	0f 95 c0             	setne  %al
c010740c:	0f b6 c0             	movzbl %al,%eax
c010740f:	85 c0                	test   %eax,%eax
c0107411:	75 24                	jne    c0107437 <default_init_memmap+0x8c>
c0107413:	c7 44 24 0c 7d bb 10 	movl   $0xc010bb7d,0xc(%esp)
c010741a:	c0 
c010741b:	c7 44 24 08 52 bb 10 	movl   $0xc010bb52,0x8(%esp)
c0107422:	c0 
c0107423:	c7 44 24 04 73 00 00 	movl   $0x73,0x4(%esp)
c010742a:	00 
c010742b:	c7 04 24 67 bb 10 c0 	movl   $0xc010bb67,(%esp)
c0107432:	e8 06 90 ff ff       	call   c010043d <__panic>
        p->flags = p->property = 0;
c0107437:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010743a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c0107441:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107444:	8b 50 08             	mov    0x8(%eax),%edx
c0107447:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010744a:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
c010744d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0107454:	00 
c0107455:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107458:	89 04 24             	mov    %eax,(%esp)
c010745b:	e8 0a ff ff ff       	call   c010736a <set_page_ref>
    for (; p != base + n; p++)
c0107460:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c0107464:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107467:	c1 e0 05             	shl    $0x5,%eax
c010746a:	89 c2                	mov    %eax,%edx
c010746c:	8b 45 08             	mov    0x8(%ebp),%eax
c010746f:	01 d0                	add    %edx,%eax
c0107471:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0107474:	0f 85 6d ff ff ff    	jne    c01073e7 <default_init_memmap+0x3c>
    }
    base->property = n;
c010747a:	8b 45 08             	mov    0x8(%ebp),%eax
c010747d:	8b 55 0c             	mov    0xc(%ebp),%edx
c0107480:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0107483:	8b 45 08             	mov    0x8(%ebp),%eax
c0107486:	83 c0 04             	add    $0x4,%eax
c0107489:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0107490:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0107493:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0107496:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0107499:	0f ab 10             	bts    %edx,(%eax)
}
c010749c:	90                   	nop
    nr_free += n;
c010749d:	8b 15 54 e1 12 c0    	mov    0xc012e154,%edx
c01074a3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01074a6:	01 d0                	add    %edx,%eax
c01074a8:	a3 54 e1 12 c0       	mov    %eax,0xc012e154
    list_add_before(&free_list, &(base->page_link));
c01074ad:	8b 45 08             	mov    0x8(%ebp),%eax
c01074b0:	83 c0 0c             	add    $0xc,%eax
c01074b3:	c7 45 e4 4c e1 12 c0 	movl   $0xc012e14c,-0x1c(%ebp)
c01074ba:	89 45 e0             	mov    %eax,-0x20(%ebp)
    __list_add(elm, listelm->prev, listelm);
c01074bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01074c0:	8b 00                	mov    (%eax),%eax
c01074c2:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01074c5:	89 55 dc             	mov    %edx,-0x24(%ebp)
c01074c8:	89 45 d8             	mov    %eax,-0x28(%ebp)
c01074cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01074ce:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    prev->next = next->prev = elm;
c01074d1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01074d4:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01074d7:	89 10                	mov    %edx,(%eax)
c01074d9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01074dc:	8b 10                	mov    (%eax),%edx
c01074de:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01074e1:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01074e4:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01074e7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01074ea:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01074ed:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01074f0:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01074f3:	89 10                	mov    %edx,(%eax)
}
c01074f5:	90                   	nop
}
c01074f6:	90                   	nop
}
c01074f7:	90                   	nop
c01074f8:	c9                   	leave  
c01074f9:	c3                   	ret    

c01074fa <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n)
{
c01074fa:	f3 0f 1e fb          	endbr32 
c01074fe:	55                   	push   %ebp
c01074ff:	89 e5                	mov    %esp,%ebp
c0107501:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c0107504:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0107508:	75 24                	jne    c010752e <default_alloc_pages+0x34>
c010750a:	c7 44 24 0c 4c bb 10 	movl   $0xc010bb4c,0xc(%esp)
c0107511:	c0 
c0107512:	c7 44 24 08 52 bb 10 	movl   $0xc010bb52,0x8(%esp)
c0107519:	c0 
c010751a:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
c0107521:	00 
c0107522:	c7 04 24 67 bb 10 c0 	movl   $0xc010bb67,(%esp)
c0107529:	e8 0f 8f ff ff       	call   c010043d <__panic>
    if (n > nr_free)
c010752e:	a1 54 e1 12 c0       	mov    0xc012e154,%eax
c0107533:	39 45 08             	cmp    %eax,0x8(%ebp)
c0107536:	76 0a                	jbe    c0107542 <default_alloc_pages+0x48>
    {
        return NULL;
c0107538:	b8 00 00 00 00       	mov    $0x0,%eax
c010753d:	e9 3c 01 00 00       	jmp    c010767e <default_alloc_pages+0x184>
    }
    struct Page *page = NULL;
c0107542:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
c0107549:	c7 45 f0 4c e1 12 c0 	movl   $0xc012e14c,-0x10(%ebp)
    // TODO: optimize (next-fit)
    while ((le = list_next(le)) != &free_list)
c0107550:	eb 1c                	jmp    c010756e <default_alloc_pages+0x74>
    {
        struct Page *p = le2page(le, page_link);
c0107552:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107555:	83 e8 0c             	sub    $0xc,%eax
c0107558:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n)
c010755b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010755e:	8b 40 08             	mov    0x8(%eax),%eax
c0107561:	39 45 08             	cmp    %eax,0x8(%ebp)
c0107564:	77 08                	ja     c010756e <default_alloc_pages+0x74>
        {
            page = p;
c0107566:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107569:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
c010756c:	eb 18                	jmp    c0107586 <default_alloc_pages+0x8c>
c010756e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107571:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->next;
c0107574:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107577:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list)
c010757a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010757d:	81 7d f0 4c e1 12 c0 	cmpl   $0xc012e14c,-0x10(%ebp)
c0107584:	75 cc                	jne    c0107552 <default_alloc_pages+0x58>
        }
    }
    if (page != NULL)
c0107586:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010758a:	0f 84 eb 00 00 00    	je     c010767b <default_alloc_pages+0x181>
    {
        if (page->property > n)
c0107590:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107593:	8b 40 08             	mov    0x8(%eax),%eax
c0107596:	39 45 08             	cmp    %eax,0x8(%ebp)
c0107599:	0f 83 88 00 00 00    	jae    c0107627 <default_alloc_pages+0x12d>
        {
            struct Page *p = page + n;
c010759f:	8b 45 08             	mov    0x8(%ebp),%eax
c01075a2:	c1 e0 05             	shl    $0x5,%eax
c01075a5:	89 c2                	mov    %eax,%edx
c01075a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01075aa:	01 d0                	add    %edx,%eax
c01075ac:	89 45 e8             	mov    %eax,-0x18(%ebp)
            p->property = page->property - n;
c01075af:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01075b2:	8b 40 08             	mov    0x8(%eax),%eax
c01075b5:	2b 45 08             	sub    0x8(%ebp),%eax
c01075b8:	89 c2                	mov    %eax,%edx
c01075ba:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01075bd:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(p);
c01075c0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01075c3:	83 c0 04             	add    $0x4,%eax
c01075c6:	c7 45 cc 01 00 00 00 	movl   $0x1,-0x34(%ebp)
c01075cd:	89 45 c8             	mov    %eax,-0x38(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01075d0:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01075d3:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01075d6:	0f ab 10             	bts    %edx,(%eax)
}
c01075d9:	90                   	nop
            list_add_after(&(page->page_link), &(p->page_link));
c01075da:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01075dd:	83 c0 0c             	add    $0xc,%eax
c01075e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01075e3:	83 c2 0c             	add    $0xc,%edx
c01075e6:	89 55 e0             	mov    %edx,-0x20(%ebp)
c01075e9:	89 45 dc             	mov    %eax,-0x24(%ebp)
    __list_add(elm, listelm, listelm->next);
c01075ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01075ef:	8b 40 04             	mov    0x4(%eax),%eax
c01075f2:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01075f5:	89 55 d8             	mov    %edx,-0x28(%ebp)
c01075f8:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01075fb:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01075fe:	89 45 d0             	mov    %eax,-0x30(%ebp)
    prev->next = next->prev = elm;
c0107601:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0107604:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0107607:	89 10                	mov    %edx,(%eax)
c0107609:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010760c:	8b 10                	mov    (%eax),%edx
c010760e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0107611:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0107614:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0107617:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010761a:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010761d:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0107620:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0107623:	89 10                	mov    %edx,(%eax)
}
c0107625:	90                   	nop
}
c0107626:	90                   	nop
        }
        list_del(&(page->page_link));
c0107627:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010762a:	83 c0 0c             	add    $0xc,%eax
c010762d:	89 45 bc             	mov    %eax,-0x44(%ebp)
    __list_del(listelm->prev, listelm->next);
c0107630:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0107633:	8b 40 04             	mov    0x4(%eax),%eax
c0107636:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0107639:	8b 12                	mov    (%edx),%edx
c010763b:	89 55 b8             	mov    %edx,-0x48(%ebp)
c010763e:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    prev->next = next;
c0107641:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0107644:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0107647:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c010764a:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010764d:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0107650:	89 10                	mov    %edx,(%eax)
}
c0107652:	90                   	nop
}
c0107653:	90                   	nop
        nr_free -= n;
c0107654:	a1 54 e1 12 c0       	mov    0xc012e154,%eax
c0107659:	2b 45 08             	sub    0x8(%ebp),%eax
c010765c:	a3 54 e1 12 c0       	mov    %eax,0xc012e154
        ClearPageProperty(page);
c0107661:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107664:	83 c0 04             	add    $0x4,%eax
c0107667:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c010766e:	89 45 c0             	mov    %eax,-0x40(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0107671:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0107674:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0107677:	0f b3 10             	btr    %edx,(%eax)
}
c010767a:	90                   	nop
    }
    return page;
c010767b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010767e:	c9                   	leave  
c010767f:	c3                   	ret    

c0107680 <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n)
{
c0107680:	f3 0f 1e fb          	endbr32 
c0107684:	55                   	push   %ebp
c0107685:	89 e5                	mov    %esp,%ebp
c0107687:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
c010768d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0107691:	75 24                	jne    c01076b7 <default_free_pages+0x37>
c0107693:	c7 44 24 0c 4c bb 10 	movl   $0xc010bb4c,0xc(%esp)
c010769a:	c0 
c010769b:	c7 44 24 08 52 bb 10 	movl   $0xc010bb52,0x8(%esp)
c01076a2:	c0 
c01076a3:	c7 44 24 04 a4 00 00 	movl   $0xa4,0x4(%esp)
c01076aa:	00 
c01076ab:	c7 04 24 67 bb 10 c0 	movl   $0xc010bb67,(%esp)
c01076b2:	e8 86 8d ff ff       	call   c010043d <__panic>
    struct Page *p = base;
c01076b7:	8b 45 08             	mov    0x8(%ebp),%eax
c01076ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p++)
c01076bd:	e9 9d 00 00 00       	jmp    c010775f <default_free_pages+0xdf>
    {
        assert(!PageReserved(p) && !PageProperty(p));
c01076c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01076c5:	83 c0 04             	add    $0x4,%eax
c01076c8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01076cf:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01076d2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01076d5:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01076d8:	0f a3 10             	bt     %edx,(%eax)
c01076db:	19 c0                	sbb    %eax,%eax
c01076dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c01076e0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01076e4:	0f 95 c0             	setne  %al
c01076e7:	0f b6 c0             	movzbl %al,%eax
c01076ea:	85 c0                	test   %eax,%eax
c01076ec:	75 2c                	jne    c010771a <default_free_pages+0x9a>
c01076ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01076f1:	83 c0 04             	add    $0x4,%eax
c01076f4:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c01076fb:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01076fe:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107701:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0107704:	0f a3 10             	bt     %edx,(%eax)
c0107707:	19 c0                	sbb    %eax,%eax
c0107709:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
c010770c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0107710:	0f 95 c0             	setne  %al
c0107713:	0f b6 c0             	movzbl %al,%eax
c0107716:	85 c0                	test   %eax,%eax
c0107718:	74 24                	je     c010773e <default_free_pages+0xbe>
c010771a:	c7 44 24 0c 90 bb 10 	movl   $0xc010bb90,0xc(%esp)
c0107721:	c0 
c0107722:	c7 44 24 08 52 bb 10 	movl   $0xc010bb52,0x8(%esp)
c0107729:	c0 
c010772a:	c7 44 24 04 a8 00 00 	movl   $0xa8,0x4(%esp)
c0107731:	00 
c0107732:	c7 04 24 67 bb 10 c0 	movl   $0xc010bb67,(%esp)
c0107739:	e8 ff 8c ff ff       	call   c010043d <__panic>
        p->flags = 0;
c010773e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107741:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c0107748:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010774f:	00 
c0107750:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107753:	89 04 24             	mov    %eax,(%esp)
c0107756:	e8 0f fc ff ff       	call   c010736a <set_page_ref>
    for (; p != base + n; p++)
c010775b:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c010775f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107762:	c1 e0 05             	shl    $0x5,%eax
c0107765:	89 c2                	mov    %eax,%edx
c0107767:	8b 45 08             	mov    0x8(%ebp),%eax
c010776a:	01 d0                	add    %edx,%eax
c010776c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010776f:	0f 85 4d ff ff ff    	jne    c01076c2 <default_free_pages+0x42>
    }
    base->property = n;
c0107775:	8b 45 08             	mov    0x8(%ebp),%eax
c0107778:	8b 55 0c             	mov    0xc(%ebp),%edx
c010777b:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c010777e:	8b 45 08             	mov    0x8(%ebp),%eax
c0107781:	83 c0 04             	add    $0x4,%eax
c0107784:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c010778b:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010778e:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0107791:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0107794:	0f ab 10             	bts    %edx,(%eax)
}
c0107797:	90                   	nop
c0107798:	c7 45 d4 4c e1 12 c0 	movl   $0xc012e14c,-0x2c(%ebp)
    return listelm->next;
c010779f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01077a2:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
c01077a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list)
c01077a8:	e9 00 01 00 00       	jmp    c01078ad <default_free_pages+0x22d>
    {
        p = le2page(le, page_link);
c01077ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01077b0:	83 e8 0c             	sub    $0xc,%eax
c01077b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01077b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01077b9:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01077bc:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01077bf:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c01077c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
        // TODO: optimize
        if (base + base->property == p)
c01077c5:	8b 45 08             	mov    0x8(%ebp),%eax
c01077c8:	8b 40 08             	mov    0x8(%eax),%eax
c01077cb:	c1 e0 05             	shl    $0x5,%eax
c01077ce:	89 c2                	mov    %eax,%edx
c01077d0:	8b 45 08             	mov    0x8(%ebp),%eax
c01077d3:	01 d0                	add    %edx,%eax
c01077d5:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01077d8:	75 5d                	jne    c0107837 <default_free_pages+0x1b7>
        {
            base->property += p->property;
c01077da:	8b 45 08             	mov    0x8(%ebp),%eax
c01077dd:	8b 50 08             	mov    0x8(%eax),%edx
c01077e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01077e3:	8b 40 08             	mov    0x8(%eax),%eax
c01077e6:	01 c2                	add    %eax,%edx
c01077e8:	8b 45 08             	mov    0x8(%ebp),%eax
c01077eb:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
c01077ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01077f1:	83 c0 04             	add    $0x4,%eax
c01077f4:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
c01077fb:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01077fe:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0107801:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0107804:	0f b3 10             	btr    %edx,(%eax)
}
c0107807:	90                   	nop
            list_del(&(p->page_link));
c0107808:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010780b:	83 c0 0c             	add    $0xc,%eax
c010780e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    __list_del(listelm->prev, listelm->next);
c0107811:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0107814:	8b 40 04             	mov    0x4(%eax),%eax
c0107817:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c010781a:	8b 12                	mov    (%edx),%edx
c010781c:	89 55 c0             	mov    %edx,-0x40(%ebp)
c010781f:	89 45 bc             	mov    %eax,-0x44(%ebp)
    prev->next = next;
c0107822:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0107825:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0107828:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c010782b:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010782e:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0107831:	89 10                	mov    %edx,(%eax)
}
c0107833:	90                   	nop
}
c0107834:	90                   	nop
c0107835:	eb 76                	jmp    c01078ad <default_free_pages+0x22d>
        }
        else if (p + p->property == base)
c0107837:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010783a:	8b 40 08             	mov    0x8(%eax),%eax
c010783d:	c1 e0 05             	shl    $0x5,%eax
c0107840:	89 c2                	mov    %eax,%edx
c0107842:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107845:	01 d0                	add    %edx,%eax
c0107847:	39 45 08             	cmp    %eax,0x8(%ebp)
c010784a:	75 61                	jne    c01078ad <default_free_pages+0x22d>
        {
            p->property += base->property;
c010784c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010784f:	8b 50 08             	mov    0x8(%eax),%edx
c0107852:	8b 45 08             	mov    0x8(%ebp),%eax
c0107855:	8b 40 08             	mov    0x8(%eax),%eax
c0107858:	01 c2                	add    %eax,%edx
c010785a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010785d:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
c0107860:	8b 45 08             	mov    0x8(%ebp),%eax
c0107863:	83 c0 04             	add    $0x4,%eax
c0107866:	c7 45 a4 01 00 00 00 	movl   $0x1,-0x5c(%ebp)
c010786d:	89 45 a0             	mov    %eax,-0x60(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0107870:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0107873:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0107876:	0f b3 10             	btr    %edx,(%eax)
}
c0107879:	90                   	nop
            base = p;
c010787a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010787d:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
c0107880:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107883:	83 c0 0c             	add    $0xc,%eax
c0107886:	89 45 b0             	mov    %eax,-0x50(%ebp)
    __list_del(listelm->prev, listelm->next);
c0107889:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010788c:	8b 40 04             	mov    0x4(%eax),%eax
c010788f:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0107892:	8b 12                	mov    (%edx),%edx
c0107894:	89 55 ac             	mov    %edx,-0x54(%ebp)
c0107897:	89 45 a8             	mov    %eax,-0x58(%ebp)
    prev->next = next;
c010789a:	8b 45 ac             	mov    -0x54(%ebp),%eax
c010789d:	8b 55 a8             	mov    -0x58(%ebp),%edx
c01078a0:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01078a3:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01078a6:	8b 55 ac             	mov    -0x54(%ebp),%edx
c01078a9:	89 10                	mov    %edx,(%eax)
}
c01078ab:	90                   	nop
}
c01078ac:	90                   	nop
    while (le != &free_list)
c01078ad:	81 7d f0 4c e1 12 c0 	cmpl   $0xc012e14c,-0x10(%ebp)
c01078b4:	0f 85 f3 fe ff ff    	jne    c01077ad <default_free_pages+0x12d>
        }
    }
    nr_free += n;
c01078ba:	8b 15 54 e1 12 c0    	mov    0xc012e154,%edx
c01078c0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01078c3:	01 d0                	add    %edx,%eax
c01078c5:	a3 54 e1 12 c0       	mov    %eax,0xc012e154
c01078ca:	c7 45 9c 4c e1 12 c0 	movl   $0xc012e14c,-0x64(%ebp)
    return listelm->next;
c01078d1:	8b 45 9c             	mov    -0x64(%ebp),%eax
c01078d4:	8b 40 04             	mov    0x4(%eax),%eax
    le = list_next(&free_list);
c01078d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list)
c01078da:	eb 66                	jmp    c0107942 <default_free_pages+0x2c2>
    {
        p = le2page(le, page_link);
c01078dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01078df:	83 e8 0c             	sub    $0xc,%eax
c01078e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (base + base->property <= p)
c01078e5:	8b 45 08             	mov    0x8(%ebp),%eax
c01078e8:	8b 40 08             	mov    0x8(%eax),%eax
c01078eb:	c1 e0 05             	shl    $0x5,%eax
c01078ee:	89 c2                	mov    %eax,%edx
c01078f0:	8b 45 08             	mov    0x8(%ebp),%eax
c01078f3:	01 d0                	add    %edx,%eax
c01078f5:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01078f8:	72 39                	jb     c0107933 <default_free_pages+0x2b3>
        {
            assert(base + base->property != p);
c01078fa:	8b 45 08             	mov    0x8(%ebp),%eax
c01078fd:	8b 40 08             	mov    0x8(%eax),%eax
c0107900:	c1 e0 05             	shl    $0x5,%eax
c0107903:	89 c2                	mov    %eax,%edx
c0107905:	8b 45 08             	mov    0x8(%ebp),%eax
c0107908:	01 d0                	add    %edx,%eax
c010790a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010790d:	75 3e                	jne    c010794d <default_free_pages+0x2cd>
c010790f:	c7 44 24 0c b5 bb 10 	movl   $0xc010bbb5,0xc(%esp)
c0107916:	c0 
c0107917:	c7 44 24 08 52 bb 10 	movl   $0xc010bb52,0x8(%esp)
c010791e:	c0 
c010791f:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
c0107926:	00 
c0107927:	c7 04 24 67 bb 10 c0 	movl   $0xc010bb67,(%esp)
c010792e:	e8 0a 8b ff ff       	call   c010043d <__panic>
c0107933:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107936:	89 45 98             	mov    %eax,-0x68(%ebp)
c0107939:	8b 45 98             	mov    -0x68(%ebp),%eax
c010793c:	8b 40 04             	mov    0x4(%eax),%eax
            break;
        }
        le = list_next(le);
c010793f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list)
c0107942:	81 7d f0 4c e1 12 c0 	cmpl   $0xc012e14c,-0x10(%ebp)
c0107949:	75 91                	jne    c01078dc <default_free_pages+0x25c>
c010794b:	eb 01                	jmp    c010794e <default_free_pages+0x2ce>
            break;
c010794d:	90                   	nop
    }
    list_add_before(le, &(base->page_link));
c010794e:	8b 45 08             	mov    0x8(%ebp),%eax
c0107951:	8d 50 0c             	lea    0xc(%eax),%edx
c0107954:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107957:	89 45 94             	mov    %eax,-0x6c(%ebp)
c010795a:	89 55 90             	mov    %edx,-0x70(%ebp)
    __list_add(elm, listelm->prev, listelm);
c010795d:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0107960:	8b 00                	mov    (%eax),%eax
c0107962:	8b 55 90             	mov    -0x70(%ebp),%edx
c0107965:	89 55 8c             	mov    %edx,-0x74(%ebp)
c0107968:	89 45 88             	mov    %eax,-0x78(%ebp)
c010796b:	8b 45 94             	mov    -0x6c(%ebp),%eax
c010796e:	89 45 84             	mov    %eax,-0x7c(%ebp)
    prev->next = next->prev = elm;
c0107971:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0107974:	8b 55 8c             	mov    -0x74(%ebp),%edx
c0107977:	89 10                	mov    %edx,(%eax)
c0107979:	8b 45 84             	mov    -0x7c(%ebp),%eax
c010797c:	8b 10                	mov    (%eax),%edx
c010797e:	8b 45 88             	mov    -0x78(%ebp),%eax
c0107981:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0107984:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0107987:	8b 55 84             	mov    -0x7c(%ebp),%edx
c010798a:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010798d:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0107990:	8b 55 88             	mov    -0x78(%ebp),%edx
c0107993:	89 10                	mov    %edx,(%eax)
}
c0107995:	90                   	nop
}
c0107996:	90                   	nop
}
c0107997:	90                   	nop
c0107998:	c9                   	leave  
c0107999:	c3                   	ret    

c010799a <default_nr_free_pages>:

static size_t
default_nr_free_pages(void)
{
c010799a:	f3 0f 1e fb          	endbr32 
c010799e:	55                   	push   %ebp
c010799f:	89 e5                	mov    %esp,%ebp
    return nr_free;
c01079a1:	a1 54 e1 12 c0       	mov    0xc012e154,%eax
}
c01079a6:	5d                   	pop    %ebp
c01079a7:	c3                   	ret    

c01079a8 <basic_check>:

static void
basic_check(void)
{
c01079a8:	f3 0f 1e fb          	endbr32 
c01079ac:	55                   	push   %ebp
c01079ad:	89 e5                	mov    %esp,%ebp
c01079af:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c01079b2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01079b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01079bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01079bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01079c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c01079c5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01079cc:	e8 3e bb ff ff       	call   c010350f <alloc_pages>
c01079d1:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01079d4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01079d8:	75 24                	jne    c01079fe <basic_check+0x56>
c01079da:	c7 44 24 0c d0 bb 10 	movl   $0xc010bbd0,0xc(%esp)
c01079e1:	c0 
c01079e2:	c7 44 24 08 52 bb 10 	movl   $0xc010bb52,0x8(%esp)
c01079e9:	c0 
c01079ea:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
c01079f1:	00 
c01079f2:	c7 04 24 67 bb 10 c0 	movl   $0xc010bb67,(%esp)
c01079f9:	e8 3f 8a ff ff       	call   c010043d <__panic>
    assert((p1 = alloc_page()) != NULL);
c01079fe:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107a05:	e8 05 bb ff ff       	call   c010350f <alloc_pages>
c0107a0a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107a0d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0107a11:	75 24                	jne    c0107a37 <basic_check+0x8f>
c0107a13:	c7 44 24 0c ec bb 10 	movl   $0xc010bbec,0xc(%esp)
c0107a1a:	c0 
c0107a1b:	c7 44 24 08 52 bb 10 	movl   $0xc010bb52,0x8(%esp)
c0107a22:	c0 
c0107a23:	c7 44 24 04 dd 00 00 	movl   $0xdd,0x4(%esp)
c0107a2a:	00 
c0107a2b:	c7 04 24 67 bb 10 c0 	movl   $0xc010bb67,(%esp)
c0107a32:	e8 06 8a ff ff       	call   c010043d <__panic>
    assert((p2 = alloc_page()) != NULL);
c0107a37:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107a3e:	e8 cc ba ff ff       	call   c010350f <alloc_pages>
c0107a43:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107a46:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107a4a:	75 24                	jne    c0107a70 <basic_check+0xc8>
c0107a4c:	c7 44 24 0c 08 bc 10 	movl   $0xc010bc08,0xc(%esp)
c0107a53:	c0 
c0107a54:	c7 44 24 08 52 bb 10 	movl   $0xc010bb52,0x8(%esp)
c0107a5b:	c0 
c0107a5c:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
c0107a63:	00 
c0107a64:	c7 04 24 67 bb 10 c0 	movl   $0xc010bb67,(%esp)
c0107a6b:	e8 cd 89 ff ff       	call   c010043d <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0107a70:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107a73:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0107a76:	74 10                	je     c0107a88 <basic_check+0xe0>
c0107a78:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107a7b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0107a7e:	74 08                	je     c0107a88 <basic_check+0xe0>
c0107a80:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107a83:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0107a86:	75 24                	jne    c0107aac <basic_check+0x104>
c0107a88:	c7 44 24 0c 24 bc 10 	movl   $0xc010bc24,0xc(%esp)
c0107a8f:	c0 
c0107a90:	c7 44 24 08 52 bb 10 	movl   $0xc010bb52,0x8(%esp)
c0107a97:	c0 
c0107a98:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
c0107a9f:	00 
c0107aa0:	c7 04 24 67 bb 10 c0 	movl   $0xc010bb67,(%esp)
c0107aa7:	e8 91 89 ff ff       	call   c010043d <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c0107aac:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107aaf:	89 04 24             	mov    %eax,(%esp)
c0107ab2:	e8 a9 f8 ff ff       	call   c0107360 <page_ref>
c0107ab7:	85 c0                	test   %eax,%eax
c0107ab9:	75 1e                	jne    c0107ad9 <basic_check+0x131>
c0107abb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107abe:	89 04 24             	mov    %eax,(%esp)
c0107ac1:	e8 9a f8 ff ff       	call   c0107360 <page_ref>
c0107ac6:	85 c0                	test   %eax,%eax
c0107ac8:	75 0f                	jne    c0107ad9 <basic_check+0x131>
c0107aca:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107acd:	89 04 24             	mov    %eax,(%esp)
c0107ad0:	e8 8b f8 ff ff       	call   c0107360 <page_ref>
c0107ad5:	85 c0                	test   %eax,%eax
c0107ad7:	74 24                	je     c0107afd <basic_check+0x155>
c0107ad9:	c7 44 24 0c 48 bc 10 	movl   $0xc010bc48,0xc(%esp)
c0107ae0:	c0 
c0107ae1:	c7 44 24 08 52 bb 10 	movl   $0xc010bb52,0x8(%esp)
c0107ae8:	c0 
c0107ae9:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
c0107af0:	00 
c0107af1:	c7 04 24 67 bb 10 c0 	movl   $0xc010bb67,(%esp)
c0107af8:	e8 40 89 ff ff       	call   c010043d <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0107afd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107b00:	89 04 24             	mov    %eax,(%esp)
c0107b03:	e8 42 f8 ff ff       	call   c010734a <page2pa>
c0107b08:	8b 15 80 bf 12 c0    	mov    0xc012bf80,%edx
c0107b0e:	c1 e2 0c             	shl    $0xc,%edx
c0107b11:	39 d0                	cmp    %edx,%eax
c0107b13:	72 24                	jb     c0107b39 <basic_check+0x191>
c0107b15:	c7 44 24 0c 84 bc 10 	movl   $0xc010bc84,0xc(%esp)
c0107b1c:	c0 
c0107b1d:	c7 44 24 08 52 bb 10 	movl   $0xc010bb52,0x8(%esp)
c0107b24:	c0 
c0107b25:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
c0107b2c:	00 
c0107b2d:	c7 04 24 67 bb 10 c0 	movl   $0xc010bb67,(%esp)
c0107b34:	e8 04 89 ff ff       	call   c010043d <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c0107b39:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107b3c:	89 04 24             	mov    %eax,(%esp)
c0107b3f:	e8 06 f8 ff ff       	call   c010734a <page2pa>
c0107b44:	8b 15 80 bf 12 c0    	mov    0xc012bf80,%edx
c0107b4a:	c1 e2 0c             	shl    $0xc,%edx
c0107b4d:	39 d0                	cmp    %edx,%eax
c0107b4f:	72 24                	jb     c0107b75 <basic_check+0x1cd>
c0107b51:	c7 44 24 0c a1 bc 10 	movl   $0xc010bca1,0xc(%esp)
c0107b58:	c0 
c0107b59:	c7 44 24 08 52 bb 10 	movl   $0xc010bb52,0x8(%esp)
c0107b60:	c0 
c0107b61:	c7 44 24 04 e4 00 00 	movl   $0xe4,0x4(%esp)
c0107b68:	00 
c0107b69:	c7 04 24 67 bb 10 c0 	movl   $0xc010bb67,(%esp)
c0107b70:	e8 c8 88 ff ff       	call   c010043d <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0107b75:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107b78:	89 04 24             	mov    %eax,(%esp)
c0107b7b:	e8 ca f7 ff ff       	call   c010734a <page2pa>
c0107b80:	8b 15 80 bf 12 c0    	mov    0xc012bf80,%edx
c0107b86:	c1 e2 0c             	shl    $0xc,%edx
c0107b89:	39 d0                	cmp    %edx,%eax
c0107b8b:	72 24                	jb     c0107bb1 <basic_check+0x209>
c0107b8d:	c7 44 24 0c be bc 10 	movl   $0xc010bcbe,0xc(%esp)
c0107b94:	c0 
c0107b95:	c7 44 24 08 52 bb 10 	movl   $0xc010bb52,0x8(%esp)
c0107b9c:	c0 
c0107b9d:	c7 44 24 04 e5 00 00 	movl   $0xe5,0x4(%esp)
c0107ba4:	00 
c0107ba5:	c7 04 24 67 bb 10 c0 	movl   $0xc010bb67,(%esp)
c0107bac:	e8 8c 88 ff ff       	call   c010043d <__panic>

    list_entry_t free_list_store = free_list;
c0107bb1:	a1 4c e1 12 c0       	mov    0xc012e14c,%eax
c0107bb6:	8b 15 50 e1 12 c0    	mov    0xc012e150,%edx
c0107bbc:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0107bbf:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0107bc2:	c7 45 dc 4c e1 12 c0 	movl   $0xc012e14c,-0x24(%ebp)
    elm->prev = elm->next = elm;
c0107bc9:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107bcc:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107bcf:	89 50 04             	mov    %edx,0x4(%eax)
c0107bd2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107bd5:	8b 50 04             	mov    0x4(%eax),%edx
c0107bd8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107bdb:	89 10                	mov    %edx,(%eax)
}
c0107bdd:	90                   	nop
c0107bde:	c7 45 e0 4c e1 12 c0 	movl   $0xc012e14c,-0x20(%ebp)
    return list->next == list;
c0107be5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107be8:	8b 40 04             	mov    0x4(%eax),%eax
c0107beb:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0107bee:	0f 94 c0             	sete   %al
c0107bf1:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0107bf4:	85 c0                	test   %eax,%eax
c0107bf6:	75 24                	jne    c0107c1c <basic_check+0x274>
c0107bf8:	c7 44 24 0c db bc 10 	movl   $0xc010bcdb,0xc(%esp)
c0107bff:	c0 
c0107c00:	c7 44 24 08 52 bb 10 	movl   $0xc010bb52,0x8(%esp)
c0107c07:	c0 
c0107c08:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
c0107c0f:	00 
c0107c10:	c7 04 24 67 bb 10 c0 	movl   $0xc010bb67,(%esp)
c0107c17:	e8 21 88 ff ff       	call   c010043d <__panic>

    unsigned int nr_free_store = nr_free;
c0107c1c:	a1 54 e1 12 c0       	mov    0xc012e154,%eax
c0107c21:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c0107c24:	c7 05 54 e1 12 c0 00 	movl   $0x0,0xc012e154
c0107c2b:	00 00 00 

    assert(alloc_page() == NULL);
c0107c2e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107c35:	e8 d5 b8 ff ff       	call   c010350f <alloc_pages>
c0107c3a:	85 c0                	test   %eax,%eax
c0107c3c:	74 24                	je     c0107c62 <basic_check+0x2ba>
c0107c3e:	c7 44 24 0c f2 bc 10 	movl   $0xc010bcf2,0xc(%esp)
c0107c45:	c0 
c0107c46:	c7 44 24 08 52 bb 10 	movl   $0xc010bb52,0x8(%esp)
c0107c4d:	c0 
c0107c4e:	c7 44 24 04 ee 00 00 	movl   $0xee,0x4(%esp)
c0107c55:	00 
c0107c56:	c7 04 24 67 bb 10 c0 	movl   $0xc010bb67,(%esp)
c0107c5d:	e8 db 87 ff ff       	call   c010043d <__panic>

    free_page(p0);
c0107c62:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107c69:	00 
c0107c6a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107c6d:	89 04 24             	mov    %eax,(%esp)
c0107c70:	e8 09 b9 ff ff       	call   c010357e <free_pages>
    free_page(p1);
c0107c75:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107c7c:	00 
c0107c7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107c80:	89 04 24             	mov    %eax,(%esp)
c0107c83:	e8 f6 b8 ff ff       	call   c010357e <free_pages>
    free_page(p2);
c0107c88:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107c8f:	00 
c0107c90:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107c93:	89 04 24             	mov    %eax,(%esp)
c0107c96:	e8 e3 b8 ff ff       	call   c010357e <free_pages>
    assert(nr_free == 3);
c0107c9b:	a1 54 e1 12 c0       	mov    0xc012e154,%eax
c0107ca0:	83 f8 03             	cmp    $0x3,%eax
c0107ca3:	74 24                	je     c0107cc9 <basic_check+0x321>
c0107ca5:	c7 44 24 0c 07 bd 10 	movl   $0xc010bd07,0xc(%esp)
c0107cac:	c0 
c0107cad:	c7 44 24 08 52 bb 10 	movl   $0xc010bb52,0x8(%esp)
c0107cb4:	c0 
c0107cb5:	c7 44 24 04 f3 00 00 	movl   $0xf3,0x4(%esp)
c0107cbc:	00 
c0107cbd:	c7 04 24 67 bb 10 c0 	movl   $0xc010bb67,(%esp)
c0107cc4:	e8 74 87 ff ff       	call   c010043d <__panic>

    assert((p0 = alloc_page()) != NULL);
c0107cc9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107cd0:	e8 3a b8 ff ff       	call   c010350f <alloc_pages>
c0107cd5:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107cd8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0107cdc:	75 24                	jne    c0107d02 <basic_check+0x35a>
c0107cde:	c7 44 24 0c d0 bb 10 	movl   $0xc010bbd0,0xc(%esp)
c0107ce5:	c0 
c0107ce6:	c7 44 24 08 52 bb 10 	movl   $0xc010bb52,0x8(%esp)
c0107ced:	c0 
c0107cee:	c7 44 24 04 f5 00 00 	movl   $0xf5,0x4(%esp)
c0107cf5:	00 
c0107cf6:	c7 04 24 67 bb 10 c0 	movl   $0xc010bb67,(%esp)
c0107cfd:	e8 3b 87 ff ff       	call   c010043d <__panic>
    assert((p1 = alloc_page()) != NULL);
c0107d02:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107d09:	e8 01 b8 ff ff       	call   c010350f <alloc_pages>
c0107d0e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107d11:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0107d15:	75 24                	jne    c0107d3b <basic_check+0x393>
c0107d17:	c7 44 24 0c ec bb 10 	movl   $0xc010bbec,0xc(%esp)
c0107d1e:	c0 
c0107d1f:	c7 44 24 08 52 bb 10 	movl   $0xc010bb52,0x8(%esp)
c0107d26:	c0 
c0107d27:	c7 44 24 04 f6 00 00 	movl   $0xf6,0x4(%esp)
c0107d2e:	00 
c0107d2f:	c7 04 24 67 bb 10 c0 	movl   $0xc010bb67,(%esp)
c0107d36:	e8 02 87 ff ff       	call   c010043d <__panic>
    assert((p2 = alloc_page()) != NULL);
c0107d3b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107d42:	e8 c8 b7 ff ff       	call   c010350f <alloc_pages>
c0107d47:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107d4a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107d4e:	75 24                	jne    c0107d74 <basic_check+0x3cc>
c0107d50:	c7 44 24 0c 08 bc 10 	movl   $0xc010bc08,0xc(%esp)
c0107d57:	c0 
c0107d58:	c7 44 24 08 52 bb 10 	movl   $0xc010bb52,0x8(%esp)
c0107d5f:	c0 
c0107d60:	c7 44 24 04 f7 00 00 	movl   $0xf7,0x4(%esp)
c0107d67:	00 
c0107d68:	c7 04 24 67 bb 10 c0 	movl   $0xc010bb67,(%esp)
c0107d6f:	e8 c9 86 ff ff       	call   c010043d <__panic>

    assert(alloc_page() == NULL);
c0107d74:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107d7b:	e8 8f b7 ff ff       	call   c010350f <alloc_pages>
c0107d80:	85 c0                	test   %eax,%eax
c0107d82:	74 24                	je     c0107da8 <basic_check+0x400>
c0107d84:	c7 44 24 0c f2 bc 10 	movl   $0xc010bcf2,0xc(%esp)
c0107d8b:	c0 
c0107d8c:	c7 44 24 08 52 bb 10 	movl   $0xc010bb52,0x8(%esp)
c0107d93:	c0 
c0107d94:	c7 44 24 04 f9 00 00 	movl   $0xf9,0x4(%esp)
c0107d9b:	00 
c0107d9c:	c7 04 24 67 bb 10 c0 	movl   $0xc010bb67,(%esp)
c0107da3:	e8 95 86 ff ff       	call   c010043d <__panic>

    free_page(p0);
c0107da8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107daf:	00 
c0107db0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107db3:	89 04 24             	mov    %eax,(%esp)
c0107db6:	e8 c3 b7 ff ff       	call   c010357e <free_pages>
c0107dbb:	c7 45 d8 4c e1 12 c0 	movl   $0xc012e14c,-0x28(%ebp)
c0107dc2:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0107dc5:	8b 40 04             	mov    0x4(%eax),%eax
c0107dc8:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0107dcb:	0f 94 c0             	sete   %al
c0107dce:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c0107dd1:	85 c0                	test   %eax,%eax
c0107dd3:	74 24                	je     c0107df9 <basic_check+0x451>
c0107dd5:	c7 44 24 0c 14 bd 10 	movl   $0xc010bd14,0xc(%esp)
c0107ddc:	c0 
c0107ddd:	c7 44 24 08 52 bb 10 	movl   $0xc010bb52,0x8(%esp)
c0107de4:	c0 
c0107de5:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
c0107dec:	00 
c0107ded:	c7 04 24 67 bb 10 c0 	movl   $0xc010bb67,(%esp)
c0107df4:	e8 44 86 ff ff       	call   c010043d <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0107df9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107e00:	e8 0a b7 ff ff       	call   c010350f <alloc_pages>
c0107e05:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0107e08:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107e0b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0107e0e:	74 24                	je     c0107e34 <basic_check+0x48c>
c0107e10:	c7 44 24 0c 2c bd 10 	movl   $0xc010bd2c,0xc(%esp)
c0107e17:	c0 
c0107e18:	c7 44 24 08 52 bb 10 	movl   $0xc010bb52,0x8(%esp)
c0107e1f:	c0 
c0107e20:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
c0107e27:	00 
c0107e28:	c7 04 24 67 bb 10 c0 	movl   $0xc010bb67,(%esp)
c0107e2f:	e8 09 86 ff ff       	call   c010043d <__panic>
    assert(alloc_page() == NULL);
c0107e34:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107e3b:	e8 cf b6 ff ff       	call   c010350f <alloc_pages>
c0107e40:	85 c0                	test   %eax,%eax
c0107e42:	74 24                	je     c0107e68 <basic_check+0x4c0>
c0107e44:	c7 44 24 0c f2 bc 10 	movl   $0xc010bcf2,0xc(%esp)
c0107e4b:	c0 
c0107e4c:	c7 44 24 08 52 bb 10 	movl   $0xc010bb52,0x8(%esp)
c0107e53:	c0 
c0107e54:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
c0107e5b:	00 
c0107e5c:	c7 04 24 67 bb 10 c0 	movl   $0xc010bb67,(%esp)
c0107e63:	e8 d5 85 ff ff       	call   c010043d <__panic>

    assert(nr_free == 0);
c0107e68:	a1 54 e1 12 c0       	mov    0xc012e154,%eax
c0107e6d:	85 c0                	test   %eax,%eax
c0107e6f:	74 24                	je     c0107e95 <basic_check+0x4ed>
c0107e71:	c7 44 24 0c 45 bd 10 	movl   $0xc010bd45,0xc(%esp)
c0107e78:	c0 
c0107e79:	c7 44 24 08 52 bb 10 	movl   $0xc010bb52,0x8(%esp)
c0107e80:	c0 
c0107e81:	c7 44 24 04 02 01 00 	movl   $0x102,0x4(%esp)
c0107e88:	00 
c0107e89:	c7 04 24 67 bb 10 c0 	movl   $0xc010bb67,(%esp)
c0107e90:	e8 a8 85 ff ff       	call   c010043d <__panic>
    free_list = free_list_store;
c0107e95:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0107e98:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0107e9b:	a3 4c e1 12 c0       	mov    %eax,0xc012e14c
c0107ea0:	89 15 50 e1 12 c0    	mov    %edx,0xc012e150
    nr_free = nr_free_store;
c0107ea6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107ea9:	a3 54 e1 12 c0       	mov    %eax,0xc012e154

    free_page(p);
c0107eae:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107eb5:	00 
c0107eb6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107eb9:	89 04 24             	mov    %eax,(%esp)
c0107ebc:	e8 bd b6 ff ff       	call   c010357e <free_pages>
    free_page(p1);
c0107ec1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107ec8:	00 
c0107ec9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107ecc:	89 04 24             	mov    %eax,(%esp)
c0107ecf:	e8 aa b6 ff ff       	call   c010357e <free_pages>
    free_page(p2);
c0107ed4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107edb:	00 
c0107edc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107edf:	89 04 24             	mov    %eax,(%esp)
c0107ee2:	e8 97 b6 ff ff       	call   c010357e <free_pages>
}
c0107ee7:	90                   	nop
c0107ee8:	c9                   	leave  
c0107ee9:	c3                   	ret    

c0107eea <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1)
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void)
{
c0107eea:	f3 0f 1e fb          	endbr32 
c0107eee:	55                   	push   %ebp
c0107eef:	89 e5                	mov    %esp,%ebp
c0107ef1:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
c0107ef7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0107efe:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c0107f05:	c7 45 ec 4c e1 12 c0 	movl   $0xc012e14c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list)
c0107f0c:	eb 6a                	jmp    c0107f78 <default_check+0x8e>
    {
        struct Page *p = le2page(le, page_link);
c0107f0e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107f11:	83 e8 0c             	sub    $0xc,%eax
c0107f14:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(PageProperty(p));
c0107f17:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0107f1a:	83 c0 04             	add    $0x4,%eax
c0107f1d:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0107f24:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0107f27:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0107f2a:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0107f2d:	0f a3 10             	bt     %edx,(%eax)
c0107f30:	19 c0                	sbb    %eax,%eax
c0107f32:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c0107f35:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0107f39:	0f 95 c0             	setne  %al
c0107f3c:	0f b6 c0             	movzbl %al,%eax
c0107f3f:	85 c0                	test   %eax,%eax
c0107f41:	75 24                	jne    c0107f67 <default_check+0x7d>
c0107f43:	c7 44 24 0c 52 bd 10 	movl   $0xc010bd52,0xc(%esp)
c0107f4a:	c0 
c0107f4b:	c7 44 24 08 52 bb 10 	movl   $0xc010bb52,0x8(%esp)
c0107f52:	c0 
c0107f53:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
c0107f5a:	00 
c0107f5b:	c7 04 24 67 bb 10 c0 	movl   $0xc010bb67,(%esp)
c0107f62:	e8 d6 84 ff ff       	call   c010043d <__panic>
        count++, total += p->property;
c0107f67:	ff 45 f4             	incl   -0xc(%ebp)
c0107f6a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0107f6d:	8b 50 08             	mov    0x8(%eax),%edx
c0107f70:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107f73:	01 d0                	add    %edx,%eax
c0107f75:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107f78:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107f7b:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
c0107f7e:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0107f81:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list)
c0107f84:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107f87:	81 7d ec 4c e1 12 c0 	cmpl   $0xc012e14c,-0x14(%ebp)
c0107f8e:	0f 85 7a ff ff ff    	jne    c0107f0e <default_check+0x24>
    }
    assert(total == nr_free_pages());
c0107f94:	e8 1c b6 ff ff       	call   c01035b5 <nr_free_pages>
c0107f99:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0107f9c:	39 d0                	cmp    %edx,%eax
c0107f9e:	74 24                	je     c0107fc4 <default_check+0xda>
c0107fa0:	c7 44 24 0c 62 bd 10 	movl   $0xc010bd62,0xc(%esp)
c0107fa7:	c0 
c0107fa8:	c7 44 24 08 52 bb 10 	movl   $0xc010bb52,0x8(%esp)
c0107faf:	c0 
c0107fb0:	c7 44 24 04 18 01 00 	movl   $0x118,0x4(%esp)
c0107fb7:	00 
c0107fb8:	c7 04 24 67 bb 10 c0 	movl   $0xc010bb67,(%esp)
c0107fbf:	e8 79 84 ff ff       	call   c010043d <__panic>

    basic_check();
c0107fc4:	e8 df f9 ff ff       	call   c01079a8 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c0107fc9:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0107fd0:	e8 3a b5 ff ff       	call   c010350f <alloc_pages>
c0107fd5:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p0 != NULL);
c0107fd8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0107fdc:	75 24                	jne    c0108002 <default_check+0x118>
c0107fde:	c7 44 24 0c 7b bd 10 	movl   $0xc010bd7b,0xc(%esp)
c0107fe5:	c0 
c0107fe6:	c7 44 24 08 52 bb 10 	movl   $0xc010bb52,0x8(%esp)
c0107fed:	c0 
c0107fee:	c7 44 24 04 1d 01 00 	movl   $0x11d,0x4(%esp)
c0107ff5:	00 
c0107ff6:	c7 04 24 67 bb 10 c0 	movl   $0xc010bb67,(%esp)
c0107ffd:	e8 3b 84 ff ff       	call   c010043d <__panic>
    assert(!PageProperty(p0));
c0108002:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108005:	83 c0 04             	add    $0x4,%eax
c0108008:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c010800f:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0108012:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0108015:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0108018:	0f a3 10             	bt     %edx,(%eax)
c010801b:	19 c0                	sbb    %eax,%eax
c010801d:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c0108020:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0108024:	0f 95 c0             	setne  %al
c0108027:	0f b6 c0             	movzbl %al,%eax
c010802a:	85 c0                	test   %eax,%eax
c010802c:	74 24                	je     c0108052 <default_check+0x168>
c010802e:	c7 44 24 0c 86 bd 10 	movl   $0xc010bd86,0xc(%esp)
c0108035:	c0 
c0108036:	c7 44 24 08 52 bb 10 	movl   $0xc010bb52,0x8(%esp)
c010803d:	c0 
c010803e:	c7 44 24 04 1e 01 00 	movl   $0x11e,0x4(%esp)
c0108045:	00 
c0108046:	c7 04 24 67 bb 10 c0 	movl   $0xc010bb67,(%esp)
c010804d:	e8 eb 83 ff ff       	call   c010043d <__panic>

    list_entry_t free_list_store = free_list;
c0108052:	a1 4c e1 12 c0       	mov    0xc012e14c,%eax
c0108057:	8b 15 50 e1 12 c0    	mov    0xc012e150,%edx
c010805d:	89 45 80             	mov    %eax,-0x80(%ebp)
c0108060:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0108063:	c7 45 b0 4c e1 12 c0 	movl   $0xc012e14c,-0x50(%ebp)
    elm->prev = elm->next = elm;
c010806a:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010806d:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0108070:	89 50 04             	mov    %edx,0x4(%eax)
c0108073:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0108076:	8b 50 04             	mov    0x4(%eax),%edx
c0108079:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010807c:	89 10                	mov    %edx,(%eax)
}
c010807e:	90                   	nop
c010807f:	c7 45 b4 4c e1 12 c0 	movl   $0xc012e14c,-0x4c(%ebp)
    return list->next == list;
c0108086:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0108089:	8b 40 04             	mov    0x4(%eax),%eax
c010808c:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
c010808f:	0f 94 c0             	sete   %al
c0108092:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0108095:	85 c0                	test   %eax,%eax
c0108097:	75 24                	jne    c01080bd <default_check+0x1d3>
c0108099:	c7 44 24 0c db bc 10 	movl   $0xc010bcdb,0xc(%esp)
c01080a0:	c0 
c01080a1:	c7 44 24 08 52 bb 10 	movl   $0xc010bb52,0x8(%esp)
c01080a8:	c0 
c01080a9:	c7 44 24 04 22 01 00 	movl   $0x122,0x4(%esp)
c01080b0:	00 
c01080b1:	c7 04 24 67 bb 10 c0 	movl   $0xc010bb67,(%esp)
c01080b8:	e8 80 83 ff ff       	call   c010043d <__panic>
    assert(alloc_page() == NULL);
c01080bd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01080c4:	e8 46 b4 ff ff       	call   c010350f <alloc_pages>
c01080c9:	85 c0                	test   %eax,%eax
c01080cb:	74 24                	je     c01080f1 <default_check+0x207>
c01080cd:	c7 44 24 0c f2 bc 10 	movl   $0xc010bcf2,0xc(%esp)
c01080d4:	c0 
c01080d5:	c7 44 24 08 52 bb 10 	movl   $0xc010bb52,0x8(%esp)
c01080dc:	c0 
c01080dd:	c7 44 24 04 23 01 00 	movl   $0x123,0x4(%esp)
c01080e4:	00 
c01080e5:	c7 04 24 67 bb 10 c0 	movl   $0xc010bb67,(%esp)
c01080ec:	e8 4c 83 ff ff       	call   c010043d <__panic>

    unsigned int nr_free_store = nr_free;
c01080f1:	a1 54 e1 12 c0       	mov    0xc012e154,%eax
c01080f6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nr_free = 0;
c01080f9:	c7 05 54 e1 12 c0 00 	movl   $0x0,0xc012e154
c0108100:	00 00 00 

    free_pages(p0 + 2, 3);
c0108103:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108106:	83 c0 40             	add    $0x40,%eax
c0108109:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0108110:	00 
c0108111:	89 04 24             	mov    %eax,(%esp)
c0108114:	e8 65 b4 ff ff       	call   c010357e <free_pages>
    assert(alloc_pages(4) == NULL);
c0108119:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0108120:	e8 ea b3 ff ff       	call   c010350f <alloc_pages>
c0108125:	85 c0                	test   %eax,%eax
c0108127:	74 24                	je     c010814d <default_check+0x263>
c0108129:	c7 44 24 0c 98 bd 10 	movl   $0xc010bd98,0xc(%esp)
c0108130:	c0 
c0108131:	c7 44 24 08 52 bb 10 	movl   $0xc010bb52,0x8(%esp)
c0108138:	c0 
c0108139:	c7 44 24 04 29 01 00 	movl   $0x129,0x4(%esp)
c0108140:	00 
c0108141:	c7 04 24 67 bb 10 c0 	movl   $0xc010bb67,(%esp)
c0108148:	e8 f0 82 ff ff       	call   c010043d <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c010814d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108150:	83 c0 40             	add    $0x40,%eax
c0108153:	83 c0 04             	add    $0x4,%eax
c0108156:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c010815d:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0108160:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0108163:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0108166:	0f a3 10             	bt     %edx,(%eax)
c0108169:	19 c0                	sbb    %eax,%eax
c010816b:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c010816e:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0108172:	0f 95 c0             	setne  %al
c0108175:	0f b6 c0             	movzbl %al,%eax
c0108178:	85 c0                	test   %eax,%eax
c010817a:	74 0e                	je     c010818a <default_check+0x2a0>
c010817c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010817f:	83 c0 40             	add    $0x40,%eax
c0108182:	8b 40 08             	mov    0x8(%eax),%eax
c0108185:	83 f8 03             	cmp    $0x3,%eax
c0108188:	74 24                	je     c01081ae <default_check+0x2c4>
c010818a:	c7 44 24 0c b0 bd 10 	movl   $0xc010bdb0,0xc(%esp)
c0108191:	c0 
c0108192:	c7 44 24 08 52 bb 10 	movl   $0xc010bb52,0x8(%esp)
c0108199:	c0 
c010819a:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
c01081a1:	00 
c01081a2:	c7 04 24 67 bb 10 c0 	movl   $0xc010bb67,(%esp)
c01081a9:	e8 8f 82 ff ff       	call   c010043d <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c01081ae:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c01081b5:	e8 55 b3 ff ff       	call   c010350f <alloc_pages>
c01081ba:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01081bd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01081c1:	75 24                	jne    c01081e7 <default_check+0x2fd>
c01081c3:	c7 44 24 0c dc bd 10 	movl   $0xc010bddc,0xc(%esp)
c01081ca:	c0 
c01081cb:	c7 44 24 08 52 bb 10 	movl   $0xc010bb52,0x8(%esp)
c01081d2:	c0 
c01081d3:	c7 44 24 04 2b 01 00 	movl   $0x12b,0x4(%esp)
c01081da:	00 
c01081db:	c7 04 24 67 bb 10 c0 	movl   $0xc010bb67,(%esp)
c01081e2:	e8 56 82 ff ff       	call   c010043d <__panic>
    assert(alloc_page() == NULL);
c01081e7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01081ee:	e8 1c b3 ff ff       	call   c010350f <alloc_pages>
c01081f3:	85 c0                	test   %eax,%eax
c01081f5:	74 24                	je     c010821b <default_check+0x331>
c01081f7:	c7 44 24 0c f2 bc 10 	movl   $0xc010bcf2,0xc(%esp)
c01081fe:	c0 
c01081ff:	c7 44 24 08 52 bb 10 	movl   $0xc010bb52,0x8(%esp)
c0108206:	c0 
c0108207:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
c010820e:	00 
c010820f:	c7 04 24 67 bb 10 c0 	movl   $0xc010bb67,(%esp)
c0108216:	e8 22 82 ff ff       	call   c010043d <__panic>
    assert(p0 + 2 == p1);
c010821b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010821e:	83 c0 40             	add    $0x40,%eax
c0108221:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0108224:	74 24                	je     c010824a <default_check+0x360>
c0108226:	c7 44 24 0c fa bd 10 	movl   $0xc010bdfa,0xc(%esp)
c010822d:	c0 
c010822e:	c7 44 24 08 52 bb 10 	movl   $0xc010bb52,0x8(%esp)
c0108235:	c0 
c0108236:	c7 44 24 04 2d 01 00 	movl   $0x12d,0x4(%esp)
c010823d:	00 
c010823e:	c7 04 24 67 bb 10 c0 	movl   $0xc010bb67,(%esp)
c0108245:	e8 f3 81 ff ff       	call   c010043d <__panic>

    p2 = p0 + 1;
c010824a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010824d:	83 c0 20             	add    $0x20,%eax
c0108250:	89 45 dc             	mov    %eax,-0x24(%ebp)
    free_page(p0);
c0108253:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010825a:	00 
c010825b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010825e:	89 04 24             	mov    %eax,(%esp)
c0108261:	e8 18 b3 ff ff       	call   c010357e <free_pages>
    free_pages(p1, 3);
c0108266:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c010826d:	00 
c010826e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108271:	89 04 24             	mov    %eax,(%esp)
c0108274:	e8 05 b3 ff ff       	call   c010357e <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c0108279:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010827c:	83 c0 04             	add    $0x4,%eax
c010827f:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c0108286:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0108289:	8b 45 9c             	mov    -0x64(%ebp),%eax
c010828c:	8b 55 a0             	mov    -0x60(%ebp),%edx
c010828f:	0f a3 10             	bt     %edx,(%eax)
c0108292:	19 c0                	sbb    %eax,%eax
c0108294:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c0108297:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c010829b:	0f 95 c0             	setne  %al
c010829e:	0f b6 c0             	movzbl %al,%eax
c01082a1:	85 c0                	test   %eax,%eax
c01082a3:	74 0b                	je     c01082b0 <default_check+0x3c6>
c01082a5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01082a8:	8b 40 08             	mov    0x8(%eax),%eax
c01082ab:	83 f8 01             	cmp    $0x1,%eax
c01082ae:	74 24                	je     c01082d4 <default_check+0x3ea>
c01082b0:	c7 44 24 0c 08 be 10 	movl   $0xc010be08,0xc(%esp)
c01082b7:	c0 
c01082b8:	c7 44 24 08 52 bb 10 	movl   $0xc010bb52,0x8(%esp)
c01082bf:	c0 
c01082c0:	c7 44 24 04 32 01 00 	movl   $0x132,0x4(%esp)
c01082c7:	00 
c01082c8:	c7 04 24 67 bb 10 c0 	movl   $0xc010bb67,(%esp)
c01082cf:	e8 69 81 ff ff       	call   c010043d <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c01082d4:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01082d7:	83 c0 04             	add    $0x4,%eax
c01082da:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c01082e1:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01082e4:	8b 45 90             	mov    -0x70(%ebp),%eax
c01082e7:	8b 55 94             	mov    -0x6c(%ebp),%edx
c01082ea:	0f a3 10             	bt     %edx,(%eax)
c01082ed:	19 c0                	sbb    %eax,%eax
c01082ef:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c01082f2:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c01082f6:	0f 95 c0             	setne  %al
c01082f9:	0f b6 c0             	movzbl %al,%eax
c01082fc:	85 c0                	test   %eax,%eax
c01082fe:	74 0b                	je     c010830b <default_check+0x421>
c0108300:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108303:	8b 40 08             	mov    0x8(%eax),%eax
c0108306:	83 f8 03             	cmp    $0x3,%eax
c0108309:	74 24                	je     c010832f <default_check+0x445>
c010830b:	c7 44 24 0c 30 be 10 	movl   $0xc010be30,0xc(%esp)
c0108312:	c0 
c0108313:	c7 44 24 08 52 bb 10 	movl   $0xc010bb52,0x8(%esp)
c010831a:	c0 
c010831b:	c7 44 24 04 33 01 00 	movl   $0x133,0x4(%esp)
c0108322:	00 
c0108323:	c7 04 24 67 bb 10 c0 	movl   $0xc010bb67,(%esp)
c010832a:	e8 0e 81 ff ff       	call   c010043d <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c010832f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0108336:	e8 d4 b1 ff ff       	call   c010350f <alloc_pages>
c010833b:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010833e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108341:	83 e8 20             	sub    $0x20,%eax
c0108344:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0108347:	74 24                	je     c010836d <default_check+0x483>
c0108349:	c7 44 24 0c 56 be 10 	movl   $0xc010be56,0xc(%esp)
c0108350:	c0 
c0108351:	c7 44 24 08 52 bb 10 	movl   $0xc010bb52,0x8(%esp)
c0108358:	c0 
c0108359:	c7 44 24 04 35 01 00 	movl   $0x135,0x4(%esp)
c0108360:	00 
c0108361:	c7 04 24 67 bb 10 c0 	movl   $0xc010bb67,(%esp)
c0108368:	e8 d0 80 ff ff       	call   c010043d <__panic>
    free_page(p0);
c010836d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0108374:	00 
c0108375:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108378:	89 04 24             	mov    %eax,(%esp)
c010837b:	e8 fe b1 ff ff       	call   c010357e <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c0108380:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0108387:	e8 83 b1 ff ff       	call   c010350f <alloc_pages>
c010838c:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010838f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108392:	83 c0 20             	add    $0x20,%eax
c0108395:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0108398:	74 24                	je     c01083be <default_check+0x4d4>
c010839a:	c7 44 24 0c 74 be 10 	movl   $0xc010be74,0xc(%esp)
c01083a1:	c0 
c01083a2:	c7 44 24 08 52 bb 10 	movl   $0xc010bb52,0x8(%esp)
c01083a9:	c0 
c01083aa:	c7 44 24 04 37 01 00 	movl   $0x137,0x4(%esp)
c01083b1:	00 
c01083b2:	c7 04 24 67 bb 10 c0 	movl   $0xc010bb67,(%esp)
c01083b9:	e8 7f 80 ff ff       	call   c010043d <__panic>

    free_pages(p0, 2);
c01083be:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c01083c5:	00 
c01083c6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01083c9:	89 04 24             	mov    %eax,(%esp)
c01083cc:	e8 ad b1 ff ff       	call   c010357e <free_pages>
    free_page(p2);
c01083d1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01083d8:	00 
c01083d9:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01083dc:	89 04 24             	mov    %eax,(%esp)
c01083df:	e8 9a b1 ff ff       	call   c010357e <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c01083e4:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c01083eb:	e8 1f b1 ff ff       	call   c010350f <alloc_pages>
c01083f0:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01083f3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01083f7:	75 24                	jne    c010841d <default_check+0x533>
c01083f9:	c7 44 24 0c 94 be 10 	movl   $0xc010be94,0xc(%esp)
c0108400:	c0 
c0108401:	c7 44 24 08 52 bb 10 	movl   $0xc010bb52,0x8(%esp)
c0108408:	c0 
c0108409:	c7 44 24 04 3c 01 00 	movl   $0x13c,0x4(%esp)
c0108410:	00 
c0108411:	c7 04 24 67 bb 10 c0 	movl   $0xc010bb67,(%esp)
c0108418:	e8 20 80 ff ff       	call   c010043d <__panic>
    assert(alloc_page() == NULL);
c010841d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0108424:	e8 e6 b0 ff ff       	call   c010350f <alloc_pages>
c0108429:	85 c0                	test   %eax,%eax
c010842b:	74 24                	je     c0108451 <default_check+0x567>
c010842d:	c7 44 24 0c f2 bc 10 	movl   $0xc010bcf2,0xc(%esp)
c0108434:	c0 
c0108435:	c7 44 24 08 52 bb 10 	movl   $0xc010bb52,0x8(%esp)
c010843c:	c0 
c010843d:	c7 44 24 04 3d 01 00 	movl   $0x13d,0x4(%esp)
c0108444:	00 
c0108445:	c7 04 24 67 bb 10 c0 	movl   $0xc010bb67,(%esp)
c010844c:	e8 ec 7f ff ff       	call   c010043d <__panic>

    assert(nr_free == 0);
c0108451:	a1 54 e1 12 c0       	mov    0xc012e154,%eax
c0108456:	85 c0                	test   %eax,%eax
c0108458:	74 24                	je     c010847e <default_check+0x594>
c010845a:	c7 44 24 0c 45 bd 10 	movl   $0xc010bd45,0xc(%esp)
c0108461:	c0 
c0108462:	c7 44 24 08 52 bb 10 	movl   $0xc010bb52,0x8(%esp)
c0108469:	c0 
c010846a:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
c0108471:	00 
c0108472:	c7 04 24 67 bb 10 c0 	movl   $0xc010bb67,(%esp)
c0108479:	e8 bf 7f ff ff       	call   c010043d <__panic>
    nr_free = nr_free_store;
c010847e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108481:	a3 54 e1 12 c0       	mov    %eax,0xc012e154

    free_list = free_list_store;
c0108486:	8b 45 80             	mov    -0x80(%ebp),%eax
c0108489:	8b 55 84             	mov    -0x7c(%ebp),%edx
c010848c:	a3 4c e1 12 c0       	mov    %eax,0xc012e14c
c0108491:	89 15 50 e1 12 c0    	mov    %edx,0xc012e150
    free_pages(p0, 5);
c0108497:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c010849e:	00 
c010849f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01084a2:	89 04 24             	mov    %eax,(%esp)
c01084a5:	e8 d4 b0 ff ff       	call   c010357e <free_pages>

    le = &free_list;
c01084aa:	c7 45 ec 4c e1 12 c0 	movl   $0xc012e14c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list)
c01084b1:	eb 1c                	jmp    c01084cf <default_check+0x5e5>
    {
        struct Page *p = le2page(le, page_link);
c01084b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01084b6:	83 e8 0c             	sub    $0xc,%eax
c01084b9:	89 45 d8             	mov    %eax,-0x28(%ebp)
        count--, total -= p->property;
c01084bc:	ff 4d f4             	decl   -0xc(%ebp)
c01084bf:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01084c2:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01084c5:	8b 40 08             	mov    0x8(%eax),%eax
c01084c8:	29 c2                	sub    %eax,%edx
c01084ca:	89 d0                	mov    %edx,%eax
c01084cc:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01084cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01084d2:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
c01084d5:	8b 45 88             	mov    -0x78(%ebp),%eax
c01084d8:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list)
c01084db:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01084de:	81 7d ec 4c e1 12 c0 	cmpl   $0xc012e14c,-0x14(%ebp)
c01084e5:	75 cc                	jne    c01084b3 <default_check+0x5c9>
    }
    assert(count == 0);
c01084e7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01084eb:	74 24                	je     c0108511 <default_check+0x627>
c01084ed:	c7 44 24 0c b2 be 10 	movl   $0xc010beb2,0xc(%esp)
c01084f4:	c0 
c01084f5:	c7 44 24 08 52 bb 10 	movl   $0xc010bb52,0x8(%esp)
c01084fc:	c0 
c01084fd:	c7 44 24 04 4b 01 00 	movl   $0x14b,0x4(%esp)
c0108504:	00 
c0108505:	c7 04 24 67 bb 10 c0 	movl   $0xc010bb67,(%esp)
c010850c:	e8 2c 7f ff ff       	call   c010043d <__panic>
    assert(total == 0);
c0108511:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0108515:	74 24                	je     c010853b <default_check+0x651>
c0108517:	c7 44 24 0c bd be 10 	movl   $0xc010bebd,0xc(%esp)
c010851e:	c0 
c010851f:	c7 44 24 08 52 bb 10 	movl   $0xc010bb52,0x8(%esp)
c0108526:	c0 
c0108527:	c7 44 24 04 4c 01 00 	movl   $0x14c,0x4(%esp)
c010852e:	00 
c010852f:	c7 04 24 67 bb 10 c0 	movl   $0xc010bb67,(%esp)
c0108536:	e8 02 7f ff ff       	call   c010043d <__panic>
}
c010853b:	90                   	nop
c010853c:	c9                   	leave  
c010853d:	c3                   	ret    

c010853e <page2ppn>:
page2ppn(struct Page *page) {
c010853e:	55                   	push   %ebp
c010853f:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0108541:	a1 60 e0 12 c0       	mov    0xc012e060,%eax
c0108546:	8b 55 08             	mov    0x8(%ebp),%edx
c0108549:	29 c2                	sub    %eax,%edx
c010854b:	89 d0                	mov    %edx,%eax
c010854d:	c1 f8 05             	sar    $0x5,%eax
}
c0108550:	5d                   	pop    %ebp
c0108551:	c3                   	ret    

c0108552 <page2pa>:
page2pa(struct Page *page) {
c0108552:	55                   	push   %ebp
c0108553:	89 e5                	mov    %esp,%ebp
c0108555:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0108558:	8b 45 08             	mov    0x8(%ebp),%eax
c010855b:	89 04 24             	mov    %eax,(%esp)
c010855e:	e8 db ff ff ff       	call   c010853e <page2ppn>
c0108563:	c1 e0 0c             	shl    $0xc,%eax
}
c0108566:	c9                   	leave  
c0108567:	c3                   	ret    

c0108568 <page2kva>:
page2kva(struct Page *page) {
c0108568:	55                   	push   %ebp
c0108569:	89 e5                	mov    %esp,%ebp
c010856b:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c010856e:	8b 45 08             	mov    0x8(%ebp),%eax
c0108571:	89 04 24             	mov    %eax,(%esp)
c0108574:	e8 d9 ff ff ff       	call   c0108552 <page2pa>
c0108579:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010857c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010857f:	c1 e8 0c             	shr    $0xc,%eax
c0108582:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108585:	a1 80 bf 12 c0       	mov    0xc012bf80,%eax
c010858a:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010858d:	72 23                	jb     c01085b2 <page2kva+0x4a>
c010858f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108592:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108596:	c7 44 24 08 f8 be 10 	movl   $0xc010bef8,0x8(%esp)
c010859d:	c0 
c010859e:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
c01085a5:	00 
c01085a6:	c7 04 24 1b bf 10 c0 	movl   $0xc010bf1b,(%esp)
c01085ad:	e8 8b 7e ff ff       	call   c010043d <__panic>
c01085b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01085b5:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c01085ba:	c9                   	leave  
c01085bb:	c3                   	ret    

c01085bc <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
c01085bc:	f3 0f 1e fb          	endbr32 
c01085c0:	55                   	push   %ebp
c01085c1:	89 e5                	mov    %esp,%ebp
c01085c3:	83 ec 18             	sub    $0x18,%esp
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
c01085c6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01085cd:	e8 9b 8b ff ff       	call   c010116d <ide_device_valid>
c01085d2:	85 c0                	test   %eax,%eax
c01085d4:	75 1c                	jne    c01085f2 <swapfs_init+0x36>
        panic("swap fs isn't available.\n");
c01085d6:	c7 44 24 08 29 bf 10 	movl   $0xc010bf29,0x8(%esp)
c01085dd:	c0 
c01085de:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
c01085e5:	00 
c01085e6:	c7 04 24 43 bf 10 c0 	movl   $0xc010bf43,(%esp)
c01085ed:	e8 4b 7e ff ff       	call   c010043d <__panic>
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
c01085f2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01085f9:	e8 b1 8b ff ff       	call   c01011af <ide_device_size>
c01085fe:	c1 e8 03             	shr    $0x3,%eax
c0108601:	a3 1c e1 12 c0       	mov    %eax,0xc012e11c
}
c0108606:	90                   	nop
c0108607:	c9                   	leave  
c0108608:	c3                   	ret    

c0108609 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
c0108609:	f3 0f 1e fb          	endbr32 
c010860d:	55                   	push   %ebp
c010860e:	89 e5                	mov    %esp,%ebp
c0108610:	83 ec 28             	sub    $0x28,%esp
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c0108613:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108616:	89 04 24             	mov    %eax,(%esp)
c0108619:	e8 4a ff ff ff       	call   c0108568 <page2kva>
c010861e:	8b 55 08             	mov    0x8(%ebp),%edx
c0108621:	c1 ea 08             	shr    $0x8,%edx
c0108624:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0108627:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010862b:	74 0b                	je     c0108638 <swapfs_read+0x2f>
c010862d:	8b 15 1c e1 12 c0    	mov    0xc012e11c,%edx
c0108633:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c0108636:	72 23                	jb     c010865b <swapfs_read+0x52>
c0108638:	8b 45 08             	mov    0x8(%ebp),%eax
c010863b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010863f:	c7 44 24 08 54 bf 10 	movl   $0xc010bf54,0x8(%esp)
c0108646:	c0 
c0108647:	c7 44 24 04 14 00 00 	movl   $0x14,0x4(%esp)
c010864e:	00 
c010864f:	c7 04 24 43 bf 10 c0 	movl   $0xc010bf43,(%esp)
c0108656:	e8 e2 7d ff ff       	call   c010043d <__panic>
c010865b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010865e:	c1 e2 03             	shl    $0x3,%edx
c0108661:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c0108668:	00 
c0108669:	89 44 24 08          	mov    %eax,0x8(%esp)
c010866d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108671:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0108678:	e8 71 8b ff ff       	call   c01011ee <ide_read_secs>
}
c010867d:	c9                   	leave  
c010867e:	c3                   	ret    

c010867f <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
c010867f:	f3 0f 1e fb          	endbr32 
c0108683:	55                   	push   %ebp
c0108684:	89 e5                	mov    %esp,%ebp
c0108686:	83 ec 28             	sub    $0x28,%esp
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c0108689:	8b 45 0c             	mov    0xc(%ebp),%eax
c010868c:	89 04 24             	mov    %eax,(%esp)
c010868f:	e8 d4 fe ff ff       	call   c0108568 <page2kva>
c0108694:	8b 55 08             	mov    0x8(%ebp),%edx
c0108697:	c1 ea 08             	shr    $0x8,%edx
c010869a:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010869d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01086a1:	74 0b                	je     c01086ae <swapfs_write+0x2f>
c01086a3:	8b 15 1c e1 12 c0    	mov    0xc012e11c,%edx
c01086a9:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c01086ac:	72 23                	jb     c01086d1 <swapfs_write+0x52>
c01086ae:	8b 45 08             	mov    0x8(%ebp),%eax
c01086b1:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01086b5:	c7 44 24 08 54 bf 10 	movl   $0xc010bf54,0x8(%esp)
c01086bc:	c0 
c01086bd:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
c01086c4:	00 
c01086c5:	c7 04 24 43 bf 10 c0 	movl   $0xc010bf43,(%esp)
c01086cc:	e8 6c 7d ff ff       	call   c010043d <__panic>
c01086d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01086d4:	c1 e2 03             	shl    $0x3,%edx
c01086d7:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c01086de:	00 
c01086df:	89 44 24 08          	mov    %eax,0x8(%esp)
c01086e3:	89 54 24 04          	mov    %edx,0x4(%esp)
c01086e7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01086ee:	e8 40 8d ff ff       	call   c0101433 <ide_write_secs>
}
c01086f3:	c9                   	leave  
c01086f4:	c3                   	ret    

c01086f5 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)

    pushl %edx              # push arg
c01086f5:	52                   	push   %edx
    call *%ebx              # call fn
c01086f6:	ff d3                	call   *%ebx

    pushl %eax              # save the return value of fn(arg)
c01086f8:	50                   	push   %eax
    call do_exit            # call do_exit to terminate current thread
c01086f9:	e8 ca 08 00 00       	call   c0108fc8 <do_exit>

c01086fe <switch_to>:
.text
.globl switch_to
switch_to:                      # switch_to(from, to)

    # save from's registers
    movl 4(%esp), %eax          # eax points to from
c01086fe:	8b 44 24 04          	mov    0x4(%esp),%eax
    popl 0(%eax)                # save eip !popl
c0108702:	8f 00                	popl   (%eax)
    movl %esp, 4(%eax)          # save esp::context of from
c0108704:	89 60 04             	mov    %esp,0x4(%eax)
    movl %ebx, 8(%eax)          # save ebx::context of from
c0108707:	89 58 08             	mov    %ebx,0x8(%eax)
    movl %ecx, 12(%eax)         # save ecx::context of from
c010870a:	89 48 0c             	mov    %ecx,0xc(%eax)
    movl %edx, 16(%eax)         # save edx::context of from
c010870d:	89 50 10             	mov    %edx,0x10(%eax)
    movl %esi, 20(%eax)         # save esi::context of from
c0108710:	89 70 14             	mov    %esi,0x14(%eax)
    movl %edi, 24(%eax)         # save edi::context of from
c0108713:	89 78 18             	mov    %edi,0x18(%eax)
    movl %ebp, 28(%eax)         # save ebp::context of from
c0108716:	89 68 1c             	mov    %ebp,0x1c(%eax)

    # restore to's registers
    movl 4(%esp), %eax          # not 8(%esp): popped return address already
c0108719:	8b 44 24 04          	mov    0x4(%esp),%eax
                                # eax now points to to
    movl 28(%eax), %ebp         # restore ebp::context of to
c010871d:	8b 68 1c             	mov    0x1c(%eax),%ebp
    movl 24(%eax), %edi         # restore edi::context of to
c0108720:	8b 78 18             	mov    0x18(%eax),%edi
    movl 20(%eax), %esi         # restore esi::context of to
c0108723:	8b 70 14             	mov    0x14(%eax),%esi
    movl 16(%eax), %edx         # restore edx::context of to
c0108726:	8b 50 10             	mov    0x10(%eax),%edx
    movl 12(%eax), %ecx         # restore ecx::context of to
c0108729:	8b 48 0c             	mov    0xc(%eax),%ecx
    movl 8(%eax), %ebx          # restore ebx::context of to
c010872c:	8b 58 08             	mov    0x8(%eax),%ebx
    movl 4(%eax), %esp          # restore esp::context of to
c010872f:	8b 60 04             	mov    0x4(%eax),%esp

    pushl 0(%eax)               # push eip
c0108732:	ff 30                	pushl  (%eax)

    ret
c0108734:	c3                   	ret    

c0108735 <__intr_save>:
__intr_save(void) {
c0108735:	55                   	push   %ebp
c0108736:	89 e5                	mov    %esp,%ebp
c0108738:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c010873b:	9c                   	pushf  
c010873c:	58                   	pop    %eax
c010873d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0108740:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0108743:	25 00 02 00 00       	and    $0x200,%eax
c0108748:	85 c0                	test   %eax,%eax
c010874a:	74 0c                	je     c0108758 <__intr_save+0x23>
        intr_disable();
c010874c:	e8 b3 9a ff ff       	call   c0102204 <intr_disable>
        return 1;
c0108751:	b8 01 00 00 00       	mov    $0x1,%eax
c0108756:	eb 05                	jmp    c010875d <__intr_save+0x28>
    return 0;
c0108758:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010875d:	c9                   	leave  
c010875e:	c3                   	ret    

c010875f <__intr_restore>:
__intr_restore(bool flag) {
c010875f:	55                   	push   %ebp
c0108760:	89 e5                	mov    %esp,%ebp
c0108762:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0108765:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0108769:	74 05                	je     c0108770 <__intr_restore+0x11>
        intr_enable();
c010876b:	e8 88 9a ff ff       	call   c01021f8 <intr_enable>
}
c0108770:	90                   	nop
c0108771:	c9                   	leave  
c0108772:	c3                   	ret    

c0108773 <page2ppn>:
page2ppn(struct Page *page) {
c0108773:	55                   	push   %ebp
c0108774:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0108776:	a1 60 e0 12 c0       	mov    0xc012e060,%eax
c010877b:	8b 55 08             	mov    0x8(%ebp),%edx
c010877e:	29 c2                	sub    %eax,%edx
c0108780:	89 d0                	mov    %edx,%eax
c0108782:	c1 f8 05             	sar    $0x5,%eax
}
c0108785:	5d                   	pop    %ebp
c0108786:	c3                   	ret    

c0108787 <page2pa>:
page2pa(struct Page *page) {
c0108787:	55                   	push   %ebp
c0108788:	89 e5                	mov    %esp,%ebp
c010878a:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c010878d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108790:	89 04 24             	mov    %eax,(%esp)
c0108793:	e8 db ff ff ff       	call   c0108773 <page2ppn>
c0108798:	c1 e0 0c             	shl    $0xc,%eax
}
c010879b:	c9                   	leave  
c010879c:	c3                   	ret    

c010879d <pa2page>:
pa2page(uintptr_t pa) {
c010879d:	55                   	push   %ebp
c010879e:	89 e5                	mov    %esp,%ebp
c01087a0:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c01087a3:	8b 45 08             	mov    0x8(%ebp),%eax
c01087a6:	c1 e8 0c             	shr    $0xc,%eax
c01087a9:	89 c2                	mov    %eax,%edx
c01087ab:	a1 80 bf 12 c0       	mov    0xc012bf80,%eax
c01087b0:	39 c2                	cmp    %eax,%edx
c01087b2:	72 1c                	jb     c01087d0 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c01087b4:	c7 44 24 08 74 bf 10 	movl   $0xc010bf74,0x8(%esp)
c01087bb:	c0 
c01087bc:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
c01087c3:	00 
c01087c4:	c7 04 24 93 bf 10 c0 	movl   $0xc010bf93,(%esp)
c01087cb:	e8 6d 7c ff ff       	call   c010043d <__panic>
    return &pages[PPN(pa)];
c01087d0:	a1 60 e0 12 c0       	mov    0xc012e060,%eax
c01087d5:	8b 55 08             	mov    0x8(%ebp),%edx
c01087d8:	c1 ea 0c             	shr    $0xc,%edx
c01087db:	c1 e2 05             	shl    $0x5,%edx
c01087de:	01 d0                	add    %edx,%eax
}
c01087e0:	c9                   	leave  
c01087e1:	c3                   	ret    

c01087e2 <page2kva>:
page2kva(struct Page *page) {
c01087e2:	55                   	push   %ebp
c01087e3:	89 e5                	mov    %esp,%ebp
c01087e5:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c01087e8:	8b 45 08             	mov    0x8(%ebp),%eax
c01087eb:	89 04 24             	mov    %eax,(%esp)
c01087ee:	e8 94 ff ff ff       	call   c0108787 <page2pa>
c01087f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01087f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01087f9:	c1 e8 0c             	shr    $0xc,%eax
c01087fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01087ff:	a1 80 bf 12 c0       	mov    0xc012bf80,%eax
c0108804:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0108807:	72 23                	jb     c010882c <page2kva+0x4a>
c0108809:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010880c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108810:	c7 44 24 08 a4 bf 10 	movl   $0xc010bfa4,0x8(%esp)
c0108817:	c0 
c0108818:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
c010881f:	00 
c0108820:	c7 04 24 93 bf 10 c0 	movl   $0xc010bf93,(%esp)
c0108827:	e8 11 7c ff ff       	call   c010043d <__panic>
c010882c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010882f:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0108834:	c9                   	leave  
c0108835:	c3                   	ret    

c0108836 <kva2page>:
kva2page(void *kva) {
c0108836:	55                   	push   %ebp
c0108837:	89 e5                	mov    %esp,%ebp
c0108839:	83 ec 28             	sub    $0x28,%esp
    return pa2page(PADDR(kva));
c010883c:	8b 45 08             	mov    0x8(%ebp),%eax
c010883f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108842:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0108849:	77 23                	ja     c010886e <kva2page+0x38>
c010884b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010884e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108852:	c7 44 24 08 c8 bf 10 	movl   $0xc010bfc8,0x8(%esp)
c0108859:	c0 
c010885a:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
c0108861:	00 
c0108862:	c7 04 24 93 bf 10 c0 	movl   $0xc010bf93,(%esp)
c0108869:	e8 cf 7b ff ff       	call   c010043d <__panic>
c010886e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108871:	05 00 00 00 40       	add    $0x40000000,%eax
c0108876:	89 04 24             	mov    %eax,(%esp)
c0108879:	e8 1f ff ff ff       	call   c010879d <pa2page>
}
c010887e:	c9                   	leave  
c010887f:	c3                   	ret    

c0108880 <alloc_proc>:
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void)
{
c0108880:	f3 0f 1e fb          	endbr32 
c0108884:	55                   	push   %ebp
c0108885:	89 e5                	mov    %esp,%ebp
c0108887:	83 ec 28             	sub    $0x28,%esp
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
c010888a:	c7 04 24 68 00 00 00 	movl   $0x68,(%esp)
c0108891:	e8 d4 e3 ff ff       	call   c0106c6a <kmalloc>
c0108896:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (proc != NULL)
c0108899:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010889d:	0f 84 a1 00 00 00    	je     c0108944 <alloc_proc+0xc4>
     *       struct trapframe *tf;                       // Trap frame for current interrupt
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */
        proc->state = PROC_UNINIT;
c01088a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01088a6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        proc->pid = -1;
c01088ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01088af:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
        proc->runs = 0;
c01088b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01088b9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        proc->kstack = 0;
c01088c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01088c3:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        proc->need_resched = 0;
c01088ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01088cd:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        proc->parent = NULL;
c01088d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01088d7:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        proc->mm = NULL;
c01088de:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01088e1:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
        memset(&(proc->context), 0, sizeof(struct context));
c01088e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01088eb:	83 c0 1c             	add    $0x1c,%eax
c01088ee:	c7 44 24 08 20 00 00 	movl   $0x20,0x8(%esp)
c01088f5:	00 
c01088f6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01088fd:	00 
c01088fe:	89 04 24             	mov    %eax,(%esp)
c0108901:	e8 bc 0d 00 00       	call   c01096c2 <memset>
        proc->tf = NULL;
c0108906:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108909:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
        proc->cr3 = boot_cr3;
c0108910:	8b 15 5c e0 12 c0    	mov    0xc012e05c,%edx
c0108916:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108919:	89 50 40             	mov    %edx,0x40(%eax)
        proc->flags = 0;
c010891c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010891f:	c7 40 44 00 00 00 00 	movl   $0x0,0x44(%eax)
        memset(proc->name, 0, PROC_NAME_LEN);
c0108926:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108929:	83 c0 48             	add    $0x48,%eax
c010892c:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c0108933:	00 
c0108934:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010893b:	00 
c010893c:	89 04 24             	mov    %eax,(%esp)
c010893f:	e8 7e 0d 00 00       	call   c01096c2 <memset>
    }
    return proc;
c0108944:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0108947:	c9                   	leave  
c0108948:	c3                   	ret    

c0108949 <set_proc_name>:

// set_proc_name - set the name of proc
char *
set_proc_name(struct proc_struct *proc, const char *name)
{
c0108949:	f3 0f 1e fb          	endbr32 
c010894d:	55                   	push   %ebp
c010894e:	89 e5                	mov    %esp,%ebp
c0108950:	83 ec 18             	sub    $0x18,%esp
    memset(proc->name, 0, sizeof(proc->name));
c0108953:	8b 45 08             	mov    0x8(%ebp),%eax
c0108956:	83 c0 48             	add    $0x48,%eax
c0108959:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c0108960:	00 
c0108961:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0108968:	00 
c0108969:	89 04 24             	mov    %eax,(%esp)
c010896c:	e8 51 0d 00 00       	call   c01096c2 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
c0108971:	8b 45 08             	mov    0x8(%ebp),%eax
c0108974:	8d 50 48             	lea    0x48(%eax),%edx
c0108977:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c010897e:	00 
c010897f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108982:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108986:	89 14 24             	mov    %edx,(%esp)
c0108989:	e8 1e 0e 00 00       	call   c01097ac <memcpy>
}
c010898e:	c9                   	leave  
c010898f:	c3                   	ret    

c0108990 <get_proc_name>:

// get_proc_name - get the name of proc
char *
get_proc_name(struct proc_struct *proc)
{
c0108990:	f3 0f 1e fb          	endbr32 
c0108994:	55                   	push   %ebp
c0108995:	89 e5                	mov    %esp,%ebp
c0108997:	83 ec 18             	sub    $0x18,%esp
    static char name[PROC_NAME_LEN + 1];
    memset(name, 0, sizeof(name));
c010899a:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c01089a1:	00 
c01089a2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01089a9:	00 
c01089aa:	c7 04 24 44 e0 12 c0 	movl   $0xc012e044,(%esp)
c01089b1:	e8 0c 0d 00 00       	call   c01096c2 <memset>
    return memcpy(name, proc->name, PROC_NAME_LEN);
c01089b6:	8b 45 08             	mov    0x8(%ebp),%eax
c01089b9:	83 c0 48             	add    $0x48,%eax
c01089bc:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c01089c3:	00 
c01089c4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01089c8:	c7 04 24 44 e0 12 c0 	movl   $0xc012e044,(%esp)
c01089cf:	e8 d8 0d 00 00       	call   c01097ac <memcpy>
}
c01089d4:	c9                   	leave  
c01089d5:	c3                   	ret    

c01089d6 <get_pid>:

// get_pid - alloc a unique pid for process
static int
get_pid(void)
{
c01089d6:	f3 0f 1e fb          	endbr32 
c01089da:	55                   	push   %ebp
c01089db:	89 e5                	mov    %esp,%ebp
c01089dd:	83 ec 10             	sub    $0x10,%esp
    static_assert(MAX_PID > MAX_PROCESS);
    struct proc_struct *proc;
    list_entry_t *list = &proc_list, *le;
c01089e0:	c7 45 f8 58 e1 12 c0 	movl   $0xc012e158,-0x8(%ebp)
    static int next_safe = MAX_PID, last_pid = MAX_PID;
    if (++last_pid >= MAX_PID)
c01089e7:	a1 80 8a 12 c0       	mov    0xc0128a80,%eax
c01089ec:	40                   	inc    %eax
c01089ed:	a3 80 8a 12 c0       	mov    %eax,0xc0128a80
c01089f2:	a1 80 8a 12 c0       	mov    0xc0128a80,%eax
c01089f7:	3d ff 1f 00 00       	cmp    $0x1fff,%eax
c01089fc:	7e 0c                	jle    c0108a0a <get_pid+0x34>
    {
        last_pid = 1;
c01089fe:	c7 05 80 8a 12 c0 01 	movl   $0x1,0xc0128a80
c0108a05:	00 00 00 
        goto inside;
c0108a08:	eb 14                	jmp    c0108a1e <get_pid+0x48>
    }
    if (last_pid >= next_safe)
c0108a0a:	8b 15 80 8a 12 c0    	mov    0xc0128a80,%edx
c0108a10:	a1 84 8a 12 c0       	mov    0xc0128a84,%eax
c0108a15:	39 c2                	cmp    %eax,%edx
c0108a17:	0f 8c ab 00 00 00    	jl     c0108ac8 <get_pid+0xf2>
    {
    inside:
c0108a1d:	90                   	nop
        next_safe = MAX_PID;
c0108a1e:	c7 05 84 8a 12 c0 00 	movl   $0x2000,0xc0128a84
c0108a25:	20 00 00 
    repeat:
        le = list;
c0108a28:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0108a2b:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while ((le = list_next(le)) != list)
c0108a2e:	eb 7d                	jmp    c0108aad <get_pid+0xd7>
        {
            proc = le2proc(le, list_link);
c0108a30:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108a33:	83 e8 58             	sub    $0x58,%eax
c0108a36:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (proc->pid == last_pid)
c0108a39:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108a3c:	8b 50 04             	mov    0x4(%eax),%edx
c0108a3f:	a1 80 8a 12 c0       	mov    0xc0128a80,%eax
c0108a44:	39 c2                	cmp    %eax,%edx
c0108a46:	75 3c                	jne    c0108a84 <get_pid+0xae>
            {
                if (++last_pid >= next_safe)
c0108a48:	a1 80 8a 12 c0       	mov    0xc0128a80,%eax
c0108a4d:	40                   	inc    %eax
c0108a4e:	a3 80 8a 12 c0       	mov    %eax,0xc0128a80
c0108a53:	8b 15 80 8a 12 c0    	mov    0xc0128a80,%edx
c0108a59:	a1 84 8a 12 c0       	mov    0xc0128a84,%eax
c0108a5e:	39 c2                	cmp    %eax,%edx
c0108a60:	7c 4b                	jl     c0108aad <get_pid+0xd7>
                {
                    if (last_pid >= MAX_PID)
c0108a62:	a1 80 8a 12 c0       	mov    0xc0128a80,%eax
c0108a67:	3d ff 1f 00 00       	cmp    $0x1fff,%eax
c0108a6c:	7e 0a                	jle    c0108a78 <get_pid+0xa2>
                    {
                        last_pid = 1;
c0108a6e:	c7 05 80 8a 12 c0 01 	movl   $0x1,0xc0128a80
c0108a75:	00 00 00 
                    }
                    next_safe = MAX_PID;
c0108a78:	c7 05 84 8a 12 c0 00 	movl   $0x2000,0xc0128a84
c0108a7f:	20 00 00 
                    goto repeat;
c0108a82:	eb a4                	jmp    c0108a28 <get_pid+0x52>
                }
            }
            else if (proc->pid > last_pid && next_safe > proc->pid)
c0108a84:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108a87:	8b 50 04             	mov    0x4(%eax),%edx
c0108a8a:	a1 80 8a 12 c0       	mov    0xc0128a80,%eax
c0108a8f:	39 c2                	cmp    %eax,%edx
c0108a91:	7e 1a                	jle    c0108aad <get_pid+0xd7>
c0108a93:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108a96:	8b 50 04             	mov    0x4(%eax),%edx
c0108a99:	a1 84 8a 12 c0       	mov    0xc0128a84,%eax
c0108a9e:	39 c2                	cmp    %eax,%edx
c0108aa0:	7d 0b                	jge    c0108aad <get_pid+0xd7>
            {
                next_safe = proc->pid;
c0108aa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108aa5:	8b 40 04             	mov    0x4(%eax),%eax
c0108aa8:	a3 84 8a 12 c0       	mov    %eax,0xc0128a84
c0108aad:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108ab0:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108ab3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108ab6:	8b 40 04             	mov    0x4(%eax),%eax
        while ((le = list_next(le)) != list)
c0108ab9:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0108abc:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108abf:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c0108ac2:	0f 85 68 ff ff ff    	jne    c0108a30 <get_pid+0x5a>
            }
        }
    }
    return last_pid;
c0108ac8:	a1 80 8a 12 c0       	mov    0xc0128a80,%eax
}
c0108acd:	c9                   	leave  
c0108ace:	c3                   	ret    

c0108acf <proc_run>:

// proc_run - make process "proc" running on cpu
// NOTE: before call switch_to, should load  base addr of "proc"'s new PDT
void proc_run(struct proc_struct *proc)
{
c0108acf:	f3 0f 1e fb          	endbr32 
c0108ad3:	55                   	push   %ebp
c0108ad4:	89 e5                	mov    %esp,%ebp
c0108ad6:	83 ec 28             	sub    $0x28,%esp
    if (proc != current)
c0108ad9:	a1 28 c0 12 c0       	mov    0xc012c028,%eax
c0108ade:	39 45 08             	cmp    %eax,0x8(%ebp)
c0108ae1:	74 64                	je     c0108b47 <proc_run+0x78>
    {
        bool intr_flag;
        struct proc_struct *prev = current, *next = proc;
c0108ae3:	a1 28 c0 12 c0       	mov    0xc012c028,%eax
c0108ae8:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108aeb:	8b 45 08             	mov    0x8(%ebp),%eax
c0108aee:	89 45 f0             	mov    %eax,-0x10(%ebp)
        local_intr_save(intr_flag);
c0108af1:	e8 3f fc ff ff       	call   c0108735 <__intr_save>
c0108af6:	89 45 ec             	mov    %eax,-0x14(%ebp)
        {
            current = proc;
c0108af9:	8b 45 08             	mov    0x8(%ebp),%eax
c0108afc:	a3 28 c0 12 c0       	mov    %eax,0xc012c028
            load_esp0(next->kstack + KSTACKSIZE);
c0108b01:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108b04:	8b 40 0c             	mov    0xc(%eax),%eax
c0108b07:	05 00 20 00 00       	add    $0x2000,%eax
c0108b0c:	89 04 24             	mov    %eax,(%esp)
c0108b0f:	e8 9f a8 ff ff       	call   c01033b3 <load_esp0>
            lcr3(next->cr3);
c0108b14:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108b17:	8b 40 40             	mov    0x40(%eax),%eax
c0108b1a:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("mov %0, %%cr3" :: "r" (cr3) : "memory");
c0108b1d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108b20:	0f 22 d8             	mov    %eax,%cr3
}
c0108b23:	90                   	nop
            switch_to(&(prev->context), &(next->context));
c0108b24:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108b27:	8d 50 1c             	lea    0x1c(%eax),%edx
c0108b2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108b2d:	83 c0 1c             	add    $0x1c,%eax
c0108b30:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108b34:	89 04 24             	mov    %eax,(%esp)
c0108b37:	e8 c2 fb ff ff       	call   c01086fe <switch_to>
        }
        local_intr_restore(intr_flag);
c0108b3c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108b3f:	89 04 24             	mov    %eax,(%esp)
c0108b42:	e8 18 fc ff ff       	call   c010875f <__intr_restore>
    }
}
c0108b47:	90                   	nop
c0108b48:	c9                   	leave  
c0108b49:	c3                   	ret    

c0108b4a <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void)
{
c0108b4a:	f3 0f 1e fb          	endbr32 
c0108b4e:	55                   	push   %ebp
c0108b4f:	89 e5                	mov    %esp,%ebp
c0108b51:	83 ec 18             	sub    $0x18,%esp
    forkrets(current->tf);
c0108b54:	a1 28 c0 12 c0       	mov    0xc012c028,%eax
c0108b59:	8b 40 3c             	mov    0x3c(%eax),%eax
c0108b5c:	89 04 24             	mov    %eax,(%esp)
c0108b5f:	e8 76 a6 ff ff       	call   c01031da <forkrets>
}
c0108b64:	90                   	nop
c0108b65:	c9                   	leave  
c0108b66:	c3                   	ret    

c0108b67 <hash_proc>:

// hash_proc - add proc into proc hash_list
static void
hash_proc(struct proc_struct *proc)
{
c0108b67:	f3 0f 1e fb          	endbr32 
c0108b6b:	55                   	push   %ebp
c0108b6c:	89 e5                	mov    %esp,%ebp
c0108b6e:	53                   	push   %ebx
c0108b6f:	83 ec 34             	sub    $0x34,%esp
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
c0108b72:	8b 45 08             	mov    0x8(%ebp),%eax
c0108b75:	8d 58 60             	lea    0x60(%eax),%ebx
c0108b78:	8b 45 08             	mov    0x8(%ebp),%eax
c0108b7b:	8b 40 04             	mov    0x4(%eax),%eax
c0108b7e:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
c0108b85:	00 
c0108b86:	89 04 24             	mov    %eax,(%esp)
c0108b89:	e8 58 13 00 00       	call   c0109ee6 <hash32>
c0108b8e:	c1 e0 03             	shl    $0x3,%eax
c0108b91:	05 40 c0 12 c0       	add    $0xc012c040,%eax
c0108b96:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108b99:	89 5d f0             	mov    %ebx,-0x10(%ebp)
c0108b9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108b9f:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108ba2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108ba5:	89 45 e8             	mov    %eax,-0x18(%ebp)
    __list_add(elm, listelm, listelm->next);
c0108ba8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108bab:	8b 40 04             	mov    0x4(%eax),%eax
c0108bae:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0108bb1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0108bb4:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0108bb7:	89 55 e0             	mov    %edx,-0x20(%ebp)
c0108bba:	89 45 dc             	mov    %eax,-0x24(%ebp)
    prev->next = next->prev = elm;
c0108bbd:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108bc0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0108bc3:	89 10                	mov    %edx,(%eax)
c0108bc5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108bc8:	8b 10                	mov    (%eax),%edx
c0108bca:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108bcd:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0108bd0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108bd3:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0108bd6:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0108bd9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108bdc:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0108bdf:	89 10                	mov    %edx,(%eax)
}
c0108be1:	90                   	nop
}
c0108be2:	90                   	nop
}
c0108be3:	90                   	nop
}
c0108be4:	90                   	nop
c0108be5:	83 c4 34             	add    $0x34,%esp
c0108be8:	5b                   	pop    %ebx
c0108be9:	5d                   	pop    %ebp
c0108bea:	c3                   	ret    

c0108beb <find_proc>:

// find_proc - find proc frome proc hash_list according to pid
struct proc_struct *
find_proc(int pid)
{
c0108beb:	f3 0f 1e fb          	endbr32 
c0108bef:	55                   	push   %ebp
c0108bf0:	89 e5                	mov    %esp,%ebp
c0108bf2:	83 ec 28             	sub    $0x28,%esp
    if (0 < pid && pid < MAX_PID)
c0108bf5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0108bf9:	7e 5f                	jle    c0108c5a <find_proc+0x6f>
c0108bfb:	81 7d 08 ff 1f 00 00 	cmpl   $0x1fff,0x8(%ebp)
c0108c02:	7f 56                	jg     c0108c5a <find_proc+0x6f>
    {
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
c0108c04:	8b 45 08             	mov    0x8(%ebp),%eax
c0108c07:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
c0108c0e:	00 
c0108c0f:	89 04 24             	mov    %eax,(%esp)
c0108c12:	e8 cf 12 00 00       	call   c0109ee6 <hash32>
c0108c17:	c1 e0 03             	shl    $0x3,%eax
c0108c1a:	05 40 c0 12 c0       	add    $0xc012c040,%eax
c0108c1f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108c22:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108c25:	89 45 f4             	mov    %eax,-0xc(%ebp)
        while ((le = list_next(le)) != list)
c0108c28:	eb 19                	jmp    c0108c43 <find_proc+0x58>
        {
            struct proc_struct *proc = le2proc(le, hash_link);
c0108c2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108c2d:	83 e8 60             	sub    $0x60,%eax
c0108c30:	89 45 ec             	mov    %eax,-0x14(%ebp)
            if (proc->pid == pid)
c0108c33:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108c36:	8b 40 04             	mov    0x4(%eax),%eax
c0108c39:	39 45 08             	cmp    %eax,0x8(%ebp)
c0108c3c:	75 05                	jne    c0108c43 <find_proc+0x58>
            {
                return proc;
c0108c3e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108c41:	eb 1c                	jmp    c0108c5f <find_proc+0x74>
c0108c43:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108c46:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return listelm->next;
c0108c49:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108c4c:	8b 40 04             	mov    0x4(%eax),%eax
        while ((le = list_next(le)) != list)
c0108c4f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108c52:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108c55:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0108c58:	75 d0                	jne    c0108c2a <find_proc+0x3f>
            }
        }
    }
    return NULL;
c0108c5a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108c5f:	c9                   	leave  
c0108c60:	c3                   	ret    

c0108c61 <kernel_thread>:

// kernel_thread - create a kernel thread using "fn" function
// NOTE: the contents of temp trapframe tf will be copied to
//       proc->tf in do_fork-->copy_thread function
int kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags)
{
c0108c61:	f3 0f 1e fb          	endbr32 
c0108c65:	55                   	push   %ebp
c0108c66:	89 e5                	mov    %esp,%ebp
c0108c68:	83 ec 68             	sub    $0x68,%esp
    struct trapframe tf;
    memset(&tf, 0, sizeof(struct trapframe));
c0108c6b:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
c0108c72:	00 
c0108c73:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0108c7a:	00 
c0108c7b:	8d 45 ac             	lea    -0x54(%ebp),%eax
c0108c7e:	89 04 24             	mov    %eax,(%esp)
c0108c81:	e8 3c 0a 00 00       	call   c01096c2 <memset>
    tf.tf_cs = KERNEL_CS;
c0108c86:	66 c7 45 e8 08 00    	movw   $0x8,-0x18(%ebp)
    tf.tf_ds = tf.tf_es = tf.tf_ss = KERNEL_DS;
c0108c8c:	66 c7 45 f4 10 00    	movw   $0x10,-0xc(%ebp)
c0108c92:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0108c96:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
c0108c9a:	0f b7 45 d4          	movzwl -0x2c(%ebp),%eax
c0108c9e:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
    tf.tf_regs.reg_ebx = (uint32_t)fn;
c0108ca2:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ca5:	89 45 bc             	mov    %eax,-0x44(%ebp)
    tf.tf_regs.reg_edx = (uint32_t)arg;
c0108ca8:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108cab:	89 45 c0             	mov    %eax,-0x40(%ebp)
    tf.tf_eip = (uint32_t)kernel_thread_entry;
c0108cae:	b8 f5 86 10 c0       	mov    $0xc01086f5,%eax
c0108cb3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
c0108cb6:	8b 45 10             	mov    0x10(%ebp),%eax
c0108cb9:	0d 00 01 00 00       	or     $0x100,%eax
c0108cbe:	89 c2                	mov    %eax,%edx
c0108cc0:	8d 45 ac             	lea    -0x54(%ebp),%eax
c0108cc3:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108cc7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0108cce:	00 
c0108ccf:	89 14 24             	mov    %edx,(%esp)
c0108cd2:	e8 98 01 00 00       	call   c0108e6f <do_fork>
}
c0108cd7:	c9                   	leave  
c0108cd8:	c3                   	ret    

c0108cd9 <setup_kstack>:

// setup_kstack - alloc pages with size KSTACKPAGE as process kernel stack
static int
setup_kstack(struct proc_struct *proc)
{
c0108cd9:	f3 0f 1e fb          	endbr32 
c0108cdd:	55                   	push   %ebp
c0108cde:	89 e5                	mov    %esp,%ebp
c0108ce0:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = alloc_pages(KSTACKPAGE);
c0108ce3:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0108cea:	e8 20 a8 ff ff       	call   c010350f <alloc_pages>
c0108cef:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL)
c0108cf2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108cf6:	74 1a                	je     c0108d12 <setup_kstack+0x39>
    {
        proc->kstack = (uintptr_t)page2kva(page);
c0108cf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108cfb:	89 04 24             	mov    %eax,(%esp)
c0108cfe:	e8 df fa ff ff       	call   c01087e2 <page2kva>
c0108d03:	89 c2                	mov    %eax,%edx
c0108d05:	8b 45 08             	mov    0x8(%ebp),%eax
c0108d08:	89 50 0c             	mov    %edx,0xc(%eax)
        return 0;
c0108d0b:	b8 00 00 00 00       	mov    $0x0,%eax
c0108d10:	eb 05                	jmp    c0108d17 <setup_kstack+0x3e>
    }
    return -E_NO_MEM;
c0108d12:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
}
c0108d17:	c9                   	leave  
c0108d18:	c3                   	ret    

c0108d19 <put_kstack>:

// put_kstack - free the memory space of process kernel stack
static void
put_kstack(struct proc_struct *proc)
{
c0108d19:	f3 0f 1e fb          	endbr32 
c0108d1d:	55                   	push   %ebp
c0108d1e:	89 e5                	mov    %esp,%ebp
c0108d20:	83 ec 18             	sub    $0x18,%esp
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
c0108d23:	8b 45 08             	mov    0x8(%ebp),%eax
c0108d26:	8b 40 0c             	mov    0xc(%eax),%eax
c0108d29:	89 04 24             	mov    %eax,(%esp)
c0108d2c:	e8 05 fb ff ff       	call   c0108836 <kva2page>
c0108d31:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0108d38:	00 
c0108d39:	89 04 24             	mov    %eax,(%esp)
c0108d3c:	e8 3d a8 ff ff       	call   c010357e <free_pages>
}
c0108d41:	90                   	nop
c0108d42:	c9                   	leave  
c0108d43:	c3                   	ret    

c0108d44 <copy_mm>:

// copy_mm - process "proc" duplicate OR share process "current"'s mm according clone_flags
//         - if clone_flags & CLONE_VM, then "share" ; else "duplicate"
static int
copy_mm(uint32_t clone_flags, struct proc_struct *proc)
{
c0108d44:	f3 0f 1e fb          	endbr32 
c0108d48:	55                   	push   %ebp
c0108d49:	89 e5                	mov    %esp,%ebp
c0108d4b:	83 ec 18             	sub    $0x18,%esp
    assert(current->mm == NULL);
c0108d4e:	a1 28 c0 12 c0       	mov    0xc012c028,%eax
c0108d53:	8b 40 18             	mov    0x18(%eax),%eax
c0108d56:	85 c0                	test   %eax,%eax
c0108d58:	74 24                	je     c0108d7e <copy_mm+0x3a>
c0108d5a:	c7 44 24 0c ec bf 10 	movl   $0xc010bfec,0xc(%esp)
c0108d61:	c0 
c0108d62:	c7 44 24 08 00 c0 10 	movl   $0xc010c000,0x8(%esp)
c0108d69:	c0 
c0108d6a:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
c0108d71:	00 
c0108d72:	c7 04 24 15 c0 10 c0 	movl   $0xc010c015,(%esp)
c0108d79:	e8 bf 76 ff ff       	call   c010043d <__panic>
    /* do nothing in this project */
    return 0;
c0108d7e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108d83:	c9                   	leave  
c0108d84:	c3                   	ret    

c0108d85 <copy_thread>:

// copy_thread - setup the trapframe on the  process's kernel stack top and
//             - setup the kernel entry point and stack of process
static void
copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf)
{
c0108d85:	f3 0f 1e fb          	endbr32 
c0108d89:	55                   	push   %ebp
c0108d8a:	89 e5                	mov    %esp,%ebp
c0108d8c:	57                   	push   %edi
c0108d8d:	56                   	push   %esi
c0108d8e:	53                   	push   %ebx
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
c0108d8f:	8b 45 08             	mov    0x8(%ebp),%eax
c0108d92:	8b 40 0c             	mov    0xc(%eax),%eax
c0108d95:	05 b4 1f 00 00       	add    $0x1fb4,%eax
c0108d9a:	89 c2                	mov    %eax,%edx
c0108d9c:	8b 45 08             	mov    0x8(%ebp),%eax
c0108d9f:	89 50 3c             	mov    %edx,0x3c(%eax)
    *(proc->tf) = *tf;
c0108da2:	8b 45 08             	mov    0x8(%ebp),%eax
c0108da5:	8b 40 3c             	mov    0x3c(%eax),%eax
c0108da8:	8b 55 10             	mov    0x10(%ebp),%edx
c0108dab:	bb 4c 00 00 00       	mov    $0x4c,%ebx
c0108db0:	89 c1                	mov    %eax,%ecx
c0108db2:	83 e1 01             	and    $0x1,%ecx
c0108db5:	85 c9                	test   %ecx,%ecx
c0108db7:	74 0c                	je     c0108dc5 <copy_thread+0x40>
c0108db9:	0f b6 0a             	movzbl (%edx),%ecx
c0108dbc:	88 08                	mov    %cl,(%eax)
c0108dbe:	8d 40 01             	lea    0x1(%eax),%eax
c0108dc1:	8d 52 01             	lea    0x1(%edx),%edx
c0108dc4:	4b                   	dec    %ebx
c0108dc5:	89 c1                	mov    %eax,%ecx
c0108dc7:	83 e1 02             	and    $0x2,%ecx
c0108dca:	85 c9                	test   %ecx,%ecx
c0108dcc:	74 0f                	je     c0108ddd <copy_thread+0x58>
c0108dce:	0f b7 0a             	movzwl (%edx),%ecx
c0108dd1:	66 89 08             	mov    %cx,(%eax)
c0108dd4:	8d 40 02             	lea    0x2(%eax),%eax
c0108dd7:	8d 52 02             	lea    0x2(%edx),%edx
c0108dda:	83 eb 02             	sub    $0x2,%ebx
c0108ddd:	89 df                	mov    %ebx,%edi
c0108ddf:	83 e7 fc             	and    $0xfffffffc,%edi
c0108de2:	b9 00 00 00 00       	mov    $0x0,%ecx
c0108de7:	8b 34 0a             	mov    (%edx,%ecx,1),%esi
c0108dea:	89 34 08             	mov    %esi,(%eax,%ecx,1)
c0108ded:	83 c1 04             	add    $0x4,%ecx
c0108df0:	39 f9                	cmp    %edi,%ecx
c0108df2:	72 f3                	jb     c0108de7 <copy_thread+0x62>
c0108df4:	01 c8                	add    %ecx,%eax
c0108df6:	01 ca                	add    %ecx,%edx
c0108df8:	b9 00 00 00 00       	mov    $0x0,%ecx
c0108dfd:	89 de                	mov    %ebx,%esi
c0108dff:	83 e6 02             	and    $0x2,%esi
c0108e02:	85 f6                	test   %esi,%esi
c0108e04:	74 0b                	je     c0108e11 <copy_thread+0x8c>
c0108e06:	0f b7 34 0a          	movzwl (%edx,%ecx,1),%esi
c0108e0a:	66 89 34 08          	mov    %si,(%eax,%ecx,1)
c0108e0e:	83 c1 02             	add    $0x2,%ecx
c0108e11:	83 e3 01             	and    $0x1,%ebx
c0108e14:	85 db                	test   %ebx,%ebx
c0108e16:	74 07                	je     c0108e1f <copy_thread+0x9a>
c0108e18:	0f b6 14 0a          	movzbl (%edx,%ecx,1),%edx
c0108e1c:	88 14 08             	mov    %dl,(%eax,%ecx,1)
    proc->tf->tf_regs.reg_eax = 0;
c0108e1f:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e22:	8b 40 3c             	mov    0x3c(%eax),%eax
c0108e25:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
    proc->tf->tf_esp = esp;
c0108e2c:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e2f:	8b 40 3c             	mov    0x3c(%eax),%eax
c0108e32:	8b 55 0c             	mov    0xc(%ebp),%edx
c0108e35:	89 50 44             	mov    %edx,0x44(%eax)
    proc->tf->tf_eflags |= FL_IF;
c0108e38:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e3b:	8b 40 3c             	mov    0x3c(%eax),%eax
c0108e3e:	8b 50 40             	mov    0x40(%eax),%edx
c0108e41:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e44:	8b 40 3c             	mov    0x3c(%eax),%eax
c0108e47:	81 ca 00 02 00 00    	or     $0x200,%edx
c0108e4d:	89 50 40             	mov    %edx,0x40(%eax)

    proc->context.eip = (uintptr_t)forkret;
c0108e50:	ba 4a 8b 10 c0       	mov    $0xc0108b4a,%edx
c0108e55:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e58:	89 50 1c             	mov    %edx,0x1c(%eax)
    proc->context.esp = (uintptr_t)(proc->tf);
c0108e5b:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e5e:	8b 40 3c             	mov    0x3c(%eax),%eax
c0108e61:	89 c2                	mov    %eax,%edx
c0108e63:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e66:	89 50 20             	mov    %edx,0x20(%eax)
}
c0108e69:	90                   	nop
c0108e6a:	5b                   	pop    %ebx
c0108e6b:	5e                   	pop    %esi
c0108e6c:	5f                   	pop    %edi
c0108e6d:	5d                   	pop    %ebp
c0108e6e:	c3                   	ret    

c0108e6f <do_fork>:
 * @clone_flags: used to guide how to clone the child process
 * @stack:       the parent's user stack pointer. if stack==0, It means to fork a kernel thread.
 * @tf:          the trapframe info, which will be copied to child process's proc->tf
 */
int do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf)
{
c0108e6f:	f3 0f 1e fb          	endbr32 
c0108e73:	55                   	push   %ebp
c0108e74:	89 e5                	mov    %esp,%ebp
c0108e76:	83 ec 48             	sub    $0x48,%esp
    int ret = -E_NO_FREE_PROC;
c0108e79:	c7 45 f4 fb ff ff ff 	movl   $0xfffffffb,-0xc(%ebp)
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS)
c0108e80:	a1 40 e0 12 c0       	mov    0xc012e040,%eax
c0108e85:	3d ff 0f 00 00       	cmp    $0xfff,%eax
c0108e8a:	0f 8f 0d 01 00 00    	jg     c0108f9d <do_fork+0x12e>
    {
        goto fork_out;
    }
    ret = -E_NO_MEM;
c0108e90:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)
    //    3. call copy_mm to dup OR share mm according clone_flag
    //    4. call copy_thread to setup tf & context in proc_struct
    //    5. insert proc_struct into hash_list && proc_list
    //    6. call wakeup_proc to make the new child process RUNNABLE
    //    7. set ret vaule using child proc's pid
    if ((proc = alloc_proc()) == NULL)
c0108e97:	e8 e4 f9 ff ff       	call   c0108880 <alloc_proc>
c0108e9c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108e9f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0108ea3:	0f 84 f7 00 00 00    	je     c0108fa0 <do_fork+0x131>
    {
        goto fork_out;
    }

    proc->parent = current;
c0108ea9:	8b 15 28 c0 12 c0    	mov    0xc012c028,%edx
c0108eaf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108eb2:	89 50 14             	mov    %edx,0x14(%eax)

    if (setup_kstack(proc) != 0)
c0108eb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108eb8:	89 04 24             	mov    %eax,(%esp)
c0108ebb:	e8 19 fe ff ff       	call   c0108cd9 <setup_kstack>
c0108ec0:	85 c0                	test   %eax,%eax
c0108ec2:	0f 85 f0 00 00 00    	jne    c0108fb8 <do_fork+0x149>
    {
        goto bad_fork_cleanup_proc;
    }
    if (copy_mm(clone_flags, proc) != 0)
c0108ec8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108ecb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108ecf:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ed2:	89 04 24             	mov    %eax,(%esp)
c0108ed5:	e8 6a fe ff ff       	call   c0108d44 <copy_mm>
c0108eda:	85 c0                	test   %eax,%eax
c0108edc:	0f 85 c4 00 00 00    	jne    c0108fa6 <do_fork+0x137>
    {
        goto bad_fork_cleanup_kstack;
    }
    copy_thread(proc, stack, tf);
c0108ee2:	8b 45 10             	mov    0x10(%ebp),%eax
c0108ee5:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108ee9:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108eec:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108ef0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108ef3:	89 04 24             	mov    %eax,(%esp)
c0108ef6:	e8 8a fe ff ff       	call   c0108d85 <copy_thread>

    bool intr_flag;
    local_intr_save(intr_flag);
c0108efb:	e8 35 f8 ff ff       	call   c0108735 <__intr_save>
c0108f00:	89 45 ec             	mov    %eax,-0x14(%ebp)
    {
        proc->pid = get_pid();
c0108f03:	e8 ce fa ff ff       	call   c01089d6 <get_pid>
c0108f08:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0108f0b:	89 42 04             	mov    %eax,0x4(%edx)
        hash_proc(proc);
c0108f0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108f11:	89 04 24             	mov    %eax,(%esp)
c0108f14:	e8 4e fc ff ff       	call   c0108b67 <hash_proc>
        list_add(&proc_list, &(proc->list_link));
c0108f19:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108f1c:	83 c0 58             	add    $0x58,%eax
c0108f1f:	c7 45 e8 58 e1 12 c0 	movl   $0xc012e158,-0x18(%ebp)
c0108f26:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0108f29:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108f2c:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0108f2f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108f32:	89 45 dc             	mov    %eax,-0x24(%ebp)
    __list_add(elm, listelm, listelm->next);
c0108f35:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108f38:	8b 40 04             	mov    0x4(%eax),%eax
c0108f3b:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0108f3e:	89 55 d8             	mov    %edx,-0x28(%ebp)
c0108f41:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0108f44:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0108f47:	89 45 d0             	mov    %eax,-0x30(%ebp)
    prev->next = next->prev = elm;
c0108f4a:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0108f4d:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0108f50:	89 10                	mov    %edx,(%eax)
c0108f52:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0108f55:	8b 10                	mov    (%eax),%edx
c0108f57:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0108f5a:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0108f5d:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108f60:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0108f63:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0108f66:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108f69:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0108f6c:	89 10                	mov    %edx,(%eax)
}
c0108f6e:	90                   	nop
}
c0108f6f:	90                   	nop
}
c0108f70:	90                   	nop
        nr_process++;
c0108f71:	a1 40 e0 12 c0       	mov    0xc012e040,%eax
c0108f76:	40                   	inc    %eax
c0108f77:	a3 40 e0 12 c0       	mov    %eax,0xc012e040
    }
    local_intr_restore(intr_flag);
c0108f7c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108f7f:	89 04 24             	mov    %eax,(%esp)
c0108f82:	e8 d8 f7 ff ff       	call   c010875f <__intr_restore>

    wakeup_proc(proc);
c0108f87:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108f8a:	89 04 24             	mov    %eax,(%esp)
c0108f8d:	e8 d4 02 00 00       	call   c0109266 <wakeup_proc>

    ret = proc->pid;
c0108f92:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108f95:	8b 40 04             	mov    0x4(%eax),%eax
c0108f98:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108f9b:	eb 04                	jmp    c0108fa1 <do_fork+0x132>
        goto fork_out;
c0108f9d:	90                   	nop
c0108f9e:	eb 01                	jmp    c0108fa1 <do_fork+0x132>
        goto fork_out;
c0108fa0:	90                   	nop
fork_out:
    return ret;
c0108fa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108fa4:	eb 20                	jmp    c0108fc6 <do_fork+0x157>
        goto bad_fork_cleanup_kstack;
c0108fa6:	90                   	nop
c0108fa7:	f3 0f 1e fb          	endbr32 

bad_fork_cleanup_kstack:
    put_kstack(proc);
c0108fab:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108fae:	89 04 24             	mov    %eax,(%esp)
c0108fb1:	e8 63 fd ff ff       	call   c0108d19 <put_kstack>
c0108fb6:	eb 01                	jmp    c0108fb9 <do_fork+0x14a>
        goto bad_fork_cleanup_proc;
c0108fb8:	90                   	nop
bad_fork_cleanup_proc:
    kfree(proc);
c0108fb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108fbc:	89 04 24             	mov    %eax,(%esp)
c0108fbf:	e8 c5 dc ff ff       	call   c0106c89 <kfree>
    goto fork_out;
c0108fc4:	eb db                	jmp    c0108fa1 <do_fork+0x132>
}
c0108fc6:	c9                   	leave  
c0108fc7:	c3                   	ret    

c0108fc8 <do_exit>:
// do_exit - called by sys_exit
//   1. call exit_mmap & put_pgdir & mm_destroy to free the almost all memory space of process
//   2. set process' state as PROC_ZOMBIE, then call wakeup_proc(parent) to ask parent reclaim itself.
//   3. call scheduler to switch to other process
int do_exit(int error_code)
{
c0108fc8:	f3 0f 1e fb          	endbr32 
c0108fcc:	55                   	push   %ebp
c0108fcd:	89 e5                	mov    %esp,%ebp
c0108fcf:	83 ec 18             	sub    $0x18,%esp
    panic("process exit!!.\n");
c0108fd2:	c7 44 24 08 29 c0 10 	movl   $0xc010c029,0x8(%esp)
c0108fd9:	c0 
c0108fda:	c7 44 24 04 7e 01 00 	movl   $0x17e,0x4(%esp)
c0108fe1:	00 
c0108fe2:	c7 04 24 15 c0 10 c0 	movl   $0xc010c015,(%esp)
c0108fe9:	e8 4f 74 ff ff       	call   c010043d <__panic>

c0108fee <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg)
{
c0108fee:	f3 0f 1e fb          	endbr32 
c0108ff2:	55                   	push   %ebp
c0108ff3:	89 e5                	mov    %esp,%ebp
c0108ff5:	83 ec 18             	sub    $0x18,%esp
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
c0108ff8:	a1 28 c0 12 c0       	mov    0xc012c028,%eax
c0108ffd:	89 04 24             	mov    %eax,(%esp)
c0109000:	e8 8b f9 ff ff       	call   c0108990 <get_proc_name>
c0109005:	8b 15 28 c0 12 c0    	mov    0xc012c028,%edx
c010900b:	8b 52 04             	mov    0x4(%edx),%edx
c010900e:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109012:	89 54 24 04          	mov    %edx,0x4(%esp)
c0109016:	c7 04 24 3c c0 10 c0 	movl   $0xc010c03c,(%esp)
c010901d:	e8 af 72 ff ff       	call   c01002d1 <cprintf>
    cprintf("To U: \"%s\".\n", (const char *)arg);
c0109022:	8b 45 08             	mov    0x8(%ebp),%eax
c0109025:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109029:	c7 04 24 62 c0 10 c0 	movl   $0xc010c062,(%esp)
c0109030:	e8 9c 72 ff ff       	call   c01002d1 <cprintf>
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
c0109035:	c7 04 24 6f c0 10 c0 	movl   $0xc010c06f,(%esp)
c010903c:	e8 90 72 ff ff       	call   c01002d1 <cprintf>
    return 0;
c0109041:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109046:	c9                   	leave  
c0109047:	c3                   	ret    

c0109048 <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and
//           - create the second kernel thread init_main
void proc_init(void)
{
c0109048:	f3 0f 1e fb          	endbr32 
c010904c:	55                   	push   %ebp
c010904d:	89 e5                	mov    %esp,%ebp
c010904f:	83 ec 28             	sub    $0x28,%esp
c0109052:	c7 45 ec 58 e1 12 c0 	movl   $0xc012e158,-0x14(%ebp)
    elm->prev = elm->next = elm;
c0109059:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010905c:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010905f:	89 50 04             	mov    %edx,0x4(%eax)
c0109062:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109065:	8b 50 04             	mov    0x4(%eax),%edx
c0109068:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010906b:	89 10                	mov    %edx,(%eax)
}
c010906d:	90                   	nop
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i++)
c010906e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0109075:	eb 26                	jmp    c010909d <proc_init+0x55>
    {
        list_init(hash_list + i);
c0109077:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010907a:	c1 e0 03             	shl    $0x3,%eax
c010907d:	05 40 c0 12 c0       	add    $0xc012c040,%eax
c0109082:	89 45 e8             	mov    %eax,-0x18(%ebp)
    elm->prev = elm->next = elm;
c0109085:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109088:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010908b:	89 50 04             	mov    %edx,0x4(%eax)
c010908e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109091:	8b 50 04             	mov    0x4(%eax),%edx
c0109094:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109097:	89 10                	mov    %edx,(%eax)
}
c0109099:	90                   	nop
    for (i = 0; i < HASH_LIST_SIZE; i++)
c010909a:	ff 45 f4             	incl   -0xc(%ebp)
c010909d:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
c01090a4:	7e d1                	jle    c0109077 <proc_init+0x2f>
    }

    if ((idleproc = alloc_proc()) == NULL)
c01090a6:	e8 d5 f7 ff ff       	call   c0108880 <alloc_proc>
c01090ab:	a3 20 c0 12 c0       	mov    %eax,0xc012c020
c01090b0:	a1 20 c0 12 c0       	mov    0xc012c020,%eax
c01090b5:	85 c0                	test   %eax,%eax
c01090b7:	75 1c                	jne    c01090d5 <proc_init+0x8d>
    {
        panic("cannot alloc idleproc.\n");
c01090b9:	c7 44 24 08 8b c0 10 	movl   $0xc010c08b,0x8(%esp)
c01090c0:	c0 
c01090c1:	c7 44 24 04 99 01 00 	movl   $0x199,0x4(%esp)
c01090c8:	00 
c01090c9:	c7 04 24 15 c0 10 c0 	movl   $0xc010c015,(%esp)
c01090d0:	e8 68 73 ff ff       	call   c010043d <__panic>
    }

    idleproc->pid = 0;
c01090d5:	a1 20 c0 12 c0       	mov    0xc012c020,%eax
c01090da:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    idleproc->state = PROC_RUNNABLE;
c01090e1:	a1 20 c0 12 c0       	mov    0xc012c020,%eax
c01090e6:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
    idleproc->kstack = (uintptr_t)bootstack;
c01090ec:	a1 20 c0 12 c0       	mov    0xc012c020,%eax
c01090f1:	ba 00 60 12 c0       	mov    $0xc0126000,%edx
c01090f6:	89 50 0c             	mov    %edx,0xc(%eax)
    idleproc->need_resched = 1;
c01090f9:	a1 20 c0 12 c0       	mov    0xc012c020,%eax
c01090fe:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
    set_proc_name(idleproc, "idle");
c0109105:	a1 20 c0 12 c0       	mov    0xc012c020,%eax
c010910a:	c7 44 24 04 a3 c0 10 	movl   $0xc010c0a3,0x4(%esp)
c0109111:	c0 
c0109112:	89 04 24             	mov    %eax,(%esp)
c0109115:	e8 2f f8 ff ff       	call   c0108949 <set_proc_name>
    nr_process++;
c010911a:	a1 40 e0 12 c0       	mov    0xc012e040,%eax
c010911f:	40                   	inc    %eax
c0109120:	a3 40 e0 12 c0       	mov    %eax,0xc012e040

    current = idleproc;
c0109125:	a1 20 c0 12 c0       	mov    0xc012c020,%eax
c010912a:	a3 28 c0 12 c0       	mov    %eax,0xc012c028

    int pid = kernel_thread(init_main, "Hello world!!", 0);
c010912f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0109136:	00 
c0109137:	c7 44 24 04 a8 c0 10 	movl   $0xc010c0a8,0x4(%esp)
c010913e:	c0 
c010913f:	c7 04 24 ee 8f 10 c0 	movl   $0xc0108fee,(%esp)
c0109146:	e8 16 fb ff ff       	call   c0108c61 <kernel_thread>
c010914b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (pid <= 0)
c010914e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0109152:	7f 1c                	jg     c0109170 <proc_init+0x128>
    {
        panic("create init_main failed.\n");
c0109154:	c7 44 24 08 b6 c0 10 	movl   $0xc010c0b6,0x8(%esp)
c010915b:	c0 
c010915c:	c7 44 24 04 a8 01 00 	movl   $0x1a8,0x4(%esp)
c0109163:	00 
c0109164:	c7 04 24 15 c0 10 c0 	movl   $0xc010c015,(%esp)
c010916b:	e8 cd 72 ff ff       	call   c010043d <__panic>
    }

    initproc = find_proc(pid);
c0109170:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109173:	89 04 24             	mov    %eax,(%esp)
c0109176:	e8 70 fa ff ff       	call   c0108beb <find_proc>
c010917b:	a3 24 c0 12 c0       	mov    %eax,0xc012c024
    set_proc_name(initproc, "init");
c0109180:	a1 24 c0 12 c0       	mov    0xc012c024,%eax
c0109185:	c7 44 24 04 d0 c0 10 	movl   $0xc010c0d0,0x4(%esp)
c010918c:	c0 
c010918d:	89 04 24             	mov    %eax,(%esp)
c0109190:	e8 b4 f7 ff ff       	call   c0108949 <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
c0109195:	a1 20 c0 12 c0       	mov    0xc012c020,%eax
c010919a:	85 c0                	test   %eax,%eax
c010919c:	74 0c                	je     c01091aa <proc_init+0x162>
c010919e:	a1 20 c0 12 c0       	mov    0xc012c020,%eax
c01091a3:	8b 40 04             	mov    0x4(%eax),%eax
c01091a6:	85 c0                	test   %eax,%eax
c01091a8:	74 24                	je     c01091ce <proc_init+0x186>
c01091aa:	c7 44 24 0c d8 c0 10 	movl   $0xc010c0d8,0xc(%esp)
c01091b1:	c0 
c01091b2:	c7 44 24 08 00 c0 10 	movl   $0xc010c000,0x8(%esp)
c01091b9:	c0 
c01091ba:	c7 44 24 04 ae 01 00 	movl   $0x1ae,0x4(%esp)
c01091c1:	00 
c01091c2:	c7 04 24 15 c0 10 c0 	movl   $0xc010c015,(%esp)
c01091c9:	e8 6f 72 ff ff       	call   c010043d <__panic>
    assert(initproc != NULL && initproc->pid == 1);
c01091ce:	a1 24 c0 12 c0       	mov    0xc012c024,%eax
c01091d3:	85 c0                	test   %eax,%eax
c01091d5:	74 0d                	je     c01091e4 <proc_init+0x19c>
c01091d7:	a1 24 c0 12 c0       	mov    0xc012c024,%eax
c01091dc:	8b 40 04             	mov    0x4(%eax),%eax
c01091df:	83 f8 01             	cmp    $0x1,%eax
c01091e2:	74 24                	je     c0109208 <proc_init+0x1c0>
c01091e4:	c7 44 24 0c 00 c1 10 	movl   $0xc010c100,0xc(%esp)
c01091eb:	c0 
c01091ec:	c7 44 24 08 00 c0 10 	movl   $0xc010c000,0x8(%esp)
c01091f3:	c0 
c01091f4:	c7 44 24 04 af 01 00 	movl   $0x1af,0x4(%esp)
c01091fb:	00 
c01091fc:	c7 04 24 15 c0 10 c0 	movl   $0xc010c015,(%esp)
c0109203:	e8 35 72 ff ff       	call   c010043d <__panic>
}
c0109208:	90                   	nop
c0109209:	c9                   	leave  
c010920a:	c3                   	ret    

c010920b <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void cpu_idle(void)
{
c010920b:	f3 0f 1e fb          	endbr32 
c010920f:	55                   	push   %ebp
c0109210:	89 e5                	mov    %esp,%ebp
c0109212:	83 ec 08             	sub    $0x8,%esp
    while (1)
    {
        if (current->need_resched)
c0109215:	a1 28 c0 12 c0       	mov    0xc012c028,%eax
c010921a:	8b 40 10             	mov    0x10(%eax),%eax
c010921d:	85 c0                	test   %eax,%eax
c010921f:	74 f4                	je     c0109215 <cpu_idle+0xa>
        {
            schedule();
c0109221:	e8 8e 00 00 00       	call   c01092b4 <schedule>
        if (current->need_resched)
c0109226:	eb ed                	jmp    c0109215 <cpu_idle+0xa>

c0109228 <__intr_save>:
__intr_save(void) {
c0109228:	55                   	push   %ebp
c0109229:	89 e5                	mov    %esp,%ebp
c010922b:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c010922e:	9c                   	pushf  
c010922f:	58                   	pop    %eax
c0109230:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0109233:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0109236:	25 00 02 00 00       	and    $0x200,%eax
c010923b:	85 c0                	test   %eax,%eax
c010923d:	74 0c                	je     c010924b <__intr_save+0x23>
        intr_disable();
c010923f:	e8 c0 8f ff ff       	call   c0102204 <intr_disable>
        return 1;
c0109244:	b8 01 00 00 00       	mov    $0x1,%eax
c0109249:	eb 05                	jmp    c0109250 <__intr_save+0x28>
    return 0;
c010924b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109250:	c9                   	leave  
c0109251:	c3                   	ret    

c0109252 <__intr_restore>:
__intr_restore(bool flag) {
c0109252:	55                   	push   %ebp
c0109253:	89 e5                	mov    %esp,%ebp
c0109255:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0109258:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010925c:	74 05                	je     c0109263 <__intr_restore+0x11>
        intr_enable();
c010925e:	e8 95 8f ff ff       	call   c01021f8 <intr_enable>
}
c0109263:	90                   	nop
c0109264:	c9                   	leave  
c0109265:	c3                   	ret    

c0109266 <wakeup_proc>:
#include <proc.h>
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
c0109266:	f3 0f 1e fb          	endbr32 
c010926a:	55                   	push   %ebp
c010926b:	89 e5                	mov    %esp,%ebp
c010926d:	83 ec 18             	sub    $0x18,%esp
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
c0109270:	8b 45 08             	mov    0x8(%ebp),%eax
c0109273:	8b 00                	mov    (%eax),%eax
c0109275:	83 f8 03             	cmp    $0x3,%eax
c0109278:	74 0a                	je     c0109284 <wakeup_proc+0x1e>
c010927a:	8b 45 08             	mov    0x8(%ebp),%eax
c010927d:	8b 00                	mov    (%eax),%eax
c010927f:	83 f8 02             	cmp    $0x2,%eax
c0109282:	75 24                	jne    c01092a8 <wakeup_proc+0x42>
c0109284:	c7 44 24 0c 28 c1 10 	movl   $0xc010c128,0xc(%esp)
c010928b:	c0 
c010928c:	c7 44 24 08 63 c1 10 	movl   $0xc010c163,0x8(%esp)
c0109293:	c0 
c0109294:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
c010929b:	00 
c010929c:	c7 04 24 78 c1 10 c0 	movl   $0xc010c178,(%esp)
c01092a3:	e8 95 71 ff ff       	call   c010043d <__panic>
    proc->state = PROC_RUNNABLE;
c01092a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01092ab:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
}
c01092b1:	90                   	nop
c01092b2:	c9                   	leave  
c01092b3:	c3                   	ret    

c01092b4 <schedule>:

void
schedule(void) {
c01092b4:	f3 0f 1e fb          	endbr32 
c01092b8:	55                   	push   %ebp
c01092b9:	89 e5                	mov    %esp,%ebp
c01092bb:	83 ec 38             	sub    $0x38,%esp
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
c01092be:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    local_intr_save(intr_flag);
c01092c5:	e8 5e ff ff ff       	call   c0109228 <__intr_save>
c01092ca:	89 45 ec             	mov    %eax,-0x14(%ebp)
    {
        current->need_resched = 0;
c01092cd:	a1 28 c0 12 c0       	mov    0xc012c028,%eax
c01092d2:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
c01092d9:	8b 15 28 c0 12 c0    	mov    0xc012c028,%edx
c01092df:	a1 20 c0 12 c0       	mov    0xc012c020,%eax
c01092e4:	39 c2                	cmp    %eax,%edx
c01092e6:	74 0a                	je     c01092f2 <schedule+0x3e>
c01092e8:	a1 28 c0 12 c0       	mov    0xc012c028,%eax
c01092ed:	83 c0 58             	add    $0x58,%eax
c01092f0:	eb 05                	jmp    c01092f7 <schedule+0x43>
c01092f2:	b8 58 e1 12 c0       	mov    $0xc012e158,%eax
c01092f7:	89 45 e8             	mov    %eax,-0x18(%ebp)
        le = last;
c01092fa:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01092fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109300:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109303:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->next;
c0109306:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109309:	8b 40 04             	mov    0x4(%eax),%eax
        do {
            if ((le = list_next(le)) != &proc_list) {
c010930c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010930f:	81 7d f4 58 e1 12 c0 	cmpl   $0xc012e158,-0xc(%ebp)
c0109316:	74 13                	je     c010932b <schedule+0x77>
                next = le2proc(le, list_link);
c0109318:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010931b:	83 e8 58             	sub    $0x58,%eax
c010931e:	89 45 f0             	mov    %eax,-0x10(%ebp)
                if (next->state == PROC_RUNNABLE) {
c0109321:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109324:	8b 00                	mov    (%eax),%eax
c0109326:	83 f8 02             	cmp    $0x2,%eax
c0109329:	74 0a                	je     c0109335 <schedule+0x81>
                    break;
                }
            }
        } while (le != last);
c010932b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010932e:	3b 45 e8             	cmp    -0x18(%ebp),%eax
c0109331:	75 cd                	jne    c0109300 <schedule+0x4c>
c0109333:	eb 01                	jmp    c0109336 <schedule+0x82>
                    break;
c0109335:	90                   	nop
        if (next == NULL || next->state != PROC_RUNNABLE) {
c0109336:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010933a:	74 0a                	je     c0109346 <schedule+0x92>
c010933c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010933f:	8b 00                	mov    (%eax),%eax
c0109341:	83 f8 02             	cmp    $0x2,%eax
c0109344:	74 08                	je     c010934e <schedule+0x9a>
            next = idleproc;
c0109346:	a1 20 c0 12 c0       	mov    0xc012c020,%eax
c010934b:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        next->runs ++;
c010934e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109351:	8b 40 08             	mov    0x8(%eax),%eax
c0109354:	8d 50 01             	lea    0x1(%eax),%edx
c0109357:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010935a:	89 50 08             	mov    %edx,0x8(%eax)
        if (next != current) {
c010935d:	a1 28 c0 12 c0       	mov    0xc012c028,%eax
c0109362:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0109365:	74 0b                	je     c0109372 <schedule+0xbe>
            proc_run(next);
c0109367:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010936a:	89 04 24             	mov    %eax,(%esp)
c010936d:	e8 5d f7 ff ff       	call   c0108acf <proc_run>
        }
    }
    local_intr_restore(intr_flag);
c0109372:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109375:	89 04 24             	mov    %eax,(%esp)
c0109378:	e8 d5 fe ff ff       	call   c0109252 <__intr_restore>
}
c010937d:	90                   	nop
c010937e:	c9                   	leave  
c010937f:	c3                   	ret    

c0109380 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c0109380:	f3 0f 1e fb          	endbr32 
c0109384:	55                   	push   %ebp
c0109385:	89 e5                	mov    %esp,%ebp
c0109387:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c010938a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c0109391:	eb 03                	jmp    c0109396 <strlen+0x16>
        cnt ++;
c0109393:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
c0109396:	8b 45 08             	mov    0x8(%ebp),%eax
c0109399:	8d 50 01             	lea    0x1(%eax),%edx
c010939c:	89 55 08             	mov    %edx,0x8(%ebp)
c010939f:	0f b6 00             	movzbl (%eax),%eax
c01093a2:	84 c0                	test   %al,%al
c01093a4:	75 ed                	jne    c0109393 <strlen+0x13>
    }
    return cnt;
c01093a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01093a9:	c9                   	leave  
c01093aa:	c3                   	ret    

c01093ab <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c01093ab:	f3 0f 1e fb          	endbr32 
c01093af:	55                   	push   %ebp
c01093b0:	89 e5                	mov    %esp,%ebp
c01093b2:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c01093b5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c01093bc:	eb 03                	jmp    c01093c1 <strnlen+0x16>
        cnt ++;
c01093be:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c01093c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01093c4:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01093c7:	73 10                	jae    c01093d9 <strnlen+0x2e>
c01093c9:	8b 45 08             	mov    0x8(%ebp),%eax
c01093cc:	8d 50 01             	lea    0x1(%eax),%edx
c01093cf:	89 55 08             	mov    %edx,0x8(%ebp)
c01093d2:	0f b6 00             	movzbl (%eax),%eax
c01093d5:	84 c0                	test   %al,%al
c01093d7:	75 e5                	jne    c01093be <strnlen+0x13>
    }
    return cnt;
c01093d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01093dc:	c9                   	leave  
c01093dd:	c3                   	ret    

c01093de <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c01093de:	f3 0f 1e fb          	endbr32 
c01093e2:	55                   	push   %ebp
c01093e3:	89 e5                	mov    %esp,%ebp
c01093e5:	57                   	push   %edi
c01093e6:	56                   	push   %esi
c01093e7:	83 ec 20             	sub    $0x20,%esp
c01093ea:	8b 45 08             	mov    0x8(%ebp),%eax
c01093ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01093f0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01093f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c01093f6:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01093f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01093fc:	89 d1                	mov    %edx,%ecx
c01093fe:	89 c2                	mov    %eax,%edx
c0109400:	89 ce                	mov    %ecx,%esi
c0109402:	89 d7                	mov    %edx,%edi
c0109404:	ac                   	lods   %ds:(%esi),%al
c0109405:	aa                   	stos   %al,%es:(%edi)
c0109406:	84 c0                	test   %al,%al
c0109408:	75 fa                	jne    c0109404 <strcpy+0x26>
c010940a:	89 fa                	mov    %edi,%edx
c010940c:	89 f1                	mov    %esi,%ecx
c010940e:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0109411:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0109414:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c0109417:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c010941a:	83 c4 20             	add    $0x20,%esp
c010941d:	5e                   	pop    %esi
c010941e:	5f                   	pop    %edi
c010941f:	5d                   	pop    %ebp
c0109420:	c3                   	ret    

c0109421 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c0109421:	f3 0f 1e fb          	endbr32 
c0109425:	55                   	push   %ebp
c0109426:	89 e5                	mov    %esp,%ebp
c0109428:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c010942b:	8b 45 08             	mov    0x8(%ebp),%eax
c010942e:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c0109431:	eb 1e                	jmp    c0109451 <strncpy+0x30>
        if ((*p = *src) != '\0') {
c0109433:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109436:	0f b6 10             	movzbl (%eax),%edx
c0109439:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010943c:	88 10                	mov    %dl,(%eax)
c010943e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109441:	0f b6 00             	movzbl (%eax),%eax
c0109444:	84 c0                	test   %al,%al
c0109446:	74 03                	je     c010944b <strncpy+0x2a>
            src ++;
c0109448:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
c010944b:	ff 45 fc             	incl   -0x4(%ebp)
c010944e:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
c0109451:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0109455:	75 dc                	jne    c0109433 <strncpy+0x12>
    }
    return dst;
c0109457:	8b 45 08             	mov    0x8(%ebp),%eax
}
c010945a:	c9                   	leave  
c010945b:	c3                   	ret    

c010945c <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c010945c:	f3 0f 1e fb          	endbr32 
c0109460:	55                   	push   %ebp
c0109461:	89 e5                	mov    %esp,%ebp
c0109463:	57                   	push   %edi
c0109464:	56                   	push   %esi
c0109465:	83 ec 20             	sub    $0x20,%esp
c0109468:	8b 45 08             	mov    0x8(%ebp),%eax
c010946b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010946e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109471:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
c0109474:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109477:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010947a:	89 d1                	mov    %edx,%ecx
c010947c:	89 c2                	mov    %eax,%edx
c010947e:	89 ce                	mov    %ecx,%esi
c0109480:	89 d7                	mov    %edx,%edi
c0109482:	ac                   	lods   %ds:(%esi),%al
c0109483:	ae                   	scas   %es:(%edi),%al
c0109484:	75 08                	jne    c010948e <strcmp+0x32>
c0109486:	84 c0                	test   %al,%al
c0109488:	75 f8                	jne    c0109482 <strcmp+0x26>
c010948a:	31 c0                	xor    %eax,%eax
c010948c:	eb 04                	jmp    c0109492 <strcmp+0x36>
c010948e:	19 c0                	sbb    %eax,%eax
c0109490:	0c 01                	or     $0x1,%al
c0109492:	89 fa                	mov    %edi,%edx
c0109494:	89 f1                	mov    %esi,%ecx
c0109496:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0109499:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c010949c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
c010949f:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c01094a2:	83 c4 20             	add    $0x20,%esp
c01094a5:	5e                   	pop    %esi
c01094a6:	5f                   	pop    %edi
c01094a7:	5d                   	pop    %ebp
c01094a8:	c3                   	ret    

c01094a9 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c01094a9:	f3 0f 1e fb          	endbr32 
c01094ad:	55                   	push   %ebp
c01094ae:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c01094b0:	eb 09                	jmp    c01094bb <strncmp+0x12>
        n --, s1 ++, s2 ++;
c01094b2:	ff 4d 10             	decl   0x10(%ebp)
c01094b5:	ff 45 08             	incl   0x8(%ebp)
c01094b8:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c01094bb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01094bf:	74 1a                	je     c01094db <strncmp+0x32>
c01094c1:	8b 45 08             	mov    0x8(%ebp),%eax
c01094c4:	0f b6 00             	movzbl (%eax),%eax
c01094c7:	84 c0                	test   %al,%al
c01094c9:	74 10                	je     c01094db <strncmp+0x32>
c01094cb:	8b 45 08             	mov    0x8(%ebp),%eax
c01094ce:	0f b6 10             	movzbl (%eax),%edx
c01094d1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01094d4:	0f b6 00             	movzbl (%eax),%eax
c01094d7:	38 c2                	cmp    %al,%dl
c01094d9:	74 d7                	je     c01094b2 <strncmp+0x9>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c01094db:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01094df:	74 18                	je     c01094f9 <strncmp+0x50>
c01094e1:	8b 45 08             	mov    0x8(%ebp),%eax
c01094e4:	0f b6 00             	movzbl (%eax),%eax
c01094e7:	0f b6 d0             	movzbl %al,%edx
c01094ea:	8b 45 0c             	mov    0xc(%ebp),%eax
c01094ed:	0f b6 00             	movzbl (%eax),%eax
c01094f0:	0f b6 c0             	movzbl %al,%eax
c01094f3:	29 c2                	sub    %eax,%edx
c01094f5:	89 d0                	mov    %edx,%eax
c01094f7:	eb 05                	jmp    c01094fe <strncmp+0x55>
c01094f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01094fe:	5d                   	pop    %ebp
c01094ff:	c3                   	ret    

c0109500 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c0109500:	f3 0f 1e fb          	endbr32 
c0109504:	55                   	push   %ebp
c0109505:	89 e5                	mov    %esp,%ebp
c0109507:	83 ec 04             	sub    $0x4,%esp
c010950a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010950d:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0109510:	eb 13                	jmp    c0109525 <strchr+0x25>
        if (*s == c) {
c0109512:	8b 45 08             	mov    0x8(%ebp),%eax
c0109515:	0f b6 00             	movzbl (%eax),%eax
c0109518:	38 45 fc             	cmp    %al,-0x4(%ebp)
c010951b:	75 05                	jne    c0109522 <strchr+0x22>
            return (char *)s;
c010951d:	8b 45 08             	mov    0x8(%ebp),%eax
c0109520:	eb 12                	jmp    c0109534 <strchr+0x34>
        }
        s ++;
c0109522:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c0109525:	8b 45 08             	mov    0x8(%ebp),%eax
c0109528:	0f b6 00             	movzbl (%eax),%eax
c010952b:	84 c0                	test   %al,%al
c010952d:	75 e3                	jne    c0109512 <strchr+0x12>
    }
    return NULL;
c010952f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109534:	c9                   	leave  
c0109535:	c3                   	ret    

c0109536 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c0109536:	f3 0f 1e fb          	endbr32 
c010953a:	55                   	push   %ebp
c010953b:	89 e5                	mov    %esp,%ebp
c010953d:	83 ec 04             	sub    $0x4,%esp
c0109540:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109543:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0109546:	eb 0e                	jmp    c0109556 <strfind+0x20>
        if (*s == c) {
c0109548:	8b 45 08             	mov    0x8(%ebp),%eax
c010954b:	0f b6 00             	movzbl (%eax),%eax
c010954e:	38 45 fc             	cmp    %al,-0x4(%ebp)
c0109551:	74 0f                	je     c0109562 <strfind+0x2c>
            break;
        }
        s ++;
c0109553:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c0109556:	8b 45 08             	mov    0x8(%ebp),%eax
c0109559:	0f b6 00             	movzbl (%eax),%eax
c010955c:	84 c0                	test   %al,%al
c010955e:	75 e8                	jne    c0109548 <strfind+0x12>
c0109560:	eb 01                	jmp    c0109563 <strfind+0x2d>
            break;
c0109562:	90                   	nop
    }
    return (char *)s;
c0109563:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0109566:	c9                   	leave  
c0109567:	c3                   	ret    

c0109568 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c0109568:	f3 0f 1e fb          	endbr32 
c010956c:	55                   	push   %ebp
c010956d:	89 e5                	mov    %esp,%ebp
c010956f:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c0109572:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c0109579:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0109580:	eb 03                	jmp    c0109585 <strtol+0x1d>
        s ++;
c0109582:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
c0109585:	8b 45 08             	mov    0x8(%ebp),%eax
c0109588:	0f b6 00             	movzbl (%eax),%eax
c010958b:	3c 20                	cmp    $0x20,%al
c010958d:	74 f3                	je     c0109582 <strtol+0x1a>
c010958f:	8b 45 08             	mov    0x8(%ebp),%eax
c0109592:	0f b6 00             	movzbl (%eax),%eax
c0109595:	3c 09                	cmp    $0x9,%al
c0109597:	74 e9                	je     c0109582 <strtol+0x1a>
    }

    // plus/minus sign
    if (*s == '+') {
c0109599:	8b 45 08             	mov    0x8(%ebp),%eax
c010959c:	0f b6 00             	movzbl (%eax),%eax
c010959f:	3c 2b                	cmp    $0x2b,%al
c01095a1:	75 05                	jne    c01095a8 <strtol+0x40>
        s ++;
c01095a3:	ff 45 08             	incl   0x8(%ebp)
c01095a6:	eb 14                	jmp    c01095bc <strtol+0x54>
    }
    else if (*s == '-') {
c01095a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01095ab:	0f b6 00             	movzbl (%eax),%eax
c01095ae:	3c 2d                	cmp    $0x2d,%al
c01095b0:	75 0a                	jne    c01095bc <strtol+0x54>
        s ++, neg = 1;
c01095b2:	ff 45 08             	incl   0x8(%ebp)
c01095b5:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c01095bc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01095c0:	74 06                	je     c01095c8 <strtol+0x60>
c01095c2:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c01095c6:	75 22                	jne    c01095ea <strtol+0x82>
c01095c8:	8b 45 08             	mov    0x8(%ebp),%eax
c01095cb:	0f b6 00             	movzbl (%eax),%eax
c01095ce:	3c 30                	cmp    $0x30,%al
c01095d0:	75 18                	jne    c01095ea <strtol+0x82>
c01095d2:	8b 45 08             	mov    0x8(%ebp),%eax
c01095d5:	40                   	inc    %eax
c01095d6:	0f b6 00             	movzbl (%eax),%eax
c01095d9:	3c 78                	cmp    $0x78,%al
c01095db:	75 0d                	jne    c01095ea <strtol+0x82>
        s += 2, base = 16;
c01095dd:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c01095e1:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c01095e8:	eb 29                	jmp    c0109613 <strtol+0xab>
    }
    else if (base == 0 && s[0] == '0') {
c01095ea:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01095ee:	75 16                	jne    c0109606 <strtol+0x9e>
c01095f0:	8b 45 08             	mov    0x8(%ebp),%eax
c01095f3:	0f b6 00             	movzbl (%eax),%eax
c01095f6:	3c 30                	cmp    $0x30,%al
c01095f8:	75 0c                	jne    c0109606 <strtol+0x9e>
        s ++, base = 8;
c01095fa:	ff 45 08             	incl   0x8(%ebp)
c01095fd:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c0109604:	eb 0d                	jmp    c0109613 <strtol+0xab>
    }
    else if (base == 0) {
c0109606:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010960a:	75 07                	jne    c0109613 <strtol+0xab>
        base = 10;
c010960c:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c0109613:	8b 45 08             	mov    0x8(%ebp),%eax
c0109616:	0f b6 00             	movzbl (%eax),%eax
c0109619:	3c 2f                	cmp    $0x2f,%al
c010961b:	7e 1b                	jle    c0109638 <strtol+0xd0>
c010961d:	8b 45 08             	mov    0x8(%ebp),%eax
c0109620:	0f b6 00             	movzbl (%eax),%eax
c0109623:	3c 39                	cmp    $0x39,%al
c0109625:	7f 11                	jg     c0109638 <strtol+0xd0>
            dig = *s - '0';
c0109627:	8b 45 08             	mov    0x8(%ebp),%eax
c010962a:	0f b6 00             	movzbl (%eax),%eax
c010962d:	0f be c0             	movsbl %al,%eax
c0109630:	83 e8 30             	sub    $0x30,%eax
c0109633:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109636:	eb 48                	jmp    c0109680 <strtol+0x118>
        }
        else if (*s >= 'a' && *s <= 'z') {
c0109638:	8b 45 08             	mov    0x8(%ebp),%eax
c010963b:	0f b6 00             	movzbl (%eax),%eax
c010963e:	3c 60                	cmp    $0x60,%al
c0109640:	7e 1b                	jle    c010965d <strtol+0xf5>
c0109642:	8b 45 08             	mov    0x8(%ebp),%eax
c0109645:	0f b6 00             	movzbl (%eax),%eax
c0109648:	3c 7a                	cmp    $0x7a,%al
c010964a:	7f 11                	jg     c010965d <strtol+0xf5>
            dig = *s - 'a' + 10;
c010964c:	8b 45 08             	mov    0x8(%ebp),%eax
c010964f:	0f b6 00             	movzbl (%eax),%eax
c0109652:	0f be c0             	movsbl %al,%eax
c0109655:	83 e8 57             	sub    $0x57,%eax
c0109658:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010965b:	eb 23                	jmp    c0109680 <strtol+0x118>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c010965d:	8b 45 08             	mov    0x8(%ebp),%eax
c0109660:	0f b6 00             	movzbl (%eax),%eax
c0109663:	3c 40                	cmp    $0x40,%al
c0109665:	7e 3b                	jle    c01096a2 <strtol+0x13a>
c0109667:	8b 45 08             	mov    0x8(%ebp),%eax
c010966a:	0f b6 00             	movzbl (%eax),%eax
c010966d:	3c 5a                	cmp    $0x5a,%al
c010966f:	7f 31                	jg     c01096a2 <strtol+0x13a>
            dig = *s - 'A' + 10;
c0109671:	8b 45 08             	mov    0x8(%ebp),%eax
c0109674:	0f b6 00             	movzbl (%eax),%eax
c0109677:	0f be c0             	movsbl %al,%eax
c010967a:	83 e8 37             	sub    $0x37,%eax
c010967d:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c0109680:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109683:	3b 45 10             	cmp    0x10(%ebp),%eax
c0109686:	7d 19                	jge    c01096a1 <strtol+0x139>
            break;
        }
        s ++, val = (val * base) + dig;
c0109688:	ff 45 08             	incl   0x8(%ebp)
c010968b:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010968e:	0f af 45 10          	imul   0x10(%ebp),%eax
c0109692:	89 c2                	mov    %eax,%edx
c0109694:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109697:	01 d0                	add    %edx,%eax
c0109699:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
c010969c:	e9 72 ff ff ff       	jmp    c0109613 <strtol+0xab>
            break;
c01096a1:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
c01096a2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01096a6:	74 08                	je     c01096b0 <strtol+0x148>
        *endptr = (char *) s;
c01096a8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01096ab:	8b 55 08             	mov    0x8(%ebp),%edx
c01096ae:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c01096b0:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c01096b4:	74 07                	je     c01096bd <strtol+0x155>
c01096b6:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01096b9:	f7 d8                	neg    %eax
c01096bb:	eb 03                	jmp    c01096c0 <strtol+0x158>
c01096bd:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c01096c0:	c9                   	leave  
c01096c1:	c3                   	ret    

c01096c2 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c01096c2:	f3 0f 1e fb          	endbr32 
c01096c6:	55                   	push   %ebp
c01096c7:	89 e5                	mov    %esp,%ebp
c01096c9:	57                   	push   %edi
c01096ca:	83 ec 24             	sub    $0x24,%esp
c01096cd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01096d0:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c01096d3:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
c01096d7:	8b 45 08             	mov    0x8(%ebp),%eax
c01096da:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01096dd:	88 55 f7             	mov    %dl,-0x9(%ebp)
c01096e0:	8b 45 10             	mov    0x10(%ebp),%eax
c01096e3:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c01096e6:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c01096e9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c01096ed:	8b 55 f8             	mov    -0x8(%ebp),%edx
c01096f0:	89 d7                	mov    %edx,%edi
c01096f2:	f3 aa                	rep stos %al,%es:(%edi)
c01096f4:	89 fa                	mov    %edi,%edx
c01096f6:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c01096f9:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c01096fc:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c01096ff:	83 c4 24             	add    $0x24,%esp
c0109702:	5f                   	pop    %edi
c0109703:	5d                   	pop    %ebp
c0109704:	c3                   	ret    

c0109705 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c0109705:	f3 0f 1e fb          	endbr32 
c0109709:	55                   	push   %ebp
c010970a:	89 e5                	mov    %esp,%ebp
c010970c:	57                   	push   %edi
c010970d:	56                   	push   %esi
c010970e:	53                   	push   %ebx
c010970f:	83 ec 30             	sub    $0x30,%esp
c0109712:	8b 45 08             	mov    0x8(%ebp),%eax
c0109715:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109718:	8b 45 0c             	mov    0xc(%ebp),%eax
c010971b:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010971e:	8b 45 10             	mov    0x10(%ebp),%eax
c0109721:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c0109724:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109727:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010972a:	73 42                	jae    c010976e <memmove+0x69>
c010972c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010972f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0109732:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109735:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0109738:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010973b:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c010973e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0109741:	c1 e8 02             	shr    $0x2,%eax
c0109744:	89 c1                	mov    %eax,%ecx
    asm volatile (
c0109746:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0109749:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010974c:	89 d7                	mov    %edx,%edi
c010974e:	89 c6                	mov    %eax,%esi
c0109750:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0109752:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0109755:	83 e1 03             	and    $0x3,%ecx
c0109758:	74 02                	je     c010975c <memmove+0x57>
c010975a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010975c:	89 f0                	mov    %esi,%eax
c010975e:	89 fa                	mov    %edi,%edx
c0109760:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c0109763:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0109766:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
c0109769:	8b 45 e4             	mov    -0x1c(%ebp),%eax
        return __memcpy(dst, src, n);
c010976c:	eb 36                	jmp    c01097a4 <memmove+0x9f>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c010976e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109771:	8d 50 ff             	lea    -0x1(%eax),%edx
c0109774:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109777:	01 c2                	add    %eax,%edx
c0109779:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010977c:	8d 48 ff             	lea    -0x1(%eax),%ecx
c010977f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109782:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
c0109785:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109788:	89 c1                	mov    %eax,%ecx
c010978a:	89 d8                	mov    %ebx,%eax
c010978c:	89 d6                	mov    %edx,%esi
c010978e:	89 c7                	mov    %eax,%edi
c0109790:	fd                   	std    
c0109791:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0109793:	fc                   	cld    
c0109794:	89 f8                	mov    %edi,%eax
c0109796:	89 f2                	mov    %esi,%edx
c0109798:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c010979b:	89 55 c8             	mov    %edx,-0x38(%ebp)
c010979e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
c01097a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c01097a4:	83 c4 30             	add    $0x30,%esp
c01097a7:	5b                   	pop    %ebx
c01097a8:	5e                   	pop    %esi
c01097a9:	5f                   	pop    %edi
c01097aa:	5d                   	pop    %ebp
c01097ab:	c3                   	ret    

c01097ac <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c01097ac:	f3 0f 1e fb          	endbr32 
c01097b0:	55                   	push   %ebp
c01097b1:	89 e5                	mov    %esp,%ebp
c01097b3:	57                   	push   %edi
c01097b4:	56                   	push   %esi
c01097b5:	83 ec 20             	sub    $0x20,%esp
c01097b8:	8b 45 08             	mov    0x8(%ebp),%eax
c01097bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01097be:	8b 45 0c             	mov    0xc(%ebp),%eax
c01097c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01097c4:	8b 45 10             	mov    0x10(%ebp),%eax
c01097c7:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c01097ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01097cd:	c1 e8 02             	shr    $0x2,%eax
c01097d0:	89 c1                	mov    %eax,%ecx
    asm volatile (
c01097d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01097d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01097d8:	89 d7                	mov    %edx,%edi
c01097da:	89 c6                	mov    %eax,%esi
c01097dc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c01097de:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c01097e1:	83 e1 03             	and    $0x3,%ecx
c01097e4:	74 02                	je     c01097e8 <memcpy+0x3c>
c01097e6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c01097e8:	89 f0                	mov    %esi,%eax
c01097ea:	89 fa                	mov    %edi,%edx
c01097ec:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c01097ef:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c01097f2:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
c01097f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c01097f8:	83 c4 20             	add    $0x20,%esp
c01097fb:	5e                   	pop    %esi
c01097fc:	5f                   	pop    %edi
c01097fd:	5d                   	pop    %ebp
c01097fe:	c3                   	ret    

c01097ff <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c01097ff:	f3 0f 1e fb          	endbr32 
c0109803:	55                   	push   %ebp
c0109804:	89 e5                	mov    %esp,%ebp
c0109806:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c0109809:	8b 45 08             	mov    0x8(%ebp),%eax
c010980c:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c010980f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109812:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c0109815:	eb 2e                	jmp    c0109845 <memcmp+0x46>
        if (*s1 != *s2) {
c0109817:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010981a:	0f b6 10             	movzbl (%eax),%edx
c010981d:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0109820:	0f b6 00             	movzbl (%eax),%eax
c0109823:	38 c2                	cmp    %al,%dl
c0109825:	74 18                	je     c010983f <memcmp+0x40>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c0109827:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010982a:	0f b6 00             	movzbl (%eax),%eax
c010982d:	0f b6 d0             	movzbl %al,%edx
c0109830:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0109833:	0f b6 00             	movzbl (%eax),%eax
c0109836:	0f b6 c0             	movzbl %al,%eax
c0109839:	29 c2                	sub    %eax,%edx
c010983b:	89 d0                	mov    %edx,%eax
c010983d:	eb 18                	jmp    c0109857 <memcmp+0x58>
        }
        s1 ++, s2 ++;
c010983f:	ff 45 fc             	incl   -0x4(%ebp)
c0109842:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
c0109845:	8b 45 10             	mov    0x10(%ebp),%eax
c0109848:	8d 50 ff             	lea    -0x1(%eax),%edx
c010984b:	89 55 10             	mov    %edx,0x10(%ebp)
c010984e:	85 c0                	test   %eax,%eax
c0109850:	75 c5                	jne    c0109817 <memcmp+0x18>
    }
    return 0;
c0109852:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109857:	c9                   	leave  
c0109858:	c3                   	ret    

c0109859 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c0109859:	f3 0f 1e fb          	endbr32 
c010985d:	55                   	push   %ebp
c010985e:	89 e5                	mov    %esp,%ebp
c0109860:	83 ec 58             	sub    $0x58,%esp
c0109863:	8b 45 10             	mov    0x10(%ebp),%eax
c0109866:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0109869:	8b 45 14             	mov    0x14(%ebp),%eax
c010986c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c010986f:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0109872:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0109875:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0109878:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c010987b:	8b 45 18             	mov    0x18(%ebp),%eax
c010987e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0109881:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109884:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0109887:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010988a:	89 55 f0             	mov    %edx,-0x10(%ebp)
c010988d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109890:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109893:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0109897:	74 1c                	je     c01098b5 <printnum+0x5c>
c0109899:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010989c:	ba 00 00 00 00       	mov    $0x0,%edx
c01098a1:	f7 75 e4             	divl   -0x1c(%ebp)
c01098a4:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01098a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01098aa:	ba 00 00 00 00       	mov    $0x0,%edx
c01098af:	f7 75 e4             	divl   -0x1c(%ebp)
c01098b2:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01098b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01098b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01098bb:	f7 75 e4             	divl   -0x1c(%ebp)
c01098be:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01098c1:	89 55 dc             	mov    %edx,-0x24(%ebp)
c01098c4:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01098c7:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01098ca:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01098cd:	89 55 ec             	mov    %edx,-0x14(%ebp)
c01098d0:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01098d3:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c01098d6:	8b 45 18             	mov    0x18(%ebp),%eax
c01098d9:	ba 00 00 00 00       	mov    $0x0,%edx
c01098de:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c01098e1:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c01098e4:	19 d1                	sbb    %edx,%ecx
c01098e6:	72 4c                	jb     c0109934 <printnum+0xdb>
        printnum(putch, putdat, result, base, width - 1, padc);
c01098e8:	8b 45 1c             	mov    0x1c(%ebp),%eax
c01098eb:	8d 50 ff             	lea    -0x1(%eax),%edx
c01098ee:	8b 45 20             	mov    0x20(%ebp),%eax
c01098f1:	89 44 24 18          	mov    %eax,0x18(%esp)
c01098f5:	89 54 24 14          	mov    %edx,0x14(%esp)
c01098f9:	8b 45 18             	mov    0x18(%ebp),%eax
c01098fc:	89 44 24 10          	mov    %eax,0x10(%esp)
c0109900:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109903:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0109906:	89 44 24 08          	mov    %eax,0x8(%esp)
c010990a:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010990e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109911:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109915:	8b 45 08             	mov    0x8(%ebp),%eax
c0109918:	89 04 24             	mov    %eax,(%esp)
c010991b:	e8 39 ff ff ff       	call   c0109859 <printnum>
c0109920:	eb 1b                	jmp    c010993d <printnum+0xe4>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c0109922:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109925:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109929:	8b 45 20             	mov    0x20(%ebp),%eax
c010992c:	89 04 24             	mov    %eax,(%esp)
c010992f:	8b 45 08             	mov    0x8(%ebp),%eax
c0109932:	ff d0                	call   *%eax
        while (-- width > 0)
c0109934:	ff 4d 1c             	decl   0x1c(%ebp)
c0109937:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c010993b:	7f e5                	jg     c0109922 <printnum+0xc9>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c010993d:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0109940:	05 10 c2 10 c0       	add    $0xc010c210,%eax
c0109945:	0f b6 00             	movzbl (%eax),%eax
c0109948:	0f be c0             	movsbl %al,%eax
c010994b:	8b 55 0c             	mov    0xc(%ebp),%edx
c010994e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0109952:	89 04 24             	mov    %eax,(%esp)
c0109955:	8b 45 08             	mov    0x8(%ebp),%eax
c0109958:	ff d0                	call   *%eax
}
c010995a:	90                   	nop
c010995b:	c9                   	leave  
c010995c:	c3                   	ret    

c010995d <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c010995d:	f3 0f 1e fb          	endbr32 
c0109961:	55                   	push   %ebp
c0109962:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0109964:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0109968:	7e 14                	jle    c010997e <getuint+0x21>
        return va_arg(*ap, unsigned long long);
c010996a:	8b 45 08             	mov    0x8(%ebp),%eax
c010996d:	8b 00                	mov    (%eax),%eax
c010996f:	8d 48 08             	lea    0x8(%eax),%ecx
c0109972:	8b 55 08             	mov    0x8(%ebp),%edx
c0109975:	89 0a                	mov    %ecx,(%edx)
c0109977:	8b 50 04             	mov    0x4(%eax),%edx
c010997a:	8b 00                	mov    (%eax),%eax
c010997c:	eb 30                	jmp    c01099ae <getuint+0x51>
    }
    else if (lflag) {
c010997e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0109982:	74 16                	je     c010999a <getuint+0x3d>
        return va_arg(*ap, unsigned long);
c0109984:	8b 45 08             	mov    0x8(%ebp),%eax
c0109987:	8b 00                	mov    (%eax),%eax
c0109989:	8d 48 04             	lea    0x4(%eax),%ecx
c010998c:	8b 55 08             	mov    0x8(%ebp),%edx
c010998f:	89 0a                	mov    %ecx,(%edx)
c0109991:	8b 00                	mov    (%eax),%eax
c0109993:	ba 00 00 00 00       	mov    $0x0,%edx
c0109998:	eb 14                	jmp    c01099ae <getuint+0x51>
    }
    else {
        return va_arg(*ap, unsigned int);
c010999a:	8b 45 08             	mov    0x8(%ebp),%eax
c010999d:	8b 00                	mov    (%eax),%eax
c010999f:	8d 48 04             	lea    0x4(%eax),%ecx
c01099a2:	8b 55 08             	mov    0x8(%ebp),%edx
c01099a5:	89 0a                	mov    %ecx,(%edx)
c01099a7:	8b 00                	mov    (%eax),%eax
c01099a9:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c01099ae:	5d                   	pop    %ebp
c01099af:	c3                   	ret    

c01099b0 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c01099b0:	f3 0f 1e fb          	endbr32 
c01099b4:	55                   	push   %ebp
c01099b5:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c01099b7:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c01099bb:	7e 14                	jle    c01099d1 <getint+0x21>
        return va_arg(*ap, long long);
c01099bd:	8b 45 08             	mov    0x8(%ebp),%eax
c01099c0:	8b 00                	mov    (%eax),%eax
c01099c2:	8d 48 08             	lea    0x8(%eax),%ecx
c01099c5:	8b 55 08             	mov    0x8(%ebp),%edx
c01099c8:	89 0a                	mov    %ecx,(%edx)
c01099ca:	8b 50 04             	mov    0x4(%eax),%edx
c01099cd:	8b 00                	mov    (%eax),%eax
c01099cf:	eb 28                	jmp    c01099f9 <getint+0x49>
    }
    else if (lflag) {
c01099d1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01099d5:	74 12                	je     c01099e9 <getint+0x39>
        return va_arg(*ap, long);
c01099d7:	8b 45 08             	mov    0x8(%ebp),%eax
c01099da:	8b 00                	mov    (%eax),%eax
c01099dc:	8d 48 04             	lea    0x4(%eax),%ecx
c01099df:	8b 55 08             	mov    0x8(%ebp),%edx
c01099e2:	89 0a                	mov    %ecx,(%edx)
c01099e4:	8b 00                	mov    (%eax),%eax
c01099e6:	99                   	cltd   
c01099e7:	eb 10                	jmp    c01099f9 <getint+0x49>
    }
    else {
        return va_arg(*ap, int);
c01099e9:	8b 45 08             	mov    0x8(%ebp),%eax
c01099ec:	8b 00                	mov    (%eax),%eax
c01099ee:	8d 48 04             	lea    0x4(%eax),%ecx
c01099f1:	8b 55 08             	mov    0x8(%ebp),%edx
c01099f4:	89 0a                	mov    %ecx,(%edx)
c01099f6:	8b 00                	mov    (%eax),%eax
c01099f8:	99                   	cltd   
    }
}
c01099f9:	5d                   	pop    %ebp
c01099fa:	c3                   	ret    

c01099fb <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c01099fb:	f3 0f 1e fb          	endbr32 
c01099ff:	55                   	push   %ebp
c0109a00:	89 e5                	mov    %esp,%ebp
c0109a02:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c0109a05:	8d 45 14             	lea    0x14(%ebp),%eax
c0109a08:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c0109a0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109a0e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109a12:	8b 45 10             	mov    0x10(%ebp),%eax
c0109a15:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109a19:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109a1c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109a20:	8b 45 08             	mov    0x8(%ebp),%eax
c0109a23:	89 04 24             	mov    %eax,(%esp)
c0109a26:	e8 03 00 00 00       	call   c0109a2e <vprintfmt>
    va_end(ap);
}
c0109a2b:	90                   	nop
c0109a2c:	c9                   	leave  
c0109a2d:	c3                   	ret    

c0109a2e <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c0109a2e:	f3 0f 1e fb          	endbr32 
c0109a32:	55                   	push   %ebp
c0109a33:	89 e5                	mov    %esp,%ebp
c0109a35:	56                   	push   %esi
c0109a36:	53                   	push   %ebx
c0109a37:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0109a3a:	eb 17                	jmp    c0109a53 <vprintfmt+0x25>
            if (ch == '\0') {
c0109a3c:	85 db                	test   %ebx,%ebx
c0109a3e:	0f 84 c0 03 00 00    	je     c0109e04 <vprintfmt+0x3d6>
                return;
            }
            putch(ch, putdat);
c0109a44:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109a47:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109a4b:	89 1c 24             	mov    %ebx,(%esp)
c0109a4e:	8b 45 08             	mov    0x8(%ebp),%eax
c0109a51:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0109a53:	8b 45 10             	mov    0x10(%ebp),%eax
c0109a56:	8d 50 01             	lea    0x1(%eax),%edx
c0109a59:	89 55 10             	mov    %edx,0x10(%ebp)
c0109a5c:	0f b6 00             	movzbl (%eax),%eax
c0109a5f:	0f b6 d8             	movzbl %al,%ebx
c0109a62:	83 fb 25             	cmp    $0x25,%ebx
c0109a65:	75 d5                	jne    c0109a3c <vprintfmt+0xe>
        }

        // Process a %-escape sequence
        char padc = ' ';
c0109a67:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c0109a6b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c0109a72:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109a75:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c0109a78:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0109a7f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0109a82:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c0109a85:	8b 45 10             	mov    0x10(%ebp),%eax
c0109a88:	8d 50 01             	lea    0x1(%eax),%edx
c0109a8b:	89 55 10             	mov    %edx,0x10(%ebp)
c0109a8e:	0f b6 00             	movzbl (%eax),%eax
c0109a91:	0f b6 d8             	movzbl %al,%ebx
c0109a94:	8d 43 dd             	lea    -0x23(%ebx),%eax
c0109a97:	83 f8 55             	cmp    $0x55,%eax
c0109a9a:	0f 87 38 03 00 00    	ja     c0109dd8 <vprintfmt+0x3aa>
c0109aa0:	8b 04 85 34 c2 10 c0 	mov    -0x3fef3dcc(,%eax,4),%eax
c0109aa7:	3e ff e0             	notrack jmp *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c0109aaa:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c0109aae:	eb d5                	jmp    c0109a85 <vprintfmt+0x57>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c0109ab0:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c0109ab4:	eb cf                	jmp    c0109a85 <vprintfmt+0x57>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c0109ab6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c0109abd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0109ac0:	89 d0                	mov    %edx,%eax
c0109ac2:	c1 e0 02             	shl    $0x2,%eax
c0109ac5:	01 d0                	add    %edx,%eax
c0109ac7:	01 c0                	add    %eax,%eax
c0109ac9:	01 d8                	add    %ebx,%eax
c0109acb:	83 e8 30             	sub    $0x30,%eax
c0109ace:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c0109ad1:	8b 45 10             	mov    0x10(%ebp),%eax
c0109ad4:	0f b6 00             	movzbl (%eax),%eax
c0109ad7:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c0109ada:	83 fb 2f             	cmp    $0x2f,%ebx
c0109add:	7e 38                	jle    c0109b17 <vprintfmt+0xe9>
c0109adf:	83 fb 39             	cmp    $0x39,%ebx
c0109ae2:	7f 33                	jg     c0109b17 <vprintfmt+0xe9>
            for (precision = 0; ; ++ fmt) {
c0109ae4:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
c0109ae7:	eb d4                	jmp    c0109abd <vprintfmt+0x8f>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
c0109ae9:	8b 45 14             	mov    0x14(%ebp),%eax
c0109aec:	8d 50 04             	lea    0x4(%eax),%edx
c0109aef:	89 55 14             	mov    %edx,0x14(%ebp)
c0109af2:	8b 00                	mov    (%eax),%eax
c0109af4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c0109af7:	eb 1f                	jmp    c0109b18 <vprintfmt+0xea>

        case '.':
            if (width < 0)
c0109af9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0109afd:	79 86                	jns    c0109a85 <vprintfmt+0x57>
                width = 0;
c0109aff:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c0109b06:	e9 7a ff ff ff       	jmp    c0109a85 <vprintfmt+0x57>

        case '#':
            altflag = 1;
c0109b0b:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c0109b12:	e9 6e ff ff ff       	jmp    c0109a85 <vprintfmt+0x57>
            goto process_precision;
c0109b17:	90                   	nop

        process_precision:
            if (width < 0)
c0109b18:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0109b1c:	0f 89 63 ff ff ff    	jns    c0109a85 <vprintfmt+0x57>
                width = precision, precision = -1;
c0109b22:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109b25:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0109b28:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c0109b2f:	e9 51 ff ff ff       	jmp    c0109a85 <vprintfmt+0x57>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c0109b34:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
c0109b37:	e9 49 ff ff ff       	jmp    c0109a85 <vprintfmt+0x57>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c0109b3c:	8b 45 14             	mov    0x14(%ebp),%eax
c0109b3f:	8d 50 04             	lea    0x4(%eax),%edx
c0109b42:	89 55 14             	mov    %edx,0x14(%ebp)
c0109b45:	8b 00                	mov    (%eax),%eax
c0109b47:	8b 55 0c             	mov    0xc(%ebp),%edx
c0109b4a:	89 54 24 04          	mov    %edx,0x4(%esp)
c0109b4e:	89 04 24             	mov    %eax,(%esp)
c0109b51:	8b 45 08             	mov    0x8(%ebp),%eax
c0109b54:	ff d0                	call   *%eax
            break;
c0109b56:	e9 a4 02 00 00       	jmp    c0109dff <vprintfmt+0x3d1>

        // error message
        case 'e':
            err = va_arg(ap, int);
c0109b5b:	8b 45 14             	mov    0x14(%ebp),%eax
c0109b5e:	8d 50 04             	lea    0x4(%eax),%edx
c0109b61:	89 55 14             	mov    %edx,0x14(%ebp)
c0109b64:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c0109b66:	85 db                	test   %ebx,%ebx
c0109b68:	79 02                	jns    c0109b6c <vprintfmt+0x13e>
                err = -err;
c0109b6a:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c0109b6c:	83 fb 06             	cmp    $0x6,%ebx
c0109b6f:	7f 0b                	jg     c0109b7c <vprintfmt+0x14e>
c0109b71:	8b 34 9d f4 c1 10 c0 	mov    -0x3fef3e0c(,%ebx,4),%esi
c0109b78:	85 f6                	test   %esi,%esi
c0109b7a:	75 23                	jne    c0109b9f <vprintfmt+0x171>
                printfmt(putch, putdat, "error %d", err);
c0109b7c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0109b80:	c7 44 24 08 21 c2 10 	movl   $0xc010c221,0x8(%esp)
c0109b87:	c0 
c0109b88:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109b8b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109b8f:	8b 45 08             	mov    0x8(%ebp),%eax
c0109b92:	89 04 24             	mov    %eax,(%esp)
c0109b95:	e8 61 fe ff ff       	call   c01099fb <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c0109b9a:	e9 60 02 00 00       	jmp    c0109dff <vprintfmt+0x3d1>
                printfmt(putch, putdat, "%s", p);
c0109b9f:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0109ba3:	c7 44 24 08 2a c2 10 	movl   $0xc010c22a,0x8(%esp)
c0109baa:	c0 
c0109bab:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109bae:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109bb2:	8b 45 08             	mov    0x8(%ebp),%eax
c0109bb5:	89 04 24             	mov    %eax,(%esp)
c0109bb8:	e8 3e fe ff ff       	call   c01099fb <printfmt>
            break;
c0109bbd:	e9 3d 02 00 00       	jmp    c0109dff <vprintfmt+0x3d1>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c0109bc2:	8b 45 14             	mov    0x14(%ebp),%eax
c0109bc5:	8d 50 04             	lea    0x4(%eax),%edx
c0109bc8:	89 55 14             	mov    %edx,0x14(%ebp)
c0109bcb:	8b 30                	mov    (%eax),%esi
c0109bcd:	85 f6                	test   %esi,%esi
c0109bcf:	75 05                	jne    c0109bd6 <vprintfmt+0x1a8>
                p = "(null)";
c0109bd1:	be 2d c2 10 c0       	mov    $0xc010c22d,%esi
            }
            if (width > 0 && padc != '-') {
c0109bd6:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0109bda:	7e 76                	jle    c0109c52 <vprintfmt+0x224>
c0109bdc:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c0109be0:	74 70                	je     c0109c52 <vprintfmt+0x224>
                for (width -= strnlen(p, precision); width > 0; width --) {
c0109be2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109be5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109be9:	89 34 24             	mov    %esi,(%esp)
c0109bec:	e8 ba f7 ff ff       	call   c01093ab <strnlen>
c0109bf1:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0109bf4:	29 c2                	sub    %eax,%edx
c0109bf6:	89 d0                	mov    %edx,%eax
c0109bf8:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0109bfb:	eb 16                	jmp    c0109c13 <vprintfmt+0x1e5>
                    putch(padc, putdat);
c0109bfd:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c0109c01:	8b 55 0c             	mov    0xc(%ebp),%edx
c0109c04:	89 54 24 04          	mov    %edx,0x4(%esp)
c0109c08:	89 04 24             	mov    %eax,(%esp)
c0109c0b:	8b 45 08             	mov    0x8(%ebp),%eax
c0109c0e:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
c0109c10:	ff 4d e8             	decl   -0x18(%ebp)
c0109c13:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0109c17:	7f e4                	jg     c0109bfd <vprintfmt+0x1cf>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0109c19:	eb 37                	jmp    c0109c52 <vprintfmt+0x224>
                if (altflag && (ch < ' ' || ch > '~')) {
c0109c1b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0109c1f:	74 1f                	je     c0109c40 <vprintfmt+0x212>
c0109c21:	83 fb 1f             	cmp    $0x1f,%ebx
c0109c24:	7e 05                	jle    c0109c2b <vprintfmt+0x1fd>
c0109c26:	83 fb 7e             	cmp    $0x7e,%ebx
c0109c29:	7e 15                	jle    c0109c40 <vprintfmt+0x212>
                    putch('?', putdat);
c0109c2b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109c2e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109c32:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c0109c39:	8b 45 08             	mov    0x8(%ebp),%eax
c0109c3c:	ff d0                	call   *%eax
c0109c3e:	eb 0f                	jmp    c0109c4f <vprintfmt+0x221>
                }
                else {
                    putch(ch, putdat);
c0109c40:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109c43:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109c47:	89 1c 24             	mov    %ebx,(%esp)
c0109c4a:	8b 45 08             	mov    0x8(%ebp),%eax
c0109c4d:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0109c4f:	ff 4d e8             	decl   -0x18(%ebp)
c0109c52:	89 f0                	mov    %esi,%eax
c0109c54:	8d 70 01             	lea    0x1(%eax),%esi
c0109c57:	0f b6 00             	movzbl (%eax),%eax
c0109c5a:	0f be d8             	movsbl %al,%ebx
c0109c5d:	85 db                	test   %ebx,%ebx
c0109c5f:	74 27                	je     c0109c88 <vprintfmt+0x25a>
c0109c61:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0109c65:	78 b4                	js     c0109c1b <vprintfmt+0x1ed>
c0109c67:	ff 4d e4             	decl   -0x1c(%ebp)
c0109c6a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0109c6e:	79 ab                	jns    c0109c1b <vprintfmt+0x1ed>
                }
            }
            for (; width > 0; width --) {
c0109c70:	eb 16                	jmp    c0109c88 <vprintfmt+0x25a>
                putch(' ', putdat);
c0109c72:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109c75:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109c79:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0109c80:	8b 45 08             	mov    0x8(%ebp),%eax
c0109c83:	ff d0                	call   *%eax
            for (; width > 0; width --) {
c0109c85:	ff 4d e8             	decl   -0x18(%ebp)
c0109c88:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0109c8c:	7f e4                	jg     c0109c72 <vprintfmt+0x244>
            }
            break;
c0109c8e:	e9 6c 01 00 00       	jmp    c0109dff <vprintfmt+0x3d1>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c0109c93:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109c96:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109c9a:	8d 45 14             	lea    0x14(%ebp),%eax
c0109c9d:	89 04 24             	mov    %eax,(%esp)
c0109ca0:	e8 0b fd ff ff       	call   c01099b0 <getint>
c0109ca5:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109ca8:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c0109cab:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109cae:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109cb1:	85 d2                	test   %edx,%edx
c0109cb3:	79 26                	jns    c0109cdb <vprintfmt+0x2ad>
                putch('-', putdat);
c0109cb5:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109cb8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109cbc:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c0109cc3:	8b 45 08             	mov    0x8(%ebp),%eax
c0109cc6:	ff d0                	call   *%eax
                num = -(long long)num;
c0109cc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109ccb:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109cce:	f7 d8                	neg    %eax
c0109cd0:	83 d2 00             	adc    $0x0,%edx
c0109cd3:	f7 da                	neg    %edx
c0109cd5:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109cd8:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c0109cdb:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0109ce2:	e9 a8 00 00 00       	jmp    c0109d8f <vprintfmt+0x361>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c0109ce7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109cea:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109cee:	8d 45 14             	lea    0x14(%ebp),%eax
c0109cf1:	89 04 24             	mov    %eax,(%esp)
c0109cf4:	e8 64 fc ff ff       	call   c010995d <getuint>
c0109cf9:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109cfc:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c0109cff:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0109d06:	e9 84 00 00 00       	jmp    c0109d8f <vprintfmt+0x361>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c0109d0b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109d0e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109d12:	8d 45 14             	lea    0x14(%ebp),%eax
c0109d15:	89 04 24             	mov    %eax,(%esp)
c0109d18:	e8 40 fc ff ff       	call   c010995d <getuint>
c0109d1d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109d20:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c0109d23:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c0109d2a:	eb 63                	jmp    c0109d8f <vprintfmt+0x361>

        // pointer
        case 'p':
            putch('0', putdat);
c0109d2c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109d2f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109d33:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c0109d3a:	8b 45 08             	mov    0x8(%ebp),%eax
c0109d3d:	ff d0                	call   *%eax
            putch('x', putdat);
c0109d3f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109d42:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109d46:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c0109d4d:	8b 45 08             	mov    0x8(%ebp),%eax
c0109d50:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c0109d52:	8b 45 14             	mov    0x14(%ebp),%eax
c0109d55:	8d 50 04             	lea    0x4(%eax),%edx
c0109d58:	89 55 14             	mov    %edx,0x14(%ebp)
c0109d5b:	8b 00                	mov    (%eax),%eax
c0109d5d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109d60:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c0109d67:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c0109d6e:	eb 1f                	jmp    c0109d8f <vprintfmt+0x361>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c0109d70:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109d73:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109d77:	8d 45 14             	lea    0x14(%ebp),%eax
c0109d7a:	89 04 24             	mov    %eax,(%esp)
c0109d7d:	e8 db fb ff ff       	call   c010995d <getuint>
c0109d82:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109d85:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c0109d88:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c0109d8f:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c0109d93:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109d96:	89 54 24 18          	mov    %edx,0x18(%esp)
c0109d9a:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0109d9d:	89 54 24 14          	mov    %edx,0x14(%esp)
c0109da1:	89 44 24 10          	mov    %eax,0x10(%esp)
c0109da5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109da8:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109dab:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109daf:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0109db3:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109db6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109dba:	8b 45 08             	mov    0x8(%ebp),%eax
c0109dbd:	89 04 24             	mov    %eax,(%esp)
c0109dc0:	e8 94 fa ff ff       	call   c0109859 <printnum>
            break;
c0109dc5:	eb 38                	jmp    c0109dff <vprintfmt+0x3d1>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c0109dc7:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109dca:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109dce:	89 1c 24             	mov    %ebx,(%esp)
c0109dd1:	8b 45 08             	mov    0x8(%ebp),%eax
c0109dd4:	ff d0                	call   *%eax
            break;
c0109dd6:	eb 27                	jmp    c0109dff <vprintfmt+0x3d1>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c0109dd8:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109ddb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109ddf:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c0109de6:	8b 45 08             	mov    0x8(%ebp),%eax
c0109de9:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c0109deb:	ff 4d 10             	decl   0x10(%ebp)
c0109dee:	eb 03                	jmp    c0109df3 <vprintfmt+0x3c5>
c0109df0:	ff 4d 10             	decl   0x10(%ebp)
c0109df3:	8b 45 10             	mov    0x10(%ebp),%eax
c0109df6:	48                   	dec    %eax
c0109df7:	0f b6 00             	movzbl (%eax),%eax
c0109dfa:	3c 25                	cmp    $0x25,%al
c0109dfc:	75 f2                	jne    c0109df0 <vprintfmt+0x3c2>
                /* do nothing */;
            break;
c0109dfe:	90                   	nop
    while (1) {
c0109dff:	e9 36 fc ff ff       	jmp    c0109a3a <vprintfmt+0xc>
                return;
c0109e04:	90                   	nop
        }
    }
}
c0109e05:	83 c4 40             	add    $0x40,%esp
c0109e08:	5b                   	pop    %ebx
c0109e09:	5e                   	pop    %esi
c0109e0a:	5d                   	pop    %ebp
c0109e0b:	c3                   	ret    

c0109e0c <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c0109e0c:	f3 0f 1e fb          	endbr32 
c0109e10:	55                   	push   %ebp
c0109e11:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c0109e13:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109e16:	8b 40 08             	mov    0x8(%eax),%eax
c0109e19:	8d 50 01             	lea    0x1(%eax),%edx
c0109e1c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109e1f:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c0109e22:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109e25:	8b 10                	mov    (%eax),%edx
c0109e27:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109e2a:	8b 40 04             	mov    0x4(%eax),%eax
c0109e2d:	39 c2                	cmp    %eax,%edx
c0109e2f:	73 12                	jae    c0109e43 <sprintputch+0x37>
        *b->buf ++ = ch;
c0109e31:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109e34:	8b 00                	mov    (%eax),%eax
c0109e36:	8d 48 01             	lea    0x1(%eax),%ecx
c0109e39:	8b 55 0c             	mov    0xc(%ebp),%edx
c0109e3c:	89 0a                	mov    %ecx,(%edx)
c0109e3e:	8b 55 08             	mov    0x8(%ebp),%edx
c0109e41:	88 10                	mov    %dl,(%eax)
    }
}
c0109e43:	90                   	nop
c0109e44:	5d                   	pop    %ebp
c0109e45:	c3                   	ret    

c0109e46 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c0109e46:	f3 0f 1e fb          	endbr32 
c0109e4a:	55                   	push   %ebp
c0109e4b:	89 e5                	mov    %esp,%ebp
c0109e4d:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0109e50:	8d 45 14             	lea    0x14(%ebp),%eax
c0109e53:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c0109e56:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109e59:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109e5d:	8b 45 10             	mov    0x10(%ebp),%eax
c0109e60:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109e64:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109e67:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109e6b:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e6e:	89 04 24             	mov    %eax,(%esp)
c0109e71:	e8 08 00 00 00       	call   c0109e7e <vsnprintf>
c0109e76:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0109e79:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0109e7c:	c9                   	leave  
c0109e7d:	c3                   	ret    

c0109e7e <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c0109e7e:	f3 0f 1e fb          	endbr32 
c0109e82:	55                   	push   %ebp
c0109e83:	89 e5                	mov    %esp,%ebp
c0109e85:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c0109e88:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e8b:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0109e8e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109e91:	8d 50 ff             	lea    -0x1(%eax),%edx
c0109e94:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e97:	01 d0                	add    %edx,%eax
c0109e99:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109e9c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c0109ea3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0109ea7:	74 0a                	je     c0109eb3 <vsnprintf+0x35>
c0109ea9:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0109eac:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109eaf:	39 c2                	cmp    %eax,%edx
c0109eb1:	76 07                	jbe    c0109eba <vsnprintf+0x3c>
        return -E_INVAL;
c0109eb3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c0109eb8:	eb 2a                	jmp    c0109ee4 <vsnprintf+0x66>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c0109eba:	8b 45 14             	mov    0x14(%ebp),%eax
c0109ebd:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109ec1:	8b 45 10             	mov    0x10(%ebp),%eax
c0109ec4:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109ec8:	8d 45 ec             	lea    -0x14(%ebp),%eax
c0109ecb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109ecf:	c7 04 24 0c 9e 10 c0 	movl   $0xc0109e0c,(%esp)
c0109ed6:	e8 53 fb ff ff       	call   c0109a2e <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c0109edb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109ede:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c0109ee1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0109ee4:	c9                   	leave  
c0109ee5:	c3                   	ret    

c0109ee6 <hash32>:
 * @bits:   the number of bits in a return value
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
c0109ee6:	f3 0f 1e fb          	endbr32 
c0109eea:	55                   	push   %ebp
c0109eeb:	89 e5                	mov    %esp,%ebp
c0109eed:	83 ec 10             	sub    $0x10,%esp
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
c0109ef0:	8b 45 08             	mov    0x8(%ebp),%eax
c0109ef3:	69 c0 01 00 37 9e    	imul   $0x9e370001,%eax,%eax
c0109ef9:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (hash >> (32 - bits));
c0109efc:	b8 20 00 00 00       	mov    $0x20,%eax
c0109f01:	2b 45 0c             	sub    0xc(%ebp),%eax
c0109f04:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0109f07:	88 c1                	mov    %al,%cl
c0109f09:	d3 ea                	shr    %cl,%edx
c0109f0b:	89 d0                	mov    %edx,%eax
}
c0109f0d:	c9                   	leave  
c0109f0e:	c3                   	ret    

c0109f0f <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
c0109f0f:	f3 0f 1e fb          	endbr32 
c0109f13:	55                   	push   %ebp
c0109f14:	89 e5                	mov    %esp,%ebp
c0109f16:	57                   	push   %edi
c0109f17:	56                   	push   %esi
c0109f18:	53                   	push   %ebx
c0109f19:	83 ec 24             	sub    $0x24,%esp
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
c0109f1c:	a1 88 8a 12 c0       	mov    0xc0128a88,%eax
c0109f21:	8b 15 8c 8a 12 c0    	mov    0xc0128a8c,%edx
c0109f27:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
c0109f2d:	6b f0 05             	imul   $0x5,%eax,%esi
c0109f30:	01 fe                	add    %edi,%esi
c0109f32:	bf 6d e6 ec de       	mov    $0xdeece66d,%edi
c0109f37:	f7 e7                	mul    %edi
c0109f39:	01 d6                	add    %edx,%esi
c0109f3b:	89 f2                	mov    %esi,%edx
c0109f3d:	83 c0 0b             	add    $0xb,%eax
c0109f40:	83 d2 00             	adc    $0x0,%edx
c0109f43:	89 c7                	mov    %eax,%edi
c0109f45:	83 e7 ff             	and    $0xffffffff,%edi
c0109f48:	89 f9                	mov    %edi,%ecx
c0109f4a:	0f b7 da             	movzwl %dx,%ebx
c0109f4d:	89 0d 88 8a 12 c0    	mov    %ecx,0xc0128a88
c0109f53:	89 1d 8c 8a 12 c0    	mov    %ebx,0xc0128a8c
    unsigned long long result = (next >> 12);
c0109f59:	a1 88 8a 12 c0       	mov    0xc0128a88,%eax
c0109f5e:	8b 15 8c 8a 12 c0    	mov    0xc0128a8c,%edx
c0109f64:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0109f68:	c1 ea 0c             	shr    $0xc,%edx
c0109f6b:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0109f6e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
c0109f71:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
c0109f78:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109f7b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0109f7e:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0109f81:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0109f84:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109f87:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0109f8a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0109f8e:	74 1c                	je     c0109fac <rand+0x9d>
c0109f90:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109f93:	ba 00 00 00 00       	mov    $0x0,%edx
c0109f98:	f7 75 dc             	divl   -0x24(%ebp)
c0109f9b:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0109f9e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109fa1:	ba 00 00 00 00       	mov    $0x0,%edx
c0109fa6:	f7 75 dc             	divl   -0x24(%ebp)
c0109fa9:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0109fac:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0109faf:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0109fb2:	f7 75 dc             	divl   -0x24(%ebp)
c0109fb5:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0109fb8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0109fbb:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0109fbe:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0109fc1:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0109fc4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0109fc7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
c0109fca:	83 c4 24             	add    $0x24,%esp
c0109fcd:	5b                   	pop    %ebx
c0109fce:	5e                   	pop    %esi
c0109fcf:	5f                   	pop    %edi
c0109fd0:	5d                   	pop    %ebp
c0109fd1:	c3                   	ret    

c0109fd2 <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
c0109fd2:	f3 0f 1e fb          	endbr32 
c0109fd6:	55                   	push   %ebp
c0109fd7:	89 e5                	mov    %esp,%ebp
    next = seed;
c0109fd9:	8b 45 08             	mov    0x8(%ebp),%eax
c0109fdc:	ba 00 00 00 00       	mov    $0x0,%edx
c0109fe1:	a3 88 8a 12 c0       	mov    %eax,0xc0128a88
c0109fe6:	89 15 8c 8a 12 c0    	mov    %edx,0xc0128a8c
}
c0109fec:	90                   	nop
c0109fed:	5d                   	pop    %ebp
c0109fee:	c3                   	ret    
