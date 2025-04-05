library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.util.all;

entity stack is
    -- generic (
    --     STACK_DEPTH : integer
    -- );
    port (
        clk_in       : in std_logic;
        enable       : in std_logic;
        push_pop_sel : in std_logic;
        reset        : in std_logic;
        data_in      : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        data_out     : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end entity stack;

architecture Behavioral of stack is
    type reg_array is array (0 to STACK_DEPTH-1) 
                      of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal regs : reg_array;
    signal sp   : integer range 0 to STACK_DEPTH-1;
begin

    process(all) begin
        if reset = '1' then
            sp <= 0;
            regs <= (others => (others => '0'));
        elsif rising_edge(clk_in) then
            if enable = '1' then
                if push_pop_sel = '1' then
                    sp <= sp + 1;
                    regs(2) <= data_in;
                else
                    sp <= sp - 1;
                end if;
            end if;
        end if;
    end process;

    data_out <= regs(2);

end Behavioral;