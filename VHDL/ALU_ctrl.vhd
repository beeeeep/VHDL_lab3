library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
entity ALU_ctrl is
    port ( clk     : in  std_logic;
         reset   : in  std_logic;
         enter   : in  std_logic;
         sign    : in  std_logic;
         FN      : out std_logic_vector (3 downto 0);   -- ALU functions
         RegCtrl : out std_logic_vector (1 downto 0);  -- Register update control bits
         led_out : out  std_logic_vector (7 downto 0)   -- ALU functions
        );
end ALU_ctrl;

 -- 3 registers, 4bit counter (FN), 2bit buffer(reg_ctrl) ,1bit flag(sign_enabled)  Total: 7bits
 -- Debouncers: 2x(4bit) Total 8 bits
architecture behavioral of ALU_ctrl is

    component debouncer is
        port ( clk        : in  std_logic;
             reset      : in  std_logic;
             button_in  : in  std_logic;
             button_out : out std_logic
   
            );
    end component;



    signal enter_out : std_logic;
    signal sign_out : std_logic;
    signal sign_enabled : std_logic;
    signal sign_enabled_next : std_logic;
    signal FN_next    :std_logic_vector (3 downto 0);
    signal FN_buffer    :std_logic_vector (3 downto 0);
    signal RegCtrl_next :std_logic_vector (1 downto 0);
    signal RegCtrl_buffer :std_logic_vector (1 downto 0);
   signal led_out_next : std_logic_vector (7 downto 0);   -- ALU functions
   signal led_out_buffer : std_logic_vector (7 downto 0);   -- ALU functions
begin

  Debouncer_enter_inst: debouncer --Debounces enter button, enter_out is high for only 1 clock period, when button is pressed
  port map
  ( clk => clk,
    reset    => reset,
    button_in  => enter,
    button_out => enter_out
   );

  Debouncer_sign_inst: debouncer --Debounces sign button, sign_out is high for only 1 clock period, when button is pressed
        port map
    (
     clk => clk,
     reset => reset,
     button_in  => sign,
     button_out => sign_out
     );


FN_stage_enter_presses_comb: process(led_out_buffer,sign_enabled,enter_out,FN_buffer,reset) -- FSM for FN selection
        begin      
        if reset='1' then
        FN_next<="0010";
        led_out_next<="00000001";
        else
        if enter_out='1' then
            case FN_buffer(3 downto 0) is
                when "0000" =>
                    FN_next<="0001";
                    led_out_next<="00000011";
                when "0001" =>
                    FN_next<="0010";
                    led_out_next<="00000111";
                when "0010" =>
                    FN_next<="0011";
                    led_out_next<="00001111";
                when "0011" =>
                    FN_next<="0100";
                    led_out_next<="00011111";           
                when "0100" =>
                    if(sign_enabled='1') then --if signed mode is enabled allow the signed calculations to be selected
                        FN_next<="1010";
                        led_out_next<="00111111";
                    else
                        FN_next<=(others => '0');
                        led_out_next<="00000001";                       
                    end if;
                when "1010" =>
                    if(sign_enabled='1') then --if signed mode is enabled allow the signed calculations to be selected
                        FN_next<="1011";
                        led_out_next<="01111111";
                    else
                        FN_next<=(others => '0');
                        led_out_next<="00000001";
                    end if;
                when "1011" =>
                    if(sign_enabled='1') then --if signed mode is enabled allow the signed calculations to be selected
                        FN_next<="1100";
                        led_out_next<="11111111";
                    else
                        FN_next<=(others => '0');
                        led_out_next<="00000001";
                    end if;
                when "1100" =>
                    FN_next<=(others => '0');
                    led_out_next<="00000001";
                when others    =>
                    FN_next<=(others => '0');
                    led_out_next<="00000001";
            end case;
            else
            FN_next<=FN_buffer;  
            led_out_next<=led_out_buffer;               
        end if;
        end if;
    end process;
    
  RegCtrl_comb: process(FN_buffer,reset) -- FSM for   RegCtrl selection
    begin       
      case FN_buffer(3 downto 0) is
                  when "0000" =>
                      RegCtrl_next<="01";
                  when "0001" =>
                      RegCtrl_next<="10";
                     when others    => 
                      RegCtrl_next<="00";     
     end case;
    end process;  
    
    

  Set_FN_and_RegCtrl_seq: process(led_out_next,RegCtrl_next,FN_next,clk,reset) --FN buffer register
    begin
        if(reset= '1') then
            FN_buffer<=(others => '0');
            RegCtrl_buffer<=(others => '0');
            led_out_buffer<=led_out_next;
        elsif (rising_edge(clk)) then
            FN_buffer<=FN_next;
            led_out_buffer<=led_out_next;
            RegCtrl_buffer<=RegCtrl_next;
        end if;
    end process;
    FN<=FN_buffer; -- connect FN output with buffer
    RegCtrl<=RegCtrl_buffer;
    led_out<=led_out_buffer;
    
    
  Set_sign_seq: process(sign_enabled_next,clk,reset)  -- sign_enabled register
    begin
        if(reset= '1') then
            sign_enabled<='0';
        elsif (rising_edge(clk)) then
            sign_enabled<=sign_enabled_next;
        end if;
    end process;

    Set_sign_comb: process(sign_enabled,sign_out,reset)  -- Sets the sign enabled register High or Low if the sign button is pressed
    begin
        if(reset= '1') then
            sign_enabled_next<='0';
        elsif (sign_out='1' and sign_enabled='0') then
            sign_enabled_next<='1';
        elsif (sign_out='1' and sign_enabled='1') then
         sign_enabled_next<='0';    
        else
            sign_enabled_next<=sign_enabled;
        end if;
    end process;



end behavioral;
