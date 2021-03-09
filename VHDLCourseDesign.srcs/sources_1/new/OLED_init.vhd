----------------------------------------------------------------------------------
-- OLED��ʼ�����򣬷��������OLED���г�ʼ��
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity OLED_init is
    Port ( clk         : in std_logic;
           rst         : in std_logic;  -- �첽��λ
           en          : in std_logic;  -- ͬ��ʹ��
           sdout       : out std_logic; -- SPI������ݣ��͸�oled SDIN
           oled_sclk   : out std_logic; -- SPI���ʱ�ӣ��͸�oled SCLK
           oled_dc     : out std_logic; -- ����/���� ���ƣ�=1�����ݣ�=0������
           oled_res    : out std_logic; -- OLED reset���͵�ƽ��Ч
           oled_vbat   : out std_logic; -- DC/DCת����·�ĵ�Դ����Ϊʹ�ܶ�
           oled_vdd    : out std_logic; -- power supply for logic
           finish      : out std_logic);-- ��ɵı�־
end OLED_init;

architecture Behavioral of OLED_init is
    component spi_ctrl
        port ( clk         : in std_logic;
               rst         : in std_logic;
               en          : in std_logic;
               sdata       : in std_logic_vector (7 downto 0);
               sdout       : out std_logic;
               oled_sclk   : out std_logic;
               finish      : out std_logic);
    end component;

    component delay
        port ( clk         : in std_logic;
               rst         : in std_logic;
               delay_ms    : in std_logic_vector (7 downto 0);
               en          : in std_logic;
               finish      : out std_logic);
    end component;

    type states is (-- inside states --
                    SetSPI, WaitSPIFinish,      -- SPI����״̬
                    SetDelay, WaitDelayFinish,  -- delay��ʱ״̬
                    Transition,                 -- �л���outside state
                    -- end inside states --
                    
                    Idle, VddOn,                -- ��ʼ״̬
                    -- outside states step 1 --
                    Wait1, DispOff, ResetOn,
                    -- end outside states step 1 --
                    
                    -- outside states step 2 --
                    Wait2, ResetOff, ChargePump1, ChargePump2,
                    PreCharge1, PreCharge2, VbatOn,
                    -- end outside states step 2 --
                    
                    -- outside states step 3 --
                    Wait3, DispContrast1, DispContrast2, InvertDisp1,
                    InvertDisp2, ComConfig1, ComConfig2, DispOn,
                    -- end outside states step 3 --
                    
                    FullDisp, Done);

    signal present_state : states := Idle;
    signal after_state : states := Idle;
    
    -- ֱ��������˿ڰ󶨵��ź�
    signal temp_dc      : std_logic := '0';
    signal temp_res     : std_logic := '1';
    signal temp_vbat    : std_logic := '1';
    signal temp_vdd     : std_logic := '1';
    signal temp_fin     : std_logic := '0';

    -- ������������Ԫ���˿ڰ󶨵��ź�
    signal temp_delay_ms    : std_logic_vector (7 downto 0) := (others=>'0');
    signal temp_delay_en    : std_logic := '0';
    signal temp_delay_fin   : std_logic;
    signal temp_spi_en      : std_logic := '0';
    signal temp_sdata       : std_logic_vector (7 downto 0) := (others=>'0');
    signal temp_spi_fin     : std_logic;

begin
    spi_com : spi_ctrl port map (clk=>clk, rst=>rst,
                                 en=>temp_spi_en,
                                 sdata=>temp_sdata,
                                 sdout=>sdout,
                                 oled_sclk=>oled_sclk,
                                 finish=>temp_spi_fin);

    delay_com : delay port map (clk=>clk, rst=>rst,
                                delay_ms=>temp_delay_ms,
                                en=>temp_delay_en,
                                finish=>temp_delay_fin);
    -- ������˿ڰ�
    oled_dc <= temp_dc;
    oled_res <= temp_res;
    oled_vbat <= temp_vbat;
    oled_vdd <= temp_vdd;
    finish <= temp_fin;

    -- ���״̬step2 ��ɺ��ӳ�100ms������ÿ�����״̬�ӳ�1ms
    temp_delay_ms <= "01100100" when after_state = DispContrast1 else -- 100ms
                     "00000001"; -- 1ms
    -- ������״̬��
    process (rst, clk)
    begin
        if (rst='1') then
            present_state <= Idle;
            temp_res <= '0';
        elsif rising_edge(clk) then
            temp_res <= '1';
            case present_state is
            when Idle =>
                if en = '1' then
                    temp_dc <= '0';
                    present_state <= VddOn;
                end if;
            
            -- initialization sequence --
            -- ��ʼ�����У�ÿ��ʼOLED��ʾ��Ӧִ��
            when VddOn =>
                temp_vdd <= '0';
                present_state <= Wait1;
            when Wait1 =>
                after_state <= DispOff;
                present_state <= SetDelay;
            when DispOff =>
                temp_sdata <= "10101110"; -- 0xAE
                after_state <= ResetOn;
                present_state <= SetSPI;
            when ResetOn =>
                temp_res <= '0';
                present_state <= Wait2;
            when Wait2 =>
                after_state <= ResetOff;
                present_state <= SetDelay;
            when ResetOff =>
                temp_res <= '1';
                after_state <= ChargePump1;
                present_state <= SetDelay;
            when ChargePump1 =>
                temp_sdata <= "10001101"; -- 0x8D
                after_state <= ChargePump2;
                present_state <= SetSPI;
            when ChargePump2 =>
                temp_sdata <= "00010100"; -- 0x14
                after_state <= PreCharge1;
                present_state <= SetSPI;
            when PreCharge1  =>
                temp_sdata <= "11011001"; -- 0xD9
                after_state <= PreCharge2;
                present_state <= SetSPI;
            when PreCharge2 =>
                temp_sdata <= "11110001"; -- 0xF1
                after_state <= VbatOn;
                present_state <= SetSPI;
            when VbatOn =>
                temp_vbat <= '0';
                present_state <= Wait3;
            when Wait3 =>
                after_state <= DispContrast1;
                present_state <= SetDelay;
            when DispContrast1=>
                temp_sdata <= "10000001"; -- 0x81
                after_state <= DispContrast2;
                present_state <= SetSPI;
            when DispContrast2=>
                temp_sdata <= "00001111"; -- 0x0F
                after_state <= InvertDisp1;
                present_state <= SetSPI;
            when InvertDisp1 =>
                temp_sdata <= "10100000"; -- 0xA0
                after_state <= InvertDisp2;
                present_state <= SetSPI;
            when InvertDisp2 =>
                temp_sdata <= "11000000"; -- 0xC0
                after_state <= ComConfig1;
                present_state <= SetSPI;
            when ComConfig1 =>
                temp_sdata <= "11011010"; -- 0xDA
                after_state <= ComConfig2;
                present_state <= SetSPI;
            when ComConfig2 =>
                temp_sdata <= "00000000"; -- 0x00
                after_state <= DispOn;
                present_state <= SetSPI;
            when DispOn =>
                temp_sdata <= "10101111"; -- 0xAF
                after_state <= Done;
                present_state <= SetSPI;
            -- end initialization sequence --

            -- FullDisp״̬����debug������������Ļ���������в����ܵ���״̬
            when FullDisp =>
                temp_sdata <= "10100101"; -- 0xA5
                after_state <= Done;
                present_state <= SetSPI;

            -- ��ɳ�ʼ��
            when Done =>
                if en = '0' then
                    temp_fin <= '0';
                    present_state <= Idle;
                else
                    temp_fin <= '1';
                end if;
                
            ---- inside:ÿִ��һ��after_state�ֻ��ܻ�������ִ���ڲ�״̬ ----
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
            ---- end inside ----
            
            when others =>
                present_state <= Idle;
            end case;
        end if;
    end process;

end Behavioral;

