--������λ�������ݱȽ���
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity comparer_B is
    port(A,B    : in std_logic_vector(7 downto 0);
         tab    : out std_logic;                       --�����ţ�ȡ1��AΪ��Сֵ��ȡ0��BΪ��Сֵ
         q      : out std_logic_vector(7 downto 0));
end comparer_B;

architecture beh of comparer_B is
begin
    process(A,B)
    begin
        if A > B then
            q <= B; tab <= '0';
        else 
            q <= A; tab <= '1';
        end if;
    end process;
end beh;
