library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity B2BCD is
    Port ( clk : in STD_LOGIC;
           B : in STD_LOGIC_VECTOR (9 downto 0);
           BCD : out STD_LOGIC_VECTOR (11 downto 0));
end B2BCD;

architecture Behavioral of B2BCD is
    -- Register signals
    signal r : std_logic_vector (9 downto 0);
    
    -- 3-bit counter signals
    signal counter : std_logic_vector (3 downto 0);
    
    -- State machine signals
    type state is (s0, s1, s2, s3);
    signal PS, NS : state;
    signal z, c3, c2, c1, c0 : std_logic;
    
    -- Shift register signals
    constant three : unsigned (3 downto 0) := to_unsigned(3, 4);
    signal d0, d1, d2 : std_logic_vector (3 downto 0);
    signal l0, l1 : std_logic;
    signal comp0, comp1 :std_logic;
    signal sum0, sum1 : std_logic_vector (3 downto 0);
    
    -- BCD registers
    signal BCD_internal : std_logic_vector (11 downto 0);
    
begin
    -- Register
    process (clk) begin
        if (rising_edge(clk)) then
            if (c0 = '1') then
                r <= b;
            elsif (c1 = '1') then
                r <= r(8 downto 0) & '0';
            else
                r <= r;
            end if;
        end if;
    end process;
    
    -- 3-bit counter
    process (clk) begin
        if (rising_edge(clk)) then
            if (c0 = '1') then
                counter <= "1001";
            elsif (c1 = '1') then
                counter <= std_logic_vector(unsigned(counter) - 1);
            else
                counter <= counter;
            end if;
        end if;
    end process;
    
    z <= '1' when (counter = "0000") else '0';
    
    -- State machine
    process (clk) begin
        if (rising_edge(clk)) then
            PS <= NS;
        end if;
    end process;
    
    process (PS, Z) begin
        c3 <= '0'; c2 <= '0'; c1 <= '0'; c0 <= '0';
        case (PS) is
            when S0 =>
                NS <= S1;
                c0 <= '1';
            when S1 =>
                NS <= S2;
                c2 <= '1';
            when S2 =>
                if (z = '1') then
                    NS <= S3;
                    c1 <= '1';
                else
                    NS <= S1;
                    c1 <= '1';
                end if;
            when S3 =>
                NS <= S0;
                c3 <= '1';
        end case;
    end process;
    
    -- Shift registers
    process (clk) begin
        if (rising_edge(clk)) then
            -- Least significant
            if (c1 = '1') then
                d0 <= d0(2 downto 0) & r(9);
            elsif (c0 = '1') then
                d0 <= "0000";
            elsif (l0 = '1') then
                d0 <= sum0;
            else
                d0 <= d0;
            end if;
            -- Middle
            if (c1 = '1') then
                d1 <= d1(2 downto 0) & d0(3);
            elsif (c0 = '1') then
                d1 <= "0000";
            elsif (l1 = '1') then
                d1 <= sum1;
            else
                d1 <= d1;
            end if;
            -- Most significant
            if (c1 = '1') then
                d2 <= d2(2 downto 0) & d1(3);
            elsif (c0 = '1') then
                d2 <= "0000";
            else
                d2 <= d2;
            end if;
        end if ;
    end process;
    
    -- Supplemental circuitry for shift registers
    comp0 <= '1' when (unsigned(d0) > to_unsigned(4,4)) else '0';
    comp1 <= '1' when (unsigned(d1) > to_unsigned(4,4)) else '0';
    l0 <= comp0 and c2;
    l1 <= comp1 and c2;
    sum0 <= std_logic_vector(unsigned(d0) + three);
    sum1 <= std_logic_vector(unsigned(d1) + three);
    
    -- BCD registers
    process (clk) begin
        if (rising_edge(clk)) then
            if (c3 = '1') then
                BCD_internal(11 downto 8) <= d2;
                BCD_internal(7 downto 4) <= d1;
                BCD_internal(3 downto 0) <= d0;
            else
                BCD_internal <= BCD_internal;
            end if;
        end if;
    end process;
    
    BCD <= BCD_internal;
    
end Behavioral;