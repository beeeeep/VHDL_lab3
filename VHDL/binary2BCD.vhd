library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


entity binary2BCD is
    generic ( WIDTH : integer := 8   -- 8 bit binary to BCD
           );
    port (
        clk       : in  std_logic;
        reset     : in  std_logic;
        binary_in : in  std_logic_vector(WIDTH-1 downto 0);  -- binary input width
        BCD_out   : out std_logic_vector(9 downto 0)        -- BCD output, 10 bits [2|4|4] to display a 3 digit BCD value when input has length 8
   
    );

end binary2BCD;

architecture structural of binary2BCD is
 
 -- 4 registers, 1 (4bit)counter, 1 (10bit) shift register,1 (10bit) buffer register, 1 (8bit)buffer. Total: 32bits
 
    signal Binary_in_buff: std_logic_vector(WIDTH-1 downto 0);   -- binary_in buffer
    signal Binary_in_buff_next: std_logic_vector(WIDTH-1 downto 0); 

    signal  BCD_sreg: std_logic_vector (9 downto 0); -- Shift register for Double-Dabble
    signal  BCD_sreg_next: std_logic_vector (9 downto 0);

    signal  counter: std_logic_vector (3 downto 0);  -- 8 bit counter
    signal  counter_next: std_logic_vector (3 downto 0);
    signal  count_done: std_logic; --Count complete signal

    signal  BCD_out_buffer: std_logic_vector (9 downto 0);  --output buffer, refreshes on count_done
    signal  BCD_out_buffer_next: std_logic_vector (9 downto 0);
    
    
begin

    Double_dabble_sequential: process(clk,counter) --converts bin to bcd, uses the Double dabble algorythm
    begin
        if(rising_edge(clk)) then
            if reset='1' then             
                BCD_sreg<="0000000000";
                Binary_in_buff<="00000000";
            else           
                Binary_in_buff<=Binary_in_buff_next;                            
                BCD_sreg<=BCD_sreg_next;               
            end if;
        end if;      
    end process;

    Double_dabble_combinational: process(reset,binary_in,Binary_in_buff,BCD_sreg,count_done)--converts bin to bcd, uses the Double dabble algorythm
    begin
        if reset='1' then  
            BCD_sreg_next<="0000000000";
            Binary_in_buff_next<=binary_in;
        else
            if(count_done='0') then
                Binary_in_buff_next(WIDTH-1 downto 1)<=Binary_in_buff(WIDTH-2 downto 0); --shift bit from binary_in buffer to BCD_shift register
                Binary_in_buff_next(0)<='0'; 
               if(BCD_sreg(3 downto 0)>="0101") then -- if the low nibble of the shift register is larger than 5, add 3 to it, and left shift 1
                        BCD_sreg_next(9 downto 1)<=BCD_sreg(8 downto 0)+"0011"; 
                        BCD_sreg_next(0)<=Binary_in_buff(WIDTH-1);
              elsif (BCD_sreg(7 downto 4)>="0101") then  -- if the high nibble of the shift register is larger than 5, add 3 to it, and left shift 1
                        BCD_sreg_next(9 downto 1)<=BCD_sreg(8 downto 0)+"00110000";
                        BCD_sreg_next(0)<=Binary_in_buff(WIDTH-1);
               else
                        BCD_sreg_next(9 downto 1)<=BCD_sreg(8 downto 0); -- else, just left shift 1
                        BCD_sreg_next(0)<=Binary_in_buff(WIDTH-1);
               end if;       
            else               
                BCD_sreg_next<="0000000000";   -- when all 8 bits have been shifted, reset shift register, buffer the input and start again
                Binary_in_buff_next<=binary_in;                
           end if;
        end if;
   end process;



Output_buffer_sequential: process(clk,reset,BCD_out_buffer_next)  -- output buffer, used to store the output signal until the next conversion is ready
begin
     if(rising_edge(clk)) then
       if reset='1' then
          BCD_out_buffer<="0000000000";
       else
          BCD_out_buffer<= BCD_out_buffer_next;            
       end if;
   end if;      
end process;

Output_buffer_combinational: process(reset,count_done,BCD_out_buffer,BCD_sreg) -- output buffer, used to store the output signal until the next conversion is ready
   begin   
          if reset='1' then
             BCD_out_buffer_next<="0000000000";
          elsif(count_done='1') then 
             BCD_out_buffer_next<=BCD_sreg; -- if the conversion is complete, refresh the output buffer
           else
            BCD_out_buffer_next<= BCD_out_buffer;   --else, keep the same value    
          end if;
          BCD_out<=BCD_out_buffer; 
end process;


Counter_sequential: process(clk,reset,counter_next) --counter register, used to count the conversion's steps, counts up to 9
 begin   
         if(rising_edge(clk)) then
       if reset='1' then
          counter<="0000";
       else
          counter<=counter_next;
       end if;
   end if; 
end process;

Counter_combinational: process(clk,reset,counter)--counter register, used to count the conversion's steps, counts up to 9
 begin   
        if reset='1' then
           counter_next<="0000";
           count_done<='1'; 
         elsif(counter<="1000") then  
            counter_next<=counter+1;
            count_done<='0';
          else
           counter_next<="0000"; --if the coutner reaches 9, zero it and start again
           count_done<='1';        
         end if;
         BCD_out<=BCD_out_buffer; 
end process;





end structural;
