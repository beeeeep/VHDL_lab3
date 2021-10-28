library ieee;
use ieee.std_logic_1164.all;

library work;
use work.ALU_components_pack.all;

entity ALU_top is
   port ( clk        : in  std_logic;
          reset      : in  std_logic;
          b_Enter    : in  std_logic;
          b_Sign     : in  std_logic;
          input      : in  std_logic_vector(7 downto 0);
          seven_seg  : out std_logic_vector(7 downto 0);
          anode      : out std_logic_vector(3 downto 0)
        );
end ALU_top;

architecture structural of ALU_top is

   -- SIGNAL DEFINITIONS
   component ALU_ctrl is
	   port (
		     clk     : in  std_logic;
             reset   : in  std_logic;
             enter   : in  std_logic;
             sign    : in  std_logic;
             FN      : out std_logic_vector (3 downto 0);   -- ALU functions
             RegCtrl : out std_logic_vector (1 downto 0)   -- Register update control bits
	          );
    end component;
    
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

component ALU is
   port (
      --    clk       : in  std_logic;
      --    reset     : in  std_logic;  
          A          : in  std_logic_vector (7 downto 0);   -- Input A
          B          : in  std_logic_vector (7 downto 0);   -- Input B
          FN         : in  std_logic_vector (3 downto 0);   -- ALU functions provided by the ALU_Controller (see the lab manual)
          result 	 : out std_logic_vector (7 downto 0);   -- ALU output (unsigned binary)
	      overflow   : out std_logic;                       -- '1' if overflow ocurres, '0' otherwise 
	      sign       : out std_logic                        -- '1' if the result is a negative value, '0' otherwise
        );
end component;

component seven_seg_driver is
   port ( clk           : in  std_logic;
          reset         : in  std_logic;
          BCD_digit     : in  std_logic_vector(9 downto 0);          
          sign          : in  std_logic;
          overflow      : in  std_logic;
          DIGIT_ANODE   : out std_logic_vector(3 downto 0);
          SEGMENT       : out std_logic_vector(7 downto 0)
        );
end component;

component binary2BCD is
   generic ( WIDTH : integer := 8   -- 8 bit binary to BCD
           );
   port ( 
          clk       : in  std_logic;
          reset     : in  std_logic;
          binary_in : in  std_logic_vector(7 downto 0);  -- binary input width
          BCD_out   : out std_logic_vector(9 downto 0)        -- BCD output, 10 bits [2|4|4] to display a 3 digit BCD value when input has length 8
        );
end component;

    signal Enter : std_logic;
    signal FN    : std_logic_vector (3 downto 0);   -- ALU functions
    signal RegCtrl : std_logic_vector (1 downto 0);
    signal A : std_logic_vector (7 downto 0);   -- Input A
    signal B : std_logic_vector (7 downto 0);
    signal result : std_logic_vector (7 downto 0);    
	signal overflow : std_logic;                       -- '1' if overflow ocurres, '0' otherwise 
	signal sign : std_logic;         
    signal DIGIT_ANODE : std_logic_vector(3 downto 0);
    signal SEGMENT : std_logic_vector(7 downto 0);
    signal BCD_out  :std_logic_vector(9 downto 0);
begin
    ALU_ctrl_inst : ALU_ctrl
    port map (
		    clk     => clk,
            reset   => reset,
            enter   => b_Enter,
            sign   => b_Sign,
            FN      => FN,
            RegCtrl =>RegCtrl
	     );
	     
	      regUpdate_inst : regUpdate
    port map (
		    clk     => clk,
            reset   => reset,
            RegCtrl => RegCtrl,
            input   => input,
            A       => A,  
            B       => B
	     );
	     
	     ALU_inst : ALU
    port map (
          -- clk     => clk,
          --  reset   => reset,
            A       => A,  
            B       => B,
            result  => result,
            FN      => FN,
            overflow=> overflow,
            sign    => sign
	     );
	     
	     binary2BCD_inst : binary2BCD
    port map (
			clk => clk,
			reset => reset,
			binary_in => result,
            BCD_out   => BCD_out
	     );
	     
	     seven_seg_driver_inst : seven_seg_driver
    port map (
          clk         => clk,
          reset       => reset,
          BCD_digit   => BCD_out,     
          sign        => sign,
          overflow    => overflow, 
          DIGIT_ANODE => anode,
          SEGMENT     => seven_seg
	     );

end structural;