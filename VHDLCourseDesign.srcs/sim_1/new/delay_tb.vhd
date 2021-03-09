----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/16/2021 02:45:34 PM
-- Design Name: 
-- Module Name: delay_comp_tb - Behavioral
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

entity delay_tb is
--  Port ( );
end delay_tb;

architecture Behavioral of delay_tb is
    component delay is
        port (  clk         : in std_logic; -- System clock
                rst         : in std_logic;  -- Global synchronous reset
                delay_ms    : in std_logic_vector (11 downto 0); -- Amount of ms to delay
                en          : in std_logic; -- Delay enable
                finish      : out std_logic); -- Delay finish flag
    end component;
    signal clk : std_logic := '0';
    signal rst, en, finish : std_logic;
    signal delay_ms : std_logic_vector(11 downto 0);
begin
    DUT : delay
    port map(clk=>clk, rst=>rst, delay_ms=>delay_ms, en=>en, finish=>finish);
    
    clk <= not clk after 5 ns;
    
    process begin
        rst <= '1';
        wait for 10 ns;
        rst <= '0';
        wait;
    end process;
    
    process begin
        en <= '1';
        wait for 4 ms;
        en <= '0';
        wait for 1 ms;
    end process;
    
   delay_ms <= "000000000011";
    
end Behavioral;
