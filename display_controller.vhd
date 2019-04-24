library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity display_controller is
    Port ( clk : in STD_LOGIC;
           bcd : in STD_LOGIC_VECTOR (11 downto 0);
           w : out STD_LOGIC;
           wadd : out STD_LOGIC_VECTOR (2 downto 0);
           din : out STD_LOGIC_VECTOR (5 downto 0));
end display_controller;

architecture Behavioral of display_controller is
    -- First mux signals
    signal M : std_logic_vector (3 downto 0);
    signal s : std_logic_vector (1 downto 0);
    
    -- Counter signals
    signal wadd_internal : unsigned (2 downto 0) := "111";
    signal Z, C0, C1 : std_logic;
    
    -- Comparator signals
    signal L : std_logic;
    
    -- State machine signals
    type state is (S0, S1);
    signal PS, NS : state := S0;
begin
    -- Counter
    process (clk) begin
        if (rising_edge(clk)) then
            if (C0 = '1') then
                wadd_internal <= "111";
            elsif (C1 = '1') then
                wadd_internal <= wadd_internal - 1;
            end if;
        end if;
    end process;
    
    wadd <= std_logic_vector(wadd_internal);
    s <= std_logic_vector(wadd_internal(1 downto 0));
    Z <= '1' when (wadd_internal = "000") else '0';
    
    -- 4 to 1 mux
    M <= bcd(3 downto 0) when (s = "00") else
         bcd(7 downto 4) when (s = "01") else
         bcd(11 downto 8) when (s = "10") else
         "0000";
    
    -- Comparator
    L <= '1' when (wadd_internal < "011") else '0';
    
    -- 2 to 1 mux
    din <= "000000" when (L = '0') else ('1' & M & '0');
    
    -- State Machine
    process (clk) begin
        if (rising_edge(clk)) then
            PS <= NS;
        end if;
    end process;
    
    process (PS, Z) begin
        w <= '0'; C0 <= '0'; C1 <= '0';
        case (PS) is
            when S0 =>
                NS <= S1;
                C0 <= '1';
            when S1 =>
                if (Z = '1') then
                    NS <= S0;
                    w <= '1';
                else
                    NS <= S1;
                    w <= '1';
                    C1 <= '1';
                end if;
        end case;
    end process;
    
end Behavioral;