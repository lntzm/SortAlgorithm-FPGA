# VHDLCourseDesign
基于FPGA的最小值次小值不同算法求解、不同排序算法、使用OLED显示屏输出结果

## Usage
本项目基于Xilinx ZedBoard，使用vivado 2018.3进行开发，仅使用了ZedBoard的PL部分，即纯FPGA实现，且未对内核ip进行修改。

代码位于目录 `./VHDLCourseDesign.srcs/` 

其中`./VHDLCourseDesign.srcs/sources_1/new`为设计，`./VHDLCourseDesign.srcs/constrs_1/new`为约束，`./VHDLCourseDesign.srcs/sim_1/new`为仿真

controller.vhd为顶层文件，默认采用最小次小的方案A与排序的方案A

##

