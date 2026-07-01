# fortranファイルの出力を見て、ここを書き換えること！
    first_filenum = 1
    last_filenum = 300
#

# 変数の受け渡し
    if (!exists("nu")) nu = "unknown"
    nu_tag = nu
    nu_tag = system(sprintf("echo %s | sed 's/\\./p/g'", nu))
    video_dir = sprintf("../videoout/nu%s", nu_tag)
    system(sprintf("mkdir -p %s", video_dir))
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
    set cntrparam levels 20
    unset key
    set colorbox
    set cblabel "流線関数"


    set terminal pngcairo size 800,600 
    set size ratio 0.50

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

    video_name = sprintf("%s/stream_func.mp4", video_dir)
    system(sprintf("rm -f %s", video_name))
    system(sprintf("ffmpeg -framerate 10 -i ../imageout/stream%%06d.png -c:v libx264 -pix_fmt yuv420p -movflags +faststart %s", video_name))
    system("rm -r ../imageout/*")
    # system("rm -r ../dataout/*")
#

# 東西流速
    
    system("rm -rf ../imageout/*")

    #set cntrparam levels incremental -100,5,100
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

    video_name = sprintf("%s/westerlies.mp4", video_dir)
    system(sprintf("rm -f %s", video_name))
    system(sprintf("ffmpeg -framerate 10 -i ../imageout/westerlies%%06d.png -c:v libx264 -pix_fmt yuv420p -movflags +faststart %s", video_name))

    system("rm -r ../imageout/*")
    # system("rm -r ../dataout/*")
#

# 南北流速
    system("rm -rf ../imageout/*")

    set cntrparam levels incremental -20,0.5,20
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

    video_name = sprintf("%s/southwind.mp4", video_dir)
    system(sprintf("rm -f %s", video_name))
    system(sprintf("ffmpeg -framerate 10 -i ../imageout/southwind%%06d.png -c:v libx264 -pix_fmt yuv420p -movflags +faststart %s", video_name))

    system("rm -r ../imageout/*")
    # system("rm -r ../dataout/*")
#

# 鉛直流
    system("rm -rf ../imageout/*")

    #set cntrparam levels incremental -0.02,0.001,0.02
    set cntrparam levels 20
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

    video_name = sprintf("%s/upward.mp4", video_dir)
    system(sprintf("rm -f %s", video_name))
    system(sprintf("ffmpeg -framerate 10 -i ../imageout/upward%%06d.png -c:v libx264 -pix_fmt yuv420p -movflags +faststart %s", video_name))

    #system("rm -r ../imageout/*")
    # system("rm -r ../dataout/*")
#

# 温位
    system("rm -rf ../imageout/*")

    set cntrparam levels incremental 0.3,0.05,1.2
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

    video_name = sprintf("%s/pottemp.mp4", video_dir)
    system(sprintf("rm -f %s", video_name))
    system(sprintf("ffmpeg -framerate 10 -i ../imageout/pottemp%%06d.png -c:v libx264 -pix_fmt yuv420p -movflags +faststart %s", video_name))

    #system("rm -r ../imageout/*")
    #system("rm -r ../dataout/*")
#

# v鉛直積分

    set terminal pngcairo size 800,600      

    image_name = sprintf("%s/integral.png", video_dir)
    set output image_name
    set title 'vの鉛直積分' 

    set xrange [*:*]
    set yrange [*:*]
    set xtics auto
    set ytics auto
    set grid
    set ylabel 'vの鉛直積分 |∫v dz|' 
    set xlabel '時間 [day]' 
    set logscale y
    set yrange
    set size ratio 0.5
    set format y "%.1t×10^{%L}"

    plot '../dataout/v_integral.dat' using 1:2 every ::1 with lines lc 'black' lw 1 notitle
#






