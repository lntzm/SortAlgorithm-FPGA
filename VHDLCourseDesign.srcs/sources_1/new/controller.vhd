----------------------------------------------------------------------------------
-- 顶层元件，总控制器
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity controller is
    Port ( clk, rst     : in std_logic;
           input        : in std_logic_vector(7 downto 0);  -- 数的输入
           previous_num : in std_logic;     -- 按键控制
           next_num     : in std_logic;
           view_min_sec : in std_logic;
           view_sort    : in std_logic;
           oled_sdin    : out std_logic;    -- 输出给oled
           oled_sclk    : out std_logic;
           oled_dc      : out std_logic;
           oled_res     : out std_logic;
           oled_vbat    : out std_logic;
           oled_vdd     : out std_logic;
           leds         : out std_logic_vector(5 downto 0));
end controller;

architecture Behavioral of controller is
    component OLED_init is
        Port ( clk         : in std_logic;
               rst         : in std_logic;
               en          : in std_logic;
               sdout       : out std_logic; -- 经选择连到OLED
               oled_sclk   : out std_logic; -- 经选择连到OLED
               oled_dc     : out std_logic; -- 经选择连到OLED
               oled_res    : out std_logic; -- 直接连到OLED
               oled_vbat   : out std_logic; -- 直接连到OLED
               oled_vdd    : out std_logic; -- 直接连到OLED
               finish      : out std_logic);
    end component;

    component OLED_show is
        Port ( clk       : in std_logic;
               rst       : in std_logic;
               en        : in std_logic;
               data0     : in std_logic_vector(7 downto 0);
               data1     : in std_logic_vector(7 downto 0);
               data2     : in std_logic_vector(7 downto 0);
               data3     : in std_logic_vector(7 downto 0);
               data4     : in std_logic_vector(7 downto 0);
               data5     : in std_logic_vector(7 downto 0);
               index     : in std_logic_vector(2 downto 0);
               sdout     : out std_logic; -- 经选择连到OLED
               oled_sclk : out std_logic; -- 经选择连到OLED
               oled_dc   : out std_logic); -- 经选择连到OLED
    end component;

    component debounce is
        Port ( in_key : in STD_LOGIC;
               clk : in STD_LOGIC;
               out_key : out STD_LOGIC);
    end component;

    component min_secmin_A is
        Port ( data0 : in STD_LOGIC_VECTOR (7 downto 0);
               data1 : in STD_LOGIC_VECTOR (7 downto 0);
               data2 : in STD_LOGIC_VECTOR (7 downto 0);
               data3 : in STD_LOGIC_VECTOR (7 downto 0);
               data4 : in STD_LOGIC_VECTOR (7 downto 0);
               data5 : in STD_LOGIC_VECTOR (7 downto 0);
               min : out STD_LOGIC_VECTOR (7 downto 0);
               second_min : out STD_LOGIC_VECTOR (7 downto 0));
    end component;

    component sort_A is
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
    end component;

    type state is (Idle, Init, Input0, Input1, Input2,
                   Input3, Input4, Input5, 
                   ShowMinSec, ShowSort, Confirmed);
    
    signal pr_state, nx_state : state;
    
    -- oled两个元件的控制信号
    signal init_en          : std_logic;
    signal init_done        : std_logic;
    signal show_en          : std_logic;
--    signal show_done        : std_logic;
    
    -- oled两个元件经选择后才能连到OLED的信号
    signal init_sdata       : std_logic;
    signal init_spi_clk     : std_logic;
    signal init_dc          : std_logic;
    signal show_sdata       : std_logic;
    signal show_spi_clk     : std_logic;
    signal show_dc          : std_logic;
    
    -- 消抖后的按键信号
    signal previous_btn     : std_logic;
    signal next_btn         : std_logic;
    signal min_sec_btn      : std_logic;
    signal sort_btn         : std_logic;
    
    -- 6个输入数据
    signal data0, data1, data2 : std_logic_vector(7 downto 0);
    signal data3, data4, data5 : std_logic_vector(7 downto 0);
    
    -- 得到的最小值次小值
    signal min, second_min  : std_logic_vector(7 downto 0);
    
    -- 得到从小到大排序后的值
    signal sorted0, sorted1, sorted2 : std_logic_vector(7 downto 0);
    signal sorted3, sorted4, sorted5 : std_logic_vector(7 downto 0);
    
    -- 输入给OLED_show的数据
    signal index : std_logic_vector(2 downto 0);
    signal num0, num1, num2 : std_logic_vector(7 downto 0);
    signal num3, num4, num5 : std_logic_vector(7 downto 0);
    
begin

    OLEDInit : OLED_init
    port map (clk=>clk, rst=>rst, en=>init_en,
              sdout=>init_sdata,
              oled_sclk=>init_spi_clk,
              oled_dc=>init_dc,
              oled_res=>oled_res,
              oled_vbat=>oled_vbat,
              oled_vdd=>oled_vdd,
              finish=>init_done);
    
    OLEDDisplay : OLED_show
    port map (clk=>clk, rst=>rst, en=>show_en,
              data0=>num0, data1=>num1, data2=>num2,
              data3=>num3, data4=>num4, data5=>num5,
              index=>index,
              sdout=>show_sdata,
              oled_sclk=>show_spi_clk,
              oled_dc=>show_dc);

    GetBtnU : debounce
    port map(in_key=>previous_num,
             clk=>clk,
             out_key=>previous_btn);

    GetBtnD : debounce
    port map(in_key=>next_num,
             clk=>clk,
             out_key=>next_btn);

    GetBtnL : debounce
    port map(in_key=>view_min_sec,
             clk=>clk,
             out_key=>min_sec_btn);

    GetBtnR : debounce
    port map(in_key=>view_sort,
             clk=>clk,
             out_key=>sort_btn);

    CalMinSec : min_secmin_A
    port map (data0=>data0, data1=>data1, data2=>data2,
              data3=>data3, data4=>data4, data5=>data5,
              min=>min, second_min=>second_min);

    CalSort : sort_A
    port map (data0=>data0, data1=>data1, data2=>data2,
              data3=>data3, data4=>data4, data5=>data5,
              output0=>sorted0, output1=>sorted1,
              output2=>sorted2, output3=>sorted3,
              output4=>sorted4, output5=>sorted5);
    
    process(rst, clk)
    begin
        if (rst='1') then
            pr_state <= Idle;
        elsif (rising_edge(clk)) then
            pr_state <= nx_state;
        end if;
    end process;

    process(pr_state, init_done, next_btn,
            previous_btn, min_sec_btn, sort_btn)
    begin
        case pr_state is
        when Idle =>
            leds <= "000000";
            nx_state <= Init;
        -- 初始化OLED 
        when Init =>
            leds <= "111111";
            if init_done = '1' then
                nx_state <= Input0;
            else
                nx_state <= Init;
            end if;
        -- 输入第1个数
        when Input0 =>
            leds <= "000001";
            index <= "000";
            data0 <= input;
            num0 <= input; num1 <= data1; num2 <= data2;
            num3 <= data3; num4 <= data4; num5 <= data5;
            if (next_btn='1') then
                nx_state <= Input1;
            else
                nx_state <= Input0;
            end if;
        -- 输入第2个数
        when Input1 =>
            leds <= "000010";
            index <= "001";
            data1 <= input;
            num0 <= data0; num1 <= input; num2 <= data2;
            num3 <= data3; num4 <= data4; num5 <= data5;
            if (next_btn='1') then
                nx_state <= Input2;
            elsif (previous_btn='1') then
                nx_state <= Input0;
            else
                nx_state <= Input1;
            end if;
        -- 输入第3个数
        when Input2 =>
            leds <= "000100";
            index <= "010";
            data2 <= input;
            num0 <= data0; num1 <= data1; num2 <= input;
            num3 <= data3; num4 <= data4; num5 <= data5;
            if (next_btn='1') then
                nx_state <= Input3;
            elsif (previous_btn='1') then
                nx_state <= Input1;
            else
                nx_state <= Input2;
            end if;
        -- 输入第4个数
        when Input3 =>
            leds <= "001000";
            index <= "011";
            data3 <= input;
            num0 <= data0; num1 <= data1; num2 <= data2;
            num3 <= input; num4 <= data4; num5 <= data5;
            if (next_btn='1') then
                nx_state <= Input4;
            elsif (previous_btn='1') then
                nx_state <= Input2;
            else
                nx_state <= Input3;
            end if;
        -- 输入第5个数
        when Input4 =>
            leds <= "010000";
            index <= "100";
            data4 <= input;
            num0 <= data0; num1 <= data1; num2 <= data2;
            num3 <= data3; num4 <= input; num5 <= data5;
            if (next_btn='1') then
                nx_state <= Input5;
            elsif (previous_btn='1') then
                nx_state <= Input3;
            else
                nx_state <= Input4;
            end if;
        -- 输入第6个数
        when Input5 =>
            leds <= "100000";
            index <= "101";
            data5 <= input;
            num0 <= data0; num1 <= data1; num2 <= data2;
            num3 <= data3; num4 <= data4; num5 <= input;
            if (next_btn='1') then
                nx_state <= Confirmed;
            elsif (previous_btn='1') then
                nx_state <= Input4;
            else
                nx_state <= Input5;
            end if;
        -- 确认所有输入数据
        when Confirmed =>
            leds <= "000000";
            index <= "101";
            num0 <= data0; num1 <= data1; num2 <= data2;
            num3 <= data3; num4 <= data4; num5 <= data5;
            if (previous_btn='1') then
                nx_state <= Input5;
            elsif (min_sec_btn='1') then
                nx_state <= ShowMinSec;
            elsif (sort_btn='1') then
                nx_state <= ShowSort;
            else
                nx_state <= Confirmed;
            end if;
        -- 显示最小值次小值
        when ShowMinSec =>
            leds <= "000000";
            index <= "110";
            num0 <= min; num1 <= second_min;
            if (previous_btn='1') then
                nx_state <= Input5;
            elsif (sort_btn='1') then
                nx_state <= ShowSort;
            else
                nx_state <= ShowMinSec;
            end if;
        -- 显示排序结果
        when ShowSort =>
            leds <= "000000";
            index <= "111";
            num0 <= sorted0; num1 <= sorted1; num2 <= sorted2;
            num3 <= sorted3; num4 <= sorted4; num5 <= sorted5;
            if (previous_btn='1') then
                nx_state <= Input5;
            elsif (min_sec_btn='1') then
                nx_state <= ShowMinSec;
            else
                nx_state <= ShowSort;
            end if;
        
        when others =>
            nx_state <= Idle;
        end case;
    end process;
    
    init_en <= '1' when pr_state = Init else '0';       -- OLED_init使能
    show_en <= '0' when (pr_state=Idle or pr_state=Init)
                   else '1';                            -- OLED_show使能
    
    -- 输出给一些OLED端口的选择器
    oled_sdin <= init_sdata when pr_state = Init else
                 show_sdata;
    oled_sclk <= init_spi_clk when pr_state = Init else
                 show_spi_clk;
    oled_dc   <= init_dc when pr_state = Init else
                 show_dc;

end Behavioral;
