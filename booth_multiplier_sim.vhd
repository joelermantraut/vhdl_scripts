---- Author: Joel Ermantraut
---- Last modified: 30/05/2021
---- Standard Notation:
--    -- Upper case for entity in/out's and constants
--    -- Lower case for others

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Libraries

entity booth_multiplier_sim is
    generic(
        N           : integer := 4
        );
end entity;

architecture main of booth_multiplier_sim is

    signal IN_WEB           : std_logic_vector((N * 2 - 1) downto 0);
    signal CLOCK_50         : std_logic := '0';
    signal START            : std_logic;
    signal END_P            : std_logic;
    signal RESULT           : std_logic_vector(7 downto 0);
    -- Booth multiplier component

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

begin

    U0: booth_multiplier port map(IN_WEB, CLOCK_50, START, END_P, RESULT);

    -- synthesis translate off

    CLOCK_50 <= not CLOCK_50 after 25 ps; -- 50ns period clock

    STIMULUS: process
        begin
        for i in 15 downto 0 loop
            IN_WEB(3 downto 0) <= std_logic_vector(to_unsigned(i, 4));
            for j in 15 downto 0 loop
                IN_WEB(7 downto 4) <= std_logic_vector(to_unsigned(j, 4));
                START <= '0', '1' after 50 ps, '0' after 100 ps;
                wait until END_P = '1';
                assert (to_integer(unsigned(RESULT)) = (i * j))
                    report "Incorrect product"
                    severity Error;
            end loop;
        end loop;

    end process STIMULUS;

    -- synthesis translate on

end main;
