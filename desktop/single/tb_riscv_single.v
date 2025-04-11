`timescale 1ns/1ps

module tb_riscv_single();
    reg clk;
    reg rst_n;
    wire [31:0]matrixp00  ;
    wire [31:0]matrixp01  ;
    wire [31:0]matrixp10  ;
    wire [31:0]matrixp11  ;
    reg [7:0]matrixA_11;
    reg [7:0]matrixA_12;
    reg [7:0]matrixA_21;
    reg [7:0]matrixA_22;
    reg [7:0]matrixB_11;
    reg [7:0]matrixB_12;
    reg [7:0]matrixB_21;
    reg [7:0]matrixB_22;
    reg ReLU;


    wire [31:0]cycle_count ;
    
    riscv_single_block uut(
        .clk(clk),
        .rst_n(rst_n),
        .matrixA_11 (matrixA_11),
        .matrixA_12 (matrixA_12),
        .matrixA_21 (matrixA_21),
        .matrixA_22 (matrixA_22),
        .matrixB_11 (matrixB_11),
        .matrixB_12 (matrixB_12),
        .matrixB_21 (matrixB_21),
        .matrixB_22 (matrixB_22),
        .matrixp00  (matrixp00  ),
        .matrixp01  (matrixp01  ),
        .matrixp10  (matrixp10  ),
        .matrixp11  (matrixp11  ),
        .cycle_count(cycle_count),
        .ReLU(ReLU)
    );
    
    // 时钟生成
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // 20ns周期
    end
    
    // 测试序列
    initial begin
        // 初始化存储器
        $readmemh("C:/Users/Administrator/Desktop/single/instr.mem", uut.instr_mem);
        $readmemh("C:/Users/Administrator/Desktop/single/data.mem", uut.data_mem);
        #200;
        rst_n     <=1'd0;
        ReLU      <=1'd0;
        matrixA_11<=8'd0;
        matrixA_12<=8'd0;
        matrixA_21<=8'd0;
        matrixA_22<=8'd0;
        
        matrixB_11<=8'd0;
        matrixB_12<=8'd0;
        matrixB_21<=8'd0;
        matrixB_22<=8'd0;
        #200
        rst_n     <=1'd1;
        #200
        ReLU      <=1'd1;
        matrixA_11<=8'd1;
        matrixA_12<=8'd2;
        matrixA_21<=8'd3;
        matrixA_22<=8'd4;
            
        matrixB_11<=8'd1;
        matrixB_12<=8'd2;
        matrixB_21<=8'd3;
        matrixB_22<=8'd4;
        $display("Cycle Count=%d", cycle_count);
        $display(" matrix p00 = %x", matrixp00);
        $display(" matrix p01 = %x", matrixp01);
        $display(" matrix p10 = %x", matrixp10);
        $display(" matrix p11 = %x", matrixp11);
    
        #200
        ReLU      <=1'd1;
        matrixA_11<=8'd11;
        matrixA_12<=8'd12;
        matrixA_21<=8'd13;
        matrixA_22<=8'd14;
            
        matrixB_11<=8'd21;
        matrixB_12<=8'd22;
        matrixB_21<=8'd23;
        matrixB_22<=8'd24;
        $display("Cycle Count=%d", cycle_count);
        $display(" matrix p00 = %x", matrixp00);
        $display(" matrix p01 = %x", matrixp01);
        $display(" matrix p10 = %x", matrixp10);
        $display(" matrix p11 = %x", matrixp11);
    
        #200
        ReLU      <=1'd1;
        matrixA_11<=8'd31;
        matrixA_12<=8'd32;
        matrixA_21<=8'd33;
        matrixA_22<=8'd34;
            
        matrixB_11<=8'd41;
        matrixB_12<=8'd42;
        matrixB_21<=8'd43;
        matrixB_22<=8'd44;
        $display("Cycle Count=%d", cycle_count);
        $display(" matrix p00 = %x", matrixp00);
        $display(" matrix p01 = %x", matrixp01);
        $display(" matrix p10 = %x", matrixp10);
        $display(" matrix p11 = %x", matrixp11);
    
        #200
        ReLU      <=1'd1;
        matrixA_11<=8'd51;
        matrixA_12<=8'd52;
        matrixA_21<=8'd53;
        matrixA_22<=8'd54;
            
        matrixB_11<=8'd61;
        matrixB_12<=8'd62;
        matrixB_21<=8'd63;
        matrixB_22<=8'd64;
        $display("Cycle Count=%d", cycle_count);
        $display(" matrix p00 = %x", matrixp00);
        $display(" matrix p01 = %x", matrixp01);
        $display(" matrix p10 = %x", matrixp10);
        $display(" matrix p11 = %x", matrixp11);
    
        #200
        ReLU      <=1'd1;
        matrixA_11<=8'd71;
        matrixA_12<=8'd72;
        matrixA_21<=8'd73;
        matrixA_22<=8'd74;
            
        matrixB_11<=8'd81;
        matrixB_12<=8'd82;
        matrixB_21<=8'd83;
        matrixB_22<=8'd84;
        $display("Cycle Count=%d", cycle_count);
        $display(" matrix p00 = %x", matrixp00);
        $display(" matrix p01 = %x", matrixp01);
        $display(" matrix p10 = %x", matrixp10);
        $display(" matrix p11 = %x", matrixp11);
    
        #200
        ReLU      <=1'd1;
        matrixA_11<=8'd91;
        matrixA_12<=8'd92;
        matrixA_21<=8'd93;
        matrixA_22<=8'd94;
            
        matrixB_11<=8'd101;
        matrixB_12<=8'd102;
        matrixB_21<=8'd103;
        matrixB_22<=8'd104;

        $display("Cycle Count=%d", cycle_count);
        $display(" matrix p00 = %x", matrixp00);
        $display(" matrix p01 = %x", matrixp01);
        $display(" matrix p10 = %x", matrixp10);
        $display(" matrix p11 = %x", matrixp11);
        #200
        ReLU      <=1'd1;
        matrixA_11<=8'd91;
        matrixA_12<=8'd98;
        matrixA_21<=8'd93;
        matrixA_22<=8'd95;
            
        matrixB_11<=8'd111;
        matrixB_12<=8'd102;
        matrixB_21<=8'd123;
        matrixB_22<=8'd104;

        $display("Cycle Count=%d", cycle_count);
        $display(" matrix p00 = %x", matrixp00);
        $display(" matrix p01 = %x", matrixp01);
        $display(" matrix p10 = %x", matrixp10);
        $display(" matrix p11 = %x", matrixp11);
        #200
        ReLU      <=1'd1;
        matrixA_11<=8'd91;
        matrixA_12<=8'd38;
        matrixA_21<=8'd93;
        matrixA_22<=8'd95;
            
        matrixB_11<=8'd111;
        matrixB_12<=8'd102;
        matrixB_21<=8'd133;
        matrixB_22<=8'd114;

        $display("Cycle Count=%d", cycle_count);
        $display(" matrix p00 = %x", matrixp00);
        $display(" matrix p01 = %x", matrixp01);
        $display(" matrix p10 = %x", matrixp10);
        $display(" matrix p11 = %x", matrixp11);
    end
    

endmodule