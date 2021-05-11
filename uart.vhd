-- uart.vhd: UART controller - receiving part
-- Author(s): 
-- Denis Karev (xkarev00@stud.fit.vutbr.cz)
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

-------------------------------------------------
entity UART_RX is
port(	
    CLK: 	    in std_logic;
	RST: 	    in std_logic;
	DIN: 	    in std_logic;
	DOUT: 	    out std_logic_vector(7 downto 0);
	DOUT_VLD: 	out std_logic
);
end UART_RX;  

-------------------------------------------------
architecture behavioral of UART_RX is

signal cnt_clk 	  	: std_logic_vector(4 downto 0);
signal cnt_bit   	: std_logic_vector(3 downto 0);
signal rd_en  		: std_logic;
signal cnt_en 		: std_logic;
signal data_vld 	: std_logic;

begin
	FSM: entity work.UART_FSM(behavioral)
    port map (
        CLK 	    => CLK,
        RST 	    => RST,
        DIN 	    => DIN,
        CNT_CLK 	=> cnt_clk,
        CNT_BIT	 	=> cnt_bit,
		RD_EN		=> rd_en,
		CNT_EN		=> cnt_en,
		DVLD		=> data_vld
    );
	DOUT_VLD <= data_vld;						-- signalize, that data is valid

	process (CLK) begin
		if rising_edge(CLK) then
			if cnt_en = '1' then				-- clock counter is enabled (only while waiting for the first bit or receiveing data)
				cnt_clk <= cnt_clk + '1';
			else
				cnt_clk <= "00000";
			end if;	
		end if;				

		if rd_en = '0' then						-- data is not collected
			cnt_bit <= "0000";					-- set bit counter to zero
		else 
			if cnt_clk(4) = '1' then
				cnt_clk <= "00000";				-- set clock cycle counter 
				DOUT(to_integer(unsigned(cnt_bit))) <= DIN;
				cnt_bit <= cnt_bit + '1';		-- next bit
			end if;	
		end if;
	end process;
end behavioral;
