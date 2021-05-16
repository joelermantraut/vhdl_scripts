entity decoder is
	port
	(
		-- Input ports
		IN_WEB		: in bit_vector(2 downto 0);
		-- Output ports
		OUT_WEB		: out bit_vector(7 downto 0)
	);
end decoder;


-- Library Clause(s) (optional)
-- Use Clause(s) (optional)

architecture A1 of decoder is

	-- Declarations (optional)

begin

	DECODE_FUNC: process(IN_WEB)
	begin
		OUT_WEB <= (others => '0');
	
		if IN_WEB(0)='0' and IN_WEB(1)='0' and IN_WEB(2)='0' then
			OUT_WEB(0) <= '1';
		elsif IN_WEB(0)='1' and IN_WEB(1)='0' and IN_WEB(2)='0' then
			OUT_WEB(1) <= '1';
		elsif IN_WEB(0)='0' and IN_WEB(1)='1' and IN_WEB(2)='0' then
			OUT_WEB(2) <= '1';
		elsif IN_WEB(0)='1' and IN_WEB(1)='1' and IN_WEB(2)='0' then
			OUT_WEB(3) <= '1';
		elsif IN_WEB(0)='0' and IN_WEB(1)='0' and IN_WEB(2)='1' then
			OUT_WEB(4) <= '1';
		elsif IN_WEB(0)='1' and IN_WEB(1)='0' and IN_WEB(2)='1' then
			OUT_WEB(5) <= '1';
		elsif IN_WEB(0)='0' and IN_WEB(1)='1' and IN_WEB(2)='1' then
			OUT_WEB(6) <= '1';
		elsif IN_WEB(0)='1' and IN_WEB(1)='1' and IN_WEB(2)='1' then
			OUT_WEB(7) <= '1';
		end if;
			
	end process DECODE_FUNC;

end A1;
