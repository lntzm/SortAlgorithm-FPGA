----------------------------------------------------------------------------------
-- 求最小值与次小值 方案A
-- 采用软件设计思想，纯组合逻辑
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity min_secmin_A is
    Port ( data0 : in STD_LOGIC_VECTOR (7 downto 0);
           data1 : in STD_LOGIC_VECTOR (7 downto 0);
           data2 : in STD_LOGIC_VECTOR (7 downto 0);
           data3 : in STD_LOGIC_VECTOR (7 downto 0);
           data4 : in STD_LOGIC_VECTOR (7 downto 0);
           data5 : in STD_LOGIC_VECTOR (7 downto 0);
           min   : out STD_LOGIC_VECTOR (7 downto 0);
           second_min : out STD_LOGIC_VECTOR (7 downto 0));
end min_secmin_A;

architecture Behavioral of min_secmin_A is
    -- 构造数组，方便使用下标
    type data_matrix is array(0 to 5) of std_logic_vector(7 downto 0);
begin
    process(data0, data1, data2, data3, data4, data5)
        variable temp : std_logic_vector(7 downto 0);
        variable data : data_matrix;
    begin
        data := (data0, data1, data2, data3, data4, data5);
        
        -- 找到6个数中的最小值，与data(0)交换位置
        for i in 1 to 5 loop
            if data(i) < data(0) then
                temp := data(0);
                data(0) := data(i);
                data(i) := temp;
            end if;
        end loop;
        
        -- 在除data(0)以外的5个数中找最小值，与data(1)交换位置
        for j in 2 to 5 loop
            if data(j) < data(1) then
                data(1) := data(j);
            end if;
        end loop;
        
        min <= data(0);
        second_min <= data(1);
    end process;
    
end Behavioral;
