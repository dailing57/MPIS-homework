	.data
day:	.word 31,28,31,30,31,30,31,31,30,31,30,31
calendar: .space 3600
buf:	.ascii "    "
WEEK:	.asciiz "Mon Tue Wed Thu Fri Sat Sun"
MONTH:	.asciiz "JanFebMarAprMayJunJulAugSepOctNovDec"
endl: .asciiz "\n"
titlespace: .asciiz "                                           "
seperateLine:	.asciiz "\n-------------------------------------------------------------------------------------------\n"
yearinput: .asciiz "Please input a year later than 2021: "	
	.globl main
	.text

main:
	la $a0,yearinput
	li $v0,4
	syscall
	
	li $v0, 5 #读入年
	syscall
	la $s7, ($v0) #年份放在s7

	la $s4, day

	li $v0, 4		#分割线
	la $a0, seperateLine
	syscall
	
	li $v0,4
	la $a0, titlespace #打印标题的空格
	syscall
	
	li $v0,1
	la $a0, ($s7) #打印标题年份
	syscall
	
	li $s0, 0x0a		#换行符
	la $s1, calendar	#年历首地址
	la $s2, day		#月份天首地址
	li $s3, 6		#星期比较工具
	li $s4, 0x39		#用来比较‘9’
	li $s5, 0x30		#用来比较‘0’
	jal pre			#预处理所有位置为空格
	addi $t1, $s1, 3440
	li $t0, 37
	
pre_row:	sb $s0, 0($t1)		#预处理换行
	addi $t1, $t1, -93
	addi $t0, $t0, -1
	blez $t0, pre_content
	b pre_row
	
pre_content:		
	li $a0, 2		#行
	li $a1, 12		#列
	la $a2, MONTH		#月份首地址
	jal setmon		#填入月份名称
	addi $t1, $s1, 136	#大标题2019
	li $a0, 3		#行
	li $a1, 0		#列
	la $a2, WEEK		#星期首地址
	jal setweek		#填入星期名称
	
	li $t5, 2021	
	li $t1, 4 #2021.1.1是周五，找到当年第一天是星期几
	li $t2, 1
	li $t3, 1	
	la $t4, day	
	rep1:bge $t5,$s7,yeard      #年份小于输入年份
		rep2: bgt $t2,12,month				#月份小于等于12
		li $t0,0
		lw $t6,($t4)	#t6是当前月天数
		bne $t2,2,nxt
		jal check	
		add $t6,$t6,$t0
		nxt:
			rep3: bgt $t3,$t6,dayd			#天数小于当月天数
				  addi $t3,$t3,1
				  addi $t1,$t1,1
				  blt $t1,7,adddate
				  li $t1,0
				  adddate:
				  b rep3
			dayd:  addi $t2,$t2,1   			#天数超过当前月的天数之后，天数置为1，月份加一
				  li $t3,1	
				  bgt $t2,12,month
				  addi $t4,$t4,4			#上限天数置为下一个月的天数  	  
				  b rep2
		month: li   $t2,1	#月数超过12之后，月置为1，年数加一
			   subi $t4,$t4,44
			   addi $t5,$t5,1
			   b rep1	
	yeard: 		    
	li $t7, 4		#行循环操作数
	li $a0, 4		#横坐标
	li $s6, 1		#月
dealDate:	li $a1, 0		#列坐标
	li $t8, 3		#列循环操作数
	loopp4:			#填入日期
		jal setdate
		addi $a1, $a1, 32	#下一个月（列）
		addi $s6, $s6, 1
		addi $t8, $t8, -1
		blez $t8, nextline4
		b loopp4
	nextline4:
		add $a0, $a0, 9		#下一行
		bgt $s6, 12, PRINT
		#add $t7, $t7, -1
		blez $t7, PRINT
	b dealDate
	
PRINT:li $v0, 4		#打印
	la $a0, calendar
	syscall
	li $v0, 4
	la $a0, seperateLine
	syscall
	li $v0, 10
	syscall


pre:	li $t0, 0x20			#全部置为空格
	move $t1, $s1
	li $t2, 3598
	loop:	sb $t0, 0($t1)
		addi $t2, $t2, -1
		addi $t1, $t1, 1
		bltz $t2, endpre
		b loop
	endpre:	jr $ra

setmon:	
	li $t8, 4				#行循环次数
	loop2:	mul $t0, $a0, 93		#行坐标
		move $t1, $a1			#列
		li $t9, 3			#列循环次数
		add $t0, $t1, $t0		#行列坐标
		add $t2, $s1, $t0		#calendar地址
		loopp2:				#填入月份
			lb $t3, 0($a2)
			sb $t3, 0($t2)
			lb $t3, 1($a2)
			sb $t3, 1($t2)
			lb $t3, 2($a2)
			sb $t3, 2($t2)
			addi $a2, $a2, 3	#下一个月份名称
			addi $t2, $t2, 32	#下一列
			addi $t9, $t9, -1
			blez $t9, nextline2
			b loopp2
		nextline2: addi $a0, $a0, 9	#下一行
			addi $t8, $t8, -1
			blez $t8, break2
		b loop2
	break2:	jr $ra
	
setweek:
	move $t0, $a0			#行
	move $t1, $a1			#列
	move $t2, $a2			#星期地址
	li $t9, 4			#行循环次数
	loop3:	mul $t3, $t0, 93
		li $t8, 3		#列循环次数
		add $t4, $t3, $t1
		add $t5, $t4, $s1	#该行起始地址
		repp3:	
			move $t2, $a2
			fillweek:	#填入星期，遇到0跳出
				lb $t6, 0($t2)
				beqz $t6, nextcol3
				sb $t6, 0($t5)
				addi $t2, $t2, 1
				addi $t5, $t5, 1
				b fillweek
			nextcol3:
				addi $t5, $t5, 5	#下一列
				addi $t8, $t8, -1
				blez $t8, nextrow3
			b repp3
		nextrow3:
			addi $t0, $t0, 9	#下一行
			addi $t9, $t9, -1
			blez $t9, break3
		b loop3
	break3:	jr $ra


setdate:
	move $t2, $a0			#起点横坐标
	move $t3, $a1			#起点纵坐标
	mul $t2, $t2, 93		
	sll $t4, $t1, 2			#继承上个月最后一天，起点偏移量
	add $t4, $t4, $t2		
	add $t4, $t4, $t3		
	add $t4, $t4, $s1		#起点地址
	addi $t4, $t4, 1
	lw $t9, 0($s2)			#天数&循环次数
	
		move $t5,$s7
		bne $t9,28,nxt2
		li $t0,0
		move $a3,$ra
		jal check
		move $ra,$a3	
		add $t9,$t9,$t0
		nxt2:
	
	addi $s2, $s2, 4
	li $t5, 0x30			#十位数
	li $t6, 0x31			#个位数
	loop5:	bne $t5, $s5, next5	#十位数不为0才填写
		b dealCarry
	next5:	sb $t5, 0($t4)
	dealCarry: 	
		sb $t6, 1($t4)
		addi $t6, $t6, 1	#日期数字加1
		bgt  $t6, $s4, iscarry 	#判断进位
		b notcarry
	iscarry: addi $t5, $t5, 1	#进位
		addi $t6, $t6, -10
	notcarry:
		addi $t4, $t4, 4
		addi $t1, $t1, 1
		bgt $t1, $s3, isendl2	#判断是否到了星期天换行
		b notendl2
	isendl2: addi $t1, $t1, -7
		addi $t4, $t4, 65	#换行继续填数字
	notendl2:
		addi $t9, $t9, -1
		blez $t9, ret5
		b loop5
	ret5: jr $ra
	
	check:div $t0,$t5,4#检查是否是闰年,t0用来存返回值
		  mfhi $t0
		  beq $t0,0,else1
		  li $t0,0
		  jr $ra
		  else1:
		  div $t7,$t5,400
		  mfhi $t7
		  bne $t7,0,else2
		  li $t0,0
		  jr $ra
		  else2:li $t0,1
		  jr $ra
