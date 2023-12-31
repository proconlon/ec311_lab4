// This verison of the moore machine was modified slightly when we ran on the board.
// we modified to send a debounced output of both the reset and read button.

`timescale 1ns / 1ps

module moore_FSM(
    output reg out,
    input clk,
    input reset,
    input read,
    //input button, //modified from original moore machine
    input [7:0] in
);
    reg [2:0] p;
    reg [2:0] present_state, next_state;
    
    // See here we debounce and clean both the reset button and read button
    wire reset_clean;
   debouncer reset_deb(
        .clk(clk),
        .button(reset),
        .clean(reset_clean) 
    );
      
    wire read_clean;
    debouncer read_deb(
        .clk(clk),
        .button(read),
        .clean(read_clean) 
    );
    
    parameter S0 = 0, S1 = 1, S2 = 2, S3 = 3;
    
    initial present_state = S3;
    
    always @(*) begin
        if (reset_clean)
            next_state = S3;
        else
            next_state = present_state;

        case (present_state)
            S0: begin
                if (read_clean && !reset_clean)
                    next_state = S1;
                else if (!read_clean && !reset_clean)
                    next_state = S0;
            end
            S1: begin
                if ( !reset_clean)
                    next_state = S2;
                else
                    next_state = S1;
            end
            S2: begin
                if ( !reset_clean)
                    next_state = S0;
                else
                    next_state = S2;
            end
            S3: begin
                if (!reset_clean)
                    next_state = S0;
            end
        endcase
    end 

    always @(posedge clk) begin
        present_state <= next_state;
        case (present_state)
            S1: out <= in[p];
            S2: p <= p + 1;
            S3: begin
                p <= 0;
                out <= 0;
            end
        endcase
    end
endmodule
