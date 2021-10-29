library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity seven_seg_driver is
    port ( clk           : in  std_logic;
         reset         : in  std_logic;
         BCD_digit     : in  std_logic_vector(9 downto 0);
         sign          : in  std_logic;
         overflow      : in  std_logic;
         DIGIT_ANODE   : out std_logic_vector(3 downto 0);
         SEGMENT       : out std_logic_vector(7 downto 0)
        );
end seven_seg_driver;

-- 6 registers, 4 (8bit)buffer, 1 (10bit) counter,1 (2it)index_counter. Total: 20bits

architecture behavioral of seven_seg_driver is

    signal Seg_reg_0,Seg_reg_1,Seg_reg_2,Seg_reg_3:  std_logic_vector(7 downto 0);
    signal index,index_next:unsigned(1 downto 0);
    signal counter_delay,counter_delay_next:unsigned(9 downto 0);
begin

    --/*******************************************************
    --/
    --/       Binary to 7 Segment transformations
    --/ 
    --/*******************************************************

    Bin_to_Seg_3: process(BCD_digit)
    begin
        case BCD_digit(3 downto 0) is
            when "0000" =>
                Seg_reg_3 <= "11000000";
            when "0001" =>
                Seg_reg_3 <= "11111001";
            when "0010" =>
                Seg_reg_3 <= "10100100";
            when "0011" =>
                Seg_reg_3 <= "10110000";
            when "0100" =>
                Seg_reg_3 <= "10011001";
            when "0101" =>
                Seg_reg_3 <= "10010010";
            when "0110" =>
                Seg_reg_3 <= "10000010";
            when "0111" =>
                Seg_reg_3 <= "11111000";
            when "1000" =>
                Seg_reg_3 <= "10000000";
            when "1001" =>
                Seg_reg_3 <= "10011000";
            when "1111" =>
                Seg_reg_3 <= "00000000";  --clear the display 
            when others =>
                Seg_reg_3 <= "10000110";
        end case;
    end process;

    Bin_to_Seg_2: process(BCD_digit)
    begin
        case BCD_digit(7 downto 4) is
            when "0000" =>
                Seg_reg_2 <= "11000000";
            when "0001" =>
                Seg_reg_2 <= "11111001";
            when "0010" =>
                Seg_reg_2 <= "10100100";
            when "0011" =>
                Seg_reg_2 <= "10110000";
            when "0100" =>
                Seg_reg_2 <= "10011001";
            when "0101" =>
                Seg_reg_2 <= "10010010";
            when "0110" =>
                Seg_reg_2 <= "10000010";
            when "0111" =>
                Seg_reg_2 <= "11111000";
            when "1000" =>
                Seg_reg_2 <= "10000000";
            when "1001" =>
                Seg_reg_2 <= "10011000";
            when "1111" =>
                Seg_reg_2 <= "00000000";  --clear the display 
            when others =>
                Seg_reg_2 <= "10000110";
        end case;
    end process;

    Bin_to_Seg_1: process(BCD_digit)
    begin
        case BCD_digit(9 downto 8) is
            when "00" =>
                Seg_reg_1 <= "11000000";
            when "01" =>
                Seg_reg_1 <= "11111001";
            when "10" =>
                Seg_reg_1 <= "10100100";
            when "11" =>
                Seg_reg_1 <= "10110000";
            when others =>
                Seg_reg_1 <= "10000110";
        end case;
    end process;

    Sign_to_Seg_0:process(sign)
    begin
        if(sign='1') then
            Seg_reg_0<="01000000";
        else
            Seg_reg_0<="11111111";
        end if;
    end process;

    --/*******************************************************
    --/
    --/      7 Segment driver processes
    --/ 
    --/*******************************************************
    Segment_scan_delay:   process(clk,reset,counter_delay,index)
    begin
        if rising_edge(clk)then
            if(reset='1') then
                counter_delay_next<="0000000000";
                counter_delay<="0000000000";
            else
                counter_delay<=counter_delay_next;
            end if;
        end if;
        counter_delay_next<=counter_delay+1;
        if( counter_delay="1111111111") then
            index_next <= index + 1;
        else
            index_next<=index;
        end if;
    end process;

    Seg_driver: process(reset,overflow,index,Seg_reg_0,Seg_reg_1,Seg_reg_2,Seg_reg_3) -- scans each 7-seg display with a shift register, changes the code to display, according to the register enabled
    begin
       if(reset='1') then -- if overflow is detected, show dashes to all segments
         DIGIT_ANODE <= "0000";
         SEGMENT <= "00000000";
    
        elsif(overflow='1') then -- if overflow is detected, show dashes to all segments
            DIGIT_ANODE <= "0000";
            SEGMENT <= "01000000";
        else
            case index is
                when "00" =>
                    if Seg_reg_0 = "00000000" then
                        DIGIT_ANODE <= "1111";
                        SEGMENT<="11111111";
                        
                    else
                        DIGIT_ANODE <= "1110";
                        SEGMENT <= Seg_reg_0;
                    end if;
                when "01" =>
                    if Seg_reg_1 = "00000000" then
                        DIGIT_ANODE <= "1111";
                        SEGMENT<="11111111";
                    else
                        DIGIT_ANODE <= "1101";
                        SEGMENT <= Seg_reg_1;

                    end if;
                when "10" =>
                    if Seg_reg_2 = "00000000" then
                        DIGIT_ANODE <= "1111";
                        SEGMENT<="11111111";
                    else
                        DIGIT_ANODE <= "1011";
                        SEGMENT <= Seg_reg_2;
                    end if;
                when "11" =>
                    if Seg_reg_3 = "00000000" then
                        DIGIT_ANODE <= "1111";
                        SEGMENT<="11111111";
                    else
                        DIGIT_ANODE <= "0111";
                        SEGMENT <= Seg_reg_3;
                    end if;
                when others =>
                    DIGIT_ANODE <= "1111";
                    SEGMENT<="11111111";
            end case;
        end if;
    end process;
end behavioral;
