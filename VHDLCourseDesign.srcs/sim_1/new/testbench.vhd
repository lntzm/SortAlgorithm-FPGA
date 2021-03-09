library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.conv_std_logic_vector;


entity testbench is
--  Port ( );
end testbench;

architecture Behavioral of testbench is
    component controller is
        Port ( clk, rst     : in std_logic;
               input        : in std_logic_vector(7 downto 0);  -- 数的输入
               previous_num : in std_logic;     -- 按键控制
               next_num     : in std_logic;
               view_min_sec : in std_logic;
               view_sort    : in std_logic;
               oled_sdin    : out std_logic;    -- 输出给oled
               oled_sclk    : out std_logic;
               oled_dc      : out std_logic;
               oled_res     : out std_logic;
               oled_vbat    : out std_logic;
               oled_vdd     : out std_logic;
               leds         : out std_logic_vector(5 downto 0));
    end component;
    
    signal clk : std_logic := '0';
    signal rst, previous_num, next_num, view_min_sec, view_sort : std_logic;
    signal oled_sdin, oled_sclk, oled_dc, oled_res, oled_vbat, oled_vdd : std_logic;
    signal input : std_logic_vector(7 downto 0);
    signal leds : std_logic_vector(5 downto 0);
begin
    DUT : controller
    port map ( clk=>clk, rst=>rst,
               input=>input,
               previous_num=>previous_num,
               next_num=>next_num,
               view_min_sec=>view_min_sec,
               view_sort=>view_sort,
               oled_sdin=>oled_sdin,
               oled_sclk=>oled_sclk,
               oled_dc=>oled_dc,
               oled_res=>oled_res,
               oled_vbat=>oled_vbat,
               oled_vdd=>oled_vdd,
               leds=>leds);
    
    clk <= not clk after 5 ns;
    
    process begin
        rst <= '1'; wait for 3 ns;
        rst <= '0'; wait;
    end process;
    
    process begin
        input <= "11110111"; wait for 140 ms;   -- F7
        input <= "00111110"; wait for 100 ms;   -- 3E
        input <= "10000000"; wait for 100 ms;   -- 80
        input <= "00000001"; wait for 100 ms;   -- 01
        input <= "10011110"; wait for 100 ms;   -- 9E
        input <= "00101100"; wait;              -- 2C
    end process;
    
    process begin
        next_num <= '0'; wait for 50 ms;    -- num0
        next_num <= '1'; wait for 50 ms;
        next_num <= '0'; wait for 50 ms;    -- num1
        next_num <= '1'; wait for 50 ms;
        next_num <= '0'; wait for 50 ms;    -- num2
        next_num <= '1'; wait for 50 ms;
        next_num <= '0'; wait for 50 ms;    -- num3
        next_num <= '1'; wait for 50 ms;
        next_num <= '0'; wait for 50 ms;    -- num4
        next_num <= '1'; wait for 50 ms;
        next_num <= '0'; wait;              -- num5
    end process;
    
    previous_num <= '0';
    
    process begin
        view_min_sec <= '0'; wait for 600 ms;
        view_min_sec <= '1'; wait for 50 ms;
        view_min_sec <= '0'; wait;
    end process;
    
    process begin
        view_sort <= '0'; wait for 700ms;
        view_sort <= '1'; wait for 50 ms;
        view_sort <= '0'; wait;
    end process;

end Behavioral;
