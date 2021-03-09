--���ü������ķ����������
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity min_secmin_D is
Port (data0, data1, data2, data3, data4, data5 : in std_logic_vector(7 downto 0);
      clk                                      : in std_logic;           
      min, sec_min                             : out std_logic_vector(7 downto 0));
end min_secmin_D;

architecture Behavioral of min_secmin_D is
    component min_chose_4_2_C is
        Port (data0, data1, data2, data3    :in std_logic_vector(7 downto 0);
              min, sec_min                  :out std_logic_vector(7 downto 0));
    end component;
    signal tim                        :std_logic_vector(1 downto 0);--�����������
    signal temp0, temp1, temp2, temp3   :std_logic_vector(7 downto 0);
    signal tem_min, tem_sec_min         :std_logic_vector(7 downto 0);
begin
    dut:min_chose_4_2_C port map(data0 => temp0, data1 => temp1, data2 => temp2, data3 => temp3,min => tem_min, sec_min => tem_sec_min);
    
    --����ʱ�Ӹı����ֵ
    process(clk)
    begin
        if rising_edge(clk) then
            if tim <= 1 then tim <= tim +1;--�����ص���ʱ��һ
            else tim <= "00";
            end if;
            --���ݲ�ͬ�ļ���ֵ���벻ͬ������
            if tim = "00" then
                temp0 <= tem_min; temp1 <= tem_sec_min; temp2 <= data4; temp3 <= data5;
            else 
                temp0 <= data0; temp1 <= data1; temp2 <= data2; temp3 <= data3;
                tim <= "00";
            end if; 
        end if;
    end process;
    --���ݼ���ֵȷ�����
    process(tim)
    begin
    if tim = "00" then
        min <= tem_min; sec_min <= tem_sec_min;
    end if;
    end process;      
    
end Behavioral;
