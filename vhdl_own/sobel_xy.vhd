--------------------------------------------------------------------------------
--
-- File     : sobel_xy.vhd
-- Author   : Marc Leemann
-- Date     : 14.12.2021
--
-- Context  : Fast 3x3 sobel mask
--
--------------------------------------------------------------------------------
-- Description :
--  Takes 8 8-bit integers nested in 2 32-bit integers as inputs and applies a
--  both Sobel X and Sobel Y masks, then sums the results
--
--  Image to apply Sobel mask on:
--  0  1  2
--  3  X  4
--  5  6  7
--
--  Sobel X:        Sobel Y:
--  -1  0  1         1  2  1
--  -2  0  2         0  0  0
--  -1  0  1        -1 -2 -1
--
--  Bytes 0 to 3 are to be put in dataA, bytes 4 to 7 are to be put in dataB
--  dataA = pixel3 & pixel2 & pixel1 & pixel0 (VHDL syntax)
--  dataB = pixel5 & pixel6 & pixel7 & pixel4
--  Results of Sobel X and Sobel Y are simply added to give final result
--
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

    signal pixel0_s : integer range 0 to 255;
    signal pixel1_s : integer range 0 to 255;
    signal pixel2_s : integer range 0 to 255;
    signal pixel3_s : integer range 0 to 255;
    signal pixel4_s : integer range 0 to 255;
    signal pixel5_s : integer range 0 to 255;
    signal pixel6_s : integer range 0 to 255;
    signal pixel7_s : integer range 0 to 255;
    signal pixel8_s : integer range 0 to 255;

    signal result_X_s     : integer range -1024 to 1023;
    signal result_X_abs_s : integer range 0 to 1024;
    signal result_Y_s     : integer range -1024 to 1023;
    signal result_Y_abs_s : integer range 0 to 1024;
    signal result_int_s   : integer range 0 to 2048;

    signal inter_X_1_s : integer range -512  to 511;
    signal inter_X_2_s : integer range -1024 to 1023;
    signal inter_X_3_s : integer range -512  to 511;
    signal inter_X_4_s : integer range -1024 to 1023;

    signal inter_Y_1_s : integer range -512  to 511;
    signal inter_Y_2_s : integer range -1024 to 1023;
    signal inter_Y_3_s : integer range -512  to 511;
    signal inter_Y_4_s : integer range -1024 to 1023;

    signal result_over_128_s : std_logic_vector(7 downto 0);

begin
    done_o <= not start_i;
-- Warning: check endianness
    pixel0_s <= to_integer(unsigned(dataA_i(31 downto 24)));
    pixel1_s <= to_integer(unsigned(dataA_i(23 downto 16)));
    pixel2_s <= to_integer(unsigned(dataA_i(15 downto  8)));
    pixel3_s <= to_integer(unsigned(dataA_i(7  downto  0)));

    pixel4_s <= to_integer(unsigned(dataB_i(7  downto  0)));
    pixel5_s <= to_integer(unsigned(dataB_i(31 downto 24)));
    pixel6_s <= to_integer(unsigned(dataB_i(23 downto 16)));
    pixel7_s <= to_integer(unsigned(dataB_i(15 downto  8)));

    inter_X_1_s <= pixel2_s - pixel0_s;
    inter_X_2_s <= 2*pixel4_s - 2*pixel3_s;
    inter_X_3_s <= pixel7_s  - pixel5_s;

    inter_X_4_s <= inter_X_1_s + inter_X_3_s;
    result_X_s  <= inter_X_2_s + inter_X_4_s;
    --result_X_s  <=  pixel2_s - pixel0_s + 2*pixel4_s - 2*pixel3_s + pixel7_s  - pixel5_s;

    inter_Y_1_s <= pixel0_s - pixel5_s;
    inter_Y_2_s <= 2*pixel1_s - 2*pixel6_s;
    inter_Y_3_s <= pixel2_s - pixel7_s;

    inter_Y_4_s <= inter_Y_1_s + inter_Y_3_s;
    result_Y_s  <= inter_Y_2_s + inter_Y_4_s;

    --result_Y_s  <=  pixel0_s - pixel5_s + 2*pixel1_s - 2*pixel6_s + pixel2_s - pixel7_s;

    result_X_abs_s <= abs(result_X_s);
    result_Y_abs_s <= abs(result_Y_s);

    result_int_s <= result_X_abs_s + result_Y_abs_s;

    result_over_128_s <= "11111111" when result_int_s > 128 else "00000000";
    --result_o <= result_over_128_s & "00000000" & std_logic_vector(to_unsigned(result_int_s,16));
    result_o <=  std_logic_vector(to_unsigned(result_int_s,16)) & "00000000" & result_over_128_s;
    --result_o <= std_logic_vector(to_unsigned(result_int_s,16)) & "0000000000000000";

end dataflow;
