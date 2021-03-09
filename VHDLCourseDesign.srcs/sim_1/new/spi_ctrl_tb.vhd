----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/08/2021 10:50:20 AM
-- Design Name: 
-- Module Name: spi_ctrl_tb - Behavioral
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

entity spi_ctrl_tb is
--  Port ( );
end spi_ctrl_tb;

architecture Behavioral of spi_ctrl_tb is
    component spi_ctrl is
        Port ( clk          : in std_logic; -- System clok (100MHz)
               rst          : in std_logic; -- Global synchronous reset
               en           : in std_logic; -- Block enable pin
               sdata        : in std_logic_vector (7 downto 0); -- Byte to be sent
               sdout        : out std_logic; -- Serial data out
               oled_sclk    : out std_logic; -- OLED serial clock
               finish       : out std_logic); -- Finish flag for block
    end component;
    
    signal clk : std_logic := '0';
    signal rst, en, sdout, oled_sclk, finish : std_logic;
    signal sdata : std_logic_vector(7 downto 0);
    
begin
    DUT : spi_ctrl
    port map(clk=>clk, rst=>rst, en=>en, sdata=>sdata,
             sdout=>sdout, oled_sclk=>oled_sclk, finish=>finish);
    
    clk <= not clk after 5 ns;
    
    process begin
        rst <= '1'; wait for 10 ns;
        rst <= '0'; wait;
    end process;
    
    process begin
        en <= '1'; wait for 2us;
        en <= '0'; wait for 1us;
    end process;
    
    sdata <= "10101110";
    
end Behavioral;
