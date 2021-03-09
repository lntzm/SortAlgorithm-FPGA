----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/07/2021 04:57:02 PM
-- Design Name: 
-- Module Name: testbench - Behavioral
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
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.conv_std_logic_vector;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity min_sec_tb is
--  Port ( );
end min_sec_tb;

architecture Behavioral of min_sec_tb is
    component min_secmin is
        Port ( data0 : in STD_LOGIC_VECTOR (7 downto 0);
               data1 : in STD_LOGIC_VECTOR (7 downto 0);
               data2 : in STD_LOGIC_VECTOR (7 downto 0);
               data3 : in STD_LOGIC_VECTOR (7 downto 0);
               data4 : in STD_LOGIC_VECTOR (7 downto 0);
               data5 : in STD_LOGIC_VECTOR (7 downto 0);
               min : out STD_LOGIC_VECTOR (7 downto 0);
               second_min : out STD_LOGIC_VECTOR (7 downto 0));
    end component;

    signal data0, data1, data2, data3, data4, data5, min, second_min : std_logic_vector(7 downto 0);
begin
    DUT : min_secmin
    port map(data0, data1, data2, data3, data4, data5, min, second_min);

    data0 <= conv_std_logic_vector(34, 8);
    data1 <= conv_std_logic_vector(15, 8);
    data2 <= conv_std_logic_vector(21, 8);
    data3 <= conv_std_logic_vector(8, 8);
    data4 <= conv_std_logic_vector(64, 8);
    data5 <= conv_std_logic_vector(36, 8);

end Behavioral;
