library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity project_reti_logiche is
    port(
        i_clk   : in std_logic;
        i_rst   : in std_logic;
        i_start : in std_logic;
        i_w     : in std_logic;
        
        o_z0    : out std_logic_vector(7 downto 0);
        o_z1    : out std_logic_vector(7 downto 0);
        o_z2    : out std_logic_vector(7 downto 0);
        o_z3    : out std_logic_vector(7 downto 0);
        o_done  : out std_logic;
        
        o_mem_addr : out std_logic_vector(15 downto 0);
        i_mem_data : in std_logic_vector(7 downto 0);
        o_mem_we   : out std_logic;
        o_mem_en   : out std_logic
);
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is
    type state is (RST, GET_CHAN, GET_ADDR, FIX_ADDR, WRITE_ADDR,
     WAIT_MEMO_1, WAIT_MEMO_2, READ_MEMO, SELECT_CHAN, REPEAT, GET_CHAN_2);  -- missing states
    
    signal state_reg, state_next : state := RST;
    signal start_reg : std_logic := '0';
    signal w_reg : std_logic := '0';
    signal o_done_next, o_mem_en_next, o_mem_we_next : std_logic := '0';
    --signal channel_read, channel_read_next : boolean := false;
    signal bit_read, bit_read_next : integer range 0 to 16 := 0;
	signal curr_channel, curr_chan_next : std_logic_vector(1 downto 0) := "00";
	signal o_mem_addr_next : std_logic_vector(15 downto 0) := "0000000000000000";
	signal o_z0_next, o_z1_next, o_z2_next, o_z3_next : std_logic_vector(7 downto 0) := "00000000";
	signal tmp_addr, tmp_addr_next : std_logic_vector(15 downto 0) := "0000000000000000";
	signal pos_i, pos_i_next : integer range 0 to 16 := 0;
	signal fixed_addr, fixed_addr_next : std_logic_vector(15 downto 0) := "0000000000000000";
	signal curr_word, curr_word_next : std_logic_vector(7 downto 0) := "00000000";
	signal z0_t, z0_t_next, z1_t, z1_t_next, z2_t, z2_t_next, z3_t, z3_t_next : std_logic_vector (7 downto 0) := "00000000";
	signal one : std_logic_vector(1 downto 0) := "01";
	signal two : std_logic_vector(1 downto 0) := "10";
	signal zero: std_logic_vector(7 downto 0) := "00000000";
	signal helper, helper_next : integer range 0 to 1 := 0;
	
begin
    process(i_rst, i_clk)
    begin
        if (i_rst = '1') then
            state_reg <= RST;
            w_reg <= '0';
			o_done <= '0';
			--o_done_next <= '0';
            o_z0 <= "00000000";
            o_z1 <= "00000000";
            o_z2 <= "00000000";
            o_z3 <= "00000000";
			--o_z0_next <= "00000000";
			--o_z1_next <= "00000000";
			--o_z2_next <= "00000000";
			--o_z3_next <= "00000000";
			z0_t <= "00000000";
			z1_t <= "00000000";
			z2_t <= "00000000";
			z3_t <= "00000000";
			--z0_t_next <= "00000000";
			--z1_t_next <= "00000000";
			--z2_t_next <= "00000000";
			--z3_t_next <= "00000000";
            --channel_read <= false;
			--channel_read_next <= false;
			bit_read <= 0;
			o_mem_addr <= "0000000000000000";
			--o_mem_addr_next <= "0000000000000000";
			tmp_addr <= "0000000000000000";
			--tmp_addr_next <= "0000000000000000";
			fixed_addr <= "0000000000000000";
			--fixed_addr_next <= "0000000000000000";
            pos_i <= 0;
			o_mem_en <= '0';
			--o_mem_en_next <= '0';
			o_mem_we <= '0';
			--o_mem_we_next <= '0';
			curr_word <= "00000000";
			curr_channel <= "00";
			helper <= 0;
			--curr_word_next <= "00000000";
            -- maybe altri segnali da resettare
		elsif(rising_edge(i_clk)) then
			state_reg <= state_next;
			start_reg <= i_start;
			w_reg <= i_w;
			o_done <= o_done_next;
			o_z0 <= o_z0_next;
			o_z1 <= o_z1_next;
            o_z2 <= o_z2_next;
            o_z3 <= o_z3_next;
			z0_t <= z0_t_next; 
			z1_t <= z1_t_next;
			z2_t <= z2_t_next;
			z3_t <= z3_t_next;
			--channel_read <= false;
			bit_read <= bit_read_next;
			o_mem_addr <= o_mem_addr_next;
			tmp_addr <= tmp_addr_next;
			fixed_addr <= fixed_addr_next;
			pos_i <= pos_i_next;
			o_mem_en <= o_mem_en_next;
			o_mem_we <= o_mem_we_next;
			curr_word <= curr_word_next;
			curr_channel  <= curr_chan_next;
			helper <= helper_next;
		    
		end if;
	end process;
	
	
	process(state_reg, bit_read, i_start, start_reg, w_reg, curr_channel, two, one, pos_i, tmp_addr, fixed_addr, zero, i_mem_data, curr_word, z0_t, z1_t, z2_t, z3_t, helper)
	
	variable counter : integer range 0 to 16;
	variable new_pos : integer range 0 to 16;
	variable counter_2 : integer range 0 to 16;
	
	begin
	
        state_next <= state_reg;
        curr_chan_next <= curr_channel;
        bit_read_next <= bit_read;
        pos_i_next <= pos_i;
        z0_t_next <= z0_t;
        z1_t_next <= z1_t;
        z2_t_next <= z2_t;
        z3_t_next <= z3_t;
        fixed_addr_next <= fixed_addr;
        tmp_addr_next <= tmp_addr;
        curr_word_next <= curr_word;
        helper_next <= 0;
        o_z0_next <= "00000000";
        o_z1_next <= "00000000";
        o_z2_next <= "00000000";
        o_z3_next <= "00000000";
        o_done_next <= '0';
        o_mem_addr_next <= "0000000000000000";
        o_mem_en_next <= '0'; 
        
		
	--eventuali inizializzazioni
	
		case state_reg is
			when RST =>
				if (i_start = '1') then
					state_next <= GET_CHAN;
				end if;
			
			when GET_CHAN =>
				if(bit_read = 0 and w_reg = '1' and (helper = 0 or helper = 1)) then
					bit_read_next <= 1;
					curr_chan_next <= "10";
					helper_next <= 1;
					state_next <= GET_CHAN;
				elsif(bit_read = 0 and w_reg = '0' and (helper = 0 or helper = 1)) then
				    bit_read_next <= 1;
					curr_chan_next <= "00";
					helper_next <= 0;
					state_next <= GET_CHAN;
				elsif(bit_read = 1 and w_reg = '1' and helper = 0) then
				    bit_read_next <= 0;
				    curr_chan_next <= "01";
				    helper_next <= 0;
					state_next <= GET_ADDR;
				elsif(bit_read = 1 and w_reg = '1' and helper = 1) then
				    bit_read_next <= 0;
				    curr_chan_next <= "11";
				    helper_next <= 0;
				    state_next <= GET_ADDR;
				elsif(bit_read = 1 and w_reg = '0' and helper = 0) then 
					bit_read_next <= 0;
					curr_chan_next <= "00";
					helper_next <= 0;					  
					state_next <= GET_ADDR;
				elsif(bit_read = 1 and w_reg = '0' and helper = 1) then
				    bit_read_next <= 0;
					curr_chan_next <= "10";
					helper_next <= 0;					  
					state_next <= GET_ADDR;
				end if;
			
			when GET_ADDR =>
				if(start_reg = '1') then
					state_next <= GET_ADDR;
					bit_read_next <= bit_read +1;
					tmp_addr_next(bit_read) <= w_reg;
					pos_i_next <= pos_i;
				else
					state_next <= FIX_ADDR;
					bit_read_next <= bit_read;
					pos_i_next <= 0;
					tmp_addr_next(15) <= tmp_addr(15);
				end if;
					
			when FIX_ADDR =>
			    if(bit_read > 1) then
			         counter := bit_read -1;
			         fixed_addr_next(counter) <= tmp_addr(pos_i);
			         pos_i_next <= pos_i +2;
			         bit_read_next <= counter -1;
			         counter_2 := counter-1;
			         new_pos := pos_i +1;
			         fixed_addr_next(counter_2) <= tmp_addr(new_pos);	
			         state_next <= FIX_ADDR;		     
				elsif(bit_read = 1) then
				    counter := 0 ;
					fixed_addr_next(counter) <= tmp_addr(pos_i);
					bit_read_next <= counter;
					pos_i_next <= pos_i + 1;
					state_next <= FIX_ADDR;
					counter_2 := 0;
					new_pos := pos_i;
					fixed_addr_next(counter_2) <= tmp_addr(new_pos); 
				else
				    counter := 0;
					fixed_addr_next(counter) <= fixed_addr(0);
					bit_read_next <= bit_read;
					pos_i_next <= 0;
					state_next <= WRITE_ADDR;
					counter_2 := 0;
					new_pos := 0;
					fixed_addr_next(counter_2) <= fixed_addr(0);
				end if;
				
			when WRITE_ADDR =>
				o_mem_addr_next <= fixed_addr;
								
			    o_mem_en_next <= '1';
				o_mem_we_next <= '0';
				state_next <= WAIT_MEMO_1;
				tmp_addr_next <= "0000000000000000";
				fixed_addr_next <= "0000000000000000";
			
			when WAIT_MEMO_1 =>
			     state_next <= WAIT_MEMO_2;
			     	
			when WAIT_MEMO_2 =>
			     state_next <= READ_MEMO;			
				
			when READ_MEMO =>
				state_next <= SELECT_CHAN;
				o_mem_en_next <= '0';
				curr_word_next <= std_logic_vector(unsigned(zero) + unsigned(i_mem_data));
															
			when SELECT_CHAN =>
				if(curr_channel = "00") then
					o_z0_next <= curr_word;
					z0_t_next <= curr_word;
					z1_t_next <= z1_t;
					z2_t_next <= z2_t;
					z3_t_next <= z3_t;
					o_done_next <= '1';
					o_z1_next <= z1_t;
					o_z2_next <= z2_t;
					o_z3_next <= z3_t;
					state_next <= REPEAT;
				elsif(curr_channel = "01") then
					o_z0_next <= z0_t;
					z0_t_next <= z0_t;
					z1_t_next <= curr_word;
					z2_t_next <= z2_t;
					z3_t_next <= z3_t;
					o_done_next <= '1';
					o_z1_next <= curr_word;
					o_z2_next <= z2_t;
					o_z3_next <= z3_t;
					state_next <= REPEAT;
				elsif(curr_channel = "10") then
					o_z0_next <= z0_t;
					z0_t_next <= z0_t;
					z1_t_next <= z1_t;
					z2_t_next <= curr_word;
					z3_t_next <= z3_t;
					o_done_next <= '1';
					o_z1_next <= z1_t;
					o_z2_next <= curr_word;
					o_z3_next <= z3_t;
					state_next <= REPEAT;
				elsif(curr_channel = "11") then
					o_z0_next <= z0_t;
					z0_t_next <= z0_t; 
					z1_t_next <= z1_t;
					z2_t_next <= z2_t;
					z3_t_next <= curr_word;
					o_done_next <= '1';
					o_z1_next <= z1_t;
					o_z2_next <= z2_t;
					o_z3_next <= curr_word;
					state_next <= REPEAT;
				end if;
				
			when REPEAT =>
				o_done_next <= '0';
				o_z0_next <= "00000000";
				o_z1_next <= "00000000";
				o_z3_next <= "00000000";
				o_z2_next <= "00000000";
				state_next <= GET_CHAN_2;
				bit_read_next <= 0;
				curr_chan_next <= "00";
				
			when GET_CHAN_2 =>
				if(start_reg = '1' and w_reg = '1') then	
					bit_read_next <= 1;
					state_next <= GET_CHAN;
					curr_chan_next <= "10";
					helper_next <= 1;
				elsif(start_reg = '1' and w_reg = '0') then
				    bit_read_next <= 1;
				    state_next <= GET_CHAN;
				    curr_chan_next <= "00";
				    helper_next <= 0;				    
				else
					bit_read_next <= bit_read;
					state_next <= GET_CHAN_2;
					curr_chan_next <= "00";
					helper_next <= 0;
					
				end if;
						
		end case;
	end process;
end Behavioral;