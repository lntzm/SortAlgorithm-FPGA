--四个八位输入数据求最小、次小值的选择器
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;

entity min_chose_4_2_C is
    Port (data0, data1, data2, data3    :in std_logic_vector(7 downto 0);
          min, sec_min                  :out std_logic_vector(7 downto 0));
end min_chose_4_2_C;

architecture Behavioral of min_chose_4_2_C is
    component comparer_B is
        port(A, B   :in std_logic_vector(7 downto 0);
             tab    :out std_logic;
             q      :out std_logic_vector(7 downto 0));
    end component;
    signal tab  :std_logic_vector(2 downto 0);         --用三位长度的信号将所有比较器的输出标号合并
    signal tem, tem_min, tem_min0, tem_min1    :std_logic_vector(7 downto 0);
begin
    --利用三个比较器相连接求出四个数据中的最小值
    dut1:comparer_B port map(A => data0, B => data1, tab => tab(0), q => tem_min0);
    dut2:comparer_B port map(A => data2, B => data3, tab => tab(1), q => tem_min1);
    dut3:comparer_B port map(A => tem_min0, B => tem_min1, tab => tab(2), q => min);
    
    --根据不同的标号值选择不同的数据
    process(tab)
    begin
        if tab(2) = '1' and tab(0) = '1' then 
            tem_min <= tem_min1; tem<=data1;     --最小值是data0
        elsif tab(2) = '1' and tab(0) = '0' then
            tem_min <= tem_min1; tem<=data0;     --最小值是data1
        elsif tab(2) = '0' and tab(1) = '1' then
            tem_min <= tem_min0; tem <= data3;   --最小值是data2
        elsif tab(2) = '0' and tab(1) = '0' then
            tem_min <= tem_min0; tem <= data2;   --最小值是data3
--        else 
--            tem_min <= tem_min0; tem <= data2;
        end if;
    end process;
   
    --利用比较器输出的标号对特定的数据进行比较，从而得到次小值    
    --dut4:comparer_B port map(A=>tem, B=>tem_min, q=>sec_min);
    
    --利用unsigned库现成的比较器进行比较，从而得到次小值
    sec_min <= tem when tem < tem_min else tem_min;
    
end Behavioral;