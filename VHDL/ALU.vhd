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
      signal mod_step1 : std_logic_vector(7 downto 0);
      signal mod_step2 : std_logic_vector(7 downto 0);
      signal mod_step3 : std_logic_vector(7 downto 0);
      signal mod_step4 : std_logic_vector(7 downto 0);
      signal mod_step5 : std_logic_vector(7 downto 0);
      signal mod_step6 : std_logic_vector(7 downto 0);
      signal mod_step7 : std_logic_vector(7 downto 0);
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
                 if regA >= 192 then
       mod_step1 <=regA-192;
       else mod_step1 <=regA;
       end if;
       if mod_step1 >= 96 then
       mod_step2 <=mod_step1-96;
       else mod_step2 <=mod_step1;
       end if;
       if mod_step2 >= 48 then
       mod_step3 <=mod_step2-48;
       else mod_step3 <=mod_step2;
       end if;
       if mod_step3 >= 24 then
       mod_step4 <=mod_step3-24;
       else mod_step4 <=mod_step3;
       end if;
       if mod_step4 >= 12 then
       mod_step5 <=mod_step4-12;
       else mod_step5 <=mod_step4;
       end if;
       if mod_step5 >= 6 then
       mod_step6 <=mod_step5-6;
       else mod_step6 <=mod_step5;
       end if;
       if mod_step6 >= 6 then
       mod_step7 <=mod_step6-3;
       else mod_step7 <=mod_step6;
       end if;
       result <= mod_step7;
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
      if regA >= 192 then
       mod_step1 <=regA-192;
       else mod_step1 <=regA;
       end if;
       if mod_step1 >= 96 then
       mod_step2 <=mod_step1-96;
       else mod_step2 <=mod_step1;
       end if;
       if mod_step2 >= 48 then
       mod_step3 <=mod_step2-48;
       else mod_step3 <=mod_step2;
       end if;
       if mod_step3 >= 24 then
       mod_step4 <=mod_step3-24;
       else mod_step4 <=mod_step3;
       end if;
       if mod_step4 >= 12 then
       mod_step5 <=mod_step4-12;
       else mod_step5 <=mod_step4;
       end if;
       if mod_step5 >= 6 then
       mod_step6 <=mod_step5-6;
       else mod_step6 <=mod_step5;
       end if;
       if mod_step6 >= 6 then
       mod_step7 <=mod_step6-3;
       else mod_step7 <=mod_step6;
       end if;
       if(regA(7) = '0') then 
               result <= mod_step7;
           else
                if mod_step7 = 1 then
                       result <= "00000000";
                   elsif mod_step7 = 2 then
                       result <= "00000001";
                   elsif mod_step7 = 0 then
                       result <= "00000010";
               end if;        
           end if;
   when others =>
        overflow <= '0';
        sign<='0';
        result<="00000000";
   end case;
   end process;

end Behavioral;