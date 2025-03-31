`timescale 1ns/1ps

module PipelineCPU_tb;
    logic clk;
    logic reset;
    logic [31:0] cycle_count;

    // 实例化流水线 CPU 模块
    // 注意：确保 PipelineCPU 模块中有公开的 PC 信号（例如 pc_if）
    PipelineCPU dut(
        .clk(clk),
        .reset(reset)
    );

    // 产生时钟：周期10 ns（每5 ns翻转一次）
    always #5 clk = ~clk;

    // 计数器：在每个时钟上升沿累加周期数
    initial begin
        cycle_count = 0;
        forever @(posedge clk) begin
            cycle_count = cycle_count + 1;
        end
    end

    // 仿真流程：复位后等待直到PC达到 400（即执行100条指令），然后输出结果并结束仿真
    initial begin
        reset = 1;
        #20;         // 复位20 ns
        reset = 0;
        // 等待直到 PC 达到 400（假设每条指令 PC 增加4）
        wait (dut.pc_if >= 32'd400);
        $display("Pipeline CPU Simulation Results:");
        $display("  Total cycles = %0d", cycle_count);
        $display("  Final PC     = %0d", dut.pc_if);
        // 有效指令数 = PC/4；真实 CPI = 总周期数 / (PC/4)
        $display("  Effective CPI = %0f", cycle_count / (dut.pc_if / 4.0));
        $finish;
    end

    // 波形记录
    initial begin
        $dumpfile("PipelineCPU_tb.vcd");
        $dumpvars(0, PipelineCPU_tb);
    end
endmodule
