----------------------------------------------------------------------------------
-- OLED��ʾ���򣬸���index�ж�Ӧ�������Ļ����������ʾ����Ļ��
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity OLED_show is
    Port ( clk       : in std_logic;
           rst       : in std_logic;  -- �첽��λ
           en        : in std_logic;  -- ͬ��ʹ��
           data0     : in std_logic_vector(7 downto 0);
           data1     : in std_logic_vector(7 downto 0);
           data2     : in std_logic_vector(7 downto 0);
           data3     : in std_logic_vector(7 downto 0);
           data4     : in std_logic_vector(7 downto 0);
           data5     : in std_logic_vector(7 downto 0);
           index     : in std_logic_vector(2 downto 0); --��ʾ��ģʽ
           sdout     : out std_logic; -- SPI������ݣ��͸�oled SDIN
           oled_sclk : out std_logic; -- SPI���ʱ�ӣ��͸�oled SCLK
           oled_dc   : out std_logic); -- ����/���� ���ƣ�=1�����ݣ�=0������
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
                    SetSPI, WaitSPIFinish,      -- SPI����״̬
                    SetDelay, WaitDelayFinish,  -- delay��ʱ״̬
                    Transition,                 -- �л���outside state
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
    signal after_state : states := Idle;    -- ���SPI����������ʱ��״̬
    signal after_char_state : states;       -- ������һ���ַ�(8bit x 8bit)֮���״̬
    signal after_page_state : states;      -- ������һҳ(1char x 16char)֮���״̬
    signal after_update_state : states;     -- ������������Ļ(4pages)֮���״̬
    
    -- ��������oled_screen����4pages��һ��page��16chars��һ��char��8bit ascii���ʾ
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
    
    -- ��6�������ɵ�����
    type data_matrix is array(0 to 5) of std_logic_vector(7 downto 0);
    signal data : data_matrix;
    
    signal temp_dc : std_logic := '0';  -- ��oled_dc��

    -- ��delay�˿ڰ󶨵��ź�
    signal temp_delay_ms : std_logic_vector (7 downto 0);  -- Ҫ�ӳٵĺ�����
    signal temp_delay_en : std_logic := '0';    -- delayԪ����ʹ���ź�
    signal temp_delay_fin : std_logic;  -- delayԪ������ɱ�־

    -- ��spi�˿ڰ󶨵��ź�
    signal temp_spi_en : std_logic := '0';  -- ʹ���ź�
    signal temp_sdata : std_logic_vector (7 downto 0) := (others => '0');   -- �뷢�͵�����
    signal temp_spi_fin : std_logic;    -- ��ɱ�־
    
    signal temp_char : std_logic_vector (7 downto 0) := (others => '0'); -- ����ʾ�ַ���ascii��ֵ
    signal temp_addr : std_logic_vector (10 downto 0) := (others => '0'); -- ascii��ֵ��Ӧ��ascii_memory�ĵ�ַ
    signal temp_dout : std_logic_vector (7 downto 0); -- ascii_memory���ֵ
    signal temp_page : std_logic_vector (1 downto 0) := (others => '0'); -- ��ǰpage
    signal temp_index : integer range 0 to 15 := 0; -- ��ǰ�ַ���page���index
    
    -- �������滻������ʾ��oled��Ļ����װΪ����
    function replace_screen(index : std_logic_vector(2 downto 0);
                            nums : data_matrix;
                            screen : oled_screen) return oled_screen is
        variable high_nums, low_nums: data_matrix;
        variable new_screen : oled_screen;
    begin
        new_screen := screen;
        
        for i in 0 to 5 loop
            if nums(i)(7 downto 4) > "1001" then --����9��ascii��ֵתΪ��д��ĸ
                high_nums(i) := ("0100" & nums(i)(7 downto 4)) - 9;
            else
                high_nums(i) := "0011" & nums(i)(7 downto 4);
            end if;
            
            if nums(i)(3 downto 0) > "1001" then --����9��ascii��ֵתΪ��д��ĸ
                low_nums(i) := ("0100" & nums(i)(3 downto 0)) - 9;
            else
                low_nums(i) := "0011" & nums(i)(3 downto 0);
            end if;
        end loop;
        
        case index is
        when "000" =>   -- �����1����
            new_screen(1, 5) := high_nums(0);
            new_screen(1, 6) := low_nums(0);
        when "001" =>   -- �����2����
            new_screen(1, 5) := high_nums(0);
            new_screen(1, 6) := low_nums(0);
            new_screen(1, 13) := high_nums(1);
            new_screen(1, 14) := low_nums(1);
        when "010" =>   -- �����3����
            new_screen(1, 5) := high_nums(0);
            new_screen(1, 6) := low_nums(0);
            new_screen(1, 13) := high_nums(1);
            new_screen(1, 14) := low_nums(1);
            new_screen(2, 5) := high_nums(2);
            new_screen(2, 6) := low_nums(2);
        when "011" =>   -- �����4����
            new_screen(1, 5) := high_nums(0);
            new_screen(1, 6) := low_nums(0);
            new_screen(1, 13) := high_nums(1);
            new_screen(1, 14) := low_nums(1);
            new_screen(2, 5) := high_nums(2);
            new_screen(2, 6) := low_nums(2);
            new_screen(2, 13) := high_nums(3);
            new_screen(2, 14) := low_nums(3);
        when "100" =>   -- �����5����
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
        when "101" =>   -- �����6����
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
        when "110" =>   -- ��ʾ��Сֵ���Сֵ
            new_screen(1, 13) := high_nums(0);
            new_screen(1, 14) := low_nums(0);
            new_screen(3, 13) := high_nums(1);
            new_screen(3, 14) := low_nums(1);
        when "111" =>   -- ��ʾ������6����
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
            -- ���õ�ǰ��ĻΪinput_screen��������Ļ����ɸ��º������ʱ
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

            -- ��ʱ100ms�����
            when Waiting =>
                temp_delay_ms <= "01100100"; -- 100ms
                after_state <= Idle;
                present_state <= SetDelay;
           
            -- UpdateScreen����״̬ת������תվ
            -- ���������ַ�����ȡ��ǰ�ַ���ascii��ֵ�����temp_char������middle1�����ַ���
            -- ���һҳ��outside����middle2���������ҳ���ص�outsideִ��after_update_state
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
            -- һ��8bit ascii�ַ�Ϊ��ʾΪ8x8���󣬺ϳɵ�ַ����ascii_memory��
            -- ��ַ��"ascii��ֵ + 0~7"���ɣ������8�Σ�һ��8bit
            -- ÿ�ϳ�һ����ַ�ȴ�һ��clk�����ڴ���ң��ٽ���SPI���ͣ���ֹ����̬
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
            -- �л�������ģʽ������SetPage�����ʼ��������ȣ��ٻص�����ģʽ
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
            
            -------- inside layer: �ڲ�SPI��������ʱ --------
            -- SPI transitions
            -- ʹ��spiԪ�����ȴ�finish�źţ�������Transition��λʹ�ܶ�
            when SetSPI =>
                temp_spi_en <= '1';
                present_state <= WaitSPIFinish;
            when WaitSPIFinish =>
                if temp_spi_fin = '1' then
                    present_state <= Transition;
                end if;

            -- delay transitions
            -- ʹ��delayԪ�����ȴ�finish�źţ�������Transition��λʹ�ܶ�
            when SetDelay =>
                temp_delay_en <= '1';
                present_state <= WaitDelayFinish;
            when WaitDelayFinish =>
                if temp_delay_fin = '1' then
                    present_state <= Transition;
                end if;

            -- clear transitions
            -- ��λ����Ԫ����ʹ�ܶˣ��������after_state
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

