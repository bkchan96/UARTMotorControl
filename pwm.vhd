----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/20/2019 01:31:02 PM
-- Design Name: 
-- Module Name: pwm - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pwm is
    Port ( clk, reset : in STD_LOGIC;
           pw : in STD_LOGIC_VECTOR (7 downto 0);
           pwm : out STD_LOGIC);
end pwm;

architecture Behavioral of pwm is

    -- declare constants for loading
    constant delay_counter_max : unsigned (6 downto 0) := to_unsigned(77, 7);
    constant zero : unsigned (7 downto 0) := to_unsigned(0, 8);
    constant period_counter_max : unsigned (7 downto 0) := to_unsigned(255, 8);
    
    -- declare counter values
    signal delay_counter : unsigned (6 downto 0) := delay_counter_max;
    signal period_counter : unsigned (7 downto 0) := zero;
    
begin
    
    -- delay counter
    process (clk, reset) begin
        if (rising_edge(clk)) then
            if (reset = '1') then
                delay_counter <= delay_counter_max;
            elsif (delay_counter = zero) then
                delay_counter <= delay_counter_max;
            else
                delay_counter <= delay_counter - 1;
            end if;
        end if;
    end process;
    
    -- period counter
    process (clk, reset) begin
        if (rising_edge(clk)) then
            if (reset = '1') then
                period_counter <= zero;
            elsif (period_counter = period_counter_max and delay_counter = zero) then
                period_counter <= zero;
            elsif (delay_counter = zero) then
                period_counter <= period_counter + 1;
            end if;
        end if;
    end process;
    
    -- comparator
    pwm <= '1' when (unsigned(pw) >= period_counter) else '0';
    
end Behavioral;
