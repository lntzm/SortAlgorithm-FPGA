library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity min_secmin_C is
    Port (data0, data1, data2, data3, data4, data5  :in std_logic_vector(7 downto 0);   --������λ��������
          min, sec_min                              :out std_logic_vector(7 downto 0)); --��Сֵ�ʹ�Сֵ
end min_secmin_C;

architecture Behavioral of min_secmin_C is
    component min_chose_4_2_C is
        Port (data0, data1, data2, data3    :in std_logic_vector(7 downto 0);
              min, sec_min                   :out std_logic_vector(7 downto 0));
    end component;
    signal temp1, temp2 :std_logic_vector(7 downto 0);
begin
    --��ǰ�ĸ��������뵽��һ��ѡ����С��Сֵ��U1��
    U1:min_chose_4_2_C port map(data0 => data0, data1 => data1, data2 => data2 ,data3 => data3, min => temp1, sec_min => temp2);
    --��U1�������Сֵ�ʹ�Сֵͬ����������һ�����뵽U2��
    U2:min_chose_4_2_C port map(data0 => temp1, data1 => temp2, data2 => data4, data3 => data5, min => min, sec_min => sec_min);
end Behavioral;