----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 17.11.2017 21:04:02
-- Design Name: 
-- Module Name: machine_sim - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use std.textio.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity juego_sim is
--Port ( );
end juego_sim;

architecture Behavioral of juego_sim is
component juego
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

end component;
	constant hmax: integer:=640;
	constant vmax: integer:=480;

	--____________________________________________________
	--¿Cuantos frames lo voy a poner a grabar para matlab?
	constant frame_max: integer :=60;
	--____________________________________________________


	SIGNAL CLK_10:STD_LOGIC:='0';
	SIGNAL rgb_out: std_logic_vector(11 downto 0):= (others=>'0');
	signal hcount,vcount : STD_LOGIC_VECTOR (10 downto 0) := "00000000000";
	signal frame_count: integer :=0;
	signal rst: std_logic:='0';
	signal led_code: std_logic_vector(7 downto 0):= (others=>'0');
	signal led_state: std_logic_vector(7 downto 0):= (others=>'0');
	
	signal coin: std_logic:='0';
	signal mult: std_logic:='0';
	signal start: std_logic:='0';

begin



test: juego port map(
    clk 	=>	clk_10,
    rst 	=>	rst,
    moneda  =>	coin,
    mult 	=>	mult,
    start 	=>	start,
    led 	=>	led_code,
    led_st 	=>	led_state,
    hcount	=>	hcount,
    vcount  =>	vcount,
    hs 		=>	open,
    vs 		=>	open,
    rgb 	=>	rgb_out
);

clk_process: process
begin
    wait for 5ns;
    clk_10<=not(clk_10); 
end process;


hvsync: process(hcount,vcount)
begin
	if (hcount=0 and vcount=0) then
		frame_count<=frame_count+1;		
	end if;
end process;




--process para ingresar los eventos externos(botones start, reset, moneda, multiplicador)
input_data: process(frame_count)
begin
	
		case frame_count is
		
		when 2=>
			rst<='1';

			
		when 10=>
			rst<='0';
			start<='1';
			coin<='1';

		when 15=>
			rst<='1';
			coin<='1';
			coin<='0';
			mult<='1';
			
		when 18=>
			rst<='0';
			mult<='0';
			
		
		when others=>
		end case;
end process;



capa1r: process(hcount)
	variable texto1: line;
    variable color: std_logic_vector(11 downto 0);
    variable temp1: std_logic_vector (3 downto 0);
    file solucion: text;
    variable c: std_logic:='0';
    variable frame_aux: integer;
begin
	

	temp1:= rgb_out(3) & rgb_out(2) & rgb_out(1) & rgb_out(0);
	--color:= temp3 & temp2 & temp1;
	
	if(vcount=0 and hcount=0 and c='0') then
		file_open(solucion, "resultadosr.m",  append_mode);
		write(texto1,string'("r(:,:,"));
		write(texto1,frame_count);
		write(texto1,string'(")=["));

		c:= not c;
		--write(texto1,string'(""));
	end if;

	write (texto1, conv_integer(temp1));

	if(hcount<=hmax)then
		write (texto1, string'(","));
	else
		if (vcount<=vmax) then
			if (vcount=vmax) then
				write (texto1, string'("];"));
				writeline (solucion, texto1);

				if frame_count>frame_max then
					file_close(solucion);
				else
					write(texto1,string'("r(:,:,"));
					write(texto1,frame_count);
					write(texto1,string'(")=["));

				end if;
			else
				write (texto1, string'(";"));
				--write(texto1, string'("   %("));
				--write(texto1, conv_integer(hcount));
				--write(texto1, string'(","));
				--write(texto1, conv_integer(vcount));
				--write(texto1, string'(")"));
				--writeline (solucion, texto1);
			end if;
		end if;
	end if;
end process;

resultado: process(frame_count)
	variable texto1: line;
    file solucion: text;
 begin
	if (frame_count=frame_max) then
		file_open(solucion, "resultado.m",  append_mode);
		write (texto1, string'("clear all;"));
		write (texto1, string'("close all;"));
		write (texto1, string'("clc;"));
		writeline (solucion, texto1);

		write (texto1, string'("run('resultadosr.m');"));
		--write (texto1, string'("run('resultadosg.m');"));
		--write (texto1, string'("run('resultadosb.m');"));
		writeline (solucion, texto1);
		write (texto1, string'("for i=1:"));
		write (texto1, frame_max);
		writeline (solucion, texto1);
		write(texto1,string'("imagen=zeros(640,480,3"));
		write(texto1,frame_max);
		write(texto1,string'(",60);"));
		write (texto1, string'("imagen(:,:,1,i)=uint8(r(:,:,i).*16);"));
		--write (texto1, string'("imagen(:,:,2,i)=uint8(g(:,:,i).*16);"));
		--write (texto1, string'("imagen(:,:,3,i)=uint8(b(:,:,i).*16);"));
		writeline (solucion, texto1);
		write (texto1, string'("end;"));
		writeline (solucion, texto1);

		write (texto1, string'("implay(imagen,1);"));
		
		writeline (solucion, texto1);
		file_close(solucion);
	end if;
end process;

end Behavioral;

--capa3b: process(hcount)
--	variable texto1: line;
--    variable color: std_logic_vector(11 downto 0);
--    variable temp3: std_logic_vector (3 downto 0);
--    file solucion: text;
--    variable c: std_logic:='0';
--    variable frame_aux: integer;
--begin
--	frame_aux:=frame_count+1;
--	temp3:= rgb_out(11) & rgb_out(10) & rgb_out(9) & rgb_out(8);
--	--color:= temp3 & temp2 & temp1;
	
--	if(vcount=0 and hcount=0 and c='0') then
--		file_open(solucion, "resultadosb.m",  append_mode);
--		write(texto1,string'("b(:,:,"));
--		write(texto1,frame_count);
--		write(texto1,string'(")=["));


--		c:= not c;
--		--write(texto1,string'(""));
--	end if;

--	write (texto1, conv_integer(temp3));

--	if(hcount<hmax)then
--		write (texto1, string'(","));
--	else
--		if (vcount<=vmax) then
--			if (vcount=vmax) then
--				write (texto1, string'("];"));
--				writeline (solucion, texto1);

--				if frame_count>frame_max then
--					file_close(solucion);
--				else
--					write(texto1,string'("b(:,:,"));
--					write(texto1,frame_aux);
--					write(texto1,string'(")=["));

--				end if;
--			else
--				write (texto1, string'(";"));
--				--write(texto1, string'("   %("));
--				--write(texto1, conv_integer(hcount));
--				--write(texto1, string'(","));
--				--write(texto1, conv_integer(vcount));
--				--write(texto1, string'(")"));
--				--writeline (solucion, texto1);
--			end if;
--		end if;
--	end if;
--end process;

--capa2g: process(hcount)
--	variable texto1: line;
--    variable color: std_logic_vector(11 downto 0);
--    variable temp2: std_logic_vector (3 downto 0);
--    file solucion: text;
--    variable c: std_logic:='0';
--    variable frame_aux: integer;
--begin
--	frame_aux:=frame_count+1;
--	temp2:= rgb_out(7) & rgb_out(6) & rgb_out(5) & rgb_out(4);
--	--color:= temp3 & temp2 & temp1;
	
--	if(vcount=0 and hcount=0 and c='0') then
--		file_open(solucion, "resultadosg.m",  append_mode);
--		write(texto1,string'("g(:,:,"));
--		write(texto1,frame_count);
--		write(texto1,string'(")=["));


--		c:= not c;
--		--write(texto1,string'(""));
--	end if;

--	write (texto1, conv_integer(temp2));

--	if(hcount<hmax)then
--		write (texto1, string'(","));
--	else
--		if (vcount<=vmax) then
--			if (vcount=vmax) then
--				write (texto1, string'("];"));
--				writeline (solucion, texto1);

--				if frame_count>frame_max then
--					file_close(solucion);
--				else
--					write(texto1,string'("g(:,:,"));
--					write(texto1,frame_aux);
--					write(texto1,string'(")=["));

--				end if;
--			else
--				write (texto1, string'(";"));
--				--write(texto1, string'("   %("));
--				--write(texto1, conv_integer(hcount));
--				--write(texto1, string'(","));
--				--write(texto1, conv_integer(vcount));
--				--write(texto1, string'(")"));
--				--writeline (solucion, texto1);
--			end if;
--		end if;
--	end if;
--end process;
