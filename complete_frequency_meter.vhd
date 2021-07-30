-- Author: Joel Ermantraut
-- Last modified: 30/05/2021
-- Standard Notation:
    -- Upper case for entity in/out's and constants
    -- Lower case for others

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Libraries

entity complete_frequency_meter is
    port(
        PWM_WEB             : in std_logic;
        CLOCK_50            : in std_logic;
        IN_WEB              : in std_logic_vector(0 downto 0); -- RESET
        -- Inputs
        OUT_WEB             : out std_logic_vector(17 downto 0)
        -- Outputs
    );
end entity;

architecture main of complete_frequency_meter is

    component binary_to_bcd is
        port
        (
            -- Inputs
            INIT            : in std_logic;
            MOD_IN          : in std_logic;
            CLOCK_50        : in std_logic;
            -- Outputs
            OUT_WEB         : out std_logic_vector(3 downto 0);
            MOD_OUT         : out std_logic
        );
    end component;

    constant SECOND_CYCLES  : integer := 49999999;
    constant ARRAY_LIMIT    : integer := 16;
    constant ARRAY_UNREACH  : integer := 20;
    -- Constants

    signal init_conv        : std_logic;
    signal bit_input        : std_logic;
    signal bit_out1,
            bit_out2,
            bit_out3,
            bit_out4        : std_logic;
    signal port_out1,
            port_out2,
            port_out3,
            port_out4       : std_logic_vector(3 downto 0);
    -- Component dependencies

    signal reset_counter    : std_logic;
    signal reset_cycles     : std_logic;
    signal cycles           : unsigned(13 downto 0);
    signal copy_cycles      : unsigned(13 downto 0);
    -- Used to measure frequency

    signal prescaler        : unsigned(25 downto 0);
    -- Used to count time

    signal enable_out       : std_logic;
    -- enable to desactivate counting while outputing
    -- enable out to register output

    signal array_index      : unsigned(4 downto 0);

begin

    U0: binary_to_bcd port map(init_conv, bit_input, CLOCK_50, port_out1, bit_out1);
    U1: binary_to_bcd port map(init_conv, bit_out1,  CLOCK_50, port_out2, bit_out2);
    U2: binary_to_bcd port map(init_conv, bit_out2,  CLOCK_50, port_out3, bit_out3);
    U3: binary_to_bcd port map(init_conv, bit_out3,  CLOCK_50, port_out4, bit_out4);
    -- Component instance

    reset_cycles <= reset_counter or IN_WEB(0);
    FREQ_PROC: process(PWM_WEB, reset_cycles)
    begin
        
        if reset_cycles = '1' then
            cycles <= to_unsigned(0, 14);
        elsif (PWM_WEB'event and PWM_WEB = '1') then
            cycles <= cycles + 1;
        end if;

    end process;

    CLK_PROC: process(CLOCK_50, IN_WEB(0), enable_out)
    begin

        if IN_WEB(0) = '1' then
            OUT_WEB <= (others => '0');
            prescaler <= to_unsigned(0, 26);
            copy_cycles <= to_unsigned(0, 14);
            array_index <= to_unsigned(ARRAY_UNREACH, 5);
        elsif (CLOCK_50'event and CLOCK_50 = '1') then

            if enable_out = '1' then
                OUT_WEB(3 downto 0) <= port_out1;
                OUT_WEB(7 downto 4) <= port_out2;
                OUT_WEB(11 downto 8) <= port_out3;
                OUT_WEB(15 downto 12) <= port_out4;
                -- Out register
                OUT_WEB(17 downto 16) <= "00";
                -- Sets to 0 the first (left to right) display
            end if;

            if prescaler < (to_unsigned(SECOND_CYCLES, 26)) then
                -- 50 millions cycles = 1 second
                prescaler <= prescaler + 1;

            else

                if array_index < (to_unsigned(ARRAY_LIMIT, 5)) then
                    array_index <= array_index + 1;
                elsif array_index = (to_unsigned(ARRAY_UNREACH, 5)) then
                    array_index <= to_unsigned(0, 5);

                    copy_cycles <= cycles;
                else
                    prescaler <= to_unsigned(0, 26);

                    array_index <= to_unsigned(ARRAY_UNREACH, 5);
                    -- Sets a number unreachable, to later
                    -- compare and reset counter.
                end if;

            end if;

        end if;

    end process;

    DISP_PROC: process(array_index, copy_cycles)
    begin

        init_conv <= '1';
        enable_out <= '0';

        case array_index(4 downto 0) is
            when "00000" => bit_input <= std_logic(copy_cycles(13));
            when "00001" => bit_input <= std_logic(copy_cycles(12));
            when "00010" => bit_input <= std_logic(copy_cycles(11));
            when "00011" => bit_input <= std_logic(copy_cycles(10));
            when "00100" => bit_input <= std_logic(copy_cycles(9));
            when "00101" => bit_input <= std_logic(copy_cycles(8));
            when "00110" => bit_input <= std_logic(copy_cycles(7));
            when "00111" => bit_input <= std_logic(copy_cycles(6));
            when "01000" => bit_input <= std_logic(copy_cycles(5));
            when "01001" => bit_input <= std_logic(copy_cycles(4));
            when "01010" => bit_input <= std_logic(copy_cycles(3));
            when "01011" => bit_input <= std_logic(copy_cycles(2));
            when "01100" => bit_input <= std_logic(copy_cycles(1));
            when "01101" => bit_input <= std_logic(copy_cycles(0));
            when "01110" =>
                init_conv <= '0';
                enable_out <= '1';
                bit_input  <= '0';
                reset_counter <= '1';
            when others =>
                enable_out <= '0';
                reset_counter <= '0';
                bit_input  <= '0';
        end case;

    end process;

end main;