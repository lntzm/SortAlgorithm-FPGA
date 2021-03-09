# clk
set_property PACKAGE_PIN Y9 [get_ports {clk}];  # "GCLK"
create_clock -period 100.000 -name CLK -waveform {0.000 50.000} [get_ports clk]

# 开关作为input
set_property PACKAGE_PIN M15  [get_ports {input[7]}];
set_property PACKAGE_PIN H17  [get_ports {input[6]}];
set_property PACKAGE_PIN H18  [get_ports {input[5]}];
set_property PACKAGE_PIN H19  [get_ports {input[4]}];
set_property PACKAGE_PIN F21  [get_ports {input[3]}];
set_property PACKAGE_PIN H22  [get_ports {input[2]}];
set_property PACKAGE_PIN G22  [get_ports {input[1]}];
set_property PACKAGE_PIN F22  [get_ports {input[0]}];

# 按键
set_property PACKAGE_PIN P16 [get_ports {rst}];  # "BTNC"
set_property PACKAGE_PIN N15 [get_ports {view_min_sec}];  # "BTNL"
set_property PACKAGE_PIN R18 [get_ports {view_sort}];  # "BTNR"
set_property PACKAGE_PIN T18 [get_ports {previous_num}];  # "BTNU"
set_property PACKAGE_PIN R16 [get_ports {next_num}];  # "BTND"

# OLED显示
set_property PACKAGE_PIN U10  [get_ports {oled_dc}];  # "OLED-DC"
set_property PACKAGE_PIN U9   [get_ports {oled_res}];  # "OLED-RES"
set_property PACKAGE_PIN AB12 [get_ports {oled_sclk}];  # "OLED-SCLK"
set_property PACKAGE_PIN AA12 [get_ports {oled_sdin}];  # "OLED-SDIN"
set_property PACKAGE_PIN U11  [get_ports {oled_vbat}];  # "OLED-VBAT"
set_property PACKAGE_PIN U12  [get_ports {oled_vdd}];  # "OLED-VDD"

# led显示
set_property PACKAGE_PIN W22 [get_ports {leds[5]}];
set_property PACKAGE_PIN V22 [get_ports {leds[4]}];
set_property PACKAGE_PIN U21 [get_ports {leds[3]}];
set_property PACKAGE_PIN U22 [get_ports {leds[2]}];
set_property PACKAGE_PIN T21 [get_ports {leds[1]}];
set_property PACKAGE_PIN T22 [get_ports {leds[0]}];

# 电压设置
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 13]];
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 33]];
set_property IOSTANDARD LVCMOS18 [get_ports -of_objects [get_iobanks 34]];
set_property IOSTANDARD LVCMOS18 [get_ports -of_objects [get_iobanks 35]];
