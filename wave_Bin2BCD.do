onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group TB_SIGNALS /TB_Bin2BCD/N
add wave -noupdate -expand -group TB_SIGNALS /TB_Bin2BCD/M
add wave -noupdate -expand -group TB_SIGNALS /TB_Bin2BCD/m
add wave -noupdate -expand -group TB_SIGNALS /TB_Bin2BCD/clk
add wave -noupdate -expand -group TB_SIGNALS /TB_Bin2BCD/rst_n
add wave -noupdate -expand -group TB_SIGNALS /TB_Bin2BCD/new_data
add wave -noupdate -expand -group TB_SIGNALS -radix unsigned /TB_Bin2BCD/data_in
add wave -noupdate -expand -group TB_SIGNALS /TB_Bin2BCD/new_ack
add wave -noupdate -expand -group TB_SIGNALS /TB_Bin2BCD/done
add wave -noupdate -expand -group TB_SIGNALS -radix hexadecimal /TB_Bin2BCD/data_out
add wave -noupdate -expand -group DUT_SIGNALS /TB_Bin2BCD/iDUT/conv_state
add wave -noupdate -expand -group DUT_SIGNALS /TB_Bin2BCD/iDUT/reg_new_value
add wave -noupdate -expand -group DUT_SIGNALS /TB_Bin2BCD/iDUT/conversion_en
add wave -noupdate -expand -group DUT_SIGNALS /TB_Bin2BCD/iDUT/clr_cnt
add wave -noupdate -expand -group DUT_SIGNALS /TB_Bin2BCD/iDUT/clr_val_reg
add wave -noupdate -expand -group DUT_SIGNALS -radix unsigned /TB_Bin2BCD/iDUT/shft_cnt
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {26 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 233
configure wave -valuecolwidth 161
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {80 ps}
