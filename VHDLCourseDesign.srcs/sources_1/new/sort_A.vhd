----------------------------------------------------------------------------------
-- 按从小到大排序 方案A
-- 采用软件设计思想，纯组合逻辑
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sort_A is
    Port ( data0    : in STD_LOGIC_VECTOR (7 downto 0);
           data1    : in STD_LOGIC_VECTOR (7 downto 0);
           data2    : in STD_LOGIC_VECTOR (7 downto 0);
           data3    : in STD_LOGIC_VECTOR (7 downto 0);
           data4    : in STD_LOGIC_VECTOR (7 downto 0);
           data5    : in STD_LOGIC_VECTOR (7 downto 0);
           output0  : out STD_LOGIC_VECTOR (7 downto 0);
           output1  : out STD_LOGIC_VECTOR (7 downto 0);
           output2  : out STD_LOGIC_VECTOR (7 downto 0);
           output3  : out STD_LOGIC_VECTOR (7 downto 0);
           output4  : out STD_LOGIC_VECTOR (7 downto 0);
           output5  : out STD_LOGIC_VECTOR (7 downto 0));
end sort_A;

architecture Behavioral of sort_A is
    type data_matrix is array(0 to 5) of std_logic_vector(7 downto 0);
begin
    -- 采用冒泡排序法进行排序
    process(data0, data1, data2, data3, data4, data5)
        variable temp : std_logic_vector(7 downto 0);
        variable data : data_matrix;
    begin
        -- 构造数组，方便使用下标
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
                temp := data(1);
                data(1) := data(j);
                data(j) := temp;
            end if;
        end loop;
        
        -- 在剩下的4个数中找最小值，与data(2)交换位置
        for k in 3 to 5 loop
            if data(k) < data(2) then
                temp := data(2);
                data(2) := data(k);
                data(k) := temp;
            end if;
        end loop;
        
        -- 在剩下的3个数中找最小值，与data(3)交换位置
        for l in 4 to 5 loop
            if data(l) < data(3) then
                temp := data(3);
                data(3) := data(l);
                data(l) := temp;
            end if;
        end loop;
        
        output0 <= data(0);
        output1 <= data(1);
        output2 <= data(2);
        output3 <= data(3);
        
        -- output4取data(4)与data(5)的较小值
        if data(5) < data(4) then
            output4 <= data(5);
            output5 <= data(4);
        else
            output4 <= data(4);
            output5 <= data(5);
        end if;

    end process;

end Behavioral;
