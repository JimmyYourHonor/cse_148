"""
Generate 16-bit interleaving bank data from plain hex file.

Our memory controller uses the following interleaving config (verilog syntax):
16-bit word addr is 25-bit long
bank[1:0] = {addr[24], addr[10]};
row[12:0] = addr[23:11];
col[9:0] = addr[9:0];
The following code only works for up to 1 << 24 words

"""

import sys

program_list = ["coin", "esift", "esift2", "nqueens", "qsort"]


for program in program_list:
	col = 0
	row = 0
	bank = 0

	with open(program + ".hex") as fin, \
		open(program + ".16bit.bank0.hex", "w") as b0, \
		open(program + ".16bit.bank1.hex", "w") as b1:

		b = [b0, b1]
		for l in fin:
			l = l.strip()
			b[bank].write(l[4:] + "\n" + l[:4] + "\n")
			col += 2

			if col == 1 << 10:
				bank += 1
				col = 0

				if bank == 2:
					row += 1
					bank = 0

					if row == 1 << 13:
						print "hex is too large, we need 4 banks to hold them"
						sys.exit(-1)
	print program, row, bank, col
