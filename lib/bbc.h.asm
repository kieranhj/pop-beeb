
\ ******************************************************************
\ *	Define OS entries (could be INCLUDE bbc_os.h)
\ ******************************************************************

osfile = &FFDD
oswrch = &FFEE
osasci = &FFE3
osbyte = &FFF4
osword = &FFF1
osfind = &FFCE
osgbpb = &FFD1
osargs = &FFDA

IRQ1V = &204
IRQ2V = &206
EVENTV = &0220

\\ Internal Key Number not INKEY!
IKN_esc = 112
IKN_up = 57
IKN_down = 41
IKN_return = 73
IKN_q = 16
IKN_a = 65
IKN_z = 97
IKN_x = 66
IKN_colon = 72
IKN_slash = 104
IKN_r = 51
IKN_k = 70
IKN_j = 69
IKN_g = 83
IKN_v = 99
IKN_m = 101
IKN_y = 68
IKN_c = 82
IKN_f = 67
IKN_b = 100
IKN_rsb = 88
IKN_lsb = 56
IKN_e = 34
IKN_s = 81
IKN_d = 50
IKN_p = 55
IKN_n = 85
IKN_ctrl = 1
IKN_shift = 0
IKN_copy = 105
IKN_del = 89
IKN_semi = 87
IKN_space = 98

\\ Opcodes
SEI_OP = $78
CLI_OP = $58
NOP_OP = $ea
OPCODE_eor_indirect_Y = &51
OPCODE_ora_indirect_Y = &11
OPCODE_INX = &E8
OPCODE_DEX = &CA
OPCODE_LDAimm = &A9
OPCODE_LDAzp = &A5
OPCODE_LDXimm = &A2
OPCODE_LDXzp = &A6
OPCODE_JMP = &4C

\\ SN Register Values
SN_REG_MASK = &70
SN_REG_TONE3_FREQ = 0
SN_REG_TONE3_VOL = 1
SN_REG_TONE2_FREQ = 2
SN_REG_TONE2_VOL = 3
SN_REG_TONE1_FREQ = 4
SN_REG_TONE1_VOL = 5
SN_REG_NOISE_CTRL = 6
SN_REG_NOISE_VOL = 7
SN_REG_MAX = 8

\\ SN Register Bit-field
SN_BIT_TONE3_FREQ = &01
SN_BIT_TONE3_VOL = &02
SN_BIT_TONE2_FREQ = &04
SN_BIT_TONE2_VOL = &08
SN_BIT_TONE1_FREQ = &10
SN_BIT_TONE1_VOL = &20
SN_BIT_NOISE_CTRL = &40
SN_BIT_NOISE_VOL = &80

\\ SN Frequency Constants
SN_FREQ_BYTE_MASK = &80
SN_FREQ_FIRST_BYTE_MASK = &0F
SN_FREQ_SECOND_BYTE_MASK = &3F

\\ SN Volume Constants
SN_VOL_MASK = &0F
SN_VOL_MAX = &0F

\\ Noise Freqency Vaues
SN_NF_MASK = &03
SN_NF_LOW = 0
SN_NF_MED = 1
SN_NF_HIGH = 2
SN_NF_TONE1 = 3

\\ Noise Frequency Type
SN_FB_MASK = &04
SN_FB_PERIODIC = 0
SN_FB_WHITENOISE = &04

\\ Palette values for ULA
PAL_black	= (0 EOR 7)
PAL_blue	= (4 EOR 7)
PAL_red		= (1 EOR 7)
PAL_magenta = (5 EOR 7)
PAL_green	= (2 EOR 7)
PAL_cyan	= (6 EOR 7)
PAL_yellow	= (3 EOR 7)
PAL_white	= (7 EOR 7)


\\ MODE 7
MODE7_base_addr = &7C00
MODE7_char_width = 40
MODE7_char_height = 25
MODE7_texel_width = (MODE7_char_width - 2) * 2
MODE7_texel_height = MODE7_char_height * 3

MODE7_alpha_black = 128
MODE7_graphic_black = 144
MODE7_contiguous = 153
MODE7_separated = 154
MODE7_black_bg = 156
MODE7_new_bg = 157

\\ MODE 2
MODE2_LEFT_MASK=&AA
MODE2_RIGHT_MASK=&55

MODE2_BLACK_PAIR=&00
MODE2_RED_PAIR=&03
MODE2_GREEN_PAIR=&0C
MODE2_YELLOW_PAIR=&0F
MODE2_BLUE_PAIR=&30
MODE2_MAGENTA_PAIR=&33
MODE2_CYAN_PAIR=&3C
MODE2_WHITE_PAIR=&3F

\\ Macro to reset any mapped characters
\\ since BeebASM doesn't have any feature for this
\\ Actually it does :)
MACRO RESET_MAPCHAR

	MAPCHAR 'A', 'Z', 'A' 
	MAPCHAR 'a', 'z', 'z'
	MAPCHAR '0', '9', '0'
	MAPCHAR '?', '?'
	MAPCHAR '!', '!'
	MAPCHAR '.', '.'
	MAPCHAR ' ', ' '

ENDMACRO