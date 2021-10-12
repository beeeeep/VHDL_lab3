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
 
 -- 4 registers, 1 (4bit)counter, 2 (8bit and 10bit)shift registers, 1 (8bit)buffer. Total: 30bits
 
    signal Binary_in_buff: std_logic_vector(WIDTH-1 downto 0);  
    signal Binary_in_buff_next: std_logic_vector(WIDTH-1 downto 0); 

    signal  BCD_out_buff: std_logic_vector (9 downto 0);
    signal  BCD_out_buff_next: std_logic_vector (9 downto 0);

    signal  counter: std_logic_vector (3 downto 0);
    signal  counter_next: std_logic_vector (3 downto 0);
    signal  count_done: std_logic;

    signal  BCD_out_final_reg: std_logic_vector (9 downto 0);
    signal  BCD_out_final_reg_next: std_logic_vector (9 downto 0);
    
    
begin

    Double_dabble_sequential: process(clk,counter) --converts bin to bcd, BCD_out_buff is the output signal
    begin
        if(rising_edge(clk)) then
            if reset='1' then             
                BCD_out_buff<="0000000000";
                Binary_in_buff<="00000000";
            else           
                Binary_in_buff<=Binary_in_buff_next;                            
                BCD_out_buff<=BCD_out_buff_next;               
            end if;
        end if;      
    end process;

    Double_dabble_combinational: process(reset,binary_in,counter,Binary_in_buff,BCD_out_buff)--converts bin to bcd, BCD_out_buff is the output signal
    begin
        if reset='1' then  
            BCD_out_buff_next<="0000000000";
            Binary_in_buff_next<=binary_in;
        else
            if(count_done<='0') then
                Binary_in_buff_next(WIDTH-1 downto 1)<=Binary_in_buff(WIDTH-2 downto 0);
                Binary_in_buff_next(0)<='0';
               if(BCD_out_buff(3 downto 0)>="0101") then
                        BCD_out_buff_next(9 downto 1)<=BCD_out_buff(8 downto 0)+"0011";
                        BCD_out_buff_next(0)<=Binary_in_buff(WIDTH-1);
              elsif (BCD_out_buff(7 downto 4)>="0101") then
                        BCD_out_buff_next(9 downto 1)<=BCD_out_buff(8 downto 0)+"00110000";
                        BCD_out_buff_next(0)<=Binary_in_buff(WIDTH-1);
               else
                        BCD_out_buff_next(9 downto 1)<=BCD_out_buff(8 downto 0);
                        BCD_out_buff_next(0)<=Binary_in_buff(WIDTH-1);
               end if;       
            else               
                BCD_out_buff_next<="0000000000";     
                Binary_in_buff_next<=binary_in;                
           end if;
        end if;
   end process;



Output_buffer_sequential: process(clk,reset,BCD_out_final_reg_next)
begin
     if(rising_edge(clk)) then
       if reset='1' then
          BCD_out_final_reg<="0000000000";
       else
          BCD_out_final_reg<= BCD_out_final_reg_next;            
       end if;
   end if;      
end process;

Output_buffer_combinational: process(reset,count_done,BCD_out_final_reg)
   begin   
          if reset='1' then
             BCD_out_final_reg_next<="0000000000";
          elsif(count_done<='0') then 
             BCD_out_final_reg_next<= BCD_out_final_reg;
           else
            BCD_out_final_reg_next<=BCD_out_buff;           
          end if;
          BCD_out<=BCD_out_final_reg; 
end process;


Counter_sequential: process(clk,reset,counter_next)
 begin   
         if(rising_edge(clk)) then
       if reset='1' then
          counter<="0000";
       else
          counter<=counter_next;
       end if;
   end if; 
end process;

Counter_combinational: process(clk,reset,counter)
 begin   
        if reset='1' then
           counter_next<="0000";
           count_done<='1'; 
         elsif(counter<="1000") then 
            counter_next<=counter+1;
            count_done<='0';
          else
           counter_next<="0000";
           count_done<='1';        
         end if;
         BCD_out<=BCD_out_final_reg; 
end process;





end structural;
