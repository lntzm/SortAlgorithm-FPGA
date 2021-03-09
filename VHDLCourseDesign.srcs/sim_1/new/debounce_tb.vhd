----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/24/2020 06:49:36 PM
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity debounce_tb is
--  Port ( );
end debounce_tb;

architecture Behavioral of debounce_tb is
    component debounce is
        Port ( in_key : in STD_LOGIC;
               clk : in STD_LOGIC;
               out_key : out STD_LOGIC);
    end component;
    
    signal in_key, clk, pressed: std_logic;
    
begin
    DUT1: debounce
    port map(in_key=>in_key, clk=>clk, out_key=>pressed);
    
    clk <= '1' after 5 ns when clk='0' else
           '0' after 5 ns when clk='1' else
           '0';
    
    process begin
        in_key <= '1';
        wait for 100 ms;
        in_key <= '0';
        wait for 100 ms;
        
        in_key <= '1';
        wait for 4 ms;
        in_key <= '0';
        wait for 4 ms;
        
        in_key <= '1';
        wait for 8 ms;
        in_key <= '0';
        wait for 8 ms;
        
        in_key <= '1';
        wait for 18 ms;
        in_key <= '0';
        wait for 18 ms;
    end process;

end Behavioral;
