.data

baseAddr:
	.word 0x3F200000

virtBaseAddr:
	.word 0

virtAddrText:
	.asciz	"Virtual baseadress is: %x\n"

GPIO_LED:
		.word 17, 18, 21, 22

GPIO_Button:
		.word 9, 10

registers:
		.skip 48
/*
** Variabler här
*/

.text
/*7
** Division

*/
idiv:
	/* r0 innehåller N */
	/* r1 innehåller D */
	mov r2, r1
	mov r1, r0
	mov r0, #0
	b .Lloop_check
	.Lloop:
		add r0, r0, #1
		sub r1, r1, r2
	.Lloop_check:
		cmp r1, r2
		bhs .Lloop
	/* r0 innehåller kvoten */
	/* r1 innehåller resten */
	bx lr


/*
		In och output för lamporna?
*/


	pin_mode:
		PUSH {r4, lr}

		MOV r0, r10
		MOV r7,r1

		NOP
		LDR r4, =registers
		LDR r4,[r4]
		MOV r5, r4		//get old value
		MOV r1,#10

		BL idiv			//r0 = PIN/10, r1 = PIN%10
		MOV r6,#4
		MUL r0,r6
		ADD r4,r0

		MOV r6,#3
		MUL r1,r6

		CMP r7,#1
		BEQ pin_out
		pin_in:
						MOV r6,#7		// 7 = 0b111
						LSL r6,r1
						MVN r6,r6
						AND r5,r6
						B pin_mode_end
		pin_out:
						MOV r6,#1
						LSL r6,r1
						ORR r5,r6
						B pin_mode_end
		pin_mode_end:
						POP {r4, pc}


		/*


		*/

	pin_high:
		PUSH {r4}
		MOV r0, r10
		MOV r7,r1


		NOP
		LDR r4, =registers
		LDR r4,[r4]
		MOV r5, r4		//get old value
		MOV r1,#32

		BL idiv			//r0 = PIN/32, r1 = PIN%32
		MOV r6,#4
		ADD r0, #7
		MUL r0,r6
		ADD r4,r0

		MOV r6,#1		// 7 = 0b111
		LSL r6,r1
		MVN r6,r6
		AND r5,r6

		POP {r4,pc}



/*
** Avbrottsrutin som kallas när ett interrupt sker. Ska räkna uppåt
*/
.GLOBAL counter_isr_up
counter_isr_up:


/*
** Avbrottsrutin som kallas när ett avbrott sker. Ska räkna neråt
*/
.GLOBAL counter_isr_down
counter_isr_down:

/*
 * Sätt upp åtkomst till GPIO-pinnarnas minne
 */
.GLOBAL setup
setup:
	PUSH {lr}
	/*calc.Virt.Addr*/

	LDR  r4, =baseAddr
	LDR  r1, [r4]
	LDR  r2, =#0x00FFFFFF
	AND  r2, r1, r2
	LSR  r3, r1, #4
	LDR  r0, =#0x0F000000
	AND  r3, r3, r0
	ADD  r2, r2, r3
	LDR  r3, =#0xF0000000
	ADD  r1, r2, r3
	LDR  r2, =virtBaseAddr
	STR  r1, [r2]
	MOV  r10, r1
	MOV  r2, #17
	MOV  r1, #1

	BL pin_mode

	LDR		r0, =virtAddrText
	BL		printk


	POP {pc}
	//BX lr
	/*

		PUSH {lr}
		LDR  r2, =GPIO_LED
		MOV  r1, #1
		BL pin_high
	//Print virtual adress
		LDR		r0, =virtAddrText
		BL		printk
	*/

/*
** Ta bort åtkomst till GPIO
*/
.GLOBAL setdown
setdown:













/*
** För att sätta en GPIO pin till input används följande formel
*/
/*.GLOBAL set_GPIO_input
set_GPIO_input:

		PUSH {lr}
		LDR r4, =virtBaseAddr
		MOV r1, #10
		B idiv
		LDR r5, r0
		MUL r5, r5, #4
		ADD r4, r4, r5

		MOD r6, r0, #10
		MUL r6, r6, #3
		LSL r6, #7

		BIC r4, r4, r6
*/



/*
** Sätter GPIO pin med nummer GPIO_NR till att vara output.
		tar r0 som parameter/pin-nummer
** gpio_addr är basaddressen. Notera att gpio_addr används som en pekare.
*/
/*
.GLOBAL set_GPIO_output
set_GPIO_output:

		PUSH {lr}
		LDR r4, =virtBaseAddr
		MOV r1, #10
		B idiv
		LDR r5, r0
		MUL r5, r5, #4
		ADD r4, r4, r5

		MOD r6, r0, #10
		MUL r6, r6, #3
		LSL r6, #1

		ORR r4, r4, r6

		POP {pc}
*/
