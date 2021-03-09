----------------------------------------------------------------------------------
-- OLED显示程序，根据index判断应输出的屏幕，将数据显示到屏幕上
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity OLED_show is
    Port ( clk       : in std_logic;
           rst       : in std_logic;  -- 异步复位
           en        : in std_logic;  -- 同步使能
           data0     : in std_logic_vector(7 downto 0);
           data1     : in std_logic_vector(7 downto 0);
           data2     : in std_logic_vector(7 downto 0);
           data3     : in std_logic_vector(7 downto 0);
           data4     : in std_logic_vector(7 downto 0);
           data5     : in std_logic_vector(7 downto 0);
           index     : in std_logic_vector(2 downto 0); --显示的模式
           sdout     : out std_logic; -- SPI输出数据，送给oled SDIN
           oled_sclk : out std_logic; -- SPI输出时钟，送给oled SCLK
           oled_dc   : out std_logic); -- 数据/命令 控制，=1送数据，=0送命令
end OLED_show;

architecture Behavioral of OLED_show is
    component spi_ctrl is
        Port ( clk         : in std_logic;
               rst         : in std_logic;
               en          : in std_logic;
               sdata       : in std_logic_vector (7 downto 0);
               sdout       : out std_logic;
               oled_sclk   : out std_logic;
               finish      : out std_logic);
    end component;

    component delay is
        Port ( clk         : in std_logic;
               rst         : in std_logic;
               delay_ms    : in std_logic_vector (7 downto 0);
               en          : in std_logic;
               finish      : out std_logic);
    end component;
    
    component ascii_memory is
        Port ( clk    : in std_logic;
               addr   : in std_logic_vector (10 downto 0);
               dout   : out std_logic_vector (7 downto 0));
    end component;

    type states is (-- inside states --
                    SetSPI, WaitSPIFinish,      -- SPI发送状态
                    SetDelay, WaitDelayFinish,  -- delay延时状态
                    Transition,                 -- 切换到outside state
                    -- end inside states --
                    
                     -- middle1: send char states--
                    SendChar0, SendChar1, SendChar2, SendChar3,
                    SendChar4, SendChar5, SendChar6, SendChar7,
                    ReadMem1, ReadMem2,
                    -- end middle1 --
                   
                    -- middle2: update page states --
                    ClearDC, SetPage, PageNum,
                    LeftColumn1, LeftColumn2, SetDC,
                    -- end middle2--
                    
                    -- outside: get showing words --
                    Idle, GetScreen, Waiting, Done,
                    UpdateScreen
                    -- end outside --
                    );

    signal present_state : states := Idle;
    signal after_state : states := Idle;    -- 完成SPI传输或完成延时的状态
    signal after_char_state : states;       -- 更新完一个字符(8bit x 8bit)之后的状态
    signal after_page_state : states;      -- 更新完一页(1char x 16char)之后的状态
    signal after_update_state : states;     -- 更新完整个屏幕(4pages)之后的状态
    
    -- 定义类型oled_screen，共4pages，一个page有16chars，一个char由8bit ascii码表示
    type oled_screen is array(0 to 3, 0 to 15) of std_logic_vector(7 downto 0);
    signal present_screen : oled_screen;
    constant input_screen : oled_screen := 
        ((x"20", x"20", x"20", x"20", x"20", x"49", x"4E", x"50", x"55", x"54", x"20", x"20", x"20", x"20", x"20", x"20"),
         (x"4E", x"75", x"6D", x"30", x"3A", x"20", x"20", x"20", x"4E", x"75", x"6D", x"31", x"3A", x"20", x"20", x"20"),
         (x"4E", x"75", x"6D", x"32", x"3A", x"20", x"20", x"20", x"4E", x"75", x"6D", x"33", x"3A", x"20", x"20", x"20"),
         (x"4E", x"75", x"6D", x"34", x"3A", x"20", x"20", x"20", x"4E", x"75", x"6D", x"35", x"3A", x"20", x"20", x"20"));
    constant min_screen : oled_screen := 
        ((x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20"),
         (x"20", x"20", x"20", x"20", x"6D", x"69", x"6E", x"20", x"20", x"20", x"20", x"3A", x"20", x"20", x"20", x"20"),
         (x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20"),
         (x"20", x"73", x"65", x"63", x"6F", x"6E", x"64", x"20", x"6D", x"69", x"6E", x"3A", x"20", x"20", x"20", x"20"));
    constant sort_screen : oled_screen := 
        ((x"20", x"20", x"20", x"20", x"20", x"53", x"4F", x"52", x"54", x"45", x"44", x"20", x"20", x"20", x"20", x"20"),
         (x"4E", x"75", x"6D", x"30", x"3A", x"20", x"20", x"20", x"4E", x"75", x"6D", x"31", x"3A", x"20", x"20", x"20"),
         (x"4E", x"75", x"6D", x"32", x"3A", x"20", x"20", x"20", x"4E", x"75", x"6D", x"33", x"3A", x"20", x"20", x"20"),
         (x"4E", x"75", x"6D", x"34", x"3A", x"20", x"20", x"20", x"4E", x"75", x"6D", x"35", x"3A", x"20", x"20", x"20"));
    
    -- 由6个数构成的数组
    type data_matrix is array(0 to 5) of std_logic_vector(7 downto 0);
    signal data : data_matrix;
    
    signal temp_dc : std_logic := '0';  -- 与oled_dc绑定

    -- 与delay端口绑定的信号
    signal temp_delay_ms : std_logic_vector (7 downto 0);  -- 要延迟的毫秒数
    signal temp_delay_en : std_logic := '0';    -- delay元件的使能信号
    signal temp_delay_fin : std_logic;  -- delay元件的完成标志

    -- 与spi端口绑定的信号
    signal temp_spi_en : std_logic := '0';  -- 使能信号
    signal temp_sdata : std_logic_vector (7 downto 0) := (others => '0');   -- 想发送的序列
    signal temp_spi_fin : std_logic;    -- 完成标志
    
    signal temp_char : std_logic_vector (7 downto 0) := (others => '0'); -- 待显示字符的ascii码值
    signal temp_addr : std_logic_vector (10 downto 0) := (others => '0'); -- ascii码值对应在ascii_memory的地址
    signal temp_dout : std_logic_vector (7 downto 0); -- ascii_memory输出值
    signal temp_page : std_logic_vector (1 downto 0) := (others => '0'); -- 当前page
    signal temp_index : integer range 0 to 15 := 0; -- 当前字符在page里的index
    
    -- 将数字替换进待显示的oled屏幕，封装为函数
    function replace_screen(index : std_logic_vector(2 downto 0);
                            nums : data_matrix;
                            screen : oled_screen) return oled_screen is
        variable high_nums, low_nums: data_matrix;
        variable new_screen : oled_screen;
    begin
        new_screen := screen;
        
        for i in 0 to 5 loop
            if nums(i)(7 downto 4) > "1001" then --大于9，ascii码值转为大写字母
                high_nums(i) := ("0100" & nums(i)(7 downto 4)) - 9;
            else
                high_nums(i) := "0011" & nums(i)(7 downto 4);
            end if;
            
            if nums(i)(3 downto 0) > "1001" then --大于9，ascii码值转为大写字母
                low_nums(i) := ("0100" & nums(i)(3 downto 0)) - 9;
            else
                low_nums(i) := "0011" & nums(i)(3 downto 0);
            end if;
        end loop;
        
        case index is
        when "000" =>   -- 输入第1个数
            new_screen(1, 5) := high_nums(0);
            new_screen(1, 6) := low_nums(0);
        when "001" =>   -- 输入第2个数
            new_screen(1, 5) := high_nums(0);
            new_screen(1, 6) := low_nums(0);
            new_screen(1, 13) := high_nums(1);
            new_screen(1, 14) := low_nums(1);
        when "010" =>   -- 输入第3个数
            new_screen(1, 5) := high_nums(0);
            new_screen(1, 6) := low_nums(0);
            new_screen(1, 13) := high_nums(1);
            new_screen(1, 14) := low_nums(1);
            new_screen(2, 5) := high_nums(2);
            new_screen(2, 6) := low_nums(2);
        when "011" =>   -- 输入第4个数
            new_screen(1, 5) := high_nums(0);
            new_screen(1, 6) := low_nums(0);
            new_screen(1, 13) := high_nums(1);
            new_screen(1, 14) := low_nums(1);
            new_screen(2, 5) := high_nums(2);
            new_screen(2, 6) := low_nums(2);
            new_screen(2, 13) := high_nums(3);
            new_screen(2, 14) := low_nums(3);
        when "100" =>   -- 输入第5个数
            new_screen(1, 5) := high_nums(0);
            new_screen(1, 6) := low_nums(0);
            new_screen(1, 13) := high_nums(1);
            new_screen(1, 14) := low_nums(1);
            new_screen(2, 5) := high_nums(2);
            new_screen(2, 6) := low_nums(2);
            new_screen(2, 13) := high_nums(3);
            new_screen(2, 14) := low_nums(3);
            new_screen(3, 5) := high_nums(4);
            new_screen(3, 6) := low_nums(4);
        when "101" =>   -- 输入第6个数
            new_screen(1, 5) := high_nums(0);
            new_screen(1, 6) := low_nums(0);
            new_screen(1, 13) := high_nums(1);
            new_screen(1, 14) := low_nums(1);
            new_screen(2, 5) := high_nums(2);
            new_screen(2, 6) := low_nums(2);
            new_screen(2, 13) := high_nums(3);
            new_screen(2, 14) := low_nums(3);
            new_screen(3, 5) := high_nums(4);
            new_screen(3, 6) := low_nums(4);
            new_screen(3, 13) := high_nums(5);
            new_screen(3, 14) := low_nums(5);
        when "110" =>   -- 显示最小值与次小值
            new_screen(1, 13) := high_nums(0);
            new_screen(1, 14) := low_nums(0);
            new_screen(3, 13) := high_nums(1);
            new_screen(3, 14) := low_nums(1);
        when "111" =>   -- 显示排序后的6个数
            new_screen(1, 5) := high_nums(0);
            new_screen(1, 6) := low_nums(0);
            new_screen(1, 13) := high_nums(1);
            new_screen(1, 14) := low_nums(1);
            new_screen(2, 5) := high_nums(2);
            new_screen(2, 6) := low_nums(2);
            new_screen(2, 13) := high_nums(3);
            new_screen(2, 14) := low_nums(3);
            new_screen(3, 5) := high_nums(4);
            new_screen(3, 6) := low_nums(4);
            new_screen(3, 13) := high_nums(5);
            new_screen(3, 14) := low_nums(5);
        when others =>
            null;
        end case;
        return new_screen;
    end replace_screen;
    
begin
    spi_com: spi_ctrl port map (clk=>clk, rst=>rst,
                                en=>temp_spi_en,
                                sdata=>temp_sdata,
                                sdout=>sdout,
                                oled_sclk=>oled_sclk,
                                finish=>temp_spi_fin);
    
    delay_com: delay port map (clk=>clk, rst=>rst,
                               delay_ms=>temp_delay_ms,
                               en=>temp_delay_en,
                               finish=>temp_delay_fin);
    
    char_com: ascii_memory port map (clk=>clk,
                                     addr=>temp_addr,
                                     dout=>temp_dout);
    
    oled_dc <= temp_dc;
    data <= (data0, data1, data2, data3, data4, data5);

    process (clk)
    begin
        if rising_edge(clk) then
            case present_state is
            -------- outside layer --------
            when Idle =>
                if en = '1' then
                    present_state <= ClearDC;
                    after_page_state <= GetScreen;
                    temp_page <= "00";
                end if;
            -- 设置当前屏幕为input_screen，更新屏幕，完成更新后进入延时
            when GetScreen =>
                if (index="111") then
                    present_screen <= replace_screen(index, data, sort_screen);
                elsif (index="110") then
                    present_screen <= replace_screen(index, data, min_screen);
                else
                    present_screen <= replace_screen(index, data, input_screen);
                end if;
                present_state <= UpdateScreen;
                after_update_state <= Waiting;

            -- 延时100ms，完成
            when Waiting =>
                temp_delay_ms <= "01100100"; -- 100ms
                after_state <= Idle;
                present_state <= SetDelay;
           
            -- UpdateScreen，各状态转换的中转站
            -- 遍历所有字符，获取当前字符的ascii码值，存给temp_char，进入middle1传送字符；
            -- 完成一页，outside进入middle2；完成所有页，回到outside执行after_update_state
            when UpdateScreen =>
                temp_char <= present_screen(conv_integer(temp_page), temp_index);
                if temp_index = 15 then
                    temp_index <= 0;
                    temp_page <= temp_page + 1;
                    after_char_state <= ClearDC;
                    if temp_page = "11" then
                        after_page_state <= after_update_state;
                    else
                        after_page_state <= UpdateScreen;
                    end if;
                else
                    temp_index <= temp_index + 1;
                    after_char_state <= UpdateScreen;
                end if;
                present_state <= SendChar0;
            -------- end outside layer --------

            -------- middle1 layer: send char states--------
            -- 一个8bit ascii字符为显示为8x8点阵，合成地址查找ascii_memory，
            -- 地址由"ascii码值 + 0~7"构成，因此送8次，一次8bit
            -- 每合成一个地址等待一个clk用于内存查找，再进行SPI发送，防止亚稳态
            when SendChar0 =>
                temp_addr <= temp_char & "000";
                after_state <= SendChar1;
                present_state <= ReadMem1;
            when SendChar1 =>
                temp_addr <= temp_char & "001";
                after_state <= SendChar2;
                present_state <= ReadMem1;
            when SendChar2 =>
                temp_addr <= temp_char & "010";
                after_state <= SendChar3;
                present_state <= ReadMem1;
            when SendChar3 =>
                temp_addr <= temp_char & "011";
                after_state <= SendChar4;
                present_state <= ReadMem1;
            when SendChar4 =>
                temp_addr <= temp_char & "100";
                after_state <= SendChar5;
                present_state <= ReadMem1;
            when SendChar5 =>
                temp_addr <= temp_char & "101";
                after_state <= SendChar6;
                present_state <= ReadMem1;
            when SendChar6 =>
                temp_addr <= temp_char & "110";
                after_state <= SendChar7;
                present_state <= ReadMem1;
            when SendChar7 =>
                temp_addr <= temp_char & "111";
                after_state <= after_char_state;
                present_state <= ReadMem1;
            when ReadMem1 =>
                present_state <= ReadMem2;
            when ReadMem2 =>
                temp_sdata <= temp_dout;
                present_state <= SetSPI;
            -------- end middle1 layer --------

            -------- middle2 layer: update page states --------
            -- 切换到命令模式，发送SetPage命令、起始像素命令等，再回到数据模式
            when ClearDC =>
                temp_dc <= '0';
                present_state <= SetPage;
            when SetPage =>
                temp_sdata <= "00100010";
                after_state <= PageNum;
                present_state <= SetSPI;
            when PageNum =>
                temp_sdata <= "000000" & temp_page;
                after_state <= LeftColumn1;
                present_state <= SetSPI;
            when LeftColumn1 =>
                temp_sdata <= "00000000";
                after_state <= LeftColumn2;
                present_state <= SetSPI;
            when LeftColumn2 =>
                temp_sdata <= "00010000";
                after_state <= SetDC;
                present_state <= SetSPI;
            when SetDC =>
                temp_dc <= '1';
                present_state <= after_page_state;
            -------- end middle2 layer --------
            
            -------- inside layer: 内层SPI发送与延时 --------
            -- SPI transitions
            -- 使能spi元件，等待finish信号，再跳到Transition复位使能端
            when SetSPI =>
                temp_spi_en <= '1';
                present_state <= WaitSPIFinish;
            when WaitSPIFinish =>
                if temp_spi_fin = '1' then
                    present_state <= Transition;
                end if;

            -- delay transitions
            -- 使能delay元件，等待finish信号，再跳到Transition复位使能端
            when SetDelay =>
                temp_delay_en <= '1';
                present_state <= WaitDelayFinish;
            when WaitDelayFinish =>
                if temp_delay_fin = '1' then
                    present_state <= Transition;
                end if;

            -- clear transitions
            -- 复位两个元件的使能端，跳到外层after_state
            when Transition =>
                temp_spi_en <= '0';
                temp_delay_en <= '0';
                present_state <= after_state;
            -------- end inside layer --------

            when others =>
                present_state <= Idle;
            end case;
        end if;
    end process;

end Behavioral;

