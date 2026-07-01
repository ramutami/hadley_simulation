ROOT_DIR="$(pwd)"

#
    cd "$ROOT_DIR"
    mkdir -p ./out
    gfortran -fopenmp main.f90 -L/Users/shotamitamura/Documents/folders/gakugyou/大学/Classes/2024/S/計算機演習/fortran -llapack -lrefblas -o ./out/main.out
    echo 0.0 | ./out/main.out

    mkdir -p ./plt/out
    cd ./plt
    gnuplot -e "nu='0.0'" plot_all.plt
#
    cd "$ROOT_DIR"
    mkdir -p ./out
    gfortran -fopenmp main.f90 -L/Users/shotamitamura/Documents/folders/gakugyou/大学/Classes/2024/S/計算機演習/fortran -llapack -lrefblas -o ./out/main.out
    echo 25.0 | ./out/main.out

    mkdir -p ./plt/out
    cd ./plt
    gnuplot -e "nu='25.0'" plot_all.plt

#
    cd "$ROOT_DIR"
    mkdir -p ./out
    gfortran -fopenmp main.f90 -L/Users/shotamitamura/Documents/folders/gakugyou/大学/Classes/2024/S/計算機演習/fortran -llapack -lrefblas -o ./out/main.out
    echo 10.0 | ./out/main.out

    mkdir -p ./plt/out
    cd ./plt
    gnuplot -e "nu='10.0'" plot_all.plt

#
    cd "$ROOT_DIR"
    mkdir -p ./out
    gfortran -fopenmp main.f90 -L/Users/shotamitamura/Documents/folders/gakugyou/大学/Classes/2024/S/計算機演習/fortran -llapack -lrefblas -o ./out/main.out
    echo 5.0 | ./out/main.out

    mkdir -p ./plt/out
    cd ./plt
    gnuplot -e "nu='5.0'" plot_all.plt

#
    cd "$ROOT_DIR"
    mkdir -p ./out
    gfortran -fopenmp main.f90 -L/Users/shotamitamura/Documents/folders/gakugyou/大学/Classes/2024/S/計算機演習/fortran -llapack -lrefblas -o ./out/main.out
    echo 2.5 | ./out/main.out

    mkdir -p ./plt/out
    cd ./plt
    gnuplot -e "nu='2.5'" plot_all.plt

#
    cd "$ROOT_DIR"
    mkdir -p ./out
    gfortran -fopenmp main.f90 -L/Users/shotamitamura/Documents/folders/gakugyou/大学/Classes/2024/S/計算機演習/fortran -llapack -lrefblas -o ./out/main.out
    echo 1.0 | ./out/main.out

    mkdir -p ./plt/out
    cd ./plt
    gnuplot -e "nu='1.0'" plot_all.plt

#
    cd "$ROOT_DIR"
    mkdir -p ./out
    gfortran -fopenmp main.f90 -L/Users/shotamitamura/Documents/folders/gakugyou/大学/Classes/2024/S/計算機演習/fortran -llapack -lrefblas -o ./out/main.out
    echo 0.5 | ./out/main.out

    mkdir -p ./plt/out
    cd ./plt
    gnuplot -e "nu='0.5'" plot_all.plt


