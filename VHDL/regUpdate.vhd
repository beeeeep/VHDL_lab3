library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


 -- 2 registers, 8bit buffer (Reg_A), 8bit buffer (Reg_B)  Total: 16bits

entity regUpdate is
   port ( clk        : in  std_logic;
          reset      : in  std_logic;
          RegCtrl    : in  std_logic_vector (1 downto 0);   -- Register update control from ALU controller
          input      : in  std_logic_vector (7 downto 0);   -- Switch inputs
          A          : out std_logic_vector (7 downto 0);   -- Input A
          B          : out std_logic_vector (7 downto 0)   -- Input B
        );
end regUpdate;

architecture behavioral of regUpdate is

signal next_Reg_A,Reg_A:std_logic_vector (7 downto 0);
signal next_Reg_B,Reg_B:std_logic_vector (7 downto 0);

begin

sequential:process(clk,reset,next_Reg_A,next_Reg_B)
   begin
   if reset = '1' then
       Reg_A<="00000000";
       Reg_B<="00000000";
   elsif rising_edge(clk) then
       Reg_A<=next_Reg_A;
       Reg_B<=next_Reg_B;
   end if;
   end process;
   
   A<=Reg_A;
   B<=Reg_B;
   

combinatorial: process(Reg_B,Reg_A,RegCtrl,input)
   begin
   if RegCtrl = "01" then --If the controllers signals to load A
       next_Reg_A<=input;
   else 
       next_Reg_A<=Reg_A;
   end if;
   
   if RegCtrl = "10" then --If the controllers signals to load B
       next_Reg_B<=input;
   else 
       next_Reg_B<=Reg_B;
   end if;
   end process;

   
end behavioral;