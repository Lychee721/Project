`timescale 1ns/1ps

module tb_SingleCycleCPU;
    logic clk;
    logic reset;
    logic [31:0] cycle_count;

    // 实例化单周期 CPU 模块
    // 注意：确保 SingleCycleCPU 模块中有公开的 PC 信号（例如 PC）
    SingleCycleCPU dut(
        .clk(clk),
        .reset(reset)
    );

    // 产生时钟：周期50 ns（每25 ns翻转一次）
    always #25 clk = ~clk;

    // 计数器：在每个时钟上升沿累加周期数
    initial begin
        cycle_count = 0;
        forever @(posedge clk) begin
            cycle_count = cycle_count + 1;
        end
    end

    // 仿真流程：复位后等待直到PC达到400（即执行100条指令），然后输出结果并结束仿真
    initial begin
        reset = 1;
        #50;         // 复位50 ns
        reset = 0;
        wait (dut.PC >= 32'd400); // 当 PC 达到400时，认为100条指令已完成
        $display("Single Cycle CPU Simulation Results:");
        $display("  Total cycles = %0d", cycle_count);
        $display("  Final PC     = %0d", dut.PC);
        // 有效指令数 = PC/4；真实 CPI = 总周期数 / (PC/4)
        $display("  Effective CPI = %0f", cycle_count / (dut.PC / 4.0));
        $finish;
    end

    // 波形记录
    initial begin
        $dumpfile("tb_SingleCycleCPU.vcd");
        $dumpvars(0, tb_SingleCycleCPU);
    end
endmodule
