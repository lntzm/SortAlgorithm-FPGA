----------------------------------------------------------------------------------
-- ͨ��SPIЭ�鷢�����ݣ�����OLED��ʾ
-- OLED�ͺ�ΪUG-2832HSWEG04����Сʱ������Ϊ100ns
-- ����漰��ʱ������ƣ�ȡ���ʱ������ΪZedBoard��32��
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity spi_ctrl is
    Port ( clk          : in std_logic;
           rst          : in std_logic;
           en           : in std_logic;
           sdata        : in std_logic_vector (7 downto 0); -- ������λʸ��
           sdout        : out std_logic; -- ��������
           oled_sclk    : out std_logic; -- OLEDʱ��
           finish       : out std_logic); -- ��ɱ�־
end spi_ctrl;

architecture Behavioral of spi_ctrl is
    type state is (idle, sending, done);
    signal pr_state, nx_state : state;
    signal counter : std_logic_vector(4 downto 0);
    signal shift_counter : std_logic_vector(3 downto 0);
    signal clk_dived, clk_dived_delay : std_logic;
    signal shift_reg : std_logic_vector(7 downto 0);
    
begin
    clk_dived <= counter(4);        -- clk_dived = clk / 32
    oled_sclk <= not clk_dived;     -- oled_sclk��clk_divecʵʱͬ��
    finish <= '1' when pr_state = done else '0';
    
    fsm_reg: process(rst, clk)
    begin
        if (rst='1') then
            pr_state <= idle;
        elsif (rising_edge(clk)) then
            pr_state <= nx_state;
        end if;
    end process fsm_reg;
    
    fsm_nxcom: process(pr_state, en, counter, shift_counter)
    begin
        case pr_state is
        when idle =>
            if (en='1') then
                nx_state <= sending;
            else
                nx_state <= idle;
            end if;
        when sending =>
            if (clk_dived_delay='0' and shift_counter="1000") then
--            if (counter="10000" and shift_counter="1000") then
                nx_state <= done;
            else
                nx_state <= sending;
            end if;
        when done =>
            if (en='0') then
                nx_state <= idle;
            else
                nx_state <= done;
            end if;
        end case;
    end process fsm_nxcom;

    counting: process(clk)          -- ��sending״̬���������������ڷ�Ƶ
    begin
        if (rising_edge(clk)) then
            if (pr_state=sending) then
                counter <= counter + 1;
                clk_dived_delay <= counter(4);  -- ��counter(4)�ӳ�һ��clk�����ڿ�ʱ�����ͬ�����
            else
                counter <= (others=>'0');
            end if;
            
        end if;
    end process counting;
    
    -- spi_ctrl���������ʱ������clk�����в���
    spi_out: process(clk)
    begin
        if (rising_edge(clk)) then
            case pr_state is
            when idle =>
                sdout <= '1';
                shift_reg <= sdata;
                shift_counter <= (others=>'0');
            when sending =>
                if (clk_dived='1' and clk_dived_delay='0') then
                    sdout <= shift_reg(7);
                    shift_reg <= shift_reg(6 downto 0) & '0';
                    shift_counter <= shift_counter + 1;
                end if;         -- ������
            when done =>
--                sdout <= '1';     -- sdoutҲ����������
                shift_reg <= (others=>'0');
            end case;
        end if;
    end process spi_out;

end Behavioral;