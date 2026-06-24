reset

system("rm -rf ../imageout_westwind")
system("mkdir -p ../imageout_westwind")

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

set surface
set view map
set pm3d map

set view 0,0
unset key
set colorbox
set cblabel "東向きの風u[m/s]"


set terminal pngcairo size 1000,500 


do for [n=first_filenum:last_filenum]{

    imageout_name = sprintf("../imageout/westsind%06d.png", n)
    file_in_name = sprintf("../dataout/hadley%06d.dat", n)
    set output imageout_name

    time_sec = real(system(sprintf("awk 'NR==1{print $3}' %s", file_in_name)))
    step_num = int(system(sprintf("awk 'NR==2{print $4}' %s", file_in_name)))

    set title sprintf("t = %.2f day, step = %d", time_sec/86400.0, step_num)

    splot\
    file_in_name using 1:($2/1000.0):3 with pm3d notitle
}








