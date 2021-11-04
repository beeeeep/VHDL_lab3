library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
---use work.tb_pkg.all;

entity tb_ALU is
end tb_ALU;


architecture structural of tb_ALU is

   component ALU
   port (
             A          : in  std_logic_vector(7 downto 0);
          B          : in  std_logic_vector(7 downto 0);
          FN         : in  std_logic_vector(3 downto 0);
          result     : out std_logic_vector(7 downto 0);
          overflow   : out std_logic;
          sign       : out std_logic
        );
   end component;
component ALU_top
  port (
          clk        : in  std_logic;
         reset      : in  std_logic;
         b_Enter    : in  std_logic;
         b_Sign     : in  std_logic;
         input      : in  std_logic_vector(7 downto 0);
         seven_seg  : out std_logic_vector(6 downto 0);
         anode      : out std_logic_vector(3 downto 0);
         led       : out std_logic_vector(7 downto 0)
       );
end component;


   signal A          : std_logic_vector(7 downto 0);
   signal B          : std_logic_vector(7 downto 0);
   signal FN         : std_logic_vector(3 downto 0);
   signal sign       : std_logic;
   signal enter      : std_logic;
   signal overflow      : std_logic;
   signal start_kb_clk, kb_clk_to_dut : std_logic := '0'; 
   signal tb_seg_en	  : std_logic_vector(3 downto 0);
   signal tb_clk, clk : std_logic := '0';
   constant period   : time := 2500 ns;
   signal start_tb : std_logic := '0'; 
   signal tb_rst, sys_rst : std_logic := '0'; 
   signal seven_seg_num:  std_logic_vector(6 downto 0); 
   signal test_nubmer         : std_logic_vector(7 downto 0);    
    signal led_out  :     std_logic_vector(7 downto 0); 
    
begin  -- structural
   
--   ALU_inst: ALU
--   port map (  

--              A         => A,
--              B         => B,
--              FN        => FN,
--              result    => test_nubmer,
--              sign      => sign,
--              overflow  => overflow
--            );

    ALU_top_inst: ALU_top
        port map (
            clk=>clk,
            reset=>sys_rst,
            b_Enter=>enter,
            b_Sign=>sign,
            input=>A,
            seven_seg=>seven_seg_num,
            anode=>tb_seg_en,
            led=>led_out
        );








 -- 2 MHz sys clock generated in testbench,
          -- kb_clk is made faster 500kHz, in fpga it wil be around 30KHz
          -- feel free to change, however shouldnt matter in simulations !! 
          clk <= not(clk) after 500 ns;
          -- adding delay to emulate latency 
          sys_rst <= '1', '0' after 2300 ns;
          tb_clk <= clk;
          tb_rst <= sys_rst;
          start_tb <= '1' after 2700 ns;










sign <= '0',                    -- B = 3
'1' after 1 * period,   -- B = 3   
'0' after 2 * period,   -- B = 145 
'1' after 3 * period,   -- B = 124 
'0' after 38 * period,   -- B = 249 
'0' after 85 * period,   -- B = 105 
'1' after 40 * period,   -- B = 124 
'0' after 42 * period,   -- B = 249 
'0' after 46 * period;   -- B = 105 


enter <= '1',                    -- B = 3
'1' after 1 * period,   -- B = 3
'0' after 2 * period,   -- B = 145
'1' after 3 * period,   -- B = 124
'0' after 4 * period,   -- B = 249
'1' after 5 * period,   -- B = 10
'1' after 6 * period,   -- B = 124
'0' after 7 * period,   -- B = 249
'1' after 8 * period,   -- B = 10
'1' after 9 * period,   -- B = 124
'0' after 10 * period,   -- B = 249
'1' after 11 * period,   -- B = 10
'1' after 12 * period,   -- B = 124
'0' after 13 * period,   -- B = 249
'1' after 14 * period,   -- B = 10
'1' after 15 * period,   -- B = 124
'0' after 16 * period,   -- B = 249
'1' after 17 * period,   -- B = 10
'1' after 18 * period,   -- B = 124
'0' after 19 * period,   -- B = 249
'1' after 20 * period,   -- B = 10
'1' after 21 * period,   -- B = 124
'0' after 22 * period,   -- B = 249
'1' after 23 * period,   -- B = 10
'1' after 24 * period,   -- B = 124
'0' after 25 * period,   -- B = 249
'1' after 26 * period, -- B = 10
'1' after 30 * period,   -- B = 10
'1' after 40 * period,   -- B = 124
'0' after 50 * period,   -- B = 249
'1' after 60 * period,   -- B = 10
'0' after 70 * period,   -- B = 249
'1' after 80 * period,   -- B = 10
'0' after 90 * period,   -- B = 249
'1' after 100 * period,   -- B = 10
'0' after 110 * period,   -- B = 249
'1' after 120 * period,   -- B = 10
'0' after 130 * period,   -- B = 249
'1' after 140 * period,   -- B = 10
'0' after 150 * period,   -- B = 249
'1' after 160 * period;   -- B = 10
   -- User test data pattern
   -- *************************
   
   A <= "10000011";                   -- A = 5
--        "00001001" after 1 * period,   -- A = 9
--        "00010001" after 2 * period,   -- A = 17
--        "10010001" after 3 * period,   -- A = 145
--        "10010100" after 4 * period,   -- A = 148
--        "11010101" after 5 * period,   -- A = 213
--        "00100011" after 6 * period,   -- A = 35
--        "11110010" after 7 * period,   -- A = 242
--        "00110001" after 8 * period,   -- A = 49
--        "01010101" after 9 * period;   -- A = 85
  
   B <= "00000111";                   -- B = 3
--        "00000011" after 1 * period,   -- B = 3
--        "10010001" after 2 * period,   -- B = 145
--        "01111100" after 3 * period,   -- B = 124
--        "11111001" after 4 * period,   -- B = 249
--        "01101001" after 5 * period,   -- B = 105
--        "01100011" after 6 * period,   -- B = 35
--        "01101000" after 7 * period,   -- B = 104
--        "00101101" after 8 * period,   -- B = 45
--        "00100100" after 9 * period;   -- B = 36
     
--   FN <= "0000",                              -- Pass A
--         "0001" after 4 * period,                                     -- Pass A   
--         "0010" after 6 * period,             -- Pass B
--         "0011" after 7 * period,             -- Pass A
--         "0100" after 8 * period,             -- Pass B
--         "1100" after 10 * period,             -- Pass unsigned A + B
--         "1010" after 14 * period,             -- Pass unsigned A - B  
--         "1011" after 16 * period,             -- Pass unsigned A - B
--         "1100" after 18 * period,             -- Pass unsigned A + B
--         "1100" after 20 * period,             -- Pass unsigned A - B
--         "1100" after 22 * period,             -- Pass unsigned max(A, B)
--         "1100" after 24 * period,            -- Pass signed A + B
--         "1100" after 26 * period,            -- Pass signed A - B
--         "1100" after 28 * period,            -- Pass signed max(A, B)
--         "1111" after 30 * period;            -- Invalid input command

end structural;
