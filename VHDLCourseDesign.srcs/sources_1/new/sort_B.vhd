library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sort_B is
    Port ( clk, rst : in STD_LOGIC;
           data0 : in STD_LOGIC_VECTOR (7 downto 0);
           data1 : in STD_LOGIC_VECTOR (7 downto 0);
           data2 : in STD_LOGIC_VECTOR (7 downto 0);
           data3 : in STD_LOGIC_VECTOR (7 downto 0);
           data4 : in STD_LOGIC_VECTOR (7 downto 0);
           data5 : in STD_LOGIC_VECTOR (7 downto 0);
           min0  : out STD_LOGIC_VECTOR (7 downto 0);
           min1  : out STD_LOGIC_VECTOR (7 downto 0);
           min2  : out STD_LOGIC_VECTOR (7 downto 0);
           min3  : out STD_LOGIC_VECTOR (7 downto 0);
           min4  : out STD_LOGIC_VECTOR (7 downto 0);
           min5  : out STD_LOGIC_VECTOR (7 downto 0));
end sort_B;

architecture Behavioral of sort_B is
component min_sortB is
    Port ( clk, rst : in STD_LOGIC;
           data0 : in STD_LOGIC_VECTOR (7 downto 0);
           data1 : in STD_LOGIC_VECTOR (7 downto 0);
           data2 : in STD_LOGIC_VECTOR (7 downto 0);
           data3 : in STD_LOGIC_VECTOR (7 downto 0);
           data4 : in STD_LOGIC_VECTOR (7 downto 0);
           data5 : in STD_LOGIC_VECTOR (7 downto 0);
           min : out STD_LOGIC_VECTOR (7 downto 0));
end component;
    signal d0, d1, d2, d3, d4, d5 : STD_LOGIC_VECTOR (7 downto 0);
    signal q0 : STD_LOGIC_VECTOR (7 downto 0);
    signal q1 : STD_LOGIC_VECTOR (7 downto 0);
    type state is (first, second, third, fourth, fifth, sixth, seventh);
    signal pr_state, nx_state : state;
    
begin

dut : min_sortB port map (clk=>clk, rst=>'0', data0=>d0, data1=>d1, data2=>d2, 
                          data3=>d3, data4=>d4, data5=>d5, min=>q0);         

seq:process(clk)
    begin
        if rst = '1' then 
            pr_state <= first;
        elsif rising_edge(clk) then
            pr_state <= nx_state;
        end if;               
    end process seq;
    
com:process(pr_state, q0, d0, d1, d2, d3, d4, d5)
    begin
        
        case pr_state is
 
        when first =>
            
             d0 <= data0; d1 <= data1;
             d2 <= data2; d3 <= data3;
             d4 <= data4; d5 <= data5;
             nx_state <= second;
             
             --min5 <= q0;--信号赋值有延迟
             --min1 <= q0;
        when second =>
             min0 <= q0;
             if (d0=q0) then d0 <= (others=>'1');
             elsif  (d1=q0) then d1 <= (others=>'1');
             elsif  (d2=q0) then d2 <= (others=>'1');
             elsif  (d3=q0) then d3 <= (others=>'1');
             elsif  (d4=q0) then d4 <= (others=>'1');
             elsif  (d5=q0) then d5 <= (others=>'1');
             end if;
             nx_state <= third;
             --min0 <= q0;--信号赋值有延迟
             --second_min <= q0;
        when third =>
             min1 <= q0;
             if (d0=q0) then d0 <= (others=>'1');
             elsif  (d1=q0) then d1 <= (others=>'1');
             elsif  (d2=q0) then d2 <= (others=>'1');
             elsif  (d3=q0) then d3 <= (others=>'1');
             elsif  (d4=q0) then d4 <= (others=>'1');
             elsif  (d5=q0) then d5 <= (others=>'1');
             end if;
             nx_state <= fourth;
             
             
        when fourth =>
             min2 <= q0;
             if (d0=q0) then d0 <= (others=>'1');
             elsif  (d1=q0) then d1 <= (others=>'1');
             elsif  (d2=q0) then d2 <= (others=>'1');
             elsif  (d3=q0) then d3 <= (others=>'1');
             elsif  (d4=q0) then d4 <= (others=>'1');
             elsif  (d5=q0) then d5 <= (others=>'1');
             end if;
             nx_state <= fifth;
             
             
       when fifth =>
             min3 <= q0;
             if (d0=q0) then d0 <= (others=>'1');
             elsif  (d1=q0) then d1 <= (others=>'1');
             elsif  (d2=q0) then d2 <= (others=>'1');
             elsif  (d3=q0) then d3 <= (others=>'1');
             elsif  (d4=q0) then d4 <= (others=>'1');
             elsif  (d5=q0) then d5 <= (others=>'1');
             end if;
             nx_state <= sixth;
             
             
       when sixth =>
             min4 <= q0;
             if (d0=q0) then d0 <= (others=>'1');
             elsif  (d1=q0) then d1 <= (others=>'1');
             elsif  (d2=q0) then d2 <= (others=>'1');
             elsif  (d3=q0) then d3 <= (others=>'1');
             elsif  (d4=q0) then d4 <= (others=>'1');
             elsif  (d5=q0) then d5 <= (others=>'1');
             end if;
             nx_state <= seventh;
             
         
        when seventh =>           
--             if (d0=q0) then d0 <= (others=>'1');
--             elsif  (d1=q0) then d1 <= (others=>'1');
--             elsif  (d2=q0) then d2 <= (others=>'1');
--             elsif  (d3=q0) then d3 <= (others=>'1');
--             elsif  (d4=q0) then d4 <= (others=>'1');
--             else d5 <= (others=>'1');
--             end if;
             min5 <= q0; 
             nx_state <= first;                                       
        end case;
    end process com;

end Behavioral;

