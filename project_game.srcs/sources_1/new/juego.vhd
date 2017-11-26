library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--use STD.textio.all;
--use IEEE.std_logic_textio.all;

library UNISIM;
use UNISIM.VComponents.all;

--use IEEE.NUMERIC_STD.ALL;
--use UNISIM.VComponents.all;

entity juego is
    Port ( 
           clk :      in  STD_LOGIC;
           rst:       in  std_logic;
           moneda:    in std_logic;
           mult:      in std_logic;
           start:     in std_logic;
           led :      out STD_LOGIC_VECTOR (7 downto 0);
           led_st:    out STD_LOGIC_VECTOR (7 downto 0);
           hcount:    out  STD_LOGIC_VECTOR (10 downto 0);  --para simular
           vcount:    out  STD_LOGIC_VECTOR (10 downto 0);  --para simular
           hs:        out std_logic;
           vs:        out std_logic;
           rgb:       out std_logic_vector(11 downto 0)
    );
end juego;


architecture Behavioral of juego is


component display_34
port(
      value:  in  std_logic_vector(7 downto 0);
      hcount: in  std_logic_vector(10 downto 0);
      vcount: in  std_logic_vector(10 downto 0);
      paint:  out std_logic;
      posx:   in  integer;
      posy:   in  integer
  );
end component;
component vga_ctrl_640x480_60hz
port
(
   rst:     in  std_logic;
   clk:     in  std_logic;
   rgb_in:  in  std_logic_vector(11 downto 0);
   HS:      out std_logic;
   VS:      out std_logic;
   hcount:  out std_logic_vector(10 downto 0);
   vcount:  out std_logic_vector(10 downto 0);
   rgb_out: out std_logic_vector(11 downto 0);--R3R2R1R0GR3GR3GR3GR3B3B2B1B0
   blank:   out std_logic
  );
end component;

component states_machine
Port 
(
  clk:      in  STD_LOGIC;
  rst:      in  std_logic;
  moneda:   in  std_logic;
  mult:     in  std_logic;
  start:    in  std_logic;
  hcount:   in  std_logic_vector(10 downto 0);
  vcount:   in  std_logic_vector(10 downto 0);
  value:    out std_logic_vector(7 downto 0);
  posx:     out integer;
  posy:     out integer;
  led:      out std_logic_vector(7 downto 0)
);
end component;
component debounce
generic( COUNT_MAX: integer := 255; 
           COUNT_WIDTH: integer := 8);
port (
    clk : std_logic;
    I: in std_logic;
    O: out std_logic
);
end component;

signal Tled :                       std_logic_vector(7 downto 0):= "00000001";
--signal Iv: std_logic := '0';
signal clk_50Mhz :                  std_logic:='0';
signal rgb_aux:                     std_logic_vector(11 downto 0);
signal hcount1,vcount1:             std_logic_vector (10 downto 0 );
signal paint0:                      std_logic;
signal px,py:                       integer;
signal val :                        std_logic_vector(7 downto 0);
signal rst_d,coin_d,mx_d,start_d:   std_logic:='0'; --botones con debouncer introducido
signal cnt :                        integer:=0;
signal rst_r,coin_r,mx_r,start_r:   std_logic:='0'; --pulsos de menos de 10ns, producidos para mejorar la respuesta de las teclas
signal temp:                        std_logic:='0';

begin

--Reloj de 50 mhz, el resto de relojes se crean en la maquina de estados a necesidad
--_________________________________________________________________________
clock_50mhz: process (clk)
begin  
  if (clk'event and clk = '1') then
    clk_50Mhz <= not clk_50Mhz;
  end if;
end process;
--_________________________________________________________________________

--debouncer para los botones
--_________________________________________________________________________
deb_coin: debounce
GENERIC MAP (
  COUNT_MAX => 19,
  COUNT_WIDTH => 5
  )
port map
(
  clk   =>  clk,
  i     =>  moneda,
  o     =>  coin_d
);

deb_mx: debounce
GENERIC MAP (
  COUNT_MAX => 19,
  COUNT_WIDTH => 5
  )
port map
(
  clk   =>  clk,
  i     =>  mult,
  o     =>  mx_d
);
deb_rst: debounce
GENERIC MAP (
  COUNT_MAX => 19,
  COUNT_WIDTH => 5
  )
port map
(
  clk   =>  clk,
  i     =>  rst,
  o     =>  rst_d
);
deb_start: debounce
GENERIC MAP (
  COUNT_MAX => 19,
  COUNT_WIDTH => 5
  )
port map
(
  clk   =>  clk,
  i     =>  start,
  o     =>  start_d
);
--_________________________________________________________________________






--generadores de pulso unico con periodo < 10ns
--___________________________________________________________

Reset_R:process (clk,rst_d)
variable rst_counter: std_logic:='0';
begin
  if(rst_d'event and rst_d='1' and rst_counter='0') then
    rst_r<='1';
    rst_counter:='1';
  end if;
  if(clk'event and clk='0') then
    rst_r<='0';
  end if;
  if(rst_d'event and rst_d='0') then
    rst_counter:='0';
  end if;
end process;

Coins_R:process (clk,coin_d)
variable coin_counter: std_logic:='0';
begin
  if(coin_d'event and coin_d='1' and coin_counter='0') then
    coin_r<='1';
    coin_counter:='1';
  end if;
  if(clk'event and clk='0') then
    coin_r<='0';
  end if;
  if(coin_d'event and coin_d='0') then
    coin_counter:='0';
  end if;
end process;

Multiplicador_R:process (clk,mx_d)
variable mx_counter: std_logic:='0';
begin
  if(mx_d'event and mx_d='1' and mx_counter='0') then
    mx_r<='1';
    mx_counter:='1';
  end if;
  if(clk'event and clk='0') then
    mx_r<='0';
  end if;
  if(mx_d'event and mx_d='0') then
    mx_counter:='0';
  end if;
end process;

Start_Real:process (clk,start_d)
variable start_counter: std_logic:='0';
begin
  if(start_d'event and start_d='1' and start_counter='0') then
    start_r<='1';
    start_counter:='1';
  end if;
  if(clk'event and clk='0') then
    start_r<='0';
  end if;
  if(start_d'event and start_d='0') then
    start_counter:='0';
  end if;
end process;
 --__________________________________________________________






vgacontroller:vga_ctrl_640x480_60hz 
port map
(
   rst      =>  rst_r,
   clk      =>  clk_50Mhz,
   rgb_in   =>  rgb_aux,
   HS       =>  hs,
   VS       =>  vs,
   hcount   =>  hcount1,
   vcount   =>  vcount1,
   rgb_out  =>  rgb,
   blank    =>  open
);

states_machine1: states_machine
Port map
(
  clk       => clk,
  rst       => rst_r,
  moneda    => coin_r,
  mult      => mx_r,
  start     => start,
  hcount    => hcount1,
  vcount    => vcount1,
  value     => val,
  posx      => px,
  posy      => py,
  led       => led_st
);

display: display_34
port map
(
  value   =>  val,
  hcount  =>  hcount1,
  vcount  =>  vcount1,
  posx    =>  px,
  posy    =>  py,
  paint   =>  paint0      
);

color: process(paint0)
begin
  if paint0='1' then
    rgb_aux<="111100000000";
  else
    rgb_aux<="111111111111";
  end if;
end process;       
--led<="11111110";
hcount<=hcount1; 
vcount<=vcount1;

end Behavioral;
