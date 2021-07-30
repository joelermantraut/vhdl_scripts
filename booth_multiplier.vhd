---- Author: Joel Ermantraut
---- Last modified: 16/05/2021
---- Standard Notation:
--    -- Upper case for entity in/out's and constants
--    -- Lower case for others

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Libraries

entity booth_multiplier is
    generic(
        N           : integer := 4;
        M           : integer := 4 
        );

    port(
        IN_WEB      : in std_logic_vector((2 * N - 1) downto 0);
        CLOCK_50    : in std_logic;
        START       : in std_logic;
        -- Inputs
        END_P       : out std_logic;
        RESULT      : out std_logic_vector((2 * N - 1) downto 0)
        -- Outputs
        );
end entity;

architecture main of booth_multiplier is

    signal a                : signed((2 * N) downto 0);
    signal s                : signed((2 * N) downto 0);
    signal p                : signed((2 * N) downto 0);
    signal p_int            : signed((2 * N) downto 0);
    signal i                : signed(N - 1 downto 0);
    signal end_signal       : std_logic;

begin

    p_int <= p + s when p(1 downto 0) = "10" else
             p + a when p(1 downto 0) = "01" else
             p;

    a(8 downto 5) <= signed(IN_WEB(7 downto 4));
    a(4 downto 0) <= to_signed(0, 5);

    s(8 downto 5) <= (not signed(IN_WEB(7 downto 4))) + 1; -- Complementary
    s(4 downto 0) <= to_signed(0, 5);

    RESULT <= std_logic_vector(p(8 downto 1)) when end_signal = '1' else
                (others => '0');
    END_P <= '1' when end_signal = '1' else '0';

    I_PROC: process(CLOCK_50)
    begin

        if (CLOCK_50'event and CLOCK_50 = '1') then

            if START = '1' then
                i <= to_signed(0, N);
            else
                if i < to_signed(M, N) then
                    i <= i + 1;
                else
                    i <= i;
                end if;
            end if;

        end if;

    end process;
    -- I register process

    P_PROC: process(CLOCK_50)
    begin

        if (CLOCK_50'event and CLOCK_50 = '1') then

            if START = '1' then
                p(8 downto 5) <= to_signed(0, 4);
                p(4 downto 1) <= signed(IN_WEB(3 downto 0));
                p(0 downto 0) <= to_signed(0, 1);
                end_signal <= '0';
            else
                if i < to_signed(M, N) then
                    p <= p_int(p'left) & p_int(p'left downto 1);
                    -- Shift registers and copies last bit
                else
                    end_signal <= '1';
                end if;
            end if;

        end if;

    end process;
    -- P register process

end main;