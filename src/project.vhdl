library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.util.all;

entity tt_um_stack_machine is
    port (
        ui_in   : in  std_logic_vector(7 downto 0);
        uo_out  : out std_logic_vector(7 downto 0);
        uio_in  : in  std_logic_vector(7 downto 0);
        uio_out : out std_logic_vector(7 downto 0);
        uio_oe  : out std_logic_vector(7 downto 0);
        ena     : in  std_logic;
        clk     : in  std_logic;
        rst_n   : in  std_logic
    );

    -- constant PP_POP    : std_logic := 0;
    -- constant PP_PUSH   : std_logic := 1;
    -- constant STACK_OFF : std_logic := 0;
    -- constant STACK_ON  : std_logic := 1;
    -- constant CARRY_OFF : std_logic := 0;
    -- constant CARRY_ON  : std_logic := 1;
    -- constant ACC_OFF   : std_logic := 0;
    -- constant ACC_ON    : std_logic := 1;
end tt_um_stack_machine;

architecture Behavioral of tt_um_stack_machine is
    signal state        : state_type;
    signal stack_value  : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal ir           : std_logic_vector(6 downto 0);
    signal deposit1     : std_logic;
    signal deposit2     : std_logic;
    signal stack_enable : std_logic;
    signal push_pop_sel : std_logic;

    signal alu_func     : std_logic_vector(3 downto 0);
    signal alu_out      : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal carry        : std_logic;
    signal carry_next   : std_logic;
    signal load_carry   : std_logic;

    signal acc          : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal load_acc     : std_logic;

    signal data_bus_sel : bus_sel_type;
    signal data_bus     : std_logic_vector(DATA_WIDTH-1 downto 0);

    --alias  ir_op        : std_logic_vector(2 downto 0) is ir(6 downto 4);
    --alias  ir_arg       : std_logic_vector(DATA_WIDTH-1 downto 0) is ir(3 downto 0);
    component stack
    -- generic (
    --     STACK_DEPTH : integer
    -- );
    port (
        clk_in       : in  std_logic;
        enable       : in  std_logic;
        push_pop_sel : in  std_logic;
        reset        : in  std_logic;
        data_in      : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        data_out     : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
    end component stack;

    component alu
    port (
        func_in   : in  std_logic_vector(3 downto 0);
        op1_in    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        op2_in    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        carry_in  : in  std_logic;
        carry_out : out std_logic;
        data_out  : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
    end component alu;

begin

    -- We don't really care
    uio_oe  <= "--------";
    uio_out <= "--------";  

    -- Instantiate stack
    stack_inst: stack
        -- generic map(
        --     STACK_DEPTH => 8
        -- )
        port map (
            clk_in       => clk,
            enable       => stack_enable,
            push_pop_sel => push_pop_sel,
            reset        => rst_n,
            data_in      => data_bus,
            data_out     => stack_value
        );

    -- Instantiate ALU
    alu_inst: alu
        port map (
            func_in   => alu_func,
            op1_in    => data_bus,
            op2_in    => acc,
            carry_in  => carry,
            carry_out => carry_next,
            data_out  => alu_out
        );

    -- Handle 7-segment display
    with stack_value(3 downto 0) select uo_out(0 to 6) <=
        "1111110" when 0x"0",
        "0110000" when 0x"1",
        "1101101" when 0x"2",
        "1111001" when 0x"3",
        "0110011" when 0x"4",
        "1011011" when 0x"5",
        "1011111" when 0x"6",
        "1110000" when 0x"7",
        "1111111" when 0x"8",
        "1111011" when 0x"9",
        "1110111" when 0x"A",
        "0011110" when 0x"b",
        "1001110" when 0x"C",
        "0111101" when 0x"d",
        "1001111" when 0x"E",
        "1000111" when 0x"F";

    uo_out(7) <= carry;

    -- Value going to the bus
    with data_bus_sel select data_bus <=
        ir(3 downto 0) when TO_BUS_IR,
        stack_value    when TO_BUS_STACK,
        carry          when TO_BUS_CARRY,
        acc            when TO_BUS_ACC;

    -- Control signals for ALU...ish
    process(all) begin
        if rising_edge(clk) then
            if load_carry then
                carry <= carry_next;
            end if;

            if load_acc then
                acc <= alu_out;
            end if;
        end if;
    end process;

    process(all) begin
        if rst_n then  -- Async reset
            state <= STATE_IDLE;
            deposit2 <= '0';
            deposit1 <= '0';
        else
            if rising_edge(clk) then
                deposit2 <= deposit1;
                deposit1 <= uio_in(7);
                if deposit2 then
                    ir(6 downto 0) <= ui_in(0 to 6);  -- Note: Bit direction reversed
                end if;

                case state is
                    when STATE_IDLE =>
                        if deposit2 then
                            case ir(6 downto 4) is
                                when "000" =>
                                    state <= STATE_PUSHI;
                                when "001" =>
                                    state <= STATE_BIN1;
                                when "010" =>
                                    state <= STATE_UN1;
                                when "011" =>
                                    state <= STATE_PUSHC;
                                when others =>
                                    state <= STATE_DONE;
                            end case;
                        end if;
                    when STATE_PUSHI | STATE_PUSHC | STATE_BIN3 | STATE_UN2 =>
                        state <= STATE_DONE;
                    when STATE_DONE =>
                        if deposit2 = '0' then
                            state <= STATE_IDLE;
                        end if;
                    when STATE_BIN1 =>
                        state <= STATE_BIN2;
                    when STATE_BIN2 =>
                        state <= STATE_BIN3;
                    when STATE_UN1 =>
                        state <= STATE_UN2;
                end case;
            end if;
        end if;
    end process;

    process(state) 
        variable push_pop_sel_v : std_logic    := 0;
        variable stack_enable_v : std_logic    := 0;
        variable load_carry_v   : std_logic    := 0;
        variable load_acc_v     : std_logic    := 0;
        variable data_bus_sel_v : bus_sel_type := TO_BUS_IR;
        variable alu_func_v     : std_logic_vector(3 downto 0) := ALU_OP1;
    begin
        case state is
            when STATE_IDLE | STATE_DONE =>
                null;
            when STATE_PUSHI =>
                push_pop_sel_v := 1;
                stack_enable_v := 1;
                data_bus_sel_v := TO_BUS_IR;
            when STATE_PUSHC =>
                push_pop_sel_v := 1;
                stack_enable_v := 1;
                data_bus_sel_v := TO_BUS_CARRY;
            when STATE_BIN1 =>
                push_pop_sel_v := 0;
                stack_enable_v := 1;
                data_bus_sel_v := TO_BUS_STACK;
                alu_func_v     := ALU_OP1;
                load_acc_v     := 1;
            when STATE_BIN2 =>
                push_pop_sel_v := 0;
                stack_enable_v := 1;
                data_bus_sel_v := TO_BUS_STACK;
                alu_func_v     := ir(3 downto 0);
                load_acc_v     := 1;
                load_carry_v   := 1;
            when STATE_BIN3 | STATE_UN2 =>
                push_pop_sel_v := 1;
                stack_enable_v := 1;
                data_bus_sel_v := TO_BUS_ACC;
            when STATE_UN1 =>
                push_pop_sel_v := 0;
                stack_enable_v := 1;
                data_bus_sel_v := TO_BUS_STACK;
                alu_func_v     := ir(3 downto 1);
                load_acc_v     := 1;
        end case;

        push_pop_sel <= push_pop_sel_v;
        stack_enable <= stack_enable_v;
        load_carry   <= load_carry_v;
        load_acc     <= load_acc_v;
        data_bus_sel <= data_bus_sel_v;
        alu_func     <= alu_func_v;
    end process;

end architecture Behavioral;