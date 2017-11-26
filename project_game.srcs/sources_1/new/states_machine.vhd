----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06.11.2017 17:16:10
-- Design Name: 
-- Module Name: state_f_machine - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity states_machine is
Port 
(
	clk:		in 	std_logic;
	rst: 		in 	std_logic;
	moneda:   	in  std_logic;
    mult:     	in  std_logic;
    start:    	in  std_logic;
	hcount:		in 	std_logic_vector(10 downto 0);
	vcount:		in 	std_logic_vector(10 downto 0);
	value:		out std_logic_vector(7 downto 0);
	posx:  		out	integer;
	posy:   	out integer;
	led:	    out std_logic_vector(7 downto 0)
);
end states_machine;

architecture Behavioral of states_machine is
	constant dl:  integer := 50; 	--largo del caracter
	constant dh:  integer := 100; 	--altura del caracter
	constant lw:  integer := 5; 	--ancho de las lineas
	constant esh: integer := 10; 	--espacio entre caracterers

	constant th: integer := 640;
	constant tv: integer := 480;

	constant CC1 : integer := 3; 	-- cantidad de letras para primera fila (codigo + confirmacion= 4 + 1) 
	
	constant esl : integer := dl+lw; --espacio entre palabras

	constant EVU : integer := 2*(dh+esh); -- espacio vertical utilizado
	constant EHU1: integer := cc1*(dl+esh) ; --Espacio horizontal total utilizado fila 1 y 2
	constant RESET_DATA: std_logic_vector(7 downto 0):=(others=>'0');

	signal data11,data12,data13,data14 :std_logic_vector(7 downto 0):=RESET_DATA;
	type state_code is (s0,s1,s2,s3,s4,s5,s6,s7,s8,s9);
	signal state_p_1,state_p_2,state_p_3,state_f_1,state_f_2,state_f_3: state_code:= s0;
	signal clk_1hz,clk_2hz,clk_4hz: std_logic:='0';
	constant c_max:integer:=5000000;
begin

	print: process(hcount)
		variable px1,px10,px11,px12,px13,px101: integer:=0;
		variable px2,px20,px21,px22,px23,px201: integer:=0;
		variable py1,py2,py3: integer;
	begin

	



		--centrado vertical y horizontalmente
		px1 := (th-ehu1)/2 ;
		py1 := (tv - EVU)/2;

		py2:=py1+dh;											   
		--py3:=py1+2*dh;

		--cuatro simbolos primera y segunda lineas
		px10:= px1;
		px11:= px1 + dl + esh;
		px12:= px1 + 2*(dl + esh);
		--px13:= px1 + 3*(dl + esh);
		px101:= px1 + 3*(dl + esh);




		if (vcount > py1) and (vcount <py2) then
			posy<=py1;

			if hcount>px10 and hcount<px11 then
				posx<=px10;
				value<=data11;

			elsif hcount>px11 and hcount<px12 then
				posx<=px11;
				value<=data12;

			elsif hcount>px12 and hcount<px101 then
				posx<=px12;
				value<=data13;
			--elsif hcount>px13 and hcount<px101 then
			--	posx<=px13;
			--	value<=data14;
			--elsif hcount>px14 and hcount<px101 then
			--	posx<=px14;
			--	value<=data_icon1;
			end if;



		--elsif vcount > py2 and vcount <py3 then
		--	posy<=py2;
			
		--	if hcount>px10 and hcount<px11 then
		--		posx<=px10;
		--		value<=data21;
		--	elsif hcount>px11 and hcount<px12 then
		--		posx<=px11;
		--		value<=data22;
		--	elsif hcount>px12 and hcount<px13 then
		--		posx<=px12;
		--		value<=data23;
		--	elsif hcount>px13 and hcount<px101 then
		--		posx<=px13;
		--		value<=data24;
		--	--elsif hcount>px14 and hcount<px101 then
		--	--	posx<=px14;
		--	--	value<=data_icon2;
			end if;
	end process;


--___________________________________________________________________
--Relojes para las maquinas. Recordar que clk= 10Mhz
--___________________________________________________________________

clk1hz:process(clk)
variable counter:integer:=0;
begin
	if (clk'event and clk = '1') then
		counter:=counter+1;
	end if;
	if(counter=100000000) then
		counter:=0;
		clk_1hz<=not clk_1hz;
	end if;
end process;

clk2hz:process(clk)
variable counter:integer:=0;
begin
	if (clk'event and clk = '1') then
		counter:=counter+1;
	end if;
	if(counter=50000000) then
		counter:=0;
		clk_2hz<=not clk_2hz;
	end if;
end process;

clk4hz:process(clk)
variable counter:integer:=0;
begin
	if (clk'event and clk = '1') then
		counter:=counter+1;
	end if;
	if(counter=25000000) then
		counter:=0;
		clk_4hz<=not clk_4hz;
	end if;
end process;









--______________________________________________________________________

--la main machine se encargara de en que estado estara cada una de las demas
--tambien recibira las señales de inicio, fin (start='0', start='1'), reset, multiplicador y moneda

Main_machine: process(clk_1hz,clk_2hz,clk_4hz,rst,moneda,start,mult)
variable move:std_logic:='0';
begin

if rst='1' then
	state_p_1<=s0;
	state_p_2<=s0;
	state_p_3<=s0;
end if;

if start='1' then
	move:= not move;
end if;





--maquina 1
if(clk_1hz'event and clk_1hz='1') then
	if move = '1' then
		state_p_1<=state_f_1;
	end if;
end if;
if(clk_2hz'event and clk_2hz='1') then
	if move='1' then
		state_p_2<=state_f_2;
	end if;
end if;

if(clk_4hz'event and clk_4hz='1') then
	if move= '1' then
		state_p_3<=state_f_3;
	end if;
end if;




end process;

first_machine: process(state_p_1)	
begin

	case state_p_1 is
		when s0=>
			data11<="01000101";
			state_f_1<=s1;
		when s1=>
			data11<="00010110";
			state_f_1<=s2;
		when s2=>
			data11<="00011110";
			state_f_1<=s3;
		when s3=>
			data11<="00100110";
			state_f_1<=s4;
		when s4=>
			data11<="00100101";
			state_f_1<=s5;
		when s5=>
			data11<="00101110";
			state_f_1<=s6;
		when s6=>
			data11<="00110110";
			state_f_1<=s7;
		when s7=>
			data11<="00111101";
			state_f_1<=s8;
		when s8=>
			data11<="00111110";
			state_f_1<=s9;
		when s9=>
			data11<="01000110";
			state_f_1<=s0;
	end case;

end process;

second_machine: process(state_p_2)
begin
		case state_p_2 is
		when s0=>
			data12<="01000101";
			state_f_2<=s1;
		when s1=>
			data12<="00010110";
			state_f_2<=s2;
		when s2=>
			data12<="00011110";
			state_f_2<=s3;
		when s3=>
			data12<="00100110";
			state_f_2<=s4;
		when s4=>
			data12<="00100101";
			state_f_2<=s5;
		when s5=>
			data12<="00101110";
			state_f_2<=s6;
		when s6=>
			data12<="00110110";
			state_f_2<=s7;
		when s7=>
			data12<="00111101";
			state_f_2<=s8;
		when s8=>
			data12<="00111110";
			state_f_2<=s9;
		when s9=>
			data12<="01000110";
			state_f_2<=s0;
	end case;
end process;

third_machine: process(state_p_3)
begin
		case state_p_3 is
		when s0=>
			data13<="01000101";
			state_f_3<=s1;
		when s1=>
			data13<="00010110";
			state_f_3<=s2;
		when s2=>
			data13<="00011110";
			state_f_3<=s3;
		when s3=>
			data13<="00100110";
			state_f_3<=s4;
		when s4=>
			data13<="00100101";
			state_f_3<=s5;
		when s5=>
			data13<="00101110";
			state_f_3<=s6;
		when s6=>
			data13<="00110110";
			state_f_3<=s7;
		when s7=>
			data13<="00111101";
			state_f_3<=s8;
		when s8=>
			data13<="00111110";
			state_f_3<=s9;
		when s9=>
			data13<="01000110";
			state_f_3<=s0;
	end case;
end process;
		
end Behavioral;





	--next_state: process(clk_1,rst)
	--begin
	--	if rst='1' then
	--		state_p<=s0;
	--	elsif(rising_edge(clk_1) ) then
	--		state_p<=state_f;
	--	end if;
	--	--if(rising_edge(flag_x)) then
	--	--	case state_p is
	--	--		when s0|s2|s4|s6|s8 =>
	--	--			state_p<=state_f;
	--	--		when others =>
	--	--	end case;
	--	--end if;

	--end process;


	--finite_state_f_machine: process(flag_x)
	--variable ban: std_logic:='0';
	--begin
	--		--state_f<=state_p;
			
	--			case state_p is
	--				when s0=>
	--						state_f<=s1;
	--						led<="00000001";
	--						ban:='0';
	--				when s1=>
	--					if rising_edge(flag_x) and keycode/=code_F0 and ban='0' then
	--						state_f<=s2;
	--						led<="00000010";
	--						ban:='1';
	--						keycode_aux<=keycode;
	--					end if;
	--				when s2=>
	--						state_f<=s3;
	--						ban:='0';
	--						led<="00000011";
							
	--				when s3=>	
	--					if rising_edge(flag_x) and keycode/=code_F0 and ban='0' then
	--						state_f<=s4;
	--						led<="00000100";
	--						ban:='1';
	--						keycode_aux<=keycode;	
	--					end if;
	--				when s4=>
	--						state_f<=s5;
	--						ban:='0';
	--						led<="00000101";

							
	--				when s5=>
	--					if rising_edge(flag_x) and keycode/=code_F0 and ban='0' then
	--						state_f<=s6;
	--						led<="00000110";
	--						ban:='1';
	--						keycode_aux<=keycode;
	--					end if;

	--				when s6=>
	--						state_f<=s7;
	--						ban:='0';
	--						led<="00000111";
							
	--				when s7=>
	--					if rising_edge(flag_x) and keycode/=code_F0 and ban='0' then
	--						state_f<=s8;
	--						led<="00001000";
	--						ban:='1';
	--						keycode_aux<=keycode;
	--					end if;
	--				when s8=>
	--						state_f<=s9;
	--						led<="00001000";


	--				when s9=>
	--					if keycode= code_Enter then
	--						if(user11=data11 and user12=data12 and user13=data13 and user14=data14) then
	--							state_f<=s10;
	--							led<="00001001";
	--							user_check<='0';
	--						elsif (user21=data11 and user22=data12 and user23=data13 and user24=data14) then
	--							state_f<=s10;
	--							led<="00001001";
	--							user_check<='1';
	--						else
	--							state_f<=s0;
	--							led<="00000000";
	--						end if;
	--					else
	--						state_f<=s8;
	--						led<="00001000";
	--					end if;

	--				when s10=>
	--					--state_f<=s11;
	--					led<="00001011";

	--				when s11=>
	--				if keycode /= code_F0 then
	--					state_f<=s12;
	--					led<="00001100";
	--				end if;
						

	--				when s13=>
	--					if keycode/=code_F0 then
	--						state_f<=s14;
	--						led<="00001011";

	--					end if;
	--				when s14=>
	--					if keycode= code_F0 then
	--						state_f<=s15;
	--						led<="00001100";	
	--					else
	--						led<="00001011";		
	--					end if;
						
	--				when s15=>	
	--					if keycode/=code_F0 then
	--						state_f<=s16;
	--						led<="00001101";

	--					end if;
	--				when s16=>
	--					if keycode= code_F0 then
	--						state_f<=s17;
	--						led<="00001110";
	--					else
	--						led<="00001101";	
	--					end if;
	--				when s17=>
	--					if keycode/=code_F0 then
	--						state_f<=s18;
	--						led<="00001111";
	--					end if;

	--				when s18=>
	--					if keycode= code_F0 then
	--						state_f<=s19;
	--						led<="00010000";
	--					else
	--						led<="00001111";		
	--					end if;
						
	--				when s19=>
	--					if keycode/=code_F0 then
	--						state_f<=s20;
	--						led<="00010001";
	--					end if;
	--				when s20=>
	--					if keycode= code_F0 then
	--						state_f<=s21;
	--						led<="00010000";
	--					else
	--						led<="00001111";		
	--					end if;

	--				when s21=>
	--					if keycode= code_Enter then
	--						if(code11=data21 and code12=data22 and code13=data23 and code14=data24 and user_check='0') then
	--							state_f<=s18;
	--							led<="00010010";
								
	--						elsif(code21=data21 and code22=data22 and code23=data23 and code24=data24 and user_check='1') then
	--							state_f<=s18;
	--							led<="00010010";
								
	--						else
	--							state_f<=s0;
	--							led<="00000000";
	--						end if;
							
	--					end if;
	--				when s22=>
	--					state_f<=s0;
	--					led<="11111111";
	--				when others=>
	--					state_f<=s0;
	--					led<="11110000";
	--			end case;
			
	--end process;

	--write_data: process(state_p)
	--variable ban: std_logic:='0';
	--begin

	--	case state_p is
	--		when s0=>
	--			ban:='0';
	--			data11<=RESET_DATA;
	--			data12<=RESET_DATA;
	--			data13<=RESET_DATA;
	--			data14<=RESET_DATA;

	--			data21<=RESET_DATA;
	--			data22<=RESET_DATA;
	--			data23<=RESET_DATA;
	--			data24<=RESET_DATA;	
	--		when s2=>
	--			data11<=keycode_aux;
	--		when s4=>
	--			data12<=keycode_aux;
	--		when s6=>
	--			data13<=keycode_aux;
	--		when s8=>
	--			if ban='0' then
	--				data14<=keycode_aux;
	--				ban:='1';
	--			end if;
	--		when s10=>
	--			ban:='0';
	--			if user_check='0' then
	--				data11<=name11;
	--				data12<=name12;
	--				data13<=name13;
	--				data14<=name14;
	--			else 
	--				data11<=name21;
	--				data12<=name22;
	--				data13<=name23;
	--				data14<=name24;
	--			end if;	
	--		when s11=>
	--			data21<=keycode_aux;
	--		when s13=>
	--			data22<=keycode_aux;
	--		when s15=>
	--			data23<=keycode_aux;
	--		when s17=>
	--			data24<=keycode_aux;
			
	--		when others=>
	--	end case;
	--end process;