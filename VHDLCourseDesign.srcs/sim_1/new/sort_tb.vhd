----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/26/2021 11:24:17 AM
-- Design Name: 
-- Module Name: sort_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.conv_std_logic_vector;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sort_tb is
--  Port ( );
end sort_tb;

architecture Behavioral of sort_tb is
    component sort is
        Port ( data0    : in STD_LOGIC_VECTOR (7 downto 0);
               data1    : in STD_LOGIC_VECTOR (7 downto 0);
               data2    : in STD_LOGIC_VECTOR (7 downto 0);
               data3    : in STD_LOGIC_VECTOR (7 downto 0);
               data4    : in STD_LOGIC_VECTOR (7 downto 0);
               data5    : in STD_LOGIC_VECTOR (7 downto 0);
               output0  : out STD_LOGIC_VECTOR (7 downto 0);
               output1  : out STD_LOGIC_VECTOR (7 downto 0);
               output2  : out STD_LOGIC_VECTOR (7 downto 0);
               output3  : out STD_LOGIC_VECTOR (7 downto 0);
               output4  : out STD_LOGIC_VECTOR (7 downto 0);
               output5  : out STD_LOGIC_VECTOR (7 downto 0));
    end component;
    
    signal data0, data1, data2, data3, data4, data5 : std_logic_vector(7 downto 0);
    signal output0, output1, output2, output3, output4, output5 : std_logic_vector(7 downto 0);
    
begin
    DUT : sort port map (data0=>data0, data1=>data1, data2=>data2,
                         data3=>data3, data4=>data4, data5=>data5,
                         output0=>output0, output1=>output1, output2=>output2,
                         output3=>output3, output4=>output4, output5=>output5);
    data0 <= conv_std_logic_vector(34, 8);
    data1 <= conv_std_logic_vector(15, 8);
    data2 <= conv_std_logic_vector(21, 8);
    data3 <= conv_std_logic_vector(8, 8);
    data4 <= conv_std_logic_vector(64, 8);
    data5 <= conv_std_logic_vector(36, 8);
end Behavioral;
