
module parameters_and_variables_for_simulation
    implicit none
    real(8), parameter :: pi = atan(1.0d0)*4.0d0
    !gloval_parameters
        !global定数：すべてのmoduleのsubroutineで参照可能な変数

        !------------change allowed--------------!
        real(8) :: nu = 25.0d0 !粘性、色々変えたりする。
        real(8),parameter :: z_max=8.0d3 !子午面の高さ[m]
        integer,parameter :: j_max=180 !緯度方向の格子数
        integer,parameter :: k_max=50 !z方向の格子数
        real(8),parameter :: delta_t = 50.0d0 !時間積分間隔[s]
        real(8),parameter :: max_t = 100.0d0 * 86400.0d0 !時間積分の打ち切り時間[s],day * 86400.0d0
        integer,parameter :: outstep_interval = 2000

        real(8),parameter :: a = 6.4d6!地球半径[m]
        real(8),parameter :: Omega = 2.0d0*pi/8.64d4 !自転
        real(8),parameter :: tau = 20.0d0 * 86400.0d0 !realxation time[s],
        real(8),parameter :: g  = 9.8d0!重力加速度
        real(8),parameter :: Delta_H = 1.0d0/3.0d0
        real(8),parameter :: Delta_v = 1.0d0/8.0d0
        real(8),parameter :: C_drag = 0.005d0 !摩擦
        !------------change allowed--------------!

        real(8),parameter :: H = z_max
        real(8),parameter :: dtheta  = pi/real(j_max,8) !緯度方向の格子幅Delta_theta
        real(8),parameter :: dz = H/real(k_max,8) !z方向の格子幅Delta_z
        integer,parameter :: timestep_max = floor(max_t/delta_t)!時間ステップの最大数

    !

    !global_variables
        !global変数：すべてのmoduleのsubroutineで参照可能な変数

        real(8),allocatable :: u(:,:)
        real(8),allocatable :: u_mid(:,:) !松野スキームにおける中間ステップ出力
        real(8),allocatable :: u_temporal(:,:)
        real(8),allocatable :: v(:,:)
        real(8),allocatable :: v_mid(:,:)
        real(8),allocatable :: v_temporal(:,:)
        real(8),allocatable :: pot_temp(:,:) !正規化された温位
        real(8),allocatable :: pot_temp_mid(:,:) 
        real(8),allocatable :: pot_temp_temporal(:,:)
        real(8),allocatable :: pot_temp_E(:,:)
        real(8),allocatable :: w(:,:)
        real(8),allocatable :: Phi_diff(:,:) !ポテンシャルPhiのtheta微分
        real(8),allocatable :: theta(:) !緯度
        real(8),allocatable :: z(:) !高度
        real(8),allocatable :: stream_func(:,:)

    !

    contains
    subroutine allocate_variables() 
        implicit none   
        integer :: j,k

        allocate(u(-1:j_max,-1:k_max))
        allocate(u_mid(-1:j_max,-1:k_max))
        allocate(u_temporal(-1:j_max,-1:k_max))
        allocate(v(0:j_max,-1:k_max))
        allocate(v_mid(0:j_max,-1:k_max))
        allocate(v_temporal(0:j_max,-1:k_max))
        allocate(pot_temp(-1:j_max,-1:k_max))
        allocate(pot_temp_mid(-1:j_max,-1:k_max))
        allocate(pot_temp_temporal(-1:j_max,-1:k_max))
        allocate(pot_temp_E(0:j_max-1,0:k_max-1))
        allocate(w(0:j_max-1,0:k_max))
        allocate(Phi_diff(0:j_max-1,0:k_max))
        allocate(theta(-1:j_max))
        allocate(z(0:k_max-1))
        allocate(stream_func(0:j_max-1,0:k_max))

        do j = lbound(theta,1),ubound(theta,1)
            theta(j) = -pi/2.0d0 + (j+0.5d0)*dtheta
        end do
        do k = lbound(z,1),ubound(z,1)
            z(k) = (k+0.5d0)*dz
        end do

    end subroutine allocate_variables


end module parameters_and_variables_for_simulation

module initialization 
    use parameters_and_variables_for_simulation
    implicit none

    contains
    subroutine initialize_pot_temp_E
        implicit none
        integer :: j,k
        real(8) :: p2,z


        do k = lbound(pot_temp_E,2),ubound(pot_temp_E, dim=2)
            z = (real(k,8)+0.5d0) * dz
            do j = lbound(pot_temp_E,1),ubound(pot_temp_E, dim=1)
                p2 = 0.5d0*(3.0d0*sin(theta(j))**2-1.0d0)
                pot_temp_E(j,k) = 1.0d0 - (2.0d0/3.0d0) * Delta_H * p2 + Delta_v * (z/H - 0.5d0)
            end do
        end do

    end subroutine initialize_pot_temp_E

    subroutine initialize_field
        implicit none
        integer :: j,k

        u = 0.0d0
        u_mid = 0.0d0
        v = 0.0d0
        v_mid = 0.0d0

        do k = lbound(pot_temp_E,2),ubound(pot_temp_E, dim=2)
        do j = lbound(pot_temp_E,1),ubound(pot_temp_E, dim=1)
            pot_temp(j,k) = pot_temp_E(j,k)
        end do
        end do

        pot_temp_mid = 0.0d0
        w = 0.0d0
        Phi_diff = 0.0d0
        stream_func = 0.0d0
    end subroutine initialize_field
end module initialization

module update_variables
    use parameters_and_variables_for_simulation
    implicit none

    contains 

    subroutine update_u(u_in,v_in,w_in,u_n,u_out) 
        implicit none
        real(8),intent(in) :: u_in(-1:j_max,-1:k_max) 
        real(8),intent(in) :: v_in(0:j_max,-1:k_max)
        real(8),intent(in) :: w_in(0:j_max-1,0:k_max)
        real(8),intent(in) :: u_n(-1:j_max,-1:k_max)
        real(8),intent(out) :: u_out(-1:j_max,-1:k_max)

        integer :: j,k
        real(8) :: term1,term2,term3,term4,term5

        do k = 0,k_max-1
        do j = 0,j_max-1
            term1 = -1.0d0/(a*cos(theta(j))) *( (u_in(j,k)+u_in(j+1,k))/2.0d0 * v_in(j+1,k)*cos(0.5d0*(theta(j+1)+theta(j))) &
            & - (u_in(j-1,k)+u_in(j,k))/2.0d0 * v_in(j,k)*cos(0.5d0*(theta(j)+theta(j-1))) ) / dtheta
            term2 = -1.0d0* (0.5d0*(u_in(j,k)+u_in(j,k+1))*w_in(j,k+1)-0.5d0*(u_in(j,k-1)+u_in(j,k))*w_in(j,k))/dz
            term3 = 2.0d0 * Omega * sin(theta(j)) * 0.5d0*(v_in(j,k)+v_in(j+1,k))
            term4 = (u_in(j,k)*0.5d0*(v_in(j,k)+v_in(j+1,k))*tan(theta(j)))/a
            term5 = nu/dz * ((u_in(j,k+1)-u_in(j,k))/dz - (u_in(j,k)-u_in(j,k-1))/dz)
            u_out(j,k) = u_n(j,k) + delta_t * (term1 + term2 + term3 + term4 + term5)
        end do
        end do

    end subroutine update_u

    subroutine update_v(u_in,v_in,w_in,Phi_diff_in,v_n,v_out)
        implicit none
        real(8),intent(in) :: u_in(-1:j_max,-1:k_max) 
        real(8),intent(in) :: v_in(0:j_max,-1:k_max)
        real(8),intent(in) :: w_in(0:j_max-1,0:k_max)
        real(8),intent(in) :: Phi_diff_in(0:j_max-1,0:k_max)
        real(8),intent(in) :: v_n(0:j_max,-1:k_max)
        real(8),intent(out) :: v_out(0:j_max,-1:k_max)

        integer :: j,k
        real(8) :: term1,term2,term3,term4,term5,term6

        do k = 0,k_max-1
            do j = 1,j_max-1
                term1 = -1.0d0/(a*cos(0.5d0*(theta(j-1)+theta(j)))) * ((0.5d0*(v_in(j,k) + v_in(j+1,k)))**2 * cos(theta(j))-(0.5d0*(v_in(j-1,k) + v_in(j,k)))**2 * cos(theta(j-1)))/dtheta
                term2 = -1.0d0 * (0.5d0*(w_in(j-1,k+1) + w_in(j,k+1))*0.5d0*(v_in(j,k+1)+v_in(j,k))-0.5d0*(w_in(j-1,k) + w_in(j,k))*0.5d0*(v_in(j,k)+v_in(j,k-1)))/dz
                term3 = -2.0d0*Omega*sin(0.5d0*(theta(j-1)+theta(j))) * 0.5d0*(u_in(j,k)+u_in(j-1,k))
                term4 = -1.0d0 * (0.5d0*(u_in(j,k) + u_in(j-1,k)))**2 * tan(0.5d0*(theta(j-1)+theta(j)))/a
                term5 = -1.0d0/a/4.0d0 * (Phi_diff_in(j-1,k) + Phi_diff_in(j-1,k+1) + Phi_diff_in(j,k) + Phi_diff_in(j,k+1))
                term6 = nu/dz/dz * (v_in(j,k+1)-v_in(j,k)-v_in(j,k)+v_in(j,k-1))
                v_out(j,k) = v_n(j,k) + delta_t * (term1 + term2 + term3 + term4 + term5 + term6)
            end do

            v_out(0,k) = 0.0d0
            v_out(j_max,k) = 0.0d0
        
        end do

    end subroutine update_v

    subroutine update_potential_temperature(v_in,w_in,pot_temp_in,pot_temp_n,pot_temp_out)
        implicit none
        real(8),intent(in) :: v_in(0:j_max,-1:k_max)
        real(8),intent(in) :: w_in(0:j_max-1,0:k_max)
        real(8),intent(in) :: pot_temp_in(-1:j_max,-1:k_max)
        real(8),intent(in) :: pot_temp_n(-1:j_max,-1:k_max)
        real(8),intent(out) :: pot_temp_out(-1:j_max,-1:k_max)

        real(8) :: term1,term2,term3,term4
        integer :: j,k

        do k = 0,k_max-1
        do j = 0,j_max-1
            term1 = -1.0d0/(a*cos(theta(j))) *( (pot_temp_in(j,k)+pot_temp_in(j+1,k))/2.0d0 * v_in(j+1,k)*cos(0.5d0*(theta(j+1)+theta(j))) &
            & - (pot_temp_in(j-1,k)+pot_temp_in(j,k))/2.0d0 * v_in(j,k)*cos(0.5d0*(theta(j)+theta(j-1))) ) / dtheta
            term2 = -1.0d0* (0.5d0*(pot_temp_in(j,k)+pot_temp_in(j,k+1))*w_in(j,k+1)-0.5d0*(pot_temp_in(j,k-1)+pot_temp_in(j,k))*w_in(j,k))/dz
            term3 = -1.0d0*(pot_temp_in(j,k)-pot_temp_E(j,k))/tau
            term4 = nu/dz * ((pot_temp_in(j,k+1)-pot_temp_in(j,k))/dz - (pot_temp_in(j,k)-pot_temp_in(j,k-1))/dz)
            pot_temp_out(j,k) = pot_temp_n(j,k) + delta_t * (term1+term2+term3+term4)
        end do
        end do


    end subroutine update_potential_temperature

end module update_variables

module calculate_variables
    use parameters_and_variables_for_simulation
    implicit none

    contains 

    subroutine calculate_w(v_in)
        implicit none
        real(8),intent(in) :: v_in(0:j_max,-1:k_max)
        integer :: j,k
        real(8) :: w_value
        real(8) :: term1

        do j = 0,j_max-1
            w_value = 0.0d0
            do k = 0,k_max
                w(j,k) = w_value
                if (k == k_max) exit
                term1 = -1.0d0/(a*cos(theta(j))) * (v_in(j+1,k)*cos(0.5d0*(theta(j+1)+theta(j))) - v_in(j,k)*cos(0.5d0*(theta(j)+theta(j-1))))/dtheta
                w_value = w_value + dz * term1
            end do
        end do

    end subroutine calculate_w

    subroutine calculate_partial_Phi(u_in,v_in,pot_temp_in,w_in)
        implicit none
        real(8),intent(in) :: u_in(-1:j_max,-1:k_max) 
        real(8),intent(in) :: v_in(0:j_max,-1:k_max)
        real(8),intent(in) :: pot_temp_in(-1:j_max,-1:k_max)
        real(8),intent(in) :: w_in(0:j_max-1,0:k_max)

        integer :: j,k
        real(8) :: integral,term3,term1
        real(8) :: val1,val2,val3,val4,val5
        real(8) :: pot_temp_integral(0:j_max-1,0:k_max)

        do j = 0,j_max-1
            integral = 0.0d0
            do k = 0,k_max
                pot_temp_integral(j,k) = integral
                if (k == k_max) exit
                integral = integral + dz*g*(pot_temp_in(j+1,k)-pot_temp_in(j-1,k))/2.0d0/dtheta
            end do

            term3 = 0.0d0
            do k = 0,k_max-1
                term3 = term3 + dz*0.5d0 * (pot_temp_integral(j,k) + pot_temp_integral(j,k+1))
            end do
            term3 = -1.0d0*term3/H

            term1 = 0.0d0
            do k = 0,k_max-1
                val1 = -1.0d0/(a*cos(theta(j))) * (v_in(j+1,k)**2 * cos(0.5d0*(theta(j)+theta(j+1))) - v_in(j,k)**2 * cos(0.5d0*(theta(j-1)+theta(j))))/dtheta
                val2 = -1.0d0/dz*(w_in(j,k+1)*0.25d0*(v_in(j,k)+v_in(j+1,k)+v_in(j,k+1)+v_in(j+1,k+1)) - w_in(j,k)*0.25d0*(v_in(j,k-1)+v_in(j+1,k-1)+v_in(j,k)+v_in(j+1,k)))
                val3 = -2.0d0*Omega*sin(theta(j))*u_in(j,k)
                val4 = -1.0d0*u_in(j,k)**2*tan(theta(j))/a
                val5 = nu/dz/dz*(0.5d0*(v_in(j,k+1)+v_in(j+1,k+1))-0.5d0*(v_in(j,k)+v_in(j+1,k)) - 0.5d0*(v_in(j,k)+v_in(j+1,k)) + 0.5d0*(v_in(j,k-1)+v_in(j+1,k-1)))
                term1 = term1 + dz*(val1+val2+val3+val4+val5)
            end do
            term1 = term1 * a/H

            do k = 0,k_max
                Phi_diff(j,k) = term1 + term3 + pot_temp_integral(j,k)
            end do

        end do

    end subroutine calculate_partial_Phi
    
end module calculate_variables

module update_boundary
    use parameters_and_variables_for_simulation
    implicit none

    contains 

    subroutine update_boundary_u(u_in)
        implicit none
        real(8),intent(inout) :: u_in(-1:j_max,-1:k_max)
        integer :: j,k

        do k=0,k_max-1
            u_in(-1,k) = -u_in(0,k)
            u_in(j_max,k) = -u_in(j_max-1,k)
        end do

        do j=-1,j_max
            u_in(j,k_max) = u_in(j,k_max-1)
            u_in(j,-1) = (nu/dz - C_drag/2.0d0)/(nu/dz + C_drag/2.0d0)*u_in(j,0)
        end do
    end subroutine update_boundary_u

    subroutine update_boundary_v(v_in)
        implicit none
        integer :: j
        real(8),intent(inout) :: v_in(0:j_max,-1:k_max)

        do j = 0,j_max
            v_in(j,k_max) = v_in(j,k_max-1)
            v_in(j,-1) = (nu/dz - C_drag/2.0d0)/(nu/dz + C_drag/2.0d0)*v_in(j,0)
        end do

    end subroutine update_boundary_v

    subroutine update_boundary_potential_temp(pot_temp_in)
        implicit none
        real(8),intent(inout) :: pot_temp_in(-1:j_max,-1:k_max)
        integer :: j,k

        do k = 0,k_max-1
            pot_temp_in(-1,k) = pot_temp_in(0,k)
            pot_temp_in(j_max,k) = pot_temp_in(j_max-1,k)
        end do

        do j = -1,j_max 
            pot_temp_in(j,k_max) = pot_temp_in(j,k_max-1)
            pot_temp_in(j,-1) = pot_temp_in(j,0)
        end do

    end subroutine update_boundary_potential_temp

end module update_boundary

module output_module
    use parameters_and_variables_for_simulation
    implicit none
    character(len=128) :: filename
    integer :: j,k

    contains

    subroutine initiate_directory
        implicit none
        call execute_command_line("rm -rf ./dataout")
        call execute_command_line("mkdir -p ./dataout")
    end subroutine initiate_directory

    subroutine calculate_stream_function(v_in)
        implicit none
        real(8),intent(in) :: v_in(0:j_max,-1:k_max)
        integer :: j,k
        real(8) :: val

        do j = 0,j_max-1
            val = 0.0d0
            do k = 0,k_max
                stream_func(j,k) = val
                if (k==k_max) exit
                val = val -0.5d0*(v_in(j,k)+v_in(j+1,k))*cos(theta(j))*dz
            end do
        end do

    end subroutine calculate_stream_function

    subroutine write_data(time,output_step,timestep)
        implicit none
        real(8),intent(in) :: time
        integer,intent(in) :: output_step,timestep
        write(filename,fmt='("./dataout/hadley",i6.6,".dat")') output_step
        open(10,file=filename,status='replace',action='write')
        write(10,*) "# time[s]",time
        write(10,*) "# calculation step",timestep
        write(10,*) "# theta[rad],z[m],u[m/s],v[m/s],w[m/s],potential_temperature,stream_function"
        !セル中央での値を出力する！
        do k=0,k_max-1
        do j=0,j_max-1
            write(10,*) theta(j),z(k),u(j,k),0.5d0*(v(j,k)+v(j+1,k)),&
            & 0.5d0*(w(j,k)+w(j,k+1)),pot_temp(j,k),0.5d0*(stream_func(j,k)+stream_func(j,k+1))
        end do
        write(10,*)" "
        end do

        close(10)
    end subroutine write_data
end module output_module

program main
    use parameters_and_variables_for_simulation
    use initialization
    use update_variables
    use update_boundary
    use calculate_variables
    use output_module
    implicit none

    integer :: timestep,outstep
    real(8) :: time

    !初期状態の設定
    call initiate_directory()
    call allocate_variables()
    call initialize_pot_temp_E()
    call initialize_field()
    call update_boundary_u(u)
    call update_boundary_v(v)
    call update_boundary_potential_temp(pot_temp)

    outstep = 0
    do timestep = 1,timestep_max
        
        !u^n,v^n,...から診断変数を求める(松野スキームステップ1)
        call calculate_w(v)
            !出力
            if (mod(timestep,outstep_interval)==1) then
                call calculate_stream_function(v_in=v)
                outstep = outstep + 1
                write(*,'(f4.1,A,i4)') real(timestep-1,8)*100.0/real(timestep_max,8),"%, outputstep=",outstep
                time = delta_t * (timestep-1)
                call write_data(time,outstep,timestep-1)
            end if
        call calculate_partial_Phi(u_in=u,v_in=v,pot_temp_in=pot_temp,w_in=w)

        !u^n,v^n,...+診断変数によりu^*,v^*...を求める
        call update_u(u_in=u, v_in=v, w_in=w, u_n=u, u_out=u_mid)
        call update_boundary_u(u_in=u_mid)
        call update_v(u_in=u,v_in=v,w_in=w,Phi_diff_in=Phi_diff,v_n=v,v_out=v_mid)
        call update_boundary_v(v_in=v_mid)
        call update_potential_temperature(v_in=v,w_in=w,pot_temp_in=pot_temp,pot_temp_n=pot_temp,pot_temp_out=pot_temp_mid)
        call update_boundary_potential_temp(pot_temp_in=pot_temp_mid)

        !u^*,v^*..から診断変数を求める(松野スキームのステップ2)
        call calculate_w(v_mid)
        call calculate_partial_Phi(u_in=u_mid,v_in=v_mid,pot_temp_in=pot_temp_mid,w_in=w)

        !u^n,v^n,...+診断変数によりu^n+1,v^n+1,...を求める
        call update_u(u_in=u_mid,v_in=v_mid,w_in=w,u_n=u,u_out=u_temporal)
        u = u_temporal
        call update_boundary_u(u_in=u)
        call update_v(u_in=u_mid,v_in=v_mid,w_in=w,Phi_diff_in=Phi_diff,v_n=v,v_out=v_temporal)
        v = v_temporal
        call update_boundary_v(v_in=v)
        call update_potential_temperature(v_in=v_mid,w_in=w,pot_temp_in=pot_temp_mid,pot_temp_n=pot_temp,pot_temp_out=pot_temp_temporal)
        pot_temp = pot_temp_temporal
        call update_boundary_potential_temp(pot_temp_in=pot_temp)

    end do


end program main
