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
--use IEEE.NUMERIC_STD.ALL;

entity State_Machine is
    Port ( clk, reset : in std_logic;
           rx_done_bit : in std_logic; -- rx done bit (goes high for only 1 clock cycle)
           rx_data : in std_logic_vector (7 downto 0); -- rx data in
           FMAB : out std_logic_vector (1 downto 0); -- front motor AB logic
           AMAB : out std_logic_vector (1 downto 0); -- aft motor AB logic
           MPWM : out std_logic_vector (7 downto 0) -- motor pwm value
           );
end State_Machine;

architecture Behavioral of State_Machine is
    -- internal output registers
    signal MPWM_internal : std_logic_vector (7 downto 0);
    
begin
    -- start process for receiving data and writing to output pwm
    process (clk, reset) begin
        if (reset = '1') then
            MPWM_internal <= "00000000";
        elsif rising_edge(clk) then
            if (rx_done_bit = '1') then
                MPWM_internal <= rx_data;
            else
                MPWM_internal <= MPWM_internal;
            end if;
        end if;
    end process;
    
    -- start process for brake and direction logic
    process (MPWM_internal) begin
        if (MPWM_internal = "00000000") then
            FMAB <= "00";
            AMAB <= "00";
        else
            FMAB <= "01";
            AMAB <= "10";
        end if;
    end process;
    
    -- tie output
    MPWM <= MPWM_internal;
    
end Behavioral;
