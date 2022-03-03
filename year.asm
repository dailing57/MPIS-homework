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
	
	li $v0, 5 #������
	syscall
	la $s7, ($v0) #��ݷ���s7

	la $s4, day

	li $v0, 4		#�ָ���
	la $a0, seperateLine
	syscall
	
	li $v0,4
	la $a0, titlespace #��ӡ����Ŀո�
	syscall
	
	li $v0,1
	la $a0, ($s7) #��ӡ�������
	syscall
	
	li $s0, 0x0a		#���з�
	la $s1, calendar	#�����׵�ַ
	la $s2, day		#�·����׵�ַ
	li $s3, 6		#���ڱȽϹ���
	li $s4, 0x39		#�����Ƚϡ�9��
	li $s5, 0x30		#�����Ƚϡ�0��
	jal pre			#Ԥ��������λ��Ϊ�ո�
	addi $t1, $s1, 3440
	li $t0, 37
	
pre_row:	sb $s0, 0($t1)		#Ԥ������
	addi $t1, $t1, -93
	addi $t0, $t0, -1
	blez $t0, pre_content
	b pre_row
	
pre_content:		
	li $a0, 2		#��
	li $a1, 12		#��
	la $a2, MONTH		#�·��׵�ַ
	jal setmon		#�����·�����
	addi $t1, $s1, 136	#�����2019
	li $a0, 3		#��
	li $a1, 0		#��
	la $a2, WEEK		#�����׵�ַ
	jal setweek		#������������
	
	li $t5, 2021	
	li $t1, 4 #2021.1.1�����壬�ҵ������һ�������ڼ�
	li $t2, 1
	li $t3, 1	
	la $t4, day	
	rep1:bge $t5,$s7,yeard      #���С���������
		rep2: bgt $t2,12,month				#�·�С�ڵ���12
		li $t0,0
		lw $t6,($t4)	#t6�ǵ�ǰ������
		bne $t2,2,nxt
		jal check	
		add $t6,$t6,$t0
		nxt:
			rep3: bgt $t3,$t6,dayd			#����С�ڵ�������
				  addi $t3,$t3,1
				  addi $t1,$t1,1
				  blt $t1,7,adddate
				  li $t1,0
				  adddate:
				  b rep3
			dayd:  addi $t2,$t2,1   			#����������ǰ�µ�����֮��������Ϊ1���·ݼ�һ
				  li $t3,1	
				  bgt $t2,12,month
				  addi $t4,$t4,4			#����������Ϊ��һ���µ�����  	  
				  b rep2
		month: li   $t2,1	#��������12֮������Ϊ1��������һ
			   subi $t4,$t4,44
			   addi $t5,$t5,1
			   b rep1	
	yeard: 		    
	li $t7, 4		#��ѭ��������
	li $a0, 4		#������
	li $s6, 1		#��
dealDate:	li $a1, 0		#������
	li $t8, 3		#��ѭ��������
	loopp4:			#��������
		jal setdate
		addi $a1, $a1, 32	#��һ���£��У�
		addi $s6, $s6, 1
		addi $t8, $t8, -1
		blez $t8, nextline4
		b loopp4
	nextline4:
		add $a0, $a0, 9		#��һ��
		bgt $s6, 12, PRINT
		#add $t7, $t7, -1
		blez $t7, PRINT
	b dealDate
	
PRINT:li $v0, 4		#��ӡ
	la $a0, calendar
	syscall
	li $v0, 4
	la $a0, seperateLine
	syscall
	li $v0, 10
	syscall


pre:	li $t0, 0x20			#ȫ����Ϊ�ո�
	move $t1, $s1
	li $t2, 3598
	loop:	sb $t0, 0($t1)
		addi $t2, $t2, -1
		addi $t1, $t1, 1
		bltz $t2, endpre
		b loop
	endpre:	jr $ra

setmon:	
	li $t8, 4				#��ѭ������
	loop2:	mul $t0, $a0, 93		#������
		move $t1, $a1			#��
		li $t9, 3			#��ѭ������
		add $t0, $t1, $t0		#��������
		add $t2, $s1, $t0		#calendar��ַ
		loopp2:				#�����·�
			lb $t3, 0($a2)
			sb $t3, 0($t2)
			lb $t3, 1($a2)
			sb $t3, 1($t2)
			lb $t3, 2($a2)
			sb $t3, 2($t2)
			addi $a2, $a2, 3	#��һ���·�����
			addi $t2, $t2, 32	#��һ��
			addi $t9, $t9, -1
			blez $t9, nextline2
			b loopp2
		nextline2: addi $a0, $a0, 9	#��һ��
			addi $t8, $t8, -1
			blez $t8, break2
		b loop2
	break2:	jr $ra
	
setweek:
	move $t0, $a0			#��
	move $t1, $a1			#��
	move $t2, $a2			#���ڵ�ַ
	li $t9, 4			#��ѭ������
	loop3:	mul $t3, $t0, 93
		li $t8, 3		#��ѭ������
		add $t4, $t3, $t1
		add $t5, $t4, $s1	#������ʼ��ַ
		repp3:	
			move $t2, $a2
			fillweek:	#�������ڣ�����0����
				lb $t6, 0($t2)
				beqz $t6, nextcol3
				sb $t6, 0($t5)
				addi $t2, $t2, 1
				addi $t5, $t5, 1
				b fillweek
			nextcol3:
				addi $t5, $t5, 5	#��һ��
				addi $t8, $t8, -1
				blez $t8, nextrow3
			b repp3
		nextrow3:
			addi $t0, $t0, 9	#��һ��
			addi $t9, $t9, -1
			blez $t9, break3
		b loop3
	break3:	jr $ra


setdate:
	move $t2, $a0			#��������
	move $t3, $a1			#���������
	mul $t2, $t2, 93		
	sll $t4, $t1, 2			#�̳��ϸ������һ�죬���ƫ����
	add $t4, $t4, $t2		
	add $t4, $t4, $t3		
	add $t4, $t4, $s1		#����ַ
	addi $t4, $t4, 1
	lw $t9, 0($s2)			#����&ѭ������
	
		move $t5,$s7
		bne $t9,28,nxt2
		li $t0,0
		move $a3,$ra
		jal check
		move $ra,$a3	
		add $t9,$t9,$t0
		nxt2:
	
	addi $s2, $s2, 4
	li $t5, 0x30			#ʮλ��
	li $t6, 0x31			#��λ��
	loop5:	bne $t5, $s5, next5	#ʮλ����Ϊ0����д
		b dealCarry
	next5:	sb $t5, 0($t4)
	dealCarry: 	
		sb $t6, 1($t4)
		addi $t6, $t6, 1	#�������ּ�1
		bgt  $t6, $s4, iscarry 	#�жϽ�λ
		b notcarry
	iscarry: addi $t5, $t5, 1	#��λ
		addi $t6, $t6, -10
	notcarry:
		addi $t4, $t4, 4
		addi $t1, $t1, 1
		bgt $t1, $s3, isendl2	#�ж��Ƿ��������컻��
		b notendl2
	isendl2: addi $t1, $t1, -7
		addi $t4, $t4, 65	#���м���������
	notendl2:
		addi $t9, $t9, -1
		blez $t9, ret5
		b loop5
	ret5: jr $ra
	
	check:div $t0,$t5,4#����Ƿ�������,t0�����淵��ֵ
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
