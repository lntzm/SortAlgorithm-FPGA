library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;

entity min_secmin_B is
    Port (data0, data1, data2, data3, data4, data5  :in std_logic_vector(7 downto 0);
          min, sec_min                              :out std_logic_vector(7 downto 0));
end min_secmin_B;

architecture Behavioral of min_secmin_B is
    component comparer_B is
        port(A, B   : in std_logic_vector(7 downto 0);
             tab    : out std_logic;
             q      : out std_logic_vector(7 downto 0));
    end component;
    signal tab  : std_logic_vector(4 downto 0);
    signal temp1, temp2, temp3, temp4   : std_logic_vector(7 downto 0);
    signal tem_sec0, tem_sec1, tem_sec2, tem_sec3  : std_logic_vector(7 downto 0);
begin
    --��������Ƚ����õ����������е���Сֵ
    min_dut1: comparer_B port map(A => data0, B => data1, tab => tab(0), q => temp1);
    min_dut2: comparer_B port map(A => data2, B => data3, tab => tab(1), q => temp2);
    min_dut3: comparer_B port map(A => data4, B => data5, tab => tab(2), q => temp3);
    min_dut4: comparer_B port map(A => temp1, B => temp2, tab => tab(3), q => temp4);    
    min_dut5: comparer_B port map(A => temp4, B => temp3, tab => tab(4), q => min);
    
    --�����������Сֵ�ıȽ�������ı��ֵ�õ��ض�λ�õ�����
    process(tab)
    begin
    if tab(0) = '1' and tab(3) = '1' and tab(4) = '1' then 
        tem_sec1 <= data1; tem_sec2 <= temp2; tem_sec3 <= temp3;--��СֵΪdata0
    elsif tab(0) = '0' and tab(3) = '1' and tab(4) = '1' then
        tem_sec1 <= data0; tem_sec2 <= temp2; tem_sec3 <= temp3;--��СֵΪdata1
    elsif tab(1) = '1' and tab(3) = '0' and tab(4) = '1' then
        tem_sec1 <= data3; tem_sec2 <= temp1; tem_sec3 <= temp3;--��СֵΪdata2
    elsif tab(1) = '0' and tab(3) = '0' and tab(4) = '1' then
        tem_sec1 <= data2; tem_sec2 <= temp1;tem_sec3 <= temp3;--��СֵΪdata3
    elsif tab(2) = '1' and tab(4) = '0' then
        tem_sec1 <= data5; tem_sec2 <= data5; tem_sec3 <= temp4;--��СֵΪdata4
    elsif tab(2) = '0' and tab(4) = '0' then
        tem_sec1 <= data4; tem_sec2 <= data4; tem_sec3<=temp4;--��СֵΪdata5
    end if;
    end process;
    
    --���������Ƚ������ض�λ�õ����ݽ��бȽϵõ���Сֵ
    
    --������ƺõıȽ������бȽ�
    --sec_min_dut1: comparer port map(A => tem_sec1, B => tem_sec2, q => tem_sec0);
    --sec_min_dut2: comparer port map(A => tem_sec0, B => tem_sec3, q => sec_min);
    
    --����unsigned���Դ��ıȽ������бȽ�
    tem_sec0 <= tem_sec1 when tem_sec1 < tem_sec2 else tem_sec2;
    sec_min <= tem_sec0 when tem_sec0 < tem_sec3 else tem_sec3;
    
end Behavioral;
