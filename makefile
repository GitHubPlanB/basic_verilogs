版权声明：本文为CSDN博主「254、小小黑」的原创文章，遵循 CC 4.0 BY-SA 版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/immeatea_aun/article/details/80961258

com:
    vcs -full64 \
    -sverilog \
    -debug_pp \                                             # 使能UCLI命令
    -LDFLAGS \                                              # 传递参数给VCS的linker，与以下三行配合使用
    -rdynamic \                                             # 指示需加载的动态库，如libsscore_vcs201209.so
    -P ${VERDI_HOME}/share/PLI/VCS/${PLATFORM}/novas.tab \  # 加载表格文件
    ${VERDI_HOME}/share/PLI/VCS/${PLANTFORM}/pli.a \        # 加载静态库
    -f ../${demo_name}/tb_top.f \
    +vcs+lic+wait \
    -l compile.log

sim:
    ./simv \
    -ucli -i ../scripts/dump_fsdb_vcs.tcl \                 # ucli的输入文件（-i）为tcl脚本
    +fsdb+autoflush \                                       # 命令行参数autoflush，一边仿真一边dump波形，如果没有该参数，那么不会dump波形，需要在ucli命令run 100ns后键入fsdbDumpflush才会dump波形
    -l sim.log
————————————————

    global env                             # tcl脚本引用环境变量，Makefile中通过export定义   
    fsdbDumpfile "$env(demo_name).fsdb"    # 设置波形文件名，受环境变量env(demo_name)控制   # demo_name在makefile中使用export demo_name=demo_fifo  
    fsdbDumpvars 0 "tb_top"                # 设置波形的顶层和层次，表示将tb_top作为顶层，Dump所有层次
    run                                    # 设置完dump信息，启动仿真（此时仿真器被ucli控制） 可以run 100ns会在仿真100ns的时候停下来下来
————————————————

debug:
    verdi \
    -sv \                            # 支持sv
    -f ../${demo_name}/tb_top.f \    # 加载设计文件列表
    -top tb_top \                    # 指定设计顶层
    -nologo                          # 关掉欢迎界面

Verdi加载设计的参数与VCS类似
支持+incdir+xx 设置include文件目录
+libext+.v 设置库文件后缀
-v 设置可搜索设计的文件
-y 设置可搜索设计的目录
