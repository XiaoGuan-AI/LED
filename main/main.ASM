 R_CNT EQU 31H		;列码R_NCT=31H单元
NUMB EQU 32H		;行码NUMB=32H单元
TCOUNT EQU 33H		;拉幕计数值TCOUNT=33H单元
	ORG 00H			;程序起始地址
	LJMP START  	
	ORG 0BH			;中断入口地址
	LJMP INT_T0		
	ORG 30H			;子程序入口地址
START:					;主程序开始
	MOV R0, #00H    	;每列的行码起始序号置0
	MOV R_CNT, #00H		;列:初值00送到31H单元
	MOV NUMB, #00H		;行:初值00送到32H单元
	MOV TCOUNT, #00H	;计数单元初值置0
	MOV TMOD, #01H		;计数定时器选用16位的计数器，工作在方式1
	MOV TH0, #(65536-5000)/256		;定时5ms。定时器高位初值为236
	MOV TL0, #(65536-5000) MOD 256	;定时器低位初值为120
	SETB TR0			;启动C/T的定时器T0
	MOV IE, #82H		;CPU开中断
	SJMP $				;中断等待
INT_T0:		
	MOV TH0, #(65536-5000)/256 		;定时5ms，设置定时器T0高位初值为236
	MOV TL0, #(65536-5000)/256		; 定时器T0低位初值为120
	MOV DPTR, #TAB			;读列码表首地址，放入DPTR
	MOV A, R_CNT			;读列码偏移地址，放入A中
	MOVC A, @A+DPTR	
		;基址变址寻址将寻到的列码数据放入A中
	MOV P3,A 				;将列码数据送P3口输出
	MOV DPTR, #NUB			;装入显示数据的地址
	MOV A, NUMB				;显示幕次的偏移地址
	MOVC A, @A+DPTR	
	;寻到数据的行码地址
	MOV P0, A 				;将该地址值输出
	INC NUMB				;行码地址加1
NEXT1:						
	INC R_CNT 				;扫描列码地址加1
	MOV A, R_CNT			;把列地址放入A中
	CJNE A, #8, NEXT2		;A不等于8，转子程序NEXT2，否则往下执行
	MOV R_CNT, #00H			;就把列码置0
	MOV NUMB, R0			;行码地址送存储单元格中
NEXT2:
	INC TCOUNT				;拉幕计数序号加1
	MOV A, TCOUNT			;将幕次序号送A中
	CJNE A, #40, NEXT4		;此序号不等于40转Next4，否则往下执行
	MOV TCOUNT, #00H		;把拉幕时序归0
	INC R0					;行码起始地址加1
	CJNE R0, #88, NEXT3	;行码自加次数不满11字符×8行/字符=88行就转Next3
	MOV R0, #00H			;不然就把行码置0
NEXT3:
	MOV NUMB, R0	;送新的一幕行码起始位给R0
NEXT4:
	RETI		;中断返回
TAB:			;列码码表
	DB 0FEH, 0FDH, 0FBH, 0F7H, 0EFH, 0DFH, 0BFH, 7FH	;列扫描从右向左
NUB:			;行码码表，字符数据
		DB 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H  		;NULL
	DB 00H, 00H, 3EH, 41H, 41H, 41H, 3EH, 00H  		; 0
	DB 00H, 00H, 00H, 00H, 21H, 7FH, 01H, 00H  		; 1
	DB 00H, 00H, 27H, 45H, 45H, 45H, 39H, 00H  		; 2
	DB 00H, 00H, 22H, 49H, 49H, 49H, 36H, 00H  		; 3
	DB 00H, 00H, 0CH, 14H, 24H, 7FH, 04H, 00H  		; 4
	DB 00H, 00H, 72H, 51H, 51H, 51H, 4EH, 00H  		; 5
	DB 00H, 00H, 3EH, 49H, 49H, 49H, 26H, 00H  		; 6
	DB 00H, 00H, 40H, 40H, 40H, 4FH, 70H, 00H  		; 7
	DB 00H, 00H, 36H, 49H, 49H, 49H, 36H, 00H  		; 8
	DB 00H, 00H, 32H, 49H, 49H, 49H, 3EH, 00H  		; 9
	DB 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H  		;NULL
END		                                        	;结束汇编