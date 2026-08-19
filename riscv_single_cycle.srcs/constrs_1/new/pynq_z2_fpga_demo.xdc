## 125 MHz clock
set_property -dict {PACKAGE_PIN H16 IOSTANDARD LVCMOS33} [get_ports sysclk]
create_clock -period 8.000 -name sysclk -waveform {0.000 4.000} [get_ports sysclk]

## reset button: BTN0
set_property -dict {PACKAGE_PIN D19 IOSTANDARD LVCMOS33} [get_ports reset_button]

## 4 leds
set_property -dict {PACKAGE_PIN R14 IOSTANDARD LVCMOS33} [get_ports {led[0]}]
set_property -dict {PACKAGE_PIN P14 IOSTANDARD LVCMOS33} [get_ports {led[1]}]
set_property -dict {PACKAGE_PIN N16 IOSTANDARD LVCMOS33} [get_ports {led[2]}]
set_property -dict {PACKAGE_PIN M14 IOSTANDARD LVCMOS33} [get_ports {led[3]}]

## setting input delay (reset) to not sync -> manually pressed async
set_false_path -from [get_ports reset_button]

## setting output delay (led) to not sync 
set_false_path -to [get_ports {led[*]}]