----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/25/2019 07:52:15 PM
-- Design Name: 
-- Module Name: display_interface - Behavioral
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

entity display_interface is
    Port ( clk, W : in STD_LOGIC;
           WADD : in STD_LOGIC_VECTOR (2 downto 0);
           din : in STD_LOGIC_VECTOR (5 downto 0);
           e : out STD_LOGIC_VECTOR (7 downto 0);
           c : out STD_LOGIC_VECTOR (6 downto 0);
           dp : out STD_LOGIC);
end display_interface;

architecture Behavioral of display_interface is
    
    -- 3x8 Input decoder signals
    signal y : std_logic_vector (7 downto 0);
    
    -- Register signals
    type register_type is array (0 to 7) of std_logic_vector (5 downto 0);
    signal reg : register_type := (others => "000000");
    
    -- Multiplexer signals
    signal s : std_logic_vector (2 downto 0);
    signal dout : std_logic_vector (5 downto 0);
    
    -- 20-bit Counter signals
    signal counter : unsigned (19 downto 0) := to_unsigned(0,20);
    
    -- 3x8 Anode decoder signals
    -- decoder uses e for output, no intermediate signals needed
    
    -- Binary to seven-segment display decoder
    -- decoder uses c for ouput, no intermediate signals needed
    
begin
    
    -- 3x8 Input Decoder ---------------
    process (W, WADD) begin
        if (W = '1') then
            case WADD is
                when "000" =>
                    y <= "00000001";
                when "001" =>
                    y <= "00000010";
                when "010" =>
                    y <= "00000100";
                when "011" =>
                    y <= "00001000";
                when "100" =>
                    y <= "00010000";
                when "101" =>
                    y <= "00100000";
                when "110" =>
                    y <= "01000000";
                when "111" =>
                    y <= "10000000";
                when others =>
                    y <= "00000000";
            end case;
        else
            y <= "00000000";
        end if;
    end process;
    ------------------------------------
    
    -- Registers -----------------------
    process (clk) begin
        if (rising_edge(clk)) then
            case y is
                when "10000000" =>
                    reg(7) <= din;
                when "01000000" =>
                    reg(6) <= din;
                when "00100000" =>
                    reg(5) <= din;
                when "00010000" =>
                    reg(4) <= din;
                when "00001000" =>
                    reg(3) <= din;
                when "00000100" =>
                    reg(2) <= din;
                when "00000010" =>
                    reg(1) <= din;
                when "00000001" =>
                    reg(0) <= din;
                when "00000000" =>
                    reg <= reg;
                when others =>
                    reg <= reg;
            end case;
        end if;
    end process;
    ------------------------------------
    
    -- Multiplexer ---------------------
    process (reg, s) begin
        case s is
            when "000" =>
                dout <= reg(0);
            when "001" =>
                dout <= reg(1);
            when "010" =>
                dout <= reg(2);
            when "011" =>
                dout <= reg(3);
            when "100" =>
                dout <= reg(4);
            when "101" =>
                dout <= reg(5);
            when "110" =>
                dout <= reg(6);
            when "111" =>
                dout <= reg(7);
            when others =>
                dout <= "ZZZZZZ";
        end case;
    end process;
    ------------------------------------
    
    -- 20-bit Counter ------------------
    process (clk) begin
        if (rising_edge(clk)) then
            if (counter = "11111111111111111111") then
                counter <= to_unsigned(0,20);
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;
    
    s <= std_logic_vector(counter(19 downto 17));
    ------------------------------------
    
    -- 3x8 Anode decoder ---------------
    process (s) begin
        case s is
            when "000" =>
                e <= "11111110";
            when "001" =>
                e <= "11111101";
            when "010" =>
                e <= "11111011";
            when "011" =>
                e <= "11110111";
            when "100" =>
                e <= "11101111";
            when "101" =>
                e <= "11011111";
            when "110" =>
                e <= "10111111";
            when "111" =>
                e <= "01111111";
            when others =>
                e <= "11111111";
        end case;
    end process;
    ------------------------------------
    
    -- Binary to seven-segment display decoder
    process (dout(5 downto 1)) begin
        if (dout(5) = '1') then
            case dout(4 downto 1) is
                when "0000" =>
                    c <= "1000000";
                when "0001" =>
                    c <= "1111001";
                when "0010" =>
                    c <= "0100100";
                when "0011" =>
                    c <= "0110000";
                when "0100" =>
                    c <= "0011001";
                when "0101" =>
                    c <= "0010010";
                when "0110" =>
                    c <= "0000010";
                when "0111" =>
                    c <= "1111000";
                when "1000" =>
                    c <= "0000000";
                when "1001" =>
                    c <= "0010000";
                when others =>
                    c <= "1111111";
            end case;
        else
            c <= "1111111";
        end if;
    end process;
    ------------------------------------
    
    -- tie dp output
    dp <= not dout(0);
    
end Behavioral;
