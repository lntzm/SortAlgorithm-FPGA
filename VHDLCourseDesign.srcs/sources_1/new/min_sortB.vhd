library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity min_sortB is
    Port ( clk, rst : in STD_LOGIC;
           data0 : in STD_LOGIC_VECTOR (7 downto 0);
           data1 : in STD_LOGIC_VECTOR (7 downto 0);
           data2 : in STD_LOGIC_VECTOR (7 downto 0);
           data3 : in STD_LOGIC_VECTOR (7 downto 0);
           data4 : in STD_LOGIC_VECTOR (7 downto 0);
           data5 : in STD_LOGIC_VECTOR (7 downto 0);
           min : out STD_LOGIC_VECTOR (7 downto 0));
end min_sortB;

architecture Behavioral of min_sortB is
    signal q0, q1, q2, q3, q4, q5 : STD_LOGIC_VECTOR (7 downto 0);

begin
    q1 <= data0 when data0 < data1 else
          data1;
    q2 <= data2 when data2 < data3 else
          data3;
    q3 <= data4 when data4 < data5 else
          data5;
    q4 <= q1 when q1 < q2 else
          q2;
    q5 <= q3 when q3 < q4 else
          q4;
   process(clk, rst)
   begin
        if (rst='1') then min <= (others=>'0');
        elsif rising_edge(clk) then
        min <= q5;
       end if;
    end process;

end Behavioral;