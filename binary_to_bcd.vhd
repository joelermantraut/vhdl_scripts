library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity binary_to_bcd is
	port
	(
		-- Inputs
		INIT			: in std_logic;
		MOD_IN		: in std_logic;
		CLOCK_50		: in std_logic;
		-- Outputs
		OUT_WEB		: out std_logic_vector(3 downto 0);
		MOD_OUT		: out std_logic
	);
end binary_to_bcd;

architecture main of binary_to_bcd is

	signal Q					 : std_logic_vector(3 downto 0);
	signal MOD_OUT_AUX	 : std_logic;

begin
	CONV_FUNC: process(CLOCK_50)
	begin
	
		if (CLOCK_50'event and CLOCK_50='1') then

			if MOD_OUT_AUX='1' then
				Q(3) <= (Q(0) and Q(3)) and INIT;
				Q(2) <= not(Q(0) xor Q(1)) and INIT;
				Q(1) <= not(Q(0)) and INIT;
			else	
				Q(3) <= Q(2) and INIT;
				Q(2) <= Q(1) and INIT;
				Q(1) <= Q(0) and INIT;
			end if;
						
			Q(0) <= MOD_IN;
		
		end if;

	end process CONV_FUNC;
	
	MOD_PROC: process(Q)
	begin
	
		case Q is
			when "0000" | "0001" | "0010" | "0011" | "0100" =>
				MOD_OUT_AUX <= '0' and INIT;
			when others =>
				MOD_OUT_AUX <= '1' and INIT;
		end case;
	
	end process MOD_PROC;
	
	OUT_WEB <= Q;
	MOD_OUT <= MOD_OUT_AUX;

end main;