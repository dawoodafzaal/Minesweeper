
.data

/* All the strings needed throughout the code, used for error messages, 
   notifying the player about input options, treasures and bombs, etc */

printrandom: .string "%d "
newline: .string "\n"
invalid_argnum: .string "Invalid number of arguments! \n"
invalid_input: .string "Input must be between 5-20 \n"
invalid_move: .string "Invalid move! Try again. \n"
invalid_entry: .string "Invalid entry. \n"
print_x: .string "X"
prompt: .string "Enter your move (x, y): \n"
move: .asciz "%d"
nice_surprise: .string "You got a nice surprise! (Score is doubled) \n"
bad_surprise: .string "You got a bad surprise! (Score is halved) \n"
time_surprise: .string "You got a time bonus! (Additional time is granted) \n"
exit_prompt: .string "Enter (21, 21) to exit! \n"
money: .string "$"
pos: .string "+"
neg: .string "-"
exclamation: .string "!"
atsign: .string "@"
print_score: .string "Score: %.2f \n"
print_timer: .string "Timer: %d \n"
top_scores_info: .string "Enter 0 for NO and 1 for YES \n"
top_scores: .string "Would you like to see the top scores? \n"
score_count: .string "Enter how many you'd like to see. \n"
treasure: .string "Uncovered a reward of %.2f \n"
bomb: .string "Bang!! You lost %.2f \n"
spot: .string "Spot has been picked, try again. \n"
exiting: .string "Now exiting game. \n"
time_finished: .string "The timer has run out, you lose! \n"
lost: .string "Sorry! You lose \n"
won: .string "Congratulations! You've won. \n"
formatIn: .string "%d"
f1:	.double 0r100.0 //setting up for floats
f2:	.double 0r0.0 //setting 0
f3:	.double 0r20.0 //setting for pos value
f4:	.double -20.0 //setting value for neg num
f5:	.double 0r23.0 //setting value for good pack
f6:	.double 0r24.0 //setting value for back pack
f7:	.double 0r25.0 //setting value for time pack

n:	.word 0

m:	.word 0
	.text

array_size = 20*20*8

i_size = 4
j_size = 4
s_size = 8 //score should be a float
t_size = 4
c_size = 4
u_size = 4
is_size = 4
bt_size = 8
negc_size = 4
//m_size = 4
//n_size = 4
gp_size = 4
bp_size = 4
tp_size = 4
pn_size = 4
nn_size = 4
fn_size = 8

/* Allocating memory */

i_s = 16
j_s = 16 + i_size
s_s = 16 + j_s
t_s = 16 + s_s
c_s = 16 + t_s
u_s = 16 + c_s
is_s = 16 + u_s
bt_s = 16 + is_s
negc_s = 16 + bt_s
//m_s = 16 + negc_s
//n_s = 16 + m_s
gp_s = 16 + negc_s
bp_s = 16 + gp_s
tp_s = 16 + bp_s
pn_s = 16 + tp_s
nn_s = 16 + pn_s
fn_s = 16 + nn_s

array_s = i_s + i_size + j_size + array_size //allocating memory for array

var_size = array_size + i_size + j_size + s_size + t_size + c_size + u_size + is_size + bt_size + negc_size + gp_size + bp_size + tp_size + pn_size + nn_size + fn_size //calculating memory
alloc = -(16 + var_size) & 16 //allocating memory
dealloc = -alloc //calculating dealloc

fp	.req x29
lr	.req x30
	.balign 4
	.global main

/* The main function is the core of the program which initializes, displays and allows
   a player to play the game */

main:	stp fp, lr, [sp, alloc]!
	mov fp, sp 

	mov w20, w0 //w0 (# of args) --> w20
	cmp w20, 3 //check the number of args
	b.ne invalidargs //invalid number of args

	mov w19, 2 //get 2nd arg (<program>, <user name>, <input>)
	ldr x0, [x1, w19, SXTW 3] //load 2nd arg (input)
	bl atoi //convert to integer

	mov x19, x0 //w0 (has integer input) --> w19

	cmp x19, 5 //compare input with 5
	b.lt error //if input < 5, invalid

	cmp x19, 20 //compare with 20
	b.gt error //if input > 20, invalid

	str x19, [fp, u_s] //storing the user input

	bl displayTopScores //branch to top scores
	
	mov w23, 0 //setting up i
	str w23, [fp, i_s] //storing i

	mov w24, 0 //setting up j
	str w24, [fp, j_s] //store j

	add x0, fp, array_s //pass the base
	mov w1, w19 //pass the input
	add x2, fp, i_s //pass i
	add x3, fp, j_s //pass j

	bl initializeGame //initialize the game board

	adr x0, f2 //change address to 0
	ldr d20, [x0] //load value into score
	str d20, [fp, s_s] //store score

	mov x22, 60 //set timer
	str x22, [fp, t_s] //store score

	cmp x19, 5 //compare user input with size of board
	b.gt calctime //if input > 5, calculate the time

continue1:
	
	mov w16, 0 //set counter for WIN-CONDITION
	str w16, [fp, c_s] //store counter

	adr x0, f2 //load 0 into reg
	ldr d20, [x0] //load zero into score
	str d20, [fp, s_s] //store score

	mov w14, 0 //set counter
	str w14, [fp, negc_s] //store in counter  

	adr x0, f3 //address for '+'
	ldr d1, [x0] //load into d-reg
	str d1, [fp, pn_s] //store value for pos num

	adr x0, f4 //address for '-'
	ldr d1, [x0] //load into d-reg
	str d1, [fp, nn_s] //store value for neg num

	adr x0, f5 //address for '$'
	ldr d1, [x0] //load into d-reg
	str d1, [fp, gp_s] //store value for surprise pack (good)	

	adr x0, f6 //address for '!'
	ldr d1, [x0] //load into d-reg
	str d1, [fp, bp_s] //store value for bad pack

	adr x0, f7 //address for '@'
	ldr d1, [x0] //load into d-reg
	str d1, [fp, tp_s] //store value for time pack

	b loop //jump into the loop 

loop:

	cmp x22, 0 //comparing timer w/ 0
	b.lt resettimer //if timer < 0, reset it back to 0

	ldr w14, [fp, negc_s] //load counter
	cmp w14, 2 
	b.eq checkscore //if counter = 1, check the scores value
	add w14, w14, 1 //increment counter
	str w14, [fp, negc_s] //store counter

continue6:

	mov x0, 0
	bl time //branch to time
	mov x5, x0 //move into new x-reg
	str x5, [fp, bt_s] //store time

	mov w23, 0 //reset i
	str w23, [fp, i_s] //store i
	mov w24, 0 //reset j
	str w24, [fp, j_s] //store j

	add x0, fp, array_s //pass the base
	mov w1, w19 //pass the input
	add x2, fp, i_s //pass i
	add x3, fp, j_s //pass j

	bl displayGame //display the game

	ldr w0, [fp, s_s] //load score	
	mov w1, w0 //set up for args
	adrp x0, print_score //change address
	add x0, x0, :lo12:print_score //add bits

	bl printf //print score

	ldr x1, [fp, t_s] //load timer
	adrp x0, print_timer //change address of timer
	add x0, x0, :lo12:print_timer //add bits

	bl printf //printing

	ldr x0, =exit_prompt
	bl printf //load exiting msg and print

	adrp x0, prompt //changing address to prompt
	add x0, x0, :lo12:prompt //adding bits
	bl printf //printing
	adrp x0, move //move is %d
	add x0, x0, :lo12:move //adding bits
	adr x1, n //address of x1 --> n
	bl scanf //scan first num
	adr x1, n //change address to n
	ldr w27, [x1] //load n --> w27
	adrp x0, move //move is %d
	add x0, x0, :lo12:move	
	adr x1, m //address of x2 --> m 
	bl scanf //scan second num
	adr x1, m //change address
	ldr w28, [x1] //load m --> w28

	sub w18, w19, 1 //w18 = input - 1 (going to be used to check if move is out of bounds)

	cmp w27, w18 //compare n w/ w18 
	b.gt invalid1 //if n > (input - 1), its an invalid move

	cmp w28, w18 //compare m w/ w18
	b.gt invalid1 //if m > (input -1), invalid move

	cmp w27, 0 //compare n w/ 0
	b.lt invalid //if n < 0, invalid input
	
	cmp w28, 0 //compare m w/ 0
	b.lt invalid //if m < 0, invalid input

	mul w25, w19, w27 //offset = input * n
	add w25, w25, w28 //offset = offset + m
	lsl w25, w25, 3 //left shift by 3

	ldr d26, [x21, w25, SXTW] //reg = board[x][y] 

	ldr d1, [fp, pn_s] //load value for cmp for pos num
	fcmp d26, d1 //check if its already been picked
	b.eq picked //if w26 == 20, its already been picked
	
	ldr d1, [fp, nn_s] //load value for cmp for neg num
	fcmp d26, d1 //check with -20
	b.eq picked //if w26 == -20, its been picked

	ldr d1, [fp, gp_s] //load value for good pack
	fcmp d26, d1 //check with 23 
	b.eq picked //if equal to, its been picked

	ldr d1, [fp, bp_s] //load value for bad pack
	fcmp d26, d1 //check w/ 24
	b.eq picked //if equal to, its been picked

	ldr d1, [fp, tp_s] //load value for time pack
	fcmp d26, d1 //check w/ 25
	b.eq picked //if equal to, its been picked

	cmp w27, 21 
	b.eq check_m3 //if n == 21, check the value of m

	cmp w27, 1 //compare n w/ 1
	b.eq check_m //if w27 == 1, check m

	cmp w27, 2
	b.eq check_m2 //if w27 == 2, check m2

continue4:

	adr x0, f2
	ldr d1, [x0]
	fcmp d26, d1 //compare w/ 0
	b.lt decreasescore //if board[x][y] < 0, decrease score

	adr x0, f2
	ldr d1, [x0]
	fcmp d26, d1 //compare again with 0
	b.ge addscore //if board[x][y] > 0, add to score
	
continue2:
	
	ldr w16, [fp, c_s] //load the counter
	
	ldr x19, [fp, u_s] //loads input	
	mul x3, x19, x19 //w3 = input * input

	add w16, w16, 1 //increment counter
	str w16, [fp, c_s] //store counter

	cmp w16, w3 //compare counter w/ input * input
	b.eq win //if counter = (input * input), they've won

continue3:

	mov x0, 0
	bl time //branch to time (stores the value in x0)

	ldr x5, [fp, bt_s] //loads start time	
	sub x9, x0, x5 //time used = start time - current time
	ldr x22, [fp, t_s] //load time

	sub x1, x22, x9 //time = original timer - time elapsed
	str x1, [fp, t_s] //load time

	b loop //this continuously loops until they back out themselves

checkscore:

	ldr d20, [fp, s_s] //load score
	adr x0, f2
	ldr d1, [x0]
	fcmp d20, d1 //compare score w/ 0
	b.lt lose //if score < 0 after the first turn, they've lost

	b continue6 //otherwise go back

win:
	mov w23, 0 //reset i
	str w23, [fp, i_s] //store i
	mov w24, 0 //reset j
	str w24, [fp, j_s] //store j

	add x0, fp, array_s //pass the base
	mov w1, w19 //pass the input
	add x2, fp, i_s //pass i
	add x3, fp, j_s //pass j

	bl displayGame //display the game

	ldr x0, =won //loading msg
	bl printf //print

	bl displayTopScores //asks if they want to see the top scores

	b done //finish
	
lose:
	mov w23, 0 //reset i
	str w23, [fp, i_s] //store i
	mov w24, 0 //reset j
	str w24, [fp, j_s] //store j
	
	add x0, fp, array_s //pass the base
	mov w1, w19 //pass the input
	add x2, fp, i_s //pass i
	add x3, fp, j_s //pass j

	bl displayGame //display the game

	ldr x0, =lost //loading message
	bl printf //print msg

	bl displayTopScores //asks if they want to see the top scores

	b done //exit program


picked: //prints message if spot has been taken

	ldr x0, =spot //load message
	bl printf //prints
	b continue3 //goes back, updates the timer and asks again

decreasescore: //branch to calculate score method

	fmov d0, d26 //pass as parameter
	adrp x0, bomb //address change 
	add x0, x0, :lo12:bomb //prints bomb with amount lost
	bl printf //print

	ldr d20, [fp, s_s] //loading score
	
	fmov d0, d20 //pass arg #1 (Score)
	fmov d1, d26 //pass value at board[x][y]

	bl calculateScore //branch to subroutine which calculates the score

	fmov d20, d0 //move score from sub-routine --> w20
	str d20, [fp, s_s] //store new score

	ldr d2, [fp, nn_s] //load value for neg num
	fmov d26, d2 //set used value to -20
	str d26, [x21, w25, SXTW] //store that value
	b continue2

addscore:

	fmov d0, d26 //pass chosen value as parameter
	adrp x0, treasure //address change
	add x0, x0, :lo12:treasure //prints rewards w/ amount
	bl printf //print

	ldr d20, [fp, s_s] //load score

	fmov d0, d20 //pass the score
	fmov d1, d26 //pass the value at board[x][y]

	bl calculateScore //branch to sub-routine which calculates score

	fmov d20, d0 //passes (score = score + board[x][y])
	str d20, [fp, s_s] //store score

	ldr d2, [fp, pn_s] //load value for pos num
	fmov d26, d2 //set score to 20
	str d26, [x21, w25, SXTW] //store it as 20
	b continue2

resettimer:

	ldr x0, =time_finished //loading msg
	bl printf //printing

	mov x22, 0 //change timer to 0, the go back
	mov x1, x22 //pass the timer for argument printing
	adrp x0, print_timer //change address of timer
	add x0, x0, :lo12:print_timer //add bits
	bl printf //prints the timer at 0

	bl displayTopScores //asks them if they'd like to see the top scores

	b done //if timer < 0, they're done the game

check_m:

	cmp w28, 3 //compare w/ 3
	b.eq nicesurprise //they got a nice surprise at board[1][3]
	b continue4 //otherwise go back to main

nicesurprise:

	ldr x0, =nice_surprise //load message
	bl printf //print

	ldr d20, [fp, s_s] //load score
	fcvtns x3, d20 //pass into an x-reg
	lsl x3, x3, 1 //logical shift left to double score
	scvtf d20, x3 //pass back into d-reg
	str d20, [fp, s_s] //store score

	mov w1, 1 //store 1 for math purposes

	mul w25, w19, w1 //offset = input * (n = 1)
	add w25, w25, 3 //offset = offset + (m = 3)
	lsl w25, w25, 3 //logical shift left
	
	ldr d26, [x21, w25, SXTW] //load value
	
	adr x0, f5 //loading value for '$'
	ldr d2, [x0] //load into d-reg
	fmov d26, d2 //swap to make it 23
	str d26, [x21, w25, SXTW] //store that value at [1][3]

	b continue2

check_m2:

	cmp w28, 4
	b.eq badsurprise //if w28 == 4, they got the bad surprise at [2][4]

	cmp w28, 2
	b.eq timepack //if w28 == 2, they got the time pack at [2][2]

	b continue4 //other wise go back

badsurprise:
	
	ldr x0, =bad_surprise //load message
	bl printf

	ldr d20, [fp, s_s] //load score
	fcvtns x3, d20 //move into x-reg
	lsr x3, x3, 1 //score = score / 2
	scvtf d20, x3 //pass back into d-reg
	str d20, [fp, s_s] //store score

	mov w1, 2 //store 1 for math purposes

	mul w25, w19, w1 //offset = input * (n = 2)
	add w25, w25, 4 //offset = offset + (m = 4)
	lsl w25, w25, 3 //logical shift left
	
	ldr d26, [x21, w25, SXTW] //load value
	
	adr x0, f6 //change address for '!'
	ldr d2, [x0] //load into d-reg
	fmov d26, d2 //swap to make it 24
	str d26, [x21, w25, SXTW] //store that value at [2][4]

	b continue2

timepack:

	ldr x0, =time_surprise //load message
	bl printf //print

	ldr x22, [fp, t_s] //loading timer
	add x22, x22, 30 //add 30s to timer
	str x22, [fp, t_s] //stores the timer

	mov w1, 2 //store 1 for math purposes

	mul w25, w19, w1 //offset = input * (n = 2)
	add w25, w25, 2 //offset = offset + (m = 2)
	lsl w25, w25, 3 //logical shift left

	adr x0, f7 //address for '@'
	ldr d2, [x0] //load into d-reg
	fmov d26, d2 //set w26 to 25	
	str d26, [x21, w25, SXTW] //load value at [2][2]

	b continue2


check_m3:

	cmp w28, 21 //checking if m == 21
	b.eq exit //branches to exit
	b continue4 //otherwise it goes back

calctime:

	ldr x19, [fp, u_s] //load the user input into an x-reg

	mov x8, 3 //store 3 for math pruposes
	mul x15, x19, x8 //w15 = input * 3
	add x22, x22, x15 //new time = time * w3 (input * 3)

	str x22, [fp, t_s] //stores timer	

	b continue1

invalid:
	ldr x0, =invalid_move //setting up string
	bl printf //print
	b continue3 //loop back

invalid1:
	
	cmp w27, 21 //compare w27 w/ 21
	b.eq check_m3 //if w27 == 21, check m

	b invalid //if n != 21, then go to invalid
	
error:
	adrp x0, invalid_input //address for input
	add x0, x0, :lo12:invalid_input //adding bits
	bl printf //printing
	
	b done

invalidargs:

	adrp x0, invalid_argnum //address for input
	add x0, x0, :lo12:invalid_argnum //adding bits
	bl printf //printing

	b done //branch to done

exit:
	bl displayTopScores //asks if they want to see top scores before exiting
	bl exitGame //branches to exit game sub routine
	b done //ends program

done:	//done function is for exiting program
	mov w0, 0
	ldp fp, lr, [sp], dealloc
	ret

/* This function takes a counter, i and j for arguments, we initialze the table
   by filling it with 20% random numbers and the remianing with positives */

initializeGame:	stp x29, x30, [sp, -16]!
		mov x29, sp

	//macro definitions
	define(base_init, x21)
	define(input_init, x26)
	define(i_init, x23)
	define(j_init, x24)
	define(offset_init, x25)
	define(randnum_init, d20)

	mov base_init, x0 //pass the base
	mov input_init, x1 //pass the user input
	mov x27, x2 //pass i
	mov x28, x3 //pass j

	ldr i_init, [x27] //loading i
	ldr j_init, [x28] //loading j

test3_initialize:

	cmp i_init, input_init //compare i w/ input
	b.lt test4_initialize //if i < input, check j
	b done_initialize //once i = input, exit

test4_initialize:

	cmp j_init, input_init //compare j w/ input
	b.lt loop_initialize //if j < input, loop to generate numbers

	add i_init, i_init, 1 //increment i
	str i_init, [x27] //store i

	mov j_init, 0 //reset j
	str j_init, [x28] //store j

	b test3_initialize //loop back

loop_initialize:
	
	ldr i_init, [x27] //loading i
	ldr j_init, [x28] //loading j
	
	mul offset_init, i_init, input_init //offset = i * input
	add offset_init, offset_init, j_init //offset = offset + j
	lsl offset_init, offset_init, 3 //left shift

	bl randomNum //branch to generate num
	str s0, [base_init, offset_init] //store the number into array[i][j]

	add j_init, j_init, 1 //add to j
	str j_init, [x28] //store j

	b test3_initialize //check j's value

done_initialize:
	
	ldp x29, x30, [sp], 16
	ret

/* The randomNum generator takes the counter and the input as a parameter, we calulate twenty percent
   of the board using the input and increment the counter until it exceeds 20% of the board to which it
   only generates positive numbers afterwards */


		.text
		.balign 4
		.global randomNum
hundred:	.double 0r100.0
m_s = 28
n_s = 24
nm_s = 23
rand_num = 44

randomNum:
	stp x29, x30, [sp, -48]!
	mov x29, sp

	str w0, [x29, m_s] //store upper bounds
	str w1, [x29, n_s] //store the lower bounds

	strb w2, [x29, nm_s] //store the 'neg' boolean
	bl rand //branch to random
	add w1, w0, 1 //add one to avoid generating a zero
	ldr w2, [x29, m_s] //loading m's value
	ldr w0, [x29, n_s] //loading n's value

	sub w0, w2, w0  //w0 = n - m
	and w0, w1, w0 //and w/ rand to generate num within boundaries
	str w0, [x29, 40] //store that random value in memory
	bl rand //branch to rand again
	negs w1, w0 //negate flag
	and w0, w0, 3 //and random num w/ 3
	and w1, w1, 3 //and the neg value w/ 3
	csneg w0, w0, w1, mi //conditional selection
	str w0, [x29, 36] //store result
	ldr w0, [x29, 40] //load value
	str w0, [x29, 32] //store flag 
	ldr w0, [x29, 32] //load flag
	scvtf d1, w0 //create the float number
	adrp x0, hundred //change address of x0
	add x0, x0, :lo12:hundred //adding bits
	ldr d0, [x0] //load the first value
	fdiv d0, d1, d0 //divide by 100
	fcvt s0, d0 //get the float value
	str s0, [x29, rand_num] //store float
	ldrb w0, [x29, 36] //not equal to the negation
	cmp w0, 0 //comparing w/ 0
	b.eq done_randomNum //if equal to, exit
	ldr w0, [x29, 36] //if its not equal then load the negation
	cmp w0, 1 //compare value w/ one
	b.ne done_randomNum //if w0 != 1, we're done
	ldr s0, [x29, rand_num] //load the float
	fmov s1, -1.0 //s1 = -1.0
	fmul s0, s0, s1 //turn it into a neg value
	str s0, [x29, rand_num] //store the new value

done_randomNum:

	ldp x29, x30, [sp], 48
	ret

/* The displayGame method quite literally displays the game, we it takes the base of the array, input, 
   and two counter variables i and j, it loops through the stored values from initialize and assigns a
   symbol to the corresponding value, it displays the board with all X's and changes the values under-
   neath to match the value of the chosen slot (so a bomb will be replaced with a negative and a treasure
   will be replaces with a positive sign, etc */

displayGame:

	stp x29, x30, [sp, -16]!
	mov x29, sp	

	//macro definitions
	define(base_dis, x21)
	define(input_dis, x19)
	define(i_dis, x20)
	define(j_dis, x23)
	define(offset_dis, x26)
	define(randnum_dis, d25)

	mov base_dis, x0 //pass base
	mov input_dis, x1 //pass input
	mov x27, x2 //pass i offset
	mov x28, x3 //pass j offset

	ldr i_dis, [x27] //loading i
	ldr j_dis, [x28] //loading j

test2_display:

	cmp i_dis, input_dis //compare i w/ input
	b.lt test1_display //if i < input, check j
	b done_display //we're done

test1_display:

	cmp j_dis, input_dis //compare j w/ input
	b.lt loop_display //if j < input, loop
	
	ldr x0, =newline //print newline
	bl printf

	add i_dis, i_dis, 1 //increment i
	str i_dis, [x27] //store i

	mov j_dis, 0 //reset j
	str j_dis, [x28] //store j

	b test2_display //loop back

loop_display:

	mul offset_dis, i_dis, input_dis //offset = i * input
	add offset_dis, offset_dis, j_dis //offset = offset + j
	lsl offset_dis, offset_dis, 3 //left shift by 3

	ldr randnum_dis, [base_dis, offset_dis] //load the random number

	adr x0, f5 //change address to 23
	ldr d1, [x0] //load value into d-reg
	fcmp randnum_dis, d1 //'$' = 23, if it is 23, it prints one
	b.eq print_money 

	adr x0, f6 //load value for '!'
	ldr d1, [x0] //load into d-reg
	fcmp randnum_dis, d1 //'!' = 24, if it is 24, it prints one
	b.eq print_exclamation

	adr x0, f7 //address for '@'
	ldr d1, [x0] //load into d-reg
	fcmp randnum_dis, d1 //'@' = 25, if it is 25, it prints one
	b.eq print_at

	adr x0, f3 //address for '+'
	ldr d1, [x0] //load into d-reg
	fcmp randnum_dis, d1 //'+' = 20, if it is 20, it prints one
	b.eq print_pos

	adr x0, f4 //load value for '-'
	ldr d1, [x0] //load into d-reg
	fcmp randnum_dis, d1 //'-' = -20, if it is -20, we print it
	b.eq print_neg

	adrp x0, print_x //otherwise, we simply print an 'X'
	add x0, x0, :lo12:print_x
	bl printf	

continue1_display:

	add j_dis, j_dis, 1 //add one to j
	str j_dis, [x28] //store j
	b test2_display //check i's value	

print_money:

	//prints '$' sign and returns to loop
	adrp x0, money
	add x0, x0, :lo12:money
	bl printf
	b continue1_display

print_exclamation:

	//prints '!' sign and returns
	adrp x0, exclamation
	add x0, x0, :lo12:exclamation
	bl printf
	b continue1_display

print_at:
	
	//prints '@' sign
	adrp x0, atsign
	add x0, x0, :lo12:atsign
	bl printf
	b continue1_display

print_pos:
	
	//prints '+' sign
	adrp x0, pos
	add x0, x0, :lo12:pos
	bl printf
	b continue1_display

print_neg:

	//prints '-' sign
	adrp x0, neg
	add x0, x0, :lo12:neg
	bl printf
	b continue1_display

done_display: //branches here when its done
	
	mov w0, 0
	ldp x29, x30, [sp], 16
	ret

/* This sub-routine uses two parameters, the score and the value at board[x][y]
   it takes the current score and add/subtracts from the value the user got at 
   board[x][y] and returns the updated score */

calculateScore:	
	stp x29, x30, [sp, -16]!
	mov x29, sp

	//macro definitions
	define(cal_score, d27)
	define(boardval, d28)

	fmov cal_score, d0 //pass the score
	fmov boardval, d1 //pass the value at board[i][j]

	fadd cal_score, cal_score, boardval //score = score + board[x][y]
	fmov d0, cal_score //w0 --> score (returning new score)

done_calculateScore:

	ldp x29, x30, [sp], 16
	ret


/* We branch to this method when the user inputs n = 21 AND m = 21, meaning
   they'd like to quit, we simply print an exiting message and return to the 
   main function to which we branch to done to terminate */

exitGame:
	stp x29, x30, [sp, -16]!
	mov x29, sp

	ldr x0, =exiting //loading string message
	bl printf //printing

done_exitGame:

	ldp x29, x30, [sp], 16
	ret

/* The display top scores method should take an input 'n' which refers to the 
   number of top scores the player would like to view, they're given the option
   to not see any and if they do, they're prompted enter how many */

displayTopScores:
	stp x29, x30, [sp, -16]!
	mov x29, sp

	//macro definitions
	define(choice_scores, w27)
	define(number_chosen, w28)

	ldr x0, =top_scores_info //prints info information regarding input for top scores
	bl printf //prints info

	adrp x0, top_scores //changing address to prompt
	add x0, x0, :lo12:top_scores //adding bits
	bl printf //printing
	adrp x0, formatIn //move is %d
	add x0, x0, :lo12:formatIn //adding bits
	adr x1, n //address of x1 --> n
	bl scanf //scan first num
	adr x1, n //change address to n
	ldr choice_scores, [x1] //load n --> w27 (choice)

	cmp choice_scores, 0 //if they picked 0, then they DO NOT want to see the scores
	b.eq done_displayTopScores //we're done

	cmp choice_scores, 1 //if the DO WANT to see the scores
	b.eq howmany //then we're done

	bl invalid_num //other wise the input was invalid so we exit

howmany:

	adrp x0, score_count //changing address to prompt
	add x0, x0, :lo12:score_count //adding bits
	bl printf //printing
	adrp x0, formatIn //move is %d
	add x0, x0, :lo12:formatIn //adding bits
	adr x1, m //address of x1 --> n
	bl scanf //scan first num
	adr x1, m //change address to n
	ldr number_chosen, [x1] //load n --> w27

	cmp number_chosen, 0 //error handling
	b.lt invalid_num //if number_chosen < 0, invalid

	/* I understand that if the input is > 0, then thats how many scores they'd like
           to display but I'm not sure how to so this is the best I can, sorry */

	b done_displayTopScores

invalid_num:

	ldr x0, =invalid_entry //loading
	bl printf //prints error message
	b done_displayTopScores //then exit the sub routine

done_displayTopScores:

	ldp x29, x30, [sp], 16
	ret

	




