LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY tb_sqrt_comport IS
END tb_sqrt_comport;

ARCHITECTURE behavior OF tb_sqrt_comport IS

  COMPONENT sqrt_comport
    GENERIC (
      data_width : INTEGER := 32
    );
    PORT (
      start : IN STD_LOGIC;
      done : OUT STD_LOGIC;
      A : IN STD_LOGIC_VECTOR(2 * data_width - 1 DOWNTO 0);
      result : OUT STD_LOGIC_VECTOR(data_width - 1 DOWNTO 0)
    );
  END COMPONENT;

  SIGNAL tb_start : STD_LOGIC := '0';
  SIGNAL tb_done : STD_LOGIC;
  SIGNAL tb_A : STD_LOGIC_VECTOR(2 * 32 - 1 DOWNTO 0) := (OTHERS => '0');
  SIGNAL tb_result : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);

BEGIN

  uut : sqrt_comport
    GENERIC MAP (
      data_width => 32
    )
    PORT MAP (
      start => tb_start,
      done => tb_done,
      A => tb_A,
      result => tb_result
    );

  stimulus : PROCESS
  BEGIN
    WAIT FOR 20 ns;

    tb_A <= STD_LOGIC_VECTOR(to_signed(64, tb_A'LENGTH));
    tb_start <= '1';
    WAIT FOR 20 ns;
    tb_start <= '0';

    WAIT UNTIL tb_done = '1';
    WAIT FOR 50 ns;

    WAIT;

  END PROCESS;

END behavior;
