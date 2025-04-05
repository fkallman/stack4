library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.util.all;

entity alu is
    port (
        func_in   : in  std_logic_vector(3 downto 0);
        op1_in    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        op2_in    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        carry_in  : in  std_logic;
        carry_out : out std_logic;
        data_out  : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end entity alu;

architecture Behavioral of alu is
    signal op1 : unsigned(DATA_WIDTH-1 downto 0);
    signal op2 : unsigned(DATA_WIDTH-1 downto 0);
    signal res : unsigned(DATA_WIDTH   downto 0);
begin
    op1 <= op1_in;
    op2 <= op2_in;

    with func_in select
        res <= op1                  when ALU_OP1,
               op2                  when ALU_OP2,
               op1 + op2            when ALU_ADD,
               op1 - op2            when ALU_SUB,
               op1 and op2          when ALU_AND,
               op1 or  op2          when ALU_OR,
               op1 xor op2          when ALU_XOR,
               not op1              when ALU_NOT,
               -op1                 when ALU_NEG,
               op1 + op2 + carry_in when ALU_ADC,
               (others => '-')      when others;

    data_out <= res(DATA_WIDTH-1 downto 0);
    carry_out <= res(DATA_WIDTH);
end architecture;