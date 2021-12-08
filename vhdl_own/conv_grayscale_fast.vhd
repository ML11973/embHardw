--------------------------------------------------------------------------------
--
-- File     : conv_grayscale.vhd
-- Author   : Marc Leemann
-- Date     : 07.12.2021
--
-- Context  : RGB to grayscale converter for EmbHardw course
--
--------------------------------------------------------------------------------
-- Description :
--  Takes a 16-bit RGB pixel as input, converts it to RGB to match the following
--  C code:
--  // Optimized RGB to gray
--  // Convert RGB to 8 LSB and divide R by 4, G by 2, B by 2
--  // Original goal is GS = 0.3R + 0.59G + 0.11B
--  gray = ((rgb&0xF100)>>10)// red part
--       + ((rgb&0x07E0)>>4)  // green part
--       + ((rgb&0x001F)<<2); // blue part
--
--------------------------------------------------------------------------------
-- Dependencies :
--
--------------------------------------------------------------------------------
-- Modifications :
-- Ver   Date        Person     Comments
-- 1.0   07.12.2021  MLN        Initial version
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity conv_grayscale is
    port (
        clk_i     : in std_logic;
        rst_i     : in std_logic;
        start_i   : in std_logic;
        rgb_i     : in std_logic_vector(31 downto 0);
        done_o    : out std_logic;
        gray_o    : out std_logic_vector(31 downto 0)
    );
end conv_grayscale;
architecture dataflow of conv_grayscale is

    signal red_s    : unsigned(7 downto 0);
    signal green_s  : unsigned(7 downto 0);
    signal blue_s   : unsigned(7 downto 0);

    signal gray_reg_s : std_logic_vector(7 downto 0);

begin
    -- Represents the bit fields for each color
    --red_s   <= rgb_i(15 downto 11) & (others=>'0');
    --green_s <= rgb_i(10 downto 5) & (others=>'0');
    --blue_s  <= rgb_i(4 downto 0) & (others=>'0');

    -- The keen observer will notice that "00" means the color value is divided
    -- by 4 and '0' means it is divided by 2
    -- We apply the approx conversion GS = 0.25*R + 0.5*G + 0.25*B
    -- Instead of standard GS = 0.3*R + 0.59*G + 0.11*B
    red_s   <= unsigned("00" & rgb_i(15 downto 11) & '0');
    green_s <= unsigned('0'  & rgb_i(10 downto 5)  & '0');
    blue_s  <= unsigned("00" & rgb_i(4 downto 0)   & '0');

    gray_o <= "000000000000000000000000" & gray_reg_s;
    done_o <= not start_i;

    --reg: process (clk_i, rst_i) is
    --begin
    --  if (rst_i = '1') then
    --    gray_reg_s <= (others=>'0');
    --  elsif (rising_edge(clk_i)) then
    --    if (start_i = '1') then
          gray_reg_s <= std_logic_vector(red_s + green_s + blue_s);
    --    end if;
    --  end if;
    --end process reg;



end dataflow;
