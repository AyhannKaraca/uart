module uart_tx#(
    parameter int c_clkfreq = 100_000_000, //10ns 
    parameter int c_baudrate = 10_000_000,  
    parameter int c_stopbit = 2
)(
    input  logic        clk_i,
    input  logic        rstn_i,
    input  logic [7:0]  tx_din_i,
    input  logic        tx_start_i,
    output logic        tx_o,
    output logic        tx_active_o,
    output logic        tx_done_tick_o
);

localparam int c_timerlim = c_clkfreq/c_baudrate; //10 * 10ns = 100ns = 10Mbps

typedef enum logic [1:0] {S_IDLE, S_START, S_DATA, S_STOP} states_t;
states_t state;


logic [31:0] timer;
logic [7:0 ] shreg;
logic [2:0 ] bitcntr;
  
assign tx_active_o = (state == S_DATA);  

always_ff @(posedge clk_i) begin : OUT_UPDATE_FF
    if(!rstn_i)begin
       tx_o            <= 1;
       tx_done_tick_o  <= 0;
       timer           <= 0;
       bitcntr         <= 0;
       state           <= S_IDLE;
       shreg           <= '0;
    end else begin
      case(state)
        S_IDLE: begin
          tx_o            <= 1;
          tx_done_tick_o  <= 0;
          if(tx_start_i) begin
            state <= S_START;
            tx_o <= 0;
            shreg <= tx_din_i;
          end
        end
        S_START: begin
          if(timer == c_timerlim-1) begin
            tx_o <= shreg[0];
            shreg[6:0] <= shreg[7:1];
            state <= S_DATA;
            timer <= 0;
          end else begin
            timer <= timer + 1;
          end
        end
        S_DATA: begin
          if(timer == c_timerlim-1) begin
            tx_o <= shreg[0];
            shreg[6:0] <= shreg[7:1];
            timer <= 0;
            
            if(bitcntr == 3'd7) begin
              state <= S_STOP;
              tx_o <= 1;
              timer <= 0;
              bitcntr <= 0;
            end else begin
              bitcntr <= bitcntr + 1;
            end
          end else begin
            timer <= timer + 1;
          end
        end
        S_STOP: begin
          if(timer == (c_timerlim*c_stopbit)-1) begin
            state <= S_IDLE;
            tx_done_tick_o  <= 1;
            timer <= 0;
          end else begin
            timer <= timer + 1;
          end
        end
      endcase
    end
end
endmodule
