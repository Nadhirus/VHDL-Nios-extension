LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY sqrt_comport IS
  GENERIC (
    data_width : INTEGER := 32
  );
  PORT (
    clk : IN STD_LOGIC; -- Added clock signal for synchronous process
    reset : IN STD_LOGIC; -- Added reset signal
    start : IN STD_LOGIC;
    done : OUT STD_LOGIC;
    A : IN STD_LOGIC_VECTOR (2 * data_width - 1 DOWNTO 0);
    result : OUT STD_LOGIC_VECTOR (data_width - 1 DOWNTO 0)
  );
END sqrt_comport;

ARCHITECTURE comportementale OF sqrt_comport IS
  TYPE state_type IS (WAIT_state, INIT_state, COUNT_state, END_state);
  SIGNAL state : state_type := WAIT_state; -- Initial state set to WAIT_state
  SIGNAL i_count : INTEGER := 0;
  SIGNAL D : signed (2 * data_width - 1 DOWNTO 0);
  SIGNAL R : signed (data_width + 2 DOWNTO 0);
  SIGNAL Z : unsigned (data_width - 1 DOWNTO 0);

BEGIN

  PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      state <= WAIT_state;
      done <= '0';
      i_count <= 0;
      D <= (OTHERS => '0');
      R <= (OTHERS => '0');
      Z <= (OTHERS => '0');
    ELSIF rising_edge(clk) THEN
      CASE state IS
        WHEN WAIT_state =>
          done <= '0';
          IF start = '1' THEN
            state <= INIT_state;
          END IF;

        WHEN INIT_state =>
          done <= '0';
          D <= signed(A);
          R <= (OTHERS => '0');
          Z <= (OTHERS => '0');
          i_count <= 0;
          state <= COUNT_state;

        WHEN COUNT_state =>
          done <= '0';
          i_count <= i_count + 1;

          IF R >= 0 THEN
            R <= resize(R * 4, data_width + 3) + signed(resize(D(2 * data_width - 1 DOWNTO 2 * data_width - 2), data_width + 3)) - signed(resize((4 * Z + 1), data_width + 3));
          ELSE
            R <= resize(R * 4, data_width + 3) + signed(resize(D(2 * data_width - 1 DOWNTO 2 * data_width - 2), data_width + 3)) + signed(resize((4 * Z + 3), data_width + 3));
          END IF;

          IF R >= 0 THEN
            Z <= resize(Z * 2 + 1, data_width);
          ELSE
            Z <= resize(Z * 2, data_width);
          END IF;

          D <= resize(D * 4, data_width * 2);

          IF i_count < data_width THEN
            state <= COUNT_state;
          ELSE
            state <= END_state;
          END IF;

        WHEN END_state =>
          done <= '1';
          result <= STD_LOGIC_VECTOR(Z);
          IF start = '0' THEN
            state <= WAIT_state;
          END IF;

        WHEN OTHERS =>
          state <= WAIT_state;
      END CASE;
    END IF;
  END PROCESS;
END comportementale;