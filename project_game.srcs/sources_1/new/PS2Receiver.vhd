--codigo convertido del verilog

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--use STD.textio.all;
--use IEEE.std_logic_textio.all;

library UNISIM;
use UNISIM.VComponents.all;
entity PS2Receiver is
port( clk:      in  std_logic;
      kclk:     in  std_logic;
      kdata:    in  std_logic;
      keycode:  out std_logic_vector(7 downto 0);
      flag_x:    out std_logic
    );
      
end entity;

architecture behave of PS2Receiver is

signal kclkf:     std_logic:='0';
signal kdataf:    std_logic:='0';
signal datacur:   std_logic_vector(7 downto 0):="00000000";
--signal dataprev:  std_logic_vector(7 downto 0);
signal cnt:       std_logic_vector(3 downto 0):= "0000" ;
signal flag:      std_logic:='0';
signal pflag:     std_logic:='0';
signal contar:    std_logic_vector(1 downto 0) :="00";


-- componente debouncing
component debouncing 
 generic( COUNT_MAX: integer := 255; 
           COUNT_WIDTH: integer := 8);
 port( clk : in std_logic;
       I : in std_logic;
       O : out std_logic);
 end component;

-- inicia la arquitectura
begin
--antirebote  kclck
deb1:  debouncing
	GENERIC MAP (
		COUNT_MAX => 19,
		COUNT_WIDTH => 5
		)
	PORT MAP(
		clk => clk,
		I => kclk,
		O => kclkf
	);
	
deb2:  debouncing
  GENERIC MAP (
      COUNT_MAX => 19,
      COUNT_WIDTH => 5
      )
  PORT MAP(
      clk => clk,
      I => kdata,
      O => kdataf
  );


   --kdataf<=kdata; -- solo para simulacion
--proceso para leer los datos detectado activado por el reloj del teclado
process(kclk)   
   begin
    if(falling_edge(kclk)) then
      case (cnt) is
          when "0000" => null;
          when "0001" => datacur(0)<=kdataf;
          when "0010" => datacur(1)<=kdataf;
          when "0011" => datacur(2)<=kdataf;
          when "0100" => datacur(3)<=kdataf;
          when "0101" => datacur(4)<=kdataf;
          when "0110" => datacur(5)<=kdataf;
          when "0111" => datacur(6)<=kdataf;
          when "1000" => datacur(7)<=kdataf;
          when "1001" => flag <= '1' ;
                         --contar<= '0';
          when "1010" => flag <= '0' ;
          when others => null;
      end case;
      if (cnt <= "1001" ) then 
        cnt <= cnt+1;
      elsif(cnt = "1010" ) then
        cnt <= "0000" ;
      end if;  
   end if;   
 end process;

process(clk)
  begin
    if(falling_edge(clk)) then
        if(flag = '1' and  pflag = '0') then
--           keycode <= dataprev & datacur;
            
             keycode <= datacur;
            if(contar<"10") then
              flag_x <= '1';
              contar<= contar+'1';
            else
               flag_x <= '0';
            end if;
             --dataprev <= datacur;
        else
             flag_x <= '0';
             pflag <= flag;
             contar <= "00";
        end if;
        
     end if;
    end process;
--verificar que funcione!!
end behave;
--endmodule
