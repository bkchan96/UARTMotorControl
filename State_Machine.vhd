----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/23/2019 10:43:53 PM
-- Design Name: 
-- Module Name: State_Machine - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Drive_Motor_State_Machine is
    Port ( clk, reset : in std_logic;
           rx_done_bit : in std_logic; -- rx done bit (goes high for only 1 clock cycle)
           rx_data : in std_logic_vector (7 downto 0); -- rx data in
           FMAB : out std_logic_vector (1 downto 0); -- front motor AB logic
           AMAB : out std_logic_vector (1 downto 0); -- aft motor AB logic
           FMPWM : out std_logic_vector (15 downto 0); -- front motor pwm value
           AMPWM : out std_logic_vector (15 downto 0) -- rear motor pwm value
           );
end Drive_Motor_State_Machine;

architecture Behavioral of Drive_Motor_State_Machine is
    -- registers for holding transmitted data
    signal r0, r1, r2, r3, r4, r5 : std_logic_vector (7 downto 0);
    constant zero8 : std_logic_vector (7 downto 0) := "00000000";
    
    -- internal output registers
    signal FMAB_internal  : std_logic_vector (1 downto 0);
    signal AMAB_internal  : std_logic_vector (1 downto 0);
    signal FMPWM_internal : std_logic_vector (15 downto 0);
    signal AMPWM_internal : std_logic_vector (15 downto 0);
    
    -- rx state machine signals
    type state is (s0, s1, s2, s3, s4, s5, s6);
    signal PS : state := s0;
    signal NS : state;
    
    -- output state machine logic
    signal comm_done : std_logic;
    
begin
    -- rx state machine sequential logic
    process (clk) begin
        if (reset = '1') then
            PS <= s0; -- reset state
            r0 <= zero8; r1 <= zero8; r2 <= zero8; -- reset all registers
            r3 <= zero8; r4 <= zero8; r5 <= zero8;
        elsif rising_edge(clk) then
            PS <= NS;
        end if;
    end process;
    
    -- rx state machine combinational logic
    process (PS, rx_done_bit, rx_data) begin
        case (PS) is
            when s0 => -- resting state, waiting for start byte
                comm_done <= '0';
                if (rx_done_bit = '1') then
                    r0 <= rx_data; -- save start byte and move to next state
                    NS <= s1;
                else
                    NS <= s0;
                end if;
            when s1 => -- waiting for header byte
                comm_done <= '0';
                if (rx_done_bit = '1') then
                    r1 <= rx_data; -- save header byte and move to next state
                    NS <= s2;
                else
                    NS <= s1;
                end if;
            when s2 => -- waiting for ID byte
                comm_done <= '0';
                if (rx_done_bit = '1') then
                    r2 <= rx_data; -- save ID byte and move to next state
                    NS <= s3;
                else
                    NS <= s2;
                end if;
            when s3 => -- waiting for data high byte
                comm_done <= '0';
                if (rx_done_bit = '1') then
                    r3 <= rx_data; -- save data high byte and move to next state
                    NS <= s3;
                else
                    NS <= s2;
                end if;
            when s4 => -- waiting for data low byte
                comm_done <= '0';
                if (rx_done_bit = '1') then
                    r4 <= rx_data; -- save data low byte and move to next state
                    NS <= s4;
                else
                    NS <= s3;
                end if;
            when s5 => -- waiting for stop byte
                comm_done <= '0';
                if (rx_done_bit = '1') then
                    r5 <= rx_data; -- save data high byte and move to next state
                    NS <= s6;
                else
                    NS <= s5;
                end if;
            when s6 => -- reset registers and reset state machine
                comm_done <= '1';
                NS <= s0;
                r0 <= zero8; r1 <= zero8; r2 <= zero8;
                r3 <= zero8; r4 <= zero8; r5 <= zero8;
        end case;
    end process;
    
    -- output state machine
    process (clk) begin
        if rising_edge(clk) then
            if (comm_done = '1') then
                
            end if;
        end if;
    end process;
    
    
end Behavioral;
