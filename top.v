`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/23/2019 11:39:36 PM
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top(clk, reset, rx, pwm, A, B, AStatus, BStatus, C, E, DP);
    input clk, reset, rx;
    output [1:0] pwm, A, B, AStatus, BStatus;
    output [6:0] C;
    output [7:0] E;
    output DP;
    
    // intermediate signals
    wire rx_done_bit;
    wire [7:0] rx_data;
    wire [1:0] FMAB, AMAB;
    wire [7:0] MPWM;
    wire pwm_internal;
    wire [11:0] BCD;
    wire w;
    wire [2:0] wadd;
    wire [5:0] din;
    
    // instantiate RX module (868 parameter for 115200 baud rate)
    UART_RX #(868) u_UART_RX(.i_Clk(clk), .i_RX_Serial(rx), .o_RX_DV(rx_done_bit), .o_RX_Byte(rx_data));
    
    // instantiate drive motor state machine
    State_Machine u_State_Machine(.clk(clk), .reset(reset), .rx_done_bit(rx_done_bit), .rx_data(rx_data), .FMAB(FMAB), .AMAB(AMAB), .MPWM(MPWM));
    
    // instantiate pwm module
    pwm u_pwm(.clk(clk), .reset(reset), .pw(MPWM), .pwm(pwm_internal));
    
    // instantiate B2BCD
    B2BCD u_B2BCD(.clk(clk), .B({2'b00, MPWM}), .BCD(BCD));
    
    // instantiate display controller
    display_controller u_display_controller(.clk(clk), .bcd(BCD), .w(w), .wadd(wadd), .din(din));
    
    // instantiate display interface
    display_interface u_display_interface(.clk(clk), .w(w), .WADD(wadd), .din(din), .e(E), .c(C), .dp(DP));
    
    // tie outputs
    assign pwm = {pwm_internal, pwm_internal};
    assign {A[1],B[1]} = FMAB;
    assign {A[0],B[0]} = AMAB;
    assign {AStatus[1],BStatus[1]} = FMAB;
    assign {AStatus[0],BStatus[0]} = AMAB;

endmodule
