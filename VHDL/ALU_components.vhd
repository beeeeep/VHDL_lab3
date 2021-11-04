library ieee;
use ieee.std_logic_1164.all;

package ALU_components_pack is

   -- Button debouncing 
   component debouncer   
   port ( clk        : in  std_logic;
          reset      : in  std_logic;
          button_in  : in  std_logic;
          button_out : out std_logic
        );
   end component;
   
   -- D-flipflop
   component dff
   generic ( W : integer );
   port ( clk     : in  std_logic;
          reset   : in  std_logic;
          d       : in  std_logic_vector(W-1 downto 0);
          q       : out std_logic_vector(W-1 downto 0)
        );
   end component;
   
  -- Shift_Add_3 (for Bin to BCD) 
    component Shift_Add_3   
    port ( input       :in  std_logic_vector(3 downto 0);
           output      :out  std_logic_vector(3 downto 0)
         );
    end component;   
   
   
 
    signal mod_step1 : std_logic_vector(7 downto 0);
   
   -- ADD MORE COMPONENTS HERE IF NEEDED 
   
end ALU_components_pack;

-------------------------------------------------------------------------------
-- ALU component pack body
-------------------------------------------------------------------------------
package body ALU_components_pack is

end ALU_components_pack;

-------------------------------------------------------------------------------
-- debouncer component: There is no need to use this component, thogh if you get 
--                      unwanted moving between states of the FSM because of pressing
--                      push-button this component might be useful.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debouncer is
   port ( clk        : in  std_logic;
          reset      : in  std_logic;
          button_in  : in  std_logic;
          button_out : out std_logic
        );
end debouncer;

architecture behavioral of debouncer is

   signal count      : unsigned(23 downto 0);  -- Range to count 20ms with 50 MHz clock
   signal count_next      : unsigned(23 downto 0);  -- Range to count 20ms with 50 MHz clock
   signal button_tmp : std_logic;
   signal last_button: std_logic;

begin

process ( clk )
begin
   if clk'event and clk = '1' then
      if reset = '1' then
         count <= (others => '0');
         button_out<='0';
      else    
         button_out<= button_tmp;          
         count<=count_next;     
         last_button<=button_in;
         end if;
      end if;
end process;


process(button_in,count,last_button)
begin
    
    if (count=0 and last_button='0' and button_in='1') then -- if the delay has passed (count=0), and there is a rising edge on button
         button_tmp <='1';    
         count_next <= (others => '1');   --set the delay counter
    elsif(count>to_unsigned(0,count'length)) then  --count delay time
        count_next<=count-1;
        button_tmp<='0';
    else
       button_tmp<='0'; 
       count_next<=count;
    end if;                       
end process;



end behavioral;

------------------------------------------------------------------------------
-- component dff - D-FlipFlop 
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity dff is
   generic ( W : integer
           );
   port ( clk     : in  std_logic;
          reset   : in  std_logic;
          d       : in  std_logic_vector(W-1 downto 0);
          q       : out std_logic_vector(W-1 downto 0)
        );
end dff;

architecture behavioral of dff is

begin

   process ( clk )
   begin
      if clk'event and clk = '1' then
         if reset = '1' then
            q <= (others => '0');
         else
            q <= d;
         end if;
      end if;
   end process;              

end behavioral;

------------------------------------------------------------------------------
-- component Shift_Add_3 
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity Shift_Add_3 is
   port ( input       :in  std_logic_vector(3 downto 0);
          output      :out std_logic_vector(3 downto 0)
        );
end Shift_Add_3;

architecture behavioral of Shift_Add_3 is


begin

   process (input)
   begin
   if(input>="0101") then
     output(3 downto 0) <= std_logic_vector(unsigned(input(3 downto 0))+"0011") ;
   else
    output(3 downto 0) <=  input(3 downto 0);
   end if;  
   end process;              

end behavioral;

------------------------------------------------------------------------------
-- BEHAVORIAL OF THE ADDED COMPONENETS HERE
-------------------------------------------------------------------------------
