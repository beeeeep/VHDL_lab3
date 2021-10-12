library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.ALU_components_pack.all;


entity ALU_top is
   port ( clk        : in  std_logic;
          reset      : in  std_logic;
          b_Enter    : in  std_logic;
          b_Sign     : in  std_logic;
          input      : in  std_logic_vector(7 downto 0);
          seven_seg  : out std_logic_vector(6 downto 0);
          anode      : out std_logic_vector(3 downto 0)
        );
end ALU_top;

architecture structural of ALU_top is

   -- SIGNAL DEFINITIONS
   signal Enter : std_logic;
   signal BCD_digit_buffer : std_logic_vector(9 downto 0);  
   
component regUpdate is
      port ( 
      clk        : in  std_logic;
      reset      : in  std_logic;
      RegCtrl    : in  std_logic_vector (1 downto 0);   -- Register update control from ALU controller
      input      : in  std_logic_vector (7 downto 0);   -- Switch inputs
      A          : out std_logic_vector (7 downto 0);   -- Input A
      B          : out std_logic_vector (7 downto 0)   -- Input B
       );
 end component;

component binary2BCD is
          generic ( WIDTH : integer := 8   -- 8 bit binary to BCD
           );   
          port (
                 clk       : in  std_logic;
                 reset     : in  std_logic;
                 binary_in : in  std_logic_vector(WIDTH-1 downto 0);  -- binary input width
                 BCD_out   : out std_logic_vector(9 downto 0)        -- BCD output, 10 bits [2|4|4] to display a 3 digit BCD value when input has length 8
               );
end component;

component seven_seg_driver is
      port ( clk           : in  std_logic;
             reset         : in  std_logic;
             BCD_digit     : in  std_logic_vector(9 downto 0);          
             sign          : in  std_logic;
             overflow      : in  std_logic;
             DIGIT_ANODE   : out std_logic_vector(3 downto 0);
             SEGMENT       : out std_logic_vector(6 downto 0)
           );
end component;

begin

seven_seg_driver_inst : seven_seg_driver 
      port map 
    ( 
      clk => clk,
      reset => reset,
      BCD_digit => BCD_digit_buffer,
      sign     => '1',
      overflow    => '1',
      DIGIT_ANODE    => anode,
      SEGMENT => seven_seg
    );

  binary2BCD_inst : binary2BCD
  port map 
 (
       clk => clk,
       reset => reset,
       binary_in => "11001111",
       BCD_out => BCD_digit_buffer
  );

-- regUpdate_isnt: regUpdate 
--            port ( 
--            clk  => clk,       
--            reset  => reset,    
--            RegCtrl    
--            input     
--            A          
--            B        
--             );

 
 
   ---- to provide a clean signal out of a bouncy one coming from the push button
   ---- input(b_Enter) comes from the pushbutton; output(Enter) goes to the FSM 
   --debouncer1: debouncer
   --port map ( clk          => clk,
   --           reset        => reset,
   --           button_in    => b_Enter,
   --           button_out   => Enter
   --         );

   -- ****************************
   -- DEVELOPE THE STRUCTURE OF ALU_TOP HERE
   -- ****************************

end structural;
