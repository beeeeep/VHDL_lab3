library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


entity ALU is
   port ( A          : in  std_logic_vector (7 downto 0);   -- Input A
          B          : in  std_logic_vector (7 downto 0);   -- Input B
          FN         : in  std_logic_vector (3 downto 0);   -- ALU functions provided by the ALU_Controller (see the lab manual)
          result 	 : out std_logic_vector (7 downto 0);   -- ALU output (unsigned binary)
	      overflow   : out std_logic;                       -- '1' if overflow ocurres, '0' otherwise 
	      sign       : out std_logic                        -- '1' if the result is a negative value, '0' otherwise
        );
end ALU;

 architecture behavioral of ALU is
 
      signal regA,regB:std_logic_vector(7 downto 0);
      signal AA,BB,RR: std_logic_vector(7 downto 0);
      signal temp_A, temp_B, temp_Y : std_logic_vector (7 downto 0);
-- SIGNAL DEFINITIONS HERE IF NEEDED

begin
   process ( FN, A, B )
   begin
   case FN is
       when "0000" =>
           regA<=A;
           temp_A<=A;
       when "0001" =>
           regB<=B;
           temp_B<=B;
       when "0010" =>
           result <= regA + regB;
           temp_Y <= regA + regB;
           if((temp_A(7)='1' and temp_B(1)='1')or((temp_A(7)='1' or temp_B(1)='1')and temp_Y(7)='0')) then 
               overflow <= '1'; 
           else 
               overflow <='0'; 
	       end if;
       when "0011" =>
           result <= regA + not(regB) + 1;  
       when "0100" =>
           result (1 downto 0)<= regA(1 downto 0);
           result (7 downto 2)<="000000";
       when "1010" =>
           if(regA(7) = '1') then 
               AA<=regA xor "01111111"+1;
           else
               AA<=regA;
           end if;
           if(regB(7) = '1') then 
               BB<=regB xor "01111111"+1;
           else
               BB<=regB;
           end if;
               RR<=AA+BB;
           if(regA(7) = '0'and regB(7) = '0' and RR(7) = '1') then 
               result<= RR;
               overflow <= '1';
               sign<='0';
           elsif(regA(7) = '1'and regB(7) = '1' and RR(7) = '0') then
               result<= RR;
               overflow <= '1';
               sign<='1';
           elsif( RR(7) = '0')then
               overflow <= '0';
               sign<='0';
               result<=RR;
           else
               overflow <= '0';
               sign<='1';
               result<=RR xor "01111111"+1;
           end if;
       when "1011" =>              
          if(regA(7) = '1') then 
               AA<=regA xor "01111111"+1;
           else
               AA<=regA;
           end if;
           if(regB(7) = '1') then 
               BB<=not regB+'1';
           else
               BB<=regB;
           end if;
               RR<=AA+BB;
           if(regA(7) = '0'and regB(7) = '1' and RR(7) = '1') then 
               result<= RR;
               overflow <= '1';
               sign<='0';
           elsif(regA(7) = '1'and regB(7) = '0' and RR(7) = '0') then
               result<= RR;
               overflow <= '1';
               sign<='1';
           elsif( RR(7) = '0')then
               overflow <= '0';
               sign<='0';
               result<=RR;
           else
               overflow <= '0';
               sign<='1';
               result<=RR xor "01111111"+1;
           end if;
   when "1100" =>
       result (1 downto 0)<= regA(1 downto 0);
       result (7 downto 2)<="000000";
       if(regA(7) = '1') then 
               sign<='1';
           else
               sign<='0';
           end if;
   when others =>
        overflow <= '0';
        sign<='0';
        result<="00000000";
   end case;
   end process;

end Behavioral;