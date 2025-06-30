module uart_rx#(
    parameter int c_clkfreq = 100_000_000, //10ns 
    parameter int c_baudrate = 10_000_000
)(
    input  logic        clk_i,
    input  logic        rstn_i,
    input  logic        rx_i,
    output logic [7:0]  rx_dout_o,
    output logic        rx_done_tick_o
);

localparam int c_timerlim = c_clkfreq/c_baudrate; //10 * 10ns = 100ns = 10Mbps

typedef enum logic [1:0] {S_IDLE, S_START, S_DATA, S_STOP} states_t;
states_t state;

logic [31:0] timer;
logic [7:0 ] shreg;
logic [2:0 ] bitcntr;

assign rx_dout_o = shreg;

always_ff @(posedge clk_i) begin : OUT_UPDATE_FF
    if(!rstn_i)begin
       rx_done_tick_o  <= 0;
       timer           <= 0;
       bitcntr         <= 0;
       state           <= S_IDLE;
       shreg           <= '0;
    end else begin
      case(state)
        S_IDLE: begin
            rx_done_tick_o <= 0;
            if(!rx_i) begin
                state <= S_START;
            end
        end
        S_START: begin
            if(timer == (c_timerlim-1)/2) begin
                state <= S_DATA;
                timer <= 0;
            end else begin
                timer <= timer + 1;
            end
        end
        S_DATA: begin
            if(timer == c_timerlim-1) begin
                shreg[7] <= rx_i;
                shreg[6:0] <= shreg[7:1];
                timer <= 0;
                if(bitcntr == 3'd7) begin
                    state <= S_STOP;
                    bitcntr <= 0;
                end else begin
                    bitcntr <= bitcntr +1;
                end
            end else begin
                timer <= timer+1;
            end
        end
        S_STOP: begin
            if(timer == c_timerlim-1) begin
                state <= S_IDLE;
                rx_done_tick_o  <= 1;
                timer <= 0;
            end else begin
                timer <= timer + 1;
            end
        end
      endcase
    end
end
endmodule
