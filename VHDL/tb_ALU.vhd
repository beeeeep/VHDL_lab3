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
          clk        : in  std_logic;
           reset      : in  std_logic;
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
         anode      : out std_logic_vector(3 downto 0)
       );
end component;


   signal A          : std_logic_vector(7 downto 0);
   signal B          : std_logic_vector(7 downto 0);
   signal FN         : std_logic_vector(3 downto 0);
   signal result     : std_logic_vector(7 downto 0);
   signal overflow   : std_logic;
   signal sign       : std_logic;
   signal start_kb_clk, kb_clk_to_dut : std_logic := '0'; 
   signal tb_seg_en	  : std_logic_vector(3 downto 0);
   signal tb_clk, clk : std_logic := '0';
   constant period   : time := 2500 ns;
   signal start_tb : std_logic := '0'; 
   signal tb_rst, sys_rst : std_logic := '0'; 
   signal seven_seg_num:  std_logic_vector(6 downto 0); 

    
begin  -- structural
   
   ALU_inst: ALU
   port map (  
            clk     => clk,
              reset   => sys_rst,
                A         => A,
              B         => B,
              FN        => FN,
              result    => result,
              sign      => sign,
              overflow  => overflow
            );

--    ALU_top_inst: ALU_top
--        port map (
--            clk=>clk,
--            reset=>sys_rst,
--            b_Enter=>'0',
--            b_Sign=>'0',
--            input=>"00011010",
--            seven_seg=>seven_seg_num,
--            anode=>tb_seg_en
--        );








 -- 2 MHz sys clock generated in testbench,
          -- kb_clk is made faster 500kHz, in fpga it wil be around 30KHz
          -- feel free to change, however shouldnt matter in simulations !! 
          clk <= not(clk) after 500 ns;
          -- adding delay to emulate latency 
          sys_rst <= '1', '0' after 2300 ns;
          tb_clk <= clk;
          tb_rst <= sys_rst;
          start_tb <= '1' after 2700 ns;














   
   -- *************************
   -- User test data pattern
   -- *************************
   
   A <= "00000101",                    -- A = 5
        "00001001" after 1 * period,   -- A = 9
        "00010001" after 2 * period,   -- A = 17
        "10010001" after 3 * period,   -- A = 145
        "10010100" after 4 * period,   -- A = 148
        "11010101" after 5 * period,   -- A = 213
        "00100011" after 6 * period,   -- A = 35
        "11110010" after 7 * period,   -- A = 242
        "00110001" after 8 * period,   -- A = 49
        "01010101" after 9 * period;   -- A = 85
  
   B <= "00000011",                    -- B = 3
        "00000011" after 1 * period,   -- B = 3
        "10010001" after 2 * period,   -- B = 145
        "01111100" after 3 * period,   -- B = 124
        "11111001" after 4 * period,   -- B = 249
        "01101001" after 5 * period,   -- B = 105
        "01100011" after 6 * period,   -- B = 35
        "01101000" after 7 * period,   -- B = 104
        "00101101" after 8 * period,   -- B = 45
        "00100100" after 9 * period;   -- B = 36
     
   FN <= "0000",                              -- Pass A
         "0001" after 1 * period,             -- Pass B
         "0000" after 2 * period,             -- Pass A
         "0001" after 3 * period,             -- Pass B
         "0100" after 4 * period,             -- Pass unsigned A + B
         "0100" after 5 * period,             -- Pass unsigned A - B  
         "0100" after 6 * period,             -- Pass unsigned A - B
         "0100" after 7 * period,             -- Pass unsigned A + B
         "0100" after 8 * period,             -- Pass unsigned A - B
         "0100" after 9 * period,             -- Pass unsigned max(A, B)
         "0100" after 10 * period,            -- Pass signed A + B
         "0100" after 11 * period,            -- Pass signed A - B
         "0100" after 12 * period,            -- Pass signed max(A, B)
         "1111" after 13 * period;            -- Invalid input command

end structural;
