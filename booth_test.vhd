---- Author: Joel Ermantraut
---- Last modified: 16/05/2021
---- Standard Notation:
--    -- Upper case for entity in/out's and constants
--    -- Lower case for others

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Libraries

entity booth_test is
    generic(
        N           : integer := 4
        );

    port(
        IN_WEB      : in std_logic_vector((2 * N - 1) downto 0);
        CLOCK_50    : in std_logic;
        -- Inputs
        OUT_WEB     : out std_logic_vector((2 * N - 1) downto 0)
        -- Outputs
        );
end entity;

architecture main of booth_test is

    component booth_multiplier is
        generic(
            N           : integer := 4
            );

        port(
            IN_WEB      : in std_logic_vector((N * 2 - 1) downto 0);
            CLOCK_50    : in std_logic;
            START       : in std_logic;
            -- Inputs
            END_P       : out std_logic;
            RESULT      : out std_logic_vector(7 downto 0)
            -- Outputs
            );
    end component;
    -- Components

	constant CYCLES	: integer := 49;
    -- Constants

    signal prescaler	: unsigned(25 downto 0);
    signal start_booth  : std_logic;
    signal end_booth	: std_logic;
    signal result_booth : std_logic_vector(7 downto 0);
    -- Signals

begin

	U0: booth_multiplier port map(IN_WEB, CLOCK_50, start_booth, end_booth, result_booth);

	PRES_PROC: process(CLOCK_50)
	begin

        if (CLOCK_50'event and CLOCK_50 = '1') then

        	if prescaler < to_unsigned(CYCLES, 26) then
        		prescaler <= prescaler + 1;

        		start_booth <= '1';
        	else
        		start_booth <= '0';

        		if end_booth = '1' then
	        		prescaler <= to_unsigned(0, 26);

	        		OUT_WEB <= result_booth;
        		end if;
        	end if;

        end if;

	end process;

end main;