
bin/kernel：     文件格式 elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 c0 12 00       	mov    $0x12c000,%eax
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
c0100020:	a3 00 c0 12 c0       	mov    %eax,0xc012c000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 b0 12 c0       	mov    $0xc012b000,%esp
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

static void lab1_switch_test(void);

int
kern_init(void) {
c0100036:	f3 0f 1e fb          	endbr32 
c010003a:	55                   	push   %ebp
c010003b:	89 e5                	mov    %esp,%ebp
c010003d:	83 ec 18             	sub    $0x18,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
c0100040:	b8 60 11 13 c0       	mov    $0xc0131160,%eax
c0100045:	2d 00 e0 12 c0       	sub    $0xc012e000,%eax
c010004a:	83 ec 04             	sub    $0x4,%esp
c010004d:	50                   	push   %eax
c010004e:	6a 00                	push   $0x0
c0100050:	68 00 e0 12 c0       	push   $0xc012e000
c0100055:	e8 8a a2 00 00       	call   c010a2e4 <memset>
c010005a:	83 c4 10             	add    $0x10,%esp

    cons_init();                // init the console
c010005d:	e8 e7 31 00 00       	call   c0103249 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100062:	c7 45 f4 c0 ab 10 c0 	movl   $0xc010abc0,-0xc(%ebp)
    cprintf("%s\n\n", message);
c0100069:	83 ec 08             	sub    $0x8,%esp
c010006c:	ff 75 f4             	pushl  -0xc(%ebp)
c010006f:	68 dc ab 10 c0       	push   $0xc010abdc
c0100074:	e8 39 02 00 00       	call   c01002b2 <cprintf>
c0100079:	83 c4 10             	add    $0x10,%esp

    print_kerninfo();
c010007c:	e8 ae 1c 00 00       	call   c0101d2f <print_kerninfo>

    grade_backtrace();
c0100081:	e8 97 00 00 00       	call   c010011d <grade_backtrace>

    pmm_init();                 // init physical memory management
c0100086:	e8 98 4e 00 00       	call   c0104f23 <pmm_init>

    pic_init();                 // init interrupt controller
c010008b:	e8 41 33 00 00       	call   c01033d1 <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100090:	e8 e3 34 00 00       	call   c0103578 <idt_init>

    vmm_init();                 // init virtual memory management
c0100095:	e8 14 62 00 00       	call   c01062ae <vmm_init>
    proc_init();                // init process table
c010009a:	e8 df 9b 00 00       	call   c0109c7e <proc_init>
    
    ide_init();                 // init ide devices
c010009f:	e8 72 21 00 00       	call   c0102216 <ide_init>
    swap_init();                // init swap
c01000a4:	e8 d6 6a 00 00       	call   c0106b7f <swap_init>

    clock_init();               // init clock interrupt
c01000a9:	e8 e2 28 00 00       	call   c0102990 <clock_init>
    intr_enable();              // enable irq interrupt
c01000ae:	e8 6d 34 00 00       	call   c0103520 <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();
    
    cpu_idle();                 // run idle process
c01000b3:	e8 6c 9d 00 00       	call   c0109e24 <cpu_idle>

c01000b8 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000b8:	f3 0f 1e fb          	endbr32 
c01000bc:	55                   	push   %ebp
c01000bd:	89 e5                	mov    %esp,%ebp
c01000bf:	83 ec 08             	sub    $0x8,%esp
    mon_backtrace(0, NULL, NULL);
c01000c2:	83 ec 04             	sub    $0x4,%esp
c01000c5:	6a 00                	push   $0x0
c01000c7:	6a 00                	push   $0x0
c01000c9:	6a 00                	push   $0x0
c01000cb:	e8 d2 20 00 00       	call   c01021a2 <mon_backtrace>
c01000d0:	83 c4 10             	add    $0x10,%esp
}
c01000d3:	90                   	nop
c01000d4:	c9                   	leave  
c01000d5:	c3                   	ret    

c01000d6 <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000d6:	f3 0f 1e fb          	endbr32 
c01000da:	55                   	push   %ebp
c01000db:	89 e5                	mov    %esp,%ebp
c01000dd:	53                   	push   %ebx
c01000de:	83 ec 04             	sub    $0x4,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000e1:	8d 4d 0c             	lea    0xc(%ebp),%ecx
c01000e4:	8b 55 0c             	mov    0xc(%ebp),%edx
c01000e7:	8d 5d 08             	lea    0x8(%ebp),%ebx
c01000ea:	8b 45 08             	mov    0x8(%ebp),%eax
c01000ed:	51                   	push   %ecx
c01000ee:	52                   	push   %edx
c01000ef:	53                   	push   %ebx
c01000f0:	50                   	push   %eax
c01000f1:	e8 c2 ff ff ff       	call   c01000b8 <grade_backtrace2>
c01000f6:	83 c4 10             	add    $0x10,%esp
}
c01000f9:	90                   	nop
c01000fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01000fd:	c9                   	leave  
c01000fe:	c3                   	ret    

c01000ff <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c01000ff:	f3 0f 1e fb          	endbr32 
c0100103:	55                   	push   %ebp
c0100104:	89 e5                	mov    %esp,%ebp
c0100106:	83 ec 08             	sub    $0x8,%esp
    grade_backtrace1(arg0, arg2);
c0100109:	83 ec 08             	sub    $0x8,%esp
c010010c:	ff 75 10             	pushl  0x10(%ebp)
c010010f:	ff 75 08             	pushl  0x8(%ebp)
c0100112:	e8 bf ff ff ff       	call   c01000d6 <grade_backtrace1>
c0100117:	83 c4 10             	add    $0x10,%esp
}
c010011a:	90                   	nop
c010011b:	c9                   	leave  
c010011c:	c3                   	ret    

c010011d <grade_backtrace>:

void
grade_backtrace(void) {
c010011d:	f3 0f 1e fb          	endbr32 
c0100121:	55                   	push   %ebp
c0100122:	89 e5                	mov    %esp,%ebp
c0100124:	83 ec 08             	sub    $0x8,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c0100127:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c010012c:	83 ec 04             	sub    $0x4,%esp
c010012f:	68 00 00 ff ff       	push   $0xffff0000
c0100134:	50                   	push   %eax
c0100135:	6a 00                	push   $0x0
c0100137:	e8 c3 ff ff ff       	call   c01000ff <grade_backtrace0>
c010013c:	83 c4 10             	add    $0x10,%esp
}
c010013f:	90                   	nop
c0100140:	c9                   	leave  
c0100141:	c3                   	ret    

c0100142 <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c0100142:	f3 0f 1e fb          	endbr32 
c0100146:	55                   	push   %ebp
c0100147:	89 e5                	mov    %esp,%ebp
c0100149:	83 ec 18             	sub    $0x18,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c010014c:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c010014f:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c0100152:	8c 45 f2             	mov    %es,-0xe(%ebp)
c0100155:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c0100158:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010015c:	0f b7 c0             	movzwl %ax,%eax
c010015f:	83 e0 03             	and    $0x3,%eax
c0100162:	89 c2                	mov    %eax,%edx
c0100164:	a1 00 e0 12 c0       	mov    0xc012e000,%eax
c0100169:	83 ec 04             	sub    $0x4,%esp
c010016c:	52                   	push   %edx
c010016d:	50                   	push   %eax
c010016e:	68 e1 ab 10 c0       	push   $0xc010abe1
c0100173:	e8 3a 01 00 00       	call   c01002b2 <cprintf>
c0100178:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  cs = %x\n", round, reg1);
c010017b:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010017f:	0f b7 d0             	movzwl %ax,%edx
c0100182:	a1 00 e0 12 c0       	mov    0xc012e000,%eax
c0100187:	83 ec 04             	sub    $0x4,%esp
c010018a:	52                   	push   %edx
c010018b:	50                   	push   %eax
c010018c:	68 ef ab 10 c0       	push   $0xc010abef
c0100191:	e8 1c 01 00 00       	call   c01002b2 <cprintf>
c0100196:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  ds = %x\n", round, reg2);
c0100199:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c010019d:	0f b7 d0             	movzwl %ax,%edx
c01001a0:	a1 00 e0 12 c0       	mov    0xc012e000,%eax
c01001a5:	83 ec 04             	sub    $0x4,%esp
c01001a8:	52                   	push   %edx
c01001a9:	50                   	push   %eax
c01001aa:	68 fd ab 10 c0       	push   $0xc010abfd
c01001af:	e8 fe 00 00 00       	call   c01002b2 <cprintf>
c01001b4:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  es = %x\n", round, reg3);
c01001b7:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001bb:	0f b7 d0             	movzwl %ax,%edx
c01001be:	a1 00 e0 12 c0       	mov    0xc012e000,%eax
c01001c3:	83 ec 04             	sub    $0x4,%esp
c01001c6:	52                   	push   %edx
c01001c7:	50                   	push   %eax
c01001c8:	68 0b ac 10 c0       	push   $0xc010ac0b
c01001cd:	e8 e0 00 00 00       	call   c01002b2 <cprintf>
c01001d2:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  ss = %x\n", round, reg4);
c01001d5:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001d9:	0f b7 d0             	movzwl %ax,%edx
c01001dc:	a1 00 e0 12 c0       	mov    0xc012e000,%eax
c01001e1:	83 ec 04             	sub    $0x4,%esp
c01001e4:	52                   	push   %edx
c01001e5:	50                   	push   %eax
c01001e6:	68 19 ac 10 c0       	push   $0xc010ac19
c01001eb:	e8 c2 00 00 00       	call   c01002b2 <cprintf>
c01001f0:	83 c4 10             	add    $0x10,%esp
    round ++;
c01001f3:	a1 00 e0 12 c0       	mov    0xc012e000,%eax
c01001f8:	83 c0 01             	add    $0x1,%eax
c01001fb:	a3 00 e0 12 c0       	mov    %eax,0xc012e000
}
c0100200:	90                   	nop
c0100201:	c9                   	leave  
c0100202:	c3                   	ret    

c0100203 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c0100203:	f3 0f 1e fb          	endbr32 
c0100207:	55                   	push   %ebp
c0100208:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
c010020a:	90                   	nop
c010020b:	5d                   	pop    %ebp
c010020c:	c3                   	ret    

c010020d <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c010020d:	f3 0f 1e fb          	endbr32 
c0100211:	55                   	push   %ebp
c0100212:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
c0100214:	90                   	nop
c0100215:	5d                   	pop    %ebp
c0100216:	c3                   	ret    

c0100217 <lab1_switch_test>:

static void
lab1_switch_test(void) {
c0100217:	f3 0f 1e fb          	endbr32 
c010021b:	55                   	push   %ebp
c010021c:	89 e5                	mov    %esp,%ebp
c010021e:	83 ec 08             	sub    $0x8,%esp
    lab1_print_cur_status();
c0100221:	e8 1c ff ff ff       	call   c0100142 <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c0100226:	83 ec 0c             	sub    $0xc,%esp
c0100229:	68 28 ac 10 c0       	push   $0xc010ac28
c010022e:	e8 7f 00 00 00       	call   c01002b2 <cprintf>
c0100233:	83 c4 10             	add    $0x10,%esp
    lab1_switch_to_user();
c0100236:	e8 c8 ff ff ff       	call   c0100203 <lab1_switch_to_user>
    lab1_print_cur_status();
c010023b:	e8 02 ff ff ff       	call   c0100142 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c0100240:	83 ec 0c             	sub    $0xc,%esp
c0100243:	68 48 ac 10 c0       	push   $0xc010ac48
c0100248:	e8 65 00 00 00       	call   c01002b2 <cprintf>
c010024d:	83 c4 10             	add    $0x10,%esp
    lab1_switch_to_kernel();
c0100250:	e8 b8 ff ff ff       	call   c010020d <lab1_switch_to_kernel>
    lab1_print_cur_status();
c0100255:	e8 e8 fe ff ff       	call   c0100142 <lab1_print_cur_status>
}
c010025a:	90                   	nop
c010025b:	c9                   	leave  
c010025c:	c3                   	ret    

c010025d <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c010025d:	f3 0f 1e fb          	endbr32 
c0100261:	55                   	push   %ebp
c0100262:	89 e5                	mov    %esp,%ebp
c0100264:	83 ec 08             	sub    $0x8,%esp
    cons_putc(c);
c0100267:	83 ec 0c             	sub    $0xc,%esp
c010026a:	ff 75 08             	pushl  0x8(%ebp)
c010026d:	e8 0c 30 00 00       	call   c010327e <cons_putc>
c0100272:	83 c4 10             	add    $0x10,%esp
    (*cnt) ++;
c0100275:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100278:	8b 00                	mov    (%eax),%eax
c010027a:	8d 50 01             	lea    0x1(%eax),%edx
c010027d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100280:	89 10                	mov    %edx,(%eax)
}
c0100282:	90                   	nop
c0100283:	c9                   	leave  
c0100284:	c3                   	ret    

c0100285 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c0100285:	f3 0f 1e fb          	endbr32 
c0100289:	55                   	push   %ebp
c010028a:	89 e5                	mov    %esp,%ebp
c010028c:	83 ec 18             	sub    $0x18,%esp
    int cnt = 0;
c010028f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c0100296:	ff 75 0c             	pushl  0xc(%ebp)
c0100299:	ff 75 08             	pushl  0x8(%ebp)
c010029c:	8d 45 f4             	lea    -0xc(%ebp),%eax
c010029f:	50                   	push   %eax
c01002a0:	68 5d 02 10 c0       	push   $0xc010025d
c01002a5:	e8 89 a3 00 00       	call   c010a633 <vprintfmt>
c01002aa:	83 c4 10             	add    $0x10,%esp
    return cnt;
c01002ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01002b0:	c9                   	leave  
c01002b1:	c3                   	ret    

c01002b2 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c01002b2:	f3 0f 1e fb          	endbr32 
c01002b6:	55                   	push   %ebp
c01002b7:	89 e5                	mov    %esp,%ebp
c01002b9:	83 ec 18             	sub    $0x18,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c01002bc:	8d 45 0c             	lea    0xc(%ebp),%eax
c01002bf:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c01002c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002c5:	83 ec 08             	sub    $0x8,%esp
c01002c8:	50                   	push   %eax
c01002c9:	ff 75 08             	pushl  0x8(%ebp)
c01002cc:	e8 b4 ff ff ff       	call   c0100285 <vcprintf>
c01002d1:	83 c4 10             	add    $0x10,%esp
c01002d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c01002d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01002da:	c9                   	leave  
c01002db:	c3                   	ret    

c01002dc <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c01002dc:	f3 0f 1e fb          	endbr32 
c01002e0:	55                   	push   %ebp
c01002e1:	89 e5                	mov    %esp,%ebp
c01002e3:	83 ec 08             	sub    $0x8,%esp
    cons_putc(c);
c01002e6:	83 ec 0c             	sub    $0xc,%esp
c01002e9:	ff 75 08             	pushl  0x8(%ebp)
c01002ec:	e8 8d 2f 00 00       	call   c010327e <cons_putc>
c01002f1:	83 c4 10             	add    $0x10,%esp
}
c01002f4:	90                   	nop
c01002f5:	c9                   	leave  
c01002f6:	c3                   	ret    

c01002f7 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c01002f7:	f3 0f 1e fb          	endbr32 
c01002fb:	55                   	push   %ebp
c01002fc:	89 e5                	mov    %esp,%ebp
c01002fe:	83 ec 18             	sub    $0x18,%esp
    int cnt = 0;
c0100301:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c0100308:	eb 14                	jmp    c010031e <cputs+0x27>
        cputch(c, &cnt);
c010030a:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c010030e:	83 ec 08             	sub    $0x8,%esp
c0100311:	8d 55 f0             	lea    -0x10(%ebp),%edx
c0100314:	52                   	push   %edx
c0100315:	50                   	push   %eax
c0100316:	e8 42 ff ff ff       	call   c010025d <cputch>
c010031b:	83 c4 10             	add    $0x10,%esp
    while ((c = *str ++) != '\0') {
c010031e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100321:	8d 50 01             	lea    0x1(%eax),%edx
c0100324:	89 55 08             	mov    %edx,0x8(%ebp)
c0100327:	0f b6 00             	movzbl (%eax),%eax
c010032a:	88 45 f7             	mov    %al,-0x9(%ebp)
c010032d:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c0100331:	75 d7                	jne    c010030a <cputs+0x13>
    }
    cputch('\n', &cnt);
c0100333:	83 ec 08             	sub    $0x8,%esp
c0100336:	8d 45 f0             	lea    -0x10(%ebp),%eax
c0100339:	50                   	push   %eax
c010033a:	6a 0a                	push   $0xa
c010033c:	e8 1c ff ff ff       	call   c010025d <cputch>
c0100341:	83 c4 10             	add    $0x10,%esp
    return cnt;
c0100344:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0100347:	c9                   	leave  
c0100348:	c3                   	ret    

c0100349 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c0100349:	f3 0f 1e fb          	endbr32 
c010034d:	55                   	push   %ebp
c010034e:	89 e5                	mov    %esp,%ebp
c0100350:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c0100353:	90                   	nop
c0100354:	e8 72 2f 00 00       	call   c01032cb <cons_getc>
c0100359:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010035c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100360:	74 f2                	je     c0100354 <getchar+0xb>
        /* do nothing */;
    return c;
c0100362:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100365:	c9                   	leave  
c0100366:	c3                   	ret    

c0100367 <rb_node_create>:
#include <rb_tree.h>
#include <assert.h>

/* rb_node_create - create a new rb_node */
static inline rb_node *
rb_node_create(void) {
c0100367:	55                   	push   %ebp
c0100368:	89 e5                	mov    %esp,%ebp
c010036a:	83 ec 08             	sub    $0x8,%esp
    return kmalloc(sizeof(rb_node));
c010036d:	83 ec 0c             	sub    $0xc,%esp
c0100370:	6a 10                	push   $0x10
c0100372:	e8 81 78 00 00       	call   c0107bf8 <kmalloc>
c0100377:	83 c4 10             	add    $0x10,%esp
}
c010037a:	c9                   	leave  
c010037b:	c3                   	ret    

c010037c <rb_tree_empty>:

/* rb_tree_empty - tests if tree is empty */
static inline bool
rb_tree_empty(rb_tree *tree) {
c010037c:	55                   	push   %ebp
c010037d:	89 e5                	mov    %esp,%ebp
c010037f:	83 ec 10             	sub    $0x10,%esp
    rb_node *nil = tree->nil, *root = tree->root;
c0100382:	8b 45 08             	mov    0x8(%ebp),%eax
c0100385:	8b 40 04             	mov    0x4(%eax),%eax
c0100388:	89 45 fc             	mov    %eax,-0x4(%ebp)
c010038b:	8b 45 08             	mov    0x8(%ebp),%eax
c010038e:	8b 40 08             	mov    0x8(%eax),%eax
c0100391:	89 45 f8             	mov    %eax,-0x8(%ebp)
    return root->left == nil;
c0100394:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100397:	8b 40 08             	mov    0x8(%eax),%eax
c010039a:	39 45 fc             	cmp    %eax,-0x4(%ebp)
c010039d:	0f 94 c0             	sete   %al
c01003a0:	0f b6 c0             	movzbl %al,%eax
}
c01003a3:	c9                   	leave  
c01003a4:	c3                   	ret    

c01003a5 <rb_tree_create>:
 * Note that, root->left should always point to the node that is the root
 * of the tree. And nil points to a 'NULL' node which should always be
 * black and may have arbitrary children and parent node.
 * */
rb_tree *
rb_tree_create(int (*compare)(rb_node *node1, rb_node *node2)) {
c01003a5:	f3 0f 1e fb          	endbr32 
c01003a9:	55                   	push   %ebp
c01003aa:	89 e5                	mov    %esp,%ebp
c01003ac:	83 ec 18             	sub    $0x18,%esp
    assert(compare != NULL);
c01003af:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01003b3:	75 16                	jne    c01003cb <rb_tree_create+0x26>
c01003b5:	68 68 ac 10 c0       	push   $0xc010ac68
c01003ba:	68 78 ac 10 c0       	push   $0xc010ac78
c01003bf:	6a 1f                	push   $0x1f
c01003c1:	68 8d ac 10 c0       	push   $0xc010ac8d
c01003c6:	e8 23 14 00 00       	call   c01017ee <__panic>

    rb_tree *tree;
    rb_node *nil, *root;

    if ((tree = kmalloc(sizeof(rb_tree))) == NULL) {
c01003cb:	83 ec 0c             	sub    $0xc,%esp
c01003ce:	6a 0c                	push   $0xc
c01003d0:	e8 23 78 00 00       	call   c0107bf8 <kmalloc>
c01003d5:	83 c4 10             	add    $0x10,%esp
c01003d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01003db:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01003df:	0f 84 b9 00 00 00    	je     c010049e <rb_tree_create+0xf9>
        goto bad_tree;
    }

    tree->compare = compare;
c01003e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01003e8:	8b 55 08             	mov    0x8(%ebp),%edx
c01003eb:	89 10                	mov    %edx,(%eax)

    if ((nil = rb_node_create()) == NULL) {
c01003ed:	e8 75 ff ff ff       	call   c0100367 <rb_node_create>
c01003f2:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01003f5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01003f9:	0f 84 8e 00 00 00    	je     c010048d <rb_tree_create+0xe8>
        goto bad_node_cleanup_tree;
    }

    nil->parent = nil->left = nil->right = nil;
c01003ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100402:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100405:	89 50 0c             	mov    %edx,0xc(%eax)
c0100408:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010040b:	8b 50 0c             	mov    0xc(%eax),%edx
c010040e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100411:	89 50 08             	mov    %edx,0x8(%eax)
c0100414:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100417:	8b 50 08             	mov    0x8(%eax),%edx
c010041a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010041d:	89 50 04             	mov    %edx,0x4(%eax)
    nil->red = 0;
c0100420:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100423:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    tree->nil = nil;
c0100429:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010042c:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010042f:	89 50 04             	mov    %edx,0x4(%eax)

    if ((root = rb_node_create()) == NULL) {
c0100432:	e8 30 ff ff ff       	call   c0100367 <rb_node_create>
c0100437:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010043a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010043e:	74 38                	je     c0100478 <rb_tree_create+0xd3>
        goto bad_node_cleanup_nil;
    }

    root->parent = root->left = root->right = nil;
c0100440:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100443:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100446:	89 50 0c             	mov    %edx,0xc(%eax)
c0100449:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010044c:	8b 50 0c             	mov    0xc(%eax),%edx
c010044f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100452:	89 50 08             	mov    %edx,0x8(%eax)
c0100455:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100458:	8b 50 08             	mov    0x8(%eax),%edx
c010045b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010045e:	89 50 04             	mov    %edx,0x4(%eax)
    root->red = 0;
c0100461:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100464:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    tree->root = root;
c010046a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010046d:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0100470:	89 50 08             	mov    %edx,0x8(%eax)
    return tree;
c0100473:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100476:	eb 2c                	jmp    c01004a4 <rb_tree_create+0xff>
        goto bad_node_cleanup_nil;
c0100478:	90                   	nop
c0100479:	f3 0f 1e fb          	endbr32 

bad_node_cleanup_nil:
    kfree(nil);
c010047d:	83 ec 0c             	sub    $0xc,%esp
c0100480:	ff 75 f0             	pushl  -0x10(%ebp)
c0100483:	e8 8c 77 00 00       	call   c0107c14 <kfree>
c0100488:	83 c4 10             	add    $0x10,%esp
c010048b:	eb 01                	jmp    c010048e <rb_tree_create+0xe9>
        goto bad_node_cleanup_tree;
c010048d:	90                   	nop
bad_node_cleanup_tree:
    kfree(tree);
c010048e:	83 ec 0c             	sub    $0xc,%esp
c0100491:	ff 75 f4             	pushl  -0xc(%ebp)
c0100494:	e8 7b 77 00 00       	call   c0107c14 <kfree>
c0100499:	83 c4 10             	add    $0x10,%esp
c010049c:	eb 01                	jmp    c010049f <rb_tree_create+0xfa>
        goto bad_tree;
c010049e:	90                   	nop
bad_tree:
    return NULL;
c010049f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01004a4:	c9                   	leave  
c01004a5:	c3                   	ret    

c01004a6 <rb_left_rotate>:
    y->_left = x;                                               \
    x->parent = y;                                              \
    assert(!(nil->red));                                        \
}

FUNC_ROTATE(rb_left_rotate, left, right);
c01004a6:	f3 0f 1e fb          	endbr32 
c01004aa:	55                   	push   %ebp
c01004ab:	89 e5                	mov    %esp,%ebp
c01004ad:	83 ec 18             	sub    $0x18,%esp
c01004b0:	8b 45 08             	mov    0x8(%ebp),%eax
c01004b3:	8b 40 04             	mov    0x4(%eax),%eax
c01004b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01004b9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004bc:	8b 40 0c             	mov    0xc(%eax),%eax
c01004bf:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01004c2:	8b 45 08             	mov    0x8(%ebp),%eax
c01004c5:	8b 40 08             	mov    0x8(%eax),%eax
c01004c8:	39 45 0c             	cmp    %eax,0xc(%ebp)
c01004cb:	74 10                	je     c01004dd <rb_left_rotate+0x37>
c01004cd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004d0:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01004d3:	74 08                	je     c01004dd <rb_left_rotate+0x37>
c01004d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004d8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01004db:	75 16                	jne    c01004f3 <rb_left_rotate+0x4d>
c01004dd:	68 a4 ac 10 c0       	push   $0xc010aca4
c01004e2:	68 78 ac 10 c0       	push   $0xc010ac78
c01004e7:	6a 64                	push   $0x64
c01004e9:	68 8d ac 10 c0       	push   $0xc010ac8d
c01004ee:	e8 fb 12 00 00       	call   c01017ee <__panic>
c01004f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004f6:	8b 50 08             	mov    0x8(%eax),%edx
c01004f9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004fc:	89 50 0c             	mov    %edx,0xc(%eax)
c01004ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100502:	8b 40 08             	mov    0x8(%eax),%eax
c0100505:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0100508:	74 0c                	je     c0100516 <rb_left_rotate+0x70>
c010050a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010050d:	8b 40 08             	mov    0x8(%eax),%eax
c0100510:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100513:	89 50 04             	mov    %edx,0x4(%eax)
c0100516:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100519:	8b 50 04             	mov    0x4(%eax),%edx
c010051c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010051f:	89 50 04             	mov    %edx,0x4(%eax)
c0100522:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100525:	8b 40 04             	mov    0x4(%eax),%eax
c0100528:	8b 40 08             	mov    0x8(%eax),%eax
c010052b:	39 45 0c             	cmp    %eax,0xc(%ebp)
c010052e:	75 0e                	jne    c010053e <rb_left_rotate+0x98>
c0100530:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100533:	8b 40 04             	mov    0x4(%eax),%eax
c0100536:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100539:	89 50 08             	mov    %edx,0x8(%eax)
c010053c:	eb 0c                	jmp    c010054a <rb_left_rotate+0xa4>
c010053e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100541:	8b 40 04             	mov    0x4(%eax),%eax
c0100544:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100547:	89 50 0c             	mov    %edx,0xc(%eax)
c010054a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010054d:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100550:	89 50 08             	mov    %edx,0x8(%eax)
c0100553:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100556:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100559:	89 50 04             	mov    %edx,0x4(%eax)
c010055c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010055f:	8b 00                	mov    (%eax),%eax
c0100561:	85 c0                	test   %eax,%eax
c0100563:	74 16                	je     c010057b <rb_left_rotate+0xd5>
c0100565:	68 cc ac 10 c0       	push   $0xc010accc
c010056a:	68 78 ac 10 c0       	push   $0xc010ac78
c010056f:	6a 64                	push   $0x64
c0100571:	68 8d ac 10 c0       	push   $0xc010ac8d
c0100576:	e8 73 12 00 00       	call   c01017ee <__panic>
c010057b:	90                   	nop
c010057c:	c9                   	leave  
c010057d:	c3                   	ret    

c010057e <rb_right_rotate>:
FUNC_ROTATE(rb_right_rotate, right, left);
c010057e:	f3 0f 1e fb          	endbr32 
c0100582:	55                   	push   %ebp
c0100583:	89 e5                	mov    %esp,%ebp
c0100585:	83 ec 18             	sub    $0x18,%esp
c0100588:	8b 45 08             	mov    0x8(%ebp),%eax
c010058b:	8b 40 04             	mov    0x4(%eax),%eax
c010058e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100591:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100594:	8b 40 08             	mov    0x8(%eax),%eax
c0100597:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010059a:	8b 45 08             	mov    0x8(%ebp),%eax
c010059d:	8b 40 08             	mov    0x8(%eax),%eax
c01005a0:	39 45 0c             	cmp    %eax,0xc(%ebp)
c01005a3:	74 10                	je     c01005b5 <rb_right_rotate+0x37>
c01005a5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005a8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01005ab:	74 08                	je     c01005b5 <rb_right_rotate+0x37>
c01005ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005b0:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01005b3:	75 16                	jne    c01005cb <rb_right_rotate+0x4d>
c01005b5:	68 a4 ac 10 c0       	push   $0xc010aca4
c01005ba:	68 78 ac 10 c0       	push   $0xc010ac78
c01005bf:	6a 65                	push   $0x65
c01005c1:	68 8d ac 10 c0       	push   $0xc010ac8d
c01005c6:	e8 23 12 00 00       	call   c01017ee <__panic>
c01005cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005ce:	8b 50 0c             	mov    0xc(%eax),%edx
c01005d1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005d4:	89 50 08             	mov    %edx,0x8(%eax)
c01005d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005da:	8b 40 0c             	mov    0xc(%eax),%eax
c01005dd:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01005e0:	74 0c                	je     c01005ee <rb_right_rotate+0x70>
c01005e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005e5:	8b 40 0c             	mov    0xc(%eax),%eax
c01005e8:	8b 55 0c             	mov    0xc(%ebp),%edx
c01005eb:	89 50 04             	mov    %edx,0x4(%eax)
c01005ee:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005f1:	8b 50 04             	mov    0x4(%eax),%edx
c01005f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005f7:	89 50 04             	mov    %edx,0x4(%eax)
c01005fa:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005fd:	8b 40 04             	mov    0x4(%eax),%eax
c0100600:	8b 40 0c             	mov    0xc(%eax),%eax
c0100603:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0100606:	75 0e                	jne    c0100616 <rb_right_rotate+0x98>
c0100608:	8b 45 0c             	mov    0xc(%ebp),%eax
c010060b:	8b 40 04             	mov    0x4(%eax),%eax
c010060e:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100611:	89 50 0c             	mov    %edx,0xc(%eax)
c0100614:	eb 0c                	jmp    c0100622 <rb_right_rotate+0xa4>
c0100616:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100619:	8b 40 04             	mov    0x4(%eax),%eax
c010061c:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010061f:	89 50 08             	mov    %edx,0x8(%eax)
c0100622:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100625:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100628:	89 50 0c             	mov    %edx,0xc(%eax)
c010062b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010062e:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100631:	89 50 04             	mov    %edx,0x4(%eax)
c0100634:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100637:	8b 00                	mov    (%eax),%eax
c0100639:	85 c0                	test   %eax,%eax
c010063b:	74 16                	je     c0100653 <rb_right_rotate+0xd5>
c010063d:	68 cc ac 10 c0       	push   $0xc010accc
c0100642:	68 78 ac 10 c0       	push   $0xc010ac78
c0100647:	6a 65                	push   $0x65
c0100649:	68 8d ac 10 c0       	push   $0xc010ac8d
c010064e:	e8 9b 11 00 00       	call   c01017ee <__panic>
c0100653:	90                   	nop
c0100654:	c9                   	leave  
c0100655:	c3                   	ret    

c0100656 <rb_insert_binary>:
 * rb_insert_binary - insert @node to red-black @tree as if it were
 * a regular binary tree. This function is only intended to be called
 * by function rb_insert.
 * */
static inline void
rb_insert_binary(rb_tree *tree, rb_node *node) {
c0100656:	55                   	push   %ebp
c0100657:	89 e5                	mov    %esp,%ebp
c0100659:	83 ec 28             	sub    $0x28,%esp
    rb_node *x, *y, *z = node, *nil = tree->nil, *root = tree->root;
c010065c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010065f:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0100662:	8b 45 08             	mov    0x8(%ebp),%eax
c0100665:	8b 40 04             	mov    0x4(%eax),%eax
c0100668:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010066b:	8b 45 08             	mov    0x8(%ebp),%eax
c010066e:	8b 40 08             	mov    0x8(%eax),%eax
c0100671:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    z->left = z->right = nil;
c0100674:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100677:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010067a:	89 50 0c             	mov    %edx,0xc(%eax)
c010067d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100680:	8b 50 0c             	mov    0xc(%eax),%edx
c0100683:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100686:	89 50 08             	mov    %edx,0x8(%eax)
    y = root, x = y->left;
c0100689:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010068c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010068f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100692:	8b 40 08             	mov    0x8(%eax),%eax
c0100695:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while (x != nil) {
c0100698:	eb 2e                	jmp    c01006c8 <rb_insert_binary+0x72>
        y = x;
c010069a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010069d:	89 45 f0             	mov    %eax,-0x10(%ebp)
        x = (COMPARE(tree, x, node) > 0) ? x->left : x->right;
c01006a0:	8b 45 08             	mov    0x8(%ebp),%eax
c01006a3:	8b 00                	mov    (%eax),%eax
c01006a5:	83 ec 08             	sub    $0x8,%esp
c01006a8:	ff 75 0c             	pushl  0xc(%ebp)
c01006ab:	ff 75 f4             	pushl  -0xc(%ebp)
c01006ae:	ff d0                	call   *%eax
c01006b0:	83 c4 10             	add    $0x10,%esp
c01006b3:	85 c0                	test   %eax,%eax
c01006b5:	7e 08                	jle    c01006bf <rb_insert_binary+0x69>
c01006b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006ba:	8b 40 08             	mov    0x8(%eax),%eax
c01006bd:	eb 06                	jmp    c01006c5 <rb_insert_binary+0x6f>
c01006bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006c2:	8b 40 0c             	mov    0xc(%eax),%eax
c01006c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while (x != nil) {
c01006c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006cb:	3b 45 e8             	cmp    -0x18(%ebp),%eax
c01006ce:	75 ca                	jne    c010069a <rb_insert_binary+0x44>
    }
    z->parent = y;
c01006d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01006d3:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01006d6:	89 50 04             	mov    %edx,0x4(%eax)
    if (y == root || COMPARE(tree, y, z) > 0) {
c01006d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01006dc:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
c01006df:	74 17                	je     c01006f8 <rb_insert_binary+0xa2>
c01006e1:	8b 45 08             	mov    0x8(%ebp),%eax
c01006e4:	8b 00                	mov    (%eax),%eax
c01006e6:	83 ec 08             	sub    $0x8,%esp
c01006e9:	ff 75 ec             	pushl  -0x14(%ebp)
c01006ec:	ff 75 f0             	pushl  -0x10(%ebp)
c01006ef:	ff d0                	call   *%eax
c01006f1:	83 c4 10             	add    $0x10,%esp
c01006f4:	85 c0                	test   %eax,%eax
c01006f6:	7e 0b                	jle    c0100703 <rb_insert_binary+0xad>
        y->left = z;
c01006f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01006fb:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01006fe:	89 50 08             	mov    %edx,0x8(%eax)
c0100701:	eb 0a                	jmp    c010070d <rb_insert_binary+0xb7>
    }
    else {
        y->right = z;
c0100703:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100706:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0100709:	89 50 0c             	mov    %edx,0xc(%eax)
    }
}
c010070c:	90                   	nop
c010070d:	90                   	nop
c010070e:	c9                   	leave  
c010070f:	c3                   	ret    

c0100710 <rb_insert>:

/* rb_insert - insert a node to red-black tree */
void
rb_insert(rb_tree *tree, rb_node *node) {
c0100710:	f3 0f 1e fb          	endbr32 
c0100714:	55                   	push   %ebp
c0100715:	89 e5                	mov    %esp,%ebp
c0100717:	83 ec 18             	sub    $0x18,%esp
    rb_insert_binary(tree, node);
c010071a:	83 ec 08             	sub    $0x8,%esp
c010071d:	ff 75 0c             	pushl  0xc(%ebp)
c0100720:	ff 75 08             	pushl  0x8(%ebp)
c0100723:	e8 2e ff ff ff       	call   c0100656 <rb_insert_binary>
c0100728:	83 c4 10             	add    $0x10,%esp
    node->red = 1;
c010072b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010072e:	c7 00 01 00 00 00    	movl   $0x1,(%eax)

    rb_node *x = node, *y;
c0100734:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100737:	89 45 f4             	mov    %eax,-0xc(%ebp)
            x->parent->parent->red = 1;                         \
            rb_##_right##_rotate(tree, x->parent->parent);      \
        }                                                       \
    } while (0)

    while (x->parent->red) {
c010073a:	e9 6c 01 00 00       	jmp    c01008ab <rb_insert+0x19b>
        if (x->parent == x->parent->parent->left) {
c010073f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100742:	8b 50 04             	mov    0x4(%eax),%edx
c0100745:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100748:	8b 40 04             	mov    0x4(%eax),%eax
c010074b:	8b 40 04             	mov    0x4(%eax),%eax
c010074e:	8b 40 08             	mov    0x8(%eax),%eax
c0100751:	39 c2                	cmp    %eax,%edx
c0100753:	0f 85 ad 00 00 00    	jne    c0100806 <rb_insert+0xf6>
            RB_INSERT_SUB(left, right);
c0100759:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010075c:	8b 40 04             	mov    0x4(%eax),%eax
c010075f:	8b 40 04             	mov    0x4(%eax),%eax
c0100762:	8b 40 0c             	mov    0xc(%eax),%eax
c0100765:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100768:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010076b:	8b 00                	mov    (%eax),%eax
c010076d:	85 c0                	test   %eax,%eax
c010076f:	74 35                	je     c01007a6 <rb_insert+0x96>
c0100771:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100774:	8b 40 04             	mov    0x4(%eax),%eax
c0100777:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c010077d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100780:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100786:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100789:	8b 40 04             	mov    0x4(%eax),%eax
c010078c:	8b 40 04             	mov    0x4(%eax),%eax
c010078f:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c0100795:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100798:	8b 40 04             	mov    0x4(%eax),%eax
c010079b:	8b 40 04             	mov    0x4(%eax),%eax
c010079e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01007a1:	e9 05 01 00 00       	jmp    c01008ab <rb_insert+0x19b>
c01007a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007a9:	8b 40 04             	mov    0x4(%eax),%eax
c01007ac:	8b 40 0c             	mov    0xc(%eax),%eax
c01007af:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01007b2:	75 1a                	jne    c01007ce <rb_insert+0xbe>
c01007b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007b7:	8b 40 04             	mov    0x4(%eax),%eax
c01007ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01007bd:	83 ec 08             	sub    $0x8,%esp
c01007c0:	ff 75 f4             	pushl  -0xc(%ebp)
c01007c3:	ff 75 08             	pushl  0x8(%ebp)
c01007c6:	e8 db fc ff ff       	call   c01004a6 <rb_left_rotate>
c01007cb:	83 c4 10             	add    $0x10,%esp
c01007ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007d1:	8b 40 04             	mov    0x4(%eax),%eax
c01007d4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c01007da:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007dd:	8b 40 04             	mov    0x4(%eax),%eax
c01007e0:	8b 40 04             	mov    0x4(%eax),%eax
c01007e3:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c01007e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007ec:	8b 40 04             	mov    0x4(%eax),%eax
c01007ef:	8b 40 04             	mov    0x4(%eax),%eax
c01007f2:	83 ec 08             	sub    $0x8,%esp
c01007f5:	50                   	push   %eax
c01007f6:	ff 75 08             	pushl  0x8(%ebp)
c01007f9:	e8 80 fd ff ff       	call   c010057e <rb_right_rotate>
c01007fe:	83 c4 10             	add    $0x10,%esp
c0100801:	e9 a5 00 00 00       	jmp    c01008ab <rb_insert+0x19b>
        }
        else {
            RB_INSERT_SUB(right, left);
c0100806:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100809:	8b 40 04             	mov    0x4(%eax),%eax
c010080c:	8b 40 04             	mov    0x4(%eax),%eax
c010080f:	8b 40 08             	mov    0x8(%eax),%eax
c0100812:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100815:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100818:	8b 00                	mov    (%eax),%eax
c010081a:	85 c0                	test   %eax,%eax
c010081c:	74 32                	je     c0100850 <rb_insert+0x140>
c010081e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100821:	8b 40 04             	mov    0x4(%eax),%eax
c0100824:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c010082a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010082d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100833:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100836:	8b 40 04             	mov    0x4(%eax),%eax
c0100839:	8b 40 04             	mov    0x4(%eax),%eax
c010083c:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c0100842:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100845:	8b 40 04             	mov    0x4(%eax),%eax
c0100848:	8b 40 04             	mov    0x4(%eax),%eax
c010084b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010084e:	eb 5b                	jmp    c01008ab <rb_insert+0x19b>
c0100850:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100853:	8b 40 04             	mov    0x4(%eax),%eax
c0100856:	8b 40 08             	mov    0x8(%eax),%eax
c0100859:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010085c:	75 1a                	jne    c0100878 <rb_insert+0x168>
c010085e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100861:	8b 40 04             	mov    0x4(%eax),%eax
c0100864:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100867:	83 ec 08             	sub    $0x8,%esp
c010086a:	ff 75 f4             	pushl  -0xc(%ebp)
c010086d:	ff 75 08             	pushl  0x8(%ebp)
c0100870:	e8 09 fd ff ff       	call   c010057e <rb_right_rotate>
c0100875:	83 c4 10             	add    $0x10,%esp
c0100878:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010087b:	8b 40 04             	mov    0x4(%eax),%eax
c010087e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100884:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100887:	8b 40 04             	mov    0x4(%eax),%eax
c010088a:	8b 40 04             	mov    0x4(%eax),%eax
c010088d:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c0100893:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100896:	8b 40 04             	mov    0x4(%eax),%eax
c0100899:	8b 40 04             	mov    0x4(%eax),%eax
c010089c:	83 ec 08             	sub    $0x8,%esp
c010089f:	50                   	push   %eax
c01008a0:	ff 75 08             	pushl  0x8(%ebp)
c01008a3:	e8 fe fb ff ff       	call   c01004a6 <rb_left_rotate>
c01008a8:	83 c4 10             	add    $0x10,%esp
    while (x->parent->red) {
c01008ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008ae:	8b 40 04             	mov    0x4(%eax),%eax
c01008b1:	8b 00                	mov    (%eax),%eax
c01008b3:	85 c0                	test   %eax,%eax
c01008b5:	0f 85 84 fe ff ff    	jne    c010073f <rb_insert+0x2f>
        }
    }
    tree->root->left->red = 0;
c01008bb:	8b 45 08             	mov    0x8(%ebp),%eax
c01008be:	8b 40 08             	mov    0x8(%eax),%eax
c01008c1:	8b 40 08             	mov    0x8(%eax),%eax
c01008c4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    assert(!(tree->nil->red) && !(tree->root->red));
c01008ca:	8b 45 08             	mov    0x8(%ebp),%eax
c01008cd:	8b 40 04             	mov    0x4(%eax),%eax
c01008d0:	8b 00                	mov    (%eax),%eax
c01008d2:	85 c0                	test   %eax,%eax
c01008d4:	75 0c                	jne    c01008e2 <rb_insert+0x1d2>
c01008d6:	8b 45 08             	mov    0x8(%ebp),%eax
c01008d9:	8b 40 08             	mov    0x8(%eax),%eax
c01008dc:	8b 00                	mov    (%eax),%eax
c01008de:	85 c0                	test   %eax,%eax
c01008e0:	74 19                	je     c01008fb <rb_insert+0x1eb>
c01008e2:	68 d8 ac 10 c0       	push   $0xc010acd8
c01008e7:	68 78 ac 10 c0       	push   $0xc010ac78
c01008ec:	68 a9 00 00 00       	push   $0xa9
c01008f1:	68 8d ac 10 c0       	push   $0xc010ac8d
c01008f6:	e8 f3 0e 00 00       	call   c01017ee <__panic>

#undef RB_INSERT_SUB
}
c01008fb:	90                   	nop
c01008fc:	c9                   	leave  
c01008fd:	c3                   	ret    

c01008fe <rb_tree_successor>:
 * rb_tree_successor - returns the successor of @node, or nil
 * if no successor exists. Make sure that @node must belong to @tree,
 * and this function should only be called by rb_node_prev.
 * */
static inline rb_node *
rb_tree_successor(rb_tree *tree, rb_node *node) {
c01008fe:	55                   	push   %ebp
c01008ff:	89 e5                	mov    %esp,%ebp
c0100901:	83 ec 10             	sub    $0x10,%esp
    rb_node *x = node, *y, *nil = tree->nil;
c0100904:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100907:	89 45 fc             	mov    %eax,-0x4(%ebp)
c010090a:	8b 45 08             	mov    0x8(%ebp),%eax
c010090d:	8b 40 04             	mov    0x4(%eax),%eax
c0100910:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if ((y = x->right) != nil) {
c0100913:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100916:	8b 40 0c             	mov    0xc(%eax),%eax
c0100919:	89 45 f8             	mov    %eax,-0x8(%ebp)
c010091c:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010091f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100922:	74 1b                	je     c010093f <rb_tree_successor+0x41>
        while (y->left != nil) {
c0100924:	eb 09                	jmp    c010092f <rb_tree_successor+0x31>
            y = y->left;
c0100926:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100929:	8b 40 08             	mov    0x8(%eax),%eax
c010092c:	89 45 f8             	mov    %eax,-0x8(%ebp)
        while (y->left != nil) {
c010092f:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100932:	8b 40 08             	mov    0x8(%eax),%eax
c0100935:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0100938:	75 ec                	jne    c0100926 <rb_tree_successor+0x28>
        }
        return y;
c010093a:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010093d:	eb 38                	jmp    c0100977 <rb_tree_successor+0x79>
    }
    else {
        y = x->parent;
c010093f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100942:	8b 40 04             	mov    0x4(%eax),%eax
c0100945:	89 45 f8             	mov    %eax,-0x8(%ebp)
        while (x == y->right) {
c0100948:	eb 0f                	jmp    c0100959 <rb_tree_successor+0x5b>
            x = y, y = y->parent;
c010094a:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010094d:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100950:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100953:	8b 40 04             	mov    0x4(%eax),%eax
c0100956:	89 45 f8             	mov    %eax,-0x8(%ebp)
        while (x == y->right) {
c0100959:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010095c:	8b 40 0c             	mov    0xc(%eax),%eax
c010095f:	39 45 fc             	cmp    %eax,-0x4(%ebp)
c0100962:	74 e6                	je     c010094a <rb_tree_successor+0x4c>
        }
        if (y == tree->root) {
c0100964:	8b 45 08             	mov    0x8(%ebp),%eax
c0100967:	8b 40 08             	mov    0x8(%eax),%eax
c010096a:	39 45 f8             	cmp    %eax,-0x8(%ebp)
c010096d:	75 05                	jne    c0100974 <rb_tree_successor+0x76>
            return nil;
c010096f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100972:	eb 03                	jmp    c0100977 <rb_tree_successor+0x79>
        }
        return y;
c0100974:	8b 45 f8             	mov    -0x8(%ebp),%eax
    }
}
c0100977:	c9                   	leave  
c0100978:	c3                   	ret    

c0100979 <rb_tree_predecessor>:
/* *
 * rb_tree_predecessor - returns the predecessor of @node, or nil
 * if no predecessor exists, likes rb_tree_successor.
 * */
static inline rb_node *
rb_tree_predecessor(rb_tree *tree, rb_node *node) {
c0100979:	55                   	push   %ebp
c010097a:	89 e5                	mov    %esp,%ebp
c010097c:	83 ec 10             	sub    $0x10,%esp
    rb_node *x = node, *y, *nil = tree->nil;
c010097f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100982:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100985:	8b 45 08             	mov    0x8(%ebp),%eax
c0100988:	8b 40 04             	mov    0x4(%eax),%eax
c010098b:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if ((y = x->left) != nil) {
c010098e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100991:	8b 40 08             	mov    0x8(%eax),%eax
c0100994:	89 45 f8             	mov    %eax,-0x8(%ebp)
c0100997:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010099a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010099d:	74 1b                	je     c01009ba <rb_tree_predecessor+0x41>
        while (y->right != nil) {
c010099f:	eb 09                	jmp    c01009aa <rb_tree_predecessor+0x31>
            y = y->right;
c01009a1:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01009a4:	8b 40 0c             	mov    0xc(%eax),%eax
c01009a7:	89 45 f8             	mov    %eax,-0x8(%ebp)
        while (y->right != nil) {
c01009aa:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01009ad:	8b 40 0c             	mov    0xc(%eax),%eax
c01009b0:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01009b3:	75 ec                	jne    c01009a1 <rb_tree_predecessor+0x28>
        }
        return y;
c01009b5:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01009b8:	eb 38                	jmp    c01009f2 <rb_tree_predecessor+0x79>
    }
    else {
        y = x->parent;
c01009ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01009bd:	8b 40 04             	mov    0x4(%eax),%eax
c01009c0:	89 45 f8             	mov    %eax,-0x8(%ebp)
        while (x == y->left) {
c01009c3:	eb 1f                	jmp    c01009e4 <rb_tree_predecessor+0x6b>
            if (y == tree->root) {
c01009c5:	8b 45 08             	mov    0x8(%ebp),%eax
c01009c8:	8b 40 08             	mov    0x8(%eax),%eax
c01009cb:	39 45 f8             	cmp    %eax,-0x8(%ebp)
c01009ce:	75 05                	jne    c01009d5 <rb_tree_predecessor+0x5c>
                return nil;
c01009d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01009d3:	eb 1d                	jmp    c01009f2 <rb_tree_predecessor+0x79>
            }
            x = y, y = y->parent;
c01009d5:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01009d8:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01009db:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01009de:	8b 40 04             	mov    0x4(%eax),%eax
c01009e1:	89 45 f8             	mov    %eax,-0x8(%ebp)
        while (x == y->left) {
c01009e4:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01009e7:	8b 40 08             	mov    0x8(%eax),%eax
c01009ea:	39 45 fc             	cmp    %eax,-0x4(%ebp)
c01009ed:	74 d6                	je     c01009c5 <rb_tree_predecessor+0x4c>
        }
        return y;
c01009ef:	8b 45 f8             	mov    -0x8(%ebp),%eax
    }
}
c01009f2:	c9                   	leave  
c01009f3:	c3                   	ret    

c01009f4 <rb_search>:
 * rb_search - returns a node with value 'equal' to @key (according to
 * function @compare). If there're multiple nodes with value 'equal' to @key,
 * the functions returns the one highest in the tree.
 * */
rb_node *
rb_search(rb_tree *tree, int (*compare)(rb_node *node, void *key), void *key) {
c01009f4:	f3 0f 1e fb          	endbr32 
c01009f8:	55                   	push   %ebp
c01009f9:	89 e5                	mov    %esp,%ebp
c01009fb:	83 ec 18             	sub    $0x18,%esp
    rb_node *nil = tree->nil, *node = tree->root->left;
c01009fe:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a01:	8b 40 04             	mov    0x4(%eax),%eax
c0100a04:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100a07:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a0a:	8b 40 08             	mov    0x8(%eax),%eax
c0100a0d:	8b 40 08             	mov    0x8(%eax),%eax
c0100a10:	89 45 f4             	mov    %eax,-0xc(%ebp)
    int r;
    while (node != nil && (r = compare(node, key)) != 0) {
c0100a13:	eb 17                	jmp    c0100a2c <rb_search+0x38>
        node = (r > 0) ? node->left : node->right;
c0100a15:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0100a19:	7e 08                	jle    c0100a23 <rb_search+0x2f>
c0100a1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a1e:	8b 40 08             	mov    0x8(%eax),%eax
c0100a21:	eb 06                	jmp    c0100a29 <rb_search+0x35>
c0100a23:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a26:	8b 40 0c             	mov    0xc(%eax),%eax
c0100a29:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while (node != nil && (r = compare(node, key)) != 0) {
c0100a2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a2f:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0100a32:	74 1a                	je     c0100a4e <rb_search+0x5a>
c0100a34:	83 ec 08             	sub    $0x8,%esp
c0100a37:	ff 75 10             	pushl  0x10(%ebp)
c0100a3a:	ff 75 f4             	pushl  -0xc(%ebp)
c0100a3d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100a40:	ff d0                	call   *%eax
c0100a42:	83 c4 10             	add    $0x10,%esp
c0100a45:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0100a48:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0100a4c:	75 c7                	jne    c0100a15 <rb_search+0x21>
    }
    return (node != nil) ? node : NULL;
c0100a4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a51:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0100a54:	74 05                	je     c0100a5b <rb_search+0x67>
c0100a56:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a59:	eb 05                	jmp    c0100a60 <rb_search+0x6c>
c0100a5b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100a60:	c9                   	leave  
c0100a61:	c3                   	ret    

c0100a62 <rb_delete_fixup>:
/* *
 * rb_delete_fixup - performs rotations and changes colors to restore
 * red-black properties after a node is deleted.
 * */
static void
rb_delete_fixup(rb_tree *tree, rb_node *node) {
c0100a62:	f3 0f 1e fb          	endbr32 
c0100a66:	55                   	push   %ebp
c0100a67:	89 e5                	mov    %esp,%ebp
c0100a69:	83 ec 18             	sub    $0x18,%esp
    rb_node *x = node, *w, *root = tree->root->left;
c0100a6c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100a6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100a72:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a75:	8b 40 08             	mov    0x8(%eax),%eax
c0100a78:	8b 40 08             	mov    0x8(%eax),%eax
c0100a7b:	89 45 ec             	mov    %eax,-0x14(%ebp)
            rb_##_left##_rotate(tree, x->parent);               \
            x = root;                                           \
        }                                                       \
    } while (0)

    while (x != root && !x->red) {
c0100a7e:	e9 04 02 00 00       	jmp    c0100c87 <rb_delete_fixup+0x225>
        if (x == x->parent->left) {
c0100a83:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a86:	8b 40 04             	mov    0x4(%eax),%eax
c0100a89:	8b 40 08             	mov    0x8(%eax),%eax
c0100a8c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0100a8f:	0f 85 fd 00 00 00    	jne    c0100b92 <rb_delete_fixup+0x130>
            RB_DELETE_FIXUP_SUB(left, right);
c0100a95:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a98:	8b 40 04             	mov    0x4(%eax),%eax
c0100a9b:	8b 40 0c             	mov    0xc(%eax),%eax
c0100a9e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100aa1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100aa4:	8b 00                	mov    (%eax),%eax
c0100aa6:	85 c0                	test   %eax,%eax
c0100aa8:	74 36                	je     c0100ae0 <rb_delete_fixup+0x7e>
c0100aaa:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100aad:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100ab3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ab6:	8b 40 04             	mov    0x4(%eax),%eax
c0100ab9:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c0100abf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ac2:	8b 40 04             	mov    0x4(%eax),%eax
c0100ac5:	83 ec 08             	sub    $0x8,%esp
c0100ac8:	50                   	push   %eax
c0100ac9:	ff 75 08             	pushl  0x8(%ebp)
c0100acc:	e8 d5 f9 ff ff       	call   c01004a6 <rb_left_rotate>
c0100ad1:	83 c4 10             	add    $0x10,%esp
c0100ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ad7:	8b 40 04             	mov    0x4(%eax),%eax
c0100ada:	8b 40 0c             	mov    0xc(%eax),%eax
c0100add:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100ae0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100ae3:	8b 40 08             	mov    0x8(%eax),%eax
c0100ae6:	8b 00                	mov    (%eax),%eax
c0100ae8:	85 c0                	test   %eax,%eax
c0100aea:	75 23                	jne    c0100b0f <rb_delete_fixup+0xad>
c0100aec:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100aef:	8b 40 0c             	mov    0xc(%eax),%eax
c0100af2:	8b 00                	mov    (%eax),%eax
c0100af4:	85 c0                	test   %eax,%eax
c0100af6:	75 17                	jne    c0100b0f <rb_delete_fixup+0xad>
c0100af8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100afb:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c0100b01:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b04:	8b 40 04             	mov    0x4(%eax),%eax
c0100b07:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100b0a:	e9 78 01 00 00       	jmp    c0100c87 <rb_delete_fixup+0x225>
c0100b0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b12:	8b 40 0c             	mov    0xc(%eax),%eax
c0100b15:	8b 00                	mov    (%eax),%eax
c0100b17:	85 c0                	test   %eax,%eax
c0100b19:	75 32                	jne    c0100b4d <rb_delete_fixup+0xeb>
c0100b1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b1e:	8b 40 08             	mov    0x8(%eax),%eax
c0100b21:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100b27:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b2a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c0100b30:	83 ec 08             	sub    $0x8,%esp
c0100b33:	ff 75 f0             	pushl  -0x10(%ebp)
c0100b36:	ff 75 08             	pushl  0x8(%ebp)
c0100b39:	e8 40 fa ff ff       	call   c010057e <rb_right_rotate>
c0100b3e:	83 c4 10             	add    $0x10,%esp
c0100b41:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b44:	8b 40 04             	mov    0x4(%eax),%eax
c0100b47:	8b 40 0c             	mov    0xc(%eax),%eax
c0100b4a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100b4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b50:	8b 40 04             	mov    0x4(%eax),%eax
c0100b53:	8b 10                	mov    (%eax),%edx
c0100b55:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b58:	89 10                	mov    %edx,(%eax)
c0100b5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b5d:	8b 40 04             	mov    0x4(%eax),%eax
c0100b60:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100b66:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b69:	8b 40 0c             	mov    0xc(%eax),%eax
c0100b6c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100b72:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b75:	8b 40 04             	mov    0x4(%eax),%eax
c0100b78:	83 ec 08             	sub    $0x8,%esp
c0100b7b:	50                   	push   %eax
c0100b7c:	ff 75 08             	pushl  0x8(%ebp)
c0100b7f:	e8 22 f9 ff ff       	call   c01004a6 <rb_left_rotate>
c0100b84:	83 c4 10             	add    $0x10,%esp
c0100b87:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100b8a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100b8d:	e9 f5 00 00 00       	jmp    c0100c87 <rb_delete_fixup+0x225>
        }
        else {
            RB_DELETE_FIXUP_SUB(right, left);
c0100b92:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b95:	8b 40 04             	mov    0x4(%eax),%eax
c0100b98:	8b 40 08             	mov    0x8(%eax),%eax
c0100b9b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100b9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100ba1:	8b 00                	mov    (%eax),%eax
c0100ba3:	85 c0                	test   %eax,%eax
c0100ba5:	74 36                	je     c0100bdd <rb_delete_fixup+0x17b>
c0100ba7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100baa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100bb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bb3:	8b 40 04             	mov    0x4(%eax),%eax
c0100bb6:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c0100bbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bbf:	8b 40 04             	mov    0x4(%eax),%eax
c0100bc2:	83 ec 08             	sub    $0x8,%esp
c0100bc5:	50                   	push   %eax
c0100bc6:	ff 75 08             	pushl  0x8(%ebp)
c0100bc9:	e8 b0 f9 ff ff       	call   c010057e <rb_right_rotate>
c0100bce:	83 c4 10             	add    $0x10,%esp
c0100bd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bd4:	8b 40 04             	mov    0x4(%eax),%eax
c0100bd7:	8b 40 08             	mov    0x8(%eax),%eax
c0100bda:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100bdd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100be0:	8b 40 0c             	mov    0xc(%eax),%eax
c0100be3:	8b 00                	mov    (%eax),%eax
c0100be5:	85 c0                	test   %eax,%eax
c0100be7:	75 20                	jne    c0100c09 <rb_delete_fixup+0x1a7>
c0100be9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100bec:	8b 40 08             	mov    0x8(%eax),%eax
c0100bef:	8b 00                	mov    (%eax),%eax
c0100bf1:	85 c0                	test   %eax,%eax
c0100bf3:	75 14                	jne    c0100c09 <rb_delete_fixup+0x1a7>
c0100bf5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100bf8:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c0100bfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c01:	8b 40 04             	mov    0x4(%eax),%eax
c0100c04:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100c07:	eb 7e                	jmp    c0100c87 <rb_delete_fixup+0x225>
c0100c09:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100c0c:	8b 40 08             	mov    0x8(%eax),%eax
c0100c0f:	8b 00                	mov    (%eax),%eax
c0100c11:	85 c0                	test   %eax,%eax
c0100c13:	75 32                	jne    c0100c47 <rb_delete_fixup+0x1e5>
c0100c15:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100c18:	8b 40 0c             	mov    0xc(%eax),%eax
c0100c1b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100c21:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100c24:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c0100c2a:	83 ec 08             	sub    $0x8,%esp
c0100c2d:	ff 75 f0             	pushl  -0x10(%ebp)
c0100c30:	ff 75 08             	pushl  0x8(%ebp)
c0100c33:	e8 6e f8 ff ff       	call   c01004a6 <rb_left_rotate>
c0100c38:	83 c4 10             	add    $0x10,%esp
c0100c3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c3e:	8b 40 04             	mov    0x4(%eax),%eax
c0100c41:	8b 40 08             	mov    0x8(%eax),%eax
c0100c44:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100c47:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c4a:	8b 40 04             	mov    0x4(%eax),%eax
c0100c4d:	8b 10                	mov    (%eax),%edx
c0100c4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100c52:	89 10                	mov    %edx,(%eax)
c0100c54:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c57:	8b 40 04             	mov    0x4(%eax),%eax
c0100c5a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100c60:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100c63:	8b 40 08             	mov    0x8(%eax),%eax
c0100c66:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100c6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c6f:	8b 40 04             	mov    0x4(%eax),%eax
c0100c72:	83 ec 08             	sub    $0x8,%esp
c0100c75:	50                   	push   %eax
c0100c76:	ff 75 08             	pushl  0x8(%ebp)
c0100c79:	e8 00 f9 ff ff       	call   c010057e <rb_right_rotate>
c0100c7e:	83 c4 10             	add    $0x10,%esp
c0100c81:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100c84:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while (x != root && !x->red) {
c0100c87:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c8a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0100c8d:	74 0d                	je     c0100c9c <rb_delete_fixup+0x23a>
c0100c8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c92:	8b 00                	mov    (%eax),%eax
c0100c94:	85 c0                	test   %eax,%eax
c0100c96:	0f 84 e7 fd ff ff    	je     c0100a83 <rb_delete_fixup+0x21>
        }
    }
    x->red = 0;
c0100c9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c9f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

#undef RB_DELETE_FIXUP_SUB
}
c0100ca5:	90                   	nop
c0100ca6:	c9                   	leave  
c0100ca7:	c3                   	ret    

c0100ca8 <rb_delete>:
/* *
 * rb_delete - deletes @node from @tree, and calls rb_delete_fixup to
 * restore red-black properties.
 * */
void
rb_delete(rb_tree *tree, rb_node *node) {
c0100ca8:	f3 0f 1e fb          	endbr32 
c0100cac:	55                   	push   %ebp
c0100cad:	89 e5                	mov    %esp,%ebp
c0100caf:	83 ec 28             	sub    $0x28,%esp
    rb_node *x, *y, *z = node;
c0100cb2:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100cb5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    rb_node *nil = tree->nil, *root = tree->root;
c0100cb8:	8b 45 08             	mov    0x8(%ebp),%eax
c0100cbb:	8b 40 04             	mov    0x4(%eax),%eax
c0100cbe:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100cc1:	8b 45 08             	mov    0x8(%ebp),%eax
c0100cc4:	8b 40 08             	mov    0x8(%eax),%eax
c0100cc7:	89 45 ec             	mov    %eax,-0x14(%ebp)

    y = (z->left == nil || z->right == nil) ? z : rb_tree_successor(tree, z);
c0100cca:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ccd:	8b 40 08             	mov    0x8(%eax),%eax
c0100cd0:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0100cd3:	74 1b                	je     c0100cf0 <rb_delete+0x48>
c0100cd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100cd8:	8b 40 0c             	mov    0xc(%eax),%eax
c0100cdb:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0100cde:	74 10                	je     c0100cf0 <rb_delete+0x48>
c0100ce0:	ff 75 f4             	pushl  -0xc(%ebp)
c0100ce3:	ff 75 08             	pushl  0x8(%ebp)
c0100ce6:	e8 13 fc ff ff       	call   c01008fe <rb_tree_successor>
c0100ceb:	83 c4 08             	add    $0x8,%esp
c0100cee:	eb 03                	jmp    c0100cf3 <rb_delete+0x4b>
c0100cf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100cf3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    x = (y->left != nil) ? y->left : y->right;
c0100cf6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100cf9:	8b 40 08             	mov    0x8(%eax),%eax
c0100cfc:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0100cff:	74 08                	je     c0100d09 <rb_delete+0x61>
c0100d01:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100d04:	8b 40 08             	mov    0x8(%eax),%eax
c0100d07:	eb 06                	jmp    c0100d0f <rb_delete+0x67>
c0100d09:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100d0c:	8b 40 0c             	mov    0xc(%eax),%eax
c0100d0f:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    assert(y != root && y != nil);
c0100d12:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100d15:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0100d18:	74 08                	je     c0100d22 <rb_delete+0x7a>
c0100d1a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100d1d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0100d20:	75 19                	jne    c0100d3b <rb_delete+0x93>
c0100d22:	68 00 ad 10 c0       	push   $0xc010ad00
c0100d27:	68 78 ac 10 c0       	push   $0xc010ac78
c0100d2c:	68 2f 01 00 00       	push   $0x12f
c0100d31:	68 8d ac 10 c0       	push   $0xc010ac8d
c0100d36:	e8 b3 0a 00 00       	call   c01017ee <__panic>

    x->parent = y->parent;
c0100d3b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100d3e:	8b 50 04             	mov    0x4(%eax),%edx
c0100d41:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100d44:	89 50 04             	mov    %edx,0x4(%eax)
    if (y == y->parent->left) {
c0100d47:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100d4a:	8b 40 04             	mov    0x4(%eax),%eax
c0100d4d:	8b 40 08             	mov    0x8(%eax),%eax
c0100d50:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0100d53:	75 0e                	jne    c0100d63 <rb_delete+0xbb>
        y->parent->left = x;
c0100d55:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100d58:	8b 40 04             	mov    0x4(%eax),%eax
c0100d5b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100d5e:	89 50 08             	mov    %edx,0x8(%eax)
c0100d61:	eb 0c                	jmp    c0100d6f <rb_delete+0xc7>
    }
    else {
        y->parent->right = x;
c0100d63:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100d66:	8b 40 04             	mov    0x4(%eax),%eax
c0100d69:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100d6c:	89 50 0c             	mov    %edx,0xc(%eax)
    }

    bool need_fixup = !(y->red);
c0100d6f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100d72:	8b 00                	mov    (%eax),%eax
c0100d74:	85 c0                	test   %eax,%eax
c0100d76:	0f 94 c0             	sete   %al
c0100d79:	0f b6 c0             	movzbl %al,%eax
c0100d7c:	89 45 e0             	mov    %eax,-0x20(%ebp)

    if (y != z) {
c0100d7f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100d82:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100d85:	74 5c                	je     c0100de3 <rb_delete+0x13b>
        if (z == z->parent->left) {
c0100d87:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d8a:	8b 40 04             	mov    0x4(%eax),%eax
c0100d8d:	8b 40 08             	mov    0x8(%eax),%eax
c0100d90:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0100d93:	75 0e                	jne    c0100da3 <rb_delete+0xfb>
            z->parent->left = y;
c0100d95:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d98:	8b 40 04             	mov    0x4(%eax),%eax
c0100d9b:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0100d9e:	89 50 08             	mov    %edx,0x8(%eax)
c0100da1:	eb 0c                	jmp    c0100daf <rb_delete+0x107>
        }
        else {
            z->parent->right = y;
c0100da3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100da6:	8b 40 04             	mov    0x4(%eax),%eax
c0100da9:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0100dac:	89 50 0c             	mov    %edx,0xc(%eax)
        }
        z->left->parent = z->right->parent = y;
c0100daf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100db2:	8b 40 0c             	mov    0xc(%eax),%eax
c0100db5:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0100db8:	89 50 04             	mov    %edx,0x4(%eax)
c0100dbb:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100dbe:	8b 52 08             	mov    0x8(%edx),%edx
c0100dc1:	8b 40 04             	mov    0x4(%eax),%eax
c0100dc4:	89 42 04             	mov    %eax,0x4(%edx)
        *y = *z;
c0100dc7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100dca:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100dcd:	8b 0a                	mov    (%edx),%ecx
c0100dcf:	89 08                	mov    %ecx,(%eax)
c0100dd1:	8b 4a 04             	mov    0x4(%edx),%ecx
c0100dd4:	89 48 04             	mov    %ecx,0x4(%eax)
c0100dd7:	8b 4a 08             	mov    0x8(%edx),%ecx
c0100dda:	89 48 08             	mov    %ecx,0x8(%eax)
c0100ddd:	8b 52 0c             	mov    0xc(%edx),%edx
c0100de0:	89 50 0c             	mov    %edx,0xc(%eax)
    }
    if (need_fixup) {
c0100de3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0100de7:	74 11                	je     c0100dfa <rb_delete+0x152>
        rb_delete_fixup(tree, x);
c0100de9:	83 ec 08             	sub    $0x8,%esp
c0100dec:	ff 75 e4             	pushl  -0x1c(%ebp)
c0100def:	ff 75 08             	pushl  0x8(%ebp)
c0100df2:	e8 6b fc ff ff       	call   c0100a62 <rb_delete_fixup>
c0100df7:	83 c4 10             	add    $0x10,%esp
    }
}
c0100dfa:	90                   	nop
c0100dfb:	c9                   	leave  
c0100dfc:	c3                   	ret    

c0100dfd <rb_tree_destroy>:

/* rb_tree_destroy - destroy a tree and free memory */
void
rb_tree_destroy(rb_tree *tree) {
c0100dfd:	f3 0f 1e fb          	endbr32 
c0100e01:	55                   	push   %ebp
c0100e02:	89 e5                	mov    %esp,%ebp
c0100e04:	83 ec 08             	sub    $0x8,%esp
    kfree(tree->root);
c0100e07:	8b 45 08             	mov    0x8(%ebp),%eax
c0100e0a:	8b 40 08             	mov    0x8(%eax),%eax
c0100e0d:	83 ec 0c             	sub    $0xc,%esp
c0100e10:	50                   	push   %eax
c0100e11:	e8 fe 6d 00 00       	call   c0107c14 <kfree>
c0100e16:	83 c4 10             	add    $0x10,%esp
    kfree(tree->nil);
c0100e19:	8b 45 08             	mov    0x8(%ebp),%eax
c0100e1c:	8b 40 04             	mov    0x4(%eax),%eax
c0100e1f:	83 ec 0c             	sub    $0xc,%esp
c0100e22:	50                   	push   %eax
c0100e23:	e8 ec 6d 00 00       	call   c0107c14 <kfree>
c0100e28:	83 c4 10             	add    $0x10,%esp
    kfree(tree);
c0100e2b:	83 ec 0c             	sub    $0xc,%esp
c0100e2e:	ff 75 08             	pushl  0x8(%ebp)
c0100e31:	e8 de 6d 00 00       	call   c0107c14 <kfree>
c0100e36:	83 c4 10             	add    $0x10,%esp
}
c0100e39:	90                   	nop
c0100e3a:	c9                   	leave  
c0100e3b:	c3                   	ret    

c0100e3c <rb_node_prev>:
/* *
 * rb_node_prev - returns the predecessor node of @node in @tree,
 * or 'NULL' if no predecessor exists.
 * */
rb_node *
rb_node_prev(rb_tree *tree, rb_node *node) {
c0100e3c:	f3 0f 1e fb          	endbr32 
c0100e40:	55                   	push   %ebp
c0100e41:	89 e5                	mov    %esp,%ebp
c0100e43:	83 ec 10             	sub    $0x10,%esp
    rb_node *prev = rb_tree_predecessor(tree, node);
c0100e46:	ff 75 0c             	pushl  0xc(%ebp)
c0100e49:	ff 75 08             	pushl  0x8(%ebp)
c0100e4c:	e8 28 fb ff ff       	call   c0100979 <rb_tree_predecessor>
c0100e51:	83 c4 08             	add    $0x8,%esp
c0100e54:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (prev != tree->nil) ? prev : NULL;
c0100e57:	8b 45 08             	mov    0x8(%ebp),%eax
c0100e5a:	8b 40 04             	mov    0x4(%eax),%eax
c0100e5d:	39 45 fc             	cmp    %eax,-0x4(%ebp)
c0100e60:	74 05                	je     c0100e67 <rb_node_prev+0x2b>
c0100e62:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e65:	eb 05                	jmp    c0100e6c <rb_node_prev+0x30>
c0100e67:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e6c:	c9                   	leave  
c0100e6d:	c3                   	ret    

c0100e6e <rb_node_next>:
/* *
 * rb_node_next - returns the successor node of @node in @tree,
 * or 'NULL' if no successor exists.
 * */
rb_node *
rb_node_next(rb_tree *tree, rb_node *node) {
c0100e6e:	f3 0f 1e fb          	endbr32 
c0100e72:	55                   	push   %ebp
c0100e73:	89 e5                	mov    %esp,%ebp
c0100e75:	83 ec 10             	sub    $0x10,%esp
    rb_node *next = rb_tree_successor(tree, node);
c0100e78:	ff 75 0c             	pushl  0xc(%ebp)
c0100e7b:	ff 75 08             	pushl  0x8(%ebp)
c0100e7e:	e8 7b fa ff ff       	call   c01008fe <rb_tree_successor>
c0100e83:	83 c4 08             	add    $0x8,%esp
c0100e86:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (next != tree->nil) ? next : NULL;
c0100e89:	8b 45 08             	mov    0x8(%ebp),%eax
c0100e8c:	8b 40 04             	mov    0x4(%eax),%eax
c0100e8f:	39 45 fc             	cmp    %eax,-0x4(%ebp)
c0100e92:	74 05                	je     c0100e99 <rb_node_next+0x2b>
c0100e94:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e97:	eb 05                	jmp    c0100e9e <rb_node_next+0x30>
c0100e99:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e9e:	c9                   	leave  
c0100e9f:	c3                   	ret    

c0100ea0 <rb_node_root>:

/* rb_node_root - returns the root node of a @tree, or 'NULL' if tree is empty */
rb_node *
rb_node_root(rb_tree *tree) {
c0100ea0:	f3 0f 1e fb          	endbr32 
c0100ea4:	55                   	push   %ebp
c0100ea5:	89 e5                	mov    %esp,%ebp
c0100ea7:	83 ec 10             	sub    $0x10,%esp
    rb_node *node = tree->root->left;
c0100eaa:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ead:	8b 40 08             	mov    0x8(%eax),%eax
c0100eb0:	8b 40 08             	mov    0x8(%eax),%eax
c0100eb3:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (node != tree->nil) ? node : NULL;
c0100eb6:	8b 45 08             	mov    0x8(%ebp),%eax
c0100eb9:	8b 40 04             	mov    0x4(%eax),%eax
c0100ebc:	39 45 fc             	cmp    %eax,-0x4(%ebp)
c0100ebf:	74 05                	je     c0100ec6 <rb_node_root+0x26>
c0100ec1:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ec4:	eb 05                	jmp    c0100ecb <rb_node_root+0x2b>
c0100ec6:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100ecb:	c9                   	leave  
c0100ecc:	c3                   	ret    

c0100ecd <rb_node_left>:

/* rb_node_left - gets the left child of @node, or 'NULL' if no such node */
rb_node *
rb_node_left(rb_tree *tree, rb_node *node) {
c0100ecd:	f3 0f 1e fb          	endbr32 
c0100ed1:	55                   	push   %ebp
c0100ed2:	89 e5                	mov    %esp,%ebp
c0100ed4:	83 ec 10             	sub    $0x10,%esp
    rb_node *left = node->left;
c0100ed7:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100eda:	8b 40 08             	mov    0x8(%eax),%eax
c0100edd:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (left != tree->nil) ? left : NULL;
c0100ee0:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ee3:	8b 40 04             	mov    0x4(%eax),%eax
c0100ee6:	39 45 fc             	cmp    %eax,-0x4(%ebp)
c0100ee9:	74 05                	je     c0100ef0 <rb_node_left+0x23>
c0100eeb:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100eee:	eb 05                	jmp    c0100ef5 <rb_node_left+0x28>
c0100ef0:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100ef5:	c9                   	leave  
c0100ef6:	c3                   	ret    

c0100ef7 <rb_node_right>:

/* rb_node_right - gets the right child of @node, or 'NULL' if no such node */
rb_node *
rb_node_right(rb_tree *tree, rb_node *node) {
c0100ef7:	f3 0f 1e fb          	endbr32 
c0100efb:	55                   	push   %ebp
c0100efc:	89 e5                	mov    %esp,%ebp
c0100efe:	83 ec 10             	sub    $0x10,%esp
    rb_node *right = node->right;
c0100f01:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100f04:	8b 40 0c             	mov    0xc(%eax),%eax
c0100f07:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (right != tree->nil) ? right : NULL;
c0100f0a:	8b 45 08             	mov    0x8(%ebp),%eax
c0100f0d:	8b 40 04             	mov    0x4(%eax),%eax
c0100f10:	39 45 fc             	cmp    %eax,-0x4(%ebp)
c0100f13:	74 05                	je     c0100f1a <rb_node_right+0x23>
c0100f15:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f18:	eb 05                	jmp    c0100f1f <rb_node_right+0x28>
c0100f1a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100f1f:	c9                   	leave  
c0100f20:	c3                   	ret    

c0100f21 <check_tree>:

int
check_tree(rb_tree *tree, rb_node *node) {
c0100f21:	f3 0f 1e fb          	endbr32 
c0100f25:	55                   	push   %ebp
c0100f26:	89 e5                	mov    %esp,%ebp
c0100f28:	83 ec 18             	sub    $0x18,%esp
    rb_node *nil = tree->nil;
c0100f2b:	8b 45 08             	mov    0x8(%ebp),%eax
c0100f2e:	8b 40 04             	mov    0x4(%eax),%eax
c0100f31:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (node == nil) {
c0100f34:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100f37:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0100f3a:	75 2c                	jne    c0100f68 <check_tree+0x47>
        assert(!node->red);
c0100f3c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100f3f:	8b 00                	mov    (%eax),%eax
c0100f41:	85 c0                	test   %eax,%eax
c0100f43:	74 19                	je     c0100f5e <check_tree+0x3d>
c0100f45:	68 16 ad 10 c0       	push   $0xc010ad16
c0100f4a:	68 78 ac 10 c0       	push   $0xc010ac78
c0100f4f:	68 7f 01 00 00       	push   $0x17f
c0100f54:	68 8d ac 10 c0       	push   $0xc010ac8d
c0100f59:	e8 90 08 00 00       	call   c01017ee <__panic>
        return 1;
c0100f5e:	b8 01 00 00 00       	mov    $0x1,%eax
c0100f63:	e9 6d 01 00 00       	jmp    c01010d5 <check_tree+0x1b4>
    }
    if (node->left != nil) {
c0100f68:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100f6b:	8b 40 08             	mov    0x8(%eax),%eax
c0100f6e:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0100f71:	74 5b                	je     c0100fce <check_tree+0xad>
        assert(COMPARE(tree, node, node->left) >= 0);
c0100f73:	8b 45 08             	mov    0x8(%ebp),%eax
c0100f76:	8b 00                	mov    (%eax),%eax
c0100f78:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100f7b:	8b 52 08             	mov    0x8(%edx),%edx
c0100f7e:	83 ec 08             	sub    $0x8,%esp
c0100f81:	52                   	push   %edx
c0100f82:	ff 75 0c             	pushl  0xc(%ebp)
c0100f85:	ff d0                	call   *%eax
c0100f87:	83 c4 10             	add    $0x10,%esp
c0100f8a:	85 c0                	test   %eax,%eax
c0100f8c:	79 19                	jns    c0100fa7 <check_tree+0x86>
c0100f8e:	68 24 ad 10 c0       	push   $0xc010ad24
c0100f93:	68 78 ac 10 c0       	push   $0xc010ac78
c0100f98:	68 83 01 00 00       	push   $0x183
c0100f9d:	68 8d ac 10 c0       	push   $0xc010ac8d
c0100fa2:	e8 47 08 00 00       	call   c01017ee <__panic>
        assert(node->left->parent == node);
c0100fa7:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100faa:	8b 40 08             	mov    0x8(%eax),%eax
c0100fad:	8b 40 04             	mov    0x4(%eax),%eax
c0100fb0:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0100fb3:	74 19                	je     c0100fce <check_tree+0xad>
c0100fb5:	68 49 ad 10 c0       	push   $0xc010ad49
c0100fba:	68 78 ac 10 c0       	push   $0xc010ac78
c0100fbf:	68 84 01 00 00       	push   $0x184
c0100fc4:	68 8d ac 10 c0       	push   $0xc010ac8d
c0100fc9:	e8 20 08 00 00       	call   c01017ee <__panic>
    }
    if (node->right != nil) {
c0100fce:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100fd1:	8b 40 0c             	mov    0xc(%eax),%eax
c0100fd4:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0100fd7:	74 5b                	je     c0101034 <check_tree+0x113>
        assert(COMPARE(tree, node, node->right) <= 0);
c0100fd9:	8b 45 08             	mov    0x8(%ebp),%eax
c0100fdc:	8b 00                	mov    (%eax),%eax
c0100fde:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100fe1:	8b 52 0c             	mov    0xc(%edx),%edx
c0100fe4:	83 ec 08             	sub    $0x8,%esp
c0100fe7:	52                   	push   %edx
c0100fe8:	ff 75 0c             	pushl  0xc(%ebp)
c0100feb:	ff d0                	call   *%eax
c0100fed:	83 c4 10             	add    $0x10,%esp
c0100ff0:	85 c0                	test   %eax,%eax
c0100ff2:	7e 19                	jle    c010100d <check_tree+0xec>
c0100ff4:	68 64 ad 10 c0       	push   $0xc010ad64
c0100ff9:	68 78 ac 10 c0       	push   $0xc010ac78
c0100ffe:	68 87 01 00 00       	push   $0x187
c0101003:	68 8d ac 10 c0       	push   $0xc010ac8d
c0101008:	e8 e1 07 00 00       	call   c01017ee <__panic>
        assert(node->right->parent == node);
c010100d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101010:	8b 40 0c             	mov    0xc(%eax),%eax
c0101013:	8b 40 04             	mov    0x4(%eax),%eax
c0101016:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0101019:	74 19                	je     c0101034 <check_tree+0x113>
c010101b:	68 8a ad 10 c0       	push   $0xc010ad8a
c0101020:	68 78 ac 10 c0       	push   $0xc010ac78
c0101025:	68 88 01 00 00       	push   $0x188
c010102a:	68 8d ac 10 c0       	push   $0xc010ac8d
c010102f:	e8 ba 07 00 00       	call   c01017ee <__panic>
    }
    if (node->red) {
c0101034:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101037:	8b 00                	mov    (%eax),%eax
c0101039:	85 c0                	test   %eax,%eax
c010103b:	74 31                	je     c010106e <check_tree+0x14d>
        assert(!node->left->red && !node->right->red);
c010103d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101040:	8b 40 08             	mov    0x8(%eax),%eax
c0101043:	8b 00                	mov    (%eax),%eax
c0101045:	85 c0                	test   %eax,%eax
c0101047:	75 0c                	jne    c0101055 <check_tree+0x134>
c0101049:	8b 45 0c             	mov    0xc(%ebp),%eax
c010104c:	8b 40 0c             	mov    0xc(%eax),%eax
c010104f:	8b 00                	mov    (%eax),%eax
c0101051:	85 c0                	test   %eax,%eax
c0101053:	74 19                	je     c010106e <check_tree+0x14d>
c0101055:	68 a8 ad 10 c0       	push   $0xc010ada8
c010105a:	68 78 ac 10 c0       	push   $0xc010ac78
c010105f:	68 8b 01 00 00       	push   $0x18b
c0101064:	68 8d ac 10 c0       	push   $0xc010ac8d
c0101069:	e8 80 07 00 00       	call   c01017ee <__panic>
    }
    int hb_left = check_tree(tree, node->left);
c010106e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101071:	8b 40 08             	mov    0x8(%eax),%eax
c0101074:	83 ec 08             	sub    $0x8,%esp
c0101077:	50                   	push   %eax
c0101078:	ff 75 08             	pushl  0x8(%ebp)
c010107b:	e8 a1 fe ff ff       	call   c0100f21 <check_tree>
c0101080:	83 c4 10             	add    $0x10,%esp
c0101083:	89 45 ec             	mov    %eax,-0x14(%ebp)
    int hb_right = check_tree(tree, node->right);
c0101086:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101089:	8b 40 0c             	mov    0xc(%eax),%eax
c010108c:	83 ec 08             	sub    $0x8,%esp
c010108f:	50                   	push   %eax
c0101090:	ff 75 08             	pushl  0x8(%ebp)
c0101093:	e8 89 fe ff ff       	call   c0100f21 <check_tree>
c0101098:	83 c4 10             	add    $0x10,%esp
c010109b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(hb_left == hb_right);
c010109e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01010a1:	3b 45 e8             	cmp    -0x18(%ebp),%eax
c01010a4:	74 19                	je     c01010bf <check_tree+0x19e>
c01010a6:	68 ce ad 10 c0       	push   $0xc010adce
c01010ab:	68 78 ac 10 c0       	push   $0xc010ac78
c01010b0:	68 8f 01 00 00       	push   $0x18f
c01010b5:	68 8d ac 10 c0       	push   $0xc010ac8d
c01010ba:	e8 2f 07 00 00       	call   c01017ee <__panic>
    int hb = hb_left;
c01010bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01010c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!node->red) {
c01010c5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01010c8:	8b 00                	mov    (%eax),%eax
c01010ca:	85 c0                	test   %eax,%eax
c01010cc:	75 04                	jne    c01010d2 <check_tree+0x1b1>
        hb ++;
c01010ce:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    }
    return hb;
c01010d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01010d5:	c9                   	leave  
c01010d6:	c3                   	ret    

c01010d7 <check_safe_kmalloc>:

static void *
check_safe_kmalloc(size_t size) {
c01010d7:	f3 0f 1e fb          	endbr32 
c01010db:	55                   	push   %ebp
c01010dc:	89 e5                	mov    %esp,%ebp
c01010de:	83 ec 18             	sub    $0x18,%esp
    void *ret = kmalloc(size);
c01010e1:	83 ec 0c             	sub    $0xc,%esp
c01010e4:	ff 75 08             	pushl  0x8(%ebp)
c01010e7:	e8 0c 6b 00 00       	call   c0107bf8 <kmalloc>
c01010ec:	83 c4 10             	add    $0x10,%esp
c01010ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(ret != NULL);
c01010f2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01010f6:	75 19                	jne    c0101111 <check_safe_kmalloc+0x3a>
c01010f8:	68 e2 ad 10 c0       	push   $0xc010ade2
c01010fd:	68 78 ac 10 c0       	push   $0xc010ac78
c0101102:	68 9a 01 00 00       	push   $0x19a
c0101107:	68 8d ac 10 c0       	push   $0xc010ac8d
c010110c:	e8 dd 06 00 00       	call   c01017ee <__panic>
    return ret;
c0101111:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101114:	c9                   	leave  
c0101115:	c3                   	ret    

c0101116 <check_compare1>:

#define rbn2data(node)              \
    (to_struct(node, struct check_data, rb_link))

static inline int
check_compare1(rb_node *node1, rb_node *node2) {
c0101116:	f3 0f 1e fb          	endbr32 
c010111a:	55                   	push   %ebp
c010111b:	89 e5                	mov    %esp,%ebp
    return rbn2data(node1)->data - rbn2data(node2)->data;
c010111d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101120:	83 e8 04             	sub    $0x4,%eax
c0101123:	8b 10                	mov    (%eax),%edx
c0101125:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101128:	83 e8 04             	sub    $0x4,%eax
c010112b:	8b 00                	mov    (%eax),%eax
c010112d:	29 c2                	sub    %eax,%edx
c010112f:	89 d0                	mov    %edx,%eax
}
c0101131:	5d                   	pop    %ebp
c0101132:	c3                   	ret    

c0101133 <check_compare2>:

static inline int
check_compare2(rb_node *node, void *key) {
c0101133:	f3 0f 1e fb          	endbr32 
c0101137:	55                   	push   %ebp
c0101138:	89 e5                	mov    %esp,%ebp
    return rbn2data(node)->data - (long)key;
c010113a:	8b 45 08             	mov    0x8(%ebp),%eax
c010113d:	83 e8 04             	sub    $0x4,%eax
c0101140:	8b 10                	mov    (%eax),%edx
c0101142:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101145:	29 c2                	sub    %eax,%edx
c0101147:	89 d0                	mov    %edx,%eax
}
c0101149:	5d                   	pop    %ebp
c010114a:	c3                   	ret    

c010114b <check_rb_tree>:

void
check_rb_tree(void) {
c010114b:	f3 0f 1e fb          	endbr32 
c010114f:	55                   	push   %ebp
c0101150:	89 e5                	mov    %esp,%ebp
c0101152:	53                   	push   %ebx
c0101153:	83 ec 34             	sub    $0x34,%esp
    rb_tree *tree = rb_tree_create(check_compare1);
c0101156:	83 ec 0c             	sub    $0xc,%esp
c0101159:	68 16 11 10 c0       	push   $0xc0101116
c010115e:	e8 42 f2 ff ff       	call   c01003a5 <rb_tree_create>
c0101163:	83 c4 10             	add    $0x10,%esp
c0101166:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(tree != NULL);
c0101169:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010116d:	75 19                	jne    c0101188 <check_rb_tree+0x3d>
c010116f:	68 ee ad 10 c0       	push   $0xc010adee
c0101174:	68 78 ac 10 c0       	push   $0xc010ac78
c0101179:	68 b3 01 00 00       	push   $0x1b3
c010117e:	68 8d ac 10 c0       	push   $0xc010ac8d
c0101183:	e8 66 06 00 00       	call   c01017ee <__panic>

    rb_node *nil = tree->nil, *root = tree->root;
c0101188:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010118b:	8b 40 04             	mov    0x4(%eax),%eax
c010118e:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0101191:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101194:	8b 40 08             	mov    0x8(%eax),%eax
c0101197:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(!nil->red && root->left == nil);
c010119a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010119d:	8b 00                	mov    (%eax),%eax
c010119f:	85 c0                	test   %eax,%eax
c01011a1:	75 0b                	jne    c01011ae <check_rb_tree+0x63>
c01011a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01011a6:	8b 40 08             	mov    0x8(%eax),%eax
c01011a9:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c01011ac:	74 19                	je     c01011c7 <check_rb_tree+0x7c>
c01011ae:	68 fc ad 10 c0       	push   $0xc010adfc
c01011b3:	68 78 ac 10 c0       	push   $0xc010ac78
c01011b8:	68 b6 01 00 00       	push   $0x1b6
c01011bd:	68 8d ac 10 c0       	push   $0xc010ac8d
c01011c2:	e8 27 06 00 00       	call   c01017ee <__panic>

    int total = 1000;
c01011c7:	c7 45 e0 e8 03 00 00 	movl   $0x3e8,-0x20(%ebp)
    struct check_data **all = check_safe_kmalloc(sizeof(struct check_data *) * total);
c01011ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01011d1:	c1 e0 02             	shl    $0x2,%eax
c01011d4:	83 ec 0c             	sub    $0xc,%esp
c01011d7:	50                   	push   %eax
c01011d8:	e8 fa fe ff ff       	call   c01010d7 <check_safe_kmalloc>
c01011dd:	83 c4 10             	add    $0x10,%esp
c01011e0:	89 45 dc             	mov    %eax,-0x24(%ebp)

    long i;
    for (i = 0; i < total; i ++) {
c01011e3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01011ea:	eb 39                	jmp    c0101225 <check_rb_tree+0xda>
        all[i] = check_safe_kmalloc(sizeof(struct check_data));
c01011ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01011ef:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01011f6:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01011f9:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
c01011fc:	83 ec 0c             	sub    $0xc,%esp
c01011ff:	6a 14                	push   $0x14
c0101201:	e8 d1 fe ff ff       	call   c01010d7 <check_safe_kmalloc>
c0101206:	83 c4 10             	add    $0x10,%esp
c0101209:	89 03                	mov    %eax,(%ebx)
        all[i]->data = i;
c010120b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010120e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101215:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101218:	01 d0                	add    %edx,%eax
c010121a:	8b 00                	mov    (%eax),%eax
c010121c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010121f:	89 10                	mov    %edx,(%eax)
    for (i = 0; i < total; i ++) {
c0101221:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101225:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101228:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c010122b:	7c bf                	jl     c01011ec <check_rb_tree+0xa1>
    }

    int *mark = check_safe_kmalloc(sizeof(int) * total);
c010122d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0101230:	c1 e0 02             	shl    $0x2,%eax
c0101233:	83 ec 0c             	sub    $0xc,%esp
c0101236:	50                   	push   %eax
c0101237:	e8 9b fe ff ff       	call   c01010d7 <check_safe_kmalloc>
c010123c:	83 c4 10             	add    $0x10,%esp
c010123f:	89 45 d8             	mov    %eax,-0x28(%ebp)
    memset(mark, 0, sizeof(int) * total);
c0101242:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0101245:	c1 e0 02             	shl    $0x2,%eax
c0101248:	83 ec 04             	sub    $0x4,%esp
c010124b:	50                   	push   %eax
c010124c:	6a 00                	push   $0x0
c010124e:	ff 75 d8             	pushl  -0x28(%ebp)
c0101251:	e8 8e 90 00 00       	call   c010a2e4 <memset>
c0101256:	83 c4 10             	add    $0x10,%esp

    for (i = 0; i < total; i ++) {
c0101259:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101260:	eb 29                	jmp    c010128b <check_rb_tree+0x140>
        mark[all[i]->data] = 1;
c0101262:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101265:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010126c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010126f:	01 d0                	add    %edx,%eax
c0101271:	8b 00                	mov    (%eax),%eax
c0101273:	8b 00                	mov    (%eax),%eax
c0101275:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010127c:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010127f:	01 d0                	add    %edx,%eax
c0101281:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
    for (i = 0; i < total; i ++) {
c0101287:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010128b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010128e:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0101291:	7c cf                	jl     c0101262 <check_rb_tree+0x117>
    }
    for (i = 0; i < total; i ++) {
c0101293:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010129a:	eb 33                	jmp    c01012cf <check_rb_tree+0x184>
        assert(mark[i] == 1);
c010129c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010129f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01012a6:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01012a9:	01 d0                	add    %edx,%eax
c01012ab:	8b 00                	mov    (%eax),%eax
c01012ad:	83 f8 01             	cmp    $0x1,%eax
c01012b0:	74 19                	je     c01012cb <check_rb_tree+0x180>
c01012b2:	68 1b ae 10 c0       	push   $0xc010ae1b
c01012b7:	68 78 ac 10 c0       	push   $0xc010ac78
c01012bc:	68 c8 01 00 00       	push   $0x1c8
c01012c1:	68 8d ac 10 c0       	push   $0xc010ac8d
c01012c6:	e8 23 05 00 00       	call   c01017ee <__panic>
    for (i = 0; i < total; i ++) {
c01012cb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01012cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01012d2:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01012d5:	7c c5                	jl     c010129c <check_rb_tree+0x151>
    }

    for (i = 0; i < total; i ++) {
c01012d7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01012de:	eb 66                	jmp    c0101346 <check_rb_tree+0x1fb>
        int j = (rand() % (total - i)) + i;
c01012e0:	e8 e9 97 00 00       	call   c010aace <rand>
c01012e5:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01012e8:	89 d1                	mov    %edx,%ecx
c01012ea:	2b 4d f4             	sub    -0xc(%ebp),%ecx
c01012ed:	99                   	cltd   
c01012ee:	f7 f9                	idiv   %ecx
c01012f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01012f3:	01 d0                	add    %edx,%eax
c01012f5:	89 45 d0             	mov    %eax,-0x30(%ebp)
        struct check_data *z = all[i];
c01012f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01012fb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101302:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101305:	01 d0                	add    %edx,%eax
c0101307:	8b 00                	mov    (%eax),%eax
c0101309:	89 45 cc             	mov    %eax,-0x34(%ebp)
        all[i] = all[j];
c010130c:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010130f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101316:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101319:	01 d0                	add    %edx,%eax
c010131b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010131e:	8d 0c 95 00 00 00 00 	lea    0x0(,%edx,4),%ecx
c0101325:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101328:	01 ca                	add    %ecx,%edx
c010132a:	8b 00                	mov    (%eax),%eax
c010132c:	89 02                	mov    %eax,(%edx)
        all[j] = z;
c010132e:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0101331:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101338:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010133b:	01 c2                	add    %eax,%edx
c010133d:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0101340:	89 02                	mov    %eax,(%edx)
    for (i = 0; i < total; i ++) {
c0101342:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101346:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101349:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c010134c:	7c 92                	jl     c01012e0 <check_rb_tree+0x195>
    }

    memset(mark, 0, sizeof(int) * total);
c010134e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0101351:	c1 e0 02             	shl    $0x2,%eax
c0101354:	83 ec 04             	sub    $0x4,%esp
c0101357:	50                   	push   %eax
c0101358:	6a 00                	push   $0x0
c010135a:	ff 75 d8             	pushl  -0x28(%ebp)
c010135d:	e8 82 8f 00 00       	call   c010a2e4 <memset>
c0101362:	83 c4 10             	add    $0x10,%esp
    for (i = 0; i < total; i ++) {
c0101365:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010136c:	eb 29                	jmp    c0101397 <check_rb_tree+0x24c>
        mark[all[i]->data] = 1;
c010136e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101371:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101378:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010137b:	01 d0                	add    %edx,%eax
c010137d:	8b 00                	mov    (%eax),%eax
c010137f:	8b 00                	mov    (%eax),%eax
c0101381:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101388:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010138b:	01 d0                	add    %edx,%eax
c010138d:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
    for (i = 0; i < total; i ++) {
c0101393:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101397:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010139a:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c010139d:	7c cf                	jl     c010136e <check_rb_tree+0x223>
    }
    for (i = 0; i < total; i ++) {
c010139f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01013a6:	eb 33                	jmp    c01013db <check_rb_tree+0x290>
        assert(mark[i] == 1);
c01013a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01013ab:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01013b2:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01013b5:	01 d0                	add    %edx,%eax
c01013b7:	8b 00                	mov    (%eax),%eax
c01013b9:	83 f8 01             	cmp    $0x1,%eax
c01013bc:	74 19                	je     c01013d7 <check_rb_tree+0x28c>
c01013be:	68 1b ae 10 c0       	push   $0xc010ae1b
c01013c3:	68 78 ac 10 c0       	push   $0xc010ac78
c01013c8:	68 d7 01 00 00       	push   $0x1d7
c01013cd:	68 8d ac 10 c0       	push   $0xc010ac8d
c01013d2:	e8 17 04 00 00       	call   c01017ee <__panic>
    for (i = 0; i < total; i ++) {
c01013d7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01013db:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01013de:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01013e1:	7c c5                	jl     c01013a8 <check_rb_tree+0x25d>
    }

    for (i = 0; i < total; i ++) {
c01013e3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01013ea:	eb 3c                	jmp    c0101428 <check_rb_tree+0x2dd>
        rb_insert(tree, &(all[i]->rb_link));
c01013ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01013ef:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01013f6:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01013f9:	01 d0                	add    %edx,%eax
c01013fb:	8b 00                	mov    (%eax),%eax
c01013fd:	83 c0 04             	add    $0x4,%eax
c0101400:	83 ec 08             	sub    $0x8,%esp
c0101403:	50                   	push   %eax
c0101404:	ff 75 ec             	pushl  -0x14(%ebp)
c0101407:	e8 04 f3 ff ff       	call   c0100710 <rb_insert>
c010140c:	83 c4 10             	add    $0x10,%esp
        check_tree(tree, root->left);
c010140f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101412:	8b 40 08             	mov    0x8(%eax),%eax
c0101415:	83 ec 08             	sub    $0x8,%esp
c0101418:	50                   	push   %eax
c0101419:	ff 75 ec             	pushl  -0x14(%ebp)
c010141c:	e8 00 fb ff ff       	call   c0100f21 <check_tree>
c0101421:	83 c4 10             	add    $0x10,%esp
    for (i = 0; i < total; i ++) {
c0101424:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101428:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010142b:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c010142e:	7c bc                	jl     c01013ec <check_rb_tree+0x2a1>
    }

    rb_node *node;
    for (i = 0; i < total; i ++) {
c0101430:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101437:	eb 66                	jmp    c010149f <check_rb_tree+0x354>
        node = rb_search(tree, check_compare2, (void *)(all[i]->data));
c0101439:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010143c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101443:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101446:	01 d0                	add    %edx,%eax
c0101448:	8b 00                	mov    (%eax),%eax
c010144a:	8b 00                	mov    (%eax),%eax
c010144c:	83 ec 04             	sub    $0x4,%esp
c010144f:	50                   	push   %eax
c0101450:	68 33 11 10 c0       	push   $0xc0101133
c0101455:	ff 75 ec             	pushl  -0x14(%ebp)
c0101458:	e8 97 f5 ff ff       	call   c01009f4 <rb_search>
c010145d:	83 c4 10             	add    $0x10,%esp
c0101460:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(node != NULL && node == &(all[i]->rb_link));
c0101463:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
c0101467:	74 19                	je     c0101482 <check_rb_tree+0x337>
c0101469:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010146c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101473:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101476:	01 d0                	add    %edx,%eax
c0101478:	8b 00                	mov    (%eax),%eax
c010147a:	83 c0 04             	add    $0x4,%eax
c010147d:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
c0101480:	74 19                	je     c010149b <check_rb_tree+0x350>
c0101482:	68 28 ae 10 c0       	push   $0xc010ae28
c0101487:	68 78 ac 10 c0       	push   $0xc010ac78
c010148c:	68 e2 01 00 00       	push   $0x1e2
c0101491:	68 8d ac 10 c0       	push   $0xc010ac8d
c0101496:	e8 53 03 00 00       	call   c01017ee <__panic>
    for (i = 0; i < total; i ++) {
c010149b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010149f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01014a2:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01014a5:	7c 92                	jl     c0101439 <check_rb_tree+0x2ee>
    }

    for (i = 0; i < total; i ++) {
c01014a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01014ae:	eb 70                	jmp    c0101520 <check_rb_tree+0x3d5>
        node = rb_search(tree, check_compare2, (void *)i);
c01014b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01014b3:	83 ec 04             	sub    $0x4,%esp
c01014b6:	50                   	push   %eax
c01014b7:	68 33 11 10 c0       	push   $0xc0101133
c01014bc:	ff 75 ec             	pushl  -0x14(%ebp)
c01014bf:	e8 30 f5 ff ff       	call   c01009f4 <rb_search>
c01014c4:	83 c4 10             	add    $0x10,%esp
c01014c7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(node != NULL && rbn2data(node)->data == i);
c01014ca:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
c01014ce:	74 0d                	je     c01014dd <check_rb_tree+0x392>
c01014d0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01014d3:	83 e8 04             	sub    $0x4,%eax
c01014d6:	8b 00                	mov    (%eax),%eax
c01014d8:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01014db:	74 19                	je     c01014f6 <check_rb_tree+0x3ab>
c01014dd:	68 54 ae 10 c0       	push   $0xc010ae54
c01014e2:	68 78 ac 10 c0       	push   $0xc010ac78
c01014e7:	68 e7 01 00 00       	push   $0x1e7
c01014ec:	68 8d ac 10 c0       	push   $0xc010ac8d
c01014f1:	e8 f8 02 00 00       	call   c01017ee <__panic>
        rb_delete(tree, node);
c01014f6:	83 ec 08             	sub    $0x8,%esp
c01014f9:	ff 75 d4             	pushl  -0x2c(%ebp)
c01014fc:	ff 75 ec             	pushl  -0x14(%ebp)
c01014ff:	e8 a4 f7 ff ff       	call   c0100ca8 <rb_delete>
c0101504:	83 c4 10             	add    $0x10,%esp
        check_tree(tree, root->left);
c0101507:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010150a:	8b 40 08             	mov    0x8(%eax),%eax
c010150d:	83 ec 08             	sub    $0x8,%esp
c0101510:	50                   	push   %eax
c0101511:	ff 75 ec             	pushl  -0x14(%ebp)
c0101514:	e8 08 fa ff ff       	call   c0100f21 <check_tree>
c0101519:	83 c4 10             	add    $0x10,%esp
    for (i = 0; i < total; i ++) {
c010151c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101520:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101523:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0101526:	7c 88                	jl     c01014b0 <check_rb_tree+0x365>
    }

    assert(!nil->red && root->left == nil);
c0101528:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010152b:	8b 00                	mov    (%eax),%eax
c010152d:	85 c0                	test   %eax,%eax
c010152f:	75 0b                	jne    c010153c <check_rb_tree+0x3f1>
c0101531:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101534:	8b 40 08             	mov    0x8(%eax),%eax
c0101537:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c010153a:	74 19                	je     c0101555 <check_rb_tree+0x40a>
c010153c:	68 fc ad 10 c0       	push   $0xc010adfc
c0101541:	68 78 ac 10 c0       	push   $0xc010ac78
c0101546:	68 ec 01 00 00       	push   $0x1ec
c010154b:	68 8d ac 10 c0       	push   $0xc010ac8d
c0101550:	e8 99 02 00 00       	call   c01017ee <__panic>

    long max = 32;
c0101555:	c7 45 f0 20 00 00 00 	movl   $0x20,-0x10(%ebp)
    if (max > total) {
c010155c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010155f:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0101562:	7e 06                	jle    c010156a <check_rb_tree+0x41f>
        max = total;
c0101564:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0101567:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }

    for (i = 0; i < max; i ++) {
c010156a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101571:	eb 52                	jmp    c01015c5 <check_rb_tree+0x47a>
        all[i]->data = max;
c0101573:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101576:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010157d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101580:	01 d0                	add    %edx,%eax
c0101582:	8b 00                	mov    (%eax),%eax
c0101584:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0101587:	89 10                	mov    %edx,(%eax)
        rb_insert(tree, &(all[i]->rb_link));
c0101589:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010158c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101593:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101596:	01 d0                	add    %edx,%eax
c0101598:	8b 00                	mov    (%eax),%eax
c010159a:	83 c0 04             	add    $0x4,%eax
c010159d:	83 ec 08             	sub    $0x8,%esp
c01015a0:	50                   	push   %eax
c01015a1:	ff 75 ec             	pushl  -0x14(%ebp)
c01015a4:	e8 67 f1 ff ff       	call   c0100710 <rb_insert>
c01015a9:	83 c4 10             	add    $0x10,%esp
        check_tree(tree, root->left);
c01015ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01015af:	8b 40 08             	mov    0x8(%eax),%eax
c01015b2:	83 ec 08             	sub    $0x8,%esp
c01015b5:	50                   	push   %eax
c01015b6:	ff 75 ec             	pushl  -0x14(%ebp)
c01015b9:	e8 63 f9 ff ff       	call   c0100f21 <check_tree>
c01015be:	83 c4 10             	add    $0x10,%esp
    for (i = 0; i < max; i ++) {
c01015c1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01015c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01015c8:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01015cb:	7c a6                	jl     c0101573 <check_rb_tree+0x428>
    }

    for (i = 0; i < max; i ++) {
c01015cd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01015d4:	eb 70                	jmp    c0101646 <check_rb_tree+0x4fb>
        node = rb_search(tree, check_compare2, (void *)max);
c01015d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01015d9:	83 ec 04             	sub    $0x4,%esp
c01015dc:	50                   	push   %eax
c01015dd:	68 33 11 10 c0       	push   $0xc0101133
c01015e2:	ff 75 ec             	pushl  -0x14(%ebp)
c01015e5:	e8 0a f4 ff ff       	call   c01009f4 <rb_search>
c01015ea:	83 c4 10             	add    $0x10,%esp
c01015ed:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(node != NULL && rbn2data(node)->data == max);
c01015f0:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
c01015f4:	74 0d                	je     c0101603 <check_rb_tree+0x4b8>
c01015f6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01015f9:	83 e8 04             	sub    $0x4,%eax
c01015fc:	8b 00                	mov    (%eax),%eax
c01015fe:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0101601:	74 19                	je     c010161c <check_rb_tree+0x4d1>
c0101603:	68 80 ae 10 c0       	push   $0xc010ae80
c0101608:	68 78 ac 10 c0       	push   $0xc010ac78
c010160d:	68 fb 01 00 00       	push   $0x1fb
c0101612:	68 8d ac 10 c0       	push   $0xc010ac8d
c0101617:	e8 d2 01 00 00       	call   c01017ee <__panic>
        rb_delete(tree, node);
c010161c:	83 ec 08             	sub    $0x8,%esp
c010161f:	ff 75 d4             	pushl  -0x2c(%ebp)
c0101622:	ff 75 ec             	pushl  -0x14(%ebp)
c0101625:	e8 7e f6 ff ff       	call   c0100ca8 <rb_delete>
c010162a:	83 c4 10             	add    $0x10,%esp
        check_tree(tree, root->left);
c010162d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101630:	8b 40 08             	mov    0x8(%eax),%eax
c0101633:	83 ec 08             	sub    $0x8,%esp
c0101636:	50                   	push   %eax
c0101637:	ff 75 ec             	pushl  -0x14(%ebp)
c010163a:	e8 e2 f8 ff ff       	call   c0100f21 <check_tree>
c010163f:	83 c4 10             	add    $0x10,%esp
    for (i = 0; i < max; i ++) {
c0101642:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101646:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101649:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c010164c:	7c 88                	jl     c01015d6 <check_rb_tree+0x48b>
    }

    assert(rb_tree_empty(tree));
c010164e:	83 ec 0c             	sub    $0xc,%esp
c0101651:	ff 75 ec             	pushl  -0x14(%ebp)
c0101654:	e8 23 ed ff ff       	call   c010037c <rb_tree_empty>
c0101659:	83 c4 10             	add    $0x10,%esp
c010165c:	85 c0                	test   %eax,%eax
c010165e:	75 19                	jne    c0101679 <check_rb_tree+0x52e>
c0101660:	68 ac ae 10 c0       	push   $0xc010aeac
c0101665:	68 78 ac 10 c0       	push   $0xc010ac78
c010166a:	68 00 02 00 00       	push   $0x200
c010166f:	68 8d ac 10 c0       	push   $0xc010ac8d
c0101674:	e8 75 01 00 00       	call   c01017ee <__panic>

    for (i = 0; i < total; i ++) {
c0101679:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101680:	eb 3c                	jmp    c01016be <check_rb_tree+0x573>
        rb_insert(tree, &(all[i]->rb_link));
c0101682:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101685:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010168c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010168f:	01 d0                	add    %edx,%eax
c0101691:	8b 00                	mov    (%eax),%eax
c0101693:	83 c0 04             	add    $0x4,%eax
c0101696:	83 ec 08             	sub    $0x8,%esp
c0101699:	50                   	push   %eax
c010169a:	ff 75 ec             	pushl  -0x14(%ebp)
c010169d:	e8 6e f0 ff ff       	call   c0100710 <rb_insert>
c01016a2:	83 c4 10             	add    $0x10,%esp
        check_tree(tree, root->left);
c01016a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01016a8:	8b 40 08             	mov    0x8(%eax),%eax
c01016ab:	83 ec 08             	sub    $0x8,%esp
c01016ae:	50                   	push   %eax
c01016af:	ff 75 ec             	pushl  -0x14(%ebp)
c01016b2:	e8 6a f8 ff ff       	call   c0100f21 <check_tree>
c01016b7:	83 c4 10             	add    $0x10,%esp
    for (i = 0; i < total; i ++) {
c01016ba:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01016be:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01016c1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01016c4:	7c bc                	jl     c0101682 <check_rb_tree+0x537>
    }

    rb_tree_destroy(tree);
c01016c6:	83 ec 0c             	sub    $0xc,%esp
c01016c9:	ff 75 ec             	pushl  -0x14(%ebp)
c01016cc:	e8 2c f7 ff ff       	call   c0100dfd <rb_tree_destroy>
c01016d1:	83 c4 10             	add    $0x10,%esp

    for (i = 0; i < total; i ++) {
c01016d4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01016db:	eb 21                	jmp    c01016fe <check_rb_tree+0x5b3>
        kfree(all[i]);
c01016dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01016e0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01016e7:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01016ea:	01 d0                	add    %edx,%eax
c01016ec:	8b 00                	mov    (%eax),%eax
c01016ee:	83 ec 0c             	sub    $0xc,%esp
c01016f1:	50                   	push   %eax
c01016f2:	e8 1d 65 00 00       	call   c0107c14 <kfree>
c01016f7:	83 c4 10             	add    $0x10,%esp
    for (i = 0; i < total; i ++) {
c01016fa:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01016fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101701:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0101704:	7c d7                	jl     c01016dd <check_rb_tree+0x592>
    }

    kfree(mark);
c0101706:	83 ec 0c             	sub    $0xc,%esp
c0101709:	ff 75 d8             	pushl  -0x28(%ebp)
c010170c:	e8 03 65 00 00       	call   c0107c14 <kfree>
c0101711:	83 c4 10             	add    $0x10,%esp
    kfree(all);
c0101714:	83 ec 0c             	sub    $0xc,%esp
c0101717:	ff 75 dc             	pushl  -0x24(%ebp)
c010171a:	e8 f5 64 00 00       	call   c0107c14 <kfree>
c010171f:	83 c4 10             	add    $0x10,%esp
}
c0101722:	90                   	nop
c0101723:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0101726:	c9                   	leave  
c0101727:	c3                   	ret    

c0101728 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c0101728:	f3 0f 1e fb          	endbr32 
c010172c:	55                   	push   %ebp
c010172d:	89 e5                	mov    %esp,%ebp
c010172f:	83 ec 18             	sub    $0x18,%esp
    if (prompt != NULL) {
c0101732:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0101736:	74 13                	je     c010174b <readline+0x23>
        cprintf("%s", prompt);
c0101738:	83 ec 08             	sub    $0x8,%esp
c010173b:	ff 75 08             	pushl  0x8(%ebp)
c010173e:	68 c0 ae 10 c0       	push   $0xc010aec0
c0101743:	e8 6a eb ff ff       	call   c01002b2 <cprintf>
c0101748:	83 c4 10             	add    $0x10,%esp
    }
    int i = 0, c;
c010174b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c0101752:	e8 f2 eb ff ff       	call   c0100349 <getchar>
c0101757:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c010175a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010175e:	79 0a                	jns    c010176a <readline+0x42>
            return NULL;
c0101760:	b8 00 00 00 00       	mov    $0x0,%eax
c0101765:	e9 82 00 00 00       	jmp    c01017ec <readline+0xc4>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c010176a:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c010176e:	7e 2b                	jle    c010179b <readline+0x73>
c0101770:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c0101777:	7f 22                	jg     c010179b <readline+0x73>
            cputchar(c);
c0101779:	83 ec 0c             	sub    $0xc,%esp
c010177c:	ff 75 f0             	pushl  -0x10(%ebp)
c010177f:	e8 58 eb ff ff       	call   c01002dc <cputchar>
c0101784:	83 c4 10             	add    $0x10,%esp
            buf[i ++] = c;
c0101787:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010178a:	8d 50 01             	lea    0x1(%eax),%edx
c010178d:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0101790:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0101793:	88 90 20 e0 12 c0    	mov    %dl,-0x3fed1fe0(%eax)
c0101799:	eb 4c                	jmp    c01017e7 <readline+0xbf>
        }
        else if (c == '\b' && i > 0) {
c010179b:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c010179f:	75 1a                	jne    c01017bb <readline+0x93>
c01017a1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01017a5:	7e 14                	jle    c01017bb <readline+0x93>
            cputchar(c);
c01017a7:	83 ec 0c             	sub    $0xc,%esp
c01017aa:	ff 75 f0             	pushl  -0x10(%ebp)
c01017ad:	e8 2a eb ff ff       	call   c01002dc <cputchar>
c01017b2:	83 c4 10             	add    $0x10,%esp
            i --;
c01017b5:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01017b9:	eb 2c                	jmp    c01017e7 <readline+0xbf>
        }
        else if (c == '\n' || c == '\r') {
c01017bb:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c01017bf:	74 06                	je     c01017c7 <readline+0x9f>
c01017c1:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c01017c5:	75 8b                	jne    c0101752 <readline+0x2a>
            cputchar(c);
c01017c7:	83 ec 0c             	sub    $0xc,%esp
c01017ca:	ff 75 f0             	pushl  -0x10(%ebp)
c01017cd:	e8 0a eb ff ff       	call   c01002dc <cputchar>
c01017d2:	83 c4 10             	add    $0x10,%esp
            buf[i] = '\0';
c01017d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01017d8:	05 20 e0 12 c0       	add    $0xc012e020,%eax
c01017dd:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c01017e0:	b8 20 e0 12 c0       	mov    $0xc012e020,%eax
c01017e5:	eb 05                	jmp    c01017ec <readline+0xc4>
        c = getchar();
c01017e7:	e9 66 ff ff ff       	jmp    c0101752 <readline+0x2a>
        }
    }
}
c01017ec:	c9                   	leave  
c01017ed:	c3                   	ret    

c01017ee <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c01017ee:	f3 0f 1e fb          	endbr32 
c01017f2:	55                   	push   %ebp
c01017f3:	89 e5                	mov    %esp,%ebp
c01017f5:	83 ec 18             	sub    $0x18,%esp
    if (is_panic) {
c01017f8:	a1 20 e4 12 c0       	mov    0xc012e420,%eax
c01017fd:	85 c0                	test   %eax,%eax
c01017ff:	75 5f                	jne    c0101860 <__panic+0x72>
        goto panic_dead;
    }
    is_panic = 1;
c0101801:	c7 05 20 e4 12 c0 01 	movl   $0x1,0xc012e420
c0101808:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c010180b:	8d 45 14             	lea    0x14(%ebp),%eax
c010180e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0101811:	83 ec 04             	sub    $0x4,%esp
c0101814:	ff 75 0c             	pushl  0xc(%ebp)
c0101817:	ff 75 08             	pushl  0x8(%ebp)
c010181a:	68 c3 ae 10 c0       	push   $0xc010aec3
c010181f:	e8 8e ea ff ff       	call   c01002b2 <cprintf>
c0101824:	83 c4 10             	add    $0x10,%esp
    vcprintf(fmt, ap);
c0101827:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010182a:	83 ec 08             	sub    $0x8,%esp
c010182d:	50                   	push   %eax
c010182e:	ff 75 10             	pushl  0x10(%ebp)
c0101831:	e8 4f ea ff ff       	call   c0100285 <vcprintf>
c0101836:	83 c4 10             	add    $0x10,%esp
    cprintf("\n");
c0101839:	83 ec 0c             	sub    $0xc,%esp
c010183c:	68 df ae 10 c0       	push   $0xc010aedf
c0101841:	e8 6c ea ff ff       	call   c01002b2 <cprintf>
c0101846:	83 c4 10             	add    $0x10,%esp
    
    cprintf("stack trackback:\n");
c0101849:	83 ec 0c             	sub    $0xc,%esp
c010184c:	68 e1 ae 10 c0       	push   $0xc010aee1
c0101851:	e8 5c ea ff ff       	call   c01002b2 <cprintf>
c0101856:	83 c4 10             	add    $0x10,%esp
    print_stackframe();
c0101859:	e8 25 06 00 00       	call   c0101e83 <print_stackframe>
c010185e:	eb 01                	jmp    c0101861 <__panic+0x73>
        goto panic_dead;
c0101860:	90                   	nop
    
    va_end(ap);

panic_dead:
    intr_disable();
c0101861:	e8 c6 1c 00 00       	call   c010352c <intr_disable>
    while (1) {
        kmonitor(NULL);
c0101866:	83 ec 0c             	sub    $0xc,%esp
c0101869:	6a 00                	push   $0x0
c010186b:	e8 4c 08 00 00       	call   c01020bc <kmonitor>
c0101870:	83 c4 10             	add    $0x10,%esp
c0101873:	eb f1                	jmp    c0101866 <__panic+0x78>

c0101875 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c0101875:	f3 0f 1e fb          	endbr32 
c0101879:	55                   	push   %ebp
c010187a:	89 e5                	mov    %esp,%ebp
c010187c:	83 ec 18             	sub    $0x18,%esp
    va_list ap;
    va_start(ap, fmt);
c010187f:	8d 45 14             	lea    0x14(%ebp),%eax
c0101882:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c0101885:	83 ec 04             	sub    $0x4,%esp
c0101888:	ff 75 0c             	pushl  0xc(%ebp)
c010188b:	ff 75 08             	pushl  0x8(%ebp)
c010188e:	68 f3 ae 10 c0       	push   $0xc010aef3
c0101893:	e8 1a ea ff ff       	call   c01002b2 <cprintf>
c0101898:	83 c4 10             	add    $0x10,%esp
    vcprintf(fmt, ap);
c010189b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010189e:	83 ec 08             	sub    $0x8,%esp
c01018a1:	50                   	push   %eax
c01018a2:	ff 75 10             	pushl  0x10(%ebp)
c01018a5:	e8 db e9 ff ff       	call   c0100285 <vcprintf>
c01018aa:	83 c4 10             	add    $0x10,%esp
    cprintf("\n");
c01018ad:	83 ec 0c             	sub    $0xc,%esp
c01018b0:	68 df ae 10 c0       	push   $0xc010aedf
c01018b5:	e8 f8 e9 ff ff       	call   c01002b2 <cprintf>
c01018ba:	83 c4 10             	add    $0x10,%esp
    va_end(ap);
}
c01018bd:	90                   	nop
c01018be:	c9                   	leave  
c01018bf:	c3                   	ret    

c01018c0 <is_kernel_panic>:

bool
is_kernel_panic(void) {
c01018c0:	f3 0f 1e fb          	endbr32 
c01018c4:	55                   	push   %ebp
c01018c5:	89 e5                	mov    %esp,%ebp
    return is_panic;
c01018c7:	a1 20 e4 12 c0       	mov    0xc012e420,%eax
}
c01018cc:	5d                   	pop    %ebp
c01018cd:	c3                   	ret    

c01018ce <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c01018ce:	f3 0f 1e fb          	endbr32 
c01018d2:	55                   	push   %ebp
c01018d3:	89 e5                	mov    %esp,%ebp
c01018d5:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c01018d8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01018db:	8b 00                	mov    (%eax),%eax
c01018dd:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01018e0:	8b 45 10             	mov    0x10(%ebp),%eax
c01018e3:	8b 00                	mov    (%eax),%eax
c01018e5:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01018e8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c01018ef:	e9 d2 00 00 00       	jmp    c01019c6 <stab_binsearch+0xf8>
        int true_m = (l + r) / 2, m = true_m;
c01018f4:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01018f7:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01018fa:	01 d0                	add    %edx,%eax
c01018fc:	89 c2                	mov    %eax,%edx
c01018fe:	c1 ea 1f             	shr    $0x1f,%edx
c0101901:	01 d0                	add    %edx,%eax
c0101903:	d1 f8                	sar    %eax
c0101905:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0101908:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010190b:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c010190e:	eb 04                	jmp    c0101914 <stab_binsearch+0x46>
            m --;
c0101910:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
        while (m >= l && stabs[m].n_type != type) {
c0101914:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101917:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010191a:	7c 1f                	jl     c010193b <stab_binsearch+0x6d>
c010191c:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010191f:	89 d0                	mov    %edx,%eax
c0101921:	01 c0                	add    %eax,%eax
c0101923:	01 d0                	add    %edx,%eax
c0101925:	c1 e0 02             	shl    $0x2,%eax
c0101928:	89 c2                	mov    %eax,%edx
c010192a:	8b 45 08             	mov    0x8(%ebp),%eax
c010192d:	01 d0                	add    %edx,%eax
c010192f:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0101933:	0f b6 c0             	movzbl %al,%eax
c0101936:	39 45 14             	cmp    %eax,0x14(%ebp)
c0101939:	75 d5                	jne    c0101910 <stab_binsearch+0x42>
        }
        if (m < l) {    // no match in [l, m]
c010193b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010193e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0101941:	7d 0b                	jge    c010194e <stab_binsearch+0x80>
            l = true_m + 1;
c0101943:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101946:	83 c0 01             	add    $0x1,%eax
c0101949:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c010194c:	eb 78                	jmp    c01019c6 <stab_binsearch+0xf8>
        }

        // actual binary search
        any_matches = 1;
c010194e:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c0101955:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0101958:	89 d0                	mov    %edx,%eax
c010195a:	01 c0                	add    %eax,%eax
c010195c:	01 d0                	add    %edx,%eax
c010195e:	c1 e0 02             	shl    $0x2,%eax
c0101961:	89 c2                	mov    %eax,%edx
c0101963:	8b 45 08             	mov    0x8(%ebp),%eax
c0101966:	01 d0                	add    %edx,%eax
c0101968:	8b 40 08             	mov    0x8(%eax),%eax
c010196b:	39 45 18             	cmp    %eax,0x18(%ebp)
c010196e:	76 13                	jbe    c0101983 <stab_binsearch+0xb5>
            *region_left = m;
c0101970:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101973:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0101976:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c0101978:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010197b:	83 c0 01             	add    $0x1,%eax
c010197e:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0101981:	eb 43                	jmp    c01019c6 <stab_binsearch+0xf8>
        } else if (stabs[m].n_value > addr) {
c0101983:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0101986:	89 d0                	mov    %edx,%eax
c0101988:	01 c0                	add    %eax,%eax
c010198a:	01 d0                	add    %edx,%eax
c010198c:	c1 e0 02             	shl    $0x2,%eax
c010198f:	89 c2                	mov    %eax,%edx
c0101991:	8b 45 08             	mov    0x8(%ebp),%eax
c0101994:	01 d0                	add    %edx,%eax
c0101996:	8b 40 08             	mov    0x8(%eax),%eax
c0101999:	39 45 18             	cmp    %eax,0x18(%ebp)
c010199c:	73 16                	jae    c01019b4 <stab_binsearch+0xe6>
            *region_right = m - 1;
c010199e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01019a1:	8d 50 ff             	lea    -0x1(%eax),%edx
c01019a4:	8b 45 10             	mov    0x10(%ebp),%eax
c01019a7:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c01019a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01019ac:	83 e8 01             	sub    $0x1,%eax
c01019af:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01019b2:	eb 12                	jmp    c01019c6 <stab_binsearch+0xf8>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c01019b4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01019b7:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01019ba:	89 10                	mov    %edx,(%eax)
            l = m;
c01019bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01019bf:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c01019c2:	83 45 18 01          	addl   $0x1,0x18(%ebp)
    while (l <= r) {
c01019c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019c9:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01019cc:	0f 8e 22 ff ff ff    	jle    c01018f4 <stab_binsearch+0x26>
        }
    }

    if (!any_matches) {
c01019d2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01019d6:	75 0f                	jne    c01019e7 <stab_binsearch+0x119>
        *region_right = *region_left - 1;
c01019d8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01019db:	8b 00                	mov    (%eax),%eax
c01019dd:	8d 50 ff             	lea    -0x1(%eax),%edx
c01019e0:	8b 45 10             	mov    0x10(%ebp),%eax
c01019e3:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
c01019e5:	eb 3f                	jmp    c0101a26 <stab_binsearch+0x158>
        l = *region_right;
c01019e7:	8b 45 10             	mov    0x10(%ebp),%eax
c01019ea:	8b 00                	mov    (%eax),%eax
c01019ec:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c01019ef:	eb 04                	jmp    c01019f5 <stab_binsearch+0x127>
c01019f1:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
c01019f5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01019f8:	8b 00                	mov    (%eax),%eax
c01019fa:	39 45 fc             	cmp    %eax,-0x4(%ebp)
c01019fd:	7e 1f                	jle    c0101a1e <stab_binsearch+0x150>
c01019ff:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0101a02:	89 d0                	mov    %edx,%eax
c0101a04:	01 c0                	add    %eax,%eax
c0101a06:	01 d0                	add    %edx,%eax
c0101a08:	c1 e0 02             	shl    $0x2,%eax
c0101a0b:	89 c2                	mov    %eax,%edx
c0101a0d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a10:	01 d0                	add    %edx,%eax
c0101a12:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0101a16:	0f b6 c0             	movzbl %al,%eax
c0101a19:	39 45 14             	cmp    %eax,0x14(%ebp)
c0101a1c:	75 d3                	jne    c01019f1 <stab_binsearch+0x123>
        *region_left = l;
c0101a1e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101a21:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0101a24:	89 10                	mov    %edx,(%eax)
}
c0101a26:	90                   	nop
c0101a27:	c9                   	leave  
c0101a28:	c3                   	ret    

c0101a29 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c0101a29:	f3 0f 1e fb          	endbr32 
c0101a2d:	55                   	push   %ebp
c0101a2e:	89 e5                	mov    %esp,%ebp
c0101a30:	83 ec 38             	sub    $0x38,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c0101a33:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101a36:	c7 00 14 af 10 c0    	movl   $0xc010af14,(%eax)
    info->eip_line = 0;
c0101a3c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101a3f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c0101a46:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101a49:	c7 40 08 14 af 10 c0 	movl   $0xc010af14,0x8(%eax)
    info->eip_fn_namelen = 9;
c0101a50:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101a53:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c0101a5a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101a5d:	8b 55 08             	mov    0x8(%ebp),%edx
c0101a60:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c0101a63:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101a66:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c0101a6d:	c7 45 f4 ac d1 10 c0 	movl   $0xc010d1ac,-0xc(%ebp)
    stab_end = __STAB_END__;
c0101a74:	c7 45 f0 7c 3c 12 c0 	movl   $0xc0123c7c,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c0101a7b:	c7 45 ec 7d 3c 12 c0 	movl   $0xc0123c7d,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c0101a82:	c7 45 e8 a5 8a 12 c0 	movl   $0xc0128aa5,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c0101a89:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0101a8c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0101a8f:	76 0d                	jbe    c0101a9e <debuginfo_eip+0x75>
c0101a91:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0101a94:	83 e8 01             	sub    $0x1,%eax
c0101a97:	0f b6 00             	movzbl (%eax),%eax
c0101a9a:	84 c0                	test   %al,%al
c0101a9c:	74 0a                	je     c0101aa8 <debuginfo_eip+0x7f>
        return -1;
c0101a9e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101aa3:	e9 85 02 00 00       	jmp    c0101d2d <debuginfo_eip+0x304>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c0101aa8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c0101aaf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101ab2:	2b 45 f4             	sub    -0xc(%ebp),%eax
c0101ab5:	c1 f8 02             	sar    $0x2,%eax
c0101ab8:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c0101abe:	83 e8 01             	sub    $0x1,%eax
c0101ac1:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c0101ac4:	ff 75 08             	pushl  0x8(%ebp)
c0101ac7:	6a 64                	push   $0x64
c0101ac9:	8d 45 e0             	lea    -0x20(%ebp),%eax
c0101acc:	50                   	push   %eax
c0101acd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c0101ad0:	50                   	push   %eax
c0101ad1:	ff 75 f4             	pushl  -0xc(%ebp)
c0101ad4:	e8 f5 fd ff ff       	call   c01018ce <stab_binsearch>
c0101ad9:	83 c4 14             	add    $0x14,%esp
    if (lfile == 0)
c0101adc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101adf:	85 c0                	test   %eax,%eax
c0101ae1:	75 0a                	jne    c0101aed <debuginfo_eip+0xc4>
        return -1;
c0101ae3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101ae8:	e9 40 02 00 00       	jmp    c0101d2d <debuginfo_eip+0x304>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c0101aed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101af0:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0101af3:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0101af6:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c0101af9:	ff 75 08             	pushl  0x8(%ebp)
c0101afc:	6a 24                	push   $0x24
c0101afe:	8d 45 d8             	lea    -0x28(%ebp),%eax
c0101b01:	50                   	push   %eax
c0101b02:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0101b05:	50                   	push   %eax
c0101b06:	ff 75 f4             	pushl  -0xc(%ebp)
c0101b09:	e8 c0 fd ff ff       	call   c01018ce <stab_binsearch>
c0101b0e:	83 c4 14             	add    $0x14,%esp

    if (lfun <= rfun) {
c0101b11:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101b14:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0101b17:	39 c2                	cmp    %eax,%edx
c0101b19:	7f 78                	jg     c0101b93 <debuginfo_eip+0x16a>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c0101b1b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101b1e:	89 c2                	mov    %eax,%edx
c0101b20:	89 d0                	mov    %edx,%eax
c0101b22:	01 c0                	add    %eax,%eax
c0101b24:	01 d0                	add    %edx,%eax
c0101b26:	c1 e0 02             	shl    $0x2,%eax
c0101b29:	89 c2                	mov    %eax,%edx
c0101b2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101b2e:	01 d0                	add    %edx,%eax
c0101b30:	8b 10                	mov    (%eax),%edx
c0101b32:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0101b35:	2b 45 ec             	sub    -0x14(%ebp),%eax
c0101b38:	39 c2                	cmp    %eax,%edx
c0101b3a:	73 22                	jae    c0101b5e <debuginfo_eip+0x135>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c0101b3c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101b3f:	89 c2                	mov    %eax,%edx
c0101b41:	89 d0                	mov    %edx,%eax
c0101b43:	01 c0                	add    %eax,%eax
c0101b45:	01 d0                	add    %edx,%eax
c0101b47:	c1 e0 02             	shl    $0x2,%eax
c0101b4a:	89 c2                	mov    %eax,%edx
c0101b4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101b4f:	01 d0                	add    %edx,%eax
c0101b51:	8b 10                	mov    (%eax),%edx
c0101b53:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101b56:	01 c2                	add    %eax,%edx
c0101b58:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101b5b:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c0101b5e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101b61:	89 c2                	mov    %eax,%edx
c0101b63:	89 d0                	mov    %edx,%eax
c0101b65:	01 c0                	add    %eax,%eax
c0101b67:	01 d0                	add    %edx,%eax
c0101b69:	c1 e0 02             	shl    $0x2,%eax
c0101b6c:	89 c2                	mov    %eax,%edx
c0101b6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101b71:	01 d0                	add    %edx,%eax
c0101b73:	8b 50 08             	mov    0x8(%eax),%edx
c0101b76:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101b79:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c0101b7c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101b7f:	8b 40 10             	mov    0x10(%eax),%eax
c0101b82:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c0101b85:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101b88:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c0101b8b:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0101b8e:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0101b91:	eb 15                	jmp    c0101ba8 <debuginfo_eip+0x17f>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c0101b93:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101b96:	8b 55 08             	mov    0x8(%ebp),%edx
c0101b99:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c0101b9c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101b9f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c0101ba2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0101ba5:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c0101ba8:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101bab:	8b 40 08             	mov    0x8(%eax),%eax
c0101bae:	83 ec 08             	sub    $0x8,%esp
c0101bb1:	6a 3a                	push   $0x3a
c0101bb3:	50                   	push   %eax
c0101bb4:	e8 97 85 00 00       	call   c010a150 <strfind>
c0101bb9:	83 c4 10             	add    $0x10,%esp
c0101bbc:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101bbf:	8b 52 08             	mov    0x8(%edx),%edx
c0101bc2:	29 d0                	sub    %edx,%eax
c0101bc4:	89 c2                	mov    %eax,%edx
c0101bc6:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101bc9:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c0101bcc:	83 ec 0c             	sub    $0xc,%esp
c0101bcf:	ff 75 08             	pushl  0x8(%ebp)
c0101bd2:	6a 44                	push   $0x44
c0101bd4:	8d 45 d0             	lea    -0x30(%ebp),%eax
c0101bd7:	50                   	push   %eax
c0101bd8:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c0101bdb:	50                   	push   %eax
c0101bdc:	ff 75 f4             	pushl  -0xc(%ebp)
c0101bdf:	e8 ea fc ff ff       	call   c01018ce <stab_binsearch>
c0101be4:	83 c4 20             	add    $0x20,%esp
    if (lline <= rline) {
c0101be7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0101bea:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0101bed:	39 c2                	cmp    %eax,%edx
c0101bef:	7f 24                	jg     c0101c15 <debuginfo_eip+0x1ec>
        info->eip_line = stabs[rline].n_desc;
c0101bf1:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0101bf4:	89 c2                	mov    %eax,%edx
c0101bf6:	89 d0                	mov    %edx,%eax
c0101bf8:	01 c0                	add    %eax,%eax
c0101bfa:	01 d0                	add    %edx,%eax
c0101bfc:	c1 e0 02             	shl    $0x2,%eax
c0101bff:	89 c2                	mov    %eax,%edx
c0101c01:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101c04:	01 d0                	add    %edx,%eax
c0101c06:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c0101c0a:	0f b7 d0             	movzwl %ax,%edx
c0101c0d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101c10:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0101c13:	eb 13                	jmp    c0101c28 <debuginfo_eip+0x1ff>
        return -1;
c0101c15:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101c1a:	e9 0e 01 00 00       	jmp    c0101d2d <debuginfo_eip+0x304>
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c0101c1f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0101c22:	83 e8 01             	sub    $0x1,%eax
c0101c25:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while (lline >= lfile
c0101c28:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0101c2b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101c2e:	39 c2                	cmp    %eax,%edx
c0101c30:	7c 56                	jl     c0101c88 <debuginfo_eip+0x25f>
           && stabs[lline].n_type != N_SOL
c0101c32:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0101c35:	89 c2                	mov    %eax,%edx
c0101c37:	89 d0                	mov    %edx,%eax
c0101c39:	01 c0                	add    %eax,%eax
c0101c3b:	01 d0                	add    %edx,%eax
c0101c3d:	c1 e0 02             	shl    $0x2,%eax
c0101c40:	89 c2                	mov    %eax,%edx
c0101c42:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101c45:	01 d0                	add    %edx,%eax
c0101c47:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0101c4b:	3c 84                	cmp    $0x84,%al
c0101c4d:	74 39                	je     c0101c88 <debuginfo_eip+0x25f>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c0101c4f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0101c52:	89 c2                	mov    %eax,%edx
c0101c54:	89 d0                	mov    %edx,%eax
c0101c56:	01 c0                	add    %eax,%eax
c0101c58:	01 d0                	add    %edx,%eax
c0101c5a:	c1 e0 02             	shl    $0x2,%eax
c0101c5d:	89 c2                	mov    %eax,%edx
c0101c5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101c62:	01 d0                	add    %edx,%eax
c0101c64:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0101c68:	3c 64                	cmp    $0x64,%al
c0101c6a:	75 b3                	jne    c0101c1f <debuginfo_eip+0x1f6>
c0101c6c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0101c6f:	89 c2                	mov    %eax,%edx
c0101c71:	89 d0                	mov    %edx,%eax
c0101c73:	01 c0                	add    %eax,%eax
c0101c75:	01 d0                	add    %edx,%eax
c0101c77:	c1 e0 02             	shl    $0x2,%eax
c0101c7a:	89 c2                	mov    %eax,%edx
c0101c7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101c7f:	01 d0                	add    %edx,%eax
c0101c81:	8b 40 08             	mov    0x8(%eax),%eax
c0101c84:	85 c0                	test   %eax,%eax
c0101c86:	74 97                	je     c0101c1f <debuginfo_eip+0x1f6>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c0101c88:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0101c8b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101c8e:	39 c2                	cmp    %eax,%edx
c0101c90:	7c 42                	jl     c0101cd4 <debuginfo_eip+0x2ab>
c0101c92:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0101c95:	89 c2                	mov    %eax,%edx
c0101c97:	89 d0                	mov    %edx,%eax
c0101c99:	01 c0                	add    %eax,%eax
c0101c9b:	01 d0                	add    %edx,%eax
c0101c9d:	c1 e0 02             	shl    $0x2,%eax
c0101ca0:	89 c2                	mov    %eax,%edx
c0101ca2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101ca5:	01 d0                	add    %edx,%eax
c0101ca7:	8b 10                	mov    (%eax),%edx
c0101ca9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0101cac:	2b 45 ec             	sub    -0x14(%ebp),%eax
c0101caf:	39 c2                	cmp    %eax,%edx
c0101cb1:	73 21                	jae    c0101cd4 <debuginfo_eip+0x2ab>
        info->eip_file = stabstr + stabs[lline].n_strx;
c0101cb3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0101cb6:	89 c2                	mov    %eax,%edx
c0101cb8:	89 d0                	mov    %edx,%eax
c0101cba:	01 c0                	add    %eax,%eax
c0101cbc:	01 d0                	add    %edx,%eax
c0101cbe:	c1 e0 02             	shl    $0x2,%eax
c0101cc1:	89 c2                	mov    %eax,%edx
c0101cc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101cc6:	01 d0                	add    %edx,%eax
c0101cc8:	8b 10                	mov    (%eax),%edx
c0101cca:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101ccd:	01 c2                	add    %eax,%edx
c0101ccf:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101cd2:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c0101cd4:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101cd7:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0101cda:	39 c2                	cmp    %eax,%edx
c0101cdc:	7d 4a                	jge    c0101d28 <debuginfo_eip+0x2ff>
        for (lline = lfun + 1;
c0101cde:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101ce1:	83 c0 01             	add    $0x1,%eax
c0101ce4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0101ce7:	eb 18                	jmp    c0101d01 <debuginfo_eip+0x2d8>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c0101ce9:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101cec:	8b 40 14             	mov    0x14(%eax),%eax
c0101cef:	8d 50 01             	lea    0x1(%eax),%edx
c0101cf2:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101cf5:	89 50 14             	mov    %edx,0x14(%eax)
             lline ++) {
c0101cf8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0101cfb:	83 c0 01             	add    $0x1,%eax
c0101cfe:	89 45 d4             	mov    %eax,-0x2c(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0101d01:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0101d04:	8b 45 d8             	mov    -0x28(%ebp),%eax
        for (lline = lfun + 1;
c0101d07:	39 c2                	cmp    %eax,%edx
c0101d09:	7d 1d                	jge    c0101d28 <debuginfo_eip+0x2ff>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0101d0b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0101d0e:	89 c2                	mov    %eax,%edx
c0101d10:	89 d0                	mov    %edx,%eax
c0101d12:	01 c0                	add    %eax,%eax
c0101d14:	01 d0                	add    %edx,%eax
c0101d16:	c1 e0 02             	shl    $0x2,%eax
c0101d19:	89 c2                	mov    %eax,%edx
c0101d1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101d1e:	01 d0                	add    %edx,%eax
c0101d20:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0101d24:	3c a0                	cmp    $0xa0,%al
c0101d26:	74 c1                	je     c0101ce9 <debuginfo_eip+0x2c0>
        }
    }
    return 0;
c0101d28:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101d2d:	c9                   	leave  
c0101d2e:	c3                   	ret    

c0101d2f <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c0101d2f:	f3 0f 1e fb          	endbr32 
c0101d33:	55                   	push   %ebp
c0101d34:	89 e5                	mov    %esp,%ebp
c0101d36:	83 ec 08             	sub    $0x8,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c0101d39:	83 ec 0c             	sub    $0xc,%esp
c0101d3c:	68 1e af 10 c0       	push   $0xc010af1e
c0101d41:	e8 6c e5 ff ff       	call   c01002b2 <cprintf>
c0101d46:	83 c4 10             	add    $0x10,%esp
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c0101d49:	83 ec 08             	sub    $0x8,%esp
c0101d4c:	68 36 00 10 c0       	push   $0xc0100036
c0101d51:	68 37 af 10 c0       	push   $0xc010af37
c0101d56:	e8 57 e5 ff ff       	call   c01002b2 <cprintf>
c0101d5b:	83 c4 10             	add    $0x10,%esp
    cprintf("  etext  0x%08x (phys)\n", etext);
c0101d5e:	83 ec 08             	sub    $0x8,%esp
c0101d61:	68 ae ab 10 c0       	push   $0xc010abae
c0101d66:	68 4f af 10 c0       	push   $0xc010af4f
c0101d6b:	e8 42 e5 ff ff       	call   c01002b2 <cprintf>
c0101d70:	83 c4 10             	add    $0x10,%esp
    cprintf("  edata  0x%08x (phys)\n", edata);
c0101d73:	83 ec 08             	sub    $0x8,%esp
c0101d76:	68 00 e0 12 c0       	push   $0xc012e000
c0101d7b:	68 67 af 10 c0       	push   $0xc010af67
c0101d80:	e8 2d e5 ff ff       	call   c01002b2 <cprintf>
c0101d85:	83 c4 10             	add    $0x10,%esp
    cprintf("  end    0x%08x (phys)\n", end);
c0101d88:	83 ec 08             	sub    $0x8,%esp
c0101d8b:	68 60 11 13 c0       	push   $0xc0131160
c0101d90:	68 7f af 10 c0       	push   $0xc010af7f
c0101d95:	e8 18 e5 ff ff       	call   c01002b2 <cprintf>
c0101d9a:	83 c4 10             	add    $0x10,%esp
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c0101d9d:	b8 60 11 13 c0       	mov    $0xc0131160,%eax
c0101da2:	2d 36 00 10 c0       	sub    $0xc0100036,%eax
c0101da7:	05 ff 03 00 00       	add    $0x3ff,%eax
c0101dac:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c0101db2:	85 c0                	test   %eax,%eax
c0101db4:	0f 48 c2             	cmovs  %edx,%eax
c0101db7:	c1 f8 0a             	sar    $0xa,%eax
c0101dba:	83 ec 08             	sub    $0x8,%esp
c0101dbd:	50                   	push   %eax
c0101dbe:	68 98 af 10 c0       	push   $0xc010af98
c0101dc3:	e8 ea e4 ff ff       	call   c01002b2 <cprintf>
c0101dc8:	83 c4 10             	add    $0x10,%esp
}
c0101dcb:	90                   	nop
c0101dcc:	c9                   	leave  
c0101dcd:	c3                   	ret    

c0101dce <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c0101dce:	f3 0f 1e fb          	endbr32 
c0101dd2:	55                   	push   %ebp
c0101dd3:	89 e5                	mov    %esp,%ebp
c0101dd5:	81 ec 28 01 00 00    	sub    $0x128,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c0101ddb:	83 ec 08             	sub    $0x8,%esp
c0101dde:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0101de1:	50                   	push   %eax
c0101de2:	ff 75 08             	pushl  0x8(%ebp)
c0101de5:	e8 3f fc ff ff       	call   c0101a29 <debuginfo_eip>
c0101dea:	83 c4 10             	add    $0x10,%esp
c0101ded:	85 c0                	test   %eax,%eax
c0101def:	74 15                	je     c0101e06 <print_debuginfo+0x38>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c0101df1:	83 ec 08             	sub    $0x8,%esp
c0101df4:	ff 75 08             	pushl  0x8(%ebp)
c0101df7:	68 c2 af 10 c0       	push   $0xc010afc2
c0101dfc:	e8 b1 e4 ff ff       	call   c01002b2 <cprintf>
c0101e01:	83 c4 10             	add    $0x10,%esp
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
c0101e04:	eb 65                	jmp    c0101e6b <print_debuginfo+0x9d>
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0101e06:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101e0d:	eb 1c                	jmp    c0101e2b <print_debuginfo+0x5d>
            fnname[j] = info.eip_fn_name[j];
c0101e0f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0101e12:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101e15:	01 d0                	add    %edx,%eax
c0101e17:	0f b6 00             	movzbl (%eax),%eax
c0101e1a:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0101e20:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101e23:	01 ca                	add    %ecx,%edx
c0101e25:	88 02                	mov    %al,(%edx)
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0101e27:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101e2b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0101e2e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0101e31:	7c dc                	jl     c0101e0f <print_debuginfo+0x41>
        fnname[j] = '\0';
c0101e33:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0101e39:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101e3c:	01 d0                	add    %edx,%eax
c0101e3e:	c6 00 00             	movb   $0x0,(%eax)
                fnname, eip - info.eip_fn_addr);
c0101e41:	8b 45 ec             	mov    -0x14(%ebp),%eax
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0101e44:	8b 55 08             	mov    0x8(%ebp),%edx
c0101e47:	89 d1                	mov    %edx,%ecx
c0101e49:	29 c1                	sub    %eax,%ecx
c0101e4b:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0101e4e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101e51:	83 ec 0c             	sub    $0xc,%esp
c0101e54:	51                   	push   %ecx
c0101e55:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0101e5b:	51                   	push   %ecx
c0101e5c:	52                   	push   %edx
c0101e5d:	50                   	push   %eax
c0101e5e:	68 de af 10 c0       	push   $0xc010afde
c0101e63:	e8 4a e4 ff ff       	call   c01002b2 <cprintf>
c0101e68:	83 c4 20             	add    $0x20,%esp
}
c0101e6b:	90                   	nop
c0101e6c:	c9                   	leave  
c0101e6d:	c3                   	ret    

c0101e6e <read_eip>:

static __noinline uint32_t
read_eip(void) {
c0101e6e:	f3 0f 1e fb          	endbr32 
c0101e72:	55                   	push   %ebp
c0101e73:	89 e5                	mov    %esp,%ebp
c0101e75:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c0101e78:	8b 45 04             	mov    0x4(%ebp),%eax
c0101e7b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c0101e7e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0101e81:	c9                   	leave  
c0101e82:	c3                   	ret    

c0101e83 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c0101e83:	f3 0f 1e fb          	endbr32 
c0101e87:	55                   	push   %ebp
c0101e88:	89 e5                	mov    %esp,%ebp
c0101e8a:	83 ec 28             	sub    $0x28,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c0101e8d:	89 e8                	mov    %ebp,%eax
c0101e8f:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
c0101e92:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp(), eip = read_eip();
c0101e95:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101e98:	e8 d1 ff ff ff       	call   c0101e6e <read_eip>
c0101e9d:	89 45 f0             	mov    %eax,-0x10(%ebp)

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
c0101ea0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0101ea7:	e9 8d 00 00 00       	jmp    c0101f39 <print_stackframe+0xb6>
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
c0101eac:	83 ec 04             	sub    $0x4,%esp
c0101eaf:	ff 75 f0             	pushl  -0x10(%ebp)
c0101eb2:	ff 75 f4             	pushl  -0xc(%ebp)
c0101eb5:	68 f0 af 10 c0       	push   $0xc010aff0
c0101eba:	e8 f3 e3 ff ff       	call   c01002b2 <cprintf>
c0101ebf:	83 c4 10             	add    $0x10,%esp
        uint32_t *args = (uint32_t *)ebp + 2;
c0101ec2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101ec5:	83 c0 08             	add    $0x8,%eax
c0101ec8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (j = 0; j < 4; j ++) {
c0101ecb:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0101ed2:	eb 26                	jmp    c0101efa <print_stackframe+0x77>
            cprintf("0x%08x ", args[j]);
c0101ed4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0101ed7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101ede:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101ee1:	01 d0                	add    %edx,%eax
c0101ee3:	8b 00                	mov    (%eax),%eax
c0101ee5:	83 ec 08             	sub    $0x8,%esp
c0101ee8:	50                   	push   %eax
c0101ee9:	68 0c b0 10 c0       	push   $0xc010b00c
c0101eee:	e8 bf e3 ff ff       	call   c01002b2 <cprintf>
c0101ef3:	83 c4 10             	add    $0x10,%esp
        for (j = 0; j < 4; j ++) {
c0101ef6:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
c0101efa:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
c0101efe:	7e d4                	jle    c0101ed4 <print_stackframe+0x51>
        }
        cprintf("\n");
c0101f00:	83 ec 0c             	sub    $0xc,%esp
c0101f03:	68 14 b0 10 c0       	push   $0xc010b014
c0101f08:	e8 a5 e3 ff ff       	call   c01002b2 <cprintf>
c0101f0d:	83 c4 10             	add    $0x10,%esp
        print_debuginfo(eip - 1);
c0101f10:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101f13:	83 e8 01             	sub    $0x1,%eax
c0101f16:	83 ec 0c             	sub    $0xc,%esp
c0101f19:	50                   	push   %eax
c0101f1a:	e8 af fe ff ff       	call   c0101dce <print_debuginfo>
c0101f1f:	83 c4 10             	add    $0x10,%esp
        eip = ((uint32_t *)ebp)[1];
c0101f22:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101f25:	83 c0 04             	add    $0x4,%eax
c0101f28:	8b 00                	mov    (%eax),%eax
c0101f2a:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = ((uint32_t *)ebp)[0];
c0101f2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101f30:	8b 00                	mov    (%eax),%eax
c0101f32:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
c0101f35:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0101f39:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101f3d:	74 0a                	je     c0101f49 <print_stackframe+0xc6>
c0101f3f:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0101f43:	0f 8e 63 ff ff ff    	jle    c0101eac <print_stackframe+0x29>
    }
}
c0101f49:	90                   	nop
c0101f4a:	c9                   	leave  
c0101f4b:	c3                   	ret    

c0101f4c <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0101f4c:	f3 0f 1e fb          	endbr32 
c0101f50:	55                   	push   %ebp
c0101f51:	89 e5                	mov    %esp,%ebp
c0101f53:	83 ec 18             	sub    $0x18,%esp
    int argc = 0;
c0101f56:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0101f5d:	eb 0c                	jmp    c0101f6b <parse+0x1f>
            *buf ++ = '\0';
c0101f5f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f62:	8d 50 01             	lea    0x1(%eax),%edx
c0101f65:	89 55 08             	mov    %edx,0x8(%ebp)
c0101f68:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0101f6b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f6e:	0f b6 00             	movzbl (%eax),%eax
c0101f71:	84 c0                	test   %al,%al
c0101f73:	74 1e                	je     c0101f93 <parse+0x47>
c0101f75:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f78:	0f b6 00             	movzbl (%eax),%eax
c0101f7b:	0f be c0             	movsbl %al,%eax
c0101f7e:	83 ec 08             	sub    $0x8,%esp
c0101f81:	50                   	push   %eax
c0101f82:	68 98 b0 10 c0       	push   $0xc010b098
c0101f87:	e8 8d 81 00 00       	call   c010a119 <strchr>
c0101f8c:	83 c4 10             	add    $0x10,%esp
c0101f8f:	85 c0                	test   %eax,%eax
c0101f91:	75 cc                	jne    c0101f5f <parse+0x13>
        }
        if (*buf == '\0') {
c0101f93:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f96:	0f b6 00             	movzbl (%eax),%eax
c0101f99:	84 c0                	test   %al,%al
c0101f9b:	74 65                	je     c0102002 <parse+0xb6>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0101f9d:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0101fa1:	75 12                	jne    c0101fb5 <parse+0x69>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0101fa3:	83 ec 08             	sub    $0x8,%esp
c0101fa6:	6a 10                	push   $0x10
c0101fa8:	68 9d b0 10 c0       	push   $0xc010b09d
c0101fad:	e8 00 e3 ff ff       	call   c01002b2 <cprintf>
c0101fb2:	83 c4 10             	add    $0x10,%esp
        }
        argv[argc ++] = buf;
c0101fb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101fb8:	8d 50 01             	lea    0x1(%eax),%edx
c0101fbb:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0101fbe:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101fc5:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101fc8:	01 c2                	add    %eax,%edx
c0101fca:	8b 45 08             	mov    0x8(%ebp),%eax
c0101fcd:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0101fcf:	eb 04                	jmp    c0101fd5 <parse+0x89>
            buf ++;
c0101fd1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0101fd5:	8b 45 08             	mov    0x8(%ebp),%eax
c0101fd8:	0f b6 00             	movzbl (%eax),%eax
c0101fdb:	84 c0                	test   %al,%al
c0101fdd:	74 8c                	je     c0101f6b <parse+0x1f>
c0101fdf:	8b 45 08             	mov    0x8(%ebp),%eax
c0101fe2:	0f b6 00             	movzbl (%eax),%eax
c0101fe5:	0f be c0             	movsbl %al,%eax
c0101fe8:	83 ec 08             	sub    $0x8,%esp
c0101feb:	50                   	push   %eax
c0101fec:	68 98 b0 10 c0       	push   $0xc010b098
c0101ff1:	e8 23 81 00 00       	call   c010a119 <strchr>
c0101ff6:	83 c4 10             	add    $0x10,%esp
c0101ff9:	85 c0                	test   %eax,%eax
c0101ffb:	74 d4                	je     c0101fd1 <parse+0x85>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0101ffd:	e9 69 ff ff ff       	jmp    c0101f6b <parse+0x1f>
            break;
c0102002:	90                   	nop
        }
    }
    return argc;
c0102003:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0102006:	c9                   	leave  
c0102007:	c3                   	ret    

c0102008 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0102008:	f3 0f 1e fb          	endbr32 
c010200c:	55                   	push   %ebp
c010200d:	89 e5                	mov    %esp,%ebp
c010200f:	83 ec 58             	sub    $0x58,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0102012:	83 ec 08             	sub    $0x8,%esp
c0102015:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0102018:	50                   	push   %eax
c0102019:	ff 75 08             	pushl  0x8(%ebp)
c010201c:	e8 2b ff ff ff       	call   c0101f4c <parse>
c0102021:	83 c4 10             	add    $0x10,%esp
c0102024:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0102027:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010202b:	75 0a                	jne    c0102037 <runcmd+0x2f>
        return 0;
c010202d:	b8 00 00 00 00       	mov    $0x0,%eax
c0102032:	e9 83 00 00 00       	jmp    c01020ba <runcmd+0xb2>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0102037:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010203e:	eb 59                	jmp    c0102099 <runcmd+0x91>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0102040:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0102043:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0102046:	89 d0                	mov    %edx,%eax
c0102048:	01 c0                	add    %eax,%eax
c010204a:	01 d0                	add    %edx,%eax
c010204c:	c1 e0 02             	shl    $0x2,%eax
c010204f:	05 00 b0 12 c0       	add    $0xc012b000,%eax
c0102054:	8b 00                	mov    (%eax),%eax
c0102056:	83 ec 08             	sub    $0x8,%esp
c0102059:	51                   	push   %ecx
c010205a:	50                   	push   %eax
c010205b:	e8 12 80 00 00       	call   c010a072 <strcmp>
c0102060:	83 c4 10             	add    $0x10,%esp
c0102063:	85 c0                	test   %eax,%eax
c0102065:	75 2e                	jne    c0102095 <runcmd+0x8d>
            return commands[i].func(argc - 1, argv + 1, tf);
c0102067:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010206a:	89 d0                	mov    %edx,%eax
c010206c:	01 c0                	add    %eax,%eax
c010206e:	01 d0                	add    %edx,%eax
c0102070:	c1 e0 02             	shl    $0x2,%eax
c0102073:	05 08 b0 12 c0       	add    $0xc012b008,%eax
c0102078:	8b 10                	mov    (%eax),%edx
c010207a:	8d 45 b0             	lea    -0x50(%ebp),%eax
c010207d:	83 c0 04             	add    $0x4,%eax
c0102080:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0102083:	83 e9 01             	sub    $0x1,%ecx
c0102086:	83 ec 04             	sub    $0x4,%esp
c0102089:	ff 75 0c             	pushl  0xc(%ebp)
c010208c:	50                   	push   %eax
c010208d:	51                   	push   %ecx
c010208e:	ff d2                	call   *%edx
c0102090:	83 c4 10             	add    $0x10,%esp
c0102093:	eb 25                	jmp    c01020ba <runcmd+0xb2>
    for (i = 0; i < NCOMMANDS; i ++) {
c0102095:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0102099:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010209c:	83 f8 02             	cmp    $0x2,%eax
c010209f:	76 9f                	jbe    c0102040 <runcmd+0x38>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c01020a1:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01020a4:	83 ec 08             	sub    $0x8,%esp
c01020a7:	50                   	push   %eax
c01020a8:	68 bb b0 10 c0       	push   $0xc010b0bb
c01020ad:	e8 00 e2 ff ff       	call   c01002b2 <cprintf>
c01020b2:	83 c4 10             	add    $0x10,%esp
    return 0;
c01020b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01020ba:	c9                   	leave  
c01020bb:	c3                   	ret    

c01020bc <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c01020bc:	f3 0f 1e fb          	endbr32 
c01020c0:	55                   	push   %ebp
c01020c1:	89 e5                	mov    %esp,%ebp
c01020c3:	83 ec 18             	sub    $0x18,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c01020c6:	83 ec 0c             	sub    $0xc,%esp
c01020c9:	68 d4 b0 10 c0       	push   $0xc010b0d4
c01020ce:	e8 df e1 ff ff       	call   c01002b2 <cprintf>
c01020d3:	83 c4 10             	add    $0x10,%esp
    cprintf("Type 'help' for a list of commands.\n");
c01020d6:	83 ec 0c             	sub    $0xc,%esp
c01020d9:	68 fc b0 10 c0       	push   $0xc010b0fc
c01020de:	e8 cf e1 ff ff       	call   c01002b2 <cprintf>
c01020e3:	83 c4 10             	add    $0x10,%esp

    if (tf != NULL) {
c01020e6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01020ea:	74 0e                	je     c01020fa <kmonitor+0x3e>
        print_trapframe(tf);
c01020ec:	83 ec 0c             	sub    $0xc,%esp
c01020ef:	ff 75 08             	pushl  0x8(%ebp)
c01020f2:	e8 c8 15 00 00       	call   c01036bf <print_trapframe>
c01020f7:	83 c4 10             	add    $0x10,%esp
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c01020fa:	83 ec 0c             	sub    $0xc,%esp
c01020fd:	68 21 b1 10 c0       	push   $0xc010b121
c0102102:	e8 21 f6 ff ff       	call   c0101728 <readline>
c0102107:	83 c4 10             	add    $0x10,%esp
c010210a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010210d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0102111:	74 e7                	je     c01020fa <kmonitor+0x3e>
            if (runcmd(buf, tf) < 0) {
c0102113:	83 ec 08             	sub    $0x8,%esp
c0102116:	ff 75 08             	pushl  0x8(%ebp)
c0102119:	ff 75 f4             	pushl  -0xc(%ebp)
c010211c:	e8 e7 fe ff ff       	call   c0102008 <runcmd>
c0102121:	83 c4 10             	add    $0x10,%esp
c0102124:	85 c0                	test   %eax,%eax
c0102126:	78 02                	js     c010212a <kmonitor+0x6e>
        if ((buf = readline("K> ")) != NULL) {
c0102128:	eb d0                	jmp    c01020fa <kmonitor+0x3e>
                break;
c010212a:	90                   	nop
            }
        }
    }
}
c010212b:	90                   	nop
c010212c:	c9                   	leave  
c010212d:	c3                   	ret    

c010212e <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c010212e:	f3 0f 1e fb          	endbr32 
c0102132:	55                   	push   %ebp
c0102133:	89 e5                	mov    %esp,%ebp
c0102135:	83 ec 18             	sub    $0x18,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0102138:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010213f:	eb 3c                	jmp    c010217d <mon_help+0x4f>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0102141:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0102144:	89 d0                	mov    %edx,%eax
c0102146:	01 c0                	add    %eax,%eax
c0102148:	01 d0                	add    %edx,%eax
c010214a:	c1 e0 02             	shl    $0x2,%eax
c010214d:	05 04 b0 12 c0       	add    $0xc012b004,%eax
c0102152:	8b 08                	mov    (%eax),%ecx
c0102154:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0102157:	89 d0                	mov    %edx,%eax
c0102159:	01 c0                	add    %eax,%eax
c010215b:	01 d0                	add    %edx,%eax
c010215d:	c1 e0 02             	shl    $0x2,%eax
c0102160:	05 00 b0 12 c0       	add    $0xc012b000,%eax
c0102165:	8b 00                	mov    (%eax),%eax
c0102167:	83 ec 04             	sub    $0x4,%esp
c010216a:	51                   	push   %ecx
c010216b:	50                   	push   %eax
c010216c:	68 25 b1 10 c0       	push   $0xc010b125
c0102171:	e8 3c e1 ff ff       	call   c01002b2 <cprintf>
c0102176:	83 c4 10             	add    $0x10,%esp
    for (i = 0; i < NCOMMANDS; i ++) {
c0102179:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010217d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102180:	83 f8 02             	cmp    $0x2,%eax
c0102183:	76 bc                	jbe    c0102141 <mon_help+0x13>
    }
    return 0;
c0102185:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010218a:	c9                   	leave  
c010218b:	c3                   	ret    

c010218c <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c010218c:	f3 0f 1e fb          	endbr32 
c0102190:	55                   	push   %ebp
c0102191:	89 e5                	mov    %esp,%ebp
c0102193:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0102196:	e8 94 fb ff ff       	call   c0101d2f <print_kerninfo>
    return 0;
c010219b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01021a0:	c9                   	leave  
c01021a1:	c3                   	ret    

c01021a2 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c01021a2:	f3 0f 1e fb          	endbr32 
c01021a6:	55                   	push   %ebp
c01021a7:	89 e5                	mov    %esp,%ebp
c01021a9:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c01021ac:	e8 d2 fc ff ff       	call   c0101e83 <print_stackframe>
    return 0;
c01021b1:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01021b6:	c9                   	leave  
c01021b7:	c3                   	ret    

c01021b8 <ide_wait_ready>:
    unsigned int size;          // Size in Sectors
    unsigned char model[41];    // Model in String
} ide_devices[MAX_IDE];

static int
ide_wait_ready(unsigned short iobase, bool check_error) {
c01021b8:	f3 0f 1e fb          	endbr32 
c01021bc:	55                   	push   %ebp
c01021bd:	89 e5                	mov    %esp,%ebp
c01021bf:	83 ec 14             	sub    $0x14,%esp
c01021c2:	8b 45 08             	mov    0x8(%ebp),%eax
c01021c5:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    int r;
    while ((r = inb(iobase + ISA_STATUS)) & IDE_BSY)
c01021c9:	90                   	nop
c01021ca:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01021ce:	83 c0 07             	add    $0x7,%eax
c01021d1:	0f b7 c0             	movzwl %ax,%eax
c01021d4:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01021d8:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01021dc:	89 c2                	mov    %eax,%edx
c01021de:	ec                   	in     (%dx),%al
c01021df:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01021e2:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01021e6:	0f b6 c0             	movzbl %al,%eax
c01021e9:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01021ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021ef:	25 80 00 00 00       	and    $0x80,%eax
c01021f4:	85 c0                	test   %eax,%eax
c01021f6:	75 d2                	jne    c01021ca <ide_wait_ready+0x12>
        /* nothing */;
    if (check_error && (r & (IDE_DF | IDE_ERR)) != 0) {
c01021f8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01021fc:	74 11                	je     c010220f <ide_wait_ready+0x57>
c01021fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102201:	83 e0 21             	and    $0x21,%eax
c0102204:	85 c0                	test   %eax,%eax
c0102206:	74 07                	je     c010220f <ide_wait_ready+0x57>
        return -1;
c0102208:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010220d:	eb 05                	jmp    c0102214 <ide_wait_ready+0x5c>
    }
    return 0;
c010220f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0102214:	c9                   	leave  
c0102215:	c3                   	ret    

c0102216 <ide_init>:

void
ide_init(void) {
c0102216:	f3 0f 1e fb          	endbr32 
c010221a:	55                   	push   %ebp
c010221b:	89 e5                	mov    %esp,%ebp
c010221d:	57                   	push   %edi
c010221e:	53                   	push   %ebx
c010221f:	81 ec 40 02 00 00    	sub    $0x240,%esp
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c0102225:	66 c7 45 f6 00 00    	movw   $0x0,-0xa(%ebp)
c010222b:	e9 6b 02 00 00       	jmp    c010249b <ide_init+0x285>
        /* assume that no device here */
        ide_devices[ideno].valid = 0;
c0102230:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0102234:	6b c0 38             	imul   $0x38,%eax,%eax
c0102237:	05 40 e4 12 c0       	add    $0xc012e440,%eax
c010223c:	c6 00 00             	movb   $0x0,(%eax)

        iobase = IO_BASE(ideno);
c010223f:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0102243:	66 d1 e8             	shr    %ax
c0102246:	0f b7 c0             	movzwl %ax,%eax
c0102249:	0f b7 04 85 30 b1 10 	movzwl -0x3fef4ed0(,%eax,4),%eax
c0102250:	c0 
c0102251:	66 89 45 ea          	mov    %ax,-0x16(%ebp)

        /* wait device ready */
        ide_wait_ready(iobase, 0);
c0102255:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0102259:	6a 00                	push   $0x0
c010225b:	50                   	push   %eax
c010225c:	e8 57 ff ff ff       	call   c01021b8 <ide_wait_ready>
c0102261:	83 c4 08             	add    $0x8,%esp

        /* step1: select drive */
        outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4));
c0102264:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0102268:	c1 e0 04             	shl    $0x4,%eax
c010226b:	83 e0 10             	and    $0x10,%eax
c010226e:	83 c8 e0             	or     $0xffffffe0,%eax
c0102271:	0f b6 c0             	movzbl %al,%eax
c0102274:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0102278:	83 c2 06             	add    $0x6,%edx
c010227b:	0f b7 d2             	movzwl %dx,%edx
c010227e:	66 89 55 ca          	mov    %dx,-0x36(%ebp)
c0102282:	88 45 c9             	mov    %al,-0x37(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102285:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c0102289:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c010228d:	ee                   	out    %al,(%dx)
}
c010228e:	90                   	nop
        ide_wait_ready(iobase, 0);
c010228f:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0102293:	6a 00                	push   $0x0
c0102295:	50                   	push   %eax
c0102296:	e8 1d ff ff ff       	call   c01021b8 <ide_wait_ready>
c010229b:	83 c4 08             	add    $0x8,%esp

        /* step2: send ATA identify command */
        outb(iobase + ISA_COMMAND, IDE_CMD_IDENTIFY);
c010229e:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01022a2:	83 c0 07             	add    $0x7,%eax
c01022a5:	0f b7 c0             	movzwl %ax,%eax
c01022a8:	66 89 45 ce          	mov    %ax,-0x32(%ebp)
c01022ac:	c6 45 cd ec          	movb   $0xec,-0x33(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01022b0:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c01022b4:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c01022b8:	ee                   	out    %al,(%dx)
}
c01022b9:	90                   	nop
        ide_wait_ready(iobase, 0);
c01022ba:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01022be:	6a 00                	push   $0x0
c01022c0:	50                   	push   %eax
c01022c1:	e8 f2 fe ff ff       	call   c01021b8 <ide_wait_ready>
c01022c6:	83 c4 08             	add    $0x8,%esp

        /* step3: polling */
        if (inb(iobase + ISA_STATUS) == 0 || ide_wait_ready(iobase, 1) != 0) {
c01022c9:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01022cd:	83 c0 07             	add    $0x7,%eax
c01022d0:	0f b7 c0             	movzwl %ax,%eax
c01022d3:	66 89 45 d2          	mov    %ax,-0x2e(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01022d7:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
c01022db:	89 c2                	mov    %eax,%edx
c01022dd:	ec                   	in     (%dx),%al
c01022de:	88 45 d1             	mov    %al,-0x2f(%ebp)
    return data;
c01022e1:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c01022e5:	84 c0                	test   %al,%al
c01022e7:	0f 84 a2 01 00 00    	je     c010248f <ide_init+0x279>
c01022ed:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01022f1:	6a 01                	push   $0x1
c01022f3:	50                   	push   %eax
c01022f4:	e8 bf fe ff ff       	call   c01021b8 <ide_wait_ready>
c01022f9:	83 c4 08             	add    $0x8,%esp
c01022fc:	85 c0                	test   %eax,%eax
c01022fe:	0f 85 8b 01 00 00    	jne    c010248f <ide_init+0x279>
            continue ;
        }

        /* device is ok */
        ide_devices[ideno].valid = 1;
c0102304:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0102308:	6b c0 38             	imul   $0x38,%eax,%eax
c010230b:	05 40 e4 12 c0       	add    $0xc012e440,%eax
c0102310:	c6 00 01             	movb   $0x1,(%eax)

        /* read identification space of the device */
        unsigned int buffer[128];
        insl(iobase + ISA_DATA, buffer, sizeof(buffer) / sizeof(unsigned int));
c0102313:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0102317:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c010231a:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c0102320:	89 45 c0             	mov    %eax,-0x40(%ebp)
c0102323:	c7 45 bc 80 00 00 00 	movl   $0x80,-0x44(%ebp)
    asm volatile (
c010232a:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c010232d:	8b 4d c0             	mov    -0x40(%ebp),%ecx
c0102330:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0102333:	89 cb                	mov    %ecx,%ebx
c0102335:	89 df                	mov    %ebx,%edi
c0102337:	89 c1                	mov    %eax,%ecx
c0102339:	fc                   	cld    
c010233a:	f2 6d                	repnz insl (%dx),%es:(%edi)
c010233c:	89 c8                	mov    %ecx,%eax
c010233e:	89 fb                	mov    %edi,%ebx
c0102340:	89 5d c0             	mov    %ebx,-0x40(%ebp)
c0102343:	89 45 bc             	mov    %eax,-0x44(%ebp)
}
c0102346:	90                   	nop

        unsigned char *ident = (unsigned char *)buffer;
c0102347:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c010234d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        unsigned int sectors;
        unsigned int cmdsets = *(unsigned int *)(ident + IDE_IDENT_CMDSETS);
c0102350:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102353:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
c0102359:	89 45 e0             	mov    %eax,-0x20(%ebp)
        /* device use 48-bits or 28-bits addressing */
        if (cmdsets & (1 << 26)) {
c010235c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010235f:	25 00 00 00 04       	and    $0x4000000,%eax
c0102364:	85 c0                	test   %eax,%eax
c0102366:	74 0e                	je     c0102376 <ide_init+0x160>
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA_EXT);
c0102368:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010236b:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
c0102371:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102374:	eb 09                	jmp    c010237f <ide_init+0x169>
        }
        else {
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA);
c0102376:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102379:	8b 40 78             	mov    0x78(%eax),%eax
c010237c:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        ide_devices[ideno].sets = cmdsets;
c010237f:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0102383:	6b c0 38             	imul   $0x38,%eax,%eax
c0102386:	8d 90 44 e4 12 c0    	lea    -0x3fed1bbc(%eax),%edx
c010238c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010238f:	89 02                	mov    %eax,(%edx)
        ide_devices[ideno].size = sectors;
c0102391:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0102395:	6b c0 38             	imul   $0x38,%eax,%eax
c0102398:	8d 90 48 e4 12 c0    	lea    -0x3fed1bb8(%eax),%edx
c010239e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01023a1:	89 02                	mov    %eax,(%edx)

        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);
c01023a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01023a6:	83 c0 62             	add    $0x62,%eax
c01023a9:	0f b7 00             	movzwl (%eax),%eax
c01023ac:	0f b7 c0             	movzwl %ax,%eax
c01023af:	25 00 02 00 00       	and    $0x200,%eax
c01023b4:	85 c0                	test   %eax,%eax
c01023b6:	75 16                	jne    c01023ce <ide_init+0x1b8>
c01023b8:	68 38 b1 10 c0       	push   $0xc010b138
c01023bd:	68 7b b1 10 c0       	push   $0xc010b17b
c01023c2:	6a 7d                	push   $0x7d
c01023c4:	68 90 b1 10 c0       	push   $0xc010b190
c01023c9:	e8 20 f4 ff ff       	call   c01017ee <__panic>

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
c01023ce:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01023d2:	6b c0 38             	imul   $0x38,%eax,%eax
c01023d5:	05 40 e4 12 c0       	add    $0xc012e440,%eax
c01023da:	83 c0 0c             	add    $0xc,%eax
c01023dd:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01023e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01023e3:	83 c0 36             	add    $0x36,%eax
c01023e6:	89 45 d8             	mov    %eax,-0x28(%ebp)
        unsigned int i, length = 40;
c01023e9:	c7 45 d4 28 00 00 00 	movl   $0x28,-0x2c(%ebp)
        for (i = 0; i < length; i += 2) {
c01023f0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01023f7:	eb 34                	jmp    c010242d <ide_init+0x217>
            model[i] = data[i + 1], model[i + 1] = data[i];
c01023f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01023fc:	8d 50 01             	lea    0x1(%eax),%edx
c01023ff:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0102402:	01 d0                	add    %edx,%eax
c0102404:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0102407:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010240a:	01 ca                	add    %ecx,%edx
c010240c:	0f b6 00             	movzbl (%eax),%eax
c010240f:	88 02                	mov    %al,(%edx)
c0102411:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0102414:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102417:	01 d0                	add    %edx,%eax
c0102419:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010241c:	8d 4a 01             	lea    0x1(%edx),%ecx
c010241f:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102422:	01 ca                	add    %ecx,%edx
c0102424:	0f b6 00             	movzbl (%eax),%eax
c0102427:	88 02                	mov    %al,(%edx)
        for (i = 0; i < length; i += 2) {
c0102429:	83 45 ec 02          	addl   $0x2,-0x14(%ebp)
c010242d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102430:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c0102433:	72 c4                	jb     c01023f9 <ide_init+0x1e3>
        }
        do {
            model[i] = '\0';
c0102435:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102438:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010243b:	01 d0                	add    %edx,%eax
c010243d:	c6 00 00             	movb   $0x0,(%eax)
        } while (i -- > 0 && model[i] == ' ');
c0102440:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102443:	8d 50 ff             	lea    -0x1(%eax),%edx
c0102446:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0102449:	85 c0                	test   %eax,%eax
c010244b:	74 0f                	je     c010245c <ide_init+0x246>
c010244d:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102450:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102453:	01 d0                	add    %edx,%eax
c0102455:	0f b6 00             	movzbl (%eax),%eax
c0102458:	3c 20                	cmp    $0x20,%al
c010245a:	74 d9                	je     c0102435 <ide_init+0x21f>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
c010245c:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0102460:	6b c0 38             	imul   $0x38,%eax,%eax
c0102463:	05 40 e4 12 c0       	add    $0xc012e440,%eax
c0102468:	8d 48 0c             	lea    0xc(%eax),%ecx
c010246b:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010246f:	6b c0 38             	imul   $0x38,%eax,%eax
c0102472:	05 48 e4 12 c0       	add    $0xc012e448,%eax
c0102477:	8b 10                	mov    (%eax),%edx
c0102479:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010247d:	51                   	push   %ecx
c010247e:	52                   	push   %edx
c010247f:	50                   	push   %eax
c0102480:	68 a2 b1 10 c0       	push   $0xc010b1a2
c0102485:	e8 28 de ff ff       	call   c01002b2 <cprintf>
c010248a:	83 c4 10             	add    $0x10,%esp
c010248d:	eb 01                	jmp    c0102490 <ide_init+0x27a>
            continue ;
c010248f:	90                   	nop
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c0102490:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0102494:	83 c0 01             	add    $0x1,%eax
c0102497:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
c010249b:	66 83 7d f6 03       	cmpw   $0x3,-0xa(%ebp)
c01024a0:	0f 86 8a fd ff ff    	jbe    c0102230 <ide_init+0x1a>
    }

    // enable ide interrupt
    pic_enable(IRQ_IDE1);
c01024a6:	83 ec 0c             	sub    $0xc,%esp
c01024a9:	6a 0e                	push   $0xe
c01024ab:	e8 f0 0e 00 00       	call   c01033a0 <pic_enable>
c01024b0:	83 c4 10             	add    $0x10,%esp
    pic_enable(IRQ_IDE2);
c01024b3:	83 ec 0c             	sub    $0xc,%esp
c01024b6:	6a 0f                	push   $0xf
c01024b8:	e8 e3 0e 00 00       	call   c01033a0 <pic_enable>
c01024bd:	83 c4 10             	add    $0x10,%esp
}
c01024c0:	90                   	nop
c01024c1:	8d 65 f8             	lea    -0x8(%ebp),%esp
c01024c4:	5b                   	pop    %ebx
c01024c5:	5f                   	pop    %edi
c01024c6:	5d                   	pop    %ebp
c01024c7:	c3                   	ret    

c01024c8 <ide_device_valid>:

bool
ide_device_valid(unsigned short ideno) {
c01024c8:	f3 0f 1e fb          	endbr32 
c01024cc:	55                   	push   %ebp
c01024cd:	89 e5                	mov    %esp,%ebp
c01024cf:	83 ec 04             	sub    $0x4,%esp
c01024d2:	8b 45 08             	mov    0x8(%ebp),%eax
c01024d5:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    return VALID_IDE(ideno);
c01024d9:	66 83 7d fc 03       	cmpw   $0x3,-0x4(%ebp)
c01024de:	77 1a                	ja     c01024fa <ide_device_valid+0x32>
c01024e0:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c01024e4:	6b c0 38             	imul   $0x38,%eax,%eax
c01024e7:	05 40 e4 12 c0       	add    $0xc012e440,%eax
c01024ec:	0f b6 00             	movzbl (%eax),%eax
c01024ef:	84 c0                	test   %al,%al
c01024f1:	74 07                	je     c01024fa <ide_device_valid+0x32>
c01024f3:	b8 01 00 00 00       	mov    $0x1,%eax
c01024f8:	eb 05                	jmp    c01024ff <ide_device_valid+0x37>
c01024fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01024ff:	c9                   	leave  
c0102500:	c3                   	ret    

c0102501 <ide_device_size>:

size_t
ide_device_size(unsigned short ideno) {
c0102501:	f3 0f 1e fb          	endbr32 
c0102505:	55                   	push   %ebp
c0102506:	89 e5                	mov    %esp,%ebp
c0102508:	83 ec 04             	sub    $0x4,%esp
c010250b:	8b 45 08             	mov    0x8(%ebp),%eax
c010250e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    if (ide_device_valid(ideno)) {
c0102512:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0102516:	50                   	push   %eax
c0102517:	e8 ac ff ff ff       	call   c01024c8 <ide_device_valid>
c010251c:	83 c4 04             	add    $0x4,%esp
c010251f:	85 c0                	test   %eax,%eax
c0102521:	74 10                	je     c0102533 <ide_device_size+0x32>
        return ide_devices[ideno].size;
c0102523:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0102527:	6b c0 38             	imul   $0x38,%eax,%eax
c010252a:	05 48 e4 12 c0       	add    $0xc012e448,%eax
c010252f:	8b 00                	mov    (%eax),%eax
c0102531:	eb 05                	jmp    c0102538 <ide_device_size+0x37>
    }
    return 0;
c0102533:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0102538:	c9                   	leave  
c0102539:	c3                   	ret    

c010253a <ide_read_secs>:

int
ide_read_secs(unsigned short ideno, uint32_t secno, void *dst, size_t nsecs) {
c010253a:	f3 0f 1e fb          	endbr32 
c010253e:	55                   	push   %ebp
c010253f:	89 e5                	mov    %esp,%ebp
c0102541:	57                   	push   %edi
c0102542:	53                   	push   %ebx
c0102543:	83 ec 40             	sub    $0x40,%esp
c0102546:	8b 45 08             	mov    0x8(%ebp),%eax
c0102549:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c010254d:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c0102554:	77 1a                	ja     c0102570 <ide_read_secs+0x36>
c0102556:	66 83 7d c4 03       	cmpw   $0x3,-0x3c(%ebp)
c010255b:	77 13                	ja     c0102570 <ide_read_secs+0x36>
c010255d:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0102561:	6b c0 38             	imul   $0x38,%eax,%eax
c0102564:	05 40 e4 12 c0       	add    $0xc012e440,%eax
c0102569:	0f b6 00             	movzbl (%eax),%eax
c010256c:	84 c0                	test   %al,%al
c010256e:	75 19                	jne    c0102589 <ide_read_secs+0x4f>
c0102570:	68 c0 b1 10 c0       	push   $0xc010b1c0
c0102575:	68 7b b1 10 c0       	push   $0xc010b17b
c010257a:	68 9f 00 00 00       	push   $0x9f
c010257f:	68 90 b1 10 c0       	push   $0xc010b190
c0102584:	e8 65 f2 ff ff       	call   c01017ee <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0102589:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0102590:	77 0f                	ja     c01025a1 <ide_read_secs+0x67>
c0102592:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102595:	8b 45 14             	mov    0x14(%ebp),%eax
c0102598:	01 d0                	add    %edx,%eax
c010259a:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c010259f:	76 19                	jbe    c01025ba <ide_read_secs+0x80>
c01025a1:	68 e8 b1 10 c0       	push   $0xc010b1e8
c01025a6:	68 7b b1 10 c0       	push   $0xc010b17b
c01025ab:	68 a0 00 00 00       	push   $0xa0
c01025b0:	68 90 b1 10 c0       	push   $0xc010b190
c01025b5:	e8 34 f2 ff ff       	call   c01017ee <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c01025ba:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c01025be:	66 d1 e8             	shr    %ax
c01025c1:	0f b7 c0             	movzwl %ax,%eax
c01025c4:	0f b7 04 85 30 b1 10 	movzwl -0x3fef4ed0(,%eax,4),%eax
c01025cb:	c0 
c01025cc:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c01025d0:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c01025d4:	66 d1 e8             	shr    %ax
c01025d7:	0f b7 c0             	movzwl %ax,%eax
c01025da:	0f b7 04 85 32 b1 10 	movzwl -0x3fef4ece(,%eax,4),%eax
c01025e1:	c0 
c01025e2:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c01025e6:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01025ea:	83 ec 08             	sub    $0x8,%esp
c01025ed:	6a 00                	push   $0x0
c01025ef:	50                   	push   %eax
c01025f0:	e8 c3 fb ff ff       	call   c01021b8 <ide_wait_ready>
c01025f5:	83 c4 10             	add    $0x10,%esp

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c01025f8:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01025fc:	83 c0 02             	add    $0x2,%eax
c01025ff:	0f b7 c0             	movzwl %ax,%eax
c0102602:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c0102606:	c6 45 d5 00          	movb   $0x0,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010260a:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c010260e:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0102612:	ee                   	out    %al,(%dx)
}
c0102613:	90                   	nop
    outb(iobase + ISA_SECCNT, nsecs);
c0102614:	8b 45 14             	mov    0x14(%ebp),%eax
c0102617:	0f b6 c0             	movzbl %al,%eax
c010261a:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010261e:	83 c2 02             	add    $0x2,%edx
c0102621:	0f b7 d2             	movzwl %dx,%edx
c0102624:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c0102628:	88 45 d9             	mov    %al,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010262b:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c010262f:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0102633:	ee                   	out    %al,(%dx)
}
c0102634:	90                   	nop
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c0102635:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102638:	0f b6 c0             	movzbl %al,%eax
c010263b:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010263f:	83 c2 03             	add    $0x3,%edx
c0102642:	0f b7 d2             	movzwl %dx,%edx
c0102645:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c0102649:	88 45 dd             	mov    %al,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010264c:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0102650:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0102654:	ee                   	out    %al,(%dx)
}
c0102655:	90                   	nop
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c0102656:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102659:	c1 e8 08             	shr    $0x8,%eax
c010265c:	0f b6 c0             	movzbl %al,%eax
c010265f:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0102663:	83 c2 04             	add    $0x4,%edx
c0102666:	0f b7 d2             	movzwl %dx,%edx
c0102669:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c010266d:	88 45 e1             	mov    %al,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102670:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0102674:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0102678:	ee                   	out    %al,(%dx)
}
c0102679:	90                   	nop
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c010267a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010267d:	c1 e8 10             	shr    $0x10,%eax
c0102680:	0f b6 c0             	movzbl %al,%eax
c0102683:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0102687:	83 c2 05             	add    $0x5,%edx
c010268a:	0f b7 d2             	movzwl %dx,%edx
c010268d:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c0102691:	88 45 e5             	mov    %al,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102694:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0102698:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c010269c:	ee                   	out    %al,(%dx)
}
c010269d:	90                   	nop
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c010269e:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c01026a2:	c1 e0 04             	shl    $0x4,%eax
c01026a5:	83 e0 10             	and    $0x10,%eax
c01026a8:	89 c2                	mov    %eax,%edx
c01026aa:	8b 45 0c             	mov    0xc(%ebp),%eax
c01026ad:	c1 e8 18             	shr    $0x18,%eax
c01026b0:	83 e0 0f             	and    $0xf,%eax
c01026b3:	09 d0                	or     %edx,%eax
c01026b5:	83 c8 e0             	or     $0xffffffe0,%eax
c01026b8:	0f b6 c0             	movzbl %al,%eax
c01026bb:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01026bf:	83 c2 06             	add    $0x6,%edx
c01026c2:	0f b7 d2             	movzwl %dx,%edx
c01026c5:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c01026c9:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01026cc:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01026d0:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01026d4:	ee                   	out    %al,(%dx)
}
c01026d5:	90                   	nop
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);
c01026d6:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01026da:	83 c0 07             	add    $0x7,%eax
c01026dd:	0f b7 c0             	movzwl %ax,%eax
c01026e0:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c01026e4:	c6 45 ed 20          	movb   $0x20,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01026e8:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01026ec:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01026f0:	ee                   	out    %al,(%dx)
}
c01026f1:	90                   	nop

    int ret = 0;
c01026f2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c01026f9:	eb 57                	jmp    c0102752 <ide_read_secs+0x218>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c01026fb:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01026ff:	83 ec 08             	sub    $0x8,%esp
c0102702:	6a 01                	push   $0x1
c0102704:	50                   	push   %eax
c0102705:	e8 ae fa ff ff       	call   c01021b8 <ide_wait_ready>
c010270a:	83 c4 10             	add    $0x10,%esp
c010270d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102710:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0102714:	75 44                	jne    c010275a <ide_read_secs+0x220>
            goto out;
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
c0102716:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010271a:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010271d:	8b 45 10             	mov    0x10(%ebp),%eax
c0102720:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0102723:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    asm volatile (
c010272a:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010272d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c0102730:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102733:	89 cb                	mov    %ecx,%ebx
c0102735:	89 df                	mov    %ebx,%edi
c0102737:	89 c1                	mov    %eax,%ecx
c0102739:	fc                   	cld    
c010273a:	f2 6d                	repnz insl (%dx),%es:(%edi)
c010273c:	89 c8                	mov    %ecx,%eax
c010273e:	89 fb                	mov    %edi,%ebx
c0102740:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c0102743:	89 45 c8             	mov    %eax,-0x38(%ebp)
}
c0102746:	90                   	nop
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0102747:	83 6d 14 01          	subl   $0x1,0x14(%ebp)
c010274b:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c0102752:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0102756:	75 a3                	jne    c01026fb <ide_read_secs+0x1c1>
    }

out:
c0102758:	eb 01                	jmp    c010275b <ide_read_secs+0x221>
            goto out;
c010275a:	90                   	nop
    return ret;
c010275b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010275e:	8d 65 f8             	lea    -0x8(%ebp),%esp
c0102761:	5b                   	pop    %ebx
c0102762:	5f                   	pop    %edi
c0102763:	5d                   	pop    %ebp
c0102764:	c3                   	ret    

c0102765 <ide_write_secs>:

int
ide_write_secs(unsigned short ideno, uint32_t secno, const void *src, size_t nsecs) {
c0102765:	f3 0f 1e fb          	endbr32 
c0102769:	55                   	push   %ebp
c010276a:	89 e5                	mov    %esp,%ebp
c010276c:	56                   	push   %esi
c010276d:	53                   	push   %ebx
c010276e:	83 ec 40             	sub    $0x40,%esp
c0102771:	8b 45 08             	mov    0x8(%ebp),%eax
c0102774:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c0102778:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c010277f:	77 1a                	ja     c010279b <ide_write_secs+0x36>
c0102781:	66 83 7d c4 03       	cmpw   $0x3,-0x3c(%ebp)
c0102786:	77 13                	ja     c010279b <ide_write_secs+0x36>
c0102788:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c010278c:	6b c0 38             	imul   $0x38,%eax,%eax
c010278f:	05 40 e4 12 c0       	add    $0xc012e440,%eax
c0102794:	0f b6 00             	movzbl (%eax),%eax
c0102797:	84 c0                	test   %al,%al
c0102799:	75 19                	jne    c01027b4 <ide_write_secs+0x4f>
c010279b:	68 c0 b1 10 c0       	push   $0xc010b1c0
c01027a0:	68 7b b1 10 c0       	push   $0xc010b17b
c01027a5:	68 bc 00 00 00       	push   $0xbc
c01027aa:	68 90 b1 10 c0       	push   $0xc010b190
c01027af:	e8 3a f0 ff ff       	call   c01017ee <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c01027b4:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c01027bb:	77 0f                	ja     c01027cc <ide_write_secs+0x67>
c01027bd:	8b 55 0c             	mov    0xc(%ebp),%edx
c01027c0:	8b 45 14             	mov    0x14(%ebp),%eax
c01027c3:	01 d0                	add    %edx,%eax
c01027c5:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c01027ca:	76 19                	jbe    c01027e5 <ide_write_secs+0x80>
c01027cc:	68 e8 b1 10 c0       	push   $0xc010b1e8
c01027d1:	68 7b b1 10 c0       	push   $0xc010b17b
c01027d6:	68 bd 00 00 00       	push   $0xbd
c01027db:	68 90 b1 10 c0       	push   $0xc010b190
c01027e0:	e8 09 f0 ff ff       	call   c01017ee <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c01027e5:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c01027e9:	66 d1 e8             	shr    %ax
c01027ec:	0f b7 c0             	movzwl %ax,%eax
c01027ef:	0f b7 04 85 30 b1 10 	movzwl -0x3fef4ed0(,%eax,4),%eax
c01027f6:	c0 
c01027f7:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c01027fb:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c01027ff:	66 d1 e8             	shr    %ax
c0102802:	0f b7 c0             	movzwl %ax,%eax
c0102805:	0f b7 04 85 32 b1 10 	movzwl -0x3fef4ece(,%eax,4),%eax
c010280c:	c0 
c010280d:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0102811:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0102815:	83 ec 08             	sub    $0x8,%esp
c0102818:	6a 00                	push   $0x0
c010281a:	50                   	push   %eax
c010281b:	e8 98 f9 ff ff       	call   c01021b8 <ide_wait_ready>
c0102820:	83 c4 10             	add    $0x10,%esp

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c0102823:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0102827:	83 c0 02             	add    $0x2,%eax
c010282a:	0f b7 c0             	movzwl %ax,%eax
c010282d:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c0102831:	c6 45 d5 00          	movb   $0x0,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102835:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0102839:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c010283d:	ee                   	out    %al,(%dx)
}
c010283e:	90                   	nop
    outb(iobase + ISA_SECCNT, nsecs);
c010283f:	8b 45 14             	mov    0x14(%ebp),%eax
c0102842:	0f b6 c0             	movzbl %al,%eax
c0102845:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0102849:	83 c2 02             	add    $0x2,%edx
c010284c:	0f b7 d2             	movzwl %dx,%edx
c010284f:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c0102853:	88 45 d9             	mov    %al,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102856:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c010285a:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c010285e:	ee                   	out    %al,(%dx)
}
c010285f:	90                   	nop
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c0102860:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102863:	0f b6 c0             	movzbl %al,%eax
c0102866:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010286a:	83 c2 03             	add    $0x3,%edx
c010286d:	0f b7 d2             	movzwl %dx,%edx
c0102870:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c0102874:	88 45 dd             	mov    %al,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102877:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c010287b:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c010287f:	ee                   	out    %al,(%dx)
}
c0102880:	90                   	nop
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c0102881:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102884:	c1 e8 08             	shr    $0x8,%eax
c0102887:	0f b6 c0             	movzbl %al,%eax
c010288a:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010288e:	83 c2 04             	add    $0x4,%edx
c0102891:	0f b7 d2             	movzwl %dx,%edx
c0102894:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0102898:	88 45 e1             	mov    %al,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010289b:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c010289f:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c01028a3:	ee                   	out    %al,(%dx)
}
c01028a4:	90                   	nop
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c01028a5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01028a8:	c1 e8 10             	shr    $0x10,%eax
c01028ab:	0f b6 c0             	movzbl %al,%eax
c01028ae:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01028b2:	83 c2 05             	add    $0x5,%edx
c01028b5:	0f b7 d2             	movzwl %dx,%edx
c01028b8:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c01028bc:	88 45 e5             	mov    %al,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01028bf:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01028c3:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01028c7:	ee                   	out    %al,(%dx)
}
c01028c8:	90                   	nop
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c01028c9:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c01028cd:	c1 e0 04             	shl    $0x4,%eax
c01028d0:	83 e0 10             	and    $0x10,%eax
c01028d3:	89 c2                	mov    %eax,%edx
c01028d5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01028d8:	c1 e8 18             	shr    $0x18,%eax
c01028db:	83 e0 0f             	and    $0xf,%eax
c01028de:	09 d0                	or     %edx,%eax
c01028e0:	83 c8 e0             	or     $0xffffffe0,%eax
c01028e3:	0f b6 c0             	movzbl %al,%eax
c01028e6:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01028ea:	83 c2 06             	add    $0x6,%edx
c01028ed:	0f b7 d2             	movzwl %dx,%edx
c01028f0:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c01028f4:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01028f7:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01028fb:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01028ff:	ee                   	out    %al,(%dx)
}
c0102900:	90                   	nop
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);
c0102901:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0102905:	83 c0 07             	add    $0x7,%eax
c0102908:	0f b7 c0             	movzwl %ax,%eax
c010290b:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c010290f:	c6 45 ed 30          	movb   $0x30,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102913:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0102917:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c010291b:	ee                   	out    %al,(%dx)
}
c010291c:	90                   	nop

    int ret = 0;
c010291d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c0102924:	eb 57                	jmp    c010297d <ide_write_secs+0x218>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c0102926:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010292a:	83 ec 08             	sub    $0x8,%esp
c010292d:	6a 01                	push   $0x1
c010292f:	50                   	push   %eax
c0102930:	e8 83 f8 ff ff       	call   c01021b8 <ide_wait_ready>
c0102935:	83 c4 10             	add    $0x10,%esp
c0102938:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010293b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010293f:	75 44                	jne    c0102985 <ide_write_secs+0x220>
            goto out;
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
c0102941:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0102945:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0102948:	8b 45 10             	mov    0x10(%ebp),%eax
c010294b:	89 45 cc             	mov    %eax,-0x34(%ebp)
c010294e:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    asm volatile (
c0102955:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0102958:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c010295b:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010295e:	89 cb                	mov    %ecx,%ebx
c0102960:	89 de                	mov    %ebx,%esi
c0102962:	89 c1                	mov    %eax,%ecx
c0102964:	fc                   	cld    
c0102965:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
c0102967:	89 c8                	mov    %ecx,%eax
c0102969:	89 f3                	mov    %esi,%ebx
c010296b:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c010296e:	89 45 c8             	mov    %eax,-0x38(%ebp)
}
c0102971:	90                   	nop
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c0102972:	83 6d 14 01          	subl   $0x1,0x14(%ebp)
c0102976:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c010297d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0102981:	75 a3                	jne    c0102926 <ide_write_secs+0x1c1>
    }

out:
c0102983:	eb 01                	jmp    c0102986 <ide_write_secs+0x221>
            goto out;
c0102985:	90                   	nop
    return ret;
c0102986:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0102989:	8d 65 f8             	lea    -0x8(%ebp),%esp
c010298c:	5b                   	pop    %ebx
c010298d:	5e                   	pop    %esi
c010298e:	5d                   	pop    %ebp
c010298f:	c3                   	ret    

c0102990 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0102990:	f3 0f 1e fb          	endbr32 
c0102994:	55                   	push   %ebp
c0102995:	89 e5                	mov    %esp,%ebp
c0102997:	83 ec 18             	sub    $0x18,%esp
c010299a:	66 c7 45 ee 43 00    	movw   $0x43,-0x12(%ebp)
c01029a0:	c6 45 ed 34          	movb   $0x34,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01029a4:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01029a8:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01029ac:	ee                   	out    %al,(%dx)
}
c01029ad:	90                   	nop
c01029ae:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c01029b4:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01029b8:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01029bc:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01029c0:	ee                   	out    %al,(%dx)
}
c01029c1:	90                   	nop
c01029c2:	66 c7 45 f6 40 00    	movw   $0x40,-0xa(%ebp)
c01029c8:	c6 45 f5 2e          	movb   $0x2e,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01029cc:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c01029d0:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01029d4:	ee                   	out    %al,(%dx)
}
c01029d5:	90                   	nop
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c01029d6:	c7 05 54 10 13 c0 00 	movl   $0x0,0xc0131054
c01029dd:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c01029e0:	83 ec 0c             	sub    $0xc,%esp
c01029e3:	68 22 b2 10 c0       	push   $0xc010b222
c01029e8:	e8 c5 d8 ff ff       	call   c01002b2 <cprintf>
c01029ed:	83 c4 10             	add    $0x10,%esp
    pic_enable(IRQ_TIMER);
c01029f0:	83 ec 0c             	sub    $0xc,%esp
c01029f3:	6a 00                	push   $0x0
c01029f5:	e8 a6 09 00 00       	call   c01033a0 <pic_enable>
c01029fa:	83 c4 10             	add    $0x10,%esp
}
c01029fd:	90                   	nop
c01029fe:	c9                   	leave  
c01029ff:	c3                   	ret    

c0102a00 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0102a00:	55                   	push   %ebp
c0102a01:	89 e5                	mov    %esp,%ebp
c0102a03:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0102a06:	9c                   	pushf  
c0102a07:	58                   	pop    %eax
c0102a08:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0102a0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0102a0e:	25 00 02 00 00       	and    $0x200,%eax
c0102a13:	85 c0                	test   %eax,%eax
c0102a15:	74 0c                	je     c0102a23 <__intr_save+0x23>
        intr_disable();
c0102a17:	e8 10 0b 00 00       	call   c010352c <intr_disable>
        return 1;
c0102a1c:	b8 01 00 00 00       	mov    $0x1,%eax
c0102a21:	eb 05                	jmp    c0102a28 <__intr_save+0x28>
    }
    return 0;
c0102a23:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0102a28:	c9                   	leave  
c0102a29:	c3                   	ret    

c0102a2a <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0102a2a:	55                   	push   %ebp
c0102a2b:	89 e5                	mov    %esp,%ebp
c0102a2d:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0102a30:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0102a34:	74 05                	je     c0102a3b <__intr_restore+0x11>
        intr_enable();
c0102a36:	e8 e5 0a 00 00       	call   c0103520 <intr_enable>
    }
}
c0102a3b:	90                   	nop
c0102a3c:	c9                   	leave  
c0102a3d:	c3                   	ret    

c0102a3e <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0102a3e:	f3 0f 1e fb          	endbr32 
c0102a42:	55                   	push   %ebp
c0102a43:	89 e5                	mov    %esp,%ebp
c0102a45:	83 ec 10             	sub    $0x10,%esp
c0102a48:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0102a4e:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0102a52:	89 c2                	mov    %eax,%edx
c0102a54:	ec                   	in     (%dx),%al
c0102a55:	88 45 f1             	mov    %al,-0xf(%ebp)
c0102a58:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c0102a5e:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0102a62:	89 c2                	mov    %eax,%edx
c0102a64:	ec                   	in     (%dx),%al
c0102a65:	88 45 f5             	mov    %al,-0xb(%ebp)
c0102a68:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0102a6e:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0102a72:	89 c2                	mov    %eax,%edx
c0102a74:	ec                   	in     (%dx),%al
c0102a75:	88 45 f9             	mov    %al,-0x7(%ebp)
c0102a78:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
c0102a7e:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0102a82:	89 c2                	mov    %eax,%edx
c0102a84:	ec                   	in     (%dx),%al
c0102a85:	88 45 fd             	mov    %al,-0x3(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0102a88:	90                   	nop
c0102a89:	c9                   	leave  
c0102a8a:	c3                   	ret    

c0102a8b <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0102a8b:	f3 0f 1e fb          	endbr32 
c0102a8f:	55                   	push   %ebp
c0102a90:	89 e5                	mov    %esp,%ebp
c0102a92:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0102a95:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0102a9c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102a9f:	0f b7 00             	movzwl (%eax),%eax
c0102aa2:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0102aa6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102aa9:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0102aae:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102ab1:	0f b7 00             	movzwl (%eax),%eax
c0102ab4:	66 3d 5a a5          	cmp    $0xa55a,%ax
c0102ab8:	74 12                	je     c0102acc <cga_init+0x41>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0102aba:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0102ac1:	66 c7 05 26 e5 12 c0 	movw   $0x3b4,0xc012e526
c0102ac8:	b4 03 
c0102aca:	eb 13                	jmp    c0102adf <cga_init+0x54>
    } else {
        *cp = was;
c0102acc:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102acf:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0102ad3:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0102ad6:	66 c7 05 26 e5 12 c0 	movw   $0x3d4,0xc012e526
c0102add:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0102adf:	0f b7 05 26 e5 12 c0 	movzwl 0xc012e526,%eax
c0102ae6:	0f b7 c0             	movzwl %ax,%eax
c0102ae9:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c0102aed:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102af1:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0102af5:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0102af9:	ee                   	out    %al,(%dx)
}
c0102afa:	90                   	nop
    pos = inb(addr_6845 + 1) << 8;
c0102afb:	0f b7 05 26 e5 12 c0 	movzwl 0xc012e526,%eax
c0102b02:	83 c0 01             	add    $0x1,%eax
c0102b05:	0f b7 c0             	movzwl %ax,%eax
c0102b08:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0102b0c:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0102b10:	89 c2                	mov    %eax,%edx
c0102b12:	ec                   	in     (%dx),%al
c0102b13:	88 45 e9             	mov    %al,-0x17(%ebp)
    return data;
c0102b16:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0102b1a:	0f b6 c0             	movzbl %al,%eax
c0102b1d:	c1 e0 08             	shl    $0x8,%eax
c0102b20:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0102b23:	0f b7 05 26 e5 12 c0 	movzwl 0xc012e526,%eax
c0102b2a:	0f b7 c0             	movzwl %ax,%eax
c0102b2d:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0102b31:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102b35:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0102b39:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0102b3d:	ee                   	out    %al,(%dx)
}
c0102b3e:	90                   	nop
    pos |= inb(addr_6845 + 1);
c0102b3f:	0f b7 05 26 e5 12 c0 	movzwl 0xc012e526,%eax
c0102b46:	83 c0 01             	add    $0x1,%eax
c0102b49:	0f b7 c0             	movzwl %ax,%eax
c0102b4c:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0102b50:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0102b54:	89 c2                	mov    %eax,%edx
c0102b56:	ec                   	in     (%dx),%al
c0102b57:	88 45 f1             	mov    %al,-0xf(%ebp)
    return data;
c0102b5a:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0102b5e:	0f b6 c0             	movzbl %al,%eax
c0102b61:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c0102b64:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102b67:	a3 20 e5 12 c0       	mov    %eax,0xc012e520
    crt_pos = pos;
c0102b6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102b6f:	66 a3 24 e5 12 c0    	mov    %ax,0xc012e524
}
c0102b75:	90                   	nop
c0102b76:	c9                   	leave  
c0102b77:	c3                   	ret    

c0102b78 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c0102b78:	f3 0f 1e fb          	endbr32 
c0102b7c:	55                   	push   %ebp
c0102b7d:	89 e5                	mov    %esp,%ebp
c0102b7f:	83 ec 38             	sub    $0x38,%esp
c0102b82:	66 c7 45 d2 fa 03    	movw   $0x3fa,-0x2e(%ebp)
c0102b88:	c6 45 d1 00          	movb   $0x0,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102b8c:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0102b90:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c0102b94:	ee                   	out    %al,(%dx)
}
c0102b95:	90                   	nop
c0102b96:	66 c7 45 d6 fb 03    	movw   $0x3fb,-0x2a(%ebp)
c0102b9c:	c6 45 d5 80          	movb   $0x80,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102ba0:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0102ba4:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0102ba8:	ee                   	out    %al,(%dx)
}
c0102ba9:	90                   	nop
c0102baa:	66 c7 45 da f8 03    	movw   $0x3f8,-0x26(%ebp)
c0102bb0:	c6 45 d9 0c          	movb   $0xc,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102bb4:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0102bb8:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0102bbc:	ee                   	out    %al,(%dx)
}
c0102bbd:	90                   	nop
c0102bbe:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c0102bc4:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102bc8:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0102bcc:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0102bd0:	ee                   	out    %al,(%dx)
}
c0102bd1:	90                   	nop
c0102bd2:	66 c7 45 e2 fb 03    	movw   $0x3fb,-0x1e(%ebp)
c0102bd8:	c6 45 e1 03          	movb   $0x3,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102bdc:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0102be0:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0102be4:	ee                   	out    %al,(%dx)
}
c0102be5:	90                   	nop
c0102be6:	66 c7 45 e6 fc 03    	movw   $0x3fc,-0x1a(%ebp)
c0102bec:	c6 45 e5 00          	movb   $0x0,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102bf0:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0102bf4:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0102bf8:	ee                   	out    %al,(%dx)
}
c0102bf9:	90                   	nop
c0102bfa:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c0102c00:	c6 45 e9 01          	movb   $0x1,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102c04:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0102c08:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0102c0c:	ee                   	out    %al,(%dx)
}
c0102c0d:	90                   	nop
c0102c0e:	66 c7 45 ee fd 03    	movw   $0x3fd,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0102c14:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c0102c18:	89 c2                	mov    %eax,%edx
c0102c1a:	ec                   	in     (%dx),%al
c0102c1b:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c0102c1e:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c0102c22:	3c ff                	cmp    $0xff,%al
c0102c24:	0f 95 c0             	setne  %al
c0102c27:	0f b6 c0             	movzbl %al,%eax
c0102c2a:	a3 28 e5 12 c0       	mov    %eax,0xc012e528
c0102c2f:	66 c7 45 f2 fa 03    	movw   $0x3fa,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0102c35:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0102c39:	89 c2                	mov    %eax,%edx
c0102c3b:	ec                   	in     (%dx),%al
c0102c3c:	88 45 f1             	mov    %al,-0xf(%ebp)
c0102c3f:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c0102c45:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0102c49:	89 c2                	mov    %eax,%edx
c0102c4b:	ec                   	in     (%dx),%al
c0102c4c:	88 45 f5             	mov    %al,-0xb(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c0102c4f:	a1 28 e5 12 c0       	mov    0xc012e528,%eax
c0102c54:	85 c0                	test   %eax,%eax
c0102c56:	74 0d                	je     c0102c65 <serial_init+0xed>
        pic_enable(IRQ_COM1);
c0102c58:	83 ec 0c             	sub    $0xc,%esp
c0102c5b:	6a 04                	push   $0x4
c0102c5d:	e8 3e 07 00 00       	call   c01033a0 <pic_enable>
c0102c62:	83 c4 10             	add    $0x10,%esp
    }
}
c0102c65:	90                   	nop
c0102c66:	c9                   	leave  
c0102c67:	c3                   	ret    

c0102c68 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c0102c68:	f3 0f 1e fb          	endbr32 
c0102c6c:	55                   	push   %ebp
c0102c6d:	89 e5                	mov    %esp,%ebp
c0102c6f:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0102c72:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0102c79:	eb 09                	jmp    c0102c84 <lpt_putc_sub+0x1c>
        delay();
c0102c7b:	e8 be fd ff ff       	call   c0102a3e <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0102c80:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0102c84:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c0102c8a:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0102c8e:	89 c2                	mov    %eax,%edx
c0102c90:	ec                   	in     (%dx),%al
c0102c91:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0102c94:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0102c98:	84 c0                	test   %al,%al
c0102c9a:	78 09                	js     c0102ca5 <lpt_putc_sub+0x3d>
c0102c9c:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0102ca3:	7e d6                	jle    c0102c7b <lpt_putc_sub+0x13>
    }
    outb(LPTPORT + 0, c);
c0102ca5:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ca8:	0f b6 c0             	movzbl %al,%eax
c0102cab:	66 c7 45 ee 78 03    	movw   $0x378,-0x12(%ebp)
c0102cb1:	88 45 ed             	mov    %al,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102cb4:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0102cb8:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0102cbc:	ee                   	out    %al,(%dx)
}
c0102cbd:	90                   	nop
c0102cbe:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c0102cc4:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102cc8:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0102ccc:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0102cd0:	ee                   	out    %al,(%dx)
}
c0102cd1:	90                   	nop
c0102cd2:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
c0102cd8:	c6 45 f5 08          	movb   $0x8,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102cdc:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0102ce0:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0102ce4:	ee                   	out    %al,(%dx)
}
c0102ce5:	90                   	nop
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c0102ce6:	90                   	nop
c0102ce7:	c9                   	leave  
c0102ce8:	c3                   	ret    

c0102ce9 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c0102ce9:	f3 0f 1e fb          	endbr32 
c0102ced:	55                   	push   %ebp
c0102cee:	89 e5                	mov    %esp,%ebp
    if (c != '\b') {
c0102cf0:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0102cf4:	74 0d                	je     c0102d03 <lpt_putc+0x1a>
        lpt_putc_sub(c);
c0102cf6:	ff 75 08             	pushl  0x8(%ebp)
c0102cf9:	e8 6a ff ff ff       	call   c0102c68 <lpt_putc_sub>
c0102cfe:	83 c4 04             	add    $0x4,%esp
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
c0102d01:	eb 1e                	jmp    c0102d21 <lpt_putc+0x38>
        lpt_putc_sub('\b');
c0102d03:	6a 08                	push   $0x8
c0102d05:	e8 5e ff ff ff       	call   c0102c68 <lpt_putc_sub>
c0102d0a:	83 c4 04             	add    $0x4,%esp
        lpt_putc_sub(' ');
c0102d0d:	6a 20                	push   $0x20
c0102d0f:	e8 54 ff ff ff       	call   c0102c68 <lpt_putc_sub>
c0102d14:	83 c4 04             	add    $0x4,%esp
        lpt_putc_sub('\b');
c0102d17:	6a 08                	push   $0x8
c0102d19:	e8 4a ff ff ff       	call   c0102c68 <lpt_putc_sub>
c0102d1e:	83 c4 04             	add    $0x4,%esp
}
c0102d21:	90                   	nop
c0102d22:	c9                   	leave  
c0102d23:	c3                   	ret    

c0102d24 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c0102d24:	f3 0f 1e fb          	endbr32 
c0102d28:	55                   	push   %ebp
c0102d29:	89 e5                	mov    %esp,%ebp
c0102d2b:	53                   	push   %ebx
c0102d2c:	83 ec 24             	sub    $0x24,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c0102d2f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d32:	b0 00                	mov    $0x0,%al
c0102d34:	85 c0                	test   %eax,%eax
c0102d36:	75 07                	jne    c0102d3f <cga_putc+0x1b>
        c |= 0x0700;
c0102d38:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c0102d3f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d42:	0f b6 c0             	movzbl %al,%eax
c0102d45:	83 f8 0d             	cmp    $0xd,%eax
c0102d48:	74 6c                	je     c0102db6 <cga_putc+0x92>
c0102d4a:	83 f8 0d             	cmp    $0xd,%eax
c0102d4d:	0f 8f 9d 00 00 00    	jg     c0102df0 <cga_putc+0xcc>
c0102d53:	83 f8 08             	cmp    $0x8,%eax
c0102d56:	74 0a                	je     c0102d62 <cga_putc+0x3e>
c0102d58:	83 f8 0a             	cmp    $0xa,%eax
c0102d5b:	74 49                	je     c0102da6 <cga_putc+0x82>
c0102d5d:	e9 8e 00 00 00       	jmp    c0102df0 <cga_putc+0xcc>
    case '\b':
        if (crt_pos > 0) {
c0102d62:	0f b7 05 24 e5 12 c0 	movzwl 0xc012e524,%eax
c0102d69:	66 85 c0             	test   %ax,%ax
c0102d6c:	0f 84 a4 00 00 00    	je     c0102e16 <cga_putc+0xf2>
            crt_pos --;
c0102d72:	0f b7 05 24 e5 12 c0 	movzwl 0xc012e524,%eax
c0102d79:	83 e8 01             	sub    $0x1,%eax
c0102d7c:	66 a3 24 e5 12 c0    	mov    %ax,0xc012e524
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c0102d82:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d85:	b0 00                	mov    $0x0,%al
c0102d87:	83 c8 20             	or     $0x20,%eax
c0102d8a:	89 c1                	mov    %eax,%ecx
c0102d8c:	a1 20 e5 12 c0       	mov    0xc012e520,%eax
c0102d91:	0f b7 15 24 e5 12 c0 	movzwl 0xc012e524,%edx
c0102d98:	0f b7 d2             	movzwl %dx,%edx
c0102d9b:	01 d2                	add    %edx,%edx
c0102d9d:	01 d0                	add    %edx,%eax
c0102d9f:	89 ca                	mov    %ecx,%edx
c0102da1:	66 89 10             	mov    %dx,(%eax)
        }
        break;
c0102da4:	eb 70                	jmp    c0102e16 <cga_putc+0xf2>
    case '\n':
        crt_pos += CRT_COLS;
c0102da6:	0f b7 05 24 e5 12 c0 	movzwl 0xc012e524,%eax
c0102dad:	83 c0 50             	add    $0x50,%eax
c0102db0:	66 a3 24 e5 12 c0    	mov    %ax,0xc012e524
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c0102db6:	0f b7 1d 24 e5 12 c0 	movzwl 0xc012e524,%ebx
c0102dbd:	0f b7 0d 24 e5 12 c0 	movzwl 0xc012e524,%ecx
c0102dc4:	0f b7 c1             	movzwl %cx,%eax
c0102dc7:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
c0102dcd:	c1 e8 10             	shr    $0x10,%eax
c0102dd0:	89 c2                	mov    %eax,%edx
c0102dd2:	66 c1 ea 06          	shr    $0x6,%dx
c0102dd6:	89 d0                	mov    %edx,%eax
c0102dd8:	c1 e0 02             	shl    $0x2,%eax
c0102ddb:	01 d0                	add    %edx,%eax
c0102ddd:	c1 e0 04             	shl    $0x4,%eax
c0102de0:	29 c1                	sub    %eax,%ecx
c0102de2:	89 ca                	mov    %ecx,%edx
c0102de4:	89 d8                	mov    %ebx,%eax
c0102de6:	29 d0                	sub    %edx,%eax
c0102de8:	66 a3 24 e5 12 c0    	mov    %ax,0xc012e524
        break;
c0102dee:	eb 27                	jmp    c0102e17 <cga_putc+0xf3>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c0102df0:	8b 0d 20 e5 12 c0    	mov    0xc012e520,%ecx
c0102df6:	0f b7 05 24 e5 12 c0 	movzwl 0xc012e524,%eax
c0102dfd:	8d 50 01             	lea    0x1(%eax),%edx
c0102e00:	66 89 15 24 e5 12 c0 	mov    %dx,0xc012e524
c0102e07:	0f b7 c0             	movzwl %ax,%eax
c0102e0a:	01 c0                	add    %eax,%eax
c0102e0c:	01 c8                	add    %ecx,%eax
c0102e0e:	8b 55 08             	mov    0x8(%ebp),%edx
c0102e11:	66 89 10             	mov    %dx,(%eax)
        break;
c0102e14:	eb 01                	jmp    c0102e17 <cga_putc+0xf3>
        break;
c0102e16:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c0102e17:	0f b7 05 24 e5 12 c0 	movzwl 0xc012e524,%eax
c0102e1e:	66 3d cf 07          	cmp    $0x7cf,%ax
c0102e22:	76 59                	jbe    c0102e7d <cga_putc+0x159>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c0102e24:	a1 20 e5 12 c0       	mov    0xc012e520,%eax
c0102e29:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c0102e2f:	a1 20 e5 12 c0       	mov    0xc012e520,%eax
c0102e34:	83 ec 04             	sub    $0x4,%esp
c0102e37:	68 00 0f 00 00       	push   $0xf00
c0102e3c:	52                   	push   %edx
c0102e3d:	50                   	push   %eax
c0102e3e:	e8 e4 74 00 00       	call   c010a327 <memmove>
c0102e43:	83 c4 10             	add    $0x10,%esp
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0102e46:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c0102e4d:	eb 15                	jmp    c0102e64 <cga_putc+0x140>
            crt_buf[i] = 0x0700 | ' ';
c0102e4f:	a1 20 e5 12 c0       	mov    0xc012e520,%eax
c0102e54:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0102e57:	01 d2                	add    %edx,%edx
c0102e59:	01 d0                	add    %edx,%eax
c0102e5b:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0102e60:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0102e64:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c0102e6b:	7e e2                	jle    c0102e4f <cga_putc+0x12b>
        }
        crt_pos -= CRT_COLS;
c0102e6d:	0f b7 05 24 e5 12 c0 	movzwl 0xc012e524,%eax
c0102e74:	83 e8 50             	sub    $0x50,%eax
c0102e77:	66 a3 24 e5 12 c0    	mov    %ax,0xc012e524
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c0102e7d:	0f b7 05 26 e5 12 c0 	movzwl 0xc012e526,%eax
c0102e84:	0f b7 c0             	movzwl %ax,%eax
c0102e87:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c0102e8b:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102e8f:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0102e93:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0102e97:	ee                   	out    %al,(%dx)
}
c0102e98:	90                   	nop
    outb(addr_6845 + 1, crt_pos >> 8);
c0102e99:	0f b7 05 24 e5 12 c0 	movzwl 0xc012e524,%eax
c0102ea0:	66 c1 e8 08          	shr    $0x8,%ax
c0102ea4:	0f b6 c0             	movzbl %al,%eax
c0102ea7:	0f b7 15 26 e5 12 c0 	movzwl 0xc012e526,%edx
c0102eae:	83 c2 01             	add    $0x1,%edx
c0102eb1:	0f b7 d2             	movzwl %dx,%edx
c0102eb4:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0102eb8:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102ebb:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0102ebf:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0102ec3:	ee                   	out    %al,(%dx)
}
c0102ec4:	90                   	nop
    outb(addr_6845, 15);
c0102ec5:	0f b7 05 26 e5 12 c0 	movzwl 0xc012e526,%eax
c0102ecc:	0f b7 c0             	movzwl %ax,%eax
c0102ecf:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0102ed3:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102ed7:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0102edb:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0102edf:	ee                   	out    %al,(%dx)
}
c0102ee0:	90                   	nop
    outb(addr_6845 + 1, crt_pos);
c0102ee1:	0f b7 05 24 e5 12 c0 	movzwl 0xc012e524,%eax
c0102ee8:	0f b6 c0             	movzbl %al,%eax
c0102eeb:	0f b7 15 26 e5 12 c0 	movzwl 0xc012e526,%edx
c0102ef2:	83 c2 01             	add    $0x1,%edx
c0102ef5:	0f b7 d2             	movzwl %dx,%edx
c0102ef8:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
c0102efc:	88 45 f1             	mov    %al,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102eff:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0102f03:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0102f07:	ee                   	out    %al,(%dx)
}
c0102f08:	90                   	nop
}
c0102f09:	90                   	nop
c0102f0a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0102f0d:	c9                   	leave  
c0102f0e:	c3                   	ret    

c0102f0f <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c0102f0f:	f3 0f 1e fb          	endbr32 
c0102f13:	55                   	push   %ebp
c0102f14:	89 e5                	mov    %esp,%ebp
c0102f16:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0102f19:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0102f20:	eb 09                	jmp    c0102f2b <serial_putc_sub+0x1c>
        delay();
c0102f22:	e8 17 fb ff ff       	call   c0102a3e <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0102f27:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0102f2b:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0102f31:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0102f35:	89 c2                	mov    %eax,%edx
c0102f37:	ec                   	in     (%dx),%al
c0102f38:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0102f3b:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0102f3f:	0f b6 c0             	movzbl %al,%eax
c0102f42:	83 e0 20             	and    $0x20,%eax
c0102f45:	85 c0                	test   %eax,%eax
c0102f47:	75 09                	jne    c0102f52 <serial_putc_sub+0x43>
c0102f49:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0102f50:	7e d0                	jle    c0102f22 <serial_putc_sub+0x13>
    }
    outb(COM1 + COM_TX, c);
c0102f52:	8b 45 08             	mov    0x8(%ebp),%eax
c0102f55:	0f b6 c0             	movzbl %al,%eax
c0102f58:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c0102f5e:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102f61:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0102f65:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0102f69:	ee                   	out    %al,(%dx)
}
c0102f6a:	90                   	nop
}
c0102f6b:	90                   	nop
c0102f6c:	c9                   	leave  
c0102f6d:	c3                   	ret    

c0102f6e <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c0102f6e:	f3 0f 1e fb          	endbr32 
c0102f72:	55                   	push   %ebp
c0102f73:	89 e5                	mov    %esp,%ebp
    if (c != '\b') {
c0102f75:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0102f79:	74 0d                	je     c0102f88 <serial_putc+0x1a>
        serial_putc_sub(c);
c0102f7b:	ff 75 08             	pushl  0x8(%ebp)
c0102f7e:	e8 8c ff ff ff       	call   c0102f0f <serial_putc_sub>
c0102f83:	83 c4 04             	add    $0x4,%esp
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
c0102f86:	eb 1e                	jmp    c0102fa6 <serial_putc+0x38>
        serial_putc_sub('\b');
c0102f88:	6a 08                	push   $0x8
c0102f8a:	e8 80 ff ff ff       	call   c0102f0f <serial_putc_sub>
c0102f8f:	83 c4 04             	add    $0x4,%esp
        serial_putc_sub(' ');
c0102f92:	6a 20                	push   $0x20
c0102f94:	e8 76 ff ff ff       	call   c0102f0f <serial_putc_sub>
c0102f99:	83 c4 04             	add    $0x4,%esp
        serial_putc_sub('\b');
c0102f9c:	6a 08                	push   $0x8
c0102f9e:	e8 6c ff ff ff       	call   c0102f0f <serial_putc_sub>
c0102fa3:	83 c4 04             	add    $0x4,%esp
}
c0102fa6:	90                   	nop
c0102fa7:	c9                   	leave  
c0102fa8:	c3                   	ret    

c0102fa9 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c0102fa9:	f3 0f 1e fb          	endbr32 
c0102fad:	55                   	push   %ebp
c0102fae:	89 e5                	mov    %esp,%ebp
c0102fb0:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c0102fb3:	eb 33                	jmp    c0102fe8 <cons_intr+0x3f>
        if (c != 0) {
c0102fb5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0102fb9:	74 2d                	je     c0102fe8 <cons_intr+0x3f>
            cons.buf[cons.wpos ++] = c;
c0102fbb:	a1 44 e7 12 c0       	mov    0xc012e744,%eax
c0102fc0:	8d 50 01             	lea    0x1(%eax),%edx
c0102fc3:	89 15 44 e7 12 c0    	mov    %edx,0xc012e744
c0102fc9:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0102fcc:	88 90 40 e5 12 c0    	mov    %dl,-0x3fed1ac0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c0102fd2:	a1 44 e7 12 c0       	mov    0xc012e744,%eax
c0102fd7:	3d 00 02 00 00       	cmp    $0x200,%eax
c0102fdc:	75 0a                	jne    c0102fe8 <cons_intr+0x3f>
                cons.wpos = 0;
c0102fde:	c7 05 44 e7 12 c0 00 	movl   $0x0,0xc012e744
c0102fe5:	00 00 00 
    while ((c = (*proc)()) != -1) {
c0102fe8:	8b 45 08             	mov    0x8(%ebp),%eax
c0102feb:	ff d0                	call   *%eax
c0102fed:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102ff0:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c0102ff4:	75 bf                	jne    c0102fb5 <cons_intr+0xc>
            }
        }
    }
}
c0102ff6:	90                   	nop
c0102ff7:	90                   	nop
c0102ff8:	c9                   	leave  
c0102ff9:	c3                   	ret    

c0102ffa <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c0102ffa:	f3 0f 1e fb          	endbr32 
c0102ffe:	55                   	push   %ebp
c0102fff:	89 e5                	mov    %esp,%ebp
c0103001:	83 ec 10             	sub    $0x10,%esp
c0103004:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010300a:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c010300e:	89 c2                	mov    %eax,%edx
c0103010:	ec                   	in     (%dx),%al
c0103011:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0103014:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c0103018:	0f b6 c0             	movzbl %al,%eax
c010301b:	83 e0 01             	and    $0x1,%eax
c010301e:	85 c0                	test   %eax,%eax
c0103020:	75 07                	jne    c0103029 <serial_proc_data+0x2f>
        return -1;
c0103022:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0103027:	eb 2a                	jmp    c0103053 <serial_proc_data+0x59>
c0103029:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010302f:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0103033:	89 c2                	mov    %eax,%edx
c0103035:	ec                   	in     (%dx),%al
c0103036:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c0103039:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c010303d:	0f b6 c0             	movzbl %al,%eax
c0103040:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c0103043:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c0103047:	75 07                	jne    c0103050 <serial_proc_data+0x56>
        c = '\b';
c0103049:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c0103050:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0103053:	c9                   	leave  
c0103054:	c3                   	ret    

c0103055 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c0103055:	f3 0f 1e fb          	endbr32 
c0103059:	55                   	push   %ebp
c010305a:	89 e5                	mov    %esp,%ebp
c010305c:	83 ec 08             	sub    $0x8,%esp
    if (serial_exists) {
c010305f:	a1 28 e5 12 c0       	mov    0xc012e528,%eax
c0103064:	85 c0                	test   %eax,%eax
c0103066:	74 10                	je     c0103078 <serial_intr+0x23>
        cons_intr(serial_proc_data);
c0103068:	83 ec 0c             	sub    $0xc,%esp
c010306b:	68 fa 2f 10 c0       	push   $0xc0102ffa
c0103070:	e8 34 ff ff ff       	call   c0102fa9 <cons_intr>
c0103075:	83 c4 10             	add    $0x10,%esp
    }
}
c0103078:	90                   	nop
c0103079:	c9                   	leave  
c010307a:	c3                   	ret    

c010307b <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c010307b:	f3 0f 1e fb          	endbr32 
c010307f:	55                   	push   %ebp
c0103080:	89 e5                	mov    %esp,%ebp
c0103082:	83 ec 28             	sub    $0x28,%esp
c0103085:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010308b:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c010308f:	89 c2                	mov    %eax,%edx
c0103091:	ec                   	in     (%dx),%al
c0103092:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c0103095:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c0103099:	0f b6 c0             	movzbl %al,%eax
c010309c:	83 e0 01             	and    $0x1,%eax
c010309f:	85 c0                	test   %eax,%eax
c01030a1:	75 0a                	jne    c01030ad <kbd_proc_data+0x32>
        return -1;
c01030a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01030a8:	e9 5e 01 00 00       	jmp    c010320b <kbd_proc_data+0x190>
c01030ad:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01030b3:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01030b7:	89 c2                	mov    %eax,%edx
c01030b9:	ec                   	in     (%dx),%al
c01030ba:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c01030bd:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c01030c1:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c01030c4:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c01030c8:	75 17                	jne    c01030e1 <kbd_proc_data+0x66>
        // E0 escape character
        shift |= E0ESC;
c01030ca:	a1 48 e7 12 c0       	mov    0xc012e748,%eax
c01030cf:	83 c8 40             	or     $0x40,%eax
c01030d2:	a3 48 e7 12 c0       	mov    %eax,0xc012e748
        return 0;
c01030d7:	b8 00 00 00 00       	mov    $0x0,%eax
c01030dc:	e9 2a 01 00 00       	jmp    c010320b <kbd_proc_data+0x190>
    } else if (data & 0x80) {
c01030e1:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01030e5:	84 c0                	test   %al,%al
c01030e7:	79 47                	jns    c0103130 <kbd_proc_data+0xb5>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c01030e9:	a1 48 e7 12 c0       	mov    0xc012e748,%eax
c01030ee:	83 e0 40             	and    $0x40,%eax
c01030f1:	85 c0                	test   %eax,%eax
c01030f3:	75 09                	jne    c01030fe <kbd_proc_data+0x83>
c01030f5:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01030f9:	83 e0 7f             	and    $0x7f,%eax
c01030fc:	eb 04                	jmp    c0103102 <kbd_proc_data+0x87>
c01030fe:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0103102:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c0103105:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0103109:	0f b6 80 40 b0 12 c0 	movzbl -0x3fed4fc0(%eax),%eax
c0103110:	83 c8 40             	or     $0x40,%eax
c0103113:	0f b6 c0             	movzbl %al,%eax
c0103116:	f7 d0                	not    %eax
c0103118:	89 c2                	mov    %eax,%edx
c010311a:	a1 48 e7 12 c0       	mov    0xc012e748,%eax
c010311f:	21 d0                	and    %edx,%eax
c0103121:	a3 48 e7 12 c0       	mov    %eax,0xc012e748
        return 0;
c0103126:	b8 00 00 00 00       	mov    $0x0,%eax
c010312b:	e9 db 00 00 00       	jmp    c010320b <kbd_proc_data+0x190>
    } else if (shift & E0ESC) {
c0103130:	a1 48 e7 12 c0       	mov    0xc012e748,%eax
c0103135:	83 e0 40             	and    $0x40,%eax
c0103138:	85 c0                	test   %eax,%eax
c010313a:	74 11                	je     c010314d <kbd_proc_data+0xd2>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c010313c:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c0103140:	a1 48 e7 12 c0       	mov    0xc012e748,%eax
c0103145:	83 e0 bf             	and    $0xffffffbf,%eax
c0103148:	a3 48 e7 12 c0       	mov    %eax,0xc012e748
    }

    shift |= shiftcode[data];
c010314d:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0103151:	0f b6 80 40 b0 12 c0 	movzbl -0x3fed4fc0(%eax),%eax
c0103158:	0f b6 d0             	movzbl %al,%edx
c010315b:	a1 48 e7 12 c0       	mov    0xc012e748,%eax
c0103160:	09 d0                	or     %edx,%eax
c0103162:	a3 48 e7 12 c0       	mov    %eax,0xc012e748
    shift ^= togglecode[data];
c0103167:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010316b:	0f b6 80 40 b1 12 c0 	movzbl -0x3fed4ec0(%eax),%eax
c0103172:	0f b6 d0             	movzbl %al,%edx
c0103175:	a1 48 e7 12 c0       	mov    0xc012e748,%eax
c010317a:	31 d0                	xor    %edx,%eax
c010317c:	a3 48 e7 12 c0       	mov    %eax,0xc012e748

    c = charcode[shift & (CTL | SHIFT)][data];
c0103181:	a1 48 e7 12 c0       	mov    0xc012e748,%eax
c0103186:	83 e0 03             	and    $0x3,%eax
c0103189:	8b 14 85 40 b5 12 c0 	mov    -0x3fed4ac0(,%eax,4),%edx
c0103190:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0103194:	01 d0                	add    %edx,%eax
c0103196:	0f b6 00             	movzbl (%eax),%eax
c0103199:	0f b6 c0             	movzbl %al,%eax
c010319c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c010319f:	a1 48 e7 12 c0       	mov    0xc012e748,%eax
c01031a4:	83 e0 08             	and    $0x8,%eax
c01031a7:	85 c0                	test   %eax,%eax
c01031a9:	74 22                	je     c01031cd <kbd_proc_data+0x152>
        if ('a' <= c && c <= 'z')
c01031ab:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c01031af:	7e 0c                	jle    c01031bd <kbd_proc_data+0x142>
c01031b1:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c01031b5:	7f 06                	jg     c01031bd <kbd_proc_data+0x142>
            c += 'A' - 'a';
c01031b7:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c01031bb:	eb 10                	jmp    c01031cd <kbd_proc_data+0x152>
        else if ('A' <= c && c <= 'Z')
c01031bd:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c01031c1:	7e 0a                	jle    c01031cd <kbd_proc_data+0x152>
c01031c3:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c01031c7:	7f 04                	jg     c01031cd <kbd_proc_data+0x152>
            c += 'a' - 'A';
c01031c9:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c01031cd:	a1 48 e7 12 c0       	mov    0xc012e748,%eax
c01031d2:	f7 d0                	not    %eax
c01031d4:	83 e0 06             	and    $0x6,%eax
c01031d7:	85 c0                	test   %eax,%eax
c01031d9:	75 2d                	jne    c0103208 <kbd_proc_data+0x18d>
c01031db:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c01031e2:	75 24                	jne    c0103208 <kbd_proc_data+0x18d>
        cprintf("Rebooting!\n");
c01031e4:	83 ec 0c             	sub    $0xc,%esp
c01031e7:	68 3d b2 10 c0       	push   $0xc010b23d
c01031ec:	e8 c1 d0 ff ff       	call   c01002b2 <cprintf>
c01031f1:	83 c4 10             	add    $0x10,%esp
c01031f4:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c01031fa:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01031fe:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c0103202:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
c0103206:	ee                   	out    %al,(%dx)
}
c0103207:	90                   	nop
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c0103208:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010320b:	c9                   	leave  
c010320c:	c3                   	ret    

c010320d <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c010320d:	f3 0f 1e fb          	endbr32 
c0103211:	55                   	push   %ebp
c0103212:	89 e5                	mov    %esp,%ebp
c0103214:	83 ec 08             	sub    $0x8,%esp
    cons_intr(kbd_proc_data);
c0103217:	83 ec 0c             	sub    $0xc,%esp
c010321a:	68 7b 30 10 c0       	push   $0xc010307b
c010321f:	e8 85 fd ff ff       	call   c0102fa9 <cons_intr>
c0103224:	83 c4 10             	add    $0x10,%esp
}
c0103227:	90                   	nop
c0103228:	c9                   	leave  
c0103229:	c3                   	ret    

c010322a <kbd_init>:

static void
kbd_init(void) {
c010322a:	f3 0f 1e fb          	endbr32 
c010322e:	55                   	push   %ebp
c010322f:	89 e5                	mov    %esp,%ebp
c0103231:	83 ec 08             	sub    $0x8,%esp
    // drain the kbd buffer
    kbd_intr();
c0103234:	e8 d4 ff ff ff       	call   c010320d <kbd_intr>
    pic_enable(IRQ_KBD);
c0103239:	83 ec 0c             	sub    $0xc,%esp
c010323c:	6a 01                	push   $0x1
c010323e:	e8 5d 01 00 00       	call   c01033a0 <pic_enable>
c0103243:	83 c4 10             	add    $0x10,%esp
}
c0103246:	90                   	nop
c0103247:	c9                   	leave  
c0103248:	c3                   	ret    

c0103249 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c0103249:	f3 0f 1e fb          	endbr32 
c010324d:	55                   	push   %ebp
c010324e:	89 e5                	mov    %esp,%ebp
c0103250:	83 ec 08             	sub    $0x8,%esp
    cga_init();
c0103253:	e8 33 f8 ff ff       	call   c0102a8b <cga_init>
    serial_init();
c0103258:	e8 1b f9 ff ff       	call   c0102b78 <serial_init>
    kbd_init();
c010325d:	e8 c8 ff ff ff       	call   c010322a <kbd_init>
    if (!serial_exists) {
c0103262:	a1 28 e5 12 c0       	mov    0xc012e528,%eax
c0103267:	85 c0                	test   %eax,%eax
c0103269:	75 10                	jne    c010327b <cons_init+0x32>
        cprintf("serial port does not exist!!\n");
c010326b:	83 ec 0c             	sub    $0xc,%esp
c010326e:	68 49 b2 10 c0       	push   $0xc010b249
c0103273:	e8 3a d0 ff ff       	call   c01002b2 <cprintf>
c0103278:	83 c4 10             	add    $0x10,%esp
    }
}
c010327b:	90                   	nop
c010327c:	c9                   	leave  
c010327d:	c3                   	ret    

c010327e <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c010327e:	f3 0f 1e fb          	endbr32 
c0103282:	55                   	push   %ebp
c0103283:	89 e5                	mov    %esp,%ebp
c0103285:	83 ec 18             	sub    $0x18,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0103288:	e8 73 f7 ff ff       	call   c0102a00 <__intr_save>
c010328d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c0103290:	83 ec 0c             	sub    $0xc,%esp
c0103293:	ff 75 08             	pushl  0x8(%ebp)
c0103296:	e8 4e fa ff ff       	call   c0102ce9 <lpt_putc>
c010329b:	83 c4 10             	add    $0x10,%esp
        cga_putc(c);
c010329e:	83 ec 0c             	sub    $0xc,%esp
c01032a1:	ff 75 08             	pushl  0x8(%ebp)
c01032a4:	e8 7b fa ff ff       	call   c0102d24 <cga_putc>
c01032a9:	83 c4 10             	add    $0x10,%esp
        serial_putc(c);
c01032ac:	83 ec 0c             	sub    $0xc,%esp
c01032af:	ff 75 08             	pushl  0x8(%ebp)
c01032b2:	e8 b7 fc ff ff       	call   c0102f6e <serial_putc>
c01032b7:	83 c4 10             	add    $0x10,%esp
    }
    local_intr_restore(intr_flag);
c01032ba:	83 ec 0c             	sub    $0xc,%esp
c01032bd:	ff 75 f4             	pushl  -0xc(%ebp)
c01032c0:	e8 65 f7 ff ff       	call   c0102a2a <__intr_restore>
c01032c5:	83 c4 10             	add    $0x10,%esp
}
c01032c8:	90                   	nop
c01032c9:	c9                   	leave  
c01032ca:	c3                   	ret    

c01032cb <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c01032cb:	f3 0f 1e fb          	endbr32 
c01032cf:	55                   	push   %ebp
c01032d0:	89 e5                	mov    %esp,%ebp
c01032d2:	83 ec 18             	sub    $0x18,%esp
    int c = 0;
c01032d5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c01032dc:	e8 1f f7 ff ff       	call   c0102a00 <__intr_save>
c01032e1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c01032e4:	e8 6c fd ff ff       	call   c0103055 <serial_intr>
        kbd_intr();
c01032e9:	e8 1f ff ff ff       	call   c010320d <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c01032ee:	8b 15 40 e7 12 c0    	mov    0xc012e740,%edx
c01032f4:	a1 44 e7 12 c0       	mov    0xc012e744,%eax
c01032f9:	39 c2                	cmp    %eax,%edx
c01032fb:	74 31                	je     c010332e <cons_getc+0x63>
            c = cons.buf[cons.rpos ++];
c01032fd:	a1 40 e7 12 c0       	mov    0xc012e740,%eax
c0103302:	8d 50 01             	lea    0x1(%eax),%edx
c0103305:	89 15 40 e7 12 c0    	mov    %edx,0xc012e740
c010330b:	0f b6 80 40 e5 12 c0 	movzbl -0x3fed1ac0(%eax),%eax
c0103312:	0f b6 c0             	movzbl %al,%eax
c0103315:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c0103318:	a1 40 e7 12 c0       	mov    0xc012e740,%eax
c010331d:	3d 00 02 00 00       	cmp    $0x200,%eax
c0103322:	75 0a                	jne    c010332e <cons_getc+0x63>
                cons.rpos = 0;
c0103324:	c7 05 40 e7 12 c0 00 	movl   $0x0,0xc012e740
c010332b:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c010332e:	83 ec 0c             	sub    $0xc,%esp
c0103331:	ff 75 f0             	pushl  -0x10(%ebp)
c0103334:	e8 f1 f6 ff ff       	call   c0102a2a <__intr_restore>
c0103339:	83 c4 10             	add    $0x10,%esp
    return c;
c010333c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010333f:	c9                   	leave  
c0103340:	c3                   	ret    

c0103341 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c0103341:	f3 0f 1e fb          	endbr32 
c0103345:	55                   	push   %ebp
c0103346:	89 e5                	mov    %esp,%ebp
c0103348:	83 ec 14             	sub    $0x14,%esp
c010334b:	8b 45 08             	mov    0x8(%ebp),%eax
c010334e:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c0103352:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0103356:	66 a3 50 b5 12 c0    	mov    %ax,0xc012b550
    if (did_init) {
c010335c:	a1 4c e7 12 c0       	mov    0xc012e74c,%eax
c0103361:	85 c0                	test   %eax,%eax
c0103363:	74 38                	je     c010339d <pic_setmask+0x5c>
        outb(IO_PIC1 + 1, mask);
c0103365:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0103369:	0f b6 c0             	movzbl %al,%eax
c010336c:	66 c7 45 fa 21 00    	movw   $0x21,-0x6(%ebp)
c0103372:	88 45 f9             	mov    %al,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0103375:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0103379:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c010337d:	ee                   	out    %al,(%dx)
}
c010337e:	90                   	nop
        outb(IO_PIC2 + 1, mask >> 8);
c010337f:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0103383:	66 c1 e8 08          	shr    $0x8,%ax
c0103387:	0f b6 c0             	movzbl %al,%eax
c010338a:	66 c7 45 fe a1 00    	movw   $0xa1,-0x2(%ebp)
c0103390:	88 45 fd             	mov    %al,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0103393:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0103397:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c010339b:	ee                   	out    %al,(%dx)
}
c010339c:	90                   	nop
    }
}
c010339d:	90                   	nop
c010339e:	c9                   	leave  
c010339f:	c3                   	ret    

c01033a0 <pic_enable>:

void
pic_enable(unsigned int irq) {
c01033a0:	f3 0f 1e fb          	endbr32 
c01033a4:	55                   	push   %ebp
c01033a5:	89 e5                	mov    %esp,%ebp
    pic_setmask(irq_mask & ~(1 << irq));
c01033a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01033aa:	ba 01 00 00 00       	mov    $0x1,%edx
c01033af:	89 c1                	mov    %eax,%ecx
c01033b1:	d3 e2                	shl    %cl,%edx
c01033b3:	89 d0                	mov    %edx,%eax
c01033b5:	f7 d0                	not    %eax
c01033b7:	89 c2                	mov    %eax,%edx
c01033b9:	0f b7 05 50 b5 12 c0 	movzwl 0xc012b550,%eax
c01033c0:	21 d0                	and    %edx,%eax
c01033c2:	0f b7 c0             	movzwl %ax,%eax
c01033c5:	50                   	push   %eax
c01033c6:	e8 76 ff ff ff       	call   c0103341 <pic_setmask>
c01033cb:	83 c4 04             	add    $0x4,%esp
}
c01033ce:	90                   	nop
c01033cf:	c9                   	leave  
c01033d0:	c3                   	ret    

c01033d1 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c01033d1:	f3 0f 1e fb          	endbr32 
c01033d5:	55                   	push   %ebp
c01033d6:	89 e5                	mov    %esp,%ebp
c01033d8:	83 ec 40             	sub    $0x40,%esp
    did_init = 1;
c01033db:	c7 05 4c e7 12 c0 01 	movl   $0x1,0xc012e74c
c01033e2:	00 00 00 
c01033e5:	66 c7 45 ca 21 00    	movw   $0x21,-0x36(%ebp)
c01033eb:	c6 45 c9 ff          	movb   $0xff,-0x37(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01033ef:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c01033f3:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c01033f7:	ee                   	out    %al,(%dx)
}
c01033f8:	90                   	nop
c01033f9:	66 c7 45 ce a1 00    	movw   $0xa1,-0x32(%ebp)
c01033ff:	c6 45 cd ff          	movb   $0xff,-0x33(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0103403:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c0103407:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c010340b:	ee                   	out    %al,(%dx)
}
c010340c:	90                   	nop
c010340d:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c0103413:	c6 45 d1 11          	movb   $0x11,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0103417:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c010341b:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c010341f:	ee                   	out    %al,(%dx)
}
c0103420:	90                   	nop
c0103421:	66 c7 45 d6 21 00    	movw   $0x21,-0x2a(%ebp)
c0103427:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010342b:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c010342f:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0103433:	ee                   	out    %al,(%dx)
}
c0103434:	90                   	nop
c0103435:	66 c7 45 da 21 00    	movw   $0x21,-0x26(%ebp)
c010343b:	c6 45 d9 04          	movb   $0x4,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010343f:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0103443:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0103447:	ee                   	out    %al,(%dx)
}
c0103448:	90                   	nop
c0103449:	66 c7 45 de 21 00    	movw   $0x21,-0x22(%ebp)
c010344f:	c6 45 dd 03          	movb   $0x3,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0103453:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0103457:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c010345b:	ee                   	out    %al,(%dx)
}
c010345c:	90                   	nop
c010345d:	66 c7 45 e2 a0 00    	movw   $0xa0,-0x1e(%ebp)
c0103463:	c6 45 e1 11          	movb   $0x11,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0103467:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c010346b:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c010346f:	ee                   	out    %al,(%dx)
}
c0103470:	90                   	nop
c0103471:	66 c7 45 e6 a1 00    	movw   $0xa1,-0x1a(%ebp)
c0103477:	c6 45 e5 28          	movb   $0x28,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010347b:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c010347f:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0103483:	ee                   	out    %al,(%dx)
}
c0103484:	90                   	nop
c0103485:	66 c7 45 ea a1 00    	movw   $0xa1,-0x16(%ebp)
c010348b:	c6 45 e9 02          	movb   $0x2,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010348f:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0103493:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0103497:	ee                   	out    %al,(%dx)
}
c0103498:	90                   	nop
c0103499:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
c010349f:	c6 45 ed 03          	movb   $0x3,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01034a3:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01034a7:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01034ab:	ee                   	out    %al,(%dx)
}
c01034ac:	90                   	nop
c01034ad:	66 c7 45 f2 20 00    	movw   $0x20,-0xe(%ebp)
c01034b3:	c6 45 f1 68          	movb   $0x68,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01034b7:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01034bb:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01034bf:	ee                   	out    %al,(%dx)
}
c01034c0:	90                   	nop
c01034c1:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c01034c7:	c6 45 f5 0a          	movb   $0xa,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01034cb:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c01034cf:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01034d3:	ee                   	out    %al,(%dx)
}
c01034d4:	90                   	nop
c01034d5:	66 c7 45 fa a0 00    	movw   $0xa0,-0x6(%ebp)
c01034db:	c6 45 f9 68          	movb   $0x68,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01034df:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01034e3:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c01034e7:	ee                   	out    %al,(%dx)
}
c01034e8:	90                   	nop
c01034e9:	66 c7 45 fe a0 00    	movw   $0xa0,-0x2(%ebp)
c01034ef:	c6 45 fd 0a          	movb   $0xa,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01034f3:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c01034f7:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c01034fb:	ee                   	out    %al,(%dx)
}
c01034fc:	90                   	nop
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c01034fd:	0f b7 05 50 b5 12 c0 	movzwl 0xc012b550,%eax
c0103504:	66 83 f8 ff          	cmp    $0xffff,%ax
c0103508:	74 13                	je     c010351d <pic_init+0x14c>
        pic_setmask(irq_mask);
c010350a:	0f b7 05 50 b5 12 c0 	movzwl 0xc012b550,%eax
c0103511:	0f b7 c0             	movzwl %ax,%eax
c0103514:	50                   	push   %eax
c0103515:	e8 27 fe ff ff       	call   c0103341 <pic_setmask>
c010351a:	83 c4 04             	add    $0x4,%esp
    }
}
c010351d:	90                   	nop
c010351e:	c9                   	leave  
c010351f:	c3                   	ret    

c0103520 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c0103520:	f3 0f 1e fb          	endbr32 
c0103524:	55                   	push   %ebp
c0103525:	89 e5                	mov    %esp,%ebp
    asm volatile ("sti");
c0103527:	fb                   	sti    
}
c0103528:	90                   	nop
    sti();
}
c0103529:	90                   	nop
c010352a:	5d                   	pop    %ebp
c010352b:	c3                   	ret    

c010352c <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c010352c:	f3 0f 1e fb          	endbr32 
c0103530:	55                   	push   %ebp
c0103531:	89 e5                	mov    %esp,%ebp
    asm volatile ("cli" ::: "memory");
c0103533:	fa                   	cli    
}
c0103534:	90                   	nop
    cli();
}
c0103535:	90                   	nop
c0103536:	5d                   	pop    %ebp
c0103537:	c3                   	ret    

c0103538 <print_ticks>:
#include <swap.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
c0103538:	f3 0f 1e fb          	endbr32 
c010353c:	55                   	push   %ebp
c010353d:	89 e5                	mov    %esp,%ebp
c010353f:	83 ec 08             	sub    $0x8,%esp
    cprintf("%d ticks\n",TICK_NUM);
c0103542:	83 ec 08             	sub    $0x8,%esp
c0103545:	6a 64                	push   $0x64
c0103547:	68 80 b2 10 c0       	push   $0xc010b280
c010354c:	e8 61 cd ff ff       	call   c01002b2 <cprintf>
c0103551:	83 c4 10             	add    $0x10,%esp
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
c0103554:	83 ec 0c             	sub    $0xc,%esp
c0103557:	68 8a b2 10 c0       	push   $0xc010b28a
c010355c:	e8 51 cd ff ff       	call   c01002b2 <cprintf>
c0103561:	83 c4 10             	add    $0x10,%esp
    panic("EOT: kernel seems ok.");
c0103564:	83 ec 04             	sub    $0x4,%esp
c0103567:	68 98 b2 10 c0       	push   $0xc010b298
c010356c:	6a 14                	push   $0x14
c010356e:	68 ae b2 10 c0       	push   $0xc010b2ae
c0103573:	e8 76 e2 ff ff       	call   c01017ee <__panic>

c0103578 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c0103578:	f3 0f 1e fb          	endbr32 
c010357c:	55                   	push   %ebp
c010357d:	89 e5                	mov    %esp,%ebp
c010357f:	83 ec 10             	sub    $0x10,%esp
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c0103582:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0103589:	e9 c3 00 00 00       	jmp    c0103651 <idt_init+0xd9>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c010358e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103591:	8b 04 85 e0 b5 12 c0 	mov    -0x3fed4a20(,%eax,4),%eax
c0103598:	89 c2                	mov    %eax,%edx
c010359a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010359d:	66 89 14 c5 60 e7 12 	mov    %dx,-0x3fed18a0(,%eax,8)
c01035a4:	c0 
c01035a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01035a8:	66 c7 04 c5 62 e7 12 	movw   $0x8,-0x3fed189e(,%eax,8)
c01035af:	c0 08 00 
c01035b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01035b5:	0f b6 14 c5 64 e7 12 	movzbl -0x3fed189c(,%eax,8),%edx
c01035bc:	c0 
c01035bd:	83 e2 e0             	and    $0xffffffe0,%edx
c01035c0:	88 14 c5 64 e7 12 c0 	mov    %dl,-0x3fed189c(,%eax,8)
c01035c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01035ca:	0f b6 14 c5 64 e7 12 	movzbl -0x3fed189c(,%eax,8),%edx
c01035d1:	c0 
c01035d2:	83 e2 1f             	and    $0x1f,%edx
c01035d5:	88 14 c5 64 e7 12 c0 	mov    %dl,-0x3fed189c(,%eax,8)
c01035dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01035df:	0f b6 14 c5 65 e7 12 	movzbl -0x3fed189b(,%eax,8),%edx
c01035e6:	c0 
c01035e7:	83 e2 f0             	and    $0xfffffff0,%edx
c01035ea:	83 ca 0e             	or     $0xe,%edx
c01035ed:	88 14 c5 65 e7 12 c0 	mov    %dl,-0x3fed189b(,%eax,8)
c01035f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01035f7:	0f b6 14 c5 65 e7 12 	movzbl -0x3fed189b(,%eax,8),%edx
c01035fe:	c0 
c01035ff:	83 e2 ef             	and    $0xffffffef,%edx
c0103602:	88 14 c5 65 e7 12 c0 	mov    %dl,-0x3fed189b(,%eax,8)
c0103609:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010360c:	0f b6 14 c5 65 e7 12 	movzbl -0x3fed189b(,%eax,8),%edx
c0103613:	c0 
c0103614:	83 e2 9f             	and    $0xffffff9f,%edx
c0103617:	88 14 c5 65 e7 12 c0 	mov    %dl,-0x3fed189b(,%eax,8)
c010361e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103621:	0f b6 14 c5 65 e7 12 	movzbl -0x3fed189b(,%eax,8),%edx
c0103628:	c0 
c0103629:	83 ca 80             	or     $0xffffff80,%edx
c010362c:	88 14 c5 65 e7 12 c0 	mov    %dl,-0x3fed189b(,%eax,8)
c0103633:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103636:	8b 04 85 e0 b5 12 c0 	mov    -0x3fed4a20(,%eax,4),%eax
c010363d:	c1 e8 10             	shr    $0x10,%eax
c0103640:	89 c2                	mov    %eax,%edx
c0103642:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103645:	66 89 14 c5 66 e7 12 	mov    %dx,-0x3fed189a(,%eax,8)
c010364c:	c0 
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c010364d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0103651:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103654:	3d ff 00 00 00       	cmp    $0xff,%eax
c0103659:	0f 86 2f ff ff ff    	jbe    c010358e <idt_init+0x16>
c010365f:	c7 45 f8 60 b5 12 c0 	movl   $0xc012b560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c0103666:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0103669:	0f 01 18             	lidtl  (%eax)
}
c010366c:	90                   	nop
    }
    lidt(&idt_pd);
}
c010366d:	90                   	nop
c010366e:	c9                   	leave  
c010366f:	c3                   	ret    

c0103670 <trapname>:

static const char *
trapname(int trapno) {
c0103670:	f3 0f 1e fb          	endbr32 
c0103674:	55                   	push   %ebp
c0103675:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c0103677:	8b 45 08             	mov    0x8(%ebp),%eax
c010367a:	83 f8 13             	cmp    $0x13,%eax
c010367d:	77 0c                	ja     c010368b <trapname+0x1b>
        return excnames[trapno];
c010367f:	8b 45 08             	mov    0x8(%ebp),%eax
c0103682:	8b 04 85 00 b7 10 c0 	mov    -0x3fef4900(,%eax,4),%eax
c0103689:	eb 18                	jmp    c01036a3 <trapname+0x33>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c010368b:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c010368f:	7e 0d                	jle    c010369e <trapname+0x2e>
c0103691:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c0103695:	7f 07                	jg     c010369e <trapname+0x2e>
        return "Hardware Interrupt";
c0103697:	b8 bf b2 10 c0       	mov    $0xc010b2bf,%eax
c010369c:	eb 05                	jmp    c01036a3 <trapname+0x33>
    }
    return "(unknown trap)";
c010369e:	b8 d2 b2 10 c0       	mov    $0xc010b2d2,%eax
}
c01036a3:	5d                   	pop    %ebp
c01036a4:	c3                   	ret    

c01036a5 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c01036a5:	f3 0f 1e fb          	endbr32 
c01036a9:	55                   	push   %ebp
c01036aa:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c01036ac:	8b 45 08             	mov    0x8(%ebp),%eax
c01036af:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01036b3:	66 83 f8 08          	cmp    $0x8,%ax
c01036b7:	0f 94 c0             	sete   %al
c01036ba:	0f b6 c0             	movzbl %al,%eax
}
c01036bd:	5d                   	pop    %ebp
c01036be:	c3                   	ret    

c01036bf <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c01036bf:	f3 0f 1e fb          	endbr32 
c01036c3:	55                   	push   %ebp
c01036c4:	89 e5                	mov    %esp,%ebp
c01036c6:	83 ec 18             	sub    $0x18,%esp
    cprintf("trapframe at %p\n", tf);
c01036c9:	83 ec 08             	sub    $0x8,%esp
c01036cc:	ff 75 08             	pushl  0x8(%ebp)
c01036cf:	68 13 b3 10 c0       	push   $0xc010b313
c01036d4:	e8 d9 cb ff ff       	call   c01002b2 <cprintf>
c01036d9:	83 c4 10             	add    $0x10,%esp
    print_regs(&tf->tf_regs);
c01036dc:	8b 45 08             	mov    0x8(%ebp),%eax
c01036df:	83 ec 0c             	sub    $0xc,%esp
c01036e2:	50                   	push   %eax
c01036e3:	e8 b4 01 00 00       	call   c010389c <print_regs>
c01036e8:	83 c4 10             	add    $0x10,%esp
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c01036eb:	8b 45 08             	mov    0x8(%ebp),%eax
c01036ee:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c01036f2:	0f b7 c0             	movzwl %ax,%eax
c01036f5:	83 ec 08             	sub    $0x8,%esp
c01036f8:	50                   	push   %eax
c01036f9:	68 24 b3 10 c0       	push   $0xc010b324
c01036fe:	e8 af cb ff ff       	call   c01002b2 <cprintf>
c0103703:	83 c4 10             	add    $0x10,%esp
    cprintf("  es   0x----%04x\n", tf->tf_es);
c0103706:	8b 45 08             	mov    0x8(%ebp),%eax
c0103709:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c010370d:	0f b7 c0             	movzwl %ax,%eax
c0103710:	83 ec 08             	sub    $0x8,%esp
c0103713:	50                   	push   %eax
c0103714:	68 37 b3 10 c0       	push   $0xc010b337
c0103719:	e8 94 cb ff ff       	call   c01002b2 <cprintf>
c010371e:	83 c4 10             	add    $0x10,%esp
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0103721:	8b 45 08             	mov    0x8(%ebp),%eax
c0103724:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0103728:	0f b7 c0             	movzwl %ax,%eax
c010372b:	83 ec 08             	sub    $0x8,%esp
c010372e:	50                   	push   %eax
c010372f:	68 4a b3 10 c0       	push   $0xc010b34a
c0103734:	e8 79 cb ff ff       	call   c01002b2 <cprintf>
c0103739:	83 c4 10             	add    $0x10,%esp
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c010373c:	8b 45 08             	mov    0x8(%ebp),%eax
c010373f:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c0103743:	0f b7 c0             	movzwl %ax,%eax
c0103746:	83 ec 08             	sub    $0x8,%esp
c0103749:	50                   	push   %eax
c010374a:	68 5d b3 10 c0       	push   $0xc010b35d
c010374f:	e8 5e cb ff ff       	call   c01002b2 <cprintf>
c0103754:	83 c4 10             	add    $0x10,%esp
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c0103757:	8b 45 08             	mov    0x8(%ebp),%eax
c010375a:	8b 40 30             	mov    0x30(%eax),%eax
c010375d:	83 ec 0c             	sub    $0xc,%esp
c0103760:	50                   	push   %eax
c0103761:	e8 0a ff ff ff       	call   c0103670 <trapname>
c0103766:	83 c4 10             	add    $0x10,%esp
c0103769:	8b 55 08             	mov    0x8(%ebp),%edx
c010376c:	8b 52 30             	mov    0x30(%edx),%edx
c010376f:	83 ec 04             	sub    $0x4,%esp
c0103772:	50                   	push   %eax
c0103773:	52                   	push   %edx
c0103774:	68 70 b3 10 c0       	push   $0xc010b370
c0103779:	e8 34 cb ff ff       	call   c01002b2 <cprintf>
c010377e:	83 c4 10             	add    $0x10,%esp
    cprintf("  err  0x%08x\n", tf->tf_err);
c0103781:	8b 45 08             	mov    0x8(%ebp),%eax
c0103784:	8b 40 34             	mov    0x34(%eax),%eax
c0103787:	83 ec 08             	sub    $0x8,%esp
c010378a:	50                   	push   %eax
c010378b:	68 82 b3 10 c0       	push   $0xc010b382
c0103790:	e8 1d cb ff ff       	call   c01002b2 <cprintf>
c0103795:	83 c4 10             	add    $0x10,%esp
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c0103798:	8b 45 08             	mov    0x8(%ebp),%eax
c010379b:	8b 40 38             	mov    0x38(%eax),%eax
c010379e:	83 ec 08             	sub    $0x8,%esp
c01037a1:	50                   	push   %eax
c01037a2:	68 91 b3 10 c0       	push   $0xc010b391
c01037a7:	e8 06 cb ff ff       	call   c01002b2 <cprintf>
c01037ac:	83 c4 10             	add    $0x10,%esp
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c01037af:	8b 45 08             	mov    0x8(%ebp),%eax
c01037b2:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01037b6:	0f b7 c0             	movzwl %ax,%eax
c01037b9:	83 ec 08             	sub    $0x8,%esp
c01037bc:	50                   	push   %eax
c01037bd:	68 a0 b3 10 c0       	push   $0xc010b3a0
c01037c2:	e8 eb ca ff ff       	call   c01002b2 <cprintf>
c01037c7:	83 c4 10             	add    $0x10,%esp
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c01037ca:	8b 45 08             	mov    0x8(%ebp),%eax
c01037cd:	8b 40 40             	mov    0x40(%eax),%eax
c01037d0:	83 ec 08             	sub    $0x8,%esp
c01037d3:	50                   	push   %eax
c01037d4:	68 b3 b3 10 c0       	push   $0xc010b3b3
c01037d9:	e8 d4 ca ff ff       	call   c01002b2 <cprintf>
c01037de:	83 c4 10             	add    $0x10,%esp

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c01037e1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01037e8:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c01037ef:	eb 3f                	jmp    c0103830 <print_trapframe+0x171>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c01037f1:	8b 45 08             	mov    0x8(%ebp),%eax
c01037f4:	8b 50 40             	mov    0x40(%eax),%edx
c01037f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01037fa:	21 d0                	and    %edx,%eax
c01037fc:	85 c0                	test   %eax,%eax
c01037fe:	74 29                	je     c0103829 <print_trapframe+0x16a>
c0103800:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103803:	8b 04 85 80 b5 12 c0 	mov    -0x3fed4a80(,%eax,4),%eax
c010380a:	85 c0                	test   %eax,%eax
c010380c:	74 1b                	je     c0103829 <print_trapframe+0x16a>
            cprintf("%s,", IA32flags[i]);
c010380e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103811:	8b 04 85 80 b5 12 c0 	mov    -0x3fed4a80(,%eax,4),%eax
c0103818:	83 ec 08             	sub    $0x8,%esp
c010381b:	50                   	push   %eax
c010381c:	68 c2 b3 10 c0       	push   $0xc010b3c2
c0103821:	e8 8c ca ff ff       	call   c01002b2 <cprintf>
c0103826:	83 c4 10             	add    $0x10,%esp
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0103829:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010382d:	d1 65 f0             	shll   -0x10(%ebp)
c0103830:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103833:	83 f8 17             	cmp    $0x17,%eax
c0103836:	76 b9                	jbe    c01037f1 <print_trapframe+0x132>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c0103838:	8b 45 08             	mov    0x8(%ebp),%eax
c010383b:	8b 40 40             	mov    0x40(%eax),%eax
c010383e:	c1 e8 0c             	shr    $0xc,%eax
c0103841:	83 e0 03             	and    $0x3,%eax
c0103844:	83 ec 08             	sub    $0x8,%esp
c0103847:	50                   	push   %eax
c0103848:	68 c6 b3 10 c0       	push   $0xc010b3c6
c010384d:	e8 60 ca ff ff       	call   c01002b2 <cprintf>
c0103852:	83 c4 10             	add    $0x10,%esp

    if (!trap_in_kernel(tf)) {
c0103855:	83 ec 0c             	sub    $0xc,%esp
c0103858:	ff 75 08             	pushl  0x8(%ebp)
c010385b:	e8 45 fe ff ff       	call   c01036a5 <trap_in_kernel>
c0103860:	83 c4 10             	add    $0x10,%esp
c0103863:	85 c0                	test   %eax,%eax
c0103865:	75 32                	jne    c0103899 <print_trapframe+0x1da>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c0103867:	8b 45 08             	mov    0x8(%ebp),%eax
c010386a:	8b 40 44             	mov    0x44(%eax),%eax
c010386d:	83 ec 08             	sub    $0x8,%esp
c0103870:	50                   	push   %eax
c0103871:	68 cf b3 10 c0       	push   $0xc010b3cf
c0103876:	e8 37 ca ff ff       	call   c01002b2 <cprintf>
c010387b:	83 c4 10             	add    $0x10,%esp
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c010387e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103881:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c0103885:	0f b7 c0             	movzwl %ax,%eax
c0103888:	83 ec 08             	sub    $0x8,%esp
c010388b:	50                   	push   %eax
c010388c:	68 de b3 10 c0       	push   $0xc010b3de
c0103891:	e8 1c ca ff ff       	call   c01002b2 <cprintf>
c0103896:	83 c4 10             	add    $0x10,%esp
    }
}
c0103899:	90                   	nop
c010389a:	c9                   	leave  
c010389b:	c3                   	ret    

c010389c <print_regs>:

void
print_regs(struct pushregs *regs) {
c010389c:	f3 0f 1e fb          	endbr32 
c01038a0:	55                   	push   %ebp
c01038a1:	89 e5                	mov    %esp,%ebp
c01038a3:	83 ec 08             	sub    $0x8,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c01038a6:	8b 45 08             	mov    0x8(%ebp),%eax
c01038a9:	8b 00                	mov    (%eax),%eax
c01038ab:	83 ec 08             	sub    $0x8,%esp
c01038ae:	50                   	push   %eax
c01038af:	68 f1 b3 10 c0       	push   $0xc010b3f1
c01038b4:	e8 f9 c9 ff ff       	call   c01002b2 <cprintf>
c01038b9:	83 c4 10             	add    $0x10,%esp
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c01038bc:	8b 45 08             	mov    0x8(%ebp),%eax
c01038bf:	8b 40 04             	mov    0x4(%eax),%eax
c01038c2:	83 ec 08             	sub    $0x8,%esp
c01038c5:	50                   	push   %eax
c01038c6:	68 00 b4 10 c0       	push   $0xc010b400
c01038cb:	e8 e2 c9 ff ff       	call   c01002b2 <cprintf>
c01038d0:	83 c4 10             	add    $0x10,%esp
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c01038d3:	8b 45 08             	mov    0x8(%ebp),%eax
c01038d6:	8b 40 08             	mov    0x8(%eax),%eax
c01038d9:	83 ec 08             	sub    $0x8,%esp
c01038dc:	50                   	push   %eax
c01038dd:	68 0f b4 10 c0       	push   $0xc010b40f
c01038e2:	e8 cb c9 ff ff       	call   c01002b2 <cprintf>
c01038e7:	83 c4 10             	add    $0x10,%esp
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c01038ea:	8b 45 08             	mov    0x8(%ebp),%eax
c01038ed:	8b 40 0c             	mov    0xc(%eax),%eax
c01038f0:	83 ec 08             	sub    $0x8,%esp
c01038f3:	50                   	push   %eax
c01038f4:	68 1e b4 10 c0       	push   $0xc010b41e
c01038f9:	e8 b4 c9 ff ff       	call   c01002b2 <cprintf>
c01038fe:	83 c4 10             	add    $0x10,%esp
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0103901:	8b 45 08             	mov    0x8(%ebp),%eax
c0103904:	8b 40 10             	mov    0x10(%eax),%eax
c0103907:	83 ec 08             	sub    $0x8,%esp
c010390a:	50                   	push   %eax
c010390b:	68 2d b4 10 c0       	push   $0xc010b42d
c0103910:	e8 9d c9 ff ff       	call   c01002b2 <cprintf>
c0103915:	83 c4 10             	add    $0x10,%esp
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c0103918:	8b 45 08             	mov    0x8(%ebp),%eax
c010391b:	8b 40 14             	mov    0x14(%eax),%eax
c010391e:	83 ec 08             	sub    $0x8,%esp
c0103921:	50                   	push   %eax
c0103922:	68 3c b4 10 c0       	push   $0xc010b43c
c0103927:	e8 86 c9 ff ff       	call   c01002b2 <cprintf>
c010392c:	83 c4 10             	add    $0x10,%esp
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c010392f:	8b 45 08             	mov    0x8(%ebp),%eax
c0103932:	8b 40 18             	mov    0x18(%eax),%eax
c0103935:	83 ec 08             	sub    $0x8,%esp
c0103938:	50                   	push   %eax
c0103939:	68 4b b4 10 c0       	push   $0xc010b44b
c010393e:	e8 6f c9 ff ff       	call   c01002b2 <cprintf>
c0103943:	83 c4 10             	add    $0x10,%esp
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0103946:	8b 45 08             	mov    0x8(%ebp),%eax
c0103949:	8b 40 1c             	mov    0x1c(%eax),%eax
c010394c:	83 ec 08             	sub    $0x8,%esp
c010394f:	50                   	push   %eax
c0103950:	68 5a b4 10 c0       	push   $0xc010b45a
c0103955:	e8 58 c9 ff ff       	call   c01002b2 <cprintf>
c010395a:	83 c4 10             	add    $0x10,%esp
}
c010395d:	90                   	nop
c010395e:	c9                   	leave  
c010395f:	c3                   	ret    

c0103960 <print_pgfault>:

static inline void
print_pgfault(struct trapframe *tf) {
c0103960:	55                   	push   %ebp
c0103961:	89 e5                	mov    %esp,%ebp
c0103963:	53                   	push   %ebx
c0103964:	83 ec 14             	sub    $0x14,%esp
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
c0103967:	8b 45 08             	mov    0x8(%ebp),%eax
c010396a:	8b 40 34             	mov    0x34(%eax),%eax
c010396d:	83 e0 01             	and    $0x1,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c0103970:	85 c0                	test   %eax,%eax
c0103972:	74 07                	je     c010397b <print_pgfault+0x1b>
c0103974:	bb 69 b4 10 c0       	mov    $0xc010b469,%ebx
c0103979:	eb 05                	jmp    c0103980 <print_pgfault+0x20>
c010397b:	bb 7a b4 10 c0       	mov    $0xc010b47a,%ebx
            (tf->tf_err & 2) ? 'W' : 'R',
c0103980:	8b 45 08             	mov    0x8(%ebp),%eax
c0103983:	8b 40 34             	mov    0x34(%eax),%eax
c0103986:	83 e0 02             	and    $0x2,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c0103989:	85 c0                	test   %eax,%eax
c010398b:	74 07                	je     c0103994 <print_pgfault+0x34>
c010398d:	b9 57 00 00 00       	mov    $0x57,%ecx
c0103992:	eb 05                	jmp    c0103999 <print_pgfault+0x39>
c0103994:	b9 52 00 00 00       	mov    $0x52,%ecx
            (tf->tf_err & 4) ? 'U' : 'K',
c0103999:	8b 45 08             	mov    0x8(%ebp),%eax
c010399c:	8b 40 34             	mov    0x34(%eax),%eax
c010399f:	83 e0 04             	and    $0x4,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c01039a2:	85 c0                	test   %eax,%eax
c01039a4:	74 07                	je     c01039ad <print_pgfault+0x4d>
c01039a6:	ba 55 00 00 00       	mov    $0x55,%edx
c01039ab:	eb 05                	jmp    c01039b2 <print_pgfault+0x52>
c01039ad:	ba 4b 00 00 00       	mov    $0x4b,%edx
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c01039b2:	0f 20 d0             	mov    %cr2,%eax
c01039b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr2;
c01039b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01039bb:	83 ec 0c             	sub    $0xc,%esp
c01039be:	53                   	push   %ebx
c01039bf:	51                   	push   %ecx
c01039c0:	52                   	push   %edx
c01039c1:	50                   	push   %eax
c01039c2:	68 88 b4 10 c0       	push   $0xc010b488
c01039c7:	e8 e6 c8 ff ff       	call   c01002b2 <cprintf>
c01039cc:	83 c4 20             	add    $0x20,%esp
}
c01039cf:	90                   	nop
c01039d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01039d3:	c9                   	leave  
c01039d4:	c3                   	ret    

c01039d5 <pgfault_handler>:

static int
pgfault_handler(struct trapframe *tf) {
c01039d5:	f3 0f 1e fb          	endbr32 
c01039d9:	55                   	push   %ebp
c01039da:	89 e5                	mov    %esp,%ebp
c01039dc:	83 ec 18             	sub    $0x18,%esp
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
c01039df:	83 ec 0c             	sub    $0xc,%esp
c01039e2:	ff 75 08             	pushl  0x8(%ebp)
c01039e5:	e8 76 ff ff ff       	call   c0103960 <print_pgfault>
c01039ea:	83 c4 10             	add    $0x10,%esp
    if (check_mm_struct != NULL) {
c01039ed:	a1 64 10 13 c0       	mov    0xc0131064,%eax
c01039f2:	85 c0                	test   %eax,%eax
c01039f4:	74 24                	je     c0103a1a <pgfault_handler+0x45>
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c01039f6:	0f 20 d0             	mov    %cr2,%eax
c01039f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr2;
c01039fc:	8b 4d f4             	mov    -0xc(%ebp),%ecx
        return do_pgfault(check_mm_struct, tf->tf_err, rcr2());
c01039ff:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a02:	8b 50 34             	mov    0x34(%eax),%edx
c0103a05:	a1 64 10 13 c0       	mov    0xc0131064,%eax
c0103a0a:	83 ec 04             	sub    $0x4,%esp
c0103a0d:	51                   	push   %ecx
c0103a0e:	52                   	push   %edx
c0103a0f:	50                   	push   %eax
c0103a10:	e8 e2 2e 00 00       	call   c01068f7 <do_pgfault>
c0103a15:	83 c4 10             	add    $0x10,%esp
c0103a18:	eb 17                	jmp    c0103a31 <pgfault_handler+0x5c>
    }
    panic("unhandled page fault.\n");
c0103a1a:	83 ec 04             	sub    $0x4,%esp
c0103a1d:	68 ab b4 10 c0       	push   $0xc010b4ab
c0103a22:	68 a5 00 00 00       	push   $0xa5
c0103a27:	68 ae b2 10 c0       	push   $0xc010b2ae
c0103a2c:	e8 bd dd ff ff       	call   c01017ee <__panic>
}
c0103a31:	c9                   	leave  
c0103a32:	c3                   	ret    

c0103a33 <trap_dispatch>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

static void
trap_dispatch(struct trapframe *tf) {
c0103a33:	f3 0f 1e fb          	endbr32 
c0103a37:	55                   	push   %ebp
c0103a38:	89 e5                	mov    %esp,%ebp
c0103a3a:	83 ec 18             	sub    $0x18,%esp
    char c;

    int ret;

    switch (tf->tf_trapno) {
c0103a3d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a40:	8b 40 30             	mov    0x30(%eax),%eax
c0103a43:	83 f8 2f             	cmp    $0x2f,%eax
c0103a46:	77 1f                	ja     c0103a67 <trap_dispatch+0x34>
c0103a48:	83 f8 0e             	cmp    $0xe,%eax
c0103a4b:	0f 82 00 01 00 00    	jb     c0103b51 <trap_dispatch+0x11e>
c0103a51:	83 e8 0e             	sub    $0xe,%eax
c0103a54:	83 f8 21             	cmp    $0x21,%eax
c0103a57:	0f 87 f4 00 00 00    	ja     c0103b51 <trap_dispatch+0x11e>
c0103a5d:	8b 04 85 2c b5 10 c0 	mov    -0x3fef4ad4(,%eax,4),%eax
c0103a64:	3e ff e0             	notrack jmp *%eax
c0103a67:	83 e8 78             	sub    $0x78,%eax
c0103a6a:	83 f8 01             	cmp    $0x1,%eax
c0103a6d:	0f 87 de 00 00 00    	ja     c0103b51 <trap_dispatch+0x11e>
c0103a73:	e9 c2 00 00 00       	jmp    c0103b3a <trap_dispatch+0x107>
    case T_PGFLT:  //page fault
        if ((ret = pgfault_handler(tf)) != 0) {
c0103a78:	83 ec 0c             	sub    $0xc,%esp
c0103a7b:	ff 75 08             	pushl  0x8(%ebp)
c0103a7e:	e8 52 ff ff ff       	call   c01039d5 <pgfault_handler>
c0103a83:	83 c4 10             	add    $0x10,%esp
c0103a86:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103a89:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103a8d:	0f 84 f7 00 00 00    	je     c0103b8a <trap_dispatch+0x157>
            print_trapframe(tf);
c0103a93:	83 ec 0c             	sub    $0xc,%esp
c0103a96:	ff 75 08             	pushl  0x8(%ebp)
c0103a99:	e8 21 fc ff ff       	call   c01036bf <print_trapframe>
c0103a9e:	83 c4 10             	add    $0x10,%esp
            panic("handle pgfault failed. %e\n", ret);
c0103aa1:	ff 75 f0             	pushl  -0x10(%ebp)
c0103aa4:	68 c2 b4 10 c0       	push   $0xc010b4c2
c0103aa9:	68 b5 00 00 00       	push   $0xb5
c0103aae:	68 ae b2 10 c0       	push   $0xc010b2ae
c0103ab3:	e8 36 dd ff ff       	call   c01017ee <__panic>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks ++;
c0103ab8:	a1 54 10 13 c0       	mov    0xc0131054,%eax
c0103abd:	83 c0 01             	add    $0x1,%eax
c0103ac0:	a3 54 10 13 c0       	mov    %eax,0xc0131054
        if (ticks % TICK_NUM == 0) {
c0103ac5:	8b 0d 54 10 13 c0    	mov    0xc0131054,%ecx
c0103acb:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c0103ad0:	89 c8                	mov    %ecx,%eax
c0103ad2:	f7 e2                	mul    %edx
c0103ad4:	89 d0                	mov    %edx,%eax
c0103ad6:	c1 e8 05             	shr    $0x5,%eax
c0103ad9:	6b c0 64             	imul   $0x64,%eax,%eax
c0103adc:	29 c1                	sub    %eax,%ecx
c0103ade:	89 c8                	mov    %ecx,%eax
c0103ae0:	85 c0                	test   %eax,%eax
c0103ae2:	0f 85 a5 00 00 00    	jne    c0103b8d <trap_dispatch+0x15a>
            print_ticks();
c0103ae8:	e8 4b fa ff ff       	call   c0103538 <print_ticks>
        }
        break;
c0103aed:	e9 9b 00 00 00       	jmp    c0103b8d <trap_dispatch+0x15a>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c0103af2:	e8 d4 f7 ff ff       	call   c01032cb <cons_getc>
c0103af7:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c0103afa:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0103afe:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0103b02:	83 ec 04             	sub    $0x4,%esp
c0103b05:	52                   	push   %edx
c0103b06:	50                   	push   %eax
c0103b07:	68 dd b4 10 c0       	push   $0xc010b4dd
c0103b0c:	e8 a1 c7 ff ff       	call   c01002b2 <cprintf>
c0103b11:	83 c4 10             	add    $0x10,%esp
        break;
c0103b14:	eb 78                	jmp    c0103b8e <trap_dispatch+0x15b>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c0103b16:	e8 b0 f7 ff ff       	call   c01032cb <cons_getc>
c0103b1b:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c0103b1e:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0103b22:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0103b26:	83 ec 04             	sub    $0x4,%esp
c0103b29:	52                   	push   %edx
c0103b2a:	50                   	push   %eax
c0103b2b:	68 ef b4 10 c0       	push   $0xc010b4ef
c0103b30:	e8 7d c7 ff ff       	call   c01002b2 <cprintf>
c0103b35:	83 c4 10             	add    $0x10,%esp
        break;
c0103b38:	eb 54                	jmp    c0103b8e <trap_dispatch+0x15b>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
c0103b3a:	83 ec 04             	sub    $0x4,%esp
c0103b3d:	68 fe b4 10 c0       	push   $0xc010b4fe
c0103b42:	68 d3 00 00 00       	push   $0xd3
c0103b47:	68 ae b2 10 c0       	push   $0xc010b2ae
c0103b4c:	e8 9d dc ff ff       	call   c01017ee <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c0103b51:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b54:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0103b58:	0f b7 c0             	movzwl %ax,%eax
c0103b5b:	83 e0 03             	and    $0x3,%eax
c0103b5e:	85 c0                	test   %eax,%eax
c0103b60:	75 2c                	jne    c0103b8e <trap_dispatch+0x15b>
            print_trapframe(tf);
c0103b62:	83 ec 0c             	sub    $0xc,%esp
c0103b65:	ff 75 08             	pushl  0x8(%ebp)
c0103b68:	e8 52 fb ff ff       	call   c01036bf <print_trapframe>
c0103b6d:	83 c4 10             	add    $0x10,%esp
            panic("unexpected trap in kernel.\n");
c0103b70:	83 ec 04             	sub    $0x4,%esp
c0103b73:	68 0e b5 10 c0       	push   $0xc010b50e
c0103b78:	68 dd 00 00 00       	push   $0xdd
c0103b7d:	68 ae b2 10 c0       	push   $0xc010b2ae
c0103b82:	e8 67 dc ff ff       	call   c01017ee <__panic>
        break;
c0103b87:	90                   	nop
c0103b88:	eb 04                	jmp    c0103b8e <trap_dispatch+0x15b>
        break;
c0103b8a:	90                   	nop
c0103b8b:	eb 01                	jmp    c0103b8e <trap_dispatch+0x15b>
        break;
c0103b8d:	90                   	nop
        }
    }
}
c0103b8e:	90                   	nop
c0103b8f:	c9                   	leave  
c0103b90:	c3                   	ret    

c0103b91 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c0103b91:	f3 0f 1e fb          	endbr32 
c0103b95:	55                   	push   %ebp
c0103b96:	89 e5                	mov    %esp,%ebp
c0103b98:	83 ec 08             	sub    $0x8,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c0103b9b:	83 ec 0c             	sub    $0xc,%esp
c0103b9e:	ff 75 08             	pushl  0x8(%ebp)
c0103ba1:	e8 8d fe ff ff       	call   c0103a33 <trap_dispatch>
c0103ba6:	83 c4 10             	add    $0x10,%esp
}
c0103ba9:	90                   	nop
c0103baa:	c9                   	leave  
c0103bab:	c3                   	ret    

c0103bac <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0103bac:	6a 00                	push   $0x0
  pushl $0
c0103bae:	6a 00                	push   $0x0
  jmp __alltraps
c0103bb0:	e9 67 0a 00 00       	jmp    c010461c <__alltraps>

c0103bb5 <vector1>:
.globl vector1
vector1:
  pushl $0
c0103bb5:	6a 00                	push   $0x0
  pushl $1
c0103bb7:	6a 01                	push   $0x1
  jmp __alltraps
c0103bb9:	e9 5e 0a 00 00       	jmp    c010461c <__alltraps>

c0103bbe <vector2>:
.globl vector2
vector2:
  pushl $0
c0103bbe:	6a 00                	push   $0x0
  pushl $2
c0103bc0:	6a 02                	push   $0x2
  jmp __alltraps
c0103bc2:	e9 55 0a 00 00       	jmp    c010461c <__alltraps>

c0103bc7 <vector3>:
.globl vector3
vector3:
  pushl $0
c0103bc7:	6a 00                	push   $0x0
  pushl $3
c0103bc9:	6a 03                	push   $0x3
  jmp __alltraps
c0103bcb:	e9 4c 0a 00 00       	jmp    c010461c <__alltraps>

c0103bd0 <vector4>:
.globl vector4
vector4:
  pushl $0
c0103bd0:	6a 00                	push   $0x0
  pushl $4
c0103bd2:	6a 04                	push   $0x4
  jmp __alltraps
c0103bd4:	e9 43 0a 00 00       	jmp    c010461c <__alltraps>

c0103bd9 <vector5>:
.globl vector5
vector5:
  pushl $0
c0103bd9:	6a 00                	push   $0x0
  pushl $5
c0103bdb:	6a 05                	push   $0x5
  jmp __alltraps
c0103bdd:	e9 3a 0a 00 00       	jmp    c010461c <__alltraps>

c0103be2 <vector6>:
.globl vector6
vector6:
  pushl $0
c0103be2:	6a 00                	push   $0x0
  pushl $6
c0103be4:	6a 06                	push   $0x6
  jmp __alltraps
c0103be6:	e9 31 0a 00 00       	jmp    c010461c <__alltraps>

c0103beb <vector7>:
.globl vector7
vector7:
  pushl $0
c0103beb:	6a 00                	push   $0x0
  pushl $7
c0103bed:	6a 07                	push   $0x7
  jmp __alltraps
c0103bef:	e9 28 0a 00 00       	jmp    c010461c <__alltraps>

c0103bf4 <vector8>:
.globl vector8
vector8:
  pushl $8
c0103bf4:	6a 08                	push   $0x8
  jmp __alltraps
c0103bf6:	e9 21 0a 00 00       	jmp    c010461c <__alltraps>

c0103bfb <vector9>:
.globl vector9
vector9:
  pushl $9
c0103bfb:	6a 09                	push   $0x9
  jmp __alltraps
c0103bfd:	e9 1a 0a 00 00       	jmp    c010461c <__alltraps>

c0103c02 <vector10>:
.globl vector10
vector10:
  pushl $10
c0103c02:	6a 0a                	push   $0xa
  jmp __alltraps
c0103c04:	e9 13 0a 00 00       	jmp    c010461c <__alltraps>

c0103c09 <vector11>:
.globl vector11
vector11:
  pushl $11
c0103c09:	6a 0b                	push   $0xb
  jmp __alltraps
c0103c0b:	e9 0c 0a 00 00       	jmp    c010461c <__alltraps>

c0103c10 <vector12>:
.globl vector12
vector12:
  pushl $12
c0103c10:	6a 0c                	push   $0xc
  jmp __alltraps
c0103c12:	e9 05 0a 00 00       	jmp    c010461c <__alltraps>

c0103c17 <vector13>:
.globl vector13
vector13:
  pushl $13
c0103c17:	6a 0d                	push   $0xd
  jmp __alltraps
c0103c19:	e9 fe 09 00 00       	jmp    c010461c <__alltraps>

c0103c1e <vector14>:
.globl vector14
vector14:
  pushl $14
c0103c1e:	6a 0e                	push   $0xe
  jmp __alltraps
c0103c20:	e9 f7 09 00 00       	jmp    c010461c <__alltraps>

c0103c25 <vector15>:
.globl vector15
vector15:
  pushl $0
c0103c25:	6a 00                	push   $0x0
  pushl $15
c0103c27:	6a 0f                	push   $0xf
  jmp __alltraps
c0103c29:	e9 ee 09 00 00       	jmp    c010461c <__alltraps>

c0103c2e <vector16>:
.globl vector16
vector16:
  pushl $0
c0103c2e:	6a 00                	push   $0x0
  pushl $16
c0103c30:	6a 10                	push   $0x10
  jmp __alltraps
c0103c32:	e9 e5 09 00 00       	jmp    c010461c <__alltraps>

c0103c37 <vector17>:
.globl vector17
vector17:
  pushl $17
c0103c37:	6a 11                	push   $0x11
  jmp __alltraps
c0103c39:	e9 de 09 00 00       	jmp    c010461c <__alltraps>

c0103c3e <vector18>:
.globl vector18
vector18:
  pushl $0
c0103c3e:	6a 00                	push   $0x0
  pushl $18
c0103c40:	6a 12                	push   $0x12
  jmp __alltraps
c0103c42:	e9 d5 09 00 00       	jmp    c010461c <__alltraps>

c0103c47 <vector19>:
.globl vector19
vector19:
  pushl $0
c0103c47:	6a 00                	push   $0x0
  pushl $19
c0103c49:	6a 13                	push   $0x13
  jmp __alltraps
c0103c4b:	e9 cc 09 00 00       	jmp    c010461c <__alltraps>

c0103c50 <vector20>:
.globl vector20
vector20:
  pushl $0
c0103c50:	6a 00                	push   $0x0
  pushl $20
c0103c52:	6a 14                	push   $0x14
  jmp __alltraps
c0103c54:	e9 c3 09 00 00       	jmp    c010461c <__alltraps>

c0103c59 <vector21>:
.globl vector21
vector21:
  pushl $0
c0103c59:	6a 00                	push   $0x0
  pushl $21
c0103c5b:	6a 15                	push   $0x15
  jmp __alltraps
c0103c5d:	e9 ba 09 00 00       	jmp    c010461c <__alltraps>

c0103c62 <vector22>:
.globl vector22
vector22:
  pushl $0
c0103c62:	6a 00                	push   $0x0
  pushl $22
c0103c64:	6a 16                	push   $0x16
  jmp __alltraps
c0103c66:	e9 b1 09 00 00       	jmp    c010461c <__alltraps>

c0103c6b <vector23>:
.globl vector23
vector23:
  pushl $0
c0103c6b:	6a 00                	push   $0x0
  pushl $23
c0103c6d:	6a 17                	push   $0x17
  jmp __alltraps
c0103c6f:	e9 a8 09 00 00       	jmp    c010461c <__alltraps>

c0103c74 <vector24>:
.globl vector24
vector24:
  pushl $0
c0103c74:	6a 00                	push   $0x0
  pushl $24
c0103c76:	6a 18                	push   $0x18
  jmp __alltraps
c0103c78:	e9 9f 09 00 00       	jmp    c010461c <__alltraps>

c0103c7d <vector25>:
.globl vector25
vector25:
  pushl $0
c0103c7d:	6a 00                	push   $0x0
  pushl $25
c0103c7f:	6a 19                	push   $0x19
  jmp __alltraps
c0103c81:	e9 96 09 00 00       	jmp    c010461c <__alltraps>

c0103c86 <vector26>:
.globl vector26
vector26:
  pushl $0
c0103c86:	6a 00                	push   $0x0
  pushl $26
c0103c88:	6a 1a                	push   $0x1a
  jmp __alltraps
c0103c8a:	e9 8d 09 00 00       	jmp    c010461c <__alltraps>

c0103c8f <vector27>:
.globl vector27
vector27:
  pushl $0
c0103c8f:	6a 00                	push   $0x0
  pushl $27
c0103c91:	6a 1b                	push   $0x1b
  jmp __alltraps
c0103c93:	e9 84 09 00 00       	jmp    c010461c <__alltraps>

c0103c98 <vector28>:
.globl vector28
vector28:
  pushl $0
c0103c98:	6a 00                	push   $0x0
  pushl $28
c0103c9a:	6a 1c                	push   $0x1c
  jmp __alltraps
c0103c9c:	e9 7b 09 00 00       	jmp    c010461c <__alltraps>

c0103ca1 <vector29>:
.globl vector29
vector29:
  pushl $0
c0103ca1:	6a 00                	push   $0x0
  pushl $29
c0103ca3:	6a 1d                	push   $0x1d
  jmp __alltraps
c0103ca5:	e9 72 09 00 00       	jmp    c010461c <__alltraps>

c0103caa <vector30>:
.globl vector30
vector30:
  pushl $0
c0103caa:	6a 00                	push   $0x0
  pushl $30
c0103cac:	6a 1e                	push   $0x1e
  jmp __alltraps
c0103cae:	e9 69 09 00 00       	jmp    c010461c <__alltraps>

c0103cb3 <vector31>:
.globl vector31
vector31:
  pushl $0
c0103cb3:	6a 00                	push   $0x0
  pushl $31
c0103cb5:	6a 1f                	push   $0x1f
  jmp __alltraps
c0103cb7:	e9 60 09 00 00       	jmp    c010461c <__alltraps>

c0103cbc <vector32>:
.globl vector32
vector32:
  pushl $0
c0103cbc:	6a 00                	push   $0x0
  pushl $32
c0103cbe:	6a 20                	push   $0x20
  jmp __alltraps
c0103cc0:	e9 57 09 00 00       	jmp    c010461c <__alltraps>

c0103cc5 <vector33>:
.globl vector33
vector33:
  pushl $0
c0103cc5:	6a 00                	push   $0x0
  pushl $33
c0103cc7:	6a 21                	push   $0x21
  jmp __alltraps
c0103cc9:	e9 4e 09 00 00       	jmp    c010461c <__alltraps>

c0103cce <vector34>:
.globl vector34
vector34:
  pushl $0
c0103cce:	6a 00                	push   $0x0
  pushl $34
c0103cd0:	6a 22                	push   $0x22
  jmp __alltraps
c0103cd2:	e9 45 09 00 00       	jmp    c010461c <__alltraps>

c0103cd7 <vector35>:
.globl vector35
vector35:
  pushl $0
c0103cd7:	6a 00                	push   $0x0
  pushl $35
c0103cd9:	6a 23                	push   $0x23
  jmp __alltraps
c0103cdb:	e9 3c 09 00 00       	jmp    c010461c <__alltraps>

c0103ce0 <vector36>:
.globl vector36
vector36:
  pushl $0
c0103ce0:	6a 00                	push   $0x0
  pushl $36
c0103ce2:	6a 24                	push   $0x24
  jmp __alltraps
c0103ce4:	e9 33 09 00 00       	jmp    c010461c <__alltraps>

c0103ce9 <vector37>:
.globl vector37
vector37:
  pushl $0
c0103ce9:	6a 00                	push   $0x0
  pushl $37
c0103ceb:	6a 25                	push   $0x25
  jmp __alltraps
c0103ced:	e9 2a 09 00 00       	jmp    c010461c <__alltraps>

c0103cf2 <vector38>:
.globl vector38
vector38:
  pushl $0
c0103cf2:	6a 00                	push   $0x0
  pushl $38
c0103cf4:	6a 26                	push   $0x26
  jmp __alltraps
c0103cf6:	e9 21 09 00 00       	jmp    c010461c <__alltraps>

c0103cfb <vector39>:
.globl vector39
vector39:
  pushl $0
c0103cfb:	6a 00                	push   $0x0
  pushl $39
c0103cfd:	6a 27                	push   $0x27
  jmp __alltraps
c0103cff:	e9 18 09 00 00       	jmp    c010461c <__alltraps>

c0103d04 <vector40>:
.globl vector40
vector40:
  pushl $0
c0103d04:	6a 00                	push   $0x0
  pushl $40
c0103d06:	6a 28                	push   $0x28
  jmp __alltraps
c0103d08:	e9 0f 09 00 00       	jmp    c010461c <__alltraps>

c0103d0d <vector41>:
.globl vector41
vector41:
  pushl $0
c0103d0d:	6a 00                	push   $0x0
  pushl $41
c0103d0f:	6a 29                	push   $0x29
  jmp __alltraps
c0103d11:	e9 06 09 00 00       	jmp    c010461c <__alltraps>

c0103d16 <vector42>:
.globl vector42
vector42:
  pushl $0
c0103d16:	6a 00                	push   $0x0
  pushl $42
c0103d18:	6a 2a                	push   $0x2a
  jmp __alltraps
c0103d1a:	e9 fd 08 00 00       	jmp    c010461c <__alltraps>

c0103d1f <vector43>:
.globl vector43
vector43:
  pushl $0
c0103d1f:	6a 00                	push   $0x0
  pushl $43
c0103d21:	6a 2b                	push   $0x2b
  jmp __alltraps
c0103d23:	e9 f4 08 00 00       	jmp    c010461c <__alltraps>

c0103d28 <vector44>:
.globl vector44
vector44:
  pushl $0
c0103d28:	6a 00                	push   $0x0
  pushl $44
c0103d2a:	6a 2c                	push   $0x2c
  jmp __alltraps
c0103d2c:	e9 eb 08 00 00       	jmp    c010461c <__alltraps>

c0103d31 <vector45>:
.globl vector45
vector45:
  pushl $0
c0103d31:	6a 00                	push   $0x0
  pushl $45
c0103d33:	6a 2d                	push   $0x2d
  jmp __alltraps
c0103d35:	e9 e2 08 00 00       	jmp    c010461c <__alltraps>

c0103d3a <vector46>:
.globl vector46
vector46:
  pushl $0
c0103d3a:	6a 00                	push   $0x0
  pushl $46
c0103d3c:	6a 2e                	push   $0x2e
  jmp __alltraps
c0103d3e:	e9 d9 08 00 00       	jmp    c010461c <__alltraps>

c0103d43 <vector47>:
.globl vector47
vector47:
  pushl $0
c0103d43:	6a 00                	push   $0x0
  pushl $47
c0103d45:	6a 2f                	push   $0x2f
  jmp __alltraps
c0103d47:	e9 d0 08 00 00       	jmp    c010461c <__alltraps>

c0103d4c <vector48>:
.globl vector48
vector48:
  pushl $0
c0103d4c:	6a 00                	push   $0x0
  pushl $48
c0103d4e:	6a 30                	push   $0x30
  jmp __alltraps
c0103d50:	e9 c7 08 00 00       	jmp    c010461c <__alltraps>

c0103d55 <vector49>:
.globl vector49
vector49:
  pushl $0
c0103d55:	6a 00                	push   $0x0
  pushl $49
c0103d57:	6a 31                	push   $0x31
  jmp __alltraps
c0103d59:	e9 be 08 00 00       	jmp    c010461c <__alltraps>

c0103d5e <vector50>:
.globl vector50
vector50:
  pushl $0
c0103d5e:	6a 00                	push   $0x0
  pushl $50
c0103d60:	6a 32                	push   $0x32
  jmp __alltraps
c0103d62:	e9 b5 08 00 00       	jmp    c010461c <__alltraps>

c0103d67 <vector51>:
.globl vector51
vector51:
  pushl $0
c0103d67:	6a 00                	push   $0x0
  pushl $51
c0103d69:	6a 33                	push   $0x33
  jmp __alltraps
c0103d6b:	e9 ac 08 00 00       	jmp    c010461c <__alltraps>

c0103d70 <vector52>:
.globl vector52
vector52:
  pushl $0
c0103d70:	6a 00                	push   $0x0
  pushl $52
c0103d72:	6a 34                	push   $0x34
  jmp __alltraps
c0103d74:	e9 a3 08 00 00       	jmp    c010461c <__alltraps>

c0103d79 <vector53>:
.globl vector53
vector53:
  pushl $0
c0103d79:	6a 00                	push   $0x0
  pushl $53
c0103d7b:	6a 35                	push   $0x35
  jmp __alltraps
c0103d7d:	e9 9a 08 00 00       	jmp    c010461c <__alltraps>

c0103d82 <vector54>:
.globl vector54
vector54:
  pushl $0
c0103d82:	6a 00                	push   $0x0
  pushl $54
c0103d84:	6a 36                	push   $0x36
  jmp __alltraps
c0103d86:	e9 91 08 00 00       	jmp    c010461c <__alltraps>

c0103d8b <vector55>:
.globl vector55
vector55:
  pushl $0
c0103d8b:	6a 00                	push   $0x0
  pushl $55
c0103d8d:	6a 37                	push   $0x37
  jmp __alltraps
c0103d8f:	e9 88 08 00 00       	jmp    c010461c <__alltraps>

c0103d94 <vector56>:
.globl vector56
vector56:
  pushl $0
c0103d94:	6a 00                	push   $0x0
  pushl $56
c0103d96:	6a 38                	push   $0x38
  jmp __alltraps
c0103d98:	e9 7f 08 00 00       	jmp    c010461c <__alltraps>

c0103d9d <vector57>:
.globl vector57
vector57:
  pushl $0
c0103d9d:	6a 00                	push   $0x0
  pushl $57
c0103d9f:	6a 39                	push   $0x39
  jmp __alltraps
c0103da1:	e9 76 08 00 00       	jmp    c010461c <__alltraps>

c0103da6 <vector58>:
.globl vector58
vector58:
  pushl $0
c0103da6:	6a 00                	push   $0x0
  pushl $58
c0103da8:	6a 3a                	push   $0x3a
  jmp __alltraps
c0103daa:	e9 6d 08 00 00       	jmp    c010461c <__alltraps>

c0103daf <vector59>:
.globl vector59
vector59:
  pushl $0
c0103daf:	6a 00                	push   $0x0
  pushl $59
c0103db1:	6a 3b                	push   $0x3b
  jmp __alltraps
c0103db3:	e9 64 08 00 00       	jmp    c010461c <__alltraps>

c0103db8 <vector60>:
.globl vector60
vector60:
  pushl $0
c0103db8:	6a 00                	push   $0x0
  pushl $60
c0103dba:	6a 3c                	push   $0x3c
  jmp __alltraps
c0103dbc:	e9 5b 08 00 00       	jmp    c010461c <__alltraps>

c0103dc1 <vector61>:
.globl vector61
vector61:
  pushl $0
c0103dc1:	6a 00                	push   $0x0
  pushl $61
c0103dc3:	6a 3d                	push   $0x3d
  jmp __alltraps
c0103dc5:	e9 52 08 00 00       	jmp    c010461c <__alltraps>

c0103dca <vector62>:
.globl vector62
vector62:
  pushl $0
c0103dca:	6a 00                	push   $0x0
  pushl $62
c0103dcc:	6a 3e                	push   $0x3e
  jmp __alltraps
c0103dce:	e9 49 08 00 00       	jmp    c010461c <__alltraps>

c0103dd3 <vector63>:
.globl vector63
vector63:
  pushl $0
c0103dd3:	6a 00                	push   $0x0
  pushl $63
c0103dd5:	6a 3f                	push   $0x3f
  jmp __alltraps
c0103dd7:	e9 40 08 00 00       	jmp    c010461c <__alltraps>

c0103ddc <vector64>:
.globl vector64
vector64:
  pushl $0
c0103ddc:	6a 00                	push   $0x0
  pushl $64
c0103dde:	6a 40                	push   $0x40
  jmp __alltraps
c0103de0:	e9 37 08 00 00       	jmp    c010461c <__alltraps>

c0103de5 <vector65>:
.globl vector65
vector65:
  pushl $0
c0103de5:	6a 00                	push   $0x0
  pushl $65
c0103de7:	6a 41                	push   $0x41
  jmp __alltraps
c0103de9:	e9 2e 08 00 00       	jmp    c010461c <__alltraps>

c0103dee <vector66>:
.globl vector66
vector66:
  pushl $0
c0103dee:	6a 00                	push   $0x0
  pushl $66
c0103df0:	6a 42                	push   $0x42
  jmp __alltraps
c0103df2:	e9 25 08 00 00       	jmp    c010461c <__alltraps>

c0103df7 <vector67>:
.globl vector67
vector67:
  pushl $0
c0103df7:	6a 00                	push   $0x0
  pushl $67
c0103df9:	6a 43                	push   $0x43
  jmp __alltraps
c0103dfb:	e9 1c 08 00 00       	jmp    c010461c <__alltraps>

c0103e00 <vector68>:
.globl vector68
vector68:
  pushl $0
c0103e00:	6a 00                	push   $0x0
  pushl $68
c0103e02:	6a 44                	push   $0x44
  jmp __alltraps
c0103e04:	e9 13 08 00 00       	jmp    c010461c <__alltraps>

c0103e09 <vector69>:
.globl vector69
vector69:
  pushl $0
c0103e09:	6a 00                	push   $0x0
  pushl $69
c0103e0b:	6a 45                	push   $0x45
  jmp __alltraps
c0103e0d:	e9 0a 08 00 00       	jmp    c010461c <__alltraps>

c0103e12 <vector70>:
.globl vector70
vector70:
  pushl $0
c0103e12:	6a 00                	push   $0x0
  pushl $70
c0103e14:	6a 46                	push   $0x46
  jmp __alltraps
c0103e16:	e9 01 08 00 00       	jmp    c010461c <__alltraps>

c0103e1b <vector71>:
.globl vector71
vector71:
  pushl $0
c0103e1b:	6a 00                	push   $0x0
  pushl $71
c0103e1d:	6a 47                	push   $0x47
  jmp __alltraps
c0103e1f:	e9 f8 07 00 00       	jmp    c010461c <__alltraps>

c0103e24 <vector72>:
.globl vector72
vector72:
  pushl $0
c0103e24:	6a 00                	push   $0x0
  pushl $72
c0103e26:	6a 48                	push   $0x48
  jmp __alltraps
c0103e28:	e9 ef 07 00 00       	jmp    c010461c <__alltraps>

c0103e2d <vector73>:
.globl vector73
vector73:
  pushl $0
c0103e2d:	6a 00                	push   $0x0
  pushl $73
c0103e2f:	6a 49                	push   $0x49
  jmp __alltraps
c0103e31:	e9 e6 07 00 00       	jmp    c010461c <__alltraps>

c0103e36 <vector74>:
.globl vector74
vector74:
  pushl $0
c0103e36:	6a 00                	push   $0x0
  pushl $74
c0103e38:	6a 4a                	push   $0x4a
  jmp __alltraps
c0103e3a:	e9 dd 07 00 00       	jmp    c010461c <__alltraps>

c0103e3f <vector75>:
.globl vector75
vector75:
  pushl $0
c0103e3f:	6a 00                	push   $0x0
  pushl $75
c0103e41:	6a 4b                	push   $0x4b
  jmp __alltraps
c0103e43:	e9 d4 07 00 00       	jmp    c010461c <__alltraps>

c0103e48 <vector76>:
.globl vector76
vector76:
  pushl $0
c0103e48:	6a 00                	push   $0x0
  pushl $76
c0103e4a:	6a 4c                	push   $0x4c
  jmp __alltraps
c0103e4c:	e9 cb 07 00 00       	jmp    c010461c <__alltraps>

c0103e51 <vector77>:
.globl vector77
vector77:
  pushl $0
c0103e51:	6a 00                	push   $0x0
  pushl $77
c0103e53:	6a 4d                	push   $0x4d
  jmp __alltraps
c0103e55:	e9 c2 07 00 00       	jmp    c010461c <__alltraps>

c0103e5a <vector78>:
.globl vector78
vector78:
  pushl $0
c0103e5a:	6a 00                	push   $0x0
  pushl $78
c0103e5c:	6a 4e                	push   $0x4e
  jmp __alltraps
c0103e5e:	e9 b9 07 00 00       	jmp    c010461c <__alltraps>

c0103e63 <vector79>:
.globl vector79
vector79:
  pushl $0
c0103e63:	6a 00                	push   $0x0
  pushl $79
c0103e65:	6a 4f                	push   $0x4f
  jmp __alltraps
c0103e67:	e9 b0 07 00 00       	jmp    c010461c <__alltraps>

c0103e6c <vector80>:
.globl vector80
vector80:
  pushl $0
c0103e6c:	6a 00                	push   $0x0
  pushl $80
c0103e6e:	6a 50                	push   $0x50
  jmp __alltraps
c0103e70:	e9 a7 07 00 00       	jmp    c010461c <__alltraps>

c0103e75 <vector81>:
.globl vector81
vector81:
  pushl $0
c0103e75:	6a 00                	push   $0x0
  pushl $81
c0103e77:	6a 51                	push   $0x51
  jmp __alltraps
c0103e79:	e9 9e 07 00 00       	jmp    c010461c <__alltraps>

c0103e7e <vector82>:
.globl vector82
vector82:
  pushl $0
c0103e7e:	6a 00                	push   $0x0
  pushl $82
c0103e80:	6a 52                	push   $0x52
  jmp __alltraps
c0103e82:	e9 95 07 00 00       	jmp    c010461c <__alltraps>

c0103e87 <vector83>:
.globl vector83
vector83:
  pushl $0
c0103e87:	6a 00                	push   $0x0
  pushl $83
c0103e89:	6a 53                	push   $0x53
  jmp __alltraps
c0103e8b:	e9 8c 07 00 00       	jmp    c010461c <__alltraps>

c0103e90 <vector84>:
.globl vector84
vector84:
  pushl $0
c0103e90:	6a 00                	push   $0x0
  pushl $84
c0103e92:	6a 54                	push   $0x54
  jmp __alltraps
c0103e94:	e9 83 07 00 00       	jmp    c010461c <__alltraps>

c0103e99 <vector85>:
.globl vector85
vector85:
  pushl $0
c0103e99:	6a 00                	push   $0x0
  pushl $85
c0103e9b:	6a 55                	push   $0x55
  jmp __alltraps
c0103e9d:	e9 7a 07 00 00       	jmp    c010461c <__alltraps>

c0103ea2 <vector86>:
.globl vector86
vector86:
  pushl $0
c0103ea2:	6a 00                	push   $0x0
  pushl $86
c0103ea4:	6a 56                	push   $0x56
  jmp __alltraps
c0103ea6:	e9 71 07 00 00       	jmp    c010461c <__alltraps>

c0103eab <vector87>:
.globl vector87
vector87:
  pushl $0
c0103eab:	6a 00                	push   $0x0
  pushl $87
c0103ead:	6a 57                	push   $0x57
  jmp __alltraps
c0103eaf:	e9 68 07 00 00       	jmp    c010461c <__alltraps>

c0103eb4 <vector88>:
.globl vector88
vector88:
  pushl $0
c0103eb4:	6a 00                	push   $0x0
  pushl $88
c0103eb6:	6a 58                	push   $0x58
  jmp __alltraps
c0103eb8:	e9 5f 07 00 00       	jmp    c010461c <__alltraps>

c0103ebd <vector89>:
.globl vector89
vector89:
  pushl $0
c0103ebd:	6a 00                	push   $0x0
  pushl $89
c0103ebf:	6a 59                	push   $0x59
  jmp __alltraps
c0103ec1:	e9 56 07 00 00       	jmp    c010461c <__alltraps>

c0103ec6 <vector90>:
.globl vector90
vector90:
  pushl $0
c0103ec6:	6a 00                	push   $0x0
  pushl $90
c0103ec8:	6a 5a                	push   $0x5a
  jmp __alltraps
c0103eca:	e9 4d 07 00 00       	jmp    c010461c <__alltraps>

c0103ecf <vector91>:
.globl vector91
vector91:
  pushl $0
c0103ecf:	6a 00                	push   $0x0
  pushl $91
c0103ed1:	6a 5b                	push   $0x5b
  jmp __alltraps
c0103ed3:	e9 44 07 00 00       	jmp    c010461c <__alltraps>

c0103ed8 <vector92>:
.globl vector92
vector92:
  pushl $0
c0103ed8:	6a 00                	push   $0x0
  pushl $92
c0103eda:	6a 5c                	push   $0x5c
  jmp __alltraps
c0103edc:	e9 3b 07 00 00       	jmp    c010461c <__alltraps>

c0103ee1 <vector93>:
.globl vector93
vector93:
  pushl $0
c0103ee1:	6a 00                	push   $0x0
  pushl $93
c0103ee3:	6a 5d                	push   $0x5d
  jmp __alltraps
c0103ee5:	e9 32 07 00 00       	jmp    c010461c <__alltraps>

c0103eea <vector94>:
.globl vector94
vector94:
  pushl $0
c0103eea:	6a 00                	push   $0x0
  pushl $94
c0103eec:	6a 5e                	push   $0x5e
  jmp __alltraps
c0103eee:	e9 29 07 00 00       	jmp    c010461c <__alltraps>

c0103ef3 <vector95>:
.globl vector95
vector95:
  pushl $0
c0103ef3:	6a 00                	push   $0x0
  pushl $95
c0103ef5:	6a 5f                	push   $0x5f
  jmp __alltraps
c0103ef7:	e9 20 07 00 00       	jmp    c010461c <__alltraps>

c0103efc <vector96>:
.globl vector96
vector96:
  pushl $0
c0103efc:	6a 00                	push   $0x0
  pushl $96
c0103efe:	6a 60                	push   $0x60
  jmp __alltraps
c0103f00:	e9 17 07 00 00       	jmp    c010461c <__alltraps>

c0103f05 <vector97>:
.globl vector97
vector97:
  pushl $0
c0103f05:	6a 00                	push   $0x0
  pushl $97
c0103f07:	6a 61                	push   $0x61
  jmp __alltraps
c0103f09:	e9 0e 07 00 00       	jmp    c010461c <__alltraps>

c0103f0e <vector98>:
.globl vector98
vector98:
  pushl $0
c0103f0e:	6a 00                	push   $0x0
  pushl $98
c0103f10:	6a 62                	push   $0x62
  jmp __alltraps
c0103f12:	e9 05 07 00 00       	jmp    c010461c <__alltraps>

c0103f17 <vector99>:
.globl vector99
vector99:
  pushl $0
c0103f17:	6a 00                	push   $0x0
  pushl $99
c0103f19:	6a 63                	push   $0x63
  jmp __alltraps
c0103f1b:	e9 fc 06 00 00       	jmp    c010461c <__alltraps>

c0103f20 <vector100>:
.globl vector100
vector100:
  pushl $0
c0103f20:	6a 00                	push   $0x0
  pushl $100
c0103f22:	6a 64                	push   $0x64
  jmp __alltraps
c0103f24:	e9 f3 06 00 00       	jmp    c010461c <__alltraps>

c0103f29 <vector101>:
.globl vector101
vector101:
  pushl $0
c0103f29:	6a 00                	push   $0x0
  pushl $101
c0103f2b:	6a 65                	push   $0x65
  jmp __alltraps
c0103f2d:	e9 ea 06 00 00       	jmp    c010461c <__alltraps>

c0103f32 <vector102>:
.globl vector102
vector102:
  pushl $0
c0103f32:	6a 00                	push   $0x0
  pushl $102
c0103f34:	6a 66                	push   $0x66
  jmp __alltraps
c0103f36:	e9 e1 06 00 00       	jmp    c010461c <__alltraps>

c0103f3b <vector103>:
.globl vector103
vector103:
  pushl $0
c0103f3b:	6a 00                	push   $0x0
  pushl $103
c0103f3d:	6a 67                	push   $0x67
  jmp __alltraps
c0103f3f:	e9 d8 06 00 00       	jmp    c010461c <__alltraps>

c0103f44 <vector104>:
.globl vector104
vector104:
  pushl $0
c0103f44:	6a 00                	push   $0x0
  pushl $104
c0103f46:	6a 68                	push   $0x68
  jmp __alltraps
c0103f48:	e9 cf 06 00 00       	jmp    c010461c <__alltraps>

c0103f4d <vector105>:
.globl vector105
vector105:
  pushl $0
c0103f4d:	6a 00                	push   $0x0
  pushl $105
c0103f4f:	6a 69                	push   $0x69
  jmp __alltraps
c0103f51:	e9 c6 06 00 00       	jmp    c010461c <__alltraps>

c0103f56 <vector106>:
.globl vector106
vector106:
  pushl $0
c0103f56:	6a 00                	push   $0x0
  pushl $106
c0103f58:	6a 6a                	push   $0x6a
  jmp __alltraps
c0103f5a:	e9 bd 06 00 00       	jmp    c010461c <__alltraps>

c0103f5f <vector107>:
.globl vector107
vector107:
  pushl $0
c0103f5f:	6a 00                	push   $0x0
  pushl $107
c0103f61:	6a 6b                	push   $0x6b
  jmp __alltraps
c0103f63:	e9 b4 06 00 00       	jmp    c010461c <__alltraps>

c0103f68 <vector108>:
.globl vector108
vector108:
  pushl $0
c0103f68:	6a 00                	push   $0x0
  pushl $108
c0103f6a:	6a 6c                	push   $0x6c
  jmp __alltraps
c0103f6c:	e9 ab 06 00 00       	jmp    c010461c <__alltraps>

c0103f71 <vector109>:
.globl vector109
vector109:
  pushl $0
c0103f71:	6a 00                	push   $0x0
  pushl $109
c0103f73:	6a 6d                	push   $0x6d
  jmp __alltraps
c0103f75:	e9 a2 06 00 00       	jmp    c010461c <__alltraps>

c0103f7a <vector110>:
.globl vector110
vector110:
  pushl $0
c0103f7a:	6a 00                	push   $0x0
  pushl $110
c0103f7c:	6a 6e                	push   $0x6e
  jmp __alltraps
c0103f7e:	e9 99 06 00 00       	jmp    c010461c <__alltraps>

c0103f83 <vector111>:
.globl vector111
vector111:
  pushl $0
c0103f83:	6a 00                	push   $0x0
  pushl $111
c0103f85:	6a 6f                	push   $0x6f
  jmp __alltraps
c0103f87:	e9 90 06 00 00       	jmp    c010461c <__alltraps>

c0103f8c <vector112>:
.globl vector112
vector112:
  pushl $0
c0103f8c:	6a 00                	push   $0x0
  pushl $112
c0103f8e:	6a 70                	push   $0x70
  jmp __alltraps
c0103f90:	e9 87 06 00 00       	jmp    c010461c <__alltraps>

c0103f95 <vector113>:
.globl vector113
vector113:
  pushl $0
c0103f95:	6a 00                	push   $0x0
  pushl $113
c0103f97:	6a 71                	push   $0x71
  jmp __alltraps
c0103f99:	e9 7e 06 00 00       	jmp    c010461c <__alltraps>

c0103f9e <vector114>:
.globl vector114
vector114:
  pushl $0
c0103f9e:	6a 00                	push   $0x0
  pushl $114
c0103fa0:	6a 72                	push   $0x72
  jmp __alltraps
c0103fa2:	e9 75 06 00 00       	jmp    c010461c <__alltraps>

c0103fa7 <vector115>:
.globl vector115
vector115:
  pushl $0
c0103fa7:	6a 00                	push   $0x0
  pushl $115
c0103fa9:	6a 73                	push   $0x73
  jmp __alltraps
c0103fab:	e9 6c 06 00 00       	jmp    c010461c <__alltraps>

c0103fb0 <vector116>:
.globl vector116
vector116:
  pushl $0
c0103fb0:	6a 00                	push   $0x0
  pushl $116
c0103fb2:	6a 74                	push   $0x74
  jmp __alltraps
c0103fb4:	e9 63 06 00 00       	jmp    c010461c <__alltraps>

c0103fb9 <vector117>:
.globl vector117
vector117:
  pushl $0
c0103fb9:	6a 00                	push   $0x0
  pushl $117
c0103fbb:	6a 75                	push   $0x75
  jmp __alltraps
c0103fbd:	e9 5a 06 00 00       	jmp    c010461c <__alltraps>

c0103fc2 <vector118>:
.globl vector118
vector118:
  pushl $0
c0103fc2:	6a 00                	push   $0x0
  pushl $118
c0103fc4:	6a 76                	push   $0x76
  jmp __alltraps
c0103fc6:	e9 51 06 00 00       	jmp    c010461c <__alltraps>

c0103fcb <vector119>:
.globl vector119
vector119:
  pushl $0
c0103fcb:	6a 00                	push   $0x0
  pushl $119
c0103fcd:	6a 77                	push   $0x77
  jmp __alltraps
c0103fcf:	e9 48 06 00 00       	jmp    c010461c <__alltraps>

c0103fd4 <vector120>:
.globl vector120
vector120:
  pushl $0
c0103fd4:	6a 00                	push   $0x0
  pushl $120
c0103fd6:	6a 78                	push   $0x78
  jmp __alltraps
c0103fd8:	e9 3f 06 00 00       	jmp    c010461c <__alltraps>

c0103fdd <vector121>:
.globl vector121
vector121:
  pushl $0
c0103fdd:	6a 00                	push   $0x0
  pushl $121
c0103fdf:	6a 79                	push   $0x79
  jmp __alltraps
c0103fe1:	e9 36 06 00 00       	jmp    c010461c <__alltraps>

c0103fe6 <vector122>:
.globl vector122
vector122:
  pushl $0
c0103fe6:	6a 00                	push   $0x0
  pushl $122
c0103fe8:	6a 7a                	push   $0x7a
  jmp __alltraps
c0103fea:	e9 2d 06 00 00       	jmp    c010461c <__alltraps>

c0103fef <vector123>:
.globl vector123
vector123:
  pushl $0
c0103fef:	6a 00                	push   $0x0
  pushl $123
c0103ff1:	6a 7b                	push   $0x7b
  jmp __alltraps
c0103ff3:	e9 24 06 00 00       	jmp    c010461c <__alltraps>

c0103ff8 <vector124>:
.globl vector124
vector124:
  pushl $0
c0103ff8:	6a 00                	push   $0x0
  pushl $124
c0103ffa:	6a 7c                	push   $0x7c
  jmp __alltraps
c0103ffc:	e9 1b 06 00 00       	jmp    c010461c <__alltraps>

c0104001 <vector125>:
.globl vector125
vector125:
  pushl $0
c0104001:	6a 00                	push   $0x0
  pushl $125
c0104003:	6a 7d                	push   $0x7d
  jmp __alltraps
c0104005:	e9 12 06 00 00       	jmp    c010461c <__alltraps>

c010400a <vector126>:
.globl vector126
vector126:
  pushl $0
c010400a:	6a 00                	push   $0x0
  pushl $126
c010400c:	6a 7e                	push   $0x7e
  jmp __alltraps
c010400e:	e9 09 06 00 00       	jmp    c010461c <__alltraps>

c0104013 <vector127>:
.globl vector127
vector127:
  pushl $0
c0104013:	6a 00                	push   $0x0
  pushl $127
c0104015:	6a 7f                	push   $0x7f
  jmp __alltraps
c0104017:	e9 00 06 00 00       	jmp    c010461c <__alltraps>

c010401c <vector128>:
.globl vector128
vector128:
  pushl $0
c010401c:	6a 00                	push   $0x0
  pushl $128
c010401e:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c0104023:	e9 f4 05 00 00       	jmp    c010461c <__alltraps>

c0104028 <vector129>:
.globl vector129
vector129:
  pushl $0
c0104028:	6a 00                	push   $0x0
  pushl $129
c010402a:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c010402f:	e9 e8 05 00 00       	jmp    c010461c <__alltraps>

c0104034 <vector130>:
.globl vector130
vector130:
  pushl $0
c0104034:	6a 00                	push   $0x0
  pushl $130
c0104036:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c010403b:	e9 dc 05 00 00       	jmp    c010461c <__alltraps>

c0104040 <vector131>:
.globl vector131
vector131:
  pushl $0
c0104040:	6a 00                	push   $0x0
  pushl $131
c0104042:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c0104047:	e9 d0 05 00 00       	jmp    c010461c <__alltraps>

c010404c <vector132>:
.globl vector132
vector132:
  pushl $0
c010404c:	6a 00                	push   $0x0
  pushl $132
c010404e:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c0104053:	e9 c4 05 00 00       	jmp    c010461c <__alltraps>

c0104058 <vector133>:
.globl vector133
vector133:
  pushl $0
c0104058:	6a 00                	push   $0x0
  pushl $133
c010405a:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c010405f:	e9 b8 05 00 00       	jmp    c010461c <__alltraps>

c0104064 <vector134>:
.globl vector134
vector134:
  pushl $0
c0104064:	6a 00                	push   $0x0
  pushl $134
c0104066:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c010406b:	e9 ac 05 00 00       	jmp    c010461c <__alltraps>

c0104070 <vector135>:
.globl vector135
vector135:
  pushl $0
c0104070:	6a 00                	push   $0x0
  pushl $135
c0104072:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0104077:	e9 a0 05 00 00       	jmp    c010461c <__alltraps>

c010407c <vector136>:
.globl vector136
vector136:
  pushl $0
c010407c:	6a 00                	push   $0x0
  pushl $136
c010407e:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c0104083:	e9 94 05 00 00       	jmp    c010461c <__alltraps>

c0104088 <vector137>:
.globl vector137
vector137:
  pushl $0
c0104088:	6a 00                	push   $0x0
  pushl $137
c010408a:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c010408f:	e9 88 05 00 00       	jmp    c010461c <__alltraps>

c0104094 <vector138>:
.globl vector138
vector138:
  pushl $0
c0104094:	6a 00                	push   $0x0
  pushl $138
c0104096:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c010409b:	e9 7c 05 00 00       	jmp    c010461c <__alltraps>

c01040a0 <vector139>:
.globl vector139
vector139:
  pushl $0
c01040a0:	6a 00                	push   $0x0
  pushl $139
c01040a2:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c01040a7:	e9 70 05 00 00       	jmp    c010461c <__alltraps>

c01040ac <vector140>:
.globl vector140
vector140:
  pushl $0
c01040ac:	6a 00                	push   $0x0
  pushl $140
c01040ae:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c01040b3:	e9 64 05 00 00       	jmp    c010461c <__alltraps>

c01040b8 <vector141>:
.globl vector141
vector141:
  pushl $0
c01040b8:	6a 00                	push   $0x0
  pushl $141
c01040ba:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c01040bf:	e9 58 05 00 00       	jmp    c010461c <__alltraps>

c01040c4 <vector142>:
.globl vector142
vector142:
  pushl $0
c01040c4:	6a 00                	push   $0x0
  pushl $142
c01040c6:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c01040cb:	e9 4c 05 00 00       	jmp    c010461c <__alltraps>

c01040d0 <vector143>:
.globl vector143
vector143:
  pushl $0
c01040d0:	6a 00                	push   $0x0
  pushl $143
c01040d2:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c01040d7:	e9 40 05 00 00       	jmp    c010461c <__alltraps>

c01040dc <vector144>:
.globl vector144
vector144:
  pushl $0
c01040dc:	6a 00                	push   $0x0
  pushl $144
c01040de:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c01040e3:	e9 34 05 00 00       	jmp    c010461c <__alltraps>

c01040e8 <vector145>:
.globl vector145
vector145:
  pushl $0
c01040e8:	6a 00                	push   $0x0
  pushl $145
c01040ea:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c01040ef:	e9 28 05 00 00       	jmp    c010461c <__alltraps>

c01040f4 <vector146>:
.globl vector146
vector146:
  pushl $0
c01040f4:	6a 00                	push   $0x0
  pushl $146
c01040f6:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c01040fb:	e9 1c 05 00 00       	jmp    c010461c <__alltraps>

c0104100 <vector147>:
.globl vector147
vector147:
  pushl $0
c0104100:	6a 00                	push   $0x0
  pushl $147
c0104102:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c0104107:	e9 10 05 00 00       	jmp    c010461c <__alltraps>

c010410c <vector148>:
.globl vector148
vector148:
  pushl $0
c010410c:	6a 00                	push   $0x0
  pushl $148
c010410e:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c0104113:	e9 04 05 00 00       	jmp    c010461c <__alltraps>

c0104118 <vector149>:
.globl vector149
vector149:
  pushl $0
c0104118:	6a 00                	push   $0x0
  pushl $149
c010411a:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c010411f:	e9 f8 04 00 00       	jmp    c010461c <__alltraps>

c0104124 <vector150>:
.globl vector150
vector150:
  pushl $0
c0104124:	6a 00                	push   $0x0
  pushl $150
c0104126:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c010412b:	e9 ec 04 00 00       	jmp    c010461c <__alltraps>

c0104130 <vector151>:
.globl vector151
vector151:
  pushl $0
c0104130:	6a 00                	push   $0x0
  pushl $151
c0104132:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c0104137:	e9 e0 04 00 00       	jmp    c010461c <__alltraps>

c010413c <vector152>:
.globl vector152
vector152:
  pushl $0
c010413c:	6a 00                	push   $0x0
  pushl $152
c010413e:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c0104143:	e9 d4 04 00 00       	jmp    c010461c <__alltraps>

c0104148 <vector153>:
.globl vector153
vector153:
  pushl $0
c0104148:	6a 00                	push   $0x0
  pushl $153
c010414a:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c010414f:	e9 c8 04 00 00       	jmp    c010461c <__alltraps>

c0104154 <vector154>:
.globl vector154
vector154:
  pushl $0
c0104154:	6a 00                	push   $0x0
  pushl $154
c0104156:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c010415b:	e9 bc 04 00 00       	jmp    c010461c <__alltraps>

c0104160 <vector155>:
.globl vector155
vector155:
  pushl $0
c0104160:	6a 00                	push   $0x0
  pushl $155
c0104162:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c0104167:	e9 b0 04 00 00       	jmp    c010461c <__alltraps>

c010416c <vector156>:
.globl vector156
vector156:
  pushl $0
c010416c:	6a 00                	push   $0x0
  pushl $156
c010416e:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c0104173:	e9 a4 04 00 00       	jmp    c010461c <__alltraps>

c0104178 <vector157>:
.globl vector157
vector157:
  pushl $0
c0104178:	6a 00                	push   $0x0
  pushl $157
c010417a:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c010417f:	e9 98 04 00 00       	jmp    c010461c <__alltraps>

c0104184 <vector158>:
.globl vector158
vector158:
  pushl $0
c0104184:	6a 00                	push   $0x0
  pushl $158
c0104186:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c010418b:	e9 8c 04 00 00       	jmp    c010461c <__alltraps>

c0104190 <vector159>:
.globl vector159
vector159:
  pushl $0
c0104190:	6a 00                	push   $0x0
  pushl $159
c0104192:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c0104197:	e9 80 04 00 00       	jmp    c010461c <__alltraps>

c010419c <vector160>:
.globl vector160
vector160:
  pushl $0
c010419c:	6a 00                	push   $0x0
  pushl $160
c010419e:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c01041a3:	e9 74 04 00 00       	jmp    c010461c <__alltraps>

c01041a8 <vector161>:
.globl vector161
vector161:
  pushl $0
c01041a8:	6a 00                	push   $0x0
  pushl $161
c01041aa:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c01041af:	e9 68 04 00 00       	jmp    c010461c <__alltraps>

c01041b4 <vector162>:
.globl vector162
vector162:
  pushl $0
c01041b4:	6a 00                	push   $0x0
  pushl $162
c01041b6:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c01041bb:	e9 5c 04 00 00       	jmp    c010461c <__alltraps>

c01041c0 <vector163>:
.globl vector163
vector163:
  pushl $0
c01041c0:	6a 00                	push   $0x0
  pushl $163
c01041c2:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c01041c7:	e9 50 04 00 00       	jmp    c010461c <__alltraps>

c01041cc <vector164>:
.globl vector164
vector164:
  pushl $0
c01041cc:	6a 00                	push   $0x0
  pushl $164
c01041ce:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c01041d3:	e9 44 04 00 00       	jmp    c010461c <__alltraps>

c01041d8 <vector165>:
.globl vector165
vector165:
  pushl $0
c01041d8:	6a 00                	push   $0x0
  pushl $165
c01041da:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c01041df:	e9 38 04 00 00       	jmp    c010461c <__alltraps>

c01041e4 <vector166>:
.globl vector166
vector166:
  pushl $0
c01041e4:	6a 00                	push   $0x0
  pushl $166
c01041e6:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c01041eb:	e9 2c 04 00 00       	jmp    c010461c <__alltraps>

c01041f0 <vector167>:
.globl vector167
vector167:
  pushl $0
c01041f0:	6a 00                	push   $0x0
  pushl $167
c01041f2:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c01041f7:	e9 20 04 00 00       	jmp    c010461c <__alltraps>

c01041fc <vector168>:
.globl vector168
vector168:
  pushl $0
c01041fc:	6a 00                	push   $0x0
  pushl $168
c01041fe:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c0104203:	e9 14 04 00 00       	jmp    c010461c <__alltraps>

c0104208 <vector169>:
.globl vector169
vector169:
  pushl $0
c0104208:	6a 00                	push   $0x0
  pushl $169
c010420a:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c010420f:	e9 08 04 00 00       	jmp    c010461c <__alltraps>

c0104214 <vector170>:
.globl vector170
vector170:
  pushl $0
c0104214:	6a 00                	push   $0x0
  pushl $170
c0104216:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c010421b:	e9 fc 03 00 00       	jmp    c010461c <__alltraps>

c0104220 <vector171>:
.globl vector171
vector171:
  pushl $0
c0104220:	6a 00                	push   $0x0
  pushl $171
c0104222:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c0104227:	e9 f0 03 00 00       	jmp    c010461c <__alltraps>

c010422c <vector172>:
.globl vector172
vector172:
  pushl $0
c010422c:	6a 00                	push   $0x0
  pushl $172
c010422e:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c0104233:	e9 e4 03 00 00       	jmp    c010461c <__alltraps>

c0104238 <vector173>:
.globl vector173
vector173:
  pushl $0
c0104238:	6a 00                	push   $0x0
  pushl $173
c010423a:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c010423f:	e9 d8 03 00 00       	jmp    c010461c <__alltraps>

c0104244 <vector174>:
.globl vector174
vector174:
  pushl $0
c0104244:	6a 00                	push   $0x0
  pushl $174
c0104246:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c010424b:	e9 cc 03 00 00       	jmp    c010461c <__alltraps>

c0104250 <vector175>:
.globl vector175
vector175:
  pushl $0
c0104250:	6a 00                	push   $0x0
  pushl $175
c0104252:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c0104257:	e9 c0 03 00 00       	jmp    c010461c <__alltraps>

c010425c <vector176>:
.globl vector176
vector176:
  pushl $0
c010425c:	6a 00                	push   $0x0
  pushl $176
c010425e:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c0104263:	e9 b4 03 00 00       	jmp    c010461c <__alltraps>

c0104268 <vector177>:
.globl vector177
vector177:
  pushl $0
c0104268:	6a 00                	push   $0x0
  pushl $177
c010426a:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c010426f:	e9 a8 03 00 00       	jmp    c010461c <__alltraps>

c0104274 <vector178>:
.globl vector178
vector178:
  pushl $0
c0104274:	6a 00                	push   $0x0
  pushl $178
c0104276:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c010427b:	e9 9c 03 00 00       	jmp    c010461c <__alltraps>

c0104280 <vector179>:
.globl vector179
vector179:
  pushl $0
c0104280:	6a 00                	push   $0x0
  pushl $179
c0104282:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c0104287:	e9 90 03 00 00       	jmp    c010461c <__alltraps>

c010428c <vector180>:
.globl vector180
vector180:
  pushl $0
c010428c:	6a 00                	push   $0x0
  pushl $180
c010428e:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c0104293:	e9 84 03 00 00       	jmp    c010461c <__alltraps>

c0104298 <vector181>:
.globl vector181
vector181:
  pushl $0
c0104298:	6a 00                	push   $0x0
  pushl $181
c010429a:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c010429f:	e9 78 03 00 00       	jmp    c010461c <__alltraps>

c01042a4 <vector182>:
.globl vector182
vector182:
  pushl $0
c01042a4:	6a 00                	push   $0x0
  pushl $182
c01042a6:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c01042ab:	e9 6c 03 00 00       	jmp    c010461c <__alltraps>

c01042b0 <vector183>:
.globl vector183
vector183:
  pushl $0
c01042b0:	6a 00                	push   $0x0
  pushl $183
c01042b2:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c01042b7:	e9 60 03 00 00       	jmp    c010461c <__alltraps>

c01042bc <vector184>:
.globl vector184
vector184:
  pushl $0
c01042bc:	6a 00                	push   $0x0
  pushl $184
c01042be:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c01042c3:	e9 54 03 00 00       	jmp    c010461c <__alltraps>

c01042c8 <vector185>:
.globl vector185
vector185:
  pushl $0
c01042c8:	6a 00                	push   $0x0
  pushl $185
c01042ca:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c01042cf:	e9 48 03 00 00       	jmp    c010461c <__alltraps>

c01042d4 <vector186>:
.globl vector186
vector186:
  pushl $0
c01042d4:	6a 00                	push   $0x0
  pushl $186
c01042d6:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c01042db:	e9 3c 03 00 00       	jmp    c010461c <__alltraps>

c01042e0 <vector187>:
.globl vector187
vector187:
  pushl $0
c01042e0:	6a 00                	push   $0x0
  pushl $187
c01042e2:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c01042e7:	e9 30 03 00 00       	jmp    c010461c <__alltraps>

c01042ec <vector188>:
.globl vector188
vector188:
  pushl $0
c01042ec:	6a 00                	push   $0x0
  pushl $188
c01042ee:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c01042f3:	e9 24 03 00 00       	jmp    c010461c <__alltraps>

c01042f8 <vector189>:
.globl vector189
vector189:
  pushl $0
c01042f8:	6a 00                	push   $0x0
  pushl $189
c01042fa:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c01042ff:	e9 18 03 00 00       	jmp    c010461c <__alltraps>

c0104304 <vector190>:
.globl vector190
vector190:
  pushl $0
c0104304:	6a 00                	push   $0x0
  pushl $190
c0104306:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c010430b:	e9 0c 03 00 00       	jmp    c010461c <__alltraps>

c0104310 <vector191>:
.globl vector191
vector191:
  pushl $0
c0104310:	6a 00                	push   $0x0
  pushl $191
c0104312:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c0104317:	e9 00 03 00 00       	jmp    c010461c <__alltraps>

c010431c <vector192>:
.globl vector192
vector192:
  pushl $0
c010431c:	6a 00                	push   $0x0
  pushl $192
c010431e:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c0104323:	e9 f4 02 00 00       	jmp    c010461c <__alltraps>

c0104328 <vector193>:
.globl vector193
vector193:
  pushl $0
c0104328:	6a 00                	push   $0x0
  pushl $193
c010432a:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c010432f:	e9 e8 02 00 00       	jmp    c010461c <__alltraps>

c0104334 <vector194>:
.globl vector194
vector194:
  pushl $0
c0104334:	6a 00                	push   $0x0
  pushl $194
c0104336:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c010433b:	e9 dc 02 00 00       	jmp    c010461c <__alltraps>

c0104340 <vector195>:
.globl vector195
vector195:
  pushl $0
c0104340:	6a 00                	push   $0x0
  pushl $195
c0104342:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c0104347:	e9 d0 02 00 00       	jmp    c010461c <__alltraps>

c010434c <vector196>:
.globl vector196
vector196:
  pushl $0
c010434c:	6a 00                	push   $0x0
  pushl $196
c010434e:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c0104353:	e9 c4 02 00 00       	jmp    c010461c <__alltraps>

c0104358 <vector197>:
.globl vector197
vector197:
  pushl $0
c0104358:	6a 00                	push   $0x0
  pushl $197
c010435a:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c010435f:	e9 b8 02 00 00       	jmp    c010461c <__alltraps>

c0104364 <vector198>:
.globl vector198
vector198:
  pushl $0
c0104364:	6a 00                	push   $0x0
  pushl $198
c0104366:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c010436b:	e9 ac 02 00 00       	jmp    c010461c <__alltraps>

c0104370 <vector199>:
.globl vector199
vector199:
  pushl $0
c0104370:	6a 00                	push   $0x0
  pushl $199
c0104372:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c0104377:	e9 a0 02 00 00       	jmp    c010461c <__alltraps>

c010437c <vector200>:
.globl vector200
vector200:
  pushl $0
c010437c:	6a 00                	push   $0x0
  pushl $200
c010437e:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c0104383:	e9 94 02 00 00       	jmp    c010461c <__alltraps>

c0104388 <vector201>:
.globl vector201
vector201:
  pushl $0
c0104388:	6a 00                	push   $0x0
  pushl $201
c010438a:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c010438f:	e9 88 02 00 00       	jmp    c010461c <__alltraps>

c0104394 <vector202>:
.globl vector202
vector202:
  pushl $0
c0104394:	6a 00                	push   $0x0
  pushl $202
c0104396:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c010439b:	e9 7c 02 00 00       	jmp    c010461c <__alltraps>

c01043a0 <vector203>:
.globl vector203
vector203:
  pushl $0
c01043a0:	6a 00                	push   $0x0
  pushl $203
c01043a2:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c01043a7:	e9 70 02 00 00       	jmp    c010461c <__alltraps>

c01043ac <vector204>:
.globl vector204
vector204:
  pushl $0
c01043ac:	6a 00                	push   $0x0
  pushl $204
c01043ae:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c01043b3:	e9 64 02 00 00       	jmp    c010461c <__alltraps>

c01043b8 <vector205>:
.globl vector205
vector205:
  pushl $0
c01043b8:	6a 00                	push   $0x0
  pushl $205
c01043ba:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c01043bf:	e9 58 02 00 00       	jmp    c010461c <__alltraps>

c01043c4 <vector206>:
.globl vector206
vector206:
  pushl $0
c01043c4:	6a 00                	push   $0x0
  pushl $206
c01043c6:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c01043cb:	e9 4c 02 00 00       	jmp    c010461c <__alltraps>

c01043d0 <vector207>:
.globl vector207
vector207:
  pushl $0
c01043d0:	6a 00                	push   $0x0
  pushl $207
c01043d2:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c01043d7:	e9 40 02 00 00       	jmp    c010461c <__alltraps>

c01043dc <vector208>:
.globl vector208
vector208:
  pushl $0
c01043dc:	6a 00                	push   $0x0
  pushl $208
c01043de:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c01043e3:	e9 34 02 00 00       	jmp    c010461c <__alltraps>

c01043e8 <vector209>:
.globl vector209
vector209:
  pushl $0
c01043e8:	6a 00                	push   $0x0
  pushl $209
c01043ea:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c01043ef:	e9 28 02 00 00       	jmp    c010461c <__alltraps>

c01043f4 <vector210>:
.globl vector210
vector210:
  pushl $0
c01043f4:	6a 00                	push   $0x0
  pushl $210
c01043f6:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c01043fb:	e9 1c 02 00 00       	jmp    c010461c <__alltraps>

c0104400 <vector211>:
.globl vector211
vector211:
  pushl $0
c0104400:	6a 00                	push   $0x0
  pushl $211
c0104402:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c0104407:	e9 10 02 00 00       	jmp    c010461c <__alltraps>

c010440c <vector212>:
.globl vector212
vector212:
  pushl $0
c010440c:	6a 00                	push   $0x0
  pushl $212
c010440e:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c0104413:	e9 04 02 00 00       	jmp    c010461c <__alltraps>

c0104418 <vector213>:
.globl vector213
vector213:
  pushl $0
c0104418:	6a 00                	push   $0x0
  pushl $213
c010441a:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c010441f:	e9 f8 01 00 00       	jmp    c010461c <__alltraps>

c0104424 <vector214>:
.globl vector214
vector214:
  pushl $0
c0104424:	6a 00                	push   $0x0
  pushl $214
c0104426:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c010442b:	e9 ec 01 00 00       	jmp    c010461c <__alltraps>

c0104430 <vector215>:
.globl vector215
vector215:
  pushl $0
c0104430:	6a 00                	push   $0x0
  pushl $215
c0104432:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c0104437:	e9 e0 01 00 00       	jmp    c010461c <__alltraps>

c010443c <vector216>:
.globl vector216
vector216:
  pushl $0
c010443c:	6a 00                	push   $0x0
  pushl $216
c010443e:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c0104443:	e9 d4 01 00 00       	jmp    c010461c <__alltraps>

c0104448 <vector217>:
.globl vector217
vector217:
  pushl $0
c0104448:	6a 00                	push   $0x0
  pushl $217
c010444a:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c010444f:	e9 c8 01 00 00       	jmp    c010461c <__alltraps>

c0104454 <vector218>:
.globl vector218
vector218:
  pushl $0
c0104454:	6a 00                	push   $0x0
  pushl $218
c0104456:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c010445b:	e9 bc 01 00 00       	jmp    c010461c <__alltraps>

c0104460 <vector219>:
.globl vector219
vector219:
  pushl $0
c0104460:	6a 00                	push   $0x0
  pushl $219
c0104462:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c0104467:	e9 b0 01 00 00       	jmp    c010461c <__alltraps>

c010446c <vector220>:
.globl vector220
vector220:
  pushl $0
c010446c:	6a 00                	push   $0x0
  pushl $220
c010446e:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c0104473:	e9 a4 01 00 00       	jmp    c010461c <__alltraps>

c0104478 <vector221>:
.globl vector221
vector221:
  pushl $0
c0104478:	6a 00                	push   $0x0
  pushl $221
c010447a:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c010447f:	e9 98 01 00 00       	jmp    c010461c <__alltraps>

c0104484 <vector222>:
.globl vector222
vector222:
  pushl $0
c0104484:	6a 00                	push   $0x0
  pushl $222
c0104486:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c010448b:	e9 8c 01 00 00       	jmp    c010461c <__alltraps>

c0104490 <vector223>:
.globl vector223
vector223:
  pushl $0
c0104490:	6a 00                	push   $0x0
  pushl $223
c0104492:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c0104497:	e9 80 01 00 00       	jmp    c010461c <__alltraps>

c010449c <vector224>:
.globl vector224
vector224:
  pushl $0
c010449c:	6a 00                	push   $0x0
  pushl $224
c010449e:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c01044a3:	e9 74 01 00 00       	jmp    c010461c <__alltraps>

c01044a8 <vector225>:
.globl vector225
vector225:
  pushl $0
c01044a8:	6a 00                	push   $0x0
  pushl $225
c01044aa:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c01044af:	e9 68 01 00 00       	jmp    c010461c <__alltraps>

c01044b4 <vector226>:
.globl vector226
vector226:
  pushl $0
c01044b4:	6a 00                	push   $0x0
  pushl $226
c01044b6:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c01044bb:	e9 5c 01 00 00       	jmp    c010461c <__alltraps>

c01044c0 <vector227>:
.globl vector227
vector227:
  pushl $0
c01044c0:	6a 00                	push   $0x0
  pushl $227
c01044c2:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c01044c7:	e9 50 01 00 00       	jmp    c010461c <__alltraps>

c01044cc <vector228>:
.globl vector228
vector228:
  pushl $0
c01044cc:	6a 00                	push   $0x0
  pushl $228
c01044ce:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c01044d3:	e9 44 01 00 00       	jmp    c010461c <__alltraps>

c01044d8 <vector229>:
.globl vector229
vector229:
  pushl $0
c01044d8:	6a 00                	push   $0x0
  pushl $229
c01044da:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c01044df:	e9 38 01 00 00       	jmp    c010461c <__alltraps>

c01044e4 <vector230>:
.globl vector230
vector230:
  pushl $0
c01044e4:	6a 00                	push   $0x0
  pushl $230
c01044e6:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c01044eb:	e9 2c 01 00 00       	jmp    c010461c <__alltraps>

c01044f0 <vector231>:
.globl vector231
vector231:
  pushl $0
c01044f0:	6a 00                	push   $0x0
  pushl $231
c01044f2:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c01044f7:	e9 20 01 00 00       	jmp    c010461c <__alltraps>

c01044fc <vector232>:
.globl vector232
vector232:
  pushl $0
c01044fc:	6a 00                	push   $0x0
  pushl $232
c01044fe:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c0104503:	e9 14 01 00 00       	jmp    c010461c <__alltraps>

c0104508 <vector233>:
.globl vector233
vector233:
  pushl $0
c0104508:	6a 00                	push   $0x0
  pushl $233
c010450a:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c010450f:	e9 08 01 00 00       	jmp    c010461c <__alltraps>

c0104514 <vector234>:
.globl vector234
vector234:
  pushl $0
c0104514:	6a 00                	push   $0x0
  pushl $234
c0104516:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c010451b:	e9 fc 00 00 00       	jmp    c010461c <__alltraps>

c0104520 <vector235>:
.globl vector235
vector235:
  pushl $0
c0104520:	6a 00                	push   $0x0
  pushl $235
c0104522:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c0104527:	e9 f0 00 00 00       	jmp    c010461c <__alltraps>

c010452c <vector236>:
.globl vector236
vector236:
  pushl $0
c010452c:	6a 00                	push   $0x0
  pushl $236
c010452e:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c0104533:	e9 e4 00 00 00       	jmp    c010461c <__alltraps>

c0104538 <vector237>:
.globl vector237
vector237:
  pushl $0
c0104538:	6a 00                	push   $0x0
  pushl $237
c010453a:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c010453f:	e9 d8 00 00 00       	jmp    c010461c <__alltraps>

c0104544 <vector238>:
.globl vector238
vector238:
  pushl $0
c0104544:	6a 00                	push   $0x0
  pushl $238
c0104546:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c010454b:	e9 cc 00 00 00       	jmp    c010461c <__alltraps>

c0104550 <vector239>:
.globl vector239
vector239:
  pushl $0
c0104550:	6a 00                	push   $0x0
  pushl $239
c0104552:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c0104557:	e9 c0 00 00 00       	jmp    c010461c <__alltraps>

c010455c <vector240>:
.globl vector240
vector240:
  pushl $0
c010455c:	6a 00                	push   $0x0
  pushl $240
c010455e:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c0104563:	e9 b4 00 00 00       	jmp    c010461c <__alltraps>

c0104568 <vector241>:
.globl vector241
vector241:
  pushl $0
c0104568:	6a 00                	push   $0x0
  pushl $241
c010456a:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c010456f:	e9 a8 00 00 00       	jmp    c010461c <__alltraps>

c0104574 <vector242>:
.globl vector242
vector242:
  pushl $0
c0104574:	6a 00                	push   $0x0
  pushl $242
c0104576:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c010457b:	e9 9c 00 00 00       	jmp    c010461c <__alltraps>

c0104580 <vector243>:
.globl vector243
vector243:
  pushl $0
c0104580:	6a 00                	push   $0x0
  pushl $243
c0104582:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c0104587:	e9 90 00 00 00       	jmp    c010461c <__alltraps>

c010458c <vector244>:
.globl vector244
vector244:
  pushl $0
c010458c:	6a 00                	push   $0x0
  pushl $244
c010458e:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c0104593:	e9 84 00 00 00       	jmp    c010461c <__alltraps>

c0104598 <vector245>:
.globl vector245
vector245:
  pushl $0
c0104598:	6a 00                	push   $0x0
  pushl $245
c010459a:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c010459f:	e9 78 00 00 00       	jmp    c010461c <__alltraps>

c01045a4 <vector246>:
.globl vector246
vector246:
  pushl $0
c01045a4:	6a 00                	push   $0x0
  pushl $246
c01045a6:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c01045ab:	e9 6c 00 00 00       	jmp    c010461c <__alltraps>

c01045b0 <vector247>:
.globl vector247
vector247:
  pushl $0
c01045b0:	6a 00                	push   $0x0
  pushl $247
c01045b2:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c01045b7:	e9 60 00 00 00       	jmp    c010461c <__alltraps>

c01045bc <vector248>:
.globl vector248
vector248:
  pushl $0
c01045bc:	6a 00                	push   $0x0
  pushl $248
c01045be:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c01045c3:	e9 54 00 00 00       	jmp    c010461c <__alltraps>

c01045c8 <vector249>:
.globl vector249
vector249:
  pushl $0
c01045c8:	6a 00                	push   $0x0
  pushl $249
c01045ca:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c01045cf:	e9 48 00 00 00       	jmp    c010461c <__alltraps>

c01045d4 <vector250>:
.globl vector250
vector250:
  pushl $0
c01045d4:	6a 00                	push   $0x0
  pushl $250
c01045d6:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c01045db:	e9 3c 00 00 00       	jmp    c010461c <__alltraps>

c01045e0 <vector251>:
.globl vector251
vector251:
  pushl $0
c01045e0:	6a 00                	push   $0x0
  pushl $251
c01045e2:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c01045e7:	e9 30 00 00 00       	jmp    c010461c <__alltraps>

c01045ec <vector252>:
.globl vector252
vector252:
  pushl $0
c01045ec:	6a 00                	push   $0x0
  pushl $252
c01045ee:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c01045f3:	e9 24 00 00 00       	jmp    c010461c <__alltraps>

c01045f8 <vector253>:
.globl vector253
vector253:
  pushl $0
c01045f8:	6a 00                	push   $0x0
  pushl $253
c01045fa:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c01045ff:	e9 18 00 00 00       	jmp    c010461c <__alltraps>

c0104604 <vector254>:
.globl vector254
vector254:
  pushl $0
c0104604:	6a 00                	push   $0x0
  pushl $254
c0104606:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c010460b:	e9 0c 00 00 00       	jmp    c010461c <__alltraps>

c0104610 <vector255>:
.globl vector255
vector255:
  pushl $0
c0104610:	6a 00                	push   $0x0
  pushl $255
c0104612:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c0104617:	e9 00 00 00 00       	jmp    c010461c <__alltraps>

c010461c <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c010461c:	1e                   	push   %ds
    pushl %es
c010461d:	06                   	push   %es
    pushl %fs
c010461e:	0f a0                	push   %fs
    pushl %gs
c0104620:	0f a8                	push   %gs
    pushal
c0104622:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0104623:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c0104628:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c010462a:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c010462c:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c010462d:	e8 5f f5 ff ff       	call   c0103b91 <trap>

    # pop the pushed stack pointer
    popl %esp
c0104632:	5c                   	pop    %esp

c0104633 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0104633:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0104634:	0f a9                	pop    %gs
    popl %fs
c0104636:	0f a1                	pop    %fs
    popl %es
c0104638:	07                   	pop    %es
    popl %ds
c0104639:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c010463a:	83 c4 08             	add    $0x8,%esp
    iret
c010463d:	cf                   	iret   

c010463e <forkrets>:

.globl forkrets
forkrets:
    # set stack to this new process's trapframe
    movl 4(%esp), %esp
c010463e:	8b 64 24 04          	mov    0x4(%esp),%esp
    jmp __trapret
c0104642:	eb ef                	jmp    c0104633 <__trapret>

c0104644 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0104644:	55                   	push   %ebp
c0104645:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0104647:	a1 60 10 13 c0       	mov    0xc0131060,%eax
c010464c:	8b 55 08             	mov    0x8(%ebp),%edx
c010464f:	29 c2                	sub    %eax,%edx
c0104651:	89 d0                	mov    %edx,%eax
c0104653:	c1 f8 02             	sar    $0x2,%eax
c0104656:	69 c0 39 8e e3 38    	imul   $0x38e38e39,%eax,%eax
}
c010465c:	5d                   	pop    %ebp
c010465d:	c3                   	ret    

c010465e <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c010465e:	55                   	push   %ebp
c010465f:	89 e5                	mov    %esp,%ebp
    return page2ppn(page) << PGSHIFT;
c0104661:	ff 75 08             	pushl  0x8(%ebp)
c0104664:	e8 db ff ff ff       	call   c0104644 <page2ppn>
c0104669:	83 c4 04             	add    $0x4,%esp
c010466c:	c1 e0 0c             	shl    $0xc,%eax
}
c010466f:	c9                   	leave  
c0104670:	c3                   	ret    

c0104671 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c0104671:	55                   	push   %ebp
c0104672:	89 e5                	mov    %esp,%ebp
c0104674:	83 ec 08             	sub    $0x8,%esp
    if (PPN(pa) >= npage) {
c0104677:	8b 45 08             	mov    0x8(%ebp),%eax
c010467a:	c1 e8 0c             	shr    $0xc,%eax
c010467d:	89 c2                	mov    %eax,%edx
c010467f:	a1 80 ef 12 c0       	mov    0xc012ef80,%eax
c0104684:	39 c2                	cmp    %eax,%edx
c0104686:	72 14                	jb     c010469c <pa2page+0x2b>
        panic("pa2page called with invalid pa");
c0104688:	83 ec 04             	sub    $0x4,%esp
c010468b:	68 50 b7 10 c0       	push   $0xc010b750
c0104690:	6a 5f                	push   $0x5f
c0104692:	68 6f b7 10 c0       	push   $0xc010b76f
c0104697:	e8 52 d1 ff ff       	call   c01017ee <__panic>
    }
    return &pages[PPN(pa)];
c010469c:	8b 0d 60 10 13 c0    	mov    0xc0131060,%ecx
c01046a2:	8b 45 08             	mov    0x8(%ebp),%eax
c01046a5:	c1 e8 0c             	shr    $0xc,%eax
c01046a8:	89 c2                	mov    %eax,%edx
c01046aa:	89 d0                	mov    %edx,%eax
c01046ac:	c1 e0 03             	shl    $0x3,%eax
c01046af:	01 d0                	add    %edx,%eax
c01046b1:	c1 e0 02             	shl    $0x2,%eax
c01046b4:	01 c8                	add    %ecx,%eax
}
c01046b6:	c9                   	leave  
c01046b7:	c3                   	ret    

c01046b8 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c01046b8:	55                   	push   %ebp
c01046b9:	89 e5                	mov    %esp,%ebp
c01046bb:	83 ec 18             	sub    $0x18,%esp
    return KADDR(page2pa(page));
c01046be:	ff 75 08             	pushl  0x8(%ebp)
c01046c1:	e8 98 ff ff ff       	call   c010465e <page2pa>
c01046c6:	83 c4 04             	add    $0x4,%esp
c01046c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01046cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046cf:	c1 e8 0c             	shr    $0xc,%eax
c01046d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01046d5:	a1 80 ef 12 c0       	mov    0xc012ef80,%eax
c01046da:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01046dd:	72 14                	jb     c01046f3 <page2kva+0x3b>
c01046df:	ff 75 f4             	pushl  -0xc(%ebp)
c01046e2:	68 80 b7 10 c0       	push   $0xc010b780
c01046e7:	6a 66                	push   $0x66
c01046e9:	68 6f b7 10 c0       	push   $0xc010b76f
c01046ee:	e8 fb d0 ff ff       	call   c01017ee <__panic>
c01046f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046f6:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c01046fb:	c9                   	leave  
c01046fc:	c3                   	ret    

c01046fd <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c01046fd:	55                   	push   %ebp
c01046fe:	89 e5                	mov    %esp,%ebp
c0104700:	83 ec 08             	sub    $0x8,%esp
    if (!(pte & PTE_P)) {
c0104703:	8b 45 08             	mov    0x8(%ebp),%eax
c0104706:	83 e0 01             	and    $0x1,%eax
c0104709:	85 c0                	test   %eax,%eax
c010470b:	75 14                	jne    c0104721 <pte2page+0x24>
        panic("pte2page called with invalid pte");
c010470d:	83 ec 04             	sub    $0x4,%esp
c0104710:	68 a4 b7 10 c0       	push   $0xc010b7a4
c0104715:	6a 71                	push   $0x71
c0104717:	68 6f b7 10 c0       	push   $0xc010b76f
c010471c:	e8 cd d0 ff ff       	call   c01017ee <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c0104721:	8b 45 08             	mov    0x8(%ebp),%eax
c0104724:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104729:	83 ec 0c             	sub    $0xc,%esp
c010472c:	50                   	push   %eax
c010472d:	e8 3f ff ff ff       	call   c0104671 <pa2page>
c0104732:	83 c4 10             	add    $0x10,%esp
}
c0104735:	c9                   	leave  
c0104736:	c3                   	ret    

c0104737 <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
c0104737:	55                   	push   %ebp
c0104738:	89 e5                	mov    %esp,%ebp
c010473a:	83 ec 08             	sub    $0x8,%esp
    return pa2page(PDE_ADDR(pde));
c010473d:	8b 45 08             	mov    0x8(%ebp),%eax
c0104740:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104745:	83 ec 0c             	sub    $0xc,%esp
c0104748:	50                   	push   %eax
c0104749:	e8 23 ff ff ff       	call   c0104671 <pa2page>
c010474e:	83 c4 10             	add    $0x10,%esp
}
c0104751:	c9                   	leave  
c0104752:	c3                   	ret    

c0104753 <page_ref>:

static inline int
page_ref(struct Page *page) {
c0104753:	55                   	push   %ebp
c0104754:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0104756:	8b 45 08             	mov    0x8(%ebp),%eax
c0104759:	8b 00                	mov    (%eax),%eax
}
c010475b:	5d                   	pop    %ebp
c010475c:	c3                   	ret    

c010475d <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c010475d:	55                   	push   %ebp
c010475e:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0104760:	8b 45 08             	mov    0x8(%ebp),%eax
c0104763:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104766:	89 10                	mov    %edx,(%eax)
}
c0104768:	90                   	nop
c0104769:	5d                   	pop    %ebp
c010476a:	c3                   	ret    

c010476b <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c010476b:	55                   	push   %ebp
c010476c:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c010476e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104771:	8b 00                	mov    (%eax),%eax
c0104773:	8d 50 01             	lea    0x1(%eax),%edx
c0104776:	8b 45 08             	mov    0x8(%ebp),%eax
c0104779:	89 10                	mov    %edx,(%eax)
    return page->ref;
c010477b:	8b 45 08             	mov    0x8(%ebp),%eax
c010477e:	8b 00                	mov    (%eax),%eax
}
c0104780:	5d                   	pop    %ebp
c0104781:	c3                   	ret    

c0104782 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c0104782:	55                   	push   %ebp
c0104783:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c0104785:	8b 45 08             	mov    0x8(%ebp),%eax
c0104788:	8b 00                	mov    (%eax),%eax
c010478a:	8d 50 ff             	lea    -0x1(%eax),%edx
c010478d:	8b 45 08             	mov    0x8(%ebp),%eax
c0104790:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0104792:	8b 45 08             	mov    0x8(%ebp),%eax
c0104795:	8b 00                	mov    (%eax),%eax
}
c0104797:	5d                   	pop    %ebp
c0104798:	c3                   	ret    

c0104799 <__intr_save>:
__intr_save(void) {
c0104799:	55                   	push   %ebp
c010479a:	89 e5                	mov    %esp,%ebp
c010479c:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c010479f:	9c                   	pushf  
c01047a0:	58                   	pop    %eax
c01047a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c01047a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c01047a7:	25 00 02 00 00       	and    $0x200,%eax
c01047ac:	85 c0                	test   %eax,%eax
c01047ae:	74 0c                	je     c01047bc <__intr_save+0x23>
        intr_disable();
c01047b0:	e8 77 ed ff ff       	call   c010352c <intr_disable>
        return 1;
c01047b5:	b8 01 00 00 00       	mov    $0x1,%eax
c01047ba:	eb 05                	jmp    c01047c1 <__intr_save+0x28>
    return 0;
c01047bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01047c1:	c9                   	leave  
c01047c2:	c3                   	ret    

c01047c3 <__intr_restore>:
__intr_restore(bool flag) {
c01047c3:	55                   	push   %ebp
c01047c4:	89 e5                	mov    %esp,%ebp
c01047c6:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c01047c9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01047cd:	74 05                	je     c01047d4 <__intr_restore+0x11>
        intr_enable();
c01047cf:	e8 4c ed ff ff       	call   c0103520 <intr_enable>
}
c01047d4:	90                   	nop
c01047d5:	c9                   	leave  
c01047d6:	c3                   	ret    

c01047d7 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c01047d7:	55                   	push   %ebp
c01047d8:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c01047da:	8b 45 08             	mov    0x8(%ebp),%eax
c01047dd:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c01047e0:	b8 23 00 00 00       	mov    $0x23,%eax
c01047e5:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c01047e7:	b8 23 00 00 00       	mov    $0x23,%eax
c01047ec:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c01047ee:	b8 10 00 00 00       	mov    $0x10,%eax
c01047f3:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c01047f5:	b8 10 00 00 00       	mov    $0x10,%eax
c01047fa:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c01047fc:	b8 10 00 00 00       	mov    $0x10,%eax
c0104801:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0104803:	ea 0a 48 10 c0 08 00 	ljmp   $0x8,$0xc010480a
}
c010480a:	90                   	nop
c010480b:	5d                   	pop    %ebp
c010480c:	c3                   	ret    

c010480d <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c010480d:	f3 0f 1e fb          	endbr32 
c0104811:	55                   	push   %ebp
c0104812:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0104814:	8b 45 08             	mov    0x8(%ebp),%eax
c0104817:	a3 a4 ef 12 c0       	mov    %eax,0xc012efa4
}
c010481c:	90                   	nop
c010481d:	5d                   	pop    %ebp
c010481e:	c3                   	ret    

c010481f <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c010481f:	f3 0f 1e fb          	endbr32 
c0104823:	55                   	push   %ebp
c0104824:	89 e5                	mov    %esp,%ebp
c0104826:	83 ec 10             	sub    $0x10,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0104829:	b8 00 b0 12 c0       	mov    $0xc012b000,%eax
c010482e:	50                   	push   %eax
c010482f:	e8 d9 ff ff ff       	call   c010480d <load_esp0>
c0104834:	83 c4 04             	add    $0x4,%esp
    ts.ts_ss0 = KERNEL_DS;
c0104837:	66 c7 05 a8 ef 12 c0 	movw   $0x10,0xc012efa8
c010483e:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0104840:	66 c7 05 28 ba 12 c0 	movw   $0x68,0xc012ba28
c0104847:	68 00 
c0104849:	b8 a0 ef 12 c0       	mov    $0xc012efa0,%eax
c010484e:	66 a3 2a ba 12 c0    	mov    %ax,0xc012ba2a
c0104854:	b8 a0 ef 12 c0       	mov    $0xc012efa0,%eax
c0104859:	c1 e8 10             	shr    $0x10,%eax
c010485c:	a2 2c ba 12 c0       	mov    %al,0xc012ba2c
c0104861:	0f b6 05 2d ba 12 c0 	movzbl 0xc012ba2d,%eax
c0104868:	83 e0 f0             	and    $0xfffffff0,%eax
c010486b:	83 c8 09             	or     $0x9,%eax
c010486e:	a2 2d ba 12 c0       	mov    %al,0xc012ba2d
c0104873:	0f b6 05 2d ba 12 c0 	movzbl 0xc012ba2d,%eax
c010487a:	83 e0 ef             	and    $0xffffffef,%eax
c010487d:	a2 2d ba 12 c0       	mov    %al,0xc012ba2d
c0104882:	0f b6 05 2d ba 12 c0 	movzbl 0xc012ba2d,%eax
c0104889:	83 e0 9f             	and    $0xffffff9f,%eax
c010488c:	a2 2d ba 12 c0       	mov    %al,0xc012ba2d
c0104891:	0f b6 05 2d ba 12 c0 	movzbl 0xc012ba2d,%eax
c0104898:	83 c8 80             	or     $0xffffff80,%eax
c010489b:	a2 2d ba 12 c0       	mov    %al,0xc012ba2d
c01048a0:	0f b6 05 2e ba 12 c0 	movzbl 0xc012ba2e,%eax
c01048a7:	83 e0 f0             	and    $0xfffffff0,%eax
c01048aa:	a2 2e ba 12 c0       	mov    %al,0xc012ba2e
c01048af:	0f b6 05 2e ba 12 c0 	movzbl 0xc012ba2e,%eax
c01048b6:	83 e0 ef             	and    $0xffffffef,%eax
c01048b9:	a2 2e ba 12 c0       	mov    %al,0xc012ba2e
c01048be:	0f b6 05 2e ba 12 c0 	movzbl 0xc012ba2e,%eax
c01048c5:	83 e0 df             	and    $0xffffffdf,%eax
c01048c8:	a2 2e ba 12 c0       	mov    %al,0xc012ba2e
c01048cd:	0f b6 05 2e ba 12 c0 	movzbl 0xc012ba2e,%eax
c01048d4:	83 c8 40             	or     $0x40,%eax
c01048d7:	a2 2e ba 12 c0       	mov    %al,0xc012ba2e
c01048dc:	0f b6 05 2e ba 12 c0 	movzbl 0xc012ba2e,%eax
c01048e3:	83 e0 7f             	and    $0x7f,%eax
c01048e6:	a2 2e ba 12 c0       	mov    %al,0xc012ba2e
c01048eb:	b8 a0 ef 12 c0       	mov    $0xc012efa0,%eax
c01048f0:	c1 e8 18             	shr    $0x18,%eax
c01048f3:	a2 2f ba 12 c0       	mov    %al,0xc012ba2f

    // reload all segment registers
    lgdt(&gdt_pd);
c01048f8:	68 30 ba 12 c0       	push   $0xc012ba30
c01048fd:	e8 d5 fe ff ff       	call   c01047d7 <lgdt>
c0104902:	83 c4 04             	add    $0x4,%esp
c0104905:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c010490b:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c010490f:	0f 00 d8             	ltr    %ax
}
c0104912:	90                   	nop

    // load the TSS
    ltr(GD_TSS);
}
c0104913:	90                   	nop
c0104914:	c9                   	leave  
c0104915:	c3                   	ret    

c0104916 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c0104916:	f3 0f 1e fb          	endbr32 
c010491a:	55                   	push   %ebp
c010491b:	89 e5                	mov    %esp,%ebp
c010491d:	83 ec 08             	sub    $0x8,%esp
    pmm_manager = &default_pmm_manager;
c0104920:	c7 05 58 10 13 c0 fc 	movl   $0xc010ccfc,0xc0131058
c0104927:	cc 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c010492a:	a1 58 10 13 c0       	mov    0xc0131058,%eax
c010492f:	8b 00                	mov    (%eax),%eax
c0104931:	83 ec 08             	sub    $0x8,%esp
c0104934:	50                   	push   %eax
c0104935:	68 d0 b7 10 c0       	push   $0xc010b7d0
c010493a:	e8 73 b9 ff ff       	call   c01002b2 <cprintf>
c010493f:	83 c4 10             	add    $0x10,%esp
    pmm_manager->init();
c0104942:	a1 58 10 13 c0       	mov    0xc0131058,%eax
c0104947:	8b 40 04             	mov    0x4(%eax),%eax
c010494a:	ff d0                	call   *%eax
}
c010494c:	90                   	nop
c010494d:	c9                   	leave  
c010494e:	c3                   	ret    

c010494f <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c010494f:	f3 0f 1e fb          	endbr32 
c0104953:	55                   	push   %ebp
c0104954:	89 e5                	mov    %esp,%ebp
c0104956:	83 ec 08             	sub    $0x8,%esp
    pmm_manager->init_memmap(base, n);
c0104959:	a1 58 10 13 c0       	mov    0xc0131058,%eax
c010495e:	8b 40 08             	mov    0x8(%eax),%eax
c0104961:	83 ec 08             	sub    $0x8,%esp
c0104964:	ff 75 0c             	pushl  0xc(%ebp)
c0104967:	ff 75 08             	pushl  0x8(%ebp)
c010496a:	ff d0                	call   *%eax
c010496c:	83 c4 10             	add    $0x10,%esp
}
c010496f:	90                   	nop
c0104970:	c9                   	leave  
c0104971:	c3                   	ret    

c0104972 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c0104972:	f3 0f 1e fb          	endbr32 
c0104976:	55                   	push   %ebp
c0104977:	89 e5                	mov    %esp,%ebp
c0104979:	83 ec 18             	sub    $0x18,%esp
    struct Page *page=NULL;
c010497c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    
    while (1)
    {
         local_intr_save(intr_flag);
c0104983:	e8 11 fe ff ff       	call   c0104799 <__intr_save>
c0104988:	89 45 f0             	mov    %eax,-0x10(%ebp)
         {
              page = pmm_manager->alloc_pages(n);
c010498b:	a1 58 10 13 c0       	mov    0xc0131058,%eax
c0104990:	8b 40 0c             	mov    0xc(%eax),%eax
c0104993:	83 ec 0c             	sub    $0xc,%esp
c0104996:	ff 75 08             	pushl  0x8(%ebp)
c0104999:	ff d0                	call   *%eax
c010499b:	83 c4 10             	add    $0x10,%esp
c010499e:	89 45 f4             	mov    %eax,-0xc(%ebp)
         }
         local_intr_restore(intr_flag);
c01049a1:	83 ec 0c             	sub    $0xc,%esp
c01049a4:	ff 75 f0             	pushl  -0x10(%ebp)
c01049a7:	e8 17 fe ff ff       	call   c01047c3 <__intr_restore>
c01049ac:	83 c4 10             	add    $0x10,%esp

         if (page != NULL || n > 1 || swap_init_ok == 0) break;
c01049af:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01049b3:	75 28                	jne    c01049dd <alloc_pages+0x6b>
c01049b5:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
c01049b9:	77 22                	ja     c01049dd <alloc_pages+0x6b>
c01049bb:	a1 10 f0 12 c0       	mov    0xc012f010,%eax
c01049c0:	85 c0                	test   %eax,%eax
c01049c2:	74 19                	je     c01049dd <alloc_pages+0x6b>
         
         extern struct mm_struct *check_mm_struct;
         //cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
         swap_out(check_mm_struct, n, 0);
c01049c4:	8b 55 08             	mov    0x8(%ebp),%edx
c01049c7:	a1 64 10 13 c0       	mov    0xc0131064,%eax
c01049cc:	83 ec 04             	sub    $0x4,%esp
c01049cf:	6a 00                	push   $0x0
c01049d1:	52                   	push   %edx
c01049d2:	50                   	push   %eax
c01049d3:	e8 b3 22 00 00       	call   c0106c8b <swap_out>
c01049d8:	83 c4 10             	add    $0x10,%esp
    {
c01049db:	eb a6                	jmp    c0104983 <alloc_pages+0x11>
    }
    //cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
c01049dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01049e0:	c9                   	leave  
c01049e1:	c3                   	ret    

c01049e2 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c01049e2:	f3 0f 1e fb          	endbr32 
c01049e6:	55                   	push   %ebp
c01049e7:	89 e5                	mov    %esp,%ebp
c01049e9:	83 ec 18             	sub    $0x18,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c01049ec:	e8 a8 fd ff ff       	call   c0104799 <__intr_save>
c01049f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c01049f4:	a1 58 10 13 c0       	mov    0xc0131058,%eax
c01049f9:	8b 40 10             	mov    0x10(%eax),%eax
c01049fc:	83 ec 08             	sub    $0x8,%esp
c01049ff:	ff 75 0c             	pushl  0xc(%ebp)
c0104a02:	ff 75 08             	pushl  0x8(%ebp)
c0104a05:	ff d0                	call   *%eax
c0104a07:	83 c4 10             	add    $0x10,%esp
    }
    local_intr_restore(intr_flag);
c0104a0a:	83 ec 0c             	sub    $0xc,%esp
c0104a0d:	ff 75 f4             	pushl  -0xc(%ebp)
c0104a10:	e8 ae fd ff ff       	call   c01047c3 <__intr_restore>
c0104a15:	83 c4 10             	add    $0x10,%esp
}
c0104a18:	90                   	nop
c0104a19:	c9                   	leave  
c0104a1a:	c3                   	ret    

c0104a1b <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c0104a1b:	f3 0f 1e fb          	endbr32 
c0104a1f:	55                   	push   %ebp
c0104a20:	89 e5                	mov    %esp,%ebp
c0104a22:	83 ec 18             	sub    $0x18,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c0104a25:	e8 6f fd ff ff       	call   c0104799 <__intr_save>
c0104a2a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c0104a2d:	a1 58 10 13 c0       	mov    0xc0131058,%eax
c0104a32:	8b 40 14             	mov    0x14(%eax),%eax
c0104a35:	ff d0                	call   *%eax
c0104a37:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c0104a3a:	83 ec 0c             	sub    $0xc,%esp
c0104a3d:	ff 75 f4             	pushl  -0xc(%ebp)
c0104a40:	e8 7e fd ff ff       	call   c01047c3 <__intr_restore>
c0104a45:	83 c4 10             	add    $0x10,%esp
    return ret;
c0104a48:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0104a4b:	c9                   	leave  
c0104a4c:	c3                   	ret    

c0104a4d <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c0104a4d:	f3 0f 1e fb          	endbr32 
c0104a51:	55                   	push   %ebp
c0104a52:	89 e5                	mov    %esp,%ebp
c0104a54:	57                   	push   %edi
c0104a55:	56                   	push   %esi
c0104a56:	53                   	push   %ebx
c0104a57:	83 ec 7c             	sub    $0x7c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0104a5a:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0104a61:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0104a68:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0104a6f:	83 ec 0c             	sub    $0xc,%esp
c0104a72:	68 e7 b7 10 c0       	push   $0xc010b7e7
c0104a77:	e8 36 b8 ff ff       	call   c01002b2 <cprintf>
c0104a7c:	83 c4 10             	add    $0x10,%esp
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0104a7f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0104a86:	e9 f4 00 00 00       	jmp    c0104b7f <page_init+0x132>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0104a8b:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104a8e:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104a91:	89 d0                	mov    %edx,%eax
c0104a93:	c1 e0 02             	shl    $0x2,%eax
c0104a96:	01 d0                	add    %edx,%eax
c0104a98:	c1 e0 02             	shl    $0x2,%eax
c0104a9b:	01 c8                	add    %ecx,%eax
c0104a9d:	8b 50 08             	mov    0x8(%eax),%edx
c0104aa0:	8b 40 04             	mov    0x4(%eax),%eax
c0104aa3:	89 45 a0             	mov    %eax,-0x60(%ebp)
c0104aa6:	89 55 a4             	mov    %edx,-0x5c(%ebp)
c0104aa9:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104aac:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104aaf:	89 d0                	mov    %edx,%eax
c0104ab1:	c1 e0 02             	shl    $0x2,%eax
c0104ab4:	01 d0                	add    %edx,%eax
c0104ab6:	c1 e0 02             	shl    $0x2,%eax
c0104ab9:	01 c8                	add    %ecx,%eax
c0104abb:	8b 48 0c             	mov    0xc(%eax),%ecx
c0104abe:	8b 58 10             	mov    0x10(%eax),%ebx
c0104ac1:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0104ac4:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0104ac7:	01 c8                	add    %ecx,%eax
c0104ac9:	11 da                	adc    %ebx,%edx
c0104acb:	89 45 98             	mov    %eax,-0x68(%ebp)
c0104ace:	89 55 9c             	mov    %edx,-0x64(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0104ad1:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104ad4:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104ad7:	89 d0                	mov    %edx,%eax
c0104ad9:	c1 e0 02             	shl    $0x2,%eax
c0104adc:	01 d0                	add    %edx,%eax
c0104ade:	c1 e0 02             	shl    $0x2,%eax
c0104ae1:	01 c8                	add    %ecx,%eax
c0104ae3:	83 c0 14             	add    $0x14,%eax
c0104ae6:	8b 00                	mov    (%eax),%eax
c0104ae8:	89 45 84             	mov    %eax,-0x7c(%ebp)
c0104aeb:	8b 45 98             	mov    -0x68(%ebp),%eax
c0104aee:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0104af1:	83 c0 ff             	add    $0xffffffff,%eax
c0104af4:	83 d2 ff             	adc    $0xffffffff,%edx
c0104af7:	89 c1                	mov    %eax,%ecx
c0104af9:	89 d3                	mov    %edx,%ebx
c0104afb:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0104afe:	89 55 80             	mov    %edx,-0x80(%ebp)
c0104b01:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104b04:	89 d0                	mov    %edx,%eax
c0104b06:	c1 e0 02             	shl    $0x2,%eax
c0104b09:	01 d0                	add    %edx,%eax
c0104b0b:	c1 e0 02             	shl    $0x2,%eax
c0104b0e:	03 45 80             	add    -0x80(%ebp),%eax
c0104b11:	8b 50 10             	mov    0x10(%eax),%edx
c0104b14:	8b 40 0c             	mov    0xc(%eax),%eax
c0104b17:	ff 75 84             	pushl  -0x7c(%ebp)
c0104b1a:	53                   	push   %ebx
c0104b1b:	51                   	push   %ecx
c0104b1c:	ff 75 a4             	pushl  -0x5c(%ebp)
c0104b1f:	ff 75 a0             	pushl  -0x60(%ebp)
c0104b22:	52                   	push   %edx
c0104b23:	50                   	push   %eax
c0104b24:	68 f4 b7 10 c0       	push   $0xc010b7f4
c0104b29:	e8 84 b7 ff ff       	call   c01002b2 <cprintf>
c0104b2e:	83 c4 20             	add    $0x20,%esp
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c0104b31:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104b34:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104b37:	89 d0                	mov    %edx,%eax
c0104b39:	c1 e0 02             	shl    $0x2,%eax
c0104b3c:	01 d0                	add    %edx,%eax
c0104b3e:	c1 e0 02             	shl    $0x2,%eax
c0104b41:	01 c8                	add    %ecx,%eax
c0104b43:	83 c0 14             	add    $0x14,%eax
c0104b46:	8b 00                	mov    (%eax),%eax
c0104b48:	83 f8 01             	cmp    $0x1,%eax
c0104b4b:	75 2e                	jne    c0104b7b <page_init+0x12e>
            if (maxpa < end && begin < KMEMSIZE) {
c0104b4d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104b50:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104b53:	3b 45 98             	cmp    -0x68(%ebp),%eax
c0104b56:	89 d0                	mov    %edx,%eax
c0104b58:	1b 45 9c             	sbb    -0x64(%ebp),%eax
c0104b5b:	73 1e                	jae    c0104b7b <page_init+0x12e>
c0104b5d:	ba ff ff ff 37       	mov    $0x37ffffff,%edx
c0104b62:	b8 00 00 00 00       	mov    $0x0,%eax
c0104b67:	3b 55 a0             	cmp    -0x60(%ebp),%edx
c0104b6a:	1b 45 a4             	sbb    -0x5c(%ebp),%eax
c0104b6d:	72 0c                	jb     c0104b7b <page_init+0x12e>
                maxpa = end;
c0104b6f:	8b 45 98             	mov    -0x68(%ebp),%eax
c0104b72:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0104b75:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0104b78:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
c0104b7b:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0104b7f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104b82:	8b 00                	mov    (%eax),%eax
c0104b84:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0104b87:	0f 8c fe fe ff ff    	jl     c0104a8b <page_init+0x3e>
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c0104b8d:	ba 00 00 00 38       	mov    $0x38000000,%edx
c0104b92:	b8 00 00 00 00       	mov    $0x0,%eax
c0104b97:	3b 55 e0             	cmp    -0x20(%ebp),%edx
c0104b9a:	1b 45 e4             	sbb    -0x1c(%ebp),%eax
c0104b9d:	73 0e                	jae    c0104bad <page_init+0x160>
        maxpa = KMEMSIZE;
c0104b9f:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c0104ba6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c0104bad:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104bb0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104bb3:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0104bb7:	c1 ea 0c             	shr    $0xc,%edx
c0104bba:	a3 80 ef 12 c0       	mov    %eax,0xc012ef80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c0104bbf:	c7 45 c0 00 10 00 00 	movl   $0x1000,-0x40(%ebp)
c0104bc6:	b8 60 11 13 c0       	mov    $0xc0131160,%eax
c0104bcb:	8d 50 ff             	lea    -0x1(%eax),%edx
c0104bce:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0104bd1:	01 d0                	add    %edx,%eax
c0104bd3:	89 45 bc             	mov    %eax,-0x44(%ebp)
c0104bd6:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0104bd9:	ba 00 00 00 00       	mov    $0x0,%edx
c0104bde:	f7 75 c0             	divl   -0x40(%ebp)
c0104be1:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0104be4:	29 d0                	sub    %edx,%eax
c0104be6:	a3 60 10 13 c0       	mov    %eax,0xc0131060

    for (i = 0; i < npage; i ++) {
c0104beb:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0104bf2:	eb 30                	jmp    c0104c24 <page_init+0x1d7>
        SetPageReserved(pages + i);
c0104bf4:	8b 0d 60 10 13 c0    	mov    0xc0131060,%ecx
c0104bfa:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104bfd:	89 d0                	mov    %edx,%eax
c0104bff:	c1 e0 03             	shl    $0x3,%eax
c0104c02:	01 d0                	add    %edx,%eax
c0104c04:	c1 e0 02             	shl    $0x2,%eax
c0104c07:	01 c8                	add    %ecx,%eax
c0104c09:	83 c0 04             	add    $0x4,%eax
c0104c0c:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
c0104c13:	89 45 90             	mov    %eax,-0x70(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104c16:	8b 45 90             	mov    -0x70(%ebp),%eax
c0104c19:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0104c1c:	0f ab 10             	bts    %edx,(%eax)
}
c0104c1f:	90                   	nop
    for (i = 0; i < npage; i ++) {
c0104c20:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0104c24:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104c27:	a1 80 ef 12 c0       	mov    0xc012ef80,%eax
c0104c2c:	39 c2                	cmp    %eax,%edx
c0104c2e:	72 c4                	jb     c0104bf4 <page_init+0x1a7>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c0104c30:	8b 15 80 ef 12 c0    	mov    0xc012ef80,%edx
c0104c36:	89 d0                	mov    %edx,%eax
c0104c38:	c1 e0 03             	shl    $0x3,%eax
c0104c3b:	01 d0                	add    %edx,%eax
c0104c3d:	c1 e0 02             	shl    $0x2,%eax
c0104c40:	89 c2                	mov    %eax,%edx
c0104c42:	a1 60 10 13 c0       	mov    0xc0131060,%eax
c0104c47:	01 d0                	add    %edx,%eax
c0104c49:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0104c4c:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
c0104c53:	77 17                	ja     c0104c6c <page_init+0x21f>
c0104c55:	ff 75 b8             	pushl  -0x48(%ebp)
c0104c58:	68 24 b8 10 c0       	push   $0xc010b824
c0104c5d:	68 ea 00 00 00       	push   $0xea
c0104c62:	68 48 b8 10 c0       	push   $0xc010b848
c0104c67:	e8 82 cb ff ff       	call   c01017ee <__panic>
c0104c6c:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0104c6f:	05 00 00 00 40       	add    $0x40000000,%eax
c0104c74:	89 45 b4             	mov    %eax,-0x4c(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c0104c77:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0104c7e:	e9 53 01 00 00       	jmp    c0104dd6 <page_init+0x389>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0104c83:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104c86:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104c89:	89 d0                	mov    %edx,%eax
c0104c8b:	c1 e0 02             	shl    $0x2,%eax
c0104c8e:	01 d0                	add    %edx,%eax
c0104c90:	c1 e0 02             	shl    $0x2,%eax
c0104c93:	01 c8                	add    %ecx,%eax
c0104c95:	8b 50 08             	mov    0x8(%eax),%edx
c0104c98:	8b 40 04             	mov    0x4(%eax),%eax
c0104c9b:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104c9e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0104ca1:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104ca4:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104ca7:	89 d0                	mov    %edx,%eax
c0104ca9:	c1 e0 02             	shl    $0x2,%eax
c0104cac:	01 d0                	add    %edx,%eax
c0104cae:	c1 e0 02             	shl    $0x2,%eax
c0104cb1:	01 c8                	add    %ecx,%eax
c0104cb3:	8b 48 0c             	mov    0xc(%eax),%ecx
c0104cb6:	8b 58 10             	mov    0x10(%eax),%ebx
c0104cb9:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104cbc:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104cbf:	01 c8                	add    %ecx,%eax
c0104cc1:	11 da                	adc    %ebx,%edx
c0104cc3:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0104cc6:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c0104cc9:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104ccc:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104ccf:	89 d0                	mov    %edx,%eax
c0104cd1:	c1 e0 02             	shl    $0x2,%eax
c0104cd4:	01 d0                	add    %edx,%eax
c0104cd6:	c1 e0 02             	shl    $0x2,%eax
c0104cd9:	01 c8                	add    %ecx,%eax
c0104cdb:	83 c0 14             	add    $0x14,%eax
c0104cde:	8b 00                	mov    (%eax),%eax
c0104ce0:	83 f8 01             	cmp    $0x1,%eax
c0104ce3:	0f 85 e9 00 00 00    	jne    c0104dd2 <page_init+0x385>
            if (begin < freemem) {
c0104ce9:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104cec:	ba 00 00 00 00       	mov    $0x0,%edx
c0104cf1:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c0104cf4:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c0104cf7:	19 d1                	sbb    %edx,%ecx
c0104cf9:	73 0d                	jae    c0104d08 <page_init+0x2bb>
                begin = freemem;
c0104cfb:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104cfe:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104d01:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c0104d08:	ba 00 00 00 38       	mov    $0x38000000,%edx
c0104d0d:	b8 00 00 00 00       	mov    $0x0,%eax
c0104d12:	3b 55 c8             	cmp    -0x38(%ebp),%edx
c0104d15:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c0104d18:	73 0e                	jae    c0104d28 <page_init+0x2db>
                end = KMEMSIZE;
c0104d1a:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c0104d21:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c0104d28:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104d2b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104d2e:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0104d31:	89 d0                	mov    %edx,%eax
c0104d33:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c0104d36:	0f 83 96 00 00 00    	jae    c0104dd2 <page_init+0x385>
                begin = ROUNDUP(begin, PGSIZE);
c0104d3c:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
c0104d43:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104d46:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104d49:	01 d0                	add    %edx,%eax
c0104d4b:	83 e8 01             	sub    $0x1,%eax
c0104d4e:	89 45 ac             	mov    %eax,-0x54(%ebp)
c0104d51:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0104d54:	ba 00 00 00 00       	mov    $0x0,%edx
c0104d59:	f7 75 b0             	divl   -0x50(%ebp)
c0104d5c:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0104d5f:	29 d0                	sub    %edx,%eax
c0104d61:	ba 00 00 00 00       	mov    $0x0,%edx
c0104d66:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104d69:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c0104d6c:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104d6f:	89 45 a8             	mov    %eax,-0x58(%ebp)
c0104d72:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0104d75:	ba 00 00 00 00       	mov    $0x0,%edx
c0104d7a:	89 c3                	mov    %eax,%ebx
c0104d7c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
c0104d82:	89 de                	mov    %ebx,%esi
c0104d84:	89 d0                	mov    %edx,%eax
c0104d86:	83 e0 00             	and    $0x0,%eax
c0104d89:	89 c7                	mov    %eax,%edi
c0104d8b:	89 75 c8             	mov    %esi,-0x38(%ebp)
c0104d8e:	89 7d cc             	mov    %edi,-0x34(%ebp)
                if (begin < end) {
c0104d91:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104d94:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104d97:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0104d9a:	89 d0                	mov    %edx,%eax
c0104d9c:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c0104d9f:	73 31                	jae    c0104dd2 <page_init+0x385>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c0104da1:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104da4:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0104da7:	2b 45 d0             	sub    -0x30(%ebp),%eax
c0104daa:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
c0104dad:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0104db1:	c1 ea 0c             	shr    $0xc,%edx
c0104db4:	89 c3                	mov    %eax,%ebx
c0104db6:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104db9:	83 ec 0c             	sub    $0xc,%esp
c0104dbc:	50                   	push   %eax
c0104dbd:	e8 af f8 ff ff       	call   c0104671 <pa2page>
c0104dc2:	83 c4 10             	add    $0x10,%esp
c0104dc5:	83 ec 08             	sub    $0x8,%esp
c0104dc8:	53                   	push   %ebx
c0104dc9:	50                   	push   %eax
c0104dca:	e8 80 fb ff ff       	call   c010494f <init_memmap>
c0104dcf:	83 c4 10             	add    $0x10,%esp
    for (i = 0; i < memmap->nr_map; i ++) {
c0104dd2:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0104dd6:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104dd9:	8b 00                	mov    (%eax),%eax
c0104ddb:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0104dde:	0f 8c 9f fe ff ff    	jl     c0104c83 <page_init+0x236>
                }
            }
        }
    }
}
c0104de4:	90                   	nop
c0104de5:	90                   	nop
c0104de6:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0104de9:	5b                   	pop    %ebx
c0104dea:	5e                   	pop    %esi
c0104deb:	5f                   	pop    %edi
c0104dec:	5d                   	pop    %ebp
c0104ded:	c3                   	ret    

c0104dee <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c0104dee:	f3 0f 1e fb          	endbr32 
c0104df2:	55                   	push   %ebp
c0104df3:	89 e5                	mov    %esp,%ebp
c0104df5:	83 ec 28             	sub    $0x28,%esp
    assert(PGOFF(la) == PGOFF(pa));
c0104df8:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104dfb:	33 45 14             	xor    0x14(%ebp),%eax
c0104dfe:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104e03:	85 c0                	test   %eax,%eax
c0104e05:	74 19                	je     c0104e20 <boot_map_segment+0x32>
c0104e07:	68 56 b8 10 c0       	push   $0xc010b856
c0104e0c:	68 6d b8 10 c0       	push   $0xc010b86d
c0104e11:	68 08 01 00 00       	push   $0x108
c0104e16:	68 48 b8 10 c0       	push   $0xc010b848
c0104e1b:	e8 ce c9 ff ff       	call   c01017ee <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c0104e20:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c0104e27:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104e2a:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104e2f:	89 c2                	mov    %eax,%edx
c0104e31:	8b 45 10             	mov    0x10(%ebp),%eax
c0104e34:	01 c2                	add    %eax,%edx
c0104e36:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104e39:	01 d0                	add    %edx,%eax
c0104e3b:	83 e8 01             	sub    $0x1,%eax
c0104e3e:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104e41:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104e44:	ba 00 00 00 00       	mov    $0x0,%edx
c0104e49:	f7 75 f0             	divl   -0x10(%ebp)
c0104e4c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104e4f:	29 d0                	sub    %edx,%eax
c0104e51:	c1 e8 0c             	shr    $0xc,%eax
c0104e54:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c0104e57:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104e5a:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104e5d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104e60:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104e65:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c0104e68:	8b 45 14             	mov    0x14(%ebp),%eax
c0104e6b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104e6e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104e71:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104e76:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0104e79:	eb 57                	jmp    c0104ed2 <boot_map_segment+0xe4>
        pte_t *ptep = get_pte(pgdir, la, 1);
c0104e7b:	83 ec 04             	sub    $0x4,%esp
c0104e7e:	6a 01                	push   $0x1
c0104e80:	ff 75 0c             	pushl  0xc(%ebp)
c0104e83:	ff 75 08             	pushl  0x8(%ebp)
c0104e86:	e8 61 01 00 00       	call   c0104fec <get_pte>
c0104e8b:	83 c4 10             	add    $0x10,%esp
c0104e8e:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c0104e91:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0104e95:	75 19                	jne    c0104eb0 <boot_map_segment+0xc2>
c0104e97:	68 82 b8 10 c0       	push   $0xc010b882
c0104e9c:	68 6d b8 10 c0       	push   $0xc010b86d
c0104ea1:	68 0e 01 00 00       	push   $0x10e
c0104ea6:	68 48 b8 10 c0       	push   $0xc010b848
c0104eab:	e8 3e c9 ff ff       	call   c01017ee <__panic>
        *ptep = pa | PTE_P | perm;
c0104eb0:	8b 45 14             	mov    0x14(%ebp),%eax
c0104eb3:	0b 45 18             	or     0x18(%ebp),%eax
c0104eb6:	83 c8 01             	or     $0x1,%eax
c0104eb9:	89 c2                	mov    %eax,%edx
c0104ebb:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104ebe:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0104ec0:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0104ec4:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c0104ecb:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c0104ed2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104ed6:	75 a3                	jne    c0104e7b <boot_map_segment+0x8d>
    }
}
c0104ed8:	90                   	nop
c0104ed9:	90                   	nop
c0104eda:	c9                   	leave  
c0104edb:	c3                   	ret    

c0104edc <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c0104edc:	f3 0f 1e fb          	endbr32 
c0104ee0:	55                   	push   %ebp
c0104ee1:	89 e5                	mov    %esp,%ebp
c0104ee3:	83 ec 18             	sub    $0x18,%esp
    struct Page *p = alloc_page();
c0104ee6:	83 ec 0c             	sub    $0xc,%esp
c0104ee9:	6a 01                	push   $0x1
c0104eeb:	e8 82 fa ff ff       	call   c0104972 <alloc_pages>
c0104ef0:	83 c4 10             	add    $0x10,%esp
c0104ef3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c0104ef6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104efa:	75 17                	jne    c0104f13 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c0104efc:	83 ec 04             	sub    $0x4,%esp
c0104eff:	68 8f b8 10 c0       	push   $0xc010b88f
c0104f04:	68 1a 01 00 00       	push   $0x11a
c0104f09:	68 48 b8 10 c0       	push   $0xc010b848
c0104f0e:	e8 db c8 ff ff       	call   c01017ee <__panic>
    }
    return page2kva(p);
c0104f13:	83 ec 0c             	sub    $0xc,%esp
c0104f16:	ff 75 f4             	pushl  -0xc(%ebp)
c0104f19:	e8 9a f7 ff ff       	call   c01046b8 <page2kva>
c0104f1e:	83 c4 10             	add    $0x10,%esp
}
c0104f21:	c9                   	leave  
c0104f22:	c3                   	ret    

c0104f23 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c0104f23:	f3 0f 1e fb          	endbr32 
c0104f27:	55                   	push   %ebp
c0104f28:	89 e5                	mov    %esp,%ebp
c0104f2a:	83 ec 18             	sub    $0x18,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c0104f2d:	a1 e0 b9 12 c0       	mov    0xc012b9e0,%eax
c0104f32:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104f35:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0104f3c:	77 17                	ja     c0104f55 <pmm_init+0x32>
c0104f3e:	ff 75 f4             	pushl  -0xc(%ebp)
c0104f41:	68 24 b8 10 c0       	push   $0xc010b824
c0104f46:	68 24 01 00 00       	push   $0x124
c0104f4b:	68 48 b8 10 c0       	push   $0xc010b848
c0104f50:	e8 99 c8 ff ff       	call   c01017ee <__panic>
c0104f55:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f58:	05 00 00 00 40       	add    $0x40000000,%eax
c0104f5d:	a3 5c 10 13 c0       	mov    %eax,0xc013105c
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c0104f62:	e8 af f9 ff ff       	call   c0104916 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c0104f67:	e8 e1 fa ff ff       	call   c0104a4d <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c0104f6c:	e8 56 04 00 00       	call   c01053c7 <check_alloc_page>

    check_pgdir();
c0104f71:	e8 78 04 00 00       	call   c01053ee <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c0104f76:	a1 e0 b9 12 c0       	mov    0xc012b9e0,%eax
c0104f7b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104f7e:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0104f85:	77 17                	ja     c0104f9e <pmm_init+0x7b>
c0104f87:	ff 75 f0             	pushl  -0x10(%ebp)
c0104f8a:	68 24 b8 10 c0       	push   $0xc010b824
c0104f8f:	68 3a 01 00 00       	push   $0x13a
c0104f94:	68 48 b8 10 c0       	push   $0xc010b848
c0104f99:	e8 50 c8 ff ff       	call   c01017ee <__panic>
c0104f9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104fa1:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c0104fa7:	a1 e0 b9 12 c0       	mov    0xc012b9e0,%eax
c0104fac:	05 ac 0f 00 00       	add    $0xfac,%eax
c0104fb1:	83 ca 03             	or     $0x3,%edx
c0104fb4:	89 10                	mov    %edx,(%eax)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c0104fb6:	a1 e0 b9 12 c0       	mov    0xc012b9e0,%eax
c0104fbb:	83 ec 0c             	sub    $0xc,%esp
c0104fbe:	6a 02                	push   $0x2
c0104fc0:	6a 00                	push   $0x0
c0104fc2:	68 00 00 00 38       	push   $0x38000000
c0104fc7:	68 00 00 00 c0       	push   $0xc0000000
c0104fcc:	50                   	push   %eax
c0104fcd:	e8 1c fe ff ff       	call   c0104dee <boot_map_segment>
c0104fd2:	83 c4 20             	add    $0x20,%esp

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c0104fd5:	e8 45 f8 ff ff       	call   c010481f <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c0104fda:	e8 79 09 00 00       	call   c0105958 <check_boot_pgdir>

    print_pgdir();
c0104fdf:	e8 7b 0d 00 00       	call   c0105d5f <print_pgdir>
    
    kmalloc_init();
c0104fe4:	e8 ba 2a 00 00       	call   c0107aa3 <kmalloc_init>

}
c0104fe9:	90                   	nop
c0104fea:	c9                   	leave  
c0104feb:	c3                   	ret    

c0104fec <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c0104fec:	f3 0f 1e fb          	endbr32 
c0104ff0:	55                   	push   %ebp
c0104ff1:	89 e5                	mov    %esp,%ebp
c0104ff3:	83 ec 28             	sub    $0x28,%esp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
    pde_t *pdep = &pgdir[PDX(la)];
c0104ff6:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104ff9:	c1 e8 16             	shr    $0x16,%eax
c0104ffc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105003:	8b 45 08             	mov    0x8(%ebp),%eax
c0105006:	01 d0                	add    %edx,%eax
c0105008:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)) {
c010500b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010500e:	8b 00                	mov    (%eax),%eax
c0105010:	83 e0 01             	and    $0x1,%eax
c0105013:	85 c0                	test   %eax,%eax
c0105015:	0f 85 9f 00 00 00    	jne    c01050ba <get_pte+0xce>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
c010501b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010501f:	74 16                	je     c0105037 <get_pte+0x4b>
c0105021:	83 ec 0c             	sub    $0xc,%esp
c0105024:	6a 01                	push   $0x1
c0105026:	e8 47 f9 ff ff       	call   c0104972 <alloc_pages>
c010502b:	83 c4 10             	add    $0x10,%esp
c010502e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105031:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105035:	75 0a                	jne    c0105041 <get_pte+0x55>
            return NULL;
c0105037:	b8 00 00 00 00       	mov    $0x0,%eax
c010503c:	e9 ca 00 00 00       	jmp    c010510b <get_pte+0x11f>
        }
        set_page_ref(page, 1);
c0105041:	83 ec 08             	sub    $0x8,%esp
c0105044:	6a 01                	push   $0x1
c0105046:	ff 75 f0             	pushl  -0x10(%ebp)
c0105049:	e8 0f f7 ff ff       	call   c010475d <set_page_ref>
c010504e:	83 c4 10             	add    $0x10,%esp
        uintptr_t pa = page2pa(page);
c0105051:	83 ec 0c             	sub    $0xc,%esp
c0105054:	ff 75 f0             	pushl  -0x10(%ebp)
c0105057:	e8 02 f6 ff ff       	call   c010465e <page2pa>
c010505c:	83 c4 10             	add    $0x10,%esp
c010505f:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE);
c0105062:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105065:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105068:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010506b:	c1 e8 0c             	shr    $0xc,%eax
c010506e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105071:	a1 80 ef 12 c0       	mov    0xc012ef80,%eax
c0105076:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c0105079:	72 17                	jb     c0105092 <get_pte+0xa6>
c010507b:	ff 75 e8             	pushl  -0x18(%ebp)
c010507e:	68 80 b7 10 c0       	push   $0xc010b780
c0105083:	68 82 01 00 00       	push   $0x182
c0105088:	68 48 b8 10 c0       	push   $0xc010b848
c010508d:	e8 5c c7 ff ff       	call   c01017ee <__panic>
c0105092:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105095:	2d 00 00 00 40       	sub    $0x40000000,%eax
c010509a:	83 ec 04             	sub    $0x4,%esp
c010509d:	68 00 10 00 00       	push   $0x1000
c01050a2:	6a 00                	push   $0x0
c01050a4:	50                   	push   %eax
c01050a5:	e8 3a 52 00 00       	call   c010a2e4 <memset>
c01050aa:	83 c4 10             	add    $0x10,%esp
        *pdep = pa | PTE_U | PTE_W | PTE_P;
c01050ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01050b0:	83 c8 07             	or     $0x7,%eax
c01050b3:	89 c2                	mov    %eax,%edx
c01050b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01050b8:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
c01050ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01050bd:	8b 00                	mov    (%eax),%eax
c01050bf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01050c4:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01050c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01050ca:	c1 e8 0c             	shr    $0xc,%eax
c01050cd:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01050d0:	a1 80 ef 12 c0       	mov    0xc012ef80,%eax
c01050d5:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c01050d8:	72 17                	jb     c01050f1 <get_pte+0x105>
c01050da:	ff 75 e0             	pushl  -0x20(%ebp)
c01050dd:	68 80 b7 10 c0       	push   $0xc010b780
c01050e2:	68 85 01 00 00       	push   $0x185
c01050e7:	68 48 b8 10 c0       	push   $0xc010b848
c01050ec:	e8 fd c6 ff ff       	call   c01017ee <__panic>
c01050f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01050f4:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01050f9:	89 c2                	mov    %eax,%edx
c01050fb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01050fe:	c1 e8 0c             	shr    $0xc,%eax
c0105101:	25 ff 03 00 00       	and    $0x3ff,%eax
c0105106:	c1 e0 02             	shl    $0x2,%eax
c0105109:	01 d0                	add    %edx,%eax
}
c010510b:	c9                   	leave  
c010510c:	c3                   	ret    

c010510d <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c010510d:	f3 0f 1e fb          	endbr32 
c0105111:	55                   	push   %ebp
c0105112:	89 e5                	mov    %esp,%ebp
c0105114:	83 ec 18             	sub    $0x18,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0105117:	83 ec 04             	sub    $0x4,%esp
c010511a:	6a 00                	push   $0x0
c010511c:	ff 75 0c             	pushl  0xc(%ebp)
c010511f:	ff 75 08             	pushl  0x8(%ebp)
c0105122:	e8 c5 fe ff ff       	call   c0104fec <get_pte>
c0105127:	83 c4 10             	add    $0x10,%esp
c010512a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c010512d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105131:	74 08                	je     c010513b <get_page+0x2e>
        *ptep_store = ptep;
c0105133:	8b 45 10             	mov    0x10(%ebp),%eax
c0105136:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105139:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c010513b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010513f:	74 1f                	je     c0105160 <get_page+0x53>
c0105141:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105144:	8b 00                	mov    (%eax),%eax
c0105146:	83 e0 01             	and    $0x1,%eax
c0105149:	85 c0                	test   %eax,%eax
c010514b:	74 13                	je     c0105160 <get_page+0x53>
        return pte2page(*ptep);
c010514d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105150:	8b 00                	mov    (%eax),%eax
c0105152:	83 ec 0c             	sub    $0xc,%esp
c0105155:	50                   	push   %eax
c0105156:	e8 a2 f5 ff ff       	call   c01046fd <pte2page>
c010515b:	83 c4 10             	add    $0x10,%esp
c010515e:	eb 05                	jmp    c0105165 <get_page+0x58>
    }
    return NULL;
c0105160:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105165:	c9                   	leave  
c0105166:	c3                   	ret    

c0105167 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c0105167:	55                   	push   %ebp
c0105168:	89 e5                	mov    %esp,%ebp
c010516a:	83 ec 18             	sub    $0x18,%esp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
    if (*ptep & PTE_P) {
c010516d:	8b 45 10             	mov    0x10(%ebp),%eax
c0105170:	8b 00                	mov    (%eax),%eax
c0105172:	83 e0 01             	and    $0x1,%eax
c0105175:	85 c0                	test   %eax,%eax
c0105177:	74 50                	je     c01051c9 <page_remove_pte+0x62>
        struct Page *page = pte2page(*ptep);
c0105179:	8b 45 10             	mov    0x10(%ebp),%eax
c010517c:	8b 00                	mov    (%eax),%eax
c010517e:	83 ec 0c             	sub    $0xc,%esp
c0105181:	50                   	push   %eax
c0105182:	e8 76 f5 ff ff       	call   c01046fd <pte2page>
c0105187:	83 c4 10             	add    $0x10,%esp
c010518a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) {
c010518d:	83 ec 0c             	sub    $0xc,%esp
c0105190:	ff 75 f4             	pushl  -0xc(%ebp)
c0105193:	e8 ea f5 ff ff       	call   c0104782 <page_ref_dec>
c0105198:	83 c4 10             	add    $0x10,%esp
c010519b:	85 c0                	test   %eax,%eax
c010519d:	75 10                	jne    c01051af <page_remove_pte+0x48>
            free_page(page);
c010519f:	83 ec 08             	sub    $0x8,%esp
c01051a2:	6a 01                	push   $0x1
c01051a4:	ff 75 f4             	pushl  -0xc(%ebp)
c01051a7:	e8 36 f8 ff ff       	call   c01049e2 <free_pages>
c01051ac:	83 c4 10             	add    $0x10,%esp
        }
        *ptep = 0;
c01051af:	8b 45 10             	mov    0x10(%ebp),%eax
c01051b2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
c01051b8:	83 ec 08             	sub    $0x8,%esp
c01051bb:	ff 75 0c             	pushl  0xc(%ebp)
c01051be:	ff 75 08             	pushl  0x8(%ebp)
c01051c1:	e8 00 01 00 00       	call   c01052c6 <tlb_invalidate>
c01051c6:	83 c4 10             	add    $0x10,%esp
    }
}
c01051c9:	90                   	nop
c01051ca:	c9                   	leave  
c01051cb:	c3                   	ret    

c01051cc <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c01051cc:	f3 0f 1e fb          	endbr32 
c01051d0:	55                   	push   %ebp
c01051d1:	89 e5                	mov    %esp,%ebp
c01051d3:	83 ec 18             	sub    $0x18,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c01051d6:	83 ec 04             	sub    $0x4,%esp
c01051d9:	6a 00                	push   $0x0
c01051db:	ff 75 0c             	pushl  0xc(%ebp)
c01051de:	ff 75 08             	pushl  0x8(%ebp)
c01051e1:	e8 06 fe ff ff       	call   c0104fec <get_pte>
c01051e6:	83 c4 10             	add    $0x10,%esp
c01051e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c01051ec:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01051f0:	74 14                	je     c0105206 <page_remove+0x3a>
        page_remove_pte(pgdir, la, ptep);
c01051f2:	83 ec 04             	sub    $0x4,%esp
c01051f5:	ff 75 f4             	pushl  -0xc(%ebp)
c01051f8:	ff 75 0c             	pushl  0xc(%ebp)
c01051fb:	ff 75 08             	pushl  0x8(%ebp)
c01051fe:	e8 64 ff ff ff       	call   c0105167 <page_remove_pte>
c0105203:	83 c4 10             	add    $0x10,%esp
    }
}
c0105206:	90                   	nop
c0105207:	c9                   	leave  
c0105208:	c3                   	ret    

c0105209 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c0105209:	f3 0f 1e fb          	endbr32 
c010520d:	55                   	push   %ebp
c010520e:	89 e5                	mov    %esp,%ebp
c0105210:	83 ec 18             	sub    $0x18,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c0105213:	83 ec 04             	sub    $0x4,%esp
c0105216:	6a 01                	push   $0x1
c0105218:	ff 75 10             	pushl  0x10(%ebp)
c010521b:	ff 75 08             	pushl  0x8(%ebp)
c010521e:	e8 c9 fd ff ff       	call   c0104fec <get_pte>
c0105223:	83 c4 10             	add    $0x10,%esp
c0105226:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c0105229:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010522d:	75 0a                	jne    c0105239 <page_insert+0x30>
        return -E_NO_MEM;
c010522f:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0105234:	e9 8b 00 00 00       	jmp    c01052c4 <page_insert+0xbb>
    }
    page_ref_inc(page);
c0105239:	83 ec 0c             	sub    $0xc,%esp
c010523c:	ff 75 0c             	pushl  0xc(%ebp)
c010523f:	e8 27 f5 ff ff       	call   c010476b <page_ref_inc>
c0105244:	83 c4 10             	add    $0x10,%esp
    if (*ptep & PTE_P) {
c0105247:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010524a:	8b 00                	mov    (%eax),%eax
c010524c:	83 e0 01             	and    $0x1,%eax
c010524f:	85 c0                	test   %eax,%eax
c0105251:	74 40                	je     c0105293 <page_insert+0x8a>
        struct Page *p = pte2page(*ptep);
c0105253:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105256:	8b 00                	mov    (%eax),%eax
c0105258:	83 ec 0c             	sub    $0xc,%esp
c010525b:	50                   	push   %eax
c010525c:	e8 9c f4 ff ff       	call   c01046fd <pte2page>
c0105261:	83 c4 10             	add    $0x10,%esp
c0105264:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c0105267:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010526a:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010526d:	75 10                	jne    c010527f <page_insert+0x76>
            page_ref_dec(page);
c010526f:	83 ec 0c             	sub    $0xc,%esp
c0105272:	ff 75 0c             	pushl  0xc(%ebp)
c0105275:	e8 08 f5 ff ff       	call   c0104782 <page_ref_dec>
c010527a:	83 c4 10             	add    $0x10,%esp
c010527d:	eb 14                	jmp    c0105293 <page_insert+0x8a>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c010527f:	83 ec 04             	sub    $0x4,%esp
c0105282:	ff 75 f4             	pushl  -0xc(%ebp)
c0105285:	ff 75 10             	pushl  0x10(%ebp)
c0105288:	ff 75 08             	pushl  0x8(%ebp)
c010528b:	e8 d7 fe ff ff       	call   c0105167 <page_remove_pte>
c0105290:	83 c4 10             	add    $0x10,%esp
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c0105293:	83 ec 0c             	sub    $0xc,%esp
c0105296:	ff 75 0c             	pushl  0xc(%ebp)
c0105299:	e8 c0 f3 ff ff       	call   c010465e <page2pa>
c010529e:	83 c4 10             	add    $0x10,%esp
c01052a1:	0b 45 14             	or     0x14(%ebp),%eax
c01052a4:	83 c8 01             	or     $0x1,%eax
c01052a7:	89 c2                	mov    %eax,%edx
c01052a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01052ac:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c01052ae:	83 ec 08             	sub    $0x8,%esp
c01052b1:	ff 75 10             	pushl  0x10(%ebp)
c01052b4:	ff 75 08             	pushl  0x8(%ebp)
c01052b7:	e8 0a 00 00 00       	call   c01052c6 <tlb_invalidate>
c01052bc:	83 c4 10             	add    $0x10,%esp
    return 0;
c01052bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01052c4:	c9                   	leave  
c01052c5:	c3                   	ret    

c01052c6 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c01052c6:	f3 0f 1e fb          	endbr32 
c01052ca:	55                   	push   %ebp
c01052cb:	89 e5                	mov    %esp,%ebp
c01052cd:	83 ec 18             	sub    $0x18,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c01052d0:	0f 20 d8             	mov    %cr3,%eax
c01052d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c01052d6:	8b 55 f0             	mov    -0x10(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
c01052d9:	8b 45 08             	mov    0x8(%ebp),%eax
c01052dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01052df:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01052e6:	77 17                	ja     c01052ff <tlb_invalidate+0x39>
c01052e8:	ff 75 f4             	pushl  -0xc(%ebp)
c01052eb:	68 24 b8 10 c0       	push   $0xc010b824
c01052f0:	68 e7 01 00 00       	push   $0x1e7
c01052f5:	68 48 b8 10 c0       	push   $0xc010b848
c01052fa:	e8 ef c4 ff ff       	call   c01017ee <__panic>
c01052ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105302:	05 00 00 00 40       	add    $0x40000000,%eax
c0105307:	39 d0                	cmp    %edx,%eax
c0105309:	75 0d                	jne    c0105318 <tlb_invalidate+0x52>
        invlpg((void *)la);
c010530b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010530e:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c0105311:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105314:	0f 01 38             	invlpg (%eax)
}
c0105317:	90                   	nop
    }
}
c0105318:	90                   	nop
c0105319:	c9                   	leave  
c010531a:	c3                   	ret    

c010531b <pgdir_alloc_page>:

// pgdir_alloc_page - call alloc_page & page_insert functions to 
//                  - allocate a page size memory & setup an addr map
//                  - pa<->la with linear address la and the PDT pgdir
struct Page *
pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
c010531b:	f3 0f 1e fb          	endbr32 
c010531f:	55                   	push   %ebp
c0105320:	89 e5                	mov    %esp,%ebp
c0105322:	83 ec 18             	sub    $0x18,%esp
    struct Page *page = alloc_page();
c0105325:	83 ec 0c             	sub    $0xc,%esp
c0105328:	6a 01                	push   $0x1
c010532a:	e8 43 f6 ff ff       	call   c0104972 <alloc_pages>
c010532f:	83 c4 10             	add    $0x10,%esp
c0105332:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c0105335:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105339:	0f 84 83 00 00 00    	je     c01053c2 <pgdir_alloc_page+0xa7>
        if (page_insert(pgdir, page, la, perm) != 0) {
c010533f:	ff 75 10             	pushl  0x10(%ebp)
c0105342:	ff 75 0c             	pushl  0xc(%ebp)
c0105345:	ff 75 f4             	pushl  -0xc(%ebp)
c0105348:	ff 75 08             	pushl  0x8(%ebp)
c010534b:	e8 b9 fe ff ff       	call   c0105209 <page_insert>
c0105350:	83 c4 10             	add    $0x10,%esp
c0105353:	85 c0                	test   %eax,%eax
c0105355:	74 17                	je     c010536e <pgdir_alloc_page+0x53>
            free_page(page);
c0105357:	83 ec 08             	sub    $0x8,%esp
c010535a:	6a 01                	push   $0x1
c010535c:	ff 75 f4             	pushl  -0xc(%ebp)
c010535f:	e8 7e f6 ff ff       	call   c01049e2 <free_pages>
c0105364:	83 c4 10             	add    $0x10,%esp
            return NULL;
c0105367:	b8 00 00 00 00       	mov    $0x0,%eax
c010536c:	eb 57                	jmp    c01053c5 <pgdir_alloc_page+0xaa>
        }
        if (swap_init_ok){
c010536e:	a1 10 f0 12 c0       	mov    0xc012f010,%eax
c0105373:	85 c0                	test   %eax,%eax
c0105375:	74 4b                	je     c01053c2 <pgdir_alloc_page+0xa7>
            swap_map_swappable(check_mm_struct, la, page, 0);
c0105377:	a1 64 10 13 c0       	mov    0xc0131064,%eax
c010537c:	6a 00                	push   $0x0
c010537e:	ff 75 f4             	pushl  -0xc(%ebp)
c0105381:	ff 75 0c             	pushl  0xc(%ebp)
c0105384:	50                   	push   %eax
c0105385:	e8 ba 18 00 00       	call   c0106c44 <swap_map_swappable>
c010538a:	83 c4 10             	add    $0x10,%esp
            page->pra_vaddr=la;
c010538d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105390:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105393:	89 50 20             	mov    %edx,0x20(%eax)
            assert(page_ref(page) == 1);
c0105396:	83 ec 0c             	sub    $0xc,%esp
c0105399:	ff 75 f4             	pushl  -0xc(%ebp)
c010539c:	e8 b2 f3 ff ff       	call   c0104753 <page_ref>
c01053a1:	83 c4 10             	add    $0x10,%esp
c01053a4:	83 f8 01             	cmp    $0x1,%eax
c01053a7:	74 19                	je     c01053c2 <pgdir_alloc_page+0xa7>
c01053a9:	68 a8 b8 10 c0       	push   $0xc010b8a8
c01053ae:	68 6d b8 10 c0       	push   $0xc010b86d
c01053b3:	68 fa 01 00 00       	push   $0x1fa
c01053b8:	68 48 b8 10 c0       	push   $0xc010b848
c01053bd:	e8 2c c4 ff ff       	call   c01017ee <__panic>
            //cprintf("get No. %d  page: pra_vaddr %x, pra_link.prev %x, pra_link_next %x in pgdir_alloc_page\n", (page-pages), page->pra_vaddr,page->pra_page_link.prev, page->pra_page_link.next);
        }

    }

    return page;
c01053c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01053c5:	c9                   	leave  
c01053c6:	c3                   	ret    

c01053c7 <check_alloc_page>:

static void
check_alloc_page(void) {
c01053c7:	f3 0f 1e fb          	endbr32 
c01053cb:	55                   	push   %ebp
c01053cc:	89 e5                	mov    %esp,%ebp
c01053ce:	83 ec 08             	sub    $0x8,%esp
    pmm_manager->check();
c01053d1:	a1 58 10 13 c0       	mov    0xc0131058,%eax
c01053d6:	8b 40 18             	mov    0x18(%eax),%eax
c01053d9:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c01053db:	83 ec 0c             	sub    $0xc,%esp
c01053de:	68 bc b8 10 c0       	push   $0xc010b8bc
c01053e3:	e8 ca ae ff ff       	call   c01002b2 <cprintf>
c01053e8:	83 c4 10             	add    $0x10,%esp
}
c01053eb:	90                   	nop
c01053ec:	c9                   	leave  
c01053ed:	c3                   	ret    

c01053ee <check_pgdir>:

static void
check_pgdir(void) {
c01053ee:	f3 0f 1e fb          	endbr32 
c01053f2:	55                   	push   %ebp
c01053f3:	89 e5                	mov    %esp,%ebp
c01053f5:	83 ec 28             	sub    $0x28,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c01053f8:	a1 80 ef 12 c0       	mov    0xc012ef80,%eax
c01053fd:	3d 00 80 03 00       	cmp    $0x38000,%eax
c0105402:	76 19                	jbe    c010541d <check_pgdir+0x2f>
c0105404:	68 db b8 10 c0       	push   $0xc010b8db
c0105409:	68 6d b8 10 c0       	push   $0xc010b86d
c010540e:	68 0b 02 00 00       	push   $0x20b
c0105413:	68 48 b8 10 c0       	push   $0xc010b848
c0105418:	e8 d1 c3 ff ff       	call   c01017ee <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c010541d:	a1 e0 b9 12 c0       	mov    0xc012b9e0,%eax
c0105422:	85 c0                	test   %eax,%eax
c0105424:	74 0e                	je     c0105434 <check_pgdir+0x46>
c0105426:	a1 e0 b9 12 c0       	mov    0xc012b9e0,%eax
c010542b:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105430:	85 c0                	test   %eax,%eax
c0105432:	74 19                	je     c010544d <check_pgdir+0x5f>
c0105434:	68 f8 b8 10 c0       	push   $0xc010b8f8
c0105439:	68 6d b8 10 c0       	push   $0xc010b86d
c010543e:	68 0c 02 00 00       	push   $0x20c
c0105443:	68 48 b8 10 c0       	push   $0xc010b848
c0105448:	e8 a1 c3 ff ff       	call   c01017ee <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c010544d:	a1 e0 b9 12 c0       	mov    0xc012b9e0,%eax
c0105452:	83 ec 04             	sub    $0x4,%esp
c0105455:	6a 00                	push   $0x0
c0105457:	6a 00                	push   $0x0
c0105459:	50                   	push   %eax
c010545a:	e8 ae fc ff ff       	call   c010510d <get_page>
c010545f:	83 c4 10             	add    $0x10,%esp
c0105462:	85 c0                	test   %eax,%eax
c0105464:	74 19                	je     c010547f <check_pgdir+0x91>
c0105466:	68 30 b9 10 c0       	push   $0xc010b930
c010546b:	68 6d b8 10 c0       	push   $0xc010b86d
c0105470:	68 0d 02 00 00       	push   $0x20d
c0105475:	68 48 b8 10 c0       	push   $0xc010b848
c010547a:	e8 6f c3 ff ff       	call   c01017ee <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c010547f:	83 ec 0c             	sub    $0xc,%esp
c0105482:	6a 01                	push   $0x1
c0105484:	e8 e9 f4 ff ff       	call   c0104972 <alloc_pages>
c0105489:	83 c4 10             	add    $0x10,%esp
c010548c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c010548f:	a1 e0 b9 12 c0       	mov    0xc012b9e0,%eax
c0105494:	6a 00                	push   $0x0
c0105496:	6a 00                	push   $0x0
c0105498:	ff 75 f4             	pushl  -0xc(%ebp)
c010549b:	50                   	push   %eax
c010549c:	e8 68 fd ff ff       	call   c0105209 <page_insert>
c01054a1:	83 c4 10             	add    $0x10,%esp
c01054a4:	85 c0                	test   %eax,%eax
c01054a6:	74 19                	je     c01054c1 <check_pgdir+0xd3>
c01054a8:	68 58 b9 10 c0       	push   $0xc010b958
c01054ad:	68 6d b8 10 c0       	push   $0xc010b86d
c01054b2:	68 11 02 00 00       	push   $0x211
c01054b7:	68 48 b8 10 c0       	push   $0xc010b848
c01054bc:	e8 2d c3 ff ff       	call   c01017ee <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c01054c1:	a1 e0 b9 12 c0       	mov    0xc012b9e0,%eax
c01054c6:	83 ec 04             	sub    $0x4,%esp
c01054c9:	6a 00                	push   $0x0
c01054cb:	6a 00                	push   $0x0
c01054cd:	50                   	push   %eax
c01054ce:	e8 19 fb ff ff       	call   c0104fec <get_pte>
c01054d3:	83 c4 10             	add    $0x10,%esp
c01054d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01054d9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01054dd:	75 19                	jne    c01054f8 <check_pgdir+0x10a>
c01054df:	68 84 b9 10 c0       	push   $0xc010b984
c01054e4:	68 6d b8 10 c0       	push   $0xc010b86d
c01054e9:	68 14 02 00 00       	push   $0x214
c01054ee:	68 48 b8 10 c0       	push   $0xc010b848
c01054f3:	e8 f6 c2 ff ff       	call   c01017ee <__panic>
    assert(pte2page(*ptep) == p1);
c01054f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01054fb:	8b 00                	mov    (%eax),%eax
c01054fd:	83 ec 0c             	sub    $0xc,%esp
c0105500:	50                   	push   %eax
c0105501:	e8 f7 f1 ff ff       	call   c01046fd <pte2page>
c0105506:	83 c4 10             	add    $0x10,%esp
c0105509:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010550c:	74 19                	je     c0105527 <check_pgdir+0x139>
c010550e:	68 b1 b9 10 c0       	push   $0xc010b9b1
c0105513:	68 6d b8 10 c0       	push   $0xc010b86d
c0105518:	68 15 02 00 00       	push   $0x215
c010551d:	68 48 b8 10 c0       	push   $0xc010b848
c0105522:	e8 c7 c2 ff ff       	call   c01017ee <__panic>
    assert(page_ref(p1) == 1);
c0105527:	83 ec 0c             	sub    $0xc,%esp
c010552a:	ff 75 f4             	pushl  -0xc(%ebp)
c010552d:	e8 21 f2 ff ff       	call   c0104753 <page_ref>
c0105532:	83 c4 10             	add    $0x10,%esp
c0105535:	83 f8 01             	cmp    $0x1,%eax
c0105538:	74 19                	je     c0105553 <check_pgdir+0x165>
c010553a:	68 c7 b9 10 c0       	push   $0xc010b9c7
c010553f:	68 6d b8 10 c0       	push   $0xc010b86d
c0105544:	68 16 02 00 00       	push   $0x216
c0105549:	68 48 b8 10 c0       	push   $0xc010b848
c010554e:	e8 9b c2 ff ff       	call   c01017ee <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c0105553:	a1 e0 b9 12 c0       	mov    0xc012b9e0,%eax
c0105558:	8b 00                	mov    (%eax),%eax
c010555a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010555f:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105562:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105565:	c1 e8 0c             	shr    $0xc,%eax
c0105568:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010556b:	a1 80 ef 12 c0       	mov    0xc012ef80,%eax
c0105570:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0105573:	72 17                	jb     c010558c <check_pgdir+0x19e>
c0105575:	ff 75 ec             	pushl  -0x14(%ebp)
c0105578:	68 80 b7 10 c0       	push   $0xc010b780
c010557d:	68 18 02 00 00       	push   $0x218
c0105582:	68 48 b8 10 c0       	push   $0xc010b848
c0105587:	e8 62 c2 ff ff       	call   c01017ee <__panic>
c010558c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010558f:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0105594:	83 c0 04             	add    $0x4,%eax
c0105597:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c010559a:	a1 e0 b9 12 c0       	mov    0xc012b9e0,%eax
c010559f:	83 ec 04             	sub    $0x4,%esp
c01055a2:	6a 00                	push   $0x0
c01055a4:	68 00 10 00 00       	push   $0x1000
c01055a9:	50                   	push   %eax
c01055aa:	e8 3d fa ff ff       	call   c0104fec <get_pte>
c01055af:	83 c4 10             	add    $0x10,%esp
c01055b2:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01055b5:	74 19                	je     c01055d0 <check_pgdir+0x1e2>
c01055b7:	68 dc b9 10 c0       	push   $0xc010b9dc
c01055bc:	68 6d b8 10 c0       	push   $0xc010b86d
c01055c1:	68 19 02 00 00       	push   $0x219
c01055c6:	68 48 b8 10 c0       	push   $0xc010b848
c01055cb:	e8 1e c2 ff ff       	call   c01017ee <__panic>

    p2 = alloc_page();
c01055d0:	83 ec 0c             	sub    $0xc,%esp
c01055d3:	6a 01                	push   $0x1
c01055d5:	e8 98 f3 ff ff       	call   c0104972 <alloc_pages>
c01055da:	83 c4 10             	add    $0x10,%esp
c01055dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c01055e0:	a1 e0 b9 12 c0       	mov    0xc012b9e0,%eax
c01055e5:	6a 06                	push   $0x6
c01055e7:	68 00 10 00 00       	push   $0x1000
c01055ec:	ff 75 e4             	pushl  -0x1c(%ebp)
c01055ef:	50                   	push   %eax
c01055f0:	e8 14 fc ff ff       	call   c0105209 <page_insert>
c01055f5:	83 c4 10             	add    $0x10,%esp
c01055f8:	85 c0                	test   %eax,%eax
c01055fa:	74 19                	je     c0105615 <check_pgdir+0x227>
c01055fc:	68 04 ba 10 c0       	push   $0xc010ba04
c0105601:	68 6d b8 10 c0       	push   $0xc010b86d
c0105606:	68 1c 02 00 00       	push   $0x21c
c010560b:	68 48 b8 10 c0       	push   $0xc010b848
c0105610:	e8 d9 c1 ff ff       	call   c01017ee <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0105615:	a1 e0 b9 12 c0       	mov    0xc012b9e0,%eax
c010561a:	83 ec 04             	sub    $0x4,%esp
c010561d:	6a 00                	push   $0x0
c010561f:	68 00 10 00 00       	push   $0x1000
c0105624:	50                   	push   %eax
c0105625:	e8 c2 f9 ff ff       	call   c0104fec <get_pte>
c010562a:	83 c4 10             	add    $0x10,%esp
c010562d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105630:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105634:	75 19                	jne    c010564f <check_pgdir+0x261>
c0105636:	68 3c ba 10 c0       	push   $0xc010ba3c
c010563b:	68 6d b8 10 c0       	push   $0xc010b86d
c0105640:	68 1d 02 00 00       	push   $0x21d
c0105645:	68 48 b8 10 c0       	push   $0xc010b848
c010564a:	e8 9f c1 ff ff       	call   c01017ee <__panic>
    assert(*ptep & PTE_U);
c010564f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105652:	8b 00                	mov    (%eax),%eax
c0105654:	83 e0 04             	and    $0x4,%eax
c0105657:	85 c0                	test   %eax,%eax
c0105659:	75 19                	jne    c0105674 <check_pgdir+0x286>
c010565b:	68 6c ba 10 c0       	push   $0xc010ba6c
c0105660:	68 6d b8 10 c0       	push   $0xc010b86d
c0105665:	68 1e 02 00 00       	push   $0x21e
c010566a:	68 48 b8 10 c0       	push   $0xc010b848
c010566f:	e8 7a c1 ff ff       	call   c01017ee <__panic>
    assert(*ptep & PTE_W);
c0105674:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105677:	8b 00                	mov    (%eax),%eax
c0105679:	83 e0 02             	and    $0x2,%eax
c010567c:	85 c0                	test   %eax,%eax
c010567e:	75 19                	jne    c0105699 <check_pgdir+0x2ab>
c0105680:	68 7a ba 10 c0       	push   $0xc010ba7a
c0105685:	68 6d b8 10 c0       	push   $0xc010b86d
c010568a:	68 1f 02 00 00       	push   $0x21f
c010568f:	68 48 b8 10 c0       	push   $0xc010b848
c0105694:	e8 55 c1 ff ff       	call   c01017ee <__panic>
    assert(boot_pgdir[0] & PTE_U);
c0105699:	a1 e0 b9 12 c0       	mov    0xc012b9e0,%eax
c010569e:	8b 00                	mov    (%eax),%eax
c01056a0:	83 e0 04             	and    $0x4,%eax
c01056a3:	85 c0                	test   %eax,%eax
c01056a5:	75 19                	jne    c01056c0 <check_pgdir+0x2d2>
c01056a7:	68 88 ba 10 c0       	push   $0xc010ba88
c01056ac:	68 6d b8 10 c0       	push   $0xc010b86d
c01056b1:	68 20 02 00 00       	push   $0x220
c01056b6:	68 48 b8 10 c0       	push   $0xc010b848
c01056bb:	e8 2e c1 ff ff       	call   c01017ee <__panic>
    assert(page_ref(p2) == 1);
c01056c0:	83 ec 0c             	sub    $0xc,%esp
c01056c3:	ff 75 e4             	pushl  -0x1c(%ebp)
c01056c6:	e8 88 f0 ff ff       	call   c0104753 <page_ref>
c01056cb:	83 c4 10             	add    $0x10,%esp
c01056ce:	83 f8 01             	cmp    $0x1,%eax
c01056d1:	74 19                	je     c01056ec <check_pgdir+0x2fe>
c01056d3:	68 9e ba 10 c0       	push   $0xc010ba9e
c01056d8:	68 6d b8 10 c0       	push   $0xc010b86d
c01056dd:	68 21 02 00 00       	push   $0x221
c01056e2:	68 48 b8 10 c0       	push   $0xc010b848
c01056e7:	e8 02 c1 ff ff       	call   c01017ee <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c01056ec:	a1 e0 b9 12 c0       	mov    0xc012b9e0,%eax
c01056f1:	6a 00                	push   $0x0
c01056f3:	68 00 10 00 00       	push   $0x1000
c01056f8:	ff 75 f4             	pushl  -0xc(%ebp)
c01056fb:	50                   	push   %eax
c01056fc:	e8 08 fb ff ff       	call   c0105209 <page_insert>
c0105701:	83 c4 10             	add    $0x10,%esp
c0105704:	85 c0                	test   %eax,%eax
c0105706:	74 19                	je     c0105721 <check_pgdir+0x333>
c0105708:	68 b0 ba 10 c0       	push   $0xc010bab0
c010570d:	68 6d b8 10 c0       	push   $0xc010b86d
c0105712:	68 23 02 00 00       	push   $0x223
c0105717:	68 48 b8 10 c0       	push   $0xc010b848
c010571c:	e8 cd c0 ff ff       	call   c01017ee <__panic>
    assert(page_ref(p1) == 2);
c0105721:	83 ec 0c             	sub    $0xc,%esp
c0105724:	ff 75 f4             	pushl  -0xc(%ebp)
c0105727:	e8 27 f0 ff ff       	call   c0104753 <page_ref>
c010572c:	83 c4 10             	add    $0x10,%esp
c010572f:	83 f8 02             	cmp    $0x2,%eax
c0105732:	74 19                	je     c010574d <check_pgdir+0x35f>
c0105734:	68 dc ba 10 c0       	push   $0xc010badc
c0105739:	68 6d b8 10 c0       	push   $0xc010b86d
c010573e:	68 24 02 00 00       	push   $0x224
c0105743:	68 48 b8 10 c0       	push   $0xc010b848
c0105748:	e8 a1 c0 ff ff       	call   c01017ee <__panic>
    assert(page_ref(p2) == 0);
c010574d:	83 ec 0c             	sub    $0xc,%esp
c0105750:	ff 75 e4             	pushl  -0x1c(%ebp)
c0105753:	e8 fb ef ff ff       	call   c0104753 <page_ref>
c0105758:	83 c4 10             	add    $0x10,%esp
c010575b:	85 c0                	test   %eax,%eax
c010575d:	74 19                	je     c0105778 <check_pgdir+0x38a>
c010575f:	68 ee ba 10 c0       	push   $0xc010baee
c0105764:	68 6d b8 10 c0       	push   $0xc010b86d
c0105769:	68 25 02 00 00       	push   $0x225
c010576e:	68 48 b8 10 c0       	push   $0xc010b848
c0105773:	e8 76 c0 ff ff       	call   c01017ee <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0105778:	a1 e0 b9 12 c0       	mov    0xc012b9e0,%eax
c010577d:	83 ec 04             	sub    $0x4,%esp
c0105780:	6a 00                	push   $0x0
c0105782:	68 00 10 00 00       	push   $0x1000
c0105787:	50                   	push   %eax
c0105788:	e8 5f f8 ff ff       	call   c0104fec <get_pte>
c010578d:	83 c4 10             	add    $0x10,%esp
c0105790:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105793:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105797:	75 19                	jne    c01057b2 <check_pgdir+0x3c4>
c0105799:	68 3c ba 10 c0       	push   $0xc010ba3c
c010579e:	68 6d b8 10 c0       	push   $0xc010b86d
c01057a3:	68 26 02 00 00       	push   $0x226
c01057a8:	68 48 b8 10 c0       	push   $0xc010b848
c01057ad:	e8 3c c0 ff ff       	call   c01017ee <__panic>
    assert(pte2page(*ptep) == p1);
c01057b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01057b5:	8b 00                	mov    (%eax),%eax
c01057b7:	83 ec 0c             	sub    $0xc,%esp
c01057ba:	50                   	push   %eax
c01057bb:	e8 3d ef ff ff       	call   c01046fd <pte2page>
c01057c0:	83 c4 10             	add    $0x10,%esp
c01057c3:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01057c6:	74 19                	je     c01057e1 <check_pgdir+0x3f3>
c01057c8:	68 b1 b9 10 c0       	push   $0xc010b9b1
c01057cd:	68 6d b8 10 c0       	push   $0xc010b86d
c01057d2:	68 27 02 00 00       	push   $0x227
c01057d7:	68 48 b8 10 c0       	push   $0xc010b848
c01057dc:	e8 0d c0 ff ff       	call   c01017ee <__panic>
    assert((*ptep & PTE_U) == 0);
c01057e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01057e4:	8b 00                	mov    (%eax),%eax
c01057e6:	83 e0 04             	and    $0x4,%eax
c01057e9:	85 c0                	test   %eax,%eax
c01057eb:	74 19                	je     c0105806 <check_pgdir+0x418>
c01057ed:	68 00 bb 10 c0       	push   $0xc010bb00
c01057f2:	68 6d b8 10 c0       	push   $0xc010b86d
c01057f7:	68 28 02 00 00       	push   $0x228
c01057fc:	68 48 b8 10 c0       	push   $0xc010b848
c0105801:	e8 e8 bf ff ff       	call   c01017ee <__panic>

    page_remove(boot_pgdir, 0x0);
c0105806:	a1 e0 b9 12 c0       	mov    0xc012b9e0,%eax
c010580b:	83 ec 08             	sub    $0x8,%esp
c010580e:	6a 00                	push   $0x0
c0105810:	50                   	push   %eax
c0105811:	e8 b6 f9 ff ff       	call   c01051cc <page_remove>
c0105816:	83 c4 10             	add    $0x10,%esp
    assert(page_ref(p1) == 1);
c0105819:	83 ec 0c             	sub    $0xc,%esp
c010581c:	ff 75 f4             	pushl  -0xc(%ebp)
c010581f:	e8 2f ef ff ff       	call   c0104753 <page_ref>
c0105824:	83 c4 10             	add    $0x10,%esp
c0105827:	83 f8 01             	cmp    $0x1,%eax
c010582a:	74 19                	je     c0105845 <check_pgdir+0x457>
c010582c:	68 c7 b9 10 c0       	push   $0xc010b9c7
c0105831:	68 6d b8 10 c0       	push   $0xc010b86d
c0105836:	68 2b 02 00 00       	push   $0x22b
c010583b:	68 48 b8 10 c0       	push   $0xc010b848
c0105840:	e8 a9 bf ff ff       	call   c01017ee <__panic>
    assert(page_ref(p2) == 0);
c0105845:	83 ec 0c             	sub    $0xc,%esp
c0105848:	ff 75 e4             	pushl  -0x1c(%ebp)
c010584b:	e8 03 ef ff ff       	call   c0104753 <page_ref>
c0105850:	83 c4 10             	add    $0x10,%esp
c0105853:	85 c0                	test   %eax,%eax
c0105855:	74 19                	je     c0105870 <check_pgdir+0x482>
c0105857:	68 ee ba 10 c0       	push   $0xc010baee
c010585c:	68 6d b8 10 c0       	push   $0xc010b86d
c0105861:	68 2c 02 00 00       	push   $0x22c
c0105866:	68 48 b8 10 c0       	push   $0xc010b848
c010586b:	e8 7e bf ff ff       	call   c01017ee <__panic>

    page_remove(boot_pgdir, PGSIZE);
c0105870:	a1 e0 b9 12 c0       	mov    0xc012b9e0,%eax
c0105875:	83 ec 08             	sub    $0x8,%esp
c0105878:	68 00 10 00 00       	push   $0x1000
c010587d:	50                   	push   %eax
c010587e:	e8 49 f9 ff ff       	call   c01051cc <page_remove>
c0105883:	83 c4 10             	add    $0x10,%esp
    assert(page_ref(p1) == 0);
c0105886:	83 ec 0c             	sub    $0xc,%esp
c0105889:	ff 75 f4             	pushl  -0xc(%ebp)
c010588c:	e8 c2 ee ff ff       	call   c0104753 <page_ref>
c0105891:	83 c4 10             	add    $0x10,%esp
c0105894:	85 c0                	test   %eax,%eax
c0105896:	74 19                	je     c01058b1 <check_pgdir+0x4c3>
c0105898:	68 15 bb 10 c0       	push   $0xc010bb15
c010589d:	68 6d b8 10 c0       	push   $0xc010b86d
c01058a2:	68 2f 02 00 00       	push   $0x22f
c01058a7:	68 48 b8 10 c0       	push   $0xc010b848
c01058ac:	e8 3d bf ff ff       	call   c01017ee <__panic>
    assert(page_ref(p2) == 0);
c01058b1:	83 ec 0c             	sub    $0xc,%esp
c01058b4:	ff 75 e4             	pushl  -0x1c(%ebp)
c01058b7:	e8 97 ee ff ff       	call   c0104753 <page_ref>
c01058bc:	83 c4 10             	add    $0x10,%esp
c01058bf:	85 c0                	test   %eax,%eax
c01058c1:	74 19                	je     c01058dc <check_pgdir+0x4ee>
c01058c3:	68 ee ba 10 c0       	push   $0xc010baee
c01058c8:	68 6d b8 10 c0       	push   $0xc010b86d
c01058cd:	68 30 02 00 00       	push   $0x230
c01058d2:	68 48 b8 10 c0       	push   $0xc010b848
c01058d7:	e8 12 bf ff ff       	call   c01017ee <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c01058dc:	a1 e0 b9 12 c0       	mov    0xc012b9e0,%eax
c01058e1:	8b 00                	mov    (%eax),%eax
c01058e3:	83 ec 0c             	sub    $0xc,%esp
c01058e6:	50                   	push   %eax
c01058e7:	e8 4b ee ff ff       	call   c0104737 <pde2page>
c01058ec:	83 c4 10             	add    $0x10,%esp
c01058ef:	83 ec 0c             	sub    $0xc,%esp
c01058f2:	50                   	push   %eax
c01058f3:	e8 5b ee ff ff       	call   c0104753 <page_ref>
c01058f8:	83 c4 10             	add    $0x10,%esp
c01058fb:	83 f8 01             	cmp    $0x1,%eax
c01058fe:	74 19                	je     c0105919 <check_pgdir+0x52b>
c0105900:	68 28 bb 10 c0       	push   $0xc010bb28
c0105905:	68 6d b8 10 c0       	push   $0xc010b86d
c010590a:	68 32 02 00 00       	push   $0x232
c010590f:	68 48 b8 10 c0       	push   $0xc010b848
c0105914:	e8 d5 be ff ff       	call   c01017ee <__panic>
    free_page(pde2page(boot_pgdir[0]));
c0105919:	a1 e0 b9 12 c0       	mov    0xc012b9e0,%eax
c010591e:	8b 00                	mov    (%eax),%eax
c0105920:	83 ec 0c             	sub    $0xc,%esp
c0105923:	50                   	push   %eax
c0105924:	e8 0e ee ff ff       	call   c0104737 <pde2page>
c0105929:	83 c4 10             	add    $0x10,%esp
c010592c:	83 ec 08             	sub    $0x8,%esp
c010592f:	6a 01                	push   $0x1
c0105931:	50                   	push   %eax
c0105932:	e8 ab f0 ff ff       	call   c01049e2 <free_pages>
c0105937:	83 c4 10             	add    $0x10,%esp
    boot_pgdir[0] = 0;
c010593a:	a1 e0 b9 12 c0       	mov    0xc012b9e0,%eax
c010593f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0105945:	83 ec 0c             	sub    $0xc,%esp
c0105948:	68 4f bb 10 c0       	push   $0xc010bb4f
c010594d:	e8 60 a9 ff ff       	call   c01002b2 <cprintf>
c0105952:	83 c4 10             	add    $0x10,%esp
}
c0105955:	90                   	nop
c0105956:	c9                   	leave  
c0105957:	c3                   	ret    

c0105958 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c0105958:	f3 0f 1e fb          	endbr32 
c010595c:	55                   	push   %ebp
c010595d:	89 e5                	mov    %esp,%ebp
c010595f:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0105962:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0105969:	e9 a3 00 00 00       	jmp    c0105a11 <check_boot_pgdir+0xb9>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c010596e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105971:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105974:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105977:	c1 e8 0c             	shr    $0xc,%eax
c010597a:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010597d:	a1 80 ef 12 c0       	mov    0xc012ef80,%eax
c0105982:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0105985:	72 17                	jb     c010599e <check_boot_pgdir+0x46>
c0105987:	ff 75 e4             	pushl  -0x1c(%ebp)
c010598a:	68 80 b7 10 c0       	push   $0xc010b780
c010598f:	68 3e 02 00 00       	push   $0x23e
c0105994:	68 48 b8 10 c0       	push   $0xc010b848
c0105999:	e8 50 be ff ff       	call   c01017ee <__panic>
c010599e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01059a1:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01059a6:	89 c2                	mov    %eax,%edx
c01059a8:	a1 e0 b9 12 c0       	mov    0xc012b9e0,%eax
c01059ad:	83 ec 04             	sub    $0x4,%esp
c01059b0:	6a 00                	push   $0x0
c01059b2:	52                   	push   %edx
c01059b3:	50                   	push   %eax
c01059b4:	e8 33 f6 ff ff       	call   c0104fec <get_pte>
c01059b9:	83 c4 10             	add    $0x10,%esp
c01059bc:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01059bf:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c01059c3:	75 19                	jne    c01059de <check_boot_pgdir+0x86>
c01059c5:	68 6c bb 10 c0       	push   $0xc010bb6c
c01059ca:	68 6d b8 10 c0       	push   $0xc010b86d
c01059cf:	68 3e 02 00 00       	push   $0x23e
c01059d4:	68 48 b8 10 c0       	push   $0xc010b848
c01059d9:	e8 10 be ff ff       	call   c01017ee <__panic>
        assert(PTE_ADDR(*ptep) == i);
c01059de:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01059e1:	8b 00                	mov    (%eax),%eax
c01059e3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01059e8:	89 c2                	mov    %eax,%edx
c01059ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01059ed:	39 c2                	cmp    %eax,%edx
c01059ef:	74 19                	je     c0105a0a <check_boot_pgdir+0xb2>
c01059f1:	68 a9 bb 10 c0       	push   $0xc010bba9
c01059f6:	68 6d b8 10 c0       	push   $0xc010b86d
c01059fb:	68 3f 02 00 00       	push   $0x23f
c0105a00:	68 48 b8 10 c0       	push   $0xc010b848
c0105a05:	e8 e4 bd ff ff       	call   c01017ee <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
c0105a0a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c0105a11:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105a14:	a1 80 ef 12 c0       	mov    0xc012ef80,%eax
c0105a19:	39 c2                	cmp    %eax,%edx
c0105a1b:	0f 82 4d ff ff ff    	jb     c010596e <check_boot_pgdir+0x16>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c0105a21:	a1 e0 b9 12 c0       	mov    0xc012b9e0,%eax
c0105a26:	05 ac 0f 00 00       	add    $0xfac,%eax
c0105a2b:	8b 00                	mov    (%eax),%eax
c0105a2d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105a32:	89 c2                	mov    %eax,%edx
c0105a34:	a1 e0 b9 12 c0       	mov    0xc012b9e0,%eax
c0105a39:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105a3c:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0105a43:	77 17                	ja     c0105a5c <check_boot_pgdir+0x104>
c0105a45:	ff 75 f0             	pushl  -0x10(%ebp)
c0105a48:	68 24 b8 10 c0       	push   $0xc010b824
c0105a4d:	68 42 02 00 00       	push   $0x242
c0105a52:	68 48 b8 10 c0       	push   $0xc010b848
c0105a57:	e8 92 bd ff ff       	call   c01017ee <__panic>
c0105a5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105a5f:	05 00 00 00 40       	add    $0x40000000,%eax
c0105a64:	39 d0                	cmp    %edx,%eax
c0105a66:	74 19                	je     c0105a81 <check_boot_pgdir+0x129>
c0105a68:	68 c0 bb 10 c0       	push   $0xc010bbc0
c0105a6d:	68 6d b8 10 c0       	push   $0xc010b86d
c0105a72:	68 42 02 00 00       	push   $0x242
c0105a77:	68 48 b8 10 c0       	push   $0xc010b848
c0105a7c:	e8 6d bd ff ff       	call   c01017ee <__panic>

    assert(boot_pgdir[0] == 0);
c0105a81:	a1 e0 b9 12 c0       	mov    0xc012b9e0,%eax
c0105a86:	8b 00                	mov    (%eax),%eax
c0105a88:	85 c0                	test   %eax,%eax
c0105a8a:	74 19                	je     c0105aa5 <check_boot_pgdir+0x14d>
c0105a8c:	68 f4 bb 10 c0       	push   $0xc010bbf4
c0105a91:	68 6d b8 10 c0       	push   $0xc010b86d
c0105a96:	68 44 02 00 00       	push   $0x244
c0105a9b:	68 48 b8 10 c0       	push   $0xc010b848
c0105aa0:	e8 49 bd ff ff       	call   c01017ee <__panic>

    struct Page *p;
    p = alloc_page();
c0105aa5:	83 ec 0c             	sub    $0xc,%esp
c0105aa8:	6a 01                	push   $0x1
c0105aaa:	e8 c3 ee ff ff       	call   c0104972 <alloc_pages>
c0105aaf:	83 c4 10             	add    $0x10,%esp
c0105ab2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0105ab5:	a1 e0 b9 12 c0       	mov    0xc012b9e0,%eax
c0105aba:	6a 02                	push   $0x2
c0105abc:	68 00 01 00 00       	push   $0x100
c0105ac1:	ff 75 ec             	pushl  -0x14(%ebp)
c0105ac4:	50                   	push   %eax
c0105ac5:	e8 3f f7 ff ff       	call   c0105209 <page_insert>
c0105aca:	83 c4 10             	add    $0x10,%esp
c0105acd:	85 c0                	test   %eax,%eax
c0105acf:	74 19                	je     c0105aea <check_boot_pgdir+0x192>
c0105ad1:	68 08 bc 10 c0       	push   $0xc010bc08
c0105ad6:	68 6d b8 10 c0       	push   $0xc010b86d
c0105adb:	68 48 02 00 00       	push   $0x248
c0105ae0:	68 48 b8 10 c0       	push   $0xc010b848
c0105ae5:	e8 04 bd ff ff       	call   c01017ee <__panic>
    assert(page_ref(p) == 1);
c0105aea:	83 ec 0c             	sub    $0xc,%esp
c0105aed:	ff 75 ec             	pushl  -0x14(%ebp)
c0105af0:	e8 5e ec ff ff       	call   c0104753 <page_ref>
c0105af5:	83 c4 10             	add    $0x10,%esp
c0105af8:	83 f8 01             	cmp    $0x1,%eax
c0105afb:	74 19                	je     c0105b16 <check_boot_pgdir+0x1be>
c0105afd:	68 36 bc 10 c0       	push   $0xc010bc36
c0105b02:	68 6d b8 10 c0       	push   $0xc010b86d
c0105b07:	68 49 02 00 00       	push   $0x249
c0105b0c:	68 48 b8 10 c0       	push   $0xc010b848
c0105b11:	e8 d8 bc ff ff       	call   c01017ee <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c0105b16:	a1 e0 b9 12 c0       	mov    0xc012b9e0,%eax
c0105b1b:	6a 02                	push   $0x2
c0105b1d:	68 00 11 00 00       	push   $0x1100
c0105b22:	ff 75 ec             	pushl  -0x14(%ebp)
c0105b25:	50                   	push   %eax
c0105b26:	e8 de f6 ff ff       	call   c0105209 <page_insert>
c0105b2b:	83 c4 10             	add    $0x10,%esp
c0105b2e:	85 c0                	test   %eax,%eax
c0105b30:	74 19                	je     c0105b4b <check_boot_pgdir+0x1f3>
c0105b32:	68 48 bc 10 c0       	push   $0xc010bc48
c0105b37:	68 6d b8 10 c0       	push   $0xc010b86d
c0105b3c:	68 4a 02 00 00       	push   $0x24a
c0105b41:	68 48 b8 10 c0       	push   $0xc010b848
c0105b46:	e8 a3 bc ff ff       	call   c01017ee <__panic>
    assert(page_ref(p) == 2);
c0105b4b:	83 ec 0c             	sub    $0xc,%esp
c0105b4e:	ff 75 ec             	pushl  -0x14(%ebp)
c0105b51:	e8 fd eb ff ff       	call   c0104753 <page_ref>
c0105b56:	83 c4 10             	add    $0x10,%esp
c0105b59:	83 f8 02             	cmp    $0x2,%eax
c0105b5c:	74 19                	je     c0105b77 <check_boot_pgdir+0x21f>
c0105b5e:	68 7f bc 10 c0       	push   $0xc010bc7f
c0105b63:	68 6d b8 10 c0       	push   $0xc010b86d
c0105b68:	68 4b 02 00 00       	push   $0x24b
c0105b6d:	68 48 b8 10 c0       	push   $0xc010b848
c0105b72:	e8 77 bc ff ff       	call   c01017ee <__panic>

    const char *str = "ucore: Hello world!!";
c0105b77:	c7 45 e8 90 bc 10 c0 	movl   $0xc010bc90,-0x18(%ebp)
    strcpy((void *)0x100, str);
c0105b7e:	83 ec 08             	sub    $0x8,%esp
c0105b81:	ff 75 e8             	pushl  -0x18(%ebp)
c0105b84:	68 00 01 00 00       	push   $0x100
c0105b89:	e8 63 44 00 00       	call   c0109ff1 <strcpy>
c0105b8e:	83 c4 10             	add    $0x10,%esp
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c0105b91:	83 ec 08             	sub    $0x8,%esp
c0105b94:	68 00 11 00 00       	push   $0x1100
c0105b99:	68 00 01 00 00       	push   $0x100
c0105b9e:	e8 cf 44 00 00       	call   c010a072 <strcmp>
c0105ba3:	83 c4 10             	add    $0x10,%esp
c0105ba6:	85 c0                	test   %eax,%eax
c0105ba8:	74 19                	je     c0105bc3 <check_boot_pgdir+0x26b>
c0105baa:	68 a8 bc 10 c0       	push   $0xc010bca8
c0105baf:	68 6d b8 10 c0       	push   $0xc010b86d
c0105bb4:	68 4f 02 00 00       	push   $0x24f
c0105bb9:	68 48 b8 10 c0       	push   $0xc010b848
c0105bbe:	e8 2b bc ff ff       	call   c01017ee <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c0105bc3:	83 ec 0c             	sub    $0xc,%esp
c0105bc6:	ff 75 ec             	pushl  -0x14(%ebp)
c0105bc9:	e8 ea ea ff ff       	call   c01046b8 <page2kva>
c0105bce:	83 c4 10             	add    $0x10,%esp
c0105bd1:	05 00 01 00 00       	add    $0x100,%eax
c0105bd6:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c0105bd9:	83 ec 0c             	sub    $0xc,%esp
c0105bdc:	68 00 01 00 00       	push   $0x100
c0105be1:	e8 ab 43 00 00       	call   c0109f91 <strlen>
c0105be6:	83 c4 10             	add    $0x10,%esp
c0105be9:	85 c0                	test   %eax,%eax
c0105beb:	74 19                	je     c0105c06 <check_boot_pgdir+0x2ae>
c0105bed:	68 e0 bc 10 c0       	push   $0xc010bce0
c0105bf2:	68 6d b8 10 c0       	push   $0xc010b86d
c0105bf7:	68 52 02 00 00       	push   $0x252
c0105bfc:	68 48 b8 10 c0       	push   $0xc010b848
c0105c01:	e8 e8 bb ff ff       	call   c01017ee <__panic>

    free_page(p);
c0105c06:	83 ec 08             	sub    $0x8,%esp
c0105c09:	6a 01                	push   $0x1
c0105c0b:	ff 75 ec             	pushl  -0x14(%ebp)
c0105c0e:	e8 cf ed ff ff       	call   c01049e2 <free_pages>
c0105c13:	83 c4 10             	add    $0x10,%esp
    free_page(pde2page(boot_pgdir[0]));
c0105c16:	a1 e0 b9 12 c0       	mov    0xc012b9e0,%eax
c0105c1b:	8b 00                	mov    (%eax),%eax
c0105c1d:	83 ec 0c             	sub    $0xc,%esp
c0105c20:	50                   	push   %eax
c0105c21:	e8 11 eb ff ff       	call   c0104737 <pde2page>
c0105c26:	83 c4 10             	add    $0x10,%esp
c0105c29:	83 ec 08             	sub    $0x8,%esp
c0105c2c:	6a 01                	push   $0x1
c0105c2e:	50                   	push   %eax
c0105c2f:	e8 ae ed ff ff       	call   c01049e2 <free_pages>
c0105c34:	83 c4 10             	add    $0x10,%esp
    boot_pgdir[0] = 0;
c0105c37:	a1 e0 b9 12 c0       	mov    0xc012b9e0,%eax
c0105c3c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c0105c42:	83 ec 0c             	sub    $0xc,%esp
c0105c45:	68 04 bd 10 c0       	push   $0xc010bd04
c0105c4a:	e8 63 a6 ff ff       	call   c01002b2 <cprintf>
c0105c4f:	83 c4 10             	add    $0x10,%esp
}
c0105c52:	90                   	nop
c0105c53:	c9                   	leave  
c0105c54:	c3                   	ret    

c0105c55 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0105c55:	f3 0f 1e fb          	endbr32 
c0105c59:	55                   	push   %ebp
c0105c5a:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c0105c5c:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c5f:	83 e0 04             	and    $0x4,%eax
c0105c62:	85 c0                	test   %eax,%eax
c0105c64:	74 07                	je     c0105c6d <perm2str+0x18>
c0105c66:	b8 75 00 00 00       	mov    $0x75,%eax
c0105c6b:	eb 05                	jmp    c0105c72 <perm2str+0x1d>
c0105c6d:	b8 2d 00 00 00       	mov    $0x2d,%eax
c0105c72:	a2 08 f0 12 c0       	mov    %al,0xc012f008
    str[1] = 'r';
c0105c77:	c6 05 09 f0 12 c0 72 	movb   $0x72,0xc012f009
    str[2] = (perm & PTE_W) ? 'w' : '-';
c0105c7e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c81:	83 e0 02             	and    $0x2,%eax
c0105c84:	85 c0                	test   %eax,%eax
c0105c86:	74 07                	je     c0105c8f <perm2str+0x3a>
c0105c88:	b8 77 00 00 00       	mov    $0x77,%eax
c0105c8d:	eb 05                	jmp    c0105c94 <perm2str+0x3f>
c0105c8f:	b8 2d 00 00 00       	mov    $0x2d,%eax
c0105c94:	a2 0a f0 12 c0       	mov    %al,0xc012f00a
    str[3] = '\0';
c0105c99:	c6 05 0b f0 12 c0 00 	movb   $0x0,0xc012f00b
    return str;
c0105ca0:	b8 08 f0 12 c0       	mov    $0xc012f008,%eax
}
c0105ca5:	5d                   	pop    %ebp
c0105ca6:	c3                   	ret    

c0105ca7 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c0105ca7:	f3 0f 1e fb          	endbr32 
c0105cab:	55                   	push   %ebp
c0105cac:	89 e5                	mov    %esp,%ebp
c0105cae:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c0105cb1:	8b 45 10             	mov    0x10(%ebp),%eax
c0105cb4:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105cb7:	72 0e                	jb     c0105cc7 <get_pgtable_items+0x20>
        return 0;
c0105cb9:	b8 00 00 00 00       	mov    $0x0,%eax
c0105cbe:	e9 9a 00 00 00       	jmp    c0105d5d <get_pgtable_items+0xb6>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
c0105cc3:	83 45 10 01          	addl   $0x1,0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
c0105cc7:	8b 45 10             	mov    0x10(%ebp),%eax
c0105cca:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105ccd:	73 18                	jae    c0105ce7 <get_pgtable_items+0x40>
c0105ccf:	8b 45 10             	mov    0x10(%ebp),%eax
c0105cd2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105cd9:	8b 45 14             	mov    0x14(%ebp),%eax
c0105cdc:	01 d0                	add    %edx,%eax
c0105cde:	8b 00                	mov    (%eax),%eax
c0105ce0:	83 e0 01             	and    $0x1,%eax
c0105ce3:	85 c0                	test   %eax,%eax
c0105ce5:	74 dc                	je     c0105cc3 <get_pgtable_items+0x1c>
    }
    if (start < right) {
c0105ce7:	8b 45 10             	mov    0x10(%ebp),%eax
c0105cea:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105ced:	73 69                	jae    c0105d58 <get_pgtable_items+0xb1>
        if (left_store != NULL) {
c0105cef:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0105cf3:	74 08                	je     c0105cfd <get_pgtable_items+0x56>
            *left_store = start;
c0105cf5:	8b 45 18             	mov    0x18(%ebp),%eax
c0105cf8:	8b 55 10             	mov    0x10(%ebp),%edx
c0105cfb:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c0105cfd:	8b 45 10             	mov    0x10(%ebp),%eax
c0105d00:	8d 50 01             	lea    0x1(%eax),%edx
c0105d03:	89 55 10             	mov    %edx,0x10(%ebp)
c0105d06:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105d0d:	8b 45 14             	mov    0x14(%ebp),%eax
c0105d10:	01 d0                	add    %edx,%eax
c0105d12:	8b 00                	mov    (%eax),%eax
c0105d14:	83 e0 07             	and    $0x7,%eax
c0105d17:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0105d1a:	eb 04                	jmp    c0105d20 <get_pgtable_items+0x79>
            start ++;
c0105d1c:	83 45 10 01          	addl   $0x1,0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0105d20:	8b 45 10             	mov    0x10(%ebp),%eax
c0105d23:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105d26:	73 1d                	jae    c0105d45 <get_pgtable_items+0x9e>
c0105d28:	8b 45 10             	mov    0x10(%ebp),%eax
c0105d2b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105d32:	8b 45 14             	mov    0x14(%ebp),%eax
c0105d35:	01 d0                	add    %edx,%eax
c0105d37:	8b 00                	mov    (%eax),%eax
c0105d39:	83 e0 07             	and    $0x7,%eax
c0105d3c:	89 c2                	mov    %eax,%edx
c0105d3e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105d41:	39 c2                	cmp    %eax,%edx
c0105d43:	74 d7                	je     c0105d1c <get_pgtable_items+0x75>
        }
        if (right_store != NULL) {
c0105d45:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0105d49:	74 08                	je     c0105d53 <get_pgtable_items+0xac>
            *right_store = start;
c0105d4b:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0105d4e:	8b 55 10             	mov    0x10(%ebp),%edx
c0105d51:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c0105d53:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105d56:	eb 05                	jmp    c0105d5d <get_pgtable_items+0xb6>
    }
    return 0;
c0105d58:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105d5d:	c9                   	leave  
c0105d5e:	c3                   	ret    

c0105d5f <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c0105d5f:	f3 0f 1e fb          	endbr32 
c0105d63:	55                   	push   %ebp
c0105d64:	89 e5                	mov    %esp,%ebp
c0105d66:	57                   	push   %edi
c0105d67:	56                   	push   %esi
c0105d68:	53                   	push   %ebx
c0105d69:	83 ec 2c             	sub    $0x2c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c0105d6c:	83 ec 0c             	sub    $0xc,%esp
c0105d6f:	68 24 bd 10 c0       	push   $0xc010bd24
c0105d74:	e8 39 a5 ff ff       	call   c01002b2 <cprintf>
c0105d79:	83 c4 10             	add    $0x10,%esp
    size_t left, right = 0, perm;
c0105d7c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0105d83:	e9 e1 00 00 00       	jmp    c0105e69 <print_pgdir+0x10a>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0105d88:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105d8b:	83 ec 0c             	sub    $0xc,%esp
c0105d8e:	50                   	push   %eax
c0105d8f:	e8 c1 fe ff ff       	call   c0105c55 <perm2str>
c0105d94:	83 c4 10             	add    $0x10,%esp
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0105d97:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0105d9a:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105d9d:	29 d1                	sub    %edx,%ecx
c0105d9f:	89 ca                	mov    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0105da1:	89 d6                	mov    %edx,%esi
c0105da3:	c1 e6 16             	shl    $0x16,%esi
c0105da6:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105da9:	89 d3                	mov    %edx,%ebx
c0105dab:	c1 e3 16             	shl    $0x16,%ebx
c0105dae:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105db1:	89 d1                	mov    %edx,%ecx
c0105db3:	c1 e1 16             	shl    $0x16,%ecx
c0105db6:	8b 7d dc             	mov    -0x24(%ebp),%edi
c0105db9:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105dbc:	29 d7                	sub    %edx,%edi
c0105dbe:	89 fa                	mov    %edi,%edx
c0105dc0:	83 ec 08             	sub    $0x8,%esp
c0105dc3:	50                   	push   %eax
c0105dc4:	56                   	push   %esi
c0105dc5:	53                   	push   %ebx
c0105dc6:	51                   	push   %ecx
c0105dc7:	52                   	push   %edx
c0105dc8:	68 55 bd 10 c0       	push   $0xc010bd55
c0105dcd:	e8 e0 a4 ff ff       	call   c01002b2 <cprintf>
c0105dd2:	83 c4 20             	add    $0x20,%esp
        size_t l, r = left * NPTEENTRY;
c0105dd5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105dd8:	c1 e0 0a             	shl    $0xa,%eax
c0105ddb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0105dde:	eb 4d                	jmp    c0105e2d <print_pgdir+0xce>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0105de0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105de3:	83 ec 0c             	sub    $0xc,%esp
c0105de6:	50                   	push   %eax
c0105de7:	e8 69 fe ff ff       	call   c0105c55 <perm2str>
c0105dec:	83 c4 10             	add    $0x10,%esp
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c0105def:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c0105df2:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0105df5:	29 d1                	sub    %edx,%ecx
c0105df7:	89 ca                	mov    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0105df9:	89 d6                	mov    %edx,%esi
c0105dfb:	c1 e6 0c             	shl    $0xc,%esi
c0105dfe:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105e01:	89 d3                	mov    %edx,%ebx
c0105e03:	c1 e3 0c             	shl    $0xc,%ebx
c0105e06:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0105e09:	89 d1                	mov    %edx,%ecx
c0105e0b:	c1 e1 0c             	shl    $0xc,%ecx
c0105e0e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c0105e11:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0105e14:	29 d7                	sub    %edx,%edi
c0105e16:	89 fa                	mov    %edi,%edx
c0105e18:	83 ec 08             	sub    $0x8,%esp
c0105e1b:	50                   	push   %eax
c0105e1c:	56                   	push   %esi
c0105e1d:	53                   	push   %ebx
c0105e1e:	51                   	push   %ecx
c0105e1f:	52                   	push   %edx
c0105e20:	68 74 bd 10 c0       	push   $0xc010bd74
c0105e25:	e8 88 a4 ff ff       	call   c01002b2 <cprintf>
c0105e2a:	83 c4 20             	add    $0x20,%esp
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0105e2d:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
c0105e32:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105e35:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105e38:	89 d3                	mov    %edx,%ebx
c0105e3a:	c1 e3 0a             	shl    $0xa,%ebx
c0105e3d:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105e40:	89 d1                	mov    %edx,%ecx
c0105e42:	c1 e1 0a             	shl    $0xa,%ecx
c0105e45:	83 ec 08             	sub    $0x8,%esp
c0105e48:	8d 55 d4             	lea    -0x2c(%ebp),%edx
c0105e4b:	52                   	push   %edx
c0105e4c:	8d 55 d8             	lea    -0x28(%ebp),%edx
c0105e4f:	52                   	push   %edx
c0105e50:	56                   	push   %esi
c0105e51:	50                   	push   %eax
c0105e52:	53                   	push   %ebx
c0105e53:	51                   	push   %ecx
c0105e54:	e8 4e fe ff ff       	call   c0105ca7 <get_pgtable_items>
c0105e59:	83 c4 20             	add    $0x20,%esp
c0105e5c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105e5f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105e63:	0f 85 77 ff ff ff    	jne    c0105de0 <print_pgdir+0x81>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0105e69:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
c0105e6e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105e71:	83 ec 08             	sub    $0x8,%esp
c0105e74:	8d 55 dc             	lea    -0x24(%ebp),%edx
c0105e77:	52                   	push   %edx
c0105e78:	8d 55 e0             	lea    -0x20(%ebp),%edx
c0105e7b:	52                   	push   %edx
c0105e7c:	51                   	push   %ecx
c0105e7d:	50                   	push   %eax
c0105e7e:	68 00 04 00 00       	push   $0x400
c0105e83:	6a 00                	push   $0x0
c0105e85:	e8 1d fe ff ff       	call   c0105ca7 <get_pgtable_items>
c0105e8a:	83 c4 20             	add    $0x20,%esp
c0105e8d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105e90:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105e94:	0f 85 ee fe ff ff    	jne    c0105d88 <print_pgdir+0x29>
        }
    }
    cprintf("--------------------- END ---------------------\n");
c0105e9a:	83 ec 0c             	sub    $0xc,%esp
c0105e9d:	68 98 bd 10 c0       	push   $0xc010bd98
c0105ea2:	e8 0b a4 ff ff       	call   c01002b2 <cprintf>
c0105ea7:	83 c4 10             	add    $0x10,%esp
}
c0105eaa:	90                   	nop
c0105eab:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0105eae:	5b                   	pop    %ebx
c0105eaf:	5e                   	pop    %esi
c0105eb0:	5f                   	pop    %edi
c0105eb1:	5d                   	pop    %ebp
c0105eb2:	c3                   	ret    

c0105eb3 <pa2page>:
pa2page(uintptr_t pa) {
c0105eb3:	55                   	push   %ebp
c0105eb4:	89 e5                	mov    %esp,%ebp
c0105eb6:	83 ec 08             	sub    $0x8,%esp
    if (PPN(pa) >= npage) {
c0105eb9:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ebc:	c1 e8 0c             	shr    $0xc,%eax
c0105ebf:	89 c2                	mov    %eax,%edx
c0105ec1:	a1 80 ef 12 c0       	mov    0xc012ef80,%eax
c0105ec6:	39 c2                	cmp    %eax,%edx
c0105ec8:	72 14                	jb     c0105ede <pa2page+0x2b>
        panic("pa2page called with invalid pa");
c0105eca:	83 ec 04             	sub    $0x4,%esp
c0105ecd:	68 cc bd 10 c0       	push   $0xc010bdcc
c0105ed2:	6a 5f                	push   $0x5f
c0105ed4:	68 eb bd 10 c0       	push   $0xc010bdeb
c0105ed9:	e8 10 b9 ff ff       	call   c01017ee <__panic>
    return &pages[PPN(pa)];
c0105ede:	8b 0d 60 10 13 c0    	mov    0xc0131060,%ecx
c0105ee4:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ee7:	c1 e8 0c             	shr    $0xc,%eax
c0105eea:	89 c2                	mov    %eax,%edx
c0105eec:	89 d0                	mov    %edx,%eax
c0105eee:	c1 e0 03             	shl    $0x3,%eax
c0105ef1:	01 d0                	add    %edx,%eax
c0105ef3:	c1 e0 02             	shl    $0x2,%eax
c0105ef6:	01 c8                	add    %ecx,%eax
}
c0105ef8:	c9                   	leave  
c0105ef9:	c3                   	ret    

c0105efa <pde2page>:
pde2page(pde_t pde) {
c0105efa:	55                   	push   %ebp
c0105efb:	89 e5                	mov    %esp,%ebp
c0105efd:	83 ec 08             	sub    $0x8,%esp
    return pa2page(PDE_ADDR(pde));
c0105f00:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f03:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105f08:	83 ec 0c             	sub    $0xc,%esp
c0105f0b:	50                   	push   %eax
c0105f0c:	e8 a2 ff ff ff       	call   c0105eb3 <pa2page>
c0105f11:	83 c4 10             	add    $0x10,%esp
}
c0105f14:	c9                   	leave  
c0105f15:	c3                   	ret    

c0105f16 <mm_create>:
static void check_vma_struct(void);
static void check_pgfault(void);

// mm_create -  alloc a mm_struct & initialize it.
struct mm_struct *
mm_create(void) {
c0105f16:	f3 0f 1e fb          	endbr32 
c0105f1a:	55                   	push   %ebp
c0105f1b:	89 e5                	mov    %esp,%ebp
c0105f1d:	83 ec 18             	sub    $0x18,%esp
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
c0105f20:	83 ec 0c             	sub    $0xc,%esp
c0105f23:	6a 18                	push   $0x18
c0105f25:	e8 ce 1c 00 00       	call   c0107bf8 <kmalloc>
c0105f2a:	83 c4 10             	add    $0x10,%esp
c0105f2d:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (mm != NULL) {
c0105f30:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105f34:	74 5c                	je     c0105f92 <mm_create+0x7c>
        list_init(&(mm->mmap_list));
c0105f36:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105f39:	89 45 f0             	mov    %eax,-0x10(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0105f3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105f3f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105f42:	89 50 04             	mov    %edx,0x4(%eax)
c0105f45:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105f48:	8b 50 04             	mov    0x4(%eax),%edx
c0105f4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105f4e:	89 10                	mov    %edx,(%eax)
}
c0105f50:	90                   	nop
        mm->mmap_cache = NULL;
c0105f51:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105f54:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        mm->pgdir = NULL;
c0105f5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105f5e:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        mm->map_count = 0;
c0105f65:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105f68:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)

        if (swap_init_ok) swap_init_mm(mm);
c0105f6f:	a1 10 f0 12 c0       	mov    0xc012f010,%eax
c0105f74:	85 c0                	test   %eax,%eax
c0105f76:	74 10                	je     c0105f88 <mm_create+0x72>
c0105f78:	83 ec 0c             	sub    $0xc,%esp
c0105f7b:	ff 75 f4             	pushl  -0xc(%ebp)
c0105f7e:	e8 83 0c 00 00       	call   c0106c06 <swap_init_mm>
c0105f83:	83 c4 10             	add    $0x10,%esp
c0105f86:	eb 0a                	jmp    c0105f92 <mm_create+0x7c>
        else mm->sm_priv = NULL;
c0105f88:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105f8b:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
    }
    return mm;
c0105f92:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105f95:	c9                   	leave  
c0105f96:	c3                   	ret    

c0105f97 <vma_create>:

// vma_create - alloc a vma_struct & initialize it. (addr range: vm_start~vm_end)
struct vma_struct *
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
c0105f97:	f3 0f 1e fb          	endbr32 
c0105f9b:	55                   	push   %ebp
c0105f9c:	89 e5                	mov    %esp,%ebp
c0105f9e:	83 ec 18             	sub    $0x18,%esp
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
c0105fa1:	83 ec 0c             	sub    $0xc,%esp
c0105fa4:	6a 18                	push   $0x18
c0105fa6:	e8 4d 1c 00 00       	call   c0107bf8 <kmalloc>
c0105fab:	83 c4 10             	add    $0x10,%esp
c0105fae:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (vma != NULL) {
c0105fb1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105fb5:	74 1b                	je     c0105fd2 <vma_create+0x3b>
        vma->vm_start = vm_start;
c0105fb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105fba:	8b 55 08             	mov    0x8(%ebp),%edx
c0105fbd:	89 50 04             	mov    %edx,0x4(%eax)
        vma->vm_end = vm_end;
c0105fc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105fc3:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105fc6:	89 50 08             	mov    %edx,0x8(%eax)
        vma->vm_flags = vm_flags;
c0105fc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105fcc:	8b 55 10             	mov    0x10(%ebp),%edx
c0105fcf:	89 50 0c             	mov    %edx,0xc(%eax)
    }
    return vma;
c0105fd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105fd5:	c9                   	leave  
c0105fd6:	c3                   	ret    

c0105fd7 <find_vma>:


// find_vma - find a vma  (vma->vm_start <= addr <= vma_vm_end)
struct vma_struct *
find_vma(struct mm_struct *mm, uintptr_t addr) {
c0105fd7:	f3 0f 1e fb          	endbr32 
c0105fdb:	55                   	push   %ebp
c0105fdc:	89 e5                	mov    %esp,%ebp
c0105fde:	83 ec 20             	sub    $0x20,%esp
    struct vma_struct *vma = NULL;
c0105fe1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    if (mm != NULL) {
c0105fe8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105fec:	0f 84 95 00 00 00    	je     c0106087 <find_vma+0xb0>
        vma = mm->mmap_cache;
c0105ff2:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ff5:	8b 40 08             	mov    0x8(%eax),%eax
c0105ff8:	89 45 fc             	mov    %eax,-0x4(%ebp)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
c0105ffb:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0105fff:	74 16                	je     c0106017 <find_vma+0x40>
c0106001:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106004:	8b 40 04             	mov    0x4(%eax),%eax
c0106007:	39 45 0c             	cmp    %eax,0xc(%ebp)
c010600a:	72 0b                	jb     c0106017 <find_vma+0x40>
c010600c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010600f:	8b 40 08             	mov    0x8(%eax),%eax
c0106012:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0106015:	72 61                	jb     c0106078 <find_vma+0xa1>
                bool found = 0;
c0106017:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
                list_entry_t *list = &(mm->mmap_list), *le = list;
c010601e:	8b 45 08             	mov    0x8(%ebp),%eax
c0106021:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106024:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106027:	89 45 f4             	mov    %eax,-0xc(%ebp)
                while ((le = list_next(le)) != list) {
c010602a:	eb 28                	jmp    c0106054 <find_vma+0x7d>
                    vma = le2vma(le, list_link);
c010602c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010602f:	83 e8 10             	sub    $0x10,%eax
c0106032:	89 45 fc             	mov    %eax,-0x4(%ebp)
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
c0106035:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106038:	8b 40 04             	mov    0x4(%eax),%eax
c010603b:	39 45 0c             	cmp    %eax,0xc(%ebp)
c010603e:	72 14                	jb     c0106054 <find_vma+0x7d>
c0106040:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106043:	8b 40 08             	mov    0x8(%eax),%eax
c0106046:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0106049:	73 09                	jae    c0106054 <find_vma+0x7d>
                        found = 1;
c010604b:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%ebp)
                        break;
c0106052:	eb 17                	jmp    c010606b <find_vma+0x94>
c0106054:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106057:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c010605a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010605d:	8b 40 04             	mov    0x4(%eax),%eax
                while ((le = list_next(le)) != list) {
c0106060:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106063:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106066:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0106069:	75 c1                	jne    c010602c <find_vma+0x55>
                    }
                }
                if (!found) {
c010606b:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
c010606f:	75 07                	jne    c0106078 <find_vma+0xa1>
                    vma = NULL;
c0106071:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
                }
        }
        if (vma != NULL) {
c0106078:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c010607c:	74 09                	je     c0106087 <find_vma+0xb0>
            mm->mmap_cache = vma;
c010607e:	8b 45 08             	mov    0x8(%ebp),%eax
c0106081:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0106084:	89 50 08             	mov    %edx,0x8(%eax)
        }
    }
    return vma;
c0106087:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010608a:	c9                   	leave  
c010608b:	c3                   	ret    

c010608c <check_vma_overlap>:


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
c010608c:	55                   	push   %ebp
c010608d:	89 e5                	mov    %esp,%ebp
c010608f:	83 ec 08             	sub    $0x8,%esp
    assert(prev->vm_start < prev->vm_end);
c0106092:	8b 45 08             	mov    0x8(%ebp),%eax
c0106095:	8b 50 04             	mov    0x4(%eax),%edx
c0106098:	8b 45 08             	mov    0x8(%ebp),%eax
c010609b:	8b 40 08             	mov    0x8(%eax),%eax
c010609e:	39 c2                	cmp    %eax,%edx
c01060a0:	72 16                	jb     c01060b8 <check_vma_overlap+0x2c>
c01060a2:	68 f9 bd 10 c0       	push   $0xc010bdf9
c01060a7:	68 17 be 10 c0       	push   $0xc010be17
c01060ac:	6a 68                	push   $0x68
c01060ae:	68 2c be 10 c0       	push   $0xc010be2c
c01060b3:	e8 36 b7 ff ff       	call   c01017ee <__panic>
    assert(prev->vm_end <= next->vm_start);
c01060b8:	8b 45 08             	mov    0x8(%ebp),%eax
c01060bb:	8b 50 08             	mov    0x8(%eax),%edx
c01060be:	8b 45 0c             	mov    0xc(%ebp),%eax
c01060c1:	8b 40 04             	mov    0x4(%eax),%eax
c01060c4:	39 c2                	cmp    %eax,%edx
c01060c6:	76 16                	jbe    c01060de <check_vma_overlap+0x52>
c01060c8:	68 3c be 10 c0       	push   $0xc010be3c
c01060cd:	68 17 be 10 c0       	push   $0xc010be17
c01060d2:	6a 69                	push   $0x69
c01060d4:	68 2c be 10 c0       	push   $0xc010be2c
c01060d9:	e8 10 b7 ff ff       	call   c01017ee <__panic>
    assert(next->vm_start < next->vm_end);
c01060de:	8b 45 0c             	mov    0xc(%ebp),%eax
c01060e1:	8b 50 04             	mov    0x4(%eax),%edx
c01060e4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01060e7:	8b 40 08             	mov    0x8(%eax),%eax
c01060ea:	39 c2                	cmp    %eax,%edx
c01060ec:	72 16                	jb     c0106104 <check_vma_overlap+0x78>
c01060ee:	68 5b be 10 c0       	push   $0xc010be5b
c01060f3:	68 17 be 10 c0       	push   $0xc010be17
c01060f8:	6a 6a                	push   $0x6a
c01060fa:	68 2c be 10 c0       	push   $0xc010be2c
c01060ff:	e8 ea b6 ff ff       	call   c01017ee <__panic>
}
c0106104:	90                   	nop
c0106105:	c9                   	leave  
c0106106:	c3                   	ret    

c0106107 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
c0106107:	f3 0f 1e fb          	endbr32 
c010610b:	55                   	push   %ebp
c010610c:	89 e5                	mov    %esp,%ebp
c010610e:	83 ec 38             	sub    $0x38,%esp
    assert(vma->vm_start < vma->vm_end);
c0106111:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106114:	8b 50 04             	mov    0x4(%eax),%edx
c0106117:	8b 45 0c             	mov    0xc(%ebp),%eax
c010611a:	8b 40 08             	mov    0x8(%eax),%eax
c010611d:	39 c2                	cmp    %eax,%edx
c010611f:	72 16                	jb     c0106137 <insert_vma_struct+0x30>
c0106121:	68 79 be 10 c0       	push   $0xc010be79
c0106126:	68 17 be 10 c0       	push   $0xc010be17
c010612b:	6a 71                	push   $0x71
c010612d:	68 2c be 10 c0       	push   $0xc010be2c
c0106132:	e8 b7 b6 ff ff       	call   c01017ee <__panic>
    list_entry_t *list = &(mm->mmap_list);
c0106137:	8b 45 08             	mov    0x8(%ebp),%eax
c010613a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    list_entry_t *le_prev = list, *le_next;
c010613d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106140:	89 45 f4             	mov    %eax,-0xc(%ebp)

        list_entry_t *le = list;
c0106143:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106146:	89 45 f0             	mov    %eax,-0x10(%ebp)
        while ((le = list_next(le)) != list) {
c0106149:	eb 1f                	jmp    c010616a <insert_vma_struct+0x63>
            struct vma_struct *mmap_prev = le2vma(le, list_link);
c010614b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010614e:	83 e8 10             	sub    $0x10,%eax
c0106151:	89 45 e8             	mov    %eax,-0x18(%ebp)
            if (mmap_prev->vm_start > vma->vm_start) {
c0106154:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106157:	8b 50 04             	mov    0x4(%eax),%edx
c010615a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010615d:	8b 40 04             	mov    0x4(%eax),%eax
c0106160:	39 c2                	cmp    %eax,%edx
c0106162:	77 1f                	ja     c0106183 <insert_vma_struct+0x7c>
                break;
            }
            le_prev = le;
c0106164:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106167:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010616a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010616d:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0106170:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106173:	8b 40 04             	mov    0x4(%eax),%eax
        while ((le = list_next(le)) != list) {
c0106176:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106179:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010617c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010617f:	75 ca                	jne    c010614b <insert_vma_struct+0x44>
c0106181:	eb 01                	jmp    c0106184 <insert_vma_struct+0x7d>
                break;
c0106183:	90                   	nop
c0106184:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106187:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010618a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010618d:	8b 40 04             	mov    0x4(%eax),%eax
        }

    le_next = list_next(le_prev);
c0106190:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    /* check overlap */
    if (le_prev != list) {
c0106193:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106196:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0106199:	74 15                	je     c01061b0 <insert_vma_struct+0xa9>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
c010619b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010619e:	83 e8 10             	sub    $0x10,%eax
c01061a1:	83 ec 08             	sub    $0x8,%esp
c01061a4:	ff 75 0c             	pushl  0xc(%ebp)
c01061a7:	50                   	push   %eax
c01061a8:	e8 df fe ff ff       	call   c010608c <check_vma_overlap>
c01061ad:	83 c4 10             	add    $0x10,%esp
    }
    if (le_next != list) {
c01061b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01061b3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01061b6:	74 15                	je     c01061cd <insert_vma_struct+0xc6>
        check_vma_overlap(vma, le2vma(le_next, list_link));
c01061b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01061bb:	83 e8 10             	sub    $0x10,%eax
c01061be:	83 ec 08             	sub    $0x8,%esp
c01061c1:	50                   	push   %eax
c01061c2:	ff 75 0c             	pushl  0xc(%ebp)
c01061c5:	e8 c2 fe ff ff       	call   c010608c <check_vma_overlap>
c01061ca:	83 c4 10             	add    $0x10,%esp
    }

    vma->vm_mm = mm;
c01061cd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01061d0:	8b 55 08             	mov    0x8(%ebp),%edx
c01061d3:	89 10                	mov    %edx,(%eax)
    list_add_after(le_prev, &(vma->list_link));
c01061d5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01061d8:	8d 50 10             	lea    0x10(%eax),%edx
c01061db:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01061de:	89 45 d8             	mov    %eax,-0x28(%ebp)
c01061e1:	89 55 d4             	mov    %edx,-0x2c(%ebp)
    __list_add(elm, listelm, listelm->next);
c01061e4:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01061e7:	8b 40 04             	mov    0x4(%eax),%eax
c01061ea:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01061ed:	89 55 d0             	mov    %edx,-0x30(%ebp)
c01061f0:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01061f3:	89 55 cc             	mov    %edx,-0x34(%ebp)
c01061f6:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c01061f9:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01061fc:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01061ff:	89 10                	mov    %edx,(%eax)
c0106201:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0106204:	8b 10                	mov    (%eax),%edx
c0106206:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0106209:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010620c:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010620f:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0106212:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0106215:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0106218:	8b 55 cc             	mov    -0x34(%ebp),%edx
c010621b:	89 10                	mov    %edx,(%eax)
}
c010621d:	90                   	nop
}
c010621e:	90                   	nop

    mm->map_count ++;
c010621f:	8b 45 08             	mov    0x8(%ebp),%eax
c0106222:	8b 40 10             	mov    0x10(%eax),%eax
c0106225:	8d 50 01             	lea    0x1(%eax),%edx
c0106228:	8b 45 08             	mov    0x8(%ebp),%eax
c010622b:	89 50 10             	mov    %edx,0x10(%eax)
}
c010622e:	90                   	nop
c010622f:	c9                   	leave  
c0106230:	c3                   	ret    

c0106231 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
c0106231:	f3 0f 1e fb          	endbr32 
c0106235:	55                   	push   %ebp
c0106236:	89 e5                	mov    %esp,%ebp
c0106238:	83 ec 28             	sub    $0x28,%esp

    list_entry_t *list = &(mm->mmap_list), *le;
c010623b:	8b 45 08             	mov    0x8(%ebp),%eax
c010623e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_next(list)) != list) {
c0106241:	eb 3c                	jmp    c010627f <mm_destroy+0x4e>
c0106243:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106246:	89 45 ec             	mov    %eax,-0x14(%ebp)
    __list_del(listelm->prev, listelm->next);
c0106249:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010624c:	8b 40 04             	mov    0x4(%eax),%eax
c010624f:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106252:	8b 12                	mov    (%edx),%edx
c0106254:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0106257:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c010625a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010625d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106260:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0106263:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106266:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0106269:	89 10                	mov    %edx,(%eax)
}
c010626b:	90                   	nop
}
c010626c:	90                   	nop
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
c010626d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106270:	83 e8 10             	sub    $0x10,%eax
c0106273:	83 ec 0c             	sub    $0xc,%esp
c0106276:	50                   	push   %eax
c0106277:	e8 98 19 00 00       	call   c0107c14 <kfree>
c010627c:	83 c4 10             	add    $0x10,%esp
c010627f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106282:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return listelm->next;
c0106285:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106288:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(list)) != list) {
c010628b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010628e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106291:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0106294:	75 ad                	jne    c0106243 <mm_destroy+0x12>
    }
    kfree(mm); //kfree mm
c0106296:	83 ec 0c             	sub    $0xc,%esp
c0106299:	ff 75 08             	pushl  0x8(%ebp)
c010629c:	e8 73 19 00 00       	call   c0107c14 <kfree>
c01062a1:	83 c4 10             	add    $0x10,%esp
    mm=NULL;
c01062a4:	c7 45 08 00 00 00 00 	movl   $0x0,0x8(%ebp)
}
c01062ab:	90                   	nop
c01062ac:	c9                   	leave  
c01062ad:	c3                   	ret    

c01062ae <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
c01062ae:	f3 0f 1e fb          	endbr32 
c01062b2:	55                   	push   %ebp
c01062b3:	89 e5                	mov    %esp,%ebp
c01062b5:	83 ec 08             	sub    $0x8,%esp
    check_vmm();
c01062b8:	e8 03 00 00 00       	call   c01062c0 <check_vmm>
}
c01062bd:	90                   	nop
c01062be:	c9                   	leave  
c01062bf:	c3                   	ret    

c01062c0 <check_vmm>:

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
c01062c0:	f3 0f 1e fb          	endbr32 
c01062c4:	55                   	push   %ebp
c01062c5:	89 e5                	mov    %esp,%ebp
c01062c7:	83 ec 18             	sub    $0x18,%esp
    size_t nr_free_pages_store = nr_free_pages();
c01062ca:	e8 4c e7 ff ff       	call   c0104a1b <nr_free_pages>
c01062cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    
    check_vma_struct();
c01062d2:	e8 18 00 00 00       	call   c01062ef <check_vma_struct>
    check_pgfault();
c01062d7:	e8 14 04 00 00       	call   c01066f0 <check_pgfault>

 //   assert(nr_free_pages_store == nr_free_pages());

    cprintf("check_vmm() succeeded.\n");
c01062dc:	83 ec 0c             	sub    $0xc,%esp
c01062df:	68 95 be 10 c0       	push   $0xc010be95
c01062e4:	e8 c9 9f ff ff       	call   c01002b2 <cprintf>
c01062e9:	83 c4 10             	add    $0x10,%esp
}
c01062ec:	90                   	nop
c01062ed:	c9                   	leave  
c01062ee:	c3                   	ret    

c01062ef <check_vma_struct>:

static void
check_vma_struct(void) {
c01062ef:	f3 0f 1e fb          	endbr32 
c01062f3:	55                   	push   %ebp
c01062f4:	89 e5                	mov    %esp,%ebp
c01062f6:	83 ec 58             	sub    $0x58,%esp
    size_t nr_free_pages_store = nr_free_pages();
c01062f9:	e8 1d e7 ff ff       	call   c0104a1b <nr_free_pages>
c01062fe:	89 45 ec             	mov    %eax,-0x14(%ebp)

    struct mm_struct *mm = mm_create();
c0106301:	e8 10 fc ff ff       	call   c0105f16 <mm_create>
c0106306:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(mm != NULL);
c0106309:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010630d:	75 19                	jne    c0106328 <check_vma_struct+0x39>
c010630f:	68 ad be 10 c0       	push   $0xc010bead
c0106314:	68 17 be 10 c0       	push   $0xc010be17
c0106319:	68 b4 00 00 00       	push   $0xb4
c010631e:	68 2c be 10 c0       	push   $0xc010be2c
c0106323:	e8 c6 b4 ff ff       	call   c01017ee <__panic>

    int step1 = 10, step2 = step1 * 10;
c0106328:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%ebp)
c010632f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106332:	89 d0                	mov    %edx,%eax
c0106334:	c1 e0 02             	shl    $0x2,%eax
c0106337:	01 d0                	add    %edx,%eax
c0106339:	01 c0                	add    %eax,%eax
c010633b:	89 45 e0             	mov    %eax,-0x20(%ebp)

    int i;
    for (i = step1; i >= 1; i --) {
c010633e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106341:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106344:	eb 5f                	jmp    c01063a5 <check_vma_struct+0xb6>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c0106346:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106349:	89 d0                	mov    %edx,%eax
c010634b:	c1 e0 02             	shl    $0x2,%eax
c010634e:	01 d0                	add    %edx,%eax
c0106350:	83 c0 02             	add    $0x2,%eax
c0106353:	89 c1                	mov    %eax,%ecx
c0106355:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106358:	89 d0                	mov    %edx,%eax
c010635a:	c1 e0 02             	shl    $0x2,%eax
c010635d:	01 d0                	add    %edx,%eax
c010635f:	83 ec 04             	sub    $0x4,%esp
c0106362:	6a 00                	push   $0x0
c0106364:	51                   	push   %ecx
c0106365:	50                   	push   %eax
c0106366:	e8 2c fc ff ff       	call   c0105f97 <vma_create>
c010636b:	83 c4 10             	add    $0x10,%esp
c010636e:	89 45 bc             	mov    %eax,-0x44(%ebp)
        assert(vma != NULL);
c0106371:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0106375:	75 19                	jne    c0106390 <check_vma_struct+0xa1>
c0106377:	68 b8 be 10 c0       	push   $0xc010beb8
c010637c:	68 17 be 10 c0       	push   $0xc010be17
c0106381:	68 bb 00 00 00       	push   $0xbb
c0106386:	68 2c be 10 c0       	push   $0xc010be2c
c010638b:	e8 5e b4 ff ff       	call   c01017ee <__panic>
        insert_vma_struct(mm, vma);
c0106390:	83 ec 08             	sub    $0x8,%esp
c0106393:	ff 75 bc             	pushl  -0x44(%ebp)
c0106396:	ff 75 e8             	pushl  -0x18(%ebp)
c0106399:	e8 69 fd ff ff       	call   c0106107 <insert_vma_struct>
c010639e:	83 c4 10             	add    $0x10,%esp
    for (i = step1; i >= 1; i --) {
c01063a1:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01063a5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01063a9:	7f 9b                	jg     c0106346 <check_vma_struct+0x57>
    }

    for (i = step1 + 1; i <= step2; i ++) {
c01063ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01063ae:	83 c0 01             	add    $0x1,%eax
c01063b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01063b4:	eb 5f                	jmp    c0106415 <check_vma_struct+0x126>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c01063b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01063b9:	89 d0                	mov    %edx,%eax
c01063bb:	c1 e0 02             	shl    $0x2,%eax
c01063be:	01 d0                	add    %edx,%eax
c01063c0:	83 c0 02             	add    $0x2,%eax
c01063c3:	89 c1                	mov    %eax,%ecx
c01063c5:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01063c8:	89 d0                	mov    %edx,%eax
c01063ca:	c1 e0 02             	shl    $0x2,%eax
c01063cd:	01 d0                	add    %edx,%eax
c01063cf:	83 ec 04             	sub    $0x4,%esp
c01063d2:	6a 00                	push   $0x0
c01063d4:	51                   	push   %ecx
c01063d5:	50                   	push   %eax
c01063d6:	e8 bc fb ff ff       	call   c0105f97 <vma_create>
c01063db:	83 c4 10             	add    $0x10,%esp
c01063de:	89 45 c0             	mov    %eax,-0x40(%ebp)
        assert(vma != NULL);
c01063e1:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
c01063e5:	75 19                	jne    c0106400 <check_vma_struct+0x111>
c01063e7:	68 b8 be 10 c0       	push   $0xc010beb8
c01063ec:	68 17 be 10 c0       	push   $0xc010be17
c01063f1:	68 c1 00 00 00       	push   $0xc1
c01063f6:	68 2c be 10 c0       	push   $0xc010be2c
c01063fb:	e8 ee b3 ff ff       	call   c01017ee <__panic>
        insert_vma_struct(mm, vma);
c0106400:	83 ec 08             	sub    $0x8,%esp
c0106403:	ff 75 c0             	pushl  -0x40(%ebp)
c0106406:	ff 75 e8             	pushl  -0x18(%ebp)
c0106409:	e8 f9 fc ff ff       	call   c0106107 <insert_vma_struct>
c010640e:	83 c4 10             	add    $0x10,%esp
    for (i = step1 + 1; i <= step2; i ++) {
c0106411:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0106415:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106418:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c010641b:	7e 99                	jle    c01063b6 <check_vma_struct+0xc7>
    }

    list_entry_t *le = list_next(&(mm->mmap_list));
c010641d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106420:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0106423:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0106426:	8b 40 04             	mov    0x4(%eax),%eax
c0106429:	89 45 f0             	mov    %eax,-0x10(%ebp)

    for (i = 1; i <= step2; i ++) {
c010642c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
c0106433:	e9 81 00 00 00       	jmp    c01064b9 <check_vma_struct+0x1ca>
        assert(le != &(mm->mmap_list));
c0106438:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010643b:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010643e:	75 19                	jne    c0106459 <check_vma_struct+0x16a>
c0106440:	68 c4 be 10 c0       	push   $0xc010bec4
c0106445:	68 17 be 10 c0       	push   $0xc010be17
c010644a:	68 c8 00 00 00       	push   $0xc8
c010644f:	68 2c be 10 c0       	push   $0xc010be2c
c0106454:	e8 95 b3 ff ff       	call   c01017ee <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
c0106459:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010645c:	83 e8 10             	sub    $0x10,%eax
c010645f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
c0106462:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0106465:	8b 48 04             	mov    0x4(%eax),%ecx
c0106468:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010646b:	89 d0                	mov    %edx,%eax
c010646d:	c1 e0 02             	shl    $0x2,%eax
c0106470:	01 d0                	add    %edx,%eax
c0106472:	39 c1                	cmp    %eax,%ecx
c0106474:	75 17                	jne    c010648d <check_vma_struct+0x19e>
c0106476:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0106479:	8b 48 08             	mov    0x8(%eax),%ecx
c010647c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010647f:	89 d0                	mov    %edx,%eax
c0106481:	c1 e0 02             	shl    $0x2,%eax
c0106484:	01 d0                	add    %edx,%eax
c0106486:	83 c0 02             	add    $0x2,%eax
c0106489:	39 c1                	cmp    %eax,%ecx
c010648b:	74 19                	je     c01064a6 <check_vma_struct+0x1b7>
c010648d:	68 dc be 10 c0       	push   $0xc010bedc
c0106492:	68 17 be 10 c0       	push   $0xc010be17
c0106497:	68 ca 00 00 00       	push   $0xca
c010649c:	68 2c be 10 c0       	push   $0xc010be2c
c01064a1:	e8 48 b3 ff ff       	call   c01017ee <__panic>
c01064a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01064a9:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c01064ac:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01064af:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c01064b2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for (i = 1; i <= step2; i ++) {
c01064b5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01064b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01064bc:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01064bf:	0f 8e 73 ff ff ff    	jle    c0106438 <check_vma_struct+0x149>
    }

    for (i = 5; i <= 5 * step2; i +=5) {
c01064c5:	c7 45 f4 05 00 00 00 	movl   $0x5,-0xc(%ebp)
c01064cc:	e9 80 01 00 00       	jmp    c0106651 <check_vma_struct+0x362>
        struct vma_struct *vma1 = find_vma(mm, i);
c01064d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01064d4:	83 ec 08             	sub    $0x8,%esp
c01064d7:	50                   	push   %eax
c01064d8:	ff 75 e8             	pushl  -0x18(%ebp)
c01064db:	e8 f7 fa ff ff       	call   c0105fd7 <find_vma>
c01064e0:	83 c4 10             	add    $0x10,%esp
c01064e3:	89 45 d8             	mov    %eax,-0x28(%ebp)
        assert(vma1 != NULL);
c01064e6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c01064ea:	75 19                	jne    c0106505 <check_vma_struct+0x216>
c01064ec:	68 11 bf 10 c0       	push   $0xc010bf11
c01064f1:	68 17 be 10 c0       	push   $0xc010be17
c01064f6:	68 d0 00 00 00       	push   $0xd0
c01064fb:	68 2c be 10 c0       	push   $0xc010be2c
c0106500:	e8 e9 b2 ff ff       	call   c01017ee <__panic>
        struct vma_struct *vma2 = find_vma(mm, i+1);
c0106505:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106508:	83 c0 01             	add    $0x1,%eax
c010650b:	83 ec 08             	sub    $0x8,%esp
c010650e:	50                   	push   %eax
c010650f:	ff 75 e8             	pushl  -0x18(%ebp)
c0106512:	e8 c0 fa ff ff       	call   c0105fd7 <find_vma>
c0106517:	83 c4 10             	add    $0x10,%esp
c010651a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(vma2 != NULL);
c010651d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
c0106521:	75 19                	jne    c010653c <check_vma_struct+0x24d>
c0106523:	68 1e bf 10 c0       	push   $0xc010bf1e
c0106528:	68 17 be 10 c0       	push   $0xc010be17
c010652d:	68 d2 00 00 00       	push   $0xd2
c0106532:	68 2c be 10 c0       	push   $0xc010be2c
c0106537:	e8 b2 b2 ff ff       	call   c01017ee <__panic>
        struct vma_struct *vma3 = find_vma(mm, i+2);
c010653c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010653f:	83 c0 02             	add    $0x2,%eax
c0106542:	83 ec 08             	sub    $0x8,%esp
c0106545:	50                   	push   %eax
c0106546:	ff 75 e8             	pushl  -0x18(%ebp)
c0106549:	e8 89 fa ff ff       	call   c0105fd7 <find_vma>
c010654e:	83 c4 10             	add    $0x10,%esp
c0106551:	89 45 d0             	mov    %eax,-0x30(%ebp)
        assert(vma3 == NULL);
c0106554:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c0106558:	74 19                	je     c0106573 <check_vma_struct+0x284>
c010655a:	68 2b bf 10 c0       	push   $0xc010bf2b
c010655f:	68 17 be 10 c0       	push   $0xc010be17
c0106564:	68 d4 00 00 00       	push   $0xd4
c0106569:	68 2c be 10 c0       	push   $0xc010be2c
c010656e:	e8 7b b2 ff ff       	call   c01017ee <__panic>
        struct vma_struct *vma4 = find_vma(mm, i+3);
c0106573:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106576:	83 c0 03             	add    $0x3,%eax
c0106579:	83 ec 08             	sub    $0x8,%esp
c010657c:	50                   	push   %eax
c010657d:	ff 75 e8             	pushl  -0x18(%ebp)
c0106580:	e8 52 fa ff ff       	call   c0105fd7 <find_vma>
c0106585:	83 c4 10             	add    $0x10,%esp
c0106588:	89 45 cc             	mov    %eax,-0x34(%ebp)
        assert(vma4 == NULL);
c010658b:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c010658f:	74 19                	je     c01065aa <check_vma_struct+0x2bb>
c0106591:	68 38 bf 10 c0       	push   $0xc010bf38
c0106596:	68 17 be 10 c0       	push   $0xc010be17
c010659b:	68 d6 00 00 00       	push   $0xd6
c01065a0:	68 2c be 10 c0       	push   $0xc010be2c
c01065a5:	e8 44 b2 ff ff       	call   c01017ee <__panic>
        struct vma_struct *vma5 = find_vma(mm, i+4);
c01065aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01065ad:	83 c0 04             	add    $0x4,%eax
c01065b0:	83 ec 08             	sub    $0x8,%esp
c01065b3:	50                   	push   %eax
c01065b4:	ff 75 e8             	pushl  -0x18(%ebp)
c01065b7:	e8 1b fa ff ff       	call   c0105fd7 <find_vma>
c01065bc:	83 c4 10             	add    $0x10,%esp
c01065bf:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(vma5 == NULL);
c01065c2:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c01065c6:	74 19                	je     c01065e1 <check_vma_struct+0x2f2>
c01065c8:	68 45 bf 10 c0       	push   $0xc010bf45
c01065cd:	68 17 be 10 c0       	push   $0xc010be17
c01065d2:	68 d8 00 00 00       	push   $0xd8
c01065d7:	68 2c be 10 c0       	push   $0xc010be2c
c01065dc:	e8 0d b2 ff ff       	call   c01017ee <__panic>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
c01065e1:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01065e4:	8b 50 04             	mov    0x4(%eax),%edx
c01065e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01065ea:	39 c2                	cmp    %eax,%edx
c01065ec:	75 10                	jne    c01065fe <check_vma_struct+0x30f>
c01065ee:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01065f1:	8b 40 08             	mov    0x8(%eax),%eax
c01065f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01065f7:	83 c2 02             	add    $0x2,%edx
c01065fa:	39 d0                	cmp    %edx,%eax
c01065fc:	74 19                	je     c0106617 <check_vma_struct+0x328>
c01065fe:	68 54 bf 10 c0       	push   $0xc010bf54
c0106603:	68 17 be 10 c0       	push   $0xc010be17
c0106608:	68 da 00 00 00       	push   $0xda
c010660d:	68 2c be 10 c0       	push   $0xc010be2c
c0106612:	e8 d7 b1 ff ff       	call   c01017ee <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
c0106617:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010661a:	8b 50 04             	mov    0x4(%eax),%edx
c010661d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106620:	39 c2                	cmp    %eax,%edx
c0106622:	75 10                	jne    c0106634 <check_vma_struct+0x345>
c0106624:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0106627:	8b 40 08             	mov    0x8(%eax),%eax
c010662a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010662d:	83 c2 02             	add    $0x2,%edx
c0106630:	39 d0                	cmp    %edx,%eax
c0106632:	74 19                	je     c010664d <check_vma_struct+0x35e>
c0106634:	68 84 bf 10 c0       	push   $0xc010bf84
c0106639:	68 17 be 10 c0       	push   $0xc010be17
c010663e:	68 db 00 00 00       	push   $0xdb
c0106643:	68 2c be 10 c0       	push   $0xc010be2c
c0106648:	e8 a1 b1 ff ff       	call   c01017ee <__panic>
    for (i = 5; i <= 5 * step2; i +=5) {
c010664d:	83 45 f4 05          	addl   $0x5,-0xc(%ebp)
c0106651:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106654:	89 d0                	mov    %edx,%eax
c0106656:	c1 e0 02             	shl    $0x2,%eax
c0106659:	01 d0                	add    %edx,%eax
c010665b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010665e:	0f 8e 6d fe ff ff    	jle    c01064d1 <check_vma_struct+0x1e2>
    }

    for (i =4; i>=0; i--) {
c0106664:	c7 45 f4 04 00 00 00 	movl   $0x4,-0xc(%ebp)
c010666b:	eb 5c                	jmp    c01066c9 <check_vma_struct+0x3da>
        struct vma_struct *vma_below_5= find_vma(mm,i);
c010666d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106670:	83 ec 08             	sub    $0x8,%esp
c0106673:	50                   	push   %eax
c0106674:	ff 75 e8             	pushl  -0x18(%ebp)
c0106677:	e8 5b f9 ff ff       	call   c0105fd7 <find_vma>
c010667c:	83 c4 10             	add    $0x10,%esp
c010667f:	89 45 dc             	mov    %eax,-0x24(%ebp)
        if (vma_below_5 != NULL ) {
c0106682:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0106686:	74 1e                	je     c01066a6 <check_vma_struct+0x3b7>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
c0106688:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010668b:	8b 50 08             	mov    0x8(%eax),%edx
c010668e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106691:	8b 40 04             	mov    0x4(%eax),%eax
c0106694:	52                   	push   %edx
c0106695:	50                   	push   %eax
c0106696:	ff 75 f4             	pushl  -0xc(%ebp)
c0106699:	68 b4 bf 10 c0       	push   $0xc010bfb4
c010669e:	e8 0f 9c ff ff       	call   c01002b2 <cprintf>
c01066a3:	83 c4 10             	add    $0x10,%esp
        }
        assert(vma_below_5 == NULL);
c01066a6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c01066aa:	74 19                	je     c01066c5 <check_vma_struct+0x3d6>
c01066ac:	68 d9 bf 10 c0       	push   $0xc010bfd9
c01066b1:	68 17 be 10 c0       	push   $0xc010be17
c01066b6:	68 e3 00 00 00       	push   $0xe3
c01066bb:	68 2c be 10 c0       	push   $0xc010be2c
c01066c0:	e8 29 b1 ff ff       	call   c01017ee <__panic>
    for (i =4; i>=0; i--) {
c01066c5:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01066c9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01066cd:	79 9e                	jns    c010666d <check_vma_struct+0x37e>
    }

    mm_destroy(mm);
c01066cf:	83 ec 0c             	sub    $0xc,%esp
c01066d2:	ff 75 e8             	pushl  -0x18(%ebp)
c01066d5:	e8 57 fb ff ff       	call   c0106231 <mm_destroy>
c01066da:	83 c4 10             	add    $0x10,%esp

//    assert(nr_free_pages_store == nr_free_pages());

    cprintf("check_vma_struct() succeeded!\n");
c01066dd:	83 ec 0c             	sub    $0xc,%esp
c01066e0:	68 f0 bf 10 c0       	push   $0xc010bff0
c01066e5:	e8 c8 9b ff ff       	call   c01002b2 <cprintf>
c01066ea:	83 c4 10             	add    $0x10,%esp
}
c01066ed:	90                   	nop
c01066ee:	c9                   	leave  
c01066ef:	c3                   	ret    

c01066f0 <check_pgfault>:

struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
c01066f0:	f3 0f 1e fb          	endbr32 
c01066f4:	55                   	push   %ebp
c01066f5:	89 e5                	mov    %esp,%ebp
c01066f7:	83 ec 28             	sub    $0x28,%esp
    size_t nr_free_pages_store = nr_free_pages();
c01066fa:	e8 1c e3 ff ff       	call   c0104a1b <nr_free_pages>
c01066ff:	89 45 ec             	mov    %eax,-0x14(%ebp)

    check_mm_struct = mm_create();
c0106702:	e8 0f f8 ff ff       	call   c0105f16 <mm_create>
c0106707:	a3 64 10 13 c0       	mov    %eax,0xc0131064
    assert(check_mm_struct != NULL);
c010670c:	a1 64 10 13 c0       	mov    0xc0131064,%eax
c0106711:	85 c0                	test   %eax,%eax
c0106713:	75 19                	jne    c010672e <check_pgfault+0x3e>
c0106715:	68 0f c0 10 c0       	push   $0xc010c00f
c010671a:	68 17 be 10 c0       	push   $0xc010be17
c010671f:	68 f5 00 00 00       	push   $0xf5
c0106724:	68 2c be 10 c0       	push   $0xc010be2c
c0106729:	e8 c0 b0 ff ff       	call   c01017ee <__panic>

    struct mm_struct *mm = check_mm_struct;
c010672e:	a1 64 10 13 c0       	mov    0xc0131064,%eax
c0106733:	89 45 e8             	mov    %eax,-0x18(%ebp)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
c0106736:	8b 15 e0 b9 12 c0    	mov    0xc012b9e0,%edx
c010673c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010673f:	89 50 0c             	mov    %edx,0xc(%eax)
c0106742:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106745:	8b 40 0c             	mov    0xc(%eax),%eax
c0106748:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(pgdir[0] == 0);
c010674b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010674e:	8b 00                	mov    (%eax),%eax
c0106750:	85 c0                	test   %eax,%eax
c0106752:	74 19                	je     c010676d <check_pgfault+0x7d>
c0106754:	68 27 c0 10 c0       	push   $0xc010c027
c0106759:	68 17 be 10 c0       	push   $0xc010be17
c010675e:	68 f9 00 00 00       	push   $0xf9
c0106763:	68 2c be 10 c0       	push   $0xc010be2c
c0106768:	e8 81 b0 ff ff       	call   c01017ee <__panic>

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
c010676d:	83 ec 04             	sub    $0x4,%esp
c0106770:	6a 02                	push   $0x2
c0106772:	68 00 00 40 00       	push   $0x400000
c0106777:	6a 00                	push   $0x0
c0106779:	e8 19 f8 ff ff       	call   c0105f97 <vma_create>
c010677e:	83 c4 10             	add    $0x10,%esp
c0106781:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(vma != NULL);
c0106784:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0106788:	75 19                	jne    c01067a3 <check_pgfault+0xb3>
c010678a:	68 b8 be 10 c0       	push   $0xc010beb8
c010678f:	68 17 be 10 c0       	push   $0xc010be17
c0106794:	68 fc 00 00 00       	push   $0xfc
c0106799:	68 2c be 10 c0       	push   $0xc010be2c
c010679e:	e8 4b b0 ff ff       	call   c01017ee <__panic>

    insert_vma_struct(mm, vma);
c01067a3:	83 ec 08             	sub    $0x8,%esp
c01067a6:	ff 75 e0             	pushl  -0x20(%ebp)
c01067a9:	ff 75 e8             	pushl  -0x18(%ebp)
c01067ac:	e8 56 f9 ff ff       	call   c0106107 <insert_vma_struct>
c01067b1:	83 c4 10             	add    $0x10,%esp

    uintptr_t addr = 0x100;
c01067b4:	c7 45 dc 00 01 00 00 	movl   $0x100,-0x24(%ebp)
    assert(find_vma(mm, addr) == vma);
c01067bb:	83 ec 08             	sub    $0x8,%esp
c01067be:	ff 75 dc             	pushl  -0x24(%ebp)
c01067c1:	ff 75 e8             	pushl  -0x18(%ebp)
c01067c4:	e8 0e f8 ff ff       	call   c0105fd7 <find_vma>
c01067c9:	83 c4 10             	add    $0x10,%esp
c01067cc:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c01067cf:	74 19                	je     c01067ea <check_pgfault+0xfa>
c01067d1:	68 35 c0 10 c0       	push   $0xc010c035
c01067d6:	68 17 be 10 c0       	push   $0xc010be17
c01067db:	68 01 01 00 00       	push   $0x101
c01067e0:	68 2c be 10 c0       	push   $0xc010be2c
c01067e5:	e8 04 b0 ff ff       	call   c01017ee <__panic>

    int i, sum = 0;
c01067ea:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c01067f1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01067f8:	eb 17                	jmp    c0106811 <check_pgfault+0x121>
        *(char *)(addr + i) = i;
c01067fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01067fd:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106800:	01 d0                	add    %edx,%eax
c0106802:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106805:	88 10                	mov    %dl,(%eax)
        sum += i;
c0106807:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010680a:	01 45 f0             	add    %eax,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c010680d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0106811:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c0106815:	7e e3                	jle    c01067fa <check_pgfault+0x10a>
    }
    for (i = 0; i < 100; i ++) {
c0106817:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010681e:	eb 15                	jmp    c0106835 <check_pgfault+0x145>
        sum -= *(char *)(addr + i);
c0106820:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106823:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106826:	01 d0                	add    %edx,%eax
c0106828:	0f b6 00             	movzbl (%eax),%eax
c010682b:	0f be c0             	movsbl %al,%eax
c010682e:	29 45 f0             	sub    %eax,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c0106831:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0106835:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c0106839:	7e e5                	jle    c0106820 <check_pgfault+0x130>
    }
    assert(sum == 0);
c010683b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010683f:	74 19                	je     c010685a <check_pgfault+0x16a>
c0106841:	68 4f c0 10 c0       	push   $0xc010c04f
c0106846:	68 17 be 10 c0       	push   $0xc010be17
c010684b:	68 0b 01 00 00       	push   $0x10b
c0106850:	68 2c be 10 c0       	push   $0xc010be2c
c0106855:	e8 94 af ff ff       	call   c01017ee <__panic>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
c010685a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010685d:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0106860:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0106863:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106868:	83 ec 08             	sub    $0x8,%esp
c010686b:	50                   	push   %eax
c010686c:	ff 75 e4             	pushl  -0x1c(%ebp)
c010686f:	e8 58 e9 ff ff       	call   c01051cc <page_remove>
c0106874:	83 c4 10             	add    $0x10,%esp
    free_page(pde2page(pgdir[0]));
c0106877:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010687a:	8b 00                	mov    (%eax),%eax
c010687c:	83 ec 0c             	sub    $0xc,%esp
c010687f:	50                   	push   %eax
c0106880:	e8 75 f6 ff ff       	call   c0105efa <pde2page>
c0106885:	83 c4 10             	add    $0x10,%esp
c0106888:	83 ec 08             	sub    $0x8,%esp
c010688b:	6a 01                	push   $0x1
c010688d:	50                   	push   %eax
c010688e:	e8 4f e1 ff ff       	call   c01049e2 <free_pages>
c0106893:	83 c4 10             	add    $0x10,%esp
    pgdir[0] = 0;
c0106896:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106899:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    mm->pgdir = NULL;
c010689f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01068a2:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    mm_destroy(mm);
c01068a9:	83 ec 0c             	sub    $0xc,%esp
c01068ac:	ff 75 e8             	pushl  -0x18(%ebp)
c01068af:	e8 7d f9 ff ff       	call   c0106231 <mm_destroy>
c01068b4:	83 c4 10             	add    $0x10,%esp
    check_mm_struct = NULL;
c01068b7:	c7 05 64 10 13 c0 00 	movl   $0x0,0xc0131064
c01068be:	00 00 00 

    assert(nr_free_pages_store == nr_free_pages());
c01068c1:	e8 55 e1 ff ff       	call   c0104a1b <nr_free_pages>
c01068c6:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c01068c9:	74 19                	je     c01068e4 <check_pgfault+0x1f4>
c01068cb:	68 58 c0 10 c0       	push   $0xc010c058
c01068d0:	68 17 be 10 c0       	push   $0xc010be17
c01068d5:	68 15 01 00 00       	push   $0x115
c01068da:	68 2c be 10 c0       	push   $0xc010be2c
c01068df:	e8 0a af ff ff       	call   c01017ee <__panic>

    cprintf("check_pgfault() succeeded!\n");
c01068e4:	83 ec 0c             	sub    $0xc,%esp
c01068e7:	68 7f c0 10 c0       	push   $0xc010c07f
c01068ec:	e8 c1 99 ff ff       	call   c01002b2 <cprintf>
c01068f1:	83 c4 10             	add    $0x10,%esp
}
c01068f4:	90                   	nop
c01068f5:	c9                   	leave  
c01068f6:	c3                   	ret    

c01068f7 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
c01068f7:	f3 0f 1e fb          	endbr32 
c01068fb:	55                   	push   %ebp
c01068fc:	89 e5                	mov    %esp,%ebp
c01068fe:	83 ec 28             	sub    $0x28,%esp
    int ret = -E_INVAL;
c0106901:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
c0106908:	ff 75 10             	pushl  0x10(%ebp)
c010690b:	ff 75 08             	pushl  0x8(%ebp)
c010690e:	e8 c4 f6 ff ff       	call   c0105fd7 <find_vma>
c0106913:	83 c4 08             	add    $0x8,%esp
c0106916:	89 45 ec             	mov    %eax,-0x14(%ebp)

    pgfault_num++;
c0106919:	a1 0c f0 12 c0       	mov    0xc012f00c,%eax
c010691e:	83 c0 01             	add    $0x1,%eax
c0106921:	a3 0c f0 12 c0       	mov    %eax,0xc012f00c
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
c0106926:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010692a:	74 0b                	je     c0106937 <do_pgfault+0x40>
c010692c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010692f:	8b 40 04             	mov    0x4(%eax),%eax
c0106932:	39 45 10             	cmp    %eax,0x10(%ebp)
c0106935:	73 18                	jae    c010694f <do_pgfault+0x58>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
c0106937:	83 ec 08             	sub    $0x8,%esp
c010693a:	ff 75 10             	pushl  0x10(%ebp)
c010693d:	68 9c c0 10 c0       	push   $0xc010c09c
c0106942:	e8 6b 99 ff ff       	call   c01002b2 <cprintf>
c0106947:	83 c4 10             	add    $0x10,%esp
        goto failed;
c010694a:	e9 aa 01 00 00       	jmp    c0106af9 <do_pgfault+0x202>
    }
    //check the error_code
    switch (error_code & 3) {
c010694f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106952:	83 e0 03             	and    $0x3,%eax
c0106955:	85 c0                	test   %eax,%eax
c0106957:	74 3c                	je     c0106995 <do_pgfault+0x9e>
c0106959:	83 f8 01             	cmp    $0x1,%eax
c010695c:	74 22                	je     c0106980 <do_pgfault+0x89>
    default:
            /* error code flag : default is 3 ( W/R=1, P=1): write, present */
    case 2: /* error code flag : (W/R=1, P=0): write, not present */
        if (!(vma->vm_flags & VM_WRITE)) {
c010695e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106961:	8b 40 0c             	mov    0xc(%eax),%eax
c0106964:	83 e0 02             	and    $0x2,%eax
c0106967:	85 c0                	test   %eax,%eax
c0106969:	75 4c                	jne    c01069b7 <do_pgfault+0xc0>
            cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
c010696b:	83 ec 0c             	sub    $0xc,%esp
c010696e:	68 cc c0 10 c0       	push   $0xc010c0cc
c0106973:	e8 3a 99 ff ff       	call   c01002b2 <cprintf>
c0106978:	83 c4 10             	add    $0x10,%esp
            goto failed;
c010697b:	e9 79 01 00 00       	jmp    c0106af9 <do_pgfault+0x202>
        }
        break;
    case 1: /* error code flag : (W/R=0, P=1): read, present */
        cprintf("do_pgfault failed: error code flag = read AND present\n");
c0106980:	83 ec 0c             	sub    $0xc,%esp
c0106983:	68 2c c1 10 c0       	push   $0xc010c12c
c0106988:	e8 25 99 ff ff       	call   c01002b2 <cprintf>
c010698d:	83 c4 10             	add    $0x10,%esp
        goto failed;
c0106990:	e9 64 01 00 00       	jmp    c0106af9 <do_pgfault+0x202>
    case 0: /* error code flag : (W/R=0, P=0): read, not present */
        if (!(vma->vm_flags & (VM_READ | VM_EXEC))) {
c0106995:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106998:	8b 40 0c             	mov    0xc(%eax),%eax
c010699b:	83 e0 05             	and    $0x5,%eax
c010699e:	85 c0                	test   %eax,%eax
c01069a0:	75 16                	jne    c01069b8 <do_pgfault+0xc1>
            cprintf("do_pgfault failed: error code flag = read AND not present, but the addr's vma cannot read or exec\n");
c01069a2:	83 ec 0c             	sub    $0xc,%esp
c01069a5:	68 64 c1 10 c0       	push   $0xc010c164
c01069aa:	e8 03 99 ff ff       	call   c01002b2 <cprintf>
c01069af:	83 c4 10             	add    $0x10,%esp
            goto failed;
c01069b2:	e9 42 01 00 00       	jmp    c0106af9 <do_pgfault+0x202>
        break;
c01069b7:	90                   	nop
     *    (write an non_existed addr && addr is writable) OR
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
c01069b8:	c7 45 f0 04 00 00 00 	movl   $0x4,-0x10(%ebp)
    if (vma->vm_flags & VM_WRITE) {
c01069bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01069c2:	8b 40 0c             	mov    0xc(%eax),%eax
c01069c5:	83 e0 02             	and    $0x2,%eax
c01069c8:	85 c0                	test   %eax,%eax
c01069ca:	74 04                	je     c01069d0 <do_pgfault+0xd9>
        perm |= PTE_W;
c01069cc:	83 4d f0 02          	orl    $0x2,-0x10(%ebp)
    }
    addr = ROUNDDOWN(addr, PGSIZE);
c01069d0:	8b 45 10             	mov    0x10(%ebp),%eax
c01069d3:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01069d6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01069d9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01069de:	89 45 10             	mov    %eax,0x10(%ebp)

    ret = -E_NO_MEM;
c01069e1:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

    pte_t *ptep=NULL;
c01069e8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
        }
   }
#endif
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
c01069ef:	8b 45 08             	mov    0x8(%ebp),%eax
c01069f2:	8b 40 0c             	mov    0xc(%eax),%eax
c01069f5:	83 ec 04             	sub    $0x4,%esp
c01069f8:	6a 01                	push   $0x1
c01069fa:	ff 75 10             	pushl  0x10(%ebp)
c01069fd:	50                   	push   %eax
c01069fe:	e8 e9 e5 ff ff       	call   c0104fec <get_pte>
c0106a03:	83 c4 10             	add    $0x10,%esp
c0106a06:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106a09:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106a0d:	75 15                	jne    c0106a24 <do_pgfault+0x12d>
        cprintf("get_pte in do_pgfault failed\n");
c0106a0f:	83 ec 0c             	sub    $0xc,%esp
c0106a12:	68 c7 c1 10 c0       	push   $0xc010c1c7
c0106a17:	e8 96 98 ff ff       	call   c01002b2 <cprintf>
c0106a1c:	83 c4 10             	add    $0x10,%esp
        goto failed;
c0106a1f:	e9 d5 00 00 00       	jmp    c0106af9 <do_pgfault+0x202>
    }
    
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
c0106a24:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106a27:	8b 00                	mov    (%eax),%eax
c0106a29:	85 c0                	test   %eax,%eax
c0106a2b:	75 35                	jne    c0106a62 <do_pgfault+0x16b>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
c0106a2d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a30:	8b 40 0c             	mov    0xc(%eax),%eax
c0106a33:	83 ec 04             	sub    $0x4,%esp
c0106a36:	ff 75 f0             	pushl  -0x10(%ebp)
c0106a39:	ff 75 10             	pushl  0x10(%ebp)
c0106a3c:	50                   	push   %eax
c0106a3d:	e8 d9 e8 ff ff       	call   c010531b <pgdir_alloc_page>
c0106a42:	83 c4 10             	add    $0x10,%esp
c0106a45:	85 c0                	test   %eax,%eax
c0106a47:	0f 85 a5 00 00 00    	jne    c0106af2 <do_pgfault+0x1fb>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
c0106a4d:	83 ec 0c             	sub    $0xc,%esp
c0106a50:	68 e8 c1 10 c0       	push   $0xc010c1e8
c0106a55:	e8 58 98 ff ff       	call   c01002b2 <cprintf>
c0106a5a:	83 c4 10             	add    $0x10,%esp
            goto failed;
c0106a5d:	e9 97 00 00 00       	jmp    c0106af9 <do_pgfault+0x202>
        }
    }
    else { // if this pte is a swap entry, then load data from disk to a page with phy addr
           // and call page_insert to map the phy addr with logical addr
        if(swap_init_ok) {
c0106a62:	a1 10 f0 12 c0       	mov    0xc012f010,%eax
c0106a67:	85 c0                	test   %eax,%eax
c0106a69:	74 6f                	je     c0106ada <do_pgfault+0x1e3>
            struct Page *page=NULL;
c0106a6b:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
            if ((ret = swap_in(mm, addr, &page)) != 0) {
c0106a72:	83 ec 04             	sub    $0x4,%esp
c0106a75:	8d 45 e0             	lea    -0x20(%ebp),%eax
c0106a78:	50                   	push   %eax
c0106a79:	ff 75 10             	pushl  0x10(%ebp)
c0106a7c:	ff 75 08             	pushl  0x8(%ebp)
c0106a7f:	e8 5c 03 00 00       	call   c0106de0 <swap_in>
c0106a84:	83 c4 10             	add    $0x10,%esp
c0106a87:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106a8a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106a8e:	74 12                	je     c0106aa2 <do_pgfault+0x1ab>
                cprintf("swap_in in do_pgfault failed\n");
c0106a90:	83 ec 0c             	sub    $0xc,%esp
c0106a93:	68 0f c2 10 c0       	push   $0xc010c20f
c0106a98:	e8 15 98 ff ff       	call   c01002b2 <cprintf>
c0106a9d:	83 c4 10             	add    $0x10,%esp
c0106aa0:	eb 57                	jmp    c0106af9 <do_pgfault+0x202>
                goto failed;
            }    
            page_insert(mm->pgdir, page, addr, perm);
c0106aa2:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106aa5:	8b 45 08             	mov    0x8(%ebp),%eax
c0106aa8:	8b 40 0c             	mov    0xc(%eax),%eax
c0106aab:	ff 75 f0             	pushl  -0x10(%ebp)
c0106aae:	ff 75 10             	pushl  0x10(%ebp)
c0106ab1:	52                   	push   %edx
c0106ab2:	50                   	push   %eax
c0106ab3:	e8 51 e7 ff ff       	call   c0105209 <page_insert>
c0106ab8:	83 c4 10             	add    $0x10,%esp
            swap_map_swappable(mm, addr, page, 1);
c0106abb:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106abe:	6a 01                	push   $0x1
c0106ac0:	50                   	push   %eax
c0106ac1:	ff 75 10             	pushl  0x10(%ebp)
c0106ac4:	ff 75 08             	pushl  0x8(%ebp)
c0106ac7:	e8 78 01 00 00       	call   c0106c44 <swap_map_swappable>
c0106acc:	83 c4 10             	add    $0x10,%esp
            page->pra_vaddr = addr;
c0106acf:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106ad2:	8b 55 10             	mov    0x10(%ebp),%edx
c0106ad5:	89 50 20             	mov    %edx,0x20(%eax)
c0106ad8:	eb 18                	jmp    c0106af2 <do_pgfault+0x1fb>
        }
        else {
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
c0106ada:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106add:	8b 00                	mov    (%eax),%eax
c0106adf:	83 ec 08             	sub    $0x8,%esp
c0106ae2:	50                   	push   %eax
c0106ae3:	68 30 c2 10 c0       	push   $0xc010c230
c0106ae8:	e8 c5 97 ff ff       	call   c01002b2 <cprintf>
c0106aed:	83 c4 10             	add    $0x10,%esp
            goto failed;
c0106af0:	eb 07                	jmp    c0106af9 <do_pgfault+0x202>
        }
   }
   ret = 0;
c0106af2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
failed:
    return ret;
c0106af9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106afc:	c9                   	leave  
c0106afd:	c3                   	ret    

c0106afe <pa2page>:
pa2page(uintptr_t pa) {
c0106afe:	55                   	push   %ebp
c0106aff:	89 e5                	mov    %esp,%ebp
c0106b01:	83 ec 08             	sub    $0x8,%esp
    if (PPN(pa) >= npage) {
c0106b04:	8b 45 08             	mov    0x8(%ebp),%eax
c0106b07:	c1 e8 0c             	shr    $0xc,%eax
c0106b0a:	89 c2                	mov    %eax,%edx
c0106b0c:	a1 80 ef 12 c0       	mov    0xc012ef80,%eax
c0106b11:	39 c2                	cmp    %eax,%edx
c0106b13:	72 14                	jb     c0106b29 <pa2page+0x2b>
        panic("pa2page called with invalid pa");
c0106b15:	83 ec 04             	sub    $0x4,%esp
c0106b18:	68 58 c2 10 c0       	push   $0xc010c258
c0106b1d:	6a 5f                	push   $0x5f
c0106b1f:	68 77 c2 10 c0       	push   $0xc010c277
c0106b24:	e8 c5 ac ff ff       	call   c01017ee <__panic>
    return &pages[PPN(pa)];
c0106b29:	8b 0d 60 10 13 c0    	mov    0xc0131060,%ecx
c0106b2f:	8b 45 08             	mov    0x8(%ebp),%eax
c0106b32:	c1 e8 0c             	shr    $0xc,%eax
c0106b35:	89 c2                	mov    %eax,%edx
c0106b37:	89 d0                	mov    %edx,%eax
c0106b39:	c1 e0 03             	shl    $0x3,%eax
c0106b3c:	01 d0                	add    %edx,%eax
c0106b3e:	c1 e0 02             	shl    $0x2,%eax
c0106b41:	01 c8                	add    %ecx,%eax
}
c0106b43:	c9                   	leave  
c0106b44:	c3                   	ret    

c0106b45 <pte2page>:
pte2page(pte_t pte) {
c0106b45:	55                   	push   %ebp
c0106b46:	89 e5                	mov    %esp,%ebp
c0106b48:	83 ec 08             	sub    $0x8,%esp
    if (!(pte & PTE_P)) {
c0106b4b:	8b 45 08             	mov    0x8(%ebp),%eax
c0106b4e:	83 e0 01             	and    $0x1,%eax
c0106b51:	85 c0                	test   %eax,%eax
c0106b53:	75 14                	jne    c0106b69 <pte2page+0x24>
        panic("pte2page called with invalid pte");
c0106b55:	83 ec 04             	sub    $0x4,%esp
c0106b58:	68 88 c2 10 c0       	push   $0xc010c288
c0106b5d:	6a 71                	push   $0x71
c0106b5f:	68 77 c2 10 c0       	push   $0xc010c277
c0106b64:	e8 85 ac ff ff       	call   c01017ee <__panic>
    return pa2page(PTE_ADDR(pte));
c0106b69:	8b 45 08             	mov    0x8(%ebp),%eax
c0106b6c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106b71:	83 ec 0c             	sub    $0xc,%esp
c0106b74:	50                   	push   %eax
c0106b75:	e8 84 ff ff ff       	call   c0106afe <pa2page>
c0106b7a:	83 c4 10             	add    $0x10,%esp
}
c0106b7d:	c9                   	leave  
c0106b7e:	c3                   	ret    

c0106b7f <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
c0106b7f:	f3 0f 1e fb          	endbr32 
c0106b83:	55                   	push   %ebp
c0106b84:	89 e5                	mov    %esp,%ebp
c0106b86:	83 ec 18             	sub    $0x18,%esp
     swapfs_init();
c0106b89:	e8 21 27 00 00       	call   c01092af <swapfs_init>

     if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
c0106b8e:	a1 1c 11 13 c0       	mov    0xc013111c,%eax
c0106b93:	3d ff 03 00 00       	cmp    $0x3ff,%eax
c0106b98:	76 0c                	jbe    c0106ba6 <swap_init+0x27>
c0106b9a:	a1 1c 11 13 c0       	mov    0xc013111c,%eax
c0106b9f:	3d ff ff ff 00       	cmp    $0xffffff,%eax
c0106ba4:	76 17                	jbe    c0106bbd <swap_init+0x3e>
     {
          panic("bad max_swap_offset %08x.\n", max_swap_offset);
c0106ba6:	a1 1c 11 13 c0       	mov    0xc013111c,%eax
c0106bab:	50                   	push   %eax
c0106bac:	68 a9 c2 10 c0       	push   $0xc010c2a9
c0106bb1:	6a 25                	push   $0x25
c0106bb3:	68 c4 c2 10 c0       	push   $0xc010c2c4
c0106bb8:	e8 31 ac ff ff       	call   c01017ee <__panic>
     }
     

     sm = &swap_manager_fifo;
c0106bbd:	c7 05 18 f0 12 c0 60 	movl   $0xc012ba60,0xc012f018
c0106bc4:	ba 12 c0 
     int r = sm->init();
c0106bc7:	a1 18 f0 12 c0       	mov    0xc012f018,%eax
c0106bcc:	8b 40 04             	mov    0x4(%eax),%eax
c0106bcf:	ff d0                	call   *%eax
c0106bd1:	89 45 f4             	mov    %eax,-0xc(%ebp)
     
     if (r == 0)
c0106bd4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106bd8:	75 27                	jne    c0106c01 <swap_init+0x82>
     {
          swap_init_ok = 1;
c0106bda:	c7 05 10 f0 12 c0 01 	movl   $0x1,0xc012f010
c0106be1:	00 00 00 
          cprintf("SWAP: manager = %s\n", sm->name);
c0106be4:	a1 18 f0 12 c0       	mov    0xc012f018,%eax
c0106be9:	8b 00                	mov    (%eax),%eax
c0106beb:	83 ec 08             	sub    $0x8,%esp
c0106bee:	50                   	push   %eax
c0106bef:	68 d3 c2 10 c0       	push   $0xc010c2d3
c0106bf4:	e8 b9 96 ff ff       	call   c01002b2 <cprintf>
c0106bf9:	83 c4 10             	add    $0x10,%esp
          check_swap();
c0106bfc:	e8 0f 04 00 00       	call   c0107010 <check_swap>
     }

     return r;
c0106c01:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106c04:	c9                   	leave  
c0106c05:	c3                   	ret    

c0106c06 <swap_init_mm>:

int
swap_init_mm(struct mm_struct *mm)
{
c0106c06:	f3 0f 1e fb          	endbr32 
c0106c0a:	55                   	push   %ebp
c0106c0b:	89 e5                	mov    %esp,%ebp
c0106c0d:	83 ec 08             	sub    $0x8,%esp
     return sm->init_mm(mm);
c0106c10:	a1 18 f0 12 c0       	mov    0xc012f018,%eax
c0106c15:	8b 40 08             	mov    0x8(%eax),%eax
c0106c18:	83 ec 0c             	sub    $0xc,%esp
c0106c1b:	ff 75 08             	pushl  0x8(%ebp)
c0106c1e:	ff d0                	call   *%eax
c0106c20:	83 c4 10             	add    $0x10,%esp
}
c0106c23:	c9                   	leave  
c0106c24:	c3                   	ret    

c0106c25 <swap_tick_event>:

int
swap_tick_event(struct mm_struct *mm)
{
c0106c25:	f3 0f 1e fb          	endbr32 
c0106c29:	55                   	push   %ebp
c0106c2a:	89 e5                	mov    %esp,%ebp
c0106c2c:	83 ec 08             	sub    $0x8,%esp
     return sm->tick_event(mm);
c0106c2f:	a1 18 f0 12 c0       	mov    0xc012f018,%eax
c0106c34:	8b 40 0c             	mov    0xc(%eax),%eax
c0106c37:	83 ec 0c             	sub    $0xc,%esp
c0106c3a:	ff 75 08             	pushl  0x8(%ebp)
c0106c3d:	ff d0                	call   *%eax
c0106c3f:	83 c4 10             	add    $0x10,%esp
}
c0106c42:	c9                   	leave  
c0106c43:	c3                   	ret    

c0106c44 <swap_map_swappable>:

int
swap_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c0106c44:	f3 0f 1e fb          	endbr32 
c0106c48:	55                   	push   %ebp
c0106c49:	89 e5                	mov    %esp,%ebp
c0106c4b:	83 ec 08             	sub    $0x8,%esp
     return sm->map_swappable(mm, addr, page, swap_in);
c0106c4e:	a1 18 f0 12 c0       	mov    0xc012f018,%eax
c0106c53:	8b 40 10             	mov    0x10(%eax),%eax
c0106c56:	ff 75 14             	pushl  0x14(%ebp)
c0106c59:	ff 75 10             	pushl  0x10(%ebp)
c0106c5c:	ff 75 0c             	pushl  0xc(%ebp)
c0106c5f:	ff 75 08             	pushl  0x8(%ebp)
c0106c62:	ff d0                	call   *%eax
c0106c64:	83 c4 10             	add    $0x10,%esp
}
c0106c67:	c9                   	leave  
c0106c68:	c3                   	ret    

c0106c69 <swap_set_unswappable>:

int
swap_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c0106c69:	f3 0f 1e fb          	endbr32 
c0106c6d:	55                   	push   %ebp
c0106c6e:	89 e5                	mov    %esp,%ebp
c0106c70:	83 ec 08             	sub    $0x8,%esp
     return sm->set_unswappable(mm, addr);
c0106c73:	a1 18 f0 12 c0       	mov    0xc012f018,%eax
c0106c78:	8b 40 14             	mov    0x14(%eax),%eax
c0106c7b:	83 ec 08             	sub    $0x8,%esp
c0106c7e:	ff 75 0c             	pushl  0xc(%ebp)
c0106c81:	ff 75 08             	pushl  0x8(%ebp)
c0106c84:	ff d0                	call   *%eax
c0106c86:	83 c4 10             	add    $0x10,%esp
}
c0106c89:	c9                   	leave  
c0106c8a:	c3                   	ret    

c0106c8b <swap_out>:

volatile unsigned int swap_out_num=0;

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
c0106c8b:	f3 0f 1e fb          	endbr32 
c0106c8f:	55                   	push   %ebp
c0106c90:	89 e5                	mov    %esp,%ebp
c0106c92:	83 ec 28             	sub    $0x28,%esp
     int i;
     for (i = 0; i != n; ++ i)
c0106c95:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0106c9c:	e9 2e 01 00 00       	jmp    c0106dcf <swap_out+0x144>
     {
          uintptr_t v;
          //struct Page **ptr_page=NULL;
          struct Page *page;
          // cprintf("i %d, SWAP: call swap_out_victim\n",i);
          int r = sm->swap_out_victim(mm, &page, in_tick);
c0106ca1:	a1 18 f0 12 c0       	mov    0xc012f018,%eax
c0106ca6:	8b 40 18             	mov    0x18(%eax),%eax
c0106ca9:	83 ec 04             	sub    $0x4,%esp
c0106cac:	ff 75 10             	pushl  0x10(%ebp)
c0106caf:	8d 55 e4             	lea    -0x1c(%ebp),%edx
c0106cb2:	52                   	push   %edx
c0106cb3:	ff 75 08             	pushl  0x8(%ebp)
c0106cb6:	ff d0                	call   *%eax
c0106cb8:	83 c4 10             	add    $0x10,%esp
c0106cbb:	89 45 f0             	mov    %eax,-0x10(%ebp)
          if (r != 0) {
c0106cbe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0106cc2:	74 18                	je     c0106cdc <swap_out+0x51>
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
c0106cc4:	83 ec 08             	sub    $0x8,%esp
c0106cc7:	ff 75 f4             	pushl  -0xc(%ebp)
c0106cca:	68 e8 c2 10 c0       	push   $0xc010c2e8
c0106ccf:	e8 de 95 ff ff       	call   c01002b2 <cprintf>
c0106cd4:	83 c4 10             	add    $0x10,%esp
c0106cd7:	e9 ff 00 00 00       	jmp    c0106ddb <swap_out+0x150>
          }          
          //assert(!PageReserved(page));

          //cprintf("SWAP: choose victim page 0x%08x\n", page);
          
          v=page->pra_vaddr; 
c0106cdc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106cdf:	8b 40 20             	mov    0x20(%eax),%eax
c0106ce2:	89 45 ec             	mov    %eax,-0x14(%ebp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
c0106ce5:	8b 45 08             	mov    0x8(%ebp),%eax
c0106ce8:	8b 40 0c             	mov    0xc(%eax),%eax
c0106ceb:	83 ec 04             	sub    $0x4,%esp
c0106cee:	6a 00                	push   $0x0
c0106cf0:	ff 75 ec             	pushl  -0x14(%ebp)
c0106cf3:	50                   	push   %eax
c0106cf4:	e8 f3 e2 ff ff       	call   c0104fec <get_pte>
c0106cf9:	83 c4 10             	add    $0x10,%esp
c0106cfc:	89 45 e8             	mov    %eax,-0x18(%ebp)
          assert((*ptep & PTE_P) != 0);
c0106cff:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106d02:	8b 00                	mov    (%eax),%eax
c0106d04:	83 e0 01             	and    $0x1,%eax
c0106d07:	85 c0                	test   %eax,%eax
c0106d09:	75 16                	jne    c0106d21 <swap_out+0x96>
c0106d0b:	68 15 c3 10 c0       	push   $0xc010c315
c0106d10:	68 2a c3 10 c0       	push   $0xc010c32a
c0106d15:	6a 65                	push   $0x65
c0106d17:	68 c4 c2 10 c0       	push   $0xc010c2c4
c0106d1c:	e8 cd aa ff ff       	call   c01017ee <__panic>

          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
c0106d21:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106d24:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106d27:	8b 52 20             	mov    0x20(%edx),%edx
c0106d2a:	c1 ea 0c             	shr    $0xc,%edx
c0106d2d:	83 c2 01             	add    $0x1,%edx
c0106d30:	c1 e2 08             	shl    $0x8,%edx
c0106d33:	83 ec 08             	sub    $0x8,%esp
c0106d36:	50                   	push   %eax
c0106d37:	52                   	push   %edx
c0106d38:	e8 15 26 00 00       	call   c0109352 <swapfs_write>
c0106d3d:	83 c4 10             	add    $0x10,%esp
c0106d40:	85 c0                	test   %eax,%eax
c0106d42:	74 2b                	je     c0106d6f <swap_out+0xe4>
                    cprintf("SWAP: failed to save\n");
c0106d44:	83 ec 0c             	sub    $0xc,%esp
c0106d47:	68 3f c3 10 c0       	push   $0xc010c33f
c0106d4c:	e8 61 95 ff ff       	call   c01002b2 <cprintf>
c0106d51:	83 c4 10             	add    $0x10,%esp
                    sm->map_swappable(mm, v, page, 0);
c0106d54:	a1 18 f0 12 c0       	mov    0xc012f018,%eax
c0106d59:	8b 40 10             	mov    0x10(%eax),%eax
c0106d5c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106d5f:	6a 00                	push   $0x0
c0106d61:	52                   	push   %edx
c0106d62:	ff 75 ec             	pushl  -0x14(%ebp)
c0106d65:	ff 75 08             	pushl  0x8(%ebp)
c0106d68:	ff d0                	call   *%eax
c0106d6a:	83 c4 10             	add    $0x10,%esp
c0106d6d:	eb 5c                	jmp    c0106dcb <swap_out+0x140>
                    continue;
          }
          else {
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
c0106d6f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106d72:	8b 40 20             	mov    0x20(%eax),%eax
c0106d75:	c1 e8 0c             	shr    $0xc,%eax
c0106d78:	83 c0 01             	add    $0x1,%eax
c0106d7b:	50                   	push   %eax
c0106d7c:	ff 75 ec             	pushl  -0x14(%ebp)
c0106d7f:	ff 75 f4             	pushl  -0xc(%ebp)
c0106d82:	68 58 c3 10 c0       	push   $0xc010c358
c0106d87:	e8 26 95 ff ff       	call   c01002b2 <cprintf>
c0106d8c:	83 c4 10             	add    $0x10,%esp
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
c0106d8f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106d92:	8b 40 20             	mov    0x20(%eax),%eax
c0106d95:	c1 e8 0c             	shr    $0xc,%eax
c0106d98:	83 c0 01             	add    $0x1,%eax
c0106d9b:	c1 e0 08             	shl    $0x8,%eax
c0106d9e:	89 c2                	mov    %eax,%edx
c0106da0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106da3:	89 10                	mov    %edx,(%eax)
                    free_page(page);
c0106da5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106da8:	83 ec 08             	sub    $0x8,%esp
c0106dab:	6a 01                	push   $0x1
c0106dad:	50                   	push   %eax
c0106dae:	e8 2f dc ff ff       	call   c01049e2 <free_pages>
c0106db3:	83 c4 10             	add    $0x10,%esp
          }
          
          tlb_invalidate(mm->pgdir, v);
c0106db6:	8b 45 08             	mov    0x8(%ebp),%eax
c0106db9:	8b 40 0c             	mov    0xc(%eax),%eax
c0106dbc:	83 ec 08             	sub    $0x8,%esp
c0106dbf:	ff 75 ec             	pushl  -0x14(%ebp)
c0106dc2:	50                   	push   %eax
c0106dc3:	e8 fe e4 ff ff       	call   c01052c6 <tlb_invalidate>
c0106dc8:	83 c4 10             	add    $0x10,%esp
     for (i = 0; i != n; ++ i)
c0106dcb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0106dcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106dd2:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106dd5:	0f 85 c6 fe ff ff    	jne    c0106ca1 <swap_out+0x16>
     }
     return i;
c0106ddb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106dde:	c9                   	leave  
c0106ddf:	c3                   	ret    

c0106de0 <swap_in>:

int
swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result)
{
c0106de0:	f3 0f 1e fb          	endbr32 
c0106de4:	55                   	push   %ebp
c0106de5:	89 e5                	mov    %esp,%ebp
c0106de7:	83 ec 18             	sub    $0x18,%esp
     struct Page *result = alloc_page();
c0106dea:	83 ec 0c             	sub    $0xc,%esp
c0106ded:	6a 01                	push   $0x1
c0106def:	e8 7e db ff ff       	call   c0104972 <alloc_pages>
c0106df4:	83 c4 10             	add    $0x10,%esp
c0106df7:	89 45 f4             	mov    %eax,-0xc(%ebp)
     assert(result!=NULL);
c0106dfa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106dfe:	75 16                	jne    c0106e16 <swap_in+0x36>
c0106e00:	68 98 c3 10 c0       	push   $0xc010c398
c0106e05:	68 2a c3 10 c0       	push   $0xc010c32a
c0106e0a:	6a 7b                	push   $0x7b
c0106e0c:	68 c4 c2 10 c0       	push   $0xc010c2c4
c0106e11:	e8 d8 a9 ff ff       	call   c01017ee <__panic>

     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
c0106e16:	8b 45 08             	mov    0x8(%ebp),%eax
c0106e19:	8b 40 0c             	mov    0xc(%eax),%eax
c0106e1c:	83 ec 04             	sub    $0x4,%esp
c0106e1f:	6a 00                	push   $0x0
c0106e21:	ff 75 0c             	pushl  0xc(%ebp)
c0106e24:	50                   	push   %eax
c0106e25:	e8 c2 e1 ff ff       	call   c0104fec <get_pte>
c0106e2a:	83 c4 10             	add    $0x10,%esp
c0106e2d:	89 45 f0             	mov    %eax,-0x10(%ebp)
     // cprintf("SWAP: load ptep %x swap entry %d to vaddr 0x%08x, page %x, No %d\n", ptep, (*ptep)>>8, addr, result, (result-pages));
    
     int r;
     if ((r = swapfs_read((*ptep), result)) != 0)
c0106e30:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106e33:	8b 00                	mov    (%eax),%eax
c0106e35:	83 ec 08             	sub    $0x8,%esp
c0106e38:	ff 75 f4             	pushl  -0xc(%ebp)
c0106e3b:	50                   	push   %eax
c0106e3c:	e8 b5 24 00 00       	call   c01092f6 <swapfs_read>
c0106e41:	83 c4 10             	add    $0x10,%esp
c0106e44:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106e47:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0106e4b:	74 1f                	je     c0106e6c <swap_in+0x8c>
     {
        assert(r!=0);
c0106e4d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0106e51:	75 19                	jne    c0106e6c <swap_in+0x8c>
c0106e53:	68 a5 c3 10 c0       	push   $0xc010c3a5
c0106e58:	68 2a c3 10 c0       	push   $0xc010c32a
c0106e5d:	68 83 00 00 00       	push   $0x83
c0106e62:	68 c4 c2 10 c0       	push   $0xc010c2c4
c0106e67:	e8 82 a9 ff ff       	call   c01017ee <__panic>
     }
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
c0106e6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106e6f:	8b 00                	mov    (%eax),%eax
c0106e71:	c1 e8 08             	shr    $0x8,%eax
c0106e74:	83 ec 04             	sub    $0x4,%esp
c0106e77:	ff 75 0c             	pushl  0xc(%ebp)
c0106e7a:	50                   	push   %eax
c0106e7b:	68 ac c3 10 c0       	push   $0xc010c3ac
c0106e80:	e8 2d 94 ff ff       	call   c01002b2 <cprintf>
c0106e85:	83 c4 10             	add    $0x10,%esp
     *ptr_result=result;
c0106e88:	8b 45 10             	mov    0x10(%ebp),%eax
c0106e8b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106e8e:	89 10                	mov    %edx,(%eax)
     return 0;
c0106e90:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106e95:	c9                   	leave  
c0106e96:	c3                   	ret    

c0106e97 <check_content_set>:



static inline void
check_content_set(void)
{
c0106e97:	55                   	push   %ebp
c0106e98:	89 e5                	mov    %esp,%ebp
c0106e9a:	83 ec 08             	sub    $0x8,%esp
     *(unsigned char *)0x1000 = 0x0a;
c0106e9d:	b8 00 10 00 00       	mov    $0x1000,%eax
c0106ea2:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c0106ea5:	a1 0c f0 12 c0       	mov    0xc012f00c,%eax
c0106eaa:	83 f8 01             	cmp    $0x1,%eax
c0106ead:	74 19                	je     c0106ec8 <check_content_set+0x31>
c0106eaf:	68 ea c3 10 c0       	push   $0xc010c3ea
c0106eb4:	68 2a c3 10 c0       	push   $0xc010c32a
c0106eb9:	68 90 00 00 00       	push   $0x90
c0106ebe:	68 c4 c2 10 c0       	push   $0xc010c2c4
c0106ec3:	e8 26 a9 ff ff       	call   c01017ee <__panic>
     *(unsigned char *)0x1010 = 0x0a;
c0106ec8:	b8 10 10 00 00       	mov    $0x1010,%eax
c0106ecd:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c0106ed0:	a1 0c f0 12 c0       	mov    0xc012f00c,%eax
c0106ed5:	83 f8 01             	cmp    $0x1,%eax
c0106ed8:	74 19                	je     c0106ef3 <check_content_set+0x5c>
c0106eda:	68 ea c3 10 c0       	push   $0xc010c3ea
c0106edf:	68 2a c3 10 c0       	push   $0xc010c32a
c0106ee4:	68 92 00 00 00       	push   $0x92
c0106ee9:	68 c4 c2 10 c0       	push   $0xc010c2c4
c0106eee:	e8 fb a8 ff ff       	call   c01017ee <__panic>
     *(unsigned char *)0x2000 = 0x0b;
c0106ef3:	b8 00 20 00 00       	mov    $0x2000,%eax
c0106ef8:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c0106efb:	a1 0c f0 12 c0       	mov    0xc012f00c,%eax
c0106f00:	83 f8 02             	cmp    $0x2,%eax
c0106f03:	74 19                	je     c0106f1e <check_content_set+0x87>
c0106f05:	68 f9 c3 10 c0       	push   $0xc010c3f9
c0106f0a:	68 2a c3 10 c0       	push   $0xc010c32a
c0106f0f:	68 94 00 00 00       	push   $0x94
c0106f14:	68 c4 c2 10 c0       	push   $0xc010c2c4
c0106f19:	e8 d0 a8 ff ff       	call   c01017ee <__panic>
     *(unsigned char *)0x2010 = 0x0b;
c0106f1e:	b8 10 20 00 00       	mov    $0x2010,%eax
c0106f23:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c0106f26:	a1 0c f0 12 c0       	mov    0xc012f00c,%eax
c0106f2b:	83 f8 02             	cmp    $0x2,%eax
c0106f2e:	74 19                	je     c0106f49 <check_content_set+0xb2>
c0106f30:	68 f9 c3 10 c0       	push   $0xc010c3f9
c0106f35:	68 2a c3 10 c0       	push   $0xc010c32a
c0106f3a:	68 96 00 00 00       	push   $0x96
c0106f3f:	68 c4 c2 10 c0       	push   $0xc010c2c4
c0106f44:	e8 a5 a8 ff ff       	call   c01017ee <__panic>
     *(unsigned char *)0x3000 = 0x0c;
c0106f49:	b8 00 30 00 00       	mov    $0x3000,%eax
c0106f4e:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c0106f51:	a1 0c f0 12 c0       	mov    0xc012f00c,%eax
c0106f56:	83 f8 03             	cmp    $0x3,%eax
c0106f59:	74 19                	je     c0106f74 <check_content_set+0xdd>
c0106f5b:	68 08 c4 10 c0       	push   $0xc010c408
c0106f60:	68 2a c3 10 c0       	push   $0xc010c32a
c0106f65:	68 98 00 00 00       	push   $0x98
c0106f6a:	68 c4 c2 10 c0       	push   $0xc010c2c4
c0106f6f:	e8 7a a8 ff ff       	call   c01017ee <__panic>
     *(unsigned char *)0x3010 = 0x0c;
c0106f74:	b8 10 30 00 00       	mov    $0x3010,%eax
c0106f79:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c0106f7c:	a1 0c f0 12 c0       	mov    0xc012f00c,%eax
c0106f81:	83 f8 03             	cmp    $0x3,%eax
c0106f84:	74 19                	je     c0106f9f <check_content_set+0x108>
c0106f86:	68 08 c4 10 c0       	push   $0xc010c408
c0106f8b:	68 2a c3 10 c0       	push   $0xc010c32a
c0106f90:	68 9a 00 00 00       	push   $0x9a
c0106f95:	68 c4 c2 10 c0       	push   $0xc010c2c4
c0106f9a:	e8 4f a8 ff ff       	call   c01017ee <__panic>
     *(unsigned char *)0x4000 = 0x0d;
c0106f9f:	b8 00 40 00 00       	mov    $0x4000,%eax
c0106fa4:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c0106fa7:	a1 0c f0 12 c0       	mov    0xc012f00c,%eax
c0106fac:	83 f8 04             	cmp    $0x4,%eax
c0106faf:	74 19                	je     c0106fca <check_content_set+0x133>
c0106fb1:	68 17 c4 10 c0       	push   $0xc010c417
c0106fb6:	68 2a c3 10 c0       	push   $0xc010c32a
c0106fbb:	68 9c 00 00 00       	push   $0x9c
c0106fc0:	68 c4 c2 10 c0       	push   $0xc010c2c4
c0106fc5:	e8 24 a8 ff ff       	call   c01017ee <__panic>
     *(unsigned char *)0x4010 = 0x0d;
c0106fca:	b8 10 40 00 00       	mov    $0x4010,%eax
c0106fcf:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c0106fd2:	a1 0c f0 12 c0       	mov    0xc012f00c,%eax
c0106fd7:	83 f8 04             	cmp    $0x4,%eax
c0106fda:	74 19                	je     c0106ff5 <check_content_set+0x15e>
c0106fdc:	68 17 c4 10 c0       	push   $0xc010c417
c0106fe1:	68 2a c3 10 c0       	push   $0xc010c32a
c0106fe6:	68 9e 00 00 00       	push   $0x9e
c0106feb:	68 c4 c2 10 c0       	push   $0xc010c2c4
c0106ff0:	e8 f9 a7 ff ff       	call   c01017ee <__panic>
}
c0106ff5:	90                   	nop
c0106ff6:	c9                   	leave  
c0106ff7:	c3                   	ret    

c0106ff8 <check_content_access>:

static inline int
check_content_access(void)
{
c0106ff8:	55                   	push   %ebp
c0106ff9:	89 e5                	mov    %esp,%ebp
c0106ffb:	83 ec 18             	sub    $0x18,%esp
    int ret = sm->check_swap();
c0106ffe:	a1 18 f0 12 c0       	mov    0xc012f018,%eax
c0107003:	8b 40 1c             	mov    0x1c(%eax),%eax
c0107006:	ff d0                	call   *%eax
c0107008:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return ret;
c010700b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010700e:	c9                   	leave  
c010700f:	c3                   	ret    

c0107010 <check_swap>:
#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
check_swap(void)
{
c0107010:	f3 0f 1e fb          	endbr32 
c0107014:	55                   	push   %ebp
c0107015:	89 e5                	mov    %esp,%ebp
c0107017:	83 ec 68             	sub    $0x68,%esp
    //backup mem env
     int ret, count = 0, total = 0, i;
c010701a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0107021:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     list_entry_t *le = &free_list;
c0107028:	c7 45 e8 4c 11 13 c0 	movl   $0xc013114c,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c010702f:	eb 60                	jmp    c0107091 <check_swap+0x81>
        struct Page *p = le2page(le, page_link);
c0107031:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107034:	83 e8 10             	sub    $0x10,%eax
c0107037:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(PageProperty(p));
c010703a:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010703d:	83 c0 04             	add    $0x4,%eax
c0107040:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c0107047:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010704a:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010704d:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0107050:	0f a3 10             	bt     %edx,(%eax)
c0107053:	19 c0                	sbb    %eax,%eax
c0107055:	89 45 bc             	mov    %eax,-0x44(%ebp)
    return oldbit != 0;
c0107058:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c010705c:	0f 95 c0             	setne  %al
c010705f:	0f b6 c0             	movzbl %al,%eax
c0107062:	85 c0                	test   %eax,%eax
c0107064:	75 19                	jne    c010707f <check_swap+0x6f>
c0107066:	68 26 c4 10 c0       	push   $0xc010c426
c010706b:	68 2a c3 10 c0       	push   $0xc010c32a
c0107070:	68 b9 00 00 00       	push   $0xb9
c0107075:	68 c4 c2 10 c0       	push   $0xc010c2c4
c010707a:	e8 6f a7 ff ff       	call   c01017ee <__panic>
        count ++, total += p->property;
c010707f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0107083:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0107086:	8b 50 08             	mov    0x8(%eax),%edx
c0107089:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010708c:	01 d0                	add    %edx,%eax
c010708e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107091:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107094:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0107097:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010709a:	8b 40 04             	mov    0x4(%eax),%eax
     while ((le = list_next(le)) != &free_list) {
c010709d:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01070a0:	81 7d e8 4c 11 13 c0 	cmpl   $0xc013114c,-0x18(%ebp)
c01070a7:	75 88                	jne    c0107031 <check_swap+0x21>
     }
     assert(total == nr_free_pages());
c01070a9:	e8 6d d9 ff ff       	call   c0104a1b <nr_free_pages>
c01070ae:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01070b1:	39 d0                	cmp    %edx,%eax
c01070b3:	74 19                	je     c01070ce <check_swap+0xbe>
c01070b5:	68 36 c4 10 c0       	push   $0xc010c436
c01070ba:	68 2a c3 10 c0       	push   $0xc010c32a
c01070bf:	68 bc 00 00 00       	push   $0xbc
c01070c4:	68 c4 c2 10 c0       	push   $0xc010c2c4
c01070c9:	e8 20 a7 ff ff       	call   c01017ee <__panic>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
c01070ce:	83 ec 04             	sub    $0x4,%esp
c01070d1:	ff 75 f0             	pushl  -0x10(%ebp)
c01070d4:	ff 75 f4             	pushl  -0xc(%ebp)
c01070d7:	68 50 c4 10 c0       	push   $0xc010c450
c01070dc:	e8 d1 91 ff ff       	call   c01002b2 <cprintf>
c01070e1:	83 c4 10             	add    $0x10,%esp
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
c01070e4:	e8 2d ee ff ff       	call   c0105f16 <mm_create>
c01070e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
     assert(mm != NULL);
c01070ec:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01070f0:	75 19                	jne    c010710b <check_swap+0xfb>
c01070f2:	68 76 c4 10 c0       	push   $0xc010c476
c01070f7:	68 2a c3 10 c0       	push   $0xc010c32a
c01070fc:	68 c1 00 00 00       	push   $0xc1
c0107101:	68 c4 c2 10 c0       	push   $0xc010c2c4
c0107106:	e8 e3 a6 ff ff       	call   c01017ee <__panic>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
c010710b:	a1 64 10 13 c0       	mov    0xc0131064,%eax
c0107110:	85 c0                	test   %eax,%eax
c0107112:	74 19                	je     c010712d <check_swap+0x11d>
c0107114:	68 81 c4 10 c0       	push   $0xc010c481
c0107119:	68 2a c3 10 c0       	push   $0xc010c32a
c010711e:	68 c4 00 00 00       	push   $0xc4
c0107123:	68 c4 c2 10 c0       	push   $0xc010c2c4
c0107128:	e8 c1 a6 ff ff       	call   c01017ee <__panic>

     check_mm_struct = mm;
c010712d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107130:	a3 64 10 13 c0       	mov    %eax,0xc0131064

     pde_t *pgdir = mm->pgdir = boot_pgdir;
c0107135:	8b 15 e0 b9 12 c0    	mov    0xc012b9e0,%edx
c010713b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010713e:	89 50 0c             	mov    %edx,0xc(%eax)
c0107141:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107144:	8b 40 0c             	mov    0xc(%eax),%eax
c0107147:	89 45 e0             	mov    %eax,-0x20(%ebp)
     assert(pgdir[0] == 0);
c010714a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010714d:	8b 00                	mov    (%eax),%eax
c010714f:	85 c0                	test   %eax,%eax
c0107151:	74 19                	je     c010716c <check_swap+0x15c>
c0107153:	68 99 c4 10 c0       	push   $0xc010c499
c0107158:	68 2a c3 10 c0       	push   $0xc010c32a
c010715d:	68 c9 00 00 00       	push   $0xc9
c0107162:	68 c4 c2 10 c0       	push   $0xc010c2c4
c0107167:	e8 82 a6 ff ff       	call   c01017ee <__panic>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
c010716c:	83 ec 04             	sub    $0x4,%esp
c010716f:	6a 03                	push   $0x3
c0107171:	68 00 60 00 00       	push   $0x6000
c0107176:	68 00 10 00 00       	push   $0x1000
c010717b:	e8 17 ee ff ff       	call   c0105f97 <vma_create>
c0107180:	83 c4 10             	add    $0x10,%esp
c0107183:	89 45 dc             	mov    %eax,-0x24(%ebp)
     assert(vma != NULL);
c0107186:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010718a:	75 19                	jne    c01071a5 <check_swap+0x195>
c010718c:	68 a7 c4 10 c0       	push   $0xc010c4a7
c0107191:	68 2a c3 10 c0       	push   $0xc010c32a
c0107196:	68 cc 00 00 00       	push   $0xcc
c010719b:	68 c4 c2 10 c0       	push   $0xc010c2c4
c01071a0:	e8 49 a6 ff ff       	call   c01017ee <__panic>

     insert_vma_struct(mm, vma);
c01071a5:	83 ec 08             	sub    $0x8,%esp
c01071a8:	ff 75 dc             	pushl  -0x24(%ebp)
c01071ab:	ff 75 e4             	pushl  -0x1c(%ebp)
c01071ae:	e8 54 ef ff ff       	call   c0106107 <insert_vma_struct>
c01071b3:	83 c4 10             	add    $0x10,%esp

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
c01071b6:	83 ec 0c             	sub    $0xc,%esp
c01071b9:	68 b4 c4 10 c0       	push   $0xc010c4b4
c01071be:	e8 ef 90 ff ff       	call   c01002b2 <cprintf>
c01071c3:	83 c4 10             	add    $0x10,%esp
     pte_t *temp_ptep=NULL;
c01071c6:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
c01071cd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01071d0:	8b 40 0c             	mov    0xc(%eax),%eax
c01071d3:	83 ec 04             	sub    $0x4,%esp
c01071d6:	6a 01                	push   $0x1
c01071d8:	68 00 10 00 00       	push   $0x1000
c01071dd:	50                   	push   %eax
c01071de:	e8 09 de ff ff       	call   c0104fec <get_pte>
c01071e3:	83 c4 10             	add    $0x10,%esp
c01071e6:	89 45 d8             	mov    %eax,-0x28(%ebp)
     assert(temp_ptep!= NULL);
c01071e9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c01071ed:	75 19                	jne    c0107208 <check_swap+0x1f8>
c01071ef:	68 e8 c4 10 c0       	push   $0xc010c4e8
c01071f4:	68 2a c3 10 c0       	push   $0xc010c32a
c01071f9:	68 d4 00 00 00       	push   $0xd4
c01071fe:	68 c4 c2 10 c0       	push   $0xc010c2c4
c0107203:	e8 e6 a5 ff ff       	call   c01017ee <__panic>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
c0107208:	83 ec 0c             	sub    $0xc,%esp
c010720b:	68 fc c4 10 c0       	push   $0xc010c4fc
c0107210:	e8 9d 90 ff ff       	call   c01002b2 <cprintf>
c0107215:	83 c4 10             	add    $0x10,%esp
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0107218:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c010721f:	e9 8e 00 00 00       	jmp    c01072b2 <check_swap+0x2a2>
          check_rp[i] = alloc_page();
c0107224:	83 ec 0c             	sub    $0xc,%esp
c0107227:	6a 01                	push   $0x1
c0107229:	e8 44 d7 ff ff       	call   c0104972 <alloc_pages>
c010722e:	83 c4 10             	add    $0x10,%esp
c0107231:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107234:	89 04 95 80 10 13 c0 	mov    %eax,-0x3fecef80(,%edx,4)
          assert(check_rp[i] != NULL );
c010723b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010723e:	8b 04 85 80 10 13 c0 	mov    -0x3fecef80(,%eax,4),%eax
c0107245:	85 c0                	test   %eax,%eax
c0107247:	75 19                	jne    c0107262 <check_swap+0x252>
c0107249:	68 20 c5 10 c0       	push   $0xc010c520
c010724e:	68 2a c3 10 c0       	push   $0xc010c32a
c0107253:	68 d9 00 00 00       	push   $0xd9
c0107258:	68 c4 c2 10 c0       	push   $0xc010c2c4
c010725d:	e8 8c a5 ff ff       	call   c01017ee <__panic>
          assert(!PageProperty(check_rp[i]));
c0107262:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107265:	8b 04 85 80 10 13 c0 	mov    -0x3fecef80(,%eax,4),%eax
c010726c:	83 c0 04             	add    $0x4,%eax
c010726f:	c7 45 b4 01 00 00 00 	movl   $0x1,-0x4c(%ebp)
c0107276:	89 45 b0             	mov    %eax,-0x50(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0107279:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010727c:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c010727f:	0f a3 10             	bt     %edx,(%eax)
c0107282:	19 c0                	sbb    %eax,%eax
c0107284:	89 45 ac             	mov    %eax,-0x54(%ebp)
    return oldbit != 0;
c0107287:	83 7d ac 00          	cmpl   $0x0,-0x54(%ebp)
c010728b:	0f 95 c0             	setne  %al
c010728e:	0f b6 c0             	movzbl %al,%eax
c0107291:	85 c0                	test   %eax,%eax
c0107293:	74 19                	je     c01072ae <check_swap+0x29e>
c0107295:	68 34 c5 10 c0       	push   $0xc010c534
c010729a:	68 2a c3 10 c0       	push   $0xc010c32a
c010729f:	68 da 00 00 00       	push   $0xda
c01072a4:	68 c4 c2 10 c0       	push   $0xc010c2c4
c01072a9:	e8 40 a5 ff ff       	call   c01017ee <__panic>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01072ae:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c01072b2:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c01072b6:	0f 8e 68 ff ff ff    	jle    c0107224 <check_swap+0x214>
     }
     list_entry_t free_list_store = free_list;
c01072bc:	a1 4c 11 13 c0       	mov    0xc013114c,%eax
c01072c1:	8b 15 50 11 13 c0    	mov    0xc0131150,%edx
c01072c7:	89 45 98             	mov    %eax,-0x68(%ebp)
c01072ca:	89 55 9c             	mov    %edx,-0x64(%ebp)
c01072cd:	c7 45 a4 4c 11 13 c0 	movl   $0xc013114c,-0x5c(%ebp)
    elm->prev = elm->next = elm;
c01072d4:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c01072d7:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c01072da:	89 50 04             	mov    %edx,0x4(%eax)
c01072dd:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c01072e0:	8b 50 04             	mov    0x4(%eax),%edx
c01072e3:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c01072e6:	89 10                	mov    %edx,(%eax)
}
c01072e8:	90                   	nop
c01072e9:	c7 45 a8 4c 11 13 c0 	movl   $0xc013114c,-0x58(%ebp)
    return list->next == list;
c01072f0:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01072f3:	8b 40 04             	mov    0x4(%eax),%eax
c01072f6:	39 45 a8             	cmp    %eax,-0x58(%ebp)
c01072f9:	0f 94 c0             	sete   %al
c01072fc:	0f b6 c0             	movzbl %al,%eax
     list_init(&free_list);
     assert(list_empty(&free_list));
c01072ff:	85 c0                	test   %eax,%eax
c0107301:	75 19                	jne    c010731c <check_swap+0x30c>
c0107303:	68 4f c5 10 c0       	push   $0xc010c54f
c0107308:	68 2a c3 10 c0       	push   $0xc010c32a
c010730d:	68 de 00 00 00       	push   $0xde
c0107312:	68 c4 c2 10 c0       	push   $0xc010c2c4
c0107317:	e8 d2 a4 ff ff       	call   c01017ee <__panic>
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
c010731c:	a1 54 11 13 c0       	mov    0xc0131154,%eax
c0107321:	89 45 d4             	mov    %eax,-0x2c(%ebp)
     nr_free = 0;
c0107324:	c7 05 54 11 13 c0 00 	movl   $0x0,0xc0131154
c010732b:	00 00 00 
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c010732e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0107335:	eb 1c                	jmp    c0107353 <check_swap+0x343>
        free_pages(check_rp[i],1);
c0107337:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010733a:	8b 04 85 80 10 13 c0 	mov    -0x3fecef80(,%eax,4),%eax
c0107341:	83 ec 08             	sub    $0x8,%esp
c0107344:	6a 01                	push   $0x1
c0107346:	50                   	push   %eax
c0107347:	e8 96 d6 ff ff       	call   c01049e2 <free_pages>
c010734c:	83 c4 10             	add    $0x10,%esp
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c010734f:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0107353:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0107357:	7e de                	jle    c0107337 <check_swap+0x327>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
c0107359:	a1 54 11 13 c0       	mov    0xc0131154,%eax
c010735e:	83 f8 04             	cmp    $0x4,%eax
c0107361:	74 19                	je     c010737c <check_swap+0x36c>
c0107363:	68 68 c5 10 c0       	push   $0xc010c568
c0107368:	68 2a c3 10 c0       	push   $0xc010c32a
c010736d:	68 e7 00 00 00       	push   $0xe7
c0107372:	68 c4 c2 10 c0       	push   $0xc010c2c4
c0107377:	e8 72 a4 ff ff       	call   c01017ee <__panic>
     
     cprintf("set up init env for check_swap begin!\n");
c010737c:	83 ec 0c             	sub    $0xc,%esp
c010737f:	68 8c c5 10 c0       	push   $0xc010c58c
c0107384:	e8 29 8f ff ff       	call   c01002b2 <cprintf>
c0107389:	83 c4 10             	add    $0x10,%esp
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
c010738c:	c7 05 0c f0 12 c0 00 	movl   $0x0,0xc012f00c
c0107393:	00 00 00 
     
     check_content_set();
c0107396:	e8 fc fa ff ff       	call   c0106e97 <check_content_set>
     assert( nr_free == 0);         
c010739b:	a1 54 11 13 c0       	mov    0xc0131154,%eax
c01073a0:	85 c0                	test   %eax,%eax
c01073a2:	74 19                	je     c01073bd <check_swap+0x3ad>
c01073a4:	68 b3 c5 10 c0       	push   $0xc010c5b3
c01073a9:	68 2a c3 10 c0       	push   $0xc010c32a
c01073ae:	68 f0 00 00 00       	push   $0xf0
c01073b3:	68 c4 c2 10 c0       	push   $0xc010c2c4
c01073b8:	e8 31 a4 ff ff       	call   c01017ee <__panic>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c01073bd:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01073c4:	eb 26                	jmp    c01073ec <check_swap+0x3dc>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
c01073c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01073c9:	c7 04 85 a0 10 13 c0 	movl   $0xffffffff,-0x3fecef60(,%eax,4)
c01073d0:	ff ff ff ff 
c01073d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01073d7:	8b 14 85 a0 10 13 c0 	mov    -0x3fecef60(,%eax,4),%edx
c01073de:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01073e1:	89 14 85 e0 10 13 c0 	mov    %edx,-0x3fecef20(,%eax,4)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c01073e8:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c01073ec:	83 7d ec 09          	cmpl   $0x9,-0x14(%ebp)
c01073f0:	7e d4                	jle    c01073c6 <check_swap+0x3b6>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01073f2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01073f9:	e9 c8 00 00 00       	jmp    c01074c6 <check_swap+0x4b6>
         check_ptep[i]=0;
c01073fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107401:	c7 04 85 34 11 13 c0 	movl   $0x0,-0x3feceecc(,%eax,4)
c0107408:	00 00 00 00 
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
c010740c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010740f:	83 c0 01             	add    $0x1,%eax
c0107412:	c1 e0 0c             	shl    $0xc,%eax
c0107415:	83 ec 04             	sub    $0x4,%esp
c0107418:	6a 00                	push   $0x0
c010741a:	50                   	push   %eax
c010741b:	ff 75 e0             	pushl  -0x20(%ebp)
c010741e:	e8 c9 db ff ff       	call   c0104fec <get_pte>
c0107423:	83 c4 10             	add    $0x10,%esp
c0107426:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107429:	89 04 95 34 11 13 c0 	mov    %eax,-0x3feceecc(,%edx,4)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
c0107430:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107433:	8b 04 85 34 11 13 c0 	mov    -0x3feceecc(,%eax,4),%eax
c010743a:	85 c0                	test   %eax,%eax
c010743c:	75 19                	jne    c0107457 <check_swap+0x447>
c010743e:	68 c0 c5 10 c0       	push   $0xc010c5c0
c0107443:	68 2a c3 10 c0       	push   $0xc010c32a
c0107448:	68 f8 00 00 00       	push   $0xf8
c010744d:	68 c4 c2 10 c0       	push   $0xc010c2c4
c0107452:	e8 97 a3 ff ff       	call   c01017ee <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
c0107457:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010745a:	8b 04 85 34 11 13 c0 	mov    -0x3feceecc(,%eax,4),%eax
c0107461:	8b 00                	mov    (%eax),%eax
c0107463:	83 ec 0c             	sub    $0xc,%esp
c0107466:	50                   	push   %eax
c0107467:	e8 d9 f6 ff ff       	call   c0106b45 <pte2page>
c010746c:	83 c4 10             	add    $0x10,%esp
c010746f:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107472:	8b 14 95 80 10 13 c0 	mov    -0x3fecef80(,%edx,4),%edx
c0107479:	39 d0                	cmp    %edx,%eax
c010747b:	74 19                	je     c0107496 <check_swap+0x486>
c010747d:	68 d8 c5 10 c0       	push   $0xc010c5d8
c0107482:	68 2a c3 10 c0       	push   $0xc010c32a
c0107487:	68 f9 00 00 00       	push   $0xf9
c010748c:	68 c4 c2 10 c0       	push   $0xc010c2c4
c0107491:	e8 58 a3 ff ff       	call   c01017ee <__panic>
         assert((*check_ptep[i] & PTE_P));          
c0107496:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107499:	8b 04 85 34 11 13 c0 	mov    -0x3feceecc(,%eax,4),%eax
c01074a0:	8b 00                	mov    (%eax),%eax
c01074a2:	83 e0 01             	and    $0x1,%eax
c01074a5:	85 c0                	test   %eax,%eax
c01074a7:	75 19                	jne    c01074c2 <check_swap+0x4b2>
c01074a9:	68 00 c6 10 c0       	push   $0xc010c600
c01074ae:	68 2a c3 10 c0       	push   $0xc010c32a
c01074b3:	68 fa 00 00 00       	push   $0xfa
c01074b8:	68 c4 c2 10 c0       	push   $0xc010c2c4
c01074bd:	e8 2c a3 ff ff       	call   c01017ee <__panic>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01074c2:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c01074c6:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c01074ca:	0f 8e 2e ff ff ff    	jle    c01073fe <check_swap+0x3ee>
     }
     cprintf("set up init env for check_swap over!\n");
c01074d0:	83 ec 0c             	sub    $0xc,%esp
c01074d3:	68 1c c6 10 c0       	push   $0xc010c61c
c01074d8:	e8 d5 8d ff ff       	call   c01002b2 <cprintf>
c01074dd:	83 c4 10             	add    $0x10,%esp
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
c01074e0:	e8 13 fb ff ff       	call   c0106ff8 <check_content_access>
c01074e5:	89 45 d0             	mov    %eax,-0x30(%ebp)
     assert(ret==0);
c01074e8:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c01074ec:	74 19                	je     c0107507 <check_swap+0x4f7>
c01074ee:	68 42 c6 10 c0       	push   $0xc010c642
c01074f3:	68 2a c3 10 c0       	push   $0xc010c32a
c01074f8:	68 ff 00 00 00       	push   $0xff
c01074fd:	68 c4 c2 10 c0       	push   $0xc010c2c4
c0107502:	e8 e7 a2 ff ff       	call   c01017ee <__panic>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0107507:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c010750e:	eb 1c                	jmp    c010752c <check_swap+0x51c>
         free_pages(check_rp[i],1);
c0107510:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107513:	8b 04 85 80 10 13 c0 	mov    -0x3fecef80(,%eax,4),%eax
c010751a:	83 ec 08             	sub    $0x8,%esp
c010751d:	6a 01                	push   $0x1
c010751f:	50                   	push   %eax
c0107520:	e8 bd d4 ff ff       	call   c01049e2 <free_pages>
c0107525:	83 c4 10             	add    $0x10,%esp
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0107528:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c010752c:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0107530:	7e de                	jle    c0107510 <check_swap+0x500>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
c0107532:	83 ec 0c             	sub    $0xc,%esp
c0107535:	ff 75 e4             	pushl  -0x1c(%ebp)
c0107538:	e8 f4 ec ff ff       	call   c0106231 <mm_destroy>
c010753d:	83 c4 10             	add    $0x10,%esp
         
     nr_free = nr_free_store;
c0107540:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0107543:	a3 54 11 13 c0       	mov    %eax,0xc0131154
     free_list = free_list_store;
c0107548:	8b 45 98             	mov    -0x68(%ebp),%eax
c010754b:	8b 55 9c             	mov    -0x64(%ebp),%edx
c010754e:	a3 4c 11 13 c0       	mov    %eax,0xc013114c
c0107553:	89 15 50 11 13 c0    	mov    %edx,0xc0131150

     
     le = &free_list;
c0107559:	c7 45 e8 4c 11 13 c0 	movl   $0xc013114c,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c0107560:	eb 1d                	jmp    c010757f <check_swap+0x56f>
         struct Page *p = le2page(le, page_link);
c0107562:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107565:	83 e8 10             	sub    $0x10,%eax
c0107568:	89 45 cc             	mov    %eax,-0x34(%ebp)
         count --, total -= p->property;
c010756b:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c010756f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0107572:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0107575:	8b 40 08             	mov    0x8(%eax),%eax
c0107578:	29 c2                	sub    %eax,%edx
c010757a:	89 d0                	mov    %edx,%eax
c010757c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010757f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107582:	89 45 a0             	mov    %eax,-0x60(%ebp)
    return listelm->next;
c0107585:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0107588:	8b 40 04             	mov    0x4(%eax),%eax
     while ((le = list_next(le)) != &free_list) {
c010758b:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010758e:	81 7d e8 4c 11 13 c0 	cmpl   $0xc013114c,-0x18(%ebp)
c0107595:	75 cb                	jne    c0107562 <check_swap+0x552>
     }
     cprintf("count is %d, total is %d\n",count,total);
c0107597:	83 ec 04             	sub    $0x4,%esp
c010759a:	ff 75 f0             	pushl  -0x10(%ebp)
c010759d:	ff 75 f4             	pushl  -0xc(%ebp)
c01075a0:	68 49 c6 10 c0       	push   $0xc010c649
c01075a5:	e8 08 8d ff ff       	call   c01002b2 <cprintf>
c01075aa:	83 c4 10             	add    $0x10,%esp
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
c01075ad:	83 ec 0c             	sub    $0xc,%esp
c01075b0:	68 63 c6 10 c0       	push   $0xc010c663
c01075b5:	e8 f8 8c ff ff       	call   c01002b2 <cprintf>
c01075ba:	83 c4 10             	add    $0x10,%esp
}
c01075bd:	90                   	nop
c01075be:	c9                   	leave  
c01075bf:	c3                   	ret    

c01075c0 <__intr_save>:
__intr_save(void) {
c01075c0:	55                   	push   %ebp
c01075c1:	89 e5                	mov    %esp,%ebp
c01075c3:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c01075c6:	9c                   	pushf  
c01075c7:	58                   	pop    %eax
c01075c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c01075cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c01075ce:	25 00 02 00 00       	and    $0x200,%eax
c01075d3:	85 c0                	test   %eax,%eax
c01075d5:	74 0c                	je     c01075e3 <__intr_save+0x23>
        intr_disable();
c01075d7:	e8 50 bf ff ff       	call   c010352c <intr_disable>
        return 1;
c01075dc:	b8 01 00 00 00       	mov    $0x1,%eax
c01075e1:	eb 05                	jmp    c01075e8 <__intr_save+0x28>
    return 0;
c01075e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01075e8:	c9                   	leave  
c01075e9:	c3                   	ret    

c01075ea <__intr_restore>:
__intr_restore(bool flag) {
c01075ea:	55                   	push   %ebp
c01075eb:	89 e5                	mov    %esp,%ebp
c01075ed:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c01075f0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01075f4:	74 05                	je     c01075fb <__intr_restore+0x11>
        intr_enable();
c01075f6:	e8 25 bf ff ff       	call   c0103520 <intr_enable>
}
c01075fb:	90                   	nop
c01075fc:	c9                   	leave  
c01075fd:	c3                   	ret    

c01075fe <page2ppn>:
page2ppn(struct Page *page) {
c01075fe:	55                   	push   %ebp
c01075ff:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0107601:	a1 60 10 13 c0       	mov    0xc0131060,%eax
c0107606:	8b 55 08             	mov    0x8(%ebp),%edx
c0107609:	29 c2                	sub    %eax,%edx
c010760b:	89 d0                	mov    %edx,%eax
c010760d:	c1 f8 02             	sar    $0x2,%eax
c0107610:	69 c0 39 8e e3 38    	imul   $0x38e38e39,%eax,%eax
}
c0107616:	5d                   	pop    %ebp
c0107617:	c3                   	ret    

c0107618 <page2pa>:
page2pa(struct Page *page) {
c0107618:	55                   	push   %ebp
c0107619:	89 e5                	mov    %esp,%ebp
    return page2ppn(page) << PGSHIFT;
c010761b:	ff 75 08             	pushl  0x8(%ebp)
c010761e:	e8 db ff ff ff       	call   c01075fe <page2ppn>
c0107623:	83 c4 04             	add    $0x4,%esp
c0107626:	c1 e0 0c             	shl    $0xc,%eax
}
c0107629:	c9                   	leave  
c010762a:	c3                   	ret    

c010762b <pa2page>:
pa2page(uintptr_t pa) {
c010762b:	55                   	push   %ebp
c010762c:	89 e5                	mov    %esp,%ebp
c010762e:	83 ec 08             	sub    $0x8,%esp
    if (PPN(pa) >= npage) {
c0107631:	8b 45 08             	mov    0x8(%ebp),%eax
c0107634:	c1 e8 0c             	shr    $0xc,%eax
c0107637:	89 c2                	mov    %eax,%edx
c0107639:	a1 80 ef 12 c0       	mov    0xc012ef80,%eax
c010763e:	39 c2                	cmp    %eax,%edx
c0107640:	72 14                	jb     c0107656 <pa2page+0x2b>
        panic("pa2page called with invalid pa");
c0107642:	83 ec 04             	sub    $0x4,%esp
c0107645:	68 7c c6 10 c0       	push   $0xc010c67c
c010764a:	6a 5f                	push   $0x5f
c010764c:	68 9b c6 10 c0       	push   $0xc010c69b
c0107651:	e8 98 a1 ff ff       	call   c01017ee <__panic>
    return &pages[PPN(pa)];
c0107656:	8b 0d 60 10 13 c0    	mov    0xc0131060,%ecx
c010765c:	8b 45 08             	mov    0x8(%ebp),%eax
c010765f:	c1 e8 0c             	shr    $0xc,%eax
c0107662:	89 c2                	mov    %eax,%edx
c0107664:	89 d0                	mov    %edx,%eax
c0107666:	c1 e0 03             	shl    $0x3,%eax
c0107669:	01 d0                	add    %edx,%eax
c010766b:	c1 e0 02             	shl    $0x2,%eax
c010766e:	01 c8                	add    %ecx,%eax
}
c0107670:	c9                   	leave  
c0107671:	c3                   	ret    

c0107672 <page2kva>:
page2kva(struct Page *page) {
c0107672:	55                   	push   %ebp
c0107673:	89 e5                	mov    %esp,%ebp
c0107675:	83 ec 18             	sub    $0x18,%esp
    return KADDR(page2pa(page));
c0107678:	ff 75 08             	pushl  0x8(%ebp)
c010767b:	e8 98 ff ff ff       	call   c0107618 <page2pa>
c0107680:	83 c4 04             	add    $0x4,%esp
c0107683:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107686:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107689:	c1 e8 0c             	shr    $0xc,%eax
c010768c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010768f:	a1 80 ef 12 c0       	mov    0xc012ef80,%eax
c0107694:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0107697:	72 14                	jb     c01076ad <page2kva+0x3b>
c0107699:	ff 75 f4             	pushl  -0xc(%ebp)
c010769c:	68 ac c6 10 c0       	push   $0xc010c6ac
c01076a1:	6a 66                	push   $0x66
c01076a3:	68 9b c6 10 c0       	push   $0xc010c69b
c01076a8:	e8 41 a1 ff ff       	call   c01017ee <__panic>
c01076ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01076b0:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c01076b5:	c9                   	leave  
c01076b6:	c3                   	ret    

c01076b7 <kva2page>:
kva2page(void *kva) {
c01076b7:	55                   	push   %ebp
c01076b8:	89 e5                	mov    %esp,%ebp
c01076ba:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PADDR(kva));
c01076bd:	8b 45 08             	mov    0x8(%ebp),%eax
c01076c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01076c3:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01076ca:	77 14                	ja     c01076e0 <kva2page+0x29>
c01076cc:	ff 75 f4             	pushl  -0xc(%ebp)
c01076cf:	68 d0 c6 10 c0       	push   $0xc010c6d0
c01076d4:	6a 6b                	push   $0x6b
c01076d6:	68 9b c6 10 c0       	push   $0xc010c69b
c01076db:	e8 0e a1 ff ff       	call   c01017ee <__panic>
c01076e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01076e3:	05 00 00 00 40       	add    $0x40000000,%eax
c01076e8:	83 ec 0c             	sub    $0xc,%esp
c01076eb:	50                   	push   %eax
c01076ec:	e8 3a ff ff ff       	call   c010762b <pa2page>
c01076f1:	83 c4 10             	add    $0x10,%esp
}
c01076f4:	c9                   	leave  
c01076f5:	c3                   	ret    

c01076f6 <__slob_get_free_pages>:
static slob_t *slobfree = &arena;
static bigblock_t *bigblocks;


static void* __slob_get_free_pages(gfp_t gfp, int order)
{
c01076f6:	f3 0f 1e fb          	endbr32 
c01076fa:	55                   	push   %ebp
c01076fb:	89 e5                	mov    %esp,%ebp
c01076fd:	83 ec 18             	sub    $0x18,%esp
  struct Page * page = alloc_pages(1 << order);
c0107700:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107703:	ba 01 00 00 00       	mov    $0x1,%edx
c0107708:	89 c1                	mov    %eax,%ecx
c010770a:	d3 e2                	shl    %cl,%edx
c010770c:	89 d0                	mov    %edx,%eax
c010770e:	83 ec 0c             	sub    $0xc,%esp
c0107711:	50                   	push   %eax
c0107712:	e8 5b d2 ff ff       	call   c0104972 <alloc_pages>
c0107717:	83 c4 10             	add    $0x10,%esp
c010771a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!page)
c010771d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107721:	75 07                	jne    c010772a <__slob_get_free_pages+0x34>
    return NULL;
c0107723:	b8 00 00 00 00       	mov    $0x0,%eax
c0107728:	eb 0e                	jmp    c0107738 <__slob_get_free_pages+0x42>
  return page2kva(page);
c010772a:	83 ec 0c             	sub    $0xc,%esp
c010772d:	ff 75 f4             	pushl  -0xc(%ebp)
c0107730:	e8 3d ff ff ff       	call   c0107672 <page2kva>
c0107735:	83 c4 10             	add    $0x10,%esp
}
c0107738:	c9                   	leave  
c0107739:	c3                   	ret    

c010773a <__slob_free_pages>:

#define __slob_get_free_page(gfp) __slob_get_free_pages(gfp, 0)

static inline void __slob_free_pages(unsigned long kva, int order)
{
c010773a:	55                   	push   %ebp
c010773b:	89 e5                	mov    %esp,%ebp
c010773d:	53                   	push   %ebx
c010773e:	83 ec 04             	sub    $0x4,%esp
  free_pages(kva2page(kva), 1 << order);
c0107741:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107744:	ba 01 00 00 00       	mov    $0x1,%edx
c0107749:	89 c1                	mov    %eax,%ecx
c010774b:	d3 e2                	shl    %cl,%edx
c010774d:	89 d0                	mov    %edx,%eax
c010774f:	89 c3                	mov    %eax,%ebx
c0107751:	8b 45 08             	mov    0x8(%ebp),%eax
c0107754:	83 ec 0c             	sub    $0xc,%esp
c0107757:	50                   	push   %eax
c0107758:	e8 5a ff ff ff       	call   c01076b7 <kva2page>
c010775d:	83 c4 10             	add    $0x10,%esp
c0107760:	83 ec 08             	sub    $0x8,%esp
c0107763:	53                   	push   %ebx
c0107764:	50                   	push   %eax
c0107765:	e8 78 d2 ff ff       	call   c01049e2 <free_pages>
c010776a:	83 c4 10             	add    $0x10,%esp
}
c010776d:	90                   	nop
c010776e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0107771:	c9                   	leave  
c0107772:	c3                   	ret    

c0107773 <slob_alloc>:

static void slob_free(void *b, int size);

static void *slob_alloc(size_t size, gfp_t gfp, int align)
{
c0107773:	f3 0f 1e fb          	endbr32 
c0107777:	55                   	push   %ebp
c0107778:	89 e5                	mov    %esp,%ebp
c010777a:	83 ec 28             	sub    $0x28,%esp
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
c010777d:	8b 45 08             	mov    0x8(%ebp),%eax
c0107780:	83 c0 08             	add    $0x8,%eax
c0107783:	3d ff 0f 00 00       	cmp    $0xfff,%eax
c0107788:	76 16                	jbe    c01077a0 <slob_alloc+0x2d>
c010778a:	68 f4 c6 10 c0       	push   $0xc010c6f4
c010778f:	68 13 c7 10 c0       	push   $0xc010c713
c0107794:	6a 64                	push   $0x64
c0107796:	68 28 c7 10 c0       	push   $0xc010c728
c010779b:	e8 4e a0 ff ff       	call   c01017ee <__panic>

	slob_t *prev, *cur, *aligned = 0;
c01077a0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	int delta = 0, units = SLOB_UNITS(size);
c01077a7:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c01077ae:	8b 45 08             	mov    0x8(%ebp),%eax
c01077b1:	83 c0 07             	add    $0x7,%eax
c01077b4:	c1 e8 03             	shr    $0x3,%eax
c01077b7:	89 45 e0             	mov    %eax,-0x20(%ebp)
	unsigned long flags;

	spin_lock_irqsave(&slob_lock, flags);
c01077ba:	e8 01 fe ff ff       	call   c01075c0 <__intr_save>
c01077bf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	prev = slobfree;
c01077c2:	a1 40 ba 12 c0       	mov    0xc012ba40,%eax
c01077c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
c01077ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01077cd:	8b 40 04             	mov    0x4(%eax),%eax
c01077d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if (align) {
c01077d3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01077d7:	74 21                	je     c01077fa <slob_alloc+0x87>
			aligned = (slob_t *)ALIGN((unsigned long)cur, align);
c01077d9:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01077dc:	8b 45 10             	mov    0x10(%ebp),%eax
c01077df:	01 d0                	add    %edx,%eax
c01077e1:	8d 50 ff             	lea    -0x1(%eax),%edx
c01077e4:	8b 45 10             	mov    0x10(%ebp),%eax
c01077e7:	f7 d8                	neg    %eax
c01077e9:	21 d0                	and    %edx,%eax
c01077eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
			delta = aligned - cur;
c01077ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01077f1:	2b 45 f0             	sub    -0x10(%ebp),%eax
c01077f4:	c1 f8 03             	sar    $0x3,%eax
c01077f7:	89 45 e8             	mov    %eax,-0x18(%ebp)
		}
		if (cur->units >= units + delta) { /* room enough? */
c01077fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01077fd:	8b 00                	mov    (%eax),%eax
c01077ff:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c0107802:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0107805:	01 ca                	add    %ecx,%edx
c0107807:	39 d0                	cmp    %edx,%eax
c0107809:	0f 8c b1 00 00 00    	jl     c01078c0 <slob_alloc+0x14d>
			if (delta) { /* need to fragment head to align? */
c010780f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0107813:	74 38                	je     c010784d <slob_alloc+0xda>
				aligned->units = cur->units - delta;
c0107815:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107818:	8b 00                	mov    (%eax),%eax
c010781a:	2b 45 e8             	sub    -0x18(%ebp),%eax
c010781d:	89 c2                	mov    %eax,%edx
c010781f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107822:	89 10                	mov    %edx,(%eax)
				aligned->next = cur->next;
c0107824:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107827:	8b 50 04             	mov    0x4(%eax),%edx
c010782a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010782d:	89 50 04             	mov    %edx,0x4(%eax)
				cur->next = aligned;
c0107830:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107833:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107836:	89 50 04             	mov    %edx,0x4(%eax)
				cur->units = delta;
c0107839:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010783c:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010783f:	89 10                	mov    %edx,(%eax)
				prev = cur;
c0107841:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107844:	89 45 f4             	mov    %eax,-0xc(%ebp)
				cur = aligned;
c0107847:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010784a:	89 45 f0             	mov    %eax,-0x10(%ebp)
			}

			if (cur->units == units) /* exact fit? */
c010784d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107850:	8b 00                	mov    (%eax),%eax
c0107852:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0107855:	75 0e                	jne    c0107865 <slob_alloc+0xf2>
				prev->next = cur->next; /* unlink */
c0107857:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010785a:	8b 50 04             	mov    0x4(%eax),%edx
c010785d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107860:	89 50 04             	mov    %edx,0x4(%eax)
c0107863:	eb 3c                	jmp    c01078a1 <slob_alloc+0x12e>
			else { /* fragment */
				prev->next = cur + units;
c0107865:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107868:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c010786f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107872:	01 c2                	add    %eax,%edx
c0107874:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107877:	89 50 04             	mov    %edx,0x4(%eax)
				prev->next->units = cur->units - units;
c010787a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010787d:	8b 10                	mov    (%eax),%edx
c010787f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107882:	8b 40 04             	mov    0x4(%eax),%eax
c0107885:	2b 55 e0             	sub    -0x20(%ebp),%edx
c0107888:	89 10                	mov    %edx,(%eax)
				prev->next->next = cur->next;
c010788a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010788d:	8b 40 04             	mov    0x4(%eax),%eax
c0107890:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0107893:	8b 52 04             	mov    0x4(%edx),%edx
c0107896:	89 50 04             	mov    %edx,0x4(%eax)
				cur->units = units;
c0107899:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010789c:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010789f:	89 10                	mov    %edx,(%eax)
			}

			slobfree = prev;
c01078a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01078a4:	a3 40 ba 12 c0       	mov    %eax,0xc012ba40
			spin_unlock_irqrestore(&slob_lock, flags);
c01078a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01078ac:	83 ec 0c             	sub    $0xc,%esp
c01078af:	50                   	push   %eax
c01078b0:	e8 35 fd ff ff       	call   c01075ea <__intr_restore>
c01078b5:	83 c4 10             	add    $0x10,%esp
			return cur;
c01078b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01078bb:	e9 80 00 00 00       	jmp    c0107940 <slob_alloc+0x1cd>
		}
		if (cur == slobfree) {
c01078c0:	a1 40 ba 12 c0       	mov    0xc012ba40,%eax
c01078c5:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01078c8:	75 62                	jne    c010792c <slob_alloc+0x1b9>
			spin_unlock_irqrestore(&slob_lock, flags);
c01078ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01078cd:	83 ec 0c             	sub    $0xc,%esp
c01078d0:	50                   	push   %eax
c01078d1:	e8 14 fd ff ff       	call   c01075ea <__intr_restore>
c01078d6:	83 c4 10             	add    $0x10,%esp

			if (size == PAGE_SIZE) /* trying to shrink arena? */
c01078d9:	81 7d 08 00 10 00 00 	cmpl   $0x1000,0x8(%ebp)
c01078e0:	75 07                	jne    c01078e9 <slob_alloc+0x176>
				return 0;
c01078e2:	b8 00 00 00 00       	mov    $0x0,%eax
c01078e7:	eb 57                	jmp    c0107940 <slob_alloc+0x1cd>

			cur = (slob_t *)__slob_get_free_page(gfp);
c01078e9:	83 ec 08             	sub    $0x8,%esp
c01078ec:	6a 00                	push   $0x0
c01078ee:	ff 75 0c             	pushl  0xc(%ebp)
c01078f1:	e8 00 fe ff ff       	call   c01076f6 <__slob_get_free_pages>
c01078f6:	83 c4 10             	add    $0x10,%esp
c01078f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
			if (!cur)
c01078fc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0107900:	75 07                	jne    c0107909 <slob_alloc+0x196>
				return 0;
c0107902:	b8 00 00 00 00       	mov    $0x0,%eax
c0107907:	eb 37                	jmp    c0107940 <slob_alloc+0x1cd>

			slob_free(cur, PAGE_SIZE);
c0107909:	83 ec 08             	sub    $0x8,%esp
c010790c:	68 00 10 00 00       	push   $0x1000
c0107911:	ff 75 f0             	pushl  -0x10(%ebp)
c0107914:	e8 29 00 00 00       	call   c0107942 <slob_free>
c0107919:	83 c4 10             	add    $0x10,%esp
			spin_lock_irqsave(&slob_lock, flags);
c010791c:	e8 9f fc ff ff       	call   c01075c0 <__intr_save>
c0107921:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			cur = slobfree;
c0107924:	a1 40 ba 12 c0       	mov    0xc012ba40,%eax
c0107929:	89 45 f0             	mov    %eax,-0x10(%ebp)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
c010792c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010792f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107932:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107935:	8b 40 04             	mov    0x4(%eax),%eax
c0107938:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if (align) {
c010793b:	e9 93 fe ff ff       	jmp    c01077d3 <slob_alloc+0x60>
		}
	}
}
c0107940:	c9                   	leave  
c0107941:	c3                   	ret    

c0107942 <slob_free>:

static void slob_free(void *block, int size)
{
c0107942:	f3 0f 1e fb          	endbr32 
c0107946:	55                   	push   %ebp
c0107947:	89 e5                	mov    %esp,%ebp
c0107949:	83 ec 18             	sub    $0x18,%esp
	slob_t *cur, *b = (slob_t *)block;
c010794c:	8b 45 08             	mov    0x8(%ebp),%eax
c010794f:	89 45 f0             	mov    %eax,-0x10(%ebp)
	unsigned long flags;

	if (!block)
c0107952:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0107956:	0f 84 05 01 00 00    	je     c0107a61 <slob_free+0x11f>
		return;

	if (size)
c010795c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0107960:	74 10                	je     c0107972 <slob_free+0x30>
		b->units = SLOB_UNITS(size);
c0107962:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107965:	83 c0 07             	add    $0x7,%eax
c0107968:	c1 e8 03             	shr    $0x3,%eax
c010796b:	89 c2                	mov    %eax,%edx
c010796d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107970:	89 10                	mov    %edx,(%eax)

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
c0107972:	e8 49 fc ff ff       	call   c01075c0 <__intr_save>
c0107977:	89 45 ec             	mov    %eax,-0x14(%ebp)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
c010797a:	a1 40 ba 12 c0       	mov    0xc012ba40,%eax
c010797f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107982:	eb 27                	jmp    c01079ab <slob_free+0x69>
		if (cur >= cur->next && (b > cur || b < cur->next))
c0107984:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107987:	8b 40 04             	mov    0x4(%eax),%eax
c010798a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010798d:	72 13                	jb     c01079a2 <slob_free+0x60>
c010798f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107992:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0107995:	77 27                	ja     c01079be <slob_free+0x7c>
c0107997:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010799a:	8b 40 04             	mov    0x4(%eax),%eax
c010799d:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01079a0:	72 1c                	jb     c01079be <slob_free+0x7c>
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
c01079a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01079a5:	8b 40 04             	mov    0x4(%eax),%eax
c01079a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01079ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01079ae:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01079b1:	76 d1                	jbe    c0107984 <slob_free+0x42>
c01079b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01079b6:	8b 40 04             	mov    0x4(%eax),%eax
c01079b9:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01079bc:	73 c6                	jae    c0107984 <slob_free+0x42>
			break;

	if (b + b->units == cur->next) {
c01079be:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01079c1:	8b 00                	mov    (%eax),%eax
c01079c3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01079ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01079cd:	01 c2                	add    %eax,%edx
c01079cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01079d2:	8b 40 04             	mov    0x4(%eax),%eax
c01079d5:	39 c2                	cmp    %eax,%edx
c01079d7:	75 25                	jne    c01079fe <slob_free+0xbc>
		b->units += cur->next->units;
c01079d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01079dc:	8b 10                	mov    (%eax),%edx
c01079de:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01079e1:	8b 40 04             	mov    0x4(%eax),%eax
c01079e4:	8b 00                	mov    (%eax),%eax
c01079e6:	01 c2                	add    %eax,%edx
c01079e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01079eb:	89 10                	mov    %edx,(%eax)
		b->next = cur->next->next;
c01079ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01079f0:	8b 40 04             	mov    0x4(%eax),%eax
c01079f3:	8b 50 04             	mov    0x4(%eax),%edx
c01079f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01079f9:	89 50 04             	mov    %edx,0x4(%eax)
c01079fc:	eb 0c                	jmp    c0107a0a <slob_free+0xc8>
	} else
		b->next = cur->next;
c01079fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107a01:	8b 50 04             	mov    0x4(%eax),%edx
c0107a04:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107a07:	89 50 04             	mov    %edx,0x4(%eax)

	if (cur + cur->units == b) {
c0107a0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107a0d:	8b 00                	mov    (%eax),%eax
c0107a0f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0107a16:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107a19:	01 d0                	add    %edx,%eax
c0107a1b:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0107a1e:	75 1f                	jne    c0107a3f <slob_free+0xfd>
		cur->units += b->units;
c0107a20:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107a23:	8b 10                	mov    (%eax),%edx
c0107a25:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107a28:	8b 00                	mov    (%eax),%eax
c0107a2a:	01 c2                	add    %eax,%edx
c0107a2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107a2f:	89 10                	mov    %edx,(%eax)
		cur->next = b->next;
c0107a31:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107a34:	8b 50 04             	mov    0x4(%eax),%edx
c0107a37:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107a3a:	89 50 04             	mov    %edx,0x4(%eax)
c0107a3d:	eb 09                	jmp    c0107a48 <slob_free+0x106>
	} else
		cur->next = b;
c0107a3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107a42:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0107a45:	89 50 04             	mov    %edx,0x4(%eax)

	slobfree = cur;
c0107a48:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107a4b:	a3 40 ba 12 c0       	mov    %eax,0xc012ba40

	spin_unlock_irqrestore(&slob_lock, flags);
c0107a50:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107a53:	83 ec 0c             	sub    $0xc,%esp
c0107a56:	50                   	push   %eax
c0107a57:	e8 8e fb ff ff       	call   c01075ea <__intr_restore>
c0107a5c:	83 c4 10             	add    $0x10,%esp
c0107a5f:	eb 01                	jmp    c0107a62 <slob_free+0x120>
		return;
c0107a61:	90                   	nop
}
c0107a62:	c9                   	leave  
c0107a63:	c3                   	ret    

c0107a64 <check_slab>:



void check_slab(void) {
c0107a64:	f3 0f 1e fb          	endbr32 
c0107a68:	55                   	push   %ebp
c0107a69:	89 e5                	mov    %esp,%ebp
c0107a6b:	83 ec 08             	sub    $0x8,%esp
  cprintf("check_slab() success\n");
c0107a6e:	83 ec 0c             	sub    $0xc,%esp
c0107a71:	68 3a c7 10 c0       	push   $0xc010c73a
c0107a76:	e8 37 88 ff ff       	call   c01002b2 <cprintf>
c0107a7b:	83 c4 10             	add    $0x10,%esp
}
c0107a7e:	90                   	nop
c0107a7f:	c9                   	leave  
c0107a80:	c3                   	ret    

c0107a81 <slab_init>:

void
slab_init(void) {
c0107a81:	f3 0f 1e fb          	endbr32 
c0107a85:	55                   	push   %ebp
c0107a86:	89 e5                	mov    %esp,%ebp
c0107a88:	83 ec 08             	sub    $0x8,%esp
  cprintf("use SLOB allocator\n");
c0107a8b:	83 ec 0c             	sub    $0xc,%esp
c0107a8e:	68 50 c7 10 c0       	push   $0xc010c750
c0107a93:	e8 1a 88 ff ff       	call   c01002b2 <cprintf>
c0107a98:	83 c4 10             	add    $0x10,%esp
  check_slab();
c0107a9b:	e8 c4 ff ff ff       	call   c0107a64 <check_slab>
}
c0107aa0:	90                   	nop
c0107aa1:	c9                   	leave  
c0107aa2:	c3                   	ret    

c0107aa3 <kmalloc_init>:

inline void 
kmalloc_init(void) {
c0107aa3:	f3 0f 1e fb          	endbr32 
c0107aa7:	55                   	push   %ebp
c0107aa8:	89 e5                	mov    %esp,%ebp
c0107aaa:	83 ec 08             	sub    $0x8,%esp
    slab_init();
c0107aad:	e8 cf ff ff ff       	call   c0107a81 <slab_init>
    cprintf("kmalloc_init() succeeded!\n");
c0107ab2:	83 ec 0c             	sub    $0xc,%esp
c0107ab5:	68 64 c7 10 c0       	push   $0xc010c764
c0107aba:	e8 f3 87 ff ff       	call   c01002b2 <cprintf>
c0107abf:	83 c4 10             	add    $0x10,%esp
}
c0107ac2:	90                   	nop
c0107ac3:	c9                   	leave  
c0107ac4:	c3                   	ret    

c0107ac5 <slab_allocated>:

size_t
slab_allocated(void) {
c0107ac5:	f3 0f 1e fb          	endbr32 
c0107ac9:	55                   	push   %ebp
c0107aca:	89 e5                	mov    %esp,%ebp
  return 0;
c0107acc:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107ad1:	5d                   	pop    %ebp
c0107ad2:	c3                   	ret    

c0107ad3 <kallocated>:

size_t
kallocated(void) {
c0107ad3:	f3 0f 1e fb          	endbr32 
c0107ad7:	55                   	push   %ebp
c0107ad8:	89 e5                	mov    %esp,%ebp
   return slab_allocated();
c0107ada:	e8 e6 ff ff ff       	call   c0107ac5 <slab_allocated>
}
c0107adf:	5d                   	pop    %ebp
c0107ae0:	c3                   	ret    

c0107ae1 <find_order>:

static int find_order(int size)
{
c0107ae1:	f3 0f 1e fb          	endbr32 
c0107ae5:	55                   	push   %ebp
c0107ae6:	89 e5                	mov    %esp,%ebp
c0107ae8:	83 ec 10             	sub    $0x10,%esp
	int order = 0;
c0107aeb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	for ( ; size > 4096 ; size >>=1)
c0107af2:	eb 07                	jmp    c0107afb <find_order+0x1a>
		order++;
c0107af4:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
	for ( ; size > 4096 ; size >>=1)
c0107af8:	d1 7d 08             	sarl   0x8(%ebp)
c0107afb:	81 7d 08 00 10 00 00 	cmpl   $0x1000,0x8(%ebp)
c0107b02:	7f f0                	jg     c0107af4 <find_order+0x13>
	return order;
c0107b04:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0107b07:	c9                   	leave  
c0107b08:	c3                   	ret    

c0107b09 <__kmalloc>:

static void *__kmalloc(size_t size, gfp_t gfp)
{
c0107b09:	f3 0f 1e fb          	endbr32 
c0107b0d:	55                   	push   %ebp
c0107b0e:	89 e5                	mov    %esp,%ebp
c0107b10:	83 ec 18             	sub    $0x18,%esp
	slob_t *m;
	bigblock_t *bb;
	unsigned long flags;

	if (size < PAGE_SIZE - SLOB_UNIT) {
c0107b13:	81 7d 08 f7 0f 00 00 	cmpl   $0xff7,0x8(%ebp)
c0107b1a:	77 35                	ja     c0107b51 <__kmalloc+0x48>
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
c0107b1c:	8b 45 08             	mov    0x8(%ebp),%eax
c0107b1f:	83 c0 08             	add    $0x8,%eax
c0107b22:	83 ec 04             	sub    $0x4,%esp
c0107b25:	6a 00                	push   $0x0
c0107b27:	ff 75 0c             	pushl  0xc(%ebp)
c0107b2a:	50                   	push   %eax
c0107b2b:	e8 43 fc ff ff       	call   c0107773 <slob_alloc>
c0107b30:	83 c4 10             	add    $0x10,%esp
c0107b33:	89 45 ec             	mov    %eax,-0x14(%ebp)
		return m ? (void *)(m + 1) : 0;
c0107b36:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0107b3a:	74 0b                	je     c0107b47 <__kmalloc+0x3e>
c0107b3c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107b3f:	83 c0 08             	add    $0x8,%eax
c0107b42:	e9 af 00 00 00       	jmp    c0107bf6 <__kmalloc+0xed>
c0107b47:	b8 00 00 00 00       	mov    $0x0,%eax
c0107b4c:	e9 a5 00 00 00       	jmp    c0107bf6 <__kmalloc+0xed>
	}

	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
c0107b51:	83 ec 04             	sub    $0x4,%esp
c0107b54:	6a 00                	push   $0x0
c0107b56:	ff 75 0c             	pushl  0xc(%ebp)
c0107b59:	6a 0c                	push   $0xc
c0107b5b:	e8 13 fc ff ff       	call   c0107773 <slob_alloc>
c0107b60:	83 c4 10             	add    $0x10,%esp
c0107b63:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (!bb)
c0107b66:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107b6a:	75 0a                	jne    c0107b76 <__kmalloc+0x6d>
		return 0;
c0107b6c:	b8 00 00 00 00       	mov    $0x0,%eax
c0107b71:	e9 80 00 00 00       	jmp    c0107bf6 <__kmalloc+0xed>

	bb->order = find_order(size);
c0107b76:	8b 45 08             	mov    0x8(%ebp),%eax
c0107b79:	83 ec 0c             	sub    $0xc,%esp
c0107b7c:	50                   	push   %eax
c0107b7d:	e8 5f ff ff ff       	call   c0107ae1 <find_order>
c0107b82:	83 c4 10             	add    $0x10,%esp
c0107b85:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107b88:	89 02                	mov    %eax,(%edx)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
c0107b8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107b8d:	8b 00                	mov    (%eax),%eax
c0107b8f:	83 ec 08             	sub    $0x8,%esp
c0107b92:	50                   	push   %eax
c0107b93:	ff 75 0c             	pushl  0xc(%ebp)
c0107b96:	e8 5b fb ff ff       	call   c01076f6 <__slob_get_free_pages>
c0107b9b:	83 c4 10             	add    $0x10,%esp
c0107b9e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107ba1:	89 42 04             	mov    %eax,0x4(%edx)

	if (bb->pages) {
c0107ba4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107ba7:	8b 40 04             	mov    0x4(%eax),%eax
c0107baa:	85 c0                	test   %eax,%eax
c0107bac:	74 33                	je     c0107be1 <__kmalloc+0xd8>
		spin_lock_irqsave(&block_lock, flags);
c0107bae:	e8 0d fa ff ff       	call   c01075c0 <__intr_save>
c0107bb3:	89 45 f0             	mov    %eax,-0x10(%ebp)
		bb->next = bigblocks;
c0107bb6:	8b 15 1c f0 12 c0    	mov    0xc012f01c,%edx
c0107bbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107bbf:	89 50 08             	mov    %edx,0x8(%eax)
		bigblocks = bb;
c0107bc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107bc5:	a3 1c f0 12 c0       	mov    %eax,0xc012f01c
		spin_unlock_irqrestore(&block_lock, flags);
c0107bca:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107bcd:	83 ec 0c             	sub    $0xc,%esp
c0107bd0:	50                   	push   %eax
c0107bd1:	e8 14 fa ff ff       	call   c01075ea <__intr_restore>
c0107bd6:	83 c4 10             	add    $0x10,%esp
		return bb->pages;
c0107bd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107bdc:	8b 40 04             	mov    0x4(%eax),%eax
c0107bdf:	eb 15                	jmp    c0107bf6 <__kmalloc+0xed>
	}

	slob_free(bb, sizeof(bigblock_t));
c0107be1:	83 ec 08             	sub    $0x8,%esp
c0107be4:	6a 0c                	push   $0xc
c0107be6:	ff 75 f4             	pushl  -0xc(%ebp)
c0107be9:	e8 54 fd ff ff       	call   c0107942 <slob_free>
c0107bee:	83 c4 10             	add    $0x10,%esp
	return 0;
c0107bf1:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107bf6:	c9                   	leave  
c0107bf7:	c3                   	ret    

c0107bf8 <kmalloc>:

void *
kmalloc(size_t size)
{
c0107bf8:	f3 0f 1e fb          	endbr32 
c0107bfc:	55                   	push   %ebp
c0107bfd:	89 e5                	mov    %esp,%ebp
c0107bff:	83 ec 08             	sub    $0x8,%esp
  return __kmalloc(size, 0);
c0107c02:	83 ec 08             	sub    $0x8,%esp
c0107c05:	6a 00                	push   $0x0
c0107c07:	ff 75 08             	pushl  0x8(%ebp)
c0107c0a:	e8 fa fe ff ff       	call   c0107b09 <__kmalloc>
c0107c0f:	83 c4 10             	add    $0x10,%esp
}
c0107c12:	c9                   	leave  
c0107c13:	c3                   	ret    

c0107c14 <kfree>:


void kfree(void *block)
{
c0107c14:	f3 0f 1e fb          	endbr32 
c0107c18:	55                   	push   %ebp
c0107c19:	89 e5                	mov    %esp,%ebp
c0107c1b:	83 ec 18             	sub    $0x18,%esp
	bigblock_t *bb, **last = &bigblocks;
c0107c1e:	c7 45 f0 1c f0 12 c0 	movl   $0xc012f01c,-0x10(%ebp)
	unsigned long flags;

	if (!block)
c0107c25:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0107c29:	0f 84 ab 00 00 00    	je     c0107cda <kfree+0xc6>
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
c0107c2f:	8b 45 08             	mov    0x8(%ebp),%eax
c0107c32:	25 ff 0f 00 00       	and    $0xfff,%eax
c0107c37:	85 c0                	test   %eax,%eax
c0107c39:	0f 85 85 00 00 00    	jne    c0107cc4 <kfree+0xb0>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
c0107c3f:	e8 7c f9 ff ff       	call   c01075c0 <__intr_save>
c0107c44:	89 45 ec             	mov    %eax,-0x14(%ebp)
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
c0107c47:	a1 1c f0 12 c0       	mov    0xc012f01c,%eax
c0107c4c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107c4f:	eb 5e                	jmp    c0107caf <kfree+0x9b>
			if (bb->pages == block) {
c0107c51:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107c54:	8b 40 04             	mov    0x4(%eax),%eax
c0107c57:	39 45 08             	cmp    %eax,0x8(%ebp)
c0107c5a:	75 41                	jne    c0107c9d <kfree+0x89>
				*last = bb->next;
c0107c5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107c5f:	8b 50 08             	mov    0x8(%eax),%edx
c0107c62:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107c65:	89 10                	mov    %edx,(%eax)
				spin_unlock_irqrestore(&block_lock, flags);
c0107c67:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107c6a:	83 ec 0c             	sub    $0xc,%esp
c0107c6d:	50                   	push   %eax
c0107c6e:	e8 77 f9 ff ff       	call   c01075ea <__intr_restore>
c0107c73:	83 c4 10             	add    $0x10,%esp
				__slob_free_pages((unsigned long)block, bb->order);
c0107c76:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107c79:	8b 10                	mov    (%eax),%edx
c0107c7b:	8b 45 08             	mov    0x8(%ebp),%eax
c0107c7e:	83 ec 08             	sub    $0x8,%esp
c0107c81:	52                   	push   %edx
c0107c82:	50                   	push   %eax
c0107c83:	e8 b2 fa ff ff       	call   c010773a <__slob_free_pages>
c0107c88:	83 c4 10             	add    $0x10,%esp
				slob_free(bb, sizeof(bigblock_t));
c0107c8b:	83 ec 08             	sub    $0x8,%esp
c0107c8e:	6a 0c                	push   $0xc
c0107c90:	ff 75 f4             	pushl  -0xc(%ebp)
c0107c93:	e8 aa fc ff ff       	call   c0107942 <slob_free>
c0107c98:	83 c4 10             	add    $0x10,%esp
				return;
c0107c9b:	eb 3e                	jmp    c0107cdb <kfree+0xc7>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
c0107c9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107ca0:	83 c0 08             	add    $0x8,%eax
c0107ca3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107ca6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107ca9:	8b 40 08             	mov    0x8(%eax),%eax
c0107cac:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107caf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107cb3:	75 9c                	jne    c0107c51 <kfree+0x3d>
			}
		}
		spin_unlock_irqrestore(&block_lock, flags);
c0107cb5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107cb8:	83 ec 0c             	sub    $0xc,%esp
c0107cbb:	50                   	push   %eax
c0107cbc:	e8 29 f9 ff ff       	call   c01075ea <__intr_restore>
c0107cc1:	83 c4 10             	add    $0x10,%esp
	}

	slob_free((slob_t *)block - 1, 0);
c0107cc4:	8b 45 08             	mov    0x8(%ebp),%eax
c0107cc7:	83 e8 08             	sub    $0x8,%eax
c0107cca:	83 ec 08             	sub    $0x8,%esp
c0107ccd:	6a 00                	push   $0x0
c0107ccf:	50                   	push   %eax
c0107cd0:	e8 6d fc ff ff       	call   c0107942 <slob_free>
c0107cd5:	83 c4 10             	add    $0x10,%esp
	return;
c0107cd8:	eb 01                	jmp    c0107cdb <kfree+0xc7>
		return;
c0107cda:	90                   	nop
}
c0107cdb:	c9                   	leave  
c0107cdc:	c3                   	ret    

c0107cdd <ksize>:


unsigned int ksize(const void *block)
{
c0107cdd:	f3 0f 1e fb          	endbr32 
c0107ce1:	55                   	push   %ebp
c0107ce2:	89 e5                	mov    %esp,%ebp
c0107ce4:	83 ec 18             	sub    $0x18,%esp
	bigblock_t *bb;
	unsigned long flags;

	if (!block)
c0107ce7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0107ceb:	75 07                	jne    c0107cf4 <ksize+0x17>
		return 0;
c0107ced:	b8 00 00 00 00       	mov    $0x0,%eax
c0107cf2:	eb 73                	jmp    c0107d67 <ksize+0x8a>

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
c0107cf4:	8b 45 08             	mov    0x8(%ebp),%eax
c0107cf7:	25 ff 0f 00 00       	and    $0xfff,%eax
c0107cfc:	85 c0                	test   %eax,%eax
c0107cfe:	75 5c                	jne    c0107d5c <ksize+0x7f>
		spin_lock_irqsave(&block_lock, flags);
c0107d00:	e8 bb f8 ff ff       	call   c01075c0 <__intr_save>
c0107d05:	89 45 f0             	mov    %eax,-0x10(%ebp)
		for (bb = bigblocks; bb; bb = bb->next)
c0107d08:	a1 1c f0 12 c0       	mov    0xc012f01c,%eax
c0107d0d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107d10:	eb 35                	jmp    c0107d47 <ksize+0x6a>
			if (bb->pages == block) {
c0107d12:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107d15:	8b 40 04             	mov    0x4(%eax),%eax
c0107d18:	39 45 08             	cmp    %eax,0x8(%ebp)
c0107d1b:	75 21                	jne    c0107d3e <ksize+0x61>
				spin_unlock_irqrestore(&slob_lock, flags);
c0107d1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107d20:	83 ec 0c             	sub    $0xc,%esp
c0107d23:	50                   	push   %eax
c0107d24:	e8 c1 f8 ff ff       	call   c01075ea <__intr_restore>
c0107d29:	83 c4 10             	add    $0x10,%esp
				return PAGE_SIZE << bb->order;
c0107d2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107d2f:	8b 00                	mov    (%eax),%eax
c0107d31:	ba 00 10 00 00       	mov    $0x1000,%edx
c0107d36:	89 c1                	mov    %eax,%ecx
c0107d38:	d3 e2                	shl    %cl,%edx
c0107d3a:	89 d0                	mov    %edx,%eax
c0107d3c:	eb 29                	jmp    c0107d67 <ksize+0x8a>
		for (bb = bigblocks; bb; bb = bb->next)
c0107d3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107d41:	8b 40 08             	mov    0x8(%eax),%eax
c0107d44:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107d47:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107d4b:	75 c5                	jne    c0107d12 <ksize+0x35>
			}
		spin_unlock_irqrestore(&block_lock, flags);
c0107d4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107d50:	83 ec 0c             	sub    $0xc,%esp
c0107d53:	50                   	push   %eax
c0107d54:	e8 91 f8 ff ff       	call   c01075ea <__intr_restore>
c0107d59:	83 c4 10             	add    $0x10,%esp
	}

	return ((slob_t *)block - 1)->units * SLOB_UNIT;
c0107d5c:	8b 45 08             	mov    0x8(%ebp),%eax
c0107d5f:	83 e8 08             	sub    $0x8,%eax
c0107d62:	8b 00                	mov    (%eax),%eax
c0107d64:	c1 e0 03             	shl    $0x3,%eax
}
c0107d67:	c9                   	leave  
c0107d68:	c3                   	ret    

c0107d69 <_fifo_init_mm>:
 * (2) _fifo_init_mm: init pra_list_head and let  mm->sm_priv point to the addr of pra_list_head.
 *              Now, From the memory control struct mm_struct, we can access FIFO PRA
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
c0107d69:	f3 0f 1e fb          	endbr32 
c0107d6d:	55                   	push   %ebp
c0107d6e:	89 e5                	mov    %esp,%ebp
c0107d70:	83 ec 10             	sub    $0x10,%esp
c0107d73:	c7 45 fc 44 11 13 c0 	movl   $0xc0131144,-0x4(%ebp)
    elm->prev = elm->next = elm;
c0107d7a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107d7d:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0107d80:	89 50 04             	mov    %edx,0x4(%eax)
c0107d83:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107d86:	8b 50 04             	mov    0x4(%eax),%edx
c0107d89:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107d8c:	89 10                	mov    %edx,(%eax)
}
c0107d8e:	90                   	nop
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
c0107d8f:	8b 45 08             	mov    0x8(%ebp),%eax
c0107d92:	c7 40 14 44 11 13 c0 	movl   $0xc0131144,0x14(%eax)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
c0107d99:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107d9e:	c9                   	leave  
c0107d9f:	c3                   	ret    

c0107da0 <_fifo_map_swappable>:
/*
 * (3)_fifo_map_swappable: According FIFO PRA, we should link the most recent arrival page at the back of pra_list_head qeueue
 */
static int
_fifo_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c0107da0:	f3 0f 1e fb          	endbr32 
c0107da4:	55                   	push   %ebp
c0107da5:	89 e5                	mov    %esp,%ebp
c0107da7:	83 ec 38             	sub    $0x38,%esp
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
c0107daa:	8b 45 08             	mov    0x8(%ebp),%eax
c0107dad:	8b 40 14             	mov    0x14(%eax),%eax
c0107db0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    list_entry_t *entry=&(page->pra_page_link);
c0107db3:	8b 45 10             	mov    0x10(%ebp),%eax
c0107db6:	83 c0 18             	add    $0x18,%eax
c0107db9:	89 45 f0             	mov    %eax,-0x10(%ebp)
 
    assert(entry != NULL && head != NULL);
c0107dbc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0107dc0:	74 06                	je     c0107dc8 <_fifo_map_swappable+0x28>
c0107dc2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107dc6:	75 16                	jne    c0107dde <_fifo_map_swappable+0x3e>
c0107dc8:	68 80 c7 10 c0       	push   $0xc010c780
c0107dcd:	68 9e c7 10 c0       	push   $0xc010c79e
c0107dd2:	6a 32                	push   $0x32
c0107dd4:	68 b3 c7 10 c0       	push   $0xc010c7b3
c0107dd9:	e8 10 9a ff ff       	call   c01017ee <__panic>
c0107dde:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107de1:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107de4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107de7:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0107dea:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107ded:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0107df0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107df3:	89 45 e0             	mov    %eax,-0x20(%ebp)
    __list_add(elm, listelm, listelm->next);
c0107df6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107df9:	8b 40 04             	mov    0x4(%eax),%eax
c0107dfc:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0107dff:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0107e02:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107e05:	89 55 d8             	mov    %edx,-0x28(%ebp)
c0107e08:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    prev->next = next->prev = elm;
c0107e0b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0107e0e:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107e11:	89 10                	mov    %edx,(%eax)
c0107e13:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0107e16:	8b 10                	mov    (%eax),%edx
c0107e18:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0107e1b:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0107e1e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107e21:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0107e24:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0107e27:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107e2a:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0107e2d:	89 10                	mov    %edx,(%eax)
}
c0107e2f:	90                   	nop
}
c0107e30:	90                   	nop
}
c0107e31:	90                   	nop
    //record the page access situlation
    /*LAB3 EXERCISE 2: YOUR CODE*/ 
    //(1)link the most recent arrival page at the back of the pra_list_head qeueue.
    list_add(head, entry);
    return 0;
c0107e32:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107e37:	c9                   	leave  
c0107e38:	c3                   	ret    

c0107e39 <_fifo_swap_out_victim>:
 *  (4)_fifo_swap_out_victim: According FIFO PRA, we should unlink the  earliest arrival page in front of pra_list_head qeueue,
 *                            then assign the value of *ptr_page to the addr of this page.
 */
static int
_fifo_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
c0107e39:	f3 0f 1e fb          	endbr32 
c0107e3d:	55                   	push   %ebp
c0107e3e:	89 e5                	mov    %esp,%ebp
c0107e40:	83 ec 28             	sub    $0x28,%esp
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
c0107e43:	8b 45 08             	mov    0x8(%ebp),%eax
c0107e46:	8b 40 14             	mov    0x14(%eax),%eax
c0107e49:	89 45 f4             	mov    %eax,-0xc(%ebp)
         assert(head != NULL);
c0107e4c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107e50:	75 16                	jne    c0107e68 <_fifo_swap_out_victim+0x2f>
c0107e52:	68 c7 c7 10 c0       	push   $0xc010c7c7
c0107e57:	68 9e c7 10 c0       	push   $0xc010c79e
c0107e5c:	6a 41                	push   $0x41
c0107e5e:	68 b3 c7 10 c0       	push   $0xc010c7b3
c0107e63:	e8 86 99 ff ff       	call   c01017ee <__panic>
     assert(in_tick==0);
c0107e68:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0107e6c:	74 16                	je     c0107e84 <_fifo_swap_out_victim+0x4b>
c0107e6e:	68 d4 c7 10 c0       	push   $0xc010c7d4
c0107e73:	68 9e c7 10 c0       	push   $0xc010c79e
c0107e78:	6a 42                	push   $0x42
c0107e7a:	68 b3 c7 10 c0       	push   $0xc010c7b3
c0107e7f:	e8 6a 99 ff ff       	call   c01017ee <__panic>
     /* Select the victim */
     /*LAB3 EXERCISE 2: YOUR CODE*/ 
     //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
     //(2)  assign the value of *ptr_page to the addr of this page
     /* Select the tail */
     list_entry_t *le = head->prev;
c0107e84:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107e87:	8b 00                	mov    (%eax),%eax
c0107e89:	89 45 f0             	mov    %eax,-0x10(%ebp)
     assert(head!=le);
c0107e8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107e8f:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0107e92:	75 16                	jne    c0107eaa <_fifo_swap_out_victim+0x71>
c0107e94:	68 df c7 10 c0       	push   $0xc010c7df
c0107e99:	68 9e c7 10 c0       	push   $0xc010c79e
c0107e9e:	6a 49                	push   $0x49
c0107ea0:	68 b3 c7 10 c0       	push   $0xc010c7b3
c0107ea5:	e8 44 99 ff ff       	call   c01017ee <__panic>
     struct Page *p = le2page(le, pra_page_link);
c0107eaa:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107ead:	83 e8 18             	sub    $0x18,%eax
c0107eb0:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107eb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107eb6:	89 45 e8             	mov    %eax,-0x18(%ebp)
    __list_del(listelm->prev, listelm->next);
c0107eb9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107ebc:	8b 40 04             	mov    0x4(%eax),%eax
c0107ebf:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0107ec2:	8b 12                	mov    (%edx),%edx
c0107ec4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0107ec7:	89 45 e0             	mov    %eax,-0x20(%ebp)
    prev->next = next;
c0107eca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107ecd:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0107ed0:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0107ed3:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107ed6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107ed9:	89 10                	mov    %edx,(%eax)
}
c0107edb:	90                   	nop
}
c0107edc:	90                   	nop
     list_del(le);
     assert(p !=NULL);
c0107edd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0107ee1:	75 16                	jne    c0107ef9 <_fifo_swap_out_victim+0xc0>
c0107ee3:	68 e8 c7 10 c0       	push   $0xc010c7e8
c0107ee8:	68 9e c7 10 c0       	push   $0xc010c79e
c0107eed:	6a 4c                	push   $0x4c
c0107eef:	68 b3 c7 10 c0       	push   $0xc010c7b3
c0107ef4:	e8 f5 98 ff ff       	call   c01017ee <__panic>
     *ptr_page = p;
c0107ef9:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107efc:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107eff:	89 10                	mov    %edx,(%eax)
     return 0;
c0107f01:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107f06:	c9                   	leave  
c0107f07:	c3                   	ret    

c0107f08 <_fifo_check_swap>:

static int
_fifo_check_swap(void) {
c0107f08:	f3 0f 1e fb          	endbr32 
c0107f0c:	55                   	push   %ebp
c0107f0d:	89 e5                	mov    %esp,%ebp
c0107f0f:	83 ec 08             	sub    $0x8,%esp
    cprintf("write Virt Page c in fifo_check_swap\n");
c0107f12:	83 ec 0c             	sub    $0xc,%esp
c0107f15:	68 f4 c7 10 c0       	push   $0xc010c7f4
c0107f1a:	e8 93 83 ff ff       	call   c01002b2 <cprintf>
c0107f1f:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x3000 = 0x0c;
c0107f22:	b8 00 30 00 00       	mov    $0x3000,%eax
c0107f27:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==4);
c0107f2a:	a1 0c f0 12 c0       	mov    0xc012f00c,%eax
c0107f2f:	83 f8 04             	cmp    $0x4,%eax
c0107f32:	74 16                	je     c0107f4a <_fifo_check_swap+0x42>
c0107f34:	68 1a c8 10 c0       	push   $0xc010c81a
c0107f39:	68 9e c7 10 c0       	push   $0xc010c79e
c0107f3e:	6a 55                	push   $0x55
c0107f40:	68 b3 c7 10 c0       	push   $0xc010c7b3
c0107f45:	e8 a4 98 ff ff       	call   c01017ee <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0107f4a:	83 ec 0c             	sub    $0xc,%esp
c0107f4d:	68 2c c8 10 c0       	push   $0xc010c82c
c0107f52:	e8 5b 83 ff ff       	call   c01002b2 <cprintf>
c0107f57:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x1000 = 0x0a;
c0107f5a:	b8 00 10 00 00       	mov    $0x1000,%eax
c0107f5f:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==4);
c0107f62:	a1 0c f0 12 c0       	mov    0xc012f00c,%eax
c0107f67:	83 f8 04             	cmp    $0x4,%eax
c0107f6a:	74 16                	je     c0107f82 <_fifo_check_swap+0x7a>
c0107f6c:	68 1a c8 10 c0       	push   $0xc010c81a
c0107f71:	68 9e c7 10 c0       	push   $0xc010c79e
c0107f76:	6a 58                	push   $0x58
c0107f78:	68 b3 c7 10 c0       	push   $0xc010c7b3
c0107f7d:	e8 6c 98 ff ff       	call   c01017ee <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c0107f82:	83 ec 0c             	sub    $0xc,%esp
c0107f85:	68 54 c8 10 c0       	push   $0xc010c854
c0107f8a:	e8 23 83 ff ff       	call   c01002b2 <cprintf>
c0107f8f:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x4000 = 0x0d;
c0107f92:	b8 00 40 00 00       	mov    $0x4000,%eax
c0107f97:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==4);
c0107f9a:	a1 0c f0 12 c0       	mov    0xc012f00c,%eax
c0107f9f:	83 f8 04             	cmp    $0x4,%eax
c0107fa2:	74 16                	je     c0107fba <_fifo_check_swap+0xb2>
c0107fa4:	68 1a c8 10 c0       	push   $0xc010c81a
c0107fa9:	68 9e c7 10 c0       	push   $0xc010c79e
c0107fae:	6a 5b                	push   $0x5b
c0107fb0:	68 b3 c7 10 c0       	push   $0xc010c7b3
c0107fb5:	e8 34 98 ff ff       	call   c01017ee <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0107fba:	83 ec 0c             	sub    $0xc,%esp
c0107fbd:	68 7c c8 10 c0       	push   $0xc010c87c
c0107fc2:	e8 eb 82 ff ff       	call   c01002b2 <cprintf>
c0107fc7:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x2000 = 0x0b;
c0107fca:	b8 00 20 00 00       	mov    $0x2000,%eax
c0107fcf:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==4);
c0107fd2:	a1 0c f0 12 c0       	mov    0xc012f00c,%eax
c0107fd7:	83 f8 04             	cmp    $0x4,%eax
c0107fda:	74 16                	je     c0107ff2 <_fifo_check_swap+0xea>
c0107fdc:	68 1a c8 10 c0       	push   $0xc010c81a
c0107fe1:	68 9e c7 10 c0       	push   $0xc010c79e
c0107fe6:	6a 5e                	push   $0x5e
c0107fe8:	68 b3 c7 10 c0       	push   $0xc010c7b3
c0107fed:	e8 fc 97 ff ff       	call   c01017ee <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c0107ff2:	83 ec 0c             	sub    $0xc,%esp
c0107ff5:	68 a4 c8 10 c0       	push   $0xc010c8a4
c0107ffa:	e8 b3 82 ff ff       	call   c01002b2 <cprintf>
c0107fff:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x5000 = 0x0e;
c0108002:	b8 00 50 00 00       	mov    $0x5000,%eax
c0108007:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==5);
c010800a:	a1 0c f0 12 c0       	mov    0xc012f00c,%eax
c010800f:	83 f8 05             	cmp    $0x5,%eax
c0108012:	74 16                	je     c010802a <_fifo_check_swap+0x122>
c0108014:	68 ca c8 10 c0       	push   $0xc010c8ca
c0108019:	68 9e c7 10 c0       	push   $0xc010c79e
c010801e:	6a 61                	push   $0x61
c0108020:	68 b3 c7 10 c0       	push   $0xc010c7b3
c0108025:	e8 c4 97 ff ff       	call   c01017ee <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c010802a:	83 ec 0c             	sub    $0xc,%esp
c010802d:	68 7c c8 10 c0       	push   $0xc010c87c
c0108032:	e8 7b 82 ff ff       	call   c01002b2 <cprintf>
c0108037:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x2000 = 0x0b;
c010803a:	b8 00 20 00 00       	mov    $0x2000,%eax
c010803f:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==5);
c0108042:	a1 0c f0 12 c0       	mov    0xc012f00c,%eax
c0108047:	83 f8 05             	cmp    $0x5,%eax
c010804a:	74 16                	je     c0108062 <_fifo_check_swap+0x15a>
c010804c:	68 ca c8 10 c0       	push   $0xc010c8ca
c0108051:	68 9e c7 10 c0       	push   $0xc010c79e
c0108056:	6a 64                	push   $0x64
c0108058:	68 b3 c7 10 c0       	push   $0xc010c7b3
c010805d:	e8 8c 97 ff ff       	call   c01017ee <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0108062:	83 ec 0c             	sub    $0xc,%esp
c0108065:	68 2c c8 10 c0       	push   $0xc010c82c
c010806a:	e8 43 82 ff ff       	call   c01002b2 <cprintf>
c010806f:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x1000 = 0x0a;
c0108072:	b8 00 10 00 00       	mov    $0x1000,%eax
c0108077:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==6);
c010807a:	a1 0c f0 12 c0       	mov    0xc012f00c,%eax
c010807f:	83 f8 06             	cmp    $0x6,%eax
c0108082:	74 16                	je     c010809a <_fifo_check_swap+0x192>
c0108084:	68 d9 c8 10 c0       	push   $0xc010c8d9
c0108089:	68 9e c7 10 c0       	push   $0xc010c79e
c010808e:	6a 67                	push   $0x67
c0108090:	68 b3 c7 10 c0       	push   $0xc010c7b3
c0108095:	e8 54 97 ff ff       	call   c01017ee <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c010809a:	83 ec 0c             	sub    $0xc,%esp
c010809d:	68 7c c8 10 c0       	push   $0xc010c87c
c01080a2:	e8 0b 82 ff ff       	call   c01002b2 <cprintf>
c01080a7:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x2000 = 0x0b;
c01080aa:	b8 00 20 00 00       	mov    $0x2000,%eax
c01080af:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==7);
c01080b2:	a1 0c f0 12 c0       	mov    0xc012f00c,%eax
c01080b7:	83 f8 07             	cmp    $0x7,%eax
c01080ba:	74 16                	je     c01080d2 <_fifo_check_swap+0x1ca>
c01080bc:	68 e8 c8 10 c0       	push   $0xc010c8e8
c01080c1:	68 9e c7 10 c0       	push   $0xc010c79e
c01080c6:	6a 6a                	push   $0x6a
c01080c8:	68 b3 c7 10 c0       	push   $0xc010c7b3
c01080cd:	e8 1c 97 ff ff       	call   c01017ee <__panic>
    cprintf("write Virt Page c in fifo_check_swap\n");
c01080d2:	83 ec 0c             	sub    $0xc,%esp
c01080d5:	68 f4 c7 10 c0       	push   $0xc010c7f4
c01080da:	e8 d3 81 ff ff       	call   c01002b2 <cprintf>
c01080df:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x3000 = 0x0c;
c01080e2:	b8 00 30 00 00       	mov    $0x3000,%eax
c01080e7:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==8);
c01080ea:	a1 0c f0 12 c0       	mov    0xc012f00c,%eax
c01080ef:	83 f8 08             	cmp    $0x8,%eax
c01080f2:	74 16                	je     c010810a <_fifo_check_swap+0x202>
c01080f4:	68 f7 c8 10 c0       	push   $0xc010c8f7
c01080f9:	68 9e c7 10 c0       	push   $0xc010c79e
c01080fe:	6a 6d                	push   $0x6d
c0108100:	68 b3 c7 10 c0       	push   $0xc010c7b3
c0108105:	e8 e4 96 ff ff       	call   c01017ee <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c010810a:	83 ec 0c             	sub    $0xc,%esp
c010810d:	68 54 c8 10 c0       	push   $0xc010c854
c0108112:	e8 9b 81 ff ff       	call   c01002b2 <cprintf>
c0108117:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x4000 = 0x0d;
c010811a:	b8 00 40 00 00       	mov    $0x4000,%eax
c010811f:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==9);
c0108122:	a1 0c f0 12 c0       	mov    0xc012f00c,%eax
c0108127:	83 f8 09             	cmp    $0x9,%eax
c010812a:	74 16                	je     c0108142 <_fifo_check_swap+0x23a>
c010812c:	68 06 c9 10 c0       	push   $0xc010c906
c0108131:	68 9e c7 10 c0       	push   $0xc010c79e
c0108136:	6a 70                	push   $0x70
c0108138:	68 b3 c7 10 c0       	push   $0xc010c7b3
c010813d:	e8 ac 96 ff ff       	call   c01017ee <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c0108142:	83 ec 0c             	sub    $0xc,%esp
c0108145:	68 a4 c8 10 c0       	push   $0xc010c8a4
c010814a:	e8 63 81 ff ff       	call   c01002b2 <cprintf>
c010814f:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x5000 = 0x0e;
c0108152:	b8 00 50 00 00       	mov    $0x5000,%eax
c0108157:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==10);
c010815a:	a1 0c f0 12 c0       	mov    0xc012f00c,%eax
c010815f:	83 f8 0a             	cmp    $0xa,%eax
c0108162:	74 16                	je     c010817a <_fifo_check_swap+0x272>
c0108164:	68 15 c9 10 c0       	push   $0xc010c915
c0108169:	68 9e c7 10 c0       	push   $0xc010c79e
c010816e:	6a 73                	push   $0x73
c0108170:	68 b3 c7 10 c0       	push   $0xc010c7b3
c0108175:	e8 74 96 ff ff       	call   c01017ee <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c010817a:	83 ec 0c             	sub    $0xc,%esp
c010817d:	68 2c c8 10 c0       	push   $0xc010c82c
c0108182:	e8 2b 81 ff ff       	call   c01002b2 <cprintf>
c0108187:	83 c4 10             	add    $0x10,%esp
    assert(*(unsigned char *)0x1000 == 0x0a);
c010818a:	b8 00 10 00 00       	mov    $0x1000,%eax
c010818f:	0f b6 00             	movzbl (%eax),%eax
c0108192:	3c 0a                	cmp    $0xa,%al
c0108194:	74 16                	je     c01081ac <_fifo_check_swap+0x2a4>
c0108196:	68 28 c9 10 c0       	push   $0xc010c928
c010819b:	68 9e c7 10 c0       	push   $0xc010c79e
c01081a0:	6a 75                	push   $0x75
c01081a2:	68 b3 c7 10 c0       	push   $0xc010c7b3
c01081a7:	e8 42 96 ff ff       	call   c01017ee <__panic>
    *(unsigned char *)0x1000 = 0x0a;
c01081ac:	b8 00 10 00 00       	mov    $0x1000,%eax
c01081b1:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==11);
c01081b4:	a1 0c f0 12 c0       	mov    0xc012f00c,%eax
c01081b9:	83 f8 0b             	cmp    $0xb,%eax
c01081bc:	74 16                	je     c01081d4 <_fifo_check_swap+0x2cc>
c01081be:	68 49 c9 10 c0       	push   $0xc010c949
c01081c3:	68 9e c7 10 c0       	push   $0xc010c79e
c01081c8:	6a 77                	push   $0x77
c01081ca:	68 b3 c7 10 c0       	push   $0xc010c7b3
c01081cf:	e8 1a 96 ff ff       	call   c01017ee <__panic>
    return 0;
c01081d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01081d9:	c9                   	leave  
c01081da:	c3                   	ret    

c01081db <_fifo_init>:


static int
_fifo_init(void)
{
c01081db:	f3 0f 1e fb          	endbr32 
c01081df:	55                   	push   %ebp
c01081e0:	89 e5                	mov    %esp,%ebp
    return 0;
c01081e2:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01081e7:	5d                   	pop    %ebp
c01081e8:	c3                   	ret    

c01081e9 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c01081e9:	f3 0f 1e fb          	endbr32 
c01081ed:	55                   	push   %ebp
c01081ee:	89 e5                	mov    %esp,%ebp
    return 0;
c01081f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01081f5:	5d                   	pop    %ebp
c01081f6:	c3                   	ret    

c01081f7 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
c01081f7:	f3 0f 1e fb          	endbr32 
c01081fb:	55                   	push   %ebp
c01081fc:	89 e5                	mov    %esp,%ebp
c01081fe:	b8 00 00 00 00       	mov    $0x0,%eax
c0108203:	5d                   	pop    %ebp
c0108204:	c3                   	ret    

c0108205 <page2ppn>:
page2ppn(struct Page *page) {
c0108205:	55                   	push   %ebp
c0108206:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0108208:	a1 60 10 13 c0       	mov    0xc0131060,%eax
c010820d:	8b 55 08             	mov    0x8(%ebp),%edx
c0108210:	29 c2                	sub    %eax,%edx
c0108212:	89 d0                	mov    %edx,%eax
c0108214:	c1 f8 02             	sar    $0x2,%eax
c0108217:	69 c0 39 8e e3 38    	imul   $0x38e38e39,%eax,%eax
}
c010821d:	5d                   	pop    %ebp
c010821e:	c3                   	ret    

c010821f <page2pa>:
page2pa(struct Page *page) {
c010821f:	55                   	push   %ebp
c0108220:	89 e5                	mov    %esp,%ebp
    return page2ppn(page) << PGSHIFT;
c0108222:	ff 75 08             	pushl  0x8(%ebp)
c0108225:	e8 db ff ff ff       	call   c0108205 <page2ppn>
c010822a:	83 c4 04             	add    $0x4,%esp
c010822d:	c1 e0 0c             	shl    $0xc,%eax
}
c0108230:	c9                   	leave  
c0108231:	c3                   	ret    

c0108232 <page_ref>:
page_ref(struct Page *page) {
c0108232:	55                   	push   %ebp
c0108233:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0108235:	8b 45 08             	mov    0x8(%ebp),%eax
c0108238:	8b 00                	mov    (%eax),%eax
}
c010823a:	5d                   	pop    %ebp
c010823b:	c3                   	ret    

c010823c <set_page_ref>:
set_page_ref(struct Page *page, int val) {
c010823c:	55                   	push   %ebp
c010823d:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c010823f:	8b 45 08             	mov    0x8(%ebp),%eax
c0108242:	8b 55 0c             	mov    0xc(%ebp),%edx
c0108245:	89 10                	mov    %edx,(%eax)
}
c0108247:	90                   	nop
c0108248:	5d                   	pop    %ebp
c0108249:	c3                   	ret    

c010824a <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c010824a:	f3 0f 1e fb          	endbr32 
c010824e:	55                   	push   %ebp
c010824f:	89 e5                	mov    %esp,%ebp
c0108251:	83 ec 10             	sub    $0x10,%esp
c0108254:	c7 45 fc 4c 11 13 c0 	movl   $0xc013114c,-0x4(%ebp)
    elm->prev = elm->next = elm;
c010825b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010825e:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0108261:	89 50 04             	mov    %edx,0x4(%eax)
c0108264:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108267:	8b 50 04             	mov    0x4(%eax),%edx
c010826a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010826d:	89 10                	mov    %edx,(%eax)
}
c010826f:	90                   	nop
    list_init(&free_list);
    nr_free = 0;
c0108270:	c7 05 54 11 13 c0 00 	movl   $0x0,0xc0131154
c0108277:	00 00 00 
}
c010827a:	90                   	nop
c010827b:	c9                   	leave  
c010827c:	c3                   	ret    

c010827d <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c010827d:	f3 0f 1e fb          	endbr32 
c0108281:	55                   	push   %ebp
c0108282:	89 e5                	mov    %esp,%ebp
c0108284:	83 ec 38             	sub    $0x38,%esp
    assert(n > 0);
c0108287:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010828b:	75 16                	jne    c01082a3 <default_init_memmap+0x26>
c010828d:	68 6c c9 10 c0       	push   $0xc010c96c
c0108292:	68 72 c9 10 c0       	push   $0xc010c972
c0108297:	6a 6d                	push   $0x6d
c0108299:	68 87 c9 10 c0       	push   $0xc010c987
c010829e:	e8 4b 95 ff ff       	call   c01017ee <__panic>
    struct Page *p = base;
c01082a3:	8b 45 08             	mov    0x8(%ebp),%eax
c01082a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c01082a9:	eb 6c                	jmp    c0108317 <default_init_memmap+0x9a>
        assert(PageReserved(p));
c01082ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01082ae:	83 c0 04             	add    $0x4,%eax
c01082b1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c01082b8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01082bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01082be:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01082c1:	0f a3 10             	bt     %edx,(%eax)
c01082c4:	19 c0                	sbb    %eax,%eax
c01082c6:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c01082c9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01082cd:	0f 95 c0             	setne  %al
c01082d0:	0f b6 c0             	movzbl %al,%eax
c01082d3:	85 c0                	test   %eax,%eax
c01082d5:	75 16                	jne    c01082ed <default_init_memmap+0x70>
c01082d7:	68 9d c9 10 c0       	push   $0xc010c99d
c01082dc:	68 72 c9 10 c0       	push   $0xc010c972
c01082e1:	6a 70                	push   $0x70
c01082e3:	68 87 c9 10 c0       	push   $0xc010c987
c01082e8:	e8 01 95 ff ff       	call   c01017ee <__panic>
        p->flags = p->property = 0;
c01082ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01082f0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c01082f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01082fa:	8b 50 08             	mov    0x8(%eax),%edx
c01082fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108300:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
c0108303:	83 ec 08             	sub    $0x8,%esp
c0108306:	6a 00                	push   $0x0
c0108308:	ff 75 f4             	pushl  -0xc(%ebp)
c010830b:	e8 2c ff ff ff       	call   c010823c <set_page_ref>
c0108310:	83 c4 10             	add    $0x10,%esp
    for (; p != base + n; p ++) {
c0108313:	83 45 f4 24          	addl   $0x24,-0xc(%ebp)
c0108317:	8b 55 0c             	mov    0xc(%ebp),%edx
c010831a:	89 d0                	mov    %edx,%eax
c010831c:	c1 e0 03             	shl    $0x3,%eax
c010831f:	01 d0                	add    %edx,%eax
c0108321:	c1 e0 02             	shl    $0x2,%eax
c0108324:	89 c2                	mov    %eax,%edx
c0108326:	8b 45 08             	mov    0x8(%ebp),%eax
c0108329:	01 d0                	add    %edx,%eax
c010832b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010832e:	0f 85 77 ff ff ff    	jne    c01082ab <default_init_memmap+0x2e>
    }
    base->property = n;
c0108334:	8b 45 08             	mov    0x8(%ebp),%eax
c0108337:	8b 55 0c             	mov    0xc(%ebp),%edx
c010833a:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c010833d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108340:	83 c0 04             	add    $0x4,%eax
c0108343:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c010834a:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010834d:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0108350:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0108353:	0f ab 10             	bts    %edx,(%eax)
}
c0108356:	90                   	nop
    nr_free += n;
c0108357:	8b 15 54 11 13 c0    	mov    0xc0131154,%edx
c010835d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108360:	01 d0                	add    %edx,%eax
c0108362:	a3 54 11 13 c0       	mov    %eax,0xc0131154
    list_add_before(&free_list, &(base->page_link));
c0108367:	8b 45 08             	mov    0x8(%ebp),%eax
c010836a:	83 c0 10             	add    $0x10,%eax
c010836d:	c7 45 e4 4c 11 13 c0 	movl   $0xc013114c,-0x1c(%ebp)
c0108374:	89 45 e0             	mov    %eax,-0x20(%ebp)
    __list_add(elm, listelm->prev, listelm);
c0108377:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010837a:	8b 00                	mov    (%eax),%eax
c010837c:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010837f:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0108382:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0108385:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108388:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    prev->next = next->prev = elm;
c010838b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010838e:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0108391:	89 10                	mov    %edx,(%eax)
c0108393:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0108396:	8b 10                	mov    (%eax),%edx
c0108398:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010839b:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010839e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01083a1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01083a4:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01083a7:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01083aa:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01083ad:	89 10                	mov    %edx,(%eax)
}
c01083af:	90                   	nop
}
c01083b0:	90                   	nop
}
c01083b1:	90                   	nop
c01083b2:	c9                   	leave  
c01083b3:	c3                   	ret    

c01083b4 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c01083b4:	f3 0f 1e fb          	endbr32 
c01083b8:	55                   	push   %ebp
c01083b9:	89 e5                	mov    %esp,%ebp
c01083bb:	83 ec 58             	sub    $0x58,%esp
    assert(n > 0);
c01083be:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01083c2:	75 16                	jne    c01083da <default_alloc_pages+0x26>
c01083c4:	68 6c c9 10 c0       	push   $0xc010c96c
c01083c9:	68 72 c9 10 c0       	push   $0xc010c972
c01083ce:	6a 7c                	push   $0x7c
c01083d0:	68 87 c9 10 c0       	push   $0xc010c987
c01083d5:	e8 14 94 ff ff       	call   c01017ee <__panic>
    if (n > nr_free) {
c01083da:	a1 54 11 13 c0       	mov    0xc0131154,%eax
c01083df:	39 45 08             	cmp    %eax,0x8(%ebp)
c01083e2:	76 0a                	jbe    c01083ee <default_alloc_pages+0x3a>
        return NULL;
c01083e4:	b8 00 00 00 00       	mov    $0x0,%eax
c01083e9:	e9 43 01 00 00       	jmp    c0108531 <default_alloc_pages+0x17d>
    }
    struct Page *page = NULL;
c01083ee:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
c01083f5:	c7 45 f0 4c 11 13 c0 	movl   $0xc013114c,-0x10(%ebp)
    // TODO: optimize (next-fit)
    while ((le = list_next(le)) != &free_list) {
c01083fc:	eb 1c                	jmp    c010841a <default_alloc_pages+0x66>
        struct Page *p = le2page(le, page_link);
c01083fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108401:	83 e8 10             	sub    $0x10,%eax
c0108404:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
c0108407:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010840a:	8b 40 08             	mov    0x8(%eax),%eax
c010840d:	39 45 08             	cmp    %eax,0x8(%ebp)
c0108410:	77 08                	ja     c010841a <default_alloc_pages+0x66>
            page = p;
c0108412:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108415:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
c0108418:	eb 18                	jmp    c0108432 <default_alloc_pages+0x7e>
c010841a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010841d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->next;
c0108420:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108423:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0108426:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108429:	81 7d f0 4c 11 13 c0 	cmpl   $0xc013114c,-0x10(%ebp)
c0108430:	75 cc                	jne    c01083fe <default_alloc_pages+0x4a>
        }
    }
    if (page != NULL) {
c0108432:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108436:	0f 84 f2 00 00 00    	je     c010852e <default_alloc_pages+0x17a>
        if (page->property > n) {
c010843c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010843f:	8b 40 08             	mov    0x8(%eax),%eax
c0108442:	39 45 08             	cmp    %eax,0x8(%ebp)
c0108445:	0f 83 8f 00 00 00    	jae    c01084da <default_alloc_pages+0x126>
            struct Page *p = page + n;
c010844b:	8b 55 08             	mov    0x8(%ebp),%edx
c010844e:	89 d0                	mov    %edx,%eax
c0108450:	c1 e0 03             	shl    $0x3,%eax
c0108453:	01 d0                	add    %edx,%eax
c0108455:	c1 e0 02             	shl    $0x2,%eax
c0108458:	89 c2                	mov    %eax,%edx
c010845a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010845d:	01 d0                	add    %edx,%eax
c010845f:	89 45 e8             	mov    %eax,-0x18(%ebp)
            p->property = page->property - n;
c0108462:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108465:	8b 40 08             	mov    0x8(%eax),%eax
c0108468:	2b 45 08             	sub    0x8(%ebp),%eax
c010846b:	89 c2                	mov    %eax,%edx
c010846d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108470:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(p);
c0108473:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108476:	83 c0 04             	add    $0x4,%eax
c0108479:	c7 45 cc 01 00 00 00 	movl   $0x1,-0x34(%ebp)
c0108480:	89 45 c8             	mov    %eax,-0x38(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0108483:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0108486:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0108489:	0f ab 10             	bts    %edx,(%eax)
}
c010848c:	90                   	nop
            list_add_after(&(page->page_link), &(p->page_link));
c010848d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108490:	83 c0 10             	add    $0x10,%eax
c0108493:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108496:	83 c2 10             	add    $0x10,%edx
c0108499:	89 55 e0             	mov    %edx,-0x20(%ebp)
c010849c:	89 45 dc             	mov    %eax,-0x24(%ebp)
    __list_add(elm, listelm, listelm->next);
c010849f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01084a2:	8b 40 04             	mov    0x4(%eax),%eax
c01084a5:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01084a8:	89 55 d8             	mov    %edx,-0x28(%ebp)
c01084ab:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01084ae:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01084b1:	89 45 d0             	mov    %eax,-0x30(%ebp)
    prev->next = next->prev = elm;
c01084b4:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01084b7:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01084ba:	89 10                	mov    %edx,(%eax)
c01084bc:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01084bf:	8b 10                	mov    (%eax),%edx
c01084c1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01084c4:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01084c7:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01084ca:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01084cd:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01084d0:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01084d3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01084d6:	89 10                	mov    %edx,(%eax)
}
c01084d8:	90                   	nop
}
c01084d9:	90                   	nop
        }
        list_del(&(page->page_link));
c01084da:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01084dd:	83 c0 10             	add    $0x10,%eax
c01084e0:	89 45 bc             	mov    %eax,-0x44(%ebp)
    __list_del(listelm->prev, listelm->next);
c01084e3:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01084e6:	8b 40 04             	mov    0x4(%eax),%eax
c01084e9:	8b 55 bc             	mov    -0x44(%ebp),%edx
c01084ec:	8b 12                	mov    (%edx),%edx
c01084ee:	89 55 b8             	mov    %edx,-0x48(%ebp)
c01084f1:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    prev->next = next;
c01084f4:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01084f7:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01084fa:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01084fd:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0108500:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0108503:	89 10                	mov    %edx,(%eax)
}
c0108505:	90                   	nop
}
c0108506:	90                   	nop
        nr_free -= n;
c0108507:	a1 54 11 13 c0       	mov    0xc0131154,%eax
c010850c:	2b 45 08             	sub    0x8(%ebp),%eax
c010850f:	a3 54 11 13 c0       	mov    %eax,0xc0131154
        ClearPageProperty(page);
c0108514:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108517:	83 c0 04             	add    $0x4,%eax
c010851a:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c0108521:	89 45 c0             	mov    %eax,-0x40(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0108524:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0108527:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c010852a:	0f b3 10             	btr    %edx,(%eax)
}
c010852d:	90                   	nop
    }
    return page;
c010852e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0108531:	c9                   	leave  
c0108532:	c3                   	ret    

c0108533 <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c0108533:	f3 0f 1e fb          	endbr32 
c0108537:	55                   	push   %ebp
c0108538:	89 e5                	mov    %esp,%ebp
c010853a:	81 ec 88 00 00 00    	sub    $0x88,%esp
    assert(n > 0);
c0108540:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0108544:	75 19                	jne    c010855f <default_free_pages+0x2c>
c0108546:	68 6c c9 10 c0       	push   $0xc010c96c
c010854b:	68 72 c9 10 c0       	push   $0xc010c972
c0108550:	68 9a 00 00 00       	push   $0x9a
c0108555:	68 87 c9 10 c0       	push   $0xc010c987
c010855a:	e8 8f 92 ff ff       	call   c01017ee <__panic>
    struct Page *p = base;
c010855f:	8b 45 08             	mov    0x8(%ebp),%eax
c0108562:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c0108565:	e9 8f 00 00 00       	jmp    c01085f9 <default_free_pages+0xc6>
        assert(!PageReserved(p) && !PageProperty(p));
c010856a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010856d:	83 c0 04             	add    $0x4,%eax
c0108570:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0108577:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010857a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010857d:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0108580:	0f a3 10             	bt     %edx,(%eax)
c0108583:	19 c0                	sbb    %eax,%eax
c0108585:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c0108588:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010858c:	0f 95 c0             	setne  %al
c010858f:	0f b6 c0             	movzbl %al,%eax
c0108592:	85 c0                	test   %eax,%eax
c0108594:	75 2c                	jne    c01085c2 <default_free_pages+0x8f>
c0108596:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108599:	83 c0 04             	add    $0x4,%eax
c010859c:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c01085a3:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01085a6:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01085a9:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01085ac:	0f a3 10             	bt     %edx,(%eax)
c01085af:	19 c0                	sbb    %eax,%eax
c01085b1:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
c01085b4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c01085b8:	0f 95 c0             	setne  %al
c01085bb:	0f b6 c0             	movzbl %al,%eax
c01085be:	85 c0                	test   %eax,%eax
c01085c0:	74 19                	je     c01085db <default_free_pages+0xa8>
c01085c2:	68 b0 c9 10 c0       	push   $0xc010c9b0
c01085c7:	68 72 c9 10 c0       	push   $0xc010c972
c01085cc:	68 9d 00 00 00       	push   $0x9d
c01085d1:	68 87 c9 10 c0       	push   $0xc010c987
c01085d6:	e8 13 92 ff ff       	call   c01017ee <__panic>
        p->flags = 0;
c01085db:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01085de:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c01085e5:	83 ec 08             	sub    $0x8,%esp
c01085e8:	6a 00                	push   $0x0
c01085ea:	ff 75 f4             	pushl  -0xc(%ebp)
c01085ed:	e8 4a fc ff ff       	call   c010823c <set_page_ref>
c01085f2:	83 c4 10             	add    $0x10,%esp
    for (; p != base + n; p ++) {
c01085f5:	83 45 f4 24          	addl   $0x24,-0xc(%ebp)
c01085f9:	8b 55 0c             	mov    0xc(%ebp),%edx
c01085fc:	89 d0                	mov    %edx,%eax
c01085fe:	c1 e0 03             	shl    $0x3,%eax
c0108601:	01 d0                	add    %edx,%eax
c0108603:	c1 e0 02             	shl    $0x2,%eax
c0108606:	89 c2                	mov    %eax,%edx
c0108608:	8b 45 08             	mov    0x8(%ebp),%eax
c010860b:	01 d0                	add    %edx,%eax
c010860d:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0108610:	0f 85 54 ff ff ff    	jne    c010856a <default_free_pages+0x37>
    }
    base->property = n;
c0108616:	8b 45 08             	mov    0x8(%ebp),%eax
c0108619:	8b 55 0c             	mov    0xc(%ebp),%edx
c010861c:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c010861f:	8b 45 08             	mov    0x8(%ebp),%eax
c0108622:	83 c0 04             	add    $0x4,%eax
c0108625:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c010862c:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010862f:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0108632:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0108635:	0f ab 10             	bts    %edx,(%eax)
}
c0108638:	90                   	nop
c0108639:	c7 45 d4 4c 11 13 c0 	movl   $0xc013114c,-0x2c(%ebp)
    return listelm->next;
c0108640:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0108643:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
c0108646:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c0108649:	e9 0e 01 00 00       	jmp    c010875c <default_free_pages+0x229>
        p = le2page(le, page_link);
c010864e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108651:	83 e8 10             	sub    $0x10,%eax
c0108654:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108657:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010865a:	89 45 c8             	mov    %eax,-0x38(%ebp)
c010865d:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0108660:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0108663:	89 45 f0             	mov    %eax,-0x10(%ebp)
        // TODO: optimize
        if (base + base->property == p) {
c0108666:	8b 45 08             	mov    0x8(%ebp),%eax
c0108669:	8b 50 08             	mov    0x8(%eax),%edx
c010866c:	89 d0                	mov    %edx,%eax
c010866e:	c1 e0 03             	shl    $0x3,%eax
c0108671:	01 d0                	add    %edx,%eax
c0108673:	c1 e0 02             	shl    $0x2,%eax
c0108676:	89 c2                	mov    %eax,%edx
c0108678:	8b 45 08             	mov    0x8(%ebp),%eax
c010867b:	01 d0                	add    %edx,%eax
c010867d:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0108680:	75 5d                	jne    c01086df <default_free_pages+0x1ac>
            base->property += p->property;
c0108682:	8b 45 08             	mov    0x8(%ebp),%eax
c0108685:	8b 50 08             	mov    0x8(%eax),%edx
c0108688:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010868b:	8b 40 08             	mov    0x8(%eax),%eax
c010868e:	01 c2                	add    %eax,%edx
c0108690:	8b 45 08             	mov    0x8(%ebp),%eax
c0108693:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
c0108696:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108699:	83 c0 04             	add    $0x4,%eax
c010869c:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
c01086a3:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01086a6:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01086a9:	8b 55 b8             	mov    -0x48(%ebp),%edx
c01086ac:	0f b3 10             	btr    %edx,(%eax)
}
c01086af:	90                   	nop
            list_del(&(p->page_link));
c01086b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01086b3:	83 c0 10             	add    $0x10,%eax
c01086b6:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    __list_del(listelm->prev, listelm->next);
c01086b9:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01086bc:	8b 40 04             	mov    0x4(%eax),%eax
c01086bf:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c01086c2:	8b 12                	mov    (%edx),%edx
c01086c4:	89 55 c0             	mov    %edx,-0x40(%ebp)
c01086c7:	89 45 bc             	mov    %eax,-0x44(%ebp)
    prev->next = next;
c01086ca:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01086cd:	8b 55 bc             	mov    -0x44(%ebp),%edx
c01086d0:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01086d3:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01086d6:	8b 55 c0             	mov    -0x40(%ebp),%edx
c01086d9:	89 10                	mov    %edx,(%eax)
}
c01086db:	90                   	nop
}
c01086dc:	90                   	nop
c01086dd:	eb 7d                	jmp    c010875c <default_free_pages+0x229>
        }
        else if (p + p->property == base) {
c01086df:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01086e2:	8b 50 08             	mov    0x8(%eax),%edx
c01086e5:	89 d0                	mov    %edx,%eax
c01086e7:	c1 e0 03             	shl    $0x3,%eax
c01086ea:	01 d0                	add    %edx,%eax
c01086ec:	c1 e0 02             	shl    $0x2,%eax
c01086ef:	89 c2                	mov    %eax,%edx
c01086f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01086f4:	01 d0                	add    %edx,%eax
c01086f6:	39 45 08             	cmp    %eax,0x8(%ebp)
c01086f9:	75 61                	jne    c010875c <default_free_pages+0x229>
            p->property += base->property;
c01086fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01086fe:	8b 50 08             	mov    0x8(%eax),%edx
c0108701:	8b 45 08             	mov    0x8(%ebp),%eax
c0108704:	8b 40 08             	mov    0x8(%eax),%eax
c0108707:	01 c2                	add    %eax,%edx
c0108709:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010870c:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
c010870f:	8b 45 08             	mov    0x8(%ebp),%eax
c0108712:	83 c0 04             	add    $0x4,%eax
c0108715:	c7 45 a4 01 00 00 00 	movl   $0x1,-0x5c(%ebp)
c010871c:	89 45 a0             	mov    %eax,-0x60(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010871f:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0108722:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0108725:	0f b3 10             	btr    %edx,(%eax)
}
c0108728:	90                   	nop
            base = p;
c0108729:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010872c:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
c010872f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108732:	83 c0 10             	add    $0x10,%eax
c0108735:	89 45 b0             	mov    %eax,-0x50(%ebp)
    __list_del(listelm->prev, listelm->next);
c0108738:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010873b:	8b 40 04             	mov    0x4(%eax),%eax
c010873e:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0108741:	8b 12                	mov    (%edx),%edx
c0108743:	89 55 ac             	mov    %edx,-0x54(%ebp)
c0108746:	89 45 a8             	mov    %eax,-0x58(%ebp)
    prev->next = next;
c0108749:	8b 45 ac             	mov    -0x54(%ebp),%eax
c010874c:	8b 55 a8             	mov    -0x58(%ebp),%edx
c010874f:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0108752:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0108755:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0108758:	89 10                	mov    %edx,(%eax)
}
c010875a:	90                   	nop
}
c010875b:	90                   	nop
    while (le != &free_list) {
c010875c:	81 7d f0 4c 11 13 c0 	cmpl   $0xc013114c,-0x10(%ebp)
c0108763:	0f 85 e5 fe ff ff    	jne    c010864e <default_free_pages+0x11b>
        }
    }
    nr_free += n;
c0108769:	8b 15 54 11 13 c0    	mov    0xc0131154,%edx
c010876f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108772:	01 d0                	add    %edx,%eax
c0108774:	a3 54 11 13 c0       	mov    %eax,0xc0131154
c0108779:	c7 45 9c 4c 11 13 c0 	movl   $0xc013114c,-0x64(%ebp)
    return listelm->next;
c0108780:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0108783:	8b 40 04             	mov    0x4(%eax),%eax
    le = list_next(&free_list);
c0108786:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c0108789:	eb 69                	jmp    c01087f4 <default_free_pages+0x2c1>
        p = le2page(le, page_link);
c010878b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010878e:	83 e8 10             	sub    $0x10,%eax
c0108791:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (base + base->property <= p) {
c0108794:	8b 45 08             	mov    0x8(%ebp),%eax
c0108797:	8b 50 08             	mov    0x8(%eax),%edx
c010879a:	89 d0                	mov    %edx,%eax
c010879c:	c1 e0 03             	shl    $0x3,%eax
c010879f:	01 d0                	add    %edx,%eax
c01087a1:	c1 e0 02             	shl    $0x2,%eax
c01087a4:	89 c2                	mov    %eax,%edx
c01087a6:	8b 45 08             	mov    0x8(%ebp),%eax
c01087a9:	01 d0                	add    %edx,%eax
c01087ab:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01087ae:	72 35                	jb     c01087e5 <default_free_pages+0x2b2>
            assert(base + base->property != p);
c01087b0:	8b 45 08             	mov    0x8(%ebp),%eax
c01087b3:	8b 50 08             	mov    0x8(%eax),%edx
c01087b6:	89 d0                	mov    %edx,%eax
c01087b8:	c1 e0 03             	shl    $0x3,%eax
c01087bb:	01 d0                	add    %edx,%eax
c01087bd:	c1 e0 02             	shl    $0x2,%eax
c01087c0:	89 c2                	mov    %eax,%edx
c01087c2:	8b 45 08             	mov    0x8(%ebp),%eax
c01087c5:	01 d0                	add    %edx,%eax
c01087c7:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01087ca:	75 33                	jne    c01087ff <default_free_pages+0x2cc>
c01087cc:	68 d5 c9 10 c0       	push   $0xc010c9d5
c01087d1:	68 72 c9 10 c0       	push   $0xc010c972
c01087d6:	68 b9 00 00 00       	push   $0xb9
c01087db:	68 87 c9 10 c0       	push   $0xc010c987
c01087e0:	e8 09 90 ff ff       	call   c01017ee <__panic>
c01087e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01087e8:	89 45 98             	mov    %eax,-0x68(%ebp)
c01087eb:	8b 45 98             	mov    -0x68(%ebp),%eax
c01087ee:	8b 40 04             	mov    0x4(%eax),%eax
            break;
        }
        le = list_next(le);
c01087f1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c01087f4:	81 7d f0 4c 11 13 c0 	cmpl   $0xc013114c,-0x10(%ebp)
c01087fb:	75 8e                	jne    c010878b <default_free_pages+0x258>
c01087fd:	eb 01                	jmp    c0108800 <default_free_pages+0x2cd>
            break;
c01087ff:	90                   	nop
    }
    list_add_before(le, &(base->page_link));
c0108800:	8b 45 08             	mov    0x8(%ebp),%eax
c0108803:	8d 50 10             	lea    0x10(%eax),%edx
c0108806:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108809:	89 45 94             	mov    %eax,-0x6c(%ebp)
c010880c:	89 55 90             	mov    %edx,-0x70(%ebp)
    __list_add(elm, listelm->prev, listelm);
c010880f:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0108812:	8b 00                	mov    (%eax),%eax
c0108814:	8b 55 90             	mov    -0x70(%ebp),%edx
c0108817:	89 55 8c             	mov    %edx,-0x74(%ebp)
c010881a:	89 45 88             	mov    %eax,-0x78(%ebp)
c010881d:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0108820:	89 45 84             	mov    %eax,-0x7c(%ebp)
    prev->next = next->prev = elm;
c0108823:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0108826:	8b 55 8c             	mov    -0x74(%ebp),%edx
c0108829:	89 10                	mov    %edx,(%eax)
c010882b:	8b 45 84             	mov    -0x7c(%ebp),%eax
c010882e:	8b 10                	mov    (%eax),%edx
c0108830:	8b 45 88             	mov    -0x78(%ebp),%eax
c0108833:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0108836:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0108839:	8b 55 84             	mov    -0x7c(%ebp),%edx
c010883c:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010883f:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0108842:	8b 55 88             	mov    -0x78(%ebp),%edx
c0108845:	89 10                	mov    %edx,(%eax)
}
c0108847:	90                   	nop
}
c0108848:	90                   	nop
}
c0108849:	90                   	nop
c010884a:	c9                   	leave  
c010884b:	c3                   	ret    

c010884c <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c010884c:	f3 0f 1e fb          	endbr32 
c0108850:	55                   	push   %ebp
c0108851:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0108853:	a1 54 11 13 c0       	mov    0xc0131154,%eax
}
c0108858:	5d                   	pop    %ebp
c0108859:	c3                   	ret    

c010885a <basic_check>:

static void
basic_check(void) {
c010885a:	f3 0f 1e fb          	endbr32 
c010885e:	55                   	push   %ebp
c010885f:	89 e5                	mov    %esp,%ebp
c0108861:	83 ec 38             	sub    $0x38,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0108864:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010886b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010886e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108871:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108874:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0108877:	83 ec 0c             	sub    $0xc,%esp
c010887a:	6a 01                	push   $0x1
c010887c:	e8 f1 c0 ff ff       	call   c0104972 <alloc_pages>
c0108881:	83 c4 10             	add    $0x10,%esp
c0108884:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108887:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010888b:	75 19                	jne    c01088a6 <basic_check+0x4c>
c010888d:	68 f0 c9 10 c0       	push   $0xc010c9f0
c0108892:	68 72 c9 10 c0       	push   $0xc010c972
c0108897:	68 ca 00 00 00       	push   $0xca
c010889c:	68 87 c9 10 c0       	push   $0xc010c987
c01088a1:	e8 48 8f ff ff       	call   c01017ee <__panic>
    assert((p1 = alloc_page()) != NULL);
c01088a6:	83 ec 0c             	sub    $0xc,%esp
c01088a9:	6a 01                	push   $0x1
c01088ab:	e8 c2 c0 ff ff       	call   c0104972 <alloc_pages>
c01088b0:	83 c4 10             	add    $0x10,%esp
c01088b3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01088b6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01088ba:	75 19                	jne    c01088d5 <basic_check+0x7b>
c01088bc:	68 0c ca 10 c0       	push   $0xc010ca0c
c01088c1:	68 72 c9 10 c0       	push   $0xc010c972
c01088c6:	68 cb 00 00 00       	push   $0xcb
c01088cb:	68 87 c9 10 c0       	push   $0xc010c987
c01088d0:	e8 19 8f ff ff       	call   c01017ee <__panic>
    assert((p2 = alloc_page()) != NULL);
c01088d5:	83 ec 0c             	sub    $0xc,%esp
c01088d8:	6a 01                	push   $0x1
c01088da:	e8 93 c0 ff ff       	call   c0104972 <alloc_pages>
c01088df:	83 c4 10             	add    $0x10,%esp
c01088e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01088e5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01088e9:	75 19                	jne    c0108904 <basic_check+0xaa>
c01088eb:	68 28 ca 10 c0       	push   $0xc010ca28
c01088f0:	68 72 c9 10 c0       	push   $0xc010c972
c01088f5:	68 cc 00 00 00       	push   $0xcc
c01088fa:	68 87 c9 10 c0       	push   $0xc010c987
c01088ff:	e8 ea 8e ff ff       	call   c01017ee <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0108904:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108907:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c010890a:	74 10                	je     c010891c <basic_check+0xc2>
c010890c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010890f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0108912:	74 08                	je     c010891c <basic_check+0xc2>
c0108914:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108917:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010891a:	75 19                	jne    c0108935 <basic_check+0xdb>
c010891c:	68 44 ca 10 c0       	push   $0xc010ca44
c0108921:	68 72 c9 10 c0       	push   $0xc010c972
c0108926:	68 ce 00 00 00       	push   $0xce
c010892b:	68 87 c9 10 c0       	push   $0xc010c987
c0108930:	e8 b9 8e ff ff       	call   c01017ee <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c0108935:	83 ec 0c             	sub    $0xc,%esp
c0108938:	ff 75 ec             	pushl  -0x14(%ebp)
c010893b:	e8 f2 f8 ff ff       	call   c0108232 <page_ref>
c0108940:	83 c4 10             	add    $0x10,%esp
c0108943:	85 c0                	test   %eax,%eax
c0108945:	75 24                	jne    c010896b <basic_check+0x111>
c0108947:	83 ec 0c             	sub    $0xc,%esp
c010894a:	ff 75 f0             	pushl  -0x10(%ebp)
c010894d:	e8 e0 f8 ff ff       	call   c0108232 <page_ref>
c0108952:	83 c4 10             	add    $0x10,%esp
c0108955:	85 c0                	test   %eax,%eax
c0108957:	75 12                	jne    c010896b <basic_check+0x111>
c0108959:	83 ec 0c             	sub    $0xc,%esp
c010895c:	ff 75 f4             	pushl  -0xc(%ebp)
c010895f:	e8 ce f8 ff ff       	call   c0108232 <page_ref>
c0108964:	83 c4 10             	add    $0x10,%esp
c0108967:	85 c0                	test   %eax,%eax
c0108969:	74 19                	je     c0108984 <basic_check+0x12a>
c010896b:	68 68 ca 10 c0       	push   $0xc010ca68
c0108970:	68 72 c9 10 c0       	push   $0xc010c972
c0108975:	68 cf 00 00 00       	push   $0xcf
c010897a:	68 87 c9 10 c0       	push   $0xc010c987
c010897f:	e8 6a 8e ff ff       	call   c01017ee <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0108984:	83 ec 0c             	sub    $0xc,%esp
c0108987:	ff 75 ec             	pushl  -0x14(%ebp)
c010898a:	e8 90 f8 ff ff       	call   c010821f <page2pa>
c010898f:	83 c4 10             	add    $0x10,%esp
c0108992:	8b 15 80 ef 12 c0    	mov    0xc012ef80,%edx
c0108998:	c1 e2 0c             	shl    $0xc,%edx
c010899b:	39 d0                	cmp    %edx,%eax
c010899d:	72 19                	jb     c01089b8 <basic_check+0x15e>
c010899f:	68 a4 ca 10 c0       	push   $0xc010caa4
c01089a4:	68 72 c9 10 c0       	push   $0xc010c972
c01089a9:	68 d1 00 00 00       	push   $0xd1
c01089ae:	68 87 c9 10 c0       	push   $0xc010c987
c01089b3:	e8 36 8e ff ff       	call   c01017ee <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c01089b8:	83 ec 0c             	sub    $0xc,%esp
c01089bb:	ff 75 f0             	pushl  -0x10(%ebp)
c01089be:	e8 5c f8 ff ff       	call   c010821f <page2pa>
c01089c3:	83 c4 10             	add    $0x10,%esp
c01089c6:	8b 15 80 ef 12 c0    	mov    0xc012ef80,%edx
c01089cc:	c1 e2 0c             	shl    $0xc,%edx
c01089cf:	39 d0                	cmp    %edx,%eax
c01089d1:	72 19                	jb     c01089ec <basic_check+0x192>
c01089d3:	68 c1 ca 10 c0       	push   $0xc010cac1
c01089d8:	68 72 c9 10 c0       	push   $0xc010c972
c01089dd:	68 d2 00 00 00       	push   $0xd2
c01089e2:	68 87 c9 10 c0       	push   $0xc010c987
c01089e7:	e8 02 8e ff ff       	call   c01017ee <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c01089ec:	83 ec 0c             	sub    $0xc,%esp
c01089ef:	ff 75 f4             	pushl  -0xc(%ebp)
c01089f2:	e8 28 f8 ff ff       	call   c010821f <page2pa>
c01089f7:	83 c4 10             	add    $0x10,%esp
c01089fa:	8b 15 80 ef 12 c0    	mov    0xc012ef80,%edx
c0108a00:	c1 e2 0c             	shl    $0xc,%edx
c0108a03:	39 d0                	cmp    %edx,%eax
c0108a05:	72 19                	jb     c0108a20 <basic_check+0x1c6>
c0108a07:	68 de ca 10 c0       	push   $0xc010cade
c0108a0c:	68 72 c9 10 c0       	push   $0xc010c972
c0108a11:	68 d3 00 00 00       	push   $0xd3
c0108a16:	68 87 c9 10 c0       	push   $0xc010c987
c0108a1b:	e8 ce 8d ff ff       	call   c01017ee <__panic>

    list_entry_t free_list_store = free_list;
c0108a20:	a1 4c 11 13 c0       	mov    0xc013114c,%eax
c0108a25:	8b 15 50 11 13 c0    	mov    0xc0131150,%edx
c0108a2b:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0108a2e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0108a31:	c7 45 dc 4c 11 13 c0 	movl   $0xc013114c,-0x24(%ebp)
    elm->prev = elm->next = elm;
c0108a38:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108a3b:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0108a3e:	89 50 04             	mov    %edx,0x4(%eax)
c0108a41:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108a44:	8b 50 04             	mov    0x4(%eax),%edx
c0108a47:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108a4a:	89 10                	mov    %edx,(%eax)
}
c0108a4c:	90                   	nop
c0108a4d:	c7 45 e0 4c 11 13 c0 	movl   $0xc013114c,-0x20(%ebp)
    return list->next == list;
c0108a54:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108a57:	8b 40 04             	mov    0x4(%eax),%eax
c0108a5a:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0108a5d:	0f 94 c0             	sete   %al
c0108a60:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0108a63:	85 c0                	test   %eax,%eax
c0108a65:	75 19                	jne    c0108a80 <basic_check+0x226>
c0108a67:	68 fb ca 10 c0       	push   $0xc010cafb
c0108a6c:	68 72 c9 10 c0       	push   $0xc010c972
c0108a71:	68 d7 00 00 00       	push   $0xd7
c0108a76:	68 87 c9 10 c0       	push   $0xc010c987
c0108a7b:	e8 6e 8d ff ff       	call   c01017ee <__panic>

    unsigned int nr_free_store = nr_free;
c0108a80:	a1 54 11 13 c0       	mov    0xc0131154,%eax
c0108a85:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c0108a88:	c7 05 54 11 13 c0 00 	movl   $0x0,0xc0131154
c0108a8f:	00 00 00 

    assert(alloc_page() == NULL);
c0108a92:	83 ec 0c             	sub    $0xc,%esp
c0108a95:	6a 01                	push   $0x1
c0108a97:	e8 d6 be ff ff       	call   c0104972 <alloc_pages>
c0108a9c:	83 c4 10             	add    $0x10,%esp
c0108a9f:	85 c0                	test   %eax,%eax
c0108aa1:	74 19                	je     c0108abc <basic_check+0x262>
c0108aa3:	68 12 cb 10 c0       	push   $0xc010cb12
c0108aa8:	68 72 c9 10 c0       	push   $0xc010c972
c0108aad:	68 dc 00 00 00       	push   $0xdc
c0108ab2:	68 87 c9 10 c0       	push   $0xc010c987
c0108ab7:	e8 32 8d ff ff       	call   c01017ee <__panic>

    free_page(p0);
c0108abc:	83 ec 08             	sub    $0x8,%esp
c0108abf:	6a 01                	push   $0x1
c0108ac1:	ff 75 ec             	pushl  -0x14(%ebp)
c0108ac4:	e8 19 bf ff ff       	call   c01049e2 <free_pages>
c0108ac9:	83 c4 10             	add    $0x10,%esp
    free_page(p1);
c0108acc:	83 ec 08             	sub    $0x8,%esp
c0108acf:	6a 01                	push   $0x1
c0108ad1:	ff 75 f0             	pushl  -0x10(%ebp)
c0108ad4:	e8 09 bf ff ff       	call   c01049e2 <free_pages>
c0108ad9:	83 c4 10             	add    $0x10,%esp
    free_page(p2);
c0108adc:	83 ec 08             	sub    $0x8,%esp
c0108adf:	6a 01                	push   $0x1
c0108ae1:	ff 75 f4             	pushl  -0xc(%ebp)
c0108ae4:	e8 f9 be ff ff       	call   c01049e2 <free_pages>
c0108ae9:	83 c4 10             	add    $0x10,%esp
    assert(nr_free == 3);
c0108aec:	a1 54 11 13 c0       	mov    0xc0131154,%eax
c0108af1:	83 f8 03             	cmp    $0x3,%eax
c0108af4:	74 19                	je     c0108b0f <basic_check+0x2b5>
c0108af6:	68 27 cb 10 c0       	push   $0xc010cb27
c0108afb:	68 72 c9 10 c0       	push   $0xc010c972
c0108b00:	68 e1 00 00 00       	push   $0xe1
c0108b05:	68 87 c9 10 c0       	push   $0xc010c987
c0108b0a:	e8 df 8c ff ff       	call   c01017ee <__panic>

    assert((p0 = alloc_page()) != NULL);
c0108b0f:	83 ec 0c             	sub    $0xc,%esp
c0108b12:	6a 01                	push   $0x1
c0108b14:	e8 59 be ff ff       	call   c0104972 <alloc_pages>
c0108b19:	83 c4 10             	add    $0x10,%esp
c0108b1c:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108b1f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0108b23:	75 19                	jne    c0108b3e <basic_check+0x2e4>
c0108b25:	68 f0 c9 10 c0       	push   $0xc010c9f0
c0108b2a:	68 72 c9 10 c0       	push   $0xc010c972
c0108b2f:	68 e3 00 00 00       	push   $0xe3
c0108b34:	68 87 c9 10 c0       	push   $0xc010c987
c0108b39:	e8 b0 8c ff ff       	call   c01017ee <__panic>
    assert((p1 = alloc_page()) != NULL);
c0108b3e:	83 ec 0c             	sub    $0xc,%esp
c0108b41:	6a 01                	push   $0x1
c0108b43:	e8 2a be ff ff       	call   c0104972 <alloc_pages>
c0108b48:	83 c4 10             	add    $0x10,%esp
c0108b4b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108b4e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0108b52:	75 19                	jne    c0108b6d <basic_check+0x313>
c0108b54:	68 0c ca 10 c0       	push   $0xc010ca0c
c0108b59:	68 72 c9 10 c0       	push   $0xc010c972
c0108b5e:	68 e4 00 00 00       	push   $0xe4
c0108b63:	68 87 c9 10 c0       	push   $0xc010c987
c0108b68:	e8 81 8c ff ff       	call   c01017ee <__panic>
    assert((p2 = alloc_page()) != NULL);
c0108b6d:	83 ec 0c             	sub    $0xc,%esp
c0108b70:	6a 01                	push   $0x1
c0108b72:	e8 fb bd ff ff       	call   c0104972 <alloc_pages>
c0108b77:	83 c4 10             	add    $0x10,%esp
c0108b7a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108b7d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108b81:	75 19                	jne    c0108b9c <basic_check+0x342>
c0108b83:	68 28 ca 10 c0       	push   $0xc010ca28
c0108b88:	68 72 c9 10 c0       	push   $0xc010c972
c0108b8d:	68 e5 00 00 00       	push   $0xe5
c0108b92:	68 87 c9 10 c0       	push   $0xc010c987
c0108b97:	e8 52 8c ff ff       	call   c01017ee <__panic>

    assert(alloc_page() == NULL);
c0108b9c:	83 ec 0c             	sub    $0xc,%esp
c0108b9f:	6a 01                	push   $0x1
c0108ba1:	e8 cc bd ff ff       	call   c0104972 <alloc_pages>
c0108ba6:	83 c4 10             	add    $0x10,%esp
c0108ba9:	85 c0                	test   %eax,%eax
c0108bab:	74 19                	je     c0108bc6 <basic_check+0x36c>
c0108bad:	68 12 cb 10 c0       	push   $0xc010cb12
c0108bb2:	68 72 c9 10 c0       	push   $0xc010c972
c0108bb7:	68 e7 00 00 00       	push   $0xe7
c0108bbc:	68 87 c9 10 c0       	push   $0xc010c987
c0108bc1:	e8 28 8c ff ff       	call   c01017ee <__panic>

    free_page(p0);
c0108bc6:	83 ec 08             	sub    $0x8,%esp
c0108bc9:	6a 01                	push   $0x1
c0108bcb:	ff 75 ec             	pushl  -0x14(%ebp)
c0108bce:	e8 0f be ff ff       	call   c01049e2 <free_pages>
c0108bd3:	83 c4 10             	add    $0x10,%esp
c0108bd6:	c7 45 d8 4c 11 13 c0 	movl   $0xc013114c,-0x28(%ebp)
c0108bdd:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108be0:	8b 40 04             	mov    0x4(%eax),%eax
c0108be3:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0108be6:	0f 94 c0             	sete   %al
c0108be9:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c0108bec:	85 c0                	test   %eax,%eax
c0108bee:	74 19                	je     c0108c09 <basic_check+0x3af>
c0108bf0:	68 34 cb 10 c0       	push   $0xc010cb34
c0108bf5:	68 72 c9 10 c0       	push   $0xc010c972
c0108bfa:	68 ea 00 00 00       	push   $0xea
c0108bff:	68 87 c9 10 c0       	push   $0xc010c987
c0108c04:	e8 e5 8b ff ff       	call   c01017ee <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0108c09:	83 ec 0c             	sub    $0xc,%esp
c0108c0c:	6a 01                	push   $0x1
c0108c0e:	e8 5f bd ff ff       	call   c0104972 <alloc_pages>
c0108c13:	83 c4 10             	add    $0x10,%esp
c0108c16:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0108c19:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108c1c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0108c1f:	74 19                	je     c0108c3a <basic_check+0x3e0>
c0108c21:	68 4c cb 10 c0       	push   $0xc010cb4c
c0108c26:	68 72 c9 10 c0       	push   $0xc010c972
c0108c2b:	68 ed 00 00 00       	push   $0xed
c0108c30:	68 87 c9 10 c0       	push   $0xc010c987
c0108c35:	e8 b4 8b ff ff       	call   c01017ee <__panic>
    assert(alloc_page() == NULL);
c0108c3a:	83 ec 0c             	sub    $0xc,%esp
c0108c3d:	6a 01                	push   $0x1
c0108c3f:	e8 2e bd ff ff       	call   c0104972 <alloc_pages>
c0108c44:	83 c4 10             	add    $0x10,%esp
c0108c47:	85 c0                	test   %eax,%eax
c0108c49:	74 19                	je     c0108c64 <basic_check+0x40a>
c0108c4b:	68 12 cb 10 c0       	push   $0xc010cb12
c0108c50:	68 72 c9 10 c0       	push   $0xc010c972
c0108c55:	68 ee 00 00 00       	push   $0xee
c0108c5a:	68 87 c9 10 c0       	push   $0xc010c987
c0108c5f:	e8 8a 8b ff ff       	call   c01017ee <__panic>

    assert(nr_free == 0);
c0108c64:	a1 54 11 13 c0       	mov    0xc0131154,%eax
c0108c69:	85 c0                	test   %eax,%eax
c0108c6b:	74 19                	je     c0108c86 <basic_check+0x42c>
c0108c6d:	68 65 cb 10 c0       	push   $0xc010cb65
c0108c72:	68 72 c9 10 c0       	push   $0xc010c972
c0108c77:	68 f0 00 00 00       	push   $0xf0
c0108c7c:	68 87 c9 10 c0       	push   $0xc010c987
c0108c81:	e8 68 8b ff ff       	call   c01017ee <__panic>
    free_list = free_list_store;
c0108c86:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0108c89:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0108c8c:	a3 4c 11 13 c0       	mov    %eax,0xc013114c
c0108c91:	89 15 50 11 13 c0    	mov    %edx,0xc0131150
    nr_free = nr_free_store;
c0108c97:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108c9a:	a3 54 11 13 c0       	mov    %eax,0xc0131154

    free_page(p);
c0108c9f:	83 ec 08             	sub    $0x8,%esp
c0108ca2:	6a 01                	push   $0x1
c0108ca4:	ff 75 e4             	pushl  -0x1c(%ebp)
c0108ca7:	e8 36 bd ff ff       	call   c01049e2 <free_pages>
c0108cac:	83 c4 10             	add    $0x10,%esp
    free_page(p1);
c0108caf:	83 ec 08             	sub    $0x8,%esp
c0108cb2:	6a 01                	push   $0x1
c0108cb4:	ff 75 f0             	pushl  -0x10(%ebp)
c0108cb7:	e8 26 bd ff ff       	call   c01049e2 <free_pages>
c0108cbc:	83 c4 10             	add    $0x10,%esp
    free_page(p2);
c0108cbf:	83 ec 08             	sub    $0x8,%esp
c0108cc2:	6a 01                	push   $0x1
c0108cc4:	ff 75 f4             	pushl  -0xc(%ebp)
c0108cc7:	e8 16 bd ff ff       	call   c01049e2 <free_pages>
c0108ccc:	83 c4 10             	add    $0x10,%esp
}
c0108ccf:	90                   	nop
c0108cd0:	c9                   	leave  
c0108cd1:	c3                   	ret    

c0108cd2 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c0108cd2:	f3 0f 1e fb          	endbr32 
c0108cd6:	55                   	push   %ebp
c0108cd7:	89 e5                	mov    %esp,%ebp
c0108cd9:	81 ec 88 00 00 00    	sub    $0x88,%esp
    int count = 0, total = 0;
c0108cdf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0108ce6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c0108ced:	c7 45 ec 4c 11 13 c0 	movl   $0xc013114c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0108cf4:	eb 60                	jmp    c0108d56 <default_check+0x84>
        struct Page *p = le2page(le, page_link);
c0108cf6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108cf9:	83 e8 10             	sub    $0x10,%eax
c0108cfc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(PageProperty(p));
c0108cff:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0108d02:	83 c0 04             	add    $0x4,%eax
c0108d05:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0108d0c:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0108d0f:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0108d12:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0108d15:	0f a3 10             	bt     %edx,(%eax)
c0108d18:	19 c0                	sbb    %eax,%eax
c0108d1a:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c0108d1d:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0108d21:	0f 95 c0             	setne  %al
c0108d24:	0f b6 c0             	movzbl %al,%eax
c0108d27:	85 c0                	test   %eax,%eax
c0108d29:	75 19                	jne    c0108d44 <default_check+0x72>
c0108d2b:	68 72 cb 10 c0       	push   $0xc010cb72
c0108d30:	68 72 c9 10 c0       	push   $0xc010c972
c0108d35:	68 01 01 00 00       	push   $0x101
c0108d3a:	68 87 c9 10 c0       	push   $0xc010c987
c0108d3f:	e8 aa 8a ff ff       	call   c01017ee <__panic>
        count ++, total += p->property;
c0108d44:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0108d48:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0108d4b:	8b 50 08             	mov    0x8(%eax),%edx
c0108d4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108d51:	01 d0                	add    %edx,%eax
c0108d53:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108d56:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108d59:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
c0108d5c:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0108d5f:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0108d62:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108d65:	81 7d ec 4c 11 13 c0 	cmpl   $0xc013114c,-0x14(%ebp)
c0108d6c:	75 88                	jne    c0108cf6 <default_check+0x24>
    }
    assert(total == nr_free_pages());
c0108d6e:	e8 a8 bc ff ff       	call   c0104a1b <nr_free_pages>
c0108d73:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0108d76:	39 d0                	cmp    %edx,%eax
c0108d78:	74 19                	je     c0108d93 <default_check+0xc1>
c0108d7a:	68 82 cb 10 c0       	push   $0xc010cb82
c0108d7f:	68 72 c9 10 c0       	push   $0xc010c972
c0108d84:	68 04 01 00 00       	push   $0x104
c0108d89:	68 87 c9 10 c0       	push   $0xc010c987
c0108d8e:	e8 5b 8a ff ff       	call   c01017ee <__panic>

    basic_check();
c0108d93:	e8 c2 fa ff ff       	call   c010885a <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c0108d98:	83 ec 0c             	sub    $0xc,%esp
c0108d9b:	6a 05                	push   $0x5
c0108d9d:	e8 d0 bb ff ff       	call   c0104972 <alloc_pages>
c0108da2:	83 c4 10             	add    $0x10,%esp
c0108da5:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p0 != NULL);
c0108da8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0108dac:	75 19                	jne    c0108dc7 <default_check+0xf5>
c0108dae:	68 9b cb 10 c0       	push   $0xc010cb9b
c0108db3:	68 72 c9 10 c0       	push   $0xc010c972
c0108db8:	68 09 01 00 00       	push   $0x109
c0108dbd:	68 87 c9 10 c0       	push   $0xc010c987
c0108dc2:	e8 27 8a ff ff       	call   c01017ee <__panic>
    assert(!PageProperty(p0));
c0108dc7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108dca:	83 c0 04             	add    $0x4,%eax
c0108dcd:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0108dd4:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0108dd7:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0108dda:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0108ddd:	0f a3 10             	bt     %edx,(%eax)
c0108de0:	19 c0                	sbb    %eax,%eax
c0108de2:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c0108de5:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0108de9:	0f 95 c0             	setne  %al
c0108dec:	0f b6 c0             	movzbl %al,%eax
c0108def:	85 c0                	test   %eax,%eax
c0108df1:	74 19                	je     c0108e0c <default_check+0x13a>
c0108df3:	68 a6 cb 10 c0       	push   $0xc010cba6
c0108df8:	68 72 c9 10 c0       	push   $0xc010c972
c0108dfd:	68 0a 01 00 00       	push   $0x10a
c0108e02:	68 87 c9 10 c0       	push   $0xc010c987
c0108e07:	e8 e2 89 ff ff       	call   c01017ee <__panic>

    list_entry_t free_list_store = free_list;
c0108e0c:	a1 4c 11 13 c0       	mov    0xc013114c,%eax
c0108e11:	8b 15 50 11 13 c0    	mov    0xc0131150,%edx
c0108e17:	89 45 80             	mov    %eax,-0x80(%ebp)
c0108e1a:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0108e1d:	c7 45 b0 4c 11 13 c0 	movl   $0xc013114c,-0x50(%ebp)
    elm->prev = elm->next = elm;
c0108e24:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0108e27:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0108e2a:	89 50 04             	mov    %edx,0x4(%eax)
c0108e2d:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0108e30:	8b 50 04             	mov    0x4(%eax),%edx
c0108e33:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0108e36:	89 10                	mov    %edx,(%eax)
}
c0108e38:	90                   	nop
c0108e39:	c7 45 b4 4c 11 13 c0 	movl   $0xc013114c,-0x4c(%ebp)
    return list->next == list;
c0108e40:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0108e43:	8b 40 04             	mov    0x4(%eax),%eax
c0108e46:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
c0108e49:	0f 94 c0             	sete   %al
c0108e4c:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0108e4f:	85 c0                	test   %eax,%eax
c0108e51:	75 19                	jne    c0108e6c <default_check+0x19a>
c0108e53:	68 fb ca 10 c0       	push   $0xc010cafb
c0108e58:	68 72 c9 10 c0       	push   $0xc010c972
c0108e5d:	68 0e 01 00 00       	push   $0x10e
c0108e62:	68 87 c9 10 c0       	push   $0xc010c987
c0108e67:	e8 82 89 ff ff       	call   c01017ee <__panic>
    assert(alloc_page() == NULL);
c0108e6c:	83 ec 0c             	sub    $0xc,%esp
c0108e6f:	6a 01                	push   $0x1
c0108e71:	e8 fc ba ff ff       	call   c0104972 <alloc_pages>
c0108e76:	83 c4 10             	add    $0x10,%esp
c0108e79:	85 c0                	test   %eax,%eax
c0108e7b:	74 19                	je     c0108e96 <default_check+0x1c4>
c0108e7d:	68 12 cb 10 c0       	push   $0xc010cb12
c0108e82:	68 72 c9 10 c0       	push   $0xc010c972
c0108e87:	68 0f 01 00 00       	push   $0x10f
c0108e8c:	68 87 c9 10 c0       	push   $0xc010c987
c0108e91:	e8 58 89 ff ff       	call   c01017ee <__panic>

    unsigned int nr_free_store = nr_free;
c0108e96:	a1 54 11 13 c0       	mov    0xc0131154,%eax
c0108e9b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nr_free = 0;
c0108e9e:	c7 05 54 11 13 c0 00 	movl   $0x0,0xc0131154
c0108ea5:	00 00 00 

    free_pages(p0 + 2, 3);
c0108ea8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108eab:	83 c0 48             	add    $0x48,%eax
c0108eae:	83 ec 08             	sub    $0x8,%esp
c0108eb1:	6a 03                	push   $0x3
c0108eb3:	50                   	push   %eax
c0108eb4:	e8 29 bb ff ff       	call   c01049e2 <free_pages>
c0108eb9:	83 c4 10             	add    $0x10,%esp
    assert(alloc_pages(4) == NULL);
c0108ebc:	83 ec 0c             	sub    $0xc,%esp
c0108ebf:	6a 04                	push   $0x4
c0108ec1:	e8 ac ba ff ff       	call   c0104972 <alloc_pages>
c0108ec6:	83 c4 10             	add    $0x10,%esp
c0108ec9:	85 c0                	test   %eax,%eax
c0108ecb:	74 19                	je     c0108ee6 <default_check+0x214>
c0108ecd:	68 b8 cb 10 c0       	push   $0xc010cbb8
c0108ed2:	68 72 c9 10 c0       	push   $0xc010c972
c0108ed7:	68 15 01 00 00       	push   $0x115
c0108edc:	68 87 c9 10 c0       	push   $0xc010c987
c0108ee1:	e8 08 89 ff ff       	call   c01017ee <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c0108ee6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108ee9:	83 c0 48             	add    $0x48,%eax
c0108eec:	83 c0 04             	add    $0x4,%eax
c0108eef:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c0108ef6:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0108ef9:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0108efc:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0108eff:	0f a3 10             	bt     %edx,(%eax)
c0108f02:	19 c0                	sbb    %eax,%eax
c0108f04:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c0108f07:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0108f0b:	0f 95 c0             	setne  %al
c0108f0e:	0f b6 c0             	movzbl %al,%eax
c0108f11:	85 c0                	test   %eax,%eax
c0108f13:	74 0e                	je     c0108f23 <default_check+0x251>
c0108f15:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108f18:	83 c0 48             	add    $0x48,%eax
c0108f1b:	8b 40 08             	mov    0x8(%eax),%eax
c0108f1e:	83 f8 03             	cmp    $0x3,%eax
c0108f21:	74 19                	je     c0108f3c <default_check+0x26a>
c0108f23:	68 d0 cb 10 c0       	push   $0xc010cbd0
c0108f28:	68 72 c9 10 c0       	push   $0xc010c972
c0108f2d:	68 16 01 00 00       	push   $0x116
c0108f32:	68 87 c9 10 c0       	push   $0xc010c987
c0108f37:	e8 b2 88 ff ff       	call   c01017ee <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c0108f3c:	83 ec 0c             	sub    $0xc,%esp
c0108f3f:	6a 03                	push   $0x3
c0108f41:	e8 2c ba ff ff       	call   c0104972 <alloc_pages>
c0108f46:	83 c4 10             	add    $0x10,%esp
c0108f49:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0108f4c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0108f50:	75 19                	jne    c0108f6b <default_check+0x299>
c0108f52:	68 fc cb 10 c0       	push   $0xc010cbfc
c0108f57:	68 72 c9 10 c0       	push   $0xc010c972
c0108f5c:	68 17 01 00 00       	push   $0x117
c0108f61:	68 87 c9 10 c0       	push   $0xc010c987
c0108f66:	e8 83 88 ff ff       	call   c01017ee <__panic>
    assert(alloc_page() == NULL);
c0108f6b:	83 ec 0c             	sub    $0xc,%esp
c0108f6e:	6a 01                	push   $0x1
c0108f70:	e8 fd b9 ff ff       	call   c0104972 <alloc_pages>
c0108f75:	83 c4 10             	add    $0x10,%esp
c0108f78:	85 c0                	test   %eax,%eax
c0108f7a:	74 19                	je     c0108f95 <default_check+0x2c3>
c0108f7c:	68 12 cb 10 c0       	push   $0xc010cb12
c0108f81:	68 72 c9 10 c0       	push   $0xc010c972
c0108f86:	68 18 01 00 00       	push   $0x118
c0108f8b:	68 87 c9 10 c0       	push   $0xc010c987
c0108f90:	e8 59 88 ff ff       	call   c01017ee <__panic>
    assert(p0 + 2 == p1);
c0108f95:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108f98:	83 c0 48             	add    $0x48,%eax
c0108f9b:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0108f9e:	74 19                	je     c0108fb9 <default_check+0x2e7>
c0108fa0:	68 1a cc 10 c0       	push   $0xc010cc1a
c0108fa5:	68 72 c9 10 c0       	push   $0xc010c972
c0108faa:	68 19 01 00 00       	push   $0x119
c0108faf:	68 87 c9 10 c0       	push   $0xc010c987
c0108fb4:	e8 35 88 ff ff       	call   c01017ee <__panic>

    p2 = p0 + 1;
c0108fb9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108fbc:	83 c0 24             	add    $0x24,%eax
c0108fbf:	89 45 dc             	mov    %eax,-0x24(%ebp)
    free_page(p0);
c0108fc2:	83 ec 08             	sub    $0x8,%esp
c0108fc5:	6a 01                	push   $0x1
c0108fc7:	ff 75 e8             	pushl  -0x18(%ebp)
c0108fca:	e8 13 ba ff ff       	call   c01049e2 <free_pages>
c0108fcf:	83 c4 10             	add    $0x10,%esp
    free_pages(p1, 3);
c0108fd2:	83 ec 08             	sub    $0x8,%esp
c0108fd5:	6a 03                	push   $0x3
c0108fd7:	ff 75 e0             	pushl  -0x20(%ebp)
c0108fda:	e8 03 ba ff ff       	call   c01049e2 <free_pages>
c0108fdf:	83 c4 10             	add    $0x10,%esp
    assert(PageProperty(p0) && p0->property == 1);
c0108fe2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108fe5:	83 c0 04             	add    $0x4,%eax
c0108fe8:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c0108fef:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0108ff2:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0108ff5:	8b 55 a0             	mov    -0x60(%ebp),%edx
c0108ff8:	0f a3 10             	bt     %edx,(%eax)
c0108ffb:	19 c0                	sbb    %eax,%eax
c0108ffd:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c0109000:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c0109004:	0f 95 c0             	setne  %al
c0109007:	0f b6 c0             	movzbl %al,%eax
c010900a:	85 c0                	test   %eax,%eax
c010900c:	74 0b                	je     c0109019 <default_check+0x347>
c010900e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109011:	8b 40 08             	mov    0x8(%eax),%eax
c0109014:	83 f8 01             	cmp    $0x1,%eax
c0109017:	74 19                	je     c0109032 <default_check+0x360>
c0109019:	68 28 cc 10 c0       	push   $0xc010cc28
c010901e:	68 72 c9 10 c0       	push   $0xc010c972
c0109023:	68 1e 01 00 00       	push   $0x11e
c0109028:	68 87 c9 10 c0       	push   $0xc010c987
c010902d:	e8 bc 87 ff ff       	call   c01017ee <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c0109032:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109035:	83 c0 04             	add    $0x4,%eax
c0109038:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c010903f:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0109042:	8b 45 90             	mov    -0x70(%ebp),%eax
c0109045:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0109048:	0f a3 10             	bt     %edx,(%eax)
c010904b:	19 c0                	sbb    %eax,%eax
c010904d:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c0109050:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c0109054:	0f 95 c0             	setne  %al
c0109057:	0f b6 c0             	movzbl %al,%eax
c010905a:	85 c0                	test   %eax,%eax
c010905c:	74 0b                	je     c0109069 <default_check+0x397>
c010905e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109061:	8b 40 08             	mov    0x8(%eax),%eax
c0109064:	83 f8 03             	cmp    $0x3,%eax
c0109067:	74 19                	je     c0109082 <default_check+0x3b0>
c0109069:	68 50 cc 10 c0       	push   $0xc010cc50
c010906e:	68 72 c9 10 c0       	push   $0xc010c972
c0109073:	68 1f 01 00 00       	push   $0x11f
c0109078:	68 87 c9 10 c0       	push   $0xc010c987
c010907d:	e8 6c 87 ff ff       	call   c01017ee <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c0109082:	83 ec 0c             	sub    $0xc,%esp
c0109085:	6a 01                	push   $0x1
c0109087:	e8 e6 b8 ff ff       	call   c0104972 <alloc_pages>
c010908c:	83 c4 10             	add    $0x10,%esp
c010908f:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0109092:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0109095:	83 e8 24             	sub    $0x24,%eax
c0109098:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c010909b:	74 19                	je     c01090b6 <default_check+0x3e4>
c010909d:	68 76 cc 10 c0       	push   $0xc010cc76
c01090a2:	68 72 c9 10 c0       	push   $0xc010c972
c01090a7:	68 21 01 00 00       	push   $0x121
c01090ac:	68 87 c9 10 c0       	push   $0xc010c987
c01090b1:	e8 38 87 ff ff       	call   c01017ee <__panic>
    free_page(p0);
c01090b6:	83 ec 08             	sub    $0x8,%esp
c01090b9:	6a 01                	push   $0x1
c01090bb:	ff 75 e8             	pushl  -0x18(%ebp)
c01090be:	e8 1f b9 ff ff       	call   c01049e2 <free_pages>
c01090c3:	83 c4 10             	add    $0x10,%esp
    assert((p0 = alloc_pages(2)) == p2 + 1);
c01090c6:	83 ec 0c             	sub    $0xc,%esp
c01090c9:	6a 02                	push   $0x2
c01090cb:	e8 a2 b8 ff ff       	call   c0104972 <alloc_pages>
c01090d0:	83 c4 10             	add    $0x10,%esp
c01090d3:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01090d6:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01090d9:	83 c0 24             	add    $0x24,%eax
c01090dc:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c01090df:	74 19                	je     c01090fa <default_check+0x428>
c01090e1:	68 94 cc 10 c0       	push   $0xc010cc94
c01090e6:	68 72 c9 10 c0       	push   $0xc010c972
c01090eb:	68 23 01 00 00       	push   $0x123
c01090f0:	68 87 c9 10 c0       	push   $0xc010c987
c01090f5:	e8 f4 86 ff ff       	call   c01017ee <__panic>

    free_pages(p0, 2);
c01090fa:	83 ec 08             	sub    $0x8,%esp
c01090fd:	6a 02                	push   $0x2
c01090ff:	ff 75 e8             	pushl  -0x18(%ebp)
c0109102:	e8 db b8 ff ff       	call   c01049e2 <free_pages>
c0109107:	83 c4 10             	add    $0x10,%esp
    free_page(p2);
c010910a:	83 ec 08             	sub    $0x8,%esp
c010910d:	6a 01                	push   $0x1
c010910f:	ff 75 dc             	pushl  -0x24(%ebp)
c0109112:	e8 cb b8 ff ff       	call   c01049e2 <free_pages>
c0109117:	83 c4 10             	add    $0x10,%esp

    assert((p0 = alloc_pages(5)) != NULL);
c010911a:	83 ec 0c             	sub    $0xc,%esp
c010911d:	6a 05                	push   $0x5
c010911f:	e8 4e b8 ff ff       	call   c0104972 <alloc_pages>
c0109124:	83 c4 10             	add    $0x10,%esp
c0109127:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010912a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010912e:	75 19                	jne    c0109149 <default_check+0x477>
c0109130:	68 b4 cc 10 c0       	push   $0xc010ccb4
c0109135:	68 72 c9 10 c0       	push   $0xc010c972
c010913a:	68 28 01 00 00       	push   $0x128
c010913f:	68 87 c9 10 c0       	push   $0xc010c987
c0109144:	e8 a5 86 ff ff       	call   c01017ee <__panic>
    assert(alloc_page() == NULL);
c0109149:	83 ec 0c             	sub    $0xc,%esp
c010914c:	6a 01                	push   $0x1
c010914e:	e8 1f b8 ff ff       	call   c0104972 <alloc_pages>
c0109153:	83 c4 10             	add    $0x10,%esp
c0109156:	85 c0                	test   %eax,%eax
c0109158:	74 19                	je     c0109173 <default_check+0x4a1>
c010915a:	68 12 cb 10 c0       	push   $0xc010cb12
c010915f:	68 72 c9 10 c0       	push   $0xc010c972
c0109164:	68 29 01 00 00       	push   $0x129
c0109169:	68 87 c9 10 c0       	push   $0xc010c987
c010916e:	e8 7b 86 ff ff       	call   c01017ee <__panic>

    assert(nr_free == 0);
c0109173:	a1 54 11 13 c0       	mov    0xc0131154,%eax
c0109178:	85 c0                	test   %eax,%eax
c010917a:	74 19                	je     c0109195 <default_check+0x4c3>
c010917c:	68 65 cb 10 c0       	push   $0xc010cb65
c0109181:	68 72 c9 10 c0       	push   $0xc010c972
c0109186:	68 2b 01 00 00       	push   $0x12b
c010918b:	68 87 c9 10 c0       	push   $0xc010c987
c0109190:	e8 59 86 ff ff       	call   c01017ee <__panic>
    nr_free = nr_free_store;
c0109195:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109198:	a3 54 11 13 c0       	mov    %eax,0xc0131154

    free_list = free_list_store;
c010919d:	8b 45 80             	mov    -0x80(%ebp),%eax
c01091a0:	8b 55 84             	mov    -0x7c(%ebp),%edx
c01091a3:	a3 4c 11 13 c0       	mov    %eax,0xc013114c
c01091a8:	89 15 50 11 13 c0    	mov    %edx,0xc0131150
    free_pages(p0, 5);
c01091ae:	83 ec 08             	sub    $0x8,%esp
c01091b1:	6a 05                	push   $0x5
c01091b3:	ff 75 e8             	pushl  -0x18(%ebp)
c01091b6:	e8 27 b8 ff ff       	call   c01049e2 <free_pages>
c01091bb:	83 c4 10             	add    $0x10,%esp

    le = &free_list;
c01091be:	c7 45 ec 4c 11 13 c0 	movl   $0xc013114c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c01091c5:	eb 1d                	jmp    c01091e4 <default_check+0x512>
        struct Page *p = le2page(le, page_link);
c01091c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01091ca:	83 e8 10             	sub    $0x10,%eax
c01091cd:	89 45 d8             	mov    %eax,-0x28(%ebp)
        count --, total -= p->property;
c01091d0:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01091d4:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01091d7:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01091da:	8b 40 08             	mov    0x8(%eax),%eax
c01091dd:	29 c2                	sub    %eax,%edx
c01091df:	89 d0                	mov    %edx,%eax
c01091e1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01091e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01091e7:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
c01091ea:	8b 45 88             	mov    -0x78(%ebp),%eax
c01091ed:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c01091f0:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01091f3:	81 7d ec 4c 11 13 c0 	cmpl   $0xc013114c,-0x14(%ebp)
c01091fa:	75 cb                	jne    c01091c7 <default_check+0x4f5>
    }
    assert(count == 0);
c01091fc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109200:	74 19                	je     c010921b <default_check+0x549>
c0109202:	68 d2 cc 10 c0       	push   $0xc010ccd2
c0109207:	68 72 c9 10 c0       	push   $0xc010c972
c010920c:	68 36 01 00 00       	push   $0x136
c0109211:	68 87 c9 10 c0       	push   $0xc010c987
c0109216:	e8 d3 85 ff ff       	call   c01017ee <__panic>
    assert(total == 0);
c010921b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010921f:	74 19                	je     c010923a <default_check+0x568>
c0109221:	68 dd cc 10 c0       	push   $0xc010ccdd
c0109226:	68 72 c9 10 c0       	push   $0xc010c972
c010922b:	68 37 01 00 00       	push   $0x137
c0109230:	68 87 c9 10 c0       	push   $0xc010c987
c0109235:	e8 b4 85 ff ff       	call   c01017ee <__panic>
}
c010923a:	90                   	nop
c010923b:	c9                   	leave  
c010923c:	c3                   	ret    

c010923d <page2ppn>:
page2ppn(struct Page *page) {
c010923d:	55                   	push   %ebp
c010923e:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0109240:	a1 60 10 13 c0       	mov    0xc0131060,%eax
c0109245:	8b 55 08             	mov    0x8(%ebp),%edx
c0109248:	29 c2                	sub    %eax,%edx
c010924a:	89 d0                	mov    %edx,%eax
c010924c:	c1 f8 02             	sar    $0x2,%eax
c010924f:	69 c0 39 8e e3 38    	imul   $0x38e38e39,%eax,%eax
}
c0109255:	5d                   	pop    %ebp
c0109256:	c3                   	ret    

c0109257 <page2pa>:
page2pa(struct Page *page) {
c0109257:	55                   	push   %ebp
c0109258:	89 e5                	mov    %esp,%ebp
    return page2ppn(page) << PGSHIFT;
c010925a:	ff 75 08             	pushl  0x8(%ebp)
c010925d:	e8 db ff ff ff       	call   c010923d <page2ppn>
c0109262:	83 c4 04             	add    $0x4,%esp
c0109265:	c1 e0 0c             	shl    $0xc,%eax
}
c0109268:	c9                   	leave  
c0109269:	c3                   	ret    

c010926a <page2kva>:
page2kva(struct Page *page) {
c010926a:	55                   	push   %ebp
c010926b:	89 e5                	mov    %esp,%ebp
c010926d:	83 ec 18             	sub    $0x18,%esp
    return KADDR(page2pa(page));
c0109270:	ff 75 08             	pushl  0x8(%ebp)
c0109273:	e8 df ff ff ff       	call   c0109257 <page2pa>
c0109278:	83 c4 04             	add    $0x4,%esp
c010927b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010927e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109281:	c1 e8 0c             	shr    $0xc,%eax
c0109284:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109287:	a1 80 ef 12 c0       	mov    0xc012ef80,%eax
c010928c:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010928f:	72 14                	jb     c01092a5 <page2kva+0x3b>
c0109291:	ff 75 f4             	pushl  -0xc(%ebp)
c0109294:	68 18 cd 10 c0       	push   $0xc010cd18
c0109299:	6a 66                	push   $0x66
c010929b:	68 3b cd 10 c0       	push   $0xc010cd3b
c01092a0:	e8 49 85 ff ff       	call   c01017ee <__panic>
c01092a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01092a8:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c01092ad:	c9                   	leave  
c01092ae:	c3                   	ret    

c01092af <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
c01092af:	f3 0f 1e fb          	endbr32 
c01092b3:	55                   	push   %ebp
c01092b4:	89 e5                	mov    %esp,%ebp
c01092b6:	83 ec 08             	sub    $0x8,%esp
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
c01092b9:	83 ec 0c             	sub    $0xc,%esp
c01092bc:	6a 01                	push   $0x1
c01092be:	e8 05 92 ff ff       	call   c01024c8 <ide_device_valid>
c01092c3:	83 c4 10             	add    $0x10,%esp
c01092c6:	85 c0                	test   %eax,%eax
c01092c8:	75 14                	jne    c01092de <swapfs_init+0x2f>
        panic("swap fs isn't available.\n");
c01092ca:	83 ec 04             	sub    $0x4,%esp
c01092cd:	68 49 cd 10 c0       	push   $0xc010cd49
c01092d2:	6a 0d                	push   $0xd
c01092d4:	68 63 cd 10 c0       	push   $0xc010cd63
c01092d9:	e8 10 85 ff ff       	call   c01017ee <__panic>
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
c01092de:	83 ec 0c             	sub    $0xc,%esp
c01092e1:	6a 01                	push   $0x1
c01092e3:	e8 19 92 ff ff       	call   c0102501 <ide_device_size>
c01092e8:	83 c4 10             	add    $0x10,%esp
c01092eb:	c1 e8 03             	shr    $0x3,%eax
c01092ee:	a3 1c 11 13 c0       	mov    %eax,0xc013111c
}
c01092f3:	90                   	nop
c01092f4:	c9                   	leave  
c01092f5:	c3                   	ret    

c01092f6 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
c01092f6:	f3 0f 1e fb          	endbr32 
c01092fa:	55                   	push   %ebp
c01092fb:	89 e5                	mov    %esp,%ebp
c01092fd:	83 ec 18             	sub    $0x18,%esp
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c0109300:	83 ec 0c             	sub    $0xc,%esp
c0109303:	ff 75 0c             	pushl  0xc(%ebp)
c0109306:	e8 5f ff ff ff       	call   c010926a <page2kva>
c010930b:	83 c4 10             	add    $0x10,%esp
c010930e:	8b 55 08             	mov    0x8(%ebp),%edx
c0109311:	c1 ea 08             	shr    $0x8,%edx
c0109314:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0109317:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010931b:	74 0b                	je     c0109328 <swapfs_read+0x32>
c010931d:	8b 15 1c 11 13 c0    	mov    0xc013111c,%edx
c0109323:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c0109326:	72 14                	jb     c010933c <swapfs_read+0x46>
c0109328:	ff 75 08             	pushl  0x8(%ebp)
c010932b:	68 74 cd 10 c0       	push   $0xc010cd74
c0109330:	6a 14                	push   $0x14
c0109332:	68 63 cd 10 c0       	push   $0xc010cd63
c0109337:	e8 b2 84 ff ff       	call   c01017ee <__panic>
c010933c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010933f:	c1 e2 03             	shl    $0x3,%edx
c0109342:	6a 08                	push   $0x8
c0109344:	50                   	push   %eax
c0109345:	52                   	push   %edx
c0109346:	6a 01                	push   $0x1
c0109348:	e8 ed 91 ff ff       	call   c010253a <ide_read_secs>
c010934d:	83 c4 10             	add    $0x10,%esp
}
c0109350:	c9                   	leave  
c0109351:	c3                   	ret    

c0109352 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
c0109352:	f3 0f 1e fb          	endbr32 
c0109356:	55                   	push   %ebp
c0109357:	89 e5                	mov    %esp,%ebp
c0109359:	83 ec 18             	sub    $0x18,%esp
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c010935c:	83 ec 0c             	sub    $0xc,%esp
c010935f:	ff 75 0c             	pushl  0xc(%ebp)
c0109362:	e8 03 ff ff ff       	call   c010926a <page2kva>
c0109367:	83 c4 10             	add    $0x10,%esp
c010936a:	8b 55 08             	mov    0x8(%ebp),%edx
c010936d:	c1 ea 08             	shr    $0x8,%edx
c0109370:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0109373:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109377:	74 0b                	je     c0109384 <swapfs_write+0x32>
c0109379:	8b 15 1c 11 13 c0    	mov    0xc013111c,%edx
c010937f:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c0109382:	72 14                	jb     c0109398 <swapfs_write+0x46>
c0109384:	ff 75 08             	pushl  0x8(%ebp)
c0109387:	68 74 cd 10 c0       	push   $0xc010cd74
c010938c:	6a 19                	push   $0x19
c010938e:	68 63 cd 10 c0       	push   $0xc010cd63
c0109393:	e8 56 84 ff ff       	call   c01017ee <__panic>
c0109398:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010939b:	c1 e2 03             	shl    $0x3,%edx
c010939e:	6a 08                	push   $0x8
c01093a0:	50                   	push   %eax
c01093a1:	52                   	push   %edx
c01093a2:	6a 01                	push   $0x1
c01093a4:	e8 bc 93 ff ff       	call   c0102765 <ide_write_secs>
c01093a9:	83 c4 10             	add    $0x10,%esp
}
c01093ac:	c9                   	leave  
c01093ad:	c3                   	ret    

c01093ae <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)

    pushl %edx              # push arg
c01093ae:	52                   	push   %edx
    call *%ebx              # call fn
c01093af:	ff d3                	call   *%ebx

    pushl %eax              # save the return value of fn(arg)
c01093b1:	50                   	push   %eax
    call do_exit            # call do_exit to terminate current thread
c01093b2:	e8 46 08 00 00       	call   c0109bfd <do_exit>

c01093b7 <switch_to>:
.text
.globl switch_to
switch_to:                      # switch_to(from, to)

    # save from's registers
    movl 4(%esp), %eax          # eax points to from
c01093b7:	8b 44 24 04          	mov    0x4(%esp),%eax
    popl 0(%eax)                # save eip !popl
c01093bb:	8f 00                	popl   (%eax)
    movl %esp, 4(%eax)
c01093bd:	89 60 04             	mov    %esp,0x4(%eax)
    movl %ebx, 8(%eax)
c01093c0:	89 58 08             	mov    %ebx,0x8(%eax)
    movl %ecx, 12(%eax)
c01093c3:	89 48 0c             	mov    %ecx,0xc(%eax)
    movl %edx, 16(%eax)
c01093c6:	89 50 10             	mov    %edx,0x10(%eax)
    movl %esi, 20(%eax)
c01093c9:	89 70 14             	mov    %esi,0x14(%eax)
    movl %edi, 24(%eax)
c01093cc:	89 78 18             	mov    %edi,0x18(%eax)
    movl %ebp, 28(%eax)
c01093cf:	89 68 1c             	mov    %ebp,0x1c(%eax)

    # restore to's registers
    movl 4(%esp), %eax          # not 8(%esp): popped return address already
c01093d2:	8b 44 24 04          	mov    0x4(%esp),%eax
                                # eax now points to to
    movl 28(%eax), %ebp
c01093d6:	8b 68 1c             	mov    0x1c(%eax),%ebp
    movl 24(%eax), %edi
c01093d9:	8b 78 18             	mov    0x18(%eax),%edi
    movl 20(%eax), %esi
c01093dc:	8b 70 14             	mov    0x14(%eax),%esi
    movl 16(%eax), %edx
c01093df:	8b 50 10             	mov    0x10(%eax),%edx
    movl 12(%eax), %ecx
c01093e2:	8b 48 0c             	mov    0xc(%eax),%ecx
    movl 8(%eax), %ebx
c01093e5:	8b 58 08             	mov    0x8(%eax),%ebx
    movl 4(%eax), %esp
c01093e8:	8b 60 04             	mov    0x4(%eax),%esp

    pushl 0(%eax)               # push eip
c01093eb:	ff 30                	pushl  (%eax)

    ret
c01093ed:	c3                   	ret    

c01093ee <__intr_save>:
__intr_save(void) {
c01093ee:	55                   	push   %ebp
c01093ef:	89 e5                	mov    %esp,%ebp
c01093f1:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c01093f4:	9c                   	pushf  
c01093f5:	58                   	pop    %eax
c01093f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c01093f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c01093fc:	25 00 02 00 00       	and    $0x200,%eax
c0109401:	85 c0                	test   %eax,%eax
c0109403:	74 0c                	je     c0109411 <__intr_save+0x23>
        intr_disable();
c0109405:	e8 22 a1 ff ff       	call   c010352c <intr_disable>
        return 1;
c010940a:	b8 01 00 00 00       	mov    $0x1,%eax
c010940f:	eb 05                	jmp    c0109416 <__intr_save+0x28>
    return 0;
c0109411:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109416:	c9                   	leave  
c0109417:	c3                   	ret    

c0109418 <__intr_restore>:
__intr_restore(bool flag) {
c0109418:	55                   	push   %ebp
c0109419:	89 e5                	mov    %esp,%ebp
c010941b:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c010941e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0109422:	74 05                	je     c0109429 <__intr_restore+0x11>
        intr_enable();
c0109424:	e8 f7 a0 ff ff       	call   c0103520 <intr_enable>
}
c0109429:	90                   	nop
c010942a:	c9                   	leave  
c010942b:	c3                   	ret    

c010942c <page2ppn>:
page2ppn(struct Page *page) {
c010942c:	55                   	push   %ebp
c010942d:	89 e5                	mov    %esp,%ebp
    return page - pages;
c010942f:	a1 60 10 13 c0       	mov    0xc0131060,%eax
c0109434:	8b 55 08             	mov    0x8(%ebp),%edx
c0109437:	29 c2                	sub    %eax,%edx
c0109439:	89 d0                	mov    %edx,%eax
c010943b:	c1 f8 02             	sar    $0x2,%eax
c010943e:	69 c0 39 8e e3 38    	imul   $0x38e38e39,%eax,%eax
}
c0109444:	5d                   	pop    %ebp
c0109445:	c3                   	ret    

c0109446 <page2pa>:
page2pa(struct Page *page) {
c0109446:	55                   	push   %ebp
c0109447:	89 e5                	mov    %esp,%ebp
    return page2ppn(page) << PGSHIFT;
c0109449:	ff 75 08             	pushl  0x8(%ebp)
c010944c:	e8 db ff ff ff       	call   c010942c <page2ppn>
c0109451:	83 c4 04             	add    $0x4,%esp
c0109454:	c1 e0 0c             	shl    $0xc,%eax
}
c0109457:	c9                   	leave  
c0109458:	c3                   	ret    

c0109459 <pa2page>:
pa2page(uintptr_t pa) {
c0109459:	55                   	push   %ebp
c010945a:	89 e5                	mov    %esp,%ebp
c010945c:	83 ec 08             	sub    $0x8,%esp
    if (PPN(pa) >= npage) {
c010945f:	8b 45 08             	mov    0x8(%ebp),%eax
c0109462:	c1 e8 0c             	shr    $0xc,%eax
c0109465:	89 c2                	mov    %eax,%edx
c0109467:	a1 80 ef 12 c0       	mov    0xc012ef80,%eax
c010946c:	39 c2                	cmp    %eax,%edx
c010946e:	72 14                	jb     c0109484 <pa2page+0x2b>
        panic("pa2page called with invalid pa");
c0109470:	83 ec 04             	sub    $0x4,%esp
c0109473:	68 94 cd 10 c0       	push   $0xc010cd94
c0109478:	6a 5f                	push   $0x5f
c010947a:	68 b3 cd 10 c0       	push   $0xc010cdb3
c010947f:	e8 6a 83 ff ff       	call   c01017ee <__panic>
    return &pages[PPN(pa)];
c0109484:	8b 0d 60 10 13 c0    	mov    0xc0131060,%ecx
c010948a:	8b 45 08             	mov    0x8(%ebp),%eax
c010948d:	c1 e8 0c             	shr    $0xc,%eax
c0109490:	89 c2                	mov    %eax,%edx
c0109492:	89 d0                	mov    %edx,%eax
c0109494:	c1 e0 03             	shl    $0x3,%eax
c0109497:	01 d0                	add    %edx,%eax
c0109499:	c1 e0 02             	shl    $0x2,%eax
c010949c:	01 c8                	add    %ecx,%eax
}
c010949e:	c9                   	leave  
c010949f:	c3                   	ret    

c01094a0 <page2kva>:
page2kva(struct Page *page) {
c01094a0:	55                   	push   %ebp
c01094a1:	89 e5                	mov    %esp,%ebp
c01094a3:	83 ec 18             	sub    $0x18,%esp
    return KADDR(page2pa(page));
c01094a6:	ff 75 08             	pushl  0x8(%ebp)
c01094a9:	e8 98 ff ff ff       	call   c0109446 <page2pa>
c01094ae:	83 c4 04             	add    $0x4,%esp
c01094b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01094b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01094b7:	c1 e8 0c             	shr    $0xc,%eax
c01094ba:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01094bd:	a1 80 ef 12 c0       	mov    0xc012ef80,%eax
c01094c2:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01094c5:	72 14                	jb     c01094db <page2kva+0x3b>
c01094c7:	ff 75 f4             	pushl  -0xc(%ebp)
c01094ca:	68 c4 cd 10 c0       	push   $0xc010cdc4
c01094cf:	6a 66                	push   $0x66
c01094d1:	68 b3 cd 10 c0       	push   $0xc010cdb3
c01094d6:	e8 13 83 ff ff       	call   c01017ee <__panic>
c01094db:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01094de:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c01094e3:	c9                   	leave  
c01094e4:	c3                   	ret    

c01094e5 <kva2page>:
kva2page(void *kva) {
c01094e5:	55                   	push   %ebp
c01094e6:	89 e5                	mov    %esp,%ebp
c01094e8:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PADDR(kva));
c01094eb:	8b 45 08             	mov    0x8(%ebp),%eax
c01094ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01094f1:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01094f8:	77 14                	ja     c010950e <kva2page+0x29>
c01094fa:	ff 75 f4             	pushl  -0xc(%ebp)
c01094fd:	68 e8 cd 10 c0       	push   $0xc010cde8
c0109502:	6a 6b                	push   $0x6b
c0109504:	68 b3 cd 10 c0       	push   $0xc010cdb3
c0109509:	e8 e0 82 ff ff       	call   c01017ee <__panic>
c010950e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109511:	05 00 00 00 40       	add    $0x40000000,%eax
c0109516:	83 ec 0c             	sub    $0xc,%esp
c0109519:	50                   	push   %eax
c010951a:	e8 3a ff ff ff       	call   c0109459 <pa2page>
c010951f:	83 c4 10             	add    $0x10,%esp
}
c0109522:	c9                   	leave  
c0109523:	c3                   	ret    

c0109524 <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
c0109524:	f3 0f 1e fb          	endbr32 
c0109528:	55                   	push   %ebp
c0109529:	89 e5                	mov    %esp,%ebp
c010952b:	83 ec 18             	sub    $0x18,%esp
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
c010952e:	83 ec 0c             	sub    $0xc,%esp
c0109531:	6a 68                	push   $0x68
c0109533:	e8 c0 e6 ff ff       	call   c0107bf8 <kmalloc>
c0109538:	83 c4 10             	add    $0x10,%esp
c010953b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (proc != NULL) {
c010953e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109542:	0f 84 91 00 00 00    	je     c01095d9 <alloc_proc+0xb5>
     *       struct trapframe *tf;                       // Trap frame for current interrupt
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */
        proc->state = PROC_UNINIT;
c0109548:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010954b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        proc->pid = -1;
c0109551:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109554:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
        proc->runs = 0;
c010955b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010955e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        proc->kstack = 0;
c0109565:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109568:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        proc->need_resched = 0;
c010956f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109572:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        proc->parent = NULL;
c0109579:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010957c:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        proc->mm = NULL;
c0109583:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109586:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
        memset(&(proc->context), 0, sizeof(struct context));
c010958d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109590:	83 c0 1c             	add    $0x1c,%eax
c0109593:	83 ec 04             	sub    $0x4,%esp
c0109596:	6a 20                	push   $0x20
c0109598:	6a 00                	push   $0x0
c010959a:	50                   	push   %eax
c010959b:	e8 44 0d 00 00       	call   c010a2e4 <memset>
c01095a0:	83 c4 10             	add    $0x10,%esp
        proc->tf = NULL;
c01095a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01095a6:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
        proc->cr3 = boot_cr3;
c01095ad:	8b 15 5c 10 13 c0    	mov    0xc013105c,%edx
c01095b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01095b6:	89 50 40             	mov    %edx,0x40(%eax)
        proc->flags = 0;
c01095b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01095bc:	c7 40 44 00 00 00 00 	movl   $0x0,0x44(%eax)
        memset(proc->name, 0, PROC_NAME_LEN);
c01095c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01095c6:	83 c0 48             	add    $0x48,%eax
c01095c9:	83 ec 04             	sub    $0x4,%esp
c01095cc:	6a 0f                	push   $0xf
c01095ce:	6a 00                	push   $0x0
c01095d0:	50                   	push   %eax
c01095d1:	e8 0e 0d 00 00       	call   c010a2e4 <memset>
c01095d6:	83 c4 10             	add    $0x10,%esp
    }
    return proc;
c01095d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01095dc:	c9                   	leave  
c01095dd:	c3                   	ret    

c01095de <set_proc_name>:

// set_proc_name - set the name of proc
char *
set_proc_name(struct proc_struct *proc, const char *name) {
c01095de:	f3 0f 1e fb          	endbr32 
c01095e2:	55                   	push   %ebp
c01095e3:	89 e5                	mov    %esp,%ebp
c01095e5:	83 ec 08             	sub    $0x8,%esp
    memset(proc->name, 0, sizeof(proc->name));
c01095e8:	8b 45 08             	mov    0x8(%ebp),%eax
c01095eb:	83 c0 48             	add    $0x48,%eax
c01095ee:	83 ec 04             	sub    $0x4,%esp
c01095f1:	6a 10                	push   $0x10
c01095f3:	6a 00                	push   $0x0
c01095f5:	50                   	push   %eax
c01095f6:	e8 e9 0c 00 00       	call   c010a2e4 <memset>
c01095fb:	83 c4 10             	add    $0x10,%esp
    return memcpy(proc->name, name, PROC_NAME_LEN);
c01095fe:	8b 45 08             	mov    0x8(%ebp),%eax
c0109601:	83 c0 48             	add    $0x48,%eax
c0109604:	83 ec 04             	sub    $0x4,%esp
c0109607:	6a 0f                	push   $0xf
c0109609:	ff 75 0c             	pushl  0xc(%ebp)
c010960c:	50                   	push   %eax
c010960d:	e8 bc 0d 00 00       	call   c010a3ce <memcpy>
c0109612:	83 c4 10             	add    $0x10,%esp
}
c0109615:	c9                   	leave  
c0109616:	c3                   	ret    

c0109617 <get_proc_name>:

// get_proc_name - get the name of proc
char *
get_proc_name(struct proc_struct *proc) {
c0109617:	f3 0f 1e fb          	endbr32 
c010961b:	55                   	push   %ebp
c010961c:	89 e5                	mov    %esp,%ebp
c010961e:	83 ec 08             	sub    $0x8,%esp
    static char name[PROC_NAME_LEN + 1];
    memset(name, 0, sizeof(name));
c0109621:	83 ec 04             	sub    $0x4,%esp
c0109624:	6a 10                	push   $0x10
c0109626:	6a 00                	push   $0x0
c0109628:	68 44 10 13 c0       	push   $0xc0131044
c010962d:	e8 b2 0c 00 00       	call   c010a2e4 <memset>
c0109632:	83 c4 10             	add    $0x10,%esp
    return memcpy(name, proc->name, PROC_NAME_LEN);
c0109635:	8b 45 08             	mov    0x8(%ebp),%eax
c0109638:	83 c0 48             	add    $0x48,%eax
c010963b:	83 ec 04             	sub    $0x4,%esp
c010963e:	6a 0f                	push   $0xf
c0109640:	50                   	push   %eax
c0109641:	68 44 10 13 c0       	push   $0xc0131044
c0109646:	e8 83 0d 00 00       	call   c010a3ce <memcpy>
c010964b:	83 c4 10             	add    $0x10,%esp
}
c010964e:	c9                   	leave  
c010964f:	c3                   	ret    

c0109650 <get_pid>:

// get_pid - alloc a unique pid for process
static int
get_pid(void) {
c0109650:	f3 0f 1e fb          	endbr32 
c0109654:	55                   	push   %ebp
c0109655:	89 e5                	mov    %esp,%ebp
c0109657:	83 ec 10             	sub    $0x10,%esp
    static_assert(MAX_PID > MAX_PROCESS);
    struct proc_struct *proc;
    list_entry_t *list = &proc_list, *le;
c010965a:	c7 45 f8 58 11 13 c0 	movl   $0xc0131158,-0x8(%ebp)
    static int next_safe = MAX_PID, last_pid = MAX_PID;
    if (++ last_pid >= MAX_PID) {
c0109661:	a1 80 ba 12 c0       	mov    0xc012ba80,%eax
c0109666:	83 c0 01             	add    $0x1,%eax
c0109669:	a3 80 ba 12 c0       	mov    %eax,0xc012ba80
c010966e:	a1 80 ba 12 c0       	mov    0xc012ba80,%eax
c0109673:	3d ff 1f 00 00       	cmp    $0x1fff,%eax
c0109678:	7e 0c                	jle    c0109686 <get_pid+0x36>
        last_pid = 1;
c010967a:	c7 05 80 ba 12 c0 01 	movl   $0x1,0xc012ba80
c0109681:	00 00 00 
        goto inside;
c0109684:	eb 14                	jmp    c010969a <get_pid+0x4a>
    }
    if (last_pid >= next_safe) {
c0109686:	8b 15 80 ba 12 c0    	mov    0xc012ba80,%edx
c010968c:	a1 84 ba 12 c0       	mov    0xc012ba84,%eax
c0109691:	39 c2                	cmp    %eax,%edx
c0109693:	0f 8c ad 00 00 00    	jl     c0109746 <get_pid+0xf6>
    inside:
c0109699:	90                   	nop
        next_safe = MAX_PID;
c010969a:	c7 05 84 ba 12 c0 00 	movl   $0x2000,0xc012ba84
c01096a1:	20 00 00 
    repeat:
        le = list;
c01096a4:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01096a7:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while ((le = list_next(le)) != list) {
c01096aa:	eb 7f                	jmp    c010972b <get_pid+0xdb>
            proc = le2proc(le, list_link);
c01096ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01096af:	83 e8 58             	sub    $0x58,%eax
c01096b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (proc->pid == last_pid) {
c01096b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01096b8:	8b 50 04             	mov    0x4(%eax),%edx
c01096bb:	a1 80 ba 12 c0       	mov    0xc012ba80,%eax
c01096c0:	39 c2                	cmp    %eax,%edx
c01096c2:	75 3e                	jne    c0109702 <get_pid+0xb2>
                if (++ last_pid >= next_safe) {
c01096c4:	a1 80 ba 12 c0       	mov    0xc012ba80,%eax
c01096c9:	83 c0 01             	add    $0x1,%eax
c01096cc:	a3 80 ba 12 c0       	mov    %eax,0xc012ba80
c01096d1:	8b 15 80 ba 12 c0    	mov    0xc012ba80,%edx
c01096d7:	a1 84 ba 12 c0       	mov    0xc012ba84,%eax
c01096dc:	39 c2                	cmp    %eax,%edx
c01096de:	7c 4b                	jl     c010972b <get_pid+0xdb>
                    if (last_pid >= MAX_PID) {
c01096e0:	a1 80 ba 12 c0       	mov    0xc012ba80,%eax
c01096e5:	3d ff 1f 00 00       	cmp    $0x1fff,%eax
c01096ea:	7e 0a                	jle    c01096f6 <get_pid+0xa6>
                        last_pid = 1;
c01096ec:	c7 05 80 ba 12 c0 01 	movl   $0x1,0xc012ba80
c01096f3:	00 00 00 
                    }
                    next_safe = MAX_PID;
c01096f6:	c7 05 84 ba 12 c0 00 	movl   $0x2000,0xc012ba84
c01096fd:	20 00 00 
                    goto repeat;
c0109700:	eb a2                	jmp    c01096a4 <get_pid+0x54>
                }
            }
            else if (proc->pid > last_pid && next_safe > proc->pid) {
c0109702:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109705:	8b 50 04             	mov    0x4(%eax),%edx
c0109708:	a1 80 ba 12 c0       	mov    0xc012ba80,%eax
c010970d:	39 c2                	cmp    %eax,%edx
c010970f:	7e 1a                	jle    c010972b <get_pid+0xdb>
c0109711:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109714:	8b 50 04             	mov    0x4(%eax),%edx
c0109717:	a1 84 ba 12 c0       	mov    0xc012ba84,%eax
c010971c:	39 c2                	cmp    %eax,%edx
c010971e:	7d 0b                	jge    c010972b <get_pid+0xdb>
                next_safe = proc->pid;
c0109720:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109723:	8b 40 04             	mov    0x4(%eax),%eax
c0109726:	a3 84 ba 12 c0       	mov    %eax,0xc012ba84
c010972b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010972e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109731:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109734:	8b 40 04             	mov    0x4(%eax),%eax
        while ((le = list_next(le)) != list) {
c0109737:	89 45 fc             	mov    %eax,-0x4(%ebp)
c010973a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010973d:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c0109740:	0f 85 66 ff ff ff    	jne    c01096ac <get_pid+0x5c>
            }
        }
    }
    return last_pid;
c0109746:	a1 80 ba 12 c0       	mov    0xc012ba80,%eax
}
c010974b:	c9                   	leave  
c010974c:	c3                   	ret    

c010974d <proc_run>:

// proc_run - make process "proc" running on cpu
// NOTE: before call switch_to, should load  base addr of "proc"'s new PDT
void
proc_run(struct proc_struct *proc) {
c010974d:	f3 0f 1e fb          	endbr32 
c0109751:	55                   	push   %ebp
c0109752:	89 e5                	mov    %esp,%ebp
c0109754:	83 ec 18             	sub    $0x18,%esp
    if (proc != current) {
c0109757:	a1 28 f0 12 c0       	mov    0xc012f028,%eax
c010975c:	39 45 08             	cmp    %eax,0x8(%ebp)
c010975f:	74 6c                	je     c01097cd <proc_run+0x80>
        bool intr_flag;
        struct proc_struct *prev = current, *next = proc;
c0109761:	a1 28 f0 12 c0       	mov    0xc012f028,%eax
c0109766:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109769:	8b 45 08             	mov    0x8(%ebp),%eax
c010976c:	89 45 f0             	mov    %eax,-0x10(%ebp)
        local_intr_save(intr_flag);
c010976f:	e8 7a fc ff ff       	call   c01093ee <__intr_save>
c0109774:	89 45 ec             	mov    %eax,-0x14(%ebp)
        {
            current = proc;
c0109777:	8b 45 08             	mov    0x8(%ebp),%eax
c010977a:	a3 28 f0 12 c0       	mov    %eax,0xc012f028
            load_esp0(next->kstack + KSTACKSIZE);
c010977f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109782:	8b 40 0c             	mov    0xc(%eax),%eax
c0109785:	05 00 20 00 00       	add    $0x2000,%eax
c010978a:	83 ec 0c             	sub    $0xc,%esp
c010978d:	50                   	push   %eax
c010978e:	e8 7a b0 ff ff       	call   c010480d <load_esp0>
c0109793:	83 c4 10             	add    $0x10,%esp
            lcr3(next->cr3);
c0109796:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109799:	8b 40 40             	mov    0x40(%eax),%eax
c010979c:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("mov %0, %%cr3" :: "r" (cr3) : "memory");
c010979f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01097a2:	0f 22 d8             	mov    %eax,%cr3
}
c01097a5:	90                   	nop
            switch_to(&(prev->context), &(next->context));
c01097a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01097a9:	8d 50 1c             	lea    0x1c(%eax),%edx
c01097ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01097af:	83 c0 1c             	add    $0x1c,%eax
c01097b2:	83 ec 08             	sub    $0x8,%esp
c01097b5:	52                   	push   %edx
c01097b6:	50                   	push   %eax
c01097b7:	e8 fb fb ff ff       	call   c01093b7 <switch_to>
c01097bc:	83 c4 10             	add    $0x10,%esp
        }
        local_intr_restore(intr_flag);
c01097bf:	83 ec 0c             	sub    $0xc,%esp
c01097c2:	ff 75 ec             	pushl  -0x14(%ebp)
c01097c5:	e8 4e fc ff ff       	call   c0109418 <__intr_restore>
c01097ca:	83 c4 10             	add    $0x10,%esp
    }
}
c01097cd:	90                   	nop
c01097ce:	c9                   	leave  
c01097cf:	c3                   	ret    

c01097d0 <forkret>:

// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
c01097d0:	f3 0f 1e fb          	endbr32 
c01097d4:	55                   	push   %ebp
c01097d5:	89 e5                	mov    %esp,%ebp
c01097d7:	83 ec 08             	sub    $0x8,%esp
    forkrets(current->tf);
c01097da:	a1 28 f0 12 c0       	mov    0xc012f028,%eax
c01097df:	8b 40 3c             	mov    0x3c(%eax),%eax
c01097e2:	83 ec 0c             	sub    $0xc,%esp
c01097e5:	50                   	push   %eax
c01097e6:	e8 53 ae ff ff       	call   c010463e <forkrets>
c01097eb:	83 c4 10             	add    $0x10,%esp
}
c01097ee:	90                   	nop
c01097ef:	c9                   	leave  
c01097f0:	c3                   	ret    

c01097f1 <hash_proc>:

// hash_proc - add proc into proc hash_list
static void
hash_proc(struct proc_struct *proc) {
c01097f1:	f3 0f 1e fb          	endbr32 
c01097f5:	55                   	push   %ebp
c01097f6:	89 e5                	mov    %esp,%ebp
c01097f8:	53                   	push   %ebx
c01097f9:	83 ec 24             	sub    $0x24,%esp
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
c01097fc:	8b 45 08             	mov    0x8(%ebp),%eax
c01097ff:	8d 58 60             	lea    0x60(%eax),%ebx
c0109802:	8b 45 08             	mov    0x8(%ebp),%eax
c0109805:	8b 40 04             	mov    0x4(%eax),%eax
c0109808:	83 ec 08             	sub    $0x8,%esp
c010980b:	6a 0a                	push   $0xa
c010980d:	50                   	push   %eax
c010980e:	e8 92 12 00 00       	call   c010aaa5 <hash32>
c0109813:	83 c4 10             	add    $0x10,%esp
c0109816:	c1 e0 03             	shl    $0x3,%eax
c0109819:	05 40 f0 12 c0       	add    $0xc012f040,%eax
c010981e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109821:	89 5d f0             	mov    %ebx,-0x10(%ebp)
c0109824:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109827:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010982a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010982d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    __list_add(elm, listelm, listelm->next);
c0109830:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109833:	8b 40 04             	mov    0x4(%eax),%eax
c0109836:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0109839:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010983c:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010983f:	89 55 e0             	mov    %edx,-0x20(%ebp)
c0109842:	89 45 dc             	mov    %eax,-0x24(%ebp)
    prev->next = next->prev = elm;
c0109845:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0109848:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010984b:	89 10                	mov    %edx,(%eax)
c010984d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0109850:	8b 10                	mov    (%eax),%edx
c0109852:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109855:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0109858:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010985b:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010985e:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0109861:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109864:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0109867:	89 10                	mov    %edx,(%eax)
}
c0109869:	90                   	nop
}
c010986a:	90                   	nop
}
c010986b:	90                   	nop
}
c010986c:	90                   	nop
c010986d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0109870:	c9                   	leave  
c0109871:	c3                   	ret    

c0109872 <find_proc>:

// find_proc - find proc frome proc hash_list according to pid
struct proc_struct *
find_proc(int pid) {
c0109872:	f3 0f 1e fb          	endbr32 
c0109876:	55                   	push   %ebp
c0109877:	89 e5                	mov    %esp,%ebp
c0109879:	83 ec 18             	sub    $0x18,%esp
    if (0 < pid && pid < MAX_PID) {
c010987c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0109880:	7e 5d                	jle    c01098df <find_proc+0x6d>
c0109882:	81 7d 08 ff 1f 00 00 	cmpl   $0x1fff,0x8(%ebp)
c0109889:	7f 54                	jg     c01098df <find_proc+0x6d>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
c010988b:	8b 45 08             	mov    0x8(%ebp),%eax
c010988e:	83 ec 08             	sub    $0x8,%esp
c0109891:	6a 0a                	push   $0xa
c0109893:	50                   	push   %eax
c0109894:	e8 0c 12 00 00       	call   c010aaa5 <hash32>
c0109899:	83 c4 10             	add    $0x10,%esp
c010989c:	c1 e0 03             	shl    $0x3,%eax
c010989f:	05 40 f0 12 c0       	add    $0xc012f040,%eax
c01098a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01098a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01098aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
        while ((le = list_next(le)) != list) {
c01098ad:	eb 19                	jmp    c01098c8 <find_proc+0x56>
            struct proc_struct *proc = le2proc(le, hash_link);
c01098af:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01098b2:	83 e8 60             	sub    $0x60,%eax
c01098b5:	89 45 ec             	mov    %eax,-0x14(%ebp)
            if (proc->pid == pid) {
c01098b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01098bb:	8b 40 04             	mov    0x4(%eax),%eax
c01098be:	39 45 08             	cmp    %eax,0x8(%ebp)
c01098c1:	75 05                	jne    c01098c8 <find_proc+0x56>
                return proc;
c01098c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01098c6:	eb 1c                	jmp    c01098e4 <find_proc+0x72>
c01098c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01098cb:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return listelm->next;
c01098ce:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01098d1:	8b 40 04             	mov    0x4(%eax),%eax
        while ((le = list_next(le)) != list) {
c01098d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01098d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01098da:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01098dd:	75 d0                	jne    c01098af <find_proc+0x3d>
            }
        }
    }
    return NULL;
c01098df:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01098e4:	c9                   	leave  
c01098e5:	c3                   	ret    

c01098e6 <kernel_thread>:

// kernel_thread - create a kernel thread using "fn" function
// NOTE: the contents of temp trapframe tf will be copied to 
//       proc->tf in do_fork-->copy_thread function
int
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
c01098e6:	f3 0f 1e fb          	endbr32 
c01098ea:	55                   	push   %ebp
c01098eb:	89 e5                	mov    %esp,%ebp
c01098ed:	83 ec 58             	sub    $0x58,%esp
    struct trapframe tf;
    memset(&tf, 0, sizeof(struct trapframe));
c01098f0:	83 ec 04             	sub    $0x4,%esp
c01098f3:	6a 4c                	push   $0x4c
c01098f5:	6a 00                	push   $0x0
c01098f7:	8d 45 ac             	lea    -0x54(%ebp),%eax
c01098fa:	50                   	push   %eax
c01098fb:	e8 e4 09 00 00       	call   c010a2e4 <memset>
c0109900:	83 c4 10             	add    $0x10,%esp
    tf.tf_cs = KERNEL_CS;
c0109903:	66 c7 45 e8 08 00    	movw   $0x8,-0x18(%ebp)
    tf.tf_ds = tf.tf_es = tf.tf_ss = KERNEL_DS;
c0109909:	66 c7 45 f4 10 00    	movw   $0x10,-0xc(%ebp)
c010990f:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0109913:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
c0109917:	0f b7 45 d4          	movzwl -0x2c(%ebp),%eax
c010991b:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
    tf.tf_regs.reg_ebx = (uint32_t)fn;
c010991f:	8b 45 08             	mov    0x8(%ebp),%eax
c0109922:	89 45 bc             	mov    %eax,-0x44(%ebp)
    tf.tf_regs.reg_edx = (uint32_t)arg;
c0109925:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109928:	89 45 c0             	mov    %eax,-0x40(%ebp)
    tf.tf_eip = (uint32_t)kernel_thread_entry;
c010992b:	b8 ae 93 10 c0       	mov    $0xc01093ae,%eax
c0109930:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
c0109933:	8b 45 10             	mov    0x10(%ebp),%eax
c0109936:	80 cc 01             	or     $0x1,%ah
c0109939:	89 c2                	mov    %eax,%edx
c010993b:	83 ec 04             	sub    $0x4,%esp
c010993e:	8d 45 ac             	lea    -0x54(%ebp),%eax
c0109941:	50                   	push   %eax
c0109942:	6a 00                	push   $0x0
c0109944:	52                   	push   %edx
c0109945:	e8 4c 01 00 00       	call   c0109a96 <do_fork>
c010994a:	83 c4 10             	add    $0x10,%esp
}
c010994d:	c9                   	leave  
c010994e:	c3                   	ret    

c010994f <setup_kstack>:

// setup_kstack - alloc pages with size KSTACKPAGE as process kernel stack
static int
setup_kstack(struct proc_struct *proc) {
c010994f:	f3 0f 1e fb          	endbr32 
c0109953:	55                   	push   %ebp
c0109954:	89 e5                	mov    %esp,%ebp
c0109956:	83 ec 18             	sub    $0x18,%esp
    struct Page *page = alloc_pages(KSTACKPAGE);
c0109959:	83 ec 0c             	sub    $0xc,%esp
c010995c:	6a 02                	push   $0x2
c010995e:	e8 0f b0 ff ff       	call   c0104972 <alloc_pages>
c0109963:	83 c4 10             	add    $0x10,%esp
c0109966:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c0109969:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010996d:	74 1d                	je     c010998c <setup_kstack+0x3d>
        proc->kstack = (uintptr_t)page2kva(page);
c010996f:	83 ec 0c             	sub    $0xc,%esp
c0109972:	ff 75 f4             	pushl  -0xc(%ebp)
c0109975:	e8 26 fb ff ff       	call   c01094a0 <page2kva>
c010997a:	83 c4 10             	add    $0x10,%esp
c010997d:	89 c2                	mov    %eax,%edx
c010997f:	8b 45 08             	mov    0x8(%ebp),%eax
c0109982:	89 50 0c             	mov    %edx,0xc(%eax)
        return 0;
c0109985:	b8 00 00 00 00       	mov    $0x0,%eax
c010998a:	eb 05                	jmp    c0109991 <setup_kstack+0x42>
    }
    return -E_NO_MEM;
c010998c:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
}
c0109991:	c9                   	leave  
c0109992:	c3                   	ret    

c0109993 <put_kstack>:

// put_kstack - free the memory space of process kernel stack
static void
put_kstack(struct proc_struct *proc) {
c0109993:	f3 0f 1e fb          	endbr32 
c0109997:	55                   	push   %ebp
c0109998:	89 e5                	mov    %esp,%ebp
c010999a:	83 ec 08             	sub    $0x8,%esp
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
c010999d:	8b 45 08             	mov    0x8(%ebp),%eax
c01099a0:	8b 40 0c             	mov    0xc(%eax),%eax
c01099a3:	83 ec 0c             	sub    $0xc,%esp
c01099a6:	50                   	push   %eax
c01099a7:	e8 39 fb ff ff       	call   c01094e5 <kva2page>
c01099ac:	83 c4 10             	add    $0x10,%esp
c01099af:	83 ec 08             	sub    $0x8,%esp
c01099b2:	6a 02                	push   $0x2
c01099b4:	50                   	push   %eax
c01099b5:	e8 28 b0 ff ff       	call   c01049e2 <free_pages>
c01099ba:	83 c4 10             	add    $0x10,%esp
}
c01099bd:	90                   	nop
c01099be:	c9                   	leave  
c01099bf:	c3                   	ret    

c01099c0 <copy_mm>:

// copy_mm - process "proc" duplicate OR share process "current"'s mm according clone_flags
//         - if clone_flags & CLONE_VM, then "share" ; else "duplicate"
static int
copy_mm(uint32_t clone_flags, struct proc_struct *proc) {
c01099c0:	f3 0f 1e fb          	endbr32 
c01099c4:	55                   	push   %ebp
c01099c5:	89 e5                	mov    %esp,%ebp
c01099c7:	83 ec 08             	sub    $0x8,%esp
    assert(current->mm == NULL);
c01099ca:	a1 28 f0 12 c0       	mov    0xc012f028,%eax
c01099cf:	8b 40 18             	mov    0x18(%eax),%eax
c01099d2:	85 c0                	test   %eax,%eax
c01099d4:	74 19                	je     c01099ef <copy_mm+0x2f>
c01099d6:	68 0c ce 10 c0       	push   $0xc010ce0c
c01099db:	68 20 ce 10 c0       	push   $0xc010ce20
c01099e0:	68 fe 00 00 00       	push   $0xfe
c01099e5:	68 35 ce 10 c0       	push   $0xc010ce35
c01099ea:	e8 ff 7d ff ff       	call   c01017ee <__panic>
    /* do nothing in this project */
    return 0;
c01099ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01099f4:	c9                   	leave  
c01099f5:	c3                   	ret    

c01099f6 <copy_thread>:

// copy_thread - setup the trapframe on the  process's kernel stack top and
//             - setup the kernel entry point and stack of process
static void
copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf) {
c01099f6:	f3 0f 1e fb          	endbr32 
c01099fa:	55                   	push   %ebp
c01099fb:	89 e5                	mov    %esp,%ebp
c01099fd:	57                   	push   %edi
c01099fe:	56                   	push   %esi
c01099ff:	53                   	push   %ebx
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
c0109a00:	8b 45 08             	mov    0x8(%ebp),%eax
c0109a03:	8b 40 0c             	mov    0xc(%eax),%eax
c0109a06:	05 b4 1f 00 00       	add    $0x1fb4,%eax
c0109a0b:	89 c2                	mov    %eax,%edx
c0109a0d:	8b 45 08             	mov    0x8(%ebp),%eax
c0109a10:	89 50 3c             	mov    %edx,0x3c(%eax)
    *(proc->tf) = *tf;
c0109a13:	8b 45 08             	mov    0x8(%ebp),%eax
c0109a16:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109a19:	8b 55 10             	mov    0x10(%ebp),%edx
c0109a1c:	89 d3                	mov    %edx,%ebx
c0109a1e:	ba 4c 00 00 00       	mov    $0x4c,%edx
c0109a23:	8b 0b                	mov    (%ebx),%ecx
c0109a25:	89 08                	mov    %ecx,(%eax)
c0109a27:	8b 4c 13 fc          	mov    -0x4(%ebx,%edx,1),%ecx
c0109a2b:	89 4c 10 fc          	mov    %ecx,-0x4(%eax,%edx,1)
c0109a2f:	8d 78 04             	lea    0x4(%eax),%edi
c0109a32:	83 e7 fc             	and    $0xfffffffc,%edi
c0109a35:	29 f8                	sub    %edi,%eax
c0109a37:	29 c3                	sub    %eax,%ebx
c0109a39:	01 c2                	add    %eax,%edx
c0109a3b:	83 e2 fc             	and    $0xfffffffc,%edx
c0109a3e:	89 d0                	mov    %edx,%eax
c0109a40:	c1 e8 02             	shr    $0x2,%eax
c0109a43:	89 de                	mov    %ebx,%esi
c0109a45:	89 c1                	mov    %eax,%ecx
c0109a47:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
    proc->tf->tf_regs.reg_eax = 0;
c0109a49:	8b 45 08             	mov    0x8(%ebp),%eax
c0109a4c:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109a4f:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
    proc->tf->tf_esp = esp;
c0109a56:	8b 45 08             	mov    0x8(%ebp),%eax
c0109a59:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109a5c:	8b 55 0c             	mov    0xc(%ebp),%edx
c0109a5f:	89 50 44             	mov    %edx,0x44(%eax)
    proc->tf->tf_eflags |= FL_IF;
c0109a62:	8b 45 08             	mov    0x8(%ebp),%eax
c0109a65:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109a68:	8b 50 40             	mov    0x40(%eax),%edx
c0109a6b:	8b 45 08             	mov    0x8(%ebp),%eax
c0109a6e:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109a71:	80 ce 02             	or     $0x2,%dh
c0109a74:	89 50 40             	mov    %edx,0x40(%eax)

    proc->context.eip = (uintptr_t)forkret;
c0109a77:	ba d0 97 10 c0       	mov    $0xc01097d0,%edx
c0109a7c:	8b 45 08             	mov    0x8(%ebp),%eax
c0109a7f:	89 50 1c             	mov    %edx,0x1c(%eax)
    proc->context.esp = (uintptr_t)(proc->tf);
c0109a82:	8b 45 08             	mov    0x8(%ebp),%eax
c0109a85:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109a88:	89 c2                	mov    %eax,%edx
c0109a8a:	8b 45 08             	mov    0x8(%ebp),%eax
c0109a8d:	89 50 20             	mov    %edx,0x20(%eax)
}
c0109a90:	90                   	nop
c0109a91:	5b                   	pop    %ebx
c0109a92:	5e                   	pop    %esi
c0109a93:	5f                   	pop    %edi
c0109a94:	5d                   	pop    %ebp
c0109a95:	c3                   	ret    

c0109a96 <do_fork>:
 * @clone_flags: used to guide how to clone the child process
 * @stack:       the parent's user stack pointer. if stack==0, It means to fork a kernel thread.
 * @tf:          the trapframe info, which will be copied to child process's proc->tf
 */
int
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
c0109a96:	f3 0f 1e fb          	endbr32 
c0109a9a:	55                   	push   %ebp
c0109a9b:	89 e5                	mov    %esp,%ebp
c0109a9d:	83 ec 38             	sub    $0x38,%esp
    int ret = -E_NO_FREE_PROC;
c0109aa0:	c7 45 f4 fb ff ff ff 	movl   $0xfffffffb,-0xc(%ebp)
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS) {
c0109aa7:	a1 40 10 13 c0       	mov    0xc0131040,%eax
c0109aac:	3d ff 0f 00 00       	cmp    $0xfff,%eax
c0109ab1:	0f 8f 15 01 00 00    	jg     c0109bcc <do_fork+0x136>
        goto fork_out;
    }
    ret = -E_NO_MEM;
c0109ab7:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)
    //    3. call copy_mm to dup OR share mm according clone_flag
    //    4. call copy_thread to setup tf & context in proc_struct
    //    5. insert proc_struct into hash_list && proc_list
    //    6. call wakeup_proc to make the new child process RUNNABLE
    //    7. set ret vaule using child proc's pid
    if ((proc = alloc_proc()) == NULL) {
c0109abe:	e8 61 fa ff ff       	call   c0109524 <alloc_proc>
c0109ac3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109ac6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0109aca:	0f 84 ff 00 00 00    	je     c0109bcf <do_fork+0x139>
        goto fork_out;
    }

    proc->parent = current;
c0109ad0:	8b 15 28 f0 12 c0    	mov    0xc012f028,%edx
c0109ad6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109ad9:	89 50 14             	mov    %edx,0x14(%eax)

    if (setup_kstack(proc) != 0) {
c0109adc:	83 ec 0c             	sub    $0xc,%esp
c0109adf:	ff 75 f0             	pushl  -0x10(%ebp)
c0109ae2:	e8 68 fe ff ff       	call   c010994f <setup_kstack>
c0109ae7:	83 c4 10             	add    $0x10,%esp
c0109aea:	85 c0                	test   %eax,%eax
c0109aec:	0f 85 f8 00 00 00    	jne    c0109bea <do_fork+0x154>
        goto bad_fork_cleanup_proc;
    }
    if (copy_mm(clone_flags, proc) != 0) {
c0109af2:	83 ec 08             	sub    $0x8,%esp
c0109af5:	ff 75 f0             	pushl  -0x10(%ebp)
c0109af8:	ff 75 08             	pushl  0x8(%ebp)
c0109afb:	e8 c0 fe ff ff       	call   c01099c0 <copy_mm>
c0109b00:	83 c4 10             	add    $0x10,%esp
c0109b03:	85 c0                	test   %eax,%eax
c0109b05:	0f 85 ca 00 00 00    	jne    c0109bd5 <do_fork+0x13f>
        goto bad_fork_cleanup_kstack;
    }
    copy_thread(proc, stack, tf);
c0109b0b:	83 ec 04             	sub    $0x4,%esp
c0109b0e:	ff 75 10             	pushl  0x10(%ebp)
c0109b11:	ff 75 0c             	pushl  0xc(%ebp)
c0109b14:	ff 75 f0             	pushl  -0x10(%ebp)
c0109b17:	e8 da fe ff ff       	call   c01099f6 <copy_thread>
c0109b1c:	83 c4 10             	add    $0x10,%esp

    bool intr_flag;
    local_intr_save(intr_flag);
c0109b1f:	e8 ca f8 ff ff       	call   c01093ee <__intr_save>
c0109b24:	89 45 ec             	mov    %eax,-0x14(%ebp)
    {
        proc->pid = get_pid();
c0109b27:	e8 24 fb ff ff       	call   c0109650 <get_pid>
c0109b2c:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0109b2f:	89 42 04             	mov    %eax,0x4(%edx)
        hash_proc(proc);
c0109b32:	83 ec 0c             	sub    $0xc,%esp
c0109b35:	ff 75 f0             	pushl  -0x10(%ebp)
c0109b38:	e8 b4 fc ff ff       	call   c01097f1 <hash_proc>
c0109b3d:	83 c4 10             	add    $0x10,%esp
        list_add(&proc_list, &(proc->list_link));
c0109b40:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109b43:	83 c0 58             	add    $0x58,%eax
c0109b46:	c7 45 e8 58 11 13 c0 	movl   $0xc0131158,-0x18(%ebp)
c0109b4d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0109b50:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109b53:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0109b56:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109b59:	89 45 dc             	mov    %eax,-0x24(%ebp)
    __list_add(elm, listelm, listelm->next);
c0109b5c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109b5f:	8b 40 04             	mov    0x4(%eax),%eax
c0109b62:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0109b65:	89 55 d8             	mov    %edx,-0x28(%ebp)
c0109b68:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0109b6b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0109b6e:	89 45 d0             	mov    %eax,-0x30(%ebp)
    prev->next = next->prev = elm;
c0109b71:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0109b74:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0109b77:	89 10                	mov    %edx,(%eax)
c0109b79:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0109b7c:	8b 10                	mov    (%eax),%edx
c0109b7e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0109b81:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0109b84:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0109b87:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0109b8a:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0109b8d:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0109b90:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0109b93:	89 10                	mov    %edx,(%eax)
}
c0109b95:	90                   	nop
}
c0109b96:	90                   	nop
}
c0109b97:	90                   	nop
        nr_process ++;
c0109b98:	a1 40 10 13 c0       	mov    0xc0131040,%eax
c0109b9d:	83 c0 01             	add    $0x1,%eax
c0109ba0:	a3 40 10 13 c0       	mov    %eax,0xc0131040
    }
    local_intr_restore(intr_flag);
c0109ba5:	83 ec 0c             	sub    $0xc,%esp
c0109ba8:	ff 75 ec             	pushl  -0x14(%ebp)
c0109bab:	e8 68 f8 ff ff       	call   c0109418 <__intr_restore>
c0109bb0:	83 c4 10             	add    $0x10,%esp

    wakeup_proc(proc);
c0109bb3:	83 ec 0c             	sub    $0xc,%esp
c0109bb6:	ff 75 f0             	pushl  -0x10(%ebp)
c0109bb9:	e8 c1 02 00 00       	call   c0109e7f <wakeup_proc>
c0109bbe:	83 c4 10             	add    $0x10,%esp

    ret = proc->pid;
c0109bc1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109bc4:	8b 40 04             	mov    0x4(%eax),%eax
c0109bc7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109bca:	eb 04                	jmp    c0109bd0 <do_fork+0x13a>
        goto fork_out;
c0109bcc:	90                   	nop
c0109bcd:	eb 01                	jmp    c0109bd0 <do_fork+0x13a>
        goto fork_out;
c0109bcf:	90                   	nop
fork_out:
    return ret;
c0109bd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109bd3:	eb 26                	jmp    c0109bfb <do_fork+0x165>
        goto bad_fork_cleanup_kstack;
c0109bd5:	90                   	nop
c0109bd6:	f3 0f 1e fb          	endbr32 

bad_fork_cleanup_kstack:
    put_kstack(proc);
c0109bda:	83 ec 0c             	sub    $0xc,%esp
c0109bdd:	ff 75 f0             	pushl  -0x10(%ebp)
c0109be0:	e8 ae fd ff ff       	call   c0109993 <put_kstack>
c0109be5:	83 c4 10             	add    $0x10,%esp
c0109be8:	eb 01                	jmp    c0109beb <do_fork+0x155>
        goto bad_fork_cleanup_proc;
c0109bea:	90                   	nop
bad_fork_cleanup_proc:
    kfree(proc);
c0109beb:	83 ec 0c             	sub    $0xc,%esp
c0109bee:	ff 75 f0             	pushl  -0x10(%ebp)
c0109bf1:	e8 1e e0 ff ff       	call   c0107c14 <kfree>
c0109bf6:	83 c4 10             	add    $0x10,%esp
    goto fork_out;
c0109bf9:	eb d5                	jmp    c0109bd0 <do_fork+0x13a>
}
c0109bfb:	c9                   	leave  
c0109bfc:	c3                   	ret    

c0109bfd <do_exit>:
// do_exit - called by sys_exit
//   1. call exit_mmap & put_pgdir & mm_destroy to free the almost all memory space of process
//   2. set process' state as PROC_ZOMBIE, then call wakeup_proc(parent) to ask parent reclaim itself.
//   3. call scheduler to switch to other process
int
do_exit(int error_code) {
c0109bfd:	f3 0f 1e fb          	endbr32 
c0109c01:	55                   	push   %ebp
c0109c02:	89 e5                	mov    %esp,%ebp
c0109c04:	83 ec 08             	sub    $0x8,%esp
    panic("process exit!!.\n");
c0109c07:	83 ec 04             	sub    $0x4,%esp
c0109c0a:	68 49 ce 10 c0       	push   $0xc010ce49
c0109c0f:	68 62 01 00 00       	push   $0x162
c0109c14:	68 35 ce 10 c0       	push   $0xc010ce35
c0109c19:	e8 d0 7b ff ff       	call   c01017ee <__panic>

c0109c1e <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
c0109c1e:	f3 0f 1e fb          	endbr32 
c0109c22:	55                   	push   %ebp
c0109c23:	89 e5                	mov    %esp,%ebp
c0109c25:	83 ec 08             	sub    $0x8,%esp
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
c0109c28:	a1 28 f0 12 c0       	mov    0xc012f028,%eax
c0109c2d:	83 ec 0c             	sub    $0xc,%esp
c0109c30:	50                   	push   %eax
c0109c31:	e8 e1 f9 ff ff       	call   c0109617 <get_proc_name>
c0109c36:	83 c4 10             	add    $0x10,%esp
c0109c39:	8b 15 28 f0 12 c0    	mov    0xc012f028,%edx
c0109c3f:	8b 52 04             	mov    0x4(%edx),%edx
c0109c42:	83 ec 04             	sub    $0x4,%esp
c0109c45:	50                   	push   %eax
c0109c46:	52                   	push   %edx
c0109c47:	68 5c ce 10 c0       	push   $0xc010ce5c
c0109c4c:	e8 61 66 ff ff       	call   c01002b2 <cprintf>
c0109c51:	83 c4 10             	add    $0x10,%esp
    cprintf("To U: \"%s\".\n", (const char *)arg);
c0109c54:	83 ec 08             	sub    $0x8,%esp
c0109c57:	ff 75 08             	pushl  0x8(%ebp)
c0109c5a:	68 82 ce 10 c0       	push   $0xc010ce82
c0109c5f:	e8 4e 66 ff ff       	call   c01002b2 <cprintf>
c0109c64:	83 c4 10             	add    $0x10,%esp
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
c0109c67:	83 ec 0c             	sub    $0xc,%esp
c0109c6a:	68 8f ce 10 c0       	push   $0xc010ce8f
c0109c6f:	e8 3e 66 ff ff       	call   c01002b2 <cprintf>
c0109c74:	83 c4 10             	add    $0x10,%esp
    return 0;
c0109c77:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109c7c:	c9                   	leave  
c0109c7d:	c3                   	ret    

c0109c7e <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
c0109c7e:	f3 0f 1e fb          	endbr32 
c0109c82:	55                   	push   %ebp
c0109c83:	89 e5                	mov    %esp,%ebp
c0109c85:	83 ec 18             	sub    $0x18,%esp
c0109c88:	c7 45 ec 58 11 13 c0 	movl   $0xc0131158,-0x14(%ebp)
    elm->prev = elm->next = elm;
c0109c8f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109c92:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0109c95:	89 50 04             	mov    %edx,0x4(%eax)
c0109c98:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109c9b:	8b 50 04             	mov    0x4(%eax),%edx
c0109c9e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109ca1:	89 10                	mov    %edx,(%eax)
}
c0109ca3:	90                   	nop
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
c0109ca4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0109cab:	eb 27                	jmp    c0109cd4 <proc_init+0x56>
        list_init(hash_list + i);
c0109cad:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109cb0:	c1 e0 03             	shl    $0x3,%eax
c0109cb3:	05 40 f0 12 c0       	add    $0xc012f040,%eax
c0109cb8:	89 45 e8             	mov    %eax,-0x18(%ebp)
    elm->prev = elm->next = elm;
c0109cbb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109cbe:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0109cc1:	89 50 04             	mov    %edx,0x4(%eax)
c0109cc4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109cc7:	8b 50 04             	mov    0x4(%eax),%edx
c0109cca:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109ccd:	89 10                	mov    %edx,(%eax)
}
c0109ccf:	90                   	nop
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
c0109cd0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0109cd4:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
c0109cdb:	7e d0                	jle    c0109cad <proc_init+0x2f>
    }

    if ((idleproc = alloc_proc()) == NULL) {
c0109cdd:	e8 42 f8 ff ff       	call   c0109524 <alloc_proc>
c0109ce2:	a3 20 f0 12 c0       	mov    %eax,0xc012f020
c0109ce7:	a1 20 f0 12 c0       	mov    0xc012f020,%eax
c0109cec:	85 c0                	test   %eax,%eax
c0109cee:	75 17                	jne    c0109d07 <proc_init+0x89>
        panic("cannot alloc idleproc.\n");
c0109cf0:	83 ec 04             	sub    $0x4,%esp
c0109cf3:	68 ab ce 10 c0       	push   $0xc010ceab
c0109cf8:	68 7a 01 00 00       	push   $0x17a
c0109cfd:	68 35 ce 10 c0       	push   $0xc010ce35
c0109d02:	e8 e7 7a ff ff       	call   c01017ee <__panic>
    }

    idleproc->pid = 0;
c0109d07:	a1 20 f0 12 c0       	mov    0xc012f020,%eax
c0109d0c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    idleproc->state = PROC_RUNNABLE;
c0109d13:	a1 20 f0 12 c0       	mov    0xc012f020,%eax
c0109d18:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
    idleproc->kstack = (uintptr_t)bootstack;
c0109d1e:	a1 20 f0 12 c0       	mov    0xc012f020,%eax
c0109d23:	ba 00 90 12 c0       	mov    $0xc0129000,%edx
c0109d28:	89 50 0c             	mov    %edx,0xc(%eax)
    idleproc->need_resched = 1;
c0109d2b:	a1 20 f0 12 c0       	mov    0xc012f020,%eax
c0109d30:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
    set_proc_name(idleproc, "idle");
c0109d37:	a1 20 f0 12 c0       	mov    0xc012f020,%eax
c0109d3c:	83 ec 08             	sub    $0x8,%esp
c0109d3f:	68 c3 ce 10 c0       	push   $0xc010cec3
c0109d44:	50                   	push   %eax
c0109d45:	e8 94 f8 ff ff       	call   c01095de <set_proc_name>
c0109d4a:	83 c4 10             	add    $0x10,%esp
    nr_process ++;
c0109d4d:	a1 40 10 13 c0       	mov    0xc0131040,%eax
c0109d52:	83 c0 01             	add    $0x1,%eax
c0109d55:	a3 40 10 13 c0       	mov    %eax,0xc0131040

    current = idleproc;
c0109d5a:	a1 20 f0 12 c0       	mov    0xc012f020,%eax
c0109d5f:	a3 28 f0 12 c0       	mov    %eax,0xc012f028

    int pid = kernel_thread(init_main, "Hello world!!", 0);
c0109d64:	83 ec 04             	sub    $0x4,%esp
c0109d67:	6a 00                	push   $0x0
c0109d69:	68 c8 ce 10 c0       	push   $0xc010cec8
c0109d6e:	68 1e 9c 10 c0       	push   $0xc0109c1e
c0109d73:	e8 6e fb ff ff       	call   c01098e6 <kernel_thread>
c0109d78:	83 c4 10             	add    $0x10,%esp
c0109d7b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (pid <= 0) {
c0109d7e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0109d82:	7f 17                	jg     c0109d9b <proc_init+0x11d>
        panic("create init_main failed.\n");
c0109d84:	83 ec 04             	sub    $0x4,%esp
c0109d87:	68 d6 ce 10 c0       	push   $0xc010ced6
c0109d8c:	68 88 01 00 00       	push   $0x188
c0109d91:	68 35 ce 10 c0       	push   $0xc010ce35
c0109d96:	e8 53 7a ff ff       	call   c01017ee <__panic>
    }

    initproc = find_proc(pid);
c0109d9b:	83 ec 0c             	sub    $0xc,%esp
c0109d9e:	ff 75 f0             	pushl  -0x10(%ebp)
c0109da1:	e8 cc fa ff ff       	call   c0109872 <find_proc>
c0109da6:	83 c4 10             	add    $0x10,%esp
c0109da9:	a3 24 f0 12 c0       	mov    %eax,0xc012f024
    set_proc_name(initproc, "init");
c0109dae:	a1 24 f0 12 c0       	mov    0xc012f024,%eax
c0109db3:	83 ec 08             	sub    $0x8,%esp
c0109db6:	68 f0 ce 10 c0       	push   $0xc010cef0
c0109dbb:	50                   	push   %eax
c0109dbc:	e8 1d f8 ff ff       	call   c01095de <set_proc_name>
c0109dc1:	83 c4 10             	add    $0x10,%esp

    assert(idleproc != NULL && idleproc->pid == 0);
c0109dc4:	a1 20 f0 12 c0       	mov    0xc012f020,%eax
c0109dc9:	85 c0                	test   %eax,%eax
c0109dcb:	74 0c                	je     c0109dd9 <proc_init+0x15b>
c0109dcd:	a1 20 f0 12 c0       	mov    0xc012f020,%eax
c0109dd2:	8b 40 04             	mov    0x4(%eax),%eax
c0109dd5:	85 c0                	test   %eax,%eax
c0109dd7:	74 19                	je     c0109df2 <proc_init+0x174>
c0109dd9:	68 f8 ce 10 c0       	push   $0xc010cef8
c0109dde:	68 20 ce 10 c0       	push   $0xc010ce20
c0109de3:	68 8e 01 00 00       	push   $0x18e
c0109de8:	68 35 ce 10 c0       	push   $0xc010ce35
c0109ded:	e8 fc 79 ff ff       	call   c01017ee <__panic>
    assert(initproc != NULL && initproc->pid == 1);
c0109df2:	a1 24 f0 12 c0       	mov    0xc012f024,%eax
c0109df7:	85 c0                	test   %eax,%eax
c0109df9:	74 0d                	je     c0109e08 <proc_init+0x18a>
c0109dfb:	a1 24 f0 12 c0       	mov    0xc012f024,%eax
c0109e00:	8b 40 04             	mov    0x4(%eax),%eax
c0109e03:	83 f8 01             	cmp    $0x1,%eax
c0109e06:	74 19                	je     c0109e21 <proc_init+0x1a3>
c0109e08:	68 20 cf 10 c0       	push   $0xc010cf20
c0109e0d:	68 20 ce 10 c0       	push   $0xc010ce20
c0109e12:	68 8f 01 00 00       	push   $0x18f
c0109e17:	68 35 ce 10 c0       	push   $0xc010ce35
c0109e1c:	e8 cd 79 ff ff       	call   c01017ee <__panic>
}
c0109e21:	90                   	nop
c0109e22:	c9                   	leave  
c0109e23:	c3                   	ret    

c0109e24 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
c0109e24:	f3 0f 1e fb          	endbr32 
c0109e28:	55                   	push   %ebp
c0109e29:	89 e5                	mov    %esp,%ebp
c0109e2b:	83 ec 08             	sub    $0x8,%esp
    while (1) {
        if (current->need_resched) {
c0109e2e:	a1 28 f0 12 c0       	mov    0xc012f028,%eax
c0109e33:	8b 40 10             	mov    0x10(%eax),%eax
c0109e36:	85 c0                	test   %eax,%eax
c0109e38:	74 f4                	je     c0109e2e <cpu_idle+0xa>
            schedule();
c0109e3a:	e8 80 00 00 00       	call   c0109ebf <schedule>
        if (current->need_resched) {
c0109e3f:	eb ed                	jmp    c0109e2e <cpu_idle+0xa>

c0109e41 <__intr_save>:
__intr_save(void) {
c0109e41:	55                   	push   %ebp
c0109e42:	89 e5                	mov    %esp,%ebp
c0109e44:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0109e47:	9c                   	pushf  
c0109e48:	58                   	pop    %eax
c0109e49:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0109e4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0109e4f:	25 00 02 00 00       	and    $0x200,%eax
c0109e54:	85 c0                	test   %eax,%eax
c0109e56:	74 0c                	je     c0109e64 <__intr_save+0x23>
        intr_disable();
c0109e58:	e8 cf 96 ff ff       	call   c010352c <intr_disable>
        return 1;
c0109e5d:	b8 01 00 00 00       	mov    $0x1,%eax
c0109e62:	eb 05                	jmp    c0109e69 <__intr_save+0x28>
    return 0;
c0109e64:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109e69:	c9                   	leave  
c0109e6a:	c3                   	ret    

c0109e6b <__intr_restore>:
__intr_restore(bool flag) {
c0109e6b:	55                   	push   %ebp
c0109e6c:	89 e5                	mov    %esp,%ebp
c0109e6e:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0109e71:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0109e75:	74 05                	je     c0109e7c <__intr_restore+0x11>
        intr_enable();
c0109e77:	e8 a4 96 ff ff       	call   c0103520 <intr_enable>
}
c0109e7c:	90                   	nop
c0109e7d:	c9                   	leave  
c0109e7e:	c3                   	ret    

c0109e7f <wakeup_proc>:
#include <proc.h>
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
c0109e7f:	f3 0f 1e fb          	endbr32 
c0109e83:	55                   	push   %ebp
c0109e84:	89 e5                	mov    %esp,%ebp
c0109e86:	83 ec 08             	sub    $0x8,%esp
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
c0109e89:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e8c:	8b 00                	mov    (%eax),%eax
c0109e8e:	83 f8 03             	cmp    $0x3,%eax
c0109e91:	74 0a                	je     c0109e9d <wakeup_proc+0x1e>
c0109e93:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e96:	8b 00                	mov    (%eax),%eax
c0109e98:	83 f8 02             	cmp    $0x2,%eax
c0109e9b:	75 16                	jne    c0109eb3 <wakeup_proc+0x34>
c0109e9d:	68 48 cf 10 c0       	push   $0xc010cf48
c0109ea2:	68 83 cf 10 c0       	push   $0xc010cf83
c0109ea7:	6a 09                	push   $0x9
c0109ea9:	68 98 cf 10 c0       	push   $0xc010cf98
c0109eae:	e8 3b 79 ff ff       	call   c01017ee <__panic>
    proc->state = PROC_RUNNABLE;
c0109eb3:	8b 45 08             	mov    0x8(%ebp),%eax
c0109eb6:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
}
c0109ebc:	90                   	nop
c0109ebd:	c9                   	leave  
c0109ebe:	c3                   	ret    

c0109ebf <schedule>:

void
schedule(void) {
c0109ebf:	f3 0f 1e fb          	endbr32 
c0109ec3:	55                   	push   %ebp
c0109ec4:	89 e5                	mov    %esp,%ebp
c0109ec6:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
c0109ec9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    local_intr_save(intr_flag);
c0109ed0:	e8 6c ff ff ff       	call   c0109e41 <__intr_save>
c0109ed5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    {
        current->need_resched = 0;
c0109ed8:	a1 28 f0 12 c0       	mov    0xc012f028,%eax
c0109edd:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
c0109ee4:	8b 15 28 f0 12 c0    	mov    0xc012f028,%edx
c0109eea:	a1 20 f0 12 c0       	mov    0xc012f020,%eax
c0109eef:	39 c2                	cmp    %eax,%edx
c0109ef1:	74 0a                	je     c0109efd <schedule+0x3e>
c0109ef3:	a1 28 f0 12 c0       	mov    0xc012f028,%eax
c0109ef8:	83 c0 58             	add    $0x58,%eax
c0109efb:	eb 05                	jmp    c0109f02 <schedule+0x43>
c0109efd:	b8 58 11 13 c0       	mov    $0xc0131158,%eax
c0109f02:	89 45 e8             	mov    %eax,-0x18(%ebp)
        le = last;
c0109f05:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109f08:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109f0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109f0e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->next;
c0109f11:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109f14:	8b 40 04             	mov    0x4(%eax),%eax
        do {
            if ((le = list_next(le)) != &proc_list) {
c0109f17:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109f1a:	81 7d f4 58 11 13 c0 	cmpl   $0xc0131158,-0xc(%ebp)
c0109f21:	74 13                	je     c0109f36 <schedule+0x77>
                next = le2proc(le, list_link);
c0109f23:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109f26:	83 e8 58             	sub    $0x58,%eax
c0109f29:	89 45 f0             	mov    %eax,-0x10(%ebp)
                if (next->state == PROC_RUNNABLE) {
c0109f2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109f2f:	8b 00                	mov    (%eax),%eax
c0109f31:	83 f8 02             	cmp    $0x2,%eax
c0109f34:	74 0a                	je     c0109f40 <schedule+0x81>
                    break;
                }
            }
        } while (le != last);
c0109f36:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109f39:	3b 45 e8             	cmp    -0x18(%ebp),%eax
c0109f3c:	75 cd                	jne    c0109f0b <schedule+0x4c>
c0109f3e:	eb 01                	jmp    c0109f41 <schedule+0x82>
                    break;
c0109f40:	90                   	nop
        if (next == NULL || next->state != PROC_RUNNABLE) {
c0109f41:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0109f45:	74 0a                	je     c0109f51 <schedule+0x92>
c0109f47:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109f4a:	8b 00                	mov    (%eax),%eax
c0109f4c:	83 f8 02             	cmp    $0x2,%eax
c0109f4f:	74 08                	je     c0109f59 <schedule+0x9a>
            next = idleproc;
c0109f51:	a1 20 f0 12 c0       	mov    0xc012f020,%eax
c0109f56:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        next->runs ++;
c0109f59:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109f5c:	8b 40 08             	mov    0x8(%eax),%eax
c0109f5f:	8d 50 01             	lea    0x1(%eax),%edx
c0109f62:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109f65:	89 50 08             	mov    %edx,0x8(%eax)
        if (next != current) {
c0109f68:	a1 28 f0 12 c0       	mov    0xc012f028,%eax
c0109f6d:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0109f70:	74 0e                	je     c0109f80 <schedule+0xc1>
            proc_run(next);
c0109f72:	83 ec 0c             	sub    $0xc,%esp
c0109f75:	ff 75 f0             	pushl  -0x10(%ebp)
c0109f78:	e8 d0 f7 ff ff       	call   c010974d <proc_run>
c0109f7d:	83 c4 10             	add    $0x10,%esp
        }
    }
    local_intr_restore(intr_flag);
c0109f80:	83 ec 0c             	sub    $0xc,%esp
c0109f83:	ff 75 ec             	pushl  -0x14(%ebp)
c0109f86:	e8 e0 fe ff ff       	call   c0109e6b <__intr_restore>
c0109f8b:	83 c4 10             	add    $0x10,%esp
}
c0109f8e:	90                   	nop
c0109f8f:	c9                   	leave  
c0109f90:	c3                   	ret    

c0109f91 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c0109f91:	f3 0f 1e fb          	endbr32 
c0109f95:	55                   	push   %ebp
c0109f96:	89 e5                	mov    %esp,%ebp
c0109f98:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0109f9b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c0109fa2:	eb 04                	jmp    c0109fa8 <strlen+0x17>
        cnt ++;
c0109fa4:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    while (*s ++ != '\0') {
c0109fa8:	8b 45 08             	mov    0x8(%ebp),%eax
c0109fab:	8d 50 01             	lea    0x1(%eax),%edx
c0109fae:	89 55 08             	mov    %edx,0x8(%ebp)
c0109fb1:	0f b6 00             	movzbl (%eax),%eax
c0109fb4:	84 c0                	test   %al,%al
c0109fb6:	75 ec                	jne    c0109fa4 <strlen+0x13>
    }
    return cnt;
c0109fb8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0109fbb:	c9                   	leave  
c0109fbc:	c3                   	ret    

c0109fbd <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c0109fbd:	f3 0f 1e fb          	endbr32 
c0109fc1:	55                   	push   %ebp
c0109fc2:	89 e5                	mov    %esp,%ebp
c0109fc4:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0109fc7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0109fce:	eb 04                	jmp    c0109fd4 <strnlen+0x17>
        cnt ++;
c0109fd0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0109fd4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109fd7:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0109fda:	73 10                	jae    c0109fec <strnlen+0x2f>
c0109fdc:	8b 45 08             	mov    0x8(%ebp),%eax
c0109fdf:	8d 50 01             	lea    0x1(%eax),%edx
c0109fe2:	89 55 08             	mov    %edx,0x8(%ebp)
c0109fe5:	0f b6 00             	movzbl (%eax),%eax
c0109fe8:	84 c0                	test   %al,%al
c0109fea:	75 e4                	jne    c0109fd0 <strnlen+0x13>
    }
    return cnt;
c0109fec:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0109fef:	c9                   	leave  
c0109ff0:	c3                   	ret    

c0109ff1 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c0109ff1:	f3 0f 1e fb          	endbr32 
c0109ff5:	55                   	push   %ebp
c0109ff6:	89 e5                	mov    %esp,%ebp
c0109ff8:	57                   	push   %edi
c0109ff9:	56                   	push   %esi
c0109ffa:	83 ec 20             	sub    $0x20,%esp
c0109ffd:	8b 45 08             	mov    0x8(%ebp),%eax
c010a000:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a003:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a006:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c010a009:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010a00c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a00f:	89 d1                	mov    %edx,%ecx
c010a011:	89 c2                	mov    %eax,%edx
c010a013:	89 ce                	mov    %ecx,%esi
c010a015:	89 d7                	mov    %edx,%edi
c010a017:	ac                   	lods   %ds:(%esi),%al
c010a018:	aa                   	stos   %al,%es:(%edi)
c010a019:	84 c0                	test   %al,%al
c010a01b:	75 fa                	jne    c010a017 <strcpy+0x26>
c010a01d:	89 fa                	mov    %edi,%edx
c010a01f:	89 f1                	mov    %esi,%ecx
c010a021:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010a024:	89 55 e8             	mov    %edx,-0x18(%ebp)
c010a027:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c010a02a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c010a02d:	83 c4 20             	add    $0x20,%esp
c010a030:	5e                   	pop    %esi
c010a031:	5f                   	pop    %edi
c010a032:	5d                   	pop    %ebp
c010a033:	c3                   	ret    

c010a034 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c010a034:	f3 0f 1e fb          	endbr32 
c010a038:	55                   	push   %ebp
c010a039:	89 e5                	mov    %esp,%ebp
c010a03b:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c010a03e:	8b 45 08             	mov    0x8(%ebp),%eax
c010a041:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c010a044:	eb 21                	jmp    c010a067 <strncpy+0x33>
        if ((*p = *src) != '\0') {
c010a046:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a049:	0f b6 10             	movzbl (%eax),%edx
c010a04c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010a04f:	88 10                	mov    %dl,(%eax)
c010a051:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010a054:	0f b6 00             	movzbl (%eax),%eax
c010a057:	84 c0                	test   %al,%al
c010a059:	74 04                	je     c010a05f <strncpy+0x2b>
            src ++;
c010a05b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
c010a05f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010a063:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    while (len > 0) {
c010a067:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010a06b:	75 d9                	jne    c010a046 <strncpy+0x12>
    }
    return dst;
c010a06d:	8b 45 08             	mov    0x8(%ebp),%eax
}
c010a070:	c9                   	leave  
c010a071:	c3                   	ret    

c010a072 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c010a072:	f3 0f 1e fb          	endbr32 
c010a076:	55                   	push   %ebp
c010a077:	89 e5                	mov    %esp,%ebp
c010a079:	57                   	push   %edi
c010a07a:	56                   	push   %esi
c010a07b:	83 ec 20             	sub    $0x20,%esp
c010a07e:	8b 45 08             	mov    0x8(%ebp),%eax
c010a081:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a084:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a087:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
c010a08a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010a08d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a090:	89 d1                	mov    %edx,%ecx
c010a092:	89 c2                	mov    %eax,%edx
c010a094:	89 ce                	mov    %ecx,%esi
c010a096:	89 d7                	mov    %edx,%edi
c010a098:	ac                   	lods   %ds:(%esi),%al
c010a099:	ae                   	scas   %es:(%edi),%al
c010a09a:	75 08                	jne    c010a0a4 <strcmp+0x32>
c010a09c:	84 c0                	test   %al,%al
c010a09e:	75 f8                	jne    c010a098 <strcmp+0x26>
c010a0a0:	31 c0                	xor    %eax,%eax
c010a0a2:	eb 04                	jmp    c010a0a8 <strcmp+0x36>
c010a0a4:	19 c0                	sbb    %eax,%eax
c010a0a6:	0c 01                	or     $0x1,%al
c010a0a8:	89 fa                	mov    %edi,%edx
c010a0aa:	89 f1                	mov    %esi,%ecx
c010a0ac:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010a0af:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c010a0b2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
c010a0b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c010a0b8:	83 c4 20             	add    $0x20,%esp
c010a0bb:	5e                   	pop    %esi
c010a0bc:	5f                   	pop    %edi
c010a0bd:	5d                   	pop    %ebp
c010a0be:	c3                   	ret    

c010a0bf <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c010a0bf:	f3 0f 1e fb          	endbr32 
c010a0c3:	55                   	push   %ebp
c010a0c4:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c010a0c6:	eb 0c                	jmp    c010a0d4 <strncmp+0x15>
        n --, s1 ++, s2 ++;
c010a0c8:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c010a0cc:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010a0d0:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c010a0d4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010a0d8:	74 1a                	je     c010a0f4 <strncmp+0x35>
c010a0da:	8b 45 08             	mov    0x8(%ebp),%eax
c010a0dd:	0f b6 00             	movzbl (%eax),%eax
c010a0e0:	84 c0                	test   %al,%al
c010a0e2:	74 10                	je     c010a0f4 <strncmp+0x35>
c010a0e4:	8b 45 08             	mov    0x8(%ebp),%eax
c010a0e7:	0f b6 10             	movzbl (%eax),%edx
c010a0ea:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a0ed:	0f b6 00             	movzbl (%eax),%eax
c010a0f0:	38 c2                	cmp    %al,%dl
c010a0f2:	74 d4                	je     c010a0c8 <strncmp+0x9>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c010a0f4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010a0f8:	74 18                	je     c010a112 <strncmp+0x53>
c010a0fa:	8b 45 08             	mov    0x8(%ebp),%eax
c010a0fd:	0f b6 00             	movzbl (%eax),%eax
c010a100:	0f b6 d0             	movzbl %al,%edx
c010a103:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a106:	0f b6 00             	movzbl (%eax),%eax
c010a109:	0f b6 c0             	movzbl %al,%eax
c010a10c:	29 c2                	sub    %eax,%edx
c010a10e:	89 d0                	mov    %edx,%eax
c010a110:	eb 05                	jmp    c010a117 <strncmp+0x58>
c010a112:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010a117:	5d                   	pop    %ebp
c010a118:	c3                   	ret    

c010a119 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c010a119:	f3 0f 1e fb          	endbr32 
c010a11d:	55                   	push   %ebp
c010a11e:	89 e5                	mov    %esp,%ebp
c010a120:	83 ec 04             	sub    $0x4,%esp
c010a123:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a126:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c010a129:	eb 14                	jmp    c010a13f <strchr+0x26>
        if (*s == c) {
c010a12b:	8b 45 08             	mov    0x8(%ebp),%eax
c010a12e:	0f b6 00             	movzbl (%eax),%eax
c010a131:	38 45 fc             	cmp    %al,-0x4(%ebp)
c010a134:	75 05                	jne    c010a13b <strchr+0x22>
            return (char *)s;
c010a136:	8b 45 08             	mov    0x8(%ebp),%eax
c010a139:	eb 13                	jmp    c010a14e <strchr+0x35>
        }
        s ++;
c010a13b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s != '\0') {
c010a13f:	8b 45 08             	mov    0x8(%ebp),%eax
c010a142:	0f b6 00             	movzbl (%eax),%eax
c010a145:	84 c0                	test   %al,%al
c010a147:	75 e2                	jne    c010a12b <strchr+0x12>
    }
    return NULL;
c010a149:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010a14e:	c9                   	leave  
c010a14f:	c3                   	ret    

c010a150 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c010a150:	f3 0f 1e fb          	endbr32 
c010a154:	55                   	push   %ebp
c010a155:	89 e5                	mov    %esp,%ebp
c010a157:	83 ec 04             	sub    $0x4,%esp
c010a15a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a15d:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c010a160:	eb 0f                	jmp    c010a171 <strfind+0x21>
        if (*s == c) {
c010a162:	8b 45 08             	mov    0x8(%ebp),%eax
c010a165:	0f b6 00             	movzbl (%eax),%eax
c010a168:	38 45 fc             	cmp    %al,-0x4(%ebp)
c010a16b:	74 10                	je     c010a17d <strfind+0x2d>
            break;
        }
        s ++;
c010a16d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s != '\0') {
c010a171:	8b 45 08             	mov    0x8(%ebp),%eax
c010a174:	0f b6 00             	movzbl (%eax),%eax
c010a177:	84 c0                	test   %al,%al
c010a179:	75 e7                	jne    c010a162 <strfind+0x12>
c010a17b:	eb 01                	jmp    c010a17e <strfind+0x2e>
            break;
c010a17d:	90                   	nop
    }
    return (char *)s;
c010a17e:	8b 45 08             	mov    0x8(%ebp),%eax
}
c010a181:	c9                   	leave  
c010a182:	c3                   	ret    

c010a183 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c010a183:	f3 0f 1e fb          	endbr32 
c010a187:	55                   	push   %ebp
c010a188:	89 e5                	mov    %esp,%ebp
c010a18a:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c010a18d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c010a194:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c010a19b:	eb 04                	jmp    c010a1a1 <strtol+0x1e>
        s ++;
c010a19d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
c010a1a1:	8b 45 08             	mov    0x8(%ebp),%eax
c010a1a4:	0f b6 00             	movzbl (%eax),%eax
c010a1a7:	3c 20                	cmp    $0x20,%al
c010a1a9:	74 f2                	je     c010a19d <strtol+0x1a>
c010a1ab:	8b 45 08             	mov    0x8(%ebp),%eax
c010a1ae:	0f b6 00             	movzbl (%eax),%eax
c010a1b1:	3c 09                	cmp    $0x9,%al
c010a1b3:	74 e8                	je     c010a19d <strtol+0x1a>
    }

    // plus/minus sign
    if (*s == '+') {
c010a1b5:	8b 45 08             	mov    0x8(%ebp),%eax
c010a1b8:	0f b6 00             	movzbl (%eax),%eax
c010a1bb:	3c 2b                	cmp    $0x2b,%al
c010a1bd:	75 06                	jne    c010a1c5 <strtol+0x42>
        s ++;
c010a1bf:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010a1c3:	eb 15                	jmp    c010a1da <strtol+0x57>
    }
    else if (*s == '-') {
c010a1c5:	8b 45 08             	mov    0x8(%ebp),%eax
c010a1c8:	0f b6 00             	movzbl (%eax),%eax
c010a1cb:	3c 2d                	cmp    $0x2d,%al
c010a1cd:	75 0b                	jne    c010a1da <strtol+0x57>
        s ++, neg = 1;
c010a1cf:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010a1d3:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c010a1da:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010a1de:	74 06                	je     c010a1e6 <strtol+0x63>
c010a1e0:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c010a1e4:	75 24                	jne    c010a20a <strtol+0x87>
c010a1e6:	8b 45 08             	mov    0x8(%ebp),%eax
c010a1e9:	0f b6 00             	movzbl (%eax),%eax
c010a1ec:	3c 30                	cmp    $0x30,%al
c010a1ee:	75 1a                	jne    c010a20a <strtol+0x87>
c010a1f0:	8b 45 08             	mov    0x8(%ebp),%eax
c010a1f3:	83 c0 01             	add    $0x1,%eax
c010a1f6:	0f b6 00             	movzbl (%eax),%eax
c010a1f9:	3c 78                	cmp    $0x78,%al
c010a1fb:	75 0d                	jne    c010a20a <strtol+0x87>
        s += 2, base = 16;
c010a1fd:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c010a201:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c010a208:	eb 2a                	jmp    c010a234 <strtol+0xb1>
    }
    else if (base == 0 && s[0] == '0') {
c010a20a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010a20e:	75 17                	jne    c010a227 <strtol+0xa4>
c010a210:	8b 45 08             	mov    0x8(%ebp),%eax
c010a213:	0f b6 00             	movzbl (%eax),%eax
c010a216:	3c 30                	cmp    $0x30,%al
c010a218:	75 0d                	jne    c010a227 <strtol+0xa4>
        s ++, base = 8;
c010a21a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010a21e:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c010a225:	eb 0d                	jmp    c010a234 <strtol+0xb1>
    }
    else if (base == 0) {
c010a227:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010a22b:	75 07                	jne    c010a234 <strtol+0xb1>
        base = 10;
c010a22d:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c010a234:	8b 45 08             	mov    0x8(%ebp),%eax
c010a237:	0f b6 00             	movzbl (%eax),%eax
c010a23a:	3c 2f                	cmp    $0x2f,%al
c010a23c:	7e 1b                	jle    c010a259 <strtol+0xd6>
c010a23e:	8b 45 08             	mov    0x8(%ebp),%eax
c010a241:	0f b6 00             	movzbl (%eax),%eax
c010a244:	3c 39                	cmp    $0x39,%al
c010a246:	7f 11                	jg     c010a259 <strtol+0xd6>
            dig = *s - '0';
c010a248:	8b 45 08             	mov    0x8(%ebp),%eax
c010a24b:	0f b6 00             	movzbl (%eax),%eax
c010a24e:	0f be c0             	movsbl %al,%eax
c010a251:	83 e8 30             	sub    $0x30,%eax
c010a254:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a257:	eb 48                	jmp    c010a2a1 <strtol+0x11e>
        }
        else if (*s >= 'a' && *s <= 'z') {
c010a259:	8b 45 08             	mov    0x8(%ebp),%eax
c010a25c:	0f b6 00             	movzbl (%eax),%eax
c010a25f:	3c 60                	cmp    $0x60,%al
c010a261:	7e 1b                	jle    c010a27e <strtol+0xfb>
c010a263:	8b 45 08             	mov    0x8(%ebp),%eax
c010a266:	0f b6 00             	movzbl (%eax),%eax
c010a269:	3c 7a                	cmp    $0x7a,%al
c010a26b:	7f 11                	jg     c010a27e <strtol+0xfb>
            dig = *s - 'a' + 10;
c010a26d:	8b 45 08             	mov    0x8(%ebp),%eax
c010a270:	0f b6 00             	movzbl (%eax),%eax
c010a273:	0f be c0             	movsbl %al,%eax
c010a276:	83 e8 57             	sub    $0x57,%eax
c010a279:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a27c:	eb 23                	jmp    c010a2a1 <strtol+0x11e>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c010a27e:	8b 45 08             	mov    0x8(%ebp),%eax
c010a281:	0f b6 00             	movzbl (%eax),%eax
c010a284:	3c 40                	cmp    $0x40,%al
c010a286:	7e 3c                	jle    c010a2c4 <strtol+0x141>
c010a288:	8b 45 08             	mov    0x8(%ebp),%eax
c010a28b:	0f b6 00             	movzbl (%eax),%eax
c010a28e:	3c 5a                	cmp    $0x5a,%al
c010a290:	7f 32                	jg     c010a2c4 <strtol+0x141>
            dig = *s - 'A' + 10;
c010a292:	8b 45 08             	mov    0x8(%ebp),%eax
c010a295:	0f b6 00             	movzbl (%eax),%eax
c010a298:	0f be c0             	movsbl %al,%eax
c010a29b:	83 e8 37             	sub    $0x37,%eax
c010a29e:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c010a2a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a2a4:	3b 45 10             	cmp    0x10(%ebp),%eax
c010a2a7:	7d 1a                	jge    c010a2c3 <strtol+0x140>
            break;
        }
        s ++, val = (val * base) + dig;
c010a2a9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010a2ad:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010a2b0:	0f af 45 10          	imul   0x10(%ebp),%eax
c010a2b4:	89 c2                	mov    %eax,%edx
c010a2b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a2b9:	01 d0                	add    %edx,%eax
c010a2bb:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
c010a2be:	e9 71 ff ff ff       	jmp    c010a234 <strtol+0xb1>
            break;
c010a2c3:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
c010a2c4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010a2c8:	74 08                	je     c010a2d2 <strtol+0x14f>
        *endptr = (char *) s;
c010a2ca:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a2cd:	8b 55 08             	mov    0x8(%ebp),%edx
c010a2d0:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c010a2d2:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c010a2d6:	74 07                	je     c010a2df <strtol+0x15c>
c010a2d8:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010a2db:	f7 d8                	neg    %eax
c010a2dd:	eb 03                	jmp    c010a2e2 <strtol+0x15f>
c010a2df:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c010a2e2:	c9                   	leave  
c010a2e3:	c3                   	ret    

c010a2e4 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c010a2e4:	f3 0f 1e fb          	endbr32 
c010a2e8:	55                   	push   %ebp
c010a2e9:	89 e5                	mov    %esp,%ebp
c010a2eb:	57                   	push   %edi
c010a2ec:	83 ec 24             	sub    $0x24,%esp
c010a2ef:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a2f2:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c010a2f5:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c010a2f9:	8b 55 08             	mov    0x8(%ebp),%edx
c010a2fc:	89 55 f8             	mov    %edx,-0x8(%ebp)
c010a2ff:	88 45 f7             	mov    %al,-0x9(%ebp)
c010a302:	8b 45 10             	mov    0x10(%ebp),%eax
c010a305:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c010a308:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c010a30b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c010a30f:	8b 55 f8             	mov    -0x8(%ebp),%edx
c010a312:	89 d7                	mov    %edx,%edi
c010a314:	f3 aa                	rep stos %al,%es:(%edi)
c010a316:	89 fa                	mov    %edi,%edx
c010a318:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010a31b:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c010a31e:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c010a321:	83 c4 24             	add    $0x24,%esp
c010a324:	5f                   	pop    %edi
c010a325:	5d                   	pop    %ebp
c010a326:	c3                   	ret    

c010a327 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c010a327:	f3 0f 1e fb          	endbr32 
c010a32b:	55                   	push   %ebp
c010a32c:	89 e5                	mov    %esp,%ebp
c010a32e:	57                   	push   %edi
c010a32f:	56                   	push   %esi
c010a330:	53                   	push   %ebx
c010a331:	83 ec 30             	sub    $0x30,%esp
c010a334:	8b 45 08             	mov    0x8(%ebp),%eax
c010a337:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a33a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a33d:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010a340:	8b 45 10             	mov    0x10(%ebp),%eax
c010a343:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c010a346:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a349:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010a34c:	73 42                	jae    c010a390 <memmove+0x69>
c010a34e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a351:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010a354:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a357:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010a35a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a35d:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c010a360:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a363:	c1 e8 02             	shr    $0x2,%eax
c010a366:	89 c1                	mov    %eax,%ecx
    asm volatile (
c010a368:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010a36b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010a36e:	89 d7                	mov    %edx,%edi
c010a370:	89 c6                	mov    %eax,%esi
c010a372:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c010a374:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c010a377:	83 e1 03             	and    $0x3,%ecx
c010a37a:	74 02                	je     c010a37e <memmove+0x57>
c010a37c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010a37e:	89 f0                	mov    %esi,%eax
c010a380:	89 fa                	mov    %edi,%edx
c010a382:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c010a385:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010a388:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
c010a38b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
        return __memcpy(dst, src, n);
c010a38e:	eb 36                	jmp    c010a3c6 <memmove+0x9f>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c010a390:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a393:	8d 50 ff             	lea    -0x1(%eax),%edx
c010a396:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a399:	01 c2                	add    %eax,%edx
c010a39b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a39e:	8d 48 ff             	lea    -0x1(%eax),%ecx
c010a3a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a3a4:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
c010a3a7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a3aa:	89 c1                	mov    %eax,%ecx
c010a3ac:	89 d8                	mov    %ebx,%eax
c010a3ae:	89 d6                	mov    %edx,%esi
c010a3b0:	89 c7                	mov    %eax,%edi
c010a3b2:	fd                   	std    
c010a3b3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010a3b5:	fc                   	cld    
c010a3b6:	89 f8                	mov    %edi,%eax
c010a3b8:	89 f2                	mov    %esi,%edx
c010a3ba:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c010a3bd:	89 55 c8             	mov    %edx,-0x38(%ebp)
c010a3c0:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
c010a3c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c010a3c6:	83 c4 30             	add    $0x30,%esp
c010a3c9:	5b                   	pop    %ebx
c010a3ca:	5e                   	pop    %esi
c010a3cb:	5f                   	pop    %edi
c010a3cc:	5d                   	pop    %ebp
c010a3cd:	c3                   	ret    

c010a3ce <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c010a3ce:	f3 0f 1e fb          	endbr32 
c010a3d2:	55                   	push   %ebp
c010a3d3:	89 e5                	mov    %esp,%ebp
c010a3d5:	57                   	push   %edi
c010a3d6:	56                   	push   %esi
c010a3d7:	83 ec 20             	sub    $0x20,%esp
c010a3da:	8b 45 08             	mov    0x8(%ebp),%eax
c010a3dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a3e0:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a3e3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a3e6:	8b 45 10             	mov    0x10(%ebp),%eax
c010a3e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c010a3ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a3ef:	c1 e8 02             	shr    $0x2,%eax
c010a3f2:	89 c1                	mov    %eax,%ecx
    asm volatile (
c010a3f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010a3f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a3fa:	89 d7                	mov    %edx,%edi
c010a3fc:	89 c6                	mov    %eax,%esi
c010a3fe:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c010a400:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c010a403:	83 e1 03             	and    $0x3,%ecx
c010a406:	74 02                	je     c010a40a <memcpy+0x3c>
c010a408:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010a40a:	89 f0                	mov    %esi,%eax
c010a40c:	89 fa                	mov    %edi,%edx
c010a40e:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c010a411:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010a414:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
c010a417:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c010a41a:	83 c4 20             	add    $0x20,%esp
c010a41d:	5e                   	pop    %esi
c010a41e:	5f                   	pop    %edi
c010a41f:	5d                   	pop    %ebp
c010a420:	c3                   	ret    

c010a421 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c010a421:	f3 0f 1e fb          	endbr32 
c010a425:	55                   	push   %ebp
c010a426:	89 e5                	mov    %esp,%ebp
c010a428:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c010a42b:	8b 45 08             	mov    0x8(%ebp),%eax
c010a42e:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c010a431:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a434:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c010a437:	eb 30                	jmp    c010a469 <memcmp+0x48>
        if (*s1 != *s2) {
c010a439:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010a43c:	0f b6 10             	movzbl (%eax),%edx
c010a43f:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010a442:	0f b6 00             	movzbl (%eax),%eax
c010a445:	38 c2                	cmp    %al,%dl
c010a447:	74 18                	je     c010a461 <memcmp+0x40>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c010a449:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010a44c:	0f b6 00             	movzbl (%eax),%eax
c010a44f:	0f b6 d0             	movzbl %al,%edx
c010a452:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010a455:	0f b6 00             	movzbl (%eax),%eax
c010a458:	0f b6 c0             	movzbl %al,%eax
c010a45b:	29 c2                	sub    %eax,%edx
c010a45d:	89 d0                	mov    %edx,%eax
c010a45f:	eb 1a                	jmp    c010a47b <memcmp+0x5a>
        }
        s1 ++, s2 ++;
c010a461:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010a465:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
    while (n -- > 0) {
c010a469:	8b 45 10             	mov    0x10(%ebp),%eax
c010a46c:	8d 50 ff             	lea    -0x1(%eax),%edx
c010a46f:	89 55 10             	mov    %edx,0x10(%ebp)
c010a472:	85 c0                	test   %eax,%eax
c010a474:	75 c3                	jne    c010a439 <memcmp+0x18>
    }
    return 0;
c010a476:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010a47b:	c9                   	leave  
c010a47c:	c3                   	ret    

c010a47d <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c010a47d:	f3 0f 1e fb          	endbr32 
c010a481:	55                   	push   %ebp
c010a482:	89 e5                	mov    %esp,%ebp
c010a484:	83 ec 38             	sub    $0x38,%esp
c010a487:	8b 45 10             	mov    0x10(%ebp),%eax
c010a48a:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010a48d:	8b 45 14             	mov    0x14(%ebp),%eax
c010a490:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c010a493:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a496:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010a499:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010a49c:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c010a49f:	8b 45 18             	mov    0x18(%ebp),%eax
c010a4a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010a4a5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a4a8:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010a4ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010a4ae:	89 55 f0             	mov    %edx,-0x10(%ebp)
c010a4b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a4b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a4b7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a4bb:	74 1c                	je     c010a4d9 <printnum+0x5c>
c010a4bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a4c0:	ba 00 00 00 00       	mov    $0x0,%edx
c010a4c5:	f7 75 e4             	divl   -0x1c(%ebp)
c010a4c8:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010a4cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a4ce:	ba 00 00 00 00       	mov    $0x0,%edx
c010a4d3:	f7 75 e4             	divl   -0x1c(%ebp)
c010a4d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a4d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010a4dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010a4df:	f7 75 e4             	divl   -0x1c(%ebp)
c010a4e2:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010a4e5:	89 55 dc             	mov    %edx,-0x24(%ebp)
c010a4e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010a4eb:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010a4ee:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010a4f1:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010a4f4:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a4f7:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c010a4fa:	8b 45 18             	mov    0x18(%ebp),%eax
c010a4fd:	ba 00 00 00 00       	mov    $0x0,%edx
c010a502:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c010a505:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c010a508:	19 d1                	sbb    %edx,%ecx
c010a50a:	72 37                	jb     c010a543 <printnum+0xc6>
        printnum(putch, putdat, result, base, width - 1, padc);
c010a50c:	8b 45 1c             	mov    0x1c(%ebp),%eax
c010a50f:	83 e8 01             	sub    $0x1,%eax
c010a512:	83 ec 04             	sub    $0x4,%esp
c010a515:	ff 75 20             	pushl  0x20(%ebp)
c010a518:	50                   	push   %eax
c010a519:	ff 75 18             	pushl  0x18(%ebp)
c010a51c:	ff 75 ec             	pushl  -0x14(%ebp)
c010a51f:	ff 75 e8             	pushl  -0x18(%ebp)
c010a522:	ff 75 0c             	pushl  0xc(%ebp)
c010a525:	ff 75 08             	pushl  0x8(%ebp)
c010a528:	e8 50 ff ff ff       	call   c010a47d <printnum>
c010a52d:	83 c4 20             	add    $0x20,%esp
c010a530:	eb 1b                	jmp    c010a54d <printnum+0xd0>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c010a532:	83 ec 08             	sub    $0x8,%esp
c010a535:	ff 75 0c             	pushl  0xc(%ebp)
c010a538:	ff 75 20             	pushl  0x20(%ebp)
c010a53b:	8b 45 08             	mov    0x8(%ebp),%eax
c010a53e:	ff d0                	call   *%eax
c010a540:	83 c4 10             	add    $0x10,%esp
        while (-- width > 0)
c010a543:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
c010a547:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c010a54b:	7f e5                	jg     c010a532 <printnum+0xb5>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c010a54d:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a550:	05 30 d0 10 c0       	add    $0xc010d030,%eax
c010a555:	0f b6 00             	movzbl (%eax),%eax
c010a558:	0f be c0             	movsbl %al,%eax
c010a55b:	83 ec 08             	sub    $0x8,%esp
c010a55e:	ff 75 0c             	pushl  0xc(%ebp)
c010a561:	50                   	push   %eax
c010a562:	8b 45 08             	mov    0x8(%ebp),%eax
c010a565:	ff d0                	call   *%eax
c010a567:	83 c4 10             	add    $0x10,%esp
}
c010a56a:	90                   	nop
c010a56b:	c9                   	leave  
c010a56c:	c3                   	ret    

c010a56d <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c010a56d:	f3 0f 1e fb          	endbr32 
c010a571:	55                   	push   %ebp
c010a572:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010a574:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c010a578:	7e 14                	jle    c010a58e <getuint+0x21>
        return va_arg(*ap, unsigned long long);
c010a57a:	8b 45 08             	mov    0x8(%ebp),%eax
c010a57d:	8b 00                	mov    (%eax),%eax
c010a57f:	8d 48 08             	lea    0x8(%eax),%ecx
c010a582:	8b 55 08             	mov    0x8(%ebp),%edx
c010a585:	89 0a                	mov    %ecx,(%edx)
c010a587:	8b 50 04             	mov    0x4(%eax),%edx
c010a58a:	8b 00                	mov    (%eax),%eax
c010a58c:	eb 30                	jmp    c010a5be <getuint+0x51>
    }
    else if (lflag) {
c010a58e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010a592:	74 16                	je     c010a5aa <getuint+0x3d>
        return va_arg(*ap, unsigned long);
c010a594:	8b 45 08             	mov    0x8(%ebp),%eax
c010a597:	8b 00                	mov    (%eax),%eax
c010a599:	8d 48 04             	lea    0x4(%eax),%ecx
c010a59c:	8b 55 08             	mov    0x8(%ebp),%edx
c010a59f:	89 0a                	mov    %ecx,(%edx)
c010a5a1:	8b 00                	mov    (%eax),%eax
c010a5a3:	ba 00 00 00 00       	mov    $0x0,%edx
c010a5a8:	eb 14                	jmp    c010a5be <getuint+0x51>
    }
    else {
        return va_arg(*ap, unsigned int);
c010a5aa:	8b 45 08             	mov    0x8(%ebp),%eax
c010a5ad:	8b 00                	mov    (%eax),%eax
c010a5af:	8d 48 04             	lea    0x4(%eax),%ecx
c010a5b2:	8b 55 08             	mov    0x8(%ebp),%edx
c010a5b5:	89 0a                	mov    %ecx,(%edx)
c010a5b7:	8b 00                	mov    (%eax),%eax
c010a5b9:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c010a5be:	5d                   	pop    %ebp
c010a5bf:	c3                   	ret    

c010a5c0 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c010a5c0:	f3 0f 1e fb          	endbr32 
c010a5c4:	55                   	push   %ebp
c010a5c5:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010a5c7:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c010a5cb:	7e 14                	jle    c010a5e1 <getint+0x21>
        return va_arg(*ap, long long);
c010a5cd:	8b 45 08             	mov    0x8(%ebp),%eax
c010a5d0:	8b 00                	mov    (%eax),%eax
c010a5d2:	8d 48 08             	lea    0x8(%eax),%ecx
c010a5d5:	8b 55 08             	mov    0x8(%ebp),%edx
c010a5d8:	89 0a                	mov    %ecx,(%edx)
c010a5da:	8b 50 04             	mov    0x4(%eax),%edx
c010a5dd:	8b 00                	mov    (%eax),%eax
c010a5df:	eb 28                	jmp    c010a609 <getint+0x49>
    }
    else if (lflag) {
c010a5e1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010a5e5:	74 12                	je     c010a5f9 <getint+0x39>
        return va_arg(*ap, long);
c010a5e7:	8b 45 08             	mov    0x8(%ebp),%eax
c010a5ea:	8b 00                	mov    (%eax),%eax
c010a5ec:	8d 48 04             	lea    0x4(%eax),%ecx
c010a5ef:	8b 55 08             	mov    0x8(%ebp),%edx
c010a5f2:	89 0a                	mov    %ecx,(%edx)
c010a5f4:	8b 00                	mov    (%eax),%eax
c010a5f6:	99                   	cltd   
c010a5f7:	eb 10                	jmp    c010a609 <getint+0x49>
    }
    else {
        return va_arg(*ap, int);
c010a5f9:	8b 45 08             	mov    0x8(%ebp),%eax
c010a5fc:	8b 00                	mov    (%eax),%eax
c010a5fe:	8d 48 04             	lea    0x4(%eax),%ecx
c010a601:	8b 55 08             	mov    0x8(%ebp),%edx
c010a604:	89 0a                	mov    %ecx,(%edx)
c010a606:	8b 00                	mov    (%eax),%eax
c010a608:	99                   	cltd   
    }
}
c010a609:	5d                   	pop    %ebp
c010a60a:	c3                   	ret    

c010a60b <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c010a60b:	f3 0f 1e fb          	endbr32 
c010a60f:	55                   	push   %ebp
c010a610:	89 e5                	mov    %esp,%ebp
c010a612:	83 ec 18             	sub    $0x18,%esp
    va_list ap;

    va_start(ap, fmt);
c010a615:	8d 45 14             	lea    0x14(%ebp),%eax
c010a618:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c010a61b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a61e:	50                   	push   %eax
c010a61f:	ff 75 10             	pushl  0x10(%ebp)
c010a622:	ff 75 0c             	pushl  0xc(%ebp)
c010a625:	ff 75 08             	pushl  0x8(%ebp)
c010a628:	e8 06 00 00 00       	call   c010a633 <vprintfmt>
c010a62d:	83 c4 10             	add    $0x10,%esp
    va_end(ap);
}
c010a630:	90                   	nop
c010a631:	c9                   	leave  
c010a632:	c3                   	ret    

c010a633 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c010a633:	f3 0f 1e fb          	endbr32 
c010a637:	55                   	push   %ebp
c010a638:	89 e5                	mov    %esp,%ebp
c010a63a:	56                   	push   %esi
c010a63b:	53                   	push   %ebx
c010a63c:	83 ec 20             	sub    $0x20,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010a63f:	eb 17                	jmp    c010a658 <vprintfmt+0x25>
            if (ch == '\0') {
c010a641:	85 db                	test   %ebx,%ebx
c010a643:	0f 84 8f 03 00 00    	je     c010a9d8 <vprintfmt+0x3a5>
                return;
            }
            putch(ch, putdat);
c010a649:	83 ec 08             	sub    $0x8,%esp
c010a64c:	ff 75 0c             	pushl  0xc(%ebp)
c010a64f:	53                   	push   %ebx
c010a650:	8b 45 08             	mov    0x8(%ebp),%eax
c010a653:	ff d0                	call   *%eax
c010a655:	83 c4 10             	add    $0x10,%esp
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010a658:	8b 45 10             	mov    0x10(%ebp),%eax
c010a65b:	8d 50 01             	lea    0x1(%eax),%edx
c010a65e:	89 55 10             	mov    %edx,0x10(%ebp)
c010a661:	0f b6 00             	movzbl (%eax),%eax
c010a664:	0f b6 d8             	movzbl %al,%ebx
c010a667:	83 fb 25             	cmp    $0x25,%ebx
c010a66a:	75 d5                	jne    c010a641 <vprintfmt+0xe>
        }

        // Process a %-escape sequence
        char padc = ' ';
c010a66c:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c010a670:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c010a677:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010a67a:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c010a67d:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010a684:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a687:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c010a68a:	8b 45 10             	mov    0x10(%ebp),%eax
c010a68d:	8d 50 01             	lea    0x1(%eax),%edx
c010a690:	89 55 10             	mov    %edx,0x10(%ebp)
c010a693:	0f b6 00             	movzbl (%eax),%eax
c010a696:	0f b6 d8             	movzbl %al,%ebx
c010a699:	8d 43 dd             	lea    -0x23(%ebx),%eax
c010a69c:	83 f8 55             	cmp    $0x55,%eax
c010a69f:	0f 87 06 03 00 00    	ja     c010a9ab <vprintfmt+0x378>
c010a6a5:	8b 04 85 54 d0 10 c0 	mov    -0x3fef2fac(,%eax,4),%eax
c010a6ac:	3e ff e0             	notrack jmp *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c010a6af:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c010a6b3:	eb d5                	jmp    c010a68a <vprintfmt+0x57>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c010a6b5:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c010a6b9:	eb cf                	jmp    c010a68a <vprintfmt+0x57>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c010a6bb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c010a6c2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010a6c5:	89 d0                	mov    %edx,%eax
c010a6c7:	c1 e0 02             	shl    $0x2,%eax
c010a6ca:	01 d0                	add    %edx,%eax
c010a6cc:	01 c0                	add    %eax,%eax
c010a6ce:	01 d8                	add    %ebx,%eax
c010a6d0:	83 e8 30             	sub    $0x30,%eax
c010a6d3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c010a6d6:	8b 45 10             	mov    0x10(%ebp),%eax
c010a6d9:	0f b6 00             	movzbl (%eax),%eax
c010a6dc:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c010a6df:	83 fb 2f             	cmp    $0x2f,%ebx
c010a6e2:	7e 39                	jle    c010a71d <vprintfmt+0xea>
c010a6e4:	83 fb 39             	cmp    $0x39,%ebx
c010a6e7:	7f 34                	jg     c010a71d <vprintfmt+0xea>
            for (precision = 0; ; ++ fmt) {
c010a6e9:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
c010a6ed:	eb d3                	jmp    c010a6c2 <vprintfmt+0x8f>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
c010a6ef:	8b 45 14             	mov    0x14(%ebp),%eax
c010a6f2:	8d 50 04             	lea    0x4(%eax),%edx
c010a6f5:	89 55 14             	mov    %edx,0x14(%ebp)
c010a6f8:	8b 00                	mov    (%eax),%eax
c010a6fa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c010a6fd:	eb 1f                	jmp    c010a71e <vprintfmt+0xeb>

        case '.':
            if (width < 0)
c010a6ff:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010a703:	79 85                	jns    c010a68a <vprintfmt+0x57>
                width = 0;
c010a705:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c010a70c:	e9 79 ff ff ff       	jmp    c010a68a <vprintfmt+0x57>

        case '#':
            altflag = 1;
c010a711:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c010a718:	e9 6d ff ff ff       	jmp    c010a68a <vprintfmt+0x57>
            goto process_precision;
c010a71d:	90                   	nop

        process_precision:
            if (width < 0)
c010a71e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010a722:	0f 89 62 ff ff ff    	jns    c010a68a <vprintfmt+0x57>
                width = precision, precision = -1;
c010a728:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010a72b:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010a72e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c010a735:	e9 50 ff ff ff       	jmp    c010a68a <vprintfmt+0x57>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c010a73a:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
c010a73e:	e9 47 ff ff ff       	jmp    c010a68a <vprintfmt+0x57>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c010a743:	8b 45 14             	mov    0x14(%ebp),%eax
c010a746:	8d 50 04             	lea    0x4(%eax),%edx
c010a749:	89 55 14             	mov    %edx,0x14(%ebp)
c010a74c:	8b 00                	mov    (%eax),%eax
c010a74e:	83 ec 08             	sub    $0x8,%esp
c010a751:	ff 75 0c             	pushl  0xc(%ebp)
c010a754:	50                   	push   %eax
c010a755:	8b 45 08             	mov    0x8(%ebp),%eax
c010a758:	ff d0                	call   *%eax
c010a75a:	83 c4 10             	add    $0x10,%esp
            break;
c010a75d:	e9 71 02 00 00       	jmp    c010a9d3 <vprintfmt+0x3a0>

        // error message
        case 'e':
            err = va_arg(ap, int);
c010a762:	8b 45 14             	mov    0x14(%ebp),%eax
c010a765:	8d 50 04             	lea    0x4(%eax),%edx
c010a768:	89 55 14             	mov    %edx,0x14(%ebp)
c010a76b:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c010a76d:	85 db                	test   %ebx,%ebx
c010a76f:	79 02                	jns    c010a773 <vprintfmt+0x140>
                err = -err;
c010a771:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c010a773:	83 fb 06             	cmp    $0x6,%ebx
c010a776:	7f 0b                	jg     c010a783 <vprintfmt+0x150>
c010a778:	8b 34 9d 14 d0 10 c0 	mov    -0x3fef2fec(,%ebx,4),%esi
c010a77f:	85 f6                	test   %esi,%esi
c010a781:	75 19                	jne    c010a79c <vprintfmt+0x169>
                printfmt(putch, putdat, "error %d", err);
c010a783:	53                   	push   %ebx
c010a784:	68 41 d0 10 c0       	push   $0xc010d041
c010a789:	ff 75 0c             	pushl  0xc(%ebp)
c010a78c:	ff 75 08             	pushl  0x8(%ebp)
c010a78f:	e8 77 fe ff ff       	call   c010a60b <printfmt>
c010a794:	83 c4 10             	add    $0x10,%esp
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c010a797:	e9 37 02 00 00       	jmp    c010a9d3 <vprintfmt+0x3a0>
                printfmt(putch, putdat, "%s", p);
c010a79c:	56                   	push   %esi
c010a79d:	68 4a d0 10 c0       	push   $0xc010d04a
c010a7a2:	ff 75 0c             	pushl  0xc(%ebp)
c010a7a5:	ff 75 08             	pushl  0x8(%ebp)
c010a7a8:	e8 5e fe ff ff       	call   c010a60b <printfmt>
c010a7ad:	83 c4 10             	add    $0x10,%esp
            break;
c010a7b0:	e9 1e 02 00 00       	jmp    c010a9d3 <vprintfmt+0x3a0>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c010a7b5:	8b 45 14             	mov    0x14(%ebp),%eax
c010a7b8:	8d 50 04             	lea    0x4(%eax),%edx
c010a7bb:	89 55 14             	mov    %edx,0x14(%ebp)
c010a7be:	8b 30                	mov    (%eax),%esi
c010a7c0:	85 f6                	test   %esi,%esi
c010a7c2:	75 05                	jne    c010a7c9 <vprintfmt+0x196>
                p = "(null)";
c010a7c4:	be 4d d0 10 c0       	mov    $0xc010d04d,%esi
            }
            if (width > 0 && padc != '-') {
c010a7c9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010a7cd:	7e 76                	jle    c010a845 <vprintfmt+0x212>
c010a7cf:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c010a7d3:	74 70                	je     c010a845 <vprintfmt+0x212>
                for (width -= strnlen(p, precision); width > 0; width --) {
c010a7d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010a7d8:	83 ec 08             	sub    $0x8,%esp
c010a7db:	50                   	push   %eax
c010a7dc:	56                   	push   %esi
c010a7dd:	e8 db f7 ff ff       	call   c0109fbd <strnlen>
c010a7e2:	83 c4 10             	add    $0x10,%esp
c010a7e5:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010a7e8:	29 c2                	sub    %eax,%edx
c010a7ea:	89 d0                	mov    %edx,%eax
c010a7ec:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010a7ef:	eb 17                	jmp    c010a808 <vprintfmt+0x1d5>
                    putch(padc, putdat);
c010a7f1:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c010a7f5:	83 ec 08             	sub    $0x8,%esp
c010a7f8:	ff 75 0c             	pushl  0xc(%ebp)
c010a7fb:	50                   	push   %eax
c010a7fc:	8b 45 08             	mov    0x8(%ebp),%eax
c010a7ff:	ff d0                	call   *%eax
c010a801:	83 c4 10             	add    $0x10,%esp
                for (width -= strnlen(p, precision); width > 0; width --) {
c010a804:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c010a808:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010a80c:	7f e3                	jg     c010a7f1 <vprintfmt+0x1be>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c010a80e:	eb 35                	jmp    c010a845 <vprintfmt+0x212>
                if (altflag && (ch < ' ' || ch > '~')) {
c010a810:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010a814:	74 1c                	je     c010a832 <vprintfmt+0x1ff>
c010a816:	83 fb 1f             	cmp    $0x1f,%ebx
c010a819:	7e 05                	jle    c010a820 <vprintfmt+0x1ed>
c010a81b:	83 fb 7e             	cmp    $0x7e,%ebx
c010a81e:	7e 12                	jle    c010a832 <vprintfmt+0x1ff>
                    putch('?', putdat);
c010a820:	83 ec 08             	sub    $0x8,%esp
c010a823:	ff 75 0c             	pushl  0xc(%ebp)
c010a826:	6a 3f                	push   $0x3f
c010a828:	8b 45 08             	mov    0x8(%ebp),%eax
c010a82b:	ff d0                	call   *%eax
c010a82d:	83 c4 10             	add    $0x10,%esp
c010a830:	eb 0f                	jmp    c010a841 <vprintfmt+0x20e>
                }
                else {
                    putch(ch, putdat);
c010a832:	83 ec 08             	sub    $0x8,%esp
c010a835:	ff 75 0c             	pushl  0xc(%ebp)
c010a838:	53                   	push   %ebx
c010a839:	8b 45 08             	mov    0x8(%ebp),%eax
c010a83c:	ff d0                	call   *%eax
c010a83e:	83 c4 10             	add    $0x10,%esp
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c010a841:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c010a845:	89 f0                	mov    %esi,%eax
c010a847:	8d 70 01             	lea    0x1(%eax),%esi
c010a84a:	0f b6 00             	movzbl (%eax),%eax
c010a84d:	0f be d8             	movsbl %al,%ebx
c010a850:	85 db                	test   %ebx,%ebx
c010a852:	74 26                	je     c010a87a <vprintfmt+0x247>
c010a854:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010a858:	78 b6                	js     c010a810 <vprintfmt+0x1dd>
c010a85a:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
c010a85e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010a862:	79 ac                	jns    c010a810 <vprintfmt+0x1dd>
                }
            }
            for (; width > 0; width --) {
c010a864:	eb 14                	jmp    c010a87a <vprintfmt+0x247>
                putch(' ', putdat);
c010a866:	83 ec 08             	sub    $0x8,%esp
c010a869:	ff 75 0c             	pushl  0xc(%ebp)
c010a86c:	6a 20                	push   $0x20
c010a86e:	8b 45 08             	mov    0x8(%ebp),%eax
c010a871:	ff d0                	call   *%eax
c010a873:	83 c4 10             	add    $0x10,%esp
            for (; width > 0; width --) {
c010a876:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c010a87a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010a87e:	7f e6                	jg     c010a866 <vprintfmt+0x233>
            }
            break;
c010a880:	e9 4e 01 00 00       	jmp    c010a9d3 <vprintfmt+0x3a0>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c010a885:	83 ec 08             	sub    $0x8,%esp
c010a888:	ff 75 e0             	pushl  -0x20(%ebp)
c010a88b:	8d 45 14             	lea    0x14(%ebp),%eax
c010a88e:	50                   	push   %eax
c010a88f:	e8 2c fd ff ff       	call   c010a5c0 <getint>
c010a894:	83 c4 10             	add    $0x10,%esp
c010a897:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a89a:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c010a89d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a8a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010a8a3:	85 d2                	test   %edx,%edx
c010a8a5:	79 23                	jns    c010a8ca <vprintfmt+0x297>
                putch('-', putdat);
c010a8a7:	83 ec 08             	sub    $0x8,%esp
c010a8aa:	ff 75 0c             	pushl  0xc(%ebp)
c010a8ad:	6a 2d                	push   $0x2d
c010a8af:	8b 45 08             	mov    0x8(%ebp),%eax
c010a8b2:	ff d0                	call   *%eax
c010a8b4:	83 c4 10             	add    $0x10,%esp
                num = -(long long)num;
c010a8b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a8ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010a8bd:	f7 d8                	neg    %eax
c010a8bf:	83 d2 00             	adc    $0x0,%edx
c010a8c2:	f7 da                	neg    %edx
c010a8c4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a8c7:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c010a8ca:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c010a8d1:	e9 9f 00 00 00       	jmp    c010a975 <vprintfmt+0x342>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c010a8d6:	83 ec 08             	sub    $0x8,%esp
c010a8d9:	ff 75 e0             	pushl  -0x20(%ebp)
c010a8dc:	8d 45 14             	lea    0x14(%ebp),%eax
c010a8df:	50                   	push   %eax
c010a8e0:	e8 88 fc ff ff       	call   c010a56d <getuint>
c010a8e5:	83 c4 10             	add    $0x10,%esp
c010a8e8:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a8eb:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c010a8ee:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c010a8f5:	eb 7e                	jmp    c010a975 <vprintfmt+0x342>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c010a8f7:	83 ec 08             	sub    $0x8,%esp
c010a8fa:	ff 75 e0             	pushl  -0x20(%ebp)
c010a8fd:	8d 45 14             	lea    0x14(%ebp),%eax
c010a900:	50                   	push   %eax
c010a901:	e8 67 fc ff ff       	call   c010a56d <getuint>
c010a906:	83 c4 10             	add    $0x10,%esp
c010a909:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a90c:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c010a90f:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c010a916:	eb 5d                	jmp    c010a975 <vprintfmt+0x342>

        // pointer
        case 'p':
            putch('0', putdat);
c010a918:	83 ec 08             	sub    $0x8,%esp
c010a91b:	ff 75 0c             	pushl  0xc(%ebp)
c010a91e:	6a 30                	push   $0x30
c010a920:	8b 45 08             	mov    0x8(%ebp),%eax
c010a923:	ff d0                	call   *%eax
c010a925:	83 c4 10             	add    $0x10,%esp
            putch('x', putdat);
c010a928:	83 ec 08             	sub    $0x8,%esp
c010a92b:	ff 75 0c             	pushl  0xc(%ebp)
c010a92e:	6a 78                	push   $0x78
c010a930:	8b 45 08             	mov    0x8(%ebp),%eax
c010a933:	ff d0                	call   *%eax
c010a935:	83 c4 10             	add    $0x10,%esp
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c010a938:	8b 45 14             	mov    0x14(%ebp),%eax
c010a93b:	8d 50 04             	lea    0x4(%eax),%edx
c010a93e:	89 55 14             	mov    %edx,0x14(%ebp)
c010a941:	8b 00                	mov    (%eax),%eax
c010a943:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a946:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c010a94d:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c010a954:	eb 1f                	jmp    c010a975 <vprintfmt+0x342>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c010a956:	83 ec 08             	sub    $0x8,%esp
c010a959:	ff 75 e0             	pushl  -0x20(%ebp)
c010a95c:	8d 45 14             	lea    0x14(%ebp),%eax
c010a95f:	50                   	push   %eax
c010a960:	e8 08 fc ff ff       	call   c010a56d <getuint>
c010a965:	83 c4 10             	add    $0x10,%esp
c010a968:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a96b:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c010a96e:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c010a975:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c010a979:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a97c:	83 ec 04             	sub    $0x4,%esp
c010a97f:	52                   	push   %edx
c010a980:	ff 75 e8             	pushl  -0x18(%ebp)
c010a983:	50                   	push   %eax
c010a984:	ff 75 f4             	pushl  -0xc(%ebp)
c010a987:	ff 75 f0             	pushl  -0x10(%ebp)
c010a98a:	ff 75 0c             	pushl  0xc(%ebp)
c010a98d:	ff 75 08             	pushl  0x8(%ebp)
c010a990:	e8 e8 fa ff ff       	call   c010a47d <printnum>
c010a995:	83 c4 20             	add    $0x20,%esp
            break;
c010a998:	eb 39                	jmp    c010a9d3 <vprintfmt+0x3a0>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c010a99a:	83 ec 08             	sub    $0x8,%esp
c010a99d:	ff 75 0c             	pushl  0xc(%ebp)
c010a9a0:	53                   	push   %ebx
c010a9a1:	8b 45 08             	mov    0x8(%ebp),%eax
c010a9a4:	ff d0                	call   *%eax
c010a9a6:	83 c4 10             	add    $0x10,%esp
            break;
c010a9a9:	eb 28                	jmp    c010a9d3 <vprintfmt+0x3a0>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c010a9ab:	83 ec 08             	sub    $0x8,%esp
c010a9ae:	ff 75 0c             	pushl  0xc(%ebp)
c010a9b1:	6a 25                	push   $0x25
c010a9b3:	8b 45 08             	mov    0x8(%ebp),%eax
c010a9b6:	ff d0                	call   *%eax
c010a9b8:	83 c4 10             	add    $0x10,%esp
            for (fmt --; fmt[-1] != '%'; fmt --)
c010a9bb:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c010a9bf:	eb 04                	jmp    c010a9c5 <vprintfmt+0x392>
c010a9c1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c010a9c5:	8b 45 10             	mov    0x10(%ebp),%eax
c010a9c8:	83 e8 01             	sub    $0x1,%eax
c010a9cb:	0f b6 00             	movzbl (%eax),%eax
c010a9ce:	3c 25                	cmp    $0x25,%al
c010a9d0:	75 ef                	jne    c010a9c1 <vprintfmt+0x38e>
                /* do nothing */;
            break;
c010a9d2:	90                   	nop
    while (1) {
c010a9d3:	e9 67 fc ff ff       	jmp    c010a63f <vprintfmt+0xc>
                return;
c010a9d8:	90                   	nop
        }
    }
}
c010a9d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
c010a9dc:	5b                   	pop    %ebx
c010a9dd:	5e                   	pop    %esi
c010a9de:	5d                   	pop    %ebp
c010a9df:	c3                   	ret    

c010a9e0 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c010a9e0:	f3 0f 1e fb          	endbr32 
c010a9e4:	55                   	push   %ebp
c010a9e5:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c010a9e7:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a9ea:	8b 40 08             	mov    0x8(%eax),%eax
c010a9ed:	8d 50 01             	lea    0x1(%eax),%edx
c010a9f0:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a9f3:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c010a9f6:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a9f9:	8b 10                	mov    (%eax),%edx
c010a9fb:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a9fe:	8b 40 04             	mov    0x4(%eax),%eax
c010aa01:	39 c2                	cmp    %eax,%edx
c010aa03:	73 12                	jae    c010aa17 <sprintputch+0x37>
        *b->buf ++ = ch;
c010aa05:	8b 45 0c             	mov    0xc(%ebp),%eax
c010aa08:	8b 00                	mov    (%eax),%eax
c010aa0a:	8d 48 01             	lea    0x1(%eax),%ecx
c010aa0d:	8b 55 0c             	mov    0xc(%ebp),%edx
c010aa10:	89 0a                	mov    %ecx,(%edx)
c010aa12:	8b 55 08             	mov    0x8(%ebp),%edx
c010aa15:	88 10                	mov    %dl,(%eax)
    }
}
c010aa17:	90                   	nop
c010aa18:	5d                   	pop    %ebp
c010aa19:	c3                   	ret    

c010aa1a <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c010aa1a:	f3 0f 1e fb          	endbr32 
c010aa1e:	55                   	push   %ebp
c010aa1f:	89 e5                	mov    %esp,%ebp
c010aa21:	83 ec 18             	sub    $0x18,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c010aa24:	8d 45 14             	lea    0x14(%ebp),%eax
c010aa27:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c010aa2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010aa2d:	50                   	push   %eax
c010aa2e:	ff 75 10             	pushl  0x10(%ebp)
c010aa31:	ff 75 0c             	pushl  0xc(%ebp)
c010aa34:	ff 75 08             	pushl  0x8(%ebp)
c010aa37:	e8 0b 00 00 00       	call   c010aa47 <vsnprintf>
c010aa3c:	83 c4 10             	add    $0x10,%esp
c010aa3f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c010aa42:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010aa45:	c9                   	leave  
c010aa46:	c3                   	ret    

c010aa47 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c010aa47:	f3 0f 1e fb          	endbr32 
c010aa4b:	55                   	push   %ebp
c010aa4c:	89 e5                	mov    %esp,%ebp
c010aa4e:	83 ec 18             	sub    $0x18,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c010aa51:	8b 45 08             	mov    0x8(%ebp),%eax
c010aa54:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010aa57:	8b 45 0c             	mov    0xc(%ebp),%eax
c010aa5a:	8d 50 ff             	lea    -0x1(%eax),%edx
c010aa5d:	8b 45 08             	mov    0x8(%ebp),%eax
c010aa60:	01 d0                	add    %edx,%eax
c010aa62:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010aa65:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c010aa6c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010aa70:	74 0a                	je     c010aa7c <vsnprintf+0x35>
c010aa72:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010aa75:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010aa78:	39 c2                	cmp    %eax,%edx
c010aa7a:	76 07                	jbe    c010aa83 <vsnprintf+0x3c>
        return -E_INVAL;
c010aa7c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c010aa81:	eb 20                	jmp    c010aaa3 <vsnprintf+0x5c>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c010aa83:	ff 75 14             	pushl  0x14(%ebp)
c010aa86:	ff 75 10             	pushl  0x10(%ebp)
c010aa89:	8d 45 ec             	lea    -0x14(%ebp),%eax
c010aa8c:	50                   	push   %eax
c010aa8d:	68 e0 a9 10 c0       	push   $0xc010a9e0
c010aa92:	e8 9c fb ff ff       	call   c010a633 <vprintfmt>
c010aa97:	83 c4 10             	add    $0x10,%esp
    // null terminate the buffer
    *b.buf = '\0';
c010aa9a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010aa9d:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c010aaa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010aaa3:	c9                   	leave  
c010aaa4:	c3                   	ret    

c010aaa5 <hash32>:
 * @bits:   the number of bits in a return value
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
c010aaa5:	f3 0f 1e fb          	endbr32 
c010aaa9:	55                   	push   %ebp
c010aaaa:	89 e5                	mov    %esp,%ebp
c010aaac:	83 ec 10             	sub    $0x10,%esp
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
c010aaaf:	8b 45 08             	mov    0x8(%ebp),%eax
c010aab2:	69 c0 01 00 37 9e    	imul   $0x9e370001,%eax,%eax
c010aab8:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (hash >> (32 - bits));
c010aabb:	b8 20 00 00 00       	mov    $0x20,%eax
c010aac0:	2b 45 0c             	sub    0xc(%ebp),%eax
c010aac3:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010aac6:	89 c1                	mov    %eax,%ecx
c010aac8:	d3 ea                	shr    %cl,%edx
c010aaca:	89 d0                	mov    %edx,%eax
}
c010aacc:	c9                   	leave  
c010aacd:	c3                   	ret    

c010aace <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
c010aace:	f3 0f 1e fb          	endbr32 
c010aad2:	55                   	push   %ebp
c010aad3:	89 e5                	mov    %esp,%ebp
c010aad5:	57                   	push   %edi
c010aad6:	56                   	push   %esi
c010aad7:	53                   	push   %ebx
c010aad8:	83 ec 24             	sub    $0x24,%esp
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
c010aadb:	a1 88 ba 12 c0       	mov    0xc012ba88,%eax
c010aae0:	8b 15 8c ba 12 c0    	mov    0xc012ba8c,%edx
c010aae6:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
c010aaec:	6b f0 05             	imul   $0x5,%eax,%esi
c010aaef:	01 fe                	add    %edi,%esi
c010aaf1:	bf 6d e6 ec de       	mov    $0xdeece66d,%edi
c010aaf6:	f7 e7                	mul    %edi
c010aaf8:	01 d6                	add    %edx,%esi
c010aafa:	89 f2                	mov    %esi,%edx
c010aafc:	83 c0 0b             	add    $0xb,%eax
c010aaff:	83 d2 00             	adc    $0x0,%edx
c010ab02:	89 c7                	mov    %eax,%edi
c010ab04:	83 e7 ff             	and    $0xffffffff,%edi
c010ab07:	89 f9                	mov    %edi,%ecx
c010ab09:	0f b7 da             	movzwl %dx,%ebx
c010ab0c:	89 0d 88 ba 12 c0    	mov    %ecx,0xc012ba88
c010ab12:	89 1d 8c ba 12 c0    	mov    %ebx,0xc012ba8c
    unsigned long long result = (next >> 12);
c010ab18:	a1 88 ba 12 c0       	mov    0xc012ba88,%eax
c010ab1d:	8b 15 8c ba 12 c0    	mov    0xc012ba8c,%edx
c010ab23:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c010ab27:	c1 ea 0c             	shr    $0xc,%edx
c010ab2a:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010ab2d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
c010ab30:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
c010ab37:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010ab3a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010ab3d:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010ab40:	89 55 e8             	mov    %edx,-0x18(%ebp)
c010ab43:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010ab46:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010ab49:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010ab4d:	74 1c                	je     c010ab6b <rand+0x9d>
c010ab4f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010ab52:	ba 00 00 00 00       	mov    $0x0,%edx
c010ab57:	f7 75 dc             	divl   -0x24(%ebp)
c010ab5a:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010ab5d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010ab60:	ba 00 00 00 00       	mov    $0x0,%edx
c010ab65:	f7 75 dc             	divl   -0x24(%ebp)
c010ab68:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010ab6b:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010ab6e:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010ab71:	f7 75 dc             	divl   -0x24(%ebp)
c010ab74:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010ab77:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010ab7a:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010ab7d:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010ab80:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010ab83:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010ab86:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
c010ab89:	83 c4 24             	add    $0x24,%esp
c010ab8c:	5b                   	pop    %ebx
c010ab8d:	5e                   	pop    %esi
c010ab8e:	5f                   	pop    %edi
c010ab8f:	5d                   	pop    %ebp
c010ab90:	c3                   	ret    

c010ab91 <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
c010ab91:	f3 0f 1e fb          	endbr32 
c010ab95:	55                   	push   %ebp
c010ab96:	89 e5                	mov    %esp,%ebp
    next = seed;
c010ab98:	8b 45 08             	mov    0x8(%ebp),%eax
c010ab9b:	ba 00 00 00 00       	mov    $0x0,%edx
c010aba0:	a3 88 ba 12 c0       	mov    %eax,0xc012ba88
c010aba5:	89 15 8c ba 12 c0    	mov    %edx,0xc012ba8c
}
c010abab:	90                   	nop
c010abac:	5d                   	pop    %ebp
c010abad:	c3                   	ret    
