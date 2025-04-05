library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package util is
    constant DATA_WIDTH  : integer := 4;
    constant STACK_DEPTH : integer := 8;

    type state_type is (STATE_IDLE, STATE_PUSHI, STATE_PUSHC,
                        STATE_BIN1, STATE_BIN2, STATE_BIN3,
                        STATE_UN1, STATE_UN2,
                        STATE_DONE);
    type bus_sel_type is (TO_BUS_IR, TO_BUS_STACK, TO_BUS_ACC, TO_BUS_CARRY);

    constant ALU_OP1 : std_logic_vector(3 downto 0) := "0000";
    constant ALU_OP2 : std_logic_vector(3 downto 0) := "0001";

    constant ALU_ADD : std_logic_vector(3 downto 0) := "0010";
    constant ALU_SUB : std_logic_vector(3 downto 0) := "0011";

    constant ALU_AND : std_logic_vector(3 downto 0) := "0100";
    constant ALU_OR  : std_logic_vector(3 downto 0) := "0101";
    constant ALU_XOR : std_logic_vector(3 downto 0) := "0110";
    constant ALU_ADC : std_logic_vector(3 downto 0) := "0111";

    constant ALU_NOT : std_logic_vector(3 downto 0) := "1110";
    constant ALU_NEG : std_logic_vector(3 downto 0) := "1111";
end package util;

