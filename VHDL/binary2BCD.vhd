library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


entity binary2BCD is
    generic ( WIDTH : integer := 8   -- 8 bit binary to BCD
           );
    port (
        reset     : in  std_logic;
        binary_in : in  std_logic_vector(WIDTH-1 downto 0);  -- binary input width
        BCD_out   : out std_logic_vector(9 downto 0)        -- BCD output, 10 bits [2|4|4] to display a 3 digit BCD value when input has length 8
   
    );

end binary2BCD;

architecture structural of binary2BCD is

signal input_1   :  std_logic_vector(3 downto 0);
signal input_2   :  std_logic_vector(3 downto 0);
signal input_3   :  std_logic_vector(3 downto 0);
signal input_4   :  std_logic_vector(3 downto 0);
signal input_5   :  std_logic_vector(3 downto 0);
signal input_6   :  std_logic_vector(3 downto 0);
signal input_7   :  std_logic_vector(3 downto 0);



 
signal out_1   :  std_logic_vector(3 downto 0);
signal out_2   :  std_logic_vector(3 downto 0);
signal out_3   :  std_logic_vector(3 downto 0);
signal out_4   :  std_logic_vector(3 downto 0);
signal out_5   :  std_logic_vector(3 downto 0);
signal out_6   :  std_logic_vector(3 downto 0);
signal out_7   :  std_logic_vector(3 downto 0);
  
component Shift_Add_3 is
   port ( input       :in  std_logic_vector(3 downto 0);
          output      :out std_logic_vector(3 downto 0)
        );
end component;
 
begin

Shift_ADD3_1: Shift_Add_3
 port map
 ( input =>input_1 ,
   output =>out_1
  );

Shift_ADD3_2: Shift_Add_3
   port map
   ( input =>input_2 ,
     output =>out_2
    );
    
Shift_ADD3_3: Shift_Add_3
       port map
       ( input => input_3,
         output =>out_3
        );
 Shift_ADD3_4: Shift_Add_3
   port map
   ( input =>input_4 ,
     output =>out_4
    );
       
 Shift_ADD3_5: Shift_Add_3
  port map
  ( input =>input_5, 
    output =>out_5
   );
Shift_ADD3_6: Shift_Add_3
    port map
    ( input =>input_6  ,
    output =>out_6
    );                               
Shift_ADD3_7: Shift_Add_3
    port map
    ( input =>input_7  ,
     output =>out_7
     );                               


Set_BCD_output:process(reset,binary_in,out_1,out_2,out_3,out_4,out_5,out_6,out_7)
begin
if(reset='1') then
    BCD_out<= (others => '0');
else
BCD_out(0)<=binary_in(0);
BCD_out(1)<=out_5(0);
BCD_out(2)<=out_5(1);
BCD_out(3)<=out_5(2);
BCD_out(4)<=out_5(3);
BCD_out(5)<=out_7(0);
BCD_out(6)<=out_7(1);
BCD_out(7)<=out_7(2);
BCD_out(8)<=out_7(3);
BCD_out(9)<=out_6(3);
end if;
end process;

Set_shift_Add3_modules_inputs:process(reset,binary_in,out_1,out_2,out_3,out_4,out_5,out_6,out_7)
begin
if(reset='1') then
    input_1<= (others => '0');
    input_2<= (others => '0');
    input_3<= (others => '0');
    input_4<= (others => '0');
    input_5<= (others => '0');
    input_6<= (others => '0');
    input_7<= (others => '0');
else
    input_1<='0' & binary_in(7 downto 5);
    input_2<=out_1(2 downto 0) & binary_in(4);
    input_3<=out_2(2 downto 0) & binary_in(3);
    input_4<=out_3(2 downto 0) & binary_in(2);
    input_5<=out_4(2 downto 0) & binary_in(1);
    input_6<= '0' & out_1(3) & out_2(3) & out_3(3);
    input_7<=out_6(2 downto 0) & out_4(3);
    
end if;
end process;




end structural;
