
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_signed.all;
--

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

    signal temp_Y : unsigned (7 downto 0);
    signal mod_step1 : std_logic_vector(7 downto 0);
    signal mod_step2 : std_logic_vector(7 downto 0);
    signal mod_step3 : std_logic_vector(7 downto 0);
    signal mod_step4 : std_logic_vector(7 downto 0);
    signal mod_step5 : std_logic_vector(7 downto 0);
    signal mod_step6 : std_logic_vector(7 downto 0);
    signal mod_step7 : std_logic_vector(7 downto 0);

begin


    mod_step1 <= A - 192 when A >= 192 else A;
    mod_step2 <= mod_step1 - 96 when mod_step1 >= 96 else mod_step1;
    mod_step3 <= mod_step2 - 48 when mod_step2 >= 48 else mod_step2;
    mod_step4 <= mod_step3 - 24 when mod_step3 >= 24 else mod_step3;
    mod_step5 <= mod_step4 - 12 when mod_step4 >= 12 else mod_step4;
    mod_step6 <= mod_step5 - 6 when mod_step5 >= 6 else mod_step5;
    mod_step7 <= mod_step6 - 3 when mod_step6 >= 3 else mod_step6;


    process ( FN,mod_step7,temp_Y, A, B )
    begin

        case FN is
            when "0000" => --Load A
           
                overflow <= '0';
                result<=A;
                temp_Y <=(others => '0');
                result <= (others => '0');
                sign<= '0';          
                    
            when "0001" => --Load B
        
                overflow <= '0';
                temp_Y <=(others => '0');
                result<=B;
                sign<= '0';  

          
            when "0010" => -- Unsigned A+B
           
              if((A(7)='1' or B(7)='1') and (temp_Y(7)='0')) then -- if both numbers are greater than 127
              overflow<='1';
              else
              overflow<='0';
              end if;
              temp_Y  <=(unsigned(A)) + (unsigned(B));
              result<= std_logic_vector (temp_Y);
              sign<= '0'; 

            when "0011" => -- Unsigned A-B
              if( unsigned(A) < unsigned(B) )then
                overflow<='1';
              else
                 overflow<='0';
              end if;
              temp_Y <= (unsigned(A)) + (not(unsigned(B))+1); --A+(!B+1)
              result<= std_logic_vector (temp_Y);
              sign<= '0';            
              
            when "0100" => -- Unsigned Amod3
           
                overflow <= '0';
                temp_Y <=(others => '0');
                result <= mod_step7;
                sign<= '0'; 
                  
           when "1010" => --Signed A+B
             
                --If the sum of two same sign numbers yields a negative result, the sum has overflowed
                --XNOR checks if A B have the same, AND checks if that sign is negative
                
                overflow <= (A(7) xnor B(7)) and (temp_Y(7) and '1');

                if (A(7)= '1' and B (7)='1' ) then  --if both numbers are negative    
                  
                   temp_Y <= unsigned(A) + unsigned(B);
                   result<=std_logic_vector(temp_Y);
                   sign<='1';                                        
               
                elsif (A(7)= '1' and B (7)='0' ) then  -- if A is negative and B is positive                 
                    temp_Y<=unsigned(B)+unsigned(not(A))+1;
                    result<=std_logic_vector('0' & temp_Y(6 downto 0));
                    if(unsigned(B)>(unsigned(not('0' & (A(6 downto 0))))+1)) then
                        sign<='1';
                    else
                         sign<='0';
                    end if;    
                elsif (A(7)= '0' and B (7)='0' ) then -- if both A and B are positive
                    
                    temp_Y<=unsigned(A)+unsigned(B);
                    result<=std_logic_vector(temp_Y);
                    sign<='0';
                 
                elsif (A(7)= '0' and B (7)='1' ) then -- if A is positive and B is negative
                
                    temp_Y<=unsigned(B)+unsigned(not(A))+1;
                    result<=std_logic_vector('0' & temp_Y(6 downto 0));
                    if(unsigned(B)<(unsigned(not('0' & (A(6 downto 0))))+1)) then
                        sign<='1';
                    else
                        sign<='0';
                    end if;  
                else
                  sign<='0';
                  result<=(others => '0');
                  temp_Y <=(others => '0');             
                end if;
                
            when "1011" =>  --Signed A-B            
                --If the sum of two same sign numbers yields a negative result, the sum has overflowed
                --XNOR checks if A B have the same, AND checks if that sign is negative
                overflow <= (A(7) xor B(7)) and (temp_Y(7) and '1');
            
                if (A(7)= '1' and B (7)='1' ) then --  if A is negative and B is negative -A-(-B)=-A+B
                 
                    temp_Y<=unsigned(B)+unsigned(not(A))+1;
                    result<=std_logic_vector('0' & temp_Y(6 downto 0));                
                   
                    if(unsigned(B)>(unsigned(not('0' & (A(6 downto 0))))+1)) then
                        sign<='1';
                    else
                        sign<='0';             
                    end if;
                    
                elsif (A(7)= '1' and B (7)='0' ) then --  if A is negative and B is positive -A-B
                     temp_Y <= unsigned(A) + unsigned(B);
                     result<=std_logic_vector('0' & temp_Y(6 downto 0));
                     sign<='1';
                elsif (A(7)= '0' and B (7)='0' )then -- if both are positive A-B
                    temp_Y<=unsigned(B)+unsigned(not('0' & (A(6 downto 0))))+1;
                    result<=std_logic_vector('0' & temp_Y(6 downto 0));
                    if(unsigned(B)<(unsigned(not('0' & (A(6 downto 0))))+1)) then
                        sign<='1';
                    else
                        sign<='0';
                    end if;
                elsif(A(7)= '0' and B (7)='1' ) then --  if A is positve and B is negative A+B
                     temp_Y<=unsigned('0' & (A(6 downto 0)))+unsigned('0' & (B(6 downto 0)));
                     result<=std_logic_vector(temp_Y);
                     sign<='0';              
               else 
                 
                   
                   result<=(others => '0');
                   temp_Y <=(others => '0');  
                   sign<='0'; 
                end if;
            when "1100" => --Signed Amod3 
                overflow <= '0';
                temp_Y <=(others => '0');
                
                if(A(7) = '0') then
                    result <= mod_step7;
                else
                    if mod_step7 = 2 then
                        result <=(others => '0');
                    elsif mod_step7 = 0 then
                        result <= "00000001";
                    elsif mod_step7 = 1 then
                        result <= "00000010";
                    else
                       result <= (others => '0');   
                    end if;
                end if;
                sign<= '0';

            when others =>
                overflow <= '0';
                sign<='0';
                result<=(others => '0');
                temp_Y <=(others => '0');
        end case;
    end process;

end Behavioral;