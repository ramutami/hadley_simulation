# fortranファイルの出力を見て、ここを書き換えること！
    first_filenum = 1
    last_filenum = 1577
#



# stream_func
    reset

    system("rm -rf ../imageout/*")

    set xrange [-pi/2:pi/2]
    unset xtics
    set xtics ("-π/2" -pi/2, "-π/4" -pi/4, "0" 0, "π/4" pi/4, "π/2" pi/2)
    set xlabel "緯度[rad]"
    set yrange [0:8]
    set ytics 1
    set ylabel "高度[km]"

    set view map
    set pm3d map
    set contour base

    set view 0,0
    set cntrparam levels incremental -5000,500,5000
    unset key
    set colorbox
    set cblabel "流線関数"


    set terminal pngcairo size 800,600 
    set size ratio 0.75

    set palette defined ( \
        -1 "blue",\
        0 "white", \
        1 "red" \
    )


    do for [n=first_filenum:last_filenum]{

        imageout_name = sprintf("../imageout/stream%06d.png", n)
        file_in_name = sprintf("../dataout/hadley%06d.dat", n)
        set output imageout_name

        time_sec = real(system(sprintf("awk 'NR==1{print $3}' %s", file_in_name)))
        step_num = int(system(sprintf("awk 'NR==2{print $4}' %s", file_in_name)))

        # 等値線だけ一時ファイルへ
        unset pm3d
        set contour base
        unset surface

        contour_name  = sprintf("../imageout/contour_tmp_%06d.dat", n)
        contour_clean = sprintf("../imageout/contour_clean_%06d.dat", n)

        set table contour_name
        splot file_in_name using 1:($2/1000.0):7 with lines
        unset table

        system(sprintf("awk 'NF<2{print \"\"; print \"\"; next}{print}' %s > %s", \
            contour_name, contour_clean))

        # 本番描画
        unset contour
        set surface
        set pm3d map
        set view map

        set title sprintf("t = %.2f day, step = %d", time_sec/86400.0, step_num)

        splot\
        file_in_name using 1:($2/1000.0):7 with pm3d notitle,\
        contour_clean using 1:2:3 with lines lc rgb "black" lw 1.5 notitle #,\
        #contour_clean every 75 using 1:2:3:(sprintf("%.0f",$3)) with labels tc rgb "black" notitle


        print sprintf("plotting stream func %d / %d", n, last_filenum)
    }

    system("rm ../videoout/stream_func.mp4")
    system("ffmpeg -framerate 10 \
    -i ../imageout/stream%06d.png \
    -c:v libx264 \
    -pix_fmt yuv420p \
    -movflags +faststart \
    ../videoout/stream_func.mp4")

    system("rm -r ../imageout/*")
    # system("rm -r ../dataout/*")
#

# 東西流速
    
    system("rm -rf ../imageout/*")

    set cntrparam levels incremental -20,5,60
    set cblabel "東西流速[m/s]"


    set palette defined ( \
        -1 "blue",\
        0 "white", \
        1 "red" \
    )


    do for [n=first_filenum:last_filenum]{

        imageout_name = sprintf("../imageout/westerlies%06d.png", n)
        file_in_name = sprintf("../dataout/hadley%06d.dat", n)
        set output imageout_name

        time_sec = real(system(sprintf("awk 'NR==1{print $3}' %s", file_in_name)))
        step_num = int(system(sprintf("awk 'NR==2{print $4}' %s", file_in_name)))

        # 等値線だけ一時ファイルへ
        unset pm3d
        set contour base
        unset surface

        contour_name  = sprintf("../imageout/contour_tmp_%06d.dat", n)
        contour_clean = sprintf("../imageout/contour_clean_%06d.dat", n)

        set table contour_name
        splot file_in_name using 1:($2/1000.0):3 with lines
        unset table

        system(sprintf("awk 'NF<2{print \"\"; print \"\"; next}{print}' %s > %s", \
            contour_name, contour_clean))

        # 本番描画
        unset contour
        set xrange [-pi/2:pi/2]
        set surface
        set pm3d map
        set view map

        set title sprintf("t = %.2f day, step = %d", time_sec/86400.0, step_num)

        splot\
        file_in_name using 1:($2/1000.0):3 with pm3d notitle,\
        contour_clean using 1:2:3 with lines lc rgb "black" lw 1.5 notitle,\
        contour_clean every 75 using 1:2:3:(sprintf("%.0f",$3)) with labels tc rgb "black" notitle

        print sprintf("plotting westerlies %d / %d", n, last_filenum)
    }

    system("rm ../videoout/westerlies.mp4")
    system("ffmpeg -framerate 10 \
    -i ../imageout/westerlies%06d.png \
    -c:v libx264 \
    -pix_fmt yuv420p \
    -movflags +faststart \
    ../videoout/westerlies.mp4")

    system("rm -r ../imageout/*")
    # system("rm -r ../dataout/*")
#

# 南北流速
    system("rm -rf ../imageout/*")

    set cntrparam levels incremental -10,1,10
    set cblabel "南北流速[m/s]"


    set palette defined ( \
        -1 "blue",\
        0 "white", \
        1 "red" \
    )

    do for [n=first_filenum:last_filenum]{

        imageout_name = sprintf("../imageout/southwind%06d.png", n)
        file_in_name = sprintf("../dataout/hadley%06d.dat", n)
        set output imageout_name

        time_sec = real(system(sprintf("awk 'NR==1{print $3}' %s", file_in_name)))
        step_num = int(system(sprintf("awk 'NR==2{print $4}' %s", file_in_name)))

        # 等値線だけ一時ファイルへ
        unset pm3d
        set contour base
        unset surface

        contour_name  = sprintf("../imageout/contour_tmp_%06d.dat", n)
        contour_clean = sprintf("../imageout/contour_clean_%06d.dat", n)

        set table contour_name
        splot file_in_name using 1:($2/1000.0):4 with lines
        unset table

        system(sprintf("awk 'NF<2{print \"\"; print \"\"; next}{print}' %s > %s", \
            contour_name, contour_clean))

        # 本番描画
        unset contour
        set xrange [-pi/2:pi/2]
        set surface
        set pm3d map
        set view map

        set title sprintf("t = %.2f day, step = %d", time_sec/86400.0, step_num)

        splot\
        file_in_name using 1:($2/1000.0):4 with pm3d notitle,\
        contour_clean using 1:2:3 with lines lc rgb "black" lw 1.5 notitle,\
        contour_clean every 75 using 1:2:3:(sprintf("%.0f",$3)) with labels tc rgb "black" notitle

        print sprintf("plotting southwind %d / %d", n, last_filenum)
    }

    system("rm ../videoout/southwind.mp4")
    system("ffmpeg -framerate 10 \
    -i ../imageout/southwind%06d.png \
    -c:v libx264 \
    -pix_fmt yuv420p \
    -movflags +faststart \
    ../videoout/southwind.mp4")

    system("rm -r ../imageout/*")
    # system("rm -r ../dataout/*")
#

# 鉛直流
    system("rm -rf ../imageout/*")

    set cntrparam levels incremental -0.01,0.001,0.01
    set cblabel "鉛直流[m/s]"


    set palette defined ( \
        -1 "blue",\
        0 "white", \
        1 "red" \
    )

    do for [n=first_filenum:last_filenum]{

        imageout_name = sprintf("../imageout/upward%06d.png", n)
        file_in_name = sprintf("../dataout/hadley%06d.dat", n)
        set output imageout_name

        time_sec = real(system(sprintf("awk 'NR==1{print $3}' %s", file_in_name)))
        step_num = int(system(sprintf("awk 'NR==2{print $4}' %s", file_in_name)))

        # 等値線だけ一時ファイルへ
        unset pm3d
        set contour base
        unset surface

        contour_name  = sprintf("../imageout/contour_tmp_%06d.dat", n)
        contour_clean = sprintf("../imageout/contour_clean_%06d.dat", n)

        set table contour_name
        splot file_in_name using 1:($2/1000.0):5 with lines
        unset table

        system(sprintf("awk 'NF<2{print \"\"; print \"\"; next}{print}' %s > %s", \
            contour_name, contour_clean))

        # 本番描画
        unset contour
        set xrange [-pi/2:pi/2]
        set surface
        set pm3d map
        set view map

        set title sprintf("t = %.2f day, step = %d", time_sec/86400.0, step_num)

        splot\
        file_in_name using 1:($2/1000.0):5 with pm3d notitle,\
        contour_clean using 1:2:3 with lines lc rgb "black" lw 1.5 notitle #,\
        #contour_clean every 75 using 1:2:3:(sprintf("%.3f",$3)) with labels tc rgb "black" notitle

        print sprintf("plotting upward %d / %d", n, last_filenum)
    }

    system("rm ../videoout/upward.mp4")
    system("ffmpeg -framerate 10 \
    -i ../imageout/upward%06d.png \
    -c:v libx264 \
    -pix_fmt yuv420p \
    -movflags +faststart \
    ../videoout/upward.mp4")

    #system("rm -r ../imageout/*")
    # system("rm -r ../dataout/*")
#


# 温位
    system("rm -rf ../imageout/*")

    set cntrparam levels incremental 0.5,0.05,1.15
    set cblabel "正規化された温位"


    set palette defined ( \
        -1 "blue",\
        0 "white", \
        1 "red" \
    )

    do for [n=first_filenum:last_filenum]{

        imageout_name = sprintf("../imageout/pottemp%06d.png", n)
        file_in_name = sprintf("../dataout/hadley%06d.dat", n)
        set output imageout_name

        time_sec = real(system(sprintf("awk 'NR==1{print $3}' %s", file_in_name)))
        step_num = int(system(sprintf("awk 'NR==2{print $4}' %s", file_in_name)))

        # 等値線だけ一時ファイルへ
        unset pm3d
        set contour base
        unset surface

        contour_name  = sprintf("../imageout/contour_tmp_%06d.dat", n)
        contour_clean = sprintf("../imageout/contour_clean_%06d.dat", n)

        set table contour_name
        splot file_in_name using 1:($2/1000.0):6 with lines
        unset table

        system(sprintf("awk 'NF<2{print \"\"; print \"\"; next}{print}' %s > %s", \
            contour_name, contour_clean))

        # 本番描画
        unset contour
        set xrange [-pi/2:pi/2]
        set surface
        set pm3d map
        set view map

        set title sprintf("t = %.2f day, step = %d", time_sec/86400.0, step_num)

        splot\
        file_in_name using 1:($2/1000.0):6 with pm3d notitle,\
        contour_clean using 1:2:3 with lines lc rgb "black" lw 1.5 notitle,\
        #contour_clean every 75 using 1:2:3:(sprintf("%.3f",$3)) with labels tc rgb "black" notitle

        print sprintf("plotting upwardwind %d / %d", n, last_filenum)
    }

    system("rm ../videoout/pottemp.mp4")
    system("ffmpeg -framerate 10 \
    -i ../imageout/pottemp%06d.png \
    -c:v libx264 \
    -pix_fmt yuv420p \
    -movflags +faststart \
    ../videoout/pottemp.mp4")

    #system("rm -r ../imageout/*")
    #system("rm -r ../dataout/*")
#







