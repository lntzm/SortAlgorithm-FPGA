----------------------------------------------------------------------------------
-- ��������
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity debounce is
    Port ( in_key   : in STD_LOGIC;
           clk      : in STD_LOGIC;
           out_key  : out STD_LOGIC);
end debounce;

architecture Behavioral of debounce is
    signal key_rst: std_logic;
    signal key_rst_an: std_logic;
    signal key_rst_r: std_logic;
    signal low_sw: std_logic;
    signal low_sw_r: std_logic;
    signal low_sw_an: std_logic;
    signal cnt: std_logic_vector(20 downto 0);
    signal delay: std_logic_vector(17 downto 0);
    
begin
    process(clk) begin
        if (rising_edge(clk)) then
            key_rst <= in_key;
            key_rst_r <= key_rst;
        end if;
    end process;
    
    -- �õ�ÿ�ΰ����¼��ĳ弤��Ӧ
    key_rst_an <= key_rst_r and not key_rst;
    
    -- ÿ�εõ��弤��Ӧ�������¼���
    process(clk) begin
        if (rising_edge(clk)) then
            if (key_rst_an='0') then
                cnt <= cnt + 1;
            else
                cnt <= (others=>'0');
            end if;
        end if;
    end process;
    
    -- ���20ms��û���ٴεĳ弤��Ӧ�����������ȶ�����
    -- �˳�����20ms�ĳ弤
    process(clk) begin
        if (rising_edge(clk)) then
            if (cnt = "111111111111111111111") then
                low_sw <= in_key;
            else
                null;
            end if;
            low_sw_r <= low_sw;
        end if;
    end process;
    
    -- �õ��˲�����ͷ��¼��ĳ弤��Ӧ
    out_key <= low_sw_r and not low_sw;
    
end Behavioral;
