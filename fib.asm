.data
N: .word
array: .space 2048
str1: .asciiz "input N: "
str2: .asciiz "output:\n"
nxtline: .asciiz "\n"
kk: .asciiz " "
err1: .asciiz "N is not greater than 0\n"
err2: .asciiz "OverFlow!\n"
buf:	.space 20   #1个空格+2字符”0x”+8字符+1个表示字符串结束的空字符	
	.globl main
	.text
main:					#主函数
	li $v0,4
	la $a0,str1			# 提示输入
	syscall
	li $v0,5			#输入
	syscall
	la $a2,($v0)		#把N放到a2
	la $a1,array		#把array放到a1
	li $v0,4
	la $a0,str2			#提示输出
	syscall
	la $a0,($a2)		#N的值赋给a0
	li $t1,2
	jal FIB
	jal output
	
FIB:					#得出斐波那契数列
	bltz $a0,outerr		#检查N是否大于0
	li $t7,1			#临时储存1
	sw $t7,4($a1)		#array[0]=1
	sw $t7,12($a1)		#array[1]=1
	loop0:				#循环
	bge $t1,$a0,ret  	#t1没有超过a0就一直循环
	move $t0,$t1		#t0作地址，t1作下标
	mulu $t0,$t0,8
	add $t0,$a1,$t0		#得出当前这个数的地址
	
	lw $t4,-16($t0)		#前两个数
	lw $t5,-12($t0)
	lw $t6,-8($t0)		#前一个数
	lw $t7,-4($t0)
	addu $t3,$t5,$t7	#前两个数相加
	sltu $t2,$t3,$t7
	addu $t2,$t2,$t4
	addu $t2,$t2,$t6
	
	bgtu $t2,$t7,overflow#如果相加比前一个数小就是溢出
	sw $t2,($t0)		#把t7赋给t0所指的位置
	sw $t3,4($t0)
	
	addi $t1,$t1,1		#计数器加一
	b loop0

output:					#输出函数		
	li $t5,0			#t5计数
	move $t6,$a0 		#t6存上界
	la $t4,array+4 		#t4用来遍历数组
loop1:
    bge $t5, $t6,exit	#大于或等于上界就退出
    move $a0,$t5
    
    li $v0,1			#下角标
    syscall
    li $v0,4
    
    la $a0,kk			#空格
    syscall
    
    lw $t2, 0($t4) 		#赋值
    move $a0, $t2
    bgeu $t5,46,hex
    li $v0, 1      		#输出十进制数
    syscall
hex:    
    move $a3,$t2
    lw $a0,-4($t4)
    
    addi $t4, $t4, 8	#下标后移
    jal Hexout			#输出十六进制数
    la $a0,buf
   	li $v0,4
    syscall
	jal endl			#换行
    addi $t5, $t5, 1	#计数器加一
    j loop1
	
endl:					#换行函数
	la $a0,nxtline
	li $v0,4
	syscall
	jr $ra

ret:
	jr $ra

Hexout:					#输出十六进制数
	la $a1, buf			#缓冲区地址
	li $a2, 10	    	#循环次数
	addi $t1, $a1, 10   #从位置buf+10处开始存放16进制数
loop:	
	andi $t0, $a0, 0x0f #取a0的低4位
	srl $a0, $a0, 4    	#a0右移4位
	bge $t0, 10, char 	#t0大于等于10跳转到为A-F处理
	addi $t0, $t0, 0x30	#0的ASCII码为0x30，在原先基础上加0x30
	b put
char:	
	addi $t0, $t0, 0x37 #A的ASCII码为65，在原先基础上加(65-10)
put:	
	sb $t0, ($t1)     	#放置字符
	addi $t1, $t1, -1   #放置位置前移一个字符
	addi $a2, $a2, -1   #将循环次数减1
	bgtz $a2, loop		#判断循环是否结束
out:	
	sb $0, 19($a1)		#将0x00存储到最后一个位置（位置11）
	li $t0, 0x78
	sb $t0, 2($a1)		#将0x78（字符x）存储到位置2
	li $t0, 0x30
	sb $t0, 1($a1)		#将0x30（字符0）存储到位置1
	li $t0, 0x20
	sb $t0, ($a1)	    #将0x20（字符空格）存储到位置0
	
	li $a2,8
	addi $t1, $a1, 18   #从位置buf+18处开始存放16进制数
loop_2:	
	andi $t0, $a3, 0x0f #取a3的低4位
	srl $a3, $a3, 4    	#a0右移4位
	bge $t0, 10, char_2 	#t0大于等于10跳转到为A-F处理
	addi $t0, $t0, 0x30	#0的ASCII码为0x30，在原先基础上加0x30
	b put_2
char_2:	
	addi $t0, $t0, 0x37 #A的ASCII码为65，在原先基础上加(65-10)
put_2:	
	sb $t0, ($t1)     	#放置字符
	addi $t1, $t1, -1   #放置位置前移一个字符
	addi $a2, $a2, -1   #将循环次数减1
	bgtz $a2, loop_2	 #判断循环是否结束	
	jr $ra

overflow: 				#输出溢出的报错并退出
	la $a0,err2
	li $v0,4
	syscall	
	j exit
	
outerr:   				#输出N不大于0的报错并退出
	la $a0,err1
	li $v0,4
	syscall
	j exit
	
exit:					#退出	
	li $v0,10
	syscall
