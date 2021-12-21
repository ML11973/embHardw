--------------------------------------------------------------------------------
--
-- File     : sobel.vhd
-- Author   : Marc Leemann
-- Date     : 14.12.2021
--
-- Context  : Fast 3x3 sobel mask
--
--------------------------------------------------------------------------------
-- Description :
--  Takes 6 8-bit integers nested in 2 32-bit integers as inputs and applies a
--  hard-coded Sobel X or Y mask
--  C code:
--  resultx = filterx[0] * source[(y-1)*sobel_width+(x-1)]
--   + filterx[2] * source[(y-1)*sobel_width+(x+1)]
--   + filterx[3] * source[(y)*sobel_width+(x-1)]
--   + filterx[5] * source[(y)*sobel_width+(x+1)]
--   + filterx[6] * source[(y+1)*sobel_width+(x-1)]
--   + filterx[8] * source[(y+1)*sobel_width+(x+1)];
--
--  Equivalent applied here:
--  result = 1 * dataA[23:16] + 2 * dataA[15:8] + 1 * dataA[7:0]
--         - 1 * dataB[23:16] - 2 * dataB[15:8] - 1 * dataB[7:0];
--------------------------------------------------------------------------------
-- Dependencies :
--
--------------------------------------------------------------------------------
-- Modifications :
-- Ver   Date        Person     Comments
-- 1.0   14.12.2021  MLN        Initial version
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity sobel is
    port (
        clk_i     : in std_logic;
        rst_i     : in std_logic;
        start_i   : in std_logic;
        dataA_i   : in std_logic_vector(31 downto 0);
        dataB_i   : in std_logic_vector(31 downto 0);
        done_o    : out std_logic;
        result_o  : out std_logic_vector(31 downto 0)
    );
end sobel;
architecture dataflow of sobel is

    signal pos_inputA_s        : integer;
    signal pos_inputB_s        : integer; -- multiplied by 2
    signal pos_inputC_s        : integer;

    signal neg_inputA_s        : integer;
    signal neg_inputB_s        : integer; -- multiplied by 2
    signal neg_inputC_s        : integer;

    signal result_int_s        : integer;

begin
    done_o <= not start_i;

    pos_inputA_s <= to_integer(unsigned(dataA_i(23 downto 16)));
    pos_inputB_s <= to_integer(unsigned(dataA_i(15 downto 8) & '0')); -- x2
    pos_inputC_s <= to_integer(unsigned(dataA_i(7  downto 0)));

    neg_inputA_s <= to_integer(unsigned(dataB_i(23 downto 16)));
    neg_inputB_s <= to_integer(unsigned(dataB_i(15 downto 8) & '0')); -- x2
    neg_inputC_s <= to_integer(unsigned(dataB_i(7  downto 0)));

    result_int_s <= pos_inputA_s+pos_inputB_s+pos_inputC_s
                   -neg_inputA_s-neg_inputB_s-neg_inputC_s;

    result_o <= "0000000000000000" & std_logic_vector(to_unsigned(result_int_s, 16));

end dataflow;
