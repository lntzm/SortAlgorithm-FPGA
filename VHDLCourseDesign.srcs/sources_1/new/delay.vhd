----------------------------------------------------------------------------------
-- ���뼶��ʱ����������ʱ�ĺ���������ʱ�����finish�ߵ�ƽ
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity delay is
    Port (  clk         : in std_logic;
            rst         : in std_logic;
            delay_ms    : in std_logic_vector (7 downto 0); -- ��ʱ�ĺ�����
            en          : in std_logic;
            finish      : out std_logic); -- ������־
end delay;

architecture Behavioral of delay is
    type state is (idle, delaying, done);
    signal pr_state, nx_state : state;
    signal clk_counter : std_logic_vector(16 downto 0);
    signal ms_counter : std_logic_vector(11 downto 0);
    
    
begin
    fsm_reg: process(rst, clk)
    begin
        if (rst='1') then
            pr_state <= idle;
        elsif (rising_edge(clk)) then
            pr_state <= nx_state;
        end if;
    end process fsm_reg;
    
    fsm_com: process(pr_state, en, ms_counter, delay_ms)
    begin
        case pr_state is
        when idle =>
            finish <= '0';
            if (en='1') then
                nx_state <= delaying;
            else
                nx_state <= idle;
            end if;
        when delaying =>
            finish <= '0';
            if (ms_counter=delay_ms) then
                nx_state <= done;
            else
                nx_state <= delaying;
            end if;
        when done =>
            finish <= '1';
            if (en='0') then
                nx_state <= idle;
            else
                nx_state <= done;
            end if;
        end case;
    end process fsm_com;
    
    clk_count: process(clk)
    begin
        if rising_edge(clk) then
            if (pr_state=delaying) then
                if clk_counter = "11000011010011111" then   -- 99,999
--                if clk_counter = "11000011010100000" then   -- 100,000
                    clk_counter <= (others => '0');
                    ms_counter <= ms_counter + 1;   -- 1MHz��Ϊ1ms
                else
                    clk_counter <= clk_counter + 1;
                end if;
            else
                clk_counter <= (others => '0');
                ms_counter <= (others => '0');
            end if;
        end if;
    end process clk_count;

end Behavioral;
