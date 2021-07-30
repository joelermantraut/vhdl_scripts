library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity complete_binary is
	port(
		CLOCK_50:		in std_logic;
		IN_WEB:			in std_logic_vector(0 downto 0); -- RESET
		OUT_WEB: 		out std_logic_vector(17 downto 0)
	);
end entity;

architecture main of complete_binary is

	component binary_to_bcd is
		port
		(
			-- Inputs
			INIT			: in std_logic;
			MOD_IN			: in std_logic;
			CLOCK_50		: in std_logic;
			-- Outputs
			OUT_WEB		: out std_logic_vector(3 downto 0);
			MOD_OUT		: out std_logic
		);
	end component;

	constant CYCLES	: integer := 49999999;
	constant MAX_COUNT: integer := 39999;
	-- Constants
	
	signal	aux		: unsigned(15 downto 0);
	-- Kind of flag to add decimal counter
	
	signal init_conv	: std_logic;
	signal bit_input	: std_logic;
	signal bit_out1, bit_out2, bit_out3, bit_out4, bit_out5: std_logic;
	signal port_out1, port_out2, port_out3, port_out4, port_out5: std_logic_vector(3 downto 0);
	-- Component dependencies
	
	signal enable_out		: std_logic;
	signal prescaler		: unsigned(25 downto 0);
	-- FLAGs
	
begin

	U0: binary_to_bcd port map(init_conv, bit_input, CLOCK_50, port_out1, bit_out1);
	U1: binary_to_bcd port map(init_conv, bit_out1, CLOCK_50, port_out2, bit_out2);
	U2: binary_to_bcd port map(init_conv, bit_out2, CLOCK_50, port_out3, bit_out3);
	U3: binary_to_bcd port map(init_conv, bit_out3, CLOCK_50, port_out4, bit_out4);
	U4: binary_to_bcd port map(init_conv, bit_out4, CLOCK_50, port_out5, bit_out5);
	-- Component instance
			
	process(prescaler)
	begin
	
		init_conv <= '1';
		enable_out <= '0';
	
		case prescaler(4 downto 0) is
			when "00000" => bit_input <= std_logic(aux(15));
			when "00001" => bit_input <= std_logic(aux(14));
			when "00010" => bit_input <= std_logic(aux(13));
			when "00011" => bit_input <= std_logic(aux(12));
			when "00100" => bit_input <= std_logic(aux(11));
			when "00101" => bit_input <= std_logic(aux(10));
			when "00110" => bit_input <= std_logic(aux(9));
			when "00111" => bit_input <= std_logic(aux(8));
			when "01000" => bit_input <= std_logic(aux(7));
			when "01001" => bit_input <= std_logic(aux(6));
			when "01010" => bit_input <= std_logic(aux(5));
			when "01011" => bit_input <= std_logic(aux(4));
			when "01100" => bit_input <= std_logic(aux(3));
			when "01101" => bit_input <= std_logic(aux(2));
			when "01110" => bit_input <= std_logic(aux(1));
			when "01111" => bit_input <= std_logic(aux(0));
			when "10000" =>
				init_conv <= '0';
				enable_out <= '1';
				bit_input <= '0';
			when others =>
				enable_out <= '0';
				bit_input <= '0';
		end case;
	
	end process;
	
	process(CLOCK_50)
	begin
	
		if (IN_WEB(0)='1') then
			-- Reset state
			prescaler <= to_unsigned(0, 26);
			aux <= to_unsigned(0, 16);
		elsif (CLOCK_50'event and CLOCK_50='1') then
		
			if enable_out='1' then
				OUT_WEB(3 downto 0) <= port_out1;
				OUT_WEB(7 downto 4) <= port_out2;
				OUT_WEB(11 downto 8) <= port_out3;
				OUT_WEB(15 downto 12) <= port_out4;
				OUT_WEB(17 downto 16) <= port_out5(1 downto 0);
				-- Out register
			end if;

			if prescaler < (to_unsigned(CYCLES, 26)) then
				-- 50 millions cycles = 1 second
				prescaler<= prescaler+1;
			else
				-- When reaches a second
				if aux < (to_unsigned(MAX_COUNT, 16)) then
					-- There are five displays, with the first limited to three numbers
					-- So total limit is 39999
					aux <= aux + 1;
				else
					aux <= to_unsigned(0, 16);
				end if;
				
				prescaler<= to_unsigned(0, 26);
			end if;
		
		end if;
	
	end process;

end main;