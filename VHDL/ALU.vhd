library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


entity ALU is
    port (
         clk       : in  std_logic;
         reset     : in  std_logic;
         A          : in  std_logic_vector (7 downto 0);   -- Input A
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
    
    signal  counter: std_logic_vector (7 downto 0);  -- 8 bit counter
    signal  counter_next: std_logic_vector (7 downto 0);
    signal  count_done: std_logic; --Count complete signal
    
     signal  Mod3_B: std_logic_vector (7 downto 0);   
     signal  Mod3_reg: std_logic_vector (7 downto 0);  -- 8 bit counter
       signal  Mod3_reg_next: std_logic_vector (7 downto 0);
       
     signal Mod3_enable: std_logic;
   signal  result_ready :  std_logic; 
    
    -- SIGNAL DEFINITIONS HERE IF NEEDED

begin
    process ( FN, A, B )
    begin
        if(reset='1') then
        regA<="00000000";
        regB<="00000000";
        result<="00000000";
        else
        case FN is
            when "0000" => --input A
                regA<=A;
                temp_A<=A;               
            when "0001" => --input B
                regB<=B;
                temp_B<=B;
            when "0010" => --Unsigned (A+B)
                result <= regA + regB;
                temp_Y <= regA + regB;
                if((temp_A(7)='1' and temp_B(1)='1')or((temp_A(7)='1' or temp_B(1)='1')and temp_Y(7)='0')) then --signal overflow
                    overflow <= '1';
                else
                    overflow <='0';
                end if;
            when "0011" => --Unsigned (A-B)
                 result <= regA + not(regB) + 1;   
            when "0100" => --Unsigned A mod 3
            --    result (1 downto 0)<= regA(1 downto 0); 
            --    result (7 downto 2)<="000000";
            Mod3_enable<='1';
            if(count_done='1') then
            result<=Mod3_reg;
            result_ready<='1';
            else
            result<="00000000";
            result_ready<='0';
            end if;
            when "1010" => --Signed A +B
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
            when "1011" => --Signed A -B
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
            when "1100" => --Signed A mod 3
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
        end if;
    end process;
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    Counter_n_Mod3_sequential: process(clk,reset,counter_next,Mod3_reg_next) --counter register, used to count the conversion's steps, counts up to 9
     begin   
             if(rising_edge(clk)) then
           if reset='1' then
              counter<="11000000";
              Mod3_reg<="00000000";
           else
              Mod3_reg<=Mod3_reg_next;
              counter<=counter_next;
           end if;
       end if; 
    end process;
    
    Counter_combinational: process(clk,reset,counter,Mod3_enable)--counter register, used to count the conversion's steps, counts up to 9
     begin   
            if reset='1' then
               counter_next<="11000000";
               count_done<='1'; 
             elsif(counter>="00000011" and Mod3_enable='1') then  
                counter_next(6 downto 0)<=counter(7 downto 1);
                counter_next(7)<='0';
                count_done<='0';
              else
               counter_next<="11000000"; --if the coutner reaches 9, zero it and start again
               count_done<='1';        
             end if;
    end process;

   Mod3_combinational: process(clk,reset,Mod3_reg,FN)--counter register, used to count the conversion's steps, counts up to 9
      begin   
             if reset='1' then
                Mod3_reg_next<=regA;      
               else
                 if( Mod3_enable='1') then  
                 
                    if(Mod3_reg <counter)  then          
                     Mod3_B<="00000000";
                     else
                     Mod3_B<=counter;
                     end if;
                  
                    Mod3_reg_next<=Mod3_reg-Mod3_B;
                 else
                    Mod3_reg_next<=regA;
                    Mod3_B<="00000000";
                 end if;
              end if;
     end process;
    
    
    
    
    

end Behavioral;