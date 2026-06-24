reset

system("rm -rf ../imageout_stream_func")
system("mkdir -p ../imageout_stream_func")

# fortranファイルの出力を見て、ここを書き換えること！
    first_filenum = 1
    last_filenum = 20
#

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


set terminal pngcairo size 1000,500 


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
    set table "../imageout/contour_tmp.dat"
    splot file_in_name using 1:($2/1000.0):7 with lines
    unset table

    # 本番描画
    unset contour
    set surface
    set pm3d map
    set view map

    set title sprintf("t = %.2f day, step = %d", time_sec/86400.0, step_num)

    splot\
    file_in_name using 1:($2/1000.0):7 with pm3d notitle,\
    "../imageout/contour_tmp.dat" using 1:2:3 with lines lc rgb "black" lw 1.5 notitle
}








