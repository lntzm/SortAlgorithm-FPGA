library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity min_secmin_C is
    Port (data0, data1, data2, data3, data4, data5  :in std_logic_vector(7 downto 0);   --六个八位输入数据
          min, sec_min                              :out std_logic_vector(7 downto 0)); --最小值和次小值
end min_secmin_C;

architecture Behavioral of min_secmin_C is
    component min_chose_4_2_C is
        Port (data0, data1, data2, data3    :in std_logic_vector(7 downto 0);
              min, sec_min                   :out std_logic_vector(7 downto 0));
    end component;
    signal temp1, temp2 :std_logic_vector(7 downto 0);
begin
    --将前四个数据输入到第一个选择最小次小值的U1中
    U1:min_chose_4_2_C port map(data0 => data0, data1 => data1, data2 => data2 ,data3 => data3, min => temp1, sec_min => temp2);
    --将U1输出的最小值和次小值同后两个数据一起输入到U2中
    U2:min_chose_4_2_C port map(data0 => temp1, data1 => temp2, data2 => data4, data3 => data5, min => min, sec_min => sec_min);
end Behavioral;