`timescale 1ns/1ps

// weight_memory 模块用于从外部 hex 文件加载 CNN 权重数据
// The weight_memory module loads CNN weight data from an external hex file ("cnn_weights.hex")
module weight_memory #(
    parameter DATA_WIDTH = 32,           // 数据宽度（默认32位）
    parameter ADDR_WIDTH = 10,           // 地址宽度（默认为10位，支持2^10 = 1024个数据）
    parameter MEM_DEPTH  = (1 << ADDR_WIDTH) // 存储器深度
)(
    input  logic                      clk,       // 时钟信号
    input  logic [ADDR_WIDTH-1:0]       addr,      // 地址输入
    output logic [DATA_WIDTH-1:0]       data_out   // 数据输出
);

    // 内部存储器数组，用于存放权重数据
    // Internal memory array to store weight data
    logic [DATA_WIDTH-1:0] mem [0:MEM_DEPTH-1];

    // 初始块：使用 $readmemh 从 "cnn_weights.hex" 文件中加载数据到内存数组中
    // Initial block: Load weight data from "cnn_weights.hex" into the memory array
    initial begin
        $readmemh("cnn_weights.hex", mem);
    end

    // 组合逻辑读取：直接将内存数组中对应地址的数据赋值给输出
    // Combinational read logic: Assign the memory data at the given address to the output
    assign data_out = mem[addr];

endmodule
