-- uart_fsm.vhd: UART controller - finite state machine
-- Author(s):
-- Denis Karev (xkarev00@stud.fit.vutbr.cz)
library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------
entity UART_FSM is
port(
   CLK      : in std_logic;
   RST      : in std_logic;
   DIN      : in std_logic;
   CNT_CLK  : in std_logic_vector(4 downto 0);
   CNT_BIT  : in std_logic_vector(3 downto 0);
   RD_EN    : out std_logic;
   CNT_EN   : out std_logic;
   DVLD     : out std_logic
   );
end entity UART_FSM;

-------------------------------------------------
architecture behavioral of UART_FSM is
type state is (WAIT_START_BIT, WAIT_FIRST_BIT, RECEIVE_DATA, WAIT_STOP_BIT, DATA_VALID);
signal current_state : state := WAIT_START_BIT;
begin
   RD_EN    <= '1' when current_state = RECEIVE_DATA else '0';
   CNT_EN   <= '1' when current_state = WAIT_FIRST_BIT or current_state = RECEIVE_DATA else '0'; 
   DVLD     <= '1' when current_state = DATA_VALID else '0'; 

   process (CLK) begin
      if rising_edge(CLK) then
         if RST = '1' then
            current_state <= WAIT_START_BIT;
         else
            case current_state is
               when WAIT_START_BIT => 
                  if DIN = '0' then 
                     current_state <= WAIT_FIRST_BIT;
                  end if;                  
               when WAIT_FIRST_BIT => 
                  if CNT_CLK = "11000" then 
                     current_state <= RECEIVE_DATA;
                  end if;
               when RECEIVE_DATA =>
                  if CNT_BIT = "1000" then
                     current_state <= WAIT_STOP_BIT;
                  end if;
               when WAIT_STOP_BIT =>
                  if DIN = '1' then
                     current_state <= DATA_VALID;
                  end if;
               when DATA_VALID =>
                  current_state <= WAIT_START_BIT;
               when others => null;
            end case;
         end if;
      end if;
   end process;
end behavioral;
